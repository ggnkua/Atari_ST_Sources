IMPLEMENTATION MODULE IOLink;
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
(* 26-Dez-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

IMPORT EXCEPTIONS;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, UNSIGNEDWORD;

FROM er IMPORT
(* CONST*) EIO;

IMPORT types, DosSystem;

IMPORT IOConsts, ChanConsts;

FROM IOshare IMPORT
(* VAR  *) iolibSource, nextDid;

IMPORT IOChan; (* TYPE ChanExceptions *)
FROM IOChan IMPORT
(* TYPE *) ChanId,
(* PROC *) InvalidChan;

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS;

FROM ISOStorage IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  MAXOPEN = 32;

TYPE
  DeviceId = POINTER TO ADDRESS;

VAR
  openChans : ARRAY [0..MAXOPEN] OF DeviceTablePtr;

(*===========================================================================*)
(* Defaultoperationen fuer die Initialisierung von Kanaelen                  *)
(*===========================================================================*)

PROCEDURE raiseDevice;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.wrongDevice),
                  "IO-Lib: Wrong device");
END raiseDevice;

(*---------------------------------------------------------------------------*)

#ifdef HM2
(*$E+*)
#endif
PROCEDURE defSkip ((* -- / -- *) chan : DeviceTablePtr );
BEGIN
 chan^.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAvailable),
                  "IO-Lib: 'Skip' not available");
END defSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE defLook ((* -- / -- *)     chan : DeviceTablePtr;
                   (* -- / -- *) VAR ch   : CHAR;
                   (* -- / -- *) VAR res  : IOConsts.ReadResults );
BEGIN
 chan^.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAvailable),
                  "IO-Lib: '[Skip]Look' not available");
END defLook;

(*---------------------------------------------------------------------------*)

PROCEDURE defWriteLn ((* -- / -- *) chan : DeviceTablePtr );
BEGIN
 chan^.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAvailable),
                  "IO-Lib: 'WriteLn' not available");
END defWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE defRead ((* -- / -- *)     chan : DeviceTablePtr;
                   (* -- / -- *)     to   : ADDRESS;
                   (* -- / -- *)     size : UNSIGNED;
                   (* -- / -- *) VAR read : UNSIGNED       );
BEGIN
 chan^.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAvailable),
                  "IO-Lib: 'Read' not available");
END defRead;

(*---------------------------------------------------------------------------*)

PROCEDURE defWrite ((* -- / -- *) chan : DeviceTablePtr;
                    (* -- / -- *) from : ADDRESS;
                    (* -- / -- *) size : UNSIGNED       );
BEGIN
 chan^.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAvailable),
                  "IO-Lib: 'Write' not available");
END defWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE defName ((* -- / -- *)     chan : DeviceTablePtr;
                   (* -- /AUS *) VAR name : ARRAY OF CHAR  );
BEGIN
 name[0] := types.EOS;
END defName;

(*---------------------------------------------------------------------------*)

PROCEDURE defProc ((* -- / -- *) chan : DeviceTablePtr );
END defProc;
#ifdef HM2
(*$E=*)
#endif

(*===========================================================================*)

PROCEDURE AllocateDeviceId ((* -- /AUS *) VAR did : DeviceId );
BEGIN
 did := CAST(DeviceId,MAKEADR(nextDid));
 INC(nextDid);
END AllocateDeviceId;

(*---------------------------------------------------------------------------*)

PROCEDURE MakeChan ((* EIN/ -- *)     d : DeviceId;
                    (* -- /AUS *) VAR c : ChanId   );

VAR         newChan : DeviceTablePtr;
    __REG__ i       : UNSIGNEDWORD;

BEGIN
 c := InvalidChan();
 (* Einen freien Platz fuer den neuen Kanal suchen *)
 i := 0;
 openChans[MAXOPEN] := NIL;
 WHILE openChans[i] # NIL DO
   INC(i);
 END;

 IF i < MAXOPEN THEN
   NEW(newChan);
   IF newChan # NIL THEN
     (* Der neue Kanal wird mit den Defaultoperationen initialisiert *)
     openChans[i] := newChan;
     c := CAST(ChanId,newChan);
#if ISO_value_constructor
     newChan^ := DeviceTable{NIL,
                             d, c,
                             IOConsts.notKnown, 0, ChanConsts.FlagSet{},
                             defLook, defSkip, defLook, defWriteLn, defRead,
                             defWrite, defRead, defWrite, defName, defProc,
                             defProc, defProc
                            };
#else
     WITH newChan^ DO
       cd          := NIL;
       did         := d;
       cid         := c;
       result      := IOConsts.notKnown;
       errNum      := 0;
       flags       := ChanConsts.FlagSet{};
       doLook      := defLook;
       doSkip      := defSkip;
       doSkipLook  := defLook;
       doWriteLn   := defWriteLn;
       doTextRead  := defRead;
       doTextWrite := defWrite;
       doRawRead   := defRead;
       doRawWrite  := defWrite;
       doGetName   := defName;
       doReset     := defProc;
       doFlush     := defProc;
       doFree      := defProc;
     END;
#endif
   END;
 END;
END MakeChan;

(*---------------------------------------------------------------------------*)

