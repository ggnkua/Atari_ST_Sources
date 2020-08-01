                                        (* Chapter 11 - Program 1 *)
MODULE SmallRec;

FROM InOut   IMPORT WriteString, WriteCard, WriteLn;

TYPE Description = RECORD
       Year   : CARDINAL;
       Model  : ARRAY[0..20] OF CHAR;
       Engine : ARRAY[0..8] OF CHAR
       END;

VAR  Cars  : ARRAY[1..10] OF Description;
     Index : CARDINAL;

BEGIN   (* Main Program *)
   FOR Index := 1 TO 10 DO
      Cars[Index].Year := 1930 + Index;
      Cars[Index].Model := " Duesenberg";
      Cars[Index].Engine := "V8";
   END;

   Cars[2].Model := " Stanley Steamer";
   Cars[2].Engine := "Coal";
   Cars[7].Engine := "V12";
   Cars[9].Model := " Ford";
   Cars[9].Engine := "rusted";
   Cars[9].Year := 1981;

   FOR Index := 1 TO 10 DO
      WriteString('My');
      WriteCard(Cars[Index].Year,5);
      WriteString(Cars[Index].Model);
      WriteString(" has a ");
      WriteString(Cars[Index].Engine);
      WriteString(' engine.');
      WriteLn;
   END;
END SmallRec.
