MODULE TextViewer;


IMPORT VC:=VDIControl, VA:=VDIAttributes, VO:=VDIOutput, VQ:=VDIInquiry,
       Wind,WinView, Evnt, Str:=Strings, S:=SYSTEM, File, VDI, Modl:=Model,
       Sys, Graf (* test , GemApp *);


TYPE
  Viewer*   = POINTER TO ViewDesc;
  ViewDesc* = RECORD(WinView.ViewDesc)
                mark-    : LONGINT;
                fontId-, fontHeight- : INTEGER;
              END(*RECORD*);
  Model*    = POINTER TO ModelDesc;
  ModelDesc*= RECORD (Modl.Desc)
                fileAdr- : S.PTR;
                fileLen- : LONGINT;
              END;
  Line      = POINTER TO ARRAY 256 OF CHAR;


VAR
  station : INTEGER;


(*$I-*)

PROCEDURE LineLength(line : Line) : INTEGER;
  VAR Offset : INTEGER;
 BEGIN
  Offset := 0;
  WHILE (line^[Offset] # 0X) AND (line^[Offset] # 0AX) DO INC(Offset) END;
  IF line^[Offset] = 0AX THEN INC(Offset) END(*IF*);
  RETURN Offset
 END LineLength;


PROCEDURE PrevLineLength(line : Line) : INTEGER;
  (* may not be used in first line *)
  VAR Offset : INTEGER;
 BEGIN
  Offset := -1;
  REPEAT DEC(Offset) UNTIL line^[Offset] = 0AX;
  RETURN -Offset-1
 END PrevLineLength;

(*$I=*)

PROCEDURE Row(begad, addr : S.PTR) : INTEGER;
  VAR
    row : INTEGER;
    byte: SHORTINT;
 BEGIN
  row := 0;
  WHILE (addr > begad) DO
    DEC(addr);
    S.GET( addr, byte);
    IF byte = 0AH THEN INC(row) END;
  END;
  RETURN row
 END Row;


PROCEDURE Column(begad, addr : S.PTR) : INTEGER;
  VAR
    col : INTEGER;
    byte: SHORTINT;
 BEGIN
  col := 0; byte := 0;
  WHILE (addr > begad) AND (byte # 0AH) DO
    DEC(addr); INC(col);
    S.GET( addr, byte);
  END;
  IF addr > begad THEN DEC(col) END;
  RETURN col
 END Column;


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
  VAR DistBaseTop, x2, y2, i, d, j : INTEGER;
      maxY, xOff, fw, fh, cpp : INTEGER;
      line : Line; prev, mark : S.PTR;
      first : BOOLEAN;
 BEGIN
  IF v.model # NIL THEN
    first := TRUE;
    x2 := x+w-1; y2 := y+h-1;
    VC.VsClip(station, TRUE, x, y, x2, y2);
    IF v.model(Model).fileAdr # NIL THEN
      GetFontData( v.fontId, v.fontHeight, DistBaseTop, fw, fh);
      line := v.model(Model).fileAdr;
      y2 := v.y - SHORT(v.yOff);
      maxY := y + h;
      xOff := v.x - SHORT(v.xOff);
      cpp := (v.w + SHORT(v.xOff) ) DIV fw + 1;
      mark := v.model(Model).fileAdr + v.mark;
      WHILE (line[0] # 0X) AND (y2 < maxY) DO
        IF y2 + fh > y THEN
          IF first THEN v.Redraw^(x,y,w,h); first := FALSE END;
          VDI.Ptsin[0] := xOff;
          VDI.Ptsin[1] := y2 + DistBaseTop;
          VDI.Ptsin[3] := 0;
          i := 0; j := 0;
          WHILE (line[i] # 0DX) AND (line[i] # 0AX) AND
                (line[i] # 0X) AND (j < cpp) DO
            IF line[i] = 9X THEN			(* tab *)
              REPEAT
                VDI.Intin[j] := 20H; INC(j);
              UNTIL j MOD 8 = 0;
            ELSE
              VDI.Intin[j] := ORD(line[i]); INC(j);
            END;
            INC(i);
          END;
          IF j # 0 THEN
            VDI.Ptsin[2] := j;
            VDI.Call(8,0,station,01000000H + LONG(j*256));
          END(*IF*);
          prev := line;
          INC(line, LineLength(line) );
          IF (mark >= prev) AND (mark < line) THEN
            x2 := v.x + SHORT( S.VAL(LONGINT, mark - prev) * fw - v.xOff);
            VO.VBar( station, x2-1, y2, x2+1, y2+fh);
          END;
        ELSE
          INC(line, LineLength(line) );
        END;
        INC(y2, fh);
      END;
    END;
    IF first THEN v.Redraw^(x,y,w,h) END;
  ELSE
    v.Redraw^(x, y, w, h)
  END;
 END Redraw;


PROCEDURE(m : Model) Initialize*;
(*
 * Initializes a model for text display.
 *)
 BEGIN
  m.Initialize^;
  m.fileAdr := NIL;
 END Initialize;


PROCEDURE(v : Viewer) Initialize*;
(*
 * Initializes a viewer for text display.
 *)
 BEGIN
  v.Initialize^;
  v.mark := -1;
  v.fontId := 1; v.fontHeight := 13;
 END Initialize;


PROCEDURE(v : Viewer) SetMark*(pos : LONGINT);
(*
 * sets the mark at position pos in the text displayed in v. The displayed
 * part is set so that the mark is visible. If v is opened, it will be
 * updated immediately.
 *)
  VAR
    d, cw, ch, col : INTEGER;
    begad : S.PTR;
    xOff, yOff : LONGINT;
 BEGIN
  v.mark := pos;
  GetFontData( v.fontId, v.fontHeight, d, cw, ch);
  xOff := 0;
  IF pos < 0 THEN
    yOff := 0;
  ELSE
    begad := v.model(Model).fileAdr;
    col := Column(begad, begad+pos);
    IF col >= v.w DIV cw THEN
      xOff := col * cw - v.w DIV 2;
    END;
    yOff := Row( begad, begad+pos) * ch;
  END;
  v.SetOffset(xOff, yOff);
 END SetMark;


PROCEDURE(v : Viewer) SetModel*(m : Modl.Ptr);
(*
 Set the text to be displayed.
 *)
  VAR
    d, cw, ch : INTEGER;
 BEGIN
  v.SetModel^(m);
  GetFontData(1, 13, d, cw, ch);
  WITH m: Model DO
    v.SetDataWH( 160*cw, (Row(m.fileAdr, m.fileAdr+m.fileLen) + 1) * ch);
  END;
 END SetModel;


PROCEDURE(m : Model) SetText*(begad : S.PTR; length : LONGINT);
(*
 * Sets the text data for model m. The text must start at address begad
 * and have the length length. It must be terminated by a zero byte.
 * All viewer displaying model m will be updated.
 *)
 BEGIN
  m.fileAdr := begad;
  m.fileLen := length;
  m.Changed(WinView.UpdateAll);
 END SetText;


PROCEDURE(m : Model) LoadText*(name : ARRAY OF CHAR);
(*
 * Loads a text file with given name using File.Load and sets it's data
 * in model m. If loading fails, m.fileAdr will not be changed
 * (NIL after Init).
 *)
  VAR
    length : LONGINT;
    begad  : S.PTR;
    str    : POINTER TO ARRAY OF CHAR;
 BEGIN
  IF File.Load(name, 0, 1, begad, length) THEN
    S.PUT( begad+length, 0);
    m.SetText(begad, length);
  ELSE
    NEW( str, 200);
    Str.Merge( "File ", name, str^);
    Str.Append( " not found.", str^);
    m.SetText(str, Str.Length(str^));
  END;
 END LoadText;


PROCEDURE(v : Viewer) SetFont*(fontId, fontHeight : INTEGER);
(*
 * sets the font and it's height for a viewer. If the viewer is opened,
 * it is redrawn immediately. It's size, data size and offsets are
 * recalculated.
 *)
  VAR
    d, cw, ch, ocw, och : INTEGER;
 BEGIN
  GetFontData(v.fontId, v.fontHeight, d, ocw, och);
  v.fontId := fontId;
  v.fontHeight := fontHeight;
  GetFontData(fontId, fontHeight, d, cw, ch);
  v.SetDataWH( 160*cw, (Row(v.model(Model).fileAdr,
               v.model(Model).fileAdr+v.model(Model).fileLen) + 1) * ch);
  v.SetSize( v.w DIV ocw * cw, v.h DIV och * ch);
  v.SetOffset( v.xOff DIV ocw * cw, v.yOff DIV och * ch);
 END SetFont;


PROCEDURE(v : Viewer) TextSelected*(lineAd, selAd : S.PTR);
(*
 * is called is a mouse click in the work area of a text window is
 * done. Override if you want to react on that event.
 *)
 BEGIN
 END TextSelected;


PROCEDURE(v : Viewer) HandleButtonEvent*(
         mbut : SET;
         mx, my, clicks : INTEGER) : BOOLEAN;
  VAR
    row,col : INTEGER;
    d, cw, ch : INTEGER;
    addr : Line;
 BEGIN
  IF v.model # NIL THEN
    GetFontData(v.fontId, v.fontHeight, d, cw, ch);
    row := SHORT( (my - v.y + v.yOff) DIV ch);
    col := (mx - v.x + SHORT( v.xOff) ) DIV cw;
    addr := v.model(Model).fileAdr;
    WHILE row > 0 DO
      INC( addr, LineLength(addr) );
      DEC(row);
    END;
    IF col < LineLength(addr) THEN
      v.TextSelected(addr, S.ADR(addr[col]) );
      RETURN TRUE
    END;
  END;
  RETURN FALSE
 END HandleButtonEvent;


PROCEDURE InitMod;
  VAR Workin  : VC.workin;
      Workout : VC.workout;
      d : INTEGER;
 BEGIN
  station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1;
  Workin.LineColor := 1; Workin.MarkType := 1;
  Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 1;
  Workin.FillPat := 0; Workin.FillColor := 1;
  Workin.KoorType := 2;
  VC.VOpnvwk(Workin,station,Workout);
  VA.VswrMode(station,VA.REPLACE);
  VA.VsfPerimeter(station,FALSE);
  IF VC.GDOSinstalled() THEN d := VC.VstLoadFonts(station,0) END;
 END InitMod;

(*
PROCEDURE TestMod;
  VAR v : Viewer; app : GemApp.Application;
 BEGIN
  NEW(app); app.Init;
  NEW(v); v.Init;
  v.LoadText("e:\oberon\debug\debug.m", 1000);
  v.Open;
  app.Run; app.Exit;
 END TestMod;
*)

BEGIN
  InitMod;
  (* test
  TestMod;*)
END TextViewer.
