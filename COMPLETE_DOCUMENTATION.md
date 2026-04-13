# 🎮 RPG GAME - COMPLETE DOCUMENTATION

## 📋 Table of Contents
1. [System Architecture](#system-architecture)
2. [Database (BD.lua)](#database)
3. [Combat System](#combat-system)
4. [Skills System](#skills-system)
5. [Enemy System](#enemy-system)
6. [Chapter Engine](#chapter-engine)
7. [Formulas & Balancing](#formulas--balancing)
8. [User Guide](#user-guide)

---

## 🏗️ System Architecture

### File Structure

```
RPG game/
├── BD.lua                 # ✨ Centralized database (items, skills, enemies)
├── Player.lua             # Player system + hunger/sleep decay
├── Skill.lua              # Skills logic
├── Enemy.lua              # Enemies logic + AI
├── CombatSystem.lua       # 🆕 Turn-based combat logic
├── Chapters.lua           # Chapter data (events, narrative, branching)
├── Utils.lua              # Rendering functions
├── GameController.lua     # Main controller
└── img/
    └── (game sprites)
```

### Separation of Concerns

**✅ CORRECT Architecture:**

| Module | Responsibility | What it does | What it DOESN'T do |
|--------|---------------|--------------|-------------------|
| **BD.lua** | Data storage | Items, skills, enemies definitions | No logic |
| **Player.lua** | Player state & decay | Stats, inventory, hunger/sleep decay | No combat logic |
| **Skill.lua** | Skill logic | Learn, equip, execute skills | No combat turns |
| **Enemy.lua** | Enemy AI & behavior | AI patterns, decision making | No combat turns |
| **CombatSystem.lua** | Combat execution | Turn order, victory/defeat | No chapter data |
| **Chapters.lua** | Narrative structure | Events, branching, story flow | No combat logic |
| **Utils.lua** | Rendering | Draw UI, log messages | No game logic |
| **GameController.lua** | Orchestration | Connect all systems | Minimal logic |

### Data Flow

```
BD.lua (data storage)
   ↓
   ├─→ Skill.lua (reads BD.skills)
   ├─→ Enemy.lua (reads BD.enemies)
   └─→ Utils.lua (reads BD.items)
       ↓
GameController.lua (orchestrates)
   ↓
   ├─→ Chapters.lua (story events)
   ├─→ CombatSystem.lua (combat logic)
   └─→ Player.lua (player state)
       ↓
RetroGadgets (renders)
```

---

## 📊 Database (BD.lua)

**BD.lua** is the **ONLY place** where all game data is defined.

### Benefits:
- ✅ Single source of truth
- ✅ Easy to add content
- ✅ Simple balancing
- ✅ No code duplication

### BD.lua Content

| Table | Description | Quantity |
|-------|-------------|----------|
| `BD.weapons` | Equippable weapons | 14 items |
| `BD.armor` | Armors and accessories | 25 items |
| `BD.consumables` | Potions and food | 21 items |
| `BD.misc` | Resources and gems | 20 items |
| `BD.cons_recipes` | Consumable recipes | Multiple |
| `BD.weapon_recipes` | Weapon recipes | Multiple |
| `BD.armor_recipes` | Armor recipes | Multiple |
| `BD.skills_physical` | **Physical skill tree** | 3 skills |
| `BD.skills_magic` | **Magic skill tree** | 3 skills |
| `BD.skills` | **Combined skills list** | 6 skills (auto-generated) |
| `BD.enemies` | **Game enemies** | 3 enemies |

### Skills Fragmentation

```lua
-- Physical tree (separate list)
BD.skills_physical = {
    {id = 1, name = "Heavy Strike", ...},
    {id = 2, name = "Brute Force", ...},
    {id = 3, name = "Spinning Slash", ...}
}

-- Magic tree (separate list)
BD.skills_magic = {
    {id = 4, name = "Fireball", ...},
    {id = 5, name = "Sharp Mind", ...},
    {id = 6, name = "Lightning Bolt", ...}
}

-- Combined list (automatically generated)
BD.skills = {}
for _, skill in ipairs(BD.skills_physical) do
    table.insert(BD.skills, skill)
end
for _, skill in ipairs(BD.skills_magic) do
    table.insert(BD.skills, skill)
end
```

**Benefits:**
- ✅ Each tree in its own list
- ✅ Easy to add new trees (stealth, illusion, survival)
- ✅ Combined list for global queries
- ✅ Better organization

---

## ⚔️ Combat System

### CombatSystem.lua - Responsibilities

**CombatSystem.lua** handles ALL combat logic:

| Function | Responsibility |
|----------|---------------|
| `ExecuteTurn()` | Calculate initiative, execute turns |
| `ExecutePlayerAction()` | Process player skills/attacks |
| `HandleVictory()` | Give rewards, clear combat state |
| `HandleDefeat()` | Game over logic |

**Called by:** GameController.lua  
**Calls:** Player, Enemy, Skill, Utils

### Combat Flow

```
GameController detects combat action
   ↓
CombatSystem:ExecuteTurn(player, enemy, action)
   ↓
   ├─→ Calculate initiative (player vs enemy)
   ├─→ Execute turns in order
   ├─→ Check victory/defeat
   └─→ Apply hunger/sleep decay (via Player)
```

### Main Mechanics

#### **1. Initiative (Turn Order)**
```lua
playerInitiative = player.stats.SPEED + random(0, 10)
enemyInitiative = enemy.stats.SPEED + random(0, 10)

-- Highest initiative attacks first
```

#### **2. Accuracy (Hit vs Dodge)**
```lua
baseHitChance = 75%
hitChance = baseHitChance + (attacker.HIT - defender.DODGE)
hitChance = clamp(hitChance, 10%, 95%)
```

#### **3. Critical**
```lua
if random(1, 100) <= attacker.CRIT then
    damage = damage * 2
end
```

#### **4. Damage Calculation**
```lua
-- Physical Damage
baseDamage = attacker.ATK * skillMultiplier
finalDamage = max(1, baseDamage - defender.DEF)

-- Magic Damage
baseDamage = attacker.mATK * skillMultiplier
finalDamage = max(1, baseDamage - defender.mDEF)
```

### Available Debuffs

| Debuff | Effect | Duration |
|--------|--------|----------|
| **Bleeding** | 5% max HP/turn | 2 turns |
| **Stun** | Skip turn | 1 turn |

---

## 🎯 Skills System

### Skill Trees

The game has **2 independent skill trees**:

#### 🟠 **Physical Tree (Orange)**
```
Level 1: Heavy Strike (active, 1.5x damage)
         ↓
Level 2: Brute Force (passive, +10 ATK)
         ↓
Level 4: Spinning Slash (active, 2.0x damage + bleeding)
```

#### 🔵 **Magic Tree (Cyan)**
```
Level 1: Fireball (active, 1.3x magic damage)
         ↓
Level 2: Sharp Mind (passive, +10 mATK)
         ↓
Level 4: Lightning Bolt (active, 1.8x magic damage + stun)
```

### Skill Characteristics

#### **Active Skills**
- Used in combat from **skill buttons** (video4)
- Consume **mana**
- Have **damage multipliers**
- Can apply **debuffs**

#### **Passive Skills**
- Applied **automatically** when learned
- Give permanent **stat bonuses**
- Don't consume mana
- Can't be unequipped

### Learning System

```lua
-- Requirements to learn a skill:
1. Have sufficient level
2. Have prerequisite skill (if applicable)
3. Have ≥1 Skill Point

-- Each level gives: +1 Skill Point
```

---

## 👹 Enemy System

### Chapter 0 Enemies

| ID | Name | Level | HP | AI Pattern | EXP | Gold | Drop |
|----|------|-------|----|-----------|----|-----|------|
| 1 | Weak Wolf | 1 | 30 | basic_physical | 15 | 5 | - |
| 2 | Wolf | 2 | 50 | balanced | 30 | 10 | - |
| 3 | Alpha Wolf | 4 | 100 | smart_aggressive | 75 | 25 | Health Potion (50%) |

### AI Patterns

#### **basic_physical**
- Always physical attack
- No special strategy
- For weak enemies

#### **balanced**
- Alternates physical/magical (50/50)
- Strong attack if player < 50% HP
- For normal enemies

#### **smart_aggressive**
- Prioritizes finishing (player < 30% HP)
- Constant pressure (player < 60% HP)
- 60% physical, 40% magical
- For mini-bosses

---

## 📖 Chapter Engine

### Chapters.lua - Responsibilities

**Chapters.lua ONLY contains:**
- ✅ Event data (dialogues, decisions, encounters)
- ✅ Story branching structure
- ✅ Event handlers (dispatch to other systems)

**Chapters.lua does NOT contain:**
- ❌ Combat logic (moved to CombatSystem.lua)
- ❌ Player decay logic (moved to Player.lua)
- ❌ Rendering logic (stays in Utils.lua)

### Event Types

| Type | Description | Handler Does |
|------|-------------|--------------|
| `dialogue` | Narrative text | Display text, set next event |
| `decision` | Player choice | Show options, wait for input |
| `combat` | Battle vs enemy | Create enemy, start combat |
| `reward` | Give items/stats | Add items, modify stats |
| `chapter_end` | Chapter ending | Update chapter number |

### Chapter 0: "Awakening in Darkness"

#### **Chapter Flowchart**

```
[EVENT 0] Intro: "You wake up in darkness..."
    ↓
[EVENT 1] COMBAT: Weak Wolf
    ↓
[EVENT 2] Dialogue: "You defeated the wolf."
    ↓
[EVENT 3] DECISION: What to do?
    ├─→ BRANCH A: "Go forward"
    │   ↓
    │   [EVENT 4] Dialogue: "You advance..."
    │   ↓
    │   [EVENT 5] COMBAT: Wolf
    │
    └─→ BRANCH B: "Find exit"
        ↓
        [EVENT 10] Dialogue: "You find supplies!"
        ↓
        [EVENT 11] REWARD: +20 hunger
        ↓
        [EVENT 12] Dialogue: "Return to path"
        ↓
        [EVENT 5] COMBAT: Wolf (converges)

[EVENT 5] COMBAT: Wolf
    ↓
[EVENT 15] Dialogue: "Alpha appears!"
    ↓
[EVENT 16] COMBAT: Alpha Wolf (MINI-BOSS)
    ↓
[EVENT 20] Dialogue: "Victory!"
    ↓
[EVENT 21] FINAL DECISION: Which way?
    ├─→ [EVENT 30] ENDING A: City (Chapter 1.0)
    └─→ [EVENT 40] ENDING B: Dungeons (Chapter 1.1)
```

#### **Design Features**

✅ **Side-paths** → Different routes converge  
✅ **Controlled branching** → No complexity explosion  
✅ **Multiple endings** → Affects next chapter  
✅ **Difficulty progression** → Weak → Normal → Boss  

---

## 📐 Formulas & Balancing

### Extra Stats Formulas

```lua
ATK = STR × 2
mATK = INT × 2
DEF = floor((VIT × 1.5) + (STR × 0.5))
mDEF = floor((VIT × 1.5) + (INT × 0.5))
SPEED = AGI × 1
DODGE = min(80, floor(AGI × 0.8))
HIT = min(80, floor(DEX × 0.8))
CRIT = min(25, floor(DEX × 0.25))
HEALTHR = floor(VIT × 0.1)
MANAR = floor(INT × 0.1)
```

### Max Health and Mana

```lua
maxHealth = min(999, 100 + (VIT × 5))
maxMana = min(999, 50 + (INT × 5))
```

### Level Up

```lua
-- Each level:
statPoints = +2
skillPoints = +1

-- Bonus every 5 levels:
if level % 5 == 0 then
    statPoints = +2 additional
end

-- Required EXP:
expToNextLevel = floor(10 × (1.425 ^ (level - 1)))
```

### Hunger and Sleep System

#### **Hunger (in Player.lua)**
| State | Effect |
|-------|--------|
| < 25% | -1 HP/turn (red text) |
| 0% | -3 HP/turn (flashing red) |

#### **Sleep (in Player.lua)**
| State | Effect |
|-------|--------|
| < 25% | -25% all stats |
| 0% | Faint: -10% EXP + reset to 50% |

---

## 🎮 User Guide

### Controls

#### **Navigation**
- **DPad** → Move cursor
- **Button X** → Confirm / Continue
- **Button Z** → Open Skill Tree
- **Button S** → Open Inventory
- **Button A** → Open Player Sheet

#### **Combat**
- **ScreenButton 1** → Use skill slot 1
- **ScreenButton 2** → Use skill slot 2
- **Button X** → Continue after messages

#### **Decisions**
- **DPad up/down** → Select option
- **Button X** → Confirm decision

### Debug Buttons

| Button | Effect |
|--------|--------|
| **U** | +250 EXP |
| **I** | -1 HP |
| **O** | +1 HP |

---

## 📊 System Statistics

### Implemented Content

| System | Quantity |
|---------|----------|
| **.lua Files** | 8 files |
| **Skills** | 6 skills (3 physical + 3 magic) |
| **Enemies** | 3 enemies |
| **Chapter 0 Events** | 13 events |
| **Combats** | 3 combats |
| **Items** | 80 items |

### Lines of Code

| File | Lines | Responsibility |
|------|-------|---------------|
| BD.lua | ~506 | Data only |
| Skill.lua | ~190 | Skills logic |
| Enemy.lua | ~250 | AI & behavior |
| **CombatSystem.lua** | **~127** | **Combat logic** |
| Chapters.lua | ~238 | Story only |
| Player.lua | ~617 | Player + decay |
| Utils.lua | ~811 | Rendering |
| GameController.lua | ~1089 | Orchestration |
| **TOTAL** | **~3828 lines** | **Professional** |

---

## ✅ Architecture Checklist

### Separation of Concerns Verification

```
[ ] BD.lua contains ONLY data (no functions)
[ ] Chapters.lua contains ONLY story events (no combat logic)
[ ] CombatSystem.lua contains ALL combat logic
[ ] Player.lua contains hunger/sleep decay
[ ] Each module has single responsibility
[ ] No circular dependencies
[ ] Clean imports in GameController
```

---

## 🎯 Executive Summary

This is a **professionally architected RPG** with:

✅ **Perfect separation of concerns**  
✅ **8 specialized modules** (was 7, now 8 with CombatSystem)  
✅ **Chapters.lua is pure data** (no combat logic)  
✅ **CombatSystem.lua handles all combat**  
✅ **Player.lua handles hunger/sleep**  
✅ **Turn-based combat** with initiative & AI  
✅ **Skill system** with fragmented trees  
✅ **Enemy AI** with 3 patterns  
✅ **Complete Chapter 0** with branching  
✅ **~3828 lines** of clean, maintainable code  
✅ **100% English** code & comments  

**The architecture is scalable, professional, and production-ready.** 🎉

---

*Documentation generated on April 13, 2026*  
*System version: 2.0.0 - Refactored Architecture*  
*Language: English*
