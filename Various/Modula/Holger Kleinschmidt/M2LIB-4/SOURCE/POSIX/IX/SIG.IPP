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
(* 28-Jun-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, WORDSETRANGE, WORDSET;

FROM OSCALLS IMPORT
(* PROC *) Pkill, Psigpause, Psigblock, Psigsetmask, Psigpending, Pause,
           Psignal, Psigaction, Talarm, Tmalarm, Fselect, Pgetpid,
           Syield, Pgetpgrp, Tsetitimer;

FROM types IMPORT
(* CONST*) ClkTck,
(* TYPE *) int, unsigned, unsignedlong, long, pidT, TimevalRec;

FROM er IMPORT
(* CONST*) EINVAL, eINVFN, ESRCH, EINTR,
(* VAR  *) errno;

FROM pLONGSET IMPORT
(* PROC *) LONGUNION, LONGDIFF, LONGINCL, LONGEXCL, LONGELEM;

FROM DosSystem IMPORT
(* CONST*) MINSIG, MAXSIG,
(* VAR  *) SIGMASK, SIGPENDING, SIGHANDLER,
(* PROC *) SysClock, MiNTVersion, ActPid, Exit;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)


CONST
  SigDflConst = LIC(0);
  SigIgnConst = LIC(1);

TYPE
  LONGsigset = RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: sigset  : sigsetT;
     |TRUE : siglong : UNSIGNEDLONG;
    END;
  END;

TYPE
  SigHandler = RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: proc : SignalHandler;
     |TRUE : long : SIGNEDLONG;
    END;
  END;

VAR
  MiNT    : BOOLEAN;
  hasMask : BOOLEAN; (* Werden 'Psigblock' und 'Psigsetmask' unterstuetzt ? *)

#define _wrap_handler !((defined HM2) || (defined TDIM2))

#if _wrap_handler
(* Der Signalhandler kann nicht direkt von MiNT aufgerufen werden, da die
 * Parameteruebergabe inkompatibel ist (statt des Aufrufers raeumt die
 * aufgerufene Prozedur die Parameter vom Stack); deshalb muss das
 * Stacklayout vor- und nachbereitet werden.
 *)
VAR
  Wrapper : RECORD
    code1 : UNSIGNEDLONG;
    code2 : UNSIGNEDWORD;
    code3 : UNSIGNEDWORD;
    call  : SignalHandler;
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
   errno := EINVAL;
   RETURN(-1);
 END;
 cast.sigset := set;
 LONGINCL(cast.siglong, VAL(UNSIGNEDWORD,sig));
 set := cast.sigset;
 RETURN(0);
END sigaddset;

(*---------------------------------------------------------------------------*)

PROCEDURE sigdelset ((* EIN/AUS *) VAR set : sigsetT;
                     (* EIN/ -- *)     sig : int     ): int;

VAR cast : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   errno := EINVAL;
   RETURN(-1);
 END;
 cast.sigset := set;
 LONGEXCL(cast.siglong, VAL(UNSIGNEDWORD,sig));
 set := cast.sigset;
 RETURN(0);
END sigdelset;

(*---------------------------------------------------------------------------*)

PROCEDURE sigismember ((* EIN/ -- *) set : sigsetT;
                       (* EIN/ -- *) sig : int     ): int;

VAR cast : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   errno := EINVAL;
   RETURN(-1);
 END;
 cast.sigset := set;
 RETURN(INT(LONGELEM(VAL(UNSIGNEDWORD,sig), cast.siglong)));
END sigismember;

(*---------------------------------------------------------------------------*)

PROCEDURE kill ((* EIN/ -- *) pid : pidT;
                (* EIN/ -- *) sig : int  ): int;

