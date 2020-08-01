MODULE Redirect; (* SJ 8.11.94 *)

(*
 Redirect procedure calls.

 Example: You want to replace IO.WriteString with your own WriteString
 procedure, and want to be able to undo this redirection.

 MODULE Example;

 IMPORT
   Redirect;

 VAR
   oldCode: Redirect.Code;

 PROCEDURE WriteString(str: ARRAY OF CHAR);	(* your new procedure *)
  BEGIN
   (* ... *)
  END WriteString;

 PROCEDURE NewWriteString;			(* link new procedure *)
  BEGIN
   Redirect.GetCode( S.ADR( IO.WriteString), oldCode );
   Redirect( S.ADR( IO.WriteString), S.ADR( WriteString) );
  END NewWriteString;

 PROCEDURE OldWriteString;			(* link old procedure *)
  BEGIN
   Redirect.SetCode( S.ADR( IO.WriteString), oldCode );
  END OldWriteString;

 END Example.
 *)


IMPORT
  S:=SYSTEM;


TYPE
  Code* = ARRAY 3 OF INTEGER;


PROCEDURE Redirect*(old, new: S.PTR);
(*
 Enter a jump to new at the address old. This will cause all calls of the
 procedure at address old to execute the procedure at address new. You are
 responsible for malfunctions if the parameter list does not match!
 *)
 BEGIN
  S.PUT( old, 4EF9H);	(* JMP *)
  S.PUT( old+2, new);	(* new *)
 END Redirect;


PROCEDURE GetCode*(adr: S.PTR; VAR code: Code);
(*
 Return the first three words at adr in order to be able to restore them.
 *)
 BEGIN
  S.GET( adr, code);
 END GetCode;


PROCEDURE SetCode*(adr: S.PTR; VAR code: Code);
(*
 Set the first three words at adr to restore the previous procedure.
 *)
 BEGIN
  S.PUT( adr, code);
 END SetCode;


END Redirect.