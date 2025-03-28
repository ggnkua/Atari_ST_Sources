IMPLEMENTATION MODULE Erwin;
(* programmed by P.Costanza *)
(* (c) 1992 MAXON Computer *)

  IMPORT SYSTEM, MOBS, SSWiS, Streams;

  CONST MaxLib = Libs - 1;

  VAR Logs : ARRAY [0..MaxLib] OF RECORD
                                    Registered : BOOLEAN;
                                    Prolog, Epilog : PROC
                                  END;
      WinStreams : ARRAY SSWiS.ModuleHandles,
                         SSWiS.WindowHandles OF Streams.Stream;
      ItemDef : MOBS.CLASSDEF;

  PROCEDURE Register( VAR LibHandle : INTEGER;
                          Prolog, Epilog : PROC );
  BEGIN LibHandle := 0;
        WHILE LibHandle < Libs DO
          IF ~Logs[LibHandle].Registered THEN
            Logs[LibHandle].Registered := TRUE;
            Logs[LibHandle].Prolog := Prolog;
            Logs[LibHandle].Epilog := Epilog;
            RETURN
          END
        END; LibHandle := -1
  END Register;

  PROCEDURE Deregister( LibHandle : INTEGER );
  BEGIN Logs[LibHandle].Registered := FALSE
  END Deregister;

  PROCEDURE Nolog; END Nolog;

  PROCEDURE Restore( Owner     : SSWiS.ModuleHandles;
                     Window    : SSWiS.WindowHandles;
                     WorldArea : SSWiS.Lines;
                     Offset    : SSWiS.Points );
  VAR i : INTEGER; s : Streams.Stream; b : Streams.BasePtr; it : ItemPtr;
  BEGIN Redraw.Owner  := Owner;
        Redraw.Window := Window;
        Redraw.WorldArea := WorldArea;
        Redraw.Offset    := Offset;
        i := 0;
        REPEAT IF Logs[i].Registered THEN Logs[i].Prolog END; INC(i)
        UNTIL i = Libs;
        s := WinStreams[Owner,Window];
        Streams.Reset(s);
        WHILE ~Streams.EOS(s) DO
          Streams.Read(s,b);
          it := MOBS.IS(b^.ID, ItemClass);
          IF it # NIL THEN it^.Redraw(it^.ID) END
        END;
        i := 0;
        REPEAT IF Logs[i].Registered THEN Logs[i].Epilog END; INC(i)
        UNTIL i = Libs
  END Restore;

  PROCEDURE CreateWindow( Owner  : SSWiS.ModuleHandles;
                          Window : SSWiS.WindowHandles );
  BEGIN SSWiS.CreateWindow(Owner,Window,Restore);
        Streams.Open(WinStreams[Owner,Window])
  END CreateWindow;

  PROCEDURE DeleteWindow( Owner  : SSWiS.ModuleHandles;
                          Window : SSWiS.WindowHandles );
  BEGIN SSWiS.DeleteWindow(Owner,Window);
        Streams.Close(WinStreams[Owner,Window])
  END DeleteWindow;

  PROCEDURE Switch( Owner  : SSWiS.ModuleHandles;
                    Window : SSWiS.WindowHandles );
  BEGIN Active.Owner := Owner; Active.Window := Window;
        Active.Stream := SYSTEM.ADR(WinStreams[Owner,Window])
  END Switch;

  PROCEDURE UPDATE;
  BEGIN SSWiS.ExplicitRestore(Active.Owner,Active.Window,SSWiS.NeverClip)
  END UPDATE;

  PROCEDURE InitMODULE;
  VAR i : INTEGER;
  BEGIN i := 0;
        REPEAT Logs[i].Registered := FALSE; INC(i) UNTIL i = Libs;

        ItemClass := MOBS.NEW(ItemDef,Streams.BaseClass,SIZE(Item));

        Active.Owner  := MIN(SSWiS.ModuleHandles);
        Active.Window := MIN(SSWiS.WindowHandles);
        Active.Stream := NIL
  END InitMODULE;

BEGIN InitMODULE
END Erwin.