VAR handler  : SigHandler;
    res      : INTEGER;
    savemask : UNSIGNEDLONG;
    pending  : UNSIGNEDLONG;
    testall  : BOOLEAN;
    exit     : BOOLEAN;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   errno := EINVAL;
   RETURN(-1);
 END;

 IF Pkill(pid, sig, res) THEN
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* 'Pkill'-Aufruf wird unterstuetzt, anderer Fehler *)
   errno := res;
   RETURN(-1);
 END;

 IF (pid < 0) OR (pid > 0) & (pid # ActPid()) THEN
   errno := ESRCH;
   RETURN(-1);
 END;

 (* Keine Schleife, falls Signal ignoriert wird oder blockiert ist.
  * Eine Schleife wird nur ausgefuehrt, wenn ein Signalhandler
  * ausgefuehrt wurde, der das Programm nicht abgebrochen hat.
  * In diesem Handler koennte erneut "kill()" aufgerufen worden
  * sein mit einem Signal, das nur waehrend der Ausfuehrung des
  * Handlers blockiert war, nach dessen Beendigung aber nicht mehr.
  * In diesem Fall muss getestet werden, welche Signale evtl. jetzt
  * behandelt werden koennen/muessen (moeglicherweise koennen dort
  * wieder Signalhandler aufgerufen werden usw. Diese Endrekursion
  * ist hier in eine Schleife umgewandelt).
  *)
 exit := TRUE;

 (* Wenn ein Signalhandler ausgefuehrt wurde, muessen immer alle Signale
  * von neuem getestet werden. Dies ist jedoch nicht noetig, wenn ein
  * Signal lediglich ignoriert wurde.
  * Dieses Flag ist nur bei Ausfuehrung einer Schleife von Bedeutung,
  * also nur dann, wenn mindestens ein zurueckkehrender Handler
  * ausgefuehrt wurde.
  *)
 testall := FALSE;
 LOOP
   handler.long := SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER;
   IF (sig # SIGNULL) & (handler.long # SigIgnConst) THEN
     (* Signal wird nicht grundsaetzlich ignoriert *)
     IF  exit
       & (sig # SIGKILL) (* kann nicht blockiert werden *)
       & (sig # SIGSTOP) (* -""- *)
       & (sig # SIGCONT) (* -""- *)
       & LONGELEM(VAL(UNSIGNEDWORD,sig), SIGMASK) (* blockiert? *)
     THEN
       (* Falls Signal in der Signalmaske gesetzt -> nur vermerken.
        * Kann nicht bei Schleifenausfuehrung auftreten, da dabei
        * nur Signale behandelt werden (koennen), die in der normalen
        * Signalmaske, also der, die ausserhalb des Handlers gilt,
        * nicht blockiert sind.
        *)
       LONGINCL(SIGPENDING, VAL(UNSIGNEDWORD,sig));
     ELSE
       LONGEXCL(SIGPENDING, VAL(UNSIGNEDWORD,sig));

       IF handler.long = SigDflConst THEN
         (* Kein Handler installiert -> Defaultaktion *)
         IF  (sig # SIGCONT)
           & (sig # SIGCHLD)
           & (sig # SIGWINCH)
           & (sig # SIGFPE)
         THEN
           (* Defaultaktion: Programm beenden, ohne evtl. Modulterminierung *)
           Exit(VAL(CARDINAL,sig) * 256); (* Signal in obere 8 Bit *)
         END;
         (* Sonst Defaultaktion: Ignorieren *)
       ELSE

         (* Installierten Signalhandler ausfuehren, Signalmaske solange
          * aendern.
          *)
         savemask := SIGMASK;
         SIGMASK  := LONGUNION(SIGMASK, SIGHANDLER[VAL(UNSIGNEDWORD,sig)].MASK);
         (* Zusaetzlich ist das behandelte Signal blockiert *)
         LONGINCL(SIGMASK, VAL(UNSIGNEDWORD,sig));

         handler.proc(VAL(UNSIGNEDLONG,sig));

         (* Alte Signalmaske wiederherstellen *)
         SIGMASK := savemask;
         testall := TRUE;  (* Alle Signale erneut testen *)
         exit    := FALSE; (* Schleife nicht abbrechen *)
       END;
     END;
   END; (* IF (sig = SIGNULL)...*)

   IF exit THEN
     RETURN(0);
   END;
   exit := FALSE; (* Ab jetzt Schleife durchlaufen *)

   IF testall THEN
     (* Immer alle Signale testen, da innerhalb eines Handlers beliebige
      * gesetzt werden koennen. Wird beim ersten Mal auf jeden Fall
      * ausgefuehrt, da man hierher nur gelangt, wenn ein Handler
      * ausgefuehrt wurde, sonst wird die Prozedur bereits oben
      * wegen exit = TRUE verlassen.
      *)
     pending := LONGDIFF(SIGPENDING, SIGMASK);
     IF pending = VAL(UNSIGNEDLONG,0) THEN
       RETURN(0);
     END;
     testall := FALSE;
     sig     := 1;
   END;

   (* Erstes Signal feststellen, das durch "kill()" innerhalb des Handlers
    * gesendet, aber wegen der zeitweise geltenden Signalmaske nicht
    * bearbeitet wurde.
    *)
   WHILE (sig < NSIG) & ~LONGELEM(sig, pending) DO
     INC(sig);
   END;
   IF sig = NSIG THEN
     RETURN(0);
   END;
 END; (* LOOP *)
END kill;

(*---------------------------------------------------------------------------*)

PROCEDURE raise ((* EIN/ -- *) sig : int ): int;
BEGIN
 RETURN(kill(ActPid(), sig));
END raise;

(*---------------------------------------------------------------------------*)

PROCEDURE abort;

VAR sa   : SigactionRec;
    void : int;

BEGIN
 void := raise(SIGABRT);

 (* Signal war moeglicherweise blockiert, Blockade aufheben *)
 sigemptyset(sa.saMask);
 void := sigaddset(sa.saMask, SIGABRT);
 void := sigprocmask(SigUnblock, ADR(sa.saMask), NULL);

 (* Fuer das Signal gibt es moeglicherweise einen Handler, der zurueckkehrt,
  * oder das Signal wird ignoriert, nochmal mit Defaultaktion versuchen.
  *)
 sigemptyset(sa.saMask);
 sa.saHandler := SigDfl;
 sa.saFlags   := SaFlags{};
 void := sigaction(SIGABRT, ADR(sa), NULL);
 void := raise(SIGABRT);

 (* Hilft alles nichts, jetzt auf die brutale Tour... *)
 Exit(127);
END abort;

(*---------------------------------------------------------------------------*)

PROCEDURE DeliverUnblocked;

VAR __REG__ unblocked : UNSIGNEDLONG;
    __REG__ sig       : UNSIGNEDWORD;
    __REG__ void      : INTEGER;

BEGIN
 unblocked := LONGDIFF(SIGPENDING, SIGMASK);
 IF unblocked # VAL(UNSIGNEDLONG,0) THEN
   FOR sig := 1 TO NSIG - 1 DO
     IF LONGELEM(sig, unblocked) THEN
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
    oldh : SigHandler;
    void : INTEGER;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   errno := EINVAL;
   RETURN(-1);
 END;

#if _wrap_handler
 WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
   oldh.long := HANDLER; (* Alten Handler ermitteln *)
   HANDLER   := CAST(SIGNEDLONG,handler); (* Neuen Handler setzen *)
   IF   (CAST(SIGNEDLONG,handler) = SigDflConst)
     OR (CAST(SIGNEDLONG,handler) = SigIgnConst)
   THEN
     (* SIG_IGN und SIG_DFL koennen direkt uebergeben werden, da kein
      * Prozeduraufruf mit (inkompatibler) Parameteruebergabe stattfindet.
      *)
     func := CAST(ADDRESS,handler);
   ELSE
     (* Bei echten Handlern immer den Umweg ueber 'Wrapper' gehen und erst
      * dort nach dem Signal unterscheiden und den richtigen Handler aufrufen.
      *)
     func := ADR(Wrapper);
   END;
 END;
#else
 func := CAST(ADDRESS,handler);
#endif

 IF Psignal(sig, func, prev) THEN
#if _wrap_handler
   IF prev # ADR(Wrapper) THEN
     (* Den oben gesicherten alten Handler nur neu ermitteln, falls
      * als alter Handler nicht 'Wrapper' geliefert wurde. Kann
      * eigentlich nur bei bei SIG_IGN und SIG_DFL auftreten, da 'Psignal'
      * erfolgreich war; sicherheitshalber trotzdem abfangen.
      *)
     oldh.long := CAST(SIGNEDLONG,prev);
   END;
#else
   oldh.long := CAST(SIGNEDLONG,prev);
#endif
   old := oldh.proc;
   RETURN(0);
 ELSIF CAST(SIGNEDLONG,prev) # VAL(SIGNEDLONG,eINVFN) THEN
   (* 'Psignal'-Aufruf wird unterstuetzt, anderer Fehler *)
#if _wrap_handler
   (* Geaenderten Handler restaurieren *)
   SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER := oldh.long;
#endif
   errno := INT(CAST(SIGNEDLONG,prev));
   RETURN(-1);
 ELSE
   (* 'Psignal'-Aufruf wird nicht unterstuetzt *)
   WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
#if !(_wrap_handler)
     oldh.long := HANDLER;
     HANDLER   := CAST(SIGNEDLONG,handler);
#endif
     MASK      := 0;
   END;
   old := oldh.proc;

   (* Blockierung fuer behandeltes Signal aufheben und evtl. anstehendes
    * Signal ausfuehren.
    *)
   LONGEXCL(SIGMASK, VAL(UNSIGNEDWORD,sig));
   DeliverUnblocked;

   RETURN(0);
 END;
END signal;

(*---------------------------------------------------------------------------*)

PROCEDURE sigaction ((* EIN/ -- *) sig  : int;
                     (* EIN/ -- *) act  : SigactionPtr;
                     (* EIN/ -- *) oact : SigactionPtr ): int;

VAR oldh : SigHandler;
    tmp  : SigactionRec;
    res  : INTEGER;
    cast : SigHandler;
    mask : LONGsigset;

BEGIN
 IF (sig < 0) OR (sig >= NSIG) THEN
   errno := EINVAL;
   RETURN(-1);
 END;

#if _wrap_handler
 WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
   oldh.long := HANDLER; (* Alten Handler ermitteln *)
   IF act # NULL THEN
     (* Es soll ein neuer Handler gesetzt werden *)
     tmp := act^; (* act^ nicht veraendern, nur eine Kopie *)
     act := CAST(SigactionPtr,ADR(tmp));

     (* Neuen Handler setzen *)
     cast.proc := tmp.saHandler;
     HANDLER   := cast.long;
     IF (cast.long # SigDflConst) & (cast.long # SigIgnConst) THEN
       (* SIG_IGN und SIG_DFL koennen direkt uebergeben werden, da kein
        * Prozeduraufruf mit (inkompatibler) Parameteruebergabe stattfindet,
        * sonst den Umweg ueber 'Wrapper' gehen.
        *)
       cast.long     := CAST(SIGNEDLONG,ADR(Wrapper));
       tmp.saHandler := cast.proc;
     END;
   END;
 END;
#endif

 IF Psigaction(sig, act, oact, res) THEN
#if _wrap_handler
   IF oact # NULL THEN
     (* Der alte Handler soll ermittelt werden *)
     WITH oact^ DO
       IF CAST(ADDRESS,saHandler) = ADR(Wrapper) THEN
         (* Wenn der Umweg ueber 'Wrapper' benutzt wurde, den oben
          * ermittelten tatsaechlichen Handler speichern, sonst den
          * gelieferten Wert uebernehmen (SIG_IGN oder SIG_DFL).
          *)
         saHandler := oldh.proc;
       END;
     END;
   END;
#endif
   RETURN(0);
 ELSIF res # eINVFN THEN
   (* 'Psigaction'-Aufruf wird unterstuetzt, anderer Fehler *)
#if _wrap_handler
   (* Evtl. geaenderten Handler restaurieren *)
   SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER := oldh.long;
#endif
   errno := res;
   RETURN(-1);
 ELSE
   (* 'Psigaction'-Aufruf wird nicht unterstuetzt *)
   WITH SIGHANDLER[VAL(UNSIGNEDWORD,sig)] DO
     IF oact # NULL THEN
       WITH oact^ DO
#if !(_wrap_handler)
         oldh.long    := HANDLER;
#endif
         saHandler    := oldh.proc;
         saFlags      := CAST(SaFlags,FLAGS);
         mask.siglong := MASK;
         saMask       := mask.sigset;
       END;
     END;

     IF act # NULL THEN
       WITH act^ DO
#if !(_wrap_handler)
         HANDLER := CAST(SIGNEDLONG,saHandler);
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
   LONGEXCL(SIGMASK, VAL(UNSIGNEDWORD,sig));
   DeliverUnblocked;

   RETURN(0);
 END;
END sigaction;

(*---------------------------------------------------------------------------*)

PROCEDURE killpg ((* EIN/ -- *) pgrp : pidT;
                  (* EIN/ -- *) sig  : int ): int;

BEGIN
 IF pgrp < 0 THEN
   errno := EINVAL;
   RETURN(-1);
 END;
 IF Pgetpgrp() # eINVFN THEN
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
       IF oset # NULL THEN
         oset^ := mask.sigset;
       END;
     ELSE
       IF oset # NULL THEN
         oset^ := mask.sigset;
       END;
       IF set # NULL THEN
         cast.sigset := set^;
         SIGMASK := LONGUNION(SIGMASK, cast.siglong);
       END;
     END;
  |SigUnblock:
     IF hasMask THEN
       mask.siglong := Psigblock(0);
     END;
     IF oset # NULL THEN
       oset^ := mask.sigset;
     END;
     IF set # NULL THEN
       cast.sigset  := set^;
       mask.siglong := LONGDIFF(mask.siglong, cast.siglong);
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
       IF oset # NULL THEN
         oset^ := mask.sigset;
       END;
     ELSE
       IF oset # NULL THEN
         oset^ := mask.sigset;
       END;
       IF set # NULL THEN
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
 void  := Pause();
 errno := EINTR;
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
 errno := EINTR;
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

PROCEDURE timerclear ((* -- /AUS *) VAR tv : TimevalRec );
BEGIN
 WITH tv DO
   tvSec  := 0;
   tvUSec := 0;
 END;
END timerclear;

(*---------------------------------------------------------------------------*)

PROCEDURE timerisset ((* EIN/ -- *) tv : TimevalRec ): BOOLEAN;
BEGIN
 WITH tv DO
   RETURN((tvSec # VAL(long,0)) OR (tvUSec # VAL(long,0)));
 END;
END timerisset;

(*---------------------------------------------------------------------------*)

PROCEDURE timercmp ((* EIN/ -- *) tv1   : TimevalRec;
                    (* EIN/ -- *) tv2   : TimevalRec;
                    (* EIN/ -- *) tvcmp : TimevalCmp ): BOOLEAN;
BEGIN
 WITH tv1 DO
   CASE tvcmp OF
     tvlt:
       RETURN(   (tvSec < tv2.tvSec)
              OR (tvSec = tv2.tvSec) & (tvUSec < tv2.tvUSec));
    |tvle:
       RETURN(   (tvSec < tv2.tvSec)
              OR (tvSec = tv2.tvSec) & (tvUSec <= tv2.tvUSec));
    |tvgt:
       RETURN(   (tvSec > tv2.tvSec)
              OR (tvSec = tv2.tvSec) & (tvUSec > tv2.tvUSec));
    |tvge:
       RETURN(   (tvSec > tv2.tvSec)
              OR (tvSec = tv2.tvSec) & (tvUSec >= tv2.tvUSec));
    |tveq:
       RETURN((tvSec = tv2.tvSec) & (tvUSec = tv2.tvUSec));
    |tvne:
       RETURN((tvSec # tv2.tvSec) OR (tvUSec # tv2.tvUSec));
   END;
 END;
END timercmp;

(*---------------------------------------------------------------------------*)

PROCEDURE getitimer ((* EIN/ -- *)     which : TimerType;
                     (* -- /AUS *) VAR value : ItimervalRec ): int;

VAR oldival : SIGNEDLONG;
    oldval  : SIGNEDLONG;
    res     : INTEGER;

BEGIN
 IF Tsetitimer(ORD(which), NULL, NULL, ADR(oldival), ADR(oldval), res) THEN
   WITH value.itInterval DO
     tvSec  := oldival DIV VAL(SIGNEDLONG,1000);
     tvUSec := (oldival MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000)
   END;
   WITH value.itValue DO
     tvSec  := oldval DIV VAL(SIGNEDLONG,1000);
     tvUSec := (oldval MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000)
   END;
   RETURN(0);
 ELSE
   errno := res;
   RETURN(-1);
 END;
END getitimer;

(*---------------------------------------------------------------------------*)

PROCEDURE setitimer ((* EIN/ -- *) which  : TimerType;
                     (* EIN/ -- *) value  : ItimervalPtr;
                     (* EIN/ -- *) ovalue : ItimervalPtr ): int;

VAR oldival  : SIGNEDLONG;
    oldval   : SIGNEDLONG;
    ival     : SIGNEDLONG;
    val      : SIGNEDLONG;
    oldivalp : ADDRESS;
    oldvalp  : ADDRESS;
    ivalp    : ADDRESS;
    valp     : ADDRESS;
    res      : INTEGER;

BEGIN
 IF value = NULL THEN
   ivalp := NULL;
   valp  := NULL;
 ELSE
   WITH value^.itInterval DO
     ival := tvSec * VAL(long,1000) + tvUSec DIV VAL(long,1000);
     IF (ival = VAL(long,0)) & (tvUSec # VAL(long,0)) THEN
       (* Durch das Abrunden bei der Division ist  moeglicherweise
        * eine Null entstanden, die aber eine andere Bedeutung hat;
        * also stattdessen kleinstmoeglichen Wert nehmen.
        *)
       ival := 1;
     END;
   END;
   WITH value^.itValue DO
     val := tvSec * VAL(long,1000) + tvUSec DIV VAL(long,1000);
     IF (val = VAL(long,0)) & (tvUSec # VAL(long,0)) THEN
       val := 1;
     END;
   END;
   ivalp := ADR(ival);
   valp  := ADR(val);
 END;
 IF ovalue = NULL THEN
   oldivalp := NULL;
   oldvalp  := NULL;
 ELSE
   oldivalp := ADR(oldival);
   oldvalp  := ADR(oldval);
 END;
 IF Tsetitimer(ORD(which), ivalp, valp, oldivalp, oldvalp, res) THEN
   IF ovalue # NULL THEN
     WITH ovalue^.itInterval DO
       tvSec  := oldival DIV VAL(SIGNEDLONG,1000);
       tvUSec := (oldival MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000)
     END;
     WITH ovalue^.itValue DO
       tvSec  := oldval DIV VAL(SIGNEDLONG,1000);
       tvUSec := (oldval MOD VAL(SIGNEDLONG,1000)) * VAL(SIGNEDLONG,1000)
     END;
   END;
   RETURN(0);
 ELSE
   errno := res;
   RETURN(-1);
 END;
END setitimer;

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
   IF (alarmSecs > VAL(SIGNEDLONG,0)) & (alarmSecs < secs) THEN
     voidL := Talarm(alarmSecs);
   ELSE
     voidL := Talarm(secs);
   END;
   LONGEXCL(oldMask, VAL(UNSIGNEDWORD,SIGALRM));
   res    := Psigpause(oldMask);
   remain := Talarm(0);
   voidB  := Psignal(ORD(SIGALRM), ADR(Catch), voidA);
   res    := Syield();
   voidL  := Psigblock(0FFFFFFFFH);
   remain := CAST(SIGNEDLONG,until) - CAST(SIGNEDLONG,SysClock() DIV ClkTck);
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

PROCEDURE usleep ((* EIN/ -- *) useconds : long ): long;

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
   IF (alarmMSecs > VAL(SIGNEDLONG,0)) & (alarmMSecs < mSecs) THEN
     voidL := Tmalarm(alarmMSecs);
   ELSE
     voidL := Tmalarm(mSecs);
   END;
   LONGEXCL(oldMask, VAL(UNSIGNEDWORD,SIGALRM));
   res    := Psigpause(oldMask);
   remain := Tmalarm(0);
   voidB  := Psignal(ORD(SIGALRM), ADR(Catch), voidA);
   res    := Syield();
   voidL  := Psigblock(0FFFFFFFFH);
   remain := CAST(SIGNEDLONG,until) - CAST(SIGNEDLONG,SysClock() * LC(5));
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

PROCEDURE sigmask ((* EIN/ -- *) sig : int ): unsignedlong;

VAR cast : LONGsigset;

BEGIN
 cast.siglong := 0H;
 LONGINCL(cast.siglong, VAL(UNSIGNEDWORD,sig));
 RETURN(cast.siglong);
END sigmask;

(*---------------------------------------------------------------------------*)

PROCEDURE sigsetmask ((* EIN/ -- *) mask : unsignedlong ): unsignedlong;

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

PROCEDURE sigblock ((* EIN/ -- *) mask : unsignedlong ): unsignedlong;

VAR old : UNSIGNEDLONG;

BEGIN
 IF hasMask THEN
   RETURN(Psigblock(mask));
 ELSE
   (* 'Psigblock'-Aufruf wird nicht unterstuetzt *)
   old     := SIGMASK;
   SIGMASK := LONGUNION(SIGMASK, mask);
   RETURN(old);
 END;
END sigblock;

(*---------------------------------------------------------------------------*)

PROCEDURE sigpause ((* EIN/ -- *) mask : unsignedlong );

VAR old : UNSIGNEDLONG;

BEGIN
 IF Psigpause(mask) < 0 THEN
   (* 'Psigpause'-Aufruf wird nicht unterstuetzt *)
   old     := SIGMASK;
   SIGMASK := mask;
   DeliverUnblocked;
   SIGMASK := old;
 END;
 errno := EINTR;
END sigpause;

(*===========================================================================*)

#if _wrap_handler
(* Diese Prozedur wird fuer alle Signale aufgerufen; die Unterscheidung
 * nach Signalen wird erst hier vorgenommen und dann der richtige Handler
 * aufgerufen.
 *)
PROCEDURE dispatch ((* EIN/ -- *) sig : UNSIGNEDLONG );
VAR handler : SigHandler;
BEGIN
 handler.long := SIGHANDLER[VAL(UNSIGNEDWORD,sig)].HANDLER;
 handler.proc(sig);
END dispatch;
#endif

CONST
  EINVFN = 0FFFFFFE0H; (* = er.EINVFN als (UN)SIGNEDLONG-Konstante *)
#if !((defined LPRM2) || (defined SPCM2) || (defined MM2))
VAR cast : SigHandler;
#endif
BEGIN (* sig *)
 MiNT    := MiNTVersion() > 0;
 hasMask := Psigblock(0) # EINVFN;
 (* Wenn der 'Psigblock'-Aufruf unterstuetzt wird, kann dieses Bitmuster
  * nicht auftreten, weil SIGSTOP (Bit 17) und SIGCONT (Bit 19) nicht
  * blockiert werden/sein koennen. Es wird angenommen, dass das Ergebnis
  * des Tests auch fuer 'Psigsetmask' gilt.
  *)

#if _wrap_handler
 WITH Wrapper DO
   code1 := 202F0004H; (* move.l  4(SP),D0 *)
#ifdef MM2
   code2 := 26C0H;     (* move.l  D0,(A3)+ ; Kopie <signal> *)
#else
   code2 := 2F00H;     (* move.l  D0,-(SP) ; Kopie <signal> *)
#endif
   (* Die Sequenz: jsr dispatch; rts  kann nicht durch: jmp dispatch
    * ersetzt werden, da die aufgerufene Prozedur eine Ruecksprungadresse
    * zum Abraeumen braucht.
    *
    * Auf dem Stack stehen folgende Werte:
    *
    *             ___________________
    *   12(SP)-->| Original <signal> | wird von MiNT abgeraeumt
    *            |-------------------|
    *    8(SP)-->| Original RTN-Adr. | wird von 'Wrapper' abgeraeumt
    *            |-------------------|
    *    4(SP)-->| Kopie <signal>    | |
    *            |-------------------| | wird von 'dispatch' abgeraeumt
    *    0(SP)-->| neue RTN-Adr.     | |
    *            '-------------------'
    *)
   code3 := 4EB9H;     (* jsr ... ; neue RTN-Adr. *)
   call  := dispatch;  (* ... dispatch *)
   code4 := 4E75H;     (* rts ; Original-RTN-Adr. abraeumen*)
 END;
#endif
 Catch := 4E75H; (* rts, ein sehr einfacher Signalhandler... *)
#if !((defined LPRM2) || (defined SPCM2) || (defined MM2))
 cast.long := SigDflConst;
 SigDfl    := cast.proc;
 cast.long := SigIgnConst;
 SigIgn    := cast.proc;
#endif
END sig.
