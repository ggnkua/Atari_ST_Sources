/*
 * setjmp.S - EmuTOS own copy of an ANSI standard feature
 *
 * Copyright (c) 2002 EmuTOS development team
 *
 * Authors:
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

/*
 * structure of jmp_buf:
 *   0: return address
 *   4: twelve registers d2-d7/a2-a7
 */
        .global _setjmp
        .global _longjmp
        
        .data

_setjmp:
        move.l  4(sp),a0
        move.l  (sp),(a0)+
        movem.l d2-d7/a2-a7,(a0)
        move.l  #0,d0
        rts

_longjmp:
        move.l  4(sp),a0
        move.w  8(sp),d0
        beq     nonzero
        move.l  #1,d0
nonzero:
        move.l  (a0)+,d1
        movem.l (a0),d2-d7/a2-a7
        move.l  d1,(sp)
        rts

