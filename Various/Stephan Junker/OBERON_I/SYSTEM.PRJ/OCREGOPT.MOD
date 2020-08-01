MODULE OCRegOpt; (* SJ 28.9.94 *)


IMPORT
  S:=SYSTEM, Stat:=OCStat, Sym:=OCSymbol, Expr:=OCExpr, Com:=OCCom,
  Assembler:=OCAssembler, Par:=OCPar, Strings;


VAR
  regCont: ARRAY 32 OF Sym.Symbol;
  freeRegs: SET;
  symbols: Sym.Symbol;
  firstStat, lastStat: Stat.Stat;	(* the optimizing area *)
  firstStatNo, lastStatNo: INTEGER;	(* dito as numbers *)


PROCEDURE InsertAsgn*(s: Stat.Stat; src, dest: Expr.Expr);
(*
 Insert an assignment statement in front of s assigning src to dest.
 *)
  VAR
    stat: Stat.Stat;
 BEGIN
  Stat.New(Stat.Asgn, stat); stat.expr := dest; stat.expr2 := src;
  Com.Insert(stat, s);
 END InsertAsgn;


PROCEDURE OptAndCont(s: Stat.Stat) : BOOLEAN;
 BEGIN
  RETURN (s.form = Stat.Asgn) OR (s.form = Stat.Bct) OR (s.form = Stat.Bcf)
 END OptAndCont;


PROCEDURE OptButStop(s: Stat.Stat) : BOOLEAN;
 BEGIN
  RETURN (s.form = Stat.Bra) OR (s.form = Stat.Call)
 END OptButStop;


PROCEDURE HasExpr2(s: Stat.Stat) : BOOLEAN;
 BEGIN
  RETURN (s.form = Stat.Asgn) OR (s.form = Stat.Bct) OR (s.form = Stat.Bcf)
 END HasExpr2;


PROCEDURE UsesSymbol(e: Expr.Expr; sym: Sym.Symbol) : BOOLEAN;
 BEGIN
  IF (e.form = Expr.Sym) & (e.sym = sym) THEN RETURN TRUE

  ELSIF Expr.HasOp1(e) THEN
    IF UsesSymbol(e.op1, sym) THEN RETURN TRUE END;
    IF Expr.HasOp2(e) THEN RETURN UsesSymbol(e.op2, sym) END;

  END;
  RETURN FALSE
 END UsesSymbol;


PROCEDURE FirstUsed(s: Stat.Stat; sym: Sym.Symbol) : Stat.Stat;
 BEGIN
  LOOP
    IF HasExpr2(s) THEN
      IF UsesSymbol(s.expr2, sym) THEN RETURN s END;
    END;
    IF UsesSymbol(s.expr, sym) THEN RETURN s END;
    s := s.next
  END;
 END FirstUsed;


PROCEDURE LastUsed(s: Stat.Stat; sym: Sym.Symbol) : Stat.Stat;
 BEGIN
  LOOP
    s := s.prev;
    IF HasExpr2(s) THEN
      IF UsesSymbol(s.expr2, sym) THEN RETURN s END;
    END;
    IF UsesSymbol(s.expr, sym) THEN RETURN s END;
  END;
 END LastUsed;


PROCEDURE InsertAsgnAfter(s, last: Stat.Stat; src, dest: Expr.Expr);
 BEGIN
  WHILE s # last DO
    IF s.form # Stat.Asgn THEN
      InsertAsgn(s, src, dest);
    END;
    s := s.next;
  END;
  IF (s.form = Stat.Asgn) THEN
    InsertAsgn(s.next, src, dest);
  ELSE
    InsertAsgn(s, src, dest);
  END;
 END InsertAsgnAfter;


PROCEDURE CountAcc(s: Stat.Stat; e: Expr.Expr);
 BEGIN
  IF e.form = Expr.Sym THEN
    e.a0 := 1;	(* may be replaced *)
    IF e.sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy} THEN
      INC(e.sym.priority);
    END;
    IF e = s.expr THEN (* dest *)
      e.sym.changed := TRUE;
    END;

  ELSIF e.form = Expr.Disp THEN
    CountAcc(s, e.op2);
    IF e.op1.form = Expr.Sym THEN
      IF e.op1.sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy} THEN
        e.op1.sym.priority := MIN(INTEGER)+10;	(* never in register *)
      END;
    ELSE
      CountAcc(s, e.op1);
    END;

  ELSIF e.form = Expr.ACon THEN

  ELSIF Expr.HasOp1(e) THEN
    CountAcc(s, e.op1);
    IF Expr.HasOp2(e) THEN CountAcc(s, e.op2) END;

  END;
 END CountAcc;


