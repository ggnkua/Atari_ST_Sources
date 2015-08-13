*********************************************************************************
*										*
*	Generic NEx000 driver for any Bus interface and STinG and MagicNet	*
*	(tested) and MINTNet (untestet)						*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Features:									*
*	Supports both (old) NE1000 and old and new NE2000 (clone) cards		*
*										*
* Limitations:									*
*	Can only handle one card per machine					*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on the source	*
* modules NE.C and 8390.C from Linux originally due to the authors 		*
* Donald Becker and Paul Gortmaker.						*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: ne.s 1.3 2002/06/08 16:12:22 Thomas Exp Thomas $
*
* descriptions:
*
* All functions called from upper layer software request and relinquish Bus use
*
*
* Call Tree:
* 	ei_probe1
*		ethdev_init
*			ether_setup
*		NS8390_init
*			set_multicast_list
*
* 	ei_open
*		NS8390_init
*			set_multicast_list
*
* 	ei_close
*		NS8390_init
*
* 	ei_start_xmit
*		RAM2NE (macro)
*		ne_reset_8390
*		NS8390_init
*
* 	ei_interrupt
*		ei_rx_overrun
*			ei_receive
*				...
*		ei_receive
*			rtrvPckt (external)
* (StinG version)		rtrvStngDgram
* (StinG version)			NE2RAM (macro)
* (StinG version)		process_arp (external)
* (MagiCNet version)	rtrvPckt (external)
* (MagiCNet version)		NE2RAM (macro)
*		ei_tx_intr
*		ei_tx_err
*
*
*
* Handling of 8390 interrupt mask register; where are interupts enabled/disbled?
* This is not relevant here because this driver works with polling
*
* - ei_start_xmit
*	disable
*	enable
*
* - NS8390_init
*	disable			(called from ei_close)
*				(called from ei_probe1)
*	enable if "startp"	(called from ei_open)
*
* - ei_probe1
*	disable			(first inline, then by calling NS8390_init)
*
*
*********************************************************************************
*

*
* development switches
*

		INCLUDE	DEVSWIT.I

*
* configuration switches
*


*
* code generation options
*
***		OPT	D+		; switch on symbol info
		OPT	O+		; optimize 0(an) to (an)
		OPT	W-		; warnings off
		OPT	M+		; macro expansion in listings on


* entry points and references in this module
		XDEF	ei_probe1	; (); look for NEx000 hardware (super mode)
		XDEF	ei_open		; (); switch hardware on (super mode)
		XDEF	ei_close	; (); switch hardware off (super mode)
		XDEF	ei_start_xmit	; (); tx an ethernet packet (super mode)
		XDEF	ei_interrupt	; (); rx ethernet packets and housekeeping (super mode)
		XDEF	get_stats	; (); access to struct enet_statistics  (super mode)

		XDEF	DVS		; access to the device structure

* external references
		XREF	rtrvPckt	; (); call STinG or MagicNet or MINTNet specific code
					    ; to retrieve a packet from the card into RAM

*
* manifest constants
*
TRMAGIC		EQU	"TRNE"		; my XBRA ident (unused)

*
* addresses of system variables
*

_hz_200		EQU	$4ba		; (l) 200Hz system tick

HZ		EQU	200		; system timer ticks per second


		INCLUDE	UTI.I
		INCLUDE	BUS.I
		INCLUDE	NETDEV.I

		SECTION	TEXT
**** Auxiliary Code *************************************************************


_appl_yield	move.l	a2,-(sp)	; not needed for Pure C/GNU C, needed for Turbo C
		move.w	#201,d0
		trap #2
		movea.l	(sp)+,a2
		rts



*********************************************************************************
******** taken from <linux/if.h> ************************************************

IFF_BROADCAST	EQU	$0002
IFF_PROMISC	EQU	$0100
IFF_ALLMULTI	EQU	$0200
IFF_MULTICAST	EQU	$1000


*********************************************************************************
******** taken from drivers/net/net_init.c **************************************

*** just what we need here
ether_setup
		IFNE	1
		move	#IFF_BROADCAST+IFF_MULTICAST,DVS+dev_flags
		ELSEIF
		move	#IFF_BROADCAST+IFF_MULTICAST+IFF_PROMISC,DVS+dev_flags
		ENDC
		rts


*********************************************************************************
******** Start of NS8390 specific code ******************************************

		INCLUDE	8390.I

		SECTION	TEXT
******** ei_open ****************************************************************
* in
*
* out
*	d0.l	0=OK
*
* changed
*	Turbo-C convention: d0-d2,a0-a1 may get changed
*********************************************************************************

Ron		REG	d3-d5/RxBUS/RyBUS/a2-a4/RcBUS/RdBUS


ei_open		movem.l	Ron,-(sp)
		lockBUSWait			; aquire Bus
		ldBUSRegs			; load registers to access Bus

		moveq	#1,d0			; arg: startp
		bsr	NS8390_init
		st	DVS+dev_start

		deselBUS			; deselect Bus interface
		unlockBUSWait			; relinquish Bus
		moveq	#0,d0
.doNothing	movem.l	(sp)+,Ron
		rts



******** ei_close ***************************************************************
* in
*
* out
*	d0.l	0=OK
*
* changed
*	Turbo-C convention: d0-d2,a0-a1 may get changed
*********************************************************************************

Rcl		REG	d3-d5/RxBUS/RyBUS/a2-a4/RcBUS/RdBUS


ei_close	movem.l	Rcl,-(sp)
		lockBUSWait			; aquire Bus
		ldBUSRegs			; load registers to access Bus

		moveq	#0,d0			; arg: startp
		bsr	NS8390_init
		sf	DVS+dev_start

		deselBUS			; deselect Bus interface
		unlockBUSWait			; relinquish Bus
		moveq	#0,d0
.doNothing	movem.l	(sp)+,Rcl
		rts



