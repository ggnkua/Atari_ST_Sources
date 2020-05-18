**************************************
* Programme de configuration de XBAR *
**************************************
; Certifi‚ par le Pr SHADOCKO
	OUTPUT	XBAR_CHG.TOS

	BRA	e0e

Esc=27

ObjectArrayLength=24

ObjectNext	=0
ObjectHead	=2
ObjectTail	=4
ObjectType	=6
ObjectFlags	=8
ObjectState	=10
ObjectSpec	=12
ObjectX 	=16
ObjectY 	=18
ObjectW 	=20
ObjectH 	=22

ONil		=-1
ORoot		=0
OSND_XBARINbin	=1
OSND_XBARINhex	=2
OSND_XBAROUTbin =3
OSND_XBAROUThex =4
TNull			=0
TIndexedString		=1
TInteger8bUnsigned	=2
TInteger8bSigned	=3
TInteger16bUnsigned	=4
TInteger16bSigned	=5
TInteger24bUnsigned	=6
TInteger24bSigned	=7
TInteger32bUnsigned	=8
TInteger32bSigned	=9
TFrac8bUnsigned 	=12
TFrac16bUnsigned	=13
TFrac24bUnsigned	=14
TFrac32bUnsigned	=15
TString 		=28
FIndirect	=1<<8
SSelected	=1
SDecimal	=%00<<7
SBinary 	=%01<<7
SHexadecimal	=%10<<7
SRightJustified =1<<9
SZeroed 	=1<<10
SPlus_0 	=%10<<11

	M_
PrintMode		DS.W 1
PrintStringAddress	DS.L 1
PrintStringAddress2	DS.L 1
PrintStringLength	DS.W 1
PrintOutput		DS.W 1
PrintCharacterCount	DS.W 1
PrintCharacterCount2	DS.W 1
PrintAnteSPCount	DS.W 1
PrintPastSPCount	DS.W 1
DrawTreeAd		DS.L 1
DrawObjectNb		DS.W 1
DrawObjectRoot		DS.W 1
DrawObjectTail		DS.W 1
DrawObjectAd		DS.L 1
DrawX			DS.W 1
DrawY			DS.W 1
DrawSpec		DS.L 1
DrawString		DS.B 128
	P_

ConvertInteger32bToASCII:
 ;D0.L -> Integer32b
 ;D1   -> Mode
 ;	     b0= Signed mode
 ;	  b2-b1= Sign for positive number
 ;		 00: ''
 ;		 01: ' '
 ;		 10: '+' except for 0
 ;		 11: '+'
 ;	  b4-b3= Base
 ;		 00: Decimal
 ;		 01: Binary
 ;		 10: Hexadecimal
 ;A0   -> String of 34 bytes maxi
WorkPad=34
   ;Interne:
   ;D3=Base
   ;A3=Table des chiffres
	MOVEM.L D3/A3,-(SP)
	MOVE	D1,D2
	LSR	#3,D2
	ANDI	#%11,D2
	LEA	.TabBase(PC),A1
	MOVE	(A1,D2*2),D3
	LEA	.TabChif(PC),A3
	LINK	A6,#-WorkPad
	MOVEA.L A6,A1
	BTST	#0,D1
	BEQ.S	.32bu
	ANDI	#%110,D1
	LSR	#1,D1
.32bs	TST.L	D0
	BMI.S	.neg
.pos	CMPI	#%00,D1
	BEQ.S	.32bu
	CMPI	#%01,D1
	BNE.S	.1
	MOVE.B	#' ',(A0)+
	BRA.S	.32bu
.1	CMPI	#%10,D1
	BNE.S	.2
	TST.L	D0
	BEQ.S	.32bu
.2	MOVE.B	#'+',(A0)+
	BRA.S	.32bu
.neg	MOVE.B	#'-',(A0)+
	NEG.L	D0
.32bu	SWAP	D0
	MOVEQ	#0,D1
	MOVE	D0,D1 ;D1=XHigh
	CLR	D0
	SWAP	D0 ;D0=XLow
.divH	TST	D1
	BEQ.S	.divL
	DIVU	D3,D1
	SWAP	D1
	MOVEQ	#0,D2
	MOVE	D1,D2
	SWAP	D2
	ADD.L	D2,D0
	CLR	D1
	SWAP	D1
.divL	DIVU	D3,D0
	SWAP	D0
	MOVE.B	(A3,D0),-(A6)
	CLR	D0
	SWAP	D0
	BNE.S	.divH
.copy	MOVE.B	(A6)+,(A0)+
	CMPA.L	A1,A6
	BNE	.copy
	CLR.B	(A0)
	UNLK	A6
	MOVEM.L (SP)+,D3/A3
	RTS
.TabBase DC.W 10,2,16,10
.TabChif DC.B '0','1','2','3','4','5','6','7'
	 DC.B '8','9','A','B','C','D','E','F'

