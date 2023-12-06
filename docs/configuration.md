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

### `RESAMPLE`

#### Description

Enables the resampling routine, which resamples samples from 128 sample points (so-called long samples) to 32 sample points (short samples).

#### Influence on/by other options, default value

Only works if `SAMPLE_GENERATE` is enabled.  
Disabled by default.

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+48** bytes while also enabling other chunks of code.

## Phase modulation options

These options enable the phase modulation routine.

### Enabling any of these

Internal name: `PHASEMOD_ANY` (cannot be overridden).

#### Space usage

**+44** bytes + additional space usage on top of that depending on the option.

### `PHASEMOD_LONG`

#### Description

Enables phase modulation with long samples.

#### Influence on/by other options, default value

Disabled by default.

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+111** bytes.

### `PHASEMOD_SHORT`

#### Description

Enables phase modulation with short samples.

#### Influence on/by other options, default value

Disabled by default.

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+140** bytes.

### `PHASEMOD_BOTH`

#### Influence on/by other options, default value

If enabled, enables both `PHASEMOD_LONG` and `PHASEMOD_SHORT`.  
If not defined, set to `PHASEMOD_LONG`∧`PHASEMOD_SHORT`.

#### Space usage

**+9** bytes on top of `PHASEMOD_LONG` and `PHASEMOD_SHORT`.

## Pulse generation options

These options enable the pulse generation routine.

### Enabling any of these

Internal name: `PULSEGEN_ANY` (cannot be overridden).

#### Space usage

**+5** bytes + additional space usage on top of that depending on the option.

### `PULSEGEN_LONG`

#### Description

Enables the long-sample version of the pulse generation routine.

#### Influence on/by other options, default value

Disabled by default.

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+154** bytes.

### `PULSEGEN_SHORT`

#### Description

Enables the short-sample version of the pulse generation routine.

#### Influence on/by other options, default value

Disabled by default.

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+189** bytes.

### `PULSEGEN_BOTH`

#### Influence on/by other options, default value

If enabled, enables both `PULSEGEN_LONG` and `PULSEGEN_SHORT`.
If not defined, set to `PULSEGEN_LONG`∧`PULSEGEN_SHORT`.

#### Space usage

**+4** bytes on top of `PULSEGEN_LONG` and `PULSEGEN_SHORT`.

## Other generation options

Should this be moved? probably yes

### `INSGEN_REPEAT_AMOUNT` (only applies if `SAMPLE_GENERATE` is set)

#### Description

Allocates slots for repeating arguments for opcode. Each slot has a bitmask, and it conserves options according to that bitmask (saving bytes in instrument data), and a counter decrementing with every opcode, counting until it no longer applies.

#### Influence on/by other options, default value

Disabled by default.

#### Space usage

- **0**: The basis, **+0** bytes;
- **1**: **+20** bytes;
- **2**: **+33** bytes;
- **3**: **+39** bytes;
- **4**: **+45** bytes.

**+11** additional bytes are used if `PHASEMOD` is also set.

### `PITCHTABLE_GEN`

#### Description



#### Influence on/by other options, default value



#### Space usage

- **0**: The basis,**+0** bytes inside code, but you have to supply **192** bytes of the pitchtable itself somewhere along the way;
- **1**: **+137** bytes (will increase due to not yet parsing song data header to generate pitch tables at will) inside code.

## Space usage tables

With how confusing some of the configuration space usage options can be, i have compiled a table containing the space impacts. It's probably the only good part of this document lmao

### Phase modulation

`PHASEMOD_` ommitted from option names.

| `LONG` 🡒<br>`SHORT` 🡓 | <br>0     | <br>1    |
|-:|:-:|:-:|
| 0                      | **+0**   | **+155** |
| 1                      | **+184** | **+309** |

### Pulse generation

`PULSEGEN_` ommitted from option names.

| `LONG` 🡒<br>`SHORT` 🡓 | <br>0     | <br>1    |
|-:|:-:|:-:|
| 0                      | **+0**   | **+159** |
| 1                      | **+194** | **+352** |

### `INSGEN_REPEAT_AMOUNT` and phase modulation

`PHASEMOD_ANY` shortended to `PHASEMOD`, `INSGEN_REPEAT_AMOUNT` shortened to `REPEAT`

| `PHASEMOD` 🡒<br>`REPEAT` 🡓 |<br>0|<br>1|
|-:|:-:|:-:|
|0|**+0** |**+0** |
|1|**+20**|**+31**|
|2|**+33**|**+44**|
|3|**+39**|**+50**|
|4|**+45**|**+56**|
