MODULE Popup;  (* Stephan Junker  8.12.93 *)

(*
 Implementation of popup menus.
 *)

(*$+x *)

IMPORT
  S:=SYSTEM, GemApp, DCL, VC:=VDIControl, VO:=VDIOutput, VA:=VDIAttributes,
  Str:=Strings, VI:=VDIInput, Wind, Form, VQ:=VDIInquiry, Graf;


TYPE
  MenuProc* = PROCEDURE ();
  Item      = POINTER TO ItemDesc;
  ItemDesc  = RECORD(DCL.Element)
                entry : ARRAY 30 OF CHAR;
                proc  : MenuProc;
              END;
  Menu*     = POINTER TO MenuDesc;
  MenuDesc* = RECORD
                itemList : DCL.List;
                numItems : INTEGER;
              END;


VAR
  station, maxX, maxY : INTEGER;
  x,y,w,h,cx,cy,cw,ch : INTEGER;
  active : Menu;
  inMenu : BOOLEAN;


PROCEDURE(m : Menu) Set*(entry : ARRAY OF CHAR; proc : MenuProc);
  (* stores an item in menu m. It will be displayed under the previously
     stored items. proc is the procedure which is to be called if the
     item is selected. entry is the string to be shown in the menu. It may
     not be longer than 20 characters. *)
  VAR i : Item;
 BEGIN
  NEW(i); i.proc := proc; COPY(entry, i.entry);
  m.itemList.Append(i); INC(m.numItems);
 END Set;


PROCEDURE GetCurrRect() : BOOLEAN;
  VAR mx, my : INTEGER;
      buts : SET;
 BEGIN
  VI.VqMouse( station, buts, mx, my);
  IF (mx <= x) OR (my <= y) OR (mx >= x+w-1) OR (my >= y+h-1) THEN
    RETURN FALSE
  END;
  cx := x;
  cy := S.ANL(my-y-1, SHORT( 0FFF0H) ) + y;
  cw := w;
  ch := 18;
  RETURN TRUE;
 END GetCurrRect;


PROCEDURE Locate(m : Menu);
  VAR d, mx, my : INTEGER;
      i : Item; buts : SET;
 BEGIN
  h := m.numItems * 16 + 2; w := 2;
  i := m.itemList.root;
  WHILE i # NIL DO
    d := Str.Length(i.entry) * 8 + 2;
    IF d > w THEN w := d END;
    i := i.next;
  END;
  INC(w, 16);
  VI.VqMouse( station, buts, mx, my);
  x := mx - w DIV 2; y := my - h DIV 2; (* desired, check if possible *)
  d := x + w - 1 - maxX;
  IF d > 0 THEN DEC(x, d) END;
  d := y + h - 1 - maxY;
  IF d > 0 THEN DEC(y, d) END;
  IF x < 0 THEN x := 0 END;
  IF y < 19 THEN y := 19 END;
  cx := x;
  cy := S.ANL(my-y, SHORT( 0FFF0H) ) + y;
  cw := w;
  ch := 18;
 END Locate;


PROCEDURE SelectRect(x, y, w, h: INTEGER);
 BEGIN
  VI.VHideC(station);
  VA.VswrMode(station,VA.EXOR);
  VA.VsfInterior(station, 1);
  VO.VBar(station, x, y, x+w-1, y+h-1);
  VA.VsfInterior(station, 0);
  VA.VswrMode(station,VA.REPLACE);
  VI.VShowC(station, TRUE);
 END SelectRect;


PROCEDURE Select;
 BEGIN
  SelectRect(cx, cy, cw, ch);
 END Select;


PROCEDURE Draw(m : Menu);
  VAR i : Item; y2,d : INTEGER; c : CHAR;
 BEGIN
  Form.Dial(Form.START,0,0,0,0,x,y,w,h);
  Wind.Update(Wind.BEGMCTRL);
  Wind.Update(Wind.BEGUPD);
  VI.VHideC(station);
  VO.VBar( station, x, y, x+w-1, y+h-1); (* draw background *)
  i := m.itemList.root;
  VQ.VqtFontinfo(station,c,c,d,d,d,d,y2,d,d,d,d);
  INC(y2, y+1);
  WHILE i # NIL DO (* draw entries *)
    VO.VGtext(station, x+8, y2, i.entry);
    i := i.next; INC(y2, 16);
  END;
  Select;
  VI.VShowC(station, TRUE);
 END Draw;


PROCEDURE Delete;
 BEGIN
  Wind.Update(Wind.ENDUPD);
  Wind.Update(Wind.ENDMCTRL);
  Form.Dial(Form.FINISH,0,0,0,0,x,y,w,h);
  active := NIL;
 END Delete;


PROCEDURE(m : Menu) Show*;
  (* displays the popup menu m near the mouse location and lets the user
     select an item. If the mouse leaves the menu area, the menu is deleted.
     If an item is selected, the corresponding procedure is called. *)
 BEGIN
  Locate(m); Draw(m);
  inMenu := TRUE;
  active := m; GemApp.Run;
 END Show;


PROCEDURE(m : Menu) Init*;
  (* initializes a menu *)
 BEGIN
  NEW(m.itemList); m.itemList.Init;
  m.numItems := 0;
 END Init;


PROCEDURE MouseEvent() : BOOLEAN;
  VAR
    oldX, oldY, oldW, oldH: INTEGER;
 BEGIN
  IF active # NIL THEN
    IF inMenu THEN
      oldX := cx; oldY := cy; oldW := cw; oldH := ch;
      IF GetCurrRect() THEN
        IF oldY # cy THEN
          SelectRect(oldX, oldY, oldW, oldH);
          Select;
        END;
      ELSE
        SelectRect(oldX, oldY, oldW, oldH);
        inMenu := FALSE;
      END;
    ELSIF GetCurrRect() THEN
      Select;
      inMenu := TRUE;
    END;
    RETURN TRUE
  END;
  RETURN FALSE
 END MouseEvent;


PROCEDURE ButtonEvent() : BOOLEAN;
  VAR
    num : INTEGER; i : Item;
 BEGIN
  IF active # NIL THEN
    IF inMenu THEN
      i := active.itemList.root;
      num := (cy - y) DIV 16;
      IF num < active.numItems THEN
        Delete;
        WHILE (i # NIL) AND (num > 0) DO
          i := i.next; DEC(num);
        END;
        IF i # NIL THEN i.proc END;
      ELSE
        Delete;
      END;
    ELSE
      Delete;
    END;
    active := NIL;
    GemApp.exit := TRUE;
    RETURN TRUE
  END;
  RETURN FALSE
 END ButtonEvent;


PROCEDURE InitMod;
  VAR Workin  : VC.workin;
      Workout : VC.workout;
      d       : INTEGER;
 BEGIN
  GemApp.mouseProcs.AddProc( MouseEvent);
  GemApp.buttonProcs.AddProc( ButtonEvent);
  station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1;
  Workin.LineColor := 1; Workin.MarkType := 1;
  Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0;
  Workin.FillPat := 0; Workin.FillColor := 1;
  Workin.KoorType := 2;
  VC.VOpnvwk(Workin,station,Workout);
  VA.VswrMode(station,VA.REPLACE);
  VA.VsfPerimeter(station,TRUE);
  maxX := Workout.MaxX; maxY := Workout.MaxY;
 END InitMod;


BEGIN
  InitMod;
END Popup.