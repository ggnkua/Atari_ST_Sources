IMPLEMENTATION MODULE sig;
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

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, WORDSETRANGE, WORDSET;

FROM types IMPORT
(* CONST*) ClkTck,
(* TYPE *) int, unsigned, signedlong, pidT;

IMPORT e;

FROM pLONGSET IMPORT
(* PROC *) UNIONlong, DIFFlong, INCLlong, EXCLlong, INlong;

FROM DosSystem IMPORT
(* VAR  *) BASEP,
(* PROC *) SysClock, DosPid, MiNTVersion;

FROM DosSupport IMPORT
(* CONST*) MINSIG, MAXSIG,
(* VAR  *) SIGMASK, SIGPENDING, SIGHANDLER;

FROM OSCALLS IMPORT
(* PROC *) Pkill, Psigpause, Psigblock, Psigsetmask, Psigpending, Pause,
           Psignal, Psigaction, Pterm, Talarm, Tmalarm, Fselect, Pgetpid,
           Syield, Pgetpgrp;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  LONGsigset = RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: sigset  : sigsetT;
     |TRUE : siglong : UNSIGNEDLONG;
    END;
  END;

VAR
  MiNT    : BOOLEAN;
  hasMask : BOOLEAN; (* Werden 'Psigblock' und 'Psigsetmask' unterstuetzt ? *)

#if !((defined HM2) || (defined TDIM2))
VAR
  Wrapper : RECORD
    code1 : UNSIGNEDLONG;
    code2 : UNSIGNEDWORD;
    code3 : UNSIGNEDWORD;
    call  : SigHandler;
    code4 : UNSIGNEDWORD;
  END;
#endif

VAR
  Catch : UNSIGNEDWORD;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE sigemptyset ((* -- /AUS *) VAR set : sigsetT );
BEGIN
 set[0] := WORDSET{};
 set[1] := WORDSET{};
END sigemptyset;

(*---------------------------------------------------------------------------*)

PROCEDURE sigfillset ((* -- /AUS *) VAR set : sigsetT );
BEGIN
 set[0] := WORDSET{0..15};
 set[1] := WORDSET{0..15};
END sigfillset;

(*---------------------------------------------------------------------------*)

PROCEDURE sigaddset ((* EIN/AUS *) VAR set : sigsetT;
                     (* EIN/ -- *)     sig : int     ): int;

VAR cast : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 cast.sigset := set;
 INCLlong(cast.siglong, VAL(UNSIGNEDWORD,sig));
 set := cast.sigset;
 RETURN(0);
END sigaddset;

(*---------------------------------------------------------------------------*)

PROCEDURE sigdelset ((* EIN/AUS *) VAR set : sigsetT;
                     (* EIN/ -- *)     sig : int     ): int;

VAR cast : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 cast.sigset := set;
 EXCLlong(cast.siglong, VAL(UNSIGNEDWORD,sig));
 set := cast.sigset;
 RETURN(0);
END sigdelset;

(*---------------------------------------------------------------------------*)

PROCEDURE sigismember ((* EIN/ -- *) set : sigsetT;
                       (* EIN/ -- *) sig : int     ): int;

VAR cast : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 cast.sigset := set;
 RETURN(INT(INlong(VAL(UNSIGNEDWORD,sig), cast.siglong)));
END sigismember;

(*---------------------------------------------------------------------------*)
#if (defined HM2)
(*$E+*)
#endif
(* Ohne MiNT fuer alle Compiler, mit MiNT nur fuer LPR, SPC und MM
 * noetig.
 *)
PROCEDURE dispatch ((* EIN/ -- *) sig : UNSIGNEDLONG );
VAR handler : SignalHandler;
BEGIN
 handler.long := SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER;
 handler.proc(sig);
END dispatch;
#if (defined HM2)
(*$E=*)
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE kill ((* EIN/ -- *) pid : pidT;
                (* EIN/ -- *) sig : int  ): int;

