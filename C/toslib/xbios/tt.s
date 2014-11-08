;; 
;; $Id: tt.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains Atari TT specific XBIOS calls
;; 
;; TOS.LIB is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Library General Public License as
;; published by the Free Software Foundation; either version 2 of the
;; License, or (at your option) any later version.
;;
;; TOS.LIB is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Library General Public License for more details.
;;
;; You should have received a copy of the GNU Library General Public
;; License along with the GNU C Library; see the file COPYING.LIB.  If not,
;; write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;; 

; All bindings use Pure C's parameter passing convention:
;   The first three (3) scalar arguments (char, int, long) use D0-D2.
;   The first two (2) address parameters (pointers) use A0-A1.
;   The first three (3) floatingpoint args use FP0-FP2. (NOT USED HERE)
;
;   Scalar return values (char, int, long) are expected in D0
;   Address return values (pointer) are expected in A0
;   Floating point return values are expected in FP0. (NOT USED HERE)
;
; => Registers D0-D2/A0-A1/FP0-FP2 are free for use in assembly code.
; Other registers have to be saved and restored.

; BIOS and XBIOS save and restore automatically D3-D7 and A3-A7, other
; registers can be destroyed by a trap.
; Return value (data or address) is always in D0.

; --------------------------------------------------------------------
; tabsize = 4
;		<asm>	<params>		; <comment>


_STC	EQU		4				; stack offset caused by macro REGSave

MACRO REGSave					; macro for saving registers before trap
		pea		(A2)
ENDM

MACRO REGLoad					; macro for restoring registers after trap
		movea.l	(SP)+,A2
ENDM






; --------------------------------------------------------------------
; extensions for TT TOS
; --------------------------------------------------------------------

export EsetShift
MODULE EsetShift
; short	EsetShift( short shftMode );
		REGSave
		move.w	D0,-(sp)
		move.w	#80,-(sp)
		trap	#14				; XBios(80)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export EgetShift
MODULE EgetShift
; short	EgetShift( void );
		REGSave
		move.w	#81,-(sp)
		trap	#14				; XBios(81)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export EsetBank
MODULE EsetBank
; short	EsetBank( short bankNum );
		REGSave
		move.w	D0,-(sp)
		move.w	#82,-(sp)
		trap	#14				; XBios(82)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export EsetColor
MODULE EsetColor
; short	EsetColor( short colorNum, short color );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#83,-(sp)
		trap	#14				; XBios(83)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export EsetPalette
MODULE EsetPalette
; void	EsetPalette( short colorNum, short count, short *palettePtr );
		REGSave
		pea 	(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#84,-(sp)
		trap	#14				; XBios(84)
		lea 	10(sp),sp
		REGLoad
		rts
ENDMOD

export EgetPalette
MODULE EgetPalette
; void	EgetPalette( short colorNum, short count, short *palettePtr );
		REGSave
		pea 	(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#85,-(sp)
		trap	#14				; XBios(85)
		lea 	10(sp),sp
		REGLoad
		rts
ENDMOD

export EsetGray
MODULE EsetGray
; short	EsetGray( short swtch );
		REGSave
		move.w	D0,-(sp)
		move.w	#86,-(sp)
		trap	#14				; XBios(86)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export EsetSmear
MODULE EsetSmear
; short	EsetSmear( short swtch );
		REGSave
		move.w	D0,-(sp)
		move.w	#87,-(sp)
		trap	#14				; XBios(87)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export DMAread
MODULE DMAread
; short	DMAread( long sector, short count, void *buffer, short devno );
		REGSave
		move.w	D2,-(sp)
		pea 	(A0)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		move.w	#42,-(sp)
		trap	#14				; XBios(42)
		lea 	14(sp),sp
		REGLoad
		rts
ENDMOD

export DMAwrite
MODULE DMAwrite
; short	DMAwrite( long sector, short count, void *buffer, short devno );
		REGSave
		move.w	D2,-(sp)
		pea 	(A0)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		move.w	#43,-(sp)
		trap	#14				; XBios(43)
		lea 	14(sp),sp
		REGLoad
		rts
ENDMOD

export Bconmap
MODULE Bconmap
; long	Bconmap( short devno );
		REGSave
		move.w	D0,-(sp)
		move.w	#44,-(sp)
		trap	#14				; XBios(44)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export NVMaccess
MODULE NVMaccess
; short	NVMaccess( short opcode, short start, short count, void *buffer );
		REGSave
		pea 	(A0)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#46,-(sp)
		trap	#14				; XBios(46)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD






