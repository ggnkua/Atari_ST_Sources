; +======================================================================+
; | Big Border Demo - Textual Interlude screen			 |
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

	; Inits MFP
	move.b	#1,MFP_ENABLE_A.w	; Only timer B
	move.b	#1,MFP_MASK_A.w	;
	clr.b	MFP_ENABLE_B.w	; No timer C-D
	clr.b	MFP_MASK_B.w	;
	bclr	#3,MFP_VR.w		; Automatic End Of Interrupt

	; New VBL/HBL
	move.l	#raster_vbl,VBL.w	; Set new VBL
	move.l	#default_hbl,TB_HBL.w	; Set default HBL

	; Initialize screen
	bsr	clear_mini_screen

	; Init big loop
	move.w	#0,num
	move.w	#14,top
	move.w	screen_num,d0
	lsl.w	#2,d0
	lea	toc,a0
	move.l	(a0,d0.w),a0	; a0 = text@
	move.l	a0,line_adr

	; Big loop
loop_demo:
	; Current @ = 0 ? end demo
	move.l	line_adr,a0
	move.b	(a0),d0
	beq	end_fade_final
	
	; Else, display current screen
	move.l	line_adr,a0
	bsr	init_buffer
	bsr	init_position

	; Animate line
loop_line:	bsr	vsync
	bsr	clear_part
	bsr	display_chars
	bsr	clear_end
	bsr	inc_position
	tst.w	d0
	bne.s	loop_line

	; Next line
	move.l	line_adr,a0
	lea	12(a0),a0
	move.l	a0,line_adr
	addq.w	#1,num
	cmpi.w	#5,num
	beq.s	.line0
	addq.w	#8,top
	bra.s	.linenext
.line0:	move.w	#0,num
	move.w	#14,top
	bsr.s	temporize
	bsr	end_fade_bottom
.linenext:
	jmp	loop_demo

;#-------------------#
;# Temporize 1.5 sec #
;#-------------------#

temporize:
	moveq	#75,d7
.tempo:	bsr	vsync
	dbra	d7,.tempo
	rts

;#-------------------#
;# Clear mini screen #
;#-------------------#

clear_mini_screen:

	; Clear mini screen
	bsr	vsync
	moveq	#0,d7
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	moveq	#54-1,d1
.clr_y:	moveq	#6-1,d0
.clr_x:	move.w	#-1,(a1)+
	move.w	d7,(a1)+
	move.l	d7,(a1)+
	dbra	d0,.clr_x
	lea	112(a1),a1
	dbra	d1,.clr_y

	; Display title
	lea	title+34,a0
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	moveq	#13-1,d1
.copy_y:	moveq	#6-1,d0
.copy_x:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.copy_x
	lea	112(a1),a1
	dbra	d1,.copy_y

	; Set palette
	lea	hbl_pal,a0
	move.l	#title+2,(a0)
	move.l	#palette1,13*4+8*4*0(a0)

	rts

;#--------------------#
;# Display characters #
;#--------------------#

display_chars:

	lea	buffer,a2
	lea	position,a3
	lea	curve,a4
	move.w	#-8,d6

	moveq	#12-1,d0
.char:
	btst	#0,d0
	beq.s	.next16b
	addq.l	#8,d6
.next16b:
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	move.w	top,d7
	move.w	(a3)+,d1
	lsl.w	d1
	add.w	(a4,d1.w),d7
	mulu	#160,d7
	add.w	d6,d7
	lea	(a1,d7.w),a1

	move.l	(a2)+,d4
	moveq	#8-1,d1
.line	move.l	(a2)+,d5
	and.l	d4,(a1)
	or.l	d5,(a1)
	move.l	(a2)+,d5
	and.l	d4,4(a1)
	or.l	d5,4(a1)
	lea	160(a1),a1
	dbra	d1,.line

	dbra	d0,.char

	rts

;#---------------------------#
;# Clear part of mini screen #
;#---------------------------#

clear_part:
	move.w	top,d7
	mulu	#160,d7

	moveq	#0,d2
	movea.l	screen_adr,a1
	lea	73*160+56(a1),a1
	lea	(a1,d7.w),a1
	moveq	#54-1,d1
.clr_y:	moveq	#6-1,d0
.clr_x:	move.w	#-1,(a1)+
	move.w	d2,(a1)+
	move.l	d2,(a1)+
	dbra	d0,.clr_x
	lea	112(a1),a1
	dbra	d1,.clr_y
	rts

;#-------------------------#
;# Clear after mini screen #
;#-------------------------#

clear_end:
	movea.l	screen_adr,a1
	lea	73*160+56+54*160(a1),a1
	moveq	#0,d2
	moveq	#46-1,d1
