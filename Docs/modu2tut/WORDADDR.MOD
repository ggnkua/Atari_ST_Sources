                                        (* Chapter 14 - Program 2 *)
MODULE WordAddr;

FROM SYSTEM     IMPORT ADR,WORD,ADDRESS;
FROM InOut      IMPORT WriteString,WriteCard,WriteLn;

VAR Index  : INTEGER;
    CardNo : CARDINAL;
    Peach  : ADDRESS;
    MonoVideo[0B000H:0H]  : ARRAY[1..4000] OF CHAR;
    ColorVideo[0B800H:0H] : ARRAY[1..4000] OF CHAR;

PROCEDURE PrintNumber(DatOut : WORD);
VAR Temp : CARDINAL;
BEGIN
   WriteString("The value is ");
   Temp := CARDINAL(DatOut);
   WriteCard(Temp,4);
   WriteLn;
END PrintNumber;

BEGIN
   Index := 17;
   CardNo := 38;
   Peach := ADR(Index);     (* Pointer to an INTEGER     *)
   Peach := ADR(CardNo);    (* Pointer to a CARDINAL     *)
   PrintNumber(Index);      (* Called with an INTEGER    *)
   PrintNumber(CardNo);     (* Called with a CARDINAL    *)

   Peach := 0B000H:1A2H;    (* Pointer to Segment:Offset *)

END WordAddr.
