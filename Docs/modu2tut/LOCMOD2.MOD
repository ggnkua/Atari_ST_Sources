                                        (* Chapter 13 - Program 2 *)
MODULE LocMod2;

FROM InOut IMPORT WriteString, WriteCard, WriteLn;

VAR Index : CARDINAL;

     MODULE MyStuff;
     IMPORT WriteString, WriteCard, WriteLn;
     EXPORT QUALIFIED WriteStuff;
     VAR Counter : CARDINAL;
          PROCEDURE WriteStuff;
          BEGIN
             Counter := Counter + 3;
             WriteString("The value of the counter is ");
             WriteCard(Counter,8);
             WriteLn;
          END WriteStuff;
     BEGIN
        Counter := 4;
     END MyStuff;

BEGIN      (* Main program *)
   FOR Index := 1 TO 8 DO
      MyStuff.WriteStuff;
   END;
END LocMod2.
