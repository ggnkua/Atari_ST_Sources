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
(* 31-Mai-94, Holger Kleinschmidt                                            *)
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
           StrPtr, StrRange, ArrayRange;

FROM MEMBLK IMPORT
(* PROC *) memalloc, memdealloc, memset;

FROM pLONGSET IMPORT
(* PROC *) INlong, INCLlong, EXCLlong, MASKlong;

FROM OSCALLS IMPORT
(* PROC *) Pgetpid, Pgetppid, Pgetuid, Pgetgid, Pgeteuid, Pgetegid, Psetuid,
           Psetgid, Pgetpgrp, Psetpgrp, Pfork, Pwait3, Pwaitpid, Malloc, Mfree,
           Mshrink, Pexec, Pterm, Prusage, Fclose, Fattrib, Fselect, Dgetdrv,
           Dsetdrv, Dsetpath, Fcntl, Fopen, Fforce;

FROM ctype IMPORT
(* PROC *) tocard, todigit;

FROM cstr IMPORT
(* PROC *) strlen, strcpy, strncpy, strrchr, strlwr, Token;

FROM pSTRING IMPORT
(* PROC *) SLEN;

FROM cmdline IMPORT
(* VAR  *) environ,
(* PROC *) getenv, GetEnvVar;

IMPORT e;

FROM DosSupport IMPORT
(* CONST*) TOSEXT, DINCR, XDECR, MinHandle, MaxHandle, MINSIG, MAXSIG,
(* TYPE *) FileType, HandleRange, FileAttributes, FileAttribute, DosHandler,
(* VAR  *) FD, SIGMASK, SIGPENDING, SIGHANDLER,
(* PROC *) CompletePath, UnixToDos, DosToUnix, IsTerm;

FROM DosSystem IMPORT
(* TYPE *) CmdLine, BasePtr, BasePage,
(* VAR  *) BASEP,
(* PROC *) SysClock, DosPid, DgetcwdAvail, MiNTVersion;

FROM sig IMPORT
(* CONST*) NSIG, SIGCHLD,
(* PROC *) raise;

(*==========================================================================*)

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
  MiNT      : BOOLEAN; (* Ist MiNT vorhanden ? *)
  hasDgetcwd: BOOLEAN; (* Wird Dgetcwd unterstuetzt *)
  DefExt    : ARRAY [0..29] OF CHAR;
  DefPath   : ARRAY [0..1] OF CHAR;
  Delim     : ARRAY [0..2] OF CHAR;
  nulp      : ARRAY [0..15] OF CHAR;
  Stacksize : CARDINAL;
  CHILDTIME : UNSIGNEDLONG;
  WAITTIME  : UNSIGNEDLONG;
  WAITVAL   : WaitCode;
  errnoADR  : ADDRESS;
  tforkADR  : ADDRESS;
  mintADR   : ADDRESS;
  saveADR   : ADDRESS;
#if (defined LPRM2) || (defined SPCM2)
  regsave   : ARRAY [0..3] OF ADDRESS;
#elif (defined TDIM2)
  regsave   : ARRAY [0..2] OF ADDRESS;
#elif (defined HM2)
  regsave   : ARRAY [0..12] OF ADDRESS;
#elif (defined MM2)
  regsave   : ARRAY [0..10] OF ADDRESS;
  bpsave1   : ADDRESS;
  bpsave2   : ADDRESS;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

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
 msize := SLEN(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(dir)), msize - DINCR, VAL(StrRange,msize), path0,
           dot, done);
 IF NOT done THEN
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
   e.errno := res;
   drvs    := Dsetdrv(old);
   res     := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END chdir;

(*---------------------------------------------------------------------------*)

PROCEDURE getcwd ((* EIN/ -- *) buf    : StrPtr;
                  (* EIN/ -- *) bufsiz : sizeT  ): StrPtr;

VAR err   : INTEGER;
    dlen  : INTEGER;
    xlen  : INTEGER;
    str1  : ARRAY [0..0] OF CHAR;
    stack : ADDRESS;
    msize : StrRange;
    path0 : StrPtr;

BEGIN
 IF VAL(sizeT,MAXSTR) < bufsiz THEN
   bufsiz := VAL(sizeT,MAXSTR);
 END;
 msize := VAL(StrRange,bufsiz) + XDECR;
 IF NOT hasDgetcwd AND (msize < PATHMAX) THEN
   (* mindestens PATHMAX Zeichen Puffer fuer TOS bereitstellen *)
   msize := PATHMAX;
 END;
 memalloc(VAL(sizeT,msize), stack, path0);
 str1[0] := 0C;
 IF CompletePath(CAST(StrPtr,ADR(str1)), msize, path0, dlen, err) THEN
   DosToUnix(path0, VAL(StrRange,bufsiz), buf, dlen, xlen);
   memdealloc(stack);
   IF VAL(sizeT,xlen) < bufsiz THEN
     RETURN(buf);
   ELSE
     e.errno := e.ERANGE;
     RETURN(NULL);
   END;
 ELSIF err = e.eRANGE THEN
   e.errno := e.ERANGE;
 ELSE
   e.errno := err;
 END;
 memdealloc(stack);
 RETURN(NULL);
END getcwd;

(*--------------------------------------------------------------------------*)

