IMPLEMENTATION MODULE WindSet;

(*
WindSet - Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES     IMPORT IntIn,IntOut,crystal,Integer,GRect,TreePtr,ObjectIndex,
                    Version;
FROM WindMgr IMPORT WindowFeature,WindowFunctions,Desk,WFBack;
FROM PORTAB  IMPORT UNSIGNEDWORD,SIGNEDWORD;
FROM SYSTEM  IMPORT ADR;
AES_SYSTEM_IMPORT

IMPORT WindMgr;

#if Seimet
CONST F104 = 068020500H;
      F105 = 069060100H;
#endif

PROCEDURE Kind(Handle: SIGNEDWORD; Kind: WindowFeature);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFKind);
    Array[2]:= CAST(Integer,Kind);
  END;
  crystal(105,6,1,0);
END Kind;

PROCEDURE Name(Handle: SIGNEDWORD; VAR Name: ARRAY OF CHAR);
BEGIN
  WITH IntIn DO
    WH:= Handle;
    WF:= ORD(WFName);
    WA:= ADR(Name);
  END;
  crystal(105,6,1,0);
END Name;

PROCEDURE Info(Handle: SIGNEDWORD; VAR Info: ARRAY OF CHAR);
BEGIN
  WITH IntIn DO
    WH:= Handle;
    WF:= ORD(WFInfo);
    WA:= ADR(Info);
  END;
  crystal(105,6,1,0);
END Info;

PROCEDURE CurrXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFCurrXYWH);
    WITH Rect DO
      Array[2]:= GX;
      Array[3]:= GY;
      Array[4]:= GW;
      Array[5]:= GH;
    END;
  END;
  crystal(105,6,1,0);
END CurrXYWH;

PROCEDURE HSlide(Handle: SIGNEDWORD; Pos: UNSIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFHSlide);
    Array[2]:= Pos;
  END;
  crystal(105,6,1,0);
END HSlide;

PROCEDURE VSlide(Handle: SIGNEDWORD; Pos: UNSIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFVSlide);
    Array[2]:= Pos;
  END;
  crystal(105,6,1,0);
END VSlide;

PROCEDURE Top(Handle: SIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFTop);
  END;
  crystal(105,6,1,0);
END Top;

PROCEDURE NewDesk(PTree: TreePtr; Index: ObjectIndex);
BEGIN
  WITH IntIn DO
    WH:= Desk;
    WF:= ORD(WFNewDesk);
    WA:= PTree;
    WO:= Index;
  END;
  crystal(105,6,1,0);
END NewDesk;

PROCEDURE HSlSize(Handle: SIGNEDWORD; Size: SIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFHSlSize);
    Array[2]:= Size;
  END;
  crystal(105,6,1,0);
END HSlSize;

PROCEDURE VSlSize(Handle: SIGNEDWORD; Size: SIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFVSlSize);
    Array[2]:= Size;
  END;
  crystal(105,6,1,0);
END VSlSize;

PROCEDURE TAttrb(Handle: SIGNEDWORD; IsTop: BOOLEAN);
BEGIN
  IF (Version() = 0220H) OR (Version() = 1042H) THEN
    WITH IntIn DO
      Array[0]:= Handle;
      Array[1]:= ORD(WFTAttrb);
      Array[2]:= ORD(IsTop);
    END;
    crystal(105,6,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
END TAttrb;

PROCEDURE SizTop(Handle: SIGNEDWORD; VAR Rect: GRect);

VAR Ver: UNSIGNEDWORD;

BEGIN
  IF (Version() = 0220H) OR (Version() = 1042H) THEN
    WITH IntIn DO
      Array[0]:= Handle;
      Array[1]:= ORD(WFSizTop);
      WITH Rect DO
        Array[2]:= GX;
        Array[3]:= GY;
        Array[4]:= GW;
        Array[5]:= GH;
      END;
    END;
    crystal(105,6,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
END SizTop;

PROCEDURE Back(Handle: SIGNEDWORD);
BEGIN
  IF Version() = 1042H THEN
    WITH IntIn DO
      Array[0]:= Handle;
      Array[1]:= WFBack;
    END;
    crystal(105,6,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
END Back;

PROCEDURE BEvent(Handle: SIGNEDWORD; OnOff: BOOLEAN);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WindMgr.WFBEvent);
    Array[2]:= ORD(OnOff);
    Array[3]:= 0;
    Array[4]:= 0;
    Array[5]:= 0;
  END;
  crystal(105,3,0,0);
END BEvent;

PROCEDURE Bottom(Handle: SIGNEDWORD);
BEGIN
  IntIn.Array[0]:= Handle;
  IntIn.Array[1]:= ORD(WindMgr.WFBottom);
  crystal(105,2,0,0);
END Bottom;

END WindSet.