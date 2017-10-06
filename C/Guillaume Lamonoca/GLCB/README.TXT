                                -GLCB-

                   Graphic Library for 'C' Beginners
                      (freeware distribution kit)

A standard 'C' library, very easy to implement, already implemented for
many machines, very easy to use for 'C' beginners, which supplies functions
in order to handle properly: graphics, sprites, mouse events, keyboard
events, file access, real time clock usage, double buffered animations,
digitized sounds (playbacks won't freeze execution), memory management,
random function, and internal easy-use font.

Purpose: a program that uses only 'C' standard library and a basic module
will be 100% compatible with other machines even if there is a lot
of graphics, sounds or keyboard and mouse events... (you just need to
use the basic module of your machine. if it doesn't exist it will be
very easy to write). The aim is to encourage people to write  public
domain programs with 100% compatible sources and a lot of animated graphics.


Systems currently supported (tested):
ultrix,OSF/1,VMS,OpenVMS,SunOS,Windows 3.1,MsDos,System 7,AmigaDos,TOS...


contents of glcb.zip:
---------------------

/glcbase  : graphic library ('C' basic modules) for any machine
/sources  : many games or utilities you may compile with a basic module

contents of /glcbase:
---------------------

glcbase/doc.txt    : documentation (for standard basic module functions)
glcbase/doc_fr.txt : french documentation
glcbase/header.h   : header file (the same on any machine)
glcbase/exemple.c  : simple test program (call many basic module functions)

basic modules:

glcbase/x11.c      : Xwindows (X11R5) ->ultrix,VMS,OpenVMS,OSF/1,...
glcbase/x11local.c : Another display strategy (one X request per frame)

glcbase/mac.c      : Macintosh (think C 5.0)

glcbase/atari.c    : Atari (ST,STE,TT,FALCON) (laser C)
glcbase/ataripur.c : Atari (ST,STE,TT,FALCON) (Pure C)
glcbase/ataripu2.s
glcbase/falcon.c   : Falcon (Pure C)
glcbase/falcon2.s
glcbase/falcontc.c : Falcon (Pure C)
glcbase/falcont2.s

glcbase/amiga500.c : Amiga 500/2000 (aztec C)
glcbase/amiga.c    : Amiga (all) (lattice C)
glcbase/amiga.lha  : Amiga (all) (more portable version)

glcbase/pc.c       : PC Windows 3.1 + MultiMedia lib (BC++ or TC++)
glcbase/pcvga.c    : PC MsDos + VGA 256ko (TC or TC++)
glcbase/pcvga2.asm


contents of /sources (modified sources to link with a basic module):
--------------------------------------------------------------------

sources/bldrdash/  : sources of boulder dash (X11 public domain game xbd)
sources/demineur/  : sources of xdemineur (X11 public domain game)
sources/sokoban/   : sources of xsokoban3 (enhanced X11 public domain game)

sources/qbert      : sources of a remake of Q*Bert ('original' adaptation)
sources/kakanoid   : sources of a remake of Arkanoid ('original' adaptation)
sources/jewel      : sources of a remake of xjewel ('original' adaptation)
sources/blockout   : sources of a remake of Blockout ('original' adaptation)

sources/utils      : sources of many utilities (drawing,etc...)

sources/warzone    : sources of warzone (orginal game)
                     (2 players game. real time solid 3D objects)

Caution: many games save scores. If you use floppy disks unprotect them!


quick start:
------------

- get your machine basic module
- get header.h
- get exemple.c
- get doc.txt
- read the beginning of each file
- follow the basic module instructions
- build up and run the exemple program



GLCB team:
----------

ROY Gilles		Supelec (94)	(kakanoid)
BOERI franck		Supelec (95)	(blockout)
JOUIN Christophe	Supelec (94)	(x11,amiga)
ROY Regis		Supelec (95)	(atari)
LAMONOCA Guillaume	Supelec (94)

For any question:

Guillaume LAMONOCA
7 allee lucien Mazan
13500 Martigues
FRANCE

(bal GL on some french transpac servers (minitel))

