                                     (* Chapter 15 - Program 4 *)
MODULE Infinite;                    (* Infinite Coroutine loop *)

FROM InOut IMPORT WriteCard, WriteString, WriteLn;

FROM SYSTEM IMPORT WORD, PROCESS, ADR, SIZE,
                   NEWPROCESS, TRANSFER;

VAR  main, Process1, Process2 ,Process3 : PROCESS;
     WorkSpace1, WorkSpace2, WorkSpace3 : ARRAY[1..300] OF WORD;
     Index : CARDINAL;

PROCEDURE MainProcess;
BEGIN
   LOOP
      WriteString('Main Process');
      (* This may check the printer and send another character  *)
      (* for printing if it is ready.                           *)
      TRANSFER(Process1,Process2);
      WriteLn;
   END;
END MainProcess;

PROCEDURE SubProcess;
BEGIN
   LOOP
      WriteString(' SubProcess');
      (* This may check to see if there are any additional      *)
      (* characters to be read from the keyboard.               *)
      TRANSFER(Process2,Process3);
   END;
END SubProcess;

PROCEDURE ThirdProcess;
BEGIN
   LOOP
      WriteString(' ThirdProcess');
      (* This may check to see if there was another update in    *)
      (* the clock requiring service by the system.              *)
      TRANSFER(Process3,Process1);
   END;
END ThirdProcess;

BEGIN   (* Main Module Body *)
   NEWPROCESS(MainProcess,ADR(WorkSpace1),SIZE(WorkSpace1),
              Process1);
   NEWPROCESS(SubProcess,ADR(WorkSpace2),SIZE(WorkSpace2),
              Process2);
   NEWPROCESS(ThirdProcess, ADR(WorkSpace3),SIZE(WorkSpace3),
              Process3);
   TRANSFER(main,Process1);
   (* Note that we never return here, we stay in the status loop *)
END Infinite.
