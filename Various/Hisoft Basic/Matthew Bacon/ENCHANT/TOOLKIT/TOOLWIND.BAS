
' [TOOLWIND.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DIM SHARED ToolWindowSystem

SUB InitToolWindows
SHARED max_windows

ToolWindowSystem=-1
END SUB


FUNCTION OpenToolWindow(WindowName$,BYVAL WindComp,BYVAL treeno,BYVAL redrawproc&,BYVAL sliderproc&,BYVAL closeproc&,BYVAL windw,BYVAL windh)
SHARED woObjectTree&(2),woBaseX(2),woBaseY(2),woCancelObj(1),woEditObj(1),woEditOffset(1)
SHARED woClose&(1),woCloseForm&(2),WindowSystem,FormWindowSystem,woType(1),HowManyWindows
SHARED woTreeno(2),woHandle(1),forms_enabled,woOffx(1),woOffy(1)
STATIC x,y,w,h,WindowHandle,dummy,dummy$,x1,y1,w1,h1

IF WindowSystem=0 THEN CALL InitWindowSystem
IF FormWindowSystem=0 THEN CALL InitFormWindows
IF ToolWindowSystem=0 THEN CALL InitToolWindows

FOR dummy=0 TO HowManyWindows
	IF woTreeno(0,dummy)=treeno THEN OpenToolWindow=woHandle(dummy) : TopAWindow woHandle(dummy) : EXIT FUNCTION
NEXT dummy

SelectTree treeno
x=CINT(((PEEKW(SYSTAB+44)+1)-windw)/2)
y=CINT(((PEEKW(SYSTAB+46)+1)-windh)/2)
w=windw
h=windh
FOR dummy=0 TO 255
	CALL getobj_xywh (dummy,x1,y1,w1,h1)
	IF (x1+w1)>=w THEN setobj_width dummy,PEEKW(SYSTAB+44)+1
	IF (y1+h1)>=h THEN setobj_height dummy,PEEKW(SYSTAB+46)+1
	IF enquire_flags(dummy,mask_lastob) THEN EXIT FOR
NEXT dummy
junk=wind_calc(0,WindComp,x,y,w,h,x,y,w,h)
IF y<20 THEN y=20

WindowHandle=OpenAWindow(WindowName$,WindComp,x,y,w,h,redrawproc&,sliderproc&,closeproc&)
IF WindowHandle>=0 THEN
	woType(HowManyWindows)=woTtool
	woObjectTree&(0,HowManyWindows)=tree&
	woObjectTree&(1,HowManyWindows)=0
	woTreeno(0,HowManyWindows)=treeno
	woTreeno(1,HowManyWindows)=0
	woBaseX(0,HowManyWindows)=0
	woBaseY(0,HowManyWindows)=0
	woCancelObj(HowManyWindows)=0
	woEditObj(HowManyWindows)=0
	woEditOffset(HowManyWindows)=0
	woClose&(HowManyWindows)=VARPTRS(DeleteFormWind)
	woCloseForm&(0,HowManyWindows)=closeproc&
	woCloseForm&(1,HowManyWindows)=0
	init_dialog treeno
	forms_enabled=-1
END IF
OpenToolWindow=WindowHandle
END FUNCTION

'[*END OF FILE*]