******** ei_start_xmit **********************************************************
* Transfer a raw ethernet packet from RAM into the NEx000 and start the transmitter
* To minimize packet double buffering this function allows to specify two non
* contiguous parts of the packet which get catenated here on the fly. This eases
* to assemble an enet packet from STinGs dgram representation.
*
* long ei_start_xmit (char* buff1, short len1, char* buff2, short len2);
*
* in
*	a0.l:	points to packet to send first  portion
*	d0.w:	length of packet to send first  portion
*	a1.l:	points to packet to send second portion
*	d1.w:	length of packet to send second portion
*
* out
*	d0.l	0=OK
*		1=transmitter busy or other errors
* changed
*	Turbo-C convention: d0-d2,a0-a1 may get changed
*
* N.b.: block_output and NS8390_trigger_send employed in the Linux code
* are inlined here to save cycles and to avoid the need for double buffering
*
* Only one tx buffer in use.
*
* Note that usually after calling ei_start_xmit (about 1.5 millisec) a Packet
* Transmitted interrupt would be fired ($02). Here this interrupt is dealt with
* by polling in ei_interrupt.
*
* Transmitting with NEx000 is a two step process:
* 1.	loading the RAM onboard the NE from the systems RAM by a remote
*	DMA write command
* 2.	kicking the NE so that it starts txing from its onboard RAM
*	out to the network
*
* There is a semaphore: dev_tbusy
* -	it is set at the beginning of ei_start_xmit (this function)
* -	it is queried before setting it
* -	it is reset in ei_tx_intr
* This avoids trying to transmit while transmit is still in progress
*
*********************************************************************************

* The maximum time waited (in jiffies) before assuming a Tx failed. (1000ms)
TX_TIMEOUT	EQU	((1000*HZ)/1000)

Rsx		REG	d3/RxBUS/RyBUS/a2/RcBUS/RdBUS


ei_start_xmit	move.w	d0,d2			; save arg
		lockBUS				; aquire Bus, jumps to .doNothing
						; on fail to lock with d0.l=-1
		movem.l	Rsx,-(sp)
		move.l	a0,a2			; save arg
	IFGE	TXDEBPRT-3
		PrL	_hz_200\w
		PrA	<" Tx l1: ">
		PrW	d2
		PrA	<" l2: ">
		PrW	d1
	ENDC
		ldBUSRegs			; load registers to access Bus

		tas	DVS+dev_tbusy		; is NE transmitting?
		beq.b	.c1			; no, go on

		move.l	_hz_200\w,d0		; yes, check how long ago
		sub.l	DVS+dev_trans_start,d0	; time since start of last xmit
		cmp.l	#TX_TIMEOUT,d0
		bls	.TxBusy			; not yet over, leave it alone
		
		addq.w	#1,DVS+lcl_es_tx_errors	; possibly died
	IFGE	TXDEBPRT-1
		PrA	<"TX timed out",13,10>
	ENDC
		movem.l	d1/d2/a1/a2,-(sp)	; save args
		bsr	ne_reset_8390		; hard reset 8390 chip
		moveq	#1,d0			; arg: startp=1
		bsr	NS8390_init		; init 8390 chip
		movem.l	(sp)+,d1/d2/a1/a2	; restore args used below
		st	DVS+dev_tbusy		; set semaphor again (NS8390_init clears it)
						; and fall thru to transmit

.c1		move	d2,d3			; len1
		add	d1,d3			; + len2 = total length
		move	d3,d0			; need lenght below again
		putBUS	d0,EN0_RCNTLO		; DMA count
		lsr.w	#8,d0
		putBUS	d0,EN0_RCNTHI		; "
		putBUSi	0,EN0_RSARLO		; DMA destination
		move.b	DVS+lcl_tx_start_page,d0
		putBUS	d0,EN0_RSARHI		; 8390 page to tx from
* start remote DMA write
		putBUSi	E8390_RWRITE+E8390_START,E8390_CMD

		RAM2NE	a2,d2			; put ethernet packet first  portion
		RAM2NE	a1,d1			; put ethernet packet second portion

		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUSi	ENISR_RDC,EN0_ISR	; ack intr.

		putBUS	d3,EN0_TCNTLO		; transmit count
		lsr.w	#8,d3
		putBUS	d3,EN0_TCNTHI		; "
		; 8390 page to tx from was already set in NS8390_init
* start transmitter
		putBUSi	E8390_NODMA+E8390_TRANS+E8390_START,E8390_CMD
	IFGE	TXDEBPRT-3
		PrA	<" start",13,10>
	ENDC
		move.l	_hz_200\w,DVS+dev_trans_start	; save tx start time
		moveq	#0,d0			; rc=OK

.quit		deselBUS			; deselect Bus interface
		movem.l	(sp)+,Rsx		; restore used registers
		unlockBUS			; relinquish Bus
.doNothing	rts


.TxBusy		moveq	#1,d0			; rc
		bra.b	.quit




******** ei_interrupt ***********************************************************
* The typical workload of the driver:
* Handle the ether interface interrupts. This is done by polling here.
* Thus this function is *not* a proper interrupt handler (it does not save all 
* regs. and ends with rts rather than rte).
*
* in:
*	nothing
*
* out:
*	nothing
*
* changed:
*	d0-d2,a0-a1 do change and are not saved to match Turbo-C 2.0 calling 
*	convention we save only those regs. that get changed in ei_interrupt 
*	to keep it fast. ei_receive saves the regs it uses
*
* uses
*	d5, RxBUS,RyBUS, a4, RcBUS,RdBUS
*
*********************************************************************************

* local variables in registers
RitInts		EQUR	d5		; copy of interrupt register; to be conserved by lower levels!
RitDVS		EQUR	a4		; pointer to global vars.

Rit		REG	RitInts/RxBUS/RyBUS/RitDVS/RcBUS/RdBUS	; saved registers on entry


