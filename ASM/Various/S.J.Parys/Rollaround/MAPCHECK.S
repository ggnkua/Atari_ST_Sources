    
        OPT     D+

*=========================================================================
*                                                                        *
*                       RAW DATA TO ASCII CONVERSION                     *
*                       ----------------------------                     *
*               By S.J.Parys            15\12\87                         *
*                                                                        *
*-------------------------------------------------------------------------


                BRA     START

               INCLUDE D:GEMINC.S
               INCLUDE D:GEMDOS.S

*--------- SET UP ROUTINE FOR GAME ON ST520 OR ST1040 MACHINES -----------

START           MOVE.L  A7,OLDSTACK

                CLR.L   -(A7)
                CALL_BDOS _SUPER        SUPER MODE SET
                ADD.L   #$6,A7
                MOVE.L  D0,SAVESTACK
                LEA     STACK,A7        NEW STACK

                DC.W    $A000           INITIALISE LINE "A"
                DC.W    $A00A           TURN OFF MOUSE

*                JSR     MODEL           SET MODE(low)
                LEA     MODE,A1
                MOVE.W  #1,(A1)         MED RES


*----------------------- PROG STARTS HERE --------------------------------


PROSESS         
LOADATA         MOVE.W  #27,D0          ESC
                JSR     CONOUT
                MOVE.W  #"Y",D0
                JSR     CONOUT
                MOVE.W  #33,D0
                JSR     CONOUT
                MOVE.W  #42,D0
                JSR     CONOUT

                MOVE.L  #BUFF,-(A7)
                MOVE.W  #$0A,-(A7)
                TRAP    #1
                ADDQ.L  #6,A7

                MOVE.W  BUFF,D0         LOW BYTE CONTAINS SIZE
                ANDI.L  #$000000FF,D0
                MOVE.W  D0,SIST
                LEA     LOADFILE,A0
                ADD.L   D0,A0
                MOVE.L  #5,D0           COUNT
                LEA     EXT,A1
LOPHS           MOVE.B  (A1)+,(A0)+
                DBF     D0,LOPHS

                JSR     DIRECT
                TST.W   D0
                BEQ     FU
                BRA     LOADATA 

CONOUT          MOVE.W  D0,-(A7)
                MOVE.W  #2,-(A7)
                TRAP    #1
                ADDQ.L  #4,A7
                RTS

*-------------------------------------------------------------------------
*		d7 holds size of file


FU
                LEA     RDATA,A1
		ADDA.W	#$784,A1	HEADER OFFSET
                LEA     RPUT,A2

CREAT           LEA	HEADER,A3
		MOVE.W	#46,D0
HEADLOP		MOVE.B	(A3)+,(A2)+
		DBF	D0,HEADLOP

MAPNUMBER	MOVE.B  TAB,(A2)+
                MOVE.B  TAB,(A2)+

		MOVE.W	(A1),POSTORE
	        MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+
                MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+

YCO		MOVE.B  TAB,(A2)+

	        MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+
                MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+

DEPTH		MOVE.B  TAB,(A2)+

	        MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+
                MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+

HEIGHT		MOVE.B  TAB,(A2)+

	        MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+
                MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+

ID		MOVE.B  TAB,(A2)+
	        MOVE.B  (A1)+,D2
		MOVE.B	D2,D6
		ANDI.B	#%11000000,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+
		MOVE.B	COMA,(A2)+
		MOVE.B	D6,D2
		ANDI.B	#%00111111,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+


FLAG		MOVE.B  TAB,(A2)+
		MOVE.B	#32,(A2)+	SPACE

                MOVE.B  (A1)+,D2
                BSR     CAL
                MOVE.B  DOLLA,(A2)+
                MOVE.B  D2,(A2)+
                MOVE.B  D3,(A2)+

		MOVE.B	#13,(A2)+
		MOVE.B	#10,(A2)+

		MOVE.L	A1,D6
		SUBI.L	#RDATA,D6
		CMP.L	D7,D6
		BHS	STOP	
		MOVE.W	POSTORE,D2
		CMP.W	(A1),D2
		BEQ	MAPNUMBER

		MOVE.B	#13,(A2)+
		MOVE.B	#10,(A2)+
		ADDI.W	#1,COUNT
		MOVE.W	COUNT,D2
                BSR     CAL
	        LEA	HEADER,A3
		MOVE.B	D2,7(A3)
		MOVE.B	D3,8(A3)
		MOVE.L	A1,D2
		SUB.L	#RDATA,D2
		MOVE.W	D2,OFFSET
		MOVE.B	OFFSET,D2
                BSR     CAL
	        LEA	HEADER,A3
		MOVE.B	D2,41(A3)
		MOVE.B	D3,42(A3)
		MOVE.B	OFFSET+1,D2
                BSR     CAL
	        LEA	HEADER,A3
		MOVE.B	D2,43(A3)
		MOVE.B	D3,44(A3)
		BRA	CREAT	
        

