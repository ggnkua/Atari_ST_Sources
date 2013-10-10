MODULE WBaTest;


FROM SYSTEM IMPORT ADDRESS,
                   ADR;

IMPORT Terminal;

FROM StrConv IMPORT CardToStr;

FROM InOut IMPORT WriteString, WriteLn, Read, WriteCard, WriteInt, Write;

FROM GrafBase IMPORT Rectangle, Point, white, black, LongRect, LongPnt,
                     BitOperation, MemFormDef,
                     Rect, Pnt, TransRect, LRect, LPnt;

FROM GEMGlobals IMPORT FillType, MButtonSet, MouseButton;

FROM GEMEnv IMPORT DeviceHandle, RC,
                   InitGem;

FROM VDIControls IMPORT SetClipping, DisableClipping;

FROM VDIAttributes IMPORT SetFillColor, SetFillType, SetFillIndex;

FROM VDIOutputs IMPORT FillRectangle, Ellipse;

FROM VDIInputs IMPORT GetMouseState;

FROM WindowBase IMPORT Window, WdwElement, WdwElemSet, WdwFlag, WdwFlagSet,
                       WdwState, SetWdwStrMode, WindowSpec, WindowScrollMode,
                       DetectWdwResult, WindowCopyMode,
                       CreateWindow, DeleteWindow, WindowState, OpenWindow,
                       CloseWindow, SetWindowString, WindowWorkArea,
                       GetWindowSpec, SetWindowSpec, UpdateWindow, DetectWindow,
                       ResetWindowState, WindowFlags, PutWindowOnTop;
                       
FROM ScrnCopy   IMPORT CopyOpaque;


CONST   width                   = 400;
        height                  = 200;
        
        
VAR     ende    : BOOLEAN;
        dev     : DeviceHandle;
        ch      : CHAR;
        
        drawRect: BOOLEAN;
        pos     : LongPnt;
        stdMFDB : MemFormDef;
        

PROCEDURE CloseServer (wdw: Window; env: ADDRESS);

  BEGIN
    CloseWindow (wdw);
  END CloseServer;

PROCEDURE ActiveServer (wdw: Window; env: ADDRESS);

  BEGIN
    Terminal.Write (7C);
  END ActiveServer;

PROCEDURE UpdateServer (wdw   : Window;
                        env   : ADDRESS;
                        source,
                        dest,
                        new   : Rectangle);

  VAR   size    : Rectangle;
        spec    : WindowSpec;
        x0, y0  : INTEGER;
  
  BEGIN
    GetWindowSpec (wdw, spec);
    DisableClipping (dev);
    IF source.w > 0 THEN
      CopyOpaque (dev, ADR (stdMFDB), ADR (stdMFDB), source, dest, onlyS);
    END;
    
    SetClipping (dev, new);
    SetFillColor (dev, white);
    SetFillType (dev, solidFill);
    
    FillRectangle (dev, new);
    
    SetFillColor (dev, black);
    SetFillType (dev, dottPattern);
    SetFillIndex (dev, 16);
    
    WITH size DO
      size := Rect (SHORT (spec.virtual.x), SHORT (spec.virtual.y),
                    SHORT (spec.virtual.w), SHORT (spec.virtual.h));
      Ellipse (dev, Pnt (x + w DIV 2, y + h DIV 2), w DIV 2, h DIV 2);
      SetFillIndex (dev, 18);
      IF drawRect THEN
        FillRectangle (dev, Rect (x + SHORT (pos.x), y + SHORT (pos.y),
                       w DIV 2, h DIV 2))
      END;
    END;
  
  END UpdateServer;
        
