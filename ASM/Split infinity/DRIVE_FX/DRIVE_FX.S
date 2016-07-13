*******************************************************************
*                                                                 *
* Published in the Ledgers Disk Magazine Volume 8                 *
*                                           Release Date : 1/2/92 *
*                                                                 *
*******************************************************************

* DRIVE FX DEMO BY THE TITAN OF SPLIT INFINITY.....
* RE-VAMPED BY PRONTO......(MUSIC CHANGE)
* MUSIC BY MAD MAX

*********************************************************************************************

        DC.W $A00A                              ;MOUSE OFF

        CLR.L -(SP)                             ;STICK IN SUPERVISOR MODE
        MOVE.W #$20,-(SP)
        TRAP #1
        ADDQ.L #6,SP
        MOVE.L D0,STACK                         ;STORE STACK
        MOVE.L USP,A0                           ;INSTALL USER STACK
        MOVE.L A0,USTACK                        



        MOVE.W #5,-(SP)
        MOVE.W #26,-(SP)
        TRAP #14
        ADDQ.L #4,SP


        PEA MOUSE                               ;MOUSE OFF PLEASE
        MOVE.W #1,-(SP)
        MOVE.W #25,-(SP)
        TRAP #14
        ADDQ.L #8,SP


        MOVEQ #1,D0                             ;SETUP MUSIC
        JSR MUSIC
        MOVE.B #1,MUS_NO                        ;MUSIC 1

        MOVE.W #$2700,SR                        
        MOVE.L $70,OVBL                         ;SAVE OLD VBL
        MOVE.L #VBL,$70                         ;INSTALL NEW VBL
        MOVE.W #$2300,SR


*********************************************************************************************

DEADLOP:
        CMP.B #0,(FLAG)                         ;TEST FOR KEYPRESS
        BEQ DEADLOP                             ;NO,THEN RE-LOOP
        MOVE.B #0,(FLAG)                        ;YES,THEN RESET FLAG

        CMP.B #$02,$FFFC02                      ;1 PRESSED
        BEQ   _1                                ;YES,CHANGE MUSIC TO 1

        CMP.B #$03,$FFFC02                      ;2 PRESSED
        BEQ   _2                                ;YES,CHANGE MUSIC TO 2

        CMP.B #$04,$FFFC02                      ;3 PRESSED
        BEQ   _3                                ;YES,CHANGE MUSIC TO 3

        CMP.B #$05,$FFFC02                      ;4 PRESSED
        BEQ   _4                                ;YES,CHANGE MUSIC TO 4


        CMP.B #$39,$FFFC02                      ;SPACE PRESSED
        BNE DEADLOP                             ;NO,THEN RE-LOOP
                                                ;OTHERWISE EXIT.


*********************************************************************************************

EXIT:   MOVE.W #$2700,SR                        ;RE-INSTALL
        MOVE.L OVBL,$70                         ;OLD VBL
        MOVE.W #$2300,SR


        MOVE.W #5,-(SP)
        MOVE.W #27,-(SP)
        TRAP #14
        ADDQ.L #4,SP


        MOVE.L #$8080000,$FF8800                ;TURN ALL SOUND OFF
        MOVE.L #$9090000,$FF8800
        MOVE.L #$A0A0000,$FF8800

        PEA MOUSE+2                             ;DISPLAY MOUSE CURSOR
        MOVE.W #1,-(SP)
        MOVE.W #25,-(SP)
        TRAP #14
        ADDQ.L #8,SP


        MOVE.L USTACK,A0                        ;RE-INSTALL OLD STACK
        MOVE.L A0,USP
        MOVE.L STACK,-(SP)
        MOVE.W #$20,-(SP)
        TRAP #1
        ADDQ.L #6,SP

        MOVE.W #0,-(SP)                         ;AND EXIT
        TRAP #1

*********************************************************************************************
;NOT REALLY NEEDED TO PLAY MUSIC,BUT IS NEEDED TO CHANGE MUSIC.


_1:     CMPI.B  #1,MUS_NO                       ;IS 1 CURRENT MUSIC
        BEQ     DEADLOP                         ;YES,DON'T CHANGE.
        
        MOVE.B  #1,D0                           ;NEW MUSIC NUMBER
        JSR     MUSIC                           ;AND CHANGE
        
        MOVE.B  #1,MUS_NO                       ;SET MUSIC NUMBER TO 1
        BRA     DEADLOP                         ;RETURN

