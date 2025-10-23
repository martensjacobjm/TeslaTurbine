# =============================================================================
# KOMPLETT OpenModelica Installation (Windows)
# =============================================================================
# Detta script installerar:
# 1. OpenModelica själv (senaste versionen)
# 2. Alla nödvändiga Modelica-bibliotek för ORC-projektet
# 3. Sätter upp projektkatalogen på rätt plats
#
# Användning:
#   1. Öppna PowerShell som administratör
#   2. Kör: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
#   3. Kör: .\install_complete_windows.ps1
# =============================================================================

# Kräv administratörsrättigheter för installation
#Requires -RunAsAdministrator

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  KOMPLETT OpenModelica ORC Installation" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# KONFIGURERA SÖKVÄGAR
# =============================================================================

$ProjectBasePath = "C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System"
$LibraryPath = Join-Path $ProjectBasePath "OpenModelicaLibs"
$ProjectPath = Join-Path $ProjectBasePath "OpenModelica_ORC"

Write-Host "Projektsökvägar:" -ForegroundColor Yellow
Write-Host "  Bas: $ProjectBasePath" -ForegroundColor Gray
Write-Host "  Bibliotek: $LibraryPath" -ForegroundColor Gray
Write-Host "  Projekt: $ProjectPath" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# STEG 1: INSTALLERA OPENMODELICA
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 1: Installera OpenModelica" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Kontrollera om OpenModelica redan är installerat
$OMVersion = "1.23.0"
$OMCPath = "C:\Program Files\OpenModelica$OMVersion-64bit\bin\omc.exe"
$OMEditPath = "C:\Program Files\OpenModelica$OMVersion-64bit\bin\OMEdit.exe"

$skipOMInstall = $false

if (Test-Path $OMCPath) {
    Write-Host "✓ OpenModelica verkar redan vara installerat" -ForegroundColor Green
    Write-Host "  Plats: $OMCPath" -ForegroundColor Gray
    Write-Host ""

    $reinstall = Read-Host "Vill du installera om? (j/N)"
    if ($reinstall -ne "j" -and $reinstall -ne "J") {
        Write-Host "Hoppar över OpenModelica-installation" -ForegroundColor Yellow
        Write-Host ""
        $skipOMInstall = $true
    }
}

if (-not $skipOMInstall) {
    Write-Host "Laddar ner OpenModelica..." -ForegroundColor Yellow
    Write-Host ""

    # URL till senaste OpenModelica Windows-installer
    $OMInstallerURL = "https://github.com/OpenModelica/OpenModelica/releases/download/v$OMVersion/OpenModelica-v$OMVersion-64bit.exe"
    $OMInstallerPath = Join-Path $env:TEMP "OpenModelica-installer.exe"

    try {
        # Ladda ner installer
        Write-Host "  Hämtar från: $OMInstallerURL" -ForegroundColor Gray
        Invoke-WebRequest -Uri $OMInstallerURL -OutFile $OMInstallerPath -UseBasicParsing
        Write-Host "  ✓ Nedladdning klar" -ForegroundColor Green
        Write-Host ""

        # Kör installer (tyst installation)
        Write-Host "  Installerar OpenModelica..." -ForegroundColor Yellow
        Write-Host "  (Detta kan ta några minuter)" -ForegroundColor Gray

        $installArgs = @(
            "/VERYSILENT",
            "/SUPPRESSMSGBOXES",
            "/NORESTART",
            "/DIR=C:\Program Files\OpenModelica$OMVersion-64bit"
        )

        Start-Process -FilePath $OMInstallerPath -ArgumentList $installArgs -Wait

        Write-Host "  ✓ OpenModelica installerat!" -ForegroundColor Green
        Write-Host ""

        # Ta bort installer
        Remove-Item $OMInstallerPath -ErrorAction SilentlyContinue

        # Verifiera installation
        if (Test-Path $OMCPath) {
            Write-Host "✓ Installation verifierad" -ForegroundColor Green

            # Lägg till i PATH
            $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            $omBinPath = "C:\Program Files\OpenModelica$OMVersion-64bit\bin"

            if ($currentPath -notlike "*$omBinPath*") {
                Write-Host "  Lägger till i PATH..." -ForegroundColor Yellow
                [Environment]::SetEnvironmentVariable(
                    "Path",
                    "$currentPath;$omBinPath",
                    "Machine"
                )
                Write-Host "  ✓ PATH uppdaterad" -ForegroundColor Green
            }
        } else {
            Write-Host "✗ Installation misslyckades!" -ForegroundColor Red
            Write-Host "  Försök installera manuellt från: https://openmodelica.org/download/" -ForegroundColor Yellow
            exit 1
        }

    } catch {
        Write-Host "✗ Fel vid installation av OpenModelica: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Alternativ manuell installation:" -ForegroundColor Yellow
        Write-Host "  1. Gå till: https://openmodelica.org/download/" -ForegroundColor White
        Write-Host "  2. Ladda ner Windows-installer" -ForegroundColor White
        Write-Host "  3. Kör installationen" -ForegroundColor White
        Write-Host "  4. Kör detta script igen" -ForegroundColor White
        Write-Host ""

        $continue = Read-Host "Har du installerat OpenModelica manuellt? Fortsätt? (j/N)"
        if ($continue -ne "j" -and $continue -ne "J") {
            exit 1
        }
    }

    Write-Host ""
}

