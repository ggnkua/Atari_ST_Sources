IMPLEMENTATION MODULE ObjcTool;

(*
Object Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM ObjcMgr  IMPORT Nil,Root,ObjectStates,ObjcDraw,MaxDepth,ObjcOffset,
                     ObjcChange,ObjcAdd;
FROM RsrcMgr  IMPORT RsrcObFix;
FROM RcMgr    IMPORT GRect,GPnt,RcIntersect;
FROM WindTool IMPORT BeginUpdate,EndUpdate;
FROM pSTORAGE IMPORT ALLOCATE,DEALLOCATE,SIZETYPE;
FROM PORTAB   IMPORT SIGNEDWORD,UNSIGNEDWORD,ANYPOINTER,NULL;
FROM SYSTEM   IMPORT TSIZE;
CAST_IMPORT

IMPORT AES,GetObject,SetObject,WindGet;

PROCEDURE INCLObjectFlags(Tree : AES.TreePtr;
                          Index: AES.ObjectIndex;
                          Flags: AES.ObjectFlags);
BEGIN
#if not UNIX
  INCL(Tree^[Index].ObFlags,Flags);
#else

#endif
END INCLObjectFlags;

PROCEDURE EXCLObjectFlags(Tree : AES.TreePtr;
                          Index: AES.ObjectIndex;
                          Flags: AES.ObjectFlags);
BEGIN
#if not UNIX
  EXCL(Tree^[Index].ObFlags,Flags);
#else

#endif
END EXCLObjectFlags;

PROCEDURE INCLObjectState(Tree : AES.TreePtr;
                          Index: AES.ObjectIndex;
                          State: AES.ObjectStates);
BEGIN
#if not UNIX
  INCL(Tree^[Index].ObState,State);
#else

#endif
END INCLObjectState;

PROCEDURE EXCLObjectState(Tree : AES.TreePtr;
                          Index: AES.ObjectIndex;
                          State: AES.ObjectStates);
BEGIN
#if not UNIX
  EXCL(Tree^[Index].ObState,State);
#else

#endif
END EXCLObjectState;

PROCEDURE ObjectXYWH(    Tree : AES.TreePtr;
                         Index: AES.ObjectIndex;
                     VAR Rect : GRect);
BEGIN
  WITH Rect DO
    ObjcOffset(Tree,Index,GX,GY);
    GW:= GetObject.Width(Tree,Index);
    GH:= GetObject.Height(Tree,Index);
  END;
END ObjectXYWH;

PROCEDURE ObjectRect(    Tree : AES.TreePtr;
                         Index: AES.ObjectIndex;
                     VAR Rect : AES.GRect);
CONST Margin = 3;

BEGIN
  WITH Rect DO
    ObjcOffset(Tree,Index,GX,GY);
    GW:= GetObject.Width(Tree,Index);
    GH:= GetObject.Height(Tree,Index);
    IF AES.Outlined IN GetObject.State(Tree,Index) THEN
      DEC(GX,Margin);
      DEC(GY,Margin);
      INC(GW,2 * Margin);
      INC(GH,2 * Margin);
    END;
  END;
END ObjectRect;

PROCEDURE ToggleObject(Tree : AES.TreePtr;
                       Index: AES.ObjectIndex);

VAR Rect: GRect;

BEGIN
  ObjectXYWH(Tree,Root,Rect);
  ObjcChange(Tree,Index,0,Rect,
             GetObject.State(Tree,Index) / AES.ObjectState{Selected},
             TRUE);
END ToggleObject;

PROCEDURE SelectObject(Tree : AES.TreePtr;
                       Index: AES.ObjectIndex);
BEGIN
  IF NOT (Selected IN GetObject.State(Tree,Index)) THEN
    ToggleObject(Tree,Index);
  END;
END SelectObject;

PROCEDURE DeselectObject(Tree : AES.TreePtr;
                         Index: AES.ObjectIndex);
BEGIN
  IF Selected IN GetObject.State(Tree,Index) THEN
    ToggleObject(Tree,Index);
  END;
END DeselectObject;

PROCEDURE IndirectObject(Tree : AES.TreePtr;
                         Index: AES.ObjectIndex;
                         Parms: ANYPOINTER);

VAR ObExt  : POINTER TO AES.ObjectExtension;
    OldSpec: AES.ObjectSpec;

BEGIN
  OldSpec.Address:= GetObject.Spec(Tree,Index);
#if not UNIX
  ALLOCATE(ObExt,TSIZE(AES.ObjectExtension));
  IF ObExt = NIL THEN
    AES.IntOut[0]:= 0; (* error *)
    RETURN;
  ELSE
    Tree^[Index].ObSpec.UserSpec:= ObExt;
    WITH ObExt^ DO
      Spec:= OldSpec;
      Parm:= Parms;
    END;
    INCLObjectFlags(Tree,Index,AES.Indirect);
  END;
#else

#endif
END IndirectObject;

PROCEDURE DirectObject(Tree : AES.TreePtr;
                       Index: AES.ObjectIndex);

VAR OldSpec: AES.ObjectSpec;

BEGIN
  OldSpec.Address:= GetObject.Spec(Tree,Index);
#if not UNIX
  DEALLOCATE(Tree^[Index].ObSpec.Extension,TSIZE(AES.ObjectExtension));
  Tree^[Index].ObSpec:= OldSpec;
#else

#endif
  EXCLObjectFlags(Tree,Index,AES.Indirect);
END DirectObject;

PROCEDURE DrawWindowObject(Handle: SIGNEDWORD;
                           Tree  : AES.TreePtr;
                           Index : AES.ObjectIndex);

VAR Clip: GRect;
    Rect: GRect;

BEGIN
  BeginUpdate;

  WindGet.FirstXYWH(Handle,Clip);

  WITH Clip DO
    WHILE (GW # 0) AND (GH # 0) DO
      ObjectXYWH(Tree,Index,Rect);
      IF RcIntersect(Rect,Clip) THEN
        ObjcDraw(Tree,Root,MaxDepth,Clip);
      END;
      WindGet.NextXYWH(Handle,Clip);
    END;
  END;

  EndUpdate;
END DrawWindowObject;

PROCEDURE TreeWalk(Tree: AES.TreePtr;
                   This: AES.ObjectPtr;
                   Last: AES.ObjectPtr;
                   Work: WalkProc);

VAR Index: AES.ObjectPtr;

BEGIN
  Index:= This;

  WHILE (This # Last) AND (This # Nil) DO
    IF GetObject.Tail(Tree,This) # Index THEN
      Index:= This;
      This:= Nil;

      IF Work(Tree,Index) THEN
        This:= GetObject.Head(Tree,Index);
      END;

      IF This = Nil THEN
        This:= GetObject.Next(Tree,Index);
      END;
    ELSE
      Index:= This;
      This:= GetObject.Next(Tree,Index);
    END;
  END;
END TreeWalk;

PROCEDURE ParentObject(Tree: AES.TreePtr;
                       Obj : AES.ObjectPtr): AES.ObjectPtr;

VAR Parent: AES.ObjectPtr;

BEGIN
  IF Obj = Nil THEN
    RETURN Nil;
  END;

  Parent:= GetObject.Next(Tree,Obj);
  IF Parent # Nil THEN
    WHILE GetObject.Tail(Tree,Parent) # Obj DO
      Obj:= Parent;
      Parent:= GetObject.Next(Tree,Obj);
    END;
  END;
  RETURN Parent;
END ParentObject;

TYPE CallbackPtr = POINTER TO ObjectCallback;

PROCEDURE NewObjectCallback(Tree: AES.TreePtr;
                            Item: AES.ObjectIndex;
                            Call: ObjectCallback);

VAR Callback: CallbackPtr;

BEGIN
  IF AES.Indirect IN GetObject.Flags(Tree,Item) THEN (* just replace caller *)
#if not UNIX
    Callback:= CAST(CallbackPtr,Tree^[Item].ObSpec.Extension^.Parm);
#else

#endif
    Callback^:= Call;
  ELSE
    ALLOCATE(Callback,TSIZE(ObjectCallback));
    Callback^:= Call;
    IndirectObject(Tree,Item,Callback);
  END;
END NewObjectCallback;

PROCEDURE DisposeObjectCallback(Tree: AES.TreePtr;
                                Item: AES.ObjectIndex);

VAR Callback: CallbackPtr;

BEGIN
#if not UNIX
  Callback:= CAST(CallbackPtr,Tree^[Item].ObSpec.Extension^.Parm);
#else

#endif
  DEALLOCATE(Callback,TSIZE(ObjectCallback));
  DirectObject(Tree,Item);
END DisposeObjectCallback;

PROCEDURE ObjectCall(Tree: AES.TreePtr;
                     Item: AES.ObjectIndex);

VAR Callback: CallbackPtr;

BEGIN
#if not UNIX
  Callback:= Tree^[Item].ObSpec.Extension^.Parm;
#else

#endif
  Callback^(Tree,Item);
END ObjectCall;

PROCEDURE Indirect(Tree: AES.TreePtr;
                   Item: AES.ObjectIndex): BOOLEAN;
BEGIN
#if not UNIX
  RETURN (AES.Indirect IN GetObject.Flags(Tree,Item)) AND
         (Tree^[Item].ObSpec.Extension^.Parm # NULL);
#else
  RETURN AES.Indirect IN GetObject.Flags(Tree,Item);
#endif
END Indirect;

PROCEDURE CreateTree(Amount: AES.ObjectIndex;
                     Width : SIGNEDWORD;
                     Height: SIGNEDWORD): AES.TreePtr;

VAR Tree: AES.TreePtr;

BEGIN
  ALLOCATE(Tree,VAL(SIZETYPE,Amount * TSIZE(AES.Object)));
  IF Tree # NIL THEN
    WITH Tree^[Root] DO
      ObNext:= Nil;
      ObHead:= Nil;
      ObTail:= Nil;
      ObSpec.HexCode:= 000021100H; (* default look *)
      ObFlags:= AES.None;
      ObState:= AES.ObjectState{AES.Outlined};
      ObX:= 0;
      ObY:= 0;
      ObWidth:= Width;
      ObHeight:= Height;
    END;

    SetObject.Type(Tree,Root,AES.GBox);
    RsrcObFix(Tree,Root);
  END;

  RETURN Tree;
END CreateTree;

PROCEDURE AddObject(Tree  : AES.TreePtr;
                    Parent: AES.ObjectPtr;
                    Child : AES.ObjectPtr;
                    Type  : AES.ObjectTypes;
                    Flags : AES.ObjectFlag;
                    State : AES.ObjectState;
                    X     : SIGNEDWORD;
                    Y     : SIGNEDWORD;
                    W     : SIGNEDWORD;
                    H     : SIGNEDWORD);
BEGIN
  WITH Tree^[Child] DO
    ObNext:= Nil;
    ObHead:= Nil;
    ObTail:= Nil;
    SetObject.Type(Tree,Child,Type);
    ObFlags:= Flags;
    ObState:= State;
    ObX:= X;
    ObY:= Y;
    ObWidth:= W;
    ObHeight:= H;

    WITH ObSpec DO
      CASE Type OF
        AES.GText,AES.GBoxText,AES.GFText,AES.GFBoxText:
          NEW(TEdInfo);
          IF TEdInfo # NIL THEN
            WITH TEdInfo^ DO
              ALLOCATE(TEPText,AES.MaxLen);
              ALLOCATE(TEPTmplt,AES.MaxLen);
              ALLOCATE(TEPValid,AES.MaxLen);
            END;
          END;
      | AES.GIcon:
          NEW(IconBlk);
          IF IconBlk # NIL THEN
            WITH IconBlk^ DO
              IBPMask:= NULL;
              IBPData:= NULL;
              IBPText:= NULL;
            END;
          END;
      | AES.GCIcon:
          NEW(CIconBlk);
          IF CIconBlk # NIL THEN
            WITH CIconBlk^ DO
              MainList:= NULL;
            END;
          END;
      | AES.GImage:
          NEW(BitBlk);
          IF BitBlk # NIL THEN
            BitBlk^.BIPData:= NULL;
          END;
      | AES.GButton,AES.GString,AES.GTitle:
          ALLOCATE(String,AES.MaxLen);
      ELSE
        HexCode:= 000000000H;
      END;
    END;
  END;

  RsrcObFix(Tree,Child);
  ObjcAdd(Tree,Parent,Child);
END AddObject;

PROCEDURE DeleteTree(VAR Tree: AES.TreePtr);

VAR Index: AES.ObjectPtr;

BEGIN
(*todo: care for Indirect objects*)

  Index:= Nil;

  REPEAT
    INC(Index);
    WITH Tree^[Index] DO
      WITH ObSpec DO
        CASE GetObject.Type(Tree,Index) OF
          AES.GText,AES.GBoxText,AES.GFText,AES.GFBoxText:
            WITH TEdInfo^ DO
              DEALLOCATE(TEPText,AES.MaxLen);
              DEALLOCATE(TEPTmplt,AES.MaxLen);
              DEALLOCATE(TEPValid,AES.MaxLen);
            END;
            DISPOSE(TEdInfo);
        | AES.GIcon:
            DISPOSE(IconBlk);
        | AES.GCIcon:
            DISPOSE(CIconBlk);
        | AES.GImage:
            DISPOSE(BitBlk);
        | AES.GButton,AES.GString,AES.GTitle:
            DEALLOCATE(String,AES.MaxLen);
        ELSE
          ;
        END;
      END;
    END;
  UNTIL (AES.LastOb IN Tree^[Index].ObFlags);

  DEALLOCATE(Tree,VAL(SIZETYPE,(Index + 1) * TSIZE(AES.Object)));
END DeleteTree;

END ObjcTool.