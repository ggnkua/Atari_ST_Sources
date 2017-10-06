UNIT M_Menus;

INTERFACE

USES M_Types, Basics;

CONST mCheck =        Bit0; (* H„ckchen setzen   *)
      mUncheck =      Bit1; (* H„ckchen l”schen  *)
      mDisable =      Bit2; (* Eintrag disablen  *)
      mEnable =       Bit3; (* Eintrag freigeben *)
      mSwapDisabled = Bit4; (* Bei den Eintr„gen, die in spec.x..spec.h stehen
                             * werden die Disabled-Flags geswapped. Disabled
                             * wird zu nicht disabled und umgekehrt.
                             *)
      mSwapChecked =  Bit5; (* Wie mSwapDisabled, nur mit den CHECKED-Flag *)
      mBell =         Bit6; (* Das Stadler-Flag: Klingeling! *)

TYPE PtrMenupara =      ^MenuParameter;
     MenuParameter =    RECORD
                         tree:          POINTER;
                         key:           tKey;
                         window:        INTEGER;
                         mx, my:        INTEGER;
                         menu, entry:   INTEGER;
                         spec:          tRect;
                         action:        BITSET;
                        END;

TYPE MenuHandler = PROCEDURE (mp: PtrMenupara);

FUNCTION  InitMenuline (menu: POINTER; handler: MenuHandler; lines: BOOLEAN): BOOLEAN;
PROCEDURE InstallDeskMenu (menu: POINTER);
PROCEDURE ReleaseDeskMenu;
PROCEDURE DisableDeskMenu;
PROCEDURE EnableDeskMenu;
PROCEDURE AttachMenu (main, sub: POINTER; entry, back, start, scroll: INTEGER);
FUNCTION  ScanMenu (menu: POINTER; key: tKey; kbshift: BITSET; 
                    VAR title, item, sub: INTEGER): BOOLEAN;

IMPLEMENTATION

{$I COMPOPT.INC}

USES M_Sys;

FUNCTION InitMenuline (menu: POINTER; handler: MenuHandler;
                       lines: BOOLEAN): BOOLEAN;
VAR x: RECORD
        CASE INTEGER OF
         0: (ptr: POINTER);
         1: (hnd: MenuHandler);
       END;
BEGIN
 x.hnd:= handler;
 App^.MagicPB^.AddrIn[0]:= menu;
 App^.MagicPB^.AddrIn[1]:= x.ptr;
 App^.MagicPB^.IntIn[0]:= ORD (lines);
 CallMagic (1600);
 InitMenuline:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*InitMenuline*);

PROCEDURE InstallDeskMenu (menu: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= menu;
 CallMagic (1601);
END (*InstallDeskMenu*);

PROCEDURE ReleaseDeskMenu;
BEGIN
 CallMagic (1602);
END (*ReleaseDeskMenu*);

PROCEDURE DisableDeskMenu;
BEGIN
 CallMagic (1603);
END (*DisableDeskMenu*);

PROCEDURE EnableDeskMenu;
BEGIN
 CallMagic (1604);
END (*EnableDeskMenu*);

PROCEDURE AttachMenu (main, sub: POINTER; 
                      entry, back, start, scroll: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= main;
 App^.MagicPB^.AddrIn[1]:= sub;
 App^.MagicPB^.IntIn[0]:=  entry;
 App^.MagicPB^.IntIn[1]:=  back;
 App^.MagicPB^.IntIn[2]:=  start;
 App^.MagicPB^.IntIn[3]:=  scroll;
 CallMagic (1606);
END (*AttachMenu*);

FUNCTION ScanMenu (menu: POINTER; key: tKey; kbshift: BITSET; 
                   VAR title, item, sub: INTEGER): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= menu;
 App^.MagicPB^.IntIn[0]:=  INTEGER (key);
 App^.MagicPB^.IntIn[1]:=  BitsetToWord (kbshift);
 CallMagic (1607);
 ScanMenu:= BOOLEAN (App^.MagicPB^.IntOut[0]);
 title:= App^.MagicPB^.IntOut[1];
 item:=  App^.MagicPB^.IntOut[2];
 sub:=   App^.MagicPB^.IntOut[3];
END (*ScanMenu*);

END (*M_Menus*).
