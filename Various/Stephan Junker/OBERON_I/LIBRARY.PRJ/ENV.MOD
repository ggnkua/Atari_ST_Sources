MODULE Env; (* SJ 28.2.95 *)

(*
 Manipulation of environment contents
 *)


IMPORT
  S:=SYSTEM, CommandLine, IO, Strings, Sys;


TYPE
  strptr = POINTER TO ARRAY OF CHAR;


VAR
  envSize, usedSize: LONGINT;
  env: strptr;


(*$-i *)

PROCEDURE Copy(size: LONGINT);
  VAR
    src: strptr;
 BEGIN
  IF size = 0 THEN
    src := Sys.Basepage.Env;
    WHILE src[size] # 0X DO
      INC(size);
      IF src[size] = 0X THEN INC(size) END;
    END;
    INC(size);
  ELSE
    src := env
  END;
  envSize := size + 500;
  INC( envSize, envSize MOD 2);
  NEW( env, envSize);
  S.MOVE( src, env, size);
  usedSize := size;
  Sys.Basepage.Env := S.VAL( S.PTR, env);
 END Copy;


PROCEDURE Append*(VAR string: ARRAY OF CHAR);
(*
 Append string to the environment. Let it grow if necessary.
 *)
  VAR
    i, nsize: LONGINT;
    j: INTEGER;
 BEGIN
  nsize := usedSize + Strings.Length(string) + 1;
  WHILE nsize > envSize DO
    Copy(usedSize);
  END;
  i := usedSize-1; j := 0;
  WHILE string[j] # 0X DO
    env[i] := string[j]; INC(i); INC(j);
  END;
  env[i] := 0X; env[i+1] := 0X;
  usedSize := nsize;
 END Append;


PROCEDURE NextVar(VAR i: LONGINT);
 BEGIN
  WHILE env[i] # 0X DO INC(i) END;
  INC(i);
 END NextVar;


PROCEDURE Remove*(VAR name: ARRAY OF CHAR);
(*
 Remove the environment variable named name.
 *)
  VAR
    i, s: LONGINT;
    j: INTEGER;
 BEGIN
  i := 0;
  WHILE env[i] # 0X DO
    j := 0; s := i;
    WHILE env[i] = name[j] DO
      INC(i); INC(j);
    END;
    IF (name[j] = 0X) & ((env[i] = 0X) OR (env[i] = "=")) THEN
      NextVar(i);
      WHILE i < usedSize DO
        env[s] := env[i]; INC(s); INC(i);
      END;
      DEC( usedSize, i - s);
      RETURN ;
    END;
    NextVar(i)
  END;
 END Remove;


PROCEDURE Set*;
(*
 Set environment variable(s)
 *)
  VAR
    i: INTEGER;
 BEGIN
  IF CommandLine.arg # NIL THEN
    i := Strings.FPosC("=", CommandLine.arg^);
    IF i # -1 THEN CommandLine.arg[i] := 0X END;
    Remove(CommandLine.arg^);
    IF i # -1 THEN
      CommandLine.arg[i] := "=";
      Append(CommandLine.arg^);
    END;
  ELSE
    IO.WriteString( "Usage: Env.Set <name>[=[<value>]]"); IO.WriteLn;
  END;
 END Set;


PROCEDURE List*;
(*
 List environment contents
 *)
  VAR
    sp: Strings.ptr;
    i: LONGINT;
 BEGIN
  i := 0;
  WHILE env[i] # 0X DO
    sp := S.ADR( env[i]);
    IO.WriteString( sp^); IO.WriteLn;
    NextVar(i);
  END;
 END List;


BEGIN
  Copy(0)
END Env.