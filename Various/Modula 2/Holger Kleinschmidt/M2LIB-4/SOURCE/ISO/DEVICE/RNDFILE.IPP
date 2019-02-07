IMPLEMENTATION MODULE RndFile;
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
      gelesen, und dann werden Puffer und Datei synchronisiert und ein
      neuer Puffer eingelesen. Hierdurch wird das CR, das noch im Puffer
      stand, erneut aus der Datei eingelesen, und steht nun als erstes
      Zeichen im Puffer; die Ueberpruefung auf ein Zeilenende kann nun
      von vorne beginnen.

   3) Ist beim Einlesen eines neuen Puffers das erneut eingelesene CR
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
   werden die restlichen Bytes direkt aus der Datei gelesen. In beiden
   Faellen wird vorher evtl. der alte Puffer in die Datei zurueckgeschrieben.


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
PTR_ARITH_IMPORT


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

IMPORT blk, types, ISOStrings, DosDir, file, dir;

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
  RndFileFlags = ChanConsts.FlagSet{ChanConsts.readFlag,
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
  BUFSIZE = 1024;

TYPE
  CharPtr = POINTER TO CHAR;

  rndFileDataP = POINTER TO rndFileData;
  rndFileData = RECORD
    realProps : ChanConsts.FlagSet;
      (* Flags beim Oeffnen des Kanals; wird fuer die 'Reset'- und die
       * 'SetPos'-Operation benoetigt.
       *)
    fname : ARRAY [0..MAXNAME] OF CHAR;
      (* Dateiname *)


    pos : UNSIGNEDWORD;
      (* Lese/Schreibzeiger; kennzeichnet die Position im Puffer,
       * von der das naechste Byte gelesen oder an die das naechste Byte
       * geschrieben werden soll.
       *)
    readSize : UNSIGNEDWORD;
      (* Anzahl der in den Puffer gelesenen Bytes. Dateiposition ist
       * 'readSize' Bytes hinter dem Pufferanfang, sonst am Anfang des
       * Puffers. Ist Null, falls der Puffer nur beschrieben wurde.
       *)
    buf : ARRAY [0..BUFSIZE] OF CHAR;
      (* Puffer mit Platz fuer ein zusaetzliches CR VOR dem eigentlichen
       * Puffer.
       *)
    dirty : BOOLEAN;
      (* Flag: Puffer wurde beschrieben *)
    error : BOOLEAN;
      (* Flag: Fehler bei letzter I/O-Operation. Wird fuer die Kommunikation
       * zwischen den ``tieferen'' und ``hoeheren'' Prozeduren verwendet,
       * wenn bei IO-Fehlern keine Ausnahmen generiert werden.
       *)
    handle : INTEGER;
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

VAR
  rndDevice     : DeviceId;
  rndFileSource : EXCEPTIONS.ExceptionSource;
  badChanId     : ChanId;
  nl            : CHAR;

(*===========================================================================*)
(* Geraeteoperationen                                                        *)
(*===========================================================================*)

PROCEDURE raiseEOF;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(skipAtEnd),
                  "RndFile: 'Skip/Look' at end of file");
END raiseEOF;

(*---------------------------------------------------------------------------*)

PROCEDURE raiseSkipLook;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                  "RndFile: 'Skip/Look' not available");
END raiseSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE fillBuf ((* EIN/ -- *) tid : DeviceTablePtr );
(* Leeren Puffer fuellen *)
VAR nRead : types.ssizeT;
    chanP : rndFileDataP;

BEGIN
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
   pos    := 0;
   nRead  := file.read(handle, ADR(buf), BUFSIZE);
   IF nRead >= VAL(types.ssizeT,0) THEN
     (* Null ist auch OK, dann ist das Dateiende erreicht *)
     readSize := VAL(UNSIGNEDWORD,nRead);
     error    := FALSE;
   ELSE
     readSize    := 0;
     error       := TRUE;
     tid^.errNum := errno;
#ifndef __NO_IO_EXCEPTIONS__
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError), (* RETRY moeglich *)
                      "RndFile: 'Read' failed");
#endif
   END;
 END;
END fillBuf;

(*---------------------------------------------------------------------------*)

#ifdef HM2
(*$E+*)
#endif
PROCEDURE rndFlush ((* EIN/ -- *) tid : DeviceTablePtr );
(* Schreibt gepufferte Daten in die Datei und synchronisiert den
 * Lese/Schreibzeiger der Datei mit dem Lese/Schreibzeiger des Puffers,
 * auch wenn keine Daten geschrieben wurden.
 *)
VAR __REG__ offset : types.offT;
    __REG__ rwpos  : types.offT;
    __REG__ size   : types.offT;
            moved  : BOOLEAN;
            exc    : ChanExceptions;
            chanP  : rndFileDataP;

BEGIN
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
   error  := FALSE;
   moved  := FALSE;
   size   := VAL(types.offT,readSize);
   rwpos  := VAL(types.offT,pos);
   IF readSize > 0 THEN
     (* Puffer wurde eingelesen, Dateizeiger steht 'readSize' Bytes
      * hinter dem Pufferanfang.
      *)
     IF dirty THEN
       (* In den Puffer wurde auch geschrieben, daher muss der Puffer
        * zurueckgeschrieben werden; hierzu wird der Dateizeiger an den
        * Anfang des Puffers gesetzt.
        *)
       offset := size;
     ELSE
       (* Der Dateizeiger muss nur soviele Positionen zurueckgesetzt
        * werden wie noch nicht gelesen wurden.
        * 'offset' kann nicht negativ werden, da nicht in den Puffer
        * geschrieben wurde, und deswegen rwPos <= readSize gilt.
        *)
       offset := size - rwpos;
     END;
     IF offset # VAL(types.offT,0) THEN
       IF file.lseek(handle, -offset, file.SeekCur) < VAL(types.offT,0) THEN
         tid^.errNum := errno;
         error       := TRUE;
#ifdef __NO_IO_EXCEPTIONS__
         RETURN;
#else
         EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError),(* RETRY moeglich *)
                          "RndFile: 'Flush' failed");
#endif
       END;
       moved := TRUE;
     END;
     readSize := 0;
   END;
   IF dirty THEN
     (* Falls in den Puffer geschrieben wurde, wird er bis zum aktuellen
      * Lese/Schreibzeiger zurueckgeschrieben.
      *)
     size := VAL(types.offT,file.write(handle, ADR(buf), VAL(types.sizeT,rwpos)));
     IF size # rwpos THEN
       error := TRUE;
       IF size < VAL(types.offT,0) THEN
         tid^.errNum := errno;
       ELSE
         tid^.errNum := ENOSPC;
       END;
#ifdef __NO_IO_EXCEPTIONS__
       RETURN;
#else
       IF ~moved & (size <= VAL(types.offT,0)) THEN
         exc := softDeviceError;
         (* Es ist ein RETRY moeglich, da noch nichts geschrieben,
          * und der Lese/Schreibzeiger der Datei nicht veraendert wurde.
          *)
       ELSE
         exc := hardDeviceError;
       END;
       EXCEPTIONS.RAISE(iolibSource, ORD(exc), "RndFile: 'Flush' failed");
#endif
     END;
   END;
   (* Puffer ist jetzt leer *)
   pos   := 0;
   dirty := FALSE;
 END;
END rndFlush;

(*---------------------------------------------------------------------------*)

PROCEDURE rndLook ((* EIN/ -- *)     tid : DeviceTablePtr;
                   (* -- /AUS *) VAR c   : CHAR;
                   (* -- /AUS *) VAR res : IOConsts.ReadResults );

(* Die Schleife wird hoechstens dreimal durchlaufen:
   1) Wenn der Puffer leer ist, wird ein 'fillbuf' ausgefuehrt
   2) Das einzige vorhandene Zeichen ist ein CR, also tstLF = TRUE
   3) Jetzt kann entschieden werden, welches Zeichen vorliegt

   Durchlauf Nr.3 findet immer statt, Nr.1 und/oder Nr.2 koennen
   jedoch bei den entsprechenden Bedingungen entfallen.
 *)

VAR __REG__ left  : UNSIGNEDWORD; (* Anzahl ungelesener Bytes im Puffer *)
    __REG__ ch    : CHAR;
    __REG__ r     : IOConsts.ReadResults;
            tstLF : BOOLEAN;
            chanP : rndFileDataP;

BEGIN
 IF ~(ChanConsts.readFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   raiseSkipLook;
 END;

 chanP := CAST(rndFileDataP,tid^.cd);
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
         IF left = 1 THEN
           (* Letztes Zeichen im Puffer ist ein CR; deshalb neuen Puffer
            * einlesen, um zu testen ob ein LF folgt.
            *)
           tstLF := TRUE;
         ELSIF buf[pos+1] = types.LF THEN
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

     (* Wenn der Puffer vollstaendig ausgelesen ist oder das letzte
      * Zeichen ein CR ist, wird der Puffer neu eingelesen. Ein CR
      * steht nun als erstes Zeichen im Puffer (moeglicherweise gefolgt
      * von LF, was ein Zeilenende bedeutet).
      *)
     IF tstLF OR dirty THEN
       (* Wenn der Puffer zwischendurch auch beschrieben wurde oder
        * ein CR erneut eingelesen werden soll, muss die Datei vorher mit
        * dem Puffer synchronisiert werden.
        *)
       rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         r := IOConsts.endOfInput;
         EXIT;
       END;
#endif
     END;
     fillBuf(tid);
     IF readSize = 0 THEN
       (* Datei ist leer, es musste nicht auf ein LF getestet werden. *)
       r := IOConsts.endOfInput;
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Datei ist zuende, nur das erneut gepufferte CR ist vorhanden,
        * also wird dieses als normales Zeichen gelesen.
        *)
       r  := IOConsts.allRight;
       ch := buf[0]; (* sicherheitshalber, statt nur CR *)
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
END rndLook;

(*---------------------------------------------------------------------------*)

