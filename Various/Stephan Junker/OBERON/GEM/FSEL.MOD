MODULE Fsel;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S := SYSTEM,AES,Str := Strings, Appl;

PROCEDURE Input* (VAR Path,Name : ARRAY OF CHAR) : BOOLEAN;
 (* lets the user select a filename using GEM's file selector box *)
  VAR Name2 : ARRAY 14 OF CHAR;
      i : INTEGER;
 BEGIN
  i := Str.LPosC("\",Name) + 1;
  Str.Excerpt(i,Str.Length(Name),Name,Name2);
  AES.AddrIn[0] := S.ADR(Path);
  AES.AddrIn[1] := S.ADR(Name2);
  AES.Call(5A000202H);
  IF AES.IntOut[1] = 1 THEN
    COPY(Path,Name);
    Name[Str.LPosC("\",Name) + 1] := 0X;
    Str.Append(Name2,Name);
  END(*IF*);
  RETURN AES.IntOut[1] = 1;
 END Input;

PROCEDURE ExInput* (VAR Path,Name : ARRAY OF CHAR; Title : ARRAY OF CHAR)
                  : BOOLEAN;
 (* same as Input, but a title can be shown. This feature is only supported
    since TOS 1.4. If ExInput fails, Input is automatically used *)
  VAR Name2 : ARRAY 14 OF CHAR;
      i : INTEGER;
 BEGIN
  i := Str.LPosC("\",Name) + 1;
  Str.Excerpt(i,Str.Length(Name),Name,Name2);
  AES.AddrIn[0] := S.ADR(Path);
  AES.AddrIn[1] := S.ADR(Name2);
  AES.AddrIn[2] := S.ADR(Title);
  AES.Call(5B000203H);
  IF AES.IntOut[0] = 0 THEN RETURN Input(Path,Name) END(*IF*);
  IF AES.IntOut[1] = 1 THEN
    COPY(Path,Name);
    Name[Str.LPosC("\",Name) + 1] := 0X;
    Str.Append(Name2,Name);
  END(*IF*);
  RETURN AES.IntOut[1] = 1;
 END ExInput;

END Fsel.
