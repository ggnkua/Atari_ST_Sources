MODULE OCH2; (* SJ 24.9.94 *)


IMPORT
  S:=SYSTEM, Sym:=OCSymbol, Expr:=OCExpr, Err:=OCErr, Scan:=OCScan,
  Com:=OCCom, Stat:=OCStat, Par:=OCPar, Strings, IO, NumStr;



CONST
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
  OpenArr=Sym.OpenArr; Record=Sym.Record; ProcStr=Sym.ProcStr;
  TbpStr = Sym.TbpStr;

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
  morepar = 133; needlen = 134; funcproc = 135; noptr = 145;
  guardtyp = 148; guardwrong = 149; nobasetyp = 150;
  parerr = 164; assread = 165; inxrange = 126; realonly = 152;
  strchar = 192; fieldexp = 193;

  IntTypes = {SInt, Int, LInt}; RealTypes = {Real, LReal};



PROCEDURE TD*(x: Expr.Expr) : Expr.Expr;
  VAR
    typ: Sym.Struct;
 BEGIN
  IF (x.form = Expr.Deref) & (x.op1.form = Expr.Sym)
       & (x.op1.sym.form = Sym.Ind) & (x.typ.form = Record) THEN
    x := Expr.Copy(x); x.op1 := Expr.Copy(x.op1);
    RETURN Com.Disp( x.op1, Com.Const( Sym.PtrSize, Sym.sinttyp), Sym.ptrtyp);
  ELSIF x.typ.form = Record THEN
    RETURN Com.ACon( Com.TD(x.typ) );
  ELSE
    typ := x.typ;
    x := Expr.Copy(x);
    IF x.form >= Expr.FSingle THEN
      x.op1 := Expr.Copy(x.op1);
      IF x.op1.form >= Expr.FSingle THEN
        x.op1.op1 := Expr.Copy(x.op1.op1);
      END;
    END;
    WHILE typ.form = Pointer DO
      x := Com.Deref(x, Sym.ptrtyp); typ := typ.base;
    END;
    RETURN Com.Disp( x, Com.Const(-Sym.PtrSize, Sym.sinttyp), Sym.ptrtyp);
  END;
 END TD;


PROCEDURE Deref*(VAR x : Expr.Expr);
  VAR
    e : Expr.Expr;
 BEGIN
  IF x.typ.form = Pointer THEN
    x := Com.Deref(x, x.typ.base);
  ELSE
    Err.Mark(noptr)
  END;
 END Deref;


PROCEDURE GetIntType*(val : LONGINT) : Sym.Struct;
(*
 sets the integer type according to the value val.
 *)
 BEGIN
  IF (MIN(SHORTINT) <= val) & (val <= MAX(SHORTINT)) THEN
    RETURN Sym.sinttyp
  ELSIF (MIN(INTEGER) <= val) & (val <= MAX(INTEGER)) THEN
    RETURN Sym.inttyp
  ELSE
    RETURN Sym.linttyp
  END
 END GetIntType;


PROCEDURE Field*(fld : Sym.Symbol; VAR x : Expr.Expr);
  VAR
    e : Expr.Expr;
    par : Sym.Symbol;
 BEGIN
  IF fld.form = Fld THEN
    x := Com.Disp(x, Com.Const(fld.a0, GetIntType(fld.a0) ), fld.typ );
  ELSIF fld.form # Def THEN
    Err.Mark(fieldexp)
  END;
 END Field;


