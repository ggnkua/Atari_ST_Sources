;-----------------------------------------------------------------------;
; Function: Non-modal dialog-boxes.
; Date    : 12.03.95
; By      : Thomas Nilsen
; <> 19½96 STand Software <>
 ;-----------------------------------------------------------------------;
; The purpose of this source is to give an example of how to handle 
; dialog-boxes in a window to make it multitasking-compatible.
; At this state the routine works perfectly, except for some minor
; problems regarding clipping. I have not added EVNT_KEYBD in the 
; EVNT_MULTI loop, and only a simple check for RETURN is done by 
; reading the INTOUT+10 variable  after the EVNT_MULTI-call is finnished.
; This code is not written with multiple window in mind, and it is only
; based on the idea to show how to preform non-modal programming 
; structure.
; 
; Another area where this source should be improved is the part where we
; check and execute the the routines based on what EVNT_MULTI returns.
; In this version a BRA (BEQ) is done, but if we where to make it 100% 
; correct, a BSR should be used instead. That way we make sure every 
; occurence reported by EVNT_MULTI is handled.
;
; This source is bases on a small RSC consisting of one DIALOG-tree.
; The tree itself consist of one TOUCHEXIT button and one EXIT button.
; Alter the "equ" lines to fit your own RSC.
;
; And a WARNING at the end:
; This is my first attempt ever to deal with windows in any language.
; Some parts of this code might be unfriendly with the system, but
; I have tried to do my best to follow the roules (as given in 
; The Compendium). Any ideas, bug-report, suggestions etc is 
; appreciated. I love FEEDBACK!
;
; Share and Enjoy!
; Thomas N.
;
; NeST: 90:1400/108 - AtariNet: 51:1401/108 - FidoNet: 2:211/8
;-----------------------------------------------------------------------;
; Devpac 3 used.
; Optimize ON
; Optimeze warnings OFF
; Debug-symbols ON
; Symbols OFF
; Long Debug symbols ON
; Tab set to 8
 
		OPT O+,OW-,D+,S-,XDEBUG
		
FORM1:	equ	0   /* Formular/Dialog */
EXIT:	equ	1   /* BUTTON in Baum FORM1 */
EXIT2:	equ	2   /* BUTTON In Baum FORM1 */
Win:	equ	%000000001011	; Window parameter (Closer, title, mover)
		
Header:		movea.l sp,a5		; Save a7 in a5
		lea	UStk(pc),sp	; Stack pointer to our stack
		movea.l 4(a5),a5	; Base page address
		move.l	12(a5),d0	; Base page offset to text length
		add.l	20(a5),d0	; Base page offset to data length
		add.l	28(a5),d0	; Base page offset to BSS length
		add.l	#$100,d0	; Add som extra
		move.l	d0,-(sp)	; Size to keep
		move.l	a5,-(sp)	; From adress
		clr.w	-(sp)		; Dummy value
		move.w	#$4a,-(sp)	; CODE : Setblock
		trap	#1		; Call Gemdos
		lea	12(sp),sp	;

		move.w	#4,-(sp)	; GetRes - needed(?) for V_OPNVWK
		trap	#1
		lea	2(sp),sp
		move.w	d0,Res
		
		clr.b	ExitStatus
		move.l	#Appl_Init,Aespb
		bsr	Aes
		move.w	IntOut,Ap_Id	; Store App_id

		move.l	#Graf_Handle,Aespb ; Get VDI Handle
		bsr	Aes
		move.w	IntOut,Gr_Handle ; Store it
		
		moveq.l	#-2,d0
		trap	#2	;  Check for GDOS
		addq.w	#2,d0
		beq.b	NoGDOS
		move.w	Res,d0
		addq.w	#2,d0
		move.w	d0,IntIn
		bra.b	_GDOS

