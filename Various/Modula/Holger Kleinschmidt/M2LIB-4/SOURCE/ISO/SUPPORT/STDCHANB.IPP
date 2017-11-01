IMPLEMENTATION MODULE StdChanBase;
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
(* 10-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* Da das Zeilenende bei (GEM)DOS nicht atomar ist, sondern aus zwei Zeichen
   besteht, gibt es einige Sonderfaelle beim Puffern der Daten, die dadurch
   entstehen, dass sich die beiden Zeichen auf zwei Pufferinhalte bzw. zwei
   Lese/Schreibvorgaenge verteilen koennen.

   Lesen mit "Skip/Look()" und "TextRead()" ueber 'StdInChan':

   Es wird ausschliesslich aus dem Puffer gelesen; reicht der Pufferinhalt
   nicht aus, wird zuerst der Puffer wieder aufgefuellt; dies wird wiederholt
   bis die Leseanforderung erfuellt ist, ein Zeilenende auftritt oder
   keine Daten mehr vorhanden sind. Ist das letzte Zeichen, das vom aktuellen
   Pufferinhalt gelesen werden soll (bei "Look/Skip()" ist es das einzige
   Zeichen, das gelesen oder entfernt werden soll), ein CR, koennen drei
   Sonderfaelle unterschieden werden:

   1) Befinden sich im Puffer noch weitere Zeichen, wird ueberprueft, ob
      das naechste Zeichen, also das erste Zeichen, das nicht mehr gelesen
      werden soll, ein LF ist. Ist das der Fall, gehoert das voranstehende
      CR zu einem Zeilenende, bestehend aus der Kombination CR + LF, und
      wird ebenfalls nicht mehr gelesen.

   2) Soll der gesamte Pufferinhalt gelesen werden (das CR ist dann das
      letzte Zeichen im Puffer), werden erstmal alle Zeichen vor dem CR
      gelesen. Danach wird das CR als erstes Zeichen in den Puffer geschrieben
      und ein neuer Puffer dahinter eingelesen. Die Ueberpruefung auf ein
      Zeilenende kann nun von vorne beginnen.

   3) Ist beim Einlesen eines neuen Puffers das per Hand eingetragene CR
      das einzige Zeichen, ist die Datei zuende, und das CR wird als
      normales Zeichen uebertragen. Es kann nicht ueberprueft werden, ob
      es zu einem Zeilenende gehoert, auch wenn zu einem spaeteren
      Zeitpunkt die Datei verlaengert wird und dann moeglicherweise als
      naechstes Zeichen ein LF auftritt.


   Schreiben mit "WriteLn()" und "TextWrite()" ueber 'StdOutChan':

   Folgendes wird wiederholt bis alle Zeichen uebertragen wurden:
   o Es wird das erste LF gesucht, dem kein CR vorangeht, da dieses zu einem
     CR + LF expandiert werden muss. Wird kein solches LF gefunden, kann
     der gesamte Rest ohne Wandlung uebertragen werden.
   o Nach einem evtl. Synchronisieren bzw. Leeren des Puffers wird getestet,
     ob noch genuegend Platz im Puffer ist, die gesamte Anzahl der Bytes
     aufzunehmen. Ist dies der Fall, werden die Bytes in den Puffer
     uebertragen, sonst werden die Bytes direkt in die Datei geschrieben.
   o Falls ein LF expandiert werden muss, werden nun die Zeichen CR + LF
     in den Puffer geschrieben.

   Es gibt hier nur einen Spezialfall, der aber nicht beruecksichtigt
   wird:

   1) Wenn ein CR + LF-Zeilenende ueber zwei 'TextWrite'-Operationen
      verteilt wird, also das letzte Zeichen des ersten Aufrufs ein CR
      ist und das erste Zeichen des zweiten Aufrufs ein LF, dann duerfte
      das LF nicht zu einem CR + LF expandiert werden, da das CR schon
      beim vorigen Aufruf geschrieben wurde. Genau dies wird jedoch nicht
      ueberprueft, also darf ein CR + LF-Zeilenende nicht auf zwei
      Aufrufe verteilt werden.


   Lesen mit "RawRead()" ueber 'StdInChan':

   Zuerst werden die noch im Puffer befindlichen Bytes gelesen. Reicht
   die Anzahl nicht aus, wird ueberprueft, ob weniger Bytes als
   die Puffergroesse zu lesen sind. Ist das der Fall, wird ein neuer
   Puffer eingelesen und die restlichen Bytes aus ihm gelesen, sonst
   werden die restlichen Bytes direkt aus der Datei gelesen.


   Schreiben mit "RawWrite()" ueber 'StdOutChan':

   Zuerst werden soviele Bytes in den Puffer geschrieben wie noch Platz
   ist. Sind noch weitere Bytes zu schreiben, wird ueberprueft, ob es
   weniger Bytes als die Puffergroesse sind. Ist das der Fall, werden die
   restlichen Bytes in den Puffer geschrieben, sonst direkt in die Datei.
   In beiden Faellen wird auf jeden Fall vorher der alte Puffer in die Datei
   zurueckgeschrieben.
*)

#if 1
/* Falls dieses Makro definiert ist, werden bei I/O-Fehlern keine
 * Ausnahmen ausgeloest (bei logischen Fehlern, wie z.B. dem Ausfuehren
 * einer Operation, die der Kanal nicht zur Verfuegung stellt, gibt es
 * weiterhin Ausnahmen), sondern der Fehler nur in tid^.errNum gespeichert.
 * Nach Aufruf der Geraeteprozeduren muss diese Variable also getestet
 * werden. Nur wenn sie eine Null enthaelt, ist die Operation ordnungsgemaess
 * verlaufen, sonst enthaelt sie den Code von e.errno.
 * Die Geraeteprozeduren werden auf dem Umweg ueber die Prozeduren aus
 * IOChan aufgerufen, dort wird vorher errNum auf Null gesetzt.
 */
#define __NO_IO_EXCEPTIONS__
#endif

VAL_INTRINSIC
CAST_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNED, SIGNEDLONG, UNSIGNEDWORD;

IMPORT EXCEPTIONS;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

IMPORT ISOStrings;

IMPORT IOConsts, ChanConsts;

FROM IOChan IMPORT
(* TYPE *) ChanExceptions, ChanId;

FROM IOLink IMPORT
(* TYPE *) DeviceTablePtr, DeviceTable, DeviceId,
(* PROC *) AllocateDeviceId;

FROM er IMPORT
(* CONST*) EIO, ENOSPC,
(* VAR  *) errno;

IMPORT blk, types, DosDir, file, term;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

#if 0
TYPE
  ChanId = DeviceTablePtr;
#endif

CONST
  RBUFSIZE = 1024;
  WBUFSIZE = 1024;

TYPE
  CharPtr = POINTER TO CHAR;

VAR
  stdDevice  : DeviceId;

  nullChan   : DeviceTable;
  stdInChan  : DeviceTable;
  stdOutChan : DeviceTable;
  stdErrChan : DeviceTable;

  nl         : CHAR;

