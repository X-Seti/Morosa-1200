# X-Seti - June 2026 - Morosa-1200 - Project Overview

"""
Morosa-1200 - Open hardware Mini-ITX Amiga 1200 AGA reimagining.
Morosa is Northern Italian slang for girlfriend.
A love letter to the Amiga 1200, built on BBC Micro Tube philosophy.
"""

# Morosa-1200

Morosa-1200 is a Mini-ITX Amiga 1200 reimagining built on BBC Micro Tube
co-processor philosophy. Real AGA silicon. Modern expansion. Empty sockets
for the user to fill at their own pace.

This is not an emulator. Not an FPGA clone. Real silicon, new board.
The Amiga soul. The Tube spine.

---

## One Sentence

Morosa-1200 is a Mini-ITX Amiga 1200 that works out of the box with real
AGA silicon and onboard RTG, with empty sockets for FPU, CM4, Tube cards,
PCIe GPU, PCI GPU, trapdoor accelerator and GPU daughter board -- expand
it at your own pace, in any order, as budget and availability allow.

---

## The BBC Tube Philosophy

```
BBC Micro 1982:          Morosa-1200 2026:
  6502 (host CPU)          68030 (host CPU)
  Tube ULA (interface)     Dual-port SRAM + FPGA
  ARM/Z80 co-processor     CM4 + Tube Port cards
  Empty Tube connector     Empty Tube Port socket

6502 ran BBC BASIC        68030 runs AmigaOS
ARM did computation        CM4 + GPU does rendering
Both ran simultaneously    Both run simultaneously
44 years apart. Same architecture. Still correct.
```

---

## Out of the Box

### Soldered to board (no user action needed)
```
GD5446 RTG chip    16MB VRAM onboard
                   1920x1080x32bit comfortable
                   1920x1080x32bit + double buffer
                   CGX and P96 driver support
                   PQFP package, reliable, solderable

ADV7513            HDMI transmitter (Lisa → HDMI 1)
ATmega324PB        Keyboard MCU
ATtiny             Power management MCU
6N137              MIDI optocoupler
PCM5102A           Audio DAC (stereo out)
PCM1808            Audio ADC (stereo in / sampling)
All passives       Crystals, caps, resistors
```

### User fits from donor A1200
```
Alice  MOS 8374   PLCC-84 socket   AGA DMA/blitter/copper
Lisa   MOS 4203   PLCC-84 socket   AGA video output
Paula  MOS 8364   PLCC-52 socket   Audio/floppy/serial/IRQ
Gayle  MOS 391424 PLCC-52 socket   IDE/chip select
Budgie MOS 391425 SOJ socket       PCMCIA buffer
CIA x2 MOS 8520   PLCC-44 sockets  I/O controllers
68030             QFP-132 socket   Main CPU
Kickstart ROMs    DIP-40 sockets x2
```

### User sources new
```
72-pin SIMM x1    2MB (Chip RAM, Alice limit)
72-pin SIMM x2    Up to 8MB each (Fast RAM)
USB keyboard
HDMI cable
ATX PSU
Mini-ITX case
```

### Empty sockets -- fit when ready
```
68882 FPU         PLCC-52 at U0    Hardware float
CM4 socket        200-pin          Modern I/O co-processor
Tube Port         Edge connector   CPU co-processor cards
PCIe x8 slot      Row 3            GPU (RX 5900 XT etc)
PCIe x4 slot      Row 4            Expansion cards
PCI slot          Row 1            Radeon 7000, Voodoo3
GPU daughter board Phase 2         RV350 + Theater 200
```

---

## The Expansion Journey

```
Stage 0 -- Out of box
  68030 + AGA + 16MB Fast + GD5446 RTG
  HDMI 1, audio, MIDI, IDE, SD
  1920x1080x32bit RTG screen modes
  Better than any stock A1200 ever made

Stage 1 -- Add 68882 FPU (£5-15)
  Hardware float, LightWave, flight sims

Stage 2 -- Add CM4 module (£25-75)
  USB x4, GbE, HDMI 2, extended Fast RAM
  Video decode offload, modern I/O

Stage 3 -- Add Tube Port card
  Z80 card: CP/M alongside AmigaOS
  6502 card: BBC BASIC on real silicon
  FPGA card: any soft CPU
  Community designed, open standard

Stage 4 -- Add PCI GPU (£5-10)
  Radeon 7000 PCI or Voodoo3 PCI
  Native Warp3D on 68030 bus
  PS1-PS2 gap performance

Stage 5 -- Add PCIe GPU (already owned)
  RX 5900 XT, R9 285 etc
  CM4 owns via PCIe switch
  Ray tracing, 12GB GDDR6, PS3+ territory

Stage 6 -- Add trapdoor accelerator
  TF1260, PiStorm32, ACA1233n
  Faster main CPU, more Fast RAM

Stage 7 -- Add GPU daughter board
  RV350 from AIW 9600 Pro donor
  Theater 200 PAL/NTSC capture
  Native Warp3D above PS2
```

---

## Architecture -- Three Tiers

