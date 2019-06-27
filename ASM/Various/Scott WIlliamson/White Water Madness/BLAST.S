;------------------------------------------------------------------------------
;                       ANIMATE BALL BUSTERS
;------------------------------------------------------------------------------
;
BBMOVE1:
        BTST       #0,BBFLG1                ;BB FLAG ACTIVE?
        BNE        BBM3                        ;YES
        MOVE.B     SMASHFLG1,D0         ; ONLY SMASH OR BALLBLASTER
        BNE        BBM0
        BTST       #0,STIMER+3
        BNE        BBM1
BBM0:
        RTS                                ;JUST RETURN
BBM1:
        LEA        BBPARM1,A0                ;GET BB PARMS
        MOVE.W     WINDY,D0                ;GET SCREEN WINDOW YCORD
        AND.W      #$FFF0,D0
        ADD.W      #(7*16),D0                ;MOVE DOWN 9 BLOCKS
        MOVE.W     D0,YCORD(A0)                ;SET YCORD
        JSR        FRANDOM
        AND.L      #1,D0
        BNE        BBM2A
        MOVE.W     #$90,D2                        ;FIND WATER CHAR FOR X POSITION
BBM2:
        ADD.W      #16,D2
        CMPI.W     #$1E0,D2                ;SEARCH FROM POSITION 20 TO 30
        BHI        BBM0                        ;SKIP IT
        MOVE.W     D2,D0                        ;SAVE TEMP XCORD
        JSR        FIND_CHAR
        CMPI.W     #236,D0                        ;OVER WATER?
        BHI        BBM2                        ;NO. KEEP SEARCHING
        BRA        BBM2C
BBM2A:
        MOVE.W     #$1F0,D2
BBM2B:
        SUB.W      #16,D2
        CMPI.W     #$90,D2                ;SEARCH FROM POSITION 20 TO 30
        BLS        BBM0                        ;SKIP IT
        MOVE.W     D2,D0                        ;SAVE TEMP XCORD
        JSR        FIND_CHAR
        CMPI.W     #236,D0                        ;OVER WATER?
        BHI        BBM2B                        ;NO. KEEP SEARCHING
BBM2C:
        MOVE.W     D2,XCORD(A0)                ;SET XCORD
        CLR.B      ANIMSEQ(A0)                ;RESET SEQUENCES
        MOVE.B     #1,BBFLG1                ;SET BB FLAG ACTIVE
        JSR        FRANDOM                        ;GET A DIRECTION
        AND.L      #3,D0
        LSL.W      #1,D0
        LEA        BBMOVEMENT,A1                ;GET & SAVE X & Y INCREMENT VALUES
        ADDA.L     D0,A1
        MOVE.W     (A1),BBXINC1
        MOVE.W     8(A1),BBYINC1
        RTS                                ;DONE
BBM3:
        MOVE.L     STIMER,D0
        LSR        #1,D0                        ;DO EVERY OTHER VBLANK
        BCS        BBM0                        ;SKIP THIS TIME
        LEA        BBPARM1,A0                ;GET BB PARMS
        CMPI.B     #7,ANIMSEQ(A0)                ;APPEARANCE SEQUENCES?
        BEQ        BBM4                        ;NO. START FREE SWIMMING TIMER
        BHI        BBM5                        ;NO
        ADDQ.B     #1,ANIMSEQ(A0)                ;YES. SET NEXT SEQUENCE
        RTS                                ;DONE
BBM4:
        MOVE.L     STIMER,D3                ;GET VBLANK COUNT
        ADD.L      #$40,D3                ;ADD $100 FOR BB TIMER
        MOVE.L     D3,BBTIMER1                ;SET BB TIMER
        BRA        BBM7                        ;START SWIMMING
BBM5:
        CMPI.B     #11,ANIMSEQ(A0)                ;FREE SWIMMING?
        BLS        BBM6                        ;YES
        ADDQ.B     #1,ANIMSEQ(A0)                ;NO, OPENING. INC SEQUENCE
        CMP.B      #16,ANIMSEQ(A0)                ;AT MAX OPENING SEQUENCE?
        BEQ        BBM10                        ;YES
        RTS                                ;JUST RETURN
;
BBM6:
        MOVE.L     STIMER,D3                ;GET FREE SWIMMING COUNT
        CMP.L      BBTIMER1,D3                ;ARE WE THERE?
        BLS        BBM7                        ;NO. KEEP SWIMMING
        MOVE.B     #12,ANIMSEQ(A0)                ;YES. SET TO OPEN BALL BLASTER
BBM6A:
        RTS
BBM7:
        ADDQ.B     #1,ANIMSEQ(A0)                ;RAP SWIMMING SEQUENCES FROM 8 TO 11
        CMP.B      #11,ANIMSEQ(A0)
        BLS        BBM8
        MOVE.B     #8,ANIMSEQ(A0)                ;RESET SWIMMING SEQUENCE
