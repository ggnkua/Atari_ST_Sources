MODULE OCScan; (* SJ  10.3.94 *)


IMPORT
  S:=SYSTEM, Err:=OCErr, Par:=OCPar, IO, Strings;


CONST
  (*symbol values*)
  nosym* = 0; times* = 1; slash* = 2; div* = 3; mod* = 4;
  andb* = 5; and* = 6; plus* = 7; minus* = 8; ior* = 9;
  xor* = 10; shl* = 11; shr* = 12; or* = 13; eql* = 14;
  neq* = 15; lss* = 16; leq* = 17; gtr* = 18; geq* = 19;
  in* = 20; is* = 21; arrow* = 22; period* = 23; comma* = 24;
  colon* = 25; upto* = 26; rparen* = 27; rbrak* = 28; rbrace* = 29;
  of* = 30; then* = 31; do* = 32; to* = 33; lparen* = 34;
  lbrak* = 35; lbrace* = 36; not* = 37; becomes* = 38; number* = 39;
  nil* = 40; string* = 41; ident* = 42; semicolon*= 43; bar* = 44;
  end* = 45; else* = 46; elsif* = 47; until* = 48; if* = 49;
  case* = 50; while* = 51; repeat* = 52; loop* = 53; with* = 54;
  exit* = 55; return* = 56; array* = 57; record* = 58; pointer* = 59;
  begin* = 60; const* = 61; type* = 62; var* = 63; procedure* = 64;
  import* = 65; module* = 66; eof* = 67; assembler*= 68; for* = 69;
  by* = 70; notb* = 71; td* = 72;

  (* assembler symbols *)
  elsec*=73; elsifc*=74; align*=75; macro*=76; endm*=77; irp*=78; rept*=79;
  def*=80; endc*=81; on*=82; off*=83; include*=84; message*=85;
  warning*=86; error*=87; fatal*=88; b*=89; w*=90; l*=91; s*=92; d*=93;
  cap*=96; upstring*=97; local*=99; supmode*=100; eol*=101; equ*=105;
  set*=106; charset*=107; cpu*=108; hi*=110; ls*=111; hs*=112; lo*=113;
  ne*=114; eq*=115; vc*=116; vs*=117; pl*=118; mi*=119; ge*=120; lt*=121;
  gt*=122; le*=123; sfc*=125; dfc*=126; cacr*=127; usp*=128; vbr*=129;
  caar*=130; msp*=131; isp*=132; segment*=133; code*=134; data*=135;
  bss*=136; d0*=140; a0*=148; fp0*=160; pc*=180; sr*=181;
  ccr*=182; ifc*=190;

  even*=500; base* = 501; nocom* = 502;

  (*
   * different command types:
   *
   * . "optical" differences are defined by the field contents:
   *  - commands with size, source and destination:
   *      those fields are not "Default" or NIL
   *  - commands with size and destination
   *      field src is NIL
   *  - commands with source and destination
   *      field size is "Default"
   *  - commands with destination
   *      field size is "Default" and src is NIL
   *  - commands without arguments
   *      field size is "Default", src and dest are NIL
   *
   * . differences in coding are defined by different codes
   *  - main sorting by type of coding
   *  - subsorting by type of syntax
   *)

  (* **** RRR* SS** *rrr *)
  abcd* = 200; addx* = abcd+1; sbcd* = abcd+2; subx* = abcd+3;

  cmpm* = abcd+4;

  (* **** DDD* SSee eeee *)
  add* = abcd+5; andm* = add+1; orm* = add+2; sub* = add+3;

  cmp* = add+4;

  (* **** ddd* SSEE EEEE *)
  eor* = add+5;

  (* **** RRRs **ee eeee *)
  adda* = eor+1; cmpa* = adda+1; lea* = adda+2; suba* = adda+3;

  (* **** **** SSEE EEEE *)
  addi* = adda+4; andi* = addi+1; ori* = addi+2; subi* = addi+3;
  cmpi* = addi+4; eori* = addi+5;

  (* **** qqq* SSEE EEEE *)
  addq* = addi+6; subq* = addq+1;

  (* **** ddd* SS** *DDD *)
  (* **** qqq* SS** *DDD *)
  (* **** **** **EE EEEE *)
  asl* = addq+2; asr* = asl+1; lsr* = asl+2; lsl* = asl+3;
  rol* = asl+4; ror* = asl+5; roxl* = asl+6; roxr* = asl+7;

  (* **** rrr* **EE EEEE *)
  (* **** **** **EE EEEE *)
  bchg* = asl+8; bclr* = bchg+1; bset* = bchg+2; btst* = bchg+3;

  exg* = bchg+4;

  (* **** DDD* *see eeee *)
  chk* = bchg+5;

  (* **** **** SSEE EEEE *)
  clr* = chk+1; neg* = clr+1; negx* = clr+2; notm* = clr+3;
  tst* = clr+4;

  (* **** **** **EE EEEE *)
  jmp* = clr+5; jsr* = jmp+1; pea* = jmp+2;

  nbcd* = jmp+3; st* = jmp+4; sf* = jmp+5; shi* = jmp+6;
  sls* = jmp+7; shs* = jmp+8; slo* = jmp+9; sne* = jmp+10;
  seq* = jmp+11; svc* = jmp+12; svs* = jmp+13; spl* = jmp+14;
  smi* = jmp+15; sge* = jmp+16; slt* = jmp+17; sgt* = jmp+18;
  sle* = jmp+19; tas* = jmp+20;

  (* **** **** *sEE EEEE *)
  ext* = jmp+21; extb* = ext+1;

  (* **** **** **** *RRR *)
  unlk* = ext+2; link* = unlk+1;

  swap* = unlk+2;

  (* **** DDD* **ee eeee *)
  divs* = unlk+3; divu* = divs+1; muls* = divs+2; mulu* = divs+3;

  (* **** 1100 **ee eeee  0DDD r000 0000 0DDD *)
  divsl* = divs+4; divul* = divsl+1; mulsl* = divsl+2; mulul* = divsl+3;

  (* **** **** **** **** *)
  rts* = divsl+4; illegal* = rts+1; nop* = rts+2; reset* = rts+3;
  rte* = rts+4; rtr* = rts+5; stop* = rts+6; trapv* = rts+7;

  rtd* = rts+8;

  (* **XX RRRM MMee eeee *)
  move* = rts+9; movea* = move+1;

  (* **** **** *sEE EEEE + RegList *)
  movem* = move+2;

  (* **** ddd* *s** *AAA *)
  (* **** DDD* *s** *aaa *)
  movep* = movem+1;

  (* **** DDD* qqqq qqqq *)
  moveq* = movep+1;

  (* **** **** **** ***r  RRRR ssss ssss ssss *)
  movec* = moveq+1;

  (* **** **** **** VVVV *)
  trap* = movec+1;

  (* from here to fbst 2 words base code *)

  (* **** *SS* **ee eeee  RRRR **** **** **** *)
  chk2* = trap+1; cmp2* = chk2+1;

  (* **** **** **** **** ***f ffFF F*** ****  size fehlt!? *)
  (* **** **** **ee eeee ***S SSFF F*** **** *)
  fmove* = chk2+2; fint* = fmove+1; fsinh* = fmove+2; fintrz* = fmove+3;
  fsqrt* = fmove+4; flognp1* = fmove+6; fetoxm1* = fmove+8;
  ftanh* = fmove+9; fatan* = fmove+10; fasin* = fmove+12;
  fatanh* = fmove+13; fsin* = fmove+14; ftan* = fmove+15;
  fetox* = fmove+16; ftwotox* = fmove+17; ftentox* = fmove+18;
  flogn* = fmove+20; flog10* = fmove+21; flog2* = fmove+22;
  fabs* = fmove+24; fcosh* = fmove+25; fneg* = fmove+26;
  facos* = fmove+28; fcos* = fmove+29; fgetexp* = fmove+30;
  fgetman* = fmove+31; fdiv* = fmove+32; fmod* = fmove+33;
  fadd* = fmove+34; fmul* = fmove+35; fsgldiv* = fmove+36;
  frem* = fmove+37; fscale* = fmove+38; fsglmul* = fmove+39;
  fsub* = fmove+40; fcmp* = fmove+41;

  fsincos* = fmove+42;

  (* **** **** **** ****  ***f ff?? ?*** **** *)
  ftest* = fmove+43;

  (* **** **** **EE EEEE ???????????????????? *)
  fmovem* = ftest+1;

  (* 1111 0010 01EE EEEE 0000 0000 000C CCCC *)
  fsf* = fmovem+1; fseq* = fsf+1; fsogt* = fsf+2; fsoge* = fsf+3;
  fsolt* = fsf+4; fsole* = fsf+5; fsogl* = fsf+6; fsor* = fsf+7;
  fsun* = fsf+8; fsueq* = fsf+9; fsugt* = fsf+10; fsuge* = fsf+11;
  fsult* = fsf+12; fsule* = fsf+13; fsne* = fsf+14; fst* = fsf+15;
  fssf* = fsf+16; fsseq* = fsf+17; fsgt* = fsf+18; fsge* = fsf+19;
  fslt* = fsf+20; fsle* = fsf+21; fsgl* = fsf+22; fsgle* = fsf+23;
  fsngle* = fsf+24; fsngl* = fsf+25; fsnle* = fsf+26; fsnlt* = fsf+27;
  fsnge* = fsf+28; fsngt* = fsf+29; fssneq* = fsf+30; fsst* = fsf+31;

  (* all codes higher or same fbf are label commands *)

  (* **** **** *soo oooo **** **** **** **** *)
  fbf* = fsf+32; fbeq* = fbf+1; fbogt* = fbf+2; fboge* = fbf+3;
  fbolt* = fbf+4; fbole* = fbf+5; fbogl* = fbf+6; fbor* = fbf+7;
  fbun* = fbf+8; fbueq* = fbf+9; fbugt* = fbf+10; fbuge* = fbf+11;
  fbult* = fbf+12; fbule* = fbf+13; fbne* = fbf+14; fbt* = fbf+15;
  fbsf* = fbf+16; fbseq* = fbf+17; fbgt* = fbf+18; fbge* = fbf+19;
  fblt* = fbf+20; fble* = fbf+21; fbgl* = fbf+22; fbgle* = fbf+23;
  fbngle* = fbf+24; fbngl* = fbf+25; fbnle* = fbf+26; fbnlt* = fbf+27;
  fbnge* = fbf+28; fbngt* = fbf+29; fbsneq* = fbf+30; fbst* = fbf+31;

  (* **** **** OOOO OOOO *)
  bra* = fbf+32; bsr* = bra+1; bhi* = bra+2; bls* = bra+3;
  bhs* = bra+4; blo* = bra+5; bne* = bra+6; beq* = bra+7;
  bvc* = bra+8; bvs* = bra+9; bpl* = bra+10; bmi* = bra+11;
  bge* = bra+12; blt* = bra+13; bgt* = bra+14; ble* = bra+15;

  (* **** **** **** *DDD *)
  dbt* = bra+16; dbf* = dbt+1; dbhi* = dbt+2; dbls* = dbt+3;
  dbhs* = dbt+4; dblo* = dbt+5; dbne* = dbt+6; dbeq* = dbt+7;
  dbvc* = dbt+8; dbvs* = dbt+9; dbpl* = dbt+10; dbmi* = dbt+11;
  dbge* = dbt+12; dblt* = dbt+13; dbgt* = dbt+14; dble* = dbt+15;

  (* special commands *)
  label* = dbt+16; dc* = label+1; ds* = label+2;

  (* values for numtyp *)
  chartyp* = 1; inttyp* = 2; realtyp* = 3; lrltyp* = 4;

  (* error codes *)
  strlen = 100; strend = 101; idlen = 102; illdigit = 103; diglen = 104;
  exphigh = 105; numhigh = 106; commend = 107; assonly = 185;
  idmatch = 108;

  KW = 143; (* size of hash table *)
  maxStrLen = 256; maxDig = 32;
  maxExp = 38; maxLExp = 308;

  (* symbol levels *)
  obnlev = 0; extlev = 1; asslev = 2;


