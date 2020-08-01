MODULE WinView; (* SJ 31.10.93 / 7.12.94 *)

(*
 WinView implements viewers which are displayed using standard AES
 windows. Most window functions are served automatically, but they can
 of course be overridden if a service doesn't meet your specification.

 An ACCLOSE message is reacted on by closing and deleting the windows.
 The viewers, however, remain present and can be reopened later. The
 message event is not deleted in the event record so that other handlers
 will receive this message, too. Other handlers must work the same way.
 *)

(*
 WinView has been changed to work with the new implementation of GemApp.
 *)


IMPORT
  S:=SYSTEM, AES, Model, GemApp, Wind, Graf, Evnt, VR:=VDIRaster, Sys,
  VC:=VDIControl, VO:=VDIOutput, VA:=VDIAttribute, LinkedList, Task,
  BIOS, ModelList;



CONST
  UpdateAll* = NIL; (* aspect: update everything *)



TYPE
  Viewer*      = POINTER TO ViewDesc;
  ViewDesc*    = RECORD(Model.DependDesc)
    nextWin-    : Viewer;
    handle-     : INTEGER;
    elements-   : SET;
    opened-     : BOOLEAN;
    x-,y-,w-,h- : INTEGER; (* position and size of work space *)
    fx-,fy-,fw-,fh- : INTEGER; (* maximum size *)
    xOff-,yOff- : LONGINT; (* offset in pixels *)
    lSize-,cSize-:INTEGER; (* pixels per line/column *)
    dw-,dh-     : LONGINT; (* width and height of data in pixels *)
    title-,info-: ARRAY 160 OF CHAR;
    children-   : LinkedList.Desc;
    parent-     : Viewer;
    traces      : ModelList.Desc;
    trace       : BOOLEAN;
    wasopened   : BOOLEAN;
  END;

  RectProc     = PROCEDURE (v : Viewer; x,y,w,h : INTEGER);



VAR
  Windows- : Viewer; (* the list of viewers *)
  minYPos- : INTEGER;

  Iconify*: PROCEDURE (v: Viewer; all, inOne: BOOLEAN);
  (*
   Executed to iconify one or all windows. Implemented in module
   IconifiedViewer. If not linked, no iconify works.
   *)

  Station  : INTEGER;
  Workout  : VC.workout;

  size     : INTEGER;



PROCEDURE(v : Viewer) Redraw*(x,y,w,h : INTEGER);
(*
 This procedure redraws the rectangle x,y,w,h (absolute) in viewer v.
 *)
 BEGIN
  VO.VBar( Station, x, y, x+w-1, y+h-1 );
 END Redraw;


PROCEDURE(v : Viewer) Snap*;
(*
 corrects the size and coordinates to certain rastered values.
 Override if desired. Default: Do nothing.
 *)
 BEGIN
 END Snap;


PROCEDURE(v : Viewer) VSlider*;
(*
 sets the vertical slider according to the values in v.dh and v.yOff.
 Override if this is not what you desire
 *)
 BEGIN
  IF v.opened THEN
    IF v.dh > v.h THEN
      Wind.SetVal( v.handle, Wind.VSLSIZE, SHORT( LONG(v.h) * 1000 DIV v.dh) );
      Wind.SetVal( v.handle, Wind.VSLIDE, SHORT( v.yOff * 999 DIV (v.dh - v.h) + 1 ));
    ELSE
      Wind.SetVal( v.handle, Wind.VSLSIZE, 1000);
      Wind.SetVal( v.handle, Wind.VSLIDE ,1)
    END(*IF*);
  END;
 END VSlider;


PROCEDURE(v : Viewer) HSlider*;
(*
 sets the horizontal slider according to the values in v.dw and v.xOff.
 Override if this is not what you desire
 *)
 BEGIN
  IF v.opened THEN
    IF v.dw > v.w THEN
      Wind.SetVal( v.handle, Wind.HSLSIZE, SHORT( LONG(v.w) * 1000 DIV v.dw) );
      Wind.SetVal( v.handle, Wind.HSLIDE, SHORT( v.xOff * 999 DIV (v.dw - v.w) + 1));
    ELSE
      Wind.SetVal( v.handle, Wind.HSLSIZE, 1000);
      Wind.SetVal( v.handle, Wind.HSLIDE ,1)
    END(*IF*);
  END;
 END HSlider;


