MODULE Filename; (* Stephan Junker  10.1.93 / 18.1.94 *)


(*
 * Filename is designed to divide file names into their components (i.e.
 * path, name and extension) and to merge those components to a file name.
 * It works with slashes (/) as well as with backslashes (\).
 * A path is the part of a file name from the start to the last slash or
 * backslash, inclusively. A name is the name of a file with its extension
 * (if it has one). The extension is the part of a file name after the last
 * point. If there is no point or a slash or backslash appears after the
 * last point, then there is no extension.
 *)


IMPORT
  Str:=Strings;


 CONST
   PathLen* = 256; (* lengths of types *)
   NameLen* = 40;
   ExtLen*  = 10;


 TYPE
   path*    = ARRAY PathLen OF CHAR;
   name*    = ARRAY NameLen OF CHAR;
   ext*     = ARRAY ExtLen OF CHAR;


PROCEDURE SetExt* (Ext : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
  (*
   * set new extension Ext in FullName.
   *)
  VAR i,j : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName);
  j := Str.LPosC("/",FullName);
  IF i < j THEN i := j END;
  j := Str.LPosC(".",FullName);
  IF j > i THEN FullName[j+1] := 0X
  ELSE Str.AppendC(".",FullName) END(*IF*);
  Str.Append(Ext,FullName);
 END SetExt;


PROCEDURE GetExt* (VAR FullName,Ext : ARRAY OF CHAR);
  (*
   * return extension of FullName in Ext.
   *)
  VAR i,j : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName);
  j := Str.LPosC("/",FullName);
  IF i < j THEN i := j END;
  j := Str.LPosC(".",FullName);
  IF j > i THEN Str.Excerpt(j + 1,j + 4,FullName,Ext)
  ELSE Ext[0] := 0X END(*IF*);
 END GetExt;


PROCEDURE SetName* (Name : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
  (*
   * set new name Name (with extension) in FullName.
   *)
  VAR i : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName) + 1;
  IF i = 0 THEN
    i := Str.LPosC("/",FullName) + 1;
  END;
  FullName[i] := 0X;
  Str.Append(Name,FullName);
 END SetName;


PROCEDURE GetName* (VAR FullName,Name : ARRAY OF CHAR);
  (*
   * return name (with extension) of FullName in Name.
   *)
  VAR i : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName) + 1;
  IF i = 0 THEN
    i := Str.LPosC("/",FullName) + 1;
  END;
  Str.Excerpt(i,i + 12,FullName,Name);
 END GetName;


PROCEDURE SetPath* (Path : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
  (*
   * set new path Path (with drive) in FullName.
   *)
  VAR Name : name;
 BEGIN
  GetName(FullName,Name);
  COPY(Path,FullName);
  SetName(Name,FullName);
 END SetPath;


PROCEDURE GetPath* (VAR FullName,Path : ARRAY OF CHAR);
  (*
   * return path (with drive) of FullName in Path.
   *)
  VAR
    i : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName) + 1;
  IF i = 0 THEN
    i := Str.LPosC("/",FullName) + 1;
  END;
  Str.Excerpt(0,i,FullName,Path);
 END GetPath;


END Filename.
