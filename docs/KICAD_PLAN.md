# X-Seti - May 2026 - Morosa-1200 - KiCad Schematic Plan

"""
KICAD_PLAN.md - Schematic sheet structure, symbol requirements,
netlist organisation, and build order for KiCad 8 work.
"""

## KiCad Project Structure

```
hardware/mainboard/
  Morosa-1200.kicad_pro      project file
  Morosa-1200.kicad_sch      root schematic (hierarchy top)
  sheets/
    01_power.kicad_sch       power rails and distribution
    02_cpu_68030.kicad_sch   68030 CPU + 68882 FPU
    03_chip_ram.kicad_sch    Chip RAM SIMM socket
    04_fast_ram.kicad_sch    Fast RAM SIMM sockets x2
    05_alice.kicad_sch       Alice AGA (MOS 8374)
    06_lisa.kicad_sch        Lisa AGA (MOS 4203)
    07_paula.kicad_sch       Paula (MOS 8364)
    08_gayle.kicad_sch       Gayle (MOS 391424)
    09_cias.kicad_sch        CIA x2 (MOS 8520)
    10_budgie.kicad_sch      Budgie (MOS 391425)
    11_kickstart.kicad_sch   Kickstart ROM sockets
    12_cm4_interface.kicad_sch  CM4 socket + dual-port SRAM
    13_video.kicad_sch       Lisa bus + ADV7513 HDMI
    14_audio.kicad_sch       PCM5102A + PCM1808 + MIDI
    15_storage.kicad_sch     IDE x2 + SD x2 + floppy
    16_usb_eth.kicad_sch     CM4 USB + Ethernet (via CM4)
    17_joystick.kicad_sch    DB9 x2 + CIA pot lines
    18_gpio_header.kicad_sch 40-pin RPi compatible header
    19_trapdoor.kicad_sch    A1200 trapdoor connector
    20_pci_bridge.kicad_sch  PLX PCI9052 + PCI slot (Rev 2)
    21_mcus.kicad_sch        ATmega324PB + ATtiny power MCU
    22_clocks.kicad_sch      Crystal oscillators + clock dist
  Morosa-1200.kicad_pcb      PCB layout file
  sym-lib-table              symbol library references
  fp-lib-table               footprint library references
  libs/
    morosa_custom.kicad_sym  custom symbols (Amiga chips etc)
    morosa_custom.pretty/    custom footprints
```

---

## Build Order

Work through sheets in this order.
Each sheet must be complete and reviewed before moving to next.
Power sheet must be done first -- everything depends on it.

### Phase 1 -- Power and CPU core (weeks 1-2)
```
01_power          Define all rails first
02_cpu_68030      68030 + 68882 -- the heart
03_chip_ram       SIMM socket + address decode
04_fast_ram       2x SIMM sockets
22_clocks         Crystal oscillators -- needed by all
```

### Phase 2 -- AGA chipset (weeks 3-4)
```
05_alice          DMA, blitter, copper
06_lisa           Video output bus
07_paula          Audio, floppy, serial
08_gayle          IDE, chip select
09_cias           CIA-A and CIA-B
10_budgie         PCMCIA buffer
11_kickstart      ROM sockets
```

### Phase 3 -- Modern I/O (weeks 5-6)
```
12_cm4_interface  CM4 socket + dual-port SRAM
13_video          ADV7513 HDMI from Lisa bus
14_audio          DAC, ADC, MIDI
15_storage        IDE, SD, floppy
21_mcus           Keyboard MCU, power MCU
```

### Phase 4 -- Expansion (weeks 7-8)
```
16_usb_eth        CM4 USB/Ethernet notes
17_joystick       DB9 ports + CIA pot lines
18_gpio_header    40-pin header
19_trapdoor       A1200 trapdoor connector
20_pci_bridge     PLX bridge (stub for Rev 2)
```

---

## Custom Symbols Required

These chips have no KiCad standard library symbol.
Must be created in morosa_custom.kicad_sym.

### AGA Chipset (highest priority)
```
MOS_8374_Alice    PLCC-84   84 pins
  Check Raemixx500 library first -- may already exist

MOS_4203_Lisa     PLCC-84   84 pins
  Check Raemixx500 / A1200+ library first

MOS_8364_Paula    PLCC-52   52 pins
  Check Raemixx500 library first

MOS_391424_Gayle  PLCC-52   52 pins
  Least documented -- use A1200 schematics as source

MOS_391425_Budgie SOJ-40    40 pins
  Very small chip, simple interface

MOS_8520_CIA      PLCC-44   44 pins
  Check Raemixx500 -- likely already exists
```

### Modern ICs (if not in KiCad standard library)
```
ADV7513           LFCSP-64  check standard lib first
PCM5102A          SSOP-20   likely in standard lib
PCM1808           SSOP-16   likely in standard lib
IDT70V24          various   check standard lib
CM4_Socket        200-pin   check RPi KiCad library
```

### Checking Existing Libraries
Before creating any custom symbol:
1. Check KiCad standard library (Edit > Symbol Libraries)
2. Check Raemixx500 project library
3. Check A1200+ project library
4. Check RPi official KiCad library (cm4/kicad-libraries)
5. Search KiCad community forum
6. Only create from scratch if not found anywhere

---

## Power Rails

