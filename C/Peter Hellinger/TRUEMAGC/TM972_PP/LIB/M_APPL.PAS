UNIT M_Appl;

INTERFACE

USES M_Types, AES, Basics;

VAR     ApplIdent:       INTEGER;
        AESVersion:      INTEGER;
        AESFontid:       INTEGER;
        AESFontsize:     INTEGER;
        CharWidth:       INTEGER;
        CharHeight:      INTEGER;
        BoxWidth:        INTEGER;
        BoxHeight:       INTEGER;
        SmallFontId:     INTEGER;
        SmallFontSize:   INTEGER;
        SmallChWidth:    INTEGER;
        SmallChHeight:   INTEGER;
        SmallBoxWidth:   INTEGER;
        SmallBoxHeight:  INTEGER;
        DeskX:           INTEGER;
        DeskY:           INTEGER;
        ScreenRect:      tRect;
        Win0Rect:        tRect;
        Multitask:       BOOLEAN;
        KaosTos:         BOOLEAN;
        MiNTInstalled:   BOOLEAN;
        MiNTVersion:     LONGINT;
        SpeedoGDOS:      BOOLEAN;
        SpeedoVersion:   INTEGER;
        NVDIGDOS:        BOOLEAN;
        NVDIVersion:     INTEGER;
        XMenuPossible:   BOOLEAN;
        IconifyPossible: BOOLEAN;
        UpdatePossible:  BOOLEAN;
        WindowFunction:  BITSET;
        WindowElements:  BITSET;

        DefaultWS:      WORKSTATION;

PROCEDURE ApplInit;

TYPE TermProc = FUNCTION: INTEGER;

PROCEDURE InstallTermproc (proc: TermProc);
PROCEDURE ApplTerm (return: INTEGER);
PROCEDURE ApplPath (VAR path: STRING);
PROCEDURE ApplName (VAR name: STRING);
PROCEDURE ApplIcon (icon: PtrCICONBLK);

TYPE Device = (Screen,    (* Device-Nummer  1..10 *)
               Plotter,   (*               11..20 *)
               Printer,   (*               21..30 *)
               Metafile,  (*               31..40 *)
               Camera,    (*               41..50 *)
               Tablett,   (*               51..60 *)
               Memory,    (*               61..70 *)
               dev71_80,  (*               61..70 *)
               dev81_90,  (*               71..80 *)
               dev91_99); (*               81..90 *)

PROCEDURE OpenWorkstation (device: Device; devnum, w, h: INTEGER; rc: BOOLEAN; VAR wsinfo: WORKSTATION);
PROCEDURE CloseWorkstation (VAR wsinfo: WORKSTATION);
FUNCTION  AvailableDrivers (dev: Device): INTEGER;
PROCEDURE DriverInfo (dev: Device; num: INTEGER; VAR wsinfo: WORKSTATION);
FUNCTION  VqGdos: LONGINT;
PROCEDURE MouseOn;
PROCEDURE MouseArrow;
PROCEDURE MouseCursor;
PROCEDURE MouseBusy;
PROCEDURE MouseFinger;
PROCEDURE MouseHand;
PROCEDURE MouseThincross;
PROCEDURE MouseThickcross;
PROCEDURE MouseOutline;
PROCEDURE MouseUser;
PROCEDURE MouseRotor;
PROCEDURE MousePrinter;
PROCEDURE MouseOff;
PROCEDURE MouseOffRect (r: tRect);
PROCEDURE UserMouse (VAR form: MFORM);
PROCEDURE MouseState (VAR form: INTEGER; VAR sichtbar: BOOLEAN);
PROCEDURE StoreMouse;
PROCEDURE RestoreMouse;
PROCEDURE SetMouse (x, y: INTEGER);
PROCEDURE LockScreen;
PROCEDURE UnlockScreen;
PROCEDURE FreezeScreen;
PROCEDURE UnfreezeScreen;
FUNCTION  ScreenLocked: BOOLEAN;
FUNCTION  GetHelp (CONST txt: ARRAY OF CHAR): INTEGER;


CONST ShutdownOK =     0;   
      ShutdownFailed = 1;
      
TYPE  PtrShutdown =    ^ShutdownPara;
      ShutdownPara =   RECORD
                        why:    INTEGER; (* Grund des Shutdowns   *)
                        answer: INTEGER; (* Antwort des Programms *)
                        error:  INTEGER; (* evtl. Fehlercode      *)
                       END;

TYPE ShutdownHandler = PROCEDURE (sp: PtrShutdown);

FUNCTION AcceptShutdown (handler: ShutdownHandler): BOOLEAN;


IMPLEMENTATION

USES M_Sys, Cookie, M_Strings, AES, VDI;

CONST   ABCGEM =        $0210;

CONST   cNDC =           0;
        cRC =            2;

TYPE    TermPtr =       ^TermInfo;
        TermInfo =      RECORD
                         proc:  TermProc;
                         next:  TermPtr;
                        END;


VAR     vapplpath:      ARRAY [0..255] OF CHAR;
        vapplname:      ARRAY [0..255] OF CHAR;

VAR     ProgReturn:     INTEGER;
        init:           INTEGER;
        gdos:           LONGINT;


PROCEDURE ApplInit;
VAR b: BOOLEAN;
    l: LONGINT;
    name: STRING;
    attr: tTextAttrArray;
BEGIN
 IF init <> 30961 THEN BEGIN
  
  ApplIdent:= appl_init;
  AESVersion:= App^.AESPB^.cbPGlobal^.apVersion;
  
  CallMagic (1);    (* Magic initialisieren *)
  CallMagic (609);  KaosTos:= BOOLEAN (App^.MagicPB^.IntOut[0]);
  CallMagic (608);  Multitask:= BOOLEAN (App^.MagicPB^.IntOut[0]);

  MiNTInstalled:= FindCookie (MiNT, MiNTVersion);
 
  CallMagic (604);
  AESFontid:=      App^.MagicPB^.IntOut[ 0];
  AESFontsize:=    App^.MagicPB^.IntOut[ 1];
  Charwidth:=      App^.MagicPB^.IntOut[ 2];
  Charheight:=     App^.MagicPB^.IntOut[ 3];
  Boxwidth:=       App^.MagicPB^.IntOut[ 4];
  Boxheight:=      App^.MagicPB^.IntOut[ 5];
  SmallFontid:=    App^.MagicPB^.IntOut[ 6];
  SmallFontsize:=  App^.MagicPB^.IntOut[ 7];
  SmallChWidth:=   App^.MagicPB^.IntOut[ 8];
  SmallChHeight:=  App^.MagicPB^.IntOut[ 9];
  SmallBoxWidth:=  App^.MagicPB^.IntOut[10];
  SmallBoxHeight:= App^.MagicPB^.IntOut[11];
  
  CallMagic (644);
  SpeedoGDOS:=      BOOLEAN (App^.MagicPB^.IntOut[0]);
  SpeedoVersion:=   App^.MagicPB^.IntOut[1];
  NVDIGDOS:=        BOOLEAN (App^.MagicPB^.IntOut[2]);
  NVDIVersion:=     App^.MagicPB^.IntOut[3];
  XMenuPossible:=   BOOLEAN (App^.MagicPB^.IntOut[4]);
  IconifyPossible:= BOOLEAN (App^.MagicPB^.IntOut[5]);
  UpdatePossible:=  BOOLEAN (App^.MagicPB^.IntOut[6]);
  WordToBitset (App^.MagicPB^.IntOut[7], WindowFunction);
  WordToBitset (App^.MagicPB^.IntOut[8], WindowElements);

  App^.MagicPB^.AddrIn[0]:= ADDR (ScreenRect);
  CallMagic (605);

  App^.MagicPB^.AddrIn[0]:= ADDR (Win0Rect);
  CallMagic (606);

  OpenWorkstation (Screen, -1, 0, 0, TRUE, DefaultWS);
 
  CallMagic (607);
  DeskX:=   App^.MagicPB^.IntOut[0];
  DeskY:=   App^.MagicPB^.IntOut[1];

  IF AESVersion <> ABCGEM THEN  gdos:= VDI.Vq_Gdos()
                          ELSE  gdos:= ABCGEM;

  Exitproc:= ADDR (ApplTerm);

  CallMagic (621);
  
 END;
