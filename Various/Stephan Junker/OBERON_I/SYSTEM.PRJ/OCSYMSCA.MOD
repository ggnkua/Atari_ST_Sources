MODULE OCSymScan; (* SJ 16.9.94 / 27.11.94 *)


IMPORT
  S:=SYSTEM, Stat:=OCStat, Expr:=OCExpr, Scan:=OCScan, Sym:=OCSymbol,
  Com:=OCCom, Import:=OCImport, Err:=OCErr, Par:=OCPar, OCH:=OCH2,
  Coder:=OCCoder, Strings;



CONST
  (* symbol forms *)
  Def=Sym.Def; Var=Sym.Var; Fld=Sym.Fld; Typ=Sym.Typ; LProc=Sym.LProc;
  SProc=Sym.SProc; CProc=Sym.CProc; IProc=Sym.IProc; Mod=Sym.Mod;
  Con=Sym.Con; Tbp=Sym.Tbp; Ind=Sym.Ind; Cpy=Sym.Cpy; Head=Sym.Head;
  Sep=Sym.Sep; Label=Sym.Label;

  (*structure forms*)
  Undef=Sym.Undef; Byte=Sym.Byte; Bool=Sym.Bool; Char=Sym.Char;
  SInt=Sym.SInt; Int=Sym.Int; LInt=Sym.LInt; Real=Sym.Real;
  LReal=Sym.LReal; Set=Sym.Set; String=Sym.String; NilTyp=Sym.NilTyp;
  NoTyp=Sym.NoTyp; AnyPtr=Sym.AnyPtr; Pointer=Sym.Pointer;
  ProcTyp=Sym.ProcTyp; Array=Sym.Array; DynArr=Sym.DynArr;
  OpenArr=Sym.OpenArr; Record=Sym.Record; TbpStr=Sym.TbpStr;
  ProcStr=Sym.ProcStr;

  (*symbol values*)
  nosym=Scan.nosym; times=Scan.times; slash=Scan.slash; div=Scan.div;
  mod=Scan.mod; andb=Scan.andb; and=Scan.and; plus=Scan.plus;
  minus=Scan.minus; ior=Scan.ior; xor=Scan.xor; shl=Scan.shl; shr=Scan.shr;
  or=Scan.or; eql=Scan.eql; neq=Scan.neq; lss=Scan.lss; leq=Scan.leq;
  gtr=Scan.gtr; geq=Scan.geq; in=Scan.in; is=Scan.is; arrow=Scan.arrow;
  period=Scan.period; comma=Scan.comma; colon=Scan.colon; upto=Scan.upto;
  rparen=Scan.rparen; rbrak=Scan.rbrak; rbrace=Scan.rbrace; of=Scan.of;
  then=Scan.then; do=Scan.do; to=Scan.to; lparen=Scan.lparen;
  lbrak=Scan.lbrak; lbrace=Scan.lbrace; not=Scan.not; becomes=Scan.becomes;
  number=Scan.number; nil=Scan.nil; string=Scan.string; ident=Scan.ident;
  semicolon=Scan.semicolon; bar=Scan.bar; end=Scan.end; else=Scan.else;
  elsif=Scan.elsif; until=Scan.until; if=Scan.if; case=Scan.case;
  while=Scan.while; repeat=Scan.repeat; loop=Scan.loop; with=Scan.with;
  exit=Scan.exit; return=Scan.return; array=Scan.array; record=Scan.record;
  pointer=Scan.pointer; begin=Scan.begin; const=Scan.const; type=Scan.type;
  var=Scan.var; procedure=Scan.procedure; import=Scan.import;
  module=Scan.module; eof=Scan.eof; assembler=Scan.assembler; for=Scan.for;
  by=Scan.by; notb=Scan.notb;

  (* error codes *)
  idmatch = 108; globexp = 110; statexp = 111; illfac = 112;
  nocalc = 114; incomp = 115; intonly = 116; boolonly = 117;
  incomop = 118; ext2only = 119; setonly = 120; assign = 121;
  constexp = 122; arrexp = 125; unknown = 127; nodyn = 128;
  ptrbase = 129; procfunc = 130; rettype = 131; lesspar = 132;
  morepar = 133; funcproc = 135; noreg = 113; noadr = 136;
  btypexp = 137; doublesym = 124; typknown = 138; bindexp = 139;
  onebind = 140; binderr = 141; indbind = 142; noinc = 143;
  noreturn = 166; noret = -2; funcexp = 168; nobase = 187;
  casesize = 123; assread = 165; ptrrecexp = 194; notd = 201;
  inherr = 202; nomoreret = 205; assproclev = 207;
  forwmark = 208;

  IntTypes = {SInt, Int, LInt};
  RealTypes = {Real, LReal};
  SimpleTypes = {SInt, Int, LInt, Char, Bool, Byte,
           Set, Real, LReal, AnyPtr, Pointer, ProcTyp};



