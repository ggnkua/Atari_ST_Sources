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
(* 10-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;
#ifdef MM2
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, WORDSET, UNSIGNEDLONG;

FROM types IMPORT
(* CONST*) ClkTck, EOS, DDIRSEP,
(* TYPE *) uidT, gidT, int, long, StrPtr, StrArray, StrRange, PathName, sizeT,
           timeT, short, ushort, TimevalRec, TimevalPtr;

FROM blk IMPORT
(* PROC *) memmove, memchr, memalloc, memdealloc;

FROM ctype IMPORT
(* PROC *) tocard, todigit, isgraph, Cisalpha;

FROM str IMPORT
(* PROC *) strlen, strchr, strcmp, strcasecmp, AssignCToM2, AssignM2ToC;

FROM lib IMPORT
(* PROC *) atol;

FROM OSCALLS IMPORT
(* PROC *) Dpathconf, Dcntl, Dfree, Sysconf, Tgettime, Tgetdate, Tsetdate,
           Tsettime, Fopen, Fread, Fclose, Sversion, Pgetpgrp, Psetreuid,
           Iorec, Fxattr, Dgetdrv;

FROM er IMPORT
(* CONST*) eINVFN, EINVAL, eACCDN, eFILNF, ePTHNF,
(* VAR  *) errno;

FROM ISOStrings IMPORT
(* PROC *) Length;

FROM args IMPORT
(* PROC *) GetEnvVar;

FROM tim IMPORT
(* TYPE *) TmRec, TmPtr,
(* VAR  *) timezone, daylight,
(* PROC *) strftime;

FROM DosSystem IMPORT
(* CONST*) MNAMCk,
(* TYPE *) MachineType, OsPtr, OsHeader, CookieVal,
(* PROC *) Machine, GetOsHeader, MiNTVersion, MagiCVersion, GetCookie,
           GetPageSize, SysClock;

FROM DosTime IMPORT
(* TYPE *) DosDate, TimeCast,
(* PROC *) DecodeDate, EncodeDate, DateToSeconds, SecondsToDate;

FROM DosDir IMPORT
(* CONST*) DINCR, DDRVPOSTFIX,
(* TYPE *) XATTR,
(* VAR  *) ROOTDIR,
(* PROC *) UnixToDos, TstENOTDIR, IsDosDevice;

FROM DosText IMPORT
(* TYPE *) TextFile,
(* PROC *) OpenTextFile, CloseTextFile, RewindTextFile, NextLine;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  PWBUFSIZE = 256;
  GRBUFSIZE = 512;

CONST
  MAXMEMBER = 128;

VAR
  pwfile : TextFile;
  pwname : ARRAY [0..13] OF CHAR;
  pwrec  : PasswdRec;
  pwbuf  : ARRAY [0..PWBUFSIZE-1] OF CHAR;

  grfile : TextFile;
  grname : ARRAY [0..12] OF CHAR;
  grrec  : GroupRec;
  grbuf  : ARRAY [0..GRBUFSIZE-1] OF CHAR;
  grmem  : ARRAY [0..MAXMEMBER] OF StrPtr;

  empty  : CHAR;
  midi1  : ARRAY [0..5] OF CHAR;
  midi2  : ARRAY [0..11] OF CHAR;
  kbd1   : ARRAY [0..4] OF CHAR;
  kbd2   : ARRAY [0..10] OF CHAR;

  timebase  : TimevalRec;
  ticksbase : UNSIGNEDLONG;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE getpagesize ( ): int;
BEGIN
 RETURN(INT(GetPageSize()));
END getpagesize;

(*---------------------------------------------------------------------------*)

PROCEDURE gethostname ((* EIN/ -- *) buf  : StrPtr;
                       (* EIN/ -- *) blen : sizeT  ): int;

VAR tmp  : ARRAY [0..MAXHOSTNAMELEN-1] OF CHAR;
    hd   : INTEGER;
    idx  : UNSIGNEDWORD;
    len  : SIGNEDLONG;
    void : BOOLEAN;

BEGIN
 IF ~GetEnvVar("HOSTNAME", tmp) OR (tmp[0] = EOS) THEN
   IF ROOTDIR # 0C THEN
     tmp    := "@:\etc\hostname";
     tmp[0] := ROOTDIR;
   ELSE
     tmp := "\etc\hostname";
   END;
   IF Fopen(ADR(tmp), 0, hd) THEN
     tmp := "";
     IF Fread(hd, MAXHOSTNAMELEN, ADR(tmp), len) THEN
       idx := 0;
       WHILE (idx < VAL(UNSIGNEDWORD,len)) & isgraph(tmp[idx]) DO
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
 AssignM2ToC(tmp, VAL(StrRange,blen), buf);
 RETURN(0);
END gethostname;

(*---------------------------------------------------------------------------*)

PROCEDURE uname ((* --/AUS *) VAR info : UtsnameRec ): int;

VAR void  : INTEGER;
    MiNT  : UNSIGNEDWORD;
    MagiC : SIGNEDWORD;
    date  : DosDate;
    time  : TmRec;
    osP   : OsPtr;
    idx   : UNSIGNEDWORD;
    mnam  : CookieVal;
    fmt   : ARRAY [0..2] OF CHAR;
#if 0
PROCEDURE put2dig ((* EIN/ -- *)     num : UNSIGNEDWORD;
                   (* EIN/ -- *)     idx : UNSIGNEDWORD;
                   (* -- /AUS *) VAR str : ARRAY OF CHAR );

BEGIN
 str[idx]   := todigit(VAL(CARDINAL,num DIV 10));
 str[idx+1] := todigit(VAL(CARDINAL,num MOD 10));
END put2dig;
#endif
PROCEDURE putvers ((* EIN/ -- *)     ver  : UNSIGNEDWORD;
                   (* EIN/ -- *)     base : UNSIGNEDWORD;
                   (* EIN/ -- *)     lohi : BOOLEAN;
                   (* EIN/ -- *) VAR idx  : UNSIGNEDWORD );

VAR __REG__ high : UNSIGNEDWORD;
    __REG__ low  : UNSIGNEDWORD;
    __REG__ i    : UNSIGNEDWORD;

BEGIN
 WITH info DO
   i := idx;
   IF lohi THEN
     low  := ver DIV 256;
     high := ver MOD 256;
   ELSE
     high := ver DIV 256;
     low  := ver MOD 256;
   END;
   IF high >= base THEN
     version[i] := todigit(VAL(CARDINAL,high DIV base)); INC(i);
   END;
   version[i] := todigit(VAL(CARDINAL,high MOD base)); INC(i);
   version[i] := '.'; INC(i);
   version[i] := todigit(VAL(CARDINAL,low DIV base)); INC(i);
   version[i] := todigit(VAL(CARDINAL,low MOD base)); INC(i);
   idx := i;
 END;
END putvers;

BEGIN (* uname *)
 fmt   := "%x"; (* Lokales Datumsformat *)
 MiNT  := VAL(UNSIGNEDWORD,MiNTVersion());
 MagiC := VAL(SIGNEDWORD,MagiCVersion());
 GetOsHeader(osP);
 IF osP = NULL THEN
   DecodeDate(WORDSET{}, WORDSET{}, date);
 ELSE
   DecodeDate(osP^.osDosdate, WORDSET{}, date);
 END;
 WITH time DO WITH date DO
   tmMDay := day;
   tmMon  := mon;
   tmYear := year - 1900;
 END; END;

 WITH info DO
#if 0
   (* Amerikanisches Datumsformat *)
   put2dig(VAL(UNSIGNEDWORD,date.mon + 1), 0, release);
   release[2] := '/';
   put2dig(VAL(UNSIGNEDWORD,date.day), 3, release);
   release[5] := '/';
   put2dig(VAL(UNSIGNEDWORD,date.year - 1900), 6, release);
   release[8] := 0C;
#endif
   void := gethostname(ADR(nodename), MAXHOSTNAMELEN);
   void := INT(strftime(ADR(release), 20, ADR(fmt), ADR(time)));

   idx := 0;
   IF osP = NULL THEN
     putvers(0, 16, FALSE, idx);
   ELSE
     putvers(osP^.osVersion, 16, FALSE, idx);
   END;
   IF MagiC >= 0 THEN
     version[idx] := '/'; INC(idx);
     putvers(MagiC, 16, FALSE, idx);
     sysname := "MagiC!";
   ELSIF MiNT > 0 THEN
     version[idx] := '/'; INC(idx);
     putvers(MiNT, 10, FALSE, idx);
     sysname := "TOS/MiNT";
   ELSE
     version[idx] := '/'; INC(idx);
     putvers(VAL(UNSIGNEDWORD,Sversion()), 16, TRUE, idx);
     sysname := "TOS/GEMDOS";
   END;
   version[idx] := 0C;

   IF GetCookie(MNAMCk, mnam) & (mnam.ptr # NULL) THEN
     AssignCToM2(mnam.ptr, 0, machine);
   ELSE
     CASE Machine() OF
       atariST      : machine := "ATARI ST";
      |atariSTE     : machine := "ATARI STE";
      |atariTT      : machine := "ATARI TT030";
      |atariF030    : machine := "ATARI Falcon030";
      |atariSTBOOK  : machine := "ATARI ST-Book";
      |atariSTEIDE  : machine := "ATARI STE+IDE";
      |atariMSTE    : machine := "ATARI MEGA/STE";
      |atariSPARROW : machine := "ATARI Sparrow";
      |NoAtari      : machine := "NO ATARI";
     ELSE             machine := "UNKNOWN";
     END;
   END;
 END; (* WITH *)
 RETURN(0);
END uname;

(*---------------------------------------------------------------------------*)

PROCEDURE pathconf ((* EIN/ -- *) REF file  : ARRAY OF CHAR;
                    (* EIN/ -- *)     which : PConfVal      ): long;

VAR dot   : BOOLEAN;
    done  : BOOLEAN;
    res   : INTEGER;
    limit : SIGNEDLONG;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;
    plen  : StrRange;
    tlen  : StrRange;
    iorec : POINTER TO RECORD
      ibuf     : ADDRESS;
      ibufsize : SIGNEDWORD;
    END;

PROCEDURE getpconf ((* EIN/ -- *) which : PConfVal ): BOOLEAN;
BEGIN
 IF Dpathconf(path0, ORD(which), limit) THEN
   RETURN(TRUE);
 ELSIF limit # VAL(SIGNEDLONG,eINVFN) THEN
   (* Noch mal Originalpfad probieren *)
   path0^[plen] := 0C;
   IF Dpathconf(path0, ORD(which), limit) THEN
     RETURN(TRUE);
   END;
 END;
 IF limit = VAL(SIGNEDLONG,eINVFN) THEN
   RETURN(FALSE);
 ELSE
   done  := FALSE;
   res   := INT(limit);
   limit := -1;
   RETURN(TRUE);
 END;
END getpconf;

BEGIN (* pathconf *)
 msize := Length(file) + DINCR;
 memalloc(VAL(sizeT,msize + 2), stack, path0);  (* + "\." *)
 UnixToDos(REFADR(file), msize - DINCR, VAL(StrRange,msize), path0, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;
 plen := VAL(StrRange,strlen(path0));
 tlen := plen;
 (* Falls 'path0' ein symbolischer Link auf ein Verzeichnis ist, wird
  * durch Anhaengen von \. der Link aufgeloest. Falls es kein symbolischer
  * Link auf ein Verzeichnis ist oder . in diesem Verzeichnis nicht
  * existiert, noch mal mit dem urspruenglichen Pfad versuchen.
  *)
 IF (tlen # 0) & (path0^[tlen-1] # DDIRSEP) THEN
   path0^[tlen] := DDIRSEP; INC(tlen);
 END;
 path0^[tlen]   := '.';
 path0^[tlen+1] := 0C;

 CASE which OF
   pcVdisable:
     limit := 0;
  |pcLinkMax:
     IF ~getpconf(pcLinkMax) THEN
       limit := 1;
     END;
  |pcPathMax:
     IF ~getpconf(pcPathMax) THEN
       limit := 128;
     END;
  |pcNameMax:
     IF ~getpconf(pcNameMax) THEN
       limit := 8 + 1 + 3;
     END;
  |pcPipeBuf:
     IF ~getpconf(pcPipeBuf) THEN
       limit := 512; (* Ein Sektor *)
     END;
  |pcNoTrunc:
     IF getpconf(pcNoTrunc) THEN
       IF done THEN
         IF limit > VAL(SIGNEDLONG,0) THEN
           limit := -1; (* <=> Dateinamen werden gekuerzt *)
         ELSE
           limit := 0;
         END;
       END;
     ELSE
       limit := -1 (* <=> es wird gekuerzt *)
     END;
  |pcMaxCanon,
   pcMaxInput:
     IF (strcasecmp(ADR(kbd1), path0)=0) OR (strcasecmp(ADR(kbd2), path0)=0) THEN
       iorec := Iorec(1);
     ELSIF (strcasecmp(ADR(midi1), path0)=0) OR (strcasecmp(ADR(midi2), path0)=0) THEN
       iorec := Iorec(2);
     ELSE
       iorec := Iorec(0);
     END;
     (* Ergebnis durch Vier teilen, da das BIOS Langworte liefert. *)
     limit := VAL(SIGNEDLONG,iorec^.ibufsize DIV 4);
  |pcChownRestricted:
     limit := 0; (* ja *)
 ELSE
   errno := EINVAL;
   limit := -1;
 END;

 IF ~done THEN
   TstENOTDIR(path0, FALSE, res);
   errno := res;
 END;
 memdealloc(stack);
 RETURN(limit);
END pathconf;

(*---------------------------------------------------------------------------*)

PROCEDURE sysconf ((* EIN/ -- *) which : SConfVal ): long;

VAR limit : SIGNEDLONG;
    res   : INTEGER;

BEGIN
 CASE which OF
   scClkTck:
     RETURN(ClkTck);
  |scArgMax:
     RETURN(UNLIMITED); (* wegen "ARGV" *)
  |scOpenMax:
     IF Sysconf(ORD(scOpenMax), limit) THEN
       RETURN(limit);
     ELSIF limit = VAL(SIGNEDLONG,eINVFN) THEN
       RETURN(81); (* 0..80 *)
     ELSE
       errno := INT(limit);
       RETURN(-1);
     END;
  |scNGroupsMax:
     IF Sysconf(ORD(scNGroupsMax), limit) THEN
       RETURN(limit);
     ELSIF limit = VAL(SIGNEDLONG,eINVFN) THEN
       RETURN(0);
     ELSE
       errno := INT(limit);
       RETURN(-1);
     END;
  |scChildMax:
     IF Sysconf(ORD(scChildMax), limit) THEN
       RETURN(limit);
     ELSIF limit = VAL(SIGNEDLONG,eINVFN) THEN
       RETURN(UNLIMITED);
     ELSE
       errno := INT(limit);
       RETURN(-1);
     END;
  |scJobControl:
     IF Pgetpgrp() = eINVFN THEN
       (* ANNAHME: Prozessgruppen sind ein Indikator fuer das
        * Vorhandensein von Vorder/Hintergrundprozessen.
        *)
       RETURN(-1);
     ELSE
       RETURN(1);
     END;
  |scSavedIds:
     IF Psetreuid(-1, -1, res) THEN
       (* ANNAHME: 'Psetreuid/gid' sind sinnlos ohne das Vorhandensein von
        * saved set IDs.
        * Es w„ren allerdings saved set IDs denkbar ohne diese Funktionen.
        *)
       RETURN(0);
     ELSE
       RETURN(-1); (* aber kein Fehler ! *)
     END;
  |scVersion:
     RETURN(0); (* Nicht POSIX-kompatibel *)
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END sysconf;

(*---------------------------------------------------------------------------*)

PROCEDURE statfs ((* EIN/ -- *) REF path : ARRAY OF CHAR;
                  (* -- /AUS *) VAR buf  : StatfsRec     ): int;

CONST MFSINFO  = 0104H;
      MFSBSIZE = 1024;

VAR dot   : BOOLEAN;
    done  : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    res   : INTEGER;
    lres  : SIGNEDLONG;
    path0 : StrPtr;
    xattr : XATTR;
    drive : CARDINAL;
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
 msize := Length(path) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(path), msize - DINCR, VAL(StrRange,msize), path0, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Dcntl(MFSINFO, path0, ADR(mfsinfo), lres) THEN
   WITH buf DO WITH mfsinfo DO
     fType        := VAL(SIGNEDLONG,version);
     fFsid.val[0] := -1;
     fFsid.val[1] := -1;
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

 IF Fxattr(1, path0, ADR(xattr), res) THEN
   drive := VAL(CARDINAL,xattr.dev + 1);
 ELSIF res # eINVFN THEN
   TstENOTDIR(path0, FALSE, res);
   errno := res;
   memdealloc(stack);
   RETURN(-1);
 ELSIF Cisalpha(path0^[0]) & (path0^[1] = DDRVPOSTFIX) THEN
   drive := tocard(path0^[0]) - 10 + 1;
 ELSE
   drive := 0;
 END;

 IF ~Dfree(ADR(diskinfo), drive, res) THEN
   memdealloc(stack);
   errno := res;
   RETURN(-1);
 END;

 WITH buf DO WITH diskinfo DO
   fType        := 0;
   fFsid.val[0] := -1;
   fFsid.val[1] := -1;
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
 IF buf # NULL THEN
   timep  := CAST(timeTP,buf);
   timep^ := time;
 END;
 RETURN(time);
END time;

(*---------------------------------------------------------------------------*)

PROCEDURE stime ((* EIN/ -- *) time : timeT ): int;

VAR date : DosDate;
    tc   : TimeCast;
    res  : INTEGER;

BEGIN
 IF time < VAL(timeT,0) THEN
   errno := EINVAL;
   RETURN(-1);
 END;
 SecondsToDate(time, date);
 EncodeDate(date, tc.ddate, tc.dtime);
 IF Tsetdate(tc.ddate, res) & Tsettime(tc.dtime, res) THEN
   RETURN(0);
 END;
 IF res # eACCDN THEN
   res := EINVAL;
 END;
 errno := res;
 RETURN(-1);
END stime;

(*---------------------------------------------------------------------------*)

PROCEDURE gettimeofday ((* EIN/ -- *) tp  : TimevalPtr;
                        (* EIN/ -- *) tzp : TimezonePtr ): int;

VAR ticksinc : UNSIGNEDLONG;

BEGIN
 IF tp # NULL THEN
   ticksinc   := SysClock() - ticksbase;
   tp^.tvSec  := CAST(UNSIGNEDLONG,timebase.tvSec) + (ticksinc DIV LC(200));
   tp^.tvUSec := timebase.tvUSec + CAST(long,(ticksinc MOD LC(200)) * LC(5000));
   IF tp^.tvUSec >= LIC(1000000) THEN
     DEC(tp^.tvUSec, LIC(1000000));
     INC(tp^.tvSec);
   END;
 END;
 IF tzp # NULL THEN
   tzp^.tzMinuteswest := INT(timezone DIV VAL(long,60));
   IF daylight THEN
     tzp^.tzDsttime := 1;
   ELSE
     tzp^.tzDsttime := 0;
   END;
 END;
 RETURN(0);
END gettimeofday;

(*---------------------------------------------------------------------------*)

PROCEDURE settimeofday ((* EIN/ -- *) tp  : TimevalPtr;
                        (* EIN/ -- *) tzp : TimezonePtr ): int;

VAR res : INTEGER;

BEGIN
 IF tp # NULL THEN
   res := stime(tp^.tvSec);
   IF res = 0 THEN
     timebase  := tp^;
     ticksbase := SysClock();
   END;
 END;
 RETURN(res);
END settimeofday;

(*---------------------------------------------------------------------------*)

PROCEDURE ftime ((* -- /AUS *) VAR buf : TimebRec );

VAR tb  : TimevalRec;
    tzb : TimezoneRec;
    res : INTEGER;

BEGIN
 res := gettimeofday(ADR(tb), ADR(tzb));
 buf.time     := tb.tvSec;
 buf.millitm  := VAL(ushort,tb.tvUSec DIV VAL(long,1000));
 buf.timezone := VAL(short,tzb.tzMinuteswest);
 buf.dstflag  := VAL(short,tzb.tzDsttime);
END ftime;

(*---------------------------------------------------------------------------*)

PROCEDURE IsId ((* EIN/ -- *) line : StrPtr;
                (* EIN/ -- *) id   : UNSIGNEDWORD ): BOOLEAN;

VAR __REG__ s : StrPtr;

BEGIN
 s := strchr(line, ':');
 IF s # NULL THEN
   s := strchr(ADDADR(s, 1), ':');
   IF s # NULL THEN
     RETURN(atol(ADDADR(s, 1)) = VAL(long,id));
   END;
 END;
 RETURN(FALSE);
END IsId;

(*---------------------------------------------------------------------------*)

PROCEDURE IsName ((* EIN/ -- *) line : StrPtr;
                  (* EIN/ -- *) name : StrPtr ): BOOLEAN;

VAR __REG__ s  : StrPtr;
    __REG__ eq : BOOLEAN;

BEGIN
 s := strchr(line, ':');
 IF s # NULL THEN
   s^[0] := 0C;
 END;
 eq := strcmp(name, line) = 0;
 IF s # NULL THEN
   s^[0] := ':';
 END;
 RETURN(eq);
END IsName;

(*---------------------------------------------------------------------------*)

PROCEDURE SplitPwLine ((* EIN/ -- *)     line : StrPtr;
                       (* -- /AUS *) VAR pw   : PasswdRec );

VAR __REG__ s : StrPtr;

BEGIN
 WITH pw DO
   pwName   := line;
   pwPasswd := ADR(empty);
   pwUid    := 0;
   pwGid    := 0;
   pwGecos  := ADR(empty);
   pwDir    := ADR(empty);
   pwShell  := ADR(empty);

   s := strchr(line, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s^[0]    := 0C; (* 'pwName' beenden *)
     s        := ADDADR(s, 1);
     pwPasswd := s;
   END;
   s := strchr(s, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s^[0] := 0C; (* 'pwPasswd' beenden *)
     s     := ADDADR(s, 1);
     pwUid := VAL(uidT,atol(s));
   END;
   s := strchr(s, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s     := ADDADR(s, 1);
     pwGid := VAL(gidT,atol(s));
   END;
   s := strchr(s, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s       := ADDADR(s, 1);
     pwGecos := s;
   END;
   s := strchr(s, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s^[0] := 0C; (* 'pwGecos' beenden *)
     s     := ADDADR(s, 1);
     pwDir := s;
   END;
   s := strchr(s, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s^[0]   := 0C; (* 'pwDir' beenden *)
     s       := ADDADR(s, 1);
     pwShell := s;
   END;
   s := strchr(s, ':');
   IF s # NULL THEN
     s^[0]   := 0C; (* 'pwShell' beenden, sollte eigentlich nicht noetig sein *)
   END;
 END;
END SplitPwLine;

(*---------------------------------------------------------------------------*)

PROCEDURE SplitGrLine ((* EIN/ -- *)     line : StrPtr;
                       (* -- /AUS *) VAR gr   : GroupRec );

VAR __REG__ s : StrPtr;
    __REG__ i : UNSIGNEDWORD;

BEGIN
 grmem[0] := NULL;
 WITH gr DO
   grName   := line;
   grPasswd := ADR(empty);
   grGid    := 0;
   grMem    := ADR(grmem);

   s := strchr(line, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s^[0]    := 0C; (* 'grName' beenden *)
     s        := ADDADR(s, 1);
     grPasswd := s;
   END;
   s := strchr(s, ':');
   IF s = NULL THEN
     RETURN;
   ELSE
     s^[0] := 0C; (* 'grPasswd' beenden *)
     s     := ADDADR(s, 1);
     grGid := VAL(gidT,atol(s));
   END;
   s := strchr(s, ':');
   IF (s = NULL) OR (s^[1] = 0C) THEN
     RETURN;
   ELSE
     s := ADDADR(s, 1);
     i := 0;
     LOOP
       grmem[i] := s;
       INC(i);
       s := strchr(s, ',');
       IF s # NULL THEN
         s^[0] := 0C;
         s     := ADDADR(s, 1);
       ELSE
         EXIT;
       END;
       IF i = MAXMEMBER THEN
         EXIT;
       END;
     END;
     grmem[i] := NULL;
   END;
 END;
END SplitGrLine;

(*---------------------------------------------------------------------------*)

PROCEDURE setpwent;
BEGIN
 IF pwfile.open THEN
   RewindTextFile(pwfile);
 ELSE
   OpenTextFile(ADR(pwname), pwfile);
 END;
END setpwent;

(*---------------------------------------------------------------------------*)

PROCEDURE endpwent;
BEGIN
 CloseTextFile(pwfile);
END endpwent;

(*---------------------------------------------------------------------------*)

PROCEDURE getpwent ( ): PasswdPtr;

VAR len : UNSIGNEDWORD;

BEGIN
 IF ~pwfile.open THEN
   OpenTextFile(ADR(pwname), pwfile);
 END;
 IF ~(pwfile.open & NextLine(pwfile, PWBUFSIZE, ADR(pwbuf), len)) THEN
   RETURN(NULL);
 END;
 SplitPwLine(ADR(pwbuf), pwrec);
 RETURN(ADR(pwrec));
END getpwent;

(*---------------------------------------------------------------------------*)

PROCEDURE getpwnam ((* EIN/ -- *) REF name : ARRAY OF CHAR ): PasswdPtr;

VAR wasOpen : BOOLEAN;
    len     : UNSIGNEDWORD;
    msize   : sizeT;
    stack   : ADDRESS;
    name0   : StrPtr;

BEGIN
 wasOpen := pwfile.open;
 setpwent;
 IF ~pwfile.open THEN
   RETURN(NULL);
 END;

 (* <name> wird mit einem Nullbyte abgeschlossen *)
 msize := VAL(sizeT,Length(name) + 1);
 memalloc(msize, stack, name0);
 AssignM2ToC(name, VAL(StrRange,msize), name0);

 WHILE NextLine(pwfile, PWBUFSIZE, ADR(pwbuf), len) DO
   IF IsName(ADR(pwbuf), name0) THEN
     SplitPwLine(ADR(pwbuf), pwrec);
     IF ~wasOpen THEN
       endpwent;
     END;
     memdealloc(stack);
     RETURN(ADR(pwrec));
   END;
 END;
 IF ~wasOpen THEN
   endpwent;
 END;
 memdealloc(stack);
 RETURN(NULL);
END getpwnam;

(*---------------------------------------------------------------------------*)

PROCEDURE getpwuid ((* EIN/ -- *) uid : uidT ): PasswdPtr;

VAR wasOpen : BOOLEAN;
    len     : UNSIGNEDWORD;

BEGIN
 wasOpen := pwfile.open;
 setpwent;
 IF ~pwfile.open THEN
   RETURN(NULL);
 END;
 WHILE NextLine(pwfile, PWBUFSIZE, ADR(pwbuf), len) DO
   IF IsId(ADR(pwbuf), VAL(UNSIGNEDWORD,uid)) THEN
     SplitPwLine(ADR(pwbuf), pwrec);
     IF ~wasOpen THEN
       endpwent;
     END;
     RETURN(ADR(pwrec));
   END;
 END;
 IF ~wasOpen THEN
   endpwent;
 END;
 RETURN(NULL);
END getpwuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setgrent;
BEGIN
 IF grfile.open THEN
   RewindTextFile(grfile);
 ELSE
   OpenTextFile(ADR(grname), grfile);
 END;
END setgrent;

(*---------------------------------------------------------------------------*)

PROCEDURE endgrent;
BEGIN
 CloseTextFile(grfile);
END endgrent;

(*---------------------------------------------------------------------------*)

PROCEDURE getgrent ( ): GroupPtr;

VAR len : UNSIGNEDWORD;

BEGIN
 IF ~grfile.open THEN
   OpenTextFile(ADR(grname), grfile);
 END;
 IF ~(grfile.open & NextLine(grfile, GRBUFSIZE, ADR(grbuf), len)) THEN
   RETURN(NULL);
 END;
 SplitGrLine(ADR(grbuf), grrec);
 RETURN(ADR(grrec));
END getgrent;

(*---------------------------------------------------------------------------*)

PROCEDURE getgrnam ((* EIN/ -- *) REF name : ARRAY OF CHAR ): GroupPtr;

VAR wasOpen : BOOLEAN;
    len     : UNSIGNEDWORD;
    msize   : sizeT;
    stack   : ADDRESS;
    name0   : StrPtr;

BEGIN
 wasOpen := grfile.open;
 setgrent;
 IF ~grfile.open THEN
   RETURN(NULL);
 END;

 (* <name> wird mit einem Nullbyte abgeschlossen *)
 msize := VAL(sizeT,Length(name) + 1);
 memalloc(msize, stack, name0);
 AssignM2ToC(name, VAL(StrRange,msize), name0);

 WHILE NextLine(grfile, GRBUFSIZE, ADR(grbuf), len) DO
   IF IsName(ADR(grbuf), name0) THEN
     SplitGrLine(ADR(grbuf), grrec);
     IF ~wasOpen THEN
       endgrent;
     END;
     memdealloc(stack);
     RETURN(ADR(grrec));
   END;
 END;
 IF ~wasOpen THEN
   endgrent;
 END;
 memdealloc(stack);
 RETURN(NULL);
END getgrnam;

(*---------------------------------------------------------------------------*)

PROCEDURE getgrgid ((* EIN/ -- *) gid : gidT ): GroupPtr;

VAR wasOpen : BOOLEAN;
    len     : UNSIGNEDWORD;

BEGIN
 wasOpen := grfile.open;
 setgrent;
 IF ~grfile.open THEN
   RETURN(NULL);
 END;
 WHILE NextLine(grfile, GRBUFSIZE, ADR(grbuf), len) DO
   IF IsId(ADR(grbuf), VAL(UNSIGNEDWORD,gid)) THEN
     SplitGrLine(ADR(grbuf), grrec);
     IF ~wasOpen THEN
       endgrent;
     END;
     RETURN(ADR(grrec));
   END;
 END;
 IF ~wasOpen THEN
   endgrent;
 END;
 RETURN(NULL);
END getgrgid;

(*===========================================================================*)

BEGIN (* sys *)
 midi1       := "midi:";
 midi2       := "u:\dev\midi";
 kbd1        := "kbd:";
 kbd2        := "u:\dev\kbd";
 empty       := 0C;
 grfile.open := FALSE;
 pwfile.open := FALSE;
 IF ROOTDIR # 0C THEN
   pwname    := "@:\etc\passwd";
   pwname[0] := ROOTDIR;
   grname    := "@:\etc\group";
   grname[0] := ROOTDIR;
 ELSE
   pwname := "\etc\passwd";
   grname := "\etc\group";
 END;
 timebase.tvSec  := time(NULL);
 timebase.tvUSec := LC(0);
 ticksbase       := SysClock();
END sys.
