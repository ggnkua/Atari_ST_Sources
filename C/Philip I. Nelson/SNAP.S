
* SNAP.S                         Philip I. Nelson  8/20/86   *

* Machine language portion of Snapshot program. This module  *
* has two parts. The first is called by the C module.  All   *
* that it does is redirect the ST's hardcopy vector to the   *
* second part of the program, which waits in memory until    *
* you press Alt-Help. At that point, it saves the screen     *
* image in an area called _scrbuff, which is also known to   *
* the C module. Other common variables include _palbuff,     *
* which stores the current color palette, _rez, which holds  *
* the screen resolution, and _picflag, which tells the C     *
* module when there is a screen waiting to be saved.         *


* Define these as globals, so the C part can find them when  *
* we get around to linking. They also appear in the .bss.    *

.globl _scrbuff
.globl _picflag
.globl _palbuff
.globl _rez

* Must also give the program itself a global name, since we  *
* want to call it from C as the function snap();             *

.globl _snap
_snap:

* Enter supervisor mode so we can access system variables    *

move.l #0,-(sp)
move.w #$20,-(sp)
trap   #1
addq.l #6,sp

* Point the hardcopy vector to the real program.             *

move.l #myprog,$502

* Exit supervisor mode.                                      *
move.l d0,-(sp)
move.w #$20,-(sp)
trap   #1
addq.l #6,sp

* Terminate with rts, not with GEMDOS Term or Keep Process.  *

rts

* Here's where the real program starts.                      *

myprog:

* Save registers so we don't turn the universe into plasma.  *

movem.l d0-d6/a0-a4,-(sp)

* Get current screen resolution from $44c, sshiftmod.        *
* 0 = low, 1 = medium, 2 = high resolution.                  *
* Note that it's not necessary to enter supervisor mode      *
* before we access this location. Since we're working off    *
* the VBI, grand things are possible.                        *

clr.w   _rez
move.b  $44c, _rez+1

* Save 32 bytes of palette data, reading video registers.    *

move.l #$ff8240,a0        * $ff8240 = chip address.          *
lea    _palbuff,a1        * Our storage array.               *
move   #15,d0             * Store 16 words.                  *
savepal:
move.w (a0)+,d1
and.w  #$777,d1           * Only lower $777 is significant.  *
move.w d1,(a1)+
dbra   d0,savepal

* The system variable $44e points to the current screenbase. *

move.l $44e,a0

* Point to our old friend, _scrbuff.                         *

lea _scrbuff,a1

* Store 32000 bytes of screen memory in _scrbuff.            *

move.w #7999,d0
svscr:
move.l (a0)+,(a1)+
dbra   d0,svscr

* Invert the palette so everyone knows something happened.   *

move.l #$ff8240,a1        * $ff8240 = chip address.          *
lea    _palbuff,a0        * Our storage array.               *
move   #15,d0             * Store 16 words.                  *
invert:
move.w (a0)+,d1
eor.w  #$ffff,d1          * Invert.                          *
move.w d1,(a1)+
dbra   d0, invert

delay:
move.w #1,d0
moon:
move.w #$ffff,d1
loon:
dbra   d1,loon
dbra   d0,moon

* Restore palette. Easier than going the other way....        *
* Store address of new palette in colorptr at $45a.           *

move.l #_palbuff,$45a

* Set _picflag so the C module knows it has something to save *

move.w #1,_picflag

* Restore registers so nobody else gets upset.                *

movem.l (sp)+,d0-d6/a0-a4

* Set the hardcopy flag to -1 so it looks like normal.        *

move #$ffff,$4ee

rts

.data
.bss

_picflag:
.ds.w 1

_rez:
.ds.w 1

_palbuff:
.ds.w 16

_scrbuff:
.ds.w 16000