PROCEDURE InitRegs;
  VAR
    i: INTEGER;
 BEGIN
  FOR i := 0 TO 31 DO
    regCont[i] := NIL;
  END;
 END InitRegs;


PROCEDURE IsTempVar(sym: Sym.Symbol) : BOOLEAN;
  VAR
    sp: Strings.ptr;
 BEGIN
  sp := S.ADR(sym.name);
  RETURN (sp[0] = "T") & (sp[1] = "E") & (sp[2] = "M") & (sp[3] = "P")
 END IsTempVar;


PROCEDURE NoRegister(sym: Sym.Symbol) : BOOLEAN;
  VAR
    sp: Strings.ptr;
 BEGIN
  sp := S.ADR(sym.name);
  RETURN (sp[0] = "S") & (sp[1] = "E") & (sp[2] = "M") & (sp[3] = "P")
 END NoRegister;


PROCEDURE GetRegister(form: INTEGER; symbol: Sym.Symbol; addStat: LONGINT);
  VAR
    x: Expr.Expr;
    f, l, i, level, lowest, lowInx: INTEGER;
    sym, head: Sym.Symbol;
    prio: LONGINT;
    temp: BOOLEAN;
 BEGIN
  level := symbol.lev; prio := symbol.priority-addStat;
  temp := IsTempVar(symbol);
  IF NoRegister(symbol) OR ~temp & ((prio <= 1) OR (level < 0)) THEN RETURN END;
  CASE form OF
    Expr.Dn:  f := 3; l := 7;
  | Expr.An:  f := 10; l := 13;
      IF level > 1 THEN DEC(l, level-1) END;
  | Expr.FPn: f := 17; l := 23;
  END;
  FOR i := f TO l DO
    IF (regCont[i] = NIL) THEN  (* found free *)
      regCont[i] := symbol;
      symbol.a1 := i; RETURN ;
    END;
  END;

  (* search for a variable occupying a register of that form with a lower
     priority *)
  lowest := 30000;
  FOR i := f TO l DO
    sym := regCont[i];
    IF (sym.priority < lowest) THEN
      lowest := sym.priority;
      lowInx := i;
    END;
  END;

  IF lowest < prio THEN
    symbol.a1 := lowInx;
    regCont[lowInx].a1 := Sym.NoReg;
    regCont[lowInx] := symbol;
  END;

 END GetRegister;


PROCEDURE IsGlobal(sym: Sym.Symbol) : BOOLEAN;
(*
 Return true if sym is global for symbols.
 *)
  VAR
    s: Sym.Symbol;
 BEGIN
  IF IsTempVar(sym) THEN RETURN FALSE END;
  IF (sym.lev = 0)			(* global variable *)
      OR (sym.lev < symbols.lev) THEN	(* local variable of upper proc. *)
    RETURN TRUE;
  END;
  s := symbols;
  WHILE s.form # Sym.Sep DO
    IF s = sym THEN RETURN TRUE END;		(* proc. parameter *)
    s := s.next;
  END;
  WHILE s # NIL DO
    IF s.form IN {Sym.LProc,Sym.AProc} THEN	(* local proc. *)
      RETURN TRUE
    END;
    s := s.next;
  END;
  RETURN FALSE;
 END IsGlobal;


PROCEDURE PreloadNeeded(sym: Sym.Symbol; firstStatNo: INTEGER) : BOOLEAN;
(*
 Return true if sym has to be loaded if it is to be stored in a register in
 the statements from firstStatNo.
 *)
 BEGIN
  RETURN (sym.first < firstStatNo)	(* used previously *)
          OR IsGlobal(sym)
 END PreloadNeeded;


