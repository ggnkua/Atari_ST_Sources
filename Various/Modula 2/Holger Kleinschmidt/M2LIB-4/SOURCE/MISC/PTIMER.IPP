IMPLEMENTATION MODULE pTIMER;
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
(* Okt-90 / 20-Mae-95, Holger Kleinschmidt                                   *)
(*****************************************************************************)

FROM types IMPORT
(* TYPE *) clockT;

FROM proc IMPORT
(* TYPE *) TmsRec,
(* PROC *) times;

FROM sig IMPORT
(* PROC *) sleep;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Start ((* -- /AUS *) VAR starttime : clockT );

VAR tms : TmsRec;

BEGIN
 starttime := times(tms);
END Start;

(*---------------------------------------------------------------------------*)

PROCEDURE Stop ((* EIN/ -- *) starttime : clockT ): clockT;

VAR tms : TmsRec;

BEGIN
 RETURN(times(tms) - starttime);
END Stop;

(*---------------------------------------------------------------------------*)

PROCEDURE Wait ((* EIN/ -- *) secs : CARDINAL );

VAR left : CARDINAL;

BEGIN
 left := sleep(secs);
END Wait;

END pTIMER.