VAR
  stdInChanData : RECORD
    istty : BOOLEAN;
      (* Flag: Datei ist ein (Pseudo)Terminal *)
    error : BOOLEAN;
      (* Flag: Fehler bei letzter I/O-Operation. Wird fuer die Kommunikation
       * zwischen den ``tieferen'' und ``hoeheren'' Prozeduren verwendet,
       * wenn bei IO-Fehlern keine Ausnahmen generiert werden.
       *)
    rpos : UNSIGNEDWORD;
      (* Lesezeiger; kennzeichnet die Position im Puffer,
       * von der das naechste Byte gelesen gelesen werden soll.
       *)
    readSize : UNSIGNEDWORD;
      (* Anzahl der in den Puffer gelesenen Bytes. Dateiposition ist
       * 'readSize' Bytes hinter dem Pufferanfang, sonst am Anfang des
       * Puffers. Ist Null, falls der Puffer nur beschrieben wurde.
       *)
    rbuf : ARRAY [0..RBUFSIZE] OF CHAR;
      (* Puffer mit Platz fuer ein zusaetzliches CR VOR dem eigentlichen
       * Puffer.
       *)
    rhandle : INTEGER;
      (* Dateikennung des Betriebssystems *)
    looked : BOOLEAN;
      (* Flag: Falls TRUE, sind die folgenden Felder gueltig: *)
    lookRes : IOConsts.ReadResults;
      (* Resultat der letzten Lese-Operation *)
    lookCh : CHAR;
      (* Aktuelles Zeichen, falls 'lookRes' = 'allRight' *)
    skipSize : UNSIGNEDWORD;
      (* Anzahl der zu entfernenden Zeichen, falls 'lookRes' # 'endOfInput' *)
  END;

  stdOutChanData : RECORD
    istty : BOOLEAN;
      (* Flag: Datei ist ein (Pseudo)Terminal *)
    error : BOOLEAN;
      (* Flag: Fehler bei letzter I/O-Operation. Wird fuer die Kommunikation
       * zwischen den ``tieferen'' und ``hoeheren'' Prozeduren verwendet,
       * wenn bei IO-Fehlern keine Ausnahmen generiert werden.
       *)
    wpos : UNSIGNEDWORD;
      (* Schreibzeiger; kennzeichnet die Position im Puffer,
       * an die das naechste Byte geschrieben werden soll.
       *)
    wbuf : ARRAY [0..WBUFSIZE] OF CHAR;
      (* Puffer mit Platz fuer ein zusaetzliches CR VOR dem eigentlichen
       * Puffer.
       *)
    flushBuf : BOOLEAN;
      (* Flag: Puffer nach Schreiboperation leeren *)
    dirty : BOOLEAN;
      (* Flag: Puffer wurde beschrieben *)
    whandle : INTEGER;
      (* Dateikennung des Betriebssystems *)
  END;

  stdErrChanData : RECORD
    istty    : BOOLEAN;
    error    : BOOLEAN;
    pos      : UNSIGNEDWORD;
    readSize : UNSIGNEDWORD;
    buf      : ARRAY [0..1] OF CHAR;
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE raiseEOF;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(skipAtEnd),
                  "StdChans: 'Skip/Look' at end of file");
END raiseEOF;

(*---------------------------------------------------------------------------*)

PROCEDURE raiseWrite;
BEGIN
 stdInChan.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                  "StdInChan: 'Write' not available");
END raiseWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE raiseRead;
BEGIN
 stdOutChan.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                  "StdOutChan: 'Read' not available");
END raiseRead;

(*---------------------------------------------------------------------------*)

PROCEDURE fillBuf ((* EIN/ -- *) addCR : BOOLEAN );
(* Leeren Puffer fuellen *)
VAR         nRead : types.ssizeT;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 WITH stdInChanData DO
   looked := FALSE;
   rpos   := 0;
   error  := FALSE;
   IF addCR THEN
     rbuf[0] := types.CR;
     start   := 1;
   ELSE
     start   := 0;
   END;
   nRead := file.read(rhandle, ADR(rbuf[start]), RBUFSIZE);
   IF nRead >= VAL(types.ssizeT,0) THEN
     (* Null ist auch OK, dann ist das Dateiende erreicht *)
     readSize := VAL(UNSIGNEDWORD,nRead) + start;
   ELSE
     readSize := start;
     IF ~addCR THEN
       error            := TRUE;
       stdInChan.errNum := errno;
#ifndef __NO_IO_EXCEPTIONS__
       EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError), (* RETRY moeglich *)
                        "StreamFile: 'Read' failed");
#endif
     END;
   END;
 END;
END fillBuf;

(*---------------------------------------------------------------------------*)

#ifdef HM2
(*$E+*)
#endif
PROCEDURE noProc ((* -- / -- *) tid : DeviceTablePtr );
END noProc;

(*===========================================================================*)
(* Geraeteprozeduren fuer den 'Null'-Kanal                                   *)
(*===========================================================================*)

PROCEDURE nullSkip ((* -- / -- *) tid : DeviceTablePtr );
BEGIN
 nullChan.errNum := EIO;
 raiseEOF;
END nullSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE nullLook ((* -- / -- *)     tid : DeviceTablePtr;
                    (* -- / -- *) VAR ch  : CHAR;
                    (* -- /AUS *) VAR res : IOConsts.ReadResults );
BEGIN
 res             := IOConsts.endOfInput;
 nullChan.result := IOConsts.endOfInput;
END nullLook;

(*---------------------------------------------------------------------------*)

PROCEDURE nullSkipLook ((* -- / -- *)     tid : DeviceTablePtr;
                        (* -- / -- *) VAR ch  : CHAR;
                        (* -- / -- *) VAR res : IOConsts.ReadResults );
BEGIN
 nullChan.errNum := EIO;
 raiseEOF;
END nullSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE nullRead ((* -- / -- *)     tid  : DeviceTablePtr;
                    (* -- / -- *)     to   : ADDRESS;
                    (* -- / -- *)     size : UNSIGNED;
                    (* -- /AUS *) VAR read : UNSIGNED       );
BEGIN
 read            := 0;
 nullChan.result := IOConsts.endOfInput;
END nullRead;

(*---------------------------------------------------------------------------*)

PROCEDURE nullWrite ((* -- / -- *) tid  : DeviceTablePtr;
                     (* -- / -- *) from : ADDRESS;
                     (* -- / -- *) size : UNSIGNED       );
END nullWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE nullName ((* -- / -- *)     tid  : DeviceTablePtr;
                    (* -- /AUS *) VAR name : ARRAY OF CHAR  );
BEGIN
 ISOStrings.Assign("NullChan", name);
END nullName;

(*===========================================================================*)
(* Geraeteprozeduren fuer den 'StdIn'-Kanal                                  *)
(*===========================================================================*)

PROCEDURE inWriteLn ((* -- / -- *) tid : DeviceTablePtr );
BEGIN
 raiseWrite;
END inWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE inWrite ((* -- / -- *) tid  : DeviceTablePtr;
                   (* -- / -- *) from : ADDRESS;
                   (* -- / -- *) size : UNSIGNED       );
BEGIN
 raiseWrite;
END inWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE inLook ((* -- / -- *)     tid : DeviceTablePtr;
                  (* -- /AUS *) VAR c   : CHAR;
                  (* -- /AUS *) VAR res : IOConsts.ReadResults );

