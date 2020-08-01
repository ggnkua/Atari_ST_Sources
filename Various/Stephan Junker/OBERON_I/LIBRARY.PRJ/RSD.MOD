MODULE RSD; (* SJ 19.2.95 *)

(*
 Supports Robert Federle's resident symbol driver
 *)


IMPORT
  S:=SYSTEM, Cookie;


TYPE
  IntPtr* = POINTER TO ARRAY 16000 OF INTEGER;

  SymbolHeaderPtr* = POINTER TO SymbolHeader;
  SymbolHeader* = RECORD
    programName* : ARRAY 14 OF CHAR;
    unknown*     : INTEGER;  (* not defined, but was there, value 4 *)
    symbolCount* : INTEGER;
    firstData*   : INTEGER;
    firstBss*    : INTEGER;
    symbolValues*: IntPtr;
    symbolNames* : IntPtr;
    symbolData*  : POINTER TO ARRAY 32000 OF S.BYTE;
    firstAddress*: S.PTR;
    lastAddress* : S.PTR;
    basepage*    : S.PTR;
    next*        : SymbolHeaderPtr;
  END;

  SymbolPtr* = POINTER TO Symbol;
  Symbol* = RECORD
    value*: LONGINT;
    type* : S.BYTE;
    name* : ARRAY 100 OF CHAR;  (* just as long as needed and 0-terminated *)
  END;

  SymbolCookiePtr* = POINTER TO SymbolCookie;
  SymbolCookie* = RECORD
    version-, revision- : INTEGER;
    first- : SymbolHeaderPtr;
    getSymbolName, getSymbolValue,
    addSymbolTable, removeSymbolTable : PROCEDURE ;
  END;



PROCEDURE GetCookie*() : SymbolCookiePtr;
(*
 Answer the cookie structure of the RSD or NIL if it is not installed.
 *)
  VAR
    cookie: LONGINT;
 BEGIN
  IF Cookie.Search("SYMB", cookie) THEN
    RETURN S.VAL( SymbolCookiePtr, cookie);
  ELSE
    RETURN NIL;
  END;
 END GetCookie;


PROCEDURE FirstHeader*() : SymbolHeaderPtr;
(*
 Answer the first header pointer of RSD or NIL if none.
 *)
  VAR
    cookie: SymbolCookiePtr;
 BEGIN
  cookie := GetCookie();
  IF cookie # NIL THEN
    RETURN cookie.first;
  ELSE
    RETURN NIL;
  END;
 END FirstHeader;


PROCEDURE GetSymbolName*(
    cookie: SymbolCookiePtr; adr: S.PTR;
    VAR data: SymbolPtr; VAR header: SymbolHeaderPtr) : BOOLEAN;
(*
 Answer the symbol and the symbol table belonging to adr. Answer true if
 found.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  adr,D0
    MOVE.L  cookie,A0
    MOVE.L  8(A0),A0
    JSR     (A0)
    TST.L   D0
    BNE     NotFound
    MOVE.L  header,A2
    MOVE.L  A1,(A2)
    MOVE.L  data,A2
    MOVE.L  A0,(A2)
    MOVEQ   #1,D0
    RETURN
  NotFound:
    MOVEQ   #0,D0
    RETURN
  END;
 END GetSymbolName;


PROCEDURE GetSymbolValue*(
    cookie: SymbolCookiePtr; VAR progName, symName: ARRAY OF CHAR;
    VAR data: SymbolPtr; VAR header: SymbolHeaderPtr) : BOOLEAN;
(*
 Answer the symbol and the symbol table belonging to symName in progName.
 Answer true if found.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  symName,A0
    MOVE.L  progName,A1
    MOVE.L  cookie,A2
    MOVE.L  12(A2),A2
    JSR     (A2)
    TST.L   D0
    BNE     NotFound
    MOVE.L  header,A2
    MOVE.L  A1,(A2)
    MOVE.L  data,A2
    MOVE.L  A0,(A2)
    MOVEQ   #1,D0
    RETURN
  NotFound:
    MOVEQ   #0,D0
    RETURN
  END;
 END GetSymbolValue;


PROCEDURE AddSymbolTable*(
    cookie: SymbolCookiePtr; VAR progName: ARRAY OF CHAR;
    basepage: S.PTR) : BOOLEAN;
(*
 Answer true if the symbol table of progName with that basepage could be
 loaded.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  progName,A0
    MOVE.L  basepage,A1
    MOVE.L  cookie,A2
    MOVE.L  16(A2),A2
    JSR     (A2)
    TST.L   D0
    SEQ     D0
    NEG.B   D0
    RETURN
  END;
 END AddSymbolTable;


PROCEDURE RemoveSymbolTable*(
    cookie: SymbolCookiePtr; VAR progName: ARRAY OF CHAR) : BOOLEAN;
(*
 Answer true if the symbol table of progName could be removed.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  progName,A0
    MOVE.L  cookie,A2
    MOVE.L  20(A2),A2
    JSR     (A2)
    TST.L   D0
    SEQ     D0
    NEG.B   D0
    RETURN
  END;
 END RemoveSymbolTable;


END RSD.