; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Common constants and macros                                          |
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

;#===========#
;# Constants #
;#===========#

HBL		EQU $68			; HBL interrupt vector
VBL		EQU $70			; VBL interrupt vector
TIMER_B_HBL	EQU $120		; Timer B (HBL)
MFP_PORT	EQU $FFFFFA01		; I/O port of the MFP
MFP_ENABLE_A	EQU $FFFFFA07		; Interrupt Enable A
MFP_MASK_A	EQU $FFFFFA13		; Interrupt Mask A
MFP_ENABLE_B	EQU $FFFFFA09		; Interrupt Enable B
MFP_MASK_B	EQU $FFFFFA15		; Interrupt Mask B
MFP_VR		EQU $FFFFFA17		; Vector Register
VIDEO_ADR_HIGH	EQU $FFFF8201		; Video screen memory position (High byte)
VIDEO_ADR_MID	EQU $FFFF8203		; Video screen memory position (Mid byte)
VIDEO_ADR_LOW	EQU $FFFF820D		; Video screen memory position (Low byte)
VIDEO_COUNTER	EQU $FFFF8209		; Video Counter LSB
SCREEN_FREQ	EQU $FFFF820A		; Video synchronization mode (0=60hz, 2=50hz)
SCREEN_RES	EQU $FFFF8260		; Shifter resolution (0=Low, 1=Mid, 2=High)
PALETTE		EQU $FFFF8240		; Video palette register 0
YM_REGISTER	EQU $FFFF8800		; YM2149 Register select
YM_WRITE_DATA	EQU $FFFF8802		; YM2149 Write data
KEYBOARD_CTRL	EQU $FFFFFC00		; Keyboard ACIA control
KEYBOARD_DATA	EQU $FFFFFC02		; Keyboard ACIA data
FIFTY_HZ	EQU 2			; 50Hz
SIXTY_HZ	EQU 0			; 60Hz
LOW_RES		EQU 0			; Low resolution
MID_RES		EQU 1			; Medium resolution
HIGH_RES	EQU 2			; High resolution
OPCODE_NOP	EQU $4E71		; Nop
OPCODE_RTE	EQU $4E73		; Rte
OPCODE_RTS	EQU $4E75		; Rts

;#==========================#
;# Set supervisor/user mode #
;#==========================#

SUPER:	MACRO
	move	sr,d0
	and	#$2000,d0
	bne.s	super\@
	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1
	addq	#6,sp
super\@:move.l	d0,old_ssp
	ENDM

USER:	MACRO
	move.l	old_ssp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
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

SAVE_MFP: MACRO

	movem.l	$120.w,d0-d7
	movem.l	d0-d7,old_vectors+64
	movem.l	$100.w,d0-d7
	movem.l	d0-d7,old_vectors+32
	movem.l	$58.w,d0-d7
	movem.l	d0-d7,old_vectors	

	lea	MFP_PORT.w,a0
	lea	old_mfp,a1
	moveq.w	#16,d0
get_m\@:move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,get_m\@

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
put_m\@:move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,put_m\@

	move #$2300,sr

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
	ENDM

SAVE_PALETTE: MACRO
	movem.l	PALETTE.w,d0-d7
	movem.l	d0-d7,old_palette
	ENDM

SAVE_SYNC: MACRO
	move.b	SCREEN_FREQ.w,old_sync
	ENDM

SAVE_RES: MACRO
	move.b	SCREEN_RES.w,old_res
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
	move.l	\1,d0
	addi.l	#256,d0
	clr.b	d0
	move.l	d0,\2
	move.b	d0,VIDEO_ADR_LOW.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_MID.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_HIGH.w
	ENDM

SET_PALETTE: MACRO ADR_PALETTE
	movem.l	\1,d0-d7
	movem.l	d0-d7,PALETTE.w
	ENDM

SET_SYNC: MACRO SYNCHRO
	move.b \1,SCREEN_FREQ.w
	ENDM

