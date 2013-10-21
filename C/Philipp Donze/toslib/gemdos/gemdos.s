;; 
;; $Id: gemdos.s pdonze Exp $
;; 
;; TOS.LIB - (c) 1998 - 2006 Philipp Donze
;; 
;; A replacement for PureC PCTOSLIB.LIB
;; 
;; This file is part of TOS.LIB and contains general GEMDOS calls
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
;   The first three (3) scalar arguments ( char, int, long) use D0-D2.
;   The first two (2) address parameters (pointers) use A0-A1.
;   The first three (3) floatingpoint args use FP0-FP2. (NOT USED HERE)
;
;   Scalar return values ( char, int, long) are expected in D0
;   Address return values (pointer) are expected in A0
;   Floating point return values are expected in FP0. (NOT USED HERE)
;
; => Registers D0-D2/A0-A1/FP0-FP2 are free for use in assembly code.
; Other registers have to be saved and restored.

; GEMDOS saves and restores automatically D3-D7 and A3-A7, other
; registers can be destroyed by a trap.
; Return value (data or address) is always in D0.

; --------------------------------------------------------------------
; tabsize = 4
; 	<asm>	<params>		; <comment>


_STC	EQU		4				; stack offset caused by macro REGSave

MACRO REGSave					; macro for saving registers before trap
		pea		(A2)
ENDM

MACRO REGLoad					; macro for restoring registers after trap
		movea.l	(SP)+,A2
ENDM






; --------------------------------------------------------------------
; standard GEMDOS calls
; --------------------------------------------------------------------

EXPORT gemdos
MODULE gemdos
; long	cdecl gemdos(short num, ...);
	
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


export Pterm0
MODULE Pterm0
; void	Pterm0( void );
		clr.w	-(sp)
		trap	#1				; Gemdos(0)
		illegal					; to be sure we really quit :-)
ENDMOD

export Cconin
MODULE Cconin
; long	Cconin( void );
		REGSave
		move.w	#1,-(sp)
		trap	#1				; Gemdos(1)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cconout
MODULE Cconout
; void	Cconout( short c );
		REGSave
		move.w	D0,-(sp)
		move.w	#2,-(sp)
		trap	#1				; Gemdos(2)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Cauxin
MODULE Cauxin
; long	Cauxin( void );
		REGSave
		move.w	#3,-(sp)
		trap	#1				; Gemdos(3)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cauxout
MODULE Cauxout
; void	Cauxout( short c );
		REGSave
		move.w	D0,-(sp)
		move.w	#4,-(sp)
		trap	#1				; Gemdos(4)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Cprnout
MODULE Cprnout
; void	Cprnout( short c );
		REGSave
		move.w	D0,-(sp)
		move.w	#5,-(sp)
		trap	#1				; Gemdos(5)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Crawio
MODULE Crawio
; long	Crawio( short c );
		REGSave
		move.w	D0,-(sp)
		move.w	#6,-(sp)
		trap	#1				; Gemdos(6)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Crawcin
MODULE Crawcin
; long	Crawcin( void );
		REGSave
		move.w	#7,-(sp)
		trap	#1				; Gemdos(7)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cnecin
MODULE Cnecin
; long	Cnecin( void );
		REGSave
		move.w	#8,-(sp)
		trap	#1				; Gemdos(8)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cconws
MODULE Cconws
; void	Cconws( const char *str );
		REGSave
		pea		(A0)
		move.w	#9,-(sp)
		trap	#1				; Gemdos(9)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Cconrs
MODULE Cconrs
; void	Cconrs( CCONLINE *buf );
		REGSave
		pea		(A0)
		move.w	#10,-(sp)
		trap	#1				; Gemdos(10)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Cconis
MODULE Cconis
; short	Cconis( void );
		REGSave
		move.w	#11,-(sp)
		trap	#1				; Gemdos(11)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsetdrv
MODULE Dsetdrv
; long	Dsetdrv( short drv );
		REGSave
		move.w	D0,-(sp)
		move.w	#14,-(sp)
		trap	#1				; Gemdos(14)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Cconos
MODULE Cconos
; short	Cconos( void );
		REGSave
		move.w	#16,-(sp)
		trap	#1				; Gemdos(16)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cprnos
MODULE Cprnos
; short	Cprnos( void );
		REGSave
		move.w	#17,-(sp)
		trap	#1				; Gemdos(17)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cauxis
MODULE Cauxis
; short	Cauxis( void );
		REGSave
		move.w	#18,-(sp)
		trap	#1				; Gemdos(18)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Cauxos
