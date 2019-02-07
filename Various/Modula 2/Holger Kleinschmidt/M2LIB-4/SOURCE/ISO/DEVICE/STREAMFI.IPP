IMPLEMENTATION MODULE StreamFile;
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

   Lesen mit "Skip/Look()" und "TextRead()":

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


   Schreiben mit "WriteLn()" und "TextWrite()":

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


   Lesen mit "RawRead()":

   Zuerst werden die noch im Puffer befindlichen Bytes gelesen. Reicht
   die Anzahl nicht aus, wird ueberprueft, ob weniger Bytes als
   die Puffergroesse zu lesen sind. Ist das der Fall, wird ein neuer
   Puffer eingelesen und die restlichen Bytes aus ihm gelesen, sonst
   werden die restlichen Bytes direkt aus der Datei gelesen.


   Schreiben mit "RawWrite()":

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
 * verlaufen, sonst enthaelt sie den Code von er.errno.
 * Die Geraeteprozeduren werden auf dem Umweg ueber die Prozeduren aus
 * IOChan aufgerufen, dort wird vorher errNum auf Null gesetzt.
 */
#define __NO_IO_EXCEPTIONS__
#endif

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'SIGNED' und 'UNSIGNED' koennen mittels CAST uminterpretiert
            werden, d.h. sie haben die gleiche Speichergroesse, oder CAST
            kann auch bei unterschiedlichen Groessen verwendet werden, und
            UNSIGNED ist groesser als SIGNED.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

VAL_INTRINSIC
CAST_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) MINSIGNED, MAXSIGNED, NULL,
(* TYPE *) UNSIGNED, SIGNED, UNSIGNEDWORD, UNSIGNEDLONG, SIGNEDLONG, ANYLONG;

FROM ISOStorage IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

IMPORT EXCEPTIONS;

FROM er IMPORT
(* CONST*) ENOSPC, EIO, EACCES, EROFS, ENFILE, EPERM, EMFILE, ENOTTY, EISDIR,
           ENOMEM, EEXIST, ENAMETOOLONG, ENOENT,
(* VAR  *) errno;

IMPORT DosDir, blk, types, ISOStrings, file, dir, term;

IMPORT IOConsts, ChanConsts;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM IOChan IMPORT
(* TYPE *) ChanExceptions,
(* PROC *) InvalidChan;

FROM IOLink IMPORT
(* TYPE *) DeviceId, DeviceTable, DeviceTablePtr,
(* PROC *) AllocateDeviceId, IsDevice, DeviceTablePtrValue, MakeChan,
           UnMakeChan;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

CONST
  StreamFileFlags = ChanConsts.FlagSet{ChanConsts.readFlag,
                                       ChanConsts.writeFlag,
                                       ChanConsts.oldFlag,
                                       ChanConsts.textFlag,
                                       ChanConsts.rawFlag};

#if 0
TYPE
  ChanId = DeviceTablePtr;
#endif

CONST
  MAXNAME = 255;

CONST
  RBUFSIZE = 1024;
  WBUFSIZE = 1024;

TYPE
  CharPtr = POINTER TO CHAR;

  streamFileDataP = POINTER TO streamFileData;
  streamFileData  = RECORD
(* Allgemein: *)
    fname : ARRAY [0..MAXNAME] OF CHAR;
      (* Dateiname *)
    istty : BOOLEAN;
      (* Flag: Datei ist ein (Pseudo)Terminal *)
    error : BOOLEAN;
      (* Flag: Fehler bei letzter I/O-Operation. Wird fuer die Kommunikation
       * zwischen den ``tieferen'' und ``hoeheren'' Prozeduren verwendet,
       * wenn bei IO-Fehlern keine Ausnahmen generiert werden.
       *)
    dirty : BOOLEAN;
      (* Flag: Puffer wurde beschrieben *)

(* Fuers Lesen: *)
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



(* Fuers Schreiben: *)
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
    whandle : INTEGER;
      (* Dateikennung des Betriebssystems *)
  END;


VAR
  streamDevice     : DeviceId;
  streamFileSource : EXCEPTIONS.ExceptionSource;
  badChanId        : ChanId;
  nl               : CHAR;

(*===========================================================================*)
(* Geraeteoperationen                                                        *)
(*===========================================================================*)

