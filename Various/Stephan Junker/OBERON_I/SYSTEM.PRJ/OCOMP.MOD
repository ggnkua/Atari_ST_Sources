MODULE OComp; (* SJ 16.9.94 / 3.12.94 *)


IMPORT
  S:=SYSTEM, OCSymScan, OCAssembler, OCAssOpt, OCRegOpt, OCStatOpt,
  OCStatScan, OCAss, OCFPU030, OCCoder, Par:=OCPar, Err:=OCErr,
  Stat:=OCStat, Sym:=OCSymbol, Expr:=OCExpr, Com:=OCCom, OCImport,
  OCOutput, OCScan, Sys, CommandLine, IO, FN:=Filename, Paths, File,
  GEMDOS, ObnEnv, AssOpt:=OCAssOpt, Task, OCInfo;



VAR
  begStat: Stat.Stat;
  symbols: Sym.Symbol;
  begad  : S.PTR;



PROCEDURE SeparateExpr(VAR x: Expr.Expr; VAR hasComplexExpr : BOOLEAN);
  VAR
    prev, first, second, op1Temp: BOOLEAN;
 BEGIN
  IF Expr.Complex(x) THEN
    prev := hasComplexExpr;
    op1Temp := (x.form # Expr.Adr) & (x.form # Expr.Disp);
    first := prev & op1Temp;
    SeparateExpr(x.op1, first);
    second := FALSE;
    IF Expr.HasOp2(x) THEN
      second := first OR hasComplexExpr OR ~op1Temp;
      SeparateExpr(x.op2, second)
    END;
    IF prev THEN Com.Temporize(symbols, x);
    ELSIF op1Temp & first THEN Com.Temporize(symbols, x.op1);
    ELSIF op1Temp & second THEN Com.Temporize(symbols, x.op2);
    END;
    hasComplexExpr := TRUE;
  END;
 END SeparateExpr;


PROCEDURE Separate(stat: Stat.Stat);
(*
 Separate the expressions in the statements until only one complex
 expression remains in every statement.
 *)
  VAR
    s: Stat.Stat;
    hasComplexExpr : BOOLEAN;	(* true = curr stat has one complex expr *)
    sym: Sym.Symbol;
    x: Expr.Expr;
 BEGIN
  Stat.Environment(stat, sym, s);
  s := stat; symbols := sym.syms;
  WHILE s # NIL DO
    Stat.ReadOptions(s);
    hasComplexExpr := FALSE;
    Stat.insert := s;
    CASE s.form OF
      Stat.Asgn:
        IF ((s.expr2.form = Expr.Add) OR (s.expr2.form = Expr.Sub))
            & Expr.IsConst(s.expr2.op2) & AssOpt.Match(s.expr, s.expr2.op1) THEN
          SeparateExpr(s.expr, hasComplexExpr);
          s.expr2.op1 := s.expr;
        ELSE
          SeparateExpr(s.expr, hasComplexExpr);
          SeparateExpr(s.expr2, hasComplexExpr);
        END;

    | Stat.Call, Stat.Bra:
        SeparateExpr(s.expr, hasComplexExpr);

    | Stat.Bct, Stat.Bcf:
        IF (s.expr2.form = Expr.Cmp) & Expr.IsConst(s.expr2.op2) THEN
          SeparateExpr(s.expr2.op1, hasComplexExpr);
        ELSE
          SeparateExpr(s.expr2, hasComplexExpr);
        END;

    | Stat.Begin:
        Com.varpos := SHORT( s.a0);
        begStat := s;

    | Stat.End:
        begStat.a0 := Com.varpos;

    ELSE
    END;
    s := s.next;
  END;
 END Separate;


PROCEDURE Run();
  VAR
    stat: Stat.Stat;
 BEGIN
  OCSymScan.ScanSymbols();
  IF Err.scanerr THEN RETURN END;
  stat := Stat.stats;
  WHILE stat # NIL DO
    IF stat.form = Stat.Begin THEN
      OCStatScan.ScanStats(stat);
      IF Par.display[0] THEN Stat.Output(stat, 0) END;
      IF ~Err.scanerr THEN
        IF Par.process[1] THEN Separate(stat) END;
        IF Par.display[1] THEN Stat.Output(stat, 1) END;
        IF Par.process[2] THEN OCStatOpt.Optimize(stat) END;
        IF Par.display[2] THEN Stat.Output(stat, 2) END;
        IF Par.process[3] THEN OCRegOpt.Optimize(stat) END;
        IF Par.display[3] THEN Stat.Output(stat, 3) END;
        IF Par.process[4] THEN OCAssembler.Assemble(stat) END;
        IF Par.display[4] THEN Stat.Output(stat, 4) END;
        IF Par.process[5] & (~Par.fpu OR ~Par.xcode) THEN OCFPU030.Emulate(stat) END;
        IF Par.display[5] THEN Stat.Output(stat, 5) END;
        IF Par.process[6] THEN OCAssOpt.Optimize(stat) END;
        IF Par.display[6] THEN Stat.Output(stat, 6) END;
        IF Par.reass THEN Stat.Output(stat, 9) END;
        IF Par.process[8] THEN OCCoder.Code(stat) END;
        Stat.insert := NIL;
        Stat.DisposeExpr(stat);
      END;
    END;
    stat := stat.next;
  END;
 END Run;


PROCEDURE Output(VAR name: ARRAY OF CHAR);
  VAR
    key: LONGINT;
    date, time: INTEGER;
 BEGIN
  IO.WriteLn;
  date := GEMDOS.Tgetdate(); time := GEMDOS.Tgettime();
  key := date * 10000H + S.LONG( time);
  IF ~Err.scanerr THEN
    IF Par.process[7] THEN
      OCCoder.WriteData;
      OCInfo.Export(name, OCSymScan.modid);
      OCImport.Export(name, OCSymScan.modid, key);
      OCCoder.WriteCode(name, key)
    END;
    IO.WriteLn;
    IO.WriteString("Compilation succeeded");
  ELSE
    IO.WriteString("Errors detected");
  END;
  IO.WriteLn;
 END Output;


PROCEDURE Exit;
 BEGIN
  IF begad # NIL THEN
    OCStatOpt.Exit; OCRegOpt.Exit; OCAssembler.Exit; OCSymScan.Exit;
    OCCoder.Exit; Com.Exit; OCImport.Exit; Stat.Exit; Expr.Exit; Sym.Exit;
    OCScan.Exit; Err.Exit; OCOutput.Exit; Par.Exit; OCInfo.Exit;
    S.DISPOSE(begad); begad := NIL;
  END;
 END Exit;


PROCEDURE Init(begad : S.PTR; VAR name : ARRAY OF CHAR);
 BEGIN
  OCOutput.Init(name); Err.Init(name); OCScan.Init(begad); Sym.Init;
  Expr.Init; Stat.Init; OCImport.Init; Com.Init; OCCoder.Init;
  OCSymScan.Init; OCAssembler.Init; OCRegOpt.Init; OCStatOpt.Init;
  OCInfo.Init;
 END Init;


PROCEDURE CompileIt(VAR cname: ARRAY OF CHAR);
(*
 Compiles cname. No Exit is called.
 *)
  VAR
    name   : FN.path;
    ext    : ARRAY 4 OF CHAR;
    length : LONGINT;
 BEGIN
  COPY(cname, name);
  FN.GetExt( name, ext);
  IF ext = "" THEN FN.SetExt("MOD", name) END(*IF*);
  IF Paths.Get(Par.ModPaths, name, {}, name) THEN
    IF File.Load( name, 0, 1, begad, length) THEN
      IO.WriteString( "Compiling "); IO.WriteString( name); IO.WriteLn;
      S.PUT( begad + length, 0);		(* mark eof *)
      Init(begad, name);
      Run;
      Output(name);
    END;
  ELSE
    IO.WriteString(name);
    IO.WriteString(" not found"); IO.WriteLn;
    Err.scanerr := TRUE;
  END(*IF*);
  Exit;
 END CompileIt;


PROCEDURE Compile*;
(*
 * compile an ascii source file defined by the command line.
 *)
 BEGIN
  Exit; (* in case last execution was aborted *)
  Task.Init;
  IO.WriteString("Oberon compiler V2.14  (c) Stephan Junker  ");
  IO.WriteString( Sys.compDate); IO.WriteLn;
  (* evaluate command line *)
  IF CommandLine.arg = NIL THEN
    IO.WriteString("Usage: compile <options> <module>"); IO.WriteLn;
    Task.Exit(1);
  ELSE
    Par.Init;
    WHILE (CommandLine.arg # NIL) AND Par.ReadOptions(CommandLine.arg^) DO
      CommandLine.Next()
    END(*WHILE*);
    IF CommandLine.arg # NIL THEN
      Par.ReadPaths;
      REPEAT
        CompileIt(CommandLine.arg^);
        CommandLine.Next();
      UNTIL (CommandLine.arg = NIL) OR (CommandLine.arg^ = '&') OR Err.scanerr;
      IF ~Err.scanerr THEN Task.Exit(0) END;
      Task.Exit(3)
    ELSE
      IO.WriteString("No module name found"); IO.WriteLn;
      Task.Exit(2);
    END(*IF*);
  END;
 END Compile;


END OComp.