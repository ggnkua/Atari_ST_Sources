(*######################################################################
                                                                        
        MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                      ˇ         ˇ            ˇ    ˇ          ˇ
  ######################################################################

                Typdeklarationen nach Profibuch, Anhang C

                    Implementation fÅr Megamax-Modula-2

  ######################################################################
  V1.0  (C) by Peter Hellinger
  ####################################################################*)

IMPLEMENTATION MODULE MagicTypes;

FROM SYSTEM IMPORT ASSEMBLER, BYTE, ADDRESS;

VAR a: ADDRESS;

PROCEDURE LineA (): PtrLINEA;
BEGIN
 ASSEMBLER
  DC.W    0A000H;         LineA initialisieren
  MOVE.L  D0, a
 END;
 RETURN a;
END LineA;


PROCEDURE LineAFonts (): PtrLINEAFonts;
BEGIN
 ASSEMBLER
  DC.W    0A000H;         LineA initialisieren
  MOVE.L  A1, a
 END;
 RETURN a;
END LineAFonts;


PROCEDURE Vdiesc (): PtrVDIESC;
BEGIN
 ASSEMBLER
  DC.W    0A000H;         LineA initialisieren
  MOVE.L  D0, a
 END;
 RETURN a - ADDRESS (038EH);
END Vdiesc;


VAR sysbase[04F2H]: PtrSYSHDR;


PROCEDURE Syshdr (): PtrSYSHDR;
VAR stack: ADDRESS;
    sys:   PtrSYSHDR;
BEGIN
 ASSEMBLER
  MOVE.L  #0, -(SP)
  MOVE.W  #32, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.L  D0, stack(A6)
  MOVE.L  sysbase, sys(A6)
  MOVE.L  stack(A6), -(SP)
  MOVE.W  #32, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
 END;
 RETURN sys;
END Syshdr;


END MagicTypes.
