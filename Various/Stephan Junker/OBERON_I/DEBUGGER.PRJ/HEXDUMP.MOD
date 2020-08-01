MODULE Hexdump;


IMPORT
  S:=SYSTEM, XBIOS, Db:=DbBase, Modell:=Model, WinView, NumStr,
  Str:=Strings, VO:=VDIOutput, VC:=VDIControl, Wind, BIOS;


CONST
  DumpStart = 10; AsciiStart = 60;
  NumLines = 4000;


TYPE
  Viewer*   = POINTER TO RECORD (WinView.ViewDesc)
                topad : S.PTR;
              END;
  Model     = POINTER TO RECORD(Modell.Desc)
              END;


VAR
  newDisasmViewer* : PROCEDURE (begad : S.PTR);
  address : S.PTR;
  byte    : SHORTINT; long : LONGINT;
  model   : Model;


(*$-k *)

PROCEDURE Getbyte;
 BEGIN
  S.GET(address, byte);
 END Getbyte;

(*$+k *)

PROCEDURE DumpLine(dumpAd : S.PTR; VAR line : ARRAY OF CHAR);
  VAR i,j : INTEGER;
      s : ARRAY 10 OF CHAR;
 BEGIN
  FOR i := 0 TO 78 DO line[i] := " " END;
  line[79] := 0X;
  NumStr.LCardTo( dumpAd, 16, s);
  Str.Adjust( Str.right, 8, "0", s);
  line[0] := "$";
  Str.Write(s, 1, line);
  line[AsciiStart-1] := "|";
  line[AsciiStart+16] := "|";
  i := AsciiStart; j := DumpStart;
  REPEAT
    address := dumpAd;
    XBIOS.Supexec(Getbyte);
    NumStr.LIntTo(S.LONG(byte), 16, s);
    Str.Adjust( Str.right, 2, "0", s);
    Str.Write(s, j, line);
    IF (byte >= 0) AND (byte < 20H) THEN line[i] := 0FAX
    ELSE line[i] := CHR(byte)
    END;
    INC(i); INC(dumpAd); INC(j, 3);
    IF i = AsciiStart+8 THEN INC(j) END;
  UNTIL i = AsciiStart+16;
 END DumpLine;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR
    y2,maxY,DistBaseTop,charW,charH, xOff : INTEGER;
    addr : S.PTR;
    line : ARRAY 80 OF CHAR;
 BEGIN
  v.Redraw^(x,y,w,h);			(* redraws background *)
  VC.VsClip( Db.station, TRUE, x, y, x+w-1, y+h-1);
  Db.GetFontData(DistBaseTop, charW, charH);
  y2 := v.y;
  maxY := y + h;
  xOff := v.x;
  addr := v.topad + v.yOff DIV charH * 16;
  WHILE y2 < maxY DO
    IF y2 + charH > y THEN		(* if y inside rect then *)
      DumpLine( addr, line);
      VO.VGtext( Db.station, xOff, y2 + DistBaseTop, line);
    END;
    INC(addr, 16); INC(y2, charH);
  END;
 END Redraw;


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
  Str.Insert("Hexdump ", 0, title);
  v.SetTitle(title);
  v.SetElements({Wind.TITLE, Wind.CLOSER, Wind.MOVER,
                 Wind.SIZER, Wind.UPARROW, Wind.DNARROW, Wind.VSLIDER});
  v.model := model;
  Db.GetFontData(d, cw, ch);
  v.SetDataWH(80*cw, NumLines*LONG(ch));
  v.yOff := NumLines DIV 2 * LONG(ch);
  v.topad := begad - NumLines DIV 2 * 16;
  v.Open;
 END NewViewer;


PROCEDURE Getlong;
 BEGIN
  S.GET(address, long);
 END Getlong;


PROCEDURE(v : Viewer) HandleButtonEvent*(mbut : SET; mx, my, clicks : INTEGER)
    : BOOLEAN;
  (* is called if WinView.HandleEvent detects a button event in the work
     area of viewer v *)
  VAR
    posx, posy, d, cw, ch : INTEGER;
    addr : LONGINT;
 BEGIN
  Db.GetFontData(d, cw, ch);
  posx := (mx - v.x) DIV cw;
  posy := (my - v.y) DIV ch;
  IF (posx >= 0) AND (posx < 9) THEN (* address of line *)
    addr := v.topad + v.yOff DIV ch * 16 + LONG(posy * 16);
  ELSE
    posx := ((mx - v.x) DIV cw - DumpStart) DIV 3;
    IF (posx < 0) OR (posx > 15) THEN RETURN TRUE END;
    addr := v.topad + v.yOff DIV ch * 16 + LONG(posy * 16 + posx);
    DEC(addr, S.ANL( addr, 1) );
    address := addr;
    XBIOS.Supexec(Getlong);
    addr := long;
  END;
  mbut := BIOS.Kbshift(-1);
  IF 2 IN mbut THEN (* control = disasm *)
    newDisasmViewer(addr)
  ELSIF (0 IN mbut) OR (1 IN mbut) THEN
    v.topad := addr - NumLines DIV 2 * 16;
    v.SetOffset(0, NumLines DIV 2 * LONG(ch));
  ELSE
    NewViewer(addr);
  END;
  RETURN TRUE
 END HandleButtonEvent;


PROCEDURE InitMod;
 BEGIN
  NEW(model); model.Initialize;
 END InitMod;


BEGIN
  InitMod;
END Hexdump.