VAR handler  : SignalHandler;
    res      : INTEGER;
    savemask : UNSIGNEDLONG;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 IF Pkill(pid, sig, res) THEN
   RETURN(0);
 ELSIF res <> e.eINVFN THEN
   (* 'Pkill'-Aufruf wird unterstuetzt, anderer Fehler *)
   e.errno := res;
   RETURN(-1);
 ELSE
   (* 'Pkill'-Aufruf wird nicht unterstuetzt *)
   IF (pid < 0) OR (pid > 0) AND (pid <> DosPid(BASEP)) THEN
     e.errno := e.ESRCH;
     RETURN(-1);
   END;
   handler.long := SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER;
   IF (sig = SIGNULL) OR (handler.long = SigIgn) THEN
     (* Signal wird ignoriert *)
     RETURN(0);
   ELSIF (sig <> SIGKILL) (* kann nicht maskiert werden *)
     AND (sig <> SIGSTOP) (* -""- *)
     AND (sig <> SIGCONT) (* -""- *)
     AND INlong(VAL(UNSIGNEDWORD,sig), SIGMASK)
   THEN
     (* Falls Signal in der Signalmaske gesetzt -> nur vermerken *)
     INCLlong(SIGPENDING, VAL(UNSIGNEDWORD,sig));
     RETURN(0);
   ELSE
     EXCLlong(SIGPENDING, VAL(UNSIGNEDWORD,sig));
     IF handler.long = SigDfl THEN
       (* Kein Handler installiert -> Defaultaktion *)
       IF (sig=SIGCONT) OR (sig=SIGCHLD) OR (sig=SIGWINCH) OR (sig=SIGFPE) THEN
         (* Defaultaktion: Signal ignorieren *)
         RETURN(0);
       ELSE
         (* Defaultaktion: Programm beenden *)
         Pterm(VAL(CARDINAL,sig) * 256); (* Signal in obere 8 Bit *)
       END;
     ELSE
       (* Installierten Signalhandler ausfuehren, Signalmaske solange
        * aendern.
        *)
       savemask := SIGMASK;
       SIGMASK  := UNIONlong(SIGMASK, SIGHANDLER[VAL(UNSIGNEDWORD,sig)].MASK);
       (* Zusaetzlich ist das behandelte Signal blockiert *)
       INCLlong(SIGMASK, VAL(UNSIGNEDWORD,sig));

       handler.proc(VAL(UNSIGNEDLONG,sig));

       (* Alte Signalmaske wiederherstellen *)
       SIGMASK := savemask;
       RETURN(0);
     END;
   END;
 END;
END kill;

(*---------------------------------------------------------------------------*)

PROCEDURE DeliverUnblocked;
(**)
VAR __REG__ unblocked : UNSIGNEDLONG;
    __REG__ sig       : UNSIGNEDWORD;
    __REG__ void      : INTEGER;

BEGIN
 unblocked := DIFFlong(SIGPENDING, SIGMASK);
 IF unblocked <> VAL(UNSIGNEDLONG,0) THEN
   FOR sig := 1 TO NSIG - 1 DO
     IF INlong(sig, unblocked) THEN
       void := kill(0, INT(sig));
     END;
   END;
 END;
END DeliverUnblocked;

(*---------------------------------------------------------------------------*)

PROCEDURE signal ((* EIN/ -- *)     sig     : int;
                  (* EIN/ -- *)     handler : SignalHandler;
                  (* -- /AUS *) VAR old     : SignalHandler ): int;

VAR func : ADDRESS;
    prev : ADDRESS;
    void : INTEGER;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   e.errno  := e.EINVAL;
   old.long := SigErr;
   RETURN(-1);
 END;

#if !((defined HM2) || (defined TDIM2))
 WITH handler DO WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
   old.long := HANDLER;
   HANDLER  := long;
   IF (long = SigDfl) OR (long = SigIgn) THEN
     func := CAST(ADDRESS,long);
   ELSE
     func := ADR(Wrapper);
   END;
 END; END;
#else
 func := CAST(ADDRESS,handler.long);
#endif

 IF Psignal(sig, func, prev) THEN
#if !((defined HM2) || (defined TDIM2))
   IF prev <> ADR(Wrapper) THEN
     old.long := CAST(SIGNEDLONG,prev);
   END;
#else
   old.long := CAST(SIGNEDLONG,prev);
#endif
   RETURN(0);
 ELSIF CAST(SIGNEDLONG,prev) <> VAL(SIGNEDLONG,e.eINVFN) THEN
   (* 'Psignal'-Aufruf wird unterstuetzt, anderer Fehler *)
#if !((defined HM2) || (defined TDIM2))
   (* Geaenderten Handler restaurieren *)
   SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER := old.long;
#endif
   e.errno  := INT(CAST(SIGNEDLONG,prev));
   old.long := SigErr;
   RETURN(-1);
 ELSE
   (* 'Psignal'-Aufruf wird nicht unterstuetzt *)
   WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
#if (defined HM2) || (defined TDIM2)
     old.long := HANDLER;
     HANDLER  := handler.long;
