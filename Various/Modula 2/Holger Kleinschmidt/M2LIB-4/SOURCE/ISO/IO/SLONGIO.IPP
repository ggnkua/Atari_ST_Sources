IMPLEMENTATION MODULE SLongIO;
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
(* 21-Sep-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

FROM StdChans IMPORT
(* PROC *) InChan, OutChan;

IMPORT LongIO;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReadReal ((* -- /AUS *) VAR real : LONGREAL );
BEGIN
 LongIO.ReadReal(InChan(), real);
END ReadReal;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFloat ((* EIN/ -- *) real    : LONGREAL;
                      (* EIN/ -- *) sigFigs : CARDINAL;
                      (* EIN/ -- *) width   : CARDINAL  );
BEGIN
 LongIO.WriteFloat(OutChan(), real, sigFigs, width);
END WriteFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteEng ((* EIN/ -- *) real    : LONGREAL;
                    (* EIN/ -- *) sigFigs : CARDINAL;
                    (* EIN/ -- *) width   : CARDINAL );
BEGIN
 LongIO.WriteEng(OutChan(), real, sigFigs, width);
END WriteEng;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFixed ((* EIN/ -- *) real   : LONGREAL;
                      (* EIN/ -- *) places : INTEGER;
                      (* EIN/ -- *) width  : CARDINAL );
BEGIN
 LongIO.WriteFixed(OutChan(), real, places, width);
END WriteFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteReal ((* EIN/ -- *) real   : LONGREAL;
                     (* EIN/ -- *) width  : CARDINAL );
BEGIN
 LongIO.WriteReal(OutChan(), real, width);
END WriteReal;

END SLongIO.
