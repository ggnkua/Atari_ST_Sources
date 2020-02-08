
' [WINDOW.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1998 Matthew Bacon & Paul Jones

' DECLARE FUNCTION WhichWindow(WindowHandle)		' Can be found in TOOLBX_D.BAS
DECLARE FUNCTION CloseFormWind						' Can be found in FORMWIND.BAS
DECLARE SUB HandleCursor(WindowHandle,mode)			' Can be found in FORMWIND.BAS
DECLARE SUB TextWindArrowed(WindowHandle,which)		' Can be found in TEXTWIND.BAS
DECLARE FUNCTION HandleUserClose(WindowHandle)		' This should be written by you!

CONST woTsimple=0,woTobject=1,woTtext=2,woTimage=3,woTform=4,woTtool=5

SUB	InitWindowSystem
SHARED cellx,celly,HowManyWindows,WindowSystem,max_windows
SHARED woHandle(1),woRedraw&(1),woSliderMax&(1),woClose&(1),woType(1)
SHARED woOffx(1),woOffy(1),woTindex(1),woIconify(1)

IF aes_version>=&h330 THEN max_windows=10 ELSE max_windows=7
REDIM woHandle(max_windows),woRedraw&(max_windows),woSliderMax&(max_windows)
REDIM woClose&(max_windows),woType(max_windows),woOffx(max_windows),woOffy(max_windows)
REDIM woTindex(max_windows),woIconify(max_windows)

junk=graf_handle(cellx,celly,junk,junk)
HowManyWindows=0 : WindowSystem=-1
END SUB


FUNCTION WindInter(BYVAL x1,BYVAL y1,BYVAL w1,BYVAL h1,_
			BYVAL x2,BYVAL y2,BYVAL w2,BYVAL h2,outx,outy,outw,outh)
InterSection x1,y1,w1,h1,x2,y2,w2,h2,outx,outy,outw,outh
IF outh>0 AND outw>0 THEN WindInter=-1 ELSE WindInter=0
END FUNCTION


FUNCTION OpenAWindow(WindowName$,BYVAL WindComp,BYVAL x,BYVAL y,BYVAL w,BYVAL h,BYVAL redrawproc&,BYVAL slidermaxaddr&,BYVAL closeproc&)
SHARED HowManyWindows,WindowSystem,max_windows,woHandle(1),woRedraw&(1)
SHARED woSliderMax&(1),woClose&(1),woType(1),woOffx(1),woOffy(1),woIconify(1)
STATIC WindowHandle,x1,y1,x2,y2,id

IF WindowSystem=0 THEN CALL InitWindowSystem
IF HowManyWindows=max_windows THEN
	junk=form_alert(1,"[1][  "+MyProgram$+": |  There are no more windows |  available. Please close a |  window!][ OK ]")
	OpenAWindow=-1 : EXIT SUB
END IF

