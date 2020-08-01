MODULE OLink; (* SJ 24.10.92 *)


IMPORT S:=SYSTEM, M:=Memory, FN:=Filename, File, Paths, Str:=Strings,
       Task, NStr:=NumStr, IO, Env:=Environment, Sys, Par:=OLPar,
       CL:=CommandLine, Form, ObnEnv;


CONST (* symbol types *)
  bss = 0; text = 1; data = 2; extern = 3; reglist = 4;
  global = 5; equate = 6; defined = 7;
  sint = 1; int = 2; lint = 3; str = 4; (* variables *)
  none = 0; eof = 128; ident = 129; number = 130; string = 131; ask = 132;
  unknown = 5; double = 6; namexp = 7; loaderr = 8; saverr = 9;


TYPE
   objectptr= POINTER TO object;
   symstr   = ARRAY 24 OF CHAR;
   object   = RECORD
                Next    : objectptr;
                Address : LONGINT;
                Length  : LONGINT;
                TextOff : LONGINT;
                DataOff : LONGINT;
                BssOff  : LONGINT;
                Name    : symstr;
                dreloff : LONGINT;	(* set by TextRelocLen *)
                dreladr : LONGINT;	(* dito *)
              END(*RECORD*);
   symptr   = POINTER TO symbol;
   symbol   = RECORD
                Name    : ARRAY 8 OF CHAR;
                SymType : SHORTINT;
                Magic   : SHORTINT;
                Value   : LONGINT;
                Extend  : ARRAY 14 OF CHAR;
              END(*RECORD*);
   headerptr= POINTER TO header;
   header   = RECORD
                Code    : INTEGER;
                TextSize: LONGINT;
                DataSize: LONGINT;
                BssSize : LONGINT;
                SymSize : LONGINT;
                Key     : LONGINT;
                Rsvd    : ARRAY 3 OF INTEGER;
              END(*RECORD*);
   lcptr    = POINTER TO ARRAY 1 OF LONGINT;
   relocptr = POINTER TO ARRAY 30000 OF CHAR;
   relocproc= PROCEDURE ( VAR Offset : LONGINT );
   strptr = POINTER TO ARRAY 128 OF CHAR;

VAR
  FirstMod : objectptr;
  TextOffset,DataOffset,BssOffset : LONGINT;
  LinkAlsoObj : ARRAY 25 OF objectptr; loinx : INTEGER;

(* variables for information interchange between LinkExternal and SetExtOffset *)
  OffsetList : ARRAY 100 OF LONGINT;
  ModNo,ProcNum : INTEGER;
  Module,ObjPtr : objectptr;

(* variables for information interchange between CorrectOffsets and IncOff *)
  DataStart,BssStart,Toff,Doff,Boff : LONGINT;

  SpecPaths : Paths.path;
  SysData : POINTER TO RECORD
              dummy    : ARRAY 0BAH OF SHORTINT;
              compDate : ARRAY 12 OF CHAR;
              compTime : ARRAY 10 OF CHAR;
              stackSize: LONGINT
            END;
  noSymStr : symstr;
  RetCode: INTEGER;


PROCEDURE AlreadyLinked(VAR Name : ARRAY OF CHAR) : BOOLEAN;
BEGIN
  ObjPtr := FirstMod;
  WHILE ObjPtr # NIL DO
    IF Name = ObjPtr.Name THEN RETURN TRUE END(*IF*);
    ObjPtr := ObjPtr.Next;
  END(*WHILE*);
  RETURN FALSE
END AlreadyLinked;


PROCEDURE AppendObject(Obj : objectptr);
VAR Ptr,Prev : objectptr;
BEGIN
  Ptr := FirstMod; Prev := S.ADR(FirstMod);
  WHILE Ptr # NIL DO
    Prev := Ptr; Ptr := Ptr.Next;
  END(*WHILE*);
  Prev.Next := Obj; Obj.Next := NIL;
END AppendObject;


PROCEDURE GetSymbolAd(Begad : headerptr) : LONGINT;
BEGIN
  RETURN S.VAL(LONGINT,Begad) + Begad.TextSize + Begad.DataSize + 28;
END GetSymbolAd;


PROCEDURE GetRelocAd(Begad : headerptr) : LONGINT;
BEGIN
  RETURN S.VAL(LONGINT,Begad) + Begad.TextSize + Begad.DataSize + Begad.SymSize + 28;
END GetRelocAd;