NoGDOS:		move.w	#1,IntIn
_GDOS:		move.w	#100,Contrl	; Opcode : V_OPNVWK
		move.w	#0,Contrl+2	; Number of Vertices in ptsin
		move.w	#11,Contrl+6	; Number of parameters in IntIn
		move.w	Gr_Handle,Contrl+12 ; Device Handle
		move.w	#1,IntIn+2	; Line type
		move.w	#1,IntIn+4	; Colour of line
		move.w	#1,IntIn+6	; Type of marking
		move.w	#1,IntIn+8	; Color of marking
		move.w	#1,IntIn+10	; Character set
		move.w	#1,IntIn+12	; Text colour
		move.w	#1,IntIn+14	; fill type
		move.w	#1,IntIn+16	; Fill pattern index
		move.w	#1,IntIn+18	; Fill colour
		move.w	#2,IntIn+20	; Coordinate flag
		bsr	Vdi
		move.w	Contrl+12,Ws_Handle ; Store vw. handle
		
		move.l	#RSC_Load,Aespb	 ; AES Load File
		move.l	#RSC_File,AddrIn ; RSC File to load
		bsr	Aes
		cmpi.w	#0,IntOut	; RSC file loaded ?
		beq	EndIt2
		
		move.l	#RSC_Gaddr,Aespb ; Get address of RSC tree
		move.w	#0,IntIn
		move.w	#FORM1,IntIn+2 ; Get first object (Menu)
		bsr	Aes
		tst.w	IntOut
		beq	EndIt
		movea.l AddrOut(pc),a5	; Place address in parent
		move.l	AddrOut(pc),Parent

		bsr	Form_Center	; Get coords for dialog-box 
					; (Cx,Cy,Cw,Ch)

		move.w	#0,IntIn	; Request WC_Border
		move.w	#Win,IntIn+2	; Select "widgets"
		movem.w	Cx,d0-3		; Get size-values from RSC
		movem.w	d0-3,IntIn+4	; Pass them on...
		bsr	Wind.Calc	; Calculate window size
		tst.w	IntOut		; 0 = Error
		beq.w	EndIt1
	
		movem.w	IntOut+2,d0-3	; Coords allocated for our window
		movem.w	d0-3,Wx		; Store them
		
		move.w	#Win,IntIn	; Window gadgets
		movem.w	d0-3,IntIn+2	; Coords still in d0-3 
		bsr	Wind.Create	; Create window
		move.w	IntOut,W_Handle	; Save window handle
		tst.w	IntOut		; =0 if error
		bmi.w	EndIt1
		
		move.w	W_Handle,IntIn	; Our window
		move.w	#2,IntIn+2	; Set window name
		move.l	#WinTitle,IntIn+4 ; Name to use
		clr.l	IntIn+8		; both +8 & +10
		bsr	Wind.Set	; Set its title

		move.w	#1,IntIn	; Begin Update
		bsr	Wind.Update
		
		move.w	#256,IntIn	; Turn of mousepointer
		bsr	Graf.Mouse

		move.w	W_Handle,IntIn	; Open our window
		movem.w	Wx,d0-3		; Coors to open window on
		movem.w	d0-3,IntIn+2
		bsr	Wind.Open	; Open it

		move.w	#0,IntIn	; End Update
		bsr	Wind.Update
		
		move.w	#0,FormFlag	; Reserve Flag
		bsr	Form_Dial	; Reserve space
		movea.l	Parent,a5	; Form1 address
		movem.w	Cx(pc),d0-3
		movem.w	d0-3,ClipX	; X,y,w & h of clipping area
		move.w	#FORM1,d0	; Start-Obj 
		bsr	Ob_Draw		; Draw dialog

		move.w	#257,IntIn	; Turn on mousepointer
		bsr	Graf.Mouse
		
		move.w	#0,IntIn	; Set mousepointer to arrow
		bsr	Graf.Mouse
	
;----------------------------------------------------------------------;
; Main loop.
Evnt.Multi:	tst.b	ExitStatus	; If not zero - exit selected
		bne.w	EndIt

		move.l	#MessageBuf,AddrIn
		move.l	#Evnt_Multi,Aespb
		move.w	#1+2+16,IntIn	; Key, Mouse click and msg
		move.w	#256+2,IntIn+2	; No of m-clicks
		move.w	#1,IntIn+4	; Left mouse button
		move.w	#0,IntIn+6	; Left mouse button Down
		move.w	#0,IntIn+8	; Enter Rectangle
		move.w	Cx,IntIn+10
		move.w	Cy,IntIn+12
		move.w	Cw,IntIn+14
		move.w	Ch,IntIn+16
		move.w	#0,IntIn+18
		move.w	#0,IntIn+20	; No use for second mouse check
		move.w	#0,IntIn+22
		move.w	#0,IntIn+24
		move.w	#0,IntIn+26
		move.w	#0,IntIn+28	; Time low word
		move.w	#0,IntIn+30	; Time high word
		bsr	Aes
		move.w	IntOut+2,Mx	; Save Xmouse
		move.w	IntOut+4,My	; Save YMouse
		
		cmpi.w	#1,IntOut	; Key event
		beq.s	CheckKey
		cmpi.w	#2,IntOut	; Mouse event
		beq.s	CheckMouse
		cmpi.w	#16,IntOut	; Message Event
		beq.w	CheckMsg	; Execute message 

		bra	Evnt.Multi
;----------------------------------------------------------------------;
CheckKey:	move.w	IntOut+10,d0
		cmpi.w	#$1C0D,d0	; Return key
		beq.w	EndIt
		bra	Evnt.Multi
		
CheckMsg:	lea	MessageBuf,a0
		move.w	(a0),d0		; Message type in d0
		cmpi.w	#$5758,d0	; WM_Shade (WinX)
		beq.w	Shade
		cmpi.w	#$5759,d0	; WM_Unshade (WinX)
		beq.w	UnShade
		cmpi.w	#20,d0		; Winow got redraw message
		beq.w	Redraw
		cmpi.w	#21,d0		; Windos is topped
		beq.w	Topped		
		cmpi.w	#22,d0		; Closed
		beq.w	EndIt
		cmpi.w	#28,d0		; Moved
		beq.w	MoveWindow
		bra	Evnt.Multi

CheckMouse:	move.w	#0,IntIn	; Object tree
		move.w	#FORM1,IntIn+2
		move.l	#RSC_Gaddr,Aespb ; Get Address
		bsr	Aes		; We could have taken the address from Parent....
		move.l	AddrOut,a5	; but...
		
		move.l	a5,AddrIn	; Address of three to preform search on
		move.w	#FORM1,IntIn	; Our first dialog
		move.w	#7,IntIn+2	; Depth
		move.w	Mx,IntIn+4	; X-coord of mouse
		move.w	My,IntIn+6	; Y-coords of mouse
		move.l	#Object_Find,Aespb
		bsr	Aes		; Go find it...
		tst.w	IntOut		; Error = -1
		bmi.w	Evnt.Multi
		
Mouse_Rectang:	cmpi.w	#EXIT,IntOut	; Test the exit button
		beq.s	Exit_Pressed
		cmpi.w	#EXIT2,IntOut	; Another possible choise
		beq.s	Exit2_Pressed
		bra	Evnt.Multi

Exit_Pressed:	move.l	Parent,AddrIn	; Tree address
		move.w	#EXIT,IntIn	; Object to check
		move.w	#1,IntIn+2	; no of clicks
		bsr	Form.Button	; Do it
		tst.w	IntOut		; =0 if hit on EXIT/TOUCHEXIT
		bne.w	Evnt.Multi
		move.b	#1,ExitStatus	; Exit selected - time to leave :-)
		bra	Evnt.Multi

Exit2_Pressed:	move.l	Parent,AddrIn
		move.w	#EXIT2,IntIn
		move.w	#1,IntIn+2
		bsr	Form.Button
		tst.w	IntOut
		bne.w	Evnt.Multi
		move.b	#1,ExitStatus
		bra	Evnt.Multi
*---------------------------------------------------------------------*
*	SubRoutines
EndIt:		move.w	#3,FormFlag	; Release mem
		bsr	Form_Dial	; Do it

		move.l	#Wind_Close,Aespb
		move.w	W_Handle,IntIn
		bsr	Aes
		move.l	#Wind_Delete,Aespb
		move.w	W_Handle,IntIn
		bsr	Aes

