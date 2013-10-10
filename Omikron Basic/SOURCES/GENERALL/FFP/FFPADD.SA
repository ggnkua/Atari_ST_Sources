       TTL     FAST FLOATING POINT ADD/SUBTRACT (FFPADD/FFPSUB)
***************************************
* (C) COPYRIGHT 1980 BY MOTOROLA INC. *
***************************************
 
*************************************************************
*                  FFPADD/FFPSUB                            *
*             FAST FLOATING POINT ADD/SUBTRACT              *
*                                                           *
*  FFPADD/FFPSUB - FAST FLOATING POINT ADD AND SUBTRACT     *
*                                                           *
*  INPUT:                                                   *
*      FFPADD                                               *
*          D6 - FLOATING POINT ADDEND                       *
*          D7 - FLOATING POINT ADDER                        *
*      FFPSUB                                               *
*          D6 - FLOATING POINT SUBTRAHEND                   *
*          D7 - FLOATING POINT MINUEND                      *
*                                                           *
*  OUTPUT:                                                  *
*          D7 - FLOATING POINT ADD RESULT                   *
*                                                           *
*  CONDITION CODES:                                         *
*          N - RESULT IS NEGATIVE                           *
*          Z - RESULT IS ZERO                               *
*          V - OVERFLOW HAS OCCURED                         *
*          C - UNDEFINED                                    *
*          X - UNDEFINED                                    *
*                                                           *
*           REGISTERS D3 THRU D5 ARE VOLATILE               *
*                                                           *
*  CODE SIZE: 228 BYTES       STACK WORK AREA:  0 BYTES     *
*                                                           *
*  NOTES:                                                   *
*    1) ADDEND/SUBTRAHEND UNALTERED (D6).                   *
*    2) UNDERFLOW RETURNS ZERO AND IS UNFLAGGED.            *
*    3) OVERFLOW RETURNS THE HIGHEST VALUE WITH THE         *
*       CORRECT SIGN AND THE 'V' BIT SET IN THE CCR.        *
*                                                           *
*  TIME: (8 MHZ NO WAIT STATES ASSUMED)                     *
*                                                           *
*           COMPOSITE AVERAGE  20.625 MICROSECONDS          *
*                                                           *
*  ADD:         ARG1=0              7.75 MICROSECONDS       *
*               ARG2=0              5.25 MICROSECONDS       *
*                                                           *
*          LIKE SIGNS  14.50 - 26.00  MICROSECONDS          *
*                    AVERAGE   18.00  MICROSECONDS          *
*         UNLIKE SIGNS 20.13 - 54.38  MICROCECONDS          *
*                    AVERAGE   22.00  MICROSECONDS          *
*                                                           *
*  SUBTRACT:    ARG1=0              4.25 MICROSECONDS       *
*               ARG2=0              9.88 MICROSECONDS       *
*                                                           *
*          LIKE SIGNS  15.75 - 27.25  MICROSECONDS          *
*                    AVERAGE   19.25  MICROSECONDS          *
*         UNLIKE SIGNS 21.38 - 55.63  MICROSECONDS          *
*                    AVERAGE   23.25  MICROSECONDS          *
*                                                           *
*************************************************************
         PAGE
FFPADD IDNT    1,1  FFP ADD/SUBTRACT
 
       XDEF    FFPADD,FFPSUB   ENTRY POINTS
       XREF    FFPCPYRT        COPYRIGHT NOTICE
 
         SECTION  9
 
************************
* SUBTRACT ENTRY POINT *
************************
FFPSUB   MOVE.B  D6,D4    TEST ARG1
         BEQ.S   FPART2   RETURN ARG2 IF ARG1 ZERO
         EOR.B   #$80,D4  INVERT COPIED SIGN OF ARG1
         BMI.S   FPAMI1   BRANCH ARG1 MINUS
* + ARG1
         MOVE.B  D7,D5    COPY AND TEST ARG2
         BMI.S   FPAMS    BRANCH ARG2 MINUS
         BNE.S   FPALS    BRANCH POSITIVE NOT ZERO
         BRA.S   FPART1   RETURN ARG1 SINCE ARG2 IS ZERO
 
