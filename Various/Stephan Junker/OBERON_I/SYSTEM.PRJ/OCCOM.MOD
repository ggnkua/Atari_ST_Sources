MODULE OCCom; (* SJ 2.10.94 *)


IMPORT
  S:=SYSTEM, Stat:=OCStat, Expr:=OCExpr, Sym:=OCSymbol, Scan:=OCScan,
  Import:=OCImport, Err:=OCErr, Strings, NumStr;


CONST
  nocall = 206;



VAR
  SysHalt-, SysCaseFail-, SysWithFail-, SysIndexFail-,
  SysTypeFail-, SysRetFail-, SysCheckStack-, SysCheckLongIndex-: Expr.Expr;
  StorageNew-, StorageSNew-, StorageDispose- : Expr.Expr;
  MemoryCopy- : Expr.Expr;
  Emu030MulsL-, Emu030MuluL-, Emu030DivsL-, Emu030DivuL-,
  Emu030MulslL-, Emu030MululL-, Emu030DivslL-, Emu030DivulL-,
  Emu030result-, Emu030result2-: Expr.Expr;
  EmuFPUFMoveSFF-, EmuFPUFMoveDFF-,
  EmuFPUFMoveSXF-, EmuFPUFMoveDXF-, EmuFPUFMoveLXF-,
  EmuFPUFMoveSFX-, EmuFPUFMoveDFX-, EmuFPUFMoveLFX-,
  EmuFPUFMulSFF-, EmuFPUFMulDFF-,
  EmuFPUFMulSXF-, EmuFPUFMulDXF-,
  EmuFPUFDivSFF-, EmuFPUFDivDFF-,
  EmuFPUFDivSXF-, EmuFPUFDivDXF-,
  EmuFPUFAddSFF-, EmuFPUFAddDFF-,
  EmuFPUFAddSXF-, EmuFPUFAddDXF-,
  EmuFPUFSubSFF-, EmuFPUFSubDFF-,
  EmuFPUFSubSXF-, EmuFPUFSubDXF-,
  EmuFPUFCmpSFF-, EmuFPUFCmpDFF-,
  EmuFPUFCmpSXF-, EmuFPUFCmpDXF-,
  EmuFPUFAbsSF-, EmuFPUFAbsDF-,
  EmuFPUFAbsSFF-, EmuFPUFAbsDFF-,
  EmuFPUFAbsSXF-, EmuFPUFAbsDXF-,
  EmuFPUFNegSF-, EmuFPUFNegDF-,
  EmuFPUFNegSFF-, EmuFPUFNegDFF-,
  EmuFPUFNegSXF-, EmuFPUFNegDXF-,
  EmuFPUresult- : Expr.Expr;
  varpos* : INTEGER;
  stack* : LONGINT;
  stackx : INTEGER;
  storedStack : ARRAY 10 OF LONGINT;
  label  : INTEGER;		(* counting labels *)
  tempcnt: INTEGER;



