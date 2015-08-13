*********************************************************************************
*										*
*	Low level part of STiNG port NEx000 driver for my ACSI-ISA interface	*
* 	and the Cartridge Port interface developed by Lyndon Amsdon and me.	*
*	Copyright 2001-2002 Dr. Thomas Redelberger				*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Features:									*
*	Packets are read/written directly from NEx000 to STinG datagram without	*
*	further (double) buffering and memcpy					*
* Limitations:									*
*	Gross transfer rate for rx/tx is about 300KByte/sec but with aFTP 1.41	*
*	you end up with about 50KByte/sec overall for rx/tx to/from a RAM disk	*
*	on an 8 MHz ST								*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on parts	*
* of the ethernet driver from STing's "father" Dr. Peter Rottengatter		*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: nestng.s 1.2 2002/06/08 16:12:22 Thomas Exp Thomas $
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

* references into ne.s
		XREF	DVS		; access to device structure in BSS in NE.S

* references into enestng.c
		XREF	tpl		; in ENESTNG.C, accessed from rtrvStngDgram
***		XREF	stx		; "
		XREF	my_port		; "
* entry point defined in enestng.c
		XREF	process_arp	; (); in ENESTNG.C, called from rtrvPckt when an ARP packet was received

*
* system variables
*

*
* includes
*

		INCLUDE	UTI.I		; debugging and stack handling macros
		INCLUDE	BUS.I		; ACSI or Cartridge Port hardware macros
		INCLUDE	8390.I		; Symbols for 8390 chip registers



		SECTION	TEXT

*********************************************************************************
* The following interfacing code, rtrvStngDgram, was taken from function 
* retrieve_dgram of Peter's ethernea.c, converted to assembler and optimized.
* It links STinG specifics with NEx000 hardware specifics.
* Therefore it references the external IP packet representation as well as STinGs
* internal IP packet represention.
* It accesses the transport layer (tpl)
*** as well as the port layer (stx).
*
* Although this is an ugly design it is necessary to do away with packet double
* buffering and instead copy directly from the NE memory to the STinG dgram
*********************************************************************************

*
* function pointer offsets in  tpl  and  stx  and  my_port. Because we
* use only a few functions full blown structure declaration is not 
* warranted
*
tpKRmalloc	EQU	$0c
tpKRfree	EQU	$10

***sxSet_dgram_ttl	EQU	$0c	; unused
***sxIP_discard	EQU	$2c		; unused

ptStat_rcv_data	EQU	$20
ptReceive	EQU	$24
ptStat_dropped	EQU	$28

*
*
* IP packet header
*
		RSRESET
ipVersionHd_len	RS.B	1		; 4-7: IP Version, 0-3: Internet Header Length
ipTos		RS.B	1		; Type of Service
ipLength	RS.W	1		; Total of all header, options and data
ipIdent		RS.W	1		; Identification for fragmentation
ipFragments	RS.W	1		; 15: Reserved : Must be zero
					; 14: Don't fragment flag
					; 13: More fragments flag
					; 0-12: Fragment offset
ipTtl		RS.B	1		; Time to live
ipProtocol	RS.B	1		; Protocol
ipHdr_chksum	RS.W	1		; Header checksum
ipIp_src	RS.L	1		; Source IP address
ipIp_dest	RS.L	1		; Destination IP address
ipHdrLen	EQU	__RS



*
* STinG/STik Internal IP packet representation
*
		RSRESET
sgIpHdr		RS.B	ipHdrLen	; Header of IP packet
sgOptions	RS.L	1		; Options data block
sgOpt_length	RS.W	1		; Length of options data block
sgPkt_data	RS.L	1		; IP packet data block
sgPkt_length	RS.W	1		; Length of IP packet data block
sgTimeout	RS.L	1		; Timeout of packet life
sgIp_gateway	RS.L	1		; Gateway for forwarding this packet
sgRecvd		RS.L	1		; Receiving port
sgNext		RS.L	1		; Next IP packet in IP packet queue
sgIp_DgramLen	EQU	__RS




