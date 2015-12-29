; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Manage background curve                                              |
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

BACKG_SPEED	= 6
BACKG_LENGTH	= 300			; Length of buffer = BACKG_SPEED*25

;#=============================#
;# Initialize background curve #
;#=============================#

INIT_BACKGROUND:

	;-------------
	; Clear curve
	;-------------

	lea	backg_buffer,a0
	move.l	#4*BACKG_LENGTH/4-1,d0
pc_clr:	clr.l	(a0)+
	dbra	d0,pc_clr

	;--------------------------
	; Define current positions
	;--------------------------

	lea	backg_buffer,a0
	move.l	a0,pos_backg_buffer

	lea	backg_toc_intro,a0
	move.l	a0,backg_pos_toc
	move.l	(a0),backg_pos_table
	move.l	#1073741824,backg_sum	; 2^30

	RTS

;#==========================#
;# Compute background curve #
;#==========================#

COMPUTE_BACKGROUND:

	clr.l	d2
	lea	palette_bounce,a3
	move.w	iteration_x43,d1
	move.w	(a3,d1.w),d2

	lea	palette_color,a0
	add.l	d2,a0
	move.l	a0,pos_palette_color

	;------------------------
	; Load current positions
	;------------------------

	move.l	pos_backg_buffer,a0	; a0 = current position
	lea	-2*BACKG_SPEED(a0),a5	; a5 = n lines before the buffer
	lea	2*BACKG_LENGTH(a0),a6	; a6 = n lines after the buffer
	move.l	backg_pos_toc,a1
	move.l	backg_pos_table,a2
	move.l	backg_sum,d7

	;---------------------
	; Compute next values
	;---------------------

	moveq.l	#BACKG_SPEED-1,d0
pc_for:	
	; Load next curve value into d1
	move.b	(a2)+,d1
	cmp.b	#127,d1
	bne.s	pc_sum
	; If d1=127, load next curve table into a2
	move.l	(a1)+,a2
	cmp.l	#0,a2
	bne.s	pc_adr
	; If a2=0, loop table
	lea	backg_toc_loop,a1
	move.l	(a1),a2
pc_adr:	; Load next curve value into d1
	move.b	(a2)+,d1
	
pc_sum:	; Compute sum into d7
	ext.w	d1
	ext.l	d1
	add.l	d1,d7

	; Convert d7 to offset 0..14 (step 2)
	move.w	d7,d6
	and.w	#%1110,d6
	
	; Copy offset before and after the buffer
	move.w	d6,(a5)+
	move.w	d6,(a6)+

	; Loop
	dbra d0,pc_for

	;------------------------
	; Save current positions
	;------------------------

	move.l	a1,backg_pos_toc
	move.l	a2,backg_pos_table
	move.l	d7,backg_sum

	;-------------------------
	; Shift background buffer
	;-------------------------

	move.l	pos_backg_buffer,a0
	lea	2*BACKG_SPEED(a0),a0
	cmp.l	#backg_buffer_end,a0
	ble.s	pc_buf
	lea	backg_buffer,a0
pc_buf:	move.l	a0,pos_backg_buffer

	RTS


;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#===================#
;# Background tables #
;#===================#

backg_toc_intro:
			rept 5
			dc.l cd_zero
			endr
backg_toc_loop:
			REPT 3
			dc.l bg_sin1
			dc.l bg_sin1
			dc.l bg_sin2
			dc.l bg_sin2
			dc.l bg_sin3
			dc.l bg_sin3
			ENDR
			dc.l cd_splitted
			dc.l 0

;#==============#
;# Table values #
;#==============#

bg_sin1:		incbin INC\CURVE\BG_SIN1.BIN
bg_sin2:		incbin INC\CURVE\BG_SIN2.BIN
bg_sin3:		incbin INC\CURVE\BG_SIN3.BIN
			EVEN

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#==================#
;# Current position #
;#==================#

pos_backg_buffer:	ds.l 1
backg_pos_toc:		ds.l 1
backg_pos_table:	ds.l 1
backg_sum:		ds.l 1

;#===================#
;# Background buffer #
;#===================#

			ds.w	BACKG_SPEED
backg_buffer:		ds.w	BACKG_LENGTH
backg_buffer_end:	ds.w	BACKG_LENGTH
			ds.w	BACKG_SPEED

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@