* ST-Log Magazine presents
* The Assembly Line
* (c) 1989 Frank Cohen

* This program will be used as a platform to build a simple
* word processor.  The program has been written in a generic
* style for you to find it useful when developing new ST
* applications. -FC


* ///--- *
* Name of Program/Subroutine:  SKELETON
* Purpose/Description:
*  Provide the fundimental outline of a well crafted GEM-based
*  assembly language computer program.
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  Program reads the GEM desktop information to see if calling program
*  passed some parameters.  The parameter information is stored in
*  the PARAMS text buffer.
* Outputs:
*  None
* ---\\\ *


* Resource Related Equates

MENUS = 0;  REM ---TREE---
MENU1 = 3;  REM ---OBJECT in TREE #0---
MABOUT = 9;  REM ---OBJECT in TREE #0---
MENU3 = 5;  REM ---OBJECT in TREE #0---
MENU2 = 4;  REM ---OBJECT in TREE #0---
MNEW = 18;  REM ---OBJECT in TREE #0---
MOPEN = 19;  REM ---OBJECT in TREE #0---
MCLOSE = 20;  REM ---OBJECT in TREE #0---
MSAVE = 21;  REM ---OBJECT in TREE #0---
MSAVEAS = 22;  REM ---OBJECT in TREE #0---
MSETUP = 23;  REM ---OBJECT in TREE #0---
MPRINT = 24;  REM ---OBJECT in TREE #0---
MQUIT = 25;  REM ---OBJECT in TREE #0---
MCUT = 27;  REM ---OBJECT in TREE #0---
MCOPY = 28;  REM ---OBJECT in TREE #0---
MPASTE = 29;  REM ---OBJECT in TREE #0---
MCLEAR = 30;  REM ---OBJECT in TREE #0---
MUNDO = 32;  REM ---OBJECT in TREE #0---
DABOUT = 1;  REM ---TREE---
BABOUT = 7;  REM ---OBJECT in TREE #1---
ABADMODE = 0;  REM ---STRING---
AREUSURE = 1;  REM ---STRING---
MENU4 = 6;  REM ---OBJECT in TREE #0---
MDIAGNOS = 34;  REM ---OBJECT in TREE #0---


* Gem Related Equates

OBSIZE EQU 24  ;bytes per object structure

OB_NEXT EQU 0  ;object offsets
OB_HEAD EQU 2
OB_TAIL EQU 4
OB_TYPED EQU 6
OB_FLAGS EQU 8
OB_STATE EQU 10
OB_SPEC EQU 12
OB_X EQU 16
OB_Y EQU 18
OB_WDTH EQU 20
OB_HGHT EQU 22

TEDSIZE EQU 28   ;Size of each TEDINFO structure

TE_PTEXT EQU 0   ;TEINFO offsets
TE_PTMPLT EQU 4
TE_PVALID EQU 8
TE_FONT EQU 12
TE_RESVD EQU 14
TE_JUST EQU 16
TE_COLOR EQU 18
TE_RESV2 EQU 20
TE_THICK EQU 22
TE_TXLEN EQU 24
TE_TMPLN EQU 26

* ---\\\ *



* ///--- *
* Cold-Entry Point

START MOVE.L A7,A5            ;Move the Stack Pointer to our own stack
 MOVE.L #USTK,A7              ;buffer.  See bottom of this program.

 MOVE.L 4(A5),A5              ;Ask the operating system to make all of
 MOVE.L $C(A5),D0             ;the unused memory available to this new
 ADD.L $14(A5),D0             ;GEM program.  See Concise Guide, Appendix L 
 ADD.L $1C(A5),D0             ;for detailed explanation of this code.
 ADD.L #$100,D0               ;Suffice it so say, every GEM program
 MOVE.L D0,-(A7)              ;(except Desk Accessories) need this para-
 MOVE.L A5,-(A7)              ;graph of code.
 MOVE D0,-(A7)
 MOVE #$4A,-(A7)
 TRAP #1
 ADD.L #12,A7

 MOVE #GEMEND-GEMSTART,D0     ;Clear all the variables we will
 LEA GEMSTART,A0              ;use to talk to GEM.  This is
CLRGEM CLR.B (A0)+            ;just some housekeeping.
 DBF D0,CLRGEM

 MOVE #10,CONTRL              ;AES function: APPL_INIT
 CLR CONTRL+2                 ;Initalize application and establish GEM's
 MOVE #1,CONTRL+4             ;internal data structures that will be used
 CLR CONTRL+6                 ;when any AES function is used.
 CLR CONTRL+8
 JSR AES

 MOVE #77,CONTRL              ;AES function: GRAF_HANDLE
 CLR CONTRL+2                 ;Find the GEM VDI handle for the desktop's
 MOVE #5,CONTRL+4             ;workstation.  This value will be used when
 CLR CONTRL+6                 ;we later call the VDI.
 CLR CONTRL+8
 JSR AES
 MOVE INTOUT,DRHANDLE

 MOVE #100,CONTRL             ;VDI function: OPEN_VWORK
 CLR CONTRL+2                 ;Establish a new VDI workstation.  This
 MOVE #11,CONTRL+6            ;defines the workstation parameters,
 MOVE DRHANDLE,CONTRL+12      ;defaults, font and windowsize to be
 MOVE #1,INTIN                ;used when we later open a window.
 MOVE #1,INTIN+2              ;See Concise Guide, Page 4.9 for details.
 MOVE #1,INTIN+4
 MOVE #1,INTIN+6
 MOVE #1,INTIN+8
 MOVE #1,INTIN+10
 MOVE #1,INTIN+12
 MOVE #1,INTIN+14
 MOVE #1,INTIN+16
 MOVE #1,INTIN+18
 MOVE #2,INTIN+20
 JSR VDI
 MOVE CONTRL+12,GRHANDLE

 MOVE #104,OPCODE             ;AES function: WIND_GET
 MOVE #2,SINTIN               ;Get the physical size of the GEM Desktop. This
 MOVE #5,SINTOUT              ;tells us how large an open window may become.
 CLR SADDRIN                  ;Results are stored in our GEMXPOS buffer for
 CLR SADDROUT                 ;later use.
 CLR INTIN
 MOVE #4,INTIN+2
 JSR AES
 MOVE INTOUT+2,GEMXPOS
 MOVE INTOUT+4,GEMYPOS
 MOVE INTOUT+6,GEMWIDTH
 MOVE INTOUT+8,GEMHOEHE

 MOVE #10,SHRINK              ;Initialize FORMDO variables
 MOVE #10,SHRINK+2
 MOVE #40,SHRINK+4
 MOVE #20,SHRINK+6

 MOVE #MS_BUSY,D0             ;Show a Busy-Bee mouse shape, until we're
 JSR SHWMOUSE                 ;ready to receive a user command.

 JSR GETPATH                  ;Get the default folder path name

 LEA RSCNAME,A0               ;Use resource file
 LEA G_TREE,A1
 JSR RESOURCE
 TST D0
 BNE QUICK_QUIT

 JSR CHECKMODE                ;Check graphics mode
 TST D0
 BNE QUICK_QUIT

 MOVE #30,CONTRL              ;AES function: MENU_BAR
 MOVE #1,CONTRL+2             ;Display the menu bar
 MOVE #1,CONTRL+4
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE #1,INTIN
 MOVE.L MENU_TREE,ADDRIN
 JSR AES

 LEA MENU_ALL,A0              ;Disable all invalid menus
 JSR MENU_DISABLE

 MOVE #MS_ARROW,D0            ;Display arrow mouse shape, signal to
 JSR SHWMOUSE                 ;the user we are ready for events

 CLR SAVE_FLAG                ;Prompt user at exit

 LEA LINKED_LIST,A0
 DC $4AFC