PROCEDURE CheckSpecServer (    wdw   :  Window;
                               env   : ADDRESS;
                           VAR spec  : WindowSpec;
                               border: LongRect  );

  CONST charAlign       = 8L;   (*  byte aligning  *)
        charW           = 8;
        charH           = 16;

  VAR   amt: LONGINT;
  
  BEGIN
    WITH spec DO
    
      IF visible.w > LONG (50) * LONG (charW)
      THEN visible.w := LONG (50) * LONG (charW) END;
    
      (*  Umrechnen in Weltkoor.
       *)
      INC (virtual.x, visible.x);
      INC (virtual.y, visible.y);
      
      visible.w := virtual.x + visible.w - 1L;
      visible.h := virtual.y + visible.h - 1L;
      border.w := border.x + border.w - 1L;
      border.h := border.y + border.h - 1L;
      IF virtual.x < border.x THEN virtual.x := border.x END;
      IF virtual.y < border.y THEN virtual.y := border.y END;
      IF virtual.x > border.w THEN virtual.x := border.w END;
      IF virtual.y > border.h THEN virtual.y := border.h END;
      IF visible.w < border.x THEN visible.w := border.x END;
      IF visible.h < border.y THEN visible.h := border.y END;
      IF visible.w > border.w THEN visible.w := border.w END;
      IF visible.h > border.h THEN visible.h := border.h END;
      visible.w := visible.w - virtual.x + 1L;
      visible.h := visible.h - virtual.y + 1L;
      
      INC (virtual.x, charAlign - 1L); DEC (virtual.x, virtual.x MOD charAlign);
      
      DEC (virtual.x, visible.x);
      DEC (virtual.y, visible.y);
      
      amt := visible.x MOD LONG (charW);
      INC (virtual.x, amt); DEC (visible.x, amt);
      amt := visible.y MOD LONG (charH);
      INC (virtual.y, amt); DEC (visible.y, amt);
      
      DEC (visible.w, visible.w MOD LONG (charW));
      DEC (visible.h, visible.h MOD LONG (charH));
      
    END;
  END CheckSpecServer;
(*
  VAR   amt: LONGINT;
  
  BEGIN
    WITH spec DO
      
      IF visible.w > LONG (width) THEN visible.w := LONG (width) END;
    
      (*  Umrechnen in Weltkoor.
       *)
      INC (visible.x, virtual.x);
      INC (visible.y, virtual.y);
      
      DEC (virtual.x, virtual.x MOD 16L);
      DEC (visible.x, visible.x MOD 16L);
      DEC (visible.w, visible.w MOD 16L);
      
      DEC (virtual.y, virtual.y MOD 16L);
      DEC (visible.y, visible.y MOD 16L);
      DEC (visible.h, visible.h MOD 16L);
      
      visible.w := visible.x + visible.w - 1L;
      visible.h := visible.y + visible.h - 1L;
      INC (border.x, 15L); DEC (border.x, border.x MOD 16L);
      INC (border.y, 15L); DEC (border.y, border.y MOD 16L);
      DEC (border.w, border.w MOD 16L);
      DEC (border.h, border.h MOD 16L);
      border.w := border.x + border.w - 1L;
      border.h := border.y + border.h - 1L;
      IF visible.x < border.x THEN visible.x := border.x END;
      IF visible.y < border.y THEN visible.y := border.y END;
      IF visible.x > border.w THEN visible.x := border.w END;
      IF visible.y > border.h THEN visible.y := border.h END;
      IF visible.w < border.x THEN visible.w := border.x END;
      IF visible.h < border.y THEN visible.h := border.y END;
      IF visible.w > border.w THEN visible.w := border.w END;
      IF visible.h > border.h THEN visible.h := border.h END;
      visible.w := visible.w - visible.x + 1L;
      visible.h := visible.h - visible.y + 1L;
      
      DEC (visible.x, virtual.x);
      DEC (visible.y, virtual.y);
      
    END;
  END CheckSpecServer;
 *)

(*$J-*)
PROCEDURE ScrollAmtServer (wdw : Window;
                           env : ADDRESS;
                           mode: WindowScrollMode): LONGINT;
  
(*$J=*)
  VAR   spec: WindowSpec;
  
  BEGIN
    GetWindowSpec (wdw, spec);
    CASE mode OF
      columnLeftWdw,
      columnRightWdw: RETURN 16L|
      rowUpWdw,
      rowDownWdw    : RETURN 16L|
      pageLeftWdw,
      pageRightWdw  : RETURN spec.visible.w|
      pageUpWdw,
      pageDownWdw   : RETURN spec.visible.h|
    END;
  END ScrollAmtServer;
  
