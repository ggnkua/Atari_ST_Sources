MODULE Tools; (* Stephan Junker  18.11.93 *)


(*
 * Tools implements some of the procedures defined by N. Wirth.
 *)


IMPORT
  S:=SYSTEM, O2Modules, CL:=CommandLine, IO, FN:=Filename, Storage,
  Str:=Strings, GEMDOS, NumStr, XBIOS, Form, ObjFile, Sys;


CONST
  bss = 0; text = 1; data = 2; extern = 3; reglist = 4;
  global = 5; equate = 6; defined = 7;

  maxBreaks = 9;


TYPE
   symptr   = POINTER TO symbol;
   symstr   = ARRAY 8 OF CHAR;
   symbol   = RECORD
                Name    : symstr;
                SymType : SHORTINT;
                Magic   : SHORTINT;
                Value   : LONGINT;
                Extend  : ARRAY 14 OF CHAR;
              END(*RECORD*);


VAR
  Byte : SHORTINT;
  address : S.PTR;
  breaks : ARRAY 10 OF RECORD address : LONGINT; code : INTEGER END;


PROCEDURE Free*;
(*
 free modules defined in the parameter list. Unlike the definition
 of Wirth imported modules are not deleted
 *)
 BEGIN
  IF CL.arg = NIL THEN
    IO.WriteString("Usage: Tools.Free {<module name>}"); IO.WriteLn;
  ELSE
    REPEAT
      O2Modules.Remove( CL.arg^);
      CL.Next
    UNTIL CL.arg = NIL;
  END;
 END Free;


PROCEDURE Replace*;
(*
 Replace modules defined in the parameter list.
 *)
  VAR
    mod: O2Modules.Module;
 BEGIN
  IF CL.arg = NIL THEN
    IO.WriteString("Usage: Tools.Replace {<module name>}"); IO.WriteLn;
  ELSE
    REPEAT
      mod := O2Modules.Replace( CL.arg^);
      CL.Next
    UNTIL CL.arg = NIL;
  END;
 END Replace;


PROCEDURE ShowModules*;
  (* shows a list of all modules stored *)
  VAR
    s : ARRAY 10 OF CHAR;
    tlen, dlen, blen : LONGINT;

  PROCEDURE WriteTab(VAR str : ARRAY OF CHAR; tab : INTEGER);
    VAR i : INTEGER;
   BEGIN
    IO.WriteString(str);
    FOR i := tab - Str.Length(str) TO 1 BY -1 DO
      IO.WriteChar(" ");
    END;
   END WriteTab;

  PROCEDURE~ WriteMod(mod: O2Modules.Module);
   BEGIN
    WriteTab( mod.name, 10);
    IO.WriteFInt( mod.obj.TextAdr(), 16, IO.right, 6, "0"); IO.WriteString("  ");
    IO.WriteFInt( mod.obj.TextSize(), 16, IO.right, 4, "0"); IO.WriteString("  ");
    IO.WriteFInt( mod.obj.DataAdr(), 16, IO.right, 6, "0"); IO.WriteString("  ");
    IO.WriteFInt( mod.obj.DataSize(), 16, IO.right, 4, "0"); IO.WriteString("  ");
    IO.WriteFInt( mod.bss, 16, IO.right, 6, "0"); IO.WriteString("  ");
    IO.WriteFInt( mod.obj.BssSize(), 16, IO.right, 4, "0"); IO.WriteString("  ");
    IO.WriteLn;
    INC(tlen, mod.obj.TextSize());
    INC(dlen, mod.obj.DataSize());
    INC(blen, mod.obj.BssSize());
   END WriteMod;

 BEGIN
  IO.WriteString("Name      Text    TLen  Data    DLen  Bss     BLen");
  IO.WriteLn;
  IO.WriteString("----------------------------------------------------");
  IO.WriteLn;
  tlen := 0; dlen := 0; blen := 0;
  O2Modules.Do(WriteMod);
  IO.WriteString("----------------------------------------------------");
  IO.WriteLn;
  IO.WriteFInt(tlen + dlen + blen, 10, IO.left, 18, " ");
  IO.WriteFInt(tlen, 10, IO.left, 14, " ");
  IO.WriteFInt(dlen, 10, IO.left, 14, " ");
  IO.WriteInt(blen);
  IO.WriteLn;
 END ShowModules;


