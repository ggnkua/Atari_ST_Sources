MODULE Variables;


IMPORT
  S:=SYSTEM, Selected, WinView, VO:=VDIOutput, Modell:=Model, NumStr,
  Str:=Strings, Db:=DbBase, VC:=VDIControl, Hexdump, Disasm, Sym:=OCSymbol,
  BIOS, (*Dial, *)Form, FN:=Filename, TextViewer;


CONST
  dummy = "INV";
  ValBeg = 20; TypBeg = 40; (* columns of displayed data *)
  VarWidth = 80;

  VarTyp* = 0; RecTyp* = 1; ArrTyp* = 2; DynArrTyp* = 3;

  sdecimal = 0; udecimal = 1; shexadecimal = 2; uhexadecimal = 3;
  character = 4; string = 5; symbolic = 6; complex = 7; unknown = 8;
  real = 9; lreal = 10; address = 11; boolean = 12; set = 13;
  pointer = 14;


TYPE
  Viewer*   = POINTER TO RECORD (WinView.ViewDesc) END;
  Model     = POINTER TO ModelDesc;
  ModelDesc = RECORD(Modell.Desc)
                varadr : S.PTR;
                vartyp : INTEGER;
                typ    : Sym.Struct; (* array *)
                obj    : Sym.Symbol; (* var or record *)
                prev   : Model;
                num    : LONGINT;
                name   : ARRAY 40 OF CHAR;
                disp   : INTEGER; (* array *)
              END;


VAR
  selVarAdr : S.PTR;
  selObj    : Sym.Symbol;
  selItem   : LONGINT;
  selViewer : Viewer;


PROCEDURE DefaultDisplay(typ : Sym.Struct) : INTEGER;
  VAR display : INTEGER;
 BEGIN
  display := sdecimal;
  CASE typ.form OF
    Sym.Pointer, Sym.AnyPtr : display := pointer;
   |Sym.DynArr   : display := address;
   |Sym.Array    : display := address;
   |Sym.ProcTyp  : display := uhexadecimal;
   |Sym.Record   : display := address;
   |Sym.Int      :
   |Sym.LInt     :
   |Sym.SInt     :
   |Sym.Byte     : display := udecimal;
   |Sym.Char     : display := character;
   |Sym.Bool     : display := boolean;
   |Sym.Set      : display := set;
   |Sym.Real     : display := address;
   |Sym.LReal    : display := address;
   ELSE
     display := unknown;
  END;
  RETURN display;
 END DefaultDisplay;


PROCEDURE DynArrSize*(typ: Sym.Struct; adr : LONGINT) : LONGINT;
  VAR
    len : INTEGER;
    size : LONGINT;
 BEGIN
  IF typ.form = Sym.DynArr THEN
    DEC(adr, 4);
    size := DynArrSize(typ.base,adr);
    S.GET(adr, len);
    RETURN len * size
  END;
  RETURN typ.size;
 END DynArrSize;


PROCEDURE GetViewer(m : Model; inherit : WinView.Viewer);
  VAR
    v : Viewer;
    cw,ch,d : INTEGER;
    shift : SET;
    update : BOOLEAN;
 BEGIN
  update := FALSE;
  IF inherit # NIL THEN
    shift := BIOS.Kbshift(-1);
    IF (inherit IS Viewer) AND (0 IN shift) OR (1 IN shift) THEN (* use inherited viewer *)
      v := inherit;
      update := TRUE;
    ELSE
      NEW(v); v.Initialize;
      v.x := inherit.x + 20; v.y := inherit.y + 20;
      v.w := inherit.w; v.h := inherit.h;
    END;
  ELSE
    NEW(v); v.Initialize;
    IF Db.maxY > 500 THEN
      v.SetPos(0, 400); v.SetSize( 50*8, 10*16);
    ELSE
      v.SetPos(200, v.y); v.SetSize( 30*8, 5*16);
    END;
  END;
  v.SetModel(m);
  v.SetTitle(m.name);
  Db.GetFontData(d, cw, ch);
  v.SetDataWH(VarWidth*cw, m.num*ch);
  v.Open;
