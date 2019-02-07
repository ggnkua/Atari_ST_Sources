IMPLEMENTATION MODULE EXCEPTIONS;
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

OSCALL_IMPORT
PTR_ARITH_IMPORT
VAL_INTRINSIC

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) SIGNEDLONG, UNSIGNEDWORD;

FROM types IMPORT
(* CONST*) CR, LF, EOS;

FROM OSCALLS IMPORT
(* PROC *) Cconws, Salert;

FROM ISOStrings IMPORT
(* PROC *) Concat;

FROM DosSystem IMPORT
(* CONST*) ExitFailure, ExitSuccess,
(* PROC *) exit;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  ExceptionSource = POINTER TO ADDRESS;

CONST
  MAXBUF = 80;

VAR
  nextSource : CARDINAL;
  nl         : ARRAY [0..2] OF CHAR;
  buf        : ARRAY [0..MAXBUF] OF CHAR;
  line       : ARRAY [0..50] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE AllocateSource ((* -- /AUS *) VAR newSource : ExceptionSource );
BEGIN
 newSource := MAKEADR(nextSource);
 INC(nextSource);
END AllocateSource;

(*---------------------------------------------------------------------------*)

PROCEDURE RAISE ((* EIN/ -- *) source  : ExceptionSource;
                 (* EIN/ -- *) number  : ExceptionNumber;
                 (* EIN/ -- *) message : ARRAY OF CHAR   );

BEGIN
 Concat("M2-EXCEPTION RAISED: ", message, buf);
 buf[MAXBUF] := 0C;

 IF ~Salert(ADR(buf)) THEN
   Cconws(ADR(nl));
   Cconws(ADR(line));
   Cconws(ADR(nl));
   Cconws(ADR(buf));
   Cconws(ADR(nl));
   Cconws(ADR(line));
   Cconws(ADR(nl));
 END;

 IF number = ExitSuccess THEN
   exit(ExitFailure);
 ELSE
   exit(INT(number));
 END;
END RAISE;

(*---------------------------------------------------------------------------*)

PROCEDURE CurrentNumber
  ((* EIN/ -- *) source : ExceptionSource ): ExceptionNumber;
BEGIN
 RETURN(0);
END CurrentNumber;

(*---------------------------------------------------------------------------*)

PROCEDURE GetMessage ((* -- /AUS *) VAR text : ARRAY OF CHAR );
BEGIN
 text[0] := EOS;
END GetMessage;

(*---------------------------------------------------------------------------*)

PROCEDURE IsCurrentSource ((* EIN/ -- *) source : ExceptionSource ): BOOLEAN;
BEGIN
 RETURN(FALSE);
END IsCurrentSource;

(*---------------------------------------------------------------------------*)

PROCEDURE IsExceptionalExecution ( ): BOOLEAN;
BEGIN
 RETURN(FALSE);
END IsExceptionalExecution;

BEGIN (* EXCEPTIONS *)
 nextSource := 0;
 nl[0]      := CR;
 nl[1]      := LF;
 nl[2]      := 0C;
 line       := "*************************************************";
END EXCEPTIONS.
