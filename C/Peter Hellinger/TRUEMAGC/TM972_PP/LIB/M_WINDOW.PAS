UNIT M_Windows;

INTERFACE

USES Basics, AES;

CONST wBell =          lBit0;  (* Kling Glîckchen klingelingeling      *)
      wColor =         lBit1;  (* Hintergrundfarbe des Fensters Ñndern *)
      wFulled =        lBit2;  (* Fenster auf volle Grîûe bringen      *)
      wTopped =        lBit3;  (* Fenster toppen                       *)
      wHSlide =        lBit4;  (* Horizontal-Slider setzen             *)
      wVSlide =        lBit5;  (* Vertikal-Slider setzen               *)
      wSized =         lBit6;  (* Fenstergrîûe Ñndern                  *)
      wMoved =         lBit7;  (* Fensterposition Ñndern               *)
      wSizePos =       lBit8;  (* Fenster auf Grîûe + Position bringen *)
      wChangeFont =    lBit9;  (* Font Ñndern                          *)
      wClose =         lBit10; (* Fenster schliessen                   *)
      wBottomed =      lBit11; (* Fenster in Hintergrund legen         *)
      wIconify =       lBit12; (* Fenster schrumpfen                   *)
      wAllIconify =    lBit13; (* Programm "schrumpfen"                *)
      wUniconify =     lBit14; (* Fenster wieder auf alte Grîûe        *)
      wHSUpdate =      lBit15; (* Horizontalen Slider updaten          *)
      wVSUpdate =      lBit16; (* Vertikalen Slider updaten            *)
      wCallback =      lBit17; (* Handler nach AusfÅhren der Aktionen erneut aufrufen *)
      wTempClose =     lBit18; (* Fenster temporÑr schliessen          *)
      wReopen =        lBit19; (* temporÑr geschlossenes Fenster îffnen *)
      wSetAsterik =    lBit20; (* Sternchen in Titelzeile platzieren   *)
      wDelAsterik =    lBit21; (* Sternchen aus Titelzeile lîschen     *)
      wRedraw =        lBit22; (* Redraw des Fensters auslîsen, ins spec steht die FlÑche *)
      wRedrawWin =     lBit23; (* Redraw des Fensters auslîsen, komplettes Fenster *)
      wKeyDone =       lBit24; (* Muss gesetzt sein, wenn der Tastendruck aus der
                                * WinKeyboard-Message verarbeitet werden konnte.
                                *)


(* Folgende Actionflags werden ab Version 4.12 im Flagset moreaction
 * des Windowparameterblocks ausgewertet
 *)
CONST wlHSUpdate =     lBit0; (* wie wHSUpdate, Daten jedoch in longex *)
      wlVSUpdate =     lBit1; (* wie wVSUpdate, Daten jedoch in longex *)

CONST VSlider =        0;
      HSlider =        1;

TYPE  tExData =        ARRAY [0..15] OF INTEGER;
      tExLong =        ARRAY [0..15] OF LONGINT;

TYPE  PtrWinPara =     ^WinParameter;
      WinParameter =   RECORD
                        window:     INTEGER;
                        mx, my:     INTEGER;
                        message:    INTEGER;
                        spec:       tRect;
                        extended:   tExData;
                        action:     LONGBITSET;
                        res:        POINTER;
                        tree:       POINTER;    (* Ab Lib-Version $407 *)
                        moreaction: LONGBITSET; (* Ab Lib-Version $412 *)
                        shortex:    tExdata;    (* Ab Lib-Version $412 *)
                        longex:     tExLong;    (* Ab Lib-Version $412 *)
                       END;

TYPE WindowHandler =   PROCEDURE (wp: PtrWinPara);

CONST WinMenu =        lBit0;
      WinText =        lBit1;
      WinDial =        lBit2;
      WinDrag =        lBit3;
      WinMaxsize =     lBit4;
      WinArrows =      lBit5;
      WinAlert =       lBit6;
      WinTopAllowed =  lBit7;  (* Dialogfenster wird auch bei WinTop gemeldet *)
      WinTransparent = lBit8;  (* Es wird kein Hintergrund gezeichnet *)
      WinBackclick =   lBit9;  (* Fenster kann nach MultiTOS-Methode im Hinter-
                                * grund bedient werden. Arbeitet ab AES 3.3x!
                                *)
      WinNoRedraw =    lBit10; (* Es werden keine automatischen Redraws fÅr
                                * das Fenster gemacht. Die Appliaktion ist 
                                * selbst fÅr den Redraw verantwortlich.
                                *)
      WinIconOpen =    lBit11; (* Fenster iconified îffnen *)
      WinShading =     lBit12; (* Das Fenster kann geshaded werden (siehe WINX) *)
      WinIconTitle =   lBit13; (* Icontext als Title eintragen, wenn das Fenster
                                * iconifiziert wird.
                                *)
      WinNoCycle =     lBit14; (* Fester nicht cyclen *)
      WinMultiRsc =    lBit15; (* der OpenWindow Åbergebene Zeiger ist ein
                                * Zeiger auf folgende Struktur:
                                *)

