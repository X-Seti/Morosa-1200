# CPU, RAM and Expansion Strategy

## Onboard CPU Choice

The stock A1200 68EC020 has a critical flaw for our purposes:

> The 68EC020 only has a 24-bit address bus, limiting it to 16MB total
> addressable memory regardless of what RAM is physically installed.

Morosa-1200 replaces it with a **full 68030 (QFP-132)** as the onboard default:

| Property | 68EC020 (stock) | 68020 (full) | 68030 (recommended) |
|---|---|---|---|
| Address bus | 24-bit (16MB) | 32-bit (4GB) | 32-bit (4GB) |
| Data bus | 32-bit | 32-bit | 32-bit |
| MMU | No | Yes (external 68851) | Yes (built-in) |
| FPU | No | No (needs 68881/882) | No (needs 68881/882) |
| Max clock | 14MHz (A1200) | 33MHz | 50MHz |
| Package | PLCC-68 | PLCC-68 | QFP-132 / PGA-128 |
| Cache | None | 256 byte I-cache | 256 byte I+D cache |

The 68030 is the right choice because:
- Built-in MMU (no external 68851 needed)
- Onboard instruction AND data cache (vs 68020 instruction only)
- Runs cooler than 68040 at equivalent speeds
- 50MHz versions available
- Priced about the same as 68020 when it launched -- still findable

The 68020 is also a valid choice if a 68030 is hard to source -- it is
pin-compatible in PLCC-68 and gives the full 32-bit address bus.

### Why Not Onboard 68040/060?

- 68040/060 are significantly hotter, need heatsink + fan
- They come on trapdoor accelerators which also provide RAM
- Putting 040/060 onboard and also having a trapdoor slot creates bus conflicts
- The trapdoor slot IS the 040/060 upgrade path -- keep it clean

### Onboard FPU Socket

The A1200 always had an unpopulated FPU footprint at U0. Morosa-1200 populates it:

- **68882 PLCC-52** socket at U0
- Independent clock crystal option (run FPU faster than CPU if desired)
- Disabled automatically when a 040/060 trapdoor card is present
  (040/060 have integral FPU -- two FPUs conflict)
- At 14MHz (stock clock) the FPU runs at 14MHz -- acceptable for base use

---

## RAM Configuration

### Chip RAM -- Alice hard limit

Alice (AGA) can address a maximum of **2MB Chip RAM**, period.
This is a silicon constraint of the 8374 chip, not the CPU or board.

- 1x 72-pin SIMM socket
- 2MB SIMM fitted as standard
- No benefit to larger SIMM here

### Fast RAM -- onboard

With a 32-bit CPU (68020/030/040/060) the full Fast RAM address space opens up.

- 2x 72-pin SIMM sockets
- Accepts 1MB, 4MB, or 8MB SIMMs
- Maximum onboard: **2x 8MB = 16MB Fast RAM**
- Must be: 32-bit wide (1Mx32 or 1Mx36), 70-80ns, non-EDO, single-sided
- EDO RAM NOT supported by the chipset memory controller

### Extended RAM -- via trapdoor accelerator

Trapdoor accelerator cards provide their own Fast RAM on a separate local bus:
- TF1230 / TF1260: up to 128MB
- ACA1233n: 128MB
- PiStorm32: up to 256MB via EMU68 (RPi physical RAM)

Total possible: 2MB chip + 16MB onboard fast + 128-256MB accelerator fast

---

## Trapdoor Expansion Connector

The A1200 trapdoor edge connector carries the full 68020 local bus:
- D0-D31 (32-bit data)
- A0-A31 (32-bit address, but EC020 only drives A0-A23)
- _AS, _DS, R/W, _DTACK, _DSACK0/1
- _INT2, _INT6, _RESET
- Clock (7.14MHz)
- +5V power rails

With a full 68030 onboard, ALL 32 address lines are now live on this connector.
This means any standard A1200 accelerator card works correctly, AND the full
address space is available to cards that use it.

### Compatible Accelerators (confirmed A1200 trapdoor)

| Card | CPU | RAM | Notes |
|---|---|---|---|
| TF1230 | 68030 @ 50MHz | 128MB | Popular, affordable |
| TF1260 | 68060 @ 50MHz | 128MB | Best 68k performance |
| ACA1233n | 68030 @ 25-40MHz | 128MB | Individual Computers |
| Apollo 060 | 68060 @ 50MHz | varies | Well supported |
| PiStorm32-Lite | RPi (EMU68) | 256MB | See below |

### PiStorm32-Lite

The PiStorm32-Lite is a particularly interesting option for Morosa-1200:

- Plugs into the standard A1200 trapdoor connector
- Uses a Raspberry Pi (3A+, Pi4, or CM4) running EMU68 to emulate a 68040
- Pi4 achieves 2000+ MIPS -- faster than any real 68k chip
- CM4 version has been pushed to ~3GHz in testing
- Provides: emulated 68040, up to 256MB Fast RAM from Pi physical RAM
- Open source hardware: github.com/PiStorm/pistorm32-lite-hardware
- CM4 expansion board adds: HDMI, Ethernet, USB from the Pi itself

One consideration for Morosa-1200: since we already have onboard HDMI,
USB and Ethernet, the PiStorm32 CM4 expansion board's I/O would be
redundant -- but the CM4 module itself as the accelerator is excellent.

Important note from PiStorm32 hardware repo:
> Isolate the Pi GPIO and Ethernet pins from the A1200 keyboard metal --
> tape required or the Pi will be fried.
On Morosa-1200 this is not an issue since the keyboard is external.

### Trapdoor Connector on Morosa-1200

The connector is a standard A1200 150-pin edge connector (0.05" pitch, dual row).
Sources: retroready.one (UK), amigastore.eu (EU), Sordan (Ireland/EU).

The Morosa-1200 PCB routes all 32 address lines to the trapdoor connector
(unlike the original A1200 which left A24-A31 unconnected due to EC020).
This ensures full compatibility with all accelerators including those that
probe the full 32-bit address space.

---

## Summary

| Component | Choice | Reason |
|---|---|---|
| Onboard CPU | 68030 @ up to 50MHz | 32-bit, built-in MMU, cool running |
| Onboard FPU | 68882 PLCC socket (U0) | Always designed in, never fitted |
| Chip RAM | 1x 72-pin SIMM, 2MB | Alice hard limit |
| Fast RAM | 2x 72-pin SIMM, max 16MB | 32-bit CPU unlocks full space |
| Trapdoor | Full 32-bit bus, all A lines | Correct for 68030, all accs work |
| Best acc option | PiStorm32-Lite CM4 | EMU68 68040, 256MB, open source |
