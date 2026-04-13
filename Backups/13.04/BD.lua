local BD = {}

-- ITEMS
BD.weapons = {
    {name = "Knife", type = "weapon", subType = "oneHanded", effectTags = {"1 DMG"}, price = 80, description = "A basic knife.", spr = {0, 0}},
    {name = "Katana", type = "weapon", subType = "oneHanded", effectTags = {"2 DMG"}, price = 100, description = "A basic katana.", spr = {1, 0}},
    {name = "Falchion", type = "weapon", subType = "oneHanded", effectTags = {"4 DMG"}, price = 120, description = "A basic falchion.", spr = {2, 0}},
    {name = "Sword", type = "weapon", subType = "oneHanded", effectTags = {"3 DMG"}, price = 100, description = "A basic sword.", spr = {3, 0}},
    {name = "Greatsword", type = "weapon", subType = "twoHanded", effectTags = {"5 DMG"}, price = 150, description = "A basic greatsword.", spr = {4, 0}},

    {name = "Hatchet", type = "weapon", subType = "oneHanded", effectTags = {"1 DMG"}, price = 80, description = "A basic hatchet.", spr = {5, 0}},
    {name = "Axe", type = "weapon", subType = "oneHanded", effectTags = {"4 DMG"}, price = 120, description = "A basic axe.", spr = {6, 0}},

    {name = "Flail", type = "weapon", subType = "oneHanded", effectTags = {"2 DMG"}, price = 100, description = "A basic flail.", spr = {7, 0}},
    {name = "Mace", type = "weapon", subType = "oneHanded", effectTags = {"3 DMG"}, price = 120, description = "A basic mace.", spr = {8, 0}},
    {name = "Hammer", type = "weapon", subType = "oneHanded", effectTags = {"4 DMG"}, price = 150, description = "A basic hammer.", spr = {9, 0}},
    {name = "Spear", type = "weapon", subType = "oneHanded", effectTags = {"2 DMG"}, price = 100, description = "A basic spear.", spr = {10, 0}},

    ----------------------------------------------------------------------------------------------------------------------------------------------------------

    {name = "Slingshot", type = "weapon", subType = "oneHanded", effectTags = {"1 DMG", "Ranged"}, price = 80, description = "A basic slingshot.", spr = {0, 1}},
    {name = "Bow", type = "weapon", subType = "oneHanded", effectTags = {"3 DMG", "Ranged"}, price = 100, description = "A basic bow.", spr = {1, 1}},
    {name = "Crossbow", type = "weapon", subType = "oneHanded", effectTags = {"4 DMG", "Ranged"}, price = 120, description = "A basic crossbow.", spr = {2, 1}},

    {name = "Rod", type = "weapon", subType = "oneHanded", effectTags = {"1 DMG", "1 INT"}, price = 120, description = "A basic rod.", spr = {3, 1}},
}

