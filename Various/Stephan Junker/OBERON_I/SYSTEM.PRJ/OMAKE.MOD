MODULE OMake; (* SJ 22.4.93 *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |18.4.93  |started
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Task, FN:=Filename, Str:=Strings, OCS:=Make2Parse,
       NStr:= NumStr, Paths, File, DCL, IO, GEMDOS, Sys,
       Error, Env:=Environment, CL:=CommandLine, ObnEnv,
       OComp, OLink, OCPar, GC;

CONST
  (*symbol values*)
   times = 1; slash = 2; div = 3; mod = 4;
   and = 5; plus = 6; minus = 7; or = 8; eql = 9;
   neq = 10; lss = 11; leq = 12; gtr = 13; geq = 14;
   in = 15; is = 16; arrow = 17; period = 18; comma = 19;
   colon = 20; upto = 21; rparen = 22; rbrak = 23; rbrace = 24;
   of = 25; then = 26; do = 27; to = 28; lparen = 29;
   lbrak = 30; lbrace = 31; not = 32; becomes = 33; number = 34;
   nil = 35; string = 36; ident = 37; semicolon = 38; bar = 39;
   end = 40; else = 41; elsif = 42; until = 43; if = 44;
   case = 45; while = 46; repeat = 47; loop = 48; with = 49;
   exit = 50; return = 51; array = 52; record = 53; pointer = 54;
   begin = 55; const = 56; type = 57; var = 58; procedure = 59;
   import = 60; module = 61;

TYPE file     = POINTER TO filedesc;
     filedesc = RECORD(DCL.Element)
                  Name : FN.path;
                  Imports : DCL.List;
                END;

VAR
  sym : INTEGER;
  FileList : DCL.List; (* all files which are up to date *)
  ImportList : DCL.List; (* all files which are analyzed *)
  MakePaths : Paths.path;
  compPar : FN.path;
  compParPos: INTEGER;
  mpVar, mkpVar : ARRAY 20 OF CHAR;
  linkAfterwards: BOOLEAN;


PROCEDURE CheckSym(s: INTEGER);
 BEGIN
  IF sym = s THEN OCS.Get(sym) ELSE OCS.Mark(s) END
 END CheckSym;

PROCEDURE SearchFile(FileList : DCL.List; VAR Name : ARRAY OF CHAR;
                     VAR File : file) : BOOLEAN;
  (* returns TRUE if the file Name is in the FileList *)
  VAR f : file;
 BEGIN
  f := FileList.root;
  WHILE f # NIL DO
    IF f.Name = Name THEN File := f; RETURN TRUE END;
    f := f.next;
  END;
  RETURN FALSE
 END SearchFile;

PROCEDURE ModDate(VAR Name : ARRAY OF CHAR; paths: Paths.path) : LONGINT;
  (* reads the time and date of saving of the source file. *)
  VAR
    Handle : INTEGER;
    Datime : File.datime;
    name: FN.path;
 BEGIN
  COPY(Name, name);
  IF Paths.Get( paths, name, {}, name) & File.Open(name,File.read,Handle) THEN
    File.Datime(Handle,Datime,0); File.Close(Handle);
    RETURN S.ANL(LONG(Datime.Time),0FFFFH) + Datime.Date * 10000H;
  END;
  RETURN 0
 END ModDate;

PROCEDURE ObjDate(Name : ARRAY OF CHAR) : LONGINT;
  (* reads the time and date of saving of the object file. If there is no object
     file, 0 is returned which specifies a very old file *)
 BEGIN
  FN.SetExt("OBJ",Name); RETURN ModDate(Name, OCPar.ObjPaths);
 END ObjDate;

PROCEDURE SymDate(Name : ARRAY OF CHAR) : LONGINT;
  (* reads the time and date of saving of the symbol file. If there is no symbol
     file, 0 is returned which specifies a very old file *)
 BEGIN
  FN.SetExt("SYM",Name); RETURN ModDate(Name, OCPar.SymPaths);
 END SymDate;

PROCEDURE CompilationNeeded(VAR Name : ARRAY OF CHAR; Imports : DCL.List) : BOOLEAN;
  (* returns TRUE if the file Name needs to be compiled. Compilation is needed if
     the source file is newer than the object file or if an imported file has
     a newer symbol file than the object file. *)
  VAR ObDate : LONGINT;
      f : file;
 BEGIN
  IF NOT SearchFile(FileList,Name,f) THEN
    IO.WriteString("Testing "); IO.WriteString(Name); IO.WriteString(" : ");
    ObDate := ObjDate(Name);
    IF ObDate < ModDate(Name, MakePaths) THEN
      IO.WriteString("Yes, obj older than source"); IO.WriteLn;
      RETURN TRUE
    END;
    f := Imports.root;
    WHILE f # NIL DO
      IF ObDate < SymDate(f.Name) THEN
        IO.WriteString("Yes, obj older than sym of import"); IO.WriteLn;
        RETURN TRUE
      END;
      f := f.next;
    END;
    IO.WriteString("No"); IO.WriteLn;
  END;
  RETURN FALSE;
 END CompilationNeeded;

PROCEDURE ToImport() : BOOLEAN;
  (* sets the source pointer in OCS to the start of the import list.
     Returns FALSE if a syntax error occurs *)
 BEGIN
  OCS.Get(sym);
  IF sym = module THEN OCS.Get(sym) ELSE OCS.Mark(16) END ;
  IF sym = ident THEN
   OCS.Get(sym); CheckSym(semicolon);
   IF sym = import THEN OCS.Get(sym); RETURN NOT OCS.scanerr END;
  ELSE OCS.Mark(10)
  END;
  RETURN FALSE
 END ToImport;

PROCEDURE ReadImports(VAR Name : ARRAY OF CHAR; VAR Files : DCL.List);
  (* reads the imported file of source file Name which need to be compiled into a
     list. Returns NIL if there are no such imports. CompNeeded is TRUE, if one
     symbol file of an imported file is newer than the object file *)
  VAR f : file;
      Begad: S.PTR;
      Length : LONGINT;
 BEGIN
  IF SearchFile(ImportList,Name,f) THEN
    (* Files := f.Imports *)
    Files := NIL;
  ELSIF File.Load(Name,0,0,Begad,Length) THEN
    NEW(Files); Files.Init; OCS.Init(Begad,0,Name);
    IF ToImport() THEN
      LOOP
        IF sym = ident THEN OCS.Get(sym);
          IF sym = becomes THEN OCS.Get(sym);
            IF sym = ident THEN OCS.Get(sym)
            ELSE OCS.Mark(10)
            END
          END ;
        ELSE OCS.Mark(10)
        END ;
        IF OCS.scanerr THEN EXIT END;
        NEW(f); Files.Add(f); COPY(OCS.name,f.Name);
        f.Name[8] := 0X; Str.Append(".MOD",f.Name); Str.CAPs(f.Name);
        IF sym = comma THEN OCS.Get(sym) ELSE EXIT END
      END ;
    END;
    OCS.Close;
    NEW(f); ImportList.Add(f); COPY(Name,f.Name); f.Imports := Files;
    S.DISPOSE(Begad);
  END;
 END ReadImports;


PROCEDURE SetParameter(VAR par: ARRAY OF CHAR);
 BEGIN
  COPY( par, Sys.Basepage.Command);
  Sys.Basepage.ComLen := SHORT( Str.Length(par) );
  CL.Reset;
 END SetParameter;


PROCEDURE CompileImports(VAR Name : ARRAY OF CHAR) : BOOLEAN;
  (* compiles all imports of module Name if needed (recursive). *)
  VAR f : file; Files : DCL.List;
    s: FN.path;
 BEGIN
  IF Paths.Get(MakePaths, Name,{},Name) THEN
    IF SearchFile(FileList,Name,f) THEN RETURN TRUE END;
    ReadImports(Name,Files);
    IF Files = NIL THEN RETURN TRUE END;
    IF OCS.scanerr THEN RETURN FALSE END;
    f := Files.root;
    WHILE f # NIL DO
      IF NOT CompileImports(f.Name) THEN RETURN FALSE END;
      f := f.next;
    END;
    IF CompilationNeeded(Name,Files) THEN
      compPar[compParPos] := 0X;
      Str.Append(Name, compPar);
      SetParameter(compPar);
      OComp.Compile;
      GC.Collect;
      RETURN Task.retCode = 0;
    END;
  END;
  NEW(f); FileList.Add(f); COPY(Name,f.Name);
  RETURN TRUE
 END CompileImports;


PROCEDURE MakeAll() : BOOLEAN;
  (* compiles all files in the search paths if needed *)
  VAR Path,Name : ARRAY 60 OF CHAR; path : Paths.path;
      Dta : File.dtarec;
 BEGIN
  path := MakePaths;
  WHILE path # NIL DO
    COPY(path.Path,Path);
    Str.Append("*.MOD",Path);
    File.Setdta(S.ADR(Dta));
    IF File.Sfirst(Path,{}) THEN
      REPEAT
        COPY(Path,Name); FN.SetName(Dta.Name,Name);
        File.Setdta(S.ADR(File.Dta));
        IF NOT CompileImports(Name) THEN RETURN FALSE END;
        File.Setdta(S.ADR(Dta));
      UNTIL NOT File.Snext();
    END;
    File.Setdta(S.ADR(File.Dta)); path := path.Next
  END;
  RETURN TRUE
 END MakeAll;


PROCEDURE MakeProject(File : ARRAY OF CHAR) : BOOLEAN;
  (* compiles all files used in a project if needed *)
  VAR
    fileName : ARRAY 100 OF CHAR;
 BEGIN
  COPY(File, fileName);
  FN.SetExt("MOD",fileName);
  IF CompileImports(fileName) THEN
    IF linkAfterwards THEN
      SetParameter(File);
      OLink.Link;
      RETURN Task.retCode = 0;
    END;
    RETURN TRUE
  END;
  RETURN FALSE;
 END MakeProject;


PROCEDURE CommandLine() : INTEGER;
  (* searches the command line for an argument and does the desired
     work. If no argument is found, FALSE is returned *)
 BEGIN
  IF (CL.arg = NIL) AND NOT MakeAll() OR
     (CL.arg # NIL) AND NOT MakeProject(CL.arg^) THEN
    IO.WriteString("Make aborted"); IO.WriteLn;
    RETURN -1;
  END;
  IO.WriteString("Make completed"); IO.WriteLn;
  RETURN 0;
 END CommandLine;


PROCEDURE ReadOptions;
  VAR
    i : INTEGER;

  PROCEDURE Error(opt : CHAR);
   BEGIN
    IO.WriteString("Unknown option '"); IO.WriteChar(opt);
    IO.WriteString("'. Aborted."); IO.WriteLn;
    Task.Exit(0);
   END Error;

  PROCEDURE ReadString(VAR string: ARRAY OF CHAR; VAR i : INTEGER;
                       VAR read : ARRAY OF CHAR);
    VAR
      j : INTEGER;
   BEGIN
    INC(i);
    j := 0;
    WHILE (string[i] # 0X) & (string[i] # " ") DO
      read[j] := string[i];
      INC( i); INC( j);
    END(*WHILE*);
    DEC(i);
   END ReadString;

 BEGIN
  compPar := ""; mpVar := "MODPATH"; mkpVar := "MAKEPATH";
  linkAfterwards := FALSE;
  i := 0;
  LOOP
    IF CL.arg = NIL THEN EXIT END;
    IF CL.arg[i] = "-" THEN	(* set variable *)
      LOOP
        INC( i);
        CASE CAP(CL.arg[i]) OF
          "K":
            ReadString(CL.arg^, i, mkpVar);
        | "M":
            ReadString(CL.arg^, i, mpVar);
        | "P":
            ReadString(CL.arg^, i, compPar);
        | "L":
            linkAfterwards := TRUE;
        | 0X:
            EXIT
        | "-":
        ELSE
          Error(CL.arg[i]);
        END(*CASE*);
      END(*LOOP*);
      CL.Next;
    ELSE
      EXIT
    END(*IF*);
  END(*LOOP*);
  Paths.Read(mkpVar, MakePaths);
  IF MakePaths = NIL THEN
    Paths.Read(mpVar, MakePaths);
  END;
  compParPos := Str.Length(compPar);
 END ReadOptions;


PROCEDURE Make*;
  VAR
    ret: INTEGER;
 BEGIN
  IO.WriteString("Oberon Make  V2.03  (c) Stephan Junker  ");
  IO.WriteString( Sys.compDate); IO.WriteLn;
  NEW(FileList); FileList.Init;
  NEW(ImportList); ImportList.Init;
  ReadOptions;
  OCPar.Init;
  OCPar.ReadPaths;
  ret := CommandLine();
  OCPar.Exit;
  FileList := NIL;
  ImportList := NIL;
  MakePaths := NIL;
  Task.Exit(ret);
 END Make;


END OMake.