MODULE Cauxos
; short	Cauxos( void );
		REGSave
		move.w	#19,-(sp)
		trap	#1				; Gemdos(19)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dgetdrv
MODULE Dgetdrv
; short	Dgetdrv( void );
		REGSave
		move.w	#25,-(sp)
		trap	#1				; Gemdos(25)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Fsetdta
MODULE Fsetdta
; void	Fsetdta( DTA *buf );
		REGSave
		pea		(A0)
		move.w	#26,-(sp)
		trap	#1				; Gemdos(26)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Super
MODULE Super
; long	Super( void *stack );
		cmpa.l	#1,A0
		beq		.get_mode
		cmpa.l	#0,A0
		beq		.switch_mode
		cmp.l	#$FEEDBEEF,(A0)
		beq		.return_to_user

; switch to supervisor mode with own SSP
		move.l	(SP),-(A0)		; copy return address on future ssp
		move.l	A2,-(A0)		; save A2 on future SSP

		pea		(A0)
		move.w	#32,-(sp)
		trap	#1				; Gemdos(32)

		movea.l	(SP)+,A2		; restore A2 from SP (=SSP)
		movea.l	D0,A0
		move.l	#$FEEDBEEF,-(A0); add old_ssp flag
		move.l	A0,D0
		rts
		
.switch_mode:
; switch to supervisor mode and use current SP as SSP
		move.l	A2,-(SP)
		pea		(A0)
		move.w	#32,-(sp)
		trap	#1				; Gemdos(32)
		addq.l	#6,SP
		movea.l	(SP)+,A2
		movea.l	D0,A0
		move.l	#$FEEDBEEF,-(A0); add old_ssp flag
		move.l	A0,D0
		rts

.return_to_user:
		addq.l	#4,A0			; remove old_ssp flag

.get_mode:
		move.l	A2,-(SP)
		pea		(A0)
		move.w	#32,-(sp)
		trap	#1				; Gemdos(32)
		addq.l	#6,SP
		movea.l	(SP)+,A2
		rts
ENDMOD

export Tgetdate
MODULE Tgetdate
; unsigned short	Tgetdate( void );
		REGSave
		move.w	#42,-(sp)
		trap	#1				; Gemdos(42)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Tsetdate
MODULE Tsetdate
; short	Tsetdate( unsigned short date );
		REGSave
		move.w	D0,-(sp)
		move.w	#43,-(sp)
		trap	#1				; Gemdos(43)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Tgettime
MODULE Tgettime
; unsigned short	Tgettime( void );
		REGSave
		move.w	#44,-(sp)
		trap	#1				; Gemdos(44)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Tsettime
MODULE Tsettime
; short	Tsettime( unsigned short time );
		REGSave
		move.w	D0,-(sp)
		move.w	#45,-(sp)
		trap	#1				; Gemdos(45)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Fgetdta
MODULE Fgetdta
; DTA	*Fgetdta( void );
		REGSave
		move.w	#47,-(sp)
		trap	#1				; Gemdos(47)
		addq.l	#2,sp
		move.l	D0,A0
		REGLoad
		rts
ENDMOD

export Sversion
MODULE Sversion
; short	Sversion( void );
		REGSave
		move.w	#48,-(sp)
		trap	#1				; Gemdos(48)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Ptermres
MODULE Ptermres
; void	Ptermres( long keepcnt, short retcode );
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		move.w	#49,-(sp)
		trap	#1				; Gemdos(49)
		illegal					; to be sure we really quit :-)
ENDMOD

export Dfree
MODULE Dfree
; long	Dfree( DISKINFO *buf, short driveno );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#54,-(sp)
		trap	#1				; Gemdos(54)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Dcreate
MODULE Dcreate
; long	Dcreate( const char *path );
		REGSave
		pea		(A0)
		move.w	#57,-(sp)
		trap	#1				; Gemdos(57)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Ddelete
MODULE Ddelete
; long	Ddelete( const char *path );
		REGSave
		pea		(A0)
		move.w	#58,-(sp)
		trap	#1				; Gemdos(58)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Dsetpath
MODULE Dsetpath
; long	Dsetpath( const char *path );
		REGSave
		pea		(A0)
		move.w	#59,-(sp)
		trap	#1				; Gemdos(59)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Fcreate
MODULE Fcreate
; long	Fcreate( const char *filename, short attr );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#60,-(sp)
		trap	#1				; Gemdos(60)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Fopen
