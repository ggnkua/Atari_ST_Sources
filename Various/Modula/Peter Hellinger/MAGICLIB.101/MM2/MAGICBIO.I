(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  BIOS          Basic Input Output System       Interface for Modula-2

                Implementation fÅr Megamax-Modula-2

########################################################################
  V1.0  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicBIOS;

FROM SYSTEM IMPORT WORD, ADDRESS, ADR, ASSEMBLER;

VAR lc: LONGCARD;
    li: LONGINT;
    i:  INTEGER;
    c:  CARDINAL;
    b:  BITSET;
    a:  ADDRESS;
    x: CARDINAL;


PROCEDURE Getmpb (VAR mpb: PtrMPB);
BEGIN
 ASSEMBLER
  MOVE.L  mpb(A6), -(SP)
  MOVE    #0, -(SP)
  TRAP    #13
  ADDQ.L  #6, SP
 END;
END Getmpb;


PROCEDURE Bconstat (device: INTEGER): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  device(A6), -(SP)
  MOVE    #1, -(SP)
  TRAP    #13
  ADDQ.L  #4, SP
  MOVE.W  D0, c
 END;
 RETURN c # 0;
END Bconstat;


PROCEDURE Bconin (device: INTEGER): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W  device(A6), -(SP)
  MOVE    #2, -(SP)
  TRAP    #13
  ADDQ.L  #4, SP
  MOVE.W  D0, lc
 END;
 RETURN lc;
END Bconin;


PROCEDURE Bconout (device: INTEGER; c: CHAR);
BEGIN
 x:= ORD (c);
 ASSEMBLER
  MOVE.W  x, -(SP)
  MOVE.W  device(A6), -(SP)
  MOVE    #3, -(SP)
  TRAP    #13
  ADDQ.L  #6, SP
 END;
END Bconout;


PROCEDURE Rwabs (rw: INTEGER; buf: ADDRESS; count, recno, dev: INTEGER): LONGINT;
BEGIN
 ASSEMBLER
  MOVE.W  dev(A6), -(SP)      
  MOVE.W  recno(A6), -(SP)
  MOVE.W  count(A6), -(SP)
  MOVE.L  buf(A6), -(SP)
  MOVE.W  rw(A6), -(SP)
  MOVE    #4, -(SP)
  TRAP    #13
  LEA     $E(SP), SP
  MOVE.L  D0, li
 END;
 RETURN li;
END Rwabs;


PROCEDURE Setexc (vecnum: INTEGER; vec: ADDRESS): ADDRESS;
BEGIN
 ASSEMBLER
  MOVE    vec(A6), -(SP)
  MOVE.W  vecnum(A6), -(SP);
  MOVE    #5, -(SP)
  TRAP    #13
  ADDQ.L  #8, SP
  MOVE.L  D0, a
 END;
 RETURN a;
END Setexc;


PROCEDURE Tickcal(): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE    #6, -(SP)
  TRAP    #13
  ADDQ.L  #2, SP
  MOVE.L  D0, lc
 END;
 RETURN lc;
END Tickcal;


PROCEDURE Getbpb (drive: INTEGER): PtrBPB;
BEGIN
 ASSEMBLER
  MOVE.W  drive(A6), -(SP)  
  MOVE    #7, -(SP)
  TRAP    #13
  ADDQ.L  #4, SP
  MOVE.L  D0, a
 END; 
 RETURN a;
END Getbpb;


PROCEDURE Bcostat (device: INTEGER): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  device(A6), -(SP)
  MOVE    #8, -(SP)
  TRAP    #13
  ADDQ.L  #4, SP
  MOVE.W  D0, c
 END;
 RETURN c # 0;
END Bcostat;



PROCEDURE Mediach (dev: INTEGER): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  dev(A6), -(SP)
  MOVE    #9, -(SP)
  TRAP    #13
  ADDQ.L  #4, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Mediach;


PROCEDURE Drvmap (): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE    #10, -(SP)
  TRAP    #13
  ADDQ.L  #2, SP
  MOVE.L  D0, lc
 END; 
 RETURN lc;
END Drvmap;


PROCEDURE Kbshift (keys: BITSET): BITSET;
BEGIN
 ASSEMBLER
  MOVE.W  keys(A6), -(SP);
  MOVE    #11, -(SP)
  TRAP    #13
  ADDQ.L  #4, SP
  MOVE.W  D0, b
 END;
 RETURN b;
END Kbshift;

END MagicBIOS.

