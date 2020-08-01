  MODULE OCFPU030; (* SJ 8.10.94 *)

(*
 Make the assembler output suitable for an 68000 without FPU if desired.
 *)


IMPORT
  Stat:=OCStat, Expr:=OCExpr, Com:=OCCom, Par:=OCPar, Sym:=OCSymbol,
  Assembler:=OCAssembler, AssOpt:=OCAssOpt, Scan:=OCScan, Err:=OCErr,
  OCOutput;



CONST
  noemu030 = 197; noemufpu = 198;



VAR
  stack, storedStack: LONGINT;

(*$T- *)

PROCEDURE High(x: Expr.Expr) : Expr.Expr;
  VAR
    y: Expr.Expr;
 BEGIN
  y := Expr.Copy(x);
  IF (y.form = Expr.ACon) OR (y.form = Expr.Imm) THEN
    y.op1 := Expr.EvaluateExpr(y.op1);
    y.op1.typ := Sym.linttyp;
  END;
  y.typ := Sym.linttyp;
  RETURN y;
 END High;


PROCEDURE Low(x: Expr.Expr) : Expr.Expr;
  VAR
    y, z, four, disp: Expr.Expr;
 BEGIN
  Expr.New(x.form, y, Sym.linttyp);
  Expr.New(Expr.Add, z, Sym.linttyp);
  Expr.New(Expr.Disp, disp, Sym.linttyp);
  four := Com.Const(4, Sym.sinttyp);
  y.op1 := z; z.op1 := x.op1; z.op2 := four;	(* default *)
  CASE x.form OF

    Expr.ARI:
      z.form := Expr.Disp; y.form := Expr.DA;

  | Expr.DA, Expr.DAX, Expr.PCDI:(* assume that displacement + 4 in range *)
      IF Expr.IsConst (x.op1.op2) OR (x.op1.op2.form = Expr.Sym) THEN
        y.op1 := Expr.Copy(x.op1); z.op1 := x.op1.op2; y.op1.op2 := z;
        z.typ := z.op1.typ;
      ELSE
        disp.op1 := Expr.Copy(x.op1); disp.op2 := four;
        y.op1 := disp;
      END;

  | Expr.AbsW, Expr.AbsL, Expr.Mem, Expr.PCD:

  | Expr.Sym:
      y := z; y.op1 := x;

  | Expr.MIPo, Expr.MIPr, Expr.PCPo, Expr.PCPr:
      IF (x.op1.form = Expr.Disp) & Expr.IsConst(x.op1.op2) THEN (* disp *)
        disp.op1 := x.op1.op1; disp.op2 := z;
        z.op1 := x.op1.op2; y.op1 := disp;
        z.typ := z.op1.typ;
      ELSE
        z.form := Expr.Disp; z.op1 := x.op1
      END;

  | Expr.Imm, Expr.ACon:
      y.op1 := Expr.EvaluateExpr(x.op1);
      y.op1.a0 := y.op1.a1;
      y.op1.typ := Sym.linttyp;

  ELSE
    HALT(99)
  END;
  RETURN y;
 END Low;


PROCEDURE Push(s: Stat.Stat; x: Expr.Expr);
  VAR
    msp: Expr.Expr;
 BEGIN
  msp := Com.MSP(); msp.form := Expr.APD;
  IF x.typ.form = Sym.Real THEN
    Assembler.InsertAss(s, Scan.move, Sym.linttyp, x, msp);
  ELSIF x.typ.form = Sym.LReal THEN
    Assembler.InsertAss(s, Scan.move, Sym.linttyp, Low(x), msp);
    Assembler.InsertAss(s, Scan.move, Sym.linttyp, High(x), msp);
  ELSE
    Assembler.InsertAss(s, Scan.move, x.typ, x, msp);
  END;
  INC(stack, x.typ.size);
  IF ODD(stack) THEN INC(stack) END;
 END Push;


