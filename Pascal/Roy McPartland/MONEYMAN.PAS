PROGRAM A_Workers_Wage;
{       Program to work out a wage with the tax rate and
        pay rate set as constants but the HOURS are variable
        By Roy McPartland ?/9/91     }

USES
    CRT;

CONST
     PAY_RATE = 3.50;
     TAX_RATE = 0.25;
VAR
   HOURS     : Real;
   TOTAL_PAY : Real;
   REAL_PAY  : Real;
   TAXED_PAY : Real;

PROCEDURE Display_Text;
     BEGIN
         WRITELN ('Please enter the number of hours worked');
         WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
         READLN (HOURS);
     END;

PROCEDURE Calculating_the_Pay;
     BEGIN
         TOTAL_PAY:= HOURS * PAY_RATE;
         TAXED_PAY:= TOTAL_PAY * TAX_RATE;
         REAL_PAY:= TOTAL_PAY - TAXED_PAY;
     END;

PROCEDURE Displaying_the_Results;
     BEGIN
         WRITELN ('The wage received is œ',REAL_PAY:5:2);
     END;

BEGIN
     Display_Text;
     Calculating_the_Pay;
     Displaying_the_Results;
END.
.