id=0
DO WHILE VARPTR(#257+id)
	INCR id
LOOP
graf_mouse 256,0
IF x<0 OR y<0 OR w<0 OR h<0 THEN junk=wind_get(0,WF_WORKXYWH,x,y,w,h)
WINDOW OPEN id,WindowName$,x,y,w,h,WindComp

INCR HowManyWindows
WINDOW READ id,5,WindowHandle
woHandle(HowManyWindows)=WindowHandle
woRedraw&(HowManywindows)=redrawproc&
woSliderMax&(HowManyWindows)=slidermaxaddr&
woClose&(HowManyWindows)=closeproc&
woType(HowManyWindows)=woTsimple
woOffx(HowManyWindows)=0
woOffy(HowManyWindows)=0
woIconify(HowManyWindows)=0

junk=wind_get(WindowHandle,WF_WORKXYWH,x1,y1,x2,y2)
vsf_color 0 : x2=x1+x2-1 : y2=y1+y2-1
vs_clip 1,x1,y1,x2,y2 : vr_recfl x1,y1,x2,y2
graf_mouse 257,0 : OpenAWindow=WindowHandle
END FUNCTION


FUNCTION GetOffset(BYVAL TotalHeight,BYVAL value)
IF TotalHeight<0 THEN
	GetOffset=0
ELSE
	GetOffset=(CLNG(value)*CLNG(TotalHeight)\1000)
END IF
END FUNCTION


SUB CloseAWindow(WindowHandle)
SHARED HowManyWindows,userclose_enabled,FormWindowSystem
SHARED woHandle(1),woRedraw&(1),woSliderMax&(1),woClose&(1),woType(1)
SHARED woOffx(1),woOffy(1),woTindex(1),woIconify(1),CommonIndex
STATIC dummy,id,MyHandle

MyHandle=WindowHandle
CommonIndex=WhichWindow(WindowHandle)
IF CommonIndex>0 THEN
	IF (woType(CommonIndex)=woTform OR woType(CommonIndex)=woTtool) THEN 
		IF FormWindowSystem THEN IF CloseFormWind=0 THEN EXIT SUB
	END IF
	IF userclose_enabled THEN IF HandleUserClose(WindowHandle)=0 THEN EXIT SUB
	WindowHandle=MyHandle
	DECR HowManyWindows
	CALLS woClose&(CommonIndex)
	FOR dummy=CommonIndex TO HowManyWindows
		woHandle(dummy)=woHandle(dummy+1)
		woRedraw&(dummy)=woRedraw&(dummy+1)
		woSliderMax&(dummy)=woSlidermax&(dummy+1)
		woClose&(dummy)=woClose&(dummy+1)
		woType(dummy)=woType(dummy+1)
		woOffx(dummy)=woOffx(dummy+1)
		woOffy(dummy)=woOffy(dummy+1)
		woTindex(dummy)=woTindex(dummy+1)
		woIconify(dummy)=woIconify(dummy+1)
	NEXT dummy
	WINDOW READ WindowHandle,6,id
	IF id>=0 THEN WINDOW CLOSE id
END IF
WindowHandle=0
END SUB


SUB OneSlider(BYVAL Horizontal,BYVAL TotalSize,BYVAL cur_pos,BYVAL size)
SHARED CommonHandle
STATIC dummy,temp&

IF TotalSize>0 THEN
	IF TotalSize<size THEN
		cur_pos=1 : size=1000
	ELSE
		temp&=1000*CLNG(cur_pos)
		cur_pos=temp&\(CLNG(TotalSize)-size)+1
		IF cur_pos>1000 THEN cur_pos=1000
		temp&=1000*CLNG(size)
		size=temp& \CLNG(Totalsize)+1
		IF size>1000 THEN size=1000
	END IF
	dummy=WF_VSLSIZE-Horizontal
	junk=wind_set(CommonHandle,dummy,size,0,0,0)
	dummy=dummy-7
	junk=wind_set(CommonHandle,dummy,cur_pos,0,0,0)
END IF
END SUB


SUB WindowSlid(BYVAL Horizontal,BYVAL WindowHandle,BYVAL value)
SHARED CommonIndex,CommonMAXx,CommonMAXy,CommonHandle,cellx,celly
SHARED woSliderMax&(1),woOffx(1),woOffy(1),woType(1)
STATIC x,y,w,h,char_x,char_y

CommonIndex=WhichWindow(WindowHandle)
IF CommonIndex>0 THEN
	CommonHandle=WindowHandle
	char_x=woOffx(CommonIndex)\cellx : char_y=woOffy(CommonIndex)\celly
	CALLS woSliderMax&(CommonIndex)
	junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h)
	h=(h\celly)*celly : w=(w\cellx)*cellx

	IF Horizontal THEN
		woOffx(CommonIndex)=GetOffset(CommonMAXx-w,value)
	ELSE
		woOffy(CommonIndex)=GetOffset(CommonMAXy-h,value)
	END IF
	IF woType(CommonIndex)=woTtext THEN
		IF (char_x<>(woOffx(CommonIndex)\cellx)) OR (char_y<>(woOffy(CommonIndex)\celly)) THEN FullReDraw WindowHandle
	ELSE
		FullRedraw WindowHandle
	END IF
END IF
END SUB


SUB WindowArrowed(BYVAL WindowHandle,BYVAL which)
SHARED CommonHandle,CommonIndex,CommonMAXx,CommonMAXy
SHARED woType(1),woOffx(1),woOffy(1),cellx,celly,woSliderMax&(1)
STATIC x,y,w,h,NewX,NewY

