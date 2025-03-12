# RNC ProPack 2.14

This is a mirror of Rob Northen Computing's (RNC) ProPack compression tool, which handles the RNC compression format created by Rob Northen in 1991.

This is the official RNC 2.14 package, containing a packer DOS binary and assembly decoding modules for several platforms.

For the manual, read `PROPACK.DOC`. I have also added a plain text version of the manual, `PROPACK.TXT`.

## Mirrors

This is a GitHub repo. The package is also available elsewhere:

* [Jeff Frohwein's Game Boy website](http://www.devrs.com/gb/files/libs.html)
* [Aminet](http://aminet.net/package/util/pack/RNC_ProPack) (note that although this page claims it hosts v2.08, it's the exact same package as this)

## Resources

* [MultimediaWiki](https://wiki.multimedia.cx/index.php/RNC_ProPack)'s article about RNC ProPack.
* [Sega Retro](http://segaretro.org/Rob_Northen_compression) has a good article on how RNC works.
* Decompiled source of RNC ProPack: [lab313ru/rnc_propack_source](https://github.com/lab313ru/rnc_propack_source)

## Contents

```
LIST                       - text file with list of package files
PPIBM.EXE                  - file packer (286 version)
PPAMI.EXE                  - file packer (amiga version)
PROPACK.DOC                - PRO-PACK manual (referred to as PP.DOC in LIST)
PROPACK.TXT                - Plain text version of PRO-PACK manual (not part of original archive)
SOURCE (dir)               - Assembler unpack source files
    IBMPC (dir)
        RNC_1.ASM          - 8086 Method 1
        RNC_2.ASM          - 8086 Method 2
    MC68000 (dir)
        RNC_1C.S           - MC68000 Method 1 Compact Version (consoles)
        RNC_2C.S           - MC68000 Method 2 Compact Version (consoles)
        RNC_1.S            - MC68000 Method 1
        RNC_2.S            - MC68000 Method 2
    GAMEBOY (dir)
        RNC_2.S            - Z80 Gameboy Method 2
    SUPERNES (dir)
        RNC_1.S            - 65816 Method 1
        RNC_2.S            - 65816 Method 2
    LYNX (dir)
        RNC.MAC            - RNC macros
        RNC_1.SRC          - 65C02 Atari Lynx Method 1
        RNC_2.SRC          - 65C02 Atari Lynx Method 2
    MIPS R4300
        RNC_1.ASM          - Mips R4300 Method 1
```