CONST MaxResource =   15; (* Maximal 16 Resourcen pro Fenster *)

CONST tbUp =    0;
      tbDown =  1;
      tbLeft =  2;
      tbRight = 3;
      tbMenu =  4;
      tbIcon =  5;

TYPE  WinResource =   RECORD
                       tree: tObjctree; (* Adresse des Objektbaums *)
                       xpos: INTEGER;   (* relative X-Position im Fenster *)
                       ypos: INTEGER;   (* relative Y-Position im Fenster *)
                       mode: INTEGER;
                       res1: INTEGER;
                       res2: POINTER;
                      END;

      WinTreelist =   ARRAY [0..MaxResource] OF WinResource;
      
                  
FUNCTION OpenWindow (handler: WindowHandler; 
                     element: BITSET;  extended: LONGBITSET;
                     backcolor, backrast: INTEGER;
                     x, y, w, h, xo, yo, wo, ho: INTEGER;
                     name, info: STRING;
                     rsc: POINTER; exinfo: POINTER): INTEGER;
PROCEDURE CloseWindow (VAR win: INTEGER);
PROCEDURE TempCloseWin (win: INTEGER);
PROCEDURE ReopenWin (win: INTEGER);
FUNCTION  WinOpen (win: INTEGER): BOOLEAN;
FUNCTION  DisposeWindows: INTEGER;
PROCEDURE RedrawObjc (win: INTEGER; tree: POINTER; entry, depth: INTEGER; clip: tRect);
PROCEDURE RedrawWindow (win, entry, depth: INTEGER; clip: tRect);
PROCEDURE RedrawScreen;

TYPE RewriteProc = PROCEDURE;

PROCEDURE RewriteWindow (win, handle: INTEGER; prc: RewriteProc);
PROCEDURE SetWinName (win: INTEGER; name: STRING);
FUNCTION  WinName (win: INTEGER): STRING;
PROCEDURE SetWinAsterik (win: INTEGER);
PROCEDURE DelWinAsterik (win: INTEGER);
PROCEDURE SetWinInfo (win: INTEGER; info: STRING);
FUNCTION  WinInfo (win: INTEGER): STRING;
PROCEDURE SetWinTop (win: INTEGER);
PROCEDURE SetWinBottom (win: INTEGER);
FUNCTION  WinTop (nodials: BOOLEAN): INTEGER;
PROCEDURE GEMTop (VAR win: INTEGER; VAR own: BOOLEAN);
PROCEDURE TopNext;
PROCEDURE SetWinFull (win: INTEGER);
PROCEDURE SetWinRect (win: INTEGER; rect: tRect);
PROCEDURE SetWinColor (win: INTEGER; color, back: INTEGER);
PROCEDURE SetWinPos (win: INTEGER; xx, yy: INTEGER);
PROCEDURE SetWinSize (win: INTEGER; ww, hh: INTEGER);
PROCEDURE SetWinSlider (win, which, pos, size: INTEGER);
PROCEDURE SetWinIcon (win: INTEGER; icon: PtrCICONBLK);
PROCEDURE SetWinShade (win: INTEGER);
PROCEDURE SetIcontext (win: INTEGER; text: STRING);
PROCEDURE IconifyWindow (win: INTEGER; rect: tRect; iconify: BOOLEAN);
FUNCTION  WinIconified (win: INTEGER): BOOLEAN;
PROCEDURE GetWinRect (win: INTEGER; VAR rect: tRect);
PROCEDURE GetWorkRect (win: INTEGER; VAR rect: tRect);
PROCEDURE GetUseableRect (win: INTEGER; VAR rect: tRect);
FUNCTION  GetWinExinfo (win: INTEGER): POINTER;
PROCEDURE PreventTopping (prevent: BOOLEAN);
FUNCTION  GetObjctree (win: INTEGER): POINTER;
FUNCTION  GetMenutree (win: INTEGER): POINTER;
FUNCTION  RectList (win: INTEGER; flag: INTEGER; VAR rect: tRect): BOOLEAN;
FUNCTION  RcIntersect (VAR rc1, rc2: tRect): BOOLEAN;
PROCEDURE SendSpecMessage (win, winmsg, mx, my: INTEGER; VAR r: tRect; 
                           VAR ex, sx: tExdata; VAR lx: tExLong);

IMPLEMENTATION

USES M_Sys, M_Strings;
 
VAR p1, p2: CSTRING;

FUNCTION RectList (win: INTEGER; flag: INTEGER; VAR rect: tRect): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= flag;
 CallMagic (2427);
 RectList:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*RectList*);

FUNCTION RcIntersect (VAR rc1, rc2: tRect): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rc1);
 App^.MagicPB^.AddrIn[1]:= ADDR (rc2);
 CallMagic (2428);
 RcIntersect:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*RcIntersect*);

PROCEDURE RedrawObjc (win: INTEGER; tree: POINTER; entry, depth: INTEGER; clip: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (clip);
 App^.MagicPB^.AddrIn[1]:= tree;
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= entry;
 App^.MagicPB^.IntIn[2]:= depth;
 CallMagic (2402);
END (*RedrawObjc*); 

PROCEDURE RedrawWindow (win, entry, depth: INTEGER; clip: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (clip);
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= entry;
 App^.MagicPB^.IntIn[2]:= depth;
 CallMagic (2403);
END (*RedrawWindow*); 

PROCEDURE RedrawScreen;
BEGIN
 CallMagic (2404);
END (*RedrawScreen*);

FUNCTION OpenWindow (handler: WindowHandler; 
                     element: BITSET;  extended: LONGBITSET;
                     backcolor, backrast: INTEGER;
                     x, y, w, h, xo, yo, wo, ho: INTEGER;
                     name, info: STRING;
                     rsc: POINTER; exinfo: POINTER): INTEGER;
VAR hndl: RECORD
           CASE INTEGER OF
            0: (f: WindowHandler);
            1: (p: POINTER);
          END;
BEGIN
 PascalToCString (name, @p1);
 PascalToCString (info, @p2);
 hndl.f:= handler;
 App^.MagicPB^.AddrIn[0]:= hndl.p;
 App^.MagicPB^.IntIn[ 0]:= BitsetToWord (element);
 App^.MagicPB^.IntIn[ 1]:= backcolor;
 App^.MagicPB^.IntIn[ 2]:= backrast;
 App^.MagicPB^.IntIn[ 3]:= x;
 App^.MagicPB^.IntIn[ 4]:= y;
 App^.MagicPB^.IntIn[ 5]:= w;
 App^.MagicPB^.IntIn[ 6]:= h;
 App^.MagicPB^.IntIn[ 7]:= xo;
 App^.MagicPB^.IntIn[ 8]:= yo;
 App^.MagicPB^.IntIn[ 9]:= wo;
 App^.MagicPB^.IntIn[10]:= ho;
 App^.MagicPB^.longIn[0]:= LBitsetToLong (extended);
 App^.MagicPB^.AddrIn[1]:= ADDR (p1);
 App^.MagicPB^.AddrIn[2]:= ADDR (p2);
 App^.MagicPB^.AddrIn[3]:= rsc;
 App^.MagicPB^.AddrIn[4]:= exinfo;

 CallMagic (2400);
 OpenWindow:= App^.MagicPB^.IntOut[0];
END (*WindOpen*);

PROCEDURE CloseWindow (VAR win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2401);
END (*CloseWindow*);

FUNCTION DisposeWindows: INTEGER;
BEGIN
 CallMagic (2424);
 DisposeWindows:= App^.MagicPB^.IntOut[0];
END (*DisposeWindows*);

PROCEDURE SetWinName (win: INTEGER; name: STRING);
BEGIN
 PascalToCString (name, @p1);
 App^.MagicPB^.AddrIn[0]:= ADDR (p1);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2405);
END (*SetWinName*);

PROCEDURE SetWinInfo (win: INTEGER; info: STRING);
BEGIN
 PascalToCString (info, @p1);
 App^.MagicPB^.AddrIn[0]:= ADDR (p1);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2409);
END (*SetWinInfo*);

FUNCTION WinName (win: INTEGER): STRING;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (p1);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2406);
 WinName:= StrPas (p1);
END (*WinName*);

FUNCTION WinInfo (win: INTEGER): STRING;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (p1);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2410);
 WinInfo:= StrPas (p1);
END (*WinInfo*);

PROCEDURE SetWinAsterik (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2407);
END (*SetWinAsterik*);

PROCEDURE DelWinAsterik (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2408);
END (*DelWinAsterik*);

PROCEDURE SetWinTop (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2411);
END (*SetWinTop*);

PROCEDURE SetWinBottom (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2430);
END (*SetWinBottom*);

FUNCTION WinTop (nodials: BOOLEAN): INTEGER;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (nodials);
 CallMagic (2412);
 WinTop:= App^.MagicPB^.IntOut[0];
END (*WinTop*);

PROCEDURE TopNext;
BEGIN
 CallMagic (2413);
END (*TopNext*);

PROCEDURE SetWinFull (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2414);
END (*SetWinFull*);

PROCEDURE SetWinRect (win: INTEGER; rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2415);
END (*SetWinRect*);

PROCEDURE SetWinColor  (win: INTEGER; color, back: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= color;
 App^.MagicPB^.IntIn[2]:= back;
 CallMagic (2416);
END (*SetWinColor*);

PROCEDURE SetWinPos (win: INTEGER; xx, yy: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= xx;
 App^.MagicPB^.IntIn[2]:= yy;
 CallMagic (2417);
END (*SetWinPos*);

PROCEDURE SetWinSize (win: INTEGER; ww, hh: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= ww;
 App^.MagicPB^.IntIn[2]:= hh;
 CallMagic (2418);
END (*SetWinSize*);

PROCEDURE GetWinRect (win: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2420);
END (*GetWinRect*);

PROCEDURE GetWorkRect (win: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2421);
END (*GetWorkRect*);

PROCEDURE GetUseableRect (win: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2422);
END (*GetUseableRect*);

PROCEDURE SetWinSlider (win, which, pos, size: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= which;
 App^.MagicPB^.IntIn[2]:= pos;
 App^.MagicPB^.IntIn[3]:= size;
 CallMagic (2419);
END (*SetWinSlider*);

PROCEDURE PreventTopping (prevent: BOOLEAN);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (prevent);
 CallMagic (2423);
END (*PreventTopping*);

FUNCTION GetObjctree (win: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2425);
 GetObjctree:= App^.MagicPB^.AddrOut[0];
END (*GetObjctree*);

FUNCTION GetMenutree (win: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2426);
 GetMenutree:= App^.MagicPB^.AddrOut[0];
END (*GetMenutree*);

PROCEDURE SendSpecMessage (win, winmsg, mx, my: INTEGER; VAR r: tRect;
                          VAR ex, sx: tExdata; VAR lx: tExLong);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= winmsg;
 App^.MagicPB^.IntIn[2]:= mx;
 App^.MagicPB^.IntIn[3]:= my;
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.AddrIn[1]:= ADDR (ex);
 App^.MagicPB^.AddrIn[2]:= ADDR (sx);
 App^.MagicPB^.AddrIn[3]:= ADDR (lx);
 CallMagic (2431);
END (*SendSpecMessage*);

PROCEDURE RewriteWindow (win, handle: INTEGER; prc: RewriteProc);
VAR x: RECORD
        CASE INTEGER OF
         0: (f: RewriteProc);
         1: (p: POINTER);
       END;
BEGIN
 x.f:= prc;
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= handle;
 App^.MagicPB^.AddrIn[0]:= x.p;
 CallMagic (2432)
END (*RewriteWindow*);

FUNCTION GetWinExinfo (win: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2433);
 GetWinExinfo:= App^.MagicPB^.AddrOut[0]; 
END (*GetWinExinfo*);

PROCEDURE GEMTop (VAR win: INTEGER; VAR own: BOOLEAN);
BEGIN
 CallMagic (2434);
 win:= App^.MagicPB^.IntOut[0]; 
 own:= BOOLEAN (App^.MagicPB^.IntOut[1]); 
END (*GEMTop*);

PROCEDURE SetWinIcon (win: INTEGER; icon: PtrCICONBLK);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.AddrIn[0]:= icon;
 CallMagic (2435);
END (*SetWinIcon*);

PROCEDURE SetIcontext (win: INTEGER; text: STRING);
BEGIN
 PascalToCString (text, @p1);
 App^.MagicPB^.AddrIn[0]:= ADDR (p1);
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2436);
END (*SetIcontext*);

PROCEDURE IconifyWindow (win: INTEGER; rect: tRect; iconify: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= win;
 App^.MagicPB^.IntIn[1]:= ORD (iconify);
 CallMagic (2437);
END (*IconifyWindow*);

FUNCTION  WinIconified (win: INTEGER): BOOLEAN;
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2438);
 WinIconified:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*WinIconified*);

PROCEDURE TempCloseWin (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2439);
END (*TempCloseWin*);

PROCEDURE ReopenWin (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2440);
END (*TempCloseWin*);

FUNCTION WinOpen (win: INTEGER): BOOLEAN;
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2441);
 WinOpen:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*WinOpen*);

PROCEDURE SetWinShade (win: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= win;
 CallMagic (2442);
END (*SetWinShade*);


END (*M_Windows*).
