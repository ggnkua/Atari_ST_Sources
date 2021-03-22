IMPLEMENTATION MODULE EasyGraphics;

IMPORT InOut;


(*  --------------------------------------------------------------------------
 *  System-Version: MOS 1.1
 *  --------------------------------------------------------------------------
 *  Version       : 0.01
 *  --------------------------------------------------------------------------
 *  Text-Version  : V#0015
 *  --------------------------------------------------------------------------
 *  Modul-Holder  : Manuel Chakravarty
 *  --------------------------------------------------------------------------
 *  Copyright February 89 by Manuel Chakravarty
 *  Vertriebsrechte fr ATARI ST unter MEGAMAX Modula-2
 *                  liegen bei Application Systems Heidelberg
 *  --------------------------------------------------------------------------
 *  MCH : Manuel Chakravarty
 *  --------------------------------------------------------------------------
 *  Datum    Autor  Version  Bemerkung (Arbeitsbericht)
 *
 *  01.02.89 MCH    0.01     Erste Definition nach 'EasyGraph' von MAC II
 *  --------------------------------------------------------------------------
 *  Modul-Beschreibung:
 *
 *  Grundlegende Grafikroutinen in einem Fenster.
 *  --------------------------------------------------------------------------
 *)

(*  =========== ZU TUN: ==============
 *
 *  -- 'Point' benutzen in Def.-Modul
 *
 *  -- 'baseLine' nicht konst. def., sondern erfragen
 *
 *  -- Turtle sollte ihre Position genauer speichern, um Rundungsfehler
 *     bei 'Move' zu vermeiden.
 *
 *  -- 'MathLib0' wegrationalisieren
 *
 *  =========== DOCU: ================
 *
 *)


FROM SYSTEM IMPORT ADDRESS,
                   ADR;

FROM Storage IMPORT ALLOCATE, DEALLOCATE;

FROM MOSGlobals IMPORT MemArea, GeneralErr, OutOfMemory;

FROM MOSCtrl IMPORT Stack;

FROM PrgCtrl IMPORT TermCarrier,
                    CatchProcessTerm;

FROM MathLib0 IMPORT pi,
                     sin, cos, entier;

FROM GrafBase IMPORT BitOperation, Point, PtrMemFormDef, MemFormDef,
                     Rectangle, white, black,
                     Pnt, TransRect, MinPoint, Rect, GetScreen, SetScreen;

FROM GEMGlobals IMPORT FillType, MarkerType, LineType, TEffectSet;

FROM GEMEnv IMPORT RC, DeviceHandle, GemHandle, PtrDevParm, DevParm,
                   InitGem, ExitGem, CurrGemHandle, SetCurrGemHandle,
                   DeviceParameter;

FROM VDIControls IMPORT SetClipping, DisableClipping;

FROM VDIAttributes IMPORT SetFillColor, SetFillType, SetMarkerColor,
                          SetMarkerType, SetLineColor, SetLineType,
                          SetTextColor, SetTextEffects;

FROM VDIOutputs IMPORT FillRectangle, Mark, Line, GrafText;
IMPORT VDIOutputs;

FROM VDIRasters IMPORT CopyOpaque;

FROM VDIInquires IMPORT TextExtent;

FROM EventHandler IMPORT ShareTime;

FROM WindowBase IMPORT Window, WdwElement, WdwElemSet, ScrollCopyAlways,
                       SetWdwStrMode, ScrollMode, SliderState, NoWindow,
                       CreateWindow, DeleteWindow, OpenWindow, CloseWindow,
                       SetWindowString, CalculateSliders, WindowCoordinates,
                       RedrawWindow, UpdateWindow;


CONST   noErrorTrap     = 6;

        mainWdwName     = ' Std - Graphics ';
        
        baseLine        = 4;

TYPE    turtleDesc      = RECORD
                            pos  : Point;
                            angle: INTEGER;
                          END;
        
        graphWdw        = RECORD
                            turtle: turtleDesc;
                            wdw   : Window;
                            screen: MemFormDef;
                          END;
        ptrGraphWdw     = POINTER TO graphWdw;


VAR     mainGraphWdw    : graphWdw;

        dev             : DeviceHandle;
        gemHdl          : GemHandle;
        
        VoidADR         : ADDRESS;
        VoidI           : INTEGER;


                        (*  misc. proc.s  *)
                        (*  ============  *)
                        
(*  saveCurrHdl -- Rettet das aktuelle GEM-Hdl. in 'saveArea' und setzt
 *                 stattdessen das handle von 'EasyGraphics' ein. Tritt
 *                 beim Setzen ein Fehler auf, so wird ein Laufzeitfehler
 *                 ausgel”žt.
 *)