MAIN_EVENT JSR NOCLIP         ;I've found most Desk Accessories do
 JSR TEXTINIT                 ;not reset VDI drawing parameters when
 MOVE #7,D0                   ;they terminate.  So, before each event
 JSR LINETYPE                 ;I set the VDI parameters.  This isn't
 MOVE #$FFFF,D0               ;necessary, just some housekeeping.
 JSR LINESTYL
 MOVE #2,D0
 JSR LINEWIDE
 MOVE #1,D0
 JSR SETCOLOR
 MOVE #1,D0
 JSR SETFILL
 CLR D0
 JSR FILLPERI
 MOVE #1,D0
 JSR GEMCOLR
 JSR TRANSRV

 MOVE #$33,D0                 ;Get one or more events from GEM
 JSR GT_EVENT                 ;KEY - MOUSE  - MESAGE - TIMER

MORE_EVENTS MOVE EVWHICH,D0   ;More than one event can be reported at
 AND #$10,D0                  ;once.  EVWHICH is used to keep track of
 BEQ EVENT2                   ;which events have been handled.
 MOVE EVWHICH,D0
 AND #$EF,D0
 MOVE D0,EVWHICH
 JSR MESEVENT                 ;Handle Message Event
 JMP MORE_EVENTS

EVENT2 JSR VALIDATE           ;Any drop-down menus selected?
 TST D0                       ;Drop down menus must be cleared
 BEQ EVENT4                   ;before handling a keyboard or
 CLR EVWHICH                  ;mouse event.
 JMP MAIN_EVENT

EVENT4 MOVE EVWHICH,D0        ;Handle keyboard events
 AND #1,D0
 BEQ EVENT3
 MOVE EVWHICH,D0
 AND #$FE,D0
 MOVE D0,EVWHICH
 JSR KEYEVENT
 JMP MORE_EVENTS

EVENT3 MOVE EVWHICH,D0        ;Handle mouse events
 AND #2,D0
 BEQ DOIDLE
 MOVE EVWHICH,D0
 AND #$FD,D0
 MOVE D0,EVWHICH
 JSR BUTEVENT
 JMP MORE_EVENTS

DOIDLE JMP MAIN_EVENT         ;Perform background tasks


* ///--- *
* Name of Program/Subroutine:  MESEVENT
* Purpose/Description:
*  Handle event messages
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

MESEVENT MOVE EVMESG,D0       ;Did a drop-down menu get selected?
 CMP #10,D0
 BEQ W_MENU
 CMP #20,D0                   ;Redraw the contents of a window
 BEQ W_REDRAW
 CMP #21,D0                   ;Our window is no longer on top
 BEQ W_TOPPED
 CMP #29,D0                   ;Our window has become the top window
 BEQ W_NEWTOP
 CMP #22,D0                   ;User clicked the Close-box of our window
 BEQ W_CLOSE
 CMP #24,D0                   ;User clicked one of the scrolling arrows
 BEQ W_ARROW
 CMP #25,D0                   ;User moved a horizontal slide bar
 BEQ W_HSLIDE
 CMP #26,D0                   ;User moved a vertical slide bar
 BEQ W_VSLIDE
 CMP #27,D0                   ;User changed the size of our window
 BEQ W_SIZED
 CMP #28,D0                   ;User dragged our window to a new location
 BEQ W_MOVED
 RTS

* The following labels have been established for consistency.  In
* a future chapter, these labels will be used in the block of source
* code that handes one of the above message events.

W_CLOSE TST D0                ;The TST commands are used to let the
W_TOPPED TST D0               ;the program execution fall through to
W_HSLIDE TST D0               ;the RTS command below.
W_SIZED TST D0
W_NEWTOP TST D0
W_ARROW TST D0
W_VSLIDE TST D0
 RTS

* ///--- *
* Name of Program/Subroutine:  W_MOVED
* Purpose/Description:
*  Handle a move window event message
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

W_MOVED MOVE EVMESG+6,D0
 CMP DEBUG_HANDLE,D0
 BEQ MOVE_DEBUG
 RTS

MOVE_DEBUG MOVE EVMESG+8,INTIN+4
 MOVE EVMESG+10,INTIN+6
 MOVE EVMESG+12,INTIN+8
 MOVE EVMESG+14,INTIN+10
 MOVE DEBUG_HANDLE,D0
 MOVE #5,D1
 JMP WIND_SET


* ///--- *
* Name of Program/Subroutine:  W_REDRAW
* Purpose/Description:
*  Redraw changed contents of a GEM window
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

W_REDRAW MOVE EVMESG+6,D0
 CMP DEBUG_HANDLE,D0
 BEQ REDRAW_DEBUG
 RTS


* Redraw the Debug window contents

REDRAW_DEBUG DC $A00A        ;Hide the mouse while opening the window

 MOVE EVMESG+8,P2_X          ;Save redraw area coordinates
 MOVE EVMESG+10,P2_Y         ;for later use
 MOVE EVMESG+12,P2_W
 MOVE EVMESG+14,P2_H

 MOVE #1,D0                  ;Tell GEM that we are about to redraw the
 JSR WIND_UPDATE             ;window, this stops any changes until we're done

 MOVE DEBUG_HANDLE,D0        ;Find the common area between the overall
 MOVE #4,D1                  ;update area and the content area of our
 JSR WIND_GET                ;window
 MOVE INTOUT+2,P1_X
 MOVE INTOUT+4,P1_Y
 MOVE INTOUT+6,P1_W
 MOVE INTOUT+8,P1_H
 MOVE INTOUT+2,WIND_LOC_X     ;For the text plotting code, find the
 MOVE INTOUT+4,WIND_LOC_Y     ;save the content area location of our window
 JSR RC_INTERSECT
 TST D0
 BNE RD_END
 MOVE P2_X,P1_X
 MOVE P2_Y,P1_Y
 MOVE P2_W,P1_W
 MOVE P2_H,P1_H

 MOVE DEBUG_HANDLE,D0         ;Get first window area rectangle from
 JSR WIND_GET_LIST            ;the window list

RD_LOOP TST D2                ;Any more window rectangles to check?
 BNE RD_MORE
 TST D3
 BEQ RD_END

RD_MORE MOVE D0,P2_X          ;Move the window rectangle coordinates
 MOVE D1,P2_Y                 ;into our variables.  Then check to see
 MOVE D2,P2_W                 ;if we need to redraw any of our window
 MOVE D3,P2_H
 JSR RC_INTERSECT
 TST D0
 BNE RD_AGAIN
 JSR DRAW_DEBUG               ;Do a clipped redraw of our window