PROCEDURE TempVar*(symbols: Sym.Symbol; typ: Sym.Struct; VAR temp: Expr.Expr);
  VAR
    sym: Sym.Symbol;
    name: ARRAY 10 OF CHAR;
 BEGIN
  DEC(varpos, SHORT( typ.size) );
  IF (typ.size # 1) & ODD(varpos) THEN DEC(varpos) END;
  NumStr.IntTo(tempcnt, 10, name); INC(tempcnt);
  Strings.Insert("TEMP", 0, name);
  Sym.NewSymNamed(Sym.Var, name, sym); sym.typ := typ;
  sym.a0 := varpos; sym.lev := symbols.lev;
  IF sym.lev = 0 THEN sym.lev := 1 END;
  sym.a1 := Sym.NoReg;
  Sym.InsertIn(symbols, sym);
  Expr.New(Expr.Sym, temp, typ); temp.sym := sym;
 END TempVar;


PROCEDURE Temporize*(symbols: Sym.Symbol; VAR x: Expr.Expr);
(*
 Initialize a temporary variable and assign it x. Return an expression for
 that variable.
 *)
  VAR
    temp: Expr.Expr;
    stat: Stat.Stat;
 BEGIN
  IF Expr.Temporizable(x) THEN
    TempVar(symbols, x.typ, temp);
    Stat.New(Stat.Asgn, stat); stat.expr := temp; stat.expr2 := x;
    Stat.Add(stat);
    x := temp;
  END;
 END Temporize;


PROCEDURE RetTyp*(x: Expr.Expr) : Sym.Struct;
(*
 Return the return type for the procedure defined by x. If it is no
 procedure, return Sym.notyp.
 *)
 BEGIN
  IF x.typ.form = Sym.ProcTyp THEN
    RETURN x.typ.base
  ELSIF x.form = Expr.Sym THEN
    IF x.sym.form IN {Sym.LProc, Sym.CProc, Sym.IProc, Sym.AProc, Sym.Tbp} THEN
      RETURN x.sym.typ;
    END;
  ELSIF x.typ.form = Sym.TbpStr THEN
    RETURN x.sym.typ;
  END(*IF*);
  RETURN Sym.notyp;
 END RetTyp;


PROCEDURE NewLabel*(VAR s: Stat.Stat);
  VAR
    x: Expr.Expr;
    sym: Sym.Symbol;
    name: ARRAY 10 OF CHAR;
 BEGIN
  NumStr.IntTo(label, 10, name);
  Strings.Insert("LABEL", 0, name);
  INC(label);
  Sym.NewSymNamed( Sym.Label, name, sym);
  sym.typ := Sym.linttyp; sym.lev := 0;
  Expr.New(Expr.Sym, x, Sym.linttyp);
  x.sym := sym;
  Stat.New(Stat.Label, s); s.expr := x;
  s.a0 := 0;
 END NewLabel;


PROCEDURE GetLabel*(VAR name: ARRAY OF CHAR);
  VAR
    str: ARRAY 10 OF CHAR;
    int: INTEGER;
 BEGIN
  IF (name[0] = "L") & (name[1] = "A") & (name[2] = "B") & (name[3] = "E")
      & (name[4] = "L") THEN
    Strings.Excerpt(5, 10, name, str);
    int := NumStr.ToInt(10, str);
    IF int >= label THEN label := int+1 END;
  END;
 END GetLabel;


PROCEDURE AddStat*(s: Stat.Stat);
(*
 Use this procedure to add a statement because it clears the hasComplexExpr
 variable.
 *)
 BEGIN
  Stat.Add(s);
 END AddStat;


PROCEDURE Insert*(s, next: Stat.Stat);
(*
 Use this procedure to insert a statement because it clears the
 hasComplexExpr variable.
 *)
 BEGIN
  Stat.Insert(s, next);
 END Insert;


PROCEDURE AddTwoExprStat(form: INTEGER; expr, expr2: Expr.Expr);
  VAR
    s: Stat.Stat;
 BEGIN
  Stat.New(form, s); s.expr := expr; s.expr2 := expr2;
  AddStat(s);
 END AddTwoExprStat;


PROCEDURE AddOneExprStat(form: INTEGER; expr: Expr.Expr);
  VAR
    s: Stat.Stat;
 BEGIN
  Stat.New(form, s); s.expr := expr;
  AddStat(s);
 END AddOneExprStat;


PROCEDURE BranchFalse*(x: Expr.Expr; lab: Stat.Stat);
 BEGIN
  AddTwoExprStat(Stat.Bcf, lab.expr, x);
 END BranchFalse;


PROCEDURE BranchTrue*(x: Expr.Expr; lab: Stat.Stat);
 BEGIN
  AddTwoExprStat(Stat.Bct, lab.expr, x);
 END BranchTrue;


PROCEDURE^ Asgn*(dest, src: Expr.Expr);


PROCEDURE BranchTo*(x: Expr.Expr);
 BEGIN
  AddOneExprStat(Stat.Bra, x);
 END BranchTo;


PROCEDURE Bra*(dest: Expr.Expr);
 BEGIN
  AddOneExprStat(Stat.Bra, dest);
 END Bra;


PROCEDURE Base*(label: Expr.Expr);
 BEGIN
  AddOneExprStat(Stat.Base, label);
 END Base;


PROCEDURE Dcw*(data: Expr.Expr);
 BEGIN
  AddOneExprStat(Stat.Dcw, data);
 END Dcw;


PROCEDURE PrepareSysProc*(proc: Expr.Expr);
  CONST
    Sys = "Sys"; Storage = "Storage"; EmuFPU = "EmuFPU";
    Emu030 = "Emu030"; Emu68k = "Emu68k"; Memory = "Memory";
  VAR
    mod: Sym.Symbol;
    sym: Sym.Symbol;
    sp : Strings.ptr;
 BEGIN
  IF (proc.sym.name[0] <= "9") THEN
    CASE proc.sym.name[0] OF
      "0": sp := S.ADR(Sys);
    | "1": sp := S.ADR(Storage);
    | "2": sp := S.ADR(EmuFPU);
    | "3": sp := S.ADR(Emu030);
    | "4": sp := S.ADR(Emu68k);
    | "5": sp := S.ADR(Memory);
    END;
    Strings.Delete(0, 1, proc.sym.name);
    IF NOT Sym.SearchModule(sp^, mod) THEN(* not already imported or used *)
      Sym.NewSymNamed( Sym.Mod, sp^, mod);
      mod.a0 := S.VAL(LONGINT, sp);
      Import.GlobalModule(mod, 0);
      Import.modno := -1-Import.nofgmod;
      Sym.NewSym( Sym.Head, mod.syms);
      Sym.InsertIn( Sym.global, mod);
      mod.syms.next := NIL;
    END;
    COPY(proc.sym.name, Scan.name);
    IF Sym.SearchInList( Import.SymList(mod), sym) THEN
      proc.sym := sym;
    ELSE
      Sym.InsertIn( Import.SymList(mod), proc.sym);
      proc.sym.lev := mod.lev;
      INC(proc.sym.a0, mod.lev*1000000H);
    END;
  END;
 END PrepareSysProc;


PROCEDURE TwoOpExpr*(form: INTEGER; typ: Sym.Struct; op1, op2: Expr.Expr)
                     : Expr.Expr;
(*
 Use this procedure to produce a complex expression with two operands.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( form, x, typ); x.op1 := op1; x.op2 := op2;
  RETURN x;
 END TwoOpExpr;


PROCEDURE OneOpExpr*(form: INTEGER; typ: Sym.Struct; op: Expr.Expr)
                     : Expr.Expr;
(*
 Use this procedure to produce a complex expression with one operand.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( form, x, typ); x.op1 := op;
  RETURN x;
 END OneOpExpr;


PROCEDURE Const*(val: LONGINT; typ: Sym.Struct) : Expr.Expr;
(*
 Return an expression representing the number val.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.Con, x, typ); x.a0 := val;
  RETURN x;
 END Const;


PROCEDURE AConst*(val: LONGINT; typ: Sym.Struct) : Expr.Expr;
(*
 Same as Const but as ACon.
 *)
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.ACon, x, typ); x.op1 := Const(val, typ);
  RETURN x;
 END AConst;


PROCEDURE Dn*(reg: INTEGER; typ: Sym.Struct) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.Dn, x, typ); x.a0 := reg;
  RETURN x;
 END Dn;


PROCEDURE An*(reg: INTEGER; typ: Sym.Struct) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.An, x, typ); x.a0 := reg;
  RETURN x;
 END An;


