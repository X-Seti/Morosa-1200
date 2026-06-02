# X-Seti - May 2026 - Morosa-1200 - Project Overview

"""
Morosa-1200 - Open hardware Mini-ITX Amiga 1200 AGA reimagining.
Morosa is Northern Italian slang for girlfriend. A love letter to the Amiga 1200.
"""

# Morosa-1200

Morosa-1200 is an open hardware reimagining of the Commodore Amiga 1200 mainboard
in the Mini-ITX form factor (170x170mm), designed to accept transplanted AGA custom
chips from a donor A1200 while adding modern connectivity the original never had.

This is not an emulator. Not an FPGA clone. Real silicon, new board.
The soul of the Amiga preserved. The body rebuilt for 2026.

---

## The Architecture -- Three Tiers

### Tier 1 -- The Soul (Amiga)
The authentic Amiga core. Frozen in amber. Never changes.

- 68030 @ 50MHz onboard (full 32-bit address bus, built-in MMU)
- 68882 FPU socket at U0 (always designed in, never fitted by Commodore)
- AGA custom chips from donor A1200:
  Alice (MOS 8374) PLCC-84 -- DMA, blitter, copper
  Lisa  (MOS 4203) PLCC-84 -- video output
  Paula (MOS 8364) PLCC-52 -- audio, floppy, serial, IRQ
  Gayle (MOS 391424) PLCC-52 -- IDE, chip select
  Budgie (MOS 391425) SMD -- PCMCIA buffer
  CIA x2 (MOS 8520) PLCC-44 -- I/O controllers
- 1x 72-pin SIMM -- Chip RAM (2MB max, Alice hard limit)
- 2x 72-pin SIMM -- Fast RAM (16MB max, non-EDO, 32-bit wide)
- Kickstart ROM x2 DIP-40 sockets

### Tier 2 -- The Bridge (CM4 co-processor)
The BBC Tube model. ARM as intelligent controller.
CM4 does not replace the 68030 -- it works alongside it.

- CM4 socket (BCM2711) -- Raspberry Pi Compute Module 4
- Direct CPU GPIO -- cycle-accurate, proven via PiStorm32
- 32MB/s sustained GPIO bandwidth -- matches 68030 bus
- Dual-port SRAM (IDT70V24 / CY7C136, 1-4MB) -- BBC Tube comms
- CM4 boots first, initialises all I/O, then releases 68030 reset
- AmigaOS accesses CM4 services via stub libraries transparently
- 40-pin GPIO header -- RPi compatible, direct BCM2711
- CM4 socket is swappable -- future module upgrades without board respin

### Tier 3 -- The Muscle (GPU via CM4 PCIe)
The 68030 cannot drive modern GPUs directly.
CM4 acts as intelligent GPU controller on its behalf.

- CM4 PCIe lane connects to PCIe switch
- GPU hangs off PCIe switch -- owned entirely by CM4 Linux
- 68030 issues draw commands via SRAM mailbox
- CM4 translates to Vulkan/OpenGL and drives GPU
- Results returned to 68030 via SRAM
- AmigaOS gets modern GPU rendering without knowing how

Reference GPU (already owned): RX 5900 XT
  RDNA2, 12GB GDDR6, 672 GB/s bandwidth
  Hardware ray tracing
  Vulkan 1.3, OpenGL 4.6
  ~18x PS3 performance
  AMDGPU open source driver on CM4 Linux

Development GPU: R9 285 / R9 380 (GCN 1.2)
  Lower power, same driver stack
  More than sufficient for Amiga RTG offload
  Use for bench testing before committing RX 5900 XT

---

## The BBC Tube Parallel

```
BBC Micro 1982:          Morosa-1200 2026:
  6502 (brain)             68030 (brain)
  Tube ULA (controller)    Dual-port SRAM (controller)
  ARM2 co-processor        CM4 + PCIe GPU (muscle)

6502 ran BBC BASIC        68030 runs AmigaOS
ARM2 did computation      CM4+GPU does rendering
6502 got results back     68030 gets results back
44 years apart. Same architecture. Still correct.
```

---

## Video Output -- Two Independent HDMI Outputs

