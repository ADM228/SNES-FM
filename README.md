[![Build status](https://github.com/ADM228/SNES-FM/actions/workflows/main.yml/badge.svg)](https://github.com/ADM228/SNES-FM/actions/workflows/main.yml)

# SNES-FM
SNES-FM is a frequency modulation synthesis engine/sound driver for the SNES (or specifically, the SPC700). The main gimmick of it is its ability to generate instruments before playback.  
It currently has the following features:
- On 65816 (main CPU, controls visuals and SPC700):
  - Uploading data to the SPC700
  - Phase modulation on the 65816 (for testing purposes)
  - Basic "UI" to change the mod strength on the 65816
- On SPC700 (audio CPU, controls just audio):
  - Pitch table generation
  - Phase modulation
  - Pulse generation 
  - PCM to BRR conversion and sound
  - Basic sound driver stuff - instruments, patterns and notes

The following features will be implemented in the future:
- On SPC700:
  - Tilted saw/triangle generation
  - Effects other than volume changes
  - Communication with the main CPU, therefore
   - Streaming samples
   - Sound effects
- On 65816 in the FAAAAAAAAAAR future (check out [Genecyzer](https://github.com/ADM228/Genecyzer) for a PC implementation in the meantime):
  - A whole-ass tracker and a DAW (design of the latter will be completely stolen from [FamiStudio](https://github.com/BleuBleu/FamiStudio)) 
  - Saving tracker data to SRAM and sharing .srm files of songs
  - SNES Mouse (up to 4 simultaneously) and NTT Data Pad (up to 8) support along with standard controllers (up to 8) 
  - Miracle Piano Teaching System keyboard support (up to 4 (maybe 8 if additional buttons)) (if anyone i know gets one)
  - XBAND ASCII keyboard support (up to 2)

This project is licensed under the zlib license, a copy of which is [included with the project](LICENSE).

It is being currently developed and tested on [bsnes+](https://github.com/devinacker/bsnes-plus) and [Mesen 2](https://github.com/sourmesen/mesen2) because of their accuracy and debugging features, so, if it doesn't work on your emulator, use bsnes, bsnes+, higan, ares, or Mesen 2.
