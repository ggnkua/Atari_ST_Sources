; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Fullscreen VBL routine                                               |
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

;#========================#
;# Fullscreen VBL routine #
;#========================#

full_vbl:
	move.l	#open_top,HBL.w		; HBL for the upper border
	move.w	#33,hbl_count		; Set line counter
	move	#$2100,sr
	bsr	clr_palette
	move.w	#$2100,(sp)
	rte

;#==========================#
;# HBL for the upper border #
;#==========================#

open_top:
	subq.w	#1,hbl_count		; Count lines
	beq.s	openit			; At line 34, open top border
	rte

;#=================#
;# Open top border #
;#=================#

openit:
	move.l	#open_top2,HBL.w
	move.l	a7,savea7		; Save a7
	stop	#$2100			; Stop until next HBL

open_top2:
	move	#$2700,sr		; [ 4] Mask all interrupts
	addq.l	#6,sp			; [ 2] Repair stack

	lea	SCREEN_FREQ.w,a0	; [ 2] Video synchronization mode (0=60hz, 2=50hz)
	lea	SCREEN_RES.w,a1		; [ 2] Shifter resolution (0=Low, 1=Mid, 2=High)
	moveq.l	#0,d0			; [ 1]
	
	fill_nop_81			; [81]
	move.b	d0,(a0)			; [ 2] Set synchronization mode to 60 Hz
	fill_nop_19			; [19]
	move.w	a0,(a0)			; [ 2] Set synchronization mode to 50 Hz

	; From here the top border is opened
	
waitsync:
	move.b	VIDEO_COUNTER.w,d1	; Video address pointer (Low byte)
	beq.s	waitsync
	not.w	d1			; Negate value
	lsr.w	d1,d1			; Synchronization with the beam

	; From here the code is synchronous with the scanning beam
	; Now there are 74 remaining nops before next line
	
	; Initializations background
	move.l	pos_backg_buffer,a5	; [ 5]
	move.l	pos_palette_color,a6	; [ 5]
	lea	PALETTE+2.w,a7		; [ 2]

	; Initializations palette (only used during
	; syncscroll to prefetch palette into registers)
	lea	palette,a4		; [ 3]

	; Initializations sound
	move.l	sound_table_pos,d7	; [ 5]
	move.l	#volume_table,d5	; [ 3]

	; Initializations syncscroll
	lea	sync_addresses,a2	; [ 3]
	move.l 	(a2)+,a3		; [ 3]
	jmp 	(a3)			; [ 2] => [31]

;#===================================#
;# End of the Fullscreen VBL routine #
;#===================================#

end_vbl:
	move.l	savea7,a7		; Restore a7
	move.w	#$2300,(sp)		; SR set
	st	vbl_flag
	rte

;#==================================#
;# Temporary VBL & Timer B routines #
;#==================================#

tmp_vbl:st vbl_flag			; Set VBL-Flag
timer_b:rte

;#========================#
;# Wait for vertical sync #
;#========================#

vsync:	sf	vbl_flag		; Clear VBL-Flag
wvsync:	tst.b	vbl_flag		; Wait until it is set by VBL routine
	beq.s	wvsync
	rts

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

savea7:		ds.l 1
hbl_count:	ds.w 1
vbl_flag:	ds.b 1
		even

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