; *_* Close VDI Station *_*
		move.w	#101,Contrl
		move.w	#0,Contrl+2
		move.w	#0,Contrl+6
		move.w	Ws_Handle,Contrl+12
		bsr	Vdi
				
EndIt1:		move.l	#RSC_Free,Aespb ; Clear up memory
		bsr	Aes
EndIt2:		move.l	#Appl_Exit,Aespb
		bsr	Aes
		clr.l	-(sp)
		trap	#1

*-------------------------------------------------------------------------*
; Input: d0 = Object to start drawing at
;	 a0 = tree address
;  IntInt+4-10 = x,y,w,h of clipping area
Ob_Draw:	move.w	d0,IntIn		; Obj
		move.w	#7,IntIn+2		; Depth
		move.w	ClipX(pc),IntIn+4	; Ox of clipping area
		move.w	ClipY(pc),IntIn+6	; Oy
		move.w	ClipW(pc),IntIn+8	; Ow
		move.w	ClipH(pc),IntIn+10	; Oh
		move.l	a5,AddrIn		; Add of three
		move.l	#Object_Draw,Aespb
		bsr	Aes
		rts
		
;----------------------------------------------------------------------;
; Fix coords for RSC to be displayed at center of screen
; Input: a5 - Address of tree
;
Form_Center:	move.l	#F_Center,Aespb
		move.l	a5,AddrIn
		bsr	Aes
		move.w	IntOut+2(pc),Cx
		move.w	IntOut+4(pc),Cy
		move.w	IntOut+6(pc),Cw
		move.w	IntOut+8(pc),Ch
		rts
;----------------------------------------------------------------------;
; Setup screen memory for RSC-forms
Form_Dial:	move.w	FormFlag(pc),IntIn	; Flag 0/1/2/3 (0=allocate/3=release allocated) 
		move.w	Cx(pc),IntIn+2
		move.w	Cy(pc),IntIn+4
		move.w	Cw(pc),IntIn+6
		move.w	Ch(pc),IntIn+8
		move.w	Cx(pc),IntIn+10
		move.w	Cy(pc),IntIn+12
		move.w	Cw(pc),IntIn+14
		move.w	Ch(pc),IntIn+16
		move.l	#Form_Dialog,Aespb
		bsr.w	Aes
		rts
;----------------------------------------------------------------------;
; To support a feature given by WinX. This allows any window to just
; display the title-bad and alternative the close and full box.
; The actuall window-contents disappears.
Shade:		;move.w	#3,FormFlag	; Release mem
		;bsr	Form_Dial	; Do it
		bra	Evnt.Multi
		
; Display the window-contest again.
UnShade:	;move.w	#0,FormFlag	; Reserve Mem
		;bsr	Form_Dial
		movea.l	Parent,a5	; Form1 add
		movem.w	Cx,d0-3
		movem.w	d0-3,ClipX
		move.w	#0,d0		; Start-Obj 
		bsr	Ob_Draw		; Draw form
		
		bra	Evnt.Multi

; Redraw window - calculate which parts need to redraw.
Redraw:		move.w	6(a0),d0	
		cmp.w	W_Handle,d0	; Check if it is our window
		bne.w	Evnt.Multi	; It's not
		move.w	8(a0),Rx	; Store dirty-area coords (x)
		move.w	10(a0),Ry	; y
		move.w	12(a0),Rw	; w
		move.w	14(a0),Rh	; h

		move.w	#1,IntIn	; Begin update
		bsr	Wind.Update
		
		move.w	#0,IntIn	; Desktop
		move.w	#10,IntIn+2	; Return top-windows handle
		bsr	Wind.Get
		move.w	IntOut+2,Top_Handle ; Store TopWindow handle
		
		movem.w	Rx,d0-3		; Coords for dirty area
		movem.w	d0-3,ClipX	; New coords for ob_draw (clipping)
		movea.l	Parent,a5	; Three to redraw
		move.w	#FORM1,d0	; Obj
		bsr	Ob_Draw	 

		move.w	W_Handle,IntIn
		move.w	#4,IntIn+2	; Get Work area
		bsr	Wind.Get
		
		move.w	#0,IntIn	; End update
		bsr	Wind.Update
		bra	Evnt.Multi
		
