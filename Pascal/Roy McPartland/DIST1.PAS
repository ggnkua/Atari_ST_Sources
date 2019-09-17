PROGRAM  Distance_Conversion;

{        Program to demonstrate the REPETITION
         function in Pascal Programming (Also
         it converts distances in miles to
         distances in kilometeres. Written by
         DCS1A in October 1991. Saved as DIST1.PAS    }

USES
    CRT;

CONST
    Miles_To_Km = 1.6; {Converts a distance in miles to kilometres}

VAR
    Miles      : Real;
    Kilometres : Real;

BEGIN {Main program}
    REPEAT
         WRITELN ('Please enter distance to be converted');
         WRITELN ('Enter -99 to exit program');
         READLN (Miles);
         Kilometres := Miles * Miles_To_Km;
         CLRSCR;
         WRITELN (Miles:8:2,' miles = ',Kilometres:8:2,' km');
    UNTIL (Miles = -99);
END.