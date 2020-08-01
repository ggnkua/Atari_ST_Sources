MODULE ObjFile; (* SJ 7.11.94 *)

(*
 Basic object file administration.
 *)

IMPORT
  S:=SYSTEM, Memory, Strings;



CONST
  (* symbol flags *)
  Bss* = 0; Text* = 1; Data* = 2; Extern* = 3; RegList* = 4;
  Global* = 5; Equate* = 6; Defined* = 7;



TYPE
  ObjHeader = POINTER TO RECORD
    magic   : INTEGER;
    textSize: LONGINT;
    dataSize: LONGINT;
    bssSize : LONGINT;
    symSize : LONGINT;
    key     : LONGINT;
    rsvd    : ARRAY 3 OF INTEGER;
    code    : INTEGER;	(* start of machine code *)
  END;

  TOSSymbolDesc* = RECORD
    name    : ARRAY 8 OF CHAR;
    type    : SHORTINT;
    magic   : SHORTINT;
    value   : LONGINT;
    xname   : ARRAY 14 OF CHAR;
  END;
  TOSSymbol = POINTER TO TOSSymbolDesc;

  RelTab = POINTER TO RECORD
    first   : LONGINT;
    tab     : ARRAY 32000 OF CHAR;
  END;

  ObjFileDesc = RECORD
    header  : ObjHeader;
    symbols : TOSSymbol;
    reltab  : RelTab;
    relocated: BOOLEAN;
  END;
  ObjFile* = POINTER TO ObjFileDesc;

  Symbol* = RECORD
    name-   : ARRAY 24 OF CHAR;
    type-   : SET;
    value-  : LONGINT;
    original: TOSSymbol;
    obj     : ObjFile;
  END;

  SymbolProc* = PROCEDURE (VAR sym: Symbol);
  RelocProc*  = PROCEDURE (VAR value: LONGINT);

  SysData*= POINTER TO RECORD
              dummy     : ARRAY 0BAH OF SHORTINT;
              compDate* : ARRAY 12 OF CHAR;
              compTime* : ARRAY 10 OF CHAR;
              stackSize*: LONGINT
            END;


VAR
  symbolRemoved: BOOLEAN;



PROCEDURE New*(fileAddr: S.PTR) : ObjFile;
(*
 Return a new ObjFile on the file loaded to address fileAddr.
 *)
  VAR
    obj: ObjFile;
 BEGIN
  NEW(obj);
  obj.header := fileAddr;
  obj.symbols := fileAddr + obj.header.textSize + obj.header.dataSize + 1CH;
  obj.reltab := S.VAL( S.PTR, obj.symbols) + obj.header.symSize;
  obj.relocated := FALSE;
  RETURN obj;
 END New;


PROCEDURE (obj: ObjFile) TextAdr*() : LONGINT;
(*
 Return the address of the machine code.
 *)
 BEGIN
  RETURN S.ADR( obj.header.code );
 END TextAdr;


PROCEDURE (obj: ObjFile) TextSize*() : LONGINT;
(*
 Return the size of the machine code of obj.
 *)
 BEGIN
  RETURN obj.header.textSize;
 END TextSize;


PROCEDURE (obj: ObjFile) DataAdr*() : LONGINT;
(*
 Return the address of the data segment.
 *)
 BEGIN
  RETURN obj.TextAdr() + obj.header.textSize
 END DataAdr;


PROCEDURE (obj: ObjFile) DataSize*() : LONGINT;
(*
 Return the size of the data segment of obj.
 *)
 BEGIN
  RETURN obj.header.dataSize;
 END DataSize;


PROCEDURE (obj: ObjFile) BssSize*() : LONGINT;
(*
 Return the size of the bss segment of obj.
 *)
 BEGIN
  RETURN obj.header.bssSize;
 END BssSize;


PROCEDURE (obj: ObjFile) SymAdr*() : LONGINT;
(*
 Return the address of the symbol table of obj.
 *)
 BEGIN
  RETURN S.VAL( LONGINT, obj.symbols);
 END SymAdr;


