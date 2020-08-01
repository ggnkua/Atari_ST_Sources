MODULE Events;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |6.6.93   |started
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Evnt, Event, Key, Window, Menus;

VAR AcOpen*,AcClose*,UnknMsg* : PROCEDURE;

PROCEDURE DistrKey*(Events : Event.evptr);
 BEGIN
  IF NOT Key.Call(Events.Shift,Events.Scan) THEN
    Window.Key(Events.Shift,Events.Scan,Events.Ascii);
  END;
 END DistrKey;
 
PROCEDURE DistrMsg*(Events : Event.evptr);
  VAR Msg : INTEGER;
 BEGIN
  Msg := Events.MsgBuf[0];
  IF Msg = Evnt.MNSELECTED THEN
    Menus.Selected(Events.MsgBuf[3],Events.MsgBuf[4])
  ELSIF (Msg >= Evnt.WMREDRAW) AND (Msg <= Evnt.WMNEWTOP) THEN
    Window.CallMsg(Events.MsgBuf)
  ELSIF Msg = Evnt.ACOPEN THEN 
    IF AcOpen # NIL THEN AcOpen END;
  ELSIF Msg = Evnt.ACCLOSE THEN 
    IF AcClose # NIL THEN AcClose END;
  ELSIF UnknMsg # NIL THEN UnknMsg
  END;
 END DistrMsg;
 
PROCEDURE Multi*(VAR Events : Event.events);
 BEGIN
  Events.Which := Events.Which + {Event.KEY,Event.MESSAGE};
  Events.KeyProc := DistrKey; Events.MsgProc := DistrMsg;
  Event.Multi(Events)
 END Multi;
 
END Events.