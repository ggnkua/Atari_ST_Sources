' The MFDB structure
CONST fd_addr=0,fd_w=2,fd_h=3,fd_wdwidth=4,fd_stand=5,fd_nplanes=6
CONST fd_r1=7,fd_r2=8,fd_r3=9,fd_size=9
CONST wa_uppage=0,wa_dnpage=1,wa_upline=2,wa_dnline=3
CONST wa_lfpage=4,wa_rtpage=5,wa_lfline=6,wa_rtline=7
DIM source(fd_size),dest(fd_size),xy(8)

SUB WindowArrowed2(VAL win,VAL type)
SHARED woOffY(),text_counter,celly,lines,tsummary,curline,linestodo,leave,mess()
STATIC x,y,w,h,position,i,size

junk=wind_get(win,WF_WORKXYWH,x,y,w,h)
lines=h\celly
i=WhichWindow(win)
curline=woOffY(i)\celly

IF mess(0)=wm_sized THEN IF curline>(tsummary-lines+1) THEN woOffY(i)=(tsummary-lines+1)*celly:Redraw win,x,y,w,h:leave=1:EXIT SUB
IF mess(0)=wm_fulled THEN IF curline>(tsummary-lines+1) THEN woOffY(i)=(tsummary-lines+1)*celly:ReDraw win,x,y,w,h:leave=1:EXIT SUB

SELECT CASE type
   CASE WA_UPPAGE:EXIT SUB
   CASE WA_DNPAGE:EXIT SUB
   CASE WA_UPLINE:IF (curline-1)<0 THEN leave=1:woOffY(i)=0:UpdateSliders:EXIT SUB
   CASE WA_DNLINE
	IF (curline+1)>tsummary-lines+1 THEN leave=1:EXIT SUB
END SELECT

SHARED woOffX(1),woOffY(1),cellx,celly,woSliderMax&(1)
SHARED commonhandle,commoni,commonmaxx,Commonmaxy,which,WindowHandle
STATIC x,y,w,h,NewX,NewY

WindowHandle=win
which=type

commoni=WhichWindow(WindowHandle)
junk=wind_get(WindowHandle,WF_WORKXYWH,x,y,w,h)
h=(h\celly)*celly
w=(w\cellx)*cellx
NewX=woOffX(commoni): NewY=woOffY(commoni)
SELECT CASE which
CASE	0: NewY=NewY-h
CASE 	1: NewY=NewY+h
CASE	2: NewY=NewY-celly
CASE	3: NewY=NewY+celly
CASE	4: NewX=NewX-w
CASE	5: NewX=NewX+w
CASE	6: NewX=NewX-cellx
CASE	7: NewX=NewX+cellx
END SELECT
commonhandle=WindowHandle
CALLS woSliderMax&(commoni)
woOffX(commoni)=MAX(MIN(NewX,((commonmaxx-w-1)\cellx+1)*cellx),0)
woOffY(commoni)=MAX(MIN(NewY,((commonmaxy-h-1)\celly+1)*celly),0)

SELECT CASE type
   CASE WA_UPPAGE:EXIT SUB
   CASE WA_DNPAGE:EXIT SUB
   CASE WA_UPLINE
		text_counter=curline-1
		IF text_counter<0 THEN EXIT SUB
		DisplayText2 commonhandle,which   'up
   CASE WA_DNLINE
		text_counter=curline+1
		IF text_counter>tsummary-lines+1 THEN EXIT SUB
		DisplayText1 commonhandle,which   'down
END SELECT
UpdateSliders
leave=1
END SUB

SUB DisplayText1(handle,which)
SHARED source(),dest(),xy(),summary$(),text_counter,summary_handle,celly,lines
STATIC x,y,w,h,wx,wy,ww,wh,handle,i,top_handle