TYPE
  Symbol = POINTER TO SymDesc;
  SymDesc= RECORD
             next : Symbol;
             symb : INTEGER;
             lev  : INTEGER;
             id   : ARRAY 12 OF CHAR;
           END;
  Symtab = ARRAY KW OF Symbol;


VAR
  (* name, numtyp, intval, realval, lrlval are implicit results of Get *)
  numtyp*  : INTEGER;   (* see const *)
  intval*  : LONGINT;
  realval* : REAL;
  lrlval*  : LONGREAL;
  name*    : ARRAY maxStrLen OF CHAR;

  ch*      : CHAR;   (* current character *)

  inAss*   : BOOLEAN;   (* true if assembler *)

  Options* : PROCEDURE (ptr: S.PTR); (* implemented by Stat *)

  errorOutput*: BOOLEAN; (* TRUE: mark errors *)

  keyTab   : Symtab;

  pinxchk,ptypchk,parichk,pprocCom,pshorten : BOOLEAN;

(*----------------------------------procs--------------------------------*)

PROCEDURE Mark(no: INTEGER);
 BEGIN
  IF errorOutput THEN Err.Mark(no) END;
 END Mark;


PROCEDURE Read*(VAR ch : CHAR);
 BEGIN
  S.GET( Par.position, ch); INC(Par.position);
 END Read;


