/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2011
 *
 * HDDRIVER module code by Christian Zietz.
 * Note: For HDDRIVER modules to work, entry.S must be first in Makefile.objs
 * 
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *                                        2004 F.Naumann & O.Skancke
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

	.globl	__start
	.globl	__base
	.globl	_init
	.globl	__crtinit
	.global __PgmSize
	.globl _isHddriverModule
	.globl ismodule


	.bss
savsp:
	ds.l	1
__PgmSize:
	ds.l	1

	.text

__start:
	bra.w nomodule			//started as regular program

	// module entry
#ifdef __mcoldfire__
	move.b #0xff,d0
	move.b d0,ismodule
#else
	st ismodule			//started as module (Set always True)
#endif

	move.l	#0x1c,d0		// header size
	add.l	2(a2),d0		// text size
	add.l	6(a2),d0		// data size
	movea.l	a2,a0			// program start
	adda.l	d0,a0			// bss start
	add.l	10(a2),d0		// bss size
	move.l	10(a2),d1		// bss size
	bra.s	clrbss
loop:
	clr.b	(a0)+			// clear BSS
clrbss:
	subq.l	#1,d1
	bpl		loop

	move.l	sp,savsp
	move.l	a0,sp			// end of bss
	move.l	#STACKSIZE,d1
	adda.l	d1,sp			// make room for stack
	add.l	d1,d0
	move.l	d0,__PgmSize	// total program size
#ifdef __mcoldfire__
	lea	-44(sp),sp
	movem.l	d2-d7/a2-a6,(sp)	// D2-D7 and A2-A6 must not be modified
#else
	movem.l	d2-d7/a2-a6,-(sp)	// D2-D7 and A2-A6 must not be modified
#endif
	// Mshrink
	move.l	d0,-(sp)
	pea		(a2)
	move.w	#0,-(sp)
	move.w	#74,-(sp)
	trap	#1
	lea		0xC(sp),sp

	pea		0				// environ
	pea		0				// argv
	clr.w	-(sp)			// argc
	jsr		_init
	lea		10(sp),sp

	tst.w	d0				// init returned an error?
	beq		out

	pea		(a2)			// error = Mfree
	move	#0x49,-(sp)
	trap	#1
	addq.l	#6,sp
out:
#ifdef __mcoldfire__
	movem.l	(sp),d2-d7/a2-a6
	lea	44(sp),sp
#else
	movem.l	(sp)+,d2-d7/a2-a6
#endif
	move.l	savsp,sp
	rts

__base:
	ds.l	1

nomodule:
	// Original startup code in entry.S
	move.l	0x4(sp),a0		// basepage address
	move.l	a0,__base

	movel	a0@(4),d0		// get _base->p_hitpa
	bclr	#0,d0			// round off
	movel	d0,sp			// set stack (temporarily)
	jmp	__crtinit			// in crtinit.c

_isHddriverModule:
	clr d0
	move.b ismodule,d0
	rts

	.data

ismodule:	ds.b 1