HDMI 1 -- AGA Native (Lisa -> ADV7513)
  Exact PAL 50Hz or NTSC 59.94Hz pixel clock
  No frame rate conversion, no judder
  All AGA screen modes, HAM8, copper effects
  Pixel perfect -- exactly as original hardware

HDMI 2 -- RTG / CM4 (BCM2711 native)
  Any resolution -- 1080p, 1440p, 4K
  CGX/P96 screen modes via stub driver
  Video decode, composited Workbench
  GPU rendering output

Both outputs run simultaneously.
One monitor: two HDMI inputs, press button to switch worlds.
Two monitors: AGA on one, RTG on the other.

---

## CM4 Offload -- What the 68030 Gets For Free

| Task | Stock A1200 | With CM4 |
|---|---|---|
| H.264 1080p video | Impossible | Hardware decode, smooth |
| MP3/OGG audio | Painful | Trivial |
| RTG 1080p | Not possible | CM4 VideoCore / RX 5900 XT |
| Warp3D 3D | Limited | Above PS3 via GPU |
| Networking | Slow modem | Gigabit Ethernet |
| USB | Not possible | Full HID + mass storage |
| PAL/NTSC capture | External hw | Theater 200 onboard (Phase 2) |
| AGA self-capture | Not possible | Real-time H.264 encode |
| Ray tracing | Never | RX 5900 XT hardware RT |
| LightWave render | Hours on 68030 | Real-time via CM4+GPU |

---

## I/O -- What Was Kept, What Was Dropped

Dropped from original A1200:
  23-pin video port  -- HDMI 1 replaces entirely
  DB25 parallel      -- every use case covered better
  DB25 serial        -- Paula header + MIDI DIN-5
  PCMCIA slot        -- replaced by 2x SD card slots

Kept:
  DB9 joystick x2    -- CIA pot pins, authentic, tiny
                        Megadrive pads work natively

Added:
  HDMI x2            -- AGA native + RTG simultaneous
  USB x4             -- via CM4
  Gigabit Ethernet   -- via CM4
  Audio out 3.5mm    -- PCM5102A DAC (clean 16-bit)
  Audio in 3.5mm     -- PCM1808 ADC (replaces parallel sampling)
  MIDI in/out DIN-5  -- onboard, no external box needed
  SD card x2         -- AmigaOS + CM4 independent
  40-pin GPIO        -- RPi compatible, CM4 direct
  VGA optional       -- scan doubler output

---

## Storage

- IDE header x2 -- primary (HDD) and secondary (CDROM)
- SD slot 1 -- AmigaOS side via IDE-to-SD bridge
- SD slot 2 -- CM4 boot and Linux system
- Floppy header 34-pin -- original A1200 or PC DD drive
- NVMe M.2 -- via CM4 PCIe (Linux side)
- No SATA -- bus speed mismatch, bridge not justified

---

## Native PCI GPU (68030 direct)

A small PCI bridge chip (PLX PCI9052 or similar) onboard
bridges the 68030 local bus to a standard PCI slot.

Target card: ATI Radeon 7000 PCI (RV100)
  Most common, cheapest card with Amiga driver support
  P96 confirmed, Warp3D confirmed
  £5-10 on eBay
  PS1-PS2 gap performance
  Native Warp3D to 68030 -- no CM4 involvement

PCI bridge populated Rev 2 (pads routed in Rev 1).

---

## GPU Daughter Board (Phase 2)

RV350 from donor ATI All-In-Wonder 9600 Pro/XT
  Above PS2 / near Xbox OG performance
  P96 + Warp3D native
  BGA reflow required -- done as daughter board
  Protects main PCB from failed reflow

ATI Theater 200 alongside RV350:
  PAL 625/50Hz and NTSC 525/59.94Hz hardware capture
  S-Video + composite input
  V4L2 driver on CM4 Linux
  Use cases: VHS archiving, AGA self-capture

---

## System Controllers

- Keyboard MCU  -- ATmega324PB (USB HID + A1200 protocol bridge)
- Power MCU     -- ATtiny (soft power, reset, LEDs, ATX PS_ON)
- ROM MCU       -- Kickstart flash selection

---

## Trapdoor Expansion

Standard A1200 150-pin edge connector, full 32-bit bus.
All 32 address lines routed (A24-A31 live, unlike original A1200).
Compatible: TF1230, TF1260, ACA1233n, Apollo, PiStorm32-Lite.
Open sockets for future expansion cards.
FPGA/CPLD pads populated or not at build time.

