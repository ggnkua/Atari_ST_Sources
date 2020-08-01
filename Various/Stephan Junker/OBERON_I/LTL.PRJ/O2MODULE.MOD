MODULE O2Modules; (* SJ 15.11.94 *)

(*
 O2Modules provides the procedures needed to load and execute object files
 produced by the STJ-Oberon-2 compiler V2.XX.
 *)


IMPORT
  S:=SYSTEM, Sys, IO, Paths, FN:=Filename, Strings, ObjFile, Memory,
  File, Storage, Par:=OLDPar, NumStr, O2Init, RSDManipulation, Task;



TYPE
  ModuleName = ARRAY 10 OF CHAR;

  Module* = POINTER TO ModuleDesc;
  ModuleDesc* = RECORD
    next : Module;
    name-: ModuleName;
    obj- : ObjFile;
    bss- : S.PTR;
    datime: File.datime;
    imports: ARRAY 129 OF Module;
    exports: ARRAY 100 OF S.PTR;
    expnum : INTEGER;
  END;

  DoProc = PROCEDURE (mod: Module);

  Command* = PROCEDURE;


VAR
  modList-, lastMod, currMod: Module;
  importsIO*, loadErr: BOOLEAN;



PROCEDURE Do*(aBlock: DoProc);
(*
 Call aBlock with every stored module.
 *)
  VAR
    mod: Module;
 BEGIN
  mod := modList;
  WHILE mod # NIL DO
    aBlock(mod);
    mod := mod.next;
  END;
 END Do;


PROCEDURE AddLoaded(VAR name: ModuleName; obj: ObjFile;
                    VAR mod: Module);
  VAR
    i: INTEGER;
    m: Module;
 BEGIN
  NEW(mod); mod.name := name; mod.obj := obj; mod.next := NIL;
  Storage.MarkNotCollectable(obj);
  Storage.MarkNotCollectable(mod);
  IF modList = NIL THEN
    modList := mod;
  ELSE
    m := modList;
    WHILE m.next # NIL DO m := m.next END;
    m.next := mod;
  END;
  FOR i := 0 TO 128 DO
    mod.imports[i] := NIL
  END;
 END AddLoaded;


PROCEDURE AllocateBss(mod: Module);
 BEGIN
  S.NEW(mod.bss, mod.obj.BssSize() );
  Memory.Fill(mod.bss, mod.obj.BssSize(), 0);
 END AllocateBss;


PROCEDURE AlreadyLoaded(VAR name: ModuleName; VAR module: Module) : BOOLEAN;
  VAR
    mod: Module;
 BEGIN
  mod := modList;
  WHILE mod # NIL DO
    IF mod.name = name THEN module := mod; RETURN TRUE END;
    mod := mod.next;
  END;
  module := NIL;
  RETURN FALSE
 END AlreadyLoaded;


PROCEDURE GetID(VAR name,StoreName : ARRAY OF CHAR);
  VAR i : INTEGER;
    storeName: ARRAY 30 OF CHAR;
 BEGIN
  FN.GetName(name, storeName); i := Strings.FPosC(".", storeName);
  IF i >= 0 THEN storeName[i] := 0X END;
  storeName[8] := 0X; Strings.CAPs(storeName);
  COPY(storeName, StoreName);
  IF storeName = "IO" THEN importsIO := TRUE END;
 END GetID;


PROCEDURE StoreExport(VAR sym: ObjFile.Symbol);
(*
 Make it an assignment procedure in V2.00!
 *)
 BEGIN
  IF ObjFile.Global IN sym.type THEN
    currMod.exports[ currMod.expnum ] := currMod.obj.TextAdr() + sym.value;
    INC(currMod.expnum);
  END;
 END StoreExport;


