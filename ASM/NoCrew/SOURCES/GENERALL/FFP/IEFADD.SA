       TTL     IEEE FORMAT EQUIVALENT ADD/SUBTRACT (IEFADD/IEFSUB)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************
*  MODIFIED TO BE USABLE ON M68010  6/25/85 MBODINE
 
*************************************************************
*                     IEFADD/IEFSUB                         *
*  FAST FLOATING POINT IEEE FORMAT EQUIVALENT ADD/SUBTRACT  *
*                                                           *
*  IEFADD - IEEE FORMAT EQUIVALENT FLOATING POINT ADDITION  *
*                                                           *
*  INPUT:  D6 - IEEE FORMAT NUMBER ADDEND (SOURCE)          *
*          D7 - IEEE FORMAT NUMBER ADDER  (DESTINATION)     *
*                                                           *
*  IEFSUB - IEEE FORMAT EQUIVALENT FLOATING POINT SUBTRACT  *
*                                                           *
*  INPUT:  D6 - IEEE FORMAT NUMBER SUBTRAHEND (SOURCE)      *
*          D7 - IEEE FORMAT NUMBER MINUEND (DESTINATION)    *
*                                                           *
*  OUTPUT: D7 - IEEE FORMAT FLOATING RESULT OF REGISTER D6  *
*               ADDED OR SUBTRACTED FROM REGISTER D7        *
*                                                           *
*  CONDITION CODES:                                         *
*          N - RESULT IS NEGATIVE                           *
*          Z - RESULT IS ZERO                               *
*          V - RESULT IS NAN (NOT-A-NUMBER)                 *
*          C - UNDEFINED                                    *
*          X - UNDEFINED                                    *
*                                                           *
*           ALL REGISTERS TRANSPARENT                       *
*                                                           *
*        MAXIMUM USED STACK:    28 BYTES                    *
*                                                           *
*  RESULT MATRIX:            ARG 2                          *
*                  OTHERS    +INF      -INF        NAN      *
*     ARG 1      ****************************************   *
*   OTHERS       *   A    *    B    *    C     *    F   *   *
*   +INFINITY    *   B    *    B    *    D     *    F   *   *
*   -INFINITY    *   C    *    D    *    C     *    F   *   *
*   NAN          *   E    *    E    *    E     *    F   *   *
*                ****************************************   *
*       A = RETURN ADDITION OR SUBTRACTION RESULT,          *
*           OVERFLOWING TO INFINITY, UNDERFLOWING TO ZERO   *
*       B = RETURN PLUS INFINITY                            *
*       C = RETURN MINUS INFINITY                           *
*       D = RETURN NEWLY CREATED NAN (NOT-A-NUMBER)         *
*       E = RETURN ARG1 (NAN) UNCHANGED                     *
*       F = RETURN ARG2 (NAN) UNCHANGED                     *
*                                                           *
*  NOTES:                                                   *
*    1) FOR SUBTRACTION, THE SIGN OF THE SOURCE IS          *
*       INVERTED AND THEN THE OPERATION IS TREATED AS       *
*       AN ADDITION USING THE DECISION MATRIX ABOVE.        *
*    2) SEE THE MC68344 USER'S GUIDE FOR A DESCRIPTION OF   *
*       THE POSSIBLE DIFFERENCES BETWEEN THE RESULTS        *
*       RETURNED HERE VERSUS THOSE REQUIRED BY THE          *
*       IEEE STANDARD.                                      *
*                                                           *
*************************************************************
         PAGE
IEFADD IDNT    1,1  IEEE FORMAT EQUIVALENT ADD/SUBTRACT
 
         OPT       PCS,P=68010
 
         XDEF      IEFADD    IEEE FORMAT ADDITION
         XDEF      IEFSUB    IEEE FORMAT SUBTRACTION
 
         XREF      9:IEFDOP  DOUBLE ARGUMENT CONVERSION ROUTINE
         XREF      9:IEFRTNAN CREATE AND RETURN NAN RESULT ROUTINE
         XREF      9:IEFRTD7  RETURN CONTENTS OF D7 AS THE RESULT
         XREF      9:IEFRTSZ  RETURN SIGNED ZERO WITH SIGN OF D7
         XREF      9:IEFTIEEE RETURN AND CONVERT BACK TO IEEE FORMAT
         XREF      9:FFPADD    REFERENCE FAST FLOATING POINT ADD ROUTINE
       XREF    FFPCPYRT        COPYRIGHT NOTICE
 
         SECTION  9
 
************************
* SUBTRACT ENTRY POINT *
************************
IEFSUB   BCHG.L    #31,D6    INVERT SIGN OF SECOND ARGUMENT FOR SUBTRACT
         BSR.S     IEFADD    AND CALL ADD ROUTINE
         MOVE.W    CCR,-(SP)  SAVE CCR OF RESULT ON THE STACK
         BCHG.L    #31,D6    REVERT SIGN BACK TO ORIGINAL CONDITION
         RTR                 RETURN WITH RESULT AND CONDITION CODES
 
*******************
* ADD ENTRY POINT *
*******************
IEFADD   BSR       IEFDOP    DECODE BOTH OPERANDS
         BRA.S     IEFNRM    +0 BRANCH NORMALIZED
         BRA.S     IEFINF2   +2 BRANCH ARG2 INFINITY
         BRA.S     IEFINF1   +4 BRANCH ARG1 INFINITY
* TEST FOR OPPOSITE SIGNS               +6 BOTH ARE INFINITY
         EOR.L     D6,D7     EXCLUSIVE OR SIGNS
         BMI       IEFRTNAN  OPPOSITE SIGNS - GO RETURN A NAN
*                                      OTHERWISE BOTH SAME AND RETURN SAME
 
* ARG1 INFINITY - RETURN IT
IEFINF1  MOVE.L    D6,D7     RETURN ARG1
* ARG2 INFINITY - RETURN IT (ALREADY IN D7)
IEFINF2  BRA       IEFRTD7   RETURN D7 AS OUR RESULT
 
* NORMALIZED NUMBERS - DO THE ADDITION
IEFNRM   BSR       FFPADD    DO FAST FLOATING POINT ADD
         BNE       IEFTIEEE  CONVERT RESULT BACK TO IEEE FORMAT
 
* RESULT IS ZERO - RETURN WITH PROPER SIGN FOR RN (ROUND-TO-NEAREST)
         MOVEM.L   (SP),D3-D7  RELOAD ARGUMENTS (AND REST OF REGISTERS)
         AND.L     D6,D7     RETURN MINUS ONLY IF BOTH MINUS
         BRA       IEFRTSZ   RETURN SIGNED ZERO WITH SIGN OF D7
 
         END
