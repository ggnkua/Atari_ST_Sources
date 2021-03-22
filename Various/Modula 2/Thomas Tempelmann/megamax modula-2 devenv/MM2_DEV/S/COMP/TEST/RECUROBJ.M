MODULE RecurObj;

FROM SYSTEM IMPORT TSIZE, ASSEMBLER;

TYPE Object = RECORD
                i: INTEGER;
                o: Object
              END;

VAR x: Object;
    l: LONGCARD;

BEGIN
  ASSEMBLER BREAK END;
  l:= SIZE (x);
  x.i:= 1;
  x.o.i:= 2;
  x.o.o.i:= 3
  .
END RecurObj.
