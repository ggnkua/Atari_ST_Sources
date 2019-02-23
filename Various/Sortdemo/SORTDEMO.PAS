{ PASCAL version of SelectionSort }
PROGRAM SelectionSort;

CONST
  MAXSIZE = 20;

TYPE
  SortArray = ARRAY[0..MAXSIZE] of INTEGER;  

VAR
  Numbers,SortedNumbers : SortArray;
  x,y                   : INTEGER;

FUNCTION random : Integer;
   XBIOS(17);

PROCEDURE ClrScrn;
  EXTERNAL;

PROCEDURE SelectionSort(VAR Numbers,SortedNumbers :  SortArray);
VAR
  x,y,temp : INTEGER;

BEGIN
   FOR x := 0 TO MAXSIZE DO
   BEGIN
      SortedNumbers[x] := Numbers[x];
   END;
   FOR x := 0 TO MAXSIZE-1 DO
   BEGIN
      FOR y := x+1 TO MAXSIZE DO
      BEGIN
         IF SortedNumbers[x] > SortedNumbers[y] THEN
         BEGIN
            temp := SortedNumbers[x];
            SortedNumbers[x] := SortedNumbers[y];
            SortedNumbers[y] := temp;
         END;
      END;
   END;
END;

BEGIN
   ClrScrn; writeln('');
   FOR x := 0 TO MAXSIZE DO
   BEGIN
      Numbers[x] := ABS(Random MOD 200);
   END;
   SelectionSort(Numbers,SortedNumbers);
   writeln('     UNSORTED ARRAY       SORTED ARRAY');
   FOR x := 0 TO MAXSIZE DO
   BEGIN
      writeln('          ',Numbers[x]:3,'                ',SortedNumbers[x]:3);
   END;
   REPEAT
   UNTIL Keypress;
END.
