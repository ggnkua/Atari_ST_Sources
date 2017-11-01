IMPLEMENTATION MODULE DeskTool;

(*
Desk Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES      IMPORT Root,TreePtr,ObjectIndex,ObjectSpec,Global,Version;
FROM FormMgr  IMPORT FmDFinish,FormDial;
FROM WindMgr  IMPORT Desk;
FROM RcMgr    IMPORT GRect;
FROM WindTool IMPORT BeginUpdate,EndUpdate;
FROM ObjcTool IMPORT DrawWindowObject;
FROM PORTAB   IMPORT NULL;

IMPORT GetObject,SetObject,WindGet,WindSet;

PROCEDURE OpenDesk(Tree: TreePtr; FirstOb: ObjectIndex);

VAR Rect   : GRect;
    SysTree: TreePtr;
    SysSpec: ObjectSpec;

BEGIN
  SysTree:= WindGet.NewDesk();

  (* reading and writing the systems desktop tree may cause
     memory violations under MTOS if the desktop is not "readable".
     So, do not r/w the desktop under AES 4.x or better check wether
     the memory protection is present. *)
  IF (SysTree # NULL) AND (Version() < 0400H) THEN
    SysSpec.Address:= GetObject.Spec(SysTree,Root);
    SetObject.Spec(Tree,Root,SysSpec);
    SetObject.Type(Tree,Root,GetObject.Type(SysTree,Root));
  ELSE
    (* assumption: desktop has been created with 00001141 *)
    IF Global.ApNPlanes > 1 THEN
      SysSpec.HexCode:= 00001173H;
      SetObject.Spec(Tree,Root,SysSpec);
    END;
  END;

  BeginUpdate;
  WindGet.WorkXYWH(Desk,Rect);
  SetObject.Rect(Tree,Root,Rect);
  WindSet.NewDesk(Tree,FirstOb);
  FormDial(FmDFinish,Rect,Rect);
  EndUpdate;
END OpenDesk;

PROCEDURE CloseDesk;
BEGIN
  IF Global.ApCount = 1 THEN (* because of MultiGEM *)
    WindSet.NewDesk(NULL,0);
  END;
END CloseDesk;

PROCEDURE DrawDeskObject(Desktop: TreePtr; DeskOb: ObjectIndex);
BEGIN
  DrawWindowObject(Desk,Desktop,DeskOb);
END DrawDeskObject;

END DeskTool.