******** rtrvStngDgrm ***********************************************************
* This function is called only (statically) once from rtrvPckt it does 
* special parameter passing different from Turbo-C/Pure-C or cdecl:
*
* in
*	RrxPktLen:	(d2) length of raw ethernet packet incl. ethernet CRC
*
* out
*	d0.l:	 0=OK
*		-2=Error: cannot allocate IP header
*		-3=Error: frame, IP packet lenght inconsistent
*		-4=Error: cannot allocate options
*		-5=Error: cannot allocate IP pkt data block
*		for all errors the packet just gets dropped
*
*	STinG statistics get updated
*	dev_* statistics do not get updated because dev_* is opaque to this module
*
* changed
*	d0-d1
*	we do save d2-d3 because ei_receive uses them
*	a0-a3	we do not need to save any of them because ei_interrupt does save all
*	we do not/must not use d6,d7,a5,a6 (getMore)
*********************************************************************************

RrxPktLen	EQUR	d2			; must be defined already here
RrxPushed	EQU	4			; bytes pushed on stack (d2,d3)


rtrvStngDgram	move	d3,-(a7)		; save used reg.
		move	RrxPktLen,-(a7)		; save used reg.
		move.l	tpl,a3			; access to transport layer functions

		pea	sgIp_DgramLen\w		; arg1: a long!
		movea.l	tpKRmalloc(a3),a0	; allocate mem for IP header
		jsr	(a0)
		addq.w	#4,a7			; pop arg1

		movea.l	d0,a2			; address of header
		tst.l	d0
		beq	.err1			; KRmalloc failed?

		movea.l	a2,a0
		REPT	20			; ipHdrLen
		getMore	NE_DATAPORT,d0
		move.b	d0,(a0)+		; get IP header
		ENDR

* check consistency of IP header
		move	(a7),d0			; saved RrxPktLen
		cmp.w	ipLength(a2),d0
		bcs	.err2			; error if IP length > raw packet

		move.b	ipVersionHd_len(a2),d3
		and.w	#$000f,d3		; left with Hd_len (is in longs)
		lsl.w	#2,d3			; to bytes
		cmp.w	#ipHdrLen,d3
		bcs	.err2			; error if smaller than minimum header

		cmp.w	(a7),d3
		bcc	.err2			; error if eq or larger than total raw packet

		moveq.l	#0,d0			; unsigned extend
		move.l	d0,sgOptions(a2)	; preset NULL pointer to options data
		move.w	d3,d0			; hd_len in bytes
		sub.w	#ipHdrLen,d0		; -IP Header length
		move.w	d0,sgOpt_length(a2)	; = options length in bytes
		beq.b	.c1			; that is it for no options
* above		ext.l	d0
		move.l	d0,-(a7)		; arg: length
		movea.l	tpKRmalloc(a3),a0	; allocate mem for options
		jsr	(a0)
		addq.w	#4,a7			; pop arg
		move.l	d0,sgOptions(a2)	; attach options data block
		beq	.err3			; KRmalloc failed?

		movea.l	d0,a0			; ^options data
		move.w	sgOpt_length(a2),d1	; options length in bytes
		lsr.w	#2,d1			; length in longs
		bra.b	.b1

.t1		REPT	4
		getMore	NE_DATAPORT,d0
		move.b	d0,(a0)+		; get IP options
		ENDR
.b1		dbra	d1,.t1

.c1		move.w	ipLength(a2),d0
		sub.w	d3,d0			; length-hd_len
		move.w	d0,sgPkt_length(a2)	; this may be add!
		addq.w	#1,d0			; round up to even
		and.w	#$fffe,d0
		ext.l	d0
		move.l	d0,-(a7)		; arg: length in bytes
		movea.l	tpKRmalloc(a3),a0	; allocate mem for data
		jsr	(a0)
		addq.w	#4,a7			; pop arg
		move.l	d0,sgPkt_data(a2)	; attach pkt data block
		beq	.err4			; KRmalloc failed?

		movea.l	d0,a0			; ^pkt_data
		move.w	sgPkt_length(a2),d1	; pkt_length in bytes