ei_interrupt	lockBUS				; aquire Bus, jumps to .doNothing
						; on fail to lock with d0.l=-1
		movem.l	Rit,-(sp)		; save all used registers
		lea	DVS,RitDVS		; allows faster access to global vars.
		ldBUSRegs			; load registers to access Bus

	IFNE	PARANOIA
.t1		move	sr,d1			; save int. level
		ori	#$700,sr		; disable all ints.
	ENDC
		getBUS	EN0_ISR,RitInts		; look what is up
	IFNE	PARANOIA
		getMore	EN0_ISR,d0		; again to minimize spike risk
		move	d1,sr			; reenable ints.
		cmp.b	d0,RitInts		; should always be the same
		bne.b	.t1
	ENDC
		tst.b	RitInts			; more interrupts to do?
		beq	.exit			; exit if no interrupts at all

* check for interrupt causes one by one
		mtst	ENISR_OVER,RitInts	; overrun on receive?
		beq.b	.c1

	IFGE	RXDEBPRT-4
		PrL	_hz_200\w
		PrA	<" IRxOver ISR: ">
		PrB	RitInts
		PrS	crlf(pc)
	ENDC
		bsr	ei_rx_overrun
		bra	.c2			; this did ei_receive already


.c1		mtst	ENISR_RX,RitInts	; got a good packet?
		beq	.c11

	IFGE	RXDEBPRT-4
		PrL	_hz_200\w
		PrA	<" IRxRecv ISR: ">
		PrB	RitInts
		PrA	<" RSR: ">
		getBUS	EN0_RSR,d0
		PrB	d0
		PrS	crlf(pc)
	ENDC
		bsr	ei_receive


.c11		mtst	ENISR_RX_ERR,RitInts	; RX with error?
		beq	.c2

	IFGE	RXDEBPRT-4
		PrL	_hz_200\w
		PrA	<" IRxErr  ISR: ">
		PrB	RitInts
		PrA	<" RSR: ">
		getBUS	EN0_RSR,d0
		PrB	d0
		PrS	crlf(pc)
	ENDC
		addq.w	#1,lcl_es_rx_errors(RitDVS)	; that is all we do
		putBUSi	ENISR_RX_ERR,EN0_ISR	; ack intr.


.c2		mtst	ENISR_TX,RitInts	; TX finished
		beq.b	.c3

	IFGE	TXDEBPRT-4
		PrL	_hz_200\w
		PrA	<" ITxDone ISR: ">
		PrB	RitInts
		PrS	crlf(pc)
	ENDC
		bsr	ei_tx_intr
***		bra.b	.c4			; TX and TX_ERR are mut. exclusive


.c3		mtst	ENISR_TX_ERR,RitInts
		beq.b	.c4

	IFGE	TXDEBPRT-4
		PrL	_hz_200\w
		PrA	<" ITxErr  ISR: ">
		PrB	RitInts
		PrS	crlf(pc)
	ENDC
		bsr	ei_tx_err


.c4		mtst	ENISR_COUNTERS,RitInts
		beq.b	.c5

		move	#$ff,d1
		getBUS	EN0_COUNTER0,d0
		and	d1,d0			; suppress junk bits
		add	d0,lcl_es_rx_frame_errors(RitDVS)
		getBUS	EN0_COUNTER1,d0
		and	d1,d0
		add	d0,lcl_es_rx_crc_errors(RitDVS)
		getBUS	EN0_COUNTER2,d0
		and	d1,d0
		add	d0,lcl_es_rx_missed_errors(RitDVS)

		putBUSi	ENISR_COUNTERS,EN0_ISR	; ack intr.


.c5		mtst	ENISR_RDC,RitInts
		beq.b	.c6

	IFGE	RXDEBPRT-4
		PrL	_hz_200\w
		PrA	<" IRxRDC  ISR: ">
		PrB	RitInts
		PrS	crlf(pc)
	ENDC
		putBUSi	ENISR_RDC,EN0_ISR	; ignore RDC interrupts that make it here

.c6
.exit		deselBUS			; deselect Bus interface
		movem.l	(sp)+,Rit		; restore used registers
		unlockBUS			; relinquish Bus
.doNothing	rts



******** ei_tx_err **************************************************************
* A transmitter error has happened. Most likely excess collisions (which
* is a fairly normal condition). If the error is one where the Tx will
* have been aborted, we do not try to send the packet sitting in the NE buffer
* again because tx would not be finished before the next tx is attempted by 
* ei_start_xmit
*
* in
*	nothing
*
* out
*	nothing
*
* uses
*	RitDVS
*
* changed
*
*********************************************************************************

* local variables in registers
RteTxsr		EQUR	d1		; temporary

ei_tx_err	getBUS	EN0_TSR,RteTxsr
		putBUSi	ENISR_TX_ERR,EN0_ISR		; Ack intr.
		sf	dev_tbusy(RitDVS)		; NE is available for next tx

		mtst	ENTSR_ABT,RteTxsr
		beq.b	.c1

		addq.w	#1,lcl_es_tx_aborted_errors(RitDVS)
		IFGE	TXDEBPRT-1
		PrS	.m1(pc)
		ENDC

.c1		mtst	ENTSR_ND,RteTxsr
		beq.b	.c2

		IFGE	TXDEBPRT-1
		PrS	.m2(pc)
		ENDC

.c2		mtst	ENTSR_CRS,RteTxsr
		beq.b	.c3

		addq.w	#1,lcl_es_tx_carrier_errors(RitDVS)
		IFGE	TXDEBPRT-1
		PrS	.m3(pc)
		ENDC

.c3		mtst	ENTSR_FU,RteTxsr
		beq.b	.c4

		addq.w	#1,lcl_es_tx_fifo_errors(RitDVS)
		IFGE	TXDEBPRT-1
		PrS	.m4(pc)
		ENDC

