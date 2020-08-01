MODULE Paths;

(* general information :
   The search paths are read from the environment. The paths must be ended
   with a backslash so that the file name only needs to be appended.
   Different paths are separated by a comma or a semicolon.
*)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |10.1.93  |correction for Oberon
S. Junker  |21.4.93  |read paths from environment
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Str:=Strings, FN:=Filename, File, Task, GEMDOS,
       Env:=Environment, Storage;

CONST
  numpaths = 10;

TYPE path*     = POINTER TO pathdesc;
     pathdesc* = RECORD
                   Next  : path;
                   Path* : FN.path;
                 END;

VAR Paths : path;
    PrevPaths : ARRAY 20 OF path;

PROCEDURE Get*(Name : ARRAY OF CHAR; Attribs : SET;
               VAR FullName : ARRAY OF CHAR) : BOOLEAN;
 (* searches the file Name in the current standard directory, then in the
    stored paths. Returns TRUE if found and FullName contains path and name *)
  VAR Drv,i : INTEGER; fn : FN.path; p : path;
 BEGIN
  IF File.Sfirst(Name,Attribs) THEN
    IF Name[1] # ":" THEN
      Drv := GEMDOS.Dgetdrv(); i := GEMDOS.Dgetpath(0,S.ADR(FullName));
      Str.Insert("A:",0,FullName); FullName[0] := CHR(Drv + 41H);
      Str.AppendC("\",FullName); Str.Append(Name,FullName);
    END;
    RETURN TRUE
  END(*IF*);
  FN.GetName(Name,Name);
  p := Paths;
  WHILE p # NIL DO
    COPY(p.Path,fn); Str.Append(Name,fn);
    IF File.Sfirst(fn,Attribs) THEN COPY(fn,FullName); RETURN TRUE END ;
    p := p.Next
  END(*WHILE*);
  RETURN FALSE
 END Get;

PROCEDURE Return*(VAR Path : path);
  (* returns the next path. Initiate Path to NIL ! If NIL is returned,
     then there is no next path *)
 BEGIN
  IF Path = NIL THEN Path := Paths
  ELSE Path := Path.Next
  END;
 END Return;

PROCEDURE Read*(VarName : ARRAY OF CHAR);
  (* Reads the paths defined in the environment under the variable name
     VarName *)
  VAR Def : ARRAY 200 OF CHAR; i,j : INTEGER;
      p : path;
 BEGIN
  Paths := NIL;
  IF Env.ReadStr(VarName,Def) THEN i := 0; j := 0;
    REPEAT
      WHILE (Def[j] # ",") AND (Def[j] # ";") AND (Def[j] # 0X) DO INC(j) END;
      S.NEW(p,j-i+5); p.Next := Paths; Paths := p;
      Str.Excerpt(i,j,Def,p.Path); i := j+1; INC(j);
    UNTIL Def[j-1] = 0X;
  END;
 END Read;

PROCEDURE* Init;
 BEGIN
  PrevPaths[Task.Current] := Paths;
 END Init;

PROCEDURE* Exit;
 BEGIN
  Paths := PrevPaths[Task.Current];
 END Exit;

BEGIN
  Task.StoreInit(Init); Task.StoreExit(Exit);
END Paths.