### Tier 1 -- The Soul (68030 + AGA)
```
68030 @ 50MHz         host CPU, AmigaOS
68882 socket at U0    FPU (optional, fit when ready)
AGA custom chips      from donor A1200
72-pin SIMM x1        2MB Chip RAM (Alice limit)
72-pin SIMM x2        up to 16MB Fast RAM
Kickstart ROM x2      DIP-40 sockets
GD5446 + 16MB VRAM   onboard RTG, works alone
```

### Tier 2 -- The Bridge (CM4 co-processor)
```
CM4 socket (200-pin)  BCM2711, 1-8GB LPDDR4
Direct CPU GPIO        cycle-accurate, PiStorm proven
Dual-port SRAM         BBC Tube comms window
40-pin GPIO header     RPi compatible, CM4 direct
CM4 boots first        initialises I/O, releases 68030
AmigaOS stub libs      transparent access to CM4 services
```

### Tier 3 -- The Tube Port (co-processor cards)
```
Edge connector         open standard, documented
Default: empty         fits when user ready
Z80 card               CP/M, BBC Tube compatible
6502 card              BBC/Apple style
FPGA card              soft CPU, user defined
FPGA on mainboard      translates any CPU to Amiga bus
ID EEPROM on card      FPGA detects and configures
```

---

## Video Output

```
HDMI 1 -- AGA native (always present, no CM4 needed)
  Lisa → ADV7513 → HDMI Type-A
  Exact PAL 50Hz or NTSC 59.94Hz
  All AGA screen modes, HAM8, copper effects
  Pixel perfect, no frame conversion

HDMI 2 -- RTG/CM4 (when CM4 fitted)
  CM4 BCM2711 native HDMI
  1080p, 1440p, 4K
  CGX/P96 screen modes
  Video decode, composited Workbench

Both run simultaneously
```

---

## RTG -- GD5446 with 16MB VRAM

```
GD5446 (Cirrus Logic):
  Package:  PQFP -- solderable, no BGA risk
  VRAM:     16MB onboard (8x 2MB chips)
  Drivers:  CGX and P96 confirmed
  2D accel: Yes -- fast Workbench
  3D:       No -- honest about it
  
Screen modes with 16MB VRAM:
  1920x1080 x 32-bit = 7.91MB  ✅ fits
  1920x1080 x 32-bit + double buffer = 15.82MB ✅ fits
  2560x1440 x 16-bit = 7.03MB  ✅ fits
  1280x1024 x 32-bit = 3.93MB  ✅ fits
  Any sensible RTG resolution   ✅ comfortable

Works completely without CM4.
Base machine RTG from day one.
```

---

## RAM Architecture

```
Chip RAM:
  1x 72-pin SIMM, 2MB max
  Alice hard silicon limit
  68030 + AGA chipset shared

Fast RAM:
  2x 72-pin SIMM, up to 16MB
  68030 local bus, direct access
  Non-EDO, 32-bit wide, 70-80ns

Extended Fast RAM (CM4 fitted):
  CM4 LPDDR4 slice (512MB-1GB)
  FPGA bridges to 68030 local bus
  Extends onboard SIMMs
  Whatever CM4 module provides

Trapdoor Fast RAM:
  Accelerator card's own RAM
  128-256MB (TF1260, PiStorm32)
  Direct 68030 local bus access

CM4 system RAM:
  LPDDR4 on CM4 module
  1-8GB depending on module
  Linux, video buffers, offload tasks

Tube comms:
  Dual-port SRAM chip, 1-4MB
  68030 and CM4 shared window
  BBC Tube FIFO equivalent

Total 68030 accessible:
  2MB chip + 16MB SIMM + 1GB CM4 slice
  + 256MB trapdoor = ~1.3GB realistic max
```

---

## I/O -- What Was Kept, What Was Dropped

```
Dropped from original A1200:
  23-pin video port    HDMI 1 replaces entirely
  DB25 parallel        PCM1808 ADC replaces sampling
  DB25 serial          Paula header + MIDI DIN-5
  PCMCIA               2x SD slots replace it

Kept:
  DB9 joystick x2      CIA pot pins, authentic, tiny
                       Megadrive pads work natively

Added:
  HDMI x2              AGA native + RTG simultaneous
  USB x4               via CM4
  Gigabit Ethernet     via CM4
  Audio out 3.5mm      PCM5102A DAC
  Audio in 3.5mm       PCM1808 ADC (replaces parallel sampling)
  MIDI in/out DIN-5    onboard, no external box
  SD card x2           AmigaOS + CM4 independent
  40-pin GPIO          RPi compatible, CM4 direct
  VGA optional         scan doubler output
```

---

## Expansion Slots

```
Row 1: PCI 32-bit 33MHz (68030 owned)
       Via PLX PCI9052 bridge
       Radeon 7000 PCI, Voodoo3 PCI
       Native Warp3D to 68030
       Backplate access

Row 2: A1200 Trapdoor (offset, internal)
       Full 32-bit 68030 bus
       TF1260, PiStorm32, ACA1233n
       No backplate -- internal only

Row 3: PCIe x8 (CM4 owned)
       Via PLX PEX8606 switch
       GPU slot -- RX 5900 XT, R9 285
       Backplate access

Row 4: PCIe x4 (CM4 owned)
       Via PLX PEX8606 switch
       NVMe adapter, 10GbE, sound
       Backplate access

Tube Port: (internal, small edge connector)
       Open standard CPU cards
       Z80, 6502, FPGA, ARM bare metal
       FPGA translates to Amiga bus
       Community expandable
```

