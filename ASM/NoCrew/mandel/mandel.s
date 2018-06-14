;    Mandelbrot zoomer, 128 bytes. 
;    Copyright 1998 Tomas Berndtsson, tomas@nocrew.org
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
;    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

	fmove.s	#-0.03125,fp2	; (2.0 - -2.0)/128
start
	moveq	#2,d3
	move.w	d3,-(sp)
	trap	#14
	move.l	d0,a0

	fmove.w	d3,fp1
	moveq	#128-1,d7
yloop
	fmove.w	d3,fp0
	moveq	#128-1,d6
xloop
	fmove.x	fp0,fp3
	fmove.x	fp1,fp4

	moveq	#32-1,d5
iter
	fmove.x	fp3,fp5
	fmove.x	fp4,fp6

	fmul.x	fp3,fp3	
	fmove.x	fp3,fp7
	fmul.x	fp6,fp6
	fsub.x	fp6,fp3
	fadd.x	fp0,fp3	; new x

	fmul.x	fp5,fp4
	fadd.x	fp4,fp4
	fadd.x	fp1,fp4	; new y

	fadd.x	fp7,fp6

	fcmp.w	#4,fp6
	fbge	no_more

	dbra	d5,iter

no_more
	move.w	d5,(a0)+

	fadd.x	fp2,fp0
	dbra	d6,xloop
	fadd.x	fp2,fp1
	lea	(640-256,a0),a0
	dbra	d7,yloop

	fadd.s	#0.001,fp2
	bra.s	start

;	clr.w	-(sp)
;	trap	#1
	
	