PROCEDURE rndSkip ((* EIN/ -- *) tid : DeviceTablePtr );
(* Ablauf wie 'Look' *)
VAR __REG__ left  : UNSIGNEDWORD; (* Anzahl ungelesener Bytes im Puffer *)
            tstLF : BOOLEAN;
            chanP : rndFileDataP;

BEGIN
 IF ~(ChanConsts.readFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   raiseSkipLook;
 END;

 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   IF looked THEN
     IF lookRes = IOConsts.endOfInput THEN
       tid^.errNum := EIO;
       raiseEOF;
     END;
     INC(pos, skipSize);
     looked      := FALSE;
     tid^.result := IOConsts.allRight;
     RETURN;
   END;

   LOOP
     tstLF := FALSE;
     IF pos < readSize THEN
       left := readSize - pos;
     ELSE
       left := 0;
     END;

     IF left > 0 THEN
       IF buf[pos] # types.CR THEN
         (* Normales Zeichen oder LF *)
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

     IF tstLF OR dirty THEN
       rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         tid^.result := IOConsts.endOfInput;
         RETURN;
       END;
#endif
     END;
     fillBuf(tid);
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
   INC(pos);
 END; (* WITH *)

 tid^.result := IOConsts.allRight;
END rndSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE rndSkipLook ((* EIN/ -- *)     tid : DeviceTablePtr;
                       (* -- /AUS *) VAR c   : CHAR;
                       (* -- /AUS *) VAR res : IOConsts.ReadResults );

VAR __REG__ left  : UNSIGNEDWORD;
    __REG__ ch    : CHAR;
    __REG__ r     : IOConsts.ReadResults;
            tstLF : BOOLEAN;
            chanP : rndFileDataP;

BEGIN
 IF ~(ChanConsts.readFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   raiseSkipLook;
 END;

 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   IF looked THEN
     IF lookRes = IOConsts.endOfInput THEN
       tid^.errNum := EIO;
       raiseEOF;
     END;
     INC(pos, skipSize);
   ELSE
     rndSkip(tid);
   END;

   skipSize := 1;
   r        := IOConsts.endOfLine;
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
         IF left = 1 THEN
           (* Letztes Zeichen im Puffer ist ein CR; deshalb neuen Puffer
            * einlesen, um zu testen ob ein LF folgt.
            *)
           tstLF := TRUE;
         ELSIF buf[pos+1] = types.LF THEN
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

     (* Wenn der Puffer vollstaendig ausgelesen ist oder das letzte
      * Zeichen ein CR ist, wird der Puffer neu eingelesen. Ein CR
      * steht nun als erstes Zeichen im Puffer (moeglicherweise gefolgt
      * von LF, was ein Zeilenende bedeutet).
      *)
     IF tstLF OR dirty THEN
       (* Wenn der Puffer zwischendurch auch beschrieben wurde oder
        * ein CR erneut eingelesen werden soll, muss die Datei vorher mit
        * dem Puffer synchronisiert werden.
        *)
       rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         r := IOConsts.endOfInput;
         EXIT;
       END;
#endif
     END;
     fillBuf(tid);
     IF readSize = 0 THEN
       (* Datei ist leer, es musste nicht auf ein LF getestet werden. *)
       r := IOConsts.endOfInput;
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Datei ist zuende, nur das erneut gepufferte CR ist vorhanden,
        * also wird dieses als normales Zeichen gelesen.
        *)
       r  := IOConsts.allRight;
       ch := buf[0]; (* sicherheitshalber, statt nur CR *)
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
END rndSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE rndTextRead ((* EIN/ -- *)     tid  : DeviceTablePtr;
                       (* EIN/ -- *)     to   : ADDRESS;
                       (* EIN/ -- *)     size : UNSIGNED;
                       (* -- /AUS *) VAR read : UNSIGNED       );

VAR __REG__ left  : UNSIGNED; (* Anzahl ungelesener Bytes im Puffer *)
    __REG__ cnt   : UNSIGNED;
    __REG__ tstLF : BOOLEAN;  (* Letztes Byte im Puffer gleich CR? *)
            eol   : BOOLEAN;
            lf    : CharPtr;
            chanP : rndFileDataP;

BEGIN
 read := 0;
 IF ~(ChanConsts.readFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                    "RndFile: 'TextRead' not available");
 ELSIF size = VAL(UNSIGNED,0) THEN
   tid^.result := IOConsts.allRight;
   RETURN;
 END;

 eol   := FALSE;
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked   := FALSE;
   skipSize := 1;
   LOOP
     tstLF := FALSE;
     IF pos < readSize THEN
       left := VAL(UNSIGNED,readSize - pos);
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
       IF cnt = left THEN
         (* Bis zum Ende des Puffers nach einem Zeilenende suchen *)
         lf    := blk.memchr(ADR(buf[pos]), ORD(types.LF), cnt);
         tstLF := buf[readSize-1] = types.CR;
       ELSE (* cnt < left *)
         (* Nach einem Zeilenende suchen, bis ein Zeichen hinter dem letzten
          * gewuenschten, damit ein Zeilenende auch erkannt wird, wenn das
          * letzte gewuenschte Zeichen das CR eines CR+LF-Zeilenendes ist.
          *)
         lf    := blk.memchr(ADR(buf[pos]), ORD(types.LF), cnt + VAL(UNSIGNED,1));
         tstLF := FALSE;
       END;

       IF lf # NULL THEN
         (* Zeilenende gefunden, cnt: Anzahl der Bytes
          * vor dem LF. Falls dieses LF nur durch die Vergroesserung
          * des Suchgebiets um Eins gefunden wurde, koennen alle verlangten
          * Bytes uebertragen werden, es sei denn, vor dem LF steht noch
          * ein CR.
          *)
         eol := TRUE;
         cnt := VAL(UNSIGNED,DIFADR(lf, ADR(buf[pos])));
         IF (cnt > VAL(UNSIGNED,0)) & (buf[pos+VAL(UNSIGNEDWORD,cnt)-1] = types.CR) THEN
           (* Zeilenende besteht aus CR+LF, das CR wird nicht gelesen *)
           skipSize := 2;
           DEC(cnt);
         END;
       ELSIF tstLF THEN
         (* CR nochmal mit dem naechsten Puffer lesen *)
         DEC(cnt);
       END;

       IF cnt > VAL(UNSIGNED,0) THEN
         blk.memmove(to, ADR(buf[pos]), cnt);
         DEC(size, cnt);
         INC(read, cnt);
         INC(pos, VAL(UNSIGNEDWORD,cnt));
         to := ADDADR(to, cnt);
       END;
     END;
     IF eol OR (size = VAL(UNSIGNED,0)) THEN
       EXIT;
     END;
     IF tstLF OR dirty THEN
       rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         tid^.result := IOConsts.endOfInput;
         RETURN;
       END;
#endif
     END;
     fillBuf(tid);
     IF readSize = 0 THEN
       EXIT;
     ELSIF tstLF & (readSize = 1) THEN
       (* Das erneut eingelesene CR ist das einzige Zeichen *)
       lf  := to;
       lf^ := buf[0];
       INC(pos);
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
END rndTextRead;

(*---------------------------------------------------------------------------*)

PROCEDURE rndTextWrite ((* EIN/ -- *) tid  : DeviceTablePtr;
                        (* EIN/ -- *) from : ADDRESS;
                        (* EIN/ -- *) size : UNSIGNED       );

VAR __REG__ cnt      : UNSIGNED;
    __REG__ tmp      : UNSIGNED;
            written  : BOOLEAN;
            expandLF : BOOLEAN;
            exc      : ChanExceptions;
            nWritten : types.ssizeT;
            lf       : CharPtr;
            flushBuf : BOOLEAN;
            chanP    : rndFileDataP;

BEGIN
 IF ~(ChanConsts.writeFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                    "RndFile: 'Write' not available");
 END;

 flushBuf := FALSE;
 written  := FALSE;
 chanP    := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
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

     IF tmp > VAL(UNSIGNED,BUFSIZE - pos) THEN
       (* Es passt nicht alles in den Puffer, deswegen den Puffer erstmal
        * leeren.
        *)
       rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         RETURN;
       END;
#endif
     END;
     IF cnt > VAL(UNSIGNED,0) THEN
       IF tmp <= VAL(UNSIGNED,BUFSIZE) THEN
         (* Es passt (nun) alles in den Puffer *)
         blk.memmove(ADR(buf[pos]), from, VAL(types.sizeT,cnt));
         INC(pos, VAL(UNSIGNEDWORD,cnt));
         dirty   := TRUE;
         written := TRUE;
       ELSE
         (* Sonst direkt die Quelle schreiben. Die Variablen des Puffers
          * ('pos' und 'dirty') wurden durch 'Flush' geloescht.
          *)
         nWritten := file.write(handle, from, VAL(types.sizeT,cnt));
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
           EXCEPTIONS.RAISE(iolibSource, ORD(exc), "RndFile: 'Write' failed");
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
       buf[pos] := types.CR; INC(pos);
       buf[pos] := types.LF; INC(pos);
       dirty    := TRUE;
       written  := TRUE;
     END;
   END; (* WHILE size > 0 *)
 END; (* WITH *)
END rndTextWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE rndWriteLn ((* EIN/ -- *) tid : DeviceTablePtr );
BEGIN
 tid^.doTextWrite(tid, ADR(nl), 1);
END rndWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE rndRawRead ((* EIN/ -- *)     tid  : DeviceTablePtr;
                      (* EIN/ -- *)     to   : ADDRESS;
                      (* EIN/ -- *)     size : UNSIGNED;
                      (* -- /AUS *) VAR read : UNSIGNED       );

VAR nRead : types.ssizeT;
    exc   : ChanExceptions;
    chanP : rndFileDataP;

PROCEDURE readBuf;

VAR __REG__ left : UNSIGNED;
    __REG__ cnt  : UNSIGNED;

BEGIN (* readBuf *)
 WITH chanP^ DO
   (* Anzahl ungelesener Bytes im Puffer *)
   IF pos < readSize THEN
     left := VAL(UNSIGNED,readSize - pos);
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
     blk.memmove(to, ADR(buf[pos]), VAL(types.sizeT,cnt));
     DEC(size, cnt);
     INC(read, cnt);
     INC(pos, VAL(UNSIGNEDWORD,cnt));
     to := ADDADR(to, cnt);
   END;
 END; (* WITH *)
END readBuf;

BEGIN
 read := 0;
 IF ~(ChanConsts.readFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                    "RndFile: 'RawRead' not available");
 END;

 IF size = VAL(UNSIGNED,0) THEN
   tid^.result := IOConsts.allRight;
   RETURN;
 END;
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
   (* Zuerst verbleibende Bytes aus dem Puffer uebertragen *)
   readBuf;
   IF size > VAL(UNSIGNED,0) THEN
     (* Reicht noch nicht, aber Puffer zuende *)
     IF dirty THEN
       (* Da der Puffer ``verlassen'' wird, muss die Datei mit ihm
        * synchronisiert werden.
        *)
       rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
       IF error THEN
         tid^.result := IOConsts.endOfInput;
         RETURN;
       END;
#endif
     END;
     IF size < VAL(UNSIGNED,BUFSIZE) THEN
       (* Wenn weniger Bytes als die Puffergroesse benoetigt werden,
        * wird der Puffer aufgefuellt, und die Bytes von dort
        * uebertragen.
        *)
       fillBuf(tid);
       readBuf;
     ELSE
       (* Wenn mehr als die Puffergroesse benoetigt wird, werden die
        * Bytes direkt ins Ziel uebertragen; Puffer als frei kennzeichnen.
        *)
       pos      := 0;
       readSize := 0;
       nRead    := file.read(handle, to, VAL(types.sizeT,size));
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
         EXCEPTIONS.RAISE(iolibSource, ORD(exc), "RndFile: 'RawRead' failed");
#endif
       END;
     END; (* IF size < BUFSIZE *)
   END; (* IF size > 0 *)
 END; (* WITH chanP^ *)

 IF read = VAL(UNSIGNED,0) THEN
   tid^.result := IOConsts.endOfInput;
 ELSE
   tid^.result := IOConsts.allRight;
 END;
END rndRawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE rndRawWrite ((* EIN/ -- *) tid  : DeviceTablePtr;
                       (* EIN/ -- *) from : ADDRESS;
                       (* EIN/ -- *) size : UNSIGNED       );

VAR written  : BOOLEAN;
    nWritten : types.ssizeT;
    exc      : ChanExceptions;
    chanP    : rndFileDataP;

PROCEDURE writeBuf;

VAR __REG__ cnt   : UNSIGNED;
    __REG__ space : UNSIGNED; (* Platz im Puffer *)

BEGIN (* writeBuf *)
 WITH chanP^ DO
   space := VAL(UNSIGNED,BUFSIZE - pos);
   IF space > VAL(UNSIGNED,0) THEN
     written := TRUE;
     dirty   := TRUE;
     IF size <= space THEN
       cnt := size;
     ELSE
       cnt := space;
     END;
     blk.memmove(ADR(buf[pos]), from, VAL(types.sizeT,cnt));
     DEC(size, cnt);
     INC(pos, VAL(UNSIGNEDWORD,cnt));
     from := ADDADR(from, cnt);
   END;
 END;
END writeBuf;

BEGIN
 IF ~(ChanConsts.writeFlag IN tid^.flags) THEN
   tid^.errNum := EIO;
   EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                    "RndFile: 'Write' not available");
 END;

 IF size = VAL(UNSIGNED,0) THEN
   RETURN;
 END;
 written := FALSE;
 chanP   := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
   (* Zuerst Puffer fuellen *)
   writeBuf;
   IF size > VAL(UNSIGNED,0) THEN
     (* Noch nicht alles uebertragen,
      * vollen Puffer mit Datei synchronisieren.
      *)
     rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       RETURN;
     END;
