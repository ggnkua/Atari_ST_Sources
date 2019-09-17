PROGRAM Sterling_to_US_Dollar;

{       Program that should convert the sterling monetary
        unit to that of the US Dollar by multiplying the
        Sterling value by 1.82 (the exchange rate given)
        Written by Roy McPartland sometime in September         }

USES
     CRT;

VAR
     POUND  : Real;
     DOLLAR : Real;

PROCEDURE Display_Text;
     BEGIN
          CLRSCR;
          GOTOXY (18,5);
          WRITELN ('Please enter Sterling Value to be exchanged');
          GOTOXY (18,6);
          WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
          READLN (POUND);
     END;

PROCEDURE Calculate_Dollar_Value;
     BEGIN
         DOLLAR := POUND * 1.82;
     END;

BEGIN {Main program starts here}

     Display_Text;
     Calculate_Dollar_Value;
     GOTOXY (18,11);
     WRITE ('The currency exchange has yeilded $',DOLLAR:4:2);
     GOTOXY (18,12);
     WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
     GOTOXY (52,24);
     WRITELN ('Exchanged at $1.82 to the œ1');
END.
