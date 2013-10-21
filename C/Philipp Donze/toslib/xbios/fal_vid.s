;; 
;; $Id: fal_vid.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains Atari Falcon specific XBIOS calls
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
; extensions for Falcon TOS (video)
; --------------------------------------------------------------------

export VsetScreen
MODULE VsetScreen
; void	VsetScreen( void *laddr, void *paddr, short rez , short mode );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		pea 	(A1)
		pea 	(A0)
		move.w	#5,-(sp)
		trap	#14				; XBios(5)
		lea 	14(sp),sp
		REGLoad
		rts
ENDMOD

export VsetMode
MODULE VsetMode
; short	VsetMode( short modecode );
		REGSave
		move.w	D0,-(sp)
		move.w	#88,-(sp)
		trap	#14				; XBios(88)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export VgetMonitor
MODULE VgetMonitor
; short	VgetMonitor( void );
		REGSave
		move.w	#89,-(sp)
		trap	#14				; XBios(89)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export VsetSync
MODULE VsetSync
; void	VsetSync( short external );
		REGSave
		move.w	D0,-(sp)
		move.w	#90,-(sp)
		trap	#14				; XBios(90)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export VgetSize
MODULE VgetSize
; long	VgetSize( short mode );
		REGSave
		move.w	D0,-(sp)
		move.w	#91,-(sp)
		trap	#14				; XBios(91)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export VsetRGB
MODULE VsetRGB
; void	VsetRGB( short index, short count, long *array );
		REGSave
		pea 	(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#93,-(sp)
		trap	#14				; XBios(93)
		lea 	10(sp),sp
		REGLoad
		rts
ENDMOD

export VgetRGB
MODULE VgetRGB
; void	VgetRGB( short index, short count, long *array );
		REGSave
		pea 	(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#94,-(sp)
		trap	#14				; XBios(94)
		lea 	10(sp),sp
		REGLoad
		rts
ENDMOD

export Validmode
MODULE Validmode
; short	Validmode( short mode );
		REGSave
		move.w	D0,-(sp)
		move.w	#95,-(sp)
		trap	#14				; XBios(95)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export VsetMask
MODULE VsetMask
; short	VsetMask( short andmask, short ormask );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#150,-(sp)
		trap	#14				; XBios(150)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD






