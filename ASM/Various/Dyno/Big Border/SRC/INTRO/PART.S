; +======================================================================+
; | Big Border Demo - Intro screen (moving background)		 |
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

	; Set palette
	movem.l	image+2,d0-d7
	movem.l	d0-d7,PALETTE.w
	movem.l	palette,d0-d2
	movem.l	d0-d2,PALETTE+16.w

	; Initialise background
	bsr.s 	init_background
	
	; Initialise sinus tables
	lea	sinus,a0
	moveq	#22,d0
	moveq	#22,d1
	bsr	generate_sinus

loop_demo:

	; Wait for VSYNC
	bsr	vsync

	; Display moving background
	bsr 	display_image

	; Display rotating logo
	bsr 	display_logo
	
	; Next iteration
	addq.w	#1,iteration
	add.w	#16,px
	and.w	#$7FF,px
	add.w	#12,py
	and.w	#$7FF,py

	; Exit loop ?
	cmpi.w	#50*16,iteration
	bne.s	loop_demo

	rts

;#--------------------------#
;# Initialize the 16 shifts #
;#--------------------------#

init_background:

	; Raw copy of the picture
	lea	image+34,a0
	lea	background,a1
	move.w	#5400/4-1,d0
.copy:	move.l	(a0)+,(a1)+
	dbra	d0,.copy
	
	lea	background,a6

	; For every line
	move.w	#100-1,d7
.lines:
	move.l	a6,a0
	lea	5400(a6),a1

	; Shift 15 times the picture
	move.w	#15-1,d6
.shift:
	; Plane 0
	moveq	#-1,d0
	roxl	d0	
shf	set	48
	REPT	8
	move.w	shf(a0),shf(a1)
	roxl.w	shf(a1)
shf	set	shf-6
	ENDR
	move.w	(a0),(a1)
	roxl.w	(a1)
	; Plane 1
	moveq	#-1,d0
	roxl	d0
shf	set	50
	REPT	9
	move.w	shf(a0),shf(a1)
	roxl.w	shf(a1)
shf	set	shf-6
	ENDR
	; Plane 2
	moveq	#-1,d0
	roxl	d0
shf	set	52
	REPT	9
	move.w	shf(a0),shf(a1)
	roxl.w	shf(a1)
shf	set	shf-6
	ENDR

	; Next shift
	lea	5400(a0),a0
	lea	5400(a1),a1
	dbra	d6,.shift

	; Next line
	lea	54(a6),a6
	dbra	d7,.lines

	rts

;#--------------------------#
;# Display background image #
;#--------------------------#

display_image:

	lea	sinus,a0

	move.w	px,d0
	move.w	(a0,d0.w),d1	; x = sinus(px)
	
	move.w	d1,d2
	and.w	#%1111,d2		; x % 15
	mulu	#5400,d2		; (x % 15) * 5400
	
	move.w	d1,d3
	and.w	#%11110000,d3
	lsr.w	#4,d3		; offset X
	mulu	#6,d3		; * 6
	add.l	d3,d2
	
	move.w	py,d0
	move.w	(a0,d0.w),d4	; y = sinus(py)
	mulu	#54,d4		; y * 54
	add.l	d4,d2
	
	lea	background,a0
	lea	(a0,d2.l),a0

	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	moveq	#54-1,d1
.copy_y:	REPT	6
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	ENDR	
	lea	18(a0),a0
	lea	112(a1),a1
	dbra	d1,.copy_y
	
	rts

;#-----------------------#
;# Display rotating logo #
;#-----------------------#

display_logo:

	move.w	iteration,d7
	lsr.w	#2,d7
	and.w	#%1111,d7
	lsl.w	#6,d7
	
	lea	mask+34,a0
	lea	(a0,d7.w),a0

	lsl.w	#2,d7

	lea	logo+34,a1
	lea	(a1,d7.w),a1

	movea.l	screen_adr,a2
	lea	73*160+56+8*160+8(a2),a2

	moveq	#8-1,d1
.logo:	
	move.w	(a0)+,d5	; mask
	and.w	d5,(a2)
	and.w	d5,2(a2)
	and.w	d5,4(a2)
	move.w	(a0)+,d5	; mask
	and.w	d5,8(a2)
	and.w	d5,10(a2)
	and.w	d5,12(a2)
	move.w	(a0)+,d5	; mask
	and.w	d5,16(a2)
	and.w	d5,18(a2)
	and.w	d5,20(a2)
	move.w	(a0)+,d5	; mask
	and.w	d5,24(a2)
	and.w	d5,26(a2)
	and.w	d5,28(a2)

	movem.w	(a1)+,d2-d4
	or.w	d2,(a2)
	or.w	d3,2(a2)
	or.w	d4,4(a2)
	move.w	(a1)+,6(a2)

	movem.w	(a1)+,d2-d4
	or.w	d2,8(a2)
	or.w	d3,10(a2)
	or.w	d4,12(a2)
	move.w	(a1)+,14(a2)

	movem.w	(a1)+,d2-d4
	or.w	d2,16(a2)
	or.w	d3,18(a2)
	or.w	d4,20(a2)
	move.w	(a1)+,22(a2)

	movem.w	(a1)+,d2-d4
	or.w	d2,24(a2)
	or.w	d3,26(a2)
	or.w	d4,28(a2)
	move.w	(a1)+,30(a2)

	lea	160(a2),a2
	dbra	d1,.logo
	
	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w	0
px:	dc.w	0
py:	dc.w	0

; Dyno logo
mask:	incbin MASK.DAT
logo:	incbin DYNO.DAT

palette:	dc.w $0210,$0763,$0652,$0430,$0541,$0320

; Background image
image:	incbin BUBBLES.DAT

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

sinus:	ds.w 1024

background:	ds.b 5400*16

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
