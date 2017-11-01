(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  BIOS          Basic Input Output System       Interface for Modula-2

                Implementation fÅr LPR-Modula-2

########################################################################
  V1.01  18.06.90  Peter Hellinger      Anpassungen ans neue DEF
  V1.00  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicBIOS;


FROM SYSTEM IMPORT WORD, ADDRESS, INLINE, SETREG, REG, ADR, LONG;
IMPORT MagicSys;


CONST   Trap13 = 04E4DH;
        AddSP =  0DFFCH;
        D0 =     0;

VAR     result:  LONGCARD;


(* Systemfunktionen *)

PROCEDURE Bios (c: CARDINAL);  CODE Trap13;
PROCEDURE BiosL (l: LONGCARD; c: CARDINAL);  CODE Trap13;
PROCEDURE BiosW (a: WORD; c: CARDINAL);  CODE Trap13;
PROCEDURE BiosWW (a, b: WORD; c: CARDINAL);  CODE Trap13;
PROCEDURE BiosWWWLW (a, b, c: WORD; d: LONGCARD; e: WORD; c: CARDINAL);  CODE Trap13;
PROCEDURE BiosLW (a: LONGCARD; b: WORD; c: CARDINAL);  CODE Trap13;



PROCEDURE Getmpb (VAR mpb: PtrMPB);
BEGIN
 BiosL (ADR(mpb), 0);  
 INLINE (AddSP, 0, 6);
END Getmpb;


PROCEDURE Bconstat (device: INTEGER): BOOLEAN;
BEGIN
 BiosW (device, 1);
 INLINE (AddSP, 0, 4);
 result:= REG (D0);
 RETURN result # LONG(0);
END Bconstat;


PROCEDURE Bconin (device: INTEGER): LONGCARD;
BEGIN
 BiosW (device, 2);
 INLINE (AddSP, 0, 4);
 result:= REG (D0);
 RETURN result;
END Bconin;


PROCEDURE Bconout (device: INTEGER; c: CHAR);
BEGIN
 BiosWW (ORD(c), device, 3); 
 INLINE (AddSP, 0, 6);
END Bconout;


PROCEDURE Rwabs (rw: INTEGER; buf: ADDRESS; count, recno, dev: INTEGER): LONGINT;
BEGIN
 BiosWWWLW (dev, recno, count, buf, rw, 4);        
 INLINE (AddSP, 0, 14);
 result:= REG (D0);
 RETURN MagicSys.LCardToLInt (result);
END Rwabs;


PROCEDURE Setexc (vecnum: INTEGER; vec: ADDRESS): ADDRESS;
BEGIN
 BiosLW (vec, vecnum, 5);
 INLINE (AddSP, 0, 8);
 result:= REG (D0);
 RETURN MagicSys.LCardToAddr (result);
END Setexc;


PROCEDURE Tickcal(): LONGCARD;
BEGIN
 Bios (6);
 INLINE (AddSP, 0, 2);
 result:= REG (D0);  
 RETURN result;
END Tickcal;


PROCEDURE Getbpb (drive: INTEGER): PtrBPB;
BEGIN
 BiosW (drive, 7);
 INLINE (AddSP, 0, 4);
 result:= REG (D0);
 RETURN MagicSys.LCardToAddr (result);
END Getbpb;


PROCEDURE Bcostat (device: INTEGER): BOOLEAN;
BEGIN
 BiosW (device, 8);
 INLINE (AddSP, 0, 4);
 result:= REG (D0);
 RETURN result # LONG(0);
END Bcostat;


PROCEDURE Mediach (dev: INTEGER): INTEGER;
BEGIN
 BiosW (dev, 9);
 INLINE (AddSP, 0, 4);
 result:= REG (D0);
 RETURN MagicSys.LCardToInt (result);
END Mediach;


PROCEDURE Drvmap (): LONGCARD;
BEGIN
 Bios (10);
 INLINE (AddSP, 0, 2);
 result:= REG (D0);
 RETURN result;
END Drvmap;


PROCEDURE Kbshift (keys: BITSET): BITSET;
BEGIN
 BiosW (keys, 11);
 INLINE (AddSP, 0, 4);
 result:= REG (D0);
 RETURN MagicSys.LCardToBitset (result);
END Kbshift;


END MagicBIOS.

