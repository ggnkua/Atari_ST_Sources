*********************************************************************************
* HT1ENE.S									*
*	Basic hardware data bus read test for EtherNEC & EtherNEA		*
*	EtherNEC hardware copyright 2002 Lyndon Amsdon, Dr. Thomas Redelberger	*
*	EtherNEA hardware copyright 2000-2002 Dr. Thomas Redelberger		*
*	Software Copyright 2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: ht1ene.s 1.1 2002/04/16 21:24:54 Thomas Exp Thomas $
*

*
* code generation options
*
***		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on
		
		INCLUDE	UTI.I

		INCLUDE	BUS.I


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

		PrS	.m1(pc)			; TaTa

*** test starts here
	IFNE	0
		bsr	do_test
	ELSEIF
		pea	do_test(pc)		; must execute in super mode
		move.w	#$26,-(sp)		; Supexec
		trap	#14			; xbios
		addq.l	#6,sp
	ENDC

*** test is finished
		clr	-(sp)			; Pterm0
		trap	#1			; Gemdos
		illegal				; should never get here




.m1		DC.B	$1b,"pTest EtherNE hardware without NE card",$1b,"q",13,10
		DC.B	"Software (C)2002 Dr. Thomas Redelberger",13,10,0
		EVEN


*********************************************************************************


do_test
		lockBUSWait			; aquire Bus
		ldBUSRegs			; prepare registers


.t1
* test ISA data lines
	IFNE	1
		getBUS	0,d0
		PrB	d0
		PrA	<13,10>
	ENDC
	IFNE	0
		putBUS	#0,0
		putBUS	#1,0
		putBUS	#2,0
		putBUS	#4,0
		putBUS	#8,0
		putBUS	#16,0
		putBUS	#32,0
		putBUS	#64,0
		putBUS	#128,0
	ENDC

* test ISA address lines
	IFNE	0
		getBUS	0,d0
		getBUS	1,d0
		getBUS	2,d0
		getBUS	4,d0
		getBUS	8,d0
		getBUS	16,d0
	ENDC
	IFNE	0
		putBUS	#0,0
		putBUS	#0,1
		putBUS	#0,2
		putBUS	#0,4
		putBUS	#0,8
		putBUS	#0,16
	ENDC

		PollKey
		tst	d0
		beq	.t1


		WaitKey				; eat the key
		
		deselBUS			; deselect Bus interface
		unlockBUSWait			; relinquish Bus
		rts



_appl_yield	move.l	a2,-(sp)	; not needed for Pure C/GNU C, needed for Turbo C
		move.w	#201,d0
		trap #2
		movea.l	(sp)+,a2
		rts


		INCLUDE	UTI.S


		SECTION	BSS
lcl_irqlock	EQU	0

DVS		DS.W	1		; storage for dummy lcl_irqlock (EtherNEC only)
		DS.B	256		; my stack area

******** end of HT1ENE.S ********************************************************

