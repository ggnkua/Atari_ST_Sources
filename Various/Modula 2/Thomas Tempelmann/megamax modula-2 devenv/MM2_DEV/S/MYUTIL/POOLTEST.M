MODULE PoolTest;
(*$E MOS*)

FROM SYSTEM IMPORT ADR, ADDRESS;
FROM GEMDOS IMPORT SFirst, Alloc, SetDTA, Open;
FROM StrConv IMPORT CardToStr;
FROM Console IMPORT Write, WriteString, WriteLn, Read, ReadLine;
FROM Strings IMPORT String;

VAR ad: ADDRESS;
    dta: ARRAY [0..10] OF ARRAY [1..22] OF CARDINAL;
    dtaNr: CARDINAL;
    s: String;
    ch: CHAR;
    i: INTEGER;
    n: CARDINAL;

BEGIN
  dtaNr:= 0;
  LOOP
    WriteString ('Fsfirst? (Y/N) ');
    Read (ch);
    WriteLn;
    IF CAP (ch) = 'Y' THEN
      WriteString ('Yes');
      WriteLn;
      WriteString ('File name? '); ReadLine (s);
      SetDTA (ADR (dta[dtaNr]));
      INC (dtaNr);
      SFirst (s, 0, i);
    ELSE
      WriteString ('No');
      EXIT
    END;
    WriteLn;
  END;
  WriteLn;
  WriteString ('Malloc? (Y/N) ');
  Read (ch);
  WriteLn;
  IF CAP (ch) = 'Y' THEN
    WriteString ('Malloc()');
    WriteLn;
    n:= 0;
    LOOP
      Alloc (10, ad);
      IF LONGINT(ad) <= 0 THEN
        EXIT
      END;
      INC (n);
      Write (CHR (13));
      WriteString (CardToStr (n, 4));
    END;
    WriteLn;
  ELSE
    WriteString ('Fopen()');
    WriteLn;
    n:= 0;
    LOOP
      Open ('C:\DESKTOP.INF', 0, i);
      IF i <= 0 THEN
        EXIT
      END;
      INC (n);
      Write (CHR (13));
      WriteString (CardToStr (n, 4));
    END;
    WriteLn;
  END;
  Read (ch);
END PoolTest.