PROCEDURE raiseEOF;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(skipAtEnd),
                  "StreamFile: 'Skip/Look' at end of file");
END raiseEOF;

(*---------------------------------------------------------------------------*)

PROCEDURE fillBuf ((* EIN/ -- *) tid   : DeviceTablePtr;
                   (* EIN/ -- *) addCR : BOOLEAN );
(* Leeren Puffer fuellen *)
VAR         nRead : types.ssizeT;
    __REG__ start : UNSIGNEDWORD;
            chanP : streamFileDataP;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
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
       error       := TRUE;
       tid^.errNum := errno;
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
PROCEDURE streamFlush ((* EIN/ -- *) tid : DeviceTablePtr );

VAR         chanP    : streamFileDataP;
    __REG__ nWritten : types.ssizeT;
            exc      : ChanExceptions;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE; (* sicherheitshalber *)
   error  := FALSE;
   IF dirty THEN
     (* Falls in den Puffer geschrieben wurde, wird er bis zur aktuellen
      * Schreibposition zurueckgeschrieben.
      *)
     nWritten := file.write(whandle, ADR(wbuf), VAL(types.sizeT,wpos));
     IF nWritten # VAL(types.ssizeT,wpos) THEN
       error := TRUE;
       IF nWritten < VAL(types.ssizeT,0) THEN
         tid^.errNum := errno;
       ELSE
         tid^.errNum := ENOSPC;
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
       EXCEPTIONS.RAISE(iolibSource, ORD(exc), "StreamFile: 'Flush' failed");
#endif
     END;
     (* Puffer ist jetzt leer *)
     wpos  := 0;
     dirty := FALSE;
   END;
 END;
END streamFlush;

(*---------------------------------------------------------------------------*)

