;;
;; $Id: bios.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains general BIOS calls
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
; old NON REENTRANT bios(...) function for compatibility!
; --------------------------------------------------------------------

EXPORT bios
MODULE bios
; long	cdecl bios(short num, ...);
	
        move.l      (SP)+,.save_ret
        move.l      A2,.save_a2
        trap        #1
        movea.l     .save_a2,A2
        movea.l     .save_ret,A1
        jmp         (A1)
		BSS
.save_ret:
		ds.l	1
.save_a2:
		ds.l	1
		TEXT
ENDMOD

; --------------------------------------------------------------------
; standard BIOS calls (as of TOS 1.x)
; --------------------------------------------------------------------

export Getmpb
MODULE Getmpb
; void	Getmpb( MPB *ptr );
		REGSave
		pea		(A0)
		move.w	#0,-(sp)
		trap	#13				; Bios(0)
		addq.l	#6,-(sp)
		REGLoad
		rts
ENDMOD

export Bconstat
MODULE Bconstat
; short	Bconstat( short dev );
		REGSave
		move.w	D0,-(sp)
		move.w	#1,-(sp)
		trap	#13				; Bios(1)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Bconin
MODULE Bconin
; long	Bconin( short dev );
		REGSave
		move.w	D0,-(sp)
		move.w	#2,-(sp)
		trap	#13				; Bios(2)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Bconout
MODULE Bconout
; void	Bconout( short dev, short c );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#3,-(sp)
		trap	#13				; Bios(3)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Rwabs
MODULE Rwabs
; long	Rwabs( short rwflag, void *buf, short cnt, short recnr, short dev,
;				long lrecno );
		REGSave
		move.l	_STC+$6(sp),-(sp)
		move.w	_STC+$8(sp),-(sp)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#4,-(sp)
		trap	#13				; Bios(4)
		lea		18(sp),sp
		REGLoad
		rts
ENDMOD

export Setexc
MODULE Setexc
; long	Setexc( short number, long vec );
		REGSave
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#5,-(sp)
		trap	#13				; Bios(5)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Tickcal
MODULE Tickcal
; long	Tickcal( void );
		REGSave
		move.w	#6,-(sp)
		trap	#13				; Bios(6)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Getbpb
MODULE Getbpb
; BPB	*Getbpb( short dev );
		REGSave
		move.w	D0,-(sp)
		move.w	#7,-(sp)
		trap	#13				; Bios(7)
		addq.l	#4,sp
		move.l	d0,a0
		REGLoad
		rts
ENDMOD

export Bcostat
MODULE Bcostat
; long	Bcostat( short dev );
		REGSave
		move.w	D0,-(sp)
		move.w	#8,-(sp)
		trap	#13				; Bios(8)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Mediach
MODULE Mediach
; long	Mediach( short dev );
		REGSave
		move.w	D0,-(sp)
		move.w	#9,-(sp)
		trap	#13				; Bios(9)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Drvmap
MODULE Drvmap
; long	Drvmap( void );
		REGSave
		move.w	#10,-(sp)
		trap	#13				; Bios(10)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Kbshift
MODULE Kbshift
; long	Kbshift( short mode );
		REGSave
		move.w	D0,-(sp)
		move.w	#11,-(sp)
		trap	#13				; Bios(11)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