PROCEDURE Relocate(VAR value: LONGINT);
(*
 Make it an assignment procedure in V2.00!
 *)
  VAR
    code,modNo : INTEGER;
 BEGIN
  modNo := -SHORT(ASH(value,-24));
  IF currMod.imports[modNo] = NIL THEN
    IO.WriteString(currMod.name); IO.WriteString(" uses unknown import #");
    IO.WriteInt( modNo); IO.WriteLn; loadErr := TRUE;
    HALT(90);
  ELSE
    code := S.ANL( SHORT(ASH(value,-22)), 3 );
    value := S.ANL(value,03FFFFFH);
    CASE code OF
      0 : INC(value, currMod.imports[modNo].obj.TextAdr() ) |
      1 : INC(value, S.VAL( LONGINT, currMod.imports[modNo].bss) ) |
      2 : INC(value, currMod.imports[modNo].obj.DataAdr() ) |
      3 : IF value >= currMod.imports[modNo].expnum THEN
            IO.WriteString(currMod.name);
            IO.WriteString(" uses unknown procedure #");
            IO.WriteInt( value); IO.WriteString( " in ");
            IO.WriteString(currMod.imports[modNo].name); IO.WriteLn;
            IO.WriteString( "Module position: ");
            IO.WriteInt( S.ADR(value) - currMod.obj.TextAdr() );
            IO.WriteLn;
            loadErr := TRUE; HALT(91);
          ELSE
            value := currMod.imports[modNo].exports[value]
          END |
    END;
  END;
 END Relocate;


PROCEDURE StoreTimeAndDate(VAR name: ARRAY OF CHAR; mod: Module);
  VAR
    handle: INTEGER;
 BEGIN
  IF File.Open( name, 0, handle) THEN
    File.Datime( handle, mod.datime, 0);
    File.Close( handle);
  END;
 END StoreTimeAndDate;


PROCEDURE LinkPtrOffsets;
  VAR
    lastObj: ObjFile;

  PROCEDURE ~Link(mod: Module);
    VAR
      cp, lp, np: S.PTR;
      currObj: ObjFile;
   BEGIN
    currObj := mod.obj;
    IF currObj.IsRelocated() THEN
      cp := currObj.DataAdr() + currObj.DataSize() - 4;
      IF lastObj = NIL THEN
        S.PUT(cp, cp);
      ELSE
        lp := lastObj.DataAdr() + lastObj.DataSize() - 4;
        S.GET(lp, np); S.PUT(cp, np); S.PUT(lp, cp);
      END;
      lastObj := currObj;
    END;
   END Link;

 BEGIN
  lastObj := NIL;
  Do( Link);
 END LinkPtrOffsets;


PROCEDURE UnlinkPtrOffsets(prevObj, currObj: ObjFile);
  VAR
    pp, cp, np: S.PTR;
 BEGIN
  IF currObj.IsRelocated() THEN
    cp := currObj.DataAdr() + currObj.DataSize() - 4;
    S.GET(cp, np);
    pp := prevObj.DataAdr() + prevObj.DataSize() - 4;
    S.PUT(pp, np);
  END;
 END UnlinkPtrOffsets;


PROCEDURE SetTimeAndDate(mod: Module);
  VAR
    s: ARRAY 12 OF CHAR;

  PROCEDURE Adjust(VAR s: ARRAY OF CHAR);
   BEGIN
    IF s[1] = 0X THEN
      s[2] := 0X; s[1] := s[0]; s[0] := "0";
    END;
   END Adjust;

 BEGIN
  NumStr.IntTo( S.ANL( mod.datime.Date, 1FH), 10, s);
  Adjust(s); Strings.AppendC(".", s);
  COPY(s, Sys.compDate);
  NumStr.IntTo( S.ANL( mod.datime.Date DIV 20H, 0FH), 10, s);
  Adjust(s); Strings.AppendC(".", s);
  Strings.Append( s, Sys.compDate);
  NumStr.IntTo( S.ANL( mod.datime.Date DIV 200H, 7FH) + 1980, 10, s);
  Strings.Append( s, Sys.compDate);

  NumStr.IntTo( S.ANL( mod.datime.Time DIV 800H, 1FH), 10, s);
  Adjust(s); Strings.AppendC(":", s);
  COPY(s, Sys.compTime);
  NumStr.IntTo( S.ANL( mod.datime.Time DIV 20H, 3FH), 10, s);
  Adjust(s); Strings.AppendC(":", s);
  Strings.Append( s, Sys.compTime);
  NumStr.IntTo( S.ANL( mod.datime.Time, 1FH) * 2, 10, s);
  Adjust(s); Strings.Append( s, Sys.compTime);
 END SetTimeAndDate;


