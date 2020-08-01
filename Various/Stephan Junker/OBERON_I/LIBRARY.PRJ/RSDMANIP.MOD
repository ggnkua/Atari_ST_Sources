MODULE RSDManipulation; (* SJ 19.2.95 *)

(*
 Manipulates the structures of Robert Federle's resident symbol driver.
 *)


IMPORT
  S:=SYSTEM, ObjFile, Sys, RSD, Storage, Strings, MinMax, QSort, Task;




PROCEDURE NewHeader*(symbolCount, symbolDataSize: INTEGER) : RSD.SymbolHeaderPtr;
(*
 Always use this procedure to allocate a new SymbolHeaderPtr because it may
 not be collected since it is not stored in global pointers. The field
 symbolCount is set and the open array pointers allocated correctly.
 symbolDataSize must hold the size of all symbols in the array. The new
 header is not added to RSD's headers.
 *)
  VAR
    ptr: S.PTR;
    header: RSD.SymbolHeaderPtr;
 BEGIN
  S.NEW(ptr, SIZE( RSD.SymbolHeader) + 6);
  header := ptr + 6;
  header.unknown := 4;
  header.symbolCount := symbolCount;
  S.NEW( header.symbolValues, symbolCount*2);
  S.NEW( header.symbolNames, symbolCount*2);
  S.NEW( header.symbolData, symbolDataSize);
  header.next := NIL;
  RETURN header;
 END NewHeader;


PROCEDURE AddHeader*(header: RSD.SymbolHeaderPtr);
(*
 Adds header to RSD's headers. header must have been returned by NewHeader
 because of hidden values.
 *)
  VAR
    ptr, first: S.PTR;
    cookie: RSD.SymbolCookiePtr;
    h: RSD.SymbolHeaderPtr;
 BEGIN
  cookie := RSD.GetCookie();
  IF cookie # NIL THEN
    h := cookie.first;
    IF h = NIL THEN
      cookie.first := header
    ELSE
      WHILE h.next # NIL DO h := h.next END;
      h.next := header;
    END;
    ptr := S.VAL( S.PTR, header) - 6;
    S.GET( header.symbolData, first);
    S.PUT( ptr, first);
    S.PUT( ptr+4, S.VAL( INTEGER, 1) );
  END;
 END AddHeader;


PROCEDURE DisposeHeader*(header: RSD.SymbolHeaderPtr);
(*
 Use this procedure to dispose a SymbolHeaderPtr. header must have been
 returned by NewHeader.
 *)
 BEGIN
  S.DISPOSE(header.symbolValues);
  S.DISPOSE(header.symbolNames);
  S.DISPOSE(header.symbolData);
  S.DISPOSE( S.VAL( S.PTR, header) - S.VAL( S.PTR, 6));
 END DisposeHeader;


(*$-y *)

PROCEDURE StringLength(str : ARRAY OF CHAR) : INTEGER;
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE str[i] # 0X DO INC(i) END(*WHILE*);
  RETURN i
 END StringLength;


