MODULE OCStatOpt; (* SJ 27.9.94 *)


IMPORT
  S:=SYSTEM, Expr:=OCExpr, Stat:=OCStat, Assembler:=OCAssembler, Com:=OCCom,
  Scan:=OCScan, Sym:=OCSymbol, RegOpt:=OCRegOpt, AssOpt:=OCAssOpt,
  OCH:=OCH2, Par:=OCPar, Strings, NumStr;



VAR
  symbols: Sym.Symbol;
  begStat: Stat.Stat;


(*$T- *)

PROCEDURE ReplaceSym(x: Expr.Expr; repl, by: Sym.Symbol);
 BEGIN
  IF x # NIL THEN
    IF (x.form = Expr.Sym) & (x.sym = repl) THEN
      x.sym := by
    ELSIF Expr.HasOp1(x) THEN
      ReplaceSym(x.op1, repl, by);
      IF Expr.HasOp2(x) THEN
        ReplaceSym(x.op2, repl, by);
      END;
    END;
  END;
 END ReplaceSym;


PROCEDURE ReplaceTempVar(s: Stat.Stat; repl, by: Expr.Expr);
  VAR
    psym, sym, replsym: Sym.Symbol;
 BEGIN
  replsym := repl.sym;
  WHILE s.form # Stat.End DO
    IF (s.form = Stat.Asgn) OR (s.form = Stat.Bct) OR (s.form = Stat.Bcf) THEN
      ReplaceSym( s.expr, replsym, by.sym);
      ReplaceSym( s.expr2, replsym, by.sym);
    END;
    s := s.next;
  END;

  psym := symbols; sym := psym.next;
  WHILE sym # NIL DO
    IF sym = replsym THEN
      psym.next := sym.next; RETURN
    END;
    psym := sym; sym := sym.next;
  END;
  HALT(99);
 END ReplaceTempVar;


PROCEDURE OptimizePart(VAR first: Stat.Stat);
(*
 Pass through the statements until reaching a statement which is not an
 assignment or containing a procedure call.
 Pass through all statements from s to last. If the right side of an
 assignment is a complex expression, go up to find the same expression
 again. If a value is changed inbetween which changes the expression, stop
 going up. If the same expression is found, place it in a temporary
 variable in front of the first access and replace the two accesses. If the
 first access already assigned to a temporary variable, used that.
 *)
  VAR
    s, s2, last: Stat.Stat;
    temp: Expr.Expr;
 BEGIN
  s := first;
  WHILE (s.form = Stat.Asgn) OR (s.form = Stat.Bcf) OR (s.form = Stat.Bct) DO
    IF Expr.Complex(s.expr2) THEN
      s2 := s;
      WHILE s2 # first DO
        s2 := s2.prev;
        IF (s.form = Stat.Asgn) & AssOpt.DependOn(s.expr2, s2.expr) THEN
          s2 := first;
        ELSIF AssOpt.Match(s2.expr2, s.expr2)
              & Sym.SameType(s2.expr2.typ, s.expr2.typ) THEN
          IF AssOpt.IsTempVar(s2.expr) THEN
            IF AssOpt.IsTempVar(s.expr)
                & Sym.SameType(s.expr.typ, s2.expr.typ) THEN
              ReplaceTempVar(s.next, s.expr, s2.expr);
              Stat.Remove(s);
            ELSE
              s.expr2 := Expr.Copy(s2.expr);
            END;
          ELSE
            Com.TempVar( symbols, s.expr.typ, temp);
            RegOpt.InsertAsgn(s2, s.expr2, temp);
            IF s2 = first THEN first := s2.prev END;
            s.expr2 := temp; s2.expr2 := temp;
          END;
          s2 := first;
        END;
      END;
    END;
    s := s.next;
  END;

  first := s;
 END OptimizePart;


PROCEDURE DoOptimize(VAR s: Stat.Stat);
 BEGIN
  LOOP
    Stat.ReadOptions(s);
    CASE s.form OF
      Stat.Asgn:
          OptimizePart(s);

    | Stat.End:
        EXIT

    ELSE
        s := s.next;

    END;
  END;
 END DoOptimize;


PROCEDURE PowerOfTwo*(val : LONGINT; VAR exp : INTEGER) : BOOLEAN;
 BEGIN
  exp := 0;
  WHILE ~ODD(val) DO val := val DIV 2; INC(exp) END;
  RETURN val = 1
 END PowerOfTwo;


