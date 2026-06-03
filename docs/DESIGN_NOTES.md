# X-Seti - June 2026 - Morosa-1200 - Design Notes

"""
DESIGN_NOTES.md - Architecture decisions and rationale.
Records why each design choice was made, alternatives considered,
and open questions. Updated as decisions are finalised.
"""

## Core Philosophy

Morosa-1200 is built on BBC Micro Tube co-processor philosophy.
The 68030 is the host CPU (BBC 6502 equivalent).
The CM4 and Tube Port cards are co-processors (BBC ARM/Z80 equivalent).
The AGA chipset is the soul -- preserved, authentic, real silicon.

Every design decision flows from three principles:
1. Works out of the box without CM4 or any expansion
2. Expands gracefully -- each addition improves without breaking
3. Community friendly -- open standard, forkable, documented

---

## Architecture Decisions

### Why Real Chips?
Transplanted original AGA silicon rather than FPGA emulation.
AGA has nuances in timing, DMA, and analogue output that FPGA
cores still do not fully replicate. For a board built around a
donor machine, keeping the real chips is philosophically correct.
The Amiga soul must be real.

### Why Mini-ITX?
170x170mm fits any modern case, supports ATX PSU, large enough
for AGA chipset plus modern I/O. Alicia 1200 proved Mini-ITX
is viable for AGA. Standard cases are cheap and available.

### Why BBC Tube Architecture?
The BBC Micro Tube (1982) proved that a co-processor can extend
a host computer without replacing it. 68030 runs AmigaOS natively.
CM4 handles all modern I/O services. Tube Port cards add secondary
CPUs. Each layer adds capability without breaking the layer below.
This is the correct architecture for Morosa-1200's goals.

### Out of the Box First
The board must work as a standalone enhanced A1200 without CM4.
CM4 is an enhancement, not a requirement. This means:
- 72-pin SIMMs for RAM (real Amiga hardware)
- GD5446 onboard for RTG (works without CM4)
- ADV7513 HDMI from Lisa (works without CM4)
- All AGA functions work without CM4

### Why 68030 Not 68EC020?
The 68EC020 (stock A1200) has only a 24-bit address bus -- 16MB max.
The full 68030 gives 32-bit address bus (4GB), built-in MMU,
instruction AND data cache, up to 50MHz. The 68020 (full, not EC)
is an acceptable fallback -- same PLCC-68, same 32-bit address bus,
but no built-in MMU.

### 68030 Socketed on Mainboard + Tube Port Empty
The 68030 is socketed directly on the mainboard -- it is the host CPU.
The Tube Port socket is empty by default.
Tube Port cards add co-processor CPUs alongside the 68030.
They do not replace it.
This matches the original BBC Micro model exactly.

### Why GD5446 for Onboard RTG?
PQFP package -- hand solderable, no BGA risk.
CGX and P96 driver support confirmed.
16MB VRAM with 8x 2MB VRAM chips:
  1920x1080x32bit = 7.91MB -- fits
  1920x1080x32bit + double buffer = 15.82MB -- fits
Honest 2D chip -- no pretend 3D.
Works completely without CM4.
Available as new old stock.

S3 Virge/VX (from donor CV64/3D) rejected for mainboard:
  BGA-288 package -- too risky for first board spin
  Moved to Phase 2 GPU daughter board
  RV350 replaces it on daughter board anyway

### Why CM4 (BCM2711) for ARM Co-processor?
Evaluated: BCM2711, RK3588S, BCM2712, CIX CD8180.
BCM2711 wins:
- Direct CPU GPIO -- no PCIe hop (unlike RPi5 RP1)
- PiStorm32 proven at 32MB/s on this exact chip
- Mature kernel, widest community, most drivers
- CM4 module format -- socketed, swappable
- Developer owns RPi4B for firmware development

RK3588S (OPi5c) -- second choice, same direct GPIO, faster,
but PiStorm-style firmware not yet ported.
CM4 socket accepts Radxa CM5 (RK3588S) when firmware matures.

