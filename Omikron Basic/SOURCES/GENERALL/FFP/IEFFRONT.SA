         TTL       IEEE FORMAT FRONT-END ROUTINES (IEFFRONT)
IEFFRONT IDNT   1,1  IEEE FORMAT EQUIVALENT FRONT-END ROUTINES
******************************************
*  (C)  COPYRIGHT 1981 BY MOTOROLA INC.  *
******************************************
*  MODIFIED TO BE USABLE ON M68010  6/25/85 MBODINE
 
*******************************************************
*               IDFSOP (INTERNAL SUBROUTINE)          *
*     IEEE FORMAT EQUIVALENT PROCESS SINGLE OPERAND   *
*                                                     *
*  INPUT:   D7 - IEEE FORMAT NUMBER ARGUMENT2         *
*           SP -> +0 RETURN ADDRESS TO CALLER         *
*                 +4 ORIGINAL CALLER'S RETURN ADDRESS *
*                                                     *
*  OUTPUT:  D6 CONVERTED TO FAST FLOATING POINT       *
*           FORMAT WITH USER'S ORIGINAL REGISTERS     *
*           D3-D7 STACKED OR A DIRECT RETURN BYPASSING*
*           THE FIRST-LINE ROUTINE IF EITHER          *
*           PARAMETER WAS A NAN                       *
*                                                     *
*                                                     *
*     RETURN IS VIA VECTORED BRANCH WITH OFFSET ADDED *
*     TO THE ADDRESS ON THE STACK.  THIS ALLOWS EASY  *
*     TYPE DESCRIMINATION BY THE CALLER FOR SELECTED  *
*     DATA TYPES:                                     *
*                                                     *
*   RETURN  +0   IF THE ARGUMENT IS NORMALIZED        *
*                (INCLUDING ZERO AND DENORMALIZED)    *
*           +2   IF ARGUMENT IS AN INFINITY           *
*                                                     *
*   THE STACK APPEARS:  S+0  ORIGINAL D3-D7 UPON ENTRY*
*                       S+20 ORIGINAL CALLER'S RETURN *
*                                                     *
*  CONDITION CODES:                                   *
*                                                     *
*       (ONLY IF BYPASSED RETURN DONE)                *
*                                                     *
*            N - UNDEFINED                            *
*            Z - CLEARED                              *
*            V - SET (RESULT IS A NAN)                *
*            C - UNDEFINED                            *
*            X - UNDEFINED                            *
*                                                     *
*       (ONLY IF RETURN TO IMMEDIATE CALLER)          *
*                                                     *
*            N - SET IF VALUE IS NEGATIVE             *
*            Z - SET IF VALUE IS A ZERO               *
*            V - UNDEINFED                            *
*            C - UNDEFINED                            *
*            X - UNDEFINED                            *
*                                                     *
*  THIS ROUTINE IS A FRONT END FOR THE IEEE FORMAT    *
*  CAPATIBLE ROUTINES (IEF ROUTINES).  IT MAY         *
*  BYPASS THE CALLER TO DIRECTLY RETURN TO THE USER   *
*  CODE IF THE ARGUMENT IS A NAN (NOT-A-NUMBER)       *
*  SINCE THE RESULT MUST BE A NAN (THE SAME).         *
*  THE CALL TO THIS ROUTINE MUST BE THE               *
*  FIRST INSTRUCTION OF THE LEVEL-1 IEF ROUTINE,      *
*  SINCE IT MAY RETURN DIRECTLY TO THE ORIGINAL       *
*  CALLER.  ALSO REGISTERS MUST BE UNALTERED BEFORE   *
*  THE CALL.                                          *
*                                                     *
*  LOGIC:  THE FOLLOWING DECISION TREE SHOWS THE      *
*          PROCESSING FOR THIS ROUTINE AND WHAT       *
*          VALUES ARE RETURNED FOR THE ARGUMENT       *
*                                                     *
*   IF ARG IS NAN THEN                                *
*         SET THE "V" BIT IN THE CCR AND BYPASS THE   *
*         CALLER RETURNING WITH ARG (D7) UNCHANGED    *
*                                                     *
*   IF ARG IS AN INFINITY THEN ADJUST RETURN ADDRESS  *
*         AND RETURN WITH CCR SET FOR PLUS OR MINUS   *
*         AT OFFSET +2                                *
*                                                     *
*   IF ARG IS DENORMALIZED THEN SET IT TO ZERO        *
*        ELSE IT IS NORMALIZED - CONVERT TO FFP FORMAT*
*                                                     *
*   RETURN TO CALLER AT +0 OFFSET                     *
*                                                     *
*  NOTES:                                             *
*  1) DURING THE CONVERSION OF NORMALIZED IEEE FORMAT *
*     NUMBERS TO FFP FORMAT, THE EXPONENT MAY BE TOO  *
*     LARGE FOR FFP MAGNITUDES.  WHEN THIS IS TRUE    *
*     THEN THE VALUE IS CONVERTED TO AN INFINITY WITH *
*     THE PROPER SIGN.  IF THE EXPONENT IS TOO SMALL  *
*     THAN A ZERO IS RETURNED.  SEE THE MC68344 USER'S*
*     GUIDE FOR COMPLETE DETAILS OF THE RANGE HANDLING*
*     OF THE FAST FLOATING POINT FORMAT CONVERSION.   *
*  2) ALL ZEROES ARE TREATED AS POSITIVE VALUES.      *
*  3) DENORMALIZED VALUES ARE TREATED AS ZEROES.      *
*                                                     *
*******************************************************
 
         SECTION   9
         OPT       P=68010
 
         XDEF      IEFSOP    SINGLE OPERAND CONVERT
 
