MODULE Dust;

FROM SYSTEM IMPORT ADR, ADDRESS ;

FROM GEMAESbase   IMPORT FormStart, FormGrow, FormShrink, FormFinish,
                         AESCallResult, 
                         MenuSelected,
                         RTree ,
                         Arrow ;
FROM AESApplications IMPORT ApplInitialise ;
FROM AESMenus IMPORT MenuBar, MenuItemCheck, MenuItemEnable,
                     MenuTitleNormal, MenuText, MenuRegister ;
FROM AESForms IMPORT FormDo, FormDialogue, FormAlert, FormError,
                     FormCenter ;
FROM AESResources IMPORT ResourceLoad, ResourceFree, ResourceGetAddr,
                         ResourceSetAddr, ResourceObjectFix ;
FROM AESObjects   IMPORT ObjectDraw ;
FROM AESEvents    IMPORT EventMessage ;
FROM AESGraphics  IMPORT GrafMouse ;

CONST
      MENU = 0;         (* TREE *)
      ABOUT = 1;        (* TREE *)
      MORE = 2;         (* TREE *)
      MAKETEA = 4;      (* TREE *)
      DRINKTEA = 3;     (* TREE *)
      DROPTEA = 5;      (* TREE *)
      DRINKCOF = 6;     (* TREE *)
      GOON = 7;         (* TREE *)
      ABMORE = 5;       (* OBJECT in TREE #1 *)
      ABLESS = 6;       (* OBJECT in TREE #1 *)
      MOREOK = 2;       (* OBJECT in TREE #2 *)
      MORENTOK = 3;     (* OBJECT in TREE #2 *)
      DTAGAIN = 1;      (* OBJECT in TREE #3 *)
      DTFORGET = 2;     (* OBJECT in TREE #3 *)
      DTDRINKC = 7;     (* OBJECT in TREE #3 *)
      MTAGREE = 1;      (* OBJECT in TREE #4 *)
      DROPTSHA = 2;     (* OBJECT in TREE #5 *)
      DCANGRY = 3;      (* OBJECT in TREE #6 *)
      DCSMASH = 4;      (* OBJECT in TREE #6 *)
      DCACCEPT = 5;     (* OBJECT in TREE #6 *)
      BEANGRY = 8;      (* TREE *)
      SMASHCOM = 9;     (* TREE *)
      ANGRYAGR = 4;     (* OBJECT in TREE #8 *)
      SMASHNOT = 4;     (* OBJECT in TREE #9 *)
      DESKMENU = 3;     (* OBJECT in TREE #0 *)
      QUITMENU = 4;     (* OBJECT in TREE #0 *)
      TEAMENU = 5;      (* OBJECT in TREE #0 *)
      OPTMENU = 6;      (* OBJECT in TREE #0 *)
      GLOBMENU = 7;     (* OBJECT in TREE #0 *)
      MABOUT = 10;      (* OBJECT in TREE #0 *)
      MGOON = 20;       (* OBJECT in TREE #0 *)
      MQUIT = 19;       (* OBJECT in TREE #0 *)
      MMTEA = 22;       (* OBJECT in TREE #0 *)
      MDTEA = 23;       (* OBJECT in TREE #0 *)
      MDRTEA = 24;      (* OBJECT in TREE #0 *)
      GOONOK = 5;       (* OBJECT in TREE #7 *)
      GOONNTOK = 6;     (* OBJECT in TREE #7 *)


VAR 
  VDIHandle : INTEGER ;
  WidthChar, HeightChar, WidthFont, HeightFont : INTEGER ;

  (* Window data *)
  Window : INTEGER ;            (* window handle *)
  WindX, WindY, WindWidth, WindHeight : INTEGER ; (* Total window *)

  Appl : INTEGER ;
  MenuTree : ADDRESS;

(* ------------------------------------------------------------------- *)

PROCEDURE DoDialog(which:INTEGER):INTEGER ;

TYPE
  Object = RECORD
             next  : CARDINAL;
             head  : CARDINAL;
             tail  : CARDINAL;
             type  : CARDINAL;
             flags : CARDINAL;
             state : CARDINAL;
             spec  : ADDRESS;
             obx   : CARDINAL;
             oby   : CARDINAL;
             width : CARDINAL;
             depth : CARDINAL;
           END;
  Tree = POINTER TO ARRAY [0..200] OF Object;
VAR
  dTree : ADDRESS ;
  x, y, w, h : INTEGER ;
  result : INTEGER ;

  PROCEDURE ObjectAddress(tree : INTEGER; obindex : INTEGER) : ADDRESS;
  VAR res : INTEGER; treeadr : Tree; ob : POINTER TO ADDRESS;
  BEGIN
    ResourceGetAddr(0,tree,treeadr);
    RETURN ADR(treeadr^[obindex]);
  END ObjectAddress;

  PROCEDURE GetObjectState(tree : INTEGER; obindex : INTEGER) : BITSET;
  VAR res : INTEGER; treeadr : Tree;
  BEGIN
    ResourceGetAddr(0,tree,treeadr);
    RETURN BITSET(treeadr^[obindex].state);
  END GetObjectState;

  PROCEDURE SetObjectState(tree : INTEGER; obindex : INTEGER; state : BITSET);
  VAR res : INTEGER; treeadr : Tree;
  BEGIN
    ResourceGetAddr(0,tree,treeadr);
    treeadr^[obindex].state := INTEGER(state);
  END SetObjectState;


  PROCEDURE DeselectObject(tree : INTEGER; obindex : INTEGER);
  CONST
    Selected = 0 ;
  VAR b : BITSET;
  BEGIN
    b := GetObjectState(tree,obindex);
    b := b - {Selected};
    SetObjectState(tree,obindex,b);
  END DeselectObject;

BEGIN
  ResourceGetAddr(RTree,which,dTree) ;
  FormCenter(dTree,x,y,w,h) ;
  FormDialogue(FormStart,0,0,0,0,x,y,w,h) ;
  FormDialogue(FormGrow,0,0,0,0,x,y,w,h) ;
  ObjectDraw(dTree,0,10,x,y,w,h) ;
  result := FormDo(dTree,0) ;
  DeselectObject(which,result) ;
  FormDialogue(FormShrink,0,0,0,0,x,y,w,h) ;
  FormDialogue(FormFinish,0,0,0,0,x,y,w,h) ;
  RETURN result ;
END DoDialog ;

  
(* ------------------------------------------------------------------- *)

PROCEDURE Events ;
(* Handle resource events *)
VAR
  result : INTEGER ;
  done : BOOLEAN ;
  pipeBuff : ARRAY [0..9] OF INTEGER ;

  PROCEDURE SelectMenu( Menu, Item : INTEGER ) ;
  VAR dummy:INTEGER;
  BEGIN
    CASE Menu OF
      DESKMENU : CASE Item OF
                   MABOUT : IF DoDialog(ABOUT) = ABMORE THEN
                                                  dummy:=DoDialog(MORE)
                                                 END
                 END ; |
      QUITMENU : CASE Item OF
                   MGOON  : IF DoDialog(GOON) = GOONOK THEN done:=TRUE END |
                   MQUIT  : done:=TRUE |
                 END ; |
      TEAMENU  : CASE Item OF
                   MMTEA  : dummy:=DoDialog(MAKETEA) |
                   MDTEA  : REPEAT
                              dummy:=DoDialog(DRINKTEA)
                            UNTIL dummy#DTAGAIN;
                            IF dummy=DTDRINKC THEN
                              CASE DoDialog(DRINKCOF) OF
                                DCANGRY : dummy:=DoDialog(BEANGRY)  |
                                DCSMASH : dummy:=DoDialog(SMASHCOM) |
                                DCACCEPT: |
                              END
                            END |
                   MDRTEA : dummy:=DoDialog(DROPTEA) |
                 END ; |
      OPTMENU  :
                  |
      GLOBMENU :
                  |
    ELSE
    END ;
    (* put header back normal*)
    MenuTitleNormal(MenuTree,Menu,1) ;
  END SelectMenu ;

BEGIN
  GrafMouse(Arrow,NIL) ; (* put pointing mouse *)
  done := FALSE ;
  REPEAT
    EventMessage(ADR(pipeBuff)) ;
    CASE pipeBuff[0] OF         (* message type *)
      MenuSelected   : SelectMenu(pipeBuff[3],pipeBuff[4]) ; |
    ELSE
    END ;
  UNTIL done ;
END Events ;


(* ------------------------------------------------------------------- *)

PROCEDURE InitResource() : BOOLEAN ;
CONST
  ResourceFileName = "dumgem.rsc" ;
  Alert = "[3][ No resource file for DUMGEM ][OK]" ;

VAR
  str : ARRAY [0..99] OF CHAR ;
  result : INTEGER ;

BEGIN
  Appl := ApplInitialise() ;
  str := ResourceFileName ;
  ResourceLoad(str) ;
  IF ( AESCallResult = 0 ) THEN
    str := Alert ;
    result := FormAlert(1,str) ;
    RETURN FALSE ;
  END ;
  (* enable the menu tree *)
  ResourceGetAddr(RTree,MENU,MenuTree) ;
  MenuBar(MenuTree,1) ;
  RETURN TRUE ;
END InitResource ;

(* ------------------------------------------------------------------- *)

PROCEDURE Terminate ;
BEGIN
  MenuBar(MenuTree,0) ;
  ResourceFree() ;
END Terminate ;
(* ------------------------------------------------------------------- *)

VAR
  ch : CHAR ;

BEGIN
  IF InitResource() THEN
    Events ;
  END ;
END Dust.
