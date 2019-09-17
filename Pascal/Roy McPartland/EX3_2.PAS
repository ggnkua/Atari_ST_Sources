PROGRAM Fuel_Consumption;

{     Program to calculate the fuel consumption in
      miles per gallon for a car journey.  The
      program allows the user to enter the start and
      finish readings for the odometer and the amount
      of petrol consumed on the journey.  Written by
      Roy McPartland on the same day in September 91     }

USES
    CRT;

VAR
    BEGINING   : Real;
    ENDING     : Real;
    DISTANCE   : Real;
    PETROL_CON : Real;
    MPG        : Real;

PROCEDURE CHEAT;
     BEGIN
         GOTOXY (25,7);
         WRITELN ('YOU CANNOT TURN BACK THE CLOCK');
     END;

PROCEDURE Display_Text;
     BEGIN
          CLRSCR;
          GOTOXY(16,1);
          WRITELN ('Please enter the start reading on the odometer');
          GOTOXY(16,2);
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          READLN (BEGINING);
          GOTOXY (18,5);
          WRITELN ('Now enter the reading at the journeys end');
          GOTOXY (18,6);
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          READLN (ENDING);
          IF ENDING < BEGINING THEN CHEAT;
          GOTOXY (18,8);
          WRITELN ('Please enter the amount of petrol consumed');
          GOTOXY (18,9);
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          READLN (PETROL_CON);
     END;

PROCEDURE Calculations;
     BEGIN
         DISTANCE := ENDING - BEGINING;
         MPG := DISTANCE / PETROL_CON;
     END;

PROCEDURE Display_Results;
     BEGIN
          GOTOXY (10,12);
          WRITELN ('The fuel consumption for the journey is ',MPG:3:0,' Miles per Gallon');
          GOTOXY (10,13);
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      END;

BEGIN

     Display_Text;
     Calculations;
     Display_Results;
END.