PROCEDURE(v : Viewer) Fulled*;
(*
 sets the size of the window to full size or, if it has already full
 size, to the size it had before
 *)
  VAR fx,fy,fw,fh,cx,cy,cw,ch : INTEGER;
 BEGIN
  Wind.GetXYWH(v.handle,Wind.FULL,fx,fy,fw,fh);
  Wind.Calc(Wind.WORKSP,v.elements,fx,fy,fw,fh,fx,fy,fw,fh);
  v.x := fx; v.y := fy; v.w := fw; v.h := fh;
  v.Snap;
  Wind.GetXYWH(v.handle,Wind.WORK,cx,cy,cw,ch);
  IF (cx = v.x) AND (cy = v.y) AND (cw = v.w) AND (ch = v.h) THEN
    Wind.GetXYWH(v.handle,Wind.PREV,fx,fy,fw,fh);
    Wind.Calc(Wind.WORKSP,v.elements,fx,fy,fw,fh,v.x,v.y,v.w,v.h);
    v.Snap;
  END(*IF*);
  Wind.Calc(Wind.WHOLE,v.elements,v.x,v.y,v.w,v.h,fx,fy,fw,fh);
  Wind.SetCurr(v.handle,fx,fy,fw,fh);
  v.HSlider; v.VSlider;
 END Fulled;


PROCEDURE Overlap(VAR X,Y,W,H : INTEGER; x,y,w,h : INTEGER) : BOOLEAN;
 BEGIN
  IF X + W > x + w THEN W := x + w - X; END(*IF*);
  IF Y + H > y + h THEN H := y + h - Y; END(*IF*);
  IF X < x THEN W := X + W - x; X := x; END(*IF*);
  IF Y < y THEN H := Y + H - y; Y := y; END(*IF*);
  RETURN (W >= 1) AND (H >= 1)
 END Overlap;


PROCEDURE RectRedraw(v : Viewer; x,y,w,h : INTEGER);
 BEGIN
  v.Redraw(x,y,w,h);
 END RectRedraw;


PROCEDURE RectList(v : Viewer; x,y,w,h : INTEGER; work : RectProc);
  VAR
    X,Y,W,H : INTEGER;
 BEGIN
  IF v.opened THEN
    Graf.HideMouse;
    Wind.Update(Wind.BEGUPD); Wind.GetXYWH(v.handle,Wind.FIRST,X,Y,W,H);
    WHILE W # 0 DO
      IF Overlap(X,Y,W,H,x,y,w,h) THEN work(v,X,Y,W,H); END(*IF*);
      Wind.GetXYWH(v.handle,Wind.NEXT,X,Y,W,H);
    END(*WHILE*);
    Wind.Update(Wind.ENDUPD); Graf.ShowMouse;
  END;
 END RectList;


PROCEDURE(v: Viewer) UpdateRect*(x,y,w,h : INTEGER);
(*
 calls v.Redraw in order to redraw the rectangle x,y,w,h.
 Window update is switched on and the mouse is invisible.
 *)
 BEGIN
  RectList(v, x,y,w,h, RectRedraw);
 END UpdateRect;


PROCEDURE(v : Viewer) Update*(aspect : Model.Aspect);
(*
 calls v.UpdateRect with the whole window as rectangle. aspect is
 ignored
 *)
 BEGIN
  v.UpdateRect( v.x, v.y, v.w, v.h );
 END Update;


PROCEDURE(v : Viewer) PageUp*;
(*
 displays the data of the previous page
 *)
 BEGIN
  IF v.yOff > 0 THEN
    DEC( v.yOff, v.h); (* one page up *)
    IF v.yOff < 0 THEN v.yOff := 0 END;
    v.Update( UpdateAll);
    v.VSlider;
  END;
 END PageUp;


PROCEDURE(v : Viewer) PageDown*;
(*
 displays the data of the next page
 *)
  VAR Max : LONGINT;
 BEGIN
  Max := v.dh - v.h;
  IF v.yOff < Max THEN
    INC( v.yOff, v.h); (* one page down *)
    IF v.yOff > Max THEN v.yOff := Max END;
    v.Update( UpdateAll);
    v.VSlider;
  END;
 END PageDown;


