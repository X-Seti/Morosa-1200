# X-Seti - May 2026 - Morosa-1200 - I/O Specification

"""
IO_SPEC.md - All connectors, ports, I/O shield layout and
rationale for what was kept, dropped, and replaced.
"""

## Design Philosophy

Every port on Morosa-1200 must justify its board space.
Legacy ports are replaced by better modern equivalents where possible.
Authenticity is preserved where it matters -- DB9 joystick ports stay.
Complexity is removed where it does not matter -- parallel port gone.

---

## Ports Dropped vs Original A1200

### 23-Pin Amiga Video Port -- DROPPED
Original purpose: analogue RGB, genlock, composite sync, audio out.
Replaced by: HDMI 1 (ADV7513 from Lisa digital bus) -- better quality,
universal compatibility, no modern monitor needs 23-pin RGB.
Genlock sync signals exposed on internal pin header for niche use.

### DB25 Parallel Port -- DROPPED
Original purpose: printer, sampling hardware, MIDI, dongles, ZIP drives,
ParNET networking, scanners.
Every use case replaced:
- Printing: USB via CM4
- Sampling: PCM1808 ADC onboard (24-bit/96kHz vs 8-bit/56kHz parallel)
- MIDI: DIN-5 onboard, wired to Paula serial
- Dongles: WHDLoad, abandonware
- Storage: SD cards
- Networking: Gigabit Ethernet via CM4
The PCM1808 is strictly better than parallel port sampling in every metric.

### DB25 Serial Port -- DROPPED (as full port)
Original purpose: RS-232, MIDI, modems, serial terminals.
Replaced by: MIDI DIN-5 onboard, USB-serial via CM4, Ethernet.
Paula serial TX/RX exposed on internal 4-pin header for custom use.
Full DB25 footprint not justified.

### PCMCIA Slot -- DROPPED
Original purpose: network cards, CF storage adapters, RAM expansion.
Replaced by: 2x SD card slots -- same use cases, cheaper media,
higher capacity, universally available, smaller footprint.

---

## Ports Kept

### DB9 Joystick/Mouse x2 -- KEPT
Reasons:
- Tiny connector, negligible board space
- Authentic Amiga joystick/mouse experience
- CIA potentiometer pins (POT X/Y) have no USB equivalent
- Supports: original Amiga mice, Competition Pro, Zipstick,
  Megadrive/Genesis 6-button pad (pin compatible, best 2D pad),
  Master System pad, Atari 2600/C64 joysticks, paddles, spinners
- Analogue inputs (pot pins) needed for flight sims, Arkanoid paddles
- Megadrive pads still manufactured new (Retro-Bit) at £10-15

Wiring:
  DB9 port 1 -- CIA-A joy/pot lines + ATmega324PB for USB HID bridge
  DB9 port 2 -- CIA-B joy/pot lines + ATmega324PB for USB HID bridge
  ATmega324PB translates USB mouse to Amiga quadrature protocol
  AmigaOS sees standard Amiga mouse regardless of input device

---

## New Ports (not on original A1200)

### HDMI 1 -- AGA Native
Source: Lisa digital RGB bus (24-bit parallel) direct PCB trace
Chip: ADV7513 HDMI transmitter
Output: Native PAL 50Hz or NTSC 59.94Hz pixel-perfect
Handles: All AGA screen modes, HAM8, Productivity, SuperHires
No frame rate conversion, no judder, exact Lisa pixel clock
I2C config owned by CM4 (EDID negotiation, mode setting)
AmigaOS drives Lisa as normal -- ADV7513 is transparent

### HDMI 2 -- RTG / CM4
Source: BCM2711 native HDMI output via CM4 module
Output: Any RTG resolution -- 1080p, 1440p, 4K
Used for: CGX/P96 screen modes, composited Workbench,
video playback, 3D rendering, all CM4 Linux output
Completely independent of HDMI 1 -- both run simultaneously

### USB x4
Via CM4 BCM2711 USB controller
HID: keyboard and mouse (bridged to AmigaOS via ATmega324PB)
Mass storage: transparent via stub driver to AmigaOS
All 4 ports on I/O shield

### Gigabit Ethernet
Via CM4 BCM2711 native GbE
RJ45 on I/O shield
Linux TCP/IP stack on CM4
AmigaOS accesses via SRAM stub (bsdsocket.library compatible)

### Audio Out 3.5mm Stereo
PCM5102A I2S DAC
Fed from Paula audio DMA signals tapped before RC filter
Clean 16-bit stereo output
Line level

### Audio In 3.5mm Stereo
PCM1808 ADC
24-bit, up to 96kHz
Stereo line level input
For sampling, recording, AHI compatible
Replaces parallel port sampling hardware entirely
Superior in every metric (24-bit vs 8-bit, hardware vs software)

### MIDI In -- DIN-5
6N137 optocoupler
Wired to Paula serial RX (31.25kbps)
Standard 5-pin DIN connector

### MIDI Out -- DIN-5
Wired to Paula serial TX (31.25kbps)
Standard 5-pin DIN connector
No external MIDI interface needed

### SD Card x2
SD Slot 1 -- AmigaOS side
  Connected via IDE-to-SD bridge logic
  Gayle IDE controller
  AmigaOS sees as standard IDE drive
  HDToolBox partitioning
  Workbench/games/software installation target
  FAT32 readable by both AmigaOS and Linux

SD Slot 2 -- CM4 side
  BCM2711 native SD/MMC controller
  CM4 boot and Linux system
  Independent of AmigaOS card
  Swap CM4 Linux versions without touching AmigaOS
  Both slots accessible on I/O shield without opening case

### VGA -- Optional
Output from onboard scan doubler fed from Lisa
15kHz to 31kHz conversion
For users with VGA monitors
Populated or not at build time

