-- Chapters.lua - Chapter data and narrative structure ONLY
local Enemy = require("Enemy.lua")

local Chapters = {}

---------------------------------------------------------------------------
-- CHAPTER 0: "Awakening in Darkness"

Chapters.CHAPTER_0 = {
    id = 0,
    name = "Awakening",
    
    -- ==================== EVENTS ====================
    events = {
        -- Event 0: Intro
        [0] = {
            type = "dialogue",
            text = "You wake up in darkness... You're in sewers. You must escape.",
            nextEvent = 1
        },
        
        -- Event 1: First tutorial combat
        [1] = {
            type = "combat",
            enemyId = 1, -- Weak Wolf
            onVictory = 2,
            onDefeat = "game_over"
        },
        
        -- Event 2: First decision
        [2] = {
            type = "dialogue",
            text = "You defeated the wolf. You see two paths.",
            nextEvent = 3
        },
        
        [3] = {
            type = "decision",
            question = "What to do?",
            options = {
                {text = "Go forward", nextEvent = 4},
                {text = "Find exit", nextEvent = 10}
            }
        },
        
        -- Branch A: Go forward
        [4] = {
            type = "dialogue",
            text = "You advance carefully... You hear growling.",
            nextEvent = 5
        },
        
        [5] = {
            type = "combat",
            enemyId = 2, -- Normal Wolf
            onVictory = 15,
            onDefeat = "game_over"
        },
        
        -- Branch B: Find exit
        [10] = {
            type = "dialogue",
            text = "You find a room with supplies!",
            nextEvent = 11
        },
        
        [11] = {
            type = "reward",
            items = {},
            hunger = 20,
            text = "You eat something. Recover 20 hunger.",
            nextEvent = 12
        },
        
        [12] = {
            type = "dialogue",
            text = "You return to the main path.",
            nextEvent = 5 -- Converges with branch A
        },
        
        -- Event 15: Pre-boss
        [15] = {
            type = "dialogue",
            text = "A huge shadow appears... It's the alpha!",
            nextEvent = 16
        },
        
        [16] = {
            type = "combat",
            enemyId = 3, -- Alpha Wolf (mini-boss)
            onVictory = 20,
            onDefeat = "game_over"
        },
        
        -- Event 20: Post-boss final decision
        [20] = {
            type = "dialogue",
            text = "You defeated the alpha! You see stairs and a tunnel.",
            nextEvent = 21
        },
        
        [21] = {
            type = "decision",
            question = "Which way to take?",
            options = {
                {text = "Climb stairs", nextEvent = 30},
                {text = "Explore tunnel", nextEvent = 40}
            }
        },
        
        -- Ending A: City
        [30] = {
            type = "chapter_end",
            text = "You climb the stairs and reach a city.",
            nextChapter = 1,
            nextSubchapter = 0
        },
        
        -- Ending B: Dungeons
        [40] = {
            type = "chapter_end",
            text = "You delve into the dark tunnel...",
            nextChapter = 1,
            nextSubchapter = 1
        }
    }
}

---------------------------------------------------------------------------
-- Event Data Retrieval

function Chapters:GetEvent(chapter, eventId)
    if chapter == 0 then
        return self.CHAPTER_0.events[eventId]
    end
    return nil
end

---------------------------------------------------------------------------
-- Event Handlers (dispatch only, no logic)

function Chapters:ExecuteEvent(eventId, player, gameState, log, logIcons, Utils)
    local event = self:GetEvent(player.chapter, eventId)
    if not event then
        print("Error: Event "..eventId.." doesn't exist in chapter "..player.chapter)
        return
    end
    
    if event.type == "dialogue" then
        return self:HandleDialogue(event, player, gameState, log, logIcons, Utils)
        
    elseif event.type == "decision" then
        return self:HandleDecision(event, player, gameState, log, logIcons, Utils)
        
    elseif event.type == "combat" then
        return self:HandleCombat(event, player, gameState, log, logIcons, Utils)
        
    elseif event.type == "reward" then
        return self:HandleReward(event, player, gameState, log, logIcons, Utils)
        
    elseif event.type == "chapter_end" then
        return self:HandleChapterEnd(event, player, gameState, log, logIcons, Utils)
    end
end

function Chapters:HandleDialogue(event, player, gameState, log, logIcons, Utils)
    Utils:AddLogEntry(log, logIcons, 1, 0, event.text)
    
    gameState.waitingForInput = true
    gameState.nextEvent = event.nextEvent
    
    return {type = "dialogue", waitInput = true}
end

function Chapters:HandleDecision(event, player, gameState, log, logIcons, Utils)
    Utils:AddLogEntry(log, logIcons, 3, 0, event.question)
    
    gameState.currentDecision = event
    gameState.waitingForDecision = true
    
    return {type = "decision", options = event.options}
end

function Chapters:HandleCombat(event, player, gameState, log, logIcons, Utils)
    local enemy = Enemy:new(event.enemyId)
    
    Utils:AddLogEntry(log, logIcons, 0, 0, "A "..enemy.name.." appears!")
    
    gameState.inCombat = true
    gameState.currentEnemy = enemy
    gameState.combatVictoryEvent = event.onVictory
    gameState.combatDefeatEvent = event.onDefeat
    gameState.playerTurn = true
    
    return {type = "combat_start", enemy = enemy}
end

function Chapters:HandleReward(event, player, gameState, log, logIcons, Utils)
    -- Add items
    for _, itemName in ipairs(event.items or {}) do
        player:addItemToInventory(itemName, 1)
        Utils:AddLogEntry(log, logIcons, 1, 0, "You get: "..itemName)
    end
    
    -- Modify hunger
    if event.hunger then
        player.hunger = math.min(100, player.hunger + event.hunger)
    end
    
    -- Modify sleep
    if event.sleepyness then
        player.sleepyness = math.min(100, player.sleepyness + event.sleepyness)
    end
    
    Utils:AddLogEntry(log, logIcons, 1, 0, event.text)
    
    gameState.waitingForInput = true
    gameState.nextEvent = event.nextEvent
    
    return {type = "reward"}
end

function Chapters:HandleChapterEnd(event, player, gameState, log, logIcons, Utils)
    Utils:AddLogEntry(log, logIcons, 3, 0, event.text)
    Utils:AddLogEntry(log, logIcons, 3, 0, "End of Chapter "..player.chapter)
    
    player.chapter = event.nextChapter
    player.subChapter = event.nextSubchapter
    
    gameState.waitingForInput = true
    gameState.chapterComplete = true
    
    return {type = "chapter_end"}
end

---------------------------------------------------------------------------

return Chapters