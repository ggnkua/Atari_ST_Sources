MODULE StorageTest;

(*$E MOS *)

FROM SYSTEM IMPORT ASSEMBLER,ADDRESS;
FROM StorBase IMPORT Inconsistent, ALLOCATE, DEALLOCATE, Enlarge, MemSize,
        Resize, AllAvail, MemAvail;
FROM Console IMPORT WriteString, WriteLn, Read;
FROM StrConv IMPORT CardToStr;
FROM GEMDOS IMPORT Xalloc;

VAR c: CHAR;
    n: LONGCARD;
    l, p: POINTER TO ADDRESS;
    ok: BOOLEAN;
    ad: ADDRESS;

BEGIN
  Xalloc (-1L, 0, ad);
  WriteString ('ST : ');
  WriteString (CardToStr (ad, 0));
  WriteLn;
  Xalloc (-1L, 1, ad);
  WriteString ('TT : ');
  WriteString (CardToStr (ad, 0));
  WriteLn;
  WriteString ('Max: ');
  WriteString (CardToStr (MemAvail(), 0));
  WriteLn;
  WriteString ('All: ');
  WriteString (CardToStr (AllAvail(), 0));
  WriteLn;
  ALLOCATE (ad, 100);
  WriteString ('-100:');
  WriteString (CardToStr (AllAvail(), 0));
  WriteLn;
  Resize (ad, 80, ok);
  WriteString ('+20 :');
  WriteString (CardToStr (AllAvail(), 0));
  WriteLn;
  
  (*
  ASSEMBLER BREAK END;
  ALLOCATE (ad, 100);
  ASSEMBLER BREAK END;
  IF MemSize (ad) # 100 THEN HALT END;
  ASSEMBLER BREAK END;
  DEALLOCATE (ad, 10);
  IF MemSize (ad) # 90 THEN HALT END;
  Enlarge (ad, 6, ok);
  IF MemSize (ad) # 96 THEN HALT END;
  n:= 4;
  WriteLn;
  WriteString ('ALLOCATE');
  WriteLn;
  p:= NIL;
  REPEAT
    IF Inconsistent () THEN
      WriteLn;
      WriteString ('Speicherfehler!');
      Read (c);
      WriteLn;
    ELSE
      WriteString ('.');
    END;
    l:= p;
    ALLOCATE (p, n);
    IF p # NIL THEN p^:= l END;
    n:= n * 2L;
  UNTIL p = NIL;
  IF Inconsistent () THEN
    WriteString ('Speicherfehler!');
    Read (c);
    WriteLn;
  END;
  WriteLn;
  WriteString ('DEALLOCATE');
  WriteLn;
  REPEAT
    p:= l^;
    DEALLOCATE (l, 0);
    l:= p;
    IF Inconsistent () THEN
      WriteLn;
      WriteString ('Speicherfehler!');
      Read (c);
      WriteLn;
    ELSE
      WriteString ('.');
    END;
  UNTIL p = NIL;
  p:= ADDRESS(2L);
  DEALLOCATE (p, 0);
  IF Inconsistent () THEN
    WriteLn;
    WriteString ('Speicherfehler!');
    Read (c);
    WriteLn;
  END;
  WriteLn;
  WriteString ('Ready.');
  WriteLn;
  Read (c);
  *)
END StorageTest.
