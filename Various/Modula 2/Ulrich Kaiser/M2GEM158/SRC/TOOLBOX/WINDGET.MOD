IMPLEMENTATION MODULE WindGet;

(*
WindGet - Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES      IMPORT IntIn,IntOut,crystal,Integer,
                     GRect,TreePtr,ObjectIndex,ObjectColors,Version;
FROM WindMgr  IMPORT WindowFunctions,WindowElements,Desk,WFBack;
(*FROM ApplTool IMPORT ApplGetInfo;*)
FROM PORTAB   IMPORT UNSIGNEDWORD,SIGNEDWORD,WORDSET,NULL;
FROM SYSTEM   IMPORT ADR;
AES_SYSTEM_IMPORT

#if ST
#warning ...using GetCookie, CookieVal,
#warning so you need M2POSIX/M2LIB
FROM DosSystem IMPORT GetCookie,CookieVal;
#endif

IMPORT WindMgr;

#if Seimet
CONST F104 = 068030500H;
      F105 = 069060100H;
#endif

PROCEDURE VQMagX(): BOOLEAN;

  CONST MagX = 04D616758H;

  VAR Value: CookieVal;

  BEGIN
    RETURN GetCookie(MagX,Value);
  END VQMagX;

PROCEDURE VQWINX(): BOOLEAN;

BEGIN
  WITH IntIn DO
    Array[0]:= 0;
    Array[1]:= 22360;
  END;
  IntOut[0]:= 0;
  crystal(104,2,5,0);
  RETURN IntOut[0] = 22360;
END VQWINX;

PROCEDURE WorkXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFWorkXYWH);
  END;
  crystal(104,2,5,0);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END WorkXYWH;

PROCEDURE CurrXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFCurrXYWH);
  END;
  crystal(104,2,5,0);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END CurrXYWH;

PROCEDURE PrevXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFPrevXYWH);
  END;
  crystal(104,2,5,0);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END PrevXYWH;

PROCEDURE FullXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFFullXYWH);
  END;
  crystal(104,2,5,0);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END FullXYWH;

PROCEDURE HSlide(Handle: SIGNEDWORD): UNSIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFHSlide);
  END;
  crystal(104,2,5,0);
  RETURN IntOut[1];
END HSlide;

PROCEDURE VSlide(Handle: SIGNEDWORD): UNSIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFVSlide);
  END;
  crystal(104,2,5,0);
  RETURN IntOut[1];
END VSlide;

PROCEDURE Top(): SIGNEDWORD;
BEGIN
  IntIn.Array[1]:= ORD(WFTop);
  crystal(104,2,2,0);
  RETURN IntOut[1];
END Top;

PROCEDURE TopAndBelow(VAR Top  : SIGNEDWORD;
                      VAR Id   : SIGNEDWORD;
                      VAR Below: SIGNEDWORD);
BEGIN
  IntIn.Array[1]:= ORD(WFTop);
  crystal(104,2,5,0);
  Top:= IntOut[1];
  Id:= IntOut[2];
  Below:= IntOut[3];
END TopAndBelow;

PROCEDURE FirstXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFFirstXYWH);
  END;
  crystal(104,2,5,0);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END FirstXYWH;

PROCEDURE NextXYWH(Handle: SIGNEDWORD; VAR Rect: GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFNextXYWH);
  END;
  crystal(104,2,5,0);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END NextXYWH;

(* available under MagX! 2.x, MagiC 3.x, AES 4.x, WINX >= 2.1 *)

PROCEDURE NewDesk(): TreePtr; (* may be POINTER TO Object *)

VAR P   : POINTER TO TreePtr;
    Out1: UNSIGNEDWORD;
    Out2: UNSIGNEDWORD;
    Out3: UNSIGNEDWORD;
    Out4: UNSIGNEDWORD;

BEGIN
  P:= NULL;

(*ApplGetInfo(11,Out1,Out2,Out3,Out4);*) 
  IF (Version() >= 0400H) OR
     VQWINX()             OR
     VQMagX()          (* OR
     (1 IN CAST(WORDSET,Out1))*) THEN
    IntOut[0]:= 0;
    IntOut[1]:= 0;
    IntOut[2]:= 0;
    IntIn.Array[1]:= ORD(WFNewDesk);
    crystal(104,2,3,0);
    P:= ADR(IntOut[1]);
  END;

  IF (P # NULL) AND (IntOut[0] # 0) THEN
    RETURN P^;
  ELSE
    RETURN NULL;
  END;
END NewDesk;

PROCEDURE HSlSize(Handle: SIGNEDWORD): SIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFHSlSize);
  END;
  crystal(104,2,5,0);
#if long
  RETURN LONG(IntOut[1]);
#else
  RETURN IntOut[1];
#endif
END HSlSize;

PROCEDURE VSlSize(Handle: SIGNEDWORD): SIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WFVSlSize);
  END;
  crystal(104,2,5,0);
#if long
  RETURN LONG(IntOut[1]);
#else
  RETURN IntOut[1];
#endif
END VSlSize;

PROCEDURE Color(    Handle: SIGNEDWORD;
                    Obj   : WindowElements;
                VAR Col1  : ObjectColors;
                VAR Col2  : ObjectColors);
BEGIN
  IntIn.Array[0]:= Handle;
  IntIn.Array[1]:= ORD(WindMgr.WFColor);
  IntIn.Array[2]:= ORD(Obj);
  crystal(104,3,3,0);
  Col1:= VAL(ObjectColors,IntOut[1]);
  Col2:= VAL(ObjectColors,IntOut[2]);
END Color;

PROCEDURE DColor(    Handle: SIGNEDWORD;
                     Obj   : WindowElements;
                 VAR Col1  : ObjectColors;
                 VAR Col2  : ObjectColors);
BEGIN
  IntIn.Array[0]:= Handle;
  IntIn.Array[1]:= ORD(WindMgr.WFDColor);
  IntIn.Array[2]:= ORD(Obj);
  crystal(104,3,3,0);
  Col1:= VAL(ObjectColors,IntOut[1]);
  Col2:= VAL(ObjectColors,IntOut[2]);
END DColor;

PROCEDURE Owner(    Handle: SIGNEDWORD;
                VAR Open  : BOOLEAN;
                VAR Above : SIGNEDWORD;
                VAR Below : SIGNEDWORD): SIGNEDWORD;
BEGIN
  IntIn.Array[0]:= Handle;
  IntIn.Array[1]:= ORD(WindMgr.WFOwner);
  crystal(104,2,4,0);
  Open:= IntOut[2] = 1;
  Above:= IntOut[3];
  Below:= IntOut[4];
  RETURN IntOut[1];
END Owner;

PROCEDURE BEvent(Handle: SIGNEDWORD): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[0]:= Handle;
    Array[1]:= ORD(WindMgr.WFBEvent);
    Array[2]:= 0;
    Array[3]:= 0;
    Array[4]:= 0;
    Array[5]:= 0;
  END;
  crystal(104,2,2,0);
  RETURN IntOut[1] = 1;
END BEvent;

PROCEDURE Bottom(): SIGNEDWORD;
BEGIN
  IntIn.Array[1]:= ORD(WindMgr.WFBottom);
  crystal(104,2,2,0);
  RETURN IntOut[1];
END Bottom;

END WindGet.
