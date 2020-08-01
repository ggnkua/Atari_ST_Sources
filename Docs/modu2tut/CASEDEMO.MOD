                                         (* Chapter 4 - Program 6 *)
MODULE CaseDemo;

FROM InOut IMPORT WriteString, WriteInt, WriteLn;

VAR Dummy : INTEGER;

BEGIN

   FOR Dummy := 1 TO 25 DO
      WriteInt(Dummy,4);
      WriteString("  ");
      CASE Dummy OF
         1..5        : WriteString("the number is small"); |
         6..9        : WriteString("it is a little bigger"); |
         10,11       : WriteString("it is 10 or 11"); |
         14..17      : WriteString("it is midrange"); |
         18,20,22,24 : WriteString("it is big and even"); |
         19,21,23    : WriteString("it is big and odd");
      ELSE
         WriteString("The number didn't make the list");
      END;  (* of CASE *)
      WriteLn;
   END;  (* of FOR loop *)

END CaseDemo.
