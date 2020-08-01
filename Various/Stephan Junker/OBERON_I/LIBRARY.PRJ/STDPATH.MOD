MODULE StdPath;

(*
 * just exports a variable named stdPath which contains the standard
 * GEMDOS path at the time the module was started.
 *)


IMPORT
  S:=SYSTEM, FN:=Filename, Str:=Strings, GEMDOS, Error;


VAR
  stdPath* : FN.path;


PROCEDURE Get*;
  (*
   * fills the variable stdPath with the current GEMDOS standard path,
   * i.e. <drive>:<path>\.
   * Get is called on module initialisation.
   *)
  VAR
    dummy : INTEGER;
 BEGIN
  dummy := GEMDOS.Dgetpath( 0, S.ADR( stdPath) );
  Str.Insert( " :", 0, stdPath);
  stdPath[0] := CHR( GEMDOS.Dgetdrv() + 41H);
  Str.AppendC("\", stdPath);
 END Get;


PROCEDURE Set*(path : ARRAY OF CHAR);
  (*
   * sets path as GEMDOS standard path. If the path contains a drive
   * character, the standard drive is also set. path may not contain
   * a file name, because it would be treated as a folder name. A
   * "\" at the end is not necessary, but does not disturb either.
   *)
  VAR
    i : INTEGER;
    lc : CHAR;
    s : SET;
 BEGIN
  i := Str.Length(path)-1;
  IF i >= 0 THEN
    lc := path[i];
    IF (lc = "\") OR (lc = "/") THEN
      path[i] := 0X; (* cut \ or / *)
    END;
    IF path[1] = ":" THEN
      s := GEMDOS.Dsetdrv( ORD(CAP(path[0])) - 41H);
      Str.Delete(0, 2, path);
    END;
    Error.NumStrOut(GEMDOS.Dsetpath(S.ADR(path)), path);
  END;
 END Set;


BEGIN
  Get;
END StdPath.