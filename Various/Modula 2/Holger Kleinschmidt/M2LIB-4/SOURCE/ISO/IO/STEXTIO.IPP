IMPLEMENTATION MODULE STextIO;
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
(* 10-Jun-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;
#ifdef MM2
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, UNSIGNED;

IMPORT types;

IMPORT EXCEPTIONS;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM StdChans IMPORT
(* PROC *) InChan, OutChan;

IMPORT IOChan;

FROM IOConsts IMPORT
(* TYPE *) ReadResults;

FROM IOLink IMPORT
(* TYPE *) DeviceTablePtr, DeviceTable;

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  BUFSIZE = 128;

VAR
  buf : ARRAY [0..BUFSIZE-1] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE raiseNotChannel;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAChannel),
                  "STextIO: Not a channel");
END raiseNotChannel;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadChar ((* -- /AUS *) VAR ch : CHAR );

VAR         res : ReadResults;
#ifdef MM2
            tid : DeviceTablePtr;
#else
    __REG__ tid : DeviceTablePtr;
#endif

BEGIN
 tid := CAST(DeviceTablePtr,InChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doLook(tid, ch, res);
 IF res = allRight THEN
   tid^.doSkip(tid);
 END;
END ReadChar;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadRestLine ((* -- /AUS *) VAR s : ARRAY OF CHAR );

VAR __REG__ nRead  : UNSIGNED;
    __REG__ toRead : UNSIGNED;
#ifdef MM2
            tid    : DeviceTablePtr;
#else
    __REG__ tid    : DeviceTablePtr;
#endif
            thisN  : UNSIGNED;

BEGIN
 tid := CAST(DeviceTablePtr,InChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;

 tid^.errNum := 0;

 s[0] := types.EOS;
 (* Solange lesen bis der String gefuellt ist oder keine Zeichen mehr
  * in der aktuellen Zeile vorhanden sind.
  *)
 toRead := VAL(UNSIGNED,HIGH(s)) + VAL(UNSIGNED,1);
 nRead  := 0;
 REPEAT
   tid^.doTextRead(tid, ADDADR(ADR(s), nRead), toRead, thisN);
   DEC(toRead, thisN);
   INC(nRead, thisN);
 UNTIL (toRead = VAL(UNSIGNED,0)) OR (thisN = VAL(UNSIGNED,0));

 IF nRead <= VAL(UNSIGNED,HIGH(s)) THEN
   (* Es wurden weniger Zeichen gelesen als in den String passen *)
   s[VAL(UNSIGNEDWORD,nRead)] := types.EOS;
   IF nRead > VAL(UNSIGNED,0) THEN
     tid^.result := allRight;
   END;
   (* Wenn nichts gelesen wurde (nRead = 0), ist das Resultat ('endOfLine'
    * oder 'endOfInput') bereits durch "TextRead()" gesetzt.
    *)
   RETURN;
 END;

 (* Der String wurde vollstaendig gefuellt; jetzt muss festgestellt
  * werden, ob Zeile oder Kanal zuende sind.
  *)
 tid^.doTextRead(tid, ADR(buf), BUFSIZE, thisN);
 IF thisN = VAL(UNSIGNED,0) THEN
   tid^.result := allRight;
   RETURN;
 END;

 (* Bis zum Ende der Zeile oder des Kanals lesen *)
 REPEAT
   tid^.doTextRead(tid, ADR(buf), BUFSIZE, thisN);
 UNTIL thisN = VAL(UNSIGNED,0);
 tid^.result := outOfRange;
END ReadRestLine;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadString ((* -- /AUS *) VAR s : ARRAY OF CHAR );

VAR __REG__ nRead  : UNSIGNED;
    __REG__ toRead : UNSIGNED;
#ifdef MM2
            tid    : DeviceTablePtr;
#else
    __REG__ tid    : DeviceTablePtr;
#endif
            thisN  : UNSIGNED;

BEGIN
 tid := CAST(DeviceTablePtr,InChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;

 s[0] := types.EOS;
 (* Solange lesen bis der String gefuellt ist oder keine Zeichen mehr
  * in der aktuellen Zeile vorhanden sind.
  *)
 toRead := VAL(UNSIGNED,HIGH(s)) + VAL(UNSIGNED,1);
 nRead  := 0;
 REPEAT
   tid^.doTextRead(tid, ADDADR(ADR(s), nRead), toRead, thisN);
   DEC(toRead, thisN);
   INC(nRead, thisN);
 UNTIL (toRead = VAL(UNSIGNED,0)) OR (thisN = VAL(UNSIGNED,0));

 IF nRead <= VAL(UNSIGNED,HIGH(s)) THEN
   (* Es wurden weniger Zeichen gelesen als in den String passen *)
   s[VAL(UNSIGNEDWORD,nRead)] := types.EOS;
   IF nRead > VAL(UNSIGNED,0) THEN
     tid^.result := allRight;
   END;
   (* Wenn nichts gelesen wurde (nRead = 0), ist das Resultat ('endOfLine'
    * oder 'endOfInput') bereits durch "TextRead()" gesetzt.
    *)
 END;
END ReadString;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadToken ((* -- /AUS *) VAR s : ARRAY OF CHAR );

VAR __REG__ idx  : UNSIGNEDWORD;
#ifdef MM2
            tid  : DeviceTablePtr;
#else
    __REG__ tid  : DeviceTablePtr;
#endif
            ch   : CHAR;
            res  : ReadResults;

BEGIN
 tid := CAST(DeviceTablePtr,InChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;

 tid^.errNum := 0;

 s[0] := types.EOS;
 tid^.doLook(tid, ch, res);
 WHILE ch = ' ' DO
 (* Falls 'ch' bei 'res' # 'allRight' undefiniert:
 WHILE (res = allRight) & (ch = ' ') DO
 *)
   (* Fuehrende Leerzeichen ueberlesen *)
   tid^.doSkipLook(tid, ch, res);
 END;
 idx := 0;
 IF res = allRight THEN
   (* Es gibt mindestens ein Zeichen, das weder Leerzeichen noch
    * Zeilenende ist.
    *)
   REPEAT
     s[idx] := ch;
     INC(idx);
     tid^.doSkipLook(tid, ch, res);
   UNTIL (ch = ' ') OR (idx > VAL(UNSIGNEDWORD,HIGH(s))) OR (res # allRight);

   IF (ch = ' ') OR (res # allRight) THEN
     (* Wenn das Ergebnis von "SkipLook()" nicht 'allRight' ist, kann es
      * nur 'endOfLine' oder 'endOfInput' sein; da aber bereits mindestens
      * ein Zeichen gelesen wurde, ist 'allRight' das korrekte Resultat.
      *)
     tid^.result := allRight;
   ELSE
     (* Wenn ein Nicht-Leerzeichen gelesen wurde, wurde die Schleife
      * abgebrochen, weil der String zu klein ist.
      *)
     tid^.result := outOfRange;
   END;
 END;

 IF idx <= VAL(UNSIGNEDWORD,HIGH(s)) THEN
   s[idx] := types.EOS;
 END;
END ReadToken;

(*---------------------------------------------------------------------------*)

PROCEDURE SkipLine;

VAR         read : UNSIGNED;
#ifdef MM2
            tid  : DeviceTablePtr;
#else
    __REG__ tid  : DeviceTablePtr;
#endif

BEGIN
 tid := CAST(DeviceTablePtr,InChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;

 (* Bis zum Ende der Zeile oder des Kanals lesen *)
 REPEAT
   tid^.doTextRead(tid, ADR(buf), BUFSIZE, read);
 UNTIL (read = VAL(UNSIGNED,0));
 IF tid^.result = endOfLine THEN
   tid^.doSkip(tid);
 END;
END SkipLine;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteChar ((* EIN/ -- *) ch : CHAR );
#ifdef MM2
VAR         tid : DeviceTablePtr;
#else
VAR __REG__ tid : DeviceTablePtr;
#endif

BEGIN
 tid := CAST(DeviceTablePtr,OutChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doTextWrite(tid, ADR(ch), 1);
END WriteChar;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteLn;

#ifdef MM2
VAR         tid : DeviceTablePtr;
#else
VAR __REG__ tid : DeviceTablePtr;
#endif

BEGIN
 tid := CAST(DeviceTablePtr,OutChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doWriteLn(tid);
END WriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteString ((* EIN/ -- *) REF s : ARRAY OF CHAR );

#ifdef MM2
VAR         tid : DeviceTablePtr;
#else
VAR __REG__ tid : DeviceTablePtr;
#endif

#if !((defined ISOM2) || (defined MM2) || (defined HM2))
 PROCEDURE LENGTH (VAR s : ARRAY OF CHAR): UNSIGNEDWORD;
 __REG__ VAR i : UNSIGNEDWORD;
 BEGIN
  i := 0;
  WHILE (i <= VAL(UNSIGNEDWORD,HIGH(s))) & (s[i] # types.EOS) DO
    INC(i);
  END;
  RETURN(i);
 END LENGTH;
#endif
BEGIN
 tid := CAST(DeviceTablePtr,OutChan());
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
#ifdef MM2
 tid^.doTextWrite(tid, CADR(s), VAL(UNSIGNED,LENGTH(s)));
#else
 tid^.doTextWrite(tid, ADR(s), VAL(UNSIGNED,LENGTH(s)));
#endif
END WriteString;

END STextIO.
