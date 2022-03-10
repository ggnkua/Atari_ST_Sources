MODULE TDynTree;

FROM ApplMgr  IMPORT ApplInit,ApplExit;
FROM FormMgr  IMPORT FormDial,FmDStart,FmDFinish,FormCenter,FormDo;
FROM ObjcMgr  IMPORT ObjcDraw,MaxDepth,ObjcChange;
FROM GrafMgr  IMPORT GrafMouse,Arrow;
FROM ObjcTool IMPORT CreateTree,AddObject,DeleteTree;
FROM WindTool IMPORT BeginUpdate,EndUpdate;

FROM PORTAB   IMPORT SIGNEDWORD;

IMPORT AES,SetObject,GetObject;

CONST OKBUTTON = 1;

VAR MyTree: AES.TreePtr;
    Rect  : AES.GRect;
    Ret   : SIGNEDWORD;
    OKText: AES.String;

BEGIN
  IF ApplInit() >= 0 THEN
    GrafMouse(Arrow,NIL);
    MyTree:= CreateTree(2,10,4);
    IF MyTree # NIL THEN
      AddObject(MyTree,
                AES.Root,OKBUTTON,
                AES.GButton,
                AES.ObjectFlag{AES.Exit,AES.Default,AES.Selectable},
                AES.Normal,
                2,2,6,1);
      OKText:= "  OK  "; OKText[6]:= 0C;
      SetObject.String(MyTree,OKBUTTON,OKText);

      FormCenter(MyTree,Rect);
      BeginUpdate;
      FormDial(FmDStart,Rect,Rect);
      ObjcDraw(MyTree,AES.Root,MaxDepth,Rect);
      Ret:= FormDo(MyTree,0);
      ObjcChange(MyTree,Ret,1,Rect,
                 GetObject.State(MyTree,Ret) - AES.ObjectState{AES.Selected},
                 FALSE);
      FormDial(FmDFinish,Rect,Rect);
      EndUpdate;
      DeleteTree(MyTree);
    END;
    ApplExit;
  END;
END TDynTree.