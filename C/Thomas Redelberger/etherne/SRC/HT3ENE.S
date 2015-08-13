*********************************************************************************
* HT3ENE.S									*
*	Hardware test for EtherNEC & EtherNEA *with* NE card installed.		*
*	Simulate receiving and transmitting.					*
*	EtherNEA hardware copyright 2000-2002 Dr. Thomas Redelberger		*
*	EtherNEC hardware copyright 2002 Lyndon Amsdon, Dr. Thomas Redelberger	*
*	Software Copyright 2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: ht3ene.s 1.1 2002/04/16 21:24:54 Thomas Exp Thomas $
*

*
* code generation options
*
***		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on


* references from NE.S
		XREF	ei_probe1			; (void);
		XREF	ei_open				; (void);
		XREF	ei_close			; (void);
		XREF	ei_start_xmit			; ();
		XREF	ei_interrupt			; (void);

		XDEF	rtrvPckt

		
		INCLUDE	UTI.I

		INCLUDE	BUS.I

		INCLUDE	8390.I

N8390Hdr	EQU	4		; the 8390 chip stores a 4 byte header preceeding the packet


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
* do it in user mode
		bsr	test3

		ELSEIF
* do it in super mode
		pea	test3(pc)
		move.w	#$26,-(sp)		; Supexec
		trap	#14
		addq.l	#6,sp
		ENDC

*** test is finished

		clr	-(sp)			; Pterm0
		trap	#1			; Gemdos
		illegal				; should never get here


.m1		DC.B	$1b,"pTest EtherNE hardware #3",$1b,"q",13,10
		DC.B	"(C)2002 Dr. Thomas Redelberger",13,10,0
		EVEN

*****************************************************************************



		IFNE	1
*********************************************************************************
* hardware test from terminal 
*********************************************************************************

test3		jsr	ei_probe1
		jsr	ei_open


.t1		WaitKey
		cmp.b	#'x',d0
		beq.b	.quit
		cmp.b	#'r',d0
		beq.b	.c1
		cmp.b	#'t',d0
		beq.b	.c2
		bra.b	.t1

.c1		jsr	ei_interrupt
		bra.b	.t1

.c2		move	#NtstPacket,d0
		lea	tstPacket,a0
		moveq	#0,d1
		suba.l	a1,a1
		jsr	ei_start_xmit
		bra.b	.t1

		
.quit		jsr	ei_close
		rts


		ELSEIF


*********************************************************************************
* hardware test from VBL interrupt 
*********************************************************************************

nvbls		EQU	$454		; (w) number of vbl slots (unused)
_vblqueue	EQU	$456		; (l) points to array of vbl slots (unused)

test3		jsr	ei_probe1
		jsr	ei_open

* install receiver in vertical blank queue
		move.l	_vblqueue\w,a0		; get address of first slot
		move	nvbls\w,d0		; total number of slots
		subq.w	#2,d0			; first slot is reserved for GEM

.t0		addq.l	#4,a0			; first slot is reserved for GEM
		tst.l	(a0)			; free slot?
		dbeq	d0,.t0

		bne.b	.err			; no free slot, quit

		move.l	#ei_interrupt,(a0)	; install my VBL handler


* simulate transmitting
.t1		WaitKey
		cmp.b	#'x',d0
		beq.b	.finish
		cmp.b	#'t',d0
		beq.b	.c2
		bra.b	.t1

.c2		move	#NtstPacket,d0
		lea	tstPacket,a0
		moveq	#0,d1
		suba.l	a1,a1
		jsr	ei_start_xmit
		bra.b	.t1


* deinstall my VBL handler
.finish		move.l	_vblqueue\w,a0		; get address of first slot
		move	nvbls\w,d0		; total number of slots
		subq.w	#2,d0			; first slot is reserved for GEM

.t2		addq.l	#4,a0			; first slot is reserved for GEM
		cmp.l	#ei_interrupt,(a0)	; found my guy?
		bne.b	.b2
		clr.l	(a0)			; yes, deinstall it
.b2		dbra	d0,.t2

.quit		jsr	ei_close
		rts


.err		PrA	<"No free VBL slot, quit",13,10>
		bra.b	.quit


		ENDC	; 0/1



tstPacket	DC.B	$00,$60,$97,$97,$93,$ff
;;;		DC.B	$ff,$ff,$ff,$ff,$ff,$ff
		DC.B	$00,$00,$21,$23,$34,$87
		DC.W	$0800
		DS.B	100

NtstPacket	EQU	*-tstPacket

*********************************************************************************


RrxPktLen	EQUR	d2		; as in NE.S
RrxReadPg	EQUR	d4		; as in NE.S

rtrvPckt
		PrW	RrxPktLen
		PrA	<" RrxPktLen",13,10>


		moveq	#0,d0
		move	RrxPktLen,d0		; unsigned extend

* we get the packet out of the card; just full lenght does not hurt (inc. CRC)
		putBUS	d0,EN0_RCNTLO
		lsr.w	#8,d0
		putBUS	d0,EN0_RCNTHI
* we need to skip the 8390 header
		putBUS	#N8390Hdr,EN0_RSARLO	; skip 8390 header (4)
		putBUS	RrxReadPg,EN0_RSARHI	; we start at this page
		putBUS	#E8390_RREAD+E8390_START,E8390_CMD	; go

		move.l	RrxPktLen,d1
		subq.l	#2,d1			; two bytes less we will eat first

		lea.l	pcktBuf,a0		; pointer to data
		getBUS	NE_DATAPORT,d0		; get first byte
		move.b	d0,(a0)+
		getMore	NE_DATAPORT,d0		; get second byte
		move.b	d0,(a0)+

		NE2RAM	a0,d1			; both regs get destroyed!
		putBUS	#E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUS	#ENISR_RDC,EN0_ISR	; reset remote DMA ready bit

* dump the data to screen, 16 bytes per line
		lea.l	pcktBuf,a0		; pointer to data
.t1		moveq	#15,d0

.t2		PrB	(a0)+
		PrS	.space(pc)
		subq.w	#1,RrxPktLen
		dbeq	d0,.t2
		
		PrS	.crlf(pc)
		tst	RrxPktLen
		bne.b	.t1

		PrS	.crlf(pc)

		moveq	#0,d0		; OK
		rts

.space		DC.B	" ",0
.crlf		DC.B	13,10,0


		SECTION	BSS
pcktBuf		DS.B	1600

*** stack must be allocated by the linker!
***		DS.B	256		; my stack area

******** end of HT3ENE.S ********************************************************