PROCEDURE String(c : CHAR; VAR sym: INTEGER);
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  LOOP
    Read(ch);
    IF ch = c THEN EXIT END ;
    IF ch = 0X THEN Mark(strend); EXIT END;
    IF i < maxStrLen-1 THEN name[i] := ch; INC(i)
    ELSE Mark(strlen); i := 0
    END
  END ;
  Read(ch);
  sym := string; name[i] := 0X
 END String;


PROCEDURE IdentChar(ch: CHAR) : BOOLEAN;
 BEGIN
  RETURN (ch >= "0") & (ch <= "9") OR (CAP(ch) >= "A") & (CAP(ch) <= "Z")
          OR (ch = "_");
 END IdentChar;


PROCEDURE Identifier(VAR sym: INTEGER);
  VAR
    i, k: INTEGER;
    key : Symbol;
 BEGIN
  i := 0; k := 0;
  REPEAT
    IF (ch = "_") AND NOT inAss THEN Mark(assonly) END;
    IF i < 29 THEN
      name[i] := ch; INC(k, ORD(ch)); INC(i);
    ELSE
      Mark(idlen)
    END;
    Read( ch)
  UNTIL ~IdentChar(ch);
  name[i] := 0X;
  k := (k+i) MOD KW;  (*hash function*)
  key := keyTab[k];
  WHILE key # NIL DO
    IF key.id = name THEN
      IF (key.lev = obnlev) OR (key.lev = extlev) AND Par.ext OR
         (key.lev = asslev) AND inAss THEN
        sym := key.symb; RETURN
      END;
    END;
    key := key.next;
  END ;
  sym := ident;
 END Identifier;


PROCEDURE Hval(ch: CHAR): INTEGER;
  VAR
    d: INTEGER;
 BEGIN
  d := ORD(ch) - 30H; (*d >= 0*)
  IF d >= 10 THEN
    IF (d >= 17) & (d < 23) THEN DEC(d, 7)
    ELSE d := 0; Mark(illdigit)
    END
  END ;
  RETURN d
 END Hval;


PROCEDURE Ten(e: INTEGER): REAL;
  VAR
    r : REAL;
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
  VAR
    r : LONGREAL;
 BEGIN
  r := 1.0;
  IF e > 0 THEN
    WHILE e > 100 DO r := r * 1.0D100; DEC(e,100); END(*WHILE*);
    WHILE e > 10 DO r := r * 1.0E10; DEC(e,10); END(*WHILE*);
    WHILE e > 0 DO r := r * 10.0E0; DEC(e); END(*WHILE*);
  ELSIF e < 0 THEN
    WHILE e < -100 DO r := r / 1.0D100; INC(e,100); END(*WHILE*);
    WHILE e < -10 DO r := r / 1.0E10; INC(e,10); END(*WHILE*);
    WHILE e < 0 DO r := r / 10.0E0; INC(e); END(*WHILE*);
  END(*IF*);
  RETURN r
 END TenL;


