***------------------------------------------------------------------------
*** This is the ultimate Data-Decrunch-Routine
*** for Crunch-Mania V1.4
*** (c) 1991 by FRESH THRASH of CERBERUS, all rights reserved
*** You may use this piece of code as long as you don't claim that
*** you have written it. In any case the author (me) has to be
*** mentioned someplace in your proggy.
*** Note: Source- and Destinationaddresses have to be always even Addresses
***------------------------------------------------------------------------
*** Here is the Format of the Header:
*** Type  Offset  Contents                   Function
*** LONG  0       "CrM!"                     to recongnize crunched files
*** WORD  4       Minimum Security Distance  to savely decrunch data when
***					     Source and Dest is in the same
***					     Memoryblock
*** LONG  6       Original Len               Datalen before packing
*** LONG  10 ($a) Crunched Len               Datalen after packing without
***					     Header
***------------------------------------------------------------------------
** Jump here to decrunch some data with overlap check
** You need some Memory directly in front of the Destination Area
** which has to be as large as the MinSecDist
** Load the Regs with:
** a0: Adr of Source (with Header)	** a1: Adr of Dest
**---------------------------------------------------------------
	opt	p+

OverlapDecrunch:
	movem.l	d0-d7/a0-a6,-(sp)
	cmp.l	#"CrM!",(a0)+
	bne.s	.NotCrunched
	moveq	#0,d0
	move.w	(a0)+,d0	;MinSecDist
	move.l	(a0)+,d1	;DestLen
	move.l	(a0)+,d2	;SrcLen
	lea	0(a0,d0.l),a2
	cmp.l	a1,a2
	ble.s	.NoCopy
	move.l	a0,a2
	move.l	a1,a0
	sub.l	d0,a0		;MinSecDist abziehen
	move.l	a0,a3
	move.l	d2,d7
	lsr.l	#2,d7		;Longs
.CopyLoop:
	move.l	(a2)+,(a3)+
	subq.l	#1,d7
	bne.s	.CopyLoop
	move.l	(a2)+,(a3)+	;in case of ...
.NoCopy:
	move.l	a0,a2
	bsr.s	FastDecruncher
.NotCrunched:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
**-----------------------------------------------------------
** Jump here to decrunch some data without any overlap checks
** The Regs have to loaded with:
** a0: Adr of Source (with Header)
** a1: Adr of Dest
**-----------------------------------------------------------
NormalDecrunch:
	movem.l	d0-d7/a0-a6,-(sp)
	cmp.l	#"CrM!",(a0)+
	bne.s	.NotCrunched
	tst.w	(a0)+		;skip MinSecDist
	move.l	(a0)+,d1	;OrgLen
	move.l	(a0)+,d2	;CrLen
	move.l	a0,a2
	bsr.s	FastDecruncher
.NotCrunched:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
**-------------------------------------------------------------------
** This is the pure Decrunch-Routine
** The Registers have to be loaded with the following values:
** a1: Adr of Destination (normal)	** a2: Adr of Source (packed)
** d1: Len of Destination		** d2: Len of Source
**-------------------------------------------------------------------
FastDecruncher:
	move.l	a1,a5			;Decrunched Anfang (hier Ende des Decrunchens)
	add.l	d1,a1
	add.l	d2,a2
	move.w	-(a2),d0		;Anz Bits in letztem Wort
	move.l	-(a2),d6		;1.LW
	moveq	#16,d7			;Anz Bits
	sub.w	d0,d7			;Anz Bits, die rotiert werden müssen
	lsr.l	d7,d6			;1.Bits an Anfang bringen
	move.w	d0,d7			;Anz Bits, die noch im Wort sind
	moveq	#16,d3
	moveq	#0,d4
.DecrLoop:
	cmp.l	a5,a1
	ble	.DecrEnd			;a1=a5: fertig (a1<a5: eigentlich Fehler)
	bsr	.BitTest
	bcc.s	.InsertSeq		;1.Bit 0: Sequenz
	moveq	#0,d4
** einzelne Bytes einfügen **
.InsertBytes:
	moveq	#8,d1
	bsr.w	.GetBits
	move.b	d0,-(a1)
	dbf	d4,.InsertBytes
	bra.s	.DecrLoop
