# X-Seti - June 2026 - Morosa-1200 - Tube Port Specification

"""
TUBE_PORT_SPEC.md - Open standard for the Morosa-1200 Tube Port.
CPU co-processor cards plug in here. Community expandable.
Based on BBC Micro Tube co-processor philosophy (1982).
"""

## Overview

The Tube Port is Morosa-1200's CPU co-processor expansion connector.
It is inspired directly by the BBC Micro Tube interface (1982) which
allowed any CPU to run alongside the 6502 host.

On Morosa-1200:
- 68030 is the host CPU (equivalent to BBC 6502)
- Tube Port cards are co-processor CPUs (equivalent to BBC ARM/Z80)
- FPGA on mainboard translates any card's bus to Amiga bus protocol
- Both CPUs run simultaneously
- Shared memory window (dual-port SRAM) for communication

The Tube Port is empty by default.
The 68030 runs AmigaOS without any card fitted.
Cards add capability, they do not replace the 68030.

---

## Physical Specification

```
Connector type:   Edge connector, 90 degree upright
                  Same physical style as PCI/PCIe slot
                  Internal to case, no backplate access

Pin count:        80-pin (40 per side, dual row)
Pitch:            2.54mm (0.1 inch) -- standard, easy to make cards
Card dimensions:  100mm x 60mm maximum (recommended)
                  Smaller cards also acceptable
Card thickness:   1.6mm standard PCB
Card edge:        Gold fingers, 80-pin
PCB layers:       2-layer minimum for cards
```

---

## Pin Assignment

```
Pin  Signal        Direction    Description
---  ------        ---------    -----------
Bus signals (68030 local bus subset):
 1   A0            Output       Address bit 0
 2   A1            Output       Address bit 1
 3   A2            Output       Address bit 2
 4   A3            Output       Address bit 3
 5   A4            Output       Address bit 4
 6   A5            Output       Address bit 5
 7   A6            Output       Address bit 6
 8   A7            Output       Address bit 7
 9   A8            Output       Address bit 8
10   A9            Output       Address bit 9
11   A10           Output       Address bit 10
12   A11           Output       Address bit 11
13   A12           Output       Address bit 12
14   A13           Output       Address bit 13
15   A14           Output       Address bit 14
16   A15           Output       Address bit 15
17   A16           Output       Address bit 16
18   A17           Output       Address bit 17
19   A18           Output       Address bit 18
20   A19           Output       Address bit 19
21   A20           Output       Address bit 20
22   A21           Output       Address bit 21
23   A22           Output       Address bit 22
24   A23           Output       Address bit 23

25   D0            Bidir        Data bit 0
26   D1            Bidir        Data bit 1
27   D2            Bidir        Data bit 2
28   D3            Bidir        Data bit 3
29   D4            Bidir        Data bit 4
30   D5            Bidir        Data bit 5
31   D6            Bidir        Data bit 6
32   D7            Bidir        Data bit 7

Bus control:
33   ~AS           Output       Address strobe
34   ~DS           Output       Data strobe
35   R/~W          Output       Read/Write
36   ~DTACK        Input        Data transfer acknowledge
37   ~RESET        Bidir        System reset
38   CLK           Output       System clock (7.14MHz PAL)
39   TUBE_CLK      Output       Independent Tube clock
40   ~INT2         Input        Card interrupts 68030 (level 2)

Card identification:
41   SPI_CLK       Output       SPI clock to card EEPROM
42   SPI_MOSI      Output       SPI data to card
43   SPI_MISO      Input        SPI data from card
44   SPI_~CS       Output       Card EEPROM chip select
45   CPU_ID0       Input        CPU type bit 0 (from EEPROM decode)
46   CPU_ID1       Input        CPU type bit 1
47   CPU_ID2       Input        CPU type bit 2
48   CPU_ID3       Input        CPU type bit 3

Shared memory window:
49   SRAM_A0       Bidir        Shared SRAM address 0
50   SRAM_A1       Bidir        Shared SRAM address 1
51   SRAM_A2       Bidir        Shared SRAM address 2
52   SRAM_A3       Bidir        Shared SRAM address 3
53   SRAM_A4       Bidir        Shared SRAM address 4
54   SRAM_A5       Bidir        Shared SRAM address 5
55   SRAM_A6       Bidir        Shared SRAM address 6
56   SRAM_A7       Bidir        Shared SRAM address 7
57   SRAM_D0       Bidir        Shared SRAM data 0
58   SRAM_D1       Bidir        Shared SRAM data 1
59   SRAM_D2       Bidir        Shared SRAM data 2
60   SRAM_D3       Bidir        Shared SRAM data 3
61   SRAM_D4       Bidir        Shared SRAM data 4
62   SRAM_D5       Bidir        Shared SRAM data 5
63   SRAM_D6       Bidir        Shared SRAM data 6
64   SRAM_D7       Bidir        Shared SRAM data 7
65   SRAM_~CE      Output       Shared SRAM chip enable
66   SRAM_~WE      Output       Shared SRAM write enable

Power:
67   +5V           Power        5V supply (max 500mA per card)
68   +5V           Power        5V supply (second pin)
69   +3.3V         Power        3.3V supply (max 500mA per card)
70   +3.3V         Power        3.3V supply (second pin)
71   GND           Ground
72   GND           Ground
73   GND           Ground
74   GND           Ground

Reserved for future use:
75   TUBE_RXD      Output       Serial comms to card
76   TUBE_TXD      Input        Serial comms from card
77   SPARE1        Reserved
78   SPARE2        Reserved
79   SPARE3        Reserved
80   SPARE4        Reserved
```

