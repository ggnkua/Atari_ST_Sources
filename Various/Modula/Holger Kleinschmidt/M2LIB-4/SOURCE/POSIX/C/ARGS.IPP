IMPLEMENTATION MODULE args;
__IMP_SWITCHES__
__DRIVER__ /* ARGV muss auf jeden Fall aus dem Environment entfernt werden */
__DEBUG__
__RANGECHECK_OFF__
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
(* 10-Aug-96, Holger Kleinschmidt & Ulrich Kaiser                            *)
(*****************************************************************************)

/* Folgende Zeile in #if 1 aendern, falls der Programmname
 * ueber "shel_read()" ermittelt werden soll, wenn kein ARGV-Verfahren
 * benutzt wurde.
 * Die GEM-Aufrufe sind fuer die GEM-Bibliothek ``crystal'' von
 * Ulrich Kaiser ausgelegt, wer eine andere GEM-Bibliothek verwendet, muss
 * die Aufrufe entsprechend anpassen.
 */
#if 0
#define __USE_AES_FOR_ARGV0__
#endif

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG;

FROM OSCALLS IMPORT
(* PROC *) Fsetdta, Malloc, Mfree, Fcntl, Fopen, Fclose;

FROM blk IMPORT
(* PROC *) memmove;

FROM ctype IMPORT
(* PROC *) Cisspace, Cisdigit, tocard;

FROM DosSystem IMPORT
(* TYPE *) BasePtr, BasePage, CmdLine,
(* VAR  *) BASEP;

FROM types IMPORT
(* CONST*) EOS,
(* TYPE *) int, sizeT, StrRange, ArrayRange, StrPtr, StrArray;

FROM str IMPORT
(* PROC *) AssignCToM2, strncmp;

#ifdef __USE_AES_FOR_ARGV0__
FROM StringsX IMPORT
(* PROC *) EqualPrefix;

FROM AES IMPORT
(* PROC *) Version;

FROM ApplMgr IMPORT
(* PROC *) applinit, applexit;

FROM ShelMgr IMPORT
(* PROC *) ShelRead;

FROM MenuMgr IMPORT
(* PROC *) Accessory;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  VARINC = 32; (* > 1 *)

VAR
  dta     : ARRAY [0..43] OF CHAR; (* Platz fuer Default-DTA *)
  EXARG   : BOOLEAN;   (* Flag: ARGV-Verfahren wurde benutzt *)
  EXNULL  : BOOLEAN;   (* Flag: Erweitertes ARGV-Verfahren wurde benutzt *)
  ARGV    : StrArray;  (* -> Feld von Zeigern auf die Kommando-Argumente *)
  ARGC    : CARDINAL;  (* Anzahl der Kommando-Argumente *)
  VARC    : CARDINAL;  (* Anzahl der Environmentvariablen *)
  VARSIZE : CARDINAL;  (* Anzahl der moeglichen Environmentvariablen *)
  prgName : CmdLine;   (* Name des Programms, falls feststellbar *)
  cmdBuf  : CmdLine;   (* Arbeitskopie der Basepage-Kommandozeile *)
  null    : StrPtr;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE main ((* -- /AUS *) VAR argc : ArrayRange;
                (* -- /AUS *) VAR argv : StrArray   );

BEGIN
 argc := ARGC;
 argv := ARGV;
END main;

(*---------------------------------------------------------------------------*)

PROCEDURE getenv ((* EIN/ -- *) REF var : ARRAY OF CHAR ): StrPtr;

VAR __REG__ varIdx : StrRange;
    __REG__ varPtr : StrPtr;
            val    : ArrayRange;

