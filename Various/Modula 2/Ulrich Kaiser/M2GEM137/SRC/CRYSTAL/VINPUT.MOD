IMPLEMENTATION MODULE VInput;

(*
VDI Input Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT contrl,intin,ptsin,intout,ptsout,v,CallVDI,XY,EOS,
                   Integer,Key,SpecialKey,MaxOutput,Point;
FROM PORTAB IMPORT UNSIGNEDWORD,SIGNEDWORD,WORDSET,ANYTYPE,ANYWORD;
FROM SYSTEM IMPORT ADR;
CAST_IMPORT

PROCEDURE VSInMode(Handle : UNSIGNEDWORD;
                   DevType: Devices;
                   Mode   : InputModes);
BEGIN
  intin[0]:= ORD(DevType);
  intin[1]:= ORD(Mode);
  CallVDI(33,0,2,Handle);
END VSInMode;

PROCEDURE VRqLocator(     Handle: UNSIGNEDWORD;
                          X     : XY;
                          Y     : XY;
                      VAR XOut  : XY;
                      VAR YOut  : XY;
                      VAR Term  : Key);
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  CallVDI(28,1,0,Handle);
  XOut:= ptsout[0];
  YOut:= ptsout[1];
  Term:= intout[0];
END VRqLocator;

#if no_set_return
PROCEDURE VSmLocator(    Handle: UNSIGNEDWORD;
                         X     : XY;
                         Y     : XY;
                     VAR XOut  : XY;
                     VAR YOut  : XY;
                     VAR Term  : Key): ANYWORD;
#else
PROCEDURE VSmLocator(    Handle: UNSIGNEDWORD;
                         X     : XY;
                         Y     : XY;
                     VAR XOut  : XY;
                     VAR YOut  : XY;
                     VAR Term  : Key): WORDSET;
#endif
BEGIN
  ptsin[0]:= X;
  ptsin[1]:= Y;
  CallVDI(28,1,0,Handle);
  XOut:= ptsout[0];
  YOut:= ptsout[1];
  Term:= intout[0];
  contrl.c[4]:= contrl.c[4] * 2;
#if no_set_return
  RETURN CAST(ANYWORD,CAST(WORDSET,contrl.c[4]) + CAST(WORDSET,contrl.c[2]));
#else
  RETURN CAST(WORDSET,contrl.c[4]) + CAST(WORDSET,contrl.c[2]);
#endif
END VSmLocator;

PROCEDURE VRqValuator(    Handle     : UNSIGNEDWORD;
                          ValuatorIn : UNSIGNEDWORD;
                      VAR ValuatorOut: UNSIGNEDWORD;
                      VAR Terminator : Key);
BEGIN
  intin[0]:= ValuatorIn;
  CallVDI(29,0,1,Handle);
  ValuatorOut:= intout[0];
  Terminator:= intout[1];
END VRqValuator;

PROCEDURE VSmValuator(    Handle: UNSIGNEDWORD;
                          ValIn : UNSIGNEDWORD;
                      VAR ValOut: UNSIGNEDWORD;
                      VAR Term  : Key;
                      VAR Status: UNSIGNEDWORD);
BEGIN
  intin[0]:= ValIn;
  CallVDI(29,0,1,Handle);
  ValOut:= intout[0];
  Term:= intout[1];
  Status:= contrl.c[4];
END VSmValuator;

PROCEDURE VRqChoice(    Handle: UNSIGNEDWORD;
                        ChIn  : Key;
                    VAR ChOut : Key);
BEGIN
  intin[0]:= ChIn;
  CallVDI(30,0,1,Handle);
  ChOut:= intout[0];
END VRqChoice;

PROCEDURE VSmChoice(    Handle: UNSIGNEDWORD;
                    VAR Choice: Key): BOOLEAN;
BEGIN
  CallVDI(30,0,0,Handle);
  Choice:= intout[0];
  RETURN contrl.c[4] = 1;
END VSmChoice;

PROCEDURE VRqString(    Handle   : UNSIGNEDWORD;
                        MaxLength: SIGNEDWORD;
                        EchoMode : BOOLEAN;
                    VAR PXY      : ARRAY OF XY;
                    VAR Input    : ARRAY OF CHAR);

VAR i: [0..MaxOutput];

BEGIN
  intin[0]:= MaxLength;
  intin[1]:= ORD(EchoMode);
  ptsin[0]:= PXY[0];
  ptsin[1]:= PXY[1];
  CallVDI(31,1,2,Handle);
  i:= 0;
  WHILE i < contrl.c[4] DO
    Input[i]:= CHR(intout[i]);
    INC(i);
  END;
  Input[i]:= EOS;
END VRqString;

PROCEDURE VSmString(    Handle   : UNSIGNEDWORD;
                        MaxLength: SIGNEDWORD;
                        EchoMode : BOOLEAN;
                    VAR PXY      : ARRAY OF XY;
                    VAR Input    : ARRAY OF CHAR): UNSIGNEDWORD;

VAR i: [0..MaxOutput];

BEGIN
  intin[0]:= MaxLength;
  intin[1]:= ORD(EchoMode);
  ptsin[0]:= PXY[0];
  ptsin[1]:= PXY[1];
  CallVDI(31,1,2,Handle);
  i:= 0;
  WHILE i < contrl.c[4] DO
    Input[i]:= CHR(intout[i]);
    INC(i);
  END;
  Input[i]:= EOS;
  RETURN contrl.c[4];
END VSmString;

PROCEDURE VSCForm(    Handle : UNSIGNEDWORD;
                  VAR CurForm: ARRAY OF ANYTYPE);
BEGIN
  v.iioff:= ADR(CurForm);
  CallVDI(111,0,37,Handle);
  v.iioff:= ADR(intin);
END VSCForm;

PROCEDURE VExTimV(    Handle  : UNSIGNEDWORD;
                      Timer   : PROC;
                  VAR OldTimer: PROC;
                  VAR Time    : UNSIGNEDWORD);
BEGIN
  contrl.u.p1:= Timer;
  CallVDI(118,0,0,Handle);
  OldTimer:= contrl.u.p2;
  Time:= intout[0];
END VExTimV;

PROCEDURE VShowC(Handle: UNSIGNEDWORD;
                 Reset : BOOLEAN);
BEGIN
  intin[0]:= ORD(Reset);
  CallVDI(122,0,1,Handle);
END VShowC;

PROCEDURE VHideC(Handle: UNSIGNEDWORD);
BEGIN
  CallVDI(123,0,0,Handle);
END VHideC;

PROCEDURE VQMouse(    Handle: UNSIGNEDWORD;
                  VAR Status: BOOLEAN;
                  VAR X     : XY;
                  VAR Y     : XY);
BEGIN
  CallVDI(124,0,0,Handle);
  Status:= intout[0] = 1;
  X:= ptsout[0];
  Y:= ptsout[1];
END VQMouse;

PROCEDURE VExButV(    Handle  : UNSIGNEDWORD;
                      UsrCode : PROC;
                  VAR SaveCode: PROC);
BEGIN
  contrl.u.p1:= UsrCode;
  CallVDI(125,0,0,Handle);
  SaveCode:= contrl.u.p2;
END VExButV;

PROCEDURE VExMotV(    Handle  : UNSIGNEDWORD;
                      UsrCode : PROC;
                  VAR SaveCode: PROC);
BEGIN
  contrl.u.p1:= UsrCode;
  CallVDI(126,0,0,Handle);
  SaveCode:= contrl.u.p2;
END VExMotV;

PROCEDURE VExCurV(    Handle  : UNSIGNEDWORD;
                      UsrCode : PROC;
                  VAR SaveCode: PROC);
BEGIN
  contrl.u.p1:= UsrCode;
  CallVDI(127,0,0,Handle);
  SaveCode:= contrl.u.p2;
END VExCurV;

PROCEDURE VQKeyS(    Handle: UNSIGNEDWORD;
                 VAR Status: SpecialKey);
BEGIN
  CallVDI(128,0,0,Handle);
  Status:= CAST(SpecialKey,intout[0]);
END VQKeyS;

END VInput.