(* Die Schleife wird hoechstens dreimal durchlaufen:
   1) Wenn der Puffer leer ist, wird ein 'fillbuf' ausgefuehrt
   2) Das einzige vorhandene Zeichen ist ein CR, also tstLF = TRUE
   3) Jetzt kann entschieden werden, welches Zeichen vorliegt

   Durchlauf 3) findet immer statt, 1) und/oder 2) koennen
   jedoch bei den entsprechenden Bedingungen entfallen.
 *)
VAR __REG__ left  : UNSIGNEDWORD;
    __REG__ ch    : CHAR;
    __REG__ r     : IOConsts.ReadResults;
            tstLF : BOOLEAN;

BEGIN
 WITH stdInChanData DO
   IF looked THEN
     c                := lookCh;
     res              := lookRes;
     stdInChan.result := lookRes;
     RETURN;
   END;

   skipSize := 1;
   r        := IOConsts.endOfLine;
   LOOP
     tstLF := FALSE;
     IF rpos < readSize THEN
       left := readSize - rpos;
     ELSE
       left := 0;
     END;

     IF left = 0 THEN
       ch := 0C;
     ELSE
       ch := rbuf[rpos];
       IF ch = types.CR THEN
         IF istty THEN
           (* Bei Terminals gilt auch CR alleine als Zeilenende *)
           EXIT;
         ELSIF left = 1 THEN
           (* Letztes Zeichen im Puffer ist ein CR; deshalb neuen Puffer
            * einlesen, um zu testen ob ein LF folgt. Bei einem Terminal
            * ist das nicht noetig, da CR auf jeden Fall ein Zeilenende
            * kennzeichnet, auch wenn dahinter kein LF folgt.
            *)
           tstLF := TRUE;
         ELSIF rbuf[rpos+1] = types.LF THEN
           (* LF und CR+LF gelten als Zeilenende *)
           skipSize := 2;
           EXIT;
         END;
       ELSIF ch = types.LF THEN
         (* LF ist auf jeden Fall ein Zeilenende *)
         EXIT;
       ELSE
         (* Normales Zeichen gelesen. *)
         r := IOConsts.allRight;
         EXIT;
       END;
     END;

     (* Entweder war der Puffer leer oder es muss auf ein LF getestet
      * werden, deswegen neuen Puffer einlesen und evtl. ein CR als
      * erstes Zeichen in den neuen Puffer rueberretten.
      *)
     fillBuf(tstLF);
     IF readSize = 0 THEN
       (* Datei ist leer, es musste nicht auf ein LF getestet werden. *)
       r := IOConsts.endOfInput;
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Datei ist zuende, nur das erneut gepufferte CR ist vorhanden,
        * also wird dieses als normales Zeichen gelesen.
        *)
       r := IOConsts.allRight;
       EXIT;
     END;
     (* Es wurde mindestens ein neues Zeichen eingelesen, Tests wiederholen *)
   END; (* LOOP *)

   looked  := TRUE;
   c       := ch;
   lookCh  := ch;
   lookRes := r;
   res     := r;
 END; (* WITH *)
 stdInChan.result := r;
END inLook;

(*---------------------------------------------------------------------------*)

PROCEDURE inSkip ((* -- / -- *) tid : DeviceTablePtr );
(* Ablauf wie 'Look' *)
VAR __REG__ left  : UNSIGNEDWORD;
            tstLF : BOOLEAN;

BEGIN
 WITH stdInChanData DO
   IF looked THEN
     IF lookRes = IOConsts.endOfInput THEN
       stdInChan.errNum := EIO;
       raiseEOF;
     END;
     looked := FALSE;
     INC(rpos, skipSize);
     stdInChan.result := IOConsts.allRight;
     RETURN;
   END;

   LOOP
     tstLF := FALSE;
     IF rpos < readSize THEN
       left := readSize - rpos;
     ELSE
       left := 0;
     END;

     IF left > 0 THEN
       IF istty OR (rbuf[rpos] # types.CR) THEN
         (* Bei Terminals werden nur Einzelzeichen betrachtet *)
         EXIT;
       ELSIF left = 1 THEN
         (* Nur CR im Puffer -> auf LF testen *)
         tstLF := TRUE;
       ELSIF rbuf[rpos+1] = types.LF THEN
         (* Nur im Fall CR+LF muessen zwei Bytes uebersprungen werden *)
         INC(rpos);
         EXIT;
       ELSE
         (* CR als normales Zeichen *)
         EXIT;
       END;
     END;

     fillBuf(tstLF);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       stdInChan.result := IOConsts.endOfInput;
       RETURN;
     END;
#endif
     IF readSize = 0 THEN
       stdInChan.errNum := EIO;
       raiseEOF;
     ELSIF tstLF & (readSize = 1) THEN
       EXIT;
     END;
   END; (* LOOP *)
   INC(rpos);
 END; (* WITH *)

 stdInChan.result := IOConsts.allRight;
END inSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE inSkipLook ((* -- / -- *)     tid : DeviceTablePtr;
                      (* -- /AUS *) VAR c   : CHAR;
                      (* -- /AUS *) VAR res : IOConsts.ReadResults );


VAR __REG__ left  : UNSIGNEDWORD;
    __REG__ ch    : CHAR;
    __REG__ r     : IOConsts.ReadResults;
            tstLF : BOOLEAN;

BEGIN
 WITH stdInChanData DO
   IF looked THEN
     IF lookRes = IOConsts.endOfInput THEN
       stdInChan.errNum := EIO;
       raiseEOF;
     END;
     INC(rpos, skipSize);
   ELSE
     inSkip(tid);
   END;

   skipSize := 1;
   r        := IOConsts.endOfLine;
   LOOP
     tstLF := FALSE;
     IF rpos < readSize THEN
       left := readSize - rpos;
     ELSE
       left := 0;
     END;

     IF left = 0 THEN
       ch := 0C;
     ELSE
       ch := rbuf[rpos];
       IF ch = types.CR THEN
         IF istty THEN
           (* Bei Terminals gilt auch CR alleine als Zeilenende *)
           EXIT;
         ELSIF left = 1 THEN
           (* Letztes Zeichen im Puffer ist ein CR; deshalb neuen Puffer
            * einlesen, um zu testen ob ein LF folgt. Bei einem Terminal
            * ist das nicht noetig, da CR auf jeden Fall ein Zeilenende
            * kennzeichnet, auch wenn dahinter kein LF folgt.
            *)
           tstLF := TRUE;
         ELSIF rbuf[rpos+1] = types.LF THEN
           (* LF und CR+LF gelten als Zeilenende *)
           skipSize := 2;
           EXIT;
         END;
       ELSIF ch = types.LF THEN
         (* LF ist auf jeden Fall ein Zeilenende *)
         EXIT;
       ELSE
         (* Normales Zeichen gelesen. *)
         r := IOConsts.allRight;
         EXIT;
       END;
     END;

     (* Entweder war der Puffer leer oder es muss auf ein LF getestet
      * werden, deswegen neuen Puffer einlesen und evtl. ein CR als
      * erstes Zeichen in den neuen Puffer rueberretten.
      *)
     fillBuf(tstLF);
     IF readSize = 0 THEN
       (* Datei ist leer, es musste nicht auf ein LF getestet werden. *)
       r := IOConsts.endOfInput;
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Datei ist zuende, nur das erneut gepufferte CR ist vorhanden,
        * also wird dieses als normales Zeichen gelesen.
        *)
       r := IOConsts.allRight;
       EXIT;
     END;
     (* Es wurde mindestens ein neues Zeichen eingelesen, Tests wiederholen *)
   END; (* LOOP *)

   looked  := TRUE;
   c       := ch;
   lookCh  := ch;
   lookRes := r;
   res     := r;
 END;
 stdInChan.result := r;
END inSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE inTextRead ((* -- / -- *)     tid  : DeviceTablePtr;
                      (* EIN/ -- *)     to   : ADDRESS;
                      (* EIN/ -- *)     size : UNSIGNED;
                      (* -- /AUS *) VAR read : UNSIGNED       );


VAR __REG__ left  : UNSIGNED; (* Anzahl ungelesener Bytes im Puffer *)
    __REG__ cnt   : UNSIGNED;
    __REG__ tstLF : BOOLEAN;  (* Letztes Byte im Puffer gleich CR? *)
            eol   : BOOLEAN;
            nl    : CharPtr;
            lf    : CharPtr;
            cr    : CharPtr;

BEGIN
 read := 0;
 IF size = VAL(UNSIGNED,0) THEN
   stdInChan.result := IOConsts.allRight;
   RETURN;
 END;

 eol := FALSE;
 WITH stdInChanData DO
   looked   := FALSE;
   skipSize := 1;
   LOOP
     tstLF := FALSE;
     IF rpos < readSize THEN
       left := VAL(UNSIGNED,readSize - rpos);
     ELSE
       left := 0;
     END;

     IF left > VAL(UNSIGNED,0) THEN
       (* Es gibt noch ungelesene Bytes im Puffer, also soviel uebertragen
        * wie noetig, aber nicht mehr als vorhanden.
        *)
       IF size <= left THEN
         cnt := size;
       ELSE
         cnt := left;
       END;

       IF istty THEN
         lf := blk.memchr(ADR(rbuf[rpos]), ORD(types.LF), cnt);
         cr := blk.memchr(ADR(rbuf[rpos]), ORD(types.CR), cnt);
         IF lf = NULL THEN
           nl := cr;
         ELSIF cr = NULL THEN
           nl := lf;
         ELSIF DIFADR(cr, lf) < VAL(SIGNEDLONG,0) THEN
           nl := cr;
         ELSE
           nl := lf;
         END;

         IF nl # NULL THEN
           (* Zeilenende gefunden, cnt: Anzahl der Bytes davor *)
           eol := TRUE;
           cnt := VAL(UNSIGNED,DIFADR(nl, ADR(rbuf[rpos])));
         END;
       ELSE
         IF cnt = left THEN
           (* Bis zum Ende des Puffers nach einem Zeilenende suchen *)
           nl    := blk.memchr(ADR(rbuf[rpos]), ORD(types.LF), cnt);
           tstLF := rbuf[readSize-1] = types.CR;
         ELSE (* cnt < left *)
           (* Nach einem Zeilenende suchen, bis ein Zeichen hinter dem letzten
            * gewuenschten, damit ein Zeilenende auch erkannt wird, wenn das
            * letzte gewuenschte Zeichen das CR eines CR+LF-Zeilenendes ist.
            *)
           nl    := blk.memchr(ADR(rbuf[rpos]), ORD(types.LF), cnt + VAL(UNSIGNED,1));
           tstLF := FALSE;
         END;

         IF nl # NULL THEN
           (* Zeilenende gefunden, cnt: Anzahl der Bytes
            * vor dem LF. Falls dieses LF nur durch die Vergroesserung
            * des Suchgebiets um Eins gefunden wurde, koennen alle verlangten
            * Bytes uebertragen werden, es sei denn, vor dem LF steht noch
            * ein CR.
            *)
           eol := TRUE;
           cnt := VAL(UNSIGNED,DIFADR(nl, ADR(rbuf[rpos])));
           IF (cnt > VAL(UNSIGNED,0)) & (rbuf[rpos+VAL(UNSIGNEDWORD,cnt)-1] = types.CR) THEN
             (* Zeilenende besteht aus CR+LF, das CR wird nicht gelesen *)
             skipSize := 2;
             DEC(cnt);
           END;
         ELSIF tstLF THEN
           (* CR nochmal mit dem naechsten Puffer lesen *)
           DEC(cnt);
         END;
       END;

       IF cnt > VAL(UNSIGNED,0) THEN
         blk.memmove(to, ADR(rbuf[rpos]), cnt);
         DEC(size, cnt);
         INC(read, cnt);
         INC(rpos, VAL(UNSIGNEDWORD,cnt));
         to := ADDADR(to, cnt);
       END;
     END;
     IF eol OR (size = VAL(UNSIGNED,0)) THEN
       EXIT;
     END;
     fillBuf(tstLF);
     IF readSize = 0 THEN
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Das erneut gepufferte CR ist das einzige Zeichen *)
       nl  := to;
       nl^ := types.CR;
       INC(rpos);
       INC(read);
       EXIT;
     END;
   END; (* LOOP *)

   IF read = VAL(UNSIGNED,0) THEN
     looked := TRUE;
     IF eol THEN
       lookRes          := IOConsts.endOfLine;
       stdInChan.result := IOConsts.endOfLine;
     ELSE
       lookRes          := IOConsts.endOfInput;
       stdInChan.result := IOConsts.endOfInput;
     END;
   ELSE
     stdInChan.result := IOConsts.allRight;
   END;
 END; (* WITH chanP^ *)
END inTextRead;

(*---------------------------------------------------------------------------*)

PROCEDURE inRawRead ((* -- / -- *)     tid  : DeviceTablePtr;
                     (* EIN/ -- *)     to   : ADDRESS;
                     (* EIN/ -- *)     size : UNSIGNED;
                     (* -- /AUS *) VAR read : UNSIGNED       );


VAR nRead : types.ssizeT;
    exc   : ChanExceptions;

PROCEDURE readBuf;

VAR __REG__ left : UNSIGNED;
    __REG__ cnt  : UNSIGNED;

BEGIN (* readBuf *)
 WITH stdInChanData DO
   (* Anzahl ungelesener Bytes im Puffer *)
   IF rpos < readSize THEN
     left := VAL(UNSIGNED,readSize - rpos);
   ELSE
     left := 0;
   END;

   IF left > VAL(UNSIGNED,0) THEN
     (* Es gibt noch ungelesene Bytes im Puffer, also soviel uebertragen
      * wie noetig, aber nicht mehr als vorhanden.
      *)
     IF size <= left THEN
       cnt := size;
     ELSE
       cnt := left;
     END;
     blk.memmove(to, ADR(rbuf[rpos]), VAL(types.sizeT,cnt));
     DEC(size, cnt);
     INC(read, cnt);
     INC(rpos, VAL(UNSIGNEDWORD,cnt));
     to := ADDADR(to, cnt);
   END;
 END; (* WITH *)
END readBuf;

