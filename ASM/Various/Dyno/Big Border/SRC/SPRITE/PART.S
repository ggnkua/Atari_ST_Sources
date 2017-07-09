; +======================================================================+
; | Big Border Demo - Sprite record screen			 |
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

SPRITES	set 128

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
	
	; Initialise background
	bsr.s 	init_image

	; Initialise sinus tables
	lea	cosTabX,a0
	moveq	#16,d0
	moveq	#44,d1
	bsr	generate_sinus
	lea	sinTabX,a0
	moveq	#28,d0
	moveq	#0,d1
	bsr	generate_sinus
	lea	cosTabY,a0
	moveq	#7,d0
	moveq	#23,d1
	bsr	generate_sinus
	lea	sinTabY,a0
	moveq	#16,d0
	moveq	#0,d1
	bsr	generate_sinus

	; Initialise wave values
	move.w  	#0,pxa1
	move.w  	#0,pxa2
	move.w  	#0,pya1
	move.w  	#0,pya2

	; Compute for first loop
	bsr 	compute_sprites

loop_demo:

	; Wait for VSYNC
	bsr	vsync

	; Display sprites
	bsr.s	clear_screen
	bsr	display_sprites
	bsr 	compute_sprites

	; Next iteration
	addq.w	#1,iteration

	; Exit loop ?
	cmpi.w	#50*15,iteration
	bne.s	loop_demo

	rts

;#--------------------#
;# Display background #
;#--------------------#

init_image:

	movea.l	screen_adr,a1
	moveq	#0,d0 
	move.w	#8000-1,d1
.clear:	move.l	d0,(a1)+
	dbra	d1,.clear

	lea	image+34,a0
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	moveq	#54-1,d1
.copy_y:	moveq	#6-1,d0
.copy_x:	addq.l	#4,a1
	move.l	(a0)+,(a1)+
	dbra	d0,.copy_x
	lea	112(a1),a1
	dbra	d1,.copy_y

	movem.l	palette,d0-d7
	movem.l	d0-d7,PALETTE.w
	
	rts

;#----------------------------#
;# Clear Screen (2 bitplanes) #
;#----------------------------#

clear_screen:

	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	
	moveq	#0,d2
	moveq	#54-1,d1
.clear:	move.l	d2,(a1)
	move.l	d2,8(a1)
	move.l	d2,16(a1)
	move.l	d2,24(a1)
	move.l	d2,32(a1)
	move.l	d2,40(a1)
	lea	160(a1),a1
	dbra	d1,.clear
	
	rts

;#--------------------------#
;# Compute sprite positions #
;#--------------------------#

compute_sprites:

	lea	sprites,a5
	
	; Initialise wave values
	move.w  	pxa1,pxb1
	move.w  	pxa2,pxb2
	move.w  	pya1,pyb1
	move.w  	pya2,pyb2

	movea.l 	screen_adr,a6
	moveq	#SPRITES-1,d7
compute_sprite:

	; Compute X

	lea	cosTabX,a0
	move.w	pxb1,d0
	move.w	(a0,d0.w),d5	; x = cosTabX[mod(pxb1,PILEN)]

	lea	sinTabX,a0
	move.w	pxb2,d0
	add.w	(a0,d0.w),d5	; x += sinTabX[mod(pxb2,PILEN)]
	
	add.w	#112,d5

	; Compute Y

	lea	cosTabY,a0
	move.w	pyb1,d0
	move.w	(a0,d0.w),d6	; x = cosTabY[mod(pyb1,PILEN)]

	lea	sinTabY,a0
	move.w	pyb2,d0
	add.w	(a0,d0.w),d6	; x += sinTabY[mod(pyb2,PILEN)]

	add.w	#73,d6

	; Address of the sprite routine
	lea	table,a3
	move.w	d5,d3
	and.w	#$000F,d3
	lsl.w	#2,d3
	move.l	(a3,d3.w),(a5)+

	; Compute offset
	lsr.w	#1,d5
	and.w   	#$7FF8,d5		; x / 16 * 8 => d5
	mulu    	#160,d6		; y * 160 => d6
	add.w	d5,d6		; offset
    
	; Compute screen address
	lea     	(a6,d6.w),a1
	move.l	a1,(a5)+

	; Inc angles (during the frame)
	add.w	#64,pxb1
	and.w	#$7FF,pxb1
	sub.w	#44,pxb2
	bge.s	sub1
	add.w	#1024*2,pxb2
sub1:
	add.w	#36,pyb1
	and.w	#$7FF,pyb1
	sub.w	#56,pyb2
	bge.s	sub2
	add.w	#1024*2,pyb2
sub2:
	dbra	d7,compute_sprite

	; Inc global angles
	add.w	#24,pxa1
	and.w	#$7FF,pxa1
	add.w	#14,pxa2
	and.w	#$7FF,pxa2
	sub.w	#10,pya1
	bge.s	sub3
	add.w	#1024*2,pya1
sub3:
	add.w	#20,pya2
	and.w	#$7FF,pya2

	rts

;#-----------------#
;# Display sprites #
;#-----------------#

display_sprites:
	lea	sprites,a5
	moveq	#SPRITES-1,d7
.display:	; Address of the sprite routine
	move.l	(a5)+,a2
	; Screen adress
	move.l	(a5)+,a1
	; Display sprite
	jsr     	(a2)
	dbra	d7,.display
	rts

;#----------------#
;# Sprite routine #
;#----------------#
	
	include INC_SPR.S

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w 0

; Sprites routines
table:	dc.l sommarhack_nonmasked_0
	dc.l sommarhack_nonmasked_1
	dc.l sommarhack_nonmasked_2
	dc.l sommarhack_nonmasked_3
	dc.l sommarhack_nonmasked_4
	dc.l sommarhack_nonmasked_5
	dc.l sommarhack_nonmasked_6
	dc.l sommarhack_nonmasked_7
	dc.l sommarhack_nonmasked_8
	dc.l sommarhack_nonmasked_9
	dc.l sommarhack_nonmasked_10
	dc.l sommarhack_nonmasked_11
	dc.l sommarhack_nonmasked_12
	dc.l sommarhack_nonmasked_13
	dc.l sommarhack_nonmasked_14
	dc.l sommarhack_nonmasked_15

; Palette
palette:	dc.w $0000,$0640,$0420,$0760
	dc.w $0211,$0640,$0420,$0760
	dc.w $0766,$0640,$0420,$0760
	dc.w $0544,$0640,$0420,$0760

; Background image
image:	incbin BACK.DAT

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

cosTabX:	ds.w 1024
sinTabX:	ds.w 1024
cosTabY:	ds.w 1024
sinTabY:	ds.w 1024

sprites:	ds.l SPRITES*2

pxa1:	ds.w 1
pxa2:	ds.w 1
pya1:	ds.w 1
pya2:	ds.w 1

pxb1:	ds.w 1
pxb2:	ds.w 1
pyb1:	ds.w 1
pyb2:	ds.w 1

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
