UNIT M_Strings;

INTERFACE

FUNCTION  StrLen     (CONST str: ARRAY OF CHAR): LONGINT;
FUNCTION  StrComp    (CONST str1, str2: ARRAY OF CHAR): INTEGER;
FUNCTION  StrLexComp (CONST str1, str2: ARRAY OF CHAR): INTEGER;
FUNCTION  StrLComp   (CONST str1, str2: ARRAY OF CHAR; maxLen: LONGINT): INTEGER;
FUNCTION  StrPas     (CONST str: ARRAY OF CHAR): String;
FUNCTION  StrPos     (CONST str1, str2: ARRAY OF CHAR): INTEGER;
FUNCTION  StrScan    (CONST str: ARRAY OF CHAR; c: Char): INTEGER;
FUNCTION  StrIPos    (CONST str1, str2: ARRAY OF CHAR; start: INTEGER): INTEGER;
FUNCTION  StrWPos    (CONST str1, str2: ARRAY OF CHAR; start: INTEGER;  wild, joker: CHAR): INTEGER;
FUNCTION  StrMatch   (CONST str1, str2: ARRAY OF CHAR; wild, joker: CHAR): BOOLEAN;
PROCEDURE StrCopy    (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
PROCEDURE StrICopy   (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; start, len: INTEGER);
PROCEDURE StrPCopy   (VAR dest: ARRAY OF CHAR; CONST source: String);
PROCEDURE StrLCopy   (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxlen: LONGINT);
PROCEDURE StrCat     (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
PROCEDURE StrLCat    (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxLen: LONGINT);
PROCEDURE StrInsert  (CONST str1: ARRAY OF CHAR; VAR str2: ARRAY OF CHAR; start: INTEGER);
PROCEDURE StrDelete  (VAR str: ARRAY OF CHAR; start, len: INTEGER);
PROCEDURE StrLower   (VAR str: ARRAY OF CHAR);
PROCEDURE StrUpper   (VAR str: ARRAY OF CHAR);
FUNCTION  StrSimilar (CONST cs1, cs2: ARRAY OF CHAR): INTEGER;

IMPLEMENTATION

USES M_Sys;

FUNCTION StrLen (CONST str: ARRAY OF CHAR): LONGINT;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str);
 CallMagic (300);
 StrLen:= App^.MagicPB^.LongOut[0];
END (*StrLen*);

FUNCTION StrComp (CONST str1, str2: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 CallMagic (301);
 StrComp:= App^.MagicPB^.IntOut[0];
END (*StrComp*);

FUNCTION StrLexComp (CONST str1, str2: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 CallMagic (320);
 StrLexComp:= App^.MagicPB^.IntOut[0];
END (*StrLexComp*);

FUNCTION StrLComp (CONST str1, str2: ARRAY OF CHAR; maxLen: LONGINT): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 App^.MagicPB^.LongIn[0]:= maxlen;
 CallMagic (302);
 StrLComp:= App^.MagicPB^.IntOut[0];
END (*StrLComp*);

FUNCTION StrPas (CONST str: ARRAY OF CHAR): STRING;
VAR s: STRING;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str);
 App^.MagicPB^.AddrIn[1]:= ADDR (s);
 CallMagic (303);
 StrPas:= s;
END (*StrPas*);

FUNCTION StrPos (CONST str1, str2: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 CallMagic (304);
 StrPos:= App^.MagicPB^.Intout[0];
END (*StrPos*);

FUNCTION StrScan (CONST str: ARRAY OF CHAR; c: Char): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str);
 App^.MagicPB^.Intin[0]:= ORD (c);
 CallMagic (305);
 StrScan:= App^.MagicPB^.Intout[0];
END (*StrScan*);

FUNCTION StrIPos (CONST str1, str2: ARRAY OF CHAR; start: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 App^.MagicPB^.Intin[0]:= start;
 CallMagic (306);
 StrIPos:= App^.MagicPB^.Intout[0];
END (*StrIPos*);

FUNCTION StrWPos (CONST str1, str2: ARRAY OF CHAR; start: INTEGER; wild, joker: CHAR): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 App^.MagicPB^.Intin[0]:= start;
 App^.MagicPB^.Intin[1]:= ORD (wild);
 App^.MagicPB^.Intin[2]:= ORD (joker);
 CallMagic (307);
 StrWPos:= App^.MagicPB^.Intout[0];
END (*StrWPos*);

PROCEDURE StrCopy (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (dest);
 App^.MagicPB^.AddrIn[1]:= ADDR (source);
 CallMagic (308);
END (*StrCopy*);

PROCEDURE StrLCopy (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxlen: LONGINT);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (dest);
 App^.MagicPB^.AddrIn[1]:= ADDR (source);
 App^.MagicPB^.Longin[0]:= maxlen;
 CallMagic (309);
END (*StrLCopy*);

PROCEDURE StrPCopy (VAR dest: ARRAY OF CHAR; CONST source: String);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (dest);
 App^.MagicPB^.AddrIn[1]:= ADDR (source);
 CallMagic (310);
END (*StrPCopy*);

PROCEDURE StrCat (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (dest);
 App^.MagicPB^.AddrIn[1]:= ADDR (source);
 CallMagic (311);
END (*StrCat*);

PROCEDURE StrLCat   (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR; maxLen: LONGINT);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (dest);
 App^.MagicPB^.AddrIn[1]:= ADDR (source);
 App^.MagicPB^.Longin[0]:= maxlen;
 CallMagic (312);
END (*StrLCat*);

PROCEDURE StrInsert (CONST str1: ARRAY OF CHAR; VAR str2: ARRAY OF CHAR; start: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 App^.MagicPB^.Intin[0]:= start;
 CallMagic (313);
END (*StrInsert*);

PROCEDURE StrDelete (VAR str: ARRAY OF CHAR; start, len: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str);
 App^.MagicPB^.Intin[0]:= start;
 App^.MagicPB^.Intin[1]:= len;
 CallMagic (314);
END (*StrDelete*);

PROCEDURE StrUpper (VAR str: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str);
 CallMagic (315);
END (*StrUpper*);

PROCEDURE StrLower (VAR str: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str);
 CallMagic (316);
END (*StrLower*);

FUNCTION StrMatch (CONST str1, str2: ARRAY OF CHAR; wild, joker: CHAR): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (str1);
 App^.MagicPB^.AddrIn[1]:= ADDR (str2);
 App^.MagicPB^.Intin[0]:= ORD (wild);
 App^.MagicPB^.Intin[1]:= ORD (joker);
 CallMagic (317);
 StrMatch:= BOOLEAN (App^.MagicPB^.Intout[0]);
END (*StrWPos*);

PROCEDURE StrICopy (VAR dest: ARRAY OF CHAR; CONST source: ARRAY OF CHAR;
                    start, len: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (dest);
 App^.MagicPB^.AddrIn[1]:= ADDR (source);
 App^.MagicPB^.Intin[0]:= start;
 App^.MagicPB^.Intin[1]:= len;
 CallMagic (318);
END (*StrICopy*);

FUNCTION  StrSimilar (CONST cs1, cs2: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (cs1);
 App^.MagicPB^.AddrIn[1]:= ADDR (cs2);
 CallMagic (319);
 StrSimilar:= App^.MagicPB^.Intout[0];
END (*StrSimilar*);

END (*M_Strings*).
