; +======================================================================+
; | 32B NOISE, by DYNO                             		 |
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
offset	equr d1
screen	equr a1
	
;=============
; Set palette
;=============

	pea	*-8(pc)
	move.w	#6,-(sp)
	trap	#14

;===========
; Main loop
;===========

loop:	; start - 256 = Start of the basepage
	;   +4 = First byte after the end of the TPA (= screen address !)
	move.l	start-256+4(pc),screen

	move.w	#32000/8-1,offset	; For each long word on the screen
frame:	move.l	noise,(screen)+	; Copy noise to screen (bp 0/1)
	eor.l	offset,noise	; Noise effect #1	
	roxl.l	offset,noise	; Noise effect #2
	move.l	noise,(screen)+	; Copy noise to screen (bp 2/3)
	dbra	offset,frame	; Next long word

	bra.s	loop		; Infinite loop