PROCEDURE isDevice ((* EIN/ -- *)     cid : ChanId;
                    (* EIN/ -- *)     did : DeviceId;
                    (* -- /AUS *) VAR idx : UNSIGNEDWORD;
                    (* -- /AUS *) VAR tid : DeviceTablePtr ): BOOLEAN;

VAR __REG__ i  : UNSIGNEDWORD;
    __REG__ id : DeviceTablePtr;

BEGIN
 id := CAST(DeviceTablePtr,cid);
 (* Gibt es diesen Kanal? *)
 i := 0;
 openChans[MAXOPEN] := id;
 WHILE openChans[i] # id DO
   INC(i);
 END;

 IF (id = NIL) OR (i = MAXOPEN) THEN
   EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAChannel),
                    "IO-Lib: Not a channel");
 ELSE
   tid := id;
   idx := i;
   (* Ist der Geraetetreiber fuer den Kanal zustaendig? *)
   RETURN(id^.did = did);
 END;
END isDevice;

(*---------------------------------------------------------------------------*)

PROCEDURE IsDevice ((* EIN/ -- *) cid : ChanId;
                    (* EIN/ -- *) did : DeviceId ): BOOLEAN;

VAR tid : DeviceTablePtr;
    idx : UNSIGNEDWORD;

BEGIN
 RETURN(isDevice(cid, did, idx, tid));
END IsDevice;

(*---------------------------------------------------------------------------*)

PROCEDURE UnMakeChan ((* EIN/ -- *)     did : DeviceId;
                      (* EIN/AUS *) VAR cid : ChanId   );

VAR tid : DeviceTablePtr;
    idx : UNSIGNEDWORD;

BEGIN
 IF ~isDevice(cid, did, idx, tid) THEN
   raiseDevice;
 END;
 openChans[idx] := NIL;
 DISPOSE(tid);
 cid := InvalidChan();
END UnMakeChan;

(*---------------------------------------------------------------------------*)

PROCEDURE DeviceTablePtrValue
  ((* EIN/ -- *) cid : ChanId;
   (* EIN/ -- *) did : DeviceId ): DeviceTablePtr;

VAR tid : DeviceTablePtr;
    idx : UNSIGNEDWORD;

BEGIN
 IF ~isDevice(cid, did, idx, tid) THEN
   raiseDevice;
 END;
 RETURN(tid);
END DeviceTablePtrValue;

(*---------------------------------------------------------------------------*)

PROCEDURE RAISEdevException ((* EIN/ -- *) cid : ChanId;
                             (* EIN/ -- *) did : DeviceId;
                             (* EIN/ -- *) x   : DevExceptionRange;
                             (* EIN/ -- *) s   : ARRAY OF CHAR     );

VAR tid : DeviceTablePtr;
    idx : UNSIGNEDWORD;

BEGIN
 IF ~isDevice(cid, did, idx, tid) THEN
   raiseDevice;
 END;
 EXCEPTIONS.RAISE(iolibSource, ORD(x), s);
END RAISEdevException;

(*---------------------------------------------------------------------------*)

PROCEDURE IsIOException ( ): BOOLEAN;
BEGIN
 RETURN(EXCEPTIONS.IsCurrentSource(iolibSource));
END IsIOException;

(*---------------------------------------------------------------------------*)

PROCEDURE IOException ( ): IOChan.ChanExceptions;
BEGIN
 RETURN(VAL(IOChan.ChanExceptions,EXCEPTIONS.CurrentNumber(iolibSource)));
END IOException;

(*---------------------------------------------------------------------------*)
#ifdef HM2
(*$E+*)
#endif
PROCEDURE Finalize;

VAR __REG__ i    : UNSIGNEDWORD;
            chan : DeviceTablePtr;

BEGIN
 FOR i := 0 TO MAXOPEN - 1 DO
   chan := openChans[i];
   IF chan # NIL THEN
     (* openChans[i] wird vor "rndFree()" auf NIL gesetzt, damit nicht
      * nocheinmal versucht wird, diesen Kanal zu schliessen, wenn eine
      * Ausnahme bei "rndFree()" auftritt, und weiter (wieder) versucht
      * wird, offene Kanaele zu schliessen.
      *)
     openChans[i] := NIL;
     chan^.doFree(chan);
     DISPOSE(chan);
   END;
 END;
END Finalize;
#ifdef HM2
(*$E=*)
#endif

(*===========================================================================*)

VAR i : INTEGER;

BEGIN (* IOLink *)
 FOR i := 0 TO MAXOPEN DO
   openChans[VAL(UNSIGNEDWORD,i)] := NIL;
 END;
 (* openChans[MAXOPEN] fungiert als Marke *)

#ifdef ISOM2
FINALLY (* IOLink *)
 Finalize;

EXCEPT
 (* Nicht durch Ausnahmen stoeren lassen. Es wird nochmal der
  * FINALLY-Block ausgefuehrt, um noch nicht geschlossene Kanaele
  * zu schliessen. Der fehlerverursachende Kanal wird ignoriert.
  *)
 RETRY;
#else
 i := DosSystem.atexit(Finalize);
#endif
END IOLink.
