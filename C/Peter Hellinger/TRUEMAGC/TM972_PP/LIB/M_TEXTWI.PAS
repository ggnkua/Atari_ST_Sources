(*----------------------------------------------------------------------*
 * M_TextWindows erlaubt es Pascalprogrammen, die Ausgabe der Funk-     *
 * tionen der Built-In-Funktionen Write und WriteLn in die von Magic    *
 * bereitgestellten Textfenster umzuleiten.  Dabei wird vom Konzept     *
 * der Dateitreiber in Pure-Pascal gebrauch gemacht.                    *
 *----------------------------------------------------------------------*)

UNIT M_TextWindows;

INTERFACE

USES DOS, Basics, M_Windows;

FUNCTION AssignTextwin (VAR t: TEXT;
                         draw: WindowHandler;
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
(* Wie ASSIGN auf Textdateien. Damit wird ein Terminal-Fenster so 
 * installiert, dass man mit den Pascal-Standard-Funktionen
 * Write und WriteLn direkt in das Textfenster ausgeben kann
 * Beispiel fÅr das ôffnen eines Fensters:
 * 
 * VAR t: TEXT;
 * 
 * AssignTextwin (t, SimpleWinHandler, 
 *                [AES.MOVE, NAME, CLOSER, FULL, INFO], [],
 *                50, 50, 150, 150, 0, 0, 0, 0, 0, 1, 1, 10, [], 80, 
 *                ' Hello World ', 'Test fÅr M_Textwindow', NIL);
 * SYSTEM.Rewrite (t);
 * WriteLn (t, 'Hello World');
 * WriteLn (t, 'alles klar:', 56:4, 3.576:4:2);
 * WriteLn (t, 'Soweit, sogut!');
 * Close (t);
 *)

FUNCTION AssignSimple (VAR t: TEXT; name: STRING): INTEGER;
(* Wie AssignTextwin. Das Fenster wird auf die maximale Grîsse
 * geîffnet. Als Handler fungiert ein Minimal-Handler im Modul.
 *)

PROCEDURE SimpleWinHandler (w: PtrWinPara);
(* Handler fÅr Fensterfunktionen, wie er auch bei AssignSimple zum
 * Einsatz kommt.
 *)

FUNCTION GetTEXT (handle: INTEGER): POINTER;
(* Ermittelt anhand des Fensterhandles die Adresse der Textvariablen *)

FUNCTION GetWindow (VAR t: TEXT): INTEGER;
(* Ermittelt anhand der Textvariablen das Fensterhandle *)

FUNCTION WindowsOpen: INTEGER;
(* Anzahl der Åber dieses Modul geîffneten Fenster *)

(* NÅtzliche Funktionen des Terminalfensters *)
PROCEDURE twSetAttribut     (VAR t: TEXT; attrib: BITSET);
PROCEDURE twWhereXY         (VAR t: TEXT; VAR spalte, zeile: INTEGER);

(* NÅtzliche Funktionen des VT52-Emulators als Prozeduren *)
PROCEDURE twGotoXY          (VAR t: TEXT; spalte, zeile: INTEGER);
PROCEDURE twForegroundColor (VAR t: TEXT; color: INTEGER);
PROCEDURE twBackgroundColor (VAR t: TEXT; color: INTEGER);
PROCEDURE twInsertLine      (VAR t: TEXT);
PROCEDURE twDeleteLine      (VAR t: TEXT);
PROCEDURE twCursorOn        (VAR t: TEXT);
PROCEDURE twCursorOff       (VAR t: TEXT);
PROCEDURE twWrapOff         (VAR t: TEXT);
PROCEDURE twWrapOn          (VAR t: TEXT);
PROCEDURE twClrLine         (VAR t: TEXT);
PROCEDURE twClrSOL          (VAR t: TEXT);
PROCEDURE twClrEOL          (VAR t: TEXT);
PROCEDURE twClrScr          (VAR t: TEXT);
PROCEDURE twClrSOS          (VAR t: TEXT);
PROCEDURE twClrEOS          (VAR t: TEXT);
PROCEDURE twInversOn        (VAR t: TEXT);
PROCEDURE twInversOff       (VAR t: TEXT);

IMPLEMENTATION

USES M_Sys, AES, M_Terminal, M_Messages;

{$I COMPOPT.INC}

TYPE PtrWin =    ^WinPara;
     WinPara =   RECORD
                  draw:           WindowHandler;
                  element:        BITSET;
                  extended:       LONGBITSET;
                  x, y, w, h:     INTEGER;
                  xo, yo, wo, ho: INTEGER;
                  bcolor, fcolor: INTEGER;
                  font, size:     INTEGER;
                  effects:        BITSET;
                  wrappos:        INTEGER;
                  name, info:     STRING;
                  rsc:            POINTER;
                 END;

TYPE PtrMyText = ^MyTextRec;
     MyTextRec = RECORD
                  Handle:    Word;
                  Mode:      Word;
                  BufSize:   LongInt;
                  BufPos:    LongInt;
                  BufEnd:    LongInt;
                  BufPtr:    ^TextBuf;
                  OpenFunc:  Pointer;
                  InOutFunc: Pointer;
                  FlushFunc: Pointer;
                  CloseFunc: Pointer;
                  UserData:  PtrWin;
                  Next:      PtrMyText;
                  Last:      PtrMyText;
                  Name:      array [0..123] of Char;
                  Reserved:  Word;
                  Buffer:    TextBuf;
                 END;

VAR TWinList: PtrMyText;
    WinsOpen: INTEGER;
    fromHandler: BOOLEAN;

FUNCTION WClose (VAR t: TextRec): INTEGER;  FORWARD;

FUNCTION GetWindow (VAR t: TEXT): INTEGER;
VAR txt: MyTextRec ABSOLUTE t;
BEGIN
 GetWindow:= txt.handle;
END (*GetWindow*);

FUNCTION WindowsOpen: INTEGER;
BEGIN
 WindowsOpen:= WinsOpen;
END (*GetWindow*);

FUNCTION GetTEXT (handle: INTEGER): POINTER;
VAR x: PtrMyText;
BEGIN
 GetTEXT:= NIL;
 x:= TWinList;
 WHILE x <> NIL DO BEGIN
  IF x^.Handle = handle THEN BEGIN
   GetTEXT:= x;
   EXIT;
  END;
  x:= x^.next;
 END;
END (*GetTEXT*);

PROCEDURE SimpleWinHandler (w: PtrWinPara);
VAR t: ^TextRec;
BEGIN
 w^.action:= [];
 CASE w^.message OF
  WinRedraw:     ;
  WinTopped:     w^.action := [wTopped];
  WinClosed:     BEGIN 
                  fromhandler:= TRUE;
                  t:= GetTEXT (w^.window);
                  IF t <> NIL THEN WClose (t^);
                  fromhandler:= FALSE;
                  w^.action := [M_Windows.wClose];
                 END;
  WinFulled:     w^.action := [wFulled];
  WinSized:      w^.action := [wSized];
  WinMoved:      w^.action := [wMoved];
  WinBottomed:   w^.action := [wBottomed];
  WinIconify:    w^.action := [wIconify];
  WinUniconify:  w^.action := [wUniconify];
  WinAlliconify: w^.action := [wAlliconify];
  ELSE (* Ignorieren *);
 END;
END;

FUNCTION WInout (VAR t: TextRec): INTEGER;
VAR txt: MyTextRec ABSOLUTE t;
BEGIN
 IF txt.mode = fmOutput THEN BEGIN
  App^.MagicPB^.Addrin[0]:= @txt.Buffer;
  App^.MagicPB^.Intin[0]:= txt.Handle;
  CallMagic (2003);
  FillChar (txt.Buffer, SIZEOF (txt.Buffer), #0);
  txt.BufPos:= 0;
  WInout:= 0;
 END ELSE WInout:= 103;
END (*WinInout*);

FUNCTION WClose (VAR t: TextRec): INTEGER;
VAR txt: MyTextRec ABSOLUTE t;
    x: PtrMyText;
BEGIN
 WInout (t);
 DEC (WinsOpen);
 txt.Handle:=  $FFFF;
 IF NOT fromHandler THEN BEGIN
  CloseTextWindow (INTEGER(txt.Handle));
  txt.Mode:=    fmClosed;
  txt.BufPos:=  0;
  txt.BufEnd:=  0;
  FreeMem (txt.UserData, SIZEOF (WinPara));
 END;
 WClose:= 0;
END (*WClose*);

FUNCTION WOpen (VAR t: TextRec): INTEGER;
VAR txt: MyTextRec ABSOLUTE t;
BEGIN
 txt.Mode:=    fmOutput;
 txt.InOutFunc:= @WInout;
 txt.FlushFunc:= @WInout;
 txt.CloseFunc:= @WClose;
 
 txt.handle:= OpenTextwindow (txt.Userdata^.draw,
                              txt.Userdata^.element, 
                              txt.Userdata^.extended, 
                              txt.Userdata^.x, 
                              txt.Userdata^.y, 
                              txt.Userdata^.w, 
                              txt.Userdata^.h,
                              txt.Userdata^.xo, 
                              txt.Userdata^.yo, 
                              txt.Userdata^.wo, 
                              txt.Userdata^.ho,
                              txt.Userdata^.bcolor, 
                              txt.Userdata^.fcolor,
                              txt.Userdata^.font, 
                              txt.Userdata^.size,
                              txt.Userdata^.effects,
                              txt.Userdata^.wrappos,
                              txt.Userdata^.name, 
                              txt.Userdata^.info,
                              txt.Userdata^.rsc);

 IF txt.handle < $7FFF THEN BEGIN
  INC (WinsOpen);
  ClearScreen (txt.handle);
  WOpen:= 0 
 END ELSE  WOpen:= 103; (* file not open *)
END (*WinOpen*);

FUNCTION AssignTextwin (VAR t: TEXT;
                         draw: WindowHandler;
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
VAR txt: MyTextRec ABSOLUTE t;
BEGIN
 AssignTextwin:= -1;
 FillChar (txt, SIZEOF (txt), #0);
 GetMem (txt.UserData, SIZEOF (WinPara));
 IF txt.UserData = NIL THEN EXIT;

 txt.UserData^.draw:= draw;
 txt.UserData^.element:= element;
 txt.UserData^.extended:= extended;
 txt.UserData^.x:= x;
 txt.UserData^.y:= y;
 txt.UserData^.w:= w;
 txt.UserData^.h:= h;
 txt.UserData^.xo:= xo;
 txt.UserData^.yo:= yo;
 txt.UserData^.wo:= wo;
 txt.UserData^.ho:= ho;
 txt.UserData^.bcolor:= bcolor;
 txt.UserData^.fcolor:= fcolor;
 txt.UserData^.font:= font;
 txt.UserData^.size:= size;
 txt.UserData^.effects:= effects;
 txt.UserData^.wrappos:= wrappos;
 txt.UserData^.name:= name;
 txt.UserData^.info:= info;
 txt.UserData^.rsc:= rsc;

 txt.Next:= TWinList;
 txt.Last:= NIL;
 IF TWinList <> NIL THEN TWinList^.Last:= @t;
 TWinList:= @t;

 txt.Handle:=  $FFFF;
 txt.Mode:=    fmClosed;
 txt.BufSize:= SIZEOF (TextBuf);
 txt.BufPos:=  0;
 txt.BufEnd:=  0;
 txt.BufPtr:=  @txt.Buffer;
 txt.OpenFunc:= @WOpen;
 txt.InOutFunc:= NIL;
 txt.FlushFunc:= NIL;
 txt.CloseFunc:= NIL;
 AssignTextwin:= 0;
END (*AssignTextwin*);

FUNCTION AssignSimple (VAR t: TEXT; name: STRING): INTEGER;
BEGIN 
 AssignSimple:= AssignTextwin (t, SimpleWinHandler, 
                               [AES.MOVE, AES.NAME, CLOSER, FULL, AES.SIZE, SMALLER],
                               [], -1, -1, -1, -1, 0, 0, 0, 0, 0, 1, -1, -1, [], 80,
                               name, '', NIL);
END (*AssignSimple*);


PROCEDURE twWhereXY (VAR t: TEXT; VAR spalte, zeile: INTEGER);
VAR txt: MyTextRec ABSOLUTE t;
BEGIN  M_Terminal.WhereXY (txt.Handle, spalte, zeile);  END;

PROCEDURE twSetAttribut (VAR t: TEXT; attrib: BITSET);
VAR txt: MyTextRec ABSOLUTE t;
BEGIN  M_Terminal.SetAttribut (txt.Handle, attrib);  END;

PROCEDURE twGotoXY (VAR t: TEXT; spalte, zeile: INTEGER);
BEGIN  Write (t, #27'Y', CHR(spalte+32), CHR(zeile+32));  END;

PROCEDURE twForegroundColor (VAR t: TEXT; color: INTEGER);
BEGIN  Write (t, #27'b', CHR(color));  END;

PROCEDURE twBackgroundColor (VAR t: TEXT; color: INTEGER);
BEGIN  Write (t, #27'c', CHR(color));  END;

PROCEDURE twInsertLine (VAR t: TEXT);
BEGIN  Write (t, #27'L');  END;

PROCEDURE twDeleteLine (VAR t: TEXT);
BEGIN  Write (t, #27'M');  END;

PROCEDURE twCursorOn (VAR t: TEXT);
BEGIN  Write (t, #27'e');  END;

PROCEDURE twCursorOff (VAR t: TEXT);
BEGIN  Write (t, #27'f');  END;

PROCEDURE twWrapOff (VAR t: TEXT);
BEGIN  Write (t, #27'w');  END;

PROCEDURE twWrapOn (VAR t: TEXT);
BEGIN  Write (t, #27'v');  END;

PROCEDURE twClrLine (VAR t: TEXT);
BEGIN  Write (t, #27'l');  END;

PROCEDURE twClrSOL (VAR t: TEXT);
BEGIN  Write (t, #27'o');  END;

PROCEDURE twClrEOL (VAR t: TEXT);
BEGIN  Write (t, #27'K');  END;

PROCEDURE twClrScr (VAR t: TEXT);
BEGIN  Write (t, #12);  END;

PROCEDURE twClrSOS (VAR t: TEXT);
BEGIN  Write (t, #27'd');  END;

PROCEDURE twClrEOS (VAR t: TEXT);
BEGIN  Write (t, #27'J');  END;

PROCEDURE twInversOn (VAR t: TEXT);
BEGIN  Write (t, #27'p');  END;

PROCEDURE twInversOff (VAR t: TEXT);
BEGIN  Write (t, #27'q');  END;

BEGIN 
 TWinList:= NIL;
 WinsOpen:= 0;
 fromHandler:= FALSE;
END (*mpTerminal*).
