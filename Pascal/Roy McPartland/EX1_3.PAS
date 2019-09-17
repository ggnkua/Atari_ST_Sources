PROGRAM Welcome_From;

{      stored on disk as WELCOME.PAS
       Program displays a welcome
       message from me on the screen.
       Written by Ralph Bibby 3/7/91      }

USES
     CRT;

PROCEDURE Display_Text;
     BEGIN
          CLRSCR;
          GOTOXY(28,10);
          WRITE('Welcome');
          GOTOXY(35,10);
          WRITELN(' to the Bankfield Site');
          WRITELN;
          GOTOXY(22,12);
          WRITE('of the City of Liverpool');
          GOTOXY(46,12);
          WRITELN(' Community College');
          WRITELN;
          GOTOXY(34,14);
          WRITE('from Kathryn Towns');
     END;

BEGIN
     Display_Text;
END.






