IMPLEMENTATION MODULE SRealIO;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_REAL__
(*$!r+: Modul muss mit $r- uebersetzt werden! *)
#else
(*$!r-: Modul muss mit $r+ uebersetzt werden! *)
#endif
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

IMPORT RealIO;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReadReal ((* -- /AUS *) VAR real : REAL );
BEGIN
 RealIO.ReadReal(InChan(), real);
END ReadReal;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFloat ((* EIN/ -- *) real    : REAL;
                      (* EIN/ -- *) sigFigs : CARDINAL;
                      (* EIN/ -- *) width   : CARDINAL  );
BEGIN
 RealIO.WriteFloat(OutChan(), real, sigFigs, width);
END WriteFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteEng ((* EIN/ -- *) real    : REAL;
                    (* EIN/ -- *) sigFigs : CARDINAL;
                    (* EIN/ -- *) width   : CARDINAL );
BEGIN
 RealIO.WriteEng(OutChan(), real, sigFigs, width);
END WriteEng;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFixed ((* EIN/ -- *) real   : REAL;
                      (* EIN/ -- *) places : INTEGER;
                      (* EIN/ -- *) width  : CARDINAL );
BEGIN
 RealIO.WriteFixed(OutChan(), real, places, width);
END WriteFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteReal ((* EIN/ -- *) real   : REAL;
                     (* EIN/ -- *) width  : CARDINAL );
BEGIN
 RealIO.WriteReal(OutChan(), real, width);
END WriteReal;

END SRealIO.
