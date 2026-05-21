# X-Seti - May 2026 - Morosa-1200 - CPU, RAM and Expansion

"""
CPU_RAM.md - CPU choice, RAM configuration, trapdoor expansion,
and ARM co-processor strategy for Morosa-1200.
"""

## Onboard CPU

### Decision: 68030 (full, not EC variant)

The stock A1200 68EC020 has a 24-bit address bus - 16MB maximum addressable
memory regardless of physical RAM. The full 68030 resolves this:

| Property       | 68EC020 (stock) | 68020 (full) | 68030 (chosen) |
|----------------|-----------------|--------------|----------------|
| Address bus    | 24-bit (16MB)   | 32-bit (4GB) | 32-bit (4GB)   |
| MMU            | No              | No (ext 68851)| Yes (built-in) |
| FPU            | No              | No           | No (ext 68882) |
| I+D cache      | No              | I only       | Yes both       |
| Max clock      | 14MHz (A1200)   | 33MHz        | 50MHz          |
| Package        | PLCC-68         | PLCC-68      | QFP-132        |

The 68020 (full) is an acceptable fallback if 68030 is hard to source.
Same PLCC-68 package, same 32-bit address bus, no built-in MMU.

### Onboard FPU - 68882 at U0
The A1200 always had an unpopulated FPU footprint at U0.
Morosa-1200 populates it with a 68882 PLCC-52 socket.
Independent clock crystal option for async FPU operation.
Disabled automatically when 040/060 trapdoor card is present.

---

## RAM

### Chip RAM - Alice hard limit
Alice (AGA) addresses a maximum of 2MB Chip RAM. Silicon constraint, not CPU.
- 1x 72-pin SIMM socket
- 2MB SIMM fitted as standard
- No benefit to larger SIMM

### Fast RAM - onboard
With 32-bit CPU the full Fast RAM address space is accessible.
- 2x 72-pin SIMM sockets
- Accepts 1MB, 4MB, or 8MB SIMMs per socket
- Maximum onboard: 2x 8MB = 16MB Fast RAM
- Must be: 32-bit wide (1Mx32 or 1Mx36), 70-80ns, non-EDO, single-sided
- EDO RAM NOT supported by AGA memory controller

### Extended RAM - trapdoor accelerator
Trapdoor cards provide their own Fast RAM on a separate local bus:
- TF1230 / TF1260: 128MB
- ACA1233n: 128MB
- PiStorm32-Lite (EMU68): up to 256MB from RPi physical RAM

Total possible: 2MB chip + 16MB onboard fast + 128-256MB accelerator

---

## ARM Co-processor - CM4 (BCM2711)

### Decision: BCM2711 wins

Evaluated: BCM2711, RK3588S, BCM2712, CIX CD8180

BCM2711 selected because:
- Direct CPU GPIO - no PCIe hop
- PiStorm32 proven at 32MB/s on this exact chip
- Matches 68030 bus throughput target
- Mature kernel, widest community
- CM4 module - socketed and swappable
- Developer owns RPi4B today for firmware work

### GPIO Bandwidth
68030 at 50MHz, 32-bit bus: 200MB/s theoretical, 20-40MB/s sustained real world.
BCM2711 direct GPIO: 25-32MB/s sustained. Target met.

Both BCM2711 and RK3588S hit the same GPIO ceiling (~50MHz toggle rate).
BCM2711 wins on proven firmware, not raw speed.

### CM4 Socket
Standard 200-pin CM4 high-density connector.
Accepts: CM4 (BCM2711) now, Radxa CM5 (RK3588S) when firmware matures.
No board respin needed to upgrade ARM module.

### Communication - Dual-port SRAM (BBC Tube model)
- IDT70V24 or CY7C136 dual-port SRAM, 1-4MB
- 68030 and CM4 both have direct access to shared window
- BBC Tube-style message passing - no shared OS needed
- CM4 can interrupt 68030 via _INT2 or _INT6
- AmigaOS sees CM4 as device via Autoconfig-style probe

### 40-pin GPIO Header
- RPi-compatible pinout
- Direct BCM2711 GPIO - low latency
- Standard RPi HATs compatible
- Amiga-accessible pins via level shifter (5V to 3.3V)
- Linux-owned pins for standard peripherals

---

## Trapdoor Expansion Connector

Standard A1200 150-pin edge connector (0.05-inch pitch, dual row).
Sources: retroready.one (UK), amigastore.eu (EU), Sordan (Ireland).

Morosa-1200 routes all 32 address lines to trapdoor connector.
Original A1200 left A24-A31 unconnected (EC020 limitation).
With 68030 onboard all 32 lines are live - full accelerator compatibility.

### Compatible Accelerators
- TF1230  - 68030 @ 50MHz, 128MB Fast RAM
- TF1260  - 68060 @ 50MHz, 128MB Fast RAM
- ACA1233n - 68030 @ 25-40MHz, 128MB Fast RAM
- Apollo 060 - 68060 @ 50MHz
- PiStorm32-Lite - RPi3A+/Pi4/CM4, EMU68 68040, 256MB

### PiStorm32-Lite on Trapdoor
The PiStorm32-Lite plugs into the standard trapdoor connector.
Uses BCM2711 (Pi4) running EMU68 to emulate a 68040 at 2000+ MIPS.
Open source hardware: github.com/PiStorm/pistorm32-lite-hardware
Note: Morosa-1200 already has onboard CM4, so PiStorm32 trapdoor use
would be secondary to the onboard ARM - confirm no bus conflict before use.

### Open Sockets on Trapdoor
- Full 32-bit 68030 address/data bus
- CM4 GPIO/SPI/I2C breakout header
- +5V, +3.3V, GND power pins
- 68030 clock and ARM peripheral clock
- Interrupt lines to both CPUs
- Unpopulated FPGA/CPLD footprint pads (iCE40 or XC9572XL)

---

## Summary

| Component      | Choice                          | Reason                         |
|----------------|---------------------------------|--------------------------------|
| Onboard CPU    | 68030 QFP-132 @ 50MHz           | 32-bit, MMU, cache, fast       |
| Onboard FPU    | 68882 PLCC-52 socket at U0      | Always designed in, now fitted |
| Chip RAM       | 1x 72-pin SIMM, 2MB             | Alice hard limit               |
| Fast RAM       | 2x 72-pin SIMM, max 16MB        | 32-bit CPU unlocks full space  |
| ARM co-proc    | CM4 socket, BCM2711             | Proven 32MB/s, PiStorm done    |
| Communication  | Dual-port SRAM                  | BBC Tube model, deterministic  |
| Trapdoor       | Full 32-bit, all A lines, open  | All accelerators, future proof |
