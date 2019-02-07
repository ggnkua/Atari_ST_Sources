IMPLEMENTATION MODULE SWholeIO;
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
(* 09-Jul-93, Holger Kleinschmidt                                            *)
(*****************************************************************************)

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, SIGNED;

FROM StdChans IMPORT
(* PROC *) InChan, OutChan;

IMPORT WholeIO;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReadInt ((* -- /AUS *) VAR int : SIGNED );
BEGIN
 WholeIO.ReadInt(InChan(), int);
END ReadInt;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteInt ((* EIN/ -- *) int   : SIGNED;
                    (* EIN/ -- *) width : CARDINAL );
BEGIN
 WholeIO.WriteInt(OutChan(), int, width);
END WriteInt;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadCard ((* -- /AUS *) VAR card : UNSIGNED );
BEGIN
 WholeIO.ReadCard(InChan(), card);
END ReadCard;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteCard ((* EIN/ -- *) card  : UNSIGNED;
                     (* EIN/ -- *) width : CARDINAL  );
BEGIN
 WholeIO.WriteCard(OutChan(), card, width);
END WriteCard;

END SWholeIO.
