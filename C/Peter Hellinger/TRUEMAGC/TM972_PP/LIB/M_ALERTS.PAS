UNIT M_Alerts;

INTERFACE

USES AES;

TYPE PtrAlertpara = ^Alertpara;
     Alertpara =    RECORD
                     message: INTEGER;
                     objc:    INTEGER;
                    END;

TYPE AlertHandler = PROCEDURE (dp: PtrAlertpara);

FUNCTION  Alert (x, y, def: INTEGER; str: STRING): INTEGER;
PROCEDURE WindowAlert (x, y, def: INTEGER; str: STRING; handler: AlertHandler);
PROCEDURE SetIconColor (fcolor, bcolor: INTEGER);
FUNCTION  Iconslot (slotnum: INTEGER): PtrCICONBLK;
PROCEDURE SetIconslot (slotnum: INTEGER; icon: PtrCICONBLK);

IMPLEMENTATION

USES M_Sys;

VAR cs: ARRAY [0..1024] OF CHAR;

FUNCTION Alert (x, y, def: INTEGER; str: STRING): INTEGER;
VAR a: ^POINTER;
BEGIN
 Alert:= -1;
 PascalToCString (str, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 App^.MagicPB^.AddrIn[1]:= NIL;
 App^.MagicPB^.Intin[0]:= def;
 App^.MagicPB^.Intin[1]:= x;
 App^.MagicPB^.Intin[2]:= y;
 App^.MagicPB^.Intin[3]:= ORD ((x > 0) OR (y >0));
 App^.MagicPB^.Intin[4]:= 1;
 CallMagic (500);
 Alert:= App^.MagicPB^.IntOut[0];
END (*Alert*);

PROCEDURE WindowAlert (x, y, def: INTEGER; str: STRING; 
                       handler: AlertHandler);
VAR c: RECORD
        CASE INTEGER OF
         0: (ptr: POINTER);
         1: (hnd: AlertHandler);
       END;
BEGIN
 c.hnd:= handler;
 PascalToCString (str, @cs);
 App^.MagicPB^.AddrIn[0]:= ADDR (cs);
 App^.MagicPB^.AddrIn[1]:= c.ptr;
 App^.MagicPB^.Intin[0]:= def;
 App^.MagicPB^.Intin[1]:= x;
 App^.MagicPB^.Intin[2]:= y;
 App^.MagicPB^.Intin[3]:= ORD ((x > 0) OR (y >0));
 App^.MagicPB^.Intin[4]:= 0;
 CallMagic (500);
END (*WindowAlert*);

PROCEDURE SetIconColor (fcolor, bcolor: INTEGER);
BEGIN
 App^.MagicPB^.Intin[0]:= fcolor;
 App^.MagicPB^.Intin[1]:= bcolor;
 CallMagic (502);
END (*SetIconColor*);

FUNCTION Iconslot (slotnum: INTEGER): PtrCICONBLK;
BEGIN
 App^.MagicPB^.Intin[0]:= slotnum;
 CallMagic (503);
 IconSlot:= App^.MagicPB^.AddrOut[0];
END (*IconSlot*);

PROCEDURE SetIconslot (slotnum: INTEGER; icon: PtrCICONBLK);
BEGIN
 App^.MagicPB^.AddrIn[0]:= icon;
 App^.MagicPB^.Intin[0]:= slotnum;
 CallMagic (504);
END (*SetIconSlot*);

END (*M_Alert*).