PROCEDURE saveCurrHdl (VAR saveArea : GemHandle);

  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     CurrGemHandle
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),A0
        MOVE.L  D0,(A0)
        
        MOVE.L  gemHdl,(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     SetCurrGemHandle
        TST.W   (A7)+
        BNE     ende
        
        TRAP    #noErrorTrap
        DC.W    GeneralErr - $E000
        ACZ     "EasyGraph.:Can't set own GEMHdl"
        SYNC
        
ende
    END;
  END saveCurrHdl;
  (*$L=*)

(*  restoreCurrHdl -- Setzt 'saveArea' als GEM-Hdl. ein. Falls dabei ein
 *                    Fehlere auftritt, wird ein Laufzeitfehler ausgel”žt.
 *)
        
PROCEDURE restoreCurrHdl (saveArea : GemHandle);

  (*$L-*)
  BEGIN
    ASSEMBLER
        TST.L   -4(A3)
        BEQ     ende            ; jump, if 'saveArea = noGem'
        
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     SetCurrGemHandle
        TST.W   (A7)+
        BNE     ende
        
        TRAP    #noErrorTrap
        DC.W    GeneralErr - $E000
        ACZ     "EasyGraph.:Can't set old GEMHdl"
        SYNC
        
ende
    END;
  END restoreCurrHdl;
  (*$L=*)
  
(*  reportOutOfMem -- Raises a 'Out of memory' runtime error.
 *                    It is possible to continue from the error.
 *)
 
PROCEDURE reportOutOfMem;

  BEGIN
    ASSEMBLER
        TRAP    #noErrorTrap
        DC.W    OutOfMemory - $6000
    END;
  END reportOutOfMem;

PROCEDURE cantInitGem;

  BEGIN
    ASSEMBLER
        TRAP    #noErrorTrap
        DC.W    GeneralErr - $E000
        ACZ     "EasyGraph.:Can't init. GEM"
        SYNC
    END;
  END cantInitGem;


                        (*  misc. proc.s  *)
                        (*  ============  *)

PROCEDURE newScreen (new: ADDRESS; VAR old: ADDRESS);

  BEGIN
    GetScreen (old, VoidADR, VoidI);
    SetScreen (new, ADDRESS (-1L), -1);
  END newScreen;

PROCEDURE restoreScreen (old: ADDRESS);

  BEGIN
    SetScreen (old, ADDRESS (-1L), -1);
  END restoreScreen;

PROCEDURE setClipping (screen: MemFormDef);

  BEGIN
    SetClipping (dev, Rect (0, 0, screen.w, screen.h));
  END setClipping;

PROCEDURE disableClipping;

  BEGIN
    DisableClipping (dev);
  END disableClipping;
  
  
                        (*  wdw. server  *)
                        (*  ===========  *)
                        
PROCEDURE redrawServer (wdw  : Window;
                        env  : ADDRESS;
                        frame: Rectangle);

  VAR   graphWdwPtr: ptrGraphWdw;
        physScreen : MemFormDef;
        sourceFrame: Rectangle;

  BEGIN
    graphWdwPtr := ptrGraphWdw (env);
    
    physScreen.start := NIL;
    
    IF (frame.w # 0) AND (frame.h # 0) THEN
    
      sourceFrame := TransRect (frame, WindowCoordinates (graphWdwPtr^.wdw,
                                                          MinPoint (frame)));
      CopyOpaque (dev, ADR (graphWdwPtr^.screen), ADR (physScreen),
                  sourceFrame, frame, onlyS);
                  
    END;
  END redrawServer;
  
PROCEDURE activeServer (wdw: Window;
                        env: ADDRESS);

  END activeServer;
  
PROCEDURE closeServer (wdw: Window;
                       env: ADDRESS);

  END closeServer;
  
PROCEDURE moveSizeServer (wdw    : Window;
                          env    : ADDRESS;
                          frame  : Rectangle;
                          maxWork: Rectangle): Rectangle;

  BEGIN
    RETURN frame
  END moveSizeServer;
  
PROCEDURE scrollServer (wdw    : Window;
                        env    : ADDRESS;
                        toDo   : ScrollMode;
                        sliders: SliderState): SliderState;

  VAR   graphWdwPtr: ptrGraphWdw;

  BEGIN
    graphWdwPtr := ptrGraphWdw (env);
    
    WITH sliders DO
      CASE toDo OF
        pageUp     : IF vertPos > vertSize THEN vertPos := vertPos - vertSize
                     ELSE vertPos := 0 END|
        pageDown   : vertPos := vertPos + vertSize|
        pageLeft   : IF horPos > horSize THEN horPos := horPos - horSize
                     ELSE horPos := 0 END|
        pageRight  : horPos := horPos + horSize|
        rowUp      : IF vertPos > 800 THEN vertPos := vertPos - 800
                     ELSE vertPos := 0 END|
        columnLeft : IF horPos > 800 THEN horPos := horPos - 800
                     ELSE horPos := 0 END|
        rowDown    : vertPos := vertPos + 800|
        columnRight: horPos := horPos + 800|
      END;
      
      sliders := CalculateSliders (wdw, horPos, vertPos, graphWdwPtr^.screen.w,
                                   graphWdwPtr^.screen.h);
    
    END;
    
    RETURN sliders
    
  END scrollServer;
  

                        (*  exported proc.s  *)
                        (*  ===============  *)

PROCEDURE Clear ();

  VAR   oldScreen: ADDRESS;

  BEGIN
    newScreen (mainGraphWdw.screen.start, oldScreen);
    
    setClipping (mainGraphWdw.screen);
    SetFillColor (dev, white);
    SetFillType (dev, solidFill);
    FillRectangle (dev, Rect (0, 0, mainGraphWdw.screen.w,
                              mainGraphWdw.screen.h));
    RedrawWindow (mainGraphWdw.wdw);
    disableClipping;
    
    restoreScreen (oldScreen);
  END Clear;
  
PROCEDURE Dot (x, y: INTEGER);

  VAR   oldScreen: ADDRESS;

  BEGIN
    newScreen (mainGraphWdw.screen.start, oldScreen);
    
    setClipping (mainGraphWdw.screen);
    SetMarkerColor (dev, black);
    SetMarkerType (dev, pointMark);
    Mark (dev, Pnt (x, y));
    UpdateWindow (mainGraphWdw.wdw, redrawServer, ADR (mainGraphWdw),
                  Rect (x, y, 1, 1));
    disableClipping;
    
    restoreScreen (oldScreen);
  END Dot;
  
PROCEDURE SetPen (x, y: INTEGER);

  BEGIN
    mainGraphWdw.turtle.pos := Pnt (x, y);
  END SetPen;
  
PROCEDURE TurnTo (d: INTEGER);

  BEGIN
    mainGraphWdw.turtle.angle := d;
  END TurnTo;
  
PROCEDURE Turn (d: INTEGER);

  BEGIN
    WITH mainGraphWdw.turtle DO
      angle := angle + d;
      WHILE angle > 360 DO angle := angle - 360 END;
      WHILE angle < -360 DO angle := angle + 360 END;
    END;
  END Turn;
  
PROCEDURE Move (d: INTEGER);

  BEGIN
    WITH mainGraphWdw.turtle DO
      MoveTo (pos.x + SHORT (entier (FLOAT (d)
                                     * cos (FLOAT (angle) * pi / 180.0))),
              pos.y + SHORT (entier (FLOAT (d)
                                     * sin (FLOAT (angle) * pi / 180.0))));
    END;
  END Move;
  
PROCEDURE MoveTo (x, y: INTEGER);

  VAR   oldScreen: ADDRESS;
        frame    : Rectangle;

  BEGIN
    newScreen (mainGraphWdw.screen.start, oldScreen);
    
    WITH mainGraphWdw DO
    
      setClipping (screen);
      SetLineColor (dev, black);
      SetLineType (dev, solidLn);
      
      Line (dev, turtle.pos, Pnt (x, y));
      
      frame := Rect (turtle.pos.x, turtle.pos.y,
                     x - turtle.pos.x + 1, y - turtle.pos.y + 1);
      IF frame.w < 0 THEN
        frame.x := frame.x + frame.w - 1;
        frame.w := - frame.w;
      END;
      IF frame.h < 0 THEN
        frame.y := frame.y + frame.h - 1;
        frame.h := - frame.h;
      END;
      
      UpdateWindow (wdw, redrawServer, ADR (mainGraphWdw), frame);
      
      turtle.pos := Pnt (x, y);
      
      disableClipping;
      
    END;
    
    restoreScreen (oldScreen);
  END MoveTo;
  
PROCEDURE Circle (x, y, r: INTEGER);

  VAR   oldScreen: ADDRESS;

  BEGIN
    newScreen (mainGraphWdw.screen.start, oldScreen);
    
    setClipping (mainGraphWdw.screen);
    SetLineColor (dev, black);
    SetLineType (dev, solidLn);
    VDIOutputs.Circle (dev, Pnt (x, y), r);
    UpdateWindow (mainGraphWdw.wdw, redrawServer, ADR (mainGraphWdw),
                  Rect (x - r - 1, y - r - 1, 2 * r + 2, 2 * r + 2));
    disableClipping;
    
    restoreScreen (oldScreen);
  END Circle;
  
PROCEDURE Write (ch: CHAR);

  BEGIN
    WriteString (ch);
  END Write;
  
PROCEDURE WriteString (str: ARRAY OF CHAR);

  VAR   oldScreen: ADDRESS;

  BEGIN
    newScreen (mainGraphWdw.screen.start, oldScreen);
    
    setClipping (mainGraphWdw.screen);
    SetTextColor (dev, black);
    SetTextEffects (dev, TEffectSet{});
    GrafText (dev, mainGraphWdw.turtle.pos, str);
    UpdateWindow (mainGraphWdw.wdw, redrawServer, ADR (mainGraphWdw),
                  TransRect (TextExtent (dev, str), mainGraphWdw.turtle.pos));
    disableClipping;
    
    restoreScreen (oldScreen);
  END WriteString;
  
PROCEDURE IdentifyPos (VAR x, y: INTEGER);

  BEGIN
    x := mainGraphWdw.turtle.pos.x;
    y := mainGraphWdw.turtle.pos.y;
  END IdentifyPos;
  

                        (*  managment  *)
                        (*  =========  *)

PROCEDURE termProc;

  BEGIN
    IF mainGraphWdw.wdw # NoWindow THEN DeleteWindow (mainGraphWdw.wdw) END;
    DEALLOCATE (mainGraphWdw.screen.start, 0L);
    ExitGem (gemHdl);
  END termProc;


VAR     wsp      : MemArea;
        termCrr  : TermCarrier;
        devParm  : PtrDevParm;
        
        success  : BOOLEAN;
        oldScreen: ADDRESS;

BEGIN

  mainGraphWdw.wdw := NoWindow;

  (*  Init. GEM.
   *)
  InitGem (RC, dev, success); IF ~ success THEN cantInitGem END;
  gemHdl := CurrGemHandle ();
  
  (*  Inquire screen size and number of planes, used from the VDI
   *  and alloc. a compatible screen.
   *)
   
  devParm := DeviceParameter (dev);
    
  mainGraphWdw.screen.w := 640 (*devParm^.rasterWidth + 1*);
  mainGraphWdw.screen.h := 400 (*devParm^.rasterHeight + 1*);
  mainGraphWdw.screen.standardForm := FALSE;
  mainGraphWdw.screen.words := 40 (*(mainGraphWdw.screen.w + 15) DIV 16*);
  mainGraphWdw.screen.planes := 1 (*devParm^.maxRasterPls*);
  
  ALLOCATE (mainGraphWdw.screen.start, 2L * LONG (mainGraphWdw.screen.words)
                                       * LONG (mainGraphWdw.screen.h));
  IF mainGraphWdw.screen.start = NIL THEN reportOutOfMem END;
  
  (*  Init. a window, clear its contens and show it.
   *)
   
  CreateWindow (mainGraphWdw.wdw,
                WdwElemSet{sizeElem, moveElem, scrollElem, titleElem},
                redrawServer, activeServer, closeServer, moveSizeServer,
                scrollServer, ADR (mainGraphWdw),
                ScrollCopyAlways);
  SetWindowString (mainGraphWdw.wdw, titleWdwStr, mainWdwName);
  
  newScreen (mainGraphWdw.screen.start, oldScreen);
  SetFillColor (dev, white);
  SetFillType (dev, solidFill);
  FillRectangle (dev, Rect (0, 0, mainGraphWdw.screen.w,
                            mainGraphWdw.screen.h));
  restoreScreen (oldScreen);
  
  OpenWindow (mainGraphWdw.wdw);
  ShareTime (0L);
  
  (*  Catch the process termination, for deinit.
   *)
  wsp.bottom := ADR (Stack);
  wsp.length := SIZE (Stack);
  CatchProcessTerm (termCrr, termProc, wsp);
  
END EasyGraphics.
(* $FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFEBD6FA$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$FFED31B2$0000382CT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000037C9$000037EE$00003815$0000382C$00002B1E$000007D3$000032C6$000032F4$000032DD$FFEA5C66$0000383D$000006DE$0000371B$00003735$00003759$00003774€*)
