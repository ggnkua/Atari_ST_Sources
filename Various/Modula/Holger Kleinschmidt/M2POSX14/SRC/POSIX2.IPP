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
(* "fnmatch()":                                                              *)
(* Als Grundlage dienten die 'C'-Dateien 'glob.c' der GNU-Shell BASH und     *)
(* 'fnmatch.c/h' der GNU-Fileutils.                                          *)
(*---------------------------------------------------------------------------*)
(* 29-Mai-94, Holger Kleinschmidt                                            *)
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
(* TYPE *) int, sizeT, StrRange, StrPtr, StrArray;

IMPORT e;

FROM MEMBLK IMPORT
(* PROC *) memalloc, memdealloc;

FROM pSTRING IMPORT
(* PROC *) SLEN;

FROM cstr IMPORT
(* PROC *) strncpy;

FROM DosSystem IMPORT
(* TYPE *) Shell,
(* PROC *) CallShell, ShellInstalled;

FROM cmdline IMPORT
(* PROC *) GetEnvVar;

FROM file IMPORT
(* CONST*) fOK,
(* TYPE *) AccessMode,
(* PROC *) access;

FROM proc IMPORT
(* TYPE *) SpawnMode, WaitVal, WaitOption,
(* PROC *) fork, execvp, spawnvp, waitpid, Exit;

FROM sig IMPORT
(* CONST*) SIGINT, SIGQUIT, SIGCHLD, SigIgn,
(* TYPE *) SignalHandler, sigsetT, SigsetPtr, SaFlag, SaFlags, SigactionPtr,
           SigactionRec, SigBlockType,
(* PROC *) sigaction, sigprocmask, sigemptyset, sigaddset;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  shcmd : ARRAY [0..2] OF CHAR;

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
     '[': IF    (cs = EOS)
             OR pathname AND (cs = XDIRSEP)
             OR dot      AND (cs = '.')
                         AND (   (sidx = 0)
                              OR pathname AND (str[sidx-1] = XDIRSEP))
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
          IF (pidx < pLen) AND (pat[pidx] = INVERTCHAR) THEN
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
          UNTIL (pend >= pLen) OR     (pat[pend] = ']')
                                  AND (   NOT escape
                                       OR (pat[pend-1] <> ESCAPECHAR));

          IF pend >= pLen THEN
            (* Syntaxfehler: Menge nicht korrekt abgeschlossen *)
            RETURN(FALSE);
          END;

          (* Durch das Testen auf korrekten Abschluss mit ']' koennen
           * in der nachfolgenden Schleife einige Tests auf zu grosses
           * 'pidx' entfallen.
           *)
          LOOP
            IF escape AND (pat[pidx] = ESCAPECHAR) THEN
              INC(pidx);
            END;

            cmin := pat[pidx];
            cmax := cmin;
            INC(pidx);

            IF (pat[pidx] = '-') AND (pidx + 1 < pend) THEN
              (* Ein Bereich ist nur vorhanden, falls die Obergrenze
               * nicht ']' ist; in diesem Fall steht '-' fuer ein
               * Einzelzeichen, und die Klammer beendet die Menge.
               *)
              INC(pidx);
              IF escape AND (pat[pidx] = ESCAPECHAR) THEN
                INC(pidx);
              END;
              cmax := pat[pidx];
              INC(pidx);
            END;

            IF (cmin <= cs) AND (cs <= cmax) THEN
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
          UNTIL (pidx = pLen) OR (pat[pidx] <> '*');
          DEC(pidx);

          (* Mehrere '*' hintereinander sind aequivalent zu einem einzelnen.
           * Bis zum letzten '*' ueberlesen.
           *)

          IF pathname AND (cs = XDIRSEP) THEN
            (* Wenn '*' auf einen Pfadtrenner trifft, ``matched'' es nur
             * die leere Zeichenkette, d.h. der Rest des Musters muss
             * ohne '*' auf den augenblicklichen String passen.
             *)
            INC(pidx);
          ELSIF dot AND (cs = '.')
                    AND (   (sidx = 0)
                         OR pathname AND (str[sidx-1] = XDIRSEP))
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
            IF (cs <> EOS) AND match(sidx+1, pidx) THEN
              RETURN(TRUE);
            END;
            INC(pidx);
          END;

    |'?': IF    (cs = EOS)
             OR pathname AND (cs = XDIRSEP)
             OR dot      AND (cs = '.')
                         AND (   (sidx = 0)
                              OR pathname AND (str[sidx-1] = XDIRSEP))
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
          ELSIF pat[pidx] <> cs THEN
            RETURN(FALSE);
          END;
          INC(sidx);
          INC(pidx);

     ELSE
          IF pat[pidx] <> cs THEN
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
 escape   := NOT (FNMNoEscape IN flags);
 pathname := FNMPathname IN flags;
 dot      := FNMPeriod IN flags;
 sLen     := VAL(UNSIGNEDWORD,SLEN(str));
 pLen     := VAL(UNSIGNEDWORD,SLEN(pat));

 IF match(0, 0) THEN
   RETURN(0);
 ELSE
   RETURN(FNMNoMatch);
 END;
END fnmatch;

(*----------------------------------------------------------------------------*)

PROCEDURE system ((* EIN/ -- *) REF cmd : ARRAY OF CHAR ): int;

VAR argv    : ARRAY [0..3] OF StrPtr;
    shell   : ARRAY [0..127] OF CHAR;
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
 msize := VAL(sizeT,SLEN(cmd) + 1);
 memalloc(msize, stack, cmd0);
 strncpy(cmd0, REFADR(cmd), msize);

 (* Kommandointerpreter suchen *)
 IF NOT GetEnvVar("SHELL", shell) THEN
   IF access("/bin/sh", fOK) = 0 THEN
     shell := "/bin/sh";
   ELSIF access("/bin/sh.ttp", fOK) = 0 THEN
     shell := "/bin/sh.ttp";
   ELSE
     (* Kein Kommandointerpreter gefunden *)
     memdealloc(stack);
     e.errno := e.ENOENT;
     RETURN(-1);
   END;
 END;

 argv[0] := ADR(shell);
 argv[1] := ADR(shcmd);
 argv[2] := cmd0;
 argv[3] := NULL;

 (* Zuerst mit der bei POSIX.2 beschriebenen Methode probieren: *)

 (* SIGINT und SIGQUIT im Elternprozess ignorieren, waehrend auf den
  * Kindprozess gewartet wird.
  *)
 sa.saHandler.long := SigIgn;
 sa.saFlags        := SaFlags{};
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
     IF waitpid(pid, state, WaitOption{}) >= 0 THEN
       EXIT;
     ELSIF e.errno <> e.EINTR THEN
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
 END;
 memdealloc(stack);
 RETURN(INT(CAST(SIGNEDWORD,state)));
END system;

BEGIN (* POSIX2 *)
 shcmd := "-c";
END POSIX2.
