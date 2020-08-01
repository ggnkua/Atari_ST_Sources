MODULE VDIInquiry;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |23.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,VDI;

CONST (* device types *)
  LOCATOR* = 1; VALUATOR* = 2; CHOICE* = 3; STRING* = 4;
  (* input mode *)
  REQUEST* = 1; SAMPLE* = 2;

PROCEDURE VqfAttributes*(Handle : INTEGER; VAR Interior,Color,Style,
                         WrMode,Perimeter : INTEGER);
 BEGIN
  VDI.Call(37,0,Handle,00000005H);
  Interior := VDI.Intout[0]; Color := VDI.Intout[1];
  Style := VDI.Intout[2]; WrMode := VDI.Intout[3];
  Perimeter := VDI.Intout[4];
 END VqfAttributes;

PROCEDURE VqinMode*(Handle,DevType : INTEGER) : INTEGER;
 BEGIN
  VDI.Intin[0] := DevType; VDI.Call(115,0,Handle,00000101H);
  RETURN VDI.Intout[0];
 END VqinMode;

PROCEDURE VqlAttributes*(Handle : INTEGER; VAR Type,Color,WrMode,Beg,
                         End,Width : INTEGER);
 BEGIN
  VDI.Call(35,0,Handle,00010005H);
  Type := VDI.Intout[0]; Color := VDI.Intout[1];
  WrMode := VDI.Intout[2]; Beg := VDI.Intout[3];
  End := VDI.Intout[4]; Width := VDI.Ptsout[0];
 END VqlAttributes;

PROCEDURE VqmAttributes*(Handle : INTEGER; VAR Type,Color,WrMode,Width,
                         Height : INTEGER);
 BEGIN
  VDI.Call(36,0,Handle,00020003H);
  Type := VDI.Intout[0]; Color := VDI.Intout[1];
  WrMode := VDI.Intout[2]; Width := VDI.Ptsout[0];
  Height := VDI.Ptsout[1];
 END VqmAttributes;

PROCEDURE VqtAttributes*(Handle : INTEGER; VAR Font,Color,Angle,HorAlign,
                         VertAlign,WrMode,CharWidth,CharHeight,CellWidth,
                         CellHeight : INTEGER);
 BEGIN
  VDI.Call(38,0,Handle,00040006H);
  Font := VDI.Intout[0]; Color := VDI.Intout[1];
  Angle := VDI.Intout[2]; HorAlign := VDI.Intout[3];
  VertAlign := VDI.Intout[4]; WrMode := VDI.Intout[5];
  CharWidth := VDI.Ptsout[0]; CharHeight := VDI.Ptsout[1];
  CellWidth := VDI.Ptsout[2]; CellHeight := VDI.Ptsout[3];
 END VqtAttributes;

PROCEDURE VqtExtent*(Handle : INTEGER; String : ARRAY OF CHAR;
                     VAR x1,y1,x2,y2,x3,y3,x4,y4 : INTEGER);
  VAR i : INTEGER;
 BEGIN
  i := 0;
  WHILE String[i] # 0X DO VDI.Intin[i] := ORD(String[i]); INC(i) END;
  VDI.Call(116,0,Handle,00080000H + i*256);
  x1 := VDI.Ptsout[0]; y1 := VDI.Ptsout[1];
  x2 := VDI.Ptsout[2]; y2 := VDI.Ptsout[3];
  x3 := VDI.Ptsout[4]; y3 := VDI.Ptsout[5];
  x4 := VDI.Ptsout[6]; y4 := VDI.Ptsout[7];
 END VqtExtent;

PROCEDURE VqtFontinfo*(Handle : INTEGER; VAR FirstChar,LastChar : CHAR;
                       VAR DistBotBase,DistBaseDesc,DistHalfBase,
                           DistBaseAsc,DistBaseTop,MaxWidth,AddWidth,
                           AddLeft,AddRight : INTEGER);
 BEGIN
  VDI.Call(131,0,Handle,00050002H);
  FirstChar := CHR(VDI.Intout[0]); LastChar := CHR(VDI.Intout[1]);
  MaxWidth := VDI.Ptsout[0]; DistBotBase := VDI.Ptsout[1];
  AddWidth := VDI.Ptsout[2]; DistBaseDesc := VDI.Ptsout[3];
  AddLeft := VDI.Ptsout[4]; DistHalfBase := VDI.Ptsout[5];
  AddRight := VDI.Ptsout[6]; DistBaseAsc := VDI.Ptsout[7];
  DistBaseTop := VDI.Ptsout[9];
 END VqtFontinfo;

PROCEDURE VqtName*(Handle,FontNo : INTEGER; VAR Name : ARRAY OF CHAR) : INTEGER;
  VAR i : INTEGER;
 BEGIN
  VDI.Intin[0] := FontNo; VDI.Call(130,0,Handle,00000121H); i := 32;
  REPEAT DEC(i); Name[i] := CHR(VDI.Intout[i+1]) UNTIL i = 0;
  Name[32] := 0X; RETURN VDI.Intout[0];
 END VqtName;

PROCEDURE VqtWidth*(Handle : INTEGER; Char : CHAR;
                    VAR CellWidth,LeftDelta,RightDelta : INTEGER);
 BEGIN
  VDI.Intin[0] := ORD(Char); VDI.Call(117,0,Handle,00030101H);
  CellWidth := VDI.Ptsout[0]; LeftDelta := VDI.Ptsout[2];
  RightDelta := VDI.Ptsout[4];
 END VqtWidth;

PROCEDURE VqColor*(Handle,ColorIndex : INTEGER; SetFlag : BOOLEAN;
                   VAR Red,Green,Blue : INTEGER);
 BEGIN
  VDI.Intin[0] := ColorIndex;
  VDI.Intin[1] := LONG(S.VAL(SHORTINT,SetFlag));
  VDI.Call(26,0,Handle,00000204H);
  Red := VDI.Intout[1]; Green := VDI.Intout[2]; Blue := VDI.Intout[3];
 END VqColor;

PROCEDURE VqExtnd*(Handle : INTEGER; Extended : BOOLEAN;
                   VAR Info : ARRAY OF INTEGER);
  VAR i : INTEGER;
 BEGIN
  VDI.Intin[0] := LONG(S.VAL(SHORTINT,Extended));
  VDI.Call(1,0,Handle,00060B2DH);
  S.MOVE( S.ADR(VDI.Intout), S.ADR(Info), 90 );
  S.MOVE( S.ADR(VDI.Ptsout), S.ADR(Info[45]), 24 );
END VqExtnd;

END VDIInquiry.
