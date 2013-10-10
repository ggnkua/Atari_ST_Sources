MODULE KbdDemo;

(*------------------------------------------------------------------------------
 * Version 1.1
 *------------------------------------------------------------------------------
 * Copyright Ω 1989 by Michael Seyfried
 *------------------------------------------------------------------------------
 * Demonstartionsprogramm zum Austesten von 'KbdEvents'
 *------------------------------------------------------------------------------
 *)

FROM SYSTEM IMPORT CAST, BYTE;

FROM GEMGlobals IMPORT MButtonSet, GemChar, SpecialKeySet, SpecialKey;

FROM GEMEnv IMPORT RC, DeviceHandle, InitGem;

FROM AESEvents IMPORT Event, RectEnterMode, MultiEvent, MessageBuffer,
                      EventSet;

FROM GrafBase IMPORT Rectangle, Rect, Point;

IMPORT InOut;

IMPORT StrConv;

IMPORT KbdEvents;

VAR DevHdl: DeviceHandle;                   (* VDI-Handle *)
    success: BOOLEAN;
    mouseLoc: Point;                        (* Variablen fÅr MultiEvent *)
    buttons: MButtonSet;
    keyState: SpecialKeySet;
    key: GemChar;
    doneClicks: CARDINAL;
    occuredEvents: EventSet;
    msg: MessageBuffer;

BEGIN
  InitGem( RC, DevHdl, success);    (* beim GEM anmelden *)
  IF success THEN
    InOut.WriteString( "Modul 'KbdDemo' zum Austesten von 'KbdEvents'");
    InOut.WriteLn;
    InOut.WriteString( 'Copyright Ω 1989 by Michael Seyfried');
    InOut.WriteLn; InOut.WriteLn;
    InOut.WriteString( "'Esc' beenden, 'Undo' KbdEvents (de)aktivieren");
    InOut.WriteLn; InOut.WriteLn;

    (* Ereignisschleife *)
    LOOP
      MultiEvent( EventSet {keyboard}, 0, MButtonSet {}, MButtonSet {},
                  lookForEntry, Rect( 0, 0, 0, 0),
                  lookForEntry, Rect( 0, 0, 0, 0),
                  msg, 0L, mouseLoc, buttons, keyState,
                  key, doneClicks, occuredEvents);
      IF keyboard IN occuredEvents THEN
        IF key.scan = CAST( BYTE, 97) THEN
          InOut.WriteString( 'KbdEvents wurde ');
          IF KbdEvents.KbdEventsInstalled() THEN
            KbdEvents.DeInstallKbdEvents;
            InOut.WriteString( 'deaktiviert.');
          ELSE
            KbdEvents.InstallKbdEvents;
            InOut.WriteString( 'aktiviert.');
          END;
          InOut.WriteLn;
        ELSIF key.ascii = CHR( 27) THEN
          (* Bei Esc terminieren *)
          EXIT
        ELSE
          InOut.WriteString( 'Das GEM meldet folgendes Tastaturereignis:');
          InOut.WriteLn;
          InOut.WriteString( 'ascii: ');
          InOut.Write( key.ascii);
          InOut.WriteLn;
          InOut.WriteString( 'scan: ');
          InOut.WriteString( StrConv.CardToStr( CAST( CARDINAL, key.scan), 5));
          InOut.WriteLn;
          InOut.WriteString( 'keyState: { ');
          IF rightShiftKey IN keyState THEN
            InOut.WriteString( 'rightShiftKey ')
          END;
          IF leftShiftKey IN keyState THEN
            InOut.WriteString( 'leftShiftKey ')
          END;
          IF controlKey IN keyState THEN
            InOut.WriteString( 'controlKey ')
          END;
          IF alternateKey IN keyState THEN
            InOut.WriteString( 'alternateKey ')
          END;
          InOut.WriteString( '}');
          InOut.WriteCard( CAST( CARDINAL, keyState), 6);
          InOut.WriteLn;
        END;
      END;
    END
  END
END KbdDemo.
