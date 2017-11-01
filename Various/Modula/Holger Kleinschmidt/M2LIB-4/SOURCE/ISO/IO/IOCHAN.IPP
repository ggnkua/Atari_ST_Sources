IMPLEMENTATION MODULE IOChan;
__IMP_SWITCHES__
__DEBUG__
#ifdef MM2
/* sonst: interner Verifikationsfehler... */
#undef __REG__
#define __REG__
#endif
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

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED;

IMPORT types;

IMPORT EXCEPTIONS;

IMPORT IOConsts, ChanConsts;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM IOLink IMPORT
(* TYPE *) DeviceTablePtr, DeviceTable, DeviceId,
(* PROC *) AllocateDeviceId;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

TYPE
  ChanId = DeviceTablePtr;

VAR
  badChan   : DeviceTable;
  badChanId : ChanId;
  badDevice : DeviceId;

(*===========================================================================*)
(* Geraeteprozeduren fuer den ungueltigen Kanal                              *)
(*===========================================================================*)

PROCEDURE raiseBad;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                  "IOChan: Operation on invalid channel requested");
END raiseBad;

(*---------------------------------------------------------------------------*)

PROCEDURE raiseNotChannel;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(notAChannel),
                  "IOChan: Not a channel");
END raiseNotChannel;

(*---------------------------------------------------------------------------*)

#ifdef HM2
(*$E+*)
#endif
PROCEDURE badLook ((* -- / -- *)     bad : DeviceTablePtr;
                   (* -- / -- *) VAR ch  : CHAR;
                   (* -- / -- *) VAR res : IOConsts.ReadResults );
BEGIN
 raiseBad;
END badLook;

(*---------------------------------------------------------------------------*)

PROCEDURE badRead ((* -- / -- *)     bad  : DeviceTablePtr;
                   (* -- / -- *)     to   : ADDRESS;
                   (* -- / -- *)     size : UNSIGNED;
                   (* -- / -- *) VAR read : UNSIGNED       );
BEGIN
 raiseBad;
END badRead;

(*---------------------------------------------------------------------------*)

PROCEDURE badWrite ((* -- / -- *) bad  : DeviceTablePtr;
                    (* -- / -- *) from : ADDRESS;
                    (* -- / -- *) size : UNSIGNED       );
BEGIN
 raiseBad;
END badWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE badProc ((* -- / -- *) bad : DeviceTablePtr);
BEGIN
 raiseBad;
END badProc;

(*---------------------------------------------------------------------------*)

PROCEDURE badName ((* -- / -- *)     bad  : DeviceTablePtr;
                   (* -- /AUS *) VAR name : ARRAY OF CHAR  );
BEGIN
 name[0] := types.EOS;
END badName;
#ifdef HM2
(*$E=*)
#endif
(*===========================================================================*)

PROCEDURE InvalidChan ( ): ChanId;
BEGIN
 RETURN(badChanId);
END InvalidChan;

(*---------------------------------------------------------------------------*)

PROCEDURE Look ((* EIN/ -- *)     cid : ChanId;
                (* -- /AUS *) VAR ch  : CHAR;
                (* -- /AUS *) VAR res : IOConsts.ReadResults );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0; (* wird bei Fehler geaendert *)
 tid^.doLook(tid, ch, res);
END Look;

(*---------------------------------------------------------------------------*)

PROCEDURE Skip ((* EIN/ -- *) cid : ChanId );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doSkip(tid);
END Skip;

(*---------------------------------------------------------------------------*)

PROCEDURE SkipLook ((* EIN/ -- *)     cid : ChanId;
                    (* -- /AUS *) VAR ch  : CHAR;
                    (* -- /AUS *) VAR res : IOConsts.ReadResults );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doSkipLook(tid, ch, res);
END SkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteLn ((* EIN/ -- *) cid : ChanId );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doWriteLn(tid);
END WriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE TextRead ((* EIN/ -- *)     cid       : ChanId;
                    (* EIN/ -- *)     to        : ADDRESS;
                    (* EIN/ -- *)     maxChars  : UNSIGNED;
                    (* -- /AUS *) VAR charsRead : UNSIGNED  );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doTextRead(tid, to, maxChars, charsRead);
