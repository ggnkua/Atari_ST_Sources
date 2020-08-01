MODULE O2Load; (* SJ 7.11.94 *)

(*
 Loads and runs object files produced by STJ-Oberon-2 V2.00.
 For older object files, the setting of Sys.CompTime, Sys.CompDate
 and Sys.StackSize has to be changed.
 *)


IMPORT
  S:=SYSTEM, Sys, CommandLine, LS:=O2LS, Memory, Storage, O2Init;



TYPE
  ModuleName = ARRAY 10 OF CHAR;

  Module = POINTER TO ModuleDesc;
  ModuleDesc = RECORD
    next: Module;
    name: ModuleName;
    obj : LS.ObjFile;
    bss : S.PTR;
    datime: LS.datime;
    imports: ARRAY 129 OF Module;
    exports: ARRAY 100 OF S.PTR;
    expnum : INTEGER;
  END;



VAR
  loadErr: BOOLEAN;
  modList, lastMod, currMod: Module;
  defStart: LS.path;



PROCEDURE AddLoaded(VAR name: ModuleName; obj: LS.ObjFile;
                    VAR mod: Module);
  VAR
    i: INTEGER;
 BEGIN
  NEW(mod); mod.name := name; mod.obj := obj; mod.next := NIL;
  Storage.MarkNotCollectable(obj);
  Storage.MarkNotCollectable(mod);
  IF lastMod = NIL THEN
    modList := mod;
  ELSE
    lastMod.next := mod;
  END;
  lastMod := mod;
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
 BEGIN
  LS.GetName(name, StoreName); i := LS.FPosC(".", StoreName);
  IF i >= 0 THEN StoreName[i] := 0X END;
  StoreName[8] := 0X; LS.CAPs(StoreName);
 END GetID;


PROCEDURE StoreExport(VAR sym: LS.Symbol);
(*
 Make it an assignment procedure in V2.00!
 *)
 BEGIN
  IF LS.Global IN sym.type THEN
    currMod.exports[ currMod.expnum ] := currMod.obj.TextAdr() + sym.value;
    INC(currMod.expnum);
  END;
 END StoreExport;


PROCEDURE^ LoadModule(name: ARRAY OF CHAR) : Module;


PROCEDURE LoadImport(VAR sym: LS.Symbol);
(*
 Make it an assignment procedure in V2.00!
 *)
 BEGIN
  IF LS.Extern IN sym.type THEN  (* an import *)
    currMod.imports[ -sym.value ] := LoadModule(sym.name);
  END;
 END LoadImport;


PROCEDURE Relocate(VAR value: LONGINT);
(*
 Make it an assignment procedure in V2.00!
 *)
  VAR
    code,modNo : INTEGER;
 BEGIN
  modNo := -SHORT(ASH(value,-24));
  IF currMod.imports[modNo] = NIL THEN
    LS.WriteString(currMod.name); LS.WriteString(" uses unknown import");
    LS.WriteLn; loadErr := TRUE;
    HALT(90);
  ELSE
    code := S.ANL( SHORT(ASH(value,-22)), 3 );
    value := S.ANL(value,03FFFFFH);
    CASE code OF
      0 : INC(value, currMod.imports[modNo].obj.TextAdr() ) |
      1 : INC(value, S.VAL( LONGINT, currMod.imports[modNo].bss) ) |
      2 : INC(value, currMod.imports[modNo].obj.DataAdr() ) |
      3 : IF value >= currMod.imports[modNo].expnum THEN
            LS.WriteString(currMod.name);
            LS.WriteString(" uses unknown procedure in ");
            LS.WriteString(currMod.imports[modNo].name); LS.WriteLn;
            loadErr := TRUE; HALT(91);
          ELSE
            value := currMod.imports[modNo].exports[value]
          END |
    END;
  END;
 END Relocate;


PROCEDURE SetSysData(obj: LS.ObjFile);
  VAR
    sysData: LS.SysData;
    objName, s: LS.path;
    objHandle: INTEGER;
    datime : LS.datime;
    stack: LONGINT;

  PROCEDURE Adjust(VAR s: ARRAY OF CHAR);
   BEGIN
    IF s[1] = 0X THEN
      s[2] := 0X; s[1] := s[0]; s[0] := "0";
    END;
   END Adjust;

 BEGIN
  sysData := obj.DataAdr();
  S.GETREG(15, stack);
  sysData.stackSize := stack - S.ADR( O2Init.Start);
  LS.GetName(defStart, objName); LS.SetExt( LS.objExt, objName);
  IF LS.PathsGet(LS.objPaths, objName, {}, objName) AND
      LS.Open( objName, 0, objHandle) THEN
    LS.Datime( objHandle, datime, 0);
    LS.Close( objHandle);
    LS.IntToStr( S.ANL( datime.Date, 1FH), 10, s);
    Adjust(s); LS.AppendC(".", s);
    COPY(s, sysData.compDate);
    LS.IntToStr( S.ANL( datime.Date DIV 20H, 0FH), 10, s);
    Adjust(s); LS.AppendC(".", s);
    LS.Append( s, sysData.compDate);
    LS.IntToStr( S.ANL( datime.Date DIV 200H, 7FH) + 1980, 10, s);
    LS.Append( s, sysData.compDate);

    LS.IntToStr( S.ANL( datime.Time DIV 800H, 1FH), 10, s);
    Adjust(s); LS.AppendC(":", s);
    COPY(s, sysData.compTime);
    LS.IntToStr( S.ANL( datime.Time DIV 20H, 3FH), 10, s);
    Adjust(s); LS.AppendC(":", s);
    LS.Append( s, sysData.compTime);
    LS.IntToStr( S.ANL( datime.Time, 1FH) * 2, 10, s);
    Adjust(s); LS.Append( s, sysData.compTime);
  END;
 END SetSysData;


