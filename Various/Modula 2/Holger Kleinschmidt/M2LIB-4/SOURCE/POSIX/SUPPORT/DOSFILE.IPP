IMPLEMENTATION MODULE DosFile;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 26-Mai-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDLONG, UNSIGNEDWORD, SIGNEDLONG, SIGNEDWORD, WORDSET;

FROM types IMPORT
(* TYPE *) modeT, sizeT;

FROM er IMPORT
(* CONST*) eIHNDL;

FROM OSCALLS IMPORT
(* PROC *) Fopen, Fclose, Fforce, Fseek, Fcntl;

FROM blk IMPORT
(* PROC *) memfill;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  nulp : ARRAY [0..15] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE IsTerm ((* EIN/ -- *) h : INTEGER ): BOOLEAN;

VAR old  : SIGNEDLONG;
    lres : SIGNEDLONG;
    done : BOOLEAN;

BEGIN
 done := Fseek(0, h, 1, old);
 done := Fseek(1, h, 0, lres);
 done := Fseek(old, h, 0, old);

 RETURN(lres = VAL(SIGNEDLONG,0));
END IsTerm;

(*---------------------------------------------------------------------------*)

PROCEDURE IsCTerm ((* EIN/ -- *) h : INTEGER ): BOOLEAN;

CONST FSTAT = 00004600H;

TYPE
  XATTR = RECORD
    mode    : modeT;
    index   : UNSIGNEDLONG;
    dev     : UNSIGNEDWORD;
    rdev    : UNSIGNEDWORD; (* Ab MiNT 1.10 mit sinnvollem Wert *)
    nlink   : UNSIGNEDWORD;
    uid     : UNSIGNEDWORD;
    gid     : UNSIGNEDWORD;
    size    : SIGNEDLONG;
    blksize : SIGNEDLONG;
    nblocks : SIGNEDLONG;
    mtime   : WORDSET;
    mdate   : WORDSET;
    atime   : WORDSET;
    adate   : WORDSET;
    ctime   : WORDSET;
    cdate   : WORDSET;
    attr    : WORDSET;
    res1    : SIGNEDWORD;
    res2    : ARRAY [0..1] OF SIGNEDLONG;
  END;

VAR st1  : XATTR;
    st2  : XATTR;
    lres : SIGNEDLONG;

BEGIN
 IF ~(IsTerm(h) OR IsTerm(-1)) THEN
   RETURN(FALSE);
 ELSIF h = -1 THEN
   RETURN(TRUE);
 END;
 IF Fcntl(h, ADR(st1), FSTAT, lres) & Fcntl(-1, ADR(st2), FSTAT, lres) THEN
   (* Wenn <h> dieselbe Datei wie die Kennung -1 kennzeichnet, ist <h>
    * das Kontrollterminal.
    *)
   RETURN((st1.dev = st2.dev) & (st1.index = st2.index));
 END;
 (* Sonst annehmen, dass das CON:-Device gemeint ist, wenn nicht das
  * AUX:-Device gemeint ist.
  *)
 RETURN(h # -2)
END IsCTerm;

(*---------------------------------------------------------------------------*)

PROCEDURE Disconnect ((* EIN/ -- *)     h   : INTEGER;
                      (* -- /AUS *) VAR res : INTEGER ): BOOLEAN;

CONST RDWR = 2;

VAR nulh : INTEGER;
    done : BOOLEAN;

BEGIN
 IF ~IsCTerm(h) THEN
   res := eIHNDL;
   RETURN(FALSE);
 END;
 (* Kontrollterminal auf /dev/null umlenken *)
 IF Fopen(ADR(nulp), RDWR, nulh) THEN
   done := (h = -1) OR Fclose(h, res);
   done := Fforce(-1, nulh, res);
   FD[VAL(HandleRange, h)].ftype := unknown;
   FD[VAL(HandleRange,-1)].ftype := unknown;
   IF nulh # h THEN
     (* Sollte eigentlich immer der Fall sein *)
     done := (h = -1) OR Fforce(h, nulh, res);
     done := Fclose(nulh, res);
   END;
   RETURN(TRUE);
 ELSE
   res := nulh;
   RETURN(FALSE);
 END;
END Disconnect;

(*===========================================================================*)

BEGIN (* DosFile *)
 nulp := "u:\dev\null";
 memfill(ADR(FD), LC(0), VAL(sizeT,SIZE(FD)));

 WITH TTYMODE DO
   mode   := cooked;
   crmod  := TRUE;
   echo   := TRUE;
   xkey   := TRUE;
   noflsh := FALSE;
 END;
END DosFile.
