IMPLEMENTATION MODULE VPalette;

(*
VDI Palette Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM VDI    IMPORT contrl,intin,intout,CallVDIEsc,Integer,CallEsc;
FROM PORTAB IMPORT UNSIGNEDWORD,SIGNEDWORD;
CAST_IMPORT

PROCEDURE VSPFilm(Handle   : UNSIGNEDWORD;
                  Index    : UNSIGNEDWORD;
                  Lightness: SIGNEDWORD);
BEGIN
  intin[0]:= Index;
  intin[1]:= Lightness;
  CallVDIEsc(91,0,2,Handle);
END VSPFilm;

PROCEDURE VQPFilmName(    Handle: UNSIGNEDWORD;
                          Index : UNSIGNEDWORD;
                      VAR Name  : ARRAY OF CHAR): BOOLEAN;
VAR i: [0..24];

BEGIN
  intin[0]:= Index;
  CallVDIEsc(92,0,1,Handle);
  FOR i:= 0 TO (contrl.c[4] - 1) DO
    Name[i]:= CHR(intout[i]);
  END;
  RETURN contrl.c[4] # 0;
END VQPFilmName;

PROCEDURE VSCExpose(Handle: UNSIGNEDWORD;
                    State : BOOLEAN);
BEGIN
  intin[0]:= ORD(State);
  CallVDIEsc(93,0,1,Handle);
END VSCExpose;

PROCEDURE VQPFilms(    Handle: UNSIGNEDWORD;
                   VAR Names : FilmNames);

VAR i: [0..124];
    s: [0..4];
    c: [0..24];

BEGIN
  CallEsc(91,Handle);
  i:= 0;
  FOR s:= 0 TO 4 DO
    FOR c:= 0 TO 24 DO
      Names[s,c]:= CHR(intout[i]);
      INC(i);
    END;
  END;
END VQPFilms;

PROCEDURE VQPState(    Handle   : UNSIGNEDWORD;
                   VAR Port     : UNSIGNEDWORD;
                   VAR Index    : UNSIGNEDWORD;
                   VAR Lightness: SIGNEDWORD;
                   VAR Interlace: BOOLEAN;
                   VAR Planes   : UNSIGNEDWORD;
                   VAR Indices  : FilmIndex);

VAR i: [0..20];
    j: [0..7];
    k: [0..1];

BEGIN
  CallEsc(92,Handle);
  Port:= intout[0];
  Index:= intout[1];
#if long
  Lightness:= LONG(intout[2]);
#else
  Lightness:= intout[2];
#endif
  Interlace:= intout[3] = 1;
  Planes:= intout[4];

  i:= 5;
  FOR j:= 0 TO 7 DO
    FOR k:= 0 TO 1 DO
      Indices[j,k]:= intout[i];
      INC(i);
    END;
  END;
END VQPState;

PROCEDURE VSPState(    Handle   : UNSIGNEDWORD;
                       Port     : UNSIGNEDWORD;
                       Index    : UNSIGNEDWORD;
                       Lightness: SIGNEDWORD;
                       Interlace: BOOLEAN;
                       Planes   : UNSIGNEDWORD;
                   VAR Indices  : FilmIndex) ;

VAR i: [0..20];
    j: [0..7];
    k: [0..1];

BEGIN
  intin[0]:= CAST(Integer,Port);
  intin[1]:= CAST(Integer,Index);
  intin[2]:= CAST(Integer,Lightness);
  intin[3]:= ORD(Interlace);
  intin[4]:= CAST(Integer,Planes);

  i:= 5;
  FOR j:= 0 TO 7 DO
    FOR k:= 0 TO 1 DO
      intin[i]:= ORD(Indices[j,k]);
      INC(i);
    END;
  END;
  CallVDIEsc(93,0,21,Handle);
END VSPState;

PROCEDURE VSPSave(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(94,Handle);
END VSPSave;

PROCEDURE VSPMessage(Handle: UNSIGNEDWORD);
BEGIN
  CallEsc(95,Handle);
END VSPMessage;

PROCEDURE VQPError(Handle: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
  CallEsc(96,Handle);
  RETURN CAST(UNSIGNEDWORD,intout[0]);
END VQPError;

END VPalette.