EXPMSK   EQU       $7F800000 IEEE FORMAT EXPONENT MASK
VBIT     EQU       $0002     CONDITION CODE "V" BIT MASK
CBIT     EQU       $0001     CONDITION CODE "C" BIT MASK
 
* CALL INTERNAL SUBROUTINE TO PARSE ARGUMENT (D7)
IEFSOP   LEA       -16(SP),SP ADJUST STACK FOR NEW RETURN ADDRESS POSITION
         MOVE.L    16(SP),-(SP) MOVE RETURN ADDRESS TO NEW LOCATION
         MOVEM.L   D3-D7,4(SP) SAVE ORIGINAL CALLER'S REGISTERS
         BSR.S     IEFPRSE   CONVERT ARGUMENT TWO
         BCC.S     IEFARGS   BRANCH NOT INFINITY
         MOVE.W    CCR,D5     SAVE CCR
         ADD.L     #2,(SP)   ADJUST RETURN ADDRESS
         MOVE.W    D5,CCR    RESTORE CCR
IEFARGS  RTS                 RETURN TO CALLER AT PROPER OFFSET
         PAGE
*******************************************************
*               IDFDOP (INTERNAL SUBROUTINE)          *
*     IEEE FORMAT EQUIVALENT PROCESS DOUBLE OPERAND   *
*                                                     *
*  INPUT:   D6 - IEEE FORMAT NUMBER ARGUMENT1         *
*           D7 - IEEE FORMAT NUMBER ARGUMENT2         *
*           SP -> +0 RETURN ADDRESS TO CALLER         *
*                 +4 ORIGINAL CALLER'S RETURN ADDRESS *
*                                                     *
*  OUTPUT:  D6/D7 CONVERTED TO FAST FLOATING POINT    *
*           FORMAT WITH USER'S ORIGINAL REGISTERS     *
*           D3-D7 STACKED OR A DIRECT RETURN BYPASSING*
*           THE FIRST-LINE ROUTINE IF EITHER          *
*           PARAMETER WAS A NAN                       *
*                                                     *
*                                                     *
*     RETURN IS VIA VECTORED BRANCH WITH OFFSET ADDED *
*     TO THE ADDRESS ON THE STACK.  THIS ALLOWS EASY  *
*     TYPE DESCRIMINATION BY THE CALLER FOR SELECTED  *
*     DATA TYPES:                                     *
*                                                     *
*   RETURN  +0   IF BOTH ARGUMENTS NORMALIZED         *
*                (INCLUDING ZERO AND DENORMALIZED)    *
*           +2   IF ARG2 IS AN INFINITY               *
*           +4   IF ARG1 IS AN INFINITY               *
*           +6   IF BOTH ARGUMENTS ARE INFINITIES     *
*                                                     *
*   THE STACK APPEARS:  S+0  ORIGINAL D3-D7 UPON ENTRY*
*                       S+20 ORIGINAL CALLER'S RETURN *
*                                                     *
*  CONDITION CODES:                                   *
*                                                     *
*      (ONLY IF BYPASSED RETURN DONE)                 *
*                                                     *
*            N - UNDEFINED                            *
*            Z - CLEARED                              *
*            V - SET (RESULT IS A NAN)                *
*            C - UNDEFINED                            *
*            X - UNDEFINED                            *
*                                                     *
*      (ONLY IF RETURN DIRECTLY TO IMMEDIATE CALLER)  *
*                                                     *
*            N - SET IF ARG1 IS NEGATIVE              *
*            Z - SET IF ARG1 IS ZERO                  *
*            V - UNDEFINED                            *
*            C - SET IF ARG1 IS AN INFINITY           *
*            X - UNDEFINED                            *
*                                                     *
*  THIS ROUTINE IS A FRONT END FOR THE IEEE FORMAT    *
*  CAPATIBLE ROUTINES (IEF ROUTINES).  IT MAY         *
*  BYPASS THE CALLER TO DIRECTLY RETURN TO THE USER   *
*  CODE IF AN ARGUMENT IS A NAN (NOT-A-NUMBER)        *
*  SINCE THE RESULT MUST BE A NAN.  IT MUST BE THE    *
*  FIRST INSTRUCTION OF THE LEVEL-1 IEF ROUTINE,      *
*  SINCE IT MAY RETURN DIRECTLY TO THE ORIGINAL       *
*  CALLER.  ALSO REGISTERS MUST BE UNALTERED BEFORE   *
*  THE CALL.                                          *
*                                                     *
*  LOGIC:  THE FOLLOWING DECISION TREE SHOWS THE      *
*          PROCESSING FOR THIS ROUTINE AND WHAT       *
*          VALUES ARE RETURNED FOR ARG1 AND ARG2      *
*                                                     *
*   IF ARG2 IS NAN THEN                               *
*         SET THE "V" BIT IN THE CCR AND BYPASS THE   *
*         CALLER RETURNING WITH ARG2 (D7) UNCHANGED   *
*                                                     *
*   IF ARG1 IS NAN THEN                               *
*         SET THE "V" BIT IN THE CCR AND BYPASS THE   *
*         CALLER RETURNING WITH ARG1 COPIED TO ARG2   *
*                                                     *
*   IF ARG2 IS AN INFINITY THEN ADJUST RETURN ADDRESS *
*                                                     *
*   IF ARG1 IS AN INFINITY THEN ADJUST RETURN ADDRESS *
*                                                     *
*   IF ARG2 IS DENORMALIZED THEN SET IT TO ZERO       *
*        ELSE IT IS NORMALIZED - CONVERT TO FFP FORMAT*
*                                                     *
*   IF ARG1 IS DENORMALIZED THEN SET IT TO ZERO       *
*        ELSE IT IS NORMALIZED - CONVERT TO FFP FORMAT*
*                                                     *
*   RETURN TO CALLER AT PROPER OFFSET                 *
*                                                     *
*  NOTES:                                             *
*  1) DURING THE CONVERSION OF NORMALIZED IEEE FORMAT *
*     NUMBERS TO FFP FORMAT, THE EXPONENT MAY BE TOO  *
*     LARGE FOR FFP MAGNITUDES.  WHEN THIS IS TRUE    *
*     THEN THE VALUE IS CONVERTED TO AN INFINITY WITH *
*     THE PROPER SIGN.  IF THE EXPONENT IS TOO SMALL  *
*     THAN A ZERO IS RETURNED.  SEE THE MC68344 USER'S*
*     GUIDE FOR COMPLETE DETAILS OF THE RANGE         *
*     TREATMENT BY THE FAST FLOATING POINT CONVERSION.*
*  2) ALL ZEROES ARE TREATED AS POSITIVE VALUES.      *
*  3) DENORMALIZED VALUES ARE TREATED AS ZEROES.      *
*                                                     *
*******************************************************
 
         SECTION   9
 
         XDEF      IEFDOP    DUAL OPERAND CONVERT
 