PROCEDURE(v : Viewer) PageLeft*;
(*
 displays the data of the page to the left
 *)
 BEGIN
  IF v.xOff > 0 THEN
    DEC( v.xOff, v.w); (* one page left *)
    IF v.xOff < 0 THEN v.xOff := 0 END;
    v.Update( UpdateAll);
    v.HSlider
  END;
 END PageLeft;


PROCEDURE(v : Viewer) PageRight*;
(*
 displays the data of the page to the right
 *)
  VAR Max : LONGINT;
 BEGIN
  Max := v.dw - v.w;
  IF v.xOff < Max THEN
    INC( v.xOff, v.w); (* one page down *)
    IF v.xOff > Max THEN v.xOff := Max END;
    v.Update( UpdateAll);
    v.HSlider
  END;
 END PageRight;


PROCEDURE GetViewer*(handle : INTEGER; VAR v : Viewer) : BOOLEAN;
(*
 returns true if the viewer with the AES handle is found
 *)
  VAR vi : Viewer;
 BEGIN
  vi := Windows;
  WHILE vi # NIL DO
    IF vi.handle = handle THEN v := vi; RETURN TRUE END;
    vi := vi.nextWin
  END;
  RETURN FALSE;
 END GetViewer;


PROCEDURE GetTop*(VAR v : Viewer) : BOOLEAN;
(*
 returns the current top viewer. If there is no viewer, false is
 returned
 *)
  VAR handle : INTEGER;
 BEGIN
  RETURN Wind.GetTop(handle) AND GetViewer(handle,v)
 END GetTop;


PROCEDURE(v : Viewer) IsTop*() : BOOLEAN;
(*
 returns true if v is the current top viewer
 *)
  VAR handle : INTEGER;
 BEGIN
  RETURN Wind.GetTop(handle) AND (handle = v.handle);
 END IsTop;


PROCEDURE ScrollDown(v : Viewer; x,y,w,h : INTEGER);
 BEGIN
  IF h > size THEN
    VR.ScrollDown( Station, x, y, x+w-1, y+h-1, size );
    v.Redraw( x, y, w, size );
  ELSE
    v.Redraw( x, y, w, h );
  END;
 END ScrollDown;


PROCEDURE(v : Viewer) LineUp*;
(*
 displays the data of the previous line
 *)
 BEGIN
  IF v.yOff > 0 THEN
    size := v.lSize;
    IF v.yOff < size THEN DEC(size, size - SHORT(v.yOff)) END;
    DEC( v.yOff, size); (* one line up *)
    RectList(v, v.x, v.y, v.w, v.h, ScrollDown);
    v.VSlider;
  END;
 END LineUp;


PROCEDURE ScrollUp(v : Viewer; x,y,w,h : INTEGER);
 BEGIN
  IF h > size THEN
    VR.ScrollUp( Station, x, y, x+w-1, y+h-1, size );
    v.Redraw( x, y+h-size, w, size );
  ELSE
    v.Redraw( x, y, w, h );
  END;
 END ScrollUp;


PROCEDURE(v : Viewer) LineDown*;
(*
 displays the data of the next line
 *)
  VAR Max : LONGINT;
 BEGIN
  Max := v.dh - v.h;
  IF v.yOff < Max THEN
    size := v.lSize;
    IF v.yOff+size > Max THEN DEC(size, SHORT(v.yOff+size - Max)) END;
    INC( v.yOff, size); (* one line down *)
    RectList(v, v.x, v.y, v.w, v.h, ScrollUp);
    v.VSlider;
  END;
 END LineDown;


PROCEDURE ScrollRight(v : Viewer; x,y,w,h : INTEGER);
 BEGIN
  IF w > size THEN
    VR.ScrollRight( Station, x, y, x+w-1, y+h-1, size );
    v.Redraw( x, y, size, h);
  ELSE
    v.Redraw( x, y, w, h );
  END;
 END ScrollRight;


PROCEDURE(v : Viewer) ColLeft*;
(*
 displays the data one column to the left
 *)
 BEGIN
  IF v.xOff > 0 THEN
    size := v.cSize;
    IF v.xOff < size THEN DEC(size, size - SHORT(v.xOff)) END;
    DEC( v.xOff, size); (* one col left *)
    RectList(v, v.x, v.y, v.w, v.h, ScrollRight);
    v.HSlider
  END;
 END ColLeft;


