-- Enemy.lua - Enemy system with AI
local BD = require("BD.lua")

local Enemy = {}

---------------------------------------------------------------------------
-- Constructor

function Enemy:new(enemyId)
    -- Find template in BD
    local template = nil
    for _, enemy in ipairs(BD.enemies) do
        if enemy.id == enemyId then
            template = enemy
            break
        end
    end
    
    if not template then
        print("Error: Enemy ID "..enemyId.." doesn't exist")
        return nil
    end
    
    local obj = {
        id = template.id,
        name = template.name,
        spriteRow = template.spriteRow,
        level = template.level,
        health = template.health,
        maxHealth = template.maxHealth,
        mana = template.mana,
        maxMana = template.maxMana,
        stats = {
            strength = template.stats.strength,
            agility = template.stats.agility,
            dexterity = template.stats.dexterity,
            intelligence = template.stats.intelligence,
            vitality = template.stats.vitality
        },
        subStats = {
            attack = 0,
            mAttack = 0,
            defense = 0,
            mDefense = 0,
            speed = 0,
            dodge = 0,
            hit = 0,
            crit = 0,
            healthRegen = 0,
            manaRegen = 0,
            hungerDecay = 0,
            sleepDecay = 0
        },
        expReward = template.expReward,
        goldReward = template.goldReward,
        itemDrops = template.itemDrops or {},
        aiPattern = template.aiPattern,
        debuffs = {},
        stunned = false
    }
    
    setmetatable(obj, self)
    self.__index = self
    
    -- Calculate substats
    obj:updateSubStats()
    
    return obj
end

---------------------------------------------------------------------------
-- Calculate substats (same as Player but without equipment)

function Enemy:updateSubStats()
    local str = self.stats.strength
    local agi = self.stats.agility
    local dex = self.stats.dexterity
    local int = self.stats.intelligence
    local vit = self.stats.vitality
    
    self.subStats = {
        attack = (str * 2),
        mAttack = (int * 2),
        defense = math.floor((vit * 1.5) + (str * 0.5)),
        mDefense = math.floor((vit * 1.5) + (int * 0.5)),
        speed = agi,
        dodge = math.min(80, math.floor(agi * 0.8)),
        hit = math.min(80, math.floor(dex * 0.8)),
        crit = math.min(25, math.floor(dex * 0.25)),
        healthRegen = math.floor(vit * 0.1),
        manaRegen = math.floor(int * 0.1),
        hungerDecay = 0,
        sleepDecay = 0
    }
end

---------------------------------------------------------------------------
-- AI System

function Enemy:DecideAction(player, log, logIcons, Utils)
    -- Check if stunned
    if self.debuffs.stun and self.debuffs.stun > 0 then
        Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." is stunned!")
        return {type = "skip"}
    end
    
    local healthPercent = self.health / self.maxHealth
    local playerHealthPercent = player.health / player.maxHealth
    
    if self.aiPattern == "basic_physical" then
        return self:BasicPhysicalAI(playerHealthPercent)
    elseif self.aiPattern == "balanced" then
        return self:BalancedAI(healthPercent, playerHealthPercent)
    elseif self.aiPattern == "smart_aggressive" then
        return self:SmartAggressiveAI(healthPercent, playerHealthPercent)
    else
        return {type = "attack", attackType = "physical"}
    end
end

function Enemy:BasicPhysicalAI(playerHealthPercent)
    -- Always physical attack
    return {type = "attack", attackType = "physical"}
end

function Enemy:BalancedAI(healthPercent, playerHealthPercent)
    -- If player is weak, strong attack
    if playerHealthPercent < 0.5 then
        return {type = "attack", attackType = "physical", power = 1.3}
    end
    
    -- 50% physical, 50% magical
    if math.random() < 0.5 then
        return {type = "attack", attackType = "physical"}
    else
        return {type = "attack", attackType = "magical"}
    end
end

function Enemy:SmartAggressiveAI(healthPercent, playerHealthPercent)
    -- If player very weak, finish him
    if playerHealthPercent < 0.3 then
        return {type = "attack", attackType = "physical", power = 1.5}
    end
    
    -- If player medium weak, constant pressure
    if playerHealthPercent < 0.6 then
        return {type = "attack", attackType = "physical", power = 1.2}
    end
    
    -- Smart alternation
    if math.random() < 0.6 then
        return {type = "attack", attackType = "physical"}
    else
        return {type = "attack", attackType = "magical"}
    end
end

---------------------------------------------------------------------------
-- Execute action

function Enemy:ExecuteAction(action, player, log, logIcons, Utils)
    if action.type == "skip" then
        return
    end
    
    if action.type == "attack" then
        self:Attack(player, action.attackType, action.power or 1.0, log, logIcons, Utils)
    end
end

function Enemy:Attack(target, attackType, powerMultiplier, log, logIcons, Utils)
    -- Calculate base damage
    local baseDamage = 0
    if attackType == "physical" then
        baseDamage = self.subStats.attack
    else
        baseDamage = self.subStats.mAttack
    end
    
    baseDamage = baseDamage * powerMultiplier
    
    -- Apply defense
    local totalDamage = 0
    if attackType == "physical" then
        totalDamage = math.max(1, baseDamage - target.subStats.defense)
    else
        totalDamage = math.max(1, baseDamage - target.subStats.mDefense)
    end
    
    -- Check hit
    local hitChance = 75 + (self.subStats.hit - target.subStats.dodge)
    hitChance = math.max(10, math.min(95, hitChance))
    
    if math.random(1, 100) > hitChance then
        Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." missed the attack!")
        return
    end
    
    -- Check critical
    if math.random(1, 100) <= self.subStats.crit then
        totalDamage = totalDamage * 2
        Utils:AddLogEntry(log, logIcons, 0, 0, "Enemy critical!")
    end
    
    -- Apply damage
    totalDamage = math.floor(totalDamage)
    target:minusHealth(totalDamage)
    
    local attackName = attackType == "physical" and "Bite" or "Magic roar"
    Utils:AddLogEntry(log, logIcons, 1, 0, self.name.." used "..attackName.."!")
    Utils:AddLogEntry(log, logIcons, 0, 0, target.name.." takes "..totalDamage.." damage!")
end

---------------------------------------------------------------------------
-- Update debuffs each turn

function Enemy:UpdateDebuffs(log, logIcons, Utils)
    -- Bleeding
    if self.debuffs.bleeding and self.debuffs.bleeding > 0 then
        local bleedDamage = math.floor(self.maxHealth * 0.05) -- 5% max HP
        self.health = math.max(0, self.health - bleedDamage)
        Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." loses "..bleedDamage.." from bleeding!")
        self.debuffs.bleeding = self.debuffs.bleeding - 1
    end
    
    -- Stun
    if self.debuffs.stun and self.debuffs.stun > 0 then
        self.debuffs.stun = self.debuffs.stun - 1
    end
end

---------------------------------------------------------------------------
-- Drop items on death

function Enemy:GetDrops()
    local drops = {}
    
    for _, drop in ipairs(self.itemDrops) do
        if math.random(1, 100) <= drop.chance then
            table.insert(drops, drop.name)
        end
    end
    
    return drops
end

---------------------------------------------------------------------------

return Enemy