# X-Seti - May 2026 - Morosa-1200 - GPU Strategy

"""
GPU_STRATEGY.md - GPU selection rationale, performance context,
daughter board approach, and PAL/NTSC video capture via Theater 200.
"""

## Performance Context

```
Console reference points:
  PS1  (1994):  ~180K textured polys/sec   33 Mpixels/sec
  PS2  (2000):  ~20M real polys/sec        2.4 Gpixels/sec
  Xbox OG(2001):~100M polys/sec            4.0 Gpixels/sec
  PS3  (2006):  ~300M polys/sec            ~100 Gpixels/sec
```

## Chips Evaluated

| Chip | 3D Polys/sec | Fill Rate | Console | Amiga Driver | Decision |
|---|---|---|---|---|---|
| Cirrus GD5446 | None (2D only) | 2D only | N/A | CGX yes | Rejected -- no 3D |
| Virge/VX | ~150K | 52 Mpixels | Below PS1 | CGX yes | Rejected -- below PS1 |
| Virge/DX | ~220K | 60 Mpixels | ~PS1 | CGX yes | Rejected -- just PS1 |
| Permedia 2 | ~1M | varies | ~PS1 | CGX+Warp3D | Considered |
| Voodoo3 PCI | ~7M | 350 Mpixels | PS1-PS2 gap | CGX+Warp3D | Hard to find |
| RV350 (AIW 9600) | ~30-40M | 3.2 Gpixels | Above PS2 | P96+Warp3D | Chosen |
| CM4 VideoCore VI | ~20M | 1.4 Gpixels | ~PS2 | Stub driver | Phase 1 default |

Target: between PS1 and leaning toward PS2, with existing Amiga driver support.
Result: RV350 exceeds target -- above PS2, near original Xbox territory.

## Why Voodoo3 Was Considered But Dropped

Voodoo3 PCI is the classic Amiga community 3D card.
CGX, P96 and Warp3D drivers proven and mature.
Performance between PS1 and PS2 -- meets target.
Problem: PCI versions rare, £30-80 and rising.
Retro collector market driving prices up every year.
The RV350 from an already-owned donor card is free and better.

## Chosen GPU: RV350 (ATI Radeon 9600 Pro/XT)

Source: Donor ATI All-In-Wonder 9600 Pro/XT card (already owned).
Chip: RV350 -- R300 derivative, 130nm process.
Interface on donor: AGP 8x (cannot use directly on Amiga bus).
Solution: Transplant RV350 BGA + DDR memory to daughter board.

Performance:
- ~30-40M triangles/sec
- ~3.2 Gpixels/sec fill rate
- Above PS2 (2.4 Gpixels), approaching Xbox OG (4.0 Gpixels)
- DirectX 9.0 / Shader Model 2.0
- OpenGL 2.0

Amiga driver support:
- Picasso96: Yes (R300 family confirmed)
- Warp3D: Yes (R300 family confirmed)
- CGX: Yes

## BGA Reflow Reality

RV350 package: BGA-256 or BGA-332
DDR memory: TSOP-II (easier) or BGA

Requirements:
- BGA rework station (IR preferred)
- Reflow profile for RV350
- PCB preheater (prevent warping)
- No-clean flux
- Patience -- done on a good day only

Success rate with proper equipment: 80-90%
Doing this on a separate daughter board protects the main PCB investment.
If the BGA work fails, only the cheap small daughter board is lost.

## Daughter Board Architecture

Rather than placing RV350 directly on the main mITX PCB:

```
GPU Daughter Board (~60x80mm, 8-layer):
  RV350 BGA + DDR memory
  Theater 200 + supporting passives
  Power regulation for GPU/memory voltages
  Connects to main board via MXM-style socket

Main Board:
  MXM-style socket routed (Rev 1 unpopulated)
  GPU bus signals pre-routed in Rev 1
  Populate socket in Rev 2
  If daughter board fails -- swap it, main board safe
  If better GPU available later -- new daughter board
```

PCB stackup for daughter board: 8-layer minimum
Main board stays at 6-layer

## ATI Theater 200 -- PAL/NTSC Capture

Mounted alongside RV350 on GPU daughter board.

Specifications:
- PAL: 625 lines, 50Hz (UK/Europe/Australia)
- NTSC: 525 lines, 59.94Hz (North America/Japan)
- SECAM: 625 lines, 50Hz (France)
- S-Video input: both standards
- Composite input: both standards
- Hardware YUV decode
- Adaptive 3D comb filter
- Auto-detects input standard (no manual switching)
- I2C configuration

Linux driver: V4L2 (mature, existing, no new driver work needed)
CM4 owns Theater 200 via I2C
AmigaOS accesses via CM4 SRAM stub

### Use Cases

PAL VHS archiving:
  Connect VHS player via S-Video or composite
  Theater 200 hardware-decodes PAL stream
  CM4 receives frames via V4L2
  CM4 encodes to H.264/H.265 hardware
  Stored to NVMe -- archive quality

