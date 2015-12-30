; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Manage text curve                                                    |
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

CURVE_DIVIDER	= 3			; Distorter 1/3 speed
CURVE_SPEED	= 12			; Number of shifts = FONT_HEIGHT / CURVE_DIVIDER
CURVE_LENGTH	= 60			; Length of buffer = CURVE_SPEED * (2 * CURVE_DIVIDER - 1)

;#=======================#
;# Initialize text curve #
;#=======================#

INIT_TEXT_CURVE:

	;-------------------
	; Init lookup table
	;-------------------
	; (byte AND $F) * cntCombination * TILE_HEIGHT * 8 bytes)

	clr.l	d3
	move.w	cntCombination,d3
	mulu	#8*TILE_HEIGHT,d3

	lea	curve_lut+256*4,a0
	move.l	#256-1,d0
ci_lut:	clr.l	d2
	move.b	d0,d2			; 0..255
	and.b	#$F,d2			; 0..15
	mulu	d3,d2			; * cntCombination * TILE_HEIGHT * 8 bytes
	move.l	d2,-(a0)
	dbra	d0,ci_lut

	;-------------
	; Clear curve
	;-------------

	lea	curve_buffer,a0
	move.l	#12*CURVE_LENGTH/4-1,d0
ci_clr:	clr.l	(a0)+
	dbra	d0,ci_clr

	;--------------------------
	; Define current positions
	;--------------------------

	lea	curve_buffer,a0
	move.l	a0,pos_curve_buffer

	lea	curve_toc_intro,a0
	move.l	a0,curve_pos_toc
	move.l	(a0),curve_pos_table
	move.l	#0,curve_sum

	RTS

;#====================#
;# Compute text curve #
;#====================#
; Replay 1 sample during the routine

COMPUTE_TEXT_CURVE:

	;------------------------
	; Load current positions
	;------------------------

	move.l	pos_curve_buffer,a0	; a0 = current position
	lea	-6*CURVE_SPEED(a0),a5	; a5 = n lines before the buffer
	lea	6*CURVE_LENGTH(a0),a6	; a6 = n lines after the buffer
	move.l	curve_pos_toc,a1
	move.l	curve_pos_table,a2
	move.l	curve_sum,d7
	lea	curve_lut,a3
	move.b	#127,d2
	move.b	#%11111110,d3
	move.l	textDemoWidthRawX16,d4	; max scroll value
	clr.w	d5

	;---------------------
	; Compute next values
	;---------------------

	moveq.l	#CURVE_SPEED-1,d0
cc_for:	
	; Load next curve value
	move.b	(a2)+,d1
	cmp.b	d2,d1
	bne.s	cc_sum
	; If d1=127, load next curve table
	addq.l	#4,a1
	move.l	(a1),a2
	cmp.l	#0,a2
	bne.s	cc_adr
	; If a2=0, loop table
	lea	curve_toc_loop,a1
	move.l	(a1),a2
cc_adr:	; Load next curve value
	move.b	(a2)+,d1
cc_sum:	
	ext.w	d1			; extends byte to word 
	ext.l	d1			; extends word to long word	
	; Compute sum
	add.l	d1,d7
	; Offset < 0
	bge.s	cc_min
	add.l	d4,d7
cc_min:	; Offset > max
	cmp.l	d7,d4
	bge.s	cc_max
	sub.l	d4,d7
cc_max:
	; Append offset to the buffer
	
	clr.w	d5
	move.b	d7,d5
	add.w	d5,d5
	add.w	d5,d5
	move.l	(a3,d5.w),d5

	move.l	d5,(a5)+
	move.l	d5,(a6)+

	; Append offset to the buffer

	move.l	d7,d6
	lsr.l	#3,d6
	and.b	d3,d6

	move.w	d6,(a5)+
	move.w	d6,(a6)+

	; Play sample
	cmp.w	#CURVE_SPEED/2,d0
	bne.s	no_sample
	move.l	a3,save_reg1
	bsr	PLAY_SAMPLE
	move.l	save_reg1(pc),a3
	move.b	#127,d2
	move.b	#%11111110,d3
no_sample:

	; Loop
	dbra d0,cc_for

	;------------------------
	; Save current positions
	;------------------------

	move.l	a1,curve_pos_toc
	move.l	a2,curve_pos_table
	move.l	d7,curve_sum

	;--------------------
	; Shift curve buffer
	;--------------------

	move.l	pos_curve_buffer,a0
	lea	6*CURVE_SPEED(a0),a0
	cmp.l	#curve_buffer_end,a0
	ble.s	cc_buf
	lea	curve_buffer,a0
cc_buf:	move.l	a0,pos_curve_buffer

	RTS

save_reg1:	dc.l 0

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#==============#
;# Curve tables #
;#==============#

curve_toc_intro:
			rept 10
			dc.l cd_zero
			endr
			dc.l cd_fast_sin
			dc.l cd_medium_sin
			dc.l cd_slow_sin
			dc.l cd_splitted
curve_toc_loop:
			dc.l cd_slow_sin
			dc.l cd_slow_sin
			dc.l cd_slow_dist
			dc.l cd_slow_sin
			dc.l cd_slow_sin
			dc.l cd_medium_sin
			dc.l cd_fast_sin
			dc.l cd_medium_sin
			dc.l cd_slow_sin
			dc.l cd_medium_dist
			dc.l cd_medium_sin
			dc.l cd_slow_sin
			dc.l cd_splitted
			dc.l 0

;#==============#
;# Table values #
;#==============#

cd_zero:		dcb.b 160,0
			dc.b  127
cd_splitted:		incbin INC\CURVE\SPLITTED.BIN
cd_slow_sin:		incbin INC\CURVE\SLOWSIN.BIN
cd_medium_sin:		incbin INC\CURVE\MEDSIN.BIN
cd_fast_sin:		incbin INC\CURVE\FASTSIN.BIN
cd_slow_dist:		incbin INC\CURVE\SLOWDIST.BIN
cd_medium_dist:		incbin INC\CURVE\MEDDIST.BIN
;cd_fast_dist:		incbin INC\CURVE\FASTDIST.BIN
			EVEN

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

; (byte AND $F) * cntCombination * TILE_HEIGHT * 8 bytes)
curve_lut:		ds.l 256

;#==================#
;# Current position #
;#==================#

pos_curve_buffer:	ds.l 1
curve_pos_toc:		ds.l 1
curve_pos_table:	ds.l 1
curve_sum:		ds.l 1

;#==============#
;# Curve buffer #
;#==============#

			ds.b 6*CURVE_SPEED
curve_buffer:		ds.b 6*CURVE_LENGTH
curve_buffer_end:	ds.b 6*CURVE_LENGTH
			ds.b 6*CURVE_SPEED

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@