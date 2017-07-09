; +======================================================================+
; | Big Border Demo - 3D Glenz screen			 |
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

	opt	m+,o-,x+,p=68000

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	INCLUDE	CORE.S

;#---------------#
;# Runs the demo #
;#---------------#

run_demo:

	IFEQ	PROD-0
	SET_PHYSBASE screen_buf,screen_adr
	ELSE
	move.l	$260.w,d0
	move.l	d0,screen_adr
	move.b	d0,VIDEO_ADR_LOW.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_MID.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_HIGH.w
	ENDC

	; Clear screen
	movea.l	screen_adr,a1
	moveq	#0,d0 
	move.w	#8000-1,d1
.clear:	move.l	d0,(a1)+
	dbra	d1,.clear

	; Fade in
	bsr	clear_mini
	move.w	#$010,PALETTE+8*2.w
	bsr	vsync
	bsr	vsync
	move.w	#$020,PALETTE+8*2.w
	bsr	vsync
	bsr	vsync

	; Set palette
	movem.l	palette,d0-d7
	movem.l	d0-d7,PALETTE.w

loop_demo:	; Wait for VSYNC
	bsr	vsync

	; Clear mini screen
	bsr	clear_mini

	; Compute cube Y pos
	lea	curve,a2
	move.w	iteration,d0
	move.b	(a2,d0.w),d3
	ext.w	d3
	move.w	d3,d4
	neg.w	d4
	addq.w	#2,d4
	muls	#16,d4

	; Start address of glenz object
	lea	glenz+34,a0
	move.w	iteration,d0
	and.w	#$00FF,d0
	mulu	#896,d0
	lea	16(a0,d0.l),a0
	add.l	d4,a0

	; Display glenz object
	movea.l	screen_adr,a1
	lea	73*160+56+8(a1),a1
	moveq	#54-1,d1
	add.w	d3,d1
	subq.w	#1,d1
	blt.s	.nocopy
.copy_y:	moveq	#4-1,d0
.copy_x:	move.l	(a0)+,(a1)+
	addq.l	#4,a1
	dbra	d0,.copy_x
	lea	128(a1),a1
	dbra	d1,.copy_y
.nocopy:	
	; Next frame
	addq.w	#1,iteration

	; Exit loop ?
	cmp.w	#end_curve-curve,iteration
	bne.s	loop_demo

	; Temporize
	moveq	#50-1,d7
temporize:	bsr	vsync
	dbra	d7,temporize

	; Fade out
	bsr.s	clear_mini
	move.w	#$020,PALETTE+8*2.w
	bsr	vsync
	bsr	vsync
	move.w	#$010,PALETTE+8*2.w
	bsr	vsync
	bsr	vsync

	rts

;#-------------------#
;# Clear mini screen #
;#-------------------#

clear_mini:
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	moveq	#54-1,d1
.clr_y:	moveq	#6-1,d0
.clr_x:	clr.l	(a1)+
	clr.w	(a1)+
	move.w	#-1,(a1)+
	dbra	d0,.clr_x
	lea	112(a1),a1
	dbra	d1,.clr_y
	rts
	
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w 0

palette:	dc.w $000,$001,$002,$003
	dc.w $011,$022,$033,$044
	dc.w $021,$310,$531,$753
	dc.w $110,$220,$330,$440

glenz:	incbin OBJECT.DAT

curve:	include ..\WIRE\CURVE.S
end_curve:

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
