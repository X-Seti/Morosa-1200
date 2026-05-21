# X-Seti - May 2026 - Morosa-1200 - Donor Chip Transplant Guide

"""
TRANSPLANT.md - Donor chip removal, identification and transplant guide.
Covers A1200 and CyberVision 64/3D donor boards.
"""

# Donor Chip Transplant Guide

## Overview

Morosa-1200 is designed around chips transplanted from a donor Amiga 1200.
This guide covers identification, removal, and preparation of donor chips.

---

## Chips Required From Donor A1200

| Chip | Package | Function | Notes |
|---|---|---|---|
| Alice (MOS 8374) | PLCC-84 | AGA Agnus — DMA/blitter/copper | Hot chip, runs warm |
| Lisa (MOS 4203) | PLCC-84 | AGA Denise — video output | Hot chip |
| Paula (MOS 8364) | PLCC-52 | Audio, floppy, serial, IRQ | Usually reliable |
| Gayle (MOS 391424) | PLCC-52 | IDE, PCMCIA, chip select | Check for corrosion |
| Budgie (MOS 391425) | SMD SOJ | PCMCIA buffer | Small, handle carefully |
| CIA × 2 (MOS 8520) | PLCC-44 | I/O controllers | Two required |
| 68EC020 CPU | PLCC-68 | Main processor | Check for bent pins |
| Crystal OSC (PAL) | DIP-4 | 28.37516 MHz clock | Keep with board |
| Kickstart ROMs × 2 | DIP-40 | Kickstart 3.1 | Source new if possible |

---

## Chips Required From Donor CyberVision 64/3D

| Chip | Package | Function | Notes |
|---|---|---|---|
| S3 Virge/VX | BGA/QFP | 2D/3D graphics accelerator | Check revision |
| VRAM × 4 | SOJ-40 | 1MB each = 4MB total | EDO VRAM |

---

## Removal Tools Required

- Hot air rework station (recommended 280–320°C for PLCC)
- PLCC extraction tool (for socketed chips)
- Flux (no-clean)
- IPA and brushes for cleaning
- Anti-static mat and wrist strap
- Fine-tip tweezers
- Multimeter for continuity checks

---

## Removal Procedure — PLCC Chips (Alice, Lisa, Paula, Gayle, CIAs, CPU)

1. Apply flux liberally around all four sides of the chip
2. Set hot air to 300°C, medium airflow
3. Work around all four sides evenly — do not concentrate heat on one side
4. Test for movement gently with tweezers every 30 seconds
5. When all solder has reflowed, lift chip cleanly straight up
6. Clean pads with solder wick and IPA
7. Inspect all pads — none should be lifted
8. Store chips in anti-static foam

**Note:** Alice and Lisa run hot during operation. If the donor board has
been heavily used, inspect the PCB under these chips for heat stress damage.

---

## Removal Procedure — Budgie (SMD SOJ)

Budgie is small and the pads are close together. Use hot air at 260°C with
a fine nozzle. Keep surrounding components shielded with kapton tape.
Alternatively a skilled operator can use a drag soldering technique to remove.

---

## Condition Checks Before Transplanting

### All PLCC chips
- Visual: no cracked package, no corrosion on pins
- Pin check: all pins present, none bent under the package
- If socketed on donor: test in donor first before transplanting

### CPU (68EC020)
- PLCC-68 is fragile — check all 68 pins carefully
- A bent pin under the package may not be visible until the chip fails to boot

### Paula
- Check for corrosion on the audio output pins (pins 1–4)
- Paula chips are generally very reliable; failures are rare

### CIAs
- Two required — CIA-A and CIA-B
- Both MOS 8520 — identical chips, position on board determines function
- Very robust, rarely fail

### Kickstart ROMs
- If sourcing new: use Kickstart 3.1 (391773-01 / 391774-01) or 3.2
- ROM images available for programming 27C400 EPROMs
- New EPROMs recommended over donor ROMs which may be 30+ years old

---

## Preparation for Transplant

1. Clean all chip pins with IPA — remove any flux residue from donor board
2. Check pin coplanarity — all pins should sit flat
3. Re-tin any oxidised pins with fresh solder before transplanting
4. Use PLCC sockets on Morosa-1200 for all socketed chips — allows future removal
4. Alternatively solder direct (as recommended by Alicia 1200 builder notes)
   for better thermal contact and more reliable connections

---

## References

- Chucky Hertell transplant guide: https://wordpress.hertell.nu/?p=1053
- Alicia 1200 build notes: https://amiga.erkan.se/alicia-1200-amiga-1200-clone-in-mini-itx-form-factor/
- A1200 chip pinouts: https://www.amigawiki.org
