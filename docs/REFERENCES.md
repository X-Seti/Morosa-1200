# References & Research Links

## Related Open Hardware Projects

### Mainboard Replicas
```
git clone https://github.com/SukkoPera/Raemixx500        # A500+ KiCad — gold standard methodology
git clone https://github.com/amigalisa/Amiga-SMD-500      # A500 SMD version
git clone https://bitbucket.org/jvandezande/amiga-1200    # A1200+ modular KiCad
git clone https://github.com/Bmiga-1200/b1200-hardware    # A1200 FPGA clone (reference)
git clone https://github.com/rhaamo/kicad-amiga2000       # A2000 Rev6.2 KiCad
git clone https://github.com/iansbremner/Amiga-2000-KiCAD # A2000 Rev6
git clone https://github.com/jasonsbeer/Amiga-2000-EATX   # A2000 EATX
git clone https://github.com/iansbremner/Amiga-3000-Daughterboard
git clone https://github.com/Acill/A4000RevB              # A4000 KiCad + Gerbers
```

### Modern Enhanced Designs
```
git clone https://github.com/jasonsbeer/AmigaPCI          # OCS/ECS ATX with native PCI
git clone https://github.com/nonarkitten/amiga_replacement_project  # FPGA chip replacements
```

### Chip Replacements & Addons
```
git clone https://github.com/endofexclusive/deniser       # FPGA Denise drop-in replacement
git clone https://github.com/SukkoPera/OpenAmigaVideoHybrid
git clone https://github.com/reinauer/amiga-romy          # 1MB ROM adapter A3000/A4000
```

### Commercial Non-Open Projects (reference only)
- Alicia 1200 (Mini-ITX AGA): https://www.enterlogic.se
- Denise (Mini-ITX A500+): https://www.enterlogic.se
- UK reseller: https://shop.flamelily.co.uk

---

## Key Datasheets Needed

### AGA Chipset
- Alice (MOS 8374) — Hardware Reference Manual covers DMA/blitter
- Lisa (MOS 4203) — AGA video output pinout
- Paula (MOS 8364) — Audio/IO/serial pinout
- Gayle (MOS 391424) — IDE/PCMCIA register map
- CIA 8520 — I/O controller timing

Primary source: http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/

### S3 Virge/VX
- S3 Virge/VX datasheet: search S3 Graphics archive
- CyberGraphX driver source: available via Aminet

### Modern ICs
- SiI9022A HDMI transmitter: Silicon Image
- ADV7513 HDMI transmitter: Analog Devices (alt to SiI9022A)
- PCM5102A stereo DAC: Texas Instruments
- PCM1808 stereo ADC: Texas Instruments
- CH376S USB host: WCH (Jiangsu Hengqin Technology)
- MAX3421E USB host: Maxim/Analog Devices
- ENC28J60 Ethernet: Microchip
- W5500 Ethernet: WIZnet
- ATmega324PB keyboard MCU: Microchip
- 6N137 MIDI optocoupler: standard

---

## Community Resources

- AmigaWiki: https://www.amigawiki.org
- Amiga Hardware Reference: http://amigadev.elowar.com
- English Amiga Board: https://eab.abime.net
- Amiga PCB Explorer: http://amigapcb.org
- Component locator (ReAmiga builds): http://locator.reamiga.info
- Chucky Hertell blog: https://wordpress.hertell.nu
- Retro Tinkering Discord: https://discord.gg/retrotinkering
- Amiga.erkan.se (Alicia builder notes): https://amiga.erkan.se

---

## Standards & Form Factor References

- Mini-ITX specification: 170×170mm, 4× M3 mounting holes
- ATX power connector: 24-pin Molex Mini-Fit Jr
- IDE (ATA): 40-pin 2.54mm pitch header
- Floppy: 34-pin 2.54mm pitch header
- DIN-5 MIDI: standard 180° 5-pin DIN
- HDMI Type A: 19-pin
- Mini-DIN 8 RGB (PS2/PS3 style): SCART-compatible signal levels