* CALL INTERNAL SUBROUTINE TO PARSE ARGUMENT 2 (D7)
IEFDOP   LEA       -16(SP),SP RESET STACK FOR REGISTER STORAGE
         MOVE.L    16(SP),-(SP) MOVE RETURN ADDRESS TO NEW BOTTOM OF STACK
         MOVEM.L   D3-D7,4(SP) SAVE ORIGINAL REGISTERS ABOVE RETURN ADDRESS
         BSR.S     IEFPRSE   CONVERT ARGUMENT TWO
         BCC.S     IEFARG2   BRANCH NOT INFINITY
         ADD.L     #2,(SP)   ADJUST RETURN ADDRESS
IEFARG2  EXG.L     D6,D7     SWAP ARGUMENTS TO CONVERT ARG1 (NAN RETURNS ARG1)
         BSR.S     IEFPRSE   CONVERT SECOND ARGUMENT
         BCC.S     IEFNOTI   BRANCH NOT INFINITY
         MOVE.W    CCR,D5     SAVE CCR
         ADD.L     #4,(SP)   ADJUST RETURN ADDRESS
         MOVE.W    D5,CCR    RESTORE CCR
IEFNOTI  EXG.L     D6,D7     SWAP ARGUMENTS BACK INTO PLACE
         RTS                 RETURN TO CALLER
         PAGE