MODULE Fopen
; long	Fopen( const char *filename, short mode );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#61,-(sp)
		trap	#1				; Gemdos(61)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Fclose
MODULE Fclose
; long	Fclose( short handle );
		REGSave
		move.w	D0,-(sp)
		move.w	#62,-(sp)
		trap	#1				; Gemdos(62)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Fread
MODULE Fread
; long	Fread( short handle, long count, void *buf );
		REGSave
		pea		(A0)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#63,-(sp)
		trap	#1				; Gemdos(63)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Fwrite
MODULE Fwrite
; long	Fwrite( short handle, long count, const void *buf );
		REGSave
		pea		(A0)
		move.l	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#64,-(sp)
		trap	#1				; Gemdos(64)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Fdelete
MODULE Fdelete
; long	Fdelete( const char *path );
		REGSave
		pea		(A0)
		move.w	#65,-(sp)
		trap	#1				; Gemdos(65)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Fseek
MODULE Fseek
; long	Fseek( long where, short handle, short how );
		REGSave
		move.w	D2,-(sp)
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		move.w	#66,-(sp)
		trap	#1				; Gemdos(66)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Fattrib
MODULE Fattrib
; long	Fattrib( const char *filename, short wflag, short attrib );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#67,-(sp)
		trap	#1				; Gemdos(67)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD

export Fdup
MODULE Fdup
; long	Fdup( short handle );
		REGSave
		move.w	D0,-(sp)
		move.w	#69,-(sp)
		trap	#1				; Gemdos(69)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Fforce
MODULE Fforce
; long	Fforce( short stdh, short nonstdh );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		move.w	#70,-(sp)
		trap	#1				; Gemdos(70)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Dgetpath
MODULE Dgetpath
; long	Dgetpath( char *path, short driveno );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#71,-(sp)
		trap	#1				; Gemdos(71)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Malloc
MODULE Malloc
; void	*Malloc( long size );
		REGSave
		move.l	D0,-(sp)
		move.w	#72,-(sp)
		trap	#1				; Gemdos(72)
		addq.l	#6,sp
		move.l	D0,A0
		REGLoad
		rts
ENDMOD

export Mfree
MODULE Mfree
; long	Mfree( void *block );
		REGSave
		pea		(A0)
		move.w	#73,-(sp)
		trap	#1				; Gemdos(73)
		addq.l	#6,sp
		REGLoad
		rts
ENDMOD

export Mshrink
MODULE Mshrink
; long	Mshrink( void *block, long newsiz );
		REGSave
		move.l	D1,-(sp)
		pea		(A0)
		clr.w	-(sp)
		move.w	#74,-(sp)
		trap	#1				; Gemdos(74)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Pexec
MODULE Pexec
; long	Pexec( short mode, const void *ptr1, const void *ptr2, const void *ptr3 );
		REGSave
		move.l	_STC+$4(sp),-(sp)
		pea		(A1)
		pea		(A0)
		move.w	D0,-(sp)
		move.w	#75,-(sp)
		trap	#1				; Gemdos(75)
		lea		16(sp),sp
		REGLoad
		rts
ENDMOD

export Pterm
MODULE Pterm
; void	Pterm( short retcode );
		move.w	D0,-(sp)
		move.w	#76,-(sp)
		trap	#1				; Gemdos(76)
		illegal					; to be sure we really quit :-)
ENDMOD

export Fsfirst
MODULE Fsfirst
; long	Fsfirst( const char *filename, short attr );
		REGSave
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#78,-(sp)
		trap	#1				; Gemdos(78)
		addq.l	#8,sp
		REGLoad
		rts
ENDMOD

export Fsnext
MODULE Fsnext
; long	Fsnext( void );
		REGSave
		move.w	#79,-(sp)
		trap	#1				; Gemdos(79)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Frename
MODULE Frename
; long	Frename( const char *oldname, const char *newname );
		REGSave
		pea		(A1)
		pea		(A0)
		clr.w	-(sp)
		move.w	#86,-(sp)
		trap	#1				; Gemdos(86)
		lea		12(sp),sp
		REGLoad
		rts
ENDMOD

export Fdatime
MODULE Fdatime
; long	Fdatime( DOSTIME *timeptr, short handle, short wflag );
		REGSave
		move.w	D1,-(sp)
		move.w	D0,-(sp)
		pea		(A0)
		move.w	#87,-(sp)
		trap	#1				; Gemdos(87)
		lea		10(sp),sp
		REGLoad
		rts
ENDMOD
