
(* ******************* Start Quicksort ****************** *)

PROCEDURE Swap(a, b: CARDINAL);
(* swaps offsets of start of lines a and b *)
VAR tmplong: LONGCARD;
    longptr2: POINTER TO LONGCARD;
BEGIN
  longptr:= lnptradr + ADDRESS(4 * LONG(a));
  tmplong:= longptr^; (* offset of start of line a *)
  longptr2:= lnptradr + ADDRESS(4 * LONG(b));
  longptr^:= longptr2^;
  longptr2^:= tmplong;
END Swap;


PROCEDURE Greater(VAR line1, line2, key: CARDINAL): INTEGER;
(* returns: 1 for > , 0 for = , -1 for < *)
(* key: which key sort field are we doing? *)
VAR longptr1, longptr2: POINTER TO LONGCARD;
    ptr1, ptr2: POINTER TO CHAR;
    i: CARDINAL;
    ch1, ch2: CHAR;
    result: INTEGER;
BEGIN
  longptr1:= lnptradr + ADDRESS(4 * LONG(line1));
  longptr2:= lnptradr + ADDRESS(4 * LONG(line2));
  ptr1:= startadr + ADDRESS(longptr1^ + LONG(startcol[key]));
  ptr2:= startadr + ADDRESS(longptr2^ + LONG(startcol[key]));
  i:= 1;
  LOOP
    ch1:= CAP(ptr1^);
    ch2:= CAP(ptr2^);
    IF ch1 > ch2 THEN
      result:= 1;
      EXIT;
    ELSIF (ch1 < ch2) THEN
      result:= -1;
      EXIT;
    END; (* if *)
    IF (i >= fieldlen[key]) THEN (* made it through fields with all matching *)
        result:= 0;
      EXIT;
    END; (* if done *)
    INC(ptr1);
    INC(ptr2);
    INC(i);
  END; (* loop *)
  RETURN result;
END Greater;


PROCEDURE CheckSwap(VAR index1, index2: CARDINAL): BOOLEAN;
(* if two lines are out of sequence, swap them *)
VAR switched: BOOLEAN;
    int: INTEGER;
    key: CARDINAL;
BEGIN
  key:= 0;
  switched:= FALSE;
  LOOP
    int:= Greater(index1, index2, key);
    IF ((int > 0) & (ascend[key]))
    OR ((int < 0) & NOT(ascend[key])) THEN
      Swap(index1, index2);
      switched:= TRUE;
      EXIT;
    ELSIF int = 0 THEN
      IF key < maxkey THEN
        INC(key);
      ELSE
        EXIT;
      END;
    ELSE (* already in sequence *)
      EXIT;
    END;
  END;
  RETURN switched;
END CheckSwap;


PROCEDURE Bsort(start, top: CARDINAL);
(* bubble sort from start to top, inclusive *)
VAR index, junk: CARDINAL;
    switched: BOOLEAN;
    int: INTEGER;
BEGIN
  REPEAT
    switched:= FALSE; 
    FOR index:= start TO top-1 DO
      junk:= index+1;
      IF CheckSwap(index, junk) THEN
        switched:= TRUE;
      END;
    END; (* for *)
  UNTIL switched = FALSE;
END Bsort;


PROCEDURE Findmedian(start, top: CARDINAL);
(* start, top, middle are line numbers *)
VAR middle: CARDINAL;
    int: INTEGER;
BEGIN
  middle:= (start + top) DIV 2;
  ok:= CheckSwap(start, middle);
  IF CheckSwap(middle, top) THEN (* switched *)
    ok:= CheckSwap(start, middle);
  END;
END Findmedian;


PROCEDURE SwapupChk(VAR e, m: CARDINAL);
VAR int: INTEGER;
    key: CARDINAL;
BEGIN
  int:= 0;
  LOOP (* dec'ing e *)
    IF (e <= m) OR (int >= 5) THEN
      EXIT;
    END;
    key:= 0;
    LOOP (* inc'ing key *)
      int:= Greater(e, m, key);
      IF ((int > 0) & (ascend[key]))
      OR ((int < 0) & NOT(ascend[key])) THEN
        DEC(e);
        EXIT;
      ELSIF int = 0 THEN
        IF key < maxkey THEN
          INC(key);
        ELSE
          DEC(e);
          EXIT;
        END;
      ELSE (* already in sequence *)
        int:= 5; (* exit flag *)
        EXIT;
      END; (* if out of sequence *)
    END; (* loop key *)
  END; (* loop e *)
  IF e > m THEN
    Swap(e, m);
    m:= e;
  END; (* if e > m *)
END SwapupChk;


PROCEDURE SwapdownChk(VAR s, m: CARDINAL);
VAR int: INTEGER;
    key: CARDINAL;
BEGIN
  int:= 0;
  LOOP
    IF (s >= m) OR (int >= 5) THEN
      EXIT;
    END;
    key:= 0;
    LOOP (* inc'ing key *)
      int:= Greater(s, m, key);
      IF ((int < 0) & (ascend[key]))
      OR ((int > 0) & NOT(ascend[key])) THEN
        INC(s);
        EXIT;
      ELSIF int = 0 THEN
        IF key < maxkey THEN
          INC(key);
        ELSE
          INC(s);
          EXIT;
        END;
      ELSE (* already in sequence *)
        int:= 5; (* flag to exit outer loop *)
        EXIT;
      END; (* if out of sequence *)
    END; (* loop key *)
  END; (* loop while *)
  IF s < m THEN
    Swap(s, m);
    m:= s;
  END; (* if s > m *)
END SwapdownChk;


PROCEDURE Sortsection(start, top: CARDINAL);
(* to sort section of main array and divide it into n partitions
   for bubble sort *)
VAR swapup, switched: BOOLEAN;
    s, e, m, key (* , index, middle *): CARDINAL;
    int: INTEGER;
BEGIN
  IF (top - start) < blocksize THEN (* use bubble sort *)
    Bsort(start, top);
  ELSE (* find some middle point and sort above/below that *)
    Findmedian(start, top);
    swapup:= TRUE;
    (* start scanning from array top *)
    s:= start; (* lower comparison limit *)
    e:= top; (* upper comparison limit *)
    m:= start; (* location of comparison value *)
    WHILE e > s DO (* alternate *)
      IF swapup THEN
        (* scan downward from partition top and exchange if smaller
           than median *)
        SwapupChk(e, m);
        swapup:= FALSE;
      ELSE (* not swapup *)
        (* scan upward from partition start and exchange if
           larger than median *)
        SwapdownChk(s, m);
        swapup:= TRUE;
      END; (* if swapup *)
    END; (* while e > s *)

    IF m > start + 1 THEN
      Sortsection(start, m - 1); 
    ELSE 
      int:= 0;
      LOOP (* inc m *)
        IF (m >= top) OR (int <> 0) THEN
          EXIT;
        END;
        key:= 0;
        LOOP (* inc key *)
          int:= Greater(m, start, key);
          IF (int <> 0) THEN
            EXIT;
          ELSE (* int = 0 THEN *)(* equal counts = true *)
            IF key < maxkey THEN
              INC(key);
            ELSE
              INC(m);
              EXIT;
            END;
          END; (* if *)
        END; (* loop key *)
      END; (* loop m while same *)
    END; (* if sort bottom section *)
    IF m < top - 1 THEN
      Sortsection(m, top); 
    END; (* if sort top section *)
  END; (* if top-start < blocksize *)
END Sortsection;
 
(* ******************* End Quicksort ****************** *)
