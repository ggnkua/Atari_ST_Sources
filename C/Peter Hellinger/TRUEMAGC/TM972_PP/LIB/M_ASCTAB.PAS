UNIT M_AscTable;

INTERFACE

USES M_Types;

FUNCTION AsciiTable (rect: tRect): CHAR;

IMPLEMENTATION

(*$I COMPOPT.INC*)

USES M_Sys;

FUNCTION AsciiTable (rect: tRect): CHAR;
(* Dialoghandling fÅr CharInsert *)
BEGIN
 App^.MagicPB^.AddrIn[1]:= ADDR (rect);
 CallMagic (800);
 AsciiTable:= CHR (App^.MagicPB^.IntOut[0]);
END (*AsciiTable*);

END (*M_AscTable*).