PROCEDURE Number;
  VAR
    i, j, h, d, e, n: INTEGER;
    x, f:   REAL;
    y, g: LONGREAL;
    lastCh: CHAR; neg: BOOLEAN;
    dig:    ARRAY maxDig OF CHAR;

 PROCEDURE ReadScaleFactor;
  BEGIN
   Read( ch);
   IF ch = "-" THEN neg := TRUE; Read( ch)
   ELSE neg := FALSE;
     IF ch = "+" THEN Read( ch) END
   END ;
   IF ("0" <= ch) & (ch <= "9") THEN
     REPEAT e := e*10 + ORD(ch)-30H; Read( ch);
     UNTIL (ch < "0") OR (ch >"9")
   ELSE Mark(illdigit)
   END
  END ReadScaleFactor;

 BEGIN
  i := 0;
  REPEAT
    IF i < maxDig THEN
      dig[i] := ch; INC(i); Read( ch)
    ELSE
      Mark(diglen)
    END;
  UNTIL (ch < "0") OR ("9" < ch) & (CAP(ch) < "A") OR ("Z" < CAP(ch));
  lastCh := ch; j := 0;
  WHILE (j < i-1) & (dig[j] = "0") DO INC(j) END ;
  IF ch = "." THEN
    Read( ch);
    IF ch = "." THEN lastCh := 0X; ch := 7FX END
  END ;
  IF lastCh = "." THEN (*decimal point*)
    h := i;
    WHILE ("0" <= ch) & (ch <= "9") DO (*read fraction*)
      IF i < maxDig THEN dig[i] := ch; INC(i) END ;
      Read( ch)
    END ;
    IF ch = "D" THEN
      y := 0.0; g := 1.0; e := 0;
      WHILE j < h DO y := y*10.0 + (ORD(dig[j])-30H); INC(j) END ;
      WHILE j < i DO g := g/10.0; y := (ORD(dig[j])-30H)*g + y; INC(j) END ;
      ReadScaleFactor;
      IF neg THEN
        IF e <= maxLExp THEN y := y / TenL(e) ELSE y := 0.0 END
      ELSIF e > 0 THEN
        IF e <= maxLExp THEN y := TenL(e) * y
        ELSE y := 0.0; Mark(exphigh)
        END
      END ;
      numtyp := 4; lrlval := y
    ELSE x := 0.0; f := 1.0; e := 0;
      WHILE j < h DO x := x*10.0 + (ORD(dig[j])-30H); INC(j) END ;
      WHILE j < i DO f := f/10.0; x := (ORD(dig[j])-30H)*f + x; INC(j) END ;
      IF ch = "E" THEN ReadScaleFactor END ;
      IF neg THEN
        IF e <= maxExp THEN x := x / Ten(e) ELSE x := 0.0 END
      ELSIF e > 0 THEN
        IF e <= maxExp THEN x := Ten(e) * x
        ELSE x := 0.0; Mark(exphigh)
        END
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
        IF intval > 255 THEN Mark(numhigh); intval := 0 END
      END
    ELSE (*decimal*)
      WHILE j < i DO
        d := ORD(dig[j]) - 30H;
        IF d < 10 THEN
          IF intval <= (MAX(LONGINT) - d) DIV 10 THEN intval := intval*10 + d
          ELSE Mark(numhigh); intval := 0
          END
        ELSE Mark(illdigit); intval := 0
        END ;
        INC(j)
      END
    END ;
    IF lastCh = "X" THEN numtyp := chartyp ELSE numtyp := inttyp END
  END
 END Number;


PROCEDURE HexNumber;
 BEGIN
  intval := 0;
  WHILE (ch >= "0") AND (ch <= "9") OR (ch >= "A") AND (ch <= "F") DO
    intval := Hval(ch) + intval * 16;
    Read(ch);
  END;
  IF NOT inAss THEN Mark(assonly) END;
  numtyp := inttyp;
 END HexNumber;

(*----------------------------------Get----------------------------------*)