#endif
     IF size <= VAL(UNSIGNED,BUFSIZE) THEN
       (* Rest passt in den Puffer *)
       writeBuf;
     ELSE
       (* Sonst direkt die Quelle schreiben *)
       nWritten := file.write(handle, from, VAL(types.sizeT,size));
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
         EXCEPTIONS.RAISE(iolibSource, ORD(exc), "RndFile: 'Write' failed");
#endif
       END;
     END;
   END;
 END;
END rndRawWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE rndName ((* EIN/ -- *)     tid  : DeviceTablePtr;
                   (* -- /AUS *) VAR name : ARRAY OF CHAR  );

VAR chanP : rndFileDataP;

BEGIN
 chanP := CAST(rndFileDataP,tid^.cd);
 ISOStrings.Assign(chanP^.fname, name);
END rndName;

(*---------------------------------------------------------------------------*)

PROCEDURE rndReset ((* EIN/ -- *) tid : DeviceTablePtr );

VAR chanP : rndFileDataP;

BEGIN
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
   IF dirty THEN
     rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       RETURN;
     END;
#endif
   END;
   IF file.lseek(handle, 0, file.SeekSet) < VAL(types.offT,0) THEN
     tid^.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
     RETURN;
#else
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError),
                      "RndFile: 'Reset' failed");
