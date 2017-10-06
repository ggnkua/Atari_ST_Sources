UNIT M_Popups;

INTERFACE

PROCEDURE AttachPopup (main, sub: POINTER; entry: INTEGER);
PROCEDURE Popup (tree: POINTER; x, y, idx: INTEGER; VAR pop: POINTER; VAR item: INTEGER);

IMPLEMENTATION

{$I COMPOPT.INC}

USES M_Sys;

PROCEDURE AttachPopup (main, sub: POINTER; entry: INTEGER);
BEGIN
 WITH App^.MagicPB^ DO BEGIN
  AddrIn[0]:= main;
  AddrIn[1]:= sub;
  IntIn[0]:= entry;
  CallMagic (1701);
 END;
END (*AttachPopup*);

PROCEDURE Popup (tree: POINTER; x, y, idx: INTEGER; VAR pop: POINTER; VAR item: INTEGER);
BEGIN
 WITH App^.MagicPB^ DO BEGIN
  AddrIn[0]:= tree;
  IntIn[0]:= x;
  IntIn[1]:= y;
  IntIn[2]:= idx;
  CallMagic (1700);
  pop:= AddrOut[0];
  item:= IntOut[0];
 END;
END (*Popup*);

END (*M_Popups*).
