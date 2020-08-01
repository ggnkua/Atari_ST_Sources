                                        (* Chapter 12 - Program 1 *)
MODULE Pointers;

FROM InOut   IMPORT WriteString, WriteInt, WriteLn;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM SYSTEM  IMPORT TSIZE;

TYPE Name = ARRAY[0..20] OF CHAR;

VAR  MyName : POINTER TO Name;    (* MyName points to a string *)
     MyAge  : POINTER TO INTEGER; (* MyAge points to an INTEGER *)

BEGIN

   ALLOCATE(MyAge,TSIZE(INTEGER));
   ALLOCATE(MyName,TSIZE(Name));

   MyAge^ := 27;
   MyName^ := "John Q. Doe";

   WriteString("My name is ");
   WriteString(MyName^);
   WriteString(" and I am ");
   WriteInt(MyAge^,2);
   WriteString(" years old.");
   WriteLn;

   DEALLOCATE(MyAge,TSIZE(INTEGER));
   DEALLOCATE(MyName,TSIZE(Name));

END Pointers.
