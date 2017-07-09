; +======================================================================+
; | Big Border Demo - Please wait screen			 |
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

	opt	m+,o-,x+,p=68000

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	INCLUDE	CORE.S

;#===============#
;# Runs the demo #
;#===============#

run_demo:

	move.w	#$700,d0
	lea	VIDEO_ADR_HIGH.w,a0
	movep.w	d0,(a0)		; Screen position = $70000

	; Clear screen
	movea.l	#$70000,a1
	moveq	#0,d0 
	move.w	#8000-1,d1
.clear:	move.l	d0,(a1)+
	dbra	d1,.clear

	; Display image
	lea	image+34,a0
	movea.l	#$70000,a1
	lea	73*160+56(a1),a1
	moveq	#54-1,d1
.copy_y:	moveq	#6-1,d0
.copy_x:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.copy_x
	lea	112(a1),a1
	dbra	d1,.copy_y

	; Set Palette
	movem.l	image+2,d0-d7
	movem.l	d0-d7,PALETTE.w
	movem.l	d0-d7,K_PALETTE.w

	IFEQ	PROD-0
loop:	; Wait for VSYNC
	bsr	vsync
	; Check keyboard 
	cmpi.b	#$39,KEYBOARD_DATA.w
	bne.s	loop	
	ENDC

	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

image:	incbin BACK.DAT

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 END
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