(*  IF update THEN v.Update(WinView.UpdateAll) END; done by SetModel*)
 END GetViewer;


PROCEDURE GetAddr(o : Sym.Symbol; varadr : S.PTR) : S.PTR;
  VAR
    addr : S.PTR;
 BEGIN
  IF (o.form IN {Sym.Var,Sym.Fld}) OR
        (o.form = Sym.Ind) AND (o.typ.form = Sym.DynArr) THEN
    addr := varadr + o.a0;
  ELSIF o.form = Sym.Ind THEN
    S.GET(varadr + o.a0, addr);
  ELSE
    addr := S.ADR(dummy);
  END;
  RETURN addr;
 END GetAddr;


PROCEDURE NewViewer*(varadr : S.PTR; vartyp : INTEGER;
                     typ : Sym.Struct; obj : Sym.Symbol;
                     VAR name : ARRAY OF CHAR; inherit : WinView.Viewer);
  (* opens a new viewer displaying variables *)
  VAR
    v : Viewer;
    m : Model;
    num : LONGINT;
    o : Sym.Symbol;

    PROCEDURE AddBase(typ : Sym.Struct);
      VAR o : Sym.Symbol;
     BEGIN
      IF typ.base # NIL THEN
        AddBase(typ.base);
      END;
      o := typ.syms;
      WHILE o # NIL DO
        IF o.form = Sym.Fld THEN
          o.a1 := DefaultDisplay( o.typ);
