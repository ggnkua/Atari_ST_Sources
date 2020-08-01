MODULE GemApp; (* SJ 7.12.94 *)

(*
 This new version of GemApp waits for all kinds of events and calls stored
 event handlers.
 *)


IMPORT
  S:=SYSTEM, Application, Evnt, VI:=VDIInput, ProcList, Redirect, Sys,
  Task;



CONST
  Timer = 300;



VAR
  messageProcs-: ProcList.Desc;
  (*
   Add your procedures if you want to catch message events.
   *)
  keyboardProcs-: ProcList.Desc;
  (*
   Add your procedures if you want to catch keyboard events.
   *)
  mouseProcs-: ProcList.Desc;
  (*
   Add your procedures if you want to catch mouse events.
   *)
  message*: Evnt.msgbuf;
  buttons*, shiftbits*: SET;
  mx*, my*, clicks*, scancode*: INTEGER;
  character*: CHAR;
  (*
   These variables describe the kind of event.
   *)
  buttonProcs-: ProcList.Desc;
  (*
   Add your procedures if you want to catch button events.
   *)
  exit*, running: BOOLEAN;
  (*
   If you set exit, GemApp.Run will terminate.
   Special feature: When you set exit before entering Run, it will
   terminate if it was called earlier. Use this to return to the first
   event loop in the program.
   *)



PROCEDURE Run*;
  VAR
    events, dummy: SET;
 BEGIN
  IF ~exit OR ~running THEN
    exit := FALSE; running := TRUE;
    REPEAT
      VI.VqMouse(1, buttons, mx, my);
      events := Evnt.Multi(
          {Evnt.MOUSE1, Evnt.KEYBOARD, Evnt.BUTTON, Evnt.MESSAGE, Evnt.TIME},
          2, {0}, {0}, Evnt.LEAVE, mx, my, 1, 1, 0, 0, 0, 0, 0,
          message, Timer, mx, my, buttons,
          shiftbits, scancode, character, clicks);
      IF Evnt.TIME IN events THEN
        IF (1 IN buttons) THEN
          VI.VqMouse(1, dummy, mx, my);
          buttonProcs.Execute;
        END;
        Application.timerProcs.Execute;
      END;
      IF Evnt.KEYBOARD IN events THEN
        keyboardProcs.AddProc( CheckKey);
        keyboardProcs.Execute;
        keyboardProcs.RemoveProc( CheckKey);
      END;
      IF Evnt.MESSAGE IN events THEN
        messageProcs.Execute;
      END;
      IF (Evnt.MOUSE1 IN events) THEN
        VI.VqMouse(1, buttons, mx, my);
        mouseProcs.Execute
      END;
      IF (Evnt.BUTTON IN events) THEN
        buttonProcs.Execute
      END;
    UNTIL exit;
  END;
  exit := FALSE;
 END Run;


PROCEDURE CheckKey() : BOOLEAN;
 BEGIN
  IF (scancode = 10H) & (shiftbits = {Evnt.CONTROL}) THEN
    Task.Exit(0)
  END;
  IF (scancode = 1FH) & (shiftbits = {Evnt.CONTROL}) THEN
    REPEAT
      Evnt.Keybd(scancode, character);
    UNTIL scancode = 10H;
    RETURN TRUE
  END;
  IF (scancode = 2EH) & (shiftbits = {Evnt.CONTROL}) THEN
    S.PUTREG(15, Sys.stackEnd+Sys.stackSize);
    Run;
    RETURN TRUE
  END;
  RETURN FALSE
 END CheckKey;


PROCEDURE RemoveProcs(from, to: S.PTR) : BOOLEAN;
 BEGIN
  messageProcs.RemoveBetween( from, to);
  keyboardProcs.RemoveBetween( from, to);
  mouseProcs.RemoveBetween( from, to);
  buttonProcs.RemoveBetween( from, to);
  RETURN TRUE
 END RemoveProcs;


PROCEDURE Init;
 BEGIN
  Redirect.Redirect( S.ADR(Application.Run), S.ADR(Run) );
  messageProcs.Initialize;
  keyboardProcs.Initialize;
  mouseProcs.Initialize;
  buttonProcs.Initialize;
  running := FALSE;
  Task.StoreCodeRemoveProc( RemoveProcs);
 END Init;


BEGIN
  Init;
END GemApp.