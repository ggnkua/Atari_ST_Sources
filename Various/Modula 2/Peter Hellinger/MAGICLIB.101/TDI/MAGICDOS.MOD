(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  GEMDOS        Disk Operating System           Interface for Modula-2

                Implementation fÅr TDI-Modula-2/ST
                
########################################################################
  V1.0  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicDOS;

(*------------------------------*)
(*      TDI-COMPILERSWITCHES    *)
(*                              *)
(*$V-   Overflow-Checks         *)
(*$R-   Range-Checks            *)
(*$S-   Stack-Check             *)
(*$N-   NIL-Checks              *)
(*$T-   TDI-Compiler vor 3.01   *)
(*$Q+   Branch statt Jumps      *)
(*                              *)
(*------------------------------*)


FROM SYSTEM IMPORT ADDRESS, SETREG, REGISTER, CODE, ADR, WORD, LONGWORD, PUSH;


CONST   TRAP1 =         04E41H;
        D0 =            0;

VAR     SaveA5:         ADDRESS;
        SaveA6:         ADDRESS;
        SaveA7:         ADDRESS;



PROCEDURE Pterm0 ();
BEGIN
 PUSH (CARDINAL (0));
 CODE (TRAP1);
END Pterm0;


PROCEDURE Cconin (): LONGCARD;
BEGIN
 PUSH (CARDINAL (1));
 CODE (TRAP1);
 RETURN LONGCARD (REGISTER (D0));
END Cconin;


PROCEDURE Cconout (ch: CHAR);
BEGIN
 PUSH (CARDINAL (ch));
 PUSH (CARDINAL (2));
 CODE (TRAP1);
END Cconout;


PROCEDURE Cauxin (): CARDINAL;
BEGIN
 PUSH (CARDINAL (3));
 CODE (TRAP1);
 RETURN CARDINAL (REGISTER (D0));
END Cauxin;


PROCEDURE Cauxout (ch: CHAR);
BEGIN
 PUSH (CARDINAL (ch));
 PUSH (CARDINAL (4));
 CODE (TRAP1);
END Cauxout;


PROCEDURE Cprnout (ch: CHAR);
BEGIN
 PUSH (CARDINAL (ch));
 PUSH (CARDINAL (5));
 CODE (TRAP1);
END Cprnout;


PROCEDURE Crawio  (ch: CHAR): LONGCARD;
BEGIN
 PUSH (ORD(ch));
 PUSH (CARDINAL (6));
 CODE (TRAP1);
 RETURN LONGCARD (REGISTER (D0));
END Crawio;


PROCEDURE Crawin (): LONGCARD;
BEGIN
 PUSH (CARDINAL (7));
 CODE (TRAP1);
 RETURN LONGCARD (REGISTER (D0));
END Crawin;


PROCEDURE Cnecin (): LONGCARD;
BEGIN
 PUSH (CARDINAL (8));
 CODE (TRAP1);
 RETURN LONGCARD (REGISTER (D0));
END Cnecin;


PROCEDURE Cconws (VAR string: ARRAY OF CHAR);
BEGIN
 PUSH (ADR (string));
 PUSH (CARDINAL (9));
 CODE (TRAP1);
END Cconws;


PROCEDURE Cconrs (VAR string: ARRAY OF CHAR);
BEGIN
 PUSH (ADR (string));
 PUSH (CARDINAL (10));
 CODE (TRAP1);
END Cconrs;


PROCEDURE Cconis (): BOOLEAN;
BEGIN
 PUSH (CARDINAL (11));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0)) # 0;
END Cconis;


PROCEDURE Dsetdrv (drive: CARDINAL; VAR drvmap: LONGCARD);
BEGIN
 PUSH (CARDINAL (drive));
 PUSH (CARDINAL (14));
 CODE (TRAP1);
 drvmap:= LONGCARD (REGISTER (D0));
END Dsetdrv;


PROCEDURE Cconos (): BOOLEAN;
BEGIN
 PUSH (CARDINAL (16));
 CODE (TRAP1);
 RETURN (REGISTER (D0)) # 0;
END Cconos;


PROCEDURE Cprnos (): BOOLEAN;
BEGIN
 PUSH (CARDINAL (17));
 CODE (TRAP1);
 RETURN (REGISTER (D0)) # 0;
END Cprnos;


PROCEDURE Cauxis (): BOOLEAN;
BEGIN
 PUSH (CARDINAL (18));
 CODE (TRAP1);
 RETURN (REGISTER (D0)) # 0;
