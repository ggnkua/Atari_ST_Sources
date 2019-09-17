PROGRAM Double_Your_Money;
{       Program to calculate how long
        it will take for an user
        definable amount of money
        invested in a bank (at a
        definable interest rate) to
        double.
        Written by Roy McPartland to
        demonstrate the WHILE..DO
        functions in Pascal.  Saved on
        disk as INTEREST.PAS 23/10/91     }

USES
    CRT;

VAR
    Count         : Real;
    Investment     : Real;
    Interest_Rate  : Real;
    Added_Interest : Real;
    Orig_Investment: Real;

PROCEDURE Asking_for_input_figures;
     BEGIN
         CLRSCR;
         WRITELN ('Please enter amount to be invested');
         READLN (Orig_Investment);
         WRITELN ('Now enter the interest rate as a decimal');
         READLN (Interest_Rate);
     END;

PROCEDURE Calculating_the_time;
     BEGIN
          Count := 0;
          Investment := Orig_Investment;
          WHILE Investment < (Orig_Investment * 2) DO
               BEGIN
                   Added_Interest := Interest_Rate * Investment;
                   Investment := Investment + Added_Interest;
                   Count := Count + 1
               END;
     END;

PROCEDURE Display_Answers;
     BEGIN
         CLRSCR;
         WRITELN ('The investment takes ',Count:4:1,' years to double');
     END;

BEGIN {Main Program}
    Asking_for_Input_Figures;
    Calculating_the_time;
    Display_Answers;
    DELAY (3000);
    WHILE Orig_investment <> -99 Do
         BEGIN
             Asking_for_Input_Figures;
             Calculating_the_time;
             Display_Answers;
             DELAY (3000);
         END;
END.