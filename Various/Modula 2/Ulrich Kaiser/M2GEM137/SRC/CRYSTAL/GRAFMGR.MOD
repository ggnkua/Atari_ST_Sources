IMPLEMENTATION MODULE GrafMgr;

(*
AES Graphics Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES     IMPORT IntIn,IntOut,Addr,crystal,Version,Integer;
FROM RcMgr   IMPORT GRect,GPnt;
#if ST
#if ABC
#warning ...taking care of ABC-GEM
FROM XGrfMgr IMPORT XGrfStepCalc,XGrf2Box;
#endif
#else
FROM XGrfMgr IMPORT XGrfStepCalc,XGrf2Box;
#endif
FROM PORTAB  IMPORT UNSIGNEDWORD,SIGNEDWORD;
AES_SYSTEM_IMPORT

#if Seimet
CONST F70 = 046040300H;
      F71 = 047080300H;
      F72 = 048060100H;
      F73 = 049080100H;
      F74 = 04A080100H;
      F75 = 04B040101H;
      F76 = 04C030101H;
      F77 = 04D000500H;
      F78 = 04E010101H;
      F79 = 04F000500H;
#endif

PROCEDURE GrafRubberBox(    StartPos   : GPnt;
                            StartWidth : SIGNEDWORD;
                            StartHeight: SIGNEDWORD;
                        VAR LastWidth  : SIGNEDWORD;
                        VAR LastHeight : SIGNEDWORD);
BEGIN
  WITH IntIn DO
    WITH StartPos DO
      Array[0]:= GX;
      Array[1]:= GY;
    END;
    Array[2]:= StartWidth;
    Array[3]:= StartHeight;
  END;
  crystal(70,4,3,0);
  LastWidth:= IntOut[1];
  LastHeight:= IntOut[2];
END GrafRubberBox;

PROCEDURE GrafDragBox(    StartWidth : SIGNEDWORD;
                          StartHeight: SIGNEDWORD;
                          StartX     : SIGNEDWORD;
                          StartY     : SIGNEDWORD;
                      VAR Bound      : GRect;
                      VAR NewPos     : GPnt);
BEGIN
  WITH IntIn DO
    Array[0]:= StartWidth;
    Array[1]:= StartHeight;
    Array[2]:= StartX;
    Array[3]:= StartY;
    WITH Bound DO
      Array[4]:= GX;
      Array[5]:= GY;
      Array[6]:= GW;
      Array[7]:= GH;
    END;
  END;
  crystal(71,8,3,0);
  WITH NewPos DO
    GX:= IntOut[1];
    GY:= IntOut[2];
  END;
END GrafDragBox;

PROCEDURE GrafMoveBox(StartWidth : UNSIGNEDWORD;
                      StartHeight: UNSIGNEDWORD;
                      StartPos   : GPnt;
                      EndPos     : GPnt);
BEGIN
  WITH IntIn DO
    Array[0]:= StartWidth;
    Array[1]:= StartHeight;
    WITH StartPos DO
      Array[2]:= GX;
      Array[3]:= GY;
    END;
    WITH EndPos DO
      Array[4]:= GX;
      Array[5]:= GY;
    END;
  END;
  crystal(72,6,1,0);
END GrafMoveBox;

PROCEDURE GrafGrowBox(VAR From: GRect;
                      VAR To  : GRect);
#if ST
#if ABC
VAR CXY  : GPnt;
    XY   : GPnt;
    Cnt  : UNSIGNEDWORD;
    XStep: SIGNEDWORD;
    YStep: SIGNEDWORD;
#endif
#else
VAR CXY  : GPnt;
    XY   : GPnt;
    Cnt  : UNSIGNEDWORD;
    XStep: SIGNEDWORD;
    YStep: SIGNEDWORD;
#endif

BEGIN
#if ST
#if ABC
  IF Version() = 0220H THEN (* GEM 2.x *)
    XGrfStepCalc(From.GW,From.GH,To,CXY,Cnt,XStep,YStep);
    XY.GX:= From.GX;
    XY.GY:= From.GY;
    GrafMoveBox(From.GW,From.GH,XY,CXY);
    XGrf2Box(CXY.GX,CXY.GY,From.GW,From.GH,TRUE,Cnt,XStep,YStep,TRUE);
  ELSE
#endif
#else
 IF Version() >= 0220H THEN (* GEM 2.x and GEM 3.x *)
    XGrfStepCalc(From.GW,From.GH,To,CXY,Cnt,XStep,YStep);
    XY.GX:= From.GX;
    XY.GY:= From.GY;
    GrafMoveBox(From.GW,From.GH,XY,CXY);
    XGrf2Box(CXY.GX,CXY.GY,From.GW,From.GH,TRUE,Cnt,XStep,YStep,TRUE);
  ELSE
#endif
    WITH IntIn DO
      WITH From DO
        Array[0]:= GX;
        Array[1]:= GY;
        Array[2]:= GW;
        Array[3]:= GH;
      END;
      WITH To DO
        Array[4]:= GX;
        Array[5]:= GY;
        Array[6]:= GW;
        Array[7]:= GH;
      END;
    END;
    crystal(73,8,1,0);
#if ST
#if ABC
  END;
#endif
#else
  END;
#endif
END GrafGrowBox;

PROCEDURE GrafShrinkBox(VAR From: GRect;
                        VAR To  : GRect);
#if ST
#if ABC
VAR CXY  : GPnt;
    XY   : GPnt;
    Cnt  : UNSIGNEDWORD;
    XStep: SIGNEDWORD;
    YStep: SIGNEDWORD;
#endif
#else
VAR CXY  : GPnt;
    XY   : GPnt;
    Cnt  : UNSIGNEDWORD;
    XStep: SIGNEDWORD;
    YStep: SIGNEDWORD;
#endif

BEGIN
#if ST
#if ABC
  IF Version() = 0220H THEN (* GEM 2.x *)
    XGrfStepCalc(From.GW,From.GH,To,CXY,Cnt,XStep,YStep);
    XGrf2Box(To.GX,To.GY,To.GW,To.GH,TRUE,Cnt,-XStep,-YStep,TRUE);
    XY.GX:= From.GX;
    XY.GY:= From.GY;
    GrafMoveBox(From.GW,From.GH,CXY,XY)
  ELSE
#endif
#else
 IF Version() >= 0220H THEN (* GEM 2.x and GEM 3.x *)
    XGrfStepCalc(From.GW,From.GH,To,CXY,Cnt,XStep,YStep);
    XGrf2Box(To.GX,To.GY,To.GW,To.GH,TRUE,Cnt,-XStep,-YStep,TRUE);
    XY.GX:= From.GX;
    XY.GY:= From.GY;
    GrafMoveBox(From.GW,From.GH,CXY,XY)
  ELSE
#endif
    WITH IntIn DO
      WITH From DO
        Array[0]:= GX;
        Array[1]:= GY;
        Array[2]:= GW;
        Array[3]:= GH;
      END;
      WITH To DO
        Array[4]:= GX;
        Array[5]:= GY;
        Array[6]:= GW;
        Array[7]:= GH;
      END;
    END;
    crystal(74,8,1,0);
#if ST
#if ABC
  END;
#endif
#else
  END;
#endif
END GrafShrinkBox;

PROCEDURE GrafWatchBox(PTree   : TreePtr;
                       Ob      : ObjectIndex;
                       Instate : ObjectState;
                       Outstate: ObjectState): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[1]:= Ob;
    Array[2]:= CAST(Integer,Instate);
    Array[3]:= CAST(Integer,Outstate);
  END;
  Addr[0]:= PTree;
  crystal(75,4,1,1);
  RETURN IntOut[0] = 1;
END GrafWatchBox;

PROCEDURE GrafSlideBox(PTree : TreePtr;
                       Parent: ObjectIndex;
                       Ob    : ObjectIndex;
                       IsVert: SlideModes): UNSIGNEDWORD;
BEGIN
  WITH IntIn DO
    Array[0]:= Parent;
    Array[1]:= Ob;
    Array[2]:= ORD(IsVert);
  END;
  Addr[0]:= PTree;
  crystal(76,3,1,1);
  RETURN IntOut[0];
END GrafSlideBox;

PROCEDURE GrafHandle(VAR WChar: UNSIGNEDWORD;
                     VAR HChar: UNSIGNEDWORD;
                     VAR WBox : UNSIGNEDWORD;
                     VAR HBox : UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
  crystal(77,0,5,0);
  WChar:= IntOut[1];
  HChar:= IntOut[2];
  WBox:= IntOut[3];
  HBox:= IntOut[4];
  RETURN IntOut[0];
END GrafHandle;

PROCEDURE GrafMouse(MouseNum : UNSIGNEDWORD;
                    MouseForm: MFormPtr);
BEGIN
  IntIn.Array[0]:= MouseNum;
  Addr[0]:= MouseForm;
  crystal(78,1,1,1);
END GrafMouse;

PROCEDURE GrafMKState(VAR MXY   : GPnt;
                      VAR MState: MouseButton;
                      VAR KState: SpecialKey);
BEGIN
  crystal(79,0,5,0);
  WITH MXY DO
    GX:= IntOut[1];
    GY:= IntOut[2];
  END;
  MState:= CAST(MouseButton,IntOut[3]);
  KState:= CAST(SpecialKey,IntOut[4]);
END GrafMKState;

#if not (proc_const || ISOM2)
BEGIN
GrafRubBox:= GrafRubberBox;
GrafMBox:= GrafMoveBox;
#endif
END GrafMgr.