_2:     CMPI.B  #2,MUS_NO                       ;IS 2 CURRENT MUSIC
        BEQ     DEADLOP                         ;YES,DON'T CHANGE.
        
        MOVE.B  #2,D0                           ;NEW MUSIC NUMBER
        JSR     MUSIC                           ;AND CHANGE

        MOVE.B  #2,MUS_NO                       ;SET MUSIC NUMBER TO 2
        BRA     DEADLOP                         ;RETURN

_3:     CMPI.B  #3,MUS_NO                       ;IS 3 CURRENT MUSIC
        BEQ     DEADLOP                         ;YES,DON'T CHANGE.

        MOVE.B  #3,D0                           ;NEW MUSIC NUMBER
        JSR     MUSIC                           ;AND CHANGE

        MOVE.B  #3,MUS_NO                       ;SET MUSIC NUMBER TO 3
        BRA     DEADLOP                         ;RETURN

_4:     CMPI.B  #4,MUS_NO                       ;IS CURRENT MUSIC 4
        BEQ     DEADLOP                         ;YES,DON'T CHANGE

        MOVE.B  #4,D0                           ;NEW MUSIC NUMBER
        JSR     MUSIC                           ;AND CHANGE

        MOVE.B  #4,MUS_NO                       ;SET MUSIC NUMBER TO 4
        BRA     DEADLOP                         ;RETURN

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*~*~~~~~~~~~
;FOLLOWING NOT NEEDED TO PLAY MUSIC,EXCEPT FOR THE LABEL 'VBL'.

VBL:                                            
;THE DRIVE FX CODE

        CMPI.B  #1,MUS_NO                       ;IS CURRENT MUSIC 1
        BEQ     _1_                             ;YES,THEN SET UP FOR 1

        CMPI.B  #2,MUS_NO                       ;IS CURRENT MUSIC 2
        BEQ     _2_                             ;YES THEN SET UP FOR 2

        CMPI.B  #3,MUS_NO                       ;IS CURRENT MUSIC 3
        BEQ     _34_                            ;YES THEN SET UP FOR 3&4

        CMPI.B  #4,MUS_NO                       ;IS CURRENT MUSIC 4
        BEQ     _34_                            ;YES THEN SET UP FOR 3&4


_1_     MOVE.B #7,$FF8800                       ;TEST TO SEE IF VOICE
        BTST #5,$FF8800                         ;IS ON(V 3)
        BNE LOFF                                ;NO,THEN LIGHT OFF
        BRA  LON                                ;ELSE ON

_2_     MOVE.B #7,$FF8800                       ;TEST TO SEE IF VOICE
        BTST #3,$FF8800                         ;IS ON(V 1) 
        BNE LOFF                                ;NO,THEN LIGHT OFF
        BRA LON                                 ;ELSE ON

_34_    MOVE.B #7,$FF8800                       ;TEST TO SEE IF VOICE
        BTST #4,$FF8800                         ;IS ON(V 2)
        BNE LOFF                                ;NO,THEN LIGHT OFF ELSE ON

LON     MOVE.B #$E,$FFFF8800.W                  ;TURN DISK DRIVE
        MOVE.B #$4,$FFFF8802.W                  ;LIGHT ON
        BRA LREST

LOFF    MOVE.B #$E,$FFFF8800.W                  ;TURN DISK DRIVE
        MOVE.B #$3,$FFFF8802.W                  ;LIGHT OFF

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*~*~~~~~~~~~

LREST:  JSR MUSIC+8                             ;PLAY MUSIC


        MOVE.B #1,(FLAG)                        ;SET FLAG TO 1
        RTE                                     ;RETURN FROM EXCEPTION
 
*************** DATA IN DE AREA (THE REVENGE OF!!!) **********************************
MUS_NO: DC.W    1                               ;MUSIC NUMBER

FLAG:   DC.B 0                                  ;FLAG
        EVEN

SCR:    EQU $78000                              ;ADDRESS OF SCREEN

STACK:  DC.L 0                                  ;OLD STACK
USTACK: DC.L 0                                  ;USERS STACK

OVBL:   DC.L 0                                  ;OLD VBL

MOUSE:  DC.B $12,$1A,$14,8                      ;MOUSE SET UP
        EVEN

SYSPAL: DC.W $777,$700,$070,$000,$007,$707,$007,$555    ;SYSTEM PALETTE
        DC.W $333,$733,$373,$773,$337,$737,$377,$000

MUSIC:  INCBIN A:\MAX.MUZ            ;MUSIC TO LOAD
        EVEN

        END
