UNIT M_Dials;

INTERFACE

USES Basics, M_Types, AES;

CONST MoveBox =         17; 
      SpecButton =      18;
      SpecText =        19;
      FrameBox =        20;
      Helpbutton =      21; (* Nicht implementiert - Wozu auch? *)
      CircleButton =    22;
      TripleButton =    23;

CONST TitleText =    127;  (* Titeltext eines Dialogs *)
      Invisible =    126;  (* "unsichtbares" Objekt *)
      SliderBox =    125;  (* Grundobjekt eines Sliders, vom Typ GIBOX *)
      DropCircle =   124;  (* Drop-Circlebutton *)
      DropBox =      123;  (* Dropbox-Objekt *)
      ListBox =      122;  (* Listbox-Objekt *)
      SpecBox =      121;  (* GBox, mit Spezialeffekten *)
      SpecBoxchar =  120;  (* GBoxchar, dessen Zeichen als Shortkey gesetzt wird! *)
      TimerObjc =    119;  (* Timer *)
      HelpObjc =     118;  (* Help-Objekt *)
      Iconbutton =   117;  (* Icon-Button *)
      RegisterCard = 116;  (* Registerkarte *)
      Register =     115;  (* Registerbutton *)
      

PROCEDURE DisposeDials;

CONST aSelect =       lBit0;   (* SELECTED-Flag setzen                   *)
      aDeselect =     lBit1;   (* SELECTED-Flag lîschen                  *)
      aCheck =        lBit2;   (* CHECK-Flag setzen                      *)
      aUncheck =      lBit3;   (* CHECK-Flag lîschen                     *)
      aDisable =      lBit4;   (* Disable-Flag setzen                    *)
      aEnable =       lBit5;   (* Disable-Flag lîschen                   *)
      aTriple1 =      lBit6;   (* Triple-Status 1 setzen                 *)
      aTriple2 =      lBit7;   (* Triple-Status 2 setzen                 *)
      aTriple3 =      lBit8;   (* Triple-Status 3 setzen                 *)
      aSlider =       lBit9;   (* Slider-Positon setzen                  *)
      aBell =         lBit10;  (* Glocke ertînen lassen                  *)
      aAsterik =      lBit11;  (* Sternchen in Fenstertitel zeichnen     *)
      aNoAsterik =    lBit12;  (* Sternchen aus Fenstertitel lîschen     *)
      aDraw =         lBit13;  (* gemeldetes Objekt neuzeichnen          *)
      aDrawSlider =   lBit14;  (* Slider neu zeichnen                    *)
      aDrawChilds =   lBit15;  (* Objekt + Childs des Objekts zeichnen   *)
      aDrawParent =   lBit16;  (* Parent + Childs des Objekts zeichnen   *)
      aDrawDial =     lBit17;  (* Dialog vollstÑndig neu zeichnen        *)
      aDrawList =     lBit18;  (* Objektliste neuzeichnen                *)
      aClose =        lBit19;  (* Dialog beenden                         *)
      aUpdateSlider = lBit20;  (* Slider berechnen und neu setzen        *)
      aTopDialog =    lBit21;  (* Dialog toppen                          *)
      aCallback =     lBit22;  (* Dialoghandler nach Abarbeitung der Flags erneut aufrufen *)
      aDelEdit =      lBit23;  (* Lîscht Eingabefelder im extended-Array *)
      aChangeEdit =   lBit24;  (* In start steht das neue Editfeld       *)
      aDrawLbox =     lBit25;  (* Update und Neuanzeige einer Listbox    *)
      aSetCursor =    lBit26;  (* Cursor im Editfeld setzen              *)
      aKeyUsed =      lBit27;  (* Setzen, wenn ein Tastendruck verarbeitet wurde! *)
      aRes28 =        lBit28;  (* Reserviert                             *)
      aRes29 =        lBit29;  (* Reserviert                             *)
      aRes30 =        lBit30;  (* Reserviert                             *)
      aKillDial =     lBit31;  (* Dialogvariable lîschen                 *)
      


