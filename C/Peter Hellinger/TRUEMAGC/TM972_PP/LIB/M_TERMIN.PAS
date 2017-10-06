UNIT M_Terminal;

INTERFACE

USES Basics, M_Windows;

CONST Invers = Bit7;  (* ZusÑtzliches Flag fÅr Text-Effekte.  Wird in
                       * M_Terminal emuliert!
                       *)

FUNCTION OpenTextwindow (draw: WindowHandler;
                         element: BITSET; 
                         extended: LONGBITSET;
                         x, y, w, h: INTEGER;
                         xo, yo, wo, ho: INTEGER;
                         bcolor, fcolor: INTEGER;
                         font, size: INTEGER;
                         effects: BITSET;
                         wrappos: INTEGER;
                         name, info: STRING;
                         rsc: POINTER): INTEGER;
PROCEDURE CloseTextwindow (win: INTEGER);
PROCEDURE WriteChar (win: INTEGER; ch: CHAR);
PROCEDURE WriteLine (win: INTEGER; str: STRING);
PROCEDURE WriteLn (win: INTEGER);
PROCEDURE WriteInt  (win, val, len: INTEGER);
PROCEDURE WriteWord (win: INTEGER; val: WORD; len: INTEGER);
PROCEDURE WriteLInt (win: INTEGER; val: LONGINT; len: INTEGER);
PROCEDURE WriteReal (win: INTEGER; val: REAL; len: INTEGER);
FUNCTION  GetChar (win, x, y: INTEGER): CHAR;
PROCEDURE GetLine (win, line: INTEGER; VAR strng: STRING);
PROCEDURE WindowInfo (win: INTEGER; VAR column, lines, font: INTEGER);
PROCEDURE CalcRedraw (win: INTEGER; rect: tRect; VAR von, bis: INTEGER);
PROCEDURE InsertLine (win: INTEGER);
PROCEDURE DeleteLine (win: INTEGER);
PROCEDURE WhereXY (win: INTEGER; VAR spalte, zeile: INTEGER);
PROCEDURE GotoXY (win, spalte, zeile: INTEGER);
PROCEDURE CursorOn  (win: INTEGER);
PROCEDURE CursorOff (win: INTEGER);
PROCEDURE WrapPos (win, pos: INTEGER);
PROCEDURE WrapOff (win: INTEGER);
PROCEDURE WrapOn  (win: INTEGER);
PROCEDURE ClearLine (win: INTEGER);
PROCEDURE ClearStartOfLine (win: INTEGER);
PROCEDURE ClearEndOfLine (win: INTEGER);
PROCEDURE ClearScreen (win: INTEGER);
PROCEDURE ClearStartOfScreen (win: INTEGER);
PROCEDURE ClearEndOfScreen (win: INTEGER);
PROCEDURE ForegroundColor (win, color: INTEGER);
PROCEDURE BackgroundColor (win, color: INTEGER);
PROCEDURE InversOn  (win: INTEGER);
PROCEDURE InversOff (win: INTEGER);
PROCEDURE SetAttribut (win: INTEGER; attrib: BITSET);
PROCEDURE SetTabspace (win, tab: INTEGER);
PROCEDURE ChangeFont (win, font, size, color: INTEGER; attrib: BITSET);
PROCEDURE TermfontSelector (CONST msg: STRING; flags: BITSET);
FUNCTION  TopTerminal: INTEGER;
PROCEDURE LoadTermfonts;

IMPLEMENTATION

USES M_Sys;

{$I COMPOPT.INC}

FUNCTION OpenTextwindow (draw: WindowHandler;
                         element: BITSET; 
                         extended: LONGBITSET;
                         x, y, w, h: INTEGER;
                         xo, yo, wo, ho: INTEGER;
                         bcolor, fcolor: INTEGER;
                         font, size: INTEGER;
                         effects: BITSET;
                         wrappos: INTEGER;
                         name, info: STRING;
                         rsc: POINTER): INTEGER;
