# X-Seti - June 2026 - Morosa-1200 - CPU, RAM and Expansion

"""
CPU_RAM.md - CPU choice, RAM configuration, expansion strategy.
Covers 68030 onboard, 68882 FPU, SIMM sockets, CM4 LPDDR4
extension, Tube Port, and trapdoor expansion.
"""

## Onboard CPU -- MC68030

### Decision: 68030 socketed on mainboard

| Property      | 68EC020 (stock) | 68020 (full) | 68030 (chosen) |
|---------------|-----------------|--------------|----------------|
| Address bus   | 24-bit (16MB)   | 32-bit (4GB) | 32-bit (4GB)   |
| MMU           | No              | No (ext)     | Yes (built-in) |
| FPU           | No              | No           | No (ext 68882) |
| I+D cache     | No              | I only       | Yes both       |
| Max clock     | 14MHz (stock)   | 33MHz        | 50MHz          |
| Package       | PLCC-68         | PLCC-68      | QFP-132        |

68030 is socketed -- not soldered -- for replaceability.
68020 (full) is acceptable fallback if 68030 hard to source.
Same QFP-132 socket, 32-bit address bus.

### Why Not 68040/060 Onboard?
68040/060 run hot, need heatsink/fan.
They come on trapdoor accelerators WITH their own RAM.
Putting 040/060 onboard conflicts with trapdoor slot.
The trapdoor IS the 040/060 upgrade path.
Tube Port cards are secondary CPUs, not CPU replacements.

### Onboard FPU -- 68882 at U0
A1200 always had unpopulated FPU footprint at U0.
Morosa-1200 populates it with PLCC-52 socket.
User fits 68882 chip when available (£5-15 eBay).
Disabled automatically when 040/060 trapdoor card present
(040/060 have integral FPU -- two FPUs conflict).
Independent clock crystal option for async FPU operation.

---

## RAM Architecture

### Chip RAM -- Alice hard silicon limit
Alice (AGA) addresses maximum 2MB Chip RAM.
This is a silicon constraint -- not CPU, not board.
```
1x 72-pin SIMM socket
2MB SIMM fitted as standard
No benefit to larger SIMM
Alice DMA reads this directly
68030 and AGA chipset share it
```

### Fast RAM -- onboard SIMMs
With 32-bit 68030 CPU the full Fast RAM space is accessible.
```
2x 72-pin SIMM sockets
Accepts 1MB, 4MB, or 8MB SIMMs per socket
Maximum onboard: 2x 8MB = 16MB Fast RAM
Must be: 32-bit wide (1Mx32 or 1Mx36)
         70-80ns access time
         Non-EDO
         Single-sided preferred
EDO RAM NOT supported by AGA memory controller
```

### Why Keep SIMMs?
Board must work without CM4 (out of the box principle).
Alice needs Chip RAM physically present on her bus.
68030 needs Fast RAM to boot AmigaOS.
72-pin SIMMs still available (eBay, retro suppliers, NOS).
CM4 LPDDR4 extends Fast RAM when CM4 is fitted -- additive.
Future: if SIMMs unavailable, FPGA bridges SDRAM chips instead.

### Extended Fast RAM -- CM4 LPDDR4 (when CM4 fitted)
```
CM4 module has 1-8GB LPDDR4 (depends on module)
FPGA carves a slice for 68030 use:
  512MB-1GB mapped as additional Fast RAM
  68030 local bus access via FPGA bridge
  Extends onboard SIMMs transparently
  AmigaOS sees it as standard Fast RAM
  No software changes needed

CM4 LPDDR4 allocation:
  Amiga Fast RAM slice: 512MB-1GB
  Linux system RAM: remainder
  GPU buffers: from Linux portion
```

### Trapdoor Fast RAM
```
Accelerator cards bring own RAM:
  TF1230/TF1260: up to 128MB
  ACA1233n: up to 128MB
  PiStorm32-Lite: up to 256MB (Pi's RAM)
Direct 68030 local bus on accelerator card
```

### Total RAM Summary
```
Chip RAM:        2MB (Alice, fixed forever)
Fast RAM SIMM:   16MB (onboard, always present)
Fast RAM CM4:    512MB-1GB (when CM4 fitted)
Fast RAM trap:   128-256MB (trapdoor accelerator)
CM4 system:      1-8GB LPDDR4 (Linux, CM4 owned)
GPU VRAM:        12GB GDDR6 (RX 5900 XT, CM4 owned)
Dual-port SRAM:  1-4MB (BBC Tube comms window)

Total 68030 accessible:
  2MB + 16MB + 1GB + 256MB = ~1.3GB realistic max
```

---

## Tube Port -- Co-processor CPU Cards

The Tube Port is Morosa-1200's secondary CPU expansion.
Inspired by BBC Micro Tube interface (1982).
68030 is the host. Cards are co-processors.
Both run simultaneously. Neither replaces the other.

```
Physical: small edge connector, internal, 80-pin
Default:  empty socket
Cards:    Z80, 6502, FPGA soft CPU, 8086 etc
FPGA:     detects card via SPI EEPROM
          loads appropriate translation core
          bridges card CPU bus to Amiga bus

Z80 card:   CP/M 2.2/3.0, BBC Z80 Tube ROMs
6502 card:  BBC BASIC, Apple II style
FPGA card:  any soft CPU (iCE40, open toolchain)
ARM card:   bare Cortex-M, real-time tasks
```

Full specification: docs/TUBE_PORT_SPEC.md

---

## Trapdoor Expansion Connector

Standard A1200 150-pin edge connector, 90 degree upright.
All 32 address lines routed (A24-A31 live, unlike original).
Full 32-bit bus -- all accelerators work correctly.

```
Compatible accelerators:
  TF1230  68030 @ 50MHz, 128MB Fast RAM
  TF1260  68060 @ 50MHz, 128MB Fast RAM
  ACA1233n 68030 @ 25-40MHz, 128MB
  Apollo 060 68060 @ 50MHz
  PiStorm32-Lite RPi, EMU68 68040, 256MB

PiStorm32-Lite note:
  Morosa-1200 has onboard CM4 already.
  PiStorm32 via trapdoor = second ARM alongside CM4.
  Confirm no bus conflict before use.
  Both provide different functions -- possible to coexist.
```

---

## CPU Upgrade Path Summary

```
Base (out of box):
  68030 @ 50MHz onboard (socketed)
  68882 FPU socket (empty, fit when ready)
  GD5446 RTG onboard
  16MB Fast RAM via SIMMs
  Works as enhanced A1200

Step 1 -- Add 68882:
  Fit chip into U0 socket
  Hardware FPU for LightWave, flight sims
  £5-15, plug in, done

Step 2 -- Add CM4:
  Fit CM4 module into 200-pin socket
  USB, GbE, HDMI 2, extended Fast RAM
  Modern I/O services come online

Step 3 -- Add Tube card:
  Fit Z80/6502/FPGA card into Tube Port
  Secondary CPU runs alongside 68030
  BBC Tube philosophy fulfilled

Step 4 -- Add trapdoor accelerator:
  TF1260 or PiStorm32 in trapdoor
  68060 @ 75MHz or ARM 2GHz
  Main CPU upgrades massively
  68882 on mainboard deactivated automatically
```
