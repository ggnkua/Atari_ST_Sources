; Fading, hiding, glittering Fuji
; Copyright 1999 Tomas Berndtsson, nobrain@nocrew.org
;                Matti Tanttari, tatti@nocrew.org
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

	clr.w	-(sp)
	move.w	#$20,-(sp)
	trap	#1

	move.l	#scr+16,$45e.w
	
	move.w	#192,$ffff820e.w

dl	
	rol.l	d7,d7
	add.b	$ffff8209.w,d7
	move.l	d7,d1


	divul.l	#172,d0:d1
	and.w	#$3fe,d1
	
	lea	tjo+1(pc),a1
	move.w	d0,d5
	add.b	(a1),d5
	lsl.w	#8,d5
	move.b	d0,d5
	add.b	(a1),d5
	moveq	#42,d2
	add.l	d2,-1(a1)

logopos	lea	$deadbeef,a0
	move.w	d1,d2
	lsr.w	#3,d2
	move.w	d2,d3
	and.w	#$7,d2
	lsr.w	#3,d3
	and.w	#$7f,d3
	move.w	d0,d4
	lsr.w	#2,d4
	mulu	#24,d4
	add.w	d4,a0
	add.w	d3,a0
	eor.w	#7,d2
	btst.b	d2,(a0)
	beq.s	.nokladd
	move.w	d5,d2
.nokladd
	add.w	(a1),d2
	lsl.l	#8,d0
	lsl.l	#2,d0
	lea	scr(pc),a0
	add.w	d1,a0
	add.l	d0,a0

	move.l	d2,(a0)+
	move.w	d2,(a0)
	
	bra.s	dl

	data
*********

	bss

tjo	ds.l	1
	ds.w	1

scr
	ds.w	270000-3
	

	