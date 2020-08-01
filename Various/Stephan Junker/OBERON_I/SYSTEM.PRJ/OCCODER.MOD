MODULE OCCoder; (* SJ 11.10.94 *)


IMPORT
  S:=SYSTEM, Expr:=OCExpr, Sym:=OCSymbol, Stat:=OCStat, Output:=OCOutput,
  Com:=OCCom, Scan:=OCScan, Files:=BFiles, FN:=Filename, Par:=OCPar,
  Err:=OCErr, OCH:=OCH2, Import:=OCImport, IO, Strings;



CONST
  RelTabSize = 10000; DRelTabSize = 10000;
  TDStructSize = 1000; basetypeno = 200;



VAR
  module, symbols: Sym.Symbol;
  tsize, vsize, dsize, ssize, pc: LONGINT;
  objfile: Files.File; obj: Output.Rider;
  tdStructs: ARRAY TDStructSize OF Sym.Struct; tdsx: INTEGER;
  bodypos: LONGINT;
  proccnt, numproc : INTEGER;
  codeRd, dataRd : Output.CodeRider;



PROCEDURE UnusedProcNo(no: INTEGER) : BOOLEAN;
  VAR
    sym, tsym: Sym.Symbol;
    typ: Sym.Struct;
 BEGIN
  IF Sym.self # NIL THEN
    sym := Sym.self.syms;
    WHILE sym # NIL DO
      IF (sym.form IN {Sym.LProc, Sym.IProc}) & (SHORT( sym.a1) = no) THEN
        RETURN FALSE
      ELSIF (sym.form = Sym.Typ) THEN
        typ := sym.typ;
        IF typ.form = Sym.Pointer THEN typ := typ.base END;
        IF typ.form = Sym.Record THEN
          REPEAT
            tsym := typ.syms;
            WHILE tsym # NIL DO
              IF (tsym.form = Sym.Tbp) & (tsym.lev = no) THEN
                RETURN FALSE
              END;
              tsym := tsym.next;
            END;
            typ := typ.base;
          UNTIL typ = NIL;
        END;
      END;
      sym := sym.next
    END;
  END;
  RETURN TRUE
 END UnusedProcNo;


