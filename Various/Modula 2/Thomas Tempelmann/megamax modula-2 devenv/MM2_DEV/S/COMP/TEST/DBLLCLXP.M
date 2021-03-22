MODULE DblLclXp;
(*$E MOS *)
IMPORT Console;

PROCEDURE proc; FORWARD;

  MODULE L1;
  IMPORT proc;
  BEGIN proc; END L1;

  MODULE L2;
  IMPORT Console;
  EXPORT proc;
    MODULE LL2;
    FROM Console IMPORT Read, WriteLn, WriteString;
    EXPORT proc;
    PROCEDURE proc;
      BEGIN
        WriteString ('Hallo');
        WriteLn;
      END proc;
    BEGIN proc END LL2;
  BEGIN proc END L2;

BEGIN
  proc;
  Console.WriteLn;
  Console.WriteString ('"Hallo" muž viermal erschienen sein!');
  Console.WriteLn;
END DblLclXp.
