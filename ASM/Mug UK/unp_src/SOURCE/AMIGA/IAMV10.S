
			> ANALOG USHQ	Spatula City	+1.707.451.2835
			> ANALOG EHQ	Proton Dreams	+41.71.85.06.12
			> Soon opened:	Civil War	+41.27.xxx.xxx

         _________  ___    ___  _________  ___         _________  __________
        /  ___   /\/   \  /  /\/  ___   /\/  /\       /  ___   /\/  ____   /\
       /  /\_/  / /     \/  / /  /\_/  / /  / /      /  /\_/  / /  /\__/__/ /
      /  ___   / /  /\     / /  ___   / /  / /      /  / //  / /  / /__\__\/
     /  /\_/  / /  / /\   / /  /\_/  / /  / /      /  / //  / /  / /__  /\
    /  / //  / /  / / /  / /  / //  / /  /_/____  /  /_//  / /  /_/\_/ / /
   /__/ //__/ /__/ / /__/ /__/ //__/ /_________/\/________/ /_________/ /
   \__\/ \__\/\__\/  \__\/\__\/ \__\/\_________\/\________\/\_________\/  Wil

						-=> The Sky Has No Limit <=-


			    Is proud to present you


 ********************** ICE/ATOMIC MULTI CRUNCHER DOC ***********************
 *******************  A LITTLE UTILITY BY KEN OF ANALOG !  ******************

	Release 1.0
	November 1992


	This packer is based on some existing one in the Atari scene. The
main advantage of the Ice-Packer is the very fast decrunching algorithm,
faster as all you've seen before on your poor Amiga ! The efficiency of the
cruncher is average, but see a bit how fast it decrunch !

	Of course this utility is more destinated to demo-games program-
mers as normal cli-phreakers, because the format was not standard as power-
packer is.


	This util. is a very simple one : 

First gadget ("file type"):
--------------------------

	It concerns the file you have to pack...

	- If it is a data one (like some demo part,or gfx...etc), just
	  select "DATA" : the file will be simply crunched, no header
	  added, to decrunch it, you'll have to use the decrunch sources
	  included with this file...

	- If it is a prg one (files which could be ran...), select
	  "PROGRAM". It will be packed, and a prg header will be added
	  (a 820 bytes header for the ice algo, 868 for the atomic one),
	  which will decrunch your file automatically... Before packing
	  I test the source file, so if you did a mistake, don't worry...

	- If you are not sure (or if you are lazy), select "CHECK FILE",
	  a test will occure to detect file type...

Second gadget ("file mode"):
---------------------------

	You want to crunch a single file ? So, use the "SINGLE" mode,