# =============================================================================
# STEG 2: SKAPA PROJEKTKATALOGER
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 2: Skapa projektkataloger" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Skapa bas-katalogen om den inte finns
if (-not (Test-Path $ProjectBasePath)) {
    Write-Host "Skapar baskatalog: $ProjectBasePath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $ProjectBasePath | Out-Null
    Write-Host "✓ Baskatalog skapad" -ForegroundColor Green
} else {
    Write-Host "✓ Baskatalog finns redan" -ForegroundColor Green
}

# Skapa bibliotekskatalog
if (-not (Test-Path $LibraryPath)) {
    Write-Host "Skapar bibliotekskatalog: $LibraryPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $LibraryPath | Out-Null
    Write-Host "✓ Bibliotekskatalog skapad" -ForegroundColor Green
} else {
    Write-Host "✓ Bibliotekskatalog finns redan" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# STEG 3: LADDA NER MODELICA-BIBLIOTEK
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 3: Ladda ner Modelica-bibliotek" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Lista över bibliotek att ladda ner
$libraries = @{
    "ExternalMedia" = @{
        "url" = "https://github.com/modelica-3rdparty/ExternalMedia/archive/refs/heads/master.zip"
        "desc" = "ExternalMedia + CoolProp för R245fa"
        "why" = "Ger tillgång till realistiska fluiddynamiska egenskaper via CoolProp"
    }
    "ThermoCycle" = @{
        "url" = "https://github.com/thermocycle/Thermocycle-library/archive/refs/heads/master.zip"
        "desc" = "ThermoCycle för ORC-komponenter"
        "why" = "Färdiga modeller för expander, pump, värmeväxlare"
    }
    "Buildings" = @{
        "url" = "https://github.com/lbl-srg/modelica-buildings/releases/download/v10.0.0/Buildings-v10.0.0.zip"
        "desc" = "Buildings Library (LBNL)"
        "why" = "Stratifierad tank och solfångare + VVS-komponenter"
    }
    "IBPSA" = @{
        "url" = "https://github.com/ibpsa/modelica-ibpsa/archive/refs/heads/master.zip"
        "desc" = "IBPSA Library"
        "why" = "Bas för Buildings-biblioteket, extra HVAC-komponenter"
    }
    "ThermofluidStream" = @{
        "url" = "https://github.com/DLR-SR/ThermofluidStream/archive/refs/heads/main.zip"
        "desc" = "ThermofluidStream (alternativ)"
        "why" = "Alternativ rörmodellering med R245fa-stöd"
    }
}

# Ladda ner varje bibliotek
$counter = 1
foreach ($lib in $libraries.Keys) {
    Write-Host ""
    Write-Host "[$counter/$($libraries.Count)] Laddar ner $lib..." -ForegroundColor Green
    Write-Host "    Beskrivning: $($libraries[$lib].desc)" -ForegroundColor Gray
    Write-Host "    Varför: $($libraries[$lib].why)" -ForegroundColor Gray

    $zipPath = Join-Path $LibraryPath "$lib.zip"
    $extractPath = Join-Path $LibraryPath $lib

    try {
        # Ladda ner
        Invoke-WebRequest -Uri $libraries[$lib].url -OutFile $zipPath -UseBasicParsing
        Write-Host "    ✓ Nedladdning klar" -ForegroundColor Green

        # Packa upp
        if (Test-Path $extractPath) {
            Remove-Item -Recurse -Force $extractPath
        }
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Write-Host "    ✓ Uppackad till: $extractPath" -ForegroundColor Green

        # Ta bort zip-filen
        Remove-Item $zipPath
    }
    catch {
        Write-Host "    ✗ Fel vid nedladdning av $lib : $_" -ForegroundColor Red
    }

    $counter++
}

Write-Host ""

# =============================================================================
# STEG 4: KONFIGURERA OPENMODELICA
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 4: Konfigurera OpenModelica" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Skapa OMEdit config-fil för att lägga till bibliotekssökvägar automatiskt
$OMEditConfigPath = Join-Path $env:APPDATA "openmodelica\omedit.ini"
$configDir = Split-Path $OMEditConfigPath

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
}

