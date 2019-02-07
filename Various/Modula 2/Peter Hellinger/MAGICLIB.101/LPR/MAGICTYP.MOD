(*######################################################################
                                                                        
        MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                      ˇ         ˇ            ˇ    ˇ          ˇ
  ######################################################################

                Typdeklarationen nach Profibuch, Anhang C

                      Implementation fÅr LPR-Modula-2

  ######################################################################
  V1.01  18.06.90  Peter Hellinger      Anpassungen an neues DEF
  V1.00  (C) by Peter Hellinger
  ####################################################################*)

IMPLEMENTATION MODULE MagicTypes;

FROM SYSTEM IMPORT BYTE, ADDRESS, INLINE, SETREG, REG, VAL, LONG;


PROCEDURE LineA (): PtrLINEA;
BEGIN
 INLINE (0A000H);
 RETURN VAL (PtrLINEA, REG (0));
END LineA;


PROCEDURE LineAFonts (): PtrLINEAFonts;
BEGIN
 INLINE (0A000H);
 RETURN VAL (PtrLINEAFonts, REG (9));
END LineAFonts;


PROCEDURE Vdiesc (): PtrVDIESC;
VAR lc: LONGCARD;
BEGIN
 INLINE (0A000H);
 lc:= REG (0);  DEC (lc, LONG(038EH));
 RETURN VAL (PtrVDIESC, lc);
END Vdiesc;


PROCEDURE DosL (l: LONGCARD; z: CARDINAL);  CODE 04E41H;

VAR base: POINTER TO ADDRESS;


PROCEDURE Syshdr (): PtrSYSHDR;
VAR stack: ADDRESS;
    sys:  PtrSYSHDR;
BEGIN
 base:= VAL (ADDRESS, 04F2H);
 DosL (LONG(0), 32);  INLINE (0DFFCH, 0, 6);
 stack:= REG (0);
 sys:= base^;
 DosL (stack, 32);  INLINE (0DFFCH, 0, 6);
 RETURN sys;
END Syshdr;


END MagicTypes.
