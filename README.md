[![Build status](https://github.com/ADM228/SNES-FM/actions/workflows/main.yml/badge.svg)](https://github.com/ADM228/SNES-FM/actions/workflows/main.yml)

# SNES-FM
SNES-FM is a frequency modulation synthesis engine for the SNES (or specifically, the SPC700).
The following features are already implemented:
- On 65816 (main CPU, controls visuals and SPC700):
  - Uploading data to the SPC700
  - Phase modulation on the 65816 (for testing purposes)
  - Basic "UI" to change the mod strength on the 65816
- On SPC700 (audio CPU, controls just audio):
  - Phase modulation
  - Pulse generation 
  - PCM to BRR conversion and sound
  - Basic sound driver stuff - instruments, patterns and notes

The following features will be implemented in the future:
- On 65816:
  - A whole-ass tracker for this
  - Also a DAW too (design will be completely stolen from FamiStudio at https://github.com/BleuBleu/FamiStudio) 
  - Saving tracker data to SRAM and sharing .srm files of songs
  - SNES Mouse (up to 4 simultaneously) and NTT Data Pad (up to 8) support along with standard controllers (up to 8) 
  - Miracle Piano Teaching System keyboard support (up to 4 (maybe 8 if additional buttons)) (if anyone i know gets one)
  - XBAND ASCII keyboard support (up to 2)
- On SPC700:
  - Tilted saw/triangle generation
  - Effects other than volume changes

The engine is not realtime since the SPC700 is slow af, the engine generates all the instruments before playing a song.

It is being currently developed and tested on [bsnes+](https://github.com/devinacker/bsnes-plus) and [Mesen 2](https://github.com/sourmesen/mesen2) because of their accuracy and debugging features, so, if it doesn't work on your emulator, use bsnes, bsnes+, higan, ares, or Mesen 2.
