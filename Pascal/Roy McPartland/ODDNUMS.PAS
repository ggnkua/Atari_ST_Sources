PROGRAM Odd_Numbers;

{       This program displays all the
        odd numbers between 0 and 39
        using the REPEAT & UNTIL
        commands.  Written by Roy Mc
        Partland 15/10/91, Saved as
        ODDNUMS.PAS                       }

USES
    CRT;

VAR
    Number  : Real;

BEGIN {Main program starts here}
     Number:= 1;
     WRITELN (Number:2:0);
      REPEAT
       Number:= Number + 2;
       WRITELN (Number:2:0);
      UNTIL (Number = 39);
END.