.c4		mtst	ENTSR_CDH,RteTxsr
		beq.b	.c5

		addq.w	#1,lcl_es_tx_hartbeat_errors(RitDVS)
		IFGE	TXDEBPRT-1
		PrS	.m5(pc)
		ENDC

.c5		mtst	ENTSR_OWC,RteTxsr
		beq.b	.c6

		addq.w	#1,lcl_es_tx_window_errors(RitDVS)
		IFGE	TXDEBPRT-1
		PrS	.m6(pc)
		ENDC

.c6
		IFGE	TXDEBPRT-1
		PrS	crlf(pc)
		ENDC
		rts


		IFGE	TXDEBPRT-1
.m1		DC.B	"excess-collisions ",0
.m2		DC.B	"non-deferral ",0
.m3		DC.B	"lost-carrier ",0
.m4		DC.B	"FIFO-underrun ",0
.m5		DC.B	"lost-heartbeat ",0
.m6		DC.B	"window ",0
		EVEN
		ENDC



******** ei_tx_intr *************************************************************
* We have finished a transmit: check for errors
* We can not trigger another send because we use only one tx buffer and tx would
* not be finished before next attempt by ei_start_xmit
*
* in
*	nothing
*
* out
*	nothing
*
* uses
*	RitDVS
*
* changed
*
*********************************************************************************

* local variables in registers
RtiStts		EQUR	d1		; temporary


ei_tx_intr	getBUS	EN0_TSR,RtiStts		; first get status for this one
		putBUSi	ENISR_TX,EN0_ISR	; Ack intr.
		sf	dev_tbusy(RitDVS)	; NE is available for next tx

* Minimize Tx latency: update the statistics after we restart TXing

* do we have a collision?
		mtst	ENTSR_COL,RtiStts
		beq.b	.c1
		addq.w	#1,lcl_es_collisions(RitDVS)	; just book keeping

* do we have a packet transmitted?
.c1		mtst	ENTSR_PTX,RtiStts
		beq.b	.c2

		addq.w	#1,lcl_es_tx_packets(RitDVS)	; the usual case
.exit		rts


* this shall never happen
.c2
		IFGE	TXDEBPRT-1
		PrS	.m1(pc)
		ENDC
		bra.b	.exit

		IFGE	TXDEBPRT-1
.m1		DC.B	"TX Err in tx_intr?",13,10,0
		EVEN
		ENDC


******** ei_receive *************************************************************
* We have a good packet(s), get it/them out of the buffers.
*
* N.b.: get_8390_hdr and block_input employed in the Linux code are not used here.
* Rather an inlined remote DMA Read packet technique is used
*
* in
*	nothing
*
* out
*	nothing
*
* uses
*	RxBUS,RyBUS, RitDVS, RcBUS,RdBUS

*
* changed
*	
*
********
* The 8390 header problem:
* Was observed with 1 NE1000 clone with Winbond W89C90 chip
* 1 NE2000 clone with Winbond W89C90 chip
* 1 NE2000 clone with UMC UM9090 chip
* Symptoms:
* The Status field (rxHdrSts) contains garbage
* The Next Frame field (RrxNextFrm) looks like it contains the Status value
* The Lo Byte Count field looks like it contains the Next Frame value
* The Hi Byte Count field looks like it contains the Lo Byte Count
* We recover accordingly
* This renders 8390 Remote DMA Send useless and necessitates Remote DMA Read
* This also defeats use of the error bits in the 8390 header
*
* This problem was not observed with a new single chip NE2000 clone with
* Realtek RTL8019AS chip
*********************************************************************************

N8390Hdr	EQU	4		; the chip saves a 4 bytes header preceeding the packet

* local variables in registers
RrxReadPg	EQUR	d4			; page where the newly arrived packet shall be read from
RrxNextFrm	EQUR	d3			; the next packet to be read
RrxPktLen	EQUR	d2			; lenght of the newly arrived packet
RrxJnk8990	EQUR	d1			; Header is junk flag (8990, 9090 symptom)

RrxHiLvl1	EQUR	a2			; we save these here to avoid rtrvPkct needs to save
RrxHiLvl2	EQUR	a3			; them at each call (assumes >1 packet to slurp)

* local variables in memory
		RSRESET
rxHdrSts	RS.B	1			; 8390 status byte
rxDummy1	RS.B	1			; align
rxPktCnt	RS.W	1			; max. # of packets to slurp
rxNLcl		EQU	__RS


Rrx		REG	RrxNextFrm/RrxReadPg/RrxHiLvl1/RrxHiLvl2	; saved registers on entry


ei_receive	movem.l	Rrx,-(sp)			; save registers
		Alloc	rxNLcl				; locals vars
		move	#20,rxPktCnt(sp)			; # packets maximum
	IFGE	RXDEBPRT-2
		addq.w	#1,eiCalls
	ENDC

		move.b	lcl_current_page(RitDVS),RrxReadPg	; start reading where writing should have commenced


.t1		putBUSi	E8390_NODMA+E8390_PAGE1+E8390_START,E8390_CMD	; switch to page 1
	IFNE	PARANOIA
		move	sr,d1					; save status register
		ori	#$700,sr				; disable all ints.
	ENDC
.t0		getBUS	EN1_CURPAG,d0
		move.b	d0,lcl_current_page(RitDVS)		; get the rx page (incoming packet pointer)
	IFNE	PARANOIA
		getBUS	EN1_CURPAG,d0				; again
		cmp.b	lcl_current_page(RitDVS),d0		; should be equal
		bne.b	.t0
		move	d1,sr					; reenable ints.
	ENDC
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_START,E8390_CMD	; revert to page 0

* when we have read up to CurrPg we are done
		cmp.b	lcl_current_page(RitDVS),RrxReadPg	; Read all the frames?
		beq	.exit					; Done for now

