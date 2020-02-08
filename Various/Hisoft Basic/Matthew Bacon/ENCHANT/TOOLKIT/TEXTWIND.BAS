
' [TEXTWIND.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' The files CURSOR.BAS & WINDOW.BAS are required to use TEXTWIND.BAS

' SUB WhichWindow(WindowHandle)		' Can be found in TOOLBX_D.BAS

DIM SHARED TextWindowSystem

SUB InitTextSystem(BYVAL MaxFiles,BYVAL MaxLines)
SHARED MaxTextWindows,woTLines(1),WindTLines$(2),woVSWR(2),TabSize,MaxTextWidth
SHARED HowManyTextWindows,expandtabsflag,MaxTextLines
STATIC dummy,i

MaxTextWindows=MaxFiles : MaxTextLines=MaxLines
REDIM woTLines(MaxTextWindows-1),WindTLines$(MaxTextWindows-1,MaxLines),woVSWR(MaxTextWindows-1,MaxLines)
TabSize=4 : MaxTextWidth=150 : HowManyTextWindows=0 : TextWindowSystem=-1
expandtabsflag=-1
FOR i=0 TO  MaxTextWindows-1
	FOR dummy=0 TO MaxLines-1
		woVSWR(i,dummy)=1
	NEXT
NEXT
END SUB


FUNCTION OpenTextWindow(BYVAL WindowName$,BYVAL WindComp)
SHARED woType(1),woTindex(1),HowManyTextWindows,MaxTextWindows,HowManyWindows
SHARED WindowSystem
STATIC WindowHandle,x,y,w,h

IF WindowSystem=0 THEN CALL InitWindowSystem
IF TextWindowSystem=0 THEN
	junk=form_alert(1,"[1][  "+MyProgram$+": |  The text window system must |  first be initialised! ][ OK ]")
	OpenTextWindow=0 : EXIT FUNCTION
END IF
junk=wind_get(0,WF_WORKXYWH,x,y,w,h)
WindowHandle=OpenAWindow(WindowName$,WindComp,x,y,w,h,VARPTRS(TextWindRedraw),VARPTRS(TextWindSlid),VARPTRS(TextWindClose))
IF WindowHandle>=0 THEN
	INCR HowManyTextWindows
	IF HowManyTextWindows>MaxTextWindows THEN
		DECR HowManyTextWindows
		junk=form_alert(1,"[1][  "+MyProgram$+": |  There are no more text windows|  available. Please close a |  window!][ OK ]")
		WindowHandle=-1
	ELSE
		woType(HowManyWindows)=woTtext
		woTindex(HowManyWindows)=HowManyTextWindows-1
	END IF
END IF
OpenTextWindow=WindowHandle
END FUNCTION


SUB LoadTextFile(BYVAL file$,BYVAL index,TotalLines)
SHARED WindTLines$(2),MaxTextLines,expandtabsflag
STATIC dummy,myfile

IF TextWindowSystem=0 THEN EXIT SUB
CALL update_mouse
dummy=0 : myfile=FREEFILE
OPEN file$ FOR INPUT AS #myfile
DO
	LINE INPUT #myfile,WindTLines$(index,dummy)
	IF expandtabsflag THEN ExpandTabs WindTLines$(index,dummy),WindTLines$(index,dummy)
	IF dummy>=MaxTextLines THEN EXIT LOOP
	INCR dummy
	CALL update_mouse
LOOP UNTIL EOF(myfile)
CLOSE myfile : TotalLines=dummy
MOUSE 0
END SUB


SUB ExpandTabs(BYVAL source$,dest$)
SHARED TabSize
STATIC dummy,i,char,temp

i=1 : dest$=""
FOR dummy=1 TO LEN(source$)
	char=ASC(MID$(source$,dummy,1))
	IF char=9 THEN
		temp=((i-1)\TabSize+1)*TabSize+1
		dest$=dest$+SPACE$(temp-i)
		i=temp
	ELSE
		dest$=dest$+CHR$(char)
		INCR i
	END IF
NEXT dummy
END SUB


SUB TextWindSlid
SHARED CommonIndex,CommonHandle,CommonMAXx,CommonMAXy,MaxTextWidth,cellx,celly
SHARED woTLines(1),woTindex(1),mess(),woOffx(1),woOffy(1)
STATIC x,y,w,h,file

CommonIndex=WhichWindow(CommonHandle) : IF CommonIndex=0 THEN EXIT SUB
CommonMAXx=MaxTextWidth*cellx
CommonMAXy=woTLines(woTindex(CommonIndex))*celly
woOffx(CommonIndex)=cellx*(woOffx(CommonIndex)\cellx)
woOffy(CommonIndex)=celly*(woOffy(CommonIndex)\celly)

junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h)
file=woTindex(CommonIndex)
IF mess(0)=WM_SIZED THEN
	IF (woOffy(CommonIndex)\celly)>(woTLines(file)-(h\celly)) THEN
		woOffy(CommonIndex)=(woTLines(file)-(h\celly))*celly
		CALL FullRedraw (CommonHandle)
	END IF
END IF
END SUB


SUB TextWindArrowed(BYVAL WindowHandle,BYVAL which)
SHARED CommonHandle,CommonIndex,CommonMAXx,CommonMAXy,mess(),woTindex(1)
SHARED woTLines(1),woOffx(1),woOffy(1),cellx,celly,woSliderMax&(1)
STATIC x,y,w,h,NewX,NewY,MessageType,type,file,x2,y2,OldCommonMAXx,OldCommonMAXy

CommonIndex=WhichWindow(WindowHandle)
IF CommonIndex>0 THEN
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
	OldCommonMAXx=CommonMAXx : OldCommonMAXy=CommonMAXy
	CALLS woSliderMax&(CommonIndex)
	woOffx(CommonIndex)=MAX(MIN(NewX,((CommonMAXx-w-1)\cellx+1)*cellx),0)
	woOffy(CommonIndex)=MAX(MIN(NewY,((CommonMAXy-h-1)\celly+1)*celly),0)
	CommonMAXx=OldCommonMAXx : CommonMAXy=OldCommonMAXy

	MessageType=mess(0)
	SELECT CASE MessageType
	CASE WM_SIZED
		file=woTindex(CommonIndex)
		IF (woOffy(CommonIndex)\celly)>(woTLines(file)-(h\celly)) THEN
			woOffy(CommonIndex)=(woTLines(file)-(h\celly))*celly
			CALL FullRedraw (CommonHandle)
		END IF
	CASE WM_ARROWED
		woOffx(CommonIndex)=cellx*(woOffx(CommonIndex)\cellx)
		woOffy(CommonIndex)=celly*(woOffy(CommonIndex)\celly)
		file=woTindex(CommonIndex)
		junk=wind_get(CommonHandle,WF_HSLIDE,x2,junk,junk,junk)
		junk=wind_get(CommonHandle,WF_VSLIDE,y2,junk,junk,junk)
		type=mess(4)
		SELECT CASE type
		CASE WA_UPLINE
			junk=wind_get(WindowHandle,WF_WORKXYWH,x,y,w,h)
			IF (h\celly)>woTLines(file) THEN EXIT SELECT
			IF y2<>1 THEN CALL FastTextWindRedraw : UpdateSliders
		CASE WA_DNLINE
			junk=wind_get(WindowHandle,WF_WORKXYWH,x,y,w,h)
			IF (h\celly)>woTLines(file) THEN EXIT SELECT
			IF y2<>1000 THEN CALL FastTextWindRedraw : UpdateSliders
		CASE WA_LFLINE : IF x2<>1 THEN CALL FastTextWindRedraw : UpdateSliders
		CASE WA_RTLINE : IF x2<>1000 THEN CALL FastTextWindRedraw : UpdateSliders
		CASE ELSE : FullReDraw WindowHandle
		END SELECT
	CASE ELSE
		FullReDraw WindowHandle
	END SELECT
END IF
END SUB


SUB FastTextWindRedraw
SHARED CommonX,CommonY,CommonW,CommonH,CommonHandle,woReDraw&(1)
SHARED CommonIndex,woIconify(1),WindTLines$(2),woOffx(1),woOffy(1),woTindex(1)
SHARED itreeno,mess(),cellx,celly,woVSWR(2)
STATIC oldtree&,x1,y1,w1,h1,x2,y2,w2,h2,xvdi,yvdi,x,y,w,h,file,top_handle
STATIC src_MFDB&(),des_MFDB&(),xyarr(),MessageType,dummy$,vswr_setting