#endif
     MASK     := 0;
   END;
   (* Blockierung fuer behandeltes Signal aufheben und evtl. anstehendes
    * Signal ausfuehren.
    *)
   EXCLlong(SIGMASK, VAL(UNSIGNEDWORD,sig));
   DeliverUnblocked;

   RETURN(0);
 END;
END signal;

(*---------------------------------------------------------------------------*)

PROCEDURE sigaction ((* EIN/ -- *) sig  : int;
                     (* EIN/ -- *) act  : SigactionPtr;
                     (* EIN/ -- *) oact : SigactionPtr ): int;

VAR oldh : SIGNEDLONG;
    tmp  : SigactionRec;
    res  : INTEGER;
    mask : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   e.errno  := e.EINVAL;
   RETURN(-1);
 END;

#if !((defined HM2) || (defined TDIM2))
 WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
   oldh := HANDLER;
   IF act <> NULL THEN
     (* act^ nicht veraendern, nur eine Kopie *)
     tmp := act^;
     act := CAST(SigactionPtr,ADR(tmp));
     WITH tmp.saHandler DO
       HANDLER := long;
       IF (long <> SigDfl) AND (long <> SigIgn) THEN
         long := CAST(SIGNEDLONG,ADR(Wrapper));
       END;
     END;
   END;
 END;
#endif

 IF Psigaction(sig, act, oact, res) THEN
#if !((defined HM2) || (defined TDIM2))
   IF oact <> NULL THEN
     WITH oact^.saHandler DO
       IF CAST(ADDRESS,long) = ADR(Wrapper) THEN
         long := oldh;
       END;
     END;
   END;
#endif
   RETURN(0);
 ELSIF res <> e.eINVFN THEN
   (* 'Psigaction'-Aufruf wird unterstuetzt, anderer Fehler *)
#if !((defined HM2) || (defined TDIM2))
   (* Geaenderten Handler restaurieren *)
   SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER := oldh;
#endif
   e.errno := res;
   RETURN(-1);
 ELSE
   (* 'Psigaction'-Aufruf wird nicht unterstuetzt *)
   WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
     IF oact <> NULL THEN
       WITH oact^ DO
#if (defined HM2) || (defined TDIM2)
         saHandler.long := HANDLER;
#else
         saHandler.long := oldh;
#endif
         saFlags        := CAST(SaFlags,FLAGS);
         mask.siglong   := MASK;
         saMask         := mask.sigset;
       END;
     END;

     IF act <> NULL THEN
       WITH act^ DO
#if (defined HM2) || (defined TDIM2)
         HANDLER := saHandler.long;
#endif
         FLAGS   := CAST(WORDSET,saFlags);
         (* Innerhalb des Handlers zusaetzlich die angegebene Signalmaske
          * beruecksichtigen.
          *)
         mask.sigset := saMask;
         MASK        := mask.siglong;
       END;
     END;
   END; (* WITH SIGHANDLER *)

   (* Blockierung fuer behandeltes Signal aufheben und evtl. anstehendes
    * Signal ausfuehren.
    *)
   EXCLlong(SIGMASK, VAL(UNSIGNEDWORD,sig));
   DeliverUnblocked;

   RETURN(0);
 END;
END sigaction;

(*---------------------------------------------------------------------------*)

PROCEDURE raise ((* EIN/ -- *) sig : int ): int;

VAR pid : INTEGER;

BEGIN
 pid := Pgetpid();
 IF pid < 0 THEN
   (* 'Pgetpid'-Aufruf wird nicht unterstuetzt *)
   RETURN(kill(0, sig));
 ELSE
   RETURN(kill(pid, sig));
 END;
END raise;

(*---------------------------------------------------------------------------*)

PROCEDURE killpg ((* EIN/ -- *) pgrp : pidT;
                  (* EIN/ -- *) sig  : int ): int;

BEGIN
 IF pgrp < 0 THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 END;
 IF Pgetpgrp() <> e.eINVFN THEN
   (* Prozessgruppen werden unterstuetzt *)
   RETURN(kill(-pgrp, sig));
 ELSE
   RETURN(kill(pgrp, sig));
 END;
END killpg;

(*---------------------------------------------------------------------------*)

PROCEDURE sigprocmask ((* EIN/ -- *) how  : SigBlockType;
                       (* EIN/ -- *) set  : SigsetPtr;
                       (* EIN/ -- *) oset : SigsetPtr    ): int;

VAR old  : UNSIGNEDLONG;
    mask : LONGsigset;
    cast : LONGsigset;

BEGIN
 mask.siglong := SIGMASK;
 CASE how OF
   SigBlock:
     IF hasMask THEN
       IF set = NULL THEN
         mask.siglong := 0;
       ELSE
         mask.sigset  := set^;
       END;
       mask.siglong := Psigblock(mask.siglong);
       IF oset <> NULL THEN
         oset^ := mask.sigset;
       END;
     ELSE
       IF oset <> NULL THEN
         oset^ := mask.sigset;
       END;
       IF set <> NULL THEN
         cast.sigset := set^;
         SIGMASK := UNIONlong(SIGMASK, cast.siglong);
       END;
     END;
  |SigUnBlock:
     IF hasMask THEN
       mask.siglong := Psigblock(0);
     END;
     IF oset <> NULL THEN
       oset^ := mask.sigset;
     END;
     IF set <> NULL THEN
       cast.sigset  := set^;
       mask.siglong := DIFFlong(mask.siglong, cast.siglong);
       IF hasMask THEN
         old := Psigsetmask(mask.siglong);
       ELSE
         SIGMASK := mask.siglong;
         DeliverUnblocked;
       END;
     END;
 ELSE (* SigSetMask *)
     IF hasMask THEN
       IF set = NULL THEN
         mask.siglong := Psigblock(0);
       ELSE
         mask.sigset  := set^;
         mask.siglong := Psigsetmask(mask.siglong);
       END;
       IF oset <> NULL THEN
         oset^ := mask.sigset;
       END;
     ELSE
       IF oset <> NULL THEN
         oset^ := mask.sigset;
       END;
       IF set <> NULL THEN
         mask.sigset  := set^;
         SIGMASK := mask.siglong;
         DeliverUnblocked;
       END;
     END;
 END;
 RETURN(0);
END sigprocmask;

(*---------------------------------------------------------------------------*)

PROCEDURE sigpending ((* -- /AUS *) VAR set : sigsetT ): int;

VAR pending : LONGsigset;
    res     : SIGNEDLONG;

BEGIN
 res := Psigpending();
 IF res < VAL(SIGNEDLONG,0) THEN
   (* 'Psigpending'-Aufruf wird nicht unterstuetzt *)
   pending.siglong := SIGPENDING;
 ELSE
   pending.siglong := res;
 END;
 set := pending.sigset;
 RETURN(0);
END sigpending;

(*---------------------------------------------------------------------------*)

PROCEDURE pause;

VAR void : INTEGER;

BEGIN
 void    := Pause();
 e.errno := e.EINTR;
END pause;

(*---------------------------------------------------------------------------*)

PROCEDURE sigsuspend ((* EIN/ -- *) sigmask : sigsetT );

VAR mask : LONGsigset;
    old  : UNSIGNEDLONG;

BEGIN
 mask.sigset := sigmask;
 IF Psigpause(mask.siglong) < 0 THEN
   (* 'Psigpause'-Aufruf wird nicht unterstuetzt *)
   old     := SIGMASK;
   SIGMASK := mask.siglong;
   DeliverUnblocked;
   SIGMASK := old;
 END;
 e.errno := e.EINTR;
END sigsuspend;

(*---------------------------------------------------------------------------*)

PROCEDURE alarm ((* EIN/ -- *) sec : unsigned ): unsigned;

CONST MAXSEC = LC(2147483);

VAR secs : SIGNEDLONG;
    rem  : SIGNEDLONG;

BEGIN
 IF VAL(UNSIGNEDLONG,sec) > MAXSEC THEN
   (* sonst gibts Ueberlauf in MiNT *)
   sec := VAL(unsigned,MAXSEC);
 END;
 rem := Talarm(VAL(SIGNEDLONG,sec));
 IF rem < VAL(SIGNEDLONG,0) THEN
   (* 'Talarm'-Aufruf wird nicht unterstuetzt *)
   RETURN(0);
 ELSE
   RETURN(VAL(CARDINAL,rem));
 END;
END alarm;

(*---------------------------------------------------------------------------*)

PROCEDURE sleep ((* EIN/ -- *) seconds : unsigned ): unsigned;

CONST MAXSEC = LC(2147483);

VAR until      : UNSIGNEDLONG;
    voidB      : BOOLEAN;
    voidL      : UNSIGNEDLONG;
    voidA      : ADDRESS;
    alarmSecs  : SIGNEDLONG;
    secs       : SIGNEDLONG;
    remain     : SIGNEDLONG;
    oldHandler : ADDRESS;
    oldMask    : UNSIGNEDLONG;
    cast       : LONGsigset;
    res        : INTEGER;

