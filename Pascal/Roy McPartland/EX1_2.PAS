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
          WRITE('Welcome');
          WRITELN(' to the Bankfield Site');
          WRITELN;
          WRITE('of the City of Liverpool');
          WRITELN(' Community College');
          WRITELN;
          WRITE('from Kathryn Towns');
     END;

BEGIN
     Display_Text;
END.





