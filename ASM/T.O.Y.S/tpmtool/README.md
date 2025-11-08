# TPM Tool v0.9

A tool for working with TTrak Module (TPM), TTrak Multi Module (TPN), and SNDH files with embedded TPM/TPN file and player.

TTrak is a YM2149 Chip Tracker for the Atari ST family of computers, available at https://ttrak2149.com. 

TPM Tool can show information about TPM, TPN, and SNDH files.

TPM Tool can merge one or more TPM, TPN, and SNDH files into a single TPN or SNDH file with shared instruments and one or more sub-songs.

Using TPM Tool to convert TPM, or SNDH with embedded TPM to TPN or SNDH with embedded TPN has size benefits even for a single song. This is because TPN strips unused instrument, pattern, and digi sound data.

File size examples for converting the TTrak 1.04 sample modules, this is also memory savings when using music composed with TTrak in your productions:

```
DOOMER.TPM (36Kb) -> DOOMER.TPN ( 7Kb)
LYNDON.TPM (36Kb) -> LYNDON.TPN ( 4Kb)
TOMCHI.TPM (67Kb) -> TOMCHI.TPN (17Kb)
WOBBLA.TPM (37Kb) -> WOBBLA.TPN ( 6Kb)
```

## Included Files

### TPMTOOL.TTP

The Atari TOS Takes Parameters executable. See its own Usage page for help.

Requires at least 1MB of memory.

### macos/tpmtool

A macOS executable. See its own Usage page for help.

### doc/

Various documentation

* PLAYER.md - Documentation for how to use the `player.bin` TPN player binary.
* TPN_FORMAT.md - Documenting the TPN TTrak Multi Module file format
* IFF.txt - EA IFF 85 standard
* sndhv21.txt - SNDH file structure, Revision 2.10

### player.tst/

Sample project for working with TPN files directly, builds with DevPac 3.

* main.s - Build and run this
* iff.s - Helper functions for reading EA IFF 85 files
* multi1.tpn - A TTrak Multi Module sample file containing two versions of Chroma Grid
* player.bin - A PC relative player binary for TTrak Multi Module files, see PLAYER.md

### source/

Source code for building `tpmtool`. Requires C++23 with standard library.

* artifacts - Build artifacts
* ide - Xcode project for building/debugging on macOS
* include - Header files
* Makefile - The make file
* src - Implementation files

## Acknowledgements

* Damian 'Damo' Russel - For providing information about the TPN file format and replay code
* Steven 'Tat' Tattersall - For support
* Anders 'Evl' Eriksson - For support
