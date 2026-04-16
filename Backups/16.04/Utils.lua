-- Imports y configuraciones iniciales
local BD = require("BD.lua")

-- Dispositivos hardware
local audio = gdt.AudioChip0
local videoPrincipal = gdt.VideoChip0
local videoLogs = gdt.VideoChip1
local videoOptions = gdt.VideoChip2
local videoSkills = gdt.VideoChip3
local rom = gdt.ROM

-- Definición de la clase Utils
local Utils = {}

function Utils:new()
    return setmetatable({}, { __index = Utils })
end

-- Recursos gráficos
local gameFont = rom.User.SpriteSheets["gameFont.png"]
local gameFontAlter1 = rom.User.SpriteSheets["gameFontAlter1.png"]
local gameFontAlter1Shadow = rom.User.SpriteSheets["gameFontAlter1Shadow.png"]
local guiIcons = rom.User.SpriteSheets["guiIcons.png"]
local logIcons = rom.User.SpriteSheets["logIcons.png"]
local itemSpr = rom.User.SpriteSheets["itemSprites.png"]
local guiSelectors = rom.User.SpriteSheets["guiSelectors.png"]
local guiOptionSelector = rom.User.SpriteSheets["guiOptionSelector.png"]
local guiInventory = rom.User.SpriteSheets["guiInventory.png"]
local guiPlayerSheet = rom.User.SpriteSheets["guiPlayerSheet.png"]
local guiExtraStats = rom.User.SpriteSheets["guiExtraStats.png"]

---------------------------------------------------------------------------
-- systems

function Utils:PlayAudio(snd, channel, isLoop)
	
	if(isLoop) then
  audio:PlayLoop(snd, channel)
	else
  audio:Play(snd, channel)
	end
	
end

function Utils:Tprint(chip, pos, font, spriteSheet, spriteX, spriteY, txt, textColor, maxWidth)
    textColor = textColor or color.white
    maxWidth = maxWidth or 28  -- Default 28 characters for full screen
    
    -- Draw icon if exists
    if spriteSheet then
        chip:DrawSprite(pos, spriteSheet, spriteX, spriteY, color.white, color.clear)
        pos = pos + vec2(12, 0)
    end

    -- Smart line break function that respects whole words
    local function formatTextWithWordWrap(text, maxCharsPerLine)
        local lines = {}
        local currentLine = ""
        
        -- Split by explicit line breaks first
        for paragraph in text:gmatch("[^\n]+") do
            local words = {}
            for word in paragraph:gmatch("%S+") do
                table.insert(words, word)
            end
            
            for i, word in ipairs(words) do
                local testLine = currentLine
                if #currentLine > 0 then
                    testLine = testLine .. " " .. word
                else
                    testLine = word
                end
                
                -- Check if adding this word exceeds the limit
                if #testLine > maxCharsPerLine then
                    -- If current line has content, save it and start new line
                    if #currentLine > 0 then
                        table.insert(lines, currentLine)
                        currentLine = word
                    else
                        -- Word itself is too long, force break it
                        table.insert(lines, word)
                        currentLine = ""
                    end
                else
                    currentLine = testLine
                end
            end
            
            -- Save the last line of this paragraph
            if #currentLine > 0 then
                table.insert(lines, currentLine)
                currentLine = ""
            end
        end
        
        return table.concat(lines, "\n")
    end

    txt = formatTextWithWordWrap(txt, maxWidth)

    -- Draw text
    local line, charPos = 0, 0
    for i = 1, #txt do
        local char = txt:sub(i, i)
        if char == "\n" then 
            line, charPos = line + 1, 0
        else
            chip:DrawSprite(
                pos + vec2(4 * charPos, 7 * line), 
                font, 
                char:byte() % 32, 
                math.floor(char:byte() / 32), 
                textColor, 
                color.clear
            )
            charPos = charPos + 1
        end
    end
end

function Utils:ListSize(list)

	local size = 0
	for item in pairs(list) do
  	size = size + 1
	end
	return size
	
end

---------------------------------------------------------------------------
-- log
	
function Utils:AddLogEntry(log, spriteSheet, spriteX, spriteY, text)
  table.insert(log, {
      spriteSheet = spriteSheet,
      spriteX = spriteX,
      spriteY = spriteY,
      text = text
  })
end