PROCEDURE GetProcNo*(proc: Sym.Symbol) : INTEGER;
(*
 Return a procedure number to identifie proc. If proc was defined in
 previous compilations, use the same number.
 *)
  VAR
    sym: Sym.Symbol;
    num: INTEGER;
    typ, ftyp: Sym.Struct;
 BEGIN
  IF Sym.self # NIL THEN
    IF proc.form # Sym.Tbp THEN
      COPY(proc.name, Scan.name);
      IF Sym.SearchInList(Sym.self.syms, sym) & (sym.form = proc.form) THEN
        num := SHORT( sym.a1);
        IF num > numproc THEN numproc := num END;
        RETURN num;
      END;
    ELSE
      ftyp := proc.syms.next.typ;
      WHILE ftyp.form = Sym.Pointer DO ftyp := ftyp.base END;
      typ := OCH.SelfTyp(ftyp);
      IF (typ # NIL) & (typ.form = Sym.Record) THEN
        WHILE (typ # NIL) & (typ.n # ftyp.n) DO
          typ := typ.base
        END;
        COPY(proc.name, Scan.name);
        IF (typ # NIL) & Sym.SearchInList(typ.syms, sym)
            & (sym.form = Sym.Tbp) THEN
          num := sym.lev;
          IF num > numproc THEN numproc := num END;
          RETURN num;
        END;
      END;
    END;
  END;
  REPEAT
    INC(proccnt);
  UNTIL UnusedProcNo(proccnt);
  RETURN proccnt;
 END GetProcNo;


PROCEDURE StoreTDStruct*(typ: Sym.Struct);
  VAR
    i: INTEGER;
 BEGIN
  FOR i := 0 TO tdsx-1 DO
    IF tdStructs[i] = typ THEN RETURN END;
  END;
  tdStructs[tdsx] := typ; INC(tdsx);
 END StoreTDStruct;


PROCEDURE OpenFile(VAR name: ARRAY OF CHAR);
  VAR
    filename: FN.path;
 BEGIN
  COPY(name, filename); FN.SetExt( Par.objExt, filename);
  IF Par.ObjPaths # Par.ModPaths THEN
    FN.SetPath( Par.ObjPaths.Path, filename)
  END;
  objfile := Files.New(filename);
  IF objfile = NIL THEN
    IO.WriteString( "Could not create object file"); IO.WriteLn;
  ELSE
    IO.WriteString( "New object file: ");
    IO.WriteString( filename);
    IO.WriteLn;
    obj.Set( objfile, 0)
  END;
 END OpenFile;


PROCEDURE CloseFile;
 BEGIN
  objfile.Register;
  objfile.Close;
  Output.Close;
 END CloseFile;


PROCEDURE StoreReloc;
 BEGIN
  codeRd.StoreReloc;
 END StoreReloc;


PROCEDURE StoreDReloc;
 BEGIN
  dataRd.StoreReloc;
 END StoreDReloc;


PROCEDURE StoreData(VAR dat: ARRAY OF S.BYTE; len: INTEGER);
 BEGIN
  dataRd.WriteBytes(dat, len);
  IF ODD(dataRd.Size()) THEN dataRd.Write(0) END;
 END StoreData;


PROCEDURE And(val : INTEGER; and : LONGINT) : INTEGER;
 BEGIN
  RETURN S.ANL(val, SHORT(and));
 END And;


PROCEDURE AndSh(val, and, shift : INTEGER) : INTEGER;
 BEGIN
  RETURN SHORT( S.LSH(S.ANL(val, and), shift) );
 END AndSh;


PROCEDURE BaseReg*(x: Expr.Expr) : INTEGER;
 BEGIN
  IF (x.form IN {Expr.An, Expr.Dn}) THEN
    RETURN SHORT(x.a0);
  ELSIF x.form = Expr.SP THEN RETURN 7;
  ELSIF (x.op1.form IN {Expr.An, Expr.Dn, Expr.FPn}) THEN
    RETURN SHORT(x.op1.a0);
  ELSIF x.op1.form = Expr.SP THEN RETURN 7;
  ELSIF (x.op1.form = Expr.Disp) OR (x.op1.form = Expr.Ind) THEN
    RETURN BaseReg(x.op1);
  END;
  HALT(99);	(* where is the base register??? *)
  RETURN 0;
 END BaseReg;


PROCEDURE EffAdr(x : Expr.Expr) : INTEGER;
  VAR
    val : LONGINT;
 BEGIN
  CASE x.form OF
    Expr.Dn:
      RETURN BaseReg(x)
  | Expr.An:
      RETURN BaseReg(x)+8
  | Expr.ARI:
      RETURN BaseReg(x)+16
  | Expr.API:
      RETURN BaseReg(x)+24
  | Expr.APD:
      RETURN BaseReg(x)+32
  | Expr.DA:
      RETURN BaseReg(x)+40
  | Expr.DAX, Expr.MIPo, Expr.MIPr:
      RETURN BaseReg(x)+48
  | Expr.AbsW:
      RETURN 38H
  | Expr.AbsL, Expr.Mem, Expr.Sym:
      RETURN 39H
  | Expr.PCD:
      RETURN 3AH
  | Expr.PCDI, Expr.PCPo, Expr.PCPr:
      RETURN 3BH
  | Expr.Imm, Expr.ACon, Expr.CCR, Expr.SR:
      RETURN 3CH
  | Expr.SP:
      RETURN 15;
  | Expr.FPn:
      HALT(99);
      RETURN 0;
  ELSE
      val := Expr.Evaluate(x);
      IF (x.typ.size = 4) OR Expr.reloc THEN
        RETURN 39H;
      ELSE
        RETURN 38H;
      END;
  END;
 END EffAdr;


PROCEDURE Put(word : INTEGER);
 BEGIN
  codeRd.WriteInt(word);
  INC(pc, 2);
 END Put;


PROCEDURE PutL(long : LONGINT);
 BEGIN
  codeRd.WriteLInt(long);
  INC(pc, 4);
 END PutL;


PROCEDURE PutB(byte : SHORTINT);
 BEGIN
  codeRd.Write(byte);
  INC(pc);
 END PutB;


PROCEDURE PutBytes(VAR var: ARRAY OF S.BYTE; len : LONGINT);
 BEGIN
  codeRd.WriteBytes(var, len);
  INC(pc, len);
 END PutBytes;


PROCEDURE SaveHeader(key: LONGINT);
 BEGIN
  IF ODD(vsize) THEN INC(vsize) END;
  IF ODD(dsize) THEN INC(dsize) END;

  obj.WriteInt(601AH);		(* code *)
  obj.WriteLInt(tsize);		(* text size, later filled *)
  obj.WriteLInt(dsize);		(* data size, later filled *)
  obj.WriteLInt(vsize);		(* bss size, later filled *)
  obj.WriteLInt(ssize);		(* symbol size, later filled *)
  obj.WriteLInt(key);		(* key *)
  obj.WriteLInt(0);		(* reserved *)
  obj.WriteInt(0);		(* reserved *)

  Put(4AF9H);			(* TAS.B *)
  StoreReloc; PutL(400000H);
  Put(6702H);			(* BNE.B +2 *)
  Put(4E75H);			(* RTS *)
  Put(4EF9H); StoreReloc;	(* JMP bodypos *)
  PutL(bodypos);
 END SaveHeader;


PROCEDURE DataReg(x: Expr.Expr) : INTEGER;
 BEGIN
  IF x.form = Expr.Dn THEN RETURN SHORT(x.a0) END;
  HALT(99);
  RETURN 0;
 END DataReg;


PROCEDURE BranchCommand(com, size: INTEGER; diff : LONGINT);
  VAR
    p : POINTER TO ARRAY 1000 OF CHAR;

  PROCEDURE PutBranch(no : INTEGER);
   BEGIN
    IF size = Stat.Word THEN
      Put(6000H + no * 100H); Put(SHORT(diff));
    ELSE
      IF (diff < -128) OR (diff > 127) THEN HALT(99) END;
      Put(6000H + no * 100H + And(0FFH, diff));
    END;
   END PutBranch;

  PROCEDURE PutFBranch(no : INTEGER);
   BEGIN
    Put(S.VAL(INTEGER, 0F280H) + no);
    Put(SHORT(diff));
   END PutFBranch;

 BEGIN
  IF com <= Scan.fbst THEN
    PutFBranch(com-Scan.fbf);
  ELSE
    PutBranch(com-Scan.bra);
  END;
 END BranchCommand;


PROCEDURE DbccCommand(com: INTEGER; diff : LONGINT; src: Expr.Expr);
 BEGIN
  Put(50C8H + (com-Scan.dbt) * 100H + DataReg(src));
  Put(SHORT(diff));
 END DbccCommand;


PROCEDURE DcCommand(size: INTEGER; data: LONGINT);
 BEGIN
  IF size = Stat.Byte THEN PutB(SHORT(SHORT(data)))
  ELSIF size = Stat.Word THEN Put(SHORT(data))
  ELSE PutL( data);
  END;
(*  | Scan.dcr:
       StoreReloc;
       Put( SHORT( lab DIV 10000H));
       Put( SHORT( lab));
    | Scan.dcs:
       p := S.VAL(S.PTR, lab);
       PutBytes(p^, Strings.Length(p^) );
    | Scan.ds:
       WHILE lab > 0 DO
         IF size = Byte THEN PutB(0)
         ELSIF size = Word THEN Put(0)
         ELSE Put(0); Put(0);
         END;
         DEC(lab);
       END;
    ELSE
    END;*)
 END DcCommand;


PROCEDURE MoveEffAdr(x : Expr.Expr) : INTEGER;
  VAR
    ea : INTEGER;
 BEGIN
  ea := EffAdr(x);
  RETURN AndSh(ea, 38H, 3) + AndSh(ea, 7, 9)
 END MoveEffAdr;


PROCEDURE Size(size : INTEGER) : INTEGER;
 BEGIN
  CASE size OF
    Stat.Byte: RETURN 00H
  | Stat.Word: RETURN 40H
  | Stat.Long: RETURN 80H
  END;
 END Size;


PROCEDURE WLSize6(size : INTEGER) : INTEGER;
 BEGIN
  CASE size OF
    Stat.Word: RETURN 00H
  | Stat.Long: RETURN 40H
  END;
 END WLSize6;


PROCEDURE WLSize8(size : INTEGER) : INTEGER;
 BEGIN
  CASE size OF
    Stat.Word: RETURN 000H
  | Stat.Long: RETURN 100H
  END;
 END WLSize8;


PROCEDURE XSize(size : INTEGER) : INTEGER;
 BEGIN
  CASE size OF
    Stat.Byte: RETURN 1000H
  | Stat.Word: RETURN 3000H
  | Stat.Long: RETURN 2000H
  END;
 END XSize;


PROCEDURE FSize(size : INTEGER) : INTEGER;
 BEGIN
  CASE size OF
    Stat.Byte: RETURN 1800H
  | Stat.Word: RETURN 1000H
  | Stat.Long: RETURN 0000H
  | Stat.Single: RETURN 0400H
  | Stat.Double: RETURN 1400H
  END;
 END FSize;


PROCEDURE IsConst*(x: Expr.Expr) : BOOLEAN;
(*
 Returns true if x is a constant expression.
 *)
 BEGIN
  RETURN
    (x.form = Expr.Con)
    OR (x.form = Expr.ACon)
    OR (x.form = Expr.Imm)
    OR (x.form = Expr.TD)
    OR (x.form = Expr.Sym)
    OR (x.form >= Expr.FSingle)
      & (x.form # Expr.Bit) & (x.form # Expr.Deref)
      & IsConst(x.op1)
      & (~Expr.HasOp2(x) OR IsConst(x.op2));
 END IsConst;


PROCEDURE GetDisp*(e: Expr.Expr) : LONGINT;
 BEGIN
  IF e.op1.form = Expr.Disp THEN
    IF IsConst(e.op1.op2) THEN
      RETURN Expr.Evaluate(e.op1.op2);
    END;
    IF e.op1.op1.form = Expr.Disp THEN
      IF IsConst(e.op1.op1.op2) THEN
        RETURN Expr.Evaluate(e.op1.op1.op2);
      END;
    END;
  END;
  RETURN 0;
 END GetDisp;


PROCEDURE GetIndex(e: Expr.Expr) : SHORTINT;

  PROCEDURE MakeData(e: Expr.Expr) : SHORTINT;
    VAR
      res: SHORTINT;
      fac: LONGINT;
   BEGIN
    res := 0;
    IF e.form = Expr.Mul THEN
      res := SHORT( SHORT( Expr.Evaluate(e.op2) ));
      IF res = 8 THEN res := 6 END;
      e := e.op1;
    END;
    IF e.typ.size = 4 THEN INC(res, 8) END;
    INC(res, SHORT( SHORT( e.a0)) * 16);
    IF e.form = Expr.An THEN INC(res, S.VAL( SHORTINT, 80H)) END;
    RETURN res;
   END MakeData;

 BEGIN
  IF e.op1.form = Expr.Disp THEN
    IF (e.op1.op2.form = Expr.XReg) THEN
      RETURN MakeData(e.op1.op2.op1);
    ELSIF (e.op1.op2.form IN {Expr.An, Expr.SP, Expr.Dn}) THEN
      RETURN MakeData(e.op1.op2);
    END;
    IF e.op1.op1.form = Expr.Disp THEN
      IF (e.op1.op1.op2.form = Expr.XReg) THEN
        RETURN MakeData(e.op1.op1.op2.op1);
      ELSIF (e.op1.op1.op2.form IN {Expr.Dn, Expr.An, Expr.SP}) THEN
        RETURN MakeData(e.op1.op1.op2);
      END;
    END;
  END;
  RETURN -2;
 END GetIndex;


PROCEDURE SearchInd(e: Expr.Expr; VAR ind: Expr.Expr) : BOOLEAN;
 BEGIN
  IF e.op1.form = Expr.Ind THEN
    ind := e.op1; RETURN TRUE
  END;
  IF e.op1.form = Expr.Disp THEN
    RETURN SearchInd(e.op1, ind);
  END;
  RETURN FALSE
 END SearchInd;


PROCEDURE GetBase(x: Expr.Expr) : Expr.Expr;
 BEGIN
  IF (x.op1.form IN {Expr.An, Expr.SP, Expr.PC}) THEN
    RETURN x.op1;
  ELSIF (x.op1.form = Expr.Disp)
         & (x.op1.op1.form IN {Expr.An, Expr.SP, Expr.PC}) THEN
    RETURN x.op1.op1;
  ELSE
    RETURN NIL;
  END;
 END GetBase;


PROCEDURE FFExtByte( ind, base: Expr.Expr; xreg: SHORTINT;
                     bd, od: LONGINT; form : INTEGER) : SHORTINT;
  VAR
    res: SHORTINT;
 BEGIN
  res := 10H;
  IF ind # NIL THEN
    IF (xreg = -2) OR (form = Expr.MIPr) OR (form = Expr.PCPr) THEN
      res := 1
    ELSE
      res := 5
    END;
    IF od # 0 THEN
      INC(res);
      IF (od > MAX(INTEGER)) OR (od < MIN(INTEGER)) THEN
        INC(res);
      END;
    END;
  END;
  IF bd # 0 THEN
    INC(res, 10H);
    IF (bd > MAX(INTEGER)) OR (bd < MIN(INTEGER)) THEN
      INC(res, 10H);
    END;
  END;
  IF xreg = -2 THEN INC(res, 40H) END;
  IF base = NIL THEN INC(res, S.VAL( SHORTINT, 80H)) END;
  RETURN res;
 END FFExtByte;


PROCEDURE PutDisp(disp: LONGINT);
 BEGIN
  IF disp # 0 THEN
    IF (disp > MAX(INTEGER)) OR (disp < MIN(INTEGER)) THEN
      PutL( disp);
    ELSE
      Put( SHORT( disp));
    END;
  END;
 END PutDisp;


PROCEDURE Operand(x: Expr.Expr);
  VAR
    bd, od: LONGINT;
    xreg: SHORTINT;
    ind, base : Expr.Expr;
 BEGIN
  CASE x.form OF

    Expr.DA, Expr.PCD:
      Put( SHORT( GetDisp(x) ) );

  | Expr.DAX, Expr.PCDI:
      PutB( GetIndex(x) ); PutB( SHORT( SHORT( GetDisp(x) ) ) );

  | Expr.MIPo, Expr.MIPr, Expr.PCPo, Expr.PCPr:
      xreg := GetIndex(x); PutB( xreg+1 );
      od := GetDisp(x);
      IF SearchInd(x, ind) THEN
        bd := GetDisp(ind);
        base := GetBase(ind);
      ELSE
        bd := 0; ind := NIL;
      END;
      PutB( FFExtByte( ind, base, xreg, bd, od, x.form) );
      PutDisp( bd); PutDisp( od);

  | Expr.AbsW:
      Put( SHORT( Expr.Evaluate(x.op1) ));

  | Expr.AbsL:
      od := Expr.Evaluate(x.op1);
      PutL( od);

  | Expr.Mem:
      StoreReloc;
      od := Expr.Evaluate(x.op1);
      PutL( od);

  | Expr.Sym:
      StoreReloc;
      IF x.sym.form = Sym.Con THEN
        x.typ := Sym.linttyp;
        od := Expr.Evaluate(x);
      ELSE
        od := x.sym.a0;
      END;
      PutL( od);

  ELSE
    IF (x.form >= Expr.FSingle) OR (x.form = Expr.Imm)
        OR (x.form = Expr.Con) THEN
      IF x.typ.form = Sym.LReal THEN
        x := Expr.EvaluateExpr(x);
        PutL( x.a0); PutL( x.a1);
      ELSIF x.typ.form # Sym.NoTyp THEN
        od := Expr.Evaluate(x);
        IF (x.typ.size = 4) OR Expr.reloc THEN
          IF Expr.reloc THEN StoreReloc END;
          PutL( od);
        ELSE
          Put( SHORT( od ));
        END;
      END;
    END;

  END;
 END Operand;


PROCEDURE DAReg(x: Expr.Expr) : INTEGER;
 BEGIN
  IF (x.form IN {Expr.Dn, Expr.FPn}) THEN
    RETURN SHORT(x.a0);
  ELSIF x.form = Expr.An THEN
    RETURN SHORT( x.a0) + 8;
  ELSIF (x.form = Expr.SP) OR (x.op1.form = Expr.SP) THEN RETURN 15;
  ELSIF (x.op1.form IN {Expr.Dn, Expr.FPn}) THEN
    RETURN SHORT(x.op1.a0);
  ELSIF x.op1.form = Expr.An THEN
    RETURN SHORT( x.op1.a0) + 8;
  ELSIF (x.op1.form = Expr.Disp) OR (x.op1.form = Expr.Ind) THEN
    RETURN DAReg(x.op1);
  END;
  HALT(99);	(* where is the base register??? *)
  RETURN 0;
 END DAReg;


PROCEDURE RegList(x: Expr.Expr) : INTEGER;
  VAR
    set: SET;

  PROCEDURE AddRegs(x: Expr.Expr);
    VAR
      from, to: LONGINT;
   BEGIN
    IF x.form = Expr.Sub THEN
      from := x.op1.a0;
      IF x.op1.form = Expr.An THEN INC(from, 8)
      ELSIF x.op1.form # Expr.Dn THEN HALT(99)
      END;
      to := x.op2.a0;
      IF x.op2.form = Expr.An THEN INC(to, 8)
      ELSIF x.op2.form # Expr.Dn THEN HALT(99)
      END;
(*      set := set + {from..to}; compiler error V1.24 *)
      set := set + Expr.BuildSet(from, to);
    ELSIF x.form = Expr.RDv THEN
      AddRegs(x.op1); AddRegs(x.op2);
    ELSIF x.form = Expr.Dn THEN
      INCL(set, x.a0);
    ELSIF x.form = Expr.An THEN
      INCL(set, x.a0+8);
    ELSE HALT(99)
    END;
   END AddRegs;

 BEGIN
  IF x.form # Expr.Rlst THEN HALT(99) END;
  set := {};
  AddRegs(x.op1);
  RETURN SHORT( S.VAL( LONGINT, set) );
 END RegList;


PROCEDURE MirrorRegList(x: Expr.Expr) : INTEGER;
  VAR
    regs, mirror, i: INTEGER;
 BEGIN
  regs := RegList(x);
  mirror := 0;
  FOR i := 15 TO 0 BY -1 DO
    mirror := mirror * 2;
    IF ODD(regs) THEN INC(mirror) END;
    regs := regs DIV 2;
  END;
  RETURN mirror;
 END MirrorRegList;


PROCEDURE FPRegList(x: Expr.Expr) : INTEGER;
  VAR
    set: SET;

  PROCEDURE AddRegs(x: Expr.Expr);
    VAR
      from, to: LONGINT;
   BEGIN
    IF x.form = Expr.Sub THEN
      from := x.op1.a0;
      IF x.op1.form # Expr.FPn THEN HALT(99) END;
      to := x.op2.a0;
      IF x.op2.form # Expr.FPn THEN HALT(99) END;
      set := set + {from..to};
    ELSIF x.form = Expr.RDv THEN
      AddRegs(x.op1); AddRegs(x.op2);
    ELSIF x.form = Expr.FPn THEN
      INCL(set, x.a0);
    ELSE HALT(99)
    END;
   END AddRegs;

 BEGIN
  IF x.form # Expr.FRlst THEN HALT(99) END;
  set := {};
  AddRegs(x.op1);
  RETURN SHORT( S.VAL( LONGINT, set) );
 END FPRegList;


PROCEDURE MirrorFPRegList(x: Expr.Expr) : INTEGER;
  VAR
    regs, mirror, i: INTEGER;
 BEGIN
  regs := FPRegList(x);
  mirror := 0;
  FOR i := 7 TO 0 BY -1 DO
    mirror := mirror * 2;
    IF ODD(regs) THEN INC(mirror) END;
    regs := regs DIV 2;
  END;
  RETURN mirror;
 END MirrorFPRegList;


PROCEDURE Command(com, size : INTEGER; src, dest : Expr.Expr);
  VAR
    base : INTEGER;

  PROCEDURE PutOperands;
   BEGIN
    IF src # NIL THEN Operand(src) END;
    IF dest # NIL THEN Operand(dest) END;
   END PutOperands;

  PROCEDURE PutRSr(base : LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(dest), 7, 9) + DAReg(src) + Size(size) );
   END PutRSr;

  PROCEDURE PutrSR(base : LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(src), 7, 9) + DAReg(dest) + Size(size) );
   END PutrSR;

  PROCEDURE PutDSe(base: LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(dest), 7, 9) + EffAdr(src) + Size(size) );
    PutOperands;
   END PutDSe;

  PROCEDURE PutRse(base: LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(dest), 7, 9) + EffAdr(src) + WLSize8(size) );
    PutOperands;
   END PutRse;

  PROCEDURE PutdSE(base: LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(src), 7, 9) + EffAdr(dest) + Size(size) );
    PutOperands;
   END PutdSE;

  PROCEDURE PutAdd(base: LONGINT);
   BEGIN
    IF dest.form = Expr.Dn THEN PutDSe(base)
    ELSIF (dest.form = Expr.An) OR (dest.form = Expr.SP) THEN
      Command( com+(Scan.adda-Scan.add), size, src, dest)
    ELSE PutdSE(base+100H)
    END;
   END PutAdd;

  PROCEDURE PutSE(base: LONGINT);
   BEGIN
    Put( SHORT(base) + EffAdr(dest) + Size(size) );
    PutOperands;
   END PutSE;

  PROCEDURE PutqSE(base: LONGINT);
   BEGIN
    Put(SHORT(base) + AndSh(SHORT(Expr.Evaluate(src)), 7, 9) + EffAdr(dest) + Size(size) );
    src := NIL; PutOperands;
   END PutqSE;

  PROCEDURE PutSe(base: LONGINT);
   BEGIN
    Put( SHORT(base) + EffAdr(src) + Size(size) );
    PutOperands;
   END PutSe;

  PROCEDURE PutShift(base: LONGINT);
   BEGIN
    IF src.form = Expr.Dn THEN PutdSE(base+20H)
    ELSIF dest = NIL THEN PutSe(base+80H)
    ELSIF dest.form = Expr.Dn THEN PutqSE(base)
    ELSE PutSE(base+80H)
    END;
   END PutShift;

  PROCEDURE PutdE(base: LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(src), 7, 9) + EffAdr(dest));
    PutOperands;
   END PutdE;

  PROCEDURE PutDe(base: LONGINT);
   BEGIN
    Put( SHORT(base) + AndSh(DAReg(dest), 7, 9) + EffAdr(src));
    PutOperands;
   END PutDe;

  PROCEDURE PutE(base: LONGINT);
   BEGIN
    Put( SHORT(base) + EffAdr(dest));
    PutOperands;
   END PutE;

  PROCEDURE PutBit(base: LONGINT);
   BEGIN
    IF src.form = Expr.Dn THEN PutdE(base)
    ELSE src.typ := Sym.inttyp; PutE(base+700H)
    END;
   END PutBit;

  PROCEDURE Pute(base: LONGINT);
   BEGIN
    Put( SHORT(base) + EffAdr(src));
    PutOperands;
   END Pute;

  PROCEDURE PutMulDiv(base, lbase, lbase2: LONGINT);
   BEGIN
    IF size = Stat.Word THEN PutDe(base)
    ELSE
      Put( SHORT(lbase) + EffAdr(src));
      Put( SHORT(lbase2) + AndSh(DAReg(dest), 7, 12)
          + And(DAReg(dest), 7));
      PutOperands;
    END;
   END PutMulDiv;

  PROCEDURE PutFCC(com: INTEGER);
   BEGIN
    IF src.form = Expr.FPn THEN
      IF dest = NIL THEN
        Put(S.VAL(INTEGER, 0F200H));
        Put(AndSh(DAReg(src), 7, 10) + AndSh(DAReg(src), 7, 7) + com);
      ELSIF dest.form = Expr.FPn THEN
        Put(S.VAL(INTEGER, 0F200H));
        Put(AndSh(DAReg(src), 7, 10) + AndSh(DAReg(dest), 7, 7) + com);
      ELSE
        Put(S.VAL(INTEGER, 0F200H) + EffAdr(dest));
        Put(6000H + FSize(size) + AndSh(DAReg(src), 7, 7) + com);
        PutOperands
      END;
    ELSE
      Put(S.VAL(INTEGER, 0F200H) + EffAdr(src));
      IF dest = NIL THEN
        Put(4000H + FSize(size) + com);
      ELSE
        Put(4000H + FSize(size) + AndSh(DAReg(dest), 7, 7) + com);
      END(*IF*);
      PutOperands
    END;
   END PutFCC;

  PROCEDURE PutCmp2(base2: INTEGER);
   BEGIN
    Put(00C0H + EffAdr(src));
    Put( AndSh(DAReg(dest), 0FH, 12) + base2);
    PutOperands;
   END PutCmp2;

 BEGIN
  CASE com OF
    Scan.abcd: PutRSr(0C100H);
  | Scan.addx: PutRSr(0D100H);
  | Scan.sbcd: PutRSr(08100H);
  | Scan.subx: PutRSr(09100H);
  | Scan.cmpm: PutRSr(0B100H);
  | Scan.add: PutAdd(0D000H);
  | Scan.andm: PutAdd(0C000H);
  | Scan.orm: PutAdd(08000H);
  | Scan.sub: PutAdd(09000H);
  | Scan.cmp: PutDSe(0B000H);
  | Scan.eor: PutdSE(0B100H);
  | Scan.adda: PutRse(0D0C0H);
  | Scan.cmpa: PutRse(0B0C0H);
  | Scan.lea: PutRse(040C0H);
  | Scan.suba: PutRse(090C0H);
  | Scan.addi: PutSE(0600H);
  | Scan.andi: PutSE(0200H);
  | Scan.cmpi: PutSE(0C00H);
  | Scan.eori: PutSE(0A00H);
  | Scan.ori: PutSE(0);
  | Scan.subi: PutSE(0400H);
  | Scan.addq: PutqSE(5000H);
  | Scan.subq: PutqSE(5100H);
  | Scan.asl: PutShift(0E100H);
  | Scan.asr: PutShift(0E000H);
  | Scan.lsr: PutShift(0E008H);
  | Scan.lsl: PutShift(0E108H);
  | Scan.rol: PutShift(0E118H);
  | Scan.ror: PutShift(0E018H);
  | Scan.roxl: PutShift(0E110H);
  | Scan.roxr: PutShift(0E010H);
  | Scan.bchg: PutBit(0140H);
  | Scan.bclr: PutBit(0180H);
  | Scan.bset: PutBit(01C0H);
  | Scan.btst: PutBit(0100H);
  | Scan.chk: IF size = Stat.Word THEN PutDSe(4140H) ELSE PutDSe(4080H) END;
  | Scan.clr: PutSe(4200H);
  | Scan.jmp: Pute(4EC0H);
  | Scan.jsr: Pute(4E80H);
  | Scan.ext: PutSe(4840H);
  | Scan.nbcd: Pute(4800H);
  | Scan.neg: PutSe(4400H);
  | Scan.negx: PutSe(4000H);
  | Scan.notm: PutSe(4600H);
  | Scan.pea, Scan.swap: Pute(4840H);
  | Scan.st..Scan.sle: Pute(50C0H + (com - Scan.st) * 100H);
  | Scan.fsf..Scan.fsst: Pute(0F240H); Put(com - Scan.fsf);
  | Scan.tas: Pute(4AC0H);
  | Scan.tst: PutSe(4A00H);
  | Scan.unlk: Pute(4E50H);
  | Scan.extb: Pute(49C0H);
  | Scan.divs: PutMulDiv(81C0H, 4C40H, 800H);
  | Scan.divu: PutMulDiv(80C0H, 4C40H, 0);
  | Scan.muls: PutMulDiv(0C1C0H, 4C00H, 800H);
  | Scan.mulu: PutMulDiv(0C0C0H, 4C00H, 0);
  | Scan.divsl: PutMulDiv(81C0H, 4C40H, 0C00H);
  | Scan.divul: PutMulDiv(80C0H, 4C40H, 400H);
  | Scan.mulsl: PutMulDiv(0C1C0H, 4C00H, 0C00H);
  | Scan.mulul: PutMulDiv(0C0C0H, 4C00H, 400H);
  | Scan.exg:
      IF src.form = dest.form THEN PutDe(0C140H)
      ELSIF src.form = Expr.Dn THEN PutdE(0C180H)
      ELSE PutDe(0C180H)
      END;
  | Scan.rts: Put(4E75H);
  | Scan.illegal: Put(4AFCH);
  | Scan.nop: Put(4E71H);
  | Scan.reset: Put(4E70H);
  | Scan.rte: Put(4E73H);
  | Scan.rtr: Put(4E77H);
  | Scan.stop: Put(4E72H);
  | Scan.trapv: Put(4E76H);
  | Scan.link:
      IF size = Stat.Word THEN Pute(4E48H) ELSE Pute(4800H) END;
  | Scan.move, Scan.movea:
      IF src.form = Expr.CCR THEN PutE(42C0H);
      ELSIF dest.form = Expr.CCR THEN Pute(44C0H);
      ELSIF src.form = Expr.SR THEN PutE(40C0H);
      ELSIF dest.form = Expr.SR THEN Pute(46C0H);
      ELSIF src.form = Expr.USP THEN PutE(4E60H);
      ELSIF dest.form = Expr.USP THEN Pute(4E58H);
      ELSE
        Pute( XSize(size) + MoveEffAdr(dest));
      END(*IF*);
  | Scan.movem:
      IF src.form = Expr.Rlst THEN
        Put( 4880H + WLSize6(size) + EffAdr(dest));
        IF dest.form = Expr.APD THEN Put( MirrorRegList(src));
        ELSE Put( RegList(src) );
        END;
      ELSE
        Put( 4C80H + WLSize6(size) + EffAdr(src));
        Put( RegList(dest) );
      END;
      PutOperands;
  | Scan.movep:
      IF src.form = Expr.Dn THEN PutrSR(0140H) ELSE PutRSr(00C0H) END;
      PutOperands;
  | Scan.moveq: Put(7000H + AndSh(DAReg(dest), 7, 9)
                 + And(0FFH, Expr.Evaluate(src) ));
  | Scan.trap: Put(4E40H + And(0FH, Expr.Evaluate(src) ));
  | Scan.chk2: PutCmp2(800H);
  | Scan.cmp2: PutCmp2(0);
  | Scan.fmove..Scan.fsub: PutFCC(com-Scan.fmove);
  | Scan.fcmp: PutFCC(38H);
  | Scan.ftest: PutFCC(3AH);
  | Scan.fsincos: PutFCC(30H);
  | Scan.fmovem:
      IF src.form = Expr.FRlst THEN
        Put( S.VAL(INTEGER, 0F200H) + EffAdr(dest));
        Put( S.VAL(INTEGER, 0E000H) + MirrorFPRegList(src) );
      ELSE
        Put( S.VAL(INTEGER, 0F200H) + EffAdr(src));
        Put( S.VAL(INTEGER, 0C000H) + FPRegList(dest) );
      END;
      PutOperands;
  END;
 END Command;


