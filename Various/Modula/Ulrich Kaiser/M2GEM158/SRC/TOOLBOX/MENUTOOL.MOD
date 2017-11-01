IMPLEMENTATION MODULE MenuTool;

(*
Menu Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)
(*DRIVER*)

FROM AES      IMPORT Key,SpecialKey,KAlt,KCtrl,KLShift,KRShift,
                     Indirect,LastOb,Selectable,Disabled,
                     GUserDef,GBox,GString,
                     StringPtr,StringRange,
                     Root,Nil,ObjectPtr,ObjectIndex,TreePtr,
                     Global;
FROM ApplMgr  IMPORT ApplWrite;
FROM EvntMgr  IMPORT MessageBlock,MnSelected;
FROM MenuMgr  IMPORT MenuBar,MenuTNormal,MenuIEnable;
FROM WindMgr  IMPORT Desk;
FROM RcMgr    IMPORT RcConstrain,GRect;
FROM ObjcTool IMPORT ObjectXYWH,ParentObject,IndirectObject,
                     NewObjectCallback,DisposeObjectCallback;
(*
FROM EvntTool IMPORT AddKeybdProc;
*)
FROM RsrcTool IMPORT SpecialChar;
FROM WindTool IMPORT BeginUpdate,EndUpdate;
FROM PORTAB   IMPORT NULL,SIGNEDWORD,WORDSET;
FROM pSTORAGE IMPORT ALLOCATE,DEALLOCATE;
FROM SYSTEM   IMPORT TSIZE;
CAST_IMPORT

IMPORT GetObject,SetObject,WindGet;

CONST THEBAR    = 1;
      THEACTIVE = 2;
      THEFIRST  = 3;

PROCEDURE ShowMenu(Menu: TreePtr);

CONST ValidChars   = 122;
      TheDesk      = 123;
      TheMenu      = 124;
      RadioButtons = 125;
      FlyingAlerts = 126;
      ScanCodes    = 127;

VAR Id  : SIGNEDWORD;
    Ob  : ObjectIndex;
    Work: GRect;
    Rect: GRect;
    OldX: SIGNEDWORD;

BEGIN
  MenuTree:= Menu; (* this is always the current menu *)
  IF GetObject.Extnd(Menu,Root) # TheMenu THEN
    SetObject.Extnd(Menu,Root,TheMenu); (* set flag for the first call *)
    WindGet.WorkXYWH(Desk,Work);
    Ob:= 7; (* start with the first drop down menu *)

    REPEAT
      IF GetObject.Type(Menu,Ob) = GBox THEN (* drop down menu? *)
        ObjectXYWH(Menu,Ob,Rect); (* get absolute coordinates *)
        OldX:= Rect.GX; (* store old x position *)
        RcConstrain(Work,Rect); (* constrain drop down menu *)
        IF Rect.GX # OldX THEN (* changed? *)
          SetObject.X(Menu,Ob,GetObject.X(Menu,Ob) + (Rect.GX - OldX) - 1);
        END; (* GEM desktop decreases here by 8 pixels in case of low rez *)
      END;
      INC(Ob);
    UNTIL LastOb IN GetObject.Flags(Menu,Ob);
  END;

  Id:= MenuBar(Menu,1);
END ShowMenu;

PROCEDURE HideMenu(Menu: TreePtr);

VAR Id: SIGNEDWORD;

BEGIN
  MenuTree:= NULL;
  Id:= MenuBar(Menu,0);
END HideMenu;

PROCEDURE EnableMenu(Menu: TreePtr; Enable: BOOLEAN);

VAR Title: ObjectPtr;
    Width: SIGNEDWORD;

