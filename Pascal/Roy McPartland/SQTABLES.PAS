PROGRAM Table_Of_Squares;
{       Written by Ralph Bibby 7/12/90
        The program uses a REPEAT loop
        to produce a table of squares
        for integers from 1 to 20
        inclusive                         }

USES
    CRT;

VAR
    Number   : INTEGER;
    NumberSq : INTEGER;

PROCEDURE Print_Headings;
     BEGIN
         CLRSCR;
         WRITELN ('Table of Squares');
         WRITELN;
     END;

PROCEDURE Produce_Table;
     BEGIN
         Number :=1;
         REPEAT
              NumberSq := Number * Number;
              WRITELN (Number:6,NumberSq:6);
              Number := Number + 1
         UNTIL Number > 20
     END;

BEGIN
    Print_Headings;
    Produce_Table;
END.