DIM src_MFDB&(10),des_MFDB&(10),xyarr(8)
junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h) : file=woTindex(CommonIndex)
graf_mouse 256,0 : junk=wind_update(BEG_UPDATE)
junk=wind_get(CommonHandle,WF_FIRSTXYWH,x1,y1,w1,h1)
WHILE (w1<>0) AND (h1<>0)
	IF WindInter(x,y,w,h,x1,y1,w1,h1,CommonX,CommonY,CommonW,CommonH) THEN
		CommonIndex=WhichWindow(CommonHandle)
		IF CommonIndex>0 THEN
			vsf_color 0 : xvdi=CommonX+CommonW-1 : yvdi=CommonY+CommonH-1
			vs_clip 1,CommonX,CommonY,xvdi,yvdi : vswr_mode 1

			MessageType=mess(4)
			SELECT CASE MessageType
			CASE WA_UPLINE
				xyarr(0)=CommonX : xyarr(1)=CommonY : xyarr(2)=xvdi : xyarr(3)=yvdi-celly
				xyarr(4)=CommonX : xyarr(5)=CommonY+celly : xyarr(6)=xvdi : xyarr(7)=yvdi
			CASE WA_DNLINE
				xyarr(0)=CommonX : xyarr(1)=CommonY+celly : xyarr(2)=xvdi : xyarr(3)=yvdi
				xyarr(4)=CommonX : xyarr(5)=CommonY : xyarr(6)=xvdi : xyarr(7)=yvdi-celly
			CASE WA_LFLINE
				xyarr(0)=CommonX : xyarr(1)=CommonY : xyarr(2)=xvdi-cellx : xyarr(3)=yvdi
				xyarr(4)=CommonX+cellx : xyarr(5)=CommonY : xyarr(6)=xvdi : xyarr(7)=yvdi
			CASE WA_RTLINE
				xyarr(0)=CommonX+cellx : xyarr(1)=CommonY : xyarr(2)=xvdi : xyarr(3)=yvdi
				xyarr(4)=CommonX : xyarr(5)=CommonY : xyarr(6)=xvdi-cellx : xyarr(7)=yvdi
			END SELECT
			CALL vro_cpyfm(3,xyarr(),VARPTR(src_MFDB&(0)),VARPTR(des_MFDB&(0)))

			junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
			SELECT CASE MessageType
			CASE WA_UPLINE
				vr_recfl CommonX,CommonY,xvdi,CommonY+celly
				IF top_handle=CommonHandle THEN
					dummy$=WindTLines$(file,woOffy(CommonIndex)\celly)
					vswr_setting=woVSWR(file,woOffy(CommonIndex)\celly) : vswr_mode vswr_setting
					v_gtext CommonX,CommonY+celly,MID$(dummy$+SPACE$(CommonW\cellx),(woOffx(CommonIndex)\cellx)+1)
				ELSE
					CALL TextWindRedraw
				END IF
			CASE WA_DNLINE
				vr_recfl CommonX,yvdi,xvdi,yvdi-celly
				IF top_handle=CommonHandle THEN
					dummy$=WindTLines$(file,(CommonH\celly)+(woOffy(CommonIndex)\celly)-1)
					v_gtext CommonX,CommonY+((CommonH\celly)*celly),MID$(dummy$+SPACE$(CommonW\cellx),(woOffx(CommonIndex)\cellx)+1)
					dummy$=WindTLines$(file,(CommonH\celly)+(woOffy(CommonIndex)\celly))
					vswr_setting=woVSWR(file,(CommonH\celly)+(woOffy(CommonIndex)\celly)) : vswr_mode vswr_setting
					v_gtext CommonX,CommonY+((CommonH\celly)*celly)+celly,MID$(dummy$+SPACE$(CommonW\cellx),(woOffx(CommonIndex)\cellx)+1)
				ELSE
					CALL TextWindRedraw
				END IF
			CASE WA_LFLINE : vr_recfl CommonX,yvdi,xvdi+cellx,yvdi : CALL TextWindRedraw
			CASE WA_RTLINE : vr_recfl CommonX,yvdi,xvdi-cellx,yvdi : CALL TextWindRedraw
			END SELECT
		END IF
	END IF
	junk=wind_get(CommonHandle,WF_NEXTXYWH,x1,y1,w1,h1)
WEND
junk=wind_update(END_UPDATE) : graf_mouse 257,0
ERASE src_MFDB&,des_MFDB&,xyarr : vswr_mode 1
END SUB


SUB TextWindRedraw
SHARED CommonHandle,CommonIndex,woTIndex(1),woOffX(1),woOffY(1),cellx,celly
SHARED WindTLines$(2),woTLines(1),expandtabsflag,mess(),woVSWR(2)
STATIC x,y,w,h,file,TotalChars,start_line,end_line,cur_line
STATIC dummy,dummy$,vswr_setting,x1,y1,w1,h1