END (*ApplInit*);

PROCEDURE InstallTermproc (proc: TermProc);
VAR p: TermPtr;
BEGIN
 GetMem (p, SIZEOF (TermPtr));  IF p = NIL THEN  HALT;
 p^.proc:= proc; 
 p^.next:= App^.TermProc;
 App^.TermProc:= p;
END (*InstallTermproc*);

PROCEDURE ApplTerm (return: INTEGER);
VAR  p: TermPtr;
     i: INTEGER;
BEGIN
 (* Installierte TermProcedures abarbeiten *)
 p:= App^.TermProc;
 WHILE (p <> NIL) DO BEGIN  (*i:=*) p^.proc;  p:= p^.next;  END;
 App^.MagicPB^.IntIn[0]:= return;
 CallMagic (4);   (* Alles deinstallieren *)
 CallMagic (2);   (* ExitMagic *)
 Terminate (return);
END (*ApplTerm*);

PROCEDURE ApplPath (VAR path: STRING);
BEGIN
 path:= StrPas (vapplpath);
END (*ApplPath*);

PROCEDURE ApplName (VAR name: STRING);
BEGIN
 name:= StrPas (vapplname);
END (*ApplName*);

PROCEDURE OpenWorkstation (device: Device; devnum, w, h: INTEGER; rc: BOOLEAN;
                           VAR wsinfo: WORKSTATION);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (wsinfo);
 App^.MagicPB^.IntIn[0]:=  ORD (device);
 App^.MagicPB^.IntIn[1]:=  devnum;
 App^.MagicPB^.IntIn[2]:=  w;
 App^.MagicPB^.IntIn[3]:=  h;
 App^.MagicPB^.IntIn[4]:=  ORD (rc);
 CallMagic (602);
END (*OpenWorkstation*);

PROCEDURE CloseWorkstation (VAR wsinfo: WORKSTATION);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (wsinfo);
 CallMagic (603);
END (*CloseWorkstation*);

FUNCTION  AvailableDrivers (dev: Device): INTEGER;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (dev);
 CallMagic (642);
 AvailableDrivers:= App^.MagicPB^.IntOut[0];
END (*AvailableDrivers*);

PROCEDURE DriverInfo (dev: Device; num: INTEGER; VAR wsinfo: WORKSTATION);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (wsinfo);
 App^.MagicPB^.IntIn[0]:= ORD (dev);
 App^.MagicPB^.IntIn[1]:= num;
 CallMagic (643);
END (*DriverInfo*);

PROCEDURE MouseOn;
BEGIN
 CallMagic (620);
END (*MouseOn*);

PROCEDURE MouseArrow;
BEGIN
 CallMagic (621);
END (*MouseArrow*);

PROCEDURE MouseCursor;
BEGIN
 CallMagic (622);
END (*MouseCursor*);

PROCEDURE MouseBusy;
BEGIN
 CallMagic (623);
END (*MouseBusy*);

PROCEDURE MouseFinger;
BEGIN
 CallMagic (624);
END (*MouseFinger*);

PROCEDURE MouseHand;
BEGIN
 CallMagic (625);
END (*MouseHand*);

PROCEDURE MouseThincross;
BEGIN
 CallMagic (626);
END (*MouseThincross*);

PROCEDURE MouseThickcross;
BEGIN
 CallMagic (627);
END (*MouseThickcross*);

PROCEDURE MouseOutline;
BEGIN
 CallMagic (628);
END (*MouseOutline*);

PROCEDURE MouseRotor;
BEGIN
 CallMagic (640);
END (*MouseRotor*);

PROCEDURE MousePrinter;
BEGIN
 CallMagic (646);
END (*MousePrinter*);

PROCEDURE MouseUser;
BEGIN
 CallMagic (629);
END (*MouseUser*);

PROCEDURE MouseOff;
BEGIN
 CallMagic (630);
END (*MouseOff*);

PROCEDURE UserMouse (VAR form: MFORM);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (form);
 CallMagic (631);
END (*UserMouse*);

PROCEDURE MouseState (VAR form: INTEGER; VAR sichtbar: BOOLEAN);
BEGIN
 CallMagic (632);
 form:= App^.MagicPB^.IntOut[0];
 sichtbar:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*MouseState*);

PROCEDURE StoreMouse;
BEGIN
 CallMagic (633);
END (*StoreMouse*);

PROCEDURE RestoreMouse;
VAR view: BOOLEAN;
BEGIN
 CallMagic (634);
END (*RestoreMouse*);

PROCEDURE SetMouse (x, y: INTEGER);
VAR xx, yy: INTEGER;
    ch:     CHAR;
    s:      BITSET;
BEGIN
 App^.MagicPB^.IntIn[0]:= x;
 App^.MagicPB^.IntIn[1]:= y;
 CallMagic (635);
END (*SetMouse*);

PROCEDURE MouseOffRect (r: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 CallMagic (641);
END (*MouseOffRect*);

FUNCTION VqGdos (): LONGINT;
BEGIN 
 VqGdos:= gdos;
END (*VqGdos*);

PROCEDURE LockScreen;
BEGIN
 CallMagic (636);
END (*LockScreen*);

PROCEDURE UnlockScreen;
BEGIN
 CallMagic (637);
END (*UnlockScreen*);

PROCEDURE FreezeScreen;
BEGIN
 CallMagic (638);
END (*FreezeScreen*);

PROCEDURE UnfreezeScreen;
BEGIN
 CallMagic (639);
END (*UnfreezeScreen*);

FUNCTION ScreenLocked: BOOLEAN;
BEGIN
 ScreenLocked:= M_Types.ScreenLocked IN App^.flags;
END (*ScreenLocked*);

PROCEDURE InitMtAppl;
VAR s: ARRAY [0..255] OF CHAR;
    c, d, l, i: INTEGER;
    p1: PCHAR;
BEGIN
 IF init <> 30961 THEN BEGIN
  ApplInit;  (* Applikation und Workstations initialisieren *)
  shel_read (vapplpath, s);
  l:= StrLen (vapplpath);  c:= l;  d:= 1;
  WHILE ((c > 1) AND (vapplpath[c-1] <> '\')) DO BEGIN
   DEC (c);  INC (d);
  END; (* WHILE *)
  p1:= ADDR(vapplpath[c]);
  StrLCopy (vapplname, p1^, d);
  SYSTEM.TermProc:= ADDR (ApplTerm);
  init:= 30961;
 END;
END (*InitMtAppl*);

FUNCTION  GetHelp (CONST txt: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (txt);
 CallMagic (645);
 GetHelp:= App^.MagicPB^.IntOut[0];
END (*GetHelp*);

FUNCTION AcceptShutdown (handler: ShutdownHandler): BOOLEAN;
VAR x: RECORD
        CASE INTEGER OF
         0: (ptr: POINTER);
         1: (hnd: ShutdownHandler);
       END;
BEGIN
 x.hnd:= handler;
 App^.MagicPB^.AddrIn[0]:= x.ptr;
 CallMagic (647);
 AcceptShutdown:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*AcceptShutdown*);

PROCEDURE ApplIcon (icon: PtrCICONBLK);
BEGIN
 App^.ApplIcon:= icon;
END (*ApplIcon*);

BEGIN
 init:= 0;
 InitMtAppl;
END (*M_Appl*).