---

## Card ID EEPROM Format

Every Tube Port card carries a small SPI EEPROM (AT25010 or similar, 128 bytes).
The FPGA reads this at power-on to identify the card and load the correct
translation core.

```
Byte  Field           Description
----  -----           -----------
0     MAGIC_H         0x4D ('M')
1     MAGIC_L         0x31 ('1') -- "M1" = Morosa-1200 Tube card
2     CPU_TYPE        CPU identifier (see table below)
3     CPU_SPEED_MHZ   CPU clock speed in MHz
4     DATA_BUS_WIDTH  8, 16, or 32
5     ADDR_BUS_WIDTH  16, 24, or 32
6     LOCAL_RAM_KB    Local RAM on card in KB (0 if none)
7     FPU_PRESENT     0x00 = no FPU, 0x01 = FPU on card
8     VRAM_PRESENT    0x00 = no VRAM, 0x01 = VRAM on card
9     FPGA_CORE       Which FPGA translation core to load
10    VERSION_MAJOR   Card hardware version major
11    VERSION_MINOR   Card hardware version minor
12-15 RESERVED        Set to 0x00
16-127 NAME           Card name string, null terminated
       e.g. "Morosa Z80 CP/M Card v1.0"
```

### CPU Type Codes

```
0x00  Empty / no card
0x01  MC68030          Native Amiga bus (pass-through)
0x02  MC68060          Native Amiga bus (pass-through)
0x03  Z80              Zilog Z80 / Z80 CMOS
0x04  6502             MOS 6502 / WDC 65C02
0x05  65C816           WDC 65C816 (16-bit 6502)
0x06  8086             Intel 8086
0x07  80186            Intel 80186
0x08  ARM_M0           ARM Cortex-M0
0x09  ARM_M4           ARM Cortex-M4
0x0A  FPGA_ICE40       Lattice iCE40 soft CPU
0x0B  FPGA_ECP5        Lattice ECP5 soft CPU
0x0C  RISCV_RV32       RISC-V RV32I
0x0D  RISCV_RV64       RISC-V RV64I
0xFF  CUSTOM           Custom/experimental
```

---

## FPGA Translation Cores

The onboard FPGA loads a translation core based on the card EEPROM CPU_TYPE.

```
Core 0x01 -- 68030 pass-through
  Minimal translation
  68030 bus signals passed through
  Used when 68030 card or 68060 card fitted
  Effectively transparent

Core 0x03 -- Z80 bridge
  Z80 ~MREQ → ~AS + ~DS
  Z80 ~RD/~WR → R/~W
  Z80 ~WAIT ← wait state insertion
  Z80 ~INT ← converted Amiga interrupts
  8-bit data on D0-D7
  16-bit address mapped to Amiga space
  CP/M address map: 0x0000-0xFFFF

Core 0x04 -- 6502 bridge
  6502 PHI2 → bus cycle timing
  6502 R/~W → Amiga R/~W
  6502 ~NMI ← Amiga ~INT2
  6502 ~IRQ ← Amiga ~INT6
  8-bit data on D0-D7
  16-bit address mapped to Amiga space

Core 0x0A -- iCE40 soft CPU
  Flexible -- core defined by card FPGA
  Card FPGA implements any CPU ISA
  Communicates via standard bus signals
  Most flexible option
```