END Cauxis;


PROCEDURE Cauxos (): BOOLEAN;
BEGIN
 PUSH (CARDINAL (19));
 CODE (TRAP1);
 RETURN (REGISTER (D0)) # 0;
END Cauxos;


PROCEDURE Dgetdrv (): CARDINAL;
BEGIN
 PUSH (CARDINAL (25));
 CODE (TRAP1);
 RETURN CARDINAL (REGISTER (D0));
END Dgetdrv;


PROCEDURE Fsetdta (dta: PtrDTA);
BEGIN
 PUSH (dta);
 PUSH (CARDINAL (26));
 CODE (TRAP1);
END Fsetdta;


PROCEDURE Super (VAR stack: ADDRESS);
BEGIN
 PUSH (stack);
 PUSH (CARDINAL (32));
 CODE (TRAP1);
 stack:= ADDRESS (REGISTER (D0));
END Super;


PROCEDURE Tgetdate (): CARDINAL;
BEGIN
 PUSH (CARDINAL (42));
 CODE (TRAP1);
 RETURN CARDINAL (REGISTER (D0));
END Tgetdate;


PROCEDURE Tsetdate (date: CARDINAL);
BEGIN
 PUSH (CARDINAL (date));
 PUSH (CARDINAL (43));
 CODE (TRAP1);
END Tsetdate;


PROCEDURE Tgettime (): CARDINAL;
BEGIN
 PUSH (CARDINAL (44));
 CODE (TRAP1);
 RETURN CARDINAL (REGISTER (D0));
END Tgettime;


PROCEDURE Tsettime (time: CARDINAL);
BEGIN
 PUSH (CARDINAL (time));
 PUSH (CARDINAL (45));
 CODE (TRAP1);
END Tsettime;


PROCEDURE Fgetdta (): PtrDTA;
BEGIN
 PUSH (CARDINAL (47));
 CODE (TRAP1);
 RETURN ADDRESS (REGISTER (D0));
END Fgetdta;


PROCEDURE Sversion (): CARDINAL;
BEGIN
 PUSH (CARDINAL (48));
 CODE (TRAP1);
 RETURN CARDINAL (REGISTER (D0));
END Sversion;


PROCEDURE Ptermres  (keep: LONGCARD; return: CARDINAL);
BEGIN
 PUSH (CARDINAL (return));
 PUSH (keep);
 PUSH (CARDINAL (49));
 CODE (TRAP1);
END Ptermres;


PROCEDURE Dfree (VAR di: DISKINFO; drive: CARDINAL);
BEGIN
 PUSH (CARDINAL (drive));
 PUSH (ADR (di));
 PUSH (CARDINAL (54));
 CODE (TRAP1);
END Dfree;


PROCEDURE Dcreate (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 PUSH (ADR (pfad));
 PUSH (CARDINAL (57));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Dcreate;


PROCEDURE Ddelete (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 PUSH (ADR(pfad));
 PUSH (CARDINAL (58));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));  
END Ddelete;


PROCEDURE Dsetpath (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 PUSH (ADR(pfad));
 PUSH (CARDINAL (59));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));  
END Dsetpath;


PROCEDURE Fcreate (VAR name: ARRAY OF CHAR; attr: BITSET): INTEGER;
BEGIN
 PUSH (CARDINAL (attr));
 PUSH (ADR(name));
 PUSH (CARDINAL (60));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Fcreate;


PROCEDURE Fopen (VAR name: ARRAY OF CHAR; mode: CARDINAL): INTEGER;
BEGIN
 PUSH (CARDINAL (mode));
 PUSH (ADR(name));
 PUSH (CARDINAL (61));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));  
END Fopen;


PROCEDURE Fclose (handle: INTEGER): INTEGER;
BEGIN
 PUSH (CARDINAL (handle));
 PUSH (CARDINAL (62));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Fclose;


PROCEDURE Fread (handle: INTEGER; VAR count: LONGCARD; buffer: ADDRESS);
 (* Read file *)
BEGIN
 PUSH (buffer);
 PUSH (count);
 PUSH (CARDINAL (handle));
 PUSH (CARDINAL (63));
 CODE (TRAP1);
 count:= LONGCARD (REGISTER (D0));
END Fread;


PROCEDURE Fwrite (handle: INTEGER; VAR count: LONGCARD; buffer: ADDRESS);
BEGIN
 PUSH (buffer);
 PUSH (count);
 PUSH (CARDINAL (handle));
 PUSH (CARDINAL (64));
 CODE (TRAP1);
 count:= LONGCARD (REGISTER (D0));