PROCEDURE OptimizeExpr(s: Stat.Stat; e: Expr.Expr);
  VAR
    h: Expr.Expr;
    exp: INTEGER;
    val: LONGINT;
    typ: Sym.Struct;
 BEGIN
  IF e.form = Expr.Mul THEN
    IF Expr.IsConst(e.op1) & (e.op1.typ.form IN {Sym.SInt..Sym.LInt}) THEN
      val := Expr.Evaluate(e.op1);
      IF val = 0 THEN e.form := Expr.Con; e.a0 := 0
      ELSIF val = 1 THEN Expr.CopyCont(e.op2, e);
      ELSE
        IF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) THEN
          val := Expr.Evaluate(e.op2);
          IF val = 0 THEN e.form := Expr.Con; e.a0 := 0
          ELSIF val = 1 THEN Expr.CopyCont(e.op1, e);
          END;
        ELSIF PowerOfTwo(val, exp) THEN
          h := e.op1; e.op1 := e.op2; e.op2 := h;
          e.form := Expr.Ash; e.op2.form := Expr.Con;
          e.op2.a0 := exp;
        END;
      END;
    ELSIF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) THEN
      val := Expr.Evaluate(e.op2);
      IF val = 0 THEN e.form := Expr.Con; e.a0 := 0
      ELSIF val = 1 THEN Expr.CopyCont(e.op1, e);
      ELSIF PowerOfTwo(val, exp) THEN
        e.form := Expr.Ash; e.op2.form := Expr.Con;
        e.op2.a0 := exp;
      END;
    END(*IF*);
  ELSIF e.form = Expr.Div THEN
    IF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) THEN
      val := Expr.Evaluate(e.op2);
      IF val = 1 THEN Expr.CopyCont(e.op1, e);
      ELSIF PowerOfTwo(val, exp) THEN
        e.form := Expr.Ash; e.op2.form := Expr.Con;
        e.op2.a0 := -exp;
      END;
    END(*IF*);
  ELSIF e.form = Expr.Mod THEN
    IF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) THEN
      val := Expr.Evaluate(e.op2);
      IF val = 1 THEN e.form := Expr.Con; e.a0 := 0
      ELSIF PowerOfTwo(val, exp) THEN
        e.form := Expr.Anl; e.op2.form := Expr.Con;
        e.op2.a0 := val-1;
      END;
    END(*IF*);
  ELSIF e.form = Expr.Add THEN
    IF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) &
       (Expr.Evaluate(e.op2) = 0) THEN
      Expr.CopyCont(e.op1, e);
    ELSIF Expr.IsConst(e.op1) & (e.op1.typ.form IN {Sym.SInt..Sym.LInt}) &
       (Expr.Evaluate(e.op1) = 0) THEN
      Expr.CopyCont(e.op2, e);
    END(*IF*);
  ELSIF e.form = Expr.Sub THEN
    IF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) &
       (Expr.Evaluate(e.op2) = 0) THEN
      Expr.CopyCont(e.op1, e);
    END(*IF*);
  ELSIF e.form = Expr.Disp THEN
    IF Expr.IsConst(e.op2) & (e.op2.typ.form IN {Sym.SInt..Sym.LInt}) &
       (Expr.Evaluate(e.op2) = 0) THEN
      typ := e.typ; Expr.CopyCont(e.op1, e); e.typ := typ;
    ELSE
      OptimizeExpr(s, e.op2);
    END(*IF*);
  END(*IF*);
 END OptimizeExpr;