.clr_y:	moveq	#6-1,d0
.clr_x:	move.l	d2,(a1)+
	move.l	d2,(a1)+
	dbra	d0,.clr_x
	lea	112(a1),a1
	dbra	d1,.clr_y
	rts

;#---------------------#
;# Increment positions #
;#---------------------#

inc_position:
	move.w	#(end_curve-curve)/2,d7
	lea	position,a2
	moveq	#12-1,d0
.initpos:	move.w	(a2),d1
	addq.w	#1,d1
	cmp.w	d1,d7
	beq.s	.end_position
	move.w	d1,(a2)+
	dbra	d0,.initpos
	; d0<>0 = screen not finished
	moveq	#1,d0
	rts

.end_position:
	; d0=0 = screen finished
	moveq	#0,d0
	rts

;#---------------#
;# Fade to black #
;#---------------#

end_fade_final:
	lea	paltitle,a4
	lea	palette1+16*2,a5
	lea	hbl_pal,a6
	moveq	#7-1,d7
.fade:	rept	2
	bsr	vsync
	move.l	a4,(a6)
	move.l	a5,13*4(a6)
	endr
	lea	16*2(a4),a4
	lea	16*2(a5),a5
	dbra	d7,.fade
	; Go to the next screen
	addq.w	#1,screen_num
	rts

end_fade_bottom:
	
	; Fade out
	lea	palette1+16*2,a5
	lea	hbl_pal,a6
	moveq	#7-1,d7
.fade:	rept	2
	bsr	vsync
	move.l	a5,13*4(a6)
	endr
	lea	16*2(a5),a5
	dbra	d7,.fade

	; Restore clean screen
	bsr	clear_mini_screen

	rts

;#-------------#
;# Init buffer #
;#-------------#
; Input : a0 = text@ (12 chars)

init_buffer:
	lea	font+34,a1
	lea	buffer,a2
	moveq	#12-1,d0
.char:
	moveq	#0,d1
	move.b	(a0)+,d1	; d1 = char
	sub.w	#32,d1	; d1 = ord(char)-32
	lsl.w	#7,d1	; x128
	
	move.l	#%00000000111111110000000011111111,d4
	btst	#0,d0
	bne.s	.nodecal
	add.w	#64,d1
	move.l	#%11111111000000001111111100000000,d4
.nodecal:
	lea	(a1,d1.w),a6

	move.l	d4,(a2)+
	moveq	#16-1,d6
.copy:	move.l	(a6)+,(a2)+
	dbra	d6,.copy

	dbra	d0,.char
	rts

;#----------------#
;# Init positions #
;#----------------#

init_position:

	move.w	num,d0
	btst	#0,d0
	beq.s	.lefttoright

.righttoleft:
	lea	position,a2
	moveq	#0,d2
	moveq	#12-1,d0
.initrtl:	move.w	d2,(a2)+
	addq.l	#4,d2
	dbra	d0,.initrtl
	rts

.lefttoright:
	lea	position+12*2,a2
	moveq	#0,d2
	moveq	#12-1,d0
.initltr:	move.w	d2,-(a2)
	addq.l	#4,d2
	dbra	d0,.initltr
	rts

;#================#
;# Raster VBL/HBL #
;#================#

raster_vbl:	move.w	#$000,PALETTE.w

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

raster_hbl:	

	movem.l	d1/a1,-(sp)

	; Wait to be within mini-screen
	cmp.w	#144-2,hbl_count
	blt.s	.next
	cmp.w	#250-2,hbl_count
	bgt.s	.next
	
	move.w	hbl_count,d1
	sub.w	#144-2,d1
	lsl.w	#1,d1
	lea	hbl_pal,a1
	tst.l	(a1,d1.w)
	beq.s	.next

	move.l	(a1,d1.w),a1
	move.l	(a1)+,PALETTE+00.w
	move.l	(a1)+,PALETTE+04.w
	move.l	(a1)+,PALETTE+08.w
	move.l	(a1)+,PALETTE+12.w
	move.l	(a1)+,PALETTE+16.w
	move.l	(a1)+,PALETTE+20.w
	move.l	(a1)+,PALETTE+24.w
	move.l	(a1)+,PALETTE+28.w

	; Inc HBL count
.next:	addq.w	#2,hbl_count

	; Install new Timer B HBL
	move.l	#raster_hbl,TB_HBL.w
	clr.b	MFP_CTRL_B.w
	move.b	#1,MFP_DATA_B.w
	move.b	#8,MFP_CTRL_B.w
	ori.b	#1,MFP_ENABLE_A.w

	movem.l	(sp)+,d1/a1

	rte

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

iteration:	dc.w 0
hbl_count:	dc.w 0

title:	incbin TITLE.DAT
font:	incbin FONT.DAT
palette:	include PALETTE.S
curve:	include CURVE.S
end_curve:

screen_num:	dc.w 0