TYPE Dialmode =  (dNormal,      (* "Normaler" Dialog                     *)
                  dSpecial,     (* Spezialdialog zb. Popup               *)
                  dFlydial,     (* fliegender Dialog                     *)
                  dModal,       (* modaler Fensterdialog                 *)
                  dNonmodal);   (* nichtmodaler Fensterdialog            *)

TYPE PtrDialpara =      ^DialParameter;
     DialParameter =    RECORD
                         message: INTEGER;     (* Was ist passiert?    *)
                         tree:    tObjctree;   (* Objektbaum           *)
                         objc:    INTEGER;     (* Welches Objekt?      *)
                         mx, my:  INTEGER;     (* Mausposition         *)
                         key:     tKey;        (* Tastencode           *)
                         asc:     CHAR;        (* Ascii-Code           *)
                         mstate:  BITSET;      (* Maustastenstatus     *)
                         kstate:  BITSET;      (* Sondertastenstatus   *)
                         spec:    tRect;       (* Special-Parameter    *)
                         start:   INTEGER;     (* Edit-Element         *)
                         pos:     INTEGER;     (* Edit-Position        *)
                         action:  LONGBITSET;  (* Was ist noch zu tun? *)
                         list:    ^tCtrlArray; (* Zeiger auf Integer-Array *)
                         res:     POINTER;
                         (* Folgende Werte werden ab Magic 4 Revison 5 eingetragen *)
                         window:  INTEGER;
                         open:    INTEGER;
                         mode:    Dialmode;
                         (* Folgende Werte werden ab Magic 5 Revison 1 eingetragen *)
                         extend:  tRect;
                         moreaction: LONGBITSET;
                        END;

TYPE DialHandler = PROCEDURE (dp: PtrDialpara);

CONST dPos =         lBit0;  (* Dialog positionieren                  *)
      dAllkeys =     lBit1;  (* Alle Tasten im Editfeld melden        *)
      dMouse =       lBit2;  (* Mausbewegung melden                   *)
      dLeaveOut =    lBit3;  (* abbrechen, wenn ausserhalb            *)
      dButton =      lBit4;  (* Ok/Abbruch Mechanik                   *)
      dUpArrow =     lBit5;  (* Pfeil-Oben in Fenster aufnehmen       *)
      dDownArrow =   lBit6;  (* Pfeil-Unten aufnehmen                 *)
      dVSlider =     lBit7;  (* Vertikalen Slider aufnehmen           *)
      dLeftArrow =   lBit8;  (* Pfeil-Links aufnehmen                 *)
      dRightArrow =  lBit9;  (* Pfeil-Rechts aufnehmen                *)
      dHSlider =     lBit10; (* Horizontalen Slider aufnehmen         *)
      dFuller =      lBit11; (* Fenster-Fuller aufnehmen              *)
      dInfo =        lBit12; (* Infozeile aufnehmen                   *)
      dSizer =       lBit13; (* Fenster-Sizer aufnehmen               *)
      dIconifier =   lBit14; (* Iconifier aufnehmen                   *)
      dCenter =      lBit15; (* Dialog zwangsweise zentrieren         *)
      dWintop =      lBit16; (* Der Dialog wird bei M_Windows.WinTop
                              * als Fenster gemeldet, nicht als Dialog!
                              * Dadurch erreichen auch Nachrichten wie 
                              * WinChangeFont den Dialog!
                              *)
      dForceWindow = lBit17; (* Dialog MUSS ein Fenster sein, sonst 
                              * hats keinen Sinn. Nach Opendial steht 
                              * entweder die Fensterkennung, oder -1
                              * in Intin[0] des Magic-Parameterblocks
                              *)
      dWinKeys =     lBit18; (* Cursortasten werden auf die Fenster-
                              * Sliderelemente des Dialogfensters 
                              * abgebildet. Nur sinnvoll, wenn man beim
                              * îffnen des Dialogs auch Sliderelemente
                              * angefordert hat!
                              *)
      dBackclick =   lBit19; (* Dialogfenster kann nach MTOS-Methode 
                              * im Hintergrund bedient werden
                              *)
      dShadow =      lBit20; (* Fuller 'shadowed' das Fenter *)
      dBackColor =   lBit21; (* öbernimmt die Hintergrundfarbe des
                              * Dialogs in den Hintergrund eines 
                              * iconfied Fensters.
                              *)
      dIconTitle =   lBit22; (* Icontext wird Fenstertitel, wenn der Dialog
                              * iconifiziert wird
                              *)
      dIconOpen =    lBit23; (* Dialogfenster wird Iconifiziert geîffnet *)

FUNCTION  OpenDial (tree: POINTER; mode: Dialmode; flags: LONGBITSET;
                    edit, edpos, ok, cancel, xpos, ypos: INTEGER; name: STRING): INTEGER;

PROCEDURE CloseDial (tree: POINTER);

PROCEDURE DialInfo (tree: POINTER; VAR mode: Dialmode; VAR win: INTEGER; VAR open: BOOLEAN);
FUNCTION  NewDial (tree: POINTER; handler: DialHandler): BOOLEAN;
PROCEDURE DisposeDial (tree: POINTER);
PROCEDURE ObjcExtype (tree: POINTER; entry, extyp: INTEGER);
PROCEDURE GetObjcExtype (tree: POINTER; entry: INTEGER; VAR extyp, typ: INTEGER);
PROCEDURE SetUserkey (tree: POINTER; objc: INTEGER; key: tKey; action, doset: BOOLEAN);
PROCEDURE ResetUserkeys (tree: POINTER);
PROCEDURE UserValids (tree: POINTER; str: STRING);

CONST   CSCREEN =       0;
        CMOUSE =        1;
        CPOS =          2;

PROCEDURE DialCenter (tree: POINTER; flag, xx, yy: INTEGER; VAR rect: tRect);
PROCEDURE DialDraw (tree: POINTER; entry, depth: INTEGER; clip: tRect);
PROCEDURE DialChange (tree: POINTER; entry: INTEGER; state: Wordbits; clip: tRect; doset, draw: BOOLEAN);
PROCEDURE DisableDialog (tree: POINTER);
PROCEDURE EnableDialog (tree: POINTER);

PROCEDURE SetEdit (tree: POINTER; item: INTEGER; size: WORD; valid: CHAR);
PROCEDURE SetEditpos (tree: POINTER; pos: INTEGER; VAR redraw: BOOLEAN);
FUNCTION  GetEditpos (tree: POINTER): INTEGER;

TYPE TripleState = (TriState1,  (* leere Box    *)
                    TriState2,  (* angekreuzt   *)
                    TriState3,  (* grau gefÅllt *)
                    TriError);  (* Fehler!      *)

FUNCTION  GetTriple (tree: POINTER; entry: INTEGER): TripleState;
PROCEDURE SetTriple (tree: POINTER; entry: INTEGER; state: TripleState);

PROCEDURE GetSlider (tree: POINTER; entry: INTEGER;  VAR spos, ssize: INTEGER);
PROCEDURE SetSlider (tree: POINTER; entry, spos, ssize: INTEGER); 

PROCEDURE FreeListbox (tree: POINTER; item: INTEGER); 
PROCEDURE RedrawListbox (tree: POINTER; item, start: INTEGER);

TYPE ListboxMode = (Select, Check, SelectMulti, CheckMulti, Disable, Enable);

PROCEDURE SetListboxMode (tree: POINTER; item: INTEGER; mode: ListboxMode);
PROCEDURE SetDropboxElement (tree: POINTER; item, entry: INTEGER; draw: BOOLEAN);
FUNCTION  FindSelected (tree: POINTER; item, start: INTEGER): INTEGER;
FUNCTION  FindChecked (tree: POINTER; item, start: INTEGER): INTEGER;
PROCEDURE SelectMatching (tree: POINTER; item, start: INTEGER;
                          CONST entry: ARRAY OF CHAR;
                          state: WordBits;  sel, first: BOOLEAN);
PROCEDURE SelectMatchPtr (tree: POINTER; item, start: INTEGER; data: POINTER;
                          state: WordBits;  sel, first: BOOLEAN);
PROCEDURE SelectEntry (tree: POINTER; item, entry: INTEGER;
                       state: WordBits; sel: BOOLEAN);
PROCEDURE SelectAll (tree: POINTER; item, start: INTEGER;
                     state: WordBits; sel: BOOLEAN);
