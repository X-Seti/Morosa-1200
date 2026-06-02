# X-Seti - May 2026 - Morosa-1200 - Video Architecture

"""
VIDEO_ARCHITECTURE.md - Dual HDMI output architecture, AGA native path,
RTG/CM4 path, PAL/NTSC handling, and GPU offload strategy.
"""

## Overview

Morosa-1200 has two completely independent video output paths running
simultaneously. No switching required, no compromises on either path.

```
HDMI 1 -- AGA native (Lisa -> ADV7513)
HDMI 2 -- RTG/CM4 (BCM2711 VideoCore VI)
```

---

## HDMI 1 -- AGA Native Path

### Signal Path
```
Lisa (MOS 4203) PLCC-84
  Digital RGB bus -- 24 lines (8-bit per channel)
  + HSYNC, VSYNC, CSYNC, BLANK, CLOCK
      |
  Direct PCB traces (no connector, no cable)
      |
  ADV7513 HDMI transmitter (Analog Devices)
      |
  HDMI Type-A connector -- I/O shield position 1
```

### Why ADV7513
- Fractional PLL locks to Lisa's non-standard pixel clocks
- Handles PAL 50.08Hz exactly -- no frame rate conversion
- Handles NTSC 59.94Hz exactly
- Handles AGA Productivity mode (31kHz VGA)
- Handles SuperHires, Super72, all AGA modes
- I2C configuration (CM4 owns I2C bus for EDID/mode negotiation)
- No scandoubler needed in traditional sense
- Just pixel clock regeneration and HDMI packetising

### Screen Modes on HDMI 1
All output at exact Lisa pixel clock:
- PAL Low Res 320x256 @ 50Hz
- PAL High Res 640x256 @ 50Hz
- PAL Interlace 640x512 @ 25Hz fields
- NTSC Low Res 320x200 @ 59.94Hz
- NTSC High Res 640x200 @ 59.94Hz
- HAM8 -- all 262144 colours
- Productivity 640x480 @ 31kHz
- SuperHires 1280x256
- Any custom AGA copper mode

### PAL 50Hz -- Why It Matters
PAL Amiga runs at exactly 50.08Hz.
Most HDMI monitors accept 50Hz (broadcast standard).
ADV7513 outputs at exact Lisa pixel clock.
Zero frame rate conversion, zero judder, zero dropped frames.
PAL demos run at exact speed they were coded for.
Games feel exactly as they did on a Commodore 1084S monitor.

---

## HDMI 2 -- RTG / CM4 Path

### Signal Path
```
BCM2711 (CM4 module)
  Native HDMI output
      |
  HDMI Type-A connector -- I/O shield position 2
```

### Screen Modes on HDMI 2
Any resolution the BCM2711 supports:
- 1920x1080 @ 60Hz (1080p)
- 2560x1440 @ 60Hz (1440p)
- 3840x2160 @ 30/60Hz (4K)
- Any custom resolution

### CyberGraphX / Picasso96 Integration
CM4 exposes RTG screen modes to AmigaOS via CGX driver stub:
```
AmigaOS opens RTG screen (e.g. 1920x1080x32)
    |
CGX stub driver intercepts
    |
Draw calls pass to CM4 via dual-port SRAM mailbox
    |
CM4 VideoCore VI executes via OpenGL ES 3.1
    |
Output direct to HDMI 2
    |
AmigaOS never knows it left the 68030
```

### VideoCore VI Performance
- ~20M polygons/sec
- ~1.4 Gpixels/sec fill rate
- OpenGL ES 3.1
- Hardware video decode (H.264, H.265, VP9, MPEG-2)
- Approaching PS2 territory (PS2 = 2.4 Gpixels/sec)
- Sufficient for: Workbench compositing, video playback,
  Warp3D-era 3D games, demo effects

---

## Both Outputs Simultaneously

HDMI 1 and HDMI 2 are completely independent.
Both can be connected at the same time.
Single monitor users: two HDMI inputs, press button to switch.
Dual monitor users: AGA on one, RTG on the other.