PROCEDURE OptimizeAddSub(s: Stat.Stat; dest, op1, op2: Expr.Expr;
                         int, set: INTEGER) : BOOLEAN;
  VAR
    mnem: INTEGER;
 BEGIN
  IF ~(op1.typ.form IN {Sym.Real, Sym.LReal}) & AssOpt.Match( dest, op1) THEN
    IF (op2.form = Expr.Con) THEN
      Assembler.InsertACon(op2);
    ELSIF (op2.form # Expr.Dn) THEN
      RETURN FALSE;
    END;
    IF dest.typ.form = Sym.Set THEN
      mnem := set;
      IF mnem = Scan.andm THEN
        IF op2.form # Expr.Dn THEN RETURN FALSE END;
        Assembler.InsertAss(s, Scan.notm, dest.typ, op2, NIL);
      END;
    ELSE mnem := int
    END;
    IF (dest.form = Expr.SP) OR (dest.form = Expr.An) THEN
      CASE mnem OF
        Scan.add : mnem := Scan.adda
      | Scan.sub : mnem := Scan.suba
      | Scan.orm, Scan.andm: RETURN FALSE
      END;
    ELSIF (op2.form = Expr.ACon) THEN
      CASE mnem OF
        Scan.add : mnem := Scan.addi
      | Scan.sub : mnem := Scan.subi
      | Scan.orm : mnem := Scan.ori
      | Scan.andm: mnem := Scan.andi
      END;
    END;
    Assembler.ReplaceAss(s, mnem, dest.typ, op2, dest);
    RETURN TRUE;
  END;
  RETURN FALSE;
 END OptimizeAddSub;

(*
PROCEDURE TryDisplace(VAR s: Stat.Stat; dest, op1, op2: Expr.Expr);
  VAR
    deref: Expr.Expr;

  PROCEDURE OnceDeref(s: Stat.Stat; x: Expr.Expr; VAR deref: Expr.Expr)
                      : BOOLEAN;
    VAR
      fnd: BOOLEAN;

    PROCEDURE CheckDeref(expr: Expr.Expr) : BOOLEAN;
     BEGIN
      IF (expr.form = Expr.Deref) & AssOpt.Match(expr.op1, x) THEN
        deref := expr; RETURN TRUE
      END;
      RETURN FALSE
     END CheckDeref;

   BEGIN
    fnd := FALSE;
    WHILE s.form = Stat.Asgn DO
      IF CheckDeref(s.expr) THEN
        IF fnd THEN RETURN FALSE ELSE fnd := TRUE END;
      ELSIF AssOpt.DependOn(s.expr, x) THEN
        RETURN FALSE
      END;
      IF CheckDeref(s.expr2) THEN
        IF fnd THEN RETURN FALSE ELSE fnd := TRUE END;
      ELSIF AssOpt.DependOn(s.expr2, x) THEN
        RETURN FALSE
      END;
      s := s.next;
    END;
    RETURN fnd;
   END OnceDeref;

 BEGIN
  IF (op1.typ.form IN {Sym.AnyPtr, Sym.Pointer})
      & IsTemp(dest) & OnceDeref(s.next, dest, deref) THEN
    deref.op1 := Com.Disp(op1, op2);
    Stat.Remove(s);
  END;
 END TryDisplace;
*)

PROCEDURE OptimizeStat(begin: Stat.Stat);
(*
 Optimize the statements.
 *)
  VAR
    d: BOOLEAN;
    sym: Sym.Symbol;
    s, s2: Stat.Stat;
    len: INTEGER;
    off: LONGINT;
    sp : Strings.ptr;
 BEGIN
  Stat.Environment(begin, sym, s);
  symbols := sym.syms;
  s := begin;
  WHILE (s # NIL) & (s.form # Stat.End) DO
    Stat.ReadOptions(s);
    CASE s.form OF
      Stat.Asgn:
        IF AssOpt.Match(s.expr, s.expr2) THEN
          Stat.Remove(s)
        ELSIF AssOpt.IsTempVar(s.expr) & AssOpt.IsTempVar(s.expr2)
            & Sym.SameType(s.expr.typ, s.expr2.typ) THEN
          ReplaceTempVar(s, s.expr, s.expr2);
          Stat.Remove(s)
        ELSIF (s.expr.form = Expr.DynArr) & (s.expr2.typ.form = Sym.String) THEN
          OCH.StringData(s.expr2, len, sp, off);
          IF len = 1 THEN	(* "" *)
            s.expr := s.expr.op1;
            s2 := s.prev; Stat.Remove(s2);
          END;
        ELSE
          CASE s.expr2.form OF

            Expr.Neg:
              IF AssOpt.Match( s.expr, s.expr2.op1) & ~Expr.Complex(s.expr)
                  & ~(s.expr2.form IN {Sym.Real, Sym.LReal}) THEN
                Assembler.ReplaceAss(s, Scan.neg, s.expr.typ, s.expr, NIL);
              END;

          | Expr.Ntl:
              IF AssOpt.Match( s.expr, s.expr2.op1) & ~Expr.Complex(s.expr) THEN
                Assembler.ReplaceAss(s, Scan.notm, s.expr.typ, s.expr, NIL);
              END;

          | Expr.Not:
              IF AssOpt.Match( s.expr, s.expr2.op1) & ~Expr.Complex(s.expr) THEN
                Assembler.ReplaceAss(s, Scan.eori, s.expr.typ,
                    Com.AConst(1, Sym.sinttyp), s.expr);
              END;

          | Expr.Add:
              IF NOT (OptimizeAddSub(s, s.expr, s.expr2.op1, s.expr2.op2,
                                Scan.add, Scan.orm)
                  OR OptimizeAddSub(s, s.expr, s.expr2.op2, s.expr2.op1,
                                    Scan.add, Scan.orm) ) THEN
  (*              TryDisplace(s, s.expr, s.expr2.op1, s.expr2.op2);*)
              END;

          | Expr.Sub:
              d := OptimizeAddSub(s, s.expr, s.expr2.op1, s.expr2.op2,
                                  Scan.sub, Scan.andm)

          ELSE
          END;
        END;

    ELSE
    END;
    s := s.next;
  END;
 END OptimizeStat;


PROCEDURE Optimize*(begin: Stat.Stat);
  VAR
    s: Stat.Stat;
    sym: Sym.Symbol;
 BEGIN
  s := begin;
  WHILE (s # NIL) & (s.form # Stat.End) DO
    Stat.ReadOptions(s);
    CASE s.form OF
      Stat.Asgn:
        OptimizeExpr(s, s.expr); OptimizeExpr(s, s.expr2);

    | Stat.Call, Stat.Bra, Stat.Bct, Stat.Bcf:
       OptimizeExpr(s, s.expr);

    ELSE
    END;
    s := s.next;
  END;

  IF Par.opt THEN
    Stat.Environment(begin, sym, s);
    s := begin;
    symbols := sym.syms;
    Com.varpos := SHORT( s.a0);
    begStat := s;
    Stat.insert := s;
    s := s.next;
    DoOptimize(s);
    begStat.a0 := Com.varpos;

  END;

  OptimizeStat(begin);
 END Optimize;


PROCEDURE Init*;
 BEGIN
 END Init;


PROCEDURE Exit*;
 BEGIN
  symbols := NIL;
  begStat := NIL;
 END Exit;


END OCStatOpt.