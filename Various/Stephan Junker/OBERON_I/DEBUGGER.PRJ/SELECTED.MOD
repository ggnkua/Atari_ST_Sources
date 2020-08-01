MODULE Selected;


IMPORT
  S:=SYSTEM, Model, Popup, Db:=DbBase, Hexdump, Disasm, TextViewer,
  ObnPar:=OCPar, FN:=Filename, Form, WinView, Paths, Menus, Str:=Strings,
  GEMDOS, Info:=OCInfo, Sym:=OCSymbol, OCOutput, Expr:=OCExpr, Err:=OCErr,
  Par:=OCPar, OCScan, Graf, NumStr;


CONST
  VarTyp = 0; RecTyp = 1; ArrTyp = 2; DynArrTyp = 3;

  sdecimal = 0; udecimal = 1; shexadecimal = 2; uhexadecimal = 3;
  character = 4; string = 5; symbolic = 6; complex = 7; unknown = 8;
  real = 9; lreal = 10; address = 11; boolean = 12; set = 13;


TYPE
  ModObjcs* = POINTER TO ModObDesc;
  ModObDesc*= RECORD
                next*    : ModObjcs;
                name*    : ARRAY 14 OF CHAR;
                objcs*   : Sym.Symbol;
                analysed*: BOOLEAN;
                offsets* : POINTER TO ARRAY 16000 OF INTEGER;
                codelen* : INTEGER;
                source*  : S.PTR;
                srclen*  : LONGINT;
              END;


VAR
  modMenu* : Popup.Menu;
  valMenu* : Popup.Menu;
  adrMenu* : Popup.Menu;
  varMenu* : Popup.Menu;
  disMenu* : Popup.Menu;
  addr*  : S.PTR;
  dsp*   : POINTER TO ARRAY 1 OF SHORTINT;
  model* : Model.Ptr;
  item*  : LONGINT;
  modname* : ARRAY 24 OF CHAR;
  procname*: ARRAY 24 OF CHAR;
  viewer*  : WinView.Viewer;

  GetModPos*         : PROCEDURE() : LONGINT;
  CorrectCallList*   : PROCEDURE (objcs : ModObjcs);
  NewVariableViewer* : PROCEDURE (varadr : S.PTR; vartyp : INTEGER;
                                  typ : Sym.Struct; obj : Sym.Symbol;
                                  VAR name : ARRAY OF CHAR;
                                  inherit : WinView.Viewer);
  ChangeDisplay*     : PROCEDURE (display : INTEGER);

  loadedObjcs: ModObjcs;



PROCEDURE ShowText;
  VAR
    v   : TextViewer.Viewer;
    m   : TextViewer.Model;
    v2  : WinView.Viewer;
    d   : INTEGER;
    begad : S.PTR;
    length, modpos : LONGINT;
 BEGIN
  IF GetModPos = NIL THEN modpos := -1
  ELSE modpos := GetModPos();
  END;
  v2 := WinView.Windows; m := NIL;
  WHILE v2 # NIL DO
    IF (v2 IS TextViewer.Viewer) AND (v2.title = modname) THEN
      m := v2.model;
      IF v2(TextViewer.Viewer).mark = modpos THEN
        v2.Open; RETURN
      END;
    END;
    v2 := v2.nextWin;
  END;
  IF Db.LoadSource( modname, begad, length) THEN
    IF m = NIL THEN
      NEW(m); m.Initialize;
      m.SetText(begad, length);
    END;
    NEW(v); v.Initialize;
    v.SetModel(m); v.SetMark(modpos);
    v.SetTitle(modname);
    IF Db.maxX > 1000 THEN
      v.SetPos(640, v.y);
    END;
    v.Open;
  ELSE
    d := Form.Alert(1, "[2][Source not found][Cancel]");
  END;
 END ShowText;


PROCEDURE AlreadyLoaded*(name : ARRAY OF CHAR; VAR objcs : ModObjcs)
                        : BOOLEAN;
  VAR o : ModObjcs;
 BEGIN
  Str.CAPs(name);
  o := loadedObjcs;
  WHILE o # NIL DO
    IF o.name = name THEN
      objcs := o;
      RETURN TRUE
    END;
    o := o.next
  END;
  RETURN FALSE;
 END AlreadyLoaded;


PROCEDURE StoreObjects*(VAR modObjcs : ModObjcs; VAR name : ARRAY OF CHAR;
                       objcs : Sym.Symbol; analysed : BOOLEAN);
  VAR o : ModObjcs;
 BEGIN
  IF modObjcs # NIL THEN
    o := modObjcs;
  ELSE
    NEW(o);
    o.next := loadedObjcs; loadedObjcs := o;
  END;
  COPY(name, o.name); o.objcs := objcs; o.analysed := analysed;
  Str.CAPs(o.name);