---

## Storage

```
IDE header x2        Primary HDD + secondary CDROM
SD slot x1           AmigaOS side, IDE-to-SD bridge
SD slot x2           CM4 boot and Linux system
Floppy header        34-pin, A1200 or PC DD drive
M.2 NVMe             Via CM4 PCIe (Linux side)
```

---

## Historical Context

```
1990: Amiga Video Toaster does ray tracing
      LightWave 3D, $3000 vs $50,000 SGI
      
1993: Jurassic Park CGI -- modelled on Amiga
      Babylon 5 -- entire series on Video Toaster
      Star Trek Voyager -- Foundation Imaging, Amiga
      
1994: Commodore bankrupt. Amiga abandoned.
      At its creative peak.
      
2026: Morosa-1200
      Real AGA silicon
      BBC Tube co-processor architecture
      Hardware ray tracing via RX 5900 XT
      LightWave renders in real time
      The Video Toaster started something.
      Morosa-1200 finishes it.
```

---

## Repository Structure

```
Morosa-1200/
  hardware/
    mainboard/       KiCad 8 -- main PCB
    tube_port/       Tube Port connector spec
    cards/
      z80_card/      Z80 co-processor card
      6502_card/     6502 co-processor card
      fpga_card/     Soft CPU card
    video/           Video output board
    gpu_daughter/    RV350 daughter board (Phase 2)
  docs/
    DESIGN_NOTES.md       Architecture decisions
    CPU_RAM.md            CPU/RAM/expansion strategy
    IO_SPEC.md            Connectors and ports
    VIDEO_ARCHITECTURE.md Dual HDMI, AGA, RTG
    CM4_OFFLOAD.md        BBC Tube offload paths
    GPU_STRATEGY.md       GPU selection, CM4 controller
    TUBE_PORT_SPEC.md     Tube Port open standard
    TRANSPLANT.md         Donor chip removal guide
    REFERENCES.md         Git repos and datasheets
    REFERENCE_ASSETS.md   Reference repo inventory
    HISTORY.md            Video Toaster legacy
    KICAD_PLAN.md         Schematic plan
    KICAD_SYMBOLS.md      Symbol audit
  research/
    amiga_chipset/   Alice, Lisa, Paula, Gayle docs
    modern_ics/      ADV7513, PCM5102A, PCM1808 etc
    cm4/             CM4 datasheet, BCM2711, IO board
    cpu_fpu/         68030, 68882, 68060 manuals
    gpu/             RV350, R9 285 docs
    reference_boards/ A1200+ and Raemixx500 repos
  bom/               Bill of materials
  README.md
```

---

## Status

```
Architecture:    DECIDED -- all major decisions made
Documentation:   COMPLETE -- all docs written
Datasheets:      COMPLETE -- all critical PDFs gathered
KiCad:           STARTING -- schematic work beginning

Next steps:
  [ ] Create KiCad project
  [ ] Import Raemixx500 symbol libraries
  [ ] Draw 01_power.kicad_sch
  [ ] Draw 22_clocks.kicad_sch
  [ ] Draw 02_cpu_68030.kicad_sch
  [ ] Continue through all 22 sheets
  [ ] PCB layout
  [ ] Design review
  [ ] Prototype fabrication
```

---

## Toolchain

```
KiCad 8            Schematic and PCB layout
JLCPCB / PCBWay    6-layer controlled impedance fab
Yosys / nextpnr    FPGA synthesis (Garuda native)
Garuda Linux       KDE Wayland development
```

---

## Licence

```
Hardware:       CERN-OHL-S v2
Documentation:  CC BY-SA 4.0
FPGA cores:     GPL v2
```

---

## References

```
Amiga Hardware Reference: http://amigadev.elowar.com
AmigaWiki:                https://www.amigawiki.org
PiStorm32-Lite:           https://github.com/PiStorm/pistorm32-lite-hardware
A1200+ project:           https://bitbucket.org/jvandezande/amiga-1200
Raemixx500:               https://github.com/SukkoPera/Raemixx500
LightWave history:        https://en.wikipedia.org/wiki/LightWave_3D
locator.reamiga.info:     http://locator.reamiga.info
English Amiga Board:      https://eab.abime.net
```

---

"Morosa" -- Northern Italian slang for girlfriend.
Because some loves never die.

In 1990 the Video Toaster put ray tracing in the hands of anyone with
$3000 and an Amiga. Jurassic Park. Babylon 5. Star Trek Voyager.
All on Amiga hardware. Then Commodore collapsed.

Morosa-1200 continues that tradition. Real AGA silicon. BBC Tube
co-processor architecture. Hardware ray tracing. The architecture
the Video Toaster proved, rebuilt for 2026.