PROCEDURE NextSymbol(VAR Ptr : symptr);
BEGIN
  IF Ptr.Magic = 48H THEN INC(Ptr,28) ELSE INC(Ptr,14) END;
END NextSymbol;


PROCEDURE MergeName(Ptr : symptr; VAR Name : ARRAY OF CHAR);
BEGIN
  COPY(Ptr.Name,Name); Name[8] := 0X;
  IF Ptr.Magic = 48H THEN Str.Append(Ptr.Extend,Name) END;
END MergeName;


PROCEDURE TestSymType(Sym : symptr; Bit : INTEGER) : BOOLEAN;
 BEGIN
  RETURN Bit IN S.VAL(SET,LONG(LONG(Sym.SymType)))
 END TestSymType;


PROCEDURE AddOffsets(Begad : LONGINT);
VAR Ptr : symptr;
BEGIN
  Ptr := GetSymbolAd(Begad);
  WHILE Ptr.Name[0] # 0X DO
    IF TestSymType(Ptr,text) THEN INC(Ptr.Value,TextOffset);
    ELSIF TestSymType(Ptr,data) THEN INC(Ptr.Value,DataOffset);
    ELSIF TestSymType(Ptr,bss) THEN INC(Ptr.Value,BssOffset);
    END(*IF*);
    NextSymbol(Ptr);
  END;
END AddOffsets;


PROCEDURE FindModule2(Name : ARRAY OF CHAR; VAR Ptr : objectptr) : BOOLEAN;
VAR s : ARRAY 80 OF CHAR;
BEGIN
  Ptr := FirstMod;
  WHILE Ptr # NIL DO
    IF Ptr.Name = Name THEN RETURN TRUE END(*IF*);
    Ptr := Ptr.Next;
  END(*WHILE*);
  IO.WriteString(Name); IO.WriteString(" not found in list"); IO.WriteLn;
  RetCode := -1; RETURN FALSE
END FindModule2;


PROCEDURE FindModule(Mod : symptr; VAR Ptr : objectptr) : BOOLEAN;
VAR Name : symstr;
BEGIN
  MergeName(Mod,Name);
  RETURN FindModule2(Name,Ptr);
END FindModule;


PROCEDURE DeleteSymbol(Ptr : objectptr; Sym : symptr);
VAR Size : LONGINT;
  Head : headerptr;
BEGIN
  IF Sym.Magic = 48H THEN Size := 28 ELSE Size := 14 END(*IF*);
  M.Copy(S.VAL(LONGINT,Sym) + Size,S.VAL(LONGINT,Sym),
         Ptr.Address + Ptr.Length - S.VAL(LONGINT,Sym) - Size);
  DEC(Ptr.Length,Size);
  Head := Ptr.Address;
  DEC(Head.SymSize,Size);
END DeleteSymbol;


PROCEDURE DeleteImportSymbols(Ptr : objectptr);
VAR Sym : symptr;
BEGIN
  Sym := GetSymbolAd(Ptr.Address);
  WHILE Sym.Name[0] # 0X DO
    IF TestSymType(Sym,equate) THEN DeleteSymbol(Ptr,Sym)
    ELSE NextSymbol(Sym)
    END;
  END(*WHILE*);
END DeleteImportSymbols;


PROCEDURE WorkOnReloc(ModAd : LONGINT; Work : relocproc);
(* runs through the relocation table and calls Work with every offset
   in the code *)
VAR lcp   : lcptr;
    Reloc : relocptr;
    i     : INTEGER;
BEGIN
  lcp := GetRelocAd(ModAd);
  IF lcp[0] # 0 THEN
    Reloc := S.VAL(LONGINT,lcp) + 4;
    lcp := ModAd + lcp[0] + 28;
    Work(lcp[0]); i := 0;
    WHILE Reloc[i] # 0X DO
      IF Reloc[i] = 1X THEN
        REPEAT INC(lcp,254); INC(i); UNTIL Reloc[i] # 1X;
      END(*IF*);
      INC(lcp, ORD(Reloc[i]) );
      Work(lcp[0]); INC(i);
    END(*WHILE*);
  END(*IF*);
END WorkOnReloc;


PROCEDURE SetExtOffset*( VAR Offset : LONGINT );
(* if offset specifies an external value, it will be corrected. It needs
   OffsetList, ModNo, ProcNum and Module *)