toc:	dc.l text0
	dc.l text1
	dc.l text2
	dc.l text3
	dc.l text4
	dc.l text5
	dc.l text6
	dc.l text7
	dc.l text8

text0:	dc.b " HELLO      "
	dc.b "EVERYBODY !!"
	dc.b " THIS IS THE"
	dc.b "  BIG-BORDER"
	dc.b "DEMO BY DYNO"

	dc.b "SPECIFICALLY"
	dc.b "DESIGNED FOR"
	dc.b " SOMMARHACK "
	dc.b "  2017, IN  "
	dc.b "GRADO SWEDEN"

	dc.b "OK NOW LET'S"
	dc.b " START WITH "
	dc.b "THE  SERIOUS"
	dc.b " STUFF, ARE "
	dc.b " YOU READY? "

	dc.b 0

; WIRE

text1:	dc.b "NEXT UP:    "
	dc.b " A PICTURE  "
	dc.b "DISPLAYED IN"
	dc.b "HICOLOR WITH"
	dc.b " 100 COLORZ!"
	dc.b 0
	
; MPP

text2:	dc.b " GREAT! NOW "
	dc.b " WHAT ABOUT "
	dc.b "SOME  MIGHTY"
	dc.b "KEFRENS BARS"
	dc.b "   ??????   "
	dc.b 0

; KEFRENS

text3:	dc.b "  NOW IT'S  "
	dc.b "TIME 4 SOME "
	dc.b " MAGNIFICENT"
	dc.b "  REAL-TIME "
	dc.b "   FRACTALS "
	dc.b 0

; FRACTAL

text4:	dc.b "OKAY,  NOW A"
	dc.b " NEW EFFECT "
	dc.b "ON ATARI ST,"
	dc.b " EVER SEEN A"
	dc.b "1-PX PLASMA?"
	dc.b 0

; PLASMOIL

text5:	dc.b "WITH DELIGHT"
	dc.b "LET'S SEE AN"
	dc.b "OTHER  HICOL"
	dc.b "PIX WITH 180"
	dc.b "  COLORZ!   "
	dc.b 0

; MPP

text6:	dc.b "AFTER  WEEKS"
	dc.b "OF HARD WORK"
	dc.b "HERE COME ZE"
	dc.b "FABULOUS  3D"
	dc.b " GLENZ PART "
	dc.b 0

; GLENZ
	
text7:	dc.b "AND NOW KEEP"
	dc.b " YOUR  EYES "
	dc.b "OPENED FOR A"
	dc.b " NEW  WORLD "
	dc.b " RECORD  :) "

	dc.b "YOU'RE GOING"
	dc.b " TO SEE 128 "
	dc.b " NON MASKED "
	dc.b "2 BITPLANES "
	dc.b " 8X8 SPRITES"

	dc.b 0

; SPRITE

text8:	dc.b "============"
	dc.b "   CREDITS  "
	dc.b "  FOR THIS  "
	dc.b " SHORT DEMO "
	dc.b "============"

	dc.b " THIS AMIGA "
	dc.b "FONT RIPPED "
	dc.b " BY ROY FROM"
	dc.b "SUPERIOR ART"
	dc.b " CREATIONS  "

	dc.b "  CODE AND  "
	dc.b " ALL  OTHER "
	dc.b " MARVELLOUS "
	dc.b " GRAFIX  BY "
	dc.b "    DYNO    "

	dc.b "  MUSIC BY  "
	dc.b " EPIC  FROM "
	dc.b "    THE     "
	dc.b "  MISFITS   "
	dc.b "  SOFTWARE  "

	dc.b "============"
	dc.b "  THE       "
	dc.b "  GREETINGS "
	dc.b "      GO TO "
	dc.b "============"

	dc.b "  ALL THE   "
	dc.b "   PEOPLE   "
	dc.b " ATTENDING  "
	dc.b "THE  SOMMAR-"
	dc.b "HACK PARTY !"

	dc.b " AND TO ALL "
	dc.b " THE OTHERS "
	dc.b "(THE LIST IS"
	dc.b " TOO LONG TO"
	dc.b " FIT HERE..)"

	dc.b "============"
	dc.b "= NOW IT'S ="
	dc.b "=  TIME TO ="
	dc.b "=   WRAP ! ="
	dc.b "============"

	dc.b "============"
	dc.b "=          ="
	dc.b "= HEJ DA ! ="
	dc.b "=          ="
	dc.b "============"
	dc.b 0

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

hbl_pal:	ds.l 54

num:	ds.w 1
top:	ds.w 1
line_adr:	ds.l 1

buffer:	ds.b 12*(64+4)

position:	ds.w 12

screen_adr:	ds.l 1
	IFEQ	PROD-0
screen_buf:	ds.b 32000+256
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