END Fwrite;
  

PROCEDURE Fdelete (VAR name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 PUSH (ADR(name));
 PUSH (CARDINAL (65));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0)) # 0;
END Fdelete;


PROCEDURE Fseek (offset: LONGINT; handle, mode: INTEGER): LONGCARD;
BEGIN
 PUSH (mode);
 PUSH (handle);
 PUSH (offset);
 PUSH (CARDINAL (66));
 CODE (TRAP1);
 RETURN LONGCARD (REGISTER (D0));
END Fseek;


PROCEDURE Fattrib (VAR name: ARRAY OF CHAR; wich: BOOLEAN; VAR attr: BITSET);
BEGIN
 PUSH (attr);
 PUSH (CARDINAL(wich));
 PUSH (CARDINAL (67));
 PUSH (ADR(name));
 CODE (TRAP1);
 attr:= BITSET (REGISTER (D0));
END Fattrib;


PROCEDURE Fdup (handle: INTEGER): INTEGER;
BEGIN
 PUSH (handle);
 PUSH (CARDINAL (69));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Fdup;

            
PROCEDURE Fforce (std, nonstd: INTEGER): BOOLEAN;
BEGIN
 PUSH (nonstd);
 PUSH (std);
 PUSH (CARDINAL (70));
 RETURN INTEGER (REGISTER (D0)) # 0;
END Fforce;


PROCEDURE Dgetpath (VAR pfad: ARRAY OF CHAR; drive: CARDINAL);
BEGIN
 PUSH (drive);
 PUSH (ADR(pfad));
 PUSH (CARDINAL (71));
 CODE (TRAP1);
END Dgetpath;


PROCEDURE Malloc (bytes: LONGCARD): ADDRESS;
BEGIN
 PUSH (bytes);
 PUSH (CARDINAL (72));
 CODE (TRAP1);
 RETURN  REGISTER (D0);
END Malloc;


PROCEDURE Mfree (addr: ADDRESS): BOOLEAN;
BEGIN
 PUSH (addr);
 PUSH (CARDINAL (73));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0)) # 0;  
END Mfree;


PROCEDURE Mshrink (addr: ADDRESS; newSize: LONGCARD): BOOLEAN;
BEGIN
 PUSH (newSize);
 PUSH (addr);
 PUSH (CARDINAL (0));
 PUSH (CARDINAL (74));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0)) = 0;
END Mshrink;


PROCEDURE Pexec (mode: CARDINAL; VAR name, tail, env: ARRAY OF CHAR): INTEGER;
BEGIN
 PUSH (ADR (env));
 PUSH (ADR (tail));
 PUSH (ADR (name));
 PUSH (mode);
 PUSH (CARDINAL (75));
 SaveA5:= REGISTER (13);
 SaveA6:= REGISTER (14);
 SaveA7:= REGISTER (15);
 CODE (TRAP1);
 SETREG (13, SaveA5);
 SETREG (14,SaveA6);
 SETREG (15,SaveA7);
 RETURN INTEGER (REGISTER (D0));
END Pexec;


PROCEDURE Pterm (code: INTEGER);
BEGIN
 PUSH (CARDINAL (code));
 PUSH (CARDINAL (76));
 CODE (TRAP1);
END Pterm;


PROCEDURE Fsfirst (VAR name: ARRAY OF CHAR; attr: BITSET): INTEGER;
BEGIN
 PUSH (attr);
 PUSH (ADR (name));
 PUSH (CARDINAL (78));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Fsfirst;


PROCEDURE Fsnext (): INTEGER;
BEGIN
 PUSH (CARDINAL (79));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Fsnext;


PROCEDURE Frename (VAR curr, new: ARRAY OF CHAR): INTEGER;
BEGIN
 PUSH (ADR(new));
 PUSH (ADR(curr));
 PUSH (CARDINAL (0));
 PUSH (CARDINAL (86));
 CODE (TRAP1);
 RETURN INTEGER (REGISTER (D0));
END Frename;


PROCEDURE Fdatime (handle: INTEGER; buff: DOSTIME; wich: BOOLEAN);
BEGIN
 PUSH (CARDINAL (wich));
 PUSH (handle);
 PUSH (ADR(buff));
 PUSH (CARDINAL (87));
 CODE (TRAP1);
END Fdatime;

END MagicDOS.

