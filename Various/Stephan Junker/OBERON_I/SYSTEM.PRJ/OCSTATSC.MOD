MODULE OCStatScan; (* SJ 2.10.94 / 27.11.94 *)


IMPORT
  S:=SYSTEM, Expr:=OCExpr, Scr:=OCSymScan, Stat:=OCStat, Sym:=OCSymbol,
  OCH:=OCH2, Com:=OCCom, Err:=OCErr, Scan:=OCScan, Par:=OCPar, IO, Strings;


CONST
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

  (* symbol forms *)
  Def=Sym.Def; Var=Sym.Var; Fld=Sym.Fld; Typ=Sym.Typ; LProc=Sym.LProc;
  SProc=Sym.SProc; CProc=Sym.CProc; IProc=Sym.IProc; Mod=Sym.Mod;
  Con=Sym.Con; Tbp=Sym.Tbp; Ind=Sym.Ind; Cpy=Sym.Cpy; Head=Sym.Head;
  Sep=Sym.Sep;

  (*structure forms*)
  Undef=Sym.Undef; Byte=Sym.Byte; Bool=Sym.Bool; Char=Sym.Char;
  SInt=Sym.SInt; Int=Sym.Int; LInt=Sym.LInt; Real=Sym.Real;
  LReal=Sym.LReal; Set=Sym.Set; String=Sym.String; NilTyp=Sym.NilTyp;
  NoTyp=Sym.NoTyp; AnyPtr=Sym.AnyPtr; Pointer=Sym.Pointer;
  ProcTyp=Sym.ProcTyp; Array=Sym.Array; DynArr=Sym.DynArr;
  OpenArr=Sym.OpenArr; Record=Sym.Record; TbpStr=Sym.TbpStr;
  ProcStr=Sym.ProcStr;

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
  casesize = 123; stringonly = 144; simpletype = 154; numtyp = 157;
  chartyp = 158; realtyp = 152; lintonly = 203; sametype = 204;
  nomoreret = 205;

  IntTypes = {SInt, Int, LInt};



VAR
  exitLabel: Expr.Expr;		(* for EXIT *)
  AssemblerCode*: PROCEDURE ();
  symbols: Sym.Symbol;



PROCEDURE GetIncDec( VAR x, y: Expr.Expr);
 BEGIN
  Scr.Expression(x);
  IF x.form = Expr.Con THEN Err.Mark(var) END;
  IF NOT (x.typ.form IN {SInt..LInt, Byte, AnyPtr, Pointer, Def}) THEN
    Err.Mark(intonly); x.typ := Sym.undftyp;
  END;
  IF Scr.sym = comma THEN
    Scan.Get(Scr.sym); Scr.Expression(y);
    OCH.AssnCompatible(x.typ, y);
  ELSE
    y := Com.Const( 1, x.typ);
  END;
 END GetIncDec;


PROCEDURE GetInclExcl( VAR x, y: Expr.Expr);
 BEGIN
  Scr.Expression(x);
  IF x.form = Expr.Con THEN Err.Mark(var) END;
  IF x.typ.form # Set THEN
    Err.Mark(setonly); x.typ := Sym.undftyp;
  END;
  Scr.CheckSym(comma);
  Scr.Expression(y);
  IF ~(y.typ.form IN {SInt..LInt, Def}) THEN Err.Mark(intonly) END;
 END GetInclExcl;


PROCEDURE DualLogic( form, op: INTEGER; VAR expr: Expr.Expr);
  VAR
    x, y: Expr.Expr;
 BEGIN
  Scr.Expression(x);
  IF ~(x.typ.form IN {Undef, Byte, SInt..LInt, AnyPtr}) THEN
    Err.Mark(intonly)
  END;
  Scr.CheckSym(comma);
  Scr.Expression(y);
  IF ~(y.typ.form IN {Undef, SInt..LInt}) THEN Err.Mark(intonly) END;
  OCH.CalcCompatible(x, y, op);
  expr := Com.TwoOpExpr(form, x.typ, x, y);
 END DualLogic;


PROCEDURE Shift( form: INTEGER; VAR expr: Expr.Expr);
  VAR
    x, y, ext: Expr.Expr;
 BEGIN
  Scr.Expression(x);
  IF ~(x.typ.form IN {Undef, Byte, SInt..LInt, AnyPtr}) THEN
    Err.Mark(intonly)
  END;
  Scr.CheckSym(comma);
  Scr.Expression(y);
  IF ~(y.typ.form IN {Undef, SInt..LInt}) THEN Err.Mark(intonly) END;
  IF x.typ.size # 4 THEN
    x := Com.ULong(x, Sym.linttyp);
  END;
  expr := Com.TwoOpExpr(form, Sym.linttyp, x, y);
 END Shift;


PROCEDURE NewTrueLab(VAR false, true: Stat.Stat);
 BEGIN
  IF Scr.trueLab = NIL THEN Com.NewLabel(true)
  ELSE true := Scr.trueLab; Scr.trueLab := NIL
  END;
  false := Scr.falseLab; Scr.falseLab := NIL;
 END NewTrueLab;


