# How much space will SNESFM eat up in my project?

It's a pretty big question to solve considering how configurable SNESFM is. So here's how the settings increase/decrease the amount of space used by SNESFM code:

## Usage by configuration options

Configuration names are marked in `code`, !SNESFM_CFG is omitted from all of them

### `SAMPLE_GENERATE`

- **0**: The basis, **+0** bytes
- **1**: **+732** bytes by itself, it also allows a bunch of other options to be enabled

### `PHASEMOD`

- **0**: The basis, **+0** bytes
- **1**: 33+5+
- 15 if both smp gen
- 6 if only either one is set

### `INSGEN_REPEAT_AMOUNT` (only applies if `SAMPLE_GENERATE` is set)

- **0**: The basis, **+0** bytes
- **1**: **+21** bytes, and additionally +11 bytes if `PHASEMOD` is also set, resulting in **+32** bytes
- **2**: **+34** and **+45** bytes respectively
- **3**: **+46** and **+57** bytes respectively
- **4**: **+58** and **+69** (nice) bytes respectively

### `PITCHTABLE_GEN`

- **0**: The basis,**+0** bytes inside code, but you have to supply **192** bytes of the pitchtable itself somewhere along the way
- **1**: **+137** bytes (will increase due to not yet parsing song data header to generate pitch tables at will) inside code