BEGIN
  Title:= Menu^[THEFIRST].ObNext;

  Width:= Menu^[THEFIRST].ObWidth;
  REPEAT
    INC(Width,Menu^[Title].ObWidth);
    MenuTNormal(Menu,Title,TRUE); (* may be omitted *)

    (* this is rather undocumented! *)
    MenuIEnable(Menu,
                CAST(ObjectIndex,CAST(WORDSET,Title) + WORDSET{15}),
                Enable);
    (* else
    IF Enable THEN
      EXCL(Menu^[Title].ObState,Disabled);
    ELSE
      INCL(Menu^[Title].ObState,Disabled);
    END;
      perhaps add EXCL/INCL(Menu^[Title].ObFlags,Selectable);
    ShowMenu(Menu);
      perhaps ObjcDraw(Menu,Title,...);
    *)

    Title:= Menu^[Title].ObNext;
  UNTIL Title = THEACTIVE;

  IF Enable THEN
    Menu^[THEACTIVE].ObWidth:= Width;
  ELSE
    Menu^[THEACTIVE].ObWidth:= Menu^[THEFIRST].ObWidth;
  END;
END EnableMenu;

PROCEDURE MenuKey(Menu: TreePtr; EvKey: Key; EvSpecial: SpecialKey): BOOLEAN;

(* format of a menu entry: "  open... ^O" or "  open... ^O " *)

VAR ShortCut   : ARRAY[0..1] OF CHAR;
    MotherTitle: ObjectPtr;
    ChildTitle : ObjectPtr;
    MotherEntry: ObjectPtr;
    ChildEntry : ObjectPtr;
    Msg        : MessageBlock;
    Found      : BOOLEAN;

  PROCEDURE TestEntry(Index: ObjectPtr): BOOLEAN;

  VAR String: StringPtr;
      i     : StringRange;

  BEGIN
    String:= NIL;

    IF GetObject.Type(Menu,Index) = GString THEN
      String:= GetObject.StringPtr(Menu,Index);
    ELSIF GetObject.Type(Menu,Index) = GUserDef THEN
      IF GetObject.Extnd(Menu,Index) = 16 THEN (* Flying Look *)
        IF Indirect IN Menu^[Index].ObFlags THEN
          String:= Menu^[Index].ObSpec.Extension^.Spec.UserBlk^.UBParm^.Parm; (* wouuuh *)
        ELSE
          String:= Menu^[Index].ObSpec.UserBlk^.UBParm^.Parm;
        END;
      END;
    ELSE
      RETURN FALSE;
    END;

    IF String # NIL THEN
      i:= 0;

      WHILE String^[i] # 0C DO (* go to the end of the string *)
        INC(i);
      END;

      DEC(i); (* there was one INC too much *)

      IF String^[i] = " " THEN (* skip over last space if there is any *)
        DEC(i);
      END;

      IF (String^[i] = ShortCut[1]) AND (String^[i - 1] = ShortCut[0]) THEN
        RETURN TRUE;
      END;
    END;
    RETURN FALSE;
  END TestEntry;