PROCEDURE IsTempVar(x: Expr.Expr) : BOOLEAN;
  VAR
    sp: Strings.ptr;
 BEGIN
  IF x.form = Expr.Sym THEN
    sp := S.ADR(x.sym.name);
    RETURN (sp[0] = "T") & (sp[1] = "E") & (sp[2] = "M") & (sp[3] = "P")
  END;
  RETURN FALSE
 END IsTempVar;


PROCEDURE StandProcCall(sym: Sym.Symbol; VAR expr: Expr.Expr);
(*
 sym.form = SProc
 *)
  VAR
    x, y, z: Expr.Expr;
    num : INTEGER;
    typ : Sym.Struct;
    reg, val : LONGINT;
    stat, first, false, true: Stat.Stat;

  PROCEDURE HaltStat;
    VAR
      x: Expr.Expr;
   BEGIN
    Scr.Expression(x);
    IF ~ (x.typ.form IN {SInt, Int, Def}) THEN
      Err.Mark(intonly)
    ELSIF ~Expr.IsConst(x) & ~Par.ext THEN
      Err.Mark(ext2only)
    END;
    OCH.AssnCompatible(Sym.inttyp, x);
    Com.StoreStack(Com.SysHalt);
    Com.Push(x); Com.Call(Com.SysHalt);
    Com.RestoreStack(Com.SysHalt);
   END HaltStat;

 BEGIN
  expr := NIL;
  Scr.CheckSym(lparen);
  CASE sym.a1 OF
    Sym.Halt:
      HaltStat;

  | Sym.New:
      Scr.Expression(x);
      IF x.form = Expr.Con THEN Err.Mark(var) END;
      IF x.typ.form # Pointer THEN Err.Mark(pointer)
      ELSE
        Com.StoreStack(Com.StorageNew);
        num := 0; typ := x.typ;
        WHILE (typ.base.form = OpenArr) DO
          Scr.CheckSym(comma);
          Scr.Expression(y);
          OCH.AssnCompatible(Sym.linttyp, y);
          Com.Push(y);
          INC(num); typ := typ.base;
        END;
        Com.Push( Com.ACon( Com.TD( x.typ.base ) ) );
        Com.Push( Com.Adr( x ) );
        Com.Call(Com.StorageNew);
        Com.RestoreStack(Com.StorageNew);
      END;

  | Sym.SNew:
      Scr.Expression(x);
      IF x.form = Expr.Con THEN Err.Mark(var) END;
      IF (x.typ.form # Pointer) & (x.typ.form # AnyPtr) THEN
        Err.Mark(pointer)
      ELSE
        Com.StoreStack(Com.StorageSNew);
        Scr.CheckSym(comma);
        Scr.Expression(y);
        OCH.AssnCompatible(Sym.linttyp, y);
        Com.Push(y);
        Com.Push( Com.Adr( x ) );
        Com.Call(Com.StorageSNew);
        Com.RestoreStack(Com.StorageSNew);
      END;

  | Sym.Inc:
      GetIncDec( x, y);
      Com.Asgn( x, Com.Add( x, y) );

  | Sym.Dec:
      GetIncDec( x, y);
      Com.Asgn( x, Com.Sub( x, y) );

  | Sym.Incl:
      GetInclExcl( x, y);
      Com.Asgn( x, Com.Add( x, Com.Set( y, y) ) );

  | Sym.Excl:
      GetInclExcl( x, y);
      Com.Asgn( x, Com.Sub( x, Com.Set( y, y) ) );

  | Sym.Copy:
      Scr.Expression(x);
      IF (x.typ.form # String)
          & (~(x.typ.form IN {Array, DynArr, OpenArr})
            OR (x.typ.base.form # Char)) THEN
        Err.Mark(stringonly);
      END;
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF ~(y.typ.form IN {Array, DynArr, OpenArr})
          OR (y.typ.base.form # Char) THEN
        Err.Mark(stringonly);
      END;
      IF x.form IN {Sym.DynArr, Sym.OpenArr} THEN
        Expr.New( Expr.DynArr, z, x.typ);
        z.op1 := x; z.op2 := OCH.TypeSize(x, x.typ);
        x := z;
      END;
      IF y.form IN {Sym.DynArr, Sym.OpenArr} THEN
        Expr.New( Expr.DynArr, z, y.typ);
        z.op1 := y; z.op2 := OCH.TypeSize(y, y.typ);
        y := z;
      END;
      Com.Asgn( y, x);

  | Sym.Dispose:
      Scr.Expression(x);
      IF x.form = Expr.Con THEN Err.Mark(var) END;
      IF (x.typ.form # Pointer) & (x.typ.form # AnyPtr) THEN
        Err.Mark(pointer)
      ELSE
        Com.StoreStack(Com.StorageDispose);
        Com.Push( x);
        Com.Call(Com.StorageDispose);
        Com.RestoreStack(Com.StorageDispose);
      END;

  | Sym.Get:
      Scr.Expression(x);
      IF (x.typ.form IN {SInt, Int}) & Expr.IsConst(x) THEN
        x.typ := Sym.linttyp
      END;
      IF ~(x.typ.form IN {LInt, AnyPtr, Pointer}) THEN Err.Mark(pointer)
      ELSE
        Scr.CheckSym(comma);
        Scr.Expression(y);
        IF y.form = Expr.Con THEN Err.Mark(var) END;
        IF y.typ.form IN {DynArr, OpenArr} THEN Err.Mark(nodyn) END;
        Com.Asgn( y, Com.Deref(x, y.typ) );
      END;

  | Sym.Put:
      Scr.Expression(x);
      IF (x.typ.form IN {SInt, Int}) & Expr.IsConst(x) THEN
        x.typ := Sym.linttyp
      END;
      IF ~(x.typ.form IN {LInt, AnyPtr, Pointer}) THEN Err.Mark(pointer)
      ELSE
        Scr.CheckSym(comma);
        Scr.Expression(y);
        IF y.typ.form IN {DynArr, OpenArr} THEN Err.Mark(nodyn) END;
        IF y.typ.form = String THEN OCH.StringToChar(y) END;
        Com.Asgn( Com.Deref(x, y.typ), y );
      END;

  | Sym.Getreg:
      Scr.IntConstExpression(reg);
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF y.form = Expr.Con THEN Err.Mark(var) END;
      IF (y.typ.form IN {String..NoTyp, Array..Record}) THEN
        Err.Mark(simpletype); y.typ := Sym.undftyp;
      END;
      IF reg >= 16 THEN
        Com.Asgn( y, Com.FPn(SHORT(reg)-16, y.typ) );
      ELSIF reg >= 8 THEN
        Com.Asgn( y, Com.An(SHORT(reg)-8, y.typ) );
      ELSE
        Com.Asgn( y, Com.Dn(SHORT(reg), y.typ) );
      END;

  | Sym.Putreg:
      Scr.IntConstExpression(reg);
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF y.form = Expr.Con THEN Err.Mark(var) END;
      IF (y.typ.form IN {String..NoTyp, Array..Record}) THEN
        Err.Mark(simpletype); y.typ := Sym.undftyp;
      END;
      IF reg >= 16 THEN
        Com.Asgn( Com.FPn(SHORT(reg)-16, y.typ), y);
      ELSIF reg >= 8 THEN
        Com.Asgn( Com.An(SHORT(reg)-8, y.typ), y );
      ELSE
        Com.Asgn( Com.Dn(SHORT(reg), y.typ), y );
      END;

  | Sym.Inline:
      LOOP
        Scr.ConstExpression(x);
        IF ~(x.typ.form IN IntTypes) THEN Err.Mark(intonly) END;
        Com.Dcw(x);
        IF Scr.sym = comma THEN Scan.Get( Scr.sym)
        ELSE EXIT
        END;
      END;

  | Sym.Move:
      Scr.Expression(x);
      IF ~(x.typ.form IN {LInt, AnyPtr, Pointer}) THEN
        Err.Mark(pointer); x.typ := Sym.undftyp;
      END;
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF ~(y.typ.form IN {LInt, AnyPtr, Pointer}) THEN
        Err.Mark(pointer); y.typ := Sym.undftyp;
      END;
      Scr.CheckSym(comma);
      Scr.Expression(z);
      IF ~(z.typ.form IN {SInt..LInt, Def}) THEN
        Err.Mark(intonly); z.typ := Sym.undftyp;
      END;
      OCH.AssnCompatible(Sym.linttyp, z);
      Com.StoreStack(Com.MemoryCopy);
      Com.Push(x); Com.Push(y); Com.Push(z);
      Com.Call(Com.MemoryCopy);
      Com.RestoreStack(Com.MemoryCopy);

  | Sym.Void:
      Scr.Expression(x);
      IF x.typ.form = NoTyp THEN Err.Mark(funcproc) END;

  | Sym.Assert:
      first := Stat.insert.prev;
      Scr.Expression(x);
      IF x.typ.form # Bool THEN Err.Mark(boolonly) END;
      Scr.CheckSym(comma);
      NewTrueLab(false, true);
      Com.BranchTrue(x, true);
      IF false # NIL THEN Stat.Add(false) END;
      HaltStat;
      Stat.Add(true);
      IF ~Par.arichk THEN
        stat := Stat.insert.prev;
        WHILE stat # first DO
          Stat.Remove(stat);
        END;
      END;

  | Sym.Size:
      Scr.qualidentobj(sym);
      IF sym.typ.form IN {NoTyp, String, DynArr, OpenArr} THEN Err.Mark(type) END;
      expr := Com.Const( sym.typ.size, OCH.GetIntType( sym.typ.size) );

  | Sym.Min:
      Scr.qualidentobj(sym);
      CASE sym.typ.form OF
        SInt: val := MIN(SHORTINT);
      | Int:  val := MIN(INTEGER);
      | LInt: val := MIN(LONGINT);
      | Set:  val := 0;
      | Real: expr := Com.Const( 0FF7FFFFFH, Sym.realtyp);
              RETURN;
      | LReal:expr := Com.Const( 0FFEFFFFFH, Sym.lrltyp);
              expr.a1 := 0FFFFFFFFH; RETURN;
      | Def:  val := 0;
      ELSE Err.Mark(simpletype); val := 0;
      END;
      expr := Com.Const( val, OCH.GetIntType( val) );

  | Sym.Max:
      Scr.qualidentobj(sym);
      CASE sym.typ.form OF
        SInt: val := MAX(SHORTINT);
      | Int:  val := MAX(INTEGER);
      | LInt: val := MAX(LONGINT);
      | Set:  val := 31;
      | Real: expr := Com.Const( 07F7FFFFFH, Sym.realtyp);
              RETURN;
      | LReal:expr := Com.Const( 07FEFFFFFH, Sym.lrltyp);
              expr.a1 := 0FFFFFFFFH; RETURN;
      | Def:  val := 0;
      ELSE Err.Mark(simpletype); val := 0;
      END;
      expr := Com.Const( val, OCH.GetIntType( val) );

  | Sym.Val:
      Scr.qualidentobj(sym);
      Scr.CheckSym(comma);
      Scr.Expression(y);
      y := Expr.Copy(y);
      IF IsTempVar(y) THEN y.sym.name[0] := "S" END;
      y.typ := sym.typ;
      expr := y;

  | Sym.Odd:
      Scr.Expression(x);
      IF x.typ.form = String THEN OCH.StringToChar(x);
      ELSIF ~(x.typ.form IN {Byte, Char..LInt, AnyPtr, Pointer}) THEN
        Err.Mark(simpletype)
      END;
      expr := Com.OneOpExpr(Expr.Odd, Sym.booltyp, x);

  | Sym.Chr:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Byte, SInt..LInt}) THEN
        Err.Mark(intonly)
      END;
      expr := Com.OneOpExpr(Expr.Chr, Sym.chartyp, x);

  | Sym.Abs:
      Scr.Expression(x);
      IF ~(x.typ.form IN {SInt..LInt, Real, LReal}) THEN
        Err.Mark(numtyp)
      END;
      expr := Com.OneOpExpr(Expr.Abs, x.typ, x);

  | Sym.Cap:
      Scr.Expression(x);
      IF x.typ.form = String THEN OCH.StringToChar(x);
      ELSIF x.typ.form # Char THEN Err.Mark(chartyp)
      END;
      expr := Com.OneOpExpr(Expr.Cap, Sym.chartyp, x);

  | Sym.Ord:
      Scr.Expression(x);
      IF x.typ.form = String THEN OCH.StringToChar(x);
      ELSIF x.typ.form # Char THEN Err.Mark(chartyp)
      END;
      expr := Com.OneOpExpr(Expr.Ord, Sym.inttyp, x);

  | Sym.Entier:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Real, LReal}) THEN Err.Mark(realtyp) END;
      expr := Com.OneOpExpr(Expr.Entier, Sym.linttyp, x);

  | Sym.Trunc:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Real, LReal}) THEN Err.Mark(realtyp) END;
      expr := Com.OneOpExpr(Expr.Trunc, Sym.linttyp, x);

  | Sym.Adr:
      Scr.Expression(x);
      IF (x.form = Expr.Con) & (x.typ.form # String) THEN Err.Mark(var) END;
      expr := Com.Adr(x);

  | Sym.Short:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Int, LInt, LReal}) THEN Err.Mark(numtyp) END;
      expr := Com.OneOpExpr(Expr.Short, OCH.ShortType(x.typ), x);

  | Sym.Long:
      Scr.Expression(x);
      IF ~(x.typ.form IN {SInt..Real}) THEN Err.Mark(numtyp) END;
      expr := Com.OneOpExpr(Expr.Long, OCH.LongType(x.typ), x);

  | Sym.ULong:
      Scr.Expression(x);
      IF ~(x.typ.form IN {SInt, Int}) THEN Err.Mark(intonly) END;
      IF x.form = Expr.ULong THEN
        x.typ := Sym.linttyp
      ELSE
        expr := Com.OneOpExpr(Expr.ULong, OCH.LongType(x.typ), x);
      END;

  | Sym.Ntl:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Undef, Byte, SInt..LInt}) THEN
        Err.Mark(intonly)
      END;
      expr := Com.OneOpExpr(Expr.Ntl, x.typ, x);

  | Sym.Len:
      Scr.Expression(x);
      IF ~(x.typ.form IN {String, Array, DynArr, OpenArr}) THEN Err.Mark(arrexp) END;
      IF Scr.sym = comma THEN
        Scan.Get( Scr.sym); Scr.IntConstExpression(val);
      ELSE
        val := 0;
      END;
      expr := OCH.LenOfDim(x, SHORT( val) );

  | Sym.Ash:
      Shift( Expr.Ash, expr);

  | Sym.Lsh:
      Shift( Expr.Lsh, expr);

  | Sym.Rot:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Undef, Byte, SInt..LInt, AnyPtr}) THEN
        Err.Mark(intonly)
      END;
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF ~(y.typ.form IN {Undef, SInt..LInt}) THEN Err.Mark(intonly) END;
      expr := Com.TwoOpExpr(Expr.Rot, x.typ, x, y);

  | Sym.Anl:
      DualLogic(Expr.Anl, Scan.andb, expr);

  | Sym.Orl:
      DualLogic(Expr.Orl, Scan.ior, expr);

  | Sym.Xol:
      DualLogic(Expr.Xol, Scan.xor, expr);

  | Sym.Bit:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Undef, LInt, AnyPtr, Pointer}) THEN
        Err.Mark(pointer)
      END;
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF ~(y.typ.form IN {Undef, SInt..LInt}) THEN Err.Mark(intonly) END;
      expr := Com.TwoOpExpr(Expr.Bit, Sym.booltyp, x, y);

  | Sym.Cc:
      Scr.Expression(x);
      IF x.typ.form # Sym.Bool THEN Err.Mark(boolonly) END;
      expr := Com.OneOpExpr(Expr.Coc, Sym.inttyp, x);

  | Sym.Swap:
      Scr.Expression(x);
      IF ~(x.typ.form IN {Undef, LInt}) THEN Err.Mark(lintonly) END;
      expr := Com.OneOpExpr(Expr.Swap, Sym.linttyp, x);

  | Sym.Exg:
      Scr.Expression(x);
      IF x.form = Expr.Con THEN Err.Mark(var) END;
      Scr.CheckSym(comma);
      Scr.Expression(y);
      IF y.form = Expr.Con THEN Err.Mark(var) END;
      IF ~Sym.SameType(x.typ, y.typ) THEN Err.Mark(sametype) END;
      Com.TempVar( Sym.symbols, x.typ, z);
      Com.Asgn( z, x); Com.Asgn( x, y); Com.Asgn( y, z);

  END;
 END StandProcCall;


