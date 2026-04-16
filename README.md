# 🎮 MANUAL COMPLETO - RPG COMBAT SYSTEM

---

## 📑 ÍNDICE

1. [Controles de Testing](#-controles-de-testing)
2. [Sistema de Estadísticas](#-sistema-de-estadísticas)
3. [Sistema de Combate](#️-sistema-de-combate)
4. [Habilidades (Skills)](#-habilidades-skills)
5. [Buffs (Mejoras Temporales)](#-buffs-mejoras-temporales)
6. [Debuffs (Penalizaciones)](#-debuffs-penalizaciones)
7. [Items y Consumibles](#-items-y-consumibles)
8. [Sistema de Equipamiento](#️-sistema-de-equipamiento)
9. [Combos y Estrategias](#-combos-y-estrategias)
10. [Guía de Testing](#-guía-de-testing)

---

## 🎮 CONTROLES DE TESTING

### **KEYPAD 0 - BUFFS** (Botones 1-6)

| Botón | Buff | Duración | Efecto Principal |
|:-----:|:----:|:--------:|:-----------------|
| **1** | **Regen** | 4 turnos | Regenera +8 HP por turno |
| **2** | **Shield** | 2 turnos | Reduce daño recibido 40% |
| **3** | **Strength** | 3 turnos | Aumenta ATK +40% |
| **4** | **Haste** | 3 turnos | Aumenta Dodge +30% y Crit +15% |
| **5** | **Focus** | 3 turnos | Aumenta Hit +50% y mATK +30% |
| **6** | **Berserk** | 2 turnos | ATK +60%, DEF -40% |

### **KEYPAD 1 - DEBUFFS** (Botones 1-6)

| Botón | Debuff | Duración | Efecto Principal |
|:-----:|:------:|:--------:|:-----------------|
| **1** | **Bleeding** | 3 turnos | Pierde 5% HP máximo por turno |
| **2** | **Poison** | 4 turnos | Pierde 8 HP por turno |
| **3** | **Burn** | 2 turnos | Pierde 12 HP/turno y DEF -30% |
| **4** | **Freeze** | 1 turno | Paraliza + recibe +40% daño |
| **5** | **Paralyze** | 2 turnos | 50% chance de no poder actuar |
| **6** | **Confusion** | 2 turnos | 40% chance de golpearse a sí mismo |

**💡 Mecánica Toggle:** Presionar el botón cuando el efecto está **activo** lo **elimina**. Presionarlo cuando está **inactivo** lo **aplica**.

**⏱️ Delay:** Hay un delay de 0.2 segundos después de cada pulsación para evitar dobles activaciones.

---

## 📊 SISTEMA DE ESTADÍSTICAS

### **STATS PRINCIPALES (Primary Stats)**

Estas son las estadísticas base del personaje que afectan a todas las demás:

#### **Strength (STR) - Fuerza** ⚔️
- **Función principal:** Daño físico
- **Afecta a:**
  - ATK: +100% del valor (1 STR = +1 ATK)
  - Crit: +50% del valor (1 STR = +0.5 Crit)
  - Hunger Decay: +25% del valor
- **Estrategia:** Ideal para builds físicos y críticos

#### **Agility (AGI) - Agilidad** 🏃
- **Función principal:** Velocidad y evasión
- **Afecta a:**
  - ATK: +50% del valor (1 AGI = +0.5 ATK)
  - Speed: +100% del valor (1 AGI = +1 Speed)
  - Dodge: +50% del valor (1 AGI = +0.5 Dodge)
  - Hunger Decay: +25% del valor
  - Sleep Decay: +25% del valor
- **Estrategia:** Builds evasivos y rápidos

#### **Dexterity (DEX) - Destreza** 🎯
- **Función principal:** Precisión
- **Afecta a:**
  - mATK: +50% del valor (1 DEX = +0.5 mATK)
  - Speed: +50% del valor (1 DEX = +0.5 Speed)
  - Dodge: +50% del valor (1 DEX = +0.5 Dodge)
  - Hit: +100% del valor (1 DEX = +1 Hit)
  - Crit: +50% del valor (1 DEX = +0.5 Crit)
- **Estrategia:** Híbrido entre físico y mágico

#### **Intelligence (INT) - Inteligencia** 🧠
- **Función principal:** Poder mágico
- **Afecta a:**
  - mATK: +100% del valor (1 INT = +1 mATK)
  - mDEF: +50% del valor (1 INT = +0.5 mDEF)
  - Mana Regen: +50% del valor
- **Estrategia:** Builds de magia pura

#### **Vitality (VIT) - Vitalidad** ❤️
- **Función principal:** Resistencia
- **Afecta a:**
  - DEF: +100% del valor (1 VIT = +1 DEF)
  - mDEF: +100% del valor (1 VIT = +1 mDEF)
  - Health Regen: +50% del valor
- **Estrategia:** Tanques y supervivencia

---

### **SUBSTATS (Estadísticas Derivadas)**

Estas estadísticas se calculan automáticamente a partir de las stats principales y el equipamiento:

#### **Attack (ATK) - Ataque Físico**
```
Fórmula: (STR × 1.0) + (AGI × 0.5) + Bonus Equipamiento
```
- **Función:** Daño base de ataques físicos
- **Modificadores:**
  - Strength buff: ×1.4 (+40%)
  - Berserk buff: ×1.6 (+60%)
- **Ejemplo:** STR=20, AGI=10, Equip=5 → ATK = 20 + 5 + 5 = 30

#### **Magic Attack (mATK) - Ataque Mágico**
```
Fórmula: (INT × 1.0) + (DEX × 0.5) + Bonus Equipamiento
```
- **Función:** Daño base de ataques mágicos
- **Modificadores:**
  - Focus buff: ×1.3 (+30%)
- **Ejemplo:** INT=25, DEX=12, Equip=3 → mATK = 25 + 6 + 3 = 34

#### **Defense (DEF) - Defensa Física**
```
Fórmula: (VIT × 1.0) + Bonus Equipamiento
```
- **Función:** Reduce daño físico recibido
- **Modificadores:**
  - Berserk buff: ×0.6 (-40%)
  - Burn debuff: ×0.7 (-30%)
- **Ejemplo:** VIT=18, Equip=8 → DEF = 18 + 8 = 26

#### **Magic Defense (mDEF) - Defensa Mágica**
```
Fórmula: (VIT × 1.0) + (INT × 0.5) + Bonus Equipamiento
```
- **Función:** Reduce daño mágico recibido
- **Modificadores:** Ninguno actualmente
- **Ejemplo:** VIT=18, INT=20, Equip=5 → mDEF = 18 + 10 + 5 = 33

#### **Speed (SPD) - Velocidad**
```
Fórmula: (AGI × 1.0) + (DEX × 0.5) + Bonus Equipamiento
```
- **Función:** Determina quién ataca primero
- **Regla:** Si SPD jugador ≥ SPD enemigo → jugador ataca primero
- **Modificadores:** Ninguno actualmente
- **Ejemplo:** AGI=15, DEX=10, Equip=2 → SPD = 15 + 5 + 2 = 22

#### **Dodge (DOD) - Evasión**
```
Fórmula: (AGI × 0.5) + (DEX × 0.5) + Bonus Equipamiento
```
- **Función:** Reduce probabilidad de ser golpeado
- **Modificadores:**
  - Haste buff: ×1.3 (+30%)
- **Ejemplo:** AGI=16, DEX=14, Equip=3 → DOD = 8 + 7 + 3 = 18

#### **Hit (HIT) - Precisión**
```
Fórmula: (DEX × 1.0) + Bonus Equipamiento
```
- **Función:** Aumenta probabilidad de golpear
- **Modificadores:**
  - Focus buff: ×1.5 (+50%)
- **Ejemplo:** DEX=18, Equip=4 → HIT = 18 + 4 = 22

#### **Critical (CRIT) - Crítico**
```
Fórmula: (STR × 0.5) + (DEX × 0.5) + Bonus Equipamiento
```
- **Función:** Probabilidad de golpe crítico (×2 daño)
- **Modificadores:**
  - Haste buff: ×1.15 (+15%)
- **Ejemplo:** STR=20, DEX=16, Equip=2 → CRIT = 10 + 8 + 2 = 20%

---

### **STATS SECUNDARIOS**

#### **Health Regeneration**
```
Fórmula: (VIT × 0.5) + Bonus Equipamiento
```
- **Función:** HP recuperado automáticamente al avanzar eventos (fuera de combate)

#### **Mana Regeneration**
```
Fórmula: (INT × 0.5) + Bonus Equipamiento
```
- **Función:** Mana recuperado automáticamente al avanzar eventos

#### **Hunger Decay**
```
Fórmula: (STR × 0.25) + (AGI × 0.25) + Bonus Equipamiento
```
- **Función:** Hambre que pierdes al avanzar eventos
- **Nota:** A mayor stat, más hambre pierdes (necesitas comer más)

#### **Sleep Decay**
```
Fórmula: (STR × 0.25) + (AGI × 0.25) + Bonus Equipamiento
```
- **Función:** Sueño que pierdes al avanzar eventos
- **Nota:** A mayor stat, más sueño pierdes (necesitas dormir más)

---

## ⚔️ SISTEMA DE COMBATE

### **ORDEN DE TURNO**

El combate funciona en turnos alternados determinados por la estadística de **Speed**:

```
┌─────────────────────────────────────────┐
│ INICIO DEL TURNO                        │
├─────────────────────────────────────────┤
│ 1. Comparar Speed jugador vs enemigo    │
│                                         │
│ Si Speed jugador ≥ Speed enemigo:       │
│   ├─ Jugador actúa primero              │
│   ├─ Actualizar status effects          │
│   └─ Enemigo actúa (si sobrevive)       │
│                                         │
│ Si Speed enemigo > Speed jugador:       │
│   ├─ Enemigo actúa primero              │
│   ├─ Actualizar status effects          │
│   └─ Jugador actúa (si sobrevive)       │
│                                         │
├─────────────────────────────────────────┤
│ 2. Verificar si alguno murió            │
│ 3. Repetir desde paso 1                 │
└─────────────────────────────────────────┘
```

**💡 Nota importante:** Los status effects (buffs/debuffs) se actualizan DESPUÉS de que ambos actúan, al final del turno completo.

---

### **CÁLCULO DE DAÑO FÍSICO**

```
┌──────────────────────────────────────────────┐
│ DAÑO FÍSICO (Ataque básico o Power Strike)  │
├──────────────────────────────────────────────┤
│ 1. Daño Base = ATK del atacante             │
│                                              │
│ 2. Aplicar multiplicador de skill:          │
│    - Ataque básico: ×1.0                     │
│    - Power Strike: ×1.5                      │
│                                              │
│ 3. Restar defensa del objetivo:             │
│    Daño = max(1, Daño Base - DEF objetivo)  │
│                                              │
│ 4. Calcular probabilidad de impacto:        │
│    Hit% = 75 + (HIT atacante - DOD defensor)│
│    Límites: mín 10%, máx 95%                │
│                                              │
│ 5. Tirar dado de impacto:                   │
│    Si falla → "MISS" (0 daño)               │
│    Si acierta → continuar                   │
│                                              │
│ 6. Tirar dado de crítico:                   │
│    Si random ≤ CRIT% → Daño ×2              │
│                                              │
│ 7. Aplicar modificadores de status:         │
│    - Si objetivo tiene Shield: Daño ×0.6    │
│    - Si objetivo tiene Freeze: Daño ×1.4    │
│                                              │
│ 8. Redondear y aplicar:                     │
│    Daño Final = floor(Daño)                 │
└──────────────────────────────────────────────┘
```

**Ejemplo completo:**
```
Jugador: ATK=30, HIT=25, CRIT=20%
Enemigo: DEF=10, DOD=15, tiene Shield activo

1. Daño Base = 30
2. Power Strike: 30 × 1.5 = 45
3. Restar DEF: 45 - 10 = 35
4. Hit% = 75 + (25 - 15) = 85%
5. Dado de impacto = 42 → ¡Acierta! (42 < 85)
6. Dado de crítico = 15 → ¡Crítico! (15 < 20)
   Daño = 35 × 2 = 70
7. Shield activo: 70 × 0.6 = 42
8. Daño Final = 42 HP
```

---

### **CÁLCULO DE DAÑO MÁGICO**

```
┌──────────────────────────────────────────────┐
│ DAÑO MÁGICO (Fireball, Ice Shard, etc.)     │
├──────────────────────────────────────────────┤
│ 1. Daño Base = mATK del atacante            │
│                                              │
│ 2. Aplicar multiplicador de skill:          │
│    - Fireball: ×1.8                          │
│    - Ice Shard: ×1.4                         │
│                                              │
│ 3. Restar defensa mágica:                   │
│    Daño = max(1, Daño Base - mDEF objetivo) │
│                                              │
│ 4-8. Mismo proceso que daño físico          │
│      (Hit, Miss, Crit, Shield, Freeze)      │
└──────────────────────────────────────────────┘
```

**💡 Diferencias clave:**
- Usa mATK en lugar de ATK
- Usa mDEF en lugar de DEF
- Los mismos modificadores (Shield, Freeze, Crit) aplican igual

---

### **SISTEMA DE HIT/MISS**

```
Hit Chance = 75% base + (HIT atacante - DODGE defensor)

Límites:
- Mínimo: 10% (siempre hay 10% de chance mínimo)
- Máximo: 95% (nunca 100% garantizado)
```

**Ejemplos:**
```
HIT=20, DODGE=10 → 75 + (20-10) = 85% de acertar
HIT=15, DODGE=30 → 75 + (15-30) = 60% de acertar
HIT=10, DODGE=50 → 75 + (10-50) = 35% de acertar
HIT=5,  DODGE=80 → 75 + (5-80) = 10% (límite mínimo)
HIT=50, DODGE=5  → 75 + (50-5) = 95% (límite máximo)
```

---

### **SISTEMA DE CRÍTICOS**

```
Critical Chance = CRIT%

Si el golpe es crítico:
- Daño Final ×2 (después de restar defensa, antes de Shield/Freeze)
```

**Ejemplo:**
```
ATK=30, DEF=10, CRIT=25%

Daño normal: 30 - 10 = 20 HP
Daño crítico: (30 - 10) × 2 = 40 HP
```

---

### **ACTUALIZACIÓN DE STATUS EFFECTS**

Al final de cada turno completo (después de que ambos actúan):

```
1. Player:UpdateBuffs()
   - Regen: +8 HP
   - Otros buffs: -1 turno

2. Player:UpdateDebuffs()
   - Bleeding: -5% HP máx
   - Poison: -8 HP
   - Burn: -12 HP
   - Otros debuffs: -1 turno

3. Enemy:UpdateBuffs()
   (igual que player)

4. Enemy:UpdateDebuffs()
   (igual que player)

5. Eliminar status con 0 turnos
```

---

## 🎯 HABILIDADES (SKILLS)

### **SKILLS OFENSIVOS**

#### **⚔️ Power Strike**
```yaml
ID: power_strike
Tipo: Physical
Coste: 15 Mana
Daño: ATK × 1.5
Efectos: Ninguno
Hit: Normal (75% + HIT - DODGE)
Crítico: Posible
```
**Descripción:** Golpe físico potenciado que hace 50% más daño que un ataque básico.

**Cuándo usar:**
- Contra enemigos con baja DEF
- Cuando tienes buffs de ATK (Strength, Berserk)
- Para rematar enemigos con poca vida

**Estrategia:**
- Combinar con Strength (+40% ATK) = ATK × 1.5 × 1.4 = ATK × 2.1
- Combinar con Berserk (+60% ATK) = ATK × 1.5 × 1.6 = ATK × 2.4
- Si el enemigo tiene Burn (-30% DEF), el daño efectivo aumenta aún más

---

#### **🔥 Fireball**
```yaml
ID: fireball
Tipo: Magical
Coste: 20 Mana
Daño: mATK × 1.8
Efectos: 30% chance de Burn (2 turnos)
Hit: Normal
Crítico: Posible
```
**Descripción:** Bola de fuego que hace alto daño mágico y puede quemar al enemigo.

**Cuándo usar:**
- Contra enemigos con baja mDEF
- Cuando necesitas aplicar Burn para reducir su DEF
- Build de mago puro (alta INT)

**Estrategia:**
- Si aplica Burn, el enemigo pierde 24 HP adicionales (12 HP × 2 turnos)
- Burn reduce DEF del enemigo en 30%, perfecto antes de ataques físicos
- Combinar con Focus (+30% mATK) = mATK × 1.8 × 1.3 = mATK × 2.34

**Daño total esperado:**
```
Daño directo: mATK × 1.8 - mDEF
Daño DOT (si aplica Burn): 24 HP en 2 turnos
Total: ~50-80 HP en 3 turnos
```

---

#### **❄️ Ice Shard**
```yaml
ID: ice_shard
Tipo: Magical
Coste: 18 Mana
Daño: mATK × 1.4
Efectos: 40% chance de Freeze (1 turno)
Hit: Normal
Crítico: Posible
```
**Descripción:** Proyectil de hielo que puede congelar al enemigo.

**Cuándo usar:**
- Para control (bloquear turno del enemigo)
- Antes de un ataque potente en el siguiente turno
- Contra enemigos de alto ATK (evitas recibir daño)

**Estrategia:**
- Si aplica Freeze, el enemigo NO actúa en su siguiente turno
- Freeze hace que el enemigo reciba +40% daño
- Combo perfecto: Ice Shard → Freeze → Power Strike × 1.4

**Ejemplo de combo:**
```
Turno 1: Ice Shard (mATK × 1.4) → Aplica Freeze
Turno 2: Power Strike (ATK × 1.5 × 1.4) = ATK × 2.1
Total: ~60-100 HP en 2 turnos + enemigo pierde 1 turno
```

---

### **SKILLS DE SOPORTE**

#### **💚 Heal**
```yaml
ID: heal
Tipo: Healing
Coste: 12 Mana
Efecto: Restaura 30 HP
Puede usarse: En combate y fuera de combate
```
**Descripción:** Recupera una cantidad fija de HP instantáneamente.

**Cuándo usar:**
- Cuando HP < 40% (emergencia)
- Si Shield está activo (curar + mitigar = máxima supervivencia)
- Antes de recibir un ataque fuerte del enemigo

**Comparación con Regen:**
```
Heal: 30 HP instantáneos, 12 Mana
Regen: 32 HP en 4 turnos, 0 Mana (si es un consumible)

Heal es mejor: Para emergencias
Regen es mejor: Para combates largos
```

---

#### **🧘 Meditation**
```yaml
ID: meditation
Tipo: Support
Coste: 0 Mana
Efecto: Restaura 20 Mana
Pierde el turno: Sí
```
**Descripción:** Meditas para recuperar Mana, pero pierdes tu turno de ataque.

**Cuándo usar:**
- Cuando Mana < 20 y necesitas usar skills
- En combates largos donde necesitas gestionar recursos
- Si el enemigo está con poco HP y puedes permitirte 1 turno defensivo

**Estrategia:**
- Usar con Shield activo (reduces daño mientras recuperas mana)
- NO usar si el enemigo puede matarte en 1-2 turnos
- Ideal en early game cuando el mana pool es pequeño

**Cálculo de eficiencia:**
```
Meditation: +20 Mana, 0 coste
Power Strike: 15 Mana para ~30 daño
Fireball: 20 Mana para ~40 daño

Meditation permite ~1-2 skills adicionales por uso
```

---

## 💊 BUFFS (MEJORAS TEMPORALES)

### **🌿 Regen (Regeneración)**

```yaml
Duración: 4 turnos
Efecto: +8 HP al inicio de cada turno
Daño total: +32 HP durante toda la duración
Stackeo: Sí (suma turnos)
Tipo: Curación Over Time (HOT)
```

**Cómo funciona:**
```
Turno 1: +8 HP (quedan 3 turnos)
Turno 2: +8 HP (quedan 2 turnos)
Turno 3: +8 HP (queda 1 turno)
Turno 4: +8 HP (expira)
Total: +32 HP
```

**Stackeo de turnos:**
```
Turno 1: Aplicar Regen (4 turnos)
Turno 3: Aplicar Regen de nuevo (4 turnos)
Resultado: Ahora tiene 4 - 2 + 4 = 6 turnos de Regen
```

**Cuándo usar:**
- ANTES de entrar en combates largos
- Cuando HP < 60% y tienes tiempo
- Combinar con Shield para máxima supervivencia

**Comparación con Heal:**
```
Regen: 32 HP en 4 turnos
Heal: 30 HP instantáneos

Regen es mejor para: Combates largos, preparación
Heal es mejor para: Emergencias, HP crítico
```

**Estrategias:**
- Aplicar en eventos de capítulo ANTES de combate
- En combate largo, mejor que Heal (más HP total)
- Combinar con DEF alta para tanqueo

---

### **🛡️ Shield (Escudo)**

```yaml
Duración: 2 turnos
Efecto: Reduce TODO el daño recibido en 40%
Stackeo: Sí (suma turnos)
Tipo: Mitigación de daño
```

**Cómo funciona:**
```
Daño normal: 50 HP
Con Shield: 50 × 0.6 = 30 HP
Daño bloqueado: 20 HP
```

**Interacción con Freeze:**
```
Enemigo tiene Freeze (+40% daño)
Player tiene Shield (-40% daño)

Daño base: 50 HP
Con Freeze: 50 × 1.4 = 70 HP
Con Shield: 70 × 0.6 = 42 HP
Resultado: Shield mitiga parcialmente el Freeze
```

**Momento de aplicación:**
```
1. Calcular daño base
2. Restar DEF
3. Aplicar crítico (si aplica)
4. Aplicar Shield (-40%)  ← AQUÍ
5. Aplicar Freeze (+40%)
6. Daño final
```

**Cuándo usar:**
- Antes de recibir ataques fuertes
- Contra enemigos de alto ATK
- Combinar con Regen para tanqueo máximo
- Cuando tienes Berserk activo (compensa la -40% DEF)

**Cálculo de efectividad:**
```
Sin Shield:
ATK enemigo = 60, tu DEF = 20
Daño = 60 - 20 = 40 HP
Recibes 40 HP de daño

Con Shield:
Daño = (60 - 20) × 0.6 = 24 HP
Recibes 24 HP de daño
Diferencia: 16 HP bloqueados por turno

En 2 turnos: ~32 HP bloqueados total
```

**Estrategias:**
- Activar antes de boss fights
- Usar con Berserk para ataque sin consecuencias
- Esencial contra enemigos que golpean por 50+ HP

---

### **⚔️ Strength (Fuerza)**

```yaml
Duración: 3 turnos
Efecto: ATK × 1.4 (+40%)
Stackeo: Sí (suma turnos)
Tipo: Amplificación de daño físico
```

**Cómo funciona:**
```
ATK base: 30
Con Strength: 30 × 1.4 = 42 ATK
Aumento: +12 ATK
```

**Cálculo en combate:**
```
Sin Strength:
ATK=30, DEF enemigo=10
Daño = 30 - 10 = 20 HP

Con Strength:
ATK=42, DEF enemigo=10
Daño = 42 - 10 = 32 HP

Diferencia: +12 HP por ataque
En 3 turnos: +36 HP adicionales
```

**Con Power Strike:**
```
Sin Strength:
Power Strike = (ATK × 1.5) - DEF = (30 × 1.5) - 10 = 35 HP

Con Strength:
ATK con buff = 30 × 1.4 = 42
Power Strike = (42 × 1.5) - 10 = 53 HP

Diferencia: +18 HP por Power Strike
```

**Interacción con Berserk:**
```
Strength: ATK × 1.4
Berserk: ATK × 1.6

NO SE ACUMULAN - Solo el más fuerte aplica
Resultado: Solo Berserk aplica (×1.6 > ×1.4)
```

**Cuándo usar:**
- Builds físicos (alta STR base)
- Antes de combos de Power Strike
- Contra enemigos con DEF baja-media
- Cuando quieres daño sostenido (3 turnos)

**Estrategias:**
- Aplicar al inicio del combate
- Combinar con Burn en enemigo (-30% DEF) = sinergia máxima
- NO usar si tienes Berserk disponible (Berserk es mejor)

---

### **⚡ Haste (Prisa)**

```yaml
Duración: 3 turnos
Efecto: Dodge × 1.3 (+30%), Crit × 1.15 (+15%)
Stackeo: Sí (suma turnos)
Tipo: Evasión y crítico
```

**Cómo funciona - Dodge:**
```
Dodge base: 20
Con Haste: 20 × 1.3 = 26 Dodge
Aumento: +6 Dodge

Hit del enemigo = 25
Hit% sin Haste = 75 + (25 - 20) = 80%
Hit% con Haste = 75 + (25 - 26) = 74%
Diferencia: 6% menos de ser golpeado
```

**Cómo funciona - Crit:**
```
Crit base: 20%
Con Haste: 20 × 1.15 = 23%
Aumento: +3% de crítico

En 10 ataques:
Sin Haste: 2 críticos (~20%)
Con Haste: 2-3 críticos (~23%)
```

**Efectividad vs enemigos de alto ATK:**
```
Enemigo: ATK=70, HIT=30
Player: DEF=20, Dodge=15

Sin Haste:
Hit% enemigo = 75 + (30 - 15) = 90%
9 de cada 10 ataques aciertan
Daño promedio = (70 - 20) × 0.9 = 45 HP/turno

Con Haste:
Dodge = 15 × 1.3 = 19.5 ≈ 20
Hit% enemigo = 75 + (30 - 20) = 85%
8.5 de cada 10 ataques aciertan
Daño promedio = (70 - 20) × 0.85 = 42.5 HP/turno

Reducción: 2.5 HP/turno
En 3 turnos: ~7-8 HP evitados
```

**Cuándo usar:**
- Contra enemigos de muy alto ATK (survival)
- Builds de críticos (STR + DEX altos)
- Cuando necesitas RNG a tu favor
- Combates donde cada punto de evasión cuenta

**Estrategias:**
- Mejor en builds balanceados (AGI + DEX + STR)
- Combinar con armas de alto daño base (críticos duelen más)
- Menos útil contra enemigos de bajo HIT

---

### **🎯 Focus (Concentración)**

```yaml
Duración: 3 turnos
Efecto: Hit × 1.5 (+50%), mATK × 1.3 (+30%)
Stackeo: Sí (suma turnos)
Tipo: Precisión y magia
```

**Cómo funciona - Hit:**
```
Hit base: 20
Con Focus: 20 × 1.5 = 30
Aumento: +10 Hit

Dodge enemigo = 35
Hit% sin Focus = 75 + (20 - 35) = 60%
Hit% con Focus = 75 + (30 - 35) = 70%
Diferencia: +10% más de acertar
```

**Cómo funciona - mATK:**
```
mATK base: 40
Con Focus: 40 × 1.3 = 52
Aumento: +12 mATK

Fireball sin Focus: (40 × 1.8) - 15 = 57 HP
Fireball con Focus: (52 × 1.8) - 15 = 78.6 HP
Diferencia: +21 HP por Fireball
```

**Cuándo usar:**
- Contra enemigos con ALTO Dodge (30+)
- Builds de mago (INT alta)
- Cuando tus ataques fallan frecuentemente
- Antes de usar Fireball o Ice Shard

**Estrategias:**
- Esencial contra enemigos ágiles
- Builds híbridos física-mágica (aprovecha ambos bonus)
- Combinar con Fireball para daño mágico explosivo

---

### **😡 Berserk (Ira)**

```yaml
Duración: 2 turnos
Efecto: ATK × 1.6 (+60%), DEF × 0.6 (-40%)
Stackeo: Sí (suma turnos)
Tipo: Riesgo/Recompensa
```

**Cómo funciona:**
```
ATK base: 30
DEF base: 25

Con Berserk:
ATK = 30 × 1.6 = 48 (+18 ATK)
DEF = 25 × 0.6 = 15 (-10 DEF)
```

**Cálculo de daño infligido:**
```
Sin Berserk:
Power Strike = (30 × 1.5) - 10 = 35 HP

Con Berserk:
ATK = 30 × 1.6 = 48
Power Strike = (48 × 1.5) - 10 = 62 HP

Diferencia: +27 HP por Power Strike
En 2 turnos: +54 HP adicionales
```

**Cálculo de daño recibido:**
```
ATK enemigo = 50

Sin Berserk:
Daño = 50 - 25 = 25 HP

Con Berserk:
DEF = 25 × 0.6 = 15
Daño = 50 - 15 = 35 HP

Diferencia: +10 HP más de daño recibido
En 2 turnos: +20 HP adicionales recibidos
```

**Balance neto:**
```
Daño extra infligido: +54 HP (en 2 turnos)
Daño extra recibido: +20 HP (en 2 turnos)
Ganancia neta: +34 HP de ventaja
```

**Cuándo usar:**
- Cuando puedes matar al enemigo en 1-2 turnos
- Con Shield activo (mitiga la penalización de DEF)
- Contra enemigos de bajo ATK
- Build glass cannon (todo ATK, poca DEF)

**Cuándo NO usar:**
- Contra enemigos de muy alto ATK (te matan rápido)
- Cuando HP < 40%
- Sin Shield o Regen activos

**Estrategias:**
```
Combo Seguro:
1. Activar Shield (-40% daño recibido)
2. Activar Berserk (+60% ATK, -40% DEF)
3. Power Strike spam

Resultado:
- Daño infligido: ATK × 1.6 × 1.5 = ATK × 2.4
- Daño recibido: (ATK_enemigo - DEF×0.6) × 0.6
  Shield compensa la vulnerabilidad de Berserk
```

---

## 🩸 DEBUFFS (PENALIZACIONES)

### **🩸 Bleeding (Sangrado)**

```yaml
Duración: 3 turnos
Daño: 5% HP máximo por turno
Daño total: 15% HP máximo en 3 turnos
Stackeo: Sí (suma turnos)
Tipo: Damage Over Time (DOT) escalable
```

**Cómo funciona:**
```
HP máximo = 100

Turno 1: -5 HP (quedan 2 turnos)
Turno 2: -5 HP (queda 1 turno)
Turno 3: -5 HP (expira)
Total: -15 HP
```

**Escalado con HP:**
```
HP = 80:  5% = 4 HP/turno → 12 HP total
HP = 100: 5% = 5 HP/turno → 15 HP total
HP = 150: 5% = 7 HP/turno → 21 HP total
HP = 200: 5% = 10 HP/turno → 30 HP total
```

**Comparación con Poison:**
```
Bleeding: Escala con HP máximo
Poison: Daño fijo (8 HP/turno)

Contra enemigo de 100 HP:
Bleeding = 15 HP total
Poison = 32 HP total
Winner: Poison

Contra enemigo de 250 HP:
Bleeding = 37 HP total
Poison = 32 HP total
Winner: Bleeding
```

**Cuándo usar:**
- Contra enemigos con HP muy alto (150+)
- Builds que prolongan el combate (tanques)
- Combinar con otros DOTs para máximo daño

**Estrategias:**
```
Combo DOT Stack:
Bleeding (15% HP) + Poison (32 HP) + Burn (24 HP)
= 71 HP + 15% HP máx en 4 turnos

Contra enemigo de 200 HP:
71 HP + 30 HP = 101 HP
= Mata al enemigo solo con DOTs
```

---

### **☠️ Poison (Veneno)**

```yaml
Duración: 4 turnos
Daño: 8 HP fijo por turno
Daño total: 32 HP en 4 turnos
Stackeo: Sí (suma turnos)
Tipo: Damage Over Time (DOT) fijo
```

**Cómo funciona:**
```
Turno 1: -8 HP (quedan 3 turnos)
Turno 2: -8 HP (quedan 2 turnos)
Turno 3: -8 HP (queda 1 turno)
Turno 4: -8 HP (expira)
Total: -32 HP
```

**Efectividad por fase de juego:**
```
Early game (enemigos ~80 HP):
Poison = 32 HP
% del HP enemigo = 40%
Muy efectivo

Mid game (enemigos ~150 HP):
Poison = 32 HP
% del HP enemigo = 21%
Moderadamente efectivo

Late game (enemigos ~300 HP):
Poison = 32 HP
% del HP enemigo = 10%
Menos efectivo (usar Bleeding)
```

**Cuándo usar:**
- Early game (muy fuerte)
- Contra enemigos de HP bajo-medio (<150 HP)
- Cuando quieres daño consistente sin escalar
- Tiene la duración más larga (4 turnos)

**Estrategias:**
- Aplicar al inicio del combate
- Mejor en combates largos (4 turnos o más)
- Combinar con Bleeding contra jefes

---

### **🔥 Burn (Quemadura)**

```yaml
Duración: 2 turnos
Daño: 12 HP por turno
Efecto adicional: DEF × 0.7 (-30%)
Daño total: 24 HP en 2 turnos
Stackeo: Sí (suma turnos)
Tipo: DOT + Debuff de defensa
```

**Cómo funciona:**
```
Turno 1: -12 HP, DEF reducida (queda 1 turno)
Turno 2: -12 HP, DEF reducida (expira)
Total: -24 HP directo
```

**Reducción de DEF:**
```
DEF base del enemigo: 30
Con Burn: 30 × 0.7 = 21
Reducción: -9 DEF

Tu ATK = 50
Daño sin Burn: 50 - 30 = 20 HP
Daño con Burn: 50 - 21 = 29 HP
Diferencia: +9 HP por ataque físico
```

**Daño total en combo:**
```
Burn aplicado, luego 2 turnos de Power Strike:

Daño DOT: 24 HP (12×2)
Daño extra por DEF reducida: 9 HP × 2 ataques = 18 HP
Total bonus: 42 HP en 2 turnos
```

**Cuándo usar:**
- Antes de spam de ataques físicos
- Contra enemigos con DEF alta (25+)
- Builds físicos de alto ATK
- Tiene el DOT más fuerte por turno (12 HP)

**Estrategias:**
```
Combo Físico:
1. Aplicar Burn (DEF × 0.7)
2. Activar Strength (ATK × 1.4)
3. Power Strike spam

Resultado:
Daño = [(ATK × 1.4) × 1.5] - [DEF × 0.7]
Amplificación extrema de daño físico
```

---

### **❄️ Freeze (Congelación)**

```yaml
Duración: 1 turno
Efecto 1: Bloquea acción completamente
Efecto 2: Daño recibido × 1.4 (+40%)
Stackeo: Sí (suma turnos)
Tipo: Control + Amplificación de daño
```

**Cómo funciona:**
```
Turno 1: Objetivo aplicado con Freeze
Turno 2: Objetivo no puede actuar + recibe +40% daño
Turno 3: Freeze expira
```

**Amplificación de daño:**
```
Tu ATK = 50, DEF enemigo = 15

Sin Freeze:
Daño = 50 - 15 = 35 HP

Con Freeze:
Daño = (50 - 15) × 1.4 = 49 HP

Diferencia: +14 HP
```

**Combo con Power Strike:**
```
Turno 1: Ice Shard aplica Freeze
Turno 2: Power Strike

Ice Shard: (mATK × 1.4) - mDEF = ~30 HP
Power Strike con Freeze: [(ATK × 1.5) - DEF] × 1.4 = ~70 HP
Total: ~100 HP en 2 turnos

Bonus: Enemigo pierde 1 turno completo
```

**¿Por qué solo 1 turno?**
```
Freeze es extremadamente poderoso:
- 100% bloqueo de acción (vs 50% de Paralyze)
- +40% daño (vs 0% de Paralyze)
- No es RNG, es garantizado

1 turno es suficiente para cambiar el combate
```

**Cuándo usar:**
- Antes de tu ataque más fuerte
- Contra enemigos de muy alto ATK (evitas recibir daño)
- Para setup de combos letales
- Cuando necesitas 1 turno de ventaja crítica

**Estrategias:**
```
Combo Letal:
1. Ice Shard (40% chance de Freeze)
2. Si aplica: Berserk + Shield
3. Power Strike con +40% daño

Resultado:
Freeze aplicado = enemigo pierde turno
Power Strike = (ATK × 1.6 × 1.5 × 1.4) = ATK × 3.36
Shield = mitiga el -40% DEF de Berserk

Uno de los combos más fuertes del juego
```

---

### **⚡ Paralyze (Parálisis)**

```yaml
Duración: 2 turnos
Efecto: 50% probabilidad de bloquear acción
Stackeo: Sí (suma turnos)
Tipo: Control basado en RNG
```

**Cómo funciona:**
```
Cada turno mientras está activo:
- Tirar dado (1-100)
- Si resultado ≤ 50: Acción bloqueada
- Si resultado > 50: Puede actuar normalmente
```

**Probabilidades:**
```
1 turno con Paralyze:
50% de bloquear 1 vez

2 turnos con Paralyze:
50% × 50% = 25% de bloquear ambos
50% + 50% = 75% de bloquear al menos 1
25% de no bloquear ninguno

Promedio: ~1 turno bloqueado de 2
```

**Comparación con Freeze:**
```
Freeze:
- 1 turno de duración
- 100% bloqueo garantizado
- +40% daño amplificado

Paralyze:
- 2 turnos de duración
- 50% bloqueo por turno (RNG)
- 0% daño amplificado

Freeze es mejor para: Combos garantizados
Paralyze es mejor para: Control prolongado
```

**Cuándo usar:**
- Cuando quieres control por más tiempo
- Contra enemigos que atacan muy fuerte (cada turno bloqueado es valioso)
- Cuando el RNG está de tu lado
- Builds que prolongan combates

**Estrategias:**
- Aplicar y rezar (es RNG)
- Combinar con Shield (si no funciona, tienes backup)
- Mejor contra múltiples enemigos (más tiradas = más chances)

---

### **😵 Confusion (Confusión)**

```yaml
Duración: 2 turnos
Efecto: 40% probabilidad de golpearse a sí mismo
Daño auto-infligido: 50% del ATK propio
Stackeo: Sí (suma turnos)
Tipo: Disrupción basada en RNG
```

**Cómo funciona:**
```
Cada turno mientras está activo:
- ANTES de ejecutar cualquier acción:
  - Tirar dado (1-100)
  - Si ≤ 40: Se golpea a sí mismo
  - Si > 40: Actúa normalmente
```

**Daño auto-infligido:**
```
ATK del objetivo = 60

Si se confunde:
Daño a sí mismo = floor(60 × 0.5) = 30 HP
Pierde 30 HP + pierde su turno de ataque
```

**Probabilidades:**
```
1 turno con Confusion:
40% de auto-golpearse 1 vez

2 turnos con Confusion:
40% × 40% = 16% de auto-golpearse ambos
40% + 40% - 16% = 64% de auto-golpearse al menos 1
36% de no auto-golpearse ninguno

Promedio: ~0.8 turnos auto-golpeados de 2
```

**Efectividad vs ATK enemigo:**
```
Enemigo de bajo ATK (ATK=30):
Auto-daño = 15 HP
Moderadamente útil

Enemigo de alto ATK (ATK=80):
Auto-daño = 40 HP
Muy útil (se hace mucho daño a sí mismo)
```

**Cuándo usar:**
- Contra enemigos de muy alto ATK (70+)
- Cuando quieres RNG disruptivo
- Builds que aprovechan turnos perdidos del enemigo
- Late game (enemigos tienen ATK alto)

**Estrategias:**
- Mejor contra bosses de alto ATK
- Cada turno confundido = 2× ventaja (no ataca + se daña)
- Combinar con DOTs mientras está confundido

---

## 🧪 ITEMS Y CONSUMIBLES

### **Consumibles de Curación**

#### **Red Herb (Hierba Roja)**
```yaml
Efecto: +20 HP
Precio: 10 Gold
Stackeable: Hasta 99
```
- Curación básica
- Útil en early game
- Llevar siempre 5-10 en inventario

#### **Yellow Herb (Hierba Amarilla)**
```yaml
Efecto: +15 Mana
Precio: 12 Gold
Stackeable: Hasta 99
```
- Regeneración de mana básica
- Esencial para magos
- Más eficiente que Meditation en emergencias

#### **Potion (Poción)**
```yaml
Efecto: +50 HP
Precio: 25 Gold
Stackeable: Hasta 99
```
- Curación estándar
- Mid game onwards
- Más eficiente que Red Herb

---

### **Consumibles con Status Effects**

#### **Regen Potion (Poción de Regeneración)**
```yaml
Efecto: APPLY regen 4
Precio: 30 Gold
Stackeable: Hasta 99
```
- Aplica Regen (4 turnos)
- Usar ANTES de combates difíciles
- Más eficiente que curación directa en combates largos

#### **Antidote (Antídoto)**
```yaml
Efecto: CLEANSE poison
Precio: 15 Gold
Stackeable: Hasta 99
```
- Elimina Poison
- Esencial contra enemigos venenosos
- Llevar 2-3 siempre

#### **Burn Salve (Ungüento Quemaduras)**
```yaml
Efecto: CLEANSE burn
Precio: 18 Gold
Stackeable: Hasta 99
```
- Elimina Burn
- Importante contra enemigos de fuego
- Restaura DEF completa inmediatamente

#### **Full Cleanse (Limpieza Total)**
```yaml
Efecto: CLEANSE ALL
Precio: 50 Gold
Stackeable: Hasta 99
```
- Elimina TODOS los debuffs
- Muy caro pero muy útil
- Guardar para emergencias (stacked de debuffs)

---

### **Consumibles de Buff**

#### **Strength Elixir (Elixir de Fuerza)**
```yaml
Efecto: APPLY strength 3
Precio: 35 Gold
Stackeable: Hasta 99
```
- Aplica Strength (3 turnos)
- Usar antes de boss fights
- Combinar con Power Strike

#### **Focus Tonic (Tónico de Concentración)**
```yaml
Efecto: APPLY focus 3
Precio: 35 Gold
Stackeable: Hasta 99
```
- Aplica Focus (3 turnos)
- Esencial contra enemigos evasivos
- Útil para builds de mago

---

### **Sistema de effectTag**

Los items usan tags para definir sus efectos:

```lua
-- Curación básica
"50 HP" → Cura 50 HP

-- Restauración de recursos
"25 MANA" → Restaura 25 Mana
"25 HUNG" → Reduce hambre 25 puntos
"40 SLEEP" → Reduce sueño 40 puntos

-- Limpiar debuffs
"CLEANSE poison" → Elimina Poison
"CLEANSE burn" → Elimina Burn
"CLEANSE ALL" → Elimina todos los debuffs

-- Aplicar buffs
"APPLY regen 4" → Aplica Regen por 4 turnos
"APPLY strength 3" → Aplica Strength por 3 turnos
"APPLY shield 2" → Aplica Shield por 2 turnos
```

**Tags múltiples:**
```lua
effectTag = "30 HP, 15 MANA"
→ Cura 30 HP Y restaura 15 Mana

effectTag = "CLEANSE ALL, 50 HP"
→ Elimina todos los debuffs Y cura 50 HP
```

---

## 🛡️ SISTEMA DE EQUIPAMIENTO

### **Slots de Equipamiento**

```yaml
lHand: Arma izquierda
rHand: Arma derecha (o escudo)
head: Casco/Casco
body: Armadura de cuerpo
feet: Botas
accesory1: Accesorio 1
accesory2: Accesorio 2
```

---

### **ARMAS**

#### **Knife (Cuchillo)**
```yaml
Slot: lHand o rHand
Tipo: Weapon
Bonus: ATK +5
```
- Arma básica inicial
- Ligera y rápida

#### **Axe (Hacha)**
```yaml
Slot: lHand o rHand
Tipo: Weapon
Bonus: ATK +8
```
- Más daño que Knife
- Ideal para builds de fuerza

#### **Magic Staff (Báculo Mágico)**
```yaml
Slot: lHand o rHand
Tipo: Weapon
Bonus: mATK +10
```
- Esencial para magos
- Aumenta daño de Fireball/Ice Shard

---

### **ARMADURAS**

#### **Leather Cap (Gorro de Cuero)**
```yaml
Slot: head
Tipo: Armor
Bonus: DEF +3
```
- Protección básica

#### **Iron Chestplate (Peto de Hierro)**
```yaml
Slot: body
Tipo: Armor
Bonus: DEF +12
```
- Armadura pesada
- Gran aumento de supervivencia

#### **Leather Boots (Botas de Cuero)**
```yaml
Slot: feet
Tipo: Armor
Bonus: DEF +4, Dodge +2
```
- Balance entre defensa y evasión

---

### **ACCESORIOS**

#### **Emerald Pendant (Colgante de Esmeralda)**
```yaml
Slot: accesory1 o accesory2
Tipo: Accesory
Bonus: mATK +5, Mana Regen +2
```
- Ideal para magos
- Aumenta regeneración de mana

#### **Ruby Necklace (Collar de Rubí)**
```yaml
Slot: accesory1 o accesory2
Tipo: Accesory
Bonus: ATK +4, Crit +3
```
- Ideal para físicos
- Aumenta daño y críticos

---

### **Estrategia de Equipamiento**

#### **Build Físico (Warrior)**
```yaml
lHand: Axe (ATK +8)
rHand: Knife (ATK +5)
head: Leather Cap (DEF +3)
body: Iron Chestplate (DEF +12)
feet: Leather Boots (DEF +4, Dodge +2)
accesory1: Ruby Necklace (ATK +4, Crit +3)
accesory2: Ruby Necklace (ATK +4, Crit +3)

Total Bonus:
ATK: +21
DEF: +19
Dodge: +2
Crit: +6
```

#### **Build Mágico (Mage)**
```yaml
lHand: Magic Staff (mATK +10)
rHand: Magic Staff (mATK +10)
head: Leather Cap (DEF +3)
body: Iron Chestplate (DEF +12)
feet: Leather Boots (DEF +4, Dodge +2)
accesory1: Emerald Pendant (mATK +5, Mana Regen +2)
accesory2: Emerald Pendant (mATK +5, Mana Regen +2)

Total Bonus:
mATK: +30
DEF: +19
Dodge: +2
Mana Regen: +4
```

---

## 🔥 COMBOS Y ESTRATEGIAS

### **COMBOS DE DAÑO**

#### **Combo Físico Explosivo**
```yaml
Requisitos: Strength elixir, Power Strike skill
Turnos: 3

Turno 1: Usar Strength elixir (ATK × 1.4)
Turno 2: Power Strike (ATK × 1.4 × 1.5 = ATK × 2.1)
Turno 3: Power Strike (ATK × 1.4 × 1.5 = ATK × 2.1)

Daño total: ~120-180 HP en 3 turnos
```

#### **Combo DOT Máximo**
```yaml
Requisitos: Items que apliquen Bleeding, Poison, Burn
Turnos: 1 (aplicación)

Turno 1: Aplicar Bleeding + Poison + Burn

Daño Over Time:
Bleeding: 15% HP máx (15 HP si enemigo tiene 100 HP)
Poison: 32 HP
Burn: 24 HP
Total: 71 HP + 15% HP máx en 4 turnos

Estrategia: Aplicar y defenderte mientras los DOTs matan
```

#### **Combo Freeze Letal**
```yaml
Requisitos: Ice Shard, Berserk, Shield
Turnos: 3

Turno 1: Ice Shard (40% chance Freeze)
Turno 2 (si Freeze aplicó):
  - Activar Shield + Berserk
  - Power Strike con +40% daño de Freeze

Daño total:
Ice Shard: ~30 HP
Power Strike con Freeze y Berserk:
  (ATK × 1.6 × 1.5 × 1.4) = ATK × 3.36
  Ejemplo: ATK=30 → (30 × 3.36) - DEF = ~90 HP

Total: ~120 HP en 2 turnos + enemigo pierde 1 turno
```

---

### **ESTRATEGIAS DE SUPERVIVENCIA**

#### **Tanque Perfecto**
```yaml
Buffs: Shield + Regen
Estrategia: Defensa máxima

Shield: -40% daño recibido
Regen: +8 HP/turno por 4 turnos = +32 HP

Efectividad:
Daño normal recibido: 50 HP/turno
Con Shield: 30 HP/turno
Con Regen: 30 - 8 = 22 HP neto/turno

Reducción: 28 HP/turno bloqueados
En 2 turnos: 56 HP salvados
```

#### **Berserk Seguro**
```yaml
Buffs: Shield + Berserk
Estrategia: Ataque sin riesgo

Berserk: ATK × 1.6, DEF × 0.6
Shield: Daño recibido × 0.6

Daño recibido normal: (ATK_enemigo - DEF)
Con Berserk: (ATK_enemigo - DEF × 0.6)
Con Shield también: (ATK_enemigo - DEF × 0.6) × 0.6

Resultado: Shield compensa la vulnerabilidad de Berserk
```

---

### **ESTRATEGIAS POR TIPO DE ENEMIGO**

#### **Vs Enemigo Alto HP, Bajo ATK (Tanque)**
```yaml
Estrategia: DOT Stack

1. Aplicar Bleeding (escala con HP alto)
2. Aplicar Poison (daño consistente)
3. Aplicar Burn (reduce su DEF)
4. Spam Power Strike

Daño total: DOTs (~70 HP) + Power Strike mejorado
```

#### **Vs Enemigo Bajo HP, Alto ATK (Glass Cannon)**
```yaml
Estrategia: Burst + Control

1. Activar Shield (mitiga su ATK)
2. Ice Shard → Freeze
3. Power Strike con Freeze (+40% daño)

Objetivo: Matarlo antes de que te mate
```

#### **Vs Enemigo Alto Dodge (Evasivo)**
```yaml
Estrategia: Focus + Magia

1. Aplicar Focus (Hit × 1.5)
2. Fireball spam (mágico ignora parte del Dodge)

Focus asegura que aciertes tus golpes
```

#### **Vs Boss (Alto HP + Alto ATK)**
```yaml
Estrategia: Full Preparation

Pre-combate:
- Usar Regen potion (4 turnos de +8 HP)
- Usar Strength elixir (3 turnos de ATK × 1.4)

Combate:
Turno 1: Shield + Burn al enemigo
Turno 2-4: Power Strike spam

Resultado: Supervivencia + Daño máximo
```

---

## 🔬 GUÍA DE TESTING

### **FASE 1: Testing de Buffs Individuales**

#### **Test 1.1: Regen**
```yaml
Objetivo: Verificar curación over time

Pasos:
1. Presionar Keypad0 Botón 1 (activar Regen)
2. Verificar icono verde en barra superior
3. Verificar contador "4"
4. Avanzar 1 evento de capítulo
5. Verificar que HP aumentó en ~8
6. Verificar contador ahora dice "3"
7. Repetir hasta expiración

Resultado esperado:
- 4 turnos de +8 HP cada uno
- Total: +32 HP
- Icono desaparece al llegar a 0
```

#### **Test 1.2: Shield**
```yaml
Objetivo: Verificar reducción de daño

Pasos:
1. Anotar HP actual
2. Entrar en combate
3. Presionar Keypad0 Botón 2 (activar Shield)
4. Verificar icono azul
5. Recibir ataque enemigo
6. Anotar daño recibido
7. Desactivar Shield (Keypad0 Botón 2)
8. Recibir mismo ataque
9. Comparar daño

Resultado esperado:
- Con Shield: ~40% menos daño
- Ejemplo: 50 HP → 30 HP
```

#### **Test 1.3: Strength**
```yaml
Objetivo: Verificar aumento de ATK

Pasos:
1. Abrir stats del jugador (ver ATK base)
2. Presionar Keypad0 Botón 3 (activar Strength)
3. Verificar icono rojo
4. Ver stats de nuevo
5. Verificar ATK aumentó ×1.4

Resultado esperado:
- ATK base: 30 → Con Strength: 42
- Diferencia: +40%
```

#### **Test 1.4: Haste**
```yaml
Objetivo: Verificar aumento de Dodge y Crit

Pasos:
1. Ver Dodge y Crit base
2. Presionar Keypad0 Botón 4 (activar Haste)
3. Ver stats de nuevo
4. Verificar aumentos

Resultado esperado:
- Dodge × 1.3 (+30%)
- Crit × 1.15 (+15%)
```

#### **Test 1.5: Focus**
```yaml
Objetivo: Verificar aumento de Hit y mATK

Pasos:
1. Ver Hit y mATK base
2. Presionar Keypad0 Botón 5 (activar Focus)
3. Ver stats de nuevo
4. Verificar aumentos

Resultado esperado:
- Hit × 1.5 (+50%)
- mATK × 1.3 (+30%)
```

#### **Test 1.6: Berserk**
```yaml
Objetivo: Verificar aumento de ATK y reducción de DEF

Pasos:
1. Ver ATK y DEF base
2. Presionar Keypad0 Botón 6 (activar Berserk)
3. Ver stats de nuevo
4. Verificar cambios

Resultado esperado:
- ATK × 1.6 (+60%)
- DEF × 0.6 (-40%)
```

---

### **FASE 2: Testing de Debuffs Individuales**

#### **Test 2.1: Bleeding**
```yaml
Objetivo: Verificar daño % de HP

Pasos:
1. Anotar HP actual y HP máximo
2. Presionar Keypad1 Botón 1 (activar Bleeding)
3. Avanzar 1 turno
4. Verificar HP perdido = ~5% HP máx
5. Repetir 3 veces

Resultado esperado:
- Si HP máx = 100: -5 HP/turno
- 3 turnos: -15 HP total
```

#### **Test 2.2: Poison**
```yaml
Objetivo: Verificar daño fijo

Pasos:
1. Anotar HP actual
2. Presionar Keypad1 Botón 2 (activar Poison)
3. Avanzar 1 turno
4. Verificar HP perdido = 8 HP
5. Repetir 4 veces

Resultado esperado:
- Cada turno: -8 HP
- 4 turnos: -32 HP total
```

#### **Test 2.3: Burn**
```yaml
Objetivo: Verificar daño + reducción DEF

Pasos:
1. Anotar HP y DEF
2. Presionar Keypad1 Botón 3 (activar Burn)
3. Ver stats → DEF debe ser ×0.7
4. Avanzar 1 turno → HP debe bajar 12
5. Repetir 2 veces

Resultado esperado:
- DEF reducida a 70%
- -12 HP/turno
- 2 turnos: -24 HP total
```

#### **Test 2.4: Freeze**
```yaml
Objetivo: Verificar bloqueo + amplificación daño

Pasos:
1. Entrar en combate
2. Presionar Keypad1 Botón 4 (activar Freeze)
3. Intentar atacar
4. Verificar mensaje "You are frozen and can't act!"
5. Recibir ataque enemigo
6. Verificar daño ~40% mayor de lo normal

Resultado esperado:
- Acción bloqueada 100%
- Daño recibido ×1.4
```

#### **Test 2.5: Paralyze**
```yaml
Objetivo: Verificar bloqueo probabilístico

Pasos:
1. Entrar en combate
2. Presionar Keypad1 Botón 5 (activar Paralyze)
3. Intentar atacar múltiples veces
4. Contar cuántas veces se bloquea

Resultado esperado:
- ~50% de los intentos bloqueados
- Mensaje "You are paralyzed and can't act!" aparece ~50%
```

#### **Test 2.6: Confusion**
```yaml
Objetivo: Verificar auto-daño

Pasos:
1. Anotar HP y ATK
2. Presionar Keypad1 Botón 6 (activar Confusion)
3. Intentar atacar múltiples veces
4. Observar si te golpeas a ti mismo

Resultado esperado:
- ~40% de los ataques te golpean a ti
- Daño = floor(ATK × 0.5)
- Mensaje "Confused! You hit yourself for X damage!"
```

---

### **FASE 3: Testing de Interacciones**

#### **Test 3.1: Shield vs Daño Normal**
```yaml
Objetivo: Verificar que Shield reduce daño

Setup:
1. Entrar combate
2. Recibir 1 ataque SIN Shield → anotar daño
3. Activar Shield
4. Recibir 1 ataque CON Shield → anotar daño
5. Comparar

Resultado esperado:
Con Shield ≈ 60% del daño sin Shield
```

#### **Test 3.2: Shield vs Freeze**
```yaml
Objetivo: Verificar orden de aplicación

Setup:
1. Activar Shield
2. Aplicar Freeze a ti mismo
3. Recibir ataque enemigo

Resultado esperado:
Daño = (Daño_base × 1.4 Freeze) × 0.6 Shield
Shield mitiga parcialmente el Freeze
```

#### **Test 3.3: Strength vs Berserk**
```yaml
Objetivo: Verificar que no se acumulan

Setup:
1. Activar Strength (ATK ×1.4)
2. Ver ATK
3. Activar Berserk (ATK ×1.6)
4. Ver ATK de nuevo

Resultado esperado:
Solo Berserk aplica (×1.6 > ×1.4)
ATK no es ×1.4 × ×1.6 = ×2.24
```

#### **Test 3.4: Burn + Ataques Físicos**
```yaml
Objetivo: Verificar sinergia de DEF reducida

Setup:
1. Entrar combate con enemigo
2. Aplicar Burn al enemigo
3. Ver DEF del enemigo (debe ser ×0.7)
4. Atacar con Power Strike
5. Comparar daño vs sin Burn

Resultado esperado:
Daño con Burn es significativamente mayor
```

---

### **FASE 4: Testing de Stackeo**

#### **Test 4.1: Stackeo Simple**
```yaml
Objetivo: Verificar que turnos se suman

Setup:
1. Aplicar Regen (4 turnos)
2. Ver contador = 4
3. Avanzar 2 turnos → contador = 2
4. Aplicar Regen de nuevo (4 turnos)
5. Ver contador

Resultado esperado:
Contador = 2 + 4 = 6 turnos
No resetea a 4, SUMA
```

#### **Test 4.2: Múltiples DOTs**
```yaml
Objetivo: Verificar que se acumulan correctamente

Setup:
1. Aplicar Bleeding
2. Aplicar Poison
3. Aplicar Burn
4. Avanzar 1 turno
5. Calcular HP perdido total

Resultado esperado:
Turno 1: -5 HP (Bleeding) -8 HP (Poison) -12 HP (Burn)
Total: -25 HP en 1 turno
```

---

### **VALORES DE REFERENCIA PARA TESTING**

#### **Player Stats Aproximados (nivel 1)**
```yaml
HP: 100
Mana: 50
ATK: 25-30
mATK: 20-25
DEF: 18-22
mDEF: 18-22
Speed: 15-20
Dodge: 12-18
Hit: 18-22
Crit: 15-20%
```

#### **Daños Esperados**
```yaml
Ataque básico: 10-20 HP
Power Strike: 15-35 HP
Fireball: 20-45 HP
Ice Shard: 15-30 HP

Con crítico: Cualquiera de los anteriores ×2
```

#### **Efectividad de Status**
```yaml
Regen: +32 HP en 4 turnos (~32% HP total)
Shield: Bloquea ~16-20 HP/turno
Poison: -32 HP en 4 turnos (~32% HP total)
Bleeding: -15 HP en 3 turnos si HP=100
Burn: -24 HP + sinergia con físicos
Freeze: Bloquea 1 turno + ~15 HP extra de amplificación
```

---

### **CHECKLIST DE VERIFICACIÓN**

#### **Visual**
- [ ] Iconos cambian de gris a color al activar
- [ ] Números de turnos aparecen y son legibles
- [ ] Números decrementan cada turno/evento
- [ ] Iconos desaparecen cuando llegan a 0 turnos

#### **Stats**
- [ ] ATK cambia con Strength/Berserk
- [ ] DEF cambia con Berserk/Burn
- [ ] Dodge cambia con Haste
- [ ] Hit cambia con Focus
- [ ] Valores regresan a normal cuando expiran

#### **Daño**
- [ ] Shield reduce daño ~40%
- [ ] Freeze amplifica daño ~40%
- [ ] DOTs hacen daño cada turno
- [ ] Críticos hacen ×2 daño

#### **Control**
- [ ] Freeze bloquea 100% de acciones (1 turno)
- [ ] Paralyze bloquea ~50% de acciones
- [ ] Confusion causa self-damage ~40%

#### **Decremento**
- [ ] Turnos bajan en combate
- [ ] Turnos bajan en eventos de capítulo
- [ ] Status con 0 turnos desaparecen

---

## 📝 NOTAS FINALES

### **Orden de Aplicación de Efectos**

```
1. Acción del jugador/enemigo (ataque, skill, item)
2. Calcular daño base
3. Aplicar multiplicadores de skill
4. Restar defensa
5. Calcular hit/miss
6. Calcular crítico
7. Aplicar Shield (si activo)
8. Aplicar Freeze (si activo)
9. Aplicar daño final
10. Actualizar buffs (Regen, etc.)
11. Actualizar debuffs (Poison, Bleeding, Burn, etc.)
12. Decrementar contadores de turnos
13. Eliminar status expirados (0 turnos)
```

### **Tips Generales**

1. **Siempre equipar antes de combate**
2. **Aplicar buffs antes de entrar en combate si es posible**
3. **DOTs son mejores en combates largos**
4. **Burst damage es mejor en combates cortos**
5. **Shield + Regen = supervivencia máxima**
6. **Berserk solo con Shield activo**
7. **Focus esencial contra enemigos evasivos**
8. **Freeze es el debuff más poderoso (usado correctamente)**

---

## 🏆 **FIN DEL MANUAL**

Este manual cubre todos los sistemas, mecánicas, stats, skills, buffs, debuffs, items y estrategias del juego.

**Para testing:** Sigue la Guía de Testing fase por fase.
**Para jugar:** Usa las secciones de Combos y Estrategias.
**Para entender:** Lee Sistema de Stats y Sistema de Combate.

**¡Buena suerte y buen testing!** 🎮