### Why 72-pin SIMMs for Base RAM?
Base machine must work without CM4.
Alice needs Chip RAM physically present on her bus.
68030 needs Fast RAM to run AmigaOS.
72-pin SIMMs are still available (eBay, retro suppliers).
CM4 LPDDR4 extends Fast RAM when CM4 is fitted.
SIMMs remain as base -- CM4 is additive, not replacement.

### Why 16MB VRAM on GD5446?
1920x1080x32bit = 7.91MB
1920x1080x32bit + double buffer = 15.82MB
16MB gives comfortable 1080p 32-bit with double buffering.
8MB only covers 1080p 32-bit without double buffering.
16MB = 8x 2MB VRAM chips -- achievable, documented, working.

### Dual HDMI Outputs
HDMI 1: Lisa → ADV7513 → HDMI (AGA native, no CM4 needed)
HDMI 2: CM4 BCM2711 native HDMI (RTG, when CM4 fitted)
Both independent, both simultaneous.
HDMI 1 works without CM4 -- critical for out-of-box use.
ADV7513 I2C configured by CM4 when present, has sensible
defaults when CM4 absent (no I2C configuration needed for
basic AGA output).

### Why Drop Parallel Port?
PCM1808 ADC replaces parallel port sampling -- better in
every metric (24-bit vs 8-bit, hardware vs software, stereo
vs mono). All other parallel port use cases covered by CM4.

### Why Keep DB9 Joystick Ports?
CIA potentiometer inputs have no USB equivalent.
Megadrive/Genesis pads are pin compatible, still manufactured.
Connector is tiny -- negligible board space.
Authentic Amiga gaming experience preserved.

### Expansion Slot Layout
Row 1: PCI (68030 owned via PLX PCI9052) -- Radeon/Voodoo3
Row 2: Trapdoor (68030 bus, offset, no backplate) -- accelerators
Row 3: PCIe x8 (CM4 owned) -- GPU
Row 4: PCIe x4 (CM4 owned) -- expansion
Tube Port: (internal small connector) -- CPU co-processor cards

Two independent bus domains:
  68030 domain: Row 1 PCI
  CM4 domain: Row 3, Row 4, M.2 NVMe

### GPU Strategy
Phase 1: GD5446 onboard (CGX, 16MB, works alone)
Phase 2: RV350 daughter board (P96+Warp3D, above PS2)
Phase 3: RX 5900 XT via CM4 PCIe (PS3+, ray tracing)

CM4 as GPU controller:
  68030 issues draw commands via dual-port SRAM
  CM4 translates to Vulkan/OpenGL
  GPU renders, result returned to 68030
  68030 gets PS3-territory rendering without touching PCIe

---

## Decisions Still Open

### FPGA Size
Was: iCE40 (small, for Tube Port translation)
Now considering: ECP5 (larger, can also do DDR3 memory controller)
Decision: ECP5 preferred -- handles Tube Port + future DDR3 bridge
          if SIMMs become unavailable

### PCMCIA Retention
Dropped: replaced by SD slots
Confirmed: correct decision, no use case survives

### VGA Output
Optional: populated at build time
Scan doubler from Lisa signal
Not critical path -- HDMI 1 covers all cases

### ADV7513 vs SiI9022A
ADV7513 preferred: fractional PLL handles AGA non-standard clocks
SiI9022A fallback: simpler, cheaper, less capable
Decision: ADV7513 for best AGA compatibility

---

## Alternatives Rejected

PCI/PCIe on 68030 bus: architecturally incompatible
DIMM for Amiga RAM: Alice/Gayle require SIMM timing
SATA: bridge chip complexity not justified
EDO RAM: not supported by AGA controller
Onboard 68040/060: conflicts with trapdoor slot
BCM2712 RPi5: GPIO via PCIe hop, not cycle-accurate
CIX CD8180 OPi6: immature kernel, too risky
S3 Virge/VX onboard: BGA-288, moved to daughter board
8MB VRAM on GD5446: only covers 1080p without double buffer
No SIMMs: board must work without CM4, Alice needs real RAM