```
Typical use:
  HDMI 1 -> older monitor or TV
            AGA demos, games, native software
            Exact PAL/NTSC timing preserved

  HDMI 2 -> modern widescreen monitor
            RTG Workbench, productivity
            Video playback, web via CM4
```

---

## CM4 Video Offload Architecture

### BBC Tube Model Applied to Video
```
68030 sets up copper list and DMA (as normal)
    |
Lisa outputs digital RGB to HDMI 1 (transparent)
    |
For RTG operations:
  68030 calls CGX library
      |
  CGX stub writes command to dual-port SRAM
      |
  CM4 reads command, executes on VideoCore VI
      |
  Result on HDMI 2
      |
  68030 notified via interrupt (optional)
```

### Video Decode Offload
```
AmigaOS opens video file via datatypes
    |
Datatype stub passes file handle to CM4 via SRAM
    |
CM4 hardware-decodes frame (H.264 = near zero CPU cost)
    |
Raw frame written to SRAM window
    |
68030 blits frame to AGA screen or RTG surface
    |
Smooth video playback at 1080p on a 68030 Amiga
```

### AGA Self-Capture
```
AGA demo running on 68030
    |
Lisa outputs PAL to HDMI 1 (display)
    |
Lisa RGB also routed to Theater 200 analog input (Phase 2)
    |
Theater 200 captures PAL stream
    |
CM4 receives raw PAL frames via V4L2
    |
CM4 encodes to H.264
    |
Written to NVMe or SD
    |
Real-time AGA demo capture, no external hardware
```

---

## Phase 2 -- GPU Daughter Board

### RV350 (from AIW Radeon 9600 Pro/XT donor)

```
Performance:
  ~30-40M triangles/sec
  ~3.2 Gpixels/sec fill rate
  Above PS2 (2.4 Gpixels), near original Xbox (4.0 Gpixels)
  DirectX 9 / Shader Model 2.0
  OpenGL 2.0

Amiga drivers:
  Picasso96: Yes (R300 confirmed)
  Warp3D:    Yes (R300 confirmed)
  CGX:       Yes

Package: BGA -- requires rework station
Done as separate daughter board to protect main PCB
```

### ATI Theater 200 (alongside RV350)

```
PAL: 625 lines, 50Hz -- European/UK/Australian standard
NTSC: 525 lines, 59.94Hz -- North American standard
SECAM: 625 lines, 50Hz -- French variant
S-Video input: both standards
Composite input: both standards
Hardware YUV decode
Adaptive 3D comb filter
Auto-detects input standard

Linux driver: V4L2 (existing, mature)
CM4 owns via I2C
AmigaOS accesses via SRAM stub

Use cases:
  PAL VHS archive digitisation
  AGA output capture (self-recording)
  NTSC source compatibility
  Real-time H.264 encode via CM4 hardware
```

---

## Screen Mode Summary

| Mode | Output | Source | Notes |
|---|---|---|---|
| PAL Low/Hi Res | HDMI 1 | Lisa direct | Native 50Hz exact |
| NTSC | HDMI 1 | Lisa direct | Native 59.94Hz exact |
| HAM8 | HDMI 1 | Lisa direct | All 262144 colours |
| Productivity | HDMI 1 | Lisa direct | 640x480 31kHz |
| Any AGA copper | HDMI 1 | Lisa direct | Pixel perfect |
| RTG 1080p | HDMI 2 | CM4 VideoCore | CGX/P96 driver |
| RTG 1440p | HDMI 2 | CM4 VideoCore | CGX/P96 driver |
| RTG 4K | HDMI 2 | CM4 VideoCore | CM4 capable |
| Warp3D (Ph2) | HDMI 2 | RV350 daughter | Native Warp3D |
| Video playback | HDMI 2 | CM4 H.264 HW | 1080p smooth |
| Composited WB | HDMI 2 | CM4 VideoCore | Alpha blend, smooth |
