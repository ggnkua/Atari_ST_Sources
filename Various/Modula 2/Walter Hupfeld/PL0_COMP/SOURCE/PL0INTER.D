DEFINITION MODULE PL0Interpreter;

CONST
  maxfct = 15;
  maxlev = 15;
  maxadr = 1023;
  
TYPE 
  Instruction = RECORD
                  f : [0..maxfct]; (* function *)
                  l : [0..maxlev]; (* level *)
                  a : [0..maxadr]; (* address *)
                END;
                
  VAR code : ARRAY [0..maxadr] OF Instruction;

  PROCEDURE Interpret;
  PROCEDURE EndInterpreter;
END PL0Interpreter.

