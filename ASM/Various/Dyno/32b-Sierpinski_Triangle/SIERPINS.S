; +======================================================================+
; | 32B SIERPINSKI TRIANGLES, by DYNO                                    |
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

intin	equr a3
ptsin	equr a4

;===================
; Initialize Line-A
;===================

	dc.w	$A000
	movem.l	(a0),a1/a2/intin/ptsin

;===========
; Main loop
;===========

	move.l	60(a0),(ptsin)	; 319+199 -> ptsin
loop:
	move.l	(ptsin),d0		; d0.w = Y
	and.w	(ptsin),d0		; d0.w = Y and X
	sne	1(intin)		; Color = (X and Y != 0) ? FF : 00
	dc.w	$A001		; Put pixel

	subq.w	#1,(ptsin)		; Next X
	bge.s	loop		; Loop X

	move.w	#319,(ptsin)

	subq.l	#1,(ptsin)		; Next Y
	bge.s	loop		; Loop Y
