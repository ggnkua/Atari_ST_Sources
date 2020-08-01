MODULE ModList;


IMPORT
  S:=SYSTEM, Selected, WinView, VO:=VDIOutput, Modell:=Model, NumStr,
  Str:=Strings, Db:=DbBase, VC:=VDIControl, Hexdump, Disasm, O2Modules;


CONST
  TextBeg = 10; TLenBeg = 22;		(* columns of displayed data *)
  DataBeg = 30; DLenBeg = 42;
  BssBeg  = 50; BLenBeg = 62;
  ModListWidth = 70;


TYPE
  ModData*  = POINTER TO ModDataDesc;
  ModDataDesc=RECORD
                link : ModData;
                mod  : Db.Module;
                tbdsp: SHORTINT;
                tldsp: SHORTINT;
                dbdsp: SHORTINT;
                dldsp: SHORTINT;
                bbdsp: SHORTINT;
                bldsp: SHORTINT;
              END;
  Viewer*   = POINTER TO RECORD (WinView.ViewDesc) END;
  Model     = POINTER TO RECORD(Modell.Desc)
                modList : ModData;
              END;


VAR
  x*,y*,w*,h* : INTEGER;


PROCEDURE BuildList*() : ModData;
  (* must be called once to build up the data for the list of modules *)
  VAR
    l,f : ModData;

  PROCEDURE~ Collect(mod: O2Modules.Module);
    VAR
      m: ModData;
   BEGIN
    NEW(m); m.link := NIL;
    IF l # NIL THEN l.link := m END;
    l := m;
    IF f = NIL THEN f := m END;
    m.mod := mod;
    m.tbdsp := Db.UnsignedHex;
    m.tldsp := Db.UnsignedHex;
    m.dbdsp := Db.UnsignedHex;
    m.dldsp := Db.UnsignedHex;
    m.bbdsp := Db.UnsignedHex;
    m.bldsp := Db.UnsignedHex;
   END Collect;

 BEGIN
  l := NIL; f := NIL;
  O2Modules.Do( Collect);
  RETURN f;
 END BuildList;


