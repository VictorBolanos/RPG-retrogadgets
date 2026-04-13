-- Imports
local Utils = require("Utils.lua")
local Player = require("Player.lua")
local Skill = require("Skill.lua")
local Enemy = require("Enemy.lua")
local Chapters = require("Chapters.lua")
local CombatSystem = require("CombatSystem.lua")

-- Instancias de clases
Utils = Utils:new()

-- Chip inits
local rom = gdt.ROM
local audio = gdt.AudioChip0
local cpu = gdt.CPU0
local flashMemory = gdt.FlashMemory0
local video1, video2, video3, video4 = gdt.VideoChip0, gdt.VideoChip1, gdt.VideoChip2, gdt.VideoChip3

-- Output
local skillLeds = {gdt.Led8, gdt.Led9}

-- Input
local ligthSwitch = gdt.Switch0
local screenButtonSkills = {gdt.ScreenButton0, gdt.ScreenButton1}
local buttonA, buttonS, buttonZ, buttonX = gdt.LedButton5, gdt.LedButton2, gdt.LedButton0, gdt.LedButton1
local buttonLogUp, buttonLogDown = gdt.LedButton3, gdt.LedButton4
local dPad = gdt.DPad0
local buttonSelect, buttonStart = gdt.LedButton14, gdt.LedButton15

local buttonU, buttonI, buttonO, buttonP = gdt.LedButton7, gdt.LedButton8, gdt.LedButton9, gdt.LedButton10

-- Sprites
local gameFont = rom.User.SpriteSheets["gameFont.png"]
local gameFontAlter1 = rom.User.SpriteSheets["gameFontAlter1.png"]
local gameFontAlter1Shadow = rom.User.SpriteSheets["gameFontAlter1Shadow.png"]
local enemySpr = rom.User.SpriteSheets["enemySprites.png"]
local itemSpr = rom.User.SpriteSheets["itemSprites.png"]
local skillSpr = rom.User.SpriteSheets["skillSpr.png"]
local guiIcons = rom.User.SpriteSheets["guiIcons.png"]
local logIcons = rom.User.SpriteSheets["logIcons.png"]
local guiButtons = rom.User.SpriteSheets["guiButtons.png"]
local guiSelectors = rom.User.SpriteSheets["guiSelectors.png"]
local guiOptionSelector = rom.User.SpriteSheets["guiOptionSelector.png"]
local guiInventory = rom.User.SpriteSheets["guiInventory.png"]
local guiSkillList = rom.User.SpriteSheets["guiSkillList.png"]
local guiPlayerSheet = rom.User.SpriteSheets["guiPlayerSheet.png"]
local guiPlayerConstants = rom.User.SpriteSheets["guiPlayerConstants.png"]
local guiExtraStats = rom.User.SpriteSheets["guiExtraStats.png"]
local bgsSpr = {rom.User.SpriteSheets["sewersBG.png"]}
local debugSpr = rom.User.SpriteSheets["debugSpr.png"]

-- Game locals
local inventorySlotDiff, needsUpdate, logScrollOffset = 14, true, 0
local player, log = nil, {}

-- Game state para capítulos y combate
local gameState = {
    currentEvent = 0,
    inCombat = false,
    currentEnemy = nil,
    playerTurn = true,
    waitingForInput = false,
    waitingForDecision = false,
    currentDecision = nil,
    nextEvent = nil,
    combatVictoryEvent = nil,
    combatDefeatEvent = nil,
    chapterComplete = false,
    gameOver = false,
    enemyAnimFrame = 0,
    enemyAnimTimer = 0,
    combatMenuActive = false,
    combatOptions = {},
    selectedCombatOption = 1
}

-- Skill tree locals
local isSkillTreeOpen = false
local selectedSkillId = nil
local skillTreeScrollOffset = 0
local selectedDecisionIndex = 1

-- Inventory locals
local isInventoryOpen, isPlayerSheetOpen = false, false
local selectedItemIndex, confirmedItemIndex = vec2(1, 1), nil
local selectedEquipmentIndex, confirmedEquipmentIndex = vec2(1, 1), nil
local selectedStatIndex = nil
local isSelectingEquipment = false
local inventoryFilterType = nil
local inventoryFilterSubType = nil
local isFilteredInventoryOpen = false
local isEquipmentMode = false
local showSubStatsSelector = false
local isSubStatsOpen = false
local isOptionMenuOpen = false
local currentOptions = {}
local selectedOptionIndex = 1
local isRecipesMenuOpen = false
local selectedItemForRecipes = nil
local selectedRecipeIndex = 1
local recipeScrollOffset = 0  -- Nuevo: offset para el scroll de recetas

---------------------------------------------------------------------------

-- debugies

function DrawBackground()
    -- Get current phase and background
    local phase = Chapters:GetCurrentPhase(player.chapter, gameState.currentEvent)
    
    if phase and phase.background then
        local bgSprite = bgsSpr[1] -- sewersBG for now
        if bgSprite then
            video1:DrawSprite(vec2(0, 0), bgSprite, 0, 0, color.white, color.clear)
        end
    end
end

