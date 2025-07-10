MODULE MAS51; (* version for 8051 family *)

(* History :
   SJ  18.3.93  : adaptation from OCS by N. Wirth and SJ
   		 19.3.93	: error constants, ident
   		 20.3.93  : error in Identifier corrected, Reinit introduced
   		 21.3.93  : constants instead of numbers
   		 22.3.93  : CharSet
   		 23.3.93  : listing
   		 24.3.93  : macroparameter automatically used
   		 25.3.93  : V1.00 ready
   		 14.4.93  : line of source text at error message added
   		 29.4.93  : correction for load time linking
   		 21.5.93  : error output better
*)

IMPORT S:=SYSTEM, NStr:=NumStr, Str:=Strings, File, FN:=Filename,
       MasPar, FB:=FileBuffer, IO, Task;

 (*symbols:
     |  0          1          2           3            4
  ---|--------------------------------------------------------
   0 |  null       *          /           !            #
   5 |  &          ^          ~           ~~           +
  10 |  -          |          <=          >            >=
  15 |  =          <>         <           IN           ,
  20 |  :          ?          )           ]            }
  25 |  OF         THEN       DO          TO           (
  30 |  [          {          IFC         :=           number
  35 |  NIL        string     ident       ;            FOR
  40 |  END        ELSE       ELSIF       UNTIL        IF
  45 |  CASE       WHILE      REPEAT      LOOP         WITH
  50 |  EXIT       RETURN     ARRAY       RECORD       POINTER
  55 |  BEGIN      CONST      TYPE        VAR          PROCEDURE
  60 |  IMPORT     MODULE     eof					EQU					 SET
  65 |	SFR				 SFRB				BIT					CHARSET			 ORG
  70 |	CPU				 SEGMENT		CODE				DATA				 XDATA
  75 |  IDATA			 BITDATA		DB					DW					 DD
  80 |  ALIGN			 MACRO			ENDM				IRP					 REPT
  85 |  ELSEIF		 ENDIF			IFDEF				IFNDEF			 PAGE
  90 |	NEWPAGE		 MACEXP			ON					OFF					 LISTING
  95 |	PRTINIT		 PRTEXIT		TITLE				SHARED			 INCLUDE
  100|  MESSAGE		 WARNING		ERROR				FATAL				 B
  105|  W					 L					$						TRUE				 FALSE
  110|	VERSION		 @          DS          OUTPUT       BINARY
  115|  SPECIAL	   TOUPPER 		UPSTRING		OPT					 LOCAL
  120|	GLOBAL                DEF
  125|
  130|
  135|
  140|	A					 C					DPTR				PC					 R0
  145|	R1				 R2					R3					R4					 R5
  150|	R6				 R7					AB
  155|	ACALL			 CALL				ADD					ADDC				 AJMP
  160|	JMP				 ANL				CJNE				CLR					 CPL
  165|	DA				 DEC				DIV					DJNZ				 INC
  170|	JB				 JBC				JC					JNB					 JNC
  175|	JNZ				 JZ					LCALL				LJMP				 MOV
  180|	MOVC			 MOVX				NOP					MUL					 ORL
  185|	POP				 PUSH				RET					RETI				 RL
  190|	RLC				 RR					RRC					SETB				 SJMP
  195|	SUBB			 SWAP				XCH					XCHD				 XRL

  not all symbols are used for MAss, the symbols for Oberon were not deleted *)

CONST KW = 43;  (*size of hash table*)
   maxDig = 32; maxInt = 7FFFH; maxShInt = 7FH; maxExp = 38; maxLExp = 308;
   maxStrLen = 128; maxIdLen = 22;

  (* error numbers *)
   illdig = 0; strhi = 1; strend = 2; exphi = 3; illmode = 4; syntax = 5;
   valexp = 10; offshi = 7; unknown = 8; double = 17; macroexp = 11;
   fewer = 12; nomac = 13; codeseg = 14; segexp = 26; noinc = 16;
   parexp = 18; sechi = 20; notcode = 21; range = 25; segerr = -1;
   nostruct = 27; onoffexp = 28; nosfrb = 29;

  (*symbol values*)
   times = 1; slash = 2; xor = 3; not = 7; and = 5; plus = 9; minus = 10;
   or = 11; arrow = 6; imm = 4; mod = 4; lss = 17; leq = 12; gtr = 13;
   geq = 14; in = 18; neq = 16; eql = 15; comma = 19; notl = 8;
   colon = 20; ask = 21; rparen = 22; rbrak = 23; rbrace = 24; then = 26;
   do = 27; lparen = 29; lbrak = 30; lbrace = 31; ifc = 32; assign = 33;
   number = 34; string = 36; idexp = 37;
   semicolon = 38; for = 39; end = 40; else = 41; elsif = 42; until = 43;
   if = 44; repeat = 47; loop = 48; exit = 50;
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

  (* ident types *)
   Clab = 0; Dlab = 1; Xlab = 2; Blab = 3; Macro = 4; MacroPar = 5;
   Ccon = 6; Dcon = 7; Xcon = 8; Bcon = 9; Cvar = 10; Dvar = 11;
   Xvar = 12; Bvar = 13;

TYPE ident* = ARRAY maxIdLen+2 OF CHAR;
		 sym 		= POINTER TO symbol;
		 symbol = RECORD
		 						Next : sym;
		 						symb : INTEGER;
		 						id   : ARRAY 12 OF CHAR;
		 					END;
     symtab = ARRAY KW OF sym;
     textptr*= POINTER TO textdef;
     textdef*= RECORD
                Prev : textptr;
                Begad*,lastpos : LONGINT;
                Runad* : POINTER TO ARRAY 100 OF CHAR;
                lastline : INTEGER;
                LastListed,LineAdr : LONGINT;
                ListPath,List,AutoReset : BOOLEAN;
                Name* : ARRAY 80 OF CHAR;
              END;
     lab*		= POINTER TO labdef;
     labdef*= RECORD
								Next* : lab;
       				  Val*  : LONGINT; (* Label : loc; Macro : ^Text; MacroPar : ^String *)
       				  Type* : INTEGER;
       				  Global* : BOOLEAN;
       				  Id*   : ident;
       				  Begad*: LONGINT;
       				  File* : ARRAY 80 OF CHAR;
       		    END;
     keytab*= ARRAY KW OF lab;
     tab*	  = POINTER TO tabdef;
     tabdef*= RECORD
      				  Upper*,Lower*,Next* : tab;
      				  Start*,End* : LONGINT;
      				  KeyTab* : keytab;
      			  END;

 (*name, numtyp, intval, realval, lrlval are implicit results of Get*)
VAR numtyp* : INTEGER; (* 1 = char, 2 = integer, 3 = real, 4 = longreal*)
  intval*  : LONGINT;
  realval* : REAL;
  lrlval*  : LONGREAL;
  scanerr* : BOOLEAN;
  name*    : ARRAY 128 OF CHAR;
  MainDial*: LONGINT;
  LineFeed* : BOOLEAN; (* set if a LF occured before the current symbol *)
  FirstChar*: BOOLEAN; (* set if a name was read which started in column 0 *)
  Hash*    : INTEGER;  (* value of hash function for name *)
  CharSet* : ARRAY 256 OF CHAR;
  Loc*,LastLoc : LONGINT;

VAR
  ch*: CHAR;     (*current character*)
  Text* : textptr; (* first text, currently working on *)
  FreeTextRecs : textptr;
  keyTab : symtab;
  CurrTab* : tab;
  Label* : lab; (* last searched/entered label *)

VAR
  NumErr, NumWarn : INTEGER;
  ErrName,FileName,ListName : FN.path;
  lf,ef : FB.file;
  BytesInLine,LinesInPage,NumSym,lastsym : INTEGER;
  GetValue* : PROCEDURE (VAR Mode : INTEGER; VAR Value : LONGINT);
  extsym* : POINTER TO ARRAY 1 OF INTEGER;

PROCEDURE HexChar(Nibble : INTEGER) : CHAR;
 BEGIN
  Nibble := S.ANL(Nibble,0FH);
  IF Nibble >= 10 THEN RETURN CHR(Nibble+37H) END;
  RETURN CHR(Nibble+30H)
 END HexChar;

PROCEDURE WriteLnl;
 BEGIN
  FB.WriteWord(lf,0D0AH); INC(LinesInPage);
  IF (MasPar.PageSize # 0) AND (LinesInPage >= MasPar.PageSize) THEN
    LinesInPage := 0; FB.WriteByte(lf,0CH);
    IF MasPar.Title[0] # 0X THEN
      FB.WriteChars(lf,MasPar.Title); FB.WriteLong(lf,0D0A0D0AH);
    END;
  END;
  BytesInLine := 0;
 END WriteLnl;

PROCEDURE FormFeed*;
 BEGIN
  IF Text.List AND MasPar.ListOn THEN FB.WriteChar(lf,0CX) END;
 END FormFeed;

PROCEDURE WriteHead;
  VAR s : ARRAY 10 OF CHAR;
 BEGIN
  IF lf.Length = 0 THEN FB.WriteChars(lf,MasPar.PrtInit) END;
  IF LastLoc # Loc THEN LastLoc := Loc;
    NStr.LIntTo(Loc,16,s); Str.Adjust(Str.right,5," ",s);
    FB.WriteChars(lf,s); FB.WriteChars(lf," : ");
  ELSE FB.WriteChar(lf,09X)
  END;
 END WriteHead;

PROCEDURE ListByte*(Byte : INTEGER);
  (* writes a hex byte into the listing, max. 5 bytes per line *)
 BEGIN
  IF MasPar.ListOn THEN
    IF BytesInLine = 5 THEN WriteLnl END;
    IF BytesInLine = 0 THEN WriteHead END;
    FB.WriteChar(lf,HexChar(Byte DIV 16)); FB.WriteChar(lf,HexChar(Byte));
    FB.WriteChar(lf," "); INC(BytesInLine);
  END;
 END ListByte;

PROCEDURE ListSource*;
  VAR Adr : LONGINT; c : CHAR;
 BEGIN
  IF Text.List AND MasPar.ListOn THEN Adr := Text.LastListed;
    WHILE Adr < Text.LineAdr DO
      IF BytesInLine = 0 THEN WriteHead END;
      IF BytesInLine <= 2 THEN FB.WriteChar(lf,09X) END;
      FB.WriteChar(lf,09X); S.GET(Adr,c);
      WHILE (c # 0X) AND (c # 0DX) DO
        FB.WriteChar(lf,c); INC(Adr); S.GET(Adr,c);
      END;
      WriteLnl; INC(Adr,2);
    END;
  END;
  Text.LastListed := Text.LineAdr;
 END ListSource;

PROCEDURE ListSymbol*(VAR Name : ARRAY OF CHAR; Value : LONGINT; Type : INTEGER);
  VAR s : ARRAY 10 OF CHAR; i : INTEGER;
 BEGIN
  IF Text.List AND MasPar.ListOn AND (Type # Macro) AND (Type # MacroPar) THEN
    IF NumSym = 0 THEN WriteLnl; FB.WriteChars(lf,"Symboltabelle:");
      WriteLnl;
    END;
    IF NumSym MOD 3 = 0 THEN WriteLnl END;
    FB.WriteChars(lf,Name); FB.WriteChars(lf," : ");
    i := 16 - Str.Length(Name);
    WHILE i > 0 DO FB.WriteChar(lf," "); DEC(i) END;
    NStr.LIntTo(Value,16,s); Str.Adjust(Str.right,9," ",s);
    FB.WriteChars(lf,s); FB.WriteChar(lf," ");
    IF Type >= Cvar THEN DEC(Type,Cvar)
    ELSIF Type >= Ccon THEN DEC(Type,Ccon)
    END;
    CASE Type OF
      Clab : FB.WriteChars(lf,"C | ") |
      Dlab : FB.WriteChars(lf,"D | ") |
      Xlab : FB.WriteChars(lf,"X | ") |
      Blab : FB.WriteChars(lf,"B | ")
      ELSE FB.WriteChars(lf,"- | ")
    END;
    INC(NumSym);
  END;
 END ListSymbol;

PROCEDURE Read*(VAR ch : CHAR);
 BEGIN
  ch := Text.Runad[0]; INC(Text.Runad);
 END Read;

PROCEDURE WriteString(s : ARRAY OF CHAR);
 BEGIN
  FB.WriteChars(ef,s);
 END WriteString;

PROCEDURE WriteLn;
 BEGIN
  FB.WriteWord(ef,0D0AH);
 END WriteLn;

PROCEDURE WriteInt(i : LONGINT);
 VAR s : ARRAY 10 OF CHAR;
 BEGIN
  NStr.LIntTo(i,10,s); WriteString(s);
 END WriteInt;

PROCEDURE GetLine() : INTEGER;
  VAR c : CHAR; Pos : LONGINT;
 BEGIN
  Pos := S.VAL(LONGINT,Text.Runad) - Text.Begad;
  IF Text.lastline = 0 THEN Text.lastline := 1 END;
  c := 1X;
  WHILE (Pos > Text.lastpos) AND (Pos > 0) AND (c # 0X) DO
    DEC(Pos); S.GET(Text.Begad + Pos,c);
    IF c = 0AX THEN INC(Text.lastline) END;
  END;
  Text.lastpos := S.VAL(LONGINT,Text.Runad) - Text.Begad;
  RETURN Text.lastline
 END GetLine;

PROCEDURE GetCol() : INTEGER;
  VAR c : CHAR; Col : INTEGER; Pos : LONGINT;
 BEGIN
  Col := 1; Pos := S.VAL(LONGINT,Text.Runad) - Text.Begad;
  WHILE Pos > 0 DO DEC(Pos);
    S.GET(Text.Begad + Pos,c);
    IF c = 0AX THEN RETURN Col END;
    INC(Col);
  END;
  RETURN Col
 END GetCol;

PROCEDURE WriteErrorLine(Error : ARRAY OF CHAR);
  (* writes a line into the error file with the format given in ErrorFormat *)
  VAR i,j,k : INTEGER;
      s,e : ARRAY 50 OF CHAR;
      p   : POINTER TO ARRAY 50 OF CHAR;
      CurrText : textptr;
 BEGIN
  COPY(MasPar.ErrorFormat,s); i := 0; j := 0;
  WHILE s[i] # 0X DO
    IF s[i] = "\" THEN
      IF j < i THEN s[i] := 0X; p := S.ADR(s[j]); WriteString(p^) END;
      INC(i,2); j := i;
      CASE s[i-1] OF
        "d" : WriteString(Text.Name) |
        "z" : WriteInt( GetLine() ) |
        "s" : WriteInt( GetCol() ) |
        "p" : WriteInt( S.VAL(LONGINT,Text.Runad) - Text.Begad ) |
        "f" : WriteString(Error); WriteString(" ("); WriteString(name);
          WriteString(')'); |
        ELSE DEC(j)
      END;
    ELSE INC(i);
    END;
  END;
  IF j < i THEN p := S.ADR(s[j]); WriteString(p^) END;
  WriteLn;
  IF Text.ListPath THEN CurrText := Text; Text := Text.Prev;
    WriteErrorLine("called previous error"); Text := CurrText
  END;
 END WriteErrorLine;

PROCEDURE WriteWarn(n : INTEGER);
  VAR s : ARRAY 50 OF CHAR;
 BEGIN
  IF MasPar.WarningsOut THEN
    CASE n OF
      -segerr : s := "segment error" |
      ELSE NStr.IntTo(n,10,s)
    END(*CASE*);
    Str.Insert("Warning : ",0,s);
    WriteErrorLine(s);
  END;
 END WriteWarn;

PROCEDURE WriteErr(n : INTEGER);
  VAR s : ARRAY 50 OF CHAR;
 BEGIN
  CASE n OF
    illdig : s := "illegal digit" |
    strhi : s := "string too long" |
    strend : s := "string not ended" |
    exphi : s := "exponent too high" |
    illmode : s := "illegal addressing mode" |
    syntax : s := "syntax error" |
    valexp : s := "value expected" |
    offshi : s := "offset too high" |
    unknown : s := "unknown identifier" |
    double : s := "identifier already defined" |
    plus : s := "'+' expected" |
    comma : s := "',' expected" |
    a : s := "'A' expected" |
    idexp : s := "identifier expected" |
    endm : s := "'ENDM' expected" |
    macroexp : s := "macro expected" |
    fewer : s := "fewer parameters than defined" |
    nomac : s := "no macro allowed" |
    codeseg : s := "only allowed in code segment" |
    rparen : s := "')' expected" |
    segexp : s := "segment type expected" |
    noinc : s := "include file not found" |
    end : s := "'END' expected" |
    parexp : s := "parameter expected" |
    eof : s := "end of file expected" |
    string : s := "string expected" |
    endif : s := "'ENDIF' expected" |
    sechi : s := "second character must be greater than first" |
    notcode : s := "not allowed in code segment" |
    range : s := "value out of range" |
    eql : s := "'=' expected" |
    assign : s := "':=' expected" |
    nostruct : s := "no structure to leave" |
    until : s := "'until' expected" |
    onoffexp : s := "on or off expected" |
    rbrace : s := "'}' expected" |
    rbrak : s := "']' expected" |
    nosfrb : s := "address not bitaddressable" |
    ELSE NStr.IntTo(n,10,s)
  END(*CASE*);
  WriteErrorLine(s);
 END WriteErr;

PROCEDURE Mark*(n: INTEGER);
  VAR l : INTEGER;
 BEGIN
  l := Text.lastline;
  IF (l # GetLine() ) AND (NumErr < MasPar.MaxErr) THEN
    IF n < 0 THEN WriteWarn( - n ); INC(NumWarn);
    ELSE
      INC(NumErr); scanerr := TRUE; WriteErr( n );
    END ;
  END;
 END Mark;

PROCEDURE Error*(VAR Err : ARRAY OF CHAR);
  VAR s : ARRAY 10 OF CHAR;
 BEGIN
  INC(NumErr); scanerr := TRUE; WriteErrorLine(Err);
  IO.WriteString(Err); IO.WriteLn;
 END Error;

PROCEDURE Warning*(VAR Err : ARRAY OF CHAR);
  VAR s : ARRAY 10 OF CHAR;
 BEGIN
  INC(NumWarn);
  IF MasPar.WarningsOut THEN WriteErrorLine(Err);
    IO.WriteString(Err); IO.WriteLn;
  END;
 END Warning;

PROCEDURE^ Get2(VAR sym: INTEGER);

PROCEDURE Search*(VAR Value : LONGINT; VAR Type : INTEGER) : BOOLEAN;
  (* tries to find MAS.name in the current table and in upper ones. Returns
     FALSE if not found *)
  VAR Tab : tab;
 BEGIN
  Tab := CurrTab;
  WHILE Tab # NIL DO
    Label := Tab.KeyTab[Hash];
  	WHILE Label # NIL DO
  		IF Label.Id = name THEN Value := Label.Val;
  		  Type := Label.Type; RETURN TRUE
  		END;
  		Label := Label.Next;
  	END;
  	Tab := Tab.Upper;
 	END;
 	RETURN FALSE;
 END Search;

PROCEDURE String(c : CHAR; VAR sym: INTEGER);
  VAR i,j,k,Mode,Type : INTEGER; Value : LONGINT;
      s,str : ARRAY maxStrLen OF CHAR;
      p : POINTER TO ARRAY 100 OF CHAR;
 BEGIN
  i := 0; k := 0;
  LOOP Read(ch);
    IF ch = c THEN EXIT END ;
    IF ch = 0X THEN Mark(strend); EXIT END;
    IF i < maxStrLen-1 THEN
      IF ch = "\" THEN Read(ch);
        CASE CAP(ch) OF
          "B" : ch := 08X |
          "A" : ch := 07X |
          "E" : ch := 1BX |
          "T" : ch := 09X |
          "N" : ch := 0AX |
          "R" : ch := 0DX |
          "0".."9" :
              j := ORD(ch)-30H; Read(ch);
              IF (ch >= "0") AND (ch <= "9") THEN
                j := j * 10 + ORD(ch) - 30H; Read(ch);
                IF (ch >= "0") AND (ch <= "9") THEN
                  j := j * 10 + ORD(ch) - 30H; Read(ch);
                END;
              END;
              ch := CHR(j); DEC(Text.Runad) |
          "{" : Read(ch); Get2(extsym[0]);
              GetValue(Mode,Value);
              IF extsym[0] # rbrace THEN Mark(rbrace)
              ELSE DEC(Text.Runad); NStr.LIntTo(Value,10,s);
                Str.Write(s,i,str); INC(i,Str.Length(s)-1);
                ch := str[i];
              END;
          ELSE
        END;
      END;
      str[i] := CharSet[ORD(ch)]; name[i] := ch; INC(i);
      INC(k,ORD(CAP(ch)));
    ELSE Mark(strhi); EXIT
    END
  END ;
  name[i] := 0X;
  IF ch # 0X THEN Read(ch) END;
  IF c = "'" THEN
    IF i > 4 THEN Mark(strhi); i := 4 END;
    intval := 0; j := 0;
    WHILE j < i DO
      intval := intval * 256 + LONG(ORD(str[j])); INC(j);
    END;
    sym := number;
  ELSE
    Hash := ABS( (k+i) MOD KW );  (*hash function*)
    sym := string; str[i] := 0X;
    IF MasPar.IdCap THEN Str.CAPs(name) END;
    IF Search(Value,Type) AND (Type = MacroPar) THEN p := Value;
      COPY(p^,name); Str.CAPs(name);
    ELSE COPY(str,name)
    END;
  END;
 END String;

PROCEDURE Set*(VAR File : ARRAY OF CHAR; Begad,Runad : LONGINT;
               ListPath,List,AutoReset : BOOLEAN);
  VAR t : textptr;
 BEGIN
  IF Begad <= 10000H THEN HALT(21) END;
  IF Text # NIL THEN DEC(Text.Runad);
    IF NOT Text.List THEN List := FALSE END;
  END;
  ch := " ";
  IF NOT MasPar.ListOn THEN List := FALSE END;
  IF FreeTextRecs = NIL THEN NEW(t)
  ELSE t := FreeTextRecs; FreeTextRecs := t.Prev
  END;
  t.Prev := Text; Text := t;
  t.Begad := Begad; t.Runad := Runad; t.lastpos := -20; t.lastline := 0;
  t.LastListed := Runad; t.LineAdr := Runad; t.ListPath := ListPath;
  t.List := List; t.AutoReset := AutoReset; COPY(File,t.Name);
 END Set;

PROCEDURE SetText*(text : textptr; Runad : LONGINT;
                   ListPath,List,AutoReset : BOOLEAN);
 BEGIN
  Set(text.Name,text.Begad,Runad,ListPath,List,AutoReset);
 END SetText;

PROCEDURE Reset*;
  VAR t : textptr;
 BEGIN
  t := Text; Text := Text.Prev; Read(ch);
  t.Prev := FreeTextRecs; FreeTextRecs := t;
 END Reset;

PROCEDURE Identifier(VAR symb : INTEGER);
  VAR i,k,Type : INTEGER; KeyWord : ident; Sym : sym;
      Value : LONGINT;
 BEGIN
  i := 0; k := 0;
  REPEAT
    IF i < maxIdLen THEN name[i] := ch;
      KeyWord[i] := CAP(ch); INC(k, ORD(CAP(ch))); INC(i);
    END ;
    Read(ch)
  UNTIL ((ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch)))
        AND (ch # "_") AND (ch # ".");
  name[i] := 0X; KeyWord[i] := 0X;
  k := ABS( (k+i) MOD KW );  (*hash function*)
  Hash := k;
  Sym := keyTab[k];
  WHILE Sym # NIL DO
  	IF (MasPar.CommCap AND (Sym.id = KeyWord)) OR
  	   (NOT MasPar.CommCap AND (Sym.id = name)) THEN
  	  symb := Sym.symb;
      IF MasPar.CommCap THEN COPY(KeyWord,name) END;
  	  RETURN
  	END;
  	Sym := Sym.Next;
  END;
  IF MasPar.IdCap THEN COPY(KeyWord,name) END;
  IF Search(Value,Type) AND (Type = MacroPar) THEN
    Set(Label.File,Label.Begad,Value,TRUE,FALSE,TRUE); Get2(symb)
  ELSE symb := idexp
  END;
 END Identifier;

PROCEDURE Hval(ch: CHAR): INTEGER;
  VAR d: INTEGER;
 BEGIN d := ORD(ch) - 30H; (*d >= 0*)
  IF (d >= 10) OR (d < 0) THEN
    IF (d >= 17) & (d < 23) THEN DEC(d, 7) ELSE d := 0; Mark(illdig) END
  END ;
  RETURN d
 END Hval;

PROCEDURE Bval(ch: CHAR): INTEGER;
  VAR d: INTEGER;
 BEGIN d := ORD(ch) - 30H; (*d >= 0*)
  IF (d >= 2) OR (d < 0) THEN Mark(illdig) END;
  RETURN d
 END Bval;

PROCEDURE Oval(ch: CHAR): INTEGER;
  VAR d: INTEGER;
 BEGIN d := ORD(ch) - 30H; (*d >= 0*)
  IF (d >= 8) OR (d < 0) THEN Mark(illdig) END;
  RETURN d
 END Oval;

PROCEDURE Ten(e: INTEGER): REAL;
  VAR r : REAL;
 BEGIN
  r := 1.0;
  IF e > 0 THEN
    WHILE e > 10 DO r := r * 1.0E10; DEC(e,10); END(*WHILE*);
    WHILE e > 0 DO r := r * 10.0; DEC(e); END(*WHILE*);
  ELSIF e < 0 THEN
    WHILE e < -10 DO r := r / 1.0E10; INC(e,10); END(*WHILE*);
    WHILE e < 0 DO r := r / 10.0; INC(e); END(*WHILE*);
  END(*IF*);
  RETURN r
 END Ten;

PROCEDURE TenL(e: INTEGER): LONGREAL;
  VAR r : LONGREAL;
 BEGIN
  r := 1.0;
  IF e > 0 THEN
    WHILE e > 100 DO r := r * 1.0D100; DEC(e,100); END(*WHILE*);
    WHILE e > 10 DO r := r * 1.0D10; DEC(e,10); END(*WHILE*);
    WHILE e > 0 DO r := r * 10.0D0; DEC(e); END(*WHILE*);
  ELSIF e < 0 THEN
    WHILE e < -100 DO r := r / 1.0D100; INC(e,100); END(*WHILE*);
    WHILE e < -10 DO r := r / 1.0D10; INC(e,10); END(*WHILE*);
    WHILE e < 0 DO r := r / 10.0D0; INC(e); END(*WHILE*);
  END(*IF*);
  RETURN r
 END TenL;

PROCEDURE Number;
  VAR i, j, h, d, e, n: INTEGER;
      x, f: REAL;
      y, g: LONGREAL;
      neg: BOOLEAN;
      lastCh : CHAR;
      dig: ARRAY maxDig OF CHAR;

 PROCEDURE ReadScaleFactor;
  BEGIN Read( ch);
   IF ch = "-" THEN neg := TRUE; Read( ch)
   ELSE neg := FALSE;
     IF ch = "+" THEN Read( ch) END
   END ;
   IF ("0" <= ch) & (ch <= "9") THEN
     REPEAT e := e*10 + ORD(ch)-30H; Read( ch);
     UNTIL (ch < "0") OR (ch >"9")
   ELSE Mark(illdig)
   END
  END ReadScaleFactor;

 BEGIN i := 0;
  REPEAT dig[i] := ch; INC(i); Read( ch)
  UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch));
  j := 0;
  WHILE (j < i-1) & (dig[j] = "0") DO INC(j) END ;
  IF ch = "." THEN (*decimal point*)
    h := i;
    WHILE ("0" <= ch) & (ch <= "9") DO (*read fraction*)
      IF i < maxDig THEN dig[i] := ch; INC(i) END ;
      Read( ch)
    END ;
    IF ch = "D" THEN
      y := 0.0D0; g := 1.0D0; e := 0;
      WHILE j < h DO y := y*10.0D0 + (ORD(dig[j])-30H); INC(j) END ;
      WHILE j < i DO g := g/10.0D0; y := (ORD(dig[j])-30H)*g + y; INC(j) END ;
      ReadScaleFactor;
      IF neg THEN
        IF e <= maxLExp THEN y := y / TenL(e) ELSE y := 0.0D0 END
      ELSIF e > 0 THEN
        IF e <= maxLExp THEN y := TenL(e) * y ELSE y := 0.0D0; Mark(exphi) END
      END ;
      numtyp := 4; lrlval := y
    ELSE x := 0.0; f := 1.0; e := 0;
      WHILE j < h DO x := x*10.0 + (ORD(dig[j])-30H); INC(j) END ;
      WHILE j < i DO f := f/10.0; x := (ORD(dig[j])-30H)*f + x; INC(j) END ;
      IF ch = "E" THEN ReadScaleFactor END ;
      IF neg THEN
        IF e <= maxExp THEN x := x / Ten(e) ELSE x := 0.0 END
      ELSIF e > 0 THEN
        IF e <= maxExp THEN x := Ten(e) * x ELSE x := 0.0; Mark(exphi) END
      END ;
      numtyp := 3; realval := x
    END
  ELSE (*integer*)
    lastCh := dig[i-1]; intval := 0;
    IF lastCh = "H" THEN DEC(i);
      WHILE j < i DO
        intval := intval * 16 + Hval(dig[j]);
        INC(j);
      END;
    ELSIF lastCh = "B" THEN DEC(i);
      WHILE j < i DO
        intval := intval * 2 + Bval(dig[j]);
        INC(j);
      END;
    ELSIF lastCh = "O" THEN DEC(i);
      WHILE j < i DO
        intval := intval * 8 + Oval(dig[j]);
        INC(j);
      END;
    ELSE (*decimal*)
      REPEAT
        d := ORD(dig[j]) - 30H;
        IF (d < 10) AND (d >= 0) THEN intval := intval*10 + d
        ELSE Mark(illdig);
        END ;
        INC(j)
      UNTIL j = i;
    END ;
    numtyp := 2
  END
 END Number;

PROCEDURE Get*(VAR sym : INTEGER);
 BEGIN
  LineFeed := FALSE; Get2(sym)
 END Get;

PROCEDURE Get2(VAR sym: INTEGER);
  VAR s: INTEGER; xch: CHAR;
      str : ARRAY 10 OF CHAR;

 PROCEDURE TestLineFeed;
  BEGIN
   IF (ch = 0AX) OR (ch = 0X) THEN
     LineFeed := TRUE; Text.LineAdr := S.VAL(LONGINT,Text.Runad);
   END;
  END TestLineFeed;

 PROCEDURE Comment; (* do not read after end of file *)
  BEGIN Read( ch);
   LOOP
     LOOP
       WHILE ch = "(" DO Read( ch);
         IF ch = "*" THEN Comment END
       END ;
       IF ch = "*" THEN Read( ch); EXIT END ;
       TestLineFeed;
       IF ch = 0X THEN EXIT END ;
       Read( ch)
     END ;
     IF ch = ")" THEN Read( ch); EXIT END ;
     IF ch = 0X THEN EXIT END
   END;
  END Comment;

 PROCEDURE NextLine;
  BEGIN
   WHILE (ch # 0AX) AND (ch # 0X) DO Read(ch) END;
   LineFeed := TRUE;
  END NextLine;

 PROCEDURE TestFirstChar;
   VAR xch : CHAR;
  BEGIN
   IF (S.VAL(LONGINT,Text.Runad) - Text.Begad > 1) THEN
     S.GET(S.VAL(LONGINT,Text.Runad)-2, xch)
   END;
   IF (S.VAL(LONGINT,Text.Runad) - Text.Begad <= 1) OR (xch = 0AX) THEN
     FirstChar := TRUE
    END;
  END TestFirstChar;

 BEGIN
  FirstChar := FALSE;
  LOOP (*ignore control characters*)
    IF ch <= " " THEN
      TestLineFeed;
      IF ch = 0X THEN EXIT ELSE Read(ch) END
    ELSIF ch > 7FX THEN Read( ch)
    ELSE EXIT
    END
  END ;
  CASE ch OF
    0X  :
      IF Text.AutoReset THEN Reset; Get(s)
      ELSE s := eof
      END |
   | "$" : s := lc; Read(ch)
   | "@" : s := ind; Read(ch)
   | 22X,"'"  : String(ch,s)
   | "#"  : s := imm; Read( ch)
   | ")"  : s := rparen; Read( ch)
   | "}"  : s := rbrace; Read( ch)
   | "{"  : s := lbrace; Read( ch)
   | "["  : TestFirstChar; s := lbrak; Read( ch)
   | "]"  : s := rbrak; Read( ch)
   | "*"  : s := times; Read( ch)
   | "+"  : s := plus; Read( ch)
   | ","  : s := comma; Read( ch)
   | "-"  : s := minus; Read( ch)
   | "/"  : s := slash; Read( ch)
   | ":"  : Read( ch);
     IF ch = "=" THEN s := assign; Read(ch) ELSE s := colon END
   | ";"  : NextLine; Get2(s)
   | "^"  : s := arrow; Read( ch)
   | "="  : s := eql; Read( ch)
   | "&"  : s := and; Read( ch); IF ch = "&" THEN Read(ch) END
   | "?"  : s := ask; Read(ch);
   | "("  : Read( ch);
       IF ch = "*" THEN Comment; Get2(s)
       ELSE s := lparen
       END
   | "|"  : s := or; Read( ch); IF ch = "|" THEN Read(ch) END
   | "!"  : s := xor; Read( ch); IF ch = "!" THEN Read(ch) END
   | "~"  : Read( ch);
   			IF ch = "~" THEN Read(ch); s := notl ELSE s := not END
   | "<"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := leq
        ELSIF ch = ">" THEN Read(ch); s := neq
        ELSE s := lss END
   | ">"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := geq ELSE s := gtr END
   | "0".."9": Number; s := number
   | "A".."Z","a".."z" : TestFirstChar; Identifier(s)
   ELSE s := 0; Read( ch);
  END ;
  sym := s; lastsym := s;
 END Get2;

PROCEDURE Init*(Begad : LONGINT; VAR Name : ARRAY OF CHAR);
  VAR d : BOOLEAN; i : INTEGER;
 BEGIN
  IO.WriteString("Pass 1"); IO.WriteLn;
  ch := " "; scanerr := FALSE; Set(Name,Begad,Begad,FALSE,TRUE,FALSE);
  NumErr := 0; NumWarn := 0;
  COPY(Name,ErrName); FN.SetExt("ERR",ErrName); COPY(Name,FileName);
  COPY(Name,ListName); FN.SetExt(MasPar.LstExt,ListName);
  d := FB.Open(ListName,10*1024,lf);
  d := FB.Open(ErrName,10*1024,ef);
  BytesInLine := 0; LinesInPage := 0; NumSym := 0; i := 0;
  REPEAT CharSet[i] := CHR(i); INC(i) UNTIL i = 256;
 END Init;

PROCEDURE Reinit*(Begad : LONGINT; VAR Name : ARRAY OF CHAR);
 BEGIN
  IO.WriteString("Pass 2"); IO.WriteLn;
  ch := " "; Text := NIL; Set(Name,Begad,Begad,FALSE,TRUE,FALSE);
  Loc := 0; LastLoc := -1;
 END Reinit;

PROCEDURE Close*;
  VAR d : BOOLEAN;
 BEGIN
  FB.Close(ef);
  IF ef.Length = 0 THEN d := File.Delete(ErrName);
    IO.WriteString("No errors"); IO.WriteLn;
  ELSE IO.WriteInt(NumErr); IO.WriteString(" errors and ");
    IO.WriteInt(NumWarn); IO.WriteString(" warnings");
    IO.WriteLn;
  END;
  IF lf.Length = 0 THEN FB.Close(lf); d := File.Delete(ListName)
  ELSE FB.WriteString(lf,MasPar.PrtExit); FB.Close(lf)
  END;
  IF NumErr = 0 THEN Task.RetCode := 0
  ELSE Task.RetCode := 2
  END;
 END Close;

PROCEDURE EnterKW(symb : INTEGER; name: ARRAY OF CHAR);
  VAR j, k: INTEGER; Sym : sym;
 BEGIN j := 0; k := 0;
  REPEAT INC(k, ORD(name[j])); INC(j)
  UNTIL (j >= LEN(name)) OR (name[j] = 0X);
  k := (k+j) MOD KW;  (*hash function*)
  NEW(Sym); Sym.Next := keyTab[k]; keyTab[k] := Sym;
  Sym.symb := symb; COPY(name, Sym.id);
 END EnterKW;

BEGIN
 EnterKW(end,"END");
 EnterKW(if,"IF");
 EnterKW(equ,"EQU");
 EnterKW(set,"SET");
 EnterKW(sfr,"SFR");
 EnterKW(sfrb,"SFRB");
 EnterKW(bit,"BIT");
 EnterKW(charset,"CHARSET");
 EnterKW(org,"ORG");
 EnterKW(cpu,"CPU");
 EnterKW(segment,"SEGMENT");
 EnterKW(code,"CODE");
 EnterKW(data,"DATA");
 EnterKW(xdata,"XDATA");
 EnterKW(idata,"IDATA");
 EnterKW(bitdata,"BITDATA");
 EnterKW(db,"DB");
 EnterKW(dw,"DW");
 EnterKW(dd,"DD");
 EnterKW(align,"ALIGN");
 EnterKW(macro,"MACRO");
 EnterKW(endm,"ENDM");
 EnterKW(irp,"IRP");
 EnterKW(rept,"REPT");
 EnterKW(elseif,"ELSEIF");
 EnterKW(endif,"ENDIF");
 EnterKW(ifdef,"IFDEF");
 EnterKW(ifndef,"IFNDEF");
 EnterKW(page,"PAGE");
 EnterKW(newpage,"NEWPAGE");
 EnterKW(on,"ON");
 EnterKW(off,"OFF");
 EnterKW(listing,"LISTING");
 EnterKW(prtinit,"PRTINIT");
 EnterKW(prtexit,"PRTEXIT");
 EnterKW(title,"TITLE");
 EnterKW(include,"INCLUDE");
 EnterKW(warning,"WARNING");
 EnterKW(message,"MESSAGE");
 EnterKW(error,"ERROR");
 EnterKW(fatal,"FATAL");
 EnterKW(version,"VERSION");
 EnterKW(opt,"OPT");
 EnterKW(local,"LOCAL");
 EnterKW(a,'A');
 EnterKW(c,'C');
 EnterKW(dptr,"DPTR");
 EnterKW(pc,"PC");
 EnterKW(r0,"R0");
 EnterKW(r1,"R1");
 EnterKW(r2,"R2");
 EnterKW(r3,"R3");
 EnterKW(r4,"R4");
 EnterKW(r5,"R5");
 EnterKW(r6,"R6");
 EnterKW(r7,"R7");
 EnterKW(ab,"AB");
 EnterKW(acall,"ACALL");
 EnterKW(add,"ADD");
 EnterKW(addc,"ADDC");
 EnterKW(ajmp,"AJMP");
 EnterKW(jmp,"JMP");
 EnterKW(anl,"ANL");
 EnterKW(cjne,"CJNE");
 EnterKW(clr,"CLR");
 EnterKW(cpl,"CPL");
 EnterKW(da,"DA");
 EnterKW(dec,"DEC");
 EnterKW(div,"DIV");
 EnterKW(djnz,"DJNZ");
 EnterKW(inc,"INC");
 EnterKW(jb,"JB");
 EnterKW(jbc,"JBC");
 EnterKW(jc,"JC");
 EnterKW(jnb,"JNB");
 EnterKW(jnc,"JNC");
 EnterKW(jnz,"JNZ");
 EnterKW(jz,"JZ");
 EnterKW(lcall,"LCALL");
 EnterKW(ljmp,"LJMP");
 EnterKW(mov,"MOV");
 EnterKW(movc,"MOVC");
 EnterKW(movx,"MOVX");
 EnterKW(nop,"NOP");
 EnterKW(mul,"MUL");
 EnterKW(orl,"ORL");
 EnterKW(pop,"POP");
 EnterKW(push,"PUSH");
 EnterKW(ret,"RET");
 EnterKW(reti,"RETI");
 EnterKW(rl,"RL");
 EnterKW(rlc,"RLC");
 EnterKW(rr,"RR");
 EnterKW(rrc,"RRC");
 EnterKW(setb,"SETB");
 EnterKW(sjmp,"SJMP");
 EnterKW(subb,"SUBB");
 EnterKW(swap,"SWAP");
 EnterKW(xch,"XCH");
 EnterKW(xchd,"XCHD");
 EnterKW(xrl,"XRL");
 EnterKW(ds,"DS");
 EnterKW(output,"OUTPUT");
 EnterKW(binary,"BINARY");
 EnterKW(special,"SPECIAL");
 EnterKW(for,"FOR");
 EnterKW(loop,"LOOP");
 EnterKW(do,"DO");
 EnterKW(then,"THEN");
 EnterKW(elsif,"ELSIF");
 EnterKW(else,"ELSE");
 EnterKW(repeat,"REPEAT");
 EnterKW(until,"UNTIL");
 EnterKW(ifc,"IFC");
 EnterKW(exit,"EXIT");
 EnterKW(macexp,"MACEXP");
 EnterKW(toupper,"TOUPPER");
 EnterKW(upstring,"UPSTRING");
 EnterKW(5,"AND");
 EnterKW(11,"OR");
 EnterKW(8,"NOT");
 EnterKW(def,"DEF");
END MAS51.
