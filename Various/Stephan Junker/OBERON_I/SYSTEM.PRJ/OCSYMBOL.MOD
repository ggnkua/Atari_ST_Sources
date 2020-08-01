MODULE OCSymbol; (* SJ 24.9.94 *)


IMPORT
  S:=SYSTEM, Err:=OCErr, Scan:=OCScan, Strings, IO;



CONST
  (* symbol forms *)
  Def* = 0;  (* a default symbol caused by an undefined error *)
  Var* = 1;  (* a variable *)
  Fld* = 2;  (* a record field *)
  Typ* = 3;  (* a type *)
  LProc* = 4;  (* local procedure *)
  SProc* = 6;  (* standard procedure *)
  CProc* = 7;  (* system procedure *)
  IProc* = 8;  (* interrupt procedure *)
  Mod* = 9;  (* module *)
  Con* = 10;  (* a constant value *)
  Tbp* = 11;  (* a type bound procedure *)
  Ind* = 12;  (* indirect variable *)
  Cpy* = 13;  (* a call by value of a dynamic array *)
  Head* = 14;  (* symbol table header *)
  Sep* = 15;  (* separator for parameter lists *)
  Label* = 16;  (* a label *)
  AProc* = 17;  (* special procedure for assignments only *)

  (*structure forms*)
  Undef* = 0;  (* unknown, after error possible *)
  Byte* = 1;  (* SYSTEM.BYTE *)
  Bool* = 2;  (* BOOLEAN *)
  Char* = 3;  (* CHAR *)
  SInt* = 4;  (* SHORTINT *)
  Int* = 5;  (* INTEGER *)
  LInt* = 6;  (* LONGINT *)
  Real* = 7;  (* REAL *)
  LReal* = 8;  (* LONGREAL *)
  Set* = 9;  (* SET *)
  String* = 10;  (* " " or ' ' *)
  NilTyp* = 11;  (* NIL *)
  NoTyp* = 12;  (* for example procedure return type *)
  AnyPtr* = 13;  (* SYSTEM.PTR *)
  Pointer* = 14; (* POINTER TO derefTyp *)
  ProcTyp* = 15; (* PROCEDURE pars : rettyp *)
  Array* = 16;  (* ARRAY n OF elemTyp *)
  DynArr* = 17;  (* ARRAY OF elemTyp *)
  OpenArr* = 18; (* (POINTER TO) ARRAY OF elemTyp *)
  Record* = 19;  (* RECORD(baseTyp) fields *)
  ProcStr* = 20; (* a procedure access *)
  TbpStr* = 21;  (* a tbp access *)

  (* standard procedures *)
  Halt* =    0;  (* proper procedures *)
  New* =     1;
  SNew* =    2;
  Inc* =     3;
  Dec* =     4;
  Incl* =    5;
  Excl* =    6;
  Copy* =    7;
  Dispose* = 8;
  Get* =     9;
  Getreg* = 10;
  Inline* = 11;
  Move* =   12;
  Put* =    13;
  Putreg* = 14;
  Void* =   15;
  Assert* = 16;

  Abs* =    20;  (* function procedures *)
  Cap* =    21;
  Ord* =    22;
  Entier* = 23;
  Size* =   24;
  Odd* =    25;
  Min* =    26;
  Max* =    27;
  Chr* =    28;
  Short* =  29;
  Long* =   30;
  Len* =    31;
  Ash* =    32;
  Trunc* =  33;
  Adr* =    34;
  Anl* =    35;
  Bit* =    36;
  Cc* =     37;
  Lsh* =    38;
  ULong* =  39;
  Ntl* =    40;
  Orl* =    41;
  Rot* =    42;
  Val* =    43;
  Xol* =    44;
  Swap* =   45;
  Exg* =    46;

  (* symbol marks *)
  NoExport* = 0; ReadOnly* = 1; Export* = 2;

  (* VarSym reg (0..31 = reg no) *)
  NoReg* = -1;

  (* CPU dependant constants *)
  PtrSize* = 4; ArrLenSize* = 4;

  (* TD offsets *)
  TDLength* = 0; TDType* = 4; TDName* = 6; TDBaseTyps* = 46;
  TDTBPs* = 86;

  (* value codes *)
  (* MMMMMMMN NNNNNNNN DDDDDDDD DDDDDDDD (Module, Number, Displacement) *)
  (* 0NNNNNNN NNNNNNNN DDDDDDDD DDDDDDDD (Number, Displacement) *)
  FirstNonExportLabel* = 512;

  (* error codes *)
  doublesym = 124; intovfl = 162; unknown = 127;

  BlkLen = 3200;

  NumTypes = 100; NumSymbols = 50;