BD.armor = {
    {name = "Leather cap", type = "armor", subType = "head", effectTags = {"1 DEF"}, price = 50, description = "A basic cap.", spr = {0, 2}},
    {name = "Leather coif", type = "armor", subType = "head", effectTags = {"2 DEF"}, price = 50, description = "A basic coif.", spr = {1, 2}},

    {name = "Skullcap", type = "armor", subType = "head", effectTags = {"3 DEF"}, price = 50, description = "A basic skullcap.", spr = {2, 2}},
    {name = "Iron helmet", type = "armor", subType = "head", effectTags = {"4 DEF"}, price = 50, description = "An helmet.", spr = {3, 2}},
    {name = "Steel helmet", type = "armor", subType = "head", effectTags = {"5 DEF"}, price = 50, description = "A steel helmet.", spr = {4, 2}},

    ----------------------------------------------------------------------------------------------------------------------------------------------------------

    {name = "Linen shirt", type = "armor", subType = "body", effectTags = {"1 DEF"}, price = 50, description = "A basic shirt.", spr = {0, 3}},
    {name = "Leather shirt", type = "armor", subType = "body", effectTags = {"2 DEF"}, price = 50, description = "A basic shirt.", spr = {1, 3}},

    {name = "Spaulders", type = "armor", subType = "body", effectTags = {"3 DEF"}, price = 50, description = "A basic spaulder.", spr = {2, 3}},
    {name = "Iron Chestplate", type = "armor", subType = "body", effectTags = {"3 DEF"}, price = 100, description = "A basic chestplate.", spr = {3, 3}},
    {name = "Steel Chestplate", type = "armor", subType = "body", effectTags = {"4 DEF"}, price = 100, description = "An iron chestplate.", spr = {4, 3}},

    ----------------------------------------------------------------------------------------------------------------------------------------------------------

    {name = "Leather sandals", type = "armor", subType = "feet", effectTags = {"1 DEF"}, price = 30, description = "A pair of sandals.", spr = {0, 4}},
    {name = "Leather boots", type = "armor", subType = "feet", effectTags = {"1 DEF"}, price = 30, description = "A basic pair of boots.", spr = {1, 4}},
    {name = "Iron boots", type = "armor", subType = "feet", effectTags = {"2 DEF"}, price = 30, description = "A pair of iron boots.", spr = {2, 4}},
    {name = "Steel boots", type = "armor", subType = "feet", effectTags = {"3 DEF"}, price = 30, description = "A pair of steel boots.", spr = {3, 4}},

    {name = "Ruby pendant", type = "armor", subType = "accesory", effectTags = {"2 STR"}, price = 120, description = "A rubi pendant", spr = {0, 5}},
    {name = "Emerald pendant", type = "armor", subType = "accesory", effectTags = {"2 AGI"}, price = 120, description = "An Emerald pendant", spr = {1, 5}},
    {name = "Sapphire pendant", type = "armor", subType = "accesory", effectTags = {"2 DEX"}, price = 120, description = "A Sapphire pendant", spr = {2, 5}},
    {name = "Amethyst pendant", type = "armor", subType = "accesory", effectTags = {"2 INT"}, price = 120, description = "An Amethyst pendant", spr = {3, 5}},
    {name = "Topaz pendant", type = "armor", subType = "accesory", effectTags = {"2 VIT"}, price = 120, description = "A Topaz pendant", spr = {4, 5}},

    {name = "Ruby necklance", type = "armor", subType = "accesory", effectTags = {"4 STR"}, price = 200, description = "A rubi necklance", spr = {5, 5}},
    {name = "Emerald necklance", type = "armor", subType = "accesory", effectTags = {"4 AGI"}, price = 200, description = "An Emerald necklance", spr = {6, 5}},
    {name = "Sapphire necklance", type = "armor", subType = "accesory", effectTags = {"4 DEX"}, price = 200, description = "A Sapphire necklance", spr = {7, 5}},
    {name = "Amethyst necklance", type = "armor", subType = "accesory", effectTags = {"4 INT"}, price = 200, description = "An Amethyst necklance", spr = {8, 5}},
    {name = "Topaz necklance", type = "armor", subType = "accesory", effectTags = {"4 VIT"}, price = 200, description = "A Topaz necklance", spr = {9, 5}},
}

