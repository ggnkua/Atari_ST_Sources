;***************************************************************************
;    CECILE Device Driver
;    Copyright (C) 1999-2006  David Godec  (david.godec@online.fr)
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;
;***************************************************************************
		
		********
		TEXT
		********
		
_OLD_MEDIACH	dc.l	0
		
		********
_BIOS_MEDIACH:
		cmp.w	#1,4(sp)
		bgt	.NoFloppy
		
		jmp	([_OLD_MEDIACH.w,pc])
		
		********
.NoFloppy		
		link	a6,#0
		
		****
		sync	$43e.w
		****
		
		move.w	8(a6),d0
		move.l	$516.w,a0
		move.b	pinfo_pun(a0,d0.w),d0
		
		move.w	d0,d1
		cmp.w	#15,d1
		bgt	.ide
		
		subq.w	#8,d1
		bmi	.not_changed
		
		move.w	d1,-(sp)
		bsr	ScSelect
		
		pea	_testunit_cdb(pc)
		move.w	#6,-(sp)
		bsr	ScCmd
		
		pea	_status(pc)
		pea	_message(pc)
		pea	200.w
		bsr	ScComplete
		
		tst.b	_status(pc)
		beq.s	.not_changed
		
		****
		
		; attention 'Check Condition'
		
		move.w	8(a6),d0
		move.l	$516.w,a0
		move.b	pinfo_pun(a0,d0.w),d0
		subq.w	#8,d0
		
		jsr	GetSense(pc)
		
		ror.w	#8,d0
		
		cmp.b	#$04,d0		04:xx -> 'not ready'
		beq.s	.changed
		cmp.b	#$29,d0		29:xx -> 'power-on or reset occured'
		beq.s	.changed
		cmp.b	#$28,d0		28:xx -> 'not ready to ready transition'
		beq.s	.changed
		cmp.b	#$3A,d0		3a:xx -> 'medium not present'
		beq.s	.changed
		
		********
.not_changed
		moveq	#0,d0
.out		
		****
		sf	$43e.w
		****
		
		unlk	a6
		rts
		
		********
.changed		
		moveq	#2,d0
		bra.s	.out
		
		********
.ide
		move.w	8(a6),d1
		lsl.w	#5,d1
		lea	(DevTable.w,pc,d1.w),a0
		
		move.w	bflags(a0),d1
		bpl	.not_changed
		bclr	#15,d1
		move.w	d1,bflags(a0)
		bra	.changed
		
		********
		