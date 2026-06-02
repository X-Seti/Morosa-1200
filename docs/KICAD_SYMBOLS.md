# X-Seti - May 2026 - Morosa-1200 - KiCad Symbol Audit

"""
KICAD_SYMBOLS.md - What symbols exist in reference libraries,
what needs converting, and what needs creating from scratch.
All symbols needed for Morosa-1200 schematic work.
"""

## Symbol Library Sources

### Raemixx500 Libraries (KiCad 5 .lib format)
Located in research/reference_boards/Raemixx500/libs/
Must be imported/converted to KiCad 8 .kicad_sym format.
KiCad 8 can import old .lib format directly -- File > Import.

### Vandezande A1200+ Libraries
Clone locally: git clone https://bitbucket.org/jvandezande/amiga-1200
Check hardware/ folder for KiCad symbol libraries.
May have AGA-specific variants we need.

---

## Symbols Available in Raemixx500 (confirmed)

These exist and can be imported/converted for Morosa-1200 use.
All are KiCad 5 .lib format -- import into KiCad 8.

| Symbol | File | Notes |
|---|---|---|
| PAULA | libs/PAULA.lib | MOS 8364, PLCC-52, A500+ pinout -- verify vs A1200 |
| FAT_AGNUS_8375 | libs/FAT_AGNUS_8375.lib | OCS/ECS Agnus -- NOT AGA Alice, pinout differs |
| DENISE | libs/DENISE.lib | OCS Denise -- NOT AGA Lisa, pinout differs |
| VIA_8520 | libs/VIA_8520.lib | CIA 8520, PLCC-44 -- same chip, reusable |
| AMIGA_ROM | libs/AMIGA_ROM.lib | DIP-40 Kickstart ROM -- reusable |
| TRAPDOOR | libs/TRAPDOOR.lib | A500 trapdoor -- need A1200 version (different pinout) |
| 68000D | libs/68000D.lib | 68000 DIP -- NOT 68030, do not use |
| GARY | libs/GARY.lib | A500 Gary glue -- not used on A1200 |
| DB9 male | libs/db9_male_mountingholes.lib | DB9 joystick -- reusable |
| DB25 female | libs/db25_female_mountingholes.lib | Not needed (parallel dropped) |
| DB23 | libs/db23_male_mountingholes.lib | Not needed (video port dropped) |

---

## Symbol Status -- What Needs Doing

### Can Reuse Directly (import .lib, verify pinout)
```
VIA_8520 (CIA)    -- same chip across all Amiga models, reuse
AMIGA_ROM         -- DIP-40 ROM, same on A1200, reuse
DB9 male          -- joystick port, reuse
```

### Need Significant Modification
```
PAULA             -- verify A1200 PLCC-52 pinout vs A500 version
                     Paula is same chip but check pin assignments
                     Raemixx500 version may be correct already

TRAPDOOR          -- A500 version has different pinout to A1200
                     A1200 trapdoor is 150-pin edge connector
                     Need to create new symbol from A1200 schematics
                     Reference: Vandezande A1200+ project
```

### Must Create From Scratch
```
MOS_8374_Alice    PLCC-84  AGA Agnus -- completely different to FAT_AGNUS
                           84 pins vs 84 pins but different functions
                           Source: Amiga HRM + A1200 schematics
                           Reference: Vandezande A1200+ if available

MOS_4203_Lisa     PLCC-84  AGA Denise -- completely different to OCS Denise
                           Source: Amiga HRM + A1200 schematics
                           Your chip: CBM 391227-01

MOS_391424_Gayle  PLCC-52  A1200 only chip, not in any A500 project
                           Least documented custom chip
                           Source: A1200 schematics (Vandezande)
                           AROS IDE driver source for register map

MOS_391425_Budgie SOJ-40   A1200 PCMCIA buffer
                           Source: A1200 schematics

MC68030           QFP-132  Not in Raemixx500 (uses 68000)
                           Check KiCad standard library first
                           NXP/Freescale may have contributed symbol
                           If not: create from MC68030 user manual

MC68882           PLCC-52  FPU
                           Check KiCad standard library
                           If not: create from MC68882 datasheet

CM4_Socket        200-pin  Raspberry Pi CM4 connector
                           Check: github.com/raspberrypi/kicad-libraries
                           Almost certainly exists there

ADV7513           LFCSP-64 HDMI transmitter
                           Check KiCad standard library
                           Analog Devices parts often contributed

PCM5102A          SSOP-20  TI audio DAC
                           Check KiCad standard library
                           TI parts usually in standard lib

PCM1808           SSOP-16  TI audio ADC
                           Check KiCad standard library

IDT70V24          varies   Dual-port SRAM
                           Check KiCad standard library
                           Renesas/IDT parts sometimes present

ATmega324PB       TQFP-44  Keyboard MCU
                           Check KiCad standard library
                           Microchip AVR usually well covered

6N137             DIP-8    MIDI optocoupler
                           Almost certainly in KiCad standard lib

72-pin SIMM       edge     SIMM socket
                           Check KiCad standard library
                           Common memory form factor
```