*
* INTERNAL CONVERT SUBROUTINE
*   CONVERT THE ARGUMENT IN D7 TO FAST FLOATING POINT FORMAT AND RETURN
*   CCR SET FOR TEST AGAINST SIGN AND ZERO
*
* OUTPUT:
*         IF NAN - DIRECT RETURN BYPASSING CALLER WITH NAN IN D7 AND "V" SET
*           ELSE RETURN WITH CONVERTED VALUE AND "C" BIT IF IS AN INFNITY
*
IEFPRSE  MOVE.L    D7,D5     SAVE ORIGINAL ARGUMENT
         SWAP.W    D7        SWAP WORD HALVES
         ROR.L     #7,D7     EXPONENT TO LOW BYTE
         EOR.B     #$80,D7     CONVERT FROM EXCESS 127 TO TWO'S-COMPLEMENT
         ADD.B     D7,D7     FROM 8 TO 7 BIT EXPONENT
         BVS.S     IEFOVF    BRANCH WILL NOT FIT
         ADD.B     #2<<1+1,D7 ADJUST EXCESS 127 TO 64 AND SET MANTISSA HIGH BIT
         BVS.S     IEFEXH    BRANCH EXPONENT TOO LARGE (OVERFLOW)
         EOR.B     #$80,D7     BACK TO EXCESS 64
         ROR.L     #1,D7     TO FAST FLOAT REPRESENTATION
         TST.B     D7        CLEAR CARRY
         RTS                 RETURN TO CALLER
 
* OVERFLOW DETECTED - CAUSED BY ONE OF THE FOLLOWING:
*        - FALSE EXPONENT OVERFLOW DUE TO DIFFERENCE IN EXCESS NOTATIONS
*        - EXPONENT TOO HIGH OR LOW TO FIT IN 7 BITS (EXPONENT OVER/UNDERFLOW)
*        - AN EXPONENT OF $FF REPRESENTING AN INFINITY
*        - AN EXPONENT OF $00 REPRESENTING A ZERO, NAN, OR DENORMALIZED VALUE
IEFOVF   BCC.S     IEFOVLW   BRANCH IF OVERFLOW (EXPONENT $FF OR TOO LARGE)
* CHECK FOR FALSE OVERFLOW
         CMP.B     #$7C,D7   ? WILL CORRECTED VALUE BE OK
         BEQ.S     IEFFOV    YES, BRANCH IF FALSE OVERFLOW
         CMP.B     #$7E,D7   ? WILL CORRECTED VALUE BE IN RANGE
         BNE.S     IEFNOTF   NO, BRANCH NOT FALSE OVERFLOW
IEFFOV   ADD.B     #$80+2<<1+1,D7 BACK TO EXCESS 64 AND SET MANTISSA HIGH BIT
         ROR.L     #1,D7     TO FAST FLOATING POINT REPRESENTATION
         TST.B     D7        INSURE NOT ILLEGAL ZERO SIGN+EXPONENT BYTE
         BNE.S     IEFCRT    NO, IS OK SO RETURN "C" CLEARED
* EXPONENT LOW - IS ZERO, DENORMALIZED VALUE, OR TOO SMALL AN EXPONENT
IEFNOTF  MOVE.L    #0,D7     RETURN ZERO FOR ALL OF THESE CASES ("C" CLEARED)
IEFCRT   RTS                 RETURN TO CALLER
 
* EXPONENT HIGH - CHECK FOR EXPONENT TOO HIGH, INFINITY, OR NAN
IEFOVLW  CMP.B     #$FE,D7   ? WAS ORIGINAL EXPONENT $FF
         BNE.S     IEFEXH    NO, BRANCH EXPONENT TOO LARGE
         LSR.L     #8,D7     SHIFT OUT EXPONENT
         LSR.L     #1,D7     SHIFT SIGN OUT INTO "X" BIT
         BEQ.S     IEFEXHI   BRANCH IF TRUE INFINITY
 
* ARG2 IS A NAN - BYPASS CALLER AND RETURN AS THE RESULT WITH "V" BIT SET
         MOVE.L    D5,D7     RETURN ORIGINAL ARGUMENT
         ADD.L     #8,SP     SKIP INTERNAL AND CALLER RETURN ADDRESSES
         MOVEM.L   (SP)+,D3-D6 RETURN REGISTERS INTACT
         ADD.L     #4,SP     SKIP ORIGINAL D7
         OR.B      #VBIT,SR  SET V BIT ON
         RTS                 RETURN TO ORIGINAL CALLER
 
* ARG2 IS INFINITY OR EXPONENT TOO LARGE SO FORCE TO INFINITY (SIGN IS BIT 8)
IEFEXH   LSL.W     #8,D7     SET "X" CCR BIT SAME AS SIGN
IEFEXHI  MOVE.L    #EXPMSK<<1,D7 SET EXPONENT ALL ONES FOR INFINITY AND OVER 1
         ROXR.L    #1,D7     SHIFT SIGN AND AND FINISHED RESULT
         OR.B      #CBIT,SR  SET "C" BIT ON FOR INFINITY NOTICE
         RTS                 RETURN TO CONVERSION ROUTINE
 
         END
