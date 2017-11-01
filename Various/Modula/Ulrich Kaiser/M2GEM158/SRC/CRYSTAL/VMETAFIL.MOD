IMPLEMENTATION MODULE VMetafile;

(*
VDI Metafile Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT contrl,intin,ptsin,v,CallVDIEsc,XY,Integer,EOS,
                   MaxInput,Point;
FROM PORTAB IMPORT UNSIGNEDWORD;
FROM SYSTEM IMPORT ADR;
CAST_IMPORT

PROCEDURE VMetaExtents(Handle: UNSIGNEDWORD;
                       MinX  : XY;
                       MinY  : XY;
                       MaxX  : XY;
                       MaxY  : XY);
BEGIN
  ptsin[0]:= MinX;
  ptsin[1]:= MinY;
  ptsin[2]:= MaxX;
  ptsin[3]:= MaxY;
  CallVDIEsc(98,2,0,Handle);
END VMetaExtents;

PROCEDURE VWriteMeta(    Handle  : UNSIGNEDWORD;
                         NumIntIn: UNSIGNEDWORD;
                     VAR MyIntIn : ARRAY OF Integer;
                         NumPtsIn: UNSIGNEDWORD;
                     VAR MyPtsIn : ARRAY OF Point);
BEGIN
  WITH v DO
    iioff:= ADR(MyIntIn);
    pioff:= ADR(MyPtsIn);
    CallVDIEsc(99,NumPtsIn,NumIntIn,Handle);
    iioff:= ADR(intin);
    pioff:= ADR(ptsin);
  END;
END VWriteMeta;

PROCEDURE VMPageSize(Handle  : UNSIGNEDWORD;
                     PgWidth : UNSIGNEDWORD;
                     PgHeight: UNSIGNEDWORD);
BEGIN
  intin[0]:= 0;
  intin[1]:= PgWidth;
  intin[2]:= PgHeight;
  CallVDIEsc(99,0,3,Handle);
END VMPageSize;

PROCEDURE VMCoords(Handle: UNSIGNEDWORD;
                   X1    : XY;
                   Y1    : XY;
                   X2    : XY;
                   Y2    : XY);
BEGIN
  intin[0]:= 1;
  intin[1]:= X1;
  intin[2]:= Y1;
  intin[3]:= X2;
  intin[4]:= Y2;
  CallVDIEsc(99,0,5,Handle);
END VMCoords;

PROCEDURE VMFileName(    Handle: UNSIGNEDWORD;
                     VAR Name  : ARRAY OF CHAR);

VAR i: [0..MaxInput];

BEGIN
  IF HIGH(Name) > (MaxInput - 1) THEN
    RETURN; (* too long *)
  END;
  i:= 0;
  LOOP
    IF Name[i] # EOS THEN
      intin[i]:= ORD(Name[i]);
    ELSE
      EXIT;
    END;
    INC(i);
    IF i > HIGH(Name) THEN
      EXIT;
    END;
  END;
  CallVDIEsc(100,0,i,Handle); (* (i + 1) - 1 = i *)
END VMFileName;

END VMetafile.
