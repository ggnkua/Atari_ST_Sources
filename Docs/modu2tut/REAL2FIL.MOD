IMPLEMENTATION MODULE Real2Fil;

(*           Copyright (c) 1987 - Coronado Enterprises             *)

FROM ASCII       IMPORT EOL;
FROM FileSystem  IMPORT File, WriteChar;
FROM Conversions IMPORT ConvertCardinal, ConvertInteger,
                        ConvertOctal, ConvertHex;

VAR OutString : ARRAY[0..80] OF CHAR;



PROCEDURE WriteLnFile(VAR FileName : File);
BEGIN
   WriteChar(FileName,EOL);
END WriteLnFile;



PROCEDURE WriteStringFile(VAR FileName : File;
                          String   : ARRAY OF CHAR);
VAR Index : CARDINAL;
BEGIN
   Index := 0;
   WHILE String[Index] <> 000C DO
      WriteChar(FileName,String[Index]);
      Index := Index + 1;
   END;
END WriteStringFile;



PROCEDURE WriteCardFile(VAR FileName : File;
                        DataOut  : CARDINAL;
                        FieldSize : CARDINAL);
VAR Index : CARDINAL;
BEGIN
   ConvertCardinal(DataOut,6,OutString);
   WHILE FieldSize > 6 DO
      WriteChar(FileName," ");
      FieldSize := FieldSize - 1;
   END;
   FOR Index := 0 TO 5 DO
      IF (OutString[Index] <> " ") OR ((6 - Index) <= FieldSize) THEN
         WriteChar(FileName,OutString[Index]);
      END;
   END;
END WriteCardFile;



PROCEDURE WriteIntFile(VAR FileName : File;
                       DataOut  : INTEGER;
                       FieldSize : CARDINAL);
VAR Index : CARDINAL;
BEGIN
   ConvertInteger(DataOut,6,OutString);
   WHILE FieldSize > 6 DO
      WriteChar(FileName," ");
      FieldSize := FieldSize - 1;
   END;
   FOR Index := 0 TO 5 DO
      IF (OutString[Index] <> " ") OR ((6 - Index) <= FieldSize) THEN
         WriteChar(FileName,OutString[Index]);
      END;
   END;
END WriteIntFile;



PROCEDURE WriteOctFile(VAR FileName : File;
                       DataOut  : CARDINAL;
                       FieldSize : CARDINAL);
VAR Index : CARDINAL;
BEGIN
   ConvertOctal(DataOut,6,OutString);
   WHILE FieldSize > 6 DO
      WriteChar(FileName," ");
      FieldSize := FieldSize - 1;
   END;
   FOR Index := (6 - FieldSize) TO 5 DO
      WriteChar(FileName,OutString[Index]);
   END;
END WriteOctFile;



PROCEDURE WriteHexFile(VAR FileName : File;
                       DataOut  : CARDINAL;
                       FieldSize : CARDINAL);
VAR Index : CARDINAL;
BEGIN
   ConvertHex(DataOut,4,OutString);
   WHILE FieldSize > 4 DO
      WriteChar(FileName," ");
      FieldSize := FieldSize - 1;
   END;
   FOR Index := (4 - FieldSize) TO 3 DO
      WriteChar(FileName,OutString[Index]);
   END;
END WriteHexFile;


(* This procedure uses a rather lengthy method for decomposing the *)
(* REAL number and forming it into single characters.  There is a  *)
(* procedure available in the Logitech library to do this for you  *)
(* but this method is kept as an example of how to decompose the   *)
(* number to prepare it for output.  It could be much more effi-   *)
(* cient to use the Logitech library call. The Procedure is named  *)
(* RealConversions.RealTOString, see your library reference.       *)

PROCEDURE WriteRealFile(VAR FileName : File;
                        DataOut  : REAL;
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
      WriteChar(FileName," ");
      WholeFieldSize := WholeFieldSize - 1;
   END;

   IF DataOut >= 0.0 THEN          (* Output the sign (- or blank) *)
      WriteChar(FileName," ");
   ELSE
      WriteChar(FileName,"-");
   END;

   WHILE Count > 0 DO       (* Output the whole part of the number *)
      ABSDataOut := 10.0 * ABSDataOut;
      Index := TRUNC(ABSDataOut);
      Char := CHR(Index + 48);                   (* 48 = ASCII '0' *)
      WriteChar(FileName,Char);
      ABSDataOut := ABSDataOut - FLOAT(Index);
      Count := Count - 1;
   END;

   IF Digits > 0 THEN  (* Output the fractional part of the number *)
      WriteChar(FileName,'.');
      FOR Count := 1 TO Digits DO
         ABSDataOut := 10.0 * ABSDataOut;
         Index := TRUNC(ABSDataOut);
         Char := CHR(Index + 48);                (* 48 = ASCII '0' *)
         WriteChar(FileName,Char);
         ABSDataOut := ABSDataOut - FLOAT(Index);
      END;
   END;
END WriteRealFile;

END Real2Fil.