ConvertFrac32bToASCII:
 ;D0.L -> Frac32b
 ;D1   -> Mode
 ;	     b0= Signed mode
 ;	  b2-b1= Sign for positive number
 ;		 00: ''
 ;		 01: ' '
 ;		 10: '+' except for 0
 ;		 11: '+'
 ;	     b3= Decimal point
 ;		 0: '.'
 ;		 1: ','
 ;A0   -> String of 1+1+32+1 bytes maxi
 ;Base=10
	BTST	#0,D1
	BEQ.S	.32bu
	MOVE	D1,D2
	ANDI	#%110,D2
	LSR	#1,D2
.32bs	LSL.L	#1,D0
	BCS.S	.neg
.pos	CMPI	#%00,D2
	BEQ.S	.32bu
	CMPI	#%01,D2
	BNE.S	.1
	MOVE.B	#' ',(A0)+
	BRA.S	.32bu
.1	CMPI	#%10,D2
	BNE.S	.2
	TST.L	D0
	BEQ.S	.32bu
.2	MOVE.B	#'+',(A0)+
	BRA.S	.32bu
._1	MOVE.B	#'1',(A0)+
	BRA.S	.32bu
.neg	MOVE.B	#'-',(A0)+
	NEG.L	D0
	BEQ	._1
.32bu	MOVEQ	#'.',D2
	BTST	#3,D1
	BEQ.S	.dp
	MOVEQ	#',',D2
.dp	MOVE.B	D2,(A0)+
	SWAP	D0
	MOVEQ	#0,D1
	MOVE	D0,D1	;D1=XHigh
	CLR	D0
	SWAP	D0	;D0=XLow
.mulh	TST	D1
	BEQ.S	.mull
	MULU	#10,D1
.mull	TST	D0
	BEQ.S	.digit
	MULU	#10,D0
	SWAP	D0
	ADD	D0,D1
	SWAP	D0
.digit	SWAP	D1
	ADDI	#'0',D1
	MOVE.B	D1,(A0)+
	CLR	D1
	SWAP	D1
	MOVE	D1,D2
	OR	D0,D2
	BNE.S	.mulh
	CLR.B	(A0)
	RTS

PrintCharacter:
 ;D0 -> Character , Yes D0 !
 ;PrintOutput -> Output
 ;		      2:CONS
 ;		      5:SCRN
	CONS_OUT PrintOutput(PC),D0
	RTS

PrintString:
 ;PrintMode
 ;	 b0= Invalid 0 terminated string
 ;	     Valid PrintStringLength ->
 ;	 b1= Invalid control characters
 ;	 b2= Output character count =< PrintCharacterCount
 ;	 b3= Output character count => PrintCharacterCount
 ;	 b4= Right Justified
 ;	 b5= '0' for GAP
 ;PrintStringAddress= Address of string

	LEA	PrintStringAddress2(PC),A0
	MOVE.L	PrintStringAddress(PC),(A0)
	LEA	PrintCharacterCount2(PC),A0
	MOVE.L	PrintCharacterCount(PC),(A0)
.InitPrintOutput
	LEA	PrintOutput(PC),A0
	MOVEQ	#2,D0
	MOVE	PrintMode(PC),D1
	BTST	#1,D1
	BEQ.S	.Output
	MOVEQ	#5,D0
.Output MOVE	D0,(A0)
.InitPrintStringLength
	MOVE	PrintMode(PC),D0
	BTST	#0,D0
	BNE.S	.InitPrintStringAddress2
	ANDI	#%111101,D0
	BEQ	.PrintQuickC
	MOVEQ	#0,D0 ;count
	MOVE	#65535-1,D1 ;65535 bytes for limit
	MOVE	PrintMode(PC),D2
	ANDI	#%010100,D2
	CMPI	#%000100,D2
	BNE.S	.cnt
	MOVE	PrintCharacterCount(PC),D1
	SUBQ	#1,D1
.cnt	MOVEA.L PrintStringAddress2(PC),A0
.test	TST.B	(A0)+
	BEQ.S	.length
	ADDQ	#1,D0
	DBRA	D1,.test
.length LEA	PrintStringLength(PC),A0
	MOVE	D0,(A0)
.InitPrintStringAddress2
	LEA	PrintStringAddress2(PC),A0
	MOVE	PrintMode(PC),D0
	BTST	#2,D0
	BEQ.S	.InitPrintCharacterCount2
	BTST	#4,D0
	BEQ.S	.InitPrintCharacterCount2
	MOVEQ	#0,D0
	MOVE	PrintStringLength(PC),D0
	SUB	PrintCharacterCount2(PC),D0
	BLS.S	.InitPrintCharacterCount2
	ADD.L	D0,(A0)