PROCEDURE Get*(VAR sym : INTEGER);
  VAR
    s,i,j : INTEGER; xch, optch: CHAR;
    str : ARRAY 10 OF CHAR;
    sp : Strings.ptr;
    d: BOOLEAN;

 PROCEDURE Comment;
  BEGIN
   Read( ch);
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
     IF ch = 0X THEN Mark(commend); EXIT END
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
      IF (ch = 0AX) AND inAss THEN
        Read(ch); sym := eol; RETURN
      END;
      IF ch = 0X THEN ch := " "; EXIT
      ELSE Read( ch)
      END
    ELSIF ch > 7FX THEN Read( ch)
    ELSE EXIT
    END
  END ;
  CASE ch OF   (* " " <= ch <= 7FX *)
    " "  : s := eof; ch := 0X (*eof*)
   | "!", "%", "?", "@", "\", "_", "`": s := nosym; Read( ch)
   | 22X,"'"  : String(ch,s)
   | "#"  : s := neq; Read( ch)
   | "&"  : s := and; Read( ch)
   | "("  : Read( ch);
       IF ch = "*" THEN
         S.GET( Par.position, xch);
         IF xch = "$" THEN
           sp := S.VAL( Strings.ptr, Par.position+1);
           d := Par.ReadOptions(sp^);
           IF Options # NIL THEN Options(sp) END;
         END(*IF*);
         Comment; Get(s)
       ELSE s := lparen
       END
   | ")"  : s := rparen; Read( ch)
   | "*"  : s := times; Read( ch)
   | "+"  : s := plus; Read( ch)
   | ","  : s := comma; Read( ch)
   | "-"  : s := minus; Read( ch)
   | "."  : Read( ch);
        IF ch = "." THEN Read( ch); s := upto ELSE s := period END
   | "/"  : s := slash;  Read( ch)
   | "0".."9": Number; s := number
   | "$" : Read(ch); HexNumber; s := number;
   | ":"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := becomes ELSE s := colon END
   | ";"  :
        IF inAss THEN  (* ignore rest of line *)
          REPEAT
            Read(ch);
          UNTIL (ch = 0X) OR (ch = 0AX);
          s := eol
        ELSE
          s := semicolon; Read( ch)
        END;
   | "<"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := leq
        ELSIF ch = "<" THEN Read( ch); s := shl
        ELSE s := lss
        END
   | "="  : s := eql; Read( ch)
   | ">"  : Read( ch);
        IF ch = "=" THEN Read( ch); s := geq
        ELSIF ch = ">" THEN Read( ch); s := shr
        ELSE s := gtr
        END
   | "A".."Z","a".."z" : Identifier(s)
   | "["  : s := lbrak; Read( ch)
   | "]"  : s := rbrak; Read( ch)
   | "^"  : s := arrow; Read( ch)
   | "{"  : s := lbrace; Read( ch)
   | "|"  : s := bar; Read( ch)
   | "}"  : s := rbrace; Read( ch)
   | "~"  : s := not; Read( ch)
   | 7FX  : s := upto; Read( ch)
  END ;
  IF Par.ext THEN
    IF s = notb THEN s := not  (* for compatibility to V1.XX *)
    ELSIF s = andb THEN s := and
    END;
  END;
  sym := s;
 END Get;


PROCEDURE ToEnd*(VAR id: ARRAY OF CHAR);
  VAR
    p: POINTER TO ARRAY 10 OF CHAR;
    sym: INTEGER;

  PROCEDURE Comment;
   BEGIN
    INC(p, 2);
    LOOP
      LOOP
        WHILE (p[0] = "(") & (p[1] = "*") DO Comment END;
        IF p[0] = "*" THEN INC(p); EXIT END ;
        IF p[0] = 0X THEN EXIT END ;
        INC(p)
      END ;
      IF p[0] = ")" THEN INC(p); EXIT END ;
      IF p[0] = 0X THEN Mark(commend); EXIT END
    END
   END Comment;


  PROCEDURE String;
    VAR
      c: CHAR;
   BEGIN
    c := p[0];
    REPEAT
      INC(p);
      IF p[0] = 0X THEN RETURN END;
    UNTIL p[0] = c;
    INC(p)
   END String;

 BEGIN
  p := Par.position-2;
  REPEAT
    WHILE (p[0] # 0X) & (IdentChar(p[0])
              OR (p[1] # "E")
              OR (p[2] # "N")
              OR (p[3] # "D")
              OR IdentChar(p[4])) DO
      INC(p);
      IF (p[0] = "A") & (p[1] = "S") & (p[2] = "S") & (p[3] = "E")
          & (p[4] = "M") & (p[5] = "B") & (p[6] = "L")
          & (p[7] = "E") & (p[8] = "R") THEN
        inAss := TRUE;
      END;
      IF (p[0] = "(") & (p[1] = "*") THEN
        Comment;
      ELSIF (p[0] = 22X) OR (p[0] = "'") THEN
        String
      END;
      IF (p[0] = ";") & inAss THEN
        REPEAT
          INC(p);
        UNTIL (p[0] = 0X) OR (p[0] = 0AX);
      END;
    END;
    IF p[0] = 0X THEN RETURN END;
    inAss := FALSE;
    INC(p, 4);
    Par.position := p;
    Read(ch); Get(sym);
  UNTIL (sym = ident);
  IF (name # id) THEN Mark(idmatch) END;
 END ToEnd;

(*----------------------------------Init---------------------------------*)

PROCEDURE Init*(source : LONGINT);
  VAR
    d : BOOLEAN;
 BEGIN
  ch := " ";
  Par.source := source; Par.position := source;
  errorOutput := TRUE;
 END Init;


PROCEDURE Exit*;
 BEGIN
 END Exit;

(*----------------------------------body---------------------------------*)

PROCEDURE EnterKW(sym, lev: INTEGER; name: ARRAY OF CHAR);
  VAR
    j, k: INTEGER;
    key : Symbol;
 BEGIN
  j := 0; k := 0;
  REPEAT
    INC(k, ORD(name[j])); INC(j)
  UNTIL (j >= LEN(name)) OR (name[j] = 0X);
  k := (k+j) MOD KW;   (*hash function*)
  NEW(key);
  key.symb := sym; key.lev := lev; COPY(name, key.id);
  key.next := keyTab[k]; keyTab[k] := key;
 END EnterKW;


PROCEDURE InitModule;
 BEGIN
  EnterKW(sfc, asslev, "SFC");
  EnterKW(dfc, asslev, "DFC");
  EnterKW(cacr, asslev, "CACR");
  EnterKW(caar, asslev, "CAAR");
  EnterKW(vbr, asslev, "VBR");
  EnterKW(msp, asslev, "MSP");
  EnterKW(isp, asslev, "ISP");
  EnterKW(fmove, asslev, "FMOVE");
  EnterKW(fint, asslev, "FINT");
  EnterKW(fsinh, asslev, "FSINH");
  EnterKW(fintrz, asslev, "FINTRZ");
  EnterKW(fsqrt, asslev, "FSQRT");
  EnterKW(flognp1, asslev, "FLOGNP1");
  EnterKW(fetoxm1, asslev, "FETOXM1");
  EnterKW(ftanh, asslev, "FTANH");
  EnterKW(fatan, asslev, "FATAN");
  EnterKW(fasin, asslev, "FASIN");
  EnterKW(fatanh, asslev, "FATANH");
  EnterKW(fsin, asslev, "FSIN");
  EnterKW(ftan, asslev, "FTAN");
  EnterKW(fetox, asslev, "FETOX");
  EnterKW(ftwotox, asslev, "FTWOTOX");
  EnterKW(ftentox, asslev, "FTENTOX");
  EnterKW(flogn, asslev, "FLOGN");
  EnterKW(flog10, asslev, "FLOG10");
  EnterKW(flog2, asslev, "FLOG2");
  EnterKW(fabs, asslev, "FABS");
  EnterKW(fcosh, asslev, "FCOSH");
  EnterKW(fneg, asslev, "FNEG");
  EnterKW(facos, asslev, "FACOS");
  EnterKW(fcos, asslev, "FCOS");
  EnterKW(fgetexp, asslev, "FGETEXP");
  EnterKW(fgetman, asslev, "FGETMAN");
  EnterKW(fdiv, asslev, "FDIV");
  EnterKW(fmod, asslev, "FMOD");
  EnterKW(fadd, asslev, "FADD");
  EnterKW(fmul, asslev, "FMUL");
  EnterKW(fsgldiv, asslev, "FSGLDIV");
  EnterKW(frem, asslev, "FREM");
  EnterKW(fscale, asslev, "FSCALE");
  EnterKW(fsglmul, asslev, "FSGLMUL");
  EnterKW(fsub, asslev, "FSUB");
  EnterKW(fcmp, asslev, "FCMP");
  EnterKW(ftest, asslev, "FTEST");
  EnterKW(fsincos, asslev, "FSINCOS");
  EnterKW(fmovem, asslev, "FMOVEM");
  EnterKW(fbf, asslev, "FBF");
  EnterKW(fbeq, asslev, "FBEQ");
  EnterKW(fbogt, asslev, "FBOGT");
  EnterKW(fboge, asslev, "FBOGE");
  EnterKW(fbolt, asslev, "FBOLT");
  EnterKW(fbole, asslev, "FBOLE");
  EnterKW(fbogl, asslev, "FBOGL");
  EnterKW(fbor, asslev, "FBOR");
  EnterKW(fbun, asslev, "FBUN");
  EnterKW(fbueq, asslev, "FBUEQ");
  EnterKW(fbugt, asslev, "FBUGT");
  EnterKW(fbuge, asslev, "FBUGE");
  EnterKW(fbult, asslev, "FBULT");
  EnterKW(fbule, asslev, "FBULE");
  EnterKW(fbne, asslev, "FBNE");
  EnterKW(fbt, asslev, "FBT");
  EnterKW(fbsf, asslev, "FBSF");
  EnterKW(fbseq, asslev, "FBSEQ");
  EnterKW(fbgt, asslev, "FBGT");
  EnterKW(fbge, asslev, "FBGE");
  EnterKW(fblt, asslev, "FBLT");
  EnterKW(fble, asslev, "FBLE");
  EnterKW(fbgl, asslev, "FBGL");
  EnterKW(fbgle, asslev, "FBGLE");
  EnterKW(fbngle, asslev, "FBNGLE");
  EnterKW(fbngl, asslev, "FBNGL");
  EnterKW(fbnle, asslev, "FBNLE");
  EnterKW(fbnlt, asslev, "FBNLT");
  EnterKW(fbnge, asslev, "FBNGE");
  EnterKW(fbngt, asslev, "FBNGT");
  EnterKW(fbsneq, asslev, "FBSNEQ");
  EnterKW(fbst, asslev, "FBST");
  EnterKW(fsf, asslev, "FSF");
  EnterKW(fseq, asslev, "FSEQ");
  EnterKW(fsogt, asslev, "FSOGT");
  EnterKW(fsoge, asslev, "FSOGE");
  EnterKW(fsolt, asslev, "FSOLT");
  EnterKW(fsole, asslev, "FSOLE");
  EnterKW(fsogl, asslev, "FSOGL");
  EnterKW(fsor, asslev, "FSOR");
  EnterKW(fsun, asslev, "FSUN");
  EnterKW(fsueq, asslev, "FSUEQ");
  EnterKW(fsugt, asslev, "FSUGT");
  EnterKW(fsuge, asslev, "FSUGE");
  EnterKW(fsult, asslev, "FSULT");
  EnterKW(fsule, asslev, "FSULE");
  EnterKW(fsne, asslev, "FSNE");
  EnterKW(fst, asslev, "FST");
  EnterKW(fssf, asslev, "FSSF");
  EnterKW(fsseq, asslev, "FSSEQ");
  EnterKW(fsgt, asslev, "FSGT");
  EnterKW(fsge, asslev, "FSGE");
  EnterKW(fslt, asslev, "FSLT");
  EnterKW(fsle, asslev, "FSLE");
  EnterKW(fsgl, asslev, "FSGL");
  EnterKW(fsgle, asslev, "FSGLE");
  EnterKW(fsngle, asslev, "FSNGLE");
  EnterKW(fsngl, asslev, "FSNGL");
  EnterKW(fsnle, asslev, "FSNLE");
  EnterKW(fsnlt, asslev, "FSNLT");
  EnterKW(fsnge, asslev, "FSNGE");
  EnterKW(fsngt, asslev, "FSNGT");
  EnterKW(fssneq, asslev, "FSSNEQ");
  EnterKW(fsst, asslev, "FSST");
  EnterKW(base, asslev, "BASE");
  EnterKW(chk2, asslev, "CHK2");
  EnterKW(cmp2, asslev, "CMP2");
  EnterKW(equ, asslev, "EQU");
  EnterKW(charset, asslev, "CHARSET");
  EnterKW(cpu, asslev, "CPU");
  EnterKW(segment, asslev, "SEGMENT");
  EnterKW(code, asslev, "CODE");
  EnterKW(data, asslev, "DATA");
  EnterKW(bss, asslev, "BSS");
  EnterKW(align, asslev, "ALIGN");
  EnterKW(even, asslev, "EVEN");
  EnterKW(macro, asslev, "MACRO");
  EnterKW(endm, asslev, "ENDM");
  EnterKW(irp, asslev, "IRP");
  EnterKW(rept, asslev, "REPT");
  EnterKW(def, asslev, "DEF");
  EnterKW(on, asslev, "ON");
  EnterKW(off, asslev, "OFF");
  EnterKW(include, asslev, "INCLUDE");
  EnterKW(warning, asslev, "WARNING");
  EnterKW(message, asslev, "MESSAGE");
  EnterKW(error, asslev, "ERROR");
  EnterKW(fatal, asslev, "FATAL");
  EnterKW(local, asslev, "LOCAL");
  EnterKW(ds, asslev, "DS");
  EnterKW(dc, asslev, "DC");
  EnterKW(ifc, asslev, "IFC");
  EnterKW(endc, asslev, "ENDC");
  EnterKW(elsifc, asslev, "ELSIFC");
  EnterKW(elsec, asslev, "ELSEC");
  EnterKW(cap, asslev, "CAP");
  EnterKW(upstring, asslev, "UPSTRING");
  EnterKW(supmode, asslev, "SUPMODE");
  EnterKW(hi, asslev, "HI");
  EnterKW(ls, asslev, "LS");
  EnterKW(hs, asslev, "HS");
  EnterKW(hs, asslev, "CC");
  EnterKW(lo, asslev, "LO");
  EnterKW(lo, asslev, "CS");
  EnterKW(ne, asslev, "NE");
  EnterKW(eq, asslev, "EQ");
  EnterKW(vc, asslev, "VC");
  EnterKW(vs, asslev, "VS");
  EnterKW(pl, asslev, "PL");
  EnterKW(mi, asslev, "MI");
  EnterKW(ge, asslev, "GE");
  EnterKW(lt, asslev, "LT");
  EnterKW(gt, asslev, "GT");
  EnterKW(le, asslev, "LE");
  EnterKW(a0+7, asslev, "SP");
  EnterKW(usp, asslev, "USP");
  EnterKW(pc, asslev, "PC");
  EnterKW(sr, asslev, "SR");
  EnterKW(ccr, asslev, "CCR");
  EnterKW(abcd, asslev, "ABCD");
  EnterKW(add, asslev, "ADD");
  EnterKW(adda, asslev, "ADDA");
  EnterKW(addi, asslev, "ADDI");
  EnterKW(addq, asslev, "ADDQ");
  EnterKW(addx, asslev, "ADDX");
  EnterKW(andi, asslev, "ANDI");
  EnterKW(asl, asslev, "ASL");
  EnterKW(asr, asslev, "ASR");
  EnterKW(bra, asslev, "BRA");
  EnterKW(bsr, asslev, "BSR");
  EnterKW(bhi, asslev, "BHI");
  EnterKW(bls, asslev, "BLS");
  EnterKW(bhs, asslev, "BHS");
  EnterKW(bhs, asslev, "BCC");
  EnterKW(blo, asslev, "BLO");
  EnterKW(blo, asslev, "BCS");
  EnterKW(bne, asslev, "BNE");
  EnterKW(beq, asslev, "BEQ");
  EnterKW(bvc, asslev, "BVC");
  EnterKW(bvs, asslev, "BVS");
  EnterKW(bpl, asslev, "BPL");
  EnterKW(bmi, asslev, "BMI");
  EnterKW(bge, asslev, "BGE");
  EnterKW(blt, asslev, "BLT");
  EnterKW(bgt, asslev, "BGT");
  EnterKW(ble, asslev, "BLE");
  EnterKW(bchg, asslev, "BCHG");
  EnterKW(bclr, asslev, "BCLR");
  EnterKW(bset, asslev, "BSET");
  EnterKW(btst, asslev, "BTST");
  EnterKW(chk, asslev, "CHK");
  EnterKW(clr, asslev, "CLR");
  EnterKW(cmp, asslev, "CMP");
  EnterKW(cmpa, asslev, "CMPA");
  EnterKW(cmpi, asslev, "CMPI");
  EnterKW(cmpm, asslev, "CMPM");
  EnterKW(dbt, asslev, "DBT");
  EnterKW(dbf, asslev, "DBRA");
  EnterKW(dbf, asslev, "DBF");
  EnterKW(dbhi, asslev, "DBHI");
  EnterKW(dbls, asslev, "DBLS");
  EnterKW(dbhs, asslev, "DBHS");
  EnterKW(dbhs, asslev, "DBCC");
  EnterKW(dblo, asslev, "DBLO");
  EnterKW(dblo, asslev, "DBCS");
  EnterKW(dbne, asslev, "DBNE");
  EnterKW(dbeq, asslev, "DBEQ");
  EnterKW(dbvc, asslev, "DBVC");
  EnterKW(dbvs, asslev, "DBVS");
  EnterKW(dbpl, asslev, "DBPL");
  EnterKW(dbmi, asslev, "DBMI");
  EnterKW(dbge, asslev, "DBGE");
  EnterKW(dblt, asslev, "DBLT");
  EnterKW(dbgt, asslev, "DBGT");
  EnterKW(dble, asslev, "DBLE");
  EnterKW(divs, asslev, "DIVS");
  EnterKW(divu, asslev, "DIVU");
  EnterKW(eor, asslev, "EOR");
  EnterKW(eori, asslev, "EORI");
  EnterKW(exg, asslev, "EXG");
  EnterKW(ext, asslev, "EXT");
  EnterKW(extb, asslev, "EXTB");
  EnterKW(illegal, asslev, "ILLEGAL");
  EnterKW(jmp, asslev, "JMP");
  EnterKW(jsr, asslev, "JSR");
  EnterKW(lea, asslev, "LEA");
  EnterKW(link, asslev, "LINK");
  EnterKW(lsl, asslev, "LSL");
  EnterKW(lsr, asslev, "LSR");
  EnterKW(move, asslev, "MOVE");
  EnterKW(movea, asslev, "MOVEA");
  EnterKW(movem, asslev, "MOVEM");
  EnterKW(movep, asslev, "MOVEP");
  EnterKW(moveq, asslev, "MOVEQ");
  EnterKW(muls, asslev, "MULS");
  EnterKW(mulu, asslev, "MULU");
  EnterKW(nbcd, asslev, "NBCD");
  EnterKW(neg, asslev, "NEG");
  EnterKW(negx, asslev, "NEGX");
  EnterKW(nop, asslev, "NOP");
  EnterKW(ori, asslev, "ORI");
  EnterKW(pea, asslev, "PEA");
  EnterKW(reset, asslev, "RESET");
  EnterKW(rol, asslev, "ROL");
  EnterKW(ror, asslev, "ROR");
  EnterKW(roxl, asslev, "ROXL");
  EnterKW(roxr, asslev, "ROXR");
  EnterKW(rte, asslev, "RTE");
  EnterKW(rtr, asslev, "RTR");
  EnterKW(rts, asslev, "RTS");
  EnterKW(sbcd, asslev, "SBCD");
  EnterKW(st, asslev, "ST");
  EnterKW(sf, asslev, "SF");
  EnterKW(shi, asslev, "SHI");
  EnterKW(sls, asslev, "SLS");
  EnterKW(shs, asslev, "SHS");
  EnterKW(shs, asslev, "SCC");
  EnterKW(slo, asslev, "SLO");
  EnterKW(slo, asslev, "SCS");
  EnterKW(sne, asslev, "SNE");
  EnterKW(seq, asslev, "SEQ");
  EnterKW(svc, asslev, "SVC");
  EnterKW(svs, asslev, "SVS");
  EnterKW(spl, asslev, "SPL");
  EnterKW(smi, asslev, "SMI");
  EnterKW(sge, asslev, "SGE");
  EnterKW(slt, asslev, "SLT");
  EnterKW(sgt, asslev, "SGT");
  EnterKW(sle, asslev, "SLE");
  EnterKW(stop, asslev, "STOP");
  EnterKW(sub, asslev, "SUB");
  EnterKW(suba, asslev, "SUBA");
  EnterKW(subi, asslev, "SUBI");
  EnterKW(subq, asslev, "SUBQ");
  EnterKW(subx, asslev, "SUBX");
  EnterKW(swap, asslev, "SWAP");
  EnterKW(tas, asslev, "TAS");
  EnterKW(trap, asslev, "TRAP");
  EnterKW(trapv, asslev, "TRAPV");
  EnterKW(tst, asslev, "TST");
  EnterKW(unlk, asslev, "UNLK");
  EnterKW(movec, asslev, "MOVEC");
  EnterKW(rtd, asslev, "RTD");
  EnterKW(divul, asslev, "DIVUL");
  EnterKW(divsl, asslev, "DIVSL");
  EnterKW(mulul, asslev, "MULUL");
  EnterKW(mulsl, asslev, "MULSL");
  EnterKW(s, asslev, 'S');
  EnterKW(d, asslev, 'D');
  EnterKW(b, asslev, 'B');
  EnterKW(w, asslev, 'W');
  EnterKW(l, asslev, 'L');
  EnterKW(td, asslev, 'TD');
  EnterKW(fp0, asslev, "FP0");
  EnterKW(fp0+1, asslev, "FP1");
  EnterKW(fp0+2, asslev, "FP2");
  EnterKW(fp0+3, asslev, "FP3");
  EnterKW(fp0+4, asslev, "FP4");
  EnterKW(fp0+5, asslev, "FP5");
  EnterKW(fp0+6, asslev, "FP6");
  EnterKW(fp0+7, asslev, "FP7");
  EnterKW(a0, asslev, "A0");
  EnterKW(a0+1, asslev, "A1");
  EnterKW(a0+2, asslev, "A2");
  EnterKW(a0+3, asslev, "A3");
  EnterKW(a0+4, asslev, "A4");
  EnterKW(a0+5, asslev, "A5");
  EnterKW(a0+6, asslev, "A6");
  EnterKW(a0+7, asslev, "A7");
  EnterKW(d0, asslev, "D0");
  EnterKW(d0+1, asslev, "D1");
  EnterKW(d0+2, asslev, "D2");
  EnterKW(d0+3, asslev, "D3");
  EnterKW(d0+4, asslev, "D4");
  EnterKW(d0+5, asslev, "D5");
  EnterKW(d0+6, asslev, "D6");
  EnterKW(d0+7, asslev, "D7");
  EnterKW(module, obnlev, "MODULE");
  EnterKW(import, obnlev, "IMPORT");
  EnterKW(assembler, extlev, "ASSEMBLER");
  EnterKW(ior, extlev, "IOR");
  EnterKW(xor, extlev, "XOR");
  EnterKW(type, obnlev, "TYPE");
  EnterKW(in, obnlev, "IN");
  EnterKW(is, obnlev, "IS");
  EnterKW(of, obnlev, "OF");
  EnterKW(nil, obnlev, "NIL");
  EnterKW(var, obnlev, "VAR");
  EnterKW(case, obnlev, "CASE");
  EnterKW(exit, obnlev, "EXIT");
  EnterKW(then, obnlev, "THEN");
  EnterKW(with, obnlev, "WITH");
  EnterKW(array, obnlev, "ARRAY");
  EnterKW(const, obnlev, "CONST");
  EnterKW(for, obnlev, "FOR");
  EnterKW(by, obnlev, "BY");
  EnterKW(until, obnlev, "UNTIL");
  EnterKW(while, obnlev, "WHILE");
  EnterKW(record, obnlev, "RECORD");
  EnterKW(repeat, obnlev, "REPEAT");
  EnterKW(return, obnlev, "RETURN");
  EnterKW(procedure, obnlev, "PROCEDURE");
  EnterKW(to, obnlev, "TO");
  EnterKW(loop, obnlev, "LOOP");
  EnterKW(pointer, obnlev, "POINTER");
  EnterKW(begin, obnlev, "BEGIN");
  EnterKW(elsif, obnlev, "ELSIF");
  EnterKW(if, obnlev, "IF");
  EnterKW(else, obnlev, "ELSE");
  EnterKW(do, obnlev, "DO");
  EnterKW(mod, obnlev, "MOD");
  EnterKW(div, obnlev, "DIV");
  EnterKW(andb, extlev,  "AND");
  EnterKW(andm, asslev, "AND");
  EnterKW(notb, extlev, "NOT");
  EnterKW(notm, asslev, "NOT");
  EnterKW(or, obnlev, "OR");
  EnterKW(orm, asslev, "OR");
  EnterKW(end, obnlev, "END");
 END InitModule;


BEGIN
  InitModule
END OCScan.