(* record field usage:

Symbol
form syms lev typ a0 a1
--------------------------------------------------------------------------
Def
Var  level typ offset reg
Fld   typ offset
Typ   typ
LProc pars level rettyp offset pno
SProc     pno
CProc pars  rettyp trapno pno
Mod syms modno  ^fname key
Con   typ offset expr
Tbp  pno rettyp offset  tdoff
Ind  level typ offset
Cpy  level typ offset
Head upper
Sep
Label    offset labexpr
--------------------------------------------------------------------------

Struct
form base syms n a0
--------------------------------------------------------------------------
Undef
Byte
Bool
Char
SInt
Int
LInt
Real
LReal
Set
String
NilTyp
NoTyp
AnyPtr
Pointer ptrto
ProcTyp rettyp pars psize
Array elem  numElem
DynArr elem
OpenArr elem
Record base fields extno tdpos
ProcStr
TbpStr
--------------------------------------------------------------------------

*)

TYPE
  Struct*   = POINTER TO StructD; (* used for simple types *)

  Symbol*   = POINTER TO SymbolD; (* also used for Sep and Def *)
  SymbolD*  = RECORD
                next* : Symbol;  (* linear list *)
                form* : INTEGER; (* see const *)
                ref*  : INTEGER; (* needed for symbol IO *)
                name* : ARRAY 30 OF CHAR;(* identifier *)
                forw* : BOOLEAN; (* true = forward *)
                lev*  : INTEGER; (* procedure / module level *)
                mark* : INTEGER; (* export mark *)
                typ*  : Struct;  (* the type *)
                syms* : Symbol;  (* its symbol list *)
                a0*   : LONGINT;
                a1*   : LONGINT;
                changed* : BOOLEAN; (* its value changed *)
                first*, last* : INTEGER;(* accesses (statements) *)
                priority* : INTEGER; (* register priority *)
              END(*RECORD*);

  StructD*  = RECORD
                form* : INTEGER; (* see const *)
                ref*  : INTEGER; (* needed for symbol IO *)
                base* : Struct;
                syms* : Symbol;
                n*    : LONGINT;
                size* : LONGINT;
                mark* : INTEGER;
                a0*   : LONGINT;
                name* : Strings.ptr;
              END(*RECORD*);

  SymCompProc = PROCEDURE (s1, s2: Symbol) : BOOLEAN;



VAR
  symbols*, global-, system-, self*: Symbol;
  level*  : INTEGER;
  undftyp*, stringtyp*, notyp*, niltyp*,
  bytetyp*, booltyp*, chartyp*, sinttyp*,
  inttyp*, linttyp*, realtyp*, lrltyp*,
  settyp*, ptrtyp*, procstr*, tbpstr* : Struct;

  mem : ARRAY 1000 OF POINTER TO ARRAY BlkLen OF CHAR;
  memx, space: INTEGER;
  nextAddr: S.PTR;

  types1, types2: ARRAY NumTypes OF Struct;
  typesEqual    : ARRAY NumTypes OF BOOLEAN;
  typx, numtyps : INTEGER;
  symbols1, symbols2: ARRAY NumSymbols OF Symbol;
  symbolsEqual  : ARRAY NumSymbols OF BOOLEAN;
  symx, numsyms : INTEGER;

  freeSyms: Symbol;
  freeStrs: Struct;



