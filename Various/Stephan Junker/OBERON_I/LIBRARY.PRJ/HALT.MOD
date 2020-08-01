MODULE Halt; (* Stephan Junker  3.12.93 / 25.11.94 / 4.12.94 *)

(*
 Halt links a procedure in Sys.Halt that displays the error in an alert
 box.
 *)


IMPORT
  S:=SYSTEM, Sys, NumStr, Strings, Form, Task;



VAR
  inException* : BOOLEAN;
  excAddress*  : S.PTR;
  excType-     : INTEGER;
  registers-   : ARRAY 16 OF LONGINT;


(*$-k no stack check because a stack error could have caused HALT -> recursion *)


PROCEDURE ShowError*(VAR errmsg: ARRAY OF CHAR; contPossible: BOOLEAN);
(*
 Just exported to be redirected by LTLHalt.
 *)
  VAR
    s, name: ARRAY 160 OF CHAR;
    d: INTEGER;
    address: S.PTR;
 BEGIN
  address := excAddress; (*excAddress := NIL;*)
  s := "[1]["; Strings.Append( errmsg, s);
  Strings.Append("][Abort",s);
  IF contPossible THEN Strings.Append( "|Continue",s) END;
  Strings.AppendC("]", s);
  d := Form.Alert(1,s);
  inException := FALSE;
  IF d = 1 THEN
    Task.Exit(-1);
  END;
 END ShowError;


PROCEDURE Halt(no : INTEGER);
  VAR
    s : ARRAY 80 OF CHAR;
    addr, stack: S.PTR;
 BEGIN
  IF (no = Sys.STACKERR) & inException THEN RETURN END; (* prevent recursion *)
  ASSEMBLER
    MOVEM.L  D0-A7,registers
  END;
  inException := TRUE;
  excType := no;
  CASE no OF
    Sys.TYPERR: s := "Type check failed" |
    Sys.NORET : s := "Return statement missing" |
    Sys.CASERR : s := "Case selection failed" |
    Sys.REALERR : s := "Arithmetic error" |
    Sys.OUTOFMEM : s := "Out of memory" |
    Sys.WITHERR : s := "With selection failed" |
    Sys.MEMERR : s := "Memory destroyed" |
    Sys.STACKERR : s := "Stack overflow";
      S.GETREG(15, stack); INC(stack, 1000); S.PUTREG(15, stack) |
    Sys.PROTOUSED : s := "Prototype used.|Please overwrite" |
    Sys.BUSERR : s := "Bus error" |
    Sys.ADDRERR : s := "Address error" |
    Sys.ILLERR : s := "Illegal opcode" |
    Sys.DIVERR : s := "Division by zero" |
    Sys.INXERR : s := "Check error" |
    Sys.OVFLERR : s := "Overflow error" |
    Sys.PRIVERR : s := "Privilege violated" |
    Sys.TRACERR : s := "Trace exception" |
    Sys.NOMEMADR : s := "DISPOSE address not valid" |
    Sys.BREAK : s := "User interrupt" |
    ELSE
      IF (no >= 100) AND (no < 200) THEN
        NumStr.IntTo(no - 100, 10, s);
        Strings.Insert("User breakpoint #",0,s);
      ELSE
        NumStr.IntTo(no, 10, s);
        Strings.Insert("Error #",0,s);
      END;
  END;
(*  IF excAddress = NIL THEN*)
    S.GET( registers[14], addr);
    S.GET( addr+4, excAddress);
(*  END;*)
  ShowError(s, no >= 20);
  ASSEMBLER
    MOVEM.L  registers,D0-A7
  END;
 END Halt;


BEGIN
  Sys.Halt := Halt;
END Halt.