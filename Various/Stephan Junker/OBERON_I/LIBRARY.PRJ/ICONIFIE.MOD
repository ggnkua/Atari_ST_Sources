MODULE IconifiedViewer; (* SJ 25.2.95 *)

(*
 Subclass of WinView.Viewer for iconified windows. Needs only to be
 imported to make iconifying work. The iconified window displays the titles
 of the windows contained in it. If you want to have an icon there, you
 must subclass ViewDesc.
 *)


IMPORT
  S:=SYSTEM, VC:=VDIControl, VO:=VDIOutput, VA:=VDIAttribute,
  LinkedList, WinView, ICFS, Wind, Graf;


TYPE
  ViewElement* = POINTER TO RECORD(LinkedList.ElemDesc)
    viewer-: WinView.Viewer;
  END;

  ViewDesc* = RECORD(WinView.ViewDesc)
    id-: INTEGER;
    viewers-: LinkedList.Desc;
  END;
  Viewer* = POINTER TO ViewDesc;


VAR
  station  : INTEGER;
  cellWidth, cellHeight: INTEGER;


PROCEDURE (v: Viewer) Initialize*;
 BEGIN
  v.Initialize^;
  v.viewers.Initialize;
  v.elements := {Wind.TITLE, Wind.CLOSER, Wind.MOVER};
  v.SetTitle("Icon");
 END Initialize;


PROCEDURE (v: Viewer) Open*;
 BEGIN
  v.id := ICFS.GetPos(v.x, v.y, v.w, v.h);
  IF v.id < 0 THEN HALT(90) END;
  v.Open^;
 END Open;


PROCEDURE (v: Viewer) Close*;
 BEGIN
  v.id := ICFS.FreePos(v.id);
  IF v.id < 0 THEN HALT(90) END;
  v.Close^;
 END Close;


PROCEDURE (v: Viewer) Redraw*(x, y, w, h: INTEGER);
  VAR
    x2, y2: INTEGER;

  PROCEDURE ~DrawTitle(e: LinkedList.Element);
   BEGIN
     VO.VGtext(station, v.x + 5, y2, e(ViewElement).viewer.title);
     INC(y2, cellHeight);
   END DrawTitle;

 BEGIN
  v.Redraw^(x, y, w, h);
  VC.VsClip(station, TRUE, x, y, x+w-1, y+h-1);
  y2 := v.y + 10; x2 := v.x + 5;
  v.viewers.Do( DrawTitle);
 END Redraw;


PROCEDURE(v : Viewer) Snap*;
  VAR
    d: INTEGER;
 BEGIN
  d := ICFS.Snap( v.id, v.x, v.y);
 END Snap;


PROCEDURE(v : Viewer) HandleButtonEvent*(mbut : SET; mx, my, clicks : INTEGER) : BOOLEAN;

  PROCEDURE ~Reopen(e: LinkedList.Element);
   BEGIN
    e(ViewElement).viewer.Open;
   END Reopen;

 BEGIN
  v.viewers.Do( Reopen);
  v.Close;
  RETURN TRUE
 END HandleButtonEvent;


PROCEDURE AddViewer(VAR list: LinkedList.Desc; viewer: WinView.Viewer);
  VAR
    e: ViewElement;
    d: INTEGER;
 BEGIN
  IF viewer.opened THEN
    NEW(e); e.viewer := viewer;
    list.Add(e);
    IF viewer IS Viewer THEN
      d := ICFS.FreePos(viewer(Viewer).id);
    END;
(*    Wind.Close(viewer.handle); viewer.opened := FALSE;*)
    viewer.Close;
  END;
 END AddViewer;


PROCEDURE Iconify(v: WinView.Viewer; all, inOne: BOOLEAN);
  VAR
    iv: Viewer;
 BEGIN
  IF all THEN
    IF inOne THEN
      NEW(iv); iv.Initialize;
      REPEAT
        AddViewer(iv.viewers, v);
        v := v.nextWin;
      UNTIL v = NIL;
      iv.Open;
    ELSE
      REPEAT
        IF v.opened THEN
          NEW(iv); iv.Initialize;
          AddViewer(iv.viewers, v);
          iv.Open;
        END;
        v := v.nextWin;
      UNTIL v = NIL;
    END;
  ELSE
    NEW(iv); iv.Initialize;
    AddViewer(iv.viewers, v);
    iv.Open;
  END;
 END Iconify;


PROCEDURE InitMod;
  VAR
    d : INTEGER;
    Workin : VC.workin;
    Workout: VC.workout;
 BEGIN
  station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0; Workin.FillPat := 4;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VC.VOpnvwk(Workin,station,Workout);
  VA.VswrMode(station,VA.REPLACE);
  VA.VsfPerimeter(station,FALSE);
  VC.VsClip(station, FALSE, 0, 0, 0, 0);
  VA.VstPoint(station, 8, d, d, cellWidth, cellHeight);
  WinView.Iconify := Iconify;
 END InitMod;


BEGIN
  InitMod
END IconifiedViewer.