SET_RES: MACRO RESOLUTION
	move.b	\1,SCREEN_RES.w
	ENDM

;#======================#
;# Enable/disable mouse #
;#======================#

MOUSE_OFF: MACRO
off\@:	btst	#1,KEYBOARD_CTRL.w
	beq.s	off\@
	move.b	#$12,KEYBOARD_DATA.w
	ENDM

MOUSE_ON: MACRO
on\@:	btst	#1,KEYBOARD_CTRL.w
	beq.s	on\@
	move.b	#$8,KEYBOARD_DATA.w
	ENDM

;#=============#
;# Section BSS #
;#=============#

		SECTION BSS
old_ssp: 	ds.l 1
old_mfp: 	ds.b 24
old_vectors: 	ds.l 24
old_physbase: 	ds.l 1
old_palette: 	ds.w 16
old_sync: 	ds.b 1
old_res: 	ds.b 1
		SECTION TEXT

;#==================#
;# Fillers Overscan #
;#==================#

fill_dbra_5: MACRO num
	moveq   #0,d1
	dbra    d1,*
	ENDM
fill_dbra_8: MACRO num
	moveq   #1,d1
	dbra    d1,*
	ENDM
fill_dbra_11: MACRO num
	moveq   #2,d1
	dbra    d1,*
	ENDM
fill_dbra_14: MACRO num
	moveq   #3,d1
	dbra    d1,*
	ENDM
fill_dbra_17: MACRO num
	moveq   #4,d1
	dbra    d1,*
	ENDM
fill_dbra_20: MACRO num
	moveq   #5,d1
	dbra    d1,*
	ENDM
fill_dbra_23: MACRO num
	moveq   #6,d1
	dbra    d1,*
	ENDM
fill_dbra_26: MACRO num
	moveq   #7,d1
	dbra    d1,*
	ENDM
fill_dbra_29: MACRO num
	moveq   #8,d1
	dbra    d1,*
	ENDM
fill_dbra_32: MACRO num
	moveq   #9,d1
	dbra    d1,*
	ENDM
fill_dbra_35: MACRO num
	moveq   #10,d1
	dbra    d1,*
	ENDM
fill_dbra_38: MACRO num
	moveq   #11,d1
	dbra    d1,*
	ENDM
fill_dbra_41: MACRO num
	moveq   #12,d1
	dbra    d1,*
	ENDM
fill_dbra_44: MACRO num
	moveq   #13,d1
	dbra    d1,*
	ENDM
fill_dbra_47: MACRO num
	moveq   #14,d1
	dbra    d1,*
	ENDM
fill_dbra_50: MACRO num
	moveq   #15,d1
	dbra    d1,*
	ENDM
fill_dbra_53: MACRO num
	moveq   #16,d1
	dbra    d1,*
	ENDM
fill_dbra_56: MACRO num
	moveq   #17,d1
	dbra    d1,*
	ENDM
fill_dbra_59: MACRO num
	moveq   #18,d1
	dbra    d1,*
	ENDM
fill_dbra_62: MACRO num
	moveq   #19,d1
	dbra    d1,*
	ENDM
fill_dbra_65: MACRO num
	moveq   #20,d1
	dbra    d1,*
	ENDM
fill_dbra_68: MACRO num
	moveq   #21,d1
	dbra    d1,*
	ENDM
fill_dbra_71: MACRO num
	moveq   #22,d1
	dbra    d1,*
	ENDM
fill_dbra_74: MACRO num
	moveq   #23,d1
	dbra    d1,*
	ENDM
fill_dbra_77: MACRO num
	moveq   #24,d1
	dbra    d1,*
	ENDM
fill_dbra_80: MACRO num
	moveq   #25,d1
	dbra    d1,*
	ENDM
fill_dbra_83: MACRO num
	moveq   #26,d1
	dbra    d1,*
	ENDM