FUNCTION  AddEntry (tree: POINTER; item: INTEGER; state: BITSET; data: POINTER; entry: STRING): BOOLEAN;
FUNCTION  InsertEntry (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; entry: STRING): BOOLEAN;
FUNCTION  ChangeEntry (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; entry: STRING): BOOLEAN;
FUNCTION  CountState (tree: POINTER; item: INTEGER; state: Wordbits): LONGINT;

FUNCTION  AddData (tree: POINTER; item: INTEGER; state: BITSET; data: POINTER; size: INTEGER; entry: STRING): BOOLEAN;
FUNCTION  InsertData (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; size: INTEGER; entry: STRING): BOOLEAN;
FUNCTION  ChangeData (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; size: INTEGER; entry: STRING): BOOLEAN;

FUNCTION  DelEntry     (tree: POINTER; item: INTEGER;  num: INTEGER): BOOLEAN;
FUNCTION  FindEntry    (tree: POINTER; item, start: INTEGER; entry: STRING): INTEGER;
FUNCTION  FindExact    (tree: POINTER; item, start: INTEGER; entry: STRING): INTEGER;
FUNCTION  FindEntryPtr (tree: POINTER; item, start: INTEGER; data: POINTER): INTEGER;

TYPE FindLbmode = (exact, wild, similar, autoloc);

FUNCTION  FindListbox (tree: POINTER; item, start, percent: INTEGER; mode: FindLbmode; 
                       entry: STRING): INTEGER;

PROCEDURE GetEntry (tree: POINTER; item: INTEGER; num: INTEGER; VAR data: POINTER; VAR entry: STRING);
FUNCTION  ActEntry (tree: POINTER; item: INTEGER): INTEGER;
FUNCTION  MaxEntry (tree: POINTER; item: INTEGER): INTEGER;
PROCEDURE GetEntryState  (tree: POINTER; item, entry: INTEGER; VAR b: BITSET);
PROCEDURE SetEntryState  (tree: POINTER; item, entry: INTEGER; b: BITSET);
PROCEDURE DropNext (tree: POINTER; item: INTEGER);
PROCEDURE DropEntry (tree: POINTER; item: INTEGER; dir: INTEGER);
PROCEDURE DisableDropbox (tree: POINTER; item: INTEGER; draw: BOOLEAN);
PROCEDURE EnableDropbox (tree: POINTER; item: INTEGER; draw: BOOLEAN);

PROCEDURE SelectRegister (tree: POINTER; item: INTEGER);


FUNCTION  DrawString (r: tRect; mode, col, bcol, brast, ftyp, fid, fsize: INTEGER;
                      CONST s: ARRAY OF CHAR;
                      flags: BITSET; center, middle, del, just: BOOLEAN): tKey;
PROCEDURE Rect (r: tRect; color, fill: INTEGER);
PROCEDURE Frame (r: tRect; color, thick: INTEGER);
PROCEDURE Frame2 (r: tRect; color1, color2, thick: INTEGER);
PROCEDURE Shadow (r: tRect; color, thick: INTEGER);
PROCEDURE Line (x, y, w, h, color: INTEGER);
PROCEDURE DrawBack (p: POINTER; rect: tRect; par, frm, ted, reg: BOOLEAN);

IMPLEMENTATION

USES M_Sys;


PROCEDURE DisposeDials;
BEGIN
 CallMagic (1101);
END (*DisposeDials*);

FUNCTION OpenDial (tree: POINTER; mode: Dialmode; flags: LONGBITSET;
                   edit, edpos, ok, cancel, xpos, ypos: INTEGER;
                   name: STRING): INTEGER;
