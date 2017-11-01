(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  BIOS          Basic Input Output System       Interface for Modula-2

                Implementation fÅr TDI-Modula-2/ST

########################################################################
  V1.0  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicBIOS;

FROM SYSTEM IMPORT WORD, ADDRESS, CODE, SETREG, REGISTER, ADR, PUSH;


CONST   TRAP13 = 04E4DH;
        D0 =     0;


PROCEDURE Getmpb (VAR mpb: PtrMPB);
BEGIN
 PUSH (mpb);
 PUSH (CARDINAL (0));
 CODE (TRAP13);
END Getmpb;


PROCEDURE Bconstat (device: INTEGER): BOOLEAN;
BEGIN
 PUSH (device);
 PUSH (CARDINAL (1));         
 CODE (TRAP13);
 RETURN BOOLEAN (BITSET (REGISTER (D0)) * {0});
END Bconstat;


PROCEDURE Bconin (device: INTEGER): LONGCARD;
BEGIN
 PUSH (device);
 PUSH (CARDINAL (2));         
 CODE (TRAP13);
 RETURN LONGCARD (REGISTER(D0));
END Bconin;


PROCEDURE Bconout (device: INTEGER; c: CHAR);
BEGIN
 PUSH (CARDINAL (c));         
 PUSH (device);
 PUSH (CARDINAL (3));
 CODE (TRAP13);
END Bconout;


PROCEDURE Rwabs (rw: INTEGER; buf: ADDRESS; count, recno, dev: INTEGER): LONGINT;
BEGIN
 PUSH (dev);      
 PUSH (recno);    
 PUSH (count);    
 PUSH (buf);      
 PUSH (rw);
 PUSH (CARDINAL (4));        
 CODE (TRAP13);
 RETURN LONGINT (REGISTER (D0));
END Rwabs;


PROCEDURE Setexc (vecnum: INTEGER; vec: ADDRESS): ADDRESS;
BEGIN
 PUSH (ADDRESS (vec));  
 PUSH (vecnum);        
 PUSH (CARDINAL (5));             
 CODE (TRAP13);
 RETURN ADDRESS (REGISTER (D0));
END Setexc;


PROCEDURE Tickcal(): LONGCARD;
BEGIN
 PUSH (CARDINAL(6));  
 CODE (TRAP13);
 RETURN LONGCARD (REGISTER (D0));
END Tickcal;


PROCEDURE Getbpb (drive: INTEGER): PtrBPB;
BEGIN
 PUSH (drive);  
 PUSH (CARDINAL(7));    
 CODE (TRAP13);
 RETURN PtrBPB (REGISTER(D0));
END Getbpb;


PROCEDURE Bcostat (device: INTEGER): BOOLEAN;
BEGIN
 PUSH (device);
 PUSH (CARDINAL (8));         
 CODE (TRAP13);
 RETURN BOOLEAN (BITSET (REGISTER (D0)) * {0});
END Bcostat;


PROCEDURE Mediach (dev: INTEGER): INTEGER;
BEGIN
 PUSH (dev);  
 PUSH (CARDINAL(9));    
 CODE (TRAP13);
 RETURN INTEGER (REGISTER(D0));
END Mediach;


PROCEDURE Drvmap (): LONGCARD;
BEGIN
 PUSH(CARDINAL(10));  
 CODE(TRAP13);
 RETURN LONGCARD (REGISTER(D0));
END Drvmap;


PROCEDURE Kbshift (keys: BITSET): BITSET;
BEGIN
 PUSH (keys);  
 PUSH (CARDINAL (11));              
 CODE (TRAP13);
 RETURN BITSET (REGISTER (D0));
END Kbshift;


END MagicBIOS.