* get the header the NIC stored at the beginning of the frame
		moveq	#0,d0
	IFD	BUGGY_HW
		moveq	#0,RrxJnk8990			; assume no Hdr junk
	ENDC
		putBUSi	N8390Hdr,EN0_RCNTLO
		putBUS	d0,EN0_RCNTHI			; Hdr is only some bytes
		putBUS	d0,EN0_RSARLO			; Hdr is on page boundary
		putBUS	RrxReadPg,EN0_RSARHI
		putBUSi	E8390_RREAD+E8390_START,E8390_CMD ; start remote DMA Read

		getBUS	NE_DATAPORT,d0
		move.b	d0,rxHdrSts(sp)			; first: status byte
		getMore	NE_DATAPORT,RrxNextFrm		; next:  next page
		getMore	NE_DATAPORT,d0			; next:  Count Lo
		getMore	NE_DATAPORT,RrxPktLen		; next:  Count Hi
		lsl.w	#8,RrxPktLen			; Count Hi in upper byte
		move.b	d0,RrxPktLen			; merge in Count Lo byte
* RrxPktLen is the length of the packet data to *follow* the header (incl. CRC)
		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUSi	ENISR_RDC,EN0_ISR		; reset remote DMA ready bit

* check status (only $01 and $21 is good)
		move.b	rxHdrSts(sp),d0
		and.b	#$ff-ENRSR_PHY-ENRSR_DEF,d0	; do not care phys/multi., defer.
		cmp.b	#ENRSR_RXOK,d0			; only his should be set
		bne	.err

* check if next frame is within start and stop
		cmp.b	lcl_rx_start_page(RitDVS),RrxNextFrm
		bcs	.err
		cmp.b	lcl_stop_page(RitDVS),RrxNextFrm
		bhi	.err

* we should also check here if CountHi is consistent with NextFrm and ReadPg (sic!)

* check for good ethernet packet length
		cmp	#64,RrxPktLen			; check for bogus length
		bcs	.err
		cmp	#1518,RrxPktLen			; 6(eth)+6(eth)+2(type)+1500+4(crc)
		bhi	.err


.getPkt		; here we assume things are OK
	IFGE	RXDEBPRT-3
		PrA	<9,"Rx ">
		bsr	eirDumpState
	ENDC

		addq.w	#1,RrxPktLen			; round up to even
		and.w	#$fffe,RrxPktLen

* implied arg: RrxPktLen (d2)
* implied arg: RrxReadPg (d4)
* implied arg: RrxJnk8990 (d1)
		bsr	rtrvPckt			; get packet out of the card
		tst.l	d0				; update driver statistics
		bne.b	.c4
		addq.w	#1,lcl_es_rx_packets(RitDVS)
		bra.b	.c5
.c4		addq.w	#1,lcl_es_rx_dropped(RitDVS)
.c5
* set boundary one page behind up to including the page to be read next
.skip		move.b	RrxNextFrm,RrxReadPg			; start of next packet to be read
		cmp.b	lcl_rx_start_page(RitDVS),RrxNextFrm	; if Next is at the start
		bne.b	.c6
		move.b	lcl_stop_page(RitDVS),RrxNextFrm	; ...boundary must be stop-1
.c6		subq.b	#1,RrxNextFrm
		putBUS	RrxNextFrm,EN0_BOUNDARY			; update boundary

.b2		subq.w	#1,rxPktCnt(sp)			; make sure not tied up to much
		bne	.t1				; next packet


	IFGE	RXDEBPRT-2
		PrA	<9,"Too much to receive",10,13,0>
	ENDC


.exit		putBUSi	ENISR_RX+ENISR_RX_ERR,EN0_ISR	; ack interrupt

		deAlloc	rxNLcl				; pop local vars
		movem.l	(sp)+,Rrx			; restore registers
		rts


debPrint	MACRO
		IFGE	RXDEBPRT-2
		PrA	<\1>
		bsr	eirDumpState
		ENDC
		ENDM


* when we get here we likely have the 8390 header writing problem
	IFND	BUGGY_HW
.m1		DC.B	"Funny Hdr in ei_receive",13,10,0
		EVEN
.err
		PrS	.m1(pc)
		bra	.skip

	ELSEIF
.err
		debPrint	<9,"RxX">
* check status (only $01 and $21 is good) again
		move.b	RrxNextFrm,d0			; the misguided status
		and.b	#$ff-ENRSR_PHY-ENRSR_DEF,d0	; do not care phys/multi., defer.
		cmp.b	#ENRSR_RXOK,d0			; only his should be set
		bne.b	.e2				; hopeless

		; here there is still a chance
		move.b	RrxPktLen,RrxNextFrm		; fix Next
		sub.b	RrxReadPg,RrxPktLen		; calculate Count Hi Byte
		subq.b	#1,RrxPktLen			; rounding ???
		bge.b	.c1
	
		add.b	lcl_stop_page(RitDVS),RrxPktLen		; adjust for wrap
		sub.b	lcl_rx_start_page(RitDVS),RrxPktLen

.c1		ror.w	#8,RrxPktLen			; swap bytes
		tst.b	RrxPktLen			; if Lo Count==0 ...
		bne.b	.c2
		add.w	#$0100,RrxPktLen		; ...one more block
.c2
		debPrint	<9,"RxY">

* check if next frame is within start and stop again
		cmp.b	lcl_rx_start_page(RitDVS),RrxNextFrm
		bcs.b	.e2
		cmp.b	lcl_stop_page(RitDVS),RrxNextFrm
		bhi.b	.e2

* check for good ethernet packet length again
		cmp	#64,RrxPktLen			; check for bogus length
		bcs.b	.e2
		cmp	#1518,RrxPktLen			; 6+6+2(type)+1500+4(crc)
		bls.b	.c3


* this is the brute force method to skip the junk and try to synchronise again
.e2
		debPrint	<9,"RxZ">
		move.b	lcl_current_page(RitDVS),RrxNextFrm
		bra	.skip


