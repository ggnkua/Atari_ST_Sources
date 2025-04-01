MODULE Kreis; (* Kreisdarstellung n. Bresenham *)
              (* Autor: J”rg Kantel            *)
              (* (c) MAXON Computer 1993       *)

FROM TermWindow IMPORT Read, Write, WriteString,
                       SetPos, NewTitle,
                       InitTerminal,
                       OpenTerminal,
                       CloseTerminal,
                       DeleteTerminal;

VAR x,y, xMitte,yMitte, r, rHoch2 : INTEGER;
    taste                         : CHAR;

BEGIN
   xMitte := 38; yMitte := 10; r      := 8;
   x      := 0;  y      := r;  rHoch2 := r*r;

   InitTerminal(TRUE);
   NewTitle("Bresenham-Kreis");
   OpenTerminal(0,0, 0,0);
   (* Wenn w und h bei OpenTerminal = (0,0),
      dann wird das Terminal ber die gesamte
      Bildschirmbreite ge”ffnet.
   *)

   REPEAT
      SetPos(yMitte+y, xMitte+2*x); Write("*");
      SetPos(yMitte+x, xMitte+2*y); Write("*");
      SetPos(yMitte-x, xMitte+2*y); Write("*");
      SetPos(yMitte-y, xMitte+2*x); Write("*");
      SetPos(yMitte-y, xMitte-2*x); Write("*");
      SetPos(yMitte-x, xMitte-2*y); Write("*");
      SetPos(yMitte+x, xMitte-2*y); Write("*");
      SetPos(yMitte+y, xMitte-2*x); Write("*");
      INC(x);
      IF (x*x + y*y - y - rHoch2 >= 0) THEN
         DEC(y);
      END;
   UNTIL x >= y;
   SetPos(20,1);
   WriteString("Ende mit beliebiger Taste");
   Read(taste);
   CloseTerminal;
   DeleteTerminal;
END Kreis.