BEGIN
 read := 0;
 IF size = VAL(UNSIGNED,0) THEN
   stdInChan.result := IOConsts.allRight;
   RETURN;
 END;

 WITH stdInChanData DO
   looked := FALSE;
   (* Zuerst verbleibende Bytes aus dem Puffer uebertragen *)
   readBuf;
   IF size > VAL(UNSIGNED,0) THEN
     (* Reicht noch nicht, aber Puffer zuende *)
     IF size < VAL(UNSIGNED,RBUFSIZE) THEN
       (* Wenn weniger Bytes als die Puffergroesse benoetigt werden,
        * wird der Puffer aufgefuellt, und die Bytes von dort
        * uebertragen.
        *)
       fillBuf(FALSE);
       readBuf;
     ELSE
       (* Wenn mehr als die Puffergroesse benoetigt wird, werden die
        * Bytes direkt ins Ziel uebertragen; Puffer als frei kennzeichnen.
        *)
       rpos     := 0;
       readSize := 0;
       nRead    := file.read(rhandle, to, VAL(types.sizeT,size));
       IF nRead >= VAL(types.ssizeT,0) THEN
         INC(read, VAL(UNSIGNED,nRead));
       ELSE
         stdInChan.errNum := errno;
#ifndef __NO_IO_EXCEPTIONS__
         IF read = VAL(UNSIGNED,0) THEN
           (* Wenn noch nichts gelesen wurde, ist ein RETRY moeglich *)
           exc := softDeviceError;
         ELSE
           exc := hardDeviceError;
         END;
         EXCEPTIONS.RAISE(iolibSource, ORD(exc),
                          "StdInChan: 'RawRead' failed");
#endif
       END;
     END; (* IF size < RBUFSIZE *)
   END; (* IF size > 0 *)
 END; (* WITH chanP^ *)

 IF read = VAL(UNSIGNED,0) THEN
   stdInChan.result := IOConsts.endOfInput;
 ELSE
   stdInChan.result := IOConsts.allRight;
 END;
END inRawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE inName ((* -- / -- *)     tid  : DeviceTablePtr;
                  (* -- /AUS *) VAR name : ARRAY OF CHAR  );
BEGIN
 ISOStrings.Assign("StdInChan", name);
END inName;

(*===========================================================================*)
(* Geraeteprozeduren fuer den 'StdOut'-Kanal                                 *)
(*===========================================================================*)

PROCEDURE outSkip ((* -- / -- *) tid : DeviceTablePtr );
BEGIN
 raiseRead;
END outSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE outLook ((* -- / -- *)     tid : DeviceTablePtr;
                   (* -- / -- *) VAR ch  : CHAR;
                   (* -- / -- *) VAR res : IOConsts.ReadResults );
BEGIN
 raiseRead;
END outLook;

(*---------------------------------------------------------------------------*)

PROCEDURE outRead ((* -- / -- *)     tid  : DeviceTablePtr;
                   (* -- / -- *)     to   : ADDRESS;
                   (* -- / -- *)     size : UNSIGNED;
                   (* -- / -- *) VAR read : UNSIGNED       );
BEGIN
 raiseRead;
END outRead;

(*---------------------------------------------------------------------------*)

PROCEDURE outFlush ((* -- / -- *) tid : DeviceTablePtr );

VAR __REG__ nWritten : types.ssizeT;
            exc      : ChanExceptions;

BEGIN
 WITH stdOutChanData DO
   IF dirty THEN
     (* Falls in den Puffer geschrieben wurde, wird er bis zur aktuellen
      * Schreibposition zurueckgeschrieben.
      *)
     nWritten := file.write(whandle, ADR(wbuf), VAL(types.sizeT,wpos));
     IF nWritten # VAL(types.ssizeT,wpos) THEN
       error := TRUE;
       IF nWritten < VAL(types.ssizeT,0) THEN
         stdOutChan.errNum := errno;
       ELSE
         stdOutChan.errNum := ENOSPC;
       END;
#ifdef __NO_IO_EXCEPTIONS__
       RETURN;
#else
       IF nWritten <= VAL(types.ssizeT,0) THEN
         exc := softDeviceError;
         (* Es ist ein RETRY moeglich, da noch nichts geschrieben
          * und der Schreibzeiger der Datei nicht veraendert wurde.
          *)
       ELSE
         exc := hardDeviceError;
       END;
       EXCEPTIONS.RAISE(iolibSource, ORD(exc), "StdOutChan: 'Flush' failed");
#endif
     END;
     (* Puffer ist jetzt leer *)
     wpos  := 0;
     dirty := FALSE;
   END;
   error := FALSE;
 END;
END outFlush;

(*---------------------------------------------------------------------------*)

PROCEDURE outRawWrite ((* -- / -- *) tid  : DeviceTablePtr;
                       (* EIN/ -- *) from : ADDRESS;
                       (* EIN/ -- *) size : UNSIGNED       );

VAR written  : BOOLEAN;
    nWritten : types.ssizeT;
    exc      : ChanExceptions;

PROCEDURE writeBuf;

VAR __REG__ cnt   : UNSIGNED;
    __REG__ space : UNSIGNED; (* Platz im Puffer *)

BEGIN (* writeBuf *)
 WITH stdOutChanData DO
   space := VAL(UNSIGNED,WBUFSIZE - wpos);
   IF space > VAL(UNSIGNED,0) THEN
     written := TRUE;
     dirty   := TRUE;
     IF size <= space THEN
       cnt := size;
     ELSE
       cnt := space;
     END;
     blk.memmove(ADR(wbuf[wpos]), from, VAL(types.sizeT,cnt));
     DEC(size, cnt);
     INC(wpos, VAL(UNSIGNEDWORD,cnt));
     from := ADDADR(from, cnt);
   END;
 END;
END writeBuf;

BEGIN
 IF size = VAL(UNSIGNED,0) THEN
   RETURN;
 END;

 written := FALSE;
 WITH stdOutChanData DO
   (* Zuerst Puffer fuellen *)
   writeBuf;
   IF size > VAL(UNSIGNED,0) THEN
     (* Noch nicht alles uebertragen,
      * vollen Puffer mit Datei synchronisieren.
      *)
     outFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       RETURN;
     END;
#endif
     IF size <= VAL(UNSIGNED,WBUFSIZE) THEN
       (* Rest passt in den Puffer *)
       writeBuf;
     ELSE
       (* Sonst direkt die Quelle schreiben *)
       nWritten := file.write(whandle, from, VAL(types.sizeT,size));
       IF nWritten # VAL(types.ssizeT,size) THEN
         stdOutChan.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
         RETURN;
#else
         IF ~written & (nWritten = VAL(types.ssizeT,0)) THEN
           (* Wenn noch nichts geschrieben wurde, ist ein RETRY moeglich *)
           exc := softDeviceError;
         ELSE
           exc := hardDeviceError;
         END;
         EXCEPTIONS.RAISE(iolibSource, ORD(exc), "StdOutChan: 'Write' failed");
#endif
       END;
     END;
   END;
   IF istty & flushBuf THEN
     (* Terminal ist zeilenweise gepuffert *)
     outFlush(tid);
     flushBuf := FALSE;
   END;
 END;
END outRawWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE outTextWrite ((* -- / -- *) tid  : DeviceTablePtr;
                        (* EIN/ -- *) from : ADDRESS;
                        (* EIN/ -- *) size : UNSIGNED       );

VAR __REG__ cnt      : UNSIGNED;
    __REG__ tmp      : UNSIGNED;
            written  : BOOLEAN;
            expandLF : BOOLEAN;
            exc      : ChanExceptions;
            nWritten : types.ssizeT;
            lf       : CharPtr;

