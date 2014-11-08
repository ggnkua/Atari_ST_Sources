;; 
;; $Id: fal_dsp.s pdonze Exp $
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
; extensions for Falcon TOS (dsp)
; --------------------------------------------------------------------

export Dsp_DoBlock
MODULE Dsp_DoBlock
; void	Dsp_DoBlock(char *data_in, long size_in, 
;				char *data_out, long size_out );
		REGSave
		move.l	D1,-(sp)
		pea 	(A1)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#96,-(sp)
		trap	#14				; XBios(96)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_BlkHandShake
MODULE Dsp_BlkHandShake
; void	Dsp_BlkHandShake(char *data_in, long size_in, 
;				char *data_out, long size_out );
		REGSave
		move.l	D1,-(sp)
		pea 	(A1)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#97,-(sp)
		trap	#14				; XBios(97)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_BlkUnpacked
MODULE Dsp_BlkUnpacked
; void	Dsp_BlkUnpacked(char *data_in, long size_in, 
;				char *data_out, long size_out );
		REGSave
		move.l	D1,-(sp)
		pea 	(A1)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#98,-(sp)
		trap	#14				; XBios(98)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_InStream
MODULE Dsp_InStream
; void	Dsp_InStream(char *data_in, long block_size, 
;				long num_blocks, long *blocks_done );
		REGSave
		pea 	(A1)
		move.l	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#99,-(sp)
		trap	#14				; XBios(99)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_OutStream
MODULE Dsp_OutStream
; void	Dsp_OutStream(char *data_in, long block_size, 
;				long num_blocks, long *blocks_done );
		REGSave
		pea 	(A1)
		move.l	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#100,-(sp)
		trap	#14				; XBios(100)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_IOStream
