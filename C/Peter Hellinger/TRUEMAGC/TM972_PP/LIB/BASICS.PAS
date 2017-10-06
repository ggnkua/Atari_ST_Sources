UNIT Basics;

INTERFACE

CONST   Null =       $00000000;

TYPE    ByteBits =   (bBit0, bBit1, bBit2, bBit3, bBit4, bBit5, bBit6, bBit7);
        BYTESET =    SET OF Bytebits;

TYPE    WordBits =   (Bit8, Bit9, Bit10, Bit11, Bit12, Bit13, Bit14, Bit15,
                      Bit0, Bit1, Bit2, Bit3, Bit4, Bit5, Bit6, Bit7);
        BITSET =     SET OF WordBits;

TYPE    LongBits =   (lBit24, lBit25, lBit26, lBit27, lBit28, lBit29, lBit30, lBit31,
                      lBit16, lBit17, lBit18, lBit19, lBit20, lBit21, lBit22, lBit23,
                      lBit8, lBit9, lBit10, lBit11, lBit12, lBit13, lBit14, lBit15,
                      lBit0, lBit1, lBit2, lBit3, lBit4, lBit5, lBit6, lBit7);
        LONGBITSET = SET OF LongBits;


TYPE    tRect =         RECORD
                         x, y, w, h: INTEGER;
                        END;

TYPE    tPxyRect =      RECORD
                         x1, y1: INTEGER;
                         x2, y2: INTEGER;
                         x3, y3: INTEGER;
                         x4, y4: INTEGER;
                         x5, y5: INTEGER;
                         x6, y6: INTEGER;
                         x7, y7: INTEGER;
                         x8, y8: INTEGER;
                        END;

TYPE    PtrCSTRING =    ^CSTRING;
        CSTRING =       ARRAY [0..255] OF CHAR;

TYPE    PtrLCString =   ^LCSTRING;
        LCSTRING =      ARRAY [0..$FFFF] OF CHAR;

TYPE    tAESGLOBAL =    RECORD
                         apVersion:     INTEGER; (* globl 0 *)
                         apCount:       INTEGER; (* globl 1 *)
                         apId:          INTEGER; (* globl 2 *)
                         apPprivate:    LONGINT; (* globl 3/4 *)
                         apPtree:       POINTER; (* globl 5/6*)
                         apPmem:        POINTER; (* globl 7/8 *)
                         apLmem:        INTEGER; (* globl 9 *)
                         apNplanes:     INTEGER; (* globl 10 *)
                         Reserved1:     INTEGER; (* globl 11 *)
                         Reserved2:     INTEGER; (* globl 12 *)
                         apBvdisk:      WORD;    (* globl 13 *)
                         apBvhard:      WORD;    (* globl 14 *)
                        END;

TYPE    tControl =      RECORD
                         opcode:        INTEGER;
                         sizeIntIn:     INTEGER;
                         sizeIntOut:    INTEGER;
                         sizeAddrIn:    INTEGER;
                         sizeAddrOut:   INTEGER;
                        END;

TYPE    tIntIn =        ARRAY [0..16] OF INTEGER;
        tIntOut =       ARRAY [0.. 7] OF INTEGER;
        tAddrIn =       ARRAY [0.. 2] OF POINTER;
        tAddrOut =      ARRAY [0.. 1] OF POINTER;
        tCtrlArray =    ARRAY [0..512] OF INTEGER;
        tVDICtrlArray = ARRAY [0.. 11] OF INTEGER;

TYPE    PtrAESPB =      ^AESParablock;
        AESParablock =  RECORD
                         cbControl: ^tControl;
                         cbPglobal: ^tAESGLOBAL;
                         cbPintin:  ^tIntIn;
                         cbPintout: ^tIntOut;
                         cbPadrin:  ^tAddrIn;
                         cbPadrout: ^tAddrOut;
                        END;

TYPE    PtrVDIPB =      ^VDIParablock;
        VDIParablock =  RECORD
                         control:   ^tVDICtrlArray;
                         intin:     ^tCtrlArray;
                         ptsin:     ^tCtrlArray;
                         intout:    ^tCtrlArray;
                         ptsout:    ^tCtrlArray;
                        END;


FUNCTION  Min           (i1, i2: INTEGER): INTEGER;
FUNCTION  Max           (i1, i2: INTEGER): INTEGER;
FUNCTION  SwapLong      (value: LONGINT): LONGINT;
FUNCTION  HexByte       (b: BYTE): STRING;
FUNCTION  HexWord       (w: WORD): STRING;
FUNCTION  HexLong       (l: LONGINT): STRING;
FUNCTION  LongText      (l: LONGINT): STRING;
FUNCTION  TextLong      (s: STRING): LONGINT;
PROCEDURE LongCText     (l: LONGINT; VAR cs: ARRAY OF CHAR);
PROCEDURE KillBlanks    (leading: BOOLEAN; VAR s: STRING);

