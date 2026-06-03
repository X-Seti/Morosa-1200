# X-Seti - May 2026 - Morosa-1200 - Reference Assets Inventory

"""
REFERENCE_ASSETS.md - Inventory of useful files found in cloned
reference repos. What to use, where to find it, what to extract.
"""

## Vandezande A1200+ (research/reference_boards/amiga-1200/)

### Schematics (use Rev5 as primary reference)
```
A1200+_Schematics_Rev5.pdf    -- most complete, use this
A1200+_Schematics_Rev3.pdf    -- backup reference
A1200+ Rev2 Schematics.pdf    -- earlier version
A1200+_Schematics_Rev0.pdf    -- original, compare for changes
```

Primary schematic files (KiCad 4/5 format):
```
A1200+.sch                    -- main schematic
A1200 Plus CORE.sch           -- core chipset sheet
A1200 Plus CORE.pcb           -- PCB layout
A1200+.pcb                    -- full PCB
```

### Key Expansion Projects
```
VideoExpansion/SimpleRGBBoard/ -- RGB video output board
  SimpleRGBBoard.sch           -- Lisa video bus connections
  SimpleRGBBoard Rev0 Schematics.pdf
  -- CRITICAL: shows how to connect to Lisa video pins
  -- Direct reference for our ADV7513 video path

VideoExpansion/ZZ1200/        -- ZZ9000 style expansion
  ZZ1200.sch                  -- interesting reference

RamExpansion/RamBo 1Mx4/      -- SIMM RAM expansion
  RamBo 1Mx4.sch              -- SIMM socket wiring
  RamBo 1Mx4 Rev0 Schematics.pdf
  -- Reference for our 72-pin SIMM sockets

JoyStickExpansion/            -- DB9 joystick expansion
  A1200+JoyStickExpansion.sch -- CIA pot pin connections
  -- Reference for our DB9 port wiring

CPLD/                         -- Bus logic implementation
  Amiga1200Plus.vhd           -- VHDL source
  amiga1200plus.jed            -- CPLD JED file
  -- Reference for glue logic if needed
```

### Firmware (gold dust)
```
Firmware/Keyboard/KeyboardController/
  main.c                      -- keyboard MCU main loop
  src/amigakb.c               -- Amiga keyboard protocol implementation
  src/key_scan.c              -- key scanning logic
  include/amigakb.h           -- keyboard protocol definitions
  -- CRITICAL: reuse this for our ATmega324PB keyboard MCU
  -- Already written, tested, working
```

### BOM and Production Files
```
A1200+ (BOM Csv).csv          -- complete BOM with part numbers
A1200+ Rev2 BOM.pdf           -- human readable BOM
A1200+ (Pick And Place Csv).csv -- pick and place data
A1200+.dxf                    -- board outline DXF
-- Use BOM as reference for passives values around AGA chips
```

### Gerbers (for reference, not direct use)
```
A1200Plus_Gerbers_Rev6.zip    -- latest Gerbers
A1200Plus_Gerbers_Rev5.zip
-- Can open in KiCad to study PCB layout
-- Useful for understanding chip placement
```

---

## Raemixx500 (research/reference_boards/Raemixx500/)

### Schematic Sheets (KiCad 5 .sch format)
```
Raemixx500.sch                -- top level hierarchy
cpu.sch                       -- 68000 CPU sheet
  -- Adapt for 68030 (different but related)
cias.sch                      -- CIA 8520 x2
  -- Reuse directly, same chips
audio.sch                     -- Paula audio section
  -- Partial reuse, verify A1200 pinout differences
ram.sch                       -- RAM section
  -- Reference for SIMM/DIP RAM wiring
rom.sch                       -- Kickstart ROM
  -- Reuse directly, same ROM type
power.sch                     -- power distribution
  -- Major reference for our power sheet
video.sch                     -- video output
  -- Reference for Lisa video bus
floppy.sch                    -- floppy controller
  -- Reuse via Paula connections
expansion.sch                 -- expansion connector
  -- Reference for trapdoor wiring
trapdoor.sch                  -- trapdoor specifically
  -- Direct reference, adapt for 150-pin A1200 version
clockdist.sch                 -- clock distribution
  -- Reuse, same crystal frequencies
rtc.sch                       -- real time clock
  -- Reference if we add RTC
terminators.sch               -- bus terminators
  -- Important reference for signal integrity
```