CommonIndex=WhichWindow(WindowHandle)
IF CommonIndex>0 THEN
	IF woType(CommonIndex)=woTtext THEN
		TextWindArrowed WindowHandle,which : EXIT SUB
	END IF

	junk=wind_get(WindowHandle,WF_WORKXYWH,x,y,w,h)
	h=(h\celly)*celly : w=(w\cellx)*cellx
	NewX=woOffx(CommonIndex) : NewY=woOffy(CommonIndex)

	SELECT CASE which
	CASE 0 : NewY=NewY-h
	CASE 1 : NewY=NewY+h
	CASE 2 : NewY=NewY-celly
	CASE 3 : NewY=NewY+celly
	CASE 4 : NewX=NewX-w
	CASE 5 : NewX=NewX+w
	CASE 6 : NewX=NewX-cellx
	CASE 7 : NewX=NewX+cellx
	END SELECT

	CommonHandle=WindowHandle
	CALLS woSliderMax&(CommonIndex)
	woOffx(CommonIndex)=MAX(MIN(NewX,((CommonMAXx-w-1)\cellx+1)*cellx),0)
	woOffy(CommonIndex)=MAX(MIN(NewY,((CommonMAXy-h-1)\celly+1)*celly),0)
	FullReDraw WindowHandle
END IF
END SUB


SUB RenameWindow(WindowHandle,WindowName$)
STATIC BasicHandle

WINDOW READ WindowHandle,6,BasicHandle
WINDOW NAME BasicHandle,WindowName$
END SUB


SUB ReDraw(WindowHandle,BYVAL x,BYVAL y,BYVAL w,BYVAL h)
SHARED CommonX,CommonY,CommonW,CommonH,CommonHandle,woReDraw&(1)
SHARED CommonIndex,woIconify(1),itreeno,woType(1)
STATIC oldtree&,x1,y1,w1,h1,x2,y2,w2,h2,xvdi,yvdi

graf_mouse 256,0
junk=wind_update(BEG_UPDATE)
junk=wind_get(WindowHandle,WF_FIRSTXYWH,x1,y1,w1,h1)
WHILE (w1<>0) AND (h1<>0)
	IF WindInter(x,y,w,h,x1,y1,w1,h1,CommonX,CommonY,CommonW,CommonH) THEN
		vsf_color 0 : xvdi=CommonX+CommonW-1 : yvdi=CommonY+CommonH-1
		vs_clip 1,CommonX,CommonY,xvdi,yvdi : vr_recfl CommonX,CommonY,xvdi,yvdi
		CommonIndex=WhichWindow(WindowHandle)
		IF CommonIndex>0 THEN
			CommonHandle=WindowHandle
			IF woIconify(CommonIndex)=1 THEN
				IF itreeno<>0 THEN
					oldtree&=tree& : SelectTree itreeno
					junk=wind_get(CommonHandle,WF_WORKXYWH,x2,y2,w2,h2)
					setobj_xywh 0,x2,y2,w2,h2
					junk=objc_draw(tree&,0,10,CommonX,CommonY,CommonW,CommonH)
					tree&=oldtree&
				END IF
			ELSE
				CALLS woReDraw&(CommonIndex) : UpdateSliders
			END IF
		END IF
	END IF
	junk=wind_get(WindowHandle,WF_NEXTXYWH,x1,y1,w1,h1)
WEND
junk=wind_update(END_UPDATE)
graf_mouse 257,0
END SUB


SUB FullReDraw(BYVAL WindowHandle)
STATIC x,y,w,h

junk=wind_get(WindowHandle,WF_WORKXYWH,x,y,w,h)
Redraw WindowHandle,x,y,w,h
END SUB


SUB ChangeWindow(BYVAL WindowHandle,BYVAL x,BYVAL y,BYVAL w,BYVAL h)
SHARED woType(1),woObjectTree&(2),woBaseX(2),woBaseY(2),woOffx(1),woOffy(1)
SHARED CommonIndex,cellx,celly

