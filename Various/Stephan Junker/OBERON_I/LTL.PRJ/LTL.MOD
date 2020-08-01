MODULE LTL;


IMPORT
  Sys, IO, CommandLine, FN:=Filename, StdPath, OLDPar, O2Modules, Strings;


PROCEDURE Call*(VAR Command : ARRAY OF CHAR);
  VAR
    i,j : INTEGER;
    ModName,ProcName : ARRAY 30 OF CHAR;
    s,path : FN.path;
    Mod : O2Modules.Module;
    Proc : O2Modules.Command;
 BEGIN
  OLDPar.Init;
  O2Modules.importsIO := FALSE;
  i := 0;
  WHILE (Command[i] = " ") DO INC(i) END;
  j := 0;
  WHILE (Command[i] >= "0") DO
    ModName[j] := Command[i]; INC(i); INC(j)
  END;
  ModName[j] := 0X; j := 0;
  FN.GetPath( ModName, path);
  StdPath.Set( path);
  IF Command[i] = "." THEN
    INC(i);
    WHILE (Command[i] >= "0") DO
      ProcName[j] := Command[i]; INC(i); INC(j)
    END;
    ProcName[j] := 0X;
    COPY( ProcName, s); Strings.CAPs(s);
    IF s = "OBJ" THEN ProcName := "Run" END;
  ELSE
    ProcName := "Run";
  END;
  WHILE (Command[i] = " ") DO INC(i) END;
  j := 0;
  WHILE Command[i] # 0X DO
    Sys.Basepage.Command[j] := Command[i]; INC(i); INC(j)
  END;
  Sys.Basepage.Command[j] := 0X; Sys.Basepage.ComLen := SHORT(j);
  CommandLine.Reset;
  Mod := O2Modules.Load(ModName);
  IF Mod = NIL THEN
    IO.WriteString( "Module "); IO.WriteString( ModName);
    IO.WriteString( " could not be loaded."); IO.WriteLn;
  ELSIF ProcName # "" THEN
    Proc := O2Modules.GetCommand(Mod, ProcName);
    IF Proc = NIL THEN
      IO.WriteString( "Procedure "); IO.WriteString( ProcName);
      IO.WriteString( " not found."); IO.WriteLn;
    ELSE
      Proc;
    END;
  END;
 END Call;


END LTL.