BEGIN
 IF seconds = 0 THEN
   RETURN(0);
 END;
 IF VAL(UNSIGNEDLONG,seconds) > MAXSEC THEN
   (* sonst gibts Ueberlauf in MiNT *)
   seconds := VAL(CARDINAL,MAXSEC);
 END;
 secs := VAL(SIGNEDLONG,seconds);
 IF MiNT THEN
   (* Das folgende Algorithmus stammt aus der MiNTLib: *)
   alarmSecs := Talarm(0);
   oldMask   := Psigblock(0FFFFFFFFH);
   voidB     := Psignal(ORD(SIGALRM), ADR(Catch), oldHandler);
   voidL     := Psigblock(0FFFFFFFFH);
   until     := SysClock() DIV ClkTck + VAL(UNSIGNEDLONG,seconds);
   IF (alarmSecs > VAL(SIGNEDLONG,0)) AND (alarmSecs < secs) THEN
     voidL := Talarm(alarmSecs);
   ELSE
     voidL := Talarm(secs);
   END;
   EXCLlong(oldMask, VAL(UNSIGNEDWORD,SIGALRM));
   res       := Psigpause(oldMask);
   alarmSecs := Talarm(0);
   voidB     := Psignal(ORD(SIGALRM), ADR(Catch), voidA);
   res       := Syield();
   voidL     := Psigblock(0FFFFFFFFH);
   remain    := CAST(SIGNEDLONG,until) - CAST(SIGNEDLONG,SysClock() DIV ClkTck);
   IF alarmSecs > VAL(SIGNEDLONG,0) THEN
     DEC(alarmSecs, secs - remain);
     IF alarmSecs > VAL(SIGNEDLONG,0) THEN
       voidL := Talarm(alarmSecs);
     ELSE
       voidB := Pkill(Pgetpid(), ORD(SIGALRM), res);
     END;
   END;
   voidB := Psignal(ORD(SIGALRM), oldHandler, voidA);
   voidL := Psigsetmask(oldMask);
   res   := Syield();
   IF remain > VAL(SIGNEDLONG,0) THEN
     RETURN(VAL(CARDINAL,remain));
   ELSE
     RETURN(0);
   END;
 ELSE
   until := SysClock() + VAL(UNSIGNEDLONG,seconds) * ClkTck;
   REPEAT
   UNTIL SysClock() >= until;
   RETURN(0);
 END;
END sleep;

(*---------------------------------------------------------------------------*)

PROCEDURE usleep ((* EIN/ -- *) useconds : signedlong ): signedlong;

VAR until      : UNSIGNEDLONG;
    voidB      : BOOLEAN;
    voidL      : UNSIGNEDLONG;
    voidA      : ADDRESS;
    alarmMSecs : SIGNEDLONG;
    mSecs      : SIGNEDLONG;
    remain     : SIGNEDLONG;
    oldHandler : ADDRESS;
    oldMask    : UNSIGNEDLONG;
    cast       : LONGsigset;
    res        : INTEGER;

BEGIN
 mSecs := useconds DIV VAL(SIGNEDLONG,1000);
 IF mSecs <= VAL(SIGNEDLONG,0) THEN
   RETURN(0);
 END;
 (* 'useconds': Zeit in Millisekunden *)
 IF MiNT THEN
   (* Das folgende Algorithmus stammt aus der MiNTLib: *)
   alarmMSecs := Tmalarm(0);
   oldMask    := Psigblock(0FFFFFFFFH);
   voidB      := Psignal(ORD(SIGALRM), ADR(Catch), oldHandler);
   voidL      := Psigblock(0FFFFFFFFH);
   until      := SysClock() * VAL(UNSIGNEDLONG,5) + CAST(UNSIGNEDLONG,mSecs);
   IF (alarmMSecs > VAL(SIGNEDLONG,0)) AND (alarmMSecs < mSecs) THEN
     voidL := Tmalarm(alarmMSecs);
   ELSE
     voidL := Tmalarm(mSecs);
   END;
   EXCLlong(oldMask, VAL(UNSIGNEDWORD,SIGALRM));
   res        := Psigpause(oldMask);
   alarmMSecs := Tmalarm(0);
   voidB      := Psignal(ORD(SIGALRM), ADR(Catch), voidA);
   res        := Syield();
   voidL      := Psigblock(0FFFFFFFFH);
   remain     := CAST(SIGNEDLONG,until) - CAST(SIGNEDLONG,SysClock() * LC(5));
   IF alarmMSecs > VAL(SIGNEDLONG,0) THEN
     DEC(alarmMSecs, mSecs - remain);
     IF alarmMSecs > VAL(SIGNEDLONG,0) THEN
       voidL := Tmalarm(alarmMSecs);
     ELSE
       voidB := Pkill(Pgetpid(), ORD(SIGALRM), res);
     END;
   END;
   voidB := Psignal(ORD(SIGALRM), oldHandler, voidA);
   voidL := Psigsetmask(oldMask);
   res   := Syield();
   IF remain > VAL(SIGNEDLONG,0) THEN
     RETURN(VAL(UNSIGNEDLONG,remain) * VAL(UNSIGNEDLONG,1000));
   ELSE
     RETURN(0);
   END;
 ELSE
   until := SysClock() + VAL(UNSIGNEDLONG,mSecs) DIV LC(5);
   REPEAT
   UNTIL SysClock() >= until;
 END;
 RETURN(0);
