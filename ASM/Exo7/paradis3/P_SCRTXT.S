; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Compute the buffers displayed before and after the logical screen    |
; +======================================================================+
; | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
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

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#===========#
;# Constants #
;#===========#

TILE_HEIGHT 	= 6
FONT_HEIGHT 	= 6*TILE_HEIGHT			; 36
BLOC_HEIGHT 	= 2*TILE_HEIGHT			; 12

;#========================#
;# Initialize text buffer #
;#========================#
; Input
;   a0   = source buffer
;   a1   = destination buffer
;   d0.w = size of buffer
;   d1.l = width of buffer x2

INIT_TEXT_BUFFER:

	move.l	d1,-(sp)

	;--------------------------------
	; Add offset tile to text buffer
	;--------------------------------

	lea	(a0,d0.w),a0
	lea	(a1,d0.w),a1
	lea	(a1,d0.w),a1

	moveq.l	#TILE_HEIGHT*8,d2		; TILE_HEIGHT lines * 8 bytes

	ext.l	d0
	subq.l	#1,d0

bi_init:clr.w	d1
	move.b	-(a0),d1
	mulu.w	d2,d1
	move.w	d1,-(a1)
	dbra	d0,bi_init

	;---------------------
	; Init lookup table 1
	;---------------------
	; For each line, offset from the beginning of the tile
	; (= 8 bytes * num line)

	lea	scroll_lut_1,a0
	moveq.l	#6-1,d0
	moveq.w	#8*0,d1
	moveq.w	#8*1,d2
	moveq.w	#8*2,d3
	moveq.w	#8*3,d4
	moveq.w	#8*4,d5
	moveq.w	#8*5,d6
bi_lut2:movem.w	d1-d6,(a0)
	lea	6*2(a0),a0
	dbra	d0,bi_lut2

	;---------------------
	; Init lookup table 2
	;---------------------
	; For each line, text start at :
	; textWidth * 2 (.W) * num line in tile

	lea	scroll_lut_2,a0
	move.l	(sp)+,d3			; text width * 2 (.W)
	clr.l	d2
	moveq.l	#6-1,d1
bi_lut3:moveq.l	#6-1,d0
bi_int3:move.w	d2,(a0)+
	dbra	d0,bi_int3
	add.l	d3,d2				; * num line in tile
	dbra	d1,bi_lut3

	;----------------------------------------------------
	; Initializations small buffer (just for 1st screen)
	;----------------------------------------------------

	lea	textDemo,a6
	move.l	a6,buffer_small_src

	move.l	pos_curve_buffer,a6
	lea	2*6*CURVE_SPEED(a6),a6
	move.l	a6,buffer_small_curve
	
	RTS

;#============================#
;# Init addresses every 3 VBL #
;#============================#

SET_TEXT_EVERY_3_VBL:

	; Init small buffer SRC address

	lea	textDemo,a6
	sub.l	textDemoWidthX4,a6
	move.l	a6,buffer_small_src

	; Init small buffer DST address

	move.l	sync_logical,a6
	
st3_norm:
	cmp.l	#screen_buf+9*FONT_HEIGHT*230,a6
	blt.s	st3_norm_ok
	sub.l	#8*FONT_HEIGHT*230,a6
	bra.s	st3_norm
st3_norm_ok:
	lea	-(FONT_HEIGHT*230+BLOC_HEIGHT*230)(a6),a6
	move.l	a6,buffer_small_dst

	RTS

;#==========================#
;# Init addresses every VBL #
;#==========================#

SET_TEXT_EVERY_VBL:

	; Increment small buffer SRC address

	move.l	textDemoWidthX4,d0
	add.l	d0,buffer_small_src

	; Init small buffer CURVE address

	move.l	pos_curve_buffer,a6
	cmp.w	#48*2,iteration_x72
	bge.s	ev_stop
	lea	6*CURVE_SPEED(a6),a6
	cmp.w	#24*2,iteration_x72
	bge.s	ev_stop
	lea	6*CURVE_SPEED(a6),a6
ev_stop:move.l	a6,buffer_small_curve

	; Increment small buffer DST address

	move.l	buffer_small_dst,a6
	lea	BLOC_HEIGHT*230(a6),a6
	move.l	a6,buffer_small_dst

	; Init big buffer DST address

	move.l	sync_logical,a0
	add.l	#7*FONT_HEIGHT*230,a0
	move.l	a0,buffer_big_dst

	RTS

;#=====================================#
;# Compute next position of the buffer #
;#=====================================#