---

## Form Factor

- Mini-ITX 170x170mm
- 6-layer PCB, KiCad 8
- ATX 24-pin power
- Standard ATX case mounting
- JLCPCB / PCBWay fabrication target

---

## What You Need

From a donor A1200:
  Alice, Lisa, Paula, Gayle, Budgie, CIA x2,
  crystal oscillators, Kickstart ROMs

From a donor CyberVision 64/3D (Phase 2):
  S3 Virge/VX chip -- if used
  OR use ATI AIW 9600 Pro/XT as GPU donor instead

From ATI AIW 9600 Pro/XT (Phase 2 GPU board):
  RV350 GPU chip
  DDR memory chips
  ATI Theater 200 capture chip

New silicon:
  68030 QFP-132, 68882 PLCC-52
  CM4 module (BCM2711)
  ADV7513 HDMI transmitter
  Dual-port SRAM (IDT70V24 or CY7C136)
  PCM5102A DAC, PCM1808 ADC
  ATmega324PB, ATtiny
  PLX PCI9052 (Rev 2)
  All passives

---

## Repository Structure

```
Morosa-1200/
  hardware/
    mainboard/     KiCad 8 -- main PCB
    video/         Video output board
    audio/         Audio I/O board
    io/            USB/Ethernet/SD
  docs/
    DESIGN_NOTES.md      Architecture decisions
    CPU_RAM.md           CPU/RAM/expansion strategy
    IO_SPEC.md           All connectors and ports
    VIDEO_ARCHITECTURE.md Dual HDMI, AGA native, RTG
    CM4_OFFLOAD.md       BBC Tube model, offload paths
    GPU_STRATEGY.md      GPU selection, CM4 as controller
    TRANSPLANT.md        Donor chip removal guide
    REFERENCES.md        All git repos and datasheets
    HISTORY.md           Video Toaster legacy, LightWave
  research/        Reference schematics, datasheets
  bom/             Bill of materials
  README.md
```

---

## Status

Pre-design / Research phase -- architecture fully decided

- [x] Architecture decided
- [x] CPU/RAM strategy decided
- [x] I/O specification decided
- [x] Video architecture decided
- [x] CM4 offload architecture decided
- [x] GPU strategy decided
- [x] All documentation written
- [ ] Gather all datasheets into research/
- [ ] KiCad schematic -- core chipset
- [ ] KiCad schematic -- CM4 interface + dual-port SRAM
- [ ] KiCad schematic -- video path (Lisa + ADV7513)
- [ ] KiCad schematic -- audio path
- [ ] KiCad schematic -- USB/IO/storage
- [ ] KiCad schematic -- PCI bridge (Rev 2)
- [ ] PCB layout -- Mini-ITX 6-layer
- [ ] Design review
- [ ] Prototype fabrication (Rev 1)
- [ ] Bring-up and testing

---

## Toolchain

- KiCad 8 -- schematic and PCB layout
- JLCPCB / PCBWay -- 6-layer controlled impedance
- Garuda Linux / KDE Wayland

---

## Licence

Hardware: CERN Open Hardware Licence v2 - Strongly Reciprocal (CERN-OHL-S)
Documentation: CC BY-SA 4.0

---

## References

- Amiga Hardware Reference: http://amigadev.elowar.com
- AmigaWiki: https://www.amigawiki.org
- PiStorm32-Lite: https://github.com/PiStorm/pistorm32-lite-hardware
- locator.reamiga.info: http://locator.reamiga.info
- English Amiga Board: https://eab.abime.net
- LightWave 3D history: https://en.wikipedia.org/wiki/LightWave_3D
- Foundation Imaging: https://en.wikipedia.org/wiki/Foundation_Imaging

---

"Morosa" -- Northern Italian slang for girlfriend.
Because some loves never die.

In 1990 the Video Toaster put ray tracing in the hands of anyone
with $3000 and an Amiga. Jurassic Park. Babylon 5. Star Trek Voyager.
All rendered on Amiga hardware.

Morosa-1200 continues that tradition.
Real AGA silicon. Modern ARM co-processor. Hardware ray tracing.
The architecture the Video Toaster proved, rebuilt for 2026.
