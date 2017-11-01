(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ÿ         ÿ            ÿ    ÿ          ÿ
########################################################################

  VDI           Virtual Device Interface        Interface for Modula-2

                Implementation fr Megamax-Modula-2

########################################################################
  V1.01  18.06.90  Peter Hellinger      Bug in GDos() gefixt
  V1.00  (C) by    Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicVDI;


(*------------------------------*)
(*      MM2-Compilerswitches    *)
(*                              *)
(*$R-   Range-Checks            *)
(*$S-   Stack-Check             *)
(*                              *)
(*------------------------------*)


FROM SYSTEM IMPORT ADDRESS, ADR, WORD, LONGWORD, ASSEMBLER;
IMPORT MagicSys;


VAR vdipb: ADDRESS;


PROCEDURE VDICall (c0, c1, c3, c5, c6: INTEGER);
BEGIN
 VDIControl[0]:= c0;
 VDIControl[1]:= c1;
 VDIControl[3]:= c3;
 VDIControl[5]:= c5;
 VDIControl[6]:= c6;
 ASSEMBLER
  MOVE.W   #115, D0
  MOVE.L   vdipb, D1
  TRAP     #2
 END;
END VDICall;


PROCEDURE GDos(): BOOLEAN;
VAR x: LONGINT;
BEGIN
 ASSEMBLER
  MOVE.L   #-2, D0      ; LONG, Sappelzement!
  TRAP     #2
  MOVE.L   D0, x(A6)
 END;
 RETURN x # LONGINT(-2);
END GDos;


(*#######################################################################*)


PROCEDURE SetWritemode (handle, mode: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= mode;
 VDICall (32, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetWritemode;


PROCEDURE SetColor (handle, index: INTEGER; VAR rgb: ARRAY OF WORD);
BEGIN
 VDIIntIn[0]:= index;
 VDIIntIn[1]:= MagicSys.WordToInt (rgb[0]);
 VDIIntIn[2]:= MagicSys.WordToInt (rgb[1]);
 VDIIntIn[3]:= MagicSys.WordToInt (rgb[2]);
 VDICall(14, 0, 4, 0, handle);
END SetColor;


PROCEDURE SetLinetype (handle, style: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= style;
 VDICall (15, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetLinetype;


PROCEDURE SetUserlinestyle (handle: INTEGER; style: WORD);
BEGIN
 VDIIntIn[0]:= MagicSys.WordToInt (style);
 VDICall (113, 0, 1, 0, handle);
END SetUserlinestyle;


PROCEDURE SetLinewidth (handle, width: INTEGER): INTEGER;
BEGIN
 VDIPtsIn[0]:= width;
 VDIPtsIn[1]:= 0;
 VDICall (16, 1, 0, 0, handle);
 RETURN VDIPtsOut[0];
END SetLinewidth;


PROCEDURE SetLinecolor (handle, color: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= color;
 VDICall (17, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetLinecolor;


PROCEDURE SetLineEndstyles (handle, begin, end: INTEGER);
BEGIN
 VDIIntIn[0]:= begin;
 VDIIntIn[1]:= end;
 VDICall (108, 0, 2, 0, handle);
END SetLineEndstyles;


PROCEDURE SetMarkertype (handle, type: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= type;
 VDICall (18, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetMarkertype;


PROCEDURE SetMarkerheight (handle, height: INTEGER): INTEGER; 
BEGIN
 VDIPtsIn[0]:= height;
 VDIPtsIn[1]:= 0;
 VDICall (19, 1, 0, 0, handle);
 RETURN VDIPtsOut[0];
END SetMarkerheight;


PROCEDURE SetMarkercolor (handle, index: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= index;
 VDICall (20, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetMarkercolor;


PROCEDURE SetCharheight (handle, hi: INTEGER; VAR cw, ch, bw, bh: INTEGER);
BEGIN
 VDIPtsIn[0]:= 0;
 VDIPtsIn[1]:= hi;
 VDICall (12, 1, 0, 0, handle);
 cw:= VDIPtsOut[0];
 ch:= VDIPtsOut[1];
 bw:= VDIPtsOut[2];
 bh:= VDIPtsOut[3];
END SetCharheight;


PROCEDURE SetCharpoints (handle, hi: INTEGER; VAR cw, ch, bw, bh: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= hi;
 VDICall (107, 0, 1, 0, handle);
 cw:= VDIPtsOut[0];
 ch:= VDIPtsOut[1];
 bw:= VDIPtsOut[2];
 bh:= VDIPtsOut[3];
 RETURN VDIIntOut[0];
END SetCharpoints;


PROCEDURE SetCharbaseline (handle, angle: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= angle;
 VDICall (13, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetCharbaseline;


PROCEDURE SetTextface (handle, font: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= font;
 VDICall (21, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetTextface;


PROCEDURE SetTextcolor (handle, index: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= index;
 VDICall (22, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetTextcolor;


PROCEDURE SetTexteffect (handle: INTEGER; effect: BITSET): BITSET;
BEGIN
 VDIIntIn[0]:= MagicSys.WordToInt (effect);
 VDICall (106, 0, 1, 0, handle);
 RETURN BITSET(VDIIntOut[0]);
END SetTexteffect;


PROCEDURE SetTextalignment (handle, hin, vin: INTEGER; VAR ho, vo: INTEGER);
BEGIN
 VDIIntIn[0]:= hin;
 VDIIntIn[1]:= vin;
 VDICall (39, 0, 2, 0, handle);
 ho:= VDIIntOut[0];
 vo:= VDIIntOut[1];
END SetTextalignment;


PROCEDURE SetFillinterior (handle, index: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= index;
 VDICall (23, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetFillinterior;


PROCEDURE SetFillstyle (handle, style: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= style;
 VDICall (24, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetFillstyle;


PROCEDURE SetFillcolor (handle, index: INTEGER): INTEGER; 
BEGIN
 VDIIntIn[0]:= index;
 VDICall (25, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END SetFillcolor;


PROCEDURE SetFillperimeter (handle: INTEGER; border: BOOLEAN): BOOLEAN;
BEGIN
 IF border THEN  VDIIntIn[0]:= 1;  ELSE  VDIIntIn[0]:= 0;  END;
 VDICall (104, 0, 1, 0, handle);
 RETURN VDIIntOut[0] = 1;
END SetFillperimeter;


PROCEDURE SetUserfillpattern (handle: INTEGER; VAR pat: ARRAY OF WORD);
VAR old: ADDRESS;
BEGIN
 old:= VDIPB.intin;
 VDIPB.intin:= ADR (pat);
 VDICall (112, 0, HIGH(pat) * 16, 0, handle);
 VDIPB.intin:= old;
END SetUserfillpattern;


(*#######################################################################*)


PROCEDURE OpenWorkstation (VAR in: ARRAY OF WORD; VAR handle: INTEGER;
                           VAR out: ARRAY OF WORD);
VAR c: INTEGER;
BEGIN
 FOR c:= 0 TO 10 DO  VDIIntIn[c]:= MagicSys.WordToInt (in[c]); END;
 VDICall(1, 0, 11, 0, handle);
 handle:= VDIControl[6];
 FOR c:= 0 TO 44 DO  out[c]:= WORD(VDIIntOut[c]); END;
 FOR c:= 0 TO 11 DO  out[c+44]:= WORD(VDIPtsOut[c]); END;
END OpenWorkstation;


PROCEDURE CloseWorkstation (handle: INTEGER);
BEGIN
 VDICall(2, 0, 0, 0, handle);
END CloseWorkstation;


PROCEDURE OpenVirtual (VAR in: ARRAY OF WORD; VAR handle: INTEGER;
                       VAR out: ARRAY OF WORD);
VAR c: INTEGER;
BEGIN
 FOR c:= 0 TO 10 DO  VDIIntIn[c]:= MagicSys.WordToInt (in[c]); END;
 VDICall(100, 0, 11, 0, handle);
 handle:= VDIControl[6];
 FOR c:= 0 TO 44 DO  out[c]:= WORD(VDIIntOut[c]); END;
 FOR c:= 0 TO 11 DO  out[c+45]:= WORD(VDIPtsOut[c]); END;
END OpenVirtual;


PROCEDURE CloseVirtual (handle: INTEGER);
BEGIN
 VDICall(101, 0, 0, 0, handle);
END CloseVirtual;


PROCEDURE ClearWorkstation (handle: INTEGER);
BEGIN
 VDICall(3, 0, 0, 0, handle);
END ClearWorkstation;


PROCEDURE UpdateWorkstation (handle: INTEGER);
BEGIN
 VDICall(4, 0, 0, 0, handle);
END UpdateWorkstation;


PROCEDURE LoadFonts (handle, select: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= select;
 VDICall(119, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END LoadFonts;


PROCEDURE UnloadFonts (handle, select: INTEGER);
BEGIN
 VDIIntIn[0]:= select;
 VDICall(120, 0, 1, 0, handle);
END UnloadFonts;


PROCEDURE SetClipping (handle: INTEGER; VAR rect: ARRAY OF WORD; do: BOOLEAN);
BEGIN
 VDIPtsIn[0]:= MagicSys.WordToInt (rect[0]);
 VDIPtsIn[1]:= MagicSys.WordToInt (rect[1]);
 VDIPtsIn[2]:= MagicSys.WordToInt (rect[2]);
 VDIPtsIn[3]:= MagicSys.WordToInt (rect[3]);
 IF do THEN  VDIIntIn[0]:= 1;  ELSE VDIIntIn[0]:= 0;  END;
 VDICall(129, 2, 1, 0, handle);
END SetClipping;


(*#######################################################################*)


PROCEDURE GetCharcells (handle: INTEGER; VAR rows, colums: INTEGER);
BEGIN
 VDICall (5, 0, 0, 1, handle);
 rows:= VDIIntOut[0];
 colums:= VDIIntOut[1];
END GetCharcells;


PROCEDURE ExitAlphamode (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 2, handle);
END ExitAlphamode;


PROCEDURE EnterAlphamode (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 3, handle);
END EnterAlphamode;


PROCEDURE AlphacursorUp (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 4, handle);
END AlphacursorUp;


PROCEDURE AlphacursorDown (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 5, handle);
END AlphacursorDown;

PROCEDURE AlphacursorRight (handle : INTEGER);
BEGIN
 VDICall (5, 0, 0, 6, handle);
END AlphacursorRight;


PROCEDURE AlphacursorLeft (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 7, handle);
END AlphacursorLeft;


PROCEDURE HomeAlphacursor (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 8, handle);
END HomeAlphacursor;


PROCEDURE EraseEOS (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 9, handle);
END EraseEOS;


PROCEDURE EraseEOL (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 10, handle);
END EraseEOL;


PROCEDURE AlphacursorAddress (handle, row, column: INTEGER);
BEGIN
 VDIIntIn[0]:= row;
 VDIIntIn[1]:= column;
 VDICall (5, 0, 2, 11, handle);
END AlphacursorAddress;


PROCEDURE CursorText (handle: INTEGER; string: ARRAY OF CHAR);
VAR h, i: INTEGER;
BEGIN
 h:= HIGH(string); i:= 0;
 LOOP
  IF (i > h) OR (string[i] = 0C) THEN EXIT END;
  VDIIntIn[i]:= ORD(string[i]);  INC(i);
 END;
 IF (i = 0) THEN RETURN END;
 VDICall (5, 0, i, 12, handle);
END CursorText;


PROCEDURE ReverseVideoOn (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 13, handle);
END ReverseVideoOn;


PROCEDURE ReverseVideoOff (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 14, handle);
END ReverseVideoOff;


PROCEDURE InqCursoraddress (handle: INTEGER; VAR row, column: INTEGER);
BEGIN
 VDICall (5, 0, 0, 15, handle);
 row:= VDIIntOut[0];
 column:= VDIIntOut[1];
END InqCursoraddress;


PROCEDURE InqTabletstatus (handle: INTEGER): INTEGER;
BEGIN
 VDICall (5, 0, 0, 16, handle);
 RETURN VDIIntOut[0];
END InqTabletstatus;


PROCEDURE Hardcopy (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 17, handle);
END Hardcopy;


PROCEDURE DisplayCursor (handle, x, y: INTEGER);
BEGIN
 VDICall (5, 1, 0, 18, handle);
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
END DisplayCursor;


PROCEDURE RemoveCursor (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 19, handle);
END RemoveCursor;


PROCEDURE FormAdvance (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 20, handle);
END FormAdvance;


PROCEDURE OutputWindow (handle: INTEGER; VAR pxy: ARRAY OF WORD);
VAR i: INTEGER;
BEGIN
 FOR i:= 0 TO 3 DO VDIPtsIn[i]:= MagicSys.WordToInt (pxy[i]); END;
 VDICall (5, 2, 0, 21, handle);
END OutputWindow;


PROCEDURE ClearDisplaylist (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 22, handle);
END ClearDisplaylist;


PROCEDURE OutputBitimagefile (handle: INTEGER; fileName: ARRAY OF CHAR;
                              aspect, scaling, numPts: INTEGER;
                              VAR pxy: ARRAY OF WORD);
VAR h, i: INTEGER;
BEGIN
 VDIIntIn[0]:= aspect;
 VDIIntIn[1]:= scaling;
 h:= HIGH (fileName);
 i:= 0;
 LOOP
  IF (i > h) OR (fileName [i] = 0C) THEN EXIT END;
  VDIIntIn[2+i]:= ORD (fileName[i]);
  INC (i);
 END; (* LOOP *)
 IF (i = 0) THEN RETURN END;
 VDIIntIn[i+2]:= 0;   (* terminate array properly *)
 VDICall (5, numPts, 3+i, 23, handle);
END OutputBitimagefile;


PROCEDURE GetPrinterscan(handle: INTEGER; VAR gSlice, gPage, size, page, div: INTEGER);
BEGIN
 VDICall (5, 0, 0, 24, handle);
 gSlice:= VDIIntOut[0];
 gPage:= VDIIntOut[1];
 size:= VDIIntOut[2];
 page:= VDIIntOut[3];
 div:= VDIIntOut[4];
END GetPrinterscan;


PROCEDURE PrintText (handle: INTEGER; string: ARRAY OF CHAR);
VAR h, i: INTEGER;
BEGIN
 h:= HIGH(string); i:= 0;
 LOOP
  IF (i > h) OR (string[i] = 0C) THEN EXIT END;
  VDIIntIn[i]:= ORD(string[i]);  INC(i);
 END;
 IF (i = 0) THEN RETURN END;
 VDICall (5, 0, i, 25, handle);
END PrintText;


PROCEDURE SelectPalette (handle, palette: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= palette;
 VDICall (5, 0, 1, 60, handle);
 RETURN VDIIntOut[0];
END SelectPalette;


PROCEDURE GenerateTone(handle, freq, time: INTEGER);
BEGIN
 VDIIntIn[0]:= freq;
 VDIIntIn[1]:= time;
 VDICall (5, 0, 2, 61, handle);
END GenerateTone;


PROCEDURE ToneMultiflag (handle, action: INTEGER);
BEGIN
 VDIIntIn[0]:= action;
 VDICall (5, 0, 1, 62, handle);
END ToneMultiflag;


PROCEDURE SetTabletaxisInch (handle, xres, yres: INTEGER;
                             VAR xset, yset: INTEGER);
BEGIN
 VDIIntIn[0]:= xres;
 VDIIntIn[1]:= yres;
 VDICall (5, 0, 2, 81, handle);
 xset:= VDIIntIn[0];
 yset:= VDIIntIn[1];
END SetTabletaxisInch;


PROCEDURE SetTabletaxisLine (handle, xres, yres: INTEGER;
                             VAR xset, yset: INTEGER);
BEGIN
 VDIIntIn[0]:= xres;
 VDIIntIn[1]:= yres;
 VDICall (5, 0, 2, 82, handle);
 xset:= VDIIntIn[0];
 yset:= VDIIntIn[1];
END SetTabletaxisLine;


PROCEDURE SetTabletorigin (handle, x, y: INTEGER);
BEGIN
 VDIIntIn[0]:= x;
 VDIIntIn[1]:= y;
 VDICall (5, 0, 2, 83, handle);
END SetTabletorigin;


PROCEDURE GetTabletorigin (handle: INTEGER; VAR x, y: INTEGER);
BEGIN
 VDICall (5, 0, 0, 84, handle);
 x:= VDIIntIn[0];
 y:= VDIIntIn[1];
END GetTabletorigin;


PROCEDURE SetTabletalignment (handle, x, y: INTEGER);
BEGIN
 VDIIntIn[0]:= x;
 VDIIntIn[1]:= y;
 VDICall (5, 0, 2, 85, handle);
END SetTabletalignment;


PROCEDURE SetFilmtype (handle, index, light: INTEGER);
BEGIN
 VDIIntIn[0]:= index;
 VDIIntIn[1]:= light;
 VDICall (5, 0, 2, 91, handle);
END SetFilmtype;


PROCEDURE GetFilmname (handle: INTEGER; VAR filmName: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 VDICall (5, 0, 1, 92, handle);
 FOR i:= 0 TO 24 DO filmName[i]:= CHR(VDIIntOut[i]) END;
END GetFilmname;


PROCEDURE SetFilmexposure (handle, state: INTEGER);
BEGIN
 VDIIntIn[0]:= state;
 VDICall (5, 0, 1, 93, handle);
END SetFilmexposure;


PROCEDURE UpdateMetafile (handle, minX, minY, maxX, maxY: INTEGER);
BEGIN
 VDIPtsIn[0]:= minX;
 VDIPtsIn[1]:= minY;
 VDIPtsIn[2]:= maxX;
 VDIPtsIn[3]:= maxY;
 VDICall (5, 2, 0, 98, handle);
END UpdateMetafile;


PROCEDURE WriteMetafile (handle, numIntin: INTEGER;  VAR intIn: ARRAY OF WORD;
                         numPtsin: INTEGER;  VAR ptsIn: ARRAY OF WORD);
VAR oldInt, oldPts: ADDRESS;
BEGIN
 oldInt:= VDIPB.intin;
 oldPts:= VDIPB.ptsin;
 VDIPB.intin:= ADR (intIn);
 VDIPB.ptsin:= ADR (ptsIn);
 VDICall (5, numPtsin, numIntin, 99, handle);
 VDIPB.intin:= oldInt;
 VDIPB.ptsin:= oldPts;
END WriteMetafile;


PROCEDURE PhysicalPagesize (handle, width, height: INTEGER);
BEGIN
 VDIIntIn[0]:= 0;
 VDIIntIn[1]:= width;
 VDIIntIn[2]:= height;
 VDICall (5, 0, 3, 99, handle);
END PhysicalPagesize;


PROCEDURE CoordinateWindow (handle, llx, lly, urx, ury: INTEGER);
BEGIN
 VDIIntIn[0]:= 1;
 VDIIntIn[1]:= llx;
 VDIIntIn[2]:= lly;
 VDIIntIn[3]:= ury;
 VDIIntIn[4]:= ury;
 VDICall (5, 0, 5, 99, handle);
END CoordinateWindow;


PROCEDURE ChangeVdiFilename (handle: INTEGER; fileName: ARRAY OF CHAR);
VAR h, i: INTEGER;
BEGIN
 h:= HIGH(fileName);  i:= 0;
 LOOP
  IF (i > h) OR (fileName [i] = 0C) THEN EXIT END;
  VDIIntIn[i]:= ORD (fileName[i]);  INC (i);
 END; (* LOOP *);
 IF (i = 0) THEN RETURN END;
 VDIIntIn[i]:= 0;
 VDICall (5, 0, i, 100, handle);
END ChangeVdiFilename;


PROCEDURE SetLineoffset (handle, offset: INTEGER);
BEGIN
 VDIIntIn[0]:= offset;
 VDICall (5, 0, 1, 101, handle);
END SetLineoffset;


PROCEDURE InitSystemfont (handle: INTEGER; VAR header: ARRAY OF WORD);
BEGIN
 VDIIntIn[0]:= MagicSys.WordToInt (header[0]);
 VDIIntIn[1]:= MagicSys.WordToInt (header[1]);
 VDICall (5, 0, 2, 102, handle);
END InitSystemfont;


(*#######################################################################*)

VAR old:   ADDRESS;
    trick: POINTER TO ADDRESS;

PROCEDURE SetInputmode (handle, device, mode: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= device;
 VDIIntIn[1]:= mode;
 VDICall(33, 0, 2, 0, handle);
 RETURN VDIIntOut[0];
END SetInputmode;


PROCEDURE InputLocatorRQ (handle, x, y: INTEGER; VAR xo, yo: INTEGER; VAR term: CHAR);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDICall(28, 1, 0, 0, handle);
 xo:= VDIPtsOut[0];
 yo:= VDIPtsOut[1];
 term:= CHR(VDIIntOut[0]);
END InputLocatorRQ;


PROCEDURE InputLocatorSM (handle, x, y: INTEGER; VAR xo, yo: INTEGER;
                     VAR term: CHAR): BITSET;
VAR bs: BITSET;
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDICall(28, 1, 0, 0, handle);
 xo:= VDIPtsOut[0];
 yo:= VDIPtsOut[1];
 term:= CHR(VDIIntOut[0]);
 ASSEMBLER
  MOVE.W  D0, bs(A6)
 END;
 RETURN bs;
END InputLocatorSM;


PROCEDURE InputValuatorRQ (handle, in: INTEGER; VAR out: INTEGER; VAR term: CHAR);
BEGIN
 VDIIntIn[0] := in;
 VDICall (29, 0, 1, 0, handle);
 out:= VDIIntOut[0];
 term:= CHR(VDIIntOut[1]);
END InputValuatorRQ;


PROCEDURE InputValuatorSM (handle, in: INTEGER; VAR out: INTEGER;
                      VAR term: CHAR): BITSET;
BEGIN
 VDIIntIn[0] := in;
 VDICall (29, 0, 1, 0, handle);
 out:= VDIIntOut[0];
 term:= CHR(VDIIntOut[1]);
 RETURN BITSET(VDIControl[4]);
END InputValuatorSM;


PROCEDURE InputChoiceRQ (handle, in: INTEGER; VAR out: INTEGER);
BEGIN
 VDIIntIn[0] := in;
 VDICall (30, 0, 1, 0, handle);
 out:= VDIIntOut[0];
END InputChoiceRQ;


PROCEDURE InputChoiceSM (handle: INTEGER; VAR choice: INTEGER ): INTEGER;
BEGIN
 VDICall (30, 0, 0, 0, handle);
 choice:= VDIIntOut [0];
 RETURN VDIControl[4];
END InputChoiceSM;


PROCEDURE InputStringRQ (handle, len: INTEGER; echo: BOOLEAN;
                    VAR xy: ARRAY OF WORD;
                    VAR string: ARRAY OF CHAR);
VAR h, i: INTEGER;
BEGIN
 VDIIntIn[0]:= len;
 IF echo THEN  VDIIntIn[1]:= 1;  ELSE  VDIIntIn[1]:= 0;  END;
 VDIPtsIn[0]:= MagicSys.WordToInt (xy[0]);
 VDIPtsIn[1]:= MagicSys.WordToInt (xy[1]);
 VDICall (31, 1, 2, 0, handle);
 h:= VDIControl[4] - 1;
 FOR i:= 0 TO h DO string[i]:= CHR(VDIIntOut[i]) END;
 string [h + 1]:= 0C;
END InputStringRQ;


PROCEDURE InputStringSM (handle, len: INTEGER; echo: BOOLEAN;
                    VAR xy: ARRAY OF WORD;
                    VAR string: ARRAY OF CHAR): INTEGER;
VAR h, i: INTEGER;
BEGIN
 VDIIntIn[0]:= len;
 IF echo THEN  VDIIntIn[1]:= 1;  ELSE  VDIIntIn[1]:= 0;  END;
 VDIPtsIn[0]:= MagicSys.WordToInt (xy[0]);
 VDIPtsIn[1]:= MagicSys.WordToInt (xy[1]);
 VDICall (31, 1, 2, 0, handle);
 h:= VDIControl[4] - 1;
 FOR i:= 0 TO h DO string[i]:= CHR(VDIIntOut[i]) END;
 string [h + 1]:= 0C;
 RETURN VDIControl[4];
END InputStringSM;


PROCEDURE SetMouseform (handle: INTEGER; VAR form: ARRAY OF WORD);
BEGIN
 old:= VDIPB.intin;
 VDIPB.intin:= ADR (form);
 VDICall (111, 0, 37, 0, handle);
 VDIPB.intin:= old;
END SetMouseform;


PROCEDURE ShowCursor (handle: INTEGER; reset: BOOLEAN);
BEGIN
 IF reset THEN  VDIIntIn[0]:= 0;  ELSE  VDIIntIn[0]:= 1;  END;
 VDICall (122, 0, 1, 0, handle);
END ShowCursor;


PROCEDURE HideCursor (handle: INTEGER);
BEGIN
 VDICall (123, 0, 0, 0, handle);
END HideCursor;


PROCEDURE SampleMouse (handle: INTEGER; VAR stat: BITSET; VAR x, y: INTEGER);
BEGIN
 VDICall (124, 0, 0, 0, handle);
 stat:= BITSET(VDIIntOut[0]);
 x:= VDIPtsOut[0];
 y:= VDIPtsOut[1];
END SampleMouse;


PROCEDURE ExTimerVector (handle: INTEGER; new: ADDRESS;
                         VAR intervall: INTEGER): ADDRESS;
BEGIN
 trick:= ADR (VDIControl[7]);  trick^:= new;
 VDICall (118, 0, 0, 0, handle);
 intervall:= VDIIntOut[0];
 trick:= ADR (VDIControl[9]);
 RETURN trick^;
END ExTimerVector;


PROCEDURE ExButtonVector (handle: INTEGER; new: ADDRESS): ADDRESS;
BEGIN
 trick:= ADR (VDIControl[7]); trick^:= new;
 VDICall (125, 0, 0, 0, handle);
 trick:= ADR (VDIControl[9]);
 RETURN trick^;
END ExButtonVector;


PROCEDURE ExMovementVector (handle: INTEGER; new: ADDRESS): ADDRESS;
BEGIN
 trick:= ADR (VDIControl[7]); trick^:= new;
 VDICall (126, 0, 0, 0, handle);
 trick:= ADR (VDIControl[9]);
 RETURN trick^;
END ExMovementVector;


PROCEDURE ExCursorVector (handle: INTEGER; new: ADDRESS): ADDRESS;
BEGIN
 trick:= ADR (VDIControl[7]); trick^:= new;
 VDICall (127, 0, 0, 0, handle);
 trick:= ADR (VDIControl[9]);
 RETURN trick^;
END ExCursorVector;


PROCEDURE SampleKeyboard (handle: INTEGER; VAR status: BITSET);
BEGIN
 VDICall (128, 0, 0, 0, handle);
 status:= BITSET(VDIIntOut[0]);
END SampleKeyboard;


(*#######################################################################*)

VAR i, h: INTEGER;


PROCEDURE ExtendedInquire (handle, wich: INTEGER; VAR out: ARRAY OF WORD);
VAR i: INTEGER;
BEGIN
 VDIIntIn[0]:= ORD(wich);
 VDICall (102, 0, 1, 0, handle);
 FOR i:=  0 TO 44 DO out[i]:= WORD(VDIIntOut[i]); END;
 FOR i:= 45 TO 56 DO out[i]:= WORD(VDIPtsOut[i-45]); END;
END ExtendedInquire;


PROCEDURE InquireColor (handle, color: INTEGER; set: BOOLEAN; VAR rgb: ARRAY OF WORD);
BEGIN
 VDIIntIn[0]:= color;
 IF set THEN  VDIIntIn[0]:= 0;  ELSE  VDIIntIn[0]:= 1;  END;
 VDICall (26, 0, 2, 0, handle);
 rgb[0]:= WORD(VDIIntOut[1]);
 rgb[1]:= WORD(VDIIntOut[2]);
 rgb[2]:= WORD(VDIIntOut[3]);
END InquireColor;


PROCEDURE InquireLine (handle: INTEGER; VAR attrib: ARRAY OF WORD);
BEGIN
 VDICall (35, 0, 0, 0, handle);
 attrib[0]:= WORD(VDIIntOut[0]);
 attrib[1]:= WORD(VDIIntOut[1]);
 attrib[2]:= WORD(VDIIntOut[2]);
 attrib[3]:= WORD(VDIPtsOut[0]);
END InquireLine;


PROCEDURE InquireMarker (handle: INTEGER; VAR attrib: ARRAY OF WORD);
BEGIN
 VDICall (36, 0, 0, 0, handle);
 attrib[0]:= WORD(VDIIntOut[0]);
 attrib[1]:= WORD(VDIIntOut[1]);
 attrib[2]:= WORD(VDIIntOut[2]);
 attrib[3]:= WORD(VDIPtsOut[1]);
END InquireMarker;


PROCEDURE InquireFill (handle: INTEGER; VAR attrib: ARRAY OF WORD);
VAR i: INTEGER;
BEGIN
 VDICall (37, 0, 0, 0, handle);
 FOR i:= 0 TO 3 DO attrib[i]:= WORD(VDIIntOut[i]); END;
END InquireFill;


PROCEDURE InquireText (handle: INTEGER; VAR attrib: ARRAY OF WORD);
VAR i: INTEGER;
BEGIN
 VDICall (38, 0, 0, 0, handle);
 FOR i:= 0 TO 5 DO attrib[i]:= WORD(VDIIntOut[i]); END;
 FOR i:= 6 TO 9 DO attrib[i]:= WORD(VDIPtsOut[i-6]); END;
END InquireText;


PROCEDURE InquireTextextent (handle: INTEGER; string: ARRAY OF CHAR;
                      VAR extent: ARRAY OF WORD);
BEGIN
 i:= 0;
 h:= HIGH(string);
 LOOP
  IF (i > h) OR (string[i] = 0C) THEN EXIT END;
  VDIIntIn[i]:= ORD(string[i]);  INC (i);
 END;
 VDICall (116, 0, i, 0, handle);
 extent[0]:= WORD(VDIPtsOut[0]);
 extent[1]:= WORD(VDIPtsOut[1]);
 extent[2]:= WORD(VDIPtsOut[2]);
 extent[3]:= WORD(VDIPtsOut[3]);
 extent[4]:= WORD(VDIPtsOut[4]);
 extent[5]:= WORD(VDIPtsOut[5]);
 extent[6]:= WORD(VDIPtsOut[6]);
 extent[7]:= WORD(VDIPtsOut[7]);
END InquireTextextent;


PROCEDURE InquireCharwidth (handle: INTEGER; ch: CHAR; VAR width, left, right: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= ORD(ch);
 VDICall (117, 0, 1, 0, handle);
 width:= VDIPtsOut[0];
 left:= VDIPtsOut[2];
 right:= VDIPtsOut[4];
 RETURN VDIIntOut[0];
END InquireCharwidth;


PROCEDURE InquireFacename (handle, element: INTEGER; VAR name: ARRAY OF CHAR): INTEGER;
VAR i: INTEGER;
BEGIN
 VDIIntIn[0]:= element;
 VDICall (130, 0, 1, 0, handle);
 FOR i:= 1 TO 32 DO name[i-1]:= CHR(VDIIntOut[i]) END;
 RETURN VDIIntOut[0];
END InquireFacename;
 

PROCEDURE InquireCellarray (handle: INTEGER; VAR pxy: ARRAY OF WORD;
                     len, rows: INTEGER; VAR elUsed, rowsUsed, status: INTEGER;
                     VAR colArray: ARRAY OF WORD);
VAR i: INTEGER;
BEGIN
 FOR i:= 0 TO 3 DO VDIPtsIn[i]:= MagicSys.WordToInt (pxy[i]); END;
 VDIControl[7]:= len;
 VDIControl[8]:= rows;
 old:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (colArray);
 VDICall (27, 2, 0, 0, handle);
 VDIPB.ptsin:= old;
 elUsed:= VDIControl[9];
 rowsUsed:= VDIControl[10];
 status:= VDIControl[11];
END InquireCellarray;


PROCEDURE InquireInputmode (handle: INTEGER; dev: INTEGER): INTEGER;
BEGIN
 VDIIntIn[0]:= ORD(dev);
 VDICall (115, 0, 1, 0, handle);
 RETURN VDIIntOut[0];
END InquireInputmode;


PROCEDURE InquireFaceinfo (handle : INTEGER; VAR minADE, maxADE, maxWidth: INTEGER;
                    VAR dist: ARRAY OF WORD;  VAR effects: ARRAY OF WORD);
VAR i: INTEGER;
BEGIN
 VDICall (131, 0, 0, 0, handle);
 minADE:= VDIIntOut[0];
 maxADE:= VDIIntOut[1];
 FOR i:= 0 TO 4 DO dist[i]:= WORD(VDIPtsOut[2 * i + 1]); END;
 maxWidth:= VDIPtsOut[0];
 effects[0]:= MagicSys.IntToWord (VDIPtsOut[2]);
 effects[1]:= MagicSys.IntToWord (VDIPtsOut[4]);
 effects[2]:= MagicSys.IntToWord (VDIPtsOut[6]);
END InquireFaceinfo;


(*#######################################################################*)

VAR c:      CARDINAL;
    oldPts: ADDRESS;
    oldInt: ADDRESS;


PROCEDURE Polyline (handle, count: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(6, count, 0, 0, handle);
 VDIPB.ptsin:= oldPts;
END Polyline;


PROCEDURE Polymarker (handle, count: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(7, count, 0, 0, handle);
 VDIPB.ptsin:= oldPts;
END Polymarker;


PROCEDURE Text (handle, x, y: INTEGER; string: ARRAY OF CHAR);
BEGIN
 c:= 0;
 WHILE (c <= HIGH(string)) AND (string[c] # 0C) DO
  VDIIntIn[c]:= ORD(string[c]);  INC(c);
 END;
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDICall(8, 1, c, 0, handle);
END Text;


PROCEDURE FilledArea (handle, count: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(9, count, 0, 0, handle);
 VDIPB.ptsin:= oldPts;
END FilledArea;


PROCEDURE CellArray (handle, len, used, rows, mode: INTEGER;
                     VAR pxy, color: ARRAY OF WORD);
BEGIN
 VDIControl[7]:= len;
 VDIControl[8]:= used;
 VDIControl[9]:= rows;
 VDIControl[10]:= mode;
 oldPts:= VDIPB.intin;
 oldInt:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDIPB.intin:= ADR (color);
 VDICall(10, 2, len * rows, 0, handle);
 VDIPB.ptsin:= oldPts;
 VDIPB.intin:= oldInt;
END CellArray;


PROCEDURE ContourFill (handle, x, y, index: INTEGER);
BEGIN
 VDIIntIn[0]:= index;
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDICall(103, 1, 1, 0, handle);
END ContourFill;


PROCEDURE FillRectangle (handle: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(114, 2, 0, 0, handle);
 VDIPB.ptsin:= oldPts;
END FillRectangle;


PROCEDURE Bar (handle: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(11, 2, 0, 1, handle);
 VDIPB.ptsin:= oldPts;
END Bar;


PROCEDURE Arc (handle, x, y, rad, beg, end: INTEGER);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= 0;
 VDIPtsIn[3]:= 0;
 VDIPtsIn[4]:= 0;
 VDIPtsIn[5]:= 0;
 VDIPtsIn[6]:= rad;
 VDIPtsIn[7]:= 0;
 VDIIntIn[0]:= beg;
 VDIIntIn[1]:= end;
 VDICall(11, 4, 2, 2, handle);
END Arc;


PROCEDURE Pie (handle, x, y, rad, beg, end: INTEGER);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= 0;
 VDIPtsIn[3]:= 0;
 VDIPtsIn[4]:= 0;
 VDIPtsIn[5]:= 0;
 VDIPtsIn[6]:= rad;
 VDIPtsIn[7]:= 0;
 VDIIntIn[0]:= beg;
 VDIIntIn[1]:= end;
 VDICall(11, 4, 2, 3, handle);
END Pie;


PROCEDURE Circle (handle, x, y, rad: INTEGER);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= 0;
 VDIPtsIn[3]:= 0;
 VDIPtsIn[4]:= rad;
 VDIPtsIn[5]:= 0;
 VDICall(11, 3, 0, 4, handle);
END Circle;


PROCEDURE Ellipse (handle, x, y, xrad, yrad: INTEGER);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= xrad;
 VDIPtsIn[3]:= yrad;
 VDICall(11, 2, 0, 5, handle);
END Ellipse;


PROCEDURE EllipticalArc (handle, x, y, xrad, yrad, beg, end: INTEGER);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= xrad;
 VDIPtsIn[3]:= yrad;
 VDIIntIn[0]:= beg;
 VDIIntIn[1]:= end;
 VDICall(11, 2, 2, 6, handle);
END EllipticalArc;


PROCEDURE EllipticalPie (handle, x, y, xrad, yrad, beg, end: INTEGER);
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= xrad;
 VDIPtsIn[3]:= yrad;
 VDIIntIn[0]:= beg;
 VDIIntIn[1]:= end;
 VDICall(11, 2, 2, 7, handle);
END EllipticalPie;


PROCEDURE RoundedRectangle (handle: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(11, 2, 0, 8, handle);
 VDIPB.ptsin:= oldPts;
END RoundedRectangle;


PROCEDURE FilledRoundedRectangle (handle: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 oldPts:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 VDICall(11, 2, 0, 9, handle);
 VDIPB.ptsin:= oldPts;
END FilledRoundedRectangle;


PROCEDURE JustifiedText (handle, x, y, len, wspace, cspace: INTEGER;
                         string: ARRAY OF CHAR);
BEGIN
 c:= 0;
 WHILE (c < HIGH(string)) OR (string[c] # 0C) DO
  VDIIntIn[c+2]:= ORD(string[c]);
 END;
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDIPtsIn[2]:= len;
 VDIPtsIn[3]:= 0;
 VDIIntIn[0]:= wspace;
 VDIIntIn[1]:= cspace;
 VDICall(11, 2, 0, 10, handle);
END JustifiedText;


(*#######################################################################*)

VAR ptsIn,
    intIn:      ADDRESS;
    control7:   POINTER TO ADDRESS;
    control9:   POINTER TO ADDRESS;


PROCEDURE CopyRasterOpaque (handle, mode: INTEGER;
                      VAR pxy, srcMFDB, destMFDB: ARRAY OF WORD);
BEGIN
 VDIIntIn[0]:= mode;
 ptsIn:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 control7^:= ADR (srcMFDB);
 control9^:= ADR (destMFDB);
 VDICall(109, 4, 1, 0, handle);
 VDIPB.ptsin:= ptsIn;
END CopyRasterOpaque;


PROCEDURE CopyRasterTransparent (handle, mode, cSet, cNotset: INTEGER;
                           VAR pxy, srcMFDB, destMFDB: ARRAY OF WORD);
BEGIN
 VDIIntIn[0]:= mode;
 VDIIntIn[1]:= cSet;
 VDIIntIn[2]:= cNotset;
 ptsIn:= VDIPB.ptsin;
 VDIPB.ptsin:= ADR (pxy);
 control7^:= ADR (srcMFDB);
 control9^:= ADR (destMFDB);
 VDICall(121, 4, 1, 0, handle);
 VDIPB.ptsin:= ptsIn;
END CopyRasterTransparent;


PROCEDURE TransformForm (handle: INTEGER; VAR srcMFDB, destMFDB: ARRAY OF WORD);
BEGIN
 control7^:= ADR (srcMFDB);
 control9^:= ADR (destMFDB);
 VDICall(110, 0, 0, 0, handle);
END TransformForm;


PROCEDURE GetPixel (handle, x, y: INTEGER; VAR index: INTEGER): BOOLEAN;
BEGIN
 VDIPtsIn[0]:= x;
 VDIPtsIn[1]:= y;
 VDICall(105, 1, 0, 0, handle);
 index:= VDIIntOut[1];
 RETURN VDIIntOut[0] = 0;
END GetPixel;


BEGIN
 VDIPB.control:= ADR (VDIControl);
 VDIPB.intin:=   ADR (VDIIntIn);
 VDIPB.ptsin:=   ADR (VDIPtsIn);
 VDIPB.intout:=  ADR (VDIIntOut);
 VDIPB.ptsout:=  ADR (VDIPtsOut);
 vdipb:= ADR (VDIPB);
 control7:= ADR (VDIControl[7]);
 control9:= ADR (VDIControl[9]);
END MagicVDI.

