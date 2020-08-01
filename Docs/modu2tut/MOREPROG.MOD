                                         (* Chapter 7 - Program 2 *)
MODULE MoreProg;   (* More program construction examples *)

FROM InOut IMPORT WriteString, WriteLn;

CONST MainC = 27;
TYPE  MainT = ARRAY[3..7] OF CARDINAL;
VAR   MainV : MainT;

     PROCEDURE Proc1;
     CONST Proc1C = 33;
     TYPE  Proc1T = ARRAY[-23..-15] OF CHAR;
     VAR   Proc1V : MainT;
           Proc11 : Proc1T;
     BEGIN
       WriteString("Procedure 1");
       WriteLn;
     END Proc1;

     PROCEDURE Proc2;
     CONST Proc2C = 22;
     TYPE  Proc2T = ARRAY[3..5],[-4..0] OF BOOLEAN;
     VAR   Proc2V : MainT;
           Proc21 : Proc2T;
          PROCEDURE Proc3;
          CONST Proc3C = -234;
          TYPE  Proc3T = ARRAY[12..13] OF MainT;
          VAR   Proc3V : MainT;
                Proc31 : Proc2T;
                Proc32 : Proc3T;
          BEGIN
            WriteString("Procedure 3");
            WriteLn;
          END Proc3;

          PROCEDURE Proc4;
          CONST Proc4C = 111;
          TYPE  Proc4T = CARDINAL;
          VAR   Proc4V : MainT;
                Proc41 : Proc2T;
                Proc42 : Proc4T;
               PROCEDURE Proc5;
               CONST Proc5C = "A";
               TYPE  Proc5T = ARRAY[22..222] OF CHAR;
               VAR   Proc5V : MainT;
                     Proc51 : Proc2T;
                     Proc52 : Proc4T;
                     Proc53 : Proc5T;
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
END MoreProg.
