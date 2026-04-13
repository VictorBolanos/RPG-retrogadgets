-- Skill.lua - Complete skill system
local BD = require("BD.lua")

local Skill = {}

---------------------------------------------------------------------------
-- Skill functions

function Skill:GetSkillData(skillId)
    for _, skill in ipairs(BD.skills) do
        if skill.id == skillId then
            return skill
        end
    end
    return nil
end

function Skill:CanLearnSkill(player, skillId)
    local skillData = self:GetSkillData(skillId)
    if not skillData then return false, "Skill doesn't exist" end
    
    -- Check if already learned
    for _, learnedId in ipairs(player.skills) do
        if learnedId == skillId then
            return false, "Already learned"
        end
    end
    
    -- Check required level
    if player.level < skillData.requiredLevel then
        return false, "Insufficient level"
    end
    
    -- Check prerequisite skill
    if skillData.requiredSkill then
        local hasPrerequisite = false
        for _, learnedId in ipairs(player.skills) do
            if learnedId == skillData.requiredSkill then
                hasPrerequisite = true
                break
            end
        end
        if not hasPrerequisite then
            return false, "Missing prerequisite"
        end
    end
    
    -- Check skill points
    if player.skillPoints < 1 then
        return false, "No skill points"
    end
    
    return true, "OK"
end

function Skill:LearnSkill(player, skillId)
    local canLearn, reason = self:CanLearnSkill(player, skillId)
    if not canLearn then
        return false, reason
    end
    
    local skillData = self:GetSkillData(skillId)
    
    -- Add skill to learned list
    table.insert(player.skills, skillId)
    player.skillPoints = player.skillPoints - 1
    
    -- If passive, apply bonus immediately
    if skillData.type == "passive" and skillData.statBonus then
        for stat, bonus in pairs(skillData.statBonus) do
            player.equipmentStatBonuss[stat] = (player.equipmentStatBonuss[stat] or 0) + bonus
        end
        player:updateSubStats()
    end
    
    return true, "Skill learned!"
end

function Skill:CanEquipSkill(player, skillId, slot)
    -- Check if skill is learned
    local isLearned = false
    for _, learnedId in ipairs(player.skills) do
        if learnedId == skillId then
            isLearned = true
            break
        end
    end
    if not isLearned then return false, "Skill not learned" end
    
    -- Check if it's active
    local skillData = self:GetSkillData(skillId)
    if skillData.type ~= "active" then
        return false, "Only actives"
    end
    
    return true, "OK"
end

function Skill:EquipSkill(player, skillId, slot)
    local canEquip, reason = self:CanEquipSkill(player, skillId, slot)
    if not canEquip then return false, reason end
    
    -- Slot must be 1 or 2
    if slot ~= 1 and slot ~= 2 then
        return false, "Invalid slot"
    end
    
    player.selectedSkills[slot] = skillId
    return true, "Skill equipped"
end

function Skill:UnequipSkill(player, slot)
    player.selectedSkills[slot] = nil
    return true, "Skill unequipped"
end

---------------------------------------------------------------------------
-- Skill execution in combat

function Skill:UseSkill(user, target, skillId, log, logIcons, Utils)
    local skillData = self:GetSkillData(skillId)
    if not skillData then return false, "Skill doesn't exist" end
    
    -- Check mana
    if user.mana < skillData.manaCost then
        Utils:AddLogEntry(log, logIcons, 0, 0, user.name.." has no mana!")
        return false, "No mana"
    end
    
    -- Consume mana
    user.mana = math.max(0, user.mana - skillData.manaCost)
    
    -- Calculate base damage
    local baseDamage = 0
    if skillData.damageType == "physical" then
        baseDamage = user.subStats.attack
    elseif skillData.damageType == "magical" then
        baseDamage = user.subStats.mAttack
    end
    
    local totalDamage = baseDamage * skillData.damageMultiplier
    
    -- Apply target defense
    if skillData.damageType == "physical" then
        totalDamage = math.max(1, totalDamage - target.subStats.defense)
    elseif skillData.damageType == "magical" then
        totalDamage = math.max(1, totalDamage - target.subStats.mDefense)
    end
    
    -- Check hit
    local hitChance = 75 + (user.subStats.hit - target.subStats.dodge)
    hitChance = math.max(10, math.min(95, hitChance))
    
    if math.random(1, 100) > hitChance then
        Utils:AddLogEntry(log, logIcons, 0, 0, user.name.." missed the attack!")
        return true, "Miss"
    end
    
    -- Check critical
    if math.random(1, 100) <= user.subStats.crit then
        totalDamage = totalDamage * 2
        Utils:AddLogEntry(log, logIcons, 1, 0, "Critical! "..math.floor(totalDamage).." damage!")
    else
        Utils:AddLogEntry(log, logIcons, 1, 0, user.name.." used "..skillData.name.."!")
    end
    
    -- Apply damage
    totalDamage = math.floor(totalDamage)
    target.health = math.max(0, target.health - totalDamage)
    
    Utils:AddLogEntry(log, logIcons, 1, 0, target.name.." takes "..totalDamage.." damage!")
    
    -- Apply debuff if exists
    if skillData.applyDebuff then
        target.debuffs = target.debuffs or {}
        if skillData.applyDebuff == "bleeding" then
            target.debuffs.bleeding = 2 -- 2 turns
            Utils:AddLogEntry(log, logIcons, 0, 0, target.name.." is bleeding!")
        elseif skillData.applyDebuff == "stun" then
            target.debuffs.stun = 1 -- 1 turn
            Utils:AddLogEntry(log, logIcons, 0, 0, target.name.." is stunned!")
        end
    end
    
    return true, "Skill executed"
end

---------------------------------------------------------------------------

return Skill