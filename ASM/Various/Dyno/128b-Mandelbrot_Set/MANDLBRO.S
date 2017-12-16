; +======================================================================+
; | 128B MANDELBROT SET, by DYNO                                         |
; +======================================================================+
; | Copyright (c) 2017 Frederic Poeydomenge <dyno@aldabase.com>          |
; +----------------------------------------------------------------------+
; | This program is free software: you can redistribute it and/or modify |
; | it under the terms of the GNU General Public License as published by |
; | the Free Software Foundation, either version 3 of the License, or    |
; | (at your option) any later version.                                  |
; |                                                                      |
; | This program is distributed in the hope that it will be useful,      |
; | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
; | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
; | GNU General Public License for more details.                         |
; |                                                                      |
; | You should have received a copy of the GNU General Public License    |
; | along with this program. If not, see <http://www.gnu.org/licenses/>. |
; +======================================================================+

	OPT O+,D-,X-

ACCURACY 	= 8

XMIN	= (-235<<ACCURACY)/100
XMAX	= (120<<ACCURACY)/100
XINC	= 3			; ~= (XMAX-XMIN)/320

YMIN	= (-117<<ACCURACY)/100
YMAX	= (117<<ACCURACY)/100
YINC	= 3			; ~= (YMAX-YMIN)/200

LIMIT	= 2<<(ACCURACY+2)		; Radial limit
ITER	= 16

im	equr a5
re	equr a6
tmpi	equr d1
tmpr	equr d2
zi	equr d3
zr	equr d4
col	equr d5
ptx	equr d6
pty	equr d7

;=====================
; Draw Mandelbrot Set
;=====================

	;-------------
	; Set palette
	;-------------

	pea	palette(pc)
	move.w	#6,-(sp)
	trap	#14

	;-----------------------
	; Line-A Initialization
	;-----------------------

	dc.w	$A000
	movem.l	(a0),a1-a4		; A3=INTIN, A4=PTSIN

	;---------
	; For X&Y
	;---------

	move.w	#YMAX,im
	move.w	#200-1,pty
yLoop:	move.w	#XMAX,re
	move.w	#320-1,ptx
xLoop:
	; Initialise zr/zi to initial values
	move.w	re,zr
	move.w	im,zi

	;-------------------
	; Max 16 iterations
	;-------------------

	moveq	#ITER-1,col
nloop
	; tmpr = zr * zr
	move.w	zr,tmpr
	muls	tmpr,tmpr
	asr.l	#ACCURACY,tmpr

	; tmpi = zi * zi
	move.w	zi,tmpi
	muls	tmpi,tmpi
	asr.l	#ACCURACY,tmpi
	
	; if (zr * zr + zi * zi > 4) stop iteration
	move.w	tmpi,d0
	add.w	tmpr,d0
	asl.w	#5,d0		; cmp.w	#LIMIT,d0
	bvs.s	put_pixel		; bgt.s	put_pixel

	; zi = (2 * zr * zi) + im
	muls	zr,zi
	asr.l	#ACCURACY-1,zi
	add.w	im,zi

	; zr = tmpr - tmpi + re;
	move.w	tmpr,zr
	sub.w	tmpi,zr
	add.w	re,zr
	
	; Next iteration
	dbra	col,nloop

	;----------
	; Putpixel
	;----------

put_pixel:	move.w	col,(a3)
	movem.w	ptx/pty,(a4)
	dc.w	$A001

	;----------
	; Next X&Y
	;----------

	subq.w	#XINC,re
	dbra	ptx,xLoop
	subq.w	#YINC,im
	dbra	pty,yLoop

;===========
; Wait loop
;===========

	bra.s	*

;=========
; Palette
;=========

palette:	dc.w	$000,$100,$200,$311,$422,$533,$644,$755
	dc.w	$575,$464,$353,$242,$131,$020,$010,$000
