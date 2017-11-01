IMPLEMENTATION MODULE sys;
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
(* Basiert auf der MiNTLIB von Eric R. Smith und anderen                     *)
(* --------------------------------------------------------------------------*)
(* 14-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;
#ifdef MM2
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, WORDSET;

FROM MEMBLK IMPORT
(* PROC *) memalloc, memdealloc;

FROM ctype IMPORT
(* PROC *) todigit, isgraph;

FROM cstr IMPORT
(* PROC *) strncpy;

FROM types IMPORT
(* CONST*) ClkTck, EOS,
(* TYPE *) int, long, StrPtr, StrRange, PathName, sizeT, timeT, TimeCast;

FROM OSCALLS IMPORT
(* PROC *) Dpathconf, Dcntl, Dfree, Sysconf, Tgettime, Tgetdate, Tsetdate,
           Tsettime, Fopen, Fread, Fclose, Sversion;

IMPORT e;

FROM pSTRING IMPORT
(* PROC *) SLEN;

FROM cmdline IMPORT
(* PROC *) GetEnvVar;

FROM DosSystem IMPORT
(* TYPE *) CPUType, MachineType, OsPtr, OsHeader,
(* PROC *) CPU, Machine, GetOsHeader, SysconfAvail, DpathconfAvail,
           MiNTVersion, MagiXVersion;

FROM DosSupport IMPORT
(* CONST*) DINCR,
(* TYPE *) DosDate,
(* VAR  *) ROOTDIR,
(* PROC *) UnixToDos, DecodeDate, EncodeDate, DateToSeconds, SecondsToDate;

FROM file IMPORT
(* TYPE *) StatRec,
(* PROC *) stat;

FROM tim IMPORT
(* TYPE *) TmRec, TmPtr,
(* PROC *) strftime;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  hasDpathconf : BOOLEAN;
  hasSysconf   : BOOLEAN;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE gethostname ((* EIN/ -- *) buf  : StrPtr;
                       (* EIN/ -- *) blen : sizeT  ): int;

VAR tmp  : ARRAY [0..MAXHOSTNAMELEN-1] OF CHAR;
    hd   : INTEGER;
    idx  : UNSIGNEDWORD;
    len  : SIGNEDLONG;
    void : BOOLEAN;

BEGIN
 IF NOT GetEnvVar("HOSTNAME", tmp) THEN
   IF ROOTDIR <> 0C THEN
     tmp    := "@:\etc\hostname";
     tmp[0] := ROOTDIR;
   ELSE
     tmp := "\etc\hostname";
   END;
   IF Fopen(ADR(tmp), 0, hd) THEN
     tmp := "";
     IF Fread(hd, MAXHOSTNAMELEN, ADR(tmp), len) THEN
       idx := 0;
       WHILE (idx < VAL(UNSIGNEDWORD,len)) AND isgraph(tmp[idx]) DO
         INC(idx);
       END;
       IF idx < MAXHOSTNAMELEN THEN
         tmp[idx] := EOS;
       END;
     END;
     void := Fclose(hd, hd);
   ELSE
     tmp := "";
   END;
   IF tmp[0] = EOS THEN
     tmp := "?";
   END;
 END;
 strncpy(buf, ADR(tmp), blen);
 RETURN(0);
END gethostname;

(*---------------------------------------------------------------------------*)

PROCEDURE uname ((* --/AUS *) VAR info : UtsnameRec ): int;

VAR void  : INTEGER;
    MiNT  : CARDINAL;
    MagiX : CARDINAL;
    date  : DosDate;
    time  : TmRec;
    osP   : OsPtr;
    idx   : UNSIGNEDWORD;
    fmt   : ARRAY [0..2] OF CHAR;

PROCEDURE putvers ((* EIN/ -- *)     ver  : CARDINAL;
                   (* EIN/ -- *)     base : CARDINAL;
                   (* EIN/ -- *)     lohi : BOOLEAN;
                   (* EIN/ -- *) VAR idx  : UNSIGNEDWORD );

VAR __REG__ high : CARDINAL;
    __REG__ low  : CARDINAL;
    __REG__ i    : UNSIGNEDWORD;

BEGIN
 WITH info DO
   i    := idx;
   IF lohi THEN
     low  := ver DIV 256;
     high := ver MOD 256;
   ELSE
     high := ver DIV 256;
     low  := ver MOD 256;
   END;
   IF high >= base THEN
     version[i] := todigit(high DIV base); INC(i);
   END;
   version[i] := todigit(high MOD base); INC(i);
   version[i] := '.'; INC(i);
   version[i] := todigit(low DIV base); INC(i);
   version[i] := todigit(low MOD base); INC(i);
   idx := i;
 END;
END putvers;

BEGIN
 fmt   := "%x"; (* Lokales Datumsformat *)
 MiNT  := MiNTVersion();
 MagiX := MagiXVersion();
 GetOsHeader(osP);
 DecodeDate(osP^.osDosdate, WORDSET{}, date);
 WITH time DO WITH date DO
   tmMDay := day;
   tmMon  := mon;
   tmYear := year - 1900;
 END; END;

 WITH info DO
   void := gethostname(ADR(nodename), MAXHOSTNAMELEN);
   void := INT(strftime(ADR(release), 20, ADR(fmt), ADR(time)));

   idx := 0;
   putvers(VAL(CARDINAL,osP^.osVersion), 16, FALSE, idx);
   IF MagiX > 0 THEN
     version[idx] := '/'; INC(idx);
     putvers(MagiX, 16, FALSE, idx);
     sysname := "Mag!X";
   ELSIF MiNT > 0 THEN
     version[idx] := '/'; INC(idx);
     putvers(MiNT, 10, FALSE, idx);
     sysname := "TOS/MiNT";
   ELSE
     version[idx] := '/'; INC(idx);
     putvers(Sversion(), 16, TRUE, idx);
     sysname := "TOS/GEMDOS";
   END;
   version[idx] := 0C;

   CASE Machine() OF
     atariST   : machine := "Atari ST";
    |atariSTE  : machine := "Atari STE";
    |atariTT   : machine := "Atari TT030";
    |atariF030 : machine := "Atari Falcon030";
    |atariMSTE : machine := "Atari MEGA/STE";
   ELSE
                 machine := "Atari";
   END;
 END; (* WITH *)
 RETURN(0);
END uname;

(*---------------------------------------------------------------------------*)

PROCEDURE pathconf ((* EIN/ -- *) REF file  : ARRAY OF CHAR;
                    (* EIN/ -- *)     which : PConfVal      ): long;

VAR dot   : BOOLEAN;
    done  : BOOLEAN;
    limit : SIGNEDLONG;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 IF hasDpathconf THEN
   msize := SLEN(file) + DINCR;
   memalloc(VAL(sizeT,msize), stack, path0);
   UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
             path0, dot, done);
   IF NOT done THEN
     memdealloc(stack);
     RETURN(-1);
   END;
   CASE which OF
     pcMaxCanon : limit := -1; (* ?? *)
    |pcMaxInput : limit := -1; (* ?? *)
    |pcChownRestricted: limit := 0; (* ja *)
    |pcVdisable : limit := 0;
   ELSE
     IF NOT Dpathconf(path0, INT(which)+1, limit) THEN
       e.errno := INT(limit);
       limit   := -1;
     ELSIF which = pcNoTrunc THEN
       IF limit > LIC(0) THEN
         limit := -1; (* <=> Dateinamen werden gekuerzt *)
       ELSE
         limit := 0;
       END;
     END;
   END;
   memdealloc(stack);
   RETURN(limit);
 ELSE (* NOT hasDpathconf *)
   CASE which OF
     pcLinkMax  : RETURN(1);
    |pcPathMax  : RETURN(128);
    |pcNameMax  : RETURN(12);
    |pcNoTrunc  : RETURN(-1); (* -1 <=> es wird gekuerzt *)
    |pcVdisable : RETURN(0);
    |pcMaxInput : RETURN(-1); (* ? *)
    |pcMaxCanon : RETURN(-1); (* ? *)
   ELSE (* pcPipeBuf, pcChownRestricted... *)
     e.errno := e.EINVAL;
     RETURN(-1);
   END;
 END;