RD_AGAIN MOVE DEBUG_HANDLE,D0 ;Get the next window rectangle
 JSR WIND_NEXT_LIST
 JMP RD_LOOP

RD_END CLR D0                 ;Tell GEM we're finished updating
 JSR WIND_UPDATE

 DC $A009                     ;Make mouse visible again
 RTS

* Draw the contents of the Debug window, clipped to the P2 coordinates

DRAW_DEBUG JSR NOCLIP         ;Disable clipping
 JSR TRANSOFF                 ;Use VDI replace drawing mode
 CLR D0                       ;Use background color
 JSR SETCOLOR
 MOVE #1,D0                   ;Use the solid fill pattern
 JSR SETFILL
 CLR D0                       ;Turn off the fill outline
 JSR FILLPERI
 MOVE P2_X,D0                 ;Load the rectangle coordinates
 MOVE P2_Y,D1
 MOVE D0,D2
 ADD P2_W,D2
 SUB #1,D2
 MOVE D1,D3
 ADD P2_H,D3
 SUB #1,D3
 JSR RECTANGLE                ;Clear the update region

 MOVE P2_X,D0                 ;Turn on clipping
 MOVE P2_Y,D1
 MOVE D0,D2
 ADD P2_W,D2
 SUB #1,D2
 MOVE D1,D3
 ADD P2_H,D3
 SUB #1,D3
 JSR SETCLIP

 JSR TEXTINIT                 ;Plot contents of window
 MOVE WIND_LOC_X,D0
 MOVE WIND_LOC_Y,D1
 ADD #8,D1
 LEA DEMES,A0
 JMP GEMTEXT


* ///--- *
* Name of Program/Subroutine: RC_INTERSECT
* Purpose/Description:
*  Calculate intersection area of two rectangles
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
*  P1_X,Y,W,H Rectangle coordinates
*  P2_X,Y,W,H Second rectangle coordinates
* Outputs:
*  P2_X,Y,W,H Intersection of source rectangles
*  D0 - 0 Rectangles intersect
*       1 Rectangles do not intersect
* ---\\\ *

RC_INTERSECT MOVE P2_X,D0
 ADD P2_W,D0
 MOVE P1_X,D1
 ADD P1_W,D1
 CMP D0,D1
 BCC RCI_MIN1
 MOVE D1,D0

RCI_MIN1 MOVE P2_Y,D1
 ADD P2_H,D1
 MOVE P1_Y,D2
 ADD P1_H,D2
 CMP D1,D2
 BCC RCI_MIN2
 MOVE D2,D1

RCI_MIN2 MOVE P2_X,D2
 MOVE P1_X,D3
 CMP D2,D3
 BCS RCI_MIN3
 MOVE D3,D2

RCI_MIN3 MOVE P2_Y,D3
 MOVE P1_Y,D4
 CMP D3,D4
 BCS RCI_MIN4
 MOVE D4,D3

RCI_MIN4 MOVE D2,P2_X
 MOVE D3,P2_Y

 MOVE D0,D4
 SUB D2,D4
 MOVE D4,P2_W

 MOVE D1,D4
 SUB D3,D4
 MOVE D4,P2_H

 CMP D0,D2
 BGE RCI_AGAIN
 CMP D1,D3
 BGE RCI_AGAIN

 CLR D0
 RTS

RCI_AGAIN MOVE #1,D0
 RTS


* ///--- *
* Name of Program/Subroutine:  W_MENU
* Purpose/Description:
*  Handle menu events
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

W_MENU MOVE #33,CONTRL        ;AES function: MENU_TNORMAL
 MOVE #2,CONTRL+2             ;Display menu title in reverse video
 MOVE #1,CONTRL+4             ;This resets the Menu Bar for the next
 MOVE #1,CONTRL+6             ;command.
 CLR CONTRL+8
 MOVE EVMESG+6,INTIN
 MOVE #1,INTIN+2
 MOVE.L MENU_TREE,ADDRIN
 JSR AES

 MOVE EVMESG+6,D0             ;D0 holds the menu title # selected
 MOVE EVMESG+8,D1             ;D1 holds the menu entry # selected

 CMP #MENU1,D0                ;DESK (Fuji symbol) menu chosen
 BEQ DODESK
 CMP #MENU2,D0                ;FILE drop-down menu chosen
 BEQ DOFILE
 CMP #MENU3,D0                ;EDIT drop-down menu chosen
 BEQ DOEDIT
 CMP #MENU4,D0                ;DIAGNOSTIC drop-down menu chosen
 BEQ DODIAG
 RTS


* ///--- *
* Name of Program/Subroutine:  DODESK
* Purpose/Description:
*  Handle DESK (Fuji Symbol) drop-down menu event
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

DODESK CMP #MABOUT,D1         ;Did user ask for ABOUT... information?       
 BNE NODESK

 MOVE.L ABOUT_TREE,A0         ;Reset the OK button in the About... dialog
 ADD.L #BABOUT*OBSIZE,A0      ;before displaying the dialog to the user.
 CLR OB_STATE(A0)

 MOVE.L ABOUT_TREE,A0         ;Run the About... dialog
 MOVE #-1,D0
 JMP FORMDO

NODESK RTS


* ///--- *
* Name of Program/Subroutine:  DOFILE
* Purpose/Description:
*  Handle FILE drop-down menu event
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

DOFILE CMP #MNEW,D1
 BEQ DONEW
 CMP #MOPEN,D1
 BEQ DOOPEN
 CMP #MCLOSE,D1
 BEQ DOCLOSE
 CMP #MSAVE,D1
 BEQ DOSAVE
 CMP #MSAVEAS,D1
 BEQ DOSAVEAS
 CMP #MSETUP,D1
 BEQ DOSETUP
 CMP #MPRINT,D1
 BEQ DOPRINT
 CMP #MQUIT,D1
 BEQ DOQUIT
 RTS

* The following labels have been established for consistency.  In
* a future chapter, these labels will be used in the block of source
* code that handes one of the above message events.

DONEW TST D0                  ;The TST commands are used to let the
DOOPEN TST D0                 ;the program execution fall through to
DOCLOSE TST D0                ;the RTS command below.
DOSAVE TST D0
DOSAVEAS TST D0
DOSETUP TST D0
DOPRINT TST D0
 RTS


* ///--- *
* Name of Program/Subroutine:  DOQUIT
* Purpose/Description:
*  Terminate application, return to Desktop or Shell
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

DOQUIT TST SAVE_FLAG          ;Has the user saved his work?
 BEQ QUIT_100

 MOVE #AREUSURE,D0            ;No, so ask him if his work should
 JSR GADDR2                   ;be saved first.  AREUSURE is a resource
 JSR DOALERT                  ;tree containing the definition of an alert
 CMP #2,D0                    ;The results are 1-Yes, 2-No, 3-Cancel
 BEQ QUIT_100
 CMP #3,D0
 BEQ NO_QUIT

* Add code here to save data
* before quitting

