#!/bin/bash
# X-Seti - May 2026 - Morosa-1200 - Datasheet Fetcher
# Run from the research/ directory
# chmod +x fetch_datasheets.sh && ./fetch_datasheets.sh

mkdir -p amiga_chipset modern_ics cm4 cpu_fpu gpu reference_boards

echo "=== Morosa-1200 Datasheet Fetcher ==="
echo ""

fetch() {
    local name=$1
    local url=$2
    local dest=$3
    echo -n "Fetching $name ... "
    wget -q --timeout=30 -O "$dest" "$url"
    local size=$(stat -c%s "$dest" 2>/dev/null || echo 0)
    if [ "$size" -gt 1000 ]; then
        echo "OK ($(ls -lh $dest | awk '{print $5}'))"
    else
        echo "FAILED (check URL)"
        rm -f "$dest"
    fi
}

echo "--- Modern ICs ---"
fetch "PCM5102A DAC" \
    "https://www.ti.com/lit/ds/symlink/pcm5102a.pdf" \
    "modern_ics/PCM5102A.pdf"

fetch "PCM1808 ADC" \
    "https://www.ti.com/lit/ds/symlink/pcm1808.pdf" \
    "modern_ics/PCM1808.pdf"

fetch "ADV7513 HDMI" \
    "https://www.analog.com/media/en/technical-documentation/data-sheets/ADV7513.pdf" \
    "modern_ics/ADV7513.pdf"

fetch "6N137 MIDI opto" \
    "https://www.onsemi.com/pdf/datasheet/6n137-d.pdf" \
    "modern_ics/6N137.pdf"

fetch "ATmega324PB MCU" \
    "https://ww1.microchip.com/downloads/en/DeviceDoc/ATmega324PB.pdf" \
    "modern_ics/ATmega324PB.pdf"

echo ""
echo "--- CM4 / BCM2711 ---"
fetch "CM4 datasheet" \
    "https://datasheets.raspberrypi.com/cm4/cm4-datasheet.pdf" \
    "cm4/CM4_datasheet.pdf"

fetch "BCM2711 peripherals" \
    "https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf" \
    "cm4/BCM2711_peripherals.pdf"

fetch "CM4 IO board schematic" \
    "https://datasheets.raspberrypi.com/cm4io/cm4io-schematics.pdf" \
    "cm4/CM4IO_schematics.pdf"

echo ""
echo "--- CPU / FPU ---"
fetch "MC68030 User Manual" \
    "https://www.nxp.com/docs/en/reference-manual/MC68030UM.pdf" \
    "cpu_fpu/MC68030_UserManual.pdf"

fetch "MC68882 FPU" \
    "https://www.nxp.com/docs/en/data-sheet/MC68882.pdf" \
    "cpu_fpu/MC68882.pdf"

echo ""
echo "--- Reference Board Repos ---"
echo -n "Cloning Raemixx500 (A500+ KiCad) ... "
if [ ! -d "reference_boards/Raemixx500" ]; then
    git clone -q https://github.com/SukkoPera/Raemixx500 \
        reference_boards/Raemixx500 && echo "OK" || echo "FAILED"
else
    echo "already exists"
fi

echo -n "Cloning Amiga 1200+ (Vandezande) ... "
if [ ! -d "reference_boards/amiga-1200" ]; then
    git clone -q https://bitbucket.org/jvandezande/amiga-1200 \
        reference_boards/amiga-1200 && echo "OK" || echo "FAILED"
else
    echo "already exists"
fi

echo -n "Cloning RPi KiCad libraries ... "
if [ ! -d "cm4/kicad-libraries" ]; then
    git clone -q https://github.com/raspberrypi/kicad-libraries \
        cm4/kicad-libraries && echo "OK" || echo "FAILED"
else
    echo "already exists"
fi

echo ""
echo "=== Done ==="
echo ""
echo "Results:"
find . -name "*.pdf" | sort | while read f; do
    echo "  $f ($(ls -lh $f | awk '{print $5}'))"
done
