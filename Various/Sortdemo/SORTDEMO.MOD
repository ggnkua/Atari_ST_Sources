(* MODULA-2 Version of Selection Sort *)
MODULE SortDemo;
FROM BIOS        IMPORT BConIn,Device;
FROM GEMDOS      IMPORT ConOut;
FROM InOut       IMPORT WriteCard,WriteString,WriteLn;
FROM Sort        IMPORT SelectSort,MAXSIZE;
FROM XBIOS       IMPORT Random;

VAR
  Numbers,SortedNumbers : ARRAY[0..MAXSIZE] OF CARDINAL;
  x,y                   : CARDINAL;
  wait      : LONGCARD;
   
BEGIN
   ConOut(CHR(27)); ConOut("E"); (* Clear the screen                  *)
   WriteLn;                      (* Skip a line                       *)
   FOR x := 0 TO MAXSIZE DO      (* Fill the array with random values *)
      Numbers[x] := CARDINAL(Random() MOD 200);
   END;
   SelectSort(Numbers,SortedNumbers);
   WriteString("    UNSORTED ARRAY     SORTED ARRAY"); WriteLn;
   FOR x := 0 TO MAXSIZE DO
      WriteString("       "); WriteCard(Numbers[x],5);
      WriteString("          "); WriteCard(SortedNumbers[x],5); WriteLn;
   END;
   wait := BConIn(CON); (* Wait for a key press *)
END SortDemo.
