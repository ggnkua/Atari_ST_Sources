IMPLEMENTATION MODULE proc;
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
INLINE_CODE_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;
#ifdef MM2
FROM SYSTEM IMPORT (* PROC *) CADR;
FROM MOSCtrl IMPORT (* VAR  *) ActMOSProcess, BaseProcess;
#endif

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, ANYLONG,
           WORDSET;

FROM types IMPORT
(* CONST*) EOS, SUFFIXSEP, DDIRSEP, XDIRSEP, MAXSTR, PATHMAX,
(* TYPE *) int, unsigned, long, sizeT, uidT, gidT, pidT, clockT, StrArray,
           StrPtr, StrRange, ArrayRange, modeT, TimevalRec, TimevalPtr;

FROM blk IMPORT
(* PROC *) memalloc, memdealloc, memset;

FROM pLONGSET IMPORT
(* PROC *) LONGELEM, LONGINCL, LONGEXCL, LONGMASK;

FROM OSCALLS IMPORT
(* PROC *) Pgetpid, Pgetppid, Pgetuid, Pgetgid, Pgeteuid, Pgetegid, Psetuid,
           Psetgid, Pgetpgrp, Psetpgrp, Pfork, Pwait3, Pwaitpid, Malloc, Mfree,
           Mshrink, Pexec, Prusage, Fclose, Fselect, Dgetdrv, Pumask,
           Dsetdrv, Dsetpath, Fcntl, Fopen, Fforce, Cconis, Cconos, Cauxis,
           Cauxos, Pseteuid, Psetegid, Psetreuid, Psetregid, Pgetgroups,
           Psetgroups, Dpathconf, Pnice, Prenice;
#ifdef MM2
FROM OSCALLS IMPORT Psigblock, Psigsetmask;
#endif

FROM ctype IMPORT
(* PROC *) tocard, todigit, Cisalpha;

FROM str IMPORT
(* PROC *) strlen, strcpy, strncpy, strrchr, strlwr, strupr, strcmp, Token,
           AssignM2ToC;

FROM ISOStrings IMPORT
(* PROC *) Length;

FROM args IMPORT
(* VAR  *) environ,
(* PROC *) getenv, GetEnvVar;

FROM er IMPORT
(* CONST*) ERANGE, eRANGE, eINVFN, eACCDN, EPERM, ESRCH, eBREAK, ECHILD,
           EFAULT, E2BIG, ENOENT, EINVAL,
(* VAR  *) errno;

FROM DosSystem IMPORT
(* CONST*) MINSIG, MAXSIG,
(* TYPE *) CmdLine, BasePtr, BasePage, DosHandler,
(* VAR  *) BASEP, SIGMASK, SIGPENDING, SIGHANDLER,
(* PROC *) DosPid, ActPid, SysClock, MiNTVersion, MagiCVersion, Exit;

FROM DosFile IMPORT
(* PROC *) Disconnect;

FROM DosDir IMPORT
(* CONST*) TOSEXT, DINCR, XDECR,
(* VAR  *) UMASK,
(* PROC *) CompletePath, UnixToDos, DosToUnix, FileExists, PathToken,
           SplitPath, TstENOTDIR;

FROM sig IMPORT
(* CONST*) NSIG, SIGCHLD,
(* PROC *) raise;

FROM sys IMPORT
(* TYPE *) PasswdRec, PasswdPtr, GroupRec, GroupPtr, SConfVal,
(* PROC *) getpwuid, setgrent, getgrent, endgrent, sysconf;

(*==========================================================================*)

CONST
  DELIMITER = ",;";
  DELIMLEN  = 2;

CONST
  EOKL = LIC(0);

CONST
  BPSIZE = 256; (* Groesse einer Basepage *)

TYPE
  LONGfdset = RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: fdset  : fdSet;
     |TRUE : fdlong : UNSIGNEDLONG;
    END;
  END;

(* Lokale Umdefinition der Basepage fuer "tfork()" *)
TYPE
  BPtr  = POINTER TO BPage;
  BPage = RECORD
    lowtpa : ADDRESS;
    hitpa  : ADDRESS;
    tbase  : PROC;
    tlen   : UNSIGNEDLONG;
    dbase  : ADDRESS;
    dlen   : UNSIGNEDLONG;
    bbase  : ADDRESS;
    blen   : UNSIGNEDLONG;
    dta    : ADDRESS;
    parent : BPtr;
    res1   : UNSIGNEDLONG;
    env    : ADDRESS;
    res2   : ARRAY [0..49] OF ANYLONG;
    (* Die restlichen zwei Langworte der Kommandozeile
       (die leer ist) dienen als Zwischenspeicher fuer
       die Uebergabe des ``Thread'' und dessen Parameter.
     *)
    tProc  : ThreadProc;
    tArg   : ANYLONG;
  END;

TYPE
  WaitCode =  RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: long : SIGNEDLONG;
     |TRUE : pid  : UNSIGNEDWORD;
             term : SIGNEDWORD;
    END;
  END;

CONST
  MAXLOGIN = 32;

VAR
  loginbuf  : ARRAY [0..MAXLOGIN] OF CHAR;
  hasXPexec : BOOLEAN; (* hat Pexec(100/104/200...) *)
  MiNT      : BOOLEAN; (* Ist MiNT vorhanden ? *)
  DefExt    : ARRAY [0..29] OF CHAR;
  DefPath   : ARRAY [0..1] OF CHAR;
  Delim     : ARRAY [0..DELIMLEN] OF CHAR;
  Stacksize : CARDINAL;
  CHILDTIME : UNSIGNEDLONG;
  WAITTIME  : UNSIGNEDLONG;
  WAITVAL   : WaitCode;
  errnoADR  : ADDRESS;
  tforkADR  : ADDRESS;
  mintADR   : ADDRESS;
  saveADR   : ADDRESS;

(* Die folgenden Variablen muessten als Stack verwaltet werden, damit
 * Verschachtelungen von "vfork()" moeglich werden. Das ist moeglich,
 * da immer nur ein vfork-Unterprozess aktiv ist, auch wenn 'Pvfork'
 * verwendet wurde.
 *)
#if (defined LPRM2) || (defined SPCM2)
  regsave   : ARRAY [0..3] OF ADDRESS;
#elif (defined TDIM2)
  regsave   : ARRAY [0..2] OF ADDRESS;
#elif (defined HM2)
  regsave   : ARRAY [0..12] OF ADDRESS;
#elif (defined MM2)
  regsave   : ARRAY [0..7] OF ADDRESS;
  RtnAdr    : ADDRESS;
  ActMOSProc: ADDRESS;
  BaseProc  : ADDRESS;
  ProcMask  : UNSIGNEDLONG;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE umask ((* EIN/ -- *) excl : modeT ): modeT;

VAR oldmask : modeT;
    lres    : SIGNEDLONG;

BEGIN
 oldmask := UMASK;
 UMASK   := excl;
 lres    := Pumask(excl);
 IF lres < VAL(SIGNEDLONG,0) THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(oldmask);
 ELSE
   RETURN(CAST(modeT,VAL(UNSIGNEDWORD,lres)));
 END;
END umask;

(*---------------------------------------------------------------------------*)

PROCEDURE chdir ((* EIN/ -- *) REF dir : ARRAY OF CHAR ): int;

VAR old   : CARDINAL;
    res   : INTEGER;
    drvs  : UNSIGNEDLONG;
    dot   : BOOLEAN;
    done  : BOOLEAN;
    start : UNSIGNEDWORD;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 msize := Length(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(dir)), msize - DINCR, VAL(StrRange,msize), path0,
           dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 (* aktuelles Laufwerk merken, fuer Fehlerfall *)
 old := Dgetdrv();

 start := 0;
 IF path0^[0] = 0C THEN
   path0^[0] := DDIRSEP;
   path0^[1] := 0C;
 ELSIF path0^[1] = ':' THEN
   (* neues Laufwerk setzen *)
   drvs  := Dsetdrv(tocard(path0^[0]) - 10);
   start := 2;
 END;

 (* Pfad ohne Laufwerksangabe setzen *)
 IF Dsetpath(ADDADR(path0, start), res) THEN
   res := 0;
 ELSE
   drvs := Dsetdrv(old); (* altes Laufwerk einstellen *)
   TstENOTDIR(path0, TRUE, res);
   errno := res;
   res   := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END chdir;

(*---------------------------------------------------------------------------*)

PROCEDURE getcwd ((* EIN/ -- *) buf    : StrPtr;
                  (* EIN/ -- *) bufsiz : sizeT  ): StrPtr;

CONST DPCASE = 6;
        DPCASECONV = 1;

VAR err   : INTEGER;
    lres  : SIGNEDLONG;
    dlen  : INTEGER;
    xlen  : INTEGER;
    str1  : CHAR;
    stack : ADDRESS;
    msize : StrRange;
    path0 : StrPtr;
    res   : StrPtr;

