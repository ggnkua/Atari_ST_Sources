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
(* 24-Mai-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC

FROM LCTypes IMPORT
(* TYPE *) CType, CClass, LCCtype;

IMPORT LC, LCPOSIX;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE iscntrl ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(IScntrl IN LC.Ctype^.class[c]);
END iscntrl;

(*---------------------------------------------------------------------------*)

PROCEDURE isspace ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISspace IN LC.Ctype^.class[c]);
END isspace;

(*---------------------------------------------------------------------------*)

PROCEDURE isblank  ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISblank IN LC.Ctype^.class[c]);
END isblank;

(*---------------------------------------------------------------------------*)

PROCEDURE islower ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISlower IN LC.Ctype^.class[c]);
END islower;

(*---------------------------------------------------------------------------*)

PROCEDURE isupper ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISupper IN LC.Ctype^.class[c]);
END isupper;

(*---------------------------------------------------------------------------*)

PROCEDURE isalpha ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalpha IN LC.Ctype^.class[c]);
END isalpha;

(*---------------------------------------------------------------------------*)

PROCEDURE isodigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISodigit IN LC.Ctype^.class[c]);
END isodigit;

(*---------------------------------------------------------------------------*)

PROCEDURE isdigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISdigit IN LC.Ctype^.class[c]);
END isdigit;

(*---------------------------------------------------------------------------*)

PROCEDURE isxdigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISxdigit IN LC.Ctype^.class[c]);
END isxdigit;

(*---------------------------------------------------------------------------*)

PROCEDURE isalnum ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalnum IN LC.Ctype^.class[c]);
END isalnum;

(*---------------------------------------------------------------------------*)

PROCEDURE isgraph ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISgraph IN LC.Ctype^.class[c]);
END isgraph;

(*---------------------------------------------------------------------------*)

PROCEDURE isprint ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISprint IN LC.Ctype^.class[c]);
END isprint;

(*---------------------------------------------------------------------------*)

PROCEDURE ispunct ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISpunct IN LC.Ctype^.class[c]);
END ispunct;

(*---------------------------------------------------------------------------*)

PROCEDURE tolower ((* EIN/ -- *) c : CHAR ): CHAR;
BEGIN
 RETURN(LC.Ctype^.tolower[c]);
END tolower;

(*---------------------------------------------------------------------------*)

PROCEDURE toupper ((* EIN/ -- *) c : CHAR ): CHAR;
BEGIN
 RETURN(LC.Ctype^.toupper[c]);
END toupper;

(*---------------------------------------------------------------------------*)

PROCEDURE Ciscntrl ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(IScntrl IN LCPOSIX.Ctype^.class[c]);
END Ciscntrl;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisspace ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISspace IN LCPOSIX.Ctype^.class[c]);
END Cisspace;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisblank  ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISblank IN LCPOSIX.Ctype^.class[c]);
END Cisblank;

(*---------------------------------------------------------------------------*)

PROCEDURE Cislower ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISlower IN LCPOSIX.Ctype^.class[c]);
END Cislower;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisupper ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISupper IN LCPOSIX.Ctype^.class[c]);
END Cisupper;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisalpha ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalpha IN LCPOSIX.Ctype^.class[c]);
END Cisalpha;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisodigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISodigit IN LCPOSIX.Ctype^.class[c]);
END Cisodigit;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisdigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISdigit IN LCPOSIX.Ctype^.class[c]);
END Cisdigit;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisxdigit ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISxdigit IN LCPOSIX.Ctype^.class[c]);
END Cisxdigit;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisalnum ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISalnum IN LCPOSIX.Ctype^.class[c]);
END Cisalnum;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisgraph ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISgraph IN LCPOSIX.Ctype^.class[c]);
END Cisgraph;

(*---------------------------------------------------------------------------*)

PROCEDURE Cisprint ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISprint IN LCPOSIX.Ctype^.class[c]);
END Cisprint;

(*---------------------------------------------------------------------------*)

PROCEDURE Cispunct ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(ISpunct IN LCPOSIX.Ctype^.class[c]);
END Cispunct;

(*---------------------------------------------------------------------------*)

PROCEDURE Ctolower ((* EIN/ -- *) c : CHAR ): CHAR;
BEGIN
 RETURN(LCPOSIX.Ctype^.tolower[c]);
END Ctolower;

(*---------------------------------------------------------------------------*)

PROCEDURE Ctoupper ((* EIN/ -- *) c : CHAR ): CHAR;
BEGIN
 RETURN(LCPOSIX.Ctype^.toupper[c]);
END Ctoupper;

(*---------------------------------------------------------------------------*)

PROCEDURE isascii ((* EIN/ -- *) c : CHAR ): BOOLEAN;
BEGIN
 RETURN(c <= 177C);
END isascii;

(*---------------------------------------------------------------------------*)

PROCEDURE tocard ((* EIN/ -- *) c : CHAR ): CARDINAL;

VAR __REG__ class : CClass;

BEGIN
 class := LCPOSIX.Ctype^.class[c];
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
   RETURN(CHR(i + VAL(CARDINAL,ORD('a')) - 10));
 END;
END todigit;

END ctype.
