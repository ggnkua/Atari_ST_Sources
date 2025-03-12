** MY COMPACTION ROUTINES

	bra progbit

***********************************************
sourcename
	dc.b "E:\PACKERS\TUFTY.SET",0
destname
	dc.b "E:\PACKERS\TUFTYB.SET",0
	even

sourcebase	dc.l 0
destbase	dc.l 0

sourcelen	dc.l 0
destlen		dc.l 0

bytestogo	dc.l 0

cbestoffset	dc.w 0
cbestcoplen	dc.w 0

piccompdoneflag	dc.w 0
scanlength	dc.l 0
illextflag	dc.l 0

delcount	dc.w 0

***********************************************
keyvbi	subq #1,delcount
	bcc xkvbi
	move #255,delcount

	moveq #13,D0		print carriage return
	bsr printchar
	move.l bytestogo,D0	print bytes to go
	bsr printdeclong

xkvbi	rts

***********************************************
** PROGRAM INITIALIZATION

progbit	bsr gosuper
;	move.b #3,$FFFFFC04.w		disable midi (master reset)
;	bsr mouseoff			disable mouse

	move.l #thing,D0
	move.l D0,destbase		dest base 1200 bytes
	add.l #$4B0,D0			lower than source base
	move.l D0,sourcebase

	lea sourcename,A0		load source file
	move.l sourcebase,A1
	move.l #$1000000,D0		16 meg load
	bsr loadfile
	tst.l iostatus
	bmi exitprog

	move.l iostatus,D0
	move.l D0,sourcelen		initial length
	move.l D0,bytestogo

	bsr printdeclong
	moveq #13,D0			print carriage return
	bsr printchar
	moveq #10,D0			print line feed
	bsr printchar

***********************************************
	move.l #keyvbi,$4D6.w		vbi on

;	bsr convertit

	move #0,piccompdoneflag		(picture compression flag)
	bsr compactit

	move.l #0,$4D6.w		vbi off

	lea destname,A0
	move.l destbase,A1
	move.l destlen,D0
	bsr savefile

***********************************************
exitprog
;	bsr mouseon
;	move.b #$95,$FFFFFC04.w		enable midi again
	bsr gouser

	clr -(sp)			exit program
	trap #1

*****************************************************************
compactit
	CLR.W	illextflag
	MOVE.L	#$1528,scanlength

	MOVEA.L	sourcebase(PC),A0	source base
	MOVE.L	sourcelen(PC),D0	length of source
	MOVEA.L	destbase(PC),A1		dest base
	LEA	0(A0,D0.L),A2		very end pointer

	MOVE.L	#$49636521,D7		write "Ice!"
	BSR	write4bytes

	ADDQ.L	#4,A1			leave a blank long
	MOVE.L	sourcelen(PC),D7	write uncompacted length
	BSR	write4bytes

	MOVEQ	#0,D5			zero extraction counter
	MOVEQ	#$1F,D6			init "bits left in D7"
	MOVEQ	#0,D7			clear bit buffer
	MOVEQ	#0,D4			write one bit
	MOVE.W	piccompdoneflag(PC),D1	(picture compression flag)
	BSR	writebits

***********
cmpl0	MOVEA.L	A0,A3			get end of scan pointer
	ADDA.L	scanlength(PC),A3
	CMPA.L	A2,A3			truncate to source end if reached
	BLE.S	L916DA
	MOVEA.L	A2,A3
L916DA	MOVEQ	#1,D4			best no. reps
	LEA	2(A0),A4		point to source + 2

*****
cmpl1	MOVE.B	(A0),D0
	MOVE.B	1(A0),D1
hntl1	CMP.B	(A4)+,D0		hunt for first byte
	BEQ.S	gtit1
hntl2	CMPA.L	A4,A3			check end reached
	BGT.S	hntl1
	BRA.S	L9174A

gtit1	CMP.B	(A4),D1			loop back if second not same
	BNE.S	hntl2

	MOVEA.L	A4,A6
	SUBQ.L	#1,A6			point to 1st repeated byte
	MOVE.L	A6,D0
	MOVEA.L	A0,A5			point to copy base
L916FC	CMPM.B	(A5)+,(A6)+
	BNE.S	gtit2
	CMPA.L	D0,A5			test for read = offset
	BHI.S	gtit2
	CMPA.L	A6,A3			test for A6 = end
	BGT.S	L916FC

*****
gtit2	MOVE.L	A5,D1
	SUB.L	A0,D1
	SUBQ.L	#1,D1			length of copy
	MOVE.L	A6,D2
	SUB.L	A5,D2			offset from base
	SUB.L	D1,D2			offset from copy end

	MOVE.L	#$409,D0		max copy len
	CMP.L	D0,D4
	BEQ.S	L9174A			do it if max already found(?)
	CMP.L	D0,D1			test for legal new copy
	BLS.S	cok1
	SUB.L	D0,D1			get amount over max
	ADD.L	D1,D2			increase offset from end
	MOVE.L	D0,D1			set copy to max

cok1	CMP.L	D1,D4			test for better copy
	BGE.S	dlp1
	CMP.W	#$111F,D2		test for illegal offset
	BHI.S	dlp1
	MOVE.L	D1,D4			save new copy length
	MOVE.W	D1,cbestcoplen
	MOVE.W	D2,cbestoffset		save the offset too

dlp1	CMPA.L	A4,A3			test for done
	BGT.S	cmpl1

***********
L9174A	MOVE.W	cbestoffset(PC),D0
	MOVE.W	D4,D1
	CMPI.W	#1,D1			test for no copy found
	BEQ.S	dextr
	CMPI.W	#2,D1			branch to 2 byte copy
	BEQ.S	d2bcop
	BRA.S	dnormcop		or normal copy