* if Pkt_length is odd we have allocated one more byte and we extract one more byte
		addq.w	#1,d1			; round up to even
		and.w	#$fffe,d1

		NE2RAM	a0,d1			; get IP data

		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUSi	ENISR_RDC,EN0_ISR	; reset remote DMA ready bit

		lea	my_port,a3
		move.l	a3,sgRecvd(a2)		; recvd = &my_port
		moveq	#0,d0
		move.l	d0,sgNext(a2)		; nothing hanging
*** really necessary at this layer?
***		move.l	a2,-(a7)		; arg ^dgram
***		movea.l	stx,a0
***		movea.l	sxSet_dgram_ttl(a0),a0
***		jsr	(a0)
***		addq.w	#4,a7			; pop arg

* append new dgram at the end of the dgram queue hanging from my_port.receive
		lea	ptReceive(a3),a0	; address of pointer to first dgram in queue
		bra.b	.b4

.t4		move.l	d0,a0
		lea	sgNext(a0),a0		; address of pointer to next dgram in queue
.b4		move.l	(a0),d0			; first dgram hanging and then next dgram in queue
		bne.b	.t4			; branch if not last one

		move.l	a2,(a0)			; attach the new dgram

		move	(a7)+,RrxPktLen		; restore used reg.
		ext.l	RrxPktLen
		add.l	RrxPktLen,ptStat_rcv_data(a3)	; update STinGs statistics
		moveq	#0,d3			; rc=OK

.quit		move.l	d3,d0			; establish return code
		move	(a7)+,d3		; restore used reg.
		rts


.err1		moveq	#-2,d3			; rc=Error: cannot allocate IP header
.stat		move	(a7)+,RrxPktLen		; restore used reg.
		addq.w	#1,my_port+ptStat_dropped	; update STinG  statistics
		bra.b	.quit

.err2		moveq	#-3,d3			; rc=Error: frame, IP packet lenght inconsistent
.freeIPh	move.l	a2,-(a7)		; arg: free IP header again
		movea.l	tpKRfree(a3),a0
		jsr	(a0)
		addq.w	#4,a7			; pop arg
		bra.b	.stat

.err3		moveq	#-4,d3			; rc=Error: cannot allocate options
		bra.b	.freeIPh

.err4		moveq	#-5,d3			; rc=Error: cannot allocate IP pkt data block
		move.l	sgOptions,d0		; have options been present?
		beq.b	.freeIPh		; no, go free IP header
		move.l	d0,-(a7)		; arg: free options again
		movea.l	tpKRfree(a3),a0
		jsr	(a0)
		addq.w	#4,a7			; pop arg
		bra.b	.freeIPh


******** declarations for ethernet **********************************************
N8390Hdr	EQU	4		; the 8390 chip storesa 4 byte header preceeeding the packet
NCRC		EQU	4		; 4 trailing CRC of a ethernet packet

		RSRESET
EthDst		RS.B	6		; Ethernet destination address (unused)
EthSrc		RS.B	6		; Ethernet source address (unused)
EthType		RS.W	1		; Ethernet packet type
EthCTypeIP		EQU	$0800		; packet type IP
EthCTypeARP		EQU	$0806		; packet type ARP
EthCtypeRARP		EQU	$8035		; packet type reverse ARP (unused)
EthCTypeIPARPHi		EQU	$08		; Hi byte for both IP and ARP
EthCTypeIPLo		EQU	$00		; Lo byte IP
EthCTypeARPLo		EQU	$06		; Lo byte ARP
EthN		EQU	__RS
NArpPkt		EQU	64-EthN		; length of Arp packet without ethernet header
					; but with padding and ethernet CRC



******** rtrvPckt ***************************************************************
* This function is called only (statically) once from ei_receive in NE.S; it does 
* special parameter passing different from Turbo-C/Pure-C or cdecl:
*
*
* This function effects to get the packet out of the NEx000 card into the ST RAM
* The code is ugly as we need to discern ARP and IP on the fly because
* we want to extract the packet without double buffering
*
* in:	RrxJnk8990	(d1) Junk 8390 header occured from 8990 chip (only IFD BUGGY_HW)
*	RrxPktLen	(d2) The raw ethernet packet length (declared already above)
*	RrxReadPg	(d4) Page where the packet starts
*
* out:
*	d0.l:	  0=OK
*		Errors:
*		 -1=cannot allocate IP header
*		 -2=frame, IP packet lenght inconsistent
*		 -3=cannot allocate options
*		 -4=cannot allocate IP pkt data block
*		-10=junk Ethernet *type* word
*		-11=bogus ARP packet
*		plus process_arp return codes
*
*		for all errors the packet just gets dropped
*
*	STinG statistics get updated
*	dev_* statistics do not get updated because dev_* is opaque to this module
*
*
* changed:
*	d0-d1
*	registers d2-d5,RxBUS,RyBUS,RcBUS,RdBUS are not changed
*

	IFD	BUGGY_HW
