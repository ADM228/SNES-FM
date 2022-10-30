# SNES-FM
SNES-FM is a frequency modulation synthesis engine for the SNES (or specifically, the SPC700).
The following features are already implemented:
- Uploading data to the SPC700 (although it refuses to work sometimes which is why there might be NOPs in the SPC700 code)
- Phase modulation on the SPC700
- Phase modulation on the 65816 (for testing purposes)
- Basic "UI" to change the mod strength on the 65816

The following features will be implemented in the future:
- On-demand pulse and tilted saw/triangle synthesis 
- PCM to BRR conversion and y'know, sound
- Channel 8 drum mode (softmixing 8-bit PCM samples into 1 channel)
- A whole-ass tracker for this
- Saving tracker data to SRAM and sharing .srm files of songs

The engine is not realtime since the SPC700 is slow af, the engine generates all the instruments before playing a song.

It is being currently developed and tested on https://github.com/devinacker/bsnes-plus because of its accuracy and debugging features, so, if it doesn't work on Snes9x or (why the f*ck would you use that) ZSNES, use bsnes, bsnes+, higan or ares.
