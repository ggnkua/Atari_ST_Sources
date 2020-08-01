MODULE Filename;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |10.1.93  |correction for Oberon
S. Junker  |20.6.93  |length of path to 200 and fullname deleted
----------------------------------------------------------------------------
*)

IMPORT Str:=Strings;

TYPE path*     = ARRAY 200 OF CHAR;
     name*     = ARRAY 14 OF CHAR;
     ext*      = ARRAY 4 OF CHAR;

PROCEDURE SetExt* (Ext : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
 (* set new extension in FullName *)
  VAR i,j : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName);
  j := Str.LPosC(".",FullName);
  IF j > i THEN FullName[j+1] := 0X
  ELSE Str.AppendC(".",FullName) END(*IF*);
  Str.Append(Ext,FullName);
 END SetExt;

PROCEDURE GetExt* (VAR FullName,Ext : ARRAY OF CHAR);
 (* get extension in FullName *)
  VAR i,j : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName);
  j := Str.LPosC(".",FullName);
  IF j > i THEN Str.Excerpt(j + 1,j + 4,FullName,Ext)
  ELSE Ext[0] := 0X END(*IF*);
 END GetExt;

PROCEDURE SetName* (Name : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
 (* set new name (with extension) in FullName *)
  VAR i : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName) + 1;
  FullName[i] := 0X;
  Str.Append(Name,FullName);
 END SetName;

PROCEDURE GetName* (VAR FullName,Name : ARRAY OF CHAR);
 (* get name (with extension) in FullName *)
  VAR i : INTEGER;
 BEGIN
  i := Str.LPosC("\",FullName) + 1;
  Str.Excerpt(i,i + 12,FullName,Name);
 END GetName;

PROCEDURE SetPath* (Path : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
 (* set new path (with drive) in FullName *)
  VAR Name : name;
 BEGIN
  GetName(FullName,Name);
  COPY(Path,FullName);
  SetName(Name,FullName);
 END SetPath;

PROCEDURE GetPath* (VAR FullName,Path : ARRAY OF CHAR);
 (* get path (with drive) in FullName *)
 BEGIN
  Str.Excerpt(0,Str.LPosC("\",FullName) + 1,FullName,Path);
 END GetPath;

END Filename.