function Utils:PrintLogEntries(log, chip, pos, font, scrollOffset)
    chip:Clear(color.black)
    
    local screenHeight, charLimit, lineHeight = 32, 28, 8
    local currentY = pos.Y + screenHeight + scrollOffset

    -- Recorrer el log en orden inverso para imprimir los más recientes primero
    for i = #log, 1, -1 do
        local entry = log[i]
        local logHeight = math.ceil(#entry.text / charLimit) * lineHeight
        currentY = currentY - logHeight

        -- Print solo si está dentro del área visible
        if currentY + logHeight > pos.Y and currentY < pos.Y + screenHeight then
            self:Tprint(chip, vec2(pos.X, currentY), font, entry.spriteSheet, entry.spriteX, entry.spriteY, entry.text)
        elseif currentY + logHeight <= pos.Y then
            break -- No imprimir más si los siguientes logs están completamente fuera de pantalla
        end
    end
end

function Utils:CalculateTotalLogHeight(log)
    local totalHeight = 0
    for _, entry in ipairs(log) do
        totalHeight = totalHeight + (math.ceil(#entry.text / 28) * 8)
    end
    return totalHeight
end

---------------------------------------------------------------------------
-- items

function Utils:GetItemData(itemName)
    for _, category in ipairs({BD.weapons, BD.armor, BD.consumables, BD.misc}) do
        for _, item in ipairs(category) do
            if item.name == itemName then return item end
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- player constants

function Utils:PrintPlayerConstants(player)
    -- Dibujar el fondo de las constantes
    videoPrincipal:DrawSprite(vec2(0, 0), rom.User.SpriteSheets["guiPlayerConstants.png"], 0, 0, color.white, color.clear)

    -- Función para imprimir números con ajuste de posición
    local function printAdjustedNumber(value, baseX, y)
        local str = tostring(value)
        local x = baseX - (#str * 4)  -- Retrocede 4px por cada dígito
        self:Tprint(videoPrincipal, vec2(x, y), gameFontAlter1, nil, nil, nil, str)
    end

    -- Print cada estadística con su posición base
    printAdjustedNumber(player.health, 12, 56)     -- Health
    printAdjustedNumber(player.mana, 38, 56)      -- Mana
    printAdjustedNumber(player.hunger, 90, 56)    -- Hunger
    printAdjustedNumber(player.sleepyness, 116, 56)-- Sleep
    
    -- Draw status effects bar
    local statusIconsSprite = rom.User.SpriteSheets["statusIcons.png"]
    if statusIconsSprite then
        self:DrawPlayerStatusBar(player, statusIconsSprite)
    end
end

---------------------------------------------------------------------------
-- inventory print

function Utils:PrintInventory(player, itemType, itemSubType, selectedIndex, confirmedIndex, isFiltered, equipSlot)
    -- Configuración inicial de pantalla
    videoPrincipal:Clear(color.black)
    videoPrincipal:DrawSprite(vec2(0, 0), guiInventory, 0, 0, color.white, color.clear)

    -- Preparar lista de ítems con opción de desequipar si es necesario
    local items = {}
    local shouldShowUnequip = isFiltered and equipSlot and player.equipment[equipSlot]
    
    
    if shouldShowUnequip then
        table.insert(items, {
            name = "UNEQUIP",
            quantity = 1,
            data = {
                name = "Unequip",
                type = "unequip",
                subType = "none",
                spr = {6, 0},
                effectTags = {"Unequip"},
                price = 0,
                description = "Remueve el objeto equipado actualmente"
            }
        })
    end

    -- Agregar ítems del inventario
    for name, qty in pairs(player.inventory) do
        local data = self:GetItemData(name)
        if data then table.insert(items, {name = name, quantity = qty, data = data}) end
    end

    -- Ordenar manteniendo "UNEQUIP" primero
    table.sort(items, function(a, b)
        return (a.data.type == "unequip" and true) or 
               (b.data.type == "unequip" and false) or
               (a.data.spr[2] * 10 + a.data.spr[1]) < (b.data.spr[2] * 10 + b.data.spr[1])
    end)

    -- Dibujar ítems filtrados
    local activeItem, visibleCount = nil, 0
    for i, item in ipairs(items) do
        -- Show UNEQUIP type only if equipSlot was provided
        local allowUnequip = equipSlot ~= nil and item.data.type == "unequip"
        
        local showItem = not itemType or item.data.type == itemType or allowUnequip
        showItem = showItem and (not itemSubType or item.data.subType == itemSubType or allowUnequip)
        
        if showItem then
            local row = math.floor(visibleCount / 5)
            local col = visibleCount % 5
            local pos = vec2(2 + col * 13, 2 + row * 13)

            local drawPos = item.data.type == "unequip" and (pos + vec2(1,1)) or pos

            videoPrincipal:DrawSprite(drawPos, 
                item.data.type == "unequip" and guiIcons or itemSpr,
                item.data.spr[1], item.data.spr[2], 
                color.white, color.clear)

            if item.data.type ~= "unequip" then
                self:Tprint(videoPrincipal, pos + vec2(item.quantity < 10 and 6 or 2, 4), 
                          gameFontAlter1, nil, nil, nil, tostring(item.quantity))
            end

            -- Verificar selección
            if (selectedIndex.x == col + 1 and selectedIndex.y == row + 1) or
               (confirmedIndex and confirmedIndex.x == col + 1 and confirmedIndex.y == row + 1) then
                activeItem = item.data
            end

            visibleCount = visibleCount + 1
        end
    end

    -- Dibujar selectores
    if visibleCount > 0 then
        local function drawSel(index, frame)
            videoPrincipal:DrawSprite(vec2((index.x - 1) * 13, (index.y - 1) * 13), 
                                    guiSelectors, frame, 0, color.white, color.clear)
        end
        drawSel(selectedIndex, 0)
        if confirmedIndex then drawSel(confirmedIndex, 1) end
    end

    -- Mostrar detalles del ítem activo
    if activeItem then
        local desc = #activeItem.effectTags > 0 and table.concat(activeItem.effectTags, ", ") or activeItem.description
        self:Tprint(videoPrincipal, vec2(68, 8), gameFontAlter1, nil, nil, nil, activeItem.name)
        self:Tprint(videoPrincipal, vec2(68, 24), gameFontAlter1, nil, nil, nil, desc)
        self:Tprint(videoPrincipal, vec2(68, 40), gameFontAlter1, nil, nil, nil, tostring(activeItem.price))
    end
end

function Utils:PrintInventoryItem(pos, itemData, quantity)
    videoPrincipal:DrawSprite(pos, itemSpr, itemData.spr[1], itemData.spr[2], color.white, color.clear)
    local quantityPos = pos + vec2(quantity < 10 and 6 or 2, 4)
    self:Tprint(videoPrincipal, quantityPos, gameFontAlter1, nil, nil, nil, tostring(quantity))
end

---------------------------------------------------------------------------
-- playersheet print

function Utils:PrintPlayerSheet(player, selEqIndex, confEqIndex, selStatIndex, showSubStats)
    -- Configuración inicial
    videoPrincipal:Clear(color.black)
    videoPrincipal:DrawSprite(vec2(0, 0), guiPlayerSheet, 0, 0, color.white, color.clear)

    -- Definición de slots y posiciones
    local slots = {
        lHand = {pos = vec2(2, 2), defaultSpr = {0,1}}, 
        head = {pos = vec2(15, 2), defaultSpr = {1,1}},
        rHand = {pos = vec2(28, 2), defaultSpr = {2,1}}, 
        accesory1 = {pos = vec2(2, 15), defaultSpr = {3,1}},
        body = {pos = vec2(15, 15), defaultSpr = {4,1}}, 
        accesory2 = {pos = vec2(2, 28), defaultSpr = {3,1}},
        feet = {pos = vec2(15, 28), defaultSpr = {5,1}}
    }

    -- Dibujar equipo con verificación de nil
    for slotName, slot in pairs(slots) do
        local itemName = player.equipment[slotName]
        if itemName then
            local itemData = self:GetItemData(itemName)
            if itemData and itemData.spr then
                videoPrincipal:DrawSprite(slot.pos, itemSpr, itemData.spr[1], itemData.spr[2], color.white, color.clear)
            else
                videoPrincipal:DrawSprite(slot.pos, guiIcons, slot.defaultSpr[1], slot.defaultSpr[2], color.white, color.clear)
            end
        else
            videoPrincipal:DrawSprite(slot.pos, guiIcons, slot.defaultSpr[1], slot.defaultSpr[2], color.white, color.clear)
        end
    end

    -- Resto del método permanece igual...
    local statPos = {
        strength = vec2(96,0), agility = vec2(96,8), dexterity = vec2(96,16),
        intelligence = vec2(96,24), vitality = vec2(96,32)
    }

    -- Dibujar selectores
    local function drawSel(pos, frame, isStat)
        local offset = isStat and vec2(1,0) or vec2(2,2)
        videoPrincipal:DrawSprite(pos - offset, guiSelectors, frame, isStat and 2 or 1, color.white, color.clear)
    end

    if not isSelectingEquipment then
        if selEqIndex and not selStatIndex and not showSubStats then
            drawSel(slots[selEqIndex].pos, 0)
        end
        
        if selStatIndex and not showSubStats then
            drawSel(statPos[selStatIndex], 0, true)
        end
        
        if showSubStats then
            videoPrincipal:DrawSprite(vec2(105, 33), guiOptionSelector, 0, 0, color.white, color.clear)
        end
        
        if confEqIndex then
            drawSel(slots[confEqIndex].pos, 1)
        end
    end

    -- Mostrar info del equipo seleccionado
    if selEqIndex and not selStatIndex and not showSubStats then
        local itemName = player.equipment[selEqIndex]
        if itemName then
            local data = self:GetItemData(itemName)
            if data then
                self:Tprint(videoPrincipal, vec2(1,39), gameFont, nil,nil,nil, data.name)
                local effects = data.effectTags and #data.effectTags > 0 and table.concat(data.effectTags, ", ") or "No special effects"
                self:Tprint(videoPrincipal, vec2(1,45), gameFontAlter1, nil,nil,nil, effects)
            end
        end
    end

    -- Dibujar stats
    local stats = {
        {player.stats.strength, 84,1}, {player.stats.agility, 84,9},
        {player.stats.dexterity, 84,17}, {player.stats.intelligence, 84,25},
        {player.stats.vitality, 84,33}
    }

    for _, stat in ipairs(stats) do
        local x = stat[1] < 10 and stat[2] or (stat[1] < 100 and stat[2]-4 or stat[2]-8)
        self:Tprint(videoPrincipal, vec2(x, stat[3]), gameFontAlter1, nil,nil,nil, tostring(stat[1]))
    end

    -- Info jugador
    local function printNum(val, x, y)
        local str = tostring(val)
        local adjX = val < 10 and x or (val < 100 and x-4 or (val < 1000 and x-8 or x-12))
        self:Tprint(videoPrincipal, vec2(adjX, y), gameFontAlter1, nil,nil,nil, str)
    end

    printNum(player.level, 115,1)
    printNum(player.points, 115,9)
    printNum(player.gold, 115,16)
    printNum(player.exp, 94-(#tostring(player.exp)*4),44)
    printNum(player.expToNextLevel, 99,44)

    -- Botones de mejora
    if player.points > 0 then
        for _, pos in pairs(statPos) do
            videoPrincipal:DrawSprite(pos+vec2(0,1), guiIcons, 5,0, color.white, color.clear)
        end
    end
end


function Utils:PrintSubStats(player)
    videoPrincipal:Clear(color.black)
    videoPrincipal:DrawSprite(vec2(0,0), guiExtraStats,0,0, color.white, color.clear)
    
    local function ps(v,x,y)
        local s = tostring(math.floor(v))
        self:Tprint(videoPrincipal, vec2(x-(#s-1)*4,y), gameFontAlter1,nil,nil,nil,s)
    end
    
    -- Izquierda
    local s = player.subStats
    ps(s.attack,50,2) ps(s.mAttack,50,10) ps(s.defense,50,18)
    ps(s.mDefense,50,26) ps(s.speed,50,34) ps(s.dodge,50,42)
    
    -- Derecha
    ps(s.hit,115,2) ps(s.crit,115,10) ps(s.healthRegen,115,18)
    ps(s.manaRegen,115,26) ps(s.hungerDecay,115,34) ps(s.sleepDecay,115,42)
end

---------------------------------------------------------------------------
-- options system

function Utils:ShowOptions(chip, options, selectedIndex)
    chip:Clear(color.black)
    local startY = 2
    for i, option in ipairs(options) do
        local iconX, iconY = 4, 0  -- Icono por defecto (logIcons 4,0)
        if i == selectedIndex then
            iconX, iconY = 5, 0  -- Icono seleccionado (logIcons 5,0)
        end
        
        -- Dibujar icono + texto
        self:Tprint(chip, vec2(2, startY + (i-1)*8), gameFont, logIcons, iconX, iconY, option.text)
    end
end

function Utils:GetItemOptions(itemData)
    local options = {}
    
    if itemData.type == "weapon" or itemData.type == "armor" then
        table.insert(options, {text = "Equip", action = "equip"})
        table.insert(options, {text = "Drop", action = "drop"})
    elseif itemData.type == "consumable" then
        table.insert(options, {text = "Use", action = "use"})
        table.insert(options, {text = "Recipes", action = "recipes"})  -- Nueva opción
        table.insert(options, {text = "Drop", action = "drop"})
    else -- misc
        table.insert(options, {text = "Recipes", action = "recipes"})  -- Nueva opción
        table.insert(options, {text = "Drop", action = "drop"})
    end
    
    return options
end

---------------------------------------------------------------------------
-- recipes system

-- Primero añadimos el método ParseIngredients a Utils
function Utils:ParseIngredients(ingredients)
    local parsed = {}
    for _, ing in ipairs(ingredients) do
        -- El formato es "1 Item Name" o "2 Item Name" etc
        local quantity, itemName = ing:match("(%d+) (.+)")
        if quantity and itemName then
            table.insert(parsed, {
                itemName = itemName,
                quantity = tonumber(quantity)
            })
        end
    end
    return parsed
end

-- Y ahora la función PrintRecipes corregida
function Utils:PrintRecipes(player, videoChip, selectedItem, selectedRecipeIndex, scrollOffset)
    videoChip = videoChip or videoPrincipal
    videoChip:Clear(color.black)
    
    if #player.recipes == 0 then
        self:Tprint(videoChip, vec2(10, 15), gameFont, nil, nil, nil, "No recipes discovered yet!")
        return
    end
    
    -- Filtrar recetas si se especificó un ítem seleccionado
    local filteredRecipes = {}
    if selectedItem then
        for _, recipe in ipairs(player.recipes) do
            local ingredients = self:ParseIngredients(recipe.ingredients)
            for _, ing in ipairs(ingredients) do
                if ing.itemName == selectedItem then
                    table.insert(filteredRecipes, recipe)
                    break
                end
            end
        end
    else
        filteredRecipes = player.recipes
    end
    
    if #filteredRecipes == 0 then
        self:Tprint(videoChip, vec2(10, 15), gameFont, nil, nil, nil, "No recipes found for this item!")
        return
    end
    
    -- Asegurar que el índice seleccionado sea válido
    selectedRecipeIndex = selectedRecipeIndex or 1
    if selectedRecipeIndex < 1 then selectedRecipeIndex = 1 end
    if selectedRecipeIndex > #filteredRecipes then selectedRecipeIndex = #filteredRecipes end
    
    -- Asegurar que el scroll offset sea válido
    scrollOffset = scrollOffset or 0
    local maxVisibleRecipes = 3  -- 51 píxeles ÷ 15 píxeles por receta
    local maxScrollOffset = math.max(0, (#filteredRecipes - maxVisibleRecipes) * 15)
    scrollOffset = math.min(maxScrollOffset, math.max(0, scrollOffset))
    
    local RECIPE_HEIGHT = 15
    local START_Y = 2
    local START_X = 11
    local ITEM_SPACING = 24
    local FORMULA_Y_OFFSET = 0
    local ITEM_Y_OFFSET = -1
    local INDICATOR_Y_OFFSET = 6
    
    for i, recipe in ipairs(filteredRecipes) do
        local currentY = START_Y + (i-1) * RECIPE_HEIGHT - scrollOffset
        
        -- Solo dibujar si la receta está dentro de la pantalla
        if currentY >= START_Y - RECIPE_HEIGHT and currentY <= 53 then
            -- Dibujar el selector (rojo o verde según si está seleccionado)
            local selectorIcon = (i == selectedRecipeIndex) and 5 or 4
            videoChip:DrawSprite(vec2(1, currentY), logIcons, selectorIcon, 0, color.white, color.clear)
            
            -- 1. Imprimir la fórmula base según el número de ingredientes
            local ingredients = self:ParseIngredients(recipe.ingredients)
            local formulaText = ""
            if #ingredients == 2 then
                formulaText = "    +     ="
            elseif #ingredients == 3 then
                formulaText = "    +     +     ="
            end
            self:Tprint(videoChip, vec2(START_X, currentY + FORMULA_Y_OFFSET), 
                       gameFont, nil, nil, nil, formulaText)
            
            -- 2. Procesar ingredientes
            local xOffset = START_X + 1
            
            for _, ing in ipairs(ingredients) do
                local itemData = self:GetItemData(ing.itemName)
                if itemData then
                    -- 3. Dibujar sprite del item
                    videoChip:DrawSprite(
                        vec2(xOffset, currentY + ITEM_Y_OFFSET),
                        itemSpr,
                        itemData.spr[1],
                        itemData.spr[2],
                        color.white,
                        color.clear
                    )
                    
                    -- 4. Dibujar indicador de disponibilidad
                    local hasEnough = player.inventory[ing.itemName] and 
                                    player.inventory[ing.itemName] >= ing.quantity
                    local iconX = hasEnough and 0 or 1
                    videoChip:DrawSprite(
                        vec2(xOffset + 4, currentY + INDICATOR_Y_OFFSET),
                        guiIcons,
                        iconX,
                        2,
                        color.white,
                        color.clear
                    )
                    
                    -- 5. Imprimir cantidad si es mayor a 1
                    if ing.quantity > 1 then
                        self:Tprint(
                            videoChip,
                            vec2(xOffset, currentY + INDICATOR_Y_OFFSET),
                            gameFontAlter1Shadow,
                            nil, nil, nil,
                            tostring(ing.quantity)
                        )
                    end
                    
                    xOffset = xOffset + ITEM_SPACING
                end
            end
            
            -- 6. Dibujar el item resultante
            local resultXOffset = xOffset + (#ingredients == 3 and 10 or 10)
            local resultItemName = recipe.name:gsub(" Recipe", "")
            local resultItem = self:GetItemData(resultItemName)
            if resultItem then
                videoChip:DrawSprite(
                    vec2(resultXOffset - 10, currentY + ITEM_Y_OFFSET),  -- Restamos 6 píxeles a la posición X
                    itemSpr,
                    resultItem.spr[1],
                    resultItem.spr[2],
                    color.white,
                    color.clear
                )
            end
        end
    end
end

---------------------------------------------------------------------------
-- SKILL SYSTEM UI

function Utils:PrintSkillTree(player, selectedSkillId, scrollOffset, skipClear)
    local skillSpr = rom.User.SpriteSheets["skillSpr.png"]
    local guiSkillList = rom.User.SpriteSheets["guiSkillList.png"]
    local guiSelectors = rom.User.SpriteSheets["guiSelectors.png"]
    
    -- Only clear if not showing confirmation window
    if not skipClear then
        videoPrincipal:Clear(color.black)
    end
    
    -- Pintar fondo del skill tree
    videoPrincipal:DrawSprite(vec2(0, 0), guiSkillList, 0, 0, color.white, color.clear)
    
    scrollOffset = scrollOffset or 0
    
    -- Pintar skills del árbol físico (columna 0)
    for _, skillData in ipairs(BD.skills) do
        if skillData.tree == "physical" then
            self:DrawSkillIcon(player, skillData, selectedSkillId, scrollOffset, guiSelectors, skillSpr)
        end
    end
    
    -- Pintar skills del árbol mágico (columna 2)
    for _, skillData in ipairs(BD.skills) do
        if skillData.tree == "magic" then
            self:DrawSkillIcon(player, skillData, selectedSkillId, scrollOffset, guiSelectors, skillSpr)
        end
    end
    
    -- Pintar info de la skill seleccionada
    if selectedSkillId then
        -- Find skill data directly from BD.skills
        local skillData = nil
        for _, skill in ipairs(BD.skills) do
            if skill.id == selectedSkillId then
                skillData = skill
                break
            end
        end
        
        if skillData then
            self:DrawSkillInfo(skillData, player)
        end
    end
end

function Utils:DrawSkillIcon(player, skillData, selectedSkillId, scrollOffset, guiSelectors, skillSpr)
    local col = skillData.treeColumn
    local row = skillData.gridRow - scrollOffset
    
    -- Solo pintar si está visible (filas 0-4)
    if row < 0 or row > 4 then return end
    
    -- Posiciones base
    local selectorX = 1 + (col * 12)
    local selectorY = 1 + (row * 12)
    local iconX = 3 + (col * 12)
    local iconY = 3 + (row * 12)
    
    -- Check if already learned
    local isLearned = false
    for _, learnedId in ipairs(player.skills) do
        if learnedId == skillData.id then
            isLearned = true
            break
        end
    end
    
    -- Check if can be learned (requirements check)
    local canLearn = true
    
    if not isLearned then
        -- Check skill points
        if player.skillPoints < 1 then
            canLearn = false
        end
        
        -- Check required skill
        if skillData.requiredSkill then
            local hasRequiredSkill = false
            for _, learnedId in ipairs(player.skills) do
                if learnedId == skillData.requiredSkill then
                    hasRequiredSkill = true
                    break
                end
            end
            if not hasRequiredSkill then
                canLearn = false
            end
        end
    end
    
    -- Determine icon color based on state
    local iconColor
    if isLearned then
        iconColor = color.white  -- Learned: full color
    elseif canLearn then
        iconColor = color.white  -- Can learn: full color (colored border differentiates learned)
    else
        iconColor = color.gray  -- Cannot learn: gray (darker but still visible)
    end
    
    -- Draw skill icon
    videoPrincipal:DrawSprite(
        vec2(iconX, iconY),
        skillSpr,
        skillData.spriteX, skillData.spriteY,
        iconColor, color.clear
    )
    
    -- Draw colored selector ONLY if learned
    if isLearned then
        local selectorCol = skillData.tree == "physical" and 1 or 3
        videoPrincipal:DrawSprite(
            vec2(selectorX, selectorY),
            guiSelectors,
            selectorCol, 3,
            color.white, color.clear
        )
    end
    
    -- Draw cursor if this is the selected skill
    if selectedSkillId == skillData.id then
        videoPrincipal:DrawSprite(
            vec2(selectorX, selectorY),
            guiSelectors,
            0, 3,
            color.white, color.clear
        )
    end
end

function Utils:DrawSkillInfo(skillData, player)
    local guiIcons = rom.User.SpriteSheets["guiIcons.png"]
    
    -- Name (66, 8)
    self:Tprint(videoPrincipal, vec2(66, 8), gameFontAlter1, nil, nil, nil, skillData.name)
    
    -- Available skill points (114, 0 for 1 digit / 110, 0 for 2 digits)
    local pointsStr = tostring(player.skillPoints)
    local pointsX = #pointsStr == 1 and 114 or 110
    self:Tprint(videoPrincipal, vec2(pointsX, 0), gameFontAlter1, nil, nil, nil, pointsStr)
    
    -- Description (66, 24) - NO "DESCRIPTION" title, it's already in the UI base
    -- maxWidth=15 chars (62 pixels / 4 pixels per char)
    self:Tprint(videoPrincipal, vec2(66, 24), gameFont, nil, nil, nil, skillData.description, nil, 15)
    
    -- Mana cost (114, 16 for 1 digit / 110, 16 for 2 digits)
    if skillData.type == "active" then
        local costStr = tostring(skillData.manaCost)
        local costX = #costStr == 1 and 114 or 110
        -- Only number, icon is already in UI base
        self:Tprint(videoPrincipal, vec2(costX, 16), gameFontAlter1, nil, nil, nil, costStr)
    end
end

function Utils:PrintCombatScreen(player, enemy, enemyFrame, gameFont, gameFontAlter2, guiIcons, enemySpr)
    -- Don't clear - background is already drawn in update()
    
    -- Pintar sprite del enemigo centrado (con animación)
    local enemyX = 56  -- Centrado en 128px
    local enemyY = 10
    videoPrincipal:DrawSprite(
        vec2(enemyX, enemyY),
        enemySpr,
        enemyFrame, enemy.spriteRow,
        color.white, color.clear
    )
    
    -- HP del enemigo debajo del sprite
    local hpText = tostring(enemy.health)
    local heartX = 52
    local heartY = 30
    
    -- Icono corazón
    videoPrincipal:DrawSprite(vec2(heartX, heartY), guiIcons, 0, 0, color.white, color.clear)
    
    -- Texto HP (alineado a la derecha del corazón)
    local hpX = heartX + 8
    self:Tprint(videoPrincipal, vec2(hpX, heartY), gameFont, nil, nil, nil, hpText)
    
    -- Draw enemy status effects below HP
    local statusIconsSprite = rom.User.SpriteSheets["statusIcons.png"]
    if statusIconsSprite then
        self:DrawEnemyStatusList(enemy, heartX, heartY + 8, statusIconsSprite, gameFont)
    end
end

function Utils:PrintSkillButtons(player, Skill, skillSpr)
    local video4 = gdt.VideoChip3
    video4:Clear(color.black)
    
    -- Slot 1 (0, 0)
    if player.selectedSkills[1] then
        local skillData = Skill:GetSkillData(player.selectedSkills[1])
        if skillData then
            video4:DrawSprite(
                vec2(3, 3),
                skillSpr,
                skillData.spriteX, skillData.spriteY,
                color.white, color.clear
            )
        end
    end
    
    -- Slot 2 (27, 0)
    if player.selectedSkills[2] then
        local skillData = Skill:GetSkillData(player.selectedSkills[2])
        if skillData then
            video4:DrawSprite(
                vec2(30, 3),
                skillSpr,
                skillData.spriteX, skillData.spriteY,
                color.white, color.clear
            )
        end
    end
end

function Utils:PrintDecisionOptions(options, selectedIndex)
    local video3 = gdt.VideoChip2
    
    
    video3:Clear(color.black)
    
    local startY = 2
    for i, option in ipairs(options) do
        local iconX, iconY = 4, 0  -- Icon not selected
        if i == selectedIndex then
            iconX, iconY = 5, 0  -- Icon selected
        end
        
        
        -- Draw icon + text (same as ShowOptions)
        self:Tprint(video3, vec2(2, startY + (i-1)*8), gameFont, logIcons, iconX, iconY, option.text)
    end
end

function Utils:PrintSkillConfirmation(videoChip, gameFont, guiExtraWindow, guiButtons)
    -- Window position and size
    -- Window: 16,16 to 111,47 (96x32)
    local windowX = 16
    local windowY = 16
    
    
    -- Draw confirmation window (sprite index 0,1 not 0,0)
    videoChip:DrawSprite(vec2(windowX, windowY), guiExtraWindow, 0, 1, color.white, color.clear)
    
    -- Text: "Learn skill?" centered
    -- Window width = 96 pixels, text "Learn skill?" = 12 chars * 4px = 48px
    -- Center: (96 - 48) / 2 = 24 pixels from window left
    local textX = windowX + 24
    local textY = windowY + 6
    self:Tprint(videoChip, vec2(textX, textY), gameFont, nil, nil, nil, "Learn skill?")
    
    -- Buttons centered on second row
    -- Button Z (confirm) - index 4
    -- Button X (cancel) - index 5
    -- Each button is 12x12
    -- Total width for 2 buttons with spacing: 12 + 4 + 12 = 28 pixels
    -- Center: (96 - 28) / 2 = 34 pixels from window left
    
    local buttonY = windowY + 18
    local buttonZX = windowX + 28
    local buttonXX = windowX + 56
    
    -- Draw button Z (confirm)
    videoChip:DrawSprite(vec2(buttonZX, buttonY), guiButtons, 4, 0, color.white, color.clear)
    
    -- Draw button X (cancel)
    videoChip:DrawSprite(vec2(buttonXX, buttonY), guiButtons, 5, 0, color.white, color.clear)
end

---------------------------------------------------------------------------
-- STATUS EFFECTS RENDERING

function Utils:DrawPlayerStatusBar(player, statusIconsSprite)
    local CombatSystem = require("CombatSystem.lua")
    
    if not statusIconsSprite then return end
    
    -- Buffs positions: 5, 14, 23, 32, 41, 50
    local buffPositions = {5, 14, 23, 32, 41, 50}
    local buffNames = {"regen", "shield", "strength", "haste", "focus", "berserk"}
    
    -- Debuffs positions: 70, 79, 88, 97, 106, 115
    local debuffPositions = {70, 79, 88, 97, 106, 115}
    local debuffNames = {"bleeding", "poison", "burn", "freeze", "paralyze", "confusion"}
    
    local y = 1  -- Y position for all icons
    
    -- Draw buffs
    for i, buffName in ipairs(buffNames) do
        local statusData = CombatSystem.StatusEffects[buffName]
        if statusData then
            local isActive = player.buffs and player.buffs[buffName] and player.buffs[buffName] > 0
            
            -- Usar color.white para activos, gris para inactivos
            local spriteColor = isActive and color.white or vec3(60, 60, 60)
            
            videoPrincipal:DrawSprite(
                vec2(buffPositions[i], y),
                statusIconsSprite,
                statusData.sprite[1], statusData.sprite[2],
                spriteColor, color.clear
            )
            
            -- Draw turn count if active
            if isActive and player.buffs[buffName] < 999 then  -- 999 = permanent
                self:Tprint(videoPrincipal, vec2(buffPositions[i] + 5, y + 4), 
                          gameFontAlter1, nil, nil, nil, tostring(player.buffs[buffName]))
            end
        end
    end
    
    -- Draw debuffs
    for i, debuffName in ipairs(debuffNames) do
        local statusData = CombatSystem.StatusEffects[debuffName]
        if statusData then
            local isActive = player.debuffs and player.debuffs[debuffName] and player.debuffs[debuffName] > 0
            
            -- Usar color.white para activos, gris para inactivos
            local spriteColor = isActive and color.white or vec3(60, 60, 60)
            
            videoPrincipal:DrawSprite(
                vec2(debuffPositions[i], y),
                statusIconsSprite,
                statusData.sprite[1], statusData.sprite[2],
                spriteColor, color.clear
            )
            
            -- Draw turn count if active
            if isActive then
                self:Tprint(videoPrincipal, vec2(debuffPositions[i] + 5, y + 4), 
                          gameFontAlter1, nil, nil, nil, tostring(player.debuffs[debuffName]))
            end
        end
    end
end

function Utils:DrawEnemyStatusList(enemy, posX, posY, statusIconsSprite, font)
    local CombatSystem = require("CombatSystem.lua")
    local currentY = posY
    
    -- Count active buffs and debuffs
    local hasBuffs = false
    local hasDebuffs = false
    
    if enemy.buffs then
        for _, turns in pairs(enemy.buffs) do
            if turns > 0 then hasBuffs = true break end
        end
    end
    
    if enemy.debuffs then
        for _, turns in pairs(enemy.debuffs) do
            if turns > 0 then hasDebuffs = true break end
        end
    end
    
    -- Draw buffs
    if hasBuffs then
        self:Tprint(videoPrincipal, vec2(posX, currentY), font, nil, nil, nil, "Buffs:")
        currentY = currentY + 7
        
        local iconX = posX
        for buffName, turns in pairs(enemy.buffs) do
            if turns > 0 then
                local statusData = CombatSystem.StatusEffects[buffName]
                if statusData then
                    -- Draw icon con color.white
                    videoPrincipal:DrawSprite(
                        vec2(iconX, currentY),
                        statusIconsSprite,
                        statusData.sprite[1], statusData.sprite[2],
                        color.white, color.clear
                    )
                    
                    -- Draw turns (skip if permanent)
                    if turns < 999 then
                        self:Tprint(videoPrincipal, vec2(iconX + 5, currentY + 4), 
                                  gameFontAlter1, nil, nil, nil, tostring(turns))
                    end
                    
                    iconX = iconX + 10  -- Next icon
                end
            end
        end
        currentY = currentY + 10
    end
    
    -- Draw debuffs
    if hasDebuffs then
        self:Tprint(videoPrincipal, vec2(posX, currentY), font, nil, nil, nil, "Debuffs:")
        currentY = currentY + 7
        
        local iconX = posX
        for debuffName, turns in pairs(enemy.debuffs) do
            if turns > 0 then
                local statusData = CombatSystem.StatusEffects[debuffName]
                if statusData then
                    -- Draw icon con color.white
                    videoPrincipal:DrawSprite(
                        vec2(iconX, currentY),
                        statusIconsSprite,
                        statusData.sprite[1], statusData.sprite[2],
                        color.white, color.clear
                    )
                    
                    -- Draw turns
                    self:Tprint(videoPrincipal, vec2(iconX + 5, currentY + 4), 
                              gameFontAlter1, nil, nil, nil, tostring(turns))
                    
                    iconX = iconX + 10  -- Next icon
                end
            end
        end
    end
end

---------------------------------------------------------------------------

return Utils