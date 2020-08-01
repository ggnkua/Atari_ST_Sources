MODULE OCAssembler; (* SJ 27.9.94 *)


IMPORT
  S:=SYSTEM, Stat:=OCStat, Expr:=OCExpr, Sym:=OCSymbol, Scan:=OCScan,
  Com:=OCCom, OCH:=OCH2, Par:=OCPar, Strings, IO;


CONST
  (* condition codes *)
  T* = 0; F* = 1; HI* = 2; LS* = 3; HS* = 4;
  LO* = 5; NE* = 6; EQ* = 7; VC* = 8; VS* = 9;
  PL* = 10; MI* = 11; GE* = 12; LT* = 13;
  GT* = 14; LE* = 15;
  FNE = -18; FEQ = -31; FGE = -13; FLT = -12;
  FGT = -14; FLE = -11;

  RealTypes = {Sym.Real, Sym.LReal};



VAR
  dest: Expr.Expr;
  procsym: Sym.Symbol;
  inAss: BOOLEAN;


(*$T- *)

PROCEDURE IsLabel*(x: Expr.Expr) : BOOLEAN;
 BEGIN
  RETURN (x.form = Expr.Sym) & (x.sym.form = Sym.Label);
 END IsLabel;


PROCEDURE ReplaceAss*(s: Stat.Stat; mnem: INTEGER; typ: Sym.Struct;
                      src, dest: Expr.Expr);
