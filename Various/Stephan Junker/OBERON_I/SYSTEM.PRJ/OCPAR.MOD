MODULE OCPar; (* SJ  10.3.94 *)


IMPORT
  S:=SYSTEM, Env:=Environment, Paths, IO, Task;


VAR
  (* parameters *)
  ErrDist*,MaxErr* : INTEGER;
  ErrorFormat*, statProc* : ARRAY 50 OF CHAR;
  inxchk*,typchk*,arichk*,stkchk*, WarningsOut*, copyDyn* : BOOLEAN;
  SymPaths*,ObjPaths*,ModPaths*,InfPaths* : Paths.path;
  fpu*,xcode* : BOOLEAN;	(* use FPU / 68030 commands *)
  ext* : BOOLEAN;		(* allow extensions *)
  reass*,dis*,ass*,opt*,sym*, highOpt* : BOOLEAN;
  dbInfo*, procCom*, shorten*, ccode* : BOOLEAN;
  objExt* : ARRAY 4 OF CHAR;
  display* : ARRAY 10 OF BOOLEAN;
  process* : ARRAY 10 OF BOOLEAN;
  rsvdTBPs* : INTEGER;

  (* other basic variables *)
  source*, position* : S.PTR;

  debug* : BOOLEAN;	(* should be constant *)

  calledAsModule* : BOOLEAN;

  mpVar, opVar, spVar, ipVar : ARRAY 20 OF CHAR;

  parichk, pinxchk, pstkchk, popt, ptypchk, pWarningsOut: BOOLEAN;

(*
 * new options definition (capital ignored):
 * Notation | Meaning                                       | Default value
 * ------------------------------------------------------------------------
 *  +/-A    | Arithmetic check on / off                     | +
 *  +/-I    | Index check on / off                          | +
 *  +/-T    | Type check on / off                           | +
 *  +/-K    | stacK check on / off                          | +
 *  +/-3    | 68030 code on / off                           | -
 *  +/-F    | Fpu code on / off                             | -
 *  +/-R    | Reassemble on / off                           | -
 *  +/-P    | oPtimize on / off                             | +
 *  +/-X    | language eXtensions on / off                  | -
 *  +/-W    | warning output on / off                       | -
 *  +/-C    | Compiler Code on / off                        | +
 *  +/-Y    | copY dYnamic array on / off                   | +
 *  +/-H    | Highest optimization on /off                  | -
 *  +J<proc>| Jump to proc after every statement            | -
 *  -J      | Do not Jump after every statement             | -
 *  -E<ext> | set Extension to ext                          | OBJ
 *  -N<num> | set Number of reserved TBP entries to num     | 10
 *  -D<num> | set Distance between errors to num            | 20
 *  -U<num> | set maximUm number of errors to num           | 100
 *  -M<var> | read module path from env. variable var       | MODPATH
 *  -O<var> | read object path from env. variable var       | OBJPATH
 *  -S<var> | read symbol path from env. variable var       | SYMPATH
 *
 *  +/-G?   | display? true / false                         | -
 *  +/-Q?   | process? true / false                         | +
 *  +/-B    | debug on / off                                | -
 *)


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
          "A":
            parichk := arichk; arichk := FALSE
        | "B":
            debug := FALSE
        | "C":
            ccode := FALSE
        | "D":
            ReadNumber(string, i, ErrDist);
        | "E":
            ReadString(string, i, objExt);
        | "F":
            fpu := FALSE
        | "G":
            INC(i);
            display[ ORD( string[i]) - 30H] := FALSE;
        | "H":
            highOpt := FALSE
        | "I":
            pinxchk := inxchk; inxchk := FALSE
        | "J":
            statProc := "";
        | "K":
            pstkchk := stkchk; stkchk := FALSE
        | "M":
            ReadString(string, i, mpVar);
        | "N":
            ReadNumber(string, i, rsvdTBPs);
        | "O":
            ReadString(string, i, opVar);
        | "P":
            popt := opt; opt := FALSE
        | "Q":
            INC(i);
            process[ ORD( string[i]) - 30H] := FALSE;
        | "R":
            ass := dis;
            reass := FALSE
        | "S":
            ReadString(string, i, spVar);
        | "T":
            ptypchk := typchk; typchk := FALSE
        | "U":
            ReadNumber(string, i, MaxErr);
        | "W":
            pWarningsOut := WarningsOut; WarningsOut := FALSE
        | "X":
            ext := FALSE
        | "Y":
            copyDyn := FALSE
        | "3":
            xcode := FALSE
        | "+", "=", " ", 0X:
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
            parichk := arichk; arichk := TRUE
        | "B":
            debug := TRUE
        | "C":
            ccode := TRUE
        | "F":
            fpu := TRUE
        | "G":
            INC(i);
            display[ ORD( string[i]) - 30H] := TRUE;
        | "H":
            highOpt := TRUE
        | "I":
            pinxchk := inxchk; inxchk := TRUE
        | "J":
            ReadString(string, i, statProc);
        | "K":
            pstkchk := stkchk; stkchk := TRUE
        | "P":
            popt := opt; opt := TRUE
        | "Q":
            INC(i);
            process[ ORD( string[i]) - 30H] := TRUE;
        | "R":
            ass := TRUE;
            reass := TRUE
        | "T":
            ptypchk := typchk; typchk := TRUE
        | "W":
            pWarningsOut := WarningsOut; WarningsOut := TRUE
        | "X":
            ext := TRUE
        | "Y":
            copyDyn := TRUE
        | "3":
            xcode := TRUE
        | "-", "=", " ", 0X:
            EXIT
        | "+":
        ELSE
          Error(string[i]);
        END(*CASE*);
      END(*LOOP*);
    ELSIF string[i] = "=" THEN	(* restore *)
      LOOP
        INC( i);
        CASE CAP(string[i]) OF
          "A":
            arichk := parichk;
        | "I":
            inxchk := pinxchk
        | "K":
            stkchk := pstkchk
        | "P":
            opt := popt
        | "T":
            typchk := ptypchk
        | "W":
            WarningsOut := pWarningsOut
        | "-", "+", " ", 0X:
            EXIT
        | "=":
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
  Paths.Read( spVar, SymPaths);
  Paths.Read( opVar, ObjPaths);
  Paths.Read( ipVar, InfPaths);
  IF ModPaths = NIL THEN
    NEW( ModPaths); ModPaths.Next := NIL; ModPaths.Path := ".\";
  END;
  IF SymPaths = NIL THEN SymPaths := ModPaths END;
  IF ObjPaths = NIL THEN ObjPaths := ModPaths END;
  IF InfPaths = NIL THEN InfPaths := ModPaths END;
 END ReadPaths;