BD.consumables = {
    {name = "Health Potion", type = "consumable", subType = "potion", effectTags = {"50 HP"}, price = 25, description = "Restores health.", spr = {0, 6}},
    {name = "Mana Potion", type = "consumable", subType = "potion", effectTags = {"50 MANA"}, price = 30, description = "Restores mana.", spr = {1, 6}},
    {name = "Green Potion", type = "consumable", subType = "potion", effectTags = {"25 HP", "25 MANA"}, price = 50, description = "???", spr = {2, 6}},
    {name = "Yellow Potion", type = "consumable", subType = "potion", effectTags = {"25 HP", "25 MANA"}, price = 50, description = "???", spr = {3, 6}},
    {name = "Coffe", type = "consumable", subType = "food", effectTags = {"25 SLEEP"}, price = 10, description = "Restores sleepyness", spr = {4, 6}},

    {name = "Mushroom", type = "consumable", subType = "food", effectTags = {"1 HP, 2 HUNG"}, price = 10, description = "A brown mushroom.", spr = {5, 6}},
    {name = "Cherry", type = "consumable", subType = "food", effectTags = {"2 HP, 4 HUNG"}, price = 10, description = "A red cherry.", spr = {6, 6}},
    {name = "Carrot", type = "consumable", subType = "food", effectTags = {"3 HP, 6 HUNG"}, price = 10, description = "A orange carrot.", spr = {7, 6}},
    {name = "Apple", type = "consumable", subType = "food", effectTags = {"4 HP, 8 HUNG"}, price = 10, description = "A red apple.", spr = {8, 6}},
    {name = "Cheese", type = "consumable", subType = "food", effectTags = {"5 HP, 10 HUNG"}, price = 10, description = "A piece of cheese.", spr = {9, 6}},
    {name = "Bread", type = "consumable", subType = "food", effectTags = {"5 HP, 15 HUNG"}, price = 10, description = "A piece of bread.", spr = {10, 6}},
    {name = "Fish", type = "consumable", subType = "food", effectTags = {"5 HP, 15 HUNG"}, price = 10, description = "A piece of fish.", spr = {11, 6}},
    {name = "Sausage", type = "consumable", subType = "food", effectTags = {"10 HP, 25 HUNG"}, price = 10, description = "A piece of sausage.", spr = {12, 6}},
    {name = "Turkey", type = "consumable", subType = "food", effectTags = {"20 HP, 40 HUNG"}, price = 10, description = "A piece of turkey.", spr = {13, 6}},

    {name = "Cheese whipping", type = "consumable", subType = "food", effectTags = {"25 HP, 40 HUNG"}, price = 10, description = "A cheese whippin.", spr = {14, 6}},
    {name = "Sausage whipping", type = "consumable", subType = "food", effectTags = {"25 HP, 40 HUNG"}, price = 10, description = "A sausage whippin.", spr = {15, 6}},
    {name = "Vegetable soup", type = "consumable", subType = "food", effectTags = {"25 HP, 75 HUNG"}, price = 10, description = "A vegetable soup.", spr = {16, 6}},
    {name = "Meat soup", type = "consumable", subType = "food", effectTags = {"30 HP, 90 HUNG"}, price = 10, description = "A meat soup.", spr = {17, 6}},
}

BD.misc = {
    {name = "Rock", type = "misc", subType = "", effectTags = {}, price = 1, description = "A basic rock", spr = {0, 7}},
    {name = "Copper ore", type = "misc", subType = "", effectTags = {}, price = 15, description = "A copper ore", spr = {1, 7}},
    {name = "Iron ore", type = "misc", subType = "", effectTags = {}, price = 15, description = "An iron ore", spr = {2, 7}},
    {name = "Silver ore", type = "misc", subType = "", effectTags = {}, price = 25, description = "A silver ore", spr = {3, 7}},
    {name = "Gold ore", type = "misc", subType = "", effectTags = {}, price = 25, description = "A gold ore", spr = {4, 7}},

    {name = "Copper ingot", type = "misc", subType = "", effectTags = {}, price = 30, description = "A copper ingot", spr = {5, 7}},
    {name = "Iron ingot", type = "misc", subType = "", effectTags = {}, price = 30, description = "An iron ingot", spr = {6, 7}},
    {name = "Steel ingot", type = "misc", subType = "", effectTags = {}, price = 50, description = "A steel ingot", spr = {7, 7}},
    {name = "Silver ingot", type = "misc", subType = "", effectTags = {}, price = 150, description = "A silver ingot", spr = {8, 7}},
    {name = "Gold ingot", type = "misc", subType = "", effectTags = {}, price = 200, description = "A gold ingot", spr = {9, 7}},

    {name = "Ruby", type = "misc", subType = "", effectTags = {}, price = 50, description = "A red gem.", spr = {10, 7}},
    {name = "Emerald", type = "misc", subType = "", effectTags = {}, price = 50, description = "A green gem.", spr = {11, 7}},
    {name = "Sapphire", type = "misc", subType = "", effectTags = {}, price = 50, description = "A blue gem.", spr = {12, 7}},
    {name = "Amethyst", type = "misc", subType = "", effectTags = {}, price = 50, description = "A purple gem.", spr = {13, 7}},
    {name = "Topaz", type = "misc", subType = "", effectTags = {}, price = 50, description = "A yellow gem.", spr = {14, 7}},
    {name = "Diamond", type = "misc", subType = "", effectTags = {}, price = 300, description = "A clear gem.", spr = {15, 7}},
    
    {name = "Stick", type = "misc", subType = "", effectTags = {}, price = 1, description = "A stick", spr = {16, 7}},
    {name = "Wood", type = "misc", subType = "", effectTags = {}, price = 10, description = "Piece of wood", spr = {17, 7}},

    {name = "Glass jar", type = "misc", subType = "", effectTags = {}, price = 10, description = "A glass jar", spr = {18, 7}},
    {name = "Red herb", type = "misc", subType = "", effectTags = {}, price = 5, description = "A red herb", spr = {19, 7}},
    {name = "Blue herb", type = "misc", subType = "", effectTags = {}, price = 5, description = "A blue herb", spr = {20, 7}},
    {name = "Green herb", type = "misc", subType = "", effectTags = {}, price = 5, description = "A green herb", spr = {21, 7}},
    {name = "Yellow herb", type = "misc", subType = "", effectTags = {}, price = 5, description = "A yellow herb", spr = {22, 7}},
    {name = "Coffe bean", type = "misc", subType = "", effectTags = {}, price = 5, description = "A coffe bean", spr = {23, 7}},

    {name = "Leather", type = "misc", subType = "", effectTags = {}, price = 10, description = "A piece of leather", spr = {24, 7}},
    {name = "Linen", type = "misc", subType = "", effectTags = {}, price = 10, description = "A piece of linen", spr = {25, 7}},

}

