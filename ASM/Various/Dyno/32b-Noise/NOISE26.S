; +======================================================================+
; | 26B NOISE, by DYNO                             		 |
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

start:

;==================
; Register equates
;==================

noise	equr d0
offset	equr d7
screen	equr a1

;===================
; Initialize offset
;===================
; Should be divisible by 4

	moveq	#6,offset

;=============
; Set palette
;=============

	pea	*-8(pc)
	move.w	offset,-(sp)
	trap	#14

;===========
; Main loop
;===========

	move.l	start-256+4(pc),screen	; -256 = Start of the basepage
				;   +4 = First byte after the end of the TPA
				; (= screen address !)
loop:	eor.l	offset,noise	; Noise effect #1
	roxl.l	offset,noise	; Noise effect #2
	
	; Copy noise to screen (modulo 65536)
	; -2, because initial offset value (#6) is not divisible by 4
	move.l	noise,-2(screen,offset.w)

	addq.l	#4,offset		; Next offset
	bra.s	loop		; Infinite loop