END usleep;

(*---------------------------------------------------------------------------*)

PROCEDURE sigmask ((* EIN/ -- *) sig : int ): UNSIGNEDLONG;

VAR cast : LONGsigset;

BEGIN
 cast.siglong := 0H;
 INCLlong(cast.siglong, VAL(UNSIGNEDWORD,sig));
 RETURN(cast.siglong);
END sigmask;

(*---------------------------------------------------------------------------*)

PROCEDURE sigsetmask ((* EIN/ -- *) mask : UNSIGNEDLONG ): UNSIGNEDLONG;

VAR old : UNSIGNEDLONG;

BEGIN
 IF hasMask THEN
   RETURN(Psigsetmask(mask));
 ELSE
   (* 'Psigsetmask'-Aufruf wird nicht unterstuetzt *)
   old     := SIGMASK;
   SIGMASK := mask;
   DeliverUnblocked;
   RETURN(old);
 END;
END sigsetmask;

(*---------------------------------------------------------------------------*)

PROCEDURE sigblock ((* EIN/ -- *) mask : UNSIGNEDLONG ): UNSIGNEDLONG;

VAR old : UNSIGNEDLONG;

BEGIN
 IF hasMask THEN
   RETURN(Psigblock(mask));
 ELSE
   (* 'Psigblock'-Aufruf wird nicht unterstuetzt *)
   old     := SIGMASK;
   SIGMASK := UNIONlong(SIGMASK, mask);
   RETURN(old);
 END;
END sigblock;

(*---------------------------------------------------------------------------*)

PROCEDURE sigpause ((* EIN/ -- *) mask : UNSIGNEDLONG );
(**)
VAR old : UNSIGNEDLONG;

BEGIN
 IF Psigpause(mask) < 0 THEN
   (* 'Psigpause'-Aufruf wird nicht unterstuetzt *)
   old     := SIGMASK;
   SIGMASK := mask;
   DeliverUnblocked;
   SIGMASK := old;
 END;
 e.errno := e.EINTR;
END sigpause;

(*===========================================================================*)

CONST
  EINVFN = 0FFFFFFE0H; (* = e.EINVFN als (UN)SIGNEDLONG-Konstante *)

BEGIN (* sig *)
 MiNT    := MiNTVersion() > 0;
 hasMask := Psigblock(0) <> EINVFN;
 (* Wenn der 'Psigblock'-Aufruf unterstuetzt wird, kann dieses Bitmuster
  * nicht auftreten, weil SIGSTOP (Bit 17) und SIGCONT (Bit 19) nicht
  * blockiert werden/sein koennen. Es wird angenommen, dass das Ergebnis
  * des Tests auch fuer 'Psigsetmask' gilt.
  *)

#if !((defined HM2) || (defined TDIM2))
 WITH Wrapper DO
   code1 := 202F0004H; (* move.l  4(SP),D0 *)
#ifdef MM2
   code2 := 26C0H;     (* move.l  D0,(A3)+ *)
#else
   code2 := 2F00H;     (* move.l  D0,-(SP) *)
#endif
   code3 := 4EB9H;     (* jsr ... *)
   call  := dispatch;  (* ... dispatch *)
   code4 := 4E75H;     (* rts *)
 END;
#endif
 Catch := 4E75H; (* rts, ein sehr einfacher Signalhandler... *)
END sig.