BEGIN
  IF Menu = NULL THEN (* ShowMenu() has not yet been called *)
    RETURN FALSE;
  END;

  ShortCut[1]:= SpecialChar(EvKey);

  IF ShortCut[1] # 0C THEN
    IF KAlt IN EvSpecial THEN
      ShortCut[0]:= 7C; (* "0123X" *)
    ELSIF KCtrl IN EvSpecial THEN
      ShortCut[0]:= 136C; (* "0123^X" *)
    ELSIF SpecialKey{KLShift,KRShift} * EvSpecial # SpecialKey{} THEN
      ShortCut[0]:= 1C; (* "0123X" *)
    ELSE
      ShortCut[0]:= " "; (* "0123 X" *)
    END;

    BeginUpdate;
    EndUpdate;   (* for certain reasons *)

    MotherTitle:= GetObject.Head(Menu,GetObject.Head(Menu,Root));
    ChildTitle:= GetObject.Head(Menu,MotherTitle);
    MotherEntry:= GetObject.Head(Menu,GetObject.Tail(Menu,Root));
    ChildEntry:= GetObject.Head(Menu,MotherEntry);

    Found:= FALSE;
    WHILE NOT Found DO
      IF NOT(Disabled IN GetObject.State(Menu,ChildTitle)) THEN
        WHILE NOT Found AND (ChildEntry # MotherEntry) AND (ChildEntry # Nil) DO
          IF NOT(Disabled IN GetObject.State(Menu,ChildEntry)) THEN
            Found:= TestEntry(ChildEntry);
          END;

          IF Found THEN
            WITH Msg DO
              Type  := MnSelected;
              Id    := Global.ApId;
              Length:= 0;
              Title := ChildTitle;
              Item  := ChildEntry;
            END;
            MenuTNormal(Menu,ChildTitle,FALSE);
            ApplWrite(Global.ApId,16,Msg);
          END;

          ChildEntry:= GetObject.Next(Menu,ChildEntry);
        END;
      END;

      ChildTitle:= GetObject.Next(Menu,ChildTitle);
      MotherEntry:= GetObject.Next(Menu,MotherEntry);
      ChildEntry:= GetObject.Head(Menu,MotherEntry);

      IF ChildTitle = MotherTitle THEN
        RETURN FALSE;
      END;
    END;
    RETURN Found;
  ELSE
    RETURN FALSE;
  END;
END MenuKey;

(* procedure for an event handler *)

PROCEDURE DoMenuKey(MyKey: Key; MySpecial: SpecialKey): BOOLEAN;
BEGIN
  IF MenuTree # NULL THEN
    RETURN NOT MenuKey(MenuTree,MyKey,MySpecial);
  ELSE
    RETURN FALSE;
  END;
END DoMenuKey;

TYPE CallbackPtr = POINTER TO MenuCallback;

VAR BugAction: MenuCallback;

PROCEDURE FirstGString(Menu: TreePtr): ObjectIndex;

VAR i: ObjectIndex;

BEGIN
  (* simple, but it should work *)
  i:= 3;
  REPEAT
    INC(i);
  UNTIL GetObject.Type(Menu,i) = GString;
  RETURN i;
END FirstGString;

PROCEDURE NewMenuAction(Menu: TreePtr; Item: ObjectIndex; Call: MenuCallback);

VAR Callback: CallbackPtr;

BEGIN
  (* bypass GEM bug *)

  IF Item = FirstGString(Menu) THEN
    BugAction:= Call;
    RETURN;
  END;

  IF Indirect IN GetObject.Flags(Menu,Item) THEN (* just replace caller *)
#if not UNIX
    Callback:= CAST(CallbackPtr,Menu^[Item].ObSpec.Extension^.Parm);
#else

#endif
    Callback^:= Call;
  ELSE
    ALLOCATE(Callback,TSIZE(MenuCallback));
    IF Callback # NIL THEN
      Callback^:= Call;
      IndirectObject(Menu,Item,Callback);
    END;
  END;
END NewMenuAction;

PROCEDURE MenuAction(Menu: TreePtr; Title: ObjectIndex; Item: ObjectIndex);

VAR Callback: POINTER TO MenuCallback;

BEGIN
  (* bypass GEM bug *)

  IF Item = FirstGString(Menu) THEN
    BugAction(Menu,Title);
    RETURN;
  END;

#if not UNIX
  IF Indirect IN GetObject.Flags(Menu,Item) THEN
    Callback:= Menu^[Item].ObSpec.Extension^.Parm;
  ELSE
    Callback:= NIL;
  END;
#else

#endif
  IF Callback # NIL THEN
    Callback^(Menu,Title);
  END;
END MenuAction;

(*
PROCEDURE MenuTitleOf(Menu: TreePtr; MenuItem: ObjectIndex): ObjectIndex;

VAR ParentBox: ObjectPtr;
    FirstBox : ObjectPtr;
    Diff     : ObjectPtr;

BEGIN
  ParentBox:= ParentObject(Menu,MenuItem);
  FirstBox := GetObject.Head(Menu,GetObject.Tail(Menu,Root));

  Diff:= 0;
  WHILE FirstBox # ParentBox DO
    INC(Diff);
    FirstBox:= GetObject.Next(Menu,FirstBox);
  END;

  RETURN GetObject.Head(Menu,
                        GetObject.Head(Menu,
                                       GetObject.Head(Menu,Root))) + Diff;
END MenuTitleOf;
*)

BEGIN
  MenuTree:= NULL;
(*
  AddKeybdProc(DoMenuKey);
*)
#if not ISO_proc_const
(*NewMenuAction:= NewObjectCallback;*)
  DisposeMenuAction:= DisposeObjectCallback;
#endif
END MenuTool.
