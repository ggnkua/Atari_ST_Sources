(*--- Swap-Funktionen --------------------------------------------------*)
UNIT M_Heap;

INTERFACE

FUNCTION  GetHeap (size: LONGINT): POINTER;
PROCEDURE FreeHeap (VAR p: POINTER; size: LONGINT);

FUNCTION  SwapOut (VAR p: POINTER; size: LONGINT): BOOLEAN;
FUNCTION  SwapIn  (VAR p: POINTER): BOOLEAN;
FUNCTION  SwappedOut (p: POINTER): BOOLEAN;
PROCEDURE CloseSwapping;

IMPLEMENTATION

USES M_Sys;

FUNCTION  GetHeap (size: LONGINT): POINTER;
BEGIN
 App^.MagicPB^.LongIn[0]:= size;
 CallMagic (2704);
 GetHeap:= App^.MagicPB^.AddrOut[0];
END (*GetHeap*);

PROCEDURE FreeHeap (VAR p: POINTER; size: LONGINT);
BEGIN
 App^.MagicPB^.AddrIn[0]:= p;
 App^.MagicPB^.LongIn[0]:= size;
 CallMagic (2705);
 p:= App^.MagicPB^.AddrIn[0];
END (*FreeHeap*);

FUNCTION SwapOut (VAR p: POINTER; size: LONGINT): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= p;
 App^.MagicPB^.LongIn[0]:= size;
 CallMagic (2700);
 p:= App^.MagicPB^.AddrIn[0];
 SwapOut:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*SwapOut*);

FUNCTION SwapIn (VAR p: POINTER): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= p;
 CallMagic (2701);
 p:= App^.MagicPB^.AddrIn[0];
 SwapIn:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*SwapIn*);

FUNCTION  SwappedOut (p: POINTER): BOOLEAN;
BEGIN
 App^.MagicPB^.AddrIn[0]:= p;
 CallMagic (2702);
 SwappedOut:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*SwappedOut*);

PROCEDURE CloseSwapping;
BEGIN
 CallMagic (2703);
END (*CloseSwapping*);

END (*Swap*).
