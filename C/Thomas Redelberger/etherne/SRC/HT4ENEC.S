*********************************************************************************
* HT4ENEC.S									*
*	Basic hardware test for EtherNEC					*
*	EtherNEC hardware copyright 2002 Lyndon Amsdon, Dr. Thomas Redelberger	*
*	Software Copyright 2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: ht4enec.s 1.1 2002/04/16 21:24:54 Thomas Exp Thomas $
*

*
* code generation options
*
***		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on
		
		INCLUDE	UTI.I

		INCLUDE	BUSENEC.I

putBUSr		MACRO
		move.w	#(\2)<<8,RyBUS		; move ISA address to bits 8-15
		move.w	RyBUS,RxBUS		; get a copy
		move.b	\1,RyBUS		; merge in data
		add.w	RyBUS,RyBUS		; shift up one bit to avoid UDS/LDS ***
		move.b	0(RcBUS,RyBUS.w),d0	; write by reading
		ENDM




		SECTION	TEXT

* set stack and give back unused memory
myStart		move.l	4(sp),a0		; get pointer to basepage
		move.l	$18(a0),d0		; get start of BSS
		add.l	$1c(a0),d0		; +BSS length=points beyond BSS
		move.l	d0,sp			; here starts our stack
		sub.l	a0,d0			; =total length
		move.l	d0,-(sp)		; reserve this much memory
		move.l	a0,-(sp)		; from there
		clr	-(sp)			; dummy word
		move	#$4a,-(sp)		; Mshrink
		trap	#1			; GemDos
		lea	12(sp),sp		; pop args

		PrS	.TaTa(pc)

*** test starts here
* LIST +
		ldBUSRegs			; prepare registers



* write to ISA data lines and read back
		PrS	.header

		move	#$00,d1
		bsr	outAux
* LIST -
		not	d1
		bsr	outAux

		move	#$01,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$02,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$04,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$08,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$10,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$20,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$40,d1
		bsr	outAux
		not	d1
		bsr	outAux

		move	#$80,d1
		bsr	outAux
		not	d1
		bsr	outAux


		PrS	.promptUsr(pc)
		WaitKey				; eat the key
		
.quit


*** test is finished
		clr	-(sp)			; Pterm0
		trap	#1			; Gemdos
		illegal				; should never get here




.TaTa		DC.B	$1b,"pTest EtherNEC hardware: data lines round trip",$1b,"q",13,10
		DC.B	"(C)2002 Dr. Thomas Redelberger",13,10,0

.promptUsr	DC.B	"hit any key to finish",13,10,0

.header		DC.B	9,"written",9,"read",13,10,0

		EVEN


********************************************************************************	

outAux
		putBUSr	d1,0
		PrS	.tabDollar
		PrB	d1
		PrS	.tabDollar
		PrB	d0
		PrS	.crlf
		rts

.tabDollar	DC.B	9,"$",0

.crlf		DC.B	13,10,0

		EVEN



*********************************************************************************

		INCLUDE	UTI.S


		SECTION	BSS

		DS.B	256		; my stack area

******** end of HT4ENEC.S *******************************************************

