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
start_front:

;#=========================================#
;# Macro executed during Full-line routine #
;#=========================================#
	
front_set:	MACRO

	subq.w	#1,$C(a4)		; [ 4] BLOC_LINE
	bne.s	.path2\@		; [ 3/2]
.path1\@:	addq.l	#4,$8(a4)		;   [ 6] BLOC_ADR
	addq.w	#8,$C(a4)		;   [ 4] BLOC_LINE
	move.l	$8(a4),a2		;   [ 4] BLOC_ADR
	move.l	(a2),(a4)		;   [ 5] STRIPE_SRC
	bra.s	.endpath\@		;   [ 3] = 29
.path2\@:	fill_nop_21			; [21] = 28
.endpath\@:
	movem.l	(a4),a5/a6		; [ 7] STRIPE_SRC+STRIPE_DST

	move.l	(a5)+,(a6)+		; [ 5]
	move.l	(a5)+,(a6)+		; [ 5]
	lea	230-8(a6),a6	; [ 2]
	move.l	(a5)+,(a6)+		; [ 5]
	move.l	(a5)+,(a6)+		; [ 5]
	lea	230-8(a6),a6	; [ 2] = 24

	movem.l	a5/a6,(a4)		; [ 6] STRIPE_SRC+STRIPE_DST

	ENDM			; TOTAL: 65 NOPS

;#===================#
;# Update front text #
;#===================#

update_scroller:

	;-----------------------------
	; Every 4 VBL : scroll screen
	;-----------------------------

	lea	update_front(pc),a0
	tst.w	(a0)
	beq.s	.noUpdate

	;-------------------------------
	; Move on to the next text char
	;-------------------------------

	; Need to update text ?
	lea	update_text(pc),a6
	tst.w	(a6)
	beq.s	.nochg

	; update_text=2 : Interpose an empty col
	lea	font(pc),a0
	lea	font_pos(pc),a1
	move.l	a0,(a1)
	subq.w	#1,(a6)
	bne.s	.nochg
	
	; update_text=1 : Get next char
	lea	text_pos(pc),a3
	addq.l	#1,(a3)

	; Text < 0, go back to start of text
	move.l	(a3),a6
	move.b	(a6),d0
	bge.s	.noteot
	lea	text(pc),a2
	move.l	a2,(a3)
.noteot:
	; Load new font @
	lea	font(pc),a0
	lea	font_pos(pc),a1
	clr.l	d1
	move.l	(a3),a6
	move.b	(a6),d1		; char - 32
	lsl.l	#8,d1		; x256
	sub.l	#16,d1
	add.l	d1,a0
	move.l	a0,(a1)
.nochg:
	;---------------------------------
	; Move on to the next text column
	;---------------------------------

	; Next font stripe
	lea	font_pos(pc),a0
	add.l	#16,(a0)

	; font[15] < 0: last column
	move.l	font_pos(pc),a6
	tst.b	15(a6)
	bge.s	.notneg
	lea	update_text(pc),a1	; need to update text
	addq.w	#2,(a1)		; on the next frame
.notneg:
.noUpdate:
	;------------------------
	; Draw a vertical stripe
	;------------------------
	; Initializations

	move.l	font_pos(pc),a0
	lea	tile+34(pc),a2
	lea	frame_stripe+4*3(pc),a4

	;------------------------
	; Draw a vertical stripe
	;------------------------
	; Store 16 blocks @ in frame_stripe buffer

	clr.w	d6
	moveq	#16-1,d0
.draw:	clr.w	d1
	move.b	(a0)+,d1		; tile num
	bge.s	.notinf
	bclr	#7,d1
.notinf:	add.w	d1,d6		; sum of the offsets
	lsl.w	#7,d1		; x128
	lea	(a2,d1.w),a3	; src address
	move.l	a3,(a4)+
	dbra	d0,.draw

	;------------------------
	; Draw a vertical stripe
	;------------------------
	; Count successive empty stripe

	lea	empty_counter(pc),a1
	tst.w	d6
	beq.s	.empty
	clr.w	(a1)
	bra.s	.end
.empty:	addq.w	#1,(a1)
.end:
	;------------------------------
	; Initialize buffers addresses
	;------------------------------
reset_buffer:
	lea	frame_stripe(pc),a0
	move.l	a0,BLOC_ADR.w
	move.w	#8,BLOC_LINE.w
	move.l	BLOC_ADR.w,a0
	move.l	(a0),STRIPE_SRC.w
	move.l	sync_logical(pc),a0
	lea	216-230*16(a0),a0
	move.l	a0,STRIPE_DST.w

	rts

;#=================#
;# Initialize text #
;#=================#

init_scroller:

	;---------------------------------------
	; Complete missing tiles in the tileset
	;---------------------------------------

	; Two oblique blocks (outside)
	lea	tile+34+6*128(pc),a0
	lea	tile+34+10*128(pc),a1
	bsr.s	.copy_top_bottom

	; Two oblique blocks (inside)
	lea	tile+34+10*128(pc),a0
	lea	tile+34+14*128(pc),a1
	bsr.s	.copy_top_bottom

	;----------------------
	; Initialize positions
	;----------------------

	; Text position
	lea	text(pc),a0
	lea	text_pos(pc),a1
	move.l	a0,(a1)

	; Font position
	clr.l	d1
	move.b	(a0),d1		; char - 32
	lsl.l	#8,d1		; x256
	lea	font(pc),a0
	lea	font_pos(pc),a1
	add.l	d1,a0
	move.l	a0,(a1)

	;----------------------------------
	; Initialize "frame_stripe" buffer
	;----------------------------------

	lea	tile+34(pc),a2
	lea	frame_stripe(pc),a3
	moveq	#36-1,d0
.init:	move.l	a2,(a3)+
	dbra	d0,.init

	;------------------------------
	; Initialize buffers addresses
	;------------------------------

	bra.s	reset_buffer

;#=======================================#
;# Complete missing tiles in the tileset #
;#=======================================#

.copy_top_bottom:
	moveq	#32-1,d0
.copy:	movem.l	(a0)+,d1/d2
	movem.l	d1/d2,-(a1)
	dbra	d0,.copy
	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

text:	incbin INC\TEXT.BIN
text_length = *-text

	IFEQ	SIZE-0
font:	incbin INC\SMFONT.BIN
tile:	incbin INC\SMTILE.RAW
	ENDC

	IFEQ	SIZE-1
font:	incbin INC\MDFONT.BIN
tile:	incbin INC\MDTILE.RAW
	ENDC

	IFEQ	SIZE-2
font:	incbin INC\LGFONT.BIN
tile:	incbin INC\LGTILE.RAW
	ENDC

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

update_front:	ds.w 1
update_text:	ds.w 1

empty_counter:	ds.w 1

text_pos:		ds.l 1
font_pos:		ds.l 1

frame_stripe:	ds.l 36

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end_front: