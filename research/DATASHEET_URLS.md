# X-Seti - May 2026 - Morosa-1200 - Datasheet Download URLs

"""
DATASHEET_URLS.md - Direct URLs for all datasheets needed.
Download these on your machine and place in the correct research/ subfolder.
wget or curl each URL directly.
"""

## Download Script

Save as research/fetch_datasheets.sh and run on your machine:

```bash
#!/bin/bash
# Morosa-1200 datasheet fetcher
# Run from the research/ directory

mkdir -p amiga_chipset modern_ics cm4 cpu_fpu gpu reference_boards

echo "Fetching modern IC datasheets..."

# Audio
wget -q -O modern_ics/PCM5102A.pdf \
  "https://www.ti.com/lit/ds/symlink/pcm5102a.pdf"

wget -q -O modern_ics/PCM1808.pdf \
  "https://www.ti.com/lit/ds/symlink/pcm1808.pdf"

# HDMI transmitter
wget -q -O modern_ics/ADV7513.pdf \
  "https://www.analog.com/media/en/technical-documentation/data-sheets/ADV7513.pdf"

# MIDI optocoupler
wget -q -O modern_ics/6N137.pdf \
  "https://www.onsemi.com/pdf/datasheet/6n137-d.pdf"

# MCUs
wget -q -O modern_ics/ATmega324PB.pdf \
  "https://ww1.microchip.com/downloads/en/DeviceDoc/ATmega324PB.pdf"

# Dual port SRAM
wget -q -O modern_ics/IDT70V24.pdf \
  "https://www.renesas.com/us/en/document/dst/70v24-datasheet"

wget -q -O modern_ics/CY7C136.pdf \
  "https://www.infineon.com/dgdl/Infineon-CY7C136_CY7C1360C-DataSheet-v12_00-EN.pdf"

# PCI bridge
wget -q -O modern_ics/PCI9052.pdf \
  "https://docs.broadcom.com/docs/12353427"

echo "Fetching CM4 documentation..."

# CM4 datasheet
wget -q -O cm4/CM4_datasheet.pdf \
  "https://datasheets.raspberrypi.com/cm4/cm4-datasheet.pdf"

# CM4 IO board schematic (reference design)
wget -q -O cm4/CM4IO_schematic.pdf \
  "https://datasheets.raspberrypi.com/cm4io/cm4io-schematics.pdf"

# BCM2711 datasheet
wget -q -O cm4/BCM2711.pdf \
  "https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf"

echo "Fetching CPU/FPU datasheets..."

# 68030 user manual
wget -q -O cpu_fpu/MC68030_UserManual.pdf \
  "https://www.nxp.com/docs/en/reference-manual/MC68030UM.pdf"

# 68882 FPU
wget -q -O cpu_fpu/MC68882.pdf \
  "https://www.nxp.com/docs/en/data-sheet/MC68882.pdf"

echo "Fetching Amiga chipset documentation..."

# Amiga Hardware Reference Manual (primary source)
wget -q -O amiga_chipset/Amiga_HRM.pdf \
  "http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0000.html"

echo "Done. Check each file size -- 0 bytes means the URL failed."
ls -lh */*.pdf
```

---

## Manual Download URLs

If the script fails for any URL, download manually:

### Modern ICs -- research/modern_ics/

| File | URL |
|---|---|
| PCM5102A.pdf | https://www.ti.com/lit/ds/symlink/pcm5102a.pdf |
| PCM1808.pdf | https://www.ti.com/lit/ds/symlink/pcm1808.pdf |
| ADV7513.pdf | https://www.analog.com/media/en/technical-documentation/data-sheets/ADV7513.pdf |
| 6N137.pdf | https://www.onsemi.com/pdf/datasheet/6n137-d.pdf |
| ATmega324PB.pdf | https://ww1.microchip.com/downloads/en/DeviceDoc/ATmega324PB.pdf |
| IDT70V24.pdf | https://www.renesas.com/us/en/document/dst/70v24-datasheet |
| CY7C136.pdf | https://www.infineon.com/dgdl/Infineon-CY7C136_CY7C1360C-DataSheet-v12_00-EN.pdf |
| PCI9052.pdf | https://docs.broadcom.com/docs/12353427 |

