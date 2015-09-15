
IMPLEMENTATION MODULE DrawProj;

(*****************************************************)
(*                                                   *)
(*      DRAWPROJ version 2.1                         *)
(*      --------------------                         *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements a few procedures, used in  *)
(* main program DRIEDIM (which handles the user      *)
(* interface).                                       *)
(* This main program became too big for              *)
(* the compiler, that's why it was divided into      *)
(* four parts: GLOBALS, DDHELP, DRAWPROJ and DRIEDIM *) 
(*                                                   *)
(*****************************************************)

  FROM GEMVDIbase  IMPORT PxyArrayType;

  FROM VDIControls IMPORT SetClipping;

  FROM VDIOutputs  IMPORT FillRectangle;

  FROM AESMenus    IMPORT MenuBar, MenuTitleNormal;

  FROM GEMAESbase  IMPORT MouseOn, MouseOff, HourGlass, Arrow,
                          FirstXYWH, NextXYWH, FullXYWH, CurrXYWH, WorkXYWH,
                          EndUpdate, BeginUpdate;
                                  
  FROM AESGraphics IMPORT GrafMouse;

  FROM AESWindows  IMPORT WindowGet;

  FROM Objects    IMPORT LineList, PlotProjection;

  FROM MkLines    IMPORT MkProjection;

  FROM Vectors    IMPORT Point;

  FROM DDHelp     IMPORT DrawCross, CheckItem;

  FROM Globals    IMPORT handle, MenuTree, Parts, HLRFLG;

  



PROCEDURE DrawWindow(Proj          : LineList; (* description of projection *)
                     dirtyX,dirtyY,          
                     dirtyW,dirtyH : INTEGER;  (* XYWH of area to redraw    *)
                     Zoom          : REAL;     (* Multiplication factor     *)
                     Window        : INTEGER;  (* Window ID                 *)
                     dx, dy        : INTEGER;  (* translation of picture    *)
                     Cross         : BOOLEAN); (* Crosshair on?             *)
(********************************)
(* Draws window with 3D picture *)
(********************************)
  CONST
    ClippingOff= 0;
    ClippingOn = 1;
 
  VAR
    midx, midy,
    X,Y,W,H,
    x,y,w,h: INTEGER;  
    line: PxyArrayType;


  PROCEDURE Intersect(VAR x1,y1,w1,h1: INTEGER;
                          x2,y2,w2,h2: INTEGER);
  (***********************************************) 
  (* Intersects rectangle 1 against reactangle 2 *)
  (***********************************************) 
    VAR xh1,xh2,yh1,yh2: INTEGER;
  BEGIN
    xh1:= x1+w1;
    xh2:= x2+w2;
    yh1:= y1+h1;
    yh2:= y2+h2;

    IF x2>x1   THEN x1 := x2  END;
    IF y2>y1   THEN y1 := y2  END;
    IF xh2<xh1 THEN xh1:= xh2 END;
    IF yh2<yh1 THEN yh1:= yh2 END;

    w1:= xh1-x1;
    h1:= yh1-y1;

    IF w1<0 THEN w1:= 0 END;
    IF h1<0 THEN h1:= 0 END;
  END Intersect;

BEGIN
 (* Get user area of window *)
 (* and compute origin for  *)
 (* PlotProjection:         *)

  WindowGet(Window, WorkXYWH, X,Y,W,H);
  midx:= X+ ( W DIV 2);
  midy:= Y+ ( H DIV 2);

  (* Hide mouse cursor: *)
  GrafMouse(MouseOff, NIL);

  (* Draw all rectangles in rectangle list of window: *)

  WindowGet(Window, FirstXYWH, x,y,w,h);  (* First rectangle *)

  WHILE (h*w)#0 (* Still another window to be drawn *) DO
    Intersect(x,y,w,h,dirtyX,dirtyY,dirtyW,dirtyH);

    IF (h*w)#0 THEN (* rectangle overlaps dirty area *)
      line[0]:= x;
      line[1]:= y;
      line[2]:= x+w-1;
      line[3]:= y+h-1;

      SetClipping  (handle, ClippingOn, line);
      FillRectangle(handle, line);              (* Clear rectangle *)
      PlotProjection(handle, 
                     midx+dx, midy+dy, 
                     Zoom, Proj);               (* Plot view       *)
      IF Cross THEN DrawCross(X,Y,W,H) END;     (* with cross?     *)
    END;    

    WindowGet(Window, NextXYWH, x,y,w,h);       (* Next rectangle  *)
  END;
   
  SetClipping  (handle, ClippingOff, line);
  GrafMouse (MouseOn,  NIL);
END DrawWindow;




PROCEDURE NewView(Observer, ObPoint: Point;
                  VAR Proj: LineList;
                  VAR HLR : BOOLEAN;
                  ResetFlg: BOOLEAN);
(*********************************************)
(* Deallocate old projection and compute new *)
(* remove hidden lines when HLR is TRUE and  *) 
(* reset HLR when ResetFlg is TRUE           *)
(*********************************************)
  CONST
   (* Menu switches *)
      MenuOn    = 1;
      MenuOff   = 0;    

BEGIN
 (* Turn mouse cursor to hourglass to show that prog is busy: *)
  GrafMouse(HourGlass, NIL);

 (* MkProjection could use menubar as statusline: *)
  IF HLR THEN MenuBar(MenuTree, MenuOff) END;

  MkProjection(Parts, Observer, ObPoint, HLR, Proj);

  IF HLR THEN MenuBar(MenuTree, MenuOn) END;

  IF HLR AND ResetFlg THEN CheckItem(HLRFLG, HLR) END;

 (* Set mouse cursor back to an arrow *)
  GrafMouse(Arrow, NIL);
END NewView;


END DrawProj.