BEGIN
 written := FALSE;
 WITH stdOutChanData DO
   WHILE size > VAL(UNSIGNED,0) DO
     (* Erstes LF suchen, dem kein CR vorangeht. *)
     tmp      := size;
     cnt      := 0;
     expandLF := FALSE;
     REPEAT
       lf := blk.memchr(ADDADR(from, cnt), ORD(types.LF), tmp);
       IF lf # NULL THEN
         cnt := VAL(UNSIGNED,DIFADR(lf, from));
         lf  := SUBADR(lf, 1);
         IF (cnt = VAL(UNSIGNED,0)) OR (lf^ # types.CR) THEN
           expandLF := TRUE;
         ELSE
           INC(cnt); (* LF ueberspringen *)
           tmp := size - cnt;
         END;
         flushBuf := TRUE;
       END;
     UNTIL expandLF OR (lf = NULL) OR (tmp = VAL(UNSIGNED,0));

     IF expandLF THEN
       (* Unveraenderte Bytes + CR + LF *)
       tmp := cnt + VAL(UNSIGNED,2);
     ELSE
       (* Alles unveraendert uebertragen *)
       cnt := size;
       tmp := cnt;
     END;
     (* cnt: Anzahl der unveraendert zu uebertragenden Bytes.
      * tmp: 'cnt' plus evtl. CR/LF fuer Test des Pufferplatzes.
      *)

     IF tmp > VAL(UNSIGNED,WBUFSIZE - wpos) THEN
       (* Es passt nicht alles in den Puffer, deswegen den Puffer erstmal
        * leeren.
        *)
       outFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         RETURN;
       END;
#endif
     END;
     IF cnt > VAL(UNSIGNED,0) THEN
       IF tmp <= VAL(UNSIGNED,WBUFSIZE) THEN
         (* Es passt (nun) alles in den Puffer *)
         blk.memmove(ADR(wbuf[wpos]), from, VAL(types.sizeT,cnt));
         INC(wpos, VAL(UNSIGNEDWORD,cnt));
         dirty   := TRUE;
         written := TRUE;
       ELSE
         (* Sonst direkt die Quelle schreiben. Die Variablen des Puffers
          * ('pos' und 'dirty') wurden durch 'Flush' geloescht.
          *)
         nWritten := file.write(whandle, from, VAL(types.sizeT,cnt));
         IF nWritten = VAL(types.ssizeT,cnt) THEN
           written := TRUE;
         ELSE
           stdOutChan.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
           RETURN;
#else
           IF ~written & (nWritten = VAL(types.ssizeT,0)) THEN
             (* Wenn noch nichts geschrieben wurde, ist ein RETRY moeglich *)
             exc := softDeviceError;
           ELSE
             exc := hardDeviceError;
           END;
           EXCEPTIONS.RAISE(iolibSource, ORD(exc),
                            "StdOutChan: 'Write' failed");
#endif
         END;
       END;
       DEC(size, cnt);
     END;

     IF expandLF THEN
       INC(cnt); (* LF in der Quelle ueberspringen *)
       DEC(size);
       from := ADDADR(from, cnt);
       (* CR + LF in den Puffer schreiben; es ist sichergestellt, dass
        * Platz dafuer vorhanden ist.
        *)
       wbuf[wpos] := types.CR; INC(wpos);
       wbuf[wpos] := types.LF; INC(wpos);
       dirty      := TRUE;
       written    := TRUE;
     END;
   END; (* WHILE size > 0 *)

   IF istty & flushBuf THEN
     (* Terminal ist zeilenweise gepuffert *)
     outFlush(tid);
     flushBuf := FALSE;
   END;
 END; (* WITH *)
END outTextWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE outWriteLn ((* -- / -- *) tid : DeviceTablePtr );
BEGIN
 stdOutChanData.flushBuf := TRUE;
 stdOutChan.doTextWrite(tid, ADR(nl), 1);
END outWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE outName ((* -- / -- *)     tid  : DeviceTablePtr;
                   (* -- /AUS *) VAR name : ARRAY OF CHAR  );

BEGIN
 ISOStrings.Assign("StdOutChan", name);
END outName;

(*===========================================================================*)
(* Ungepufferte Geraeteprozeduren fuer den 'StdErr'-Kanal                    *)
(*===========================================================================*)

PROCEDURE readChar ((* -- /AUS *) VAR ch   : CHAR;
                    (* -- /AUS *) VAR done : BOOLEAN );

VAR nRead : types.ssizeT;

BEGIN
 WITH stdErrChanData DO
   nRead := file.read(file.StderrFileNo, ADR(ch), VAL(types.sizeT,1));
   IF nRead >= VAL(types.ssizeT,0) THEN
     (* Null ist auch OK, dann ist das Dateiende erreicht *)
     done  := nRead > VAL(types.ssizeT,0);
     error := FALSE;
   ELSE
     done  := FALSE;
     error := TRUE;
     stdErrChan.errNum := errno;
#ifndef __NO_IO_EXCEPTIONS__
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError),
                      "StdErrChan: 'Read' failed");
#endif
   END;
 END;
END readChar;

(*---------------------------------------------------------------------------*)

PROCEDURE writeChar ((* EIN/ -- *) ch : CHAR );

VAR nWritten : types.ssizeT;

BEGIN
 WITH stdErrChanData DO
   nWritten := file.write(file.StderrFileNo, ADR(ch), VAL(types.sizeT,1));
   IF nWritten = VAL(types.ssizeT,1) THEN
     error := FALSE;
   ELSE
     error := TRUE;
     IF nWritten < VAL(types.ssizeT,0) THEN
       stdErrChan.errNum := errno;
     ELSE
       stdErrChan.errNum := ENOSPC;
     END;
#ifndef __NO_IO_EXCEPTIONS__
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError),
                      "StdErrChan: 'Write' failed");
#endif
   END;
 END;
END writeChar;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufLook ((* -- / -- *)     tid : DeviceTablePtr;
                     (* -- /AUS *) VAR c   : CHAR;
                     (* -- /AUS *) VAR res : IOConsts.ReadResults );

VAR __REG__ left  : UNSIGNEDWORD;
    __REG__ ch    : CHAR;
    __REG__ r     : IOConsts.ReadResults;
            tstLF : BOOLEAN;
            done  : BOOLEAN;

BEGIN
 WITH stdErrChanData DO
   r := IOConsts.endOfLine;
   LOOP
     tstLF := FALSE;
     IF pos < readSize THEN
       left := readSize - pos;
     ELSE
       left := 0;
     END;

     IF left = 0 THEN
       ch := 0C;
     ELSE
       ch := buf[pos];
       IF ch = types.CR THEN
         IF istty THEN
           (* Bei Terminals gilt auch CR alleine als Zeilenende *)
           EXIT;
         ELSIF left = 1 THEN
           (* Letztes Zeichen im Puffer ist ein CR; deshalb neuen Puffer
            * einlesen, um zu testen ob ein LF folgt. Bei einem Terminal
            * ist das nicht noetig, da CR auf jeden Fall ein Zeilenende
            * kennzeichnet, auch wenn dahinter kein LF folgt.
            *)
           tstLF := TRUE;
         ELSIF buf[pos+1] = types.LF THEN
           (* LF und CR+LF gelten als Zeilenende *)
           EXIT;
         END;
       ELSIF ch = types.LF THEN
         (* LF ist auf jeden Fall ein Zeilenende *)
         EXIT;
       ELSE
         (* Normales Zeichen gelesen. *)
         r := IOConsts.allRight;
         EXIT;
       END;
     END;

     pos := 0;
     IF tstLF THEN
       buf[0]   := types.CR;
       readSize := 1;
       readChar(buf[1], done);
     ELSE
       readSize := 0;
       readChar(buf[0], done);
     END;
     IF done THEN
       INC(readSize);
     END;

     IF readSize = 0 THEN
       (* Datei ist leer, es musste nicht auf ein LF getestet werden. *)
       r := IOConsts.endOfInput;
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Datei ist zuende, nur das erneut gepufferte CR ist vorhanden,
        * also wird dieses als normales Zeichen gelesen.
        *)
       r := IOConsts.allRight;
       EXIT;
     END;
   END; (* LOOP *)
 END; (* WITH *)

 c                 := ch;
 res               := r;
 stdErrChan.result := r;