PROCEDURE Wait;

  VAR     ch      : CHAR;
  
  BEGIN
    Read (ch);
  END Wait;

PROCEDURE OkOrNot (value:BOOLEAN);

  BEGIN
    IF value THEN WriteString ('OK')
    ELSE WriteString ('An error!') END;
    WriteLn;
  END OkOrNot;

VAR     wdw, w2 : Window;
        success : BOOLEAN;
        i       : LONGCARD;
                       
        
PROCEDURE toggleRect;

  BEGIN
    drawRect := ~ drawRect;
    UpdateWindow (wdw, UpdateServer, NIL, LRect (pos.x, pos.y, 200L, 100L),
                  noCopyWdw, 0L);
  END toggleRect;

PROCEDURE posRect;

  VAR   p          : Point;
        lp         : LongPnt;
        buts       : MButtonSet;
        oldDrawRect: BOOLEAN;
        w          : Window;
        res        : DetectWdwResult;
        spec       : WindowSpec;

  BEGIN
    GetMouseState (dev, p, buts);
    DetectWindow (wdw, 0, p, w, res);
    IF (msBut1 IN buts) AND (res = foundWdwDWR) THEN
    
      GetWindowSpec (wdw, spec);
      lp := LPnt (LONG (p.x) - spec.virtual.x, LONG (p.y) - spec.virtual.y);
      IF (lp.x < 0L) OR (lp.x >= spec.virtual.w)
         OR (lp.y < 0L) OR (lp.y >= spec.virtual.h)  THEN Write (7C)
      ELSE
        oldDrawRect := drawRect;
        IF oldDrawRect THEN toggleRect END;
        pos := lp;
        IF oldDrawRect THEN toggleRect END;
      END;
      
    END;
  END posRect;

VAR     spec: WindowSpec;
        
BEGIN
  stdMFDB.start := NIL;
  drawRect := TRUE;
  InitGem (RC, dev, success);
  IF ~ success THEN HALT END;
  
  pos := LPnt (LONG (width DIV 4), LONG (height DIV 4));
  spec.virtual := LRect (0, 100, width, height);
  spec.visible := LRect (0, 0, 200, 200);
  CreateWindow (wdw, WdwElemSet {infoElem, titleElem, sizeElem, closeElem,
                                 scrollElem},
                UpdateServer, CheckSpecServer, ScrollAmtServer,
                ActiveServer, CloseServer, NIL);
  SetWindowString (wdw, titleWdwStr, 'Hallo...');
  SetWindowString (wdw, infoWdwStr, 'Ich informiere...');
  SetWindowSpec (wdw, spec);
  
  OpenWindow (wdw);
  
  (*
  
  CreateWindow (w2, WdwElemSet {infoElem, titleElem, sizeElem, closeElem,
                                scrollElem},
               UpdateServer, CheckSpecServer, ScrollAmtServer,
               ActiveServer, CloseServer, NIL);
  SetWindowString (w2, titleWdwStr, 'Hallo...');
  SetWindowString (w2, infoWdwStr, 'Ich informiere...');
  SetWindowSpec (w2, spec);
  
  OpenWindow (w2);
   *)
  
  REPEAT
    Read (ch);
    IF ch = ' ' THEN toggleRect END;
    IF ch = 'p' THEN posRect END;
    IF ch = 't' THEN PutWindowOnTop (wdw) END;
  UNTIL ch = 33C;
  
  IF ~ (hiddenWdw IN WindowFlags (wdw)) THEN CloseWindow (wdw) END;
  DeleteWindow (wdw);
END WBaTest.

(* $FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$0000232A$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C$FFF68D6C€$00002653T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$0000127F$00001269$0000129A$00001268$0000129A$0000111E$00000D14$0000112A$000002E5$000026BB$00002653$00002329$000019BA$00001A5A$00002653$00001287¼€€*)