junk=wind_get(junk,wf_top,top_handle,junk,junk,junk)
junk=wind_get(handle,wf_workxywh,wx,wy,ww,wh)
junk=wind_get(handle,wf_firstxywh,x,y,w,h)
junk=wind_update(beg_update)
MOUSE -1
WHILE w>0 AND h>0
	CALL vs_clip(1,x,y,x+w-1,y+h-1)
	xy(0)=x
	xy(1)=y+celly
	xy(2)=x+w
	xy(3)=y+h
	xy(4)=x
	xy(5)=y
	xy(6)=x+w
	xy(7)=y+h-celly
	CALL vro_cpyfm(3,xy(),VARPTR(source(0)),VARPTR(dest(0)))
	vst_color 1
	vsf_color 0
	vr_recfl x,y+h-celly,x+w,y+h
	IF NOT top_handle=summary_handle THEN	
		v_gtext wx,wy+((lines)*celly)," "+summary$(text_counter+lines-1)
		i=(y-wy)/celly
		IF i=<2 THEN i=2
		v_gtext wx,wy+((i-1)*celly)," "+summary$(text_counter+i-2)
		v_gtext wx,wy+(i*celly)," "+summary$(text_counter+i-1)
		v_gtext wx,wy+((i+1)*celly)," "+summary$(text_counter+i)
		i=(y+h-wy)/celly
		IF i=<2 THEN i=2
		v_gtext wx,wy+((i-1)*celly)," "+summary$(text_counter+i-2)
		v_gtext wx,wy+(i*celly)," "+summary$(text_counter+i-1)
		v_gtext wx,wy+((i+1)*celly)," "+summary$(text_counter+i)
	ELSE
		v_gtext wx,wy+((lines)*celly)," "+summary$(text_counter+lines-1)
	END IF
	junk=wind_get(handle,wf_nextxywh,x,y,w,h)
WEND
junk=wind_update(end_update)
MOUSE 0
END SUB

SUB DisplayText2(handle,which)
SHARED source(),dest(),xy(),summary$(),text_counter,summary_handle,celly,lines
STATIC x,y,w,h,wx,wy,ww,wh,handle,i,top_handle

junk=wind_get(junk,wf_top,top_handle,junk,junk,junk)
junk=wind_get(handle,wf_workxywh,wx,wy,ww,wh)
junk=wind_get(handle,wf_firstxywh,x,y,w,h)
junk=wind_update(beg_update)
MOUSE -1
WHILE w>0 AND h>0
	CALL vs_clip(1,x,y,x+w-1,y+h-1)
	xy(0)=x
	xy(1)=y
	xy(2)=x+w
	xy(3)=y+h-celly
	xy(4)=x
	xy(5)=y+celly
	xy(6)=x+w
	xy(7)=y+h
	CALL vro_cpyfm(3,xy(),VARPTR(source(0)),VARPTR(dest(0)))
	vst_color 1
	vsf_color 0
	vr_recfl x,y,x+w,y+celly
	IF NOT top_handle=summary_handle THEN	
		v_gtext wx,wy+celly," "+summary$(text_counter)
		i=(y-wy)/celly
		IF i=<2 THEN i=2
		v_gtext wx,wy+(i*celly)," "+summary$(text_counter+i-1)
		v_gtext wx,wy+((i+1)*celly)," "+summary$(text_counter+i)
		v_gtext wx,wy+((i+2)*celly)," "+summary$(text_counter+i+1)
		i=(y+h-wy)/celly
		IF i=<2 THEN i=2
		v_gtext wx,wy+(i*celly)," "+summary$(text_counter+i-1)
		v_gtext wx,wy+((i+1)*celly)," "+summary$(text_counter+i)
		v_gtext wx,wy+((i+2)*celly)," "+summary$(text_counter+i+1)
	ELSE
		v_gtext wx,wy+celly," "+summary$(text_counter)
	END IF
	junk=wind_get(handle,wf_nextxywh,x,y,w,h)
WEND
junk=wind_update(end_update)
MOUSE 0
END SUB
