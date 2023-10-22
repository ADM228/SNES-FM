# How much space will SNESFM eat up in my project?

It's a pretty big question to solve considering how configurable SNESFM is. So here's how the settings increase/decrease the amount of space used by SNESFM code:

### !SNESFM_CFG_INSGEN_REPEAT_AMOUNT:

- **0**: The basis, ***+0*** bytes
- **1**: ***+21*** bytes if !SNESFM_CFG_SAMPLE_GENERATE is set, and ***+32*** if both !SNESFM_CFG_SAMPLE_GENERATE and !SNESFM_CFG_PHASEMOD are set
- **2**: ***+34*** and ***+45*** bytes respectively
- **3**: ***+46*** and ***+57*** bytes respectively
- **4**: ***+58*** and ***+69*** (nice) bytes respectively

### !SNESFM_CFG_PITCHTABLE_GEN:

- **0**: The basis, ***+0*** bytes inside code, but you have to supply ***192*** bytes of the pitchtable itself somewhere along the way
- **1**: ***+137*** bytes (will increase due to not yet parsing song data header to generate pitch tables at will) inside code