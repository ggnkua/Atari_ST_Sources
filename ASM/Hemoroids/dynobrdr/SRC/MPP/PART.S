; +======================================================================+
; | Big Border Demo - Multi Palette Picture screen		 |
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
	
	; Display image
	bsr.s	display_image

	; Inits MFP
	move.b	#1,MFP_ENABLE_A.w	; Only timer B
	move.b	#1,MFP_MASK_A.w	;
	clr.b	MFP_ENABLE_B.w	; No timer C-D
	clr.b	MFP_MASK_B.w	;
	bclr	#3,MFP_VR.w		; Automatic End Of Interrupt

	; New VBL/HBL
	move.l	#raster_vbl,VBL.w	; Set new VBL
	move.l	#default_hbl,TB_HBL.w	; Set default HBL

	; Start iteration
	clr.w	iteration

loop_demo:	; Wait for VSYNC
	bsr	vsync

	; Next iteration
	addq.w	#1,iteration

	; Exit loop ?
	cmpi.w	#50*8,iteration
	bne.s	loop_demo

	; Next image
	add.l	#2592,image
	add.l	#1728,palette

	rts

;#---------------#
;# Display image #
;#---------------#

display_image:

	move.l	image,a0

	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	moveq	#54-1,d1
.copy_y:	moveq	#12-1,d0
.copy_x:	move.l	(a0)+,(a1)+
	dbra	d0,.copy_x
	lea	112(a1),a1
	dbra	d1,.copy_y

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
	; Set palette address
	move.l	palette,current
	; Install new Timer B HBL
	move.w	#$2100,sr
	stop	#$2100
	move.w	#$2700,sr
	move.l	#raster_hbl,TB_HBL.w
	clr.b	MFP_CTRL_B.w
	move.b	#1,MFP_DATA_B.w
	move.b	#8,MFP_CTRL_B.w
	ori.b	#1,MFP_ENABLE_A.w
	rte

raster_hbl:

	; Wait to be within mini-screen
	cmp.w	#144,hbl_count
	blt.s	.next
	cmp.w	#250,hbl_count
	bgt.s	.next

	move.l	current(pc),a1
	movem.l	(a1)+,d5-d7/a2-a6
	move.w	d5,PALETTE+2.w
	movem.l	d6-d7/a2-a6,PALETTE+4.w
	move.l	a1,current

	; Inc HBL count
.next:	addq.w	#2,hbl_count

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

current:	dc.l 0

iteration:	dc.w 0
hbl_count:	dc.w 0

image:	dc.l	images
palette:	dc.l	palettes

images:	incbin pics\pixel2.img
	incbin pics\paint.img

palettes:	incbin pics\pixel2.pal
	incbin pics\paint.pal

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
