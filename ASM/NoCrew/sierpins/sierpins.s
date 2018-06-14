; Power morphing Sierpinski's triangle - 128 bytes
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

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	scr(pc),a3
	move.l	a3,$45e.w	

	lea	corners(pc),a4
	moveq	#80,d6
	asl.l	d6
	moveq	#0,d7

	move.w	#160-1,d3
	moveq	#1,d4
dl
	move.w	#15707,d5
dlb
	eor.w	#$21,d4

	move.w	#$11,(sp)
	trap	#14
	divul	#3,d0:d1
	add.w	(a4,d0.w*4),d6
	add.w	2(a4,d0.w*4),d7
	asr.w	d6
	asr.w	d7
	move.w	d7,d0
	mulu.w	#320,d0
	add.l	d6,d0
	move.w	(a3,d0.l*2),d1
	cmp.w	#$7df,d1
	bge.s	nomore
	add.w	d4,(a3,d0.l*2)
nomore
	dbra	d5,dlb

	addq.w	#2,a4
	addq.w	#2,(a4)+
	addq.w	#2,(a4)+
	subq.w	#2,(a4)+
	subq.w	#2,(a4)+
	subq.w	#2,(a4)+
	lea	-12(a4),a4	

	dbra	d3,dl

	clr.w	(sp)
	trap	#1
	
corners	dc.w	159,0
	dc.w	0,399
	dc.w	319,399

	bss
scr	ds.w	200000

	