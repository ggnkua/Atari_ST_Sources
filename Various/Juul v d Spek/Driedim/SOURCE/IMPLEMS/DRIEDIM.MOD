
MODULE Driedim;

(*****************************************************)
(*                                                   *)
(*      DRIEDIM version 2.1                          *)
(*      -------------------                          *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module is the main module of DRIEDIM.        *)
(* it contains mainly the startup and the event loop *)
(* Since it became too big for the compiler, it was  *)
(* divided into four parts: GLOBALS, DDHELP,         *)
(* DRAWPROJ and DRIEDIM.                             *) 
(*                                                   *)
(*****************************************************)

  FROM AESApplications IMPORT ApplWrite;

  FROM SYSTEM      IMPORT ADR; 

  FROM GEMDOS      IMPORT Delete, SetOrGet, Attrib;

  FROM VDIEscapes  IMPORT HardCopy;

  FROM AESMenus    IMPORT MenuBar, MenuTitleNormal;

  FROM GEMAESbase  IMPORT ButtonEvent, Mouse1Event, MesageEvent,
                          ThinCross,
                          MouseOn, MouseOff, HourGlass, Arrow,
                          Top,
                          FullXYWH, CurrXYWH, WorkXYWH,
                          WindowHorizSlide, WindowVertSlide,

                          WindowRedraw, WindowTopped, WindowClosed,
                          WindowFulled, WindowArrowed, WindowHorizSlided,
                          WindowVertSlided, WindowSized, WindowMoved,
                          WindowNewTop, MenuSelected;
                                  

  FROM AESGraphics IMPORT GrafMouse, GrafGrowBox, GrafShrinkBox,
                          GrafMouseKeyboardState;

  FROM AESWindows  IMPORT WindowOpen, WindowGet, WindowSet, WindowClose;

  FROM AESEvents   IMPORT EventMultiple;



  (* ------------------------- *)
  (* Driedim specific modules: *)
  (* ------------------------- *)
  FROM Objects    IMPORT LineList, PlotFile, PlotFileResult;

  FROM Vectors    IMPORT Point, LookAt,
                         MoveFurther, MoveUp, MoveHoriz, Rotate, Elevate;

  FROM DrawProj   IMPORT NewView, DrawWindow;

  FROM DDHelp     IMPORT SwitchFullView, FillForm, FillFormResult,
                         ReadForm, PutForm, DoDial, 
                         scale, member, CheckItem, DrawCross;

  FROM Globals    IMPORT InitDrieDim, AllocateStuff, DeAllocateStuff,
                         ApId, Window1, Window2, handle, Strng,
                         MenuTree, FormTree, AboutTree, ChooseFile,
                         WDesk, HDesk, HMenuBar, Parts, ShowAlert,

                         DELPLOTF, DISKFULL, FILEXIST, 
                         PLOTFILE, ABOUTDD, QUITDD, VIEWPIC, 
                         SETPARMS, CANTOPEN, READONLY,
                         RESETFLG, HLRFLG, FULLVIEW, CROSSFLG, PRINTSCR; 

  