VAR
  sym* : INTEGER;	    	(* current symbol *)
  modid* : ARRAY 24 OF CHAR;	(* module name *)
  lastSymbol* : Sym.Symbol;
  StandProcCall*: PROCEDURE (sym: Sym.Symbol; VAR expr: Expr.Expr);
  trueLab*, falseLab*: Stat.Stat;(* if # NIL the labels to branch to *)
  vsize : LONGINT;		(* variable size *)



PROCEDURE CheckSym*(s : INTEGER);
 BEGIN
  IF sym = s THEN Scan.Get(sym) ELSE Err.Mark(s) END
 END CheckSym;


PROCEDURE CheckMark(VAR mk : INTEGER);
 BEGIN
  Scan.Get(sym);
  IF (sym = times) OR (sym = minus) THEN
    IF Sym.level <= 1 THEN
      IF sym = times THEN mk := Sym.Export ELSE mk := Sym.ReadOnly END;
    ELSE
      mk := Sym.NoExport;
      Err.Mark(globexp)
    END;
    Scan.Get(sym)
  ELSE
    mk := Sym.NoExport
  END
 END CheckMark;


PROCEDURE qualidentobj*(VAR obj : Sym.Symbol);
  (* sym = ident *)
  VAR
    lab: Stat.Stat;
 BEGIN
  IF Scan.inAss & ~Sym.Search(obj) THEN		(* undefined label *)
    Sym.NewSym( Label, obj); obj.typ := Sym.linttyp;
    Com.NewLabel(lab);
    obj.a1 := S.VAL(LONGINT, lab.expr);
    Scan.Get(sym);
    obj.forw := TRUE; Sym.Insert(obj);
  ELSE
    Sym.Find(obj); Scan.Get(sym);
    IF (obj.form = Mod) THEN
      IF (sym = period) THEN
        Scan.Get(sym);
        IF sym = ident THEN
          Sym.FindInList( Import.SymList(obj), obj); Scan.Get(sym);
        ELSE
          Err.Mark(ident); Sym.NewSym(Def, obj);
        END
      ELSE
        COPY(obj.name, Scan.name);
        IF Sym.SearchInList( Import.SymList(obj), obj) THEN
          IF ~Par.ext THEN Err.Mark(ext2only) END;
          (* same name as module *)
        END;
      END;
    END;
    lastSymbol := obj;
  END;
 END qualidentobj;


PROCEDURE qualident*(VAR x : Expr.Expr);
  (* sym = ident *)
  VAR
    obj : Sym.Symbol;
 BEGIN
  qualidentobj(obj);
  Expr.New(Expr.Sym, x, OCH.SymTyp(obj)); x.sym := obj;
  IF Scan.inAss THEN
    IF (obj.lev <= 0) OR (obj.typ.form = Sym.String) THEN
      x.typ := Sym.linttyp
    ELSE x.typ := OCH.GetIntType(obj.a0)
    END;
  ELSIF (obj.form IN {Sym.Ind, Sym.Cpy}) THEN
    x := Com.Deref(x, x.typ.base);
  END;
 END qualident;


PROCEDURE^ Expression*(VAR x: Expr.Expr);

PROCEDURE^ ActualParameters*(x : Expr.Expr);


PROCEDURE FindFld(typ: Sym.Struct; VAR fld: Sym.Symbol);
  VAR
    xtyp: Sym.Struct;
 BEGIN
  xtyp := typ;
  WHILE (xtyp # NIL) & ~Sym.SearchInList(xtyp.syms, fld) DO
    xtyp := xtyp.base;
  END;
  IF xtyp = NIL THEN
    Err.Mark(unknown);
    Sym.NewSym(Def, fld); fld.forw := TRUE;
    Sym.InsertIn(typ.syms, fld);
    fld.typ := Sym.undftyp;
  END;
 END FindFld;


PROCEDURE selector*(VAR x : Expr.Expr);
  VAR
    y,z : Expr.Expr;
    fld, par, lastSym : Sym.Symbol;
    n, psym, inherits  : INTEGER;
    typ, xtyp, partyp : Sym.Struct;
    Scanname: ARRAY 256 OF CHAR;
 BEGIN
  IF (x.form = Expr.Sym) & (x.sym.form = Sym.Typ) THEN
    Err.Mark(var)
  END;
  LOOP
    IF sym = lbrak THEN
      Scan.Get(sym);
      LOOP
        IF x.typ.form = Pointer THEN
          lastSymbol := NIL; OCH.Deref(x)
        END;
        lastSym := lastSymbol;
        Expression(y);
        lastSymbol := lastSym;
        OCH.Index(y, x);
        IF sym = comma THEN Scan.Get(sym) ELSE EXIT END
      END ;
      CheckSym(rbrak)
    ELSIF sym = period THEN
      Scan.Get(sym);
      IF sym = ident THEN
        IF (x.typ.form = Record)
            OR (x.typ.form = Pointer) &  (x.typ.base.form = Record) THEN
          typ := x.typ;
          IF typ.form = Pointer THEN typ := typ.base END;
          FindFld(typ, fld);
          lastSymbol := fld;
          IF fld.form # Tbp THEN
            IF x.typ.form = Pointer THEN
              lastSymbol := NIL; OCH.Deref(x)
            END;
            OCH.Field(fld, x); Scan.Get(sym);
          ELSE
            par := fld.syms.next; partyp := par.typ;
            IF par.form = Sym.Ind THEN partyp := partyp.base END;
            IF (partyp.form = Pointer) & (x.typ.form = Record) THEN
              Err.Mark(incomp)
            ELSIF (partyp.form = Record) & (x.typ.form = Pointer) THEN
              (*OCH.Deref(x) ActualParameters knows it *)
            END;
            inherits := 0;
            Scan.Get(sym);
            WHILE sym = arrow DO
              IF typ # NIL THEN typ := typ.base END;
              INC(inherits); Scan.Get(sym)
            END;
            IF inherits > 0 THEN
              IF typ = NIL THEN Err.Mark(inherr)
              ELSE
                COPY(Scan.name, Scanname);
                COPY(fld.name, Scan.name);
                FindFld(typ, fld);
                COPY(Scanname, Scan.name);
              END;
            END;
            Expr.New(Expr.Tbp, z, Sym.tbpstr);
            z.sym := fld; z.op1 := x;
            psym := sym;
            ActualParameters( z);
            y := Com.Deref( OCH.TD(x), Sym.ptrtyp );
            IF (inherits > 0) & (typ # NIL) THEN
              y := Com.Deref( Com.Disp( y,
                Com.Const( Sym.TDBaseTyps+typ.n*Sym.PtrSize, Sym.inttyp),
                Sym.ptrtyp), Sym.ptrtyp );
            END;
            Com.Call( Com.Deref( Com.Disp(y,
                 Com.Const( Sym.TDTBPs + fld.a1*Sym.PtrSize, Sym.inttyp),
                 Sym.ptrtyp), Sym.ptrtyp) );
            Com.RestoreStack(z);
            z := Com.Ret(z);
            IF z.typ.form # Sym.NoTyp THEN Com.Temporize(Sym.symbols, z) END;
            IF psym = lparen THEN CheckSym(rparen) END;
            IF (sym # period) OR (z.typ.form # Sym.NoTyp) THEN
              x := z;
              IF ~Par.ext THEN EXIT END;
            ELSIF ~Par.ext THEN
              Err.Mark(ext2only)
            END;
          END;
        ELSE
          Err.Mark(record); Scan.Get(sym)
        END;
      ELSE Err.Mark(ident)
      END
    ELSIF sym = arrow THEN
      Scan.Get(sym);
      lastSymbol := NIL;
      OCH.Deref(x);
    ELSIF (sym = lparen) & ~Scan.inAss THEN
      IF x.typ.form IN {Pointer, Record} THEN	(* type guard *)
        Scan.Get(sym);
        IF sym = ident THEN
          qualidentobj(fld);
          IF fld.form = Typ THEN
            OCH.TypeGuard(x, fld.typ);
          ELSE
            Err.Mark(type)
          END;
        ELSE Err.Mark(ident)
        END;
      ELSIF x.typ.form IN {ProcTyp, ProcStr, TbpStr} THEN
        (* proc call *)
        IF (x.form = Expr.Sym) & (x.sym.form = Sym.SProc) THEN
          StandProcCall(x.sym, x);
        ELSE
          ActualParameters( x); y := x;
          IF x.typ.form = Sym.ProcTyp THEN x := Com.Deref(x, Sym.procstr) END;
          Com.Call(x);
          Com.RestoreStack(x);
          x := Com.Ret(y);
          IF x.typ.form # Sym.NoTyp THEN Com.Temporize(Sym.symbols, x) END;
        END;
        IF ~Par.ext THEN CheckSym(rparen); EXIT END;
      ELSE
        Err.Mark(procedure); Scan.Get(sym);
        x := NIL; EXIT
      END(*IF*);
      CheckSym(rparen);
    ELSE EXIT
    END;
    IF x = NIL THEN EXIT END;
  END;
 END selector;


PROCEDURE ConstExpression*(VAR x : Expr.Expr);
 BEGIN
  Expression(x);
  IF ~Expr.IsConst(x) THEN
    Err.Mark(const);
    x.form := Def;
  END;
 END ConstExpression;


PROCEDURE IntConstExpression*(VAR val : LONGINT);
  VAR
    x : Expr.Expr;
    f : INTEGER;
 BEGIN
  ConstExpression(x);
  IF NOT (x.typ.form IN IntTypes+{Def}) THEN
    Err.Mark(intonly);
    val := 1;
  ELSE
    val := Expr.Evaluate(x)
  END;
 END IntConstExpression;


PROCEDURE CaseConstExpression*(form : INTEGER; VAR val : LONGINT);
  VAR
    x : Expr.Expr;
    f, len : INTEGER;
    ptr : Strings.ptr;
    off : LONGINT;
 BEGIN
  ConstExpression(x);
  f := x.typ.form;
  IF f = String THEN
    OCH.StringToChar(x);
    f := Char;
  END(*IF*);
  IF (f # form) AND ((f IN {Real,LReal,Char,Bool,String}) OR
      (form IN {Char,Bool}) OR (f > form))  THEN
    Err.Mark(incomop);
    val := 1;
  ELSE
    val := Expr.Evaluate(x)
  END;
 END CaseConstExpression;


PROCEDURE^ Type(VAR typ : Sym.Struct; pointing : BOOLEAN);


PROCEDURE ArrayType(VAR typ: Sym.Struct; pointing : BOOLEAN);
  VAR
    arrtyp: Sym.Struct;
    size  : LONGINT;
 BEGIN
  IF (sym # of) THEN
    Sym.NewStr(Array, arrtyp);
    IntConstExpression(arrtyp.n);
  ELSE
    IF NOT pointing THEN Err.Mark(nodyn) END;
    Sym.NewStr(OpenArr, arrtyp);
    arrtyp.n := 0;
  END;
  arrtyp.base := Sym.undftyp;
  IF sym = of THEN
    Scan.Get(sym); Type(arrtyp.base, pointing)
  ELSIF sym = comma THEN
    Scan.Get(sym); ArrayType(arrtyp.base, FALSE)
  ELSE Err.Mark(of)
  END ;
  size := arrtyp.base.size;
  arrtyp.size := arrtyp.n * size;
  typ := arrtyp;
  Coder.StoreTDStruct(arrtyp);
 END ArrayType;


PROCEDURE RecordType(VAR typ: Sym.Struct);
  VAR
    adr, size: LONGINT;
    fld, fld0, fld1: Sym.Symbol;
    ftyp, btyp: Sym.Struct;
    base: Sym.Symbol;
    even: BOOLEAN;
 BEGIN
  adr := 0; Sym.NewStr(Record, typ);
  typ.base := NIL; typ.n := 0;

  IF sym = lparen THEN				(*record extension*)
    Scan.Get(sym);
    IF sym = ident THEN
      qualidentobj(base);
      IF (base.form = Typ) THEN
        IF (base.typ.form = Record) THEN
          typ.base := base.typ; typ.n := base.typ.n + 1;
          adr := base.typ.size
        ELSIF base.typ.form # Undef THEN
          Err.Mark(btypexp);
        END(*IF*);
      ELSE Err.Mark(btypexp)
      END
    ELSIF base.form # Def THEN
      Err.Mark(ident)
    END ;
    CheckSym(rparen)
  END ;

  Sym.NewList;					(* get fields *)
  LOOP
    IF sym = ident THEN
      LOOP
        IF sym = ident THEN
          IF (typ.base # NIL) & Sym.SearchInList(typ.base.syms, fld0) THEN
            Err.Mark(doublesym)
          END ;
          Sym.NewSym(Fld, fld); fld.typ := NIL;
          Sym.Insert(fld); CheckMark(fld.mark);
        ELSE Err.Mark(ident)
        END ;
        IF sym = comma THEN Scan.Get(sym)
        ELSIF sym = ident THEN Err.Mark(comma)
        ELSE EXIT
        END
      END ;
      CheckSym(colon); Type(ftyp, FALSE); size := ftyp.size;
      fld1 := Sym.symbols.next;
      btyp := ftyp;
      WHILE btyp.form = Array DO btyp := btyp.base END;
      even := ~ (btyp.form IN {Char, SInt, Byte, Bool});
      WHILE fld1 # NIL DO
        IF fld1.typ = NIL THEN
          IF even THEN INC(adr, adr MOD 2 ) END ;
          fld1.typ := ftyp; fld1.a0 := adr; INC(adr, size);
        END;
        fld1 := fld1.next;
      END
    END ;
    IF sym = semicolon THEN Scan.Get(sym)
    ELSIF sym = ident THEN Err.Mark(semicolon)
    ELSE EXIT
    END
  END ;
  typ.size := S.ANL(adr,1) + adr;
  typ.syms := Sym.symbols;
  OCH.CheckUndefPointer;
  Sym.OldList;
  Coder.StoreTDStruct(typ);
 END RecordType;


PROCEDURE^ ProcType(VAR typ: Sym.Struct);


PROCEDURE FormalType(var : BOOLEAN; VAR typ: Sym.Struct; VAR dynArr : BOOLEAN);
  VAR
    x: Sym.Symbol;
    typ0: Sym.Struct;
    a, s: LONGINT;
 BEGIN
  typ := Sym.undftyp; a := 0;
  WHILE sym = array DO
    Scan.Get(sym); CheckSym(of); INC(a)
  END ;
  dynArr := NOT var AND (a # 0);
  IF sym = ident THEN
    qualidentobj(x);
    IF x.form = Typ THEN
      typ := x.typ;
      IF typ.form = NoTyp THEN Err.Mark(type) END
    ELSIF x.form # Def THEN
      Err.Mark(type)
    END
  ELSIF sym = procedure THEN
    Scan.Get(sym); ProcType(typ)
  ELSE
    Err.Mark(ident)
  END ;
  s := 0;
  WHILE a > 0 DO
    Sym.NewStr(DynArr, typ0); typ0.base := typ;
    INC(s, Sym.ArrLenSize);
    typ := typ0; DEC(a)
  END;
  IF var OR (typ.form = DynArr) THEN
    Sym.NewStr(Pointer, typ0); typ0.size := Sym.PtrSize;
    IF typ.form = DynArr THEN INC(typ0.size, s)
    ELSIF typ.form = Record THEN INC(typ0.size, Sym.PtrSize)
    END;
    typ0.base := typ;
    typ := typ0
  END;
 END FormalType;


PROCEDURE FormalParameters(VAR resTyp: Sym.Struct; VAR psize: LONGINT);
  VAR
    res : Sym.Symbol;
    par : Sym.Symbol;
    typ : Sym.Struct;
    adr, size : LONGINT;
    mode : INTEGER;
    dynArr : BOOLEAN;
 BEGIN
  psize := 0;
  IF sym = lparen THEN
    adr := 0;
    Scan.Get(sym);
    IF (sym = ident) OR (sym = var) THEN
      LOOP
        IF sym = var THEN
          mode := Ind; Scan.Get(sym)
        ELSE
          mode := Var;
        END;
        LOOP
          IF sym = ident THEN
            Sym.NewSym(mode, par); par.typ := NIL; par.a1 := Sym.NoReg;
            Sym.Insert(par); Scan.Get(sym);
          ELSE
            Err.Mark(ident)
          END ;
          IF sym = comma THEN Scan.Get(sym)
          ELSIF sym = ident THEN Err.Mark(comma)
          ELSIF sym = var THEN Err.Mark(comma); Scan.Get(sym)
          ELSE EXIT
          END
        END ;
        CheckSym(colon); FormalType(mode = Ind, typ, dynArr);
        size := S.ANL(typ.size,1) + typ.size;	(* stack always even *)
        par := Sym.symbols.next;
        WHILE par # NIL DO
          IF par.typ = NIL THEN
            par.typ := typ; DEC(adr, size); par.a0 := adr;
            IF dynArr & (mode = Var) THEN par.form := Cpy END;
          END;
          par := par.next;
        END ;
        IF sym = semicolon THEN Scan.Get(sym)
        ELSIF sym = ident THEN Err.Mark(semicolon)
        ELSE EXIT
        END
      END;
      psize := -adr; par := Sym.symbols.next;
      WHILE par # NIL DO
        INC(par.a0, 8-adr); par := par.next;
      END ;
    END ;
    CheckSym(rparen);
    IF sym = colon THEN
      Scan.Get(sym); resTyp := Sym.undftyp;
      IF sym = ident THEN
        qualidentobj(res);
        IF res.form = Typ THEN
          IF res.typ.form IN {NoTyp, DynArr, OpenArr} THEN
            Err.Mark(rettype)
          ELSE
            resTyp := res.typ;
            IF (resTyp.form IN {Array, Record}) AND NOT Par.ext THEN
              Err.Mark(ext2only)
            END;
          END
        ELSE Err.Mark(type)
        END
      ELSE Err.Mark(ident)
      END
    ELSE resTyp := Sym.notyp
    END
  END;
 END FormalParameters;


PROCEDURE ProcType(VAR typ: Sym.Struct);
  VAR
    psize: LONGINT;
    ptyp : Sym.Struct;
 BEGIN
  Sym.NewStr(ProcTyp, typ); typ.size := Sym.PtrSize;
  IF sym = lparen THEN
    ptyp := typ; Sym.NewList;
    ptyp.syms := Sym.symbols;
    FormalParameters(typ.base, psize);
    typ.n := psize;
    Sym.OldList;
  ELSE
    typ.base := Sym.notyp; typ.n := 0;
    Sym.NewSym(Head, typ.syms); typ.syms.next := NIL;
  END
 END ProcType;


PROCEDURE Type(VAR typ : Sym.Struct; pointing : BOOLEAN);
  VAR
    obj : Sym.Symbol;
    base: Sym.Struct;
 BEGIN
  typ := Sym.undftyp;
  IF sym = ident THEN
    qualidentobj(obj);
    IF (obj # NIL) AND (obj.form = Typ) THEN
      typ := obj.typ;
      IF typ.form = NoTyp THEN
        Err.Mark(type)
      END
    ELSE
      Err.Mark(type)
    END
  ELSIF sym = array THEN
    Scan.Get(sym); ArrayType(typ, pointing)
  ELSIF sym = pointer THEN
    Scan.Get(sym); Sym.NewStr(Pointer, typ);
    typ.size := Sym.PtrSize;
    CheckSym(to); obj := NIL;
    IF (sym # ident) OR Sym.Search(obj) THEN
      Type(base, TRUE); OCH.SetPtrBase(typ, base);
    ELSE			     		(* forward ref *)
      Sym.NewSym(Typ, obj);
      typ.base := Sym.undftyp; obj.forw := TRUE;
      obj.typ := typ; Sym.Insert(obj);
      Scan.Get(sym);
    END;
  ELSIF sym = record THEN
    Scan.Get(sym); RecordType(typ);
    CheckSym(end)
  ELSIF sym = procedure THEN
    Scan.Get(sym); ProcType(typ)
  ELSE Err.Mark(type)
  END;
  IF (sym < semicolon) OR (else < sym) THEN
    Err.Mark(semicolon);
    WHILE (sym < ident) OR (else < sym) & (sym < begin) DO
      Scan.Get(sym)
    END
  END
 END Type;


PROCEDURE ConstantDeclaration;
  VAR
    con : Sym.Symbol;
    x   : Expr.Expr;
 BEGIN
  Scan.Get(sym);
  WHILE sym = ident DO
    Sym.NewSym(Con, con);
    Sym.Insert(con);
    CheckMark(con.mark);
    IF sym = eql THEN
      Scan.Get(sym); ConstExpression(x);
      Expr.MarkUsed(x);
    ELSIF sym = becomes THEN
      Err.Mark(eql); Scan.Get(sym); ConstExpression(x);
      Expr.MarkUsed(x);
    ELSE Err.Mark(eql)
    END ;
    con.a1 := S.VAL( LONGINT, x);
    con.typ := x.typ;
    CheckSym(semicolon)
  END;
 END ConstantDeclaration;


PROCEDURE TypeDeclaration;
  VAR
    typ : Sym.Struct;
    typobj, fobj : Sym.Symbol;
 BEGIN
  Scan.Get(sym);
  WHILE sym = ident DO
    typ := Sym.undftyp;
    Sym.NewSym(Typ, typobj);
    fobj := typobj; Sym.Insert(typobj);
    typ := Sym.notyp; CheckMark(typobj.mark);
    IF sym = eql THEN
      Scan.Get(sym); Type(typ, FALSE);
      IF typ.form = Sym.Record THEN
        Coder.StoreTDStruct(typ);
      END;
      S.NEW(typ.name,
          Strings.Length(typobj.name) + Strings.Length(modid) + 2);
      COPY(modid, typ.name^);
      Strings.AppendC(".", typ.name^);
      Strings.Append(typobj.name, typ.name^);
    ELSIF (sym = becomes) OR (sym = colon) THEN
      Err.Mark(eql); Scan.Get(sym); Type(typ, FALSE)
    ELSE Err.Mark(eql)
    END ;
    IF fobj # typobj THEN	(* forward fixup *)
      OCH.SetPtrBase(typobj.typ, typ);
    END;
    typobj.typ := typ;
    CheckSym(semicolon)
  END
 END TypeDeclaration;


PROCEDURE VariableDeclaration(VAR dsize : LONGINT);
  VAR
    obj : Sym.Symbol;
    typ, btyp : Sym.Struct;
    size, adr : LONGINT;
    even: BOOLEAN;
 BEGIN
  Scan.Get(sym);
  WHILE sym = ident DO
    LOOP
      Sym.NewSym(Var, obj); obj.typ := NIL; obj.a1 := Sym.NoReg;
      CheckMark(obj.mark); Sym.Insert(obj);
      IF sym = comma THEN Scan.Get(sym)
      ELSIF sym = ident THEN Err.Mark(comma)
      ELSE EXIT
      END;
      IF sym # ident THEN
        Err.Mark(ident); EXIT
      END;
    END;
    CheckSym(colon); Type(typ, FALSE);
    size := typ.size;
    adr := dsize;
    obj := Sym.symbols.next;		(* go through linear list *)
    btyp := typ;
    WHILE btyp.form = Array DO btyp := btyp.base END;
    even := ~ (btyp.form IN {Char, SInt, Byte, Bool});
    WHILE obj # NIL DO
      IF (obj.form = Var) AND (obj.typ = NIL) THEN
        IF even THEN
          INC(adr, adr MOD 2 )		(* evenize *)
        END ;
        obj.typ := typ;
        IF Sym.level = 0 THEN
          obj.a0 := adr;
          INC(adr, size);
        ELSE
          INC(adr, size);
          obj.a0 := - adr;
        END(*IF*);
      END(*IF*);
      obj := obj.next
    END;
    dsize := adr;
    CheckSym(semicolon)
  END;
  INC(dsize, dsize MOD 2);		(* evenize *)
  IF (dsize >= 8000H) & (Sym.level # 0) THEN
    Err.Mark(209);
  END;
 END VariableDeclaration;


PROCEDURE^ Block(VAR dsize : LONGINT; symbol: Sym.Symbol);


PROCEDURE ProcedureDeclaration;
  VAR
    body, forw : BOOLEAN;
    proc, proc2, sep : Sym.Symbol;
    typ  : Sym.Struct;
    obj  : Sym.Symbol;
    fpsize, psize, dsize, val, lab: LONGINT;
    procStat: Stat.Stat;
    form: INTEGER;
 BEGIN
  psize := 0; body := TRUE; forw := FALSE; obj := NIL;
  form := LProc;
  IF (sym # ident) & (sym # lparen) THEN
    IF sym = times THEN
      (* ignored *)
    ELSIF sym = arrow THEN (*forward*)
      body := FALSE; forw := TRUE;
    ELSIF sym = minus THEN
      form := CProc; body := FALSE
    ELSIF sym = plus THEN
      form := IProc;
    ELSIF sym = not THEN
      form := Sym.AProc;
      IF ~Par.ext THEN Err.Mark(ext2only) END;
      IF Sym.level # 1 THEN Err.Mark(assproclev) END;
    ELSE
      Err.Mark(ident)
    END ;
    Scan.Get(sym)
  END ;
  IF sym = lparen THEN form := Tbp END;
  IF form # Tbp THEN
    IF sym # ident THEN Err.Mark(ident) END;
    Sym.NewSym(form, proc); proc2 := proc;
    Sym.Insert(proc2)
  END;
  Sym.NewList;

  IF form = Tbp THEN			(* type bound procedure *)
    FormalParameters(typ, fpsize);
    obj := Sym.symbols.next;
    IF obj = NIL THEN			(* no parameter *)
      Err.Mark(bindexp);
    ELSIF obj.next # NIL THEN		(* more than one parameter *)
      Err.Mark(onebind);
    ELSIF obj.typ.form = Record THEN
      Err.Mark(indbind)
    ELSIF (obj.typ.form # Pointer) OR 	(* wrong bind type *)
          (obj.typ.base.form # Record) AND
          ((obj.form # Ind) OR
           (obj.typ.base.form # Pointer) OR
           (obj.typ.base.base.form # Record)) THEN
      Err.Mark(binderr)
    ELSIF sym # ident THEN
      Err.Mark(ident)
    END;
    Sym.NewSym(Tbp, proc); proc2 := proc;
    proc.lev := 0; proc.a0 := 0;
  END;

  proc.syms := Sym.symbols; proc.forw := forw;
  CheckMark(proc.mark);
  proc.typ := Sym.notyp;
  IF sym = lparen THEN
    FormalParameters(proc.typ, psize);
  END ;
  Sym.NewSym(Sep, sep); Sym.Insert(sep);	(* separate pars *)
  IF proc.form = CProc THEN
    IF sym = number THEN
      IntConstExpression(proc.a1);
      IF sym = comma THEN
        Scan.Get(sym);
        IntConstExpression(proc.a0);
      ELSE
        Err.Mark(comma)
      END;
    ELSE
      Err.Mark(number)
    END;
  END;

  IF (proc.form = Tbp) AND (obj # NIL) THEN
    proc.a1 := OCH.GetBoundNo(proc, obj.typ);
    typ := OCH.GetRecordType(obj.typ);
    Sym.InsertIn(typ.syms, proc);
    IF psize # 0 THEN DEC(obj.a0,8) END;
    INC(psize, fpsize);
    IF proc = proc2 THEN proc.lev := Coder.GetProcNo(proc) END;
  ELSIF (proc.form # CProc) & (proc.mark # Sym.NoExport)
      & (proc = proc2) THEN
    proc.a1 := Coder.GetProcNo(proc);
  END;
  IF proc2 # proc THEN	(* was forward *)
    OCH.CompareParLists(proc.syms.next, proc2.syms.next, proc.typ, proc2.typ);
    IF proc.mark # proc2.mark THEN Err.Mark(forwmark) END;
    proc := proc2;
    proc.syms := Sym.symbols;
  END;
  Stat.New( Stat.Proc, procStat);
  procStat.sym := proc; Stat.Add( procStat);
  procStat.a0 := 0;
  IF body THEN procStat.a0 := 1 END;

  IF body THEN
    CheckSym(semicolon);
    dsize := psize;
    Block(dsize, proc);
  END;

  Sym.OldList
 END ProcedureDeclaration;


PROCEDURE CheckChange*;
 BEGIN
  IF (lastSymbol # NIL) & (lastSymbol.lev < 0)
       & (lastSymbol.mark = Sym.ReadOnly) THEN
    Err.Mark(assread)
  END;
 END CheckChange;


PROCEDURE ActualParameters*(x : Expr.Expr);
  VAR
    apar : Expr.Expr;
    fpar : Sym.Symbol;

  PROCEDURE CheckByte(ft, at: Sym.Struct) : BOOLEAN;
   BEGIN
    RETURN (ft.form = DynArr) AND (ft.base.form = Byte) OR
                 (* VAR ARRAY OF BYTE : any actual type *)
           (ft.form = Byte) AND (at.size = 1)
                 (* VAR BYTE : actual type size 1 *)
   END CheckByte;

  PROCEDURE PushArrayLens(apar: Expr.Expr);
    VAR
      typ: Sym.Struct;
   BEGIN
    IF CheckByte( fpar.typ.base, apar.typ) THEN
      Com.Push( Com.ExtendTo( OCH.TypeSize(apar, apar.typ), Sym.linttyp) );
    ELSE
      typ := apar.typ;
      REPEAT
        Com.Push( Com.ExtendTo( OCH.LenOfArray(apar, typ), Sym.linttyp) );
        IF (typ.form IN {Array, DynArr, OpenArr}) THEN typ := typ.base END;
      UNTIL ~(typ.form IN {Array, DynArr, OpenArr});
    END;
   END PushArrayLens;

  PROCEDURE PushComplex(apar: Expr.Expr; typ: Sym.Struct);
    VAR
      size : LONGINT;
      sp,sx: Expr.Expr;
   BEGIN
    size := typ.size;
    IF ODD(size) THEN INC(size) END;
    INC(Com.stack, size);
    sp := Com.SP();
    sx := Com.Const(size, Sym.linttyp);
    Com.Asgn( sp, Com.Sub(sp, sx) );
    Com.Asgn( Com.Deref(sp, typ), apar);
   END PushComplex;

  PROCEDURE CheckParCompatible(tbpPar: BOOLEAN);
    VAR
      ft, at : Sym.Struct;
      adr  : Expr.Expr;
   BEGIN
    IF (fpar # NIL) AND (apar # NIL) THEN
      IF fpar.form = Ind THEN	(* VAR param *)
        CheckChange;
        ft := fpar.typ.base; at := apar.typ;
        IF tbpPar & (at.form = Pointer) & (ft.form = Record) THEN
          at := at.base
        ELSE
          tbpPar := FALSE
        END;
        IF ~Sym.SameType(ft, at)
            & ((ft.form # Sym.AnyPtr) OR (at.form # Sym.Pointer))
            & ~CheckByte(ft, at) THEN
          WHILE (ft.form = DynArr) AND (at.form IN {Array, DynArr, OpenArr}) DO
            ft := ft.base; at := at.base;
          END;
          IF NOT Sym.SameType(at, ft) THEN
            IF (at.form = Pointer) AND (ft.form = Pointer) THEN
              at := at.base; ft := ft.base;
            END(*IF*);
            IF (at.form = Record) AND (ft.form = Record) THEN
              WHILE (at # NIL) AND NOT Sym.SameType(at, ft) DO
                at := at.base;
              END;
              IF at = NIL THEN Err.Mark(incomp) END;
            ELSE
              Err.Mark(incomp)
            END;
          END;
        END;
        IF fpar.typ.base.form = Record THEN	(* VAR record *)
          Com.Push( OCH.TD(apar) );
        ELSIF fpar.typ.base.form = DynArr THEN
          PushArrayLens(apar);
        END;
        IF tbpPar THEN
          Com.Push( apar );
        ELSE
          Com.Push( Com.Adr(apar) );
        END;
      ELSIF fpar.form = Cpy THEN
        ft := fpar.typ.base;
        IF ~CheckByte(ft, apar.typ) THEN
          OCH.AssnCompatible(ft, apar);
        END;
        PushArrayLens(apar);
        Com.Push( Com.Adr(apar) );
      ELSE
        OCH.AssnCompatible(fpar.typ, apar);
        IF fpar.typ.form IN {Array, Record} THEN
          PushComplex(apar, fpar.typ);
        ELSE
          Com.Push( apar );
        END;
      END;
      fpar := fpar.next;
    END;
   END CheckParCompatible;

 BEGIN
  Com.StoreStack(x);
  fpar := OCH.FPar(x);
  IF x.typ.form = TbpStr THEN		(* tbp: first parameter *)
    apar := x.op1;
    CheckParCompatible(TRUE);
  END;
  IF sym = lparen THEN
    Scan.Get(sym);
    IF sym # rparen THEN
      LOOP
        Expression(apar);
        IF fpar = NIL THEN
          Err.Mark(morepar)
        ELSE
          CheckParCompatible(FALSE)
        END;
        IF sym = comma THEN Scan.Get(sym)
        ELSIF (lparen <= sym) & (sym <= ident) THEN Err.Mark(comma)
        ELSE EXIT
        END
      END;
    END;
  END;
  IF (fpar # NIL) & (fpar.form # Sym.Sep) THEN
    Err.Mark(lesspar)
  END;
 END ActualParameters;


PROCEDURE Element(VAR x: Expr.Expr);
  VAR
    e2, y: Expr.Expr;
 BEGIN
  Expression(x);
  IF sym = upto THEN
    Scan.Get(sym); Expression(e2);
  ELSE
    e2 := x
  END ;
  x := Com.Set(x, e2);
 END Element;


PROCEDURE Sets(VAR x: Expr.Expr);
  VAR
    y, con: Expr.Expr;
 BEGIN
  IF sym # rbrace THEN
    Element(x);
    LOOP
      IF sym = comma THEN Scan.Get(sym)
      ELSIF (lparen <= sym) & (sym <= ident) THEN Err.Mark(comma)
      ELSE EXIT
      END ;
      Element(y);
      OCH.Op(plus, x, y)  (*x := x+y*)
    END
  ELSE
    Expr.New(Expr.Con, y, Sym.settyp);
    y.a0 := 0;
    x := y;
  END ;
  CheckSym(rbrace)
 END Sets;


PROCEDURE Factor(VAR x: Expr.Expr);
  VAR
    ce : Expr.Expr;
    obj: Sym.Symbol;
    sp : POINTER TO ARRAY OF CHAR;
    tl, fl, el: Stat.Stat;
    typ: Sym.Struct;
 BEGIN
  IF sym < lparen THEN
    Err.Mark(illfac);
    REPEAT Scan.Get(sym) UNTIL sym >= lparen;
  END ;
  IF sym = ident THEN
    qualident(x); selector(x);
    IF x = NIL THEN
      Err.Mark(funcproc); Expr.New( Expr.Def, x, Sym.undftyp);
    END;
    IF (x.typ.form = Sym.NoTyp) THEN Err.Mark(funcproc) END;
  ELSIF sym = not THEN
    Scan.Get(sym); Factor(x);
    IF ~(x.typ.form IN {Bool, Def}) THEN Err.Mark(boolonly) END;
    fl := falseLab; falseLab := trueLab; trueLab := fl;
    x := Com.Not(x);
  ELSIF sym = lparen THEN
    Scan.Get(sym); Expression(x); CheckSym(rparen)
  ELSIF sym = number THEN
    Scan.Get(sym);
    Expr.New(Expr.Con, ce, Sym.realtyp);
    CASE Scan.numtyp OF
      Scan.inttyp:
        ce.a0 := Scan.intval; ce.typ := OCH.GetIntType(ce.a0);
    | Scan.chartyp:
        ce.a0 := Scan.intval; ce.typ := Sym.chartyp;
    | Scan.realtyp:
        ce.a0 := S.VAL(LONGINT, Scan.realval)
    | Scan.lrltyp:
        ce.typ := Sym.lrltyp; S.PUT( S.ADR(ce.a0), Scan.lrlval)
    END;
    x := ce;
  ELSIF sym = string THEN
    Expr.New(Expr.Con, ce, Sym.stringtyp);
    NEW(sp, Strings.Length(Scan.name)+1 );
    COPY(Scan.name, sp^);
    ce.a1 := S.VAL(LONGINT, sp);
    ce.a0 := -1;
    Scan.Get(sym);
    x := ce;
  ELSIF sym = nil THEN
    x := Com.Const(0, Sym.niltyp); Scan.Get(sym);
  ELSIF sym = lbrak THEN
    Scan.Get(sym); Err.Mark(lparen); Expression(x); CheckSym(rparen)
  ELSIF sym = lbrace THEN
    Scan.Get(sym); Sets(x)
  ELSIF sym = Scan.td THEN
    Scan.Get(sym); CheckSym(lparen);
    qualidentobj(obj); CheckSym(rparen);
    typ := obj.typ;
    IF typ.form = Sym.Pointer THEN typ := typ.base END;
    IF ~(typ.form IN {Array, OpenArr, Record}) THEN
      Err.Mark(notd)
    END;
    Expr.New(Expr.TD, x, Sym.ptrtyp);
    x.a0 := S.VAL( LONGINT, typ);
  ELSE
    Err.Mark(illfac); Scan.Get(sym);
    Expr.New(Expr.Def, x, Sym.undftyp);
  END
 END Factor;


PROCEDURE ReplaceLabelBy(label, by: Stat.Stat);
  VAR
    s: Stat.Stat;
 BEGIN
  s := Stat.stats;
  WHILE s # NIL DO
    IF ((s.form = Stat.Bct) OR (s.form = Stat.Bcf))
        & (s.expr.sym = label.expr.sym) THEN
      s.expr := by.expr;
    END;
    s := s.next;
  END;
 END ReplaceLabelBy;


PROCEDURE Term(VAR x: Expr.Expr);
  VAR
    z : Expr.Expr;
    op: INTEGER;
    extended: BOOLEAN;
    fl: Stat.Stat;
 BEGIN
  Factor(x);
  fl := falseLab;
  WHILE (times <= sym) & (sym <= and) DO
    IF sym = and THEN
      IF fl = NIL THEN Com.NewLabel(fl) END;
      Com.BranchFalse(x, fl);
      IF trueLab # NIL THEN Stat.Add(trueLab); trueLab := NIL END;
      falseLab := NIL;
      Scan.Get(sym); Factor(x);
      IF falseLab # NIL THEN ReplaceLabelBy(falseLab, fl) END;
      falseLab := fl;
    ELSE
      op := sym;
      Scan.Get(sym); Factor(z);
      OCH.CalcCompatible(x, z, op);
      extended := (op IN {div, mod, times})	(* only word operation possible *)
         & (x.typ.form = SInt) & (z.typ.form = SInt);
      IF extended THEN
        OCH.Extend(x, Sym.inttyp); OCH.Extend(z, Sym.inttyp);
      END;
      OCH.Op(op, x, z);
      IF extended THEN
        x := Com.Short(x, Sym.sinttyp)
      END;
    END;
  END;
 END Term;


PROCEDURE SimpleExpression(VAR x: Expr.Expr);
  VAR
    z : Expr.Expr;
    op: INTEGER;
    tl: Stat.Stat;
 BEGIN
  IF sym = minus THEN
    Scan.Get(sym); Term(z);
    x := Com.Neg(z);
  ELSIF sym = plus THEN Scan.Get(sym); Term(x)
  ELSE Term(x)
  END;
  tl := trueLab;
  WHILE (plus <= sym) & (sym <= or) DO
    IF sym = or THEN
      IF tl = NIL THEN Com.NewLabel(tl) END;
      Com.BranchTrue(x, tl);
      IF falseLab # NIL THEN Stat.Add(falseLab); falseLab := NIL END;
      trueLab := NIL;
      Scan.Get(sym); Term(x);
      IF trueLab # NIL THEN ReplaceLabelBy(trueLab, tl) END;
      trueLab := tl;
    ELSE
      op := sym;
      Scan.Get(sym); Term(z);
      OCH.CalcCompatible(x, z, op);
      OCH.Op(op, x, z);
    END;
  END;
 END SimpleExpression;


PROCEDURE GetIsExpr*(VAR x : Expr.Expr; VAR ntyp: Sym.Struct);
  VAR
    obj: Sym.Symbol;
    typ: Sym.Struct;
 BEGIN
  ntyp := Sym.undftyp;
  IF (x.typ.form # Record)
      & ((x.typ.form # Pointer) OR (x.typ.base.form # Record)) THEN
    Err.Mark(ptrrecexp)
  END;
  Scan.Get(sym);
  IF sym = ident THEN
    qualidentobj(obj);
    IF (obj.form # Typ) THEN
      Err.Mark(type);
    ELSE
      typ := obj.typ;
      IF (obj.typ.form = Pointer) THEN typ := typ.base END;
      ntyp := typ;
      IF typ.form # Record THEN Err.Mark(record)
      ELSE
        x := Com.Cmp( Com.TD(typ),
            Com.Disp( Com.Deref( OCH.TD(x), Sym.ptrtyp ),
                Com.Const( Sym.TDBaseTyps + typ.n*Sym.PtrSize, Sym.sinttyp ),
                Sym.ptrtyp),
            eql );
        RETURN;
      END;
    END;
  ELSE Err.Mark(ident)
  END;
  Expr.New( Expr.Def, x, Sym.undftyp);
 END GetIsExpr;


PROCEDURE Expression*(VAR x: Expr.Expr);
  VAR
    y, cmp : Expr.Expr;
    op  : INTEGER;
    typ : Sym.Struct;
 BEGIN
  lastSymbol := NIL;
  SimpleExpression(x);
  op := sym;
  IF (eql <= op) & (op <= geq) THEN
    Scan.Get(sym);
    SimpleExpression(y);
    OCH.CalcCompatible(x, y, op);
    Expr.New( Expr.Cmp, cmp, Sym.booltyp);
    cmp.a0 := op;
    cmp.op1 := x; cmp.op2 := y; x:= cmp;
  ELSIF op = in THEN
    Expr.New( Expr.In, y, Sym.booltyp);
    Scan.Get(sym);
    y.op1 := x; SimpleExpression(y.op2); x:= y;
    IF y.op2.typ.form # Set THEN Err.Mark(setonly) END;
  ELSIF sym = is THEN
    GetIsExpr(x, typ);
  ELSIF sym = becomes THEN
    CheckChange;
    Expr.New(Expr.Asgn, y, x.typ); y.op1 := x;
    Scan.Get(sym); Expression(y.op2);
    OCH.AssnCompatible(x.typ, y.op2);
    x := y;
    IF NOT Par.ext THEN Err.Mark(ext2only) END;
  END;
 END Expression;


PROCEDURE Block(VAR dsize : LONGINT; symbol: Sym.Symbol);
  VAR
    begStat, endStat: Stat.Stat;
 BEGIN
  IF Sym.level = 0 THEN dsize := 2 ELSE dsize := 0 END;
  LOOP
    IF sym = const THEN ConstantDeclaration END;
    IF sym = type THEN TypeDeclaration END;
    IF sym = var THEN VariableDeclaration(dsize) END;
    IF (sym < const) OR (sym > var) THEN EXIT END ;
  END;
  OCH.CheckUndefPointer;
  WHILE sym = procedure DO
   Scan.Get(sym); ProcedureDeclaration; CheckSym(semicolon)
  END ;
  Stat.New(Stat.Begin, begStat); Stat.Add(begStat);
  IF Sym.level = 0 THEN begStat.a0 := 0
  ELSE begStat.a0 := -SHORT( dsize)
  END;
  IF sym = begin THEN
    DEC(Par.position); S.PUT( S.ADR( symbol.first), Par.position);
    Scan.ToEnd(symbol.name);
  ELSE
    symbol.first := -1;
    CheckSym(end);
    IF sym # ident THEN Err.Mark(ident)
    ELSIF Scan.name # symbol.name THEN Err.Mark(idmatch)
    END;
  END;
  Stat.New(Stat.End, endStat); Stat.Add(endStat);
  Scan.Get(sym);
 END Block;


PROCEDURE ScanSymbols*;
(*
 Scan the symbols of the currently set file.
 *)
  VAR
    impid, filename : ARRAY 24 OF CHAR;
    modStat : Stat.Stat;
    key, lab : LONGINT;
    mod: Sym.Symbol;
    unqualified : BOOLEAN;
 BEGIN
  Scan.Get(sym);
  IF sym = module THEN Scan.Get(sym)
  ELSE Err.Mark(module)
  END;
  IF sym = ident THEN
    COPY(Scan.name, modid);
    Import.ImportSelf(modid);
    Sym.NewSym( Sym.Mod, mod); mod.syms := Sym.symbols;
    Stat.New( Stat.Mod, modStat); modStat.sym := mod;
    Stat.Add( modStat);
    Scan.Get(sym); CheckSym(semicolon);
    IF sym = import THEN
      Scan.Get(sym);
      LOOP
        IF sym = ident THEN
          COPY(Scan.name, impid);
          COPY(impid, filename);
          unqualified := FALSE;
          Scan.Get(sym);
          IF sym = becomes THEN
            Scan.Get(sym);
            IF sym = ident THEN
              COPY(Scan.name, filename);
              Scan.Get(sym);
            ELSE
              Err.Mark(ident)
            END
          ELSIF sym = times THEN
            unqualified := TRUE;
            Scan.Get(sym);
          END ;
          IF unqualified & ~Par.ext THEN Err.Mark(ext2only) END;
          Import.Import(filename, impid, unqualified);
        ELSE
          Err.Mark(ident)
        END ;
        IF sym = comma THEN Scan.Get(sym)
        ELSIF sym = ident THEN Err.Mark(comma)
        ELSE EXIT
        END
      END ;
      CheckSym(semicolon)
    END ;
    IF ~ Err.scanerr THEN
      Block(vsize, mod);
      CheckSym(period);
    END;
  ELSE
    Err.Mark(ident)
  END;
 END ScanSymbols;


PROCEDURE Init*;
 BEGIN
  trueLab := NIL; falseLab := NIL;
  lastSymbol := NIL;
 END Init;


PROCEDURE Exit*;
 BEGIN
  trueLab := NIL; falseLab := NIL;
  lastSymbol := NIL;
 END Exit;


END OCSymScan.