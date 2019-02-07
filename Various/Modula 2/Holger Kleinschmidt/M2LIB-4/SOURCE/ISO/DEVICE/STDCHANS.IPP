IMPLEMENTATION MODULE StdChans;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
(*$E+*)
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

VAL_INTRINSIC
CAST_IMPORT

IMPORT StdChanBase, IOChan;

IMPORT DosSystem;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

#if 0
TYPE
  ChanId = DeviceTablePtr;
#endif


VAR
  nullChanId : ChanId;
  inChanId   : ChanId;
  outChanId  : ChanId;
  errChanId  : ChanId;

(*===========================================================================*)

PROCEDURE StdInChan ( ): ChanId;
BEGIN
 RETURN(CAST(ChanId,StdChanBase.StdInChanId));
END StdInChan;

(*---------------------------------------------------------------------------*)

PROCEDURE StdOutChan ( ): ChanId;
BEGIN
 RETURN(CAST(ChanId,StdChanBase.StdOutChanId));
END StdOutChan;

(*---------------------------------------------------------------------------*)

PROCEDURE StdErrChan ( ): ChanId;
BEGIN
 RETURN(CAST(ChanId,StdChanBase.StdErrChanId));
END StdErrChan;

(*---------------------------------------------------------------------------*)

PROCEDURE NullChan ( ): ChanId;
BEGIN
 RETURN(CAST(ChanId,StdChanBase.NullChanId));
END NullChan;

(*---------------------------------------------------------------------------*)

PROCEDURE InChan ( ): ChanId;
BEGIN
 RETURN(inChanId);
END InChan;

(*---------------------------------------------------------------------------*)

PROCEDURE OutChan ( ): ChanId;
BEGIN
 RETURN(outChanId);
END OutChan;

(*---------------------------------------------------------------------------*)

PROCEDURE ErrChan ( ): ChanId;
BEGIN
 RETURN(errChanId);
END ErrChan;

(*---------------------------------------------------------------------------*)

PROCEDURE SetInChan ((* EIN/ -- *) cid : ChanId );
BEGIN
 inChanId := cid;
END SetInChan;

(*---------------------------------------------------------------------------*)

PROCEDURE SetOutChan ((* EIN/ -- *) cid : ChanId );
BEGIN
 outChanId := cid;
END SetOutChan;

(*---------------------------------------------------------------------------*)

PROCEDURE SetErrChan ((* EIN/ -- *) cid : ChanId );
BEGIN
 errChanId := cid;
END SetErrChan;

(*---------------------------------------------------------------------------*)

PROCEDURE Finalize;
BEGIN
 IOChan.Flush(CAST(ChanId,StdChanBase.StdOutChanId));
END Finalize;

(*===========================================================================*)

#ifndef ISOM2
VAR i : INTEGER;
#endif
BEGIN (* StdChans *)
 nullChanId := CAST(ChanId,StdChanBase.NullChanId);
 inChanId   := CAST(ChanId,StdChanBase.StdInChanId);
 outChanId  := CAST(ChanId,StdChanBase.StdOutChanId);
 errChanId  := CAST(ChanId,StdChanBase.StdErrChanId);

#ifdef ISOM2
FINALLY (* StdChans *)
 Finalize;

EXCEPT
 RETURN; (* Fehler ignorieren *)
#else
 i := DosSystem.atexit(Finalize);
#endif
END StdChans.