.InitPrintCharacterCount2 ; with SP
	LEA	PrintCharacterCount2(PC),A0
	MOVE	PrintStringLength(PC),D0
	MOVE	PrintMode(PC),D1
	BTST	#2,D1
	BEQ.S	.min
	CMP	(A0),D0
	BLS.S	.min
	MOVE	(A0),D0
.min	BTST	#3,D1
	BEQ.S	.CharacterCount
	CMP	(A0),D0
	BHS.S	.CharacterCount
	MOVE	(A0),D0
.CharacterCount
	MOVE	D0,(A0)
.InitPrintAnteSPCount2
	LEA	PrintAnteSPCount(PC),A1
	MOVEQ	#0,D0
	BTST	#4,D1
	BEQ.S	.AnteSPCount
	MOVE	(A0),D2
	SUB	PrintStringLength(PC),D2
	BLS.S	.AnteSPCount
	MOVE	D2,D0
.AnteSPCount
	MOVE	D0,(A1)
	SUB	D0,(A0)
.InitPrintPastSPCount
	LEA	PrintPastSPCount(PC),A1
	MOVEQ	#0,D0
	BTST	#4,D1
	BNE.S	.PastSPCount
	MOVE	(A0),D2
	SUB	PrintStringLength(PC),D2
	BLS.S	.PastSPCount
	MOVE	D2,D0
.PastSPCount
	MOVE	D0,(A1)
	SUB	D0,(A0)

.PrintAnteSP
	MOVE	PrintAnteSPCount(PC),D0
	BEQ.S	.PrintCharacter
.nasp	MOVEQ	#' ',D0
	LEA	PrintMode+1(PC),A0
	BTST	#5,(A0)
	BEQ.S	.pasp
	MOVEQ	#'0',D0
.pasp	BSR	PrintCharacter
	LEA	PrintAnteSPCount(PC),A0
	SUBQ	#1,(A0)
	BNE	.nasp

.PrintCharacter
	MOVE	PrintCharacterCount2(PC),D0
	BEQ.S	.PrintPastSP
.nchar	LEA	PrintStringAddress2(PC),A0
	MOVEA.L (A0),A1
	MOVE.B	(A1)+,D0
	MOVE.L	A1,(A0)
	BSR	PrintCharacter
	LEA	PrintCharacterCount2(PC),A0
	SUBQ	#1,(A0)
	BNE	.nchar

.PrintPastSP
	MOVE	PrintPastSPCount(PC),D0
	BEQ.S	.x
.npsp	MOVEQ	#' ',D0
	LEA	PrintMode+1(PC),A0
	BTST	#5,(A0)
	BEQ.S	.ppsp
	MOVEQ	#'0',D0
.ppsp	BSR	PrintCharacter
	LEA	PrintPastSPCount(PC),A0
	SUBQ	#1,(A0)
	BNE	.npsp
.x	RTS

.PrintQuickC
	LEA	PrintStringAddress2(PC),A0
	MOVEA.L (A0),A1
	MOVE.B	(A1)+,D0
	BEQ.S	.xQC
	MOVE.L	A1,(A0)
	BSR	PrintCharacter
	BRA	.PrintQuickC
.xQC	RTS

PrintString0: ; C-style
 ;A0 -> Address of string
	LEA	PrintStringAddress(PC),A1
	MOVE.L	A0,(A1)
	LEA	PrintMode(PC),A1
	CLR	(A1)
	BSR	PrintString
	RTS

NormalVideo:
	LEA	.nv(PC),A0
	BSR	PrintString0
	RTS
.nv	DC.B	Esc,'q',0,0

InverseVideo:
	LEA	.iv(PC),A0
	BSR	PrintString0
	RTS
.iv	DC.B	Esc,'p',0,0

GetSpec:
 ;D0 <- Spec
 ;D1 -> Object
	LEA	ObjectList(PC),A0
	MULU	#ObjectArrayLength,D1
	ADDA	D1,A0
	MOVEA.L ObjectSpec(A0),A1
	BTST	#0,ObjectFlags(A0)
	BEQ.S	.1
	MOVEA.L (A1),A1
.1	MOVE.L	A1,D0
	RTS

SetSpec:
 ;D0 -> Spec
 ;D1 -> Object
	LEA	ObjectList(PC),A0
	MULU	#ObjectArrayLength,D1
	ADDA	D1,A0
	LEA	ObjectSpec(A0),A1
	BTST	#0,ObjectFlags(A0)
	BEQ.S	.1
	MOVEA.L (A1),A1
.1	MOVE.L	D0,(A1)
	RTS

RscCenterAndInit:
 ;A s‚parer ... de plus il faut "fournir" le nombre d'objet !!!
	DC.W	$A000
	MOVE	-44(A0),D0 ; V_CEL_MX
	ADDQ	#1,D0
	MOVE	-42(A0),D1 ; V_CEL_MY
	ADDQ	#1,D1
	LEA	ObjectList(PC),A0
	MOVEQ	#OSND_XBAROUThex-ORoot,D2
	SUB	ObjectW(A0),D0
	LSR	#1,D0
	SUB	ObjectH(A0),D1
	LSR	#1,D1
