; +======================================================================+
; | 64B SIERPINSKI SCROLLER, by DYNO                                     |
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

	OPT O+,D-,X-,P+

;==================
; Register equates
;==================

tmp	equr d0
x	equr d1
y	equr d2
char	equr d3

;============
; Initialize
;============

	lea	string(pc),a3	; a3 = start of string
	pea	(a3)		; Push string address
	move.w	#9,-(sp)		; Cconws

;===========
; Main loop
;===========

	moveq	#-1,y		; Infinite loop
yLoop:
	lea	4(a3),a0		; Return to start of string
	move.b	y,(a0)		; Background color
	bclr	#3,(a0)+		; Background color

	moveq	#40-1,x		; Foreach text column
xLoop:	
	moveq	#'#',char
	move.w	x,tmp
	and.w	y,tmp
	beq.s	.point
	moveq	#' ',char
.point:
	move.b	char,(a0)+		; Copy char

	dbra	x,xLoop		; Next column

	cmp.b	#'#',5(a3)		; If first char = "#"
	bne.s	.nobell		; then play a
	move.b	#7,(a0)+		; Bell sound
.nobell:	clr.b	(a0)+		; EOL

	trap	#1		; Write string

	subq.l	#1,y		; Next line
	bra.s	yLoop

;========
; String
;========
	
string:	dc.b	$0A,$0D		; Carriage return + Line feed
	dc.b	$1B,$63		; Escape + c (Set background color)
