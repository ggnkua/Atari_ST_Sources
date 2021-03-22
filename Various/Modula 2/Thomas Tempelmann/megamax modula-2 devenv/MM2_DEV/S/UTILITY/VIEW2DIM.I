IMPLEMENTATION MODULE View2Dim;

(*
 * Thomas Tempelmann, 17.5.93
 *
 * Terminologie:
 *  'wdw' ist immer vom Typ CellWindow,
 *  'win' ist immer vom Typ WindowBase.Window,
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADR, ADDRESS;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
FROM GrafBase IMPORT MemFormDef, BitOperation, Point, Rectangle, black, white,
        FramePoints, ClipRect, Rect, Pnt, LPnt, LongPnt, LongRect;
FROM VDIRasters IMPORT CopyOpaque;
FROM VDIControls IMPORT DisableClipping, SetClipping;
FROM GEMEnv IMPORT RC, GemHandle, DeviceHandle, ExitGem, GemError,
        InitGem, CurrGemHandle, SetCurrGemHandle, GemActive;
FROM VDIAttributes IMPORT SetTextColor, SetTextEffects, SetFillColor,
        SetFillType, SetFillPerimeter, SetWritingMode,
        SetLineType, SetLineColor, SetLineWidth;
FROM VDIOutputs IMPORT Line, FillRectangle, GrafText;
FROM GEMGlobals IMPORT GemChar, MButtonSet, msBut1, LineType, SpecialKeySet;
IMPORT SystemError, WindowBase;
FROM EventHandler IMPORT FlushEvents, InstallWatchDog, WatchDogCarrier,
        EventProc;
FROM AESEvents IMPORT mouseButton;
FROM SysUtil0 IMPORT VarEqual;

TYPE    CellWindow = POINTER TO RECORD
                       win: WindowBase.Window;
                       cellEnv: ADDRESS;
                       cellW, cellH: INTEGER;
                       cellsX, cellsY: INTEGER;
                       drawBorders: BOOLEAN;
                       suppressUpdate: INTEGER; (* nur Updates, wenn Null *)
                       (* mustNotCopy: INTEGER;    (* wenn # 0, Neuzeichnen! *) *)
                       updateCell: UpdateCellProc;
                       activateCell: ActivateCellProc;
                       closeCellWindow: CloseCellWdwProc;
                     END;

CONST   maxWdw = 9;

VAR     wdws: ARRAY [0..maxWdw] OF CellWindow;
        wins: ARRAY [0..maxWdw] OF WindowBase.Window;
        winEnvOffs: LONGCARD;

VAR     stdMFDB: MemFormDef;
        device: DeviceHandle;
        gemHdl: GemHandle;
        ok: BOOLEAN;


PROCEDURE pointToCellPos (    wdw    :CellWindow;
                              p      :Point;
                          VAR column,
                              row    : INTEGER;
                          VAR success: BOOLEAN);

  VAR   lp: LongPnt;
  
  BEGIN
    WITH wdw^ DO
      WindowBase.CalcWindowCoor (win, p, lp, success);
      IF NOT success THEN RETURN END;
      column := SHORT (lp.x DIV LONG (cellW));
      row := SHORT (lp.y DIV LONG (cellH));
      IF column >= cellsX THEN
        column := cellsX - 1
      END;
      IF row >= cellsY THEN
        row := cellsY - 1
      END;
    END;
  END pointToCellPos;

PROCEDURE cellToPointPos (wdw: CellWindow; column, row: INTEGER): Point;
  (*  Calculates the real pixel coors of the cell coors *)
  VAR   result: Point;
  BEGIN
    WITH wdw^ DO
      WindowBase.CalcScreenCoor (win,
                                 LPnt (LONG (column) * LONG (cellW),
                                       LONG (row) * LONG (cellH)), result, ok);
    END;
    RETURN result
  END cellToPointPos;

VAR lastFrameW, lastFrameH: INTEGER;

PROCEDURE update (win   : WindowBase.Window;
                  env   : ADDRESS;
                  source,
                  dest,
                  new   : Rectangle);

  VAR   wdw: CellWindow;
        oldHdl: GemHandle;
        blankOnce: BOOLEAN; (* alles auf einmal l”schen oder zellenweise *)
        x, y, l, t, r, b: INTEGER;
        cell: CellPnt;
        p, p2: Point;
        clip, frame: Rectangle;

  BEGIN (*update*)
    wdw:= env;
    IF wdw^.win # win THEN HALT END;
    
    IF wdw^.suppressUpdate # 0 THEN RETURN END;
    
    IF source.w # 0 THEN
      (*IF wdw^.mustNotCopy = 0 THEN*)
      DisableClipping (device);
      CopyOpaque (device, ADR (stdMFDB), ADR (stdMFDB), source, dest, onlyS);
      (*ELSE
          (* Kopieren nicht erlaubt - neuzeichnen! *)
          IF (new.w <= 0) OR (new.h <= 0) THEN
            new:= dest
          ELSE
            new:= FrameRects (new, dest);
          END
        END
      *)
    END;
    
    IF (new.w <= 0) OR (new.h <= 0) THEN RETURN END;
    
    oldHdl:= CurrGemHandle ();
    SetCurrGemHandle (gemHdl, ok);
    IF NOT ok THEN HALT END;
    
    frame.w:= wdw^.cellW;
    frame.h:= wdw^.cellH;
    
    blankOnce:= (frame.w < 64) OR (frame.h < 30)
             OR (lastFrameW # frame.w) OR (lastFrameH # frame.h);
    
    lastFrameW:= frame.w;
    lastFrameH:= frame.h;
    
    IF blankOnce THEN
      SetFillColor (device, white);
      FillRectangle (device, new);
    END;
    
    pointToCellPos (wdw, Pnt (new.x, new.y), l, t, ok);
    pointToCellPos (wdw, Pnt (new.x+new.w-1, new.y+new.h-1), r, b, ok);
    FOR y:= t TO b DO
      FOR x:= l TO r DO
        p:= cellToPointPos (wdw, x, y);
        frame.x:= p.x;
        frame.y:= p.y;
        clip:= ClipRect (frame, new);
        IF VarEqual (clip, frame) THEN
          DisableClipping (device);
          (* wird sowieso bermalt:
            IF ~blankOnce THEN SetFillColor (device, white); FillRectangle (device, clip); END;
          *)
        ELSE
          (* wird sowieso bermalt:
            IF ~blankOnce THEN SetFillColor (device, white); FillRectangle (device, clip); END;
          *)
          SetClipping (device, new);
        END;
        cell.x:= x;
        cell.y:= y;
        wdw^.updateCell (wdw, wdw^.cellEnv, cell, frame, clip, device);
      END(*FOR*);
      IF ~blankOnce THEN
        (* briger rechter Bereich, der nicht zu Zellen geh”rt, l”schen *)
        x:= r+1;
        p:= cellToPointPos (wdw, x, y);
        frame.x:= p.x;
        frame.y:= p.y;
        clip:= ClipRect (frame, new);
        IF (clip.w > 0) & (clip.h > 0) THEN
          SetFillColor (device, white);
          FillRectangle (device, clip);
        END
      END;
    END(*FOR*);
    IF ~blankOnce THEN
      (* briger unterer Bereich, der nicht zu Zellen geh”rt, l”schen *)
      SetFillColor (device, white);
      y:= b+1;
      FOR x:= l TO r DO
        p:= cellToPointPos (wdw, x, y);
        frame.x:= p.x;
        frame.y:= p.y;
        clip:= ClipRect (frame, new);
        IF (clip.w > 0) & (clip.h > 0) THEN
          FillRectangle (device, clip);
        END;
      END
    END;
    
    IF wdw^.drawBorders THEN
      SetLineColor (device, black);
      SetLineType (device, solidLn);
      SetLineWidth (device, 1);
      p:= cellToPointPos (wdw, l, t);
      p2:= cellToPointPos (wdw, r+1, b+1);
      SetClipping (device, new);
      x:= p.x + wdw^.cellW-1;
      REPEAT
        Line (device, Point {x, p.y}, Point {x, p2.y});
        INC (x, wdw^.cellW)
      UNTIL x >= p2.x;
      y:= p.y + wdw^.cellH-1;
      REPEAT
        Line (device, Point {p.x, y}, Point {p2.x, y});
        INC (y, wdw^.cellH);
      UNTIL y >= p2.y;
    END;
    
    DisableClipping (device);
    
    SetCurrGemHandle (oldHdl, ok);
    IF NOT ok THEN HALT END;
  END update;

PROCEDURE activated (win: WindowBase.Window; env: ADDRESS);

  END activated;

PROCEDURE close (win: WindowBase.Window; env: ADDRESS);

  VAR   wdw: CellWindow;

  BEGIN
    wdw:= env;
    IF wdw^.win # win THEN HALT END;
    IF ADDRESS (wdw^.closeCellWindow) # NIL THEN
      IF wdw^.closeCellWindow (wdw, wdw^.cellEnv) THEN
        CloseCellWindow (wdw)
      END;
    END;
  END close;

PROCEDURE checkSpec (    win   : WindowBase.Window;
                         env   : ADDRESS;
                     VAR spec  : WindowBase.WindowSpec;
                         border: LongRect    );
  
  CONST cellAlign       = 8L;
  
  VAR   wdw: CellWindow;
        amt: LONGINT;
        ptr: ADDRESS;

  BEGIN
    wdw:= env;
    IF wdw^.win # win THEN HALT END;
    WITH spec DO
      IF visible.w > LONG (wdw^.cellsX) * LONG (wdw^.cellW) THEN
        visible.w:= LONG (wdw^.cellsX) * LONG (wdw^.cellW)
      END;
      IF visible.h > LONG (wdw^.cellsY) * LONG (wdw^.cellH) THEN
        visible.h:= LONG (wdw^.cellsY) * LONG (wdw^.cellH)
      END;
      (*  Umrechnen in Weltkoor. *)
      INC (virtual.x, visible.x);
      INC (virtual.y, visible.y);
      visible.w:= virtual.x + visible.w - 1L;
      visible.h:= virtual.y + visible.h - 1L;
      border.w:= border.x + border.w - 1L;
      border.h:= border.y + border.h - 1L;
      IF virtual.x < border.x THEN virtual.x:= border.x END;
      IF virtual.y < border.y THEN virtual.y:= border.y END;
      IF virtual.x > border.w THEN virtual.x:= border.w END;
      IF virtual.y > border.h THEN virtual.y:= border.h END;
      IF visible.w < border.x THEN visible.w:= border.x END;
      IF visible.h < border.y THEN visible.h:= border.y END;
      IF visible.w > border.w THEN visible.w:= border.w END;
      IF visible.h > border.h THEN visible.h:= border.h END;
      visible.w:= visible.w - virtual.x + 1L;
      visible.h:= visible.h - virtual.y + 1L;
      
      INC (virtual.x, cellAlign - 1L); DEC (virtual.x, virtual.x MOD cellAlign);
      
      DEC (virtual.x, visible.x);
      DEC (virtual.y, visible.y);
      
      amt:= visible.x MOD LONG (wdw^.cellW);
      INC (virtual.x, amt); DEC (visible.x, amt);
      amt:= visible.y MOD LONG (wdw^.cellH);
      INC (virtual.y, amt); DEC (visible.y, amt);
      
      (*
        DEC (visible.w, visible.w MOD LONG (wdw^.cellW));
        DEC (visible.h, visible.h MOD LONG (wdw^.cellH));
      *)
    END;
  END checkSpec;

PROCEDURE scrollAmt (win    : WindowBase.Window;
                     env    : ADDRESS;
                     toDo   : WindowBase.WindowScrollMode): LONGINT;

  VAR   spec: WindowBase.WindowSpec;
        wdw: CellWindow;

  BEGIN
    wdw:= env;
    IF wdw^.win # win THEN HALT END;
    WindowBase.GetWindowSpec (win, spec);
    CASE toDo OF
      WindowBase.pageLeftWdw,
      WindowBase.pageRightWdw  : RETURN spec.visible.w|
      WindowBase.pageUpWdw,
      WindowBase.pageDownWdw   : RETURN spec.visible.h|
      WindowBase.columnLeftWdw,
      WindowBase.columnRightWdw: RETURN wdw^.cellW|
      WindowBase.rowUpWdw,
      WindowBase.rowDownWdw    : RETURN wdw^.cellH|
    END;
  END scrollAmt;


PROCEDURE setPosAndSize (wdw: CellWindow; x, y, w, h: INTEGER);
  BEGIN
    WITH wdw^ DO
      IF x = -1 THEN x := WindowBase.CenterWdw ELSE x := x * cellW END;
      IF y = -1 THEN y := WindowBase.CenterWdw ELSE y := y * cellH END;
      IF w = -1 THEN w := WindowBase.MaxWdw ELSE w := w * cellW END;
      IF h = -1 THEN h := WindowBase.MaxWdw ELSE h := h * cellH END;
      WindowBase.SetWindowWorkArea (win, Rect (x, y, w, h))
    END
  END setPosAndSize;

PROCEDURE Enqueue (wdw: CellWindow; win: WindowBase.Window): BOOLEAN;
  VAR n: CARDINAL;
  BEGIN
    FOR n:= 0 TO maxWdw DO
      IF wdws[n] = NIL THEN
        wdws[n]:= wdw;
        wins[n]:= win;
        RETURN TRUE
      END
    END;
    RETURN FALSE
  END Enqueue;

PROCEDURE Dequeue (wdw: CellWindow);
  VAR n: CARDINAL;
  BEGIN
    FOR n:= 0 TO maxWdw DO
      IF wdws[n] = wdw THEN
        wdws[n]:= NIL;
        wins[n]:= WindowBase.NoWindow;
        RETURN
      END
    END;
  END Dequeue;

PROCEDURE FindWdw (win: WindowBase.Window): CellWindow;
  VAR n: CARDINAL;
  BEGIN
    FOR n:= 0 TO maxWdw DO
      IF wins[n] = win THEN
        RETURN wdws[n]
      END
    END;
    RETURN NIL
  END FindWdw;

PROCEDURE CreateCellWindow (VAR wdw            : CellWindow;
                                cellSizeX      : CARDINAL;
                                cellSizeY      : CARDINAL;
                                cellsX0        : CARDINAL;
                                cellsY0        : CARDINAL;
                                infoLine       : BOOLEAN;
                                cellBorders    : BOOLEAN;
                                updateServer   : UpdateCellProc;
                                activateServer : ActivateCellProc;
                                closeServer    : CloseCellWdwProc;
                                serverEnv      : ADDRESS);
  
  VAR baseElems: WindowBase.WdwElemSet;
      spec: WindowBase.WindowSpec;
      p: ADDRESS;
      pw: POINTER TO CellWindow;
      
  BEGIN
    NEW (wdw);
    IF wdw # NIL THEN
      WITH wdw^ DO
        cellEnv:= serverEnv;
        updateCell:= updateServer;
        activateCell:= activateServer;
        closeCellWindow:= closeServer;
        cellW:= cellSizeX;
        cellH:= cellSizeY;
        cellsX:= cellsX0;
        cellsY:= cellsY0;
        drawBorders:= cellBorders;
        suppressUpdate:= 0;
        (*mustNotCopy:= 0;*)
        baseElems:= WindowBase.WdwElemSet {WindowBase.sizeElem,
          WindowBase.moveElem, WindowBase.scrollElem, WindowBase.titleElem};
        IF infoLine THEN INCL (baseElems, WindowBase.infoElem) END;
        IF ADDRESS (closeServer) # NIL THEN INCL (baseElems, WindowBase.closeElem) END;
        WindowBase.CreateWindow (win, baseElems, update, checkSpec,
                                 scrollAmt, activated, close, wdw);
        IF WindowBase.WindowState (win) # WindowBase.okWdw THEN
          DISPOSE (wdw);
          RETURN
        END;
        (* 'env'-Feld in 'Window' finden, da dies unser 'CellWindow' ist *)
        p:= ADDRESS(win);
        winEnvOffs:= 0;
        LOOP
          IF winEnvOffs > 100 THEN HALT END;
          pw:= p+winEnvOffs;
          IF pw^ = wdw THEN EXIT END;
          INC (winEnvOffs, 2)
        END;
        IF ~Enqueue (wdw, win) THEN
          WindowBase.DeleteWindow (win);
          DISPOSE (wdw);
          RETURN
        END;
        WindowBase.GetWindowSpec (win, spec);
        spec.virtual.w := LONG (cellsX) * LONG (cellW) + LONG (cellW) - 1;
        spec.virtual.h := LONG (cellsY) * LONG (cellH) + LONG (cellH) - 1;
        WindowBase.SetWindowSpec (win, spec);
        setPosAndSize (wdw, -1, -1, -1, -1);
      END;(*WITH*)
    END
  END CreateCellWindow;

PROCEDURE SpecifyCellWindow (wdw: CellWindow;
                             cellSizeX, cellSizeY, cellsX0, cellsY0: CARDINAL;
                             cellBorders: BOOLEAN);
  VAR spec: WindowBase.WindowSpec; save: CellPnt; hor, ver: LONGINT;
  BEGIN
    save:= MidCell (wdw);
    WITH wdw^ DO
      IF (cellW # INT(cellSizeX)) OR (cellH # INT(cellSizeY))
      OR (cellsX # INT(cellsX0)) OR (cellsY # INT(cellsY0)) THEN
        INC (suppressUpdate);
        drawBorders:= cellBorders;
        cellW:= cellSizeX;
        cellH:= cellSizeY;
        cellsX:= cellsX0;
        cellsY:= cellsY0;
        WindowBase.GetWindowSpec (win, spec);
        spec.virtual.w := LONG (cellsX) * LONG (cellW) + LONG (cellW) - 1;
        spec.virtual.h := LONG (cellsY) * LONG (cellH) + LONG (cellH) - 1;
        WindowBase.SetWindowSpec (win, spec);
        SetMid (wdw, save);
        FlushEvents ();
        DEC (suppressUpdate);
        WindowBase.RedrawWindow (wdw^.win);
      END;
    END;
  END SpecifyCellWindow;

PROCEDURE DeleteCellWindow (VAR wdw: CellWindow);
  BEGIN
    IF wdw # NIL THEN
      WindowBase.DeleteWindow (wdw^.win);
      Dequeue (wdw);
      DISPOSE (wdw);
    END
  END DeleteCellWindow;

PROCEDURE OpenCellWindow (wdw: CellWindow);
  BEGIN
    IF wdw # NIL THEN
      IF WindowBase.hiddenWdw IN WindowBase.WindowFlags (wdw^.win) THEN
        WindowBase.OpenWindow (wdw^.win);
      ELSIF NOT (WindowBase.topWdw IN WindowBase.WindowFlags (wdw^.win)) THEN
        WindowBase.PutWindowOnTop (wdw^.win);
      END
    END;
  END OpenCellWindow;

PROCEDURE CloseCellWindow (wdw: CellWindow);
  BEGIN
    IF wdw # NIL THEN
      IF NOT (WindowBase.hiddenWdw IN WindowBase.WindowFlags (wdw^.win)) THEN
        WindowBase.CloseWindow (wdw^.win)
      END
    END;
  END CloseCellWindow;

PROCEDURE RedrawCell (wdw   : CellWindow;
                      pos   : CellPnt);
  VAR frame: LongRect;
  BEGIN
    IF wdw # NIL THEN
      frame:= LongRect {LONG(INT(pos.x))*LONG(wdw^.cellW),
                        LONG(INT(pos.y))*LONG(wdw^.cellH),
                        wdw^.cellW, wdw^.cellH};
      WindowBase.UpdateWindow (wdw^.win, update, wdw, frame, WindowBase.noCopyWdw, 0);
    END;
  END RedrawCell;

PROCEDURE Win (wdw: CellWindow): WindowBase.Window;
  BEGIN
    RETURN wdw^.win
  END Win;

PROCEDURE CellWin (win: WindowBase.Window): CellWindow;
  VAR p: POINTER TO CellWindow;
  BEGIN
    IF win # WindowBase.NoWindow THEN
      p:= ADDRESS (win) + winEnvOffs;
      IF p^^.win = win THEN
        RETURN p^
      END;
    END;
    RETURN NIL
  END CellWin;

PROCEDURE SetTopLeft (wdw: CellWindow; cell: CellPnt);
  VAR hor, vert: LONGINT;
  BEGIN
    hor:= INT (LONG (cell.x)) * LONG (wdw^.cellW);
    vert:= INT (LONG (cell.y)) * LONG (wdw^.cellH);
    WindowBase.SetWindowSliderPos (wdw^.win, hor, vert);
    (*
      INC (wdw^.suppressUpdate);
      FlushEvents ();
      DEC (wdw^.suppressUpdate);
      WindowBase.RedrawWindow (wdw^.win);
    *)
  END SetTopLeft;

PROCEDURE TopLeftCell (wdw: CellWindow): CellPnt;
  VAR hor, vert: LONGINT; cell: CellPnt;
  BEGIN
    WindowBase.GetWindowSliderPos (wdw^.win, hor, vert);
    cell.x:= SHORT (hor DIV LONG (wdw^.cellW));
    cell.y:= SHORT (vert DIV LONG (wdw^.cellH));
    RETURN cell
  END TopLeftCell;

PROCEDURE VisibleCells (wdw: CellWindow): CellRect;
  VAR spec: WindowBase.WindowSpec; r: CellRect;
  BEGIN
    WITH wdw^ DO
      WindowBase.GetWindowSpec (win, spec);
      r.x:= SHORT ((spec.visible.x) DIV LONG (cellW));
      r.y:= SHORT ((spec.visible.y) DIV LONG (cellH));
      r.w:= SHORT ((spec.visible.w) DIV LONG (cellW));
      r.h:= SHORT ((spec.visible.h) DIV LONG (cellH));
    END;
    RETURN r
  END VisibleCells;

PROCEDURE MidCell (wdw: CellWindow): CellPnt;
  VAR spec: WindowBase.WindowSpec; cell: CellPnt;
  BEGIN
    WITH wdw^ DO
      WindowBase.GetWindowSpec (win, spec);
      cell.x:= SHORT ((spec.visible.x + spec.visible.w DIV 2) DIV LONG (cellW));
      cell.y:= SHORT ((spec.visible.y + spec.visible.h DIV 2) DIV LONG (cellH));
    END;
    RETURN cell
  END MidCell;

PROCEDURE SetMid (wdw: CellWindow; cell: CellPnt);
  VAR spec: WindowBase.WindowSpec; hor, ver: LONGINT;
  BEGIN
    WITH wdw^ DO
      WindowBase.GetWindowSpec (win, spec);
      hor:= INT (LONG (cell.x+1)) * LONG (wdw^.cellW) - spec.visible.w DIV 2;
      ver:= INT (LONG (cell.y+1)) * LONG (wdw^.cellH) - spec.visible.h DIV 2;
      IF hor < 0 THEN hor:= 0 END;
      IF ver < 0 THEN ver:= 0 END;
      WindowBase.SetWindowSliderPos (win, hor, ver);
    END
  END SetMid;

PROCEDURE DevHdl (): DeviceHandle;
  BEGIN
    RETURN device
  END DevHdl;

PROCEDURE SuppressUpdate (wdw: CellWindow);
  BEGIN
    INC (wdw^.suppressUpdate);
  END SuppressUpdate;

PROCEDURE AllowUpdate (wdw: CellWindow; force: BOOLEAN);
  BEGIN
    DEC (wdw^.suppressUpdate);
    IF force OR (wdw^.suppressUpdate < 0) THEN wdw^.suppressUpdate:= 0 END;
  END AllowUpdate;

PROCEDURE butHdler (clicks: CARDINAL; loc: Point; buts: MButtonSet;
                    keys: SpecialKeySet): BOOLEAN;

  VAR res: WindowBase.DetectWdwResult;
      win: WindowBase.Window;
      wdw: CellWindow;
      x, y: INTEGER;
      frame: Rectangle;
      p: Point;
      ok: BOOLEAN;
      info: ButEvRec;
      
  BEGIN
    WindowBase.DetectWindow (wins, 0, loc, win, res);
    IF res = WindowBase.foundWdwDWR THEN
      wdw:= FindWdw (win);
      IF wdw = NIL THEN HALT END;
      pointToCellPos (wdw, loc, x, y, ok);
      IF ok THEN
        p:= cellToPointPos (wdw, x, y);
        frame:= Rectangle {p.x, p.y, wdw^.cellW, wdw^.cellH};
        info:= ButEvRec {clicks, loc, buts, keys};
        RETURN wdw^.activateCell (wdw, wdw^.cellEnv, CellPnt{x,y},
                        frame, info, device);
      END;
    END;
    RETURN TRUE (* -> Event weitergeben *)
  END butHdler;

VAR wdhandle: WatchDogCarrier;

BEGIN
  stdMFDB.start := NIL;
  InitGem (RC, device, ok);
  IF ok THEN
    gemHdl:= CurrGemHandle ();
  ELSE
    SystemError.OutOfMemory ();
  END;
  InstallWatchDog (wdhandle, EventProc {mouseButton, butHdler});
END View2Dim.
