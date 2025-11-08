# TPN File Format Specification

## Overview

TPN (TTrak Multi Module) is an EA IFF 85 file format for storing Atari ST YM2149 music data with **one shared instrument set** and **one or more songs**. The format is designed for multi-song compilations where songs share the same instruments but have different patterns and sequences.

The name TPN was chosen as the next increment from TPM (M→N).

## File Structure

TPN files follow the EA IFF 85 specification with this hierarchy:

```
FORM # { TPN1      // Structured group chunk for a TPN v1 file.
   AUTH # {        // [Optional] Composer/Author metadata
       string
   } ?
   (C)  # {        // [Optional] Copyright metadata
       string
   } ?
   ANNO # {        // [Optional] Annotation (tool name)
       string
   } ?
   TPIS # {        // Instrument Set chunk
       InstrumentSet body
   }
   LIST # { TPSN   // List group chunk of songs
       NAME # {    // [Optional] Song title
           string
       } ?
       TPSN # {    // One or more song chunks
           Song body
       } +
   }
}
```

**Note:** Even single-song files must wrap songs in a LIST chunk for consistent parsing.

### Example Block Diagram

Block diagram layout for a TPN file with metadata and three songs.

```
┌────────────────────────────────────────────────────┐
│ Structured chunk for TPN v1 file                   │
├────────────────────────────────────────────────────┤
| header[4] = "FORM"                                 |
| size (uint32_t)                                    |
| type[4] = "TPN1"                                   |
│  ┌───────────────────────────────────────────────┐ │
│  │ [Optional] Metadata chunks                    │ │
│  ├───────────────────────────────────────────────┤ │
│  │ header[4] = "AUTH"                            │ │
│  │ size (uint32_t)                               │ │
│  │ composer (null-terminated string)             │ │
│  ├───────────────────────────────────────────────┤ │
│  │ header[4] = "(C) "                            │ │
│  │ size (uint32_t)                               │ │
│  │ copyright (null-terminated string)            │ │
│  ├───────────────────────────────────────────────┤ │
│  │ header[4] = "ANNO"                            │ │
│  │ size (uint32_t)                               │ │
│  │ annotation (null-terminated string)           │ │
│  └───────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────┐ │
│  │ Instrument Set chunk                          │ │
│  ├───────────────────────────────────────────────┤ │
│  │ header[4] = "TPIS"                            │ │
│  │ size (uint32_t)                               │ │
│  │ instrument_count (uint8_t)                    │ │
│  │ digi_slot_count (uint8_t)                     │ │
│  │ [Instrument data × instrument_count]          │ │
│  │ [DigiData × digi_slot_count]                  │ │
│  └───────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────┐ │
│  │ List group chunk of songs                     │ │
│  ├───────────────────────────────────────────────┤ │
|  | header[4] = "LIST"                            | |
|  | size (uint32_t)                               | |
|  | type[4] = "TPSN"                              | |
│  │   ┌─────────────────────────────────────────┐ │ │
│  │   │ [Optional] Song #1 Name chunk           │ │ │
│  │   ├─────────────────────────────────────────┤ │ │
│  │   │ header[4] = "NAME"                      │ │ │
│  │   │ size (uint32_t)                         │ │ │
│  │   │ title (null-terminated string)          │ │ │
│  │   └─────────────────────────────────────────┘ │ │
│  │   ┌─────────────────────────────────────────┐ │ │
│  │   │ Song chunk #1                           │ │ │
│  │   ├─────────────────────────────────────────┤ │ │
│  │   │ header[4] = "TPSN"                      │ │ │
│  │   │ size (uint32_t)                         │ │ │
│  │   │ song_length, song_restart, tick_speed   │ │ │
│  │   │ pattern_count                           │ │ │
│  │   │ groove_seq[16]                          │ │ │
│  │   │ sequence_data[256]                      │ │ │
│  │   │ [Pattern data × pattern_count]          │ │ │
│  │   └─────────────────────────────────────────┘ │ │
│  │   ┌─────────────────────────────────────────┐ │ │
│  │   │ [Optional] Song #2 Name chunk           │ │ │
│  │   ├─────────────────────────────────────────┤ │ │
│  │   │ header[4] = "NAME"                      │ │ │
│  │   │ [NAME data...]                          │ │ │
│  │   └─────────────────────────────────────────┘ │ │
│  │   ┌─────────────────────────────────────────┐ │ │
│  │   │ Song chunk #2                           │ │ │
│  │   ├─────────────────────────────────────────┤ │ │
│  │   │ [Song #2 data...]                       │ │ │
│  │   └─────────────────────────────────────────┘ │ │
│  │   ┌─────────────────────────────────────────┐ │ │
│  │   │ [Optional] Song #3 Name chunk           │ │ │
│  │   └─────────────────────────────────────────┘ │ │
│  │   ┌─────────────────────────────────────────┐ │ │
│  │   │ Song chunk #3                           │ │ │
│  │   ├─────────────────────────────────────────┤ │ │
│  │   │ [Song #3 data...]                       │ │ │
│  │   └─────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

## Chunk Descriptions

### `FORM` `TPN1` (Group Chunk)

Top-level container for the entire TPN file. The version `TPN1` indicates format version 1.

**Structure:**

- `header[4]`: 4CC identifier "FORM"
- `size`: Size of entire file minus 8 bytes (for FORM header)
- `type[4]`: Format identifier "TPN1"

### `AUTH` (Metadata Chunk - Optional)

Contains composer/author name.

**Structure:**

- `header[4]`: 4CC identifier "AUTH"
- `size`: Size of chunk body (string length + 1 for null terminator)
- `composer`: Null-terminated string
- Padding to even boundary if needed

**Note:** Written only when metadata is enabled and composer is non-empty.

### `(C) ` (Metadata Chunk - Optional)

Contains copyright information.

**Structure:**

- `header[4]`: 4CC identifier "(C) " (note trailing space)
- `size`: Size of chunk body (string length + 1)
- `copyright`: Null-terminated string
- Padding to even boundary if needed

**Note:** Written only when metadata is enabled and copyright is non-empty.

### `ANNO` (Metadata Chunk - Optional)

Contains annotation, typically the tool that created the file.

**Structure:**

- `header[4]`: 4CC identifier "ANNO"
- `size`: Size of chunk body (string length + 1)
- `annotation`: Null-terminated string (e.g., "tpmtool")
- Padding to even boundary if needed

**Note:** Written when metadata is enabled. Current implementation always writes "tpmtool".

### `TPIS` (Instrument Set Chunk - Required)

Contains all instruments and their associated digital sound data.

**Structure:**

- `header[4]`: 4CC identifier "TPIS"
- `size`: Size of chunk body (excluding header + size field)
- `instrument_count`: Number of instruments (1-255)
- `digi_slot_count`: Number of digital sound slots (0-32)
- `instruments[]`: Array of Instrument structures (1030 bytes each × instrument_count)
- `digi_data[]`: Variable-size digital sound samples (digi_slot_count entries)
- Padding to even boundary if needed

**Instrument Structure** (1030 bytes):

- 1030 bytes of instrument data (excludes the 16-byte name field from TPM's 1046-byte format)
- Contains waveform, envelope, and other synthesis parameters
- Instruments use 1-based indexing (1-32), index 0 is invalid / no note

**Digital Sound Data**:

Each digi sound is a variable-length chunk:

- Minimum 1 byte: `0x80` (end marker for empty sound)
- Otherwise: sound sample data followed by `0x80` end marker
- Sounds use 0-based indexing (0-31)

### `LIST` `TPSN` (Group Chunk - Required)

Container for one or more song chunks. The `LIST` type `TPSN` indicates it contains `TPSN` data chunks and optional `NAME` chunks.

**Structure:**

- `header[4]`: 4CC identifier "LIST"
- `size`: Size of chunk body
- `type[4]`: List type identifier "TPSN"
- Contents: Alternating NAME (optional) and TPSN chunks
- Padding to even boundary if needed

### `NAME` (Metadata Chunk - Optional)

Contains song title. Appears immediately before its corresponding TPSN chunk.

**Structure:**

- `header[4]`: 4CC identifier "NAME"
- `size`: Size of chunk body (string length + 1)
- `title`: Null-terminated string
- Padding to even boundary if needed

**Note:** Written only when metadata is enabled and song title is non-empty.

### `TPSN` (Song Chunk - Required)

Individual song data with patterns and sequence information.

**Structure:**

- `header[4]`: 4CC identifier "TPSN"
- `size`: Size of chunk body
- `song_length`: Number of entries in sequence_data (1-255)
- `song_restart`: Loop point position (0-254)
- `tick_speed`: Playback speed in Hz (typically 50 or 200)
- `pattern_count`: Number of patterns following (1-255)
- `groove_seq[16]`: Groove timing sequence (16 bytes)
- `sequence_data[256]`: Pattern playback order (256 bytes, zero-padded after song_length)
- `patterns[]`: Array of Pattern structures (1024 bytes each × pattern_count)
- Padding to even boundary if needed

**Pattern Structure** (1024 bytes):

- 64 rows × 4 channels × 4 bytes per row = 1024 bytes
- Each row contains: note, instrument, effect command, effect parameter
- Pattern indices in sequence_data are 0-based (0-254)

## Chunk Ordering

EA IFF 85 does not enforce ordering of chunks. In the list of `TPSN` chunks a `NAME` chunk is related to the next `TPSN` chunk.

## Implementation Notes

- **Instrument Indexing**: Uses 1-based indexing (1-32), not 0-based. Index 0 is invalid / no note.
- **Pattern Indexing**: Uses 0-based indexing (0-254). Patterns are referenced by index within each song's pattern array.
- **Digi Sound Indexing**: Uses 0-based indexing (0-31). Index references the deduplicated digi_data array.
- **IFF85 Parsing**: Standard IFF85 parsers can navigate the chunk structure
- **Chunk Alignment**: All chunk bodies are padded to even byte boundaries per IFF85 specification
- **LIST Requirement**: Single-song files must still use `LIST` structure for consistency
- **Metadata Flag**: Files can be written with or without metadata chunks. Minimal files contain only `TPIS`, and `LIST` with `TPSN` chunks.
- **String Chunks**: `AUTH`, `(C) `, `ANNO`, and `NAME` chunks comntain null-terminated strings

## Format Version

Current version: **TPN1**

Future versions may increment the version identifier (TPN2, etc.) for backward-incompatible changes.

## Examples

### Minimal File Structure (No Metadata)
```
FORM TPN1
  TPIS (instruments and digi data)
  LIST TPSN
    TPSN (song #1)
    ...
```

### Full File Structure (With Metadata)
```
FORM TPN1
  AUTH (composer)
  (C)  (copyright)
  ANNO (tool name)
  TPIS (instruments and digi data)
  LIST TPSN
    NAME (song #1 title)
    TPSN (song #1)
    NAME (song #2 title)
    TPSN (song #2)
    ...
```