PROCEDURE Init*;
  VAR
    s : ARRAY 200 OF CHAR;
    i : INTEGER;
 BEGIN
  (* set default values *)
  ErrDist := 20; MaxErr := 100;
  IF NOT Env.ReadStr("ERRFORM",ErrorFormat) THEN
    ErrorFormat := "Error \d \z, \s: \f";
  END;
  statProc := "";
  dbInfo := FALSE;
  inxchk := TRUE;
  typchk := TRUE;
  arichk := TRUE;
  stkchk := TRUE;
  copyDyn := TRUE;
  WarningsOut := TRUE;
  mpVar := "MODPATH";
  opVar := "OBJPATH";
  spVar := "SYMPATH";
  ipVar := "INFPATH";
  objExt := "OBJ";
  fpu := FALSE;
  xcode := FALSE;
  ext := FALSE;
  reass := FALSE;
  dis := FALSE;
  ass := FALSE;
  opt := TRUE;
  highOpt := TRUE;
  ccode := TRUE;
  rsvdTBPs := 10;
  debug := FALSE;	(* later const *)
  procCom := TRUE; shorten := TRUE;
  calledAsModule := FALSE;
  FOR i := 0 TO 9 DO process[i] := TRUE END;
  FOR i := 0 TO 9 DO display[i] := FALSE END;

  (* read standard options from environment *)
  IF Env.ReadStr("OCOPT", s) AND NOT ReadOptions(s) THEN
    IO.WriteString("Env. variable OCOPT has no valid options. Aborted."); IO.WriteLn;
    Task.Exit(0);
  END(*IF*);
 END Init;


PROCEDURE Exit*;
 BEGIN
  SymPaths := NIL; ObjPaths := NIL;
  ModPaths := NIL; InfPaths := NIL;
 END Exit;


END OCPar.