Topped:		move.w	#3,FormFlag	; Allocate
		bsr	Form_Dial

		move.w	W_Handle,IntIn	; Window to top - ours
		move.w	#10,IntIn+2	; WIN_TOP
		bsr	Wind.Set
		
		move.w	W_Handle,IntIn	; Out window
		move.w	#4,IntIn+2	; Only interested in the work area
		bsr	Wind.Get	; of the window
		movem.w	IntOut+2,d0-3
		movem.w	d0-3,Cx		; Store new coords
		movea.l	Parent,a0	; Address to out dialog
		move.w	Cx,16(a0)	; New coords for dialog
		move.w	Cy,18(a0)	; New coords for dialog

		move.w	#0,FormFlag	; Allocate
		bsr	Form_Dial
		movem.w	Cx,d0-3		; Get 
		movem.w	d0-3,ClipX	; Coords to clipping area
		movea.l	Parent,a5	; Tree
		move.w	#FORM1,d0	; Form to draw
		bsr	Ob_Draw
		bra	Evnt.Multi	; and return to the loop
;----------------------------------------------------------------------;
; Message $1c detected - window moved		
MoveWindow:	move.w	6(a0),d0
		cmp.w	W_Handle,d0	; Check if it is our window
		bne.w	Evnt.Multi	; It's not
		move.w	8(a0),Wx	; Store new values
		move.w	10(a0),Wy
		move.w	12(a0),Ww	; Same as before
		move.w	14(a0),Wh	; same as before

		move.w	#3,FormFlag	; Release previous allocated
		bsr	Form_Dial	; screen-area

		; Some clipping should be done here.
		
		move.w	W_Handle,IntIn	; Our window
		move.w	#5,IntIn+2	; Set new x,y,w,h
		movem.w	Wx,d0-3
		movem.w	d0-3,IntIn+4
		bsr	Wind.Set	; Set new window-coords
		tst.w	IntOut		; =0 if error
		beq.w	EndIt
		
		move.w	W_Handle,IntIn	; Out window
		move.w	#4,IntIn+2	; Only interested in the work area
		bsr	Wind.Get	; of the window
		movem.w	IntOut+2,d0-3
		movem.w	d0-3,Cx		; Store new coords
		movea.l	Parent,a0	; Address to out dialog
		move.w	Cx,16(a0)	; New coords for dialog
		move.w	Cy,18(a0)	; New coords for dialog

		move.w	#0,FormFlag	; Allocate
		bsr	Form_Dial
		bra	Evnt.Multi	; and return to the loop
;----------------------------------------------------------------------;
Aes:		movem.l	d0-7/a0-6,-(sp)
		move.l	#Aespb,d1
		move.l	#$C8,d0
		trap	#2
		movem.l	(sp)+,d0-7/a0-6
		rts
Vdi:		movem.l	d0-7/a0-6,-(sp)
		move.l	#Vdipb,d1
		moveq.w	#$73,d0
		trap	#2
		movem.l	(sp)+,d0-7/a0-6
		rts
;-------------------------------------------------------------------------;
Wind.Get:	move.l	#Wind_Get,Aespb
		bra	Rts
Wind.Calc:	move.l	#Wind_Calc,Aespb
		bra	Rts
Wind.Create:	move.l	#Wind_Create,Aespb
		bra	Rts
Wind.Open:	move.l	#Wind_Open,Aespb
		bra	Rts
Wind.Set:	move.l	#Wind_Set,Aespb
		bra	Rts
Wind.Update:	move.l	#Wind_Update,Aespb
		bra	Rts
Graf.Mouse:	move.l	#Graf_Mouse,Aespb
		move.w	#0,AddrIn	; Usually 0 
		bra	Rts
Evnt.Button:	move.l	#Evnt_Button,Aespb
		bra	Rts
Form.Button:	move.l	#Form_Button,Aespb
		
Rts:		bsr	Aes
		rts
				
;-------------------------------------------------------------------------;
;-------------------------------------------------------------------------;
;-------------------------------------------------------------------------;
		Section DATA