PROCEDURE getlogin ( ): StrPtr;
BEGIN
 IF GetEnvVar("LOGNAME", loginbuf) THEN
   (* 'LOGNAME' existiert und hat einen Wert *)
   loginbuf[MAXLOGIN] := 0C;
 ELSIF Pgetuid() <= 0 THEN
   loginbuf := "root";
 ELSE
   RETURN(NULL);
 END;
 RETURN(ADR(loginbuf));
END getlogin;

(*--------------------------------------------------------------------------*)

PROCEDURE getpid ( ): pidT;

VAR pid : INTEGER;

BEGIN
 pid := Pgetpid();
 IF pid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(DosPid(BASEP));
 ELSE
   RETURN(pid);
 END;
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

PROCEDURE setuid ((* EIN/ -- *) uid : uidT ): int;

VAR res : INTEGER;

BEGIN
 IF Psetuid(uid, res) THEN
   RETURN(0);
 ELSIF res <> e.eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   IF res = e.eACCDN THEN
     e.errno := e.EPERM;
   ELSE
     e.errno := res;
   END;
   RETURN(-1);
 ELSIF uid = 0 THEN
   RETURN(0);
 ELSE
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
END setuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setgid ((* EIN/ -- *) gid : gidT ): int;

VAR res : INTEGER;

BEGIN
 IF Psetgid(gid, res) THEN
   RETURN(0);
 ELSIF res <> e.eINVFN THEN
   (* Aufruf wird unterstuetzt, anderer Fehler *)
   IF res = e.eACCDN THEN
     e.errno := e.EPERM;
   ELSE
     e.errno := res;
   END;
   RETURN(-1);
 ELSIF gid = 0 THEN
   RETURN(0);
 ELSE
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
END setgid;

(*---------------------------------------------------------------------------*)

PROCEDURE seteuid ((* EIN/ -- *) uid : uidT ): int;
BEGIN
 RETURN(setuid(uid));
END seteuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setegid ((* EIN/ -- *) gid : gidT ): int;
BEGIN
 RETURN(setgid(gid));
END setegid;

(*---------------------------------------------------------------------------*)

PROCEDURE setreuid ((* EIN/ -- *) ruid : uidT;
                    (* EIN/ -- *) euid : uidT ): int;
BEGIN
 RETURN(setuid(euid));
END setreuid;

(*---------------------------------------------------------------------------*)

PROCEDURE setregid ((* EIN/ -- *) rgid : gidT;
                    (* EIN/ -- *) egid : gidT ): int;
BEGIN
 RETURN(setgid(egid));
END setregid;

(*---------------------------------------------------------------------------*)

PROCEDURE getpgrp ( ): pidT;

VAR pid : INTEGER;

BEGIN
 pid := Pgetpgrp();
 IF pid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(DosPid(BASEP));
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
   e.errno := e.EINVAL;
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
   ELSIF PID <> e.eINVFN THEN
     (* 'Pgetpgrp'-Aufruf wird unterstuetzt, anderer Fehler *)
     IF PID = e.eACCDN THEN
       e.errno := e.ESRCH;
     ELSE
       e.errno := PID;
     END;
     RETURN(-1);
   END;
 END;

 (* 'Pgetpid'- und/oder 'Pgetpgrp'-Aufruf wird nicht unterstuetzt *)
 PID := DosPid(BASEP);
 IF    ((pid  = 0) OR (pid  = PID))
   AND ((pgid = 0) OR (pgid = PID))
 THEN
   RETURN(0);
 ELSE
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
END setpgid;

(*--------------------------------------------------------------------------*)

PROCEDURE setsid ( ): pidT;

CONST TIOCGPGRP = 5406H; (* ('T'<<8)|6 *)
      TIOCSPGRP = 5407H; (* ('T'<<8)|7 *)
      RDWR = 2;

VAR pgrp : INTEGER;
    pid  : INTEGER;
    nulh : INTEGER;
    arg  : SIGNEDLONG;
    lres : SIGNEDLONG;
    res  : INTEGER;
    void : BOOLEAN;

BEGIN
 pgrp := Pgetpgrp();
 pid  := Pgetpid();
 IF (pgrp < 0) OR (pid < 0) OR (pgrp = pid) THEN
   (* Prozess ist bereits ``process group leader'', darf
    * kein "setsid()" ausfuehren.
    * (Oder die Aufrufe werden nicht unterstuetzt)
    *)
   e.errno := e.EPERM;
   RETURN(-1);
 END;

 IF IsTerm(-1) THEN
   (* Wenn das Kontrollterminal dieser Prozessgruppe zugeordent ist,
    * Prozessgruppe loeschen.
    *)
   IF Fcntl(-1, ADR(arg), TIOCGPGRP, lres) THEN
     IF arg = VAL(SIGNEDLONG,pgrp) THEN
       arg := 0;
       IF NOT Fcntl(-1, ADR(arg), TIOCSPGRP, lres) THEN
         e.errno := INT(lres);
         RETURN(-1);
       END;
     END;
   ELSE
     e.errno := INT(lres);
     RETURN(-1);
   END;
   (* Kontrollterminal auf /dev/null umlenken *)
   IF Fopen(ADR(nulp), RDWR, nulh) THEN
     void := Fforce(-1, nulh, res);
     void := Fclose(nulh, res);
     FD[VAL(HandleRange,-1)].ftype := unknown;
   ELSE
     e.errno := nulh;
     RETURN(-1);
   END;
 END;

 (* Neue Prozessgruppe hat die Kennung des aufrufenden Prozesses. *)
 IF Psetpgrp(0, 0, pgrp) THEN
   RETURN(pgrp);
 ELSE
   IF pgrp = e.eACCDN THEN
     e.errno := e.ESRCH;
   ELSE
     e.errno := pgrp;
   END;
   RETURN(-1);
 END;