PROCEDURE (obj: ObjFile) SymSize*() : LONGINT;
(*
 Return the size of the symbol table of obj.
 *)
 BEGIN
  RETURN obj.header.symSize;
 END SymSize;


PROCEDURE (obj: ObjFile) RelocAdr*() : LONGINT;
(*
 Return the address of the relocation table of obj.
 *)
 BEGIN
  RETURN S.VAL( LONGINT, obj.reltab);
 END RelocAdr;


PROCEDURE (obj: ObjFile) RelocSize*() : LONGINT;
(*
 Return the size of the relocation table of obj. This is a time consuming
 search task!
 *)
  VAR
    i: INTEGER;
 BEGIN
  i := 0;
  IF obj.reltab.first # 0 THEN
    WHILE obj.reltab.tab[i] # 0X DO INC(i) END;
    INC(i);
  END;
  RETURN i+4;
 END RelocSize;


PROCEDURE (obj: ObjFile) SymbolsDo*(proc: SymbolProc);
(*
 Call proc with every symbol of obj.
 *)
  VAR
    sym: Symbol;
    tsym, psym: TOSSymbol;
    i : INTEGER;
 BEGIN
  tsym := obj.symbols;
  WHILE tsym.name[0] # 0X DO
    FOR i := 0 TO 7 DO sym.name[i] := tsym.name[i] END;
    sym.name[8] := 0X;
    sym.type := S.VAL( SET, LONG( S.LONG( tsym.type)));
    sym.value := tsym.value;
    sym.original := tsym;
    sym.obj := obj;
    psym := tsym;
    IF tsym.magic = 48H THEN
      FOR i := 0 TO 13 DO sym.name[i+8] := tsym.xname[i] END;
      sym.name[22] := 0X;
      INC(tsym, 28)
    ELSE
      INC(tsym, 14);
    END;
    symbolRemoved := FALSE;
    proc(sym);
    IF symbolRemoved THEN tsym := psym END;
  END;
 END SymbolsDo;


PROCEDURE (obj: ObjFile) RelocDo*(proc: RelocProc);
(*
 Call proc with every value to be relocated of obj.
 *)
  VAR
    relpos: POINTER TO ARRAY 1 OF LONGINT;
    i: INTEGER;
 BEGIN
  IF obj.reltab.first # 0 THEN
    relpos := S.VAL( S.PTR, obj.header) + 1CH + obj.reltab.first;
    proc( relpos[0] );
    i := 0;
    WHILE obj.reltab.tab[i] # 0X DO
      WHILE obj.reltab.tab[i] = 1X DO
        INC( relpos, 254); INC(i);
      END;
      INC( relpos, ORD( obj.reltab.tab[i]) );
      INC(i);
      proc( relpos[0] );
    END;
  END;
 END RelocDo;


PROCEDURE (obj: ObjFile) Dispose*;
(*
 Dispose the memory occupied by the code and the descriptor. Needed as
 long as the garbage collector is not available.
 *)
 BEGIN
  S.DISPOSE(obj.header);
  S.DISPOSE(obj);
 END Dispose;


PROCEDURE (obj: ObjFile) Key*() : LONGINT;
(*
 Answer the key of the object file.
 *)
 BEGIN
  RETURN obj.header.key;
 END Key;


PROCEDURE GetSymbolNo(obj: ObjFile; VAR name: ARRAY OF CHAR;
                      value: LONGINT) : INTEGER;
  VAR
    no: INTEGER;

  PROCEDURE~ GetNo(VAR sym: Symbol);
   BEGIN
    IF sym.value = value THEN RETURN^ no END;
    IF sym.name = name THEN INC(no) END;
   END GetNo;

 BEGIN
  no := 0;
  obj.SymbolsDo(GetNo);
  RETURN 0;
 END GetSymbolNo;