otherwise select the "SEVERAL" (<--About this mode,you will have to select
a source and a target for each file you want to pack (max. 20 files)...To
stop script just select the CLOSE gadget or the "FORGET IT" on a  "SOURCE
FILE" requester !)

Third gadget ("algorythm"):
--------------------------

	It concerns the way you want to crunch your file(s). Both use
huffman's algorythm,so try them both !

NOTE:	these algo are not mine, I took them from the ATOMIC PACKER V3.5,
	and the ICE-PACKER 2.4 (<-i'm not sure), and I converted them
	(ATOMIC and ICE packer are ATARI ST utils)...

NOTE2:	By a strange way,i have to load a file in chip mem to use it with
	the ICE algo,otherwise a mega-crashe occures, AND I DON'T KNOW
	WHY ! So if someone find the solution just write t'me !!! (Crash
	looks like an attempt to read some "write-only" registers
	(strange !))

NOTE3: If a crash occures try the ATOMIC algo...(No bug)


	For the moment, I didn't find any bug (except "NOTE 2" one). Maybe
I will code a second version of this, more profesionnal, more funny...etc
but I'M NOT SURE !, so if you want it, write t'me ! (I have some games to
code, these times...)

My address:
----------	LIMBOURG AWEN
		14 BIS, RUE LAMARTINE
		21000 DIJON
		FRANCE !


PS:	If you want to write to the main coders of this util (i mean algo
	coders...) just find a ST ! (their work merit praise !)

PPS:	A bug found ! Some times ,some piece of mem are lost when exiting
	IAM PACKER, I don't know exactly why, but i'm searching!

PPPS:	Some greetings:

	-ATOMIC AND ICE CODERS !!!(GIGA THANX !)
	-ALL MY FRIENDS	: FERNAND,MANU,RHALEX,STEPH',LAETITIA,ISA,JP
			  JEAN-PHILIPPE,BENJAMIN...ETC (ANALOG RULES !)
			  GUS (ZE BROTHER)
			  FLO (THE CAT)
	-THE MUSIC I LISTEN:
			  MY BLOODY VALENTINE,ZE BOO RADLEYS,SONIC YOUTH
			  PIXIES,NIRVANA,RIDE...ETC
			  COULEUR 3 (FAVOURITE RADIO)
	-THE MOVIE I SAW:
			  ALIEN(S)(3),RESERVOIR DOGS,UNFORGIVEN...ETC


PPPPS:	See you soon !		  


*****************************************************************************
*			ATOMIC DECRUNCH ROUT				    *
*****************************************************************************

MODE:		EQU	1	;1 MEANS FROM A0 TO A0,0 FROM A0 TO A1
PIC_ALGO:	EQU	0	;FOR FILE USING A PIC PACKING(NOT IMPLEMENTED)
DEC_SPACE:	EQU	0	;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0	;0 MEANS NO RESTORE DEC SPACE

ATOM_DEPAC:	MOVEM.L	D0-A6,-(A7)
		CMP.L	#"ATM5",(A0)+
		BNE	NOT_PACKED
		LINK	A2,#-28
		MOVE.L	(A0)+,D0
		IF	MODE<>0
		LEA	4(A0,D0.L),A5
		MOVE.L	D0,-(A7)
		ELSE
		MOVE.L	A1,A5
		ADD.L	D0,A5
		ENDC
		MOVE.L	A5,A4
		IF	MODE<>0
		IF	DEC_SPACE<>0
		LEA	DEC_SPACE(A4),A5
		ENDC
		ENDC
		LEA	-$C(A4),A4
		MOVE.L	(A0)+,D0
		MOVE.L	A0,A6
		ADD.L	D0,A6
		IF	PIC_ALGO<>0
		MOVEQ	#0,D0
		MOVE.B	-(A6),D0
		MOVE	D0,-2(A2)
		IF	RESTORE_SPACE<>0
		LSL	#2,D0
		SUB	D0,A4
		ENDC
		ELSE
		IF	RESTORE_SPACE<>0
		CLR	-2(A2)
		ENDC
		SUBQ	#1,A6
		ENDC
		IF	RESTORE_SPACE<>0
		LEA	BUFF_MARG(PC),A3
		MOVE	-2(A2),D0
		LSL	#2,D0
		ADD	#DEC_SPACE+$C,D0
		BRA.S	.SAVE
.SAVE_M:	MOVE.B	(A4)+,(A3)+
		SUBQ	#1,D0
.SAVE:		BNE.S	.SAVE_M
		MOVEM.L	A3-A4,-(A7)
		ENDC
		IF	PIC_ALGO<>0
		PEA	(A5)
		ENDC
		MOVE.B	-(A6),D7
		BRA	TAKE_TYPE
DECRUNCH:	MOVE	D3,D5
TAKE_LENGHT:	ADD.B	D7,D7
.CONT_TAKE:	DBCS	D5,TAKE_LENGHT
		BEQ.S	.EMPTY1
		BCC.S	.NEXT_COD
		SUB	D3,D5
		NEG	D5
		BRA.S	.DO_COPY1
.NEXT_COD:	MOVEQ	#3,D6
		BSR.S	GET_BIT2
		BEQ.S	.NEXT_COD1
		BRA.S	.DO_COPY
.NEXT_COD1:	MOVEQ	#7,D6
		BSR.S	GET_BIT2
		BEQ.S	.NEXT_COD2
		ADD	#15,D5
		BRA.S	.DO_COPY
.EMPTY1:	MOVE.B	-(A6),D7
		ADDX.B	D7,D7
		BRA.S	.CONT_TAKE
.NEXT_COD2:	MOVEQ	#13,D6
		BSR.S	GET_BIT2
		ADD	#255+15,D5
.DO_COPY:	ADD	D3,D5
.DO_COPY1:	LEA	DECRUN_TABLE(PC),A4
		MOVE	D5,D2
		BNE.S	BIGGER
		ADD.B	D7,D7
		BNE.S	.NOT_EMPTY
		MOVE.B	-(A6),D7
		ADDX.B	D7,D7
.NOT_EMPTY:	BCS.S	.HO_KESAKO
		MOVEQ	#1,D6
		BRA.S	WORD
.HO_KESAKO:	MOVEQ	#3,D6
		BSR.S	GET_BIT2
		TST.B	-28(A2)
		BEQ.S	.HO_KESAKO1
		MOVE.B	10-28(A2,D5.W),-(A5)
		BRA	TST_END
.HO_KESAKO1:	MOVE.B	(A5),D0
		BTST	#3,D5
		BNE.S	.HO_KESAKO2
		BRA.S	.HO_KESAKO3
.HO_KESAKO2:	ADD.B	#$F0,D5
.HO_KESAKO3:	SUB.B	D5,D0
		MOVE.B	D0,-(A5)
		BRA	TST_END
GET_BIT2:	CLR	D5
.GET_BITS:	ADD.B	D7,D7
		BEQ.S	.EMPTY
.CONT:		ADDX	D5,D5
		DBF	D6,.GET_BITS
		TST	D5
		RTS
.EMPTY:		MOVE.B	-(A6),D7
		ADDX.B	D7,D7
		BRA.S	.CONT
BIGGER:		MOVEQ	#2,D6
WORD:		BSR.S	GET_BIT2
CONTUS:		MOVE	D5,D4
		MOVE.B	14(A4,D4.W),D6
		EXT	D6
		TST.B	1-28(A2)
		BNE.S	.SPE_OFCOD1
		ADDQ	#4,D6
		BRA.S	.NOSPE_OFCOD1
.SPE_OFCOD1:	BSR.S	GET_BIT2
		MOVE	D5,D1
		LSL	#4,D1
		MOVEQ	#2,D6
		BSR.S	GET_BIT2
		CMP.B	#7,D5
		BLT.S	.TAKE_OROF
		MOVEQ	#0,D6
		BSR.S	GET_BIT2
		BEQ.S	.ITS_LITTLE
		MOVEQ	#2,D6
		BSR.S	GET_BIT2
		ADD	D5,D5
		OR	D1,D5
		BRA.S	.SPE_OFCOD2
.ITS_LITTLE:	OR.B	2-28(A2),D1
		BRA.S	.SPE_OFCOD3
.TAKE_OROF:	OR.B	3-28(A2,D5.W),D1
.SPE_OFCOD3:	MOVE	D1,D5
		BRA.S	.SPE_OFCOD2
.NOSPE_OFCOD1:	BSR.S	GET_BIT2
.SPE_OFCOD2:	ADD	D4,D4
		BEQ.S	.FIRST
		ADD	-2(A4,D4.W),D5
.FIRST:		LEA	1(A5,D5.W),A4
		MOVE.B	-(A4),-(A5)
.COPY_SAME:	MOVE.B	-(A4),-(A5)
		DBF	D2,.COPY_SAME
		BRA.S	TST_END
MAKE_JNK:	ADD.B	D7,D7
		BNE.S	.NOT_EMPTY
		MOVE.B	-(A6),D7
		ADDX.B	D7,D7
.NOT_EMPTY:	BCS.S	STRING
		MOVE.B	-(A6),-(A5)
TST_END:	CMP.L	A5,A3
		BNE.S	MAKE_JNK
		CMP.L	A6,A0
		BEQ.S	WORK_DONE
TAKE_TYPE:	MOVEQ	#0,D6
		BSR	GET_BIT2
		BEQ.S	.NOSPE_OFCOD
		MOVE.B	-(A6),D0
		LEA	2-28(A2),A1
		MOVE.B	D0,(A1)+
		MOVEQ	#1,D1
		MOVEQ	#6,D2
.NEXT:		CMP.B	D0,D1
		BNE.S	.NO_OFF_4B
		ADDQ	#2,D1
.NO_OFF_4B:	MOVE.B	D1,(A1)+
		ADDQ	#2,D1
		DBF	D2,.NEXT
		ST	1-28(A2)
		BRA.S	.SPE_OFCOD
.NOSPE_OFCOD:	SF	1-28(A2)
.SPE_OFCOD:	MOVEQ	#0,D6
		BSR	GET_BIT2
		BEQ.S	.RELATIF
		LEA	10-28(A2),A1
		MOVEQ	#15,D0
.NEXT_F:	MOVE.B	-(A6),(A1)+
		DBF	D0,.NEXT_F
		ST	-28(A2)
		BRA.S	.FREQ
.RELATIF:	SF	-28(A2)
.FREQ:		CLR	D3
		MOVE.B	-(A6),D3
		MOVE.B	-(A6),D0
		LSL	#8,D0
		MOVE.B	-(A6),D0
		MOVE.L	A5,A3
		SUB	D0,A3
		BRA.S	MAKE_JNK
STRING:		BRA	DECRUNCH
WORK_DONE:
		IF	PIC_ALGO<>0
		MOVE.L	(A7)+,A0
		PEA	(A2)
		BSR.S	DECOD_PICTURE
		MOVE.L	(A7)+,A2
		ENDC
		IF	RESTORE_SPACE<>0
		MOVEM.L	(A7)+,A3-A4
		ENDC
		IF	MODE<>0
		MOVE.L	(A7)+,D0
		BSR	COPY_DECRUN
		ENDC
		IF	RESTORE_SPACE<>0
		MOVE	-2(A2),D0
		LSL	#2,D0
		ADD	#DEC_SPACE+$C,D0
		BRA.S	.RESTORE
.RESTORE_M:	MOVE.B	-(A3),-(A4)
		SUBQ	#1,D0
.RESTORE:	BNE.S	.RESTORE_M
		ENDC
		UNLK	A2
NOT_PACKED:	MOVEM.L	(A7)+,D0-A6
 		RTS
DECRUN_TABLE:	DC.W	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
		DC.W	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
		DC.B	0,1,3,4,5,6,7,8
		IF	PIC_ALGO<>0
DECOD_PICTURE:	MOVE	-2(A2),D7
.NEXT_PICTURE:	DBF	D7,.DECOD_ALGO
		RTS
.DECOD_ALGO:	MOVE.L	-(A0),D0
		LEA	0(A5,D0.L),A1
.NO_ODD:	LEA	$7D00(A1),A2
.NEXT_PLANES:	MOVEQ	#3,D6
.NEXT_WORD:	MOVE	(A1)+,D0
		MOVEQ	#3,D5
.NEXT_BITS:	ADD	D0,D0
		ADDX	D1,D1
		ADD	D0,D0
		ADDX	D2,D2
		ADD	D0,D0
		ADDX	D3,D3
		ADD	D0,D0
		ADDX	D4,D4
		DBF	D5,.NEXT_BITS
		DBF	D6,.NEXT_WORD
		MOVEM	D1-D4,-8(A1)
		CMP.L	A1,A2
		BNE.S	.NEXT_PLANES
		BRA.S	.NEXT_PICTURE
		ENDC
		IF	MODE<>0
COPY_DECRUN:	LSR.L	#4,D0
		LEA	-12(A6),A6
.COPY_DECRUN:	REPT	4
		MOVE.L	(A5)+,(A6)+
		ENDR
		DBF	D0,.COPY_DECRUN
		RTS
		ENDC
		IF	RESTORE_SPACE<>0
BUFF_MARG:	DCB.B	$90+DEC_SPACE+$C
		ENDC

*************************************************************************
*			ICE DEPACK ROUT					*
*			(FROM A0 TO A0)					*
*************************************************************************

ICE_DEPAC	LINK	A3,#-$78
		MOVEM.L	A0-A6/D0-D7,-(A7)
		LEA	120(A0),A4
		MOVE.L	A4,A6
		BSR.B	L00DC
		CMP.L	#$49434521,D0
		BNE.B	L00DB
		BSR.S	L00DC
		LEA	-8(A0,D0.L),A5
		BSR.S	L00DC
		MOVE.L	D0,(A7)
		ADD.L	D0,A6
		MOVE.L	A6,A1
		MOVEQ	#$77,D0
L00D4		MOVE.B	-(A1),-(A3)
		DBF	D0,L00D4
		MOVE.L	A6,A3
		MOVE.B	-(A5),D7
		BSR.S	L00DE
		MOVE.L	A3,A5
		BSR.W	L00E2
		BCC.S	L00D8
		MOVE.W	#$F9F,D7
		BSR.W	L00E2
		BCC.S	L00D5
		MOVEQ	#$F,D0
		BSR.W	L00E4
		MOVE.W	D1,D7
L00D5		MOVEQ	#3,D6
L00D6		MOVE.W	-(A3),D4
		MOVEQ	#3,D5
L00D7		ADD.W	D4,D4
		ADDX.W	D0,D0
		ADD.W	D4,D4
		ADDX.W	D1,D1
		ADD.W	D4,D4
		ADDX.W	D2,D2
		ADD.W	D4,D4
		ADDX.W	D3,D3
		DBF	D5,L00D7
		DBF	D6,L00D6
		MOVEM.W	D0-D3,(A3)
		DBF	D7,L00D5
L00D8		MOVEM.L	(A7),A0-A3/D0-D7
L00D9		MOVE.B	(A4)+,(A0)+
		SUBQ.L	#1,D0
		BNE.S	L00D9
		MOVEQ	#$77,D0
L00DA		MOVE.B	-(A3),-(A5)
		DBF	D0,L00DA
L00DB		MOVEM.L	(A7)+,A0-A6/D0-D7
		UNLK	A3
		RTS
L00DC		MOVEQ	#3,D1
L00DD		LSL.L	#8,D0
		MOVE.B	(A0)+,D0
		DBF	D1,L00DD
		RTS
L00DE		BSR.S	L00E2
		BCC.S	L00E1
		MOVEQ	#0,D1
		BSR.S	L00E2
		BCC.S	L00E0
		LEA	L00EF(PC),A1
		MOVEQ	#4,D3
L00DF		MOVE.L	-(A1),D0
		BSR.S	L00E4
		SWAP	D0
		CMP.W	D0,D1
		DBNE	D3,L00DF
		ADD.L	20(A1),D1
L00E0		MOVE.B	-(A5),-(A6)
		DBF	D1,L00E0
L00E1		CMP.L	A4,A6
		BGT.S	L00E7
		RTS
L00E2		ADD.B	D7,D7
		BNE.S	L00E3
		MOVE.B	-(A5),D7
		ADDX.B	D7,D7
L00E3		RTS
L00E4		MOVEQ	#0,D1
L00E5		ADD.B	D7,D7
		BNE.S	L00E6
		MOVE.B	-(A5),D7
		ADDX.B	D7,D7
L00E6		ADDX.W	D1,D1
		DBF	D0,L00E5
		RTS
L00E7		LEA	L00F0(PC),A1
		MOVEQ	#3,D2
L00E8		BSR.S	L00E2
		DBCC	D2,L00E8
		MOVEQ	#0,D4
		MOVEQ	#0,D1
		MOVE.B	1(A1,D2.W),D0
		EXT.W	D0
		BMI.S	L00E9
		BSR.S	L00E4
L00E9		MOVE.B	6(A1,D2.W),D4
		ADD.W	D1,D4
		BEQ.S	L00EB
		LEA	L00F1(PC),A1
		MOVEQ	#1,D2
L00EA		BSR.S	L00E2
		DBCC	D2,L00EA
		MOVEQ	#0,D1
		MOVE.B	1(A1,D2.W),D0
		EXT.W	D0
		BSR.S	L00E4
		ADD.W	D2,D2
		ADD.W	6(A1,D2.W),D1
		BPL.S	L00ED
		SUB.W	D4,D1
		BRA.S	L00ED
L00EB		MOVEQ	#0,D1
		MOVEQ	#5,D0
		MOVEQ	#-1,D2
		BSR.S	L00E2
		BCC.S	L00EC
		MOVEQ	#8,D0
		MOVEQ	#$3F,D2
L00EC		BSR.S	L00E4
		ADD.W	D2,D1
L00ED		LEA	2(A6,D4.W),A1
		ADD.W	D1,A1
		MOVE.B	-(A1),-(A6)
L00EE		MOVE.B	-(A1),-(A6)
		DBF	D4,L00EE
		BRA.W	L00DE
		DC.W	$7FFF,$000E,$00FF,$0007
		DC.W	$0007,$0002,$0003,$0001
		DC.W	$0003,$0001
L00EF		DC.W	0
		DC.B 	$1,$D,0,0,0,$E,0,0,0,$7,0,0,0,$4,0,0,0,