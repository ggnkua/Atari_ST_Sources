MODULE CoApp; (* SJ 1.3.95 *)

(*
 This module installs a timer procedure in Application which calls the next
 coroutine stored in XCoroutines. Just import it and all your coroutines
 are called regularly in TOS or GEM application. Those coroutines should
 always transfer to the main routine.
 *)


IMPORT
  S:=SYSTEM, Application, XCoroutines, GemApp, XBIOS;



VAR
  time, keyTime: LONGINT;


(*$-k *)

PROCEDURE ReadHz200;
 BEGIN
  S.GET( 4BAH, time);
 END ReadHz200;

(*$+k *)

PROCEDURE GetTime() : LONGINT;
 BEGIN
  XBIOS.Supexec( ReadHz200);
  RETURN time;
 END GetTime;


PROCEDURE Timer() : BOOLEAN;
 BEGIN
  IF GetTime() - keyTime > 200 THEN
    XCoroutines.TransferTime( XCoroutines.current, XCoroutines.Next(), 10 );
  END;
  RETURN FALSE;
 END Timer;


PROCEDURE Keyboard() : BOOLEAN;
 BEGIN
  keyTime := GetTime();
  RETURN FALSE;
 END Keyboard;


BEGIN
  Application.timerProcs.AddProc( Timer);
  GemApp.keyboardProcs.AddProc( Keyboard);
END CoApp.