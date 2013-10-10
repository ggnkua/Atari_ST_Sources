MODULE T;

(*$R-,S-*)

(*
 * Tests fÅr A7- und Reg-ParameterÅbergabe
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS;

(*$[+*)

TYPE Ptyp = PROCEDURE (CARDINAL, CARDINAL);

PROCEDURE proc1 (a,b: CARDINAL);
  VAR e,f: CARDINAL;
  BEGIN
    e:= a;
  END proc1;

VAR c,d: CARDINAL; ch: CHAR; s: ARRAY [0..2] OF CHAR; ca: ARRAY [0..2] OF CARDINAL;
    s5: ARRAY [0..4] OF CHAR; l: LONGCARD; r: LONGREAL; ptr: ADDRESS;
    procvar: Ptyp;

BEGIN
  ASSEMBLER BREAK END;
  procvar:= proc1;
  procvar (1,2);
END T.
