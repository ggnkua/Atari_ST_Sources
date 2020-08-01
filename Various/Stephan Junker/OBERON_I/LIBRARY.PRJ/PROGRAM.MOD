MODULE Program; (* SJ 4.12.94 *)

(*
 Module Program implements procedures concerning program space. These
 procedures work in stand alone programs as well as under LTL.
 *)


IMPORT
  S:=SYSTEM, Sys;



PROCEDURE AddressInCode*(adr: S.PTR) : BOOLEAN;
(*
 Answer true if adr is in the code area of the program.
 *)
 BEGIN
  RETURN (adr >= Sys.Basepage.TextBase) & (adr < Sys.Basepage.DataBase)
 END AddressInCode;


PROCEDURE ProcedureAtAddress*(address: S.PTR; VAR name: ARRAY OF CHAR);
(*
 Answer the procedure at address. address is any address in the code area
 of the program. The procedure is answered as <module>.<procedure>.
 The program version returns en empty string.
 *)
 BEGIN
  name := "";
 END ProcedureAtAddress;


PROCEDURE AddressInData*(adr: S.PTR) : BOOLEAN;
(*
 Answer true if adr is in the data area of the program.
 *)
 BEGIN
  RETURN (adr >= Sys.Basepage.DataBase) & (adr < Sys.Basepage.BssBase)
 END AddressInData;


PROCEDURE AddressInBss*(adr: S.PTR) : BOOLEAN;
(*
 Answer true if adr is in the bss area of the program.
 *)
 BEGIN
  RETURN (adr >= Sys.Basepage.BssBase)
      & (adr < Sys.Basepage.BssBase + Sys.Basepage.BssLen)
 END AddressInBss;


END Program.