PROCEDURE Events;
(***********************************************************)
(* Loop and act upon messages, received by window manager: *)
(* For description of all kinds of events and messages,    *)
(* see AES manual section 4.                               *)
(***********************************************************)
  CONST
   (* Window arrow types, returned in message type WindowArrowed *)
    PageUp    = 0;
    PageDown  = 1;
    ArrowUp   = 2;
    ArrowDown = 3;
    PageLeft  = 4;
    PageRight = 5;
    ArrowLeft = 6;
    ArrowRight= 7;

   (* returned file attribute (Attrib) *)
    ReadOnly  = 1;

   (* Used for events: *)
    EnterRect = 0;
    ExitRect  = 1;
    LeftButton= 1;
    LeftDown  = 1;

   (* Minimum allowed sizes for window1: *)
      wMin= 30;
      hMin= 30;

   (* Menu switches *)
      MenuOn    = 1;
      MenuOff   = 0;    
      ItemNormal= 1;

  TYPE
    WindPos= RECORD X,Y,W,H: INTEGER END;

  VAR
   (* Buffer to receive messages *)
    Message  : ARRAY [0 .. 9] OF INTEGER;

   (* String to fill with filename by ChooseFile *)
    FileName : Strng;

    TransStep,            (* Translation value for moving *)
                          (*  through Driedim world.      *)

    Zoom     : REAL;      (* zoom factor for projection *)
    
    Observer,             (* Position of observer          *)
    ObPoint: Point;       (* and of observed point         *)
    Proj   : LineList;    (* Description of projected view *)

   (* Only if applicable:  *)
    AmountSlided,      (* Slider position      *)
    ArrowKind,         (* Selected arrow       *)
    MenuTitle,         (* Selected menu title. *)
    MenuItem: INTEGER; (* Selected menu item.  *)

   (* Current window with size of work area:     *)
    Window, Wx,Wy,Ww,Wh : INTEGER;  

    full,                   (* Window1 full sized?               *)
    done,                   (* Exit condition                    *)
    HLR,                    (* Hidden line removal on/off        *)
    CrossFlg,               (* cross on/off                      *)
    PicFlg,                 (* View/Picture mode                 *)
    ResetFlg,               (* Automatic HLR reset?              *)
    InRectangle,            (* Mouse cursor in active window?    *)
    fullview : BOOLEAN;     (* To remember if window2 active     *)
    old, hw  : WindPos;     (* size memory for window1.          *)

    MEvType,                (* mouse event type (enter exit rectangle) *)
    MouseForm,              (* current form of mouse cursor            *)
    events   : INTEGER;     (* to remember events that have occurred   *)


    DeltaX, DeltaY,         (* Picture translation; always 0 when *)
                            (*  in view mode.                     *)

    dx,dy,dummy,            (* some workspace *)
    x,y,w,h,k: INTEGER;
    n        : CARDINAL;
    r        : REAL;
    b        : BOOLEAN;


  PROCEDURE NewPicture(newview: BOOLEAN);
  (* Draw new view in current window; compute new view if *)
  (* newview is true, and send redraw message to Window   *)
  BEGIN    
    IF newview THEN NewView(Observer, ObPoint, Proj, HLR, ResetFlg) END;

    Message[0]:= WindowRedraw;
    Message[3]:= Window; 
    Message[4]:= Wx; 
    Message[5]:= Wy;
    Message[6]:= Ww;
    Message[7]:= Wh;
    ApplWrite(ApId, 16, ADR(Message) );
  END NewPicture;


  PROCEDURE HandleMenu(MenuItem: INTEGER);
  (***************************************************)
  (* MenuItem was selected; perform requested action *)
  (***************************************************)
  BEGIN
    CASE MenuItem OF
      ABOUTDD : k:= DoDial(AboutTree,-1)
     |QUITDD  : done:= TRUE             
     |FULLVIEW: SwitchFullView(fullview)
     |HLRFLG  : CheckItem(HLRFLG, HLR)  
     |RESETFLG: CheckItem(RESETFLG, ResetFlg)

     |DELPLOTF: FileName:= "\*.LNS";
                IF ChooseFile(FileName) THEN
                  Attrib(FileName, get, n);
                  IF n=ReadOnly THEN dummy:= ShowAlert(READONLY)
                   ELSE b:= Delete(FileName)
                  END
                END

     |PLOTFILE: FileName:= "\*.LNS";
                IF ChooseFile(FileName) THEN
                  CASE PlotFile(FileName, dx, dy, Zoom, Proj) OF
                    Prima     : (* All went ok. *)          |
                    CantOpen  : dummy:= ShowAlert(CANTOPEN) |
                    DiskFull  : dummy:= ShowAlert(DISKFULL) |
                    FileExists: dummy:= ShowAlert(FILEXIST) |
                  END
                END

     |CROSSFLG: CheckItem(CROSSFLG, CrossFlg);
                IF CrossFlg THEN DrawCross(Wx,Wy,Ww,Wh)
                ELSE NewPicture(FALSE) END

     |PRINTSCR: GrafMouse(MouseOff, NIL);
                HardCopy(handle);
                GrafMouse(MouseOn , NIL)

     |VIEWPIC : CheckItem(VIEWPIC, PicFlg);
                IF (NOT PicFlg) AND ((DeltaX#0) OR (DeltaY#0)) THEN
                  DeltaX:= 0;
                  DeltaY:= 0;
                  NewPicture(FALSE)
                END
                                     
     |SETPARMS: CASE FillForm(Observer, ObPoint, Zoom, TransStep)  OF
                  NewCoords:
                    NewPicture(TRUE);
                    DeltaX:= 0;
                    DeltaY:= 0        |
                  NewZoom  :
                    NewPicture(FALSE) |
                  Canceled,
                  Nothing,
                  NewStep :
                    (* Do Nothing *)
                 END; 
    END;
  END HandleMenu;


BEGIN
 (* Set initial states *)
  full    := FALSE;
  fullview:= FALSE;
  done    := FALSE;
  CrossFlg:= FALSE;
  HLR     := FALSE;
  ResetFlg:= TRUE;
  PicFlg  := FALSE;

  DeltaX:= 0;
  DeltaY:= 0;



 (* Set projection to known value: *)
  Proj:= NIL;
 
 (* Get initial view parameters (Observer, ObPoint,  *)
 (* Zoom and TransStep) from resource FORM:          *)
  ReadForm(Observer, ObPoint, Zoom, TransStep);

 (* .. and compute first projection *)
  NewView(Observer, ObPoint, Proj, HLR, FALSE); 


 (* Turn on menubar (Object MENU) *) 
  MenuBar(MenuTree, MenuOn);

 (* And open window1; remains opened until exit *)
 (* The growbox is optional                     *)
  GrafMouse(MouseOff, NIL);
  GrafGrowBox(10, HMenuBar+10, 1, 1,                (* Begin rectangle *)
              10, HMenuBar+10, WDesk-40, HDesk-40); (* End rectangle   *)
  WindowOpen(Window1,
             10, HMenuBar+10, WDesk-40, HDesk-40);  (* Initial size    *)
  GrafMouse(MouseOn, NIL);

 (* Turn sliders in middle of slider bar (scale = 0 .. 1000): *)
  WindowSet (Window1, WindowVertSlide, 500, 0, 0, 0);
  WindowSet (Window1, WindowHorizSlide, 500, 0, 0, 0);


  REPEAT
   (* Get current window and its size: *)
    IF fullview THEN Window:= Window2 ELSE Window:= Window1 END;
    WindowGet(Window, WorkXYWH, Wx,Wy,Ww,Wh);

   (* Get mouse position, and decide in this window or not: *)
    GrafMouseKeyboardState(dx,dy,dummy,dummy);
    InRectangle:= (Wx<dx) AND (Wy<dy)
                   AND ((Wx+Ww)>dx) AND ((Wy+Wh)>dy);

   (* Set current mouse form and -event type: *)
    IF InRectangle THEN
      MouseForm:= ThinCross;
      MEvType  := ExitRect
     ELSE
      MouseForm:= Arrow;
      MEvType  := EnterRect
    END;

   GrafMouse(MouseForm, NIL);


   (* Wait for next event: buttonclick, window/menu message *)
   (*  or exit/entry work area of current window:           *)
   events:= 
    EventMultiple( ButtonEvent
                   +Mouse1Event
                   +MesageEvent,         (* Events to be waited for *)

                   1,                    (* One button click  *)
                   LeftButton,           (* with left button  *)
                   LeftDown,             (*  down.            *)

                   MEvType, Wx,Wy,Ww,Wh, (* or mouse entry/exit window *)
                   0,0,0,0,0,            (* no mouse2 event            *)
                   ADR(Message),         (* buffer for message         *)

                   0,0,                  (* No timer event                  *)
                   dx,dy,                (* returned mouse coord's at event *)

                   dummy,dummy,dummy,dummy);                 


   IF member(MesageEvent, events) THEN
    CASE Message[0] OF
      WindowRedraw     :(* Part of window exposed: redraw          *) 
                         DrawWindow(Proj, 
                                    Message[4], Message[5],
                                    Message[6], Message[7],
                                    Zoom, Window, DeltaX, DeltaY, CrossFlg);

     |WindowClosed     :(* Closer is activated; Set exit condition *)
                         done:= TRUE;

     |WindowFulled     :(* Fuller was activated; this application  *)
                        (* owns only one window with a fuller: #1  *)
                        (* Switch between full window size, and    *)
                        (* old value.                              *)
                         IF NOT full THEN
                           WITH old DO (* Get maximum size of window *)
                             WindowGet(Window, FullXYWH, X, Y, W, H) 
                           END
                         END;

                         WITH hw DO (* and current size *)
                           WindowGet(Window, CurrXYWH, X, Y, W, H)
                         END;

                         IF full THEN
                           GrafShrinkBox(old.X, old.Y, old.W, old.H,
                                         hw.X,  hw.Y,  hw.W,  hw.H)
                          ELSE
                           GrafGrowBox(hw.X,  hw.Y,  hw.W,  hw.H,
                                       old.X, old.Y, old.W, old.H)
                         END;

                         WITH old DO (* Set new size *)
                           WindowSet(Window, CurrXYWH, X, Y, W, H)
                         END;

                         full:= NOT full;
                         old:= hw;
                         
     |WindowArrowed    :(* One of window's arrows activated *)
                        (* Move position of 3D observer:    *)
                         ArrowKind:= Message[4];
                         IF NOT PicFlg THEN
                           CASE ArrowKind OF
                             PageUp    : MoveFurther(Observer, ObPoint,
                                                     TransStep);
                            |PageDown  : MoveFurther(Observer, ObPoint,
                                                     -TransStep);
                            |ArrowRight: MoveHoriz  (Observer, ObPoint,
                                                      TransStep);
                            |ArrowLeft : MoveHoriz  (Observer, ObPoint,
                                                     -TransStep);
                            |ArrowUp   : MoveUp     (Observer, ObPoint,
                                                     -TransStep);
                            |ArrowDown : MoveUp     (Observer, ObPoint,
                                                      TransStep);
                           ELSE END;
                           NewPicture(TRUE)

                          ELSE
                           CASE ArrowKind OF
                             PageUp     : DeltaY:= DeltaY + Wh |
                             PageDown   : DeltaY:= DeltaY - Wh |
                             PageRight  : DeltaX:= DeltaX - Ww |
                             PageLeft   : DeltaX:= DeltaX + Ww |
                             ArrowUp    : DeltaY:= DeltaY + Wh DIV 10 |
                             ArrowDown  : DeltaY:= DeltaY - Wh DIV 10 |
                             ArrowRight : DeltaX:= DeltaX - Ww DIV 10 |
                             ArrowLeft  : DeltaX:= DeltaX + Ww DIV 10 |
                           END;
                           NewPicture(FALSE);
                         END;

     |WindowHorizSlided: (* Horizontal slider was used, compute *)
                         (* arc between -pi and pi for turning  *)
                         (* observer:                           *)
                         AmountSlided:= Message[4];

                        (* Set slider box to indicated position; *)
                        (* is set back at beginning of this loop *)
                         WindowSet (Window, WindowHorizSlide, 
                                    AmountSlided, 0, 0, 0);

                         IF NOT PicFlg THEN
                           r:= FLOAT(VAL(CARDINAL,AmountSlided))*6.283/1000.0
                               - 3.1415;
                           Rotate(Observer, ObPoint, r);
                           NewPicture(TRUE);

                          ELSE
                           DeltaX:= DeltaX - scale(AmountSlided, Ww);
                           NewPicture(FALSE)
                         END;

                         WindowSet (Window1, WindowHorizSlide, 500, 0, 0, 0)


     |WindowVertSlided :(* see previous case *)
                         AmountSlided:= Message[4];

                         WindowSet (Window, WindowVertSlide, 
                                    AmountSlided, 
                                    (* Dummies: *) 0,0,0);

                         IF NOT PicFlg THEN
                           r:= FLOAT(VAL(CARDINAL,AmountSlided))*3.1415/1000.0
                               - 1.57;
                           Elevate(Observer, ObPoint, r);
                           NewPicture(TRUE)

                          ELSE
                           DeltaY:= DeltaY - scale(AmountSlided, Wh);
                           NewPicture(FALSE)
                         END;

                         WindowSet (Window1, WindowVertSlide, 500, 0, 0, 0);


     |WindowSized,      (* Window was asked to move or resize; *)
      WindowMoved       (* set to requested position           *)
                       : x:= Message[4];
                         y:= Message[5];
                         w:= Message[6];
                         h:= Message[7];

                        (* May not become to small: *)
                         IF w<wMin THEN w:= wMin END;
                         IF h<hMin THEN h:= hMin END;
                         WindowSet(Window, CurrXYWH, x, y, w, h);
                         
                         IF Message[0]=WindowSized THEN
                           NewPicture(FALSE)
                         END

     |WindowTopped,     (* Window has been asked to bring to top of desk *)
      WindowNewTop     : WindowSet(Window, Top, 
                                   (* Dummies: *) 0,0,0,0);


     |MenuSelected     :(* Some menu item was selected; perform *)
                        (* the requested action:                *)
                         MenuItem := Message[4];
                         MenuTitle:= Message[3];

                         HandleMenu(MenuItem);

                        (* Deselect menu item *)
                         MenuTitleNormal(MenuTree, MenuTitle, ItemNormal);
    END

   ELSIF member(ButtonEvent, events) AND InRectangle THEN
     dx:= Wx + (Ww DIV 2) - dx;
     dy:= Wy + (Wh DIV 2) - dy;

     IF NOT PicFlg THEN 
       LookAt(dx, -dy, Zoom, Observer, ObPoint);
       NewPicture(TRUE)
      ELSE
       DeltaX:= DeltaX+dx;
       DeltaY:= DeltaY+dy;
       NewPicture(FALSE)
     END
   END
  UNTIL done;

 (* Close window2, if open *)
  IF fullview THEN SwitchFullView(fullview) END;

 (* Close window1;  *)
  WindowGet(Window1, CurrXYWH, x,y,w,h);
  WindowClose ( Window1 );
  GrafShrinkBox( 0, 0, 0, 0, x,y,w,h);

 (* Remove menubar *)
  MenuBar(MenuTree, MenuOff);
END Events;




BEGIN
  IF AllocateStuff( " DrieDim " ) THEN   (* Allocation ok.               *)
    IF InitDrieDim() THEN                (* Inputfile was found and read *)
      Events                             (* -> go into event loop        *)
    END;
  END;

  DeAllocateStuff;  
END Driedim.


