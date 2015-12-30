; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Generated code for the overscan                                      |
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

; #======================================================================#
; # Used registers                                                       #
; #----------------------------------------------------------------------#
; # Overall       a0 = overscan routine      d0 = overscan routine       #
; #               a1 = overscan routine                                  #
; #----------------------------------------------------------------------#
; # Syncscroll    a2 = next rout address                                 #
; #               a3 = tmp adress                                        #
; #----------------------------------------------------------------------#
; # Text          a2 = buffer start          d6 = text offset            #
; #               a3 = tmp @ in buffer                                   #
; #               a4 = screen address                                    #
; #----------------------------------------------------------------------#
; # Background    a5 = palette curve         d1/d4 = movem palette       #
; #               a6 = palette color                                     #
; #               a7 = $ffff8242 (col. 01)                               #
; #----------------------------------------------------------------------#
; # Sound replay                             d7 = sound buffer           #
; #                                          d5 = volume table           #
; #======================================================================#

left_border: MACRO
	move.w	a1,(a1)			; [ 2]
	nop				; [ 1]
	move.b	d0,(a1)			; [ 2]
	ENDM

right_border: MACRO
	move.b 	d0,(a0)			; [ 2]
	move.w 	a0,(a0)			; [ 2]
	ENDM

stabilisator: MACRO
	move.w 	a1,(a1)			; [ 2] Change the resolution to high-res
	nop				; [ 1]
	move.b 	d0,(a1)			; [ 2] Get back to low-res
	ENDM

big_block_init:	MACRO
	move.l	buffer_big_dst,a4	; [ 5]
	lea     buffer_big,a2		; [ 3]
	move.l  a2,usp			; [ 1] => [ 9]
	ENDM

small_block_init: MACRO
	move.l	buffer_small_dst,a4	; [ 5]
	lea     buffer_small,a2		; [ 3]
	move.l  a2,usp			; [ 1] => [ 9]
	ENDM

copy_start_line: MACRO
	; Next buffer value (.l = decal + .l = start of text)
	move.l  usp,a3			; [ 1]
	move.l	(a3)+,d6		; [ 3]
	move.l	(a3)+,a2		; [ 3]
	move.l  a3,usp			; [ 1] => [ 8]
	ENDM

copy_single_block: MACRO
	move.w	(a2)+,a3		; [ 2]
	add.l	d6,a3			; [ 2]
	move.l	(a3)+,(a4)+		; [ 5]
	move.l	(a3)+,(a4)+		; [ 5] => [14]
	ENDM

copy_end_line: MACRO
	lea	22(a4),a4		; [ 2]
	ENDM

background_init: MACRO
	move.w	(a5)+,d4		; [ 2]
	ENDM

background_load: MACRO
	movem.l	(a6,d4.w),d1-d4		; [13] 20+8n
	ENDM

background_set: MACRO
	movem.l	d1-d4,(a7)		; [10] 8+8n
	lea	32(a6),a6		; [ 2] => [12]
	ENDM

palette_init: MACRO
	movem.l	(a4),d2/d3/d4/d6	; [11] 12+8n
	ENDM

palette_set: MACRO
	move.w	d2,PALETTE+18.w		; [ 3]
	movem.l	d3/d4/d6,PALETTE+20.w	; [ 9] 12+8n => [12]
	ENDM
	
;#===============#
;# Generate Code #
;#===============#

INIT_GENERATED_CODE:
	lea	genc_generated,a1
loopg:	move.l	(a0)+,a2
gencg:	move.w	(a2)+,(a1)+
	cmpi.w	#OPCODE_RTE,(a2)
	beq.s	endg
	cmpi.w	#OPCODE_RTS,(a2)
	bne.s	gencg
	bra.s	loopg
endg:	move.w	#OPCODE_RTE,(a1)+
	RTS
	
	SECTION BSS

genc_generated:		ds.b 24400
genc_generated_end:

	SECTION TEXT

;#=========================================================#
;# Remove sample replay from generated code (during intro) #
;#=========================================================#
; Replace YM2149 write code :
;	movep.l	d2,1440(a1)		; [ 7]
;	move.l	d3,1440(a1)		; [ 4] (8 bytes, 11 nops)
; by dummy code :
;	clr.l   	PALETTE.w 	; [ 6]
;	clr.l   	PALETTE.w 	; [ 6] (8 bytes, 12 nops ?!?)
; Input:
;   a0 = start of buffer to parse
;   a1 = end of buffer to parse

GENC_DISABLE_SAMPLE:
gd_loop:move.l	(a0),d0
	cmp.l	#$05C905A0,d0		; movep.l d2,1440(a1)
	bne.s	gd_notf
	move.l	#$42B88240,(a0)		; clr.l   PALETTE.w
	move.l	#$42B88240,4(a0)	; clr.l   PALETTE.w
gd_notf:addq.l	#2,a0
	cmp.l	a0,a1
	bne.s	gd_loop
	RTS

GENC_ENABLE_SAMPLE:
ge_loop:move.l	(a0),d0
	cmp.l	#$42B88240,d0		; clr.l   PALETTE.w
	bne.s	ge_notf
	move.l	#$05C905A0,(a0)		; movep.l d2,1440(a1)
	move.l	#$234305A0,4(a0)	; move.l  d3,1440(a1)