PROCEDURE PushAdr(s: Stat.Stat; x: Expr.Expr);
 BEGIN
  Assembler.InsertAss(s, Scan.pea, Sym.notyp, x, NIL);
  INC(stack, 4);
 END PushAdr;


PROCEDURE StoreStack;
 BEGIN
  storedStack := stack;
 END StoreStack;


PROCEDURE Call(s: Stat.Stat; x: Expr.Expr);
  VAR
    sp: Expr.Expr;
 BEGIN
  Com.PrepareSysProc(x);
  Assembler.InsertAss(s, Scan.jsr, Sym.notyp, x, NIL);
  IF storedStack # stack THEN
    sp := Com.SP();
    Assembler.InsertAss(s, Scan.adda, Sym.linttyp,
        Com.AConst(stack - storedStack, Sym.linttyp), sp);
    stack := storedStack;
  END;
 END Call;


PROCEDURE CallLSD(s: Stat.Stat; long, single, double: Expr.Expr);
 BEGIN
  IF s.a0 = Stat.Long THEN Call(s, long)
  ELSIF s.a0 = Stat.Single THEN Call(s, single)
  ELSE Call(s, double)
  END;
 END CallLSD;


PROCEDURE EmuFPU1(VAR s: Stat.Stat; singleF, doubleF : Expr.Expr);
 BEGIN
  Push(s, Com.AConst(s.expr.a0, Sym.inttyp) );
  CallLSD(s, NIL, singleF, doubleF);
  Stat.Remove(s);
 END EmuFPU1;


PROCEDURE EmuFPU2(VAR s: Stat.Stat; singleFF, doubleFF,
                 longXF, singleXF, doubleXF,
                 longFX, singleFX, doubleFX : Expr.Expr);
  VAR
    disp: Expr.Expr;
 BEGIN
  IF s.expr2.form = Expr.FPn THEN	(* dest = fpn *)
    IF s.expr.form = Expr.FPn THEN	(* & src = fpn *)
      Push(s, Com.AConst(s.expr.a0, Sym.inttyp) );
      Push(s, Com.AConst(s.expr2.a0, Sym.inttyp) );
      CallLSD(s, NIL, singleFF, doubleFF);
    ELSE
      Push(s, s.expr);
      Push(s, Com.AConst(s.expr2.a0, Sym.inttyp) );
      CallLSD(s, longXF, singleXF, doubleXF);
    END;
  ELSIF s.a0 = Stat.Long THEN		(* longFX *)
    Push(s, Com.AConst(s.expr.a0, Sym.inttyp) );
    Call(s, longFX);
    Com.PrepareSysProc(Com.EmuFPUresult);
    Assembler.InsertAss(s, Scan.move, Sym.linttyp, Com.EmuFPUresult,
        s.expr2);
  ELSE					(* src = fpn *)
    IF (s.expr2.form = Expr.PreDec) OR (s.expr2.form = Expr.APD) THEN
      Assembler.InsertAss(s, Scan.subq, Sym.linttyp,
          Com.AConst(s.expr.typ.size, Sym.notyp), s.expr2.op1);
      s.expr2.form := Expr.ARI;
      IF (s.expr2.op1.form = Expr.SP)
          OR (s.expr2.op1.form = Expr.An) & (s.expr2.op1.a0 = 7) THEN
        Expr.New(Expr.Disp, disp, s.expr2.typ);
        disp.op1 := s.expr2.op1;
        disp.op2 := Com.Const(2, Sym.inttyp);
        s.expr2.op1 := disp; s.expr2.form := Expr.DA;
      END;
    END;
    Push(s, Com.AConst(s.expr.a0, Sym.inttyp) );
    PushAdr(s, s.expr2);
    CallLSD(s, longFX, singleFX, doubleFX);
  END;
  Stat.Remove(s);
 END EmuFPU2;


PROCEDURE GetD2(VAR e: Expr.Expr);
(*
 Return a Dn expression with register 1.
 *)
 BEGIN
  Expr.New(Expr.Dn, e, e.typ); e.a0 := 2; e.a1 := 1;
 END GetD2;


PROCEDURE GetA1(VAR e: Expr.Expr);
(*
 Return a An expression with register 0.
 *)
 BEGIN
  Expr.New(Expr.An, e, e.typ); e.a0 := 1; e.a1 := 1;
 END GetA1;


PROCEDURE FindIndexReg(e: Expr.Expr; VAR y: Expr.Expr);
 BEGIN
  IF e.op1.form = Expr.Disp THEN
    IF (e.op1.op2.form = Expr.XReg) THEN
      y := e.op1.op2.op1; RETURN
    ELSIF (e.op1.op2.form = Expr.Dn) OR (e.op1.op2.form = Expr.An) THEN
      y := e.op1.op2; RETURN
    END;
    IF e.op1.op1.form = Expr.Disp THEN
      IF (e.op1.op1.op2.form = Expr.XReg) THEN
        y := e.op1.op1.op2.op1; RETURN
      ELSIF (e.op1.op1.op2.form = Expr.Dn) OR (e.op1.op1.op2.form = Expr.An) THEN
        y := e.op1.op1.op2; RETURN
      END;
    END;
  END;
  HALT(99);
 END FindIndexReg;


PROCEDURE FindDisp(e: Expr.Expr; VAR y: Expr.Expr) : BOOLEAN;
 BEGIN
  IF e.op1.form = Expr.Disp THEN
    IF Expr.IsConst(e.op1.op2) THEN
      y := e.op1.op2; RETURN TRUE
    END;
    IF e.op1.op1.form = Expr.Disp THEN
      IF Expr.IsConst(e.op1.op1.op2) THEN
        y := e.op1.op1.op2; RETURN TRUE
      END;
    END;
  END;
  RETURN FALSE
 END FindDisp;


PROCEDURE WordDisp(x: Expr.Expr) : BOOLEAN;
 BEGIN
  RETURN x.typ.size <= 2
 END WordDisp;


PROCEDURE ByteDisp(x: Expr.Expr) : BOOLEAN;
 BEGIN
  RETURN x.typ.size = 1
 END ByteDisp;


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


PROCEDURE HasIndex(e: Expr.Expr) : BOOLEAN;
 BEGIN
  IF (e.op1.form = Expr.Disp) THEN
    IF (e.op1.op2.form = Expr.XReg) OR (e.op1.op2.form = Expr.Dn) THEN
      RETURN TRUE
    END;
    RETURN HasIndex(e.op1);
  END;
  RETURN FALSE
 END HasIndex;


PROCEDURE SetDAX(e: Expr.Expr);
 BEGIN
  IF HasIndex(e) THEN e.form := Expr.DAX ELSE e.form := Expr.DA END;
 END SetDAX;


PROCEDURE^ StandardAddr(s: Stat.Stat; VAR x: Expr.Expr);


PROCEDURE ReplaceInd(s: Stat.Stat; e: Expr.Expr);
  VAR
    ind, ind2, a1: Expr.Expr;
 BEGIN
  IF SearchInd(e, ind2) THEN
    ind := ind2; SetDAX(ind);
    StandardAddr(s, ind); GetA1(a1);
    Assembler.InsertAss(s, Scan.move, Sym.linttyp, ind, a1);
    Expr.CopyCont(a1, ind2);
  END;
 END ReplaceInd;


