; +======================================================================+
; | Big Border Demo - Wireframe screen			 |
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
	movem.l	palette,d0-d7
	movem.l	d0-d7,PALETTE.w

;#---------------------------------------#
;# Step 1 : appearance of the background #
;#---------------------------------------#

	clr.w	iteration

	lea	back+34+54*42,a6
	
step1:	; Wait for VSYNC
	bsr	vsync

	; Source address
	move.l	a6,a0
	
	; Destination address
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	; Display part of background image
	move.w	iteration,d1
.copy_y:	moveq	#6-1,d0
.copy_x:	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	addq.l	#2,a1
	dbra	d0,.copy_x
	addq.l	#6,a0
	lea	112(a1),a1
	dbra	d1,.copy_y

	; Next frame
	addq.w	#1,iteration
	lea	-42(a6),a6

	; Exit loop ?
	cmpi.w	#55,iteration
	bne.s	step1

;#-----------------------------------#
;# Step 2 : appearance of the insert #
;#-----------------------------------#

	clr.w	iteration
	lea	save_logo,a6

step2:	; Wait for VSYNC
	bsr	vsync

	; Address of right column
	lea	back+34+30,a0

	; Destination address
	movea.l	screen_adr,a1
	lea	73*160+56+5*8(a1),a1

	; Scroll insert on the right

	move.w	#54-1,d1
.roxl:	
	roxl.w	6(a0)
	roxl.w	(a0)
	roxl.w	8(a0)
	roxl.w	2(a0)
	roxl.w	10(a0)
	roxl.w	4(a0)

	move.l	(a0),(a6)+		; save in buffer
	move.w	4(a0),(a6)+

	move.l	(a0),(a1)+		; copy to screen
	move.w	4(a0),(a1)+
	addq.l	#2,a1

	lea	42(a0),a0
	lea	152(a1),a1
	
	dbra	d1,.roxl

	; Next frame
	addq.w	#1,iteration

	; Exit loop ?
	cmpi.w	#16,iteration
	bne.s	step2

;#------------------------#
;# Step 3 : rotating cube #
;#------------------------#

	clr.w	iteration

step3:	; Wait for VSYNC
	bsr	vsync

	; Clear 2x planes
	movea.l	screen_adr,a1
	lea	73*160+56+8(a1),a1
	moveq	#49-1,d1	
.clear:	moveq	#3-1,d0
.clear_x:	addq.l	#4,a1
	clr.l	(a1)+
	dbra	d0,.clear_x
	lea	136(a1),a1
	dbra	d1,.clear

	; Compute cube Y pos
	lea	curve,a2
	move.w	iteration,d0
	move.b	(a2,d0.w),d3
	ext.w	d3
	move.w	d3,d4
	neg.w	d4
	addq.w	#1,d4
	muls	#6,d4

	; Display 3D cube - plane 4
	
	lea	cube+34,a0
	move.w	iteration,d0
	divu.w	#300,d0
	swap	d0	; iteration modulo 300
	mulu	#288,d0
	lea	(a0,d0.l),a0
	add.l	d4,a0

	movea.l	screen_adr,a1
	lea	73*160+56+8(a1),a1

	moveq	#46,d1
	add.w	d3,d1
	ble.s	.skip
	
.copy_y:	moveq	#3-1,d0
.copy_x:	addq.l	#6,a1
	move.w	(a0)+,(a1)+
	dbra	d0,.copy_x
	lea	136(a1),a1
	dbra	d1,.copy_y
.skip:
	; Display 3D cube - plane 3

	lea	cube+34,a0
	move.w	iteration,d0
	addq.w	#4,d0
	divu.w	#300,d0
	swap	d0	; iteration modulo 300
	mulu	#288,d0
	lea	(a0,d0.l),a0
	add.l	d4,a0

	movea.l	screen_adr,a1
	lea	73*160+56+8(a1),a1

	moveq	#46,d1
	add.w	d3,d1
	ble.s	.skip2

.copy_y2:	moveq	#3-1,d0
.copy_x2:	addq.l	#4,a1
	move.w	(a0)+,(a1)+
	addq.l	#2,a1
	dbra	d0,.copy_x2
	lea	136(a1),a1
	dbra	d1,.copy_y2
.skip2:
	; Display 3D cube - plane 3+4

	lea	cube+34,a0
	move.w	iteration,d0
	addq.w	#8,d0
	divu.w	#300,d0
	swap	d0	; iteration modulo 300
	mulu	#288,d0
	lea	(a0,d0.l),a0
	add.l	d4,a0
	
	movea.l	screen_adr,a1
	lea	73*160+56+8(a1),a1

	moveq	#46,d1
	add.w	d3,d1
	ble.s	.skip3

.copy_y3:	moveq	#3-1,d0
.copy_x3:	addq.l	#4,a1

	move.w	(a1),d7
	or.w	(a0),d7
	move.w	d7,(a1)+

	move.w	(a1),d7
	or.w	(a0)+,d7
	move.w	d7,(a1)+
	
	dbra	d0,.copy_x3
	lea	136(a1),a1
	dbra	d1,.copy_y3
.skip3:
	; Next frame
	addq.w	#1,iteration

	; Exit loop ?
	cmp.w	#end_curve-curve,iteration
	bne	step3

;#--------------------------------------#
;# Step 4 : disappearance of the insert #
;#--------------------------------------#

	clr.w	iteration

step4:	; Wait for VSYNC
	bsr	vsync

	; Disappearance of the insert on the right

	lea	save_logo,a6
	moveq	#15,d0
	sub.w	iteration,d0
	mulu	#3*2*54,d0
	lea	(a6,d0.w),a6

	movea.l	screen_adr,a1
	lea	73*160+56+5*8(a1),a1

	move.w	#54-1,d1
.restore:	move.l	(a6)+,(a1)+
	move.w	(a6)+,(a1)+
	addq.l	#2,a1
	lea	152(a1),a1
	dbra	d1,.restore

	; Next frame
	addq.w	#1,iteration

	; Exit loop ?
	cmpi.w	#16,iteration
	bne.s	step4

;#------------------------------------------#
;# Step 5 : disappearance of the background #
;#------------------------------------------#

	clr.w	iteration

	lea	back+34,a6
	
step5:	; Wait for VSYNC
	bsr	vsync

	; Clear 4x planes
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	moveq	#54-1,d1	
.clear:	moveq	#12-1,d0
.clear_x:	clr.l	(a1)+
	dbra	d0,.clear_x
	lea	112(a1),a1
	dbra	d1,.clear

	; Display part of background image

	move.l	a6,a0
	
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	move.w	#54-1,d1
	sub.w	iteration,d1
	ble.s	.skip5
.copy_y:	
	move.l	(a0),d3
	move.w	4(a0),d4
	moveq.l	#6-1,d0
.copy_b:	move.l	d3,(a1)+
	move.w	d4,(a1)+
	addq.l	#2,a1
	dbra	d0,.copy_b
	
	lea	42(a0),a0
	lea	112(a1),a1
	dbra	d1,.copy_y
.skip5:
	; Next frame
	addq.w	#1,iteration
	lea	42(a6),a6

	; Exit loop ?
	cmpi.w	#55,iteration
	bne.s	step5

	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w 0

col1	= $766
col2	= $655
col3	= $544

palette:	dc.w $000,$433,$122,$344,$332,col2,col1,col1
	dc.w col1,col3,col1,col1,col1,col1,col1,col1

back:	incbin BACK.DAT

cube:	incbin CUBE.DAT

curve:	include CURVE.S
end_curve:

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

save_logo:	ds.b 3*2*54*16

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