PROCEDURE Execute*(mod: Module);
(*
 Execute the module body of mod.
 *)
  VAR
    adr: LONGINT;
 BEGIN
  IF mod # NIL THEN
    SetTimeAndDate(mod);
    S.PUT( mod.bss, 0);        (* delete init var *)
    adr := mod.obj.TextAdr();      (* address of module *)
    ASSEMBLER

    MOVE.L  adr(A6),A0      (* call module *)
    JSR  (A0)

    END;
  END;
 END Execute;


PROCEDURE Load*(name: ARRAY OF CHAR) : Module;
(*
 Load the module named name. Its module body is executed.
 *)
  VAR
    filename, str: FN.path;
    storedName: ModuleName;
    begad: S.PTR;
    length: LONGINT;
    obj: ObjFile;
    prevCurrMod, mod: Module;
    versionConflict: BOOLEAN;
    fhandle: INTEGER;
    dateTime: File.datime;

  PROCEDURE CheckVersion(key: LONGINT; imp: Module) : BOOLEAN;
   BEGIN
    IF S.LSH(imp.obj.Key(),-1) > S.LSH(key,-1) THEN (* Versionskonflikt *)
      IO.WriteString( "Symbol file of ");
      IO.WriteString( imp.name);
      IO.WriteString( " is younger than the object file of ");
      IO.WriteString( mod.name); IO.WriteLn;
      IO.WriteString( "Recompile "); IO.WriteString( mod.name);
      IO.WriteString( " to achieve consistency."); IO.WriteLn;
      RETURN FALSE;
    END;
    RETURN TRUE;
   END CheckVersion;

  PROCEDURE~ LoadImport(VAR sym: ObjFile.Symbol);
    VAR
      imod: Module;
   BEGIN
    IF ~versionConflict & (ObjFile.Extern IN sym.type) THEN  (* an import *)
      imod := Load(sym.name);
      IF imod # NIL THEN
        currMod.imports[ -sym.value ] := imod;
        versionConflict := ~CheckVersion( dateTime.Date * 10000H +
            S.LONG(dateTime.Time), imod);
      ELSE
        versionConflict := TRUE;
      END;
    END;
   END LoadImport;

 BEGIN
  GetID(name, storedName);
  IF ~AlreadyLoaded(storedName, mod) THEN
    prevCurrMod := currMod;
    COPY(storedName, filename); FN.SetExt(Par.objExt, filename);
    IF Paths.Get(Par.objPaths, filename, {}, filename) &
        File.Open (filename, File.read, fhandle) THEN
      File.Datime (fhandle, dateTime, File.get);
      File.Close  (fhandle);
      IF File.Load(filename, 0, 0, begad, length) THEN
        obj := ObjFile.New(begad);
        AddLoaded( storedName, obj, mod);
        StoreTimeAndDate(filename, mod);
        currMod := mod;
        AllocateBss( mod);
        RSDManipulation.AddTable(storedName, obj, mod.bss);
        mod.expnum := 1;
        obj.SymbolsDo( StoreExport);
        versionConflict := FALSE;
        obj.SymbolsDo( LoadImport);
        IF versionConflict THEN
          Remove(mod.name); RETURN NIL;
        END;
        mod.imports[0] := mod;  (* self *)
        mod.exports[0] := mod.obj.TextAdr();
        obj.RelocDo( Relocate);
        obj.SetRelocated(TRUE);
        LinkPtrOffsets;
        IO.WriteString( "Loaded module "); IO.WriteString( filename);
        IO.WriteLn;
        Execute(mod);
      END;
    ELSE
      IO.WriteString( "Did not find ");
      IO.WriteString( name); IO.WriteLn;
      loadErr := TRUE;
      mod := NIL;
    END;
    currMod := prevCurrMod;
  END;
  RETURN mod;
 END Load;


