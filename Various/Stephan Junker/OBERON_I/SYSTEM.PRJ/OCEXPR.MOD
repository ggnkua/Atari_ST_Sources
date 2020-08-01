MODULE OCExpr; (* SJ 24.9.94 *)

(*
 The type Expr is needed for any kind of expressions used in Oberon
 source code.
 What you must do to add new expressions:
 Choose a form constant and place it in the right group. The groups are
 divided into simple expressions without operands, single operand
 expressions and double operand expressions. If necessary, enter the usage
 of the universal record fields in the comment table. Maybe you also need
 to add fields to ExprD.
 Then some procedures here must be extended:
   Output: Implement a suitable ascii output.
   Evaluate: Evaluate all constant expressions.
   Complex: Return true if an expression is complex enough to be separated.
 *)

IMPORT
  S:=SYSTEM, Symbol:=OCSymbol, Scan:=OCScan, IO:=OCOutput, Err:=OCErr,
  Strings, CIO:=IO;



CONST
  Free = -1;    (* unused expr *)

  (* simple expressions *)
  Dn* = 0;    (* data register direct *)
  An* = Dn+1;    (* address register direct *)
  ARI* = An+1;    (* address register indirect *)
  API* = ARI+1;    (* ARI with postincrement *)
  APD* = API+1;    (* ARI with predecrement *)
  DA* = APD+1;    (* ARI with 16 bit distance *)
  DAX* = DA+1;    (* ARI with index reg plus scale and upto 32 bit dist *)
  AbsW* = DAX+1;  (* absloute word *)
  AbsL* = AbsW+1;  (* absolute long *)
  Mem* = AbsL+1;  (* memory direct *)
  MIPo* = Mem+1;  (* memory indirect postindexed; (An + bd) + Xm.Size * Scale + od *)
  MIPr* = MIPo+1;  (* memory indirect preindexed; (An + Xm.Size * Scale + bd) + od *)
  PCD* = MIPr+1;  (* PC indirect with distance *)
  PCDI* = PCD+1;  (* PC indirect with distance and index *)
  PCPo* = PCDI+1;  (* PC indirect postindexed *)
  PCPr* = PCPo+1;  (* PC indirect preindexed *)
  Imm* = PCPr+1;  (* immediate *)
  DDn* = Imm+1;    (* double data register, Dxreg:Dreg *)
  Rlst* = DDn+1;  (* register list *)
  FRlst* = Rlst+1;  (* fpu register list *)
  CCR* = FRlst+1;  (* CCR *)
  SR* = CCR+1;    (* SR *)
  USP* = SR+1;    (* USP *)
  SFR* = USP+1;    (* special function register of 68030 *)
  FPn* = SFR+1;    (* floating point register direct *)
  SP* = FPn+1;    (* Stack pointer *)
  Ind* = SP+1;    (* [...] *)
  PC* = Ind+1;    (* PC *)

  Def* = 30;    (* default expression for errors *)
  Sym* = Def+1;    (* a symbol access *)
  Con* = Sym+1;    (* any number or string *)
  Coc* = Con+1;    (* condition code *)
  Ret* = Coc+1;    (* a procedure return value *)
  TD* = Ret+1;    (* type descriptor of op *)
  Tbp* = TD+1;    (* no further use *)
  XReg* = Tbp+1;  (* reg.size *)
  LSimple* = 39;

  (* single operand expressions *)
  FSingle* = 40;
  Neg* = FSingle;  (* - op *)
  Not* = Neg+1;    (* ~ op *)
  Ntl* = Not+1;    (* NTL(op) *)
  Adr* = Ntl+1;    (* ADR(op) *)
  Long* = Adr+1;  (* LONG(op) *)
  Deref* = Long+1;  (* op^ *)
  Trunc* = Deref+1;  (* TRUNC(op) *)
  Abs* = Trunc+1;  (* ABS(op) *)
  Cap* = Abs+1;    (* CAP(op) *)
  Ord* = Cap+1;    (* ORD(op) *)
  Entier* = Ord+1;  (* ENTIER(op) *)
  Odd* = Entier+1;  (* ODD(op) *)
  Chr* = Odd+1;    (* CHR(op) *)
  Swap* = Chr+1;  (* SWAP(op) *)
  PreDec* = Swap+1;  (* decrement op1 and indirect *)
  PostInc* = PreDec+1;  (* indirect and increment *)
  Short* = PostInc+1;  (* SHORT(op) *)
  ACon* = Short+1;  (* #op *)
  ULong* = ACon+1;  (* LONG(op) *)
  LSingle* = 69;

  (* dual operand expressions *)
  FDual* = 70;
  Mul* = FDual;    (* op1 * op2 *)
  Div* = Mul+1;    (* op1 DIV op2 *)
  Mod* = Div+1;    (* op1 MOD op2 *)
  Add* = Mod+1;    (* op1 + op2 *)
  Sub* = Add+1;    (* op1 - op2 *)
  RDv* = Sub+1;    (* op1 / op2 *)
  And* = RDv+1;    (* op1 & op2 *)
  Or*  = And+1;    (* op1 OR op2 *)
  Anl* = Or+1;    (* ANL(op1, op2) *)
  Orl* = Anl+1;    (* ORL(op1, op2) *)
  Xol* = Orl+1;    (* XOL(op1, op2) *)
  Lsh* = Xol+1;    (* LSH(op1, op2) *)
  Ash* = Lsh+1;    (* ASH(op1, op2) *)
  Rot* = Ash+1;    (* ROT(op1, op2) *)
  Bit* = Rot+1;    (* BIT(op1, op2) *)
  In*  = Bit+1;    (* op1 IN op2 *)
  Asgn* = In+1;    (* op1 := op2 *)
  Disp* = Asgn+1;  (* op, disp *)
  Set* = Disp+1;  (* {op1..op2} *)
  Check* = Set+1;  (* CHECK(op1, op2) *)
  DynArr* = Check+1;  (* array[size] *)
  Cmp* = DynArr+1;  (* op1 <rel> op2 *)
  LDual* = 99;

  (* error codes *)
  intonly = 116; const=Scan.const;

  (* codes for operation *)
  noop = 0; relop = 1; addop = 2; mulop = 3;


(* record field usage:

Expr
form  sym  op1  op2  a0  a1
--------------------------------------------------------------------------
Def
Sym  sym
Con        value  xvalue
- String      offset  addr
ACon    con
Coc        cc
Ret    proc
TD        typ

Dn        reg  change
An        reg  change
FPn        reg  change

FSingle..  op
..LSingle

FDouble..  op1  op2
..LDouble
Cmp    op1  op2  relop

*)


TYPE
  Expr*     = POINTER TO ExprD;
  ExprD*    = RECORD
                form*: INTEGER;    (* see const *)
                typ* : Symbol.Struct;
                a0*  : LONGINT;
                a1*  : LONGINT;
                op1*, op2* : Expr;
                sym* : Symbol.Symbol;
                next : LONGINT;    (* only for collecting *)
              END;



VAR
  symbol* : Symbol.Symbol;  (* set by Stat *)
  reloc-  : BOOLEAN;    (* set by Evaluate *)
  baselab*: LONGINT;    (* set by OCCoder, subtracted from labels *)
  operation: INTEGER;
  freeExprs: Expr;
  allExprs : Expr;



PROCEDURE New*(form: INTEGER; VAR x: Expr; typ: Symbol.Struct);
 BEGIN
  IF freeExprs = NIL THEN
    Symbol.Alloc( SIZE(ExprD), x);
    x.next := S.VAL( LONGINT, allExprs); allExprs := x;
  ELSE
    x := freeExprs; freeExprs := freeExprs.op1;
  END;
  x.form := form; x.typ := typ;
  x.a1 := 0;
 END New;


PROCEDURE Dispose(x: Expr);
 BEGIN
  IF x.form = Free THEN RETURN END;  (* already free *)
  x.op1 := freeExprs; freeExprs := x;
  x.form := Free;
 END Dispose;


PROCEDURE DisposeAll*;
(*
 Dispose all expressions which are not marked to be used.
 *)
  VAR
    e: Expr;
 BEGIN
  e := allExprs;
  WHILE e # NIL DO
    IF e.next > 0 THEN  (* not used *)
      Dispose(e)
    END;
    e := ABS(e.next);
  END;
 END DisposeAll;


PROCEDURE HasOp1*(x: Expr) : BOOLEAN;
 BEGIN
  RETURN (x.form >= ARI) & (x.form <= FRlst)
         OR (x.form = Ind) OR (x.form = XReg)
         OR (x.form >= FSingle)
 END HasOp1;


PROCEDURE HasOp2*(x: Expr) : BOOLEAN;
 BEGIN
  RETURN (x.form = DDn) OR (x.form >= FDual) & (x.op2 # NIL)
 END HasOp2;


PROCEDURE MarkUsed*(x: Expr);
(*
 Mark x as an expression still used (and used until the end, thus may never
 be disposed). Also mark its subexpressions.
 *)
 BEGIN
  IF x.next < 0 THEN RETURN END;  (* already marked *)
  x.next := -x.next;
  IF HasOp1(x) THEN MarkUsed(x.op1) END;
  IF HasOp2(x) THEN MarkUsed(x.op2) END;
  IF (x.form = Sym) & (x.sym.form = Symbol.Con) THEN
    MarkUsed( S.VAL( Expr, x.sym.a1) )
  END;
 END MarkUsed;


PROCEDURE Temporizable*(x: Expr) : BOOLEAN;
 BEGIN
  RETURN ~(x.typ.form IN {Symbol.String, Symbol.Array..Symbol.Record})
 END Temporizable;


PROCEDURE IsConst*(x: Expr) : BOOLEAN;
(*
 Returns true if x is a constant expression.
 *)
 BEGIN
  RETURN
    (x.form = Con)
    OR (x.form = ACon)
    OR (x.form = TD)
    OR (x.form = Sym) & (x.sym.form IN {Symbol.Con, Symbol.Label})
    OR HasOp1(x) & IsConst(x.op1)
      & (x.form # Bit) & (x.form # Deref) & (x.form # Disp)
      & (~HasOp2(x) OR IsConst(x.op2));
 END IsConst;


PROCEDURE Complex*(x: Expr) : BOOLEAN;
(*
 Return true if an expression is complex enough to be separated.
 *)
 BEGIN
  RETURN ~IsConst(x) & (x.form >= FSingle) & (x.form # Ret) & (x.form # TD)
         & (x.form # PreDec) & (x.form # PostInc)
 END Complex;

(*$T- *)

PROCEDURE CopyCont*(x, y: Expr);
  VAR
    next: LONGINT;
 BEGIN
  next := y.next;
  y^ := x^;
  y.next := next;
 END CopyCont;


PROCEDURE Copy*(x: Expr) : Expr;
  VAR
    y: Expr;
 BEGIN
  New(Def, y, Symbol.undftyp);
  CopyCont(x, y);
  RETURN y;
 END Copy;


PROCEDURE DeepCopy*(x: Expr) : Expr;
  VAR
    y: Expr;
 BEGIN
  New(Def, y, Symbol.undftyp);
  CopyCont(x, y);
  IF HasOp1(x) THEN
    y.op1 := DeepCopy(x.op1);
  END;
  IF HasOp2(x) THEN
    y.op2 := DeepCopy(x.op2);
  END;
  RETURN y;
 END DeepCopy;


PROCEDURE BuildSet*(from, to: LONGINT) : SET;
(*
 replaces the expression {from..to} which does not function in V1.24
 *)
  VAR
    set: SET;
    h: LONGINT;
 BEGIN
  IF from > to THEN h := from; from := to; to := h END;  (* from < to *)
  set := {};
  from := from MOD 32; to := to MOD 32;
  WHILE from <= to DO
    INCL(set, from); INC(from);
  END;
  RETURN set;
 END BuildSet;


PROCEDURE^ EvaluateReal(e: Expr) : REAL;


PROCEDURE EvaluateInt(e: Expr) : LONGINT;
  VAR
    val1, val2: LONGINT;
    bl : BOOLEAN;
    typ: Symbol.Struct;
 BEGIN
  IF ((e.form # Sym) OR (e.sym.form = Symbol.Con))
      & ((e.form # Add) OR (e.op1.form # Sym) OR (e.op1.sym.typ = e.typ)) THEN
    IF e.typ.form = Symbol.Real THEN
      RETURN S.VAL( LONGINT, EvaluateReal(e));
    ELSIF e.typ.form = Symbol.LReal THEN
      HALT(99)
    END;
  END;
  CASE e.form OF
    Con:
      IF e.typ.form = Symbol.String THEN reloc := TRUE END;
      RETURN e.a0;

  | Sym:
      IF e.sym.form = Symbol.Con THEN
        RETURN EvaluateInt( S.VAL( Expr, e.sym.a1) );
      ELSIF e.sym.form = Symbol.Label THEN
        IF baselab # 0 THEN RETURN e.sym.a0-baselab END;
        reloc := ~reloc;
        RETURN e.sym.a0;
      ELSE
        IF e.sym.form IN {Symbol.Var, Symbol.Ind, Symbol.Cpy} THEN
          reloc := e.sym.lev <= 0;
        ELSE
          reloc := TRUE
        END;
        RETURN e.sym.a0;
      END;

  | TD:
      typ := S.VAL( Symbol.Struct, e.a0);
      reloc := TRUE;
      RETURN typ.a0;

  | Neg:
      RETURN -EvaluateInt(e.op1)

  | Not:
      RETURN S.XOL( EvaluateInt(e.op1), 1);

  | Ntl:
      RETURN S.NTL( EvaluateInt(e.op1) )

  | Adr:
      IF e.op1.typ.form = Symbol.String THEN
        HALT(100);
      ELSE
        Err.Mark(const)
      END;

  | Long, Ord, Chr, Short, AbsL, AbsW, ACon, Imm:
      RETURN EvaluateInt(e.op1);

  | Mem:
      reloc := TRUE;
      RETURN EvaluateInt(e.op1);

  | ULong:
      val1 := EvaluateInt(e.op1);
      IF e.typ.form = Symbol.LInt THEN
        RETURN S.ANL(val1, 0FFFFH);
      ELSE
        RETURN S.ANL(val1, 0FFH);
      END(*IF*);

  | Mul:
      RETURN EvaluateInt(e.op1) * EvaluateInt(e.op2);

  | Div:
      RETURN EvaluateInt(e.op1) DIV EvaluateInt(e.op2);

  | Mod:
      RETURN EvaluateInt(e.op1) MOD EvaluateInt(e.op2);

  | Add:
      RETURN EvaluateInt(e.op1) + EvaluateInt(e.op2);

  | Sub:
      RETURN EvaluateInt(e.op1) - EvaluateInt(e.op2);

  | Anl, And:
      RETURN S.ANL(EvaluateInt(e.op1), EvaluateInt(e.op2) );

  | Or, Orl:
      RETURN S.ORL( EvaluateInt(e.op1),  EvaluateInt(e.op2) );

  | Xol:
      RETURN S.XOL(EvaluateInt(e.op1), EvaluateInt(e.op2))

  | Lsh:
      RETURN S.LSH(EvaluateInt(e.op1), EvaluateInt(e.op2))

  | Ash:
      RETURN ASH(EvaluateInt(e.op1), EvaluateInt(e.op2))

  | Rot:
      RETURN S.ROT(EvaluateInt(e.op1), EvaluateInt(e.op2))

  | In:
      IF EvaluateInt(e.op1) IN S.VAL(SET, EvaluateInt(e.op2)) THEN
        RETURN 1;
      ELSE
        RETURN 0;
      END(*IF*);

  | Set:
      IF e.op2 = NIL THEN
        RETURN S.VAL( LONGINT, {EvaluateInt(e.op1)});
      END;
(*      RETURN S.VAL(LONGINT, {EvaluateInt(e.op1)..EvaluateInt(e.op2)} )
compiler error V1.24 *)
      RETURN S.VAL(LONGINT, BuildSet(EvaluateInt(e.op1), EvaluateInt(e.op2)) )

  | Abs:
      RETURN ABS( EvaluateInt(e.op1) );

  | Cap:
      RETURN S.VAL(SHORTINT, CAP( S.VAL(CHAR, EvaluateInt(e.op1))));

  | Odd:
      bl := ODD(EvaluateInt(e.op1));
      RETURN S.VAL(SHORTINT, bl);

  | Cmp:
      val1 := EvaluateInt(e.op1);
      val2 := EvaluateInt(e.op2);
      CASE e.a0 OF
        Scan.eql:
          bl := val1 = val2;
      | Scan.neq:
          bl := val1 # val2;
      | Scan.lss:
          bl := val1 < val2;
      | Scan.leq:
          bl := val1 <= val2;
      | Scan.gtr:
          bl := val1 > val2;
      | Scan.geq:
          bl := val1 >= val2;
      END;
      RETURN S.VAL(SHORTINT, bl);

  ELSE
      Err.Mark(const)
  END;
  RETURN 0;
 END EvaluateInt;


PROCEDURE Evaluate*(e: Expr) : LONGINT;
(*
 Evaluate the expression e. If it is not constant or the result is not an
 integer, an error message is written.
 *)
 BEGIN
  reloc := FALSE; RETURN EvaluateInt(e);
 END Evaluate;


PROCEDURE^ EvaluateLReal(e: Expr; VAR lr: LONGREAL);


PROCEDURE EvaluateReal(e: Expr) : REAL;
  VAR
    lr: LONGREAL;
    r : REAL;
 BEGIN
  CASE e.form OF
    Con:
      RETURN S.VAL( REAL, e.a0);

  | ACon, Imm:
      RETURN EvaluateReal(e.op1);

  | Sym:
      IF e.sym.form = Symbol.Con THEN
        RETURN EvaluateReal( S.VAL( Expr, e.sym.a1) );
      ELSE
        Err.Mark(const)
      END;

  | Neg:
      RETURN -EvaluateReal(e.op1)

  | Long:
      r := Evaluate(e.op1);
      RETURN r;

  | Short:
      EvaluateLReal(e.op1, lr);
      RETURN SHORT( lr);

  | Mul:
      RETURN EvaluateReal(e.op1) * EvaluateReal(e.op2);

  | RDv:
      RETURN EvaluateReal(e.op1) / EvaluateReal(e.op2);

  | Add:
      RETURN EvaluateReal(e.op1) + EvaluateReal(e.op2);

  | Sub:
      RETURN EvaluateReal(e.op1) - EvaluateReal(e.op2);

  | Abs:
      RETURN ABS( EvaluateReal(e.op1) );

  ELSE
      Err.Mark(const)
  END;
  RETURN 0.0;
 END EvaluateReal;


PROCEDURE EvaluateLReal(e: Expr; VAR result: LONGREAL);
  VAR
    lr, lr2: LONGREAL;
 BEGIN
  CASE e.form OF
    Con:
      S.GET( S.ADR(e.a0), lr);

  | ACon, Imm:
      EvaluateLReal(e.op1, lr);

  | Sym:
      IF e.sym.form = Symbol.Con THEN
        EvaluateLReal( S.VAL( Expr, e.sym.a1), lr );
      ELSE
        Err.Mark(const)
      END;

  | Neg:
      EvaluateLReal(e.op1, lr);
      lr := -lr;

  | Long:
      lr := EvaluateReal(e.op1);

  | Mul:
      EvaluateLReal(e.op1, lr);
      EvaluateLReal(e.op2, lr2);
      lr := lr * lr2;

  | RDv:
      EvaluateLReal(e.op1, lr);
      EvaluateLReal(e.op2, lr2);
      lr := lr / lr2;

  | Add:
      EvaluateLReal(e.op1, lr);
      EvaluateLReal(e.op2, lr2);
      lr := lr + lr2;

  | Sub:
      EvaluateLReal(e.op1, lr);
      EvaluateLReal(e.op2, lr2);
      lr := lr - lr2;

  | Abs:
      EvaluateLReal(e.op1, lr);
      lr := ABS(lr);

  ELSE
      Err.Mark(const)
  END;
  result := lr;
 END EvaluateLReal;


PROCEDURE EvaluateExpr*(x: Expr) : Expr;
  VAR
    y: Expr;
    lr: LONGREAL;
 BEGIN
  New(Con, y, x.typ);
  IF x.typ.form = Symbol.Real THEN
    y.a0 := S.VAL( LONGINT, EvaluateReal(x) );
  ELSIF x.typ.form = Symbol.LReal THEN
    EvaluateLReal(x, lr);
    S.PUT( S.ADR(y.a0), lr);
  ELSIF x.typ.form = Symbol.String THEN
    WHILE x.form = Sym DO
      IF x.sym.form # Symbol.Con THEN HALT(99) END;
      x := S.VAL( Expr, x.sym.a1);
    END;
    IF x.form # Con THEN HALT(99) END;
    y.a0 := x.a0; y.a1 := x.a1;
  ELSE
    y.a0 := Evaluate(x);
  END;
  RETURN y;
 END EvaluateExpr;


PROCEDURE TryWriteModule*(sym: Symbol.Symbol);
  VAR
    s, s2: Symbol.Symbol;
 BEGIN
  s := Symbol.global;
  WHILE s # NIL DO
    IF (s.form = Symbol.Mod) & (s.mark = 0) THEN
      s2 := s.syms;
      WHILE s2 # NIL DO
        IF s2 = sym THEN
          IO.WriteString( s.name);
          IO.WriteChar( ".");
          RETURN ;
        END;
        s2 := s2.next;
      END;
    END;
    s := s.next;
  END;
 END TryWriteModule;


PROCEDURE SymbolOf*(typ: Symbol.Struct; VAR fnd : Symbol.Symbol) : BOOLEAN;
(*
 Tries to find a symbol of form Typ with a type identical to typ.
 *)
  VAR
    h, s: Symbol.Symbol;

  PROCEDURE SearchList(s: Symbol.Symbol; VAR fnd: Symbol.Symbol) : BOOLEAN;
   BEGIN
    WHILE s # NIL DO
      IF (s.form = Symbol.Typ) & Symbol.SameType(s.typ, typ) THEN
        fnd := s; RETURN TRUE
      ELSIF (s.form = Symbol.Mod) THEN
        IF SearchList(s.syms, fnd) THEN RETURN TRUE END;
      END;
      s := s.next;
    END;
    RETURN FALSE
   END SearchList;

 BEGIN
  h := symbol.syms;
  REPEAT
    IF SearchList(h.next, s) THEN
      fnd := s; RETURN TRUE
    END;
    h := h.syms;
  UNTIL h = NIL;
  RETURN FALSE;
 END SymbolOf;


PROCEDURE XSymbolOf(typ: Symbol.Struct; VAR fnd : Symbol.Symbol) : BOOLEAN;
  VAR
    sym: Symbol.Symbol;
 BEGIN
  IF SymbolOf(typ, fnd) THEN RETURN TRUE END;
  sym := Symbol.global;
  WHILE sym # NIL DO
    IF (sym.form IN {Symbol.Typ, Symbol.Var})
        & (Symbol.SameType(sym.typ, typ)
          OR (sym.typ.form = Symbol.Pointer)
             & Symbol.SameType(sym.typ.base, typ)) THEN
      fnd := sym;
      RETURN TRUE
    END;
    sym := sym.next;
  END;
  RETURN FALSE
 END XSymbolOf;


PROCEDURE Output*(e: Expr; first: BOOLEAN);
  VAR
    sp: Strings.ptr;
    lr: LONGREAL;
    sym: Symbol.Symbol;

  PROCEDURE WriteCon(e: Expr);
    VAR
      i: INTEGER;
      set: SET;
      written: BOOLEAN;
   BEGIN
    CASE e.typ.form OF
      Symbol.String:
        sp:= S.VAL( Strings.ptr, e.a1);
        IO.WriteChar( 22X);
        IO.WriteString( sp^);
        IO.WriteChar( 22X);
    | Symbol.Char:
        IF (e.a0 < 20H) OR (e.a0 >= 7FH) THEN
          IF e.a0 >= 80H THEN IO.WriteChar( "0") END;
          IO.WriteFInt( e.a0, 16, IO.right, 2, "0");
          IO.WriteChar( "X");
        ELSE
          IO.WriteChar( 22X);
          IO.WriteChar( CHR(e.a0));
          IO.WriteChar( 22X);
        END;
    | Symbol.Real:
        IO.WriteReal( S.VAL(REAL, e.a0), 6, IO.noadj, 0, 0X);
    | Symbol.LReal:
        S.GET( S.ADR( e.a0), lr);
        IO.WriteLReal( SHORT(lr), 6, IO.noadj, 0, 0X);
    | Symbol.Set:
        IO.WriteChar( "{");
        set := S.VAL(SET, e.a0); written := FALSE;
        FOR i := 0 TO 31 DO
          IF (i IN set)
               & ((i = 0) OR ~(i-1 IN set) OR (i = 31) OR ~(i+1 IN set)) THEN
            IF written THEN IO.WriteChar( ",") END;
            IO.WriteInt( i);
            written := TRUE;
          END;
        END;
        IO.WriteChar( "}");
    ELSE
        IO.WriteInt( e.a0);
    END;
   END WriteCon;

  PROCEDURE WriteProc1(str: ARRAY OF CHAR);
   BEGIN
    IO.WriteString( str);
    Output(e.op1, FALSE);
    IO.WriteChar( ")");
   END WriteProc1;

  PROCEDURE WriteProc2(str: ARRAY OF CHAR);
   BEGIN
    IO.WriteString( str);
    Output(e.op1, FALSE);
    IO.WriteString( ", ");
    Output(e.op2, FALSE);
    IO.WriteChar( ")");
   END WriteProc2;

  PROCEDURE WriteExpr2(str: ARRAY OF CHAR; op: INTEGER);
    VAR
      paren: BOOLEAN;
      prevop : INTEGER;
   BEGIN
    paren := op < operation;
    prevop := operation; operation := op;
    IF paren THEN IO.WriteChar( "(") END;
    Output(e.op1, FALSE);
    IO.WriteString( str);
    Output(e.op2, FALSE);
    IF paren THEN IO.WriteChar( ")") END;
    operation := prevop;
   END WriteExpr2;

 BEGIN
  CASE e.form OF
    Def:
      IO.WriteString( "(Default expression)");

  | Sym:
      TryWriteModule(e.sym);
      IO.WriteString( e.sym.name);

  | TD:
      IO.WriteString( "TD(");
      IF XSymbolOf(S.VAL( Symbol.Struct, e.a0) , sym) THEN
        TryWriteModule(sym);
        IO.WriteString( sym.name);
      ELSE
        IO.WriteString( "No type name found");
      END;
      IO.WriteChar( ")");

  | Con:
      WriteCon(e);

  | ACon:
      IF first THEN
        IO.WriteChar( "#");
      END;
      Output(e.op1, FALSE);

  | Dn:
      IO.WriteChar( "D");
      IO.WriteInt( e.a0);

  | An:
      IO.WriteChar( "A");
      IO.WriteInt( e.a0);

  | FPn:
      IO.WriteString( "FP");
      IO.WriteChar( CHR( e.a0 + 30H));

  | Neg:
      IO.WriteChar( "-");
      Output(e.op1, FALSE);

  | Not:
      IO.WriteChar( "~");
      Output(e.op1, FALSE);

  | Ntl:
      WriteProc1( "NTL(");

  | Adr:
      WriteProc1( "ADR(");

  | Long:
      IF e.typ.form = Symbol.Real THEN
        WriteProc1( "FLOAT(");
      ELSE
        WriteProc1( "LONG(");
      END;

  | Deref:
      IO.WriteChar( "(");
      Output(e.op1, FALSE);
      IO.WriteChar( ")");

  | Trunc:
      WriteProc1( "TRUNC(");

  | Abs:
      WriteProc1( "ABS(");

  | Cap:
      WriteProc1( "CAP(");

  | Ord:
      WriteProc1( "ORD(");

  | Entier:
      WriteProc1( "ENTIER(");

  | Odd:
      WriteProc1( "ODD(");

  | Chr:
      WriteProc1( "CHR(");

  | Short:
      WriteProc1( "SHORT(");

  | ULong:
      WriteProc1( "ULONG(");

  | Mul:
      WriteExpr2( '*', mulop);

  | Div:
      WriteExpr2( " DIV ", mulop);

  | Mod:
      WriteExpr2( " MOD ", mulop);

  | Add:
      WriteExpr2( '+', addop);

  | Sub:
      WriteExpr2( '-', addop);

  | RDv:
      WriteExpr2( '/', mulop);

  | And:
      WriteExpr2( '&', mulop);

  | Or:
      WriteExpr2( " OR ", addop);

  | Anl:
      WriteProc2( "ANL(");

  | Orl:
      WriteProc2( "ORL(");

  | Xol:
      WriteProc2( "XOL(");

  | Lsh:
      WriteProc2( "LSH(");

  | Ash:
      WriteProc2( "ASH(");

  | Rot:
      WriteProc2( "ROT(");

  | Bit:
      WriteProc2( "BIT(");

  | In:
      WriteExpr2( " IN ", addop);

  | Asgn:
      WriteExpr2( " := ", addop);

  | Disp:
      Output(e.op1, FALSE);
      IO.WriteChar( ",");
      Output(e.op2, FALSE);

  | Set:
      IO.WriteChar( "{");
      Output(e.op1, FALSE);
      IF e.op2 # NIL THEN
        IO.WriteString( "..");
        Output(e.op2, FALSE);
      END;
      IO.WriteChar( "}");

  | Cmp:
      CASE e.a0 OF
        Scan.eql:
          WriteExpr2( '=', relop);
      | Scan.neq:
          WriteExpr2( '#', relop);
      | Scan.lss:
          WriteExpr2( '<', relop);
      | Scan.leq:
          WriteExpr2( "<=", relop);
      | Scan.gtr:
          WriteExpr2( '>', relop);
      | Scan.geq:
          WriteExpr2( ">=", relop);
      END;

  | DynArr:
      Output(e.op1, FALSE);
      IO.WriteChar( "[");
      Output(e.op2, FALSE);
      IO.WriteChar( "]");

  | SP:
      IO.WriteString( "SP");

  | PreDec, APD:
      IO.WriteString( "-(");
      Output(e.op1, FALSE);
      IO.WriteChar( ")");

  | PostInc, API:
      IO.WriteChar( "(");
      Output(e.op1, FALSE);
      IO.WriteString( ")+");

  | Ret:
      IO.WriteString( "RETBY(");
      Output(e.op1, FALSE);
      IO.WriteChar( ")");

  | DDn:
      Output(e.op1, FALSE);
      IO.WriteChar( ":");
      Output(e.op2, FALSE);

  | Rlst, FRlst:
      Output(e.op1, FALSE)

  | Ind:
      IO.WriteChar( "[");
      Output(e.op1, FALSE);
      IO.WriteChar( "]");

  | MIPr, MIPo, DA, ARI, DAX:
      IO.WriteChar( "(");
      Output(e.op1, FALSE);
      IO.WriteChar( ")");

  | XReg:
      Output(e.op1, FALSE);
      IO.WriteChar( ".");
      IF e.op1.typ.size = 2 THEN
        IO.WriteChar( "W");
      ELSE
        IO.WriteChar( "L");
      END;

  | Check:
      WriteProc2( "CHECK(");

  | Imm:
      IO.WriteChar( "#");
      Output(e.op1, FALSE);

  | CCR:
      IO.WriteString( "CCR");

  | SR:
      IO.WriteString( "SR");

  | USP:
      IO.WriteString( "USP");

  | SFR:
      CASE e.a0 OF
        Scan.sfc: IO.WriteString( "SFC");
      | Scan.dfc: IO.WriteString( "DFC");
      | Scan.cacr:IO.WriteString( "CACR");
      | Scan.usp: IO.WriteString( "USP");
      | Scan.vbr: IO.WriteString( "VBR");
      | Scan.caar:IO.WriteString( "CAAR");
      | Scan.msp: IO.WriteString( "MSP");
      | Scan.isp: IO.WriteString( "ISP");
      END;

  | PC:
      IO.WriteString( "PC");

  ELSE
      IO.WriteString("Unknown expression #"); IO.WriteInt(e.form);
  END;
 END Output;


PROCEDURE Init*;
  VAR
    obj: Symbol.Symbol;
    x  : Expr;
 BEGIN
  Scan.name := "TRUE"; Symbol.Find(obj);
  New( Con, x, Symbol.booltyp); x.a0 := 1;
  MarkUsed(x);
  obj.a1 := S.VAL(LONGINT, x);
  Scan.name := "FALSE"; Symbol.Find(obj);
  New( Con, x, Symbol.booltyp); x.a0 := 0;
  MarkUsed(x);
  obj.a1 := S.VAL(LONGINT, x);
 END Init;


PROCEDURE Exit*;
 BEGIN
  symbol := NIL;
  freeExprs := NIL;
  allExprs := NIL;
 END Exit;


END OCExpr.