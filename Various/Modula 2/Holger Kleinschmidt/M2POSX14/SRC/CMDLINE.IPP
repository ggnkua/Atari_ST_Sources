IMPLEMENTATION MODULE cmdline;
__IMP_SWITCHES__
__DRIVER__ (* ARGV muss auf jeden Fall aus dem Environment entfernt werden *)
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
(* 05-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

/* Folgende Zeile in 'C'-Kommentarklammern setzen, falls der Programmname
 * nicht ueber "shel_read()" ermittelt werden soll, wenn kein ARGV-Verfahren
 * benutzt wurde.
 * Da das Ermitteln des Programmnamens auf diese Weise fuer TOS-Programme
 * nicht ganz ``sauber'' ist, sollten die Kommentarklammern normalerweise
 * gesetzt sein!
 * Die GEM-Aufrufe sind fuer die GEM-Bibliothek ``crystal'' von
 * Ulrich Kaiser ausgelegt, wer eine andere GEM-Bibliothek verwendet, muss
 * die Aufrufe entsprechend anpassen.
 */

/*
#define USE_AES_FOR_ARGV0
*/

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG;

FROM OSCALLS IMPORT
(* PROC *) Fsetdta, Malloc;

FROM ctype IMPORT
(* PROC *) isspace, isdigit, tocard;

FROM DosSystem IMPORT
(* TYPE *) BasePtr, BasePage, CmdLine,
(* VAR  *) BASEP;

FROM types IMPORT
(* CONST*) EOS,
(* TYPE *) StrRange, ArrayRange, StrPtr, StrArray;

FROM cstr IMPORT
(* PROC *) AssignCToM2;

#ifdef USE_AES_FOR_ARGV0
FROM pSTRING IMPORT EQUALN;

FROM AES IMPORT
(* PROC *) Version;

FROM ApplMgr IMPORT
(* PROC *) ApplInit, ApplExit;

FROM ShelMgr IMPORT
(* PROC *) ShelRead;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  dta     : ARRAY [0..43] OF CHAR; (* Platz fuer Default-DTA *)
  ARGV    : StrArray;  (* -> Feld von Zeigern auf die Kommando-Argumente *)
  ENVP    : StrArray;  (* -> Feld von Zeigern auf die Environment-Variablen *)
  ARGC    : CARDINAL;  (* Anzahl der Kommando-Argumente *)
  prgName : CmdLine;   (* Name des Programms, falls feststellbar *)
  cmdBuf  : CmdLine;   (* Arbeitskopie der Basepage-Kommandozeile *)
  null    : StrPtr;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE main ((* -- /AUS *) VAR argc : ArrayRange;
                (* -- /AUS *) VAR argv : StrArray   );
(*T*)
BEGIN
 argc := ARGC;
 argv := ARGV;
END main;

(*---------------------------------------------------------------------------*)

PROCEDURE getenv ((* EIN/ -- *) REF var : ARRAY OF CHAR ): StrPtr;
(*T*)
VAR __REG__ varIdx : StrRange;
    __REG__ varPtr : StrPtr;
            val    : ArrayRange;

BEGIN
 val    := 0;
 varPtr := ENVP^[0];
 WHILE varPtr <> NULL DO
   varIdx := 0;
   WHILE (VAL(CARDINAL,varIdx) <= VAL(CARDINAL,HIGH(var)))
     AND (var[varIdx] <> 0C)
     AND (var[varIdx] = varPtr^[varIdx])
   DO
     INC(varIdx);
   END;

   IF (   (VAL(CARDINAL,varIdx) > VAL(CARDINAL,HIGH(var)))
       OR (var[varIdx]     = 0C))
      AND (varPtr^[varIdx] = '=')
   THEN
     RETURN(CAST(StrPtr,ADR(varPtr^[varIdx+1])));
   END;

   INC(val);
   varPtr := ENVP^[val];
 END;

 RETURN(NULL);
END getenv;

(*---------------------------------------------------------------------------*)

PROCEDURE ArgCount ( ): CARDINAL;
(*T*)
BEGIN
 RETURN(ARGC);
END ArgCount;

(*---------------------------------------------------------------------------*)

PROCEDURE GetArg ((* EIN/ -- *)     i   : CARDINAL;
                  (* -- /AUS *) VAR arg : ARRAY OF CHAR );
(*T*)
BEGIN
 IF i < ARGC THEN
   AssignCToM2(ARGV^[VAL(ArrayRange,i)], 0, arg);
 ELSE
   arg[0] := EOS;
 END;
END GetArg;

(*---------------------------------------------------------------------------*)

PROCEDURE GetEnvVar ((* EIN/ -- *) REF var : ARRAY OF CHAR;
                     (* -- /AUS *) VAR val : ARRAY OF CHAR ): BOOLEAN;
(*T*)
BEGIN
 AssignCToM2(getenv(var), 0, val);
 RETURN(val[0] <> EOS);
END GetEnvVar;

(*---------------------------------------------------------------------------*)

PROCEDURE initargs;
(*T*)
(* Initialisieren der Programmargumente und Environmentvariablen.
   Als Prozedur, damit Registervariablen deklariert werden koennen.
 *)
VAR __REG__ envPtr  : StrPtr;
    __REG__ cmdPtr  : StrPtr;
    __REG__ envIdx  : StrRange;
    __REG__ srcIdx  : StrRange;
    __REG__ dstIdx  : StrRange;
    __REG__ c       : CHAR;
            EXARG   : BOOLEAN;
            EXNULL  : BOOLEAN;
            ENV     : BOOLEAN;
#ifdef USE_AES_FOR_ARGV0
            AUTO    : BOOLEAN;
#endif
    __REG__ i       : ArrayRange;
            cmdLen  : StrRange;
            nullIdx : StrRange;
            argIdx  : StrRange;
            envSize : CARDINAL;
            args    : ArrayRange;
            vars    : ArrayRange;
            mem     : ADDRESS;

BEGIN
  EXARG  := FALSE;
  EXNULL := FALSE;
  ARGC   := 0;
  args   := 0;
  vars   := 0;
  null   := NULL;
  ARGV   := CAST(StrArray,ADR(null));
  ENVP   := CAST(StrArray,ADR(null));
  envPtr := BASEP^.pEnv;

  Fsetdta(ADR(dta));  (* damit bleibt die Kommandozeile ungeschoren *)
  BASEP^.pDta := ADR(dta);

  ENV := (envPtr <> NULL) AND (envPtr^[0] <> 0C);
  IF ENV THEN
    (* Zuerst wird nach ARGV gesucht, und, falls vorhanden, abgetrennt,
     * sodass der Rest einheitlich als Environment behandelt werden
     * kann. Das ARGV-Verfahren benutzt naemlich nicht das Standardformat
     * fuer Environmentvariablen und darf nicht bei der evtl. noetigen
     * Formatkorrektur des Environments beruecksichtigt werden.
     *)
    envIdx := 0;
    LOOP
      IF EXARG THEN
        INC(args);
      ELSE
#ifdef TDIM2
__RANGECHECK_OFF__ (* Ausdruck sonst zu kompliziert ... *)
#endif
        IF    (envPtr^[envIdx]   = 'A')
          AND (envPtr^[envIdx+1] = 'R')
          AND (envPtr^[envIdx+2] = 'G')
          AND (envPtr^[envIdx+3] = 'V')
          AND (envPtr^[envIdx+4] = '=')
        THEN
          envPtr^[envIdx]   := 0C;
          envPtr^[envIdx+1] := 0C; (* Falls ARGV erste (und einzige) Variable *)
          IF MWCStyle OR (BASEP^.pCmdlin[0] = CHR(127)) THEN
            EXARG := TRUE;
            IF    (envPtr^[envIdx+5] = 'N')
              AND (envPtr^[envIdx+6] = 'U')
              AND (envPtr^[envIdx+7] = 'L')
              AND (envPtr^[envIdx+8] = 'L')
              AND (envPtr^[envIdx+9] = ':')
            THEN
              INC(envIdx, 10);
              nullIdx := envIdx;
              EXNULL  := TRUE;
            ELSE
              INC(envIdx, 5);
            END;
#ifdef TDIM2
__RANGECHECK_PREV__
#endif
            (* Wert der ARGV-Variable (erstmal) ueberlesen *)
            WHILE envPtr^[envIdx] <> 0C DO
              INC(envIdx);
            END;
            INC(envIdx); (* Hier beginnt der Programmname *)
            IF envPtr^[envIdx] = 0C THEN
              (* Environment zuende: Fehler, kein ARGV *)
              EXARG  := FALSE;
              EXNULL := FALSE;
              EXIT;
            ELSE
              argIdx := envIdx;
              args   := 1;
            END;
          ELSE
            EXIT; (* ARGV entspricht nicht dem Atari-Standard *)
          END;
        END;
      END;
      WHILE envPtr^[envIdx] <> 0C DO
        INC(envIdx);
      END;
      INC(envIdx);
      IF envPtr^[envIdx] = 0C THEN EXIT; END;
    END; (* LOOP *)
  END; (* IF ENV *)

  IF args = 0 THEN
    args    := 1; (* mindestens Programmname *)
    prgName := "";
    cmdBuf  := BASEP^.pCmdlin;

#ifdef USE_AES_FOR_ARGV0
#  warning ...using AES for argv[0]

    AUTO := FALSE;
    IF Version() = 0 THEN
      IF ApplInit() < 0 THEN
        AUTO := Version() = 0;
      ELSE
        ApplExit;
      END;
    END;

    IF NOT AUTO THEN
      (* AES bereits initialisiert *)
      ShelRead(prgName, cmdBuf);
      IF NOT EQUALN(ORD(cmdBuf[0])+1, cmdBuf, BASEP^.pCmdlin) THEN
        (* Plausibilitaetstest: Wenn die Kommandozeile nicht mit der aus
         * der Basepage uebereinstimmt, ist dieses Programm vermutlich
         * nicht mit "ShelWrite" gestartet worden, und die Ergebnisse
         * von "ShelRead()" stimmen nicht.
         * Dieser Test klappt nicht immer: z.B. nicht, wenn aufrufendes
         * Programm (per ShelWrite gestartet) und aufgerufenes
         * Programm (durch Pexec) ohne Argumente gestartet werden,
         * dann sind naemlich auch beide Kommandozeilen gleich.
         *)
        prgName := "";
        cmdBuf  := BASEP^.pCmdlin;
      END;
    END;
#endif

    (* Kommandozeile untersuchen, falls kein (korrektes) ARGV-Verfahren
     * verwendet wurde.
     * Es wird angenommen, dass im ersten Byte der Kommandozeile die
     * korrekte Laenge der Kommandozeile steht (ist das sicher?)!
     *
     * Zuerst muss die Anzahl der Argumente ermittelt werden.
     *)
    cmdLen := ORD(cmdBuf[0]);  (* Laenge der Kommandozeile *)
    IF cmdLen > 124 THEN
      cmdLen := 124;           (* max. 124 Zeichen ausschl. Laengenbyte *)
    END;

    dstIdx := 0;
    srcIdx := 1;               (* Laengenbyte ueberspringen *)
    (* Ueberfluessige Leerzeichen zwischen den Argumenten entfernt;
     * dafuer werden sie mit Nullbyte abgeschlossen. Dieses wird aber
     * nur in einer Kopie der Basepage-Kommandozeile vorgenommen.
     *)
    REPEAT
      WHILE (srcIdx <= cmdLen) AND isspace(cmdBuf[srcIdx]) DO
        (* Leerzeichen vor dem Argument entfernen.
         * Entfernt auch das abschliessende CR des Desktops.
         *)
        INC(srcIdx);
      END;
      IF cmdBuf[srcIdx] < ' ' THEN
        (* Controlzeichen (z.B. 0C) beendet auch die Kommandozeile *)
        srcIdx := cmdLen + 1;
      END;
      IF srcIdx <= cmdLen THEN
        WHILE (srcIdx <= cmdLen) AND (cmdBuf[srcIdx] > ' ')  DO
          (* Argument ohne Leerzeichen nach vorne schieben *)
          cmdBuf[dstIdx] := cmdBuf[srcIdx];
          INC(srcIdx);
          INC(dstIdx);
        END;
        cmdBuf[dstIdx] := 0C; (* Argument durch Nullbyte abschliessen *)
        INC(srcIdx);          (* Argumentende ueberspringen *)
        INC(dstIdx);
        INC(args);
      END;
    UNTIL srcIdx > cmdLen;
  END; (* IF args = 0 *)

  IF ENV THEN
    (* Jetzt muss das Environment evtl. korrigiert werden, da der
     * Desktop die Variablen in einem anderen Format als ueblich
     * ablegt (z.B.: "PATH=",0C,"A:\",0C, statt "PATH=A:\",0C).
     * Gleichzeitig wird die Anzahl der Variablen ermittelt.
     *)
    srcIdx := 0;
    dstIdx := 0;
    REPEAT
      REPEAT
        (* Variablenname kopieren, dabei evtl. nach vorne verschieben *)
        c := envPtr^[srcIdx];
        envPtr^[dstIdx] := c;
        INC(srcIdx);
        INC(dstIdx);
      UNTIL (c = 0C) OR (c = '=');

      IF (c = '=') THEN
        (* Variable hat evtl. einen Wert *)
        IF (envPtr^[srcIdx] = 0C) AND (envPtr^[srcIdx+1] <> 0C) THEN
          envIdx := srcIdx;
          REPEAT
            INC(envIdx);
            c := envPtr^[envIdx];
          UNTIL (c = 0C) OR (c = '=');
          IF c = 0C THEN
            (* eingeschobenes Nullbyte ignorieren *)
            INC(srcIdx);
          END;
        END;
        REPEAT
          (* Variablenwert kopieren, einschliesslich abschl. NullByte *)
          c := envPtr^[srcIdx];
          envPtr^[dstIdx] := c;
          INC(srcIdx);
          INC(dstIdx);
        UNTIL c = 0C;
      END;
      INC(vars);
    UNTIL envPtr^[srcIdx] = 0C;
    envPtr^[dstIdx] := 0C; (* Environment beendet *)
  END; (* IF ENV *)

  envSize := VAL(CARDINAL,(args + vars + 2)) * VAL(CARDINAL,TSIZE(StrPtr));
  (* + 2 wegen Nullpointer *)
  IF NOT Malloc(VAL(SIGNEDLONG, envSize), mem) THEN
    args := 0;
    vars := 0;
  ELSE
    ENVP := CAST(StrArray,mem);
    IF ENV THEN
      envIdx := 0;
      FOR i := 0 TO vars - 1 DO  (* vars > 0 ist gesichert *)
        ENVP^[i] := CAST(StrPtr,ADR(envPtr^[envIdx]));
        REPEAT
          INC(envIdx);
        UNTIL envPtr^[envIdx] = 0C;
        INC(envIdx); (* Die Null *)
      END;
    END; (* IF ENV *)
    ENVP^[vars] := NULL;

    ARGV := CAST(StrArray,ADR(ENVP^[vars+1]));
    IF EXARG THEN
      envIdx := argIdx;
      FOR i := 0 TO args - 1 DO  (* args > 0 ist gesichert *)
        ARGV^[i] := CAST(StrPtr,ADR(envPtr^[envIdx]));
        REPEAT
          INC(envIdx);
        UNTIL envPtr^[envIdx] = 0C;
        INC(envIdx);
      END;

      IF EXNULL THEN
        (* Die Indexliste der leeren Argumente besteht aus durch
         * Kommata getrennten Dezimalzahlen. Beim ersten ungueltigen
         * Zeichen (einschliesslich dem beendenden Nullbyte) wird die
         * Liste als beendet betrachtet.
         *)
        WHILE isdigit(envPtr^[nullIdx]) DO
          (* Zeichenkette in einen Index wandeln.
           * Ohne Ueberlaufpruefung usw.
           *)
          i := 0;
          REPEAT
            i := i * 10 + VAL(ArrayRange,tocard(envPtr^[nullIdx]));
            INC(nullIdx);
          UNTIL NOT isdigit(envPtr^[nullIdx]);

          IF i < args THEN
            (* Schutz-Leerzeichen des leeren Arguments loeschen *)
            ARGV^[i]^[0] := 0C;
          END;
          IF envPtr^[nullIdx] = ',' THEN
            (* Es folgt eine weitere Zahl *)
            INC(nullIdx);
          END;
        END;
      END;

      (* Soviel wie moeglich vom ARGV-Environment in die Basepage-Kommandozeile
       * kopieren, falls dies vom Aufrufer nicht getan wurde. Der Programmname
       * wird uebersprungen.
       *)
      cmdBuf[0] := CHR(127);
      i      := 1;
      dstIdx := 1;
      WHILE (i < args) AND (dstIdx <= 124) DO
        srcIdx := 0;
        cmdPtr := ARGV^[i]; INC(i);
        IF cmdPtr^[0] = 0C THEN
          (* Leeres Argument *)
          cmdBuf[dstIdx]   := "'";
          cmdBuf[dstIdx+1] := "'";
          INC(dstIdx, 2);
        ELSE
          (* Argument kopieren *)
          REPEAT
            cmdBuf[dstIdx] := cmdPtr^[srcIdx];
            INC(srcIdx);
            INC(dstIdx);
          UNTIL (cmdPtr^[srcIdx] = 0C) OR (dstIdx > 124);
        END;

        (* dstIdx <= 126 ist gesichert *)
        IF i < args THEN
          (* Ende des Arguments erreicht *)
          cmdBuf[dstIdx] := ' ';
          INC(dstIdx);
        ELSE
          (* Ende der Argumentliste erreicht *)
          cmdBuf[dstIdx] := 0C;
        END;
      END;

      (* Die restliche Kommandozeile wird geloescht. *)
      IF dstIdx > 125 THEN
        dstIdx := 125;
      END;
      WHILE dstIdx < 128 DO
        cmdBuf[dstIdx] := 0C;
        INC(dstIdx);
      END;
      BASEP^.pCmdlin := cmdBuf;

    ELSE (* NOT EXARG *)
      ARGV^[0] := CAST(StrPtr,ADR(prgName));
      srcIdx   := 0;
      FOR i := 1 TO args - 1 DO
        ARGV^[i] := CAST(StrPtr,ADR(cmdBuf[srcIdx]));
        REPEAT
          INC(srcIdx);
        UNTIL cmdBuf[srcIdx] = 0C;
        INC(srcIdx);
      END;
    END;
  END; (* IF mem = NULL *)

  ARGV^[args] := NULL;
  ARGC        := VAL(CARDINAL,args);
  environ     := ENVP;
END initargs;

(*===========================================================================*)

BEGIN (* cmdline *)
 initargs;
END cmdline.