---

## Symbol Creation Priority Order

Work through in this order:

```
Priority 1 -- Needed for Phase 1 schematic sheets
  MC68030           check standard lib first
  MC68882           check standard lib first
  MOS_8374_Alice    create from scratch
  72-pin SIMM       check standard lib first
  Power symbols     already in KiCad standard lib

Priority 2 -- Needed for AGA chipset sheets
  MOS_4203_Lisa     create from scratch
  MOS_8364_Paula    modify from Raemixx500
  MOS_391424_Gayle  create from scratch
  MOS_391425_Budgie create from scratch
  VIA_8520 CIA      import from Raemixx500
  AMIGA_ROM         import from Raemixx500

Priority 3 -- Needed for modern I/O sheets
  CM4_Socket        check RPi library
  ADV7513           check standard lib
  PCM5102A          check standard lib
  PCM1808           check standard lib
  IDT70V24          check standard lib
  ATmega324PB       check standard lib
  6N137             check standard lib

Priority 4 -- Needed for expansion sheets
  A1200_Trapdoor    create from A1200 schematics
  DB9 male          import from Raemixx500
  IDE_40pin         check standard lib
  SD_Socket         check standard lib
  MIDI_DIN5         check standard lib
```

---

## Where to Find Pinout Data

### Alice (MOS 8374) PLCC-84
Primary: Amiga Hardware Reference Manual (AGA supplement)
Backup: http://amigadev.elowar.com
Also: Vandezande A1200+ schematic
Pin 1: identified by PLCC notch corner
Key signals: A[0..20], D[0..15], RGA[0..8], CCK, CCKQ, CDAC

### Lisa (MOS 4203) PLCC-84
Primary: Amiga Hardware Reference Manual
Your chip: CBM 391227-01 (confirmed, photographed)
Key signals: RGB[0..7] x3, HSYNC, VSYNC, CSYNC, BLANK, PIXCLK
Also: RGA[0..8], DRD[0..15]

### Gayle (MOS 391424) PLCC-52
Primary: Vandezande A1200+ schematic (best source)
Backup: AROS source code -- arch/m68k-amiga/devs/ide
Register map: based on IDE ATA standard + custom Amiga extensions
This chip is the least publicly documented -- A1200 schematics essential

### A1200 Trapdoor Connector
150-pin edge connector, 0.05-inch pitch, dual row
Pinout: documented in Amiga Hardware Reference Manual
Also: EAB (English Amiga Board) hardware forum
Key signals: A[0..31], D[0..31], plus all bus control lines

---

## KiCad 8 Import Procedure for Old .lib Files

```
1. Open KiCad 8 Symbol Editor
2. File > Import Symbol Library
3. Navigate to Raemixx500/libs/PAULA.lib
4. KiCad converts to .kicad_sym format automatically
5. Review all pins -- verify against datasheet
6. Correct any errors before using in schematic
7. Save to morosa_custom.kicad_sym
```

---

## Symbol Drawing Guidelines

Consistent style across all custom symbols:

```
Pin length:       100 mil (2.54mm)
Pin name size:    50 mil
Pin number size:  50 mil
Body line width:  0 (default)
Pin grouping:     Group by function not pin number
  - Power pins together (top or bottom)
  - Address bus together
  - Data bus together
  - Control signals together
  - Clock signals together

Active low signals:  Use ~ prefix (e.g. ~AS, ~RESET)
Bidirectional:       Set pin type to Bidirectional
Power pins:          Set pin type to Power input
Clock pins:          Set pin type to Input + clock flag

Reference prefix:
  U  -- ICs (CPU, custom chips, logic)
  J  -- Connectors (SIMM, IDE, trapdoor)
  X  -- Crystals
  C  -- Capacitors
  R  -- Resistors
  T  -- Transformers (audio)
  D  -- Diodes/optocouplers
```
