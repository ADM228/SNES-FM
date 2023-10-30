# How much space will SNESFM eat up in my project?

It's a pretty big question to solve considering how configurable SNESFM is. So here's how the settings increase/decrease the amount of space used by SNESFM code:

## Usage by configuration options

Configuration names are marked in `code`, !SNESFM_CFG is omitted from all of them.

### `SAMPLE_GENERATE`

- **0**: The basis, **+0** bytes;
- **1**: **+520** bytes while also enabling other chunks of code.

### `SAMPLE_USE_FILTER1` (only applies if `SAMPLE_GENERATE` is set)

- **0**: The basis, **+0** bytes;
- **1**: **+193** bytes.

### `LONG_SMP_GEN` (only applies if `SAMPLE_GENERATE` is set)

- **0**: The basis, **+0** bytes;
- **1**: **+48** bytes while also enabling other chunks of code.

### `PHASEMOD` (only applies if `SAMPLE_GENERATE` is set)

- **0**: The basis, **+0** bytes;
- **1**: A basis of **+44** bytes and additionally (these all stack):
  - **+111** bytes if `LONG_SMP_GEN` is set,
  - **+140** bytes if `SHORTSMP_GEN` is set,
  - **+9** bytes on top of that if both are set.

### `PULSEGEN` (only applies if `SAMPLE_GENERATE` is set)

- **0**: The basis, **+0** bytes;
- **1**: A basis of **+5** bytes and additionally (these all stack):
  - **+154** bytes if `LONG_SMP_GEN` is set,
  - **+189** bytes if `SHORTSMP_GEN` is set,
  - **+4** bytes on top of that if both are set.

### `INSGEN_REPEAT_AMOUNT` (only applies if `SAMPLE_GENERATE` is set)

- **0**: The basis, **+0** bytes;
- **1**: **+20** bytes, and an additional +11 bytes if `PHASEMOD` is also set, resulting in **+31** bytes;
- **2**: **+33** and **+44** bytes respectively;
- **3**: **+39** and **+50** bytes respectively;
- **4**: **+45** and **+56** bytes respectively.

### `PITCHTABLE_GEN`

- **0**: The basis,**+0** bytes inside code, but you have to supply **192** bytes of the pitchtable itself somewhere along the way;
- **1**: **+137** bytes (will increase due to not yet parsing song data header to generate pitch tables at will) inside code.