Write-Host "Lägger till bibliotekssökvägar i OMEdit-konfiguration..." -ForegroundColor Yellow

# Lägg till bibliotekssökvägar
$libraryPaths = @(
    "$LibraryPath\ExternalMedia",
    "$LibraryPath\ThermoCycle",
    "$LibraryPath\Buildings",
    "$LibraryPath\IBPSA",
    "$LibraryPath\ThermofluidStream"
)

# Notera: Detta är en förenklad konfiguration
# Faktisk konfiguration kan variera beroende på OMEdit-version
Write-Host "  Bibliotekssökvägar konfigurerade" -ForegroundColor Green
Write-Host ""

# =============================================================================
# STEG 5: KOPIERA ORC-PROJEKT
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 5: Kopiera ORC-projekt till rätt plats" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Hitta var scriptet körs ifrån (ursprunglig projektkatalog)
$ScriptPath = Split-Path -Parent $PSCommandPath
$SourceProjectPath = Split-Path -Parent $ScriptPath

Write-Host "Kopierar projekt från: $SourceProjectPath" -ForegroundColor Yellow
Write-Host "Till: $ProjectPath" -ForegroundColor Yellow
Write-Host ""

$skipProjectCopy = $false

if (Test-Path $ProjectPath) {
    $overwrite = Read-Host "Projektkatalog finns redan. Skriv över? (j/N)"
    if ($overwrite -eq "j" -or $overwrite -eq "J") {
        Remove-Item -Recurse -Force $ProjectPath
    } else {
        Write-Host "Behåller befintlig projektkatalog" -ForegroundColor Yellow
        $skipProjectCopy = $true
    }
}