function Testing()
	
	-- 	Utils:AddLogEntry(log, logIcons, 2, 0, "You get conciusness inside a dark sewer. you must scape trought the ladder or explore another exit")
	-- 
	-- 	Utils:AddLogEntry(log, logIcons, 3, 0, "What do you want to do?")
	-- 	
	-- 	Utils:AddLogEntry(log, logIcons, 0, 0, "You noticed a suspicious shape far in the dark...")
	-- 	
	-- 	Utils:AddLogEntry(log, logIcons, 3, 0, "What do you want to do?")
	
	



	--video1:DrawSprite(vec2(0,0), debugSpr, 0, 0, color.white, color.clear)
	
	--video1:DrawSprite(vec2(0,0), bgsSpr[1], 0, 0, color.white, color.clear)
	
	--video1:DrawSprite(vec2(0,0), guiInventory, 0, 0, color.white, color.clear)
	
	--video1:DrawSprite(vec2(0,0), guiPlayerSheet, 0, 0, color.white, color.clear)

    --(chapter, subChapter, gold, name, level, exp, expToNextLevel, points, hunger, sleepyness, health, maxHealth, mana, maxMana, stats, equipment, inventory, skills, selectedSkills)
    player = Player:new(0, 0, 0, "SirBolas", 1, 0, 10, 10, 50, 50, 10, 10, 10, 10, {1,1,1,1,1}, {}, {}, {}, {})

    player:addItemToInventory("Knife", 1)
    player:addItemToInventory("Axe", 1)

    player:addItemToInventory("Leather cap", 1)
    player:addItemToInventory("Leather shirt", 1)
    player:addItemToInventory("Leather boots", 1)

    player:addItemToInventory("Health Potion", 1)
    player:addItemToInventory("Sausage whipping", 2)
    player:addItemToInventory("Chestplate", 1)
    player:addItemToInventory("Iron Chestplate", 1)
    player:addItemToInventory("Iron boots", 1)
    
    player:addItemToInventory("Emerald pendant", 1)
    player:addItemToInventory("Ruby necklance", 1)

    player:addItemToInventory("Silver ingot", 8)
    player:addItemToInventory("Emerald", 1)
    player:addItemToInventory("Sapphire", 3)
    player:addItemToInventory("Amethyst", 6)
    player:addItemToInventory("Topaz", 6)
    player:addItemToInventory("Diamond", 1)
		
    --player:addItemToInventory("Red herb", 1)
    --player:addItemToInventory("Blue herb", 1)
    --player:addItemToInventory("Green herb", 1)
    --player:addItemToInventory("Yellow herb", 1)

    -- StartChapter0 is now called from Init(), not here

end


function TestingUpdate()
	
	if buttonU.ButtonDown then
		player:addExp(250)
		
	end
	
	if buttonI.ButtonDown then
		player:minusHealth(1)
		
	end
	
	if buttonO.ButtonDown then
		player:plusHealth(1)
		
	end
	
	if buttonP.ButtonDown then
        print("Player recipes:")
		for recipe in player.recipes do
            print(recipe)
        end
		
		
	end
	
end


---------------------------------------------------------------------------

-- functions

function Init()
	
	-- Start Chapter 0 automatically
	StartChapter0()
	
	sleep(0.2)

end

function LogController()
    local totalLogHeight = Utils:CalculateTotalLogHeight(log)
    local maxScrollUp = totalLogHeight - 32

    -- Ajustar desplazamiento según el botón presionado
    if buttonLogDown.ButtonState and logScrollOffset > 0 then logScrollOffset = logScrollOffset - 1 end
    if buttonLogUp.ButtonState and logScrollOffset < maxScrollUp then logScrollOffset = logScrollOffset + 1 end

    -- Imprimir los logs con el desplazamiento actual
    Utils:PrintLogEntries(log, video2, vec2(0, 0), gameFont, logScrollOffset)
end

---------------------------------------------------------------------------------------
-- Handle buttons and toggle states

function ToggleInventory()
    -- Don't allow opening inventory during combat (it opens via combat menu only)
    if gameState.inCombat then return end
    
    if buttonA.ButtonDown then
        -- **Si el inventario filtrado estaba abierto, cerrarlo antes de abrir el normal**
        if isFilteredInventoryOpen then
            isFilteredInventoryOpen = false
            inventoryFilterType, inventoryFilterSubType = nil, nil
        end

        -- **Abrir o cerrar el inventario normal**
        isInventoryOpen = not isInventoryOpen
        showSubStatsSelector = false -- **Cerrar el selector de subestadísticas**

        -- **Resetear la posición de selección en inventario normal**
        if isInventoryOpen then
            selectedItemIndex = vec2(1, 1) -- **Siempre empezar en la primera posición**
            confirmedItemIndex = nil -- **Eliminar marcador de selección anterior**
            isPlayerSheetOpen = false -- **Asegurar que se cierre el equipamiento**
            Utils:PrintInventory(player, nil, nil, selectedItemIndex, confirmedItemIndex)
        end
    end
end


function TogglePlayerSheet()
    if buttonS.ButtonDown then
        if isSubStatsOpen then
            isSubStatsOpen = false
        end
        isPlayerSheetOpen = not isPlayerSheetOpen
        selectedStatIndex = nil
        if isPlayerSheetOpen then
            isInventoryOpen = false
            selectedEquipmentIndex = "lHand"
            
            -- In combat, player sheet is READ-ONLY
            if gameState.inCombat then
                gameState.combatPlayerSheetReadOnly = true
            end
        else
            gameState.combatPlayerSheetReadOnly = false
        end
    end
end