macro_compute_buffer: MACRO

	; Compute new text Decal

	move.l	a6,a3				; a3 = @font
	adda.l	(a0)+,a3			;      + offset from the beginning of the tileset
	adda.w	(a1)+,a3			;      + offset from the beginning of the tile
	move.l	a3,(a4)+			; store in buffer

	; Compute new text Start

	clr.l	d7				; d7 =
	move.w	(a2)+,d7			;      text width * 2 (.W) * num line in tile
	add.w	(a0)+,d7			;      + posX
	add.l	a5,d7				;      + textDemo
	move.l	d7,(a4)+			; store in buffer

	ENDM

;#================================#
;# Compute the small (1/3) buffer #
;# displayed before the screen    #
;#================================#

COMPUTE_SMALL_BUFFER:
	move.l	buffer_small_curve,a0
	move.l	buffer_small_src,a5
	lea	buffer_small,a4
	lea	scroll_lut_1,a1
	lea	scroll_lut_2,a2
	lea	font,a6
	REPT	BLOC_HEIGHT
	macro_compute_buffer
	ENDR
	RTS

;#===================================#
;# Compute the full buffer displayed #
;# just after the logical screen     #
;#===================================#
; Replay 2 samples during the routine

COMPUTE_BIG_BUFFER:
	move.l	pos_curve_buffer,a0
	lea	textDemo,a5
	lea	buffer_big,a4
	lea	scroll_lut_1,a1
	lea	scroll_lut_2,a2
	lea	font,a6
	REPT	FONT_HEIGHT/3
	macro_compute_buffer
	ENDR
	move.l	a0,save_reg2
	bsr	PLAY_SAMPLE
	move.l	save_reg2(pc),a0
	REPT	FONT_HEIGHT/3
	macro_compute_buffer
	ENDR
	move.l	a0,save_reg2
	bsr	PLAY_SAMPLE
	move.l	save_reg2(pc),a0
	REPT	FONT_HEIGHT/3
	macro_compute_buffer
	ENDR
	RTS

save_reg2:	dc.l 0

;#=========================#
;# Compute the buffer used #
;# during intro            #
;#=========================#

COMPUTE_INTRO_BUFFER:

	move.l	#screen_buf+INTRO_TEXT_BUFF,a5	; textIntro
	add.w	intro_pos,a5			; + posX
	lea	buffer_big,a4
	lea	scroll_lut_1,a1
	lea	scroll_lut_2,a2
	lea	font,a6
	clr.l	d6

	; (byte AND $F) * cntCombination * TILE_HEIGHT * 8 bytes)
	move.w	intro_iteration,d1
	and.w	#$FF,d1
	lsl.w	#2,d1
	lea	curve_lut,a3
	add.l	(a3,d1.w),a6

	moveq.l	#FONT_HEIGHT-1,d0
ci_big:	
	; Compute new text Decal
	move.l	a6,a3				; a3 = @font + offset from the beginning of the tileset
	adda.w	(a1)+,a3			;      + offset from the beginning of the tile
	move.l	a3,(a4)+			; store in buffer

	; Compute new text Start
	move.l	a5,a3				; a3 = textIntro + posX
	adda.w	(a2)+,a3			;      + text width * 2 (.W) * num line in tile
	move.l	a3,(a4)+			; store in buffer

	dbra	d0,ci_big

	RTS

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

font:			incbin	INC\FONT.BIN

textDemo:		incbin	INC\TEXTDEMO.BIN
textDemoEnd:	
textIntro:		incbin	INC\TEXTINTR.BIN
textIntroEnd:
zikIntro:		incbin	INC\DMASC.SND
zikIntroEnd:
textFiller:		dcb.b	(textDemoEnd-textDemo)-(textIntroEnd-textIntro)-(zikIntroEnd-zikIntro),0
textFillerEnd:

			include	INC\TEXTDEMO.S
			include	INC\TEXTINTR.S

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#==============#
;# Text buffers #
;#==============#

buffer_small:		ds.l	BLOC_HEIGHT*2
buffer_big:		ds.l	FONT_HEIGHT*2

;#==================#
;# Current position #
;#==================#

buffer_small_src:	ds.l	1
buffer_small_curve:	ds.l	1
buffer_small_dst:	ds.l	1

buffer_big_dst:		ds.l	1

;#===============#
;# Lookup Tables #
;#===============#

; For each line, offset from the beginning of the tile (= 8 bytes * num line)
scroll_lut_1:		ds.w	36

; For each line, text start at : text width * 2 (.W) * num line in tile
scroll_lut_2:		ds.w	36

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@