DEFINITION MODULE FileSystem;

FROM Files IMPORT File;

TYPE Response=(done,notdone);
VAR  res:Response;

PROCEDURE Lookup(VAR f:File;filename:ARRAY OF CHAR;new:BOOLEAN);
PROCEDURE Close(VAR f:File);

END FileSystem.