PROCEDURE ShowSyms(VAR name: ARRAY OF CHAR; type: SET);
  VAR
    mod : O2Modules.Module;

  PROCEDURE~ WriteSym(VAR sym: ObjFile.Symbol);
   BEGIN
    IF sym.type * type = type THEN
      IO.WriteFInt( sym.value, 16, IO.right, 8, "0");
      IO.WriteString( "  "); IO.WriteString( sym.name); IO.WriteLn;
    END;
  END WriteSym;

 BEGIN
  mod := O2Modules.Load(name);
  IF mod = NIL THEN
    IO.WriteString( "Module "); IO.WriteString( name);
    IO.WriteString( " not found."); IO.WriteLn;
  ELSE
    mod.obj.SymbolsDo( WriteSym);
  END;
 END ShowSyms;


PROCEDURE ShowCommands*;
 BEGIN
  IF CL.arg = NIL THEN
    IO.WriteString("Usage: Tools.ShowCommands <module name>"); IO.WriteLn;
  ELSE
    ShowSyms(CL.arg^, {ObjFile.Text, ObjFile.Global});
  END;
 END ShowCommands;


PROCEDURE ShowProcedures*;
 BEGIN
  IF CL.arg = NIL THEN
    IO.WriteString("Usage: Tools.ShowProcedures <module name>"); IO.WriteLn;
  ELSE
    ShowSyms(CL.arg^, {ObjFile.Text});
  END;
 END ShowProcedures;


PROCEDURE ShowVariables*;
 BEGIN
  IF CL.arg = NIL THEN
    IO.WriteString("Usage: Tools.ShowVariables <module name>"); IO.WriteLn;
  ELSE
    ShowSyms(CL.arg^, {ObjFile.Bss});
  END;
 END ShowVariables;

(*$-k *)

PROCEDURE GetByte;
 BEGIN
  S.GET(address, Byte);
 END GetByte;

(*$+k *)

PROCEDURE DoDump(DumpAd : S.PTR; Bytes : LONGINT);
  VAR i : INTEGER;
      ascii : ARRAY 18 OF CHAR;
 BEGIN
  REPEAT
    IO.WriteFInt(DumpAd,16,IO.right,8,"0");
    IO.WriteString("  "); i := 0;
    REPEAT
      address := DumpAd;
      XBIOS.Supexec(GetByte);
      IO.WriteFInt(S.LONG(Byte), 16, IO.right, 2, "0");
      IF (Byte >= 0) AND (Byte < 20H) THEN ascii[i] := 0FAX
      ELSE ascii[i] := CHR(Byte)
      END;
      IO.WriteChar(" "); INC(i); INC(DumpAd);
      IF i = 8 THEN IO.WriteChar(" ") END;
      DEC(Bytes);
    UNTIL (i = 16) OR (Bytes = 0);
    ascii[i] := 0X;
    IF i < 8 THEN IO.WriteChar(" ") END;
    WHILE i < 16 DO IO.WriteString("   "); INC(i) END;
    IO.WriteChar("|");
    IO.WriteString(ascii);
    IO.WriteChar("|");
    IO.WriteLn;
  UNTIL Bytes = 0;
 END DoDump;


