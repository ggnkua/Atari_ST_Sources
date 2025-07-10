MODULE Mass51;

(* History :
   SJ  18.3.93  : started
       19.3.93  : 8051 commands, two passes
       20.3.93  : CodeClr corrected, MAS.Reinit and MAS.Close called,
                  FileBuffer used, macros added
       21.3.93  : include, local, segment, org, expressions
       22.3.93  : charset, irp, rept, align
       23.3.93  : symbol output
       24.3.93  : special format
       25.3.93  : V1.00 ready
       6.4.93   : little corrections
       12.4.93  : loop,ifc,repeat,for,exit
       14.4.93  : org works now with values smaller than actual cloc
       29.4.93  : correction for load time linking
       21.5.93  : error output better
       20.6.93  : error with ToEndif and MacroPar corrected
*)

IMPORT S:=SYSTEM, File, MAS:=MAS51, IO, FN:=Filename, FB:=FileBuffer, Sys,
       Paths, Str:=Strings, MasPar, Stack, Task, NumStr, CL:=CommandLine;

CONST
  (*symbol values*)
   times = 1; slash = 2; xor = 3; not = 7; and = 5; plus = 9; minus = 10;
   or = 11; arrow = 6; imm = 4; mod = 4; lss = 17; leq = 12; gtr = 13;
   geq = 14; in = 18; neq = 16; eql = 15; comma = 19; notl = 8;
   colon = 20; ask = 21; rparen = 22; rbrak = 23; rbrace = 24; then = 26;
   do = 27; lparen = 29; lbrak = 30; lbrace = 31; ifc = 32; assign = 33;
   number = 34; string = 36; ident = 37;
   semicolon = 38; for = 39; end = 40; else = 41; elsif = 42; until = 43;
   if = 44; repeat = 47; loop = 48; exitt = 50;
   eof = 62; equ = 63; set = 64; sfr = 65; sfrb = 66; bit = 67; charset = 68;
   org = 69; cpu = 70; segment = 71; code = 72; data = 73; xdata = 74;
   idata = 75; bitdata = 76; db = 77; dw = 78; dd = 79; align = 80;
   macro = 81; endm = 82; irp = 83; rept = 84; elseif = 85; endif = 86;
   ifdef = 87; ifndef = 88; page = 89; newpage = 90; macexp = 91;
   on = 92; off = 93; listing = 94; prtinit = 95; prtexit = 96; title = 97;
   shared = 98; include = 99; message = 100; warning = 101; error = 102;
   fatal = 103; b = 104; w = 105; l = 106; lc = 107; true = 108;
   false = 109; version = 110; ind = 111; ds = 112; output = 113;
   binary = 114; special = 115; toupper = 116; upstring = 117; opt = 118;
   local = 119; global = 120; def = 122;
   a = 140; c = 141; dptr = 142; pc = 143; r0 = 144; r1 = 145; r2 = 146;
   r3 = 147; r4 = 148; r5 = 149; r6 = 150; r7 = 151; ab = 152;
   acall = 155; call = 156; add = 157; addc = 158; ajmp = 159;
   jmp = 160; anl = 161; cjne = 162; clr = 163; cpl = 164; da = 165;
   dec = 166; div = 167; djnz = 168; inc = 169; jb = 170;
   jbc = 171; jc = 172; jnb = 173; jnc = 174; jnz = 175; jz = 176;
   lcall = 177; ljmp = 178; mov = 179; movc = 180; movx = 181;
   nop = 182; mul = 183; orl = 184; pop = 185; push = 186; ret = 187;
   reti = 188; rl = 189; rlc = 190; rr = 191; rrc = 192; setb = 193;
   sjmp = 194; subb = 195; swap = 196; xch = 197; xchd = 198; xrl = 199;

  (* addressing modes *)
   None = 0; A = 1; AB = 2; C = 3; Rn = 4; Ri = 5; DPTR = 6; ADPTR = 7;
   APC = 8; DPTRI = 9; Dir = 10; Imm = 11; Addr11 = 12; Addr16 = 13;
   Rel = 14; Bit = 15; NBit = 16;

  (* error numbers *)
   strend = 2; illmode = 4; syntax = 5; valexp = 10; offshi = 7; unknown = 8;
   double = 17; macroexp = 11; fewer = 12; nomac = 13; codeonly = 14;
   segexp = 26; noinc = 16; parexp = 18; sechi = 20; notcode = 21;
   range = 25; segerr = -1; nostruct = 27; onoffexp = 28; nosfrb = 29;

  (* ident types *)
   Clab = 0; Dlab = 1; Xlab = 2; Blab = 3; Macro = 4; MacroPar = 5;
   Ccon = 6; Dcon = 7; Xcon = 8; Bcon = 9; Cvar = 10; Dvar = 11;
   Xvar = 12; Bvar = 13; Notype = -1;

  (* segment types *)
   codeseg = 0; dataseg = 1; xdataseg = 2; bdataseg = 3;

   KW = 43;  (*size of hash table*)
   Version = 101H; specoff = 9;

TYPE
  file   = POINTER TO loaded;
  loaded = RECORD
             Next  : file;
             Begad : LONGINT;
             Name  : FN.path
           END;
  ifset  = POINTER TO ifdesc;
  ifdesc = RECORD
             Next  : ifset;
             Runad : LONGINT;
           END;
  exit   = POINTER TO exitdesc;
  exitdesc = RECORD
               Prev : exit;
               i    : INTEGER;
               Pos  : ARRAY 20 OF LONGINT;
             END;
  str = ARRAY 256 OF CHAR;
  StackElem = RECORD(Stack.ElemDesc)
                On : BOOLEAN;
              END;
  StackPtr  = POINTER TO StackElem;

VAR sym,seg : INTEGER;
    cloc,dloc,xloc,bloc,CPU,IfId,Value2 : LONGINT;
    Global : MAS.tabdef;
    Pass2,BinInit,SpecInit,GetValOff : BOOLEAN;
    bf,sf : FB.file;
    Files : file; Ifs : ifset;
    BinName,SpecName : FN.path;
    Exits : exit;
    PrevListOn, LastStackElem : Stack.Stack;
    CurrName : FN.path;
    globalSymbolFile : BOOLEAN;


PROCEDURE WriteBin(Byte : INTEGER);
 BEGIN
  IF MasPar.Bin AND NOT BinInit THEN
    BinInit := FB.Open(BinName,64*1024,bf);
  END;
  IF BinInit THEN FB.WriteByte(bf,SHORT(Byte)) END;
 END WriteBin;

PROCEDURE WriteSpec(Byte : INTEGER);
 BEGIN
  IF MasPar.Spec AND NOT SpecInit THEN
    SpecInit := FB.Open(SpecName,64*1024,sf);
    FB.WriteWord(sf,8914H); FB.WriteByte(sf,31H);
    FB.WriteLong(sf,0); FB.WriteWord(sf,0);
  END;
  IF SpecInit THEN FB.WriteByte(sf,SHORT(Byte)) END;
 END WriteSpec;

PROCEDURE CloseSpec;
 BEGIN
  IF SpecInit THEN
    FB.WriteByte(sf,0); FB.WriteChars(sf,"MASS 1.00");
    FB.Seek(sf,FB.absbeg,7);
    FB.WriteWord(sf,SHORT(cloc DIV 256 + cloc * 256));
    FB.Close(sf);
  END;
 END CloseSpec;

PROCEDURE StoreByte(Byte : INTEGER);
  (* stores the lower 8 bit of Byte in the code and increments loc *)
 BEGIN
  IF Pass2 AND (seg = codeseg) THEN
    WriteBin(Byte); WriteSpec(Byte); MAS.ListByte(Byte);
  END;
  IF seg # codeseg THEN MAS.Mark(codeonly)
  ELSE INC(cloc)
  END;
 END StoreByte;

PROCEDURE ChangeByte(Byte : INTEGER);
  (* stores the lower 8 bit of Byte in the code and increments loc *)
 BEGIN
  IF Pass2 AND (seg = codeseg) THEN
    WriteBin(Byte); WriteSpec(Byte);
  END;
  IF seg # codeseg THEN MAS.Mark(codeonly) END;
 END ChangeByte;

PROCEDURE StoreXByte(Byte : LONGINT);
  (* stores the lower 8 bit of Byte in the code and increments loc *)
 BEGIN
  StoreByte(SHORT(Byte));
 END StoreXByte;