QUIT_100 MOVE #MS_BUSY,D0     ;Mouse is busy, no user events allowed
 JSR SHWMOUSE

 MOVE DEBUG_HANDLE,D0         ;Close Debug window
 JSR CLOSE_WINDOW

 MOVE #101,CONTRL             ;VDI function: V_CLSVWK
 CLR CONTRL+2                 ;Close Virtual Workstation
 CLR CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 JSR VDI

 MOVE #19,CONTRL              ;AES function: APPL_EXIT
 CLR CONTRL+2                 ;Let GEM clear up its working environment
 MOVE #1,CONTRL+4             ;before returning to the GEM Desktop
 CLR CONTRL+6
 CLR CONTRL+8
 JSR AES

QUICK_QUIT CLR -(A7)          ;GEMDOS function: P_TERM
 TRAP #1                      ;Exit to Shell

NO_QUIT RTS                   ;Don't quit, user cancelled quit command


* ///--- *
* Name of Program/Subroutine:  DOEDIT
* Purpose/Description:
*  Handle EDIT drop-down menu command
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  D1-menu item selected
* Outputs:
* ---\\\ *

DOEDIT CMP #MCUT,D1
 BEQ DOCUT
 CMP #MCOPY,D1
 BEQ DOCOPY
 CMP #MPASTE,D1
 BEQ DOPASTE
 CMP #MCLEAR,D1
 BEQ DOCLEAR
 CMP #MUNDO,D1
 BEQ DOUNDO
 RTS

* The following labels have been established for consistency.  In
* a future chapter, these labels will be used in the block of source
* code that handes one of the above message events.

DOCUT TST D0                  ;The TST commands are used to let the
DOCOPY TST D0                 ;the program execution fall through to
DOPASTE TST D0                ;the RTS command below.
DOCLEAR TST D0
DOUNDO TST D0
 RTS


* ///--- *
* Name of Program/Subroutine:  DODIAG
* Purpose/Description:
*  Handle DIAGNOSTIC drop-down menu command
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
*  D1 - Menu item selected
* Outputs:
* ---\\\ *

DODIAG CMP #MDIAGNOS,D1
 BEQ DODEBUG
 RTS


* ///--- *
* Name of Program/Subroutine:  DODEBUG
* Purpose/Description:
*  Open DIAGNOSTIC window
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

DODEBUG TST DEBUG_HANDLE      ;Is debug window open already?
 BNE DOD_END

 LEA DEBUG_NAME,A0            ;No, so open it and store the window
 MOVE #8,D0                   ;handle into the DEBUG_HANDLE variable
 MOVE #12,D1
 MOVE #400,D2
 MOVE #100,D3
 JSR OPEN_WINDOW
 MOVE D0,DEBUG_HANDLE

DOD_END RTS


* ///--- *
* Name of Program/Subroutine:  KEYEVENT
* Purpose/Description:
*  Handle keyboard event and drop-down menu keyboard equivalents
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

KEYEVENT MOVE EVKEY,D0        ;Handle drop-down menu keyboard equivalents
 MOVE D0,D1
 LSR #8,D1

 CMP.B #24,D0                 ;Ctrl X is always Cut
 BEQ DOCUT
 CMP.B #3,D0                  ;Ctrl C is always Copy
 BEQ DOCOPY
 CMP.B #22,D0                 ;Ctrl V is always Paste
 BEQ DOPASTE
 RTS


* ///--- *
* Name of Program/Subroutine:  BUTEVENT
* Purpose/Description:
*  Handle mouse-click events
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
* ---\\\ *

BUTEVENT RTS


* ///--- *
* Name of Program/Subroutine: OPEN_WINDOW
* Purpose/Description:
*  Open a GEM window
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
*  D0 - X coordinate of open window
*  D1 - Y coordinate of open window
*  D2 - Width of window
*  D3 - Height of window
*  A0 - Pointer to window title
* Outputs:
*  D0 - Window handle
* ---\\\ *

OPEN_WINDOW MOVE D0,OW_X         ;Store parameters
 MOVE D1,OW_Y
 MOVE D2,OW_W
 MOVE D3,OW_H
 MOVE.L A0,OW_NAME

 DC $A00A                     ;Hide the mouse while opening the window

 MOVE #100,CONTRL             ;AES function: WIND_CREATE
 MOVE #5,CONTRL+2             ;Let GEM establish a new window handle
 MOVE #1,CONTRL+4             ;with a greatest open size equal to the
 CLR CONTRL+6                 ;size of the desktop window
 CLR CONTRL+8
 MOVE #11,INTIN                ;Window will have a name, close box, and move
 MOVE GEMXPOS,INTIN+2
 MOVE GEMYPOS,INTIN+4
 MOVE GEMWIDTH,INTIN+6
 MOVE GEMHOEHE,INTIN+8
 JSR AES
 MOVE INTOUT,WIHANDLE

 MOVE.L OW_NAME,INTIN+4       ;AES function: SET_WIND
 MOVE #105,CONTRL             ;Set the window title name
 MOVE #6,CONTRL+2
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE WIHANDLE,INTIN
 MOVE #2,INTIN+2
 JSR AES

 MOVE #101,CONTRL             ;AES function: WIND_OPEN
 MOVE #5,CONTRL+2             ;Instruct GEM to open the window now
 MOVE #1,CONTRL+4             ;the initial size is found in our stored
 CLR CONTRL+6                 ;variables.
 CLR CONTRL+8
 MOVE WIHANDLE,INTIN
 MOVE OW_X,INTIN+2
 MOVE OW_Y,INTIN+4
 MOVE OW_W,INTIN+6
 MOVE OW_H,INTIN+8
 JSR AES

 DC $A009                     ;Show the mouse now that everything is finished
 MOVE WIHANDLE,D0
 RTS

WIHANDLE DS 1                 ;Temporary window storage
OW_X DS 1
OW_Y DS 1
OW_W DS 1
OW_H DS 1
OW_NAME DS.L 1


* ///--- *
* Name of Program/Subroutine: CLOSE_WINDOW
* Purpose/Description:
*  Close and remove a GEM window
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
*  D0 - Window handle
* Outputs:
* ---\\\ *

CLOSE_WINDOW TST D0           ;Is this a valid window handle?
 BEQ CLO_END
 MOVE D0,-(A7)                ;Yes, save window handle for a little while

 DC $A00A                     ;Hide the mouse until the window is gone

 MOVE #102,CONTRL             ;AES function: WIND_CLOSE
 MOVE #1,CONTRL+2             ;Instruct GEM to close an open window
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE (A7)+,INTIN
 JSR AES

 MOVE #103,CONTRL             ;AES function: WIND_DELETE
 MOVE #1,CONTRL+2             ;Free the space occipied by the window
 MOVE #1,CONTRL+4             ;and release the window handle
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE WIHANDLE,INTIN
 JSR AES

 DC $A009                     ;Show the mouse now that everything is finished

CLO_END RTS





* ///--- *
* Name of Program/Subroutine: WIND_GET_LIST
* Purpose/Description:
*  Find next window area rectangle in window list
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
*  D0 - Window handle
* Outputs:
*  D0 - X location
*  D1 - Y location
*  D2 - W width
*  D3 - H height
* ---\\\ *

