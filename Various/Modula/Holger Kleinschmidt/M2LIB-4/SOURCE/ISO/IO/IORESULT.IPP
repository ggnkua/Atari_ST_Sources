IMPLEMENTATION MODULE IOResult;
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


IMPORT EXCEPTIONS;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM IOLink IMPORT
(* TYPE *) DeviceTable, DeviceTablePtr;

IMPORT IOChan;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReadResult ((* EIN/ -- *) cid : IOChan.ChanId ): ReadResults;

VAR __REG__ tid : DeviceTablePtr;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   EXCEPTIONS.RAISE(iolibSource, ORD(IOChan.notAChannel),
                    "IOResult: Not a channel");
 END;
 RETURN(tid^.result);
END ReadResult;

END IOResult.