.c3		; when we get here we have the 8390 header problem sucessfully fixed
		; and go for normal extraction of the packet
		st	RrxJnk8990			; take note of Hdr problem
		bra	.getPkt				; and resume

	ENDC	; IFND BUGGY_HW



		IFGE	RXDEBPRT-2
eirDumpState	
		PrA	<" Cls: ">
		PrW	eiCalls(pc)
		PrA	<" Cnt: ">
		PrB	rxPktCnt+1+4(sp)
		PrA	<" Rea: ">
		PrB	RrxReadPg
		PrA	<" Nxt: ">
		PrB	RrxNextFrm
		PrA	<" Cur: ">
		PrB	lcl_current_page(RitDVS)
		PrA	<" Sts: ">
		PrB	rxHdrSts+4(sp)
		PrA	<" Siz: ">
		PrW	RrxPktLen
		PrS	crlf(pc)
		rts

eiCalls		DC.W	0
		ENDC


******** ei_rx_overrun **********************************************************
* We have a receiver overrun: we have to kick the 8390 to get it started
* again. Problem is that you have to kick it exactly as NS prescribes in
* the updated datasheets, or "the NIC may act in an unpredictable manner."
* This includes causing "the NIC to defer indefinitely when it is stopped
* on a busy network."  Ugh.
*
* in
*	nothing
*
* out
*	nothing
*
* changed
*
*********************************************************************************

* local variables in memory; we must use them here instead of registers because 
* ei_receive (called below) would destroy those registers
		RSRESET
roWasTxing	RS.W	1
roMustResend	RS.w	1
roNLcl		EQU	__RS


ei_rx_overrun	Alloc	roNLcl				; locals vars
		clr	roMustResend(sp)

		getBUS	E8390_CMD,d0
		and	#E8390_TRANS,d0
		move	d0,roWasTxing(sp)		; find out if transmit is in progress
		
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_STOP,E8390_CMD	; stop

	IFGE	RXDEBPRT-1
		PrA	<"Receiver overrun",13,10>
	ENDC
		addq.w	#1,lcl_es_rx_over_errors(RitDVS)

* Wait a full Tx time (1.2ms) + some guard time, NS says 1.6ms total.
* Early datasheets said to poll the reset bit, but now they say that
* it "is not a reliable indicator and subsequently should be ignored."

		move.l	ticks2ms(RitDVS),d0	; wait 2ms
		moveq	#2,d1			; irrelevant here
		bsr	ADelay

* Reset RBCR[01] back to zero as per magic incantation.
		moveq	#0,d0
		putBUS	d0,EN0_RCNTLO
		putBUS	d0,EN0_RCNTHI

* See if any Tx was interrupted or not. According to NS, this
* step is vital, and skipping it will cause no end of havoc.
		tst	roWasTxing(sp)
		beq.b	.c1

		getBUS	EN0_ISR,d0
		and	#ENISR_TX+ENISR_TX_ERR,d0	; completed if non zero
		seq	roMustResend(sp)		; if zero must resend

* Have to enter loopback mode and then restart the NIC before
* you are allowed to slurp packets up off the ring.
.c1		putBUSi	E8390_TXOFF,EN0_TXCR
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_START,E8390_CMD	; restart

* Clear the Rx ring of all the debris, and ack the interrupt.
		bsr	ei_receive
		putBUSi	ENISR_OVER,EN0_ISR

* Leave loopback mode, and resend any packet that got stopped.
		putBUSi	E8390_TXCONFIG,EN0_TXCR 

		tst	roMustResend(sp)
		beq.b	.c2
 
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_START+E8390_TRANS,E8390_CMD

.c2		deAlloc	roNLcl			; pop local vars
		rts




*********************************************************************************
* update statics counters and get access to them
*********************************************************************************


RgsDVS		EQUR	a4

Rgs		REG	RxBUS/RyBUS/RgsDVS/RcBUS/RdBUS


get_stats	movem.l	Rgs,-(sp)
		lea	DVS,RgsDVS
		lockBUS				; aquire Bus
						; jumps to .doNothing on fail to lock
		ldBUSRegs			; load registers to access Bus

		tst.b	dev_start(RgsDVS)	; device active?
		beq.b	.c1			; if not, just return pointer

* if accessible and device is running, update statistics
		move	#$ff,d1
		getBUS	EN0_COUNTER0,d0
		and	d1,d0			; suppress junk bits
		add	d0,lcl_es_rx_frame_errors(RgsDVS)
		getBUS	EN0_COUNTER1,d0
		and	d1,d0
		add	d0,lcl_es_rx_crc_errors(RgsDVS)
		getBUS	EN0_COUNTER2,d0
		and	d1,d0
		add	d0,lcl_es_rx_missed_errors(RgsDVS)
	
.c1		deselBUS			; deselect Bus interface
		unlockBUS			; relinquish Bus
.doNothing	move.l	#DVS+lcl_stats,d0	; OK
		movem.l	(sp)+,Rgs		; restore used registers
		rts


******** set_multicast_list *****************************************************
*	Set or clear the multicast filter for this adaptor.
*********************************************************************************

set_multicast_list
		move	DVS+dev_flags,d0
		and	#IFF_PROMISC,d0
		beq.b	.c1
		putBUSi	E8390_RXCONFIG+$18,EN0_RXCR
		bra.b	.c3

.c1		move	DVS+dev_flags,d0
		and	#IFF_ALLMULTI,d0
		or	DVS+dev_mc_list,d0
		beq.b	.c2
* The multicast-accept list is initialized to accept-all, and we rely on 
* higher-level filtering for now.
		putBUSi	E8390_RXCONFIG+$08,EN0_RXCR
		bra.b	.c3

.c2		putBUSi	E8390_RXCONFIG,EN0_RXCR

.c3		rts



******** ethdev_init ************************************************************
* Initialize the rest of the 8390 device structure.
*********************************************************************************

ethdev_init	bsr	ether_setup
		rts



