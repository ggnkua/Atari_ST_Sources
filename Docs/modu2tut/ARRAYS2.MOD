                                         (* Chapter 6 - Program 2 *)
MODULE Arrays2;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR  Index, Count     : CARDINAL;
     Checkerboard     : ARRAY[1..8] OF ARRAY[1..8] OF CARDINAL;
     Value            : ARRAY[1..8],[1..8] OF CARDINAL;

BEGIN
   FOR Index := 1 TO 8 DO
      FOR Count := 1 TO 8 DO
         Checkerboard[Index,Count] := Index + 3*Count;
         Value[Index,Count] := Index + 2*Checkerboard[Index,Count];
      END;  (* of Count loop *)
   END;     (* of Index loop *)

   WriteString("Output of checkerboard");
   WriteLn;
   FOR Index := 1 TO 8 DO
      FOR Count := 1 TO 8 DO
         WriteInt(Checkerboard[Index,Count],6);
      END;  (* of Count loop *)
      WriteLn;
   END;     (* of Index loop *)

   Value[3,5] := 77;   (* change a few of the values *)
   Value[3,6] := 3;
   Value[Value[3,6],7] := 2;  (* same as Value[3,7] := 2; *)

   WriteLn;
   WriteString("Output of Value matrix");
   WriteLn;
   FOR Count := 1 TO 8 DO
      FOR Index := 1 TO 8 DO
         WriteInt(Value[Count,Index],6);
      END;   (* of Index loop *)
      WriteLn;
   END;      (* of Count loop *)
END Arrays2.
