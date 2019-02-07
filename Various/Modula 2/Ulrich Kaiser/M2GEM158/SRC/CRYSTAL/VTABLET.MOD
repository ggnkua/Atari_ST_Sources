IMPLEMENTATION MODULE VTablet;

(*
VDI Escape Functions for graphic Tablets.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT intin,ptsin,intout,CallVDI,CallVDIEsc,Integer,MaxInput,
                   XY,Point,CallEsc;
FROM PORTAB IMPORT UNSIGNEDWORD;
CAST_IMPORT

PROCEDURE VTResolution(    Handle: UNSIGNEDWORD;
                           XRes  : UNSIGNEDWORD;
                           YRes  : UNSIGNEDWORD;
                       VAR XSet  : UNSIGNEDWORD;
                       VAR YSet  : UNSIGNEDWORD);
BEGIN
  intin[0]:= XRes;
  intin[1]:= YRes;
  CallVDIEsc(81,0,2,Handle);
  XSet:= intout[0];
  YSet:= intout[1];
END VTResolution;

PROCEDURE VTAxis(    Handle: UNSIGNEDWORD;
                     XRes  : UNSIGNEDWORD;
                     YRes  : UNSIGNEDWORD;
                 VAR XSet  : UNSIGNEDWORD;
                 VAR YSet  : UNSIGNEDWORD);
BEGIN
  intin[0]:= XRes;
  intin[1]:= YRes;
  CallVDIEsc(82,0,2,Handle);
  XSet:= intout[0];
  YSet:= intout[1];
END VTAxis;

PROCEDURE VTOrigin(Handle : UNSIGNEDWORD;
                   XOrigin: UNSIGNEDWORD;
                   YOrigin: UNSIGNEDWORD);
BEGIN
  intin[0]:= XOrigin;
  intin[1]:= YOrigin;
  CallVDIEsc(83,0,2,Handle);
END VTOrigin;

PROCEDURE VQTDimensions(    Handle    : UNSIGNEDWORD;
                        VAR XDimension: UNSIGNEDWORD;
                        VAR YDimension: UNSIGNEDWORD);
BEGIN
  CallEsc(84,Handle);
  XDimension:= intout[0];
  YDimension:= intout[1];
END VQTDimensions;

PROCEDURE VTAlignment(Handle: UNSIGNEDWORD;
                      DX    : UNSIGNEDWORD;
                      DY    : UNSIGNEDWORD);
BEGIN
  intin[0]:= DX;
  intin[1]:= DY;
  CallVDIEsc(85,0,2,Handle);
END VTAlignment;

END VTablet.