PROCEDURE LoopBack() : BOOLEAN;
(*
 Answer true if there is a path from firstStat to a previous statement.
 *)
  VAR
    s, s2: Stat.Stat;
 BEGIN
  s := firstStat;
  WHILE (s # NIL) & (s.form # Stat.End) DO
    IF (s.form = Stat.Bra) & Assembler.IsLabel(s.expr)
        OR (s.form = Stat.Bcf) OR (s.form = Stat.Bct) THEN
      s2 := firstStat.prev;
      WHILE (s2 # NIL) & (s2.form # Stat.Begin) DO
        IF (s2.form = Stat.Label) & (s2.expr.sym = s.expr.sym) THEN
          RETURN TRUE
        END;
        s2 := s2.prev;
      END;
    END;
    s := s.next;
  END;
  RETURN FALSE
 END LoopBack;


PROCEDURE ExprNeedsAddress(e: Expr.Expr; sym: Sym.Symbol) : BOOLEAN;
 BEGIN
  IF (e.form = Expr.Adr) & (e.op1.form = Expr.Sym) & (e.op1.sym = sym) THEN
    RETURN TRUE

  ELSIF Expr.HasOp1(e) THEN
    IF ExprNeedsAddress(e.op1, sym) THEN RETURN TRUE END;
    IF Expr.HasOp2(e) THEN RETURN ExprNeedsAddress(e.op2, sym) END;

  END;
  RETURN FALSE
 END ExprNeedsAddress;


PROCEDURE AddressNeeded(sym: Sym.Symbol) : BOOLEAN;
  VAR
    s: Stat.Stat;
 BEGIN
  s := firstStat;
  WHILE s # lastStat DO
    IF HasExpr2(s) THEN
      IF ExprNeedsAddress(s.expr2, sym) THEN RETURN TRUE END;
    END;
    IF ExprNeedsAddress(s.expr, sym) THEN RETURN TRUE END;
    s := s.next;
  END;
  RETURN FALSE
 END AddressNeeded;


PROCEDURE RestoreNeeded(sym: Sym.Symbol; lastStatNo: INTEGER) : BOOLEAN;
(*
 Return true if sym has to be stored in memory if it is to be stored in a
 register in the statements to lastStatNo.
 *)
 BEGIN
  RETURN sym.changed & ((sym.last >= lastStatNo)(* used afterwards *)
         OR IsGlobal(sym) OR (sym.first < firstStatNo) & LoopBack()
         OR AddressNeeded(sym))
 END RestoreNeeded;


PROCEDURE CalcAddStat(sym: Sym.Symbol; firstStatNo, lastStatNo: INTEGER;
                      VAR addStat: INTEGER);
 BEGIN
  addStat := 0;
  IF PreloadNeeded(sym, firstStatNo) THEN	(* preload *)
    INC(addStat)
  END;
  IF RestoreNeeded(sym, lastStatNo) THEN	(* restore *)
    INC(addStat);
  END;
 END CalcAddStat;


PROCEDURE SetRegister(s: Stat.Stat; e: Expr.Expr;
                      statNo, firstStatNo, lastStatNo: INTEGER);
  VAR
    addStat: INTEGER;
 BEGIN
  IF (e.form = Expr.Sym) & (e.sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy})
      & (e.sym.lev >= 0) THEN
    IF (e.sym.a1 = Sym.NoReg) THEN
      IF e.sym.first = statNo THEN
        CalcAddStat(e.sym, firstStatNo, lastStatNo, addStat);
        IF (e.sym.priority - addStat >= 2) THEN
          IF e.sym.typ.form IN { Sym.Byte, Sym.Bool, Sym.Char, Sym.SInt,
                                 Sym.Int, Sym.LInt, Sym.Set} THEN
            GetRegister( Expr.Dn, e.sym, addStat);
          ELSIF e.sym.typ.form IN {Sym.AnyPtr, Sym.Pointer, Sym.ProcTyp} THEN
            GetRegister( Expr.An, e.sym, addStat);
          ELSIF e.sym.typ.form IN {Sym.Real, Sym.LReal} THEN
            GetRegister( Expr.FPn, e.sym, addStat);
          END;
        END;
      END;
    ELSIF ~RestoreNeeded(e.sym, lastStatNo) & (e.sym.last = statNo) THEN
      e.a1 := 1;	(* may be changed *)
      INCL(freeRegs, e.sym.a1);
    END(*IF*);

  ELSIF e.form = Expr.ACon THEN

  ELSIF Expr.HasOp1(e) THEN
    SetRegister(s, e.op1, statNo, firstStatNo, lastStatNo);
    IF Expr.HasOp2(e) THEN
      SetRegister(s, e.op2, statNo, firstStatNo, lastStatNo);
    END;

  END;
 END SetRegister;


PROCEDURE ReplaceExpr(VAR x: Expr.Expr);
  VAR
    e: Expr.Expr;
 BEGIN
  e := x;
  IF (e.a0 = 1) & (e.form = Expr.Sym) & (e.sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy})
      & (e.sym.lev >= 0) & (e.sym.a1 # Sym.NoReg) THEN
    e.a0 := e.sym.a1;
    IF e.a0 >= 16 THEN
      DEC(e.a0, 16); e.form := Expr.FPn
    ELSIF e.a0 >= 8 THEN
      DEC(e.a0, 8); e.form := Expr.An
    ELSE
      e.form := Expr.Dn
    END;

  ELSIF e.form = Expr.ACon THEN

  ELSIF (e.form = Expr.Adr) & (e.op1.form = Expr.Sym) THEN

  ELSIF Expr.HasOp1(e) THEN
    ReplaceExpr(e.op1);
    IF Expr.HasOp2(e) THEN ReplaceExpr(e.op2) END;

  END;
 END ReplaceExpr;


PROCEDURE RegExpr(sym: Sym.Symbol) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  IF sym.a1 >= 16 THEN
    Expr.New( Expr.FPn, x, sym.typ);
    x.a0 := sym.a1 - 16;
  ELSIF sym.a1 >= 8 THEN
    Expr.New( Expr.An, x, sym.typ);
    x.a0 := sym.a1 - 8;
  ELSE
    Expr.New( Expr.Dn, x, sym.typ);
    x.a0 := sym.a1;
  END(*IF*);
  RETURN x;
 END RegExpr;


PROCEDURE SymExpr(sym: Sym.Symbol) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.Sym, x, sym.typ); x.sym := sym;
  x.a0 := 0;	(* do not replace *)
  RETURN x;
 END SymExpr;


