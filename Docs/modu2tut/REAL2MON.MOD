IMPLEMENTATION MODULE Real2Mon;

(*            Copyright (c) 1987 - Coronado Enterprises            *)

FROM InOut IMPORT Write;

VAR OutString : ARRAY[0..80] OF CHAR;

(* This procedure uses a rather lengthy method for decomposing the *)
(* REAL number and forming it into single characters.  There is a  *)
(* procedure available in the Logitech library to do this for you  *)
(* but this method is kept as an example of how to decompose the   *)
(* number to prepare it for output.  It could be much more effi-   *)
(* cient to use the Logitech library call. The Procedure is named  *)
(* RealConversions.RealTOString, see your library reference.       *)

PROCEDURE WriteReal(DataOut  : REAL;
                    FieldSize : CARDINAL;
                    Digits    : CARDINAL);

VAR Index          : CARDINAL;
    Field          : CARDINAL;
    Count          : CARDINAL;
    WholeFieldSize : CARDINAL;
    ABSDataOut     : REAL;
    Char           : CHAR;
    RoundReal      : REAL;

BEGIN
   IF DataOut >= 0.0 THEN   (* Get the absolute value to work with *)
      ABSDataOut := DataOut;
   ELSE
      ABSDataOut := -DataOut;
   END;

                         (* Make sure the Digits field is positive *)
   IF Digits < 0 THEN
      Digits := 0;
   END;

        (* Make sure there are 3 or more digits for the whole part *)
   IF (FieldSize - Digits) < 3 THEN
      FieldSize := Digits + 3;
   END;

   RoundReal := 0.5;         (* This is used for rounding the data *)
   IF Digits = 0 THEN
      WholeFieldSize := FieldSize;
   ELSE
      WholeFieldSize := FieldSize - Digits - 1;
      FOR Count := 1 TO Digits DO
         RoundReal := RoundReal * 0.1;    (* Reduce for each digit *)
      END;
   END;
   ABSDataOut := ABSDataOut + RoundReal;    (* Add rounding amount *)

   Count := 0;
   WHILE ABSDataOut >= 1.0 DO
      Count := Count + 1;              (* Count significant digits *)
      ABSDataOut := 0.1 * ABSDataOut;
   END;

   WHILE WholeFieldSize > (Count + 1) DO  (* Output leading blanks *)
      Write(" ");
      WholeFieldSize := WholeFieldSize - 1;
   END;

   IF DataOut >= 0.0 THEN          (* Output the sign (- or blank) *)
      Write(" ");
   ELSE
      Write("-");
   END;

   WHILE Count > 0 DO       (* Output the whole part of the number *)
      ABSDataOut := 10.0 * ABSDataOut;
      Index := TRUNC(ABSDataOut);
      Char := CHR(Index + 48);                   (* 48 = ASCII '0' *)
      Write(Char);
      ABSDataOut := ABSDataOut - FLOAT(Index);
      Count := Count - 1;
   END;

   IF Digits > 0 THEN  (* Output the fractional part of the number *)
      Write('.');
      FOR Count := 1 TO Digits DO
         ABSDataOut := 10.0 * ABSDataOut;
         Index := TRUNC(ABSDataOut);
         Char := CHR(Index + 48);                (* 48 = ASCII '0' *)
         Write(Char);
         ABSDataOut := ABSDataOut - FLOAT(Index);
      END;
   END;
END WriteReal;

END Real2Mon.