STOP            MOVE.L  #RPUT,D1
                MOVE.L  A2,D2
                SUB.L   D1,D2
                                
                LEA     LOADFILE,A6
                CLR.L   D0
                MOVE.W  SIST,D0
                ADD.L   D0,A6
                LEA     EXT1,A5
                MOVE.B  (A5)+,(A6)+     .
                MOVE.B  (A5)+,(A6)+     S
                MOVE.B  (A5),(A6)       0

                BSR     SAVE




*------------------------------------------------------------------------


FINISH          

*                JSR     MODEL           SET IN MED RES
                LEA     OLDPALL,A1
                JSR     PALL

LOP             MOVE.L  COLORPTR,D0
                TST.W   D0
                BNE     LOP

                DC.W    $A009           TURN ON MOUSE

                MOVE.L  OLDSTACK,A7

                MOVE.L  SAVESTACK,-(A7)
                MOVE.W  #$20,-(A7)
                TRAP    #1
                ADD.L   #$6,A7

                CLR.W   D0
                CLR.W   -(A7)           CLEAR STACK WORD
                TRAP    #1              RETURN
 
*--------------------------------------------------------------------------

BYTEXYR         MOVE.L  D5,D7
                JSR     XYCO1
                MOVE.L  D7,D5
                SWAP    D5
                ANDI.L  #$0000FFFF,D5   X CO
                ANDI.W  #$FFF8,D5
                LSR     #3,D5           DIVIDE BY 8
                OR.W    D5,D5           
                BEQ     OKH
                BTST    #0,D5           TEST IF ODD OR EVEN
                BNE     MULP
                BRA     OKH
MULP            ADDA.L  #1,A0
OKH             RTS
*---
PRNUM           MOVE.L  #7,D0
RE              MOVE.B  (A2)+,(A1)
                ADDA.L  #160,A1
                DBF     D0,RE
                RTS
*-------------------------------------------------------------------------
*               ENTRY D5 =X Y A0=CURRENT SCREEN EXIT A0= ADDRESS 
*               CURRUPTS  D0,D5,A0 

XYCO1           CLR.L   D0
                MOVE.W  D5,D0           Y CO
                SWAP    D5
                ANDI.L  #$0000FFFF,D5   X CO
                BRA     XYSUB
XYCO            CLR.L   D0
XYSUB           MULS    #160,D0         TIMES LINE LENTH
                ANDI.W  #$FFF0,D5
                ASR     #1,D5           DIVIDE BY 16 TIMES 6
                ADD.W   D5,D0           NUMBER OR BYTES DOWN THE SCREEN
                ADDA.L  D0,A0           ADD OFSET
                RTS
*-------------------------------------------------------------------------

MODEL           MOVE.W  MODE,D1         NEW MODE
                MOVE.W  D1,-(A7)
                MOVE.L  #$FFFFFFFF,-(A7)        SCREEN ADD
                MOVE.L  #$FFFFFFFF,-(A7)
                MOVE.W  #5,-(A7)
                TRAP    #14
                ADDA.L  #$C,A7          CLEAR UP
                RTS

*-------------------------------------------------------------------------
*               ADDRESS OF PALLET TO SET UP IN A1

PALL            MOVE.L  A1,-(A7)        NEW PALLET STORAGE AREA
                MOVE.W  #6,-(A7)
                TRAP    #14
                ADDQ.L  #6,A7
                RTS

*-------------------------------------------------------------------------
*       A4 = FILE NAME A5 = STORE D7 IF NEO ELSE SIZE

LOAD_PIC        MOVE.W  #0,-(A7)        READ\WRITE FILE
                MOVE.L  A4,-(A7)        ADDRESS OF FILE NAME
                CALL_BDOS F_OPEN
                ADDQ.L  #8,A7
                TST.W   D0              TEST FOR ERROR
                BMI     EROR
                MOVE.W  D0,HANDLE

                TST.L   D7
                BEQ     GOTOIT
                JMP     READ1

GOTOIT          MOVE.L  #$7D00,D7       FILE SIZE FOR NEO
                LEA     BUFFER,A1
