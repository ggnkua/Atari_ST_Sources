UNIT M_Sys;

INTERFACE

USES M_Types, Basics;

PROCEDURE SetKeymap (map: Keymap);
PROCEDURE InitKeymap (VAR map: Keymap);
PROCEDURE ResetKeymap;
PROCEDURE UseDeadkeys (doit: BOOLEAN);
PROCEDURE MapNumblock (doit: BOOLEAN);
PROCEDURE ScanToKey (scan, chr: INTEGER; status: BITSET; VAR key: tKey; VAR ch: CHAR);
PROCEDURE KeyToScan (key: tKey; VAR scan: INTEGER; VAR kbshift: BITSET);
FUNCTION  KeyToChar (key: tKey): CHAR;
FUNCTION  CharToKey (ch: CHAR): tKey;
FUNCTION  UpperCase (lower: tKey): tKey;
FUNCTION  LowerCase (upper: tKey): tKey;
PROCEDURE SetDeadKeys (keys: BITSET);
PROCEDURE SetConfigflag (flag: LongBits; doset: BOOLEAN);
FUNCTION  InConfig (flag: LongBits): BOOLEAN;
PROCEDURE SetDefaultkey (name: tFKeys; val: tKey);
FUNCTION  DefaultKey (name: tFKeys): tKey;
PROCEDURE GetDeads (VAR keys: BITSET);
PROCEDURE SetDeads (keys: BITSET);
FUNCTION  ConfigPtr: PtrConfig;
PROCEDURE MagicVersion (VAR version, revision: INTEGER);
PROCEDURE MagicVerString (VAR version: ARRAY OF CHAR);

VAR App: PtrApp;

PROCEDURE InitMagic;
PROCEDURE ExitMagic;
PROCEDURE ProgName (name: ARRAY OF CHAR);
FUNCTION  Min (i1, i2: INTEGER): INTEGER;
FUNCTION  Max (i1, i2: INTEGER): INTEGER;
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
PROCEDURE InclByteset (VAR bset: BYTESET; bit: ByteBits);
PROCEDURE ExclByteset (VAR bset: BYTESET; bit: ByteBits);
PROCEDURE InclBitset (VAR bset: BITSET; bit: WordBits);
PROCEDURE Exclbitset (VAR bset: BITSET; bit: WordBits);
PROCEDURE InclLongset (VAR bset: LONGBITSET; bit: LongBits);
PROCEDURE ExclLongset (VAR bset: LONGBITSET; bit: LongBits);
FUNCTION  BootDevice: INTEGER;
FUNCTION  BasepagePtr: POINTER;
FUNCTION  Accessory: BOOLEAN;
FUNCTION  SysHeader: POINTER;
FUNCTION  TosVersion: WORD;
FUNCTION  TosDate: WORD;
PROCEDURE Terminate (return: INTEGER);
PROCEDURE CallMagic (func: INTEGER);
PROCEDURE CopyrightOn;
PROCEDURE CopyrightOff;
PROCEDURE Ping;
PROCEDURE VisualScreen (VAR r: tRect);


TYPE EmergencyProc = PROCEDURE;

PROCEDURE SetEmergencyProc (ep: EmergencyProc);

FUNCTION  ReadFile (name: STRING; VAR size: LONGINT; VAR date, time: WORD): POINTER;


IMPLEMENTATION

(*$L M_SYS.O*)

{$IFDEF Link} USES mkKernel, DOS, OS, Cookie, AES, VDI;  {$ENDIF}
{$IFNDEF Link} USES DOS, OS, Cookie, AES, VDI;  {$ENDIF}

CONST MagicNeeded = $0972;


TYPE  ErrArray = ARRAY [0..9, 0..50] OF CHAR;

CONST FatalErrors:  ErrArray =
        (* 0 *)      ('[3][|MAGIC: Fataler Fehler!| |'#0,
        (* 1 *)       '|ProgrammausfÅhrung unmîglich!][ OHA!!! ]'#0,
        (* 2 *)       'Magic nicht gefunden!'#0,
        (* 3 *)       'Magic nicht installiert!'#0,
        (* 4 *)       'Magic-Version veraltet!'#0,
        (* 5 *)       'Cookie nicht installiert!'#0,
        (* 6 *)       'GEMDOS-AusfÅhrungsfehler!'#0,
        (* 7 *)       'nicht genÅgend Speicher!'#0,
        (* 8 *)       'Unbekannter Fehler!'#0,
        (* 9 *)       'TrueMagic hat sich beendet'#0
                     );

VAR cast:       RECORD
                 CASE INTEGER OF
                  0: (lint: LONGINT);
                  1: (hw, lw: WORD);
                  2: (b1, b2, b3, b4: BYTE);
                  3: (lset: LONGBITSET);
                  4: (hs, ls: BITSET);
                  5: (s1, s2, s3, s4: BYTESET);
                END;

VAR base: PtrPD;
    sys:  PtrSYSHDR;
    acc:  BOOLEAN;
    boot: INTEGER;
    language: INTEGER;
    MagicBase: LONGINT;

VAR ActConfig: PtrConfig;
    MyCookie:  TheConfig;
    _magic, _mint, _Magx: LONGINT;
    MintIsDa: BOOLEAN;
    MagxIsDa: BOOLEAN;
    NormalAbort: BOOLEAN;


FUNCTION RunMagic: LONGINT; EXTERNAL;

FUNCTION Min (i1, i2: INTEGER): INTEGER;
BEGIN
 IF i1 < i2 THEN  Min:= i1  ELSE  Min:= i2;
END (*Min*);

FUNCTION Max (i1, i2: INTEGER): INTEGER;
BEGIN
 IF i1 < i2 THEN  Max:= i2  ELSE  Max:= i1;
END (*Max*);

PROCEDURE ByteToByteset (value: BYTE; VAR bset: Byteset);
BEGIN
 cast.lint:= 0;  cast.b4:= value;  bset:= cast.s4;
END (*ByteToByteset*);

PROCEDURE ByteToBitset (value: BYTE; VAR bset: BITSET);
BEGIN
 cast.lint:= 0;  cast.b4:= value;  bset:= cast.ls;
END (*ByteToBitset*);

PROCEDURE ByteToLBitset (value: BYTE; VAR bset: LONGBITSET);
BEGIN
 cast.lint:= 0;  cast.b4:= value;  bset:= cast.lset;
END (*ByteToLBitset*);

(* 16-Bit Casting *)

PROCEDURE WordToByteset (value: WORD; VAR bset: Byteset);
BEGIN
 cast.lint:= 0;  cast.lw:= value;  bset:= cast.s4;
END (*WordToByteset*);

PROCEDURE WordToBitset (value: WORD; VAR bset: BITSET);
BEGIN
 cast.lint:= 0;  cast.lw:= value;  bset:= cast.ls;
END (*WordToBitset*);

PROCEDURE WordToLBitset (value: WORD; VAR bset: LONGBITSET);
BEGIN
 cast.lint:= 0;  cast.lw:= value;  bset:= cast.lset;
END (*WordToLBitset*);

(* 32-Bit Casting *)

PROCEDURE LongToByteset (value: LONGINT; VAR bset: Byteset);
BEGIN
 cast.lint:= value;  bset:= cast.s4;
END (*LongToByteset*);

PROCEDURE LongToBitset (value: LONGINT; VAR bset: BITSET);
BEGIN
 cast.lint:= value;  bset:= cast.ls;
END (*LongToBitset*);

PROCEDURE LongToLBitset (value: LONGINT; VAR bset: LONGBITSET);
BEGIN
 cast.lint:= value;  bset:= cast.lset;
END (*LongToLBitset*);

FUNCTION  BytesetToByte (bset: Byteset): BYTE;
BEGIN
 cast.s4:= bset;  BytesetToByte:= cast.b4;
END;

FUNCTION  BitsetToByte  (bset: BITSET): BYTE;
BEGIN
 cast.ls:= bset;  BitsetToByte:= cast.b4;
