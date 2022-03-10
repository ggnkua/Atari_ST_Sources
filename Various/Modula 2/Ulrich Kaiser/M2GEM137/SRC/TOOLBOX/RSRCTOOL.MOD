IMPLEMENTATION MODULE RsrcTool;

(*
Resource Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)
(*DRIVER*)

FROM AES      IMPORT Key,ScanWord,ObjectSpec,ObjectTypes,TreePtr,Root,Nil,
                     MaxObject,ObjectIndex,StringPtr,BitBlkPtr,Flag15,LastOb,
                     Global,Version;
FROM FormMgr  IMPORT FormError,NoFile,NoMemory;
FROM RsrcMgr  IMPORT RTree,RString,RFrStr,RFrImg,
                     TreeIndex,StringIndex,FreeStringIndex,FreeImageIndex,
                     FreeStringPtr,FreeImagePtr,
                     RsrcGAddr,
                     AddRsrcLoad;
FROM ShelMgr  IMPORT ShelFind,ShelRead;
FROM VRaster  IMPORT MFDB,VRTrnFm;
FROM AESTool  IMPORT NewObject;
FROM ObjcTool IMPORT INCLObjectFlags,TreeWalk;
FROM VDITool  IMPORT AESHandle;
FROM PORTAB   IMPORT NULL,ANYPOINTER,SIGNEDWORD,UNSIGNEDWORD;
CAST_IMPORT

IMPORT RsrcMgr,GetObject,SetObject;

PROCEDURE FixMFDB(VAR FDB : MFDB;
                      Addr: ANYPOINTER;
                      WB  : UNSIGNEDWORD;
                      H   : UNSIGNEDWORD);

CONST BitsPerByte = 8;

BEGIN
  WITH FDB DO
    FDAddr:= Addr;
    FDW:= WB * BitsPerByte;
    FDH:= H;
    FDWdWidth:= WB DIV 2;
    FDNPlanes:= 1;
  END;
END FixMFDB;

PROCEDURE Transform(Src  : ANYPOINTER;
                    SrcWB: UNSIGNEDWORD;
                    Dst  : ANYPOINTER;
                    DstWB: UNSIGNEDWORD;
                    H    : UNSIGNEDWORD);

VAR SrcFDB: MFDB;
    DstFDB: MFDB;

BEGIN
  FixMFDB(SrcFDB,Src,SrcWB,H);
  SrcFDB.FDStand:= TRUE;
  FixMFDB(DstFDB,Dst,DstWB,H);
  DstFDB.FDStand:= FALSE;
  VRTrnFm(AESHandle(),SrcFDB,DstFDB);
END Transform;

PROCEDURE TransformBitBlock(Block: BitBlkPtr);
BEGIN
  WITH Block^ DO
    IF BIPData # NULL THEN
      Transform(BIPData,BIWB,BIPData,BIWB,BIHL);
    END;
  END;
END TransformBitBlock;

PROCEDURE TransformObject(Tree: TreePtr; Index: ObjectIndex);

CONST BitsPerByte = 8;
      Transformed = Flag15;

VAR ObSpec: ObjectSpec;
    WB    : UNSIGNEDWORD;

BEGIN
  ObSpec.Address:= GetObject.Spec(Tree,Index);
  IF ObSpec.Address = NULL THEN
    RETURN;
  END;

  CASE GetObject.Type(Tree,Index) OF
    GImage:
      IF NOT(Transformed IN GetObject.Flags(Tree,Index)) THEN
        TransformBitBlock(ObSpec.BitBlk);
        INCLObjectFlags(Tree,Index,Transformed);
      END;

      (* better do this than nothing *)

      SetObject.Height(Tree,Index,ObSpec.BitBlk^.BIHL);

  | GIcon:
      IF NOT(Transformed IN GetObject.Flags(Tree,Index)) THEN
        WITH ObSpec.IconBlk^ DO

          (* transform icon from standard to screen format *)

          WB:= (IBWIcon + 7) DIV BitsPerByte;
          Transform(IBPData,WB,IBPData,WB,IBHIcon);
          Transform(IBPMask,WB,IBPMask,WB,IBHIcon);

          (* correct height *)

          SetObject.Height(Tree,Index,IBHIcon + IBHText);

        END;
        INCLObjectFlags(Tree,Index,Transformed);
      END;
  ELSE
    RETURN;
  END;
END TransformObject;

  PROCEDURE transform(Tree: TreePtr; Index: ObjectIndex): BOOLEAN;
  BEGIN
    TransformObject(Tree,Index);
    RETURN Index < (MaxObject - 1);
  END transform;

PROCEDURE TransformTree(Tree: TreePtr);
BEGIN
  TreeWalk(Tree,Root,Nil,transform);
END TransformTree;

PROCEDURE NumberOfTrees(): TreeIndex;
BEGIN
#if not UNIX
  IF Global.ApPMem # NULL THEN
    RETURN Global.ApPMem^.RsHNTree;
  ELSE
    RETURN 0;
  END;
