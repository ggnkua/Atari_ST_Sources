IMPLEMENTATION MODULE ctype;
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
(* 18-Apr-93, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC

FROM LCTypes IMPORT
(* TYPE *) CType, CClass, LCCtype;

FROM LC IMPORT
(* VAR  *) Ctype;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE iscntrl ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(IScntrl IN Ctype^.class[c]);
END iscntrl;

(*---------------------------------------------------------------------------*)

PROCEDURE isspace ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISspace IN Ctype^.class[c]);
END isspace;

(*---------------------------------------------------------------------------*)

PROCEDURE isblank  ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISblank IN Ctype^.class[c]);
END isblank;

(*---------------------------------------------------------------------------*)

PROCEDURE islower ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISlower IN Ctype^.class[c]);
END islower;

(*---------------------------------------------------------------------------*)

PROCEDURE isupper ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISupper IN Ctype^.class[c]);
END isupper;

(*---------------------------------------------------------------------------*)

PROCEDURE isalpha ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalpha IN Ctype^.class[c]);
END isalpha;

(*---------------------------------------------------------------------------*)

PROCEDURE isdigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISdigit IN Ctype^.class[c]);
END isdigit;

(*---------------------------------------------------------------------------*)

PROCEDURE isxdigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISxdigit IN Ctype^.class[c]);
END isxdigit;

(*---------------------------------------------------------------------------*)

PROCEDURE isalnum ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalnum IN Ctype^.class[c]);
END isalnum;

(*---------------------------------------------------------------------------*)

PROCEDURE isgraph ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISgraph IN Ctype^.class[c]);
END isgraph;

(*---------------------------------------------------------------------------*)

PROCEDURE isprint ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISprint IN Ctype^.class[c]);
END isprint;

(*---------------------------------------------------------------------------*)

PROCEDURE ispunct ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISpunct IN Ctype^.class[c]);
END ispunct;

(*---------------------------------------------------------------------------*)

PROCEDURE tolower ((* EIN/ -- *) c : CHAR ): CHAR;
BEGIN
 RETURN(Ctype^.tolower[c]);
END tolower;

(*---------------------------------------------------------------------------*)

PROCEDURE toupper ((* EIN/ -- *) c : CHAR ): CHAR;
BEGIN
 RETURN(Ctype^.toupper[c]);
END toupper;

(*---------------------------------------------------------------------------*)

PROCEDURE isascii ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(c <= 177C);
END isascii;

(*---------------------------------------------------------------------------*)

PROCEDURE tocard ((* EIN/ -- *) c : CHAR ): CARDINAL;

VAR __REG__ class : CClass;

BEGIN
 class := Ctype^.class[c];
 IF ISdigit IN class THEN
   RETURN(VAL(CARDINAL,ORD(c) - ORD('0')));
 ELSIF ISupper IN class THEN
   RETURN(VAL(CARDINAL,ORD(c) - ORD('A') + 10));
 ELSIF ISlower IN class THEN
   RETURN(VAL(CARDINAL,ORD(c) - ORD('a') + 10));
 ELSE
   RETURN(VAL(CARDINAL,ORD('Z') + 1)); (* ``ungueltiger'' Wert *)
 END;
END tocard;

(*---------------------------------------------------------------------------*)

PROCEDURE todigit ((* EIN/ -- *) i : CARDINAL ): CHAR;
BEGIN
 IF i <= 9 THEN
   RETURN(CHR(i + VAL(CARDINAL,ORD('0'))));
 ELSE
   RETURN(CHR(i + VAL(CARDINAL,ORD('A')) - 10));
 END;
END todigit;

END ctype.
