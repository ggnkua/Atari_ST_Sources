MODULE MasPar;

(* History :
   SJ  18.3.93  : adaptation from ObnPar
   		 19.3.93  : variables added
   		 20.3.93  : extensions added
   		 24.3.93  : parameter setting
   		 29.4.93  : parameters from environment
*)

IMPORT S:=SYSTEM, Env:=Environment, Paths;

CONST on = "ON";

VAR
  MaxErr*,PageSize*  : INTEGER;
  ErrorFormat*,PrtInit*,PrtExit*,Title* : ARRAY 50 OF CHAR;
  WarningsOut*,ListOn*,Bin*,Spec*,IdCap*,CommCap*,MacExp* : BOOLEAN;
  SrcExt*,BinExt*,LstExt*,SpecExt*,s : ARRAY 4 OF CHAR;
  Value : LONGINT;
  paths* : Paths.path;

BEGIN
  IF Env.ReadInt("MAXERR",10,Value) THEN MaxErr := SHORT(Value)
  ELSE MaxErr := 100
  END;
  IF Env.ReadInt("PAGESIZE",10,Value) THEN PageSize := SHORT(Value)
  ELSE PageSize := 60
  END;
  IF NOT Env.ReadStr("ERRFORM",ErrorFormat) THEN
    ErrorFormat := "Error \d \z, \s: \f";
  END;
  IF NOT Env.ReadStr("PRTINIT",PrtInit) THEN PrtInit[0] := 0X END;
  IF NOT Env.ReadStr("PRTEXIT",PrtExit) THEN PrtExit[0] := 0X END;
  IF NOT Env.ReadStr("TITLE",Title) THEN Title[0] := 0X END;
  IF NOT Env.ReadStr("SRCEXT",SrcExt) THEN SrcExt := "ASM" END;
  IF NOT Env.ReadStr("BINEXT",BinExt) THEN BinExt := "BIN" END;
  IF NOT Env.ReadStr("LSTEXT",LstExt) THEN LstExt := "LST" END;
  IF NOT Env.ReadStr("SPECEXT",SpecExt) THEN SpecExt := 'P' END;
  ListOn := Env.ReadStr("LIST",s) AND (s = on);
  Bin := NOT Env.ReadStr("BIN",s) OR (s = on);
  Spec := Env.ReadStr("SPEC",s) AND (s = on);
  CommCap := NOT Env.ReadStr("COMMCAP",s) OR (s = on);
  IdCap := Env.ReadStr("IDCAP",s) AND (s = on);
  MacExp := NOT Env.ReadStr("MACEXP",s) OR (s = on);
  WarningsOut := Env.ReadStr("WARNOUT",s) AND (s = on);
  Paths.Read("MASSPATH", paths);
END MasPar.