(*          GetRealType(o.typ, GetAddr(o, varadr));*)
          INC(num)
        END;
        o := o.next;
      END;
     END AddBase;

 BEGIN
  v := WinView.Windows;
  WHILE v # NIL DO (* search identical model *)
    IF (v.model # NIL) AND (v.model IS Model) THEN
      m := v.model;
      IF (m.varadr = varadr) AND (m.vartyp = vartyp) AND (m.name = name) AND
         ((vartyp IN {VarTyp, RecTyp}) AND (m.obj = obj) AND (m.obj.typ = obj.typ)
         OR (vartyp IN {ArrTyp, DynArrTyp}) AND (m.typ = typ)) THEN (* found *)
        v.Open; RETURN
      END;
    END;
    v := v.nextWin;
  END;
  NEW(m); m.Initialize;
  m.typ := typ; m.obj := obj;
  COPY(name, m.name);
  num := 2;
  IF vartyp = VarTyp THEN
    o := obj;
    WHILE o # NIL DO
      IF o.form IN {Sym.Var, Sym.Ind} THEN
        o.a1 := DefaultDisplay( o.typ);
(*        GetRealType(o.typ, GetAddr(o, varadr));*)
        INC(num)
      END;
      o := o.next;
    END;
  ELSIF vartyp = ArrTyp THEN
    num := typ.n + 2;
    m.disp := DefaultDisplay( typ.base);
(*    GetRealType(typ.base, varadr);*)
  ELSIF vartyp = DynArrTyp THEN
    S.GET( varadr+4, num);
    m.disp := DefaultDisplay( typ.base);
    typ.size := DynArrSize(typ, varadr);
    typ.n := num; vartyp := ArrTyp; S.GET( varadr, varadr);
    INC(num, 2);
(*    GetRealType(typ.base, varadr);*)
  ELSIF vartyp = RecTyp THEN
    AddBase(typ);
  END;
  m.num := num;
  m.varadr := varadr; m.vartyp := vartyp;
  IF (inherit # NIL) AND (inherit IS Viewer) THEN
    m.prev := inherit.model
  ELSE m.prev := NIL
  END;
  GetViewer(m, inherit);
 END NewViewer;


PROCEDURE NewModelViewer(m : Model; inherit : WinView.Viewer);
  (* opens a new viewer displaying variables *)
  VAR
    v : Viewer;
    num : INTEGER;
    shift : SET;
    o : Sym.Symbol;
 BEGIN
  v := WinView.Windows;
  WHILE v # NIL DO				(* search identical model *)
    IF (v.model = m) THEN
      v.Open; RETURN
    END;
    v := v.nextWin;
  END;
  GetViewer(m, inherit);
 END NewModelViewer;


PROCEDURE Convert(addr : S.PTR; size : LONGINT; display : LONGINT;
                  VAR str : ARRAY OF CHAR);
  VAR byte : SHORTINT;
      word,i : INTEGER;
      vlong: LONGINT;
      long : LONGINT;
      s    : ARRAY 10 OF CHAR;
 BEGIN
  COPY("Impossible", str);
  IF display = unknown THEN
    COPY("???", str)
  ELSIF display = complex THEN
    COPY("***", str)
  ELSIF display = address THEN
    NumStr.LCardTo(addr, 16, str);
    Str.Adjust(Str.right, 8, "0", str);
    Str.AppendC("H", str); Str.InsertC("*", 0, str)
  ELSIF addr < 8000H THEN
    COPY("Invalid", str)
  ELSIF size = 1 THEN
    S.GET(addr, byte);
    CASE display OF
      sdecimal:
       NumStr.LIntTo(byte, 10, str);
     |udecimal:
       NumStr.LCardTo(S.LONG(byte), 10, str);
     |uhexadecimal:
       NumStr.LCardTo(S.LONG(byte), 16, str);
       Str.Adjust(Str.right, 2, "0", str);
       Str.AppendC("H", str);
     |shexadecimal:
       NumStr.LIntTo(byte, 16, str);
       Str.AppendC("H", str);
     |character:
       IF byte < 32 THEN
         NumStr.LCardTo(S.LONG(byte), 16, str);
         Str.Adjust(Str.right, 2, "0", str);
         Str.AppendC("X", str);
       ELSE
         COPY('" "', str); str[1] := CHR(byte)
       END;
     |string:
       COPY("' ", str);
       str[1] := CHR(byte);
       Str.AppendC("'", str);
     |boolean:
       IF byte = 0 THEN COPY("FALSE", str)
       ELSIF byte = 1 THEN COPY("TRUE", str)
       ELSE COPY("Invalid", str)
       END;
     |ELSE
    END;
  ELSIF size = 2 THEN
    S.GET(addr, word);
    CASE display OF
      sdecimal:
       NumStr.LIntTo(word, 10, str);
     |udecimal:
       NumStr.LCardTo(S.LONG(word), 10, str);
     |uhexadecimal:
       NumStr.LCardTo(S.LONG(word), 16, str);
       Str.Adjust(Str.right, 4, "0", str);
       Str.AppendC("H", str);
     |shexadecimal:
       NumStr.LIntTo(word, 16, str);
       Str.AppendC("H", str);
     |string:
       COPY("'  ", str);
       str[1] := CHR(word DIV 256);
       str[2] := CHR(word);
       Str.AppendC("'", str);
     |ELSE
    END;
  ELSIF size = 4 THEN
    S.GET(addr, long);
    CASE display OF
      sdecimal:
       NumStr.LIntTo(long, 10, str);
     |udecimal:
       NumStr.LCardTo(long, 10, str);
     |uhexadecimal:
       NumStr.LCardTo(long, 16, str);
       Str.Adjust(Str.right, 8, "0", str);
       Str.AppendC("H", str);
     |pointer:
       IF long = 0 THEN
         COPY("NIL", str)
       ELSE
         NumStr.LCardTo(long, 16, str);
         Str.Adjust(Str.right, 8, "0", str);
         Str.AppendC("H", str);
       END;
     |shexadecimal:
       NumStr.LIntTo(long, 16, str);
       Str.AppendC("H", str);
     |string:
       COPY("'    ", str);
       str[1] := CHR(long DIV 1000000H);
       str[2] := CHR(long DIV 10000H);
       str[3] := CHR(long DIV 100H);
       str[4] := CHR(long);
       Str.AppendC("'", str);
     |real:
       NumStr.RealTo(S.VAL(REAL, long), 4, str);
     |set:
       str[0] := "{"; str[1] := 0X;
       FOR i := 0 TO 31 DO
         IF ODD(long) THEN
           IF str[1] # 0X THEN Str.AppendC(",", str) END;
           NumStr.IntTo( i, 10, s);
           IF Str.Length(str) + Str.Length(s) >= TypBeg - ValBeg THEN
             RETURN
           END;
           Str.Append(s, str);
         END;
         long := long DIV 2;
       END;
       Str.AppendC("}", str);
     |ELSE
    END;
  ELSIF size = 8 THEN
    S.GET(addr, long);
    S.GET(addr+4, vlong);
    CASE display OF
     uhexadecimal:
       NumStr.LCardTo(long, 16, str);
       NumStr.LCardTo(vlong, 16, s);
       Str.Adjust(Str.right, 8, "0", s);
       Str.Adjust(Str.right, 8, "0", str);
       Str.Append( s, str); Str.AppendC("H", str);
     |string:
       COPY("'        ", str);
       str[1] := CHR(long DIV 1000000H);
       str[2] := CHR(long DIV 10000H);
       str[3] := CHR(long DIV 100H);
       str[4] := CHR(long);
       str[5] := CHR(vlong DIV 1000000H);
       str[6] := CHR(vlong DIV 10000H);
       str[7] := CHR(vlong DIV 100H);
       str[8] := CHR(vlong);
       Str.AppendC("'", str);
     |lreal:
       NumStr.LRealTo(S.VAL(LONGREAL, long), 4, str);
     |ELSE
    END;
  ELSE
    CASE display OF
     uhexadecimal:
       i := 0; str[0] := 0X;
       WHILE (i < size) AND (i < 16) DO
         S.GET(addr + LONG(i), byte);
         NumStr.LCardTo(S.LONG(byte), 16, s);
         Str.Adjust(Str.right, 2, "0", s);
         IF Str.Length(str) + Str.Length(s) >= TypBeg - ValBeg THEN
           RETURN
         END;
         Str.Append(s, str);
         INC(i);
       END;
       Str.AppendC("H", str);
     |string:
       str[0] := "'"; i := 0;
       WHILE (i < size) AND (i < TypBeg - ValBeg - 1) DO
         S.GET(addr + LONG(i), str[i+1]);
         INC(i);
       END;
       str[i+1] := 0X;
       Str.AppendC("'", str);
     |ELSE
    END;
  END;
 END Convert;


PROCEDURE GetTypeDef(obj: Sym.Symbol; t : Sym.Struct; adr : S.PTR;
                     VAR typedef : ARRAY OF CHAR);
  VAR
    u,o, first: Sym.Symbol;
    mod: Sym.Symbol;
    s  : ARRAY 40 OF CHAR;

    PROCEDURE Find(VAR u: Sym.Symbol);
     BEGIN
      WHILE (u # NIL) & ((u.form # Sym.Typ) OR ~Sym.SameType(t, u.typ)) DO
        u := u.next;
      END(*WHILE*);
     END Find;

 BEGIN
  u := Sym.global;
  Find(u);
  IF u#NIL THEN
    Str.Append(u.name, typedef); RETURN ;
  END;
  u := Sym.system.syms;
  Find(u);
  IF u#NIL THEN
    Str.Append("SYSTEM.", typedef);
    Str.Append(u.name, typedef); RETURN ;
  END;
  u   := obj;
  mod := NIL;
  o   := obj;
  first := obj;
  REPEAT
    Find(u);
    IF u#NIL THEN
      IF mod # NIL THEN
        Str.Append(mod.name,typedef); Str.AppendC(".", typedef);
      END(*IF*);
      Str.Append(u.name,typedef);
      RETURN;
    ELSE
      mod := NIL;
      WHILE (o # NIL) & (mod = NIL) DO
        IF o.form = Sym.Mod THEN mod := o END;
        o := o.next;
      END;
      IF (o = NIL) & (mod = NIL) THEN
        IF first # NIL THEN
          first := first.syms;
          IF first # NIL THEN
            o := first; u := first;
          END;
        END;
      ELSE
        u := mod.syms;
      END;
    END;
  UNTIL first = NIL;
  (* write Type *)
  CASE t.form OF
    Sym.Pointer  : Str.Append("POINTER TO ", typedef);
                   GetTypeDef(obj, t.base, NIL, typedef);
   |Sym.DynArr   : Str.Append("ARRAY OF ", typedef);
                   GetTypeDef(obj, t.base, NIL, typedef);
   |Sym.Array    : Str.Append("ARRAY ", typedef);
                   NumStr.LIntTo(t.n, 10, s);
                   Str.Append(s, typedef);
                   Str.Append(" OF ", typedef);
                   GetTypeDef(obj, t.base, NIL, typedef);
   |Sym.ProcTyp  : Str.Append("PROCEDURE ...", typedef);
   |Sym.Record   : Str.Append("RECORD ...", typedef);
  ELSE
    Str.Append("!!!UNKNOWN!!!", typedef);
  END(*CASE*);
 END GetTypeDef;


PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR
    DistBaseTop,charW,charH, xOff, n : INTEGER;
    y2,l,maxY : LONGINT;
    s   : ARRAY 80 OF CHAR;
    m   : Model;
    o   : Sym.Symbol;
    typ : Sym.Struct;
    adr : S.PTR;
 BEGIN
  v.Redraw^(x,y,w,h);			(* redraws background *)
  VC.VsClip( Db.station, TRUE, x, y, x+w-1, y+h-1);
  Db.GetFontData(DistBaseTop, charW, charH);
  y2 := v.y - v.yOff;
  maxY := y + h; l := v.y + v.dh - v.yOff;
  IF l < maxY THEN
    maxY := l
  END;
  xOff := v.x - SHORT(v.xOff);
  m := v.model;
  IF y2 + charH > y THEN		(* if y inside rect then backptr *)
    VO.VGtext( Db.station, xOff+20, SHORT(y2) + DistBaseTop, m.name);
  END;
  INC(y2, charH);
  IF y2 + charH > y THEN		(* if y inside rect then header *)
    VO.VGtext( Db.station, xOff, SHORT(y2) + DistBaseTop, "Name");
    VO.VGtext( Db.station, xOff+ValBeg*charW, SHORT(y2) + DistBaseTop, "Wert");
    VO.VGtext( Db.station, xOff+TypBeg*charW, SHORT(y2) + DistBaseTop, "Typ");
  END;
  INC(y2, charH);
  o := m.obj; typ := m.typ;
  WHILE y2 < maxY DO
    IF m.vartyp IN {VarTyp, RecTyp} THEN
      WHILE (o = NIL) AND (typ # NIL) AND (typ.base # NIL) DO
        typ := typ.base;
        o := typ.syms;
      END;
      WHILE (o # NIL) AND NOT (o.form IN {Sym.Fld, Sym.Var, Sym.Ind}) DO
        o := o.next;
        WHILE (o = NIL) AND (typ # NIL) AND (typ.base # NIL) DO
          typ := typ.base;
          o := typ.syms;
        END;
      END;
    END;
    IF y2 + charH > y THEN		(* if y inside rect then *)
      IF m.vartyp IN {VarTyp, RecTyp} THEN
        IF o # NIL THEN
          VO.VGtext( Db.station, xOff, SHORT(y2) + DistBaseTop, o.name);(* name *)
          adr := GetAddr(o, m.varadr);
          Convert(adr, o.typ.size, o.a1, s);			(* val *)
          VO.VGtext( Db.station, xOff+ValBeg*charW, SHORT(y2) + DistBaseTop, s);
          s[0] := 0X; GetTypeDef(m.obj, o.typ, adr, s);		(* typ *)
          VO.VGtext( Db.station, xOff+TypBeg*charW, SHORT(y2) + DistBaseTop, s);
        END;
      ELSIF m.vartyp = ArrTyp THEN
        n := SHORT((y2 + v.yOff - v.y) DIV charH - 2);
        IF (n >= 0) AND (n < typ.n) THEN
          NumStr.IntTo(n, 10, s);
          Str.InsertC("[", 0, s); Str.AppendC("]", s);
          VO.VGtext( Db.station, xOff, SHORT(y2) + DistBaseTop, s);(* index *)
          adr := m.varadr+n*typ.base.size;
          Convert(adr, typ.base.size, m.disp, s);		(* val *)
          VO.VGtext( Db.station, xOff+ValBeg*charW, SHORT(y2) + DistBaseTop, s);
          s[0] := 0X; GetTypeDef(m.obj, typ.base, adr, s);		(* typ *)
          VO.VGtext( Db.station, xOff+TypBeg*charW, SHORT(y2) + DistBaseTop, s);
        END;
      END;
    END;
    IF (m.vartyp IN {VarTyp, RecTyp}) AND (o # NIL) THEN
      o := o.next;
    END;
    INC(y2, charH);
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
    Db.GetFontData( d, cw, ch);
    CASE S.ANL( aspect, 0FFFFH) OF
     |2: (* value *)
        IF v.model(Model).vartyp = ArrTyp THEN
          v.UpdateRect( v.x - SHORT(v.xOff) + ValBeg*cw,
                        v.y, (TypBeg-ValBeg)*cw, v.h );
          RETURN
        END;
        start := ValBeg; width := TypBeg - ValBeg;
     |3: (* type *)
        start := TypBeg; width := VarWidth - TypBeg;
     |4: (* value and type *)
        start := ValBeg; width := VarWidth - ValBeg;
    END;
    v.UpdateRect( v.x - SHORT(v.xOff) + start*cw,
                  v.y + SHORT((aspect DIV 10000H + 2) * ch - v.yOff),
                  width*cw, ch );
  END;
 END Update;


PROCEDURE Dereference(obj : Sym.Symbol; viewer : Viewer; varadr : S.PTR);
  VAR name : ARRAY 80 OF CHAR;
      addr : S.PTR;
      typ  : Sym.Struct;
 BEGIN
  IF (varadr < 1000H) OR (varadr >= 10000000H) THEN
    RETURN
  END;
  typ := obj.typ;
  CASE typ.form OF
    Sym.Pointer :
      typ := typ.base;
      COPY(obj.name, name); Str.AppendC("^", name);
      S.GET( varadr, addr);
      IF (addr < 1000H) OR (addr >= 10000000H) THEN
        RETURN
      END;
      IF typ.form = Sym.Record THEN
        NewViewer(addr, RecTyp, typ, typ.syms, name, viewer);
      ELSIF typ.form = Sym.Array THEN
        NewViewer(addr, ArrTyp, typ, NIL, name, viewer);
      ELSIF typ.form = Sym.DynArr THEN
        NewViewer(addr, DynArrTyp, typ, NIL, name, viewer);
      END;
   |Sym.Record  :
      COPY(obj.name, name);
      Str.AppendC(".", name);
      NewViewer(varadr, RecTyp, typ, typ.syms, name, viewer);
   |Sym.Array   :
      COPY(obj.name, name);
      Str.Append("[]", name);
      NewViewer(varadr, ArrTyp, typ, NIL, name, viewer);
   |Sym.DynArr  :
      COPY(obj.name, name);
      Str.Append("[]", name);
      NewViewer(varadr, DynArrTyp, typ, NIL, name, viewer);
   ELSE
  END;
 END Dereference;


PROCEDURE ChangeDisplay(display : INTEGER);
 BEGIN
  selViewer.model(Model).disp := display;
  selObj.a1 := display;
  IF selObj.a0 < 0 THEN
    selViewer.model.Changed( WinView.UpdateAll);
  ELSE
    selViewer.model.Changed(selItem);
  END;
 END ChangeDisplay;


PROCEDURE(v : Viewer) HandleButtonEvent(mbut : SET; mx, my, clicks : INTEGER)
    : BOOLEAN;
  (* is called if WinView.HandleEvent detects a button event in the work
     area of viewer v *)
  VAR
    posx, posy, d, cw, ch : INTEGER;
    m : Model;
    o : Sym.Symbol;
    varadr : S.PTR;
    obj : Sym.SymbolD;
    typ : Sym.Struct;
    v2  : WinView.Viewer;
 BEGIN
  Db.GetFontData(d, cw, ch);
  posx := (mx - v.x + SHORT(v.xOff) ) DIV cw;
  posy := SHORT((my - v.y + v.yOff ) DIV ch - 2);
  IF posy = -2 THEN (* back *)
    m := v.model(Model).prev;
    IF m # NIL THEN
      v2 := WinView.Windows;
      WHILE v2 # NIL DO (* search viewer displaying prev *)
        IF v2.model = m THEN (* found *)
          v2.Open; RETURN TRUE(* top *)
        END;
        v2 := v2.nextWin;
      END;
      NewModelViewer(m, v);
    END;
  END;
  IF posy < 0 THEN RETURN TRUE END;		(* first two lines *)
  m := v.model; typ := m.typ;
  IF m.vartyp IN {VarTyp, RecTyp} THEN
    o := m.obj; d := posy;
    WHILE NOT (o.form IN {Sym.Var, Sym.Ind, Sym.Fld}) DO
      o := o.next;
      WHILE (o = NIL) AND (typ # NIL) AND (typ.base # NIL) DO
        typ := typ.base;
        o := typ.syms;
      END;
      IF o = NIL THEN RETURN TRUE END;
    END;
    WHILE d > 0 DO
      REPEAT
        o := o.next;
        WHILE (o = NIL) AND (typ # NIL) AND (typ.base # NIL) DO
          typ := typ.base;
          o := typ.syms;
        END;
        IF o = NIL THEN RETURN TRUE END;
      UNTIL o.form IN {Sym.Var, Sym.Ind, Sym.Fld};
      DEC(d);
    END;
    varadr := GetAddr(o, m.varadr);
  ELSIF posy >= typ.n THEN RETURN TRUE
  ELSE
    NumStr.IntTo(posy, 10, obj.name);
    Str.InsertC("[", 0, obj.name); Str.AppendC("]", obj.name);
    obj.typ := m.typ.base;
    varadr := m.varadr + posy * obj.typ.size;
    o := S.ADR(obj); o.a1 := m.disp;
    o.a0 := -1;
  END;
  selViewer := v;
  selVarAdr := varadr; selObj := o;
  IF posx < ValBeg THEN			(* variable name selected *)
    Dereference(o, v, varadr);
  ELSIF posx < TypBeg THEN		(* var value selected *)
    selItem := posy * 10000H + 2;
    IF o.a1 = address THEN
      Selected.addr := varadr;
    ELSE
      S.GET(varadr, Selected.addr);
    END;
    Selected.varMenu.Show;
  ELSIF posx < VarWidth THEN		(* typ selected *)
    selItem := posy * 10000H + 3;
(*    Dial.typeDial.Do(Dial.TYPESTRING);*)
  END;
  RETURN TRUE
 END HandleButtonEvent;


PROCEDURE ChangeType;
 BEGIN
 END ChangeType;


PROCEDURE Init*;
 BEGIN
 END Init;


PROCEDURE Exit*;
 BEGIN
  selObj := NIL;
  selViewer := NIL;
 END Exit;


BEGIN
  Selected.NewVariableViewer := NewViewer;
  Selected.ChangeDisplay := ChangeDisplay;
(*  Dial.ChangeType := ChangeType;*)
END Variables.