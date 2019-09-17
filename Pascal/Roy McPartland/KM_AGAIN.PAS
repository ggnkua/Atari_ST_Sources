PROGRAM Conversion_Chart;

{       This program displays a conversion chart
        between miles and kilomtric distances.
        Written By Roy McPartland 15/10/91.
        Saved on disk as KM_AGAIN.PAS                }

USES
    CRT;

CONST
     Miles_to_Km = 1.6093;
VAR
    Miles        : Real;
    Km           : Real;

BEGIN
     CLRSCR;
     WRITELN (' Miles to Kilometres chart');
     WRITELN;
     Miles := 10;
     Km := Miles * Miles_to_Km;
     WRITELN (Miles:3:0,' Miles equals ',Km:3:3,' Km');
     REPEAT
     Miles := Miles + 10;
     Km := Miles * Miles_to_Km;
     WRITELN (Miles:3:0,' Miles equals ',Km:3:3,' Km');
     UNTIL (Miles = 100);
END.