; ASM2CLD.S
; Written sometime in 1994!


; Code to invoke the ASM56000 and LOD2CLD apps to produce a CLD file
;
; Macros 'app' and 'source' must define the paths of the app and source
; files.
; To run from Devpac 3, enter the filename WITHOUT ".ASM" on the cmd line



;---------------------------------------------------------------------
; Address of assembly applications:
; Note: Folder identifiers MUST have \\ instead of \ to assemble!!

app	macro
	dc.b	'c:\\apps\\program\\ttp\\'
	endm

; Address of our .ASM file:

source	macro
	dc.b	'd:\\dsp\\asm\\'
	endm
;---------------------------------------------------------------------



	OUTPUT	C:\APPS\PROGRAM\TTP\ASM2CLD.TTP


	move.l a7,a5
	move.l 4(a5),a5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #500,d0
	move.l d0,d1
	add.l a5,d1
	and.l #-2,d1
	move.l d1,a7
	move.l d0,-(a7)
	move.l a5,-(a7)
	pea $4a0000
	trap #1
	lea 12(a7),a7

	bsr convert_cli

	lea text1(pc),a0
	bsr print

; First, run assembler
	pea fake_env(pc)
	pea asm_cli(pc)
	pea asm_file(pc)
	pea $4b0000
	trap #1
	lea 16(a7),a7

; run cld-->lod
	pea fake_env(pc)
	pea cldlod_cli(pc)
	pea cldlod_file(pc)
	pea $4b0000
	trap #1
	lea 16(a7),a7

	lea text3(pc),a0
	bsr print

; Finally, run lod-->CLD

	lea	cldlod_cli2(pc),a0
	bsr	load_file

	lea	CLDfile_data,a0
	jsr	convert_lod

	lea	SaveFileName(pc),a0
	BSR	Save_File

	lea text4(pc),a0
	bsr print

; Wipe out files:
	pea delete1(pc)
	move.w #$41,-(a7)
	trap #1
	addq.l #6,a7

	move.w #0,-(a7)
	trap #1

; ****** Subroutines ******

print:	pea (a0)
	move.w #9,-(a7)
	trap #1
	addq.l #6,a7
	rts

convert_cli:
; Make filename:
	bsr make_filename

; First, .asm command line:
; Output file first
; Then source file name
	lea asm_cli2(pc),a1
	bsr copyit
	move.b #".",(a1)+
	move.b #"a",(a1)+
	move.b #"s",(a1)+
	move.b #"m",(a1)+
	clr.b (a1)+
	move.l a1,d1
	sub.l #asm_cli+1,d1
	move.b d1,asm_cli

; CLD->LOD command line/filename:
	lea cldlod_cli2(pc),a1
	bsr copyit
	move.b #".",(a1)+
	move.b #"l",(a1)+
	move.b #"o",(a1)+
	move.b #"d",(a1)+
	clr.b (a1)+

	move.l a1,d1
	sub.l #cldlod_cli+1,d1
	move.b d1,cldlod_cli

; SAVE FILE:
	lea SaveFileName(pc),a1
	bsr copyit
	move.b #".",(a1)+
	move.b #"c",(a1)+
	move.b #"l",(a1)+
	move.b #"d",(a1)+
	clr.b (a1)+
	rts

copyit:	lea our_filename(pc),a0
.getit	move.b (a0)+,d0
	beq.s .done

	move.b d0,(a1)+
	bra.s .getit
.done	rts

make_filename:				;(without extender)
	lea $81(a5),a0
	lea our_filename2(pc),a1
.getit	move.b (a0)+,d0
	beq.s .done

	move.b d0,(a1)+
	bra.s .getit
.done	clr.b (a1)+
	rts
	even

load_file:
	BSR	FOpen
	PEA	CLDfile_data(PC)
	PEA	$FFFFFF
	MOVE.W	D0,-(A7)
	MOVE.W	#$3F,-(A7)	;GEMDOS 3F, F_READ
	TRAP	#1
	LEA	12(A7),A7
	BSR	FClose
	RTS

