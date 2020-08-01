MODULE Out;

(*****************************************************************************)
(* Oakwood-like Out.                                                         *)
(* --------------------------------------------------------------------------*)
(* 30-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* Basic character output is done through module IO (procedures 'WriteLn',
   'WriteChar' and 'WriteString'). Therefore you can change behaviour
   of output (buffer etc.) with the relevant procedures of IO.

   'Open' clears the screen in this implementation. The output format
   of the other procedures is supposed to conform to the Oakwood guidelines
   (max. 7 digits for 'Real' and 16 digits for 'LongReal').
   For further information, please refer to OAKWOOD.TXT or have a look at
   the sources.
 *)

IMPORT Strings, Conv:=FConvBase, IO;

TYPE
  NumberStr = ARRAY 30 OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Open*;
BEGIN
 IO.ClearHome;
END Open;

(*---------------------------------------------------------------------------*)

PROCEDURE Char* ((* EIN/ -- *) ch : CHAR );
BEGIN
 IO.WriteChar(ch);
END Char;

(*---------------------------------------------------------------------------*)

(*$-Y *)
PROCEDURE String* ((* EIN/ -- *) str : ARRAY OF CHAR );
BEGIN
 IO.WriteString(str);
END String;
(*$+Y *)

(*---------------------------------------------------------------------------*)

PROCEDURE Ln*;
BEGIN
 IO.WriteLn;
END Ln;

(*---------------------------------------------------------------------------*)

PROCEDURE out ((* EIN/ -- *)     width : INTEGER;
               (* EIN/ -- *) VAR str   : NumberStr );
BEGIN
 IF width > 0 THEN
   WHILE width >= 5 DO
     IO.WriteString("     ");
     DEC(width, 5);
   END;
   WHILE width > 0 DO
     IO.WriteChar(' ');
     DEC(width);
   END;
 END;
 IO.WriteString(str);
END out;

(*---------------------------------------------------------------------------*)

PROCEDURE Int* ((* EIN/ -- *) i     : LONGINT;
                (* EIN/ -- *) width : INTEGER );

VAR str  : NumberStr;
    neg  : BOOLEAN;
    idx  : INTEGER;
    idx2 : INTEGER;
    si   : INTEGER;

BEGIN
 IF i # MIN(LONGINT) THEN
   neg := i < 0;
   IF neg THEN
     i := -i;
   END;

   idx2 := SIZE(NumberStr)-1;
   (* 32-Bit-Arithmetik noetig *)
   WHILE i > MAX(INTEGER) DO
     str[idx2] := CHR(i MOD 10 + ORD('0'));
     i         := i DIV 10;
     DEC(idx2);
   END;
   (* Jetzt reicht 16-Bit-Arithmetik *)
   si := SHORT(i);
   REPEAT
     str[idx2] := CHR(si MOD 10 + ORD('0'));
     si        := si DIV 10;
     DEC(idx2);
   UNTIL si = 0;
   IF neg THEN
     str[idx2] := '-';
     DEC(idx2);
   END;
   INC(idx2);
   idx := 0;
   WHILE idx2 < SIZE(NumberStr) DO
     str[idx] := str[idx2];
     INC(idx);
     INC(idx2);
   END;
   str[idx] := 0X;
 ELSE
   str := "-2147483648";
   idx := 11;
 END;
 out(width - idx, str);
END Int;

(*---------------------------------------------------------------------------*)

PROCEDURE Real* ((* EIN/ -- *) r     : REAL;
                 (* EIN/ -- *) width : INTEGER );

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    form : SHORTINT;
    str  : NumberStr;
    lr   : LONGREAL;

BEGIN
 IF Conv.checkReal(r, form) & Conv.split(r, neg, lr, exp, form) THEN
   Conv.floatToStrETH(neg, lr, exp, FALSE, str);
 ELSE
   Conv.formToStr(form, str);
 END;
 out(width - Strings.Length(str), str);
END Real;

(*---------------------------------------------------------------------------*)

PROCEDURE LongReal* ((* EIN/ -- *) r     : LONGREAL;
                     (* EIN/ -- *) width : INTEGER );

VAR neg  : BOOLEAN;
    exp  : INTEGER;
    form : SHORTINT;
    str  : NumberStr;

BEGIN
 IF Conv.split(r, neg, r, exp, form) THEN
   Conv.floatToStrETH(neg, r, exp, TRUE, str);
 ELSE
   Conv.formToStr(form, str);
 END;
 out(width - Strings.Length(str), str);
END LongReal;

END Out.
