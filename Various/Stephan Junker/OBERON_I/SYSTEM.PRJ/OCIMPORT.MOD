MODULE OCImport; (* SJ  1.5.94 *)


IMPORT
  S:=SYSTEM, FN:=Filename, Sym:=OCSymbol, Files:=BFiles, Output:=OCOutput,
  Expr:=OCExpr, Err:=OCErr, Par:=OCPar, Scan:=OCScan, File,
  IO, Paths, Strings;



CONST
  SfTag200 = 53323030H;	(* "S200" *)
  SfTag203 = 53323033H;	(* "S203" *)
  CurrSfTag = SfTag203;

  NumSymbols = 2000; NumStructs = 500; NumGlbMod = 100;
  NumEqualTypes = 500;

  (* which symbols: *)
  ExportedSym = 0; AllSymUptoSep = 1;

  (* error codes *)
  nosymfile = 181; symerr = 184; symnotfnd = 186; version = 182;



TYPE
  StringPtr = POINTER TO ARRAY 24 OF CHAR;
  Rider = RECORD
    addr: S.PTR;
  END;
  ImpFile = POINTER TO RECORD
    addr: S.PTR;
    len : LONGINT;
  END;



VAR
  modno* : INTEGER;
  symfile: Files.File; symr: Output.Rider;
  fsym: ImpFile; fsymr: Rider;
  symbols: ARRAY NumSymbols OF Sym.Symbol;
  structs: ARRAY NumStructs OF Sym.Struct;
  symcnt, strcnt: INTEGER;
  glbmod-: ARRAY NumGlbMod OF Sym.Symbol; nofgmod-: INTEGER;
  equalTypes: ARRAY NumEqualTypes OF Sym.Struct;
  etx, netx: INTEGER;
  normalImport : BOOLEAN;
  sftag: LONGINT;

(*---------------------------------------------------------------------*)

PROCEDURE Old(name: ARRAY OF CHAR) : ImpFile;
  VAR
    f: ImpFile;
 BEGIN
  NEW(f);
  IF ~File.Load( name, 0, 0, f.addr, f.len) THEN
    f := NIL;
  END;
  RETURN f;
 END Old;


PROCEDURE (f: ImpFile) Close;
 BEGIN
  S.DISPOSE(f.addr);
 END Close;


PROCEDURE (VAR r: Rider) Set(file: ImpFile; pos: LONGINT);
 BEGIN
  r.addr := file.addr + pos;
 END Set;


PROCEDURE (VAR r: Rider) Read(VAR byte: S.BYTE);
 BEGIN
  S.GET(r.addr, byte);
  INC(r.addr);
 END Read;


PROCEDURE (VAR r: Rider) ReadInt(VAR int: INTEGER);
  VAR
    si1, si2: SHORTINT;
 BEGIN
  S.GET(r.addr, si1);
  S.GET(r.addr+1, si2);
  INC(r.addr, 2);
  int := si1 * 256 + S.LONG(si2);
 END ReadInt;


PROCEDURE (VAR r: Rider) ReadLInt(VAR int: LONGINT);
  VAR
    si1, si2, si3, si4: SHORTINT;
 BEGIN
  S.GET(r.addr, si1);
  S.GET(r.addr+1, si2);
  S.GET(r.addr+2, si3);
  S.GET(r.addr+3, si4);
  INC(r.addr, 4);
  int := (S.LONG(si1 * 256 + S.LONG(si2)) * 256 + S.LONG(si3)) * 256 + S.LONG(si4);
 END ReadLInt;


PROCEDURE (VAR r: Rider) ReadId(VAR id: ARRAY OF CHAR);
  VAR
    c: CHAR;
    i: INTEGER;
 BEGIN
  i := 0;
  REPEAT
    S.GET(r.addr, c);
    id[i] := c; INC(i);
    INC(r.addr);
  UNTIL c = 0X;
 END ReadId;

(*---------------------------------------------------------------------*)

