MODULE MOD0; (* test ShutDown *)
IMPORT Program;IMPORT MOD1,MOD2;
FROM Terminal IMPORT Write,Read;
FROM Program IMPORT AddShutDowner;

VAR ch : CHAR;

PROCEDURE PROC9;
BEGIN Write('9') END PROC9;

PROCEDURE ReadPuin(VAR c : CHAR);
BEGIN
  Read(c);IF c='0' THEN HALT END;
END ReadPuin;

PROCEDURE PROC0;
BEGIN Write('0') END PROC0;

BEGIN (* main program actions *)
  PROC0;
  AddShutDowner(PROC9);  
  ReadPuin(ch);
  Program.NormalExit;
END MOD0.
