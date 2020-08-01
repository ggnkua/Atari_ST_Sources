                                        (* Chapter 13 - Program 1 *)
MODULE LocMod1;

FROM InOut IMPORT WriteString, WriteCard, WriteLn;

VAR Index : CARDINAL;

       MODULE LocalStuff;
       EXPORT GetNumber;    (* Nothing else is visible outside *)
                            (* Nothing outside is visible here *)
       VAR Counter : CARDINAL;

              PROCEDURE GetNumber() : CARDINAL;
              BEGIN
                 Counter := Counter + 3;
                 RETURN Counter;
              END GetNumber;

       BEGIN
       Counter := 4;    (* This is only run at load time *)
       END LocalStuff;

BEGIN      (* Main program *)
   FOR Index := 1 TO 8 DO
      WriteString("The count is now ");
      WriteCard(GetNumber(),8);
      WriteLn;
   END;    (* Do loop *)
END LocMod1.