.center ADD	D0,ObjectX(A0)
	ADD	D1,ObjectY(A0)
	ADDA	#ObjectArrayLength,A0
	DBRA	D2,.center
	RTS

DrawAt:
 ;DrawX -> X
 ;DrawY -> Y
	LEA	.at(PC),A0
	MOVE	DrawX(PC),D0
	MOVE	DrawY(PC),D1
	ADDI	#32,D0
	ADDI	#32,D1
	MOVE.B	D0,3(A0)
	MOVE.B	D1,2(A0)
	BSR	PrintString0
	RTS
.at	DC.B	Esc,'Y',0,0,0 ;Y+32 and X+32
	EVEN

DrawAtObject:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	LEA	DrawX(PC),A1
	MOVE	ObjectX(A0),(A1)
	LEA	DrawY(PC),A1
	MOVE	ObjectY(A0),(A1)
	BRA	DrawAt

DrawNormal:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	BTST	#0,ObjectState+1(A0)
	BEQ.S	.x
	BSR	NormalVideo
.x	RTS

DrawInverse:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	BTST	#0,ObjectState+1(A0)
	BEQ.S	.x
	BSR	InverseVideo
.x	RTS

ReadSpec:
 ;DrawObjectAd -> ObjectAddress
 ;DrawSpec     <-
	LEA	DrawSpec(PC),A0
	MOVEA.L DrawObjectAd(PC),A1
	MOVEA.L ObjectSpec(A1),A2
	BTST	#0,ObjectFlags(A1)
	BEQ.S	.1
	MOVEA.L (A2),A2
.1	MOVE.L	A2,(A0)
	RTS

DrawInteger32bUnsigned:
 ;D0 -> Integer32b
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEQ	#%000,D1
	MOVE	ObjectState(A0),D2
	ANDI	#%11<<7,D2
	LSR	#7-3,D2
	OR	D2,D1
	LEA	DrawString(PC),A0
	BSR	ConvertInteger32bToASCII
	LEA	PrintMode(PC),A0
	MOVEQ	#%001100,D0
	MOVEA.L DrawObjectAd(PC),A1
	MOVE	ObjectState(A1),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	ObjectW(A1),(A0)
	LEA	PrintStringAddress(PC),A0
	LEA	DrawString(PC),A1
	MOVE.L	A1,(A0)
	BSR	PrintString
	RTS

DrawInteger32bSigned:
 ;D0 -> Integer32b
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEQ	#%001,D1
	MOVE.B	ObjectState(A0),D2
	LSR	#2,D2
	ANDI	#%110,D2
	OR	D2,D1
	MOVE	ObjectState(A0),D2
	ANDI	#%11<<7,D2
	LSR	#7-3,D2
	OR	D2,D1
	LEA	DrawString(PC),A0
	BSR	ConvertInteger32bToASCII
	LEA	PrintMode(PC),A0
	MOVEQ	#%001100,D0
	MOVEA.L DrawObjectAd(PC),A1
	MOVE	ObjectState(A1),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	ObjectW(A1),(A0)
	LEA	PrintStringAddress(PC),A0
	LEA	DrawString(PC),A1
	MOVE.L	A1,(A0)
	BSR	PrintString
	RTS

DrawFrac32bUnsigned:
 ;D0 -> Frac32b
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEQ	#%0000,D1
	LEA	DrawString(PC),A0
	BSR	ConvertFrac32bToASCII
	LEA	PrintMode(PC),A0
	MOVEQ	#%001100,D0
	MOVEA.L DrawObjectAd(PC),A1
	MOVE	ObjectState(A1),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A0)
	LEA	PrintCharacterCount(PC),A0
	MOVE	ObjectW(A1),(A0)
	LEA	PrintStringAddress(PC),A0
	LEA	DrawString(PC),A1
	MOVE.L	A1,(A0)
	BSR	PrintString
	RTS

DrawTNull:
	RTS

DrawTIndexedString:
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	MOVEA.L DrawSpec(PC),A1
	MOVEA.L (A1)+,A2
	MOVE	(A2),D0
	LSL	#2,D0
	MOVEA.L (A1,D0),A1
	LEA	PrintStringAddress(PC),A2
	MOVE.L	A1,(A2)
	LEA	PrintMode(PC),A1
	MOVEQ	#%001110,D0
	MOVE	ObjectState(A0),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A1)
	LEA	PrintCharacterCount(PC),A1
	MOVE	ObjectW(A0),(A1)
	BSR	PrintString
	RTS

DrawTInteger8bUnsigned:
	MOVEQ	#0,D0
	MOVE.B	DrawSpec+3(PC),D0
	BRA	DrawInteger32bUnsigned

