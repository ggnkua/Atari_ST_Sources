IMPLEMENTATION MODULE WindMgr;

(*
AES Window Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES    IMPORT IntIn,IntOut,Global,crystal,Version,Integer;
FROM RcMgr  IMPORT GRect,GPnt;
FROM PORTAB IMPORT SIGNEDWORD,UNSIGNEDWORD;
FROM SYSTEM IMPORT ADR;
AES_SYSTEM_IMPORT

#if Seimet
CONST F100 = 064050100H;
      F101 = 065050100H;
      F102 = 066010100H;
      F103 = 067010100H;
      F104 = 068030500H;
      F105 = 069060100H;
      F106 = 06A020100H;
      F107 = 06B010100H;
      F108 = 06C060500H;
      F109 = 06D000000H;

      F119 = 077000100H;
#endif

#if ST
VAR DummyC: CHAR;
#endif

PROCEDURE WindCreate(    Kind   : WindowFeature;
                     VAR MaxRect: GRect): SIGNEDWORD;

VAR Window: SIGNEDWORD;

BEGIN
  WITH IntIn DO
#if ST
    IF Move IN Kind THEN
      INCL(Kind,Name);
    END;
#endif
    Array[0]:= CAST(Integer,Kind);
    WITH MaxRect DO
      Array[1]:= GX;
      Array[2]:= GY;
      Array[3]:= GW;
      Array[4]:= GH;
    END;
  END;
  crystal(100,5,1,0);
#if ST
  (* bypass mover bug *)
  Window:= IntOut[0];
  IF (Window # NoWindow) AND (Move IN Kind) THEN
    WITH IntIn DO
      WH:= Window;
      WF:= ORD(WFName);
      DummyC:= 0C;
      WA:= ADR(DummyC);
    END;
    crystal(105,6,1,0);
  END;
  RETURN Window;
#else
  RETURN IntOut[0];
#endif
END WindCreate;

PROCEDURE WindOpen(    Handle   : SIGNEDWORD;
                   VAR StartRect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    WITH StartRect DO
      Array[1]:= GX;
      Array[2]:= GY;
      Array[3]:= GW;
      Array[4]:= GH;
    END;
  END;
  crystal(101,5,1,0);
END WindOpen;

PROCEDURE WindClose(Handle: SIGNEDWORD);
BEGIN
  IntIn.Array[0]:= Handle;
  crystal(102,1,1,0);
END WindClose;

PROCEDURE WindDelete(VAR Handle: SIGNEDWORD);
BEGIN
  IntIn.Array[0]:= Handle;
  crystal(103,1,1,0);
  Handle:= NoWindow;
END WindDelete;

PROCEDURE WindGet(    Handle: SIGNEDWORD;
                      Field : WindowFunctions;
                  VAR Word1 : SIGNEDWORD;
                  VAR Word2 : SIGNEDWORD;
                  VAR Word3 : SIGNEDWORD;
                  VAR Word4 : SIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(Field);
    Array[2]:= Word1;
  END;
  crystal(104,2,5,0);
  Word1:= IntOut[1];
  Word2:= IntOut[2];
  Word3:= IntOut[3];
  Word4:= IntOut[4];
END WindGet;

PROCEDURE WindSet(Handle: SIGNEDWORD;
                  Field : WindowFunctions;
                  Word1 : SIGNEDWORD;
                  Word2 : SIGNEDWORD;
                  Word3 : SIGNEDWORD;
                  Word4 : SIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(Field);
    Array[2]:= Word1;
    Array[3]:= Word2;
    Array[4]:= Word3;
    Array[5]:= Word4;
  END;
  crystal(105,6,1,0);
END WindSet;

PROCEDURE WindFind(XY: GPnt): SIGNEDWORD;
BEGIN
  WITH IntIn DO
    WITH XY DO
      Array[0]:= GX;
      Array[1]:= GY;
    END;
  END;
  crystal(106,2,1,0);
  RETURN IntOut[0];
END WindFind;

PROCEDURE WindUpdate(BegUp: UNSIGNEDWORD): BOOLEAN;
BEGIN
  IntIn.Array[0]:= BegUp;
  crystal(107,1,1,0);
  RETURN IntOut[0] # 0;
END WindUpdate;

PROCEDURE WindCalc(    Type : CalcModes;
                       Kind : WindowFeature;
                   VAR Rect1: GRect;
                   VAR Rect2: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= ORD(Type);
    Array[1]:= CAST(Integer,Kind);
    WITH Rect1 DO
      Array[2]:= GX;
      Array[3]:= GY;
      Array[4]:= GW;
      Array[5]:= GH;
    END;
  END;
  crystal(108,6,5,0);
  WITH Rect2 DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END WindCalc;

PROCEDURE WindNew;
BEGIN
#if ST
  IF (Version() > 0140H) AND (Version() # 0220H) THEN
    crystal(109,0,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
#else
  IntOut[0]:= 0; (* error *)
#endif
END WindNew;

PROCEDURE WindApFind(MXY: GPnt): SIGNEDWORD;
BEGIN
#if ST
  IF Global.ApCount > 1 THEN
    crystal(119,0,1,0);
    RETURN IntOut[0];
  END;
#else
  RETURN 0;
#endif
END WindApFind;

END WindMgr.
