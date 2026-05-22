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

K_MAGICNUM		= $200		; = "DYNO"
K_MACHINE		= $204
K_MEM_SIZE		= $206
K_MMU_LINE		= $208
K_MMU_SKIP		= $20A
K_WAKESTATE		= $20C
K_QVBL		= $210
K_NB_VBL		= $214

K_SAV_TRAP1		= $220
K_SAV_TRAP2		= $224
K_SAV_TRAP13	= $228
K_SAV_TRAP14	= $22C
K_SAV_ILLG		= $230

K_LOAD_SCR		= $250
K_EXEC_SCR		= $251
K_LOAD_TOC		= $252
K_LOAD_DATA		= $256

K_VSHARED		= $260

K_RET_PC		= $280
K_RET_SP		= $284

K_PALETTE		= $2E0
K_COPY_ROUT		= $2F0		; 12 bytes ($2F0..$2FC)

;#===========#
;# Constants #
;#===========#

HBL		= $68		; HBL interrupt vector
VBL		= $70		; VBL interrupt vector
TB_HBL		= $120		; Timer B (HBL)
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

;#==========================#
;# Set supervisor/user mode #
;#==========================#

SUPER:	MACRO
	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq	#6,sp
	ENDM

USER:	MACRO
	SUPER
	ENDM

;#==================#
;# Quit the program #
;#==================#

PTERM:	MACRO
	clr.w	(sp)
	trap	#1
	ENDM

;#================================#
;# Save the MFP vectors/registers #
;#================================#

SAVE_MFP:	MACRO

	movem.l	$120.w,d0-d7
	movem.l	d0-d7,old_vectors+64
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,old_vectors+32
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,old_vectors	

	lea	MFP_PORT.w,a0
	lea	old_mfp,a1
	moveq	#16,d0
get_m\@:	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,get_m\@

	SECTION BSS
old_mfp:		ds.b 24
old_vectors:	ds.l 24
	SECTION TEXT

	ENDM

;#===================================#
;# Restore the MFP vectors/registers #
;#===================================#

RESTORE_MFP: MACRO

	move.w	#$2700,sr

	movem.l	old_vectors+64,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	old_vectors+32,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	old_vectors,d0-d7
	movem.l	d0-d7,$58.w

	lea	old_mfp,a0
	lea	MFP_PORT.w,a1
	move.w	#16,d0
put_m\@:	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,put_m\@

	move #$2300,sr

	ENDM

;#===================================#
;# Set default MFP vectors/registers #
;#===================================#

CLR_MFP:	MACRO
	clr.b	MFP_ENABLE_A.w	; No timer A-B
	clr.b	MFP_MASK_A.w	;
	clr.b	MFP_ENABLE_B.w	; No timer C-D
	clr.b	MFP_MASK_B.w	;
	bclr	#3,MFP_VR.w		; Automatic End Of Interrupt
	ENDM

;#===========================#
;# Save screen configuration #
;#===========================#

SAVE_PHYSBASE: MACRO
	lea	old_physbase,a0
	clr.b	(a0)+
	move.b	VIDEO_ADR_HIGH.w,(a0)+
	move.b	VIDEO_ADR_MID.w,(a0)+
	move.b	VIDEO_ADR_LOW.w,(a0)+
	SECTION BSS
old_physbase:	ds.l 1
	SECTION TEXT
	ENDM

SAVE_PALETTE: MACRO
	movem.l	PALETTE.w,d0-d7
	movem.l	d0-d7,old_palette
	SECTION BSS
old_palette:	ds.w 16
	SECTION TEXT
	ENDM

SAVE_SYNC:	MACRO
	move.b	SCREEN_FREQ.w,old_sync
	SECTION BSS
old_sync:		ds.b 1
	SECTION TEXT
	ENDM

SAVE_RES:	MACRO
	move.b	SCREEN_RES.w,old_res
	SECTION BSS
old_res:		ds.b 1
	SECTION TEXT
	ENDM

;#==============================#
;# Restore screen configuration #
;#==============================#

RESTORE_PHYSBASE: MACRO
	lea	old_physbase,a0
	move.b	(a0)+,d0
	move.b	(a0)+,VIDEO_ADR_HIGH.w
	move.b	(a0)+,VIDEO_ADR_MID.w
	move.b	(a0)+,VIDEO_ADR_LOW.w
	ENDM

RESTORE_PALETTE: MACRO
	movem.l	old_palette,d0-d7
	movem.l	d0-d7,PALETTE.w
	ENDM

RESTORE_SYNC: MACRO
	move.b	old_sync,SCREEN_FREQ.w
	ENDM

RESTORE_RES: MACRO
	move.b	old_res,SCREEN_RES.w
	ENDM

;#==========================#
;# Set screen configuration #
;#==========================#

SET_PHYSBASE: MACRO ADR_BUFFER,ADR_PHYSIQUE
	lea	\1,a0
	lea	\2,a1
	move.l	a0,d0
	addi.l	#256,d0
	clr.b	d0
	move.l	d0,(a1)
	move.b	d0,VIDEO_ADR_LOW.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_MID.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_HIGH.w
	ENDM

SET_PHYSBASE_OVERSCAN: MACRO ADR_BUFFER,ADR_PHYSIQUE
	SET_PHYSBASE \1,\2
	addi.l  #160,\2		; 1 regular line for synchronisation (160 bytes)
	ENDM

SET_PALETTE: MACRO ADR_PALETTE
	movem.l	\1,d0-d7
	movem.l	d0-d7,PALETTE.w
	ENDM

CLR_PALETTE: MACRO
	clr.l	PALETTE+0.w
	clr.l	PALETTE+4.w
	clr.l	PALETTE+8.w
	clr.l	PALETTE+12.w
	clr.l	PALETTE+16.w
	clr.l	PALETTE+20.w
	clr.l	PALETTE+24.w
	clr.l	PALETTE+28.w
	ENDM

SET_SYNC: MACRO SYNCHRO
	move.b	\1,SCREEN_FREQ.w
	ENDM

SET_RES: MACRO RESOLUTION
	move.b	\1,SCREEN_RES.w
	ENDM

;#======================#
;# Enable/disable mouse #
;#======================#

MOUSE_OFF:	MACRO
off\@:	btst	#1,KEYBOARD_CTRL.w
	beq.s	off\@
	move.b	#$12,KEYBOARD_DATA.w
	ENDM

MOUSE_ON:	MACRO
on\@:	btst	#1,KEYBOARD_CTRL.w
	beq.s	on\@
	move.b	#$8,KEYBOARD_DATA.w
	ENDM