RrxJnk8990	EQUR	d1
	ENDC
RrxReadPg	EQUR	d4
	
rtrvPckt
	IFGE	RXDEBPRT-999
		PrW	RrxPktLen
		PrA	<" RrxPktLen",13,10>
	ENDC
* we do not need the two leading ethernet MAC addresses (12 bytes) and the trailing 4 CRC bytes
* thus we adjust the # of bytes to read
		move	RrxPktLen,d0
		sub	#EthType+NCRC,d0		; enet dst & src (12) bytes + 4 CRC less
		putBUS	d0,EN0_RCNTLO
		lsr.w	#8,d0
		putBUS	d0,EN0_RCNTHI
* hence we skip the 8390 header and the 2 MAC addreses
		putBUSi	N8390Hdr+EthType,EN0_RSARLO	; skip 8390 header (4) + enet dst & src (12)
		putBUS	RrxReadPg,EN0_RSARHI
* thus we start remote DMA read command starting at the 2 ethernet type bytes
		putBUSi	E8390_RREAD+E8390_START,E8390_CMD

	IFD	BUGGY_HW
* note that the data is shifted by one byte in case of a junk header, we need to do one more read
		tst.b	RrxJnk8990
		beq.b	.c1
		getBUS	NE_DATAPORT,d0			; dummy read

.c1
	ENDC
		getBUS	NE_DATAPORT,d0			; get type hi byte
		cmp.b	#EthCTypeIPARPHi,d0
		bne	.err
		getMore	NE_DATAPORT,d0			; get type lo byte
		cmp.b	#EthCTypeIPLo,d0		; IP packet?
		beq	.IP
		cmp.b	#EthCTypeARPLo,d0		; ARP packet?
		beq	.ARP				; if not it is an error


.err		moveq.l	#-10,d0				; fall thru

.err1
	IFGE	RXDEBPRT-1
		PrA	<"rc ">
		PrL	d0
		PrA	<" ">
		getBUS	NE_DATAPORT,d1
		PrB	d1
		PrA	<" ">
		getBUS	NE_DATAPORT,d1
		PrB	d1
		PrA	<" ">
		getBUS	NE_DATAPORT,d1
		PrB	d1
		PrA	<13,10>
	ENDC
		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; abort remote DMA
		getBUS	NE_DATAPORT,d1			; only this makes for a proper abort !!!
		putBUSi	ENISR_RDC,EN0_ISR		; reset remote DMA ready bit
		bra	.exit


.ARP		moveq	#-11,d0				; preset error rc
		move	RrxPktLen,d1			; raw ethernet packet length
		sub	#EthN+NCRC,d1			; ethernet header + 4 CRC less
		cmp	#NArpPkt,d1			; must fit in buffer
		bhi	.err1
		lea	ArpPktBuff,a0			; destination
		NE2RAM	a0,d1				; both regs get destroyed!
		putBUSi	E8390_NODMA+E8390_START,E8390_CMD	; complete remote DMA
		putBUSi	ENISR_RDC,EN0_ISR		; reset remote DMA ready bit
		lea	ArpPktBuff,a0			; arg1:
		move	RrxPktLen,d0			; arg2:
		jsr	process_arp
		bra.b	.exit


.IP		bsr	rtrvStngDgram			; implied arg1: RrxPktLen	
		tst.l	d0
		bne	.err1				; Nachkarten
*		bra.b	.exit				; fall thru to exit


.exit		rts



******** data initialised to zero ***********************************************


		SECTION	BSS

ArpPktBuff	DS.B	NArpPkt

******** end of nestng.s ********************************************************
