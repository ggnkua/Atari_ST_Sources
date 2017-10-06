UNIT M_Fontselector;

INTERFACE

USES Basics;

CONST fsFlydial =      Bit0;   (* Normaler Dialog                 *)
      fsModal =        Bit1;   (* Selektor in Fenster             *)
      fsNonmodal =     Bit2;   (* Selektor ist nicht-modal        *)
      fsMonospaced =   Bit3;   (* Nur monospaced Fonts            *)
      fsEffect =       Bit4;   (* Texteffekte ausw„hlen           *)
      fsColor =        Bit5;   (* Farbe ausw„hlen                 *)
      fsRotation =     Bit6;   (* Rotation einstellen             *)
      fsWidth =        Bit7;   (* Breite bei FSM-Fonts einstellen *)
      fsSpeedoOnly =   Bit8;   (* Nur Speedofonts anzeigen        *)
      fsBitmapOnly =   Bit9;   (* Nur Speedofonts anzeigen        *)
      fsTruetypeOnly = Bit10;  (* Nur Truetypefonts anzeigen      *)
      fsType1Only =    Bit11;  (* Nur Type1-Fonts zulassen        *)
      fsFixType =      Bit12;  (* Typselektion nicht zulassen     *)
      fsOwntext =      Bit13;  (* Eigenen Text in die Auswahlbox  *)
      fsVectorfont =   Bit14;  (* Eigenen Text in die Auswahlbox  *)

PROCEDURE SampleSentence (CONST txt: STRING);
PROCEDURE FontSelector (handle: INTEGER; CONST msg: STRING; opt: BITSET; win: INTEGER);
PROCEDURE CloseSelector;
PROCEDURE RedrawSelector;
PROCEDURE SelectorInfo (VAR win, xpos, ypos, font: INTEGER);

IMPLEMENTATION

USES M_Sys;


PROCEDURE FontSelector (handle: INTEGER; 
                        CONST msg: STRING;
                        opt: BITSET;
                        win: INTEGER);
VAR x: CSTRING;
BEGIN
 PascalToCString (msg, @x);
 App^.MagicPB^.AddrIn[0]:= ADDR (x);
 App^.MagicPB^.IntIn[0]:= handle;
 App^.MagicPB^.IntIn[1]:= BitsetToWord (opt);
 App^.MagicPB^.IntIn[2]:= win;
 CallMagic (1500);
END (*FontSelector*);

PROCEDURE CloseSelector;
BEGIN
 CallMagic (1501);
END (*CloseSelector*);

PROCEDURE SampleSentence (CONST txt: STRING);
VAR x: CSTRING;
BEGIN
 PascalToCString (txt, @x);
 App^.MagicPB^.AddrIn[0]:= ADDR (x);
 CallMagic (1502);
END (*SampleSentence*);

PROCEDURE RedrawSelector;
BEGIN
 CallMagic (1503);
END (*RedrawSelector*);

PROCEDURE SelectorInfo (VAR win, xpos, ypos, font: INTEGER);
BEGIN
 CallMagic (1505);
 win:=  App^.MagicPB^.IntOut[0];
 xpos:= App^.MagicPB^.IntOut[1];
 ypos:= App^.MagicPB^.IntOut[2];
 font:= App^.MagicPB^.IntOut[3];
END (*SelectorInfo*);

END (*M_Fontselector*).
