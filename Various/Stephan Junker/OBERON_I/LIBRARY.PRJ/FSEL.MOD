MODULE Fsel; (* SJ *)


IMPORT
  S:=SYSTEM, AES, Strings, Appl, FN:=Filename, StdPath, GEMDOS;


PROCEDURE AdjustPathAndName(VAR path, name: ARRAY OF CHAR);
  VAR
    s, s2: FN.path;
 BEGIN
  FN.GetName( name, name);
  FN.GetExt( path, s);
  IF s = "" THEN FN.SetExt('*', path) END;
  FN.GetName( path, s);
  IF s[0] = "." THEN
    Strings.InsertC("*", 0, s); FN.SetName(s, path)
  END;
  FN.GetPath( path, s);
  IF s = "" THEN
    FN.SetPath( StdPath.stdPath, path)
  END;
  IF (path[1] # ":") THEN
    COPY( StdPath.stdPath, s2);
    IF path[2] = "\" THEN s2[2] := 0X END;
    Strings.Insert( s2, 0, path)
  END;
 END AdjustPathAndName;


PROCEDURE Input* (VAR Path, Name : ARRAY OF CHAR) : BOOLEAN;
(*
 lets the user select a fileName using GEM's file selector box
 *)
  VAR
    p, n: FN.path;
 BEGIN
  COPY(Path, p); COPY(Name, n);
  AdjustPathAndName(p, n);
  AES.AddrIn[0] := S.ADR(p);
  AES.AddrIn[1] := S.ADR(n);
  AES.Call(5A000202H);
  IF AES.IntOut[1] = 1 THEN
    COPY( p ,Name);
    FN.SetName( n, Name);
  END(*IF*);
  RETURN AES.IntOut[1] = 1;
 END Input;


PROCEDURE ExInput* (VAR Path, Name : ARRAY OF CHAR; Title : ARRAY OF CHAR)
                  : BOOLEAN;
(*
 Same as Input, but a Title can be shown. This feature is only supported
 since TOS 1.4. ExInput automatically calls Input if not available.
 *)
  VAR
    p, n: FN.path;
 BEGIN
  IF GEMDOS.Sversion() <= 1300H THEN
    RETURN Input(Path,Name)
  END;
  COPY(Path, p); COPY(Name, n);
  AdjustPathAndName(p, n);
  AES.AddrIn[0] := S.ADR(p);
  AES.AddrIn[1] := S.ADR(n);
  AES.AddrIn[2] := S.ADR(Title);
  AES.Call(5B000203H);
  IF AES.IntOut[1] = 1 THEN
    COPY( p ,Name);
    FN.SetName( n, Name);
  END(*IF*);
  RETURN AES.IntOut[1] = 1;
 END ExInput;



END Fsel.
