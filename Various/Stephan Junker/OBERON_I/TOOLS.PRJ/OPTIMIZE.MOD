MODULE Optimizer; (* SJ 8.7.95 *)


IMPORT
  S:=SYSTEM, Sys, Task, CommandLine, IO, Filename, Env:=Environment,
  Strings, Paths, File, OCPar, OCErr, OCScan;


CONST
  (* symbol types *)
  Proc = 0; Tbp = 1;


TYPE
  Name   = ARRAY 30 OF CHAR;

  Symbol = POINTER TO SymDesc;
  SymDesc = RECORD
    next: Symbol;
    name: Name;
    used: BOOLEAN;
    scanned: BOOLEAN;
    type: INTEGER;
    start, end: S.PTR;
  END;

  Import = POINTER TO ImpDesc;
  Module = POINTER TO ModDesc;
  ModDesc = RECORD
    next: Module;
    name: ARRAY 14 OF CHAR;
    start, end: S.PTR;
    symbols: Symbol;
    procStart, procEnd: S.PTR;
    imports: Import;
  END;

  ImpDesc = RECORD
    next: Import;
    shortName, longName: Name;
    module: Module;
  END;


VAR
  (* global module list *)
  modules, lastMod: Module;
  destination: Filename.path;


PROCEDURE Scan(name: ARRAY OF CHAR) : Module;
  VAR
    mod: Module;
    imp: Import;
    symbol: Symbol;
    filename: Filename.path;
    modname : Name;
    begad: S.PTR; length: LONGINT;
    sym, type: INTEGER;
    ch: CHAR;
    start, end: S.PTR;
 BEGIN
  name[8] := 0X; Strings.CAPs( name);
  IF (name = "O2INIT") OR (name = "SYS") OR (name = "SYSTEM")
      OR (name = "EMUFPU") OR (name = "EMU030") OR (name = "STORAGE")
      OR (name = "MEMORY") THEN
    RETURN NIL;
  END;
  Filename.SetExt( "MOD", name);
  mod := modules;
  WHILE mod # NIL DO
    IF mod.name = name THEN RETURN mod END;
    mod := mod.next;
  END;
  IF Paths.Get( OCPar.ModPaths, name, {}, filename)
      & File.Load( filename, 0, 1, begad, length) THEN
    IO.WriteString( "Scanning "); IO.WriteString( filename); IO.WriteLn;
    S.PUT( begad + length, 0);    (* mark eof *)
    NEW( mod); mod.next := NIL;
    COPY( name, mod.name);
    mod.start := begad; mod.end := begad + length;
    mod.symbols := NIL; mod.imports := NIL;
    mod.procStart := NIL; mod.procEnd := begad;
    IF lastMod = NIL THEN modules := mod;
    ELSE lastMod.next := mod;
    END;
    lastMod := mod;
    OCScan.Init( begad); OCScan.errorOutput := FALSE;
    OCScan.Get( sym); (* MODULE *)
    OCScan.Get( sym); (* <name> *)
    COPY( OCScan.name, modname);
    OCScan.Get( sym); (* ; *)
    OCScan.Get( sym);
    IF sym = OCScan.import THEN
      OCScan.Get(sym);
      LOOP
        NEW( imp); imp.next := mod.imports; mod.imports := imp;
        COPY(OCScan.name, imp.shortName);
        COPY(OCScan.name, imp.longName);
        OCScan.Get(sym);
        IF sym = OCScan.becomes THEN
          OCScan.Get(sym);
          COPY(OCScan.name, imp.longName);
          OCScan.Get(sym);
        ELSIF sym = OCScan.times THEN
          IO.WriteString( "Unqualified import is not supported. Aborted.");
          IO.WriteLn;
          Task.Exit(-1);
        END ;
        IF sym = OCScan.comma THEN OCScan.Get(sym)
        ELSE EXIT
        END
      END ;
    END;
    LOOP
      IF (sym = OCScan.begin) OR (sym = OCScan.eof) THEN
        EXIT;
      END;
      IF (sym = OCScan.procedure) THEN
        start := OCPar.position - 10;
        OCScan.Get( sym);
        IF (sym # OCScan.minus) & (sym # OCScan.arrow) THEN
          IF (sym = OCScan.times) OR (sym = OCScan.plus) OR (sym = OCScan.not) THEN
            OCScan.Get( sym);
          END;
          type := Proc;
          IF (sym = OCScan.lparen) THEN
            REPEAT
              OCScan.Get( sym);
            UNTIL (sym = OCScan.rparen);
            OCScan.Get( sym);
            type := Tbp;
          END;
          IF sym = OCScan.ident THEN
            NEW(symbol); symbol.next := mod.symbols; mod.symbols := symbol;
            symbol.used := FALSE; symbol.scanned := FALSE;
            symbol.start := start;
            IF mod.procStart = NIL THEN mod.procStart := symbol.start END;
            symbol.type := type;
            COPY( OCScan.name, symbol.name);
            REPEAT
              REPEAT
                OCScan.Get( sym);
(*                IF sym = OCScan.assembler THEN
                  OCScan.inAss := TRUE;
                  REPEAT
                    OCScan.Get( sym);
                  UNTIL sym = OCScan.end;
                  OCScan.inAss := FALSE;
                  OCScan.Get( sym);
                END;*)
              UNTIL sym = OCScan.end;
              OCScan.Get( sym);
            UNTIL (sym = OCScan.ident) & (OCScan.name = symbol.name);
            OCScan.Get( sym); (* ; *)
            end := OCPar.position;
            REPEAT
              S.GET( end, ch);
              INC( end);
            UNTIL (ch > " ");
            symbol.end := end-1;
            mod.procEnd := symbol.end;
          END;
        END;
      END;
      OCScan.Get( sym);
    END;
    OCScan.Exit;
    imp := mod.imports;
    WHILE imp # NIL DO
      imp.module := Scan( imp.longName);
      imp := imp.next;
    END;
    RETURN mod;
  ELSE
    IO.WriteString( name); IO.WriteString( " not found. Aborted."); IO.WriteLn;
    Task.Exit(-1);
  END;
 END Scan;


PROCEDURE Mark;
  VAR
    mod: Module;
    symbol: Symbol;
    completed: BOOLEAN;

  PROCEDURE MarkUsed(module: Module; start, end: S.PTR);
    VAR
      imp: Import;
      mod: Module;
      symbol: Symbol;
      sym: INTEGER;
   BEGIN
    OCScan.Init(start); OCScan.errorOutput := FALSE;
    REPEAT
      OCScan.Get( sym);
      IF (*sym = OCScan.assembler THEN
        OCScan.inAss := TRUE;
      ELSIF (sym = OCScan.end) & OCScan.inAss THEN
        OCScan.inAss := FALSE;
      ELSIF*) sym = OCScan.ident THEN
        symbol := module.symbols;
        WHILE symbol # NIL DO
          IF (symbol.type = Proc) & (symbol.name = OCScan.name) THEN
            symbol.used := TRUE
          END;
          symbol := symbol.next;
        END;
        imp := module.imports;
        LOOP
          IF imp = NIL THEN EXIT END;
          IF (imp.module # NIL) & (imp.shortName = OCScan.name) THEN
            OCScan.Get(sym);
            IF sym = OCScan.period THEN
              OCScan.Get( sym);
              IF sym = OCScan.ident THEN    (* ident in module *)
                symbol := imp.module.symbols;
                LOOP
                  IF symbol = NIL THEN EXIT END;
                  IF (symbol.type = Proc) & (symbol.name = OCScan.name) THEN
                    symbol.used := TRUE;
                    EXIT;
                  END;
                  symbol := symbol.next;
                END;
              END;
            END;
            EXIT
          END;
          imp := imp.next;
        END;
      ELSIF sym = OCScan.period THEN
        OCScan.Get(sym);
        IF sym = OCScan.ident THEN  (* mark all Tbps with that name *)
          mod := modules;
          WHILE mod # NIL DO
            symbol := mod.symbols;
            WHILE symbol # NIL DO
              IF (symbol.type = Tbp) & (symbol.name = OCScan.name) THEN
                symbol.used := TRUE
              END;
              symbol := symbol.next;
            END;
            mod := mod.next;
          END;
        END;
      END;
    UNTIL OCPar.position >= end;
    OCScan.Exit;
   END MarkUsed;

 BEGIN
  mod := modules;
  WHILE mod # NIL DO
    MarkUsed( mod, mod.procEnd, mod.end);
    mod := mod.next;
  END;
  REPEAT
    mod := modules;
    completed := TRUE;
    WHILE mod # NIL DO
      symbol := mod.symbols;
      WHILE symbol # NIL DO
        IF symbol.used & ~symbol.scanned THEN
          completed := FALSE;
          symbol.scanned := TRUE;
          MarkUsed( mod, symbol.start, symbol.end);
        END;
        symbol := symbol.next;
      END;
      mod := mod.next;
    END;
  UNTIL completed;
 END Mark;


PROCEDURE Save;
  VAR
    mod: Module;
    filename: Filename.path;
    handle: INTEGER;
    count: LONGINT;
    symbol: Symbol;

  PROCEDURE Write( count: LONGINT; addr: S.PTR);
   BEGIN
    IF ~File.Write( handle, count, addr) THEN
      IO.WriteString( "Error while writing "); IO.WriteString( filename);
      IO.WriteLn; Task.Exit(-1);
    END;
   END Write;

 BEGIN
  mod := modules;
  WHILE mod # NIL DO
    COPY( destination, filename);
    Strings.Append( mod.name, filename);
    IF File.Create( filename, {}, handle) THEN
      IO.WriteString( "Saving "); IO.WriteString( filename); IO.WriteLn;
      IF mod.procStart = NIL THEN
        Write( mod.end - mod.start, mod.start);
      ELSE
        Write( mod.procStart - mod.start, mod.start);
        symbol := mod.symbols;
        WHILE symbol # NIL DO
          IF symbol.used THEN
            Write( symbol.end - symbol.start, symbol.start);
          END;
          symbol := symbol.next;
        END;
        Write( mod.end - mod.procEnd, mod.procEnd);
      END;
      File.Close(handle);
    ELSE
      IO.WriteString( "Could not open for writing: ");
      IO.WriteString( filename); IO.WriteLn;
      Task.Exit(-1);
    END;
    mod := mod.next;
  END;
 END Save;


PROCEDURE ReadOptions(VAR string: ARRAY OF CHAR) : BOOLEAN;
 (*
  * reads options from string and returns true if it contained options.
  *)
  VAR
    i : INTEGER;

  PROCEDURE Error(opt : CHAR);
   BEGIN
    IO.WriteString("Unknown option '"); IO.WriteChar(opt);
    IO.WriteString("'. Aborted."); IO.WriteLn;
    Task.Exit(0);
   END Error;
(*
  PROCEDURE ReadNumber(VAR string: ARRAY OF CHAR; VAR i, num : INTEGER);
   BEGIN
    INC(i);
    num := 0;
    WHILE (string[i] >= "0") AND (string[i] <= "9") DO
      num := num * 10 + ORD( string[i]) - 30H;
      INC( i);
    END(*WHILE*);
    DEC(i);
   END ReadNumber;
*)
  PROCEDURE ReadString(VAR string: ARRAY OF CHAR; VAR i : INTEGER;
                       VAR read : ARRAY OF CHAR);
    VAR
      j : INTEGER;
   BEGIN
    INC(i);
    j := 0;
    WHILE (string[i] # 0X) AND (string[i] # "+") AND (string[i] # "-")
          & (string[i] # " ") DO
      read[j] := string[i];
      INC( i); INC( j);
    END(*WHILE*);
    DEC(i);
    read[j] := 0X;
   END ReadString;

 BEGIN
  i := 0;
  LOOP
    IF string[i] = "-" THEN	(* switch off or set variable *)
      LOOP
        INC( i);
        CASE CAP(string[i]) OF
          "D":
            ReadString(string, i, destination);
            IF destination[ Strings.Length(destination)-1 ] # "\" THEN
              Strings.AppendC( "\", destination);
            END;
        | "+", " ", 0X:
            EXIT
        | "-":
        ELSE
          Error(string[i]);
        END(*CASE*);
      END(*LOOP*);
    ELSIF string[i] = "+" THEN	(* switch on *)
      LOOP
        INC( i);
        CASE CAP(string[i]) OF
          "-", " ", 0X:
            EXIT
        | "+":
        ELSE
          Error(string[i]);
        END(*CASE*);
      END(*LOOP*);
    ELSE
      EXIT
    END(*IF*);
  END(*LOOP*);
  RETURN i # 0;
 END ReadOptions;


PROCEDURE Options(ptr: S.PTR);
 BEGIN
 END Options;


PROCEDURE Init;
  VAR
    s: ARRAY 200 OF CHAR;
 BEGIN
  OCPar.Init;
  OCScan.Options := Options;
  modules := NIL; lastMod := NIL;
  destination := "D:\";
  (* read standard options from environment *)
  IF Env.ReadStr("OPOPT", s) AND NOT ReadOptions(s) THEN
    IO.WriteString("Env. var. OPOPT has no valid options. Aborted."); IO.WriteLn;
    Task.Exit(0);
  END(*IF*);
 END Init;


PROCEDURE Exit;
 BEGIN
  OCPar.Exit;
  modules := NIL; lastMod := NIL;
 END Exit;


PROCEDURE Run*;
  VAR
    mod: Module;
 BEGIN
  Exit;
  Task.Init;
  IO.WriteString("Oberon optimizer V2.00  (c) Stephan Junker  ");
  IO.WriteString( Sys.compDate); IO.WriteLn;
  IF CommandLine.arg # NIL THEN
    Init;
    WHILE (CommandLine.arg # NIL) AND ReadOptions(CommandLine.arg^) DO
      CommandLine.Next()
    END(*WHILE*);
    IF CommandLine.arg # NIL THEN
      OCPar.ReadPaths;
      mod := Scan(CommandLine.arg^);
      Mark; Save;
    ELSE
      IO.WriteString("No module name found"); IO.WriteLn;
    END;
    Exit;
  ELSE
    IO.WriteString( "Usage: Optimize [options] <module>"); IO.WriteLn;
    IO.WriteString( "Options: -d<path>  set destination path"); IO.WriteLn;
    IO.WriteString( "All options can be defined using env. var. OPOPT"); IO.WriteLn;
  END;
  Task.Exit(-1);
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END Optimizer.