IMPLEMENTATION MODULE FileSystem;

IMPORT Files;

PROCEDURE  Lookup(VAR f:Files.File;filename:ARRAY OF CHAR;new:BOOLEAN);
BEGIN
  Files.Open(f,filename,Files.readSeqTxt);
  IF Files.State(f)>=0 THEN res:=done ELSE res:=notdone END;
END Lookup;

PROCEDURE Close(VAR f:Files.File);
BEGIN
  Files.Close(f)
END Close;

END FileSystem.