DrawTInteger8bSigned:
	MOVE.B	DrawSpec+3(PC),D0
	EXT.W	D0
	EXT.L	D0
	BRA	DrawInteger32bSigned

DrawTInteger16bUnsigned:
	MOVEQ	#0,D0
	MOVE	DrawSpec+2(PC),D0
	BRA	DrawInteger32bUnsigned

DrawTInteger16bSigned:
	MOVE	DrawSpec+2(PC),D0
	EXT.L	D0
	BRA	DrawInteger32bSigned

DrawTInteger24bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	ANDI.L	#$FFFFFF,D0
	BRA	DrawInteger32bUnsigned

DrawTInteger24bSigned:
	MOVE.L	DrawSpec(PC),D0
	SWAP	D0
	EXT.W	D0
	SWAP	D0
	BRA	DrawInteger32bSigned

DrawTInteger32bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	BRA	DrawInteger32bUnsigned

DrawTInteger32bSigned:
	MOVE.L	DrawSpec(PC),D0
	BRA	DrawInteger32bSigned

DrawTFrac8bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	ANDI.L	#$FF000000,D0
	BRA	DrawFrac32bUnsigned

DrawTFrac16bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	CLR	D0
	BRA	DrawFrac32bUnsigned

DrawTFrac24bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	CLR.B	D0
	BRA	DrawFrac32bUnsigned

DrawTFrac32bUnsigned:
	MOVE.L	DrawSpec(PC),D0
	BRA	DrawFrac32bUnsigned

DrawTString:
 ;A0 -> ObjectAddress ( or DrawObjectAd )
	LEA	PrintStringAddress(PC),A1
	MOVE.L	DrawSpec(PC),(A1)
	LEA	.ox(PC),A1
	MOVE	ObjectX(A0),(A1)+
	MOVE	ObjectY(A0),(A1)+
	MOVE	ObjectW(A0),(A1)+
	MOVE	ObjectH(A0),(A1)
	LEA	PrintMode(PC),A1
	MOVEQ	#%001110,D0
	MOVE	ObjectState(A0),D1
	ANDI	#%11<<9,D1
	LSR	#5,D1
	OR	D1,D0
	MOVE	D0,(A1)
	LEA	PrintCharacterCount(PC),A1
	MOVE	.ow(PC),(A1)
.p	BSR	PrintString
	LEA	.oh(PC),A0
	SUBQ	#1,(A0)
	BEQ.S	.x
	MOVEA.L PrintStringAddress(PC),A0
	MOVEQ	#0,D0
	MOVE	PrintStringLength(PC),D0
	ADDA.L	D0,A0
	PEA	(A0)
	MOVE	PrintMode(PC),-(SP)
	LEA	DrawX(PC),A0
	MOVE	.ox(PC),(A0)
	LEA	DrawY(PC),A0
	LEA	.oy(PC),A1
	ADDQ	#1,(A1)
	MOVE	(A1),(A0)
	BSR	DrawAt
	LEA	PrintMode(PC),A0
	MOVE	(SP)+,(A0)
	LEA	PrintStringAddress(PC),A0
	MOVE.L	(SP)+,(A0)
	BRA	.p
.x	RTS

.ox	DS.W	1
.oy	DS.W	1
.ow	DS.W	1
.oh	DS.W	1

DrawTypeTable:
	DC.W	DrawTNull-DrawTNull
	DC.W	DrawTIndexedString-DrawTNull
	DC.W	DrawTInteger8bUnsigned-DrawTNull
	DC.W	DrawTInteger8bSigned-DrawTNull
	DC.W	DrawTInteger16bUnsigned-DrawTNull
	DC.W	DrawTInteger16bSigned-DrawTNull
	DC.W	DrawTInteger24bUnsigned-DrawTNull
	DC.W	DrawTInteger24bSigned-DrawTNull
	DC.W	DrawTInteger32bUnsigned-DrawTNull
	DC.W	DrawTInteger32bSigned-DrawTNull
	DC.W	DrawTNull-DrawTNull
	DC.W	DrawTNull-DrawTNull
	DC.W	DrawTFrac8bUnsigned-DrawTNull
	DC.W	DrawTFrac16bUnsigned-DrawTNull
	DC.W	DrawTFrac24bUnsigned-DrawTNull
	DC.W	DrawTFrac32bUnsigned-DrawTNull

DrawType:
 ;DrawObjectAd -> ObjectAddress
	MOVEA.L DrawObjectAd(PC),A0
	MOVE	ObjectType(A0),D0
	CMPI	#TString,D0
	BNE.S	.1
	BRA	DrawTString
.1	CMPI	#TFrac32bUnsigned,D0
	BLS.S	.2
	RTS
