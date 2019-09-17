PROGRAM CONVERTING_DEGREES;

        { This program converts temperatures in degees
          celcius to temperatures in degrees fahrenheit

              82073 PROGRAMMING R. MCPARTLAND &
              D.COULTHURST

              DATE OF PRODUCTION 1/10/91
              SAVED AS A FILE ON DISK, PROBABLY NOT CALLED
              CONVERT.PAS                                   }

USES
   CRT;

   VAR
      CELCIUS,FAHRENHEIT : REAL;

PROCEDURE DISPLAY_TEXT;
     BEGIN
         CLRSCR;
         WRITE ('Please enter the value in degrees celcius ');
         READLN (CELCIUS);
         FAHRENHEIT :=(CELCIUS*9/5)+32;
         CLRSCR;
         WRITELN (CELCIUS :4:1,' degrees Celcius is ',FAHRENHEIT :4:1,' degrees Fahrenheit!');
END;

   BEGIN
         DISPLAY_TEXT;
   END.