END;

FUNCTION  LBitsetToByte (bset: LONGBITSET): BYTE;
BEGIN
 cast.lset:= bset;  LBitsetToByte:= cast.b4;
END;

FUNCTION  BytesetToWord (bset: Byteset): WORD;
BEGIN
 cast.s4:= bset;  BytesetToWord:= cast.lw;
END;

FUNCTION  BitsetToWord  (bset: BITSET): WORD;
BEGIN
 cast.ls:= bset;  BitsetToWord:= cast.lw;
END;

FUNCTION  LBitsetToWord (bset: LONGBITSET): WORD;
BEGIN
 cast.lset:= bset;  LBitsetToWord:= cast.lw;
END;

FUNCTION  BytesetToLong (bset: Byteset): LONGINT;
BEGIN
 cast.s4:= bset;  BytesetToLong:= cast.lint;
END;

FUNCTION  BitsetToLong (bset: BITSET): LONGINT;
BEGIN
 cast.ls:= bset;  BitsetToLong:= cast.lint;
END;

FUNCTION  LBitsetToLong (bset: LONGBITSET): LONGINT;
BEGIN
 cast.lset:= bset;  LBitsetToLong:= cast.lint;
END;

PROCEDURE InclByteset (VAR bset: BYTESET; bit: ByteBits);
BEGIN
 bset:= bset + [bit];
END (*InclByteset*);

PROCEDURE ExclByteset (VAR bset: BYTESET; bit: ByteBits);
BEGIN
 bset:= bset - [bit];
END (*ExclByteset*);

PROCEDURE InclBitset (VAR bset: BITSET; bit: WordBits);
BEGIN
 bset:= bset + [bit];
END (*InclBitset*);

PROCEDURE ExclBitset (VAR bset: BITSET; bit: WordBits);
BEGIN
 bset:= bset - [bit];
END (*ExclBitset*);

PROCEDURE InclLongset (VAR bset: LONGBITSET; bit: LongBits);
BEGIN
 bset:= bset + [bit];
END (*InclLongset*);

PROCEDURE ExclLongset (VAR bset: LONGBITSET; bit: LongBits);
BEGIN
 bset:= bset - [bit];
END (*ExclLongset*);

FUNCTION BootDevice: INTEGER;
BEGIN
 BootDevice:= boot;
END (*BootDevice*);

FUNCTION BasepagePtr: POINTER;
BEGIN
 BasepagePtr:= base;
END (*BasepagePtr*);

FUNCTION Accessory: BOOLEAN;
BEGIN
 Accessory:= acc;
END (*Accessory*);

FUNCTION SysHeader: POINTER;
BEGIN
 SysHeader:= sys;
END (*SysHeader*);

FUNCTION TosVersion: WORD;
BEGIN   
 TosVersion:= sys^.osVersion;
END (*TosVersion*);

FUNCTION TosDate: WORD;
BEGIN
 TosDate:= sys^.osdosdate;
END (*TosDate*);

PROCEDURE Terminate (return: INTEGER);
VAR p: PtrPD;
BEGIN
 SwapVectors;
 IF MagicBase <> -1 THEN BEGIN
  p:= POINTER (MagicBase);
  Mfree (p^.pEnv);
  Mfree (p);
 END;
 NormalAbort:= TRUE;
 Pterm (return);
END (*Terminate*);

FUNCTION GetSyshdr: LONGINT;
VAR hdr: POINTER ABSOLUTE $04F2;
    bdv: INTEGER ABSOLUTE $0446;
BEGIN
 sys:= hdr;
 language:= sys^.osconf SHR 1;
 boot:= bdv;
 GetSyshdr:= 0;
END (*GetSyshdr*);

PROCEDURE UseDeadkeys (doit: BOOLEAN);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (doit);
 CallMagic (441);
END (*UseDeadkeys*);

PROCEDURE MapNumblock (doit: BOOLEAN);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (doit);
 CallMagic (442);