PROCEDURE streamLook ((* EIN/ -- *)     tid : DeviceTablePtr;
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
            chanP : streamFileDataP;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
   IF looked THEN
     c           := lookCh;
     res         := lookRes;
     tid^.result := lookRes;
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
     fillBuf(tid, tstLF);
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

   looked      := TRUE;
   c           := ch;
   lookCh      := ch;
   lookRes     := r;
   res         := r;
   tid^.result := r;
 END; (* WITH *)
END streamLook;

(*---------------------------------------------------------------------------*)

PROCEDURE streamSkip ((* EIN/ -- *) tid : DeviceTablePtr );
(* Ablauf wie 'Look' *)
VAR __REG__ left  : UNSIGNEDWORD;
            tstLF : BOOLEAN;
            chanP : streamFileDataP;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
   IF looked THEN
     IF lookRes = IOConsts.endOfInput THEN
       tid^.errNum := EIO;
       raiseEOF;
     END;
     INC(rpos, skipSize);
     looked      := FALSE;
     tid^.result := IOConsts.allRight;
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

     fillBuf(tid, tstLF);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       tid^.result := IOConsts.endOfInput;
       RETURN;
     END;
#endif
     IF readSize = 0 THEN
       tid^.errNum := EIO;
       raiseEOF;
     ELSIF tstLF & (readSize = 1) THEN
       EXIT;
     END;
   END; (* LOOP *)
   INC(rpos);
 END; (* WITH *)

 tid^.result := IOConsts.allRight;
END streamSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE streamSkipLook ((* EIN/ -- *)     tid : DeviceTablePtr;
                          (* -- /AUS *) VAR c   : CHAR;
                          (* -- /AUS *) VAR res : IOConsts.ReadResults );

VAR __REG__ left  : UNSIGNEDWORD;
    __REG__ ch    : CHAR;
    __REG__ r     : IOConsts.ReadResults;
            tstLF : BOOLEAN;
            chanP : streamFileDataP;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
   IF looked THEN
     IF lookRes = IOConsts.endOfInput THEN
       tid^.errNum := EIO;
       raiseEOF;
     END;
     INC(rpos, skipSize);
   ELSE
     streamSkip(tid);
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
     fillBuf(tid, tstLF);
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

   looked      := TRUE;
   c           := ch;
   lookCh      := ch;
   lookRes     := r;
   res         := r;
   tid^.result := r;
 END;
END streamSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE streamTextRead ((* EIN/ -- *)     tid  : DeviceTablePtr;
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
            chanP : streamFileDataP;

BEGIN
 read := 0;
 IF size = VAL(UNSIGNED,0) THEN
   tid^.result := IOConsts.allRight;
   RETURN;
 END;

 eol   := FALSE;
 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
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
     fillBuf(tid, tstLF);
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
       lookRes     := IOConsts.endOfLine;
       tid^.result := IOConsts.endOfLine;
     ELSE
       lookRes     := IOConsts.endOfInput;
       tid^.result := IOConsts.endOfInput;
     END;
   ELSE
     tid^.result := IOConsts.allRight;
   END;
 END; (* WITH chanP^ *)
END streamTextRead;

(*---------------------------------------------------------------------------*)

PROCEDURE streamTextWrite ((* EIN/ -- *) tid  : DeviceTablePtr;
                           (* EIN/ -- *) from : ADDRESS;
                           (* EIN/ -- *) size : UNSIGNED       );

VAR __REG__ cnt      : UNSIGNED;
    __REG__ tmp      : UNSIGNED;
            written  : BOOLEAN;
            expandLF : BOOLEAN;
            exc      : ChanExceptions;
            nWritten : types.ssizeT;
            lf       : CharPtr;
            chanP    : streamFileDataP;

BEGIN
 written := FALSE;
 chanP   := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE; (* sicherheitshalber *)
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
       streamFlush(tid);
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
           tid^.errNum := errno;
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
                            "StreamFile: 'Write' failed");
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
     streamFlush(tid);
     flushBuf := FALSE;
   END;
 END; (* WITH *)
END streamTextWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE streamWriteLn ((* EIN/ -- *) tid : DeviceTablePtr );

VAR chanP : streamFileDataP;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 chanP^.flushBuf := TRUE;
 tid^.doTextWrite(tid, ADR(nl), 1);
END streamWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE streamRawRead ((* EIN/ -- *)     tid  : DeviceTablePtr;
                         (* EIN/ -- *)     to   : ADDRESS;
                         (* EIN/ -- *)     size : UNSIGNED;
                         (* -- /AUS *) VAR read : UNSIGNED       );

VAR nRead : types.ssizeT;
    exc   : ChanExceptions;
    chanP : streamFileDataP;

PROCEDURE readBuf;

VAR __REG__ left : UNSIGNED;
    __REG__ cnt  : UNSIGNED;

BEGIN (* readBuf *)
 WITH chanP^ DO
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

BEGIN (* streamRawRead *)
 read := 0;
 IF size = VAL(UNSIGNED,0) THEN
   tid^.result := IOConsts.allRight;
   RETURN;
 END;

 chanP := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
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
       fillBuf(tid, FALSE);
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
         tid^.errNum := errno;
#ifndef __NO_IO_EXCEPTIONS__
         IF read = VAL(UNSIGNED,0) THEN
           (* Wenn noch nichts gelesen wurde, ist ein RETRY moeglich *)
           exc := softDeviceError;
         ELSE
           exc := hardDeviceError;
         END;
         EXCEPTIONS.RAISE(iolibSource, ORD(exc),
                          "StreamFile: 'RawRead' failed");
#endif
       END;
     END; (* IF size < RBUFSIZE *)
   END; (* IF size > 0 *)
 END; (* WITH chanP^ *)

 IF read = VAL(UNSIGNED,0) THEN
   tid^.result := IOConsts.endOfInput;
 ELSE
   tid^.result := IOConsts.allRight;
 END;
END streamRawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE streamRawWrite ((* EIN/ -- *) tid  : DeviceTablePtr;
                          (* EIN/ -- *) from : ADDRESS;
                          (* EIN/ -- *) size : UNSIGNED       );

VAR written  : BOOLEAN;
    nWritten : types.ssizeT;
    exc      : ChanExceptions;
    chanP    : streamFileDataP;

PROCEDURE writeBuf;

VAR __REG__ cnt   : UNSIGNED;
    __REG__ space : UNSIGNED; (* Platz im Puffer *)

BEGIN (* writeBuf *)
 WITH chanP^ DO
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

BEGIN (* streamRawWrite *)
 IF size = VAL(UNSIGNED,0) THEN
   RETURN;
 END;

 written := FALSE;
 chanP   := CAST(streamFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE; (* sicherheitshalber *)
   (* Zuerst Puffer fuellen *)
   writeBuf;
   IF size > VAL(UNSIGNED,0) THEN
     (* Noch nicht alles uebertragen,
      * vollen Puffer mit Datei synchronisieren.
      *)
     streamFlush(tid);
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
         tid^.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
         RETURN;
#else
         IF ~written & (nWritten = VAL(types.ssizeT,0)) THEN
           (* Wenn noch nichts geschrieben wurde, ist ein RETRY moeglich *)
           exc := softDeviceError;
         ELSE
           exc := hardDeviceError;
         END;
         EXCEPTIONS.RAISE(iolibSource, ORD(exc), "StreamFile: 'Write' failed");
#endif
       END;
     END;
   END;
   IF istty & flushBuf THEN
     (* Terminal ist zeilenweise gepuffert *)
     streamFlush(tid);
     flushBuf := FALSE;
   END;
 END;
END streamRawWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE streamName ((* EIN/ -- *)     tid  : DeviceTablePtr;
                      (* -- /AUS *) VAR name : ARRAY OF CHAR  );

VAR chanP : streamFileDataP;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 ISOStrings.Assign(chanP^.fname, name);
END streamName;

(*---------------------------------------------------------------------------*)

PROCEDURE streamReset ((* EIN/ -- *) tid : DeviceTablePtr );
BEGIN
 streamFlush(tid);
END streamReset;

(*---------------------------------------------------------------------------*)

PROCEDURE streamFree ((* EIN/ -- *) tid : DeviceTablePtr );

VAR chanP : streamFileDataP;
    res   : INTEGER;

BEGIN
 chanP := CAST(streamFileDataP,tid^.cd);
 IF chanP # NIL THEN
   IF ChanConsts.writeFlag IN tid^.flags THEN
     streamFlush(tid);
     res := file.close(chanP^.whandle);
   END;
   IF ChanConsts.readFlag IN tid^.flags THEN
     res := file.close(chanP^.rhandle);
   END;
   DISPOSE(chanP);
   tid^.cd := NIL;
 END;
END streamFree;
#ifdef HM2
(*$E=*)
#endif

(*===========================================================================*)

PROCEDURE errToOpenRes ((* EIN/ -- *) err : INTEGER ): OpenResults;
BEGIN
 CASE err OF
#ifdef __GEMDOS__
   EACCES,
   EROFS        : RETURN(ChanConsts.wrongPermissions);
  |ENFILE       : RETURN(ChanConsts.tooManyOpen);
#else
   EACCES,
   EPERM,
   EROFS        : RETURN(ChanConsts.wrongPermissions);
  |EMFILE,
   ENFILE       : RETURN(ChanConsts.tooManyOpen);
#endif
  |ENOTTY,
   EISDIR       : RETURN(ChanConsts.wrongFileType);
  |ENOMEM       : RETURN(ChanConsts.outOfChans);
  |EEXIST       : RETURN(ChanConsts.fileExists);
  |ENAMETOOLONG : RETURN(ChanConsts.wrongNameFormat);
  |ENOENT       : RETURN(ChanConsts.noSuchFile);
  |ENOSPC       : RETURN(ChanConsts.noRoomOnDevice);
 ELSE             RETURN(ChanConsts.otherProblem);
 END;
END errToOpenRes;

(*---------------------------------------------------------------------------*)

PROCEDURE Open ((* -- /AUS *) VAR ch   : ChanId;
                (* EIN/ -- *) REF name : ARRAY OF CHAR;
                (* EIN/ -- *)     flag : FlagSet;
                (* -- /AUS *) VAR res  : OpenResults   );

VAR         tid   : DeviceTablePtr;
            data  : streamFileDataP;
    __REG__ rhndl : INTEGER;
    __REG__ whndl : INTEGER;
    __REG__ rd    : BOOLEAN;
    __REG__ wr    : BOOLEAN;
            st    : dir.StatRec;
            acc   : file.OpenModes;
            tty   : BOOLEAN;

BEGIN
 ch := badChanId;
 IF ~(flag <= StreamFileFlags) THEN
   res := ChanConsts.wrongFlags;
   RETURN;
 END;
 IF ~(ChanConsts.rawFlag IN flag) THEN
   INCL(flag, ChanConsts.textFlag);
 END;
 IF ~(ChanConsts.writeFlag IN flag) THEN
   INCL(flag, ChanConsts.readFlag);
 END;
 rhndl := -1;
 whndl := -1;

 rd := ChanConsts.readFlag IN flag;
 wr := ChanConsts.writeFlag IN flag;

 IF rd THEN
   INCL(flag, ChanConsts.oldFlag);
   rhndl := file.open(name, file.oRDONLY);
   IF rhndl < file.MINHANDLE THEN
     res := errToOpenRes(errno);
     RETURN;
   END;
 END;

 IF wr THEN
   IF ChanConsts.oldFlag IN flag THEN
     acc := file.oWRONLY + file.OpenModes{file.oCREAT, file.oTRUNC};
   ELSE
     acc := file.oWRONLY + file.OpenModes{file.oCREAT, file.oEXCL};
   END;
   whndl := file.open(name, acc);
   IF whndl < file.MINHANDLE THEN
     res := errToOpenRes(errno);
     IF rd THEN rhndl := file.close(rhndl); END;
     RETURN;
   END;
 END;

 IF rd THEN
   tty := term.isatty(rhndl) > 0;
 ELSE
   tty := term.isatty(whndl) > 0;
 END;
 IF tty THEN
   INCL(flag, ChanConsts.interactiveFlag);
 END;

 MakeChan(streamDevice, ch);
#if ISO_opaque_compare
 IF ch = badChanId THEN
#else
 IF CAST(ADDRESS,ch) = CAST(ADDRESS,badChanId) THEN
#endif
   IF rd THEN rhndl := file.close(rhndl); END;
   IF wr THEN whndl := file.close(whndl); END;
   res := ChanConsts.outOfChans;
   RETURN;
 END;

 NEW(data);
 IF data = NIL THEN
   IF rd THEN rhndl := file.close(rhndl); END;
   IF wr THEN whndl := file.close(whndl); END;
   res := ChanConsts.outOfChans;
   UnMakeChan(streamDevice, ch);
   RETURN;
 END;

 tid := DeviceTablePtrValue(ch, streamDevice);
 WITH tid^ DO
   cd          := data;
   did         := streamDevice;
   cid         := ch;
   result      := IOConsts.notKnown;
   errNum      := 0;
   doGetName   := streamName;
   doReset     := streamReset;
   doFlush     := streamFlush;
   doFree      := streamFree;
   IF ChanConsts.textFlag IN flag THEN
     IF wr THEN
       doWriteLn := streamWriteLn;
       IF DosDir.BINIO & ~tty THEN
         doTextWrite := streamRawWrite;
       ELSE
         doTextWrite := streamTextWrite;
       END;
     END;
     IF rd THEN
       doLook     := streamLook;
       doSkip     := streamSkip;
       doSkipLook := streamSkipLook;
       doTextRead := streamTextRead;
     END;
   END;
   IF ChanConsts.rawFlag IN flag THEN
     IF wr THEN
       doRawWrite := streamRawWrite;
     END;
     IF rd THEN
       doRawRead  := streamRawRead;
     END;
   END;
   flags := flag;
 END;

 WITH data^ DO
   ISOStrings.Assign(name, fname);
   istty    := tty;
   error    := FALSE;
   dirty    := FALSE;
   rpos     := 0;
   readSize := 0;
   rhandle  := rhndl;
   looked   := FALSE;
   lookRes  := IOConsts.notKnown;
   lookCh   := 0C;
   skipSize := 0;
   wpos     := 0;
   flushBuf := FALSE;
   whandle  := whndl;
 END;
 res := ChanConsts.opened;
END Open;

(*---------------------------------------------------------------------------*)

PROCEDURE IsStreamFile ((* EIN/ -- *) cid : ChanId ): BOOLEAN;
BEGIN
 RETURN(IsDevice(cid, streamDevice));
END IsStreamFile;

(*---------------------------------------------------------------------------*)

PROCEDURE Close ((* EIN/AUS *) VAR cid : ChanId );

VAR tid : DeviceTablePtr;

BEGIN
 tid := DeviceTablePtrValue(cid, streamDevice);
 streamFree(tid);
 UnMakeChan(streamDevice, cid);
END Close;

(*===========================================================================*)

BEGIN (* StreamFile *)
 EXCEPTIONS.AllocateSource(streamFileSource);
 AllocateDeviceId(streamDevice);
 badChanId := InvalidChan();
 nl        := types.LF;
END StreamFile.