#else

#endif
END NumberOfTrees;

PROCEDURE TreeArray(T: TreeIndex): TreePtr;
BEGIN
#if not UNIX
  IF Global.ApPTree # NULL THEN
    RETURN Global.ApPTree^[T];
  ELSE
    RETURN NULL;
  END;
#else

#endif
END TreeArray;

CONST ValidChars   = 122;
      TheDesk      = 123;
      TheMenu      = 124;
      RadioButtons = 125;
      FlyingAlerts = 126;
      ScanCodes    = 127;

VAR ScanCodeTree: TreePtr;

PROCEDURE GetScanCodeTree(): TreePtr;

VAR Tree: TreeIndex;

BEGIN
  IF ScanCodeTree = NIL THEN (* is it the first call? *)
    Tree:= NumberOfTrees();
    WHILE Tree > 0 DO
      DEC(Tree);
      IF GetObject.Extnd(TreeArray(Tree),Root) = ScanCodes THEN
        ScanCodeTree:= TreeArray(Tree);
        RETURN ScanCodeTree;
      END;
    END;
  ELSE
    RETURN ScanCodeTree;
  END;
END GetScanCodeTree;

PROCEDURE RsrcLoad(Name: ARRAY OF CHAR): BOOLEAN;

VAR Tree: TreeIndex;

BEGIN
  ScanCodeTree:= NIL;

  Tree:= NumberOfTrees();
  WHILE Tree > 0 DO
    DEC(Tree);
    IF GetObject.Extnd(TreeArray(Tree),Root) = ScanCodes THEN
      ScanCodeTree:= TreeArray(Tree);
      RETURN TRUE;
    END;
  END;
  RETURN TRUE;
END RsrcLoad;

(*
PROCEDURE LookupResource(): BOOLEAN;

TYPE Str128 = ARRAY[0..127] OF CHAR;

BEGIN

  ShelRead(Command,Tail);

  RETURN LoadResource("Command"+".RSC");
END LookupResource;
*)

PROCEDURE GetTreePtr(TreeNo: TreeIndex): TreePtr;

VAR Tree: TreePtr;

BEGIN
  Tree:= NIL;
  IF RsrcGAddr(RTree,TreeNo,Tree) THEN
    TransformTree(Tree);
  END;
  RETURN Tree;
END GetTreePtr;

PROCEDURE GetStringPtr(StringNo: StringIndex): StringPtr;

VAR String: StringPtr;

BEGIN
  IF RsrcGAddr(RString,StringNo,String) THEN
    RETURN String;
  END;
  RETURN NIL;
END GetStringPtr;

PROCEDURE GetFreeStringPtr(FreeStringNo: FreeStringIndex): StringPtr;

VAR FreeString: FreeStringPtr;

BEGIN
  IF RsrcGAddr(RFrStr,FreeStringNo,FreeString) THEN
    RETURN FreeString^;
  END;
  RETURN NIL;
END GetFreeStringPtr;

PROCEDURE GetFreeImagePtr(FreeImageNo: FreeImageIndex): BitBlkPtr;

VAR FreeImage: FreeImagePtr;

BEGIN
  IF RsrcGAddr(RFrImg,FreeImageNo,FreeImage) THEN
    TransformBitBlock(FreeImage^); (* important for PC-GEM *)
    RETURN FreeImage^;
  END;
  RETURN NIL;
END GetFreeImagePtr;

PROCEDURE SpecialChar(Code: Key): CHAR;

VAR ActString: ObjectIndex;
    String   : StringPtr;

  PROCEDURE WordOfString(VAR Str: ARRAY OF CHAR): ScanWord;

  CONST HexChars = "0123456789ABCDEF";

  TYPE HexIndex = [0..16];

  VAR i        : HexIndex;
      j        : [0..3];
      Word     : ScanWord;
      HexString: ARRAY HexIndex OF CHAR;

  BEGIN
    HexString:= HexChars;
    Word:= 0;

    FOR j:= 0 TO 3 DO
      i:= 0;
      WHILE Str[j] # HexString[i] DO
        INC(i);
      END;
      Word:= VAL(ScanWord,i) + 16 * Word;
    END;

    RETURN Word;
  END WordOfString;

BEGIN
  IF ScanCodeTree # NIL THEN
    ActString:= Root; (* GBox *)

    REPEAT
      INC(ActString);
      String:= GetObject.StringPtr(ScanCodeTree,ActString);
#if packing
      IF Code.ScanCode = WordOfString(String^) THEN
#else
      IF Code = WordOfString(String^) THEN
#endif
        RETURN String^[5]; (* format: "0123X" *)
      END;
    UNTIL LastOb IN GetObject.Flags(ScanCodeTree,ActString);

  END;

  RETURN 0C; (* repeat loop without success or ScanCodeTree NOT found *)
END SpecialChar;

BEGIN
  AddRsrcLoad(RsrcLoad);
#if not proc_const
  TransGImage:= TransformObject;
#endif
END RsrcTool.