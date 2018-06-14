; Plasma - 128 bytes
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

	move.w	#2,-(sp)
	trap	#14

	move.w	#320*2,d1
	fmove.s	#0.01,fp7
	fmove.x	fp7,fp0
ss
	move.l	d0,a0
	lea	(a0,(320*198*2).l),a2
	fmove.x	fp0,fp1
	fadd.x	fp7,fp0
	fmove.x	fp1,fp3
	move.w	#198-1,d6
ll
	fsin.x	fp1,fp2
	fcos.x	fp3,fp4
	fmul.x	fp4,fp2
	fadd.x	fp7,fp1
	fadd.x	fp7,fp1
	fsub.x	fp7,fp3
	fmul.w	#320,fp2
	fmul.x	fp2,fp4
	fadd.w	#160,fp2
	fadd.x	fp2,fp4

	fmove.w	fp2,d2
	fmove.w	fp4,d4
	lea	(a0,d2.w*2),a1
	lea	(a2,d4.w*2),a3
	moveq	#127-1,d7
dl
	add.w	d7,(a1)+
	add.w	d7,(a3)+
	dbra	d7,dl

	add.w	d1,a0
	sub.w	d1,a2

	dbra	d6,ll

	bra.s	ss
	