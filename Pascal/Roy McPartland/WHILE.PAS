PROGRAM While_Example;

{       This program demonstrates
        the WHILE..DO loop          }

USES
    CRT;

VAR X :Integer;

BEGIN {Main program}
    CLRSCR;
    X := 10;
    WHILE (X > 0) DO
        BEGIN
            WRITE ('  X = ',X:3);
            X := X - 2; {value of x reduced by two}
        END;

END.

