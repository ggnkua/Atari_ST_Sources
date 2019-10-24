IMPLEMENTATION MODULE  MOD2;
IMPORT Program;IMPORT Terminal;

PROCEDURE PROC2;
BEGIN Terminal.Write('2') END PROC2;

PROCEDURE PROC7;
BEGIN Terminal.Write('7') END PROC7;

BEGIN (* actions of module MOD2 *)
  PROC2;
  Program.AddShutDowner(PROC7);
END MOD2.