MODULE Dsp_IOStream
; void	Dsp_IOStream(char *data_in, char *data_out,
;				long block_insize, long block_outsize,
;				long num_blocks, long *blocks_done );
		REGSave
		move.l	_STC+4(SP),-(SP)
		move.l	D2,-(sp)
		move.l	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A1)
		pea 	(A0)
		move.w	#101,-(sp)
		trap	#14				; XBios(101)
		lea 	26(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_RemoveInterrupts
MODULE Dsp_RemoveInterrupts
; void	Dsp_RemoveInterrupts( short mask );
		REGSave
		move.w	D0,-(SP)
		move.w	#102,-(sp)
		trap	#14				; XBios(102)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Dsp_GetWordSize
MODULE Dsp_GetWordSize
; short	Dsp_GetWordSize( void );
		REGSave
		move.w	#103,-(sp)
		trap	#14				; XBios(103)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_Lock
MODULE Dsp_Lock
; short	Dsp_Lock( void );
		REGSave
		move.w	#104,-(sp)
		trap	#14				; XBios(104)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_Unlock
MODULE Dsp_Unlock
; void	Dsp_Unlock( void );
		REGSave
		move.w	#105,-(sp)
		trap	#14				; XBios(105)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_Available
MODULE Dsp_Available
; void	Dsp_Available( long *xavail, long *yavail );
		REGSave
		pea 	(A1)
		pea 	(A0)
		move.w	#106,-(sp)
		trap	#14				; XBios(106)
		lea 	10(sp),sp
		REGLoad
		rts
ENDMOD
	
export Dsp_Reserve
MODULE Dsp_Reserve
; short	Dsp_Reserve( long xreserve, long yreserve );
		REGSave
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#107,-(sp)
		trap	#14				; XBios(107)
		lea		10(SP),sp
		REGLoad
		rts
ENDMOD

export Dsp_LoadProg
MODULE Dsp_LoadProg
; short	Dsp_LoadProg(char *file, short ability, void *buffer );
		REGSave
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#108,-(sp)
		trap	#14				; XBios(108)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_ExecProg
MODULE Dsp_ExecProg
; void	Dsp_ExecProg(char *codeptr, long codesize, short ability );
		REGSave
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#109,-(sp)
		trap	#14				; XBios(109)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_ExecBoot
MODULE Dsp_ExecBoot
; void	Dsp_ExecBoot(char *codeptr, long codesize, short ability );
		REGSave
		move.w	D1,-(sp)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#110,-(sp)
		trap	#14				; XBios(110)
		lea 	12(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_LodToBinary
MODULE Dsp_LodToBinary
; long	Dsp_LodToBinary(char *file, char *codeptr );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#111,-(sp)
		trap	#14				; XBios(111)
		lea		10(SP),sp
		REGLoad
		rts
ENDMOD

EXPORT Dsp_TriggerHC
MODULE Dsp_TriggerHC
; void	Dsp_TriggerHC( short vector );
		REGSave
		move.w	D0,-(SP)
		move.w	#112,-(sp)
		trap	#14				; XBios(112)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Dsp_RequestUniqueAbility
MODULE Dsp_RequestUniqueAbility
; short	Dsp_RequestUniqueAbility( void );
		REGSave
		move.w	#113,-(sp)
		trap	#14				; XBios(113)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_GetProgAbility
MODULE Dsp_GetProgAbility
; short	Dsp_GetProgAbility( void );
		REGSave
		move.w	#114,-(sp)
		trap	#14				; XBios(114)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_FlushSubroutines
MODULE Dsp_FlushSubroutines
; void	Dsp_FlushSubroutines( void );
		REGSave
		move.w	#115,-(sp)
		trap	#14				; XBios(115)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_LoadSubroutine
MODULE Dsp_LoadSubroutine
; short	Dsp_LoadSubroutine( char *codeptr, long size, short ability );
		REGSave
		move.w	D1,-(SP)
		move.l	D0,-(SP)
		pea		(A0)
		move.w	#116,-(sp)
		trap	#14				; XBios(116)
		lea		12(SP),sp
		REGLoad
		rts
ENDMOD

export Dsp_InqSubrAbility
MODULE Dsp_InqSubrAbility
; short	Dsp_InqSubrAbility( short flag );
		REGSave
		move.w	D0,-(sp)
		move.w	#117,-(sp)
		trap	#14				; XBios(117)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Dsp_RunSubroutine
MODULE Dsp_RunSubroutine
; short	Dsp_RunSubroutine( short handle );
		REGSave
		move.w	D0,-(SP)
		move.w	#118,-(sp)
		trap	#14				; XBios(118)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Dsp_Hf0
MODULE Dsp_Hf0
; short	Dsp_Hf0( short flag );
		REGSave
		move.w	D0,-(sp)
		move.w	#119,-(sp)
		trap	#14				; XBios(119)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Dsp_Hf1
MODULE Dsp_Hf1
; short	Dsp_Hf1( short flag );
		REGSave
		move.w	D0,-(sp)
		move.w	#120,-(sp)
		trap	#14				; XBios(1201)
		addq.l	#4,sp
		REGLoad
		rts
ENDMOD

export Dsp_Hf2
MODULE Dsp_Hf2
; short	Dsp_Hf2( void );
		REGSave
		move.w	#121,-(sp)
		trap	#14				; XBios(121)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_Hf3
MODULE Dsp_Hf3
; short	Dsp_Hf3( void );
		REGSave
		move.w	#122,-(sp)
		trap	#14				; XBios(122)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

export Dsp_BlkWords
MODULE Dsp_BlkWords
; void	Dsp_BlkWords( short *data_in, long size_in, 
;				short *data_out, long size_out );
		REGSave
		move.l	D1,-(sp)
		pea 	(A1)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#123,-(sp)
		trap	#14				; XBios(123)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_BlkBytes
MODULE Dsp_BlkBytes
; void	Dsp_BlkBytes(char *data_in, long size_in, 
;				char *data_out, long size_out );
		REGSave
		move.l	D1,-(sp)
		pea 	(A1)
		move.l	D0,-(sp)
		pea 	(A0)
		move.w	#124,-(sp)
		trap	#14				; XBios(124)
		lea 	18(sp),sp
		REGLoad
		rts
ENDMOD

export Dsp_HStat
MODULE Dsp_HStat
; short	Dsp_HStat( void );
		REGSave
		move.w	#125,-(sp)
		trap	#14				; XBios(125)
		addq.l	#2,sp
		REGLoad
		rts
ENDMOD

EXPORT Dsp_SetVectors
MODULE Dsp_SetVectors
; void	Dsp_SetVectors( void (*receiver)(),
;				long (*transmitter)() );
		REGSave
		pea		(A1)
		pea		(A0)
		move.w	#126,-(SP)
		trap	#14				; XBios(126)
		lea		10(SP),SP
		REGLoad
		rts
ENDMOD

export Dsp_MultBlocks
MODULE Dsp_MultBlocks
; void	Dsp_MultBlocks( long numsend, long numreceive,
;				DSPBLOCK *sendblk,
;				DSPBLOCK *receiveblock );
		REGSave
		pea		(A1)
		pea		(A0)
		move.l	D1,-(SP)
		move.l	D0,-(SP)
		move.w	#127,-(sp)
		trap	#14				; XBios(127)
		lea		18(SP),SP
		REGLoad
		rts
ENDMOD