### Symbol Libraries (KiCad 5 .lib format)
```
Most useful for Morosa-1200:

libs/PAULA.lib                -- Paula 8364 PLCC-52
libs/VIA_8520.lib             -- CIA 8520 PLCC-44
libs/AMIGA_ROM.lib            -- Kickstart ROM DIP-40
libs/FAT_AGNUS_8375.lib       -- Agnus (NOT Alice, different)
libs/DENISE.lib               -- Denise (NOT Lisa AGA, different)
libs/TRAPDOOR.lib             -- trapdoor connector
libs/GARY.lib                 -- Gary glue (not needed, reference)
libs/68000D.lib               -- 68000 (not 68030, reference only)
libs/xtal.lib                 -- crystal symbol
libs/amipower.lib             -- Amiga power connector
libs/db9_male_mountingholes.lib -- DB9 connector

Import procedure in KiCad 8:
  Symbol Editor > File > Import Symbol Library
  Select .lib file
  Saves as .kicad_sym automatically
  Review all pins after import
```

### Footprint Library (Raemixx500.pretty/)
```
Most useful footprints:

Trapdoor.kicad_mod            -- A500 trapdoor footprint
                                 Adapt for A1200 150-pin version
DB_9M.kicad_mod               -- DB9 male connector
DB_25M.kicad_mod              -- DB25 (reference only, not used)
Crystal_RTC.kicad_mod         -- RTC crystal footprint
Keyboard_Connector.kicad_mod  -- keyboard connector

These are KiCad 6+ format -- should open directly in KiCad 8
```

### 3D Models
```
3dModels/                     -- STEP files for 3D view
  BS-7.STEP                   -- coin cell holder
  DSN6.step                   -- DIN connector
-- Useful for checking clearances in 3D view
```

---

## Missing Datasheets -- Find These Manually

Still needed -- search these on alldatasheet.com or datasheetarchive.com:

```
MC68882 FPU:
  Search: alldatasheet.com for "MC68882"
  Save to: research/cpu_fpu/MC68882.pdf

ATmega324PB:
  Already downloaded! Check modern_ics/ATmega324PB.pdf
  (fetch_datasheets.sh got it)

ADV7513:
  Already downloaded! Check modern_ics/adv7513.pdf
  AND modern_ics/ADV7513_Hardware_User_Guide.pdf

CY7C136 Dual-port SRAM:
  Search: alldatasheet.com for "CY7C136"
  Or use IDT70V24 instead (search alldatasheet.com)
  Save to: research/modern_ics/

CM4 IO Board Schematic:
  Try: https://datasheets.raspberrypi.com/cm4io/cm4io-schematics.pdf
  Save to: research/cm4/
  Or search "CM4 IO board schematic github"

PLX PCI9052 (PCI bridge):
  Search: broadcom.com for PCI9052
  Or: alldatasheet.com for "PCI9052"
  Save to: research/modern_ics/PLX_PCI9052.pdf

PLX PEX8606 (PCIe switch):
  Search: broadcom.com for PEX8606
  Save to: research/modern_ics/PLX_PEX8606.pdf
```

---

## Priority Action List

### Immediate -- before opening KiCad
```
1. Open and read:
   research/reference_boards/amiga-1200/A1200+_Schematics_Rev5.pdf
   -- Study Alice, Lisa, Gayle, Budgie connections
   -- Note all power pins and decoupling
   -- Note all bus connections

2. Open and read:
   research/reference_boards/amiga-1200/VideoExpansion/
   SimpleRGBBoard/SimpleRGBBoard Rev0 Schematics.pdf
   -- How Lisa video bus is connected externally
   -- Direct reference for ADV7513 input connections

3. Open and read:
   research/reference_boards/Raemixx500/power.sch
   -- In KiCad 5 or as reference
   -- Power distribution approach

4. Copy keyboard firmware for later use:
   reference_boards/amiga-1200/Firmware/Keyboard/
   KeyboardController/main.c and src/amigakb.c
   -- Already written keyboard MCU code
   -- Will save weeks of firmware work
```

### First KiCad Session
```
1. Create project: hardware/mainboard/Morosa-1200.kicad_pro
2. Import Raemixx500 libs (PAULA, VIA_8520, AMIGA_ROM etc)
3. Check KiCad 8 standard lib for 68030, CM4
4. Draw 01_power.kicad_sch
5. Draw 22_clocks.kicad_sch (simple, good warmup)
```

---

## Visual-Retro-Emulator Note

The Visual-Retro-Emulator project would complement Morosa-1200 well.
When IMG Factory work is complete, consider resuming it.
The emulator testing could run on the CM4 Linux side,
providing software testing of Morosa-1200 hardware behaviour
before physical boards are available.
Pause was correct -- finish IMG Factory first.