WIND_GET_LIST
 MOVE #104,CONTRL              ;AES function: WIND_GET
 MOVE #2,CONTRL+2              ;Get first rectangle in window list
 MOVE #5,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN
 MOVE #11,INTIN+2
 JSR AES
 MOVE INTOUT+2,D0
 MOVE INTOUT+4,D1
 MOVE INTOUT+6,D2
 MOVE INTOUT+8,D3
 RTS


* ///--- *
* Name of Program/Subroutine: WIND_NEXT_LIST
* Purpose/Description:
*  Find next window area rectangle in window list
* Creation Date:  October 14, 1989
* Modification History:
* Inputs:
*  D0 - Window handle
* Outputs:
*  D0 - X location
*  D1 - Y location
*  D2 - W width
*  D3 - H height
* ---\\\ *

WIND_NEXT_LIST
 MOVE #104,CONTRL              ;AES function: WIND_GET
 MOVE #2,CONTRL+2              ;Get first rectangle in window list
 MOVE #5,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN
 MOVE #12,INTIN+2
 JSR AES
 MOVE INTOUT+2,D0
 MOVE INTOUT+4,D1
 MOVE INTOUT+6,D2
 MOVE INTOUT+8,D3
 RTS


* ///--- *
* Name of Program/Subroutine:  MENU_ENABLE
* Purpose/Description:
*  Enable a group of menus
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  A0 - Pointer to byte aligned list of menus to enable
* Outputs:
* ---\\\ *

MENU_ENABLE CLR.L D0
 MOVE.B (A0)+,D0
 TST.B D0
 BEQ ME_END
 MULU #OBSIZE,D0
 ADD.L MENU_TREE,D0
 MOVE.L D0,A1
 AND #$FFF7,OB_STATE(A1)
 JMP MENU_ENABLE
ME_END RTS


* ///--- *
* Name of Program/Subroutine:  MENU_DISABLE
* Purpose/Description:
*  Disable a group of menus
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  A0 - Pointer to byte aligned list of menus to disable
* Outputs:
* ---\\\ *

MENU_DISABLE CLR.L D0
 MOVE.B (A0)+,D0
 TST.B D0
 BEQ MD_END
 MULU #OBSIZE,D0
 ADD.L MENU_TREE,D0
 MOVE.L D0,A1
 OR #8,OB_STATE(A1)
 JMP MENU_DISABLE
MD_END RTS


* ///--- *
* Name of Program/Subroutine:  VALIDATE
* Purpose/Description:
*  Check for selected drop-down menu.  If a menu is pulled down
*  but not selected, the program must wait until the user clicks
*  a command or exits the drop-down menu.
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
*  D0 = 0 if no drop-down menus are pulled down
* ---\\\ *

VALIDATE MOVE.L MENU_TREE,A0  ;Test the OB_STATE flag of each
 MOVE.L A0,A1                 ;drop-down menu title object
 ADD #MENU1*OBSIZE,A1
 TST OB_STATE(A1)
 BNE VALIDNO

 MOVE.L A0,A1
 ADD #MENU2*OBSIZE,A1
 TST OB_STATE(A1)
 BNE VALIDNO

 MOVE.L A0,A1
 ADD #MENU3*OBSIZE,A1
 TST OB_STATE(A1)
 BNE VALIDNO

* Add more tests here if you have more than 3 drop-down menus

 CLR D0
 RTS

VALIDNO MOVE #-1,D0
 RTS


* ///--- *
* Name of Program/Subroutine:  SHWMOUSE
* Purpose/Description:
*  Change mouse shape
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  D0 - Mouse image number
* ---\\\ *

MS_ARROW EQU 0
MS_TEXT EQU 1
MS_BUSY EQU 2
MS_FINGER EQU 3
MS_HAND EQU 4
MS_CROSS EQU 5
MS_THICK EQU 6
MS_OUTLINE EQU 7

SHWMOUSE MOVE #78,CONTRL      ;AES function: GRAF_MOUSE
 MOVE #1,CONTRL+2             ;Change mouse shape
 MOVE #1,CONTRL+4
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN ;MOUSE IMAGE
 CLR.L ADDRIN
 JSR AES
 DC $A009  ;SHOW MOUSE
 RTS


* ///--- *
* Name of Program/Subroutine:  FORMDO
* Purpose/Description:
*  Run a dialog, handle user events until an
*  exit or default button is selected.
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  A0 - Pointer to dialog tree structure
*  D0 - Default Edit field object number
* Outputs:
*  D0 - Object number that caused termination
* ---\\\ *

FORMDO MOVE.L A0,FORMDIAL     ;Save parameters for later use
 MOVE D0,FORMEDIT

 DC $A00A                     ;Hide the mouse pointer

 MOVE #54,CONTRL              ;AES function: FORM_CENTER
 CLR CONTRL+2                 ;Find screen coordinates that place the
 MOVE #5,CONTRL+4             ;dialog window in the center of the screen
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE.L FORMDIAL,ADDRIN
 JSR AES
 MOVE INTOUT+2,DIALX
 MOVE INTOUT+4,DIALY
 MOVE INTOUT+6,DIALW
 MOVE INTOUT+8,DIALH

 MOVE #51,CONTRL              ;AES function: FORM_DIAL
 MOVE #9,CONTRL+2             ;Reserve the screen space under the dialog
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 CLR INTIN
 MOVE SHRINK,INTIN+2
 MOVE SHRINK+2,INTIN+4
 MOVE SHRINK+4,INTIN+6
 MOVE SHRINK+6,INTIN+8
 MOVE INTOUT+2,INTIN+10
 MOVE INTOUT+4,INTIN+12
 MOVE INTOUT+6,INTIN+14
 MOVE INTOUT+8,INTIN+16
 JSR AES

 MOVE #1,INTIN                ;AES function: FORM_DIAL
 JSR AES                      ;Animate dialog window opening

 MOVE #42,CONTRL              ;AES function: OBJC_DRAW
 MOVE #6,CONTRL+2             ;Draw dialog window contents on screen
 MOVE #1,CONTRL+4
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 CLR INTIN
 MOVE #100,INTIN+2
 MOVE GEMXPOS,INTIN+4
 MOVE GEMYPOS,INTIN+6
 MOVE GEMWIDTH,INTIN+8
 MOVE GEMHOEHE,INTIN+10
 MOVE.L FORMDIAL,ADDRIN
 JSR AES

 DC $A009                     ;Make the mouse pointer visible

 MOVE #50,CONTRL              ;AES function: FORM_DO
 MOVE #1,CONTRL+2             ;Run the dialog, handle all events, return
 MOVE #1,CONTRL+4             ;when an exit object has been selected
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE FORMEDIT,INTIN
 MOVE.L FORMDIAL,ADDRIN
 JSR AES
 MOVE INTOUT,SAVERTRN

 DC $A00A                     ;Bye, Bye Mr. Mouse

 MOVE #51,CONTRL              ;AES function: FORM_DIAL
 MOVE #9,CONTRL+2             ;Animate the dialog window closing
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE #2,INTIN
 MOVE SHRINK,INTIN+2
 MOVE SHRINK+2,INTIN+4
 MOVE SHRINK+4,INTIN+6
 MOVE SHRINK+6,INTIN+8
 MOVE DIALX,INTIN+10
 MOVE DIALY,INTIN+12
 MOVE DIALW,INTIN+14
 MOVE DIALH,INTIN+16
 JSR AES

 MOVE #3,INTIN                ;AES function: FORM_DIAL
 JSR AES                      ;Free the screen space

 DC $A009                     ;Make the mouse visible again

 MOVE SAVERTRN,D0             ;Return the selected object number
 RTS


