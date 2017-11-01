(*######################################################################
                                                                        
        MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                      ˇ         ˇ            ˇ    ˇ          ˇ
  ######################################################################

                Typdeklarationen nach Profibuch, Anhang C

                      Implementation fÅr TDI-Modula-2

  ######################################################################
  V1.0  (C) by Peter Hellinger
  ####################################################################*)

IMPLEMENTATION MODULE MagicTypes;

FROM SYSTEM IMPORT BYTE, ADDRESS, CODE, PUSH, SETREG, REGISTER;


PROCEDURE LineA (): PtrLINEA;
BEGIN
 CODE (0A000H);
 RETURN ADDRESS (REGISTER (0));
END LineA;


PROCEDURE LineAFonts (): PtrLINEAFonts;
BEGIN
 CODE (0A000H);
 RETURN ADDRESS (REGISTER (9));
END LineAFonts;


PROCEDURE Vdiesc (): PtrVDIESC;
BEGIN
 CODE (0A000H);
 RETURN ADDRESS(REGISTER (0)) - ADDRESS (038EH);
END Vdiesc;


VAR sysbase[04F2H]: PtrSYSHDR;


PROCEDURE Syshdr (): PtrSYSHDR;
VAR stack: ADDRESS;
    sys:   PtrSYSHDR;
BEGIN
 PUSH (LONGCARD (0));
 PUSH (CARDINAL (32));
 CODE (04E41H);
 stack:= ADDRESS (REGISTER (0));
 sys:= sysbase;
 PUSH (stack);
 PUSH (CARDINAL (32));
 CODE (04E41H);
 RETURN sys;
END Syshdr;


END MagicTypes.
