# Morosa-1200

**Morosa** — Italian slang for *girlfriend*. A love letter to the Amiga 1200.

Morosa-1200 is an open hardware reimagining of the Commodore Amiga 1200 mainboard in the **Mini-ITX form factor (170×170mm)**, designed to accept transplanted AGA custom chips from a donor A1200 while adding modern connectivity that the original board never had.

This is not an emulator. Not an FPGA clone. Real silicon, new board.

---

## Project Goals

- Accept all original A1200 AGA custom chips (Alice, Lisa, Paula, Gayle, Budgie, CIAs, 68020)
- Mini-ITX form factor — fits any standard modern PC case
- ATX power connector
- Modern I/O without sacrificing Amiga authenticity
- Transplant-friendly: designed around a donor A1200 as primary chip source
- Open hardware — KiCad 8, fully documented, community forkable

---

## Inspired By / Standing On The Shoulders Of

| Project | What we learned |
|---|---|
| [Amiga 1200+ (Vandezande)](https://bitbucket.org/jvandezande/amiga-1200) | Modular daughterboard approach, video bus exposure |
| [Rämixx500 (SukkoPera)](https://github.com/SukkoPera/Raemixx500) | KiCad methodology, open hardware best practices |
| [Alicia 1200 (Enterlogic)](https://www.enterlogic.se) | Mini-ITX AGA form factor validation, Tornado slot concept |
| [AmigaPCI (jasonsbeer)](https://github.com/jasonsbeer/AmigaPCI) | Modern bus integration thinking |
| [Deniser (endofexclusive)](https://github.com/endofexclusive/deniser) | FPGA chip replacement approach |
| [Re-Amiga 1200 (Chucky Hertell)](https://wordpress.hertell.nu) | Donor chip transplant methodology |

---

## Target Hardware Specification

### CPU
- **Default:** Motorola 68EC020 @ 14.18MHz (PLCC-68, from donor A1200)
- **Onboard socket:** PLCC-68, accepts 68EC020 or full 68020 (adds MMU)
- **Upgrade path:** Trapdoor slot accepts standard A1200 accelerators (Blizzard 1230/1240/1260 etc)
  - 68030 + 68882 FPU via accelerator
  - 68040 (integral MMU+FPU) via accelerator
  - 68060 (integral MMU+FPU, 75MHz) via accelerator

### RAM
- **Chip RAM:** 1x 72-pin SIMM socket — max **2MB** (hard Alice limit)
- **Fast RAM:** 2x 72-pin SIMM sockets — max **16MB** onboard (32-bit, 70-80ns, non-EDO)
- **Extended Fast RAM:** up to 128MB via trapdoor accelerator card
- DIMM not used — 72-pin SIMM required to match memory controller bus width
### Core (Donor A1200 chips)
- **Alice (MOS 8374):** AGA Agnus -- DMA, blitter, copper (PLCC-84, from donor)
- **Lisa (MOS 4203):** AGA Denise — video output (PLCC-84, from donor)  
- **Paula (MOS 8364):** Audio, floppy, serial, interrupts (PLCC-52, from donor)
- **Gayle (MOS 391424):** IDE, PCMCIA, chip select logic (PLCC-52, from donor)
- **Budgie (MOS 391425):** PCMCIA buffer (SMD, from donor)
- **CIA × 2 (MOS 8520):** I/O controllers (PLCC-44, from donor)
- **Kickstart ROM:** 2× 27C400 or equivalent

### Video
- **Lisa digital video bus** exposed on internal header
- **HDMI output:** SiI9022A or ADV7513 HDMI transmitter fed from Lisa bus
- **VGA port** (15kHz / 31kHz via onboard scan doubler)
- **RGB Mini-DIN** (PS2/PS3 style) for direct RGB output
- Internal video slot header (A4000-style, all digital signals)

### Graphics Expansion
- **S3 Virge/VX chip** transplanted from CyberVision 64/3D donor card
- **4MB VRAM** (transplanted from CyberVision donor)
- CyberGraphX driver compatible
- Connected via direct bus rather than Zorro slot

### Audio
- **Paula** retains floppy/serial/interrupt duties
- Paula audio DMA signals tapped directly
- **PCM5102A stereo DAC** — clean 16-bit audio out, 3.5mm jack
- **Audio IN:** TLV320AIC or PCM1808 ADC, 3.5mm stereo input (AHI compatible)
- **MIDI IN/OUT:** 6N137 optocoupler + DIN-5 connectors, wired to Paula serial TX/RX

### Storage
- **IDE header × 2** — primary (HDD) and secondary (CDROM) — standard 40-pin
- **SD card slots × 2** — via IDE-to-SD bridge (e.g. IDESDA or SD-IDE adapter logic)
- Floppy pin header (standard 34-pin, supports original A1200 drive or PC DD drive)
- *(SATA not included — bus speed mismatch; CF/SD adapters preferred)*

### USB
- **USB host controller:** CH376S or MAX3421E
- **4× USB-A ports** — keyboard, mouse, drives (HID + mass storage)
- USB keyboard replaces original A1200 internal keyboard connector (MCU bridge)
- USB mouse replaces DB9 mouse port

### Networking
- **Ethernet:** ENC28J60 or W5500 SPI Ethernet, RJ45 on I/O shield

### Expansion
- **Trapdoor/clock port connector** — compatible with original A1200 accelerator cards
- **Clock port header** — for existing clock port peripherals
- *(PCI/PCIe not included — incompatible with 68020 bus architecture)*

### System Controllers (modern MCUs)
- **Keyboard MCU:** ATmega324PB — handles USB HID keyboard + original A1200 keyboard protocol
- **Power MCU:** ATtiny — soft power, reset, LED control, ATX PSU management
- **ROM MCU:** Flash ROM selection / Kickstart switching

### Form Factor & Power
- **Mini-ITX:** 170 × 170mm
- **ATX 24-pin** power connector
- Standard ATX case mounting holes
- I/O shield: HDMI, VGA, USB ×4, audio in/out, MIDI in/out, Ethernet, RGB Mini-DIN

---

## What You Need From a Donor A1200

All of the following are transplanted from your existing A1200:

- Alice (PLCC-84)
- Lisa (PLCC-84)
- Paula (PLCC-52)
- Gayle (PLCC-52)
- Budgie (SMD)
- CIA × 2 (PLCC-44)
- 68EC020 CPU (PLCC-68)
- Crystal oscillators (28.37516 MHz PAL / 28.63636 MHz NTSC)
- Kickstart ROM chips

All passives, connectors, and modern ICs are sourced new.

---

## What You Need From a Donor CyberVision 64/3D

- S3 Virge/VX chip (BGA or QFP depending on card revision)
- 4× 1MB VRAM chips

---

## Repository Structure

```
Morosa-1200/
├── hardware/
│   ├── mainboard/        # KiCad 8 project — main PCB
│   ├── video/            # Video output daughterboard (HDMI/VGA)
│   ├── audio/            # Audio I/O board (DAC/ADC/MIDI)
│   └── io/               # USB/Ethernet/SD controller board
├── docs/
│   ├── DESIGN_NOTES.md   # Architecture decisions and rationale
│   ├── TRANSPLANT.md     # Donor chip removal and transplant guide
│   ├── BOM_NOTES.md      # Sourcing notes for hard-to-find parts
│   └── REFERENCES.md     # Datasheets, schematics, community resources
├── research/             # Reference schematics, datasheets, notes
├── bom/                  # Bill of materials (CSV, interactive HTML)
└── README.md
```

---

## Status

🔴 **Pre-design / Research phase**

- [ ] Finalise feature set
- [ ] Gather all donor chip datasheets and pinouts
- [ ] KiCad schematic — core chipset
- [ ] KiCad schematic — video path
- [ ] KiCad schematic — audio path
- [ ] KiCad schematic — USB/IO
- [ ] PCB layout — Mini-ITX
- [ ] Design review
- [ ] Prototype fabrication
- [ ] Bring-up and testing

---

## Toolchain

- **KiCad 8** — schematic capture and PCB layout
- **JLCPCB / PCBWay** — fabrication (6-layer, controlled impedance)
- Garuda Linux / KDE Wayland development environment

---

## Licence

Hardware design files: **CERN Open Hardware Licence v2 - Strongly Reciprocal (CERN-OHL-S)**  
Documentation: **CC BY-SA 4.0**

---

## Community & References

- [Amiga Hardware Reference Manual](http://amigadev.elowar.com/)
- [AmigaWiki](https://www.amigawiki.org)
- [locator.reamiga.info](http://locator.reamiga.info)
- [English Amiga Board](https://eab.abime.net)
- [Retro Tinkering Discord](https://discord.gg/retrotinkering)

---

*"Morosa" — Northern Italian slang for girlfriend. Because some loves never die.*