PROCEDURE NewFalseLab(VAR false, true: Stat.Stat);
 BEGIN
  IF Scr.falseLab = NIL THEN Com.NewLabel(false)
  ELSE false := Scr.falseLab; Scr.falseLab := NIL
  END;
  true := Scr.trueLab; Scr.trueLab := NIL;
 END NewFalseLab;


PROCEDURE IdentStat();
  VAR
    x, y, z: Expr.Expr;
    asn, call, fl, tl, el : Stat.Stat;
    obj : Sym.Symbol;
    exp : Expr.Expr;
 BEGIN
  Scr.lastSymbol := NIL;
  Scr.qualident(x); Scr.selector(x);
  IF (Scr.sym = becomes) OR (Scr.sym = eql) THEN
    IF x = NIL THEN
      Err.Mark(funcproc); Expr.New( Expr.Def, x, Sym.undftyp);
    END;
    IF (x.typ.form = Sym.NoTyp) THEN Err.Mark(funcproc) END;
    Scr.CheckChange;
    IF Scr.sym = eql THEN Err.Mark(becomes) END;
    Scan.Get(Scr.sym); Scr.Expression(y);
    OCH.AssnCompatible(x.typ, y);
    IF x.typ.form IN {DynArr, OpenArr} THEN
      Expr.New( Expr.DynArr, z, x.typ);
      z.op1 := x; z.op2 := OCH.TypeSize(x, x.typ);
      x := z;
    END;
    IF (Scr.trueLab # NIL) OR (Scr.falseLab # NIL) THEN	(* conditional *)
      NewFalseLab(fl, tl);
      Com.BranchFalse(y, fl);
      IF tl # NIL THEN Stat.Add(tl) END;
      y := Com.Const(1, Sym.booltyp);
      Com.Asgn(x, y);
      Com.NewLabel(el);
      Com.Bra(el.expr);
      Stat.Add(fl);
      y := Com.Const(0, Sym.booltyp);
      Com.Asgn(x, y);
      Stat.Add(el);
    ELSE
      Com.Asgn(x, y);
    END;
  ELSIF (x # NIL) & (x.typ.form IN {Sym.ProcStr, Sym.ProcTyp}) THEN
    Scr.ActualParameters(x);	(* checks if no parameters *)
    IF x.typ.form = Sym.ProcTyp THEN x := Com.Deref(x, Sym.procstr) END;
    Com.Call(x);
    Com.RestoreStack(x);
  ELSIF (x # NIL) & ~(x.typ.form IN {Sym.Undef, Sym.NoTyp}) THEN
    Err.Mark(procfunc);
  END
 END IdentStat;


PROCEDURE^ StatSeq;


PROCEDURE LoopStat();
  VAR
    fs, ls: Stat.Stat;
    x: Expr.Expr;
 BEGIN
  Scan.Get(Scr.sym);
  Com.NewLabel(fs); Stat.Add(fs);
  x := exitLabel;
  Com.NewLabel(ls); exitLabel := ls.expr;
  StatSeq;
  exitLabel := x;
  Com.BranchTo(fs.expr); Stat.Add(ls);
  Scr.CheckSym(end);
 END LoopStat;


PROCEDURE IfStat();
  VAR
    ls, es, bs: Stat.Stat;
    x : Expr.Expr;
 BEGIN
  Com.NewLabel(ls);		(* label at the end *)
  REPEAT
    Scan.Get(Scr.sym); Scr.Expression(x);
    NewFalseLab(es, bs);
    Com.BranchFalse(x, es);
    IF  NOT (x.typ.form IN {Bool, Def}) THEN Err.Mark(boolonly) END;
    Scr.CheckSym(then);
    IF bs # NIL THEN Stat.Add(bs) END;
    StatSeq;
    Com.BranchTo(ls.expr);
    Stat.Add(es);
  UNTIL Scr.sym # elsif;
  IF Scr.sym = else THEN Scan.Get(Scr.sym); StatSeq END;
  Stat.Add(ls);
  Scr.CheckSym(end);
 END IfStat;


PROCEDURE WithStat();
  VAR
    x, y : Expr.Expr;
    xtyp, ntyp : Sym.Struct;
    ls, es: Stat.Stat;
    obj: Sym.Symbol;

  PROCEDURE SetType(obj: Sym.Symbol; typ: Sym.Struct; VAR old: Sym.Struct);
   BEGIN
    IF typ.form = Sym.Record THEN
      IF obj.typ.base.form = Sym.Record THEN
        old := obj.typ.base; obj.typ.base := typ
      ELSE
        old := obj.typ.base.base; obj.typ.base.base := typ
      END;
    ELSE
      IF obj.typ.base.form = Sym.Record THEN
        old := obj.typ; obj.typ := typ
      ELSE
        old := obj.typ.base; obj.typ.base := typ
      END;
    END;
   END SetType;

 BEGIN
  Com.NewLabel(ls);		(* label at the end *)
  REPEAT
    Com.NewLabel(es);	(* label at next | *)
    xtyp := NIL;
    Scan.Get(Scr.sym);
    IF Scr.sym = ident THEN
      Scr.qualident(x); y := x;
      WHILE y.form # Expr.Sym DO
        IF y.form = Expr.Deref THEN y := y.op1
        ELSIF y.form = Expr.Deref THEN y := y.op2
        ELSE Err.Mark(ident); RETURN	(* prevent endless loop *)
        END;
      END;
      obj := y.sym;
      IF Scr.sym = colon THEN
        y := x;
        Scr.GetIsExpr(y, ntyp);
        SetType(obj, ntyp, xtyp);
        Com.BranchFalse(y, es);
      ELSE
        Err.Mark(colon)
      END;
    ELSE
      Err.Mark(ident)
    END;
    IF NOT (y.typ.form IN {Bool, Def}) THEN Err.Mark(boolonly) END;
    Scr.CheckSym(do);
    StatSeq;
    Com.BranchTo(ls.expr);
    Stat.Add(es);
    IF xtyp # NIL THEN SetType(obj, xtyp, ntyp) END;
  UNTIL Scr.sym # bar;
  IF Scr.sym = else THEN
    Scan.Get(Scr.sym); StatSeq
  ELSE
    Com.Call(Com.SysWithFail);
  END;
  Stat.Add(ls);
  Scr.CheckSym(end);
 END WithStat;


PROCEDURE RepStat();
  VAR
    ls, fs, es: Stat.Stat;
    x : Expr.Expr;
 BEGIN
  Scan.Get(Scr.sym);
  Com.NewLabel(fs); Stat.Add(fs);
  StatSeq;
  Scr.CheckSym(until);
  Scr.Expression(x);
  IF NOT (x.typ.form IN {Bool, Def}) THEN Err.Mark(boolonly) END;
  NewFalseLab(es, ls);
  Com.BranchFalse(x, es);
  fs.expr := es.expr;
  IF ls # NIL THEN Stat.Add(ls) END;
 END RepStat;


PROCEDURE WhileStat();
  VAR
    ls, fs, bs: Stat.Stat;
    x : Expr.Expr;
 BEGIN
  Scan.Get(Scr.sym);
  Com.NewLabel(fs); Stat.Add(fs);
  Scr.Expression(x); Scr.CheckSym(do);
  NewFalseLab(ls, bs);
  Com.BranchFalse(x, ls);
  IF bs # NIL THEN Stat.Add(bs) END;
  IF NOT (x.typ.form IN {Bool, Def}) THEN Err.Mark(boolonly) END;
  StatSeq;
  Scr.CheckSym(end);
  Com.BranchTo(fs.expr);
  Stat.Add(ls);
 END WhileStat;


PROCEDURE ExitStat();
 BEGIN
  Scan.Get(Scr.sym);
  Com.BranchTo(exitLabel);
 END ExitStat;


PROCEDURE ForStat();
  VAR
    inc: Stat.Stat;
    vari, endVal, cmp: Expr.Expr;
    step: LONGINT;
    fs, ls: Stat.Stat;
 BEGIN
  Scan.Get(Scr.sym);
  IF Scr.sym # ident THEN Err.Mark(ident);
  ELSE
    IdentStat();
    IF (Stat.insert.prev.form # Stat.Asgn) THEN
      Err.Mark(assign); RETURN;
    END;
    vari := Stat.insert.prev.expr;
    IF (vari.form # Expr.Sym) OR (vari.sym.form # Sym.Var) THEN
      Err.Mark(var)
    END;
    IF NOT (vari.typ.form IN IntTypes+{Def}) THEN
      Err.Mark(intonly);
    END;
    Com.NewLabel(fs); Stat.Add(fs); Com.NewLabel(ls);
    Scr.CheckSym(to);
    Scr.Expression(endVal);
    OCH.AssnCompatible(vari.typ, endVal);
    IF Scr.sym = by THEN
      Scan.Get(Scr.sym);
      Scr.IntConstExpression(step);
    ELSE
      step := 1
    END;
    Scr.CheckSym(do);
    Expr.New(Expr.Cmp, cmp, Sym.booltyp);
    cmp.op1 := Expr.Copy(vari); cmp.op2 := endVal;
    IF step >= 0 THEN cmp.a0 := gtr ELSE cmp.a0 := lss END;
    Com.BranchTrue(cmp, ls);
    StatSeq; Scr.CheckSym(end);
    Com.Asgn( Expr.Copy(vari),
        Com.Add( Expr.Copy(vari), Com.Const( step, vari.typ) ) );
    Com.BranchTo(fs.expr);
    Stat.Add(ls);
  END;
 END ForStat;


PROCEDURE CaseStat();
  CONST
    TableSize = 1000;
  VAR
    f, i : INTEGER;
    x, sel, sub, mul, deref: Expr.Expr;
    from, to, min, max, oldmin: LONGINT;
    tl, cl, fl, el, sl, fcl: Stat.Stat;
    table: ARRAY TableSize OF Expr.Expr;

  PROCEDURE ClearTable(from, to: INTEGER);
    VAR
      i : INTEGER;
   BEGIN
    FOR i := from TO to DO table[i] := fl.expr END;
   END ClearTable;

  PROCEDURE Enter;
    VAR
      h: LONGINT;
      i, j : INTEGER;
   BEGIN
    IF from > to THEN
      h := from; from := to; to := h;
    END;
    oldmin := min;
    IF from < min THEN min := from END;
    IF to > max THEN max := to END;
    IF max - min >= TableSize THEN
      Err.Mark(casesize);
      max := min + TableSize - 1;
      IF to > max THEN to := max END;
    END;
    IF min # oldmin THEN	(* shift table to min = 0 *)
      IF oldmin - min >= TableSize THEN
        ClearTable(0, TableSize-1)
      ELSE
        i := TableSize - SHORT(oldmin - min);
        j := TableSize;
        REPEAT
          DEC(i); DEC(j);
          table[j] := table[i];
        UNTIL i = 0;
        ClearTable(0, SHORT( oldmin - min) - 1);
      END;
    END;
    DEC(from, min); DEC(to, min);
    FOR i := SHORT( from) TO SHORT( to) DO
      table[i] := cl.expr;
    END;
   END Enter;

 BEGIN
  Scan.Get(Scr.sym);
  Scr.Expression(sel);
  f := sel.typ.form;
  IF f = String THEN OCH.StringToChar(sel);
  ELSIF ~ (f IN {SInt, Int, LInt, Char, Bool}) THEN
    Err.Mark(intonly)
  END;
  Scr.CheckSym(of);
  Com.NewLabel(tl); Com.NewLabel(fl); Com.NewLabel(el); Com.NewLabel(sl);
  Com.BranchTo(sl.expr);
  ClearTable(0, TableSize-1);
  min := MAX(LONGINT); max := MIN(LONGINT);
  fcl := NIL;
  LOOP
    IF Scr.sym = bar THEN Scan.Get(Scr.sym) END;
    Com.NewLabel(cl);
    IF fcl = NIL THEN fcl := cl END;
    LOOP
      Scr.CaseConstExpression(f, from);
      IF Scr.sym = upto THEN
        Scan.Get(Scr.sym);
        Scr.CaseConstExpression(f, to);
      ELSE
        to := from;
      END;
      Enter;
      IF Scr.sym = comma THEN Scan.Get(Scr.sym) ELSE EXIT END;
    END;
    Scr.CheckSym(colon);
    Stat.Add(cl);
    StatSeq;
    Com.BranchTo(el.expr);
    IF Scr.sym # bar THEN EXIT END;
    Scan.Get(Scr.sym);
    IF (Scr.sym = end) OR (Scr.sym = else) THEN EXIT END;
  END;
  Stat.Add(fl);
  IF Scr.sym = else THEN
    Scan.Get(Scr.sym); StatSeq;
  ELSE
    Com.Call(Com.SysCaseFail);
  END;
  Com.BranchTo(el.expr);
  Stat.Add(sl);
  Com.BranchTrue(
    Com.Cmp(sel, Com.Const( max, sel.typ), gtr),
    fl);  	(* greater than max *)
  sub := Com.Dn(2, sel.typ);
  Com.Asgn( sub, Com.Sub(sel, Com.Const( min, sel.typ) ) );
  Com.BranchTrue(
    Com.Cmp(sub, Com.Const( 0, sel.typ), lss),
    fl);	(* less than min *)
  IF sub.typ.size = 1 THEN
    sub := Com.Long(sub, Sym.inttyp)
  END;
  mul := Com.Mul( sub, Com.Const( 2, sel.typ) );
  deref := Com.Disp( tl.expr, mul, Sym.inttyp);
  Com.Bra( Com.Disp( fcl.expr, deref, Sym.ptrtyp) );
  Com.Base(fcl.expr);
  Stat.Add(tl);
  i := 0; f := SHORT( max - min);
  WHILE i <= f DO
    Com.Dcw(table[i]); INC(i);
  END;
  Scr.CheckSym(end);
  Stat.Add(el);
 END CaseStat;


PROCEDURE ReturnStat*();
  VAR
    x: Expr.Expr;
    i: INTEGER;
    fl, tl: Stat.Stat;
 BEGIN
  Scan.Get(Scr.sym); x := NIL;
  i := Stat.psx-1;
  WHILE Scr.sym = arrow DO
    IF ~Par.ext THEN Err.Mark(ext2only) END;
    DEC(i);
    IF i < 0 THEN Err.Mark(nomoreret); i := 0 END;
    Scan.Get(Scr.sym);
  END;
  IF (Scr.sym < semicolon) THEN
    Scr.Expression(x);
    IF (i # 0) & (Stat.procStack[i].typ.form # NoTyp) THEN
      OCH.AssnCompatible(Stat.procStack[i].typ, x);
    ELSE
      Err.Mark(noreturn)
    END;
  ELSIF ~Scan.inAss & (i # 0) & (Stat.procStack[i].typ.form # NoTyp) THEN
    Err.Mark(return)
  END;
  IF (Scr.trueLab # NIL) OR (Scr.falseLab # NIL) THEN	(* conditional *)
    NewFalseLab(fl, tl);
    Com.BranchFalse(x, fl);
    IF tl # NIL THEN Stat.Add(tl) END;
    x := Com.Const(1, Sym.booltyp);
    Com.RetStat(Stat.procStack[i], x, i);
    Stat.Add(fl);
    x := Com.Const(0, Sym.booltyp);
  END;
  Com.RetStat(Stat.procStack[i], x, i);
 END ReturnStat;


PROCEDURE CallStatProc;
  VAR
    proc: Sym.Symbol;
    x   : Expr.Expr;
 BEGIN
  IF Par.statProc # "" THEN
    COPY(Par.statProc, Scan.name);
    IF Sym.Search(proc) & (proc.form = Sym.LProc) THEN
      Expr.New( Expr.Sym, x, Sym.procstr); x.sym := proc;
      Com.StoreStack(x);
      Com.Push( Com.Const(Par.position-Par.source, Sym.linttyp) );
      Com.Call(x);
      Com.RestoreStack(x);
    ELSE
      IO.WriteString( "Did not find procedure ");
      IO.WriteString( Par.statProc);
      IO.WriteString( ". No call done."); IO.WriteLn;
    END;
  END;
 END CallStatProc;


PROCEDURE StatSeq;
  VAR
    empty: BOOLEAN;
 BEGIN
  LOOP
    IF Scr.sym < ident THEN
      Err.Mark(statexp);
      REPEAT Scan.Get(Scr.sym) UNTIL Scr.sym >= ident;
    END;
    empty := FALSE;
    IF Scr.sym = ident THEN IdentStat();
    ELSIF Scr.sym = loop THEN LoopStat();
    ELSIF Scr.sym = if THEN IfStat();
    ELSIF Scr.sym = repeat THEN RepStat();
    ELSIF Scr.sym = while THEN WhileStat();
    ELSIF Scr.sym = exit THEN ExitStat();
    ELSIF Scr.sym = for THEN ForStat();
    ELSIF Scr.sym = case THEN CaseStat();
    ELSIF Scr.sym = with THEN WithStat();
    ELSIF Scr.sym = return THEN ReturnStat();
    ELSIF Scr.sym = assembler THEN AssemblerCode();
    ELSE
      empty := TRUE;
    END;
    IF ~empty THEN CallStatProc END;
    IF Scr.sym = semicolon THEN
      Scan.Get(Scr.sym)
    ELSIF (Scr.sym <= ident) OR (if <= Scr.sym) & (Scr.sym <= return) THEN
      Err.Mark(semicolon)
    ELSE EXIT
    END
  END;
 END StatSeq;


PROCEDURE ScanStats*(begStat: Stat.Stat);
(*
 Scan the statements of symbol and store them after begStat.
 *)
  VAR
    symbol: Sym.Symbol;
    firstNewStat: Stat.Stat;
 BEGIN
  Stat.Environment(begStat, symbol, firstNewStat);
  IF symbol.first # -1 THEN		(* has statements *)
    S.GET( S.ADR( symbol.first), Par.position);
    Scan.Read( Scan.ch); Scan.Get( Scr.sym);
    Stat.insert := begStat.next;
    CallStatProc;
    Com.varpos := SHORT( begStat.a0);
    symbols := symbol.syms;
    StatSeq;
    begStat.a0 := Com.varpos;
    OCH.CheckUndefForward;
    Scr.CheckSym(end);
    IF Scr.sym # ident THEN Err.Mark(ident)
    ELSIF Scan.name # symbol.name THEN Err.Mark(idmatch)
    END;
  END;
 END ScanStats;


BEGIN
  Scr.StandProcCall := StandProcCall;
END OCStatScan.