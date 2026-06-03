#!/bin/bash
# X-Seti - May 2026 - Morosa-1200 - Fetch Missing Datasheets
# Run from the research/ directory
# chmod +x fetch_missing.sh && ./fetch_missing.sh

echo "=== Fetching Missing Datasheets ==="

fetch() {
    local name=$1
    local url=$2
    local dest=$3
    echo -n "Fetching $name ... "
    wget -q --timeout=30 --user-agent="Mozilla/5.0" -O "$dest" "$url"
    local size=$(stat -c%s "$dest" 2>/dev/null || echo 0)
    if [ "$size" -gt 1000 ]; then
        echo "OK ($(ls -lh $dest | awk '{print $5}'))"
    else
        echo "FAILED (check URL)"
        rm -f "$dest"
    fi
}

echo "--- Missing Modern ICs ---"

# ADV7513 - try alternative URL
fetch "ADV7513 HDMI" \
    "https://www.analog.com/media/en/technical-documentation/data-sheets/adv7513.pdf" \
    "modern_ics/ADV7513.pdf"

# ATmega324PB - try alternative
fetch "ATmega324PB MCU" \
    "https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/ATmega324PB-Data-Sheet-DS40001908.pdf" \
    "modern_ics/ATmega324PB.pdf"

# MC68882 FPU
fetch "MC68882 FPU" \
    "https://www.nxp.com/docs/en/reference-manual/MC68882UM.pdf" \
    "modern_ics/MC68882.pdf"

# CM4 IO board schematic - alternative
fetch "CM4 IO Schematic" \
    "https://datasheets.raspberrypi.com/cm4io/cm4io-schematics.pdf" \
    "cm4/CM4IO_schematics.pdf"

# IDT70V24 dual port SRAM
fetch "IDT70V24 SRAM" \
    "https://www.renesas.com/us/en/document/dst/70v24-data-sheet" \
    "modern_ics/IDT70V24.pdf"

# CY7C136 dual port SRAM (alternative to IDT)
fetch "CY7C136 SRAM" \
    "https://www.infineon.com/dgdl/Infineon-CY7C136_CY7C1360C-DataSheet-v12_00-EN.pdf?fileId=8ac78c8c7d0d8da4017d0ee9a5de4e1e" \
    "modern_ics/CY7C136.pdf"

echo ""
echo "--- RPi KiCad Library (public repo) ---"
echo -n "Cloning RPi KiCad library ... "
if [ ! -d "cm4/kicad-libraries" ]; then
    git clone -q https://github.com/RPiAwesome/kicad-rpi-libs.git \
        cm4/kicad-libraries 2>/dev/null || \
    git clone -q https://github.com/nickcoutsos/keyswitch-kicad-library \
        cm4/kicad-libraries 2>/dev/null || \
    echo "Try manually: search KiCad forum for CM4 symbol"
else
    echo "already exists"
fi

# CM4 symbol specifically - grab from known good source
echo -n "Fetching CM4 KiCad symbol ... "
mkdir -p cm4/symbols
wget -q --timeout=30 \
    "https://raw.githubusercontent.com/symbioticEDA/kicad-footprints/main/RPi_CM4.kicad_sym" \
    -O cm4/symbols/RPi_CM4.kicad_sym 2>/dev/null || \
    echo "Not found - will create manually"

echo ""
echo "=== Done ==="
echo ""
echo "Key files we already have:"
echo "  Vandezande A1200+ schematics (Rev0, Rev3, Rev5) -- most important"
echo "  MC68030 User Manual (22MB)"  
echo "  CM4 datasheet (11MB)"
echo "  BCM2711 peripherals (1.3MB)"
echo "  PCM5102A, PCM1808, 6N137 datasheets"
echo ""
echo "Open these PDFs first before starting KiCad:"
echo "  reference_boards/amiga-1200/A1200+_Schematics_Rev5.pdf"
echo "  cpu_fpu/MC68030_UserManual.pdf"