AGA self-capture:
  AGA demo running on 68030
  Lisa RGB also routed to Theater 200 input
  Theater 200 captures AGA PAL output
  CM4 encodes to H.264 in real time
  Record AGA demos on the machine running them
  No external capture card needed

NTSC compatibility:
  North American Amiga software in NTSC
  Canadian source material (VHS, camcorder)
  Plug in -- Theater 200 autodetects

## Two-Phase GPU Plan

### Phase 1 (Rev 1 board, no daughter board)
CM4 VideoCore VI handles all RTG via HDMI 2.
~PS2 performance, OpenGL ES 3.1.
MXM socket routed on main board but unpopulated.
Prove the architecture works first.

### Phase 2 (daughter board)
RV350 daughter board populated.
Theater 200 alongside for PAL/NTSC capture.
Native Warp3D on R300 hardware.
Above PS2 performance native to AmigaOS.
PAL/NTSC video capture operational.

## Cards to Check in Hardware Inventory

When going through old cards:

Priority 1 -- AIW 9600 Pro/XT (known donor)
  Purple input dongle confirms this card
  RV350 + Theater 200 -- both needed

Priority 2 -- Any Radeon PCI card
  9200 PCI, 9250 PCI, 9600 PCI
  Can connect directly to PCI bus
  No BGA transplant needed
  Cheaper, lower risk option

Priority 3 -- 8800GT x2 (known)
  PCIe, too modern for native Amiga drivers
  But CM4 PCIe could own them
  Nouveau Linux driver
  PS3-territory rendering on CM4 side
  Interesting for Phase 3 thinking

Priority 4 -- Any Voodoo3 PCI
  If found: keep it
  Proven Amiga Warp3D, rare, valuable
  Even if not used in Morosa-1200 immediately

Priority 5 -- Other Radeon AGP cards x4
  Note chip model and memory
  R200/R300 family preferred
  May have Theater chips on some

---

## The CM4 as GPU Controller -- Key Architecture

The 68030 cannot directly drive modern GPUs -- the bus bandwidth
mismatch is insurmountable (68030 ~40MB/s vs PCIe x16 ~16GB/s).

The CM4 solves this completely as an intelligent co-processor/controller:

```
68030 (AmigaOS brain)
    |
    | issues draw commands via dual-port SRAM
    |
CM4 BCM2711 (intelligent controller)
    |
    | translates commands to Vulkan/OpenGL
    | owns PCIe bus entirely
    |
PCIe switch (PLX PEX8608 or similar)
    |
    +-- GPU slot (HD 7770, RX 580, anything modern)
    +-- NVMe M.2 slot
    +-- Additional PCIe slots/devices
```

The 68030 never touches the modern GPU directly.
It issues requests, CM4 executes them, results returned via SRAM.
AmigaOS stub libraries make this transparent to all software.

### Effective GPU Performance for AmigaOS

| Path | GPU | Performance | How |
|---|---|---|---|
| Native PCI (68030 direct) | Radeon 7000 PCI | PS1-PS2 gap | PLX bridge on board |
| Via CM4 controller | HD 7770 GCN | PS3/360 territory | CM4 PCIe + Vulkan |
| Via CM4 controller | RX 580 | Well beyond PS4 | Swap card, same stubs |
| Via CM4 controller | Any future GPU | Keeps improving | CM4 loads new driver |

### Why PCIe via CM4 Opens Everything Up

CM4 PCIe lane connects to a PCIe switch giving:
- GPU slot -- any modern GPU, swappable, user upgradeable
- NVMe M.2 -- fast storage, CM4 owned
- Capture card -- PCIe video capture
- Sound card -- studio quality audio
- 10GbE -- if GbE not enough
- WiFi M.2 Key-E
- FPGA card -- custom hardware acceleration
- Anything with a PCIe interface

All owned by CM4 Linux.
All accessible to AmigaOS via SRAM stub libraries.
68030 sees the same clean AmigaOS interface regardless of what is plugged in.

When user upgrades GPU:
- Swap PCIe card
- CM4 loads new AMDGPU/Nouveau driver
- AmigaOS stub library unchanged
- 68030 gets better results silently
- No board respin, no new Amiga drivers needed

### The BBC Tube Parallel

```
BBC Micro 1982:          Morosa-1200 2026:
  6502 (brain)             68030 (brain)
    |                        |
  Tube ULA (controller)    Dual-port SRAM (controller)
    |                        |
  ARM2 (muscle)            CM4 + PCIe GPU (muscle)

6502 ran BBC BASIC        68030 runs AmigaOS
ARM2 did computation      CM4+GPU does rendering
6502 got results back     68030 gets results back
44 years apart, same architecture.
```

### The Platform vs Fixed-Spec Design

Fixed forever (the soul):
  68030 + AGA + real donor chips
  Authentic Amiga core, never changes

Infinitely expandable (the body):
  Everything behind CM4 PCIe
  Follows PC hardware ecosystem
  Benefits from all future PC hardware development
  User upgrades GPU like upgrading a PC graphics card

The Amiga core is frozen in amber -- perfect and authentic.
The CM4 + PCIe is alive -- modern, growing, endless possibilities.
