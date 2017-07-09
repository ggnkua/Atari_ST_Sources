; +======================================================================+
; | THOROUGHLY STABLE RASTERS, IN ONLY 128 BYTES, FOR ATARI ST/STE       |
; +======================================================================+
; | Copyright (c) 2016 Frederic Poeydomenge <dyno@aldabase.com>          |
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

SCHEME		= $1000			; Color scheme : $1000 or $0111 for 8 colors

RASTER_LEN	= 65536

PAL		= $FFFF8240		; Video palette register 0
HBL		= $68			; Level 2 Int Autovector (HBL)
VBL		= $70			; Level 4 Int Autovector (VBL)

color		equr d7
inc		equr d6
dir		equr d5
index		equr d4
counter		equr d3
temp		equr d0

raster		equr a5
palette		equr a4

;=====================
; Set supervisor mode
;=====================

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1

;==============
; Clear screen
;==============

	move.l	$44E.w,a0
	move.w	#32000/4-1,counter
clear:	clr.l	(a0)+
	dbra	counter,clear
	; Here counter.w = $FFFF (= RASTER_LEN-1)

;==================
; Compute gradient
;==================

	lea	zone(pc),raster		; Buffer

	clr.w	color			; Palette color
	moveq	#1,inc			; Color increment
	move.w	#%0000000111111100,dir	; Direction : 0 (inc color) or 1 (dec color)
					;   (2 lowest bits are not used)
	;move.w	#RASTER_LEN-1,counter	; Defined in previous loop
gradient:	
	rol.w	#1,dir			; Next direction
	bcs.s	.dec
.inc:	add.w	inc,color		;   =0 : increment color
	bra.s	.save
.dec:	sub.w	inc,color		;   =1 : decrement color
	bne.s	.save			; When color = $000
	rol.w	#2,dir			;   - Reset direction to initial value
	rol.w	#4,inc			;   - Change color
	eor	#SCHEME,inc		;   - Add some entropy to color
.save:
	move.w	color,(raster)+		; Save color in buffer

	dbra	counter,gradient	; Next color

;========================
; Install new interrupts
;========================

	lea	hbl(pc),a0		; Pointer to dummy HBL
	move.l	a0,HBL.w		; Set dummy HBL
	addq.l	#2,a0			; Pointer to new VBL
	move.l	a0,VBL.w		; Set new VBL

wait:	bra.s	wait			; Wait until the VBL start

;===========
; Dummy HBL
;===========

hbl:	rte

;==============================================
; Start of VBL : Synchronization with the beam
;==============================================

vbl:	stop	#$2100			; Wait for first HBL
	move.w	#$2700,sr		; Disable interrupts

	; Wait to be off the screen
	moveq	#15,index		; Between 12 & 17
.off:	subq.w	#1,index
	bne.s	.off
	; Here index.l = 0

	lea	PAL.w,palette

;===========
; Main loop
;===========
; Amount of nops per :
;   * Scan line :   128
;   * Full VBL  : 40064 ( = 313 lines * 128 nops )

main:	move.w	#312-1,counter		; [  2] Line counter
	lea	zone(pc,index.l),raster	; [  4] Pointer to first rasterbar

line:	move.w	(raster)+,(palette)	; [  3] Draw rasterbar
	moveq	#40-1,temp		; [  1] Wait
	dbra	temp,*			; [121] = 40*3+1
	dbra	counter,line		; [  3] Next line
					; [  1] End of dbra = 1 more nop
	addq.w	#2,index		; [  1] Shift start address

	moveq	#38-1,temp		; [  1] Wait
	dbra	temp,*			; [115] = 38*3+1
	nop				; [  1]

	bra.s	main			; [  3] Next scanline

;=============
; Raster data
;=============

	SECTION BSS
	
zone:		ds.w	RASTER_LEN
