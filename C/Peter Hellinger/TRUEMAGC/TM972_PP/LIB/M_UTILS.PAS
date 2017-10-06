UNIT M_Utils;

INTERFACE

USES Basics, AES;

TYPE    AnyType =       RECORD
                         CASE x: INTEGER OF
                          0:  (int:  LONGINT);
                          2:  (hword: WORD; lword: WORD);
                          4:  (b4: BYTE; b3: BYTE; b2: BYTE; b1: BYTE);
                        END;

PROCEDURE InclFlag (tree: POINTER; entry: INTEGER; bit: WordBits);
PROCEDURE ExclFlag (tree: POINTER; entry: INTEGER; bit: WordBits);
PROCEDURE SetFlag (tree: POINTER; entry: INTEGER; bit: WordBits; setit: BOOLEAN);
FUNCTION  InFlag (tree: POINTER; entry: INTEGER; bit: WordBits): BOOLEAN;
PROCEDURE InclState (tree: POINTER; entry: INTEGER; bit: WordBits);
PROCEDURE ExclState (tree: POINTER; entry: INTEGER; bit: WordBits);
FUNCTION  InState (tree: POINTER; entry: INTEGER; bit: WordBits): BOOLEAN;
PROCEDURE SetState (tree: POINTER; entry: INTEGER; bit: WordBits; setit: BOOLEAN);
PROCEDURE ObjcFont (tree: POINTER; entry: INTEGER; typ, id, size: INTEGER);
PROCEDURE ObjcString (tree: POINTER; entry: INTEGER; VAR str: ARRAY OF CHAR);
PROCEDURE ObjcFString (tree: POINTER; entry: INTEGER; VAR str: ARRAY OF CHAR);
PROCEDURE SetObjcString (tree: POINTER; entry: INTEGER; str: ARRAY OF CHAR);
FUNCTION  ObjcStringAdr (tree: POINTER; entry: INTEGER): POINTER;
PROCEDURE SetObjcStringAdr (tree: POINTER; entry: INTEGER; str: POINTER);
PROCEDURE ObjcStrLen (tree: POINTER; entry: INTEGER; VAR textLen, tmpltLen: INTEGER);
PROCEDURE ObjcColor (tree: POINTER; entry: INTEGER; VAR inner, text, frame, raster: INTEGER);
PROCEDURE SetObjcColor (tree: POINTER; entry, inner, text, frame, raster: INTEGER);
PROCEDURE ObjcPos (tree: POINTER; entry: INTEGER; VAR x, y: INTEGER);
FUNCTION  ObjcParent (tree: POINTER; entry: INTEGER): INTEGER;
PROCEDURE ObjcRect (tree: POINTER; entry: INTEGER; VAR rect: tRect);
PROCEDURE SetObjcRect (tree: POINTER; entry: INTEGER; rect: tRect);
PROCEDURE ObjcArea (tree: POINTER; entry: INTEGER; VAR rect: tRect);
FUNCTION  ObjcFrame (tree: POINTER; entry: INTEGER): INTEGER;
PROCEDURE CalcArea (tree: POINTER; entry: INTEGER; VAR rect: tRect);
PROCEDURE HideObjctree (tree: POINTER; entry: INTEGER; hide: BOOLEAN);

TYPE    ScanType = (SearchType, SearchState, SearchFlags);

FUNCTION  ScanFlags (tree: POINTER; styp: ScanType; entry, typ: INTEGER; flag: WordBits): INTEGER;
PROCEDURE SetObjc (tree: POINTER; num, parent, typ: INTEGER;
                   flags, state: BITSET;  spec: Objcspec; 
                   obx, oby, obw, obh: INTEGER; add: BOOLEAN);
FUNCTION  GetObjcspec (tree: POINTER; entry: INTEGER): PtrObjcspec;

TYPE BounceMode = (Left, Right, Both);

