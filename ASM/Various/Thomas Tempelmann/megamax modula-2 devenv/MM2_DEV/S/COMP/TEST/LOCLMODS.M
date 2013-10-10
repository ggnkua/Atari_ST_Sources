
MODULE LocModule;

  MODULE M1;
  EXPORT cmd;
    MODULE m2;
    EXPORT cmd;
    TYPE cmd = (NOP, GoUp, GoDown);
    END m2;
  END M1;

  MODULE M3;
  IMPORT cmd;
    MODULE M4;
    IMPORT cmd;
    VAR cc: cmd;
    BEGIN
      cc:=NOP;
    END M4;
  VAR cc: cmd;
  BEGIN
    cc:=NOP;
  END M3;

VAR cc: cmd;

BEGIN
  cc:=NOP;
END LocModule.