END setsid;

(*--------------------------------------------------------------------------*)

PROCEDURE fork ( ): pidT;

VAR pid : INTEGER;

BEGIN
 pid := Pfork();
 IF pid >= 0 THEN
   RETURN(pid);
 ELSE
   e.errno := pid;
   RETURN(-1);
 END;
END fork;

(*---------------------------------------------------------------------------*)

PROCEDURE MakeWaitVal ((* EIN/ -- *) retCode : SIGNEDWORD ): SIGNEDWORD;

CONST SIGINT = 2;

VAR __REG__ exit : UNSIGNEDWORD;
    __REG__ sig  : UNSIGNEDWORD;
    __REG__ ret  : WORDSET;

BEGIN
 IF retCode = -32 THEN
   (* Programm wurde durch 'Ctrl-C' abgebrochen *)
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
 IF (sig <> 0) AND (exit <> 0) AND (exit <> 127) THEN
   (* normaler Returncode, kein Signal *)
   sig := 0;
 END;
 IF (exit = 127) AND (sig <> 0) THEN
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
    Pterm(tProc(tArg));
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
    IF MiNT THEN
      done := Pexec(104, NULL, b, NULL, pid);
    ELSE
      (* Programm hat eine neue Basepage, deshalb die alte merken *)
      base  := BASEP;
      BASEP := CAST(BasePtr,b);

      (* Dos-Emulations-Variablen fuer Signale sichern *)
      mask    := SIGMASK;
      pending := SIGPENDING;
      handler := SIGHANDLER;
      (* keine Signale blockiert *)
      SIGMASK := 0;

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
    (* Der Speicher fuer Basepage und Environment gehoert dem
     * aufrufenden Prozess; er wird deshalb nicht automatisch nach
     * Beendigung des Unterprozesses freigegeben.
     *)
    void := Mfree(b^.env, err);
    void := Mfree(b, err);

    IF done THEN
      RETURN(INT(pid)); (* Eine gueltige Prozesskennung ist immer positiv *)
    ELSE
      e.errno := INT(pid);
      RETURN(-1);
    END;
  ELSE
    e.errno := INT(ret);
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
  movea.l (SP)+,A1       ; RTN-Adresse vom Stack retten
;; SETREG(8, mintADR);
  tst.b   (A0)
  beq.s   tos
  move.w  #$0113,-(SP)   ; Pvfork
  trap    #1             ;
  addq.l  #2,SP          ;
  tst.w   D0
  bmi.s   err
  bra.s   ende
tos:
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
  move.w  D0,(A0)        ; e.errno setzen
  moveq   #-1,D0

ende:
  move.w  D0,(SP)
  movea.l A3,A4          ; alte Modulbasis setzen
  jmp     (A1)
*)
 CODE(2C5FH,265FH,225FH);
 SETREG(8, mintADR);
 CODE(4A10H,670EH,3F3CH,0113H,4E41H,548FH,4A40H,6B32H,6038H);
 SETREG(8, saveADR);
 CODE(48D0H,6A00H,558FH,487AH,0018H,4850H);
 SETREG(8, tforkADR);
 CODE(4E90H);
 SETREG(8, saveADR);
 CODE(301FH,4CD0H,6A00H,6B0EH,6014H,588FH,205FH,4CD0H,6A00H,7000H,6008H);
 SETREG(8, errnoADR);
 CODE(3080H,70FFH,3E80H,284BH,4ED1H);
END vfork;

#elif (defined TDIM2)

__PROCFRAME_OFF__
PROCEDURE vfork ( ): pidT;
BEGIN
(*
  movea.l (SP)+,A1       ; RTN-Adresse vom Stack retten
;; SETREG(8, mintADR);
  tst.b   (A0)
  beq.s   tos
  move.w  #$0113,-(SP)   ; Pvfork
  trap    #1             ;
  addq.l  #2,SP          ;
  tst.w   D0
  bmi.s   err
  bra.s   ende
tos:
  nop                    ;; durch SETREG(8, saveADR); ersetzt
  nop                    ;;
  nop                    ;;
  movem.l A1/A5/A6,(A0)
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
  movem.l (A0),A1/A5/A6
  bmi.s   err
  bra.s   ende

child:
  addq.l  #4,SP          ; RTN-Adresse weg
  movea.l (SP)+,A0       ; a0 := saveADR
  movem.l (A0),A1/A5/A6
  moveq   #0,D0
  bra.s   ende

err:
  nop                    ;; durch SETREG(8, errnoADR); ersetzt
  nop                    ;;
  nop                    ;;
  move.w  D0,(A0)        ; e.errno setzen
  moveq   #-1,D0

ende:
  move.w  D0,(SP)
  jmp     (A1)
*)
 CODE(225FH);
 SETREG(8, mintADR);
 CODE(4A10H,670EH,3F3CH,0113H,4E41H,548FH,4A40H,6B3AH,6042H);
 SETREG(8, saveADR);
 CODE(48D0H,6200H,558FH,487AH,001EH,4850H);
 SETREG(8, tforkADR);
 CODE(4E90H);
 SETREG(8, saveADR);
 CODE(508FH,301FH,4CD0H,6200H,6B0EH,6016H,588FH,205FH,4CD0H,6200H,7000H,600AH);
 SETREG(8, errnoADR);
 CODE(3080H,70FFH,3E80H,4ED1H);
