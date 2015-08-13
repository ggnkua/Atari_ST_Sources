*********************************************************************************
* Helper functions for ST assembler programming					*
*	Copyright 2001 Dr. Thomas Redelberger					*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: uti.s 1.1 2002/03/24 13:48:44 Thomas Exp Thomas $
*

*
* code generation options
*
***		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on

*
* entry points and references in this module
*
		XDEF	prntStr		; (); debugging
		XDEF	prntLong	; (); "
		XDEF	prntWord	; (); "
		XDEF	prntByte	; (); "
		XDEF	prntSR		; (); "


		SECTION	TEXT

**** Debugging code *************************************************************



******** prntLong *****************************************************
* print longword
*	cdecl void prntLong(long arg);
***********************************************************************

Rph		REG	d0-d2/d6/d7/a0-a2
RNph		EQU	8*4			; number of saved bytes

prntLong	movem.l	Rph,-(sp)		; save used regs.
		move.l	RNph+4(sp),d6		; get longword
		moveq.l	#7,d7
		bra.b	prntNibbles


******** prntWord *****************************************************
* print word
*	cdecl void prntWord(short arg);
***********************************************************************

prntWord	movem.l	Rph,-(sp)		; save used regs.
		move	RNph+4(sp),d6		; get word
		swap	d6			; in upper word
		moveq.l	#3,d7
		bra.b	prntNibbles


******** prntByte *****************************************************
* print byte
*	cdecl void prntByte(char arg);
***********************************************************************

prntByte	movem.l	Rph,-(sp)		; save used regs.
		move.b	RNph+4(sp),d6		; get byte
		swap	d6			; in upper word
		lsl.l	#8,d6			; in upper byte
		moveq.l	#1,d7
*		fall thru to prntNibbles


prntNibbles	moveq	#0,d0			; clear word
		REPT	4			; get nibble in d0
		lsl.l	#1,d6			; in extend bit
		roxl.b	#1,d0			; from extend bit
		ENDR
		move.b	.HexTab(pc,d0.w),d0	; get hex character
		move	d0,-(sp)		; arg: the char
		move.l	#$00030002,-(sp)	; 2 args: VT52-console (2), Bconout (3)
		trap	#13			; Bios
		addq.l	#6,sp			; pop args
		dbra	d7,prntNibbles

		movem.l	(sp)+,Rph
		rts

.HexTab		DC.B	"0123456789abcdef"

******** prntSR *******************************************************

prntSR		move	SR,-(sp)
		bsr.b	prntWord
		addq.l	#2,sp
		rts



******** prntStr ****************************************************************
* prints message on screen (VT52 codes)
*	cdecl void prntStr(char *message);
*********************************************************************************

Rps		REG	d0-d2/a0-a2/a6
RNps		EQU	4*7			; number of saved bytes

prntStr		movem.l	Rps,-(sp)
		move.l	RNps+4(sp),a6		; get pointer to string
		bra.b	.b1

.t1		move	d0,-(sp)		; arg: the char
		move.l	#$00030002,-(sp)	; 2 args: VT52-console, Bconout
		trap	#13			; Bios
		addq.l	#6,sp			; pop args
.b1		moveq	#0,d0			; unsigned extend
		move.b	(a6)+,d0
		bne.b	.t1

		movem.l	(sp)+,Rps
		rts


*********************************************************************************
