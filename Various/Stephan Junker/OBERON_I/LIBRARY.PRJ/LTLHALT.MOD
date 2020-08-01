MODULE LTLHalt; (* Stephan Junker  3.12.93 / 25.11.94 / 4.12.94 *)

(*
 A version of Halt for LTL. Never import it directly.
 *)


IMPORT
  S:=SYSTEM, Strings, Form, Program, Task, Halt, Redirect;


VAR
  Debug*: PROCEDURE (addr: S.PTR; contPossible: BOOLEAN);


PROCEDURE ShowError(VAR errmsg: ARRAY OF CHAR; contPossible: BOOLEAN);
  VAR
    s, name: ARRAY 160 OF CHAR;
    d: INTEGER;
    address: S.PTR;
 BEGIN
  address := Halt.excAddress; (*Halt.excAddress := NIL;*)
  s := "[1]["; Strings.Append( errmsg, s);
  Strings.Append( " in|", s);
  Program.ProcedureAtAddress(address, name);
  Strings.Append(name, s);
  Strings.Append("][Abort",s);
  IF Debug # NIL THEN
    Strings.Append("|Debug", s);
  END;
  IF contPossible THEN Strings.Append( "|Continue",s) END;
  Strings.AppendC("]", s);
  d := Form.Alert(1,s);
  Halt.inException := FALSE;
  IF d = 1 THEN
    Task.Exit(-1);
  ELSIF (Debug # NIL) & (d = 2) THEN
    Debug(address, contPossible);
  END;
 END ShowError;


BEGIN
  Redirect( S.ADR( Halt.ShowError), S.ADR( ShowError) );
END LTLHalt.