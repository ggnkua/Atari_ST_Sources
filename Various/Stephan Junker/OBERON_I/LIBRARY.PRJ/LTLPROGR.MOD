MODULE LTLProgram; (* SJ 4.12.94 *)

(*
 Module Program implements procedures concerning program space. These
 procedures work in stand alone programs as well as under LTL.
 This is the LTL version which redirects the procedures of the stand alone
 version. You will never import LTLProgram, but Program.
 *)


IMPORT
  S:=SYSTEM, O2Modules, Strings, ObjFile, Program, Redirect;



PROCEDURE AddressInCode*(adr: S.PTR) : BOOLEAN;
(*
 Answer true if adr is in the code area of the program.
 *)
  VAR
    address: S.PTR;
    found  : BOOLEAN;

  PROCEDURE~ CheckAddress(mod: O2Modules.Module);
   BEGIN
    IF (address >= mod.obj.TextAdr() ) & (address < mod.obj.DataAdr() ) THEN
      found := TRUE;
    END;
   END CheckAddress;

 BEGIN
  address := adr;
  found := FALSE;
  O2Modules.Do(CheckAddress);
  RETURN found;
 END AddressInCode;


PROCEDURE ProcedureAtAddress*(address: S.PTR; VAR name: ARRAY OF CHAR);
(*
 Answer the procedure at address. address is any address in the code area
 of the program. The procedure is answered as <module>.<procedure>
 *)
  VAR
    procedure: ARRAY 24 OF CHAR;
    procadr  : S.PTR;
    module   : O2Modules.Module;

  PROCEDURE~ SearchModuleAtAddress( mod: O2Modules.Module);
   BEGIN
    IF (address >= mod.obj.TextAdr()) & (address < mod.obj.DataAdr()) THEN
      module := mod;
    END;
   END SearchModuleAtAddress;

  PROCEDURE~ SearchProcedureAtAddress(VAR sym: ObjFile.Symbol);
    VAR
      adr: S.PTR;
   BEGIN
    IF ObjFile.Text IN sym.type THEN
      adr := sym.value + module.obj.TextAdr();
      IF (adr < address) & (adr > procadr) THEN
        procadr := adr;
        COPY(sym.name, procedure);
      END;
    END;
   END SearchProcedureAtAddress;

 BEGIN
  module := NIL;
  O2Modules.Do( SearchModuleAtAddress);
  IF module # NIL THEN
    procedure := ""; procadr := 0;
    module.obj.SymbolsDo( SearchProcedureAtAddress);
    COPY( module.name, name);
    Strings.AppendC(".", name);
    Strings.Append( procedure, name);
  ELSE
    name := "Address not in code";
  END;
 END ProcedureAtAddress;


PROCEDURE AddressInData*(adr: S.PTR) : BOOLEAN;
(*
 Answer true if adr is in the data area of the program.
 *)
(* This is the simplest and slowest solution.
  VAR
    address: S.PTR;
    found  : BOOLEAN;

  PROCEDURE~ CheckAddress(mod: O2Modules.Module);
   BEGIN
    IF (address >= mod.obj.DataAdr() )
        & (address < mod.obj.DataAdr()+mod.obj.DataSize() ) THEN
      found := TRUE;
    END;
   END CheckAddress;

 BEGIN
  address := adr;
  found := FALSE;
  O2Modules.Do(CheckAddress);
  RETURN found;
*)

(* The GC needs a faster solution *)
 BEGIN
  (*$-p *)
  ASSEMBLER

    MOVE.L  O2Modules.modList,A0    ; A0 = ^current module
    MOVE.L  adr,D0

  modLoop:
    MOVE.L  A0,D1
    BEQ.B   notFound

    MOVE.L  14(A0),A1   ; ^obj
    MOVE.L  (A1),A2     ; ^header
    LEA     28(A2),A3   ; ^text
    ADDA.L  2(A2),A3    ; ^data
    CMP.L   A3,D0
    BLO.B   nextMod

    ADDA.L  6(A2),A3    ; ^end data
    CMP.L   A3,D0
    BHS.B   nextMod

    MOVEQ   #1,D0
    RETURN

  nextMod:
    MOVE.L  (A0),A0     ; next module
    BRA.B   modLoop

  notFound:
    MOVEQ   #0,D0
    RETURN

  END;
  (*$+p *)
 END AddressInData;


PROCEDURE AddressInBss*(address: S.PTR) : BOOLEAN;
(*
 Answer true if adr is in the bss area of the program.
 *)

  PROCEDURE~ CheckAddress(mod: O2Modules.Module);
   BEGIN
    IF (address >= mod.bss ) & (address < mod.bss + mod.obj.BssSize() ) THEN
      RETURN^ TRUE
    END;
   END CheckAddress;

 BEGIN
  O2Modules.Do(CheckAddress);
  RETURN FALSE;
 END AddressInBss;


BEGIN
  Redirect( S.ADR( Program.AddressInCode), S.ADR( AddressInCode) );
  Redirect( S.ADR( Program.AddressInData), S.ADR( AddressInData) );
  Redirect( S.ADR( Program.AddressInBss), S.ADR( AddressInBss) );
  Redirect( S.ADR( Program.ProcedureAtAddress), S.ADR( ProcedureAtAddress) );
END LTLProgram.