PROCEDURE StandardAddr(s: Stat.Stat; VAR x: Expr.Expr);
  VAR
    e, dreg, xreg, reg, disp, d, cp, cp2: Expr.Expr;
 BEGIN
  Expr.New(Expr.Dn, dreg, Sym.linttyp); dreg.a0 := 2; dreg.a1 := 1;
  Expr.New(Expr.XReg, xreg, Sym.linttyp); xreg.op1 := dreg;
  e := x;
  CASE e.form OF

    Expr.DA, Expr.PCD:		(* check word size of disp *)
      IF FindDisp(e, disp) & ~WordDisp(disp) THEN
        cp := Expr.Copy(disp);
        Assembler.InsertAss(s, Scan.move, Sym.linttyp, Com.ACon(cp), dreg);
        e.form := Expr.DAX; Expr.CopyCont(xreg, disp);
      END;

  | Expr.DAX, Expr.PCDI:	(* check byte size of disp *)
      IF FindDisp(e, disp) & ~ByteDisp(disp) THEN
        FindIndexReg(e, reg);
        cp := Expr.Copy(disp);
        Assembler.InsertACon(cp);
        cp2 := Expr.Copy(reg);
        IF (reg.typ.size = 4) OR ~WordDisp(disp) THEN
          cp.typ := Sym.linttyp;
          IF reg.typ.size # 4 THEN
            Assembler.InsertAss(s, Scan.clr, Sym.linttyp, dreg, NIL);
          END;
          Assembler.InsertAss(s, Scan.move, reg.typ, cp2, dreg);
          Assembler.InsertAss(s, Scan.add, Sym.linttyp, cp, dreg);
        ELSE
          cp.typ := Sym.inttyp;
          Assembler.InsertAss(s, Scan.move, Sym.inttyp, cp2, dreg);
          Assembler.InsertAss(s, Scan.add, Sym.inttyp, cp, dreg);
          dreg.typ := Sym.inttyp; xreg.typ := Sym.inttyp;
        END;
        Expr.CopyCont(dreg, reg);
        d := Com.Const(0, Sym.sinttyp);
        Expr.CopyCont(d, disp);
      END;

  | Expr.MIPo, Expr.MIPr, Expr.PCPo, Expr.PCPr:	(* emulate *)
      ReplaceInd(s, e);				(* Ind -> A1 *)
      SetDAX(e);
      StandardAddr(s, e);

  | Expr.DDn:
      Err.Mark(noemu030);

  ELSE
  END;
  x := e;
 END StandardAddr;


PROCEDURE CheckFMove(begin: Stat.Stat);
  VAR
    s: Stat.Stat;
    form : INTEGER;
 BEGIN
  s := begin;
  WHILE s # NIL DO
    IF (s.form = Scan.move)
        & ((s.expr.form = Expr.FPn) OR (s.expr2.form = Expr.FPn)) THEN
      s.form := Scan.fmove;
      IF s.expr.typ.form = Sym.LInt THEN s.a0 := Stat.Single END;
      IF (s.expr.form = Expr.FPn) & (s.expr2.form = Expr.FPn) THEN
        IF (s.a0 < Stat.Single) THEN
          form := s.expr.typ.form;
          IF ~(form IN {Sym.Real, Sym.LReal}) THEN
            form := s.expr2.typ.form;
            IF ~(form IN {Sym.Real, Sym.LReal}) THEN form := Sym.Real END;
          END;
          IF form = Sym.Real THEN s.a0 := Stat.Single
          ELSE s.a0 := Stat.Double
          END;
        END;
      END;
    END;
    s := s.next;
  END;
 END CheckFMove;


