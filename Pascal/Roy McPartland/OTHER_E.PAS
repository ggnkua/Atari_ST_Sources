PROGRAM Printing_an_E_on_Screen {Written by Roy McPartland, sorry if I used
the wrong disk!};

      USES CRT;

PROCEDURE Printing_the_long_Es_first;
   BEGIN

         CLRSCR;
         GOTOXY (33,8);
         WRITE ('E E E E E');
         GOTOXY (33,9);
         WRITE ('E E E E E');
         GOTOXY (33,12);
         WRITE ('E E E E E');
         GOTOXY (33,13);
         WRITE ('E E E E E');
         GOTOXY (33,16);
         WRITE ('E E E E E');
         GOTOXY (33,17);
         WRITE ('E E E E E');

     END;

PROCEDURE Now_printing_the_small_lines;
   BEGIN

        GOTOXY (33,10);
        WRITE ('E E E');
        GOTOXY (33,11);
        WRITE ('E E E');
        GOTOXY (33,14);
        WRITE ('E E E');
        GOTOXY (33,15);
        WRITELN ('E E E');

END;


   BEGIN

       Printing_the_long_Es_first;
       Now_printing_the_small_lines;

  END.