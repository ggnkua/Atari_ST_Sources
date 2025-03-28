MODULE Test;
(* Date : 21:54  25. 5.1991 *)

  IMPORT Basic, Erwin, SSWiS;

  VAR Module : SSWiS.ModuleHandles;
      StopFlag : BOOLEAN;

  PROCEDURE Accept( Owner  : SSWiS.ModuleHandles;
                    Window : SSWiS.WindowHandles;
                    VAR Report : SSWiS.EventReports );
  BEGIN CASE Report.Type OF
          SSWiS.Notification :
            SSWiS.ExplicitRestore(Owner,Window,SSWiS.NeverClip)
        | SSWiS.Identification :
            SSWiS.Identify("Erwin - Test","===","P. Costanza","9/90 & 5/91")
        | SSWiS.Keyboard : StopFlag := TRUE
        ELSE END
  END Accept;

  PROCEDURE DefWin;
  VAR p : SSWiS.ScreenPoints; P : SSWiS.Points;
  BEGIN Erwin.CreateWindow(Module,0);
        SSWiS.SetWindowElements(Module,0,SSWiS.SetOfWindowElements{SSWiS.Fuller..SSWiS.YScroller});
        SSWiS.SetWindowTitle(Module,0,"Erwin - Test");
        p.X := 40; p.Y := 40;
        SSWiS.PositionWindow(Module,0,p);
        p.X := 300; p.Y := 300;
        SSWiS.SizeWindowContent(Module,0,SSWiS.NullScreenPoint,
                                         p,SSWiS.ScreenSize);
        SSWiS.PositionWorld(Module,0,SSWiS.NullPoint);
        P.X := 1000; P.Y := 1000;
        SSWiS.SizeWorld(Module,0,P);
        SSWiS.PlaceWindowOnTop(Module,0);
        Erwin.Switch(Module,0)
  END DefWin;

BEGIN SSWiS.Register(Module,"Erwin - Test",Accept);
      DefWin;

      Basic.BOX(450,450,550,550);
      Basic.PBOX(100,100,200,200);
      Basic.PLOT(0,0);
      Basic.DRAWto(1000,1000);
      Basic.PLOT(0,1000);
      Basic.DRAWto(1000,0);
      Basic.DEFTEXT(1,17,0,32);
      Basic.TEXT(250,250,"Dies ist ein Test!");

      Erwin.UPDATE;

      StopFlag := FALSE;
      REPEAT SSWiS.PollEvents UNTIL StopFlag;

      Erwin.DeleteWindow(Module,0);
      SSWiS.Deregister(Module)
END Test.