******** NS8390_init ************************************************************
* This page of functions should be 8390 generic
* Follow National Semi's recommendations for initializing the "NIC"
*
* in:
*	d0.w	if <> 0 initialize more
* out:
*	nothing
*
* changed:
*	d0, a0
*********************************************************************************

NS8390_init	move	d0,-(sp)		; save argument "startp"

* Follow National Semi's recommendations for initing the DP83902
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_STOP,E8390_CMD
* we always access byte-wise: $48, never word-wise: $49
		putBUSi	$48,EN0_DCFG
* Clear the remote byte count registers
		moveq	#0,d1
		putBUS	d1,EN0_RCNTLO
		putBUS	d1,EN0_RCNTHI
* Set to monitor and loopback mode -- this is vital!
		putBUSi	E8390_RXOFF,EN0_RXCR
		putBUSi	E8390_TXOFF,EN0_TXCR
* Set the transmit page and receive ring
		move.b	DVS+lcl_tx_start_page,d0
		putBUS	d0,EN0_TPSR
		move.b	DVS+lcl_rx_start_page,d0
		putBUS	d0,EN0_BOUNDARY
		putBUS	d0,EN0_STARTPG
		move.b	DVS+lcl_stop_page,d0
		putBUS	d0,EN0_STOPPG
* Clear the pending interrupts and mask
		putBUSi	$ff,EN0_ISR		; acknoledge all
		putBUS	d1,EN0_IMR		; and disable all interrupts
    
* Copy the station address into the DS8390 registers, and set the 
* multicast hash bitmap to receive all multicasts
		putBUSi	E8390_NODMA+E8390_PAGE1+E8390_STOP,E8390_CMD
		lea	DVS+dev_dev_addr,a0
		move.b	(a0)+,d0
		putBUS	d0,EN1_PHYS+0
		move.b	(a0)+,d0
		putBUS	d0,EN1_PHYS+1
		move.b	(a0)+,d0
		putBUS	d0,EN1_PHYS+2
		move.b	(a0)+,d0
		putBUS	d0,EN1_PHYS+3
		move.b	(a0)+,d0
		putBUS	d0,EN1_PHYS+4
		move.b	(a0)+,d0
		putBUS	d0,EN1_PHYS+5

* Initialize the multicast list to accept-all. If we enable multicast the 
* higher levels can do the filtering
		moveq	#$ff,d0
		putBUS	d0,EN1_MULT+0
		putBUS	d0,EN1_MULT+1
		putBUS	d0,EN1_MULT+2
		putBUS	d0,EN1_MULT+3
		putBUS	d0,EN1_MULT+4
		putBUS	d0,EN1_MULT+5
		putBUS	d0,EN1_MULT+6
		putBUS	d0,EN1_MULT+7

		move.b	DVS+lcl_rx_start_page,d0
		addq.b	#1,d0				; boundary one behind current
		putBUS	d0,EN1_CURPAG
		move.b	d0,DVS+lcl_current_page		; mirror
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_STOP,E8390_CMD	; back to page 0

		sf	DVS+dev_tbusy		; initialize
		sf	DVS+dev_interrupt	; initialize
		sf	DVS+lcl_irqlock		; initialize

		move	(sp)+,d0		; restore argument "startp"
		beq.b	.c1
		putBUSi	$ff,EN0_ISR		; clear all interrupts
* for this application (polling) we leave all intr masked.
*		putBUSi	ENISR_ALL,EN0_IMR	; and enable all
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_START,E8390_CMD
		putBUSi	E8390_TXCONFIG,EN0_TXCR	; xmit on
* 3c503 TechMan says rxconfig only after the NIC is started
		putBUSi	E8390_RXCONFIG,EN0_RXCR	; rx on 
* Get the multicast status right if this was a reset
		bsr	set_multicast_list

.c1		rts




******** End of the NS8390 chip specific code ***********************************
*********************************************************************************
******** Start of the NEx000 and clones board specific code *********************



**** Delay function specific to Ataris ******************************************
* in:
*	d0.l maximum delay time in processor specific units
*	d1.l maximum delay time in 200Hz timer ticks = 5ms
* out:
*	d0 time left in processor specific units

ADelay		lea	_hz_200\w,a0
		add.l	(a0),d1			; time to quit at

.t1		subq.l	#1,d0			; time has come?
		beq.b	.exit
		cmp.l	(a0),d1			; time has come?
		bhi.b	.t1

.exit		rts



******** ei_probe1 **************************************************************
* we do not have a ne_probe from which this gets called
*
* in:
*	nothing
* out:
*	d0.l	  0=OK
*		<>0=Error, no device found
*
* changed:
*	a lot
*********************************************************************************

* local variables in registers
RprDVS		EQUR	a4		; pointer to global vars.

NBSA_prom	EQU	32

* local variables in memory
		RSRESET
pbSA_prom	RS.B	NBSA_prom
pbWordLen	RS.W	1
pbNEx000	RS.B	1
pbFiller	RS.B	1
pbNLcl		EQU	__RS

Rpr		REG	RxBUS/RyBUS/RprDVS/RcBUS/RdBUS


ei_probe1	movem.l	Rpr,-(sp)		; save used regs
		lea	DVS,RprDVS		; allows faster access to global vars.
		Alloc	pbNLcl			; allocate locals vars
		move	#2,pbWordLen(sp)
		lockBUSWait			; aquire Bus
		ldBUSRegs			; load registers to access Bus

* first we calibrate 2ms for this specific machine
		moveq.l	#0,d0			; indefinitely
		move.l	#26,d1			; 26*5ms=130ms according to _hz_200
		bsr.b	ADelay
		neg.l	d0			; so many machine ticks for 130ms
		asr.l	#6,d0			; 2ms = 130ms/64
		addq.l	#1,d0			; always round up
		move.l	d0,ticks2ms(RprDVS)	; store for use in the driver

		getBUS	NE_RESET,d1
		putBUS	d1,NE_RESET

