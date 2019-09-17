PROGRAM ROOM_DIMENTIONS;

{            This  program  asks the user to enter the
             dimentions of a room then  calculates the
             floor area, the total area of the walls &
             ceiling  area then calculates the cost of
                        decorating the room.

              PC version by Roy McPartland and Khaled
                             Mahmud.

               Written on 2/10/91. Saved on disk as
                            ROOMDEC.PAS                 }
USES
    CRT;

   CONST   CARPET     = 11.99;
           PAINT      = 0.5;
           WALL_PAPER = 0.5;

   VAR
            LENGTH    : REAL;
            HEIGHT    : REAL;
            WIDTH     : REAL;
            AREA      : REAL;
            SW        : REAL;
            LW        : REAL;
            WALL_AREA : REAL;
            PAINTCOST : REAL;
            PAPERCOST : REAL;
            CARPETCST : REAL;

PROCEDURE Display_Text;
      BEGIN
         CLRSCR;
         WRITELN ('Please enter length of room');
         READLN (LENGTH);
         WRITELN ('Please enter height of room');
         READLN (HEIGHT);
         WRITELN ('Please enter width of room');
         READLN (WIDTH);
      END;

PROCEDURE CALCULATE_ANSWER;
     BEGIN
        AREA      := LENGTH * WIDTH;
        SW        := HEIGHT * WIDTH;
        LW        := HEIGHT * LENGTH;
        WALL_AREA := (SW + LW) * 2;
        PAINTCOST := PAINT * AREA;
        CARPETCST := AREA * CARPET;
        PAPERCOST := WALL_PAPER * WALL_AREA;
     END;

PROCEDURE DISPLAY_ANSWER;
     BEGIN
         WRITELN ('In a room of length ',LENGTH :3:2,' bredth ',WIDTH: 3:2,
         ' and height ',HEIGHT : 3:2 );
         WRITELN;
         WRITELN ('The floor area equals ',AREA :3:2);
         WRITELN;
         WRITELN ('The ceiling area equals ',AREA :3:2);
         WRITELN;
         WRITELN ('The area of the walls equals ', WALL_AREA :3:2);
         WRITELN;
         WRITELN ('The paint costs œ',PAINTCOST :3:2);
         WRITELN;
         WRITELN ('The carpet costs œ',CARPETCST :3:2);
         WRITELN;
         WRITELN ('The wall paper costs œ',PAPERCOST :3:2);
     END;

BEGIN
     DISPLAY_TEXT;
     CALCULATE_ANSWER;
     DISPLAY_ANSWER;
END.