dextr	MOVE.B	(A0)+,(A1)+		another byte extract
	ADDQ.L	#1,D5			increase extraction counter
	BRA.S	dcmpl0

d2bcop	CMPI.W	#$23F,D0		extract if illegal offset
	BHI.S	dextr
	BSR	wrextract
	BSR	wr2bcopy
	BRA.S	rj13

dnormcop
	BSR	wrextract
	BSR	wroffset

rj13	BSR	wrcopyamount
	MOVEQ	#0,D5			zero extraction counter

	MOVE.W	cbestcoplen(PC),D0
	LEA	0(A0,D0.W),A0
dcmpl0	LEA	-3(A2),A3		finish at source-3
	CMPA.L	A3,A0
	BCS	cmpl0

***********
L91798	CMPA.L	A2,A0			extract last few bytes
	BGE.S	L917A2
	MOVE.B	(A0)+,(A1)+
	ADDQ.L	#1,D5
	BRA.S	L91798

L917A2	BSR	wrextract		write the extraction
	BSET	D6,D7
	BSR	write4bytes		empty the buffer

	SUBA.L	destbase(PC),A1		get length of compacted data
	MOVE.L	A1,D0
	MOVE.L	D0,D7
	move.l	D0,destlen
	MOVEA.L	destbase(PC),A1		write to base+4
	ADDQ.L	#4,A1
	BSR	write4bytes
	RTS

**************************************
wrextract
	CMP.L	#$810D,D5		max extract 33037 bytes
	BLS.S	wrxok1
	MOVE.W	#$FFFF,illextflag
	MOVEA.L	A0,A2

wrxok1	sub.l D5,bytestogo		decrease counter

	LEA	ctab1(PC),A3
	MOVEQ	#6,D3
fl1	MOVE.W	-(A3),D4
	CMP.W	D4,D5
	DBGE	D3,fl1

	SUB.W	D4,D5			make into excess
	ADD.W	D3,D3
	LEA	ctab1(PC),A3
	ADDA.W	D3,A3
	MOVE.B	(A3)+,D2		no. bits excess
	EXT.W	D2
	MOVEQ	#-1,D1
	LSL.L	D2,D1
	OR.W	D5,D1
	MOVEQ	#0,D5
	MOVE.B	(A3)+,D4		no. bits to write
	EXT.W	D4
	SUBQ.W	#1,D4
	BRA	writebits

	DC.W	0,1,2,5
	DC.W 	8,$F,$10E
ctab1	DC.B	1,1,1,2,2,4,2,6
	DC.B	3,9,8,$11,$F,$20

**************************************
wroffset
	LEA	ctab2(PC),A3
	MOVEQ	#2,D3
fl2	ADD.W	D3,D3
	MOVE.W	0(A3,D3.W),D4
	LSR.W	#1,D3
	CMP.W	D4,D0
	DBGE	D3,fl2

	SUB.W	D4,D0			make into excess
	ADD.W	D3,D3
	MOVE.W	6(A3,D3.W),D3
	MOVE.W	D3,D4
	LSR.W	#8,D3			shift amount
	MOVEQ	#-1,D1
	LSL.W	D3,D1
	OR.W	D0,D1
	ANDI.W	#$F,D4			no. bytes to write
	BRA	writebits

ctab2	DC.W	0,$20,$120
	DC.W	$606,$908,$C0D

**************************************
wr2bcopy
	CMPI.W	#$23F,D0
	BHI	dextr
	MOVE.W	D0,D1
	CMPI.W	#$3F,D1
	BLE.S	L91872
	SUBI.W	#$40,D1			64-575 = 10 bit
	MOVEQ	#9,D4
	BSET	D4,D1
	BRA	writebits
L91872	MOVEQ	#6,D4			0-63 = 7 bit
	BRA.S	writebits

**************************************
wrcopyamount
	LEA	ctab3(PC),A3
	moveq	#0,D0
	MOVE.W	cbestcoplen(PC),D0
	sub.l	D0,bytestogo

	MOVEQ	#4,D5
fl3	MOVE.B	0(A3,D5.W),D4
	EXT.W	D4
	CMP.W	D4,D0
	DBGE	D5,fl3

	SUB.W	D4,D0			make into excess
	MOVE.B	5(A3,D5.W),D4
	EXT.W	D4
	MOVEQ	#-1,D1
	LSL.W	D4,D1
	OR.W	D0,D1
	ADD.W	D5,D4
	SUBQ.W	#1,D4
	BRA.S	writebits

ctab3	DC.B	2,3,4,6,$A
	DC.B	1,1,2,3,$A

**************************************
writebits
	LSR.L	#1,D1
	ROXR.L	#1,D7
	DBF	D6,dwbl1
	BSR.S	write4bytes
	MOVEQ	#0,D7
	MOVEQ	#$1F,D6
dwbl1	DBF	D4,writebits
	RTS

**************************************
write4bytes
	ROL.L	#8,D7			write 4 bytes allowing
	MOVE.B	D7,(A1)+		for odd address
	ROL.L	#8,D7
	MOVE.B	D7,(A1)+
	ROL.L	#8,D7
	MOVE.B	D7,(A1)+
	ROL.L	#8,D7
	MOVE.B	D7,(A1)+
	RTS

*****************************************************************
convertit
	move.l sourcebase,A0		source base
	move.l sourcelen,D7		length of source
	subq #1,D7

	moveq #0,D0
cvl1	move.b (A0),D2
	move.b D2,D1
	sub.b D0,D1
	move.b D1,(A0)+
	move.b D2,D0
	dbra D7,cvl1
	rts

*****************************************************************
	include STUFF2.S

*****************************************************************
thing