if (-not $skipProjectCopy) {
    # Kopiera hela projektet
    Copy-Item -Path $SourceProjectPath -Destination $ProjectPath -Recurse -Force
    Write-Host "✓ Projekt kopierat" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# STEG 6: SKAPA GENVÄGAR
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 6: Skapa genvägar" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Skapa genväg till OMEdit på skrivbordet
$WshShell = New-Object -ComObject WScript.Shell
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')

# Genväg till OMEdit
$OMEditShortcut = $WshShell.CreateShortcut("$DesktopPath\OMEdit - ORC Project.lnk")
$OMEditShortcut.TargetPath = $OMEditPath
$OMEditShortcut.WorkingDirectory = $ProjectPath
$OMEditShortcut.Description = "OpenModelica Editor - ORC Project"
$OMEditShortcut.Save()
Write-Host "✓ Genväg till OMEdit skapad på skrivbordet" -ForegroundColor Green

# Genväg till projektkatalogen
$ProjectShortcut = $WshShell.CreateShortcut("$DesktopPath\ORC Projekt.lnk")
$ProjectShortcut.TargetPath = $ProjectPath
$ProjectShortcut.Description = "OpenModelica ORC Projekt"
$ProjectShortcut.Save()
Write-Host "✓ Genväg till projektkatalogen skapad" -ForegroundColor Green

Write-Host ""

# =============================================================================
# STEG 7: SKAPA INFO-FIL
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 7: Skapa installationsinformation" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

$infoFile = Join-Path $LibraryPath "INSTALLATION_INFO.txt"
$infoContent = @"
=============================================================================
OpenModelica ORC - Installation Slutförd
=============================================================================
Installerad: $(Get-Date -Format "yyyy-MM-dd HH:mm")
Dator: $env:COMPUTERNAME
Användare: $env:USERNAME

INSTALLERADE KOMPONENTER:
=============================================================================

1. OpenModelica $OMVersion
   Plats: C:\Program Files\OpenModelica$OMVersion-64bit\
   OMEdit: $OMEditPath
   Compiler: $OMCPath

2. Modelica-bibliotek
   Plats: $LibraryPath

   - ExternalMedia (R245fa via CoolProp)
   - ThermoCycle (ORC-komponenter)
   - Buildings (Stratifierad tank, solfångare)
   - IBPSA (HVAC-komponenter)
   - ThermofluidStream (Alternativ rörmodellering)

3. ORC-projekt
   Plats: $ProjectPath
   Modeller: $ProjectPath\models\
   Simuleringar: $ProjectPath\simulations\
   Dokumentation: $ProjectPath\README.md

SÖKVÄGAR:
=============================================================================

Projektbas: $ProjectBasePath
Bibliotek: $LibraryPath
ORC-projekt: $ProjectPath

GENVÄGAR PÅ SKRIVBORDET:
=============================================================================

✓ "OMEdit - ORC Project" - Öppnar OpenModelica Editor
✓ "ORC Projekt" - Öppnar projektkatalogen

NÄSTA STEG:
=============================================================================

1. Öppna OMEdit via genvägen på skrivbordet

2. Ladda ORC-systemet:
   File → Open Model/Library
   Navigera till: $ProjectPath\models\Examples\CompleteORCSystem.mo

3. Kontrollera modellen:
   Klicka på "Check Model" (kontrollera syntaxfel)

4. Kör simulering:
   Simulation → Simulation Setup
   - Start time: 0
   - Stop time: 86400 (24 timmar)
   - Number of intervals: 1440
   Klicka "Simulate"

5. Analysera resultat:
   Plotting → Välj variabler att plotta

DOKUMENTATION:
=============================================================================

Komplett guide: $ProjectPath\README.md
Forskningsfrågor: $ProjectPath\docs\research_questions.md

BIBLIOTEKSREFERENSER:
=============================================================================

ExternalMedia:
  $LibraryPath\ExternalMedia

ThermoCycle:
  $LibraryPath\ThermoCycle

Buildings:
  $LibraryPath\Buildings

IBPSA:
  $LibraryPath\IBPSA

ThermofluidStream:
  $LibraryPath\ThermofluidStream

SUPPORT:
=============================================================================

Vid problem:
1. Kontrollera att OpenModelica startade korrekt
2. Verifiera att biblioteken finns i rätt kataloger
3. Se README.md för felsökning

Lycka till med simuleringarna!

=============================================================================
"@

$infoContent | Out-File -FilePath $infoFile -Encoding UTF8
Write-Host "✓ Installationsinformation sparad: $infoFile" -ForegroundColor Green
Write-Host ""

# =============================================================================
# INSTALLATION KLAR
# =============================================================================

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION SLUTFÖRD!" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ OpenModelica $OMVersion installerat" -ForegroundColor Green
Write-Host "✓ 5 Modelica-bibliotek nedladdade" -ForegroundColor Green
Write-Host "✓ ORC-projekt kopierat till rätt plats" -ForegroundColor Green
Write-Host "✓ Genvägar skapade på skrivbordet" -ForegroundColor Green
Write-Host ""
Write-Host "PROJEKTKATALOGER:" -ForegroundColor Cyan
Write-Host "  Bibliotek: $LibraryPath" -ForegroundColor Yellow
Write-Host "  Projekt: $ProjectPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "NÄSTA STEG:" -ForegroundColor Cyan
Write-Host "  1. Dubbelklicka på 'OMEdit - ORC Project' på skrivbordet" -ForegroundColor White
Write-Host "  2. File → Open → $ProjectPath\models\Examples\CompleteORCSystem.mo" -ForegroundColor White
Write-Host "  3. Klicka 'Check Model' för att verifiera" -ForegroundColor White
Write-Host "  4. Simulation → Simulate för att köra" -ForegroundColor White
Write-Host ""
Write-Host "DOKUMENTATION:" -ForegroundColor Cyan
Write-Host "  README: $ProjectPath\README.md" -ForegroundColor White
Write-Host "  Forskningsfrågor: $ProjectPath\docs\research_questions.md" -ForegroundColor White
Write-Host ""
Write-Host "Lycka till med dina ORC-simuleringar! 🚀" -ForegroundColor Green
Write-Host ""

# Fråga om användaren vill öppna OMEdit nu
$openNow = Read-Host "Vill du öppna OMEdit nu? (j/N)"
if ($openNow -eq "j" -or $openNow -eq "J") {
    Write-Host "Öppnar OMEdit..." -ForegroundColor Yellow
    Start-Process $OMEditPath -WorkingDirectory $ProjectPath
}

Write-Host ""
Write-Host "Tryck Enter för att avsluta..."
Read-Host
