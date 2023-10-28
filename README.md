[![Build status](https://github.com/ADM228/SNES-FM/actions/workflows/main.yml/badge.svg)](https://github.com/ADM228/SNES-FM/actions/workflows/main.yml)

# SNES-FM

## Overview

SNES-FM is a frequency modulation synthesis engine/sound driver for the SNES (or specifically, the SPC700). The main gimmick of it is its ability to generate instruments before playback.

## Currently implemented features

### On 5A22/65816/main CPU

- Uploading code, instrument and song data to the SPC700
- Phase modulation on the 65816 (for testing purposes)
- Basic "UI" to change the mod strength on the 65816

### On SPC700/audio CPU

- Parsing the compressed instrument data
- Pitch table generation
- Phase modulation
- Pulse generation
- PCM to BRR conversion and sound
- Basic sound driver stuff - instruments, patterns and notes

## Roadmap (sorta)

### On SPC700

- Modular synthesis-related:
  - Tilted saw/triangle generation
  - Feedback
  - Mult
  - etc
- Effects other than volume changes
- Extended communication with the main CPU, therefore
  - Streaming samples
  - Sound effects
- 4 sections in instruments
  
### On 5A22 (in the not yet forseeable future; check out [Genecyzer](https://github.com/ADM228/Genecyzer) for a PC implementation in the meantime)

- A whole-ass tracker and a DAW (design of the latter will be completely stolen from [FamiStudio](https://github.com/BleuBleu/FamiStudio))
- Saving tracker data to SRAM and sharing .srm files of songs
- SNES Mouse (up to 4 simultaneously) and NTT Data Pad (up to 8) support along with standard controllers (up to 8)
- Miracle Piano Teaching System keyboard support (up to 4 (maybe 8 if additional buttons)) (if anyone i know gets one)
- XBAND ASCII keyboard support (up to 2)

## Building

This project is made and compiled with the [asar](https://github.com/rpghacker/asar) SNES compiler. On Linux you build it with `make`, and there is no separate process for building on Windows, so just use e.g. [winmake](https://gnuwin32.sourceforge.net/packages/make.htm) to build it with the same makefile. If you want use other compilers in your project, you're sorta in luck as asar (somehow) can build a binary file of just SNES-FM (in N-SPC format). To do that, call `make SNESFM`, and you will end up with an `SNESFM.bin` file in the `bin` directory.

## Usage in your projects

This project is very much incomplete so i can't exactly recommend using it yet, but if you really need to, it is licensed under the zlib license, a copy of which is [included with the project](LICENSE). The code size statistics depending on compile options can be found in [this document](docs/usage.md).

## Development & testing

It is being currently developed and tested on [bsnes+](https://github.com/devinacker/bsnes-plus) and [Mesen 2](https://github.com/sourmesen/mesen2) because of their accuracy and debugging features, so, if it doesn't work on your emulator, use bsnes, bsnes+, higan, ares, or Mesen 2.