IF TextWindowSystem=0 THEN EXIT SUB
CommonIndex=WhichWindow(CommonHandle) : IF CommonIndex=0 THEN EXIT SUB
junk=wind_get(CommonHandle,WF_WORKXYWH,x,y,w,h) : file=woTindex(CommonIndex)

TotalChars=woOffx(CommonIndex)\cellx : start_line=woOffy(CommonIndex)\celly
end_line=(h\celly)

IF start_line+end_line>woTLines(file) THEN end_line=woTLines(file)-start_line
IF start_line<0 THEN start_line=0
IF end_line>woTLines(file) THEN end_line=woTLines(file)

cur_line=start_line
FOR dummy=1 TO end_line+1
	vswr_setting=woVSWR(file,cur_line) : vswr_mode vswr_setting
	IF expandtabsflag OR TotalChars<>0 THEN
		IF expandtabsflag THEN
			dummy$=WindTLines$(file,cur_line)
			IF woOffx(CommonIndex)<>0 THEN
				dummy$=MID$(WindTLines$(file,cur_line),TotalChars+1)
			END IF
		ELSE
			dummy$=MID$(WindTLines$(file,cur_line),TotalChars+1)
		END IF
		v_gtext x,y+((cur_line-(start_line-1))*celly),dummy$+SPACE$(w\cellx)
	ELSE
		v_gtext x,y+((cur_line-(start_line-1))*celly),WindTLines$(file,cur_line)+SPACE$(w\cellx)
	END IF
	INCR cur_line
	vswr_mode 1
NEXT dummy
END SUB


SUB TextWindClose
SHARED HowManyWindows,CommonIndex,HowManyTextWindows,woTindex(1)
SHARED WindTLines$(2),woTLines(1),woVSWR(2)
STATIC dummy,i

FOR dummy=1 TO HowManyWindows+1
	IF woTindex(dummy)>woTindex(CommonIndex) THEN DECR woTindex(dummy)
NEXT dummy
DECR HowManyTextWindows

FOR dummy=woTindex(CommonIndex)+1 TO HowManyTextWindows
	woTLines(dummy-1)=woTLines(dummy)
	FOR i=0 TO UBOUND(WindTLines$,2)
		WindTLines$(dummy-1,i)=WindTLines$(dummy,i)
		woVSWR(dummy-1,i)=woVSWR(dummy,i)
	NEXT i
NEXT dummy
woTindex(CommonIndex)=0
END SUB


SUB TextWindLoop (BYVAL key_pressed)
SHARED mess(),woType(1),WindowSystem
STATIC dummy,x,y,top_handle

junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
IF WindowSystem THEN
	dummy=WhichWindow(top_handle)
	IF woType(dummy)=2 THEN
		junk=wind_get(top_handle,WF_HSLIDE,x,junk,junk,junk)
		junk=wind_get(top_handle,WF_VSLIDE,y,junk,junk,junk)
		mess(3)=top_handle
		SELECT CASE key_pressed
		CASE 19200
			IF NOT x=1 THEN mess(0)=WM_ARROWED : mess(4)=WA_LFLINE : CALL WindowArrowed(top_handle,WA_LFLINE)
		CASE 19712
			IF NOT x=1000 THEN mess(0)=WM_ARROWED : mess(4)=WA_RTLINE : CALL WindowArrowed(top_handle,WA_RTLINE)
		CASE 19252
			IF NOT x=1 THEN mess(0)=WM_ARROWED : mess(4)=WA_LFPAGE : CALL WindowArrowed(top_handle,WA_LFPAGE)
		CASE 19766
			IF NOT x=1000 THEN mess(0)=WM_ARROWED : mess(4)=WA_RTPAGE : CALL WindowArrowed(top_handle,WA_RTPAGE)
		CASE 18432
			IF NOT y=1 THEN mess(0)=WM_ARROWED : mess(4)=WA_UPLINE : CALL WindowArrowed(top_handle,WA_UPLINE)
		CASE 20480
			IF NOT y=1000 THEN mess(0)=WM_ARROWED : mess(4)=WA_DNLINE : CALL WindowArrowed(top_handle,WA_DNLINE)
		CASE 18488
			IF NOT y=1 THEN mess(0)=WM_ARROWED : mess(4)=WA_UPPAGE : CALL WindowArrowed(top_handle,WA_UPPAGE)
		CASE 20530
			IF NOT y=1000 THEN mess(0)=WM_ARROWED : mess(4)=WA_DNPAGE : CALL WindowArrowed(top_handle,WA_DNPAGE)
		END SELECT
	END IF
END IF
END SUB

'[*END OF FILE*]