BEGIN
 IF VAL(sizeT,MAXSTR) < bufsiz THEN
   bufsiz := VAL(sizeT,MAXSTR);
 END;
 msize := VAL(StrRange,bufsiz) + XDECR;
 IF msize < PATHMAX THEN
   (* mindestens PATHMAX Zeichen Puffer fuer TOS bereitstellen *)
   msize := PATHMAX;
 END;
 memalloc(VAL(sizeT,msize), stack, path0);
 str1 := 0C;
 res  := NULL;
 IF CompletePath(ADR(str1), msize, path0, dlen, err) THEN
   (* Nur wenn das Dateisystem den Dpathconf(DP_CASE)-Aufruf nicht kennt,
    * oder wenn sowieso grundsaetzlich in Grossbuchstaben konvertiert
    * wird, werden die Dateinamen in Kleinbuchstaben konvertiert, sonst
    * werden vom Dateisystem Gross/Kleinbuchstaben entweder unterschieden
    * oder zumindest beibehalten.
    *)
   DosToUnix(path0,
             ~Dpathconf(path0, DPCASE, lres) OR (INT(lres) = DPCASECONV),
             VAL(StrRange,bufsiz),
             buf,
             dlen,
             xlen);

   IF VAL(sizeT,xlen) < bufsiz THEN
     res := buf;
   ELSE
     errno := ERANGE;
   END;
 ELSIF err = eRANGE THEN
   errno := ERANGE;
 ELSE
   errno := err;
 END;
 memdealloc(stack);
 RETURN(res);
END getcwd;

(*--------------------------------------------------------------------------*)

PROCEDURE getlogin ( ): StrPtr;

VAR uid : INTEGER;
    pw  : PasswdPtr;