PROCEDURE Alloc*(size: INTEGER; VAR ptr: S.PTR);
 BEGIN
  IF ODD(size) THEN INC(size) END;
  IF space < size THEN
    INC(memx);
    IF mem[memx] = NIL THEN
      S.NEW(mem[memx], BlkLen);
    END;
    space := BlkLen;
    nextAddr := mem[memx];
  END;
  ptr := nextAddr;
  INC(nextAddr, size);
  DEC(space, size);
 END Alloc;


PROCEDURE NewSym*(form: INTEGER; VAR symbol: Symbol);
  VAR
    sym: Symbol;
    size: INTEGER;
 BEGIN
  IF freeSyms = NIL THEN
    Alloc( SIZE(SymbolD), sym);
  ELSE
    sym := freeSyms; freeSyms := freeSyms.next;
  END;
  sym.form := form;
  IF form IN {Head, Sep, Def} THEN
    sym.name := ""
  ELSE
    COPY(Scan.name, sym.name);
  END;
  sym.ref := 0; sym.forw := FALSE;
  sym.mark := NoExport; sym.lev := level;
  sym.typ := notyp; sym.syms := NIL;
  symbol := sym;
 END NewSym;


PROCEDURE NewSymNamed*(form: INTEGER; name: ARRAY OF CHAR; VAR symbol: Symbol);
  VAR
    str: ARRAY 40 OF CHAR;
 BEGIN
  COPY(Scan.name, str); COPY(name, Scan.name);
  NewSym(form, symbol);
  COPY(str, Scan.name);
 END NewSymNamed;


PROCEDURE DisposeSym*(sym: Symbol);
 VAR
   i: INTEGER;
 BEGIN
  sym.next := freeSyms; freeSyms := sym;
  i := 0;
  WHILE i < numsyms DO
    IF (symbols1[i] = sym) OR (symbols2[i] = sym) THEN
      DEC(numsyms);
      IF symx > numsyms THEN symx := numsyms END;
      symbols1[i] := symbols1[numsyms];
      symbols2[i] := symbols2[numsyms];
      symbolsEqual[i] := symbolsEqual[numsyms];
    ELSE
      INC(i);
    END;
  END;
 END DisposeSym;


PROCEDURE NewStr*(form: INTEGER; VAR str: Struct);
  VAR
    typ: Struct;
    i: INTEGER;
 BEGIN
  IF freeStrs = NIL THEN
    Alloc( SIZE(StructD), typ);
  ELSE
    typ := freeStrs; freeStrs := freeStrs.base;
  END;
  typ.form := form; typ.ref := 0; typ.mark := NoExport;
  str := typ; typ.size := 0; typ.a0 := -1;
  typ.name := NIL;
 END NewStr;


PROCEDURE DisposeStr*(str: Struct);
 VAR
   i: INTEGER;
 BEGIN
  str.base := freeStrs; freeStrs := str;
  i := 0;
  WHILE i < numtyps DO
    IF (types1[i] = str) OR (types2[i] = str) THEN
      DEC(numtyps);
      IF typx > numtyps THEN typx := numtyps END;
      types1[i] := types1[numtyps];
      types2[i] := types2[numtyps];
      typesEqual[i] := typesEqual[numtyps];
    ELSE
      INC(i);
    END;
  END;
 END DisposeStr;


PROCEDURE NewList*;
(*
 create a new symbol list with the current list as upper list. level is
 incremented.
 *)
  VAR
    head: Symbol;
 BEGIN
  INC(level);
  NewSym(Head, head); head.next := NIL; head.syms := symbols;
  symbols := head;
 END NewList;


PROCEDURE OldList*;
(*
 reset current symbol list to upper list. level is decremented.
 *)
 BEGIN
  symbols := symbols.syms; DEC(level);
 END OldList;


PROCEDURE Search*(VAR fnd: Symbol) : BOOLEAN;
(*
 Searches the current symbol list and all upper lists for the symbol with
 name Scan.name. If it is found, its symbol descriptor is returned in fnd
 and the result is true, else it is false.
 *)
  VAR
    head, sym : Symbol;
 BEGIN
  head := symbols;
  REPEAT
    sym := head.next;
    WHILE sym # NIL DO
      IF sym.name = Scan.name THEN
        fnd := sym; RETURN TRUE;
      END(*IF*);
      sym := sym.next;
    END(*WHILE*);
    (* the following prevents endless loop. But who done it? *)
    IF head = head.syms THEN head.syms := NIL END;
    head := head.syms;
  UNTIL head = NIL;
  RETURN FALSE;
 END Search;


