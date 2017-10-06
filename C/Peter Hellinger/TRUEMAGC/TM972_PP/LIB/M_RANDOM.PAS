UNIT M_Random;

INTERFACE

PROCEDURE Randomize;
PROCEDURE RandomInit (initial: WORD);
FUNCTION RndInt (max: INTEGER): INTEGER;
FUNCTION RndLInt (max: LONGINT): LONGINT;
FUNCTION RndReal: REAL;

IMPLEMENTATION

USES M_Sys;

{$I COMPOPT.INC}

PROCEDURE RandomInit (initial: WORD);
BEGIN
 App^.MagicPB^.IntIn[0]:= initial;  CallMagic (1801);
END (*RandomInit*);

PROCEDURE Randomize;
BEGIN
 CallMagic (1800);
END (*Randomize*);

FUNCTION RndInt (max: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.IntIn[0]:= max;
 CallMagic (1802);
 RndInt:= App^.MagicPB^.IntOut[0];
END (*RndInt*);

FUNCTION RndLInt (max: LONGINT): LONGINT;
BEGIN
 App^.MagicPB^.LongIn[0]:= max;
 CallMagic (1803);
 RndLInt:= App^.MagicPB^.LongOut[0];
END (*RndLInt*);

FUNCTION RndReal: REAL;
VAR r: REAL;
BEGIN
 App^.MagicPB^.AddrIn[0]:= ADDR (r);
 CallMagic (1804);
 RndReal:= r;
END (*RndReal*);

END (*M_Random*).