*------------
.SpecialInsert:
	moveq	#14,d4
	moveq	#5,d1
	bsr.s	.BitTest
	bcs.s	.IB1
	moveq	#14,d1
.IB1:	bsr.s	.GetBits
	add.w	d0,d4
	bra.s	.InsertBytes
*------------
.InsertSeq:
** Anzahl der gleichen Bits holen **
	bsr.s	.BitTest
	bcs.s	.AB1
	moveq	#1,d1			;Maske: 0 (1 AB)
	moveq	#1,d4			;normal: Summe 1
	bra.s	.ABGet
.AB1:
	bsr.s	.BitTest
	bcs.s	.AB2
	moveq	#2,d1			;Maske: 01 (2 ABs)
	moveq	#3,d4			;ab hier: Summe mindestens 3
	bra.s	.ABGet
.AB2:
	bsr.s	.BitTest
	bcs.s	.AB3
	moveq	#4,d1			;Maske: 011 (4 ABs)
	moveq	#7,d4			;hier: Summe 11
	bra.s	.ABGet
.AB3:
	moveq	#8,d1			;Maske: 111 (8 ABs)
	moveq	#$17,d4			;hier: Summe 11
.ABGet:
	bsr.s	.GetBits
	add.w	d0,d4			;d0: Länge der Sequenz - 1
	cmp.w	#22,d4
	beq.s	.SpecialInsert
	blt.s	.Cont
	subq.w	#1,d4
.Cont:
** SequenzAnbstand holen **
	bsr.s	.BitTest
	bcs.s	.DB1
	moveq	#9,d1			;Maske: 0 (9 DBs)
	moveq	#$20,d2
	bra.s	.DBGet
.DB1:
	bsr.s	.BitTest
	bcs.s	.DB2
	moveq	#5,d1			;Maske: 01 (5 DBs)
	moveq	#0,d2
	bra.s	.DBGet
.DB2:
	moveq	#14,d1			;Maske: 11 (12 DBs)
	move.w	#$220,d2
.DBGet:
	bsr.s	.GetBits
	add.w	d2,d0
	lea	0(a1,d0.w),a3		;a3 auf Anf zu kopierender Seq setzten
.InsSeqLoop:
	move.b	-(a3),-(a1)		;Byte kopieren
	move.b	(a1),$ffff8240.w	; flash colours
	dbf	d4,.InsSeqLoop

	bra.w	.DecrLoop
*------------
.BitTest:
	subq.w	#1,d7
	bne.s	.BTNoLoop
	moveq	#16,d7			;hier kein add notwendig: d7 vorher 0
	move.w	d6,d0
	lsr.l	#1,d6			;Bit rausschieben und Flags setzen
	swap	d6			;ror.l	#16,d6
	move.w	-(a2),d6		;nächstes Wort holen
	swap	d6			;rol.l	#16,d6
	lsr.w	#1,d0			;Bit rausschieben und Flags setzen
	rts
.BTNoLoop:
	lsr.l	#1,d6			;Bit rausschieben und Flags setzen
	rts
*----------
.GetBits:				;d1:AnzBits->d0:Bits
	move.w	d6,d0			;d6:Akt Wort
	lsr.l	d1,d6			;nächste Bits nach vorne bringen
	sub.w	d1,d7			;d7:Anz Bits, die noch im Wort sind
	bgt.s	.GBNoLoop
;	add.w	#16,d7			;BitCounter korrigieren
	add.w	d3,d7			;BitCounter korrigieren
	ror.l	d7,d6			;restliche Bits re rausschieben
	move.w	-(a2),d6		;nächstes Wort holen
	rol.l	d7,d6			;und zurückrotieren
.GBNoLoop:
	add.w	d1,d1			;*2 (in Tab sind Ws)
	and.w	.AndData-2(pc,d1.w),d0	;unerwünschte Bits rausschmeißen
	rts
*----------
.AndData:
	dc.w	%1,%11,%111,%1111,%11111,%111111,%1111111
	dc.w	%11111111,%111111111,%1111111111
	dc.w	%11111111111,%111111111111
	dc.w	%1111111111111,%11111111111111
*-----------
.DecrEnd:
	rts		;a5: Start of decrunched Data
