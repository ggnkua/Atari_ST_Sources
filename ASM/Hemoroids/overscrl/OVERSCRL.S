; +======================================================================+
; | 256-byte intro for SOMMARHACK 2021 by Dyno / Hemoroids               |
; +======================================================================+
; | Copyright (c) 2021 Frederic Poeydomenge <dyno@aldabase.com>          |
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

	INCLUDE	MACRO.S
	INCLUDE	MACROVER.S

	OUTPUT	.TOS
	OPT	O+,D-,X-,P+

SCREEN@	equ	$180		; * $100 = $18000
STRIPES	equ	31
HEIGHT	equ	62

noise	equr	d4
frame	equr	d6		; Frame number

;-----------------
; Supervisor-mode
;-----------------
; Set a7 to Basepage::p_blen.w (Length of the BSS section = $0020)
; followed by command line address (that will become our new stack pointer)

	lea.l	*-256+30(pc),a7	; 0020 xxxx xxxx (Super)
	trap	#1		; Call GEMDOS

;----------------------
; Initialize MFP 68901
;----------------------

	clr.l	$FFFFFA06.w		; No timer A-B (FFFA07) C-D (FFFA09)

;----------------------------
; Fill one stripe with noise
;----------------------------

	lea	(SCREEN@*$100)+160,a5	; Video screen memory position
	move.l	a5,a4

	clr.l	frame
	move.w	#HEIGHT*230/2-1,frame
word:
	eor.w	frame,noise		; Noise effect #1
	roxl.w	frame,noise		; Noise effect #2

	move.l	frame,d0
	divu.w	#115,d0
	move.w	d0,d3		; d3.w = line from HEIGHT-1 to 0
	swap	d0		; d0.w = row from 114 to  0
	subq.w	#3,d0		; d0.w = row from 111 to -3

	move.b	d0,d1
	and.b	#%1111,d1
	cmpi.b	#4,d1
	bpl.s	.not_col
	lsl.w	#1,noise		; Low-order bit = 0
.not_col:
	and.b	#%11110000,d0
	lsr.b	#1,d0
	cmp.b	d0,d3
	bne.s	.not_row
	clr.w	-230(a5)
	clr.w	noise
.not_row:
	move.w	noise,(a5)+		; Copy noise to screen
	dbra	frame,word
	; here frame=-1

;-------------
; Copy stripe
;-------------

copy:	move.l	(a4)+,(a5)+
	cmp.l	#(SCREEN@*$100)+160+((STRIPES+2)*128*230),a5
	bne.s	copy

;--------------------------------
; Install Fullscreen VBL routine
;--------------------------------

	lea	vbl(pc),a2
	move.l	a2,VBL.w

	bra.s	*		; Infinite loop

;#========================#
;# Fullscreen VBL routine #
;#========================#

vbl:	move.w	#$2700,sr		; Disable interruptions

	move.w	#1073,d0
.wait_top:	subq.w	#1,d0
	bne.s	.wait_top		; Wait until reach HBL line 33

	lea	SCREEN_FREQ.w,a0	; Video synchronization mode (0=60hz, 2=50hz)
	move.w	#274,d7		; Set line counter

	move.b	d0,(a0)		; Set synchronization mode to 60 Hz
	fill_nop_19
	move.w	a0,(a0)		; Set synchronization mode to 50 Hz
	; From here the top border is opened

.wait_sync:	move.b	VIDEO_COUNTER.w,d0	; Video address pointer (Low byte)
	beq.s	.wait_sync
	not.l	d0		; Negate value
	lsr.w	d0,d0		; Synchronization with the beam
	; From here the code is synchronous with the scanning beam

	; Synchro-line (72 nops)
	lea	SCREEN_RES.w,a1	; [ 2] Shifter resolution (0=Low, 2=High)
	fill_nop_70			; [70]

	; Full-line (128 nops)
.full_line:	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	move.w	a0,(a0)		; [ 2] Get back to 50 Hz
	move.b	d0,(a1)		; [ 2] Get back to low-res
	fill_nop_88			; [88]
	move.b	(a1),(a0)		; [ 3] Change the display frequency to 60Hz
	move.w	a0,(a0)		; [ 2] Get back to 50Hz
	fill_nop_5			; [13]
	cmp.w	#45+2,d7		;     -[ 2] Open bottom border ? [2nd]
	beq.s	.bottom2		;     -[ 3/2]
	bra.s	.bottom3		;     -[ 3]
.bottom2:	move.b	d0,(a0)		;     -[ 2]
.bottom3:	nop			;     -[ 1]
	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	nop			; [ 1]
	move.b	d0,(a1)		; [ 2] Get back to low-res
	fill_nop_8			; [11]
	dbra	d7,.full_line	;     -[ 3]

	; Scroll
	addq.w	#1,frame		; Inc frame number
	cmpi.w	#STRIPES,frame
	bne.s	.noreset
	clr.w	frame
.noreset:
	; Compute screen @
	moveq	#230/2,d0
	mulu	frame,d0
	add.w	#SCREEN@,d0		; d0.w = screen @ High+Med

	; Set screen @
	movep.w	d0,VIDEO_ADR_HIGH-SCREEN_FREQ(a0)

	; Set palette
	moveq	#16-1,d0
	lea	PALETTE+16*2.w,a2
.set_pal:	move.w	d0,-(a2)
	dbra	d0,.set_pal

	; End of the fullscreen VBL routine
	rte

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

supervisor:	ds.b 32