*******************
* ADD ENTRY POINT *
*******************
FFPADD   MOVE.B  D6,D4    TEST ARGUMENT1
         BMI.S   FPAMI1   BRANCH IF ARG1 MINUS
         BEQ.S   FPART2   RETURN ARG2 IF ZERO
 
* + ARG1
         MOVE.B  D7,D5    TEST ARGUMENT2
         BMI.S   FPAMS    BRANCH IF MIXED SIGNS
         BEQ.S   FPART1   ZERO SO RETURN ARGUMENT1
 
* +ARG1 +ARG2
* -ARG1 -ARG2
FPALS    SUB.B   D4,D5    TEST EXPONENT MAGNITUDES
         BMI.S   FPA2LT   BRANCH ARG1 GREATER
         MOVE.B  D7,D4    SETUP STRONGER S+EXP IN D4
 
* ARG1EXP <= ARG2EXP
         CMP.B   #24,D5   OVERBEARING SIZE
         BCC.S   FPART2   BRANCH YES, RETURN ARG2
         MOVE.L  D6,D3    COPY ARG1
         CLR.B   D3       CLEAN OFF SIGN+EXPONENT
         LSR.L   D5,D3    SHIFT TO SAME MAGNITUDE
         MOVE.B  #$80,D7  FORCE CARRY IF LSB-1 ON
         ADD.L   D3,D7    ADD ARGUMENTS
         BCS.S   FPA2GC   BRANCH IF CARRY PRODUCED
FPARSR   MOVE.B  D4,D7    RESTORE SIGN/EXPONENT
         RTS              RETURN TO CALLER
 
* ADD SAME SIGN OVERFLOW NORMALIZATION
FPA2GC   ROXR.L  #1,D7    SHIFT CARRY BACK INTO RESULT
         ADD.B   #1,D4    ADD ONE TO EXPONENT
         BVS.S   FPA2OS   BRANCH OVERFLOW
         BCC.S   FPARSR   BRANCH IF NO EXPONENT OVERFLOW
FPA2OS   MOVEQ   #-1,D7   CREATE ALL ONES
         SUB.B   #1,D4    BACK TO HIGHEST EXPONENT+SIGN
         MOVE.B  D4,D7    REPLACE IN RESULT
*        OR.B    #$02,CCR SHOW OVERFLOW OCCURRED
         DC.L    $003C0002 ****ASSEMBLER ERROR****
         RTS              RETURN TO CALLER
 
* RETURN ARGUMENT1
FPART1   MOVE.L  D6,D7    MOVE IN AS RESULT
         MOVE.B  D4,D7    MOVE IN PREPARED SIGN+EXPONENT
         RTS              RETURN TO CALLER
 
* RETURN ARGUMENT2
FPART2   TST.B   D7       TEST FOR RETURNED VALUE
         RTS              RETURN TO CALLER
 
* -ARG1EXP > -ARG2EXP
* +ARG1EXP > +ARG2EXP
FPA2LT   CMP.B   #-24,D5  ? ARGUMENTS WITHIN RANGE
         BLE.S   FPART1   NOPE, RETURN LARGER
         NEG.B   D5       CHANGE DIFFERENCE TO POSITIVE
         MOVE.L  D6,D3    SETUP LARGER VALUE
         CLR.B   D7       CLEAN OFF SIGN+EXPONENT
         LSR.L   D5,D7    SHIFT TO SAME MAGNITUDE
         MOVE.B  #$80,D3  FORCE CARRY IF LSB-1 ON
         ADD.L   D3,D7    ADD ARGUMENTS
         BCS.S   FPA2GC   BRANCH IF CARRY PRODUCED
         MOVE.B  D4,D7    RESTORE SIGN/EXPONENT
         RTS              RETURN TO CALLER
 
* -ARG1
FPAMI1   MOVE.B  D7,D5    TEST ARG2'S SIGN
         BMI.S   FPALS    BRANCH FOR LIKE SIGNS
         BEQ.S   FPART1   IF ZERO RETURN ARGUMENT1
 