#endif
   END;
 END;
 (* Moegliche Operationen wie beim Oeffnen des Kanals *)
 tid^.flags := chanP^.realProps;
END rndReset;

(*---------------------------------------------------------------------------*)

PROCEDURE rndFree ((* EIN/ -- *) tid : DeviceTablePtr );

VAR chanP : rndFileDataP;

BEGIN
 chanP := CAST(rndFileDataP,tid^.cd);
 IF chanP # NIL THEN
   WITH chanP^ DO
     IF dirty THEN
       rndFlush(tid);
     END;
     handle := file.close(handle);
   END;
   DISPOSE(chanP);
   tid^.cd := NIL;
 END;
END rndFree;
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

PROCEDURE openChan ((* EIN/ -- *) VAR name : ARRAY OF CHAR;
                    (* EIN/ -- *)     acc  : file.OpenModes;
                    (* EIN/ -- *)     flag : FlagSet;
                    (* -- /AUS *) VAR ch   : ChanId;
                    (* -- /AUS *) VAR res  : OpenResults   );

VAR         tid  : DeviceTablePtr;
            data : rndFileDataP;
            st   : dir.StatRec;
    __REG__ hndl : INTEGER;

BEGIN
 hndl := file.open(name, acc);
 IF (hndl < file.MINHANDLE) OR (dir.fstat(hndl, st) < 0) THEN
   res := errToOpenRes(errno);
   RETURN;
 END;
 IF ~dir.sISREG(st.stMode) THEN
   (* Nur regulaere Dateien erlauben die 'lseek'-Operation *)
   res  := ChanConsts.wrongFileType;
   hndl := file.close(hndl);
   RETURN;
 END;

 MakeChan(rndDevice, ch);