All rails must be defined in 01_power.kicad_sch
Use PWR_FLAG on all rails to suppress ERC warnings.

```
+5V       -- main Amiga logic supply
            68030, AGA chips, CIAs, ROM
            From ATX +5V rail

+3.3V     -- CM4, ADV7513, modern ICs
            From ATX +3.3V or onboard LDO

+12V      -- Available for expansion
            From ATX +12V rail (passthrough)

-12V      -- Available if needed
            From ATX -12V rail

+1.8V     -- CM4 core (from CM4 module itself)
            CM4 generates internally

GND       -- Common ground plane
AGND      -- Analogue ground (audio section)
            Star point connection to GND

Amiga chip supply voltages:
  68030:    +5V (PLCC-68 -- check decoupling)
  Alice:    +5V (PLCC-84 -- runs warm, good decoupling)
  Lisa:     +5V (PLCC-84 -- runs warm)
  Paula:    +5V (PLCC-52)
  Gayle:    +5V (PLCC-52)
  CIA x2:   +5V (PLCC-44)
  Budgie:   +5V (SOJ-40)
  ROM x2:   +5V (DIP-40)
  68882:    +5V (PLCC-52)
```

### Decoupling Capacitors
Every IC needs decoupling caps.
Place as close as possible to power pins on PCB.
```
AGA chips (Alice, Lisa -- hot chips):
  100nF ceramic per power pin
  10uF electrolytic per chip

Other chips:
  100nF ceramic per power pin

CM4 socket:
  Follow CM4 datasheet recommendations exactly
  Multiple 100nF + bulk capacitance

68030:
  100nF per power pin
  Motorola application notes for guidance
```

---

## Critical Net Names

Use consistent net names throughout all sheets.
Hierarchical labels connect sheets together.

### CPU Bus (68030 local bus)
```
A[0..31]          32 address lines
D[0..31]          32 data lines
~AS               address strobe (active low)
~DS               data strobe (active low)
~DTACK            data transfer acknowledge
~DSACK0           data size acknowledge 0
~DSACK1           data size acknowledge 1
R~W               read/write
~RESET            system reset
~HALT             processor halt
CLK               system clock (7.14MHz PAL)
~IPL0             interrupt priority 0
~IPL1             interrupt priority 1
~IPL2             interrupt priority 2
~BERR             bus error
```

### Chip Bus (AGA internal)
```
RGA[0..8]         register address (9 bits)
RGD[0..15]        register data (16 bits)
~CCK              colour clock
CCKQ              colour clock quadrature
~CDAC             chip DMA acknowledge
~INT2             level 2 interrupt
~INT6             level 6 interrupt
```

### Lisa Video Bus
```
VID_R[0..7]       red channel 8-bit
VID_G[0..7]       green channel 8-bit
VID_B[0..7]       blue channel 8-bit
VID_HSYNC         horizontal sync
VID_VSYNC         vertical sync
VID_CSYNC         composite sync
VID_BLANK         blanking signal
VID_CLK           pixel clock
```

### CM4 Interface
```
CM4_SRAM_A[0..21] SRAM address (up to 4MB)
CM4_SRAM_D[0..15] SRAM data (16-bit)
CM4_SRAM_~CE0     chip enable (68030 side)
CM4_SRAM_~CE1     chip enable (CM4 side)
CM4_~INT          CM4 interrupt to 68030
CM4_GPIO[0..27]   CM4 GPIO lines
CM4_SCL           I2C clock (to ADV7513 etc)
CM4_SDA           I2C data
```

---

## ERC Rules

Enable all ERC checks.
Fix all errors before starting PCB layout.
Common issues with Amiga chips:
- Bidirectional pins on data bus -- set correctly
- Open collector outputs -- add pull-ups in schematic
- Power pins on AGA chips -- all must be connected
- Unused inputs -- tie to GND or VCC as appropriate

---

## Design Rules for PCB

Set before starting layout:
```
Minimum trace width:   0.15mm (signal)
                       0.3mm (power)
                       0.5mm (high current)
Minimum clearance:     0.15mm
Via drill:             0.3mm minimum
Via annular ring:      0.2mm minimum
Layer stackup:         6-layer
  L1: Top copper (signal)
  L2: Ground plane
  L3: Signal
  L4: Power plane (+5V / +3.3V split)
  L5: Signal
  L6: Bottom copper (signal)

Controlled impedance:
  50 ohm single-ended (CM4 signals)
  90 ohm differential (USB pairs from CM4)
  100 ohm differential (HDMI pairs to ADV7513)
```

---

## First Steps in KiCad

1. Install KiCad 8
   sudo pacman -S kicad kicad-library kicad-library-3d

2. Clone reference repos into research/reference_boards/
   (run fetch_datasheets.sh)

3. Open Raemixx500 project
   Study how AGA chip symbols are drawn
   Note pin grouping conventions used

4. Create new KiCad project
   hardware/mainboard/Morosa-1200.kicad_pro

5. Create morosa_custom.kicad_sym library
   Add to project sym-lib-table

6. Draw 01_power.kicad_sch first
   Define all rails
   Add PWR_FLAG to all nets

7. Draw 02_cpu_68030.kicad_sch
   68030 symbol -- check if exists in Raemixx500
   68882 symbol -- check libraries
   Connect to power and bus nets

8. Review with fresh eyes before continuing
