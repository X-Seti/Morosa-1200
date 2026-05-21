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

---

## Project Goals

- Accept all original A1200 AGA custom chips from a donor board
- Mini-ITX form factor - fits any standard modern PC case
- ATX power connector
- Modern I/O without sacrificing Amiga authenticity
- Transplant-friendly: donor A1200 as primary chip source
- Open hardware - KiCad 8, fully documented, community forkable

---

## Architecture Summary

### Tier 1 - The Soul (Amiga)
- 68030 @ 50MHz onboard (full 32-bit address bus)
- 68882 FPU socket (U0 - always designed in, never fitted by Commodore)
- AGA custom chips from donor A1200 (Alice, Lisa, Paula, Gayle, CIAs)
- 1x 72-pin SIMM - Chip RAM (2MB max, Alice hard limit)
- 2x 72-pin SIMM - Fast RAM (16MB max, non-EDO, 32-bit wide)

### Tier 2 - The Bridge (ARM co-processor)
- CM4 socket (BCM2711) - Raspberry Pi Compute Module 4
- Direct CPU GPIO - cycle-accurate 68k bus interface (proven via PiStorm32)
- 32MB/s sustained GPIO bandwidth - matches 68030 bus throughput
- Runs Linux - handles all modern I/O services
- Communicates with 68030 via dual-port SRAM window (BBC Tube architecture)
- 40-pin GPIO header (RPi-compatible, direct BCM2711, low latency)
- CM4 socket is swappable - future module upgrades without board respin

### Tier 3 - The Expansion
- Standard A1200 trapdoor connector (full 32-bit bus, all address lines)
- Compatible: TF1230, TF1260, ACA1233n, Apollo, PiStorm32-Lite
- Open sockets for future expansion cards
- FPGA pads on trapdoor interface (populated or not at build time)

---

## Hardware Specification

### Core (Donor A1200 chips)
- Alice (MOS 8374)    - AGA Agnus, DMA/blitter/copper (PLCC-84)
- Lisa (MOS 4203)     - AGA Denise, video output (PLCC-84)
- Paula (MOS 8364)    - Audio/floppy/serial/IRQ (PLCC-52)
- Gayle (MOS 391424)  - IDE/PCMCIA/chip select (PLCC-52)
- Budgie (MOS 391425) - PCMCIA buffer (SMD SOJ)
- CIA x2 (MOS 8520)   - I/O controllers (PLCC-44)
- 68030 CPU           - QFP-132, replaces donor 68EC020
- 68882 FPU           - PLCC-52 socket at U0
- Kickstart ROM x2    - DIP-40 sockets

### Video
- Lisa digital video bus on internal header
- HDMI output via SiI9022A or ADV7513 transmitter
- VGA port via onboard scan doubler (15kHz/31kHz)
- RGB Mini-DIN (PS2/PS3 style) for direct analogue RGB
- A4000-style internal video slot header

### Graphics Expansion
- S3 Virge/VX transplanted from CyberVision 64/3D donor
- 4MB VRAM transplanted from donor card
- CyberGraphX driver compatible
- Direct bus connection (not Zorro slot)

### Audio
- Paula audio DMA tapped directly
- PCM5102A stereo DAC - 16-bit audio out (3.5mm)
- PCM1808 stereo ADC - audio in (3.5mm)
- MIDI IN/OUT - 6N137 optocoupler + DIN-5, wired to Paula serial TX/RX

### Storage
- IDE header x2 - primary (HDD) and secondary (CDROM), 40-pin
- SD card slots x2 - via IDE-to-SD bridge
- Floppy header - 34-pin, original A1200 or PC DD drive
- NVMe M.2 via CM4 PCIe (Linux side)

### USB / Networking
- USB host x4 via CM4 (Linux side, transparent to AmigaOS via device driver)
- Gigabit Ethernet via CM4
- USB keyboard/mouse bridged to AmigaOS via ATmega324PB MCU

### System Controllers
- Keyboard MCU  - ATmega324PB (USB HID + A1200 keyboard protocol)
- Power MCU     - ATtiny (soft power, reset, LEDs, ATX PS_ON)
- ROM MCU       - Kickstart flash selection / switching

### Co-processor Communication
- Dual-port SRAM (IDT70V24 or CY7C136, 1-4MB)
- 68030 and CM4 both access shared window
- BBC Tube-style message passing architecture
- CM4 can interrupt 68030 via _INT2 or _INT6
- 40-pin GPIO header - RPi-compatible, direct BCM2711

### Form Factor
- Mini-ITX 170x170mm, 6-layer PCB, KiCad 8
- ATX 24-pin power connector
- Standard ATX case mounting holes
- I/O shield: HDMI, VGA, USB x4, audio in/out, MIDI, Ethernet, RGB Mini-DIN

---

## What You Need

### From a Donor A1200
Alice, Lisa, Paula, Gayle, Budgie, CIA x2, crystal oscillators, Kickstart ROMs

### From a Donor CyberVision 64/3D
S3 Virge/VX chip, 4x 1MB VRAM chips

### New Silicon
68030, 68882, CM4 module, dual-port SRAM, PCM5102A, PCM1808,
SiI9022A/ADV7513, ATmega324PB, ATtiny, CH376S, all passives

---

## Repository Structure

```
Morosa-1200/
- hardware/
  - mainboard/    KiCad 8 project - main PCB
  - video/        Video output board (HDMI/VGA/RGB)
  - audio/        Audio I/O (DAC/ADC/MIDI)
  - io/           USB/Ethernet/SD controller
- docs/
  - DESIGN_NOTES.md   Architecture decisions and rationale
  - CPU_RAM.md        CPU/RAM/expansion strategy
  - TRANSPLANT.md     Donor chip removal and transplant guide
  - REFERENCES.md     Datasheets, schematics, community resources
- research/       Reference schematics, datasheets, notes
- bom/            Bill of materials (CSV, interactive HTML)
- README.md
```

---

## Status

Pre-design / Research phase

- [ ] Finalise feature set
- [ ] Gather donor chip datasheets and pinouts
- [ ] KiCad schematic - core chipset
- [ ] KiCad schematic - video path
- [ ] KiCad schematic - audio path
- [ ] KiCad schematic - USB/IO/CM4 interface
- [ ] PCB layout - Mini-ITX 6-layer
- [ ] Design review
- [ ] Prototype fabrication
- [ ] Bring-up and testing

---

## Toolchain

- KiCad 8 - schematic and PCB layout
- JLCPCB / PCBWay - fabrication (6-layer, controlled impedance)
- Garuda Linux / KDE Wayland

---

## Licence

Hardware: CERN Open Hardware Licence v2 - Strongly Reciprocal (CERN-OHL-S)
Documentation: CC BY-SA 4.0

---

## References

- Amiga Hardware Reference: http://amigadev.elowar.com
- AmigaWiki: https://www.amigawiki.org
- PiStorm32-Lite hardware: https://github.com/PiStorm/pistorm32-lite-hardware
- locator.reamiga.info: http://locator.reamiga.info
- English Amiga Board: https://eab.abime.net

---

"Morosa" - Northern Italian slang for girlfriend. Because some loves never die.