#if ISO_opaque_compare
 IF ch = badChanId THEN
#else
 IF CAST(ADDRESS,ch) = CAST(ADDRESS,badChanId) THEN
#endif
   hndl := file.close(hndl);
   res  := ChanConsts.outOfChans;
   RETURN;
 END;

 NEW(data);
 IF data = NIL THEN
   hndl := file.close(hndl);
   res  := ChanConsts.outOfChans;
   UnMakeChan(rndDevice, ch);
   RETURN;
 END;

 tid := DeviceTablePtrValue(ch, rndDevice);
 WITH tid^ DO
   cd        := data;
   did       := rndDevice;
   cid       := ch;
   result    := IOConsts.notKnown;
   errNum    := 0;
   doGetName := rndName;
   doReset   := rndReset;
   doFlush   := rndFlush;
   doFree    := rndFree;
   IF ChanConsts.textFlag IN flag THEN
     IF ChanConsts.writeFlag IN flag THEN
       doWriteLn := rndWriteLn;
       IF DosDir.BINIO THEN
         doTextWrite := rndRawWrite;
       ELSE
         doTextWrite := rndTextWrite;
       END;
     END;
     IF ChanConsts.readFlag IN flag THEN
       doLook     := rndLook;
       doSkip     := rndSkip;
       doSkipLook := rndSkipLook;
       doTextRead := rndTextRead;
     END;
   END;
   IF ChanConsts.rawFlag IN flag THEN
     IF ChanConsts.writeFlag IN flag THEN
       doRawWrite := rndRawWrite;
     END;
     IF ChanConsts.readFlag IN flag THEN
       doRawRead  := rndRawRead;
     END;
   END;
   flags := flag;
 END;

 WITH data^ DO
   ISOStrings.Assign(name, fname);
   realProps := flag;
   pos       := 0;
   readSize  := 0;
   dirty     := FALSE;
   error     := FALSE;
   handle    := hndl;
   looked    := FALSE;
   lookRes   := IOConsts.notKnown;
   lookCh    := 0C;
   skipSize  := 0;
 END;
 res := ChanConsts.opened;
END openChan;

(*---------------------------------------------------------------------------*)

PROCEDURE OpenOld ((* -- /AUS *) VAR cid   : ChanId;
                   (* EIN/ -- *) REF name  : ARRAY OF CHAR;
                   (* EIN/ -- *)     flags : FlagSet;
                   (* -- /AUS *) VAR res   : OpenResults   );

VAR acc : file.OpenModes;

BEGIN
 cid := badChanId;
 IF ~(flags <= RndFileFlags) THEN
   res := ChanConsts.wrongFlags;
   RETURN;
 END;
 IF ChanConsts.writeFlag IN flags THEN
   flags := flags + ChanConsts.FlagSet{ChanConsts.oldFlag};
 ELSE
   flags := flags + ChanConsts.FlagSet{ChanConsts.oldFlag,
                                       ChanConsts.readFlag};
 END;
 IF ~(ChanConsts.textFlag IN flags) THEN
   INCL(flags, ChanConsts.rawFlag);
 END;

 IF ChanConsts.FlagSet{ChanConsts.readFlag, ChanConsts.writeFlag} <= flags THEN
   acc := file.oRDWR;
 ELSIF ChanConsts.readFlag IN flags THEN
   acc := file.oRDONLY;
 ELSE
   acc := file.oWRONLY;
 END;

 openChan(name, acc, flags, cid, res);