VAR n, i: CSTRING;
    t: RECORD
        CASE INTEGER OF
         0: (d: WindowHandler);
         1: (p: POINTER);
       END;
BEGIN
 PascalToCString (name, @n);
 PascalToCString (info, @i);
 t.d:= draw;
 App^.MagicPB^.Addrin[ 0]:= t.p;
 App^.MagicPB^.Addrin[ 1]:= @n;
 App^.MagicPB^.Addrin[ 2]:= @i;
 App^.MagicPB^.Addrin[ 3]:= rsc;
 App^.MagicPB^.Intin[ 0]:= BitsetToWord (element);
 App^.MagicPB^.Intin[ 1]:= x;
 App^.MagicPB^.Intin[ 2]:= y;
 App^.MagicPB^.Intin[ 3]:= w;
 App^.MagicPB^.Intin[ 4]:= h;
 App^.MagicPB^.Intin[ 5]:= xo;
 App^.MagicPB^.Intin[ 6]:= yo;
 App^.MagicPB^.Intin[ 7]:= wo;
 App^.MagicPB^.Intin[ 8]:= ho;
 App^.MagicPB^.Intin[ 9]:= bcolor;
 App^.MagicPB^.Intin[10]:= fcolor;
 App^.MagicPB^.Intin[11]:= font;
 App^.MagicPB^.Intin[12]:= size;
 App^.MagicPB^.Intin[13]:= BitsetToWord (effects);
 App^.MagicPB^.Intin[14]:= wrappos;
 App^.MagicPB^.longIn[0]:= LBitsetToLong (extended);
 CallMagic (2000);
 OpenTextwindow:= App^.MagicPB^.Intout[0];
END (*OpenTextWindow*);
  
PROCEDURE CloseTextwindow (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2001);
END (*CloseTextWindow*);

PROCEDURE WriteChar (win: INTEGER; ch: CHAR);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= ORD (ch);
 CallMagic (2002);
END (*WriteChar*);

PROCEDURE WriteLine (win: INTEGER; str: STRING);
VAR s: CSTRING;
BEGIN
 PascalToCString (str, @s);
 App^.MagicPB^.Addrin[0]:= @s;
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2003);
END (*WriteLine*);

PROCEDURE WriteLn (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2004);
END (*WriteLn*);

