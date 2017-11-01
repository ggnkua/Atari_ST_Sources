IMPLEMENTATION MODULE FormMgr;

(*
AES Form Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES     IMPORT IntIn,IntOut,Addr,crystal,Version,Integer;
#if ST
#if ABC
#warning ...taking care of ABC-GEM
FROM GrafMgr IMPORT GrafGrowBox,GrafShrinkBox;
#endif
#else
FROM GrafMgr IMPORT GrafGrowBox,GrafShrinkBox;
#endif
FROM PORTAB  IMPORT SIGNEDWORD,UNSIGNEDWORD,ANYPOINTER;
FROM RcMgr   IMPORT GRect;
AES_SYSTEM_IMPORT

#if Seimet
CONST F50 = 032010101H;
      F51 = 033090100H;
      F52 = 034010101H;
      F53 = 035010100H;
      F54 = 036000501H;
      F55 = 037030301H;
      F56 = 038020201H;
#endif

PROCEDURE formdo(PTree: TreePtr;
                 Start: ObjectIndex): SIGNEDWORD;
BEGIN
  IntIn.Array[0]:= Start;
  Addr[0]:= PTree;
  crystal(50,1,1,1);
  RETURN IntOut[0]; (* double click -> bit #15 *)
END formdo;

PROCEDURE formdial(    Dial: FormDials;
                   VAR From: GRect;
                   VAR To  : GRect);
BEGIN
#if ST
#if ABC
  IF Version() = 0220H THEN (* only GEM 2.x *)
    CASE Dial OF
      FmDGrow:
        GrafGrowBox(From,To);
        RETURN;
    | FmDShrink:
        GrafShrinkBox(From,To);
        RETURN;
    ELSE
      ;
    END;
  END;
#endif
#else
  IF Version() >= 0220H THEN
    CASE Dial OF
      FmDGrow:
        GrafGrowBox(From,To);
        RETURN;
    | FmDShrink:
        GrafShrinkBox(From,To);
        RETURN;
    ELSE
      ;
    END;
  END;
#endif

  WITH IntIn DO
    Array[0]:= ORD(Dial);
    WITH From DO
      Array[1]:= GX;
      Array[2]:= GY;
      Array[3]:= GW;
      Array[4]:= GH;
    END;
    WITH To DO
      Array[5]:= GX;
      Array[6]:= GY;
      Array[7]:= GW;
      Array[8]:= GH;
    END;
  END;
  crystal(51,9,1,0);
END formdial;

PROCEDURE formalert(DefBut  : UNSIGNEDWORD;
                    PAlrtStr: ANYPOINTER): UNSIGNEDWORD;
BEGIN
  IntIn.Array[0]:= DefBut;
  Addr[0]:= PAlrtStr;
  crystal(52,1,1,1);
  RETURN IntOut[0];
END formalert;

PROCEDURE FormError(Error: SIGNEDWORD);
BEGIN
#if ST
  IntIn.Array[0]:= -Error - 31; (* to PC-DOS error code *)
#else
  IntIn.Array[0]:= Error;
#endif
  crystal(53,1,1,0);
END FormError;

PROCEDURE formcenter(    Tree: TreePtr;
                     VAR Rect: GRect);
BEGIN
  Addr[0]:= Tree;
  crystal(54,0,5,1);
  WITH Rect DO
    GX:= IntOut[1];
    GY:= IntOut[2];
    GW:= IntOut[3];
    GH:= IntOut[4];
  END;
END formcenter;

PROCEDURE FormKeybd(    PTree : TreePtr;
                        Ob    : ObjectIndex;
                        NextOb: ObjectPtr;
                        InKey : Key;
                    VAR NewOb : ObjectPtr;
                    VAR OutKey: Key): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[0]:= Ob;
#if packing
    Array[1]:= InKey.ScanCode;
#else
    Array[1]:= InKey;
#endif
    Array[2]:= NextOb;
  END;
  Addr[0]:= PTree;
  crystal(55,3,3,1);
  NewOb:= IntOut[1];
#if packing
  OutKey.ScanCode:= IntOut[2];
#else
  OutKey:= IntOut[2];
#endif
  RETURN IntOut[0] > 0;
END FormKeybd;

PROCEDURE FormButton(    PTree : TreePtr;
                         Ob    : ObjectPtr;
                         Clicks: UNSIGNEDWORD;
                     VAR NextOb: ObjectPtr): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[0]:= Ob;
    Array[1]:= Clicks;
  END;
  Addr[0]:= PTree;
  crystal(56,2,2,1);
  NextOb:= IntOut[1];
  RETURN IntOut[0] > 0;
END FormButton;

BEGIN
  FormDo:= formdo;
  FormDial:= formdial;
  FormAlert:= formalert;
  FormCenter:= formcenter;
END FormMgr.
