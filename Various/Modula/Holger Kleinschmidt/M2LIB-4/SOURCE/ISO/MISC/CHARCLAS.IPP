IMPLEMENTATION MODULE CharClass;
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
(* 29-Jun-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

FROM LCTypes IMPORT
(* TYPE *) CType, CClass, LCCtype;

FROM LC IMPORT
(* VAR  *) Ctype;

(*===========================================================================*)

PROCEDURE IsNumeric ((* EIN/ -- *) ch : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISdigit IN Ctype^.class[ch]);
END IsNumeric;

(*---------------------------------------------------------------------------*)

PROCEDURE IsLetter ((* EIN/ -- *) ch : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalpha IN Ctype^.class[ch]);
END IsLetter;

(*---------------------------------------------------------------------------*)

PROCEDURE IsUpper ((* EIN/ -- *) ch : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISupper IN Ctype^.class[ch]);
END IsUpper;

(*---------------------------------------------------------------------------*)

PROCEDURE IsLower ((* EIN/ -- *) ch : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISlower IN Ctype^.class[ch]);
END IsLower;

(*---------------------------------------------------------------------------*)

PROCEDURE IsControl ((* EIN/ -- *) ch : CHAR ): BOOLEAN;
BEGIN
 RETURN(IScntrl IN Ctype^.class[ch]);
END IsControl;

(*---------------------------------------------------------------------------*)

PROCEDURE IsWhiteSpace ((* EIN/ -- *) ch : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISspace IN Ctype^.class[ch]);
END IsWhiteSpace;

END CharClass.
