; Pyro - 128 bytes
; Copyright 1998 Tomas Berndtsson, nobrain@nocrew.org
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

	moveq	#$20,d5
	clr.l	-(sp)
	move.w	d5,-(sp)
	trap	#1
	lea	(scr,pc),a3
	move.l	a3,$45e.w	

	addq.l	#5,d5

dl
	fsub.x	fp0,fp0
	moveq	#127,d4
	move.l	d4,d6

; fire away...
l1
	fsincos.x	fp0,fp1:fp2
	fmul.w	d5,fp1
	fmove.w	d6,fp7
	fmul.x	fp7,fp2
	fadd.x	fp7,fp1
	fsub.x	fp2,fp7
	
	bsr.s	sp

	fadd.s	#0.01237,fp0
	dbra	d4,l1

; ... and BOOM!
l2
	fsincos.x	fp0,fp1:fp7
	fmul.w	d4,fp1
	fmul.w	d4,fp7
	fadd.w	d6,fp1
	fadd.w	d4,fp7
	bsr.s	sp
	fadd.w	d6,fp0
	addq.w	#1,d4
	cmp.w	d6,d4
	blt.s	l2

	bra.s	dl
	
sp
	fmove.l	fp7,d7
	fmove.l	fp1,d1
	muls.w	#320,d7
	add.l	d1,d7
;	move.l	d7,(a3,d7.l*2)
	not.l	(a3,d7.l*2)
	move.w	d5,-(sp)
	trap	#14
	addq.w	#2,sp
	clr.l	(a3,d7.l*2)
	rts
	
	bss
scr	ds.w	100000

	