READ            MOVE.L  A1,-(A7)
                MOVE.L  #128,-(A7)
                MOVE.W  HANDLE,-(A7)
                CALL_BDOS F_READ
                ADD.L   #12,A7
                TST.W   D0
                BMI     EROR

                LEA     BUFFER,A1       NEW PALLET
                ADDQ.L  #4,A1           COLOURS
                JSR     PALL            SET PALLET COLOUR

READ1           MOVE.L  A5,A1           SCREEN ADD
                MOVE.L  A1,-(A7)
                MOVE.L  D7,-(A7)        SIZE OF DATA
                MOVE.W  HANDLE,-(A7)
                CALL_BDOS F_READ
                ADD.L   #12,A7
                TST.W   D0
                BMI     EROR
 
CLOSE           MOVE.W  HANDLE,-(A7)
                CALL_BDOS F_CLOSE
                ADDQ.L  #4,A7
                RTS

*--------------------------------------------------------------------------

SAVE            MOVE.W  #0,-(A7)        CREAT FILE
                MOVE.L  #LOADFILE,-(A7)
                MOVE.W  #$3C,-(A7)
                TRAP    #1
                ADDQ.L  #8,A7
                TST.L   D0
                BMI     EROR
                MOVE.W  D0,HANDLE

WRITE           MOVE.L  #RPUT,-(A7)
                MOVE.L  D2,-(A7)
                MOVE.W  HANDLE,-(A7)
                MOVE.W  #$40,-(A7)
                TRAP    #1
                ADD.L   #12,A7

                JMP     CLOSE

*------------------
EROR            JSR     CLOSE
ERROR2          NEG.W   D0              TURN POS
                ANDI.L  #$0000FFFF,D0
                ADD.W   #-32,D0
                BCC     UNNO            UNKNOWN ERROR
                CMPI.W  #17,D0
                BCC     FINISH
                LEA     ERRFILE,A0
                LSL.W   #2,D0
                MOVE.L  0(A0,D0.W),A3   WORDS TO PRINT
GT              MOVE.L  #$00400001,D7   PRINT POS
LOPB            CLR.L   D0
                MOVE.L  D7,D5
                MOVE.L  $44E,A0         REAL SCREEN
                JSR     BYTEXYR         PRINT POS IN A0
                ADDQ.L  #6,A0
                CLR.L   D0              
                MOVE.B  (A3)+,D0
                TST.B   D0
                BEQ     RETURN
                CMPI.B  #32,D0          SPACE
                BNE     LET
                MOVE.B  #95,D0          LOAD SPACE
LET             ADDI.B  #-65,D0
                MULS    #8,D0
                LEA     ALPH,A2
                ADD.L   D0,A2           LETTER TO PRINT
                MOVE.L  A0,A1
                JSR     PRNUM
                SWAP    D7
                ADDI.W  #8,D7
                SWAP    D7
                BRA     LOPB
RETURN          CALL_BDOS C_RAWCIN      WAIT FOR KEY PRESS
                ADDQ.L  #2,A7
                RTS

UNNO            MOVE.L  #ER10,A3
                BRA     GT

ERRFILE         DC.L    ER0,ER1,ER2,ER3,ER4,ER5,ER6,ER7,ER8,ER9
*-------------------------------------------------------------------------


DIRECT          MOVE.L  #DTA,-(A7)      SET UP DATA BUFFER
                MOVE.W  #$1A,-(A7)
                TRAP    #1
                ADDQ.L  #6,A7

                MOVE.W  #0,-(A7)        READ/WRITE FILE
                MOVE.L  #LOADFILE,-(A7) FILE TO TRY AND LOAD
                MOVE.W  #$4E,-(A7)
                TRAP    #1
                ADDQ.L  #8,A7
                TST.L   D0
                BNE     ERROR2

                LEA     DTA,A6
                MOVE.L  #LOADFILE,A4    FILE NAME
                MOVE.L  #RDATA,A5          WHERE IN MEMORY TO PLACE FILE
                MOVE.L  26(A6),D7       FILE SIZE
                JSR     LOAD_PIC
                RTS

*---------------------------------------------------------------------
 
CAL             MOVE.B  D2,D3
                ANDI.B  #$F0,D2
                LSR.B   #4,D2
                CMPI.B  #10,D2
                BGE     LETTERS
                ADDI.B  #$30,D2
                BRA     NV
LETTERS         ADDI.B  #$37,D2
NV              ANDI.B  #$0F,D3
                CMPI.B  #10,D3
                BGE     LETS
                ADDI.B  #$30,D3
                RTS
LETS            ADDI.B  #$37,D3
                RTS     

