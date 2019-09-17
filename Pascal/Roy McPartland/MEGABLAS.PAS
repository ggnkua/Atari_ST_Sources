PROGRAM Countdown;

{       This program uses the DELAY function in
        Turbo Pascal to set a delay time of 1000
        miliseconds (1 second) between displaying
        numbers for a 'rocket launch sequence'.
        Written by Roy McPartland, ace space-
        fighter vehicle type thingie commander,
        15/10/91.  Saved on disk as MEGABLAS.PAS     }

USES
    CRT;

VAR
    Number  : Integer;

BEGIN {Main Program};
    CLRSCR;
    WRITELN ('What number do you want to countdown from?');
    READLN (Number);
    CLRSCR;
    GOTOXY (30,11);
    WRITELN ('T minus ',Number,' seconds');
    REPEAT
    Number := Number - 1;
    DELAY (1000);
    GOTOXY (30,11);
    WRITELN ('T minus ',Number,' seconds ');
    UNTIL  (Number = 0);
    GOTOXY (32,13);
    WRITELN ('=============');
    GOTOXY (32,14);
    WRITELN ('Lift Off!!!!!');
    GOTOXY (32,15);
    WRITELN ('=============');
END.