PROCEDURE ByteToByteset (value: BYTE; VAR bset: BYTESET);
PROCEDURE ByteToBitset  (value: BYTE; VAR bset: BITSET);
PROCEDURE ByteToLBitset (value: BYTE; VAR bset: LONGBITSET);
PROCEDURE WordToByteset (value: WORD; VAR bset: BYTESET);
PROCEDURE WordToBitset  (value: WORD; VAR bset: BITSET);
PROCEDURE WordToLBitset (value: WORD; VAR bset: LONGBITSET);
PROCEDURE LongToByteset (value: LONGINT; VAR bset: BYTESET);
PROCEDURE LongToBitset  (value: LONGINT; VAR bset: BITSET);
PROCEDURE LongToLBitset (value: LONGINT; VAR bset: LONGBITSET);
FUNCTION  BytesetToByte (bset: BYTESET): BYTE;
FUNCTION  BitsetToByte  (bset: BITSET): BYTE;
FUNCTION  LBitsetToByte (bset: LONGBITSET): BYTE;
FUNCTION  BytesetToWord (bset: BYTESET): WORD;
FUNCTION  BitsetToWord  (bset: BITSET): WORD;
FUNCTION  LBitsetToWord (bset: LONGBITSET): WORD;
FUNCTION  BytesetToLong (bset: BYTESET): LONGINT;
FUNCTION  BitsetToLong  (bset: BITSET): LONGINT;
FUNCTION  LBitsetToLong (bset: LONGBITSET): LONGINT;

IMPLEMENTATION

{$I COMPOPT.INC}

FUNCTION SwapLong (value: LONGINT): LONGINT;
VAR i: INTEGER;
    swp: RECORD
          CASE BOOLEAN OF
           TRUE: (v: LONGINT);
           FALSE: (h, l: INTEGER);
         END;
BEGIN
 swp.v:= value;
 i:= SWAP (swp.h);
 swp.h:= SWAP (swp.l);
 swp.l:= i;
 SwapLong:= swp.v;
END (*SwapLong*);

FUNCTION Min (i1, i2: INTEGER): INTEGER;
BEGIN
 IF i1 < i2 THEN  Min:= i1  ELSE  Min:= i2;
END (*Min*);

FUNCTION Max (i1, i2: INTEGER): INTEGER;
BEGIN
 IF i1 < i2 THEN  Max:= i2  ELSE  Max:= i1;
END (*Max*);

Const HexDigs: ARRAY [0..15] OF CHAR = '0123456789ABCDEF';

FUNCTION HexByte (b: BYTE): STRING;
VAR bz: BYTE;
BEGIN
 bz:= b AND $F;
 b:= b SHR 4;
 HexByte:= HexDigs [b] + HexDigs [bz];
END (*HexByte*);

FUNCTION HexWord (w: WORD): STRING;
BEGIN
 HexWord:= HexByte (HI (w)) + HexByte (LO (w));
END (*HexWord*);

FUNCTION HexLong (l: LONGINT): STRING;
VAR x: RECORD
        CASE BOOLEAN OF
         TRUE:  (a: LONGINT);
         FALSE: (h, l: WORD;);
       END;
BEGIN
 x.a:= l;
 HexLong:= HexByte (HI (x.h)) + HexByte (LO (x.h)) + HexByte (HI (x.l)) + HexByte (LO (x.l));
END (*HexWord*);

FUNCTION LongText (l: LONGINT): STRING;
VAR x: RECORD
        CASE INTEGER OF
         0: (li: LONGINT);
         1: (h, l: WORD);
         2: (a, b, c, d: CHAR);
       END;
BEGIN
 x.li:= l;
 LongText:= x.a + x.b + x.c + x.d;
END (*LongText*);

FUNCTION TextLong (s: STRING): LONGINT;
VAR x: RECORD
        CASE INTEGER OF
         0: (li: LONGINT);
         1: (h, l: WORD);
         2: (a, b, c, d: CHAR);
       END;
BEGIN
 x.a:= s[1];  x.b:= s[2];  x.c:= s[3];  x.d:= s[4];
 TextLong:= x.li;
END (*TextLong*);

PROCEDURE LongCText (l: LONGINT; VAR cs: ARRAY OF CHAR);
VAR x: RECORD
        CASE INTEGER OF
         0: (li: LONGINT);
         1: (h, l: WORD);
         2: (a, b, c, d: CHAR);
       END;
