IMPLEMENTATION MODULE  MOD1;
IMPORT Program, Terminal;
(*--------------------------------*)
MODULE  MOD3;
IMPORT Program,Terminal;
EXPORT QUALIFIED PROC3,PROC8;

PROCEDURE PROC3;
BEGIN Terminal.Write('3') END PROC3;

PROCEDURE PROC8;
BEGIN Terminal.Write('8') END PROC8;

BEGIN (* actions of module MOD3 *)
  PROC3;
  Program.AddShutDowner(PROC8);
END MOD3;
(*--------------------------------*)

PROCEDURE PROC1;
BEGIN Terminal.Write('1') END PROC1;

BEGIN (* actions of module MOD1 *)
  PROC1;
END MOD1.
