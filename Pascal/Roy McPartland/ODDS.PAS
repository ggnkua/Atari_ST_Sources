PROGRAM Conversion_Chart;

USES
    CRT;

CONST
     Miles_to_Km = 1.82;
VAR
    Miles        : Real;
    Km           : Real;

BEGIN
     Miles := 10;
     Km := Miles * Miles_to_Km;
     WRITELN (Miles:3:0,' Miles equals ',Km:3:0,' Km);
     REPEAT
     Miles := Miles + 10;
     WRITELN (Miles:3:0,' Miles equals ',Km:3:0,' Km);
     UNTIL (Miles = 100);
END.