# 🆕 INSTALLATION PÅ NY DATOR

## Du är här för att projektet inte finns på din nya dator ännu!

Följ dessa steg för att ladda ner och installera allt från GitHub.

---

## ⚡ SNABBASTE SÄTTET (3 steg)

### Steg 1: Öppna PowerShell
- Tryck **Win + X**
- Välj **"Windows PowerShell"** (vanlig, INTE admin)

### Steg 2: Kör bootstrap-kommandot

Kopiera och klistra in detta i PowerShell (tryck Enter):

```powershell
$scriptUrl = "https://raw.githubusercontent.com/martensjacobjm/TeslaTurbine/claude/create-repository-011CUQKk4VgQKTu19T9xWSDS/OpenModelica_ORC/scripts/bootstrap.ps1"
Invoke-Expression (Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing).Content
```

Detta kommer att:
1. Skapa katalogen på OneDrive
2. Ladda ner projektet från GitHub
3. Visa instruktioner för installation

### Steg 3: Följ instruktionerna som visas

Bootstrap-scriptet kommer att visa exakt vad du ska göra härnäst!

---

## 📦 ALTERNATIV: Manuell nedladdning

Om ovanstående inte fungerar:

### Steg 1: Ladda ner projektet
1. Gå till: https://github.com/martensjacobjm/TeslaTurbine
2. Klicka på **"Code"** → **"Download ZIP"**
3. Spara ZIP-filen

### Steg 2: Packa upp
1. Packa upp ZIP-filen
2. Flytta den uppackade mappen till:
   ```
   C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\
   ```
3. Byt namn på mappen till: `TeslaTurbine`

### Steg 3: Kör installation
1. Öppna PowerShell som **administratör**
2. Kör:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Navigera:
   ```powershell
   cd "C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System\TeslaTurbine\OpenModelica_ORC\scripts"
   ```
4. Installera:
   ```powershell
   .\install_complete_windows.ps1
   ```

---

## 🔧 Om Git är installerat

Om du har Git installerat är det ännu enklare:

```powershell
# 1. Skapa katalogen
New-Item -ItemType Directory -Force -Path "C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System"

# 2. Navigera dit
cd "C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System"

# 3. Klona projektet
git clone https://github.com/martensjacobjm/TeslaTurbine.git

# 4. Byt till rätt branch
cd TeslaTurbine
git checkout claude/create-repository-011CUQKk4VgQKTu19T9xWSDS

# 5. Kör installation (som admin)
cd "OpenModelica_ORC\scripts"
.\install_complete_windows.ps1
```

---

## ❓ Felsökning

### Problem: "Cannot connect to GitHub"
**Lösning:** Kontrollera din internetanslutning och försök igen.

### Problem: "Execution policy" fel
**Lösning:** Öppna PowerShell som administratör och kör:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problem: OneDrive-mappen finns inte
**Lösning:**
1. Kontrollera att OneDrive är konfigurerat på datorn
2. Verifiera att sökvägen är korrekt:
   ```
   C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat
   ```
3. Skapa mappen "Simulering System" manuellt om den inte finns

### Problem: Bootstrap-scriptet fungerar inte
**Lösning:** Använd "ALTERNATIV: Manuell nedladdning" istället.

---

## 📋 Efter nedladdning

När projektet är nedladdat fortsätter du med installations-scriptet som installerar:
- ✅ OpenModelica
- ✅ Alla Modelica-bibliotek
- ✅ Projektfiler
- ✅ Genvägar

Se **OpenModelica_ORC/SNABBSTART.md** för detaljer!

---

## 💡 Kontakta support

Om något går fel, kontrollera:
1. Internetanslutning
2. OneDrive är konfigurerat och synkat
3. Tillräckligt diskutrymme (~500 MB)

**Lycka till med installationen! 🚀**
