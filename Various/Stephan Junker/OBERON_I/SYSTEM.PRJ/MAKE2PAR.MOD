MODULE Make2Parse;  (*NW 7.6.87 / 20.12.90*)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |22.12.92 |started as Modula version
S. Junker  |17.2.93  |Oberon version
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, NStr:=NumStr,Str:=Strings, FN:=Filename, IO,
       Form, Task;

 (*symbols:
     |  0          1          2           3            4
  ---|--------------------------------------------------------
   0 |  null       *          /           DIV          MOD
   5 |  &          +          -           OR           =
  10 |  #          <          <=          >            >=
  15 |  IN         IS         ^           .            ,
  20 |  :          ..         )           ]            }
  25 |  OF         THEN       DO          TO           (
  30 |  [          {          ~           :=           number
  35 |  NIL        string     ident       ;            |
  40 |  END        ELSE       ELSIF       UNTIL        IF
  45 |  CASE       WHILE      REPEAT      LOOP         WITH
  50 |  EXIT       RETURN     ARRAY       RECORD       POINTER
  55 |  BEGIN      CONST      TYPE        VAR          PROCEDURE
  60 |  IMPORT     MODULE     eof         ASSEMBLER    FOR
  65 |  BY *)

 CONST KW = 43;  (*size of hash table*)
    maxDig = 32;
    maxInt = 7FFFH;
    maxShInt = 7FH;
    maxExp = 38; maxLExp = 308;
    maxStrLen = 128;

 (*name, numtyp, intval, realval, lrlval are implicit results of Get*)
VAR numtyp* : INTEGER; (* 1 = char, 2 = integer, 3 = real, 4 = longreal*)
  intval*  : LONGINT;
  realval* : REAL;
  lrlval*  : LONGREAL;
  scanerr* : BOOLEAN;
  name*    : ARRAY 128 OF CHAR;

VAR
  pinxchk,ptypchk,parichk : BOOLEAN;
  ch*: CHAR;     (*current character*)
  lastpos: LONGINT; lastline : INTEGER; (*error position in source file*)

  i: INTEGER;
  keyTab  : ARRAY KW OF
        RECORD symb, alt: INTEGER; id: ARRAY 12 OF CHAR END;

VAR Begad* : LONGINT;
    Runad* : POINTER TO ARRAY 100 OF CHAR;
    NumErr*, NumWarn* : INTEGER;
    ErrName,FileName* : FN.path;
    CallOnError* : PROCEDURE;

  pc* : POINTER TO ARRAY OF INTEGER;


PROCEDURE Mark*(No : INTEGER);
  VAR d : INTEGER;
 BEGIN
  d := Form.Alert( 1, "[1][Error while parsing][Cancel]");
  Task.Exit(0);
 END Mark;

PROCEDURE Read(VAR ch : CHAR);
 BEGIN
  ch := Runad[0]; INC(Runad);
 END Read;

PROCEDURE String(c : CHAR; VAR sym: INTEGER);
  VAR i: INTEGER;
 BEGIN i := 0;
  LOOP Read(ch);
    IF ch = c THEN EXIT END ;
    IF i < maxStrLen-1 THEN name[i] := ch; INC(i) ELSE Mark(212); i := 0 END
  END ;
  Read(ch);
  IF (i = 1) AND (c = 22X) THEN sym := 34; numtyp := 1; intval := ORD(name[0])
  ELSE sym := 36; name[i] := 0X (*string*)
  END
 END String;

PROCEDURE Identifier(VAR sym: INTEGER);
  VAR i, k: INTEGER;
 BEGIN i := 0; k := 0;
  REPEAT
    IF i < 31 THEN name[i] := ch; INC(i); INC(k, ORD(ch)) END ;
    Read( ch)
  UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch));
  name[i] := 0X;
  k := (k+i) MOD KW;  (*hash function*)
  IF (keyTab[k].symb # 0) & (keyTab[k].id = name) THEN sym := keyTab[k].symb
  ELSE k := keyTab[k].alt;
    IF (keyTab[k].symb # 0) & (keyTab[k].id = name) THEN sym := keyTab[k].symb
    ELSE sym := 37 (*ident*)
    END
  END ;
 END Identifier;

PROCEDURE Hval(ch: CHAR): INTEGER;
  VAR d: INTEGER;
 BEGIN d := ORD(ch) - 30H; (*d >= 0*)
  IF d >= 10 THEN
    IF (d >= 17) & (d < 23) THEN DEC(d, 7) ELSE d := 0; Mark(2) END
  END ;
  RETURN d
 END Hval;

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
      x, f:   REAL;
      y, g: LONGREAL;
      lastCh: CHAR; neg: BOOLEAN;
      dig:    ARRAY maxDig OF CHAR;

 PROCEDURE ReadScaleFactor;
  BEGIN Read( ch);
   IF ch = "-" THEN neg := TRUE; Read( ch)
   ELSE neg := FALSE;
     IF ch = "+" THEN Read( ch) END
   END ;
   IF ("0" <= ch) & (ch <= "9") THEN
     REPEAT e := e*10 + ORD(ch)-30H; Read( ch);
     UNTIL (ch < "0") OR (ch >"9")
   ELSE Mark(2)
   END
  END ReadScaleFactor;

 BEGIN i := 0;
  REPEAT dig[i] := ch; INC(i); Read( ch)
  UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch));
  lastCh := ch; j := 0;
  WHILE (j < i-1) & (dig[j] = "0") DO INC(j) END ;
  IF ch = "." THEN Read( ch);
    IF ch = "." THEN lastCh := 0X; ch := 7FX END
  END ;
  IF lastCh = "." THEN (*decimal point*)
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
        IF e <= maxLExp THEN y := TenL(e) * y ELSE y := 0.0D0; Mark(203) END
      END ;
      numtyp := 4; lrlval := y
    ELSE x := 0.0; f := 1.0; e := 0;
      WHILE j < h DO x := x*10.0 + (ORD(dig[j])-30H); INC(j) END ;
      WHILE j < i DO f := f/10.0; x := (ORD(dig[j])-30H)*f + x; INC(j) END ;
      IF ch = "E" THEN ReadScaleFactor END ;
      IF neg THEN
        IF e <= maxExp THEN x := x / Ten(e) ELSE x := 0.0 END
      ELSIF e > 0 THEN
        IF e <= maxExp THEN x := Ten(e) * x ELSE x := 0.0; Mark(203) END
      END ;
      numtyp := 3; realval := x
    END
  ELSE (*integer*)
    lastCh := dig[i-1]; intval := 0;
    IF lastCh = "H" THEN
      IF j # i-1 THEN
        DEC(i); intval := Hval(dig[j]); INC(j);
        IF i-j <= 7 THEN
          IF (i-j = 7) & (intval >= 8) THEN DEC(intval, 16) END ;
          WHILE j < i DO intval := Hval(dig[j]) + intval * 16; INC(j) END
        END
      END
    ELSIF lastCh = "X" THEN
      DEC(i);
      WHILE j < i DO
        intval := Hval(dig[j]) + intval*16; INC(j);
        IF intval > 255 THEN Mark(203); intval := 0 END
      END
    ELSE (*decimal*)
      WHILE j < i DO
        d := ORD(dig[j]) - 30H;
        IF d < 10 THEN
        IF intval <= (MAX(LONGINT) - d) DIV 10 THEN intval := intval*10 + d
        ELSE Mark(203); intval := 0
        END
      ELSE Mark(2); intval := 0
      END ;
      INC(j)
    END
   END ;
   IF lastCh = "X" THEN numtyp := 1 ELSE numtyp := 2 END
  END
 END Number;