(*
 Replace s by an assembler statement with mnem as mnemonics and the size
 defined by typ. src and dest wil become expr and expr2.
 *)
  VAR
    size: INTEGER;
 BEGIN
  CASE typ.form OF
    Sym.Byte, Sym.Bool, Sym.Char, Sym.SInt:
      size := Stat.Byte;
  | Sym.Int:
      size := Stat.Word;
  | Sym.LInt, Sym.AnyPtr, Sym.Set, Sym.NilTyp, Sym.Pointer, Sym.ProcTyp,
    Sym.ProcStr:
      size := Stat.Long;
  | Sym.Real:
      size := Stat.Single;
  | Sym.LReal:
      size := Stat.Double;
  | Sym.NoTyp:
      size := Stat.NoSize;
  END;
  s.form := mnem; s.a0 := size;
  s.expr := src; s.expr2 := dest;
  (* error watchdog *)
  IF (mnem = Scan.lea) & (dest.form # Expr.An) THEN HALT(199) END;
 END ReplaceAss;


PROCEDURE InsertAss*(s: Stat.Stat; mnem: INTEGER; typ: Sym.Struct;
                     src, dest: Expr.Expr);
(*
 Insert a statement in front of s and make it an assembler statement with
 mnem as mnemonics and the size defined by typ. src and dest wil become
 expr and expr2.
 *)
  VAR
    stat: Stat.Stat;
 BEGIN
  Stat.New(Stat.Ass, stat);
  Com.Insert(stat, s);
  ReplaceAss(stat, mnem, typ, src, dest);
 END InsertAss;


PROCEDURE GetD0(VAR e: Expr.Expr);
(*
 Return a Dn expression with a register 0.
 *)
 BEGIN
  Expr.New(Expr.Dn, e, e.typ); e.a0 := 0; e.a1 := 1;
 END GetD0;


PROCEDURE GetD1(VAR e: Expr.Expr);
(*
 Return a Dn expression with register 1.
 *)
 BEGIN
  Expr.New(Expr.Dn, e, e.typ); e.a0 := 1; e.a1 := 1;
 END GetD1;


PROCEDURE GetD2(VAR e: Expr.Expr);
(*
 Return a Dn expression with register 1.
 *)
 BEGIN
  Expr.New(Expr.Dn, e, e.typ); e.a0 := 2; e.a1 := 1;
 END GetD2;


PROCEDURE GetA0(VAR e: Expr.Expr);
(*
 Return a An expression with register 0.
 *)
 BEGIN
  Expr.New(Expr.An, e, e.typ); e.a0 := 0; e.a1 := 1;
 END GetA0;


PROCEDURE GetFP0(VAR e: Expr.Expr);
(*
 Return a FPn expression with register 0.
 *)
 BEGIN
  Expr.New(Expr.FPn, e, e.typ); e.a0 := 0; e.a1 := 1;
 END GetFP0;


PROCEDURE LoadDestOrD0(s: Stat.Stat; e2: Expr.Expr; VAR e: Expr.Expr);
  VAR
    x: Expr.Expr;
 BEGIN
  IF (dest # NIL) & (dest.form = Expr.Dn)
      & ((e2 = NIL) OR (e2.form # Expr.Dn) OR (e2.a0 # dest.a0)) THEN
    InsertAss(s, Scan.move, e.typ, e, dest);
    x := Expr.Copy(dest);
    x.typ := e.typ; e := x;
  ELSE
    x := e; GetD0(x);
    InsertAss(s, Scan.move, e.typ, e, x);
    e := x;
  END;
 END LoadDestOrD0;


PROCEDURE LoadD0(s: Stat.Stat; e2: Expr.Expr; VAR e: Expr.Expr);
(*
 If dest is a Dn expression, load e into that register. Else if e is a
 changeable Dn expression, keep it. Else load it into D0.
 *)
 BEGIN
  IF (e.form # Expr.Dn) OR (e.a1 # 1) THEN	(* is not in changeable Dn *)
    LoadDestOrD0(s, e2, e);
  END;
 END LoadD0;


PROCEDURE LoadD0Unchg(s: Stat.Stat; e2: Expr.Expr; VAR e: Expr.Expr);
(*
 If dest is a Dn expression, load e into that register. Else if e is a
 Dn expression, keep it. Else load it into D0.
 *)
 BEGIN
  IF (e.form # Expr.Dn) THEN	(* is not in Dn *)
    LoadDestOrD0(s, e2, e);
  END;
 END LoadD0Unchg;


PROCEDURE SetD0(VAR e: Expr.Expr);
(*
 If dest is a Dn expression, return that register. Else if e is a
 changeable Dn expression, keep it. Else return D0.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  IF (e.form # Expr.Dn) OR (e.a1 # 1) THEN
    IF (dest # NIL) & (dest.form = Expr.Dn) THEN
      x := Expr.Copy(dest);
      x.typ := e.typ; e := x;
    ELSE
      GetD0(e);
    END;
  END;
 END SetD0;


PROCEDURE LoadD1(s: Stat.Stat; VAR e: Expr.Expr);
(*
 If e is a changeable Dn expression, keep it. Else load it into D1.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  IF (e.form # Expr.Dn) OR (e.a1 # 1) THEN
    x := e; GetD1(x);
    InsertAss(s, Scan.move, e.typ, e, x);
    e := x;
  END;
 END LoadD1;


PROCEDURE LoadD1Unchg(s: Stat.Stat; VAR e: Expr.Expr);
(*
 If e is a Dn expression, keep it. Else load it into D1.
 *)
 BEGIN
  IF (e.form # Expr.Dn) THEN	(* is not in Dn *)
    LoadD1(s, e);
  END;
 END LoadD1Unchg;


PROCEDURE LoadA0(s: Stat.Stat; VAR e: Expr.Expr);
(*
 If dest is an An expression, load e into that register. Else if e is a
 changeable An expression, keep it. Else load it into A0.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  IF (e.form # Expr.An) (*OR (e.a1 # 1)*) THEN
    IF (dest # NIL) & (dest.form = Expr.An) THEN
      InsertAss(s, Scan.move, e.typ, e, dest);
      x := Expr.Copy(dest);
      x.typ := e.typ; e := x;
    ELSE
      x := e; GetA0(x);
      InsertAss(s, Scan.move, e.typ, e, x);
      e := x;
    END;
  END;
 END LoadA0;


PROCEDURE SetA0(VAR e: Expr.Expr);
(*
 If dest is an An expression, return that register. Else if e is a
 changeable An expression, keep it. Else return A0.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  IF (e.form # Expr.An) OR (e.a1 # 1) THEN
    IF (dest # NIL) & (dest.form = Expr.An) THEN
      e := dest;
    ELSE
      GetA0(e);
    END;
  END;
 END SetA0;


PROCEDURE LoadDestOrFP0(s: Stat.Stat; e2: Expr.Expr; VAR e: Expr.Expr);
  VAR
    x: Expr.Expr;
 BEGIN
  IF (dest # NIL) & (dest.form = Expr.FPn)
      & ((e2 = NIL) OR (e2.form # Expr.FPn) OR (e2.a0 # dest.a0)) THEN
    InsertAss(s, Scan.fmove, e.typ, e, dest);
    x := Expr.Copy(dest);
    x.typ := e.typ; e := x;
  ELSE
    x := e; GetFP0(x);
    InsertAss(s, Scan.fmove, e.typ, e, x);
    e := x;
  END;
 END LoadDestOrFP0;


PROCEDURE LoadFP0(s: Stat.Stat; e2: Expr.Expr; VAR e: Expr.Expr);
(*
 If dest is a FPn expression, load e into that register. Else if e is a
 changeable FPn expression, keep it. Else load it into FP0.
 *)
 BEGIN
  IF (e.form # Expr.FPn) OR (e.a1 # 1) THEN
    LoadDestOrFP0(s, e2, e);
  END;
 END LoadFP0;


PROCEDURE LoadFP0Unchg(s: Stat.Stat; e2: Expr.Expr; VAR e: Expr.Expr);
(*
 If dest is an FPn expression, load e into that register. Else if e is an
 FPn expression, keep it. Else load it into FP0.
 *)
 BEGIN
  IF (e.form # Expr.FPn) THEN	(* is not in FPn *)
    LoadDestOrFP0(s, e2, e);
  END;
 END LoadFP0Unchg;


PROCEDURE OrderReg1(VAR op1, op2: Expr.Expr);
(*
 If op2 is a changeable data register expression, swap op1 and op2.
 *)
  VAR
    h: Expr.Expr;
 BEGIN
  IF ((op2.form = Expr.Dn) OR (op2.form = Expr.FPn)) & (op2.a1 = 1) THEN
    h := op1; op1 := op2; op2 := h;
  END;
 END OrderReg1;


PROCEDURE InsertACon*(VAR op: Expr.Expr);
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.ACon, x, op.typ);
  x.op1 := op; op := x;
 END InsertACon;


PROCEDURE NewLabel*(VAR lab: Stat.Stat);
 BEGIN
  Com.NewLabel(lab);
  lab.expr2 := NIL; lab.form := Scan.label;
  lab.a0 := Stat.NoSize;
 END NewLabel;


PROCEDURE^ Itemize(s: Stat.Stat; VAR x: Expr.Expr);


PROCEDURE InsertExpr(form: INTEGER; typ: Sym.Struct; x: Expr.Expr)
                      : Expr.Expr;
  VAR
    y: Expr.Expr;
 BEGIN
  Expr.New(form, y, typ);
  y.op1 := x;
  RETURN y;
 END InsertExpr;


PROCEDURE NegateConst*(VAR op: Expr.Expr);
 BEGIN
  IF op.form = Expr.Con THEN op.a0 := -op.a0
  ELSIF op.form = Expr.Neg THEN op := op.op1
  ELSE op := InsertExpr(Expr.Neg, op.typ, op)
  END;
 END NegateConst;


PROCEDURE Shift(s: Stat.Stat; VAR x: Expr.Expr; right, left: INTEGER);
  VAR
    e, h: Expr.Expr;
    lab, lab2 : Stat.Stat;
    val : LONGINT;
 BEGIN
  e := x;
  Itemize(s, e.op1); Itemize(s, e.op2);
  IF e.op2.form = Expr.ACon THEN
    val := Expr.Evaluate(e.op2);
    IF val >= 0 THEN	(* shift left *)
      IF val > 8 THEN LoadD1(s, e.op2) END;
      LoadD0(s, e.op2, e.op1);
      InsertAss(s, left, e.typ, e.op2, e.op1);
    ELSE
      NegateConst(e.op2.op1);
      IF val < -8 THEN LoadD1(s, e.op2) END;
      LoadD0(s, e.op2, e.op1);
      InsertAss(s, right, e.typ, e.op2, e.op1);
    END;
  ELSE
    NewLabel(lab); NewLabel(lab2);
    LoadD1(s, e.op2);
    LoadD0(s, e.op2, e.op1);
    InsertAss(s, Scan.tst, e.op2.typ, e.op2, NIL);
    InsertAss(s, Scan.bpl, Sym.sinttyp, lab.expr, NIL);
    InsertAss(s, Scan.neg, e.op2.typ, e.op2, NIL);
    InsertAss(s, right, e.op1.typ, e.op2, e.op1);
    InsertAss(s, Scan.bra, Sym.sinttyp, lab2.expr, NIL);
    InsertAss(s, Scan.label, Sym.notyp, lab.expr, NIL);
    InsertAss(s, left, e.op1.typ, e.op2, e.op1);
    InsertAss(s, Scan.label, Sym.notyp, lab2.expr, NIL);
  END;
  x := e.op1; x.typ := e.typ;
 END Shift;


PROCEDURE InvertedCond(coc: LONGINT) : INTEGER;
 BEGIN
  IF coc >= 0 THEN RETURN S.XOL( SHORT(coc), 1) END;
  CASE -coc OF	(* compiler error in V1.24 *)
    -FNE: RETURN FEQ;
  | -FEQ: RETURN FNE;
  | -FGE: RETURN FLT;
  | -FLT: RETURN FGE;
  | -FGT: RETURN FLE;
  | -FLE: RETURN FGT;
  END;
 END InvertedCond;


PROCEDURE TurnedCond(coc: LONGINT) : LONGINT;
 BEGIN
  IF coc >= 0 THEN
    CASE coc OF
      HI: RETURN LO
    | LS: RETURN HS
    | HS: RETURN LS
    | LO: RETURN HI
    | GE: RETURN LE
    | LT: RETURN GT
    | GT: RETURN LT
    | LE: RETURN GE
    ELSE  RETURN coc;
    END;
  END;
  CASE -coc OF	(* compiler error in V1.24 *)
    -FGE: RETURN FLE;
  | -FLT: RETURN FGT;
  | -FGT: RETURN FLT;
  | -FLE: RETURN FGE;
  ELSE    RETURN coc;
  END;
 END TurnedCond;


PROCEDURE MakeSolid(s: Stat.Stat; VAR x: Expr.Expr);
(*
 If x.form = Expr.Coc, make it a 0 for false and 1 for true.
 *)
  VAR
    h: Expr.Expr;
 BEGIN
  IF x.form = Expr.Coc THEN
    h := x; GetD0(h);
    IF x.a0 < 0 THEN
      InsertAss(s, Scan.fbf + SHORT( x.a0), Sym.notyp, h, NIL);
    ELSE
      InsertAss(s, Scan.st + SHORT( x.a0), Sym.notyp, h, NIL);
    END;
    InsertAss(s, Scan.neg, Sym.sinttyp, h, NIL);
    x := h;
  END;
 END MakeSolid;


PROCEDURE Itemized(s: Stat.Stat; x: Expr.Expr) : Expr.Expr;
 BEGIN
  Itemize(s, x); RETURN x;
 END Itemized;


PROCEDURE PostInc(x: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
  VAR
    y: Expr.Expr;
 BEGIN
  Expr.New( Expr.API, y, typ); y.op1 := x; RETURN y;
 END PostInc;


PROCEDURE CompareString(s: Stat.Stat; op1, op2: Expr.Expr);
  VAR
    stat, looplab, endlab, cmplab: Stat.Stat;
    src, dest: Expr.Expr;
    len: INTEGER;
    off: LONGINT;
    sp : Strings.ptr;
 BEGIN
  IF op2.typ.form = Sym.String THEN
    OCH.StringData(op2, len, sp, off);
    IF len = 1 THEN	(* "" *)
      InsertAss(s, Scan.cmpi, Sym.chartyp, Com.AConst( 0, Sym.chartyp),
          Itemized(s, op1));
      RETURN ;
    END;
  END;

  src := Com.An(0, Sym.linttyp); dest := Com.An(1, Sym.linttyp);
  InsertAss(s, Scan.move, Sym.linttyp, Itemized(s, Com.Adr(op2) ), dest);
  InsertAss(s, Scan.move, Sym.linttyp, Itemized(s, Com.Adr(op1) ), src);

  NewLabel(looplab); Stat.Insert(looplab, s);
  NewLabel(endlab); NewLabel(cmplab);
  InsertAss(s, Scan.tst, Sym.sinttyp,
      InsertExpr( Expr.ARI, Sym.sinttyp, src), NIL);
  InsertAss(s, Scan.bne, Sym.sinttyp, cmplab.expr, NIL);
  InsertAss(s, Scan.cmpm, Sym.sinttyp,
      PostInc( dest, Sym.sinttyp), PostInc(src, Sym.sinttyp) );
  InsertAss(s, Scan.bra, Sym.sinttyp, endlab.expr, NIL);
  Stat.Insert(cmplab, s);
  InsertAss(s, Scan.cmpm, Sym.sinttyp,
      PostInc( dest, Sym.sinttyp), PostInc(src, Sym.sinttyp) );
  InsertAss(s, Scan.beq, Sym.inttyp, looplab.expr, NIL);
  Stat.Insert(endlab, s);
 END CompareString;


PROCEDURE MakeCoc(s: Stat.Stat; VAR x: Expr.Expr);
(*
 If x.form # Expr.Coc, make it a Coc expression.
 *)
  VAR
    e: Expr.Expr;
 BEGIN
  e := x;
  IF e.form # Expr.Coc THEN
    IF Expr.IsConst(e) THEN
      IF Expr.Evaluate(e) = 1 THEN e.a0 := T
      ELSE e.a0 := F
      END;
      e.form := Expr.Coc;
    ELSE
      InsertAss(s, Scan.tst, e.typ, e, NIL);
      Expr.New(Expr.Coc, e, e.typ);
      e.a0 := NE;
    END;
  END;
  x := e;
 END MakeCoc;


PROCEDURE Itemize(s: Stat.Stat; VAR x: Expr.Expr);
(*
 Return an expression representing an assembler access to x.
 *)
  VAR
    e, h, h1, h2, op1, op2: Expr.Expr;
    lab, lab2 : Stat.Stat;
    typ, optyp: Sym.Struct;
    string: BOOLEAN;
 BEGIN
  e := x;
  IF e.form >= Expr.FSingle THEN optyp := e.op1.typ END;
  op1 := e.op1; op2 := e.op2;
  IF (e.form = Expr.Deref)
      & ((e.op1.form = Expr.ACon) OR (e.op1.form = Expr.Adr)) THEN
    IF e.op1.op1.typ.form # Sym.String THEN HALT(99) END;
    x := e.op1.op1; x.typ := e.typ; RETURN
  END;
  IF ~inAss & (e.form # Expr.ACon) & (e.form # Expr.Disp)
      & ~IsLabel(e) & Expr.IsConst(e) THEN
    IF e.form = Expr.Adr THEN e.form := Expr.ACon
    ELSE InsertACon(e);
    END;
  ELSE
    CASE e.form OF
      Expr.Neg:
        Itemize(s, op1);
        IF optyp.form IN RealTypes THEN
          LoadFP0(s, NIL, op1);
          InsertAss(s, Scan.fneg, optyp, op1, NIL);
        ELSE
          LoadD0(s, NIL, op1);
          InsertAss(s, Scan.neg, optyp, op1, NIL);
        END;
        e := op1;

    | Expr.Not:
        Itemize(s, op1);
        LoadD0(s, NIL, op1);
        InsertAss(s, Scan.eori, optyp, Com.AConst( 1, optyp), op1);
        e := op1;

    | Expr.Ntl:
        Itemize(s, op1);
        LoadD0(s, NIL, op1);
        InsertAss(s, Scan.notm, optyp, op1, NIL);
        e := op1;

    | Expr.Adr:
        Itemize(s, op1);
        IF op1.form = Expr.Deref THEN
          h := op1.op1; h.typ := e.typ;
        ELSIF op1.form = Expr.Sym THEN
          h := op1; InsertACon(h);
          h.typ := e.typ;
        ELSIF op1.form = Expr.ACon THEN
          h := op1;
          IF h.typ.form # Sym.String THEN HALT(99) END;
          h.typ := e.typ;
        ELSE
          h := e; SetA0(h);
          InsertAss(s, Scan.lea, e.typ, op1, h);
        END;
        e := h;

    | Expr.Long:
        Itemize(s, op1);
        IF e.typ.form IN RealTypes THEN
          LoadFP0(s, NIL, op1);
        ELSE
          LoadD0(s, NIL, op1);
          InsertAss(s, Scan.ext, e.typ, op1, NIL);
        END;
        e := op1; e.typ := x.typ;

    | Expr.Deref:
        IF op1.form = Expr.Adr THEN
          h := op1.op1; h.typ := e.typ; e := h;
          Itemize(s, e);
        ELSE
          Itemize(s, op1);
          IF op1.form = Expr.ACon THEN
            h := op1.op1; h.typ := e.typ;
          ELSE
            LoadA0(s, op1);
            Expr.New( Expr.ARI, h, e.typ); h.op1 := op1;
          END;
          e := h;
        END;

    | Expr.Mul:
        Itemize(s, op1); Itemize(s, op2);
        OrderReg1(op1, op2);
        IF optyp.form IN RealTypes THEN
          LoadFP0(s, op2, op1);
          InsertAss(s, Scan.fmul, optyp, op2, op1);
        ELSE
          LoadD0(s, op2, op1);
          IF optyp.form = Sym.Set THEN
            InsertAss(s, Scan.andm, optyp, op2, op1);
          ELSE
            InsertAss(s, Scan.muls, optyp, op2, op1);
          END;
        END;
        e := op1;

    | Expr.Div:
        Itemize(s, op1); Itemize(s, op2);
        LoadD0(s, op2, op1);
        IF optyp.size = 2 THEN
          InsertAss(s, Scan.ext, Sym.linttyp, op1, NIL)
        END;
        InsertAss(s, Scan.divs, optyp, op2, op1);
        e := op1;

    | Expr.Mod:
        Itemize(s, op1); Itemize(s, op2);
        IF optyp.form = Sym.LInt THEN
          h := e; SetD0(h); LoadD1(s, op1);
          Expr.New( Expr.DDn, h2, Sym.notyp);
          h2.op2 := op1; h2.op1 := h;
          InsertAss(s, Scan.divsl, Sym.linttyp, op2, h2);
          e := h;
        ELSE
          LoadD0(s, op2, op1);
          InsertAss(s, Scan.ext, Sym.linttyp, op1, NIL);
          InsertAss(s, Scan.divs, optyp, op2, op1);
          InsertAss(s, Scan.swap, Sym.linttyp, op1, NIL);
          e := op1;
        END;

    | Expr.Add:
        Itemize(s, op1); Itemize(s, op2);
        OrderReg1(op1, op2);
        IF optyp.form IN RealTypes THEN
          LoadFP0(s, op2, op1);
          InsertAss(s, Scan.fadd, optyp, op2, op1);
        ELSE
          LoadD0(s, op2, op1);
          IF optyp.form = Sym.Set THEN
            InsertAss(s, Scan.orm, optyp, op2, op1);
          ELSE
            InsertAss(s, Scan.add, optyp, op2, op1);
          END;
        END;
        e := op1;

    | Expr.Sub:
        Itemize(s, op1); Itemize(s, op2);
        IF optyp.form IN RealTypes THEN
          LoadFP0(s, op2, op1);
          InsertAss(s, Scan.fsub, optyp, op2, op1);
        ELSE
          LoadD0(s, op2, op1);
          IF e.op1.typ.form = Sym.Set THEN
            IF Expr.IsConst(op2) THEN
              Expr.New( Expr.Ntl, h, op2.typ);
              h.op1 := op2.op1; op2.op1 := h;
              InsertAss(s, Scan.andi, optyp, op2, op1);
            ELSE
              LoadD1(s, op2);
              InsertAss(s, Scan.notm, optyp, op2, NIL);
              InsertAss(s, Scan.andm, optyp, op2, op1);
            END;
          ELSE
            InsertAss(s, Scan.sub, optyp, op2, op1);
          END;
        END;
        e := op1;

    | Expr.RDv:
        Itemize(s, op1); Itemize(s, op2);
        IF optyp.form = Sym.Set THEN
          LoadD0(s, op2, op1);
          IF (op2.form = Expr.ACon) OR (op2.form = Expr.Imm) THEN
            InsertAss(s, Scan.eori, optyp, op2, op1);
          ELSE
            LoadD1(s, op2);
            InsertAss(s, Scan.eor, optyp, op2, op1);
          END;
        ELSE
          LoadFP0(s, op2, op1);
          InsertAss(s, Scan.fdiv, optyp, op2, op1);
        END;
        e := op1;

    | Expr.Anl:
        Itemize(s, op1); Itemize(s, op2);
        OrderReg1(op1, op2);
        LoadD0(s, op2, op1);
        InsertAss(s, Scan.andm, optyp, op2, op1);
        e := op1;

    | Expr.Orl:
        Itemize(s, op1); Itemize(s, op2);
        OrderReg1(op1, op2);
        LoadD0(s, op2, op1);
        InsertAss(s, Scan.orm, optyp, op2, op1);
        e := op1;

    | Expr.Xol:
        Itemize(s, op1); Itemize(s, op2);
        LoadD0(s, op2, op1);
        IF (op2.form = Expr.ACon) OR (op2.form = Expr.Imm) THEN
          InsertAss(s, Scan.eori, optyp, op2, op1);
        ELSE
          LoadD1(s, op2);
          InsertAss(s, Scan.eor, optyp, op2, op1);
        END;
        e := op1;

    | Expr.Lsh:
        Shift(s, e, Scan.lsr, Scan.lsl);

    | Expr.Ash:
        Shift(s, e, Scan.asr, Scan.asl);

    | Expr.Rot:
        Shift(s, e, Scan.ror, Scan.rol);

    | Expr.In:
        Itemize(s, op1); Itemize(s, op2);
        LoadD0Unchg(s, op1, op2);
        IF op1.form # Expr.ACon THEN LoadD1Unchg(s, op1) END;
        InsertAss(s, Scan.btst, optyp, op1, op2);
        Expr.New( Expr.Coc, e, e.typ);
        e.a0 := NE;

    | Expr.Asgn:
        Itemize(s, op1); Itemize(s, op2);
        MakeSolid(s, op2);
        InsertAss(s, Scan.move, op1.typ, op2, op1);
        e := op2;

    | Expr.Set:
        Itemize(s, op1);
        IF op2 # NIL THEN
          Itemize(s, op2);
          NewLabel(lab);
          LoadD0(s, op2, op1); LoadD1(s, op2);
          InsertAss( s, Scan.cmp, op1.typ, op1, op2);
          InsertAss( s, Scan.bhi, Sym.inttyp, lab.expr, NIL);
          InsertAss( s, Scan.exg, Sym.notyp, op1, op2);(* higher in op2 *)
          InsertAss(s, Scan.label, Sym.notyp, lab.expr, NIL);
          h := e; GetD2(h);
          InsertAss( s, Scan.move, Sym.linttyp, Com.AConst(-1, Sym.linttyp), h);
          InsertAss( s, Scan.lsl, Sym.linttyp, op1, h);	(* -1 << smaller *)
          InsertAss( s, Scan.move, Sym.linttyp, Com.AConst(-2, Sym.linttyp),op1);
          InsertAss( s, Scan.lsl, Sym.linttyp, op2, op1);(* -2 << higher *)
          InsertAss( s, Scan.eor, Sym.linttyp, h, op1);	(* result *)
          e := op1; e.typ := Sym.settyp;
        ELSE
          h := Com.AConst(0, Sym.settyp);
          LoadD0(s, op2, h);
          LoadD1Unchg(s, op1);
          InsertAss( s, Scan.bset, Sym.settyp, op1, h);
          e := h;
        END;

    | Expr.Cmp:
        string := (op2.typ.form IN {Sym.String, Sym.DynArr, Sym.OpenArr,
                   Sym.Array});
        IF ~string THEN
          Itemize(s, op1); Itemize(s, op2);
        END;
        h1 := op1; OrderReg1(op1, op2); h2 := op1;
        Expr.New( Expr.Coc, h, e.typ);
        IF op1.typ.form IN RealTypes THEN
          LoadFP0Unchg(s, op2, op1);
          InsertAss(s, Scan.fcmp, op1.typ, op2, op1);
          CASE e.a0 OF
            Scan.eql: h.a0 := FEQ
          | Scan.neq: h.a0 := FNE
          | Scan.lss: h.a0 := FLT
          | Scan.leq: h.a0 := FLE
          | Scan.gtr: h.a0 := FGT
          | Scan.geq: h.a0 := FGE
          END;
        ELSE
          IF string THEN
            CompareString(s, op1, op2);
          ELSE
            IF op1.form = Expr.An THEN
              InsertAss(s, Scan.cmpa, op1.typ, op2, op1);
            ELSIF Expr.IsConst(op2) THEN
              InsertAss(s, Scan.cmpi, op1.typ, op2, op1);
            ELSE
              LoadD0Unchg(s, op2, op1);
              InsertAss(s, Scan.cmp, op1.typ, op2, op1);
            END;
          END;
          CASE e.a0 OF
            Scan.eql: h.a0 := EQ
          | Scan.neq: h.a0 := NE
          | Scan.lss: h.a0 := LO
          | Scan.leq: h.a0 := LS
          | Scan.gtr: h.a0 := HI
          | Scan.geq: h.a0 := HS
          END;
          IF (op1.typ.form # Sym.Char) & (h.a0 < NE) THEN
            h.a0 := S.ORL( h.a0, 0CH);
          END;
        END;
        IF h2 # h1 THEN h.a0 := TurnedCond(h.a0) END;
        e := h;

    | Expr.Trunc:
        Itemize(s, op1); LoadFP0(s, NIL, op1);
        h := e; SetD0(h);
        InsertAss(s, Scan.fmove, Sym.linttyp, op1, h);
        e := h;

    | Expr.Entier:
        Itemize(s, op1); LoadFP0(s, NIL, op1);
        h := e; SetD0(h);
        InsertAss(s, Scan.fmove, Sym.linttyp, op1, h);
        e := h;

    | Expr.Abs:
        Itemize(s, op1);
        IF optyp.form IN RealTypes THEN
          LoadFP0(s, NIL, op1);
          InsertAss(s, Scan.fabs, optyp, op1, NIL);
        ELSE
          LoadD0(s, NIL, op1); NewLabel(lab);
          InsertAss(s, Scan.tst, optyp, op1, NIL);
          InsertAss(s, Scan.bpl, Sym.sinttyp, lab.expr, NIL);
          InsertAss(s, Scan.neg, optyp, op1, NIL);
          InsertAss(s, Scan.label, Sym.notyp, lab.expr, NIL);
        END;
        e := op1;

    | Expr.Cap:
        Itemize(s, op1); LoadD0(s, NIL, op1);
        NewLabel(lab);
        InsertAss(s, Scan.cmp, Sym.sinttyp, Com.AConst(61H, Sym.sinttyp), op1);
        InsertAss(s, Scan.blo, Sym.sinttyp, lab.expr, NIL);
        InsertAss(s, Scan.cmp, Sym.sinttyp, Com.AConst(7AH, Sym.sinttyp), op1);
        InsertAss(s, Scan.bhi, Sym.sinttyp, lab.expr, NIL);
        InsertAss(s, Scan.andm, Sym.sinttyp, Com.AConst(5FH, Sym.sinttyp), op1);
        InsertAss(s, Scan.label, Sym.notyp, lab.expr, NIL);
        e := op1;

    | Expr.Odd:
        Itemize(s, op1); LoadD0(s, NIL, op1);
        InsertAss(s, Scan.btst, Sym.linttyp, Com.AConst(0, Sym.inttyp), op1);
        Expr.New( Expr.Coc, e, e.typ);
        e.a0 := NE;

    | Expr.Chr:
        Itemize(s, op1); LoadD0(s, NIL, op1);
        e := op1; e.typ := Sym.chartyp;

    | Expr.Short:
        Itemize(s, op1);
        IF e.typ.form = Sym.Real THEN
          LoadFP0(s, NIL, op1); e := op1; e.typ := Sym.realtyp
        ELSE
          LoadD0(s, NIL, op1); h := e; e := op1; e.typ := h.typ;
        END;

    | Expr.ULong, Expr.Ord:
        Itemize(s, op1);
        h := e; SetD0(h);
        InsertAss(s, Scan.clr, Sym.linttyp, h, NIL);
        InsertAss(s, Scan.move, optyp, op1, h);
        e := h;

    | Expr.Bit:
        Itemize(s, op1); Itemize(s, op2);
        LoadD1Unchg(s, op2); LoadA0(s, op1);
        InsertAss(s, Scan.btst, Sym.sinttyp, op2,
            InsertExpr(Expr.ARI, Sym.sinttyp, op1) );
        Expr.New( Expr.Coc, e, e.typ);
        e.a0 := NE;

    | Expr.SP:
        e.form := Expr.An; e.a0 := 7;

    | Expr.Ret:
        IF e.typ.form IN RealTypes THEN
          e.form := Expr.FPn;
        ELSE
          e.form := Expr.Dn;
        END;
        e.a0 := 0;

    | Expr.Disp:
        IF ((op1.form = Expr.Sym) OR (op1.form = Expr.TD)) & Expr.IsConst(op2) THEN
          Expr.New( Expr.Add, e, e.typ);
          op2 := Com.ExtendTo(op2, Sym.linttyp);
          e.op1 := op1; e.op2 := op2;
          IF (op1.form = Expr.Sym) & (op1.sym.lev > 0)
              & (op1.sym.form # Sym.AProc) THEN
            e.typ := Sym.inttyp;
            e := Com.OneOpExpr( Expr.DA, x.typ,
              Com.TwoOpExpr( Expr.Disp, Sym.linttyp,
                Com.An(7 - op1.sym.lev, Sym.linttyp), e) );
          ELSIF (op1.form = Expr.Sym) & (op1.sym.lev = 0) THEN
            e.typ := Sym.linttyp;
          END;
        ELSE
          op1 := Com.Adr(op1);
          WHILE op1.form = Expr.Disp DO
            op2 := Com.Add( Com.ExtendTo(op1.op2, op2.typ),
                              Com.ExtendTo(op2, op1.op2.typ) );
            op1 := op1.op1;
          END;
          Expr.New( Expr.Disp, h2, e.typ);
          Itemize(s, op1); LoadA0(s, op1);
          h2.op1 := op1;
          IF ~Expr.IsConst(op2) THEN
            Itemize(s, op2); LoadD0Unchg(s, op1, op2);
            Expr.New( Expr.XReg, h, op2.typ);
            h.op1 := op2; h2.op2 := h;
            Expr.New( Expr.DAX, h, e.typ);
          ELSE
            h2.op2 := op2;
            Expr.New( Expr.DA, h, e.typ);
          END;
          h.op1 := h2; e := h;
        END;

    | Expr.Sym:
        IF (e.sym.lev > 0)
            & (e.sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy}) THEN
          typ := e.typ; e.typ := Sym.inttyp;
          e := InsertExpr( Expr.DA, typ, Com.Disp(
                 Com.An( 7-e.sym.lev, Sym.ptrtyp), Com.ACon(e), Sym.ptrtyp) );
          x.typ := typ;
        END;

    | Expr.Check:
        Itemize(s, op1); Itemize(s, op2);
        LoadD0(s, op2, op1);
        InsertAss(s, Scan.chk, op1.typ, op2, op1);
        e := op1;

    | Expr.PostInc:
        e.form := Expr.API

    | Expr.PreDec:
        e.form := Expr.APD

    | Expr.ACon:
        IF e.op1.form = Expr.Disp THEN e.op1.form := Expr.Add END;

    | Expr.Swap:
        Itemize(s, op1); LoadD0(s, NIL, op1);
        InsertAss(s, Scan.swap, Sym.notyp, op1, NIL);
        e := op1;

    | Expr.Coc:
        Itemize(s, op1); MakeCoc(s, op1);
        Expr.New( Expr.CCR, h, Sym.notyp);
        LoadD0(s, NIL, h);
        e := h;

    | Expr.DynArr:
        e := Itemized(s, e.op1);

    ELSE
    END;
  END;
  x := e;
 END Itemize;


PROCEDURE CopyString(VAR s: Stat.Stat; from, to: Expr.Expr);
  VAR
    stat, lab, lab2: Stat.Stat;
    ssize, dsize, src, dest: Expr.Expr;
    len: INTEGER;
    off: LONGINT;
    sp : Strings.ptr;
 BEGIN
  IF from.typ.form = Sym.String THEN
    OCH.StringData(from, len, sp, off);
    IF len = 1 THEN	(* "" *)
      ReplaceAss(s, Scan.move, Sym.chartyp, Com.AConst( 0, Sym.chartyp),
          Itemized(s, to));
      RETURN ;
    END;
  END;

  IF to.form = Expr.DynArr THEN
    dsize := to.op2; to := to.op1;
  ELSE
    dsize := OCH.TypeSize( to, to.typ);
  END;
(*  IF dsize.form # Expr.Con THEN Itemize( s, dsize);
  ELSE InsertACon(dsize);
  END;
  LoadD1(s, dsize);
  InsertAss(s, Scan.subq, dsize.typ, Com.AConst(1, dsize.typ), dsize);*)
  dsize := Com.Sub(dsize, Com.Const(1, Sym.sinttyp) );
  IF dsize.typ.size = 1 THEN
    dsize := Com.ExtendTo(dsize, Sym.inttyp)
  END;
  Itemize( s, dsize); LoadD1(s, dsize);

  src := Com.An(0, Sym.linttyp); dest := Com.An(1, Sym.linttyp);
  InsertAss(s, Scan.move, Sym.linttyp, Itemized(s, Com.Adr(to) ), dest);
  InsertAss(s, Scan.move, Sym.linttyp, Itemized(s, Com.Adr(from) ), src);

  NewLabel(lab); Stat.Insert(lab, s);
(*  NewLabel(lab2);*)
  InsertAss(s, Scan.move, Sym.sinttyp,
      PostInc( src, Sym.sinttyp), PostInc(dest, Sym.sinttyp) );
(*  InsertAss(s, Scan.beq, Sym.sinttyp, lab2.expr, NIL);
  InsertAss(s, Scan.subq, dsize.typ, Com.AConst(1, dsize.typ), dsize);
  InsertAss(s, Scan.bne, Sym.sinttyp, lab.expr, NIL);
  InsertAss(s, Scan.move, Sym.sinttyp,
     Com.AConst( 0, Sym.sinttyp), InsertExpr(Expr.ARI, Sym.sinttyp, dest) );
  Stat.Insert(lab2, s);*)
  InsertAss(s, Scan.dbeq, Sym.notyp, dsize, lab.expr);
  InsertAss(s, Scan.clr, Sym.sinttyp,
      InsertExpr(Expr.APD, Sym.sinttyp, dest), NIL );
  Stat.Remove(s);
 END CopyString;


PROCEDURE CopyDynArr(s: Stat.Stat; sym: Sym.Symbol);
  VAR
    from, to, x, y, size, sp, src, dest: Expr.Expr;
    lab1, lab2, oc: Stat.Stat;
 BEGIN
  IF Par.ccode THEN
    IF Par.reass THEN
      Stat.New( Stat.OutCtrl, oc); oc.a0 := Stat.OCInh;
      Stat.Insert(oc, s);
    END;
    NewLabel(lab1); NewLabel(lab2);
    Expr.New( Expr.Sym, x, sym.typ.base);
    x.sym := sym;
    Expr.New( Expr.Deref, from, sym.typ.base);
    from.op1 := x;
    size := OCH.TypeSize( from, from.typ);
    Itemize(s, x);
    Itemize(s, size); LoadD0(s, NIL, size);
    InsertAss(s, Scan.addq, Sym.linttyp, Com.AConst(1, Sym.notyp), size);
    InsertAss(s, Scan.btst, Sym.linttyp, Com.AConst(0, Sym.notyp), size);
    InsertAss(s, Scan.beq, Sym.sinttyp, lab1.expr, NIL);
    InsertAss(s, Scan.addq, Sym.linttyp, Com.AConst(1, Sym.notyp), size);
    Stat.Insert(lab1, s);
    Expr.New( Expr.SP, sp, sym.typ.base);
    InsertAss(s, Scan.suba, Sym.linttyp, size, sp);

    src := Com.An(0, Sym.linttyp); dest := Com.An(1, Sym.linttyp);
    InsertAss(s, Scan.move, Sym.linttyp, sp, dest);
    InsertAss(s, Scan.move, Sym.linttyp, x, src);

    Stat.Insert(lab2, s);
    InsertAss(s, Scan.move, Sym.sinttyp,
        PostInc( src, Sym.sinttyp), PostInc(dest, Sym.sinttyp) );
    InsertAss(s, Scan.subq, Sym.linttyp, Com.AConst(1, Sym.linttyp), size);
    InsertAss(s, Scan.bne, Sym.sinttyp, lab2.expr, NIL);

    InsertAss(s, Scan.move, Sym.linttyp, sp, x);

    IF Par.reass THEN
      Stat.New( Stat.OutCtrl, oc); oc.a0 := Stat.OCOut;
      Stat.Insert(oc, s);
    END;
  END;
 END CopyDynArr;


PROCEDURE AssignComplex(VAR s: Stat.Stat; from, to: Expr.Expr);
  VAR
    stat, lab: Stat.Stat;
    ssize, src, dest, scnt: Expr.Expr;
 BEGIN
  src := Com.An(0, Sym.linttyp); dest := Com.An(1, Sym.linttyp);
  InsertAss(s, Scan.move, Sym.linttyp, Itemized(s, Com.Adr(to) ), dest);
  InsertAss(s, Scan.move, Sym.linttyp, Itemized(s, Com.Adr(from) ), src);

  ssize := Com.ACon( OCH.TypeSize( to, to.typ) );
  scnt := Com.Dn(0, ssize.typ);
  InsertAss(s, Scan.move, ssize.typ, ssize, scnt);
  NewLabel(lab); Stat.Insert(lab, s);
  InsertAss(s, Scan.move, Sym.sinttyp,
      PostInc( src, Sym.sinttyp), PostInc(dest, Sym.sinttyp) );
  InsertAss(s, Scan.subq, ssize.typ, Com.AConst(1, ssize.typ), scnt);
  InsertAss(s, Scan.bne, Sym.inttyp, lab.expr, NIL);
  Stat.Remove(s);
 END AssignComplex;


PROCEDURE Assemble*(begin: Stat.Stat);
(*
 Produce assembler statements.
 *)
  VAR
    ass, s: Stat.Stat;
    sym: Sym.Symbol;
    typ: Sym.Struct;
 BEGIN
  Stat.Environment(begin, sym, s);
  procsym := sym.syms;
  s := begin;
  LOOP
    Stat.ReadOptions(s);
    IF (s = NIL) OR (s.form = Stat.End) THEN EXIT END;
    dest := NIL; Stat.insert := s;
    CASE s.form OF
      Stat.Asgn:
        IF (s.expr2.typ.form IN {Sym.String, Sym.DynArr, Sym.OpenArr})
            OR (s.expr.typ.form IN {Sym.DynArr, Sym.OpenArr})
            OR (s.expr.typ.form = Sym.Array)
               & ~Sym.SameType(s.expr.typ, s.expr2.typ) THEN
          CopyString(s, s.expr2, s.expr)
        ELSIF (s.expr.typ.form IN {Sym.Record, Sym.Array}) THEN
          AssignComplex(s, s.expr2, s.expr);
        ELSE
          dest := s.expr;
          IF (s.expr2.typ.form = Sym.ProcStr) THEN
            InsertACon(s.expr2); s.expr2.typ := Sym.ptrtyp;
          ELSE
            Itemize(s, s.expr2);
          END;
          Itemize(s, s.expr);
          dest := NIL;
          MakeSolid(s, s.expr2);
          IF s.expr.typ.form IN {Sym.Real, Sym.LReal} THEN
            typ := s.expr.typ
          ELSIF s.expr2.typ.form IN {Sym.Real, Sym.LReal} THEN
            typ := s.expr2.typ
          ELSE
            typ := NIL;
          END;
          IF typ # NIL THEN
            IF (s.expr.form # Expr.FPn) & (s.expr2.form # Expr.FPn) THEN
              LoadFP0(s, NIL, s.expr2);
            END;
            ReplaceAss(s, Scan.fmove, typ, s.expr2, s.expr);
          ELSIF (s.expr.form = Expr.Rlst) OR (s.expr2.form = Expr.Rlst) THEN
            ReplaceAss(s, Scan.movem, Sym.linttyp, s.expr2, s.expr);
          ELSE
            ReplaceAss(s, Scan.move, s.expr.typ, s.expr2, s.expr);
          END;
        END;

    | Stat.Bra:
        Itemize(s, s.expr);
        IF IsLabel(s.expr) THEN
          ReplaceAss(s, Scan.bra, Sym.inttyp, s.expr, NIL);
        ELSE
          s.form := Scan.jmp; s.expr2 := NIL; s.a0 := Stat.NoSize;
        END;

    | Stat.Dcw:
        ReplaceAss(s, Scan.dc, Sym.inttyp, s.expr, NIL);

    | Stat.Base:
        ReplaceAss(s, Scan.base, Sym.notyp, s.expr, NIL);

    | Stat.Label:
        ReplaceAss(s, Scan.label, Sym.notyp, s.expr, NIL);

    | Stat.Call:
        IF (s.expr.form = Expr.Sym) & (s.expr.sym.form = Sym.CProc) THEN
          ReplaceAss(s, Scan.trap, Sym.notyp,
              Com.AConst( s.expr.sym.a0, Sym.sinttyp), NIL );
        ELSE
          Itemize(s, s.expr);
          ReplaceAss(s, Scan.jsr, Sym.notyp, s.expr, NIL);
        END;

    | Stat.Bct:
        Itemize(s, s.expr2); MakeCoc(s, s.expr2);
        IF s.expr2.a0 = F THEN
          Stat.Remove(s);	(* branch never *)
        ELSE
          ReplaceAss(s, Scan.bra + SHORT( s.expr2.a0), Sym.inttyp, s.expr, NIL);
        END;

    | Stat.Bcf:
        Itemize(s, s.expr2); MakeCoc(s, s.expr2);
        IF s.expr2.a0 = T THEN
          Stat.Remove(s);	(* branch never *)
        ELSE
          ReplaceAss(s, Scan.bra + InvertedCond( s.expr2.a0),
                     Sym.inttyp, s.expr, NIL);
        END;

    | Stat.Begin:
        IF Par.copyDyn THEN
          sym := procsym;
          WHILE (sym # NIL) & (sym.form # Sym.Sep) DO
            IF sym.form = Sym.Cpy THEN
              CopyDynArr(s.next, sym);
            END;
            sym := sym.next;
          END;
        END;

    ELSE
        IF s.form >= Stat.Ass THEN
          inAss := TRUE;
          IF s.expr # NIL THEN Itemize(s, s.expr) END;
          IF s.expr2 # NIL THEN Itemize(s, s.expr2) END;
          inAss := FALSE;
        END;
    END;
    s := s.next;
  END;
 END Assemble;


PROCEDURE Init*;
 BEGIN
  inAss := FALSE;
 END Init;


PROCEDURE Exit*;
 BEGIN
  dest := NIL;
  procsym := NIL;
 END Exit;


END OCAssembler.