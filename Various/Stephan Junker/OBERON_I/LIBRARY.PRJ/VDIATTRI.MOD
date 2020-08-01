MODULE VDIAttributes;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |17.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,VDI;

CONST (* write modes *)
  REPLACE* = 1; TRANSPARENT* = 2; EXOR* = 3; REVTRANS* = 4;

PROCEDURE VsfColor*(Handle,Color : INTEGER);
 BEGIN
  VDI.Intin[0] := Color; VDI.Call(25,0,Handle,00000101H);
 END VsfColor;

PROCEDURE VsfInterior*(Handle,Style : INTEGER);
 BEGIN
  VDI.Intin[0] := Style; VDI.Call(23,0,Handle,00000101H);
 END VsfInterior;

PROCEDURE VsfPerimeter*(Handle : INTEGER; Visible : BOOLEAN);
 BEGIN
  VDI.Intin[0] := LONG(S.VAL(SHORTINT,Visible));
  VDI.Call(104,0,Handle,00000101H);
 END VsfPerimeter;

PROCEDURE VsfStyle*(Handle,Style : INTEGER);
 BEGIN
  VDI.Intin[0] := Style; VDI.Call(24,0,Handle,00000101H);
 END VsfStyle;

PROCEDURE VsfUdpat*(Handle : INTEGER; VAR FillPat : ARRAY OF INTEGER;
                    Planes : INTEGER);
 BEGIN
  VDI.ParmBlk.Intin := S.ADR(FillPat); VDI.Call(112,0,Handle,Planes * 1000H);
  VDI.ParmBlk.Intin := S.ADR(VDI.Intin);
 END VsfUdpat;

PROCEDURE VslColor*(Handle,Color : INTEGER);
 BEGIN
  VDI.Intin[0] := Color; VDI.Call(17,0,Handle,00000101H);
 END VslColor;

PROCEDURE VslEnds*(Handle,BegStyle,EndStyle : INTEGER);
 BEGIN
  VDI.Intin[0] := BegStyle; VDI.Intin[1] := EndStyle;
  VDI.Call(108,0,Handle,00000200H);
 END VslEnds;

PROCEDURE VslType*(Handle,Style : INTEGER);
 BEGIN
  VDI.Intin[0] := Style; VDI.Call(15,0,Handle,00000101H);
 END VslType;

PROCEDURE VslUdsty*(Handle,Pattern : INTEGER);
 BEGIN
  VDI.Intin[0] := Pattern; VDI.Call(113,0,Handle,00000100H);
 END VslUdsty;

PROCEDURE VslWidth*(Handle,Width : INTEGER);
 BEGIN
  VDI.Ptsin[0] := Width; VDI.Ptsin[1] := 0;
  VDI.Call(16,0,Handle,01010000H);
 END VslWidth;

PROCEDURE VsmColor*(Handle,Color : INTEGER);
 BEGIN
  VDI.Intin[0] := Color; VDI.Call(20,0,Handle,00000101H);
 END VsmColor;

PROCEDURE VsmHeight*(Handle,Height : INTEGER);
 BEGIN
  VDI.Ptsin[0] := 0; VDI.Ptsin[1] := Height;
  VDI.Call(19,0,Handle,01010000H);
 END VsmHeight;

PROCEDURE VsmType*(Handle,Type : INTEGER);
 BEGIN
  VDI.Intin[0] := Type; VDI.Call(18,0,Handle,00000101H);
 END VsmType;

PROCEDURE VstAlignment*(Handle,HorIn,VertIn : INTEGER);
 BEGIN
  VDI.Intin[0] := HorIn; VDI.Intin[1] := VertIn;
  VDI.Call(39,0,Handle,00000202H);
 END VstAlignment;

PROCEDURE VstColor*(Handle,Color : INTEGER);
 BEGIN
  VDI.Intin[0] := Color; VDI.Call(22,0,Handle,00000101H);
 END VstColor;

PROCEDURE VstEffects*(Handle,Effect : INTEGER);
 BEGIN
  VDI.Intin[0] := Effect; VDI.Call(106,0,Handle,00000101H);
 END VstEffects;

PROCEDURE VstFont*(Handle,Font : INTEGER);
 BEGIN
  VDI.Intin[0] := Font; VDI.Call(21,0,Handle,00000101H);
 END VstFont;

PROCEDURE VstHeight*(Handle,Height : INTEGER; VAR CharW,CharH,CellW,CellH : INTEGER);
 BEGIN
  VDI.Ptsin[0] := 0; VDI.Ptsin[1] := Height;
  VDI.Call(12,0,Handle,01020000H);
  CharW := VDI.Ptsout[0]; CharH := VDI.Ptsout[1];
  CellW := VDI.Ptsout[2]; CellH := VDI.Ptsout[3];
 END VstHeight;

PROCEDURE VstPoint*(Handle,Point : INTEGER; VAR CharW,CharH,CellW,CellH : INTEGER);
 BEGIN
  VDI.Intin[0] := Point; VDI.Call(107,0,Handle,00020101H);
  CharW := VDI.Ptsout[0]; CharH := VDI.Ptsout[1];
  CellW := VDI.Ptsout[2]; CellH := VDI.Ptsout[3];
 END VstPoint;

PROCEDURE VstRotation*(Handle,Angle : INTEGER);
 BEGIN
  VDI.Intin[0] := Angle; VDI.Call(13,0,Handle,00000101H);
 END VstRotation;

PROCEDURE VswrMode*(Handle,Mode : INTEGER);
 BEGIN
  VDI.Intin[0] := Mode; VDI.Call(32,0,Handle,00000101H);
 END VswrMode;

PROCEDURE VsColor*(Handle,Index,Red,Green,Blue : INTEGER);
 BEGIN
  VDI.Intin[0] := Index; VDI.Intin[1] := Red;
  VDI.Intin[2] := Green; VDI.Intin[3] := Blue;
  VDI.Call(14,0,Handle,00000400H);
 END VsColor;

END VDIAttributes.