### CM4 -- research/cm4/

| File | URL |
|---|---|
| CM4_datasheet.pdf | https://datasheets.raspberrypi.com/cm4/cm4-datasheet.pdf |
| CM4IO_schematic.pdf | https://datasheets.raspberrypi.com/cm4io/cm4io-schematics.pdf |
| BCM2711.pdf | https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf |
| CM4_KiCad_symbol | https://github.com/raspberrypi/kicad-libraries |

### CPU / FPU -- research/cpu_fpu/

| File | URL |
|---|---|
| MC68030_UserManual.pdf | https://www.nxp.com/docs/en/reference-manual/MC68030UM.pdf |
| MC68882.pdf | https://www.nxp.com/docs/en/data-sheet/MC68882.pdf |
| MC68020_UserManual.pdf | https://www.nxp.com/docs/en/reference-manual/MC68020UM.pdf |

### Amiga Chipset -- research/amiga_chipset/

| File | URL |
|---|---|
| Amiga_HRM_3rd_ed.pdf | https://archive.org/details/AmigaHardwareReferenceManual3rdEd |
| AGA_chipset_notes.txt | https://eab.abime.net/showthread.php?t=60923 |
| A1200_schematics | http://amigadev.elowar.com |

### Reference Boards -- research/reference_boards/

| File | URL |
|---|---|
| Raemixx500 (KiCad) | git clone https://github.com/SukkoPera/Raemixx500 |
| Amiga1200+ (KiCad) | git clone https://bitbucket.org/jvandezande/amiga-1200 |
| CM4IO schematic | https://datasheets.raspberrypi.com/cm4io/cm4io-schematics.pdf |

---

## Critical Reference -- Amiga A1200 Chip Pinouts

These are the most important references for KiCad schematic work.
Without correct pinouts the schematic is useless.

### Alice (MOS 8374) PLCC-84
Primary: Amiga Hardware Reference Manual Chapter 6
Also: http://amigadev.elowar.com
Pin 1 orientation: notch corner

### Lisa (MOS 4203) PLCC-84
Your chip: CBM 391227-01, HP fab Korea, week 43 1993
Primary: Amiga Hardware Reference Manual
Note: AGA Lisa differs from OCS/ECS Denise pinout significantly

### Paula (MOS 8364) PLCC-52
Primary: Amiga Hardware Reference Manual Chapter 7
Audio DMA, floppy, serial, interrupt pins all documented

### Gayle (MOS 391424) PLCC-52
Less documented than other chips
Best source: A1200 schematics from jvandezande repo
IDE register map: AROS source code (drivers/disk/ide)

### CIA 8520 PLCC-44
Well documented -- used across many Commodore platforms
Primary: MOS 8520 datasheet (archive.org)

---

## KiCad Symbol Libraries Already Available

These save significant schematic work:

```bash
# Raspberry Pi official KiCad library (includes CM4)
git clone https://github.com/raspberrypi/kicad-libraries
research/cm4/

# Amiga chip symbols (community)
# Search KiCad forum and EAB for contributed symbols
# Some available in Raemixx500 project library
```

---

## Research Folder Structure

```
research/
  amiga_chipset/    Alice, Lisa, Paula, Gayle, CIA datasheets
  modern_ics/       ADV7513, PCM5102A, PCM1808, MCUs, SRAM
  cm4/              CM4 datasheet, BCM2711, IO board schematics
  cpu_fpu/          68030, 68882 user manuals
  gpu/              RV350, R9 285, Theater 200 docs
  reference_boards/ Raemixx500, A1200+ cloned repos
  DATASHEET_URLS.md this file
  fetch_datasheets.sh download script
```
