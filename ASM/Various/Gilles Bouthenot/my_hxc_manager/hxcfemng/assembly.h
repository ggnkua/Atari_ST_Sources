#ifndef __QUICKERSORT_H__
#define __QUICKERSORT_H__

/*
//
// Copyright (C) 2009, 2010, 2011 Jean-Francois DEL NERO
//
// This file is part of the HxCFloppyEmulator file selector.
//
// HxCFloppyEmulator file selector may be used and distributed without restriction
// provided that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// HxCFloppyEmulator file selector is free software; you can redistribute it
// and/or modify  it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// HxCFloppyEmulator file selector is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//   See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with HxCFloppyEmulator file selector; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//
*/

extern void quickersort();
#define quickersort(nbEntries, offset, base)              \
__extension__                           \
({                                      \
__asm__ volatile                        \
(                                       \
"move.l   %3,-(sp)\n\t"                    \
"move.w   %2,-(sp)\n\t"                    \
"move.w   %1,-(sp)\n\t"                    \
"jsr      (%0)\n\t"                         \
"addq.l    #8,sp"                          \
: /* outputs "=r"(retvalue) */           \
: /* inputs   */ "a"(quickersort), "g"((short) nbEntries), "g"((short)offset), "g"((unsigned char *)base) \
: /* clobbers */ "d0", "d1", "d2", "a0", "a1", "a2" \
  AND_MEMORY                            \
);                                      \
})

extern void memsetword();
#define memsetword(adr, wordvalue, length )              \
__extension__                           \
({                                      \
__asm__ volatile                        \
(                                       \
"move.l   %3,-(sp)\n\t"                    \
"move.w   %2,-(sp)\n\t"                    \
"move.l   %1,-(sp)\n\t"                    \
"jsr      (%0)\n\t"                         \
"lea      10(sp),sp"                          \
: /* outputs "=r"(retvalue) */           \
: /* inputs   */ "a"(memsetword), "g"((unsigned char *) adr), "g"((short) wordvalue), "g"((long) length) \
: /* clobbers */ "d0", "d1", "a0", "a1" \
  AND_MEMORY                            \
);                                      \
})

extern short setColor();
#define setColor(index, value)              \
__extension__                           \
({                                      \
register short retvalue __asm__("d0");  \
__asm__ volatile                        \
(                                       \
"move.w   %3,-(sp)\n\t"                    \
"move.w   %2,-(sp)\n\t"                    \
"jsr      (%1)\n\t"                         \
"addq.l   #4,sp"                          \
: /* outputs  */ "=r"(retvalue)           \
: /* inputs   */ "a"(setColor), "g"((short) index), "g"((short) value) \
: /* clobbers */ __CLOBBER_RETURN("d0") "d1", "d2", "d3", "d4", "d5", "d6", "d7", "a0", "a1", "a2", "a3", "a4" \
/*  AND_MEMORY */                       \
);                                      \
retvalue;                               \
})

#endif
