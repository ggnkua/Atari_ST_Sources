MODULE OCAssOpt; (* SJ 27.9.94 *)


IMPORT
  S:=SYSTEM, Assembler:=OCAssembler, Stat:=OCStat, Scan:=OCScan, OCOutput,
  Expr:=OCExpr, Sym:=OCSymbol, Com:=OCCom, OCH:=OCH2, Par:=OCPar, Strings,
  Coder:=OCCoder;


VAR
  symbols: Sym.Symbol;



PROCEDURE IsTempVar*(x: Expr.Expr) : BOOLEAN;
  VAR
    sp: Strings.ptr;
 BEGIN
  IF x.form = Expr.Sym THEN
    sp := S.ADR(x.sym.name);
    RETURN (sp[0] = "T") & (sp[1] = "E") & (sp[2] = "M") & (sp[3] = "P")
  END;
  RETURN FALSE
 END IsTempVar;


PROCEDURE Match*(e1, e2 : Expr.Expr) : BOOLEAN;
(*
 Return true if e1 and e2 access the same value.
 *)
  VAR
    sp1, sp2: Strings.ptr;
 BEGIN
  IF e1 = e2 THEN RETURN TRUE END;
  IF (e1 # NIL) & (e2 # NIL) & (e1.form = e2.form) THEN
    CASE e1.form OF
      Expr.Sym:
        RETURN e1.sym = e2.sym;

    | Expr.Con:
        IF Sym.SameType(e1.typ, e2.typ) THEN
          CASE e1.typ.form OF
            Sym.Byte..Sym.Real, Sym.Set, Sym.AnyPtr:
              RETURN e1.a0 = e2.a0;
          | Sym.LReal:
              RETURN (e1.a0 = e2.a0) & (e1.a1 = e2.a1);
          | Sym.String:
              sp1 := S.VAL( Strings.ptr, e1.a1);
              sp2 := S.VAL( Strings.ptr, e2.a1);
              RETURN (sp1 = sp2) OR (sp1^ = sp2^);
          ELSE
          END;
        END;

    | Expr.FSingle..Expr.ULong, Expr.ARI..Expr.Imm, Expr.Rlst, Expr.FRlst,
      Expr.Ind:
        RETURN Match(e1.op1, e2.op1);

    | Expr.FDual..Expr.Set-1, Expr.Set+1..Expr.DynArr:
        RETURN Match(e1.op1, e2.op1) & Match(e1.op2, e2.op2);

    | Expr.Set:
        RETURN Match(e1.op1, e2.op1)
            & ((e1.op2 = e2.op2)
              OR (e1.op2 # NIL) & (e2.op2 # NIL) & Match(e1.op2, e2.op2));

    | Expr.Cmp:
        RETURN Match(e1.op1, e2.op1)
               & Match(e1.op2, e2.op2) & (e1.a0 = e2.a0);

    | Expr.Tbp:
        RETURN Match(e1.op1, e2.op1) & (e1.sym = e2.sym);

    | Expr.Dn, Expr.An, Expr.FPn, Expr.SFR:
        RETURN e1.a0 = e2.a0;

    | Expr.SP, Expr.CCR..Expr.USP, Expr.PC:
        RETURN TRUE

    ELSE
    END;
  END;
  RETURN FALSE;
 END Match;


PROCEDURE DependOn*(x1, x2: Expr.Expr) : BOOLEAN;
(*
 Return true if a change of x2 will change the result of x1.
 *)
 BEGIN
  RETURN Match(x1, x2)
         OR Expr.HasOp1(x1) & DependOn(x1.op1, x2)
         OR Expr.HasOp2(x1) & DependOn(x1.op2, x2);
 END DependOn;


PROCEDURE ExprUsesLabel(x: Expr.Expr; sym: Sym.Symbol) : BOOLEAN;
 BEGIN
  IF x # NIL THEN
    IF (x.form = Expr.Sym) & (x.sym = sym) THEN RETURN TRUE END;
    IF (x.form >= Expr.ARI) & (x.form <= Expr.FRlst)
        OR (x.form = Expr.Ind) OR (x.form = Expr.XReg)
        OR (x.form >= Expr.FSingle) & (x.form <= Expr.LDual) THEN
      IF ExprUsesLabel(x.op1, sym) THEN RETURN TRUE END;
      IF Expr.HasOp2(x) THEN
        IF ExprUsesLabel(x.op2, sym) THEN RETURN TRUE END;
      END;
    END;
  END;
  RETURN FALSE;
 END ExprUsesLabel;


PROCEDURE LabelUsed(sym: Sym.Symbol) : BOOLEAN;
  VAR
    s: Stat.Stat;
 BEGIN
  s := Stat.stats;
  WHILE s # NIL DO
    IF (s.form >= Stat.Ass) & (s.form # Scan.label) THEN
      IF ExprUsesLabel(s.expr, sym) THEN RETURN TRUE END;
      IF ExprUsesLabel(s.expr2, sym) THEN RETURN TRUE END;
    END;
    s := s.next;
  END;
  RETURN FALSE;
 END LabelUsed;


PROCEDURE ExprReplaceLabel(x: Expr.Expr; sym, by: Sym.Symbol);
 BEGIN
  IF x # NIL THEN
    IF (x.form = Expr.Sym) & (x.sym = sym) THEN
      x.sym := by;
    ELSIF Expr.HasOp1(x) THEN
      ExprReplaceLabel(x.op1, sym, by);
      IF Expr.HasOp2(x) THEN
        ExprReplaceLabel(x.op2, sym, by);
      END;
    END;
  END;
 END ExprReplaceLabel;


PROCEDURE ReplaceLabel(sym, by: Sym.Symbol);
  VAR
    s: Stat.Stat;
 BEGIN
  s := Stat.stats;
  WHILE s # NIL DO
    IF s.form >= Stat.Ass THEN
      ExprReplaceLabel(s.expr, sym, by);
      ExprReplaceLabel(s.expr2, sym, by);
    END;
    s := s.next;
  END;
 END ReplaceLabel;


PROCEDURE ExprUsing(x, using: Expr.Expr) : BOOLEAN;
 BEGIN
  IF Match(x, using) THEN RETURN TRUE END;
  IF Expr.HasOp1(x) THEN
    IF ExprUsing(x.op1, using) THEN RETURN TRUE END;
    IF Expr.HasOp2(x) THEN
      RETURN ExprUsing(x.op2, using);
    END;
  END;
  RETURN FALSE
 END ExprUsing;


PROCEDURE CheckUsing(s: Stat.Stat; x: Expr.Expr) : BOOLEAN;
 BEGIN
  IF s.expr # NIL THEN
    IF ExprUsing(s.expr, x) THEN RETURN TRUE END;
    IF s.expr2 # NIL THEN
      IF ExprUsing(s.expr2, x) THEN RETURN TRUE END;
    END;
  END;
  RETURN FALSE
 END CheckUsing;


PROCEDURE UsedBefore(x: Expr.Expr; s: Stat.Stat) : BOOLEAN;
 BEGIN
  LOOP
    s := s.prev;
    IF s.form = Stat.Begin THEN RETURN FALSE END;
    IF CheckUsing(s, x) THEN RETURN TRUE END;
  END;
 END UsedBefore;


PROCEDURE UsedAfter(x: Expr.Expr; s: Stat.Stat) : BOOLEAN;
 BEGIN
  LOOP
    s := s.next;
    IF s.form = Stat.End THEN RETURN FALSE END;
    IF CheckUsing(s, x) THEN RETURN TRUE END;
  END;
 END UsedAfter;


PROCEDURE OpLength(x: Expr.Expr) : INTEGER;
  VAR
    val: LONGINT;
 BEGIN
  IF x = NIL THEN RETURN 0 END;
  CASE x.form OF
  | Expr.Dn, Expr.An, Expr.ARI, Expr.API, Expr.APD,
    Expr.CCR, Expr.SR, Expr.USP, Expr.SFR, Expr.FPn,
    Expr.SP, Expr.PC, Expr.DDn:
      RETURN 0;
  | Expr.DA, Expr.DAX, Expr.AbsW, Expr.PCD, Expr.PCDI,
    Expr.Rlst, Expr.FRlst:
      RETURN 2;
  | Expr.AbsL, Expr.Mem:
      RETURN 4;
  | Expr.MIPo, Expr.MIPr, Expr.PCPo, Expr.PCPr:
      RETURN OpLength(x.op1);
  | Expr.Ind:
      RETURN OpLength(x.op1);
  | Expr.Disp:
      RETURN OpLength(x.op1) + OpLength(x.op2);
  | Expr.Sym:
      IF (x.sym.lev <= 0) OR ~(x.form IN {Sym.Var, Sym.Ind, Sym.Cpy}) THEN
        RETURN 4
      ELSE RETURN 2
      END;
  ELSE
    IF (x.form = Expr.ACon) OR (x.form = Expr.Imm) THEN
      IF x.typ.size = 1 THEN RETURN 2
      ELSE RETURN SHORT( x.typ.size);
      END;
    ELSIF (x.form >= Expr.FSingle) OR (x.form = Expr.Con) THEN
      val := Expr.Evaluate(x);
      IF (x.typ.size = 4) OR Expr.reloc THEN RETURN 4;
      ELSE RETURN 2
      END;
    ELSE
      RETURN 0;
    END;
  END;
 END OpLength;


PROCEDURE CommandLength(s: Stat.Stat) : INTEGER;
  VAR
    sym: Sym.Symbol;
    len : INTEGER;

  PROCEDURE ImportLength() : INTEGER;
    VAR
      sym: Sym.Symbol;
      size: INTEGER;
   BEGIN
    sym := Sym.global; size := 0;
    WHILE sym # NIL DO
      IF (sym.form = Sym.Mod) & (sym.lev # -128) THEN	(* not SYSTEM *)
        INC(size, 6);
      END;
      sym := sym.next;
    END;
    RETURN size;
   END ImportLength;


 BEGIN
  CASE s.form OF
    Stat.Ret:
      sym := symbols.a0;
      IF (sym.form = Sym.AProc) & (symbols.lev = s.a0) THEN RETURN 12 END;
      RETURN (symbols.lev - SHORT( s.a0)) * 2 + 4;

  | Stat.Begin:
      sym := symbols.a0;
      IF sym.form = Sym.Mod THEN
        len := ImportLength();
      ELSE
        len := 0;
      END;
      IF Par.ccode THEN
        INC(len, 4);
        IF Par.stkchk THEN INC(len, 6) END;
        IF sym.form = Sym.AProc THEN INC(len, 12) END;
      END;
      RETURN len;

  | Stat.End:
      IF Par.ccode THEN
        sym := symbols.a0;
        IF (sym.form = Sym.AProc) & (sym.typ.form = Sym.NoTyp) THEN
          RETURN 12;
        ELSIF (sym.form # Sym.Mod) & (sym.typ.form # Sym.NoTyp) THEN
          RETURN 6;
        ELSE
          RETURN 4;
        END;
      END;

  | Stat.Mod:
      RETURN 16;

  ELSE
      IF s.form >= Stat.Ass THEN
        IF (s.form < Scan.fbf) THEN
          len := OpLength(s.expr) + OpLength(s.expr2) + 2;
          IF (s.form > Scan.trap)
            OR (s.form >= Scan.divs) & (s.form <= Scan.mulul)
               & (s.a0 = Stat.Long) THEN
            INC(len, 2)	(* 4 bytes base code *)
          END;
          RETURN len;
        ELSIF s.form <= Scan.ble THEN
          IF s.a0 = Stat.Byte THEN RETURN 2
          ELSE RETURN 4
          END;
        ELSIF s.form <= Scan.dble THEN
          RETURN 4
        ELSIF s.form = Scan.dc THEN
          IF s.a0 = Stat.Long THEN RETURN 4;
          ELSIF s.a0 = Stat.Word THEN RETURN 2;
          ELSIF s.expr.typ.form # Sym.String THEN RETURN 1;
          ELSE
            HALT(100)
          END;
        END;
      END;
  END;
  RETURN 0;
 END CommandLength;


PROCEDURE DistanceSmallerThan(s: Stat.Stat; lab: Expr.Expr; than: LONGINT)
                              : BOOLEAN;
  VAR
    dist: LONGINT;
    stat: Stat.Stat;

  PROCEDURE SearchRealStart() : BOOLEAN;
    VAR
      d: BOOLEAN;
   BEGIN
    LOOP
      stat := stat.next;
      IF (stat = NIL) OR (stat.form = Stat.End) THEN RETURN FALSE END;
      IF stat.form = Stat.Begin THEN
        IF lab.sym.name = "Asgn" THEN HALT(100) END;
        RETURN ABS(dist) < than;
      END;
      INC(dist, stat.len);
      IF stat.form = Stat.Proc THEN
        d := SearchRealStart();
        WHILE stat.form # Stat.End DO
          IF stat = NIL THEN RETURN FALSE END;
          INC(dist, stat.len); stat := stat.next;
        END;
        INC(dist, stat.len);
      END;
    END;
   END SearchRealStart;

 BEGIN
  IF (lab.form = Expr.Sym) & (lab.sym.form IN {Sym.Label}) THEN
    dist := 2; stat := s.next;
    LOOP	(* search forward *)
      IF stat.form = Scan.label THEN
        IF stat.expr.sym = lab.sym THEN
        IF lab.sym.name = "Asgn" THEN HALT(101) END;
        RETURN TRUE END;
      ELSIF (stat.form = Stat.Proc) & (stat.a0 = 1) THEN
        IF stat.sym = lab.sym THEN
          RETURN SearchRealStart()
        END;
      END;
      INC(dist, stat.len);
      IF dist >= than THEN EXIT END;
      stat := stat.next;
      IF (stat = NIL) THEN EXIT END;
    END;
    dist := -2; stat := s;
    LOOP	(* search backward *)
      stat := stat.prev;
      IF (stat = NIL) THEN EXIT END;
      DEC(dist, stat.len);
      IF -dist >= than THEN EXIT END;
      IF stat.form = Scan.label THEN
        IF stat.expr.sym = lab.sym THEN
        IF lab.sym.name = "Asgn" THEN HALT(102) END;
        RETURN TRUE END;
      ELSIF (stat.form = Stat.Proc) & (stat.a0 = 1) THEN
        IF stat.sym = lab.sym THEN
          RETURN SearchRealStart()
        END;
      END;
    END;
  END;
  RETURN FALSE
 END DistanceSmallerThan;


PROCEDURE ByteDistance(s: Stat.Stat; lab: Expr.Expr) : BOOLEAN;
  VAR
    answer: BOOLEAN;
 BEGIN
  RETURN DistanceSmallerThan(s, lab, MAX(SHORTINT))
 END ByteDistance;


PROCEDURE WordDistance(s: Stat.Stat; lab: Expr.Expr) : BOOLEAN;
 BEGIN
  RETURN DistanceSmallerThan(s, lab, MAX(INTEGER))
 END WordDistance;


PROCEDURE IsReg(x: Expr.Expr) : BOOLEAN;
 BEGIN
  RETURN (x.form = Expr.Dn) OR (x.form = Expr.An) OR (x.form = Expr.FPn);
 END IsReg;


PROCEDURE OptimizeContents(begin: Stat.Stat);
(*
 This is a quite complex way of optimization. It looks at the assembler
 commands inbetween label definitions. It stores which contents is moved
 into an expression. If it encounters a command changing that expression,
 the contents is forgotten. If it encounters a move into that expression
 and the source is identical, this move can be removed. Other optimizations
 may follow.
 *)
  VAR
    exprs: ARRAY 100 OF Expr.Expr;	(* an expression containing *)
    conts: ARRAY 100 OF Expr.Expr;	(* this expression *)
    sizes: ARRAY 100 OF LONGINT;	(* with this size *)
    inx  : INTEGER;
    s    : Stat.Stat;
    sym  : Sym.Symbol;

  PROCEDURE ExprChanged(x: Expr.Expr);
    VAR
      i: INTEGER;
   BEGIN
    i := 0;
    WHILE i < inx DO
      IF DependOn( exprs[i], x) OR DependOn( conts[i], x) THEN
        DEC(inx);
        exprs[i] := exprs[inx]; conts[i] := conts[inx];
        sizes[i] := sizes[inx];
      ELSE
        INC(i);
      END;
    END;
   END ExprChanged;

  PROCEDURE StoreMove(size: LONGINT; src, dest: Expr.Expr);
   BEGIN
    IF (inx < 98) & (~IsReg(src) OR ~IsReg(dest))
       & (src.form # Expr.APD) & (dest.form # Expr.APD)
       & (src.form # Expr.API) & (dest.form # Expr.API)
       & ((dest.form # Expr.An) OR (dest.a0 # 7))
       & (dest.form # Expr.SP)
       & ((src.form # Expr.An) OR (src.a0 # 7))
       & (src.form # Expr.SP)
       & ~DependOn(src, dest) THEN
      exprs[inx] := dest; conts[inx] := src; sizes[inx] := size;
      INC(inx);
      exprs[inx] := src; conts[inx] := dest; sizes[inx] := size;
      INC(inx);
    END;
   END StoreMove;

  PROCEDURE SearchConts(size: LONGINT; cont: Expr.Expr; VAR expr: Expr.Expr)
                        : BOOLEAN;
    VAR
      i: INTEGER;
   BEGIN
    i := 0;
    WHILE i < inx DO
      IF (sizes[i] = size) & Match( conts[i], cont)
          & (conts[i].typ.size = cont.typ.size) & IsReg(exprs[i]) THEN
        expr := exprs[i]; RETURN TRUE
      ELSE
        INC(i);
      END;
    END;
    RETURN FALSE
   END SearchConts;

  PROCEDURE HasUnchangedSrc(form: INTEGER; x: Expr.Expr) : BOOLEAN;
   BEGIN
    RETURN (x # NIL)
           & (x.form # Expr.APD) & (x.form # Expr.API)
           & ((form >= Scan.abcd) & (form <= Scan.cmpa)
             OR (form >= Scan.suba) & (form <= Scan.chk)
             OR (form >= Scan.tst) & (form <= Scan.jsr)
             OR (form >= Scan.divs) & (form <= Scan.fmove)
             OR (form = Scan.fcmp))
   END HasUnchangedSrc;

  PROCEDURE HasUnchangedDest(form: INTEGER; x: Expr.Expr) : BOOLEAN;
   BEGIN
    RETURN (x # NIL)
           & (x.form # Expr.APD) & (x.form # Expr.API)
           & ((form = Scan.cmpm) OR (form = Scan.cmpa)
             OR (form = Scan.cmp) OR (form = Scan.cmpi)
             OR (form = Scan.btst) OR (form = Scan.chk)
             OR (form = Scan.chk2) OR (form = Scan.cmp2)
             OR (form = Scan.fcmp))
   END HasUnchangedDest;

  PROCEDURE RemoveOrTest(VAR s: Stat.Stat);
   BEGIN
    IF (s.next.form >= Scan.bhi) & (s.next.form <= Scan.ble) THEN
      s.form := Scan.tst; s.expr2 := NIL;
    ELSE
      Stat.Remove(s);
    END;
   END RemoveOrTest;

 BEGIN
  Stat.Environment(begin, sym, s);
  s := begin; inx := 0;
  LOOP
    Stat.ReadOptions(s);
    IF (s = NIL) OR (s.form = Stat.End) THEN EXIT END;
    IF Par.opt THEN
      IF s.form >= Stat.Ass THEN
        IF HasUnchangedSrc(s.form, s.expr)
            & ~IsReg(s.expr) & SearchConts(s.a0, s.expr, s.expr)
            & Match( s.expr, s.expr2) THEN
          RemoveOrTest(s);
        ELSIF HasUnchangedDest(s.form, s.expr2)
               & ~IsReg(s.expr2) & SearchConts(s.a0, s.expr2, s.expr2)
               & Match( s.expr, s.expr2) THEN
          RemoveOrTest(s);
        ELSIF (s.form = Scan.label) OR (s.form = Scan.jsr)
           OR (s.form = Scan.bsr) OR (s.form = Scan.trap) THEN	(* forget *)
          inx := 0;
        ELSIF (s.form = Scan.move) OR (s.form = Scan.fmove) THEN
          IF ~SearchConts(s.a0, s.expr, s.expr)
              & ~Match(s.expr, s.expr2)
              & (s.expr.form # Expr.API) & (s.expr.form # Expr.APD)
              & (s.expr2.form # Expr.API) & (s.expr2.form # Expr.APD) THEN
            ExprChanged(s.expr2);
            StoreMove(s.a0, s.expr, s.expr2)
          END;
        ELSE
          IF ~HasUnchangedSrc(s.form, s.expr) & (s.expr # NIL) THEN
            ExprChanged(s.expr)
          END;
          IF ~HasUnchangedDest(s.form, s.expr2) & (s.expr2 # NIL) THEN
            ExprChanged(s.expr2);
          END;
        END;
      ELSIF s.form = Stat.End THEN inx := 0;
      END;
    ELSE inx := 0;
    END;
    s := s.next;
  END;
 END OptimizeContents;

(*$T- *)

PROCEDURE ReplaceExpr*(x, repl, by: Expr.Expr);
 BEGIN
  IF x # NIL THEN
    IF Match(x, repl) & Sym.SameType(x.typ, repl.typ) THEN
      Expr.CopyCont(by, x);
    ELSIF Expr.HasOp1(x) THEN
      ReplaceExpr(x.op1, repl, by);
      IF Expr.HasOp2(x) THEN
        ReplaceExpr(x.op2, repl, by);
      END;
    END;
  END;
 END ReplaceExpr;


PROCEDURE Replace(s, to: Stat.Stat; repl, by: Expr.Expr);
 BEGIN
  IF s.prev = to THEN RETURN END;
  WHILE s # to DO
    IF s.form >= Stat.Ass THEN
      ReplaceExpr(s.expr, repl, by);
      ReplaceExpr(s.expr2, repl, by);
    END;
    s := s.next;
  END;
 END Replace;


PROCEDURE RegUsedAfter(x: Expr.Expr; s: Stat.Stat) : BOOLEAN;
 BEGIN
  REPEAT
    IF (s.form = Stat.Ret) & (x.form = Expr.Dn) & (x.a0 = 0) THEN
      RETURN TRUE
    ELSIF (s.form = Stat.End) OR (s.form = Scan.bra)
          OR (s.form = Scan.jmp) THEN
      RETURN FALSE
    ELSIF ((s.form = Scan.jsr) OR (s.form = Scan.bsr))
          & (x.form = Expr.Dn) & (x.a0 = 0) THEN
      RETURN FALSE
    ELSIF ((s.form = Scan.move) OR (s.form = Scan.moveq)
           OR (s.form = Scan.lea) OR (s.form = Scan.fmove))
          & Match(s.expr2, x) THEN
      RETURN FALSE
    ELSIF (s.form >= Stat.Ass) & CheckUsing(s, x) THEN
      RETURN TRUE
    END;
    s := s.next;
  UNTIL s = NIL;
  RETURN FALSE
 END RegUsedAfter;


PROCEDURE PrevBranch(s: Stat.Stat; VAR s2 : Stat.Stat) : BOOLEAN;
 BEGIN
  REPEAT
    s := s.prev;
  UNTIL s.form # Scan.label;
  IF (s.form >= Scan.bra) & (s.form <= Scan.ble) THEN
    s2 := s; RETURN TRUE
  END;
  RETURN FALSE
 END PrevBranch;


PROCEDURE RemoveStupidCommands(begin: Stat.Stat);
  VAR
    s, s2: Stat.Stat;
 BEGIN
  s := begin;
  WHILE (s # NIL) & (s.form # Stat.End) DO
    CASE s.form OF
      Scan.movea:
        IF Match(s.expr, s.expr2) THEN Stat.Remove(s)
        ELSIF (s.next.form = Scan.move) & (s.expr.form = Expr.API)
            & (s.next.expr2.form = Expr.APD) & Match(s.expr2, s.next.expr)
            & Match(s.expr.op1, s.next.expr2.op1) THEN
          Stat.Remove(s); s:= s.next; Stat.Remove(s);
        END;

    | Scan.move, Scan.fmove:
        IF Match(s.expr, s.expr2) THEN Stat.Remove(s) END;

    | Scan.lsl, Scan.lsr, Scan.asl, Scan.asr,
      Scan.ror, Scan.rol, Scan.roxl, Scan.roxr,
      Scan.add, Scan.sub, Scan.addi, Scan.subi,
      Scan.adda, Scan.suba:
        IF (s.expr.form = Expr.ACon)
            & (s.expr.op1.typ.form IN {Sym.Byte..Sym.LInt, Sym.AnyPtr, Sym.Set})
            & (Expr.Evaluate(s.expr.op1) = 0)  & ~Expr.reloc THEN
          Stat.Remove(s)	(*  #0, ... *)
        END;

    | Scan.label:
        IF Par.opt THEN
          WHILE PrevBranch(s, s2)
                & Assembler.IsLabel(s2.expr)
                & (s2.expr.sym = s.expr.sym) DO
            Stat.Remove(s2);
          END;
        END;

    ELSE
    END;
    s := s.next;
  END;
 END RemoveStupidCommands;


PROCEDURE OptimizeTst(VAR s: Stat.Stat);
  VAR
    prev: Stat.Stat;
 BEGIN
  prev := s.prev;
  IF (s.expr.form = Expr.Dn)
     & (s.a0 = prev.a0)
     & ((prev.form = Scan.move)
        OR (prev.form = Scan.moveq)
        OR (prev.form = Scan.subq)
        OR (prev.form = Scan.eor)
        OR (prev.form = Scan.eori)
        OR (prev.form = Scan.and)
        OR (prev.form = Scan.andi)
        OR (prev.form = Scan.or)
        OR (prev.form = Scan.ori)
        OR (prev.form = Scan.sub)
        OR (prev.form = Scan.addq)
        OR (prev.form = Scan.add))
     & (prev.expr2.form = Expr.Dn)
     & (s.expr.a0 = prev.expr2.a0) THEN
    Stat.Remove(s);

  ELSIF (s.expr.form = Expr.Dn)
     & (s.a0 = prev.a0)
     & ((prev.form = Scan.clr)
        OR (prev.form = Scan.neg))
     & (prev.expr.form = Expr.Dn)
     & (s.expr.a0 = prev.expr.a0) THEN
    Stat.Remove(s);

  END;
 END OptimizeTst;


PROCEDURE PrepareSysIfNeeded(begin: Stat.Stat);
  VAR
    s: Stat.Stat;
    sym: Sym.Symbol;
 BEGIN
  Stat.Environment(begin, sym, s);
  symbols := sym.syms;
  symbols.a0 := S.VAL(LONGINT, sym);
  s := begin;
  LOOP
    Stat.ReadOptions(s);
    IF (s = NIL) THEN EXIT END;
    CASE s.form OF
      Stat.Begin:
        IF Par.stkchk THEN
          Com.PrepareSysProc(Com.SysCheckStack);
        END;

    | Stat.End:
        IF Par.ccode THEN
          sym := symbols.a0;
          IF (sym.form # Sym.Mod) & (sym.typ.form # Sym.NoTyp) THEN
            Com.PrepareSysProc(Com.SysRetFail);
          END;
        END;
        symbols := symbols.syms;
        EXIT

    ELSE
    END;
    s := s.next
  END;
 END PrepareSysIfNeeded;


PROCEDURE OptExpr(x: Expr.Expr);
 BEGIN
  IF (x.form = Expr.DA) & (Expr.Evaluate(x.op1.op2) = 0) THEN
    x.form := Expr.ARI; x.op1 := x.op1.op1;
  END;
 END OptExpr;


PROCEDURE Optimize*(begin: Stat.Stat);
(*
 Optimize assembler commands.
 *)
  VAR
    s, s2, s3: Stat.Stat;
    x, y, h: Expr.Expr;
    val : LONGINT;
    sym: Sym.Symbol;
 BEGIN
  RemoveStupidCommands(begin);
  IF Par.opt THEN
    Stat.Environment(begin, sym, s);
    s := begin;
    IF ~Par.opt THEN HALT(199) END;
    LOOP
      Stat.ReadOptions(s);
      IF (s = NIL) OR (s.form = Stat.End) THEN EXIT END;
      IF Par.opt THEN
        IF Stat.HasExpr1(s) THEN OptExpr(s.expr) END;
        IF Stat.HasExpr2(s) THEN OptExpr(s.expr2) END;
        CASE s.form OF
          Scan.move:
            s2 := s.next;
            IF ((s.expr.form = Expr.ACon) OR (s.expr.form = Expr.Imm))
                & (s.expr.op1.typ.form IN
                  {Sym.Byte..Sym.LInt, Sym.NilTyp, Sym.AnyPtr, Sym.Set}) THEN
              val := Expr.Evaluate(s.expr.op1);
              IF ~Expr.reloc THEN
                IF (s.expr2.form = Expr.Dn) & (s.a0 = Stat.Long)
                   & (val >= MIN(SHORTINT)) & (val <= MAX(SHORTINT)) THEN
                  s.form := Scan.moveq;
                ELSIF val = 0 THEN
                  IF s.expr2.form = Expr.An THEN
                    s.form := Scan.suba; s.expr := s.expr2;
                  ELSE
                    s.form := Scan.clr;
                    s.expr := s.expr2; s.expr2 := NIL;
                  END;
                END;
              END;
            ELSIF (s2.form = Scan.move) & (s2.a0 = s.a0)
               & (s.expr2.form = Expr.Dn)
               & Match(s2.expr, s.expr2)
               & ~RegUsedAfter(s.expr2, s2.next) THEN
              h := s.expr2; s.expr2 := s2.expr2; s2.expr2 := h;
              Stat.Remove(s2);
            ELSE
              IF IsTempVar(s.expr2) & (s2.form = Scan.move)
                  & Match(s2.expr, s.expr2) THEN
                IF UsedBefore(s.expr2, s) OR UsedAfter(s.expr2, s2) THEN
                  IF (s2.expr2.form = Expr.Dn)
                      OR (s2.expr2.form = Expr.An) THEN
                    s.expr2 := s2.expr2;
                    s2.expr2 := s2.expr;
                    s2.expr := s.expr2;
                  END;
                ELSE
                  h := s.expr2; s.expr2 := s2.expr2; s2.expr2 := h;
                  Stat.Remove(s2);
                END;
              END;

              s2 := s.next; s3 := s2.next;
              IF (s.expr.form = Expr.Sym) & (s.expr2.form = Expr.An)
                  & (s2.form = Scan.move) & (s2.expr.form = Expr.DA)
                  & ~Match(s2.expr2, s.expr) & ~Match(s2.expr2, s.expr2)
                  & (s3.form = Scan.move) & Match(s3.expr, s.expr)
                  & (s3.expr2.form = Expr.APD) & (s3.expr2.op1.form = Expr.SP)
                  & ~CheckUsing(s2, s3.expr2.op1) THEN
                Stat.Unchain(s3); Stat.Insert(s3, s2);
                s3.expr := s.expr2;
              END;
            END;

        | Scan.bra, Stat.Ret:
            WHILE (s.next.form # Scan.label) & (s.next.form # Stat.End) DO
              s2 := s.next; Stat.Remove(s2);
            END;

        | Scan.label:
            IF Par.reass THEN
              WHILE (s.next.form = Scan.label) DO
                ReplaceLabel(s.next.expr.sym, s.expr.sym);
                s2 := s.next; Stat.Remove(s2);
              END;
            END;
            WHILE PrevBranch(s, s2)
                  & Assembler.IsLabel(s2.expr)
                  & (s2.expr.sym = s.expr.sym) DO
              Stat.Remove(s2);
            END;

        | Scan.add, Scan.adda, Scan.addi:
            IF ((s.expr.form = Expr.ACon) OR (s.expr.form = Expr.Imm))
                & (s.expr.typ.form IN {Sym.SInt..Sym.LInt}) THEN
             val := Expr.Evaluate( s.expr);
             IF (val >= 1) & (val <= 8) THEN
               s.form := Scan.addq;
             ELSIF (val >= MIN(INTEGER)) & (val <= MAX(INTEGER))
                 & (s.expr2.form IN {Expr.An, Expr.SP}) THEN
               Expr.New(Expr.DA, x, Sym.notyp);
               x.op1 := Com.Disp( s.expr2, s.expr.op1, Sym.linttyp);
               s.expr := x;
               s.form := Scan.lea; s.a0 := Stat.Long;
             END;
           END;

        | Scan.sub, Scan.suba, Scan.subi:
            IF ((s.expr.form = Expr.ACon) OR (s.expr.form = Expr.Imm))
                & (s.expr.op1.typ.form IN {Sym.SInt..Sym.LInt})
                & (s.expr.op1.form = Expr.Con) THEN
             val := Expr.Evaluate( s.expr);
             IF val = 0 THEN Stat.Remove(s)
             ELSE
               IF (val >= 1) & (val <= 8) THEN
                 s.form := Scan.subq;
               ELSIF (val > MIN(INTEGER)) & (val <= MAX(INTEGER)+1)
                   & (s.expr2.form IN {Expr.An, Expr.SP}) THEN
                 Expr.New(Expr.DA, x, Sym.notyp);
                 Assembler.NegateConst(s.expr.op1);
                 x.op1 := Com.Disp( s.expr2, s.expr.op1, Sym.linttyp);
                 s.expr := x;
                 s.form := Scan.lea; s.a0 := Stat.Long;
               END;
             END;
           END;

        | Scan.cmp, Scan.cmpi:
            IF ((s.expr.form = Expr.ACon) OR (s.expr.form = Expr.Imm)) THEN
              s.form := Scan.cmpi;
              IF (s.expr.op1.typ.form IN {Sym.Byte..Sym.LInt, Sym.NilTyp,
                    Sym.AnyPtr, Sym.Set})
                  & (Expr.Evaluate(s.expr.op1) = 0) & ~Expr.reloc THEN
                IF ((s.expr2.form # Expr.An) OR Par.xcode) THEN
                  s.form := Scan.tst; s.expr := s.expr2; s.expr2 := NIL;
                  OptimizeTst(s);
                ELSE
                  s.form := Scan.move; s.expr := s.expr2;
                  s.expr2 := Com.Dn(2, s.expr.typ);
                END;
              END;
            END;

        | Scan.tst:
            OptimizeTst(s);

        | Scan.bmi:
            IF (s.prev.form = Scan.clr)
               OR ((s.prev.form = Scan.move) OR (s.prev.form = Scan.moveq))
                  & Expr.IsConst(s.prev.expr)
                  & (Expr.Evaluate(s.prev.expr) >= 0) THEN
              Stat.Remove(s)
            END;

        | Scan.lea:
            s2 := s.next;
            IF (s.expr.form = Expr.ARI) THEN
              IF Match(s.expr.op1, s.expr2) THEN
                Stat.Remove(s)
              ELSE
                s.form := Scan.move; s.expr := s.expr.op1;
              END;
            ELSIF (s.expr.form = Expr.DA) & (s.expr.op1.form = Expr.Disp)
                & Match(s.expr.op1.op1, s.expr2) THEN
              val := Expr.Evaluate(s.expr.op1.op2);
              IF val = 0 THEN
                Stat.Remove(s)
              ELSIF (val > 0) & (val <= 8) THEN
                s.form := Scan.addq;
                s.expr := s.expr.op1.op2;
                IF (s.expr.form # Expr.ACon) THEN
                  Assembler.InsertACon(s.expr);
                END;
              ELSIF (val < 0) & (val >= -8) THEN
                s.form := Scan.addq;
                s.expr := s.expr.op1.op2;
                IF (s.expr.form # Expr.ACon) THEN
                  Assembler.InsertACon(s.expr);
                END;
                Assembler.NegateConst(s.expr.op1);
              END;
            ELSIF (s2.form = Scan.move) & (s2.a0 = Stat.Long)
                & Match(s2.expr, s.expr2) & (s2.expr2.form = Expr.APD)
                & (s2.expr2.op1.form = Expr.SP)
                & ~RegUsedAfter(s.expr2, s2.next) THEN
              s.form := Scan.pea; s.expr2 := NIL;
              Stat.Remove(s2);
            ELSIF (s2.form = Scan.lea) & (s.expr.form = Expr.DA)
                & (s2.expr.form = Expr.DA) & Match(s2.expr.op1.op1, s.expr2)
                & ~RegUsedAfter(s.expr2, s2.next) THEN
              Expr.New(Expr.Add, x, Sym.inttyp);
              x.op1 := s.expr.op1.op2; x.op2 := s2.expr.op1.op2;
              s.expr.op1.op2 := x;
              h := s.expr2; s.expr2 := s2.expr2; s2.expr2 := h;
              s.form := Scan.move; s.a0 := s2.a0;
              Stat.Remove(s2);
              s := s.prev;
            END;

        ELSE
        END;
      END;
      s := s.next;
    END;

    IF Par.reass THEN
      (* remove unused labels *)
      s := begin;
      WHILE (s # NIL) & (s.form # Stat.End) DO
        IF s.form = Scan.label THEN
          IF NOT LabelUsed(s.expr.sym) THEN
            Stat.Remove(s);
          END;
        END;
        s := s.next;
      END;
    END;

    IF Par.highOpt THEN
(*      OptimizeContents(begin); buggy: produces illegal code *)
(*    OptimizeRegisters(begin);*)
    END;
  END;

  (* set ACon sizes *)
  s := begin;
  WHILE (s # NIL) & (s.form # Stat.End) DO
    CASE s.form OF

    | Scan.lsl, Scan.lsr, Scan.asl, Scan.asr,
      Scan.rol, Scan.ror, Scan.roxl, Scan.roxr,
      Scan.trap, Scan.addq, Scan.subq, Scan.moveq:
        IF (s.expr.form = Expr.ACon) OR (s.expr.form = Expr.Imm) THEN
          s.expr.typ := Sym.notyp
        END;

    | Scan.btst, Scan.bchg, Scan.bset, Scan.bclr:
        IF (s.expr.form = Expr.ACon) OR (s.expr.form = Expr.Imm) THEN
          s.expr.typ := Sym.inttyp
        END;

    ELSE
    END;
    s := s.next;
  END;

  (* calculate command lengths *)
  PrepareSysIfNeeded(begin);
  Stat.Environment(begin, sym, s);
  symbols := sym.syms;
  symbols.a0 := S.VAL( LONGINT, sym);
  LOOP
    Stat.ReadOptions(s);
    IF (s = NIL) THEN EXIT END;
    s.len := CommandLength(s);
    IF (s.form = Stat.End) THEN EXIT END;
    s := s.next;
  END;

  IF Par.opt & Par.highOpt THEN
    (* optimize branches *)
    Stat.Environment(begin, sym, s);
    s := begin;
    LOOP
      Stat.ReadOptions(s);
      IF (s = NIL) OR (s.form = Stat.End) THEN EXIT END;
      IF Par.opt THEN
        IF (s.form >= Scan.bra) & (s.form <= Scan.ble) & (s.a0 = Stat.Word) THEN
          IF ByteDistance(s, s.expr) THEN
            s.a0 := Stat.Byte; s.len := 2;
          END;
        ELSIF s.form = Scan.jsr THEN
          IF ByteDistance(s, s.expr) THEN
            s.form := Scan.bsr; s.a0 := Stat.Byte; s.len := 2;
          ELSIF WordDistance(s, s.expr) THEN
            s.form := Scan.bsr; s.a0 := Stat.Word; s.len := 4;
          END;
        END;
      END;
      s := s.next;
    END;
  END;

 END Optimize;


END OCAssOpt.