; +======================================================================+
; | 4K 4-BITS MEGA SCROLLER, by DYNO                  SILLY VENTURE 2K17 |
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

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
start_backg:

;#=======================#
;# Macros for syncscroll #
;#=======================#

sync_pal_load:	MACRO
	movem.l	(a2)+,d3-d6		; [11]
	ENDM

sync_pal_set1:	MACRO
	lea	$FFFF8252.w,a5	; [ 2]
	move.w	d3,(a5)+		; [ 2]
	move.l	d4,(a5)+		; [ 3] => 7
	ENDM

sync_pal_set2:	MACRO
	movem.l	d5/d6,(a5)		; [ 6]
	ENDM

;#=======================#
;# Macros for fullscreen #
;#=======================#

background_init:	MACRO	
	move.l	PALETTE_SRC.w,a3	; [ 4]
	ENDM

background_load:	MACRO
	movem.l	(a3)+,d2-d5		; [11]
	ENDM

background_set:	MACRO
	movem.l	d2-d5,$8242-$8260(a1)	; [11]
	ENDM

;#===================#
;# Update background #
;#===================#

update_background:

	;-------------------------------
	; Increment background position
	;-------------------------------

	lea	backg_pos(pc),a0
	subq.w	#1,(a0)

	;-----------------------
	; Set buffers addresses
	;-----------------------
reset_backg:
	move.w	(a0),d0
	add.w	shift4b(pc),d0
	and.w	#%111,d0
	; * 16 repeats * x lines * 8 colors * 2 bytes palette
	mulu	#16*((pattern_end-pattern)/4)*8*2,d0

	clr.l	d2
	lea	sinus(pc),a1
	move.w	pos_sine(pc),d1
	move.w	(a1,d1.w),d2
	lsr.l	#1,d2
	lsl.l	#4,d2
	add.l	d2,d0

	add.l	#BACKG@,d0
	move.l	d0,PALETTE_SRC.w

	rts

;#=======================#
;# Initialize background #
;#=======================#

init_background:

	;---------------------------
	; Reset background position
	;---------------------------

	lea	backg_pos(pc),a0
	clr.w	(a0)

	;-------------------
	; Initialize buffer
	;-------------------

	moveq	#0,d7
	lea	tile+4(pc),a1
	lea	BACKG@,a6

	moveq	#8-1,d6
.shift:
	moveq	#16-1,d1
.repeat:	lea	pattern(pc),a2
	lea	pattern_end(pc),a3
.line:	move.l	(a2)+,d2
	rol.l	d7,d2
	moveq	#8-1,d0
.numb:	move.w	d2,d3
	and.w	#$000F,d3
	add.w	d3,d3
	move.w	(a1,d3.w),(a6)+
	ror.l	#4,d2
	dbra	d0,.numb
	cmp.l	a2,a3
	bne.s	.line
	dbra	d1,.repeat

	addq.w	#4,d7
	dbra	d6,.shift

	bra.s	reset_backg

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

pattern:		incbin INC\PALETTE.BIN
pattern_end:

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

backg_pos:		ds.w 1

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end_backg: