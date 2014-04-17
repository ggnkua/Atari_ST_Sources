packload	add.l	#12,a0		Update dest address
	bsr	interload		Load in file
	bsr	wait		Allow loading to start
	bsr	depack		Decompress it
	rts			Return
slowload	move.w	#$601C,packload	Use alternative subroutine
	rts			Return
packload2	add.l	#12,a0		Update dest address
	bsr	interload		Load in file
waitload	move.l	oldint,d0		Get old interrupt address
	cmp.l	$68,d0		Loaded in yet?
	bne	waitload		No, keep waiting
	bsr	depack		Decompress it
	rts			Return

wait	movem.l	d0-d3/a0-a2,-(sp)	Preserve registers
waitloop	move.w	#37,-(sp)		Wait vbl
	trap	#14		Call XBIOS
	addq.l	#2,sp		Correct stack
	dbf	d5,waitloop	Wait some more
	movem.l	(sp)+,d0-d3/a0-a2	Restore registers
	rts			Return

depack	LINK	A2,#-$1C
	LEA	(A0,D4.L),A5	End of buffer
	MOVE.L	D4,-(A7)		Store decompressed size
	LEA	-$C(A5),A4
	LEA	$80(A5),A5
	LEA	(A0,D3.L),A6	End of data
	MOVEQ	#0,D0
	MOVE.B	-(A6),D0		Data Request
	MOVE.W	D0,-2(A2)
	LSL.W	#2,D0
	SUBA.W	D0,A4
	LEA	packbuff(pc),A3
	MOVE.W	-2(A2),D0
	LSL.W	#2,D0
	ADDI.W	#$8C,D0
	BRA.S	label1

label2	MOVE.B	(A4)+,(A3)+
	SUBQ.W	#1,D0
label1	BNE.S	label2
	MOVEM.L	A3-A4,-(A7)
	PEA	(A5)
	MOVE.B	-(A6),D7		Data Request
	BRA	label3

label39	MOVE.W	D3,D5
label4	ADD.B	D7,D7
label12	DBCS	D5,label4
	BEQ.S	label5
	BCC.S	label9
	SUB.W	D3,D5
	NEG.W	D5
	BRA.S	label8

label9	MOVEQ	#3,D6
	BSR.S	bittest
	BEQ.S	label11
	BRA.S	label7

label11	MOVEQ	#7,D6
	BSR.S	bittest
	BEQ.S	label6
	ADDI.W	#$F,D5
	BRA.S	label7

label5	MOVE.B	-(A6),D7		Data Request
	ADDX.B	D7,D7
	BRA.S	label12

label6	MOVEQ	#$D,D6
	BSR.S	bittest
	ADDI.W	#$10E,D5
label7	ADD.W	D3,D5
label8	LEA	data(PC),A4
	MOVE.W	D5,D2
	BNE.S	label10
	ADD.B	D7,D7
	BNE.S	label14
	MOVE.B	-(A6),D7		Data Request
	ADDX.B	D7,D7
label14	BCS.S	label15
	MOVEQ	#1,D6
	BRA.S	label13

label15	MOVEQ	#3,D6
	BSR.S	bittest
	TST.B	-$1C(A2)
	BEQ.S	label16
	MOVE.B	-$12(A2,D5.W),-(A5)
	BRA	label17

label16	MOVE.B	(A5),D0
	BTST	#3,D5
	BNE.S	label18
	BRA.S	label19

label18	ADDI.B	#$F0,D5
label19	SUB.B	D5,D0
	MOVE.B	D0,-(A5)
	BRA	label17

bittest	CLR.W	D5
bittest3	ADD.B	D7,D7
	BEQ.S	bittest2
bittest2r	ADDX.W	D5,D5
	DBF	D6,bittest3
	TST.W	D5
	RTS
bittest2	MOVE.B	-(A6),D7		Data request
	ADDX.B	D7,D7
	BRA.S	bittest2r

label10	MOVEQ	#2,D6
label13	BSR.S	bittest
	MOVE.W	D5,D4
	MOVE.B	$E(A4,D4.W),D6
	EXT.W	D6
	TST.B	-$1B(A2)
	BNE.S	label20
	ADDQ.W	#4,D6
	BRA.S	label21

label20	BSR.S	bittest
	MOVE.W	D5,D1
	LSL.W	#4,D1
	MOVEQ	#2,D6
	BSR.S	bittest
	CMP.B	#7,D5
	BLT.S	label22
	MOVEQ	#0,D6
	BSR.S	bittest
	BEQ.S	label23
	MOVEQ	#2,D6
	BSR.S	bittest
	ADD.W	D5,D5
	OR.W	D1,D5
	BRA.S	label24

label23	OR.B	-$1A(A2),D1
	BRA.S	label25

label22	OR.B	-$19(A2,D5.W),D1
label25	MOVE.W	D1,D5
	BRA.S	label24

label21	BSR.S	bittest
label24	ADD.W	D4,D4
	BEQ.S	label26
	ADD.W	-2(A4,D4.W),D5
label26	LEA	1(A5,D5.W),A4
	MOVE.B	-(A4),-(A5)
label27	MOVE.B	-(A4),-(A5)
	DBF	D2,label27
	BRA.S	label17

label31	ADD.B	D7,D7
	BNE.S	label28
	MOVE.B	-(A6),D7		Data Request
	ADDX.B	D7,D7
label28	BCS.S	label29
	MOVE.B	-(A6),-(A5)	Data Request
label17	CMPA.L	A5,A3
	BNE.S	label31
	CMPA.L	A6,A0		End of decompression check
	BEQ.S	label30
label3	MOVEQ	#0,D6
	BSR	bittest
	BEQ.S	label32
	MOVE.B	-(A6),D0		Data Request
	LEA	-$1A(A2),A1
	MOVE.B	D0,(A1)+
	MOVEQ	#1,D1
	MOVEQ	#6,D2
label34	CMP.B	D0,D1
	BNE.S	label33
	ADDQ.W	#2,D1
label33	MOVE.B	D1,(A1)+
	ADDQ.W	#2,D1
	DBF	D2,label34
	ST	-$1B(A2)
	BRA.S	label35

label32	SF	-$1B(A2)
label35	MOVEQ	#0,D6
	BSR	bittest
	BEQ.S	label36
	LEA	-$12(A2),A1
	MOVEQ	#$F,D0
label37	MOVE.B	-(A6),(A1)+	Data Request
	DBF	D0,label37
	ST	-$1C(A2)
	BRA.S	label38

label36	SF	-$1C(A2)
label38	CLR.W	D3
	MOVE.B	-(A6),D3		Data Request
	MOVE.B	-(A6),D0		Data Request
	LSL.W	#8,D0
	MOVE.B	-(A6),D0		Data Request
	MOVEA.L	A5,A3
	SUBA.W	D0,A3
	BRA.S	label31

label29	BRA	label39

	*Relocate data

label30	MOVEA.L	(A7)+,A0
	PEA	(A2)
	BSR.S	labelx
	MOVEA.L	(A7)+,A2
	MOVEM.L	(A7)+,A3-A4
	MOVE.L	(A7)+,D0
	BSR	relocate
	MOVE.W	-2(A2),D0
	LSL.W	#2,D0
	ADDI.W	#$8C,D0
	BRA.S	label41
label42	MOVE.B	-(A3),-(A4)
	SUBQ.W	#1,D0
label41	BNE.S	label42
	UNLK	A2
pend	RTS

data	dc.w	$20,$60,$160,$360,$760,$f60,$1f60
	dc.w	$1,$304,$506,$708

labelx	MOVE.W	-2(a2),d7
label47	DBF	D7,label49
	RTS

label49	MOVE.L	-(A0),D0
	LEA	0(A5,D0.L),A1
	LEA	$7D00(A1),A2
label46	MOVEQ	#3,D6
label44	MOVE.W	(A1)+,D0
	MOVEQ	#3,D5
label43	ADD.W	D0,D0
	ADDX.W	D1,D1
	ADD.W	D0,D0
	ADDX.W	D2,D2
	ADD.W	D0,D0
	ADDX.W	D3,D3
	ADD.W	D0,D0
	ADDX.W	D4,D4
	DBF	D5,label43
	DBF	D6,label44
	MOVEM.W	D1-D4,-8(A1)
	CMPA.L	A1,A2
	BNE.S	label46
	BRA.S	label47

relocate	LSR.L	#4,D0
	LEA	-$C(A6),A6
relocate2	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	DBF	D0,relocate2
	RTS

	********************************
	* C&D Games Fast Disk Routines *
	*       Interrupt driven       *
	*      d0 = starting side      *
	*      d1 = starting track     *
	*      d2 = starting sector    *
	*      d3 = length of file     *
	*      a0 = dest address       *
	********************************

dmamode	equ	$ff8606
dmadat	equ	$ff8604
dmahigh	equ	$ff8609
dmamid	equ	$ff860b
dmalow	equ	$ff860d
mfp	equ	$fffa01
flselec	equ	$ff8800
flwrite	equ	$ff8802
flock	equ	$43e

interload	movem.l	a0/d7,-(sp)	Preserve registers
	move.w	d0,side		Starting side
	move.w	d1,track		Starting track
	move.w	d2,sector		Starting sector
	move.l	d3,size		Size of file
	add.l	d3,a0		Find end address
	move.l	a0,destadr	Destination address
	bsr	loadfix		Dummy sector load
	bsr	initfdc		Initialise routines
	bsr	getside		Move to side
	bsr	gettrack		Move to track
	move.l	$68,oldint	Address of previous routine
	move.l	#loaddata2,$68	Address of interrupt routine
	movem.l	(sp)+,a0/d7	Restore registers
	move.w	#$2000,sr		Enable interrupts
	rts			Return

