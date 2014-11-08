;; 
;; $Id: xbios.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains general TOS XBIOS calls
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

EXPORT xbios
MODULE xbios
; long	cdecl xbios(short num, ...);
	
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
; standard XBIOS calls (as of TOS 1.x)
; --------------------------------------------------------------------

export Initmous
MODULE Initmous
; void	Initmous( short type, MOUSE *par, void *(*vec)() );
		REGSave
		pea 	(A0)
		pea 	(A1)
		move.w	D0,-(sp)
		move.w	#0,-(sp)
		trap	#14				; XBios(0)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Ssbrk
MODULE Ssbrk
; void	*Ssbrk( short count );
		REGSave
		move.w	D0,-(sp)
		move.w	#1,-(sp)
		trap	#14				; XBios(1)
		addq.l	#4,sp
		move.l	d0,a0
		REGLoad
		rts
ENDMOD

export Physbase
MODULE Physbase
; void	*Physbase( void );
		REGSave
		move.w	#2,-(sp)
		trap	#14				; XBios(2)
		addq.l	#2,sp
		move.l	d0,a0
		REGLoad
		rts
ENDMOD

export Logbase
MODULE Logbase
; void	*Logbase( void );
		REGSave
		move.w	#3,-(sp)
		trap	#14				; XBios(3)
		addq.l	#2,sp
		move.l	d0,a0
		REGLoad
		rts
ENDMOD

export Getrez
MODULE Getrez
; short	Getrez( void );
		REGSave
		move.w	#4,-(sp)
		trap	#14				; XBios(4)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Setscreen
MODULE Setscreen
; void	Setscreen( void *laddr, void *paddr, short rez );
		REGSave
		move.w	D0,-(sp)
		pea 	(A1)
		pea 	(A0)
		move.w	#5,-(sp)
		trap	#14				; XBios(5)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Setpalette
MODULE Setpalette
; void	Setpalette( void *pallptr );
		REGSave
		pea 	(A0)
		move.w	#6,-(sp)
		trap	#14				; XBios(6)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Setcolor
MODULE Setcolor
; short	Setcolor( short colornum, short color );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#7,-(sp)
		trap	#14				; XBios(7)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Floprd
MODULE Floprd
; short	Floprd( void *buf, long filler, short devno, short sectno,
; 				short trackno, short sideno, short count );
		REGSave
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#8,-(sp)
		trap	#14				; XBios(8)
		lea 	20(sp),sp
		REGLoad
		rts
ENDMOD

export Flopwr
MODULE Flopwr
; short	Flopwr( void *buf, long filler, short devno, short sectno,
;				short trackno, short sideno, short count );
		REGSave
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#9,-(sp)
		trap	#14				; XBios(9)
		lea 	20(sp),sp
		REGLoad
		rts
ENDMOD

export Flopfmt
MODULE Flopfmt
; short	Flopfmt( void *buf, long filler, short devno, short spt, 
;				short trackno, short sideno, short shorterlv, long magic,
;				short virgin );
		REGSave
		move.w	_STC+12(sp),-(sp)	; virgin
		move.l	_STC+12(sp),-(sp)	; magic
		move.w	_STC+14(sp),-(sp)	; shorterlv
		move.w	_STC+14(sp),-(sp)	; sideno
		move.w	_STC+14(sp),-(sp)	; trackno
		move.w	D2,-(sp)			; spt
		move.w	D1,-(sp)			; devno
		move.l	D0,-(sp)			; filler
		pea 	(A0)				; buf
		move.w	#10,-(sp)
		trap	#14				; XBios(10)
		lea 	26(sp),sp
		REGLoad
		rts
ENDMOD

export Midiws
MODULE Midiws
; void	Midiws( short cnt, void *ptr );
		REGSave
		pea 	(A0)
		move.w	D0,-(sp)
		move.w	#12,-(sp)
		trap	#14				; XBios(12)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Mfpint
MODULE Mfpint
; void	Mfpint( short erno, void (*vector)() );
		REGSave
		pea 	(A0)
		move.w	D0,-(sp)
		move.w	#13,-(sp)
		trap	#14				; XBios(13)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Iorec
MODULE Iorec
; IOREC	*Iorec( short dev );
		REGSave
		move.w	D0,-(sp)
		move.w	#14,-(sp)
		trap	#14				; XBios(14)
		addq.l	#4,sp
		move.l	D0,A0
		REGLoad
		rts
ENDMOD

export Rsconf
MODULE Rsconf
; long	Rsconf( short baud, short ctr, short ucr, short rsr, short tsr,
;				short scr );
		REGSave
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#15,-(sp)
		trap	#14				; XBios(15)
		lea 	14(sp),sp
		REGLoad
		rts
ENDMOD

export Keytbl
MODULE Keytbl
; KEYTAB	*Keytbl( void *unshift, void *shift, void *capslock );
		REGSave
		move.l	_STC+4(sp),-(sp)
		pea 	(A1)
		pea 	(A0)
		move.w	#16,-(sp)
		trap	#14				; XBios(16)
		lea 	14(sp),sp
		move.l	D0,A0
		REGLoad
		rts
