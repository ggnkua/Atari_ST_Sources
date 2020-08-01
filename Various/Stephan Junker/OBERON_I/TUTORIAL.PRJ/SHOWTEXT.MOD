MODULE ShowText;

(*
 little demo to BFiles
 *)

IMPORT
  FN:=Filename, Fsel, Files:=BFiles, IO, Sys, Task;


PROCEDURE Run*;
  VAR
    path, name : FN.path;
    file: Files.File; rider: Files.Rider;
    c: CHAR;
 BEGIN
  path := "*.MOD";
  name := "TEST.MOD";

  IF Fsel.ExInput(path, name, "Text anzeigen") THEN

    file := Files.Old(name);
    IF file # NIL THEN
      rider.Set( file, 0);
      WHILE ~rider.eof DO
        rider.Read(c); IO.WriteChar( c);
      END;
      IO.WriteLn;
      file.Close;
    ELSE
      IO.WriteString( "File could not be opened");
      IO.WriteLn;
    END;

  END;
 END Run;


BEGIN
  IF ~Sys.Loader THEN (* if running as stand alone program *)
    Run;
    Task.Exit(0); (* needed for clean up; will not return *)
  END;
END ShowText.