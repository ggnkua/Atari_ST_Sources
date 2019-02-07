
IMPLEMENTATION MODULE DDHelp;

(*****************************************************)
(*                                                   *)
(*      DDHELP version 2.1                           *)
(*      ------------------                           *)
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

  FROM AESMenus        IMPORT MenuText, MenuItemCheck;
 
  FROM AESForms        IMPORT FormDo, FormCenter, FormDialogue;

  FROM AESObjects      IMPORT ObjectDraw;

  FROM SYSTEM      IMPORT ADR; 

  FROM VDIOutputs  IMPORT PolyLine;

  FROM GEMVDIbase  IMPORT PxyArrayType;

  FROM GEMAESbase  IMPORT MouseOn, MouseOff, Arrow,
                          FormStart, FormGrow, FormShrink, FormFinish,
                          CurrXYWH, FullXYWH, Selected;


  FROM AESGraphics IMPORT GrafMouse, GrafGrowBox, GrafShrinkBox;

  FROM AESWindows  IMPORT WindowOpen, WindowGet, WindowSet,
                          WindowClose, WindowUpdate;

  FROM M2Conversions IMPORT ConvertToReal, ConvertReal;

  FROM Vectors     IMPORT Point, EqPoint;

  FROM Globals     IMPORT MenuTree, FormTree, Window1, Window2,
                          HMenuBar, WDesk, HDesk, handle,
                          ObArray, Strng, ShowAlert,

                          MENU, FORM, ZEROVIEW, ZEROZOOM, ABOUTDD, QUITDD,
                          VIEWPIC, OBSX, OBSY, OBSZ, LOOKX, LOOKY, LOOKZ,
                          ZOOM, DTRANS, FORMOK, FORMCAN, UNKNFILE, SYNTXERR,
                          NOMEMORY, ABOUT, SETPARMS, RESETFLG, HLRFLG, FULLVIEW,
                          CROSSFLG, PRINTSCR;




PROCEDURE scale(slided, max: INTEGER): INTEGER;
(* Desperately looking for MODULA-3, with *)
(* automatic type transfer between        *)
(* different numeric types                *)
  VAR 
    cheat: RECORD
             CASE BOOLEAN OF
               TRUE : i1,i2,i3,i4: INTEGER|
               FALSE: l1,l2      : LONGCARD (* compiler bombs on      *)
             END                            (* LONGINT multiplication *)
           END;
BEGIN
  WITH cheat DO
    i1:= 0; i2:= slided;
    i3:= 0; i4:= max;

    l1:= (l1*l2) DIV 1000;
    RETURN i2 - (max DIV 2)
  END;
END scale;


