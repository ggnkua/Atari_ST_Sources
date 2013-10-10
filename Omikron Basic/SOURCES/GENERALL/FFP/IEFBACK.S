         TTL       IEEE FORMAT EQUIVALENT BACK-END ROUTINES (IEFBACK)
IEFBACK  IDNT   1,1  IEEE FORMAT EQUIVALENT BACK-END ROUTINES
******************************************
*  (C)  COPYRIGHT 1981 BY MOTOROLA INC.  *
******************************************
 
         SECTION   9
 
****************************************************************
*              IEFRTNAN (INTERNAL ROUTINE)                     *
*  IEEE FORMAT EQUIVALENT FAST FLOATING POINT RETURN NAN       *
*                                                              *
*  INPUT: SP -> +0  ORIGINAL CALLERS D3-D7 REGISTERS           *
*              +20  ORIGINAL CALLERS RETURN ADDRESS            *
*                                                              *
*  OUTPUT: D7 - A NEWLY CREATED NAN (NOT-A-NUMBER)             *
*          CCR - THE "V" BIT IS FORCED ON                      *
*                                                              *
*          AND DIRECT RETURN TO THE ORIGINAL CALLER            *
*                                                              *
*  PURPOSE:  CALLED WHENEVER THE RESULT OF AN OPERATION        *
*          IS ILLEGAL OR UNDEFINED AND A NAN RESULT MUST       *
*          BE GENERATED AS THE FINAL RESULT.                   *
*                                                              *
*   THE IEEE FORMAT DEFINED NAN IS DETERMINED BY AN EXPONENT   *
*   OF ALL ONE'S AND A NON-ZERO SIGNIFICAND.  THE SIGN BIT     *
*   IS A DON'T CARE.  THE IEEE STANDARD LEAVES UP TO EACH      *
*   IMPLEMENTATION WHAT IS PLACED IN THE SIGNIFICAND.  HERE    *
*   WE WILL GENERATE THE LOW ORDER 23 BITS OF THE ORIGINAL     *
*   CALLER'S RETURN ADDRESS.  HOWEVER, THIS MAY NOT BE         *
*   SUFFICIENT - IF ALL 23 BITS HAPPEN TO BE ZERO OR THE       *
*   ADDRESS IS LARGER THAN 23 BITS THIS WOULD LEAD TO AN       *
*   INCORRECT RESULT.  THERFORE, IF THIS HAPPENS ONLY THE LOW  *
*   ORDER SIGNIFICAND BIT IS SET ON WITH THE REST ZEROES.      *
*   THIS REPRESENTS AN ODD ADDRESS (ILLEGAL WITH CURRENT M68000*
*   INSTRUCTION ALIGNMENT RESTRICTIONS) AND ANY INTERESTED     *
*   PARTY CAN TELL IF SUCH A SUBSTITUTION HAS TAKEN PLACE.     *
*   ALSO, IF THIS WAS ILLEGALLY ASSUMED TO BE AN ADDRESS AND   *
*   USED, AN ADDRESS EXCEPTION TRAP WOULD ENSUE THUS NOT       *
*   ALLOWING ITS USE AS A VALID ADDRESS.                       *
*                                                              *
****************************************************************
 
SIGNMSK  EQU       $80000000 IEEE FORMAT SIGN ISOLATION MASK
EXPMSK   EQU       $7F800000 IEEE FORMAT EXPONENT MASK
VBIT     EQU       $0002     CONDITION CODE "V" BIT MASK
ZBIT     EQU       $0004     CONDITION CODE "Z" BIT MASK
 
         XDEF      IEFRTNAN  RETURN NAN RESULT ROUTINE
 
IEFRTNAN MOVEM.L   (SP)+,D3-D7         RESTORE CALLERS REGISTERS
         MOVE.L    (SP),D7             LOAD UP RETURN ADDRESS
         AND.L     #SIGNMSK+EXPMSK,D7  VERIFY NOT LARGER THAN 23 BITS
         BNE.S     IEFNONE             IT IS, CANNOT USE IT - RETURN A ONE
         MOVE.L    (SP),D7             LOAD UP RETURN ADDRESS
         AND.L     #$007FFFFF,D7       ISOLATE ADDRESS BITS REQUIRED
         BNE.S     IEFNZRO             BRANCH IF NOT ZERO
