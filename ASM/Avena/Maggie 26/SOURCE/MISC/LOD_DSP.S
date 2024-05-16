
;APPEARS TO WORK FIRST TIME!!

convert_lod:
	LEA	DspFile(PC),A1
.Start:
	 BSR	FindDataOrEnd
	 TST	D0
	 BMI	.QuitConvert
; OK Memory Data:
	 MOVE.L	A2,A0
	 MOVE.B	1(A2),(A1)+
	 ADDQ.W	#3,A2
	 BSR	ConvertWord16
	 MOVE.W	D7,(A1)+
; NOW SAVE THIS SPACE FOR THE NUMBER OF WORDS TO DO....
	 MOVE.L	A1,SAVE_A1
	 ADDQ.W	#2,A1

	 BSR	SkipWhiteSpace
; Now, find where the block ends:
	 MOVE.L	A2,A0
	 BSR	FindUnderscore
	 MOVE.L	A2,A6
	 LEA	-3(A6),A6
	 MOVE.L	A0,A2
	 MOVE.W	#0,SAVE_WORDCOUNT
.DataLoop:
	 BSR	ConvertWord24
	 MOVE.W	D7,D6
	 SWAP	D7
	 MOVE.B	D7,(A1)+
	 MOVE.B	D6,D7
	 LSR.W	#8,D6
	 MOVE.B	D6,(A1)+
	 MOVE.B	D7,(A1)+
	 ADDQ.W	#1,SAVE_WORDCOUNT
	 BSR	SkipWhiteSpace
	 CMP.L	A6,A2
	BLT.S	.DataLoop

	 PEA	(A1)
	 MOVE.L	SAVE_A1,A1
	 MOVE.W	SAVE_WORDCOUNT,(A1)
	 MOVE.L	(A7)+,A1
	 MOVE.L	A6,A0
	BRA.S	.Start

.QuitConvert:
	MOVE.W	#-1,(A1)+
	SUB.L	#DspFile,A1
	MOVE.L	A1,DspFileLength
	RTS

DspFileLength	DS.L	1
SAVE_A1		DS.L 1
SAVE_WORDCOUNT	DS.L	1

FindDataOrEnd:
	MOVE.L	A0,A2
.FindLoop
	BSR	FindUnderscore
	CMP.B	#"D",(A2)+
	BNE.S	.CheckEnd
	CMP.B	#"A",(A2)+
	BNE.S	.FindLoop
	CMP.B	#"T",(A2)+
	BNE.S	.FindLoop
	CMP.B	#"A",(A2)+
	BNE.S	.FindLoop
	MOVEQ	#0,D0
	RTS

.CheckEnd:
	CMP.B	#"E",-1(A2)
	BNE.S	.FindLoop
	CMP.B	#"N",(A2)+
	BNE.S	.FindLoop
	CMP.B	#"D",(A2)+
	BNE.S	.FindLoop
	MOVEQ	#-1,D0
	RTS
	
FindUnderscore:
	CMP.B	#"_",(A2)+
	BNE.S	FindUnderScore
	RTS

ConvertWord16:
	MOVEQ	#3,D0
	MOVEQ	#0,D7
.conv
	LSL.L	#4,D7
	BSR	ConvertHex
	ADD.W	D2,D7
	DBF	D0,.conv
	RTS

ConvertWord24:
	MOVEQ	#5,D0
	MOVEQ	#0,D7
.conv
	LSL.L	#4,D7
	BSR	ConvertHex
	ADD.W	D2,D7
	DBF	D0,.conv
	RTS

ConvertHex
	MOVE.B	(A2)+,D2
	CMP.B	#"0",D2
	BLT	ConvError
	CMP.B	#"9",D2
	BGT	ConvLetter
	SUB.W	#"0",D2
	RTS

ConvLetter:
	CMP.B	#"A",D2
	BLT.S	ConvError
	CMP.B	#"F",D2
	BGT	ConvError
	SUB.W	#"A"-10,D2
	RTS

SkipWhitespace:
	MOVE.B	(A2)+,D0
	CMP.B	#" ",D0
	BEQ.S	SkipWhitespace
	CMP.B	#13,D0
	BEQ.S	SkipWhitespace
	CMP.B	#10,D0
	BEQ.S	SkipWhitespace
	CMP.B	#0,D0
	BEQ.S	SkipWhitespace
	SUBQ.W	#1,A2
	RTS

ConvError
	ILLEGAL


