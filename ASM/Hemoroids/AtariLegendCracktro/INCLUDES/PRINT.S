; +======================================================================+
; | Print routine                                                        |
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

;#==============================#
;# Resolution dependant options #
;#==============================#

		rsreset
print_bitplanes:	rs.w	1
print_shift:	rs.w	1
print_line_width:	rs.w	1

print_options:	dc.w	8,3,160  ; Low  rez : 4 bpl = 8b, x8, 160b line
		dc.w	4,2,160  ; Mid  rez : 2 bpl = 4b, x4, 160b line
		dc.w	2,1, 80  ; High rez : 1 bpl = 2b, x2,  80b line
		dc.w	8,3,230  ; Full rez : 4 bpl = 8b, x8, 230b line

print_option:	dc.w	0

PRINT_LOW_REZ  = 6*0
PRINT_MID_REZ  = 6*1
PRINT_HIGH_REZ = 6*2
PRINT_FULL_REZ = 6*3

;#===================#
;# Print normal text #
;#===================#
; input
;   a0 = text address
;   a1 = screen address
;   d0 = x
;   d1 = y
;   d5 = color

pt_text	equr	a0
pt_screen	equr	a1
pt_font	equr	a2
pt_tmp	equr	a3

pt_line	equr	d3
pt_offset	equr	d4
pt_color	equr	d5
pt_bitplane	equr	d6

print_text:
	movem.l	d0-a6,-(sp)

	move.w	print_option(pc),d7
	lea	print_options(pc,d7.w),a6

	; Initializations

	move.w	print_shift(a6),d2
	mulu	print_line_width(a6),d1
	clr.l	d7
	move.w	d0,d7
	lsr.l	#4,d7
	lsl.l	d2,d7
	add.l	d7,d1
	add.l	d1,pt_screen

	and.w	#$F,d0
	neg.w	d0
	add.w	#24,d0
	move.w	d0,pt_offset

.text:
	; Read next char
	clr.w	d0
	move.b	(pt_text)+,d0	; Next byte
	beq.s	.end		; Zero? end of the text
	sub.w	#32,d0		; Else, d0=num of char

	; Compute address in font
	lea	kernfont(pc),pt_font	; Font@
	move.w	d0,d1		; Num char
	lsl.w	#3,d1		; Num char * 8
	sub.w	d0,d1		; Num char * 7
	lea	(pt_font,d1.w),pt_font	; Char@

	; For each line
	move.l	pt_screen,pt_tmp
	moveq	#6-1,pt_line
.line:	
	clr.l	d0
	move.b	(pt_font)+,d0	; font byte
	lsl.l	pt_offset,d0	; shifted -> 2x .w

	; For each bitplane
	move.w	(a6),pt_bitplane	; print_bitplanes(a6)
	lsr.w	pt_bitplane		; /2
	subq.w	#1,pt_bitplane
.plane:	btst	pt_bitplane,pt_color
	beq.s	.nextplane
	move.w	pt_bitplane,d1
	add.w	d1,d1

	swap	d0
	or.w	d0,(pt_tmp,d1.w)	; Upper d0
	swap	d0
	add.w	(a6),d1		; print_bitplanes(a6)
	or.w	d0,(pt_tmp,d1.w)	; Lower d0
	
.nextplane:	dbra	pt_bitplane,.plane

	add.w	print_line_width(a6),pt_tmp
	dbra	pt_line,.line

	; Prepare start offset of next char
	sub.b	(pt_font)+,pt_offset	; char width
	cmpi.b	#8,pt_offset
	bgt.s	.keep
	add.b	#16,pt_offset
	add.w	(a6),pt_screen	; print_bitplanes(a6)
.keep:
	; Next text character
	bra.s	.text
.end:
	movem.l	(sp)+,d0-a6

	rts

;#=============================#
;# Font embedded in the kernel #
;#=============================#

kernfont:	incbin ASSETS\FONT.DAT