VAR s: CSTRING;
BEGIN
 PascalToCString (name, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.LongIn[0]:= LBitsetToLong (flags);
 App^.MagicPB^.IntIn[0]:= ORD (mode);
 App^.MagicPB^.IntIn[1]:= 0;
 App^.MagicPB^.IntIn[2]:= edit;
 App^.MagicPB^.IntIn[3]:= edpos;
 App^.MagicPB^.IntIn[4]:= ok;
 App^.MagicPB^.IntIn[5]:= cancel;
 App^.MagicPB^.IntIn[6]:= xpos;
 App^.MagicPB^.IntIn[7]:= ypos;
 CallMagic (1102);
 OpenDial:= App^.MagicPB^.IntOut[0];
END (*OpenDial*); 

PROCEDURE CloseDial (tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1103);
END (*CloseDial*);

PROCEDURE DialInfo (tree: POINTER; VAR mode: Dialmode; VAR win: INTEGER; VAR open: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1104);
 mode:= Dialmode (App^.MagicPB^.IntOut[0]);
 win:= App^.MagicPB^.IntOut[1];
 open:= BOOLEAN (App^.MagicPB^.IntOut[2]);
END (*DialInfo*);

FUNCTION NewDial (tree: POINTER; handler: DialHandler): BOOLEAN;
VAR x: RECORD
        CASE INTEGER OF
         0: (ptr: POINTER);
         1: (hnd: DialHandler);
       END;
BEGIN
 x.hnd:= handler;
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= x.ptr;
 CallMagic (1105);
 NewDial:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*NewDial*);

PROCEDURE DisposeDial (tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1106);
END (*DisposeDial*);