PROCEDURE Get*(VAR sym: INTEGER);
  VAR s,i,j : INTEGER; xch: CHAR;
      str : ARRAY 10 OF CHAR;

 PROCEDURE Comment; (* do not read after end of file *)
  BEGIN Read( ch);
   LOOP
     LOOP
       WHILE ch = "(" DO Read( ch);
         IF ch = "*" THEN Comment END
       END ;
       IF ch = "*" THEN Read( ch); EXIT END ;
       IF ch = 0X THEN EXIT END ;
       Read( ch)
     END ;
     IF ch = ")" THEN Read( ch); EXIT END ;
     IF ch = 0X THEN Mark(5); EXIT END
   END
  END Comment;

 PROCEDURE SetOption(VAR Option,PrevOpt : BOOLEAN; Select : CHAR);
  BEGIN
   IF Select = "=" THEN Option := PrevOpt
   ELSE PrevOpt := Option;
     IF Select = "+" THEN Option := TRUE
     ELSIF Select = "-" THEN Option := FALSE
     END(*IF*);
   END(*IF*);
  END SetOption;

 BEGIN
  LOOP (*ignore control characters*)
    IF ch <= " " THEN
      IF ch = 0X THEN ch := " "; EXIT
      ELSE Read( ch)
      END
    ELSIF ch > 7FX THEN Read( ch)
    ELSE EXIT
    END
  END ;
  CASE ch OF   (* " " <= ch <= 7FX *)
    " "  : s := 62; ch := 0X (*eof*)
   | "!", "$", "%", "?", "@", "\", "_", "`": s :=  0; Read( ch)
   | 22X,"'"  : String(ch,s)
   | "#"  : s := 10; Read( ch)
   | "&"  : s :=  5; Read( ch)
   | "("  : Read( ch);
       IF ch = "*" THEN
         Comment; Get(s)
       ELSE s := 29
       END
   | ")"  : s := 22; Read( ch)
   | "*"  : s :=  1; Read( ch)
   | "+"  : s :=  6; Read( ch)
   | ","  : s := 19; Read( ch)
   | "-"  : s :=  7; Read( ch)
   | "."  : Read( ch);
        IF ch = "." THEN Read( ch); s := 21 ELSE s := 18 END
   | "/"  : s := 2;  Read( ch)
   | "0".."9": Number; s := 34
   | ":"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := 33 ELSE s := 20 END
   | ";"  : s := 38; Read( ch)
   | "<"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := 12 ELSE s := 11 END
   | "="  : s :=  9; Read( ch)
   | ">"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := 14 ELSE s := 13 END
   | "A".."Z","a".."z" : Identifier(s)
   | "["  : s := 30; Read( ch)
   | "]"  : s := 23; Read( ch)
   | "^"  : s := 17; Read( ch)
   | "{"  : s := 31; Read( ch)
   | "|"  : s := 39; Read( ch)
   | "}"  : s := 24; Read( ch)
   | "~"  : s := 32; Read( ch)
   | 7FX  : s := 21; Read( ch)
  END ;
  sym := s
 END Get;

PROCEDURE Init*(source,pos : LONGINT; VAR Name : ARRAY OF CHAR);
  VAR d : BOOLEAN;
 BEGIN
  ch := " "; scanerr := FALSE; lastpos := -20; lastline := 1;
  Begad := source; Runad := source; NumErr := 0; NumWarn := 0;
  COPY(Name,ErrName); FN.SetExt("ERR",ErrName); COPY(Name,FileName);
 END Init;

PROCEDURE Close*;
  VAR d : BOOLEAN;
 BEGIN
 END Close;

PROCEDURE EnterKW(sym: INTEGER; name: ARRAY OF CHAR);
  VAR j, k: INTEGER;
 BEGIN j := 0; k := 0;
  REPEAT INC(k, ORD(name[j])); INC(j)
  UNTIL (j >= LEN(name)) OR (name[j] = 0X);
  k := (k+j) MOD KW;  (*hash function*)
  IF keyTab[k].symb # 0 THEN
    j := k;
    REPEAT INC(k) UNTIL keyTab[k].symb = 0;
    IF keyTab[j].alt # 0 THEN HALT(21) END;
    keyTab[j].alt := k
  END ;
  keyTab[k].symb := sym; COPY(name, keyTab[k].id);
 END EnterKW;

BEGIN i := KW;
 WHILE i > 0 DO
   DEC(i); keyTab[i].symb := 0; keyTab[i].alt := 0
 END ;
 keyTab[0].id := "";
 EnterKW(27, "DO");
 EnterKW(44, "IF");
 EnterKW(15, "IN");
 EnterKW(16, "IS");
 EnterKW(25, "OF");
 EnterKW( 8, "OR");
 EnterKW(40, "END");
 EnterKW( 4, "MOD");
 EnterKW(35, "NIL");
 EnterKW(58, "VAR");
 EnterKW(45, "CASE");
 EnterKW(41, "ELSE");
 EnterKW(50, "EXIT");
 EnterKW(26, "THEN");
 EnterKW(49, "WITH");
 EnterKW(52, "ARRAY");
 EnterKW(55, "BEGIN");
 EnterKW(56, "CONST");
 EnterKW(42, "ELSIF");
 EnterKW(43, "UNTIL");
 EnterKW(46, "WHILE");
 EnterKW(53, "RECORD");
 EnterKW(47, "REPEAT");
 EnterKW(51, "RETURN");
 EnterKW(59, "PROCEDURE");
 EnterKW(28, "TO");
 EnterKW( 3, "DIV");
 EnterKW(48, "LOOP");
 EnterKW(57, "TYPE");
 EnterKW(60, "IMPORT");
 EnterKW(61, "MODULE");
 EnterKW(54, "POINTER");
 EnterKW(5,  "AND");
 EnterKW(32, "NOT");
 EnterKW(63, "ASSEMBLER");
 EnterKW(64, "FOR");
 EnterKW(65, "BY");
END Make2Parse.