---

## Reference Cards

### Z80 Card
```
CPU:        Z80 CMOS (Z84C0020 or Z84C0033)
Speed:      20MHz or 33MHz
Data bus:   8-bit
Local RAM:  64KB SRAM (fast, no wait states)
Software:   CP/M 2.2, CP/M 3.0, BBC Z80 Tube ROMs
EEPROM:     CPU_TYPE = 0x03
Core:       Z80 bridge (core 0x03)
Size:       80x50mm 2-layer PCB
```

### 6502 Card
```
CPU:        WDC W65C02S (modern CMOS 6502)
Speed:      14MHz (BBC Micro compatible)
Data bus:   8-bit
Local RAM:  64KB SRAM
Software:   BBC BASIC, Apple II software
EEPROM:     CPU_TYPE = 0x04
Core:       6502 bridge (core 0x04)
Size:       80x50mm 2-layer PCB
```

### FPGA Soft CPU Card
```
FPGA:       Lattice iCE40UP5K (open toolchain)
Speed:      User defined
Data bus:   User defined (up to 32-bit)
Local RAM:  Up to 1MB SRAM
Software:   Any -- RISC-V, 68k soft core, custom ISA
EEPROM:     CPU_TYPE = 0x0A
Core:       iCE40 pass-through (core 0x0A)
Toolchain:  Yosys/nextpnr (Garuda Linux native)
Size:       100x60mm 4-layer PCB
```

---

## Design Rules for Card Makers

```
PCB:
  Max size:       100mm x 60mm
  Min thickness:  1.0mm
  Max thickness:  2.0mm
  Recommended:    1.6mm, 2-layer minimum
  Gold fingers:   ENIG or hard gold, 80-pin edge

Power budget:
  +5V:    Maximum 500mA total from Tube Port
  +3.3V:  Maximum 500mA total from Tube Port
  Cards needing more must have onboard regulation
  from a separate power header (documented in card spec)

Signal levels:
  68030 bus runs at 5V TTL levels
  Cards using 3.3V logic must include level shifters
  Do not connect 3.3V signals directly to bus lines

ESD protection:
  All bus-connected pins should have ESD protection
  TVS diodes or series resistors recommended

Decoupling:
  100nF ceramic per power pin minimum
  Bulk capacitance (10uF+) recommended per card

ID EEPROM:
  Required on every card
  AT25010A or compatible SPI EEPROM
  Pre-programmed before shipping/assembly
  MAGIC bytes must be 0x4D 0x31
```

---

## Tube Port vs Trapdoor

```
Tube Port:
  Purpose:    Co-processor CPU cards
  Cards:      Z80, 6502, FPGA soft CPU
  Relation:   Secondary to 68030 (both run together)
  Access:     Internal, no backplate
  Bus:        Subset of 68030 bus (8-bit data, 24-bit addr)
  Standard:   Morosa-1200 open standard

Trapdoor:
  Purpose:    Main CPU accelerators
  Cards:      TF1260, PiStorm32, ACA1233n
  Relation:   Replaces or accelerates 68030
  Access:     Internal, no backplate
  Bus:        Full 68030 bus (32-bit data, 32-bit addr)
  Standard:   A1200 compatible (existing)

They serve different purposes.
Tube Port card runs alongside 68030.
Trapdoor card replaces or accelerates 68030.
Both can be fitted simultaneously
(Tube Port card + Trapdoor accelerator).
```

---

## Open Standard Declaration

The Morosa-1200 Tube Port is an open standard.
Specification is released under CC BY-SA 4.0.
Anyone may design and manufacture Tube Port cards
without permission, fee, or restriction.

Community card designs should be submitted to:
  github.com/X-Seti/Morosa-1200/hardware/cards/

Reference designs (Z80, 6502, FPGA) provided
as KiCad projects under CERN-OHL-S v2.

---

## Acknowledgement

The Tube Port is inspired by and named after the
BBC Micro Tube interface, designed by Acorn Computers
in 1982. The original Tube allowed Z80, ARM2, 68000,
and other CPUs to run as co-processors alongside the
BBC Micro's 6502. We stand on the shoulders of giants.