PROCEDURE GetAddress*(VAR str : ARRAY OF CHAR; VAR adr : S.PTR) : BOOLEAN;
(*
 if str contains a hex address, it is returned. If it contains a
 module name and maybe an ident name, the address of it is returned.
 *)
  VAR
    mod : O2Modules.Module;
    name,s : ARRAY 30 OF CHAR;
    i,j : INTEGER;
    Sym : symptr;

  PROCEDURE~ Search(VAR sym: ObjFile.Symbol);
   BEGIN
    IF sym.name = name THEN
      IF ObjFile.Text IN sym.type THEN
        adr := mod.obj.TextAdr() + sym.value;
      ELSIF ObjFile.Data IN sym.type THEN
        adr := mod.obj.DataAdr() + sym.value;
      ELSE
        adr := mod.bss + sym.value;
      END;
      RETURN^ TRUE
    END;
   END Search;

 BEGIN
  IF (str[0] >= "0") AND (str[0] <= "9") THEN
    adr := NumStr.ToLInt(16, str);
    RETURN NumStr.OK;
  ELSE
    i := 0;
    WHILE (str[i] # 0X) AND (str[i] # ".") DO
      name[i] := str[i]; INC(i);
    END;
    name[i] := 0X;
    mod := O2Modules.Load(name);
    IF mod # NIL THEN
      IF str[i] = 0X THEN
        adr := mod.obj.TextAdr();
        RETURN TRUE
      ELSE
        j := 0; INC(i);
        WHILE str[i] # 0X DO
          name[j] := str[i]; INC(i); INC(j);
        END;
        name[j] := 0X;
        mod.obj.SymbolsDo( Search);
        IO.WriteString("Didn't find identifier ");
      END;
    ELSE
      IO.WriteString("Didn't find module ");
    END;
  END;
  IO.WriteString( name); IO.WriteLn;
  RETURN FALSE
 END GetAddress;


PROCEDURE Dump*;
  VAR
    DumpAd: S.PTR;
    Bytes : LONGINT;
 BEGIN
  IF (CL.arg # NIL) AND GetAddress(CL.arg^, DumpAd) THEN
    CL.Next;
    IF CL.arg # NIL THEN
      Bytes := NumStr.ToLInt(16, CL.arg^);
    ELSE
      Bytes := 0; NumStr.OK := TRUE;
    END;
    IF NumStr.OK THEN
      DoDump( DumpAd, Bytes);
      RETURN
    END;
  END;
  IO.WriteString("Usage: Tools.Dump <address> [<bytes>]"); IO.WriteLn;
  IO.WriteString("       where <address> may be a hex number or an ident"); IO.WriteLn;
  IO.WriteString("       and <bytes> is a hex number."); IO.WriteLn;
 END Dump;

(*$-k *)

PROCEDURE SetByte;
 BEGIN
  S.PUT(address, Byte);
 END SetByte;

(*$+k *)

PROCEDURE Set*;
 BEGIN
  IF (CL.arg # NIL) AND GetAddress(CL.arg^, address) THEN
    REPEAT
      CL.Next;
      IF CL.arg # NIL THEN
        Byte := SHORT(SHORT(NumStr.ToLInt(16, CL.arg^)));
        IF NumStr.OK THEN
          XBIOS.Supexec(SetByte);
          INC(address);
        END;
      END;
    UNTIL (CL.arg = NIL) OR NOT NumStr.OK;
    IF NumStr.OK THEN RETURN END;
  END;
  IO.WriteString("Usage: Tools.Set <address> {<byte>}"); IO.WriteLn;
  IO.WriteString("       where <address> may be a hex number or an ident"); IO.WriteLn;
  IO.WriteString("       and {<byte>} are hex numbers."); IO.WriteLn;
 END Set;


PROCEDURE Debug*;
 BEGIN
  HALT(99);
 END Debug;


PROCEDURE Address*;
  VAR
    addr : S.PTR;
 BEGIN
  IF CL.arg # NIL THEN
    IF GetAddress(CL.arg^, addr) THEN
      IO.WriteFInt(addr, 16, IO.right, 8, "0"); IO.WriteLn;
      RETURN
    END;
  END;
  IO.WriteString("Usage: Tools.Address <module>[.<ident>]"); IO.WriteLn;
  IO.WriteString("       where <module> is a module name and"); IO.WriteLn;
  IO.WriteString("       ident an identifier in that module."); IO.WriteLn;
 END Address;


PROCEDURE ShowCommandLine*;
 BEGIN
  IO.WriteString( "Command line contents: "); IO.WriteLn;
  IO.WriteString( Sys.Basepage.Command); IO.WriteLn;
 END ShowCommandLine;


PROCEDURE ShowMemory*;
  VAR
    free, allocated, administrative, largest: LONGINT;
 BEGIN
  Storage.Statistics(free, allocated, administrative, largest);
  IO.WriteString( "Available memory "); IO.WriteInt( free);
  IO.WriteString( " bytes"); IO.WriteLn;
  IO.WriteString( "Allocated memory "); IO.WriteInt( allocated);
  IO.WriteString( " bytes"); IO.WriteLn;
  IO.WriteString( "Largest block available: "); IO.WriteInt( largest);
  IO.WriteString( " bytes"); IO.WriteLn;
  IO.WriteInt( Storage.keepFree);
  IO.WriteString( " bytes of memory are kept free.");
  IO.WriteLn;
  IO.WriteInt( administrative);
  IO.WriteString( " bytes are needed for administration purposes.");
  IO.WriteLn;
 END ShowMemory;


PROCEDURE KeepFree*;
  VAR
    value: LONGINT;
 BEGIN
  IF (CL.arg # NIL) THEN
    value := NumStr.ToLInt(10, CL.arg^);
    IF NumStr.OK THEN
      Storage.keepFree := value;
    ELSE
      IO.WriteString( "The parameter must be a decimal value");
      IO.WriteLn;
    END;
  ELSE
    IO.WriteInt( Storage.keepFree);
    IO.WriteString( " bytes of the free memory will not be used.");
    IO.WriteLn;
  END;
 END KeepFree;


END Tools.