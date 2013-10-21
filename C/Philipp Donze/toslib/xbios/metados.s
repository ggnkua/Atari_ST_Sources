;; 
;; $Id: metados.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains Meta DOS specific XBIOS calls
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
; METADOS XBIOS calls
; --------------------------------------------------------------------

export Metainit
MODULE Metainit
; void	Metainit( METAINFO *buffer );
		REGSave
		pea 	(A0)
		move.w	#48,-(sp)
		trap	#14				; XBios(48)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Metaopen
MODULE Metaopen
; long	Metaopen( short drive, META_DRVINFO *buffer );
		REGSave
		pea 	(A0)
		move.w	D0,-(sp)
		move.w	#49,-(sp)
		trap	#14				; XBios(49)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Metaclose
MODULE Metaclose
; long	Metaclose( short drive );
		REGSave
		move.w	D0,-(sp)
		move.w	#50,-(sp)
		trap	#14				; XBios(50)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Metaread
MODULE Metaread
; long	Metaread( short drive, void *buffer, long blockno, short count );
		REGSave
		move.w	D2,-(sp)
		move.l	D1,-(sp)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#51,-(sp)
		trap	#14				; XBios(51)
		lea		14(sp),sp
		REGLoad
		rts
ENDMOD

export Metawrite
MODULE Metawrite
; long	Metawrite( short drive, void *buffer, long blockno, short count );
		REGSave
		move.w	D2,-(sp)
		move.l	D1,-(sp)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#52,-(sp)
		trap	#14				; XBios(52)
		lea		14(sp),sp
		REGLoad
		rts
ENDMOD

export Metastatus
MODULE Metastatus
; long	Metastatus( short drive, void *buffer );
		REGSave
		pea 	(A0)
		move.w	D0,-(sp)
		move.w	#54,-(sp)
		trap	#14				; XBios(54)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD
		
export Metaioctl
MODULE Metaioctl
; long	Metaioctl( short drive, long magic, short opcode, void *buffer );
		REGSave
		pea		(A0)
		move.w	D2,-(sp)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#55,-(sp)
		trap	#14				; XBios(55)
		lea		14(sp),sp
		REGLoad
		rts
ENDMOD

export Metastartaudio
MODULE Metastartaudio
; long	Metastartaudio( short drive, short flag, unsigned char *bytearray );
		REGSave
		pea		(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#59,-(sp)
		trap	#14				; XBios(59)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Metastopaudio
MODULE Metastopaudio
; long	Metastopaudio( short drive );
		REGSave
		move.w	D0,-(sp)
		move.w	#60,-(sp)
		trap	#14				; XBios(60)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Metasetsongtime
MODULE Metasetsongtime
; long	Metasetsongtime( short drive, short repeat,
;				long starttime, long endtime );
		REGSave
		move.l	_STC+4(SP),-(SP)
		move.l	D2,-(sp)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#61,-(sp)
		trap	#14				; XBios(61)
		lea 	14(sp),sp
		REGLoad
		rts
ENDMOD
		
export Metagettoc
MODULE Metagettoc
; long	Metagettoc( short drive, short flag, CD_TOC_ENTRY *buffer );
		REGSave
		pea		(A0)
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#62,-(sp)
		trap	#14				; XBios(62)
		lea 	10(sp),sp
		REGLoad
		rts
ENDMOD
		
export Metadiscinfo
MODULE Metadiscinfo
; long	Metadiscinfo( short drive, CD_DISC_INFO *p );
		REGSave
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#63,-(sp)
		trap	#14				; XBios(63)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD
