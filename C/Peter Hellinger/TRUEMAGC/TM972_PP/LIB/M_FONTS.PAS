UNIT M_Fonts;

INTERFACE 

USES Basics;

CONST   ErrNoFonts =      0;    (* Keine Fonts geladen  *)
        ErrNoGdos =      -1;    (* Kein GDOS            *)
        ErrLessMem =     -2;    (* Kein Speicher        *)
        ErrWorkstation = -3;    (* Workstation nicht Åber M_Appl geîffnet *)

FUNCTION LoadFonts (handle: INTEGER; message: BOOLEAN): INTEGER;
FUNCTION FontsLoaded (handle: INTEGER): INTEGER;
PROCEDURE UnloadFonts (handle: INTEGER);

CONST   FFIRST = 0;
        FNEXT =  1;
        FPREV =  2;
        FLAST =  3;

FUNCTION FontList (handle, flag: INTEGER): INTEGER;
FUNCTION FontAvailable (handle, fontid: INTEGER): BOOLEAN;

TYPE tFontinfo = RECORD
                  name:   ARRAY [0..50] OF CHAR;  (* Name des Fonts           *)
                  id:     WORD;    (* Font-ID                  *)
                  color:  INTEGER; (* Farbindex                *)
                  rot:    INTEGER; (* Rotationsrichtung        *)
                  halign: INTEGER; (* Horizontale Ausrichtung  *)
                  valign: INTEGER; (* Vertikale Ausrichtung    *)
                  chw:    INTEGER; (* Zeichenbreite            *)
                  chh:    INTEGER; (* Zeichenhîhe              *)
                  boxw:   INTEGER; (* Zellenbreite             *)
                  boxh:   INTEGER; (* Zellenhîhe               *)
                  effect: BITSET;  (* Texteffekte              *)
                  min:    INTEGER; (* Minimale Grîûe des Fonts *)
                  max:    INTEGER; (* Maximale Grîûe des Fonts *)
                  point:  INTEGER; (* aktuelle Grîûe des Fonts *)
                  width:  INTEGER; (* Breite bei FSM-Fonts     *)
                  skew:   INTEGER; (* Neigung bei FSM-Fonts    *)
                  typ:    INTEGER; (* Fonttyp                  *)
                  flags:  BITSET;  (* Bit0 = Font Monospaced   *)
                  res:    POINTER; (* Reserviert               *)
                 END;

(* Bits fÅr tFontinfo.flags *)
CONST cfMono = Bit0;


PROCEDURE FontInfo (handle, font: INTEGER; VAR info: tFontinfo);
PROCEDURE UpdateFontInfo (handle: INTEGER; info: tFontinfo);
FUNCTION  FontType (handle, font: INTEGER): INTEGER;
FUNCTION  FontActive (handle: INTEGER): INTEGER;
PROCEDURE FontSelect (handle: INTEGER; font: INTEGER; actual: BOOLEAN);
FUNCTION  FontSize (handle, point: INTEGER; VAR chw, chh, boxw, boxh: INTEGER): INTEGER;
FUNCTION  FontDefsize (handle: INTEGER): INTEGER;
FUNCTION  NextBigger  (handle: INTEGER): INTEGER;
FUNCTION  NextSmaller (handle: INTEGER): INTEGER;
PROCEDURE FontColor (handle, color: INTEGER);
PROCEDURE FontEffect (handle: INTEGER; effekt: BITSET);
FUNCTION  FontRotate (handle, angle: INTEGER): INTEGER;
PROCEDURE FontWidth (handle, width: INTEGER);
PROCEDURE FontSkew (handle, skew: INTEGER);
PROCEDURE FontExtent (handle: INTEGER; CONST str: ARRAY OF CHAR; VAR rect: tPxyRect);
FUNCTION  FontError: INTEGER;

IMPLEMENTATION

{$I COMPOPT.INC}

USES M_Sys;

FUNCTION LoadFonts (handle: INTEGER; message: BOOLEAN): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= ORD (message);
 CallMagic (1400);
 LoadFonts:= App^.MagicPB^.IntOut[0];
