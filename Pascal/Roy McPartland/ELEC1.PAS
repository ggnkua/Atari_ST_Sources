PROGRAM Electricity_Bill;

{       This is a program to calculate the total
        cost of an electricity bill, calculating
          the total by subtacting the previous
         month's meter reading from this month's,
         calculating the cost of the electricity
        and then adding a standing charge to this.

               Saved on disk as ELEC1.PAS
            Written by Roy McPartland 8/10/91        }

USES
    CRT;

CONST
     STANDING = 13.50;
     UNITSCH  = 0.058;

VAR
     LASTMETER : INTEGER;
     THISMETER : INTEGER;
     UNITSUSED : REAL;
     NAME      : STRING [25];
     ELECPRICE : REAL;
     TOTAL     : REAL;

PROCEDURE Display_Text;
     BEGIN
         CLRSCR;
         WRITELN ('Please enter name of customer');
         READLN (NAME);
         WRITELN ('What was the last meter reading?');
         READLN (LASTMETER);
         WRITELN ('What is the lastest reading?');
         READLN (THISMETER);
     END;

PROCEDURE Calculate_Bill;
     BEGIN
         UNITSUSED := THISMETER - LASTMETER;
         ELECPRICE := UNITSUSED * UNITSCH;
         TOTAL     := ELECPRICE + STANDING;
     END;

PROCEDURE Printing_Bill;
     BEGIN
         CLRSCR;
         GOTOXY (1,3);
         WRITELN ('Name of customer  ',NAME);
         GOTOXY (1,4);
         WRITELN ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
         GOTOXY (1,6);
         WRITELN ('Last Reading ');
         GOTOXY (1,8);
         WRITE (LASTMETER:4);
         GOTOXY (15,6);
         WRITELN ('This Reading');
         GOTOXY (15,8);
         WRITELN (THISMETER:4);
         GOTOXY (29,6);
         WRITELN ('Units Used');
         GOTOXY (29,8);
         WRITELN (UNITSUSED:4:0);
         GOTOXY (41,6);
         WRITELN ('Price per Unit');
         GOTOXY (41,8);
         WRITELN (UNITSCH:1:3);
         GOTOXY (58,6);
         WRITELN ('Total Unit Cost');
         GOTOXY (58,8);
         WRITELN (ELECPRICE:4:2);
         GOTOXY (58,10);
         WRITELN ('Standing Charge');
         GOTOXY (58,12);
         WRITELN (STANDING:4:2);
         GOTOXY (58,14);
         WRITELN ('TOTAL');
         GOTOXY (58,16);
         WRITELN (TOTAL:4:2);
     END;


BEGIN
    Display_Text;
    Calculate_Bill;
    Printing_Bill;
END.





