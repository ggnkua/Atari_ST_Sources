MODULE O2LS; (* SJ 9.11.94 *)

(*
 O2Loader support module (size reduction!)
 *)


IMPORT
  S:=SYSTEM, Sys;


CONST
  PathLen* = 256; (* lengths of types *)
  NameLen* = 40;
  ExtLen*  = 10;

  (* symbol flags *)
  Bss* = 0; Text* = 1; Data* = 2; Extern* = 3; RegList* = 4;
  Global* = 5; Equate* = 6; Defined* = 7;



TYPE
  path*    = ARRAY PathLen OF CHAR;
  name*    = ARRAY NameLen OF CHAR;
  ext*     = ARRAY ExtLen OF CHAR;

  Pathspath* = POINTER TO pathdesc;
  pathdesc* = RECORD
                Next* : Pathspath;
                Path* : path;
              END;

  dtarec     = RECORD
                 Search  : ARRAY 12 OF CHAR;
                 rsv     : ARRAY 8 OF CHAR;
                 Attrib  : INTEGER;
                 Time    : INTEGER;
                 Date    : INTEGER;
                 Length  : LONGINT;
                 Name    : ARRAY 14 OF CHAR;
               END(*RECORD*);
  dta        = POINTER TO dtarec;

  datime*    = RECORD
                 Time*   : INTEGER;
                 Date*   : INTEGER;
               END(*RECORD*);

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
  Dta : dtarec;
  objPaths* : Pathspath;
  objExt* : ext;
  opVar: ARRAY 20 OF CHAR;

(*---------------------------IO-----------------------------------------*)

PROCEDURE- Cconout*(c : INTEGER) 2,1;

PROCEDURE- Cconws*(StrPtr : S.PTR) 9,1;


PROCEDURE WriteChar(c: CHAR);
 BEGIN
  Cconout( ORD(c) );
 END WriteChar;

(*$-y *)