fill_dbra_86: MACRO num
	moveq   #27,d1
	dbra    d1,*
	ENDM
fill_dbra_89: MACRO num
	moveq   #28,d1
	dbra    d1,*
	ENDM

fill_nop_1: MACRO
	nop
	ENDM
fill_nop_2: MACRO
	exg	d1,d1
	ENDM
fill_nop_3: MACRO
	nop
	exg	d1,d1
	ENDM
fill_nop_4: MACRO
	exg	d1,d1
	exg	d1,d1
	ENDM
fill_nop_5: MACRO
	fill_dbra_5
	ENDM
fill_nop_6: MACRO
	fill_dbra_5
	nop
	ENDM
fill_nop_7: MACRO
	fill_dbra_5
	exg	d1,d1
	ENDM
fill_nop_8: MACRO
	fill_dbra_8
	ENDM
fill_nop_9: MACRO
	fill_dbra_8
	nop
	ENDM
fill_nop_10: MACRO
	fill_dbra_8
	exg	d1,d1
	ENDM
fill_nop_11: MACRO
	fill_dbra_11
	ENDM
fill_nop_12: MACRO
	fill_dbra_11
	nop
	ENDM
fill_nop_13: MACRO
	fill_dbra_11
	exg	d1,d1
	ENDM
fill_nop_14: MACRO
	fill_dbra_14
	ENDM
fill_nop_15: MACRO
	fill_dbra_14
	nop
	ENDM
fill_nop_16: MACRO
	fill_dbra_14
	exg	d1,d1
	ENDM
fill_nop_17: MACRO
	fill_dbra_17
	ENDM
fill_nop_18: MACRO
	fill_dbra_17
	nop
	ENDM
fill_nop_19: MACRO
	fill_dbra_17
	exg	d1,d1
	ENDM
fill_nop_20: MACRO
	fill_dbra_20
	ENDM
fill_nop_21: MACRO
	fill_dbra_20
	nop
	ENDM
fill_nop_22: MACRO
	fill_dbra_20
	exg	d1,d1
	ENDM
fill_nop_23: MACRO
	fill_dbra_23
	ENDM
fill_nop_24: MACRO
	fill_dbra_23
	nop
	ENDM
fill_nop_25: MACRO
	fill_dbra_23
	exg	d1,d1
	ENDM
fill_nop_26: MACRO
	fill_dbra_26
	ENDM
fill_nop_27: MACRO
	fill_dbra_26
	nop
	ENDM
fill_nop_28: MACRO
	fill_dbra_26
	exg	d1,d1
	ENDM
fill_nop_29: MACRO
	fill_dbra_29
	ENDM
fill_nop_30: MACRO
	fill_dbra_29
	nop
	ENDM
fill_nop_31: MACRO
	fill_dbra_29
	exg	d1,d1
	ENDM
fill_nop_32: MACRO
	fill_dbra_32
	ENDM
fill_nop_33: MACRO
	fill_dbra_32
	nop
	ENDM
fill_nop_34: MACRO
	fill_dbra_32
	exg	d1,d1
	ENDM
fill_nop_35: MACRO
	fill_dbra_35
	ENDM
fill_nop_36: MACRO
	fill_dbra_35
	nop
	ENDM
fill_nop_37: MACRO
	fill_dbra_35
	exg	d1,d1
	ENDM
fill_nop_38: MACRO
	fill_dbra_38
	ENDM
fill_nop_39: MACRO
	fill_dbra_38
	nop
	ENDM
fill_nop_40: MACRO
	fill_dbra_38
	exg	d1,d1
	ENDM
fill_nop_41: MACRO
	fill_dbra_41
	ENDM
fill_nop_42: MACRO
	fill_dbra_41
	nop
	ENDM
fill_nop_43: MACRO
	fill_dbra_41
	exg	d1,d1
	ENDM
