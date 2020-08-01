                                        (* Chapter 11 - Program 2 *)
MODULE BigRec;

FROM InOut   IMPORT WriteString, Write, WriteLn;

CONST  NumberOfFriends = 50;

TYPE   FullName = RECORD
         FirstName : ARRAY[0..12] OF CHAR;
         Initial   : CHAR;
         LastName  : ARRAY[0..15] OF CHAR;
       END;

       Date = RECORD
         Day, Month, Year : CARDINAL;
       END;

       Person = RECORD
         Name     : FullName;
         City     : ARRAY[0..15] OF CHAR;
         State    : ARRAY[0..3] OF CHAR;
         BirthDay : Date;
       END;

VAR   Friend             : ARRAY[1..NumberOfFriends] OF Person;
      Self,Mother,Father : Person;
      Index              : CARDINAL;

BEGIN  (* Main Program *)
   Self.Name.FirstName := "Charley";
   Self.Name.Initial := 'Z';
   Self.Name.LastName := "Brown";

   WITH Self DO
      City := "Anywhere";
      State := "CA";
      BirthDay.Day := 17;
      WITH BirthDay DO
         Month := 7;
         Year := 1938;
      END;
   END;   (* All data for Self now defined *)

   Mother := Self;
   Father := Mother;

   FOR Index := 1 TO NumberOfFriends DO
      Friend[Index] := Mother;
   END;

   WriteString(Friend[27].Name.FirstName);
   WriteString(' ');
   Write(Friend[33].Name.Initial);
   WriteString(' ');
   WriteString(Father.Name.LastName);
   WriteLn;
END BigRec.
