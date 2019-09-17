PROGRAM CIRCLE_AREA;

     {  This program is designed to calculate
        the area of a circle from it's radius
        value alone.
           IDEA  PB
           PROGRAMMING  D.COULTHURST & R. MCPARTLAND
                SAVED AS Pi      1/10/91                  }

USES
    CRT;

 VAR
    Radius,Area  :  REAL;

 CONST
    Pi =3.1415;

PROCEDURE ENTER_DATA;
    BEGIN
       CLRSCR;
       WRITELN('Enter radius value');
       WRITE('=> ');
       READLN(Radius);
    END;

PROCEDURE Calculation;
    BEGIN
       Area := (Radius*Radius)*Pi
    END;

PROCEDURE Presentation;
    BEGIN
       CLRSCR;
       GOTOXY (0,5);
       WRITE('Radius  = ');
       WRITELN (Radius :8:3);
       WRITE ('Area   = ');
       WRITELN (Area :8:3);

    END;

BEGIN
     ENTER_DATA;
     Calculation;
     Presentation;
END.