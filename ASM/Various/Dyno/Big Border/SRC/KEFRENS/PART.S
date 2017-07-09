; +======================================================================+
; | Big Border Demo - Kefrens Bars screen			 |
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

	; Initialise sinus tables
	lea	sinus,a0
	moveq	#21,d0
	moveq	#0,d1
	bsr	generate_sinus

	; Preshift copper bar
	lea	bar+34,a0
	movem.w	(a0),d2-d5
	swap	d2
	clr.w	d2
	swap	d3
	clr.w	d3
	swap	d4
	clr.w	d4
	swap	d5
	clr.w	d5
	lea	copper,a1
	moveq	#16-1,d0
.preshift:	move.w	d2,8(a1)
	swap	d2
	move.w	d2,(a1)
	swap	d2
	ror.l	d2
	move.w	d3,10(a1)
	swap	d3
	move.w	d3,2(a1)
	swap	d3
	ror.l	d3
	move.w	d4,12(a1)
	swap	d4
	move.w	d4,4(a1)
	swap	d4
	ror.l	d4
	move.w	d5,14(a1)
	swap	d5
	move.w	d5,6(a1)
	swap	d5
	ror.l	d5
	lea	16(a1),a1
	dbra	d0,.preshift

	; Clear screen
	movea.l	screen_adr,a1
	moveq	#0,d0 
	move.w	#8000-1,d1
.clear:	move.l	d0,(a1)+
	dbra	d1,.clear

	; Set palette
	movem.l	bar+2,d0-d7
	movem.l	d0-d7,PALETTE.w

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

	; Clear buffer
	lea	buffer,a0
	moveq	#48/4-1,d0
clear_buf:	move.l	#-1,(a0)+
	dbra	d0,clear_buf

	; Display screen

	lea	sinus,a6

	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1

	move.w	kefrens1,d6
	move.w	kefrens2,d7
	
	moveq	#54-1,d1
line:
	cmpi.w	#52,d1
	bge.s	.nonew
	cmpi.w	#8-1,d1
	blt.s	.nonew

	; Compute curve value
	move.w	#42,d0
	add.w	(a6,d6.w),d0
	add.w	(a6,d7.w),d0

	; Write new copper bar

	move.w	d0,d3
	and.w	#$F,d3
	lsl.w	#2,d3	; x4
	lea	mask,a4
	lea	(a4,d3.w),a4
	move.w	(a4),d4
	swap	d4
	move.w	(a4),d4
	move.w	2(a4),d5
	swap	d5
	move.w	2(a4),d5

	lsl.w	#2,d3	; x16
	lea	copper,a3
	lea	(a3,d3.w),a3
	
	move.w	d0,d2
	lsr.w	#4,d2
	lsl.w	#3,d2
	lea	buffer,a2
	lea	(a2,d2.w),a2
	
	move.l	(a2),d0
	and.l	d4,d0
	or.l	(a3)+,d0
	move.l	d0,(a2)

	move.l	4(a2),d0
	and.l	d4,d0
	or.l	(a3)+,d0
	move.l	d0,4(a2)

	move.l	8(a2),d0
	and.l	d5,d0
	or.l	(a3)+,d0
	move.l	d0,8(a2)

	move.l	12(a2),d0
	and.l	d5,d0
	or.l	(a3)+,d0
	move.l	d0,12(a2)
.nonew:
	; Copy buffer
	lea	buffer,a0
	moveq	#48/4-1,d0
copy_buf:	move.l	(a0)+,(a1)+
	dbra	d0,copy_buf
	
	; Next line value
	add.w	#38,d6
	and.w	#$7FF,d6
	add.w	#46,d7
	and.w	#$7FF,d7
	
	; Next screen line
	lea	112(a1),a1
	dbra	d1,line

	; Next frame value
	add.w	#50,kefrens1
	and.w	#$7FF,kefrens1
	add.w	#42,kefrens2
	and.w	#$7FF,kefrens2

	; Next iteration
	addq.w	#1,iteration

	; Exit loop ?
	cmpi.w	#50*15,iteration
	bne	loop_demo

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
	move.l	#raster_hbl,TB_HBL.w
	clr.b	MFP_CTRL_B.w
	move.b	#1,MFP_DATA_B.w
	move.b	#8,MFP_CTRL_B.w
	ori.b	#1,MFP_ENABLE_A.w

	rte

raster_hbl:	move.w	#$000,PALETTE+15*2.w

	; Wait to be within mini-screen
	cmp.w	#144,hbl_count
	blt.s	.next
	cmp.w	#250,hbl_count
	bgt.s	.next

	; Set palette
	lea	background,a5
	move.w	hbl_count,d5
	sub.w	#144,d5
	move.w	(a5,d5.w),PALETTE+15*2.w
.next:
	; Inc HBL count
	addq.w	#2,hbl_count

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
kefrens1:	dc.w 768
kefrens2:	dc.w 256

bar:	incbin BAR.DAT

mask:	dc.l %00000000000011111111111111111111
	dc.l %10000000000001111111111111111111
	dc.l %11000000000000111111111111111111
	dc.l %11100000000000011111111111111111
	dc.l %11110000000000001111111111111111
	dc.l %11111000000000000111111111111111
	dc.l %11111100000000000011111111111111
	dc.l %11111110000000000001111111111111
	dc.l %11111111000000000000111111111111
	dc.l %11111111100000000000011111111111
	dc.l %11111111110000000000001111111111
	dc.l %11111111111000000000000111111111
	dc.l %11111111111100000000000011111111
	dc.l %11111111111110000000000001111111
	dc.l %11111111111111000000000000111111
	dc.l %11111111111111100000000000011111

background:	incbin RASTER.DAT

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

buffer:	ds.b 48+8

copper:	ds.b 16*16

sinus:	ds.w 1024

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