function ShowRecipesMenu()
    if isRecipesMenuOpen then
        Utils:PrintRecipes(player, nil, selectedItemForRecipes)
    end
end

---------------------------------------------------------------------------------------
-- **Función para obtener el ítem confirmado**


local function GetConfirmedItem()
    if not confirmedItemIndex then return nil end
    
    print("Confirmed Index:", confirmedItemIndex.x, confirmedItemIndex.y)
    
    local items = {}
    for name, qty in pairs(player.inventory) do
        local data = Utils:GetItemData(name)
        if data then 
            print("Item in inventory:", name)
            table.insert(items, {name = name, quantity = qty, data = data}) 
        end
    end
    
    -- Ordenar igual que en PrintInventory
    table.sort(items, function(a, b)
        return (a.data.spr[2] * 10 + a.data.spr[1]) < (b.data.spr[2] * 10 + b.data.spr[1])
    end)
    
    local index = (confirmedItemIndex.y - 1) * 5 + (confirmedItemIndex.x - 1) + 1
    print("Total items:", #items, "Selected index:", index)
    
    if items[index] then
        print("Selected item:", items[index].name)
    else
        print("No item found at index", index)
    end
    
    return items[index]
end

-----------------------------------------------------------------------------------------------
-- **Función para manejar el botón Z**

function HandleButtonZ()
    if not buttonZ.ButtonDown then return end

    -- 1. Si el menú de opciones está abierto, manejar selección
    if isOptionMenuOpen then
        HandleOptionSelection()
        return
    end

    -- 2. Si estamos en el menú de recetas, ejecutar la receta seleccionada
    if isRecipesMenuOpen then
        -- Obtener las recetas filtradas actuales
        local filteredRecipes = {}
        if selectedItemForRecipes then
            for _, recipe in ipairs(player.recipes) do
                local ingredients = Utils:ParseIngredients(recipe.ingredients)
                for _, ing in ipairs(ingredients) do
                    if ing.itemName == selectedItemForRecipes then
                        table.insert(filteredRecipes, recipe)
                        break
                    end
                end
            end
        else
            filteredRecipes = player.recipes
        end

        -- Ejecutar la receta seleccionada
        if filteredRecipes[selectedRecipeIndex] then
            local success, message = player:executeRecipe(filteredRecipes[selectedRecipeIndex])
            if success then
                -- Cerrar menú de recetas y volver al inventario
                isRecipesMenuOpen = false
                selectedItemForRecipes = nil
                selectedRecipeIndex = 1
                recipeScrollOffset = 0
                
                -- Abrir inventario y actualizar visualización
                isInventoryOpen = true
                selectedItemIndex = vec2(1, 1)
                confirmedItemIndex = nil
                Utils:PrintInventory(player, nil, nil, selectedItemIndex, nil)
            else
                -- Mostrar mensaje de error
                print(message)
                -- Si el error es por inventario lleno, volver al inventario
                if message:find("Inventario lleno") then
                    isRecipesMenuOpen = false
                    selectedItemForRecipes = nil
                    selectedRecipeIndex = 1
                    recipeScrollOffset = 0
                    
                    -- Abrir inventario y actualizar visualización
                    isInventoryOpen = true
                    selectedItemIndex = vec2(1, 1)
                    confirmedItemIndex = nil
                    Utils:PrintInventory(player, nil, nil, selectedItemIndex, nil)
                end
            end
        end
        return
    end

    -- 3. Si estamos en inventario y no hay ítem confirmado
    if isInventoryOpen and not confirmedItemIndex then
        confirmedItemIndex = vec2(selectedItemIndex.x, selectedItemIndex.y)
        local item = GetConfirmedItem()
        if item then
            currentOptions = Utils:GetItemOptions(item.data)
            selectedOptionIndex = 1
            isOptionMenuOpen = true
            Utils:ShowOptions(video3, currentOptions, selectedOptionIndex)
        end
        return
    end

    -- Resto de lógica original...
    if isSubStatsOpen then return end
    
    if showSubStatsSelector then
        isSubStatsOpen, isPlayerSheetOpen = true, false
        return
    end
    
    if selectedStatIndex and isPlayerSheetOpen then
        handleStatUpgrade()
    elseif isFilteredInventoryOpen then
        handleFilteredInventorySelection()
    elseif isPlayerSheetOpen and not selectedStatIndex then
        -- Don't allow equipping during combat (read-only mode)
        if not gameState.combatPlayerSheetReadOnly then
            openFilteredInventoryForEquipment()
        end
    end
end


-- Funciones auxiliares
function handleStatUpgrade()
    if player.points > 0 and player.baseStats[selectedStatIndex] < 99 then
        player:plusStat(selectedStatIndex, 1)
        player:minusPoints(1)
        if player.points == 0 then
            selectedStatIndex, selectedEquipmentIndex = nil, "lHand"
        end
    end
end

function handleFilteredInventorySelection()
    local filteredItems = buildFilteredItemsList()
    local selectedItem = getSelectedFilteredItem(filteredItems)
    
    if selectedItem then
        processEquipmentSelection(selectedItem)
    end
end

function buildFilteredItemsList()
    local items = {}
    if player.equipment[selectedEquipmentIndex] then
        table.insert(items, {
            name = "UNEQUIP",
            data = {
                type = "unequip",
                spr = {6, 0},
                effectTags = {"Desequipar objeto actual"},
                description = "Remueve el objeto equipado actualmente"
            }
        })
    end
    
    for itemName, _ in pairs(player.inventory) do
        local itemData = Utils:GetItemData(itemName)
        if itemData and itemData.type == inventoryFilterType and itemData.subType == inventoryFilterSubType then
            table.insert(items, {name = itemName, data = itemData})
        end
    end
    
    return items
end

function getSelectedFilteredItem(items)
    local index = (selectedItemIndex.y - 1) * 5 + (selectedItemIndex.x - 1) + 1
    return items[index]
end

function processEquipmentSelection(item)
    if item.data.type == "unequip" then
        player:unequipItem(selectedEquipmentIndex)
    else
        if player.equipment[selectedEquipmentIndex] then
            player:unequipItem(selectedEquipmentIndex)
        end
        player:equipItem(item.name, selectedEquipmentIndex)
    end
    
    isFilteredInventoryOpen = false
    inventoryFilterType, inventoryFilterSubType = nil, nil
    isPlayerSheetOpen, selectedItemIndex = true, vec2(1, 1)
end

function openFilteredInventoryForEquipment()
    local equipData = player.equipment[selectedEquipmentIndex] and 
                     Utils:GetItemData(player.equipment[selectedEquipmentIndex])
    
    local defaultEquipment = {
        lHand = {type = "weapon", subType = "oneHanded"},
        head = {type = "armor", subType = "head"},
        rHand = {type = "weapon", subType = "oneHanded"},
        accesory1 = {type = "armor", subType = "accesory"},
        body = {type = "armor", subType = "body"},
        accesory2 = {type = "armor", subType = "accesory"},
        feet = {type = "armor", subType = "feet"}
    }
    
    inventoryFilterType = equipData and equipData.type or defaultEquipment[selectedEquipmentIndex].type
    inventoryFilterSubType = equipData and equipData.subType or defaultEquipment[selectedEquipmentIndex].subType
    
    isFilteredInventoryOpen, isInventoryOpen = true, false
    isPlayerSheetOpen, selectedItemIndex = false, vec2(1, 1)
end

--------------------------------------------------------------------------------------
-- **Función para manejar el botón X**

function HandleButtonX()
    if buttonX.ButtonDown then
        if isRecipesMenuOpen then
            isRecipesMenuOpen = false
            selectedItemForRecipes = nil
            selectedRecipeIndex = 1
            recipeScrollOffset = 0  -- Resetear el scroll al cerrar el menú
            
            -- Abrir inventario y actualizar visualización
            isInventoryOpen = true
            selectedItemIndex = vec2(1, 1)
            confirmedItemIndex = nil
            Utils:PrintInventory(player, nil, nil, selectedItemIndex, nil)
        elseif isOptionMenuOpen then
            isOptionMenuOpen = false
            confirmedItemIndex = nil
            video3:Clear(color.black)
        elseif isSubStatsOpen then
            isSubStatsOpen = false
            isPlayerSheetOpen = true
        elseif isFilteredInventoryOpen then
            isFilteredInventoryOpen = false
            inventoryFilterType, inventoryFilterSubType = nil, nil
            isPlayerSheetOpen = true
        elseif isInventoryOpen then
            confirmedItemIndex = nil
        end
    end
end

--------------------------------------------------------------------------------------
-- Events

--------------------------------------------------------------------------------------
-- **Función para manejar el evento del D-Pad**

function eventChannel1(sender, event)
    if event.X == 0 and event.Y == 0 then return end  -- No hay movimiento

    if isRecipesMenuOpen then
        -- Obtener las recetas filtradas actuales
        local filteredRecipes = {}
        if selectedItemForRecipes then
            for _, recipe in ipairs(player.recipes) do
                local ingredients = Utils:ParseIngredients(recipe.ingredients)
                for _, ing in ipairs(ingredients) do
                    if ing.itemName == selectedItemForRecipes then
                        table.insert(filteredRecipes, recipe)
                        break
                    end
                end
            end
        else
            filteredRecipes = player.recipes
        end

        -- Calcular el máximo offset posible
        local maxVisibleRecipes = 3  -- 51 píxeles ÷ 15 píxeles por receta
        local maxScrollOffset = math.max(0, (#filteredRecipes - maxVisibleRecipes) * 15)

        -- Navegación en el menú de recetas
        if event.Y < 0 then -- Abajo
            if selectedRecipeIndex < #filteredRecipes then
                selectedRecipeIndex = selectedRecipeIndex + 1
                -- Ajustar el scroll si la receta seleccionada está fuera de la vista
                if selectedRecipeIndex * 15 - recipeScrollOffset > 51 then
                    recipeScrollOffset = math.min(maxScrollOffset, (selectedRecipeIndex - maxVisibleRecipes) * 15)
                end
            end
        elseif event.Y > 0 then -- Arriba
            if selectedRecipeIndex > 1 then
                selectedRecipeIndex = selectedRecipeIndex - 1
                -- Ajustar el scroll si la receta seleccionada está fuera de la vista
                if selectedRecipeIndex * 15 - recipeScrollOffset < 2 then
                    recipeScrollOffset = math.max(0, (selectedRecipeIndex - 1) * 15)
                end
            end
        end
        Utils:PrintRecipes(player, nil, selectedItemForRecipes, selectedRecipeIndex, recipeScrollOffset)
        return
    elseif isOptionMenuOpen then
        if event.Y < 0 then -- Abajo
            selectedOptionIndex = math.min(selectedOptionIndex + 1, #currentOptions)
        elseif event.Y > 0 then -- Arriba
            selectedOptionIndex = math.max(selectedOptionIndex - 1, 1)
        end
        Utils:ShowOptions(video3, currentOptions, selectedOptionIndex)
        return
    elseif gameState.waitingForDecision and gameState.currentDecision and not isInventoryOpen and not isFilteredInventoryOpen and not isPlayerSheetOpen and not isSkillTreeOpen then
        -- Handle decision navigation (only if no menus open)
        local options = gameState.currentDecision.options
        if event.Y < 0 then -- Abajo
            selectedDecisionIndex = math.min(selectedDecisionIndex + 1, #options)
            print("DEBUG: DPad Down -> selectedDecisionIndex = " .. selectedDecisionIndex)
        elseif event.Y > 0 then -- Arriba
            selectedDecisionIndex = math.max(selectedDecisionIndex - 1, 1)
            print("DEBUG: DPad Up -> selectedDecisionIndex = " .. selectedDecisionIndex)
        end
        return
    elseif gameState.combatMenuActive and not isInventoryOpen and not isFilteredInventoryOpen and not isPlayerSheetOpen then
        -- Handle combat menu navigation (only if no menus open)
        if event.Y < 0 then -- Abajo
            gameState.selectedCombatOption = math.min(gameState.selectedCombatOption + 1, #gameState.combatOptions)
        elseif event.Y > 0 then -- Arriba
            gameState.selectedCombatOption = math.max(gameState.selectedCombatOption - 1, 1)
        end
        return
    end

    -- Configuración inicial
    local maxCols = 5
    local totalItems = countInventoryItems()
    local maxAccessibleRow = math.min(4, math.ceil(totalItems / maxCols))

    -- Navegación principal
    if isPlayerSheetOpen and not isFilteredInventoryOpen then
        handlePlayerSheetNavigation(event)
    elseif isInventoryOpen or isFilteredInventoryOpen then
        handleInventoryNavigation(event, totalItems, maxAccessibleRow, maxCols)
    end
end

-- Funciones auxiliares
function countInventoryItems()
    if isFilteredInventoryOpen then
        local count = player.equipment[selectedEquipmentIndex] and 1 or 0
        for itemName, _ in pairs(player.inventory) do
            local itemData = Utils:GetItemData(itemName)
            if itemData and itemData.type == inventoryFilterType and itemData.subType == inventoryFilterSubType then
                count = count + 1
            end
        end
        return count
    else
        local count = 0
        for _ in pairs(player.inventory) do count = count + 1 end
        return count
    end
end

function handlePlayerSheetNavigation(event)
    local rowMap = { {"lHand", "head", "rHand"}, {"accesory1", "body"}, {"accesory2", "feet"} }
    local statList = { "strength", "agility", "dexterity", "intelligence", "vitality" }

    -- Manejo de selector de stats
    if selectedStatIndex and event.X > 0 then
        showSubStatsSelector, selectedStatIndex = true, nil
        return
    elseif showSubStatsSelector and event.X < 0 then
        showSubStatsSelector, selectedStatIndex = false, "vitality"
        return
    end

    -- Navegación entre stats
    if selectedStatIndex then
        navigateStats(event, statList)
        return
    end

    -- Navegación entre equipamiento
    navigateEquipment(event, rowMap)
end

function navigateStats(event, statList)
    if player.points <= 0 then
        selectedStatIndex, selectedEquipmentIndex = nil, "lHand"
        return
    end

    local index = table.find(statList, selectedStatIndex)
    if not index then return end

    if event.Y < 0 and index < #statList then
        selectedStatIndex = statList[index + 1]
    elseif event.Y > 0 and index > 1 then
        selectedStatIndex = statList[index - 1]
    elseif event.X < 0 then
        selectedStatIndex, selectedEquipmentIndex = nil, "lHand"
    end
end

function navigateEquipment(event, rowMap)
    local currentRow, currentCol = findCurrentEquipmentPosition(rowMap)
    if not currentRow or not currentCol then return end

    -- Movimiento horizontal
    if event.X ~= 0 then
        handleHorizontalMovement(event, rowMap, currentRow, currentCol)
        return
    end

    -- Movimiento vertical
    if event.Y ~= 0 then
        handleVerticalMovement(event, rowMap, currentRow, currentCol)
    end
end

function findCurrentEquipmentPosition(rowMap)
    for rowIdx, row in ipairs(rowMap) do
        for colIdx, item in ipairs(row) do
            if item == selectedEquipmentIndex then
                return rowIdx, colIdx
            end
        end
    end
    return nil, nil
end

function handleHorizontalMovement(event, rowMap, currentRow, currentCol)
    if event.X < 0 and currentCol > 1 then
        selectedEquipmentIndex = rowMap[currentRow][currentCol - 1]
    elseif event.X > 0 and currentCol < #rowMap[currentRow] then
        selectedEquipmentIndex = rowMap[currentRow][currentCol + 1]
    elseif event.X > 0 then
        handleRightEdgeMovement()
    end
end

function handleRightEdgeMovement()
    if player.points > 0 then
        selectedEquipmentIndex, selectedStatIndex = nil, "strength"
    else
        showSubStatsSelector, selectedEquipmentIndex = true, nil
    end
end

function handleVerticalMovement(event, rowMap, currentRow, currentCol)
    local newRow = currentRow + (event.Y < 0 and 1 or -1)
    if newRow < 1 or newRow > #rowMap then return end

    if currentCol == 1 and selectedEquipmentIndex:find("accesory") then
        selectedEquipmentIndex = rowMap[newRow][1]
    elseif currentCol == 2 and (selectedEquipmentIndex == "body" or selectedEquipmentIndex == "feet") then
        selectedEquipmentIndex = rowMap[newRow][2]
    elseif currentRow == 1 then
        local targetCol = math.min(currentCol, #rowMap[newRow])
        selectedEquipmentIndex = rowMap[newRow][targetCol]
    end
end

function handleInventoryNavigation(event, totalItems, maxAccessibleRow, maxCols)
    if confirmedItemIndex then return end

    local newX, newY = selectedItemIndex.x, selectedItemIndex.y
    
    -- Convertir posición actual a índice absoluto (1-20)
    local currentAbsolutePos = (newY - 1) * maxCols + newX
    
    -- Calcular nueva posición absoluta basada en el movimiento
    local newAbsolutePos = currentAbsolutePos
    if event.X < 0 then
        newAbsolutePos = currentAbsolutePos - 1
    elseif event.X > 0 then
        newAbsolutePos = currentAbsolutePos + 1
    elseif event.Y < 0 then
        newAbsolutePos = currentAbsolutePos + maxCols
    elseif event.Y > 0 then
        newAbsolutePos = currentAbsolutePos - maxCols
    end
    
    -- Validar que la nueva posición absoluta está dentro de los límites
    if newAbsolutePos >= 1 and newAbsolutePos <= totalItems then
        -- Convertir posición absoluta de vuelta a coordenadas (x,y)
        newY = math.ceil(newAbsolutePos / maxCols)
        newX = ((newAbsolutePos - 1) % maxCols) + 1
        
        -- Actualizar la posición del cursor
        selectedItemIndex = vec2(newX, newY)
    end
end

--------------------------------------------------------------------------------------
-- Options system

local function ResetSelection()
    isOptionMenuOpen = false
    confirmedItemIndex = nil
    selectedItemIndex = vec2(1, 1)  -- Resetear a posición inicial
    video3:Clear(color.black)
    
    -- Redibujar inventario si está abierto
    if isInventoryOpen then
        Utils:PrintInventory(player, nil, nil, selectedItemIndex, nil)
    end
end


local function GetAppropriateSlot(itemData)
    if not itemData then return "lHand" end  -- Seguridad
    
    if itemData.type == "weapon" then
        if not player.equipment.lHand then return "lHand" end
        if not player.equipment.rHand then return "rHand" end
        return "lHand" -- Default
    elseif itemData.type == "armor" then
        if itemData.subType == "head" then return "head" end
        if itemData.subType == "body" then return "body" end
        if itemData.subType == "feet" then return "feet" end
        if itemData.subType == "accesory" then
            if not player.equipment.accesory1 then return "accesory1" end
            if not player.equipment.accesory2 then return "accesory2" end
            return "accesory1"
        end
    end
    return "lHand" -- Slot por defecto
end


function HandleOptionSelection()
    if #currentOptions == 0 or not confirmedItemIndex then 
        ResetSelection()
        return 
    end
    
    local option = currentOptions[selectedOptionIndex]
    local item = GetConfirmedItem()
    
    if not item then
        ResetSelection()
        return
    end
    
    if option.action == "equip" then
        local slot = GetAppropriateSlot(item.data)
        
        -- Desequipar primero si ya hay algo en ese slot
        if player.equipment[slot] then
            player:unequipItem(slot)  -- Esto automáticamente lo devuelve al inventario
        end
        
        -- Equipar el nuevo item
        player:equipItem(item.name, slot)
        
    elseif option.action == "use" then
        player:useItem(item.name)
        
        -- If in combat, using item counts as player turn
        if gameState.inCombat then
            local action = {type = "item", itemName = item.name}
            -- Close inventory
            isFilteredInventoryOpen = false
            isInventoryOpen = false
            isOptionMenuOpen = false
            inventoryFilterType = nil
            inventoryFilterSubType = nil
            -- Execute turn
            CombatSystem:ExecuteTurn(player, gameState.currentEnemy, action, gameState, log, logIcons, Utils)
            gameState.playerTurn = false
        end
    elseif option.action == "drop" then
        player:removeItemFromInventory(item.name, item.quantity)
    elseif option.action == "recipes" then
        isRecipesMenuOpen = true
        isInventoryOpen = false
        isOptionMenuOpen = false
        selectedItemForRecipes = item.name
        selectedRecipeIndex = 1
        recipeScrollOffset = 0  -- Resetear el scroll al abrir el menú
        confirmedItemIndex = nil 
    end
    
    ResetSelection()
end


local function ResetSelection()
    isOptionMenuOpen = false
    confirmedItemIndex = nil
    selectedItemIndex = vec2(1, 1)  -- Resetear a posición inicial
    video3:Clear(color.black)
    
    -- Redibujar inventario si está abierto
    if isInventoryOpen then
        Utils:PrintInventory(player, nil, nil, selectedItemIndex, nil)
    end
end


--------------------------------------------------------------------------------------
-- SKILL TREE SYSTEM

function ToggleSkillTree()
    if buttonZ.ButtonDown and not isInventoryOpen and not isPlayerSheetOpen and not gameState.inCombat and not gameState.waitingForDecision and not gameState.waitingForInput then
        isSkillTreeOpen = not isSkillTreeOpen
        if isSkillTreeOpen then
            selectedSkillId = 1
            skillTreeScrollOffset = 0
        end
    end
end

function HandleSkillTreeNavigation()
    if not isSkillTreeOpen then return end
    
    if dPad.DPadEvent then
        local event = dPad.DPadEvent
        
        -- Navegación vertical en el árbol
        if event.Y < 0 and selectedSkillId then
            -- Bajar
            local nextSkill = Skill:GetSkillData(selectedSkillId + 1)
            if nextSkill then
                selectedSkillId = selectedSkillId + 1
                -- Scroll si es necesario
                local skillData = Skill:GetSkillData(selectedSkillId)
                if skillData and skillData.gridRow - skillTreeScrollOffset > 4 then
                    skillTreeScrollOffset = skillTreeScrollOffset + 1
                end
            end
        elseif event.Y > 0 and selectedSkillId then
            -- Subir
            if selectedSkillId > 1 then
                selectedSkillId = selectedSkillId - 1
                -- Scroll si es necesario
                local skillData = Skill:GetSkillData(selectedSkillId)
                if skillData and skillData.gridRow - skillTreeScrollOffset < 0 then
                    skillTreeScrollOffset = skillTreeScrollOffset - 1
                end
            end
        end
        
        -- Navegación horizontal entre árboles
        if event.X > 0 and selectedSkillId then
            -- Cambiar a árbol mágico
            local currentSkill = Skill:GetSkillData(selectedSkillId)
            if currentSkill and currentSkill.tree == "physical" then
                selectedSkillId = 4 -- Primera skill mágica
            end
        elseif event.X < 0 and selectedSkillId then
            -- Cambiar a árbol físico
            local currentSkill = Skill:GetSkillData(selectedSkillId)
            if currentSkill and currentSkill.tree == "magic" then
                selectedSkillId = 1 -- Primera skill física
            end
        end
    end
    
    -- Aprender skill con botón X
    if buttonX.ButtonDown and selectedSkillId then
        local success, message = Skill:LearnSkill(player, selectedSkillId)
        if success then
            Utils:AddLogEntry(log, logIcons, 3, 0, message)
        else
            Utils:AddLogEntry(log, logIcons, 0, 0, message)
        end
    end
end

--------------------------------------------------------------------------------------
-- COMBAT SYSTEM

function HandleCombatInput()
    if not gameState.inCombat then 
        print("DEBUG: Not in combat")
        return 
    end
    
    if not gameState.playerTurn then 
        print("DEBUG: Not player turn")
        return 
    end
    
    print("DEBUG: HandleCombatInput - combatMenuActive = " .. tostring(gameState.combatMenuActive))
    
    -- If no combat menu is active, show it
    if not gameState.combatMenuActive then
        print("DEBUG: Activating combat menu")
        gameState.combatMenuActive = true
        gameState.combatOptions = {
            {text = "Attack", action = "attack"},
            {text = "Use Item", action = "item"}
        }
        gameState.selectedCombatOption = 1
        return
    end
    
    -- Confirm selection with buttonZ
    if buttonZ.ButtonDown then
        print("DEBUG: buttonZ pressed in combat")
        local option = gameState.combatOptions[gameState.selectedCombatOption]
        
        if option.action == "attack" then
            print("DEBUG: Executing attack")
            -- Execute basic attack
            local action = {type = "attack"}
            CombatSystem:ExecuteTurn(player, gameState.currentEnemy, action, gameState, log, logIcons, Utils)
            gameState.playerTurn = false
            gameState.combatMenuActive = false
            video3:Clear(color.black)
            
        elseif option.action == "item" then
            print("DEBUG: Opening item menu")
            -- Open consumables inventory
            gameState.combatMenuActive = false
            isFilteredInventoryOpen = true
            inventoryFilterType = "consumable"
            inventoryFilterSubType = nil
            selectedItemIndex = vec2(1, 1)
            confirmedItemIndex = nil
            video3:Clear(color.black)
        end
    end
end

function UpdateCombatAnimation()
    if not gameState.inCombat then return end
    
    -- Animate enemy sprite (alternate every 0.5s)
    gameState.enemyAnimTimer = gameState.enemyAnimTimer + (1/60)
    if gameState.enemyAnimTimer >= 0.5 then
        gameState.enemyAnimFrame = (gameState.enemyAnimFrame + 1) % 2
        gameState.enemyAnimTimer = 0
    end
end

--------------------------------------------------------------------------------------
-- CHAPTER SYSTEM

function HandleChapterProgression()
    -- Don't handle chapter events if menus are open or interacting with UI
    if isInventoryOpen or isFilteredInventoryOpen or isSkillTreeOpen or isOptionMenuOpen or confirmedItemIndex or selectedStatIndex then
        return
    end
    
    -- Don't handle if player sheet is open AND equipment slot is being interacted with
    if isPlayerSheetOpen and selectedEquipmentIndex and selectedEquipmentIndex ~= "lHand" then
        return
    end
    
    -- Continuar después de diálogo con buttonZ
    if gameState.waitingForInput and buttonZ.ButtonDown then
        gameState.waitingForInput = false
        local nextEv = gameState.nextEvent  -- Save before clearing
        gameState.nextEvent = nil  -- Clear to prevent re-execution
        if nextEv then
            Chapters:ExecuteEvent(nextEv, player, gameState, log, logIcons, Utils)
        end
        return -- Don't process decisions in same frame
    end
    
    -- Manejar decisiones (only if we didn't just advance dialogue)
    if gameState.waitingForDecision then
        HandleDecisionInput()
    end
end

function HandleDecisionInput()
    if not gameState.currentDecision then return end
    
    -- Don't handle if interactive menus are open
    if isInventoryOpen or isFilteredInventoryOpen or isSkillTreeOpen or isOptionMenuOpen then
        return
    end
    
    local options = gameState.currentDecision.options
    
    -- DPad navigation is handled in eventChannel1
    
    -- Confirmar decisión con buttonZ
    if buttonZ.ButtonDown then
        print("DEBUG: buttonZ pressed, selecting option " .. selectedDecisionIndex)
        local selectedOption = options[selectedDecisionIndex]
        gameState.waitingForDecision = false
        gameState.currentDecision = nil
        selectedDecisionIndex = 1
        video3:Clear(color.black)
        
        -- Ejecutar siguiente evento
        if selectedOption.nextEvent then
            Chapters:ExecuteEvent(selectedOption.nextEvent, player, gameState, log, logIcons, Utils)
        end
    end
end

function StartChapter0()
    -- Iniciar el capítulo 0
    gameState.currentEvent = 0
    Chapters:ExecuteEvent(0, player, gameState, log, logIcons, Utils)
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

function LoadGame()

	
	player.chapter = 0
	player.subChapter = 0

	return player
end


--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

Testing()

-- game controller
-- pre-update
Init()


-- update
function update()
    -- Draw background ALWAYS on video1 (behind everything) - including combat
    if not isInventoryOpen and not isPlayerSheetOpen and not isFilteredInventoryOpen and not isSubStatsOpen and not isRecipesMenuOpen and not isSkillTreeOpen then
        video1:Clear(color.black)
        DrawBackground()
    end
    
    -- Progresión de capítulos (PRIORITY - handle first)
    HandleChapterProgression()
    
    HandleButtonZ()
    HandleButtonX()

    TogglePlayerSheet()
    ToggleInventory()
    ToggleSkillTree()
    
    -- Manejo de skill tree
    if isSkillTreeOpen then
        HandleSkillTreeNavigation()
        Utils:PrintSkillTree(player, Skill, selectedSkillId, skillTreeScrollOffset)
    end
    
    -- Manejo de combate (draws on top of background)
    if gameState.inCombat then
        HandleCombatInput()
        UpdateCombatAnimation()
        Utils:PrintCombatScreen(player, gameState.currentEnemy, gameState.enemyAnimFrame, gameFont, gameFontAlter2, guiIcons, enemySpr)
        
        -- Show combat menu if active
        if gameState.combatMenuActive then
            Utils:PrintDecisionOptions(gameState.combatOptions, gameState.selectedCombatOption)
        end
    end
    
    -- Manejo de decisiones (render options)
    if gameState.waitingForDecision then
        Utils:PrintDecisionOptions(gameState.currentDecision.options, selectedDecisionIndex)
    end

    -- Renderizar la pantalla correcta según el estado
    if isRecipesMenuOpen then
        Utils:PrintRecipes(player, nil, selectedItemForRecipes, selectedRecipeIndex, recipeScrollOffset)
    elseif isFilteredInventoryOpen then
        Utils:PrintInventory(player, inventoryFilterType, inventoryFilterSubType, 
                           selectedItemIndex, confirmedItemIndex, true, selectedEquipmentIndex)
    elseif isInventoryOpen then
        Utils:PrintInventory(player, nil, nil, selectedItemIndex, confirmedItemIndex)
    elseif isSubStatsOpen then
        Utils:PrintSubStats(player)
    elseif isPlayerSheetOpen then
        Utils:PrintPlayerSheet(player, selectedEquipmentIndex, confirmedEquipmentIndex, selectedStatIndex, showSubStatsSelector)
    end

    LogController()
    
    player:updateSubStats()
    if not isSkillTreeOpen then
        Utils:PrintPlayerConstants(player)
    end
    
    TestingUpdate()
		
		



        --video1:DrawSprite(vec2(1,53), debugSpr,0,0, color.white, color.clear)
		
		--video1:DrawSprite(vec2(1,1), logIcons,5,0, color.white, color.clear)

	
		--Utils:Tprint(video1, vec2(11, 2), gameFont, nil, nil, nil, "    +     =")
		
		--video1:DrawSprite(vec2(12,1), itemSpr,8,7, color.white, color.clear)
		--video1:DrawSprite(vec2(16,8), guiIcons,7,0, color.white, color.clear)
		--Utils:Tprint(video1, vec2(11, 8), gameFontAlter1Shadow, nil, nil, nil, "2")
		
		
		--video1:DrawSprite(vec2(36,1), itemSpr,10,7, color.white, color.clear)
		--video1:DrawSprite(vec2(40,8), guiIcons,8,0, color.white, color.clear)
		
		
		--video1:DrawSprite(vec2(60,1), itemSpr,5,5, color.white, color.clear)

end