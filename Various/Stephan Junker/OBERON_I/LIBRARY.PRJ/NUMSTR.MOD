MODULE NumStr;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |10.1.93  |correction for Oberon
S. Junker  |29.4.93  |unsigned output
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Str:=Strings;

VAR OK* : BOOLEAN; (* TRUE = no error *)
    ErrorPos* : INTEGER; (* index of error position in string *)

PROCEDURE Chr(Num : INTEGER) : CHAR;
 BEGIN
  IF Num > 9 THEN RETURN CHR(Num + 37H) ELSE RETURN CHR(Num + 30H) END(*IF*);
 END Chr;

PROCEDURE IntTo* (Number,Base : INTEGER; VAR String : ARRAY OF CHAR);
 (* convert an integer number to string *)
  VAR i : INTEGER;
      Neg : BOOLEAN;
      s : ARRAY 22 OF CHAR;
 BEGIN
  Neg := Number < 0;
  IF Neg THEN Number := -Number END(*IF*);
  i := 9;
  IF Number = 0 THEN String[0] := "0"; String[1] := 0X
  ELSE
    WHILE (i >= 0) AND (Number # 0) DO
      s[i] := Chr(Number MOD Base);
      DEC(i); Number := Number DIV Base;
    END(*WHILE*);
    IF Neg AND (i >= 0) THEN s[i] := "-" ELSE INC(i) END(*IF*);
    Str.Excerpt(i,10,s,String);
  END(*IF*);
  OK := i >= 0;
 END IntTo;

PROCEDURE LIntTo* (Number : LONGINT; Base : INTEGER;
                   VAR String : ARRAY OF CHAR);
 (* convert a long integer number to string *)
  VAR i : INTEGER;
      Neg : BOOLEAN;
      s : ARRAY 34 OF CHAR;
 BEGIN
  Neg := Number < 0;
  IF Neg THEN Number := -Number END(*IF*);
  i := 32;
  IF Number = 0 THEN String[0] := "0"; String[1] := 0X
  ELSE
    WHILE (i >= 0) AND (Number # 0) DO
      s[i] := Chr( SHORT(Number MOD Base) );
      DEC(i); Number := Number DIV Base;
    END(*WHILE*);
    IF Neg AND (i >= 0) THEN s[i] := "-" ELSE INC(i) END(*IF*);
    Str.Excerpt(i,33,s,String);
  END(*IF*);
  OK := i >= 0;
 END LIntTo;

PROCEDURE Ord(Char,ec : CHAR; Base : INTEGER) : INTEGER;
  VAR Erg : INTEGER;
 BEGIN
  Char := CAP(Char);
  Erg := ORD(Char) - 30H;
  IF Char > "9" THEN DEC(Erg,7) END(*IF*);
  OK := ((Char >= "0") AND (Char <= "9") AND (Char <= ec))
        OR ((Char >= "A") AND (Char <= ec));
  RETURN Erg
 END Ord;

PROCEDURE LastChar(Base : INTEGER) : CHAR;
 BEGIN
  IF Base > 10 THEN RETURN CHR(Base + 36H) ELSE RETURN CHR(Base + 2FH) END(*IF*);
 END LastChar;

PROCEDURE ToInt* (Base : INTEGER; VAR String : ARRAY OF CHAR) : INTEGER;
 (* convert a string to an integer number *)
  VAR Erg,i,ze : INTEGER;
      ec  : CHAR;
      Neg : BOOLEAN;
 BEGIN
  ec := LastChar(Base); Neg := FALSE;
  i := 0; Erg := 0;
  WHILE (String[i] # 0X) AND (i < LEN(String)) DO
    IF String[i] = "-" THEN Neg := NOT Neg
    ELSIF (String[i] # "+") AND (String[i] # " ") THEN
      ze := Ord(String[i],ec,Base);
      IF NOT OK THEN ErrorPos := i; RETURN Erg END(*IF*);
      Erg := Erg * Base + ze
    END(*IF*);
    INC(i);
  END(*WHILE*);
  IF Neg THEN RETURN -Erg END(*IF*);
  RETURN Erg
 END ToInt;

PROCEDURE ToLInt* (Base : INTEGER; VAR String : ARRAY OF CHAR) : LONGINT;
 (* convert a string to a long integer number *)
  VAR Erg,ze : LONGINT;
    i   : INTEGER;
    ec  : CHAR;
    Neg : BOOLEAN;
 BEGIN
  ec := LastChar(Base); Neg := FALSE;
  i := 0; Erg := 0;
  WHILE (String[i] # 0X) AND (i < LEN(String)) DO
    IF String[i] = "-" THEN Neg := NOT Neg
    ELSIF (String[i] # "+") AND (String[i] # " ") THEN
      ze := Ord(String[i],ec,Base);
      IF NOT OK THEN ErrorPos := i; RETURN Erg END(*IF*);
      Erg := Erg * Base + ze
    END(*IF*);
    INC(i);
  END(*WHILE*);
  IF Neg THEN RETURN -Erg END(*IF*);
  RETURN Erg
 END ToLInt;

PROCEDURE Factor(Exp : INTEGER) : REAL;
  VAR f : REAL;
 BEGIN
  f := 1.0;
  WHILE Exp > 0 DO f := f * 10.0; DEC(Exp) END(*WHILE*);
  WHILE Exp < 0 DO f := f / 10.0; INC(Exp) END(*WHILE*);
  RETURN f
 END Factor;

PROCEDURE LFactor(Exp : INTEGER) : LONGREAL;
  VAR f : LONGREAL;
 BEGIN
  f := 1.0;
  WHILE Exp > 0 DO f := f * 10.0; DEC(Exp) END(*WHILE*);
  WHILE Exp < 0 DO f := f / 10.0; INC(Exp) END(*WHILE*);
  RETURN f
 END LFactor;

PROCEDURE RealTo* (Number : REAL; n : INTEGER; VAR String : ARRAY OF CHAR);
 (* convert real number to string with n digits *)
  VAR Mantisse : REAL;
      Exponent : INTEGER;
      str : ARRAY 10 OF CHAR;
      IntMant  : LONGINT;
 BEGIN
  Exponent := 0; Mantisse := ABS(Number);
  WHILE Mantisse >= 10.0 DO
    INC(Exponent); Mantisse := Mantisse / 10.0;
  END(*IF*);
  IF Mantisse # 0.0 THEN
    WHILE Mantisse < 1.0 DO
      DEC(Exponent); Mantisse := Mantisse * 10.0
    END;
  END(*IF*);
  Mantisse := Mantisse + 0.5 * Factor(-n);
  IF Mantisse >= 10.0 THEN
    INC(Exponent); Mantisse := Mantisse / 10.0;
  END;
  IF Number < 0.0 THEN Mantisse := -Mantisse; END;
  IntMant := S.TRUNC(Mantisse);
  LIntTo(IntMant,10,String);
  Str.AppendC(".",String);
  Mantisse := ABS(Mantisse - IntMant);
  WHILE n > 4 DO
    Mantisse := Mantisse * 10000.0; IntMant := S.TRUNC(Mantisse);
    LIntTo(IntMant,10,str); Str.Adjust(Str.right,4,"0",str);
    Mantisse := Mantisse - IntMant; Str.Append(str,String); DEC(n,4);
  END(*WHILE*);
  LIntTo(S.TRUNC(Mantisse * Factor(n)),10,str);
  Str.Adjust(Str.right,n,"0",str);
  Str.Append(str,String); Str.AppendC("E",String);
  IntTo(Exponent,10,str); Str.Append(str,String);
 END RealTo;

PROCEDURE LRealTo* (Number : LONGREAL; n : INTEGER; VAR String : ARRAY OF
CHAR);
 (* convert long real number to string with n digits *)
  VAR Mantisse : LONGREAL;
      Exponent : INTEGER;
      IntMant  : LONGINT;
      str : ARRAY 10 OF CHAR;
 BEGIN
  Exponent := 0; Mantisse := ABS(Number);
  WHILE Mantisse >= 10.0D0 DO
    INC(Exponent); Mantisse := Mantisse / 10.0D0;
  END(*IF*);
  IF Mantisse # 0.0D0 THEN
    WHILE Mantisse < 1.0D0 DO
      DEC(Exponent); Mantisse := Mantisse * 10.0D0
    END(*WHILE*);
  END(*IF*);
  Mantisse := Mantisse + 0.5D0 * LFactor(-n);
  IF Mantisse >= 10.0D0 THEN
    INC(Exponent); Mantisse := Mantisse / 10.0D0;
  END;
  IF Number < 0.0D0 THEN Mantisse := -Mantisse; END;
  IntMant := S.TRUNC(Mantisse); LIntTo(IntMant,10,String);
  Str.AppendC(".",String); Mantisse := ABS(Mantisse - IntMant);
  WHILE n > 4 DO
    Mantisse := Mantisse * 10000.0D0;
    IntMant := S.TRUNC(Mantisse); LIntTo(IntMant,10,str);
    Str.Adjust(Str.right,4,"0",str); Str.Append(str,String);
    Mantisse := Mantisse - IntMant; DEC(n,4);
  END(*WHILE*);
  LIntTo(S.TRUNC(Mantisse * LFactor(n)),10,str);
  Str.Adjust(Str.right,n,"0",str);
  Str.Append(str,String); Str.AppendC("E",String);
  IntTo(Exponent,10,str); Str.Append(str,String);
 END LRealTo;

PROCEDURE GetReal(VAR String : ARRAY OF CHAR; VAR i,n : INTEGER) : REAL;
  VAR j : INTEGER;
      str : ARRAY 12 OF CHAR;
      Erg : REAL;
 BEGIN
  n := 0; Erg := 0.0;
  REPEAT
    j := 0;
    WHILE (String[i] # ".") AND (String[i] # 0X) AND
          (CAP(String[i]) # "E") AND (j < 9) DO
      str[j] := String[i];
      INC(i); INC(j); INC(n);
    END(*WHILE*);
    str[j] := 0X;
    Erg := Erg * Factor(j) + ToLInt(10,str);
    IF NOT OK THEN RETURN Erg END(*IF*);
  UNTIL j # 9;
  RETURN Erg
 END GetReal;

PROCEDURE GetLReal(VAR String : ARRAY OF CHAR; VAR i,n : INTEGER) : LONGREAL;
  VAR j : INTEGER;
      str : ARRAY 12 OF CHAR;
      Erg : LONGREAL;
 BEGIN
  n := 0; Erg := 0.0D0;
  REPEAT
    j := 0;
    WHILE (String[i] # ".") AND (String[i] # 0X) AND
          (CAP(String[i]) # "E") AND (j < 9) DO
      str[j] := String[i];
      INC(i); INC(j); INC(n);
    END(*WHILE*);
    str[j] := 0X;
    Erg := Erg * LFactor(j) + ToLInt(10,str);
    IF NOT OK THEN RETURN Erg END(*IF*);
  UNTIL j # 9;
  RETURN Erg
 END GetLReal;

PROCEDURE ToReal* (VAR String : ARRAY OF CHAR) : REAL;
 (* convert string to real number *)
  VAR i,n : INTEGER;
      Erg : REAL;
      Ptr : Str.ptr;
      Neg : BOOLEAN;
 BEGIN
  Neg := String[0] = "-";
  IF Neg THEN i := 1 ELSE i := 0 END;
  Erg := GetReal(String,i,n);
  IF NOT OK THEN RETURN Erg END(*IF*);
  IF String[i] = "." THEN
    INC(i); Erg := Erg + GetReal(String,i,n) / Factor(n);
    IF NOT OK THEN RETURN Erg END(*IF*);
  END(*IF*);
  IF CAP(String[i]) = "E" THEN
    Ptr := S.ADR(String[i+1]); Erg := Erg * Factor(ToInt(10,Ptr^));
  END(*IF*);
  IF Neg THEN RETURN -Erg ELSE RETURN Erg END;
 END ToReal;

PROCEDURE ToLReal* (VAR String : ARRAY OF CHAR) : LONGREAL;
 (* convert string to long real number *)
  VAR i,n : INTEGER;
      Erg : LONGREAL;
      Ptr : Str.ptr;
      Neg : BOOLEAN;
 BEGIN
  Neg := String[0] = "-";
  IF Neg THEN i := 1 ELSE i := 0 END;
  Erg := GetLReal(String,i,n);
  IF NOT OK THEN RETURN Erg END(*IF*);
  IF String[i] = "." THEN
    INC(i); Erg := Erg + GetLReal(String,i,n) / LFactor(n);
    IF NOT OK THEN RETURN Erg END(*IF*);
  END(*IF*);
  IF CAP(String[i]) = "E" THEN
    Ptr := S.ADR(String[i+1]); Erg := Erg * LFactor(ToInt(10,Ptr^));
  END(*IF*);
  IF Neg THEN RETURN -Erg ELSE RETURN Erg END;
 END ToLReal;

PROCEDURE CardTo*(Number,Base : INTEGER; VAR String : ARRAY OF CHAR);
 (* convert an integer number unsigned to string *)
 BEGIN
  LIntTo(S.LONG(Number),Base,String);
 END CardTo;

PROCEDURE LCardTo*(Number : LONGINT; Base : INTEGER;
                   VAR String : ARRAY OF CHAR);
 (* convert a long integer number unsigned to string *)
  VAR i,j : INTEGER; Neg : BOOLEAN;
      s : ARRAY 16 OF CHAR;
 BEGIN
  IF (Number >= 0) OR (Base # 16) THEN LIntTo(Number,Base,String)
  ELSE i := 7;
    WHILE i >= 0 DO
      String[i] := Chr( SHORT(S.ANL(Number,0FH)));
      DEC(i); Number := Number DIV 16;
    END(*WHILE*);
    String[8] := 0X;
    OK := TRUE
  END(*IF*);
 END LCardTo;

END NumStr.