END TextRead;

(*---------------------------------------------------------------------------*)

PROCEDURE TextWrite ((* EIN/ -- *) cid          : ChanId;
                     (* EIN/ -- *) from         : ADDRESS;
                     (* EIN/ -- *) charsToWrite : UNSIGNED );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doTextWrite(tid, from, charsToWrite);
END TextWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE RawRead ((* EIN/ -- *)     cid      : ChanId;
                   (* EIN/ -- *)     to       : ADDRESS;
                   (* EIN/ -- *)     maxLocs  : UNSIGNED;
                   (* -- /AUS *) VAR locsRead : UNSIGNED );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doRawRead(tid, to, maxLocs, locsRead);
END RawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE RawWrite ((* EIN/ -- *) cid         : ChanId;
                    (* EIN/ -- *) from        : ADDRESS;
                    (* EIN/ -- *) locsToWrite : UNSIGNED );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doRawWrite(tid, from, locsToWrite);
END RawWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE GetName ((* EIN/ -- *)     cid : ChanId;
                   (* -- /AUS *) VAR s   : ARRAY OF CHAR );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doGetName(tid, s);
END GetName;

(*---------------------------------------------------------------------------*)

PROCEDURE Reset ((* EIN/ -- *) cid : ChanId );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doReset(tid);
END Reset;

(*---------------------------------------------------------------------------*)

PROCEDURE Flush ((* EIN/ -- *) cid : ChanId );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;
 tid^.doFlush(tid);
END Flush;

(*---------------------------------------------------------------------------*)

PROCEDURE SetReadResult ((* EIN/ -- *) cid : ChanId;
                         (* EIN/ -- *) res : IOConsts.ReadResults );

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.result := res;
END SetReadResult;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadResult ((* EIN/ -- *) cid : ChanId ): IOConsts.ReadResults;

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 RETURN(tid^.result);
END ReadResult;

(*---------------------------------------------------------------------------*)

PROCEDURE CurrentFlags ((* EIN/ -- *) cid : ChanId ): ChanConsts.FlagSet;

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 RETURN(tid^.flags);
END CurrentFlags;

(*---------------------------------------------------------------------------*)

PROCEDURE IsChanException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(iolibSource));
END IsChanException;

(*---------------------------------------------------------------------------*)

PROCEDURE ChanException ( ): ChanExceptions;
BEGIN
 RETURN(VAL(ChanExceptions,EXCEPTIONS.CurrentNumber(iolibSource)));
END ChanException;

(*---------------------------------------------------------------------------*)

PROCEDURE DeviceError ((* EIN/ -- *) cid : ChanId ): DeviceErrNum;

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 RETURN(tid^.errNum);
END DeviceError;

(*===========================================================================*)

BEGIN (* IOChan *)
 AllocateDeviceId(badDevice);
 badChanId := CAST(ChanId,ADR(badChan));
#if ISO_value_constructor
 badChan := DeviceTable{NIL,
                        badDevice, badChanId,
                        IOConsts.notKnown, 0, ChanConsts.FlagSet{},
                        badLook, badProc, badLook, badProc, badRead, badWrite,
                        badRead, badWrite, badName, badProc, badProc, badProc
                       };
#else
 WITH badChan DO
   cd          := NIL;
   did         := badDevice;
   cid         := badChanId;
   result      := IOConsts.notKnown;
   errNum      := 0;
   flags       := ChanConsts.FlagSet{};
   doLook      := badLook;
   doSkip      := badProc;
   doSkipLook  := badLook;
   doWriteLn   := badProc;
   doTextRead  := badRead;
   doTextWrite := badWrite;
   doRawRead   := badRead;
   doRawWrite  := badWrite;
   doGetName   := badName;
   doReset     := badProc;
   doFlush     := badProc;
   doFree      := badProc;
 END;
#endif
END IOChan.
