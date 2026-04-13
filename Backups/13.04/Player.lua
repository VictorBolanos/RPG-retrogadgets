-- imports
local Utils = require("Utils.lua")
local BD = require("BD.lua")
-- local items = require("Items.lua")
-- local skills = require("Skills.lua")

---------------------------------------------------------------------------
-- Player class

local Player = {}

function Player:new(chapter, subChapter, gold, name, level, exp, expToNextLevel, points, hunger, sleepyness, health, maxHealth, mana, maxMana, baseStats, equipment, inventory, skills, selectedSkills)
    local obj = {
        chapter = chapter,
        subChapter = subChapter,

        gold = gold,

        name = "Sin nombre",
        level = level or 1,
        exp = exp or 0,
        expToNextLevel = expToNextLevel or CalculateExpToNextLevel(level or 1),
        points = points or 0,

        hunger = hunger,
        sleepyness = sleepyness,

        health = health,
        maxHealth = maxHealth,
        mana = mana,
        maxMana = maxMana,

        baseStats = {
            strength = baseStats[1],
            agility = baseStats[2],
            dexterity = baseStats[3],
            intelligence = baseStats[4],
            vitality = baseStats[5],
        },
        
        stats = {
            strength = baseStats[1],
            agility = baseStats[2],
            dexterity = baseStats[3],
            intelligence = baseStats[4],
            vitality = baseStats[5],
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
            sleepDecay = 0,
        },

        equipmentStatBonuss = {
            strength = 0,
            agility = 0,
            dexterity = 0,
            intelligence = 0,
            vitality = 0,

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
            sleepDecay = 0,
        },

        equipment = {
            lHand = equipment.lHand or nil,
            head = equipment.head or nil,
            rHand = equipment.rHand or nil,
            accesory1 = equipment.accesory1 or nil,
            accesory2 = equipment.accesory2 or nil,
            body = equipment.body or nil,
            feet = equipment.feet or nil,
        },

        inventory = inventory or {},
        
        skills = skills or {},
        selectedSkills = selectedSkills or {},

        recipes = {}
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---------------------------------------------------------------------------
-- health

function Player:plusHealth(health)
    if (self.health + health > self.maxHealth) then
        self.health = self.maxHealth
    else
        self.health = self.health + health
    end
end

function Player:minusHealth(health)
    if (self.health - health < 0) then
        self.health = 0
    else
        self.health = self.health - health
    end
end

function Player:plusMaxHealth(health)
    if (self.maxHealth + health > 100) then
        self.maxHealth = 100
    else
        self.maxHealth = self.maxHealth + health
    end
end

function Player:minusMaxHealth(health)
    if (self.maxHealth - health < 0) then
        self.maxHealth = 0
    else
        self.maxHealth = self.maxHealth - health
    end
end

---------------------------------------------------------------------------
-- lvl up

function Player:addExp(expGained)
    self.exp = self.exp + expGained
    
    -- Mientras tenga suficiente XP para subir de nivel
    while self.exp >= self.expToNextLevel do
        self.exp = self.exp - self.expToNextLevel
        self.level = self.level + 1
        self.points = self.points + 10  -- Otorga 10 puntos al subir de nivel
        self.expToNextLevel = CalculateExpToNextLevel(self.level)
    end
end

function CalculateExpToNextLevel(currentLevel)
    if currentLevel >= 20 then return 9999 end  -- Límite duro
    return math.floor(10 * (1.425 ^ (currentLevel - 1)))
end

---------------------------------------------------------------------------
-- stats

function Player:plusStat(stat, value)
    if (self.baseStats[stat] + value > 99) then
        self.baseStats[stat] = 99
    else
        self.baseStats[stat] = self.baseStats[stat] + value
    end
    self.stats[stat] = self.baseStats[stat]
end


function Player:minusStat(stat, value)
    if (self.baseStats[stat] - value < 0) then
        self.baseStats[stat] = 0
    else
        self.baseStats[stat] = self.baseStats[stat] - value
    end
    self.stats[stat] = self.baseStats[stat]
end


function Player:plusPoints(points)
    if (self.points + points > 100) then
        self.points = 100
    else
        self.points = self.points + points
    end
end


function Player:minusPoints(points)
    if (self.points - points < 0) then
        self.points = 0
    else
        self.points = self.points - points
    end
end


function Player:updateSubStats()
    -- Referencia directa a los stats base para mejor legibilidad
    local str = self.stats.strength
    local agi = self.stats.agility
    local dex = self.stats.dexterity
    local int = self.stats.intelligence
    local vit = self.stats.vitality
--print("Sumando ", (1 * vit), " y ", self.equipmentStatBonuss.defense)
    -- Actualización completa de todos los subStats
    self.subStats = {
        attack = (1 * str) + (0.5 * agi) + self.equipmentStatBonuss.attack,
        mAttack = (1 * int) + (0.5 * dex) + self.equipmentStatBonuss.mAttack,
        defense = (1 * vit) + self.equipmentStatBonuss.defense,
        mDefense = (1 * vit) + (0.5 * int) + self.equipmentStatBonuss.mDefense,
        speed = (1 * agi) + (0.5 * dex) + self.equipmentStatBonuss.speed,
        dodge = (0.5 * agi) + (0.5 * dex) + self.equipmentStatBonuss.dodge,

        hit = (1 * dex) + self.equipmentStatBonuss.hit,
        crit = (0.5 * str) + (0.5 * dex) + self.equipmentStatBonuss.crit,
        healthRegen = (0.5 * vit) + self.equipmentStatBonuss.healthRegen,
        manaRegen = (0.5 * int) + self.equipmentStatBonuss.manaRegen,
        hungerDecay = (0.25 * str) + (0.25 * agi) + self.equipmentStatBonuss.hungerDecay,
        sleepDecay = (0.25 * str) + (0.25 * agi) + self.equipmentStatBonuss.sleepDecay
    }
end

---------------------------------------------------------------------------
-- equipmen

function Player:equipItem(itemName, slot)
    local itemData = Utils:GetItemData(itemName)
    if not itemData then
        print("Error: El ítem '"..itemName.."' no existe.")
        return
    end

    -- Verificar slot válido
    local validSlots = {
        ["lHand"] = "weapon",
        ["rHand"] = "weapon",
        ["head"] = "armor",
        ["body"] = "armor",
        ["feet"] = "armor",
        ["accesory1"] = "armor",
        ["accesory2"] = "armor"
    }

    if validSlots[slot] ~= itemData.type then
        print("Error: No puedes equipar '"..itemName.."' en '"..slot.."'.")
        return
    end

    -- Desequipar item actual si hay uno
    if self.equipment[slot] then
        local oldItemData = Utils:GetItemData(self.equipment[slot])
        if oldItemData then
            self:removeEquipEffects(oldItemData)
        end
    end

    -- Equipar nuevo item
    self.equipment[slot] = itemName
    self:applyEquipEffects(itemData)
    self:removeItemFromInventory(itemName, 1)
end


function Player:unequipItem(slot)
    local itemName = self.equipment[slot]
    if not itemName then
        print("Error: No hay nada equipado en '"..slot.."'.")
        return
    end

    local itemData = Utils:GetItemData(itemName)
    if itemData then
        self:removeEquipEffects(itemData)
    end

    self.equipment[slot] = nil
    self:addItemToInventory(itemName, 1)
end


function Player:applyEquipEffects(itemData)
    self:processEquipEffects(itemData, function(value, stat)
        return value
    end)
end

function Player:removeEquipEffects(itemData)
    self:processEquipEffects(itemData, function(value, stat)
        return -value
    end)
end

function Player:processEquipEffects(itemData, operation)
    if not itemData or not itemData.effectTags then return end
    
    -- Mapeo de efectos a propiedades y operaciones
    local effectHandlers = {
        -- Stats base
        { pattern = "(%d+) STR",     field = "stats.strength" },
        { pattern = "(%d+) AGI",     field = "stats.agility" },
        { pattern = "(%d+) DEX",     field = "stats.dexterity" },
        { pattern = "(%d+) INT",     field = "stats.intelligence" },
        { pattern = "(%d+) VIT",     field = "stats.vitality" },
        
        -- SubStats
        { pattern = "(%d+) DMG",     field = "equipmentStatBonuss.attack" },
        { pattern = "(%d+) MATK",    field = "equipmentStatBonuss.mAttack" },
        { pattern = "(%d+) DEF",     field = "equipmentStatBonuss.defense" },
        { pattern = "(%d+) MDEF",    field = "equipmentStatBonuss.mDefense" },
        { pattern = "(%d+) SPEED",   field = "equipmentStatBonuss.speed" },
        { pattern = "(%d+) DODGE",   field = "equipmentStatBonuss.dodge" },
        { pattern = "(%d+) HIT",     field = "equipmentStatBonuss.hit" },
        { pattern = "(%d+) CRIT",    field = "equipmentStatBonuss.crit" },
        { pattern = "(%d+) HEALTHR", field = "equipmentStatBonuss.healthRegen" },
        { pattern = "(%d+) MANAR",   field = "equipmentStatBonuss.manaRegen" },
        
        -- Atributos especiales
        { pattern = "(%d+) MAXHEALTH", method = "plusMaxHealth" },
        { pattern = "(%d+) MAXMANA",   method = "plusMaxMana" }
    }

    for _, effect in ipairs(itemData.effectTags) do
        for _, handler in ipairs(effectHandlers) do
            local value = effect:match(handler.pattern)
            if value then
                value = tonumber(value)
                if handler.field then
                    -- Acceso a propiedades anidadas usando string.split
                    local parts = handler.field:split(".")
                    local obj = self
                    for i = 1, #parts - 1 do
                        obj = obj[parts[i]]
                    end
                    obj[parts[#parts]] = obj[parts[#parts]] + operation(value)
                elseif handler.method then
                    self[handler.method](self, operation(value))
                end
            end
        end
    end
    
    self:updateSubStats()
end



---------------------------------------------------------------------------
-- inventory

function Player:addItemToInventory(itemName, quantity)
    self.inventory = self.inventory or {}
    local current = self.inventory[itemName] or 0
    
    if current + quantity > 99 then
        print("Límite de stack alcanzado para "..itemName.." (99)")
        return false
    end
    
    if current == 0 and self:countInventoryItems() >= 24 then
        print("Inventario lleno (24 slots máx.)")
        return false
    end
    
    self.inventory[itemName] = current + quantity
    self:discoverRecipes()
    return true
end

function Player:countInventoryItems()
    local count = 0
    for _ in pairs(self.inventory) do count = count + 1 end
    return count
end

function Player:removeItemFromInventory(itemName, quantity)
    self.inventory = self.inventory or {}
    
    if not self.inventory[itemName] then
        print("Objeto no encontrado: "..itemName)
        return false
    end
    
    if self.inventory[itemName] < quantity then
        print("Cantidad insuficiente de "..itemName)
        return false
    end
    
    self.inventory[itemName] = self.inventory[itemName] - quantity
    if self.inventory[itemName] <= 0 then self.inventory[itemName] = nil end
    return true
end


function Player:useItem(itemName)
    local itemData = Utils:GetItemData(itemName)
    if not itemData or itemData.type ~= "consumable" then return false end
    
    -- Procesar efectos
    for _, effect in ipairs(itemData.effectTags) do
        local value = effect:match("(%d+) HP")
        if value then
            self:plusHealth(tonumber(value))
        end
        
        value = effect:match("(%d+) MANA")
        if value then
            self:plusMana(tonumber(value))
        end
        
        -- Puedes añadir más efectos aquí
    end
    
    -- Eliminar un ítem del inventario
    return self:removeItemFromInventory(itemName, 1)
end

---------------------------------------------------------------------------
-- process

function Player:discoverRecipes()
    local allRecipes = {}
    -- Combinar todas las recetas de BD
    for _, category in ipairs({BD.cons_recipes or {}, BD.weapon_recipes or {}, BD.armor_recipes or {}}) do
        for _, recipe in ipairs(category) do
            table.insert(allRecipes, recipe)
        end
    end

    for _, recipe in ipairs(allRecipes) do
        local alreadyKnown = false
        -- Verificar si ya la conocemos
        for _, knownRecipe in ipairs(self.recipes) do
            if knownRecipe.name == recipe.name then
                alreadyKnown = true
                break
            end
        end

        if not alreadyKnown then
            local hasAnyIngredient = false
            -- Verificar si tenemos ALGUNO de los ingredientes
            for _, ingredient in ipairs(recipe.ingredients) do
                local quantity, itemName = ingredient:match("(%d+) (.+)")
                quantity = tonumber(quantity)
                
                if self.inventory[itemName] and self.inventory[itemName] >= 1 then
                    hasAnyIngredient = true
                    break
                end
            end

            if hasAnyIngredient then
                print("Receta desbloqueada:", recipe.name)
                table.insert(self.recipes, recipe)
            end
        end
    end
end


-- Método para verificar ingredientes
function Player:hasIngredients(recipe)
    for _, ingredient in ipairs(recipe.ingredients) do
        local quantity, itemName = ingredient:match("(%d+) (.+)")
        quantity = tonumber(quantity)
        if not self.inventory[itemName] or self.inventory[itemName] < quantity then
            return false
        end
    end
    return true
end

function Player:executeRecipe(recipe)
    -- Verificar que tenemos todos los ingredientes
    if not self:hasIngredients(recipe) then
        return false, "No tienes todos los ingredientes necesarios"
    end
    
    -- Eliminar los ingredientes
    for _, ingredient in ipairs(recipe.ingredients) do
        local quantity, itemName = ingredient:match("(%d+) (.+)")
        quantity = tonumber(quantity)
        self:removeItemFromInventory(itemName, quantity)
    end
    
    -- Añadir el item resultante
    local resultItemName = recipe.name:gsub(" Recipe", "")
    
    -- Si el item ya existe en el inventario, solo incrementamos su cantidad
    if self.inventory[resultItemName] then
        local success = self:addItemToInventory(resultItemName, 1)
        if not success then
            -- Si falla al incrementar, devolvemos los ingredientes
            for _, ingredient in ipairs(recipe.ingredients) do
                local quantity, itemName = ingredient:match("(%d+) (.+)")
                quantity = tonumber(quantity)
                self:addItemToInventory(itemName, quantity)
            end
            return false, "No hay espacio en el inventario"
        end
        return true, "¡Receta completada!"
    end
    
    -- Si es un item nuevo, verificamos si hay espacio en el inventario
    if self:countInventoryItems() >= 24 then
        -- Si no hay espacio, devolvemos los ingredientes
        for _, ingredient in ipairs(recipe.ingredients) do
            local quantity, itemName = ingredient:match("(%d+) (.+)")
            quantity = tonumber(quantity)
            self:addItemToInventory(itemName, quantity)
        end
        return false, "Inventario lleno (24 slots máx.)"
    end
    
    -- Si hay espacio, procedemos a añadir el item nuevo
    local itemData = Utils:GetItemData(resultItemName)
    if not itemData then
        -- Si no encontramos el item, devolvemos los ingredientes
        for _, ingredient in ipairs(recipe.ingredients) do
            local quantity, itemName = ingredient:match("(%d+) (.+)")
            quantity = tonumber(quantity)
            self:addItemToInventory(itemName, quantity)
        end
        return false, "Error: Item resultante no encontrado"
    end
    
    -- Encontrar el sprite más alto usado en el inventario
    local maxSpriteY = 0
    local maxSpriteX = 0
    for name, _ in pairs(self.inventory) do
        local data = Utils:GetItemData(name)
        if data and data.spr then
            if data.spr[2] > maxSpriteY then
                maxSpriteY = data.spr[2]
                maxSpriteX = data.spr[1]
            elseif data.spr[2] == maxSpriteY and data.spr[1] > maxSpriteX then
                maxSpriteX = data.spr[1]
            end
        end
    end
    
    -- Guardar temporalmente el sprite original
    local originalSpr = itemData.spr
    
    -- Temporalmente modificar el sprite solo para este item
    itemData.spr = {maxSpriteX + 1, maxSpriteY}
    
    -- Añadir el item
    local success = self:addItemToInventory(resultItemName, 1)
    
    -- Restaurar el sprite original
    itemData.spr = originalSpr
    
    if not success then
        -- Si falla al añadir, devolvemos los ingredientes
        for _, ingredient in ipairs(recipe.ingredients) do
            local quantity, itemName = ingredient:match("(%d+) (.+)")
            quantity = tonumber(quantity)
            self:addItemToInventory(itemName, quantity)
        end
        return false, "Error al añadir el item"
    end
    
    return true, "¡Receta completada!"
end





return Player