* -ARG1 +ARG2
* +ARG1 -ARG2
FPAMS    MOVEQ   #-128,D3  CREATE A CARRY MASK ($80)
         EOR.B   D3,D5    STRIP SIGN OFF ARG2 S+EXP COPY
         SUB.B   D4,D5    COMPARE MAGNITUDES
         BEQ.S   FPAEQ    BRANCH EQUAL MAGNITUDES
         BMI.S   FPATLT   BRANCH IF ARG1 LARGER
* ARG1 <= ARG2
         CMP.B   #24,D5   COMPARE MAGNITUDE DIFFERENCE
         BCC.S   FPART2   BRANCH ARG2 MUCH BIGGER
         MOVE.B  D7,D4    ARG2 S+EXP DOMINATES
         MOVE.B  D3,D7    SETUP CARRY ON ARG2
         MOVE.L  D6,D3    COPY ARG1
FPAMSS   CLR.B   D3       CLEAR EXTRANEOUS BITS
         LSR.L   D5,D3    ADJUST FOR MAGNITUDE
         SUB.L   D3,D7    SUBTRACT SMALLER FROM LARGER
         BMI.S   FPARSR   RETURN FINAL RESULT IF NO OVERFLOW
 
* MIXED SIGNS NORMALIZE
FPANOR   MOVE.B  D4,D5    SAVE CORRECT SIGN
FPANRM   CLR.B   D7       CLEAR SUBTRACT RESIDUE
         SUB.B   #1,D4    MAKE UP FOR FIRST SHIFT
         CMP.L   #$00007FFF,D7 ? SMALL ENOUGH FOR SWAP
         BHI.S   FPAXQN   BRANCH NOPE
         SWAP.W  D7       SHIFT LEFT 16 BITS REAL FAST
         SUB.B   #16,D4   MAKE UP FOR 16 BIT SHIFT
FPAXQN   ADD.L   D7,D7    SHIFT UP ONE BIT
         DBMI    D4,FPAXQN DECREMENT AND BRANCH IF POSITIVE
         EOR.B   D4,D5    ? SAME SIGN
         BMI.S   FPAZRO   BRANCH UNDERFLOW TO ZERO
         MOVE.B  D4,D7    RESTORE SIGN/EXPONENT
         BEQ.S   FPAZRO   RETURN ZERO IF EXPONENT UNDERFLOWED
         RTS              RETURN TO CALLER
 
* EXPONENT UNDERFLOWED - RETURN ZERO
FPAZRO   MOVEQ.L #0,D7    CREATE A TRUE ZERO
         RTS              RETURN TO THE CALLER
 
* ARG1 > ARG2
FPATLT   CMP.B   #-24,D5  ? ARG1 >> ARG2
         BLE.S   FPART1   RETURN IT IF SO
         NEG.B   D5       ABSOLUTIZE DIFFERENCE
         MOVE.L  D7,D3    MOVE ARG2 AS LOWER VALUE
         MOVE.L  D6,D7    SETUP ARG1 AS HIGH
         MOVE.B  #$80,D7  SETUP ROUNDING BIT
         BRA.S   FPAMSS   PERFORM THE ADDITION
 
* EQUAL MAGNITUDES
FPAEQ    MOVE.B  D7,D5    SAVE ARG1 SIGN
         EXG.L   D5,D4    SWAP ARG2 WITH ARG1 S+EXP
         MOVE.B  D6,D7    INSURE SAME LOW BYTE
         SUB.L   D6,D7    OBTAIN DIFFERENCE
         BEQ.S   FPAZRO   RETURN ZERO IF IDENTICAL
         BPL.S   FPANOR   BRANCH IF ARG2 BIGGER
         NEG.L   D7       CORRECT DIFFERENCE TO POSITIVE
         MOVE.B  D5,D4    USE ARG2'S SIGN+EXPONENT
         BRA.S   FPANRM   AND GO NORMALIZE
 
 
         END
