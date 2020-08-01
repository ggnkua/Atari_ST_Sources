MODULE OLPar; (* SJ 21.8.94 *)


IMPORT
  FN:=Filename, Paths, Env:=Environment, Task, IO;


(*
 * new options definition (capital ignored):
 * Notation | Meaning                                       | Default value
 * ------------------------------------------------------------------------
 *  +/-T    | symbol Table on / off                         | +
 *  +/-Y    | extended sYmbol table on / off                | +
 *  +/-P    | oPtimize on / off                             | -
 *  +/-A    | absolute symbol table on / off                | +
 *  -E<ext> | set object Extension to ext                   | OBJ
 *  -D<path>| set program destination to path               | same as module
 *  -N<name>| set program name to name (no ext)             | same as module
 *  -X<ext> | set program eXtension to ext                  | PRG
 *  -S<num> | set Stack size to num                         | 30000
 *  -M<var> | read module path from env. variable var       | MODPATH
 *  -O<var> | read object path from env. variable var       | OBJPATH
 *  -L<var> | read info path from env. variable var         | INFPATH
 *)


VAR
  StackSize* : LONGINT;
  SymbolTable*,ExtendedSymtab* : BOOLEAN;
  PrgExt*,objExt* : ARRAY 4 OF CHAR;
  PrgPath*, ProgName* : FN.path;
  DoOptimize*, absSym* : BOOLEAN;
  ObjPaths*,ModPaths*,InfPaths* : Paths.path;

  calledAsModule* : BOOLEAN;

  mpVar, opVar, ipVar : ARRAY 20 OF CHAR;


PROCEDURE ReadOptions*(VAR string: ARRAY OF CHAR) : BOOLEAN;
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

  PROCEDURE ReadNumber(VAR string: ARRAY OF CHAR; VAR i : INTEGER;
                       VAR num : LONGINT);
   BEGIN
    INC(i);
    num := 0;
    WHILE (string[i] >= "0") AND (string[i] <= "9") DO
      num := num * 10 + ORD( string[i]) - 30H;
      INC( i);
    END(*WHILE*);
    DEC(i);
   END ReadNumber;

  PROCEDURE ReadString(VAR string: ARRAY OF CHAR; VAR i : INTEGER;
                       VAR read : ARRAY OF CHAR);
    VAR
      j : INTEGER;
   BEGIN
    INC(i);
    j := 0;
    WHILE (string[i] # 0X) AND (string[i] # "+") AND (string[i] # "-") DO
      read[j] := string[i];
      INC( i); INC( j);
    END(*WHILE*);
    DEC(i);
   END ReadString;

 BEGIN
  i := 0;
  LOOP
    IF string[i] = "-" THEN	(* switch off or set variable *)
      LOOP
        INC( i);
        CASE CAP(string[i]) OF
          "A":
            absSym := FALSE
        | "D":
            ReadString(string, i, PrgPath);
        | "X":
            ReadString(string, i, PrgExt);
        | "N":
            ReadString(string, i, ProgName);
        | "S":
            ReadNumber(string, i, StackSize);
        | "T":
            SymbolTable := FALSE
        | "Y":
            ExtendedSymtab := FALSE
        | "P":
            DoOptimize := FALSE
        | "E":
            ReadString(string, i, objExt);
        | "L":
            ReadString(string, i, ipVar);
        | "M":
            ReadString(string, i, mpVar);
        | "O":
            ReadString(string, i, opVar);
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
          "A":
            absSym := TRUE;
        | "T":
            SymbolTable := TRUE;
        | "Y":
            ExtendedSymtab := TRUE;
        | "P":
            DoOptimize := TRUE;
        | "-", " ", 0X:
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


PROCEDURE ReadPaths*;
 BEGIN
  Paths.Read( mpVar, ModPaths);
  Paths.Read( opVar, ObjPaths);
  Paths.Read( ipVar, InfPaths);
  IF ModPaths = NIL THEN
    NEW( ModPaths); ModPaths.Next := NIL; ModPaths.Path := ".\";
  END;
  IF ObjPaths = NIL THEN ObjPaths := ModPaths END;
  IF InfPaths = NIL THEN InfPaths := ModPaths END;
 END ReadPaths;


PROCEDURE Init*;
  VAR
    s : ARRAY 200 OF CHAR;
 BEGIN
  (* set default values *)
  StackSize := 30000;
  PrgExt := "PRG";
  objExt := "OBJ";
  PrgPath[0] := 0X;
  ProgName[0] := 0X;
  mpVar := "MODPATH";
  opVar := "OBJPATH";
  ipVar := "INFPATH";
  SymbolTable := TRUE;
  ExtendedSymtab := TRUE;
  absSym := TRUE;
  calledAsModule := FALSE;

  (* read standard options from environment *)
  IF Env.ReadStr("OLOPT", s) AND NOT ReadOptions(s) THEN
    IO.WriteString("Env. variable OLOPT has no valid options. Aborted."); IO.WriteLn;
    Task.Exit(0);
  END(*IF*);
 END Init;


END OLPar.