*========================================================================*
*                                                                        *
*                               ROLLAROUND                               *
*                               ----------                               *
*               Rollaround For  ST                                       * 
*               ST verson written for MASTERTRONIC                       *
*               By S.J.Parys            25\1\88                          *
*               For Mr Chip Software                                     *
*                                                                        *
*------------------------------------------------------------------------*
		BRA	START

		INCLUDE	A:\OLDGEM\GEMINC.S
		INCLUDE	A:\OLDGEM\GEMDOS.S
                
START     CLR.L      -(A7)
          MOVE.W    #$20,-(A7)        SUPER MODE SET
          TRAP      #1
          ADD.L     #$6,A7
          MOVE.L    D0,SAVESTACK
          MOVE.L    A7,OLDSTACK
          MOVE.L    #SPACE,A7

          DC.W      $A000           SET UP LINE "A"
          DC.W      $A00A           TURN OFF MOUSE

*         JSR       MODEL           SET MODE(low)
*         LEA       MODE,A1
*         MOVE.W    #1,(A1)         MED RES


          MOVE.L  	#FILE,A4       COMPRESSED BACKGROUND PIC
          MOVE.L 	#STO,A5        WHERE IN MEMORY TO PLACE FILE
          MOVE.L 	#32128,D7              
          JSR     	LOAD_PIC


*---------------------------------------------------------------------
*               MAIN  PROGRAMME STARTS HERE


START2	MOVE.W	#-1,-(A7)
		MOVE.W	#$40,-(A7)
		TRAP		#14
		ADDQ		#4,A7
		ORI.W	#1,D0
		MOVE.W	D0,-(A7)
		MOVE.W	#$40,-(A7)
		TRAP		#14
		ADDQ		#4,A7		TURN OFF BLITTER		

MAINLOOP	LEA		$FFFF8A00,A0	BLITTER HARDWARE REGS

		MOVE.B	$469.W,D0
FWAIT	CMP.B	$469.W,D0
		BEQ.S	FWAIT
		
		MOVE.L	#$420,D0
SWAIT	SUBI.L	#1,D0
		BNE.S	SWAIT

Justblit	
		LEA		$ffff8a00,A0
bitplane	EQU		-1
		MOVE.W	#0,0(A0)	WORD PATTEN MASK
		MOVE.W	#bitplane,2(A0)	
		MOVE.W	#bitplane,4(A0)	
		MOVE.W	#bitplane,6(A0)	
		MOVE.W	#bitplane,8(A0)	
		MOVE.W	#bitplane,10(A0)	
		MOVE.W	#bitplane,12(A0)	
		MOVE.W	#bitplane,14(A0)	
		MOVE.W	#bitplane,16(A0)	
		MOVE.W	#bitplane,18(A0)	
		MOVE.W	#bitplane,20(A0)	
		MOVE.W	#bitplane,22(A0)	
	 	MOVE.W	#bitplane,24(A0)	
		MOVE.W	#bitplane,26(A0)	
		MOVE.W	#bitplane,28(A0)	
		MOVE.W	#bitplane,30(A0)	

		MOVE.W	#$8,32(A0)	XINC
		MOVE.W	#$8,34(A0)	YINC
		MOVE.L	#STO+128,36(A0)	SOURCE ADDRESS
*		MOVE.W	STO+2,38(A0)
		MOVE.W	#$FFFF,40(A0)	
		MOVE.W	#$FFFF,42(A0)
		MOVE.W	#$FFFF,44(A0)
		MOVE.W	#$8,46(A0)	XINC
		MOVE.W	#$8,48(A0)	YINC
		MOVE.L	$44E,50(A0)	DESTINATION
		MOVE.W	#20,54(A0)	NUMBER OF WORDS IN LINE YET TO WRITE
		MOVE.W	#161,56(A0)	NUMBER OF LINES YET TO BE WRITTEN
		MOVE.B	#3,58(A0)	HALFTONE
		MOVE.B	#3,59(A0)	LOGIC OPERATIONS
		MOVE.B	61(A0),d0	SOURCE BUFFER BIT SHIFT 
		ADDQ	#1,D0
		AND.B	#15,D0
		BNE.S	OK1
		MOVE.L	50(A0),D1
		ADDQ	#8,D1
		MOVE.L	$44E,D2
		ADD.W	#160,D2
		CMP.L	D1,D2
		BCS.S	OK
		MOVE.L	$44E,D1
OK		MOVE.L	D1,50(A0)
OK1		MOVE.B	D0,61(A0)



		MOVE.B	60(A0),D0
		ORI.B	#128,D0
		MOVE.B	D0,60(A0)	HALFTONE MASK HOG BUSY SET TO START
LOP		
		MOVE.B	60(A0),D0
		BTST	#7,D0
		BNE.S	LOP
		

		MOVE.W	#$FF,-(A7)
		MOVE.W	#6,-(A7)
		TRAP	#1
		ADDQ	#4,A7
		TST.W	D0
		BEQ	MAINLOOP