END OpenOld;

(*---------------------------------------------------------------------------*)

PROCEDURE OpenClean ((* -- /AUS *) VAR cid   : ChanId;
                     (* EIN/ -- *) REF name  : ARRAY OF CHAR;
                     (* EIN/ -- *)     flags : FlagSet;
                     (* -- /AUS *) VAR res   : OpenResults   );

VAR acc : file.OpenModes;

BEGIN
 cid := badChanId;
 IF ~(flags <= RndFileFlags) THEN
   res := ChanConsts.wrongFlags;
   RETURN;
 END;
 IF ChanConsts.textFlag IN flags THEN
   flags := flags + ChanConsts.FlagSet{ChanConsts.writeFlag};
 ELSE
   flags := flags + ChanConsts.FlagSet{ChanConsts.writeFlag,
                                       ChanConsts.rawFlag};
 END;

 IF ChanConsts.readFlag IN flags THEN
   acc := file.oRDWR + file.OpenModes{file.oCREAT, file.oTRUNC};
 ELSE
   acc := file.oWRONLY + file.OpenModes{file.oCREAT, file.oTRUNC};
 END;

 IF ~(ChanConsts.oldFlag IN flags) THEN
   INCL(acc, file.oEXCL);
 END;

 openChan(name, acc, flags, cid, res);
END OpenClean;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRndFile ((* EIN/ -- *) cid : ChanId ): BOOLEAN;
BEGIN
 RETURN(IsDevice(cid, rndDevice));
END IsRndFile;

(*---------------------------------------------------------------------------*)

PROCEDURE IsRndFileException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(rndFileSource));
END IsRndFileException;

(*---------------------------------------------------------------------------*)

PROCEDURE StartPos ((* EIN/ -- *) cid : ChanId ): FilePos;

VAR tid : DeviceTablePtr;

BEGIN
 tid := DeviceTablePtrValue(cid, rndDevice);
 RETURN(CAST(FilePos,VAL(UNSIGNEDLONG,0)));
END StartPos;

(*---------------------------------------------------------------------------*)

PROCEDURE CurrentPos ((* EIN/ -- *) cid : ChanId ): FilePos;

VAR         tid     : DeviceTablePtr;
            chanP   : rndFileDataP;
    __REG__ current : types.offT;

BEGIN
 tid   := DeviceTablePtrValue(cid, rndDevice);
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked  := FALSE; (* sicherheitshalber *)
   current := file.lseek(handle, 0, file.SeekCur);
   IF current < VAL(types.offT,0) THEN
     tid^.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
     RETURN(CAST(FilePos,VAL(UNSIGNEDLONG,0)));
#else
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError),
                      "RndFile: 'CurrentPos' failed");
#endif
   ELSIF readSize > 0 THEN
     (* Wenn der Puffer eingelesen wurde, steht der Dateizeiger
      * 'readSize' Bytes hinter dem Pufferanfang.
      *)
     DEC(current, VAL(types.offT,readSize));
   END;
   (* 'current' enthaelt jetzt die Anfangsadresse des Puffers. Die
    * aktuelle Position ergibt sich aus dem Lese/Schreibzeiger.
    *)
   INC(current, VAL(types.offT,pos));
 END;
 RETURN(CAST(FilePos,VAL(SIGNEDLONG,current)));
END CurrentPos;

(*---------------------------------------------------------------------------*)

PROCEDURE EndPos ((* EIN/ -- *) cid : ChanId ): FilePos;

VAR         tid    : DeviceTablePtr;
            chanP  : rndFileDataP;
    __REG__ oldPos : types.offT;
    __REG__ endPos : types.offT;

BEGIN
 tid   := DeviceTablePtrValue(cid, rndDevice);
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE; (* sicherheitshalber *)
   IF dirty THEN
     (* Wenn der Puffer beschrieben wurde, koennte die Datei durch den
      * Puffer verlaengert werden, deshalb wird er erst zurueckgeschrieben,
      * bevor das Ende der Datei festgestellt wird.
      *)
     rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       RETURN(CAST(FilePos,VAL(UNSIGNEDLONG,0)));
     END;
#endif
   END;
   (* Dateiende feststellen; ist evtl. auch ueber "dir.fstat()" ermittelbar,
    * falls das 'StatRec.stSize'-Feld tatsaechlich die AKTUELLE Dateilaenge
    * enthaelt -- keine Ahnung.
    *)
   oldPos := file.lseek(handle, 0, file.SeekCur);
   endPos := file.lseek(handle, 0, file.SeekEnd);
   oldPos := file.lseek(handle, oldPos, file.SeekSet);
   IF (oldPos < VAL(types.offT,0)) OR (endPos < VAL(types.offT,0)) THEN
     tid^.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
     RETURN(CAST(FilePos,VAL(UNSIGNEDLONG,0)));