* ///--- *
* Name of Program/Subroutine:  DOALERT
* Purpose/Description:
*  Run an alert
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  A0 = Pointer to alert object tree
* Outputs:
*  D0 = 0 object that terminated alert
* ---\\\ *

DOALERT MOVE #52,CONTRL
 MOVE #1,CONTRL+2
 MOVE #1,CONTRL+4
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE #1,INTIN
 MOVE.L A0,ADDRIN
 JSR AES
 MOVE INTOUT,D0
 RTS


* ///--- *
* Name of Program/Subroutine:  GT_EVENT
* Purpose/Description:
*  Get next GEM evenut
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  D0 = Event mask, see Concise Guide, Pg 5.10
* Outputs:
* EVMESG buffer filled with message
* Other EV... variables filled with event information
* ---\\\ *

GT_EVENT MOVE #25,CONTRL      ;AES function: Event_Multi
 MOVE #16,CONTRL+2            ;Wait for the new GEM event
 MOVE #7,CONTRL+4
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN
 MOVE #2,INTIN+2
 MOVE #1,INTIN+4
 MOVE #1,INTIN+6
 MOVE #200,INTIN+28
 MOVE #0,INTIN+30
 MOVE.L #EVMESG,ADDRIN
 JSR AES
 MOVE INTOUT,EVWHICH
 MOVE INTOUT+2,EVXPOS
 MOVE INTOUT+4,EVYPOS
 MOVE INTOUT+6,EVBUTN
 MOVE INTOUT+8,EVSTATE
 MOVE INTOUT+10,EVKEY
 MOVE INTOUT+12,EVBSTAT
 MOVE INTOUT+14,EVHEIGH
 RTS

EVMESG DC.L 0,0,0,0,0,0
EVWHICH DC 0
EVXPOS DC 0
EVYPOS DC 0
EVBUTN DC 0
EVSTATE DC 0
EVKEY DC 0
EVBSTAT DC 0
EVHEIGH DC 0



* ///--- *
* Name of Program/Subroutine:  CHECKMODE
* Purpose/Description:
*  Program will not run in low resolution mode
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
*  D0 = 0 if no errors
*  GRMODE flag set 1-Medium, 2-High resolution
* ---\\\ *

CHECKMODE  MOVE #4,-(A7)      ;XBIOS function: _getRez
 TRAP #14
 ADD #2,A7
 MOVE D0,GRMODE
 TST D0
 BNE MD_GOOD

 MOVE #ABADMODE,D0            ;Display low resolution alert
 JSR GADDR2
 JSR DOALERT
 MOVE #-1,D0
 RTS

MD_GOOD CLR D0                ;Return with good status
 RTS


* ///--- *
* Name of Program/Subroutine:  RESOURCE
* Purpose/Description:
*  Load resource file
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  A0 pointer to resrouce file name
*  A1 pointer to address tree
* Outputs:
*  D0 = 0 if no errors
* ---\\\ *

RESOURCE MOVE.L A1,A4

 MOVE #110,CONTRL             ;AES function: RSRC_LOAD
 CLR CONTRL+2                 ;Load the resource file into memory
 MOVE #1,CONTRL+4
 MOVE #1,CONTRL+6
 CLR CONTRL+8
 MOVE.L A0,ADDRIN
 JSR AES
 MOVE #-1,D0                  ;Return an error code
 TST INTOUT                   ;Check for errors
 BEQ G_END

G_100 MOVE.L (A4),D0          ;Find resource tree addresses.
 TST.L D0                     ;The resource tree contains the
 BMI G_DONE                   ;resource ID number and a location
 JSR GADDR                    ;in memory that will hold the found
 MOVE.L 4(A4),A1              ;address.
 MOVE.L A0,(A1)
 ADD.L #8,A4
 JMP G_100

G_DONE CLR D0                 ;Everything's hunky-doree

G_END RTS


* ///--- *
* Name of Program/Subroutine:  GADDR
* Purpose/Description:
*  Find memory address of tree in the loaded resource file.
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  D0 - Tree number from resrouce file
* Outputs:
*  A0 - Pointer to object tree
* ---\\\ *

GADDR CLR INTIN
 BRA GADDR3

GADDR2 MOVE #5,INTIN

GADDR3 MOVE #112,CONTRL       ;AES function: RSRC_GADDR
 MOVE #2,CONTRL+2             ;Get resource address
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 MOVE #1,CONTRL+8
 MOVE D0,INTIN+2
 JSR AES
 MOVE.L ADDROUT,A0
 RTS


* ///--- *
* Name of Program/Subroutine:  GETPATH
* Purpose/Description:
*  Find the default folder name
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
*  Default path is stored in PATHNAME buffer
* ---\\\ *

GETPATH LEA PATHNAME,A4

 MOVE #25,-(A7)                ;GEMDOS function: D_GETDRV
 TRAP #1                       ;Returns current drive number
 ADD.L #2,A7
 ADD.B #'A',D0
 MOVE.B D0,(A4)+
 MOVE.B #':',(A4)+

 CLR -(A7)                     ;GEMDOS function: D_GETPATH
 MOVE.L #PATHNAME+2,-(A7)      ;Finds current folder name, stores
 MOVE #71,-(A7)                ;it directly into our PATHNAME buffer
 TRAP #1
 ADD.L #8,A7

 MOVE #117,D0                  ;Find the end of the folder name
FCPATH_100 TST.B (A4)+
 BEQ FCPATH_101
 DBF D0,FCPATH_100

FCPATH_101 SUB #1,A4           ;Add \*.* to complete the path name
 MOVE.B #'\',(A4)+
 MOVE.B #'*',(A4)+
 MOVE.B #'.',(A4)+
 MOVE.B #'*',(A4)+
 CLR.B (A4)+
 RTS


* ///--- *
* Name of Program/Subroutine:  ADDPATH
* Purpose/Description:
*  Add path name to standard file name
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
*  A0 pointer to file name
* Outputs:
*  A0 pointer to PTHNM buffer containing file name
* ---\\\ *

ADDPATH MOVEM.L A1-A4/D0-D2,-(A7)  ;Save effected registers

 MOVE.L #39,D1            ;Copy default folder info
 LEA PATHNAME,A1
 LEA PTHNM,A2
ADDP101 MOVE.B (A1)+,D0
 CMP.B #' ',D0
 BEQ ADDP102
 CMP.B #'*',D0
 BEQ ADDP102
 CMP.B #13,D0
 BEQ ADDP102
 TST.B D0
 BEQ ADDP102
 MOVE.B D0,(A2)+
 DBF D1,ADDP101

ADDP102 MOVE.B (A0)+,D0   ;Copy file name
 CMP.B #13,D0
 BEQ ADDP103
 TST.B D0
 BEQ ADDP103
 MOVE.B D0,(A2)+
 DBF D1,ADDP102

ADDP103 LEA PTHNM,A0

 MOVEM.L (A7)+,A1-A4/D0-D2 ;Restore saved registers
 RTS


