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

### On SPC700 (full list at [TODO.txt](TODO.txt))

- Currently, the number 1 priority is optimization. SNESFM is slow as hell right now
- Modular synthesis-related:
  - Tilted saw/triangle generation
  - Feedback
  - Mult
  - etc
- Effects other than volume changes
- 4 sections in instruments
- Extended communication with the main CPU, therefore
  - Sound effects
  - Streaming samples
  
### On 5A22 (in the not yet forseeable future; check out [Genecyzer](https://github.com/ADM228/Genecyzer) for a PC implementation in the meantime)

- Possibly some simplistic demo interface (when CPU commnunication is improved)

## Building

This project is made and compiled with the [asar](https://github.com/rpghacker/asar) SNES compiler, specifically version 1.90. On Linux you build it with `make`, and there is no separate process for building on Windows, so just use e.g. [winmake](https://gnuwin32.sourceforge.net/packages/make.htm) to build it with the same makefile. If you want use other compilers in your project, you're sorta in luck as asar (somehow) can build a binary file of just SNES-FM (in N-SPC format). To do that, call `make SNESFM`, and you will end up with an `SNESFM.bin` file in the `bin` directory.

## Usage in your projects

This project is very much incomplete so i can't exactly recommend using it yet, but if you really need to, it is licensed under the zlib license (except for any demo songs as of right now (policy might change)), a copy of which is [included with the project](LICENSE). The configuration guide can be found [here](docs/configuration.md).

## Development & testing

It is being currently developed and tested on [bsnes+](https://github.com/devinacker/bsnes-plus) and [Mesen 2](https://github.com/sourmesen/mesen2) because of their accuracy and debugging features, so, if it doesn't work on your emulator, use bsnes, bsnes+, higan, ares, or Mesen 2.
