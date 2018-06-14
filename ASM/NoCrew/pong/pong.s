; Pong 128
; Copyright 1998 Tomas Berndtsson, nobrain@nocrew.org
;            and Matti Tanttari, tatti@nocrew.org
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

	lea	scr(pc),a4
	move.l	a4,$45e.w

	dc.w	$a00a

	move.w	#640,d5
	moveq	#2,d3
	move.w	d5,d4

	lea	(320*20+160)*2(a4),a6
	lea	(320-2)*2(a4),a5
dl
	dc.w	$a000
	move.w	-344(a0),d7
	mulu.w	d5,d7
	move.w	-342(a0),d6
	mulu.w	d5,d6

	bsr.s	pads

	add.w	d3,a6
	add.w	d4,a6
	tst.w	(a6)
	beq.s	nopoint

	move.w	#7,-(sp)
	move.w	#2,-(sp)
	trap	#1

	neg.w	d3
nopoint
	cmp.l	a6,a4
	bge.s	neg_d4
	
	cmp.l	#scr+320*200*2,a6
	ble.s	downpoint	

neg_d4
	neg.w	d4
downpoint

	move.w	(a6),a3
	move.w	#$f800,(a6)

	move.w	#$25,(sp)
	trap	#14

	move.w	a3,(a6)

	bsr.s	pads
	
	bra.s	dl

pads
	lea	(a4,d7.l),a1
	bsr.s	setpad
	lea	(a5,d6.l),a1

setpad
	moveq	#32-1,d0
yl	not.l	(a1)
	lea	320*2(a1),a1
	dbra	d0,yl
	rts
	
	bss
	ds.w	1
	ds.w	10000
scr	ds.w	100000

