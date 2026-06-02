# X-Seti - May 2026 - Morosa-1200 - CM4 Offload Architecture

"""
CM4_OFFLOAD.md - BBC Tube co-processor model, dual-port SRAM
communication, video decode offload, RTG offload, and
AmigaOS integration via stub libraries.
"""

## The BBC Tube Model

The Morosa-1200 co-processor architecture is directly inspired by the
BBC Micro Tube interface (1982). The Tube connected the 6502 host to
a co-processor (Z80, ARM2, 68000) via a small FIFO register set.
Neither CPU shared the other's RAM -- they passed messages.
The co-processor ran at full speed with zero bus contention.

Key insight from BBC Tube:
The co-processor wins not because it is faster, but because it has
uncontended RAM. The 68030 loses cycles to AGA DMA constantly.
The CM4 runs on its own LPDDR4 with zero bus contention.

```
BBC Model:
  [6502 host] <--Tube ULA FIFO--> [ARM co-processor + own RAM]
       |                                    |
  I/O, video, sound                   runs programs
                                      full speed RAM

Morosa-1200:
  [68030 + AGA] <--dual-port SRAM--> [CM4 BCM2711 + LPDDR4]
       |                                    |
  AmigaOS, AGA chips              Linux, all modern I/O
  legacy software                 video decode, RTG, USB
```

---

## Communication Hardware

### Dual-Port SRAM
Chip: IDT70V24 or CY7C136
Size: 1-4MB
Both CPUs have simultaneous direct access
No arbitration delay for reads
Hardware semaphore for write coordination
Deterministic latency (~20ns)
No OS required on either side to manage it

### Message Structure
```
SRAM window layout:
  0x000000 - 0x0003FF  Control registers / mailbox
  0x000400 - 0x0007FF  68030 -> CM4 command queue
  0x000800 - 0x000BFF  CM4 -> 68030 result queue
  0x000C00 - 0x000FFF  Status flags / semaphores
  0x001000 - 0x3FFFFF  Data transfer area (frames, buffers)
```

### Interrupt Lines
CM4 can interrupt 68030 via _INT2 or _INT6
68030 can signal CM4 via GPIO line (CM4 40-pin header)
Polling also supported for non-time-critical operations

---

## AmigaOS Integration

### Stub Library Pattern
AmigaOS never needs to know the CM4 exists.
Existing library interfaces are preserved.
Stub libraries intercept calls and route to CM4.

```
Application
    |
Standard AmigaOS library call
(graphics.library, datatypes, ahi.device etc)
    |
[Stub library -- SetFunction() patches]
    |
Command written to SRAM mailbox
    |
CM4 Linux process handles request
    |
Result written back to SRAM
    |
68030 notified via interrupt or polling
    |
Application receives result
    |
Application never knew anything changed
```

### Autoconfig Detection
AmigaOS detects CM4 co-processor at boot via
Autoconfig-style probe of shared SRAM control registers.
CM4 identifies itself, reports capabilities.
AmigaOS stub libraries load automatically if CM4 present.
Graceful fallback to native 68030 if CM4 absent.

---

## Video Decode Offload

### Problem
68030 at 50MHz cannot decode modern video formats in real time.
AGA chip bus contention makes it worse.
Even MPEG-1 at low resolution is painful.

### Solution
BCM2711 has dedicated hardware video decode:
- H.264: 1080p60 hardware
- H.265/HEVC: 4K capable
- VP9: YouTube format
- MPEG-2: Old AVI/VOB
- MJPEG: Common AGA format
All at near-zero CPU cost on CM4 side.

### Workflow
```
AmigaOS video player opens file
    |
datatypes.library called
    |
video.datatype stub intercepts
    |
File handle passed to CM4 via SRAM mailbox
    |
CM4 hardware-decodes frame (~0% ARM CPU usage)
    |
Raw decoded frame written to SRAM data area
    |
CM4 interrupts 68030
    |
68030 blits frame to display (AGA or RTG)
    |
Next frame request sent to CM4
    |
Result: smooth 1080p video on a 68030 Amiga
```

---

## RTG Screen Mode Offload