PROCEDURE Loc() : LONGINT;
  (* returns the current location counter *)
 BEGIN
  CASE seg OF
    codeseg : RETURN cloc |
    dataseg : RETURN dloc |
    xdataseg: RETURN xloc |
    bdataseg: RETURN bloc |
  END;
 END Loc;

PROCEDURE SetPos(Pos : LONGINT);
 BEGIN
  IF Pass2 AND MasPar.Bin THEN FB.Seek(bf,FB.absbeg,Pos) END;
  IF Pass2 AND MasPar.Spec THEN FB.Seek(sf,FB.absbeg,Pos+specoff) END;
 END SetPos;

PROCEDURE SetLoc(Loc : LONGINT);
  (* sets the current location counter *)
 BEGIN
  CASE seg OF
    codeseg :
      IF Loc < cloc THEN SetPos(Loc); cloc := Loc;
      ELSIF NOT Pass2 THEN cloc := Loc
      ELSIF BinInit AND (Loc <= bf.Length) OR
            SpecInit AND (Loc <= sf.Length-specoff) THEN
        SetPos(Loc); cloc := Loc;
      ELSE
        IF BinInit AND (cloc # bf.Length) THEN
          cloc := bf.Length; SetPos(cloc);
        ELSIF SpecInit AND (cloc # sf.Length-specoff) THEN
          cloc := sf.Length-specoff; SetPos(cloc);
        END;
        WHILE cloc < Loc DO StoreByte(0) END;
      END |
    dataseg : dloc := Loc |
    xdataseg: xloc := Loc |
    bdataseg: bloc := Loc |
  END;
 END SetLoc;

PROCEDURE IncLoc(Add : LONGINT);
  (* increments the current location counter *)
 BEGIN
  CASE seg OF
    codeseg :
      IF Pass2 THEN WHILE Add > 0 DO StoreByte(0); DEC(Add) END;
      ELSE INC(cloc,Add)
      END |
    dataseg : INC(dloc,Add) |
    xdataseg: INC(xloc,Add) |
    bdataseg: INC(bloc,Add) |
  END;
 END IncLoc;

PROCEDURE ClearKeyTab(VAR KeyTab : MAS.keytab);
  (* deletes all pointers so that the table is free *)
  VAR i : INTEGER;
 BEGIN
  i := KW;
  REPEAT DEC(i); KeyTab[i] := NIL UNTIL i = 0;
 END ClearKeyTab;

PROCEDURE SearchCurr(VAR Value : LONGINT; VAR Type : INTEGER) : BOOLEAN;
  (* tries to find MAS.name in the current table. Returns FALSE if not
     found *)
 BEGIN
  MAS.Label := MAS.CurrTab.KeyTab[MAS.Hash];
	WHILE MAS.Label # NIL DO
		IF MAS.Label.Id = MAS.name THEN Value := MAS.Label.Val;
		  Type := MAS.Label.Type; RETURN TRUE
		END;
		MAS.Label := MAS.Label.Next;
	END;
 	RETURN FALSE;
 END SearchCurr;

PROCEDURE Find(VAR Value : LONGINT; VAR Type : INTEGER) : BOOLEAN;
  (* tries to find MAS.name in the current table and in upper ones. Marks
     an error if not found (only Pass2) *)
 BEGIN
  IF MAS.Search(Value,Type) THEN RETURN TRUE
  ELSIF Pass2 THEN MAS.Mark(unknown)
  END;
  RETURN FALSE
 END Find;

PROCEDURE EnterNew(Value : LONGINT; Type : INTEGER; Glob : BOOLEAN);
	(* enters a new symbol in MAS.CurrTab. Marks an error if already defined *)
  VAR k: INTEGER;
 BEGIN
  k := MAS.Hash; NEW(MAS.Label);
  IF Glob THEN MAS.Label.Next := Global.KeyTab[k];
    Global.KeyTab[k] := MAS.Label
  ELSE MAS.Label.Next := MAS.CurrTab.KeyTab[k];
    MAS.CurrTab.KeyTab[k] := MAS.Label
  END;
  MAS.Label.Val := Value; COPY(MAS.name,MAS.Label.Id); MAS.Label.Type := Type;
  MAS.Label.Global := Glob; COPY(MAS.Text.Name,MAS.Label.File);
  MAS.Label.Begad := MAS.Text.Begad;
 END EnterNew;

PROCEDURE Enter2(Value : LONGINT; Type : INTEGER; Glob : BOOLEAN);
	(* enters a symbol in MAS.CurrTab. Overwrites it if already defined *)
  VAR Typ : INTEGER; Val : LONGINT;
 BEGIN
  IF (Glob AND MAS.Search(Val,Typ)) OR
     (NOT Glob AND SearchCurr(Val,Typ)) THEN
    MAS.Label.Val := Value; MAS.Label.Type := Type;
    COPY(MAS.Text.Name,MAS.Label.File); MAS.Label.Begad := MAS.Text.Begad;
  ELSE EnterNew(Value,Type,Glob)
  END;
 END Enter2;

PROCEDURE Enter(Value : LONGINT; Type : INTEGER; Glob : BOOLEAN);
	(* enters a new symbol in MAS.CurrTab. Marks an error if already defined *)
 BEGIN
  IF Pass2 THEN Enter2(Value,Type,Glob)
  ELSIF (Glob AND MAS.Search(Value,Type)) OR
     (NOT Glob AND SearchCurr(Value,Type)) THEN MAS.Mark(double)
  ELSE EnterNew(Value,Type,Glob)
  END;
 END Enter;

PROCEDURE CheckSym(s: INTEGER);
 BEGIN
  IF sym = s THEN MAS.Get(sym) ELSE MAS.Mark(s) END
 END CheckSym;

PROCEDURE^ GetValue(VAR Mode : INTEGER; VAR Value : LONGINT);

PROCEDURE^ SimpleExpression(VAR Mode : INTEGER; VAR Value : LONGINT;
                            VAR String : str);

PROCEDURE StringExpression(VAR String : str);
  VAR Mode : INTEGER; Value : LONGINT;
 BEGIN
  MAS.Get(sym);
  IF sym = string THEN SimpleExpression(Mode,Value,String);
    IF Mode # string THEN MAS.Mark(string) END;
  ELSE MAS.Mark(string); String[0] := 0X
  END;
 END StringExpression;

PROCEDURE Ident;
  VAR String : str; FirstChar : BOOLEAN;
 BEGIN
  IF sym = lbrak THEN FirstChar := MAS.FirstChar;
    StringExpression(String);
    IF sym # rbrak THEN MAS.Mark(rbrak) END;
    COPY(String,MAS.name);
    sym := ident; MAS.FirstChar := FirstChar;
  END;
 END Ident;

PROCEDURE Factor(VAR Mode : INTEGER; VAR Value : LONGINT; VAR String : str);
  VAR Type : INTEGER; IntAd : LONGINT; c : CHAR;

 BEGIN
  Ident;
  IF sym = number THEN Value := MAS.intval; MAS.Get(sym);
  ELSIF sym = string THEN COPY(MAS.name,String); Mode := string;
    MAS.Get(sym);
  ELSIF sym = ident THEN
    IF Find(Value,Type) AND (Type = Macro) THEN MAS.Mark(nomac) END;
    IF Pass2 AND (Type # Notype) THEN
      IF Type >= Cvar THEN DEC(Type,Cvar)
      ELSIF Type >= Ccon THEN DEC(Type,Ccon)
      END;
      IF Mode # None THEN
        IF ((Mode = Bit) OR (Mode = NBit)) AND (Type # Blab) OR
           (Mode = Addr16) AND (Type # Clab) OR
           (Mode = Dir) AND (Type # Dlab) THEN
          MAS.Mark(segerr)
        END;
      ELSE
        IF Type = Blab THEN Mode := Bit
        ELSIF Type = Clab THEN Mode := Addr16
        ELSIF Type = Dlab THEN Mode := Dir
        END;
      END;
    END;
    MAS.Get(sym);
  ELSIF sym = lparen THEN MAS.Get(sym);
    GetValue(Mode,Value); CheckSym(rparen);
  ELSIF sym = lc THEN Value := cloc; Mode := Addr16; MAS.Get(sym);
  ELSIF sym = version THEN Value := Version; MAS.Get(sym);
  ELSIF sym = cpu THEN Value := CPU; MAS.Get(sym);
  ELSIF sym = not THEN
    MAS.Get(sym); Factor(Mode,Value,String); Value := S.NTL(Value);
    IF Mode = string THEN MAS.Mark(valexp); Mode := None END;
  ELSIF sym = notl THEN
    MAS.Get(sym); Factor(Mode,Value,String);
    IF Value = 0 THEN Value := 1 ELSE Value := 0 END;
    IF Mode = string THEN MAS.Mark(valexp); Mode := None END;
  ELSIF sym = toupper THEN MAS.Get(sym); CheckSym(lparen);
    GetValue(Mode,Value); CheckSym(rparen); c := CHR(Value);
    Str.Cap(c); Value := ORD(c);
  ELSIF sym = upstring THEN MAS.Get(sym); CheckSym(lparen);
    IF sym = string THEN COPY(MAS.name,String); Str.Caps(String);
      MAS.Get(sym); CheckSym(rparen); Mode := string;
    ELSE MAS.Mark(string)
    END;
  ELSIF sym = def THEN MAS.Get(sym); CheckSym(lparen); Ident;
    IF sym = ident THEN Value := S.VAL(SHORTINT,MAS.Search(Value,Mode));
    ELSE MAS.Mark(ident)
    END;
    MAS.Get(sym); CheckSym(rparen);
  ELSE MAS.Mark(valexp);
  END;
 END Factor;

PROCEDURE Term(VAR Mode : INTEGER; VAR Value : LONGINT; VAR String : str);
  VAR mulop, Mode2: INTEGER; Val,Val2,Val3 : LONGINT;
 BEGIN
  Factor(Mode,Val,String);
  WHILE (times <= sym) & (sym <= arrow) DO Mode2 := None;
    IF Mode = string THEN MAS.Mark(valexp); Mode := None END;
    mulop := sym; MAS.Get(sym); Factor(Mode2,Val2,String);
    IF Mode2 = string THEN MAS.Mark(valexp); Mode := None END;
    IF (Mode = None) AND (Mode2 # None) THEN Mode := Mode2 END;
    CASE mulop OF
      times : Val := Val * Val2 |
      slash : Val := Val DIV Val2 |
      xor : Val := S.XOL(Val,Val2) |
      and : Val := S.ANL(Val,Val2) |
      arrow : Val3 := Val;
        WHILE Val2 # 0 DO
          Val := Val * Val3; DEC(Val2);
        END |
      mod : Val := Val MOD Val2 |
    END;
  END;
  Value := Val;
 END Term;

PROCEDURE SimpleExpression(VAR Mode : INTEGER; VAR Value : LONGINT;
                           VAR String : str);
  VAR addop,Mode2 : INTEGER; Val,Val2 : LONGINT;
      String2 : str;
 BEGIN
  IF GetValOff THEN Value := 0;
    WHILE (sym # rbrace) AND NOT MAS.LineFeed DO MAS.Get(sym) END;
    RETURN
  END;
  IF sym = minus THEN MAS.Get(sym); Term(Mode,Val,String); Val := -Val;
    IF Mode = string THEN MAS.Mark(valexp); Mode := None END;
  ELSIF sym = plus THEN MAS.Get(sym); Term(Mode,Val,String);
    IF Mode = string THEN MAS.Mark(valexp); Mode := None END;
  ELSE Term(Mode,Val,String)
  END;
  WHILE (plus <= sym) & (sym <= or) DO Mode2 := None;
    IF (Mode = string) AND (sym # plus) THEN
      MAS.Mark(valexp); Mode := None
    END;
    addop := sym; MAS.Get(sym); Term(Mode2,Val2,String2);
    IF (Mode2 = string) AND ((addop # plus) OR (Mode # string)) THEN
      MAS.Mark(valexp); Mode2 := None
    END;
    IF (Mode = None) AND (Mode2 # None) THEN Mode := Mode2 END;
    CASE addop OF
      plus :
        IF Mode # string THEN Val := Val + Val2
        ELSE Str.Append(String2,String)
        END |
      minus : Val := Val - Val2 |
      or : Val := S.ORL(Val,Val2) |
    END;
  END;
  Value := Val;
 END SimpleExpression;

PROCEDURE Expression(VAR Mode : INTEGER; VAR Value : LONGINT);
  VAR relation,Mode2 : INTEGER; Val1,Val2 : LONGINT; Erg : BOOLEAN;
      String,String2 : str;
 BEGIN
  SimpleExpression(Mode,Val1,String);
  IF (leq <= sym) & (sym <= lss) THEN Mode2 := None;
    relation := sym; MAS.Get(sym); SimpleExpression(Mode2,Val2,String2);
    IF (Mode = string) AND (Mode2 # string) OR
       (Mode2 = string) AND (Mode # string) THEN
      MAS.Mark(valexp); Mode2 := None
    END;
    CASE relation OF
      lss :
        IF Mode # string THEN Erg := Val1 < Val2
        ELSE Erg := String < String2; Mode := None
        END |
      leq :
        IF Mode # string THEN Erg := Val1 <= Val2
        ELSE Erg := String <= String2; Mode := None
        END |
      gtr :
        IF Mode # string THEN Erg := Val1 > Val2
        ELSE Erg := String > String2; Mode := None
        END |
      geq :
        IF Mode # string THEN Erg := Val1 >= Val2
        ELSE Erg := String >= String2; Mode := None
        END |
      eql :
        IF Mode # string THEN Erg := Val1 = Val2
        ELSE Erg := String = String2; Mode := None
        END |
      neq :
        IF Mode # string THEN Erg := Val1 # Val2
        ELSE Erg := String # String2; Mode := None
        END |
    END;
    Val1 := S.VAL(SHORTINT,Erg);
  END;
  Value := Val1;
 END Expression;

PROCEDURE GetValue(VAR Mode : INTEGER; VAR Value : LONGINT);
  (* returns the value declared by sym *)
 BEGIN
  Mode := None; Expression(Mode,Value)
 END GetValue;

PROCEDURE GetOperand(Modes : SET; VAR Mode : INTEGER; VAR Value : LONGINT);
  (* reads the next operand which addressing mode must be in Modes *)
 BEGIN
  Mode := None;
  IF NOT MAS.LineFeed THEN
    CASE sym OF
      a : Mode := A; MAS.Get(sym) |
      ab : Mode := AB; MAS.Get(sym) |
      c : Mode := C; MAS.Get(sym) |
      r0..r7 : Mode := Rn; Value := sym - r0; MAS.Get(sym) |
      dptr : Mode := DPTR; MAS.Get(sym) |
      imm : MAS.Get(sym); GetValue(Mode,Value); Mode := Imm |
      slash : MAS.Get(sym); GetValue(Mode,Value); Mode := NBit |
      number,ident,lc,lbrak : GetValue(Mode,Value);
        IF (Mode = None) OR (Mode = Dir) THEN
          IF Dir IN Modes THEN Mode := Dir
          ELSIF Addr11 IN Modes THEN Mode := Addr11
          ELSIF Addr16 IN Modes THEN Mode := Addr16
          ELSIF Bit IN Modes THEN Mode := Bit
          ELSIF Rel IN Modes THEN Mode := Rel
          END;
        ELSIF (Mode = Addr16) AND NOT (Addr16 IN Modes) THEN
          IF Addr11 IN Modes THEN Mode := Addr11
          ELSIF Rel IN Modes THEN Mode := Rel
          END;
        END |
      ind : MAS.Get(sym);
        IF (sym = r0) OR (sym = r1) THEN Mode := Ri; Value := sym - r0
        ELSIF sym = dptr THEN Mode := DPTRI
        ELSIF sym = a THEN MAS.Get(sym); CheckSym(plus);
      	  IF sym = pc THEN Mode := APC
      	  ELSIF sym = dptr THEN Mode := ADPTR
      	  ELSE MAS.Mark(syntax)
      	  END
      	ELSE MAS.Mark(syntax)
        END;
        MAS.Get(sym)
      ELSE
    END;
  END;
  IF NOT (Mode IN Modes) THEN MAS.Mark(illmode) END;
 END GetOperand;

PROCEDURE Relative(Length : INTEGER; VAR Value : LONGINT);
  (* calculates the relative value, Length is bytes from loc to end of
     command *)
 BEGIN
  DEC(Value,cloc + Length);
  IF Pass2 AND ((Value < -128) OR (Value > 127)) THEN MAS.Mark(offshi) END;
 END Relative;

PROCEDURE Store1(Base,Mode : INTEGER; Value : LONGINT);
  (* stores an opcode with one operand *)
 BEGIN
  CASE Mode OF
    A,AB,C,DPTR,ADPTR,None : StoreByte(Base) |
    Rn,Ri : StoreByte(Base + SHORT(Value) ) |
    Dir,Bit : StoreByte(Base); StoreXByte(Value) |
    Rel : StoreByte(Base); Relative(1,Value); StoreXByte(Value) |
    Addr16 : StoreByte(Base); StoreByte(SHORT(Value) DIV 256);
             StoreXByte(Value) |
    Addr11 : StoreByte(Base + S.ANL(SHORT(Value) DIV 8,0E0H));
             StoreXByte(Value);
             IF Pass2 AND (S.ANL(Value,0F800H) # S.ANL(cloc+2,0F800H)) THEN
               MAS.Mark(range)
             END |
    ELSE StoreByte(Base); MAS.Mark(syntax)
  END;
 END Store1;

PROCEDURE Code1(Base : INTEGER; Modes : SET);
  (* translates a command with one operand *)
  VAR Mode : INTEGER; Value : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand(Modes,Mode,Value); Store1(Base,Mode,Value);
 END Code1;

PROCEDURE CodeA(Base,Mode : INTEGER; Value : LONGINT);
  (* codes the four formats A,Rn / A,direct / A,@Ri / A,#data *)
 BEGIN
  CASE Mode OF
    Rn,Ri   : StoreByte(Base + SHORT(Value) + (Ri * 2 + 6) - Mode * 2) |
    Dir,Imm : StoreByte(Base + 15 - Mode); StoreXByte(Value) |
    ELSE
  END;
 END CodeA;

PROCEDURE CodeAdd(Base : INTEGER);
  (* translates a command of type ADD *)
  VAR Mode : INTEGER; Value : LONGINT;
 BEGIN
  MAS.Get(sym); CheckSym(a); CheckSym(comma);
  GetOperand({Rn,Dir,Ri,Imm},Mode,Value);
  CodeA(Base,Mode,Value);
 END CodeAdd;

PROCEDURE CodeAnl(Base : INTEGER);
  (* translates a command of type ANL *)
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({A,Dir,C},Mode1,Value1); CheckSym(comma);
  IF Mode1 = A THEN GetOperand({Rn,Dir,Ri,Imm},Mode2,Value2);
    CodeA(Base,Mode2,Value2);
  ELSIF Mode1 = Dir THEN GetOperand({A,Imm},Mode2,Value2);
  	StoreByte(Base + Mode2 DIV Imm + 2);
  	StoreXByte(Value1);
  	IF Mode2 = Imm THEN StoreXByte(Value2) END;
  ELSE GetOperand({Bit,NBit},Mode2,Value2);
    IF Mode2 = Bit THEN StoreByte(Base+32H) ELSE StoreByte(Base+60H) END;
    StoreXByte(Value2)
  END;
 END CodeAnl;

PROCEDURE CodeCjne;
  (* translates a CJNE command *)
  VAR Mode1,Mode2,Mode3 : INTEGER; Value1,Value2,Value3 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({A,Rn,Ri},Mode1,Value1); CheckSym(comma);
  IF Mode1 = A THEN GetOperand({Dir,Imm},Mode2,Value2); CheckSym(comma);
    GetOperand({Rel},Mode3,Value3); Relative(3,Value3);
    StoreByte(0B4H + Imm - Mode2); StoreXByte(Value2); StoreXByte(Value3);
  ELSE GetOperand({Imm},Mode2,Value2); CheckSym(comma);
    GetOperand({Rel},Mode3,Value3); Relative(3,Value3);
    StoreByte(0B6H + Ri * 2 - Mode1 * 2 + SHORT(Value1));
    StoreXByte(Value2); StoreXByte(Value3);
  END;
 END CodeCjne;

PROCEDURE CodeClr(Dist : INTEGER; Modes : SET);
  (* codes a command of type CLR *)
  VAR Mode : INTEGER; Value : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand(Modes,Mode,Value);
  IF Mode = Bit THEN StoreByte(0D2H - Dist); StoreXByte(Value)
  ELSE
    IF Mode = A THEN Dist := -Dist END;
    StoreByte(0D4H - Dist - Mode DIV 2)
  END;
 END CodeClr;

PROCEDURE CodeDec(Base : INTEGER; Modes : SET);
  VAR Mode : INTEGER; Value : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand(Modes,Mode,Value);
  CASE Mode OF
    A  : StoreByte(Base + 4) |
    Rn,Ri : StoreByte(Base + SHORT(Value) + (Ri * 2 + 6) - Mode * 2 ) |
    Dir : StoreByte(Base + 5); StoreXByte(Value) |
    DPTR : StoreByte(0A3H) |
    ELSE
  END;
 END CodeDec;

PROCEDURE CodeDjnz;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({Rn,Dir},Mode1,Value1); CheckSym(comma);
  GetOperand({Rel},Mode2,Value2);
  IF Mode1 = Rn THEN Relative(2,Value2); StoreByte(0D8H + SHORT(Value1))
  ELSE Relative(3,Value2); StoreByte(0D5H); StoreXByte(Value1);
  END;
  StoreXByte(Value2);
 END CodeDjnz;

PROCEDURE CodeJb(Base : INTEGER);
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({Bit},Mode1,Value1); CheckSym(comma);
  GetOperand({Rel},Mode2,Value2); Relative(3,Value2);
  StoreByte(Base); StoreXByte(Value1); StoreXByte(Value2);
 END CodeJb;

PROCEDURE MovRnDir(Mode1 : INTEGER; Value1 : LONGINT);
  VAR Mode2,Base : INTEGER; (* Value2 global for FOR statement *)
 BEGIN
  IF (Mode1 = Rn) OR (Mode1 = Ri) THEN GetOperand({A,Dir,Imm},Mode2,Value2);
    CASE Mode2 OF
      A : Base := 0F8H | Dir : Base := 0A8H | Imm : Base := 78H ELSE
    END;
    IF Mode1 = Ri THEN DEC(Base,2) END;
    StoreByte(Base + SHORT(Value1));
    IF Mode2 # A THEN StoreXByte(Value2) END;
  ELSIF Mode1 = Dir THEN GetOperand({A,Rn,Dir,Ri,C,Imm},Mode2,Value2);
    CASE Mode2 OF
      A     : StoreByte(0F5H); StoreXByte(Value1) |
      Rn,Ri : StoreByte(86H + Ri * 2 + SHORT(Value2) - Mode2 * 2 );
              StoreXByte(Value1) |
      Dir   : StoreByte(85H); StoreXByte(Value2); StoreXByte(Value1) |
      Imm   : StoreByte(75H); StoreXByte(Value1); StoreXByte(Value2) |
      C     : StoreByte(92H); StoreXByte(Value1) |
      ELSE
    END;
  END;
 END MovRnDir;

PROCEDURE CodeMov;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({A,Rn,Dir,Ri,C,Bit,DPTR},Mode1,Value1);
  CheckSym(comma);
  IF Mode1 = A THEN GetOperand({Rn,Dir,Ri,Imm},Mode2,Value2);
    IF Mode2 # Imm THEN CodeA(0E0H,Mode2,Value2)
    ELSE StoreByte(74H); StoreXByte(Value2)
    END;
  ELSIF (Mode1 = Rn) OR (Mode1 = Ri) OR (Mode1 = Dir) THEN
    MovRnDir(Mode1,Value1);
  ELSIF Mode1 = C THEN GetOperand({Bit},Mode2,Value2);
    StoreByte(0A2H); StoreXByte(Value2)
  ELSIF Mode1 = Bit THEN GetOperand({C},Mode2,Value2);
    StoreByte(92H); StoreXByte(Value1)
  ELSE GetOperand({Imm},Mode2,Value2);
    StoreByte(90H); StoreXByte(Value2 DIV 256); StoreXByte(Value2)
  END;
 END CodeMov;

PROCEDURE CodeMovc;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); CheckSym(a); CheckSym(comma);
  GetOperand({ADPTR,APC},Mode2,Value2);
  IF Mode2 = ADPTR THEN StoreByte(93H) ELSE StoreByte(83H) END;
 END CodeMovc;

PROCEDURE CodeMovx;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({A,Ri,DPTRI},Mode1,Value1); CheckSym(comma);
  IF Mode1 = A THEN GetOperand({Ri,DPTRI},Mode2,Value2);
    IF Mode2 = Ri THEN StoreByte(0E2H + SHORT(Value2))
    ELSE StoreByte(0E0H)
    END;
  ELSE CheckSym(a);
    IF Mode1 = Ri THEN StoreByte(SHORT(Value1) + 0F2H)
    ELSE StoreByte(0F0H)
    END;
  END;
 END CodeMovx;

PROCEDURE CodeXch;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); CheckSym(a); CheckSym(comma);
  GetOperand({Rn,Dir,Ri},Mode2,Value2);
  CodeA(0C0H,Mode2,Value2);
 END CodeXch;

PROCEDURE CodeXchd;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); CheckSym(a); CheckSym(comma);
  GetOperand({Ri},Mode2,Value2);
  StoreByte(SHORT(Value2) + 0D6H);
 END CodeXchd;

PROCEDURE CodeXrl;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({A,Dir},Mode1,Value1); CheckSym(comma);
  IF Mode1 = A THEN GetOperand({Rn,Dir,Ri,Imm},Mode2,Value2);
    CodeA(60H,Mode2,Value2);
  ELSE GetOperand({A,Imm},Mode2,Value2);
  	StoreByte(Mode2 DIV Imm + 62H);
  	StoreXByte(Value1);
  	IF Mode2 = Imm THEN StoreXByte(Value2) END;
  END;
 END CodeXrl;

PROCEDURE SubTab(StartAddr : LONGINT);
  (* initiate a lower symbol table *)
  VAR Tab : MAS.tab;

  PROCEDURE ClearMacroPar(Tab : MAS.tab);
    VAR Lab : MAS.lab; i : INTEGER;
   BEGIN
    i := KW;
    REPEAT DEC(i); Lab := Tab.KeyTab[i];
      WHILE Lab # NIL DO
        IF Lab.Type = MacroPar THEN Lab.Type := 0 END;
        Lab := Lab.Next;
      END;
    UNTIL i = 0;
   END ClearMacroPar;

 BEGIN
  Tab := MAS.CurrTab.Lower;
  WHILE Tab # NIL DO
    IF Tab.Start = StartAddr THEN MAS.CurrTab := Tab;
      ClearMacroPar(Tab); RETURN
    END;
    Tab := Tab.Next;
  END;
  NEW(Tab); Tab.Upper := MAS.CurrTab; Tab.Lower := NIL;
  Tab.Next := MAS.CurrTab.Lower; Tab.Start := StartAddr;
  ClearKeyTab(Tab.KeyTab); MAS.CurrTab.Lower := Tab;
  MAS.CurrTab := Tab;
 END SubTab;

PROCEDURE UpperTab(EndAddr : LONGINT);
  (* delete MAS.CurrTab if Delete is TRUE and switch to upper table of MAS.CurrTab *)
 BEGIN
  MAS.CurrTab.End := EndAddr; MAS.CurrTab := MAS.CurrTab.Upper;
 END UpperTab;

PROCEDURE^ StatSeq(Endsym : INTEGER);

PROCEDURE StoreLabel;
  (* stores the label in MAS.name and tests on macro *)
  VAR ph,ah,h,k,i,j,Mode,Sym : INTEGER;
      Glob : BOOLEAN; pn,an : MAS.ident;
      Sfr,Value : LONGINT; Label : MAS.lab;

  PROCEDURE StoreName(VAR name : ARRAY OF CHAR; VAR h : INTEGER);
   BEGIN
    COPY(MAS.name,name); h := MAS.Hash;
   END StoreName;

  PROCEDURE RestoreName(VAR name : ARRAY OF CHAR; VAR h : INTEGER);
   BEGIN
    COPY(name,MAS.name); MAS.Hash := h;
   END RestoreName;

  PROCEDURE ToEndm;
   BEGIN
    REPEAT MAS.Get(sym);
      IF (sym = irp) OR (sym = rept) THEN ToEndm;
        IF sym = endm THEN MAS.Get(sym) END;
      END;
    UNTIL (sym = endm) OR (sym = eof);
   END ToEndm;

 BEGIN
  StoreName(pn,ph); MAS.Get(sym); Glob := FALSE;
  IF sym = times THEN Glob := TRUE; MAS.Get(sym) END;
  IF sym = colon THEN MAS.Get(sym) END;
  StoreName(an,ah); RestoreName(pn,ph);
  IF sym = set THEN Enter2(0,Notype,Glob)
  ELSE Enter(Loc(),seg,Glob)
  END;
  Label := MAS.Label;
  IF (sym = set) OR (sym = equ) OR (sym = bit) OR (sym = sfr) OR
     (sym = sfrb) THEN Sym := sym;
    MAS.Get(sym); GetValue(Mode,Label.Val);
    IF Sym = bit THEN Label.Type := Bcon;
    ELSIF Sym = sfr THEN Label.Type := Dcon;
    ELSIF Sym = sfrb THEN
      Label.Type := Dcon; i := 0; Sfr := Label.Val;
      IF (Sfr >= 80H) AND (S.ANL(Sfr,07H) # 0) OR
         (Sfr < 20H) OR (Sfr >= 30H) AND (Sfr < 80H) THEN
        MAS.Mark(nosfrb)
      END;
      StoreName(an,ah); RestoreName(pn,ph);
      Str.Append(".0",MAS.name); h := Str.Length(MAS.name) - 1;
      REPEAT
        MAS.name[h] := CHR(i + 30H); j := 0; k := 0;
        REPEAT INC(k, ORD(CAP(MAS.name[j]))); INC(j) UNTIL j > h;
        k := (k+j) MOD KW;  (*hash function*)
        MAS.Hash := k; Enter(Sfr+i,Bcon,Glob); INC(i);
      UNTIL i = 8;
      RestoreName(an,ah);
    ELSE Label.Type := Notype; RETURN
    END;
    IF (Label.Val < 0) OR (Label.Val >= 256) THEN MAS.Mark(range) END;
  ELSIF sym = macro THEN
    Label.Val := S.VAL(LONGINT,MAS.Text.Runad); Label.Type := Macro;
    GetValOff := TRUE; ToEndm;
    GetValOff := FALSE; CheckSym(endm);
  ELSE
    RestoreName(an,ah);
  END;
 END StoreLabel;

PROCEDURE GetPar(VAR Par : ARRAY OF CHAR);
  (* reads a macro parameter *)
  VAR i,k,Type : INTEGER; Value : LONGINT;
      ch : CHAR; p : Str.ptr; Tab : MAS.tab;

  PROCEDURE JumpSpaces() : BOOLEAN;
   BEGIN
    WHILE (ch = " ") OR (ch = 09X) DO MAS.Read(ch) END;
    RETURN (ch > " ") AND (ch # ";")
   END JumpSpaces;

  PROCEDURE ReadString(End : CHAR);
   BEGIN
    IF End = "|" THEN MAS.Read(ch) END;
    REPEAT
      Par[i] := ch; INC(i); MAS.Read(ch);
    UNTIL (ch = End) OR (ch < " ");
    IF ch < " " THEN MAS.Mark(strend)
    ELSE
      IF End # "|" THEN Par[i] := End; INC(i) END;
      MAS.Read(ch);
    END;
   END ReadString;

 BEGIN
  ch := MAS.ch;
  IF JumpSpaces() THEN i := 0;
    WHILE (ch > " ") AND (ch # ";") AND (ch # ",") DO
      IF (ch = "'") OR (ch = 22X) OR (ch = "|") THEN ReadString(ch)
      ELSE Par[i] := ch; INC(i); MAS.Read(ch);
      END;
    END;
    Par[i] := 0X;
    IF i > 0 THEN
      i := 0; k := 0;
      WHILE Par[i] # 0X DO INC(k,ORD(CAP(Par[i]))); INC(i) END;
      MAS.Hash := (k+i) MOD KW; COPY(Par,MAS.name);
      Tab := MAS.CurrTab; MAS.CurrTab := Tab.Upper;
      IF MAS.Search(Value,Type) AND (Type = MacroPar) THEN
        p := Value; COPY(p^,Par)
      END;
      MAS.CurrTab := Tab;
    END;
    MAS.ch := ch;
  ELSE Par[0] := 0X;
  END;
 END GetPar;

PROCEDURE CodeMacro;
  (* codes the call of a macro *)
  VAR Tab : MAS.tab; Lab : MAS.lab;
      Pars : ARRAY 20,80 OF CHAR;
      i,Type : INTEGER;
      Value,IntAd : LONGINT;
 BEGIN
  Type := Macro;
  IF Find(Value,Type) AND (Type = Macro) THEN Lab := MAS.Label;
    i := 0; SubTab(S.VAL(LONGINT,MAS.Text.Runad));
    REPEAT GetPar(Pars[i]); INC(i);
      IF MAS.ch = "," THEN MAS.Read(MAS.ch) END;
    UNTIL i = 20;
    Tab := MAS.CurrTab; MAS.CurrTab := NIL;
    MAS.Set(Lab.File,Lab.Begad,Value,TRUE,MasPar.MacExp,FALSE);
    MAS.Get(sym); i := 0;
    IF (sym = ident) AND NOT MAS.LineFeed THEN
      LOOP
        MAS.CurrTab := Tab;
        IF MAS.name # Pars[i] THEN Enter2(S.ADR(Pars[i]),MacroPar,FALSE) END;
        INC(i);
        Tab := MAS.CurrTab; MAS.CurrTab := NIL;
        MAS.Get(sym);
        IF sym # comma THEN EXIT END;
        MAS.Get(sym);
        IF sym # ident THEN MAS.Mark(ident); EXIT END;
      END;
    END;
    MAS.CurrTab := Tab;
    StatSeq(endm); MAS.Reset; UpperTab(S.VAL(LONGINT,MAS.Text.Runad));
    MAS.Get(sym);
  ELSE
    IF Type # Macro THEN MAS.Mark(macroexp) END;
    REPEAT MAS.Get(sym) UNTIL MAS.LineFeed OR (sym = eof);
  END;
 END CodeMacro;

PROCEDURE CodeIrp;
  VAR Op : ARRAY 80 OF CHAR;
      IntAd,Adr : LONGINT;
      i : INTEGER;
 BEGIN
  MAS.Get(sym);
  IF sym = ident THEN
    SubTab(S.VAL(LONGINT,MAS.Text.Runad)); Enter(S.ADR(Op),MacroPar,FALSE);
    i := 0;
    WHILE MAS.Text.Runad[i] # 0AX DO
      IF MAS.Text.Runad[i] = 0X THEN MAS.Mark(endm); RETURN END;
      INC(i)
    END;
    Adr := S.ADR(MAS.Text.Runad[i+1]); MAS.Get(sym);
    WHILE sym = comma DO
      GetPar(Op); SubTab(S.VAL(LONGINT,MAS.Text.Runad));
      MAS.SetText(MAS.Text,Adr,FALSE,MasPar.MacExp,FALSE);
      MAS.Get(sym); StatSeq(endm);
      IF sym # endm THEN sym := 0 END;
      MAS.Reset; UpperTab(S.VAL(LONGINT,MAS.Text.Runad));
      IF sym # 0 THEN MAS.Get(sym) END;
    END;
    UpperTab(S.VAL(LONGINT,MAS.Text.Runad)); GetValOff := TRUE;
    REPEAT MAS.Get(sym) UNTIL (sym = endm) OR (sym = eof);
    GetValOff := FALSE; MAS.Get(sym);
  ELSE MAS.Mark(ident)
  END;
 END CodeIrp;

PROCEDURE CodeRept;
  VAR Mode : INTEGER; Value,Adr,IntAd : LONGINT;
 BEGIN
  MAS.Get(sym); Adr := S.VAL(LONGINT,MAS.Text.Runad); GetValue(Mode,Value);
  WHILE Value > 0 DO SubTab(S.VAL(LONGINT,MAS.Text.Runad) + Value);
    MAS.SetText(MAS.Text,Adr,FALSE,MasPar.MacExp,FALSE);
    MAS.Get(sym); StatSeq(endm); MAS.Reset;
    UpperTab(S.VAL(LONGINT,MAS.Text.Runad));
    DEC(Value);
    IF sym # endm THEN Value := 0 END;
  END;
  GetValOff := TRUE;
  REPEAT MAS.Get(sym) UNTIL (sym = endm) OR (sym = eof);
  GetValOff := FALSE; MAS.Get(sym);
 END CodeRept;

PROCEDURE Define(Size : INTEGER);
  VAR i,Mode : INTEGER; Value : LONGINT;
 BEGIN
  REPEAT
    MAS.Get(sym);
    IF sym = ask THEN
      IF seg = codeseg THEN MAS.Mark(notcode)
      ELSE IncLoc(Size)
      END;
      MAS.Get(sym);
    ELSIF sym = string THEN i := 0;
      WHILE MAS.name[i] # 0X DO StoreByte(ORD(MAS.name[i])); INC(i) END;
      WHILE i MOD Size # 0 DO StoreByte(0); INC(i) END;
      MAS.Get(sym);
    ELSE GetValue(Mode,Value); StoreXByte(Value);
      IF Size > 1 THEN Value := Value DIV 256; StoreXByte(Value);
        IF Size > 2 THEN Value := Value DIV 256;
          StoreXByte(Value); StoreXByte(Value DIV 256);
        END;
      END;
    END;
  UNTIL sym # comma;
 END Define;

PROCEDURE DefineSpace;
  VAR Mode : INTEGER; Value : LONGINT;
 BEGIN
  MAS.Get(sym); GetValue(Mode,Value);
  IF seg = codeseg THEN MAS.Mark(notcode)
  ELSE IncLoc(Value)
  END;
 END DefineSpace;

PROCEDURE Load(VAR Name : FN.path; VAR Begad : LONGINT) : BOOLEAN;
  VAR f : file; Length : LONGINT;
 BEGIN
  f := Files;
  WHILE f # NIL DO
    IF f.Name = Name THEN Begad := f.Begad; RETURN TRUE END;
    f := f.Next;
  END;
  IF File.Load(Name,0,1,Begad,Length) THEN
    S.PUT(Begad+Length,0); NEW(f); f.Begad := Begad; f.Next := Files;
    Files := f; f.Name := Name; RETURN TRUE
  END;
  RETURN FALSE;
 END Load;

PROCEDURE ToEndif;
  (* searches the corresponding endif *)
 BEGIN
  GetValOff := TRUE;
  WHILE (sym # endif) AND (sym # eof) DO
    IF (sym = if) OR (sym = ifdef) OR (sym = ifndef) THEN
      MAS.Get(sym); ToEndif; GetValOff := TRUE;
    ELSE MAS.Get(sym)
    END;
  END;
  GetValOff := FALSE; CheckSym(endif);
 END ToEndif;

PROCEDURE SearchElsif() : BOOLEAN;
  (* searches the corresponding elseif *)
 BEGIN
  GetValOff := TRUE;
  WHILE (sym # elsif) AND (sym # elseif) AND (sym # eof) AND (sym # endif) DO
    IF (sym = if) OR (sym = ifdef) OR (sym = ifndef) THEN
      MAS.Get(sym); ToEndif; GetValOff := TRUE;
    ELSE MAS.Get(sym)
    END;
  END;
  GetValOff := FALSE; RETURN sym = elsif;
 END SearchElsif;

PROCEDURE SearchElseif() : BOOLEAN;
  (* searches the corresponding elseif *)
 BEGIN
  GetValOff := TRUE;
  WHILE (sym # elseif) AND (sym # eof) AND (sym # endif) DO
    IF (sym = if) OR (sym = ifdef) OR (sym = ifndef) THEN
      MAS.Get(sym); ToEndif; GetValOff := TRUE;
    ELSE MAS.Get(sym)
    END;
  END;
  GetValOff := FALSE; RETURN sym = elseif;
 END SearchElseif;

PROCEDURE IfTrue() : BOOLEAN;
  VAR If : ifset;
 BEGIN
  INC(IfId);
  IF Pass2 THEN
    If := Ifs;
    WHILE If # NIL DO
      IF If.Runad = IfId THEN RETURN TRUE END;
      If := If.Next;
    END;
  END;
  RETURN FALSE;
 END IfTrue;

PROCEDURE SetIf(Set : BOOLEAN) : BOOLEAN;
  VAR If : ifset;
 BEGIN
  IF NOT Pass2 AND Set THEN
    NEW(If); If.Next := Ifs; Ifs := If; If.Runad := IfId;
    RETURN TRUE
  END;
  RETURN FALSE;
 END SetIf;

PROCEDURE TestCondition;
  VAR Value : LONGINT; Mode : INTEGER;
 BEGIN
  REPEAT MAS.Get(sym); GetValue(Mode,Value);
    IF IfTrue() OR SetIf(Value # 0) THEN StatSeq(0); ToEndif; RETURN END;
  UNTIL NOT SearchElsif();
  IF sym = elseif THEN
    MAS.Get(sym); StatSeq(endif); MAS.Get(sym)
  ELSE CheckSym(endif)
  END;
 END TestCondition;

PROCEDURE BestJump(From,To : LONGINT);
 BEGIN
  IF From-To <= 128 THEN (* sjmp possible *)
    StoreByte(80H); StoreXByte(To-From);
  ELSIF S.ANL(From,7FFH) = S.ANL(To,7FFH) THEN (* ajmp possible *)
    StoreXByte(S.ANL(To,700H) DIV 8 + 1); StoreXByte(To);
  ELSE (* ljmp *)
    StoreByte(2); StoreXByte(To DIV 256); StoreXByte(To);
  END;
 END BestJump;

PROCEDURE InitExits;
  VAR e : exit;
 BEGIN
  NEW(e); e.Prev := Exits; Exits := e; e.i := 0;
 END InitExits;

PROCEDURE CorrectJumps(VAR Jumps : ARRAY OF LONGINT; i : INTEGER);
 BEGIN
  WHILE i > 0 DO DEC(i); SetPos(Jumps[i]);
    ChangeByte(SHORT(cloc DIV 256)); ChangeByte(SHORT(cloc));
  END;
  SetPos(cloc);
 END CorrectJumps;

PROCEDURE TermExits;
 BEGIN
  CorrectJumps(Exits.Pos,Exits.i); Exits := Exits.Prev;
 END TermExits;

PROCEDURE ExitStatement;
 BEGIN
  IF Exits = NIL THEN MAS.Mark(nostruct)
  ELSE StoreByte(2);
    Exits.Pos[Exits.i] := cloc; INC(Exits.i);
    StoreByte(0); StoreByte(0);
  END;
  MAS.Get(sym);
 END ExitStatement;

PROCEDURE LoopStatement;
  VAR StartPos : LONGINT;
 BEGIN
  InitExits;
  StartPos := cloc;
  MAS.Get(sym); StatSeq(end);
  MAS.Get(sym); BestJump(cloc+2,StartPos);
  TermExits;
 END LoopStatement;

PROCEDURE ForStatement;
  VAR StartPos,Value1 : LONGINT; Mode1 : INTEGER;
 BEGIN
  InitExits;
  MAS.Get(sym); GetOperand({Rn,Dir},Mode1,Value1); CheckSym(assign);
  MovRnDir(Mode1,Value1);
  IF sym = do THEN MAS.Get(sym) END;
  StartPos := cloc; StatSeq(end);
  MAS.Get(sym);
  IF Mode1 = Rn THEN StoreXByte(Value1 + 0D8H);
  ELSE StoreByte(0D5H); StoreXByte(Value2);
  END;
  Relative(1,StartPos); StoreXByte(StartPos);
  TermExits;
 END ForStatement;

PROCEDURE Compare;
  VAR Mode1,Mode2 : INTEGER; Value1,Value2 : LONGINT;
 BEGIN
  MAS.Get(sym); GetOperand({A,Rn,Ri},Mode1,Value1); CheckSym(eql);
  IF Mode1 = A THEN GetOperand({Dir,Imm},Mode2,Value2);
    StoreByte(0B4H + Imm - Mode2); StoreXByte(Value2);
  ELSE GetOperand({Imm},Mode2,Value2);
    StoreByte(0B6H + Ri * 2 - Mode1 * 2 + SHORT(Value1));
    StoreXByte(Value2);
  END;
 END Compare;

PROCEDURE IfStatement;
  VAR LastIf,Value1,Value2 : LONGINT; Mode1,Mode2,i : INTEGER;
      ToEnd : ARRAY 20 OF LONGINT;

  PROCEDURE GetIf;
   BEGIN
    Compare; LastIf := cloc; StoreByte(0);
    IF sym = then THEN MAS.Get(sym) END;
   END GetIf;

  PROCEDURE SetLastIf(Value : LONGINT);
   BEGIN
    SetPos(Value); Relative(-1,Value); ChangeByte(SHORT(-Value));
    SetPos(cloc);
   END SetLastIf;

  PROCEDURE StoreJump;
   BEGIN
    StoreByte(2); ToEnd[i] := cloc; INC(i);
    StoreByte(0); StoreByte(0); SetLastIf(LastIf)
   END StoreJump;

 BEGIN
  InitExits;
  GetIf; StatSeq(0); i := 0;
  WHILE sym = elsif DO StoreJump; GetIf; StatSeq(0) END;
  IF sym = else THEN StoreJump; MAS.Get(sym); StatSeq(end); MAS.Get(sym);
  ELSE CheckSym(end); SetLastIf(LastIf)
  END;
  CorrectJumps(ToEnd,i); TermExits;
 END IfStatement;

PROCEDURE RepeatStatement;
  VAR StartPos,Value1,Value2 : LONGINT; Mode1,Mode2 : INTEGER;
 BEGIN
  InitExits;
  StartPos := cloc; MAS.Get(sym); StatSeq(until); Compare;
  Relative(1,StartPos); StoreXByte(StartPos);
  TermExits;
 END RepeatStatement;

PROCEDURE WriteAss(VAR Name : FN.path);
 BEGIN
  IO.WriteString("Assembling "); IO.WriteString(Name); IO.WriteLn;
  CurrName := Name;
 END WriteAss;

PROCEDURE StatSeq(Endsym : INTEGER);
  VAR Mode : INTEGER;
      Value,Val2,Val3,Begad,IntAd : LONGINT;
      Name,PName : FN.path;
      Def,Bin,FirstChar : BOOLEAN;
      String : str;
      stackEl : StackPtr;
 BEGIN
  LOOP
(*    IO.WriteInt(sym,10,5,1," ");*)
    CASE sym OF
      output : MAS.Get(sym);
        IF (sym = binary) OR (sym = special) THEN
          Bin := sym = binary; MAS.Get(sym);
          IF (sym = string) OR (sym = ident) THEN
            IF Bin THEN COPY(MAS.name,BinName); MasPar.Bin := TRUE
            ELSE COPY(MAS.name,SpecName); MasPar.Spec := TRUE
            END;
            MAS.Get(sym);
          ELSE MAS.Mark(string)
          END;
        ELSE MAS.Mark(syntax)
        END |
      newpage : IF MasPar.ListOn AND Pass2 THEN MAS.FormFeed END;
        MAS.Get(sym) |
      message : StringExpression(String);
        IF (String[0] # 0X) AND NOT Pass2 THEN
          IO.WriteString(String); IO.WriteLn
        END |
      warning : StringExpression(String);
        IF (String[0] # 0X) AND Pass2 THEN MAS.Warning(String) END |
      error : StringExpression(String);
        IF (String[0] # 0X) AND Pass2 THEN MAS.Error(String) END |
      fatal : StringExpression(String);
        IF String[0] # 0X THEN MAS.Error(String) END;
        Task.RetCode := 3; Task.Exit |
      prtinit : StringExpression(String);
        IF String[0] # 0X THEN COPY(String,MasPar.PrtInit) END |
      prtexit : StringExpression(String);
        IF String[0] # 0X THEN COPY(String,MasPar.PrtExit) END |
      title : StringExpression(String);
        IF String[0] # 0X THEN COPY(String,MasPar.Title) END |
      listing : MAS.Get(sym);
        IF sym = eql THEN
          IF PrevListOn = LastStackElem THEN MAS.Mark(syntax)
          ELSE
            MasPar.ListOn := PrevListOn(StackPtr).On;
            PrevListOn.Pop;
          END;
        ELSIF (sym # on) AND (sym # off) THEN MAS.Mark(onoffexp)
        ELSE
          NEW(stackEl); stackEl.On := MasPar.ListOn;
          PrevListOn.Push(stackEl);
          MasPar.ListOn := sym = on;
        END;
        MAS.Get(sym) |
      macexp : MAS.Get(sym);
        IF (sym # on) AND (sym # off) THEN MAS.Mark(onoffexp)
        ELSE MasPar.MacExp := sym = on;
        END;
        MAS.Get(sym) |
      page : MAS.Get(sym); GetValue(Mode,Value);
        MasPar.PageSize := SHORT(Value) |
      ifdef,ifndef : Def := sym = ifdef; MAS.Get(sym); Ident;
        IF sym = ident THEN
          IF IfTrue() OR SetIf(Def = MAS.Search(Value,Mode)) THEN
            MAS.Get(sym); StatSeq(0);
            IF sym = elseif THEN ToEndif ELSE CheckSym(endif) END;
          ELSIF SearchElseif() THEN
            MAS.Get(sym); StatSeq(endif); MAS.Get(sym)
          ELSE CheckSym(endif)
          END;
        ELSE MAS.Mark(ident)
        END |
      if : TestCondition |
      then : MAS.Get(sym) |
      charset : MAS.Get(sym); GetValue(Mode,Value); CheckSym(comma);
        GetValue(Mode,Val2);
        IF sym = comma THEN MAS.Get(sym); GetValue(Mode,Val3);
          IF Value > Val2 THEN MAS.Mark(sechi)
          ELSIF NOT Pass2 THEN
            WHILE Value <= Val2 DO MAS.CharSet[SHORT(Value)] := CHR(Val3);
              INC(Value); INC(Val3);
            END;
          END;
        ELSIF NOT Pass2 THEN MAS.CharSet[SHORT(Value)] := CHR(Val2)
        END |
      align : MAS.Get(sym); GetValue(Mode,Value);
        Val2 := Value - Loc() MOD Value;
        IF Val2 # Value THEN IncLoc(Val2) END |
      irp : CodeIrp |
      rept : CodeRept |
      local : SubTab(S.VAL(LONGINT,MAS.Text.Runad)); MAS.Get(sym);
        StatSeq(end); MAS.Get(sym); UpperTab(S.VAL(LONGINT,MAS.Text.Runad)) |
      include : MAS.Get(sym);
        IF (sym = string) OR (sym = ident) THEN
          IF Paths.Get(MasPar.paths,MAS.name,{},Name) AND Load(Name,Begad) THEN
            PName := CurrName; WriteAss(Name);
            MAS.Set(Name,Begad,Begad,FALSE,TRUE,FALSE);
            MAS.Get(sym); StatSeq(eof); MAS.Reset;
            WriteAss(PName);
          ELSE MAS.Mark(noinc)
          END;
        ELSE MAS.Mark(ident)
        END;
        MAS.Get(sym) |
      segment : MAS.Get(sym);
        CASE sym OF
          code : seg := codeseg |
          data : seg := dataseg |
          xdata: seg := xdataseg |
          bitdata : seg := bdataseg |
          ELSE MAS.Mark(segexp)
        END;
        MAS.Get(sym) |
      cpu : MAS.Get(sym); GetValue(Mode,CPU) |
      org : MAS.Get(sym); GetValue(Mode,Value); SetLoc(Value) |
      db : Define(1) |
      dw : Define(2) |
      dd : Define(4) |
      ds : DefineSpace |
      loop : LoopStatement |
      for : ForStatement |
      ifc : IfStatement |
      repeat : RepeatStatement |
      exitt : ExitStatement |
      acall : Code1(11H,{Addr11}) |
      add : CodeAdd(20H) |
      addc : CodeAdd(30H) |
      ajmp : Code1(1,{Addr11}) |
      anl : CodeAnl(50H) |
      cjne : CodeCjne |
      clr : CodeClr(10H,{C,Bit,A}) |
      cpl : CodeClr(20H,{C,Bit,A}) |
      da : Code1(0D4H,{A}) |
      dec : CodeDec(10H,{A,Rn,Ri,Dir}) |
      div : Code1(84H,{AB}) |
      djnz : CodeDjnz |
      inc : CodeDec(0,{A,Rn,Dir,Ri,DPTR}) |
      jb : CodeJb(20H) |
      jbc : CodeJb(10H) |
      jc : Code1(40H,{Rel}) |
      jmp : Code1(73H,{ADPTR}) |
      jnb : CodeJb(30H) |
      jnc : Code1(50H,{Rel}) |
      jnz : Code1(70H,{Rel}) |
      jz : Code1(60H,{Rel}) |
      lcall : Code1(12H,{Addr16}) |
      ljmp : Code1(2,{Addr16}) |
      mov : CodeMov |
      movc : CodeMovc |
      movx : CodeMovx |
      nop : Code1(0,{None}) |
      mul : Code1(0A4H,{AB}) |
      orl : CodeAnl(40H) |
      pop : Code1(0D0H,{Dir}) |
      push : Code1(0C0H,{Dir}) |
      ret : Code1(22H,{None}) |
      reti : Code1(32H,{None}) |
      rl : Code1(23H,{A}) |
      rlc : Code1(33H,{A}) |
      rr : Code1(03H,{A}) |
      rrc : Code1(13H,{A}) |
      setb : CodeClr(0,{C,Bit}) |
      sjmp : Code1(80H,{Rel}) |
      subb : CodeAdd(90H) |
      swap : Code1(0C4H,{A}) |
      xch : CodeXch |
      xchd : CodeXchd |
      xrl : CodeXrl |
      lbrak,ident : Ident;
        IF MAS.FirstChar THEN StoreLabel ELSE CodeMacro END |
      ELSE
        IF (Endsym = 0) OR (sym = Endsym) THEN EXIT
        ELSE MAS.Mark(Endsym);
          REPEAT MAS.Get(sym) UNTIL MAS.LineFeed OR (sym = eof);
          IF sym = eof THEN EXIT END;
        END
    END;
    IF Pass2 THEN MAS.ListSource; MAS.Loc := Loc() END;
  END;
 END StatSeq;

PROCEDURE WriteSymbols;
  VAR i : INTEGER; Lab : MAS.lab;
    name : FN.path; f : FB.file;
    s : ARRAY 10 OF CHAR;
 BEGIN
  IF globalSymbolFile THEN
    COPY(BinName, name);
    FN.SetExt("GLB",name);
    IF NOT FB.Open(name,1024,f) THEN f := NIL END;
    i := 0;
    REPEAT Lab := Global.KeyTab[i];
      WHILE Lab # NIL DO
        MAS.ListSymbol(Lab.Id,Lab.Val,Lab.Type);
        IF f # NIL THEN
          FB.WriteChars(f, Lab.Id);
          FB.WriteChars(f, " EQU ");
          NumStr.LIntTo(Lab.Val, 10, s);
          FB.WriteChars(f, s);
          FB.WriteWord(f, 0D0AH);
        END;
        Lab := Lab.Next;
      END;
      INC(i)
    UNTIL i = KW;
    IF f # NIL THEN FB.Close(f) END;
  END;
 END WriteSymbols;

PROCEDURE Init2;
 BEGIN
  cloc := 0; dloc := 30H; xloc := 0; bloc := 0; seg := codeseg;
  Pass2 := TRUE; CPU := 8051; IfId := 0;
 END Init2;

PROCEDURE Init1;
 BEGIN
  Init2; Pass2 := FALSE; Files := NIL; Ifs := NIL;
  ClearKeyTab(Global.KeyTab);
  Global.Next := NIL; Global.Lower := NIL;
  MAS.CurrTab := S.ADR(Global);
 END Init1;

PROCEDURE Assemble*;
  VAR Begad,Length,Dummy : LONGINT;
      d : INTEGER;
      Name : FN.path; ext : FN.ext;
 BEGIN
  IF CL.arg # NIL THEN
    COPY(CL.arg^,Name);
    FN.GetExt(Name, ext);
    IF ext[0] = 0X THEN FN.SetExt(MasPar.SrcExt,Name) END;
    FN.GetExt(Name, ext); Str.CAPs(ext);
    globalSymbolFile := ext = "ASM";
    IF Paths.Get(MasPar.paths,Name,{},Name) AND File.Load(Name,0,1,Begad,Length) THEN
      COPY(Name,BinName); COPY(Name,SpecName);
      FN.SetExt(MasPar.BinExt,BinName);
      FN.SetExt(MasPar.SpecExt,SpecName);
      S.PUT(Begad+Length,0X); WriteAss(Name);
      MAS.Init(Begad,Name); BinInit := FALSE; SpecInit := FALSE;
      Init1; MAS.Get(sym); StatSeq(eof);
      IF NOT MAS.scanerr THEN MAS.Reinit(Begad,Name);
        Init2; MAS.Get(sym); StatSeq(eof);
        IF BinInit THEN FB.Close(bf) END; CloseSpec;
        IF NOT MAS.scanerr THEN WriteSymbols END;
      END;
      MAS.Close;
      IF MAS.scanerr THEN IO.WriteString("assembly aborted");
        Task.RetCode := 1
      ELSE IO.WriteString("assembly complete")
      END;
      IO.WriteLn;
    ELSE
      IO.WriteString("File not found"); IO.WriteLn;
    END;
  ELSE
    IO.WriteString("Usage: mass51 <file>"); IO.WriteLn;
  END ;
 END Assemble;

BEGIN
  NEW(PrevListOn); LastStackElem := PrevListOn;
  MasPar.MacExp := FALSE;
  MAS.GetValue := GetValue; MAS.extsym := S.ADR(sym);
  IO.WriteString("8051 Makro Assembler V1.05  (c) Stephan Junker  ");
  IO.WriteString( Sys.compDate);
  IO.WriteLn; Assemble
END Mass51.