---------------------------------------------------------------------------

-- RECIPES

-- consumables
BD.cons_recipes = {
    -- health potion recipe
    {name = "Health Potion Recipe", ingredients = {"1 Glass jar", "1 Red herb"}, type = "potion", description = "Recipe to create a health potion."},
    -- mana potion recipe
    {name = "Mana Potion Recipe", ingredients = {"1 Glass jar", "1 Blue herb"}, type = "potion", description = "Recipe to create a mana potion."},
    -- green potion recipe
    {name = "Green Potion Recipe", ingredients = {"1 Glass jar", "1 Green herb"}, type = "potion", description = "Recipe to create a green potion."},
    -- yellow potion recipe
    {name = "Yellow Potion Recipe", ingredients = {"1 Glass jar", "1 Yellow herb"}, type = "potion", description = "Recipe to create a yellow potion."},
    -- coffe recipe
    {name = "Coffe Recipe", ingredients = {"1 Glass jar", "1 Coffe bean"}, type = "potion", description = "Recipe to create a coffe."},
    -- Cheese whipping recipe
    {name = "Cheese whipping Recipe", ingredients = {"1 Bread", "1 Cheese"}, type = "potion", description = "Recipe to create a cheese whipping."},
    -- Sausage whipping recipe
    {name = "Sausage whipping Recipe", ingredients = {"1 Bread", "1 Sausage"}, type = "potion", description = "Recipe to create a sausage whipping."},
    -- Vegetable soup recipe
    {name = "Vegetable soup Recipe", ingredients = {"1 Glass jar", "1 Mushroom", "1 Carrot"}, type = "potion", description = "Recipe to create a vegetable soup."},
    -- Meat soup recipe
    {name = "Meat soup Recipe", ingredients = {"1 Glass jar", "1 Carrot", "1 Turkey"}, type = "potion", description = "Recipe to create a meat soup."},
}