.2	LEA	DrawTypeTable(PC),A1
	LSL	#1,D0
	MOVE	(A1,D0),D0
	LEA	DrawTNull(PC),A1
	JMP	(A1,D0) ;A0 -> ObjectAddress

DrawObject:
 ;DrawTreeAd -> Tree
 ;DrawObjectNb -> Object
	LEA	DrawObjectAd(PC),A0
	MOVEA.L DrawTreeAd(PC),A1
	MOVE	DrawObjectNb(PC),D1
	MULU	#ObjectArrayLength,D1
	ADDA	D1,A1
	MOVE.L	A1,(A0)
	BSR	DrawAtObject
	BSR	DrawInverse
	BSR	ReadSpec
	BSR	DrawType
	BSR	DrawNormal
	RTS

DrawTree:
 ;DrawTreeAd -> Tree
 ;DrawObjectNb -> Object
	LEA	DrawObjectRoot(PC),A0
	MOVE	DrawObjectNb(PC),(A0)
.draw	BSR	DrawObject
	MOVEA.L DrawTreeAd(PC),A0
	MOVE	DrawObjectNb(PC),D0
	MULU	#ObjectArrayLength,D0
	MOVE	ObjectHead(A0,D0),D1
	BMI.S	.next
.head	LEA	DrawObjectNb(PC),A1
	MOVE	D1,(A1)
	LEA	DrawObjectTail(PC),A1
	MOVE	(A1),-(SP)
	MOVE	ObjectTail(A0,D0),(A1)
	BRA	.draw
.next	MOVE	DrawObjectNb(PC),D1
	CMP	DrawObjectRoot(PC),D1
	BEQ.S	.x
.bof	LEA	DrawObjectTail(PC),A1
	CMP	(A1),D1
	BEQ.S	.father
.brother
	LEA	DrawObjectNb(PC),A1
	MOVE	ObjectNext(A0,D0),(A1)
	BRA	.draw
.father MOVE	(SP)+,(A1)
	MOVE	ObjectNext(A0,D0),D1
	CMP	DrawObjectRoot(PC),D1
	BEQ.S	.x
	MOVE	D1,D0
	MULU	#ObjectArrayLength,D0
	BRA	.bof
.x	RTS

TableRegistres:
CopieRegistre=0
Registre_0=0
TailleChampRegistre=16
NombreRegistres=2
	DC.W OSND_XBARINbin,OSND_XBARINhex
	DC.L SND_XBARIN,Registre_0,CopieRegistre
	DC.W OSND_XBAROUTbin,OSND_XBAROUThex
	DC.L SND_XBAROUT,Registre_0,CopieRegistre
Registre DC.W 0

SauverRegistres:
	MOVEQ	#0,D0
	LEA	TableRegistres(PC),A0
.sr	MOVEA.L (A0,4),A1
	MOVE	(A1),(A0,10)
	MOVE	(A1),(A0,14)
	ADDA	#TailleChampRegistre,A0
	ADDQ	#1,D0
	CMPI	#NombreRegistres,D0
	BNE	.sr
	RTS

RestaurerRegistres:
	MOVEQ	#0,D0
	LEA	TableRegistres(PC),A0
.rr	MOVEA.L (A0,4),A1
	MOVE	(A0,10),(A1)
	MOVE	(A0,10),(A0,14)
	ADDA	#TailleChampRegistre,A0
	ADDQ	#1,D0
	CMPI	#NombreRegistres,D0
	BNE	.rr
	RTS

LireCopieRegistre:
 ;Registre ->
 ;D0 <- CopieRegistre
	MOVE	Registre(PC),D1
	LSL	#4,D1
	LEA	TableRegistres(PC),A0
	MOVE	(A0,D1,14),D0
	RTS

EcrireCopieRegistre:
 ;Registre ->
 ;D0 -> CopieRegistre
	MOVE	Registre(PC),D1
	LSL	#4,D1
	LEA	TableRegistres(PC),A0
	MOVE	D0,(A0,D1,14)
	RTS

EcrireRegistre:
 ;Registre ->
	MOVE	Registre(PC),D1
	LSL	#4,D1
	LEA	TableRegistres(PC),A0
	MOVEA.L (A0,D1,4),A1
	MOVE	(A0,D1,14),(A1)
	RTS

RegistreInverseVideo:
 ;Registre ->
	MOVE	Registre(PC),D0
	LSL	#4,D0
	LEA	TableRegistres(PC),A0
	MOVE	(A0,D0),D1
	LEA	ObjectList(PC),A1
	MULU	#ObjectArrayLength,D1
	EORI	#SSelected,(A1,D1,ObjectState)
	MOVE	(A0,D0,2),D1
	MULU	#ObjectArrayLength,D1
	EORI	#SSelected,(A1,D1,ObjectState)
	MOVE	(A0,D0),D0
	LEA	DrawObjectNb(PC),A0
	MOVE	D0,(A0)
	BSR	DrawTree
	RTS

