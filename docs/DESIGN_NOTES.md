# X-Seti - May 2026 - Morosa-1200 - Design Notes

"""
DESIGN_NOTES.md - Architecture decisions and rationale for Morosa-1200.
Records why each design choice was made, open questions, and alternatives considered.
"""

## Architecture Decisions

### Why Real Chips?
The Morosa-1200 uses transplanted original AGA silicon rather than FPGA emulation.
The AGA chipset has nuances in timing, DMA behaviour, and analogue output that
FPGA cores still do not fully replicate. For a board built around a donor machine,
keeping the real chips is both practical and philosophically correct.

### Why Mini-ITX?
170x170mm fits in any modern case, supports standard ATX PSU, and is large enough
to accommodate the AGA chipset footprint plus modern I/O without heroic routing.
The Alicia 1200 project has already proven Mini-ITX is viable for AGA.

### Why 68030 Not 68EC020?
The 68EC020 (stock A1200 CPU) has only a 24-bit address bus - 16MB maximum
regardless of RAM installed. The full 68030 gives:
- 32-bit address bus (4GB addressable)
- Built-in MMU (no external 68851 needed)
- Instruction and data cache (vs 68020 instruction only)
- Up to 50MHz
- Pin-compatible upgrade path from 68020

The 68020 (full, not EC) is an acceptable fallback - same PLCC-68 package,
same 32-bit address bus, no built-in MMU but cheaper and easier to source.

### Why CM4 (BCM2711) for the ARM co-processor?
Decision made after evaluating: BCM2711 (RPi4/CM4), RK3588S (OPi5c/5Plus),
BCM2712 (RPi5), CIX CD8180 (OPi6 Plus).

BCM2711 wins because:
- Direct CPU GPIO - no PCIe hop (unlike RPi5 which goes via RP1)
- PiStorm32 already proven at 32MB/s on this exact chip
- Mature kernel, widest community, most drivers
- CM4 module format - socketed, swappable, upgradeable
- Developer owns RPi4B for firmware development today

RK3588S (OPi5c) was second choice - also direct GPIO, faster CPU, but
PiStorm-style firmware not yet ported. CM4 socket accepts future RK3588S
module (Radxa CM5) when firmware matures - no board respin needed.

RPi5 (BCM2712) rejected - GPIO goes via PCIe to RP1 south bridge.
Higher latency, not cycle-accurate for 68k bus interface.

OPi6 Plus (CIX CD8180) rejected - immature kernel, early-adopter drivers,
too risky alongside PCB bring-up.

### The BBC Tube Architecture
The co-processor communication model is borrowed from the BBC Micro Tube interface.
The Tube used a small FIFO register set between the 6502 host and co-processor.
Neither CPU shared the other's RAM - they passed messages.

On Morosa-1200:
- Dual-port SRAM replaces the Tube ULA FIFO
- 68030 and CM4 both have a window into the same physical SRAM
- AmigaOS sees the CM4 as an accelerator/device via Autoconfig probe
- CM4 can interrupt 68030 via _INT2 or _INT6
- CM4 handles all modern I/O - AmigaOS never touches USB/Ethernet/NVMe directly
- AmigaOS calls stub libraries that pass requests to CM4 transparently

Key insight from BBC Tube: the co-processor wins not because it is faster,
but because it has uncontended RAM. The 68030 loses cycles to AGA DMA.
The CM4 runs on its own DDR4 with zero bus contention.

### Video Path
Lisa outputs a parallel digital RGB bus (8-bit per channel on AGA).
This bus is exposed on an internal header feeding:
- Onboard scan doubler (15kHz to 31kHz) for VGA output
- HDMI transmitter IC (SiI9022A or ADV7513) for digital HDMI
- RGB Mini-DIN (PS2/PS3 style connector) for direct analogue RGB

### Audio Path
Paula audio DMA output signals tapped before the RC filter network.
PCM5102A I2S DAC receives these for clean stereo output.
Paula retains all non-audio duties: floppy, serial (MIDI), interrupts.
Audio input uses PCM1808 ADC, feeding back via AHI.
MIDI uses Paula built-in UART (31.25kbps) with 6N137 optocoupler and DIN-5 onboard.

### S3 Virge/VX Integration
CyberVision 64/3D donor provides S3 Virge/VX and 4MB VRAM.
Connected directly to local bus rather than via Zorro slot.
CyberGraphX drivers support this chip and are used as-is.
May be implemented as a daughterboard due to Virge/VX signal integrity requirements.

### Storage
IDE is the native A1200 interface via Gayle.
Two 40-pin IDE headers for HDD and CDROM.
SD cards via IDE-to-SD bridge adapters.
NVMe M.2 via CM4 PCIe lane (Linux side only).
SATA not included - bus speed mismatch, bridge chip complexity not justified.

### Power Sequencing
CM4 boots first from its own SD/eMMC.
Linux initialises all I/O, USB, networking.
CM4 then releases 68030 reset line - Amiga boots.
68030 comes up, Kickstart loads, detects ARM co-processor via shared SRAM probe.
ATtiny MCU handles ATX PS_ON, soft power, reset, LEDs.

---

## Open Questions

- S3 Virge/VX as daughterboard vs onboard?
- SiI9022A vs ADV7513 for HDMI (availability vs cost)?
- IDT70V24 vs CY7C136 for dual-port SRAM?
- PCMCIA retained on mainboard or moved to Tornado-style expansion header?
- iCE40 FPGA on GPIO header for arbitration - scope creep or necessary?
- 40-pin GPIO header split (Amiga-accessible pins vs Linux-only)?

---

## Alternatives Considered and Rejected

- PCI/PCIe on 68030 bus - architecturally incompatible, 68k bus too slow
- DIMM sockets for RAM - memory controller requires 72-pin SIMM bus width
- SATA - needs bridge chip, Amiga bus cannot sustain SATA speeds
- EDO RAM - not supported by AGA memory controller
- Onboard 68040/060 - conflicts with trapdoor accelerator slot
- BCM2712 (RPi5) - GPIO via PCIe hop, not cycle-accurate
- CIX CD8180 (OPi6) - immature kernel, too risky for hardware project
