MODULE CallList;


IMPORT
  S:=SYSTEM, Selected, WinView, VO:=VDIOutput, Modell:=Model, NumStr,
  Str:=Strings, Db:=DbBase, VC:=VDIControl, Sym:=OCSymbol, Sys, Program,
  Scan:=OCScan, OCPar;


CONST
  AddrBeg = 30; StartBeg = 42; RegA6Beg = 54;	(* columns of displayed data *)
  CallListWidth = 66;


TYPE
  CallData* = POINTER TO CallDesc;
  CallDesc  = RECORD
                next : CallData;
                mod  : ARRAY 10 OF CHAR;
                proc : ARRAY 24 OF CHAR;
                addr : LONGINT;
                begad: LONGINT;
                endad: LONGINT;
                regA6: LONGINT;
                module: Db.Module;
                addsp: SHORTINT;
                bgdsp: SHORTINT;
                a6dsp: SHORTINT;
              END;
  Viewer*   = POINTER TO RECORD (WinView.ViewDesc) END;
  Model     = POINTER TO RECORD(Modell.Desc)
                callList : CallData;
              END;


VAR
  x*,y*,w*,h* : INTEGER;
  model : Model;
  selectedCall : CallData;


PROCEDURE BuildList*(addr: S.PTR) : CallData;
  (* must be called once to build up the data for the list of calls.
   * addr means the position of the exception, regA6 the contents of
   * A6 at the time of exception.
   *)
  VAR
    l,f : CallData;
    mod, proc : ARRAY 24 OF CHAR;
    modOff, procOff : LONGINT;

  PROCEDURE AddProcedureAt(stack: S.PTR);
    VAR
      c: CallData;
      addr, regA6: S.PTR;
   BEGIN
    S.GET(stack+4, addr);
    Db.GetModProc(addr, mod, proc, modOff, procOff);
    NEW(c); c.next := NIL;
    IF l # NIL THEN l.next := c END;
    l := c;
    IF f = NIL THEN f := c END;
    c.addsp := Db.UnsignedHex;
    c.bgdsp := Db.UnsignedHex;
    c.a6dsp := Db.UnsignedHex;
    COPY(mod, c.mod); COPY(proc, c.proc);
    S.GET(stack, regA6);
    c.addr := addr; c.regA6 := regA6;
    c.begad := Db.Begad; c.module := Db.Mod;
    c.endad := Db.Endad;
   END AddProcedureAt;

  PROCEDURE AddProcedures(address: S.PTR);
    VAR
      stack, stackTop, adr: S.PTR;
      opcode: INTEGER;
   BEGIN
    stackTop := Sys.stackEnd + Sys.stackSize;
    S.GETREG(14, stack);
    S.GET(stack, stack);
    REPEAT
      S.GET(stack+4, adr);
      IF ~ODD(adr) & Program.AddressInCode(adr) THEN
        IF address # NIL THEN
          S.GET(stack+4, adr);
          IF adr = address THEN address := NIL END;
        END;
        IF address = NIL THEN
          AddProcedureAt(stack);
        END;
      ELSE
        RETURN;
      END;
      S.GET(stack, stack);
    UNTIL (stack >= stackTop) OR (stack < Sys.stackEnd) OR ODD(stack);
   END AddProcedures;

 BEGIN
  l := NIL; f := NIL;
  AddProcedures(addr);
  RETURN f;
 END BuildList;