e0e:
e1e	LEA	SetScreen(PC),A0
	BSR	PrintString0
e2e	PROG_SUPERMODE #0
	MOVE.L	D0,SPSaved
	BSR	SauverRegistres
	BSR	RscCenterAndInit
	LEA	DrawTreeAd(PC),A0
	LEA	ObjectList(PC),A1
	MOVE.L	A1,(A0)
	LEA	DrawObjectNb(PC),A0
	MOVE	#ORoot,(A0)
	BSR	DrawTree
	BRA.S	XBAR_CHG
x2x	PROG_SUPERMODE SPSaved
x1x	LEA	ResetScreen(PC),A0
	BSR	PrintString0
x0x	PROG_END

GetInputState:
	CONS_GINSTATE #2
	RTS

GetKey: CONS_IN #2
	RTS

XBAR_CHG:
	BSR	GetInputState
	TST	D0
	BEQ	XBAR_CHG
	BSR	GetKey
	MOVE.L	D0,D1
	SWAP	D1
	CMPI.B	#$48,D1
	BEQ.S	HAUT
	CMPI.B	#$50,D1
	BEQ.S	BAS
	CMPI.B	#'0',D0
	BLO.S	.1
	CMPI.B	#'9',D0
	BHI.S	.1
	SUBI.B	#'0',D0
	BRA.S	BIT
.1	CMPI.B	#'A',D0
	BLO.S	.2
	CMPI.B	#'F',D0
	BHI.S	.2
	SUBI.B	#'A'-10,D0
	BRA.S	BIT
.2	CMPI.B	#'a',D0
	BLO.S	.3
	CMPI.B	#'f',D0
	BHI.S	.3
	SUBI.B	#'a'-10,D0
	BRA.S	BIT
.3	CMPI.B	#13,D0
	BEQ.S	CR
	CMPI.B	#$61,D1
	BEQ.S	UNDO
	CMPI.B	#Esc,D0
	BEQ	ESC
	BRA	XBAR_CHG

HAUT:	MOVE	Registre(PC),D0
	BEQ	XBAR_CHG
	BSR	EcrireRegistre
	BSR	RegistreInverseVideo
	LEA	Registre(PC),A0
	SUBQ	#1,(A0)
	BSR	RegistreInverseVideo
	BRA	XBAR_CHG

BAS:	MOVE	Registre(PC),D0
	CMPI	#NombreRegistres-1,D0
	BEQ	XBAR_CHG
	BSR	EcrireRegistre
	BSR	RegistreInverseVideo
	LEA	Registre(PC),A0
	ADDQ	#1,(A0)
	BSR	RegistreInverseVideo
	BRA	XBAR_CHG

BIT: ;D0 -> Numero du bit
	ANDI	#%1111,D0
	MOVE	D0,D3
	BSR	LireCopieRegistre
	BCHG	D3,D0
	BSR	EcrireCopieRegistre
	MOVE	Registre(PC),D0
	LSL	#4,D0
	LEA	TableRegistres(PC),A0
	MOVE	(A0,D0),D0
	LEA	DrawObjectNb(PC),A0
	MOVE	D0,(A0)
	BSR	DrawTree
	BRA	XBAR_CHG

CR:	BSR	EcrireRegistre
	BRA	XBAR_CHG

UNDO:	BSR	RestaurerRegistres
	LEA	DrawObjectNb(PC),A0
	MOVE	#OSND_XBARINbin,(A0)
	BSR	DrawTree
	LEA	DrawObjectNb(PC),A0
	MOVE	#OSND_XBAROUTbin,(A0)
	BSR	DrawTree
	BRA	XBAR_CHG

ESC	BSR	EcrireRegistre
	BRA	x2x

	D_
SetScreen:	DC.B Esc,'f',Esc,'c',47,Esc,'b',50,Esc,'E',Esc,'w',0
ResetScreen:	DC.B Esc,'E',Esc,'c',48,Esc,'b',47,Esc,'e',0

; PSEUDO-RSC
ObjectList:

;Root
	DC.W	ONil
	DC.W	OSND_XBARINbin
	DC.W	OSND_XBAROUTbin
	DC.W	TString
	DC.W	0
	DC.W	0
	DC.L	PageTexte
	DC.W	0
	DC.W	0
	DC.W	40
	DC.W	12

;SND_XBARINbin
	DC.W	OSND_XBAROUTbin
	DC.W	OSND_XBARINhex
	DC.W	OSND_XBARINhex
	DC.W	TInteger16bUnsigned
	DC.W	FIndirect
	DC.W	SBinary!SRightJustified!SZeroed!SSelected
	DC.L	TableRegistres+12
	DC.W	16
	DC.W	9
	DC.W	16
	DC.W	1