PROCEDURE WriteString*(Output : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  Cconws(S.ADR(Output));
 END WriteString;

(*$+y *)

PROCEDURE WriteLn*;
 BEGIN
  Cconout(0DH); Cconout(0AH);
 END WriteLn;

(*---------------------------Strings------------------------------------*)

PROCEDURE End(i : INTEGER; VAR String : ARRAY OF CHAR) : BOOLEAN;
 BEGIN
  RETURN (i >= LEN(String)) OR (String[i] = 0X);
 END End;


PROCEDURE Length*(VAR Strn : ARRAY OF CHAR) : INTEGER;
  VAR i : INTEGER;
 BEGIN i := 0;
   WHILE NOT End(i,Strn) DO INC(i) END(*WHILE*);
   RETURN i
 END Length;


PROCEDURE CAPs* (VAR Strn : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE NOT End(i,Strn) DO Strn[i] := CAP(Strn[i]); INC(i) END(*WHILE*);
 END CAPs;


PROCEDURE FPosC* (c : CHAR; VAR Str : ARRAY OF CHAR) : INTEGER;
 (* returns the position of the first appearence of character c in Str.
    Returns -1 if not found *)
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE Str[i] # c DO INC(i);
    IF End(i,Str) THEN RETURN -1 END(*IF*);
  END(*WHILE*);
  RETURN i
 END FPosC;


PROCEDURE LPosC(c : CHAR; VAR Str : ARRAY OF CHAR) : INTEGER;
  VAR i : INTEGER;
 BEGIN
  i := Length(Str)-1;
  WHILE (i >= 0) AND (Str[i] # c) DO DEC(i) END(*WHILE*);
  RETURN i
 END LPosC;


PROCEDURE AppendC*(c : CHAR; VAR Str : ARRAY OF CHAR);
  VAR i,j : INTEGER;
 BEGIN
  i := Length(Str);
  IF i < LEN(Str) THEN Str[i] := c; INC(i);
    IF i < LEN(Str) THEN Str[i] := 0X END ;
  END(*IF*);
 END AppendC;


PROCEDURE SetEnd(i : INTEGER; VAR String : ARRAY OF CHAR);
 BEGIN
  IF i < LEN(String) THEN String[i] := 0X END(*IF*);
 END SetEnd;


PROCEDURE Append*(Str1 : ARRAY OF CHAR; VAR Str2 : ARRAY OF CHAR);
  VAR i,j : INTEGER;
 BEGIN
  i := Length(Str2);
  j := 0;
  WHILE NOT End(j,Str1) DO
    IF i >= LEN(Str2) THEN RETURN END(*IF*);
    Str2[i] := Str1[j]; INC(i); INC(j);
  END(*WHILE*);
  SetEnd(i,Str2);
 END Append;


PROCEDURE Excerpt*(BPos,EPos : INTEGER; VAR Str1,Str2 : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE (i < LEN(Str2)) AND (BPos < LEN(Str1)) AND (BPos < EPos) DO
    Str2[i] := Str1[BPos]; INC(i); INC(BPos);
  END(*WHILE*);
  SetEnd(i,Str2);
 END Excerpt;


PROCEDURE Write2(VAR Str1 : ARRAY OF CHAR; Pos : INTEGER;
                 VAR Str2 : ARRAY OF CHAR) : INTEGER;
  VAR i : INTEGER;
      e : BOOLEAN;
 BEGIN
  i := 0; e := FALSE;
  WHILE NOT End(i,Str1) DO
    IF Str2[Pos] = 0X THEN e := TRUE END(*IF*);
    Str2[Pos] := Str1[i]; INC(Pos); INC(i);
  END(*WHILE*);
  IF e THEN RETURN Pos ELSE RETURN -1 END(*IF*);
 END Write2;

PROCEDURE Insert(Str1 : ARRAY OF CHAR; Pos : INTEGER;
                   VAR Str2 : ARRAY OF CHAR);
  VAR i,j : INTEGER;
 BEGIN
  i := Length(Str2);
  j := i + Length(Str1);
  IF j <= LEN(Str2) THEN
    WHILE i >= Pos DO
      Str2[j] := Str2[i]; DEC(i); DEC(j);
    END(*WHILE*);
    i := Write2(Str1,Pos,Str2);
  END(*IF*);
 END Insert;


PROCEDURE Delete(BPos,EPos : INTEGER; VAR Strn : ARRAY OF CHAR);
  VAR i : INTEGER;
 BEGIN
  i := Length(Strn);
  IF (BPos <= EPos) AND (EPos <= i) THEN
    REPEAT
      Strn[BPos] := Strn[EPos]; INC(BPos); INC(EPos);
    UNTIL EPos >= i;
    SetEnd(BPos,Strn);
  END(*IF*);
 END Delete;

(*---------------------------NumStr-------------------------------------*)

PROCEDURE Chr(Num : INTEGER) : CHAR;
 BEGIN
  IF Num > 9 THEN RETURN CHR(Num + 37H) ELSE RETURN CHR(Num + 30H) END(*IF*);
 END Chr;


PROCEDURE IntToStr* (Number,Base : INTEGER; VAR String : ARRAY OF CHAR);
  VAR i : INTEGER;
      Neg : BOOLEAN;
      s : ARRAY 22 OF CHAR;
 BEGIN
  Neg := Number < 0;
  IF Neg THEN Number := -Number END(*IF*);
  i := 9;
  IF Number = 0 THEN String[0] := "0"; String[1] := 0X
  ELSE
    WHILE (i >= 0) AND (Number # 0) DO
      s[i] := Chr(Number MOD Base);
      DEC(i); Number := Number DIV Base;
    END(*WHILE*);
    IF Neg AND (i >= 0) THEN s[i] := "-" ELSE INC(i) END(*IF*);
    Excerpt(i,10,s,String);
  END(*IF*);
 END IntToStr;

(*---------------------------Filename-----------------------------------*)

PROCEDURE SetExt* (Ext : ARRAY OF CHAR; VAR FullName : ARRAY OF CHAR);
  (*
   * set new extension Ext in FullName.
   *)
  VAR i,j : INTEGER;
 BEGIN
  i := LPosC("\",FullName);
  j := LPosC("/",FullName);
  IF i < j THEN i := j END;
  j := LPosC(".",FullName);
  IF j > i THEN FullName[j+1] := 0X
  ELSE AppendC(".",FullName) END(*IF*);
  Append(Ext,FullName);
 END SetExt;


PROCEDURE GetName* (VAR FullName,Name : ARRAY OF CHAR);
  (*
   * return name (with extension) of FullName in Name.
   *)
  VAR i : INTEGER;
 BEGIN
  i := LPosC("\",FullName) + 1;
  IF i = 0 THEN
    i := LPosC("/",FullName) + 1;
  END;
  Excerpt(i,i + 12,FullName,Name);
 END GetName;

(*---------------------------Environment--------------------------------*)

PROCEDURE Compare(VAR Env1,Env2 : ARRAY OF CHAR; VAR Pos : INTEGER) : BOOLEAN;
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE (Env1[i] = Env2[i]) DO INC(i);
    IF (Env2[i] = "=") AND ((Env1[i] = "=") OR (Env1[i] = 0X)) THEN
      Pos := i+1; RETURN TRUE
    END;
  END;
  RETURN FALSE
 END Compare;

(*$-y *)

PROCEDURE ReadStr*(Name : ARRAY OF CHAR; VAR String : ARRAY OF CHAR) : BOOLEAN;
  VAR p : POINTER TO ARRAY 100 OF CHAR;
      i : INTEGER;
 BEGIN
  p := Sys.Basepage.Env;
  WHILE p[0] # 0X DO
    IF Compare(Name,p^,i) THEN INC(p,LONG(i)); COPY(p^,String);
      RETURN TRUE
    END;
    INC(p,LONG(Length(p^) + 1));
  END;
  RETURN FALSE;
 END ReadStr;

(*$+y *)

(*---------------------------File---------------------------------------*)

PROCEDURE- Fsfirst(Attr : INTEGER; Name : LONGINT) : INTEGER 78,1;

PROCEDURE- Setdta* (DtaAdr : S.PTR) 26,1;

PROCEDURE- Getdta* () : S.PTR 47,1;

PROCEDURE- Fopen(Mode : INTEGER; Name : S.PTR) : INTEGER 61,1;

PROCEDURE- Fclose(Handle : INTEGER) : INTEGER 62,1;

PROCEDURE- Fread(Buffer,Count : LONGINT; Handle : INTEGER) : LONGINT 63,1;

PROCEDURE- Fsnext() : INTEGER 79,1;

PROCEDURE- Fdatime(Mode,Handle : INTEGER; Buf : LONGINT) 87,1;


PROCEDURE Sfirst(VAR Name : ARRAY OF CHAR; Attribs : SET) : BOOLEAN;
 BEGIN RETURN Fsfirst( SHORT(S.VAL(LONGINT,Attribs)), S.ADR(Name) ) >= 0
 END Sfirst;


PROCEDURE Snext() : BOOLEAN;
 BEGIN RETURN Fsnext() >= 0
 END Snext;


PROCEDURE Search(VAR Name : ARRAY OF CHAR; VAR Length : LONGINT) : BOOLEAN;
  (* searches a file, returns its length and TRUE if found *)
  VAR Ptr : dta;
 BEGIN
  Ptr := Getdta();
  IF Sfirst(Name,{0}) THEN Length := Ptr^.Length; RETURN TRUE END;
  RETURN FALSE
 END Search;


PROCEDURE Open*(VAR Name : ARRAY OF CHAR; Mode : INTEGER; VAR Handle  : INTEGER)
               : BOOLEAN;
 BEGIN
  Handle := Fopen( Mode, S.ADR(Name) );
  RETURN Handle >= 0
 END Open;


PROCEDURE Close*(Handle : INTEGER);
 BEGIN
  S.VOID( Fclose(Handle) );
 END Close;


PROCEDURE Read(Handle : INTEGER; VAR Count : LONGINT; Buffer : S.PTR)
                 : BOOLEAN;
 BEGIN
  Count := Fread(Buffer,Count,Handle);
  RETURN Count >= 0
 END Read;


PROCEDURE Datime* (Handle : INTEGER; VAR DateTime : datime; Mode : INTEGER);
 BEGIN Fdatime( Mode, Handle, S.ADR(DateTime) );
 END Datime;

(*$-y *)

PROCEDURE Load* (Name : ARRAY OF CHAR; BegSpace,EndSpace : LONGINT;
                 VAR Begad : S.PTR; VAR Length : LONGINT) : BOOLEAN;
  VAR Handle : INTEGER;
      Ret : BOOLEAN;
 BEGIN
  IF Search(Name,Length) THEN
    S.NEW(Begad,Length + BegSpace + EndSpace);
    IF (Begad # 0) AND Open(Name,0,Handle) THEN
      Ret := Read(Handle,Length,Begad + BegSpace);
      Close(Handle); RETURN Ret
    END(*IF*);
  END(*IF*);
  RETURN FALSE
 END Load;

(*$+y *)

(*---------------------------Paths--------------------------------------*)

PROCEDURE- Dgetdrv() : INTEGER 25,1;

PROCEDURE- Dgetpath(Drive : INTEGER; Path : S.PTR) : INTEGER 71,1;


PROCEDURE PathsGet*(Paths : Pathspath; Name : ARRAY OF CHAR; Attribs : SET;
               VAR FullName : ARRAY OF CHAR) : BOOLEAN;
  VAR Drv,i : INTEGER; fn : path; p : Pathspath;
 BEGIN
  IF Sfirst(Name,Attribs) THEN
    IF Name[1] # ":" THEN
      Drv := Dgetdrv(); i := Dgetpath(0,S.ADR(FullName));
      Insert("A:",0,FullName); FullName[0] := CHR(Drv + 41H);
      AppendC("\",FullName); Append(Name,FullName);
    ELSE COPY(Name, FullName)
    END;
    RETURN TRUE
  END(*IF*);
  GetName(Name,Name);
  p := Paths;
  WHILE p # NIL DO
    COPY(p.Path,fn); Append(Name,fn);
    IF Sfirst(fn,Attribs) THEN COPY(fn,FullName); RETURN TRUE END ;
    p := p.Next
  END(*WHILE*);
  RETURN FALSE
 END PathsGet;


PROCEDURE PathsRead*(VarName : ARRAY OF CHAR; VAR Paths : Pathspath);
  VAR Def : ARRAY 200 OF CHAR; i,j : INTEGER;
      Path : path;
      paths,p : Pathspath;

  PROCEDURE Add(VAR PathDef : ARRAY OF CHAR);
    VAR p : Pathspath;
        Path : path;
   BEGIN
    i := 0;
    WHILE (PathDef[i] # 0X) DO
      IF PathDef[i] = "*" THEN
        IF (PathDef[i-1] = "\") AND (PathDef[i+1] = "\") AND (PathDef[i+2] = 0X) THEN
          COPY(PathDef, Path);
          PathDef[i] := 0X; (* for appending *)
          Path[i+1] := 0X; (* for search *)
          IF Sfirst(Path, {4}) THEN
            REPEAT
              IF Dta.Name[0] # "." THEN
                COPY(PathDef, Path);
                Append( Dta.Name, Path); AppendC("\", Path);
                NEW(p); p.Next := Paths; Paths := p;
                COPY(Path, p.Path);
              END;
            UNTIL NOT Snext();
          END;
        ELSE
          WriteString( "Error in path definition: ");
          WriteString( PathDef); WriteLn;
        END;
        RETURN
      END;
      INC(i);
    END;
    NEW(p); p.Next := Paths; Paths := p;
    COPY(PathDef, p.Path);
   END Add;

 BEGIN
  Paths := NIL; Setdta( S.ADR(Dta) );
  IF ReadStr(VarName,Def) AND (Def[0] # 0X) THEN
    i := 0; j := 0;
    REPEAT
      WHILE (Def[j] # ",") AND (Def[j] # ";") AND (Def[j] # 0X) DO INC(j) END;
      Excerpt(i,j,Def,Path);
      IF Path[0] = "&" THEN
        Delete(0, 1, Path);
        PathsRead(Path, paths);
        IF paths # NIL THEN
          p := paths;
          WHILE p.Next # NIL DO
            p := p.Next;
          END;
          p.Next := Paths;
          Paths := paths;
        END;
      ELSE
        IF Def[j-1] # "\" THEN AppendC( "\", Path) END;
        Add(Path);
      END;
      INC(j); i := j;
    UNTIL Def[j-1] = 0X;
  END;
 END PathsRead;

(*---------------------------ObjFile------------------------------------*)

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
  RETURN obj;
 END New;


PROCEDURE (obj: ObjFile) TextAdr*() : LONGINT;
(*
 Return the address of the machine code.
 *)
 BEGIN
  RETURN S.ADR( obj.header.code );
 END TextAdr;


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


PROCEDURE (obj: ObjFile) SymbolsDo*(proc: SymbolProc);
(*
 Call proc with every symbol of obj.
 *)
  VAR
    sym: Symbol;
    tsym, psym: TOSSymbol;
 BEGIN
  tsym := obj.symbols;
  WHILE tsym.name[0] # 0X DO
    COPY(tsym.name, sym.name);
    sym.type := S.VAL( SET, LONG( S.LONG( tsym.type)));
    sym.value := tsym.value;
    sym.original := tsym;
    sym.obj := obj;
    psym := tsym;
    IF tsym.magic = 48H THEN
      Append(tsym.xname, sym.name);
      INC(tsym, 28)
    ELSE
      INC(tsym, 14);
    END;
    proc(sym);
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

(*---------------------------Parameter----------------------------------*)

PROCEDURE- Pterm0() 0,1;


PROCEDURE ReadOptions(VAR string: ARRAY OF CHAR) : BOOLEAN;
 (*
  * reads options from string and returns true if it contained options.
  *)
  VAR
    i : INTEGER;

  PROCEDURE Error(opt : CHAR);
   BEGIN
    WriteString("Unknown option '"); WriteChar(opt);
    WriteString("'. Aborted."); WriteLn;
    Pterm0();
   END Error;

  PROCEDURE ReadString(VAR string: ARRAY OF CHAR; VAR i : INTEGER;
                       VAR read : ARRAY OF CHAR);
    VAR
      j : INTEGER;
   BEGIN
    INC(i);
    j := 0;
    WHILE (string[i] # 0X) AND (string[i] # "+") AND (string[i] # "-") DO
      read[j] := string[i];
      INC( i); INC( j);
    END(*WHILE*);
    DEC(i);
   END ReadString;

 BEGIN
  i := 0;
  LOOP
    IF string[i] = "-" THEN	(* set variable *)
      LOOP
        INC( i);
        CASE CAP(string[i]) OF
          "E":
            ReadString(string, i, objExt);
        | "O":
            ReadString(string, i, opVar);
        | " ", 0X:
            EXIT
        | "-":
        ELSE
          Error(string[i]);
        END(*CASE*);
      END(*LOOP*);
    ELSE
      EXIT
    END(*IF*);
  END(*LOOP*);
  RETURN i # 0;
 END ReadOptions;


PROCEDURE InitPar*;
  VAR
    s : ARRAY 200 OF CHAR;
 BEGIN
  (* set default values *)
  objExt := "OBJ";
  opVar := "LOADPATH";

  (* read standard options from environment *)
  IF ReadStr("OLDOPT", s) AND NOT ReadOptions(s) THEN
    WriteString("Env. variable OLDOPT has no valid options. Aborted.");
    WriteLn;
    Pterm0;
  END(*IF*);
  PathsRead( opVar, objPaths);
 END InitPar;


BEGIN
  Setdta( S.ADR(Dta) );
END O2LS.