-- weapons
BD.weapon_recipes = {
    -- sword recipe
    {name = "Knife Recipe", ingredients = {"1 Iron ingot", "1 Wood"}, type = "weapon", description = "Recipe to create a knife."},
    -- axe recipe
    {name = "Katana Recipe", ingredients = {"2 Iron ingot", "1 Wood"}, type = "weapon", description = "Recipe to create a katana."},
    -- falchion recipe
    {name = "Falchion Recipe", ingredients = {"3 Iron ingot", "1 Wood"}, type = "weapon", description = "Recipe to create a falchion."},
    -- sword recipe
    {name = "Sword Recipe", ingredients = {"4 Iron ingot", "1 Wood"}, type = "weapon", description = "Recipe to create a sword."},
    -- greatsword recipe
    {name = "Greatsword Recipe", ingredients = {"5 Iron ingot", "1 Wood"}, type = "weapon", description = "Recipe to create a greatsword."},

    -- hatchet recipe
    {name = "Hatchet Recipe", ingredients = {"1 Iron ingot", "2 Wood"}, type = "weapon", description = "Recipe to create a hatchet."},
    -- axe recipe
    {name = "Axe Recipe", ingredients = {"2 Iron ingot", "2 Wood"}, type = "weapon", description = "Recipe to create an axe."},
    
    -- flail recipe
    {name = "Flail Recipe", ingredients = {"3 Iron ingot", "2 Wood"}, type = "weapon", description = "Recipe to create a flail."},
    -- mace recipe
    {name = "Mace Recipe", ingredients = {"4 Iron ingot", "2 Wood"}, type = "weapon", description = "Recipe to create a mace."},
    -- hammer recipe
    {name = "Hammer Recipe", ingredients = {"5 Iron ingot", "2 Wood"}, type = "weapon", description = "Recipe to create a hammer."},
    -- spear recipe
    {name = "Spear Recipe", ingredients = {"2 Iron ingot", "3 Wood"}, type = "weapon", description = "Recipe to create a spear."},

}

-- armor 
BD.armor_recipes = {
    -- Leather cap recipe
    {name = "Leather cap Recipe", ingredients = {"1 Leather"}, type = "armor", description = "Recipe to create a leather cap."},
    -- Leather coif recipe
    {name = "Leather coif Recipe", ingredients = {"2 Leather"}, type = "armor", description = "Recipe to create a leather coif."},
    -- Skullcap recipe
    {name = "Skullcap Recipe", ingredients = {"1 Iron ingot"}, type = "armor", description = "Recipe to create a skullcap."},
    -- Iron helmet recipe
    {name = "Iron helmet Recipe", ingredients = {"2 Iron ingot"}, type = "armor", description = "Recipe to create an iron helmet."},
    -- Steel helmet recipe
    {name = "Steel helmet Recipe", ingredients = {"1 Steel ingot"}, type = "armor", description = "Recipe to create a steel helmet."},

    -- Linen shirt recipe
    {name = "Linen shirt Recipe", ingredients = {"1 Linen"}, type = "armor", description = "Recipe to create a linen shirt."},
    -- Leather shirt recipe
    {name = "Leather shirt Recipe", ingredients = {"3 Leather"}, type = "armor", description = "Recipe to create a leather shirt."},
    -- Spaulders recipe
    {name = "Spaulders Recipe", ingredients = {"1 Iron ingot", "1 Leather"}, type = "armor", description = "Recipe to create a spaulder."},
    -- Iron Chestplate recipe
    {name = "Iron Chestplate Recipe", ingredients = {"2 Iron ingot", "1 Leather"}, type = "armor", description = "Recipe to create an iron chestplate."},
    -- Steel Chestplate recipe
    {name = "Steel Chestplate Recipe", ingredients = {"2 Steel ingot", "1 Leather"}, type = "armor", description = "Recipe to create a steel chestplate."},

    -- Leather sandals recipe
    {name = "Leather sandals Recipe", ingredients = {"2 Leather"}, type = "armor", description = "Recipe to create a pair of sandals."},
    -- Leather boots recipe
    {name = "Leather boots Recipe", ingredients = {"3 Leather"}, type = "armor", description = "Recipe to create a pair of boots."},
    -- Iron boots recipe
    {name = "Iron boots Recipe", ingredients = {"1 Iron ingot", "1 Leather"}, type = "armor", description = "Recipe to create a pair of iron boots."},
    -- Steel boots recipe
    {name = "Steel boots Recipe", ingredients = {"1 Steel ingot", "1 Leather"}, type = "armor", description = "Recipe to create a pair of steel boots."},

    -- Ruby pendant recipe
    {name = "Ruby pendant Recipe", ingredients = {"1 Silver ingot", "1 Ruby"}, type = "armor", description = "Recipe to create a ruby pendant."},
    -- Emerald pendant recipe
    {name = "Emerald pendant Recipe", ingredients = {"1 Silver ingot", "1 Emerald"}, type = "armor", description = "Recipe to create an emerald pendant."},
    -- Sapphire pendant recipe
    {name = "Sapphire pendant Recipe", ingredients = {"1 Silver ingot", "1 Sapphire"}, type = "armor", description = "Recipe to create a sapphire pendant."},
    -- Amethyst pendant recipe
    {name = "Amethyst pendant Recipe", ingredients = {"1 Silver ingot", "1 Amethyst"}, type = "armor", description = "Recipe to create an amethyst pendant."},
    -- Topaz pendant recipe
    {name = "Topaz pendant Recipe", ingredients = {"1 Silver ingot", "1 Topaz"}, type = "armor", description = "Recipe to create a topaz pendant."},

    -- Ruby necklance recipe
    {name = "Ruby necklance Recipe", ingredients = {"2 Silver ingot", "1 Ruby"}, type = "armor", description = "Recipe to create a ruby necklance."},
    -- Emerald necklance recipe
    {name = "Emerald necklance Recipe", ingredients = {"2 Silver ingot", "1 Emerald"}, type = "armor", description = "Recipe to create an emerald necklance."},
    -- Sapphire necklance recipe
    {name = "Sapphire necklance Recipe", ingredients = {"2 Silver ingot", "1 Sapphire"}, type = "armor", description = "Recipe to create a sapphire necklance."},
    -- Amethyst necklance recipe
    {name = "Amethyst necklance Recipe", ingredients = {"2 Silver ingot", "1 Amethyst"}, type = "armor", description = "Recipe to create an amethyst necklance."},
    -- Topaz necklance recipe
    {name = "Topaz necklance Recipe", ingredients = {"2 Silver ingot", "1 Topaz"}, type = "armor", description = "Recipe to create a topaz necklance."},

}