* ///--- *
* Name of Program/Subroutine:  FIND_TAIL
* Purpose/Description:
*  The GEM Desktop supports a function called INSTALL APPLICATION.
*  It is typically used to link a word processor document to the
*  word processing application.  For example, you could establish
*  any files ending in .RGT to be Regent Word 2 documents.  When
*  you double-click or OPEN a document with an extension .RGT, the
*  GEM Desktop runs Regent Word 2 passing the file name of the
*  document to be opened.  Well behaved GEM applications (like this
*  one) support this GEM Desktop feature.
* Creation Date:  August 11, 1989
* Modification History:
* Inputs:
* Outputs:
*  Command tail stored in COMDBUFF
*  Document file name stored in FILENAME buffer
*  TAILFLAG=1 if parameters are found
* ---\\\ *

FIND_TAIL MOVE #120,CONTRL   ;AES function: SHEL_READ
 CLR CONTRL+2                ;Find the application name that calling
 MOVE #1,CONTRL+4            ;this program.  Also find the parameters
 MOVE #2,CONTRL+6            ;sent to this program.  Store the results
 CLR CONTRL+8                ;in the COMDBUFF and COMTAIL buffers.
 MOVE.L #COMDBUFF,ADDRIN
 MOVE.L #COMTAIL,ADDRIN+4
 JSR AES

 CLR TAILFLAG                ;Default is no

 LEA FILENAME,A1             ;Search COMTAIL buffer to see if a
 LEA COMTAIL,A0              ;valid parameter was passed to this
 MOVE.B (A0)+,D1             ;application
 TST.B D1
 BEQ TAIL2

TAIL1 MOVE.B (A0)+,D0        ;If a parameter has been passed, parse
 TST.B D0                    ;the parameter and store it as a valid
 BEQ TAIL2                   ;file name in the FILENAME buffer.
 CMP.B #13,D0
 BEQ TAIL2
 CMP.B #' ',D0
 BEQ TAIL2
 MOVE.B D0,(A1)+
 MOVE #1,TAILFLAG
 DBF D1,TAIL1

TAIL2 CLR.B (A1)+
 RTS


* ///--- *
* Name of Program/Subroutine:  AES/VDI SUPPORT
* Purpose/Description:
*  A collection of subroutines that instruct the GEM
*  AES or VDI systems to change certain parameters
* Creation Date:  August 11, 1989
* Modification History:
* ---\\\ *

*---------GET WINDOW INFORMATION-----------
* D0 Window Handle
* D1 Get window command
WIND_GET MOVE #104,CONTRL
 MOVE #2,CONTRL+2
 MOVE #5,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN
 MOVE D1,INTIN+2
 JMP AES

*---------SET WINDOW INFORMATION-----------
* D0 Window Handle
* D1 Get window command
WIND_SET MOVE #105,CONTRL
 MOVE #6,CONTRL+2
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN
 MOVE D1,INTIN+2
 JMP AES

*---------WINDOW UPDATE STATUS-----------
* D0 1-Begin update, 0-End update
WIND_UPDATE MOVE #107,CONTRL
 MOVE #1,CONTRL+2
 MOVE #1,CONTRL+4
 CLR CONTRL+6
 CLR CONTRL+8
 MOVE D0,INTIN
 JMP AES

*---------SET FILL COLOR INDEX-----------
SETCOLOR MOVE #25,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN   ;COLOR REG
 JMP VDI

*--------SET FILL INTERIOR STYLE---------
SETFILL MOVE #23,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN   ;0=HALLOW 1=SOLID 2=PATTERN 3=HATCH 4=USER DEF
 JMP VDI

*--------SET FILL PERIMETER FLAG---------
FILLPERI MOVE #104,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*---------SET FILL STYLE INDEX-----------
SETINDEX MOVE #24,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN   ;SEE PG 5-33 OF GEM MANUAL
 JMP VDI

*---------DRAW FILLED RECTANGLE----------
RECTANGLE MOVE #114,CONTRL
 MOVE #2,CONTRL+2
 CLR CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,PTSIN   ;X1
 MOVE D1,PTSIN+2 ;Y1
 MOVE D2,PTSIN+4 ;X2
 MOVE D3,PTSIN+6 ;Y2
 JMP VDI

*-------------SET LINE TYPE--------------
LINETYPE MOVE #15,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*-------------SET USER LINE--------------
LINESTYL MOVE #113,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*------------SET LINE WIDTH--------------
LINEWIDE MOVE #16,CONTRL
 MOVE #1,CONTRL+2
 CLR CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,PTSIN
 CLR PTSIN+2
 JMP VDI

*------------SET LINE MARKER-------------
LINEMARK MOVE #18,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*------------SET LINE END-------------
LINEEND MOVE #108,CONTRL
 CLR CONTRL+2
 MOVE #2,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 MOVE D1,INTIN+2
 JMP VDI

*-------------DRAW POLYLINE--------------
DRAWPOLY MOVE #6,CONTRL
 MOVE #5,CONTRL+2
 CLR CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,PTSIN
 MOVE D1,PTSIN+2

 MOVE D0,PTSIN+4
 ADD D2,PTSIN+4
 MOVE D1,PTSIN+6

 MOVE D0,PTSIN+8
 ADD D2,PTSIN+8
 MOVE D1,PTSIN+10
 ADD D3,PTSIN+10

 MOVE D0,PTSIN+12
 MOVE D1,PTSIN+14
 ADD D3,PTSIN+14

 MOVE D0,PTSIN+16
 MOVE D1,PTSIN+18

 JMP VDI

*-------------DRAW POLYLINE MARKER--------------
DMXSIZE EQU 5
DMYSIZE EQU 2

DRAWMARK SUB #2,D0
 SUB #2,D2
 SUB #2,D3

 MOVE D0,DMORG
 MOVE D1,DMORG+2
 MOVE D2,DMORG+4
 MOVE D3,DMORG+6

 JSR TRANSRV
 MOVE #1,D0
 JSR SETCOLOR
 MOVE #1,D0
 JSR SETFILL
 CLR D0
 JSR FILLPERI

 MOVE DMORG,D0
 MOVE DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG+4,D0
 LSR #1,D0
 ADD DMORG,D0
 MOVE DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG+4,D0
 ADD DMORG,D0
 MOVE DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG+4,D0
 ADD DMORG,D0
 MOVE DMORG+6,D1
 LSR #1,D1
 ADD DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG+4,D0
 ADD DMORG,D0
 MOVE DMORG+6,D1
 ADD DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG+4,D0
 LSR #1,D0
 ADD DMORG,D0
 MOVE DMORG+6,D1
 ADD DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG,D0
 MOVE DMORG+2,D1
 ADD DMORG+6,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JSR DORECT

 MOVE DMORG,D0
 MOVE DMORG+6,D1
 LSR #1,D1
 ADD DMORG+2,D1
 MOVE #DMXSIZE,D2
 MOVE #DMYSIZE,D3
 JMP DORECT

DORECT ADD D0,D2
 ADD D1,D3
 JMP RECTANGLE