loaddata	btst	#5,mfp		Finished loading yet?
	bne	preturn		No, return
	move.l	#loaddata2,$68	Switch to other routine
	movem.l	d3/d7/a0-a1,-(sp)	Preserve registers
	bsr	copybuff		Copy data out of buffer
	bsr	getside		Move to side
	bsr	gettrack		Move to track
	movem.l	(sp)+,d3/d7/a0-a1	Restore registers
preturn	rte			Return

loaddata2	btst	#5,mfp		Read to load yet?
	bne	preturn		No, return
	move.l	d7,-(sp)		Preserve registers
	bsr	setbuff		Address of buffer
	bsr	readsect		Read in sector
	move.l	(sp)+,d7		Restore registers
	move.l	#loaddata,$68	Switch to other routine
	add.w	#1,sector		Move to next sector
	cmp.w	#10,sector	Next track yet?
	bne	preturn		No, return
	move.w	#1,sector		Back to sector 1
	add.w	#1,track		Move up track counter
	cmp.w	#80,track		Next side yet?
	bne	preturn		No, return
	move.w	#0,track		Move back to track 0
	move.w	#1,side		Move to side 1
	rte			Return

copybuff	move.l	size,d3		Get size remaining
	move.l	destadr,a0	Get destination address
	lea	buffer,a1		Address of buffer
	cmp.l	#513,d3		Less than 513 bytes remaining?
	blt	endload		Yes, end load sequence
	move.w	#31,d7		Set up a counter
buffcopy	rept	16
	move.b	(a1)+,-(a0)	Copy data out of buffer
	endr
	dbf	d7,buffcopy	Copy some more data
	sub.l	#512,size		Decrease amount to load
	sub.l	#512,destadr	Move up destination address
	rts			Return

endload	sub.w	#1,d3		Number of bytes remaining
buffcopy2	move.b	(a1)+,-(a0)	Copy data out of buffer
	dbf	d3,buffcopy2	Copy some more
	sf	flock		Enable floppy interrupt
	move.l	oldint,$68	Disable interrupts
	rts			Return

loadfix	bsr	initfdc		Initialise routines
	bsr	setbuff		Address of buffer
	bsr	getside		Move to side
	bsr	gettrack		Move to track
wait1	btst	#5,mfp		Read yet
	bne	wait1		No, wait a bit
	bsr	readsect		Read in sector
wait2	btst	#5,mfp		Read yet
	bne	wait2		No, wait a bit
	sf	flock		Enable floppy interrupt
	rts			Return

initfdc	st	flock		Disable floppy interrupt
	move.b	#$e,flselec	Select port A	
	move.b	#5,flwrite	Activate drive
	move.w	#$80,dmamode	Access FDC register
	move.w	#$d0,dmadat	Reset command
	move.l	#80,d7		Set up a delay
delay	dbf	d7,delay		Wait for reset
	rts			Return

getside	tst.w	side		Side 0
	bne	side1		No, side 1
side0	move.b	#$e,flselec	Select port A
	move.b	#5,flwrite	Select side 0
	rts			Return
side1	move.b	#$e,flselec	Select port A
	move.b	#4,flwrite	Select side 0
	rts			Return

gettrack	move.w	#$86,dmamode	Access track register
	move.w	track,d7		New track
	move.w	d7,dmadat		Send command
	move.w	#$80,dmamode	Select FDC register
	move.w	#$1b,dmadat	Seek track command
	rts			Return

readsect	move.w	#$90,dmamode	Sector count register
	move.w	#1,dmadat		Read 1 sector
	move.w	#$84,dmamode	Select sector register
	move.w	sector,d7		New sector
	move.w	d7,dmadat		Send command
	move.w	#$80,dmamode	Select FDC register
	move.w	#$80,dmadat	Read sector command
	rts			Return

setbuff	move.l	#buffer,d7	Address of buffer
	move.b	d7,dmalow		Set low byte
	lsr.l	#8,d7
	move.b	d7,dmamid		Set mid byte
	lsr.l	#8,d7
	move.b	d7,dmahigh	Set high byte
	rts			Return

side	dc.w	0		Side to read
track	dc.w	0		Track to read
sector	dc.w	0		Sector to read
size	dc.l	0		Size of file
destadr	dc.l	0		Destination address
oldint	dc.l	0		Old interrupt routine
buffer	ds.b	512		Space to load in sector
packbuff	ds.b	284		Depack buffer