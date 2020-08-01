                                        (* Chapter 12 - Program 3 *)
MODULE LinkList;

FROM InOut   IMPORT WriteString, Write, WriteLn;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM SYSTEM  IMPORT TSIZE;

TYPE  NextPointer = POINTER TO FullName;
      FullName = RECORD
        FirstName : ARRAY[0..12] OF CHAR;
        Initial   : CHAR;
        LastName  : ARRAY[0..15] OF CHAR;
        Next      : NextPointer;
      END;

VAR   StartOfList : NextPointer;
      PlaceInList : NextPointer;
      TempPlace   : NextPointer;
      Index       : CARDINAL;

BEGIN   (* Main Program *)

                  (* Generate the first name in the list *)

   ALLOCATE(PlaceInList,TSIZE(FullName));
   StartOfList := PlaceInList;
   PlaceInList^.FirstName := "John ";
   PlaceInList^.Initial := 'Q';
   PlaceInList^.LastName := " Doe";
   PlaceInList^.Next := NIL;

                  (* Generate another name in the list *)

   TempPlace := PlaceInList;
   ALLOCATE(PlaceInList,TSIZE(FullName));
   TempPlace^.Next := PlaceInList;
   PlaceInList^.FirstName := "Mary ";
   PlaceInList^.Initial := 'R';
   PlaceInList^.LastName := " Johnson";
   PlaceInList^.Next := NIL;

                 (* Add 10 more names to complete the list *)

   FOR Index := 1 TO 10 DO
      TempPlace := PlaceInList;
      ALLOCATE(PlaceInList,TSIZE(FullName));
      TempPlace^.Next := PlaceInList;
      PlaceInList^.FirstName := "Billy ";
      PlaceInList^.Initial := 'R';
      PlaceInList^.LastName := " Franklin";
      PlaceInList^.Next := NIL;
   END;

                   (* Display the list on the video monitor *)

   PlaceInList := StartOfList;
   REPEAT
      WriteString(PlaceInList^.FirstName);
      Write(PlaceInList^.Initial);
      WriteString(PlaceInList^.LastName);
      WriteLn;
      TempPlace := PlaceInList;
      PlaceInList := PlaceInList^.Next;
   UNTIL TempPlace^.Next = NIL;
END LinkList.