END vfork;
__PROCFRAME_ON__

#elif (defined HM2)

PROCEDURE vfork ( ): pidT;
BEGIN
(*
; HM
  move.l  (SP)+,D1       ; Modulbasis vom Stack retten
  movea.l (SP)+,A6       ; Frame-Pointer vom Stack retten
  movea.l (SP)+,A1       ; RTN-Adresse vom Stack retten
;; SETREG(8, mintADR);
  tst.b   (A0)
  beq.s   tos
  movea.l D1,A5
  move.w  #$0113,-(SP)   ; Pvfork
  trap    #1             ;
  addq.l  #2,SP          ;
  move.l  A5,D1
  tst.w   D0
  bmi.s   err
  bra.s   ende
tos:
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
  move.l  D0,(A0)        ; e.errno setzen
#else
  move.w  D0,(A0)        ; e.errno setzen
#endif
  moveq   #-1,D0
ende
  movea.l D1,A5          ; alte Modulbasis setzen
  jmp     (A1)
*)

 CODE(221FH,2C5FH,225FH);
 SETREG(8, mintADR);
 CODE(4A10H,6712H,2A41H,3F3CH,0113H,4E41H,548FH,220DH,4A40H,6B30H,6036H);
 SETREG(8, saveADR);
 CODE(48D0H,7EFEH,4850H,487AH,0016H);
 SETREG(8, tforkADR);
 CODE(4E90H);
 SETREG(8, saveADR);
 CODE(4CD0H,7EFEH,4A40H,6B0EH,6014H,588FH,205FH,4CD0H,7EFEH,7000H,6008H);
 SETREG(8, errnoADR);
#ifdef __LONG_WHOLE__
 CODE(2080H);
#else
 CODE(3080H);
#endif
 CODE(70FFH,2A41H,4ED1H);
END vfork;

#elif (defined MM2)

#warning *** vfork does not work with MM2 and plain TOS

__PROCFRAME_OFF__
PROCEDURE vfork ( ): pidT;
BEGIN
 ASSEMBLER
   MOVEA.L (A7)+, A1
   MOVE.L  ActMOSProcess, bpsave1
   MOVE.L  BaseProcess, bpsave2
   TST.W   MiNT
   BEQ.S   tos
   MOVE.W  #$0113, -(A7)
   TRAP    #1
   ADDQ.L  #2, A7
   TST.W   D0
   BMI.S   err
   BEQ.S   clear
   MOVE.L  bpsave1, ActMOSProcess
   MOVE.L  bpsave2, BaseProcess
   BRA.S   ende
 clear:
   CLR.L   ActMOSProcess
   CLR.L   BaseProcess
   BRA.S   ende

 tos:
   MOVEM.L D3-D7/A1/A3-A6, regsave
   LEA     child(PC), A0
   MOVE.L  A0, (A3)+
   MOVE.L  #regsave, (A3)+
#ifdef __RES_ON_STACK__
   JSR     tfork
#ifdef __LONG_WHOLE__
   MOVE.L  -(A3), D0
#else
   MOVE.W  -(A3), D0
#endif
#else
   JSR     tfork/
#endif
   MOVEM.L regsave, D3-D7/A1/A3-A6
   TST.W   D0
   BMI.S   err
   BRA.S   ende

 child:
   ADDQ.L  #4, A7
   MOVEA.L -(A3), A0
   MOVEM.L (A0), D3-D7/A1/A3-A6
   MOVEQ   #0, D0
   BRA.S   ende

 err:
#ifdef __LONG_WHOLE__
   MOVE.L  D0, e.errno
#else
   MOVE.W  D0, e.errno
#endif
   MOVEQ   #-1, D0

 ende:
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
   MOVE.L  D0, (A3)+
#else
   MOVE.W  D0, (A3)+
