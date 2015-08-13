*********************************************************************************
*										*
*	Low level part of MagicNet MIF NEx000 driver for my ACSI-ISA interface	*
* 	and the Cartridge Port interface developed by Lyndon Amsdon and me.	*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Features:									*
*	Packets are read/written directly from NEx000 to a MagiCNet datagram	*
*	without	further (double) buffering and memcpy				*
* Limitations:									*
*										*
* Credits:									*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: nemnet.s 1.3 2002/06/08 16:12:22 Thomas Exp Thomas $
*
* descriptions:
*


*
* development switches
*

		INCLUDE	DEVSWIT.I

*
* code generation options
*
***		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on


* entry points and references in this module
		XDEF	rtrvPckt	; (); get packet out of the card


* references from ENEMNET.S
		XREF	netinfo		; pointer to structure of MNet functions
		XREF	if_ENE		; structure for interface en0

*
* includes
*

* my stuff
		INCLUDE	UTI.I		; debugging and stack handling macros
		INCLUDE	BUS.I		; ACSI or Cartridge Port hardware macros
		INCLUDE	8390.I		; Symbols for 8390 chip registers

* MNet stuff, offsets in netinfo and if
		INCLUDE	INC_MNET\IF.I
		INCLUDE	INC_MNET\BUF.I
		INCLUDE	INC_MNET\NETINFO.I


		SECTION	TEXT


******** declarations for ethernet **********************************************
N8390Hdr	EQU	4		; the 8390 chip stores a 4 byte header preceeding the packet
NCRC		EQU	4		; 4 trailing CRC bytes of a ethernet packet



******** rtrvPckt ***************************************************************
* This function is called only (statically) once from ei_receive in NE.S; it does 
* special parameter passing different from Turbo-C, Pure-C or cdecl:
*
*
* This function effects to get the packet out of the NEx000 card into the ST RAM
*
* in:	RrxJnk8990	(d1) Junk 8390 header occured from 8990 chip (only IFD BUGGY_HW)
*	RrxPktLen	(d2) The raw ethernet packet length
*	RrxReadPg	(d4) Page where the packet starts
*
* out:
*	d0.l:	  0=OK
*		Errors:
*		 -1=cannot allocate buf
*		for all errors the packet just gets dropped
*
*	MagicNet statistics get updated
*	dev_* statistics do not get updated because dev_* is opaque to this module
*
* used
*	RxBUS,RyBUS,RcBUS,RdBUS
*
* changed:
*	We destroy d1,d2 although ei_receive appears to use them; they are in fact not
*	used any more after the call to rtrvPckt (this function).
*	We do not use a2 because it may get destroyed by each of the MNet functions
*	called here.
*
*	We save a4 because this is used throughout ei_interrupt as RitDVS
*	We use a3 to point to the new buffer
*	Hence a2-a3 shall be saved by ei_receive to avoid to save them for each call 
*	of rtrvPckt (assuming ei_receive has to process more than one packet)
*

* local variables in registers
	IFD	BUGGY_HW
RrxJnk8990	EQUR	d1		; as in NE.S
	ENDC
RrxPktLen	EQUR	d2		; as in NE.S
RrxReadPg	EQUR	d4		; as in NE.S

RrpPktLen	EQUR	d3		; local copy of RrxPktLen

RrpBuf		EQUR	a3		; points to the new buffer
RrpNif		EQUR	a4		; points to the interface struct if_ENE

	IFD	BUGGY_HW
* local variables in memory
rxJnk8990	EQU	0		; because d1 gets destroyed
	ENDC

rtrvPckt
	IFGE	RXDEBPRT-999
		PrW	RrxPktLen
		PrA	<" RrxPktLen",13,10>
	ENDC
		move.l	RrpNif,-(sp)		; save used reg.
		move	RrpPktLen,-(sp)		; save used reg.
	IFD	BUGGY_HW
		move.b	RrxJnk8990,-(sp)	; copy to memory (2 bytes pushed!)
	ENDC
		move	RrxPktLen,RrpPktLen	; copy because d2 gets destroyed

		lea	if_ENE,RrpNif		; access to interface structure

* do not know why these extra 50 front and 50 back are needed
		moveq	#100,d0			; more length
		add	RrpPktLen,d0		; .w but cannot overflow...

		Buf_alloc	d0,#50,#BUF_ATOMIC

		move.l	d0,RrpBuf		; buffer
		tst.l	d0
		beq	.err

		moveq	#0,d0
		move	RrpPktLen,d0		; unsigned extend
		add.l	d0,bf_dend(RrpBuf)	; move b->dend past packet

* we get the packet out of the card; just full lenght does not hurt (inc. CRC)
		putBUS	d0,EN0_RCNTLO
		lsr.w	#8,d0
		putBUS	d0,EN0_RCNTHI
* we need to skip the 8390 header
		putBUSi	N8390Hdr,EN0_RSARLO	; skip 8390 header (4)
		putBUS	RrxReadPg,EN0_RSARHI	; we start at this page
		putBUSi	E8390_RREAD+E8390_START,E8390_CMD	; go

	IFD	BUGGY_HW
* note that the data is shifted by one byte in case of a junk header, we need to do one more read
		tst.b	rxJnk8990(sp)
		beq.b	.c1
		getBUS	NE_DATAPORT,d0		; dummy read

.c1
	ENDC
		move.l	bf_dstart(RrpBuf),a0	; pointer to data

		NE2RAM	a0,RrpPktLen		; both regs get destroyed!
		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUSi	ENISR_RDC,EN0_ISR	; reset remote DMA ready bit

* pass packet to upper layers

* input filtering?
		tst.l	if_bpf(RrpNif)		; packet filter present?
		beq.b	.c2

		Bpf_input	(RrpNif),(RrpBuf)

* remove ethernet header (returns packet type in d0)
.c2		Eth_remove_hdr	(RrpBuf)

		moveq	#0,d1
		If_input	(RrpNif),(RrpBuf),d1,d0

		tst	d0			; error?
		bne.b	.err

		addq.l	#1,if_in_packets(RrpNif)	; statistics
		moveq.l	#0,d0			; signal succes & fall thru to exit

.exit
	IFD	BUGGY_HW
		addq.l	#2,sp			; pop local var.
	ENDC
		move	(sp)+,RrpPktLen		; restore used reg.
		move.l	(sp)+,RrpNif		; restore used reg.
		rts


.err		moveq.l	#-1,d0			; signal error
		addq.l	#1,if_in_errors(RrpNif)	; statistics
		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; abort remote DMA
		getBUS	NE_DATAPORT,d1		; only this makes for a proper abort !!!
		putBUSi	ENISR_RDC,EN0_ISR	; reset remote DMA ready bit
		bra.b	.exit


******** end of nemnet.s ********************************************************