PROCEDURE GlobalModule*(sym: Sym.Symbol; key: LONGINT);
  VAR
    i: INTEGER;
    sp, sp2: POINTER TO ARRAY 24 OF CHAR;
 BEGIN
  FOR i := 0 TO nofgmod-1 DO
    sp := glbmod[i].a0;
    sp2 := sym.a0;
    IF sp^ = sp2^ THEN
      IF key = 0 THEN sym.a1 := glbmod[i].a1
      ELSIF glbmod[i].a1 = 0 THEN glbmod[i].a1 := key
      ELSIF (glbmod[i].a1 # key) THEN Err.Mark(version)
      END;
      sym.lev := glbmod[i].lev;
      RETURN
    END;
  END;
  glbmod[nofgmod] := sym; INC(nofgmod);
  sym.lev := -nofgmod;
  sym.a1 := key;
 END GlobalModule;


PROCEDURE ReadSymbol(sym: Sym.Symbol);
  VAR
    r: REAL; lr: LONGREAL; li: LONGINT;
    si: SHORTINT; i: INTEGER;
    x: Expr.Expr;
    str: ARRAY 256 OF CHAR;
    sp: Strings.ptr;

  PROCEDURE ReadTbp(sym: Sym.Symbol);
    VAR
      i, modref: INTEGER;
   BEGIN
    fsymr.ReadInt(modref);
    IF modref = 0 THEN modref := modno
    ELSE modref := symbols[modref].lev
    END;
    fsymr.ReadInt( i );(* procno *)
    sym.a0 := i + modref*1000000H+0C00000H;
    sym.lev := i;
   END ReadTbp;

 BEGIN
  fsymr.Read( si); sym.form := si;
  fsymr.ReadId(sym.name);
  fsymr.ReadInt(i); sym.next := symbols[i];
  sym.lev := modno;
  CASE sym.form OF
    Sym.Var, Sym.Fld, Sym.Ind, Sym.Cpy:
      fsymr.ReadInt(i); sym.typ := structs[i];
      fsymr.ReadLInt(sym.a0);
      fsymr.Read( si); sym.mark := si;
      IF (sym.form = Sym.Var) THEN
        INC(sym.a0, modno*1000000H+400000H);
      END;
  | Sym.Typ:
      fsymr.ReadInt(i); sym.typ := structs[i];
  | Sym.LProc, Sym.IProc, Sym.CProc, Sym.Tbp:
      IF (sym.form # Sym.Tbp) OR (sym.name # "") THEN
        fsymr.ReadInt(i); sym.typ := structs[i];
        Sym.NewSym( Sym.Head, sym.syms);
        fsymr.ReadInt(i); sym.syms.next := symbols[i];
        fsymr.ReadInt( i); sym.a1 := i;
        IF sym.form = Sym.CProc THEN
          fsymr.ReadInt( i); sym.a0 := i;
        ELSIF (sym.form IN {Sym.LProc, Sym.IProc}) THEN
          INC(sym.a1, modno*1000000H+0C00000H);
          sym.a0 := sym.a1;
        ELSIF (sym.form = Sym.Tbp) THEN
          ReadTbp(sym);
          fsymr.Read(si); sym.mark := si;
          IF normalImport & (sym.mark = Sym.NoExport) THEN
            sym.name := ""
          END;
        END;
      ELSE
        fsymr.ReadInt( i); sym.a1 := i;
        ReadTbp(sym);
      END;
  | Sym.Mod:
      sym.syms := NIL;
      fsymr.ReadLInt( sym.a1);
      IF normalImport & (sym.name # "SYSTEM") THEN
        sym.a0 := S.ADR( sym.name);
        GlobalModule(sym, sym.a1);
      END;
  | Sym.Con:
      fsymr.ReadInt(i); sym.typ := structs[i];
      fsymr.Read( si); sym.typ.form := si;
      Expr.New( Expr.Con, x, sym.typ);
      Expr.MarkUsed(x);
      sym.a1 := S.VAL( LONGINT, x);
      IF sym.typ.form = Sym.String THEN
        fsymr.ReadId(str);
        S.NEW(sp, Strings.Length(str)+1);
        COPY(str, sp^);
        x.a1 := S.VAL( LONGINT, sp); x.a0 := -1
      ELSE
        fsymr.ReadLInt( x.a0);
        IF sym.typ.form = Sym.LReal THEN
          fsymr.ReadLInt( x.a1);
        END;
      END;
  ELSE
  END;
 END ReadSymbol;


PROCEDURE ReadStruct(typ: Sym.Struct);
  VAR
    si: SHORTINT; i: INTEGER;
    name: ARRAY 50 OF CHAR;
 BEGIN
  fsymr.Read( si); typ.form := si;
  IF sftag = SfTag203 THEN	(* V2.03 *)
    fsymr.ReadId(name);
    IF name # "" THEN
      S.NEW(typ.name, Strings.Length(name) + 1);
      COPY(name, typ.name^);
    END;
  END;
  fsymr.ReadLInt(typ.size);
  CASE typ.form OF
    Sym.Pointer:
      fsymr.ReadInt(i); typ.base := structs[i];
  | Sym.DynArr, Sym.OpenArr:
      fsymr.ReadInt(i); typ.base := structs[i];
      fsymr.ReadLInt( typ.a0);
      INC(typ.a0, modno*1000000H+800000H)
  | Sym.Array:
      fsymr.ReadInt(i); typ.base := structs[i];
      fsymr.ReadLInt( typ.n);
      fsymr.ReadLInt( typ.a0);
      INC(typ.a0, modno*1000000H+800000H)
  | Sym.ProcTyp:
      fsymr.ReadInt(i); typ.base := structs[i];
      Sym.NewSym( Sym.Head, typ.syms);
      fsymr.ReadInt(i); typ.syms.next := symbols[i];
  | Sym.Record:
      fsymr.ReadInt(i); typ.base := structs[i];
      Sym.NewSym( Sym.Head, typ.syms);
      fsymr.ReadInt(i); typ.syms.next := symbols[i];
      fsymr.ReadInt( i); typ.n := i;
      fsymr.ReadInt( i);
      IF i = 0 THEN i := modno
      ELSE i := symbols[i].lev
      END;
      fsymr.ReadLInt( typ.a0);
      INC(typ.a0, i*1000000H+800000H);
  ELSE
  END;
 END ReadStruct;

(*
PROCEDURE SameTypeAvailable(old: Sym.Struct; VAR new: Sym.Struct) : BOOLEAN;

  PROCEDURE CheckTyp(typ: Sym.Struct) : BOOLEAN;
   BEGIN
    IF Sym.SameType(typ, old) THEN new := typ; RETURN TRUE
    ELSIF (typ.form IN {Sym.Pointer..Sym.Record}) & (typ.base # NIL) THEN
      RETURN CheckTyp(typ.base);
    END;
    RETURN FALSE
   END CheckTyp;

  PROCEDURE SearchList(sym: Sym.Symbol) : BOOLEAN;
   BEGIN
    WHILE sym # NIL DO
      IF sym.form = Sym.Mod THEN
        IF SearchList(sym.syms) THEN RETURN TRUE END;
      ELSIF sym.form = Sym.Typ THEN
        IF CheckTyp(sym.typ) THEN RETURN TRUE END;
      END;
      sym := sym.next;
    END;
    RETURN FALSE
   END SearchList;

 BEGIN
  RETURN SearchList(Sym.global)
 END SameTypeAvailable;


PROCEDURE ReplaceStruct(old, new: Sym.Struct);
  VAR
    i: INTEGER;

  PROCEDURE Replace(VAR typ: Sym.Struct);
   BEGIN
    IF typ = old THEN typ := new;
    ELSIF (typ.form IN {Sym.Pointer..Sym.Record}) & (typ.base # NIL) THEN
      Replace(typ.base);
    END;
   END Replace;

  PROCEDURE Dispose(old: Sym.Struct);
    VAR
      sym, sym2: Sym.Symbol;
   BEGIN
    IF old.form IN {Sym.ProcTyp, Sym.Record} THEN
      sym := old.syms;
      WHILE sym # NIL DO
        sym2 := sym; sym := sym.next;
        Sym.DisposeSym(sym2);
      END;
    END;
    Sym.DisposeStr(old);
   END Dispose;

 BEGIN
  FOR i := 1 TO symcnt DO
    IF symbols[i].form IN {Sym.Var..Sym.IProc, Sym.Con..Sym.Cpy, Sym.AProc} THEN
      Replace(symbols[i].typ);
    END;
  END;
  Dispose(old);
 END ReplaceStruct;
*)

PROCEDURE ReadObjects;
  VAR
    i: INTEGER;
    typ: Sym.Struct;
 BEGIN
  fsymr.ReadInt(symcnt); fsymr.ReadInt(strcnt);
  FOR i := 1 TO symcnt DO
    Sym.NewSym(Sym.Def, symbols[i]);
  END;
  FOR i := 1 TO strcnt DO
    Sym.NewStr(Sym.Undef, structs[i]);
  END;
  symbols[0] := NIL; structs[0] := NIL;
  symbols[symcnt+1] := NIL;
  FOR i := 1 TO symcnt DO
    ReadSymbol(symbols[i]);
  END;
  FOR i := 1 TO strcnt DO
    ReadStruct(structs[i]);
  END;
(*  FOR i := 1 TO strcnt DO
    IF SameTypeAvailable(structs[i], typ) THEN
      ReplaceStruct(structs[i], typ)
    END;
  END;*)
 END ReadObjects;


PROCEDURE AppendSyms(symbols: Sym.Symbol);
  VAR
    sym: Sym.Symbol;
 BEGIN
  sym := Sym.global;
  WHILE sym.next # NIL DO sym := sym.next END;
  sym.next := symbols;
 END AppendSyms;


PROCEDURE FirstSymbol() : Sym.Symbol;
  VAR
    i: INTEGER;
    fsym: Sym.Symbol;
 BEGIN
  fsym := symbols[1];
  FOR i := 2 TO symcnt DO
    IF symbols[i].next = fsym THEN fsym := symbols[i] END;
  END;
  RETURN fsym;
 END FirstSymbol;


PROCEDURE RemoveMods(fsym: Sym.Symbol);
  VAR
    prev, sym: Sym.Symbol;
 BEGIN
  prev := fsym; sym := prev;
  WHILE sym # NIL DO
    IF sym.form = Sym.Mod THEN
      prev.next := sym.next;
    ELSE
      prev := sym;
    END;
    sym := sym.next;
  END;
 END RemoveMods;


PROCEDURE ReadImport(VAR modname: ARRAY OF CHAR;
                     import: BOOLEAN; mod: Sym.Symbol;
                     VAR loaded : BOOLEAN);
  VAR
    sp: POINTER TO ARRAY 24 OF CHAR;
    name: ARRAY 40 OF CHAR;
 BEGIN
  normalImport := import;
  fsymr.Set( fsym, 0);
  fsymr.ReadLInt(sftag);
  IF (sftag >= SfTag200) & (sftag <= CurrSfTag) THEN
    fsymr.ReadLInt(mod.a1); fsymr.ReadId(name);
    IF mod.name = "@" THEN COPY(name, mod.name) END;
    modno := mod.lev;
    IF import THEN GlobalModule(mod, mod.a1) END;
    ReadObjects;
    Sym.NewSym( Sym.Head, mod.syms);
    mod.syms.next := FirstSymbol();
    RemoveMods(mod.syms);
    mod.syms.syms := NIL;
    modno := -1-nofgmod;
    loaded := TRUE;
  ELSE
    loaded := FALSE;
  END;
  fsym.Close;
  S.DISPOSE(fsym);
  symcnt := 0; strcnt := 0;
 END ReadImport;


PROCEDURE RealImport(mod: Sym.Symbol);
  VAR
    filename: FN.path;
    loaded : BOOLEAN;
    sp: StringPtr;
 BEGIN
  sp := mod.a0;
  COPY(sp^, filename);
  filename[8] := 0X;
  FN.SetExt("SYM", filename);
  IF Paths.Get(Par.SymPaths, filename, {}, filename) THEN
    IO.WriteString( "Importing "); IO.WriteString( filename); IO.WriteLn;
    fsym := Old(filename);
    ReadImport(mod.name, TRUE, mod, loaded);
    IF ~loaded THEN
      Err.Mark(nosymfile);
    END;
  ELSE
    Err.Mark(symnotfnd)
  END;
 END RealImport;


PROCEDURE Import*(VAR name, modname : ARRAY OF CHAR; unqualified : BOOLEAN);
  CONST
    System = "SYSTEM";
  VAR
    mod: Sym.Symbol;
    sp: StringPtr;
 BEGIN
  IF name = System THEN
    mod := Sym.system;
    mod.a0 := S.ADR(System);
    COPY(modname, mod.name);
    Sym.Insert(mod);
    mod.a1 := 0;
    IF unqualified THEN
      AppendSyms(mod.syms);
    END;
    mod.mark := S.VAL( SHORTINT, unqualified)
  ELSE
    Sym.NewSymNamed( Sym.Mod, modname, mod);
    NEW(sp); COPY(name, sp^);
    mod.a0 := S.VAL( LONGINT, sp);
    mod.syms := NIL;
    GlobalModule(mod, 0);
    mod.mark := S.VAL( SHORTINT, unqualified);
    Sym.Insert(mod);
    modno := -1-nofgmod;
    IF unqualified THEN
      RealImport(mod);
      AppendSyms(symbols[1])
    END;
  END;
 END Import;


PROCEDURE ImportSelf*(VAR name: ARRAY OF CHAR);
  VAR
    filename: FN.path;
    mod: Sym.Symbol;
    loaded : BOOLEAN;
 BEGIN
  COPY(name, filename);
  filename[8] := 0X;
  FN.SetExt("SYM", filename);
  IF Paths.Get(Par.SymPaths, filename, {}, filename) THEN
    Sym.NewSymNamed( Sym.Mod, name, mod);
    mod.a0 := S.ADR( mod.name);
    fsym := Old(filename);
    ReadImport(name, FALSE, mod, loaded);
    IF loaded THEN Sym.self := mod END;
  END;
 END ImportSelf;


PROCEDURE SymList*(mod: Sym.Symbol) : Sym.Symbol;
 BEGIN
  IF mod.syms = NIL THEN
    RealImport(mod);
  END;
  RETURN mod.syms;
 END SymList;


PROCEDURE WriteNextRef(sym: Sym.Symbol);
 BEGIN
  WHILE sym # NIL DO
    IF (sym.ref # 0) & (sym.form # Sym.Mod) THEN
      symr.WriteInt(sym.ref); RETURN
    END;
    sym := sym.next
  END;
  symr.WriteInt(0);
 END WriteNextRef;


PROCEDURE FindTbpMod(tbp: Sym.Symbol; VAR mod : Sym.Symbol) : BOOLEAN;
  VAR
    mno: INTEGER;
 BEGIN
  mno := SHORT( tbp.a0 DIV 1000000H );
  IF mno = 0 THEN RETURN FALSE END;
  mod := glbmod[ -1-mno ];
  RETURN TRUE
 END FindTbpMod;


PROCEDURE TbpModRef(tbp: Sym.Symbol) : INTEGER;
  VAR
    sym: Sym.Symbol;
 BEGIN
  IF FindTbpMod(tbp, sym) THEN RETURN sym.ref ELSE RETURN 0 END;
 END TbpModRef;


PROCEDURE FindTypMod(typ: Sym.Struct; VAR mod : Sym.Symbol) : BOOLEAN;
  VAR
    mno: INTEGER;
 BEGIN
  mno := SHORT( typ.a0 DIV 1000000H );
  IF mno = 0 THEN RETURN FALSE END;
  mod := glbmod[ -1-mno ];
  RETURN TRUE
 END FindTypMod;


PROCEDURE TypModRef(typ: Sym.Struct) : INTEGER;
  VAR
    sym: Sym.Symbol;
 BEGIN
  IF FindTypMod(typ, sym) THEN RETURN sym.ref ELSE RETURN 0 END;
 END TypModRef;


PROCEDURE WriteSymbol(sym: Sym.Symbol);
  VAR
    x: Expr.Expr;
    name: ARRAY 24 OF CHAR;
    sp: Strings.ptr;

  PROCEDURE WriteTbp(sym: Sym.Symbol);
   BEGIN
    symr.WriteInt( TbpModRef(sym) );
    symr.WriteInt( sym.lev );(* procno *)
   END WriteTbp;

 BEGIN
  symr.Write( SHORT( sym.form) );
  COPY(sym.name, name);
  IF (sym.form = Sym.Sep) THEN
    sym.name := "";
  END;
  symr.WriteId(sym.name);
  COPY(name, sym.name);
  WriteNextRef(sym.next);
  CASE sym.form OF
    Sym.Var, Sym.Fld, Sym.Ind, Sym.Cpy:
      symr.WriteInt(sym.typ.ref);
      IF sym.form = Sym.Var THEN symr.WriteLInt(sym.a0-400000H)
      ELSE symr.WriteLInt(sym.a0)
      END;
      symr.Write( SHORT( sym.mark) );
  | Sym.Typ:
      symr.WriteInt(sym.typ.ref);
  | Sym.LProc, Sym.IProc, Sym.CProc, Sym.Tbp:
      IF (sym.form # Sym.Tbp) OR (sym.name # "") THEN
        symr.WriteInt(sym.typ.ref);
        symr.WriteInt(sym.syms.next.ref);
        symr.WriteInt( SHORT( sym.a1) );
        IF sym.form = Sym.CProc THEN
          symr.WriteInt( SHORT( sym.a0) );
        ELSIF sym.form = Sym.Tbp THEN
          WriteTbp(sym);
          symr.Write( SHORT( sym.mark) );
        END;
      ELSE
        symr.WriteInt( SHORT( sym.a1) );
        WriteTbp(sym);
      END;
  | Sym.Mod:
      symr.WriteLInt( sym.a1);
  | Sym.Con:
      symr.WriteInt(sym.typ.ref);
      symr.Write( SHORT( sym.typ.form) );
      x := Expr.EvaluateExpr( S.VAL( Expr.Expr, sym.a1) );
      IF sym.typ.form = Sym.String THEN
        sp := S.VAL( Strings.ptr, x.a1);
        symr.WriteId(sp^);
      ELSE
        symr.WriteLInt( x.a0);
        IF sym.typ.form = Sym.LReal THEN
          symr.WriteLInt( x.a1);
        END;
      END;
  ELSE
  END;
 END WriteSymbol;


PROCEDURE WriteStruct(typ: Sym.Struct);
 BEGIN
  symr.Write( SHORT( typ.form) );
  IF typ.name = NIL THEN symr.Write(0)	(* V2.03 *)
  ELSE symr.WriteId(typ.name^)
  END;
  symr.WriteLInt(typ.size);
  CASE typ.form OF
    Sym.Pointer:
      symr.WriteInt(typ.base.ref);
  | Sym.DynArr, Sym.OpenArr:
      symr.WriteInt(typ.base.ref);
      symr.WriteLInt( typ.a0 MOD 400000H);
  | Sym.Array:
      symr.WriteInt(typ.base.ref);
      symr.WriteLInt( typ.n);
      symr.WriteLInt( typ.a0 MOD 400000H);
  | Sym.ProcTyp:
      symr.WriteInt(typ.base.ref);
      WriteNextRef(typ.syms);
  | Sym.Record:
      IF typ.base # NIL THEN
        symr.WriteInt(typ.base.ref);
      ELSE
        symr.WriteInt(0)
      END;
      WriteNextRef(typ.syms);
      symr.WriteInt( SHORT( typ.n) );
      symr.WriteInt( TypModRef(typ) );
      symr.WriteLInt( typ.a0 MOD 400000H);
  ELSE
  END;
 END WriteStruct;


PROCEDURE WriteObjects;
  VAR
    i : INTEGER;
 BEGIN
  symr.WriteInt(symcnt); symr.WriteInt(strcnt);
  FOR i := 1 TO symcnt DO
    WriteSymbol(symbols[i]);
  END;
  FOR i := 1 TO strcnt DO
    WriteStruct(structs[i]);
  END;
 END WriteObjects;


PROCEDURE StoreSymExport(sym: Sym.Symbol);
 BEGIN
  IF sym.ref = 0 THEN
    INC(symcnt); sym.ref := symcnt;
    symbols[symcnt] := sym;
  END;
 END StoreSymExport;


PROCEDURE StoreStrExport(str: Sym.Struct);
 BEGIN
  IF str.ref = 0 THEN
    INC(strcnt); str.ref := strcnt;
    structs[strcnt] := str;
  END;
 END StoreStrExport;


PROCEDURE^ ExportSymbols(sym: Sym.Symbol; which: INTEGER);


PROCEDURE^ ExportSymbol(sym: Sym.Symbol);


PROCEDURE ExportStruct(typ: Sym.Struct);
  VAR
    mod, sym: Sym.Symbol;
 BEGIN
  IF typ.ref = 0 THEN
    StoreStrExport(typ);
    IF typ.form = Sym.Record THEN
      IF FindTypMod(typ, mod) THEN ExportSymbol( mod ) END;
      IF typ.base # NIL THEN ExportStruct(typ.base) END;
      ExportSymbols(typ.syms, ExportedSym);
    ELSIF typ.form IN {Sym.Array, Sym.OpenArr, Sym.DynArr, Sym.Pointer} THEN
      ExportStruct(typ.base);
    ELSIF typ.form = Sym.ProcTyp THEN
      ExportStruct(typ.base);
      ExportSymbols(typ.syms.next, AllSymUptoSep);
    END;
    mod := Sym.symbols;
    WHILE mod # NIL DO
      IF mod.form = Sym.Mod THEN
        sym := mod.syms;
        WHILE sym # NIL DO
          IF (sym.form = Sym.Typ) & (sym.typ = typ) THEN
            StoreSymExport(mod);
            RETURN;
          END;
          sym := sym.next
        END;
      END;
      mod := mod.next
    END;
  END;
 END ExportStruct;


PROCEDURE ExportSymbol(sym: Sym.Symbol);
  VAR
    mod: Sym.Symbol;
 BEGIN
  IF sym.ref = 0 THEN
    IF (sym.form = Sym.Tbp) & FindTbpMod(sym, mod) THEN
      ExportSymbol( mod )
    END;
    StoreSymExport(sym);
    CASE sym.form OF
      Sym.Var, Sym.Fld, Sym.Typ, Sym.Con, Sym.Ind, Sym.Cpy:
        ExportStruct(sym.typ);
    | Sym.LProc, Sym.CProc, Sym.IProc, Sym.Tbp:
        IF (sym.form # Sym.Tbp) OR (sym.mark # Sym.NoExport) THEN
          ExportStruct(sym.typ);
          ExportSymbols(sym.syms.next, AllSymUptoSep);
        END;
    ELSE
    END;
  END;
 END ExportSymbol;


PROCEDURE ExportSymbols(sym: Sym.Symbol; which: INTEGER);
(*
 Store all symbols which must be exported
 *)
 BEGIN
  WHILE sym # NIL DO
    IF (which = ExportedSym)
        & ((sym.form IN {Sym.Fld, Sym.Tbp}) OR (sym.lev >= 0)) THEN
      IF (sym.mark # Sym.NoExport) OR (sym.form = Sym.Tbp) THEN
        ExportSymbol(sym);
      END;
    ELSIF which = AllSymUptoSep THEN
      ExportSymbol(sym);
      IF sym.form = Sym.Sep THEN RETURN END;
    END;
    sym := sym.next;
  END;
 END ExportSymbols;


PROCEDURE EqualTypes(typ1, typ2: Sym.Struct) : BOOLEAN;
(*
 Prevents recursion in tbp comparison. Also increases speed.
 *)
  VAR
    i: INTEGER;
 BEGIN
  FOR i := 0 TO netx BY 2 DO
    IF (typ1 = equalTypes[i]) & (typ2 = equalTypes[i+1]) THEN
      RETURN TRUE
    END;
  END;
  IF etx > netx THEN netx := etx END;
  equalTypes[etx] := typ1;
  equalTypes[etx+1] := typ2; INC(etx, 2);
  IF etx = NumEqualTypes THEN etx := 0 END;
  RETURN FALSE
 END EqualTypes;


PROCEDURE^ CompareFields(sym, nsym: Sym.Symbol) : BOOLEAN;


PROCEDURE^ CompareParameters(sym, nsym: Sym.Symbol) : BOOLEAN;


PROCEDURE CompareStruct(typ1, typ2: Sym.Struct) : BOOLEAN;
(*
 Return true if not equal in the sense of an exported structure
 *)
 BEGIN
  IF typ1 = typ2 THEN RETURN FALSE END;	(* both NIL *)
  IF (typ1 = NIL) OR (typ2 = NIL) OR (typ1.form # typ2.form) THEN
    RETURN TRUE
  END;
  IF EqualTypes(typ1, typ2) THEN RETURN FALSE END;
  CASE typ1.form OF
    Sym.Pointer:
      RETURN CompareStruct(typ1.base, typ2.base)

  | Sym.DynArr, Sym.OpenArr:
      RETURN CompareStruct(typ1.base, typ2.base)
              OR (typ1.a0 MOD 400000H # typ2.a0 MOD 400000H)
  | Sym.Array:
      RETURN (typ1.n # typ2.n) OR CompareStruct(typ1.base, typ2.base)
              OR (typ1.a0 MOD 400000H # typ2.a0 MOD 400000H)
  | Sym.ProcTyp:
      RETURN CompareStruct(typ1.base, typ2.base)
              OR CompareParameters(typ1.syms.next, typ2.syms.next)
  | Sym.Record:
      RETURN (typ1.n # typ2.n)
              OR (typ1.a0 MOD 400000H # typ2.a0 MOD 400000H)
              OR CompareStruct(typ1.base, typ2.base)
              OR CompareFields(typ1.syms.next, typ2.syms.next)
  ELSE
  END;
  RETURN FALSE
 END CompareStruct;


PROCEDURE CompareSymbol(sym, nsym: Sym.Symbol) : BOOLEAN;
(*
 Return true if not equal in the sense of an exported symbol
 *)
  VAR
    x, y: Expr.Expr;
    sp1, sp2: Strings.ptr;
 BEGIN
  IF sym.form # nsym.form THEN RETURN TRUE END;
  CASE sym.form OF
    Sym.Var, Sym.Fld, Sym.Ind, Sym.Cpy:
      IF CompareStruct(sym.typ, nsym.typ)
          OR (sym.a0 MOD 400000H # nsym.a0 MOD 400000H)
          OR (sym.mark # nsym.mark) THEN
        RETURN TRUE
      END;
  | Sym.Typ:
      IF CompareStruct(sym.typ, nsym.typ) THEN
        RETURN TRUE
      END;
  | Sym.LProc, Sym.IProc, Sym.CProc, Sym.Tbp:
      IF (sym.a1 MOD 400000H # nsym.a1 MOD 400000H)
          OR (sym.form = Sym.Tbp) & (sym.mark # nsym.mark) THEN
        RETURN TRUE
      END;
      IF ((sym.form # Sym.Tbp) OR (sym.mark # Sym.NoExport))
          & (CompareStruct(sym.typ, nsym.typ)
            OR CompareParameters(sym.syms.next, nsym.syms.next)) THEN
        RETURN TRUE
      END;
      IF sym.form = Sym.CProc THEN
        IF sym.a0 # nsym.a0 THEN RETURN TRUE END;
      ELSIF sym.form = Sym.Tbp THEN
        IF (sym.lev # nsym.lev) THEN RETURN TRUE END;
      END;
  | Sym.Mod:
      IF sym.a1 # nsym.a1 THEN RETURN TRUE END;
  | Sym.Con:
      IF sym.typ.form # nsym.typ.form THEN RETURN TRUE END;
      x := Expr.EvaluateExpr( S.VAL( Expr.Expr, sym.a1) );
      y := Expr.EvaluateExpr( S.VAL( Expr.Expr, nsym.a1) );
      IF sym.typ.form = Sym.String THEN
        sp1 := S.VAL( Strings.ptr, x.a1);
        sp2 := S.VAL( Strings.ptr, y.a1);
        IF sp1^ # sp2^ THEN RETURN TRUE END;
      ELSE
        IF x.a0 # y.a0 THEN RETURN TRUE END;
        IF sym.typ.form = Sym.LReal THEN
          IF x.a1 # y.a1 THEN RETURN TRUE END;
        END;
      END;

  ELSE
  END;
  RETURN FALSE
 END CompareSymbol;


PROCEDURE CompareParameters(sym, nsym: Sym.Symbol) : BOOLEAN;
(*
 Return true if not equal in the sense of an exported parameter list.
 *)
 BEGIN
  WHILE (sym # NIL) & (nsym # NIL)
      & (sym.form # Sym.Sep) & (nsym.form # Sym.Sep) DO
    IF CompareSymbol(sym, nsym) THEN RETURN TRUE END;(* name need not match *)
    sym := sym.next; nsym := nsym.next;
  END;
  RETURN (sym # NIL) & (nsym # NIL) & (nsym.form # sym.form)
         OR (sym = NIL) & (nsym # NIL)
         OR (nsym = NIL) & (sym # NIL);
 END CompareParameters;


PROCEDURE CompareFields(osym, nsym: Sym.Symbol) : BOOLEAN;
(*
 Return true if not equal in the sense of an exported record field list.
 *)
  VAR
    newTbpno, oldTbpno: INTEGER;
    sym: Sym.Symbol;

  PROCEDURE CountTbp(sym: Sym.Symbol; VAR no: INTEGER);
   BEGIN
    IF (sym.form = Sym.Tbp) & (SHORT( sym.a1) > no) THEN
      no := SHORT( sym.a1);
    END;
   END CountTbp;

 BEGIN
  oldTbpno := 0; sym := osym;
  WHILE (sym # NIL) DO
    CountTbp(sym, oldTbpno); sym := sym.next;
  END;
  newTbpno := 0; sym := nsym;
  WHILE (sym # NIL) DO
    CountTbp(sym, newTbpno); sym := sym.next;
  END;
  IF newTbpno # oldTbpno THEN RETURN TRUE END;
  WHILE (osym # NIL) DO
    IF osym.name # "" THEN
      sym := nsym;
      WHILE (sym # NIL) & (sym.name # osym.name) DO
        sym := sym.next
      END;
      IF (sym = NIL) OR CompareSymbol(osym, sym) THEN
        RETURN TRUE
      END;
    END;
    osym := osym.next;
  END;
  RETURN FALSE
 END CompareFields;


PROCEDURE SymbolFileChanges() : BOOLEAN;
  VAR
    sym, nsym: Sym.Symbol;
 BEGIN
  IF Sym.self = NIL THEN RETURN TRUE END;
  sym := Sym.self.syms.next;
  WHILE sym # NIL DO
    COPY(sym.name, Scan.name);
    nsym := NIL;
    IF Sym.SearchInList(Sym.global, nsym)
        & (nsym.form = Sym.Mod) & (sym.form # Sym.Mod) THEN
      IF ~Sym.SearchInList(nsym, nsym) THEN nsym := NIL END;
    END;
    IF (nsym = NIL) OR (sym.form # nsym.form) OR CompareSymbol(sym, nsym) THEN
      RETURN TRUE
    END;
    sym := sym.next;
  END;
  RETURN FALSE
 END SymbolFileChanges;


PROCEDURE SetRealModNames;
  VAR
    sym: Sym.Symbol;
    sp : Strings.ptr;
 BEGIN
  sym := Sym.global;
  WHILE sym # NIL DO
    IF sym.form = Sym.Mod THEN
      sp := S.VAL( Strings.ptr, sym.a0);
      COPY( sp^, sym.name)
    END;
    sym := sym.next;
  END;
 END SetRealModNames;


PROCEDURE Export*(VAR name, modname: ARRAY OF CHAR; VAR key: LONGINT);
  VAR
    filename: FN.path;
    newSF : BOOLEAN;
 BEGIN
  IF ~Err.scanerr THEN
    SetRealModNames;
    newSF := SymbolFileChanges();
    IF ~newSF THEN key := Sym.self.a1 END;	(* old key *)
    ExportSymbols(Sym.symbols.next, ExportedSym);
    COPY(name, filename); FN.SetExt( "SYM", filename);
    IF Par.SymPaths # Par.ModPaths THEN
      FN.SetPath( Par.SymPaths.Path, filename)
    END;
    symfile := Files.New(filename);
    IF symfile = NIL THEN
      IO.WriteString( "Could not create symbol file"); IO.WriteLn;
    ELSE
      symr.Set( symfile, 0);
      symr.WriteLInt( CurrSfTag);
      symr.WriteLInt( key); symr.WriteId( modname);
      WriteObjects;
      symfile.Register;
      symfile.SetTimeAndDate(key);
      symfile.Close;
      IF newSF THEN
        IO.WriteString( "New symbol file: ");
        IO.WriteString( filename);
        IO.WriteLn;
      END;
    END;
  END;
 END Export;



PROCEDURE Init*;
 BEGIN
  modno := -1;
  netx := -2;
 END Init;


PROCEDURE Exit*;
  VAR
    i: INTEGER;
 BEGIN
  symfile := NIL;
  FOR i := 0 TO NumSymbols-1 DO
    symbols[i] := NIL;
  END;
  FOR i := 0 TO NumStructs-1 DO
    structs[i] := NIL;
  END;
  FOR i := 0 TO NumGlbMod-1 DO
    glbmod[i] := NIL;
  END;
  nofgmod := 0;
  FOR i := 0 TO NumEqualTypes-1 DO
    equalTypes[i] := NIL;
  END;
  etx := 0;
  symr.Set(NIL, 0);
  fsym := NIL;
 END Exit;


END OCImport.