BEGIN
 IF GetEnvVar("LOGNAME", loginbuf) & (loginbuf[0] # EOS) THEN
   (* 'LOGNAME' existiert und hat einen Wert *)
   loginbuf[MAXLOGIN] := 0C;
   RETURN(ADR(loginbuf));
 END;
 loginbuf := "root";
 uid := Pgetuid();
 IF uid < 0 THEN
   RETURN(ADR(loginbuf));
 END;
 pw := getpwuid(VAL(uidT,uid));
 IF pw = NULL THEN
   IF uid = 0 THEN
     RETURN(ADR(loginbuf));
   ELSE
     RETURN(NULL);
   END;
 ELSE
   strncpy(ADR(loginbuf), pw^.pwName, MAXLOGIN);
   loginbuf[MAXLOGIN] := 0C;
   RETURN(ADR(loginbuf));
 END;
END getlogin;

(*--------------------------------------------------------------------------*)

PROCEDURE getpid ( ): pidT;
BEGIN
 RETURN(ActPid());
END getpid;

(*---------------------------------------------------------------------------*)

PROCEDURE getppid ( ): pidT;

VAR pid : INTEGER;

BEGIN
 pid := Pgetppid();
 IF pid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(DosPid(BASEP^.pParent));
 ELSE
   RETURN(pid);
 END;
END getppid;

(*---------------------------------------------------------------------------*)

PROCEDURE getuid ( ): uidT;

VAR uid : INTEGER;

BEGIN
 uid := Pgetuid();
 IF uid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(0);
 ELSE
   RETURN(VAL(uidT,uid));
 END;
END getuid;

(*---------------------------------------------------------------------------*)

PROCEDURE getgid ( ): gidT;

VAR gid : INTEGER;

BEGIN
 gid := Pgetgid();
 IF gid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(0);
 ELSE
   RETURN(VAL(gidT,gid));
 END;
END getgid;

(*---------------------------------------------------------------------------*)

PROCEDURE geteuid ( ): uidT;

VAR uid : INTEGER;

BEGIN
 uid := Pgeteuid();
 IF uid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(0);
 ELSE
   RETURN(VAL(uidT,uid));
 END;
END geteuid;

(*---------------------------------------------------------------------------*)

PROCEDURE getegid ( ): gidT;

VAR gid : INTEGER;

BEGIN
 gid := Pgetegid();
 IF gid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(0);
 ELSE
   RETURN(VAL(gidT,gid));
 END;
END getegid;

(*---------------------------------------------------------------------------*)

PROCEDURE setuid ((* EIN/ -- *) ruid : uidT ): int;

VAR res : INTEGER;

BEGIN
 IF Psetuid(ruid, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF ruid = 0 THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END setuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setgid ((* EIN/ -- *) rgid : gidT ): int;

VAR res : INTEGER;

BEGIN
 IF Psetgid(rgid, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF rgid = 0 THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END setgid;

(*---------------------------------------------------------------------------*)

PROCEDURE seteuid ((* EIN/ -- *) euid : uidT ): int;

VAR res : INTEGER;

BEGIN
 IF Pseteuid(euid, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF euid = 0 THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END seteuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setegid ((* EIN/ -- *) egid : gidT ): int;

VAR res : INTEGER;

BEGIN
 IF Psetegid(egid, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF egid = 0 THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END setegid;

(*---------------------------------------------------------------------------*)

PROCEDURE setreuid ((* EIN/ -- *) ruid : int;
                    (* EIN/ -- *) euid : int ): int;

VAR res : INTEGER;

BEGIN
 IF Psetreuid(ruid, euid, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF ((ruid = -1) OR (ruid = 0)) & ((euid = -1) OR (euid = 0)) THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END setreuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setregid ((* EIN/ -- *) rgid : int;
                    (* EIN/ -- *) egid : int ): int;

VAR res : INTEGER;

BEGIN
 IF Psetregid(rgid, egid, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF ((rgid = -1) OR (rgid = 0)) & ((egid = -1) OR (egid = 0)) THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END setregid;

(*---------------------------------------------------------------------------*)

PROCEDURE getgroups ((* EIN/ -- *) size : int;
                     (* EIN/ -- *) list : GroupArrayPtr ): int;

VAR res : INTEGER;

BEGIN
 IF Pgetgroups(size, list, res) THEN
   RETURN(res);
 ELSIF res = eINVFN THEN
   RETURN(0);
 ELSE
   errno := res;
   RETURN(-1);
 END;
END getgroups;

(*---------------------------------------------------------------------------*)

PROCEDURE setgroups ((* EIN/ -- *) size : int;
                     (* EIN/ -- *) list : GroupArrayPtr ): int;

VAR res : INTEGER;

BEGIN
 IF Psetgroups(size, list, res) THEN
   RETURN(0);
 ELSE
   errno := res;
   RETURN(-1);
 END;
END setgroups;

(*---------------------------------------------------------------------------*)

PROCEDURE initgroups ((* EIN/ -- *) REF user    : ARRAY OF CHAR;
                      (* EIN/ -- *)     basegid : gidT          ): int;

VAR grent   : GroupPtr;
    msize   : sizeT;
    stack   : ADDRESS;
    void    : ADDRESS;
    name0   : StrPtr;
    gridx   : UNSIGNEDWORD;
    memidx  : UNSIGNEDWORD;
    ngroups : int;
    owngid  : gidT;
    gidset  : GroupArrayPtr;

BEGIN
 (* <user> wird mit einem Nullbyte abgeschlossen *)
 msize := VAL(sizeT,Length(user) + 1);
 memalloc(msize, stack, name0);
 AssignM2ToC(user, VAL(StrRange,msize), name0);

 ngroups := INT(sysconf(scNGroupsMax));
 IF ngroups < 0 THEN
   (* errno wurde von "sysconf()" gesetzt *)
   memdealloc(stack);
   RETURN(-1);
 ELSIF ngroups = 0 THEN
   (* Keine zus. Gruppen, also wird auch nichts initialisiert *)
   memdealloc(stack);
   RETURN(0);
 ELSIF ngroups > 1000 THEN
   (* Wir wollen ja nicht uebertreiben... *)
   ngroups := 1000;
 END;

 msize := VAL(sizeT,ngroups) * VAL(sizeT,TSIZE(gidT));
 memalloc(msize, void, gidset);

 (* <basegid> nur aufnehmen, falls es nicht sowieso schon die effektive
  * Gruppenkennung des Prozesses ist.
  *)
 owngid := getegid();
 IF owngid # basegid THEN
   gidset^[0] := basegid;
   gridx := 1;
 ELSE
   gridx := 0;
 END;

 (* Die Group-Datenbank wird nach Eintraegen durchsucht, bei denen <user>
  * enthalten ist. Falls die maximale Anzahl von zusaetzlichen Gruppen-
  * kennungen noch nicht ueberschritten ist, wird die entsprechende Kennung
  * in die Liste aufgenommen.
  *)
 setgrent;
 grent := getgrent();
 WHILE (grent # NULL) & (INT(gridx) < ngroups) DO
   WITH grent^ DO
     memidx := 0;
     LOOP
       IF grMem^[memidx] = NULL THEN
         EXIT;
       END;
       IF strcmp(grMem^[memidx], name0) = 0 THEN
         (* <user> ist in der Gruppe enthalten.
          * Weder die eigene effektive Gruppenkennung noch <basegid>
          * aufnehmen, da das schon erledigt ist.
          *)
         IF (grGid # basegid) & (grGid # owngid) THEN
           gidset^[gridx] := grGid;
           INC(gridx);
         END;
         EXIT;
       END;
       INC(memidx);
     END; (* LOOP *)
   END;
   grent := getgrent();
 END;
 endgrent;

 (* Ein Fehler wird von "setgroups()" gesetzt *)
 ngroups := setgroups(INT(gridx), gidset);
 memdealloc(stack);
 RETURN(ngroups);
END initgroups;

(*---------------------------------------------------------------------------*)

PROCEDURE getpgrp ( ): pidT;

VAR pid : INTEGER;

BEGIN
 pid := Pgetpgrp();
 IF pid < 0 THEN
   (* Aufruf wird nicht unterstuetzt, die eigene pid liefern *)
   RETURN(ActPid());
 ELSE
   RETURN(pid);
 END;
END getpgrp;

(*---------------------------------------------------------------------------*)

PROCEDURE setpgid ((* EIN/ -- *) pid  : pidT;
                   (* EIN/ -- *) pgid : pidT ): int;

VAR PID : INTEGER;

BEGIN
 IF (pid < 0) OR (pgid < 0) THEN
   errno := EINVAL;
   RETURN(-1);
 END;

 IF pgid = 0 THEN
   PID := Pgetpid();
 ELSE
   PID := pgid;
 END;

 IF PID >= 0 THEN
   IF Psetpgrp(pid, PID, PID) THEN
     RETURN(0);
   ELSIF PID # eINVFN THEN
     (* 'Psetpgrp'-Aufruf wird unterstuetzt, anderer Fehler *)
     IF PID = eACCDN THEN
       errno := ESRCH;
     ELSE
       errno := PID;
     END;
     RETURN(-1);
   END;
 END;

 (* 'Pgetpid'- und/oder 'Psetpgrp'-Aufruf wird nicht unterstuetzt *)
 PID := ActPid();
 IF  ((pid  = 0) OR (pid  = PID))
   & ((pgid = 0) OR (pgid = PID))
 THEN
   RETURN(0);
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;
END setpgid;

(*--------------------------------------------------------------------------*)

PROCEDURE setsid ( ): pidT;

CONST RDWR = 2;

VAR pgrp : INTEGER;
    pid  : INTEGER;
    res  : INTEGER;

BEGIN
 pgrp := Pgetpgrp();
 pid  := Pgetpid();
 IF (pgrp < 0) OR (pid < 0) OR (pgrp = pid) THEN
   (* Prozess ist bereits ``process group leader'', darf
    * kein "setsid()" ausfuehren.
    * (Oder die Aufrufe werden nicht unterstuetzt)
    *)
   errno := EPERM;
   RETURN(-1);
 END;

 (* Kontrollterminal auf /dev/null umlenken *)
 IF ~Disconnect(-1, res) THEN
   errno := res;
   RETURN(-1);
 END;

 (* Neue Prozessgruppe hat die Kennung des aufrufenden Prozesses. *)
 IF Psetpgrp(0, 0, pgrp) THEN
   RETURN(pgrp);
 ELSE
   IF pgrp = eACCDN THEN
     errno := ESRCH;
   ELSE
     errno := pgrp;
   END;
   RETURN(-1);
 END;
END setsid;

(*--------------------------------------------------------------------------*)

PROCEDURE nice ((* EIN/ -- *) delta : int ): int;

VAR res : INTEGER;

BEGIN
 IF Pnice(delta, res) THEN
   RETURN(res);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSE
   RETURN(0);
 END;
END nice;

(*--------------------------------------------------------------------------*)

PROCEDURE renice ((* EIN/ -- *) pid   : pidT;
                  (* EIN/ -- *) delta : int  ): int;

VAR res : INTEGER;

BEGIN
 IF Prenice(pid, delta, res) THEN
   RETURN(res);
 ELSIF res # eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 ELSIF pid # ActPid() THEN
   errno := EINVAL;
   RETURN(-1);
 ELSE
   RETURN(0);
 END;
END renice;

(*--------------------------------------------------------------------------*)
#ifdef MM2
PROCEDURE fork ( ): pidT;

VAR pid  : INTEGER;
    mask : UNSIGNEDLONG;

BEGIN
 (* Die Ausfuehrung der Terminierungsroutinen durch die in etv_term
  * installierte Routine soll verhindert werden. Hierzu muessen
  * 'ActMOSProcess' und 'BaseProcess' ungleich 'ProcessID^' sein. Diese
  * Variablen enthalten Basepage-Adressen. Bei 'Pfork' oder 'Pvfork' werden
  * jedoch keine neuen Basepages erzeugt.
  * Die Werte brauchen im aufrufenden Prozess nicht restauriert zu werden,
  * da bei 'Pfork' getrennte Speicherbreiche vorliegen, so dass die Variablen
  * im aufrufenden Prozess gar nicht veraendert werden.
  *
  * Die Signale muessen blockiert werden, da es sonst moeglich waere,
  * dass im Kindprozess nach der Rueckkehr aus 'Pfork' aber noch vor
  * dem Setzen von ActMOSProcess und BaseProcess ein Signal eintrifft
  * (ist allerdings nicht sehr wahrscheinlich), das den Prozess beendet.
  * Blockierte Signale (die Prozessmaske) werden an Unterprozesse vererbt.
  *)
 mask := Psigblock(0FFFFFFFFH); (* Alle Signale blockieren *)
 pid  := Pfork();
 IF pid = 0 THEN
   ActMOSProcess := NIL;
   BaseProcess   := NIL;
 ELSIF pid < 0 THEN
   errno := pid;
   pid     := -1;
 END;
 mask := Psigsetmask(mask); (* Alte Prozessmaske wiederherstellen *)
 RETURN(pid);
END fork;

#else

PROCEDURE fork ( ): pidT;

VAR pid : INTEGER;

BEGIN
 pid := Pfork();
 IF pid >= 0 THEN
   RETURN(pid);
 ELSE
   errno := pid;
   RETURN(-1);
 END;
END fork;
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE MakeWaitVal ((* EIN/ -- *) retCode : SIGNEDWORD ): SIGNEDWORD;

CONST SIGINT = 2;

VAR __REG__ exit : UNSIGNEDWORD;
    __REG__ sig  : UNSIGNEDWORD;
    __REG__ ret  : WORDSET;

BEGIN
 IF (MagiCVersion() >= 0) & (retCode = eBREAK) OR (retCode = -32) THEN
   (* Programm wurde durch 'CTRL-C' abgebrochen *)
   exit := 0;
   sig  := SIGINT;
 ELSE
   ret  := CAST(WORDSET,retCode);
#if reverse_set
   exit := CAST(UNSIGNEDWORD,ret * WORDSET{8..15});
   sig  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,ret * WORDSET{1..7}) DIV 256);
#else
   exit := CAST(UNSIGNEDWORD,ret * WORDSET{0..7});
   sig  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,ret * WORDSET{8..14}) DIV 256);
#endif
 END;
 IF sig >= NSIG THEN
   (* Kann kein Signal sein *)
   sig := 0;
 END;
 IF (sig # 0) & (exit # 0) & (exit # 127) THEN
   (* normaler Returncode, kein Signal *)
   sig := 0;
 END;
 IF (exit = 127) & (sig # 0) THEN
   (* Prozess gestoppt *)
   RETURN(retCode); (* ist schon entsprechend kodiert *)
 ELSE
   (* Prozess terminiert, evtl. durch Signal *)
   RETURN(VAL(SIGNEDWORD,exit * 256 + sig));
 END;
END MakeWaitVal;

(*---------------------------------------------------------------------------*)

PROCEDURE SetStacksize ((* EIN/ -- *) stacksize : CARDINAL);
BEGIN
 IF stacksize < MINSTACKSIZE THEN
   Stacksize := BPSIZE + MINSTACKSIZE;
 ELSE
   Stacksize := BPSIZE + stacksize;
 END;
END SetStacksize;

(*---------------------------------------------------------------------------*)

__STACKCHECK_OFF__
#if (defined HM2)
(*$E+ lokale Prozedur als Parameter *)
#endif
PROCEDURE startup;
(* Diese Prozedur ist die erste Anweisung, die nach dem "Pexec()" in
 * "tfork()" ausgefuehrt wird. An ihrer Stelle staende normalerweise
 * die Initialisierungsroutine eines gestarteten Programms. Aus diesem
 * Grund hat auch lediglich Register A7 einen definierten Wert! A7 zeigt
 * auf das Ende der TPA, und ueber 4(A7) ist die Adresse der eigenen Basepage
 * erreichbar.
 * Falls der M2-Compiler beim Beginn der Prozedur erwartet, dass
 * bestimmte Register definierte Werte haben (z.B. Megamax: A3 ist der
 * Parameterstack!), muessen diese Register entsprechend gesetzt werden,
 * bevor auf sie zugegriffen wird.
 *)
VAR b : BPtr;

BEGIN
#if (defined MM2)
  CODE(202DH,0008H); (* move.l 8(A5),D0 *)
#elif (defined HM2) || (defined TDIM2)
  CODE(202EH,0008H); (* move.l 8(A6),D0 *)
#elif (defined LPRM2) || (defined SPCM2)
  INLINE(202EH,000CH); (* move.l 12(A6),D0 *)
#endif
  GETREGADR(0, b);
#ifdef MM2
  (* A3 auf Stackanfang setzen, direkt hinter die Basepage *)
  SETREG(11, ADDADR(b, BPSIZE));
#endif

  WITH b^ DO
    Exit(tProc(tArg));
  END;
END startup;
#if (defined HM2)
(*$E=*)
#endif
__STACKCHECK_PREV__

(*---------------------------------------------------------------------------*)

PROCEDURE tfork ((* EIN/ -- *) func : ThreadProc;
                 (* EIN/ -- *) arg  : ANYLONG    ): int;

VAR b       : BPtr;
    pid     : SIGNEDLONG;
    ret     : SIGNEDLONG;
    err     : INTEGER;
    ch      : CHAR;
    done    : BOOLEAN;
    void    : BOOLEAN;
    start   : UNSIGNEDLONG;
    base    : BasePtr;
    mask    : UNSIGNEDLONG;
    pending : UNSIGNEDLONG;
    handler : DosHandler;

BEGIN
  ch := 0C;
  IF Pexec(5, NULL, ADR(ch), NULL, ret) THEN
    b    := CAST(BPtr,MAKEADR(ret));
    void := Mshrink(b, VAL(SIGNEDLONG,Stacksize), err);

    WITH b^ DO WITH BASEP^ DO
      (* Das Setzen des TPA-Endes ist wichtig fuer das
       * nachfolgende "Pexec()", dorthin wird naemlich der
       * Stack (A7) des neuen Prozesses gesetzt !
       *)
      hitpa := ADDADR(b, Stacksize);
      tbase := startup;
      tlen  := pTlen; (* ? *)
      bbase := pBbase;
      blen  := pBlen;
      dbase := pDbase;
      dlen  := pDlen;

      (* Parameter in der unbenoetigten Basepage-Kommandozeile uebergeben *)
      tProc  := func;
      tArg   := arg;
    END; END;

    IF hasXPexec THEN
      (* Unterprozess asynchron starten *)
      done := Pexec(104, NULL, b, NULL, pid);
    ELSE
      (* Dos-Emulations-Variablen fuer Signale sichern *)
      mask    := SIGMASK;
      pending := SIGPENDING;
      handler := SIGHANDLER;
      (* keine Signale blockiert *)
      SIGMASK := 0;

      (* Programm hat eine neue Basepage, deshalb die alte merken *)
      base  := BASEP;
      BASEP := CAST(BasePtr,b);

      start := SysClock();
      done  := Pexec(4, NULL, b, NULL, pid);

      (* Jetzt gilt wieder die alte Basepage *)
      BASEP := base;

      (* Die alten Signalhandler gelten wieder *)
      SIGMASK    := mask;
      SIGPENDING := pending;
      SIGHANDLER := handler;

      IF done THEN
        WAITTIME := SysClock() - start;
        INC(CHILDTIME, WAITTIME);
        WAITVAL.term := VAL(SIGNEDWORD,pid);
        (* Aus der Basepageadresse eine Prozesskennung berechnen *)
        pid := VAL(SIGNEDLONG,DosPid(b));
        WAITVAL.pid := VAL(UNSIGNEDWORD,pid);
        err := raise(SIGCHLD);
      END;
    END;
    (* Der Speicher fuer Basepage und Environment gehoert sowohl dem
     * aufrufenden Prozess als auch dem Unterprozess; er wird deshalb nicht
     * automatisch nach Beendigung des Unterprozesses freigegeben.
     * Auch wenn der Unterprozess parallel gestartet wurde, kann 'Mfree'
     * verwendet werden, da die eigentliche Freigabe erst stattfindet,
     * wenn auch der Unterprozess beendet ist.
     *)
    void := Mfree(b^.env, err);
    void := Mfree(b, err);

    IF done THEN
      RETURN(INT(pid)); (* Eine gueltige Prozesskennung ist immer positiv *)
    ELSE
      errno := INT(pid);
      RETURN(-1);
    END;
  ELSE
    errno := INT(ret);
    RETURN(-1);
  END;
END tfork;

(*---------------------------------------------------------------------------*)

#if (defined LPRM2) || (defined SPCM2)

PROCEDURE vfork ( ): pidT;
BEGIN
(*
  movea.l (SP)+,A6       ; alter Framepointer vom Stack retten
  movea.l (SP)+,A3       ; alte Modulbasis vom Stack retten
  movea.l (SP),A1        ; RTN-Adresse merken, falls Pvfork erfolgreich
                         ; ANNAHME: A1 bleibt bei Pvfork erhalten, unter TOS
                         ; dagegen bleibt der Wert auf dem Stack erhalten
  move.w  #$0113,-(SP)   ; Pvfork
  trap    #1             ;
  addq.l  #6,SP          ; Parameter und RTN-Adresse vom Stack
  tst.l   D0
  bpl.s   ende
  cmpi.w  #-32,D0        ; EINVFN?
  bne.s   err            ; B: nein, Pvfork wird unterstuetzt

; sonst TOS-Emulation mittels tfork
  movea.l -4(SP),A1      ; unter TOS Stack nicht ueberschrieben aber A1
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  movem.l A1/A3/A5-A6,(A0)
  subq.l  #2,SP          ; Platz fuer Funktionswert
  pea     child(PC)      ; tfork(child, saveADR);
  pea     (A0)           ;
  nop                    ;; durch SETREG(8, tforkADR); ersetzt
  nop                    ;;
  jsr     (A0)
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  move.w  (SP)+,D0
  movem.l (A0),A1/A3/A5-A6
  bmi.s   err
  bra.s   ende

child:
  addq.l  #4,SP          ; RTN-Adresse weg
  movea.l (SP)+,A0       ; a0 := saveADR
  movem.l (A0),A1/A3/A5-A6
  moveq   #0,D0
  bra.s   ende

err:
  nop                    ;; durch SETREG(8, errnoADR); ersetzt
  nop                    ;;
  move.w  D0,(A0)        ; errno setzen
  moveq   #-1,D0

ende:
  move.w  D0,(SP)
  movea.l A3,A4          ; alte Modulbasis setzen
  jmp     (A1)
*)
 CODE(2C5FH,265FH,2257H,3F3CH,0113H,4E41H,5C8FH,4A80H);
 CODE(6A42H,0C40H,0FFE0H,6634H,226FH,0FFFCH);
 SETREG(8, saveADR);
 CODE(48D0H,6A00H,558FH,487AH,0018H,4850H);
 SETREG(8, tforkADR);
 CODE(4E90H);
 SETREG(8, saveADR);
 CODE(301FH,4CD0H,6A00H,6B0EH,6014H);
 CODE(588FH,205FH,4CD0H,6A00H,7000H,6008H);
 SETREG(8, errnoADR);
 CODE(3080H,70FFH,3E80H,284BH,4ED1H);
END vfork;

#elif (defined TDIM2)

__PROCFRAME_OFF__
PROCEDURE vfork ( ): pidT;
BEGIN
(*
  movea.l (SP),A1        ; RTN-Adresse merken, falls Pvfork erfolgreich
                         ; ANNAHME: A1 bleibt bei Pvfork erhalten, unter TOS
                         ; dagegen bleibt der Wert auf dem Stack erhalten
  move.w  #$0113,-(SP)   ; Pvfork
  trap    #1             ;
  addq.l  #6,SP          ; Parameter und RTN-Adresse vom Stack
  tst.l   D0
  bpl.s   ende
  cmpi.w  #-32,D0
  bne.s   err
tos:
  movea.l -4(SP),A1      ; unter TOS ist die RTN-Adresse noch gueltig
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  nop                    ;;
  movem.l A1/A5-A6,(A0)
  subq.l  #2,SP          ; Platz fuer Funktionswert
  pea     child(PC)      ; tfork(child, saveADR);
  pea     (A0)           ;
  nop                    ;; durch SETREG(8, tforkADR); ersetzt
  nop                    ;;
  nop                    ;;
  jsr     (A0)
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  nop                    ;;
  addq.l  #8,SP
  move.w  (SP)+,D0
  movem.l (A0),A1/A5-A6
  bmi.s   err
  bra.s   ende

child:
  addq.l  #4,SP          ; RTN-Adresse weg
  movea.l (SP)+,A0       ; a0 := saveADR
  movem.l (A0),A1/A5-A6
  moveq   #0,D0
  bra.s   ende

err:
  nop                    ;; durch SETREG(8, errnoADR); ersetzt
  nop                    ;;
  nop                    ;;
  move.w  D0,(A0)        ; errno setzen
  moveq   #-1,D0

ende:
  move.w  D0,(SP)
  jmp     (A1)
*)
 CODE(2257H,3F3CH,0113H,4E41H,5C8FH,4A80H,6A4CH,0C40H);
 CODE(0FFE0H,663CH,226FH,0FFFCH);
 SETREG(8, saveADR);
 CODE(48D0H);
 CODE(6200H,558FH,487AH,001EH,4850H);
 SETREG(8, tforkADR);
 CODE(4E90H);
 SETREG(8, saveADR);
 CODE(508FH,301FH,4CD0H,6200H);
 CODE(6B0EH,6016H,588FH,205FH,4CD0H,6200H,7000H,600AH);
 SETREG(8, errnoADR);
 CODE(3080H,70FFH,3E80H,4ED1H);
END vfork;
__PROCFRAME_ON__

#elif (defined HM2)

PROCEDURE vfork ( ): pidT;
BEGIN
(*
  move.l  (SP)+,D1       ; alte Modulbasis vom Stack retten
  movea.l (SP)+,A6       ; alten Frame-Pointer vom Stack retten
  movea.l (SP),A1        ; RTN-Adresse merken, falls Pvfork erfolgreich
                         ; ANNAHME: A1 bleibt bei Pvfork erhalten, unter TOS
                         ; dagegen bleibt der Wert auf dem Stack erhalten
  move.l  A5,-(SP)       ; aktuelle Modulbasis fuer TOS retten
  movea.l D1,A5
  move.w  #$0113,-(SP)   ; Pvfork
  trap    #1             ;
  lea     10(SP),SP      ; Parameter, RTN-Adresse und Modulbasis vom Stack
  move.l  A5,D1
  tst.l   D0
  bpl.s   ende
  cmpi.w  #-32,D0        ; EINVFN?
  bne.s   err            ; B: nein, Pvfork wird unterstuetzt

; sonst TOS-Emulation mittels tfork
  movea.l -4(SP),A1      ; unter TOS ist die RTN-Adresse noch gueltig
  movea.l -8(SP),A5      ; unter TOS ist die Modulbasis noch gueltig
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  movem.l D1-D7/A1-A6,(A0)
  pea     (A0)
  pea     child(PC)      ; tfork(child, saveADR);
  nop                    ;; durch SETREG(8, tforkADR); ersetzt
  nop                    ;;
  jsr     (A0)
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  movem.l (A0),D1-D7/A1-A6
  tst.w   D0
  bmi.s   err
  bra.s   ende

child:
  addq.l  #4,SP          ; RTN-Adresse weg
  movea.l (SP)+,A0       ; a0 := saveADR
  movem.l (A0),D1-D7/A1-A6
  moveq   #0,D0
  bra.s   ende

err:
  nop                    ;; durch SETREG(8, errnoADR); ersetzt
  nop                    ;;
#ifdef __LONG_WHOLE__
  move.l  D0,(A0)        ; errno setzen
#else
  move.w  D0,(A0)        ; errno setzen
#endif
  moveq   #-1,D0
ende:
  movea.l D1,A5          ; alte Modulbasis setzen
  jmp     (A1)
*)
 CODE(221FH,2C5FH,2257H,2F0DH,2A41H,3F3CH,0113H,4E41H);
 CODE(4FEFH,000AH,220DH,4A80H,6A44H,0C40H,0FFE0H,6636H);
 CODE(226FH,0FFFCH,2A6FH,0FFF8H);
 SETREG(8, saveADR);
 CODE(48D0H,7EFEH);
 CODE(4850H,487AH,0016H);
 SETREG(8, tforkADR);
 CODE(4E90H);
 SETREG(8, saveADR);
 CODE(4CD0H,7EFEH,4A40H,6B0EH,6014H,588FH,205FH,4CD0H);
 CODE(7EFEH,7000H,6008H);
 SETREG(8, errnoADR);
#ifdef __LONG_WHOLE__
 CODE(2080H);
#else
 CODE(3080H);
#endif
 CODE(70FFH,2A41H);
 CODE(4ED1H);
END vfork;

#elif (defined MM2)

__PROCFRAME_OFF__
PROCEDURE vfork ( ): pidT;
BEGIN
 ASSEMBLER
   MOVEQ   #-1,D0                       ; ProcMask := Psigblock(0FFFFFFFFH)
   MOVE.L  D0,-(SP)                     ;
   MOVE.W  #278,-(SP)                   ;
   TRAP    #1                           ;
   ADDQ.L  #6,SP                        ;
   MOVE.L  D0,ProcMask                  ;
   MOVE.L  (A7)+,RtnAdr
   MOVE.L  ActMOSProcess,ActMOSProc
   MOVE.L  BaseProcess,BaseProc
   MOVE.W  #$0113, -(A7)
   TRAP    #1
   ADDQ.L  #2,A7
   TST.L   D0
   BEQ.S   clear
   BPL.S   main
   CMPI.W  #-32,D0
   BNE.S   err
   BRA.S   tos
 clear:
   ; Unterprozess: Variablen loeschen, um Ausfuehrung der
   ; Terminierungsroutinen zu verhindern
   CLR.L   ActMOSProcess
   CLR.L   BaseProcess
   BRA.S   ende
 main:
   ; Hauptprozess: Die vom Unterprozess geloeschten Werte wiederherstellen
   MOVE.L  ActMOSProc,ActMOSProcess
   MOVE.L  BaseProc,BaseProcess
   BRA.S   ende

 tos:
   MOVEM.L D3-D7/A4-A6,regsave
   LEA     child(PC), A0
   MOVE.L  A0, (A3)+
   MOVE.L  #regsave, (A3)+
#ifdef __RES_ON_STACK__
   JSR     tfork
#ifdef __LONG_WHOLE__
   MOVE.L  -(A3),D0
#else
   MOVE.W  -(A3),D0
#endif
#else
   JSR     tfork/
#endif
   MOVEM.L regsave,D3-D7/A4-A6
   TST.W   D0
   BMI.S   err
   BRA.S   ende

 child:
   ADDQ.L  #4, A7
   MOVEA.L -(A3),A0
   MOVEM.L (A0),D3-D7/A4-A6
   MOVEQ   #0,D0
   BRA.S   ende

 err:
#ifdef __LONG_WHOLE__
   MOVE.L  D0, errno
#else
   MOVE.W  D0, errno
#endif
   MOVEQ   #-1, D0

 ende:
   MOVE.L  D0,-(SP)
   MOVE.L  ProcMask,-(SP)               ; Psigsetmask(ProcMask)
   MOVE.W  #279,-(SP)                   ;
   TRAP    #1                           ;
   ADDQ.L  #6,SP                        ;
   MOVE.L  (SP)+,D0
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L  D0, (A3)+
#else
   MOVE.W  D0, (A3)+
#endif
#endif
   MOVEA.L RtnAdr,A1
   JMP     (A1)
 END;
END vfork;
__PROCFRAME_ON__
#endif

(*---------------------------------------------------------------------------*)

PROCEDURE wait ((* -- /AUS *) VAR state : WaitVal ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;

BEGIN
 state := WaitVal{};
 done  := Pwait3(WORDSET{}, NULL, res.long);
 IF ~done & (INT(res.long) = eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := ECHILD;
   WAITTIME     := 0;
 END;
 IF ~done THEN
   errno := INT(res.long);
   RETURN(-1);
 END;
 state := CAST(WaitVal,MakeWaitVal(res.term));
 RETURN(VAL(pidT,res.pid));
END wait;

(*---------------------------------------------------------------------------*)

PROCEDURE waitpid ((* EIN/ -- *)     pid     : pidT;
                   (* -- /AUS *) VAR state   : WaitVal;
                   (* EIN/ -- *)     options : WaitOptions ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;

BEGIN
 state := WaitVal{};
 done  := Pwaitpid(pid, options, NULL, res.long);
 IF ~done & (INT(res.long) = eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   IF (pid # -1) & (pid # 0) THEN
     errno := EINVAL;
     RETURN(-1);
   END;
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := ECHILD;
   WAITTIME     := 0;
 END;
 IF ~done THEN
   errno := INT(res.long);
   RETURN(-1);
 END;
 state := CAST(WaitVal,MakeWaitVal(res.term));
 RETURN(VAL(pidT,res.pid));
END waitpid;

(*---------------------------------------------------------------------------*)

PROCEDURE wait3 ((* -- /AUS *) VAR state   : WaitVal;
                 (* EIN/ -- *)     options : WaitOptions;
                 (* -- /AUS *) VAR usage   : RusageRec   ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;
    rsc  : ARRAY [0..1] OF SIGNEDLONG;

BEGIN
 state := WaitVal{};
 done  := Pwait3(options, ADR(rsc), res.long);
 IF ~done & (INT(res.long) = eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := ECHILD;
   rsc[0]       := WAITTIME * VAL(UNSIGNEDLONG,5);
   rsc[1]       := 0;
   WAITTIME     := 0;
 END;
 IF ~done THEN
   errno := INT(res.long);
   RETURN(-1);
 END;
 state := CAST(WaitVal,MakeWaitVal(res.term));
 memset(ADR(usage), 0, VAL(sizeT,TSIZE(RusageRec)));
 WITH usage DO
   WITH ruUtime DO
     tvSec  :=  rsc[0] DIV VAL(SIGNEDLONG,1000);
     tvUSec := (rsc[0] MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000);
   END;
   WITH ruStime DO
     tvSec  :=  rsc[1] DIV VAL(SIGNEDLONG,1000);
     tvUSec := (rsc[1] MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000);
   END;
   ruNvcsw := 1; (* ? *)
 END;
 RETURN(VAL(pidT,res.pid));
END wait3;

(*---------------------------------------------------------------------------*)

PROCEDURE wait4 ((* EIN/ -- *)     pid     : pidT;
                 (* -- /AUS *) VAR state   : WaitVal;
                 (* EIN/ -- *)     options : WaitOptions;
                 (* -- /AUS *) VAR usage   : RusageRec   ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;
    rsc  : ARRAY [0..1] OF SIGNEDLONG;

BEGIN
 IF pid < 0 THEN
   errno := EINVAL;
   RETURN(-1);
 ELSIF pid = 0 THEN
   pid := -1;
 END;
 state := WaitVal{};
 done  := Pwaitpid(pid, options, ADR(rsc), res.long);
 IF ~done & (INT(res.long) = eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   IF pid # -1 THEN
     errno := EINVAL;
     RETURN(-1);
   END;
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := ECHILD;
   rsc[0]       := WAITTIME * VAL(UNSIGNEDLONG,5);
   rsc[1]       := 0;
   WAITTIME     := 0;
 END;
 IF ~done THEN
   errno := INT(res.long);
   RETURN(-1);
 END;
 state := CAST(WaitVal,MakeWaitVal(res.term));
 memset(ADR(usage), 0, VAL(sizeT,TSIZE(RusageRec)));
 WITH usage DO
   WITH ruUtime DO
     tvSec  :=  rsc[0] DIV VAL(SIGNEDLONG,1000);
     tvUSec := (rsc[0] MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000);
   END;
   WITH ruStime DO
     tvSec  :=  rsc[1] DIV VAL(SIGNEDLONG,1000);
     tvUSec := (rsc[1] MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000);
   END;
   ruNvcsw := 1; (* ? *)
 END;
 RETURN(VAL(pidT,res.pid));
END wait4;

(*---------------------------------------------------------------------------*)

PROCEDURE WIFEXITED ((* EIN/ -- *) state : WaitVal ): BOOLEAN;
BEGIN
 RETURN((state * wStopval # WSTOPPED) & (state * wTermsig = WaitVal{}));
END WIFEXITED;

(*---------------------------------------------------------------------------*)

PROCEDURE WEXITSTATUS ((* EIN/ -- *) state : WaitVal ): int;
BEGIN
 RETURN(INT(CAST(SIGNEDWORD,state * wRetcode) DIV 256));
END WEXITSTATUS;

(*---------------------------------------------------------------------------*)

PROCEDURE WIFSIGNALED ((* EIN/ -- *) state : WaitVal ): BOOLEAN;
BEGIN
 RETURN((state * wStopval # WSTOPPED) & (state * wTermsig # WaitVal{}));
END WIFSIGNALED;

(*---------------------------------------------------------------------------*)

PROCEDURE WTERMSIG ((* EIN/ -- *) state : WaitVal ): int;
BEGIN
 RETURN(INT(CAST(UNSIGNEDWORD,state * wTermsig)));
END WTERMSIG;

(*---------------------------------------------------------------------------*)

PROCEDURE WIFSTOPPED ((* EIN/ -- *) state : WaitVal ): BOOLEAN;
BEGIN
 RETURN(state * wStopval = WSTOPPED);
END WIFSTOPPED;

(*---------------------------------------------------------------------------*)

PROCEDURE WSTOPSIG ((* EIN/ -- *) state : WaitVal ): int;
BEGIN
 RETURN(INT(CAST(UNSIGNEDWORD,state * wStopsig) DIV 256));
END WSTOPSIG;

(*---------------------------------------------------------------------------*)

PROCEDURE FDZERO ((* -- /AUS *) VAR fdset : fdSet );
BEGIN
 fdset[0] := WORDSET{};
 fdset[1] := WORDSET{};
END FDZERO;

(*---------------------------------------------------------------------------*)

PROCEDURE FDSET ((* EIN/ -- *)     fd    : int;
                 (* -- /AUS *) VAR fdset : fdSet );

VAR cast : LONGfdset;

BEGIN
 IF (fd >= 0) & (fd < FDSETSIZE) THEN
   cast.fdset := fdset;
   LONGINCL(cast.fdlong, VAL(UNSIGNEDWORD,fd));
   fdset := cast.fdset;
 END;
END FDSET;

(*---------------------------------------------------------------------------*)

PROCEDURE FDCLR ((* EIN/ -- *)     fd    : int;
                 (* -- /AUS *) VAR fdset : fdSet );

VAR cast : LONGfdset;

BEGIN
 IF (fd >= 0) & (fd < FDSETSIZE) THEN
   cast.fdset := fdset;
   LONGEXCL(cast.fdlong, VAL(UNSIGNEDWORD,fd));
   fdset := cast.fdset;
 END;
END FDCLR;

(*---------------------------------------------------------------------------*)

PROCEDURE FDISSET ((* EIN/ -- *) fd    : int;
                   (* EIN/ -- *) fdset : fdSet ): BOOLEAN;

VAR cast : LONGfdset;

BEGIN
 IF (fd >= 0) & (fd < FDSETSIZE) THEN
   cast.fdset := fdset;
   RETURN(LONGELEM(VAL(UNSIGNEDWORD,fd), cast.fdlong));
 ELSE
   RETURN(FALSE);
 END;
END FDISSET;

(*---------------------------------------------------------------------------*)

PROCEDURE select ((* EIN/ -- *) width     : int;
                  (* EIN/ -- *) readfds   : FdSetPtr;
                  (* EIN/ -- *) writefds  : FdSetPtr;
                  (* EIN/ -- *) exceptfds : FdSetPtr;
                  (* EIN/ -- *) timeout   : TimevalPtr ): int;

VAR mrfds   : LONGfdset;
    mwfds   : LONGfdset;
    mxfds   : LONGfdset;
    res     : INTEGER;
    tmout   : UNSIGNEDLONG;
    mtmout  : CARDINAL;

PROCEDURE TOSselect ( ): int;

VAR tstdin  : BOOLEAN;
    tstdout : BOOLEAN;
    tauxin  : BOOLEAN;
    tauxout : BOOLEAN;
    nready  : INTEGER;

BEGIN (* TOSselect *)
 IF readfds # NULL THEN
   tstdin := LONGELEM(0, mrfds.fdlong);
   tauxin := LONGELEM(2, mrfds.fdlong);
   FDZERO(readfds^);
 ELSE
   tstdin := FALSE;
   tauxin := FALSE;
 END;
 IF writefds # NULL THEN
   tstdout := LONGELEM(1, mwfds.fdlong);
   tauxout := LONGELEM(2, mwfds.fdlong);
   FDZERO(writefds^);
 ELSE
   tstdout := FALSE;
   tauxout := FALSE;
 END;
 IF exceptfds # NULL THEN
   FDZERO(exceptfds^);
 END;

 nready := 0;
 tmout  := SysClock() + tmout DIV VAL(UNSIGNEDLONG,5);
 REPEAT
   IF tstdin & Cconis() THEN
     INC(nready);
     FDSET(0, readfds^);
   END;
   IF tstdout & Cconos() THEN
     INC(nready);
     FDSET(1, writefds^);
   END;
   IF tauxin & Cauxis() THEN
     INC(nready);
     FDSET(2, readfds^);
   END;
   IF tauxout & Cauxos() THEN
     INC(nready);
     FDSET(2, writefds^);
   END;
 UNTIL (nready > 0) OR (timeout # NULL) & (SysClock() >= tmout);
 RETURN(nready);
END TOSselect;

BEGIN (* select *)
 IF width < 0 THEN
   errno := EINVAL;
   RETURN(-1);
 END;

 IF timeout = NULL THEN
   tmout := 0; (* Kein Timeout, beliebig lange warten *)
 ELSE
   WITH timeout^ DO
     tmout := CAST(UNSIGNEDLONG,  tvSec  *   VAL(long,1000)
                                + tvUSec DIV VAL(long,1000));
   END;
   IF tmout = VAL(UNSIGNEDLONG,0) THEN
     tmout := 1;
   END;
 END;

 IF readfds # NULL THEN
   mrfds.fdset := readfds^;
   IF width < FDSETSIZE THEN
     LONGMASK(VAL(UNSIGNEDWORD,width), mrfds.fdlong);
     readfds^ := mrfds.fdset;
   END;
 END;
 IF writefds # NULL THEN
   mwfds.fdset := writefds^;
   IF width < FDSETSIZE THEN
     LONGMASK(VAL(UNSIGNEDWORD,width), mwfds.fdlong);
     writefds^ := mwfds.fdset;
   END;
 END;
 IF exceptfds # NULL THEN
   mxfds.fdset := exceptfds^;
   IF width < FDSETSIZE THEN
     LONGMASK(VAL(UNSIGNEDWORD,width), mxfds.fdlong);
   END;
   exceptfds^ := mxfds.fdset;
 END;

 LOOP
   IF tmout > VAL(UNSIGNEDLONG,65535) THEN
     mtmout := 65535;
   ELSE
     mtmout := VAL(CARDINAL,tmout);
   END;

   IF ~Fselect(mtmout, readfds, writefds, exceptfds, res) THEN
     IF res = eINVFN THEN
       RETURN(TOSselect());
     ELSE
       errno := res;
       RETURN(-1);
     END;
   END;
   DEC(tmout, VAL(UNSIGNEDLONG,mtmout));

   IF (res > 0) OR (tmout = VAL(UNSIGNEDLONG,0)) THEN
     (* Mindestens eine Datei ist bereit oder Timeout abgelaufen *)
     RETURN(res);
   END;
   IF readfds # NULL THEN
     readfds^ := mrfds.fdset;
   END;
   IF writefds # NULL THEN
     writefds^ := mwfds.fdset;
   END;
   IF exceptfds # NULL THEN
     exceptfds^ := mxfds.fdset;
   END;
 END; (* LOOP *)
END select;

(*---------------------------------------------------------------------------*)

PROCEDURE Spawn ((* EIN/ -- *) mode : SpawnMode;
                 (* EIN/ -- *) prg  : StrPtr;
                 (* EIN/ -- *) argv : StrArray;
                 (* EIN/ -- *) envp : StrArray  ): INTEGER;

CONST MaxStr = 10;

VAR         envPtr     : StrPtr;
    __REG__ tmpPtr     : StrPtr;
    __REG__ cmdIdx     : StrRange;
    __REG__ i          : ArrayRange;
    __REG__ args       : ArrayRange;
            envs       : ArrayRange;
            val        : ArrayRange;
            pexec      : CARDINAL;
            res        : INTEGER;
            void       : INTEGER;
            lres       : SIGNEDLONG;
            childStart : UNSIGNEDLONG;
            null       : BOOLEAN;
            done       : BOOLEAN;
            cmdLine    : CmdLine; (* Zwischenspeicher und Kommandozeile *)

PROCEDURE argcpy ((* EIN/ -- *) src : StrPtr;
                  (* EIN/ -- *) dst : StrPtr): StrPtr;

VAR __REG__ c : CHAR;
    __REG__ s : StrPtr;
    __REG__ d : StrPtr;

BEGIN
 s := src;
 d := dst;
 REPEAT
   c := s^[0];
   d^[0] := c;
   s := ADDADR(s, 1);
   d := ADDADR(d, 1);
 UNTIL c = 0C;
 RETURN(d);
END argcpy;

BEGIN
 errno := 0;
 pexec := 0;
 IF hasXPexec THEN
   IF mode = pNOWAIT THEN
     pexec := 100;
   ELSIF mode = pOVERLAY THEN
     pexec := 200;
   END;
 ELSIF mode = pNOWAIT THEN
   errno := EINVAL;
   RETURN(-1);
 END;

 IF (argv = NULL) OR (argv^[0] = NULL) THEN
   errno := EFAULT;
   RETURN(-1);
 END;

 IF envp = NULL THEN
   envp := environ;
 END;

 (* Laenge des benoetigten Environments berechnen.
  * Dazu gehoeren entweder das uebergebene oder das aktuelle
  * Environment und die Kommandozeilenargumente einschliesslich
  * dem Programmnamen.
  *)
 lres := 0;
 i    := 0;
 null := FALSE;
 WHILE argv^[i] # NULL DO
   res := INT(strlen(argv^[i]));
   IF res = 0 THEN
     null := TRUE;
     (* Bei einem leeren Argument muss der Platz fuer den Index
      * in der ARGV-Variable beruecksichtigt werden.
      *)
     IF i > 10000 THEN
       res := 8; (* fuenf Ziffern & Komma Index + Leerzeichen + Nullbyte *)
     ELSIF i > 1000 THEN
       res := 7;
     ELSIF i > 100 THEN
       res := 6;
     ELSIF i > 10 THEN
       res := 5;
     ELSE
       res := 4;
     END;
   ELSE
     INC(res); (* Nullbyte *)
   END;
   INC(i);
   INC(lres, VAL(SIGNEDLONG,res));
 END;
 args := i;

 i := 0;
 WHILE envp^[i] # NULL DO
   INC(lres, VAL(SIGNEDLONG,strlen(envp^[i])) + VAL(SIGNEDLONG,1));
   INC(i);
 END;
 envs := i;
 INC(lres, 20); (* Platz fuer "ARGV=NULL:" & sicherheitshalber etwas mehr *)

 (* Benoetigten Speicher anfordern.
  * Wenn nicht genuegend Speicher vorhanden ist, mit Fehlermeldung abbrechen.
  *)
 IF ~Malloc(lres, envPtr) THEN
   errno := E2BIG; (* oder ENOMEM ? *)
   RETURN(-1);
 END;
 tmpPtr := envPtr;

 (* Das Environment mit den Variablen auffuellen *)
 i := 0;
 WHILE i < envs DO
   tmpPtr := argcpy(envp^[i], tmpPtr);
   INC(i);
 END;

 (* Kommandozeile mit ARGV-Verfahren ins Environment schreiben.
  * Beginn der eigentlichen Argumente (nach dem Programmnamen) merken,
  * fuer die Uebertragung in die Basepage-Kommandozeile.
  *)
 IF null THEN
   cmdLine := "ARGV=NULL:";
 ELSE
   cmdLine := "ARGV=";
 END;
 tmpPtr := argcpy(ADR(cmdLine), tmpPtr);
 IF null THEN
   tmpPtr := SUBADR(tmpPtr, 1);
   cmdLine[MaxStr] := 0C;
   i := 0;
   WHILE i < args DO
     IF argv^[i]^[0] = 0C THEN
       cmdIdx := MaxStr - 1;
       val    := i;
       REPEAT
         cmdLine[cmdIdx] := todigit(VAL(CARDINAL,val MOD 10));
         val             := val DIV 10;
         DEC(cmdIdx);
       UNTIL val = 0;
       (* Nullbyte durch Komma ersetzen *)
       tmpPtr := SUBADR(argcpy(ADR(cmdLine[cmdIdx+1]), tmpPtr), 1);
       tmpPtr^[0] := ',';
       tmpPtr := ADDADR(tmpPtr, 1);
     END;
     INC(i);
   END;
   (* das letzte Komma ist zuviel *)
   tmpPtr := SUBADR(tmpPtr, 1);
   tmpPtr^[0] := 0C;
   tmpPtr := ADDADR(tmpPtr, 1);
 END;

 cmdLine := " ";
 i       := 0;
 WHILE i < args DO
   IF argv^[i]^[0] = 0C THEN
     tmpPtr := argcpy(ADR(cmdLine), tmpPtr);
   ELSE
     tmpPtr := argcpy(argv^[i], tmpPtr);
   END;
   INC(i);
 END;
 tmpPtr^[0] := 0C; (* Ende des Environments kennzeichnen *)
 tmpPtr^[1] := 0C; (* Falls es keine Argumente gab *)

 (* Soviel der Argumente wie moeglich in die Basepage-Kommandozeile
  * uebertragen. ARGV-Verfahren durch den sonst ungueltigen
  * Kommandozeilenlaengenwert 127 signalisieren.
  *)
 cmdLine[0] := CHR(127);
 i          := 1;
 cmdIdx     := 1;
 WHILE (i < args) & (cmdIdx <= 124) DO
   tmpPtr := argv^[i]; INC(i);
   IF tmpPtr^[0] = 0C THEN
     (* Leeres Argument *)
     cmdLine[cmdIdx]   := "'";
     cmdLine[cmdIdx+1] := "'";
     INC(cmdIdx, 2);
   ELSE
     (* Argument kopieren *)
     REPEAT
       cmdLine[cmdIdx] := tmpPtr^[0];
       tmpPtr := ADDADR(tmpPtr, 1);
       INC(cmdIdx);
     UNTIL (tmpPtr^[0] = 0C) OR (cmdIdx > 124);
   END;

   (* cmdIdx <= 126 ist gesichert *)
   IF i < args THEN
     (* Ende des Arguments erreicht *)
     cmdLine[cmdIdx] := ' ';
     INC(cmdIdx);
   ELSE
     (* Ende der Argumentliste erreicht *)
     cmdLine[cmdIdx] := 0C;
   END;
 END;

 (* Die restliche Kommandozeile wird geloescht. *)
 IF cmdIdx > 125 THEN
   cmdIdx := 125;
 END;
 WHILE cmdIdx < 128 DO
   cmdLine[cmdIdx] := 0C;
   INC(cmdIdx);
 END;

 childStart := SysClock();
 done := Pexec(pexec, prg, ADR(cmdLine), envPtr, lres);
 INC(CHILDTIME, SysClock() - childStart);

 null := Mfree(envPtr, res);
 res  := INT(lres);
 IF ~done THEN
   (* Wenn "Pexec" selbst fehlschlaegt, gibts einen negativen 32-Bit-Wert. *)
   errno  := res;
   RETURN(-1);
 ELSIF mode = pOVERLAY THEN (* nur TOS *)
   (* Ohne MiNT muss selbst fuer die Beendigung des laufenden
    * Prozesses gesorgt werden. Mit MiNT kehrt der ``Pexec''-Aufruf
    * erst gar nicht zurueck!
    *)
   Exit(res);
 ELSIF mode = pWAIT THEN
   IF ~MiNT THEN
     void := raise(SIGCHLD);
   END;
   RETURN(INT(MakeWaitVal(CAST(SIGNEDWORD,VAL(UNSIGNEDWORD,CAST(CARDINAL,res))))));
 ELSE (* nur MiNT *)
   (* Bei pNOWAIT wird die (positive) Prozess-ID zurueckgegeben *)
   RETURN(res);
 END;
END Spawn;

(*---------------------------------------------------------------------------*)

PROCEDURE SpawnThis ((* EIN/ -- *) mode : SpawnMode;
                     (* EIN/ -- *) prg  : StrPtr;
                     (* EIN/ -- *) argv : StrArray;
                     (* EIN/ -- *) envp : StrArray  ): INTEGER;

VAR path0 : StrPtr;
    msize : CARDINAL;
    done  : BOOLEAN;
    void  : BOOLEAN;
    stack : ADDRESS;
    ret   : INTEGER;

BEGIN
 msize := VAL(CARDINAL,strlen(prg)) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(prg, msize - DINCR, VAL(StrRange,msize), path0, void, done);
 IF done THEN
   ret := Spawn(mode, path0, argv, envp);
 ELSE
   ret := -1;
 END;
 memdealloc(stack);
 RETURN(ret);
END SpawnThis;

(*---------------------------------------------------------------------------*)

PROCEDURE spawnv ((* EIN/ -- *) mode : SpawnMode;
                  (* EIN/ -- *) prg  : StrPtr;
                  (* EIN/ -- *) argv : StrArray  ): int;
BEGIN
 RETURN(SpawnThis(mode, prg, argv, environ));
END spawnv;

(*---------------------------------------------------------------------------*)

PROCEDURE spawnve ((* EIN/ -- *) mode : SpawnMode;
                   (* EIN/ -- *) prg  : StrPtr;
                   (* EIN/ -- *) argv : StrArray;
                   (* EIN/ -- *) envp : StrArray  ): int;
BEGIN
 RETURN(SpawnThis(mode, prg, argv, envp));
END spawnve;

(*---------------------------------------------------------------------------*)

PROCEDURE execv ((* EIN/ -- *) prg  : StrPtr;
                 (* EIN/ -- *) argv : StrArray ): int;
BEGIN
 RETURN(SpawnThis(pOVERLAY, prg, argv, environ));
END execv;

(*---------------------------------------------------------------------------*)

PROCEDURE execve ((* EIN/ -- *) prg  : StrPtr;
                  (* EIN/ -- *) argv : StrArray;
                  (* EIN/ -- *) envp : StrArray ): int;
BEGIN
 RETURN(SpawnThis(pOVERLAY, prg, argv, envp));
END execve;

(*---------------------------------------------------------------------------*)

PROCEDURE SpawnFind ((* EIN/ -- *) mode : SpawnMode;
                     (* EIN/ -- *) prg  : StrPtr;
                     (* EIN/ -- *) argv : StrArray;
                     (* EIN/ -- *) envp : StrArray  ): INTEGER;

VAR path   : StrPtr;
    tmp    : StrPtr;
    path0  : StrPtr;
    ext    : StrPtr;
    file   : StrPtr;
    pToken : StrPtr;
    eToken : StrPtr;
    stack1 : ADDRESS;
    stack2 : ADDRESS;
    stack3 : ADDRESS;
    fLen   : StrRange;
    pLen   : StrRange;
    pIdx   : StrRange;
    p1     : StrRange;
    e1     : StrRange;
    eLen   : StrRange;
    eIdx   : StrRange;
    msize  : StrRange;
    ret    : INTEGER;
    done   : BOOLEAN;
    void   : BOOLEAN;
    d,p,f  : SIGNEDWORD;
    x,l    : SIGNEDWORD;
    dpath  : ARRAY [0..2] OF CHAR;

BEGIN
 msize := VAL(StrRange,strlen(prg)) + DINCR + 1;
 memalloc(VAL(sizeT,msize), stack1, path);
 UnixToDos(prg, VAL(CARDINAL,msize - DINCR - 1), msize, path, void, done);
 IF ~done THEN
   memdealloc(stack1);
   RETURN(-1);
 END;
 SplitPath(path, d, p, f, x, l);
 IF f < 0 THEN
   (* Keine Datei angegeben *)
   errno := ENOENT;
   memdealloc(stack1);
   RETURN(-1);
 END;

 IF x >= 0 THEN
   (* <file> hat eine Extension -> nur diese probieren.
    * Dateiname von Extension trennen ('.' ueberschreiben)
    *)
   path^[x] := 0C;
   ext      := ADR(path^[x+1]);
 ELSE
   ext := getenv("TOSEXT");
   IF ext = NULL THEN
     (* <file> hat keine Extension und "TOSEXT" existiert nicht.
      * -> Extensionen aus 'DefExt' probieren.
      *)
     ext := ADR(DefExt);
   END;
 END;

 IF (d >= 0) OR (p >= 0) THEN
   (* <path> enthaelt einen Pfad und/oder ein Laufwerk -> nur dort suchen *)
   file := ADR(path^[f]);
   IF p < 0 THEN
     (* Nur Laufwerksangabe, dann ist kein Platz mehr fuer ein Nullbyte,
      * da nichts ueberschrieben werden kann; deswegen in separaten Speicher
      * kopieren.
      *)
     dpath[0] := path^[0];
     dpath[1] := ':';
     dpath[2] := 0C;
     path     := ADR(dpath);
   ELSE
     (* Pfad von Dateiname und Extension trennen (\ ueberschreiben) *)
     path^[f-1] := 0C;
   END;
 ELSE
   file := path;
   path := getenv("PATH");
   IF path = NULL THEN
     (* <path> hat keinen Pfad und "PATH" existiert nicht.
      * -> nur in 'DefPath' suchen.
      *)
     path := ADR(DefPath);
   END;
 END;

 IF x >= 0 THEN
   fLen := VAL(StrRange,x - f);
 ELSE
   fLen := VAL(StrRange,l - f);
 END;

 (* path^: Liste der zu durchsuchenden Pfade
  * file^: Dateiname ohne Pfad und Extension
  *  ext^: Liste der auszuprobierenden Extensionen
  *)

 (* Schleife ueber die Pfade *)
 pIdx := 0;
 p1   := VAL(StrRange,strlen(path));
 e1   := VAL(StrRange,strlen(ext));
 WHILE PathToken(path, p1, pIdx, pLen, pToken) DO
   IF pLen = 0 THEN
     (* leerer Pfad bedeutet: aktuelles Verzeichnis *)
     pToken := ADR(DefPath);
     pLen   := 1;
   END;
   msize := pLen + DINCR + 1 + fLen + 1;
   memalloc(VAL(sizeT,msize), stack2, tmp);
   UnixToDos(pToken, pLen, pLen + DINCR, tmp, void, done);
   IF ~done THEN
     memdealloc(stack1);
     RETURN(-1);
   END;
   pLen := VAL(StrRange,strlen(tmp));
   IF    (pLen > 0) & (tmp^[pLen-1] # DDIRSEP)
     & ~((pLen = 2) & (tmp^[1] = ':') & Cisalpha(tmp^[0]))
   THEN
     (* Zwischen Pfad und Datei muss ein \ stehen, aber nicht, wenn
      * es sich beim Pfad lediglich um eine Laufwerksangabe handelt;
      * dann soll das System naemlich automatisch das aktuelle
      * Verzeichnis dieses Laufwerks benutzen.
      *)
     tmp^[pLen] := DDIRSEP;
     INC(pLen);
   END;
   strcpy(ADR(tmp^[pLen]), file);
   INC(pLen, fLen);

   (* Schleife ueber die Extensionen *)
   done := FALSE;
   eIdx := 0;
   WHILE Token(ext, ADR(Delim), e1, eIdx, eLen, eToken) DO
     IF eLen > 0 THEN
       memalloc(VAL(sizeT,msize + 1 + eLen), stack3, path0);
       strcpy(path0, tmp);
       path0^[pLen] := '.';
       strncpy(ADR(path0^[pLen+1]), eToken, VAL(sizeT,eLen));
       path0^[pLen+1+eLen] := 0C;
       (* Extension in Kleinbuchstaben *)
       strlwr(ADR(path0^[pLen+1]));
     ELSE (* ohne Extension *)
       path0 := tmp;
       done  := TRUE; (* am Ende nicht noch mal testen *)
     END;

     IF FileExists(path0, FALSE, ret) & (ret = 1) THEN
       (* Ist regulaere Datei *)
       ret := Spawn(mode, path0, argv, envp);
       memdealloc(stack1);
       RETURN(ret);
     END;
     IF eLen > 0 THEN
       memdealloc(stack3);
     END;
   END;
   (* Noch mal ohne Extension probieren, falls noch nicht geschehen
    * und auch keine Extension angegeben war.
    *)
   IF ~done & (x < 0) & FileExists(tmp, FALSE, ret) & (ret = 1) THEN
     ret := Spawn(mode, tmp, argv, envp);
     memdealloc(stack1);
     RETURN(ret);
   END;
   memdealloc(stack2);
 END;
 errno := ENOENT;
 memdealloc(stack1);
 RETURN(-1);
END SpawnFind;

(*---------------------------------------------------------------------------*)

PROCEDURE spawnvp ((* EIN/ -- *) mode : SpawnMode;
                   (* EIN/ -- *) prg  : StrPtr;
                   (* EIN/ -- *) argv : StrArray  ): int;
BEGIN
 RETURN(SpawnFind(mode, prg, argv, environ));
END spawnvp;

(*---------------------------------------------------------------------------*)

PROCEDURE execvp ((* EIN/ -- *) prg  : StrPtr;
                  (* EIN/ -- *) argv : StrArray ): int;
BEGIN
 RETURN(SpawnFind(pOVERLAY, prg, argv, environ));
END execvp;

(*---------------------------------------------------------------------------*)

PROCEDURE times ((* -- /AUS *) VAR buf : TmsRec ): clockT;

VAR clock : UNSIGNEDLONG;
    usage : ARRAY [0..7] OF SIGNEDLONG;

BEGIN
 clock := SysClock();
 IF Prusage(ADR(usage)) >= 0 THEN
   WITH buf DO
     tmsUtime  := usage[1] DIV VAL(SIGNEDLONG,5);
     tmsStime  := usage[0] DIV VAL(SIGNEDLONG,5);
     tmsCUtime := usage[3] DIV VAL(SIGNEDLONG,5);
     tmsCStime := usage[2] DIV VAL(SIGNEDLONG,5);
   END;
 ELSE
   WITH buf DO
     tmsUtime  := VAL(clockT,clock - CHILDTIME);
     tmsStime  := 0; (* nicht feststellbar *)
     tmsCUtime := VAL(clockT,CHILDTIME);
     tmsCStime := 0; (* nicht feststellbar *)
   END;
 END;
 RETURN(VAL(clockT,clock));
END times;

(*---------------------------------------------------------------------------*)

PROCEDURE clock ( ): clockT;

VAR tms : TmsRec;

BEGIN
 IF times(tms) < VAL(clockT,0) THEN
   RETURN(-1);
 ELSE
   RETURN(tms.tmsUtime + tms.tmsStime);
 END;
END clock;

(*===========================================================================*)

BEGIN (* proc *)
 MiNT         := MiNTVersion() > 0;
 hasXPexec    := MiNT; (* muss besser gehen *)
 DefExt       := TOSEXT;
 DefPath      := ".";
 Delim        := DELIMITER;
 CHILDTIME    := 0;
 WAITTIME     := 0;
 WAITVAL.long := ECHILD;
 Stacksize    := BPSIZE + MINSTACKSIZE;
 errnoADR     := ADR(errno);
 mintADR      := ADR(MiNT);
 saveADR      := ADR(regsave);
 tforkADR     := PROCADR(tfork);
END proc.
