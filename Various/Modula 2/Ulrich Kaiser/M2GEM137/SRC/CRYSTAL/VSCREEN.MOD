IMPLEMENTATION MODULE VScreen;

(*
VDI Escape Functions for Screens.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT intin,ptsin,intout,v,CallVDI,CallEsc,CallVDIEsc,
                   Integer,MaxInput,EOS,XY,Point;
FROM PORTAB IMPORT ANYWORD,UNSIGNEDWORD;
CAST_IMPORT

PROCEDURE VQChCells(    Handle : UNSIGNEDWORD;
                    VAR Rows   : UNSIGNEDWORD;
                    VAR Columns: UNSIGNEDWORD);
BEGIN
  CallEsc(1,Handle);
  Rows:= intout[0];
  Columns:= intout[1];
END VQChCells;

PROCEDURE VExitCur(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(2,Handle);
END VExitCur;

PROCEDURE VEnterCur(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(3,Handle);
END VEnterCur;

PROCEDURE VCurUp(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(4,Handle);
END VCurUp;

PROCEDURE VCurDown(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(5,Handle);
END VCurDown;

PROCEDURE VCurRight(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(6,Handle);
END VCurRight;

PROCEDURE VCurLeft(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(7,Handle);
END VCurLeft;

PROCEDURE VCurHome(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(8,Handle);
END VCurHome;

PROCEDURE VEEOS(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(9,Handle);
END VEEOS;

PROCEDURE VEEOL(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(10,Handle);
END VEEOL;

PROCEDURE VCurAddress(Handle: UNSIGNEDWORD;
                      Row   : UNSIGNEDWORD;
                      Column: UNSIGNEDWORD);
BEGIN
  intin[0]:= Row;
  intin[1]:= Column;
  CallVDIEsc(11,0,2,Handle);
END VCurAddress;

PROCEDURE VCurText(    Handle: UNSIGNEDWORD;
                   VAR String: ARRAY OF CHAR);

VAR i: [0..MaxInput];

BEGIN
  i:= 0;
  WHILE String[i] # EOS DO
   intin[i]:= ORD(String[i]);
   INC(i);
  END;
  CallVDIEsc(12,0,i,Handle); (* i - 1 + 1 = i *)
END VCurText;

PROCEDURE VRvOn(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(13,Handle);
END VRvOn;

PROCEDURE VRvOff(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(14,Handle);
END VRvOff;

PROCEDURE VQCurAddress(    Handle: UNSIGNEDWORD;
                       VAR Row   : UNSIGNEDWORD;
                       VAR Column: UNSIGNEDWORD);
BEGIN
  CallEsc(15,Handle);
  Row:= intout[0];
  Column:= intout[1];
END VQCurAddress;

PROCEDURE VQTabStatus(Handle: UNSIGNEDWORD): BOOLEAN;
BEGIN
  CallEsc(16,Handle);
  RETURN intout[0] = 1;
END VQTabStatus;

PROCEDURE VHardCopy(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(17,Handle);
END VHardCopy;

PROCEDURE VDspCur(Handle: UNSIGNEDWORD;
                  X     : XY;
                  Y     : XY);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  CallVDIEsc(18,1,0,Handle);
END VDspCur;

PROCEDURE VRmCur(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(19,Handle);
END VRmCur;

PROCEDURE VSPalette(Handle : UNSIGNEDWORD;
                    Palette: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
  intin[0]:= Palette;
  CallVDIEsc(60,0,1,Handle);
  RETURN intout[0];
END VSPalette;

PROCEDURE VSound(Handle   : UNSIGNEDWORD;
                 Frequency: UNSIGNEDWORD;
                 Duration : UNSIGNEDWORD);
BEGIN
  intin[0]:= Frequency;
  intin[1]:= Duration;
  CallVDIEsc(61,0,2,Handle);
END VSound;

PROCEDURE VSMute(Handle: UNSIGNEDWORD;
                 Action: MutingFlags): BOOLEAN;
BEGIN
  intin[0]:= ORD(Action) - 1;
  CallVDIEsc(62,0,1,Handle);
  RETURN intout[0] = 0;
END VSMute;

PROCEDURE VOffset(Handle: UNSIGNEDWORD;
                  Offset: UNSIGNEDWORD);
BEGIN
  intin[0]:= Offset;
  CallVDIEsc(101,0,1,Handle);
END VOffset;

PROCEDURE VFontInit(Handle  : UNSIGNEDWORD;
                    FontHigh: ANYWORD;
                    FontLow : ANYWORD);
BEGIN
  intin[0]:= CAST(Integer,FontHigh);
  intin[1]:= CAST(Integer,FontLow);
  CallVDIEsc(102,0,2,Handle);
END VFontInit;

END VScreen.
