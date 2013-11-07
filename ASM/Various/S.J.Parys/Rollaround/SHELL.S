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

                
START           CLR.L   -(A7)
                MOVE.W  #$20,-(A7)        SUPER MODE SET
                TRAP    #1
                ADD.L   #$6,A7
                MOVE.L  D0,SAVESTACK
                MOVE.L  A7,OLDSTACK
                MOVE.L  #SPACE,A7

                DC.W    $A000           SET UP LINE "A"
                DC.W    $A00A           TURN OFF MOUSE

                JSR     MODEL           SET MODE(low)
                LEA     MODE,A1
                MOVE.W  #1,(A1)         MED RES


                MOVE.L  #FILE3,A4       COMPRESSED BACKGROUND PIC
                MOVE.L  #SP0,A5         WHERE IN MEMORY TO PLACE FILE
                MOVE.L  #2408,D7              
                JSR     LOAD_PIC


        MOVE.L  #KEYSET,-(A7)
        MOVE.L  #$190001,-(A7)  MOFF,JOFF
        TRAP    #14
        ADDQ.W  #8,A7


                MOVE.L  #20,D1
JHG             MOVE.L  #65535,D0
LOPWAITS        DBF     D0,LOPWAITS
                DBF     D1,JHG

*       ALL MFP IRQS OFF

        IFNE    DEBUG

        LEA     $FFFFFA01,A0		MFP 24 REGISTORS
        MOVEQ   #0,D0
        MOVEP.L D0,0(A0)	TURN OFF FROM PAR PORT TO INTERRUPT MASK B 
        MOVEP.L D0,8(A0)
        MOVEP.L D0,16(A0)
        MOVE.B  #$48,22(A0)	TOP FOUR BITS  = 64 VECTOR ADD BOT FOUR
*                		BITS PRIORITIES OF INTERRUPTS
*       RESET KEYBOARD ACIA

        MOVE.B  #3,$FFFFFC00		MASTER RESET (bit represention)
*					8 DATABITS 1 STOPBITS EVEN PARITY
        MOVE.B  #$96,$FFFFFC00

        ENDC

*       INITIALIZE SOUND CHIP

        LEA     $FFFF8800,A0
        MOVEQ   #6,D0
REGS_TO_0       MOVE.B  D0,(A0)
        CLR.B   2(A0)
        DBF     D0,REGS_TO_0
        MOVE.B  #7,(A0)
        MOVE.B  (A0),D0
        OR.B    #$3F,D0 TONE AND NOISE OFF
        MOVE.B  D0,2(A0)        WITHOUT DISTURBING
        MOVEQ   #10,D0  PORTAB BITS
REGS_TO_0_2     MOVE.B  D0,(A0)
        CLR.B   2(A0)
        CMP.B   #8,D0
        DBEQ    D0,REGS_TO_0_2

        IFNE    DEBUG

VECTOR          
*       NEW KEYBRD/JYSTK VECTOR

        MOVE.L  #READKEY,(A7)
        MOVE.L  #$D0006,-(A7)
        TRAP    #14
        ADDQ.W  #8,A7

        ENDC

*       WAIT FOR VBL

        MOVE.B  $469.W,D0
WAIT    CMP.B   $469.W,D0
        BEQ.S   WAIT

*       SET UP TIMER B TO 10TH DISLAY ENABLE

        MOVE.L  #PLAY,-(A7)     TIMER VECTOR (YOUR ROUTINE)
        MOVE.L  #$8000A,-(A7)   8 =EVENTCOUNT MODE/A=PULSE EXTENSION 10
        MOVE.L  #$1F0001,-(A7)  1 = XBTIMER B
        TRAP    #14
        ADD.L   #12,A7

        IFNE    DEBUG

*       NEW VBL

        MOVE.L  $70.W,OLDVBL+2
        MOVE.L  #VBL,$70.W

        ENDC


*---------------------------------------------------------------------
*               MAIN  PROGRAMME STARTS HERE


*       WAIT FOR NEXT VBL

        MOVE.B  $469.W,D0
WVBL    CMP.B   $469.W,D0
        BEQ.S   WVBL

*       WAIT UNTIL RASTER REACHES LINE 1

        LEA     $FFFF8209,A0    SCREEN BASE MID-BYTE
WAIT2   TST.B   (A0)            RASTER ABOVE LINE 1 ?
        BEQ.S   WAIT2           YES

                TST.W   SELECTPALL
                BEQ.S   SEAT
                LEA     PALLTABLE,A0
                MOVE.W  SELECTPALL,D0
                LSL.W   #2,D0
                MOVE.L  0(A0,D0.W),A1
                JSR     SETPALLET

SEAT            MOVE.L  PSEUDO,A0
                JSR     MOVEDATA

*       REQUEST JOYSTICK DATA

        LEA     $FFFFFC00,A0
JOYWAIT MOVE.B  (A0),D0
        BTST    #1,D0
        BEQ.S   JOYWAIT
        MOVE.B  #$16,2(A0)

*---------------------------------------------------------------------

FINISH
        MOVE.L  #$1A0008,-(A7)  TIMER B OFF
        TRAP    #14
        ADDQ.W  #4,A7
 
OLDVBL  MOVE.L  #0,$70.W        RESET VBL VECTOR
 
                JSR     $FC2408         RESET MPF (FC21B4)1040 (FC2408)MEG
                MOVE.B  #3,$FFFFFC00    RESET KYBRD CHIP
                MOVE.B  #$96,$FFFFFC00
                JSR     FLY        
                JSR     MODEL           SET IN MED RES
                LEA     OLDPALL,A1
                JSR     PALL

LOP             MOVE.L  COLORPTR,D0
                TST.W   D0
                BNE.S   LOP

                DC.W    $A009           TURN ON MOUSE
                MOVE.W  #8,$454

                MOVE.L  #ON,-(A7)
                CLR.W   -(A7)
                MOVE.W  #$19,-(A7)      TURN KEYBOARD MOUSE ON
                TRAP    #14
                ADDQ.L  #8,A7

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

JREAD           MOVEQ   #0,D1
                LEA     SPTABLES,A6
                TST.B   NUM(A6)
                BNE     CL             LOAD NEW DIRECITON IN TO STORE
                BTST.B  #7,D1
                BEQ.S   SIJ
                MOVE.B  D1,D2
                CLR.L   D3
                ANDI.B  #3,D2
                BEQ.S   NOINC
                ADDQ    #1,D3
NOINC           MOVE.B  D1,D2
                ANDI.B  #12,D2
                BEQ.S   NOINC1
                ADDQ    #1,D3
NOINC1          CMPI.B  #2,D3
                BNE.S   SIJ
                MOVE.L  #$80,D1 

SIJ             BTST.B  #7,D1
                BEQ.S   NOFIRE
                CMPI.B  #$80,D1
                BNE.S   NOFIRE
                SUBI.B  #1,FIREFLG+1
FIREFLG         MOVEQ   #2,D2
                BEQ.S   NOFIRE
                BCLR    #7,D1
                BRA.S   FIREOK
NOFIRE          MOVE.B  #2,FIREFLG+1
FIREOK          CLR.W   JUMP
                TST.B   D1
                BEQ.S   CL
                MOVE.B  D1,D2
                ANDI.B  #$7F,D1
                ANDI.B  #$80,D2
                CMPI.B  #9,D1
                BNE.S   NB1
                MOVE.B  #1,D1           UP
NB1             CMPI.B  #10,D1
                BNE.S   NB2
                MOVE.B  #8,D1           RIGHT
NB2             CMPI.B  #6,D1
                BNE.S   NB3
                MOVE.B  #2,D1           DOWN
NB3             CMPI.B  #5,D1
                BNE.S   NB4
                MOVE.B  #4,D1           LEFT
NB4             OR.B    D2,D1

                MOVE.B  D1,DIRS(A6)
                MOVE.B  D1,NEWDIR(A6)
DF              TST.B   D1
                BEQ.S   CL
                MOVE.B  #8,NUM(A6)      SET COUNT
CL              RTS

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

READKEY MOVEM.L D0/D1/A0,-(A7)
        LEA     $FFFFFC00,A0
        MOVE.B  (A0),D0
        MOVE.B  2(A0),D0
JKFLG   MOVEQ   #0,D1
        BNE.S   JOYVALS

        CMPI.B  #$FD,D0
        BEQ.S   NEWJOY

        MOVE.B  D0,NOGO+1
        BRA.S   JKDONE

NEWJOY  MOVEQ   #2,D1
        BRA.S   JKDONE

JOYVALS SUBQ.B  #1,D1
        BNE.S   JKDONE

        MOVE.B  D0,JREAD+1
JKDONE  MOVE.B  D1,JKFLG+1
        BCLR    #6,$FFFFFA11
        MOVEM.L (A7)+,D0/D1/A0
        RTE

*-----------------

*       VBL ROUTINE
*       COUNT/MONITOR CHECK/RESET NO. OF LINES FOR DE TIMER B

VBL     MOVE.L  A0,-(A7)
        ADDQ.L  #1,$466.W
        LEA     $FFFFFA1B,A0
        CLR.B   (A0)		STOP TIMER B
        MOVE.B  #10,6(A0)	COUNT 	ENTH
        MOVE.B  #8,(A0)		EVENT COUNT MODWE ACTIVE
        MOVE.L  (A7)+,A0

                SUB.W   #1,TIM
                BNE.S   MONTEST
                MOVE.W  #50,TIM
                TST.W   STOPCLOCK
                BNE.S   MONTEST
                MOVE.W  #1,NUMV7
                ORI.L   #128,NFLAG

MONTEST BTST    #7,$FFFFFA01
        BEQ.S   MONOMON
        RTE
MONOMON MOVE.L  0.W,A7
        MOVE.L  4.W,A0
        JMP     (A0)
 
WAITV           
*               MOVE.L  A6,$45E
                MOVE.W  #$FFFF,-(A7)
                MOVE.L  A6,-(A7)        SCREEN ADD
                MOVE.L  A6,-(A7)
                CALL_EBIOS _setscreen
                ADDA.L  #$C,A7          CLEAR UP
                RTS

**-------------------------------------------------------------------------
*-------------------------------------------------------------------------

MODEL           MOVE.W  MODE,D1         NEW MODE
                MOVE.W  D1,-(A7)
                MOVE.L  #$FFFFFFFF,-(A7)        SCREEN ADD
                MOVE.L  #$FFFFFFFF,-(A7)
                CALL_EBIOS _setscreen
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
                JSR     BYTEXYR         PRINT POS IN A0
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
                LEA     CHRSET,A2
                ADD.L   D0,A2           LETTER TO PRINT
                MOVE.L  A0,A1
                JSR     PRNUM
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

WRITE           MOVE.L  #R1,-(A7)
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
                MOVE.L  #R1,A5          WHERE IN MEMORY TO PLACE FILE
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

FILE            DC.B    "0000000.SML",0        FILE NAME
FILE2           DC.B    "0000000.DAT",0            FILE NAME
FILE3           DC.B    "0000000.SML",0        FILE NAME
FILE1           DC.B    "0000000.SML",0         FILE NAME
FILE4           DC.B    "0000000.SML",0         FILE NAME
FILE5           DC.B    "0000000.SND",0          FILE NAME
FILE6           DC.B    "0000000.MSC",0           FILE NAME

BUFF            DC.B    10,0
LOADFILE        DC.B    "          .DAT",0,0

ER0             DC.B    "INAVLID FUNCTION NUMBER",0
ER1             DC.B    "NO SUCH FILE ",0
ER2             DC.B    "PATHNAME NOT FOUND",0
ER3             DC.B    "TOO MANEY FILES OPEN",0
ER4             DC.B    "ACESS NOT POSSIBLE",0
ER5             DC.B    "INVALID DOOR HANDLE",0
ER6             DC.B    "NOT ENOUGH MEMORY",0
ER7             DC.B    "INVALID MEMORY BLOCK",0
ER8             DC.B    "INVALID DRIVE",0
ER9             DC.B    "NO MORE FILES",0
ER10            DC.B    "UNKNONE ERROR PHONE ME",0
ENDR            DC.B    "ROOM DATA NOT SAVED EXIT PROG Y OR N ",0

TEXT            DC.W    16,104
                DC.B    "NOW ENTERING LEVEL",$FF,$FF
                DC.L      $00980080
LNUM            DC.B    0,0,$FF

                EVEN


DTA             DS.B    44              SPACE FOR DTA BUFFER
LEVBUFF         DS.B    1836

                EVEN

STGR            DS.B    400

                EVEN                    SET EVEN BOUNDRY

                END

