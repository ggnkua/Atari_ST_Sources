MODULE FreeMem;

IMPORT GEMDOSIO; (*$EMOS*)
FROM InOut IMPORT WriteLn, WriteCard, WriteString, Read;

FROM Storage IMPORT MemAvail, AllAvail;

VAR ch:CHAR;

BEGIN
  WriteLn;
  WriteLn;
  WriteString ('Largest free space: ');
  WriteCard (MemAvail (),0);
  WriteLn;
  WriteString ('Full free space   : ');
  WriteCard (AllAvail (),0);
  WriteLn;
  Read (ch)
END FreeMem.