Save_file:
	BSR	FCreate
	PEA	CLDFile
	MOVE.L	CLDFileLength(PC),-(A7)
	MOVE.W	FHandle,-(A7)
	MOVE.W	#$40,-(A7)	;GEMDOS 3F, F_READ
	TRAP	#1
	LEA	12(A7),A7
	BSR	FClose
	RTS


FOpen:
	MOVE.W	#0,-(A7)
	PEA	(A0)
	MOVE.W	#$3D,-(A7)	;GEMDOS 3D, F_OPEN
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.W	D0,FHandle
	RTS

FCreate:
	MOVE.W	#0,-(A7)
	PEA	(A0)
	MOVE.W	#$3c,-(A7)	;GEMDOS 3C, F_CREATE
	TRAP	#1
	ADDQ.L	#8,A7
	MOVE.W	D0,FHandle
	RTS

FClose:
	MOVE.W	FHandle(PC),-(A7)
	MOVE.W	#$3E,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	RTS	

FHandle:DS.W	1

convert_lod:
	LEA	CLDFile,A1
.Start:
	 BSR	FindDataOrEnd
	 TST	D0
	 BMI	.QuitConvert

; OK Memory Data:
	 MOVE.L	A2,A0

; Convert to 0/1/2 here
; 0 = P memory
; 1 = X memory
; 2 = Y memory

	 MOVE.B	1(A2),D0
	 CMP.B	#"X",D0
	 BNE.S	.not1
	 CLR.B	(A1)+			;sent empty value
	 MOVE.W	#1,(A1)+
	 bra.s .ok
.not1:
	 CMP.B	#"Y",D0
	 BNE.S	.not2
	 CLR.B	(A1)+			;sent empty value
	 MOVE.W	#2,(A1)+
	 bra.s .ok
.not2:
	 CMP.B	#"P",D0
	 BNE.S	.not3
	 CLR.B	(A1)+			;sent empty value
	 MOVE.W	#0,(A1)+
	 bra.s .ok
.not3:
	move.w #-1,(A1)+
.ok:
	 ADDQ.W	#3,A2

	 BSR	ConvertWord16

; Write address
	 CLR.B	(A1)+
	 MOVE.W	D7,(A1)+

; NOW SAVE THIS SPACE FOR THE NUMBER OF WORDS TO DO....
	 MOVE.L	A1,SAVE_A1
	 ADDQ.W	#3,A1

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

         CLR.B	(A1)				;save data length 1
	 MOVE.W	SAVE_WORDCOUNT,1(A1)		;                 2

	 MOVE.L	(A7)+,A1

	 MOVE.L	A6,A0
	BRA	.Start

.QuitConvert:
	;CLR.B	(A1)+
	;MOVE.W	#3,(A1)+		;send "reset" value

	SUB.L	#CLDFile,A1
	MOVE.L	A1,CLDFileLength
	RTS

CLDFileLength	DS.L	1
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



our_filename:
	source
our_filename2:
	ds.b 120

asm_file:
	app
	dc.b "asm56000.ttp",0
	even
cldlod_file:
	app
	dc.b "cld2lod.ttp",0
	even

	even
asm_cli:
	dc.b 128,"-a -oIL -v -b\xyzzy.cld "	;change options if desired
asm_cli2:
	ds.b 100				;be on safe side

	even
cldlod_cli:
	dc.b 128,"\xyzzy.cld "
cldlod_cli2:
	ds.b 128
	even

SaveFileName:
	ds.b 128

delete1:
	dc.b "\xyzzy.cld",0
	even


text1	dc.b 27,"EASM --> CLD routine by TaT",13,10
	dc.b "Assembling.....",13,10,10,0

text3	dc.b 13,10,"Converting to CLD routine... ",13,13,10,0
text4	dc.b "**** Assembly completed ****",0
	even
fake_env DC.B 0			;eurk



	SECTION	BSS
CLDfile_data	ds.b 60000
CLDFile		ds.b 20000
