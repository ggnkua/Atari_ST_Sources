IMPLEMENTATION MODULE D_Pack_1;

(*$R-,S-,Z+*)

FROM D_Global   IMPORT  OneToFifty, Enumeration, RecordPointer;
FROM D_Pack_2   IMPORT  IntGlob, Char1Glob, Proc7, Proc6;

PROCEDURE Proc1 (    PointerParVal: RecordPointer);
    (* executed once *)
BEGIN
   WITH PointerParVal^.PointerComp^ (* = PointerGlobNext *) DO
      PointerParVal^.PointerComp^ := PointerGlob^;
      PointerParVal^.IntComp := 5;
      IntComp := PointerParVal^.IntComp;
      PointerComp := PointerParVal^.PointerComp;
      Proc3 (PointerComp);
       (* PointerParVal^.PointerComp^.PointerComp = PointerGlob^.PointerComp *)
      IF Discr = Ident1 THEN
         (* executed *)
         IntComp := 6;
         Proc6 (PointerParVal^.EnumComp, EnumComp);
         PointerComp := PointerGlob^.PointerComp;
         Proc7 (IntComp, 10, IntComp);
      ELSE
         (* not executed *)
         PointerParVal^ := PointerParVal^.PointerComp^;
      END; (* if *)
   END; (* with *)
END Proc1; (* Proc1 *)


PROCEDURE Proc2 (VAR IntParRef:     OneToFifty);
    (* executed once *)
    (* InParRef = 3, becomes 7 *)
VAR IntLoc:  OneToFifty;
    EnumLoc: Enumeration;
BEGIN
   IntLoc := IntParRef + 10;
   REPEAT (* executed once *)
     IF Char1Glob = 'A' THEN
        (* executed *)
        IntLoc := IntLoc - 1;
        IntParRef := IntLoc - IntGlob;
        EnumLoc := Ident1;
     END (* if *)
   UNTIL EnumLoc = Ident1; (* true *)
END Proc2; (* Proc2 *)


PROCEDURE Proc3 (VAR PointerParRef: RecordPointer);
    (* executed once *)
    (* PointerParRef becomes PointerGlob *)
BEGIN
   IF PointerGlob <> NIL THEN
      (* executed *)
      PointerParRef := PointerGlob^.PointerComp;
   END;
   Proc7 (10, IntGlob, PointerGlob^.IntComp);
END Proc3; (* Proc3 *)


PROCEDURE Proc4; (* without parameters *)
    (* executed once *)
VAR BoolLoc: BOOLEAN;
BEGIN
   BoolLoc   := Char1Glob = 'A';
   BoolGlob  := BoolLoc OR BoolGlob;
   Char2Glob := 'B';
END Proc4; (* Proc4 *)


PROCEDURE Proc5; (* without parameters *)
    (* executed once *)
BEGIN
   Char1Glob := 'A';
   BoolGlob  := FALSE;
END Proc5; (* Proc5 *)

END D_Pack_1.