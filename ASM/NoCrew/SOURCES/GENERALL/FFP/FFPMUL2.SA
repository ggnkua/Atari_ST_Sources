         TTL       FAST FLOATING POINT PRECISE MULTIPLY (FFPMUL2)
*******************************************
* (C)  COPYRIGHT 1980 BY MOTOROLA INC.    *
*******************************************
 
********************************************
*          FFPMUL2 SUBROUTINE              *
*                                          *
*   THIS MODULE IS THE SECOND OF THE       *
*   MULTIPLY ROUTINES.  IT IS 18% SLOWER   *
*   BUT PROVIDES THE HIGHEST ACCURACY      *
*   POSSIBLE.  THE ERROR IS EXACTLY .5     *
*   LEAST SIGNIFICANT BIT VERSUS AN ERROR  *
*   IN THE HIGH-SPEED DEFAULT ROUTINE OF   *
*   .50390625 LEAST SIGNIFICANT BIT DUE    *
*   TO TRUNCATION.                         *
*                                          *
* INPUT:                                   *
*          D6 - FLOATING POINT MULTIPLIER  *
*          D7 - FLOATING POINT MULTIPLICAN *
*                                          *
* OUTPUT:                                  *
*          D7 - FLOATING POINT RESULT      *
*                                          *
* REGISTERS D3 THRU D5 ARE VOLATILE        *
*                                          *
* CONDITION CODES:                         *
*          N - SET IF RESULT NEGATIVE      *
*          Z - SET IF RESULT IS ZERO       *
*          V - SET IF OVERFLOW OCCURRED    *
*          C - UNDEFINED                   *
*          X - UNDEFINED                   *
*                                          *
* CODE: 134 BYTES    STACK WORK: 0 BYTES   *
*                                          *
* NOTES:                                   *
*   1) MULTIPIER UNALTERED (D6).           *
*   2) UNDERFLOWS RETURN ZERO WITH NO      *
*      INDICATOR SET.                      *
*   3) OVERFLOWS WILL RETURN THE MAXIMUM   *
*      VALUE WITH THE PROPER SIGN AND THE  *
*      'V' BIT SET IN THE CCR.             *
*                                          *
*  TIMES: (8MHZ NO WAIT STATES ASSUMED)    *
* ARG1 ZERO            5.750 MICROSECONDS  *
* ARG2 ZERO            3.750 MICROSECONDS  *
* MINIMUM TIME OTHERS 45.750 MICROSECONDS  *
* MAXIMUM TIME OTHERS 61.500 MICROSECONDS  *
* AVERAGE OTHERS      52.875 MICROSECONDS  *
*                                          *
********************************************
       PAGE
FFPMUL2  IDNT  1,1 FFP HIGH-PRECISION MULTIPLY
 
       XDEF     FFPMUL2      ENTRY POINT
       XREF     FFPCPYRT     COPYRIGHT NOTICE
 
       SECTION   9
 
 