ge_notf:addq.l	#2,a0
	cmp.l	a0,a1
	bne.s	ge_loop
	RTS

;#===============================================#
;# Routs for the 276 scanlines                   #
;#   - 6 lines (1+5) reserved for sync-scrolling #
;#   + end of the fullscreen VBL routine         #
;#===============================================#

genc_table_demo:
	dc.l	init_big_block
	REPT	18
	dc.l	line_6,line_4,line_6,line_4,line_6,line_mid
	dc.l	line_6,line_4,line_6,line_4,line_end
	ENDR
	dc.l	init_small_block
	; Small buffer, two lines
	dc.l	line_6,line_4,line_6,line_4,line_6,line_mid
	dc.l	line_6,line_4
	dc.l	rout_bottom_1,rout_bottom_2			; open bottom at line 213
	dc.l	line_6,line_4,line_end
	; Small buffer, two lines
	dc.l	line_6,line_4,line_6,line_4,line_6,line_mid
	dc.l	line_6,line_4,line_6
	dc.l	rout_bottom_1,rout_bottom_2			; open bottom at line 229
	dc.l	line_4,line_end
	; Small buffer, 8 remaining lines
	REPT 	4
	dc.l	line_6,line_4,line_6,line_4,line_6,line_mid
	dc.l	line_6,line_4,line_6,line_4,line_end
	ENDR
	dc.l	rout_overline
	dc.l	end_vbl

genc_table_intro:
	dc.l	init_big_block
	REPT	18
	dc.l	line_6,line_4,line_6,line_4,line_6,line_mid
	dc.l	line_6,line_4,line_6,line_4,line_end
	ENDR
	dc.l	end_vbl

;#===================#
;# Scanline routines #
;#===================#

rout_overline:
	left_border			; [ 5]
	fill_nop_58			; [89]
	sample_replay			;     -[29]
	background_init			;     -[ 2]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts

rout_bottom_1: ; 127 nop
	move.w 	a1,(a1)			; [ 2] Left border
	nop				; [ 1]
	move.b 	d0,(a1)			; [ 2]
	fill_nop_45			; [89]
	sample_replay			;     -[29]
	background_init			;     -[ 2]
	movem.l	(a6,d4.w),d2-d4/a3	;     -[13] 20+8n
	move.b 	d0,(a0)			; [ 2] Right border
	move.w 	a0,(a0)			; [ 2]
	fill_nop_10			; [10]
	move.b 	d0,(a0)			; [ 2] Bottom margin 1
	nop				; [ 1]
	move.w 	a1,(a1)			; [ 2] Stabilisator
	nop				; [ 1]
	move.b 	d0,(a1)			; [ 2]
	fill_nop_1			; [11]
	movem.l	d2-d4/a3,(a7)		;     -[10] 8+8n
	rts

rout_bottom_2: ; 129 nop
	move.w 	a1,(a1)			; [ 2] Left border
	move.w 	a0,(a0)			; [ 2] Bottom margin 2
	move.b 	d0,(a1)			; [ 2]
	fill_nop_56			; [89]
	sample_replay			;     -[29]
	lea	32(a6),a6		;     -[ 2]
	background_init			;     -[ 2]
	move.b 	d0,(a0)			; [ 2] Right border
	move.w 	a0,(a0)			; [ 2]
	;fill_nop_13			; [13]
	movem.l	(a6,d4.w),d2-d4/a3	;     -[13] 20+8n
	move.w 	a1,(a1)			; [ 2] Stabilisator
	nop				; [ 1]
	move.b 	d0,(a1)			; [ 2]
	;fill_nop_12			; [12]
	movem.l	d2-d4/a3,(a7)		;     -[10] 8+8n
	lea	32(a6),a6		;     -[ 2]
	rts

init_big_block:
	left_border			; [ 5]
	;fill_nop_89			; [89]
	palette_set			;     -[12]
	sample_replay			;     -[29]
	big_block_init			;     -[ 9]
	copy_start_line			;     -[ 8]
	background_init			;     -[ 2]
	fill_nop_29			;     -[29]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts

init_small_block:
	left_border			; [ 5]
	fill_nop_41			; [89]
	sample_replay			;     -[29]
	small_block_init		;     -[ 9]
	copy_start_line			;     -[ 8]
	background_init			;     -[ 2]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts

line_6:
	left_border			; [ 5]
	fill_nop_3			; [89]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	background_init			;     -[ 2]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts

line_4:
	left_border			; [ 5]
	fill_nop_2			; [89]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	sample_replay			;     -[29]
	background_init			;     -[ 2]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts

line_mid:
	left_border			; [ 5]
	fill_nop_6			; [89]
	copy_end_line			;     -[ 2]
	copy_start_line			;     -[ 8]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	sample_replay			;     -[29]
	background_init			;     -[ 2]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts

line_end:
	left_border			; [ 5]
	fill_nop_6			; [89]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	copy_single_block		;     -[14]
	sample_replay			;     -[29]
	copy_end_line			;     -[ 2]
	copy_start_line			;     -[ 8]
	background_init			;     -[ 2]
	right_border			; [ 4]
	background_load			; [13]
	stabilisator			; [ 5]
	background_set			; [12]
	rts