END pathconf;

(*---------------------------------------------------------------------------*)

PROCEDURE sysconf ((* EIN/ -- *) which : SConfVal ): long;

VAR limit : SIGNEDLONG;

BEGIN
 IF which = scVersion THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 IF hasSysconf THEN
   CASE which OF
     scArgMax     : RETURN(UNLIMITED); (* wegen "ARGV" *)
    |scClkTck     : RETURN(ClkTck);
    |scJobControl : RETURN(1);  (* ja *)
    |scSavedIds   : RETURN(-1); (* nein ?? *)
   ELSE
     IF Sysconf(INT(which)+1, limit) THEN
       RETURN(limit);
     ELSE
       e.errno := INT(limit);
       RETURN(-1);
     END;
   END;
 ELSE
   CASE which OF
     scArgMax     : RETURN(UNLIMITED); (* wegen "ARGV" *)
    |scOpenMax    : RETURN(81);        (* max. Kennung = 80 *)
    |scNGroupsMax : RETURN(0);
    |scChildMax   : RETURN(UNLIMITED);
    |scClkTck     : RETURN(ClkTck);
    |scJobControl : RETURN(-1); (* kein ``Job Control'' *)
    |scSavedIds   : RETURN(-1); (* aber kein Fehler ! *)
   ELSE
     e.errno := e.EINVAL;
     RETURN(-1);
   END;
 END;
