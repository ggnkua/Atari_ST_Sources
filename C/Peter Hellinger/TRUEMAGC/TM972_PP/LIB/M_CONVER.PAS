UNIT M_Convert;

INTERFACE

PROCEDURE NumToStr (num: LONGINT; len, base: INTEGER; neg: BOOLEAN; VAR s: STRING);
FUNCTION StrToNum (s: STRING; base: INTEGER; neg: BOOLEAN; max: LONGINT): LONGINT;
FUNCTION StrToInt      (s: STRING): INTEGER;
FUNCTION StrToLInt     (s: STRING): LONGINT;
FUNCTION HexToInt      (s: STRING): INTEGER;
FUNCTION HexToLInt     (s: STRING): LONGINT;
FUNCTION StrToReal     (s: STRING): REAL;
PROCEDURE IntToStr      (v: INTEGER; n: INTEGER; VAR s: STRING);
PROCEDURE IntToHexStr   (v: INTEGER; n: INTEGER; VAR s: STRING);
PROCEDURE LIntToStr     (v: LONGINT; n: INTEGER; VAR s: STRING);
PROCEDURE LIntToHexStr  (v: LONGINT; n: INTEGER; VAR s: STRING);
PROCEDURE RealToStr     (v: REAL;    n: INTEGER; VAR s: STRING);

IMPLEMENTATION

USES M_Sys, M_Strings, Basics;

VAR cs: CSTRING;

PROCEDURE NumToStr (num: LONGINT; len, base: INTEGER; neg: BOOLEAN; VAR s: STRING);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR(cs);
 App^.MagicPB^.LongIn[0]:= num;
 App^.MagicPB^.IntIn[0]:= len;
 App^.MagicPB^.IntIn[1]:= base;
 App^.MagicPB^.IntIn[2]:= ORD(neg);
 CallMagic (100);
 s:= StrPas (cs);
END (*NumToStr*);

FUNCTION StrToNum (s: STRING; base: INTEGER; neg: BOOLEAN; max: LONGINT): LONGINT;
BEGIN
 PascalToCString (s, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR(cs);
 App^.MagicPB^.IntIn[0]:= base;
 App^.MagicPB^.IntIn[1]:= ORD (neg);
 App^.MagicPB^.LongIn[0]:= max;
 CallMagic (101);
 StrToNum:= App^.MagicPB^.LongOut[0];
END (*StrToNum*);

PROCEDURE RealToStr (v: REAL; n: INTEGER; VAR s: STRING);
BEGIN
 STR (v:n, s);
END (*RealToStr*);

FUNCTION StrToReal (s: STRING): REAL;
VAR r: REAL;
    i: INTEGER;
BEGIN
 VAL (s, r, i);
 StrToReal:= r;
END (*StrToReal*);

FUNCTION StrToInt (s: STRING): INTEGER;
BEGIN
 PascalToCString (s, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 CallMagic (102);
 StrToInt:= App^.MagicPB^.IntOut[0];
END (*StrToInt*);

FUNCTION StrToLInt (s: STRING): LONGINT;
BEGIN
 PascalToCString (s, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 CallMagic (103);
 StrToLInt:= App^.MagicPB^.LongOut[0];
END (*StrToLInt*);

FUNCTION HexToInt (s: STRING): INTEGER;
BEGIN
 PascalToCString (s, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 CallMagic (104);
 HexToInt:= App^.MagicPB^.IntOut[0];
END (*HexToInt*);

FUNCTION HexToLInt (s: STRING): LONGINT;
BEGIN
 PascalToCString (s, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 CallMagic (105);
 HexToLInt:= App^.MagicPB^.LongOut[0];
END (*HexToLInt*);

PROCEDURE IntToStr (v: INTEGER; n: INTEGER; VAR s: STRING);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 App^.MagicPB^.IntIn[0]:= v;
 App^.MagicPB^.IntIn[1]:= n;
 CallMagic (107);
 s:= StrPas (cs);
END (*IntToStr*);

PROCEDURE IntToHexStr (v: INTEGER; n: INTEGER; VAR s: STRING);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 App^.MagicPB^.IntIn[0]:= v;
 App^.MagicPB^.IntIn[1]:= n;
 CallMagic (108);
 s:= StrPas (cs);
END (*IntToHexStr*);

PROCEDURE LIntToHexStr (v: LONGINT; n: INTEGER; VAR s: STRING);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 App^.MagicPB^.LongIn[0]:= v;
 App^.MagicPB^.IntIn[0]:= n;
 CallMagic (110);
 s:= StrPas (cs);
END (*LIntToHexStr*);

PROCEDURE LIntToStr (v: LONGINT; n: INTEGER; VAR s: STRING);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 App^.MagicPB^.LongIn[0]:= v;
 App^.MagicPB^.IntIn[0]:= n;
 CallMagic (109);
 s:= StrPas (cs);
END (*LIntToStr*);

END (*M_Convert*).