fill_nop_44: MACRO
	fill_dbra_44
	ENDM
fill_nop_45: MACRO
	fill_dbra_44
	nop
	ENDM
fill_nop_46: MACRO
	fill_dbra_44
	exg	d1,d1
	ENDM
fill_nop_47: MACRO
	fill_dbra_47
	ENDM
fill_nop_48: MACRO
	fill_dbra_47
	nop
	ENDM
fill_nop_49: MACRO
	fill_dbra_47
	exg	d1,d1
	ENDM
fill_nop_50: MACRO
	fill_dbra_50
	ENDM
fill_nop_51: MACRO
	fill_dbra_50
	nop
	ENDM
fill_nop_52: MACRO
	fill_dbra_50
	exg	d1,d1
	ENDM
fill_nop_53: MACRO
	fill_dbra_53
	ENDM
fill_nop_54: MACRO
	fill_dbra_53
	nop
	ENDM
fill_nop_55: MACRO
	fill_dbra_53
	exg	d1,d1
	ENDM
fill_nop_56: MACRO
	fill_dbra_56
	ENDM
fill_nop_57: MACRO
	fill_dbra_56
	nop
	ENDM
fill_nop_58: MACRO
	fill_dbra_56
	exg	d1,d1
	ENDM
fill_nop_59: MACRO
	fill_dbra_59
	ENDM
fill_nop_60: MACRO
	fill_dbra_59
	nop
	ENDM
fill_nop_61: MACRO
	fill_dbra_59
	exg	d1,d1
	ENDM
fill_nop_62: MACRO
	fill_dbra_62
	ENDM
fill_nop_63: MACRO
	fill_dbra_62
	nop
	ENDM
fill_nop_64: MACRO
	fill_dbra_62
	exg	d1,d1
	ENDM
fill_nop_65: MACRO
	fill_dbra_65
	ENDM
fill_nop_66: MACRO
	fill_dbra_65
	nop
	ENDM
fill_nop_67: MACRO
	fill_dbra_65
	exg	d1,d1
	ENDM
fill_nop_68: MACRO
	fill_dbra_68
	ENDM
fill_nop_69: MACRO
	fill_dbra_68
	nop
	ENDM
fill_nop_70: MACRO
	fill_dbra_68
	exg	d1,d1
	ENDM
fill_nop_71: MACRO
	fill_dbra_71
	ENDM
fill_nop_72: MACRO
	fill_dbra_71
	nop
	ENDM
fill_nop_73: MACRO
	fill_dbra_71
	exg	d1,d1
	ENDM
fill_nop_74: MACRO
	fill_dbra_74
	ENDM
fill_nop_75: MACRO
	fill_dbra_74
	nop
	ENDM
fill_nop_76: MACRO
	fill_dbra_74
	exg	d1,d1
	ENDM
fill_nop_77: MACRO
	fill_dbra_77
	ENDM
fill_nop_78: MACRO
	fill_dbra_77
	nop
	ENDM
fill_nop_79: MACRO
	fill_dbra_77
	exg	d1,d1
	ENDM
fill_nop_80: MACRO
	fill_dbra_80
	ENDM
fill_nop_81: MACRO
	fill_dbra_80
	nop
	ENDM
fill_nop_82: MACRO
	fill_dbra_80
	exg	d1,d1
	ENDM
fill_nop_83: MACRO
	fill_dbra_83
	ENDM
fill_nop_84: MACRO
	fill_dbra_83
	nop
	ENDM
fill_nop_85: MACRO
	fill_dbra_83
	exg	d1,d1
	ENDM
fill_nop_86: MACRO
	fill_dbra_86
	ENDM
fill_nop_87: MACRO
	fill_dbra_86
	nop
	ENDM
fill_nop_88: MACRO
	fill_dbra_86
	exg	d1,d1
	ENDM
fill_nop_89: MACRO
	fill_dbra_89
	ENDM
