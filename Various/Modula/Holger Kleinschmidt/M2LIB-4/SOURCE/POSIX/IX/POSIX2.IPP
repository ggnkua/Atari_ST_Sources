IMPLEMENTATION MODULE POSIX2;
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
(* Als Grundlage fuer "fnmatch()" und "getopt()" dienten die entsprechenden  *)
(* Quelltexte der GNULib (glibc).                                            *)
(* --------------------------------------------------------------------------*)
(* 10-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT


FROM SYSTEM IMPORT
(* PROC *) ADR, ADDRESS;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, UNSIGNEDLONG;
#ifdef MM2
FROM SYSTEM IMPORT CADR;
#endif

FROM types IMPORT
(* CONST*) EOS, XDIRSEP,
(* TYPE *) int, sizeT, StrRange, StrPtr, StrArray, ArrayRange;

FROM er IMPORT
(* CONST*) EINTR,
(* VAR  *) errno;

FROM blk IMPORT
(* PROC *) memalloc, memdealloc;

FROM ISOStrings IMPORT
(* TYPE *) String1,
(* PROC *) Length, FindNext;

FROM str IMPORT
(* PROC *) strcmp, AssignM2ToC;

FROM DosSystem IMPORT
(* TYPE *) Shell,
(* PROC *) CallShell, ShellInstalled, Exit;

FROM args IMPORT
(* PROC *) getenv;

FROM proc IMPORT
(* TYPE *) SpawnMode, WaitVal, WaitOptions,
(* PROC *) fork, execvp, spawnvp, waitpid;

FROM sig IMPORT
(* CONST*) SIGINT, SIGQUIT, SIGCHLD, SigIgn,
(* TYPE *) SignalHandler, sigsetT, SigsetPtr, SaFlag, SaFlags, SigactionPtr,
           SigactionRec, SigBlockType,
(* PROC *) sigaction, sigprocmask, sigemptyset, sigaddset;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  shcmd   : ARRAY [0..2] OF CHAR;
  sh      : ARRAY [0..7] OF CHAR;
  endopt  : ARRAY [0..2] OF CHAR;
  nextopt : StrPtr;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE fnmatch ((* EIN/ -- *) REF str   : ARRAY OF CHAR;
                   (* EIN/ -- *) REF pat   : ARRAY OF CHAR;
                   (* EIN/ -- *)     flags : FNMFlags      ): int;

VAR sLen, pLen : UNSIGNEDWORD;
    dot        : BOOLEAN;
    escape     : BOOLEAN;
    pathname   : BOOLEAN;

PROCEDURE match (SIDX : UNSIGNEDWORD;
                 PIDX : UNSIGNEDWORD ): BOOLEAN;

VAR         inverted : BOOLEAN;
            cmin     : CHAR;
            cmax     : CHAR;
    __REG__ cs       : CHAR;
    __REG__ sidx     : UNSIGNEDWORD;
    __REG__ pidx     : UNSIGNEDWORD;
    __REG__ pend     : UNSIGNEDWORD;

BEGIN (* match *)
 sidx := SIDX;
 pidx := PIDX;

 WHILE pidx < pLen DO

   IF sidx < sLen THEN
     cs := str[sidx];
   ELSE
     cs := EOS;
   END;

   CASE pat[pidx] OF
     '[': IF   (cs = EOS)
            OR pathname & (cs = XDIRSEP)
            OR dot      & (cs = '.')
                        & (   (sidx = 0)
                           OR pathname & (str[sidx-1] = XDIRSEP))
          THEN
            (* Wenn der String kein Zeichen mehr enthaelt, oder ein
             * Pfadtrenner nicht ``gematched'' werden darf, oder ein Dateiname
             * mit fuehrendem Punkt nicht ``gematched'' werden darf (entweder
             * am Stringanfang oder direkt nach einem Pfadtrenner), schlaegt
             * der Vergleich fehl.
             *)
            RETURN(FALSE);
          END;

          INC(pidx);
          IF (pidx < pLen) & (pat[pidx] = INVERTCHAR) THEN
            inverted := TRUE;
            INC(pidx);
          ELSE
            inverted := FALSE;
          END;
          pend := pidx;

          (* Ein ']' an erster Stelle, evtl. hinter einem '!', beendet nicht
           * die Menge, sondern steht fuer das zu ``matchende'' Zeichen,
           * hat also keine Spezialbedeutung. Deswegen wird das erste
           * Zeichen der Menge uebersprungen.
           * Wenn das Escapezeichen erlaubt ist, bedeutet "...\]..."
           * nicht das Ende der Menge, sondern steht fuer ein zu
           * ``matchendes'' ']'.
           *)
          REPEAT
            INC(pend);
          UNTIL (pend >= pLen) OR  (pat[pend] = ']')
                                 & (~escape OR (pat[pend-1] # ESCAPECHAR));

          IF pend >= pLen THEN
            (* Syntaxfehler: Menge nicht korrekt abgeschlossen *)
            RETURN(FALSE);
          END;

          (* Durch das Testen auf korrekten Abschluss mit ']' koennen
           * in der nachfolgenden Schleife einige Tests auf zu grosses
           * 'pidx' entfallen.
           *)
          LOOP
            IF escape & (pat[pidx] = ESCAPECHAR) THEN
              INC(pidx);
            END;

            cmin := pat[pidx];
            cmax := cmin;
            INC(pidx);

            IF (pat[pidx] = '-') & (pidx + 1 < pend) THEN
              (* Ein Bereich ist nur vorhanden, falls die Obergrenze
               * nicht ']' ist; in diesem Fall steht '-' fuer ein
               * Einzelzeichen, und die Klammer beendet die Menge.
               *)
              INC(pidx);
              IF escape & (pat[pidx] = ESCAPECHAR) THEN
                INC(pidx);
              END;
              cmax := pat[pidx];
              INC(pidx);
            END;

            IF (cmin <= cs) & (cs <= cmax) THEN
              (* --> MATCH *)
              IF inverted THEN
                RETURN(FALSE);
              ELSE
                pidx := pend;
                EXIT;
              END;
            ELSIF pidx = pend THEN
              (* --> NO MATCH *)
              IF inverted THEN
                EXIT;
              ELSE
                RETURN(FALSE);
              END;
            END; (* IF cmin <= cs ... *)
          END; (* LOOP *)
          INC(sidx);
          INC(pidx);

    |'*': REPEAT
            INC(pidx);
          UNTIL (pidx = pLen) OR (pat[pidx] # '*');
          DEC(pidx);

          (* Mehrere '*' hintereinander sind aequivalent zu einem einzelnen.
           * Bis zum letzten '*' ueberlesen.
           *)

          IF pathname & (cs = XDIRSEP) THEN
            (* Wenn '*' auf einen Pfadtrenner trifft, ``matched'' es nur
             * die leere Zeichenkette, d.h. der Rest des Musters muss
             * ohne '*' auf den augenblicklichen String passen.
             *)
            INC(pidx);
          ELSIF dot & (cs = '.')
                    & (   (sidx = 0)
                       OR pathname & (str[sidx-1] = XDIRSEP))
          THEN
            RETURN(FALSE);
          ELSE

            (* Das Muster hinter dem '*' wird mit jedem moeglichen Reststring
             * verglichen. Das muss rekursiv geschehen, da das Restmuster
             * wiederum '*' enthalten kann (und auch jedesmal wieder auf
             * '.' und '/' geachtet werden muss).
             * Es werden soviele Rekursionsebenen aufgebaut, wie der Reststring
             * noch lang ist. Beim rekursiven Aufstieg wird dann der Vergleich
             * durchgefuehrt, wobei in jeder Ebene der Reststring mit dem Muster
             * hinter dem '*' verglichen wird.
             *
             * Der ``schlimmste'' Fall, also der mit den meisten rekursiven
             * Aufrufen, ist ein Muster folgender Art:
             *
             *   pat = "*?*?*?*?*?..."
             *
             * und ein String mit mindestens soviel Zeichen, wie das Muster
             * '*' hat.
             * Die Zahl an Rekursionsaufrufen berechnet sich in diesem Fall aus:
             *
             *   rcalls = 2^stars - 1 + (sLen - stars)
             *
             * wobei 'stars' die Anzahl der '*' im Muster ist und sich aus
             *
             *   stars = pLen DIV 2
             *
             * ergibt.
             * Der Aufwand ist also exponentiell, falls mehrere '*' im Muster
             * vorkommen!
             *
             * Die ``schlimmste'' Rekursionstiefe ist dagegen nicht ganz so
             * wild, sie entspricht der Stringlaenge:
             *
             *   rdepth = sLen
             *
             * Beispiel: str = "xxxx" (sLen =4), pat = "*?*?*?*?" (stars=4)
             *
             * Graph der Aufrufe; die Waagerechte kennzeichnet die Rekursions-
             * ebene, die Zahlen bedeuten die Anzahl der Aufrufe auf der
             * jeweiligen Ebene (haengen von der jeweiligen Laenge des Rest-
             * strings ab):
             *
             *         Ebene 0:  Aufruf durch 'fnmatch()'
             *                        |
             *                        V
             *         Ebene 1:  -----4--------
             *                      / | \
             *                     /  |  \
             *                   -1---2---3----
             *            .           /  / \
             *            .          /  /   \
             *            .      ---1--1-----2-
             *                              /
             *                             /
             *         Ebene 4:  ---------1----
             *
             * insgesamt 15 rekursive Aufrufe.
             *
             * Die Strings, dargestellt zum Zeitpunkt des rekursiven Aufrufs:
             *
             *   pat  = "*?*?*?"  "*?*?"       "*?*?"   "*?*?"
             *
             *   str  =   "123"  .............  "23"  ..  "3"
             *              |                    |         |
             *             "23"  .. "3"         "3"        ""
             *              |        |           |
             *             "3"       ""          ""
             *              |
             *              ""
             *
             * Falls der String laenger ist, wird die Rekursionsebene erst
             * solange linear erhoeht, bis der Reststring genauso lang wie die
             * Anzahl der '*', dann spannt sich der Baum genauso auf.
             *)
            IF (cs # EOS) & match(sidx+1, pidx) THEN
              RETURN(TRUE);
            END;
            INC(pidx);
          END;

    |'?': IF   (cs = EOS)
            OR pathname & (cs = XDIRSEP)
            OR dot      & (cs = '.')
                        & (   (sidx = 0)
                           OR pathname & (str[sidx-1] = XDIRSEP))
          THEN
            RETURN(FALSE);
          END;
          INC(sidx);
          INC(pidx);

    |ESCAPECHAR:
          IF escape THEN
            INC(pidx);
          END;
          IF pidx = pLen THEN
            RETURN(cs = EOS);
          ELSIF pat[pidx] # cs THEN
            RETURN(FALSE);
          END;
          INC(sidx);
          INC(pidx);

     ELSE
          IF pat[pidx] # cs THEN
            RETURN(FALSE);
          END;
          INC(sidx);
          INC(pidx);
   END; (* CASE *)
 END; (* WHILE *)

 (* Wenn das Muster beendet ist, muss auch der String zuende sein.*)
 RETURN(sidx = sLen);
END match;

BEGIN (* fnmatch *)
 escape   := ~(FNMNoEscape IN flags);
 pathname := FNMPathname IN flags;
 dot      := FNMPeriod IN flags;
 sLen     := VAL(UNSIGNEDWORD,Length(str));
 pLen     := VAL(UNSIGNEDWORD,Length(pat));

 IF match(0, 0) THEN
   RETURN(0);
 ELSE
   RETURN(FNMNoMatch);
 END;
END fnmatch;

(*----------------------------------------------------------------------------*)

PROCEDURE system ((* EIN/ -- *) REF cmd : ARRAY OF CHAR ): int;

VAR argv    : ARRAY [0..3] OF StrPtr;
    shell   : StrPtr;
    void    : INTEGER;
    pid     : INTEGER;
    sa      : SigactionRec;
    savintr : SigactionRec;
    savquit : SigactionRec;
    savblock: sigsetT;
    state   : WaitVal;
    msize   : sizeT;
    stack   : ADDRESS;
    cmd0    : StrPtr;

BEGIN
 (* <cmd> wird mit einem Nullbyte abgeschlossen *)
 msize := VAL(sizeT,Length(cmd) + 1);
 memalloc(msize, stack, cmd0);
 AssignM2ToC(cmd, VAL(StrRange,msize), cmd0);

 (* Kommandointerpreter bestimmen *)
 shell := getenv("SHELL");
 IF shell = NULL THEN
   (* Die Standardshell ("/bin/sh[.*]") verwenden *)
   shell := ADR(sh);
 END;

 argv[0] := shell;
 argv[1] := ADR(shcmd);
 argv[2] := cmd0;
 argv[3] := NULL;

 (* Zuerst mit der bei POSIX.2 beschriebenen Methode probieren: *)

 (* SIGINT und SIGQUIT im Elternprozess ignorieren, waehrend auf den
  * Kindprozess gewartet wird.
  *)
 sa.saHandler := SigIgn;
 sa.saFlags   := SaFlags{};
 sigemptyset(sa.saMask);
 void := sigaction(SIGINT, ADR(sa), ADR(savintr));
 void := sigaction(SIGQUIT, ADR(sa), ADR(savquit));

 (* SIGCHLD blockieren *)
 void := sigaddset(sa.saMask, SIGCHLD);
 void := sigprocmask(SigBlock, ADR(sa.saMask), ADR(savblock));

 pid := fork();
 IF pid = 0 THEN (* child *)
   (* Der Kindprozess soll SIGINT und SIGQUIT nicht ignorieren *)
   void := sigaction(SIGINT, ADR(savintr), NULL);
   void := sigaction(SIGQUIT, ADR(savquit), NULL);
   void := sigprocmask(SigSetMask, ADR(savblock), NULL);

   void := execvp(shell, ADR(argv));
   (* Wenn "execvp()" zurueckkehrt, ist ein Fehler aufgetreten *)
   Exit(127);
 END;

 IF pid = -1 THEN (* parent *)
   state := CAST(WaitVal,VAL(SIGNEDWORD,-1));
 ELSE (* parent *)
   LOOP
     IF waitpid(pid, state, WaitOptions{}) >= 0 THEN
       EXIT;
     ELSIF errno # EINTR THEN
       state := CAST(WaitVal,VAL(SIGNEDWORD,-1));
       EXIT;
     END;
   END;
 END;
 (* Signale nicht mehr ignorieren bzw. blockieren *)
 void := sigaction(SIGINT, ADR(savintr), NULL);
 void := sigaction(SIGQUIT, ADR(savquit), NULL);
 void := sigprocmask(SigSetMask, ADR(savblock), NULL);

 IF pid = -1 THEN
   (* Wenn "fork()" fehlgeschlagen ist, mit normalem 'Pexec(0,...)'
    * versuchen.
    *)
   state := CAST(WaitVal,VAL(SIGNEDWORD,spawnvp(pWAIT, shell, ADR(argv))));
   IF errno # 0 THEN
     (* "spawn*()" setzt 'errno' auf Null, falls alles OK war!
      * Als letzte Moeglichkeit "CallShell()" probieren.
      *)
     IF ShellInstalled() < NoShell THEN
       state := CAST(WaitVal,VAL(SIGNEDWORD,CallShell(cmd0)));
     END;
   END;
 END;
 memdealloc(stack);
 RETURN(INT(CAST(SIGNEDWORD,state)));
END system;

(*----------------------------------------------------------------------------*)

PROCEDURE getopt ((* EIN/ -- *)     argc   : int;
                  (* EIN/ -- *)     argv   : StrArray;
                  (* EIN/ -- *) REF optstr : ARRAY OF CHAR ): int;

VAR __REG__ ch     : CHAR;
    __REG__ optidx : ArrayRange;
            s1     : String1;
            found  : BOOLEAN;
            pos    : CARDINAL;

BEGIN
 optarg := NULL;
 optidx := VAL(ArrayRange,optind);

 IF (nextopt = NULL) OR (nextopt^[0] = 0C) THEN
   (* Zum Beginn des naechsten Arguments *)

   IF   (argv^[optidx] = NULL)
     OR (argv^[optidx]^[0] # '-')
     OR (argv^[optidx]^[1] = 0C)
   THEN
     (* Wenn alle Argumente durchsucht sind oder ein Argument gefunden
      * wurde, das keine Option sein kann, Ende der Optionen mitteilen.
      *)
     RETURN(-1);
   END;

   IF strcmp(argv^[optidx], ADR(endopt)) = 0 THEN
     (* "--" kennzeichnet das Ende der Optionen und wird ueberlesen *)
     INC(optind);
     RETURN(-1);
   END;

   (* Hinter dem Options-'-' mit der Analyse beginnen *)
   nextopt := ADR(argv^[optidx]^[1]);
 END;

 ch      := nextopt^[0];      (* Option feststellen *)
 nextopt := ADR(nextopt^[1]); (* Falls hinter der Option noch was kommt *)

 IF nextopt^[0] = 0C THEN
   (* Ende des Optionsarguments, danach mit dem naechsten Argument weiter *)
   INC(optidx);
 END;

 s1[0] := ch;
 FindNext(s1, optstr, 0, found, pos);
 IF ~found OR (ch = ':') THEN
   (* Option ist nicht bekannt oder beginnt mit ':', Fehler *)
   optopt := INT(ch);
   optind := INT(optidx);
   RETURN(INT('?'));
 END;

 IF (pos < VAL(CARDINAL,HIGH(optstr))) & (optstr[VAL(StrRange,pos)+1] = ':') THEN
   (* Option hat ein Argument *)
   IF nextopt^[0] # 0C THEN
     (* Argument steht direkt hinter der Option, beim naechsten Mal mit dem
      * dem naechsten Kommandozeilenargument weiter.
      *)
     optarg := nextopt;
     INC(optidx);
   ELSIF INT(optidx) >= argc THEN
     (* Argument fehlt, Fehler *)
     optopt := INT(ch);
     IF optstr[0] = ':' THEN
       (* Fehlendes Argument soll gegenueber anderen Fehlern hervorgehoben
        * werden.
        *)
       ch := ':';
     ELSE
       ch := '?';
     END;
   ELSE (* nextopt^[0] = 0C *)
     (* Argument ist das naechste Kommandozeilenargument, dieses wird beim
      * naechsten Mal uebersprungen.
      *)
     optarg := argv^[optidx];
     INC(optidx);
   END;
   nextopt := NULL; (* Option fertig bearbeitet *)
 END;
 optind := INT(optidx);

 (* Erkannte Option oder Zeichen fuer fehlendes Argument zurueckliefern *)
 RETURN(INT(ch));
END getopt;

BEGIN (* POSIX2 *)
 (* fuer "system()" *)
 shcmd := "-c";
 sh    := "/bin/sh";

 (* fuer "getopt()" *)
 optind  := 1;
 endopt  := "--";
 nextopt := NULL;
END POSIX2.
