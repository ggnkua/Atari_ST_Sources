/*
 * Ethernat USB driver for FreeMiNT.
 * Modified for USB by David Galvez. 2010 - 2011
 *
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 *
 * Copyright (c) 2007 Henrik Gilda.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * 
 * Low level and interrupt routines for the Ethernat driver
 *
 * 2005-02-12 Henrik Gilda
 * 2000-08-02 Frank Naumann
 * 2000-03-24 Vassilis Papathanassiou
 *
 *
 */

#define RESMAGIC		0x31415926
#define _resvalid		0x426
#define _resvector		0x42a
#define _cpld_cr		0x80000023	// Ethernat cpld control reg

	.globl _old_int
	.globl _interrupt
	.globl _ethernat_int
	.globl _set_old_int_lvl
	.globl _set_int_lvl6
	.globl _hook_reset_vector
	.globl _ethernat_probe_asm,
	.globl _ethernat_probe_c
	.globl _fake_ikbd_int

	.text

	dc.l	0x58425241		// XBRA
	dc.l	0x00000000		// (no cookie)
_old_int:
	ds.l	1
_interrupt:
	move.w	(sp),oldSR
	movem.l	a0-a7/d0-d7,-(sp)
	bsr	_ethernat_int
	movem.l	(sp)+,a0-a7/d0-d7
	rte

oldSR:	ds.w	1


// Sets interrupt level to what was in the SR
_set_old_int_lvl:
	andi.w	#0x0f00,oldSR		//just keep the int lvl
	move.l	d0,-(sp)
	move.w	sr,d0
	andi.w	#0xf0ff,d0
	or.w	oldSR,d0
	move.w	d0,sr
	move.l	(sp)+,d0
	rts

// Sets interrupt level to 6
_set_int_lvl6:
	move.w	d0,-(sp)
	move.w	sr,d0
	move.w	d0,oldSR
	andi.w	#0xf0ff,d0
	ori.w	#0x0600,d0
	move.w	d0,sr
	move.w	(sp)+,d0
	rts

// Hook into the reset vector to turn off interrupt
_hook_reset_vector:
	move.l	_resvalid,oldvalid
	move.l	#RESMAGIC,_resvalid
	move.l	_resvector,oldreset
	move.l	#newreset,_resvector
	rts

	dc.l	0x58425241		// XBRA
	dc.l	0x45544E55		// ETNU
oldreset:
	dc.l	0

newreset:
	move.b	_cpld_cr,d0
	and.b	0xF9,d0			//0xFB USB, 0xF9 USB+ETH 
	move.b	d0,_cpld_cr
	move.l	oldreset,_resvector
	move.l	oldvalid,_resvalid
	jmp	(a6)

oldvalid:
	.ds.l	1

// Change bus error exception handler
// Call probe function
// Enable again the old bus error handler
_ethernat_probe_asm:
	movem.l	a0-a7/d0-d7,-(sp)
	move.w	sr,-(sp)
	move.l	8,old_berr
	lea	berr,a0
	move.l	a0,8
	move.l	sp,old_stack
	bsr	_ethernat_probe_c
berr:
	move.l	old_berr,8
	move.l	old_stack,sp
	move.w	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a7
	rts

old_stack:
	ds.l	1
old_berr:
	ds.l	1

// calls the keyboard/MIDI handler as though an interrupt has occurred
_fake_ikbd_int:
	tst.w	0x59e.w			//handle 68000/68030 difference
	beq.b	shortframe
	move.w	#0x118,-(sp)		//push vector offset
shortframe:
	pea		retaddr(pc)	// return address
	move	sr,-(sp)		//  and SR
	move.l	0x118,a0
	jmp		(a0)		//go to interrupt handler
retaddr:				// (returns here)
	rts

