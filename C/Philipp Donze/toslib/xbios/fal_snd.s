;; 
;; $Id: fal_snd.s pdonze Exp $
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
; extensions for Falcon TOS (sound)
; --------------------------------------------------------------------

export Locksnd
MODULE Locksnd
; long	Locksnd( void );
		REGSave
		move.w	#128,-(sp)
		trap	#14				; XBios(128)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Unlocksnd
MODULE Unlocksnd
; long	Unlocksnd( void );
		REGSave
		move.w	#129,-(sp)
		trap	#14				; XBios(129)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Soundcmd	
MODULE Soundcmd	
; long	Soundcmd( short mode, short data );
		REGSave
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#130,-(sp)
		trap	#14				; XBios(130)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Setbuffer	
MODULE Setbuffer	
; long	Setbuffer( short reg, void *begaddr, void *endaddr );
		REGSave
		pea		(a1)
		pea 	(a0)
		move.w	d0,-(sp)
		move.w	#131,-(sp)
		trap	#14				; XBios(131)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Setmode	
MODULE Setmode	
; long	Setmode( short mode );
		REGSave
		move.w	d0,-(sp)
		move.w	#132,-(sp)
		trap	#14				; XBios(132)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Settracks	
MODULE Settracks	
; long	Settracks( short playtracks, short rectracks );
		REGSave
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#133,-(sp)
		trap	#14				; XBios(133)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Setmontracks		
MODULE Setmontracks		
; long	Setmontracks( short montracks );
		REGSave
		move.w	d0,-(sp)
		move.w	#134,-(sp)
		trap	#14				; XBios(134)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Setinterrupt		
MODULE Setinterrupt		
; long	Setinterrupt( short src_inter, short cause );
		REGSave
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#135,-(sp)
		trap	#14				; XBios(135)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Buffoper		
MODULE Buffoper		
; long	Buffoper( short mode );
		REGSave
		move.w	d0,-(sp)
		move.w	#136,-(sp)
		trap	#14				; XBios(136)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

EXPORT Dsptristate
MODULE Dsptristate
; long	Dsptristate( short dspxmit, short dsprec );
		REGSave
		move.w	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#137,-(sp)
		trap	#14				; XBios(137)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Gpio
MODULE Gpio
; long	Gpio( short mode, short data );
		REGSave
		move.w	D1,-(SP)
		move.w	D0,-(SP)
		move.w	#138,-(sp)
		trap	#14				; XBios(138)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Devconnect
MODULE Devconnect
; long	Devconnect( short src, short dst, short srcclk, short prescale,
;				short protocol );
		REGSave
		move.w	_STC+$4(sp),-(sp)
		move.w	_STC+$4(sp),-(sp)
		move.w	d2,-(sp)
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#139,-(sp)
		trap	#14				; XBios(139)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Sndstatus		
MODULE Sndstatus		
; long	Sndstatus( short reset );
		REGSave
		move.w	d0,-(sp)
		move.w	#140,-(sp)
		trap	#14				; XBios(140)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Buffptr	
MODULE Buffptr	
; long	Buffptr( long *ptr );
		REGSave
		pea 	(a0)
		move.w	#141,-(sp)
		trap	#14				; XBios(141)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD








