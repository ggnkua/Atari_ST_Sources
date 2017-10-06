/**************************************************************************/
/*                                                                        */
/*  NAME:         boolop.h                                                */
/*                                                                        */
/*  DATUM:        13.07.89                                                */
/*                                                                        */
/*  BESCHREIBUNG: Enthaelt Macros fuer Boolesche Operationen, sowie zum   */
/*                Setzten, Abfragen und Ruecksetzen von Bits.             */
/*                                                                        */
/*  AENDERUNGEN:  CH071088 - Prototyp.                                    */
/*                CH081088 - BOGetVal, ...                                */
/*                CH161088 - Klammern in BOGetBit(...                     */
/*                CH221188 - #define BOOLOP eingefuegt.                   */
/*                CH130789 - um BOTogVal(), BOTogBit() erweitert          */
/*                         - BOOLOP -> BOOLOPH geaendert                  */
/*                                                                        */
/*  ERWEITERUNG:  - rotate                                                */
/*                - operatoren aendern ~, ^.                              */
/*                                                                        */
/**************************************************************************/

#ifndef BOOLOPH
#define BOOLOPH

#define BOKontra(a,b)  (0)                         /*  0. 0000 */
#define BOKonjunk(a,b) (a & b)                     /*  1. 0001 */
#define BODisAImp(a,b) (a & !b)                    /*  2  0010 */
#define BOAIdent(a,b)  (a)                         /*  3. 0011 */
#define BODisBImp(a,b) (!a & b)                    /*  4. 0100 */
#define BOBIdent(a,b)  (b)                         /*  5. 0101 */
#define BOValenz(a,b)  ((a & b) | (!a & !b))       /*  9. 1001 */
#define BODisval(a,b)  (!(BOValenz(a,b)))          /*  6. 0110 */
#define BODisjunk(a,b) (a | b)                     /*  7. 0111 */
#define BOPierce(a,b)  (!(a | b))                  /*  8. 1000 */
#define BOBKompl(a,b)  (!b)                        /* 10. 1010 */
#define BOBImpli(a,b)  (a | !b)                    /* 11. 1011 */
#define BOAKompl(a,b)  (!a)                        /* 12. 1100 */
#define BOAImpli(a,b)  (!a | b)                    /* 13. 1101 */
#define BOSheffer(a,b) (!(a & b))                  /* 14. 1110 */
#define BOTautol(a,b)  (1)                         /* 15. 1111 */

#define BONegate(a)    (!a)

#define BOAND(a,b)     (BOKonjunk(a,b))
#define BOOR(a,b)      (BODisjunk(a,b))
#define BONAND(a,b)    (BOSheffer(a,b))
#define BONOR(a,b)     (BOPierce(a,b))
#define BONOT(a)       (BONegate(a))

#define BOGetVal(f,v)   (((f) & (v)) == v)
#define BOSetVal(f,v)   ((f) |= (v))
#define BOResetVal(f,v) ((f) &= ~(v))
#define BOTogVal(f,v)   (BOGetVal(f,v) ? BOResetVal(f,v) : BOSetVal(f,v))

#define BOGetBit(f,b)   (BOGetVal(f, (1 << b)))
#define BOSetBit(f,b)   (BOSetVal(f, (1 << b)))
#define BOResetBit(f,b) (BOResetVal(f, (1 << b)))
#define BOTogBit(f,b)   (BOTogVal(f, (1 << b)))

#endif BOOLOPH