junk=wind_set(WindowHandle,WF_CURRXYWH,x,y,w,h)
CommonIndex=WhichWindow(WindowHandle) : IF CommonIndex=0 THEN EXIT SUB
IF NOT (woType(CommonIndex)=woTform OR woType(CommonIndex)=woTtool) THEN EXIT SUB
junk=wind_get(WindowHandle,WF_WORKXYWH,x,y,w,h)
SelectTreeAddr woObjectTree&(0,CommonIndex)
IF enquire_state(0,mask_outlined) THEN x=x+3 : y=y+3
setobj_x 0,woBaseX(0,CommonIndex)+x
setobj_y 0,woBaseY(0,CommonIndex)+y
IF woObjectTree&(1,CommonIndex)<>0 THEN
	SelectTreeAddr woObjectTree&(1,CommonIndex)
	IF enquire_state(0,mask_outlined) THEN x=x+3 : y=y+3
	setobj_x 0,woBaseX(1,CommonIndex)+x
	setobj_y 0,woBaseY(1,CommonIndex)+y
END IF
END SUB


SUB UpdateSliders
SHARED CommonHandle,CommonIndex,CommonMAXx,CommonMAXy,mess(1)
SHARED woSliderMax&(1),woOffx(1),woOffy(1),woType(1)
STATIC x,y,w,h

CommonHandle=mess(3) : CommonIndex=WhichWindow(CommonHandle)
IF CommonIndex=0 THEN EXIT SUB

junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h)
CALLS woSliderMax&(CommonIndex)
IF woType(CommonIndex)=woTform THEN EXIT SUB
OneSlider 1,CommonMAXx,woOffx(CommonIndex),w
OneSlider 0,CommonMAXy,woOffy(CommonIndex),h
END SUB


SUB TopAWindow(VAL WindowHandle)
SHARED woType(1),CommonIndex

CommonIndex=WhichWindow(WindowHandle)
junk=wind_set(WindowHandle,WF_TOP,0,0,0,0)
END SUB


SUB UnTopAWindow(BYVAL WindowHandle)
SHARED CommonIndex

CommonIndex=WhichWindow(WindowHandle)
END SUB


SUB WindowMessage
SHARED WindX,WindY,WindH,WindW,mess(1),woIconify(1),CommonIndex
STATIC x,y,w,h,MessageType

MessageType=mess(0)
SELECT CASE MessageType
CASE WM_REDRAW : ReDraw mess(3),mess(4),mess(5),mess(6),mess(7)
CASE WM_TOPPED : TopAWindow mess(3)
CASE WM_CLOSED : CloseAWindow mess(3)
CASE WM_FULLED
	junk=wind_get(0,WF_WORKXYWH,WindX,WindY,WindW,WindH)
	junk=wind_get(mess(3),WF_CURRXYWH,x,y,w,h)
	IF (WindW<>w) OR (WindH<>h) OR (WindX<>x) OR (WindY<>y) THEN
		ChangeWindow  mess(3),WindX,WindY,WindW,WindH
	ELSE
		junk=wind_get(mess(3),WF_PREVXYWH,x,y,w,h)
		ChangeWindow mess(3),x,y,w,h
	END IF
	UpdateSliders
CASE WM_ARROWED : WindowArrowed mess(3),mess(4)
CASE WM_HSLID : WindowSlid 1,mess(3),mess(4)
CASE WM_VSLID : WindowSlid 0,mess(3),mess(4)
CASE WM_SIZED
	Changewindow mess(3),mess(4),mess(5),mess(6),mess(7)
	UpdateSliders
CASE WM_MOVED
	IF mess(4)<1 THEN mess(4)=1
	ChangeWindow mess(3),mess(4),mess(5),mess(6),mess(7)
CASE WM_UNTOPPED : UnTopAWindow mess(3)

CASE WM_ONTOP
CASE WM_BOTTOMED
CASE WM_ICONIFY
	junk=wind_set(mess(3),WF_ICONIFY,mess(4),mess(5),mess(6),mess(7))
	CommonIndex=WhichWindow(mess(3))
	woIconify(CommonIndex)=1
CASE WM_UNICONIFY
	junk=wind_set(mess(3),WF_UNICONIFY,mess(4),mess(5),mess(6),mess(7))
	CommonIndex=WhichWindow(mess(3))
	woIconify(CommonIndex)=0
CASE WM_ALLICONIFY
CASE WM_TOOLBAR
END SELECT
END SUB

'[*END OF FILE*]