### CGX/P96 Stub Driver
```
AmigaOS opens RTG screen (e.g. 1920x1080x32)
    |
cgx_cm4.card driver registered with CyberGraphX
    |
All draw calls intercepted by stub
    |
Command buffer built in SRAM:
  FILLRECT, BLIT, DRAWLINE etc
    |
CM4 VideoCore VI executes via OpenGL ES 3.1
    |
Output direct to HDMI 2
    |
Workbench compositor runs on CM4
Alpha blending, smooth window drag, shadows
All impossible on stock AGA
```

### Warp3D Offload (Phase 2 with RV350)
```
Amiga 3D application calls Warp3D API
    |
warp3d_cm4.library intercepts
    |
Translate Warp3D calls to OpenGL ES (Phase 1)
OR pass to RV350 native Warp3D driver (Phase 2)
    |
Rendered frame in SRAM
    |
68030 blits to display
    |
Existing Amiga 3D games work unchanged
```

---

## Audio Offload

### MP3 / OGG Decode
68030 cannot decode MP3 in real time at usable quality.
CM4 decodes trivially -- sends PCM samples to SRAM.
68030 feeds PCM to Paula DMA or PCM5102A DAC.
AHI compatible -- existing Amiga audio software works.

### Audio Recording
PCM1808 ADC samples audio.
CM4 receives raw samples via I2S.
CM4 can encode to MP3/FLAC/WAV.
Stored to NVMe or SD.
AmigaOS sees standard AHI recording device.

---

## Networking Offload

### bsdsocket.library Stub
```
AmigaOS application calls bsdsocket.library
(MiamiDX, AmiTCP etc)
    |
Stub intercepts socket calls
    |
Serialised to SRAM mailbox
    |
CM4 Linux TCP/IP stack handles
    |
Result returned via SRAM
    |
Application sees standard BSD socket behaviour
    |
Full internet access from AmigaOS
via CM4 GbE -- no Amiga network card needed
```

---

## Boot Sequence

```
1. ATX power on
2. CM4 boots from SD2 (Linux -- ~8 seconds)
3. CM4 initialises all I/O:
     USB controllers
     Gigabit Ethernet
     NVMe via PCIe
     HDMI 2
     Dual-port SRAM
     ADV7513 (HDMI 1) via I2C
4. CM4 writes ready flag to SRAM control register
5. CM4 releases 68030 reset line
6. 68030 starts -- Kickstart loads from ROM
7. AmigaOS boots -- probes SRAM, finds CM4
8. Stub libraries load automatically
9. Both CPUs running, SRAM channel open
10. User sees Workbench on HDMI 2
    AGA output available on HDMI 1
```

---

## Development Path

```
Phase 1 -- Prove SRAM communication
  Simple 68k test: write colour to SRAM
  CM4 reads it, paints rectangle on HDMI 2
  Proves the full pipeline works
  Can do this on bench before PCB exists
  (RPi4B + logic level shifter + breadboard)

Phase 2 -- Basic CGX stub
  Register one screen mode with CGX
  Route basic blitter calls to CM4
  Workbench on CM4 HDMI output

Phase 3 -- Video decode
  datatypes stub
  CM4 returns decoded frames
  Video plays in Workbench window

Phase 4 -- Audio and networking
  AHI stub for audio decode/record
  bsdsocket stub for networking

Phase 5 -- Warp3D
  Translate Warp3D to OpenGL ES
  Test with existing Amiga 3D software

Phase 6 -- RV350 daughter board (Phase 2 hardware)
  Native Warp3D on RV350
  Theater 200 PAL/NTSC capture
```

---

## Offload Summary

| Task | Stock A1200 | With CM4 |
|---|---|---|
| H.264 video | Impossible | 1080p hardware decode |
| MP3 audio | Painful | Trivial |
| RTG 1080p | Not possible | CM4 VideoCore VI |
| Warp3D 3D | Slow (68030) | Above PS2 (Phase 2) |
| Networking | Slow modem | GbE via Linux |
| USB | Not possible | Full HID + storage |
| PAL capture | External hw | Theater 200 onboard |
| AGA capture | Not possible | Self-capture via Theater 200 |
| Font render | 68030 slow | CM4 FreeType |
| PNG/JPEG | Slow datatypes | CM4 libpng/libjpeg |
