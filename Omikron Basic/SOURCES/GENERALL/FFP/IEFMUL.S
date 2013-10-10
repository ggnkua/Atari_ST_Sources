       TTL     IEEE FORMAT EQUIVALENT MULTIPLY (IEFMUL)
***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************
 
*************************************************************
*                       IEFMUL                              *
*  FAST FLOATING POINT IEEE FORMAT EQUIVALENT MULTIPLY      *
*                                                           *
*  IEFMUL - IEEE FORMAT EQUIVALENT FLOATING POINT MULTIPLY  *
*                                                           *
*  INPUT:  D6 - IEEE FORMAT NUMBER MULTIPLIER (SOURCE)      *
*          D7 - IEEE FORMAT NUMBER MULTIPLICAN (DESTINATION)*
*                                                           *
*  OUTPUT: D7 - IEEE FORMAT FLOATING RESULT OF REGISTER D6  *
*               MULTIPLIED BY REGISTER D7                   *
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
*        MAXIMUM STACK USED:   24 BYTES                     *
*                                                           *
*  RESULT MATRIX:            ARG 2                          *
*                NORMALIZED  ZERO       INF        NAN      *
*     ARG 1      ****************************************   *
*   NORMALIZED   *   A    *    B    *    C     *    F   *   *
*   ZERO         *   B    *    B    *    D     *    F   *   *
*   INFINITY     *   C    *    D    *    C     *    F   *   *
*   NAN          *   E    *    E    *    E     *    F   *   *
*                ****************************************   *
*               (DENORMALIZED VALUES ARE TREATED AS ZEROES) *
*       A = RETURN MULTIPLY RESULT, OVERFLOW TO INFINITY,   *
*           UNDERFLOW TO ZERO                               *
*       B = RETURN ZERO                                     *
*       C = RETURN INFINITY                                 *
*       D = RETURN NEWLY CREATED NAN (NOT-A-NUMBER) FOR     *
*           ILLEGAL OPERATION
*       E = RETURN ARG1 (NAN) UNCHANGED                     *
*       F = RETURN ARG2 (NAN) UNCHANGED                     *
*                                                           *
*  NOTES:                                                   *
*    1) ZEROES AND INFINITIES ARE RETURNED WITH PROPER      *
*       SIGN (EXCLUSIVE OR OF INPUT ARGUMENT SIGN BITS).    *
*    2) SEE THE MC68344 USER'S GUIDE FOR A DESCRIPTION OF   *
*       THE POSSIBLE DIFFERENCES BETWEEN THE RESULTS        *
*       RETURNED HERE VERSUS THOSE REQUIRED BY THE          *
*       IEEE STANDARD.                                      *
*                                                           *
*************************************************************
         PAGE
IEFMUL IDNT    1,1  IEEE FORMAT EQUIVALENT MULTIPLY
 
         OPT       PCS
 
         XDEF      IEFMUL    IEEE FORMAT EQUIVALENT MULTIPLY
 
         XREF      9:IEFDOP  DOUBLE ARGUMENT CONVERSION ROUTINE
         XREF      9:IEFRTNAN CREATE AND RETURN NAN RESULT ROUTINE
         XREF      9:IEFTIEEE RETURN AND CONVERT BACK TO IEEE FORMAT
         XREF      9:IEFRTIE  RETURN SIGNED INFINITY EXCLUSIVE OR'ED
         XREF      9:IEFRTSZE RETURN SIGNED ZERO EXCLUSIVE OR'ED
         XREF      9:FFPMUL2   REFERENCE FFP PERFECT PRECISION MULTIPLY ROUTINE
       XREF    FFPCPYRT        COPYRIGHT NOTICE
 
         SECTION  9
 
***********************************************
* IEEE FORMAT EQUIVALENT MULTIPLY ENTRY POINT *
***********************************************
IEFMUL   BSR       IEFDOP    DECODE BOTH OPERANDS
         BRA.S     IEFNRM    +0 BRANCH NORMALIZED
         BRA.S     IEFINF2   +2 BRANCH ONLY ARG2 INFINITY
         BRA.S     IEFINF1   +4 BRANCH ONLY ARG1 INFINITY
* BOTH INFINITY, RETURN PROPER SIGN     +6 BOTH ARE INFINITY
IEFRTINF BRA       IEFRTIE   RETURNE INFINITY WITH PROPER SIGN
 
* ARG1 INFINITY - SWAP ARGUMENTS AND TREAT AS ARG2
IEFINF1  EXG.L     D6,D7     SWAP FOR NEXT CODE PORTION
 
* ARG2 INFINITY - IF OPPOSITE ARGUMENT IS ZERO THAN ILLEGAL AND RETURN NAN
IEFINF2  TST.L     D6        ? IS OPPOSITE ARGUMENT A ZERO
         BNE.S     IEFRTINF  NO, GO RETURN INFINITY WITH PROPER SIGN
         BRA       IEFRTNAN  YES, RETURN A NAN FOR THIS ILLEGAL OPERATION
 
* NORMALIZED NUMBERS(OR ZERO) - DO THE MULTIPLY
IEFNRM   BSR       FFPMUL2   DO FAST FLOATING POINT ADD
         BNE       IEFTIEEE  CONVERT RESULT BACK TO IEEE FORMAT
 
* RESULT IS ZERO SO RETURN ZERO WITH PROPER SIGN
         BRA       IEFRTSZE  RETURN ZERO WITH EXCLUSIVELY OR'ED SIGNED
 
         END
