; +======================================================================+
; | 128 BYTES FULLSCREEN - Atari STF/E                                   |
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

fill_nop_0: MACRO
	ENDM
fill_nop_5: MACRO
	lsr.l	#6,d0		; [ 5] 8+2n
	ENDM
fill_nop_18: MACRO
	moveq    	#30,d0     		; [ 1]
	lsr.l	d0,d0		; [17] 8+2n
	ENDM
fill_nop_70: MACRO
	moveq	#14,d0		; [1]
	subq.l	#1,d0		; [2*VALUE]
	bne.s	*-2		; [3*(VALUE-1)+2]
	ENDM
fill_nop_88: MACRO
	moveq	#22,d0		; [1]
	subq.w	#1,d0		; [1*VALUE]
	bne.s	*-2		; [3*(VALUE-1)+2]
	ENDM

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	OUTPUT	.TOS
	OPT	O+,D-,X-,P+

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

;--------------------
; Set screen address
;--------------------

	moveq	#5,d3
	swap	d3		; d3 = Video screen memory position = $50000
	move.l	d3,$FFFF8200.w

;--------------------------------
; Install Fullscreen VBL routine
;--------------------------------

	lea	vbl(pc),a2
	move.l	a2,$70.w

;---------------
; Infinite loop
;---------------

	bra.s	*

;#========================#
;# Fullscreen VBL routine #
;#========================#

vbl:	move.w	#$2700,sr		; Disable interruptions

	move.w	#1073,d0
.wait_top:	subq.w	#1,d0
	bne.s	.wait_top		; Wait until reach HBL line 33

	lea	$FFFF820A.w,a0	; Video synchronization mode (0=60hz, 2=50hz)
	move.w	#274,d7		; Set line counter

	move.b	d0,(a0)		; Set synchronization mode to 60 Hz
	fill_nop_18			; [19]
	move.l	d3,a3		;     -[ 1]
	move.w	a0,(a0)		; Set synchronization mode to 50 Hz
	; From here the top border is opened

.wait_sync:	move.b	$FFFF8209.w,d0	; Video address pointer (Low byte)
	beq.s	.wait_sync
	not.l	d0		; Negate value
	lsr.w	d0,d0		; Synchronization with the beam
	; From here the code is synchronous with the scanning beam

	; Synchro-line (72 nops)
	lea	$FFFF8260.w,a1	; [ 2] Shifter resolution (0=Low, 2=High)
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
.bottom3:	subq.w	#5,d6		;     -[ 1]
	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	addq.b	#2,d3		; [ 1]
	move.b	d0,(a1)		; [ 2] Get back to low-res
	fill_nop_0			; [11]
	move.w	(a2),(a3)		;     -[ 3]
	eor.w	d6,(a3)		;     -[ 3]
	lea	230(a3),a3		;     -[ 2]
	dbra	d7,.full_line	;     -[ 3]

	; End of the fullscreen VBL routine
	rte

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

supervisor:	ds.b 32
