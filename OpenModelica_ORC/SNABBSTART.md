# ⚡ SNABBSTART - OpenModelica ORC-system

## 🎯 Installation på 5 minuter

### Steg 1: Förberedelse
1. Öppna **PowerShell som administratör**
   - Högerklicka på Start-knappen
   - Välj "Windows PowerShell (Admin)"

### Steg 2: Tillåt scripts (engångsinställning)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Tryck **Y** (Yes) och Enter

### Steg 3: Navigera till projektet
```powershell
cd "C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\OpenModelica_ORC\scripts"
```

### Steg 4: Kör installations-scriptet
```powershell
.\install_complete_windows.ps1
```

### Steg 5: Vänta
⏱️ Tar cirka 5-10 minuter
- Installerar OpenModelica
- Laddar ner 5 bibliotek
- Kopierar projekt
- Skapar genvägar

### Steg 6: Klart!
✅ Två nya genvägar på skrivbordet:
- **"OMEdit - ORC Project"** - Öppnar OpenModelica
- **"ORC Projekt"** - Öppnar projektmappen

---

## 🚀 Kör första simuleringen

### Steg 1: Öppna projektet
Dubbelklicka på **"OMEdit - ORC Project"** på skrivbordet

### Steg 2: Öppna modellen
- **File** → **Open Model/Library**
- Navigera till:
  ```
  C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\OpenModelica_ORC\models\Examples\CompleteORCSystem.mo
  ```
- Klicka **Open**

### Steg 3: Verifiera modellen
- Klicka på knappen **"Check Model"** (grön bock)
- Om allt är OK: Meddelande "The model is correct"

### Steg 4: Simulera
- Klicka på **"Simulate"**-knappen (grön play)
- Vänta 1-2 minuter medan simuleringen körs

### Steg 5: Visa resultat
- Gå till fliken **"Plotting"**
- I variabellistan (vänster sida), välj variabler att plotta:
  - `W_net` - Netto elektrisk effekt
  - `eta_system` - Systemverkningsgrad
  - `T_tank_top` - Tanktemperatur
  - `Q_solar_input` - Solinstrålning

---

## 📊 Viktiga variabler att mäta

### Effekter (W eller kW)
- `Q_solar_input` - Inkommande solenergi
- `W_turbine` - Turbineffekt
- `W_pump` - Pumpeffekt
- `W_net` - Netto eleffekt (turbine - pump)

### Verkningsgrader (%)
- `eta_system` - Total verkningsgrad (sol → el)
- `eta_ORC` - ORC-verkningsgrad
- `eta_turbine` - Turbin isentropisk verkningsgrad
- `eta_carnot` - Teoretisk maxverkningsgrad

### Temperaturer (K eller °C)
- `T_tank_top` - Temperatur topp av tank
- `T_evap_out` - Temperatur efter förångare
- `T_turbine_out` - Temperatur efter turbin
- `T_cond_out` - Temperatur efter kondensor

### Tryck (Pa eller bar)
- `p_high` - Högtryck (före turbin)
- `p_low` - Lågtryck (efter turbin)

### Energi (J eller kWh)
- `E_solar_collected` - Total insamlad solenergi
- `E_electrical_produced` - Total producerad el
- `E_stored_tank` - Energi lagrad i tank

### Tank
- `storageTank.SOC` - State of Charge (0-1)
- `storageTank.stratificationIndex` - Stratifieringskvalitet (0-1)

---

## 🎓 Forskningsfrågor - Snabbanalys

### 1. Systemverkningsgrad
**Fråga:** Hur mycket av solenergin blir el?

**Hur:**
- Plotta `eta_system` över tid
- Medelvärde: 5-8% förväntat

**Analys:**
```
Genomsnittlig verkningsgrad = Medelvärdet av eta_system
Jämför med Carnot-gräns (eta_carnot) = ~12-13%
```

### 2. Tesla-turbinens prestanda
**Fråga:** Hur bra är Tesla-turbinen?

**Hur:**
- Plotta `eta_turbine` över tid
- Jämför med konventionella expandrar (80-85%)

**Förväntad:**
- Tesla-turbin: 70-80%
- Fördel: Mycket enklare konstruktion!

### 3. Termisk lagring
**Fråga:** Hur hjälper tanken systemet?

**Hur:**
- Plotta `storageTank.SOC` och `W_net` tillsammans
- Se hur elproduktion fortsätter även när sol saknas

**Analys:**
- Hur länge kan systemet köra utan sol?
- Vilken SOC krävs för kontinuerlig drift?

### 4. Ekonomi
**Fråga:** Hur mycket energi per m² solfångare?

**Hur:**
```
Specifik energi = E_electrical_produced (slutvärde) / (10 m² × 3.6e6 J/kWh)
```

**Förväntat:**
- 0.3-0.6 kWh/m²/dag

---

## 🛠️ Felsökning

### Problem: "Execution policy" fel
**Lösning:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problem: Script hittas inte
**Lösning:** Kontrollera sökvägen, använd:
```powershell
ls
```
för att se vilka filer som finns i aktuell mapp

### Problem: OpenModelica installeras inte
**Lösning:** Ladda ner manuellt:
1. Gå till: https://openmodelica.org/download/
2. Ladda ner: OpenModelica-v1.23.0-64bit.exe
3. Installera
4. Kör scriptet igen

### Problem: "Model is not correct"
**Lösning:** Kontrollera att biblioteken är laddade:
- Tools → Options → Libraries
- Lägg till: `C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\OpenModelicaLibs`

### Problem: Simulering tar för lång tid
**Normal tid:** 1-2 minuter för 24 timmars simulering
**Om längre:** Stäng andra program, vänta

---

## 📖 Mer information

**Komplett dokumentation:**
```
C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\OpenModelica_ORC\README.md
```

**Forskningsfrågor:**
```
C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\OpenModelica_ORC\docs\research_questions.md
```

**Modeller:**
```
C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\OpenModelica_ORC\models\
```

---

## ✅ Checklista

- [ ] PowerShell som administratör öppnad
- [ ] Execution policy satt
- [ ] Installations-script kört
- [ ] OpenModelica installerat (kontrollera Start-meny)
- [ ] Genvägar på skrivbordet
- [ ] OMEdit startar utan fel
- [ ] CompleteORCSystem.mo öppnad
- [ ] "Check Model" ger OK
- [ ] Simulering klar
- [ ] Plots visas korrekt

**När alla är checkade: Du är redo att forska! 🎉**

---

## 💡 Tips

1. **Spara dina simuleringsresultat:**
   - File → Export → Plot → PNG/PDF

2. **Ändra simuleringstid:**
   - Simulation Setup → Stop time
   - 86400 sekunder = 24 timmar
   - 43200 sekunder = 12 timmar

3. **Ändra parametervar:**
   - Högerklicka på komponent i modellen
   - "Parameters" → Ändra värden
   - T.ex. solfångararea, tankvolym, etc.

4. **Exportera data för analys:**
   - Resultatfilen sparas automatiskt som .mat-fil
   - Kan importeras till MATLAB, Python, etc.

5. **Jämför olika konfigurationer:**
   - Kör flera simuleringar med olika parametrar
   - Spara varje resultat separat
   - Jämför i Excel eller Python

---

**Lycka till med dina ORC-simuleringar! 🚀**