* FFPMUL2 SUBROUTINE ENTRY POINT
FFPMUL2 MOVE.B D7,D5     PREPARE SIGN/EXPONENT WORK       4
       BEQ.S  FFMRTN    RETURN IF RESULT ALREADY ZERO    8/10
       MOVE.B D6,D4     COPY ARG1 SIGN/EXPONENT          4
       BEQ.S  FFMRT0    RETURN ZERO IF ARG1=0            8/10
       ADD.W  D5,D5     SHIFT LEFT BY ONE                4
       ADD.W  D4,D4     SHIFT LEFT BY ONE                4
       MOVEQ  #-128,D3  PREPARE EXPONENT MODIFIER ($80)  4
       EOR.B  D3,D4     ADJUST ARG1 EXPONENT TO BINARY   4
       EOR.B  D3,D5     ADJUST ARG2 EXPONENT TO BINARY   4
       ADD.B  D4,D5     ADD EXPONENTS                    4
       BVS.S  FFMOUF    BRANCH IF OVERFLOW/UNDERFLOW     8/10
       MOVE.B D3,D4     OVERLAY $80 CONSTANT INTO D4     4
       EOR.W  D4,D5     D5 NOW HAS SIGN AND EXPONENT     4
       ROR.W  #1,D5     MOVE TO LOW 8 BITS               8
       SWAP.W D5        SAVE FINAL S+EXP IN HIGH WORD    4
       MOVE.W D6,D5     COPY ARG1 LOW BYTE               4
       CLR.B  D7        CLEAR S+EXP OUT OF ARG2          4
       CLR.B  D5        CLEAR S+EXP OUT OF ARG1 LOW BYTE 4
       MOVE.W D5,D4     PREPARE ARG1LOWB FOR MULTIPLY    4
       MULU.W D7,D4     D4 = ARG2LOWB X ARG1LOWB         38-54 (46)
       SWAP.W D4        PLACE RESULT IN LOW WORD         4
       MOVE.L D7,D3     COPY ARG2                        4
       SWAP.W D3        TO ARG2HIGHW                     4
       MULU.W D5,D3     D3 = ARG1LOWB X ARG2HIGHW        38-54 (46)
       ADD.L  D3,D4     D4 = PARTIAL PRODUCT (NO CARRY)  8
       SWAP.W D6        TO ARG1 HIGH TWO BYTES           4
       MOVE.L D6,D3     COPY ARG1HIGHW OVER              4
       MULU.W D7,D3     D3 = ARG2LOWB X ARG1HIGHW        38-54 (46)
       ADD.L  D3,D4     D4 = PARTIAL PRODUCT             8
       CLR.W  D4        CLEAR LOW END RUNOFF             4
       ADDX.B D4,D4     SHIFT IN CARRY IF ANY            4
       SWAP.W D4        PUT CARRY INTO HIGH WORD         4
       SWAP.W D7        NOW TOP OF ARG2                  4
       MULU.W D6,D7     D7 = ARG1HIGHW X ARG2HIGHW       40-70 (54)
       SWAP.W D6        RESTORE ARG1                     4
       SWAP.W D5        RESTORE S+EXP TO LOW WORD
       ADD.L  D4,D7     ADD PARTIAL PRODUCTS             8
       BPL    FFMNOR    BRANCH IF MUST NORMALIZE         8/10
       ADD.L  #$80,D7   ROUND UP (CANNOT OVERFLOW)       16
       MOVE.B D5,D7     INSERT SIGN AND EXPONENT         4
       BEQ.S  FFMRT0    RETURN ZERO IF ZERO EXPONENT     8/10
FFMRTN RTS              RETURN TO CALLER                 16
 
* MUST NORMALIZE RESULT
FFMNOR SUB.B   #1,D5    BUMP EXPONENT DOWN BY ONE        4
       BVS.S   FFMRT0   RETURN ZERO IF UNDERFLOW         8/10
       BCS.S   FFMRT0   RETURN ZERO IF SIGN INVERTED     8/10
       MOVEQ   #$40,D4  ROUNDING FACTOR                  4
       ADD.L   D4,D7    ADD IN ROUNDING FACTOR           8
       ADD.L   D7,D7    SHIFT TO NORMALIZE               8
       BCC.S   FFMCLN   RETURN NORMALIZED NUMBER         8/10
       ROXR.L  #1,D7    ROUNDING FORCED CARRY IN TOP BIT 10
       ADD.B   #1,D5    UNDO NORMALIZE ATTEMPT           4
FFMCLN MOVE.B  D5,D7    INSERT SIGN AND EXPONENT         4
       BEQ.S   FFMRT0   RETURN ZERO IF EXPONENT ZERO     8/10
       RTS              RETURN TO CALLER                 16
 
* ARG1 ZERO
FFMRT0 MOVE.L #0,D7     RETURN ZERO                      4
       RTS              RETURN TO CALLER                 16
 
* OVERFLOW OR UNDERFLOW EXPONENT
FFMOUF BPL.S  FFMRT0    BRANCH IF UNDERFLOW TO GIVE ZERO 8/10
       EOR.B  D6,D7     CALCULATE PROPER SIGN            4
       OR.L   #$FFFFFF7F,D7 FORCE HIGHEST VALUE POSSIBLE 16
       TST.B  D7        SET SIGN IN RETURN CODE
*        ORI.B   #$02,CCR                            SET OVERFLOW BIT
       DC.L   $003C0002 ****SICK ASSEMBLER****           20
       RTS              RETURN TO CALLER                 16
 
       END