PROCEDURE WriteInt  (win, val, len: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= val;
 App^.MagicPB^.Intin[2]:= len;
 CallMagic (2005);
END (*WriteInt*); 

PROCEDURE WriteWord (win: INTEGER; val: WORD; len: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= val;
 App^.MagicPB^.Intin[2]:= len;
 CallMagic (2006);
END (*WriteWord*); 

PROCEDURE WriteLInt (win: INTEGER; val: LONGINT; len: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Longin[0]:= val;
 App^.MagicPB^.Intin[1]:= len;
 CallMagic (2007);
END (*WriteLInt*); 

PROCEDURE WriteReal (win: INTEGER; val: REAL; len: INTEGER);
VAR p: STRING;
    c: CSTRING;
BEGIN
 Str (val:len, p);
 PascalToCString (p, @c);
 App^.MagicPB^.Addrin[0]:= @c;
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2003);
END (*WriteReal*); 

FUNCTION GetChar (win, x, y: INTEGER): CHAR;
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= x;
 App^.MagicPB^.Intin[2]:= y;
 CallMagic (2008);
 GetChar:= CHR (App^.MagicPB^.Intout[0]);
END (*GetChar*);

PROCEDURE GetLine (win, line: INTEGER; VAR strng: STRING);
VAR c: CSTRING;
BEGIN
 App^.MagicPB^.Addrin[0]:= @c;
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= line;
 CallMagic (2009);
 CToPascalString (strng, @c);
END (*GetLine*);

PROCEDURE WindowInfo (win: INTEGER; VAR column, lines, font: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2010);
 column:= App^.MagicPB^.Intout[0];
 lines:= App^.MagicPB^.Intout[1];
 font:= App^.MagicPB^.Intout[2];
END (*WindowInfo*);

PROCEDURE InsertLine (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2011);
END (*InsertLine*);

PROCEDURE DeleteLine (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2012);
END (*DeleteLine*);

PROCEDURE WhereXY (win: INTEGER; VAR spalte, zeile: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2013);
 spalte:= App^.MagicPB^.Intout[0];
 zeile:= App^.MagicPB^.Intout[1];
END (*WhereXY*);

PROCEDURE GotoXY (win, spalte, zeile: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= spalte;
 App^.MagicPB^.Intin[2]:= zeile;
 CallMagic (2014);
END (*GotoXY*);

PROCEDURE CursorOn (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2015);
END (*CursorOn*);

PROCEDURE CursorOff (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2016);
END (*CursorOff*);

PROCEDURE WrapPos (win, pos: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[0]:= pos;
 CallMagic (2017);
END (*WrapPos*);

PROCEDURE WrapOff (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2018);
END (*WrapOff*);

PROCEDURE WrapOn (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2019);
END (*WrapOn*);

PROCEDURE ClearLine (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2020);
END (*ClearLine*);

PROCEDURE ClearStartOfLine (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2021);
END (*ClearStartOfLine*);

PROCEDURE ClearEndOfLine (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2022);
END (*ClearEndOfLine*);

PROCEDURE ClearScreen (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2023);
END (*ClearScreen*);

PROCEDURE ClearStartOfScreen (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2024);
END (*ClearStartOfScreen*);

PROCEDURE ClearEndOfScreen (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2025);
END (*ClearEndOfScreen*);

PROCEDURE ForegroundColor (win, color: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= color;
 CallMagic (2026);
END (*ForegroundColor*);

PROCEDURE BackgroundColor (win, color: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= color;
 CallMagic (2027);
END (*BackgroundColor*);

PROCEDURE InversOn (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2028);
END (*InversOn*);

PROCEDURE InversOff (win: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2029);
END (*InversOff*);

PROCEDURE SetAttribut (win: INTEGER; attrib: BITSET);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= BitsetToWord (attrib);
 CallMagic (2030);
END (*SetAttribut*);

PROCEDURE SetTabspace (win, tab: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= tab;
 CallMagic (2031);
END (*SetTabspace*);

PROCEDURE ChangeFont (win, font, size, color: INTEGER; attrib: BITSET);
BEGIN
 App^.MagicPB^.Intin[0]:= win;
 App^.MagicPB^.Intin[1]:= font;
 App^.MagicPB^.Intin[2]:= size;
 App^.MagicPB^.Intin[3]:= color;
 App^.MagicPB^.Intin[4]:= BitsetToWord (attrib);
 CallMagic (2032);
END (*ChangeFont*);

FUNCTION TopTerminal: INTEGER;
BEGIN
 CallMagic (2034);
 TopTerminal:= App^.MagicPB^.Intout[0];
END (*TopTerminal*);
  
PROCEDURE CalcRedraw (win: INTEGER; rect: tRect; VAR von, bis: INTEGER);
BEGIN
 App^.MagicPB^.Addrin[0]:= ADDR (rect);
 App^.MagicPB^.Intin[0]:= win;
 CallMagic (2035);
 von:= App^.MagicPB^.Intout[0];
 bis:= App^.MagicPB^.Intout[1];
END (*CalcRedraw*);

PROCEDURE TermFontselector (CONST msg: STRING; flags: BITSET);
VAR x: CSTRING;
BEGIN
 PascalToCString (msg, @x);
 App^.MagicPB^.Addrin[0]:= @x;
 App^.MagicPB^.Intin[0]:= BitsetToWord (flags + [Bit3]);
 CallMagic (2036);
END (*TermFontselector*);

PROCEDURE LoadTermfonts;
BEGIN
 CallMagic (2033);
END (*LoadTermfonts*);

END (*mpTerminal*).