PROCEDURE ShrinkVar(symbol: Sym.Symbol);
  VAR
    offset, size: LONGINT;
    sym: Sym.Symbol;
 BEGIN
(*  sym := symbol; not possible, local procedures!
  offset := sym.a0; size := sym.typ.size;
  IF size # 1 THEN
    IF ODD(size) THEN INC(size) END;
    WHILE sym # NIL DO
      IF (sym.form = Sym.Var) & (sym.lev > 0) & (sym.a0 < offset) THEN
        INC( sym.a0, size);
      END;
      sym := sym.next;
    END;
  END;*)
  Sym.DisposeSym(symbol);
 END ShrinkVar;


PROCEDURE FreeRegs(regs: SET);
  VAR
    i: INTEGER;
 BEGIN
  FOR i := 0 TO 31 DO
    IF i IN regs THEN regCont[i] := NIL END;
  END;
 END FreeRegs;


PROCEDURE OptimizePart(VAR first: Stat.Stat; VAR statNo: INTEGER);
(*
 Pass through the statements until reaching a statement which is not an
 assignment or containing a procedure call. Store the first and the last
 access to all variables and the number of accesses.
 Pass through all statements from s to last. Assign a register to every
 possible symbol. If no register is available, look for a variable with
 lower priority and take that register away. If a variable has a global
 value, preset and restore the register.
 *)
  VAR
    sym, head, psym: Sym.Symbol;
    s, last: Stat.Stat;
    firstNo, lastNo: INTEGER;
    preload, restore: BOOLEAN;
 BEGIN
  (* clear all priorities *)
  head := symbols;
  REPEAT
    sym := head;
    WHILE sym # NIL DO
      IF sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy} THEN
        sym.priority := 0; sym.a1 := Sym.NoReg;
        sym.changed := FALSE
      END;
      sym := sym.next;
    END;
    head := head.syms;
  UNTIL head = NIL;

  InitRegs;
  s := first; lastNo := statNo;
  WHILE OptAndCont(s) DO
    CountAcc(s, s.expr); CountAcc(s, s.expr2);
    s := s.next; INC(lastNo);
  END;
  IF OptButStop(s) THEN
    CountAcc(s, s.expr); s := s.next; INC(lastNo);
  END;
  firstStat := first; firstStatNo := statNo;
  lastStat := s; lastStatNo := lastNo;

  head := symbols;
  REPEAT
    sym := head;
    WHILE sym # NIL DO
      IF (sym.form = Sym.Var) & IsTempVar(sym) & (sym.priority >= 2) THEN
        INC(sym.priority, 1000 - sym.last + sym.first);
      END;
      sym := sym.next;
    END;
    head := head.syms;
  UNTIL head = NIL;

  last := s; s := first; firstNo := statNo;
  WHILE s # last DO
    IF HasExpr2(s) THEN
      SetRegister(s, s.expr2, statNo, firstNo, lastNo);
    END;
    SetRegister(s, s.expr, statNo, firstNo, lastNo);
    FreeRegs(freeRegs); freeRegs := {};
    s := s.next; INC(statNo);
  END;

  (* preload and restore *)
  head := symbols;
  REPEAT
    psym := head; sym := psym.next;
    WHILE sym # NIL DO
      IF (sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy})
          & (sym.a1 # Sym.NoReg) THEN
        preload := PreloadNeeded(sym, firstNo);
        IF preload THEN
          InsertAsgn( FirstUsed(first, sym), SymExpr(sym), RegExpr(sym));
        END;
        restore := RestoreNeeded(sym, lastNo);
        IF restore THEN
          InsertAsgnAfter( FirstUsed(first, sym), LastUsed(last, sym),
              RegExpr(sym), SymExpr(sym));
        END;
        IF ~preload & ~restore THEN	(* delete var *)
          psym.next := sym.next;
          ShrinkVar(sym);
          sym := psym;
        ELSE
          psym := sym;
        END;
      ELSE
        psym := sym;
      END;
      sym := sym.next;
    END;
    head := head.syms;
  UNTIL head = NIL;

  s := first;
  WHILE s # last DO
    IF HasExpr2(s) THEN ReplaceExpr(s.expr2) END;
    ReplaceExpr(s.expr);
    s := s.next;
  END;

  first := s;
 END OptimizePart;


PROCEDURE DoOptimize(VAR s: Stat.Stat; VAR statNo: INTEGER);
 BEGIN
  statNo := 1;
  LOOP
    Stat.ReadOptions(s);
    CASE s.form OF
      Stat.Asgn, Stat.Bct, Stat.Bcf:
          OptimizePart(s, statNo);

    | Stat.End:
        EXIT

    ELSE
        s := s.next; INC(statNo);

    END;
  END;
 END DoOptimize;


PROCEDURE StoreExpr(s: Stat.Stat; e: Expr.Expr; statNo: INTEGER);
 BEGIN
  IF e.form = Expr.Sym THEN
    IF e.sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy} THEN
      IF e.sym.first = 0 THEN
        e.sym.first := statNo;
      END;
      e.sym.last := statNo;
    END;

  ELSIF Expr.HasOp1(e) THEN
    StoreExpr(s, e.op1, statNo);
    IF Expr.HasOp2(e) THEN StoreExpr(s, e.op2, statNo) END;

  END;
 END StoreExpr;


