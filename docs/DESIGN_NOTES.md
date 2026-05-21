# Morosa-1200 Design Notes

## Architecture Decisions

### Why Real Chips?
The Morosa-1200 uses transplanted original AGA silicon rather than FPGA emulation.
The AGA chipset has nuances in timing, DMA behaviour, and analogue output that
FPGA cores still don't fully replicate. For a board built around a donor machine,
keeping the real chips is both practical and philosophically correct.

### Why Mini-ITX?
170×170mm fits in any modern case, supports standard ATX PSU, and is large enough
to accommodate the AGA chipset footprint plus modern I/O without heroic routing.
The Alicia 1200 project has already proven Mini-ITX is viable for AGA.

### Video Path
Lisa outputs a parallel digital RGB bus (8-bit per channel on AGA). This bus is
brought out to an internal header, feeding both:
- An onboard scan doubler (15kHz → 31kHz) for VGA output
- An HDMI transmitter IC (SiI9022A or ADV7513) for digital HDMI output
- An RGB Mini-DIN (PS2/PS3 style connector) for direct analogue RGB

The A4000-style internal video slot connector carries all digital signals, allowing
a future scan doubler / flicker fixer card if desired.

### Audio Path
Paula's audio DMA output signals are tapped before the original RC filter network.
A dedicated PCM5102A I2S DAC receives these signals for clean stereo output.
Paula retains all non-audio duties: floppy controller, serial port (MIDI), interrupts.

Audio input uses a PCM1808 or TLV320AIC ADC, feeding back into the system via
the AHI audio hardware interface standard.

MIDI uses Paula's built-in UART (31.25kbps) with a 6N137 optocoupler interface
and standard DIN-5 connectors onboard — no external MIDI interface needed.

### USB
The CH376S USB host controller handles HID (keyboard, mouse) and mass storage.
A separate ATmega324PB MCU bridges USB HID keyboard events to the A1200 keyboard
matrix protocol, allowing any USB keyboard to work transparently with AmigaOS.

### Storage
IDE is the native A1200 storage interface via Gayle. Two 40-pin IDE headers are
provided for HDD and CDROM. SD cards connect via IDE-to-SD bridge adapters.
SATA is not included — the 68020 bus cannot sustain SATA speeds and a bridge
chip would add significant complexity for marginal benefit.

### S3 Virge/VX Integration
The CyberVision 64/3D uses an S3 Virge/VX with 4MB VRAM. On the original card
this connects via Zorro II/III. On Morosa-1200 the chip connects directly to the
local bus, bypassing the Zorro bottleneck. CyberGraphX drivers support this chip
and will be used as-is.

This is the most complex part of the design. The Virge/VX has a 64-bit VRAM bus
and requires careful signal integrity work. This may be implemented as a
daughterboard rather than on the main PCB.

### Expansion
The trapdoor connector is retained in full for compatibility with existing
A1200 accelerator cards (Blizzard, Apollo, etc.).
The clock port header is retained for existing clock port peripherals.
PCI/PCIe expansion is architecturally incompatible with the 68020 bus and is
not included.

### Power
Standard ATX 24-pin connector. A small ATtiny MCU handles soft power (ATX
PS_ON signal), reset button, power LED, and HDD activity LED.
The original A1200 used a custom PSU — ATX is a direct improvement.

---

## Open Questions

- S3 Virge/VX as daughterboard vs onboard?
- SiI9022A vs ADV7513 for HDMI (availability/cost tradeoff)?
- ENC28J60 vs W5500 for Ethernet (W5500 has hardware TCP/IP stack)?
- Single IDE controller via Gayle or add a secondary ATA controller IC?
- PCMCIA slot — retain on mainboard or move to Tornado-style expansion header?

---

## Reference Designs Studied

- Amiga 1200+ (Vandezande) — bitbucket.org/jvandezande/amiga-1200
- Rämixx500 (SukkoPera) — github.com/SukkoPera/Raemixx500  
- Alicia 1200 (Enterlogic) — enterlogic.se
- AmigaPCI (jasonsbeer) — github.com/jasonsbeer/AmigaPCI
- Re-Amiga 1200 (Chucky Hertell) — wordpress.hertell.nu
