-- CombatSystem.lua - Turn-based combat system
local Skill = require("Skill.lua")

local CombatSystem = {}

---------------------------------------------------------------------------
-- HELPER FUNCTIONS

-- Check if table contains value
local function tableContains(tbl, value)
    if not tbl then return false end
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

---------------------------------------------------------------------------
-- STATUS EFFECTS DEFINITIONS

CombatSystem.StatusEffects = {
    -- BUFFS (Row 0)
    regen = {
        type = "buff",
        sprite = {0, 0},
        activeColor = {100, 255, 100},  -- Verde claro
        grayColor = {60, 60, 60},
        name = "Regen",
        description = "Recovers 8 HP per turn"
    },
    shield = {
        type = "buff",
        sprite = {1, 0},
        activeColor = {100, 200, 255},  -- Azul claro
        grayColor = {60, 60, 60},
        name = "Shield",
        description = "Reduces damage taken by 40%"
    },
    strength = {
        type = "buff",
        sprite = {2, 0},
        activeColor = {255, 100, 100},  -- Rojo claro
        grayColor = {60, 60, 60},
        name = "Strength",
        description = "Increases ATK by 40%"
    },
    haste = {
        type = "buff",
        sprite = {3, 0},
        activeColor = {255, 255, 100},  -- Amarillo
        grayColor = {60, 60, 60},
        name = "Haste",
        description = "Increases Dodge by 30% and Crit by 15%"
    },
    focus = {
        type = "buff",
        sprite = {4, 0},
        activeColor = {150, 220, 255},  -- Azul brillante
        grayColor = {60, 60, 60},
        name = "Focus",
        description = "100% accuracy and +30% Magic ATK"
    },
    berserk = {
        type = "buff",
        sprite = {5, 0},
        activeColor = {255, 50, 50},  -- Rojo intenso
        grayColor = {60, 60, 60},
        name = "Berserk",
        description = "ATK +60%, DEF -40%"
    },
    
    -- DEBUFFS (Row 1)
    bleeding = {
        type = "debuff",
        sprite = {0, 1},
        activeColor = {255, 0, 0},  -- Rojo
        grayColor = {60, 60, 60},
        name = "Bleeding",
        description = "Loses 5% max HP per turn"
    },
    poison = {
        type = "debuff",
        sprite = {1, 1},
        activeColor = {100, 255, 100},  -- Verde
        grayColor = {60, 60, 60},
        name = "Poison",
        description = "Loses 8 HP per turn"
    },
    burn = {
        type = "debuff",
        sprite = {2, 1},
        activeColor = {255, 165, 0},  -- Naranja
        grayColor = {60, 60, 60},
        name = "Burn",
        description = "Loses 12 HP per turn and -30% DEF"
    },
    freeze = {
        type = "debuff",
        sprite = {3, 1},
        activeColor = {100, 255, 255},  -- Cyan
        grayColor = {60, 60, 60},
        name = "Freeze",
        description = "Skips next turn and takes +40% damage"
    },
    paralyze = {
        type = "debuff",
        sprite = {4, 1},
        activeColor = {255, 255, 0},  -- Amarillo
        grayColor = {60, 60, 60},
        name = "Paralyze",
        description = "50% chance to skip turn"
    },
    confusion = {
        type = "debuff",
        sprite = {5, 1},
        activeColor = {200, 100, 255},  -- Púrpura
        grayColor = {60, 60, 60},
        name = "Confusion",
        description = "40% chance to hit self"
    }
}

---------------------------------------------------------------------------
-- STATUS EFFECTS FUNCTIONS

function CombatSystem:ApplyStatus(target, statusName, duration)
    -- Verificar que target existe
    if not target then 
        return false 
    end
    
    local statusData = self.StatusEffects[statusName]
    if not statusData then 
        return false 
    end
    
    -- Check immunity (solo si immunity existe y es una tabla)
    if target.immunity and type(target.immunity) == "table" and tableContains(target.immunity, statusName) then
        return false
    end
    
    -- Apply status (stacking adds turns)
    if statusData.type == "buff" then
        target.buffs = target.buffs or {}
        target.buffs[statusName] = (target.buffs[statusName] or 0) + duration
    else  -- debuff
        target.debuffs = target.debuffs or {}
        target.debuffs[statusName] = (target.debuffs[statusName] or 0) + duration
    end
    
    return true
end

function CombatSystem:RemoveStatus(target, statusName)
    if target.buffs and target.buffs[statusName] then
        target.buffs[statusName] = nil
    end
    if target.debuffs and target.debuffs[statusName] then
        target.debuffs[statusName] = nil
    end
end

function CombatSystem:ClearAllDebuffs(target)
    target.debuffs = {}
end

function CombatSystem:ClearAllBuffs(target)
    target.buffs = {}
end

---------------------------------------------------------------------------
-- Combat Turn Logic

