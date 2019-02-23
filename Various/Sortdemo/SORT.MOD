IMPLEMENTATION MODULE Sort;
PROCEDURE SelectSort(VAR Numbers,SortedNumbers : ARRAY OF CARDINAL);

VAR
  x,y,temp : CARDINAL;

BEGIN
   FOR x := 0 TO MAXSIZE DO
      SortedNumbers[x] := Numbers[x];
   END;
   FOR x := 0 TO MAXSIZE-1 DO
      FOR y := x+1 TO MAXSIZE DO
          IF SortedNumbers[x] > SortedNumbers[y] THEN
             temp := SortedNumbers[x];
             SortedNumbers[x] := SortedNumbers[y];
             SortedNumbers[y] := temp;
          END;
      END;
   END;
END SelectSort;
END Sort.