IEFNONE  MOVE.L    #1,D7               SET ONLY LOW BIT ON
IEFNZRO  OR.L      #EXPMSK,D7          FORCE EXPONENT ALL ONES
         OR.B      #VBIT,SR            RETURN WITH "V" BIT SET
         RTS                           RETURN TO ORIGINAL CALLER
         PAGE
**********************************************************
*           IEFTIEEE (INTERNAL SUBROUTINE)               *
*  IEEE FORMAT COMPATIBLE CONVERT FFP TO IEEE FORMAT     *
*                                                        *
*  INPUT: D7 - RESULT OF FAST FLOATING POINT OPERATION   *
*         CCR - SET FOR ABOVE RESULT                     *
*         SP -> +0  ORIGINAL CALLERS SAVED D3-D7         *
*              +20  ORIGINAL CALLERS RETURN ADDRESS      *
*                                                        *
*  OUTPUT: D7 - IEEE FORMAT EQUIVALENT OF THE RESULT     *
*                                                        *
*  CONDITION CODE:                                       *
*                                                        *
*              N - SET IF THE RESULT IS NEGATIVE         *
*              Z - SET IF THE RESULT IS ZERO             *
*              V - CLEARED (NOT NAN)                     *
*              C - CLEARED                               *
*              X - UNDEFINED                             *
*                                                        *
*    ALL FAST FLOATING POINT NUMBERS HAVE AN EXACT       *
*    IEEE FORMAT REPRESENTATION.  SINCE THE FAST         *
*    FLOATING POINT ROUTINES ALWAYS SET THE "V" BIT      *
*    FOR OVERFLOWS AND RETURNS THE PROPER SIGN, WE       *
*    CAN EASILY CHANGE THE RESULT TO AN IEEE INFINITY    *
*    AND UNFLAG THE "V" BIT.                             *
*                                                        *
**********************************************************
 
         XDEF      IEFTIEEE  RETURN IEEE RESULT TO ORIGINAL CALLER
 
IEFTIEEE BVS.S     IEFVSET   BRANCH IF OVERFLOW FFP RESULT
         ADD.L     D7,D7     DELETE MANTISSA HIGH BIT
         BEQ.S     IEFTRTN   BRANCH ZERO AS FINISHED
         EOR.B     #$80,D7   TO TWOS COMPLEMENT EXPONENT
         ASR.B     #1,D7     FORM 8-BIT EXPONENT
         SUB.B     #$82,D7   ADJUST 64 TO 127 AND EXCESSIZE
         SWAP.W    D7        SWAP FOR HIGH BYTE PLACEMENT
         ROL.L     #7,D7     SET SIGN+EXP IN HIGH BYTE
IEFTRTN  TST.L     D7        TEST "Z" AND "N", CLEAR "V" AND "C" IN CCR
         MOVEM.L   (SP)+,D3-D6 RESTORE D3 THRU D6 CALLERS REGISTERS
         ADD.L     #4,SP     SKIP ORIGINAL D7
         RTS                 RETURN TO ORIGINAL CALLER WITH RESULT
 
* OVERFLOW - SET TO PROPER IEEE FORMAT INFINITY
IEFVSET  ADD.B     D7,D7     SAVE SIGN BIT IN "X"
         MOVE.L    #EXPMSK<<1,D7 SET EXPONENT OF ONES SHIFTED LEFT
         ROXR.L    #1,D7     INSERT PROPER SIGN
         BRA       IEFTRTN   AND RETURN TO ORIGINAL CALLER
         PAGE
*******************************************************************
*  GENERAL PURPOSE RETURN ROUTINES                                *
*                                                                 *
*  THE FOLLOWING ROUTINES RETURN A SPECIFIC FINAL RESULT          *
*  TO THE ORIGINAL CALLER WITH THE PROPER CONDITION CODES         *
*  SET AS FOLLOWS:                                                *
*                                                                 *
*              N - THE RESULT IS NEGATIVE                         *
*              Z - THE RESULT IS A ZERO                           *
*              V - CLEARED (NOT A NAN)                            *
*              C - UNDEFINED                                      *
*              X - UNDEFINED                                      *
*                                                                 *
*  THE ROUTINES ARE AS FOLLOWS:                                   *
*                                                                 *
*   IEFRTD7  - RETURN THE CURRENT CONTENTS OF D7                  *
*   IEFRTOD7 - RETURN THE ORIGINAL CONTENTS OF D7                 *
*   IEFRTSZ  - RETURN A SIGNED ZERO (SIGN IS BIT 31 OF D7)        *
*   IEFRTIE  - RETURN INFINITY WITH SIGN EXCLUSIVE OR OF          *
*              ORIGINAL ARGUMENT SIGNS                            *
*   IEFRTSZE - RETURN SIGNED ZERO WITH SIGN EXCLUSIV OR           *
*              OF ORIGINAL ARGUMENT SIGNS                         *
*                                                                 *
*******************************************************************
 
         XDEF      IEFRTD7,IEFRTSZ,IEFRTOD7,IEFRTIE,IEFRTSZE
 
**********************
* RETURN ORIGINAL D7 *
* (CANT BE NEG ZERO) *
**********************
IEFRTOD7 MOVE.L    16(SP),D7  LOAD ORIGINAL D7 INTO D7
 
*********************
* RETURN CURRENT D7 *
* (CANT BE NEG ZERO)*
*********************
IEFRTD7  MOVEM.L   (SP)+,D3-D6         LOAD ALL BUT D7 REGISTERS BACK UP
         ADD.L     #4,SP     SKIP ORIGINAL D7 ON STACK
         ADD.L     D7,D7     CHECK FOR SIGNED ZERO
         BEQ.S     IEFWASZ   BRANCH IF WAS A ZERO
         ROXR.L    #1,D7     VALUE BACK INTO POSITION SET CCR ("V" CLEAR)
         RTS                 RETURN TO CALLER WITH CCR AND RESULT
 
**************************************
* RETURN SIGNED ZERO WITH SIGN BEING *
* EOR OF THE ORIGINAL OPERANDS       *
**************************************
IEFRTSZE MOVEM.L   12(SP),D6-D7 LOAD ORIGINAL ARGUMENTS
         EOR.L     D6,D7     PRODUCE PROPER SIGN
 
**********************
* RETURN SIGNED ZERO *
* D7 BIT31 HAS SIGN  *
**********************
IEFRTSZ  MOVEM.L   (SP)+,D3-D6 LOAD ALL BUT D7 BACK UP
         ADD.L     #4,SP     SKIP ORIGINAL D7 ON STACK
         ADD.L     D7,D7     SET SIGN BIT INTO CARRY
         MOVE.L    #0,D7     ZERO D7
IEFWASZ  ROXR.L    #1,D7     SET SIGN BIT BACK IN ("V" CLEARED)
         OR.B      #ZBIT,SR   FORCE ZERO BIT ON IN CCR
         RTS
 
*********************************
* RETURN INFINITY WITH EOR SIGN *
* OF ORIGINAL ARGUMENTS         *
*********************************
IEFRTIE  MOVEM.L   (SP)+,D3-D7 RESTORE ORIGINAL ARGUMENTS
         EOR.L     D6,D7   PRODUCE PROPER SIGN
         ADD.L     D7,D7     SHIFT SIGN OUT
         MOVE.L    #EXPMSK<<1,D7 SETUP INFINITY (EXPONENT ALL ONES)
         ROXR.L    #1,D7     SET SIGN BACK IN ("V" CLEARED)
         RTS                 RETURN WITH RESULT AND CCR SET
 
         END
