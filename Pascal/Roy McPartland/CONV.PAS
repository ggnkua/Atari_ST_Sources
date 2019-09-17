PROGRAM EX3_1;

{   This program converts an amount in pounds
    sterling to US dollars usin the current
    exchange rate of  œ1 = $1.82.
    Written by Justin Griffiths 24/09/91.       }

USES CRT;

VAR
    Pounds : REAL;
    Dollars: REAL;

PROCEDURE Enter_Pounds;
    BEGIN
         WRITELN('Enter your amount in pounds sterling ');
         READLN(Pounds);
         Dollars:= Pounds * 1.82;
         WRITE('œ');
         WRITE(Pounds:8:2);
         WRITE('  is equal to  $');
         WRITELN(Dollars:8:2);
         WRITELN('at the current exchange rate');
         WRITELN(' of $1.82 to the œ1.');
     END;

BEGIN
    CLRSCR;
    Enter_Pounds;
END.
