MODULE Event;

(* Event.Multi tries to simplifie the waiting for multiple events.
   For every kind of event, a procedure can be stored which is called
   if the according event is received. Therefore Event.Multi only
   terminates when Exit is set to true. After the call of KeyProc, the
   keyboard buffer is emptied *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |23.1.93  |started
S.Junker   |19.2.93  |simplified
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Evnt;

CONST KEY* = 0; BUTTON* = 1; MOUSE1* = 2; MOUSE2* = 3; MESSAGE* = 4;
      TIME* = 5;

TYPE evptr*     = POINTER TO events;
     evproc*    = PROCEDURE (Events : evptr);
     events*    = RECORD
                   (* input parameters *)
                   Which*  : SET; (* the events to wait for *)
                   Clicks* : INTEGER;
                   Mask*   : SET; (* the buttons to recognize *)
                   State*  : SET; (* bit = 1 : event if clicked
                                     bit = 0 : event if released *)
                   M1Flags*,M1x*,M1y*,M1w*,M1h* : INTEGER;
                   M2Flags*,M2x*,M2y*,M2w*,M2h* : INTEGER;
                   Time*   : LONGINT;
                   KeyProc*,ButProc*,MsgProc*,TimeProc*,
                   M1Proc*,M2Proc* : evproc; (* these procedures are
                        called if the according event occured *)
                   (* return variables *)
                   Events* : SET; (* events recognized *)
                   MsgBuf* : Evnt.msgbuf;
                   Mx*,My* : INTEGER;
                   Mbut*   : SET; (* the button that made the event *)
                   Shift*  : SET; (* CAPSLOCK excluded, RSHIFT -> LSHIFT *)
                   Scan*   : INTEGER;
                   Ascii*  : CHAR;
                   NClicks*: INTEGER;
                 END(*RECORD*);

VAR Shift*: SET; (* contains the original shift bits returned by Evnt.Multi *)
    Exit* : BOOLEAN; (* TRUE = leave Event.Multi *)

PROCEDURE Multi*(VAR e : events);
 (* wait for all kinds of events *)
  VAR Adr : LONGINT; Buf : Evnt.msgbuf;
      i : INTEGER; s : SET; c : CHAR;
 BEGIN
  Exit := FALSE;
  REPEAT
    e.Events := Evnt.Multi(e.Which,e.Clicks,e.Mask,e.State,e.M1Flags,
         e.M1x,e.M1y,e.M1w,e.M1h,e.M2Flags,e.M2x,e.M2y,e.M2w,e.M2h,e.MsgBuf,
         e.Time,e.Mx,e.My,e.Mbut,Shift,e.Scan,e.Ascii,e.NClicks);
    Adr := S.ADR(e);
    e.Shift := Shift - {0,4,5,6,7};
    IF 0 IN Shift THEN INCL(e.Shift,1) END;
    IF TIME IN e.Events THEN e.TimeProc(Adr) END;
    IF KEY IN e.Events THEN e.KeyProc(Adr);
      WHILE KEY IN Evnt.Multi({KEY,TIME},0,{},{},0,0,0,0,0,0,0,0,0,0,Buf,
        1,i,i,s,s,i,c,i) DO (* empty key buffer *)
      END;
    END;
    IF BUTTON IN e.Events THEN e.ButProc(Adr) END;
    IF MOUSE1 IN e.Events THEN e.M1Proc(Adr) END;
    IF MOUSE2 IN e.Events THEN e.M2Proc(Adr) END;
    IF MESSAGE IN e.Events THEN e.MsgProc(Adr) END;
  UNTIL Exit;
 END Multi;

END Event.