PROCEDURE Remove*(symbol: Symbol);
(*
 Searches the current symbol list and all upper lists for the symbol with
 name Scan.name. If it is found, its symbol descriptor is returned in fnd
 and the result is true, else it is false.
 *)
  VAR
    sym, psym : Symbol;
 BEGIN
  psym := symbols; sym := psym.next;
  WHILE sym # NIL DO
    IF sym = symbol THEN
      psym.next := sym.next; RETURN;
    END(*IF*);
    psym := sym; sym := sym.next;
  END(*WHILE*);
  HALT(99);
 END Remove;


PROCEDURE InsertIn*(head: Symbol; VAR symbol : Symbol);
(*
 Insert symbol in the symbol list head. If it is already there and forward
 defined, replace symbol with the found symbol. If it is not forward,
 output an error message.
 *)
  VAR
    sym, psym, lastMod : Symbol;
 BEGIN
  IF head # NIL THEN
    psym := head; sym := psym.next;
    WHILE sym # NIL DO
      IF sym.form IN {Sep, Mod} THEN lastMod := sym END;
      IF sym.name = symbol.name THEN (* found *)
        IF sym.forw & (sym.form = symbol.form) THEN
          symbol := sym; sym.forw := FALSE;
        ELSIF sym.form # Def THEN
          Err.Mark(doublesym)
        ELSE
          psym.next := symbol; symbol.next := sym.next;
        END(*IF*);
        RETURN;
      END(*IF*);
      psym := sym; sym := sym.next;
    END(*WHILE*);
    IF symbol.form = Mod THEN
      symbol.next := lastMod.next; lastMod.next := symbol
    ELSE
      psym.next := symbol; symbol.next := NIL;
    END;
  END;
 END InsertIn;


PROCEDURE Insert*(VAR symbol : Symbol);
(*
 Insert sym in the current symbol list. If it is already there and forward
 defined, replace symbol with the found symbol. If it is not forward,
 output an error message.
 *)
 BEGIN
  InsertIn(symbols, symbol);
 END Insert;


PROCEDURE Find*(VAR fnd: Symbol);
(*
 Try to find the symbol with name Scan.name in the current symbol list and
 all upper lists. If it is there, return its descriptor in fnd. If it is
 not found, mark an error, produce a default forward symbol and return it.
 *)
 BEGIN
  IF NOT Search(fnd) THEN
    Err.Mark(unknown);
    NewSym(Def, fnd); fnd.forw := TRUE; Insert(fnd);
    fnd.typ := undftyp;
  END(*IF*);
 END Find;


PROCEDURE SearchInList*(head: Symbol; VAR fnd: Symbol) : BOOLEAN;
(*
 Try to find the symbol with name Scan.name in the symbol list starting
 with head. If it is there, return its descriptor in fnd. If it is not
 found, return false.
 *)
  VAR
    sym : Symbol;
 BEGIN
  IF head # NIL THEN
    sym := head.next;
    WHILE sym # NIL DO
      IF sym.name = Scan.name THEN (* found *)
        fnd := sym; RETURN TRUE;
      END(*IF*);
      sym := sym.next;
    END(*WHILE*);
  END;
  RETURN FALSE;
 END SearchInList;


PROCEDURE FindInList*(head: Symbol; VAR fnd: Symbol);
(*
 Try to find the symbol with name Scan.name in the symbol list starting
 with head. If it is there, return its descriptor in fnd. If it is not
 found, mark an error, produce a default forward symbol and return it.
 *)
  VAR
    sym: Symbol;
 BEGIN
  IF NOT SearchInList(head, fnd) THEN
    Err.Mark(unknown);
    NewSym(Def, sym); sym.forw := TRUE; InsertIn(head, sym);
    sym.typ := undftyp;
    fnd := sym;
  END;
 END FindInList;