PROCEDURE NewViewer*(mod : ModData) : Viewer;
  (* opens a new viewer displaying modList *)
  VAR
    v : Viewer;
    m : Model;
    num,cw,ch,d : INTEGER;
 BEGIN
  NEW(v); v.Initialize;
  v.SetPos(x, y); v.SetSize( w, h);
  v.SetTitle("Modulliste");
  NEW(m); m.Initialize; v.SetModel(m);
  m.modList := mod;
  num := 1;
  WHILE mod # NIL DO
    INC(num); mod := mod.link;
  END;
  Db.GetFontData(d, cw, ch);
  v.SetDataWH(ModListWidth*cw, num*ch);
  v.Open;
  RETURN v
 END NewViewer;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR
    mod : ModData;
    y2,maxY,DistBaseTop,charW,charH, xOff : INTEGER;
    s   : ARRAY 12 OF CHAR;
 BEGIN
  v.Redraw^(x,y,w,h);			(* redraws background *)
  VC.VsClip( Db.station, TRUE, x, y, x+w-1, y+h-1);
  Db.GetFontData(DistBaseTop, charW, charH);
  mod := v.model(Model).modList;
  y2 := v.y - SHORT(v.yOff);
  maxY := y + h;
  xOff := v.x - SHORT(v.xOff);
  IF y2 + charH > y THEN		(* if y inside rect then header *)
    VO.VGtext( Db.station, xOff, y2 + DistBaseTop, "Name");
    VO.VGtext( Db.station, xOff+TextBeg*charW, y2 + DistBaseTop, "Text");
    VO.VGtext( Db.station, xOff+TLenBeg*charW, y2 + DistBaseTop, "TLen");
    VO.VGtext( Db.station, xOff+DataBeg*charW, y2 + DistBaseTop, "Data");
    VO.VGtext( Db.station, xOff+DLenBeg*charW, y2 + DistBaseTop, "DLen");
    VO.VGtext( Db.station, xOff+BssBeg*charW, y2 + DistBaseTop, "Bss");
    VO.VGtext( Db.station, xOff+BLenBeg*charW, y2 + DistBaseTop, "BLen");
  END;
  INC(y2, charH);
  WHILE mod # NIL DO
    IF y2 >= maxY THEN RETURN END;	(* leave if rect full *)
    IF y2 + charH > y THEN		(* if y inside rect then *)
      VO.VGtext( Db.station, xOff, y2 + DistBaseTop, mod.mod.name);(* name *)
      Db.Convert( mod.mod.obj.TextAdr(), mod.tbdsp, 9, s);		(* text *)
      VO.VGtext( Db.station, xOff+TextBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( mod.mod.obj.TextSize(), mod.tldsp, 5, s);		(* textlen *)
      VO.VGtext( Db.station, xOff+TLenBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( mod.mod.obj.DataAdr(), mod.dbdsp, 9, s);		(* data *)
      VO.VGtext( Db.station, xOff+DataBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( mod.mod.obj.DataSize(), mod.dldsp, 5, s);		(* datalen *)
      VO.VGtext( Db.station, xOff+DLenBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( mod.mod.bss, mod.bbdsp, 9, s);		(* bss *)
      VO.VGtext( Db.station, xOff+BssBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( mod.mod.obj.BssSize(), mod.bldsp, 5, s);		(* bsslen *)
      VO.VGtext( Db.station, xOff+BLenBeg*charW, y2 + DistBaseTop, s);
    END;
    INC(y2, charH); mod := mod.link;
  END;
 END Redraw;


PROCEDURE(v : Viewer) Update*(aspect : Modell.Aspect);
  VAR
    start, width, d, cw, ch : INTEGER;
    asp: LONGINT;
 BEGIN
  IF aspect = WinView.UpdateAll THEN v.Update^(aspect)
  ELSE
    asp := S.VAL( LONGINT, aspect);
    CASE S.ANL( asp, 0FFFFH) OF
      1: (* module name *)
        start := 0; width := TextBeg;
     |2: (* text address *)
        start := TextBeg; width := TLenBeg - TextBeg;
     |3: (* text length *)
        start := TLenBeg; width := DataBeg - TLenBeg;
     |4: (* data address *)
        start := DataBeg; width := DLenBeg - DataBeg;
     |5: (* data length *)
        start := DLenBeg; width := BssBeg - DLenBeg;
     |6: (* bss address *)
        start := BssBeg; width := BLenBeg - BssBeg;
     |7: (* bss length *)
        start := BLenBeg; width := ModListWidth - BLenBeg;
    END;
    Db.GetFontData( d, cw, ch);
    v.UpdateRect( v.x - SHORT(v.xOff) + start*cw,
                  v.y + SHORT((asp DIV 10000H + 1) * ch - v.yOff),
                  width*cw, ch );
  END;
 END Update;


PROCEDURE(v : Viewer) HandleButtonEvent*(mbut : SET; mx, my, clicks : INTEGER)
    : BOOLEAN;
  (* is called if WinView.HandleEvent detects a button event in the work
     area of viewer v *)
  VAR
    posx, posy, d, cw, ch : INTEGER;
    mod : ModData;
 BEGIN
  Db.GetFontData(d, cw, ch);
  posx := (mx - v.x + SHORT(v.xOff) ) DIV cw;
  posy := (my - v.y + SHORT(v.yOff) ) DIV ch - 1;
  IF posy < 0 THEN RETURN TRUE END;		(* first line *)
  mod := v.model(Model).modList;	(* find module *)
  d := posy;
  WHILE d > 0 DO
    DEC(d); mod := mod.link;
    IF mod = NIL THEN RETURN TRUE END;	(* out of visible modules *)
  END;
  Selected.model := v.model;
  IF posx < TextBeg THEN		(* module name selected *)
    COPY(mod.mod.name, Selected.modname);
    Selected.GetModPos := NIL;
    Selected.procname[0] := 0X;
    Selected.addr := mod.mod.bss;
    Selected.viewer := v;
    Selected.modMenu.Show;
  ELSIF posx < TLenBeg THEN		(* text address selected *)
    Selected.addr := mod.mod.obj.TextAdr();
    Selected.dsp := S.ADR( mod.tbdsp);
    Selected.item := posy * 10000H + 2;
    Selected.adrMenu.Show;
  ELSIF posx < DataBeg THEN		(* text length selected *)
    Selected.dsp := S.ADR( mod.tldsp);
    Selected.item := posy * 10000H + 3;
    Selected.valMenu.Show;
  ELSIF posx < DLenBeg THEN		(* data address selected *)
    Selected.addr := mod.mod.obj.DataAdr();
    Selected.dsp := S.ADR( mod.dbdsp);
    Selected.item := posy * 10000H + 4;
    Selected.adrMenu.Show;
  ELSIF posx < BssBeg THEN		(* data length selected *)
    Selected.dsp := S.ADR( mod.dldsp);
    Selected.item := posy * 10000H + 5;
    Selected.valMenu.Show;
  ELSIF posx < BLenBeg THEN		(* bss address selected *)
    Selected.addr := mod.mod.bss;
    Selected.dsp := S.ADR( mod.bbdsp);
    Selected.item := posy * 10000H + 6;
    Selected.adrMenu.Show;
  ELSIF posx < ModListWidth THEN	(* bss length selected *)
    Selected.dsp := S.ADR( mod.bldsp);
    Selected.item := posy * 10000H + 7;
    Selected.valMenu.Show;
  END;
  RETURN TRUE
 END HandleButtonEvent;


BEGIN
  x := 0; y := 130; w := 22*8; h := 16*16;
END ModList.