PROCEDURE RemoveTable*(name: ARRAY OF CHAR);
(*
 Remove the symbols of the module named name in the RSD's structures.
 *)
  VAR
    cookie: RSD.SymbolCookiePtr;
    table, prevTab:  RSD.SymbolHeaderPtr;
    d: BOOLEAN;
 BEGIN
  cookie := RSD.GetCookie();
  IF cookie # NIL THEN
    table := cookie.first; prevTab := NIL;
    WHILE (table # NIL) & (table.programName # name) DO
      prevTab := table; table := table.next
    END;
    IF table = NIL THEN RETURN END;
    IF prevTab = NIL THEN
      cookie.first := table.next;
    ELSE
      prevTab.next := table.next
    END;
    DisposeHeader(table);
  END;
 END RemoveTable;


PROCEDURE AddTable*(name: ARRAY OF CHAR; obj: ObjFile; bss: S.PTR);
(*
 Store the symbols of obj in the RSD's structures under the module name
 name. bss holds the start address of the bss segment.
 *)
  VAR
    header: RSD.SymbolHeaderPtr;
    f1, f2, l1, l2: S.PTR;
    symbolCount, symbolDataSize, modNameLen: INTEGER;

  PROCEDURE ~Count(VAR sym: ObjFile.Symbol);
   BEGIN
    IF sym.type * {ObjFile.Text, ObjFile.Data, ObjFile.Bss} # {} THEN
      INC(symbolCount);
      INC(symbolDataSize, modNameLen + StringLength( sym.name) );
      INC(symbolDataSize, symbolDataSize MOD 2); (* even *)
    END;
   END Count;

  PROCEDURE ~EnterData(VAR sym: ObjFile.Symbol);
    VAR
      ptr, adr: S.PTR;
      sp: Strings.ptr;
   BEGIN
    IF sym.type * {ObjFile.Text, ObjFile.Data, ObjFile.Bss} # {} THEN
      IF ObjFile.Text IN sym.type THEN
        adr := obj.TextAdr() + sym.value;
      ELSIF ObjFile.Data IN sym.type THEN
        adr := obj.DataAdr() + sym.value;
      ELSE
        adr := bss + sym.value;
      END;
      ptr := S.ADR( header.symbolData[symbolDataSize]);
      S.PUT( ptr, adr);
      S.PUT( ptr+4, SHORT( SHORT( S.VAL( LONGINT, sym.type) * 20H)));
      sp := ptr+5;
      COPY( name, sp^);
      Strings.AppendC(".", sp^);
      Strings.Append(sym.name, sp^);
      header.symbolValues[symbolCount] := symbolDataSize;
      header.symbolNames[symbolCount] := symbolDataSize;
      INC(symbolCount);
      INC(symbolDataSize, modNameLen + StringLength( sym.name) );
      INC(symbolDataSize, symbolDataSize MOD 2); (* even *)
    END;
   END EnterData;

(*$-i *)

  PROCEDURE ~CompareValues(a: S.PTR; i, j: LONGINT) : LONGINT;
    VAR
      adri, adrj: LONGINT;
   BEGIN
    S.GET( S.ADR( header.symbolData[ header.symbolValues[i] ] ), adri);
    S.GET( S.ADR( header.symbolData[ header.symbolValues[j] ] ), adrj);
    RETURN adri - adrj;
   END CompareValues;

  PROCEDURE ~CompareNames(a: S.PTR; i, j: LONGINT) : LONGINT;
    VAR
      spi, spj: Strings.ptr;
   BEGIN
    spi := S.ADR( header.symbolData[ header.symbolNames[i] ] ) + 5;
    spj := S.ADR( header.symbolData[ header.symbolNames[j] ] ) + 5;
    IF spi^ = spj^ THEN RETURN 0 END;
    IF spi^ < spj^ THEN RETURN -1 END;
    RETURN 1;
   END CompareNames;

  PROCEDURE ~Exchange(a: S.PTR; i, j: LONGINT);
    VAR
      p: RSD.IntPtr; val: INTEGER;
   BEGIN
    p := a; S.EXG(p[i], p[j]);
   END Exchange;

(*$+i *)

 BEGIN
  RemoveTable(name);
  symbolCount := 0; symbolDataSize := 0;
  modNameLen := Strings.Length( name) + 7;
  obj.SymbolsDo( Count);
  header := NewHeader(symbolCount, symbolDataSize);
  COPY(name, header.programName);
  header.firstData := 0; header.firstBss := 0;  (* not correct *)
  header.firstAddress := obj.TextAdr();
  header.lastAddress := obj.DataAdr() + obj.DataSize();
  header.basepage := 0; (* no basepage available *)
  symbolCount := 0; symbolDataSize := 0;
  obj.SymbolsDo( EnterData);
  QSort( header.symbolValues, 0, symbolCount-1, CompareValues, Exchange);
  QSort( header.symbolNames, 0, symbolCount-1, CompareNames, Exchange);
  AddHeader( header);
 END AddTable;

(*$+y *)

PROCEDURE RemoveTables;
  VAR
    cookie: RSD.SymbolCookiePtr;
    header, prev: RSD.SymbolHeaderPtr;
 BEGIN
  IF Task.level = 0 THEN
    cookie := RSD.GetCookie();
    IF cookie # NIL THEN
      header := cookie.first; prev := NIL;
      WHILE header # NIL DO
        IF Strings.FPosC( ".", header.programName) = -1 THEN
          IF prev = NIL THEN
            cookie.first := header.next
          ELSE
            prev.next := header.next
          END;
        ELSE
          prev := header;
        END;
        header := header.next;
      END;
    END;
  END;
 END RemoveTables;


BEGIN
  Task.StoreExit(RemoveTables)
END RSDManipulation.