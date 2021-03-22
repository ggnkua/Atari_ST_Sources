MODULE FileTest;

IMPORT Files;

VAR f: Files.File;

BEGIN
  Files.Create (f, "d:\new\s\comp\test\blabla.tmp",Files.writeOnly,Files.replaceOld);
END FileTest.
