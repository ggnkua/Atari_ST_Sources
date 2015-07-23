; Blue, greenish, flickering, scrolling NoCrew logo
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

	lea	$45e.w,a4
	move.l	#$200000,(a4)

	move.l	#vbl,$4ce.w
	
dl	
	move.w	#$11,(sp)
	trap	#14

	and.w	#$1fe,d1
	swap	d0
	
	lea	nocrew(pc),a0
	move.w	d1,d2
	lsr.w	#4,d2
	move.w	d0,d4
	lsr.w	#5,d4
	move.l	(a0,d4.w*4),d6
	btst.l	d2,d6
	beq.s	.nokladd
		
	mulu.w	#640,d0
	lea	$200000+64-16+640*20,a0
	add.w	d1,a0
	add.l	d0,a0

	add.w	d2,(a0)
	add.w	d2,640*3+6(a0)
.nokladd
	
	bra.s	dl

vbl
ddd	add.l	#640,(a4)
	cmp.w	#$1f,(a4)
	blt.s	.turn
	cmp.w	#$21,(a4)
	blt.s	.bupp
.turn	neg.l	ddd+2
.bupp
	rts

*********
	
	data

nocrew
	;	 xxxx....xxxx....xxxx....xxxx....
	dc.l	%00000000000000001110000000100100
	dc.l	%10001001100110100001001100101100
	dc.l	%10101011110001100001010010110100
	dc.l	%11011000010000100001010010100100
	dc.l	%10001001100000101110001100100100

*********

	bss
	ds.l	20

scr
	ds.b	2100000-20*4
