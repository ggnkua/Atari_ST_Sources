IMPLEMENTATION MODULE Globals;

(*****************************************************)
(*                                                   *)
(*      GLOBALS version 2.1                          *)
(*      -------------------                          *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements some procedures of         *)
(* main program DRIEDIM (which handles the user      *)
(* interface).                                       *)
(* This main program became too big for              *)
(* the compiler, that's why it was divided into      *)
(* four parts: GLOBALS, DDHELP, DRAWPROJ and DRIEDIM *) 
(*                                                   *)
(*****************************************************)

  FROM GEMDOS          IMPORT GetPath;

  FROM AESResources    IMPORT ResourceLoad, ResourceFree,
                              ResourceGetAddr;

  FROM AESMenus        IMPORT MenuText, MenuItemCheck;
 
  FROM AESForms        IMPORT FormDo, FormAlert, FormCenter, 
                              FormDialogue, FileSelectorInput;

  FROM AESObjects      IMPORT ObjectDraw;

  FROM AESApplications IMPORT ApplInitialise, ApplExit;

  FROM SYSTEM      IMPORT ADR, ADDRESS; 

  FROM Storage     IMPORT CreateHeap;

  FROM VDIEscapes  IMPORT CursorHome;

  FROM VDIControls IMPORT OpenVirtualWorkstation,
                          CloseVirtualWorkstation;

  FROM VDIOutputs  IMPORT PolyLine;

  FROM GEMVDIbase  IMPORT VDIWorkInType, VDIWorkOutType, PxyArrayType;

  FROM GEMAESbase  IMPORT Name, Closer, Fuller, Mover, Sizer,
                          UpArrow, DownArrow, LeftArrow, RightArrow,
                          VertSlide, HorizSlide,
                          MouseOn, MouseOff, Arrow,
                          WindowName, Top,
                          FullXYWH, CurrXYWH, WorkXYWH,
                          WindowHorizSlide, WindowVertSlide,

                          FormStart, FormGrow, FormShrink, FormFinish,

                          Selected,  White,

                          RTree, RString, 

                          AESCallResult;
                                  

  FROM AESGraphics IMPORT GrafHandle, GrafMouse, GrafGrowBox, GrafShrinkBox;

  FROM AESWindows  IMPORT WindowCreate, WindowOpen, WindowGet, WindowSet,
                          WindowClose,  WindowDelete, WindowUpdate;

  FROM M2Conversions IMPORT ConvertToReal, ConvertReal;

  FROM String      IMPORT Length, Concat, Delete;

  FROM Vectors     IMPORT Point, EqPoint;

  FROM LParser    IMPORT LInitWarmParser, LParseError, 
                         ReadHeapSize, ReadObject;




  VAR DirectoryPath: Strng; (* To remember chosen directory *) 
                            (* in ChooseFile                *)

PROCEDURE AllocateStuff(VAR WindTitle: ARRAY OF CHAR): BOOLEAN;
(***********************************************)
(* Get information about desktop, application, *)
(* Create windows to show pictures in and load *)
(* resource file (create with the resource     *)
(* construction set).                          *)
(* Return TRUE iff the resource file was found.*)
(* The window title parameter cannot be placed *)
(* on the stack, so a global value is passed.  *)
(***********************************************)
  CONST
    ResourceFileName= "driedim.rsc";

    DefDrive = 0;    (* Id from default drive          *)


   (* the only resource defined in this program; *)
   (* all others are loaded from DRIEDIM.RSC:    *)
    Alert           = "[3][ File DRIEDIM.RSC not present ][OK]";

  VAR
    str       : Strng;
    result    : INTEGER;
    intin     : VDIWorkInType;
    intout    : VDIWorkOutType;

    dummy, i  : INTEGER;
 

BEGIN
 (* Get the handle of the desktop; *)
 (* Height of menubar is height of *)
 (* character box:                 *)
  handle:= GrafHandle(dummy, dummy, dummy, HMenuBar);

 (* Homes cursor: *)
  CursorHome(handle);

 (* Open virtual workstation on desktop *)
 (* with default values for all kind of *)
 (* attributes.                         *)
 (* VDI manual pag 3-1.                 *)

  FOR i:=1 TO 10 DO intin[i]:= 1 END;
  intin[0]:= 0;     (* Screen workstation.                        *)
  intin[9]:= White; (* Fill color for Fillrectangle in DrawWindow *)

  OpenVirtualWorkstation(intin, handle, intout);

 (* Get returned screen size in pixels *)
  WDesk := intout[0]; 
  HDesk := intout[1]- HMenuBar;

 (* Mouse back to an arrow *)
  GrafMouse(Arrow, NIL);


 (* Create windows; for window management, see AES manual *)
 (* pag 2-11 to 2-13 and description of various routines  *)
 (* 11-13 to 11-25.                                       *)

 (* Window with attributes to move through driedim world: *)
  Window1:= WindowCreate(Name+Closer+Fuller+Mover+Sizer+
                         UpArrow+DownArrow+LeftArrow+RightArrow+
                         VertSlide+HorizSlide,
                         0, HMenuBar, WDesk, HDesk);

 (* The full page window; No attributes:            *)
  Window2:= WindowCreate(0, 0, HMenuBar, WDesk, HDesk);

 (* Set name of window 1 (it has a Name attribute): *)
  WindowSet (Window1, WindowName, 
             INTEGER(ADR(WindTitle) DIV 10000H),
             INTEGER(ADR(WindTitle) MOD 10000H), 
             0,0);


 (* Initialise application for AES calls *)
 (* Application identifier is returned.  *)
  ApId:= ApplInitialise();

 (* Get dir path from default drive: *)
  GetPath(DirectoryPath, DefDrive);

 (* Load resource file, and give error if not to be found: *)
 (* Otherwise, get begin addresses of object trees used.   *)

  str:= ResourceFileName;
  ResourceLoad(str);
  IF AESCallResult=0 THEN (* .RSC was not found; display Alert box: *)
    str:= Alert;
    result:= FormAlert(1,str);
    RETURN FALSE  
  ELSE
    ResourceGetAddr(RTree, MENU,  MenuTree);
    ResourceGetAddr(RTree, FORM,  FormTree);
    ResourceGetAddr(RTree, ABOUT, AboutTree);
    RETURN TRUE;
  END;

END AllocateStuff;




PROCEDURE DeAllocateStuff;
 (*************************************)
 (* Deallocate all things, that where *)
 (* allocated in AllocateStuff:       *)
 (*************************************)
BEGIN
 (* Free windows, otherwise the desktop *)
 (* will get into trouble               *)
  WindowDelete( Window1 );
  WindowDelete( Window2 );
   
 (* free workstation *)
  CloseVirtualWorkstation(handle);

 (* free memory, occupied by resources: *)
  ResourceFree;

 (* Deallocate working area for application *)
  ApplExit
END DeAllocateStuff;


PROCEDURE ChooseFile(VAR fil: ARRAY OF CHAR): BOOLEAN;
(***************************************************************)
(* on entry, fil contains template of filename to be chosen    *)
(* On exit,  fil contains full name (including directory path) *)
(* of chosen file. Returns True iff ok was pressed.            *)
(***************************************************************)

  CONST
    Cancel   = 0;    (* Cancel button of file selector *)

  VAR
    h,
    sel,              (* For FileSelectorInput: returned filename      *)
    path: Strng;      (* For FileSelectorInput: initial directory path *)
    res : INTEGER;
    i   : CARDINAL;
BEGIN
  Concat (DirectoryPath, fil, path); (* Default directory path *)
  sel := "";                         (* Initial filename       *)

  FileSelectorInput(ADR(path), ADR(sel), res);

  (* Strip mask of filename from path: *)
  i:= Length(path);
  REPEAT i:=i-1 UNTIL path[i]='\';
  Delete(path, i+1, Length(path)-i-1);
  Concat(path,sel,fil);
  Delete(path, i, 1);

  (* Remember last directory path chosen *)
  IF res<>Cancel THEN DirectoryPath:= path END;

  (* Now 'fil' is filled in with chosen filename;  *)
  (* res contains ID of the activated exit button: *)
  RETURN res#Cancel

END ChooseFile;



PROCEDURE InitDrieDim(): BOOLEAN;
(*******************************************)
(* Create heap to store driedim objects on *)
(* (do not confuse with GEM objects), and  *)
(* load objects from requested file.       *)
(* Return False iff something went wrong.  *)
(*******************************************)

  CONST
    DefHeapSize= 100;  (* Default size of working space  *)
                       (*  in KiloByte                   *) 

  VAR
    HeapSize: LONGCARD; (* var to store heapsize in (kilobyte)  *)
    fil     : Strng;    (* string to compute full file name in; *)
    ok      : BOOLEAN;
    res     : INTEGER;
BEGIN
  REPEAT
    ok:= TRUE;

    (* request filename: *)
    fil:= "\*.PLT";

    IF NOT ChooseFile(fil) THEN RETURN FALSE END;

    IF NOT LInitWarmParser(fil) THEN (* Display Alert box: *)
      res:= ShowAlert(UNKNFILE);
      ok:= FALSE  
    END;

  UNTIL ok;

 (* Read heapsize, and try to create heap: *)
  HeapSize:= ReadHeapSize();
  IF HeapSize=0 THEN HeapSize:= DefHeapSize END;

  IF NOT CreateHeap(HeapSize*1000,FALSE) THEN (* Display Alert box: *)
    res:= ShowAlert(NOMEMORY);
    RETURN FALSE  
  END;

 (* read driedim object from selected file: *)
  Parts:= ReadObject();

 (* Stop if the driedim parser detected errors: *)
  IF LParseError() THEN (* Display Alert box: *)
    res:= ShowAlert(SYNTXERR);
    RETURN FALSE  
   ELSE (* Everything OK: *)
    RETURN TRUE
  END;
END InitDrieDim;



PROCEDURE ShowAlert(Str: INTEGER): INTEGER;
(*******************************************)
(* Get string from resource set, belonging *)
(* to Str, display it, and return number   *)
(* of activated exit button.               *)
(*******************************************)
  VAR
    s : POINTER TO Strng;
BEGIN
  ResourceGetAddr(RString, Str, s);
  RETURN FormAlert(1,s^)
END ShowAlert;


END Globals.