BBM8:
        MOVE.W     XCORD(A0),D0                ;GET XCORD
        ADD.W      BBXINC1,D0                ;ADD X INC VALUE
        MOVE.W     D0,D3
        CLR.L      D1
        MOVE.W     YCORD(A0),D1                ;GET YCORD
        ADD.W      BBYINC1,D1                ;ADD Y INC VALUE
        MOVE.W     D1,D4
        JSR        GET_CHAR                ;GET CHAR UNDER SPRITE
;
        CMPI.W     #236,D0                        ;OVER WATER?
        BLS        BBM9                        ;YES. OK TO MOVE
        JSR        FRANDOM                        ;GET A NEW DIRECTION
        AND.L      #3,D0
        LSL.W      #1,D0
        LEA        BBMOVEMENT,A1                ;GET & SAVE X & Y INCREMENT VALUES
        ADDA.L     D0,A1
        MOVE.W     (A1),BBXINC1
        MOVE.W     8(A1),BBYINC1
        BRA        BBM8                        ;SEE IF BB CAN MOVE NOW.
BBM9:
        MOVE.W     D3,XCORD(A0)                ;SAVE NEW XCORD
        MOVE.W     D4,YCORD(A0)                ;SAVE NEW YCORD
        RTS                                ;DONE
;
BBM10:
        CLR.B      BBFLG1                        ;RESET BBFLG1 AS INACTIVE
        CLR.L      D0
        MOVE.W     #7,D0
        LEA        FOUNTFLG1,A1
        LEA        FOUNTPARM1,A2
BBM11:
        MOVE.W     XCORD(A0),XCORD(A2)        ;SET FOUNTAIN XCORDS
        MOVE.W     YCORD(A0),YCORD(A2)        ;SET FOUNTAIN YCORDS
        ADDA.L     #16,A2
        MOVE.B     #1,(A1)+                ;SET FOUNTAIN FLAGS
        DBF        D0,BBM11
        RTS


;------------------------------------------------------------------------------
;                       ANIMATE FOUNTAIN
;------------------------------------------------------------------------------
;
FOUNTAIN:
        LEA        SHIPPARM,A2
        MOVE.W     XCORD(A2),D5
        MOVE.W     D5,D0
        SUBQ       #1,D0
        ADDI.W     #$F,D5
        MOVE.W     YCORD(A2),D6
        MOVE.W     D6,D7
        SUBQ       #1,D7
        ADDI.W     #$F,D6
;
        MOVE.W     WINDY,D1
        MOVE.W     D1,D3
        ADD.W      #(10*16),D3
        MOVE.W     WINDX,D2
        MOVE.W     D2,D4
        ADD.W      #(20*16),D4
        ORI.B      #0,FOUNTFLG1   ;DIRECTION UP
        BEQ        FT2
        LEA        FOUNTPARM1,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT00
        CMP.W      XCORD(A1),D0
        BHI        FT00
        CMP.W      YCORD(A1),D6
        BLS        FT00
        CMP.W      XCORD(A1),D5
        BLS        FT00
        JMP        FTEND
FT00:
;
        SUBQ.W     #4,YCORD(A1)
        BCS        FT0
        CMP.W      YCORD(A1),D1
        BLS        FT2
FT0:
        CLR.B      FOUNTFLG1
;
FT2:
        ORI.B      #0,FOUNTFLG2   ;UP/RIGHT
        BEQ        FT7
        LEA        FOUNTPARM1+16,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT3
        CMP.W      XCORD(A1),D0
        BHI        FT3
        CMP.W      YCORD(A1),D6
        BLS        FT3
        CMP.W      XCORD(A1),D5
        BLS        FT3
        JMP        FTEND
FT3:
;
        SUBQ.W     #3,YCORD(A1)
        BCS        FT6
        CMP.W      YCORD(A1),D1
        BHI        FT6
        ADDQ.W     #3,XCORD(A1)
        BCS        FT6
        CMP.W      XCORD(A1),D4
        BHI        FT7
FT6:
        CLR.B      FOUNTFLG2
;
FT7:
        ORI.B      #0,FOUNTFLG3   ;RIGHT
        BEQ        FT10
        LEA        FOUNTPARM1+32,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT7A
        CMP.W      XCORD(A1),D0
        BHI        FT7A
        CMP.W      YCORD(A1),D6
        BLS        FT7A
        CMP.W      XCORD(A1),D5
        BLS        FT7A
        JMP        FTEND
FT7A:
;
        ADDQ.W     #5,XCORD(A1)
        BCS        FT8
        CMP.W      XCORD(A1),D4
        BHI        FT10
FT8:
        CLR.B      FOUNTFLG3
