MODULE Paths;

(* general information :
   The search paths are read from the environment. Different paths are
   separated by a comma or a semicolon.
*)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |10.1.93  |correction for Oberon
S. Junker  |21.4.93  |read paths from environment
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Str:=Strings, FN:=Filename, File, GEMDOS, Error,
       Env:=Environment;

CONST
  numpaths = 10;


TYPE path*     = POINTER TO pathdesc;
     pathdesc* = RECORD
                   Next* : path;
                   Path* : FN.path;
                 END;


PROCEDURE Get*(Paths : path; Name : ARRAY OF CHAR; Attribs : SET;
               VAR FullName : ARRAY OF CHAR) : BOOLEAN;
 (* searches the file Name in the current standard directory, then in the
    stored paths. Returns TRUE if found and FullName contains path and name *)
  VAR Drv,i : INTEGER; fn : FN.path; p : path;
 BEGIN
  IF File.Sfirst(Name,Attribs) THEN
    IF Name[1] # ":" THEN
      Drv := GEMDOS.Dgetdrv();
      IF Name[0] = "\" THEN
        FullName[0] := CHR(Drv + 41H); FullName[1] := ":";
        FullName[2] := 0X;
      ELSE
        i := GEMDOS.Dgetpath(0,S.ADR(FullName));
        Str.Insert("A:",0,FullName); FullName[0] := CHR(Drv + 41H);
        Str.AppendC("\",FullName);
      END;
      Str.Append(Name,FullName);
    ELSE COPY(Name, FullName)
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

PROCEDURE Read*(VarName : ARRAY OF CHAR; VAR Paths : path);
  (* Reads the paths defined in the environment under the variable name
     VarName *)
  VAR Def : ARRAY 200 OF CHAR; i,j : INTEGER;
      Path : FN.path;
      paths,p : path;

  PROCEDURE Add(VAR PathDef : ARRAY OF CHAR);
    VAR p : path;
        Path : FN.path;
   BEGIN
    i := 0;
    WHILE (PathDef[i] # 0X) DO
      IF PathDef[i] = "*" THEN
        IF (PathDef[i-1] = "\") AND (PathDef[i+1] = "\") AND (PathDef[i+2] = 0X) THEN
          COPY(PathDef, Path);
          PathDef[i] := 0X; (* for appending *)
          Path[i+1] := 0X; (* for search *)
          IF File.Sfirst(Path, {File.subdir}) THEN
            REPEAT
              IF File.Dta.Name[0] # "." THEN
                COPY(PathDef, Path);
                Str.Append( File.Dta.Name, Path); Str.AppendC("\", Path);
                NEW(p); p.Next := Paths; Paths := p;
                COPY(Path, p.Path);
              END;
            UNTIL NOT File.Snext();
          END;
        ELSE
          Path := "Error in path definition:|";
          Str.Append(PathDef, Path);
          Error.StrOut(Path);
        END;
        RETURN
      END;
      INC(i);
    END;
    NEW(p); p.Next := Paths; Paths := p;
    COPY(PathDef, p.Path);
   END Add;

 BEGIN
  Paths := NIL; File.Setdta( S.ADR(File.Dta) );
  IF Env.ReadStr(VarName,Def) AND (Def[0] # 0X) THEN
    i := 0; j := 0;
    REPEAT
      WHILE (Def[j] # ",") AND (Def[j] # ";") AND (Def[j] # 0X) DO INC(j) END;
      Str.Excerpt(i,j,Def,Path);
      IF Path[0] = "&" THEN
        Str.Delete(0, 1, Path);
        Read(Path, paths);
        IF paths # NIL THEN
          p := paths;
          WHILE p.Next # NIL DO
            p := p.Next;
          END;
          p.Next := Paths;
          Paths := paths;
        END;
      ELSE
        IF Def[j-1] # "\" THEN Str.AppendC( "\", Path) END;
        Add(Path);
      END;
      INC(j); i := j;
    UNTIL Def[j-1] = 0X;
  END;
 END Read;

END Paths.
