PROGRAM Earning_Commision;
{       This program, written by
        Roy McPartland, asks the
        user to input a product's
        code, then calculates the
        salesperson's commision.
        20/11/91                     }

USES
    CRT;

VAR
     Input_Code : Char;
     Commision  : Real;
     Input_Sale : Real;

PROCEDURE Input_The_Product;
     BEGIN
         CLRSCR;
         WRITELN ('Please enter the value of the sale');
         READLN (Input_Sale);
         WRITELN ('Now enter the product code');
         READLN (Input_Code);
     END;

PROCEDURE Calculations;
     BEGIN
          CASE (Input_Code) OF
          'A' : Commision := Input_Sale * 0.05;
          'B' : Commision := Input_Sale * 0.10;
          'C' : Commision := Input_Sale * 0.15;
          'D' : Commision := Input_Sale * 0.175;
          'E' : Commision := Input_Sale * 0.2;
          END;
     END;

PROCEDURE Display_Answers;
     BEGIN
         CLRSCR;
         WRITELN ('The sale of œ',Input_Sale:3:2,' has earned a commision of œ',
            Commision:3:2);
     END;

BEGIN
    Input_The_Product;
    Calculations;
    Display_Answers;
END.