function CombatSystem:ExecuteTurn(player, enemy, action, gameState, log, logIcons, Utils)
    if not gameState.inCombat then return end
    
    -- Calculate initiative
    local playerInitiative = player.subStats.speed + math.random(0, 10)
    local enemyInitiative = enemy.subStats.speed + math.random(0, 10)
    
    local playerFirst = playerInitiative >= enemyInitiative
    
    if playerFirst then
        -- Player turn
        self:ExecutePlayerAction(player, enemy, action, log, logIcons, Utils)
        
        if enemy.health <= 0 then
            self:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
            return
        end
        
        -- Update status effects
        player:UpdateBuffs(log, logIcons, Utils)
        player:UpdateDebuffs(log, logIcons, Utils)
        enemy:UpdateDebuffs(log, logIcons, Utils)
        enemy:UpdateBuffs(log, logIcons, Utils)
        
        if enemy.health <= 0 then
            self:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
            return
        end
        
        -- Enemy turn
        local canAct, reason = enemy:CanAct()
        if not canAct then
            Utils:AddLogEntry(log, logIcons, 0, 0, enemy.name.." is "..reason.." and can't act!")
        else
            local enemyAction = enemy:DecideAction(player, log, logIcons, Utils)
            enemy:ExecuteAction(enemyAction, player, log, logIcons, Utils)
        end
        
        if player.health <= 0 then
            self:HandleDefeat(player, gameState, log, logIcons, Utils)
            return
        end
    else
        -- Enemy attacks first
        local canAct, reason = enemy:CanAct()
        if not canAct then
            Utils:AddLogEntry(log, logIcons, 0, 0, enemy.name.." is "..reason.." and can't act!")
        else
            local enemyAction = enemy:DecideAction(player, log, logIcons, Utils)
            enemy:ExecuteAction(enemyAction, player, log, logIcons, Utils)
        end
        
        if player.health <= 0 then
            self:HandleDefeat(player, gameState, log, logIcons, Utils)
            return
        end
        
        -- Player turn
        self:ExecutePlayerAction(player, enemy, action, log, logIcons, Utils)
        
        if enemy.health <= 0 then
            self:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
            return
        end
        
        -- Update status effects
        player:UpdateBuffs(log, logIcons, Utils)
        player:UpdateDebuffs(log, logIcons, Utils)
        enemy:UpdateDebuffs(log, logIcons, Utils)
        enemy:UpdateBuffs(log, logIcons, Utils)
        
        if enemy.health <= 0 then
            self:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
            return
        end
    end
    
    -- Apply hunger/sleep decay
    player:ApplyHungerSleepDecay(log, logIcons, Utils)
    
    -- Reset player turn for next round
    gameState.playerTurn = true
end

---------------------------------------------------------------------------
-- Player Action Execution

function CombatSystem:ExecutePlayerAction(player, enemy, action, log, logIcons, Utils)
    if action.type == "skill" then
        Skill:UseSkill(player, enemy, action.skillId, log, logIcons, Utils)
    elseif action.type == "attack" then
        -- Basic physical attack
        local damage = math.max(1, player.subStats.attack - enemy.subStats.defense)
        enemy.health = math.max(0, enemy.health - damage)
        Utils:AddLogEntry(log, logIcons, 1, 0, player.name.." attacks!")
        Utils:AddLogEntry(log, logIcons, 1, 0, enemy.name.." takes "..damage.." damage!")
    elseif action.type == "item" then
        -- Item already used by player:useItem() before calling this
        Utils:AddLogEntry(log, logIcons, 1, 0, player.name.." used "..action.itemName.."!")
    end
end

---------------------------------------------------------------------------
-- Combat Victory

function CombatSystem:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
    Utils:AddLogEntry(log, logIcons, 3, 0, "Victory! You defeated "..enemy.name)
    
    -- Rewards
    player:addExp(enemy.expReward)
    player.gold = player.gold + enemy.goldReward
    
    Utils:AddLogEntry(log, logIcons, 1, 0, "You gained "..enemy.expReward.." EXP and "..enemy.goldReward.." gold")
    
    -- Item drops
    local drops = enemy:GetDrops()
    for _, itemName in ipairs(drops) do
        player:addItemToInventory(itemName, 1)
        Utils:AddLogEntry(log, logIcons, 1, 0, "You get: "..itemName)
    end
    
    -- Clear combat state
    gameState.inCombat = false
    gameState.currentEnemy = nil
    gameState.combatMenuActive = false
    gameState.playerTurn = true
    gdt.VideoChip2:Clear(color.black)
    gameState.waitingForInput = true
    gameState.nextEvent = gameState.combatVictoryEvent
end

---------------------------------------------------------------------------
-- Combat Defeat

function CombatSystem:HandleDefeat(player, gameState, log, logIcons, Utils)
    Utils:AddLogEntry(log, logIcons, 0, 0, "You have been defeated...")
    
    gameState.inCombat = false
    gameState.currentEnemy = nil
    gameState.combatMenuActive = false
    gdt.VideoChip2:Clear(color.black)
    gameState.gameOver = true
end

---------------------------------------------------------------------------

return CombatSystem