END (*MapNumblock*);

PROCEDURE ScantoKey (scan, chr: INTEGER; status: BITSET;
                     VAR key: tKey; VAR ch: CHAR);
BEGIN
 App^.MagicPB^.IntIn[0]:= scan;
 App^.MagicPB^.IntIn[1]:= chr;
 App^.MagicPB^.IntIn[2]:= BitsetToWord (status);
 CallMagic (443);
 key:= tKey (App^.MagicPB^.IntOut[0]);
 ch:= CHAR (App^.MagicPB^.IntOut[1]);
END (*ScanToKey*);

FUNCTION UpperCase (lower: tKey): tKey;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (lower);
 CallMagic (448);
 UpperCase:= tKey (App^.MagicPB^.IntOut[0]);
END (*UpperCase*);

FUNCTION LowerCase (upper: tKey): tKey;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (upper);
 CallMagic (448);
 LowerCase:= tKey (App^.MagicPB^.IntOut[0]);
END (*LowerCase*);

PROCEDURE KeyToScan (key: tKey; VAR scan: INTEGER; VAR kbshift: BITSET);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (key);
 CallMagic (444);
 scan:= App^.MagicPB^.IntOut[0];
 WordToBitset (App^.MagicPB^.IntOut[1], kbshift);
END (*KeyToScan*);

FUNCTION KeyToChar (key: tKey): CHAR;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (key);
 CallMagic (445);
 KeyToChar:= CHR (App^.MagicPB^.IntOut[0]);
END (*KeyToChar*);

FUNCTION CharToKey (ch: CHAR): tKey;
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (ch);
 CallMagic (446);
 CharToKey:= tKey(App^.MagicPB^.IntOut[0]);
END (*CharToKey*);

PROCEDURE SetDeadKeys (keys: BITSET);
BEGIN
 App^.MagicPB^.IntIn[0]:= BitsetToWord (keys);
 CallMagic (449);
END (*SetDeadKeys*);

PROCEDURE InitKeymap (VAR map: Keymap);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR(map);
 CallMagic (439);
END (*InitKeymap*);

PROCEDURE SetKeymap (map: Keymap);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR(map);
 CallMagic (438);
END (*SetKeymap*);

PROCEDURE ResetKeymap;
BEGIN
 CallMagic (440);
END (*ResetKeymap*);

FUNCTION ConfigPtr (): PtrConfig;
VAR l: LONGINT;
BEGIN
 IF FindCookie (Magic, l) THEN 
  ConfigPtr:= POINTER (l)
 ELSE
  ConfigPtr:= ADDR (MyCookie);
END (*ConfigPtr*);

PROCEDURE SetConfigflag (flag: LongBits; doset: BOOLEAN);
BEGIN
 ActConfig:= ConfigPtr;
 IF doset THEN  ActConfig^.flags:= ActConfig^.flags + [flag]
          ELSE  ActConfig^.flags:= ActConfig^.flags - [flag];
END (*SetConfigflag*);

FUNCTION InConfig (flag: LongBits): BOOLEAN;
BEGIN
 ActConfig:= ConfigPtr;
 InConfig:= flag IN ActConfig^.flags;
END (*InConfig*);

PROCEDURE SetDefaultkey (name: tFKeys; val: tKey);
BEGIN
 ActConfig:= ConfigPtr;
 ActConfig^.fkeytable^[name]:= ORD (val);
END (*DefaultKey*);

FUNCTION DefaultKey (name: tFKeys): tKey;
BEGIN
 ActConfig:= ConfigPtr;
 DefaultKey:= tKey(ActConfig^.fkeytable^[name]);
END (*DefaultKey*);

PROCEDURE GetDeads (VAR keys: BITSET);
BEGIN
 keys:= ActConfig^.deadkeys;
END (*GetDeadkeys*);

PROCEDURE SetDeads (keys: BITSET);
BEGIN
 ActConfig^.deadkeys:= keys;
END (*SetDeadkeys*);

