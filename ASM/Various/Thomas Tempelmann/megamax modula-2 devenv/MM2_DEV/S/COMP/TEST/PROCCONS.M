MODULE ProcCImport;
(*$N+,E MOS*)

(* Alias-Definitionen von Prozeduren *)

IMPORT GEMDOSIO;
(*
FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, CADR;
FROM InOut IMPORT Read;
FROM InOut IMPORT WriteString;
FROM P2 IMPORT WS;
*)
FROM P3 IMPORT Wr;

VAR ch: CHAR;

BEGIN
  (*
  ASSEMBLER BREAK END;
  WriteString ("<WriteString>");
  *)
  Wr (" <Wr> ");
END ProcCImport.