PROCEDURE StoreAcc(s: Stat.Stat; VAR statNo: INTEGER);
 BEGIN
  CASE s.form OF
    Stat.Asgn:
      StoreExpr(s, s.expr, statNo); StoreExpr(s, s.expr2, statNo);

  | Stat.Call:
      StoreExpr(s, s.expr, statNo);

  | Stat.Bct, Stat.Bcf:
      StoreExpr(s, s.expr2, statNo);

  ELSE
      IF s.form >= Stat.Ass THEN
        IF s.expr # NIL THEN StoreExpr(s, s.expr, statNo) END(*IF*);
        IF s.expr2 # NIL THEN StoreExpr(s, s.expr2, statNo) END(*IF*);
      END;

  END;
  INC(statNo);
 END StoreAcc;


PROCEDURE StoreAccesses(s: Stat.Stat);
(*
 Pass through statements starting with s to the End statement. Store the
 statement number of the first and the last statement accessing a symbol.
 (s is statement 1)
 *)
  VAR
    statNo: INTEGER;
    sym, head: Sym.Symbol;
 BEGIN
  (* clear all accesses *)
  head := symbols;
  REPEAT
    sym := head;
    WHILE sym # NIL DO
      IF sym.form IN {Sym.Var, Sym.Ind, Sym.Cpy} THEN
        sym.first := 0; sym.last := 0;
      END;
      sym := sym.next;
    END;
    (* the following prevents endless loop. But who done it? *)
    IF head = head.syms THEN head.syms := NIL END;
    head := head.syms;
  UNTIL head = NIL;

  statNo := 1;
  WHILE s.form # Stat.End DO
    StoreAcc(s, statNo);
    s := s.next
  END;
 END StoreAccesses;


PROCEDURE Optimize*(begin: Stat.Stat);
  VAR
    statNo: INTEGER;
    s: Stat.Stat;
    sym: Sym.Symbol;
 BEGIN
  IF Par.opt THEN
    Stat.Environment(begin, sym, s);
    symbols := sym.syms;
    s := begin.next;
    StoreAccesses(s);
    statNo := 1;
    DoOptimize(s, statNo);
  END;
 END Optimize;


PROCEDURE Init*;
 BEGIN
 END Init;


PROCEDURE Exit*;
 BEGIN
  symbols := NIL;
  firstStat := NIL; lastStat := NIL;
 END Exit;


END OCRegOpt.