END sysconf;

(*---------------------------------------------------------------------------*)

PROCEDURE statfs ((* EIN/ -- *) REF path : ARRAY OF CHAR;
                  (* -- /AUS *) VAR buf  : StatfsRec     ): int;
(*T*)
CONST MFSINFO  = 0104H;
      MFSBSIZE = 1024;

VAR dot   : BOOLEAN;
    done  : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    res   : INTEGER;
    lres  : SIGNEDLONG;
    path0 : StrPtr;
    st    : StatRec;
    mfsinfo : RECORD
      ninodes   : SIGNEDLONG; (* I-Nodes insgesamt *)
      nzones    : SIGNEDLONG; (* Bloecke insgesamt *)
      finodes   : SIGNEDLONG; (* freie I-Nodes *)
      fzones    : SIGNEDLONG; (* freie Bloecke *)
      version   : SIGNEDWORD; (* Typ des Dateisystems *)
      increment : SIGNEDWORD; (* -> max. Laenge von Dateinamen *)
      res       : ARRAY [0..3] OF SIGNEDLONG;
    END;
    diskinfo : RECORD
      bFree   : SIGNEDLONG; (* freie Bloecke *)
      bTotal  : SIGNEDLONG; (* Bloecke insgesamt *)
      bSecsiz : SIGNEDLONG; (* Sektorgroesse in Bytes *)
      bClsiz  : SIGNEDLONG; (* Blockgroesse in Sektoren *)
    END;

BEGIN
 IF stat(path, st) < 0 THEN
   RETURN(-1);
 END;
 msize := SLEN(path) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(path)), msize - DINCR, VAL(StrRange,msize),
           path0, dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Dcntl(MFSINFO, path0, ADR(mfsinfo), lres) THEN
   WITH buf DO WITH mfsinfo DO
     fType        := 0;
     fFsid.val[0] := VAL(SIGNEDLONG,version);
     fFsid.val[1] := 0;
     fBsize       := MFSBSIZE;
     fBlocks      := nzones;
     fBfree       := fzones;
     fBavail      := fzones;
     fFiles       := ninodes;
     fFfree       := finodes;
   END; END;
   memdealloc(stack);
   RETURN(0);
 END;

 IF NOT Dfree(ADR(diskinfo), VAL(CARDINAL,st.stDev + 1), res) THEN
   memdealloc(stack);
   e.errno := res;
   RETURN(-1);
 END;

 WITH buf DO WITH diskinfo DO
   fType        := 0;
   fFsid.val[0] := 0;
   fFsid.val[1] := 0;
   fBsize       := bSecsiz * bClsiz;
   fBlocks      := bTotal;
   fBfree       := bFree;
   fBavail      := bFree;
   fFiles       := -1;
   fFfree       := -1;
 END; END;

 memdealloc(stack);
 RETURN(0);
END statfs;

(*---------------------------------------------------------------------------*)

PROCEDURE time ((* EIN/ -- *) buf : ADDRESS ): timeT;

TYPE timeTP = POINTER TO timeT;

VAR timep : timeTP;
    time  : timeT;
    date  : DosDate;

BEGIN
 DecodeDate(Tgetdate(), Tgettime(), date);
 time := DateToSeconds(date);
 IF buf <> NULL THEN
   timep  := CAST(timeTP,buf);
   timep^ := time;
 END;
 RETURN(time);
END time;

(*---------------------------------------------------------------------------*)

PROCEDURE stime ((* EIN/ -- *) time : timeT ): int;
(**)
VAR date : DosDate;
    tc   : TimeCast;
    res  : INTEGER;

BEGIN
 IF time < VAL(timeT,0) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 SecondsToDate(time, date);
 DecodeDate(tc.date, tc.time, date);
 IF Tsetdate(tc.date, res) AND Tsettime(tc.time, res) THEN
   RETURN(0);
 END;
 IF res <> e.eACCDN THEN
   res := e.EINVAL;
 END;
 e.errno := res;
 RETURN(-1);
END stime;

(*===========================================================================*)

BEGIN (* sys *)
 hasDpathconf := DpathconfAvail();
 hasSysconf   := SysconfAvail();
END sys.