PROCEDURE LongIndex*(typ: Sym.Struct) : BOOLEAN;
(*
 Return true if typ (form = Array, DynArr, OpenArr) needs a long word
 index.
 *)
 BEGIN
  RETURN (typ.form # Array) OR (typ.n > MAX(INTEGER))
 END LongIndex;


PROCEDURE Extend*(VAR op : Expr.Expr; typ : Sym.Struct);
  VAR
    ext : Expr.Expr;
 BEGIN
  op := Com.Long(op, typ);
 END Extend;


PROCEDURE ShortType*(typ : Sym.Struct) : Sym.Struct;
 BEGIN
  IF typ.form = Int THEN RETURN Sym.sinttyp
  ELSIF typ.form = LInt THEN RETURN Sym.inttyp
  ELSIF typ.form = Real THEN RETURN Sym.linttyp
  ELSIF typ.form = LReal THEN RETURN Sym.realtyp
  ELSE RETURN Sym.notyp
  END;
 END ShortType;


PROCEDURE LongType*(typ : Sym.Struct) : Sym.Struct;
 BEGIN
  IF typ.form = SInt THEN RETURN Sym.inttyp
  ELSIF typ.form = Int THEN RETURN Sym.linttyp
  ELSIF typ.form = LInt THEN RETURN Sym.realtyp
  ELSIF typ.form = Real THEN RETURN Sym.lrltyp
  ELSE RETURN Sym.notyp
  END;
 END LongType;


PROCEDURE Extend2*(VAR op : Expr.Expr; typ : Sym.Struct);
 BEGIN
  Extend(op, ShortType(typ));
  Extend(op, typ);
 END Extend2;


PROCEDURE Extend3*(VAR op : Expr.Expr; typ : Sym.Struct);
  VAR
    t : Sym.Struct;
 BEGIN
  t := ShortType(typ);
  Extend(op, ShortType(t));
  Extend(op, t);
  Extend(op, typ);
 END Extend3;


PROCEDURE Extend4*(VAR op : Expr.Expr; typ : Sym.Struct);
  VAR
    t1,t2 : Sym.Struct;
 BEGIN
  t1 := ShortType(typ);
  t2 := ShortType(t1);
  Extend(op, ShortType(t2) );
  Extend(op, t2);
  Extend(op, t1);
  Extend(op, typ);
 END Extend4;


PROCEDURE StringData*(x: Expr.Expr; VAR len: INTEGER; VAR ptr: Strings.ptr;
                      VAR offset: LONGINT);
(*
 Return the length, the address and the offset of the string defined by x.
 *)
 BEGIN
  WHILE x.form = Expr.Sym DO
    IF x.sym.form # Sym.Con THEN HALT(99) END;
    x := S.VAL( Expr.Expr, x.sym.a1);
  END;
  IF x.form = Expr.Con THEN
    ptr := S.VAL( Strings.ptr, x.a1);
    offset := x.a0;
    len := Strings.Length(ptr^) + 1;
  ELSE
    Err.Mark(Scan.string)
  END(*IF*);
 END StringData;


PROCEDURE StringToChar*(VAR x: Expr.Expr);
(*
 x.typ.form = String. If the string is has one character, convert x to a
 character. Else mark an error and produce a character expression.
 *)
  VAR
    len : INTEGER;
    ptr : Strings.ptr;
    off : LONGINT;
 BEGIN
  StringData(x, len, ptr, off);
  Expr.New( Expr.Con, x, Sym.chartyp);
  IF len = 2 THEN
    x.a0 := ORD( ptr[0] );
  ELSE
    Err.Mark(strchar);
    x.a0 := 20H;
  END;
 END StringToChar;


PROCEDURE FPar*(x: Expr.Expr) : Sym.Symbol;
(*
 Return the formal parameter list for the procedure defined by x. If it is
 no procedure, produce a new empty parameter list.
 *)
 BEGIN
  IF (x.form = Expr.Sym) & (x.sym.form IN {LProc, CProc, IProc, Sym.AProc})
      OR (x.typ.form = TbpStr) THEN
    IF x.sym.form = Sym.Def THEN RETURN NIL END;
    RETURN x.sym.syms.next;
  ELSIF x.typ.form = ProcTyp THEN
    RETURN x.typ.syms.next;
  END(*IF*);
  Err.Mark(Scan.procedure);
  RETURN NIL;
 END FPar;


PROCEDURE AssnCompatible*(desttyp : Sym.Struct; VAR src : Expr.Expr);
  (*
   * if src and dest have different types, src will be transformed
   * to the same type if possible. To use in assignments.
   *)
  VAR
    f : INTEGER;
    st, dt: Sym.Struct;
 BEGIN
  IF src # NIL THEN
    IF NOT Sym.SameType(desttyp, src.typ) THEN
      f := src.typ.form;
      CASE desttyp.form OF
        Byte:
          IF (f = String) THEN
            StringToChar(src);
          ELSIF NOT (f IN {Char, SInt}) THEN
            Err.Mark(incomp); src.typ := Sym.bytetyp;
          END;
      | Char:
          IF (f = String) THEN
            StringToChar(src);
          ELSIF f # Byte THEN
            Err.Mark(incomp); src.typ := Sym.chartyp;
          END;
      | SInt:
          IF f  # Byte THEN
            Err.Mark(incomp); src.typ := Sym.sinttyp;
          END;
      | Int:
          IF f = SInt THEN Extend(src, Sym.inttyp)
          ELSE Err.Mark(incomp); src.typ := Sym.inttyp;
          END;
      | LInt:
          IF f = SInt THEN Extend2(src, Sym.linttyp)
          ELSIF f = Int THEN Extend(src, Sym.linttyp)
          ELSIF (f # AnyPtr) OR NOT Par.ext THEN
            Err.Mark(incomp); src.typ := Sym.linttyp;
          END;
      | Real:
          IF f = SInt THEN Extend3(src, Sym.realtyp)
          ELSIF f = Int THEN Extend2(src, Sym.realtyp)
          ELSIF f = LInt THEN Extend(src, Sym.realtyp)
          ELSE Err.Mark(incomp); src.typ := Sym.realtyp;
          END;
      | LReal:
          CASE f OF
            SInt:  Extend4(src, Sym.lrltyp);
          | Int:   Extend3(src, Sym.lrltyp);
          | LInt:  Extend2(src, Sym.lrltyp);
          | Real:  Extend(src, Sym.lrltyp);
          ELSE
            Err.Mark(incomp); src.typ := Sym.lrltyp;
          END;
      | Pointer:
          IF Par.ext AND (f = SInt) THEN Extend2(src, Sym.linttyp)
          ELSIF Par.ext AND (f = Int) THEN Extend(src, Sym.linttyp)
          ELSIF f = Pointer THEN
            st := src.typ.base; dt := desttyp.base;
            IF (st.form = Record) AND (dt.form = Record) THEN
              WHILE (st # NIL) AND NOT Sym.SameType(st, dt) DO
                st := st.base;
              END;
              IF Par.ext AND (st = NIL) THEN
                st := src.typ.base;
                WHILE (dt # NIL) AND NOT Sym.SameType(dt, st) DO
                  dt := dt.base;
                END;
                st := dt;
              END;
            ELSE
              st := NIL
            END;
            IF st = NIL THEN
              Err.Mark(incomp); src.typ := Sym.linttyp;
            END;
          ELSIF ((f # LInt) OR NOT Par.ext) AND
                NOT (f IN {AnyPtr, NilTyp}) THEN
            Err.Mark(incomp); src.typ := Sym.linttyp;
          END;
      | AnyPtr:
          IF Par.ext AND (f = SInt) THEN Extend2(src, Sym.linttyp)
          ELSIF Par.ext AND (f = Int) THEN Extend(src, Sym.linttyp)
          ELSIF ((f # LInt) OR NOT Par.ext) AND
                NOT (f IN {AnyPtr, NilTyp, Pointer}) THEN
            Err.Mark(incomp); src.typ := Sym.linttyp;
          END;
      | Array, DynArr, OpenArr:
          IF (desttyp.base.form # Char) OR (f # String) THEN
            st := src.typ; dt := desttyp;
            WHILE (dt.form = DynArr) AND (st.form IN {Array, DynArr, OpenArr}) DO
              dt := dt.base; st := st.base;
            END;
            IF NOT Sym.SameType(dt, st) THEN
              Err.Mark(incomp); src.typ := desttyp;
            END;
          END;
      | ProcTyp:
          IF (f # NilTyp) & (f # AnyPtr) THEN
            IF src.typ.form IN {ProcTyp, ProcStr, TbpStr} THEN
              IF NOT Sym.SameSyms(desttyp.syms.next, FPar(src) ) OR
                 NOT Sym.SameType( desttyp.base, Com.RetTyp(src) ) THEN
                Err.Mark(incomp); src.typ := desttyp;
              END;
            ELSE
              Err.Mark(incomp); src.typ := desttyp;
            END;
          END;
      | Record:
          st := src.typ; dt := desttyp;
          IF (st.form = Record) THEN
            WHILE (st # NIL) AND NOT Sym.SameType(st, dt) DO
              st := st.base;
            END;
          ELSE
            st := NIL
          END;
          IF st = NIL THEN Err.Mark(incomp) END;
      ELSE
        Err.Mark(incomp); src.typ := desttyp;
      END;
    END;
  END;
 END AssnCompatible;


PROCEDURE CheckSameBase(typ1, typ2: Sym.Struct);
 BEGIN
  IF (typ1.form # Record) OR (typ2.form # Record) THEN
    Err.Mark(incomop)
  ELSE
    WHILE typ1.base # NIL DO typ1 := typ1.base END;
    WHILE typ2.base # NIL DO typ2 := typ2.base END;
    IF NOT Sym.SameType(typ1, typ2) THEN Err.Mark(nobasetyp) END;
  END;
 END CheckSameBase;


PROCEDURE CalcCompatible*(VAR op1,op2 : Expr.Expr; op : INTEGER);
  (*
   * if the operands have different types, one of them will be transformed
   * to the same type if possible. To use in calculations.
   * IF intOnly is true, real types will produce errors, if realOnly is
   * true, integer types will be converted to real.
   *)
  VAR
    f1, f2 : INTEGER;
 BEGIN
  IF (op1 # NIL) & (op2 # NIL) & ~Scan.inAss THEN
    IF op = slash THEN		(* only real allowed: extend *)
      CASE op1.typ.form OF
        SInt: Extend3(op1, Sym.realtyp);
      | Int:  Extend2(op1, Sym.realtyp);
      | LInt: Extend(op1, Sym.realtyp);
      | Real, LReal, Set:
      ELSE
        Err.Mark(realonly)
      END;
      CASE op2.typ.form OF
        SInt: Extend3(op2, Sym.realtyp);
      | Int:  Extend2(op2, Sym.realtyp);
      | LInt: Extend(op2, Sym.realtyp);
      | Real, LReal, Set:
      ELSE
        Err.Mark(realonly)
      END;
    ELSIF op IN {div, mod, andb, ior, xor} THEN(* only integer allowed *)
      IF NOT (op1.typ.form IN IntTypes) THEN
        Err.Mark(intonly); op1.typ := Sym.linttyp;
      END;
      IF NOT (op2.typ.form IN IntTypes) THEN
        Err.Mark(intonly); op2.typ := Sym.linttyp;
      END;
    ELSIF op IN {and,or} THEN		(* only boolean allowed *)
      IF op1.typ.form # Bool THEN
        Err.Mark(boolonly); op1.typ := Sym.booltyp;
      END;
      IF op2.typ.form # Bool THEN
        Err.Mark(boolonly); op2.typ := Sym.booltyp;
      END;
    END;
    IF (op IN {andb, ior, xor}) AND NOT Par.ext THEN
      Err.Mark(ext2only)
    END;
    f1 := op1.typ.form;
    IF NOT Sym.SameType(op1.typ, op2.typ) THEN
      f2 := op2.typ.form; f1 := op1.typ.form;
      CASE f1 OF
        Char:
          IF (f2 = String) THEN
            StringToChar(op2);
          ELSIF f2 # Byte THEN
            Err.Mark(incomop); op2.typ := op1.typ;
          END;
      | SInt, Byte:
          CASE f2 OF
            Byte, SInt:
          | Char:  IF ~(op IN {eql, neq}) THEN
                     Err.Mark(incomop); op2.typ := op1.typ;
                   END;
          | Int:   Extend(op1, Sym.inttyp);
          | LInt:  Extend2(op1, Sym.linttyp);
          | Real:  Extend3(op1, Sym.realtyp);
          | LReal: Extend4(op1, Sym.lrltyp);
          ELSE     Err.Mark(incomop); op2.typ := op1.typ;
          END;
      | Int:
          CASE f2 OF
            SInt, Byte:  Extend(op2, Sym.inttyp);
          | LInt:  Extend(op1, Sym.linttyp);
          | Real:  Extend2(op1, Sym.realtyp);
          | LReal: Extend3(op1, Sym.lrltyp);
          ELSE     Err.Mark(incomop); op2.typ := op1.typ;
          END;
      | LInt:
          CASE f2 OF
            SInt, Byte:  Extend2(op2, Sym.linttyp);
          | Int:   Extend(op2, Sym.linttyp);
          | Real:  Extend(op1, Sym.realtyp);
          | LReal: Extend2(op1, Sym.lrltyp);
          | AnyPtr:
          | NilTyp:IF NOT (op IN {eql, neq}) THEN
                     Err.Mark(incomop); op2.typ := op1.typ;
                   END;
          ELSE     Err.Mark(incomop); op2.typ := op1.typ;
          END;
      | Real:
          CASE f2 OF
            SInt, Byte:  Extend3(op2, Sym.realtyp);
          | Int:   Extend2(op2, Sym.realtyp);
          | LInt:  Extend(op2, Sym.realtyp);
          | LReal: Extend(op1, Sym.lrltyp);
          ELSE     Err.Mark(incomop); op2.typ := op1.typ;
          END;
      | LReal:
          CASE f2 OF
            SInt, Byte:  Extend4(op2, Sym.lrltyp);
          | Int:   Extend3(op2, Sym.lrltyp);
          | LInt:  Extend2(op2, Sym.lrltyp);
          | Real:  Extend(op2, Sym.lrltyp);
          ELSE     Err.Mark(incomop); op2.typ := op1.typ;
          END;
      | Array, DynArr, OpenArr, String:
          IF (f1 = String) AND (f2 = Char) THEN
            StringToChar(op1);
          ELSIF ((f1 = String) OR (f1 IN {Array, DynArr, OpenArr}) AND
             (op1.typ.base.form = Char)) AND
             ((f2 = String) OR (f2 IN {Array, DynArr, OpenArr}) AND
             (op2.typ.base.form = Char)) THEN	(* both strings *)
            IF NOT (op IN {eql..geq}) THEN
              Err.Mark(incomop);
              op1.typ := Sym.inttyp; op2.typ := Sym.inttyp;
            END;
          ELSE
            Err.Mark(incomop);
            op1.typ := Sym.inttyp; op2.typ := Sym.inttyp;
          END;
      | Pointer:
          IF NOT (f2 IN {NilTyp, AnyPtr}) THEN
            IF (f2 = Pointer) & (op IN {eql, neq}) THEN
              CheckSameBase(op1.typ.base, op2.typ.base)
            ELSE
              Err.Mark(incomop);
              op1.typ := Sym.linttyp; op2.typ := Sym.linttyp;
            END;
          END;
      | AnyPtr:
          IF (f2 IN {SInt, Int}) AND Expr.IsConst(op2) THEN
            IF f2 = SInt THEN Extend2(op2, Sym.linttyp)
            ELSE Extend(op2, Sym.linttyp)
            END;
          ELSIF NOT (f2 IN {LInt, NilTyp, AnyPtr, Pointer}) THEN
            Err.Mark(incomop);
            op1.typ := Sym.linttyp; op2.typ := Sym.linttyp;
          END;
      | ProcTyp:
          IF f2 # NilTyp THEN
            Err.Mark(incomop);
          END;
      ELSE
          Err.Mark(incomop);
          op1.typ := Sym.inttyp; op2.typ := Sym.inttyp;
      END;
    ELSIF (op IN {div..andb, ior..shr}) & ~(f1 IN {Byte}+IntTypes)
           OR (op = slash) & ~(f1 IN RealTypes+{Set})
           OR (op IN {plus, minus, times})
             & ~(f1 IN {Byte, Set, AnyPtr}+IntTypes+RealTypes)
           OR (op IN {lss..geq})
             & ~(f1 IN {AnyPtr,Char,Byte}+IntTypes+RealTypes)
             & (~(f1 IN {Array, DynArr, OpenArr}) OR (op1.typ.base.form # Char))
           OR (op IN {and, or}) & (f1 # Bool) THEN
      Err.Mark(nocalc)
    END;
  END;
 END CalcCompatible;


PROCEDURE DimNum(typ: Sym.Struct) : LONGINT;
  VAR
    num: LONGINT;
 BEGIN
  num := 0;
  WHILE typ.base.form IN {Array, DynArr, OpenArr} DO
    INC(num); typ := typ.base;
  END;
  RETURN num;
 END DimNum;


PROCEDURE SearchDimTyp(t: Sym.Struct; dim: INTEGER; VAR typ: Sym.Struct);
 BEGIN
  IF t.base.form = Array THEN
    SearchDimTyp(t.base, dim, typ);
  END;
  IF dim = 0 THEN typ := t END;
  DEC(dim);
 END SearchDimTyp;


PROCEDURE LenOfDim*(x: Expr.Expr; dim: INTEGER) : Expr.Expr;
  VAR
    typ: Sym.Struct;
    y  : Expr.Expr;
    len : INTEGER;
    ptr : Strings.ptr;
    off : LONGINT;
 BEGIN
  IF x.typ.form = DynArr THEN
    y := x;
    WHILE (y.form = Expr.Disp) OR (y.form = Expr.Deref) DO
      y := y.op1;		(* back to the root *)
    END;
    RETURN Com.Disp( y, Com.Const( (dim+1) * Sym.PtrSize, Sym.sinttyp),
      Sym.linttyp)
  ELSIF x.typ.form = OpenArr THEN
    y := x;
    WHILE (y.form = Expr.Disp) DO
      y := y.op1;		(* back to the root *)
    END;
    IF y.form # Expr.Deref THEN HALT(99) END;
    RETURN Com.Disp( y, Com.Const( - (dim+2) * Sym.PtrSize, Sym.sinttyp),
      Sym.linttyp)
  ELSIF x.typ.form = Array THEN
    SearchDimTyp(x.typ, dim, typ);
    RETURN Com.Const( typ.n, GetIntType(typ.n) );
  ELSIF x.typ.form = String THEN
    StringData(x, len, ptr, off);
    RETURN Com.Const( len, GetIntType(len) );
  ELSE
    RETURN Com.Const( 1, Sym.sinttyp);  (* must have been a syntax error *)
  END;
 END LenOfDim;


PROCEDURE TypeSize*(x: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
(*
 Return the size of typ with x any expression in the access path.
 *)
  VAR
    y  : Expr.Expr;
    len : INTEGER;
    ptr : Strings.ptr;
    off : LONGINT;
 BEGIN
  IF typ.form = DynArr THEN
    y := x;
    WHILE (y.form = Expr.Disp) OR (y.form = Expr.Deref) DO
      y := y.op1;		(* back to the root *)
    END;
    RETURN Com.Disp( y, Com.Mul(
      Com.Const( (DimNum(typ)+1) * Sym.PtrSize, Sym.sinttyp),
      TypeSize(y, typ.base)), Sym.linttyp);
  ELSIF typ.form = OpenArr THEN
    y := x;
    WHILE (y.form = Expr.Disp) DO
      y := y.op1;		(* back to the root *)
    END;
    IF y.form # Expr.Deref THEN HALT(99) END;
    RETURN Com.Disp( y, Com.Mul(
      Com.Const( - (DimNum(typ)+2) * Sym.PtrSize, Sym.sinttyp),
      TypeSize(y, typ.base)), Sym.linttyp);
  ELSIF typ.form = String THEN
    StringData(x, len, ptr, off);
    RETURN Com.Const(len, GetIntType(len) );
  ELSE
    RETURN Com.Const(typ.size, GetIntType(typ.size) );
  END;
 END TypeSize;


PROCEDURE LenOfArray*(x: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
(*
 Return the number of elements of typ with x any expression in the access
 path.
 *)
  VAR
    y  : Expr.Expr;
    len : INTEGER;
    ptr : Strings.ptr;
    off : LONGINT;
 BEGIN
  IF typ.form = DynArr THEN
    y := x;
    WHILE (y.form = Expr.Disp) OR (y.form = Expr.Deref) DO
      y := y.op1;		(* back to the root *)
    END;
    RETURN Com.Disp( y,
      Com.Const( (DimNum(typ)+1) * Sym.PtrSize, Sym.sinttyp), Sym.linttyp);
  ELSIF typ.form = OpenArr THEN
    y := x;
    WHILE (y.form = Expr.Disp) DO
      y := y.op1;		(* back to the root *)
    END;
    IF y.form # Expr.Deref THEN HALT(99) END;
    RETURN Com.Disp( y,
      Com.Const( - (DimNum(typ)+2) * Sym.PtrSize, Sym.sinttyp), Sym.linttyp);
  ELSIF typ.form = String THEN
    StringData(x, len, ptr, off);
    RETURN Com.Const(len, GetIntType(len) );
  ELSIF typ.form = Array THEN
    RETURN Com.Const(typ.n, GetIntType(typ.n) );
  ELSE
    RETURN Com.Const(typ.size, GetIntType(typ.size) );
  END;
 END LenOfArray;


PROCEDURE Index*(y : Expr.Expr; VAR x : Expr.Expr);
  VAR
    e, len : Expr.Expr;
    typ : Sym.Struct;
    val : LONGINT;
 BEGIN
  IF x.typ.form IN {Array, DynArr, OpenArr} THEN
    IF LongIndex(x.typ) THEN typ := Sym.linttyp
    ELSE typ := Sym.inttyp
    END;
    IF y.typ.size < typ.size THEN
      AssnCompatible(typ, y);
    ELSE
      typ := y.typ;
    END;
    IF (x.typ.form = Array) AND Expr.IsConst(y) THEN
      val := Expr.Evaluate(y);
      IF (val >= x.typ.n) OR (val < 0) THEN
        Err.Mark(inxrange);
      END;
      IF val = 0 THEN x.typ := x.typ.base; RETURN END;
    ELSIF Par.inxchk THEN
      len := LenOfArray(x, x.typ);
      len.typ := typ;
      y := Com.Check( y, Com.Sub( len, Com.Const(1, typ)));
    END;
    typ := x.typ.base;
    e := Com.Mul(y, TypeSize(x, typ) );
    x := Com.Disp( x, e, typ);
  ELSE
    Err.Mark(arrexp);
  END;
 END Index;


PROCEDURE TypeGuard*(x : Expr.Expr; typ : Sym.Struct);

  PROCEDURE CheckBase(typ1, typ2 : Sym.Struct);
    VAR
      pass: Stat.Stat;
      typ : Sym.Struct;
   BEGIN
    typ := typ2;
    IF NOT Sym.SameType(typ1, typ2) THEN
      CheckSameBase(typ1, typ2);
    END;
    IF Par.typchk THEN
      Com.NewLabel(pass);
      IF x.typ.form = Sym.Pointer THEN
        Com.BranchTrue( Com.Cmp( x, Com.Const(0, Sym.linttyp), eql), pass)
      END;
      Com.BranchTrue( Com.Cmp( Com.TD(typ),
          Com.Disp( Com.Deref( TD(x), Sym.ptrtyp ),
              Com.Const( Sym.TDBaseTyps + typ.n*Sym.PtrSize, Sym.sinttyp ),
              Sym.ptrtyp),
          eql ), pass );
      Com.Call(Com.SysTypeFail);
      Stat.Add(pass);
    END;
   END CheckBase;

 BEGIN
  IF (x.typ.form = Pointer) THEN
    IF (typ.form # Pointer) THEN
      Err.Mark(guardwrong)
    ELSE
      CheckBase(x.typ.base, typ.base);
    END;
  ELSIF (x.typ.form = Record) THEN
    IF (typ.form # Record) THEN
      Err.Mark(guardwrong)
    ELSE
      CheckBase(x.typ, typ);
    END;
  ELSE
    Err.Mark(guardtyp);
  END;
  x.typ := typ;
 END TypeGuard;


PROCEDURE SymTyp*(sym: Sym.Symbol) : Sym.Struct;
(*
 Return the type of sym. If it has no type, mark an error and return a
 default type.
 *)
 BEGIN
  CASE sym.form OF
    Sym.Def:
      RETURN Sym.undftyp;
  | Sym.LProc, Sym.SProc, Sym.CProc, Sym.AProc:
      RETURN Sym.procstr;
  | Sym.Tbp:
      RETURN Sym.tbpstr;
  | Sym.Var, Sym.Ind, Sym.Cpy, Sym.Fld, Sym.Typ, Sym.Con, Sym.Label:
      RETURN sym.typ;
  ELSE
      Err.Mark(Scan.type);
      RETURN Sym.undftyp;
  END(*CASE*);
 END SymTyp;


PROCEDURE CheckUndefPointer*;
(*
 Check the current symbol list for forward types and output them.
 *)
  VAR
    sym: Sym.Symbol;
 BEGIN
  sym := Sym.symbols.next;
  WHILE sym # NIL DO
    IF (sym.form = Typ) AND sym.forw THEN
      IO.WriteString("Forward defined type ");
      IO.WriteString(sym.name);
      IO.WriteString(" is not declared");
      IO.WriteLn;
      sym.forw := FALSE;
      Err.scanerr := TRUE;
    END;
    sym := sym.next;
  END(*WHILE*);
 END CheckUndefPointer;


PROCEDURE SetPtrBase*(ptyp, btyp: Sym.Struct);
 BEGIN
  IF btyp.form IN {Record, Array, DynArr, OpenArr} THEN
    ptyp.base := btyp
  ELSE
    ptyp.base := Sym.undftyp; Err.Mark(ptrbase)
  END
 END SetPtrBase;


PROCEDURE CompareParLists*(x, y: Sym.Symbol; ret1, ret2 : Sym.Struct);

  PROCEDURE Check() : BOOLEAN;
    VAR
      st, dt : Sym.Struct;
   BEGIN
    (* first parameter may be extension *)
    IF (x # NIL) AND (y # NIL) THEN
      IF x.typ.form = Pointer THEN
        IF y.typ.form # Pointer THEN RETURN FALSE END ;
        st := y.typ.base; dt := x.typ.base
      ELSE
        st := y.typ; dt := x.typ;
      END;
      IF (st.form = Record) AND (dt.form = Record) THEN
        WHILE (st # NIL) AND NOT Sym.SameType(st, dt) DO
          st := st.base;
        END;
        IF st # NIL THEN x := x.next; y := y.next END;
      END(*IF*);
    END(*IF*);

    WHILE (x # NIL) & (x.form # Sym.Sep) DO
      IF (y # NIL) & (y.form # Sym.Sep) THEN
        IF (x.form # y.form) OR NOT Sym.SameType(x.typ, y.typ) THEN
          RETURN FALSE
        END ;
        y := y.next
      ELSE
        RETURN FALSE
      END ;
      x := x.next
    END ;

    RETURN ((y = NIL) OR (y.form = Sym.Sep)) & Sym.SameType(ret1, ret2)
   END Check;

 BEGIN
  IF ~Check() THEN
    Err.Mark(parerr)
  END;
 END CompareParLists;


PROCEDURE GetRecordType*(t: Sym.Struct) : Sym.Struct;
 BEGIN
  WHILE t.form = Pointer DO t := t.base END;
  IF t.form # Record THEN
    Err.Mark(record);
    Sym.NewStr(Record, t); t.base := NIL;
    Sym.NewSym(Sym.Head, t.syms); t.syms.next := NIL;
    t.n := 0;
  END;
  RETURN t;
 END GetRecordType;


PROCEDURE SelfTyp*(typ: Sym.Struct) : Sym.Struct;
  VAR
    sym, typsym: Sym.Symbol;
 BEGIN
  typsym := Sym.global;
  WHILE typsym # NIL DO
    IF (typsym.form = Sym.Typ) & ((typ = typsym.typ)
          OR (typsym.typ.form = Sym.Pointer) & (typsym.typ.base = typ)) THEN
      sym := Sym.self.syms;
      WHILE sym # NIL DO
        IF (sym.form = Sym.Typ) & (sym.name = typsym.name) THEN
          IF sym.typ.form = Sym.Pointer THEN
            RETURN sym.typ.base;
          ELSIF sym.typ.form = Sym.Record THEN
            RETURN sym.typ;
          ELSE
            RETURN NIL;
          END;
        END;
        sym := sym.next
      END;
    END;
    typsym := typsym.next
  END;
  RETURN NIL;
 END SelfTyp;


PROCEDURE UnusedTbpNo(no: INTEGER; ftyp: Sym.Struct) : BOOLEAN;
  VAR
    sym, tsym: Sym.Symbol;
    typ: Sym.Struct;

  PROCEDURE CheckType(typ: Sym.Struct) : BOOLEAN;
    VAR
      sym: Sym.Symbol;
   BEGIN
    IF typ # NIL THEN
      REPEAT
        sym := typ.syms;
        WHILE sym # NIL DO
          IF (sym.form = Sym.Tbp) & (sym.a1 = no) THEN
            RETURN (sym.a0 >= 0) & (sym.name = "")
          END;
          sym := sym.next;
        END;
        typ := typ.base
      UNTIL typ = NIL;
    END;
    RETURN TRUE
   END CheckType;

 BEGIN
  IF CheckType(ftyp) THEN
    IF Sym.self # NIL THEN
      RETURN CheckType( SelfTyp(ftyp) );
    END;
    RETURN TRUE
  END;
  RETURN FALSE
 END UnusedTbpNo;


PROCEDURE GetBoundNo*(proc : Sym.Symbol; t : Sym.Struct) : INTEGER;
  VAR
    typ, ftyp : Sym.Struct;
    obj, sym : Sym.Symbol;
    tbpcnt: INTEGER;
 BEGIN
  t := GetRecordType(t);
  typ := t.base;
  WHILE typ # NIL DO
    IF typ.form = Record THEN
      obj := typ.syms;
      WHILE obj # NIL DO
        IF (obj.form = Tbp) THEN
          IF (obj.name = proc.name) THEN
            CompareParLists(obj.syms.next, proc.syms.next, obj.typ, proc.typ);
            RETURN SHORT(obj.a1);
          END;
        END;
        obj := obj.next;
      END;
      typ := typ.base;
    ELSE
      IF typ.form # Sym.Undef THEN
        Err.Mark(Scan.record)
      END;
      RETURN 1;
    END;
  END;

  IF Sym.self # NIL THEN
    ftyp := t;
    WHILE ftyp.form = Sym.Pointer DO ftyp := ftyp.base END;
    typ := SelfTyp(ftyp);
    IF (typ # NIL) & (typ.form = Sym.Record) THEN
      WHILE (typ # NIL) & (typ.n # ftyp.n) DO
        typ := typ.base
      END;
      COPY(proc.name, Scan.name);
      IF (typ # NIL) & Sym.SearchInList(typ.syms, sym)
          & (sym.form = Sym.Tbp) THEN
        RETURN SHORT( sym.a1);
      END;
    END;
  END;

  tbpcnt := -1;
  REPEAT
    INC(tbpcnt);
  UNTIL UnusedTbpNo(tbpcnt, t);
  RETURN tbpcnt;
 END GetBoundNo;


PROCEDURE Op*(op : INTEGER; VAR x: Expr.Expr; z: Expr.Expr);
 BEGIN
  CASE op OF
    times: x := Com.TwoOpExpr( Expr.Mul, z.typ, x, z);
  | slash: x := Com.TwoOpExpr( Expr.RDv, z.typ, x, z);
  | div:   x := Com.TwoOpExpr( Expr.Div, z.typ, x, z);
  | mod:   x := Com.TwoOpExpr( Expr.Mod, z.typ, x, z);
  | and:   x := Com.TwoOpExpr( Expr.And, z.typ, x, z);
  | plus:  x := Com.TwoOpExpr( Expr.Add, z.typ, x, z);
  | minus: x := Com.TwoOpExpr( Expr.Sub, z.typ, x, z);
  | or:    x := Com.TwoOpExpr( Expr.Or,  z.typ, x, z);
  | shl:   IF ~Par.ext THEN Err.Mark(ext2only) END;
           x := Com.TwoOpExpr( Expr.Lsh, x.typ, x, z);
  | shr:   IF ~Par.ext THEN Err.Mark(ext2only) END;
           x := Com.TwoOpExpr( Expr.Lsh, x.typ, x, Com.Neg(z) );
  END;
  IF Expr.IsConst(x) & ~Par.reass THEN  (* reason for this patch: *)
    x := Expr.EvaluateExpr(x);          (* const expression result could *)
    IF x.typ.form IN IntTypes THEN      (* be smaller than operands *)
      x.typ := GetIntType( x.a0);
    END;
  END;
 END Op;


PROCEDURE CheckUndefForward*;
  VAR
    sym: Sym.Symbol;
 BEGIN
  sym:= Sym.symbols.next;
  WHILE sym # NIL DO
    IF sym.forw & (sym.form # Sym.Def) THEN
      IO.WriteString("Forward defined object ");
      IO.WriteString(sym.name);
      IO.WriteString(" is not implemented");
      IO.WriteLn;
      Err.scanerr := TRUE;
    END;
    sym := sym.next;
  END;
 END CheckUndefForward;


END OCH2.