END unbufLook;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufSkip ((* -- / -- *) tid : DeviceTablePtr );
(* leicht abgewandeltes 'bufSkip' *)
VAR __REG__ left  : UNSIGNEDWORD;
            tstLF : BOOLEAN;
            done  : BOOLEAN;

BEGIN
 WITH stdErrChanData DO
   LOOP
     tstLF := FALSE;
     IF pos < readSize THEN
       left := readSize - pos;
     ELSE
       left := 0;
     END;

     IF left > 0 THEN
       IF istty OR (buf[pos] # types.CR) THEN
         (* Bei Terminals werden nur Einzelzeichen betrachtet *)
         EXIT;
       ELSIF left = 1 THEN
         (* Nur CR im Puffer -> auf LF testen *)
         tstLF := TRUE;
       ELSIF buf[pos+1] = types.LF THEN
         (* Nur im Fall CR+LF muessen zwei Bytes uebersprungen werden *)
         INC(pos);
         EXIT;
       ELSE
         (* CR als normales Zeichen *)
         EXIT;
       END;
     END;

     pos := 0;
     IF tstLF THEN
       buf[0]   := types.CR;
       readSize := 1;
       readChar(buf[1], done);
     ELSE
       readSize := 0;
       readChar(buf[0], done);
     END;
     IF done THEN
       INC(readSize);
     END;
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       stdErrChan.result := IOConsts.endOfInput;
       RETURN;
     END;
#endif
     IF readSize = 0 THEN
       stdErrChan.errNum := EIO;
       raiseEOF;
     ELSIF tstLF & (readSize = 1) THEN
       EXIT;
     END;
   END; (* LOOP *)
   INC(pos);
 END; (* WITH *)

 stdErrChan.result := IOConsts.allRight;
END unbufSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufSkipLook ((* -- / -- *)     tid : DeviceTablePtr;
                         (* -- /AUS *) VAR ch  : CHAR;
                         (* -- /AUS *) VAR res : IOConsts.ReadResults );

BEGIN
 unbufSkip(tid);
 unbufLook(tid, ch, res);
END unbufSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufRawRead ((* -- / -- *)     tid       : DeviceTablePtr;
                        (* EIN/ -- *)     to        : ADDRESS;
                        (* EIN/ -- *)     maxChars  : UNSIGNED;
                        (* -- /AUS *) VAR charsRead : UNSIGNED       );

VAR adr  : CharPtr;
    done : BOOLEAN;

BEGIN
 charsRead := 0;
 IF maxChars = VAL(UNSIGNED,0) THEN
   stdErrChan.result := IOConsts.allRight;
   RETURN;
 END;

 adr := to;
 REPEAT
   readChar(adr^, done);
   IF done THEN
     adr := ADDADR(adr, 1);
     INC(charsRead);
   END;
 UNTIL ~done OR (charsRead = maxChars);

 IF charsRead = VAL(UNSIGNED,0) THEN
   stdErrChan.result := IOConsts.endOfInput;
 ELSE
   stdErrChan.result := IOConsts.allRight;
 END;
END unbufRawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufTextRead ((* -- / -- *)     tid       : DeviceTablePtr;
                         (* EIN/ -- *)     to        : ADDRESS;
                         (* EIN/ -- *)     maxChars  : UNSIGNED;
                         (* -- /AUS *) VAR charsRead : UNSIGNED       );

VAR res : IOConsts.ReadResults;
    ch  : CHAR;
    adr : CharPtr;

BEGIN
 charsRead := 0;
 IF maxChars = VAL(UNSIGNED,0) THEN
   stdErrChan.result := IOConsts.allRight;
   RETURN;
 END;

 adr := to;
 unbufLook(tid, ch, res);
 WHILE (charsRead < maxChars) & (res = IOConsts.allRight) DO
   adr^ := ch;
   adr  := ADDADR(adr, 1);
   INC(charsRead);
   unbufSkip(tid);
   unbufLook(tid, ch, res);
 END;

 IF charsRead = VAL(UNSIGNED,0) THEN
   stdErrChan.result := res;
 ELSE
   stdErrChan.result := IOConsts.allRight;
 END;
END unbufTextRead;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufRawWrite ((* -- / -- *) tid          : DeviceTablePtr;
                         (* EIN/ -- *) from         : ADDRESS;
                         (* EIN/ -- *) charsToWrite : UNSIGNED       );

VAR adr : CharPtr;

BEGIN
 adr := from;
 WHILE charsToWrite > VAL(UNSIGNED,0) DO
   writeChar(adr^);
#ifdef __NO_IO_EXCEPTIONS__
   IF stdErrChanData.error THEN
     RETURN;
   END;
#endif
   adr := ADDADR(adr, 1);
   DEC(charsToWrite);
 END;
END unbufRawWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE unbufTextWrite ((* -- / -- *) tid          : DeviceTablePtr;
                          (* EIN/ -- *) from         : ADDRESS;
                          (* EIN/ -- *) charsToWrite : UNSIGNED       );

VAR adr : CharPtr;
    c   : CHAR;
    cr  : BOOLEAN;

BEGIN
 adr := from;
 cr  := FALSE;
 WHILE charsToWrite > VAL(UNSIGNED,0) DO
   c := adr^;
   IF (c = types.LF) & ~cr THEN
     writeChar(types.CR);
#ifdef __NO_IO_EXCEPTIONS__
     IF stdErrChanData.error THEN
       RETURN;
     END;
#endif
   ELSE
     cr := c = types.CR;
   END;
   writeChar(c);
#ifdef __NO_IO_EXCEPTIONS__
   IF stdErrChanData.error THEN
     RETURN;
   END;
#endif
   adr := ADDADR(adr, 1);
   DEC(charsToWrite);
 END;
END unbufTextWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE errWriteLn ((* -- / -- *) tid : DeviceTablePtr );
BEGIN
 stdErrChan.doTextWrite(tid, ADR(nl), 1);
END errWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE errName ((* -- / -- *)     tid  : DeviceTablePtr;
                   (* -- /AUS *) VAR name : ARRAY OF CHAR  );

BEGIN
 ISOStrings.Assign("StdErrChan", name);
END errName;
#ifdef HM2
(*$E=*)
#endif

(*===========================================================================*)

BEGIN
 AllocateDeviceId(stdDevice);

 NullChanId   := ADR(nullChan);
 StdInChanId  := ADR(stdInChan);
 StdOutChanId := ADR(stdOutChan);
 StdErrChanId := ADR(stdErrChan);

 WITH stdInChanData DO
   istty    := term.isatty(file.StdinFileNo) > 0;
   error    := FALSE;
   rpos     := 0;
   readSize := 0;
   rhandle  := file.StdinFileNo;
   looked   := FALSE;
   lookRes  := IOConsts.notKnown;
   lookCh   := 0C;
   skipSize := 0;
   IF istty THEN
     INCL(stdInChan.flags, ChanConsts.interactiveFlag);
   END;
 END;
 WITH stdOutChanData DO
   istty    := term.isatty(file.StdoutFileNo) > 0;
   error    := FALSE;
   wpos     := 0;
   flushBuf := FALSE;
   dirty    := FALSE;
   whandle  := file.StdoutFileNo;
   IF istty THEN
     INCL(stdOutChan.flags, ChanConsts.interactiveFlag);
   END;
 END;
 WITH stdErrChanData DO
   istty    := term.isatty(file.StderrFileNo) > 0;
   error    := FALSE;
   pos      := 0;
   readSize := 0;
   IF istty THEN
     INCL(stdErrChan.flags, ChanConsts.interactiveFlag);
   END;
 END;

#if ISO_value_constructor
 nullChan := DeviceTable{
   NIL,
   stdDevice, CAST(ChanId,NullChanId),
   IOConsts.notKnown, 0,
   ChanConsts.FlagSet{ChanConsts.readFlag, ChanConsts.writeFlag,
                      ChanConsts.textFlag, ChanConsts.rawFlag},
   nullLook, noProc, nullSkipLook, noProc, nullRead, nullWrite, nullRead,
   nullWrite, nullName, noProc, noProc, noProc
 };
 stdInChan := DeviceTable{
   ADR(stdInChanData),
   stdDevice, CAST(ChanId,StdInChanId),
   IOConsts.notKnown, 0,
   ChanConsts.FlagSet{ChanConsts.readFlag,
                      ChanConsts.textFlag, ChanConsts.rawFlag},
   inLook, inSkip, inSkipLook, inWriteLn, inTextRead, inWrite,
   inRawRead, inWrite, inName, noProc, noProc, noProc
 };
 stdOutChan := DeviceTable{
   ADR(stdOutChanData),
   stdDevice, CAST(ChanId,StdOutChanId),
   IOConsts.notKnown, 0,
   ChanConsts.FlagSet{ChanConsts.writeFlag,
                      ChanConsts.textFlag, ChanConsts.rawFlag},
   outLook, outSkip, outLook, outWriteLn, outRead, outTextWrite,
   outRead, outRawWrite, outName, noProc, outFlush, noProc
 };
 stdErrChan := DeviceTable{
   ADR(stdErrChanData),
   stdDevice, CAST(ChanId,StdErrChanId),
   IOConsts.notKnown, 0,
   ChanConsts.FlagSet{ChanConsts.readFlag, ChanConsts.writeFlag,
                      ChanConsts.textFlag, ChanConsts.rawFlag},
   unbufLook, unbufSkip, unbufSkipLook, errWriteLn, unbufTextRead,
   unbufTextWrite, unbufRawRead, unbufRawWrite, errName, noProc, noProc,
   noProc
 };
 IF DosDir.BINIO THEN
   IF ~stdOutChanData.istty THEN
     stdOutChan.doTextWrite := outRawWrite;
   END;
   IF ~stdErrChanData.istty THEN
     stdErrChan.doTextWrite := unbufRawWrite;
   END;
 END;
#else
 WITH nullChan DO
   cd          := NIL;
   did         := stdDevice;
   cid         := CAST(ChanId,NullChanId);
   result      := IOConsts.notKnown;
   errNum      := 0;
   flags       := ChanConsts.FlagSet{ChanConsts.readFlag,
                                     ChanConsts.writeFlag,
                                     ChanConsts.textFlag,
                                     ChanConsts.rawFlag};
   doLook      := nullLook;
   doSkip      := noProc;
   doSkipLook  := nullSkipLook;
   doWriteLn   := noProc;
   doTextRead  := nullRead;
   doTextWrite := nullWrite;
   doRawRead   := nullRead;
   doRawWrite  := nullWrite;
   doGetName   := nullName;
   doReset     := noProc;
   doFlush     := noProc;
   doFree      := noProc;
 END;
 WITH stdInChan DO
   cd          := ADR(stdInChanData);
   did         := stdDevice;
   cid         := CAST(ChanId,StdInChanId);
   result      := IOConsts.notKnown;
   errNum      := 0;
   flags       := ChanConsts.FlagSet{ChanConsts.readFlag,
                                     ChanConsts.textFlag,
                                     ChanConsts.rawFlag};
   doLook      := inLook;
   doSkip      := inSkip;
   doSkipLook  := inSkipLook;
   doWriteLn   := inWriteLn;
   doTextRead  := inTextRead;
   doTextWrite := inWrite;
   doRawRead   := inRawRead;
   doRawWrite  := inWrite;
   doGetName   := inName;
   doReset     := noProc;
   doFlush     := noProc;
   doFree      := noProc;
 END;
 WITH stdOutChan DO
   cd          := ADR(stdOutChanData);
   did         := stdDevice;
   cid         := CAST(ChanId,StdOutChanId);
   result      := IOConsts.notKnown;
   errNum      := 0;
   flags       := ChanConsts.FlagSet{ChanConsts.writeFlag,
                                     ChanConsts.textFlag,
                                     ChanConsts.rawFlag};
   doLook      := outLook;
   doSkip      := outSkip;
   doSkipLook  := outLook;
   doWriteLn   := outWriteLn;
   doTextRead  := outRead;
   IF DosDir.BINIO & ~stdOutChanData.istty THEN
     doTextWrite := outRawWrite;
   ELSE
     doTextWrite := outTextWrite;
   END;
   doRawRead   := outRead;
   doRawWrite  := outRawWrite;
   doGetName   := outName;
   doReset     := noProc;
   doFlush     := outFlush;
   doFree      := noProc;
 END;
 WITH stdErrChan DO
   cd          := ADR(stdErrChanData);
   did         := stdDevice;
   cid         := CAST(ChanId,StdErrChanId);
   result      := IOConsts.notKnown;
   errNum      := 0;
   flags       := ChanConsts.FlagSet{ChanConsts.readFlag,
                                     ChanConsts.writeFlag,
                                     ChanConsts.textFlag,
                                     ChanConsts.rawFlag};
   doLook      := unbufLook;
   doSkip      := unbufSkip;
   doSkipLook  := unbufSkipLook;
   doWriteLn   := errWriteLn;
   doTextRead  := unbufTextRead;
   IF DosDir.BINIO & ~stdErrChanData.istty THEN
     doTextWrite := unbufRawWrite;
   ELSE
     doTextWrite := unbufTextWrite;
   END;
   doRawRead   := unbufRawRead;
   doRawWrite  := unbufRawWrite;
   doGetName   := errName;
   doReset     := noProc;
   doFlush     := noProc;
   doFree      := noProc;
 END;
#endif
 nl := types.LF;
END StdChanBase.

