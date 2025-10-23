# Forskningsfrågor - ORC-system med Tesla-turbin

## Innehåll
1. [Systemverkningsgrad](#1-systemverkningsgrad)
2. [Tesla-turbinens prestanda](#2-tesla-turbinens-prestanda)
3. [Termisk lagring](#3-termisk-lagring)
4. [Ekonomi och praktisk tillämpning](#4-ekonomi-och-praktisk-tillämpning)
5. [Jämförande analys](#5-jämförande-analys)
6. [Optimering](#6-optimering)

---

## 1. Systemverkningsgrad

### Huvudfråga
**Hur effektivt kan systemet omvandla solenergi till elektrisk energi med en Tesla-turbin som expander?**

### Delfrågpr

#### 1.1 Total systemverkningsgrad
**Fråga:** Vad är den totala verkningsgraden från sol till el?

**Mätvariabler:**
```modelica
eta_system = W_net / Q_solar_input
```

**Variablerna:**
- `Q_solar_input` - Inkommande solenergi [W]
- `W_net` - Netto elektrisk effekt (W_turbine - W_pump) [W]
- `eta_system` - Total systemverkningsgrad [-]

**Förväntat resultat:**
- Vid optimal drift: 5-8%
- Vid delast: 2-5%
- Jämfört med solceller: 15-20% (men ORC kan även utnyttja spillvärme)

**Analys:**
```python
# I plot_results.py
eta_avg = np.mean(data['eta_system'][data['Q_solar'] > 100])
print(f"Genomsnittlig systemverkningsgrad: {eta_avg*100:.2f}%")
```

#### 1.2 ORC-verkningsgrad
**Fråga:** Hur effektivt omvandlas tillförd värme till el i ORC-kretsen?

**Mätvariabler:**
```modelica
eta_ORC = W_net / Q_to_ORC
```

**Förväntat resultat:**
- Vid nominal drift: 8-12%
- Carnot-limit för T_hot=85°C, T_cold=40°C: ~12.6%
- Praktisk verkningsgrad: ~60-80% av Carnot

**Jämförelse med teori:**
```modelica
eta_carnot = 1 - T_cond_nominal / T_evap_nominal
ratio = eta_ORC / eta_carnot  // Förväntat: 0.6-0.8
```

#### 1.3 Inverkan av driftparametrar

**Parameterstudie 1: Förångningstemperatur**
```modelica
// Variera T_evap från 70°C till 100°C
for T_evap in 343.15:5:373.15 loop
  simulate(CompleteORCSystem(evaporator.T_evap_nominal=T_evap));
end for;
```

**Hypotes:** Högre T_evap → högre verkningsgrad (närmare Carnot)

**Parameterstudie 2: Kondensortemperatur**
```modelica
// Variera T_cond från 30°C till 50°C
for T_cond in 303.15:5:323.15 loop
  simulate(CompleteORCSystem(condenser.T_cond_nominal=T_cond));
end for;
```

**Hypotes:** Lägre T_cond → högre verkningsgrad

**Parameterstudie 3: Massflöde**
```modelica
// Variera massflöde från 0.3 till 0.8 kg/s
for m_flow in 0.3:0.1:0.8 loop
  simulate(CompleteORCSystem(m_flow_wf_nominal=m_flow));
end for;
```

**Hypotes:** Optimalt massflöde ger maximal effekt

---

## 2. Tesla-turbinens prestanda

### Huvudfråga
**Hur presterar Tesla-turbinen jämfört med konventionella expandrar i ORC-tillämpningar?**

### Delfrågor

#### 2.1 Isentropisk verkningsgrad

**Fråga:** Vilken isentropisk verkningsgrad uppnår Tesla-turbinen?

**Mätvariabler:**
```modelica
eta_is = (h_in - h_out) / (h_in - h_out_s)
```

**Variablerna:**
- `h_in` - Inloppsentalpi [J/kg]
- `h_out` - Faktisk utloppsentalpi [J/kg]
- `h_out_s` - Isentropisk utloppsentalpi [J/kg]
- `eta_is` - Isentropisk verkningsgrad [-]

**Förväntat resultat:**
- Tesla-turbin: 70-80%
- Scroll-expander: 75-85%
- Turbin-expander: 80-90%
- Skruvexpander: 70-80%

**Jämförelse:**
```python
# Analysera verkningsgrad vid olika tryckförhållanden
pr = data['p_high'] / data['p_low']
plt.scatter(pr, data['eta_turbine']*100)
plt.xlabel('Tryckförhållande')
plt.ylabel('Isentropisk verkningsgrad [%]')
```

#### 2.2 Effekttäthet

**Fråga:** Hur stor effekt per volym kan Tesla-turbinen generera?

**Mätvariabler:**
```modelica
V_turbine = pi * (diskDiameter/2)^2 * diskSpacing * numberOfDisks
powerDensity = W_actual / V_turbine  // [W/m³]
```

**Förväntat resultat:**
- Tesla-turbin: 10-50 MW/m³
- Konventionell turbin: 50-200 MW/m³

**Fördel med Tesla-turbin:**
Även om effekttätheten är lägre är konstruktionen mycket enklare och billigare!

#### 2.3 Rotationshastighet

**Fråga:** Vilken rotationshastighet ger optimal prestanda?

**Mätvariabler:**
- `omega` - Vinkelhastighet [rad/s]
- `RPM = omega * 60 / (2*pi)` - Varv per minut

**Parameterstudie:**
```modelica
// Variera rotationshastighet
for rpm in 3000:500:7000 loop
  omega = rpm * 2*pi/60;
  simulate(CompleteORCSystem(turbine.omega_nominal=omega));
end for;
```

**Hypotes:** Det finns en optimal rotationshastighet där:
- För lågt: Dålig energiextraktion
- För högt: Ökade friktionsförluster

#### 2.4 Inverkan av geometri

**Fråga 1: Diskavstånd**
```modelica
// Variera diskavstånd från 0.3 mm till 1.0 mm
for spacing in 0.0003:0.0001:0.001 loop
  simulate(CompleteORCSystem(turbine.diskSpacing=spacing));
end for;
```

**Hypotes:**
- Mindre avstånd → Högre verkningsgrad (mer viskös dragning)
- Mindre avstånd → Högre tryckfall → Lägre massflöde

**Fråga 2: Antal skivor**
```modelica
// Variera antal skivor från 10 till 40
for n in 10:5:40 loop
  simulate(CompleteORCSystem(turbine.numberOfDisks=n));
end for;
```

**Hypotes:**
- Fler skivor → Mer effektuttag
- Fler skivor → Högre tröghet → Långsammare dynamik

---

## 3. Termisk lagring

### Huvudfråga
**Hur mycket förbättrar den stratifierade ackumulatortanken systemets prestanda och kontinuitet?**

### Delfrågor

#### 3.1 Kapacitet och SOC

**Fråga:** Hur mycket energi kan tanken lagra och hur påverkar detta systemdriften?

**Mätvariabler:**
```modelica
E_stored = sum({m_layer * cp * (T[i] - T_ref) for i in 1:nLayers})
SOC = E_stored / E_stored_max
```

**Analys:**
```python
# Analysera SOC över 24 timmar
plt.plot(data['t_hours'], data['SOC']*100)
plt.axhline(y=80, color='r', linestyle='--', label='Hög nivå')
plt.axhline(y=20, color='orange', linestyle='--', label='Låg nivå')
```

**Frågor att besvara:**
1. Vid vilken SOC kan ORC-systemet drivas kontinuerligt?
2. Hur länge kan systemet köras utan sol?
3. Hur ofta behöver tanken laddas?

#### 3.2 Stratifiering

**Fråga:** Hur viktig är stratifieringen för systemets prestanda?

**Mätvariabler:**
```modelica
dT_stratification = T_top - T_bottom
stratificationIndex = dT_stratification / (T_top - T_ambient)
```

**Stratifieringsindex:**
- 1.0 = Perfekt stratifierad (varmt topp, kallt botten)
- 0.0 = Fullständigt mixad (samma temperatur överallt)

**Jämförelsestudie:**
Simulera med och utan stratifiering:
```modelica
// Med stratifiering (5 lager)
simulate(CompleteORCSystem(storageTank.nLayers=5));

// Utan stratifiering (1 lager - fullständigt mixad)
simulate(CompleteORCSystem(storageTank.nLayers=1));
```

**Förväntad skillnad:**
- Med stratifiering: Högre tillgänglig temperatur → Bättre ORC-verkningsgrad
- Utan stratifiering: Lägre medeltemperatur → Sämre verkningsgrad

#### 3.3 Tankvolym

**Fråga:** Vilken tankvolym är optimal för given solfångararea?

**Parameterstudie:**
```modelica
// Variera tankvolym från 0.5 m³ till 3.0 m³
for V in 0.5:0.5:3.0 loop
  simulate(CompleteORCSystem(storageTank.V_tank=V));
end for;
```

**Dimensioneringsregel (empirisk):**
```
V_tank = A_collector * 50-100 liter/m²
```

För 10 m² solfångare:
- Minimum: 0.5 m³
- Rekommenderat: 1.0 m³
- Maximum: 1.5 m³

#### 3.4 Värmeförluster

**Fråga:** Hur stora är värmeförlusterna och hur påverkar de systemet?

**Mätvariabler:**
```modelica
Q_loss_total = sum(Q_loss[i] for i in 1:nLayers)
loss_fraction = Q_loss_total / Q_solar_input
```

**Analys:**
```python
# Beräkna dagliga förluster
daily_loss = np.trapz(data['Q_loss_tank'], data['t_seconds'])
daily_solar = np.trapz(data['Q_solar'], data['t_seconds'])
loss_percent = (daily_loss / daily_solar) * 100
print(f"Dagliga värmeförluster: {loss_percent:.1f}%")
```

**Förbättringar:**
- Bättre isolering → Lägre förluster
- Större tank → Relativt mindre förluster per volym

---

## 4. Ekonomi och praktisk tillämpning

### Huvudfråga
**Är systemet ekonomiskt lönsamt och praktiskt genomförbart?**

### Delfrågor

#### 4.1 Specifik energiproduktion

**Fråga:** Hur mycket el produceras per m² solfångare och dag?

**Mätvariabler:**
```modelica
specificEnergy = E_electrical_produced / (A_collector * 3600000)  // kWh/m²/dag
```

**Förväntat resultat:**
- Sommardrift (God solinstrålning): 0.5-1.0 kWh/m²/dag
- Vinterdrift (Låg solinstrålning): 0.1-0.3 kWh/m²/dag
- Årsmedeltal: 0.3-0.6 kWh/m²/dag

**Jämförelse:**
- Solceller (PV): 1.5-3.0 kWh/m²/dag (högre verkningsgrad)
- Solfångare + ORC: Kan även utnyttja spillvärme och diffus strålning

#### 4.2 Ekonomisk analys

**Investeringskostnad (uppskattning):**
```
Solfångare (10 m²):       30,000 kr (3,000 kr/m²)
Ackumulatortank (1 m³):   15,000 kr
Tesla-turbin + generator: 50,000 kr
ORC-komponenter:          40,000 kr
Installation:             20,000 kr
--------------------------------------
TOTALT:                  155,000 kr
```

**Årlig energiproduktion:**
```
Specifik energi: 0.4 kWh/m²/dag
Total area: 10 m²
Dagar per år: 365

Årlig produktion = 0.4 × 10 × 365 = 1,460 kWh/år
```

**Payback-tid:**
```
Elpris: 2 kr/kWh
Årlig intäkt: 1,460 × 2 = 2,920 kr

Payback-tid = 155,000 / 2,920 ≈ 53 år
```

**Slutsats:**
Med enbart elproduktion är systemet INTE ekonomiskt lönsamt.

**MEN:** Systemet kan bli lönsamt om:
1. Spillvärmen utnytjas för uppvärmning (kombinerad el + värme)
2. Högre elpriser eller elcertifikat
3. Lägre tillverkningskostnader (skalfördelar)
4. Industriell spillvärme istället för sol (gratis värmekälla)

#### 4.3 Tillämpningsområden

**Fråga:** Var är systemet mest lämpligt?

**1. Villa/småhus (SVÅRT)**
- ❌ För hög investeringskostnad
- ❌ Långsammare payback
- ✅ Kan kombineras med uppvärmning

**2. Industriell spillvärme (UTMÄRKT)**
- ✅ Gratis värmekälla (spillvärme annars bortkastad)
- ✅ Kontinuerlig drift (inte beroende av sol)
- ✅ Kortare payback-tid (1-5 år)
- ✅ Stora volymer

**3. Fjärrvärmenät (BRA)**
- ✅ Kan mata in el till nätet
- ✅ Spillvärme används för fjärrvärme
- ✅ Höga elpriser vid toppbelastning

**4. Off-grid tillämpningar (INTRESSANT)**
- ✅ Där elnät saknas
- ✅ Kombination med diesel/biobränsle
- ✅ Termisk lagring för kontinuitet

#### 4.4 Miljöpåverkan

**CO₂-utsläpp (livscykel):**
```
Tillverkning: ~5,000 kg CO₂
Transport: ~500 kg CO₂
Installation: ~300 kg CO₂
------------------------------
TOTALT: ~5,800 kg CO₂

Årlig besparing (ersätter kolkraft):
1,460 kWh × 0.8 kg CO₂/kWh = 1,168 kg CO₂/år

Energy payback time: 5,800 / 1,168 ≈ 5 år
```

**R245fa GWP:**
- GWP: 950 (medel, ej bra)
- Läckage per år: ~5% (vid dåligt underhåll)
- Ersättare: R1233zd (GWP=7), R1234ze (GWP=6)

---

## 5. Jämförande analys

### 5.1 Tesla-turbin vs. Konventionella expandrar

| Parameter | Tesla-turbin | Scroll | Turbin | Skruv |
|-----------|-------------|--------|--------|-------|
| Isentropisk verkningsgrad | 70-80% | 75-85% | 80-90% | 70-80% |
| Kostnad | Låg | Medel | Hög | Hög |
| Komplexitet | Enkel | Medel | Hög | Hög |
| Underhåll | Minimalt | Lågt | Medel | Medel |
| Livslängd | Lång | Medel | Lång | Medel |
| Två-fas förmåga | Utmärkt | Dålig | Medel | Medel |

**Slutsats:**
Tesla-turbinen är bäst för:
- Små ORC-system (<10 kW)
- Låg budget
- Enkel konstruktion
- Tvåfasflöden

### 5.2 ORC vs. Andra teknologier

| Teknologi | Verkningsgrad | Kostnad | Temperatur |
|-----------|---------------|---------|------------|
| ORC | 5-15% | Medel | 60-150°C |
| Ångturbin | 15-40% | Hög | >150°C |
| Stirlingmotor | 10-25% | Hög | 100-300°C |
| TEG (Termoelektrisk) | 3-8% | Medel | Alla |
| Solceller | 15-22% | Låg-Medel | Ljus |

---

## 6. Optimering

### 6.1 Multivariabel optimering

**Målfunktion:**
Maximera:
```
Objective = Net Present Value (NPV)
          = Σ(årlig_intäkt / (1+discount_rate)^år) - investering
```

**Designvariabler:**
1. Solfångararea (A_collector)
2. Tankvolym (V_tank)
3. Förångningstemperatur (T_evap)
4. Kondensortemperatur (T_cond)
5. Turbingeometri (diskDiameter, numberOfDisks, diskSpacing)
6. Massflöde (m_flow)

**Bivillkor:**
- A_collector: 5-50 m²
- V_tank: 0.5-5.0 m³
- T_evap: 70-100°C
- T_cond: 30-50°C
- p_high < p_critical för R245fa

**Optimeringsmetod:**
- Genetisk algoritm
- Particle Swarm Optimization
- Gradient-baserad optimering

### 6.2 Optimala driftstrategier

**Fråga:** När ska ORC-systemet köras?

**Strategi 1: Kontinuerlig drift**
- Kör ORC när T_tank_top > T_min (t.ex. 70°C)
- Stoppa när T_tank_top < T_min

**Strategi 2: On/off med hysteres**
- Starta ORC när SOC > 0.6
- Stoppa när SOC < 0.3

**Strategi 3: Variabel last**
- Anpassa massflöde efter tillgänglig värme
- Håll högsta möjliga verkningsgrad

---

## Sammanfattning - Nyckelresultat att rapportera

### Kvantitativa resultat:

1. **Systemverkningsgrad:** ___ % (vid nominell drift)
2. **Turbin isentropisk verkningsgrad:** ___ %
3. **Specifik energiproduktion:** ___ kWh/m²/dag
4. **Payback-tid:** ___ år
5. **CO₂-besparing:** ___ kg/år

### Kvalitativa resultat:

1. **Tesla-turbinens fördelar:**
   - Enkel och billig konstruktion
   - Lämplig för små ORC-system
   - Kan hantera tvåfasflöde

2. **Tesla-turbinens nackdelar:**
   - Något lägre verkningsgrad än konventionella expandrar
   - Känslig för diskavstånd och rotationshastighet

3. **Termisk lagring:**
   - Absolut nödvändig för soldriven ORC
   - Stratifiering förbättrar prestanda avsevärt
   - Optimal volym: ~100 liter/m² solfångare

4. **Ekonomi:**
   - Ej lönsamt med enbart elproduktion från sol
   - Mycket lovande för industriell spillvärme
   - Kombinerad el+värme kan göra det lönsamt

---

**Lycka till med forskningen!** 🎓
