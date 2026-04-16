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
        immunity = template.immunity or {},        -- NEW: Status immunities
        initialBuffs = template.initialBuffs or {}, -- NEW: Start with buffs
        debuffs = {},
        buffs = {},
        stunned = false
    }
    
    setmetatable(obj, self)
    self.__index = self
    
    -- Calculate substats
    obj:updateSubStats()
    
    -- Apply initial buffs
    for _, buffName in ipairs(obj.initialBuffs) do
        obj.buffs[buffName] = 999  -- Permanent buffs
    end
    
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
    
    -- Calculate base stats
    local baseAttack = (str * 2)
    local baseMAttack = (int * 2)
    local baseDef = math.floor((vit * 1.5) + (str * 0.5))
    local baseMDef = math.floor((vit * 1.5) + (int * 0.5))
    local baseSpeed = agi
    local baseDodge = math.min(80, math.floor(agi * 0.8))
    local baseHit = math.min(80, math.floor(dex * 0.8))
    local baseCrit = math.min(25, math.floor(dex * 0.25))
    
    -- Apply BUFFS
    if self.buffs then
        -- Strength: +40% ATK
        if self.buffs.strength and self.buffs.strength > 0 then
            baseAttack = baseAttack * 1.4
        end
        
        -- Berserk: +60% ATK, -40% DEF
        if self.buffs.berserk and self.buffs.berserk > 0 then
            baseAttack = baseAttack * 1.6
            baseDef = baseDef * 0.6
        end
        
        -- Haste: +30% Dodge, +15% Crit
        if self.buffs.haste and self.buffs.haste > 0 then
            baseDodge = math.min(95, baseDodge * 1.3)
            baseCrit = math.min(50, baseCrit * 1.15)
        end
        
        -- Focus: +50% Hit, +30% mATK
        if self.buffs.focus and self.buffs.focus > 0 then
            baseHit = math.min(95, baseHit * 1.5)
            baseMAttack = baseMAttack * 1.3
        end
    end
    
    -- Apply DEBUFFS
    if self.debuffs then
        -- Burn: -30% DEF
        if self.debuffs.burn and self.debuffs.burn > 0 then
            baseDef = baseDef * 0.7
        end
    end
    
    self.subStats = {
        attack = baseAttack,
        mAttack = baseMAttack,
        defense = baseDef,
        mDefense = baseMDef,
        speed = baseSpeed,
        dodge = baseDodge,
        hit = baseHit,
        crit = baseCrit,
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
    
    -- Check Confusion FIRST
    if self.debuffs and self.debuffs.confusion and self.debuffs.confusion > 0 then
        if math.random(100) <= 40 then
            -- Hit self instead
            local selfDamage = math.floor(self.subStats.attack * 0.5)
            self.health = math.max(0, self.health - selfDamage)
            Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." is confused and hits itself for "..selfDamage.." damage!")
            return
        end
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
    
    -- Apply target buffs (Shield reduces damage)
    if target.buffs and target.buffs.shield and target.buffs.shield > 0 then
        totalDamage = totalDamage * 0.6  -- -40% damage
    end
    
    -- Apply target debuffs (Freeze increases damage taken)
    if target.debuffs and target.debuffs.freeze and target.debuffs.freeze > 0 then
        totalDamage = totalDamage * 1.4  -- +40% damage
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
    if not self.debuffs then self.debuffs = {} return end
    
    -- Bleeding
    if self.debuffs.bleeding and self.debuffs.bleeding > 0 then
        local bleedDamage = math.floor(self.maxHealth * 0.05)
        self.health = math.max(0, self.health - bleedDamage)
        Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." loses "..bleedDamage.." from bleeding!")
        self.debuffs.bleeding = self.debuffs.bleeding - 1
    end
    
    -- Poison
    if self.debuffs.poison and self.debuffs.poison > 0 then
        self.health = math.max(0, self.health - 8)
        Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." takes 8 poison damage!")
        self.debuffs.poison = self.debuffs.poison - 1
    end
    
    -- Burn
    if self.debuffs.burn and self.debuffs.burn > 0 then
        self.health = math.max(0, self.health - 12)
        Utils:AddLogEntry(log, logIcons, 0, 0, self.name.." burns for 12 damage!")
        self.debuffs.burn = self.debuffs.burn - 1
    end
    
    -- Freeze (just decrement)
    if self.debuffs.freeze and self.debuffs.freeze > 0 then
        self.debuffs.freeze = self.debuffs.freeze - 1
    end
    
    -- Paralyze (just decrement)
    if self.debuffs.paralyze and self.debuffs.paralyze > 0 then
        self.debuffs.paralyze = self.debuffs.paralyze - 1
    end
    
    -- Confusion (just decrement)
    if self.debuffs.confusion and self.debuffs.confusion > 0 then
        self.debuffs.confusion = self.debuffs.confusion - 1
    end
    
    -- Stun (legacy, now replaced by freeze/paralyze)
    if self.debuffs.stun and self.debuffs.stun > 0 then
        self.debuffs.stun = self.debuffs.stun - 1
    end
end

function Enemy:UpdateBuffs(log, logIcons, Utils)
    if not self.buffs then self.buffs = {} return end
    
    -- Regen
    if self.buffs.regen and self.buffs.regen > 0 then
        local healAmount = 8
        self.health = math.min(self.maxHealth, self.health + healAmount)
        Utils:AddLogEntry(log, logIcons, 3, 0, self.name.." regenerates "..healAmount.." HP!")
        self.buffs.regen = self.buffs.regen - 1
    end
    
    -- Other buffs just decrement
    for buffName, turnsLeft in pairs(self.buffs) do
        if buffName ~= "regen" and turnsLeft > 0 then
            self.buffs[buffName] = turnsLeft - 1
        end
    end
end

function Enemy:CanAct()
    -- Freeze blocks action
    if self.debuffs and self.debuffs.freeze and self.debuffs.freeze > 0 then
        return false, "frozen"
    end
    
    -- Paralyze has 50% chance to block
    if self.debuffs and self.debuffs.paralyze and self.debuffs.paralyze > 0 then
        if math.random(100) <= 50 then
            return false, "paralyzed"
        end
    end
    
    -- Stun (legacy)
    if self.debuffs and self.debuffs.stun and self.debuffs.stun > 0 then
        return false, "stunned"
    end
    
    return true, nil
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