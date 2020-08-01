MODULE Edit;

(*
 This is NO editor. Its just an interface for PShel to call an editor.
 *)


IMPORT
  SYSTEM, Filename, CommandLine, Paths, Sys, GEMDOS, Strings, Error, File,
  LTL, StdPath, WinView, PShell, Task, Menus, O2Modules;


CONST
  EditorPath = "D:\EVEREST\";  (* set your path here *)
  Editor = "D:\EVEREST\EVEREST.PRG";



VAR
  lastEdited: Filename.path;



PROCEDURE Run*;
(*
 You can call this procedure by entering "Edit [<file>]" in PShell.
 *)
  VAR
    path: Filename.path;
    ext: Filename.ext;
    modPaths: Paths.path;
    command: ARRAY 127 OF CHAR;
    result: LONGINT;
 BEGIN
  IF CommandLine.arg # NIL THEN
    COPY(CommandLine.arg^, lastEdited);
  END;
  Filename.GetPath( lastEdited, path);
  IF path = "" THEN
    Paths.Read("MODPATH", modPaths);
    LOOP
      IF Paths.Get( modPaths, lastEdited, {}, lastEdited) THEN EXIT END;
      Filename.GetExt( lastEdited, ext);
      IF ext = "" THEN
        Filename.SetExt( "MOD", lastEdited);
      ELSE
        Error.NumStrOut( -33, lastEdited); RETURN
      END;
    END;
  END;
  LOOP
    COPY( lastEdited, command);
    COPY( lastEdited, path);
    Filename.SetExt("ERR", path);
    IF File.Sfirst( path, {}) THEN
      Strings.AppendC( " ", command);
      Strings.Append( path, command)
    END;
    Strings.InsertC( CHR( Strings.Length( command) ), 0, command);
    StdPath.Get;
    COPY( StdPath.stdPath, path);
    StdPath.Set( EditorPath);
    WinView.CloseAll; Menus.Hide;
    result := GEMDOS.Pexec( Sys.Basepage.Env, SYSTEM.ADR(command),
        SYSTEM.ADR( Editor), 0);
    WinView.OpenAll; PShell.menu.Show;
    StdPath.Set( path);
    IF result < 0 THEN
      Error.NumStrOut( SHORT( result), Editor);
      EXIT
    ELSIF result = 1 THEN
      command := "OComp.Compile ";
      Strings.Append( lastEdited, command);
      PShell.Call( command);
      IF Task.retCode = 0 THEN
        O2Modules.Remove(lastEdited);
        EXIT
      END;
    ELSE
      EXIT
    END;
  END;
 END Run;


END Edit.