PROCEDURE Emulate*(begin: Stat.Stat);
  VAR
    s, fail, pass: Stat.Stat;
 BEGIN
  CheckFMove(begin);
  IF ~Par.fpu THEN
    s := begin;
    WHILE s # NIL DO
      StoreStack;
      CASE s.form OF
        Scan.fmove:
          IF ~AssOpt.Match(s.expr, s.expr2) THEN
            EmuFPU2(s, Com.EmuFPUFMoveSFF, Com.EmuFPUFMoveDFF,
                Com.EmuFPUFMoveLXF, Com.EmuFPUFMoveSXF, Com.EmuFPUFMoveDXF,
                Com.EmuFPUFMoveLFX, Com.EmuFPUFMoveSFX, Com.EmuFPUFMoveDFX);
          END;

      | Scan.fadd:
          EmuFPU2(s, Com.EmuFPUFAddSFF, Com.EmuFPUFAddDFF, NIL,
              Com.EmuFPUFAddSXF, Com.EmuFPUFAddDXF, NIL, NIL, NIL);

      | Scan.fsub:
          EmuFPU2(s, Com.EmuFPUFSubSFF, Com.EmuFPUFSubDFF, NIL,
              Com.EmuFPUFSubSXF, Com.EmuFPUFSubDXF, NIL, NIL, NIL);

      | Scan.fsglmul, Scan.fmul: (* ? *)
          EmuFPU2(s, Com.EmuFPUFMulSFF, Com.EmuFPUFMulDFF, NIL,
              Com.EmuFPUFMulSXF, Com.EmuFPUFMulDXF, NIL, NIL, NIL);

      | Scan.fdiv:
          EmuFPU2(s, Com.EmuFPUFDivSFF, Com.EmuFPUFDivDFF, NIL,
              Com.EmuFPUFDivSXF, Com.EmuFPUFDivDXF, NIL, NIL, NIL);

      | Scan.fabs:
          IF s.expr2 = NIL THEN
            EmuFPU1(s, Com.EmuFPUFAbsSF, Com.EmuFPUFAbsDF);
          ELSE
            EmuFPU2(s, Com.EmuFPUFAbsSFF, Com.EmuFPUFAbsDFF, NIL,
                Com.EmuFPUFAbsSXF, Com.EmuFPUFAbsDXF, NIL, NIL, NIL);
          END;

      | Scan.fneg:
          IF s.expr2 = NIL THEN
            EmuFPU1(s, Com.EmuFPUFNegSF, Com.EmuFPUFNegDF);
          ELSE
            EmuFPU2(s, Com.EmuFPUFNegSFF, Com.EmuFPUFNegDFF, NIL,
                Com.EmuFPUFNegSXF, Com.EmuFPUFNegDXF, NIL, NIL, NIL);
          END;

      | Scan.fbeq:
          Assembler.ReplaceAss(s, Scan.beq, Sym.inttyp, s.expr, NIL);

      | Scan.fbne:
          Assembler.ReplaceAss(s, Scan.bne, Sym.inttyp, s.expr, NIL);

      | Scan.fbge:
          Assembler.ReplaceAss(s, Scan.bge, Sym.inttyp, s.expr, NIL);

      | Scan.fble:
          Assembler.ReplaceAss(s, Scan.ble, Sym.inttyp, s.expr, NIL);

      | Scan.fblt:
          Assembler.ReplaceAss(s, Scan.blt, Sym.inttyp, s.expr, NIL);

      | Scan.fbgt:
          Assembler.ReplaceAss(s, Scan.bgt, Sym.inttyp, s.expr, NIL);

      | Scan.fseq:
          Assembler.ReplaceAss(s, Scan.seq, Sym.inttyp, s.expr, NIL);

      | Scan.fsne:
          Assembler.ReplaceAss(s, Scan.sne, Sym.inttyp, s.expr, NIL);

      | Scan.fsge:
          Assembler.ReplaceAss(s, Scan.sge, Sym.inttyp, s.expr, NIL);

      | Scan.fsle:
          Assembler.ReplaceAss(s, Scan.sle, Sym.inttyp, s.expr, NIL);

      | Scan.fslt:
          Assembler.ReplaceAss(s, Scan.slt, Sym.inttyp, s.expr, NIL);

      | Scan.fsgt:
          Assembler.ReplaceAss(s, Scan.sgt, Sym.inttyp, s.expr, NIL);

      | Scan.fcmp:
          EmuFPU2(s, Com.EmuFPUFCmpSFF, Com.EmuFPUFCmpDFF, NIL,
              Com.EmuFPUFCmpSXF, Com.EmuFPUFCmpDXF, NIL, NIL, NIL);

      ELSE
          IF (s.form >= Scan.fmove) & (s.form <= Scan.fbst) THEN
            Err.Mark(noemufpu)
          END;
      END;
      s := s.next
    END;
  END;
  IF ~Par.xcode THEN
    s := begin;
    WHILE s # NIL DO
      IF (s.form = Scan.chk) & (s.a0 = Stat.Long) THEN
        Assembler.InsertAss(s, Scan.move, Sym.linttyp, s.expr2,
            Com.Dn(0, Sym.linttyp) );
        Assembler.InsertAss(s, Scan.move, Sym.linttyp, s.expr,
            Com.Dn(1, Sym.linttyp) );
        Call(s, Com.SysCheckLongIndex);
        Stat.Remove(s);

      ELSIF ((s.form = Scan.muls) OR (s.form = Scan.mulu)
              OR (s.form = Scan.divs)  OR (s.form = Scan.divu))
            & (s.a0 = Stat.Long) THEN
        Push(s, s.expr); Push(s, s.expr2);
        CASE s.form OF
          Scan.muls:
            Call(s, Com.Emu030MulsL);
        | Scan.mulu:
            Call(s, Com.Emu030MuluL);
        | Scan.divs:
            Call(s, Com.Emu030DivsL);
        | Scan.divu:
            Call(s, Com.Emu030DivuL);
        END;
        Com.PrepareSysProc(Com.Emu030result);
        Assembler.InsertAss(s, Scan.move, Sym.linttyp, Com.Emu030result,
            s.expr2);
        Stat.Remove(s);

      ELSIF (s.form = Scan.divsl) OR (s.form = Scan.divul)
            OR (s.form = Scan.mulsl) OR (s.form = Scan.mulul) THEN
        (* s.expr2.form = DDn *)
        Push(s, s.expr); Push(s, s.expr2.op1); Push(s, s.expr2.op2);
        CASE s.form OF
          Scan.mulsl:
            Call(s, Com.Emu030MulslL);
        | Scan.mulul:
            Call(s, Com.Emu030MululL);
        | Scan.divsl:
            Call(s, Com.Emu030DivslL);
        | Scan.divul:
            Call(s, Com.Emu030DivulL);
        END;
        Com.PrepareSysProc(Com.Emu030result);
        Com.PrepareSysProc(Com.Emu030result2);
        Assembler.InsertAss(s, Scan.move, Sym.linttyp, Com.Emu030result,
            s.expr2.op2);
        Assembler.InsertAss(s, Scan.move, Sym.linttyp, Com.Emu030result2,
            s.expr2.op1);
        Stat.Remove(s);

      ELSIF s.form = Scan.extb THEN
        Assembler.InsertAss(s, Scan.ext, Sym.inttyp, s.expr, NIL);
        Assembler.ReplaceAss(s, Scan.ext, Sym.linttyp, s.expr, NIL);

      ELSIF (s.form = Scan.tst) & (s.expr.form = Expr.An) THEN
        Assembler.ReplaceAss(s, Scan.move, Sym.linttyp, s.expr,
            Com.Dn(0, Sym.linttyp) );

      ELSIF (s.form = Scan.chk2) OR (s.form = Scan.cmp2)
            OR (s.form = Scan.rtd) OR (s.form = Scan.movec) THEN
        Err.Mark(noemu030);

      END;
      s := s.next
    END;

    s := begin;	(* now the addressing modes *)
    WHILE s # NIL DO
      IF s.form >= Stat.Ass THEN
        IF s.expr # NIL THEN StandardAddr(s, s.expr) END;
        IF s.expr2 # NIL THEN StandardAddr(s, s.expr2) END;
      END;
      s := s.next
    END;
  END;
 END Emulate;


END OCFPU030.
