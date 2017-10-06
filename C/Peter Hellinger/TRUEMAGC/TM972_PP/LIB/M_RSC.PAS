UNIT M_Rsc;

INTERFACE

TYPE    RESOURCE =  POINTER;

FUNCTION  LoadRsc (name: STRING; VAR rsc: RESOURCE): BOOLEAN;
FUNCTION  RelocRsc (address: POINTER; VAR rsc: RESOURCE): BOOLEAN;
PROCEDURE FreeRsc (VAR rsc: RESOURCE);
FUNCTION  GaddrRsc (rsc: RESOURCE; typ, item: INTEGER): POINTER;
PROCEDURE SaddrRsc (rsc: RESOURCE; typ, item: INTEGER; tree: POINTER);
PROCEDURE ObfixRsc (rsc: RESOURCE; tree: POINTER; objc: INTEGER);

FUNCTION  CloneTree (tree: POINTER; img: BOOLEAN): POINTER;
PROCEDURE FreeClone (tree: POINTER);
 
IMPLEMENTATION

USES Basics, M_Sys;

FUNCTION LoadRsc (name: STRING; VAR rsc: RESOURCE): BOOLEAN;
VAR s: CSTRING;
BEGIN
 PascalToCString (name, @s);
 App^.MagicPB^.AddrIn[0]:= ADDR (s);
 CallMagic (1900);
 rsc:= App^.MagicPB^.AddrOut[0];
 LoadRsc:= rsc <> NIL;
END (*LoadRsc*);

FUNCTION RelocRsc (address: POINTER; VAR rsc: RESOURCE): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= address;
 CallMagic (1901);
 rsc:= App^.MagicPB^.AddrOut[0];
 RelocRsc:= rsc <> NIL;
END (*RelocRsc*);

PROCEDURE FreeRsc (VAR rsc: RESOURCE);
BEGIN
 App^.MagicPB^.AddrIn[0]:= rsc;
 CallMagic (1902);
 rsc:= NIL;
END (*FreeRsc*);

FUNCTION GaddrRsc (rsc: RESOURCE; typ, item: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= rsc;
 App^.MagicPB^.IntIn[0]:= typ;
 App^.MagicPB^.IntIn[1]:= item;
 CallMagic (1904);
 GaddrRsc:= App^.MagicPB^.AddrOut[0];
END (*GaddrRsc*);

PROCEDURE SaddrRsc (rsc: RESOURCE; typ, item: INTEGER; tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= rsc;
 App^.MagicPB^.AddrIn[1]:= tree;
 App^.MagicPB^.IntIn[0]:= typ;
 App^.MagicPB^.IntIn[1]:= item;
 CallMagic (1905);
END (*SaddrRsc*);

PROCEDURE ObfixRsc (rsc: RESOURCE; tree: POINTER; objc: INTEGER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= rsc;
 App^.MagicPB^.AddrIn[1]:= tree;
 App^.MagicPB^.IntIn[0]:= objc;
 CallMagic (1906);
END (*ObfixRsc*);

FUNCTION CloneTree (tree: POINTER; img: BOOLEAN): POINTER;
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.IntIn[0]:=  ORD (img);
 CallMagic (1909);
 CloneTree:= App^.MagicPB^.AddrOut[0];
END (*CloneTree*);

PROCEDURE FreeClone (tree: POINTER);
BEGIN
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic (1910);
END (*CloneTree*);

END (*M_Rsc*).