#endif
#endif
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
 IF NOT done AND (INT(res.long) = e.eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := e.ECHILD;
   WAITTIME     := 0;
 END;
 IF NOT done THEN
   e.errno := INT(res.long);
   RETURN(-1);
 END;
 state := CAST(WaitVal,MakeWaitVal(res.term));
 RETURN(VAL(pidT,res.pid));
END wait;

(*---------------------------------------------------------------------------*)

PROCEDURE waitpid ((* EIN/ -- *)     pid     : pidT;
                   (* -- /AUS *) VAR state   : WaitVal;
                   (* EIN/ -- *)     options : WaitOption ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;

BEGIN
 state := WaitVal{};
 done  := Pwaitpid(pid, options, NULL, res.long);
 IF NOT done AND (INT(res.long) = e.eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   IF (pid <> -1) AND (pid <> 0) THEN
     e.errno := e.EINVAL;
     RETURN(-1);
   END;
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := e.ECHILD;
   WAITTIME     := 0;
 END;
 IF NOT done THEN
   e.errno := INT(res.long);
   RETURN(-1);
 END;
 state := CAST(WaitVal,MakeWaitVal(res.term));
 RETURN(VAL(pidT,res.pid));
END waitpid;

(*---------------------------------------------------------------------------*)

PROCEDURE wait3 ((* -- /AUS *) VAR state   : WaitVal;
                 (* EIN/ -- *)     options : WaitOption;
                 (* -- /AUS *) VAR usage   : RusageRec   ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;
    rsc  : ARRAY [0..1] OF SIGNEDLONG;

BEGIN
 state := WaitVal{};
 done  := Pwait3(options, ADR(rsc), res.long);
 IF NOT done AND (INT(res.long) = e.eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := e.ECHILD;
   rsc[0]       := WAITTIME * VAL(UNSIGNEDLONG,5);
   rsc[1]       := 0;
   WAITTIME     := 0;
 END;
 IF NOT done THEN
   e.errno := INT(res.long);
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
                 (* EIN/ -- *)     options : WaitOption;
                 (* -- /AUS *) VAR usage   : RusageRec   ): pidT;

VAR res  : WaitCode;
    done : BOOLEAN;
    rsc  : ARRAY [0..1] OF SIGNEDLONG;

BEGIN
 IF pid < 0 THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 ELSIF pid = 0 THEN
   pid := -1;
 END;
 state := WaitVal{};
 done  := Pwaitpid(pid, options, ADR(rsc), res.long);
 IF NOT done AND (INT(res.long) = e.eINVFN) THEN
   (* Aufruf wird nicht unterstuetzt *)
   IF pid <> -1 THEN
     e.errno := e.EINVAL;
     RETURN(-1);
   END;
   res          := WAITVAL;
   done         := res.long >= EOKL;
   WAITVAL.long := e.ECHILD;
   rsc[0]       := WAITTIME * VAL(UNSIGNEDLONG,5);
   rsc[1]       := 0;
   WAITTIME     := 0;
 END;
 IF NOT done THEN
   e.errno := INT(res.long);
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
 RETURN((state * wStopval <> WSTOPPED) AND (state * wTermsig = WaitVal{}));
END WIFEXITED;

(*---------------------------------------------------------------------------*)

PROCEDURE WEXITSTATUS ((* EIN/ -- *) state : WaitVal ): int;
BEGIN
 RETURN(INT(CAST(SIGNEDWORD,state * wRetcode) DIV 256));
END WEXITSTATUS;

(*---------------------------------------------------------------------------*)

PROCEDURE WIFSIGNALED ((* EIN/ -- *) state : WaitVal ): BOOLEAN;
BEGIN
 RETURN((state * wStopval <> WSTOPPED) AND (state * wTermsig <> WaitVal{}));
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
 IF (fd >= 0) AND (fd < FDSETSIZE) THEN
   cast.fdset := fdset;
   INCLlong(cast.fdlong, VAL(UNSIGNEDWORD,fd));
   fdset := cast.fdset;
 END;
END FDSET;

(*---------------------------------------------------------------------------*)

PROCEDURE FDCLR ((* EIN/ -- *)     fd    : int;
                 (* -- /AUS *) VAR fdset : fdSet );

VAR cast : LONGfdset;

BEGIN
 IF (fd >= 0) AND (fd < FDSETSIZE) THEN
   cast.fdset := fdset;
   EXCLlong(cast.fdlong, VAL(UNSIGNEDWORD,fd));
   fdset := cast.fdset;
 END;
END FDCLR;

(*---------------------------------------------------------------------------*)

PROCEDURE FDISSET ((* EIN/ -- *) fd    : int;
                   (* EIN/ -- *) fdset : fdSet ): BOOLEAN;

VAR cast : LONGfdset;

BEGIN
 IF (fd >= 0) AND (fd < FDSETSIZE) THEN
   cast.fdset := fdset;
   RETURN(INlong(VAL(UNSIGNEDWORD,fd), cast.fdlong));
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

VAR         mrfds  : LONGfdset;
            mwfds  : LONGfdset;
            mxfds  : LONGfdset;
            res    : INTEGER;
            done   : BOOLEAN;
    __REG__ tmout  : UNSIGNEDLONG;
    __REG__ mtmout : CARDINAL;

BEGIN
 IF width < 0 THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;

 IF readfds <> NULL THEN
   mrfds.fdset := readfds^;
   IF width < FDSETSIZE THEN
     MASKlong(VAL(UNSIGNEDWORD,width), mrfds.fdlong);
     readfds^ := mrfds.fdset;
   END;
 END;
 IF writefds <> NULL THEN
   mwfds.fdset := writefds^;
   IF width < FDSETSIZE THEN
     MASKlong(VAL(UNSIGNEDWORD,width), mwfds.fdlong);
     writefds^ := mwfds.fdset;
   END;
 END;
 IF exceptfds <> NULL THEN
   mxfds.fdset := exceptfds^;
   IF width < FDSETSIZE THEN
     MASKlong(VAL(UNSIGNEDWORD,width), mxfds.fdlong);
   END;
   exceptfds^ := mxfds.fdset;
 END;

 IF timeout <> NULL THEN
   WITH timeout^ DO
     tmout := CAST(UNSIGNEDLONG,  tvSec  *   VAL(long,1000)
                                + tvUSec DIV VAL(long,1000));
   END;
   IF tmout = VAL(UNSIGNEDLONG,0) THEN
     tmout := 1;
   END;
 ELSE
   tmout := 0; (* Kein Timeout, beliebig lange warten *)
 END;

 LOOP
   IF tmout > VAL(UNSIGNEDLONG,65535) THEN
     mtmout := 65535;
   ELSE
     mtmout := VAL(CARDINAL,tmout);
   END;
   DEC(tmout, VAL(UNSIGNEDLONG,mtmout));
   IF NOT Fselect(mtmout, readfds, writefds, exceptfds, res) THEN
     e.errno := res;
     RETURN(-1);
   ELSIF (res > 0) OR (tmout = VAL(UNSIGNEDLONG,0)) THEN
     (* Mindestens eine Datei ist bereit oder Timeout abgelaufen *)
     RETURN(res);
   END;
   IF readfds <> NULL THEN
     readfds^ := mrfds.fdset;
   END;
   IF writefds <> NULL THEN
     writefds^ := mwfds.fdset;
   END;
   IF exceptfds <> NULL THEN
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
    __REG__ argPtr     : StrPtr;
    __REG__ cmdIdx     : StrRange;
    __REG__ envIdx     : StrRange;
    __REG__ i          : ArrayRange;
            args       : ArrayRange;
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
            fd         : HandleRange;

PROCEDURE argcpy (arg : StrPtr; envIdx : StrRange): StrRange;
VAR __REG__ i : StrRange;
    __REG__ c : CHAR;
BEGIN
 i := 0;
 REPEAT
   c := arg^[i];
   envPtr^[envIdx] := c;
   INC(i);
   INC(envIdx);
 UNTIL c = 0C;
 RETURN(envIdx);
END argcpy;

BEGIN
 e.errno := 0;
 pexec := 0;
 IF MiNT THEN
   IF mode = pNOWAIT THEN
     pexec := 100;
   ELSIF mode = pOVERLAY THEN
     pexec := 200;
   END;
 ELSIF mode = pNOWAIT THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;

 IF (argv = NULL) OR (argv^[0] = NULL) THEN
   e.errno := e.EFAULT;
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
 WHILE argv^[i] <> NULL DO
   res := INT(strlen(argv^[i]));
   IF res = 0 THEN
     null := TRUE;
     (* Bei einem leeren Argument muss der Platz fuer den Index
      * in der ARGV-Variable beruecksichtigt werden.
      * Es werden maximal 9999 Argumente korrekt bearbeitet.
      *)
     IF i > 1000 THEN
       res := 7; (* vier Ziffern & Komma Index + Leerzeichen + Nullbyte *)
     ELSIF i > 100 THEN
       res := 6;
     ELSIF i > 10 THEN
       res := 5;
     ELSE
       res := 4;
     END;
   ELSE
     INC(res); (* wegen Nullbyte *)
   END;
   INC(i);
   INC(lres, VAL(SIGNEDLONG,res));
 END;
 args := i;

 i := 0;
 WHILE envp^[i] <> NULL DO
   INC(lres, VAL(SIGNEDLONG,strlen(envp^[i]))+VAL(SIGNEDLONG,1));
   INC(i);
 END;
 envs := i;
 INC(lres, 20); (* Platz fuer "ARGV=NULL:" & sicherheitshalber etwas mehr *)

 (* Benoetigten Speicher anfordern.
  * Wenn nicht genuegend Speicher vorhanden ist, mit Fehlermeldung abbrechen.
  *)
 IF NOT Malloc(lres, envPtr) THEN
   e.errno := e.E2BIG;
   RETURN(-1);
 END;
 envIdx := 0;

 (* Das Environment mit den Variablen auffuellen *)
 i := 0;
 WHILE i < envs DO
   envIdx := argcpy(envp^[i], envIdx);
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
 envIdx := argcpy(CAST(StrPtr,ADR(cmdLine)), envIdx);
 IF null THEN
   DEC(envIdx);
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
       envIdx := argcpy(CAST(StrPtr,ADR(cmdLine[cmdIdx+1])), envIdx);
       envPtr^[envIdx-1] := ',';
     END;
     INC(i);
   END;
   (* das letzte Komma ist zuviel *)
   envPtr^[envIdx-1] := 0C;
 END;

 cmdLine := " ";
 i       := 0;
 WHILE i < args DO
   IF argv^[i]^[0] = 0C THEN
     envIdx := argcpy(CAST(StrPtr,ADR(cmdLine)), envIdx);
   ELSE
     envIdx := argcpy(argv^[i], envIdx);
   END;
   INC(i);
 END;
 envPtr^[envIdx]   := 0C; (* Ende des Environments kennzeichnen *)
 envPtr^[envIdx+1] := 0C; (* Falls es keine Argumente gab *)

 (* Soviel der Argumente wie moeglich in die Basepage-Kommandozeile
  * uebertragen. ARGV-Verfahren durch den sonst ungueltigen
  * Kommandozeilenlaengenwert 127 signalisieren.
  *)
 cmdLine[0] := CHR(127);
 i      := 1;
 cmdIdx := 1;
 WHILE (i < args) AND (cmdIdx <= 124) DO
   envIdx := 0;
   argPtr := argv^[i]; INC(i);
   IF argPtr^[0] = 0C THEN
     (* Leeres Argument *)
     cmdLine[cmdIdx]   := "'";
     cmdLine[cmdIdx+1] := "'";
     INC(cmdIdx, 2);
   ELSE
     (* Argument kopieren *)
     REPEAT
       cmdLine[cmdIdx] := argPtr^[envIdx];
       INC(envIdx);
       INC(cmdIdx);
     UNTIL (argPtr^[envIdx] = 0C) OR (cmdIdx > 124);
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

 (* Unter TOS alle offenen Dateien schliessen, bei denen das 'FdCloExec'-Flag
  * gesetzt ist. Kein WITH verwenden, da sonst evtl. keine Registervariable
  * fuer Pointer mehr uebrig (MM2).
  *)
 IF NOT MiNT THEN
   FOR fd := MinHandle TO MaxHandle DO
     IF FD[fd].cloex THEN
       done := Fclose(INT(fd), res);
       FD[fd].ftype := unknown;
       FD[fd].cloex := FALSE;
     END;
   END;
 END;

 childStart := SysClock();
 done := Pexec(pexec, prg, ADR(cmdLine), envPtr, lres);
 INC(CHILDTIME, SysClock() - childStart);

 null := Mfree(envPtr, res);
 res  := INT(lres);
 IF NOT done THEN
   (* Wenn "Pexec" selbst fehlschlaegt, gibts einen negativen 32-Bit-Wert. *)
   e.errno  := res;
   RETURN(-1);
 ELSIF mode = pOVERLAY THEN (* nur TOS *)
   (* Ohne MiNT muss selbst fuer die Beendigung des laufenden
    * Prozesses gesorgt werden. Mit MiNT kehrt der ``Pexec''-Aufruf
    * erst gar nicht zurueck!
    *)
   Pterm(res);
 ELSIF mode = pWAIT THEN
   IF NOT MiNT THEN
     void := raise(SIGCHLD);
   END;
   RETURN(INT(MakeWaitVal(CAST(SIGNEDWORD,VAL(UNSIGNEDWORD,CAST(CARDINAL,res))))));
 ELSE (* nur MiNT *)
   (* Bei pNOWAIT wird die (positive) Prozess-ID zurueckgegeben *)
   RETURN(res);
 END;
END Spawn;

(*---------------------------------------------------------------------------*)

PROCEDURE SpawnThis ((* EIN/ -- *)     mode : SpawnMode;
                     (* EIN/ -- *) VAR prg  : ARRAY OF CHAR;
                     (* EIN/ -- *)     argv : StrArray;
                     (* EIN/ -- *)     envp : StrArray      ): INTEGER;

VAR path0 : StrPtr;
    msize : CARDINAL;
    done  : BOOLEAN;
    void  : BOOLEAN;
    stack : ADDRESS;
    ret   : INTEGER;

BEGIN
 msize := SLEN(prg) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,ADR(prg)), msize - DINCR, VAL(StrRange,msize), path0,
           void, done);
 IF done THEN
   ret := Spawn(mode, path0, argv, envp);
 ELSE
   ret := -1;
 END;
 memdealloc(stack);
 RETURN(ret);
END SpawnThis;

(*---------------------------------------------------------------------------*)

PROCEDURE spawnv ((* EIN/ -- *)     mode : SpawnMode;
                  (* EIN/ -- *) REF prg  : ARRAY OF CHAR;
                  (* EIN/ -- *)     argv : StrArray      ): int;
BEGIN
 RETURN(SpawnThis(mode, prg, argv, environ));
END spawnv;

(*---------------------------------------------------------------------------*)

PROCEDURE spawnve ((* EIN/ -- *)     mode : SpawnMode;
                   (* EIN/ -- *) REF prg  : ARRAY OF CHAR;
                   (* EIN/ -- *)     argv : StrArray;
                   (* EIN/ -- *)     envp : StrArray      ): int;
BEGIN
 RETURN(SpawnThis(mode, prg, argv, envp));
END spawnve;

(*---------------------------------------------------------------------------*)

PROCEDURE execv ((* EIN/ -- *) REF prg  : ARRAY OF CHAR;
                 (* EIN/ -- *)     argv : StrArray      ): int;
BEGIN
 RETURN(SpawnThis(pOVERLAY, prg, argv, environ));
END execv;

(*---------------------------------------------------------------------------*)

PROCEDURE execve ((* EIN/ -- *) REF prg  : ARRAY OF CHAR;
                  (* EIN/ -- *)     argv : StrArray;
                  (* EIN/ -- *)     envp : StrArray      ): int;
BEGIN
 RETURN(SpawnThis(pOVERLAY, prg, argv, envp));
END execve;

(*---------------------------------------------------------------------------*)

PROCEDURE SpawnFind ((* EIN/ -- *)     mode : SpawnMode;
                     (* EIN/ -- *) VAR prg  : ARRAY OF CHAR;
                     (* EIN/ -- *)     argv : StrArray;
                     (* EIN/ -- *)     envp : StrArray      ): INTEGER;
(**)
VAR path   : StrPtr;
    tmp    : StrPtr;
    path0  : StrPtr;
    ext    : StrPtr;
    file   : StrPtr;
    pToken : StrPtr;
    eToken : StrPtr;
    fLen   : StrRange;
    pLen   : StrRange;
    pIdx   : StrRange;
    p1, p2 : StrRange;
    eLen   : StrRange;
    eIdx   : StrRange;
    e1, e2 : StrRange;
    msize  : StrRange;
    done   : BOOLEAN;
    void   : BOOLEAN;
    stack1 : ADDRESS;
    stack2 : ADDRESS;
    stack3 : ADDRESS;
    ws     : WORDSET;
    ret    : INTEGER;

BEGIN
 msize := VAL(StrRange,SLEN(prg) + DINCR);
 memalloc(VAL(sizeT,msize), stack1, path);
 UnixToDos(CAST(StrPtr,ADR(prg)), VAL(CARDINAL,msize - DINCR), msize, path,
           void, done);
 IF NOT done THEN
   memdealloc(stack1);
   RETURN(-1);
 END;
 ext := strrchr(path, SUFFIXSEP);
 tmp := strrchr(path, DDIRSEP);

 IF tmp <> NULL THEN
   (* <path> enthaelt einen Pfad -> nur dort suchen *)
   tmp^[0] := 0C; (* Pfad von Dateiname und Extension trennen *)
   file    := ADDADR(tmp, 1);
 ELSE
   file := path;
   path := getenv("PATH");
   IF path = NULL THEN
     (* <path> hat keinen Pfad und "PATH" existiert nicht.
      * -> nur in 'DefPath' suchen.
      *)
     path := CAST(StrPtr,ADR(DefPath));
   END;
 END;

 IF DIFADR(ext, tmp) > VAL(SIGNEDLONG,0) THEN
   (* <file> hat eine Extension -> nur diese probieren *)
   ext^[0] := 0C; (* Dateiname von Extension trennen *)
   ext     := ADDADR(ext, 1);
 ELSE
   ext := getenv("TOSEXT");
   IF ext = NULL THEN
     (* <file> hat keine Extension und "TOSEXT" existiert nicht.
      * -> Extensionen aus 'DefExt' probieren.
      *)
     ext := CAST(StrPtr,ADR(DefExt));
   END;
 END;

 fLen := VAL(StrRange,strlen(file));
 IF fLen = 0 THEN
   e.errno := e.ENOENT;
   memdealloc(stack1);
   RETURN(-1);
 END;

 (* path^: Liste der zu durchsuchenden Pfade
  * file^: Dateiname ohne Pfad und Extension
  *  ext^: Liste der auszuprobierenden Extensionen
  *)

 (* Schleife ueber die Pfade *)
 pIdx := 0; p1 := 0;
 WHILE Token(path, CAST(StrPtr,ADR(Delim)), pIdx, p1, p2, pLen, pToken) DO
   IF pLen = 0 THEN
     (* leerer Pfad bedeutet: aktuelles Verzeichnis *)
     pToken := CAST(StrPtr,ADR(DefPath));
     pLen   := 1;
   END;
   msize := pLen + DINCR + 1 + fLen;
   memalloc(VAL(sizeT,msize), stack2, tmp);
   UnixToDos(pToken, pLen, pLen + DINCR, tmp, void, done);
   IF NOT done THEN
     memdealloc(stack1);
     RETURN(-1);
   END;
   pLen := VAL(StrRange,strlen(tmp));
   IF (pLen > 0) AND (tmp^[pLen-1] <> DDIRSEP) THEN
     tmp^[pLen] := DDIRSEP;
     INC(pLen);
   END;
   strcpy(CAST(StrPtr,ADR(tmp^[pLen])), file);
   INC(pLen, fLen);

   (* Schleife ueber die Extensionen *)
   eIdx := 0; e1 := 0;
   WHILE Token(ext, CAST(StrPtr,ADR(Delim)), eIdx, e1, e2, eLen, eToken) DO
     IF eLen > 0 THEN
       memalloc(VAL(sizeT,msize + 1 + eLen), stack3, path0);
       strcpy(path0, tmp);
       path0^[pLen] := '.';
       strncpy(CAST(StrPtr,ADR(path0^[pLen+1])), eToken, VAL(sizeT,eLen));
       (* Extension in Kleinbuchstaben *)
       strlwr(CAST(StrPtr,ADR(path0^[pLen+1])));
       path0^[pLen+1+eLen] := 0C;
     ELSE
       path0 := tmp;
     END;

     IF Fattrib(path0, 0, 0, ws) THEN
       ret := Spawn(mode, path0, argv, envp);
       memdealloc(stack1);
       RETURN(ret);
     END;
     IF eLen > 0 THEN
       memdealloc(stack3);
     END;
   END;
   (* Zum Schluss nochmal ohne Extension probieren *)
   IF Fattrib(tmp, 0, 0, ws) THEN
     ret := Spawn(mode, tmp, argv, envp);
     memdealloc(stack1);
     RETURN(ret);
   END;
   memdealloc(stack2);
 END;
 e.errno := e.ENOENT;
 memdealloc(stack1);
 RETURN(-1);
END SpawnFind;

(*---------------------------------------------------------------------------*)

PROCEDURE spawnvp ((* EIN/ -- *)     mode : SpawnMode;
                   (* EIN/ -- *) REF prg  : ARRAY OF CHAR;
                   (* EIN/ -- *)     argv : StrArray      ): int;
BEGIN
 RETURN(SpawnFind(mode, prg, argv, environ));
END spawnvp;

(*---------------------------------------------------------------------------*)

PROCEDURE execvp ((* EIN/ -- *) REF prg  : ARRAY OF CHAR;
                  (* EIN/ -- *)     argv : StrArray      ): int;
BEGIN
 RETURN(SpawnFind(pOVERLAY, prg, argv, environ));
END execvp;

(*---------------------------------------------------------------------------*)

PROCEDURE Exit ((* EIN/ -- *) retval : int );
BEGIN
 Pterm(retval);
END Exit;

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
 nulp         := "u:\dev\null";
 hasDgetcwd   := DgetcwdAvail();
 DefExt       := TOSEXT;
 DefPath      := ".";
 Delim        := ",;";
 CHILDTIME    := 0;
 WAITTIME     := 0;
 WAITVAL.long := e.ECHILD;
 Stacksize    := BPSIZE + MINSTACKSIZE;
 errnoADR     := ADR(e.errno);
 mintADR      := ADR(MiNT);
 saveADR      := ADR(regsave);
 tforkADR     := PROCADR(tfork);
END proc.