;		ds.l	256
Aespb:		dc.l	Contrl,Global,IntIn,IntOut,AddrIn,AddrOut
Vdipb:		dc.l	Contrl,IntIn,PtsIn,IntOut,PtsOut
Contrl:		ds.w	12
IntIn:		ds.w	128
IntOut:		ds.w	128
Global:		ds.w	16
AddrIn:		ds.w	128
AddrOut:	ds.w	128
PtsIn:		ds.w	256
PtsOut:		ds.w	256

Appl_Init:	dc.w	10,0,1,0,0
Appl_Exit:	dc.w	19,0,1,0,0
FSel_Input:	dc.w	90,0,2,2,0
Object_Draw:	dc.w	42,6,1,1,0
Form_Do:	dc.w	50,1,2,1,0
F_Center:	dc.w	54,0,5,1,0
Object_Find:	dc.w	43,4,1,1,0
Evnt_Multi:	dc.w	25,16,7,1,0
Evnt_Button:	dc.w	21,3,5,0,0
Form_Dialog:	dc.w	51,9,1,1,0
Form_Alert	dc.w	52,1,1,1,0	
Form_Button:	dc.w	56,2,2,1,0
Graf_Handle:	dc.w	77,0,5,0,0
Graf_Mouse:	dc.w	78,1,1,1,0
Objc_Edit:	dc.w	46,4,2,1,0
Objc_Change:	dc.w	47,8,1,1,0
RSC_Load:	dc.w	110,0,1,1,0
RSC_Gaddr:	dc.w	112,2,1,0,1
RSC_Free:	dc.w	111,0,1,0,1
Wind_Get:	dc.w	104,2,5,0,0
Wind_Create:	dc.w	100,5,1,0,0
Wind_Open:	dc.w	101,5,1,0,0
Wind_Close:	dc.w	102,1,1,0,0
Wind_Delete:	dc.w	103,1,1,0,0
Wind_Set:	dc.w	105,6,1,0,0
Wind_Update:	dc.w	107,1,1,0,0
Wind_Calc:	dc.w	108,6,5,0,0
Wind_New:	dc.w	109,0,0,0,0
VDI_Clip:	dc.w	129,2,0,1,0	; VS_CLIP
RSC_File:	dc.b	"H:\TEMP\windrsc.RSC",0
WinTitle:	dc.b	"GEM DiskOpus ",189," STand Software",0

		SECTION BSS

; DO NOT CHANGE ORDER OF THESE ENTRIES!!!!
ClipX:		ds.w	1	; Coords used by ob_draw
ClipY:		ds.w	1	; (clipping area)
ClipW:		ds.w	1
ClipH:		ds.w	1
Cx:		ds.w	1	; Coords for RSC
Cy:		ds.w	1
Cw:		ds.w	1
Ch:		ds.w	1
Wx:		ds.w	1	; Coords for Window
Wy:		ds.w	1
Ww:		ds.w	1
Wh:		ds.w	1
DWx:		ds.w	1	; Coords for Desktop-Window
DWy:		ds.w	1
DWw:		ds.w	1
DWh:		ds.w	1
Rx:		ds.w	1	; Coord retunred for intersection
Ry:		ds.w	1	; Used for clipping.
Rw:		ds.w	1
Rh:		ds.w	1

Ap_Id:		ds.w	1
Parent:		ds.l	1
Mx:		ds.w	1
My:		ds.w	1
Key:		ds.w	1
Mouse_Shape:	ds.w	1
Mouse_Rect:	ds.w	1
Dialog:		ds.l	1
Gr_Handle:	ds.w	1	; Graf Handle
W_Handle:	ds.w	1	; Our Window Handle
Top_Handle:	ds.w	1	; Top windows handle
Ws_Handle:	ds.w	1	; Virtual Workstation handle
MessageBuf:	ds.b	16	; Message buffer
Res:		ds.w	1	; For V_OPNVWK call
FormFlag:	ds.w	1	; 
ExitStatus:	ds.b	1	; If 1 - Exit 2
		ds.l	256
UStk:		ds.l	1
