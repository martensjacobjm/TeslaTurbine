# =============================================================================
# BOOTSTRAP - Ladda ner och installera OpenModelica ORC-projekt
# =============================================================================
# Detta script laddar ner projektet från GitHub och kör installation.
#
# VIKTIGT: Kör detta DIREKT från PowerShell (inget behov av admin ännu)
#
# Användning:
#   1. Kopiera hela detta script
#   2. Öppna PowerShell (vanlig, inte admin)
#   3. Klistra in och kör
# =============================================================================

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  OpenModelica ORC - BOOTSTRAP" -ForegroundColor Cyan
Write-Host "  Laddar ner projekt från GitHub" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# KONFIGURERA SÖKVÄGAR
# =============================================================================

$BasePath = "C:\Users\marte\OneDrive - Dala VS Värme & Sanitet\Privat\Simulering System"
$GitHubRepo = "https://github.com/martensjacobjm/TeslaTurbine"
$Branch = "claude/create-repository-011CUQKk4VgQKTu19T9xWSDS"

Write-Host "Projektsökväg: $BasePath" -ForegroundColor Yellow
Write-Host "GitHub: $GitHubRepo" -ForegroundColor Yellow
Write-Host "Branch: $Branch" -ForegroundColor Yellow
Write-Host ""

# =============================================================================
# SKAPA BASKATALOG
# =============================================================================

Write-Host "Skapar baskatalog..." -ForegroundColor Yellow

if (-not (Test-Path $BasePath)) {
    try {
        New-Item -ItemType Directory -Force -Path $BasePath | Out-Null
        Write-Host "✓ Baskatalog skapad: $BasePath" -ForegroundColor Green
    } catch {
        Write-Host "✗ Kunde inte skapa baskatalog: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Försök skapa katalogen manuellt:" -ForegroundColor Yellow
        Write-Host "  1. Öppna Utforskaren" -ForegroundColor White
        Write-Host "  2. Skapa mapp: $BasePath" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "✓ Baskatalog finns redan" -ForegroundColor Green
}

Write-Host ""

# =============================================================================
# KONTROLLERA GIT
# =============================================================================

Write-Host "Kontrollerar om Git är installerat..." -ForegroundColor Yellow

$gitInstalled = $false
try {
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $gitInstalled = $true
        Write-Host "✓ Git är installerat: $gitVersion" -ForegroundColor Green
    }
} catch {
    $gitInstalled = $false
}

Write-Host ""

# =============================================================================
# LADDA NER PROJEKT
# =============================================================================

$ProjectPath = Join-Path $BasePath "TeslaTurbine"

if (Test-Path $ProjectPath) {
    Write-Host "Projektet finns redan i: $ProjectPath" -ForegroundColor Yellow
    $overwrite = Read-Host "Vill du ladda ner igen? (j/N)"
    if ($overwrite -ne "j" -and $overwrite -ne "J") {
        Write-Host "Använder befintlig projektkatalog" -ForegroundColor Green
        Write-Host ""
        goto InstallationStep
    } else {
        Write-Host "Tar bort gammal version..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $ProjectPath
    }
}

Write-Host "====================================================" -ForegroundColor Green
Write-Host "Laddar ner projekt från GitHub" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

if ($gitInstalled) {
    # Alternativ 1: Använd Git
    Write-Host "Klonar repository med Git..." -ForegroundColor Yellow
    Write-Host "(Detta kan ta 1-2 minuter)" -ForegroundColor Gray
    Write-Host ""

    try {
        Set-Location $BasePath
        git clone $GitHubRepo 2>&1 | Out-Null

        if (Test-Path $ProjectPath) {
            Set-Location $ProjectPath
            git checkout $Branch 2>&1 | Out-Null
            Write-Host "✓ Projekt klonat från GitHub" -ForegroundColor Green
        } else {
            throw "Kloning misslyckades"
        }
    } catch {
        Write-Host "✗ Git-kloning misslyckades: $_" -ForegroundColor Red
        Write-Host "Försöker ladda ner som ZIP istället..." -ForegroundColor Yellow
        $gitInstalled = $false
    }
}

