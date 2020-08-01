                                         (* Chapter 7 - Program 1 *)
MODULE OverProg;    (* Overall program construction example *)

FROM InOut IMPORT WriteString, WriteLn;

     PROCEDURE Proc1;
     BEGIN
       WriteString("Procedure 1");
       WriteLn;
     END Proc1;

     PROCEDURE Proc2;
          PROCEDURE Proc3;
          BEGIN
            WriteString("Procedure 3");
            WriteLn;
          END Proc3;

          PROCEDURE Proc4;
               PROCEDURE Proc5;
               BEGIN
                 WriteString("Procedure 5");
                 WriteLn;
               END Proc5;
          BEGIN
            WriteString("Procedure 4");
            WriteLn;
            Proc5;
            Proc3;
          END Proc4;
     BEGIN
       WriteString("Procedure 2");
       WriteLn;
       Proc3;
       Proc4;
     END Proc2;

BEGIN
  WriteString("Main Program");
  WriteLn;
  Proc2;
  Proc1;
END OverProg.