(*  IF analysed THEN
    S.NEW(o.offsets, OCC.pc);
    S.MOVE( S.ADR(OCC.code), o.offsets, OCC.pc);
    o.codelen := OCC.pc;
  ELSE*)
    o.offsets := NIL; o.codelen := 0;
(*  END;*)
  modObjcs := o;
 END StoreObjects;


PROCEDURE SearchProc(VAR o : Sym.Symbol; VAR proc : ARRAY OF CHAR;
                     tbp : BOOLEAN) : BOOLEAN;
  VAR
    o2 : Sym.Symbol;
    typ : Sym.Struct;
 BEGIN
  WHILE (o # NIL) AND ((o.name # procname) OR tbp & (o.form # Sym.Tbp)) DO
    IF (o.form = Sym.Typ) AND (o.typ.form = Sym.Record) THEN
      typ := o.typ;
      REPEAT
        o2 := typ.syms;
        IF SearchProc(o2, proc, TRUE) THEN
          o := o2;
          RETURN TRUE
        END;
        typ := typ.base;
      UNTIL typ = NIL;
    ELSIF o.form IN {Sym.LProc, Sym.IProc, Sym.AProc} THEN
      o2 := o.syms;
      IF SearchProc(o2, proc, FALSE) THEN
        o := o2;
        RETURN TRUE
      END;
    END;
    o := o.next;
  END;
  IF o # NIL THEN
    o := o.syms; RETURN TRUE
  ELSE RETURN FALSE
  END;
 END SearchProc;


(*$-t *)


PROCEDURE ExitComp;
 BEGIN
  Expr.Exit; OCScan.Exit; Err.Exit; OCOutput.Exit; Par.Exit;
  Info.Exit;
 END ExitComp;


PROCEDURE InitComp(begad : S.PTR; name : ARRAY OF CHAR);
 BEGIN
  Par.Init; Par.ReadPaths; OCOutput.Init(name); Err.Init(name);
  OCScan.Init(begad); Expr.Init; Info.Init;
 END InitComp;


PROCEDURE ConnectUpperTabs(sym, syms: Sym.Symbol);
  VAR
    s: Sym.Symbol;
    typ: Sym.Struct;
 BEGIN
  s := syms;
  s.syms := sym;
  WHILE s # NIL DO
    IF s.form IN {Sym.AProc, Sym.LProc, Sym.IProc, Sym.Tbp} THEN
      ConnectUpperTabs(sym, s.syms)
    ELSIF s.form = Sym.Typ THEN
      typ := s.typ;
      IF typ.form = Sym.Pointer THEN typ := typ.base END;
      IF typ.form = Sym.Record THEN
        ConnectUpperTabs(sym, typ.syms);
      END;
    ELSIF s.form = Sym.Mod THEN
      s.syms.syms := NIL
    END;
    s := s.next;
  END;
 END ConnectUpperTabs;


PROCEDURE ReadInfo*() : Sym.Symbol;
(*
 Read the info file of modname. Answer its symbol list.
 *)
  VAR
    modName, self, name : ARRAY 80 OF CHAR;
    objcs : ModObjcs;
    o: Sym.Symbol;
    d: INTEGER;
 BEGIN
  COPY(modname, modName);
  IF ~AlreadyLoaded(modName, objcs) THEN
    COPY(modName, name); FN.SetExt("INF", name);
    InitComp( S.ADR( name), name);  (* for Par.Init *)
    IF ~Paths.Get(ObnPar.SymPaths, name, {}, name) THEN
      FN.SetExt("SYM", name);
      IF ~Paths.Get(ObnPar.SymPaths, name, {}, name) THEN
        ExitComp;
        d := Form.Alert(1, "[2][Infofile not found][Cancel]");
        RETURN NIL
      END;
    END;
    o := Info.Import(modName);
    ExitComp;
    o.next := NIL;
    IF o.syms = NIL THEN
      d := Form.Alert(1, "[2][Infofile not loaded][Cancel]");
      RETURN NIL
    END;
    ConnectUpperTabs(o, o.syms);
    o.syms.syms := NIL;
    IF Err.scanerr THEN RETURN NIL END;
    objcs := NIL;
    o := o.syms;
    StoreObjects(objcs, modName, o, FALSE)
  ELSE
    o := objcs.objcs;
  END;
  RETURN o;
 END ReadInfo;


PROCEDURE ImportVariables;
  VAR
    name : ARRAY 80 OF CHAR;
    i,d  : INTEGER;
    o,vo : Sym.Symbol;
 BEGIN
  o := ReadInfo();
  IF o = NIL THEN RETURN END;
  COPY(modname, name);
  IF procname[0] # 0X THEN (* procedure variables *)
    Str.AppendC(".", name); Str.Append(procname, name);
    vo := o.next;
    IF NOT SearchProc(vo, procname, FALSE) THEN
      d := Form.Alert(1, "[2][Procedure not found][Cancel]");
      RETURN
    END;
  ELSE
    vo := o.next;
  END;
  NewVariableViewer(addr, VarTyp, NIL, vo, name, viewer);
 END ImportVariables;

(*$+t *)


PROCEDURE ToDecimal;
 BEGIN
  IF dsp[0] # Db.Decimal THEN
    dsp[0] := Db.Decimal;
    model.Changed(item);
  END;
 END ToDecimal;


PROCEDURE ToUnsignedHex;
 BEGIN
  IF dsp[0] # Db.UnsignedHex THEN
    dsp[0] := Db.UnsignedHex;
    model.Changed(item);
  END;
 END ToUnsignedHex;


PROCEDURE ToSignedHex;
 BEGIN
  IF dsp[0] # Db.SignedHex THEN
    dsp[0] := Db.SignedHex;
    model.Changed(item);
  END;
 END ToSignedHex;


PROCEDURE Dump;
 BEGIN
  Hexdump.NewViewer( addr);
 END Dump;


PROCEDURE Disassemble;
 BEGIN
  Disasm.NewViewer( addr);
 END Disassemble;


PROCEDURE SDecimal;
 BEGIN
  ChangeDisplay(sdecimal);
 END SDecimal;


PROCEDURE UDecimal;
 BEGIN
  ChangeDisplay(udecimal);
 END UDecimal;


PROCEDURE SHexadecimal;
 BEGIN
  ChangeDisplay(shexadecimal);
 END SHexadecimal;


PROCEDURE UHexadecimal;
 BEGIN
  ChangeDisplay(uhexadecimal);
 END UHexadecimal;


PROCEDURE Character;
 BEGIN
  ChangeDisplay(character);
 END Character;


PROCEDURE String;
 BEGIN
  ChangeDisplay(string);
 END String;


PROCEDURE Real;
 BEGIN
  ChangeDisplay(real);
 END Real;


PROCEDURE LReal;
 BEGIN
  ChangeDisplay(lreal);
 END LReal;


PROCEDURE Complex;
 BEGIN
  ChangeDisplay(complex);
 END Complex;


PROCEDURE Unknown;
 BEGIN
  ChangeDisplay(unknown);
 END Unknown;


PROCEDURE Set;
 BEGIN
  ChangeDisplay(set);
 END Set;


PROCEDURE Boolean;
 BEGIN
  ChangeDisplay(boolean);
 END Boolean;


PROCEDURE Address;
 BEGIN
  ChangeDisplay(address);
 END Address;


PROCEDURE Init*;
  VAR
    mod: Sym.Symbol;
 BEGIN
  Sym.Init;
  mod := Sym.system;
  Sym.Insert( mod);
 END Init;


PROCEDURE Exit*;
 BEGIN
  model := NIL;
  viewer := NIL;
  loadedObjcs := NIL;
  Sym.Exit;
 END Exit;


PROCEDURE InitMod;
 BEGIN
  NEW(modMenu); modMenu.Init;
  modMenu.Set("Quelltext zeigen", ShowText);
  modMenu.Set("Variablen zeigen", ImportVariables);

  NEW(valMenu); valMenu.Init;
  valMenu.Set("Dezimal", ToDecimal);
  valMenu.Set("Hexadezimal ohne Vorz.", ToUnsignedHex);
  valMenu.Set("Hexadezimal mit Vorz.", ToSignedHex);

  NEW(adrMenu); adrMenu.Init;
  adrMenu.Set("Dezimal", ToDecimal);
  adrMenu.Set("Hexadezimal mit Vorz.", ToSignedHex);
  adrMenu.Set("Hexadezimal ohne Vorz.", ToUnsignedHex);
  adrMenu.Set("Hexdump", Dump);
  adrMenu.Set("Disassemblieren", Disassemble);

  NEW(disMenu); disMenu.Init;
  disMenu.Set("Hexdump", Dump);
  disMenu.Set("Disassemblieren", Disassemble);

  NEW(varMenu); varMenu.Init;
  varMenu.Set("Set", Set);
  varMenu.Set("Boolean", Boolean);
  varMenu.Set("Character", Character);
  varMenu.Set("String", String);
  varMenu.Set("Dezimal mit Vz.", SDecimal);
(*  varMenu.Set("Dezimal ohne Vz.", UDecimal); geht nicht *)
  varMenu.Set("Hexadezimal mit Vz.", SHexadecimal);
  varMenu.Set("Hexadezimal ohne Vz.", UHexadecimal);
  varMenu.Set("Fliežkomma", Real);
  varMenu.Set("Lang Fliežkomma", LReal);
  varMenu.Set("Adresse", Address);
(*  varMenu.Set("Komplex", Complex);*)
  varMenu.Set("Unbekannt", Unknown);
  varMenu.Set("Hexdump", Dump);
  varMenu.Set("Disassemblieren", Disassemble);
 END InitMod;


BEGIN
  InitMod;
END Selected.