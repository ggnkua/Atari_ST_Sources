IMPLEMENTATION MODULE ObjcMgr;

(*
AES Object Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES    IMPORT Version,White,IntIn,IntOut,Addr,crystal,Integer;
FROM RcMgr  IMPORT GRect,GPnt;
FROM PORTAB IMPORT SIGNEDWORD,UNSIGNEDWORD;
AES_SYSTEM_IMPORT

#if Seimet
CONST F40 = 028020101H;
      F41 = 029010101H;
      F42 = 02A060101H;
      F43 = 02B040101H;
      F44 = 02C010301H;
      F45 = 02D020101H;
      F46 = 02E040201H;
      F47 = 02F080101H;
      F48 = 030040300H; (* ObjcSysVar() *)
#endif

PROCEDURE ObjcAdd(PTree : TreePtr;
                  Parent: ObjectIndex;
                  Child : ObjectIndex);
BEGIN
  WITH IntIn DO
    Array[0]:= Parent;
    Array[1]:= Child;
  END;
  Addr[0]:= PTree;
  crystal(40,2,1,1);
END ObjcAdd;

PROCEDURE ObjcDelete(PTree: TreePtr;
                     Index: ObjectIndex);
BEGIN
  IntIn.Array[0]:= Index;
  Addr[0]:= PTree;
  crystal(41,1,1,1);
END ObjcDelete;

PROCEDURE objcdraw(    PTree: TreePtr;
                       Start: ObjectIndex;
                       Depth: DrawDepth;
                   VAR Clip : GRect);
BEGIN
  WITH IntIn DO
    Array[0]:= Start;
    Array[1]:= Depth;
    WITH Clip DO
      Array[2]:= GX;
      Array[3]:= GY;
      Array[4]:= GW;
      Array[5]:= GH;
    END;
  END;
  Addr[0]:= PTree;
  crystal(42,6,1,1);
END objcdraw;

PROCEDURE ObjcFind(PTree: TreePtr;
                   Start: ObjectIndex;
                   Depth: DrawDepth;
                   XY   : GPnt): ObjectPtr;
BEGIN
  WITH IntIn DO
    Array[0]:= Start;
    Array[1]:= Depth;
    Array[2]:= XY.GX;
    Array[3]:= XY.GY;
  END;
  Addr[0]:= PTree;
  crystal(43,4,1,1);
  RETURN IntOut[0];
END ObjcFind;

PROCEDURE ObjcOffset(    PTree  : TreePtr;
                         Index  : ObjectIndex;
                     VAR XOffset: SIGNEDWORD;
                     VAR YOffset: SIGNEDWORD);
BEGIN
  IntIn.Array[0]:= Index;
  Addr[0]:= PTree;
  crystal(44,1,3,1);
  XOffset:= IntOut[1];
  YOffset:= IntOut[2];
END ObjcOffset;

PROCEDURE ObjcOrder(PTree : TreePtr;
                    Index : ObjectIndex;
                    NewPos: ObjectPtr);
BEGIN
  WITH IntIn DO
    Array[0]:= Index;
    Array[1]:= NewPos;
  END;
  Addr[0]:= PTree;
  crystal(45,2,1,1);
END ObjcOrder;

PROCEDURE ObjcEdit(    PTree : TreePtr;
                       Index : ObjectIndex;
                       EdChar: Key;
                   VAR EdPos : StringRange;
                       EdKind: EditModes);
BEGIN
  WITH IntIn DO
    Array[0]:= Index;
    Array[1]:= EdChar.ScanCode;
    Array[2]:= EdPos;
    Array[3]:= ORD(EdKind);
  END;
  Addr[0]:= PTree;
  crystal(46,4,2,1);
  EdPos:= IntOut[1];
END ObjcEdit;

PROCEDURE ObjcChange(    PTree   : TreePtr;
                         Index   : ObjectIndex;
                         Depth   : DrawDepth;
                     VAR Clip    : GRect;
                         NewState: ObjectState;
                         Redraw  : BOOLEAN);
BEGIN
  WITH IntIn DO
    Array[0]:= Index;
    Array[1]:= Depth;
    WITH Clip DO
      Array[2]:= GX;
      Array[3]:= GY;
      Array[4]:= GW;
      Array[5]:= GH;
    END;
    Array[6]:= CAST(Integer,NewState);
    Array[7]:= ORD(Redraw);
  END;
  Addr[0]:= PTree;
  crystal(47,8,1,1);
END ObjcChange;

PROCEDURE ObjcSysVar(    Mode   : BOOLEAN;
                         Which  : UNSIGNEDWORD;
                         SetVal1: UNSIGNEDWORD;
                         SetVal2: UNSIGNEDWORD;
                     VAR GetVal1: UNSIGNEDWORD;
                     VAR GetVal2: UNSIGNEDWORD);
BEGIN
#if ST
  IF (Version() >= 0340H) AND
     (Version() < 1042H) AND
     (Version() # 0399H) THEN
    WITH IntIn DO
      Array[0]:= ORD(Mode);
      Array[1]:= Which;
      Array[2]:= SetVal1;
      Array[3]:= SetVal2;
    END;
    crystal(48,4,3,0);
    GetVal1:= IntOut[1];
    GetVal2:= IntOut[2];
  ELSE
#endif
    IF NOT(Mode) THEN
      CASE Which OF
        BackgrCol:
          GetVal1:= ORD(White);
      | ActButCol:
          GetVal1:= ORD(White);
      | IndButCol:
          GetVal1:= ORD(White);
      | Ad3DValue:
          GetVal1:= 0;
          GetVal2:= 0;
      ELSE
        ;
      END;
    END;
#if ST
  END;
#endif
END ObjcSysVar;

BEGIN
  ObjcDraw:= objcdraw;
END ObjcMgr.
