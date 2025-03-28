(*---------------------------------------------------------------------*)
(*---            Implementations Module JoyEvent                    ---*)
(*---            -------------------------------                    ---*)
(*---  Modul zur Abfrage des Joysticks und des Fire-Buttons         ---*)
(*---                                                               ---*)
(*--- Programmiersprache :  SPC-Modula-2 V1.3                       ---*)
(*--- Computersystem     :  ATARI 1040 ST                           ---*)
(*--- Autor              :  Uwe A. Ruttkamp & Clemens Fehr          ---*)
(*--- Datum              :  24.09.1988                              ---*)
(*--- (c) MAXON Computer GmbH                                       ---*)
(*---------------------------------------------------------------------*)

IMPLEMENTATION MODULE JoyEvent;

                 IMPORT XBIOS;
FROM SYSTEM      IMPORT ADR, ADDRESS;
FROM VDIControls IMPORT OpenVirtualWorkstation, CloseVirtualWorkstation,
                        WorkstationInitRec, WorkstationDescription;
FROM VDIInputs   IMPORT MouseState, MouseCodes, SampleMouseButton;
FROM VDIOutputs  IMPORT Coordinate;

CONST
 MoveA0 = 13E8H;
 RTS    = 4E75H;
 
TYPE
 RoutineRec = RECORD
     Opcode  : CARDINAL;
     Offset  : CARDINAL;
     Adresse : ADDRESS;
     Return  : CARDINAL;
 END;
            
VAR
 WorkIn   : WorkstationInitRec;
 WorkOut  : WorkstationDescription;
 Handle   : INTEGER;
 PStatus  : MouseState;
 Location : Coordinate;
 Routine  : RoutineRec;
 Vector   : XBIOS.KBDVECSPtr;
 OldVec   : ADDRESS;
 Wert     : BITSET;

 PROCEDURE InitJoyEvent;
 VAR
  i : CARDINAL;
 BEGIN
  OpenVirtualWorkstation( WorkIn, Handle, WorkOut );
  FOR i:=0 TO 15 DO EXCL(Wert, i); END;
  Routine.Opcode   := MoveA0;
  Routine.Offset   := 2;
  Routine.Adresse  := ADR(Wert);
  Routine.Return   := RTS;
  (* Ab der Adresse ADR(Routine.Opcode) steht nun, in assemblierter
     Form natÅrlich, folgende Befehlsfolge :
     move.b   2(a0), Wert
     rts                   *)
  Vector           := XBIOS.Kbdvbase();
  OldVec           := Vector^.joyvec;
  Vector^.joyvec   := ADR(Routine.Opcode);
  (* Jetzt haben wir den Pointer, der auf die Routine zeigt, die bei
     jeder Joystickaktion angesprungen wird verbogen auf unsere, oben
     beschriebene, Routine. Diese besteht nur aus der Anweisung den
     Wert auf den A0 zeigt (plus einem Offset von 2) an der Stelle ab-
     zulegen, wo die globale Variable Wert steht.   *)
 END InitJoyEvent;
 
 PROCEDURE Joystick( VAR Event : JoyEventTyp ) : BOOLEAN;
 BEGIN
  IF     11 IN Wert THEN Event := Right
   ELSIF 10 IN Wert THEN Event := Left
   ELSIF  9 IN Wert THEN Event := Down
   ELSIF  8 IN Wert THEN Event := Up
   ELSE  Event := None
  END;
  SampleMouseButton( Handle, PStatus, Location );
  RETURN (RightButton IN PStatus);
 END Joystick;
 
 PROCEDURE TermJoyEvent;
 BEGIN
  Vector         := XBIOS.Kbdvbase();
  Vector^.joyvec := OldVec;
  CloseVirtualWorkstation( Handle );
 END TermJoyEvent;
END JoyEvent.
