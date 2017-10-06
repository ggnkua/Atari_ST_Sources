UNIT M_Area;

INTERFACE

USES Basics, VDI;

TYPE    AREA =           ^AreaDescr;
        AreaDescr =      RECORD (* Nicht DIREKT zugreifen!!! *)
                          x:     INTEGER;
                          y:     INTEGER;
                          w:     INTEGER;
                          h:     INTEGER;
                          init:  BOOLEAN;
                          size:  LONGINT;
                          mfdbadr: POINTER;
                          mfdb:  MFDB;
                         END;

PROCEDURE SetMFDB (VAR m: MFDB; adr: POINTER; w, h, fm, planes: INTEGER);
FUNCTION  NewAREA (VAR a: AREA): BOOLEAN;
PROCEDURE DisposeAREA (VAR a: AREA);
PROCEDURE FreeArea (a: AREA);
FUNCTION  SaveArea (hndl: INTEGER; a: AREA; rect: tRect): BOOLEAN;
PROCEDURE CopyArea (hndl: INTEGER; a: AREA; xx, yy: INTEGER);
PROCEDURE RestoreArea (hndl: INTEGER; a: AREA);
PROCEDURE MoveArea (hndl: INTEGER; a: AREA; xmove, ymove: INTEGER; VAR xx, yy: INTEGER);

IMPLEMENTATION

{$I COMPOPT.INC}

USES M_Sys;


PROCEDURE SetMFDB (VAR m: MFDB; adr: POINTER; w, h, fm, planes: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (m);
 App^.MagicPB^.AddrIn[1]:= adr;
 App^.MagicPB^.IntIn[0]:= w;
 App^.MagicPB^.IntIn[0]:= h;
 App^.MagicPB^.IntIn[0]:= fm;
 App^.MagicPB^.IntIn[0]:= planes;
 CallMagic (708);
END (*SetMFDB*);

FUNCTION NewAREA (VAR a: AREA): BOOLEAN;
BEGIN
 CallMagic (700);
 a:= App^.MagicPB^.AddrOut[0];
 NewAREA:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*NewAREA*);

PROCEDURE DisposeAREA (VAR a: AREA);
BEGIN
 App^.MagicPB^.AddrIn[0]:= a;
 CallMagic (701);
 a:= NIL;
END (*DisposeAREA*);

PROCEDURE FreeArea (a: AREA);
BEGIN
 App^.MagicPB^.AddrIn[0]:= a;
 CallMagic (702);
END (*FreeArea*);

FUNCTION SaveArea (hndl: INTEGER; a: AREA; rect: tRect): BOOLEAN;
BEGIN
 App^.MagicPB^.IntIn[0]:= hndl;
 App^.MagicPB^.AddrIn[0]:= a;
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 CallMagic (703);
 SaveArea:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*SaveArea*);

PROCEDURE RestoreArea (hndl: INTEGER; a: AREA);
BEGIN
 App^.MagicPB^.IntIn[0]:= hndl;
 App^.MagicPB^.AddrIn[0]:= a;
 CallMagic (705);
END (*RestoreArea*);

PROCEDURE CopyArea (hndl: INTEGER; a: AREA; xx, yy: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= hndl;
 App^.MagicPB^.IntIn[1]:= xx;
 App^.MagicPB^.IntIn[2]:= yy;
 App^.MagicPB^.AddrIn[0]:= a;
 CallMagic (704);
END (*CopyArea*);

PROCEDURE MoveArea (hndl: INTEGER; a: AREA; xmove, ymove: INTEGER;
                    VAR xx, yy: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= hndl;
 App^.MagicPB^.IntIn[1]:= xmove;
 App^.MagicPB^.IntIn[2]:= ymove;
 App^.MagicPB^.AddrIn[0]:= a;
 CallMagic (706);
 xx:= App^.MagicPB^.IntOut[0];
 yy:= App^.MagicPB^.IntOut[1];
END (*MoveArea*);

END (*mpArea*).
