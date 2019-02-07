IMPLEMENTATION MODULE XGrfMgr;

(*
AES Extended Grafics Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES    IMPORT IntIn,IntOut,crystal;
FROM PORTAB IMPORT UNSIGNEDWORD,SIGNEDWORD;
FROM RcMgr  IMPORT GRect,GPnt;
AES_SYSTEM_IMPORT

#if Seimet
CONST F130 = 082060600H;
      F131 = 083090100H;
#endif

PROCEDURE XGrfStepCalc(    OrgW : UNSIGNEDWORD;
                           OrgH : UNSIGNEDWORD;
                           EndR : GRect;
                       VAR CXY  : GPnt;
                       VAR Cnt  : UNSIGNEDWORD;
                       VAR XStep: SIGNEDWORD;
                       VAR YStep: SIGNEDWORD);
BEGIN
  WITH IntIn DO
    Array[0]:= OrgW;
    Array[1]:= OrgH;
    WITH EndR DO
      Array[2]:= GX;
      Array[3]:= GY;
      Array[4]:= GW;
      Array[5]:= GH;
    END;
  END;
  crystal(130,6,6,0);
  WITH CXY DO
    GX:= IntOut[1];
    GY:= IntOut[2];
  END;
  Cnt:= IntOut[3];
  XStep:= IntOut[4];
  YStep:= IntOut[5];
END XGrfStepCalc;

PROCEDURE XGrf2Box(StartX : SIGNEDWORD;
                   StartY : SIGNEDWORD;
                   StartW : UNSIGNEDWORD;
                   StartH : UNSIGNEDWORD;
                   Corners: BOOLEAN;
                   Cnt    : UNSIGNEDWORD;
                   XStep  : SIGNEDWORD;
                   YStep  : SIGNEDWORD;
                   Doubled: BOOLEAN);
BEGIN
  WITH IntIn DO
    Array[0]:= Cnt;
    Array[1]:= XStep;
    Array[2]:= YStep;
    Array[3]:= ORD(Doubled);
    Array[4]:= ORD(Corners);
    Array[5]:= StartX;
    Array[6]:= StartY;
    Array[7]:= StartW;
    Array[8]:= StartH;
  END;
  crystal(131,9,1,0);
END XGrf2Box;

END XGrfMgr.