*-----------------DRAW LINE-------------------
DRAWLINE MOVE #6,CONTRL
 MOVE #2,CONTRL+2
 CLR CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,PTSIN
 MOVE D1,PTSIN+2
 MOVE D0,PTSIN+4
 MOVE D1,PTSIN+6
 ADD D3,PTSIN+6
 JMP VDI

*--------------SET DRAWING COLOR--------------
TEXTINIT CLR D0
 JSR GEMFX
 MOVE #9,D0
 CMP #2,GRMODE
 BNE ELTON
 MOVE #10,D0
ELTON JSR GEMTSIZE
 MOVE #1,D0
 JMP GEMCOLOR

*--------------SET DRAWING COLOR--------------
GEMCOLR MOVE #17,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*---------SET VDI DRAWING TO MODE TO XOR-------
TRANSXOR MOVE #32,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE #3,INTIN
 JMP VDI

*-------SET VDI DRAWING TO MODE TO OVERWRITE------
TRANSOFF MOVE #32,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE #1,INTIN
 JMP VDI

*-------SET VDI DRAWING TO MODE TO TRANSPARENT------
TRANSON MOVE #32,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE #2,INTIN
 JMP VDI

*-------SET VDI DRAWING TO MODE TO REVERSE------
TRANSRV MOVE #32,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE #3,INTIN
 JMP VDI

*-------------TURN OFF CLIPPING----------
NOCLIP MOVE #129,CONTRL
 MOVE #2,CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 CLR INTIN
 JMP VDI

*-------------TURN CLIPPING ON----------
SETCLIP MOVE #129,CONTRL
 MOVE #2,CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE #1,INTIN
 MOVE D0,PTSIN
 MOVE D1,PTSIN+2
 MOVE D2,PTSIN+4
 MOVE D3,PTSIN+6
 JMP VDI

*------SET EFFECTS FOR VDI TEXT CALLS--------
* 0-BOLD 1-INTENSITY 2-ITALICS 3-UNDERLINE 4-OUTLINE 5-SHADOW
GEMFX MOVE #106,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*-------SET SIZE FOR VDI TEXT CALLS---------
* D0 = POINT SIZE
GEMTSIZE MOVE #107,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*-------SET COLOR FOR VDI TEXT CALLS---------
* D0 = COLOR #
GEMCOLOR MOVE #22,CONTRL
 CLR CONTRL+2
 MOVE #1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 MOVE D0,INTIN
 JMP VDI

*----------GEM TEXT PRINT SETUP-----------
* D0=XPOS D1=YPOS A0=PTR
GEMTEXT MOVE D0,PTSIN
 MOVE D1,PTSIN+2

 LEA INTIN,A1
 CLR.L D1
GEMT101 CLR.L D0
 MOVE.B (A0)+,D0
 BEQ GEMT100
 MOVE D0,(A1)+
 ADD #1,D1
 JMP GEMT101

GEMT100 CLR.B (A1)
 MOVE #8,CONTRL
 MOVE #1,CONTRL+2
 MOVE D1,CONTRL+6
 MOVE GRHANDLE,CONTRL+12
 JMP VDI

*-----------------SYSTEM CALLS-----------------
AES MOVE.L #AESPB,D1  ;CALL AES
 MOVE.L #200,D0
 TRAP #2
 RTS

VDI MOVE.L #VDIPB,D1  ;CALL VDI
 MOVE.L #$73,D0
 TRAP #2
 RTS

AESPB DC.L CONTRL,GLOBAL,INTIN,INTOUT,ADDRIN,ADDROUT
VDIPB DC.L CONTRL,INTIN,PTSIN,INTOUT,PTSOUT


* ///--- *
* Static Storage

* Example Linked List

LINKED_LIST
 DC.L SENTENCE_1
 DC SENTENCE_2-SENTENCE_1
 DC 0,2

 DC.L SENTENCE_2
 DC SENTENCE_3-SENTENCE_2
 DC 0,2

 DC.L SENTENCE_3
 DC SENTENCE_4-SENTENCE_3
 DC 0,2

 DC.L SENTENCE_4
 DC SENTENCE_5-SENTENCE_4
 DC 0,2

SENTENCE_1 DC.B 'A bug lept from the screen.',0
SENTENCE_2 DC.B 'It danced the Watoosee.',0
SENTENCE_3 DC.B 'Then it jumped into the keyboard.',0
SENTENCE_4 DC.B 'Why can I not use my keyboard?',0
SENTENCE_5 DC.B 0

DEMES DC.B 'This is the debugging window',0
DEBUG_NAME DC.B 'Debug Information',0  ;Debug window name
RSCNAME DC.B 'SKELETON.RSC',0 ;Resource file name
 EVEN

MENU_ALL DC.B MNEW,MOPEN,MCLOSE,MSAVE,MSAVEAS,MSETUP,MPRINT
 DC.B MCUT,MCOPY,MPASTE,MCLEAR,MUNDO,0

G_TREE DC.L DABOUT,ABOUT_TREE
 DC.L MENUS,MENU_TREE
 DC.L -1

* ---\\\ *

 BSS

* ///--- *
* GEM Parameter Blocks
GEMSTART DS 1
CONTRL DS 1
OPCODE EQU CONTRL
SINTIN DS 1
SINTOUT DS 1
SADDRIN DS 1
SADDROUT DS.L 5
GLOBAL DS 1
APCOUNT DS 1
APID DS 1
APPRIVATE DS.L 1
APPTREE DS.L 1
AP1RESV DS.L 1
AP2RESV DS.L 1
AP3RESV DS.L 1
AP4RESV DS.L 1
INTIN DS.L 80
PTSIN DS.L 32
INTOUT DS.L 32
PTSOUT DS.L 32
ADDRIN DS.L 32
ADDROUT DS.L 32
GRHANDLE DS 1
DRHANDLE DS 1

FORMDIAL DS.L 1
FORMEDIT DS 1
SAVERTRN DS 1
DIALX DS 1
DIALY DS 1
DIALW DS 1
DIALH DS 1
GEMXPOS DS 1
GEMYPOS DS 1
GEMWIDTH DS 1
GEMHOEHE DS 1
DMORG DS 8
SHRINK DS 8
GRMODE DS 1
GEMEND DS 1
* ---\\\ *

* ///--- *
* Application Variables

MENU_TREE DS.L 1              ;Resource object tree address storage
ABOUT_TREE DS.L 1

TAILFLAG DS 1                 ;Command tail storage
COMDBUFF DS.B 128
COMTAIL DS.B 128
FILENAME DS.B 128
 EVEN

PTHNM DS.B 40                 ;Path (folder) name storage
PATHNAME DS.B 40
 EVEN

SAVE_FLAG DS 1                ;Save changes flag

DEBUG_HANDLE DS 1             ;Diagnosis window handle

P1_X DS 1                     ;Window redraw variables
P1_Y DS 1
P1_W DS 1
P1_H DS 1
P2_X DS 1
P2_Y DS 1
P2_W DS 1
P2_H DS 1
WIND_LOC_X DS 1
WIND_LOC_Y DS 1

* ---\\\ *


* ///--- *
* Stack Storage Area
 EVEN
 DS.B 4000
USTK DS 1
 EVEN
* ---\\\ *

 END