PROCEDURE ScrollLeft(v : Viewer; x,y,w,h : INTEGER);
 BEGIN
  IF w > size THEN
    VR.ScrollLeft( Station, x, y, x+w-1, y+h-1, size );
    v.Redraw( x+w-size, y, size, h);
  ELSE
    v.Redraw( x, y, w, h );
  END;
 END ScrollLeft;


PROCEDURE(v : Viewer) ColRight*;
(*
 displays the data one column to the right
 *)
  VAR Max : LONGINT;
 BEGIN
  Max := v.dw - v.w;
  IF v.xOff < Max THEN
    size := v.cSize;
    IF v.xOff+size > Max THEN DEC(size, SHORT(v.xOff+size - Max)) END;
    INC( v.xOff, size); (* one col right *)
    RectList(v, v.x, v.y, v.w, v.h, ScrollLeft);
    v.HSlider
  END;
 END ColRight;


PROCEDURE(v : Viewer) Open*;
(*
 opens a window at x,y with size w,h as defined in the viewer. Those values
 refer to the size of the work area! If opening fails, an error message is
 shown and v.opened will be FALSE.
 If you do not return to the event loop immediately, you have to call
 v.Update( WinView.UpdateAll) since the open method will not redraw it.
 This is because opening is followed by a redraw message and two redraws
 would be done if Open would call it.
 *)
  VAR x,y,w,h : INTEGER;
 BEGIN
  IF v.opened THEN
    Wind.SetTop(v.handle);
  ELSIF Wind.Create(v.elements,v.fx,v.fy,v.fw,v.fh,v.handle) THEN
    v.Snap;
    Wind.Calc(Wind.WHOLE,v.elements,v.x,v.y,v.w,v.h,x,y,w,h);
    Wind.SetAddress( v.handle, Wind.NAME, S.ADR( v.title) );
    Wind.SetAddress( v.handle, Wind.INFO, S.ADR( v.info) );
    Wind.Open(v.handle,x,y,w,h);
    v.opened := TRUE;
    v.HSlider; v.VSlider;
    v.nextWin := Windows; Windows := v;
  END;
 END Open;


