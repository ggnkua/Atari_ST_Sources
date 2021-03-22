MODULE ProcTypesTest;

  PROCEDURE Nop;
  BEGIN
  END Nop;

VAR
  a: PROCEDURE;
  b: PROCEDURE;
BEGIN
  a:=Nop;  (* OK *)
  b:=Nop;  (* OK *)
  a:=b;    (* Error *) (* 1 *)
  b:=a;    (* Error *) (* 2 *)
END ProcTypesTest.
