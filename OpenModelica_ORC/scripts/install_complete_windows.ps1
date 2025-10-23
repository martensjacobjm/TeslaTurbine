# =============================================================================
# KOMPLETT OpenModelica Installation (Windows)
# =============================================================================
# Detta script installerar:
# 1. OpenModelica sjalv (senaste versionen)
# 2. Alla nodvandiga Modelica-bibliotek for ORC-projektet
# 3. Satter upp projektkatalogen pa ratt plats
#
# Anvandning:
#   1. Oppna PowerShell som administrator
#   2. Kor: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
#   3. Kor: .\install_complete_windows.ps1
# =============================================================================

# Krav administratorsrattigheter for installation
#Requires -RunAsAdministrator

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  KOMPLETT OpenModelica ORC Installation" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# KONFIGURERA SOKVAGAR
# =============================================================================

$ProjectBasePath = "C:\Users\marte\OneDrive - Dala VS Varme & Sanitet\Privat\Simulering System"
$LibraryPath = Join-Path $ProjectBasePath "OpenModelicaLibs"
$ProjectPath = Join-Path $ProjectBasePath "OpenModelica_ORC"

Write-Host "Projektsokvagar:" -ForegroundColor Yellow
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

# Kontrollera om OpenModelica redan ar installerat
$OMVersion = "1.23.0"
$OMCPath = "C:\Program Files\OpenModelica$OMVersion-64bit\bin\omc.exe"
$OMEditPath = "C:\Program Files\OpenModelica$OMVersion-64bit\bin\OMEdit.exe"

$skipOMInstall = $false