-- misc


---------------------------------------------------------------------------

-- ENEMIES

-- tier 1
BD.tier1_enemies = {
    -- rat
    {name = "Rat", health = 15, attack = 3, defense = 1, experience = 8, description = "A small rodent."},
    -- goblin
    {name = "Goblin", health = 20, attack = 5, defense = 2, experience = 10, description = "A small green creature."},
}

-- tier 2
BD.tier2_enemies = {
    -- wolf
    {name = "Wolf", health = 30, attack = 7, defense = 3, experience = 15, description = "A wild wolf."},
    -- bandit
    {name = "Bandit", health = 25, attack = 6, defense = 2, experience = 12, description = "A rogue thief."},
}

-- tier 3
BD.tier3_enemies = {
    -- bear
    {name = "Bear", health = 50, attack = 10, defense = 5, experience = 25, description = "A large bear."},
    -- orc
    {name = "Orc", health = 40, attack = 8, defense = 4, experience = 20, description = "A brutish creature."},
}

-- boses
BD.bosses = {
    -- dragon
    {name = "Dragon", health = 100, attack = 15, defense = 10, experience = 50, description = "A fierce dragon."},
    -- demon
    {name = "Demon", health = 80, attack = 12, defense = 8, experience = 40, description = "A dark demon."},
}

---------------------------------------------------------------------------

-- SKILLS

-- active
BD.active_skills = {
    -- fireball
    {name = "Fireball", effectTag = "50 DMG", mana_cost = 5, type = "magic", level = 1, description = "A powerful fire spell."},
    -- healing
    {name = "Healing", effectTag = "20 HP", mana_cost = 3, type = "magic", level = 1, description = "A healing spell."},
}

-- passive
BD.passive_skills = {
    -- night vision
    {name = "Night Vision", effectTag = "see in dark", type = "passive", level = 1, description = "Allows you to see in the dark."},
    -- stealth
    {name = "Stealth", effectTag = "avoid detection", type = "passive", level = 1, description = "Allows you to move undetected."},
}


---------------------------------------------------------------------------

-- TEXT

-- intro


-- dialogues


-- options


-- gameplay

---------------------------------------------------------------------------
-- SKILLS DATABASE