PROCEDURE Remove*(name: ARRAY OF CHAR);
(*
 Remove the module and all modules importing it. The memory is disposed. Be
 careful when removing modules which has procedures stored in procedure
 variables elsewhere.
 *)
  VAR
    sname: ModuleName;
    mod, pmod: Module;
    i: INTEGER;
 BEGIN
  GetID(name, sname);
  pmod := S.ADR( modList); mod := modList;
  WHILE mod # NIL DO
    IF mod.name = sname THEN
      IO.WriteString( "Removing module "); IO.WriteString( sname);
      IO.WriteLn;
      IF sname = "CHATWIN" THEN
        IO.WriteString( "Removing module Chatwin will cause severe errors.");
        IO.WriteLn;
        IO.WriteString( "Terminate as soon as possible.");
        IO.WriteLn;
        RETURN;
      END;
      pmod.next := mod.next;      (* module desc unchained *)
      UnlinkPtrOffsets(pmod.obj, mod.obj);  (* ptr offsets unchained *)
      pmod := modList;
      WHILE pmod # NIL DO
        FOR i := 0 TO 128 DO
          IF pmod.imports[i] = mod THEN    (* imports mod *)
            Remove(pmod.name)
          END;
        END;
        pmod := pmod.next;
      END;
      RSDManipulation.RemoveTable(mod.name);
      IF Task.CodeRemoved(mod.obj.TextAdr(), mod.obj.DataAdr()+mod.obj.DataSize) THEN
        mod.obj.Dispose;        (* dispose obj *)
      END;
      S.DISPOSE(mod.bss);      (* dispose bss *)
      S.DISPOSE(mod);        (* dispose descriptor *)
      RETURN ;
    END;
    pmod := mod; mod := mod.next;
  END;
 END Remove;


PROCEDURE Replace*(name: ARRAY OF CHAR) : Module;
(*
 Replace the module by a new version obtained from disk. Replacing is
 secure since it will enter a JMP command at the beginning of the previous
 procedures to the new procedures. This assumes that the parameters
 remained the same. Be careful if there are type bound procedures in the
 module which have identical names. They are recognized by the order of
 appearance in the objects symbols. If you do not change the definition
 order of the records, it should be no problem to use Replace.
 The memory inbetween the JMP commands in the old object file is disposed.
 The module is not executed.
 *)
  VAR
    sname: ModuleName;
    mod, pmod: Module;
 BEGIN
  GetID(name, sname);
  pmod := S.ADR( modList); mod := modList;
  WHILE mod # NIL DO
    IF mod.name = sname THEN
      pmod.next := mod.next;      (* module desc unchained *)
      UnlinkPtrOffsets(pmod.obj, mod.obj);  (* ptr offsets unchained *)
      pmod := Load(name);
      IF pmod # NIL THEN
        mod.obj.ReplaceBy(pmod.obj);
      END;
      RETURN pmod;
    END;
    pmod := mod; mod := mod.next;
  END;
  RETURN NIL;
 END Replace;


PROCEDURE GetCommand*(mod: Module; name: ARRAY OF CHAR) : Command;
(*
 Answer the command with that name in mod.
 *)

  PROCEDURE~ Search(VAR sym: ObjFile.Symbol);
   BEGIN
    IF (sym.name = name) & (ObjFile.Text IN sym.type) THEN
      RETURN^ S.VAL( Command, mod.obj.TextAdr() + sym.value);
    END;
   END Search;

 BEGIN
  mod.obj.SymbolsDo(Search);
  RETURN NIL;
 END GetCommand;


PROCEDURE Init;
  VAR
    obj: ObjFile;
    mod: Module;
    objtdp, modtdp: S.PTR;

  PROCEDURE ~SetTdp(mod: Module);
   BEGIN
    S.PUT( S.VAL( LONGINT, mod.obj) - 4, objtdp);
    S.PUT( S.VAL( LONGINT, mod) - 4, modtdp);
    RSDManipulation.AddTable(mod.name, mod.obj, mod.bss);
   END SetTdp;

 BEGIN
  NEW(obj);
  S.GET( S.VAL( LONGINT, obj) - 4, objtdp);
  S.DISPOSE(obj);
  NEW(mod);
  S.GET( S.VAL( LONGINT, mod) - 4, modtdp);
  S.DISPOSE(mod);
  Do( SetTdp);
  LinkPtrOffsets;
 END Init;


BEGIN
  IF Sys.Loader THEN    (* called by O2LOAD.PRG *)
    modList := O2Init.modList;
    Storage.AddBlocks( O2Init.blockRoot);
    Init
  END;
  Par.Init;
END O2Modules.