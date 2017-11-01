(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  GEMDOS        Disk Operating System           Interface for Modula-2

                Implementation fÅr LPR-Modula-2

########################################################################
  V1.01  18.06.90  Peter Hellinger      Bugs gefixed. Auf Vorschlag von
                                        Thomas Tempelmann wurden die
                                        Pterm-Funktionen verÑndert
  V1.00  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicDOS;

FROM SYSTEM IMPORT ADDRESS, SETREG, REG, INLINE, ADR, WORD, VAL, LONG;
IMPORT MagicSys;


CONST   Trap1 =         04E41H;
        AddSP =         0DFFCH;
        D0 =            0;

VAR     SaveA3:         ADDRESS;
        SaveA4:         ADDRESS;
        SaveA5:         ADDRESS;
        SaveA6:         ADDRESS;
        SaveA7:         ADDRESS;

VAR     res:            LONGCARD;


(* Systemfunktionen *)

PROCEDURE Dos           (z: CARDINAL);  CODE Trap1;
PROCEDURE DosW          (w: WORD; z: CARDINAL);  CODE Trap1;
PROCEDURE DosL          (l: LONGCARD; z: CARDINAL);  CODE Trap1;
PROCEDURE DosWL         (w: WORD; l: LONGCARD; z: CARDINAL);  CODE Trap1;
PROCEDURE DosLLW        (a,b: LONGCARD; c: WORD; z: CARDINAL);  CODE Trap1;
PROCEDURE DosWWL        (a,b: WORD; l: LONGCARD; z: CARDINAL);  CODE Trap1;
PROCEDURE DosWW         (a,b: WORD; z: CARDINAL);  CODE Trap1;
PROCEDURE DosLL         (a,b: LONGCARD; z: CARDINAL); CODE Trap1;
PROCEDURE DosLLLW       (a,b,c: LONGCARD;  d: WORD; z: CARDINAL);  CODE Trap1;



PROCEDURE Pterm0 ();
BEGIN
 Dos (0);
END Pterm0;


PROCEDURE Cconin (): LONGCARD;
BEGIN
 Dos (1);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res;
END Cconin;


PROCEDURE Cconout (ch: CHAR);
BEGIN
 DosW (ORD(ch), 2);
 INLINE (AddSP, 0, 4);
END Cconout;


PROCEDURE Cauxin (): CARDINAL;
BEGIN
 Dos (3);
 INLINE (AddSP, 0, 3);
 res:= REG (D0);
 RETURN res;
END Cauxin;


PROCEDURE Cauxout (ch: CHAR);
BEGIN
 DosW (ORD(ch), 4);
 INLINE (AddSP, 0, 4);
END Cauxout;


PROCEDURE Cprnout (ch: CHAR);
BEGIN
 DosW (ORD(ch), 5);
 INLINE (AddSP, 0, 4);
END Cprnout;


PROCEDURE Crawio  (ch: CHAR): LONGCARD;
BEGIN
 DosW (ORD(ch), 6);
 INLINE (AddSP, 0, 4);
 res:= REG (D0);
 RETURN res;
END Crawio;


PROCEDURE Crawin (): LONGCARD;
BEGIN
 Dos (7);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res;
END Crawin;


PROCEDURE Cnecin (): LONGCARD;
BEGIN
 Dos (8);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res;
END Cnecin;


PROCEDURE Cconws (VAR string: ARRAY OF CHAR);
BEGIN
 DosL (ADR(string), 9);
 INLINE (AddSP, 0, 6);
END Cconws;


PROCEDURE Cconrs (VAR string: ARRAY OF CHAR);
BEGIN
 DosL (ADR(string), 10);
 INLINE (AddSP, 0, 6);
END Cconrs;


PROCEDURE Cconis (): BOOLEAN;
BEGIN
 Dos (11);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res # LONG(0);
END Cconis;


PROCEDURE Dsetdrv (drive: CARDINAL; VAR drvmap: LONGCARD);
BEGIN
 DosW (drive, 14);
 INLINE (AddSP, 0, 4);
 drvmap:= REG (D0);
END Dsetdrv;


PROCEDURE Cconos (): BOOLEAN;
BEGIN
 Dos (16);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res # LONG(0);
END Cconos;


PROCEDURE Cprnos (): BOOLEAN;
BEGIN
 Dos (17);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res # LONG(0);
END Cprnos;


PROCEDURE Cauxis (): BOOLEAN;
BEGIN
 Dos (18);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res # LONG(0);
END Cauxis;


PROCEDURE Cauxos (): BOOLEAN;
BEGIN
 Dos (19);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res # LONG(0);
END Cauxos;


PROCEDURE Dgetdrv (): CARDINAL;
BEGIN
 Dos (25);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Dgetdrv;


PROCEDURE Fsetdta (dta: PtrDTA);
BEGIN
 DosL (VAL (ADDRESS, dta), 26);
 INLINE (AddSP, 0, 6);
END Fsetdta;


PROCEDURE Super (VAR stack: ADDRESS);
BEGIN
 DosL (stack, 32);
 INLINE (AddSP, 0, 6);
 stack:= REG (D0);
END Super;


PROCEDURE Tgetdate (): CARDINAL;
BEGIN
 Dos (42);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Tgetdate;


PROCEDURE Tsetdate (date: CARDINAL);
BEGIN
 DosW (date, 43);
 INLINE (AddSP, 0, 4);
END Tsetdate;


PROCEDURE Tgettime (): CARDINAL;
BEGIN
 Dos (44);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Tgettime;


PROCEDURE Tsettime (time: CARDINAL);
BEGIN
 DosW (time, 45);
 INLINE (AddSP, 0, 4);
END Tsettime;


PROCEDURE Fgetdta (): PtrDTA;
BEGIN
 Dos (47);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToAddr (res);
END Fgetdta;


PROCEDURE Sversion (): CARDINAL;
BEGIN
 Dos (48);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Sversion;


PROCEDURE Ptermres (keep: LONGCARD; return: CARDINAL);
BEGIN
 DosWL (return, keep, 49);
END Ptermres;


PROCEDURE Dfree (VAR di: DISKINFO; drive: CARDINAL);
BEGIN
 DosWL (drive, ADR (di), 54);
 INLINE (AddSP, 0, 8);
END Dfree;


PROCEDURE Dcreate (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 DosL (ADR (pfad), 57);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Dcreate;


PROCEDURE Ddelete (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 DosL (ADR (pfad), 58);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Ddelete;


PROCEDURE Dsetpath (VAR pfad: ARRAY OF CHAR): INTEGER;
BEGIN
 DosL (ADR (pfad), 59);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Dsetpath;


PROCEDURE Fcreate (VAR name: ARRAY OF CHAR; attr: BITSET): INTEGER;
BEGIN
 DosWL (attr, ADR (name), 60);
 INLINE (AddSP, 0, 8);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Fcreate;


PROCEDURE Fopen (VAR name: ARRAY OF CHAR; mode: CARDINAL): INTEGER;
BEGIN
 DosWL (mode, ADR (name), 61);
 INLINE (AddSP, 0, 8);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Fopen;


PROCEDURE Fclose (handle: INTEGER): INTEGER;
BEGIN
 DosW (handle, 62);
 INLINE (AddSP, 0, 4);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Fclose;


PROCEDURE Fread (handle: INTEGER; VAR count: LONGCARD; buffer: ADDRESS);
BEGIN
 DosLLW (buffer, count, handle, 63);
 INLINE (AddSP, 0, 12);
 count:= REG (D0);
END Fread;


PROCEDURE Fwrite (handle: INTEGER; VAR count: LONGCARD; buffer: ADDRESS);
BEGIN
 DosLLW (buffer, count, handle, 64);
 INLINE (AddSP, 0, 12);
 count:= REG (D0);
END Fwrite;
  

PROCEDURE Fdelete (VAR name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 DosL (ADR (name), 65);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN res = LONG (0);
END Fdelete;


PROCEDURE Fseek (offset: LONGINT; handle, mode: INTEGER): LONGCARD;
BEGIN
 DosWWL (mode, handle, offset, 66);
 INLINE (AddSP, 0, 10);
 res:= REG (D0);
 RETURN res;
END Fseek;


PROCEDURE Fattrib (VAR name: ARRAY OF CHAR; wich: BOOLEAN; VAR attr: BITSET);
VAR x: CARDINAL;
BEGIN
 IF wich THEN x:= 0 ELSE x:= 1; END;
 DosWWL (attr, x, ADR(name), 67);
 INLINE (AddSP, 0, 10);
 res:= REG (D0);
 attr:= MagicSys.LCardToBitset (res);
END Fattrib;


PROCEDURE Fdup (handle: INTEGER): INTEGER;
BEGIN
 DosW (handle, 69);
 INLINE (AddSP, 0, 4);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Fdup;

            
PROCEDURE Fforce (std, nonstd: INTEGER): BOOLEAN;
BEGIN
 DosWW (nonstd, std, 70);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN res # LONG (0);
END Fforce;


PROCEDURE Dgetpath (VAR pfad: ARRAY OF CHAR; drive: CARDINAL);
BEGIN
 DosWL (drive, ADR(pfad), 71);
 INLINE (AddSP, 0, 8);
END Dgetpath;


PROCEDURE Malloc (bytes: LONGCARD): ADDRESS;
BEGIN
 DosL (bytes, 72);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN  MagicSys.LCardToAddr (res);
END Malloc;


PROCEDURE Mfree (addr: ADDRESS): BOOLEAN;
BEGIN
 DosL (addr, 73);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN res # LONG (0);  
END Mfree;


PROCEDURE Mshrink (addr: ADDRESS; newSize: LONGCARD): BOOLEAN;
BEGIN
 DosLLW (newSize, addr, 0, 74);
 INLINE (AddSP, 0, 12);
 res:= REG (D0);
 RETURN res # LONG (0);  
END Mshrink;


PROCEDURE Pexec (mode: CARDINAL; VAR name, tail, env: ARRAY OF CHAR): INTEGER;
BEGIN
 SaveA3:= REG (11);
 SaveA4:= REG (12);
 SaveA5:= REG (13);
 SaveA6:= REG (14);
 SaveA7:= REG (15);
 DosLLLW (ADR (env), ADR (tail), ADR (name), mode, 75);
 INLINE (AddSP, 0, 16);
 SETREG (11, SaveA3);
 SETREG (12, SaveA4);
 SETREG (13, SaveA5);
 SETREG (14, SaveA6);
 SETREG (15, SaveA7);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Pexec;


PROCEDURE Pterm (code: INTEGER);
BEGIN
 DosW (code, 76);
END Pterm;


PROCEDURE Fsfirst (VAR name: ARRAY OF CHAR; attr: BITSET): INTEGER;
BEGIN
 DosWL (attr, ADR (name), 78);
 INLINE (AddSP, 0, 8);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Fsfirst;


PROCEDURE Fsnext (): INTEGER;
BEGIN
 Dos (79);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Fsnext;


PROCEDURE Frename (VAR curr, new: ARRAY OF CHAR): INTEGER;
BEGIN
 DosLLW (ADR(new), ADR(curr), 0, 86);
 INLINE (AddSP, 0, 12);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Frename;


PROCEDURE Fdatime (handle: INTEGER; buff: DOSTIME; wich: BOOLEAN);
VAR x: CARDINAL;
BEGIN
 IF wich THEN x:= 0 ELSE x:= 1; END;
 DosWWL (x, handle, ADR(buff), 87);
 INLINE (AddSP, 0, 10);
END Fdatime;


END MagicDOS.