PROCEDURE member(el, set: INTEGER): BOOLEAN;
(*****************************************************)
(* Why don't those GEM interfaces use proper sets??? *)
(*****************************************************)
BEGIN
  RETURN (set MOD (2*el))  > (el-1)
END member;



PROCEDURE SetMenuText(item: INTEGER; VAR str: ARRAY OF CHAR);
(* Put text for menu item *)
BEGIN
  MenuText(MenuTree, item, ADR(str) ); 
END SetMenuText;


PROCEDURE CheckItem(item: INTEGER; VAR b: BOOLEAN);
  CONST
    Check  = 1;
    NoCheck= 0;
BEGIN
  b:= NOT b;

  IF b THEN MenuItemCheck(MenuTree,item,Check)
  ELSE  MenuItemCheck(MenuTree,item,NoCheck) END;
END CheckItem;


PROCEDURE SwitchFullView(VAR fullview: BOOLEAN);
(*******************************************)
(* Procedure that switches windows 1 and 2 *)
(* Note how menu text is changed.          *)
(*******************************************)

  CONST
   (* Menu texts for 'full view': *)
    FVText1= "  Full view  ";
    FVText2= "  Normal view";

  VAR
   (* Sizes for window1 and window2: *)
    x1,y1,w1,h1,
    x2,y2,w2,h2: INTEGER;

BEGIN
  WindowGet(Window1, CurrXYWH, x1,y1,w1,h1);
  WindowGet(Window2, FullXYWH, x2,y2,w2,h2);
  IF fullview THEN (* Shrink box from w2 to w1, and close w2 *)
      SetMenuText( FULLVIEW, FVText1 ); 
      GrafShrinkBox( x1,y1,w1,h1, x2,y2,w2,h2);
      WindowClose ( Window2 );
    ELSE           (* Grow box from w1 to w2's size, and open w2 *)
      SetMenuText( FULLVIEW, FVText2 ); 
      GrafMouse(MouseOff, NIL);
      GrafGrowBox( x1,y1,w1,h1, x2,y2,w2,h2);
      WindowOpen(Window2, 0, HMenuBar, WDesk, HDesk);
      GrafMouse(MouseOn, NIL);
  END;

  fullview:= NOT fullview;
END SwitchFullView;




PROCEDURE FillForm( (* data to be filled in *)
                    VAR Observer, ObPoint: Point;
                    VAR Zoom, TransStep  : REAL): FillFormResult;
(******************************************************)
(* Let user input data into FORM until correct data   *)
(* See also more general (and clearer) procedure      *)
(* DoDial (furtheron)                                 *)
(******************************************************)
  VAR begtext,               (* Index of editable text to be *)
                             (*  started with at FormDo      *)
      r,x,y,w,h : INTEGER;
      ok        : BOOLEAN;   (* Exit condition *)
      str       : POINTER TO Strng;

      HObP,HObs : Point;     (* To remember old values of *)
      
      HZoom,HTrS: REAL;      (*  view parameters.         *)      

BEGIN
 (* Put view parameters into Tree FORM *)
 (* and store old values:              *)
  PutForm (Observer, ObPoint, Zoom, TransStep);
  ReadForm(HObs, HObP, HZoom, HTrS);  

 (* Compute x,y,w and h such that FORM    *)
 (* will be placed into middle of screen  *)
 (* Note: x,y,w,h are VAR parameters here *)
  FormCenter(FormTree, x,y,w,h);

 (* Reserve screen area for FORM   *)
  FormDialogue( FormStart,  0,0,0,0, x,y,w,h );

 (* Grow box for FORM              *)
  FormDialogue( FormGrow,   0,0,0,0, x,y,w,h );

 (* Set mouse back to an arrow: *)
  GrafMouse(Arrow, NIL);

  begtext:= DTRANS;
  REPEAT
    ok:= TRUE;

   (* Draw object FORM *) 
    ObjectDraw  ( FormTree, 0, 10, x,y,w,h );

   (* Monitor user interactions in FORM *)
    r:= FormDo  ( FormTree, begtext);

   (* Deselect exit button used (Ok or Cancel) *)
    WITH FormTree^[r] DO state:= state-Selected END;

   (* Read values into variables if Ok was selected *)
    IF r=FORMOK THEN ReadForm(Observer, ObPoint, Zoom, TransStep) END;

   (* Ask for new values on erroneous input *)
    IF Zoom=0.0 THEN (* Multiplication factor of zero is meaningless *)
      r:= ShowAlert(ZEROZOOM);
      begtext:= ZOOM;
      ok:= FALSE

    ELSIF EqPoint(Observer, ObPoint) THEN (* Undefined view direction *)
      r:= ShowAlert(ZEROVIEW);
      begtext:= OBSX; 
      ok:= FALSE  
    END;

  UNTIL ok; (* Until correct data *)


 (* Shrink form box *)
  FormDialogue( FormShrink, 0,0,0,0, x,y,w,h );

 (* and free screen area used *)
  FormDialogue( FormFinish, 0,0,0,0, x,y,w,h );


  IF r=FORMCAN  
        THEN RETURN Canceled END;

  IF ( (NOT EqPoint(HObs,Observer))
        OR (NOT EqPoint(HObP,ObPoint)))
        THEN RETURN NewCoords END;

  IF HZoom#Zoom
        THEN RETURN NewZoom END;

  IF HTrS#TransStep 
        THEN RETURN NewStep END;

  RETURN Nothing
  
END FillForm;


PROCEDURE ReadForm(VAR Observer, ObPoint: Point;
                   VAR Zoom, TransStep  : REAL );
(*********************************************)
(* Read all view parameters from object FORM *)
(*********************************************)

  PROCEDURE GetValue(field: INTEGER): REAL;
  (* Read REAL from edited string 'field' in object FORM *)
    VAR 
      b: BOOLEAN;
      r: REAL;
  BEGIN
    ConvertToReal(FormTree^[field].spec^.text^, b, r);
    RETURN r
  END GetValue;


BEGIN
  WITH Observer DO
    x1:= GetValue(OBSX);
    x2:= GetValue(OBSY);
    x3:= GetValue(OBSZ);
  END;

  WITH ObPoint DO
    x1:= GetValue(LOOKX);
    x2:= GetValue(LOOKY);
    x3:= GetValue(LOOKZ);
  END;

  Zoom:= GetValue(ZOOM);

  TransStep:= GetValue(DTRANS);

END ReadForm;



PROCEDURE PutForm(Observer, ObPoint: Point;
                  Zoom, TransStep  : REAL );
(********************************************)
(* Put all view parameters into object FORM *)
(********************************************)

  PROCEDURE PutValue(field: INTEGER; val: REAL);
  (* Put string representation of val into field *)
  BEGIN
    ConvertReal(val, 6, 2, FormTree^[field].spec^.text^);
  END PutValue;

BEGIN
  WITH Observer DO
    PutValue(OBSX, x1);
    PutValue(OBSY, x2);
    PutValue(OBSZ, x3);
  END;

  WITH ObPoint DO
    PutValue(LOOKX, x1);
    PutValue(LOOKY, x2);
    PutValue(LOOKZ, x3);
  END;

  PutValue(ZOOM, Zoom);

  PutValue(DTRANS, TransStep);
END PutForm;



PROCEDURE DoDial(form: ObArray; ftext: INTEGER): INTEGER;
(******************************************************)
(* Let user edit a dialogue box; see for explaination *)
(* comments in FillForm                               *)
(******************************************************)
  VAR
    r,x,y,w,h: INTEGER;
 
BEGIN 
  GrafMouse(Arrow, NIL);
  FormCenter(form, x,y,w,h);
  FormDialogue( FormStart,  0,0,0,0, x,y,w,h );
  FormDialogue( FormGrow,   0,0,0,0, x,y,w,h );
  ObjectDraw  ( form, 0, 10, x,y,w,h );
  r:= FormDo ( form, ftext);
  FormDialogue( FormShrink, 0,0,0,0, x,y,w,h );
  FormDialogue( FormFinish, 0,0,0,0, x,y,w,h );

  WITH form^[r] DO state:= state-Selected END;

  RETURN r
END DoDial;




PROCEDURE DrawCross(x,y,w,h: INTEGER);
(* Plots cross in middle of rectangle *)  
  TYPE
    Double= RECORD
              CASE BOOLEAN OF (* for omitting index computations *)
                TRUE : x1,x2,y1,y2: INTEGER     |
                FALSE: array      : PxyArrayType
              END
            END;                

  VAR
    Buff  : Double;
    mx, my: INTEGER;

BEGIN
  mx:= x+ (w DIV 2);
  my:= y+ (h DIV 2);

  WITH Buff DO
    x1:= x;
    x2:= my;
    y1:= x+w;
    y2:= my;

    PolyLine(handle,2,array);

    x1:= mx;
    x2:= y;
    y1:= mx;
    y2:= y+h;

    PolyLine(handle,2,array);
  END;

END DrawCross;




END DDHelp.
