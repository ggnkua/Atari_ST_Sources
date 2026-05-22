; +======================================================================+
; | Big Border Demo - Plasma screen				 |
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

	; Clr palette
	clr.l	PALETTE+00.w
	clr.l	PALETTE+04.w
	clr.l	PALETTE+08.w
	clr.l	PALETTE+12.w
	clr.l	PALETTE+16.w
	clr.l	PALETTE+20.w
	clr.l	PALETTE+24.w
	clr.l	PALETTE+28.w

	; Initialise sinus tables
	lea	sinTabX,a0
	moveq	#55,d0
	moveq	#56,d1
	bsr	generate_sinus
	lea	sinTabY,a0
	moveq	#127,d0
	move.w	#128,d1
	bsr	generate_sinus

	; Initialise wave values
	move.w  	#0,pxa
	move.w  	#0,pya

	; Inits MFP
	move.b	#1,MFP_ENABLE_A.w	; Only timer B
	move.b	#1,MFP_MASK_A.w	;
	clr.b	MFP_ENABLE_B.w	; No timer C-D
	clr.b	MFP_MASK_B.w	;
	bclr	#3,MFP_VR.w		; Automatic End Of Interrupt

	; New VBL/HBL
	move.l	#raster_vbl,VBL.w	; Set new VBL
	move.l	#default_hbl,TB_HBL.w	; Set default HBL

loop_demo:	

	; Wait for VSYNC
	bsr	vsync

	; Display image
	bsr.s	display_image

	; Compute palettes
	bsr.s	compute_palettes
	
	; Next iteration
	addq.w	#1,iteration

	; Exit loop ?
	cmpi.w	#50*15,iteration
	bne.s	loop_demo

	rts

;#---------------#
;# Display image #
;#---------------#

display_image:

	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	move.w	iteration,d6
	add.w	d6,d6		; x2
	add.w	iteration,d6	; x3
	addq.w	#1,d6
	move.w	d6,d4
	and.w	#%11111111,d4
	mulu	#48,d4		; 48 bytes per line

	lea	image,a2
	lea	(a2,d4.w),a2

	moveq	#54-1,d1
.copy_y:	REPT 12
	move.l	(a2)+,(a1)+
	ENDR
	lea	112(a1),a1
	dbra	d1,.copy_y

	rts

;#==================#
;# Compute palettes #
;#==================#

compute_palettes:

	; Initialise wave values
	move.w  	pxa,pxb
	move.w  	pya,pyb

	lea	gradient,a5
	lea	palettes,a6
	move.l	#$0000FFFF,d2

	moveq	#54-1,d1
.ligne:

	; Compute X
	clr.l	d5
	lea	sinTabX,a0
	move.w	pxb,d0
	move.w	(a0,d0.w),d5	; x = sinTabX[mod(pxb,PILEN)]
	lsl.l	#1,d5

	; Compute Y
	clr.l	d6
	move.w	iteration,d6
	lea	sinTabY,a0
	move.w	pyb,d0
	add.w	(a0,d0.w),d6	; x = sinTabY[mod(pyb,PILEN)]
	lsl.l	#8,d6
	add.l	d5,d6

	; Compute palette
	and.l	#$0000FFFF,d6
	lea	(a5,d6.l),a0
	REPT	16
	move.w	(a0)+,(a6)+
	ENDR
	
	; Inc angles (during the frame)
	addq.w	#6,pxb
	and.w	#$7FF,pxb
	subq.w	#4,pyb
	bge.s	.sub1
	add.w	#1024*2,pyb
.sub1:
	dbra	d1,.ligne

	; Inc global angles
	add.w	#10,pxa
	and.w	#$7FF,pxa
	addq.w	#6,pya
	and.w	#$7FF,pya

	rts

;#================#
;# Raster VBL/HBL #
;#================#

raster_vbl:
	; Call QVBL
	bsr	call_qvbl
	; Increment number of VBL routines
	addq.w	#1,K_NB_VBL.w

	; Set HBL count to 0
	clr.w	hbl_count

	; Install new Timer B HBL
	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	move.l	#raster_hbl_pre,TB_HBL.w
	clr.b	MFP_CTRL_B.w
	move.b	#1,MFP_DATA_B.w
	move.b	#8,MFP_CTRL_B.w
	ori.b	#1,MFP_ENABLE_A.w

	rte

raster_hbl_pre:

	; Wait to be within mini-screen
	cmp.w	#144-2,hbl_count
	blt.s	.next

	; Install new Timer B HBL
	move.l	#raster_hbl,TB_HBL.w
	bra.s	.fin
.next:	move.l	#raster_hbl_pre,TB_HBL.w
.fin:
	clr.b	MFP_CTRL_B.w
	move.b	#1,MFP_DATA_B.w
	move.b	#8,MFP_CTRL_B.w
	ori.b	#1,MFP_ENABLE_A.w

	; Inc HBL count
	addq.w	#2,hbl_count

	; Set starting palette address for HBLs
	move.l	#palettes,current

	rte

raster_hbl:
	
	; Set palette
	move.l	current(pc),a5
	lea	PALETTE+2.w,a6
	addq.l	#2,a5
	move.w	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	a5,current

	; Install new Timer B HBL
	move.l	#raster_hbl,TB_HBL.w
	clr.b	MFP_CTRL_B.w
	move.b	#1,MFP_DATA_B.w
	move.b	#8,MFP_CTRL_B.w
	ori.b	#1,MFP_ENABLE_A.w

	rte

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w 0
hbl_count:	dc.w 0
current:	dc.l 0

image:	incbin PLASMOIL.DAT
	incbin PLASMOIL.DAT

gradient:	incbin GRADIENT.DAT

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

palettes:	ds.b 32*54
	ds.b 32*74

sinTabX:	ds.w 1024
sinTabY:	ds.w 1024

pxa:	ds.w 1
pya:	ds.w 1

pxb:	ds.w 1
pyb:	ds.w 1

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