VAR Code : INTEGER; s : ARRAY 80 OF CHAR;
BEGIN
 IF SHORT(ASH(Offset,-24)) = ModNo THEN
   Code := S.ANL( SHORT(ASH(Offset,-22)), 3 );
   IF (ModNo # 0) OR (Code # 0) THEN
     Offset := S.ANL(Offset,0FFFFH);
   END(*IF*);
   IF (Code = 0) AND (ModNo # 0) THEN INC( Offset, Module.TextOff);
   ELSIF Code = 1 THEN INC(Offset,Module.BssOff + DataOffset + TextOffset )
   ELSIF Code = 2 THEN INC(Offset,Module.DataOff + TextOffset )
   ELSIF Code = 3 THEN
     IF (SHORT( Offset) < 0) OR (SHORT(Offset) >= ProcNum) THEN
       IO.WriteString("Error in "); IO.WriteString(ObjPtr.Name);
       IO.WriteString(": calls procedure #");
       IO.WriteInt(Offset); IO.WriteString(" unknown in ");
       IO.WriteString(Module.Name); IO.WriteLn;
       HALT(99);
       Offset := 0; Task.Exit(-1)
     END(*IF*);
     Offset := OffsetList[SHORT(Offset)]
   END(*IF*);
 END(*IF*);
END SetExtOffset;


PROCEDURE LinkExternal;
VAR Ptr  : symptr;
  Add,Add2 : LONGINT;

  PROCEDURE Link;
   VAR Sym : symptr;
   BEGIN
    Sym := GetSymbolAd(Module.Address);
    ProcNum := 1; OffsetList[0] := Module.TextOff;
    WHILE Sym.Name[0] # 0X DO
      IF TestSymType(Sym,global) THEN
        OffsetList[ProcNum] := Sym.Value; INC(ProcNum);
      END(*IF*);
      NextSymbol(Sym)
    END(*WHILE*);
    WorkOnReloc(ObjPtr.Address,SetExtOffset);
   END Link;

BEGIN
  ObjPtr := FirstMod;
  REPEAT
    Ptr := GetSymbolAd(ObjPtr.Address);
    WHILE Ptr.Name[0] # 0X DO
      IF TestSymType(Ptr,extern) AND FindModule(Ptr,Module) THEN
        ModNo := SHORT(Ptr.Value); Link;
      END(*IF*);
      NextSymbol(Ptr);
    END;
    DeleteImportSymbols(ObjPtr);
    Module := ObjPtr; ModNo := 0; Link; (* the module itself *)
    Module := FirstMod; ModNo := -128; Link; (* SYSTEM *)
    ObjPtr := ObjPtr.Next;
  UNTIL ObjPtr = NIL;
END LinkExternal;


PROCEDURE IncOffsets(Begad : headerptr);
BEGIN
  INC(TextOffset,Begad.TextSize);
  INC(DataOffset,Begad.DataSize);
  INC(BssOffset,Begad.BssSize);
END IncOffsets;


PROCEDURE SegmentOffset(Offset : LONGINT) : LONGINT;
BEGIN
  IF Offset < DataStart THEN RETURN Toff
  ELSIF Offset < BssStart THEN RETURN TextOffset + Doff - DataStart
  END(*IF*);
  RETURN TextOffset + DataOffset + Boff - BssStart
END SegmentOffset;


PROCEDURE IncOff*(VAR Offset : LONGINT);
 (* corrects all offsets that are in atari-format. Needs Toff,Doff,Boff,
    DataStart and BssStart *)
 BEGIN
  IF (Offset >= 0) & (Offset < 0C00000H) THEN
    IF Offset >= 800000H THEN (* data-segment *)
      DEC(Offset,800000H - DataStart);
    ELSIF Offset >= 400000H THEN (* bss-segment *)
      DEC(Offset,400000H - BssStart);
    END(*IF*);
    INC(Offset,SegmentOffset(Offset));
  END(*IF*);
 END IncOff;


PROCEDURE DeleteDefined(Module : objectptr);
  VAR Sym : symptr;
 BEGIN
  Sym := GetSymbolAd(Module.Address);
  WHILE Sym.Name[0] # 0X DO
    IF Sym.SymType = S.VAL(SHORTINT,80H) THEN DeleteSymbol(Module,Sym)
    ELSE NextSymbol(Sym)
    END(*IF*);
  END;
 END DeleteDefined;


PROCEDURE CorrectOffsets;
VAR Ptr  : objectptr;
    i    : INTEGER;
    Head : headerptr;
BEGIN
  Ptr := FirstMod; Toff := 0; Doff := 0; Boff := 0;
  REPEAT DeleteDefined(Ptr);
    Head := Ptr.Address; DataStart := Head.TextSize;
    BssStart := DataStart + Head.DataSize;
    WorkOnReloc(S.VAL(LONGINT,Head),IncOff);
    Ptr.TextOff := Toff; Ptr.DataOff := Doff; Ptr.BssOff := Boff;
    INC(Toff,Head.TextSize); INC(Doff,Head.DataSize);
    INC(Boff,Head.BssSize); Ptr := Ptr.Next;
  UNTIL Ptr = NIL;
END CorrectOffsets;


PROCEDURE GetKey(VAR Name : ARRAY OF CHAR) : LONGINT;
  (* reads the time and date of saving of the source file. *)
  VAR Handle : INTEGER;
      Datime : File.datime;
 BEGIN
  IF File.Sfirst(Name,{}) AND File.Open(Name,File.read,Handle) THEN
    File.Datime(Handle,Datime,0); File.Close(Handle);
    RETURN S.LONG(Datime.Time) + Datime.Date * 10000H;
  END;
  RETURN 0
 END GetKey;


PROCEDURE LinkFile(Name : ARRAY OF CHAR; Key : LONGINT;
                   KeyName : symstr; VAR FullName : FN.path) : BOOLEAN;
VAR
  Begad  : S.PTR;
  Length : LONGINT;
  Ptr    : objectptr;
  Symbol,alert : ARRAY 100 OF CHAR;
  SymPtr : symptr;
  Head : headerptr;

  PROCEDURE LinkImportedFiles(Begad,Key : LONGINT;
                              VAR KeyName : symstr) : BOOLEAN;
    VAR Ptr : symptr; Name,name : FN.path;
  BEGIN
    Ptr := GetSymbolAd(Begad);
    WHILE Ptr.Name[0] # 0X DO
      IF TestSymType(Ptr,extern) THEN
        MergeName(Ptr,Name);
        IF NOT LinkFile(Name,Key,KeyName,name) THEN RETURN FALSE END(*IF*);
      END(*IF*);
      NextSymbol(Ptr);
    END;
    RETURN TRUE
  END LinkImportedFiles;

  PROCEDURE SearchReplaceName( VAR Name : ARRAY OF CHAR);
    VAR vname : ARRAY 14 OF CHAR;
   BEGIN
    Str.Merge( "LINK_", Name, vname);
    IF Env.ReadStr( vname, vname) THEN COPY(vname, Name);
      Name[8] := 0X
    END;
   END SearchReplaceName;

  PROCEDURE CheckVersion() : BOOLEAN;
   BEGIN
    IF S.LSH(Head.Key,-1) > S.LSH(Key,-1) THEN (* Versionskonflikt *)
      alert := "[2][Symbol file of ";
      Str.Append(Name, alert);
      Str.Append("|is younger than the|object file of ", alert);
      Str.Append(KeyName, alert);
      Str.Append("][Abort|Ignore]", alert);
      RETURN Form.Alert(1, alert) = 2;
    END;
    RETURN TRUE;
   END CheckVersion;

BEGIN
  COPY(Name,Symbol); Symbol[8] := 0X;
  Str.CAPs( Symbol); SearchReplaceName( Symbol);
  FN.SetExt(Par.objExt,Symbol);
  IF NOT AlreadyLinked(Name) THEN
    IF (Paths.Get(SpecPaths,Symbol,{},Symbol)
         OR Paths.Get(Par.ObjPaths,Symbol,{},Symbol) )
         AND File.Load(Symbol,0,0,Begad,Length) THEN
      IO.WriteString("Loading "); IO.WriteString(Symbol); IO.WriteLn;
      Head := Begad;
      IF NOT CheckVersion() THEN RETURN FALSE END;
      NEW(Ptr); Ptr.Address := Begad;
      Ptr.Length := Length; COPY(Name,Ptr.Name);
      AppendObject(Ptr); AddOffsets(Begad); IncOffsets(Begad);
      COPY(Symbol,FullName);
      IF Name = "Sys" THEN
        SysData := Begad + 1CH + Head.TextSize;
      END;
      Key := GetKey(Symbol); COPY(Name, KeyName);
      IF LinkImportedFiles(Begad, Key, KeyName) THEN RETURN TRUE
      ELSE IO.WriteString("Imported by "); IO.WriteString(Name);
        IO.WriteLn; RETURN FALSE
      END;
    ELSE RetCode := -33;
      IO.WriteString(Name); IO.WriteString(" not found"); IO.WriteLn;
      RETURN FALSE
    END(*IF*);
  ELSE
    Head := ObjPtr.Address;
    RETURN CheckVersion()
  END(*IF*);
  RETURN TRUE
END LinkFile;


PROCEDURE WriteInt(i : LONGINT; n : INTEGER; VAR Line : ARRAY OF CHAR);
 VAR s : ARRAY 10 OF CHAR;
 BEGIN
   NStr.LIntTo(i,10,s);
   Str.Adjust(Str.right,n," ",s);
   Str.Append(s,Line);
 END WriteInt;


PROCEDURE SaveProgram(VAR Name,FileName : ARRAY OF CHAR);
VAR MainMod : objectptr;
    Handle,ObjHandle : INTEGER;
    ObjName : FN.path;
    datime : File.datime;
    s : ARRAY 10 OF CHAR;

  PROCEDURE LinkPtrOffsets;
    VAR
      mod, next: objectptr;
      lcp : lcptr;
      header: headerptr;
   BEGIN
    mod := FirstMod;
    REPEAT
      next := mod.Next;
      IF next = NIL THEN next := FirstMod END;
      lcp := GetSymbolAd( mod.Address) - 4;
      header := next.Address;
      lcp[0] := TextOffset + next.DataOff + header.DataSize - 4;
      mod := next;
    UNTIL mod = FirstMod;
   END LinkPtrOffsets;

  PROCEDURE DeleteExtended(Mod : objectptr);
    VAR Sym : symptr; Endad : LONGINT; Head : headerptr;
   BEGIN
    IF NOT Par.ExtendedSymtab THEN Sym := GetSymbolAd(Mod.Address);
      Endad := Mod.Address + Mod.Length - 28;
      WHILE Sym.Name[0] # 0X DO
        IF Sym.Magic = 48H THEN Sym.Magic := 0;
          Head := Mod.Address; DEC(Head.SymSize,14); DEC(Mod.Length,14);
          M.Copy(S.VAL(LONGINT,Sym) + 28,S.VAL(LONGINT,Sym) + 14,
                 Endad - S.VAL(LONGINT,Sym));
        END;
        INC(Sym,14);
      END;
    END;
   END DeleteExtended;

  PROCEDURE SymbolSize() : LONGINT;
  VAR Ptr : objectptr;
    Ret : LONGINT;
    Head : headerptr;
  BEGIN
    IF NOT Par.SymbolTable THEN RETURN 0 END;
    Ptr := FirstMod;
    Ret := 0;
    REPEAT DeleteExtended(Ptr); Head := Ptr.Address;
      INC(Ret,Head.SymSize);
      IF Par.ExtendedSymtab AND (Str.Length(Ptr.Name) > 8) THEN
        INC(Ret,28)
      ELSE INC(Ret,14)
      END;
      Ptr := Ptr.Next;
    UNTIL Ptr = NIL;
    RETURN Ret
  END SymbolSize;

  PROCEDURE SaveHeader(Handle : INTEGER);
  VAR Count: LONGINT;
    Header : header;
    d   : BOOLEAN;
  BEGIN
    IO.WriteString("Saving "); IO.WriteString(FileName); IO.WriteLn;
    IO.WriteInt(TextOffset); IO.WriteString(" bytes code and ");
    IO.WriteInt(DataOffset); IO.WriteString(" bytes data produced");
    IO.WriteLn;
    Header.Code := 601AH;
    Header.TextSize := TextOffset;
    Header.DataSize := DataOffset;
    Header.BssSize := BssOffset + Par.StackSize;
    Header.SymSize := SymbolSize();
    IF Header.SymSize # 0 THEN IO.WriteInt(Header.SymSize);
      IO.WriteString(" bytes of ");
      IF Par.ExtendedSymtab THEN IO.WriteString("extended ") END;
      IO.WriteString("symbol table"); IO.WriteLn
    END;
    Header.Key := 0;
    Header.Rsvd[0] := 0;
    Header.Rsvd[1] := 7;
    Header.Rsvd[2] := 0;
    Count := SIZE(header);
    d := File.Write(Handle,Count,S.ADR(Header));
  END SaveHeader;

  PROCEDURE SaveText(Handle : INTEGER);
  VAR Count  : LONGINT; i : INTEGER;
    d   : BOOLEAN;
    Ptr : objectptr;
    Head : headerptr;
    p : POINTER TO ARRAY 8 OF RECORD
          Jsr : INTEGER; Address : LONGINT
        END;
  BEGIN
    Ptr := FirstMod; Head := Ptr.Address;
    p := S.VAL(LONGINT,Head) + Head.TextSize - 14;
    i := 0;
    WHILE i < loinx DO p[i].Address := LinkAlsoObj[i].TextOff; INC(i) END;
    p[i].Address := MainMod.TextOff;
    REPEAT
      Head := Ptr.Address;
      Count := Head.TextSize;
      d := File.Write(Handle,Count,Ptr.Address + 28);
      Ptr := Ptr.Next;
    UNTIL Ptr = NIL;
  END SaveText;

  PROCEDURE SaveData(Handle : INTEGER);
  VAR Count  : LONGINT;
    d   : BOOLEAN;
    Ptr   : objectptr;
    Head   : headerptr;
  BEGIN
    Ptr := FirstMod;
    REPEAT
      Head := Ptr.Address;
      Count := Head.DataSize;
      d := File.Write(Handle,Count,Ptr.Address + Head.TextSize + 28);
      Ptr := Ptr.Next;
    UNTIL Ptr = NIL;
  END SaveData;

  PROCEDURE AbsoluteSymbols(Sym : symptr);
   BEGIN
    IF Par.absSym THEN
      WHILE Sym.Name[0] # 0X DO
        IF data IN S.VAL(SET,LONG(Sym.SymType)) THEN
          INC(Sym.Value,TextOffset)
        ELSIF bss IN S.VAL(SET,LONG(Sym.SymType)) THEN
          INC(Sym.Value,TextOffset + DataOffset)
        END;
        NextSymbol(Sym);
      END;
    END;
   END AbsoluteSymbols;

  PROCEDURE MakeSymbol(VAR Name : ARRAY OF CHAR; Type : SHORTINT;
              Value : LONGINT; VAR Size : LONGINT; VAR Sym : symbol);
    VAR p : relocptr;
   BEGIN
    COPY(Name,Sym.Name); Sym.SymType := Type; Sym.Magic := 0;
    Sym.Value := Value; Size := 14;
    IF Par.ExtendedSymtab AND (Str.Length(Name) > 8) THEN
      p := S.ADR(Name[8]);
      COPY(p^,Sym.Extend); Sym.Magic := 48H; Size := 28;
    END;
   END MakeSymbol;

  PROCEDURE SaveSymbols(Handle : INTEGER);
  VAR Count,Symad : LONGINT;
      d   : BOOLEAN;
      Ptr : objectptr;
      Head: headerptr;
      Symbol : symbol;
  BEGIN
    IF Par.SymbolTable THEN
      Ptr := FirstMod;
      REPEAT
        MakeSymbol(Ptr.Name,2,Ptr.TextOff,Count,Symbol);
        d := File.Write(Handle,Count,S.ADR(Symbol));
        Head := Ptr.Address; Count := Head.SymSize;
        Symad := S.VAL(LONGINT,Head) + Head.TextSize + Head.DataSize + 28;
        AbsoluteSymbols(Symad);
        d := File.Write(Handle,Count,Symad);
        Ptr := Ptr.Next;
      UNTIL Ptr = NIL;
    END;
  END SaveSymbols;

  PROCEDURE SaveRest(Handle : INTEGER; Rest : LONGINT);
  VAR Count: LONGINT;
      d    : BOOLEAN;
      c    : CHAR;
  BEGIN
    Count := 1;
    c := 1X;
    WHILE Rest > 254 DO
      d := File.Write(Handle,Count,S.ADR(c));
      DEC(Rest,254);
    END(*WHILE*);
    d := File.Write(Handle,Count,S.ADR(Rest) + 3);
  END SaveRest;

  PROCEDURE GetRest(Pos, size: LONGINT; Reloc: relocptr) : LONGINT;
    VAR
      i : INTEGER;
  BEGIN
    i := 0;
    WHILE Reloc[i] # 0X DO
      IF Reloc[i] = 1X THEN
        REPEAT
          INC(Pos,254);
          INC(i);
        UNTIL Reloc[i] # 1X;
      END(*IF*);
      INC(Pos, ORD(Reloc[i]) );
      INC(i);
    END(*WHILE*);
    RETURN size - Pos
  END GetRest;

  PROCEDURE TextRelocLen(obj: objectptr; textSize, relAdr: LONGINT) : LONGINT;
    VAR
      len, pos, addr, adr : LONGINT;
      b : CHAR;
   BEGIN
    addr := relAdr;
    S.GET(addr, pos);	(* first long word *)
    INC(addr, 4);
    LOOP
      len := 0; adr := addr;
      REPEAT
        S.GET(adr, b); INC(adr);
        IF b = 1X THEN INC(len, 254) END;
      UNTIL (b # 1X);
      INC(len, ORD(b));
      IF (b = 0X) OR (pos + len >= textSize) THEN EXIT END;
      addr := adr;
      INC(pos, len);
    END;
    IF b = 0X THEN
      obj.dreloff := -1;
    ELSE
      obj.dreladr := adr;
      obj.dreloff := len - textSize + pos;
      S.PUT(addr, 0);
    END;
    RETURN addr - relAdr;
   END TextRelocLen;

  PROCEDURE DataRelocLen(relAdr: LONGINT) : LONGINT;
    VAR
      adr : LONGINT;
      b : SHORTINT;
   BEGIN
    adr := relAdr;
    REPEAT
      S.GET(adr, b); INC(adr);
    UNTIL (b = 0);
    RETURN adr - 1 - relAdr;
   END DataRelocLen;

  PROCEDURE SaveReloc(Handle : INTEGER);
  VAR Count: LONGINT;
      d    : BOOLEAN;
      Ptr  : objectptr;
      Head : headerptr;
      Addr : LONGINT;
      Rest : LONGINT;
      lcp  : lcptr;
  BEGIN
    Ptr := FirstMod; Count := 4;
    d := File.Write(Handle,Count,GetRelocAd(Ptr.Address));
    Rest := 0;
    REPEAT
      Head := Ptr.Address; Addr := GetRelocAd(Ptr.Address); lcp := Addr;
      IF lcp[0] # 0 THEN
        IF Rest # 0 THEN SaveRest(Handle,Rest + lcp[0]) END(*IF*);
        Count := TextRelocLen(Ptr, Head.TextSize, Addr) - 4;
        IF Count # 0 THEN d := File.Write(Handle,Count,Addr + 4) END ;
        Rest := GetRest(lcp[0], Head.TextSize, Addr+4);
      ELSE INC(Rest,Head.TextSize)
      END(*IF*);
      Ptr := Ptr.Next;
    UNTIL Ptr = NIL;
    Ptr := FirstMod;
    REPEAT
      Head := Ptr.Address;
      IF Ptr.dreloff # -1 THEN
        SaveRest(Handle,Rest + Ptr.dreloff);
        Count := DataRelocLen(Ptr.dreladr);
        IF Count # 0 THEN d := File.Write(Handle,Count,Ptr.dreladr) END ;
        Rest := GetRest(Ptr.dreloff, Head.DataSize, Ptr.dreladr);
      ELSE INC(Rest,Head.DataSize)
      END(*IF*);
      Ptr := Ptr.Next;
    UNTIL Ptr = NIL;
    Count := 1; d := FALSE;
    d := File.Write(Handle,Count,S.ADR(d));
  END SaveReloc;

BEGIN
 IF FindModule2(Name,MainMod) THEN
  IF Par.PrgPath[0] # 0X THEN
    COPY(Par.PrgPath,FileName); FN.SetName(Name,FileName);
  END;
  FN.SetExt(Par.PrgExt,FileName);
  IF File.Create(FileName,{},Handle) THEN
    IF SysData # NIL THEN
      SysData.stackSize := Par.StackSize;
      COPY(Name, ObjName); FN.SetExt( Par.objExt, ObjName);
      IF Paths.Get(Par.ObjPaths,ObjName,{},ObjName) AND
         File.Open( ObjName, File.read, ObjHandle) THEN
        File.Datime( ObjHandle, datime, File.get);
        File.Close( ObjHandle);
        NStr.IntTo( S.ANL( datime.Date, 1FH), 10, s);
        Str.Adjust( Str.right, 2, "0", s);
        Str.Merge( s, '.', SysData.compDate);
        NStr.IntTo( S.ANL( datime.Date DIV 20H, 0FH), 10, s);
        Str.Adjust( Str.right, 2, "0", s);
        Str.AppendC(".", s);
        Str.Append( s, SysData.compDate);
        NStr.IntTo( S.ANL( datime.Date DIV 200H, 7FH) + 1980, 10, s);
        Str.Append( s, SysData.compDate);

        NStr.IntTo( S.ANL( datime.Time DIV 800H, 1FH), 10, s);
        Str.Adjust( Str.right, 2, "0", s);
        Str.Merge( s, ':', SysData.compTime);
        NStr.IntTo( S.ANL( datime.Time DIV 20H, 3FH), 10, s);
        Str.Adjust( Str.right, 2, "0", s);
        Str.AppendC(":", s);
        Str.Append( s, SysData.compTime);
        NStr.IntTo( S.ANL( datime.Time, 1FH) * 2, 10, s);
        Str.Adjust( Str.right, 2, "0", s);
        Str.Append( s, SysData.compTime);
      END;
    END;
    LinkPtrOffsets;
    SaveHeader(Handle);
    SaveText(Handle);
    SaveData(Handle);
    SaveSymbols(Handle);
    SaveReloc(Handle);
    File.Close(Handle);
  END(*IF*);
 END(*IF*);
END SaveProgram;


PROCEDURE LinkOthers() : BOOLEAN;
  VAR LinkAlso : ARRAY 256 OF CHAR;
      i,j : INTEGER;
      Name,name : FN.path;
 BEGIN
  IF NOT Env.ReadStr("LINKALSO",LinkAlso) THEN LinkAlso[0] := 0X END;
  i := 0; loinx := 0;
  REPEAT j := 0;
    WHILE (LinkAlso[i] # 0X) AND (LinkAlso[i] < "A") DO INC(i) END;
    WHILE (LinkAlso[i] # 0X) AND (LinkAlso[i] # ",") DO
      Name[j] := LinkAlso[i]; INC(i); INC(j)
    END;
    Name[j] := 0X;
    FN.GetName(Name,Name); j := Str.FPosC(".",Name);
    IF j # -1 THEN Name[j] := 0X END;
    IF Name[0] # 0X THEN
      IF NOT LinkFile(Name,-1,noSymStr,name) THEN RETURN FALSE END;
      IF FindModule2(Name,LinkAlsoObj[loinx]) THEN INC(loinx)
      ELSE RETURN FALSE
      END;
    END;
  UNTIL LinkAlso[i] = 0X;
  RETURN TRUE
 END LinkOthers;


PROCEDURE Exit;
  VAR
    i : INTEGER;
 BEGIN
  FOR i := 0 TO 24 DO
    LinkAlsoObj[i] := NIL;
  END;
  FirstMod := NIL;
  Module := NIL; ObjPtr := NIL;
  SpecPaths := NIL;
  SysData := NIL;
 END Exit;


PROCEDURE Link*;
  VAR
    name : FN.path; Name : FN.name;
    i : INTEGER;
 BEGIN
  Exit;
  Task.Init;
  Par.Init; RetCode := 0;
  IO.WriteString("Oberon linker V2.02  (c) Stephan Junker  ");
  IO.WriteString( Sys.compDate);
  IO.WriteLn;
  IF CL.arg # NIL THEN
    WHILE (CL.arg # NIL) AND Par.ReadOptions(CL.arg^) DO
      CL.Next()
    END(*WHILE*);
    IF CL.arg # NIL THEN
      Par.ReadPaths;
      FirstMod := NIL; TextOffset := 0; DataOffset := 0; BssOffset := 0;
      FN.GetName(CL.arg^,Name); i := Str.FPosC(".",Name);
      IF i # -1 THEN Name[i] := 0X END;
      IF Par.PrgExt[0] = "T" THEN Paths.Read("TOSPATH", SpecPaths)
      ELSE Paths.Read("GEMPATH", SpecPaths)
      END;
      IF LinkFile("O2Init",-1,noSymStr,name) AND LinkFile(Name,-1,noSymStr,name)
         AND LinkOthers() THEN
        IO.WriteString("linking "); IO.WriteString(name); IO.WriteLn;
        CorrectOffsets;
        LinkExternal;
        IF Par.ProgName[0] # 0X THEN FN.SetName(Par.ProgName, name) END;
        SaveProgram(Name,name);
      END(*IF*);
      IF RetCode = 0 THEN IO.WriteString("Linking completed");
      ELSE IO.WriteString("Linking aborted");
      END;
      IO.WriteLn;
    ELSE
      IO.WriteString("No module name found"); IO.WriteLn;
    END(*IF*);
  ELSE
    IO.WriteString("Usage: link <options> <name>"); IO.WriteLn;
  END;
  Exit;
  Task.Exit( RetCode);
 END Link;


BEGIN
  IF ~Sys.Loader THEN
    Link;
    Task.Exit( Task.retCode)
  END;
END OLink.
