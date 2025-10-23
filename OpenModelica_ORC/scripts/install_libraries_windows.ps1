# =============================================================================
# OpenModelica ORC Library Installation Script (Windows PowerShell)
# =============================================================================
# Detta script laddar ner och installerar alla nödvändiga Modelica-bibliotek
# för ORC-modellering med R245fa som arbetsmedium.
#
# Användning:
#   1. Öppna PowerShell som administratör
#   2. Kör: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#   3. Kör: .\install_libraries_windows.ps1
# =============================================================================

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  OpenModelica ORC Library Installation" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Skapa bas-mappen
$base = Join-Path $HOME "Downloads\OpenModelicaLibs"
Write-Host "Skapar biblioteksmapp: $base" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $base | Out-Null

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

    $zipPath = Join-Path $base "$lib.zip"
    $extractPath = Join-Path $base $lib

    try {
        # Ladda ner
        Invoke-WebRequest -Uri $libraries[$lib].url -OutFile $zipPath -UseBasicParsing
        Write-Host "    ✓ Nedladdning klar" -ForegroundColor Green

        # Packa upp
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
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Installation klar!" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Biblioteken finns i: $base" -ForegroundColor Yellow
Write-Host ""
Write-Host "Nästa steg:" -ForegroundColor Cyan
Write-Host "  1. Öppna OMEdit (OpenModelica Connection Editor)" -ForegroundColor White
Write-Host "  2. Gå till Tools → Options → Libraries" -ForegroundColor White
Write-Host "  3. Lägg till mappen: $base" -ForegroundColor White
Write-Host "  4. Klicka på 'Add' och lägg till varje bibliotek" -ForegroundColor White
Write-Host ""
Write-Host "Viktiga bibliotek för ORC-modellen:" -ForegroundColor Cyan
Write-Host "  • ExternalMedia - För R245fa via CoolProp" -ForegroundColor White
Write-Host "  • ThermoCycle - För ORC-komponenter" -ForegroundColor White
Write-Host "  • Buildings - För stratifierad tank och solfångare" -ForegroundColor White
Write-Host ""

# Skapa en info-fil med biblioteksinformation
$infoFile = Join-Path $base "BIBLIOTEK_INFO.txt"
$infoContent = @"
=============================================================================
OpenModelica ORC - Installerade Bibliotek
=============================================================================
Installerad: $(Get-Date -Format "yyyy-MM-dd HH:mm")

BIBLIOTEK OCH DERAS ANVÄNDNING:
=============================================================================

1. ExternalMedia + CoolProp
   Mapp: $base\ExternalMedia
   Användning: Arbetsmedium R245fa med realistiska egenskaper
   Anledning: CoolProp ger exakta termodynamiska data för R245fa

2. ThermoCycle
   Mapp: $base\ThermoCycle
   Användning: ORC-komponenter (expander, pump, värmeväxlare)
   Anledning: Färdiga validerade modeller för ORC-system

3. Buildings (LBNL)
   Mapp: $base\Buildings
   Användning: Stratifierad tank, solfångare, VVS-komponenter
   Anledning: Välvaliderade komponenter för termiska system

4. IBPSA
   Mapp: $base\IBPSA
   Användning: Bas för Buildings, extra HVAC-komponenter
   Anledning: Standardbibliotek för byggnadsimulering

5. ThermofluidStream (alternativ)
   Mapp: $base\ThermofluidStream
   Användning: Alternativ rörmodellering
   Anledning: Modernare approach till fluid-modellering

=============================================================================
INSTALLATION I OPENMODELICA:
=============================================================================

1. Öppna OMEdit
2. Tools → Options → Libraries
3. Lägg till: $base
4. Ladda biblioteken i projektet:
   - File → Load Library → [Välj bibliotek]

Eller i .mos script:
   loadModel(Modelica);
   loadFile("$base\ExternalMedia\package.mo");
   loadFile("$base\ThermoCycle\package.mo");
   loadFile("$base\Buildings\package.mo");

=============================================================================
"@

$infoContent | Out-File -FilePath $infoFile -Encoding UTF8
Write-Host "Information sparad i: $infoFile" -ForegroundColor Green
Write-Host ""