END (*LoadFonts*);

FUNCTION FontsLoaded (handle: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1401);
 FontsLoaded:= App^.MagicPB^.IntOut[0];
END (*FontsLoaded*);

PROCEDURE UnloadFonts (handle: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1402);
END (*UnloadFonts*);

FUNCTION FontList (handle, flag: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= flag;
 CallMagic (1403);
 FontList:= App^.MagicPB^.IntOut[0];
END (*FontList*);

FUNCTION FontAvailable (handle, fontid: INTEGER): BOOLEAN;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= fontid;
 CallMagic (1404);
 FontAvailable:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*FontAvailable*);

PROCEDURE FontInfo (handle, font: INTEGER; VAR info: tFontinfo);
BEGIN
 App^.MagicPB^.Addrin[0]:= ADDR (info);
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= font;
 CallMagic (1405);
END (*FontInfo*);

PROCEDURE UpdateFontInfo (handle: INTEGER; info: tFontinfo);
BEGIN
 App^.MagicPB^.Addrin[0]:= ADDR (info);
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1406);
END (*UpdateFontInfo*);

FUNCTION FontActive (handle: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1407);
 FontActive:= App^.MagicPB^.IntOut[0];
END (*FontActive*);

PROCEDURE FontSelect (handle: INTEGER; font: INTEGER; actual: BOOLEAN);
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= font;
 App^.MagicPB^.Intin[2]:= ORD (actual);
 CallMagic (1408);
END (*FontSelect*);

FUNCTION FontSize (handle: INTEGER; point: INTEGER;
                   VAR chw, chh, boxw, boxh: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= point;
 CallMagic (1409);
 chw:= App^.MagicPB^.Intout[1];
 chh:= App^.MagicPB^.Intout[2];
 boxw:= App^.MagicPB^.Intout[3];
 boxh:= App^.MagicPB^.Intout[4];
 FontSize:= App^.MagicPB^.Intout[0];
END (*FontSize*);

FUNCTION FontDefsize (handle: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1410);
 FontDefsize:= App^.MagicPB^.IntOut[0];
END (*NextSize*);

FUNCTION NextBigger (handle: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1411);
 NextBigger:= App^.MagicPB^.IntOut[0];
END (*NextBigger*);

FUNCTION NextSmaller (handle: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1412);
 NextSmaller:= App^.MagicPB^.IntOut[0];
END (*NextSmaller*);

PROCEDURE FontColor (handle, color: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= color;
 CallMagic (1413);
END (*FontColor*);

PROCEDURE FontEffect (handle: INTEGER; effekt: BITSET);
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= BitsetToWord (effekt);
 CallMagic (1414);
END (*FontEffect*);

FUNCTION FontRotate (handle, angle: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= angle;
 CallMagic (1415);
 FontRotate:= App^.MagicPB^.IntOut[0];
END (*FontRotate*);

PROCEDURE FontWidth (handle, width: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= width;
 CallMagic (1416);
END (*FontWidth*);

PROCEDURE FontSkew (handle: INTEGER; skew: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= skew;
 CallMagic (1417);
END (*FontSkew*);

PROCEDURE FontExtent (handle: INTEGER; CONST str: ARRAY OF CHAR; VAR rect: tPxyRect);
BEGIN
 App^.MagicPB^.Addrin[0]:= ADDR (str);
 App^.MagicPB^.Addrin[1]:= ADDR (rect);
 App^.MagicPB^.Intin[0]:= handle;
 CallMagic (1418);
END (*FontExtent*);

FUNCTION FontError (): INTEGER;
BEGIN
 CallMagic (1419);
 FontError:= App^.MagicPB^.Intout[0];
END (*FontError*);

FUNCTION FontType (handle, font: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.Intin[0]:= handle;
 App^.MagicPB^.Intin[1]:= font;
 CallMagic (1420);
 FontType:= App^.MagicPB^.IntOut[0];
END (*FontInfo*);

END (*M_Fonts*).