PROCEDURE SearchModule*(VAR name: ARRAY OF CHAR; VAR mod: Symbol) : BOOLEAN;
(*
 Search the module with that file name in the global symbols.
 *)
  VAR
    sp: Strings.ptr;
    s : Symbol;
 BEGIN
  s := global;
  WHILE s # NIL DO
    IF s.form = Mod THEN
      sp := S.VAL( Strings.ptr, s.a0);
      IF sp^ = name THEN mod := s; RETURN TRUE END;
    END;
    s := s.next;
  END;
  RETURN FALSE
 END SearchModule;


PROCEDURE^ SameType*(t1, t2: Struct) : BOOLEAN;
PROCEDURE^ SameSyms*(s1, s2: Symbol) : BOOLEAN;


PROCEDURE IsReservedTbp(sym: Symbol) : BOOLEAN;
 BEGIN
  RETURN (sym.form = Tbp) & (sym.name = "");
 END IsReservedTbp;


PROCEDURE CompareFlds(sym1, sym2: Symbol) : BOOLEAN;
  VAR
    s1, s2: Symbol;
 BEGIN
  s1 := sym1; s2 := sym2;
  WHILE (s1 # NIL) & (s1.form # Sep) DO
    IF s2 = NIL THEN
      IF ~IsReservedTbp(s1) THEN RETURN FALSE END;
    ELSIF (s1.form # s2.form) THEN RETURN FALSE
    ELSE s2 := s2.next;
    END;
    s1 := s1.next;
  END;
  WHILE (s2 # NIL) & (s2.form # Sep) DO
    IF ~IsReservedTbp(s2) THEN RETURN FALSE END;
    s2 := s2.next;
  END;

  (* same number of symbols *)
  s1 := sym1;
  WHILE (s1 # NIL) & (s1.form # Sep) DO
    IF (s1.name # "") THEN
      s2 := sym2;
      LOOP
        IF s1.name = s2.name THEN
          IF s1.form = Tbp THEN
            IF ~SameSyms(s1.syms.next.next, s2.syms.next.next)
                OR ~SameType(s1.typ, s2.typ) THEN
              RETURN FALSE;
            END;
          ELSIF s1.form IN {Fld, Var, Ind, Cpy} THEN
            IF ~SameType(s1.typ, s2.typ) THEN RETURN FALSE END;
          ELSE
            RETURN FALSE;
          END;
          EXIT
        END;
        s2 := s2.next;
        IF (s2 = NIL) OR (s2.form = Sep) THEN RETURN FALSE END;
      END;
    END;
    s1 := s1.next;
  END;
  RETURN TRUE
 END CompareFlds;


PROCEDURE CompareSyms(s1, s2: Symbol) : BOOLEAN;
 BEGIN
  WHILE (s1 # NIL) & (s1.form # Sep) DO
    IF (s2 = NIL) OR (s1.form # s2.form) THEN RETURN FALSE END;
    IF s1.form = Tbp THEN
      IF (s1.name # "") & (s2.name # "") THEN
        IF ~SameSyms(s1.syms.next.next, s2.syms.next.next)
            OR ~SameType(s1.typ, s2.typ) THEN
          RETURN FALSE;
        END;
      ELSIF s1.name # s2.name THEN
        RETURN FALSE
      END;
    ELSIF s1.form IN {Fld, Var, Ind, Cpy} THEN
      IF ~SameType(s1.typ, s2.typ) THEN RETURN FALSE END;
    ELSE
      RETURN FALSE;
    END;
    s1 := s1.next; s2 := s2.next;
  END;
  RETURN (s2 = NIL) OR (s2.form = Sep);
 END CompareSyms;


PROCEDURE CheckSyms(s1, s2: Symbol; compare: SymCompProc) : BOOLEAN;
  VAR
    i, inx: INTEGER;
 BEGIN
  IF s1 = s2 THEN RETURN TRUE END;
  i := 0;
  WHILE i < numsyms DO
    IF ((symbols1[i] = s1) OR (symbols1[i] = s2))
        & ((symbols2[i] = s1) OR (symbols2[i] = s2)) THEN
      RETURN symbolsEqual[i];
    END;
    INC(i);
  END;
  inx := symx; INC(symx);
  IF symx > numsyms THEN numsyms := symx END;
  IF symx = NumSymbols THEN symx := 0 END;
  symbols1[inx] := s1; symbols2[inx] := s2;
  symbolsEqual[inx] := TRUE;
  symbolsEqual[inx] := compare(s1, s2);
  RETURN symbolsEqual[inx];
 END CheckSyms;


PROCEDURE SameFlds(s1, s2: Symbol) : BOOLEAN;
 BEGIN
  RETURN CheckSyms(s1, s2, CompareFlds);
 END SameFlds;


PROCEDURE CompareType(t1, t2: Struct) : BOOLEAN;
 BEGIN
  IF t1.form = t2.form THEN
    CASE t1.form OF
      Undef..AnyPtr:
        RETURN TRUE;
    | Pointer, DynArr, OpenArr:
        RETURN SameType( t1.base, t2.base);
    | Record:
        RETURN SameFlds(t1.syms.next, t2.syms.next) & SameType( t1.base, t2.base);
    | ProcTyp:
        RETURN SameSyms(t1.syms.next, t2.syms.next) & SameType( t1.base, t2.base);
    | Array:
        RETURN (t1.n = t2.n) & SameType( t1.base, t2.base);
    ELSE
    END;
  END;
  RETURN FALSE;
 END CompareType;


PROCEDURE SameSyms*(s1, s2: Symbol) : BOOLEAN;
 BEGIN
  RETURN CheckSyms(s1, s2, CompareSyms);
 END SameSyms;


PROCEDURE SameType*(t1, t2: Struct) : BOOLEAN;
  VAR
    i, inx: INTEGER;
 BEGIN
  IF (t1 = t2) THEN RETURN TRUE END;
  IF (t1 = NIL) OR (t2 = NIL) THEN RETURN FALSE END;
  i := 0;
  WHILE i < numtyps DO
    IF ((types1[i] = t1) OR (types1[i] = t2))
        & ((types2[i] = t1) OR (types2[i] = t2)) THEN
      RETURN typesEqual[i];
    END;
    INC(i);
  END;
  inx := typx; INC(typx);
  IF typx > numtyps THEN numtyps := typx END;
  IF typx = NumTypes THEN typx := 0 END;
  types1[inx] := t1; types2[inx] := t2;
  typesEqual[inx] := TRUE;
  typesEqual[inx] := CompareType(t1, t2);
  RETURN typesEqual[inx];
 END SameType;


PROCEDURE EnterConst(name: ARRAY OF CHAR; value: INTEGER);
  VAR
    obj: Symbol;
 BEGIN
  NewSymNamed(Con, name, obj);
  Insert(obj); obj.typ := booltyp;
  obj.a0 := value;
 END EnterConst;


PROCEDURE EnterProc(name: ARRAY OF CHAR; num: INTEGER);
  VAR
    sym: Symbol;
 BEGIN
  NewSymNamed(SProc, name, sym);
  sym.a1 := num;
  Insert(sym);
 END EnterProc;


PROCEDURE EnterTyp(name: ARRAY OF CHAR; size: LONGINT;
                   id : INTEGER; VAR typ: Struct);
  VAR
    obj: Symbol;
 BEGIN
  NewSymNamed(Typ, name, obj);
  Insert(obj);
  NewStr(id, typ); obj.typ := typ; typ.size := size;
 END EnterTyp;


PROCEDURE ProduceStdSym;
  VAR
    sep : Symbol;
 BEGIN
  DEC(level); NewList;
  global := symbols;
  NewStr(Undef, undftyp);
  NewStr(Undef, undftyp.base); undftyp.base.base := NIL;
  NewStr(NoTyp, notyp);
  NewStr(String, stringtyp);
  NewStr(NilTyp, niltyp); niltyp.size := 4;
  NewStr(ProcStr, procstr); procstr.size := 4;
  NewStr(TbpStr, tbpstr); tbpstr.size := 4;
  EnterTyp("CHAR", 1, Char, chartyp);
  EnterTyp("SET", 4, Set, settyp);
  EnterTyp("REAL", 4, Real, realtyp);
  EnterTyp("INTEGER", 2, Int, inttyp);
  EnterTyp("LONGINT",  4, LInt, linttyp);
  EnterTyp("LONGREAL", 8, LReal, lrltyp);
  EnterTyp("SHORTINT", 1, SInt, sinttyp);
  EnterTyp("BOOLEAN", 1, Bool, booltyp);
  EnterProc("INC", Inc);
  EnterProc("DEC", Dec);
  EnterConst("FALSE", 0);
  EnterConst("TRUE",  1);
  EnterProc("HALT", Halt);
  EnterProc("NEW", New);
  EnterProc("ABS", Abs);
  EnterProc("CAP", Cap);
  EnterProc("ORD", Ord);
  EnterProc("ENTIER", Entier);
  EnterProc("SIZE", Size);
  EnterProc("ODD", Odd);
  EnterProc("MIN", Min);
  EnterProc("MAX", Max);
  EnterProc("CHR", Chr);
  EnterProc("SHORT", Short);
  EnterProc("LONG", Long);
  EnterProc("INCL", Incl);
  EnterProc("EXCL", Excl);
  EnterProc("LEN", Len);
  EnterProc("ASH", Ash);
  EnterProc("COPY", Copy);
  EnterProc("ASSERT", Assert);

  (*initialization of module SYSTEM*)
  level := -128;
  NewSymNamed(Mod, "SYSTEM", system);
  NewList; system.syms := symbols;
  EnterProc("LSH", Lsh);
  EnterProc("ROT", Rot);
  EnterProc("ADR",  Adr);
  EnterProc("GET", Get);
  EnterProc("PUT", Put);
  EnterProc("BIT", Bit);
  EnterProc("VAL", Val);
  EnterProc("NEW", SNew);
  EnterProc("MOVE",Move);
  EnterProc("CC",  Cc);
  EnterProc("GETREG",Getreg);
  EnterProc("PUTREG",Putreg);
  EnterProc("INLINE",Inline);
  EnterProc("ANL",Anl);
  EnterProc("ORL",Orl);
  EnterProc("XOL",Xol);
  EnterProc("NTL",Ntl);
  EnterProc("LONG",ULong);
  EnterProc("DISPOSE",Dispose);
  EnterProc("TRUNC", Trunc);
  EnterProc("VOID", Void);
  EnterProc("SWAP", Swap);
  EnterProc("EXG", Exg);
  EnterTyp("BYTE", 1, Byte, bytetyp);
  EnterTyp("PTR", PtrSize, AnyPtr, ptrtyp);
  OldList;
  level := 0;

  NewSym(Sep, sep); Insert(sep);(* mark end of standard symbols *)
 END ProduceStdSym;


PROCEDURE Init*;
 BEGIN
  level := 0;
  memx := 0; space := 0;
  S.NEW(mem[0], BlkLen); nextAddr := mem[0];
  typx := 0; numtyps := 0;
  symx := 0; numsyms := 0;
  ProduceStdSym;
 END Init;


PROCEDURE Exit*;
  VAR
    sym: Symbol;
    i: INTEGER;
 BEGIN
(*  sym := global;  not done because memory is disposed!
  WHILE sym.form # Sep DO
    sym := sym.next;
  END(*WHILE*);
  sym.next := NIL; (* cut symbols of compilation *)
*)
  symbols := NIL; self := NIL;

  FOR i := 0 TO memx DO
    IF mem[i] # NIL THEN S.DISPOSE(mem[i]) END;
    mem[i] := NIL;
  END;

  FOR i := 0 TO NumTypes-1 DO
    types1[i] := NIL; types2[i] := NIL;
  END;

  FOR i := 0 TO NumSymbols-1 DO
    symbols1[i] := NIL; symbols2[i] := NIL;
  END;

  freeSyms := NIL; freeStrs := NIL;
 END Exit;


BEGIN
(*  ProduceStdSym; Memory is disposed! *)
END OCSymbol.