PROCEDURE Distance(s: Stat.Stat; lab: Expr.Expr) : LONGINT;
  VAR
    dist: LONGINT;
    stat: Stat.Stat;
 BEGIN
  IF lab.form = Expr.Mem THEN lab := lab.op1 END;
  IF lab.sym.form = Sym.Label THEN
    IF s.a0 = Stat.Byte THEN dist := 0 ELSE dist := 2 END;
    stat := s.next;
    LOOP	(* search forward *)
      IF stat.form = Scan.label THEN
        IF stat.expr.sym = lab.sym THEN RETURN dist END;
      END;
      INC(dist, stat.len);
      stat := stat.next;
      IF (stat = NIL) THEN EXIT END;
    END;
    dist := -2; stat := s;
    LOOP	(* search backward *)
      stat := stat.prev;
      IF (stat = NIL) THEN EXIT END;
      DEC(dist, stat.len);
      IF stat.form = Scan.label THEN
        IF stat.expr.sym = lab.sym THEN
          RETURN dist
        END;
      END;
    END;
    HALT(99); (* label not found? *)
    RETURN dist
  ELSE
    RETURN lab.sym.a0 - pc - 2
  END;
 END Distance;


PROCEDURE CallImports(sym: Sym.Symbol);
 BEGIN
  WHILE sym # NIL DO
    IF (sym.form = Sym.Mod) & (sym.lev # -128) THEN	(* not SYSTEM *)
      Put(4EB9H);
      StoreReloc; PutL(sym.lev*1000000H);
    END;
    sym := sym.next;
  END;
 END CallImports;


PROCEDURE SearchProcNo(sym: Sym.Symbol; no: INTEGER;
                       VAR symbol: Sym.Symbol) : BOOLEAN;
  VAR
    i : INTEGER;
    typ: Sym.Struct;
 BEGIN
  WHILE sym # NIL DO
    IF (sym.form IN {Sym.LProc, Sym.IProc}) & (sym.mark = Sym.Export)
        & (sym.lev = 0) & (sym.a1 = no) THEN
      symbol := sym; RETURN TRUE;
    END;
    sym := sym.next;
  END;
  FOR i := 0 TO tdsx-1 DO
    typ := tdStructs[i];
    IF typ.form = Sym.Record THEN
      sym := typ.syms;
      WHILE sym # NIL DO
        IF (sym.form = Sym.Tbp) & (sym.lev = no) THEN
          symbol := sym; RETURN TRUE
        END;
        sym := sym.next;
      END;
    END;
  END;
  RETURN FALSE
 END SearchProcNo;


PROCEDURE PutSymbol(VAR name: ARRAY OF CHAR; code: INTEGER;
                      value: LONGINT);
  VAR
    ext: BOOLEAN;
    sp : Strings.ptr;
 BEGIN
  IF name[0] = 0X THEN COPY("dummy", name) END;
  ext := Strings.Length(name) > 8;
  PutBytes(name, 8);
  IF ext THEN Put(code + 48H) ELSE Put(code) END;
  PutL(value);
  IF ext THEN
    sp := S.ADR(name[8]); PutBytes(sp^, 14);
    INC(ssize, 14);
  END;
  INC(ssize, 14);
 END PutSymbol;


PROCEDURE PutSymbols(symbols: Sym.Symbol);
  VAR
    sp: Strings.ptr;
    i : INTEGER;
    sym: Sym.Symbol;
    dummy: ARRAY 10 OF CHAR;

  PROCEDURE PutProcs(sym: Sym.Symbol);
   BEGIN
    WHILE sym # NIL DO
      IF (sym.form IN {Sym.LProc, Sym.IProc, Sym.AProc}) THEN
        PutSymbol(sym.name, 200H, sym.a0);
        PutProcs(sym.syms);
      END;
      sym := sym.next;
    END;
   END PutProcs;

 BEGIN
  FOR i := 0 TO Import.nofgmod-1 DO
    sym := Import.glbmod[i];
    sp := sym.a0; PutSymbol(sp^, 4800H, sym.lev);
  END;

  dummy := "dummy";
  FOR i := 1 TO proccnt DO	(* save procs with number *)
    IF SearchProcNo(symbols, i, sym) THEN
      PutSymbol(sym.name, 2200H, sym.a0);
    ELSE
      PutSymbol(dummy, 2200H, 0);
    END;
  END;

  sym := symbols;
  WHILE sym # NIL DO
    IF sym.lev = 0 THEN
      IF (sym.form IN {Sym.LProc, Sym.IProc, Sym.AProc}) & (sym.mark = Sym.NoExport) THEN
        PutSymbol(sym.name, 200H, sym.a0);
        PutProcs(sym.syms);
      ELSIF (sym.form = Sym.Var) THEN
        PutSymbol(sym.name, 100H, sym.a0-400000H);
      END;
    END;
    sym := sym.next;
  END;
  sp := S.ADR( "body");
  PutSymbol(sp^, 200H, bodypos);
 END PutSymbols;


PROCEDURE Return(lev, currlev: INTEGER);
  VAR
    sym: Sym.Symbol;
 BEGIN
  sym := symbols.a0;
  IF (sym.form = Sym.AProc) & (currlev = lev) THEN
    Put(23CEH);		(* MOVE.L A6,sym.a0+4 *)
    StoreReloc;
    PutL(sym.a0+2);
    Put(2C5FH);		(* MOVE.L (SP)+,A6 *)
  END;
  REPEAT
    IF currlev = 0 THEN Put(4E5EH);
    ELSE Put(4E5FH - currlev);
    END;
    DEC(currlev);
  UNTIL (currlev < lev);
  Put(4E75H);
 END Return;


PROCEDURE StoreString(x: Expr.Expr);
  TYPE
    StringPtr = POINTER TO ARRAY 512 OF CHAR;
  VAR
    ptr: StringPtr;
 BEGIN
  IF x = NIL THEN RETURN END;
  IF (x.form = Expr.ACon) THEN x := x.op1 END;
  WHILE x.form = Expr.Sym DO
    IF x.sym.form # Sym.Con THEN RETURN END;
    x := S.VAL( Expr.Expr, x.sym.a1);
  END;
  IF x.form # Expr.Con THEN
    IF (x.form = Expr.Add) OR (x.form = Expr.Sub) THEN
      StoreString(x.op1); StoreString(x.op2);
    END;
  ELSIF (x.typ.form = Sym.String) & (x.a0 = -1) THEN
    x.a0 := dataRd.Size() + 800000H;
    ptr := S.VAL( StringPtr, x.a1);
    StoreData(ptr^, Strings.Length(ptr^) + 1);
  END;
 END StoreString;


PROCEDURE StoreStrings;
  VAR
    s: Stat.Stat;
 BEGIN
  s := Stat.stats;
  WHILE s # NIL DO
    IF s.form >= Stat.Ass THEN
      StoreString(s.expr)
    END;
    s := s.next
  END;
 END StoreStrings;


PROCEDURE HasPtr(typ: Sym.Struct) : BOOLEAN;
  VAR
    sym: Sym.Symbol;
 BEGIN
  IF typ.form = Sym.Pointer THEN RETURN TRUE END;
  IF typ.form IN {Sym.Array, Sym.DynArr, Sym.OpenArr} THEN
    RETURN HasPtr(typ.base);
  END;
  IF typ.form = Sym.Record THEN
    IF (typ.base # NIL) & HasPtr(typ.base) THEN RETURN TRUE END;
    sym := typ.syms;
    WHILE sym # NIL DO
      IF (sym.form = Sym.Fld) & HasPtr(sym.typ) THEN RETURN TRUE END;
      sym := sym.next;
    END;
  END;
  RETURN FALSE
 END HasPtr;


PROCEDURE NumTBPs(typ: Sym.Struct) : INTEGER;
  VAR
    max: INTEGER;
    obj: Sym.Symbol;
 BEGIN
  IF typ = NIL THEN RETURN 0 END;
  max := -1;
  WHILE typ # NIL DO
    obj := typ.syms;
    WHILE obj # NIL DO
      IF (obj.form = Sym.Tbp) & (obj.a1 > max) THEN
        max := SHORT(obj.a1);
      END;
      obj := obj.next;
    END;
    typ := typ.base;
  END;
  RETURN max+1;
 END NumTBPs;


PROCEDURE FindTbp(typ: Sym.Struct; no: INTEGER; VAR tbp: Sym.Symbol) : BOOLEAN;
  VAR
    sym: Sym.Symbol;
 BEGIN
  IF typ # NIL THEN
    sym := typ.syms;
    WHILE sym # NIL DO
      IF (sym.form = Sym.Tbp) & (sym.a1 = no) THEN
        tbp := sym; RETURN TRUE
      END;
      sym := sym.next
    END;
    RETURN FindTbp(typ.base, no, tbp);
  END;
  RETURN FALSE
 END FindTbp;


PROCEDURE EnterReservedTBPs(typ: Sym.Struct);
  VAR
    number, tbpno: INTEGER;
    last, sym: Sym.Symbol;
 BEGIN
  tbpno := NumTBPs(typ);
  last := typ.syms;
  WHILE last.next # NIL DO last := last.next END;
  number := 0;
  WHILE number < tbpno DO
    IF ~FindTbp( typ, number, sym) THEN
      Sym.NewSymNamed(Sym.Tbp, "", sym);
      sym.a1 := number;
      sym.a0 := 0;
      last.next := sym; last := sym; last.next := NIL;
    END;
    INC(number);
  END;
  IF Sym.self # NIL THEN
    number := NumTBPs( OCH.SelfTyp(typ)) - tbpno;
    IF number <= 0 THEN number := Par.rsvdTBPs END;
  ELSE
    number := Par.rsvdTBPs;
  END;
  WHILE number > 0 DO
    Sym.NewSymNamed(Sym.Tbp, "", sym);
    sym.a1 := tbpno; INC(tbpno);
    sym.a0 := 0;
    last.next := sym; last := sym; last.next := NIL;
    DEC(number);
  END;
 END EnterReservedTBPs;


PROCEDURE StorePtrOffsets(sym: Sym.Symbol);
 BEGIN
  dataRd.WriteLInt(-1);
  WHILE sym # NIL DO
    IF (sym.form IN {Sym.Var, Sym.Fld}) & (sym.lev >= 0) & HasPtr(sym.typ) THEN
      IF sym.typ.form = Sym.Pointer THEN
        dataRd.WriteLInt( - (sym.a0 MOD 400000H) );
      ELSIF sym.typ.form IN {Sym.Array, Sym.Record} THEN
        dataRd.WriteLInt( sym.a0 MOD 400000H );
        StoreDReloc;
        dataRd.WriteLInt( sym.typ.a0 );
      END;
    END;
    sym := sym.next;
  END;
 END StorePtrOffsets;


PROCEDURE StoreRecTD(typ: Sym.Struct);
  VAR
    type, i: INTEGER;
    name: ARRAY 40 OF CHAR;
    dpos: LONGINT;
    sym: Sym.Symbol;

  PROCEDURE StoreBaseType(typ: Sym.Struct);
   BEGIN
    IF typ # NIL THEN
      StoreBaseType(typ.base);
      StoreDReloc;
      dataRd.WriteLInt(typ.a0);
    END;
   END StoreBaseType;

  PROCEDURE StoreTbp(typ: Sym.Struct; no: INTEGER) : BOOLEAN;
    VAR
      tbp : Sym.Symbol;
   BEGIN
    IF typ = NIL THEN RETURN FALSE END;
    IF FindTbp(typ, no, tbp) THEN
      StoreDReloc;
      dataRd.WriteLInt(tbp.a0);
      RETURN TRUE
    END;
    RETURN StoreTbp(typ.base, no);
   END StoreTbp;

 BEGIN
  EnterReservedTBPs(typ);
  StorePtrOffsets(typ.syms);
  dpos := dataRd.Size();
  typ.a0 := dpos + 800000H;
  dataRd.WriteLInt(typ.size);
  IF HasPtr(typ) THEN type := 9
  ELSE type := 1;
  END;
  dataRd.WriteInt(type);
  IF Expr.SymbolOf(typ, sym) THEN
    COPY(module.name, name); Strings.AppendC(".", name);
    Strings.Append(sym.name, name);
  ELSE
    name := "Type is unnamed!"
  END;
  dataRd.WriteBytes(name, 40);
  StoreBaseType(typ);
  IF dataRd.Size()-dpos > Sym.TDTBPs THEN
    Err.Mark(basetypeno)
  END;
  WHILE dataRd.Size()-dpos < Sym.TDTBPs DO
    dataRd.WriteLInt(0);
  END;
  i := 0;
  WHILE StoreTbp(typ, i) DO INC(i) END;
 END StoreRecTD;


PROCEDURE StoreArrTD(typ: Sym.Struct);
  VAR
    type: INTEGER;
 BEGIN
  typ.a0 := dataRd.Size() + 800000H;
  dataRd.WriteLInt(typ.size);
  IF HasPtr(typ) THEN type := 10
  ELSE type := 2;
  END;
  dataRd.WriteInt(type);
  dataRd.WriteLInt(typ.n);
  IF typ.base.a0 # -1 THEN StoreDReloc END;
  dataRd.WriteLInt(typ.base.a0);
 END StoreArrTD;


PROCEDURE StoreOpnTD(typ: Sym.Struct);
  VAR
    type: INTEGER;
 BEGIN
  typ.a0 := dataRd.Size() + 800000H;
  dataRd.WriteLInt(typ.base.size);
  IF HasPtr(typ) THEN type := 12
  ELSE type := 4;
  END;
  dataRd.WriteInt(type);
  IF typ.base.a0 # -1 THEN StoreDReloc END;
  dataRd.WriteLInt(typ.base.a0);
 END StoreOpnTD;


PROCEDURE StoreTDs;
  VAR
    i : INTEGER;
    typ: Sym.Struct;
 BEGIN
  FOR i := 0 TO tdsx-1 DO
    typ := tdStructs[i];
    IF typ.form = Sym.Record THEN
      StoreRecTD(typ);
    ELSIF typ.form = Sym.Array THEN
      StoreArrTD(typ);
    ELSIF typ.form = Sym.OpenArr THEN
      StoreOpnTD(typ);
    ELSE HALT(99)
    END;
  END;
 END StoreTDs;


PROCEDURE Allocate(begin: Stat.Stat);
(*
 Store label/procedure positions allocate strings, allocate TD's,
 enter segment codes
 *)
  VAR
    s: Stat.Stat;
    sym: Sym.Symbol;
 BEGIN
  Stat.Environment(begin, sym, s);
  symbols := sym.syms;
  symbols.a0 := S.VAL(LONGINT, sym);
  IF s.form = Stat.Mod THEN
    module := s.sym;
    sym := Sym.global;
    WHILE sym # NIL DO	(* add segment codes *)
      IF  (sym.form = Sym.Var) & (sym.lev = 0) THEN
        IF sym.a0+sym.typ.size > vsize THEN
          vsize := sym.a0+sym.typ.size;
        END;
        INC(sym.a0, 400000H);
      END;
      sym := sym.next;
    END;
  END;
  s := begin;
  LOOP
    Stat.ReadOptions(s);
    IF (s = NIL) THEN EXIT END;
    CASE s.form OF
      Stat.Begin:
        IF symbols = Sym.global THEN
          bodypos := tsize;
        END;
        sym := symbols.a0;
        sym.a0 := tsize;
        INC(tsize, s.len);

    | Stat.End:
        INC(tsize, s.len);
        symbols := symbols.syms;
        EXIT

    | Stat.Ret:
        INC(tsize, s.len);

    | Stat.Options, Stat.OutCtrl:

    ELSE
        IF s.form < Stat.Ass THEN HALT(99) END;
        IF s.form = Scan.label THEN
          s.expr.sym.a0 := tsize
        ELSIF s.form = Scan.even THEN
          IF ODD(tsize) THEN INC(tsize); s.len := 1 END;
        ELSE
          INC(tsize, s.len);
        END;

    END;
    s := s.next;
  END;

 END Allocate;


PROCEDURE CheckCodeLength(saved: INTEGER; s: Stat.Stat);
 BEGIN
  IF saved # s.len THEN
    IO.WriteString( "Code length mismatch!"); IO.WriteLn;
    IO.WriteString( "Command: "); Stat.OutputStat(s);
    IO.WriteString( "Precalculated length: ");
    IO.WriteInt( s.len); IO.WriteLn;
    IO.WriteString( "Saved length: ");
    IO.WriteInt( saved); IO.WriteLn;
    HALT(98)
  END;
 END CheckCodeLength;


PROCEDURE PrecodingPossible(s: Stat.Stat) : BOOLEAN;
  VAR
    lab: Expr.Expr;

  PROCEDURE HasString(x: Expr.Expr) : BOOLEAN;
   BEGIN
    IF (x.form = Expr.ACon) THEN x := x.op1 END;
    WHILE x.form = Expr.Sym DO
      IF x.sym.form # Sym.Con THEN RETURN FALSE END;
      x := S.VAL( Expr.Expr, x.sym.a1);
    END;
    IF x.form # Expr.Con THEN
      IF (x.form = Expr.Add) OR (x.form = Expr.Sub) THEN
        IF HasString(x.op1) THEN RETURN TRUE END;
        RETURN HasString(x.op2);
      END;
    ELSIF (x.typ.form = Sym.String) & (x.a0 = -1) THEN
      RETURN TRUE
    END;
    RETURN FALSE
   END HasString;

  PROCEDURE HasTD(x: Expr.Expr) : BOOLEAN;
   BEGIN
    IF (x.form = Expr.TD) THEN RETURN TRUE END;
    IF (x.form >= Expr.ARI) & (x.form <= Expr.FRlst)
        OR (x.form = Expr.Ind) OR (x.form = Expr.XReg)
        OR (x.form >= Expr.FSingle) & (x.form <= Expr.LDual) THEN
      IF HasTD(x.op1) THEN RETURN TRUE END;
      IF Expr.HasOp2(x) THEN
        IF HasTD(x.op2) THEN RETURN TRUE END;
      END;
    END;
    RETURN FALSE
   END HasTD;

  PROCEDURE HasProc(x: Expr.Expr) : BOOLEAN;
   BEGIN
    IF (x.form = Expr.Sym) & (x.sym.form IN {Sym.LProc..Sym.IProc}) THEN
      RETURN TRUE
    END;
    IF (x.form >= Expr.ARI) & (x.form <= Expr.FRlst)
        OR (x.form = Expr.Ind) OR (x.form = Expr.XReg)
        OR (x.form >= Expr.FSingle) & (x.form <= Expr.LDual) THEN
      IF HasProc(x.op1) THEN RETURN TRUE END;
      IF Expr.HasOp2(x) THEN
        IF HasProc(x.op2) THEN RETURN TRUE END;
      END;
    END;
    RETURN FALSE
   END HasProc;

 BEGIN
  IF (s.form < Stat.Ass) OR (s.form = Scan.jsr)
        OR (s.form = Scan.label) THEN
    RETURN FALSE
  END;
  IF (s.form >= Scan.fbf) & (s.form <= Scan.dc) THEN
    IF (s.form >= Scan.dbt) & (s.form <= Scan.dble) THEN
      lab := s.expr2
    ELSE
      lab := s.expr
    END;
    RETURN (lab.form # Expr.Sym) OR (lab.sym.form = Sym.Label)
  END;
  IF (s.expr # NIL) & (HasString(s.expr) OR HasTD(s.expr) OR HasProc(s.expr))
     OR (s.expr2 # NIL) & (HasString(s.expr2) OR HasTD(s.expr2) OR HasProc(s.expr2)) THEN
    RETURN FALSE
  END;
  RETURN TRUE
 END PrecodingPossible;


PROCEDURE Code*(begin: Stat.Stat);
  VAR
    s, stat: Stat.Stat;
    sym: Sym.Symbol;
 BEGIN
  Allocate(begin);
  Stat.Environment(begin, sym, s);
  symbols := sym.syms;
  s := begin;
  LOOP
    Stat.ReadOptions(s);
    IF (s = NIL) OR (s.form = Stat.End) THEN EXIT END;
    IF (s.form # Scan.dc) & (s.form # Scan.label) THEN
      Expr.baselab := 0
    END;
    IF (codeRd = NIL) OR (codeRd.Size() # 0) THEN
      codeRd := Output.NewCodeRider();
    END;
    stat := s;
    WHILE PrecodingPossible(s) DO
      pc := 0;
      IF (s.form = Scan.even) & (s.len = 1) THEN
        PutB(0)
      ELSIF (s.form >= Scan.dbt) & (s.form <= Scan.dble) THEN
        DbccCommand( s.form, Distance(s, s.expr2), s.expr );
      ELSIF (s.form >= Scan.fbf) & (s.form <= Scan.ble) THEN
        BranchCommand( s.form, SHORT( s.a0), Distance(s, s.expr));
      ELSIF s.form = Scan.base THEN
        Expr.baselab := s.expr.sym.a0;
      ELSIF s.form < Scan.dbt THEN
        Command(s.form, SHORT( s.a0), s.expr, s.expr2)
      ELSIF s.form = Scan.dc THEN
        DcCommand( SHORT( s.a0), Expr.Evaluate(s.expr) );
      ELSIF s.form = Scan.label THEN
      ELSE
        HALT(99);
      END;
      CheckCodeLength(SHORT( pc), s);
      s := s.next;

    END;
    WHILE stat # s DO
      Stat.Remove(stat); stat := stat.next;
    END;
    IF codeRd.Size() # 0 THEN
      Stat.New(Stat.Code, stat);
      stat.len := SHORT( codeRd.Size());
      stat.a0 := S.VAL( LONGINT, codeRd);
      Stat.Insert(stat, s);
    END;
    Stat.ReadOptions(s);
    s := s.next;
  END;
 END Code;


PROCEDURE WriteData*;
 BEGIN
  dataRd := Output.NewCodeRider();
  Expr.symbol := Stat.stats.sym;
  StoreTDs;				(* allocate/store data *)
  StoreStrings;
  StorePtrOffsets(Sym.global);
  StoreDReloc;
  dataRd.WriteLInt(400000H);
  StoreDReloc;
  dataRd.WriteLInt(0);
  dsize := dataRd.Size();
 END WriteData;


PROCEDURE WriteCode*(VAR name: ARRAY OF CHAR; key: LONGINT);
  VAR
    s: Stat.Stat;
    sym: Sym.Symbol;
    codeRider, symRd: Output.CodeRider;
    prevpc: LONGINT;
 BEGIN
  IF numproc > proccnt THEN proccnt := numproc END;
  codeRd := Output.NewCodeRider();
  PutSymbols(symbols);
  symRd := codeRd;

  OpenFile(name);
  IF objfile # NIL THEN
    s := Stat.stats;
    pc := 0;
    LOOP
      Stat.ReadOptions(s);
      IF (s = NIL) THEN EXIT END;
      IF (s.form # Scan.dc) & (s.form # Scan.label) THEN
        Expr.baselab := 0
      END;
      prevpc := pc;
      CASE s.form OF
        Stat.Mod:
          symbols := s.sym.syms;
          Expr.symbol := s.sym;
          symbols.a0 := S.VAL(LONGINT, s.sym);
          codeRd := Output.NewCodeRider();
          SaveHeader(key);

      | Stat.Proc:
          IF s.a0 = 1 THEN
            symbols := s.sym.syms;
            symbols.a0 := S.VAL(LONGINT, s.sym);
          END;

      | Stat.Begin:
          sym := symbols.a0;
          IF sym.form = Sym.Mod THEN
            CallImports(symbols);
          END;
          IF Par.ccode THEN
            IF sym.form = Sym.AProc THEN
              Put(6004H); PutL(0)	(* BRA.S +4 *)
            END;
            IF symbols.lev = 0 THEN Put(4E56H);
            ELSE Put(4E57H - symbols.lev);
            END;
            IF ODD(s.a0) THEN DEC(s.a0) END;
            Put(SHORT( s.a0) );
            IF sym.form = Sym.AProc THEN
              Put(2F0EH);		(* MOVE.L A6,-(SP) *)
              Put(2C7AH); Put(-12);	(* MOVE.L -12(PC),A6 *)
            END;
            IF Par.stkchk THEN
              Command(Scan.jsr, Stat.NoSize, Com.SysCheckStack, NIL);
            END;
          END;

      | Stat.End:
          IF Par.ccode THEN
            sym := symbols.a0;
            IF (sym.form # Sym.Mod) & (sym.typ.form # Sym.NoTyp) THEN
              Command(Scan.jsr, Stat.NoSize, Com.SysRetFail, NIL);
            ELSE
              Return(symbols.lev, symbols.lev);
            END;
          END;
          symbols := symbols.syms;

      | Stat.Ret:
          Return(SHORT( s.a0), symbols.lev);

      | Stat.Options, Stat.OutCtrl:

      | Stat.Code:
          codeRider := s.a0;
          INC(pc, codeRider.Size());
          codeRd.MergeWith(codeRider);

      ELSE
          IF s.form >= Stat.Ass THEN
            IF (s.form >= Scan.dbt) & (s.form <= Scan.dble) THEN
              DbccCommand( s.form, Distance(s, s.expr2), s.expr );
            ELSIF (s.form >= Scan.fbf) & (s.form <= Scan.ble) THEN
              BranchCommand( s.form, SHORT( s.a0), Distance(s, s.expr));
            ELSIF s.form = Scan.base THEN
              Expr.baselab := s.expr.sym.a0;
            ELSIF s.form = Scan.dc THEN
              DcCommand( SHORT( s.a0), Expr.Evaluate(s.expr) );
            ELSIF s.form # Scan.label THEN
              Command(s.form, SHORT( s.a0), s.expr, s.expr2)
            END;
          ELSE
            IO.WriteString( "Unknown statement in WriteCode:"); IO.WriteLn;
            Stat.OutputStat(s);
            HALT(98);
          END;

      END;
      CheckCodeLength(SHORT( pc-prevpc), s);
      s := s.next;
    END;

    codeRd.MergeWith(dataRd);

    codeRd.MergeWith(symRd);	(* store symbol segment *)

    codeRd.FileOut(obj);

    codeRd.FileOutReloc(obj);	(* store relocation table *)

    CloseFile;
  END;
 END WriteCode;


PROCEDURE Init*;
 BEGIN
  tsize := 16;	(* Header + jmp *)
  vsize := 2;	(* initvar *)
  dsize := 0;
  ssize := 0;
  tdsx := 0;
  proccnt := 0; numproc := 0;
 END Init;


PROCEDURE Exit*;
  VAR
    i: INTEGER;
 BEGIN
  module := NIL; symbols := NIL;
  objfile := NIL;
  FOR i := 0 TO TDStructSize-1 DO
    tdStructs[i] := NIL;
  END;
  codeRd := NIL; dataRd := NIL;
  obj.Set(NIL, 0);
 END Exit;


END OCCoder.