PROCEDURE Bounce (mode: BounceMode);
PROCEDURE AbsRect (VAR rect: tRect);
PROCEDURE RelRect (VAR rect: tRect);
PROCEDURE RectToVars (rect: tRect;  abs: BOOLEAN; VAR x, y, w, h: INTEGER);
PROCEDURE VarsToRect (x, y, w, h: INTEGER; abs: BOOLEAN; VAR rect: tRect);
PROCEDURE AbsRectToVars (rect: tRect;  abs: BOOLEAN; VAR x, y, w, h: INTEGER);
PROCEDURE AbsVarsToRect (x, y, w, h: INTEGER; abs: BOOLEAN; VAR rect: tRect);
PROCEDURE DecAbsRect (VAR r: tRect; num: INTEGER);
PROCEDURE DecRelRect (VAR r: tRect; num: INTEGER);
PROCEDURE IncAbsRect (VAR r: tRect; num: INTEGER);
PROCEDURE IncRelRect (VAR r: tRect; num: INTEGER);
FUNCTION  InAbsRect (x, y: INTEGER; rect: tRect): BOOLEAN;
FUNCTION  InRelRect (x, y: INTEGER; rect: tRect): BOOLEAN;
PROCEDURE CalcSlider (max, act, fpos: LONGINT; VAR pos, size: INTEGER);
FUNCTION  CalcDocPos (max, act, spos: LONGINT): LONGINT;
FUNCTION  LCalcDocPos (max, act, spos: LONGINT): LONGINT;

IMPLEMENTATION

USES M_Sys;

PROCEDURE InclFlag (tree: POINTER; entry: INTEGER; bit: WordBits);
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 InclBitset (dial^[entry].obFlags, bit);
END (*InclFlag*);

PROCEDURE ExclFlag (tree: POINTER; entry: INTEGER; bit: WordBits);
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 ExclBitset (dial^[entry].obFlags, bit);
END (*ExclFlag*);

PROCEDURE SetFlag (tree: POINTER; entry: INTEGER; bit: WordBits; setit: BOOLEAN);
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 IF setit THEN  InclBitset (dial^[entry].obFlags, bit)
          ELSE  ExclBitset (dial^[entry].obFlags, bit);
END (*SetFlag*);

FUNCTION InFlag (tree: POINTER; entry: INTEGER; bit: WordBits): BOOLEAN;
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 InFlag:= bit IN dial^[entry].obFlags;
END (*InFlag*);

PROCEDURE InclState (tree: POINTER; entry: INTEGER; bit: WordBits);
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 InclBitset (dial^[entry].obState, bit);
END (*InclState*);

PROCEDURE ExclState (tree: POINTER; entry: INTEGER; bit: WordBits);
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 ExclBitset (dial^[entry].obState, bit);
END (*ExclState*);

PROCEDURE SetState (tree: POINTER; entry: INTEGER; bit: WordBits; setit: BOOLEAN);
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 IF setit THEN  InclBitset (dial^[entry].obState, bit)
          ELSE  ExclBitset (dial^[entry].obState, bit);
END (*SetState*);

FUNCTION InState (tree: POINTER; entry: INTEGER; bit: WordBits): BOOLEAN;
VAR dial: tObjcTree ABSOLUTE tree;
BEGIN
 InState:= bit IN dial^[entry].obState;
END (*InState*);

PROCEDURE ObjcString (tree: POINTER; entry: INTEGER; VAR str: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (str);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2208);
END (*ObjcString*);

PROCEDURE ObjcFString (tree: POINTER; entry: INTEGER; VAR str: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (str);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2240);
END (*ObjcFString*);

FUNCTION ObjcStringAdr (tree: POINTER; entry: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2210);
 ObjcStringAdr:= App^.MagicPB^.AddrOut[0];
END (*ObjcStringAdr*);

PROCEDURE SetObjcString (tree: POINTER; entry: INTEGER; str: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (str);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2209);
END (*SetObjcString*);

PROCEDURE SetObjcStringAdr (tree: POINTER; entry: INTEGER; str: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= str;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2211);
END (*SetObjcStringAdr*);

PROCEDURE ObjcStrLen (tree: POINTER; entry: INTEGER;
                      VAR textLen, tmpltLen: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2212);
 textlen:= App^.MagicPB^.IntOut[0];
 tmpltlen:= App^.MagicPB^.IntOut[1];
END (*ObjcStrLen*);

