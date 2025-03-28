IMPLEMENTATION MODULE  Variables;

(* (C) Robert Tolksdorf fuer ST-Computer, 8/90 *)

(* Hier sind eventuell Anpassungen noetig ! *)
FROM InOut     IMPORT WriteString, WriteInt, WriteCard;
FROM LongInOut IMPORT WriteLongInt, WriteLongCard;
FROM RealInOut IMPORT WriteReal, WriteLongReal;

(* Vom Definitions-Modul:
TYPE VariableTypes = (Boolean, Integer, Cardinal, Longint, Longcard,
                      Real, Longreal);
     Variable      = RECORD CASE Typ:VariableTypes OF
                       Boolean  : b  : BOOLEAN;
                     | Integer  : i  : INTEGER;
                     | Cardinal : c  : CARDINAL;
                     | Longint  : li : LONGINT;
                     | Longcard : lc : LONGCARD;
                     | Real     : r  : REAL;
                     | Longreal : lr : LONGREAL;
                     END END;
*)

PROCEDURE SetBool(VAR v:Variable; val:BOOLEAN);
BEGIN
  v.Typ:=Boolean;
  v.b:=val
END SetBool;

PROCEDURE BoolValue(v:Variable):BOOLEAN;
BEGIN
  IF v.Typ=Boolean THEN
    RETURN v.b
  END
END BoolValue;

PROCEDURE SetInt(VAR v:Variable; val:INTEGER);
BEGIN
  v.Typ:=Integer;
  v.i:=val
END SetInt;

PROCEDURE IntValue(v:Variable):INTEGER;
BEGIN
  IF v.Typ=Integer THEN
    RETURN v.i
  END
END IntValue;

PROCEDURE SetCard(VAR v:Variable; val:CARDINAL);
BEGIN
  v.Typ:=Cardinal;
  v.c:=val
END SetCard;

PROCEDURE CardValue(v:Variable):CARDINAL;
BEGIN
  IF v.Typ=Cardinal THEN
    RETURN v.c
  END
END CardValue;

PROCEDURE SetLongint(VAR v:Variable; val:LONGINT);
BEGIN
  v.Typ:=Longint;
  v.li:=val
END SetLongint;

PROCEDURE LongintValue(v:Variable):LONGINT;
BEGIN
  IF v.Typ=Longint THEN
    RETURN v.li
  END
END LongintValue;

PROCEDURE SetLongcard(VAR v:Variable; val:LONGCARD);
BEGIN
  v.Typ:=Longcard;
  v.lc:=val
END SetLongcard;

PROCEDURE LongcardValue(v:Variable):LONGCARD;
BEGIN
  IF v.Typ=Longcard THEN
    RETURN v.lc
  END
END LongcardValue;

PROCEDURE SetReal(VAR v:Variable; val:REAL);
BEGIN
  v.Typ:=Real;
  v.r:=val;
END SetReal;

PROCEDURE RealValue(v:Variable):REAL;
BEGIN
  IF v.Typ=Real THEN
    RETURN v.r
  END;
END RealValue;

PROCEDURE SetLongreal(VAR v:Variable; val: LONGREAL);
BEGIN
  v.Typ:=Longreal;
  v.lr:=val
END SetLongreal;

PROCEDURE LongrealValue(v:Variable):LONGREAL;
BEGIN
  IF v.Typ=Longreal THEN
    RETURN v.lr
  END
END LongrealValue;

PROCEDURE WriteValue(v:Variable);
BEGIN
  CASE v.Typ OF
    Boolean  : IF v.b THEN WriteString('TRUE')
                      ELSE WriteString('FALSE')
               END
  | Integer  : WriteInt(v.i,6)
  | Cardinal : WriteCard(v.c,5);
  | Longint  : WriteLongInt(v.li,11);
  | Longcard : WriteLongCard(v.lc,10);
(* Die Stellenanzahl der REAL/LONGREAL-Ausgaben anpassen ! *)
  | Real     : WriteReal(v.r,15);
  | Longreal : WriteLongReal(v.lr,15);
  ELSE
    HALT
  END
END WriteValue;

END Variables.

