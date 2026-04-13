-- CombatSystem.lua - Turn-based combat system
local Skill = require("Skill.lua")

local CombatSystem = {}

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
        
        -- Update enemy debuffs
        enemy:UpdateDebuffs(log, logIcons, Utils)
        
        if enemy.health <= 0 then
            self:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
            return
        end
        
        -- Enemy turn
        local enemyAction = enemy:DecideAction(player, log, logIcons, Utils)
        enemy:ExecuteAction(enemyAction, player, log, logIcons, Utils)
        
        if player.health <= 0 then
            self:HandleDefeat(player, gameState, log, logIcons, Utils)
            return
        end
    else
        -- Enemy attacks first
        local enemyAction = enemy:DecideAction(player, log, logIcons, Utils)
        enemy:ExecuteAction(enemyAction, player, log, logIcons, Utils)
        
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
        
        -- Update enemy debuffs
        enemy:UpdateDebuffs(log, logIcons, Utils)
        
        if enemy.health <= 0 then
            self:HandleVictory(player, enemy, gameState, log, logIcons, Utils)
            return
        end
    end
    
    -- Apply hunger/sleep decay
    player:ApplyHungerSleepDecay(log, logIcons, Utils)
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
    gameState.waitingForInput = true
    gameState.nextEvent = gameState.combatVictoryEvent
end

---------------------------------------------------------------------------
-- Combat Defeat

function CombatSystem:HandleDefeat(player, gameState, log, logIcons, Utils)
    Utils:AddLogEntry(log, logIcons, 0, 0, "You have been defeated...")
    
    gameState.inCombat = false
    gameState.gameOver = true
end

---------------------------------------------------------------------------

return CombatSystem