BD.skills = {
    -- ==================== ÁRBOL FÍSICO (Naranja) ====================
    {
        id = 1,
        name = "Golpe Fuerte",
        tree = "physical",
        treeColumn = 0,
        gridRow = 0,
        spriteX = 0, 
        spriteY = 0,
        type = "active",
        manaCost = 5,
        description = "Golpe fisico\npotente",
        requiredLevel = 1,
        requiredSkill = nil,
        damageMultiplier = 1.5,
        damageType = "physical"
    },
    
    {
        id = 2,
        name = "Fuerza Bruta",
        tree = "physical",
        treeColumn = 0,
        gridRow = 1,
        spriteX = 1, 
        spriteY = 0,
        type = "passive",
        manaCost = 0,
        description = "+10 ATK\npermanente",
        requiredLevel = 2,
        requiredSkill = 1,
        statBonus = {attack = 10}
    },
    
    {
        id = 3,
        name = "Corte Giratorio",
        tree = "physical",
        treeColumn = 0,
        gridRow = 2,
        spriteX = 2, 
        spriteY = 0,
        type = "active",
        manaCost = 10,
        description = "Golpe giratorio\ncon sangrado",
        requiredLevel = 4,
        requiredSkill = 2,
        damageMultiplier = 2.0,
        damageType = "physical",
        applyDebuff = "bleeding"
    },
    
    -- ==================== ÁRBOL MÁGICO (Cian) ====================
    {
        id = 4,
        name = "Bola de Fuego",
        tree = "magic",
        treeColumn = 2,
        gridRow = 0,
        spriteX = 0, 
        spriteY = 2,
        type = "active",
        manaCost = 8,
        description = "Proyectil\nmagico basico",
        requiredLevel = 1,
        requiredSkill = nil,
        damageMultiplier = 1.3,
        damageType = "magical"
    },
    
    {
        id = 5,
        name = "Mente Aguda",
        tree = "magic",
        treeColumn = 2,
        gridRow = 1,
        spriteX = 1, 
        spriteY = 2,
        type = "passive",
        manaCost = 0,
        description = "+10 mATK\npermanente",
        requiredLevel = 2,
        requiredSkill = 4,
        statBonus = {mAttack = 10}
    },
    
    {
        id = 6,
        name = "Rayo",
        tree = "magic",
        treeColumn = 2,
        gridRow = 2,
        spriteX = 2, 
        spriteY = 2,
        type = "active",
        manaCost = 12,
        description = "Descarga\nelectrica rapida",
        requiredLevel = 4,
        requiredSkill = 5,
        damageMultiplier = 1.8,
        damageType = "magical",
        applyDebuff = "stun"
    }
}

---------------------------------------------------------------------------
-- ENEMIES DATABASE

BD.enemies = {
    -- ==================== CAPÍTULO 0 ====================
    {
        id = 1,
        name = "Weak rat",
        spriteRow = 0,
        level = 1,
        health = 5,
        maxHealth = 5,
        mana = 10,
        maxMana = 10,
        stats = {
            strength = 1,
            agility = 2,
            dexterity = 0,
            intelligence = 0,
            vitality = 0
        },
        expReward = 8,
        goldReward = 5,
        itemDrops = {},
        aiPattern = "basic_physical"
    },
    
    {
        id = 2,
        name = "Rat",
        spriteRow = 0,
        level = 1,
        health = 10,
        maxHealth = 10,
        mana = 10,
        maxMana = 10,
        stats = {
            strength = 2,
            agility = 2,
            dexterity = 1,
            intelligence = 0,
            vitality = 0
        },
        expReward = 8,
        goldReward = 5,
        itemDrops = {},
        aiPattern = "balanced"
    },
    
    {
        id = 3,
        name = "Alpha Rat",
        spriteRow = 0,
        level = 4,
        health = 15,
        maxHealth = 15,
        mana = 25,
        maxMana = 25,
        stats = {
            strength = 2,
            agility = 3,
            dexterity = 1,
            intelligence = 0,
            vitality = 1
        },
        expReward = 75,
        goldReward = 25,
        itemDrops = {
            {name = "Health Potion", chance = 50}
        },
        aiPattern = "smart_aggressive"
    }
}

---------------------------------------------------------------------------

return BD