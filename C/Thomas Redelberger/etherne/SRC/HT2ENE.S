*********************************************************************************
* HT2ENE.S									*
*	Hardware test for EtherNEC and EtherNEA with NE card installed		*
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
* $Id: ht2ene.s 1.1 2002/04/16 21:24:54 Thomas Exp Thomas $
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
		bsr	ne_probe
	ELSEIF
		pea	ne_probe(pc)		; must execute in super mode
		move.w	#$26,-(sp)		; Supexec
		trap	#14			; xbios
		addq.l	#6,sp
	ENDC
*** test is finished

		clr	-(sp)			; Pterm0
		trap	#1			; Gemdos
		illegal				; should never get here


.m1		DC.B	$1b,"pTest EtherNE with NE card but without any STing, MagiCNEt, MINTNet",$1b,"q",13,10
		DC.B	"Software (C)2002 Dr. Thomas Redelberger",13,10,0
		EVEN

*****************************************************************************

		INCLUDE	8390.I

NBSA_prom	EQU	32

ne_probe
		lockBUSWait			; aquire Bus
		ldBUSRegs			; prepare registers

		PrS	.head1(pc)

		getBUS	NE_RESET,d1
		putBUS	d1,NE_RESET

		move	10000,d0		; wait 2ms
.t1		dbra	d0,.t1


		getBUS	EN0_ISR,d1		; read isr
		PrB	d1
		PrS	crlf(pc)
		PrS	crlf(pc)

		putBUS	#$ff,EN0_ISR		; ack all interrupts


		PrS	.head2(pc)

		moveq	#0,d1
* list +
		putBUS	#E8390_NODMA+E8390_PAGE0+E8390_STOP,E8390_CMD	; select page 0
* list -
		putBUS	#$48,EN0_DCFG		; set byte-wide access
		putBUS	d1,EN0_RCNTLO		; clear the count regs.
		putBUS	d1,EN0_RCNTHI
		putBUS	d1,EN0_IMR		; mask completion iqr
		putBUS	#$ff,EN0_ISR
		putBUS	#E8390_RXOFF,EN0_RXCR	; $20 set to monitor
		putBUS	#E8390_TXOFF,EN0_TXCR	; $02 and loopback mode
.again		putBUS	#NBSA_prom&$ff,EN0_RCNTLO
		putBUS	#NBSA_prom>>8,EN0_RCNTHI
		putBUS	d1,EN0_RSARLO		; DMA starting at $0000
		putBUS	d1,EN0_RSARHI
		putBUS	#E8390_RREAD+E8390_START,E8390_CMD	; go

		move	#NBSA_prom/2-1,d2
		lea	pbSA_prom,a0

.t2		getBUS	NE_DATAPORT,d0
		move.b	d0,(a0)+
		getMore	NE_DATAPORT,d1
		move.b	d1,(a0)+
		cmp.b	d0,d1			; check for doubled up values
		beq.b	.c2
		move	#1,pbWordLen
.c2		dbra	d2,.t2

		putBUS	#E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUS	#ENISR_RDC,EN0_ISR	; ack intr.

	IFNE	0
		PollKey
		tst	d0
		beq	.again

		WaitKey
	ENDC

	IFNE	1
		lea	pbSA_prom,a0
		moveq	#NBSA_prom/4-1,d2
***		PrA	<$1b,"H">

.t3		PrL	(a0)+
		PrS	crlf(pc)
		dbra	d2,.t3

***		PrA	<$1b,"H">
		PrS	AnyKey(pc)
		WaitKey
	ENDC
		deselBUS			; deselect Bus interface
		unlockBUSWait			; relinquish Bus
		rts


.head1		DC.B	"Interrupt Status register after Reset (should read $80): $",0

.head2		DC.B	"Reading the NE PROM.",13,10
		DC.B	"The first 12 bytes are the 6 byte MAC address",13,10
		DC.B	"Each byte is doubled up (this is normal):",13,10,0

AnyKey		DC.B	"Press any Key"
crlf		DC.B	13,10,0
		EVEN

pbSA_prom	DS.B	NBSA_prom
pbWordLen	DS.W	1
*****************************************************************************



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

******** end of HT2ENE.S ****************************************************