PROCEDURE Replace(old, new: ObjFile; VAR oldsym: Symbol);
  VAR
    oldno, newno: INTEGER;

  PROCEDURE~ DoReplace(VAR sym: Symbol);
    VAR
      oldadr, newadr: S.PTR;
   BEGIN
    IF sym.name = oldsym.name THEN
      IF oldno = newno THEN
        oldadr := old.TextAdr() + oldsym.value;
        newadr := new.TextAdr() + sym.value;
        S.PUT( oldadr, 4EF9H);			(* JMP abs *)
        S.PUT( oldadr+2, newadr);
        RETURN^;
      ELSE
        INC(newno)
      END;
    END;
   END DoReplace;

 BEGIN
  newno := 0;
  oldno := GetSymbolNo(old, oldsym.name, oldsym.value);
  new.SymbolsDo(DoReplace);
 END Replace;


PROCEDURE (obj: ObjFile) ReplaceBy*(new: ObjFile);
(*
 Replace the procedures in obj by those in new. If there are several
 procedures with identical names, the order of appearance is critical.
 *)

  PROCEDURE~ DoReplace(VAR sym: Symbol);
   BEGIN
    IF Text IN sym.type THEN Replace(obj, new, sym) END;
   END DoReplace;

 BEGIN
  obj.SymbolsDo(DoReplace);
 END ReplaceBy;


PROCEDURE (obj: ObjFile) IsRelocated*() : BOOLEAN;
(*
 Answer true if the object file is relocated
 *)
 BEGIN
  RETURN obj.relocated;
 END IsRelocated;


PROCEDURE (obj: ObjFile) SetRelocated*(rel : BOOLEAN);
(*
 Set the relocated flag.
 *)
 BEGIN
  obj.relocated := rel;
 END SetRelocated;


PROCEDURE (VAR sym: Symbol) SetValue*(value: LONGINT);
(*
 Set the value of a symbol.
 *)
 BEGIN
  sym.original.value := value;
 END SetValue;


PROCEDURE (VAR sym: Symbol) Remove*;
(*
 Remove a symbol from the symbol table.
 *)
  VAR
    size: LONGINT;
    tsym: TOSSymbol;
 BEGIN
  tsym := sym.original;
  IF tsym.magic = 48H THEN size := 28 ELSE size := 14 END(*IF*);
  Memory.Copy( S.VAL(LONGINT,tsym) + size, S.VAL(LONGINT,tsym),
      S.VAL( LONGINT, sym.obj.reltab) - S.VAL( LONGINT, tsym) - size);
  DEC( sym.obj.header.symSize, size);
  symbolRemoved := TRUE;
 END Remove;


PROCEDURE (VAR sym: Symbol) RemoveXName*;
(*
 Remove the name extension if sym has one. With other words, make it a
 standard sized symbol if it is in GST format.
 *)
 BEGIN
  IF sym.original.magic = 48H THEN
    INC(sym.original, 14);
    sym.original.magic := 0;
    sym.Remove;
    DEC(sym.original, 14);
    sym.original.magic := 0;
  END;
 END RemoveXName;


PROCEDURE (VAR tsym: TOSSymbolDesc) Fill*(VAR name : ARRAY OF CHAR;
                                          flags: SET; value : LONGINT;
                                          extended: BOOLEAN;
                                          VAR size: LONGINT);
(*
 Fill a TOS symbol with the parameters. IF extended is true and name
 is longer than 8 characters, the extended GST format is used. The size
 of the symbol is returned in size.
 *)
 BEGIN
  S.MOVE( S.ADR( name), S.ADR( tsym.name), 8);
  tsym.value := value;
  IF Strings.Length(name) > 8 THEN
    Strings.Excerpt( 8, 16, name, tsym.xname); tsym.magic := 48H;
    size := 28;
  ELSE
    tsym.magic := 0;
    size := 14;
  END(*IF*);
  tsym.type := SHORT(SHORT( S.VAL(LONGINT, flags) ));
 END Fill;


END ObjFile.