;
FT10:
        ORI.B      #0,FOUNTFLG4   ;DOWN/RIGHT
        BEQ        FT14
        LEA        FOUNTPARM1+48,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT11
        CMP.W      XCORD(A1),D0
        BHI        FT11
        CMP.W      YCORD(A1),D6
        BLS        FT11
        CMP.W      XCORD(A1),D5
        BLS        FT11
        JMP        FTEND
FT11:
;
        ADDQ.W     #4,XCORD(A1)
        BCS        FT13
        CMP.W      XCORD(A1),D4
        BLS        FT13
        ADDQ.W     #4,YCORD(A1)
        BCS        FT13
        CMP.W      YCORD(A1),D3
        BHI        FT14
FT13:
        CLR.B      FOUNTFLG4
;
FT14:
        ORI.B      #0,FOUNTFLG5   ;DOWN
        BEQ        FT16
        LEA        FOUNTPARM1+64,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT14A
        CMP.W      XCORD(A1),D0
        BHI        FT14A
        CMP.W      YCORD(A1),D6
        BLS        FT14A
        CMP.W      XCORD(A1),D5
        BLS        FT14A
        JMP        FTEND
FT14A:
;
        ADDQ.W     #2,YCORD(A1)
        BCS        FT15
        CMP.W      YCORD(A1),D3
        BHI        FT16
FT15:
        CLR.B      FOUNTFLG5
;
FT16:
        ORI.B      #0,FOUNTFLG6   ;DOWN/LEFT
        BEQ        FT20
        LEA        FOUNTPARM1+80,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT17
        CMP.W      XCORD(A1),D0
        BHI        FT17
        CMP.W      YCORD(A1),D6
        BLS        FT17
        CMP.W      XCORD(A1),D5
        BLS        FT17
        JMP        FTEND
FT17:
;
        ADDQ.W     #3,YCORD(A1)
        BCS        FT19
        CMP.W      YCORD(A1),D3
        BLS        FT19
        SUBQ.W     #3,XCORD(A1)
        BCS        FT19
        CMP.W      XCORD(A1),D2
        BLS        FT20
FT19:
        CLR.B      FOUNTFLG6
;
FT20:
        ORI.B      #0,FOUNTFLG7   ;LEFT
        BEQ        FT22
        LEA        FOUNTPARM1+96,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT20A
        CMP.W      XCORD(A1),D0
        BHI        FT20A
        CMP.W      YCORD(A1),D6
        BLS        FT20A
        CMP.W      XCORD(A1),D5
        BLS        FT20A
        JMP        FTEND
FT20A:
;
        SUBQ.W     #4,XCORD(A1)
        BCS        FT21
        CMP.W      XCORD(A1),D2
        BLS        FT22
FT21:
        CLR.B      FOUNTFLG7
;
FT22:
        ORI.B      #0,FOUNTFLG8   ;UP/LEFT
        BEQ        FT24
        LEA        FOUNTPARM1+112,A1
;
        CMP.W      YCORD(A1),D7
        BHI        FT22A
        CMP.W      XCORD(A1),D0
        BHI        FT22A
        CMP.W      YCORD(A1),D6
        BLS        FT22A
        CMP.W      XCORD(A1),D5
        BLS        FT22A
        JMP        FTEND
FT22A:
;
        SUBQ.W     #2,XCORD(A1)
        BCS        FT23
        CMP.W      XCORD(A1),D2
        BHI        FT23
        SUBQ.W     #2,YCORD(A1)
        BCS        FT23
        CMP.W      YCORD(A1),D1
        BLS        FT24
FT23:
        CLR.B      FOUNTFLG8
FT24:
        RTS

;------------------------------------------------------------------------------
;                      KILL 8 FOUNTAIN FLAGS/INIT EXPLOSION
;------------------------------------------------------------------------------
;
FTEND:
        LEA        FOUNTFLG1,A1
        CLR.L      (A1)+
        CLR.L      (A1)
FTEND2:
        MOVE.B     #1,EXPFLG1
        LEA        EXPLPARM1,A1
        CLR.B      ANIMSEQ(A1)
        MOVE.W     XCORD(A2),XCORD(A1)
        MOVE.W     YCORD(A2),YCORD(A1)
        CLR     SNDDMAC
        MOVE    #1,SNDDMAC
        SUB     #20,LIFE
        RTS

;------------------------------------------------------------------------------
;                           ANIMATE GENERIC EXPLOSION
;------------------------------------------------------------------------------
;
EXPLOSION:
        ORI.B      #0,EXPFLG1                ;EXPLOSION FLAG ACTIVE?
        BEQ        EXPDONE
        MOVE.L     STIMER,D0
        LSR        #1,D0
        BCS        EXPDONE
        LEA        EXPLPARM1,A1
        ADDQ.B     #1,ANIMSEQ(A1)
        CMPI.B     #4,ANIMSEQ(A1)
        BLS        EXPDONE
        CLR.B      EXPFLG1
EXPDONE:
        RTS
;
    END
 