MODULE T;

IMPORT TOSIO; (*$EMOS*)
FROM InOut IMPORT WriteReal;

VAR st: ARRAY [0..10] OF REAL;
    sp: INTEGER;

PROCEDURE push(e:REAL);
  BEGIN
    st[sp]:= e;
    INC (sp);
  END push;

PROCEDURE pop ():REAL;
  BEGIN
    DEC (sp);
    RETURN st[sp];
  END pop;

BEGIN
  push (7.);
  push (4.);
  push (pop()+pop());
  WriteReal (pop(),20,10);
END T.