BEGIN
 x.li:= l;
 cs[0]:= x.a;
 cs[1]:= x.b;
 cs[2]:= x.c;
 cs[3]:= x.d;
END (*LongText*);

PROCEDURE KillBlanks (leading: BOOLEAN; VAR s: STRING);
BEGIN
 IF leading THEN BEGIN
  WHILE (s[1] = ' ') AND (Length (s) > 0) DO  Delete (s, 1, 1);
 END ELSE BEGIN
  WHILE (s[Length(s)] = ' ') AND (Length (s) > 0) DO  Delete (s, Length(s), 1);
 END;
END (*KillBlanks*);

VAR cast:       RECORD
                 CASE INTEGER OF
                  0: (lint: LONGINT);
                  1: (hw, lw: WORD);
                  2: (b1, b2, b3, b4: BYTE);
                  3: (lset: LONGBITSET);
                  4: (hs, ls: BITSET);
                  5: (s1, s2, s3, s4: BYTESET);
                END;

PROCEDURE ByteToByteset (value: BYTE; VAR bset: Byteset);
VAR b: Byteset ABSOLUTE value;
BEGIN
 bset:= b;
END (*ByteToByteset*);

PROCEDURE ByteToBitset (value: BYTE; VAR bset: BITSET);
BEGIN
 cast.lint:= 0;  cast.b4:= value;  bset:= cast.ls;
END (*ByteToBitset*);

PROCEDURE ByteToLBitset (value: BYTE; VAR bset: LONGBITSET);
BEGIN
 cast.lint:= 0;  cast.b4:= value;  bset:= cast.lset;
END (*ByteToLBitset*);

PROCEDURE WordToByteset (value: WORD; VAR bset: Byteset);
BEGIN
 cast.lw:= value;  bset:= cast.s4;
END (*WordToByteset*);

PROCEDURE WordToBitset (value: WORD; VAR bset: BITSET);
VAR b: BITSET ABSOLUTE value;
BEGIN
 bset:= b;
END (*WordToBitset*);

PROCEDURE WordToLBitset (value: WORD; VAR bset: LONGBITSET);
BEGIN
 cast.lint:= 0;  cast.lw:= value;  bset:= cast.lset;
END (*WordToLBitset*);

PROCEDURE LongToByteset (value: LONGINT; VAR bset: Byteset);
BEGIN
 cast.lint:= value;  bset:= cast.s4;
END (*LongToByteset*);

PROCEDURE LongToBitset (value: LONGINT; VAR bset: BITSET);
BEGIN
 cast.lint:= value;  bset:= cast.ls;
END (*LongToBitset*);

PROCEDURE LongToLBitset (value: LONGINT; VAR bset: LONGBITSET);
VAR b: LONGBITSET ABSOLUTE value;
BEGIN
 bset:= b;
END (*LongToLBitset*);

FUNCTION  BytesetToByte (bset: Byteset): BYTE;
VAR b: BYTE ABSOLUTE bset;
BEGIN
 BytesetToByte:= b;
END (*BytesetToByte*);

FUNCTION  BitsetToByte  (bset: BITSET): BYTE;
BEGIN
 cast.ls:= bset;  BitsetToByte:= cast.b4;
END (*BitsetToByte*);

FUNCTION  LBitsetToByte (bset: LONGBITSET): BYTE;
BEGIN
 cast.lset:= bset;  LBitsetToByte:= cast.b4;
END (*LBitsetToByte*);

FUNCTION  BytesetToWord (bset: Byteset): WORD;
BEGIN
 cast.s4:= bset;  BytesetToWord:= cast.lw;
END (*BytesetToWord*);

FUNCTION  BitsetToWord  (bset: BITSET): WORD;
VAR b: WORD ABSOLUTE bset;
BEGIN
 BitsetToWord:= b;
END (*BitsetToWord*);

FUNCTION  LBitsetToWord (bset: LONGBITSET): WORD;
BEGIN
 cast.lset:= bset;  LBitsetToWord:= cast.lw;
END (*LBitsetToWord*);

FUNCTION  BytesetToLong (bset: Byteset): LONGINT;
BEGIN
 cast.s4:= bset;  BytesetToLong:= cast.lint;
END (*BytesetToLong*);

FUNCTION  BitsetToLong (bset: BITSET): LONGINT;
BEGIN
 cast.ls:= bset;  BitsetToLong:= cast.lint;
END (*BitsetToLong*);

FUNCTION  LBitsetToLong (bset: LONGBITSET): LONGINT;
VAR b: LONGINT ABSOLUTE bset;
BEGIN
 LBitsetToLong:= b;
END (*LBitsetToLong*);

END (*Basics*).
