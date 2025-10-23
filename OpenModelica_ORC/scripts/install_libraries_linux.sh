#!/bin/bash
# =============================================================================
# OpenModelica ORC Library Installation Script (Linux Bash)
# =============================================================================
# Detta script laddar ner och installerar alla nödvändiga Modelica-bibliotek
# för ORC-modellering med R245fa som arbetsmedium.
#
# Användning:
#   chmod +x install_libraries_linux.sh
#   ./install_libraries_linux.sh
# =============================================================================

# Färgkoder för output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  OpenModelica ORC Library Installation${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""

# Skapa bas-mappen
BASE="$HOME/Downloads/OpenModelicaLibs"
echo -e "${YELLOW}Skapar biblioteksmapp: $BASE${NC}"
mkdir -p "$BASE"

# Funktion för att ladda ner och packa upp bibliotek
download_library() {
    local name=$1
    local url=$2
    local desc=$3
    local why=$4
    local counter=$5
    local total=$6

    echo ""
    echo -e "${GREEN}[$counter/$total] Laddar ner $name...${NC}"
    echo -e "${GRAY}    Beskrivning: $desc${NC}"
    echo -e "${GRAY}    Varför: $why${NC}"

    local zip_path="$BASE/$name.zip"
    local extract_path="$BASE/$name"

    # Ladda ner
    if wget -q --show-progress -O "$zip_path" "$url"; then
        echo -e "${GREEN}    ✓ Nedladdning klar${NC}"
    else
        echo -e "${RED}    ✗ Fel vid nedladdning av $name${NC}"
        return 1
    fi

    # Packa upp
    mkdir -p "$extract_path"
    if unzip -q "$zip_path" -d "$extract_path"; then
        echo -e "${GREEN}    ✓ Uppackad till: $extract_path${NC}"
    else
        echo -e "${RED}    ✗ Fel vid uppackning av $name${NC}"
        return 1
    fi

    # Ta bort zip-filen
    rm "$zip_path"
}

# Lista över bibliotek
counter=1
total=5

# 1. ExternalMedia
download_library \
    "ExternalMedia" \
    "https://github.com/modelica-3rdparty/ExternalMedia/archive/refs/heads/master.zip" \
    "ExternalMedia + CoolProp för R245fa" \
    "Ger tillgång till realistiska fluiddynamiska egenskaper via CoolProp" \
    $counter $total
((counter++))

# 2. ThermoCycle
download_library \
    "ThermoCycle" \
    "https://github.com/thermocycle/Thermocycle-library/archive/refs/heads/master.zip" \
    "ThermoCycle för ORC-komponenter" \
    "Färdiga modeller för expander, pump, värmeväxlare" \
    $counter $total
((counter++))

# 3. Buildings
download_library \
    "Buildings" \
    "https://github.com/lbl-srg/modelica-buildings/releases/download/v10.0.0/Buildings-v10.0.0.zip" \
    "Buildings Library (LBNL)" \
    "Stratifierad tank och solfångare + VVS-komponenter" \
    $counter $total
((counter++))

# 4. IBPSA
download_library \
    "IBPSA" \
    "https://github.com/ibpsa/modelica-ibpsa/archive/refs/heads/master.zip" \
    "IBPSA Library" \
    "Bas för Buildings-biblioteket, extra HVAC-komponenter" \
    $counter $total
((counter++))

# 5. ThermofluidStream
download_library \
    "ThermofluidStream" \
    "https://github.com/DLR-SR/ThermofluidStream/archive/refs/heads/main.zip" \
    "ThermofluidStream (alternativ)" \
    "Alternativ rörmodellering med R245fa-stöd" \
    $counter $total

echo ""
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  Installation klar!${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""
echo -e "${YELLOW}Biblioteken finns i: $BASE${NC}"
echo ""
echo -e "${CYAN}Nästa steg:${NC}"
echo -e "${NC}  1. Öppna OMEdit (OpenModelica Connection Editor)${NC}"
echo -e "${NC}  2. Gå till Tools → Options → Libraries${NC}"
echo -e "${NC}  3. Lägg till mappen: $BASE${NC}"
echo -e "${NC}  4. Klicka på 'Add' och lägg till varje bibliotek${NC}"
echo ""
echo -e "${CYAN}Viktiga bibliotek för ORC-modellen:${NC}"
echo -e "${NC}  • ExternalMedia - För R245fa via CoolProp${NC}"
echo -e "${NC}  • ThermoCycle - För ORC-komponenter${NC}"
echo -e "${NC}  • Buildings - För stratifierad tank och solfångare${NC}"
echo ""

# Skapa en info-fil med biblioteksinformation
INFO_FILE="$BASE/BIBLIOTEK_INFO.txt"
cat > "$INFO_FILE" << EOF
=============================================================================
OpenModelica ORC - Installerade Bibliotek
=============================================================================
Installerad: $(date '+%Y-%m-%d %H:%M')

BIBLIOTEK OCH DERAS ANVÄNDNING:
=============================================================================

1. ExternalMedia + CoolProp
   Mapp: $BASE/ExternalMedia
   Användning: Arbetsmedium R245fa med realistiska egenskaper
   Anledning: CoolProp ger exakta termodynamiska data för R245fa

2. ThermoCycle
   Mapp: $BASE/ThermoCycle
   Användning: ORC-komponenter (expander, pump, värmeväxlare)
   Anledning: Färdiga validerade modeller för ORC-system

3. Buildings (LBNL)
   Mapp: $BASE/Buildings
   Användning: Stratifierad tank, solfångare, VVS-komponenter
   Anledning: Välvaliderade komponenter för termiska system

4. IBPSA
   Mapp: $BASE/IBPSA
   Användning: Bas för Buildings, extra HVAC-komponenter
   Anledning: Standardbibliotek för byggnadsimulering

5. ThermofluidStream (alternativ)
   Mapp: $BASE/ThermofluidStream
   Användning: Alternativ rörmodellering
   Anledning: Modernare approach till fluid-modellering

=============================================================================
INSTALLATION I OPENMODELICA:
=============================================================================

1. Öppna OMEdit
2. Tools → Options → Libraries
3. Lägg till: $BASE
4. Ladda biblioteken i projektet:
   - File → Load Library → [Välj bibliotek]

Eller i .mos script:
   loadModel(Modelica);
   loadFile("$BASE/ExternalMedia/package.mo");
   loadFile("$BASE/ThermoCycle/package.mo");
   loadFile("$BASE/Buildings/package.mo");

=============================================================================

För att installera OpenModelica på Linux (Ubuntu/Debian):
   sudo apt-get update
   sudo apt-get install openmodelica
   sudo apt-get install omlib-*

För Fedora/RHEL:
   sudo dnf install openmodelica

För Arch Linux:
   sudo pacman -S openmodelica

=============================================================================
EOF

echo -e "${GREEN}Information sparad i: $INFO_FILE${NC}"
echo ""

# Gör scriptet körbart för framtida användning
chmod +x "$0"