ENDMOD

export Random
MODULE Random
; long	Random( void );
		REGSave
		move.w	#17,-(sp)
		trap	#14				; XBios(17)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Protobt
MODULE Protobt
; void	Protobt( void *buf, long serialno, short disktype, short execflag );
		REGSave
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#18,-(sp)
		trap	#14				; XBios(18)
		lea 	14(sp),sp
		REGLoad
		rts
ENDMOD

export Flopver
MODULE Flopver
; short	Flopver( void *buf, long filler, short devno, short sectno,
;				short trackno, short sideno, short count );
		REGSave
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	_STC+8(sp),-(sp)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#19,-(sp)
		trap	#14				; XBios(19)
		lea 	20(sp),sp
		REGLoad
		rts
ENDMOD

export Scrdmp
MODULE Scrdmp
; void	Scrdmp( void );
		REGSave
		move.w	#20,-(sp)
		trap	#14				; XBios(20)
		addq.l	#2,-(sp)
		REGLoad
		rts
ENDMOD

export Cursconf
MODULE Cursconf
; short	Cursconf( short func, short rate );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#21,-(sp)
		trap	#14				; XBios(21)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Settime
MODULE Settime
; void	Settime( unsigned long time );
		REGSave
		move.l	D0,-(sp)
		move.w	#22,-(sp)
		trap	#14				; XBios(22)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Gettime
MODULE Gettime
; unsigned long	Gettime( void );
		REGSave
		move.w	#23,-(sp)
		trap	#14				; XBios(23)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Bioskeys
MODULE Bioskeys
; void	Bioskeys( void );
		REGSave
		move.w	#24,-(sp)
		trap	#14				; XBios(24)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Ikbdws
MODULE Ikbdws
; void	Ikbdws( short count, void *ptr );
		REGSave
		pea 	(A0)
		move.w	D0,-(sp)
		move.w	#25,-(sp)
		trap	#14				; XBios(25)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Jdisint
MODULE Jdisint
; void	Jdisint( short number );
		REGSave
		move.w	D0,-(sp)
		move.w	#26,-(sp)
		trap	#14				; XBios(26)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Jenabint
MODULE Jenabint
; void	Jenabint( short number );
		REGSave
		move.w	D0,-(sp)
		move.w	#27,-(sp)
		trap	#14				; XBios(27)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Giaccess
MODULE Giaccess
; char	Giaccess( short data, short regno );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#28,-(sp)
		trap	#14				; XBios(28)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Offgibit
MODULE Offgibit
; void	Offgibit( short bitno );
		REGSave
		move.w	D0,-(sp)
		move.w	#29,-(sp)
		trap	#14				; XBios(29)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Ongibit
MODULE Ongibit
; void	Ongibit( short bitno );
		REGSave
		move.w	D0,-(sp)
		move.w	#30,-(sp)
		trap	#14				; XBios(30)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Xbtimer
MODULE Xbtimer
; void	Xbtimer( short timer, short control, short data, void (*vector)() );
		REGSave
		pea 	(A0)
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#31,-(sp)
		trap	#14				; XBios(31)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Dosound
MODULE Dosound
; void	Dosound( void *buf );
		REGSave
		pea 	(A0)
		move.w	#32,-(sp)
		trap	#14				; XBios(32)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Setprt
MODULE Setprt
; short	Setprt( short config );
		REGSave
		move.w	D0,-(sp)
		move.w	#33,-(sp)
		trap	#14				; XBios(33)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Kbdvbase
MODULE Kbdvbase
; KBDVECS	*Kbdvbase( void );
		REGSave
		move.w	#34,-(sp)
		trap	#14				; XBios(34)
		addq.l	#2,sp
		move.l	d0,a0
		REGLoad
		rts
ENDMOD

export Kbrate
MODULE Kbrate
; short	Kbrate( short initial, short repeat );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#35,-(sp)
		trap	#14				; XBios(35)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Prtblk
MODULE Prtblk
; void	Prtblk( PBDEF *par );
		REGSave
		move.w	#1,$04EE
		pea 	(A0)
		move.w	#24,-(sp)
		trap	#14				; XBios(24)
		addq.l	#6,sp
		move.w	#-1,$04EE
		REGLoad
		rts
ENDMOD

export Vsync
MODULE Vsync
; void	Vsync( void );
		REGSave
		move.w	#37,-(sp)
		trap	#14				; XBios(37)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Supexec
MODULE Supexec
; long	Supexec( long (*func)() );
		REGSave
		pea 	(A0)
		move.w	#38,-(sp)
		trap	#14				; XBios(38)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Puntaes
MODULE Puntaes
; void	Puntaes( void );
		REGSave
		move.w	#39,-(sp)
		trap	#14				; XBios(39)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Floprate
MODULE Floprate
; short	Floprate( short devno, short newrate );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#41,-(sp)
		trap	#14				; XBios(41)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Blitmode
MODULE Blitmode
; short	Blitmode( short mode );
		REGSave
		move.w	D0,-(sp)
		move.w	#64,-(sp)
		trap	#14				; XBios(64)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD



