*************** INITIALISE ROUTINES **************

*       MOUSE OFF,JOYSTK OFF

START   MOVE.L  #KEYSET,-(A7)
        MOVE.L  #$190001,-(A7)  MOFF,JOFF USING ikbdws
        TRAP    #14
        ADDQ    #8,A7
        DC.W    $A000   INIT LINE A
        DC.W    $A00A   REMOVE MOUSE

*       SAVE OLD SR AND SSP AND ENTER SUPERVISOR MODE

        MOVE.L  A7,OLDUSP+2
        MOVE.W  SR,OLDSR+2
        MOVE.L  A7,-(A7)
        MOVE.W  #$20,-(A7)      CALL super
        TRAP    #1
        MOVE.L  D0,OLDSSP+2

*************** MAIN PROGRAM **************

*       LOAD THE PICTURE

LOADFILE        BSR     OPENFILE
        TST.W   D0
        BMI     EXIT
        MOVE.L  $44E.W,READFILE+2
        MOVE.L  #128,FLENGTH+2
        BSR     READFILE
        TST.L   D0
        BMI     EXIT
        MOVE.L  $44E.W,A0
        ADDQ    #4,A0
        MOVEQ   #7,D0
        LEA     $FFFF8240.W,A1
.LOOP   MOVE.L  (A0)+,(A1)+
        DBF     D0,.LOOP
        MOVE.L  $44E.W,A0
        MOVE.L  #32000,FLENGTH+2
        BSR     READFILE
        TST.L   D0
        BMI     EXIT
        BSR     CLOSEFILE

        CLR.W   $468.W
.WAIT   CMPI.W  #100,$468.W
        BNE.S   .WAIT

        MOVE.L  $70.W,OLDVBL+2
        MOVE.L  #MYVBL,$70.W

.WAIT1  CMPI.W  #4500,$468.W
        BNE.S   .WAIT1

OLDVBL  MOVE.L  #0,$70.W

*       RESTORE OPERATING SYSTEM AND EXIT

EXIT    MOVE.L  #KEYS1,-(A7)
        MOVE.L  #$190003,-(A7)  RESET KYBRD,MOFF,JOFF
        TRAP    #14
        ADDQ    #8,A7
        DC.W    $A009   PUT MOUSE BACK
OLDSSP  MOVE.L  #0,A7
OLDSR   MOVE.W  #0,SR
OLDUSP  MOVE.L  #0,A7
        CLR.W   -(A7)
        TRAP    #1

*       SUBROUTINE TO OPEN A FILE NB. NAME IN CHARBUFF

OPENFILE        MOVE.W  #2,-(A7)        OPEN FILE
LOADNAME        PEA     FILENAME
        MOVE.W  #$3D,-(A7)
        TRAP    #1
        MOVE.W  D0,FHANDLE+2
        ADDQ    #8,A7
        RTS

*       SUBROUTINE TO READ FROM A FILE NB. FHANDLE+2 SET UP

READFILE        PEA     0       LOAD ADDRESS
FLENGTH PEA     40000   LENGTH
FHANDLE MOVE.W  #0,-(A7)
        MOVE.W  #$3F,-(A7)      LOAD FILE
        TRAP    #1
        ADDA.W  #12,A7
        RTS

*       SUBROUTINE TO CLOSE A FILE NB. FHANDLE+2 SET UP

CLOSEFILE       MOVE.W  FHANDLE+2,-(A7) CLOSE FILE
        MOVE.W  #$3E,-(A7)
        TRAP    #1
        ADDQ    #4,A7
        RTS

*       SUBROUTINE TO CREATE A FILE NB. NAME IN CHARBUFF

CREATEFILE      MOVE.W  #0,-(A7)
SAVENAME        PEA     0
        MOVE.W  #$3C,-(A7)
        TRAP    #1
        MOVE.W  D0,FHANDLE+2
        ADDQ    #8,A7
        RTS

*       SUBROUTINE TO WRITE TO A FILE NB. FHANDLE+2 SET UP

WRITEFILE       PEA     0       SAVE ADDRESS
        MOVE.L  FLENGTH+2,-(A7) LENGTH TO SAVE
        MOVE.W  FHANDLE+2,-(A7)
        MOVE.W  #$40,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
        RTS

*       VBL ROUTINE

MYVBL   MOVE.W  D0,-(A7)
        ADDQ.L  #1,$466.W
        MOVE.W  #$EFF,D0
.LOOP1  DBF     D0,.LOOP1
        MOVE.W  #$3FF,D0
.LOOP2  MOVE.B  #3,$FFFF820A.W
        NOP
        NOP
        NOP
        MOVE.B  #2,$FFFF820A.W
        NOP
        NOP
        DBF     D0,.LOOP2
        MOVE.W  (A7)+,D0
        RTE

        
KEYS1   DC.B    $80,1   RESET KEY READ STATE
KEYSET  DC.B    $12,$1A MOUSE OFF,JOYSTICK OFF

FILENAME        DC.B    "STEVE.NEO",0

        END