PROCEDURE MagicVersion (VAR version, revision: INTEGER);
BEGIN
 CallMagic (3);
 version:= App^.MagicPB^.IntOut[0];
 revision:= App^.MagicPB^.IntOut[1];
END (*MagicVersion*);

PROCEDURE MagicVerString (VAR version: ARRAY OF CHAR);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (version);
 CallMagic (5);
END (*MagicVersion*);

PROCEDURE CallMagic (func: INTEGER);
BEGIN
 IF Assigned (ActConfig^.dispatcher) THEN BEGIN
  REPEAT 
   IF ((ActConfig^.actapp = NIL) OR 
       (ActConfig^.actapp = App)) THEN BEGIN
    ActConfig^.dispatcher (0, 0, 0, func, NIL, NIL, App);
    EXIT;
   END;
   IF MintIsDa THEN  Syield;
  UNTIL FALSE;
 END ELSE BEGIN
  IF Assigned (App^.UserEmergency) THEN BEGIN
   App^.UserEmergency;
   Terminate (-1);
  END ELSE BEGIN
   form_alert (1, '[3][Magic has terminated!|Program must abort!][Shit...]');
   Terminate (-1);
  END;
 END;
END (*CallMagic*);


PROCEDURE FatalError (num, code: INTEGER);
VAR x: ARRAY [0..127] OF CHAR;
    i, l: INTEGER;
    
 PROCEDURE CopyStr (n: INTEGER);
 VAR j: INTEGER;
 BEGIN
  j:= 0;
  WHILE FatalErrors[n, j] <> #0 DO BEGIN
   x[i]:= FatalErrors[n, j];  INC (i);  INC (j);
  END; 
 END (*CopyStr*); 

BEGIN
 FillChar (x, SIZEOF(x), #0);
 i:= 0;
 CopyStr (0);
 CopyStr (num);
 CopyStr (1);

 appl_init;
 form_alert (1, x);
 appl_exit;

 IF code <> 0 THEN HALT (code) ELSE HALT ($FFFF);
END (*FatalError*);

TYPE PtrXApp =          ^XApplication;
     XApplication =     RECORD
                         Handler:    tHandlerList;
                         DStack:     DialStack;
                         ValTable:   AppValues;
                         Prgname:    CSTRING;
                         MagicPB:    MagicParablock;
                         AESPB:      AESParablock;
                         VDIPB:      VDIParablock;
                         Ep:         EventParameter;
                         app:        M_Types.Application;
                         AESGlobal:  tAESGLOBAL;
                         AESControl: tControl;
                         AESIntin:   tIntIn;
                         AESIntout:  tIntOut;
                         AESAddrin:  tAddrIn;
                         AESAddrout: tAddrout;
                         VDIControl: tVDICtrlArray;
                         VDIIntin:   tCtrlArray;
                         VDIIntout:  tCtrlArray;
                         VDIPtsin:   tCtrlArray;
                         VDIPtsout:  tCtrlArray;
                        END;

VAR MagicPath:       PtrCSTRING;
    xapp:            PtrXApp;

PROCEDURE ProgName (name: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 i:= 0;
 WHILE (name[i] <> #0) AND (i < HIGH (name)) DO BEGIN
  xapp^.Prgname[i]:= name[i];  INC (i);
 END;
 xapp^.Prgname[i]:= #0;
 IF MintIsDa AND (App^.AESPB^.cbPGlobal^.apCount <> 1) THEN BEGIN
  menu_register (App^.AESPB^.cbPGlobal^.apid, xapp^.Prgname);
 END;
END (*ProgName*);

PROCEDURE InitAppStruct (xalloc: BOOLEAN);
CONST Op1 = $4D50;
      Op2 = $5048;
VAR i: INTEGER;
BEGIN
 App:= NIL;  xapp:= NIL;
 IF xalloc THEN
  (* Global, und TT-RAM, wenns mîglich wÑre... *)
  xapp:= Mxalloc (SIZEOF (XApplication), 32 + 3)
 ELSE
  xapp:= Malloc  (SIZEOF (XApplication));

 IF xapp = NIL THEN  Halt ($FFFF);  (* Speicherfehler *)

 FillChar (xapp^, SIZEOF(XApplication), #0);

 (* die AES-Parameterblîcke *)
 xapp^.AESGlobal.apVersion:=  0;
 xapp^.AESGlobal.apCount:=    0;
 xapp^.AESGlobal.apId:=       0;
 xapp^.AESGlobal.apPprivate:= 0;
 xapp^.AESGlobal.apPtree:=    NIL;
 xapp^.AESGlobal.apPmem:=     NIL;
 xapp^.AESGlobal.apLmem:=     0;
 xapp^.AESGlobal.apNplanes:=  0;
 xapp^.AESGlobal.Reserved1:=  0;
 xapp^.AESGlobal.Reserved2:=  0;
 xapp^.AESGlobal.apBvdisk:=   0;
 xapp^.AESGlobal.apBvhard:=   0;

 xapp^.AESPB.cbControl:= ADDR (xapp^.AESControl);
 xapp^.AESPB.cbPglobal:= ADDR (xapp^.AESGlobal);
 xapp^.AESPB.cbPintin:=  ADDR (xapp^.AESIntIn);
 xapp^.AESPB.cbPintout:= ADDR (xapp^.AESIntOut);
 xapp^.AESPB.cbPadrin:=  ADDR (xapp^.AESAddrIn);
 xapp^.AESPB.cbPadrout:= ADDR (xapp^.AESAddrOut);

 (* die VDI-Parameterblîcke *)
 xapp^.VDIPB.control:=  ADDR (xapp^.VDIControl);
 xapp^.VDIPB.intin:=    ADDR (xapp^.VDIIntIn);
 xapp^.VDIPB.ptsin:=    ADDR (xapp^.VDIPtsIn);
 xapp^.VDIPB.intout:=   ADDR (xapp^.VDIIntOut);
 xapp^.VDIPB.ptsout:=   ADDR (xapp^.VDIPtsOut);

 (* die Eventhandler *)
 xapp^.Handler.max:= MaxHandler;
 xapp^.Handler.events:= [];
 xapp^.Handler.disabled:= [];
 xapp^.Handler.PrioKeybd:= -1;
 xapp^.Handler.PrioButton:= -1;
 xapp^.Handler.PrioMesag:= -1;
 xapp^.Handler.PrioTimer:= -1;
 FillChar (xapp^.Handler.parablock, SIZEOF (xapp^.Handler.parablock), #0);
 xapp^.Handler.parablock.app:= ADDR (xapp^.app);
 FOR i:= 0 TO MaxHandler DO BEGIN
  xapp^.Handler.keybd[i].used:= 0;
  xapp^.Handler.button[i].used:= 0;
  xapp^.Handler.mesag[i].used:= 0;
  xapp^.Handler.moved[i].used:= 0;
  xapp^.Handler.rects[i].used:= 0;
  xapp^.Handler.timer[i].used:= 0;
 END;

 (* den Dialstack initialisieren *)
 xapp^.DStack.stackptr:= -1;
 xapp^.DStack.max:= MaxDials;
 FOR i:= 0 TO MaxDials DO xapp^.DStack.dials[i]:= NIL;
 
 xapp^.ValTable.max:= MaxValues;
 FOR i:= 0 TO MaxValues DO xapp^.ValTable.values[i]:= 0;
 xapp^.ValTable.values[0]:= MagicNeeded; (* Versionsnummer fÅr die Lib! *)

{
 xapp^.app.AESPB:=        ADDR (xapp^.AESPB);    (* AES-Parameter              *)
 xapp^.app.VDIPB:=        ADDR (xapp^.VDIPB);    (* VDI-Parameter              *)
}

 xapp^.app.AESPB:=        ADDR (AES.AESPB);    (* AES-Parameter              *)
 xapp^.app.VDIPB:=        ADDR (VDI.VDIPB);    (* VDI-Parameter              *)


 xapp^.app.MagicPB:=      ADDR (xapp^.MagicPB);  (* Magic-Parameter            *)
 xapp^.app.Handler:=      ADDR (xapp^.Handler);  (* Eventhandler-Liste         *)
 xapp^.app.Stack:=        ADDR (xapp^.DStack);   (* Stack fÅr modale Dialoge   *)
 xapp^.app.Values:=       ADDR (xapp^.ValTable); (* ValueTable                 *)
 xapp^.app.Name:=         ADDR (xapp^.Prgname);  (* Name des Programms         *)
 xapp^.app.dummy:=        (Op1 * $10000) + Op2;
 xapp^.app.Errcode:=      0;
 xapp^.app.wucount:=      0;
 xapp^.app.Flags:=        [MapNblock];
 xapp^.app.Dials:=        NIL;
 xapp^.app.Windows:=      NIL;
 xapp^.app.TopWindow:=    NIL;
 xapp^.app.TextWindow:=   NIL;
 xapp^.app.TopTextwin:=   NIL;
 xapp^.app.ApplIcon:=     NIL;
 xapp^.app.reserverd:=    NIL;  
 xapp^.app.Menus:=        NIL;
 xapp^.app.Mainmenu:=     NIL;
 xapp^.app.Alert:=        NIL;
 xapp^.app.Rsc:=          NIL;
 xapp^.app.Popups:=       NIL;
 xapp^.app.Workstations:= NIL;
 xapp^.app.Termproc:=     NIL;
 xapp^.app.Reserved1:=    NIL;             
 xapp^.app.Reserved2:=    NIL;
 xapp^.app.Reserved3:=    NIL;
 xapp^.app.Reserved4:=    NIL;
(* xapp^.app.Reserved5:=    NIL; *)
 xapp^.app.Next:=         NIL;
 App:= ADDR (xapp^.app);
END (*InitAppStruct*);

PROCEDURE RunKernel (CONST path: ARRAY OF CHAR);
VAR x, p, fname: STRING;
    c: CSTRING;
    i, apid: INTEGER;
    m: LONGINT;
    msg: ARRAY [0..7] OF INTEGER;
    events: BITSET;

BEGIN
 IF path[0] = #0 THEN BEGIN
  p:= ' :\';  p[1]:= CHR (boot + 65);
  x:= ' :\magic\';  x[1]:= CHR (boot + 65);
  Insert (p, x, 1);
  p:= FSearch (MagicName, x);
 END ELSE BEGIN
  i:= 0;
  WHILE path[i] <> #0 DO BEGIN
   p[i+1]:= ActConfig^.path^[i];
   INC (i);
  END;
  p[0]:= CHR (i);
 END;

 IF p <> '' THEN BEGIN
  IF MintIsDa THEN BEGIN
   (* MiNT ist da, Magic als DÑmon starten! *)
   m:= Pexec (0, p, '', base^.pEnv);
   IF m < 0 THEN  FatalError (6, m);

  END ELSE IF MagxIsDa THEN BEGIN
   (* Magx ist da, Magic als Parallelprozess starten *)

   appl_init;
   PascalToCString (p, @c);
   shel_write (1, 1, 100, c, #0#0#0);
   apid:= CallResult;

   (* Array's laden *)
   AESPB.cbPIntIn^[0]:=  BitsetToWord ([MUTIMER, MUMESAG]);
   AESPB.cbPIntIn^[14]:= 200;
   AESPB.cbPIntIn^[15]:= 0;
   AESPB.cbPadrin^[0]:=  @msg;

   REPEAT
    evnt_pmulti (events);
    IF (MUMESAG IN events) AND
       (msg[0] = CHEXIT) AND 
       (msg[3] = apid) THEN BEGIN
     FatalError(9, msg[4]);
    END;
   UNTIL FindCookie (Magic, _magic);  (* Auf Cookie warten *)

   ActConfig:= POINTER (_magic);

   REPEAT
    evnt_timer (200);
   UNTIL Assigned (ActConfig^.dispatcher); (* Ist der Dispatcher da? *)

   appl_exit;

  END ELSE BEGIN
   (* Magic als Overlay-Programm starten *)
   MagicBase:= Pexec (3, p, '', NIL);
   IF MagicBase > 0 THEN BEGIN
   m:= RunMagic;
    IF m <> 0 THEN FatalError (8, m);
   END ELSE BEGIN
    FatalError (6, MagicBase);
   END;
  END;
 END ELSE BEGIN
  FatalError (2, 0);
 END;
 
END (*RunKernel*);

VAR oldterm: POINTER;

PROCEDURE EmergencyHalt;
BEGIN
 IF NOT NormalAbort THEN BEGIN
  EXCLUDE (ActConfig^.flags, lBit30);
  ActConfig^.actapp:= NIL;
  DEC (ActConfig^.valuetable^[vNumTasks]);
  IF NOT (MintIsDa OR MagxIsDa) THEN  ActConfig^.dispatcher:= NIL;
 END;
 Setexc ($102, oldterm);
END (*EmergencyHalt*);

PROCEDURE InitMagic;
VAR i, j, e: INTEGER;
    m, cl: LONGINT;
BEGIN
 MintIsDa:= FindCookie (MiNT, _Mint);
 MagxIsDa:= FindCookie (Magx, _Magx);

 InitAppStruct (MintIsDa);

 IF FindCookie (Magic, _magic) THEN BEGIN
  ActConfig:= POINTER (_magic);
  IF NOT Assigned (ActConfig^.dispatcher) THEN BEGIN
   (* Kein Dispatcher?  Magic lÑuft wohl noch nicht... *)
   RunKernel (ActConfig^.path^);
   IF NOT Assigned (ActConfig^.dispatcher) THEN  FatalError (3, 0);
   IF ActConfig^.version < MagicNeeded THEN  FatalError (4, 0);
  END;
 END ELSE BEGIN (* Kein Cookie... *)
  RunKernel (#0#0);
  IF FindCookie (Magic, _magic) THEN BEGIN
   ActConfig:= POINTER (_magic);
   IF ActConfig^.version < MagicNeeded THEN  FatalError (4, 0);
  END ELSE BEGIN
   FatalError (3, 0);
  END;
 END;
 oldterm:= Setexc ($102, @EmergencyHalt);
END (*InitMagic*);

PROCEDURE ExitMagic;
BEGIN
 CallMagic (2);
END (*ExitMagic*);

PROCEDURE CopyrightOff;
BEGIN
 App^.MagicPB^.IntIn[0]:= 1;
 CallMagic (98);
END (*CopyrightOff*);

PROCEDURE CopyrightOn;
BEGIN
 App^.MagicPB^.IntIn[0]:= 0;
 CallMagic (98);
END (*CopyrightOn*);

PROCEDURE Ping;
BEGIN
 CallMagic (7);
END (*Ping*);

PROCEDURE SetEmergencyProc (ep: EmergencyProc);
BEGIN
 App^.UserEmergency:= ep;
END (*SetEmergencyProc*);

FUNCTION ReadFile (name: STRING; VAR size: LONGINT; VAR date, time: WORD): POINTER;
VAR cs: CSTRING;
BEGIN
 PascalToCString (name, @cs);
 App^.MagicPB^.AddrIn[0]:= @cs;
 CallMagic (1280);
 size:= App^.MagicPB^.Longout[0];
 ReadFile:= App^.MagicPB^.Addrout[0];
 date:= App^.MagicPB^.Intout[0];
 time:= App^.MagicPB^.intout[1];
END (*ReadFile*);

PROCEDURE VisualScreen (VAR r: tRect);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 CallMagic (648);
END (*VisualScreen*);

BEGIN
 MagicBase:= -1;
 NormalAbort:= FALSE;
 base:= POINTER (Basepage);
 Supexec (GetSyshdr);
 acc:= (base^.pParent = NIL);
 InitMagic;
END (*M_Sys*).