PROCEDURE NewViewer*(calls : CallData) : Viewer;
  (* opens a new viewer displaying calls *)
  VAR
    v : Viewer;
    num,cw,ch,d : INTEGER;
 BEGIN
  NEW(v); v.Initialize;
  v.SetPos(x, y); v.SetSize( w, h);
  v.SetTitle("Aufrufliste");
  IF model = NIL THEN
    NEW(model); model.Initialize;
    model.callList := calls;
  END;
  v.model := model;
  num := 1;
  WHILE calls # NIL DO
    INC(num); calls := calls.next;
  END;
  Db.GetFontData(d, cw, ch);
  v.SetDataWH(CallListWidth*cw, num*ch);
  v.Open;
  RETURN v
 END NewViewer;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR
    call : CallData;
    y2,maxY,DistBaseTop,charW,charH, xOff : INTEGER;
    s   : ARRAY 40 OF CHAR;
 BEGIN
  v.Redraw^(x,y,w,h);			(* redraws background *)
  VC.VsClip( Db.station, TRUE, x, y, x+w-1, y+h-1);
  Db.GetFontData(DistBaseTop, charW, charH);
  call := v.model(Model).callList;
  y2 := v.y - SHORT(v.yOff);
  maxY := y + h;
  xOff := v.x - SHORT(v.xOff);
  IF y2 + charH > y THEN		(* if y inside rect then header *)
    VO.VGtext( Db.station, xOff, y2 + DistBaseTop, "Name");
    VO.VGtext( Db.station, xOff+AddrBeg*charW, y2 + DistBaseTop, "Adresse");
    VO.VGtext( Db.station, xOff+StartBeg*charW, y2 + DistBaseTop, "StartAdr.");
    VO.VGtext( Db.station, xOff+RegA6Beg*charW, y2 + DistBaseTop, "Reg. A6");
  END;
  INC(y2, charH);
  WHILE call # NIL DO
    IF y2 >= maxY THEN RETURN END;	(* leave if rect full *)
    IF y2 + charH > y THEN		(* if y inside rect then *)
      COPY( call.mod, s); Str.AppendC(".", s); Str.Append( call.proc, s);
      VO.VGtext( Db.station, xOff, y2 + DistBaseTop, s);	(* name *)
      Db.Convert( call.addr, call.addsp, 9, s);			(* exc addr *)
      VO.VGtext( Db.station, xOff+AddrBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( call.begad, call.bgdsp, 9, s);		(* beg addr *)
      VO.VGtext( Db.station, xOff+StartBeg*charW, y2 + DistBaseTop, s);
      Db.Convert( call.regA6, call.a6dsp, 9, s);		(* reg a6 *)
      VO.VGtext( Db.station, xOff+RegA6Beg*charW, y2 + DistBaseTop, s);
    END;
    INC(y2, charH); call := call.next;
  END;
 END Redraw;


PROCEDURE(v : Viewer) Update*(asp : Modell.Aspect);
  VAR
    start, width, d, cw, ch : INTEGER;
    aspect: LONGINT;
 BEGIN
  IF asp = WinView.UpdateAll THEN v.Update^(aspect)
  ELSE
    aspect := S.VAL( LONGINT, asp);
    CASE S.ANL( aspect, 0FFFFH) OF
      1: (* module and procedure name *)
        start := 0; width := AddrBeg;
     |2: (* exc address *)
        start := AddrBeg; width := StartBeg - AddrBeg;
     |3: (* procedure address *)
        start := StartBeg; width := RegA6Beg - StartBeg;
     |4: (* reg a6 *)
        start := RegA6Beg; width := CallListWidth - RegA6Beg;
    END;
    Db.GetFontData( d, cw, ch);
    v.UpdateRect( v.x - SHORT(v.xOff) + start*cw,
                  v.y + SHORT((aspect DIV 10000H + 1) * ch - v.yOff),
                  width*cw, ch );
  END;
 END Update;


PROCEDURE ProcSourcePos(begad: S.PTR; VAR start, end: LONGINT);
  VAR
    sym: INTEGER;

  PROCEDURE GetIdent() : BOOLEAN;
   BEGIN
    Scan.Get(sym);
    WHILE sym # Scan.ident DO
      IF sym = Scan.eof THEN RETURN FALSE END;
      IF sym = Scan.lparen THEN
        REPEAT
          Scan.Get(sym);
          IF sym = Scan.eof THEN RETURN FALSE END;
        UNTIL sym = Scan.rparen;
      END;
      Scan.Get(sym);
    END;
    RETURN TRUE
   END GetIdent;

 BEGIN
  Scan.Init(begad); Scan.errorOutput := FALSE;
  start := 0; end := 0;
  LOOP
    Scan.Get(sym);
    IF sym = Scan.eof THEN EXIT END;
    IF sym = Scan.procedure THEN
      IF ~GetIdent() THEN EXIT END;
      IF Scan.name = Selected.procname THEN
        REPEAT
          Scan.Get(sym);
          IF sym = Scan.eof THEN EXIT END;
          IF sym = Scan.procedure THEN
            IF ~GetIdent() THEN EXIT END;
            Scan.ToEnd( Scan.name);
          END;
        UNTIL sym = Scan.begin;
        start := OCPar.position - begad;
        Scan.ToEnd( Selected.procname);
        end := OCPar.position - begad;
        EXIT
      END
    END;
  END;
  Scan.Exit;
 END ProcSourcePos;


PROCEDURE CodePos(VAR pos: LONGINT);
 BEGIN
  pos := selectedCall.addr - selectedCall.begad;
 END CodePos;


PROCEDURE ProcCodePos(VAR start, end: LONGINT);
  VAR
    text: LONGINT;
 BEGIN
  text := selectedCall.module.obj.TextAdr();
  start := selectedCall.begad - text;
  end := selectedCall.endad - text;
 END ProcCodePos;


PROCEDURE GetPos() : LONGINT;
  VAR
    codePos, sourceStart, sourceEnd, codeStart, codeEnd: LONGINT;
    begad: S.PTR; length: LONGINT;
 BEGIN
  IF ~Db.LoadSource( Selected.modname, begad, length) THEN RETURN -1 END;
  ProcSourcePos(begad, sourceStart, sourceEnd);
  CodePos(codePos);
  ProcCodePos(codeStart, codeEnd);
  RETURN sourceStart + codePos * (sourceEnd - sourceStart)
      DIV (codeEnd - codeStart)
 END GetPos;


PROCEDURE(v : Viewer) HandleButtonEvent*(mbut : SET; mx, my, clicks : INTEGER)
    : BOOLEAN;
  (* is called if WinView.HandleEvent detects a button event in the work
     area of viewer v *)
  VAR
    posx, posy, d, cw, ch : INTEGER;
    call : CallData;
    objcs : Selected.ModObjcs;
 BEGIN
  Db.GetFontData(d, cw, ch);
  posx := (mx - v.x + SHORT(v.xOff) ) DIV cw;
  posy := (my - v.y + SHORT(v.yOff) ) DIV ch - 1;
  IF posy < 0 THEN RETURN TRUE END;		(* first line *)
  call := v.model(Model).callList;	(* find call *)
  d := posy;
  WHILE d > 0 DO
    DEC(d); call := call.next;
    IF call = NIL THEN RETURN TRUE END;	(* out of visible calls *)
  END;
  Selected.model := v.model;
  IF posx < AddrBeg THEN		(* module name selected *)
    COPY(call.mod, Selected.modname);
    COPY(call.proc, Selected.procname);
    Selected.addr := call.regA6;
    Selected.GetModPos := GetPos;
    Selected.viewer := v;
    selectedCall := call;
    Selected.modMenu.Show;
  ELSIF posx < StartBeg THEN		(* exc address selected *)
    Selected.addr := call.addr;
    Selected.dsp := S.ADR( call.addsp);
    Selected.item := posy * 10000H + 2;
    Selected.adrMenu.Show;
  ELSIF posx < RegA6Beg THEN		(* start address selected *)
    Selected.addr := call.begad;
    Selected.dsp := S.ADR( call.bgdsp);
    Selected.item := posy * 10000H + 3;
    Selected.adrMenu.Show;
  ELSIF posx < CallListWidth THEN	(* reg a6 selected *)
    Selected.addr := call.regA6;
    Selected.dsp := S.ADR( call.a6dsp);
    Selected.item := posy * 10000H + 4;
    Selected.adrMenu.Show;
  END;
  RETURN TRUE
 END HandleButtonEvent;


PROCEDURE CorrectCallList(objcs : Selected.ModObjcs);
 BEGIN
 END CorrectCallList;


PROCEDURE Init*;
 BEGIN
 END Init;


PROCEDURE Exit*;
 BEGIN
  model := NIL;
  selectedCall := NIL;
 END Exit;


BEGIN
  x := 200; y := 130; w := 25*8; h := 16*16;
  Selected.CorrectCallList := CorrectCallList;
END CallList.