if (Test-Path $OMCPath) {
    Write-Host "OpenModelica verkar redan vara installerat" -ForegroundColor Green
    Write-Host "  Plats: $OMCPath" -ForegroundColor Gray
    Write-Host ""

    $reinstall = Read-Host "Vill du installera om? (j/N)"
    if ($reinstall -ne "j" -and $reinstall -ne "J") {
        Write-Host "Hoppar over OpenModelica-installation" -ForegroundColor Yellow
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
        Write-Host "  Hamtar fran: $OMInstallerURL" -ForegroundColor Gray
        Invoke-WebRequest -Uri $OMInstallerURL -OutFile $OMInstallerPath -UseBasicParsing
        Write-Host "  Nedladdning klar" -ForegroundColor Green
        Write-Host ""

        # Kor installer (tyst installation)
        Write-Host "  Installerar OpenModelica..." -ForegroundColor Yellow
        Write-Host "  (Detta kan ta nagra minuter)" -ForegroundColor Gray

        $installArgs = @(
            "/VERYSILENT",
            "/SUPPRESSMSGBOXES",
            "/NORESTART",
            "/DIR=C:\Program Files\OpenModelica$OMVersion-64bit"
        )

        Start-Process -FilePath $OMInstallerPath -ArgumentList $installArgs -Wait

        Write-Host "  OpenModelica installerat!" -ForegroundColor Green
        Write-Host ""

        # Ta bort installer
        Remove-Item $OMInstallerPath -ErrorAction SilentlyContinue

        # Verifiera installation
        if (Test-Path $OMCPath) {
            Write-Host "Installation verifierad" -ForegroundColor Green

            # Lagg till i PATH
            $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            $omBinPath = "C:\Program Files\OpenModelica$OMVersion-64bit\bin"

            if ($currentPath -notlike "*$omBinPath*") {
                Write-Host "  Lagger till i PATH..." -ForegroundColor Yellow
                [Environment]::SetEnvironmentVariable(
                    "Path",
                    "$currentPath;$omBinPath",
                    "Machine"
                )
                Write-Host "  PATH uppdaterad" -ForegroundColor Green
            }
        } else {
            Write-Host "Installation misslyckades!" -ForegroundColor Red
            Write-Host "  Forsok installera manuellt fran: https://openmodelica.org/download/" -ForegroundColor Yellow
            exit 1
        }

    } catch {
        Write-Host "Fel vid installation av OpenModelica: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Alternativ manuell installation:" -ForegroundColor Yellow
        Write-Host "  1. Ga till: https://openmodelica.org/download/" -ForegroundColor White
        Write-Host "  2. Ladda ner Windows-installer" -ForegroundColor White
        Write-Host "  3. Kor installationen" -ForegroundColor White
        Write-Host "  4. Kor detta script igen" -ForegroundColor White
        Write-Host ""

        $continue = Read-Host "Har du installerat OpenModelica manuellt? Fortsatt? (j/N)"
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
    Write-Host "Baskatalog skapad" -ForegroundColor Green
} else {
    Write-Host "Baskatalog finns redan" -ForegroundColor Green
}

# Skapa bibliotekskatalog
if (-not (Test-Path $LibraryPath)) {
    Write-Host "Skapar bibliotekskatalog: $LibraryPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $LibraryPath | Out-Null
    Write-Host "Bibliotekskatalog skapad" -ForegroundColor Green
} else {
    Write-Host "Bibliotekskatalog finns redan" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# STEG 3: LADDA NER MODELICA-BIBLIOTEK
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 3: Ladda ner Modelica-bibliotek" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Lista over bibliotek att ladda ner
$libraries = @{
    "ExternalMedia" = @{
        "url" = "https://github.com/modelica-3rdparty/ExternalMedia/archive/refs/heads/master.zip"
        "desc" = "ExternalMedia + CoolProp for R245fa"
        "why" = "Ger tillgang till realistiska fluiddynamiska egenskaper via CoolProp"
    }
    "ThermoCycle" = @{
        "url" = "https://github.com/thermocycle/Thermocycle-library/archive/refs/heads/master.zip"
        "desc" = "ThermoCycle for ORC-komponenter"
        "why" = "Fardiga modeller for expander, pump, varmevaxlare"
    }
    "Buildings" = @{
        "url" = "https://github.com/lbl-srg/modelica-buildings/releases/download/v10.0.0/Buildings-v10.0.0.zip"
        "desc" = "Buildings Library (LBNL)"
        "why" = "Stratifierad tank och solfangare + VVS-komponenter"
    }
    "IBPSA" = @{
        "url" = "https://github.com/ibpsa/modelica-ibpsa/archive/refs/heads/master.zip"
        "desc" = "IBPSA Library"
        "why" = "Bas for Buildings-biblioteket, extra HVAC-komponenter"
    }
    "ThermofluidStream" = @{
        "url" = "https://github.com/DLR-SR/ThermofluidStream/archive/refs/heads/main.zip"
        "desc" = "ThermofluidStream (alternativ)"
        "why" = "Alternativ rormodellering med R245fa-stod"
    }
}

# Ladda ner varje bibliotek
$counter = 1
foreach ($lib in $libraries.Keys) {
    Write-Host ""
    Write-Host "[$counter/$($libraries.Count)] Laddar ner $lib..." -ForegroundColor Green
    Write-Host "    Beskrivning: $($libraries[$lib].desc)" -ForegroundColor Gray
    Write-Host "    Varfor: $($libraries[$lib].why)" -ForegroundColor Gray

    $zipPath = Join-Path $LibraryPath "$lib.zip"
    $extractPath = Join-Path $LibraryPath $lib

    try {
        # Ladda ner
        Invoke-WebRequest -Uri $libraries[$lib].url -OutFile $zipPath -UseBasicParsing
        Write-Host "    Nedladdning klar" -ForegroundColor Green

        # Packa upp
        if (Test-Path $extractPath) {
            Remove-Item -Recurse -Force $extractPath
        }
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Write-Host "    Uppackad till: $extractPath" -ForegroundColor Green

        # Ta bort zip-filen
        Remove-Item $zipPath
    }
    catch {
        Write-Host "    Fel vid nedladdning av $lib : $_" -ForegroundColor Red
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

Write-Host "Bibliotekssokvagar konfigurerade" -ForegroundColor Green
Write-Host ""

# =============================================================================
# STEG 5: KOPIERA ORC-PROJEKT
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 5: Kopiera ORC-projekt till ratt plats" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Hitta var scriptet kors ifran
$ScriptPath = Split-Path -Parent $PSCommandPath
$SourceProjectPath = Split-Path -Parent $ScriptPath

Write-Host "Kopierar projekt fran: $SourceProjectPath" -ForegroundColor Yellow
Write-Host "Till: $ProjectPath" -ForegroundColor Yellow
Write-Host ""

$skipProjectCopy = $false

if (Test-Path $ProjectPath) {
    $overwrite = Read-Host "Projektkatalog finns redan. Skriv over? (j/N)"
    if ($overwrite -eq "j" -or $overwrite -eq "J") {
        Remove-Item -Recurse -Force $ProjectPath
    } else {
        Write-Host "Behaller befintlig projektkatalog" -ForegroundColor Yellow
        $skipProjectCopy = $true
    }
}

if (-not $skipProjectCopy) {
    Copy-Item -Path $SourceProjectPath -Destination $ProjectPath -Recurse -Force
    Write-Host "Projekt kopierat" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# STEG 6: SKAPA GENVAGAR
# =============================================================================

Write-Host "====================================================" -ForegroundColor Green
Write-Host "STEG 6: Skapa genvagar" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

$WshShell = New-Object -ComObject WScript.Shell
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')

$OMEditShortcut = $WshShell.CreateShortcut("$DesktopPath\OMEdit - ORC Project.lnk")
$OMEditShortcut.TargetPath = $OMEditPath
$OMEditShortcut.WorkingDirectory = $ProjectPath
$OMEditShortcut.Description = "OpenModelica Editor - ORC Project"
$OMEditShortcut.Save()
Write-Host "Genvag till OMEdit skapad" -ForegroundColor Green

$ProjectShortcut = $WshShell.CreateShortcut("$DesktopPath\ORC Projekt.lnk")
$ProjectShortcut.TargetPath = $ProjectPath
$ProjectShortcut.Description = "OpenModelica ORC Projekt"
$ProjectShortcut.Save()
Write-Host "Genvag till projektkatalog skapad" -ForegroundColor Green

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION SLUTFORD!" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OpenModelica installerat" -ForegroundColor Green
Write-Host "Bibliotek nedladdade" -ForegroundColor Green
Write-Host "Projekt kopierat" -ForegroundColor Green
Write-Host "Genvagar skapade" -ForegroundColor Green
Write-Host ""
Write-Host "Dubbelklicka pa 'OMEdit - ORC Project' pa skrivbordet for att starta!" -ForegroundColor Yellow
Write-Host ""

$openNow = Read-Host "Vill du oppna OMEdit nu? (j/N)"
if ($openNow -eq "j" -or $openNow -eq "J") {
    Start-Process $OMEditPath -WorkingDirectory $ProjectPath
}

Write-Host ""
Write-Host "Tryck Enter for att avsluta..."
Read-Host
