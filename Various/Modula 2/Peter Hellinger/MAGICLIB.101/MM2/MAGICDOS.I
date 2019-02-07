(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  GEMDOS        Disk Operating System           Interface for Modula-2

                Implementation fÅr Megamax-Modula-2

########################################################################
  V1.01  18.06.90  Peter Hellinger      Auf Anregung von Th. Tempelmann
                                        wurden die Pterm-Funktionen 
                                        verÑndert.
  V1.00  (C) by    Peter Hellinger
#######################################################################*)

IMPLEMENTATION MODULE MagicDOS;

(*------------------------------*)
(*      MM2-COMPILERSWITCHES    *)
(*                              *)
(*$R-   Range-Checks            *)
(*$S-   Stack-Check             *)
(*------------------------------*)


FROM SYSTEM IMPORT ADDRESS, ADR, WORD, ASSEMBLER;
IMPORT RTD;

VAR     lc:     LONGCARD;
        li:     LONGINT;
        i:      INTEGER;
        c:      CARDINAL;
        s:      BITSET;
        a:      ADDRESS;
        x:      CARDINAL;


PROCEDURE Pterm0;
BEGIN
 ASSEMBLER
  MOVE.W  #0, -(SP)
  TRAP    #1
 END;
END Pterm0;


PROCEDURE Cconin (): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W  #1, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.L  D0, lc
 END;
 RETURN lc;
END Cconin;


PROCEDURE Cconout (ch: CHAR);
BEGIN                  
 x:= ORD(ch);
 ASSEMBLER
  MOVE.W  x, -(SP)
  MOVE.W  #2, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
 END;
END Cconout;


PROCEDURE Cauxin (): CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  #3, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c;
END Cauxin;


PROCEDURE Cauxout (ch: CHAR);
BEGIN
 x:= ORD (ch);
 ASSEMBLER
  MOVE.W  x, -(SP)
  MOVE.W  #4, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
 END;
END Cauxout;


PROCEDURE Cprnout (ch: CHAR);
BEGIN
 x:= ORD (ch);
 ASSEMBLER
  MOVE.W  x, -(SP)
  MOVE.W  #5, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
 END;
END Cprnout;


PROCEDURE Crawio (ch: CHAR): LONGCARD;
BEGIN
 x:= ORD (ch);
 ASSEMBLER
  MOVE.W  x, -(SP)
  MOVE.W  #6, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
  MOVE.L  D0, lc
 END;
 RETURN lc;
END Crawio;


PROCEDURE Crawin (): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W  #7, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.L  D0, lc
 END;
 RETURN lc;
END Crawin;


PROCEDURE Cnecin (): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W  #8, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.L  D0, lc
 END;
 RETURN lc;
END Cnecin;


PROCEDURE Cconws (VAR string: ARRAY OF CHAR);
BEGIN
 ASSEMBLER
  MOVE.L  string(A6), -(SP)
  MOVE.W  #9, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
 END;
END Cconws;


PROCEDURE Cconrs (VAR string: ARRAY OF CHAR);
BEGIN
 ASSEMBLER
  MOVE.L  string(A6), -(SP)
  MOVE.W  #10, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
 END;
END Cconrs;


PROCEDURE Cconis (): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  #11, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, x
 END;
 RETURN x # 0;
END Cconis;


PROCEDURE Dsetdrv (drive: CARDINAL; VAR drvmap: LONGCARD);
BEGIN
 ASSEMBLER
  MOVE.W  drive(A6), -(SP)
  MOVE.W  #14, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
  MOVE.L  D0, lc
 END;
 drvmap:= lc;
END Dsetdrv;


PROCEDURE Cconos (): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  #16, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c # 0;
END Cconos;


PROCEDURE Cprnos (): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  #17, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c # 0;
END Cprnos;


PROCEDURE Cauxis (): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  #18, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c # 0;
END Cauxis;


PROCEDURE Cauxos (): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  #19, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c # 0;
END Cauxos;


PROCEDURE Dgetdrv (): CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  #25, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c;
END Dgetdrv;


PROCEDURE Fsetdta (dta: PtrDTA);
BEGIN
 ASSEMBLER
  MOVE.L  dta(A6), -(SP)
  MOVE.W  #26, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
 END;
END Fsetdta;


PROCEDURE Super (VAR stack: ADDRESS);
BEGIN
 a:= stack;
 ASSEMBLER
  MOVE.L  a, -(SP)
  MOVE.W  #32, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.L  D0, a
 END;
 stack:= a;
END Super;


PROCEDURE Tgetdate (): CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  #42, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c;
END Tgetdate;


PROCEDURE Tsetdate (date: CARDINAL);
BEGIN
 c:= date;
 ASSEMBLER
  MOVE.W  c, -(SP)
  MOVE.W  #43, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
 END;
END Tsetdate;


PROCEDURE Tgettime (): CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  #44, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c;
END Tgettime;


PROCEDURE Tsettime (time: CARDINAL);
BEGIN
 c:= time;
 ASSEMBLER
  MOVE.W  c, -(SP)
  MOVE.W  #45, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
 END;
END Tsettime;


PROCEDURE Fgetdta (): PtrDTA;
BEGIN
 ASSEMBLER
  MOVE.W  #47, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.L  D0, a
 END;
 RETURN a;
END Fgetdta;


PROCEDURE Sversion (): CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  #48, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, c
 END;
 RETURN c;
END Sversion;


PROCEDURE Ptermres (keep: LONGCARD; return: CARDINAL);
BEGIN
 c:= return;  lc:= keep;
 ASSEMBLER
  MOVE.W  c, -(SP)
  MOVE.L  lc, -(SP)
  MOVE.W  #49, -(SP)
  TRAP    #1
 END;
END Ptermres;


PROCEDURE Dfree (VAR dib: DISKINFO; drive: CARDINAL);
BEGIN
 c:= drive;
 ASSEMBLER
  MOVE.W  c, -(SP)
  MOVE.L  dib(A6), -(SP)
  MOVE.W  #54, -(SP)
  TRAP    #1
  ADDQ.L  #8, SP
 END;
END Dfree;


PROCEDURE Dcreate (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.L  pfad(A6), -(SP)
  MOVE.W  #57, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Dcreate;


PROCEDURE Ddelete (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.L  pfad(A6), -(SP)
  MOVE.W  #58, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.W  D0, i
 END;
 RETURN i;  
END Ddelete;


PROCEDURE Dsetpath (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.L  pfad(A6), -(SP)
  MOVE.W  #59, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.W  D0, i
 END;
 RETURN i;  
END Dsetpath;


PROCEDURE Fcreate (VAR name: ARRAY OF CHAR; attr: BITSET): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  attr(A6), -(SP)
  MOVE.L  name(A6), -(SP)
  MOVE.W  #60, -(SP)
  TRAP    #1
  ADDQ.L  #8, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Fcreate;


PROCEDURE Fopen (VAR name: ARRAY OF CHAR; mode: CARDINAL): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  mode(A6), -(SP)
  MOVE.L  name(A6), -(SP)
  MOVE.W  #61, -(SP)
  TRAP    #1
  ADDQ.L  #8, SP
  MOVE.W  D0, i
 END;
 RETURN i;  
END Fopen;


PROCEDURE Fclose (handle: INTEGER): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  handle(A6), -(SP)
  MOVE.W  #62, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Fclose;


PROCEDURE Fread (handle: INTEGER; VAR count: LONGCARD; buffer: ADDRESS);
BEGIN
 lc:= count;
 ASSEMBLER
  MOVE.L  buffer(A6), -(SP)
  MOVE.L  lc, -(SP)
  MOVE.W  handle(A6), -(SP)
  MOVE.W  #63, -(SP)
  TRAP    #1
  LEA     $C(SP), SP
  MOVE.L  D0, lc
 END;
 count:= lc;
END Fread;


PROCEDURE Fwrite (handle: INTEGER; VAR count: LONGCARD; buffer: ADDRESS);
BEGIN
 lc:= count;
 ASSEMBLER
  MOVE.L  buffer(A6), -(SP)
  MOVE.L  lc, -(SP)
  MOVE.W  handle(A6), -(SP)
  MOVE.W  #64, -(SP)
  TRAP    #1
  LEA     $C(SP), SP
  MOVE.L  D0, lc
 END;
 count:= lc;
END Fwrite;
  

PROCEDURE Fdelete (VAR name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.L  name(A6), -(SP)
  MOVE.W  #65, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.W  D0, x
 END;
 RETURN x # 0;
END Fdelete;


PROCEDURE Fseek (offset: LONGINT; handle, mode: INTEGER): LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W  mode(A6), -(SP)
  MOVE.W  handle(A6), -(SP)
  MOVE.L  offset(A6), -(SP)
  MOVE.W  #66, -(SP)
  TRAP    #1
  LEA     $A(SP), SP
  MOVE.L  D0, lc
 END;
 RETURN lc;
END Fseek;


PROCEDURE Fattrib (VAR name: ARRAY OF CHAR; set: BOOLEAN; VAR attr: BITSET);
BEGIN
 IF set THEN  c:= 1;  ELSE  c:= 0;  END;
 ASSEMBLER
  MOVE.W  attr(A6), -(SP)
  MOVE.W  c, -(SP)
  MOVE.L  name(A6), -(SP)
  MOVE.W  #67, -(SP)
  TRAP    #1
  LEA     $A(SP), SP
  MOVE.W  D0, s
 END; 
 attr:= s;
END Fattrib;


PROCEDURE Fdup (handle: INTEGER): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  handle(A6), -(SP)
  MOVE.W  #69, -(SP)
  TRAP    #1
  ADDQ.L  #4, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Fdup;

            
PROCEDURE Fforce (std, nonstd: INTEGER): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  nonstd(A6), -(SP)
  MOVE.W  std(A6), -(SP)
  MOVE.W  #70, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.W  D0, x
 END;
 RETURN x # 0;
END Fforce;


PROCEDURE Dgetpath (VAR pfad: ARRAY OF CHAR; drive: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.W  drive(A6), -(SP)
  MOVE.L  pfad(A6), -(SP)
  MOVE.W  #71, -(SP)
  TRAP    #1
  ADDQ.L  #8, SP
 END;
END Dgetpath;


PROCEDURE Malloc (bytes: LONGCARD): ADDRESS;
BEGIN
 ASSEMBLER
  MOVE.L  bytes(A6), -(SP)
  MOVE.W  #72, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.L  D0, a
 END;
 RETURN a;
END Malloc;


PROCEDURE Mfree (addr: ADDRESS): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.W  addr(A6), -(SP)
  MOVE.W  #73, -(SP)
  TRAP    #1
  ADDQ.L  #6, SP
  MOVE.W  D0, x
 END;
 RETURN x # 0;  
END Mfree;


PROCEDURE Mshrink (addr: ADDRESS; newSize: LONGCARD): BOOLEAN;
BEGIN
 ASSEMBLER
  MOVE.L  newSize(A6), -(SP)
  MOVE.L  addr(A6), -(SP)
  MOVE.W  #0, -(SP)
  MOVE.W  #74, -(SP)
  TRAP    #1
  LEA     $C(SP), SP
  MOVE.W  D0, x
 END;
 RETURN x = 0;
END Mshrink;


PROCEDURE Pexec (mode: CARDINAL; VAR name, tail, env: ARRAY OF CHAR): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.L  env(A6), -(SP)
  MOVE.L  tail(A6), -(SP)
  MOVE.L  name(A6), -(SP)
  MOVE.W  mode(A6), -(SP)
  MOVE.W  #75, -(SP)
  TRAP    #1
  LEA     $10(SP), SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Pexec;


PROCEDURE Pterm (code: INTEGER);
BEGIN
 ASSEMBLER
  MOVE.W  code(A6), -(SP)
  MOVE.W  #76, -(SP)
  TRAP    #1
 END;
END Pterm;


PROCEDURE Fsfirst (VAR name: ARRAY OF CHAR; attr: BITSET): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  attr(A6), -(SP)
  MOVE.L  name(A6), -(SP)
  MOVE.W  #78, -(SP)
  TRAP    #1
  ADDQ.L  #8, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Fsfirst;


PROCEDURE Fsnext (): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  #79, -(SP)
  TRAP    #1
  ADDQ.L  #2, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Fsnext;


PROCEDURE Frename (VAR curr, new: ARRAY OF CHAR): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.L  new(A6), -(SP)
  MOVE.L  curr(A6), -(SP)
  MOVE.W  #0, -(SP)
  MOVE.W  #86, -(SP)
  TRAP    #1
  LEA     $C(SP), SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Frename;


PROCEDURE Fdatime (handle: INTEGER; buff: DOSTIME; set: BOOLEAN);
BEGIN
 IF set THEN c:= 0;  ELSE  c:= 1;  END;
 ASSEMBLER
  MOVE.W  c, -(SP)
  MOVE.W  handle(A6), -(SP)
  MOVE.L  buff(A6), -(SP)
  MOVE.W  #87, -(SP)
  TRAP    #1
  LEA     $A(SP), SP
 END;
END Fdatime;

END MagicDOS.