PROCEDURE FPn*(reg: INTEGER; typ: Sym.Struct) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.FPn, x, typ); x.a0 := reg;
  RETURN x;
 END FPn;


PROCEDURE SP*() : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.SP, x, Sym.linttyp); RETURN x;
 END SP;


PROCEDURE MSP*() : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.PreDec, x, Sym.linttyp); x.op1 := SP(); RETURN x;
 END MSP;


PROCEDURE SPP*() : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.PostInc, x, Sym.linttyp); x.op1 := SP(); RETURN x;
 END SPP;


PROCEDURE Push*(x: Expr.Expr);
(*
 Push x onto the stack and the store the amount of bytes in order to
 restore the stack after pushing.
 *)
  VAR
    msp : Expr.Expr;
 BEGIN
  msp := MSP(); msp.typ := x.typ;
  Asgn( msp, x);
  INC(stack, x.typ.size);
  IF ODD(x.typ.size) THEN INC(stack) END;
 END Push;


PROCEDURE Call*(proc: Expr.Expr);
(*
 Attention: Changes Scan.name if system procedures are called!
 *)
  CONST
    Sys = "Sys"; Storage = "Storage"; EmuFPU = "EmuFPU";
    Emu030 = "Emu030"; Emu68k = "Emu68k"; Memory = "Memory";
  VAR
    mod: Sym.Symbol;
    sym: Sym.Symbol;
    sp : Strings.ptr;
 BEGIN
  IF (proc.form = Expr.Sym) & (proc.sym.name[0] <= "9") THEN
    PrepareSysProc(proc);
  END;
  IF (proc.form = Expr.Sym) & (proc.sym.form = Sym.CProc) THEN
    Push( AConst(proc.sym.a1, Sym.inttyp) );
  END;
  AddOneExprStat(Stat.Call, proc);
  IF proc.form = Sym.AProc THEN
    Err.Mark(nocall)
  END;
 END Call;


