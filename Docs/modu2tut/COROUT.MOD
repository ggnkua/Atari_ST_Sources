                                        (* Chapter 15 - Program 1 *)
MODULE Corout;

FROM InOut IMPORT WriteCard, WriteString, WriteLn;

FROM SYSTEM IMPORT WORD, PROCESS, ADR, SIZE,
                   NEWPROCESS, TRANSFER;

VAR  main, Process1, Process2 : PROCESS;
     WorkSpace1, WorkSpace2   : ARRAY[1..300] OF WORD;
     Index : CARDINAL;

PROCEDURE MainProcess;
BEGIN
   FOR Index := 1 TO 5 DO
      WriteString('This is loop');
      WriteCard(Index,2);
      IF Index > 2 THEN
         TRANSFER(Process1,Process2);
         WriteString(' and back to main loop');
      END;
      WriteLn;
   END;     (* of FOR loop *)
   WriteString('End of the MainProcess loop');
   WriteLn;
   TRANSFER(Process1,main);
END MainProcess;

PROCEDURE SubProcess;
BEGIN
   LOOP
      WriteString(' in SubProcess');
      TRANSFER(Process2,Process1);
      WriteString(' back');
   END;
END SubProcess;

BEGIN   (* Main Module Body *)
   NEWPROCESS(MainProcess,ADR(WorkSpace1),SIZE(WorkSpace1),
              Process1);
   NEWPROCESS(SubProcess,ADR(WorkSpace2),SIZE(WorkSpace2),
              Process2);
   TRANSFER(main,Process1);
   WriteString('End of the program');
   WriteLn;
END Corout.