#else
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError),
                      "RndFile: 'EndPos' failed");
#endif
   END;
 END;
 RETURN(CAST(FilePos,VAL(SIGNEDLONG,endPos)));
END EndPos;

(*---------------------------------------------------------------------------*)

PROCEDURE NewPos ((* EIN/ -- *) cid       : ChanId;
                  (* EIN/ -- *) chunks    : SIGNED;
                  (* EIN/ -- *) chunkSize : UNSIGNED;
                  (* EIN/ -- *) from      : FilePos  ): FilePos;

(* Ich versteh auch nicht, warum diese Funktion so kompliziert
   geworden ist...
*)
VAR         tid     : DeviceTablePtr;
    __REG__ pos     : UNSIGNED;
    __REG__ offset  : SIGNED;
    __REG__ uchunks : UNSIGNED;

PROCEDURE raisePos;
BEGIN
 tid^.errNum := EIO;
 EXCEPTIONS.RAISE(rndFileSource, 0, "RndFile: 'NewPos': Out of range");
END raisePos;

BEGIN
 tid := DeviceTablePtrValue(cid, rndDevice);
 IF (chunks < VAL(SIGNED,0)) & (chunks # MINSIGNED) THEN
   uchunks := CAST(UNSIGNED,-chunks);
 ELSE
   uchunks := CAST(UNSIGNED,chunks);
 END;
 pos := VAL(UNSIGNED,CAST(UNSIGNEDLONG,from));
 IF   (pos > CAST(UNSIGNED,MAXSIGNED))
   OR (CAST(UNSIGNED,MAXSIGNED) DIV chunkSize < uchunks)
 THEN
   raisePos;
 END;
 offset := CAST(SIGNED,chunkSize) * chunks;
 IF   (offset >= VAL(SIGNED,0)) & (MAXSIGNED - offset < VAL(SIGNED,pos))
   OR (offset  < VAL(SIGNED,0)) & (-offset > VAL(SIGNED,pos))
 THEN
   raisePos;
 END;
 RETURN(CAST(FilePos,VAL(SIGNEDLONG,CAST(SIGNED,pos) + offset)));
END NewPos;

(*---------------------------------------------------------------------------*)

PROCEDURE SetPos ((* EIN/ -- *) cid  : ChanId;
                  (* EIN/ -- *) fpos : FilePos );

VAR         tid    : DeviceTablePtr;
            chanP  : rndFileDataP;
    __REG__ newPos : types.offT;
    __REG__ endPos : types.offT;

BEGIN
 tid   := DeviceTablePtrValue(cid, rndDevice);
 chanP := CAST(rndFileDataP,tid^.cd);
 WITH chanP^ DO
   looked := FALSE;
   IF dirty THEN
     (* Wenn der Puffer veraendert wurde, muss er zurueckgeschrieben
      * werden.
      *)
     rndFlush(tid);
#ifdef __NO_IO_EXCEPTIONS__
     IF error THEN
       RETURN;
     END;
#endif
   END;
   (* Aktuelles Ende der Datei ermitteln *)
   endPos := file.lseek(handle, 0, file.SeekEnd);
   IF endPos < VAL(types.offT,0) THEN
     tid^.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
     RETURN;
#else
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError), (* RETRY moeglich *)
                      "RndFile: 'SetPos' failed");
#endif
   END;
   newPos := VAL(types.offT,CAST(SIGNEDLONG,fpos));
   IF newPos > endPos THEN
     (* Wenn die neue Position hinter dem augenblicklichen Dateiende liegt,
      * kann nicht von der Datei gelesen werden.
      *)
     EXCL(tid^.flags, ChanConsts.readFlag);
   ELSE
     (* Wenn die neue Position innerhalb der Datei liegt, sind alle
      * Operationen moeglich, die auch beim Oeffnen des Kanals angegeben
      * wurden.
      *)
     tid^.flags := chanP^.realProps;
   END;
   (* Neue Position anfahren *)
   newPos := file.lseek(handle, newPos, file.SeekSet);
   IF newPos < VAL(types.offT,0) THEN
     tid^.errNum := errno;
#ifdef __NO_IO_EXCEPTIONS__
     RETURN;
#else
     EXCEPTIONS.RAISE(iolibSource, ORD(softDeviceError), (* RETRY moeglich *)
                      "RndFile: 'SetPos' failed");
#endif
   END;
   pos      := 0;
   readSize := 0;
 END;
END SetPos;

(*---------------------------------------------------------------------------*)

PROCEDURE Close ((* EIN/AUS *) VAR cid : ChanId );

VAR tid : DeviceTablePtr;

BEGIN
 tid := DeviceTablePtrValue(cid, rndDevice);
 rndFree(tid);
 UnMakeChan(rndDevice, cid);
END Close;

(*===========================================================================*)

BEGIN (* RndFile *)
 EXCEPTIONS.AllocateSource(rndFileSource);
 AllocateDeviceId(rndDevice);
 badChanId := InvalidChan();
 nl        := types.LF;
END RndFile.
