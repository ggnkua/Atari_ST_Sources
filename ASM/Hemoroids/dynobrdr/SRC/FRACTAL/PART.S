; +======================================================================+
; | Big Border Demo - Fractal screen			 |
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

	lea	image1,a6
	moveq	#3-1,d6
show_image:

	clr.w	iteration

	; Set palette
	movem.l	2(a6),d0-d5/a0-a1
	movem.l	d0-d5/a0-a1,PALETTE.w

display:	; Wait for VSYNC
	bsr	vsync

	; Clear mini screen
	bsr.s	clear_screen

	; Display image
	bsr.s	display_image

	; Next iteration
	addq.w	#1,iteration

	; Wait 6 sec for each image
	cmpi.w	#50*6,iteration
	bne.s	display

	; Fade palette to black
	bsr.s	fade_pal_to_black

	; Clear mini screen
	bsr.s	clear_screen

	; Temporize
	moveq	#50-1,d5
temporize:	bsr	vsync
	dbra	d5,temporize

	lea	2626(a6),a6
	dbra	d6,show_image

	rts

;#---------------#
;# Display image #
;#---------------#

display_image:

	lea	34(a6),a0
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	moveq	#54-1,d1
	cmp.w	iteration,d1
	blt.s	.next
	move.w	iteration,d1
.next:

.copy_y:	moveq	#6-1,d0
.copy_x:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.copy_x
	lea	112(a1),a1
	dbra	d1,.copy_y

	rts

;#-------------------#
;# Clear mini screen #
;#-------------------#

clear_screen:
	moveq	#0,d7
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	moveq	#54-1,d1
.clr_y:	moveq	#6-1,d0
.clr_x:	move.l	d7,(a1)+
	move.l	d7,(a1)+
	dbra	d0,.clr_x
	lea	112(a1),a1
	dbra	d1,.clr_y
	rts

;#-----------------------#
;# Fade palette to black #
;#-----------------------#

fade_pal_to_black:
	
	moveq	#8-1,d5
fade:	bsr	vsync
	bsr	vsync
	lea	PALETTE.w,a5
	moveq	#16-1,d4
.fadcol:
	; Get color
	move.w	(a5),d0
	move.w	d0,d1
	move.w	d0,d2
	; Separate colors
	and.w	#$007,d0	; BLUE only
	and.w	#$070,d1	; GREEN only
	and.w	#$700,d2	; RED only
	; All colors in lowest nybble!
	lsr.w	#4,d1
	lsr.w	#8,d2
	; Fade
	tst.w	d0
	beq.s	.no_sub1
	subq.w	#1,d0
.no_sub1:	tst.w	d1
	beq.s	.no_sub2
	subq.w	#1,d1
.no_sub2:	tst.w	d2
	beq.s	.no_sub3
	subq.w	#1,d2
.no_sub3:	; Now re-combine the colors
	lsl.w	#8,d2
	lsl.w	#4,d1
	or.w	d1,d0
	or.w	d2,d0
	; d0 has been faded 1 step closer to black
	; Set color
	move.w	d0,(a5)+
	dbra	d4,.fadcol
	dbra	d5,fade

	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w 0

image1:	incbin FRACTAL1.DAT
image2:	incbin FRACTAL2.DAT
image3:	incbin FRACTAL3.DAT

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