if (-not $gitInstalled) {
    # Alternativ 2: Ladda ner ZIP
    Write-Host "Laddar ner som ZIP-fil..." -ForegroundColor Yellow
    Write-Host "(Detta kan ta 1-2 minuter)" -ForegroundColor Gray
    Write-Host ""

    $zipUrl = "$GitHubRepo/archive/refs/heads/$Branch.zip"
    $zipPath = Join-Path $env:TEMP "TeslaTurbine.zip"
    $extractPath = Join-Path $BasePath "TeslaTurbine-temp"

    try {
        # Ladda ner ZIP
        Write-Host "  Hämtar från GitHub..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        Write-Host "  ✓ Nedladdning klar" -ForegroundColor Green

        # Packa upp
        Write-Host "  Packar upp..." -ForegroundColor Gray
        Expand-Archive -Path $zipPath -DestinationPath $BasePath -Force

        # Hitta uppackad mapp (kan heta TeslaTurbine-branch-name)
        $unpackedFolder = Get-ChildItem -Path $BasePath -Directory | Where-Object { $_.Name -like "TeslaTurbine-*" } | Select-Object -First 1

        if ($unpackedFolder) {
            # Byt namn till TeslaTurbine
            Move-Item -Path $unpackedFolder.FullName -Destination $ProjectPath -Force
            Write-Host "  ✓ Projekt uppackat" -ForegroundColor Green
        } else {
            throw "Kunde inte hitta uppackad mapp"
        }

        # Ta bort ZIP
        Remove-Item $zipPath -ErrorAction SilentlyContinue

        Write-Host "✓ Projekt nedladdat från GitHub" -ForegroundColor Green

    } catch {
        Write-Host "✗ Nedladdning misslyckades: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "MANUELL LÖSNING:" -ForegroundColor Yellow
        Write-Host "  1. Gå till: $GitHubRepo" -ForegroundColor White
        Write-Host "  2. Klicka på 'Code' → 'Download ZIP'" -ForegroundColor White
        Write-Host "  3. Packa upp ZIP-filen till: $BasePath" -ForegroundColor White
        Write-Host "  4. Byt namn på mappen till: TeslaTurbine" -ForegroundColor White
        Write-Host "  5. Kör detta script igen" -ForegroundColor White
        Write-Host ""
        Read-Host "Tryck Enter för att avsluta"
        exit 1
    }
}

Write-Host ""

# =============================================================================
# VERIFIERA NEDLADDNING
# =============================================================================

:InstallationStep

Write-Host "Verifierar projekt..." -ForegroundColor Yellow

$orcPath = Join-Path $ProjectPath "OpenModelica_ORC"
$scriptPath = Join-Path $orcPath "scripts\install_complete_windows.ps1"

if (-not (Test-Path $orcPath)) {
    Write-Host "✗ OpenModelica_ORC-mappen hittades inte!" -ForegroundColor Red
    Write-Host "  Förväntad plats: $orcPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Kontrollera att projektet laddades ner korrekt." -ForegroundColor Yellow
    Read-Host "Tryck Enter för att avsluta"
    exit 1
}

if (-not (Test-Path $scriptPath)) {
    Write-Host "✗ Installations-script hittades inte!" -ForegroundColor Red
    Write-Host "  Förväntad plats: $scriptPath" -ForegroundColor Gray
    Read-Host "Tryck Enter för att avsluta"
    exit 1
}

Write-Host "✓ Projekt verifierat" -ForegroundColor Green
Write-Host ""

# =============================================================================
# INFORMATION OM NÄSTA STEG
# =============================================================================

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  NEDLADDNING KLAR!" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Projektet har laddats ner till:" -ForegroundColor Green
Write-Host "  $ProjectPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "NÄSTA STEG - Kör installationen:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Stäng detta PowerShell-fönster" -ForegroundColor White
Write-Host ""
Write-Host "2. Öppna PowerShell som ADMINISTRATÖR:" -ForegroundColor White
Write-Host "   - Högerklicka på Start" -ForegroundColor Gray
Write-Host "   - Välj 'Windows PowerShell (Admin)'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Tillåt scripts (engångsinställning):" -ForegroundColor White
Write-Host "   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Navigera till projektet:" -ForegroundColor White
Write-Host "   cd `"$orcPath\scripts`"" -ForegroundColor Yellow
Write-Host ""
Write-Host "5. Kör installations-scriptet:" -ForegroundColor White
Write-Host "   .\install_complete_windows.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Fråga om användaren vill öppna Utforskaren
$openExplorer = Read-Host "Vill du öppna projektkatalogen i Utforskaren? (j/N)"
if ($openExplorer -eq "j" -or $openExplorer -eq "J") {
    Start-Process explorer.exe -ArgumentList $ProjectPath
}

Write-Host ""
Write-Host "Tryck Enter för att avsluta..."
Read-Host
