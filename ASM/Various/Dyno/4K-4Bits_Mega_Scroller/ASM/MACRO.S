; +======================================================================+
; | Constants and macros                                                 |
; +======================================================================+
; | Copyright (c) 2015-2017 Frederic Poeydomenge <dyno@aldabase.com>     |
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

;#==================#
;# System Constants #
;#==================#

STRIPE_SRC		=  $1000
STRIPE_DST		=  $1004
BLOC_ADR		=  $1008
BLOC_LINE		=  $100C
SHIFT_STE		=  $101E
PALETTE_SRC 	=  $1020

STACK@		= $50000
BACKG@		= $50000
SCREEN@		= $60000

;#===========#
;# Constants #
;#===========#

HBL		= $68		; HBL interrupt vector
VBL		= $70		; VBL interrupt vector
TD_ITR		= $110		; Timer D (USART timer)
TC_ITR		= $114		; Timer C (200hz Clock)
TB_ITR		= $120		; Timer B (HBL)
TA_ITR		= $134		; Timer A interrupt
MFP_PORT		= $FFFFFA01		; I/O port of the MFP
MFP_ENABLE_A	= $FFFFFA07		; Interrupt Enable A
MFP_MASK_A		= $FFFFFA13		; Interrupt Mask A
MFP_ENABLE_B	= $FFFFFA09		; Interrupt Enable B
MFP_MASK_B		= $FFFFFA15		; Interrupt Mask B
MFP_VR		= $FFFFFA17		; Vector Register
MFP_CTRL_A		= $FFFFFA19		; Timer A Control
MFP_DATA_A		= $FFFFFA1F		; Timer A Data
MFP_CTRL_B		= $FFFFFA1B		; Timer B Control
MFP_DATA_B		= $FFFFFA21		; Timer B Data
VIDEO_ADR_HIGH	= $FFFF8201		; Video screen memory position (High byte)
VIDEO_ADR_MID	= $FFFF8203		; Video screen memory position (Mid byte)
VIDEO_ADR_LOW	= $FFFF820D		; Video screen memory position (Low byte)
VIDEO_COUNTER	= $FFFF8209		; Video Counter LSB
STE_SCAN_WIDTH	= $FFFF820F		; Width of a scanline (width in words-1)
STE_HSCROLL_NP	= $FFFF8264		; Horizontal scroll register without prefetch
STE_HSCROLL		= $FFFF8265		; Horizontal scroll register with prefetch
SCREEN_FREQ		= $FFFF820A		; Video synchronization mode (0=60hz, 2=50hz)
SCREEN_RES		= $FFFF8260		; Shifter resolution (0=Low, 1=Mid, 2=High)
PALETTE		= $FFFF8240		; Video palette register 0
FDC_ACCESS		= $FFFF8604		; FDC access/sector count
DMA_MODE		= $FFFF8606		; DMA mode/status
DMA_BASE_HIGH	= $FFFF8609		; DMA base and counter (High byte)
DMA_BASE_MID	= $FFFF860B		; DMA base and counter (Mid byte)
DMA_BASE_LOW	= $FFFF860D		; DMA base and counter (Low byte)
YM_REGISTER		= $FFFF8800		; YM2149 Register select
YM_WRITE_DATA	= $FFFF8802		; YM2149 Write data
KEYBOARD_CTRL	= $FFFFFC00		; Keyboard ACIA control
KEYBOARD_DATA	= $FFFFFC02		; Keyboard ACIA data
FIFTY_HZ		= 2		; 50Hz
SIXTY_HZ		= 0		; 60Hz
LOW_RES		= 0		; Low resolution
MID_RES		= 1		; Medium resolution
HIGH_RES		= 2		; High resolution
OPCODE_NOP		= $4E71		; NOP
OPCODE_RTE		= $4E73		; RTE
OPCODE_RTS		= $4E75		; RTS

;#========================================#
;# Return from interruption : set SR      #
;# without modifying CCR conditions codes #
;#========================================#

SET_SP_2700:	MACRO
	or.w	#$2700,(sp)
	ENDM

SET_SP_2500:	MACRO
	SET_SP_2700
	and.w	#$FDFF,(sp)
	ENDM

SET_SP_2300:	MACRO
	SET_SP_2700
	and.w	#$FBFF,(sp)
	ENDM

SET_SP_2100:	MACRO
	SET_SP_2700
	and.w	#$F9FF,(sp)
	ENDM

;#==========================#
;# Set supervisor/user mode #
;#==========================#

SUPER:	MACRO
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	ENDM

;#==========#
;# Test STE #
;#==========#

TEST_STE:	MACRO
	SECTION TEXT
	clr.w	d7
	; _p_cookies, pointer to cookie jar
	move.l	$5A0.w,d0
	beq.s	end_detect
	move.l	d0,a0
.loop:	move.l	(a0)+,d0
	beq.s 	end_detect
	; Check for _MCH cookie
	cmp.w	#'CH',d0
	bne.s	.end_mch
	; _MCH cookie found
	move.b	1(a0),d1
	and.b	#%11,d1
	subq.b	#1,d1
	bset	d1,d7
	btst.b	#4,3(a0)
	beq.s	.end_mch
	; Mega STE : switch to 8Mhz
	clr.b	$FFFF8E21.w
.end_mch:	; Next cookie
	addq.w	#4,a0
	bra.s	.loop
end_detect:	; Save STE flag
	lea	is_ste(pc),a0
	move.w	d7,(a0)
	SECTION BSS
is_ste:	ds.w	1
	SECTION TEXT
	ENDM
