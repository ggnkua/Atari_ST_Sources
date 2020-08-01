MODULE OLDPar; (* SJ 15.11.94 *)


IMPORT
  Env:=Environment, Paths, IO, GEMDOS, FN:=Filename;



VAR
  objPaths* : Paths.path;
  objExt* : FN.ext;
  opVar: ARRAY 20 OF CHAR;



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
    GEMDOS.Pterm0();
   END Error;

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
    IF string[i] = "-" THEN	(* set variable *)
      LOOP
        INC( i);
        CASE CAP(string[i]) OF
          "E":
            ReadString(string, i, objExt);
        | "O":
            ReadString(string, i, opVar);
        | " ", 0X:
            EXIT
        | "-":
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


PROCEDURE Init*;
  VAR
    s : ARRAY 200 OF CHAR;
 BEGIN
  (* set default values *)
  objExt := "OBJ";
  opVar := "LOADPATH";

  (* read standard options from environment *)
  IF Env.ReadStr("OLDOPT", s) AND NOT ReadOptions(s) THEN
    IO.WriteString("Env. variable OLDOPT has no valid options. Aborted.");
    IO.WriteLn;
    GEMDOS.Pterm0;
  END(*IF*);
  Paths.Read( opVar, objPaths);
 END Init;


END OLDPar.