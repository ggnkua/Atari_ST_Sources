MODULE ListView; (* SJ 4.12.94 *)

(*
 ListView implements a text window where each line can be selected.
 *)


IMPORT
  S:=SYSTEM, WinView, Modl:=Model, LinkedList, Strings, BIOS, Sys, Graf,
  VDI, VC:=VdiControl, VO:=VdiOutput, VA:=VdiAttributes, VQ:=VdiInquiry;



TYPE
  Viewer*   = POINTER TO ViewDesc;
  ViewDesc* = RECORD(WinView.ViewDesc)
  END;

  ElemDesc* = RECORD(LinkedList.ElemDesc)
    selected-: BOOLEAN;
  END;
  Element*  = POINTER TO ElemDesc;

  Model*    = POINTER TO ModelDesc;
  ModelDesc* = RECORD (Modl.Desc)
    elements: LinkedList.Desc;
    longest, total: INTEGER;
  END;



VAR
  station: INTEGER;


(*$-t *)


PROCEDURE (self: Element) ListViewString*(VAR string: ARRAY OF CHAR);
(*
 Must be overridden to answer the string which is to be displayed in the
 viewer.
 *)
 BEGIN
  HALT(Sys.PROTOUSED)
 END ListViewString;


PROCEDURE (self: Element) Selected*(mbut: SET; clicks: INTEGER);
(*
 Called if the receiver was selected by the user. Override.
 *)
 BEGIN
  HALT(Sys.PROTOUSED)
 END Selected;


PROCEDURE (m: Model) Initialize*;
(*
 Initialize the receiver.
 *)
 BEGIN
  m.Initialize^;
  m.elements.Initialize;
  m.longest := 0;
  m.total := 0;
 END Initialize;


PROCEDURE (m: Model) Add*(e: Element);
(*
 Add e at the end of the list. If viewers on that model are
 opened, they will be refreshed.
 *)
  VAR
    len: INTEGER;
    str: ARRAY 200 OF CHAR;
 BEGIN
  e.selected := FALSE;
  m.elements.Add(e);
  INC(m.total);
  e.ListViewString(str);
  len := Strings.Length(str);
  IF m.longest < len THEN m.longest := len END;
  m.Changed( NIL);
 END Add;


PROCEDURE (m: Model) Remove*(e: Element);
(*
 Remove e. Update viewers.
 *)
 BEGIN
  m.elements.Remove(e);
  m.Changed( NIL);
 END Remove;


PROCEDURE (m: Model) Deselect*(e: Element);
(*
 Deselect e and update viewers.
 *)
 BEGIN
  IF e.selected THEN
    e.selected := FALSE;
    m.Changed( NIL);
  END;
 END Deselect;


PROCEDURE (m: Model) Select*(e: Element);
(*
 Select e and update viewers.
 *)
 BEGIN
  IF ~e.selected THEN
    e.selected := TRUE;
    m.Changed( NIL);
  END;
 END Select;


PROCEDURE (m: Model) DeselectAll*();
(*
 All selected elements are deselected and all viewers updated.
 *)

  PROCEDURE~ Deselect(e: LinkedList.Element);
   BEGIN
    e(Element).selected := FALSE;
   END Deselect;

 BEGIN
  m.elements.Do( Deselect);
  m.Changed( WinView.UpdateAll);
 END DeselectAll;


PROCEDURE GetFontData(fontId, fontHeight : INTEGER;
                      VAR dbt, charW, charH : INTEGER);
  VAR
    d,dbb : INTEGER;
    c : CHAR;
 BEGIN
  VA.VstFont(station,fontId);
  VA.VstPoint(station,fontHeight,d,d,d,d);
  VQ.VqtFontinfo(station,c,c,dbb,d,d,d,dbt,charW,d,d,d);
  charH := dbt + dbb + 1;
 END GetFontData;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR
    DistBaseTop, x2, y2, i, d, j : INTEGER;
    maxY, xOff, fw, fh, cpp : INTEGER;

  PROCEDURE~ Draw(e: LinkedList.Element);
    VAR
      str: ARRAY 200 OF CHAR;
   BEGIN
    IF (y2 >= maxY) THEN RETURN^ END;
    IF y2 + fh > y THEN
      WITH e: Element DO
        e.ListViewString(str);
        VO.VGtext(station, xOff, y2 + DistBaseTop, str);
        IF e.selected THEN
          VA.VswrMode(station, VA.EXOR);
          VO.VBar(station, v.x, y2, v.x + v.w - 1, y2 + fh);
          VA.VswrMode(station, VA.REPLACE);
        END;
      END;
    END;
    INC(y2, fh);
   END Draw;

 BEGIN
  v.Redraw^(x, y, w, h);
  x2 := x+w-1; y2 := y+h-1;
  VC.VsClip(station, TRUE, x, y, x2, y2);
  GetFontData( 1, 13, DistBaseTop, fw, fh);
  y2 := v.y - SHORT(v.yOff);
  maxY := y + h;
  xOff := v.x - SHORT(v.xOff);
  cpp := (v.w + SHORT(v.xOff) ) DIV fw + 1;
  v.model(Model).elements.Do( Draw);
 END Redraw;


PROCEDURE(v : Viewer) HandleButtonEvent*(mbut : SET; mx, my, clicks : INTEGER) : BOOLEAN;
  VAR
    row, d, cw, ch : INTEGER;
    selected: LinkedList.Element;
    shift: SET;
    add: BOOLEAN;

  PROCEDURE~ DeselectAll(e: LinkedList.Element);
   BEGIN
    WITH e: Element DO
      IF (e # selected) & e.selected THEN
        e.selected := FALSE;
        v.UpdateRect( v.x, v.y + SHORT( d * ch - v.yOff), v.w, ch);
      END;
    END;
    INC(d);
   END DeselectAll;

  PROCEDURE~ Select(e: LinkedList.Element);
   BEGIN
    IF d = 0 THEN	(* found *)
      selected := e;
      IF ~add THEN
        v.model(Model).elements.Do( DeselectAll);
      END;
      WITH e: Element DO
        e.selected := ~e.selected;
        v.UpdateRect( v.x, v.y + SHORT( row * ch - v.yOff), v.w, ch);
        IF e.selected THEN
          e.Selected(mbut, clicks);
        END;
      END;
      RETURN^ TRUE
    END;
    DEC(d);
   END Select;

 BEGIN
  shift := BIOS.Kbshift(-1);
  add := (0 IN shift) OR (1 IN shift);
  GetFontData( 1, 13, d, cw, ch);
  row := SHORT( (my - v.y + v.yOff) DIV ch);
  d := row;
  v.model(Model).elements.Do( Select);
  RETURN FALSE
 END HandleButtonEvent;


PROCEDURE (v: Viewer) Open*;
  VAR
    d, cw, ch : INTEGER;
 BEGIN
  GetFontData( 1, 13, d, cw, ch);
  v.SetDataWH( v.model(Model).longest * cw, v.model(Model).total * ch);
  v.Open^
 END Open;


PROCEDURE InitMod;
  VAR
    Workin  : VC.workin;
    Workout : VC.workout;
    d : INTEGER;
 BEGIN
  station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1;
  Workin.LineColor := 1; Workin.MarkType := 1;
  Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 1;
  Workin.FillPat := 0; Workin.FillColor := 0;
  Workin.KoorType := 2;
  VC.VOpnvwk(Workin,station,Workout);
  VA.VswrMode(station,VA.REPLACE);
  VA.VsfPerimeter(station,TRUE);
 END InitMod;


BEGIN
  InitMod;
END ListView.