PROCEDURE Deref*(op: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
 BEGIN
  IF ((op.form = Expr.Adr) OR (op.form = Expr.ACon))
      & (op.op1.typ.form # Sym.String) THEN
    op.op1.typ := typ;
    RETURN op.op1
  ELSE
    RETURN OneOpExpr(Expr.Deref, typ, op);
  END;
 END Deref;


PROCEDURE ACon*(y: Expr.Expr) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New(Expr.ACon, x, y.typ); x.op1 := y;
  RETURN x;
 END ACon;


PROCEDURE Adr*(op: Expr.Expr) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  IF op.form = Expr.Deref THEN
    op.op1.typ := Sym.ptrtyp; RETURN op.op1
  ELSIF (op.form = Expr.Sym) & (op.sym.lev <= 0)
        OR (op.form = Expr.Con) & (op.typ.form = Sym.String) THEN
    x := ACon(op); x.typ := Sym.ptrtyp;
    RETURN x;
  ELSE
    RETURN OneOpExpr(Expr.Adr, Sym.ptrtyp, op);
  END;
 END Adr;


PROCEDURE Ret*(proc: Expr.Expr) : Expr.Expr;
 BEGIN
  RETURN OneOpExpr(Expr.Ret, RetTyp(proc), proc);
 END Ret;


PROCEDURE RetStat*(proc: Sym.Symbol; ret: Expr.Expr; lev : INTEGER);
  VAR
    s: Stat.Stat;
    x: Expr.Expr;
 BEGIN
  IF ret # NIL THEN
    Expr.New( Expr.Sym, x, Sym.notyp); x.sym := proc;
    x := Ret(x);
    Asgn( x, ret);
  END;
  Stat.New( Stat.Ret, s); s.a0 := lev;
  AddStat( s);
 END RetStat;


PROCEDURE Short*(x: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
  VAR
    r: REAL; lr: LONGREAL;
 BEGIN
  IF Expr.IsConst(x) & (typ.form IN {Sym.SInt, Sym.Int}) THEN
    x.typ := typ; RETURN x;
  ELSIF x.form = Expr.Con THEN
    IF typ.form = Sym.LInt THEN
      x.a0 := S.TRUNC( S.VAL( REAL, x.a0) );
    ELSE	(* Real *)
      S.GET( S.ADR( x.a0), lr);
      x.a0 := S.VAL( LONGINT, SHORT( lr) );
    END;
    x.typ := typ; RETURN x;
  ELSE
    RETURN OneOpExpr(Expr.Short, typ, x);
  END;
 END Short;


PROCEDURE Long*(x: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
  VAR
    r: REAL; lr: LONGREAL;
 BEGIN
  IF Expr.IsConst(x) & (typ.form IN {Sym.Int, Sym.LInt}) THEN
    x.typ := typ; RETURN x;
  ELSIF x.form = Expr.Con THEN
    IF typ.form = Sym.Real THEN
      r := x.a0; x.a0 := S.VAL( LONGINT, r)
    ELSE	(* LReal *)
      lr := S.VAL( REAL, x.a0);
      S.PUT( S.ADR( x.a0), lr);
    END;
    x.typ := typ; RETURN x;
  ELSE
    RETURN OneOpExpr(Expr.Long, typ, x);
  END;
 END Long;


PROCEDURE ULong*(x: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
 BEGIN
  RETURN OneOpExpr(Expr.ULong, typ, x);
 END ULong;


PROCEDURE TD*(y: Sym.Struct) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New(Expr.TD, x, Sym.ptrtyp); x.a0 := S.VAL( LONGINT, y);
  RETURN x;
 END TD;


PROCEDURE PostInc*(y: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
 BEGIN
  RETURN OneOpExpr(Expr.PostInc, typ, y);
 END PostInc;


PROCEDURE Not*(y: Expr.Expr) : Expr.Expr;
 BEGIN
  RETURN OneOpExpr(Expr.Not, y.typ, y);
 END Not;


PROCEDURE Neg*(y: Expr.Expr) : Expr.Expr;
 BEGIN
  RETURN OneOpExpr(Expr.Neg, y.typ, y);
 END Neg;


PROCEDURE Cmp*(op1, op2: Expr.Expr; rel: INTEGER) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  Expr.New( Expr.Cmp, x, Sym.booltyp);
  x.op1 := op1; x.op2 := op2; x.a0 := rel;
  RETURN x;
 END Cmp;


PROCEDURE Sub*(op1, op2: Expr.Expr) : Expr.Expr;
 BEGIN
  RETURN TwoOpExpr(Expr.Sub, op1.typ, op1, op2);
 END Sub;


PROCEDURE Add*(op1, op2: Expr.Expr) : Expr.Expr;
 BEGIN
  RETURN TwoOpExpr(Expr.Add, op1.typ, op1, op2);
 END Add;


PROCEDURE Mul*(op1, op2: Expr.Expr) : Expr.Expr;
  VAR
    ext: BOOLEAN;
    x  : Expr.Expr;
 BEGIN
  ext := op1.typ.size = 1;	(* no muls.b *)
  IF ext THEN
    op1 := Long(op1, Sym.inttyp); op2 := Long(op2, Sym.inttyp);
  END;
  x := TwoOpExpr(Expr.Mul, op1.typ, op1, op2);
  IF ext THEN
    x := Short(x, Sym.sinttyp);
  END;
  RETURN x;
 END Mul;


PROCEDURE Check*(inx, bnd: Expr.Expr) : Expr.Expr;
 BEGIN
  RETURN TwoOpExpr(Expr.Check, inx.typ, inx, bnd);
 END Check;


PROCEDURE ExtendTo*(op: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
 BEGIN
  IF op.typ.size < typ.size THEN
    IF Expr.IsConst(op) THEN
      op.typ := typ
    ELSE
      IF (op.typ.size = 1) THEN
        op := Long(op, Sym.inttyp);
      END;
      IF (typ.size = 4) THEN
        op := Long(op, Sym.linttyp);
      END;
    END;
  END;
  RETURN op;
 END ExtendTo;


PROCEDURE Disp*(op, disp: Expr.Expr; typ: Sym.Struct) : Expr.Expr;
  VAR
    x: Expr.Expr;
 BEGIN
  IF op.form = Expr.Disp THEN
    op.op2 := Add( ExtendTo(op.op2, disp.typ),
                   ExtendTo(disp, op.op2.typ) );
    op.typ := typ;
    RETURN op;
  END;
  Expr.New( Expr.Disp, x, typ); x.op1 := op; x.op2 := disp;
  RETURN x;
 END Disp;


PROCEDURE Asgn*(dest, src: Expr.Expr);
 BEGIN
  IF (src.typ.form = Sym.ProcStr) & (src.form = Expr.Sym)
      & (src.sym.form = Sym.AProc) THEN
    AddTwoExprStat(Stat.Asgn, Disp( src, Const(2, Sym.sinttyp), Sym.ptrtyp),
        An(6, Sym.ptrtyp) );
  END;
  AddTwoExprStat(Stat.Asgn, dest, src);
 END Asgn;


PROCEDURE Set*(op1, op2: Expr.Expr) : Expr.Expr;
 BEGIN
  IF op1 = op2 THEN op2 := NIL END;
  RETURN TwoOpExpr(Expr.Set, Sym.settyp, op1, op2);
 END Set;


PROCEDURE ProcLevel(x: Expr.Expr) : INTEGER;
 BEGIN
  IF (x.form = Expr.Sym)
      & (x.sym.form IN {Sym.LProc, Sym.CProc, Sym.IProc, Sym.AProc}) THEN
    IF x.sym.lev < 0 THEN RETURN 0 END;
    RETURN x.sym.lev
  ELSIF (x.typ.form IN {Sym.ProcTyp, Sym.TbpStr, Sym.ProcStr}) THEN
    RETURN 0
  END(*IF*);
  HALT(99);
 END ProcLevel;


PROCEDURE StoreStack*(proc: Expr.Expr);
(*
 Push registers needed which may be destroyed by proc (link registers)
 and store current stack value.
 *)
  VAR
    proclev: INTEGER;
 BEGIN
  proclev := ProcLevel(proc);
  IF Sym.level > proclev+1 THEN
    IF Sym.level = proclev+2 THEN
      AddTwoExprStat(Stat.Asgn, MSP(), An(7-Sym.level, Sym.ptrtyp) );
    ELSE
      AddTwoExprStat(Stat.Asgn, MSP(),
          OneOpExpr( Expr.Rlst, Sym.notyp,
              TwoOpExpr( Expr.Sub, Sym.notyp,
                  An(7-Sym.level, Sym.ptrtyp),
                  An(5-proclev, Sym.ptrtyp))) );
    END;
  END;
  storedStack[stackx] := stack;
  INC(stackx);
 END StoreStack;


PROCEDURE RestoreStack*(proc: Expr.Expr);
(*
 Restore stack and registers.
 *)
  VAR
    s: Stat.Stat;
    x: Expr.Expr;
    proclev: INTEGER;
 BEGIN
  DEC(stackx);
  IF storedStack[stackx] # stack THEN
    x := SP();
    Asgn( x, Add( x, Const(stack - storedStack[stackx], Sym.linttyp) ) );
    stack := storedStack[stackx];
  END;
  proclev := ProcLevel(proc);
  IF Sym.level > proclev+1 THEN
    IF Sym.level = proclev+2 THEN
      AddTwoExprStat(Stat.Asgn, An(7-Sym.level, Sym.ptrtyp), SPP() );
    ELSE
      AddTwoExprStat(Stat.Asgn,
          OneOpExpr( Expr.Rlst, Sym.notyp,
              TwoOpExpr( Expr.Sub, Sym.notyp,
                  An(7-Sym.level, Sym.ptrtyp),
                  An(5-proclev, Sym.ptrtyp))),
          SPP() );
    END;
  END;
 END RestoreStack;


PROCEDURE Init*;
  VAR
    sym: Sym.Symbol;
 BEGIN
  (* 0 is used for Sys *)
  Sym.NewSymNamed( Sym.LProc, "0halt", sym);
  Expr.New( Expr.Sym, SysHalt, Sym.notyp);
  SysHalt.sym := sym; sym.a0 := 0C00001H;
  Expr.MarkUsed(SysHalt);
  Sym.NewSymNamed( Sym.LProc, "0CaseFail", sym);
  Expr.New( Expr.Sym, SysCaseFail, Sym.notyp);
  SysCaseFail.sym := sym; sym.a0 := 0C00002H;
  Expr.MarkUsed(SysCaseFail);
  Sym.NewSymNamed( Sym.LProc, "0WithFail", sym);
  Expr.New( Expr.Sym, SysWithFail, Sym.notyp);
  SysWithFail.sym := sym; sym.a0 := 0C00003H;
  Expr.MarkUsed(SysWithFail);
  Sym.NewSymNamed( Sym.LProc, "0IndexFail", sym);
  Expr.New( Expr.Sym, SysIndexFail, Sym.notyp);
  SysIndexFail.sym := sym; sym.a0 := 0C00004H;
  Expr.MarkUsed(SysIndexFail);
  Sym.NewSymNamed( Sym.LProc, "0TypeFail", sym);
  Expr.New( Expr.Sym, SysTypeFail, Sym.notyp);
  SysTypeFail.sym := sym; sym.a0 := 0C00005H;
  Expr.MarkUsed(SysTypeFail);
  Sym.NewSymNamed( Sym.LProc, "0RetFail", sym);
  Expr.New( Expr.Sym, SysRetFail, Sym.notyp);
  SysRetFail.sym := sym; sym.a0 := 0C00006H;
  Expr.MarkUsed(SysRetFail);
  Sym.NewSymNamed( Sym.LProc, "0CheckStack", sym);
  Expr.New( Expr.Sym, SysCheckStack, Sym.notyp);
  SysCheckStack.sym := sym; sym.a0 := 0C00007H;
  Expr.MarkUsed(SysCheckStack);
  Sym.NewSymNamed( Sym.LProc, "0CheckLongIndex", sym);
  Expr.New( Expr.Sym, SysCheckLongIndex, Sym.notyp);
  SysCheckLongIndex.sym := sym; sym.a0 := 0C00008H;
  Expr.MarkUsed(SysCheckLongIndex);

  (* 1 is used for Storage *)
  Sym.NewSymNamed( Sym.LProc, "1New", sym);
  Expr.New( Expr.Sym, StorageNew, Sym.notyp);
  StorageNew.sym := sym; sym.a0 := 0C00001H;
  Expr.MarkUsed(StorageNew);
  Sym.NewSymNamed( Sym.LProc, "1SNew", sym);
  Expr.New( Expr.Sym, StorageSNew, Sym.notyp);
  StorageSNew.sym := sym; sym.a0 := 0C00002H;
  Expr.MarkUsed(StorageSNew);
  Sym.NewSymNamed( Sym.LProc, "1Dispose", sym);
  Expr.New( Expr.Sym, StorageDispose, Sym.notyp);
  StorageDispose.sym := sym; sym.a0 := 0C00003H;
  Expr.MarkUsed(StorageDispose);

  (* 2 is used for EmuFPU *)
  Sym.NewSymNamed( Sym.LProc, "2FMoveSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveSFF, Sym.notyp);
  EmuFPUFMoveSFF.sym := sym; sym.a0 := 0C00001H;
  Expr.MarkUsed(EmuFPUFMoveSFF);
  Sym.NewSymNamed( Sym.LProc, "2FMoveDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveDFF, Sym.notyp);
  EmuFPUFMoveDFF.sym := sym; sym.a0 := 0C00002H;
  Expr.MarkUsed(EmuFPUFMoveDFF);
  Sym.NewSymNamed( Sym.LProc, "2FMoveSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveSXF, Sym.notyp);
  EmuFPUFMoveSXF.sym := sym; sym.a0 := 0C00003H;
  Expr.MarkUsed(EmuFPUFMoveSXF);
  Sym.NewSymNamed( Sym.LProc, "2FMoveDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveDXF, Sym.notyp);
  EmuFPUFMoveDXF.sym := sym; sym.a0 := 0C00004H;
  Expr.MarkUsed(EmuFPUFMoveDXF);
  Sym.NewSymNamed( Sym.LProc, "2FMoveLXF", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveLXF, Sym.notyp);
  EmuFPUFMoveLXF.sym := sym; sym.a0 := 0C00005H;
  Expr.MarkUsed(EmuFPUFMoveLXF);
  Sym.NewSymNamed( Sym.LProc, "2FMoveSFX", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveSFX, Sym.notyp);
  EmuFPUFMoveSFX.sym := sym; sym.a0 := 0C00006H;
  Expr.MarkUsed(EmuFPUFMoveSFX);
  Sym.NewSymNamed( Sym.LProc, "2FMoveDFX", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveDFX, Sym.notyp);
  EmuFPUFMoveDFX.sym := sym; sym.a0 := 0C00007H;
  Expr.MarkUsed(EmuFPUFMoveDFX);
  Sym.NewSymNamed( Sym.LProc, "2FMoveLFX", sym);
  Expr.New( Expr.Sym, EmuFPUFMoveLFX, Sym.notyp);
  EmuFPUFMoveLFX.sym := sym; sym.a0 := 0C00008H;
  Expr.MarkUsed(EmuFPUFMoveLFX);
  Sym.NewSymNamed( Sym.LProc, "2FMulSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFMulSFF, Sym.notyp);
  EmuFPUFMulSFF.sym := sym; sym.a0 := 0C00009H;
  Expr.MarkUsed(EmuFPUFMulSFF);
  Sym.NewSymNamed( Sym.LProc, "2FMulDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFMulDFF, Sym.notyp);
  EmuFPUFMulDFF.sym := sym; sym.a0 := 0C0000AH;
  Expr.MarkUsed(EmuFPUFMulDFF);
  Sym.NewSymNamed( Sym.LProc, "2FMulSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFMulSXF, Sym.notyp);
  EmuFPUFMulSXF.sym := sym; sym.a0 := 0C0000BH;
  Expr.MarkUsed(EmuFPUFMulSXF);
  Sym.NewSymNamed( Sym.LProc, "2FMulDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFMulDXF, Sym.notyp);
  EmuFPUFMulDXF.sym := sym; sym.a0 := 0C0000CH;
  Expr.MarkUsed(EmuFPUFMulDXF);
  Sym.NewSymNamed( Sym.LProc, "2FDivSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFDivSFF, Sym.notyp);
  EmuFPUFDivSFF.sym := sym; sym.a0 := 0C0000DH;
  Expr.MarkUsed(EmuFPUFDivSFF);
  Sym.NewSymNamed( Sym.LProc, "2FDivDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFDivDFF, Sym.notyp);
  EmuFPUFDivDFF.sym := sym; sym.a0 := 0C0000EH;
  Expr.MarkUsed(EmuFPUFDivDFF);
  Sym.NewSymNamed( Sym.LProc, "2FDivSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFDivSXF, Sym.notyp);
  EmuFPUFDivSXF.sym := sym; sym.a0 := 0C0000FH;
  Expr.MarkUsed(EmuFPUFDivSXF);
  Sym.NewSymNamed( Sym.LProc, "2FDivDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFDivDXF, Sym.notyp);
  EmuFPUFDivDXF.sym := sym; sym.a0 := 0C00010H;
  Expr.MarkUsed(EmuFPUFDivDXF);
  Sym.NewSymNamed( Sym.LProc, "2FAddSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFAddSFF, Sym.notyp);
  EmuFPUFAddSFF.sym := sym; sym.a0 := 0C00011H;
  Expr.MarkUsed(EmuFPUFAddSFF);
  Sym.NewSymNamed( Sym.LProc, "2FAddDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFAddDFF, Sym.notyp);
  EmuFPUFAddDFF.sym := sym; sym.a0 := 0C00012H;
  Expr.MarkUsed(EmuFPUFAddDFF);
  Sym.NewSymNamed( Sym.LProc, "2FAddSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFAddSXF, Sym.notyp);
  EmuFPUFAddSXF.sym := sym; sym.a0 := 0C00013H;
  Expr.MarkUsed(EmuFPUFAddSXF);
  Sym.NewSymNamed( Sym.LProc, "2FAddDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFAddDXF, Sym.notyp);
  EmuFPUFAddDXF.sym := sym; sym.a0 := 0C00014H;
  Expr.MarkUsed(EmuFPUFAddDXF);
  Sym.NewSymNamed( Sym.LProc, "2FSubSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFSubSFF, Sym.notyp);
  EmuFPUFSubSFF.sym := sym; sym.a0 := 0C00015H;
  Expr.MarkUsed(EmuFPUFSubSFF);
  Sym.NewSymNamed( Sym.LProc, "2FSubDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFSubDFF, Sym.notyp);
  EmuFPUFSubDFF.sym := sym; sym.a0 := 0C00016H;
  Expr.MarkUsed(EmuFPUFSubDFF);
  Sym.NewSymNamed( Sym.LProc, "2FSubSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFSubSXF, Sym.notyp);
  EmuFPUFSubSXF.sym := sym; sym.a0 := 0C00017H;
  Expr.MarkUsed(EmuFPUFSubSXF);
  Sym.NewSymNamed( Sym.LProc, "2FSubDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFSubDXF, Sym.notyp);
  EmuFPUFSubDXF.sym := sym; sym.a0 := 0C00018H;
  Expr.MarkUsed(EmuFPUFSubDXF);
  Sym.NewSymNamed( Sym.LProc, "2FCmpSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFCmpSFF, Sym.notyp);
  EmuFPUFCmpSFF.sym := sym; sym.a0 := 0C00019H;
  Expr.MarkUsed(EmuFPUFCmpSFF);
  Sym.NewSymNamed( Sym.LProc, "2FCmpDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFCmpDFF, Sym.notyp);
  EmuFPUFCmpDFF.sym := sym; sym.a0 := 0C0001AH;
  Expr.MarkUsed(EmuFPUFCmpDFF);
  Sym.NewSymNamed( Sym.LProc, "2FCmpSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFCmpSXF, Sym.notyp);
  EmuFPUFCmpSXF.sym := sym; sym.a0 := 0C0001BH;
  Expr.MarkUsed(EmuFPUFCmpSXF);
  Sym.NewSymNamed( Sym.LProc, "2FCmpDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFCmpDXF, Sym.notyp);
  EmuFPUFCmpDXF.sym := sym; sym.a0 := 0C0001CH;
  Expr.MarkUsed(EmuFPUFCmpDXF);
  Sym.NewSymNamed( Sym.LProc, "2FAbsSF", sym);
  Expr.New( Expr.Sym, EmuFPUFAbsSF, Sym.notyp);
  EmuFPUFAbsSF.sym := sym; sym.a0 := 0C0001DH;
  Expr.MarkUsed(EmuFPUFAbsSF);
  Sym.NewSymNamed( Sym.LProc, "2FAbsDF", sym);
  Expr.New( Expr.Sym, EmuFPUFAbsDF, Sym.notyp);
  EmuFPUFAbsDF.sym := sym; sym.a0 := 0C0001EH;
  Expr.MarkUsed(EmuFPUFAbsDF);
  Sym.NewSymNamed( Sym.LProc, "2FAbsSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFAbsSFF, Sym.notyp);
  EmuFPUFAbsSFF.sym := sym; sym.a0 := 0C0001FH;
  Expr.MarkUsed(EmuFPUFAbsSFF);
  Sym.NewSymNamed( Sym.LProc, "2FAbsDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFAbsDFF, Sym.notyp);
  EmuFPUFAbsDFF.sym := sym; sym.a0 := 0C00020H;
  Expr.MarkUsed(EmuFPUFAbsDFF);
  Sym.NewSymNamed( Sym.LProc, "2FAbsSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFAbsSXF, Sym.notyp);
  EmuFPUFAbsSXF.sym := sym; sym.a0 := 0C00021H;
  Expr.MarkUsed(EmuFPUFAbsSXF);
  Sym.NewSymNamed( Sym.LProc, "2FAbsDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFAbsDXF, Sym.notyp);
  EmuFPUFAbsDXF.sym := sym; sym.a0 := 0C00022H;
  Expr.MarkUsed(EmuFPUFAbsDXF);
  Sym.NewSymNamed( Sym.LProc, "2FNegSF", sym);
  Expr.New( Expr.Sym, EmuFPUFNegSF, Sym.notyp);
  EmuFPUFNegSF.sym := sym; sym.a0 := 0C00023H;
  Expr.MarkUsed(EmuFPUFNegSF);
  Sym.NewSymNamed( Sym.LProc, "2FNegDF", sym);
  Expr.New( Expr.Sym, EmuFPUFNegDF, Sym.notyp);
  EmuFPUFNegDF.sym := sym; sym.a0 := 0C00024H;
  Expr.MarkUsed(EmuFPUFNegDF);
  Sym.NewSymNamed( Sym.LProc, "2FNegSFF", sym);
  Expr.New( Expr.Sym, EmuFPUFNegSFF, Sym.notyp);
  EmuFPUFNegSFF.sym := sym; sym.a0 := 0C00025H;
  Expr.MarkUsed(EmuFPUFNegSFF);
  Sym.NewSymNamed( Sym.LProc, "2FNegDFF", sym);
  Expr.New( Expr.Sym, EmuFPUFNegDFF, Sym.notyp);
  EmuFPUFNegDFF.sym := sym; sym.a0 := 0C00026H;
  Expr.MarkUsed(EmuFPUFNegDFF);
  Sym.NewSymNamed( Sym.LProc, "2FNegSXF", sym);
  Expr.New( Expr.Sym, EmuFPUFNegSXF, Sym.notyp);
  EmuFPUFNegSXF.sym := sym; sym.a0 := 0C00027H;
  Expr.MarkUsed(EmuFPUFNegSXF);
  Sym.NewSymNamed( Sym.LProc, "2FNegDXF", sym);
  Expr.New( Expr.Sym, EmuFPUFNegDXF, Sym.notyp);
  EmuFPUFNegDXF.sym := sym; sym.a0 := 0C00028H;
  Expr.MarkUsed(EmuFPUFNegDXF);
  Sym.NewSymNamed( Sym.Var, "2result", sym);
  Expr.New( Expr.Sym, EmuFPUresult, Sym.notyp);
  EmuFPUresult.sym := sym; sym.a0 := 0400002H;
  Expr.MarkUsed(EmuFPUresult);

  (* 3 is used for Emu030 *)
  Sym.NewSymNamed( Sym.LProc, "3MulsL", sym);
  Expr.New( Expr.Sym, Emu030MulsL, Sym.notyp);
  Emu030MulsL.sym := sym; sym.a0 := 0C00001H;
  Expr.MarkUsed(Emu030MulsL);
  Sym.NewSymNamed( Sym.LProc, "3MuluL", sym);
  Expr.New( Expr.Sym, Emu030MuluL, Sym.notyp);
  Emu030MuluL.sym := sym; sym.a0 := 0C00002H;
  Expr.MarkUsed(Emu030MuluL);
  Sym.NewSymNamed( Sym.LProc, "3DivsL", sym);
  Expr.New( Expr.Sym, Emu030DivsL, Sym.notyp);
  Emu030DivsL.sym := sym; sym.a0 := 0C00003H;
  Expr.MarkUsed(Emu030DivsL);
  Sym.NewSymNamed( Sym.LProc, "3DivuL", sym);
  Expr.New( Expr.Sym, Emu030DivuL, Sym.notyp);
  Emu030DivuL.sym := sym; sym.a0 := 0C00004H;
  Expr.MarkUsed(Emu030DivuL);
  Sym.NewSymNamed( Sym.LProc, "3MulslL", sym);
  Expr.New( Expr.Sym, Emu030MulslL, Sym.notyp);
  Emu030MulslL.sym := sym; sym.a0 := 0C00005H;
  Expr.MarkUsed(Emu030MulslL);
  Sym.NewSymNamed( Sym.LProc, "3MululL", sym);
  Expr.New( Expr.Sym, Emu030MululL, Sym.notyp);
  Emu030MululL.sym := sym; sym.a0 := 0C00006H;
  Expr.MarkUsed(Emu030MululL);
  Sym.NewSymNamed( Sym.LProc, "3DivslL", sym);
  Expr.New( Expr.Sym, Emu030DivslL, Sym.notyp);
  Emu030DivslL.sym := sym; sym.a0 := 0C00007H;
  Expr.MarkUsed(Emu030DivslL);
  Sym.NewSymNamed( Sym.LProc, "3DivulL", sym);
  Expr.New( Expr.Sym, Emu030DivulL, Sym.notyp);
  Emu030DivulL.sym := sym; sym.a0 := 0C00008H;
  Expr.MarkUsed(Emu030DivulL);
  Sym.NewSymNamed( Sym.Var, "3result", sym);
  Expr.New( Expr.Sym, Emu030result, Sym.notyp);
  Emu030result.sym := sym; sym.a0 := 0400002H;
  Expr.MarkUsed(Emu030result);
  Sym.NewSymNamed( Sym.Var, "3result2", sym);
  Expr.New( Expr.Sym, Emu030result2, Sym.notyp);
  Emu030result2.sym := sym; sym.a0 := 0400006H;
  Expr.MarkUsed(Emu030result2);

  (* 4 is used for Emu68k *)

  (* 5 is used for Memory *)
  Sym.NewSymNamed( Sym.LProc, "5Copy", sym);
  Expr.New( Expr.Sym, MemoryCopy, Sym.notyp);
  MemoryCopy.sym := sym; sym.a0 := 0C00001H;
  Expr.MarkUsed(MemoryCopy);

  stack := 0; label := 0; tempcnt := 0;
  stackx := 0;
 END Init;


PROCEDURE Exit*;
 BEGIN
  SysHalt:=NIL; SysCaseFail:=NIL; SysWithFail:=NIL; SysIndexFail:=NIL;
  SysTypeFail:=NIL; SysRetFail:=NIL; SysCheckStack:=NIL; StorageNew:=NIL;
  StorageSNew:=NIL; StorageDispose:=NIL; MemoryCopy:=NIL; Emu030MulsL:=NIL;
  Emu030MuluL:=NIL; Emu030DivsL:=NIL; Emu030DivuL:=NIL; Emu030MulslL:=NIL;
  Emu030MululL:=NIL; Emu030DivslL:=NIL; Emu030DivulL:=NIL;
  Emu030result:=NIL; Emu030result2:=NIL; EmuFPUFMoveSFF:=NIL;
  EmuFPUFMoveDFF:=NIL; EmuFPUFMoveSXF:=NIL; EmuFPUFMoveDXF:=NIL;
  EmuFPUFMoveLXF:=NIL; EmuFPUFMoveSFX:=NIL; EmuFPUFMoveDFX:=NIL;
  EmuFPUFMoveLFX:=NIL; EmuFPUFMulSFF:=NIL; EmuFPUFMulDFF:=NIL;
  EmuFPUFMulSXF:=NIL; EmuFPUFMulDXF:=NIL; EmuFPUFDivSFF:=NIL;
  EmuFPUFDivDFF:=NIL; EmuFPUFDivSXF:=NIL; EmuFPUFDivDXF:=NIL;
  EmuFPUFAddSFF:=NIL; EmuFPUFAddDFF:=NIL; EmuFPUFAddSXF:=NIL;
  EmuFPUFAddDXF:=NIL; EmuFPUFSubSFF:=NIL; EmuFPUFSubDFF:=NIL;
  EmuFPUFSubSXF:=NIL; EmuFPUFSubDXF:=NIL; EmuFPUFCmpSFF:=NIL;
  EmuFPUFCmpDFF:=NIL; EmuFPUFCmpSXF:=NIL; EmuFPUFCmpDXF:=NIL;
  EmuFPUFAbsSF:=NIL; EmuFPUFAbsDF:=NIL; EmuFPUFAbsSFF:=NIL;
  EmuFPUFAbsDFF:=NIL; EmuFPUFAbsSXF:=NIL; EmuFPUFAbsDXF:=NIL;
  EmuFPUFNegSF:=NIL; EmuFPUFNegDF:=NIL; EmuFPUFNegSFF:=NIL;
  EmuFPUFNegDFF:=NIL; EmuFPUFNegSXF:=NIL; EmuFPUFNegDXF:=NIL;
  EmuFPUresult:=NIL;
 END Exit;


END OCCom.