*----------
KEY             MOVE.W  #$FF,-(A7)
                MOVE.W  #6,-(A7)
                TRAP    #1
                ADDQ.L  #4,A7
                RTS

*----------

SINGC           MOVE.W  D1,-(A7)        SINGLE COLOUR
                MOVE.W  #0,-(A7)
                MOVE.W  #7,-(A7)
                TRAP    #14
                ADDQ.L  #6,A7
                RTS
*------
                EVEN

OLDPALL         DC.W    $0777,$0700,$0070,0,0,0,0,0
                DC.W    0,$0070,$0070,0,0,0,0,0
NEWPALL         DC.W    $0444,$0456,$0456,0,0,0,0,0,0,0,0,0,0,0,0,$0456


SAVESTACK       DC.L    0
OLDSTACK        DC.L    0
MODE            DC.W    0               LOW RES MODE 16 COLOURS
HANDLE          DC.W    0               FILE HANDLE
SIST		DC.W	0
TAB             DC.B    9
COMA            DC.B    44,0
DEF             DC.B    "DC.W"
DOLLA           DC.B    "$",0
EXT             DC.B    ".MAP",0
EXT1            DC.B    ".S",0,0

BUFFER          DS.B    128

FILE            DC.B    "LETTERS.DAT",0
FILE1           DC.B    "LETTERS.S",0
BUFF            DC.B    10,0
LOADFILE        DC.B    "          .DAT",0,0

ER0             DC.B    "INAVLID FUNCTION NUMBER",0
ER1             DC.B    "NO SUCH FILE YOU TITHEAD",0
ER2             DC.B    "PATHNAME NOT FOUND",0
ER3             DC.B    "TOO MANEY FILES OPEN",0
ER4             DC.B    "ACESS NOT POSSIBLE",0
ER5             DC.B    "INVALID DOOR HANDLE",0
ER6             DC.B    "NOT ENOUGH MEMORY",0
ER7             DC.B    "INVALID MEMORY BLOCK",0
ER8             DC.B    "INVALID DRIVE",0
ER9             DC.B    "NO MORE FILES",0
ER10            DC.B    "UNKNONE ERROR PHONE ME",0

HEADER		DC.B	"COLUMN 01	MAP	Y C0	DEPTH	HEIGHT	ID	FLAG	$0784",13,10,0

COUNT		DC.W	1
POSTORE		DC.W	0
OFFSET		DC.W	0

                EVEN                    SET EVEN BOUNDRY

ALPH            DC.W    $7CC6,$C6FE,$C6C6,$C600,$FCC6,$C6FC,$C6C6,$FC00
                DC.W    $7CC6,$C0C0,$C0C6,$7C00,$FCC6,$C6C6,$C6C6,$FC00
                DC.W    $FEC0,$C0FC,$C0C0,$FE00,$FEC0,$C0FC,$C0C0,$C000
                DC.W    $7CC6,$C0CE,$C6C6,$7C00,$C6C6,$C6FE,$C6C6,$C600
                DC.W    $1818,$1818,$1818,$1800,$0606,$0606,$06C6,$7C00
                DC.W    $C6C6,$C6FC,$C6C6,$C600,$C0C0,$C0C0,$C0C0,$FE00
                DC.W    $C6EE,$FED6,$C6C6,$C600,$C6E6,$F6DE,$CEC6,$C600
                DC.W    $7CC6,$C6C6,$C6C6,$7C00,$FCC6,$C6FC,$C0C0,$C000
                DC.W    $7CC6,$C6C6,$C6CE,$7C06,$FCC6,$C6FC,$C6C6,$C600
                DC.W    $7CC6,$C07C,$06C6,$7C00,$7E18,$1818,$1818,$1800
                DC.W    $C6C6,$C6C6,$C6C6,$7C00,$C6C6,$C66C,$6C38,$3800
                DC.W    $C6C6,$C6D6,$FEEE,$C600,$C6C6,$C67C,$C6C6,$C600
                DC.W    $C6C6,$C67C,$3838,$3800,$FE06,$0C18,$3060,$FE00
                DC.W    $3030,$3030,$0030,$3000,$0000,$0000,$0030,$3000
                DC.W    $0000,$0000,$0030,$3060,$0030,$3000,$3030,$0000
                DC.L    $00000000,$00000000

SPACE           DS.B    1024

STACK           DC.L    0
KEYONOF         DC.B    0

                EVEN

DTA             DS.B    44              SPACE FOR DTA BUFFER
RDATA           DS.B    10000
RPUT            DC.B    0


                END
