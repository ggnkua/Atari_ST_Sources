MODULE Disasm;


IMPORT
  S:=SYSTEM, Supervisor, Db:=DbBase, Modell:=Model, WinView, NumStr,
  Str:=Strings, VO:=VDIOutput, VC:=VDIControl, Wind, BIOS, Disass, Hexdump;


CONST
  MnemStart = 10; EaStart = 18;


TYPE
  Viewer*   = POINTER TO RECORD (WinView.ViewDesc)
                topad : S.PTR;
              END;
  Model     = POINTER TO RECORD(Modell.Desc)
              END;


VAR
  model   : Model;


PROCEDURE CallDisass(VAR adr : S.PTR);
 BEGIN
  Supervisor.On;
  Disass.Do(adr);
  Supervisor.Off;
 END CallDisass;


PROCEDURE DisLine(VAR disAd : S.PTR; VAR line : ARRAY OF CHAR);
  VAR i : INTEGER;
      s : ARRAY 10 OF CHAR;
 BEGIN
  FOR i := 0 TO 78 DO line[i] := " " END;
  line[79] := 0X;
  NumStr.LCardTo( disAd, 16, s);
  Str.Adjust( Str.right, 8, "0", s);
  line[0] := "$";
  Str.Write(s, 1, line);
  CallDisass(disAd);
  Str.Write( Disass.opcodeBuf^, MnemStart, line);
  Str.Write( Disass.eaBuf^, EaStart, line);
 END DisLine;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR
    y2,maxY,DistBaseTop,charW,charH,xOff,i : INTEGER;
    addr : S.PTR;
    line : ARRAY 80 OF CHAR;
 BEGIN
  v.Redraw^(x,y,w,h);			(* redraws background *)
  VC.VsClip( Db.station, TRUE, x, y, x+w-1, y+h-1);
  Db.GetFontData(DistBaseTop, charW, charH);
  y2 := v.y;
  maxY := y + h;
  xOff := v.x;
  addr := v.topad;
  WHILE y2 < maxY DO
    IF y2 + charH > y THEN		(* if y inside rect then *)
      DisLine( addr, line);
      VO.VGtext( Db.station, xOff, y2 + DistBaseTop, line);
    ELSE
      CallDisass( addr);
    END;
    INC(y2, charH);
  END;
 END Redraw;


PROCEDURE FindPreviousCode(VAR addr : S.PTR);
  VAR ad, prev : S.PTR;
 BEGIN
  ad := addr - 20H;
  WHILE ad < addr DO
    prev := ad;
    CallDisass(ad);
  END;
  addr := prev;
 END FindPreviousCode;


PROCEDURE(v : Viewer) VSlid(pos : INTEGER);
  VAR
    d, cw, ch, cpos : INTEGER;
 BEGIN
  Db.GetFontData(d, cw, ch);
  cpos := SHORT(v.yOff) DIV ch;
  WHILE cpos < pos DO
    CallDisass(v.topad);
    INC(cpos);
  END;
  WHILE cpos > pos DO
    FindPreviousCode(v.topad);
    DEC(cpos);
  END;
  v.SetOffset(0, pos * ch);
 END VSlid;


PROCEDURE(v : Viewer) PageUp;
  VAR
    lines, d, cw, ch : INTEGER;
    yOff : LONGINT;
 BEGIN
  Db.GetFontData(d, cw, ch);
  lines := v.h DIV ch;
  WHILE lines > 0 DO
    FindPreviousCode(v.topad);
    DEC(lines);
  END;
  yOff := v.yOff - v.h;
  IF yOff < 0 THEN yOff := 0 END;
  v.SetOffset( 0, yOff);
 END PageUp;


