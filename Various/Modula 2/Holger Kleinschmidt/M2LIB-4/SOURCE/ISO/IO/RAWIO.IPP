IMPLEMENTATION MODULE RawIO;
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
(* 13-Mai-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

CAST_IMPORT
VAL_INTRINSIC
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR,
(* TYPE *) ADDRESS;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, ANYTYPE;

IMPORT EXCEPTIONS;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM IOConsts IMPORT
(* TYPE *) ReadResults;

IMPORT IOChan;

FROM IOLink IMPORT
(* TYPE *) DeviceTable, DeviceTablePtr;

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Read ((* EIN/ -- *)     cid : IOChan.ChanId;
                (* -- /AUS *) VAR to  : ARRAY OF ANYTYPE );

VAR __REG__ nRead  : UNSIGNED;
    __REG__ toRead : UNSIGNED;
#ifdef MM2
            tid    : DeviceTablePtr;
#else
    __REG__ tid    : DeviceTablePtr;
#endif
            thisN  : UNSIGNED;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAChannel),
                    "RawIO.Read: Not a channel");
 END;
 tid^.errNum := 0;
 (* Solange lesen bis das Feld gefuellt ist oder keine Bytes mehr
  * gelesen werden koennen.
  *)
 toRead := VAL(UNSIGNED,HIGH(to)) + VAL(UNSIGNED,1);
 nRead  := 0;
 REPEAT
   tid^.doRawRead(tid, ADDADR(ADR(to), nRead), toRead, thisN);
   DEC(toRead, thisN);
   INC(nRead, thisN);
 UNTIL (toRead = VAL(UNSIGNED,0)) OR (thisN = VAL(UNSIGNED,0));

 IF   (nRead # VAL(UNSIGNED,HIGH(to)) + VAL(UNSIGNED,1))
    & (nRead # VAL(UNSIGNED,0))
 THEN
   tid^.result := wrongFormat;
 END;
END Read;

(*---------------------------------------------------------------------------*)

PROCEDURE Write ((* EIN/ -- *) cid  : IOChan.ChanId;
                 (* EIN/ -- *) from : ARRAY OF ANYTYPE );

#ifdef MM2
VAR         tid : DeviceTablePtr;
#else
VAR __REG__ tid : DeviceTablePtr;
#endif

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAChannel),
                    "RawIO.Write: Not a channel");
 END;
 tid^.errNum := 0;
 tid^.doRawWrite(tid, ADR(from), VAL(UNSIGNED,HIGH(from)) + VAL(UNSIGNED,1));
END Write;

END RawIO.
