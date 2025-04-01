FROM SYSTEM      IMPORT WORD, VAL, ADR;
FROM AES         IMPORT EventMultiple, WindowUpdate;
FROM AESBase     IMPORT (* nur Konstanten *) MesageEvent, 
TimerEvent, ..., EndUpdate, BeginUpdate, ...;
FROM Application IMPORT messagetype, ...;
FROM WindowBase  IMPORT ...;
...
VAR mBuf : messagetype;
events, flag, mx, my, mbutton, mstate, scancode,
mclicks : INTEGER;
...
flag := MesageEvent + TimerEvent;  (* zum Beispiel *)
...
(* Event Loop: *)
events := EventMultiple(flag,
        0,0,0,
        0,0,0,0,0,
        0,0,0,0,0,
        ADR(mBuf), (* Message-Event *)
        10000,0,   (* Timer-Event   *)
        mx, my,
        mbutton, mstate,
        scancode, mclicks);
WindowUpdate(BeginUpdate);
IF and(events, MesageEvent) THEN ...
  (* MenÅ- und Fensternachrichten auswerten *)
END;
IF and(events, TimerEvent) THEN ...
   (* Timer-Ereignisse auswerten *)
END;
WindowUpdate(EndUpdate);
...