PROCEDURE(v : Viewer) PageDown;
  VAR
    lines, d, cw, ch : INTEGER;
    yOff,max : LONGINT;
 BEGIN
  Db.GetFontData(d, cw, ch);
  lines := v.h DIV ch;
  WHILE lines > 0 DO
    CallDisass(v.topad);
    DEC(lines);
  END;
  yOff := v.yOff + v.h;
  max := 1000*ch-v.h;
  IF yOff > max THEN yOff := max END;
  v.SetOffset( 0, yOff);
 END PageDown;


PROCEDURE(v : Viewer) LineUp;
  VAR
    d, cw, ch : INTEGER;
    yOff : LONGINT;
 BEGIN
  Db.GetFontData(d, cw, ch);
  FindPreviousCode( v.topad);
  yOff := v.yOff - ch;
  IF yOff < 0 THEN yOff := 0 END;
  v.SetOffset( 0, yOff);
 END LineUp;


PROCEDURE(v : Viewer) LineDown;
  VAR
    d, cw, ch : INTEGER;
    yOff,max : LONGINT;
 BEGIN
  Db.GetFontData(d, cw, ch);
  CallDisass( v.topad);
  yOff := v.yOff + ch;
  max := 1000*ch-v.h;
  IF yOff > max THEN yOff := max END;
  v.SetOffset( 0, yOff);
 END LineDown;


PROCEDURE NewViewer*(begad : S.PTR);
  (* opens a new viewer displaying hexdump starting at begad *)
  VAR
    v : Viewer;
    m : Model;
    cw,ch,d : INTEGER;
    title : ARRAY 20 OF CHAR;
 BEGIN
  NEW(v); v.Initialize;
  NumStr.LCardTo(begad, 16, title);
  Str.Insert("Disass ", 0, title);
  v.SetTitle(title);
  v.SetElements({Wind.TITLE, Wind.CLOSER, Wind.MOVER,
                 Wind.SIZER, Wind.UPARROW, Wind.DNARROW, Wind.VSLIDER});
  v.model := model;
  Db.GetFontData(d, cw, ch);
  v.SetDataWH(80*cw, 1000*ch);
  v.yOff := 500 * ch;
  v.topad := begad;
  v.Open;
 END NewViewer;


PROCEDURE HexDigit(c : CHAR) : BOOLEAN;
 BEGIN
  RETURN (c >= "0") AND (c <= "9") OR (c >= "A") AND (c <= "F");
 END HexDigit;


PROCEDURE(v : Viewer) HandleButtonEvent(mbut : SET; mx, my, clicks : INTEGER)
    : BOOLEAN;
  (* is called if WinView.HandleEvent detects a button event in the work
     area of viewer v *)
  VAR
    posx, posy, d, i, cw, ch : INTEGER;
    addr : S.PTR;
    line : ARRAY 80 OF CHAR;
 BEGIN
  Db.GetFontData(d, cw, ch);
  posx := (mx - v.x) DIV cw;
  posy := (my - v.y) DIV ch;
  addr := v.topad;
  REPEAT
    DisLine(addr, line);
    DEC(posy);
  UNTIL posy < 0;
  WHILE (line[posx] # "$") AND HexDigit(line[posx]) DO
    DEC(posx)
  END;
  IF line[posx] = "$" THEN
    INC(posx); i := 0;
    WHILE HexDigit(line[posx]) DO
      line[i] := line[posx]; INC(i); INC(posx);
    END;
    line[i] := 0X;
    addr := NumStr.ToLInt(16, line);
    mbut := BIOS.Kbshift(-1);
    IF NOT (2 IN mbut) THEN (* control = disasm *)
      Hexdump.NewViewer(addr);
    ELSIF (0 IN mbut) OR (1 IN mbut) THEN
      v.topad := addr;
      v.Update( WinView.UpdateAll);
    ELSE
      NewViewer(addr);
    END;
  END;
  RETURN TRUE
 END HandleButtonEvent;


PROCEDURE InitMod;
 BEGIN
  NEW(model); model.Initialize;
 END InitMod;


BEGIN
  InitMod;
  Hexdump.newDisasmViewer := NewViewer;
END Disasm.