*---------------------------------------------------------------------

FINISH
                LEA     OLDPALL,A1
                JSR     PALL

LOPS            MOVE.L  COLORPTR,D0
                TST.W   D0
                BNE.S   LOPS

                DC.W    $A009           TURN ON MOUSE
                MOVE.W  #8,$454


                MOVE.L  OLDSTACK,A7

                MOVE.L  SAVESTACK,-(A7)
                MOVE.W  #$20,-(A7)
                TRAP    #1
                ADD.L   #$6,A7

                CLR.W   D0
                CLR.W   -(A7)           CLEAR STACK WORD
                TRAP    #1              RETURN 

*-------------------------------------------------------------------------
*---------- ENTRY D1 DIRECTION -------------------------------------------


*------------------

SETCOLOUR       RTS
                MOVE.W  D0,-(A7)
                MOVE.W  #0,-(A7)
                MOVE.W  #7,-(A7)
                TRAP    #14
                ADDQ.L  #6,A7
                RTS

*------------------

*       READ KYBRD/JOYSTICK


*-----------------

**-------------------------------------------------------------------------
*-------------------------------------------------------------------------

                RTS
*-------------------------------------------------------------------------
*               ADDRESS OF PALLET TO SET UP IN A1

PALL            MOVE.L  A1,-(A7)        NEW PALLET STORAGE AREA
                MOVE.W  #6,-(A7)
                TRAP    #14
                ADDQ.L  #6,A7
                RTS

*-------------------------------------------------------------------------

*       A4 = FILE NAME A5 = STORE D7 IF ZERO = NEO ELSE SIZE

LOAD_PIC        MOVE.W  #0,-(A7)        READ\WRITE FILE
                MOVE.L  A4,-(A7)        ADDRESS OF FILE NAME
                CALL_BDOS F_OPEN
                ADDQ.L  #8,A7
                TST.W   D0              TEST FOR ERROR
                BMI.S   EROR
                MOVE.W  D0,HANDLE

                TST.L   D7
                BEQ.S   GOTOIT
                JMP     READ1

GOTOIT          MOVE.L  #$7D00,D7       FILE SIZE FOR NEO
                LEA     BUFFER,A1
READ            MOVE.L  A1,-(A7)
                MOVE.L  #128,-(A7)
                MOVE.W  HANDLE,-(A7)
                CALL_BDOS F_READ
                ADD.L   #12,A7
                TST.L   D0
                BMI.S   EROR

                LEA     BUFFER,A1       NEW PALLET
                ADDQ.L  #4,A1           COLOURS
                JSR     PALL            SET PALLET COLOUR

READ1           MOVE.L  A5,A1           SCREEN ADD
                MOVE.L  A1,-(A7)
                MOVE.L  D7,-(A7)        SIZE OF DATA
                MOVE.W  HANDLE,-(A7)
                CALL_BDOS F_READ
                ADD.L   #12,A7
                TST.L   D0
                BMI.S   EROR

CLOSE           MOVE.L  D0,D7           SAVE
                MOVE.W  HANDLE,-(A7)
                CALL_BDOS F_CLOSE
                ADDQ.L  #4,A7
                MOVE.L  D7,D0           RESTORE
                RTS

EROR            JSR     CLOSE
ERROR2          NEG.W   D0              TURN POS
                ANDI.L  #$0000FFFF,D0
                ADD.W   #-32,D0
                BCC.S   UNNO            UNKNOWN ERROR
                CMPI.W  #17,D0
                BCC     FINISH
                LEA     ERRFILE,A0
                LSL.W   #2,D0
                MOVE.L  0(A0,D0.W),A3   WORDS TO PRINT
GT              MOVE.L  #$00400001,D7   PRINT POS
LOPB            CLR.L   D0
                MOVE.L  D7,D5
                MOVE.L  $44E,A0         REAL SCREEN
*                JSR     BYTEXYR         PRINT POS IN A0
                ADDQ.L  #6,A0
                CLR.L   D0              
                MOVE.B  (A3)+,D0
                TST.B   D0
                BEQ.S   RETURN
                CMPI.B  #32,D0          SPACE
                BNE.S   LET
                MOVE.B  #95,D0          LOAD SPACE
LET             ADDI.B  #-65,D0
                MULS    #8,D0
*                LEA     CHRSET,A2
                ADD.L   D0,A2           LETTER TO PRINT
                MOVE.L  A0,A1
 *               JSR     PRNUM
                SWAP    D7
                ADDI.W  #8,D7
                SWAP    D7
                BRA.S   LOPB
RETURN          CALL_BDOS C_RAWCIN      WAIT FOR KEY PRESS
                ADDQ.L  #2,A7
                RTS

UNNO            MOVE.L  #ER10,A3
                BRA.S   GT

ERRFILE         DC.L    ER0,ER1,ER2,ER3,ER4,ER5,ER6,ER7,ER8,ER9
*-------------------------------------------------------------------------

SAVE            MOVE.W  #0,-(A7)        CREAT FILE
                MOVE.L  #LOADFILE,-(A7)
                MOVE.W  #$3C,-(A7)
                TRAP    #1
                ADDQ.L  #8,A7
                TST.L   D0
                BMI     EROR
                MOVE.W  D0,HANDLE

*WRITE           MOVE.L  #R1,-(A7)
                MOVE.L  D1,-(A7)
                MOVE.W  HANDLE,-(A7)
                MOVE.W  #$40,-(A7)
                TRAP    #1
                ADD.L   #12,A7

                JMP     CLOSE
*---------------------------------------------------------------------

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
*                MOVE.L  #R1,A5          WHERE IN MEMORY TO PLACE FILE
                MOVE.L  26(A6),D7       FILE SIZE
                JSR     LOAD_PIC
                RTS

*---------------------------------------------------------------------
                EVEN

OLDPALL         DC.W    $0777,$0700,$0070,0,0,0,0,0
                DC.W    0,$0070,$0070,0,0,0,0,0

SPRITEXY        DC.B    $06             X CO
YCO             DC.B    $50             Y CO

SAVESTACK       DC.L    0
MODE            DC.W    0               LOW RES MODE 16 COLOURS
HANDLE          DC.W    0               FILE HANDLE
OLDSTACK        DC.L    0
SCHANGE         DC.W    0
LASTPOS         DC.W    0
PSEUDO          DC.L    0
JOYDATA         DC.L    $E07
VECTORSAVE      DC.L    0
MOUSE           DC.L    0
POSAVE          DC.L    0
KEYSET          DC.B    $12,$15
ON              DC.B    $8
STOPCLOCK       DC.W    0
SAVED           DC.W    0
NUM0            DC.W    0
NUMV0           DC.W    0
NUM1            DC.W    0
NUMV1           DC.W    0
NUM2            DC.W    0
NUMV2           DC.W    0
NUM3            DC.W    0
NUMV3           DC.W    0
NUM4            DC.W    0
NUMV4           DC.W    0
NUM5            DC.W    0
NUMV5           DC.W    0
NUM6            DC.W    0
NUMV6           DC.W    0
NUM7            DC.W    0
NUMV7           DC.W    0
NUM8            DC.W    0
NUMV8           DC.W    0
NUM9            DC.W    0
NUMV9           DC.W    0
NUM11           DC.W    0
NFLAG           DC.L    0
HOLD            DC.L    0
TENTHOU         DC.B    0
THOU            DC.B    0
HUND            DC.B    0
TEN             DC.B    0
UNITS           DC.B    0
EXT             DC.B    ".DAT",0,0


                DS.B    1048
SPACE           DC.L    0

BUFFER          DS.B    128

PAUSEP          DC.W    0,$222,$111,$550,$500,$150,$226,$555,$405,$300
                DC.W    $633,$330,$030,$005,$304,$000

FILE            DC.B    "TEST.NEO",0        FILE NAME
FILE2           DC.B    "0000000.DAT",0            FILE NAME
FILE3           DC.B    "0000000.SML",0        FILE NAME
FILE1           DC.B    "0000000.SML",0         FILE NAME
FILE4           DC.B    "0000000.SML",0         FILE NAME
FILE5           DC.B    "0000000.SND",0          FILE NAME
FILE6           DC.B    "0000000.MSC",0           FILE NAME

BUFF            DC.B    10,0
LOADFILE        DC.B    "          .DAT",0,0

ER0             DC.B    "INVALID FUNCTION NUMBER",0
ER1             DC.B    "NO SUCH FILE ",0
ER2             DC.B    "PATHNAME NOT FOUND",0
ER3             DC.B    "TOO MANY FILES OPEN",0
ER4             DC.B    "ACCESS NOT POSSIBLE",0
ER5             DC.B    "INVALID DOOR HANDLE",0
ER6             DC.B    "NOT ENOUGH MEMORY",0
ER7             DC.B    "INVALID MEMORY BLOCK",0
ER8             DC.B    "INVALID DRIVE",0
ER9             DC.B    "NO MORE FILES",0
ER10            DC.B    "UNKNOWN ERROR PHONE ME",0
ENDR            DC.B    "ROOM DATA NOT SAVED EXIT PROG Y OR N ",0

TEXT            DC.W    16,104
                DC.B    "NOW ENTERING LEVEL",$FF,$FF
                DC.L    $00980080
LNUM            DC.B    0,0,$FF

                EVEN


DTA             DS.B    44              SPACE FOR DTA BUFFER
LEVBUFF         DS.B    1836

                EVEN

STO             DS.B    32128

                EVEN                    SET EVEN BOUNDRY

                END

