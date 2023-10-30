# How do I configure SNESFM?

SNESFM is an extremely configurable sound driver. Options can increase the amount of space it takes, and increase or decrease the amount of space the instrument or song data takes. This is a guide to configuring SNESFM.

## Guidelines for this document

Configuration names are marked in `code`, !SNESFM_CFG is omitted from all of them. Every option features a brief description of its action, possible influence on/by other options, and its code usage.  

### Dictionary

Here's a few phrases and symbols often used here:

- "Enabled" = defined as 1 or more
- "Disabled" = defined as 0  
- "By default" = if not defined
- Logical operations:
  - ¬ - the NOT operation
  - ∧ - the AND operation
  - ∨ - the OR operation

## General sample generation options

### `SAMPLE_GENERATE`

#### Description

Dictates whether to include the code that can generate samples - the main gimmick of the SNESFM sound driver. It can reduce space that samples would've taken up in your game, however it is unfortunately pretty costly space-wise by itself.  

#### Influence on/by other options, default value

If not enabled, automatically enables `INSGEN_USE_CUSTOM_SAMPLES` if latter not defined.  
Enables several other options and blocks of options.  
Disabled by default.

#### Space usage

- **0**: **+0** bytes;
- **1**: **+520** bytes.

### `SAMPLE_USE_FILTER1`

#### Description

Whether to be able to generate samples using BRR filter mode 1. These samples have finer details, but take longer to produce, and due to the rough nature of the algorithm, may have some details wrong.

#### Influence on/by other options, default value

Only works if `SAMPLE_GENERATE` is enabled.  
Disabled by default.

#### Space usage

- **0**: **+0** bytes;
- **1**: **+193** bytes.

### `LONG_SMP_GEN`

#### Description

Whether to generate long samples (128 sample points long, good for higher quality in bass). They take longer to produce than their short counterparts.

#### Influence on/by other options, default value

Only works if `SAMPLE_GENERATE` is enabled.  
Disabled by default.

#### Space usage (wrong, actually of resample)

- **0**: The basis, **+0** bytes;
- **1**: **+48** bytes while also enabling other chunks of code.

### `SHORTSMP_GEN`

#### Description

Whether to generate short samples (32 sample points long, the only way to get high pitched instruments).

#### Influence on/by other options, default value

Only works if `SAMPLE_GENERATE` is enabled.  
Set to `SAMPLE_GENERATE`∧¬`LONGSMP_GEN` by default.

#### Space usage

No direct space usage.

## Phase modulation options

All of these only work if `SAMPLE_GENERATE` is enabled. If none of the following options are defined, they're all disabled.

### `PHASEMOD_BOTH`

#### Description



#### Influence on/by other options, default value



#### Space usage


### `PHASEMOD` (only applies if `SAMPLE_GENERATE` is set)

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: A basis of **+44** bytes and additionally (these all stack):
  - **+111** bytes if `LONG_SMP_GEN` is set,
  - **+140** bytes if `SHORTSMP_GEN` is set,
  - **+9** bytes on top of that if both are set.

### `PULSEGEN` (only applies if `SAMPLE_GENERATE` is set)

#### Description



#### Influence on/by other options, default value



#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: A basis of **+5** bytes and additionally (these all stack):
  - **+154** bytes if `LONG_SMP_GEN` is set,
  - **+189** bytes if `SHORTSMP_GEN` is set,
  - **+4** bytes on top of that if both are set.

### `INSGEN_REPEAT_AMOUNT` (only applies if `SAMPLE_GENERATE` is set)

#### Description



#### Influence on/by other options, default value



#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+20** bytes, and an additional +11 bytes if `PHASEMOD` is also set, resulting in **+31** bytes;
- **2**: **+33** and **+44** bytes respectively;
- **3**: **+39** and **+50** bytes respectively;
- **4**: **+45** and **+56** bytes respectively.

### `PITCHTABLE_GEN`

#### Description



#### Influence on/by other options, default value



#### Space usage

- **0**: The basis,**+0** bytes inside code, but you have to supply **192** bytes of the pitchtable itself somewhere along the way;
- **1**: **+137** bytes (will increase due to not yet parsing song data header to generate pitch tables at will) inside code.