;SND_XBARINhex
	DC.W	OSND_XBARINbin
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	FIndirect
	DC.W	SHexadecimal!SRightJustified!SZeroed!SSelected
	DC.L	TableRegistres+12
	DC.W	34
	DC.W	9
	DC.W	4
	DC.W	1

;SND_XBAROUTbin
	DC.W	ORoot
	DC.W	OSND_XBAROUThex
	DC.W	OSND_XBAROUThex
	DC.W	TInteger16bUnsigned
	DC.W	FIndirect
	DC.W	SBinary!SRightJustified!SZeroed
	DC.L	TableRegistres+TailleChampRegistre+12
	DC.W	16
	DC.W	10
	DC.W	16
	DC.W	1

;SND_XBAROUThex
	DC.W	OSND_XBAROUTbin
	DC.W	ONil
	DC.W	ONil
	DC.W	TInteger16bUnsigned
	DC.W	FIndirect
	DC.W	SHexadecimal!SRightJustified!SZeroed
	DC.L	TableRegistres+TailleChampRegistre+12
	DC.W	34
	DC.W	10
	DC.W	4
	DC.W	1

PageTexte:
	DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	DC.B "~ ..... XBAR_CHG by Patrick RUIZ ..... ~"
	DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	DC.B "~ ......   : Select ................ ~"
	DC.B "~ .. 0-9/A-F : Bit change ............ ~"
	DC.B "~ ....... CR : Write ................. ~"
	DC.B "~ ..... Undo : Restore ............... ~"
	DC.B "~ ... Escape : Exit without restoring  ~"
	DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	DC.B "~ SND_XBARIN = %----------------=$---- ~"
	DC.B "~ SND_XBAROUT= %----------------=$---- ~"
	DC.B "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

	M_
SPSaved 		DS.L 1
	END

; STRUCTURE OF THE OBJECTS

ObjectNext	DC.W
ObjectHead	DC.W
ObjectTail	DC.W
ObjectType	DC.W ; 0: Null
		     ; 1: IndexedString
		     ; 2: Integer8bUnsigned
		     ; 3: Integer8bSigned
		     ; 4: Integer16bUnsigned
		     ; 5: Integer16bSigned
		     ; 6: Integer24bUnsigned
		     ; 7: Integer24bSigned
		     ; 8: Integer32bUnsigned
		     ; 9: Integer32bSigned
		     ;10: Integer64bUnsigned
		     ;11: Integer64bSigned
		     ;12: Frac8bUnsigned
		     ;13: Frac16bUnsigned
		     ;14: Frac24bUnsigned
		     ;15: Frac32bUnsigned
		     ;16: Frac64bUnsigned
		     ;17: Float48b
		     ;18: Float64b
		     ;19: Float80b
		     ;28: String
ObjectFlags	DC.W ;b8= Indirect
ObjectState	DC.W ;b0= Selected
		     ;Number:
		      ;  b8-b7= Base
		      ; 	00: Decimal
		      ; 	01: Binary
		      ; 	10: Hexadecimal
		      ;     b9= Right Justification
		      ;    b10= '0' for GAP
		      ;b12-b11= Character for positive number
		      ; 	00: ''
		      ; 	01: ' '
		      ; 	10: '+' except 0
		      ; 	11: '+'
		      ;b14-b13= Space big number
		      ; 	00: ''
		      ; 	01: ' '
		      ; 	10: '.'
		      ; 	11: ','
		      ;    b15= Decimal point
		      ; 	0: '.'
		      ; 	1: ','
		     ;String:
		      ;     b9= Right Justification

ObjectSpec	DC.L ;IndexedStringStructureAddress
		     ;Integer8bUnsigned
		     ;Integer8bSigned
		     ;Integer16bUnsigned
		     ;Integer16bSigned
		     ;Integer24bUnsigned
		     ;Integer24bSigned
		     ;Integer32bUnsigned
		     ;Integer32bSigned
		     ;Integer64bUnsignedStructureAddress
		     ;Integer64bSignedStructureAddress
		     ;Frac8b
		     ;Frac16b
		     ;Frac24b
		     ;Frac32b
		     ;Frac64bStructureAddress
		     ;Float48bStructureAddress
		     ;Float64bStructureAddress
		     ;Float80bStructureAddress
		     ;StringStructureAddress
ObjectX 	DC.W
ObjectY 	DC.W
ObjectW 	DC.W
ObjectH 	DC.W

;STRUCTURE OF THE STRUCTURES

INDEXEDSTRING:	DC.L IndexAddress (Index is 16b)
		DC.L String0Address
		DC.L String1Address
		DC.L String2Address
		DC.L String3Address
		...

INTEGER64b:	DS.B 8

FRAC64b:	DS.B 8

FLOAT48b:	DS.B 6

FLOAT64b:	DS.B 8

FLOAT80b:	DS.B 10

STRING: 	DS.B 0TerminatedString if Length < (W*H)