BEGIN
 val    := 0;
 varPtr := environ^[0];
 WHILE varPtr # NULL DO
   varIdx := 0;
   WHILE (VAL(CARDINAL,varIdx) <= VAL(CARDINAL,HIGH(var)))
       & (var[varIdx] # 0C)
       & (var[varIdx] = varPtr^[varIdx])
   DO
     INC(varIdx);
   END;

   IF  ((VAL(CARDINAL,varIdx) > VAL(CARDINAL,HIGH(var))) OR (var[varIdx] = 0C))
     & (varPtr^[varIdx] = '=')
   THEN
     RETURN(ADR(varPtr^[varIdx+1]));
   END;

   INC(val);
   varPtr := environ^[val];
 END;

 RETURN(NULL);
END getenv;

(*---------------------------------------------------------------------------*)

PROCEDURE putenv ((* EIN/ -- *) var : StrPtr ): int;

VAR __REG__ len : StrRange;
    __REG__ ptr : StrPtr;
    __REG__ ch  : CHAR;
            val : ArrayRange;
            mem : ADDRESS;
            res : INTEGER;

BEGIN
 ptr := var;
 IF ptr = NULL THEN
   RETURN(-1);
 END;
 (* Laenge der Variable bis zum = ermitteln *)
 len := 0;
 LOOP
   ch := ptr^[len];
   IF (ch = '=') OR (ch = 0C) THEN
     EXIT;
   END;
   INC(len);
 END;

 (* Variable im Environment suchen *)
 val := 0;
 ptr := environ^[0];
 WHILE (ptr # NULL)
     & ((strncmp(var, ptr, VAL(sizeT,len)) # 0) OR (ptr^[len] # '='))
 DO
   INC(val);
   ptr := environ^[val];
 END;

 IF ptr # NULL THEN
   (* Environmentvariable existiert bereits, nur neuen Zeiger setzen *)
   environ^[val] := var;
   RETURN(0);
 END;

 IF VARC >= VARSIZE THEN
   IF ~Malloc(VAL(UNSIGNEDLONG,VARC+VARINC+1) * VAL(UNSIGNEDLONG,TSIZE(StrPtr)), mem) THEN
     RETURN(-1);
   END;
   IF VARC # 0 THEN
     memmove(mem, environ, VAL(sizeT,VARC) * VAL(sizeT,TSIZE(StrPtr)));
     IF ~Mfree(environ, res) THEN
       RETURN(-1);
     END;
   END;
   environ := mem;
   INC(VARSIZE, VARINC);
 END;

 environ^[val]   := var;
 environ^[val+1] := NULL;
 INC(VARC);
 RETURN(0);
END putenv;

(*---------------------------------------------------------------------------*)

PROCEDURE ArgCount ( ): CARDINAL;
BEGIN
 RETURN(ARGC);
END ArgCount;

(*---------------------------------------------------------------------------*)

PROCEDURE GetArg ((* EIN/ -- *)     i   : CARDINAL;
                  (* -- /AUS *) VAR arg : ARRAY OF CHAR );

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

VAR tmp : StrPtr;

BEGIN
 tmp := getenv(var);
 IF tmp = NULL THEN
   RETURN(FALSE);
 ELSE
   AssignCToM2(tmp, 0, val);
   RETURN(TRUE);
 END;
END GetEnvVar;

(*---------------------------------------------------------------------------*)

PROCEDURE ARGVused ( ): ARGVstyle;
BEGIN
 IF EXNULL THEN
   RETURN(nullARGV);
 ELSIF EXARG THEN
   RETURN(simpleARGV);
 ELSE
   RETURN(noARGV);
 END;
END ARGVused;

(*---------------------------------------------------------------------------*)

PROCEDURE initargs;
(* Initialisieren der Programmargumente und Environmentvariablen.
   Als Prozedur, damit Registervariablen deklariert werden koennen.
 *)
CONST PLOADINFO = 500CH; (* ('P'<< 8)|12 *)

VAR __REG__ srcPtr  : StrPtr;
    __REG__ dstPtr  : StrPtr;
    __REG__ srcIdx  : StrRange;
    __REG__ dstIdx  : StrRange;
    __REG__ c       : CHAR;
    __REG__ i       : ArrayRange;
            ENV     : BOOLEAN;
#ifdef __USE_AES_FOR_ARGV0__
            AUTO    : BOOLEAN;
#endif
            cmdLen  : StrRange;
            envPtr  : StrPtr;
            argPtr  : StrPtr;
            nulPtr  : StrPtr;
            args    : ArrayRange;
            vars    : ArrayRange;
            mem     : ADDRESS;
            lres    : LONGINT;
            done    : BOOLEAN;
            argv0   : BOOLEAN;
            phandle : INTEGER;
            pname   : ARRAY [0..13] OF CHAR;
            pload   : RECORD
              fnamelen : UNSIGNEDWORD;
              cmdlin   : ADDRESS;
              fname    : ADDRESS;
            END;

BEGIN
 envPtr := BASEP^.pEnv;
 args   := 0;
 vars   := 0;

 Fsetdta(ADR(dta));  (* damit bleibt die Kommandozeile ungeschoren *)
 BASEP^.pDta := ADR(dta);

 ENV := (envPtr # NULL) & (envPtr^[0] # 0C);
 IF ENV THEN
   (* Zuerst wird nach ARGV gesucht, und, falls vorhanden, abgetrennt,
    * so dass der Rest einheitlich als Environment behandelt werden
    * kann. Das ARGV-Verfahren benutzt naemlich nicht das Standardformat
    * fuer Environmentvariablen und darf nicht bei der evtl. noetigen
    * Formatkorrektur des Environments beruecksichtigt werden.
    *)
   srcPtr := envPtr;
   LOOP
     IF EXARG THEN
       INC(args);
     ELSE
       IF  (srcPtr^[0] = 'A')
         & (srcPtr^[1] = 'R')
         & (srcPtr^[2] = 'G')
         & (srcPtr^[3] = 'V')
         & (srcPtr^[4] = '=')
       THEN
         srcPtr^[0] := 0C;
         srcPtr^[1] := 0C; (* Falls ARGV erste (und einzige) Variable *)
         IF MWCStyle OR (BASEP^.pCmdlin[0] = CHR(127)) THEN
           EXARG := TRUE;
           IF  (srcPtr^[5] = 'N')
             & (srcPtr^[6] = 'U')
             & (srcPtr^[7] = 'L')
             & (srcPtr^[8] = 'L')
             & (srcPtr^[9] = ':')
           THEN
             srcPtr := ADDADR(srcPtr, 10);
             nulPtr := srcPtr; (* Hier beginnen die Null-Argumente *)
             EXNULL := TRUE;
           ELSE
             srcPtr := ADDADR(srcPtr, 5);
           END;
           (* Wert der ARGV-Variable (erstmal) ueberlesen *)
           WHILE srcPtr^[0] # 0C DO
             srcPtr := ADDADR(srcPtr, 1);
           END;
           srcPtr := ADDADR(srcPtr, 1);
           IF srcPtr^[0] = 0C THEN
             (* Environment zuende: Fehler, kein ARGV *)
             EXARG  := FALSE;
             EXNULL := FALSE;
             EXIT;
           ELSE
             argPtr := srcPtr; (* Hier beginnt der Programmname *)
             args   := 1;
           END;
         ELSE
           EXIT; (* ARGV entspricht nicht dem Atari-Standard *)
         END;
       END;
     END;
     WHILE srcPtr^[0] # 0C DO
       srcPtr := ADDADR(srcPtr, 1);
     END;
     srcPtr := ADDADR(srcPtr, 1);
     IF srcPtr^[0] = 0C THEN EXIT; END;
   END; (* LOOP *)
 END; (* IF ENV *)

 IF args = 0 THEN
   args    := 1; (* mindestens Programmname *)
   prgName := "";
   cmdBuf  := BASEP^.pCmdlin;
   argv0   := FALSE;

   pname := "u:\proc\x.-1"; (* Nur die -1 (= Prozess selbst) ist wichtig *)
   pload.fnamelen := SIZE(prgName);
   pload.cmdlin   := ADR(cmdBuf);
   pload.fname    := ADR(prgName);
   IF Fopen(ADR(pname), 0, phandle) THEN
     (* Wenn PLOADINFO nicht unterstuetzt wird, bleiben 'prgName' und
      * 'cmdBuf' unveraendert.
      *)
     argv0 := Fcntl(phandle, ADR(pload), PLOADINFO, lres);
     done  := Fclose(phandle, phandle);
   END;

#ifdef __USE_AES_FOR_ARGV0__
#  warning ...using AES for argv[0]

   IF ~argv0 THEN
     AUTO := FALSE;
     IF Version() = 0 THEN
       (* Noch kein ApplInit()/applinit() aufgerufen *)
       IF ~Accessory() THEN
         (* ACCs vertragen kein applexit(). Wenn das Programm aber ein
          * ACC ist, ist auch das AES bereits initialisiert.
          * Hier nicht ApplInit() benutzen, da diese Prozedur nur einmal
          * aufgerufen werden darf.
          *)
         IF applinit() < 0 THEN
           AUTO := Version() = 0;
         ELSE
           (* Und wieder abmelden, damit die Initialisierung transparent
            * ablaeuft.
            *)
           applexit;
         END;
       END;
     END;

     IF ~AUTO THEN
       (* AES bereits initialisiert *)
       ShelRead(ADR(prgName), ADR(cmdBuf));
       IF ~EqualPrefix(ORD(cmdBuf[0])+1, cmdBuf, BASEP^.pCmdlin) THEN
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
   END; (* ~argv0 *)
#endif

   (* Kommandozeile untersuchen, falls kein (korrektes) ARGV-Verfahren
    * verwendet wurde.
    * Es wird angenommen, dass im ersten Byte der Kommandozeile die
    * korrekte Laenge der Kommandozeile steht.
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
     WHILE (srcIdx <= cmdLen) & Cisspace(cmdBuf[srcIdx]) DO
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
       WHILE (srcIdx <= cmdLen) & (cmdBuf[srcIdx] > ' ')  DO
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
   srcPtr := envPtr;
   dstPtr := srcPtr;
   REPEAT
     REPEAT
       (* Variablenname kopieren, dabei evtl. nach vorne verschieben *)
       c := srcPtr^[0];
       dstPtr^[0] := c;
       srcPtr := ADDADR(srcPtr, 1);
       dstPtr := ADDADR(dstPtr, 1);
     UNTIL (c = 0C) OR (c = '=');

     IF (c = '=') THEN
       (* Variable hat evtl. einen Wert *)
       IF (srcPtr^[0] = 0C) & (srcPtr^[1] # 0C) THEN
         (* Feststellen, ob es sich nach dem Nullbyte um den Wert der
          * Variable oder bereits um die naechste Variable handelt (dann
          * hat diese Variable keinen Wert).
          * Hier kann mit einem Index statt Pointerarithmetik gearbeitet
          * werden, da eine einzelne Variable keine 64kB gross ist.
          *)
         srcIdx := 0;
         REPEAT
           INC(srcIdx);
           c := srcPtr^[srcIdx];
         UNTIL (c = 0C) OR (c = '=');
         IF c = 0C THEN
           (* eingeschobenes Nullbyte ignorieren *)
           srcPtr := ADDADR(srcPtr, 1);
         END;
       END;
       REPEAT
         (* Variablenwert kopieren, einschliesslich abschl. NullByte *)
         c := srcPtr^[0];
         dstPtr^[0] := c;
         srcPtr := ADDADR(srcPtr, 1);
         dstPtr := ADDADR(dstPtr, 1);
       UNTIL c = 0C;
     END;
     INC(vars);
   UNTIL srcPtr^[0] = 0C;
   dstPtr^[0] := 0C; (* Environment beendet *)
 END; (* IF ENV *)

 (* ARGV-Feld aufbauen *)
 IF ~Malloc(VAL(UNSIGNEDLONG,args+1) * VAL(UNSIGNEDLONG,TSIZE(StrPtr)),ARGV) THEN
   ARGV := ADR(null);
   args := 0;
 ELSE
   IF EXARG THEN
     srcPtr := argPtr;
     FOR i := 0 TO args - 1 DO  (* args > 0 ist gesichert *)
       ARGV^[i] := srcPtr;
       REPEAT
         srcPtr := ADDADR(srcPtr, 1);
       UNTIL srcPtr^[0] = 0C;
       srcPtr := ADDADR(srcPtr, 1);
     END;

     IF EXNULL THEN
       (* Die Indexliste der leeren Argumente besteht aus durch
        * Kommata getrennten Dezimalzahlen. Beim ersten ungueltigen
        * Zeichen (einschliesslich dem beendenden Nullbyte) wird die
        * Liste als beendet betrachtet.
        *)
       srcPtr := nulPtr;
       WHILE Cisdigit(srcPtr^[0]) DO
         (* Zeichenkette in einen Index wandeln.
          * Ohne Ueberlaufpruefung usw.
          *)
         i := 0;
         REPEAT
           i := i * 10 + VAL(ArrayRange,tocard(srcPtr^[0]));
           srcPtr := ADDADR(srcPtr, 1);
         UNTIL ~Cisdigit(srcPtr^[0]);

         IF i < args THEN
           (* Schutz-Leerzeichen des leeren Arguments loeschen *)
           ARGV^[i]^[0] := 0C;
         END;
         IF srcPtr^[0] = ',' THEN
           (* Es folgt eine weitere Zahl *)
           srcPtr := ADDADR(srcPtr, 1);
         END;
       END;
     END;
   ELSE (* ~EXARG *)
     ARGV^[0] := ADR(prgName);
     srcIdx   := 0;
     FOR i := 1 TO args - 1 DO
       ARGV^[i] := ADR(cmdBuf[srcIdx]);
       REPEAT
         INC(srcIdx);
       UNTIL cmdBuf[srcIdx] = 0C;
       INC(srcIdx);
     END;
   END;
   ARGV^[args] := NULL;
 END; (* IF ~Malloc *)

 (* environ-Feld aufbauen + Platz fuer neue Variablen per putenv(), ohne dass
  * Speicher angefordert werden muss.
  *)
 IF ~Malloc(VAL(UNSIGNEDLONG,vars+256+1) * VAL(UNSIGNEDLONG,TSIZE(StrPtr)),environ) THEN
   environ := ADR(null);
   vars    := 0;
 ELSE
   IF ENV THEN
     srcPtr := envPtr;
     FOR i := 0 TO vars - 1 DO  (* vars > 0 ist gesichert *)
       environ^[i] := srcPtr;
       REPEAT
         srcPtr := ADDADR(srcPtr, 1);
       UNTIL srcPtr^[0] = 0C;
       srcPtr := ADDADR(srcPtr, 1); (* Die Null *)
     END;
   END; (* IF ENV *)
   environ^[vars] := NULL;
 END;

 null    := NULL;
 ARGC    := VAL(CARDINAL,args);
 VARC    := VAL(CARDINAL,vars);
 VARSIZE := VARC + 256;
END initargs;

(*===========================================================================*)

BEGIN (* args *)
 EXARG  := FALSE;
 EXNULL := FALSE;
 initargs;
END args.