PROCEDURE(v : Viewer) Close*;
(*
 closes the window defined by v. Closing implies deleting from the sight of
 the AES, so the window handle will be available again. However, the
 contents of v is untouched and the viewer may be opened again without any
 changing
 *)
  VAR
    shift: SET;
    vi, pv: Viewer;
 BEGIN
  IF v.opened THEN
    IF v.trace & ~v.traces.IsEmpty() THEN
      shift := BIOS.Kbshift(-1);
      IF shift = {Evnt.LSHIFT, Evnt.ALTERNATE} THEN (* next model *)
        v.SetModel( v.traces.FirstModel() );
        RETURN;
      ELSIF shift = {Evnt.LSHIFT, Evnt.CONTROL} THEN (* previous model *)
        v.SetModel( v.traces.LastModel() );
        RETURN;
      END;
    END;
    Wind.Close(v.handle); Wind.Delete(v.handle); v.opened := FALSE;
    v.handle := -1;
    vi := Windows; pv := NIL;
    WHILE (vi # NIL) & (vi # v) DO
      pv := vi; vi := vi.nextWin;
    END;
    IF vi # NIL THEN
      IF pv = NIL THEN
        Windows := v.nextWin
      ELSE
        pv.nextWin := v.nextWin
      END;
    END;
  END;
 END Close;


PROCEDURE(v : Viewer) SetPos*(x,y : INTEGER);
(*
 sets the position of viewer v. The viewer is redrawn at the new position
 *)
  VAR w,h : INTEGER;
 BEGIN
  v.x := x; v.y := y;
  v.Snap;
  IF v.opened THEN
    Wind.Calc(Wind.WHOLE, v.elements, v.x, v.y, v.w, v.h, x, y, w, h);
    Wind.SetCurr(v.handle, x, y, w, h)
  END;
 END SetPos;


PROCEDURE(v : Viewer) SetSize*(w,h : INTEGER);
(*
 sets the size of viewer v. The viewer is redrawn with the new size
 *)
   VAR x,y : INTEGER;
 BEGIN
  IF w > Workout.MaxX THEN w := Workout.MaxX END;
  IF h > Workout.MaxY-minYPos THEN h := Workout.MaxY-minYPos END;
  v.w := w; v.h := h;
  v.Snap;
  IF v.opened THEN
    Wind.Calc(Wind.WHOLE, v.elements, v.x, v.y, v.w, v.h, x, y, w, h);
    Wind.SetCurr(v.handle, x, y, w, h);
    v.VSlider; v.HSlider;
  END;
 END SetSize;


PROCEDURE(v : Viewer) SetElements*(elements : SET);
(*
 sets the window elements of viewer v. The viewer is redrawn with the new
 elements
 *)
 BEGIN
  v.elements := elements;
  IF v.opened THEN Wind.SetElements(v.handle,elements) END;
 END SetElements;


PROCEDURE(v : Viewer) SetFullSize*(fx,fy,fw,fh : INTEGER);
(*
 sets the maximum size of a viewer. This size is used if the window is to
 be fulled. This setting has no direct affect on the viewer.
 *)
 BEGIN
  v.fx := fx; v.fy := fy; v.fw := fw; v.fh := fh;
 END SetFullSize;


PROCEDURE(v : Viewer) SetOffset*(xOff,yOff : LONGINT);
(*
 sets the offset in x and y direction. The offset defines the number of
 pixels invisible at the left and upper margin and tells the redraw
 procedure where to start with the redraw. These values are changed by the
 procedures which react on WM_ARROW and WM_xSLID messages. The contents of
 the viewer is redrawn immediately
 *)
 BEGIN
  v.xOff := xOff; v.yOff := yOff;
  IF v.opened THEN v.Update( UpdateAll); v.VSlider; v.HSlider END;
 END SetOffset;


PROCEDURE(v : Viewer) SetLCSize*(lSize,cSize : INTEGER);
(*
 sets the size of a line and a column in pixels. These values are used by
 the procedures reacting on WM_ARROW in order to shift the contents. This
 setting has no direct affect on the viewer.
 *)
 BEGIN
  v.lSize := lSize; v.cSize := cSize;
 END SetLCSize;


PROCEDURE(v : Viewer) SetDataWH*(dw,dh : LONGINT);
(*
 sets the size of the whole data to display in pixels. These values are
 used by the procedures which set the horizontal and vertical sliders. Both
 are redrawn after this setting
 *)
 BEGIN
  v.dw := dw; v.dh := dh;
  IF v.opened THEN v.HSlider; v.VSlider END;
 END SetDataWH;


PROCEDURE(v : Viewer) SetTitle*(title : ARRAY OF CHAR);
(*
 sets the title of the window
 *)
 BEGIN
  COPY( title, v.title);
  IF v.opened THEN
    Wind.SetAddress( v.handle, Wind.NAME, S.ADR( v.title) );
  END;
 END SetTitle;


PROCEDURE(v : Viewer) HandleKeyEvent*(shiftbits : SET; scancode : INTEGER;
                                      char : CHAR) : BOOLEAN;
(*
 is called if a key is pressed and v is the top window. It reacts on some
 standard keys to scroll the window, override for others. If a key is
 responded to, return true in order to clear the event.
 *)
 BEGIN
  IF shiftbits = {Evnt.LSHIFT} THEN
    CASE scancode OF
      48H: v.PageUp |
      50H: v.PageDown |
      4BH: v.PageLeft |
      4DH: v.PageRight |
    ELSE RETURN FALSE
    END;
  ELSIF shiftbits = {Evnt.CONTROL} THEN
    IF (scancode = 16H) THEN v.Close
    ELSIF scancode = 39H THEN Iconify(v, FALSE, FALSE)
    ELSE RETURN FALSE
    END;
  ELSIF shiftbits = {Evnt.CONTROL,Evnt.LSHIFT} THEN
    CASE scancode OF
      48H: v.LineUp |
      50H: v.LineDown |
      4BH: v.ColLeft |
      4DH: v.ColRight |
      21H: v.Fulled |
      2EH: v.Close |
      39H: Iconify(Windows, TRUE, TRUE) |
    ELSE RETURN FALSE
    END;
  ELSIF shiftbits = {} THEN
    CASE scancode OF
      48H: v.LineUp |
      50H: v.LineDown |
      4BH: v.ColLeft |
      4DH: v.ColRight |
      21H: v.Fulled |
      2EH,61H: v.Close |
    ELSE RETURN FALSE
    END;
  ELSE RETURN FALSE
  END;
  RETURN TRUE;
 END HandleKeyEvent;


PROCEDURE(v : Viewer) Topped*;
(*
 called if the user wants to top viewer v
 *)
 BEGIN
  Wind.SetTop( v.handle);
 END Topped;


PROCEDURE(v : Viewer) UnTopped*;            (* CF *)
 BEGIN
  Wind.UnTop( v.handle);
 END UnTopped;


PROCEDURE(v : Viewer) HSlid*(pos : INTEGER);
(*
 called if the user slided the horizontal slider to position Pos
 *)
 BEGIN
  v.SetOffset( pos * (v.dw-v.w) DIV 1000, v.yOff)
 END HSlid;


PROCEDURE(v : Viewer) VSlid*(pos : INTEGER);
(*
 called if the user slided the vertical slider to position Pos
 *)
 BEGIN
  v.SetOffset( v.xOff, pos * (v.dh-v.h) DIV 1000)
 END VSlid;


PROCEDURE(v : Viewer) Sized*(newW, newH : INTEGER);
(*
 called if the user changed the size of viewer v to newW, newH
 *)
  VAR x,y,w,h : INTEGER;
 BEGIN
  Wind.Calc(Wind.WORKSP,v.elements,v.x,v.y,newW,newH,x,y,w,h);
  IF w > v.fw THEN w := v.fw END;
  IF h > v.fh THEN h := v.fh END;
  v.SetSize( w, h)
 END Sized;


PROCEDURE(v : Viewer) Moved*(newX, newY : INTEGER);
(*
 called if the user moved viewer v to position newX, newY
 *)
  VAR x,y,w,h : INTEGER;
 BEGIN
  Wind.Calc(Wind.WORKSP,v.elements,newX,newY,v.w,v.h,x,y,w,h);
  v.SetPos( x, y)
 END Moved;


PROCEDURE(v : Viewer) HandleMsgEvent*(VAR msgBuf : Evnt.msgbuf) : BOOLEAN;
(*
 is called if a message is received which concerns the viewer v. The
 messages WMREDRAW, WMTOPPED, WMCLOSED, WMFULLED, WMARROWED, WMHSLID,
 WMVSLID, WMSIZED and WMMOVED are serviced. Override for other messages
 *)
 BEGIN
  CASE msgBuf[0] OF
    Evnt.WMREDRAW:
      v.UpdateRect( msgBuf[4], msgBuf[5], msgBuf[6], msgBuf[7]) |
    Evnt.WMBOTTOM:                          (* CF *)
      v.UnTopped |
    Evnt.WMTOPPED:
      v.Topped |
    Evnt.WMCLOSED:
      IF Evnt.ALTERNATE IN GemApp.shiftbits THEN
        Iconify(v, FALSE, FALSE);
      ELSIF Evnt.CONTROL IN GemApp.shiftbits THEN
        Iconify(Windows, TRUE, TRUE)
      ELSIF Evnt.LSHIFT IN GemApp.shiftbits THEN
        Iconify(Windows, TRUE, FALSE)
      ELSE
        v.Close
      END |
    Evnt.WMFULLED:
      v.Fulled |
    Evnt.WMARROWED:
      CASE msgBuf[4] OF
        0: v.PageUp |
        1: v.PageDown |
        2: v.LineUp |
        3: v.LineDown |
        4: v.PageLeft |
        5: v.PageRight |
        6: v.ColLeft |
        7: v.ColRight |
      END |
    Evnt.WMHSLID:
      v.HSlid(msgBuf[4]) |
    Evnt.WMVSLID:
      v.VSlid(msgBuf[4]) |
    Evnt.WMSIZED:
      v.Sized( msgBuf[6], msgBuf[7]) |
    Evnt.WMMOVED:
      v.Moved( msgBuf[4], msgBuf[5]) |
  ELSE
  END;
  RETURN TRUE
 END HandleMsgEvent;


PROCEDURE(v : Viewer) HandleMouseEvent*(mbut : SET; mx, my, clicks : INTEGER) : BOOLEAN;
(*
 Is called if a mouse event occurred in the work area of viewer v.
 Must return true if the event should not be distributed further.
 A mouse event occurs on every movement of the mouse.
 Default: Do nothing.
 *)
 BEGIN
  RETURN FALSE
 END HandleMouseEvent;


PROCEDURE(v : Viewer) HandleButtonEvent*(mbut : SET; mx, my, clicks : INTEGER) : BOOLEAN;
(*
 Is called if a mouse event occurred in the work area of viewer v.
 Must return true if the event should not be distributed further.
 A mouse event occurs button clicks.
 Default: Do nothing.
 *)
 BEGIN
  RETURN FALSE
 END HandleButtonEvent;


PROCEDURE(v : Viewer) Initialize*;
(*
 Intializes a new viewer. It is stored in a list, so don't dispose its
 memory! The fields are initialized as follows: handle = -1, x = fx = 0, y
 = fy = minY, w = 620, h = = 340, fw = maxX + 1, fh = maxY + 1 - minY,
 opened = FALSE, xPos = 0, yPos = 0, lSize = 16, cSize = 8, elements = all
 elements, title = "Untitled", info = "".
  *)
 BEGIN
  v.Initialize^;
  v.elements := {Wind.TITLE, Wind.CLOSER, Wind.FULLER, Wind.MOVER,
                 Wind.SIZER, Wind.UPARROW, Wind.DNARROW, Wind.VSLIDER,
                 Wind.LFARROW, Wind.RTARROW, Wind.HSLIDER};
  v.handle := -1; v.x := 0; v.y := minYPos; v.w := 620; v.h := 340;
  v.fx := 0; v.fy := 19;
  v.fw := Workout.MaxX + 1; v.fh := Workout.MaxY - 18;
  v.opened := FALSE; v.xOff := 0; v.yOff := 0;
  v.lSize := 16; v.cSize := 8; v.dw := 620; v.dh := 340;
  v.title := "Untitled"; v.info := "";
  v.children.Initialize;
  v.parent := NIL;
  v.traces.Initialize;
  v.trace := FALSE;
 END Initialize;


PROCEDURE (v: Viewer) Init*;
 BEGIN
  HALT(199);
 END Init;


PROCEDURE(v : Viewer) Remove*;
(*
 removes v from the viewer list and disposes its memory. It will be
 closed if open.
 *)
  VAR v2,v3 : Viewer;
 BEGIN
  IF v.model # NIL THEN
    v.model.RemoveDependant(v);
  END;
  IF v.opened THEN v.Close END;
  IF Windows = v THEN Windows := Windows.nextWin;
    S.DISPOSE(v)
  ELSIF Windows # NIL THEN
    v2 := Windows.nextWin; v3 := Windows;
    WHILE v2 # NIL DO
      IF v2 = v THEN
        v3.nextWin := v.nextWin;
        S.DISPOSE(v); RETURN
      END;
      v3 := v2; v2 := v2.nextWin;
    END;
  END;
 END Remove;


PROCEDURE CloseAll*;
(*
 closes all windows. This can be used before calling a program
 *)
  VAR
    v : Viewer;
 BEGIN
  v := Windows;
  WHILE v # NIL DO
    v.wasopened := v.opened;
    IF v.opened THEN v.Close END;
    v := v.nextWin;
  END;
 END CloseAll;


PROCEDURE OpenAll*;
(*
 opens all windows again which were closed by CloseAll. OpenAll may only be
 called after CloseAll. This can be used after calling a program
 *)
  VAR v : Viewer;
 BEGIN
  v := Windows;
  WHILE v # NIL DO
    IF v.wasopened THEN v.Open END;
    v := v.nextWin;
  END;
 END OpenAll;


PROCEDURE (v: Viewer) SetTrace*(set: BOOLEAN);
(*
 If set = TRUE, switch tracing on, else switch it off and release all
 models. When tracing, the current model is stored in a list when a new
 model is assigned to the viewer. The the user can switch back to the
 previous model selecting the close button with the shift key pressed. He
 can switch to the next model by pressing the alternate key when selecting
 the close button. The current trace list is cleared.
 *)
 BEGIN
  v.traces.Initialize;
  v.trace := set;
 END SetTrace;


PROCEDURE (self: Viewer) SetModel*(m: Model.Ptr);
(*
 Set the model of the viewer. This causes an Update(NIL) message.
 *)
 BEGIN
  IF self.trace & (self.model # NIL) THEN
    self.traces.AddModel(self.model);
  END;
  self.SetModel^(m);
  self.traces.RemoveModel(m);
 END SetModel;


PROCEDURE MouseEvent() : BOOLEAN;
  VAR
    v: Viewer;
    handle: INTEGER;
 BEGIN
  IF Wind.Find( GemApp.mx, GemApp.my, handle) AND GetViewer( handle, v) THEN
    RETURN v.HandleMouseEvent(GemApp.buttons, GemApp.mx, GemApp.my, GemApp.clicks);
  END;
  RETURN FALSE
 END MouseEvent;


PROCEDURE ButtonEvent() : BOOLEAN;
  VAR
    v: Viewer;
    handle: INTEGER;
 BEGIN
  IF Wind.Find( GemApp.mx, GemApp.my, handle) AND GetViewer( handle, v) THEN
    RETURN v.HandleButtonEvent(GemApp.buttons, GemApp.mx, GemApp.my, GemApp.clicks);
  END;
  RETURN FALSE
 END ButtonEvent;


PROCEDURE KeyboardEvent() : BOOLEAN;
  VAR
    v: Viewer;
 BEGIN
  IF GetTop(v) THEN
    RETURN v.HandleKeyEvent(GemApp.shiftbits, GemApp.scancode, GemApp.character)
  END;
  RETURN FALSE
 END KeyboardEvent;


PROCEDURE MessageEvent() : BOOLEAN;
  VAR
    v: Viewer;
 BEGIN
  IF (GemApp.message[0] >= 20) & (GemApp.message[0] <= 39)
      & GetViewer( GemApp.message[3], v) THEN
    RETURN v.HandleMsgEvent(GemApp.message);
  END;
  RETURN FALSE
 END MessageEvent;


PROCEDURE RemoveAll();
 BEGIN
  IF (Task.level = 0) OR (Task.level = 1) & Sys.Loader THEN
    WHILE Windows # NIL DO Windows.Close END;
  END;
 END RemoveAll;


PROCEDURE NoIconify(v: Viewer; all, inOne: BOOLEAN);
 END NoIconify;


PROCEDURE GetTDP(v: Viewer) : S.PTR;
 BEGIN
  ASSEMBLER
    MOVE.L  v,A0
    MOVE.L  -4(A0),D0
    UNLK    A6
    RTS
  END;
 END GetTDP;


PROCEDURE RemoveProcs(from, to: S.PTR) : BOOLEAN;
  VAR
    v: Viewer;
    tdp: S.PTR;
 BEGIN
  IF (S.VAL( S.PTR, Iconify) >= from) & (S.VAL( S.PTR, Iconify) < to) THEN
    Iconify := NoIconify
  END;
  v := Windows;
  WHILE v # NIL DO
    tdp := GetTDP(v);
    IF (S.VAL( S.PTR, tdp) >= from) & (S.VAL( S.PTR, tdp) < to) THEN
      v.Close
    END;
    v := v.nextWin;
  END;
  RETURN TRUE
 END RemoveProcs;


PROCEDURE InitWinView;
  VAR
    d : INTEGER;
    Workin : VC.workin;
 BEGIN
  Task.StoreExit( RemoveAll);
  GemApp.mouseProcs.AddProc( MouseEvent);
  GemApp.buttonProcs.AddProc( ButtonEvent);
  GemApp.keyboardProcs.AddProc( KeyboardEvent);
  GemApp.messageProcs.AddProc( MessageEvent);

  Wind.Calc( Wind.WORKSP, {Wind.TITLE, Wind.MOVER},
             0, 19, 100, 100, d, minYPos, d, d);
  Station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0; Workin.FillPat := 4;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VC.VOpnvwk(Workin,Station,Workout);
  VA.VswrMode(Station,VA.REPLACE);
  VA.VsfPerimeter(Station,FALSE);
  VC.VsClip(Station, FALSE, 0, 0, 0, 0);
  Iconify := NoIconify;
  Task.StoreCodeRemoveProc( RemoveProcs);
 END InitWinView;


BEGIN
  InitWinView;
END WinView.