---

## I/O Shield Layout

```
Top row:
  [HDMI 1 - AGA]  [HDMI 2 - RTG]  [GbE RJ45]

Middle row:
  [USB-A] [USB-A] [USB-A] [USB-A]

Lower middle row:
  [Audio In 3.5mm] [Audio Out 3.5mm] [MIDI In DIN-5] [MIDI Out DIN-5]

Bottom row:
  [SD1 - AmigaOS]  [SD2 - CM4]  [DB9 Joy1]  [DB9 Joy2]

Optional (populated at build time):
  [VGA]
```

---

## Internal Headers (not on I/O shield)

```
J1  -- Paula serial UART (4-pin, TX/RX/5V/GND)
J2  -- Genlock sync (HSYNC, VSYNC, CSYNC, GND)
J3  -- Floppy (34-pin standard)
J4  -- IDE primary (40-pin)
J5  -- IDE secondary (40-pin)
J6  -- ATX power (24-pin)
J7  -- Front panel (power, reset, LEDs)
J8  -- GPIO 40-pin (RPi compatible, CM4 direct)
J9  -- Trapdoor expansion connector (150-pin edge)
J10 -- CM4 module (200-pin high density)
J11 -- GPU daughter board (MXM-style, Rev 2)
J12 -- Clock port (22-pin, A1200 compatible)
```

---

## GPU Strategy

### Phase 1 (Rev 1 board)
CM4 VideoCore VI handles all RTG via HDMI 2.
No discrete GPU required.
MXM-style GPU daughter board connector routed but unpopulated.

### Phase 2 (Rev 2 / daughter board)
RV350 (from donor AIW Radeon 9600 Pro/XT) on daughter board.
ATI Theater 200 alongside RV350 for PAL/NTSC capture.
BGA reflow required -- done as separate small PCB to protect main board.
Connects via MXM-style socket on main board.
Adds: native Warp3D, P96 RTG, PAL/NTSC video capture/output.

Performance context:
  Virge/VX:    Below PS1 -- rejected
  Voodoo3 PCI: PS1-PS2 gap -- hard to source, rising prices
  RV350:       Above PS2, Xbox OG territory -- already owned
  CM4 VC VI:   Approaching PS2 -- Phase 1 default

### Theater 200 Capture (Phase 2)
ATI Theater 200 on GPU daughter board.
PAL 625/50Hz and NTSC 525/59.94Hz hardware capture.
S-Video and composite input.
Hardware YUV decode, adaptive comb filter.
V4L2 driver exists for Linux (CM4 owns via I2C).
Use cases:
- PAL VHS archiving
- AGA demo/game capture (record Lisa output)
- NTSC source compatibility
- Real-time encode to H.264 via CM4

---

## Decisions Log

| Port | Decision | Reason |
|---|---|---|
| 23-pin video | Dropped | HDMI 1 replaces entirely |
| DB25 parallel | Dropped | Every use case covered better |
| DB25 serial | Dropped | Paula header + MIDI DIN-5 |
| PCMCIA | Dropped | 2x SD slots replace |
| DB9 x2 | Kept | CIA pots, authentic, tiny |
| HDMI x2 | Added | AGA native + RTG simultaneously |
| USB x4 | Added | Via CM4 |
| GbE | Added | Via CM4 |
| Audio in | Added | PCM1808, replaces parallel sampling |
| Audio out | Added | PCM5102A, clean DAC |
| MIDI in/out | Added | DIN-5 onboard, no external box |
| SD x2 | Added | AmigaOS + CM4 independent |
| VGA | Optional | Scan doubler output |

---

## Expansion Slot System (updated)

### Row 1 -- PCI Standard (32-bit 33MHz)
Via PLX PCI9052 bridge onboard.
68030 local bus owns this slot directly.
Standard PCI bracket -- backplate access.
Target cards: Radeon 7000 PCI, Voodoo3 PCI.
Native Warp3D and CGX/P96 to 68030.
Any standard PCI card compatible.

### Row 2 -- A1200 Trapdoor (offset, internal)
150-pin edge connector, 90 degree upright (like PCIe slot).
Offset inward -- no backplate cutout needed.
68030 local bus, full 32-bit, all address lines live.
Target cards: TF1260, ACA1233n, PiStorm32-Lite.
All standard A1200 accelerators compatible.
PiStorm32 works internally -- CM4 provides USB/Ethernet anyway.

### Row 3 -- PCIe x8 (CM4 owned)
Via PLX PEX8606 switch from CM4 PCIe lane.
Standard PCIe bracket -- backplate access.
Target: GPU (RX 5900 XT, R9 285 etc).
Full height, full length card supported.

### Row 4 -- PCIe x4 (CM4 owned)
Via PLX PEX8606 switch from CM4 PCIe lane.
Standard PCIe bracket -- backplate access.
Target: NVMe adapter, 10GbE, sound card, USB3 expansion.
Half height or full height card.

### PCIe Switch
PLX PEX8606 or PEX8608.
One upstream port from CM4 PCIe Gen2 x1.
Multiple downstream ports to Row 3, Row 4, M.2 NVMe.
Linux driver built into kernel -- zero configuration.

### Backplate View (slot area)
```
[PCI bracket    -- Row 1, Radeon/Voodoo]
[blank plate    -- Row 2, trapdoor internal]
[PCIe x8 bracket -- Row 3, GPU]
[PCIe x4 bracket -- Row 4, expansion]
```

### Bus Domain Separation
68030 domain: Row 1 PCI (via PLX PCI9052)
CM4 domain:   Row 3 PCIe x8, Row 4 PCIe x4, M.2 NVMe
No conflict -- completely independent buses.