PROCEDURE ObjcExtype (tree: POINTER; entry, extyp: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 App^.MagicPB^.IntIn[1]:= extyp;
 CallMagic (1107);
END (*ObjcExtype*);

PROCEDURE GetObjcExtype (tree: POINTER; entry: INTEGER; VAR extyp, typ: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry;
 CallMagic (1108);
 extyp:= App^.MagicPB^.IntOut[0];
 typ:= App^.MagicPB^.IntOut[1];
END (*GetObjcExtype*);

PROCEDURE SetUserkey (tree: POINTER; objc: INTEGER; key: tKey; action, doset: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= objc; 
 App^.MagicPB^.IntIn[1]:= ORD (key);
 App^.MagicPB^.IntIn[2]:= ORD (action);
 App^.MagicPB^.IntIn[3]:= ORD (doset);
 CallMagic (1109);
END (*SetUserkey*);

PROCEDURE ResetUserkeys (tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1110);
END (*ResetUserkeys*);

PROCEDURE UserValids (tree: POINTER; str: STRING);
VAR s: CSTRING;
BEGIN
 PascalToCString (str, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 CallMagic (1111);
END (*UserValids*);

PROCEDURE DialCenter (tree: POINTER; flag, xx, yy: INTEGER; VAR rect: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 App^.MagicPB^.IntIn[0]:= flag; 
 App^.MagicPB^.IntIn[1]:= xx; 
 App^.MagicPB^.IntIn[2]:= yy; 
 CallMagic (1112);
END (*DialCenter*);

PROCEDURE DialDraw (tree: POINTER; entry, depth: INTEGER; clip: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (clip);
 App^.MagicPB^.IntIn[0]:= entry; 
 App^.MagicPB^.IntIn[1]:= depth; 
 CallMagic (1113);
END (*DialDraw*); 

PROCEDURE DialChange (tree: POINTER; entry: INTEGER; state: Wordbits;
                      clip: tRect; doset, draw: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR (clip);
 App^.MagicPB^.IntIn[0]:= entry; 
 App^.MagicPB^.IntIn[1]:= ORD (state); 
 App^.MagicPB^.IntIn[2]:= ORD (doset); 
 App^.MagicPB^.IntIn[3]:= ORD (draw); 
 CallMagic (1114);
END (*DialChange*);

PROCEDURE DisableDialog (tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1115);
END (*DisableDialog*);

PROCEDURE EnableDialog (tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1116);
END (*EnableDialog*);

FUNCTION GetTriple (tree: POINTER; entry: INTEGER): TripleState;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry; 
 CallMagic (1117);
 GetTriple:= TripleState (App^.MagicPB^.IntOut[0]);
END; (*GetTriple*)

PROCEDURE SetTriple (tree: POINTER; entry: INTEGER; state: TripleState);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry; 
 App^.MagicPB^.IntIn[1]:= ORD (state); 
 CallMagic (1118);
END; (*SetTriple*)

PROCEDURE GetSlider (tree: POINTER; entry: INTEGER; VAR spos, ssize: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry; 
 CallMagic (1119);
 spos:=  App^.MagicPB^.IntOut[0];
 ssize:= App^.MagicPB^.IntOut[1];
END (*GetSlider*);

PROCEDURE SetSlider (tree: POINTER; entry, spos, ssize: INTEGER); 
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= entry; 
 App^.MagicPB^.IntIn[1]:= spos; 
 App^.MagicPB^.IntIn[2]:= ssize; 
 CallMagic (1120);
END (*SetSlider*);

FUNCTION DrawString (r: tRect; mode, col, bcol, brast, ftyp, fid, fsize: INTEGER;
                     CONST s: ARRAY OF CHAR;
                     flags: BITSET; center, middle, del, just: BOOLEAN): tKey;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.AddrIn[1]:= ADDR (s);
 App^.MagicPB^.IntIn[ 0]:= mode; 
 App^.MagicPB^.IntIn[ 1]:= col; 
 App^.MagicPB^.IntIn[ 2]:= bcol; 
 App^.MagicPB^.IntIn[ 3]:= brast; 
 App^.MagicPB^.IntIn[ 4]:= ftyp; 
 App^.MagicPB^.IntIn[ 5]:= fid; 
 App^.MagicPB^.IntIn[ 6]:= fsize; 
 App^.MagicPB^.IntIn[ 7]:= BitsetToWord (flags); 
 App^.MagicPB^.IntIn[ 8]:= ORD (center); 
 App^.MagicPB^.IntIn[ 9]:= ORD (middle); 
 App^.MagicPB^.IntIn[10]:= ORD (del); 
 App^.MagicPB^.IntIn[11]:= ORD (TRUE); 
 App^.MagicPB^.IntIn[12]:= ORD (just);
 CallMagic (1121);
 DrawString:= tKey (App^.MagicPB^.IntOut[0]);
END (*DrawString*);

PROCEDURE Rect (r: tRect; color, fill: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= color; 
 App^.MagicPB^.IntIn[1]:= fill; 
 CallMagic (1122);
END (*Rect*);

PROCEDURE Frame (r: tRect; color, thick: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[1]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= color; 
 App^.MagicPB^.IntIn[1]:= thick; 
 CallMagic (1123);
END (*Frame*);

PROCEDURE Frame2 (r: tRect; color1, color2, thick: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[1]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= color1; 
 App^.MagicPB^.IntIn[1]:= color2; 
 App^.MagicPB^.IntIn[2]:= thick; 
 CallMagic (1146);
END (*Frame*);

PROCEDURE Shadow (r: tRect; color, thick: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[1]:= ADDR (r);
 App^.MagicPB^.IntIn[0]:= color; 
 App^.MagicPB^.IntIn[1]:= thick; 
 CallMagic (1124);
END (*Shadow*);

PROCEDURE Line (x, y, w, h, color: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= x; 
 App^.MagicPB^.IntIn[1]:= y; 
 App^.MagicPB^.IntIn[2]:= w; 
 App^.MagicPB^.IntIn[3]:= h; 
 App^.MagicPB^.IntIn[4]:= color; 
 CallMagic (1125);
END (*Line*);

PROCEDURE FreeListbox (tree: POINTER; item: INTEGER); 
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 CallMagic (1126);
END (*FreeListbox*);

FUNCTION AddEntry (tree: POINTER; item: INTEGER; state: BITSET; data: POINTER; entry: STRING): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.AddrIn[2]:= data;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= BitsetToWord (state);
 CallMagic (1127);
 AddEntry:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*AddEntry*);

FUNCTION AddData (tree: POINTER; item: INTEGER; state: BITSET; data: POINTER; size: INTEGER; entry: STRING): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.AddrIn[2]:= data;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= BitsetToWord (state);
 App^.MagicPB^.IntIn[2]:= size;
 CallMagic (1152);
 AddData:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*AddData*);

FUNCTION DelEntry (tree: POINTER; item: INTEGER; num: INTEGER): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= num;
 CallMagic (1128);
 DelEntry:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*DelEntry*);

FUNCTION FindEntry (tree: POINTER; item, start: INTEGER; entry: STRING): INTEGER;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 CallMagic (1129);
 FindEntry:= App^.MagicPB^.IntOut[0];
END (*FindEntry*);

FUNCTION FindExact (tree: POINTER; item, start: INTEGER; entry: STRING): INTEGER;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 CallMagic (1150);
 FindExact:= App^.MagicPB^.IntOut[0];
END (*FindExaxt*);

FUNCTION FindListbox (tree: POINTER; item, start, percent: INTEGER; mode: FindLbmode;
                      entry: STRING): INTEGER;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 App^.MagicPB^.IntIn[2]:= ORD (mode);
 App^.MagicPB^.IntIn[3]:= percent;
 CallMagic (1155);
 FindListbox:= App^.MagicPB^.IntOut[0];
END (*FindListbox*);

PROCEDURE GetEntry (tree: POINTER; item: INTEGER; num: INTEGER; VAR data: POINTER; VAR entry: STRING);
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= num;
 CallMagic (1130);
 CToPascalString (entry, @s);
 data:= App^.MagicPB^.AddrOut[0];
END (*GetEntry*);

FUNCTION ActEntry (tree: POINTER; item: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 CallMagic (1131);
 ActEntry:= App^.MagicPB^.IntOut[0];
END (*ActEntry*);

FUNCTION MaxEntry (tree: POINTER; item: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 CallMagic (1132);
 MaxEntry:= App^.MagicPB^.IntOut[0];
END (*MaxEntry*);

PROCEDURE RedrawListbox (tree: POINTER; item, start: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 CallMagic (1133);
END (*RedrawListbox*);

PROCEDURE SetListboxMode (tree: POINTER; item: INTEGER; mode: ListboxMode);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= ORD (mode);
 CallMagic (1134);
END (*SetListboxMode*);

FUNCTION FindSelected (tree: POINTER; item, start: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 CallMagic (1135);
 FindSelected:= App^.MagicPB^.IntOut[0];
END (*FindSelected*);

FUNCTION FindChecked (tree: POINTER; item, start: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 CallMagic (1136);
 FindChecked:= App^.MagicPB^.IntOut[0];
END (*FindChecked*);

PROCEDURE SelectMatching (tree: POINTER; item, start: INTEGER;
                          CONST entry: ARRAY OF CHAR;
                          state: Wordbits; sel, first: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= ADDR(entry);
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 App^.MagicPB^.IntIn[2]:= ORD (sel);
 App^.MagicPB^.IntIn[3]:= ORD (first);
 App^.MagicPB^.IntIn[4]:= ORD (state);
 CallMagic (1137);
END (*SelectMatching*);

PROCEDURE SelectMatchPtr (tree: POINTER; item, start: INTEGER; data: POINTER;
                          state: Wordbits; sel, first: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= data;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 App^.MagicPB^.IntIn[2]:= ORD (sel);
 App^.MagicPB^.IntIn[3]:= ORD (first);
 App^.MagicPB^.IntIn[4]:= ORD (state);
 CallMagic (1148);
END (*SelectMatching*);


PROCEDURE SelectAll (tree: POINTER; item, start: INTEGER;
                     state: Wordbits; sel: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 App^.MagicPB^.IntIn[2]:= ORD (sel);
 App^.MagicPB^.IntIn[3]:= ORD (state);
 CallMagic (1138);
END (*SelectAll*);

PROCEDURE SetDropboxElement (tree: POINTER; item, entry: INTEGER; draw: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= entry;
 App^.MagicPB^.IntIn[2]:= ORD (draw);
 CallMagic (1139);
END (*SetDropboxElement*);

PROCEDURE SelectEntry (tree: POINTER; item, entry: INTEGER; 
                       state: Wordbits; sel: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= entry;
 App^.MagicPB^.IntIn[2]:= ORD (sel);
 App^.MagicPB^.IntIn[3]:= ORD (state);
 CallMagic (1140);
END (*SelectEntry*);

PROCEDURE GetEntryState (tree: POINTER; item, entry: INTEGER; VAR b: BITSET);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= entry;
 CallMagic (1151);
 WordToBitset (App^.MagicPB^.IntOut[0], b);
END (*GetEntryStateEntry*);

PROCEDURE DropNext (tree: POINTER; item: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 CallMagic (1141);
END (*DropNext*);

PROCEDURE DropEntry (tree: POINTER; item: INTEGER; dir: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= dir;
 CallMagic (1147);
END (*DropEntry*);

FUNCTION InsertEntry (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; entry: STRING): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= data;
 App^.MagicPB^.AddrIn[2]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= pos;
 App^.MagicPB^.IntIn[2]:= BitsetToWord (state);
 CallMagic (1142);
 InsertEntry:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*InsertEntry*);

FUNCTION InsertData (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; size: INTEGER; entry: STRING): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= data;
 App^.MagicPB^.AddrIn[2]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= pos;
 App^.MagicPB^.IntIn[2]:= BitsetToWord (state);
 App^.MagicPB^.IntIn[3]:= size;
 CallMagic (1153);
 InsertData:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*InsertData*);

FUNCTION ChangeEntry (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; entry: STRING): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= data;
 App^.MagicPB^.AddrIn[2]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= pos;
 App^.MagicPB^.IntIn[2]:= BitsetToWord (state);
 CallMagic (1143);
 ChangeEntry:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*ChangeEntry*);

FUNCTION ChangeData (tree: POINTER; item, pos: INTEGER; state: BITSET; data: POINTER; size: INTEGER; entry: STRING): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (entry, @s);
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= data;
 App^.MagicPB^.AddrIn[2]:= @s;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= pos;
 App^.MagicPB^.IntIn[2]:= BitsetToWord (state);
 App^.MagicPB^.IntIn[3]:= size;
 CallMagic (1154);
 ChangeData:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*ChangeData*);

PROCEDURE EnableDropbox (tree: POINTER; item: INTEGER; draw: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= ORD (draw);
 CallMagic (1144);
END (*EnableDropbox*);

PROCEDURE DisableDropbox (tree: POINTER; item: INTEGER; draw: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= ORD (draw);
 CallMagic (1145);
END (*DisableDropbox*);

FUNCTION CountState (tree: POINTER; item: INTEGER; state: Wordbits): LONGINT;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= ORD (state);
 CallMagic (1156);
 CountState:= App^.MagicPB^.LongOut[0];
END (*ChangeEntry*);

PROCEDURE SetEdit (tree: POINTER; item: INTEGER; size: WORD; valid: CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= size;
 App^.MagicPB^.IntIn[2]:= ORD (valid);
 CallMagic (1157);
END (*SetEdit*);

PROCEDURE SetEditpos (tree: POINTER; pos: INTEGER; VAR redraw: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= pos;
 CallMagic (1158);
 redraw:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*SetEditpos*);

FUNCTION GetEditpos (tree: POINTER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1159);
 GetEditpos:= App^.MagicPB^.IntOut[0];
END (*GetEditpos*);

PROCEDURE SetEntryState (tree: POINTER; item, entry: INTEGER; b: BITSET);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= entry;
 App^.MagicPB^.IntIn[2]:= BitsetToWord (b);
 CallMagic (1160);
END (*SetEntryState*);

FUNCTION FindEntryPtr (tree: POINTER; item, start: INTEGER; data: POINTER): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= data;
 App^.MagicPB^.IntIn[0]:= item;
 App^.MagicPB^.IntIn[1]:= start;
 CallMagic (1161);
 FindEntryPtr:= App^.MagicPB^.IntOut[0];
END (*findEntryPtr*);

PROCEDURE DrawBack (p: POINTER; rect: tRect; par, frm, ted, reg: BOOLEAN);
BEGIN
 App^.MagicPB^.AddrIn[0]:= p;
 App^.MagicPB^.AddrIn[1]:= @rect;
 App^.MagicPB^.IntIn[0]:= ORD (par);
 App^.MagicPB^.IntIn[1]:= ORD (frm);
 App^.MagicPB^.IntIn[2]:= ORD (ted);
 App^.MagicPB^.IntIn[3]:= ORD (reg);
 CallMagic (1162);
END (*DrawBack*);

PROCEDURE SelectRegister (tree: POINTER; item: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:= item;
 CallMagic (1163);
END (*SelectRegister*);

END (*mpDials*).