PROCEDURE ObjcColor (tree: POINTER; entry: INTEGER;
                     VAR inner, text, frame, raster: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2213);
 inner:= App^.MagicPB^.IntOut[0];
 text:= App^.MagicPB^.IntOut[1];
 frame:= App^.MagicPB^.IntOut[2];
 raster:= App^.MagicPB^.IntOut[3];
END {ObjcColor};

PROCEDURE SetObjcColor (tree: POINTER;
                        entry, inner, text, frame, raster: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 App^.MagicPB^.IntIn[1]:= inner;
 App^.MagicPB^.IntIn[2]:= text;
 App^.MagicPB^.IntIn[3]:= frame;
 App^.MagicPB^.IntIn[4]:= raster;
 CallMagic (2214);
END {SetObjcColor};

FUNCTION ObjcParent (tree: POINTER; entry: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2216);
 ObjcParent:=  App^.MagicPB^.IntOut[0];
END (*ObjcParent*);
        
PROCEDURE ObjcPos (tree: POINTER; entry: INTEGER; VAR x, y: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2215);
 x:=  App^.MagicPB^.IntOut[0];
 y:=  App^.MagicPB^.IntOut[1];
END (*ObjcPos*);

PROCEDURE ObjcArea (tree: POINTER; entry: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2219);
END (*ObjcArea*);

PROCEDURE ObjcRect (tree: POINTER; entry: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2217);
END (*ObjcRect*);

PROCEDURE SetObjcRect (tree: POINTER; entry: INTEGER; rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2218);
END (*SetObjcRect*);

FUNCTION ObjcFrame (tree: POINTER; entry: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2220);
 ObjcFrame:= App^.MagicPB^.IntOut[0];
END (*ObjcFrame*);

PROCEDURE CalcArea (tree: POINTER; entry: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2221);
END (*CalcArea*);

FUNCTION ScanFlags (tree: POINTER; styp: ScanType;
                    entry, typ: INTEGER; flag: WordBits): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= ORD (styp);
 App^.MagicPB^.IntIn[1]:= entry;
 App^.MagicPB^.IntIn[2]:= typ;
 App^.MagicPB^.IntIn[3]:= ORD (flag);
 CallMagic (2222);
 ScanFlags:= App^.MagicPB^.IntOut[0];
END (*ScanFlags*);

PROCEDURE SetObjc (tree: POINTER; num, parent, typ: INTEGER;
                   flags, state: BITSET;  spec: Objcspec; 
                   obx, oby, obw, obh: INTEGER; add: BOOLEAN);
VAR f: INTEGER ABSOLUTE flags;
    s: INTEGER ABSOLUTE state;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.LongIn[0]:= LONGINT (spec.address);
 App^.MagicPB^.IntIn[0]:= num;
 App^.MagicPB^.IntIn[1]:= parent;
 App^.MagicPB^.IntIn[2]:= typ;
 App^.MagicPB^.IntIn[3]:= f;
 App^.MagicPB^.IntIn[4]:= s;
 App^.MagicPB^.IntIn[5]:= obx;
 App^.MagicPB^.IntIn[6]:= oby;
 App^.MagicPB^.IntIn[7]:= obw;
 App^.MagicPB^.IntIn[8]:= obh;
 App^.MagicPB^.IntIn[8]:= ORD (add);
 CallMagic (2223);
END (*SetObjc*);

FUNCTION GetObjcspec (tree: POINTER; entry: INTEGER): PtrObjcspec;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (2224); 
 GetObjcspec:= App^.MagicPB^.AddrOut[0];
END (*GetObjcspec*);

PROCEDURE Bounce (mode: BounceMode);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (mode);
 CallMagic (2225);
END (*Bounce*);

PROCEDURE AbsRect (VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 CallMagic (2226);
END (*AbsRect*);

PROCEDURE RelRect (VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 CallMagic (2227);
END (*RelRect*);

PROCEDURE RectToVars (rect: tRect;  abs: BOOLEAN;
                      VAR x, y, w, h: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= ORD (abs);
 CallMagic (2228);
 x:= App^.MagicPB^.IntOut[0];
 y:= App^.MagicPB^.IntOut[1];
 w:= App^.MagicPB^.IntOut[2];
 h:= App^.MagicPB^.IntOut[3];
END (*RectToVars*);

PROCEDURE VarsToRect (x, y, w, h: INTEGER; abs: BOOLEAN;
                      VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= x;
 App^.MagicPB^.IntIn[1]:= y;
 App^.MagicPB^.IntIn[2]:= w;
 App^.MagicPB^.IntIn[3]:= h;
 App^.MagicPB^.IntIn[4]:= ORD (abs);
 CallMagic (2229);
END (*VarsToRect*);

PROCEDURE AbsRectToVars (rect: tRect;  abs: BOOLEAN;
                         VAR x, y, w, h: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= ORD (abs);
 CallMagic (2230);
 x:= App^.MagicPB^.IntOut[0];
 y:= App^.MagicPB^.IntOut[1];
 w:= App^.MagicPB^.IntOut[2];
 h:= App^.MagicPB^.IntOut[3];
END (*AbsRectToVars*);

PROCEDURE AbsVarsToRect (x, y, w, h: INTEGER; abs: BOOLEAN;
                         VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= x;
 App^.MagicPB^.IntIn[1]:= y;
 App^.MagicPB^.IntIn[2]:= w;
 App^.MagicPB^.IntIn[3]:= h;
 App^.MagicPB^.IntIn[4]:= ORD (abs);
 CallMagic (2231);
END (*AbsVarsToRect*);

FUNCTION InAbsRect (x, y: INTEGER; rect: tRect): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= x;
 App^.MagicPB^.IntIn[1]:= y;
 CallMagic (2232);
 InAbsRect:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*InAbsRect*);

FUNCTION InRelRect (x, y: INTEGER; rect: tRect): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= x;
 App^.MagicPB^.IntIn[1]:= y;
 CallMagic (2233);
 InRelRect:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*InRelRect*);

PROCEDURE DecAbsRect (VAR r: tRect; num: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= num;
 CallMagic (2236);
END (*DecAbsRect*);

PROCEDURE DecRelRect (VAR r: tRect; num: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= num;
 CallMagic (2237);
END (*DecRelRect*);

PROCEDURE IncAbsRect (VAR r: tRect; num: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= num;
 CallMagic (2238);
END (*IncAbsRect*);

PROCEDURE IncRelRect (VAR r: tRect; num: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= num;
 CallMagic (2239);
END (*IncRelRect*);

PROCEDURE CalcSlider (max, act, fpos: LONGINT; VAR pos, size: INTEGER);
BEGIN
 App^.MagicPB^.LongIn[0]:= max;
 App^.MagicPB^.LongIn[1]:= act;
 App^.MagicPB^.LongIn[2]:= fpos;
 CallMagic (2242);
 pos:= App^.MagicPB^.IntOut[0];
 size:= App^.MagicPB^.IntOut[1];
END (*CalcSlider*);

FUNCTION CalcDocPos (max, act, spos: LONGINT): LONGINT;
BEGIN
 App^.MagicPB^.IntIn[0]:= max;
 App^.MagicPB^.IntIn[1]:= act;
 App^.MagicPB^.IntIn[2]:= spos;
 CallMagic (2243);
 CalcDocPos:= App^.MagicPB^.LongOut[0];
END (*CalcDocPos*);

PROCEDURE HideObjctree (tree: POINTER; entry: INTEGER; hide: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 App^.MagicPB^.IntIn[1]:= ORD (hide);
 CallMagic (2241);
END (*hideObjctree*);

PROCEDURE ObjcFont (tree: POINTER; entry, typ, id, size: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 App^.MagicPB^.IntIn[1]:= typ;
 App^.MagicPB^.IntIn[2]:= id;
 App^.MagicPB^.IntIn[3]:= size;
 CallMagic (2244);
END (*ObjcFont*);

FUNCTION LCalcDocPos (max, act, spos: LONGINT): LONGINT;
BEGIN
 App^.MagicPB^.LongIn[0]:= max;
 App^.MagicPB^.LongIn[1]:= act;
 App^.MagicPB^.LongIn[2]:= spos;
 CallMagic (2245);
 LCalcDocPos:= App^.MagicPB^.LongOut[0];
END (*LCalcDocPos*);

END (*M_Utils*).
