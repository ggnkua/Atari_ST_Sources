IMPLEMENTATION MODULE D_Pack_2;

(*$R-,S-,Z+*)

FROM D_Global IMPORT RecordPointer, OneToFifty, Array1DimInteger,
                     CapitalLetter, String30, Array2DimInteger, OneToThirty,
                     Enumeration;
FROM Strings  IMPORT Relation, Compare;

PROCEDURE Proc6 (    EnumParVal:     Enumeration;
                     VAR EnumParRef:     Enumeration);
    (* executed once *)
    (* EnumParVal = Ident3, EnumParRef becomes Ident2 *)
BEGIN
   EnumParRef := EnumParVal;
   IF NOT Func3 (EnumParVal) THEN
      (* not executed *)
      EnumParRef := Ident4;
      END;
   CASE EnumParVal OF
      Ident1: EnumParRef := Ident1    |
      Ident2: IF IntGlob > 100 THEN
                 EnumParRef := Ident1
              ELSE
                 EnumParRef := Ident4;
              END                      |
      Ident3: EnumParRef := Ident2     |    (* executed *)
      Ident4: ;                        |
      Ident5: EnumParRef := Ident3
   END; (* case *)
END Proc6; (* Proc6 *)


PROCEDURE Proc7  (    Int1ParVal,
                      Int2ParVal:    OneToFifty;
                  VAR IntParRef:     OneToFifty);
    (* executed three times                               *)
    (* first call:      Int1ParVal = 2, Int2ParVal = 3,   *)
    (*                  IntParRef becomes 7               *)
    (* second call:     Int1ParVal = 10, Int2ParVal = 5,  *)
    (*                  IntParRef becomes 17              *)
    (* third call:      Int1ParVal = 6, Int2ParVal = 10,  *)
    (*                  IntParRef becomes 18              *)
VAR
  IntLoc: OneToFifty;
BEGIN
  IntLoc := Int1ParVal + 2;
  IntParRef := Int2ParVal + IntLoc;
END Proc7; (* Proc7 *)


PROCEDURE Proc8 (VAR Array1ParRef: Array1DimInteger;
                 VAR Array2ParRef: Array2DimInteger;
                     Int1ParVal,
                     Int2ParVal:    INTEGER);
    (* executed once  *)
    (* Int1ParVal = 3 *)
    (* Int2ParVal = 7 *)
VAR
  IntIndex,
  IntLoc:   OneToFifty;
BEGIN
  IntLoc := Int1ParVal + 5;
  Array1ParRef [IntLoc] := Int2ParVal;
  Array1ParRef [IntLoc+1] := Array1ParRef [IntLoc];
  Array1ParRef [IntLoc+30] := IntLoc;
  FOR IntIndex := IntLoc TO IntLoc+1 DO
    Array2ParRef [IntLoc, IntIndex] := IntLoc;
  END;
  Array2ParRef [IntLoc, IntLoc-1] := Array2ParRef [IntLoc, IntLoc-1] + 1;
  Array2ParRef [IntLoc+20, IntLoc] := Array1ParRef [IntLoc];
  IntGlob := 5;
END Proc8; (* Proc8 *)


PROCEDURE Func1 (Char1ParVal,
                 Char2ParVal: CapitalLetter): Enumeration;
    (* executed three times, returns always Ident1              *)
    (* first call:      Char1ParVal = 'H', Char2ParVal = 'R'    *)
    (* second call:     Char1ParVal = 'A', Char2ParVal = 'C'    *)
    (* third call:      Char1ParVal = 'B', Char2ParVal = 'C'    *)
VAR
  Char1Loc, Char2Loc: CapitalLetter;
BEGIN
  Char1Loc := Char1ParVal;
  Char2Loc := Char1Loc;
  IF Char2Loc <> Char2ParVal THEN
     (* executed *)
    RETURN (Ident1)
  ELSE  (* not executed *)
    Char1Glob := Char1Loc;
    RETURN(Ident2);
  END;
END Func1; (* Func1 *)


PROCEDURE Func2 (VAR String1ParRef,
                     String2ParRef: String30): BOOLEAN;
    (* executed once, returns false              *)
    (* String1ParRef = 'DHRYSTONE PROGRAM, 1''ST STRING' *)
    (* String2ParRef = 'DHRYSTONE PROGRAM, 2''ND STRING' *)
VAR
  IntLoc:  OneToThirty;
  CharLoc: CapitalLetter;
BEGIN
  IntLoc := 2;
  WHILE IntLoc <= 2 DO (* loop body executed once *)
    IF Func1 (String1ParRef[IntLoc], String2ParRef[IntLoc+1]) = Ident1 THEN
       (* executed *)
      CharLoc := 'A';
      IntLoc := IntLoc + 1;
    END; (* if, while *)
  END;
  IF (CharLoc >= 'W') AND (CharLoc < 'Z') THEN
     (* not executed *)
     IntLoc := 7;
  END;
  IF CharLoc = 'R' THEN
     (* not executed *)
     RETURN (TRUE)
  ELSIF Compare (String1ParRef, String2ParRef) > less THEN
     (* not executed *)
     IntLoc := IntLoc + 7;
     IntGlob := IntLoc;
     RETURN(TRUE);
  ELSE (* executed *)
     RETURN(FALSE);
  END; (* if CharLoc *)
END Func2; (* Func2 *)


PROCEDURE Func3 (EnumParVal: Enumeration): BOOLEAN;
    (* executed once, returns true      *)
    (* EnumParVal = Ident3              *)
VAR
  EnumLoc:  Enumeration;
BEGIN
  EnumLoc := EnumParVal;
  IF EnumLoc = Ident3 THEN
   (* executed *)
    RETURN(TRUE)
  ELSE (* not executed *)
    RETURN(FALSE);
  END
END Func3; (* Func3 *)

END D_Pack_2.