PROCEDURE LoadModule(name: ARRAY OF CHAR) : Module;
  VAR
    filename, str: LS.path;
    storedName: ModuleName;
    begad: S.PTR;
    length: LONGINT;
    obj: LS.ObjFile;
    prevCurrMod, mod: Module;
 BEGIN
  GetID(name, storedName);
  IF ~AlreadyLoaded(storedName, mod) THEN
    prevCurrMod := currMod;
    COPY(storedName, filename); LS.SetExt(LS.objExt, filename);
    IF LS.PathsGet(LS.objPaths, filename, {}, filename) &
        LS.Load(filename, 0, 0, begad, length) THEN
      obj := LS.New(begad);
      AddLoaded( storedName, obj, mod);
      currMod := mod;
      AllocateBss( mod);
      mod.expnum := 1;
      obj.SymbolsDo( StoreExport);
      obj.SymbolsDo( LoadImport);
      mod.imports[0] := mod;  (* self *)
      mod.exports[0] := mod.obj.TextAdr();
      obj.RelocDo( Relocate);
      IF storedName = "SYS" THEN SetSysData(obj) END;
    ELSE
      LS.WriteString( "Did not find ");
      LS.WriteString( name); LS.WriteLn;
      loadErr := TRUE;
    END;
    currMod := prevCurrMod;
  END;
  RETURN mod;
 END LoadModule;


PROCEDURE Execute(o2init, main: Module);
  VAR
    adr1, adr2: LONGINT;
 BEGIN
  Sys.Basepage.LowTPA := -Sys.Basepage.LowTPA;  (* mark loader *)
  adr1 := o2init.obj.TextAdr();      (* address of O2Init *)
  adr2 := main.obj.TextAdr();      (* address of main module *)
  S.PUT( o2init.obj.DataAdr() - 40, adr2);
  ASSEMBLER

    MOVE.L  modList,-(SP)      (* parameter *)
    MOVE.L  #Storage.keepFree+4,A0 (* work around compiler bug *)
    MOVE.L  (A0),-(SP)
    MOVE.L  Sys.Basepage,A0
    MOVE.L  adr1(A6),A1      (* call O2Init *)
    JSR  (A1)
    ADDQ.L  #8,SP

  END;
 END Execute;


PROCEDURE CopyEnvironment;
(*
 Copy the environment variables in OBERON.ENV into the usual environment.
 *)
  VAR
    p,len,length,diff : LONGINT;
    begad : S.PTR;
    b,c : CHAR;
 BEGIN
  p := Sys.Basepage.Env;    (* get env len *)
  REPEAT
    REPEAT
      S.GET(p, c); INC(p);
    UNTIL c = 0X;
    S.GET(p, b); INC(p);
  UNTIL b = 0X;        (* double 0 *)
  len := p-Sys.Basepage.Env;
  IF LS.Load("OBERON.ENV", 0, len, begad, length) THEN
    S.PUT(begad+length, 0);
    p := begad; diff := 0;
    REPEAT
      REPEAT
        S.GET(p, c);
        S.PUT(p-diff, c);
        INC(p);
      UNTIL (c = 0DX) OR (c = 0AX) OR (c = 0X);
      IF c # 0X THEN
        S.PUT(p-diff-1, 0);    (* terminate previous var *)
        S.GET(p, c);
        IF c = 0AX THEN      (* 0DX + 0AX *)
          INC(diff);
          INC(p);
          S.GET(p, c);
        END;
      END;
    UNTIL c = 0X;
    S.MOVE(Sys.Basepage.Env, p-diff, len);
    Sys.Basepage.Env := begad;
  END;
 END CopyEnvironment;


PROCEDURE Start;
  VAR
    o2init, main: Module;
 BEGIN
  CopyEnvironment;
  LS.InitPar;
  IF CommandLine.arg # NIL THEN
    COPY( CommandLine.arg^, defStart);
    Sys.Basepage.ComLen := 0; Sys.Basepage.Command[0] := 0X;
  ELSIF NOT LS.ReadStr("DEFSTART", defStart) THEN
    defStart[0] := 0X;
  END;
  IF defStart[0] # 0X THEN
    loadErr := FALSE;
    o2init := LoadModule("O2INIT");
    main := LoadModule(defStart);
    IF ~loadErr THEN Execute(o2init, main) END;
  END;
 END Start;


BEGIN
  Start
END O2Load.