*		move.l	ticks2ms(RprDVS),d0	; wait 2ms
		moveq	#2,d1			; wait 5-10ms maximum
		bsr.b	ADelay

		getBUS	EN0_ISR,d1		; read isr
		and.b	#ENISR_RESET,d1		; test for reset bit
		bne.b	.c1

		PrS	.m1(pc)
		moveq	#-1,d0			; Error
		bra	.quit

.c1		putBUSi	$ff,EN0_ISR		; ack all interrupts

		moveq	#0,d0
		putBUSi	E8390_NODMA+E8390_PAGE0+E8390_STOP,E8390_CMD	; select page 0
		putBUSi	$48,EN0_DCFG		; set byte-wide access
		putBUS	d0,EN0_RCNTLO		; clear the count regs.
		putBUS	d0,EN0_RCNTHI
		putBUS	d0,EN0_IMR		; mask completion iqr
		putBUSi	$ff,EN0_ISR
		putBUSi	E8390_RXOFF,EN0_RXCR	; $20 set to monitor
		putBUSi	E8390_TXOFF,EN0_TXCR	; $02 and loopback mode
.again		putBUSi	NBSA_prom&$ff,EN0_RCNTLO
		putBUSi	NBSA_prom>>8,EN0_RCNTHI
		putBUS	d0,EN0_RSARLO		; DMA starting at $0000
		putBUS	d0,EN0_RSARHI
		putBUSi	E8390_RREAD+E8390_START,E8390_CMD	; go

		move	#NBSA_prom/2-1,d2
		lea	pbSA_prom(sp),a0

.t2		getBUS	NE_DATAPORT,d0
		move.b	d0,(a0)+
		getMore	NE_DATAPORT,d1
		move.b	d1,(a0)+
		cmp.b	d0,d1			; check for doubled up values
		beq.b	.c2
		move	#1,pbWordLen(sp)		
.c2		dbra	d2,.t2

		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUSi	ENISR_RDC,EN0_ISR	; ack intr.

	IFNE 0
		PollKey
		tst	d0
		beq	.again

		WaitKey
	ENDC

	IFNE	MACAddDEBPRT
		lea	pbSA_prom(sp),a0
		moveq	#NBSA_prom/4-1,d2
***		PrA	<$1b,"H">

.t3		PrL	(a0)+
		PrS	crlf(pc)
		dbra	d2,.t3

***		PrA	<$1b,"H">
*		WaitKey
	ENDC	; MACAddDEBPRT

		cmp	#2,pbWordLen(sp)
		bne.b	.c21

* we have a NE2000 or clone, reorder image of PROM contents
		moveq	#15,d2
		lea	pbSA_prom(sp),a0
		move.l	a0,a1

.t31		move.b	(a0)+,(a1)+	; SA_prom[i]=SA_prom[i+i];
		addq.l	#1,a0
		dbra	d2,.t31

		move.b	#NESM_START_PG,lcl_tx_start_page(RprDVS)
		move.b	#NESM_STOP_PG,lcl_stop_page(RprDVS)
		bra.b	.c22

* we have a NE1000 or clone
.c21		move.b	#NE1SM_START_PG,lcl_tx_start_page(RprDVS)
		move.b	#NE1SM_STOP_PG,lcl_stop_page(RprDVS)


.c22		move.b	lcl_tx_start_page(RprDVS),lcl_rx_start_page(RprDVS)
		add.b	#TX_PAGES,lcl_rx_start_page(RprDVS)

* check this
		cmp.b	#$57,pbSA_prom+14(sp)
		seq	d0
		cmp.b	#$57,pbSA_prom+15(sp)
		seq	pbNEx000(sp)
		and.b	d0,pbNEx000(sp)
		beq.b	.c3

		lea	.m2(pc),a0
		bra.b	.c4

.c3		lea	.m3(pc),a0

.c4		move.l	a0,lcl_name(RprDVS)

		bsr	ethdev_init

* store devices ethernet MAC address in struct device
		lea	pbSA_prom(sp),a0		
		lea	dev_dev_addr(RprDVS),a1
		moveq	#ETHER_ADDR_LEN-1,d0

.t4		move.b	(a0)+,(a1)+
		dbra	d0,.t4

		moveq	#0,d0		; arg:
		bsr	NS8390_init

		moveq	#0,d0		; rc=OK
		

.quit		deselBUS			; deselect Bus interface
		unlockBUSWait			; relinquish Bus
.doNothing	deAlloc	pbNLcl			; pop local vars
		movem.l	(sp)+,Rpr		; restore regs
		rts


.m1		DC.B	"NE Reset Bit not set. Fatal",13,10,0
.m2		DC.B	"NE1000",0
.m3		DC.B	"No NE1000",0
		EVEN



******** ne_reset_8390 **********************************************************
* Hard reset the card.  This used to pause for the same period that a
* 8390 reset command required, but that shouldn't be necessary
*********************************************************************************

ne_reset_8390	
* DON'T change these to inb_p/outb_p or reset will fail on clones
		getBUS	NE_RESET,d1
		putBUS	d1,NE_RESET

		move.l	DVS+ticks2ms,d0		; wait 2ms
		moveq	#2,d1			; wait 5-10ms maximum (irrelevant here)
		bsr	ADelay

* This check _should_not_ be necessary, omit eventually
		getBUS	EN0_ISR,d1		; read isr
		and.b	#ENISR_RESET,d1		; test for reset bit
		bne.b	.c1

		PrS	.m1(pc)

.c1		putBUSi	ENISR_RESET,EN0_ISR	; ack interrupt

		rts


.m1		DC.B	"ne_reset_8390 failed",13,10,0
		EVEN



******** Initialised data *******************************************************

crlf		DC.B	13,10,0
		EVEN


******** data initialised to zero ***********************************************

		SECTION	BSS
DVS		DS.B	Ndevice		; allocate device structure

******** end of ne.s ************************************************************
