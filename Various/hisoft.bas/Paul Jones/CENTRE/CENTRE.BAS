REM $option y+,q300
'WINDOW OFF : REM Goodbye! BASIC window routines, NOW!
LIBRARY "GEMAES"
DEFINT a-z
'j=shel_read(progname$,comandline$)
'j=form_alert(1,"[4]["+progname$+"|"+comandline$+"][ok]")





REM $include gemaes.bh
REM $include centre.bh
DECLARE FUNCTION newform_alert(BYVAL button,BYVAL addr&)
myco=win_name+win_close+win_move+win_info+&h4000

j=wind_get(0,wf_workxywh,XM,YM,WM,HM)

DIM mess(7)
f=rsrc_load("CENTRE.RSC")
IF f=0 THEN mm=form_alert(1,"[3][CENTRE.RSC][OK]") : SYSTEM

mm=rsrc_gaddr(0,0,menu&)
menu_bar menu&,1 : REM Put in menu mar

mpos=menu_register(PEEKW(PEEKL(GB+4)+4),"  Centre            ") : REM my app's name

REM setup done, main program.
time&=100
main:
e=evnt_multi(mu_mesag+mu_button,258,3,0,0,0,0,0,0,0,0,0,0,0,VARPTR(mess(0)),time&,xa,ya,buttona,kstate,k,br) 
IF e AND mu_mesag THEN do_message mess(0) : ' deal with a message
IF e AND mu_button AND buttona>0 THEN do_mouse xa,ya,buttona : ' deal with a click



GOTO main:

REM end routine
Pquit:
menu_bar menu&,0 : REM remove menu bar
IF a_open=1 THEN a_open=0 : j=wind_close(a_handle) : j=wind_delete(a_handle)

r=rsrc_free
IF r=0 THEN r=form_alert(1,"[1][Centre:|rsrc_free][OK]")
SYSTEM


SUB do_message(BYVAL mes_type)
SHARED mess(1),menu&,tt
SHARED a_open,a_handle,about&,x_in,y_in,w_in,h_in,myco,nde&,xm,ym,wm,hm
STATIC title,item,j,jj,f,gdf
LOCAL xre,yre,wre,hre
'f=form_alert(1,"[4]["+STR$(mes_type)+"][ok]")

SELECT CASE mes_type
CASE &H4711
WINDOW OPEN 1,"!",80,80,300,300,win_name
FOR gdf=0 TO 7
? mess(gdf)
NEXT gdf
j=evnt_keybd
WINDOW CLOSE 1
CASE mn_selected 
title=mess(3)
item=mess(4)
menu_tnormal menu&,title,1
IF title=Mdesk AND item=Mcentre THEN CALL about_me
IF title=Mfile AND item=MQuit THEN GOTO Pquit:
IF title=Msystem AND item=newd THEN
	j=rsrc_gaddr(0,NEWDESK,nde&)
	POKEW nde&+ob_x,xm
	POKEW nde&+ob_y,ym
	POKEW nde&+ob_width,wm
	POKEW nde&+ob_height,hm
	j=wind_set(0,WF_NEWDESK,PEEKW(VARPTR(nde&)),PEEKW(VARPTR(nde&)+2),0,0)
	form_dial 3,0,0,0,0,xm,ym,wm,hm

END IF
IF (title<>Msystem) OR (Item<>24) THEN GOTO skipck:
REM checkbox
REM is it checked?
IF PEEKW(menu&+ob_sizeof*24+ob_state)*mask_checked=0 THEN j=1 : ELSE j=0
REM check it.
menu_icheck menu&,24,j
IF j=1 THEN jj=objc_sysvar(1,backgrcol,13,0,0,0)
IF j=0 THEN jj=objc_sysvar(1,backgrcol,8,0,0,0)

skipck:
IF title=Msystem AND item=newr THEN j=wind_set(0,WF_NEWDESK,0,0,0,0) : nde&=0


CASE wm_redraw
IF mess(3)=a_handle AND a_open=1 THEN
	j=wind_update(1)
	j=wind_get(a_handle,wf_firstxywh,xre,yre,wre,hre)
	DO
	IF wre=0 AND hre=0 THEN EXIT LOOP
	j=objc_draw(about&,0,4,xre,yre,wre,hre)
	j=wind_get(a_handle,wf_nextxywh,xre,yre,wre,hre)
	LOOP
	j=wind_update(0)
END IF
menu_tnormal menu&,title,1
CASE wm_moved
IF mess(3)=a_handle AND a_open=1 THEN




	j=wind_calc(1,myco,mess(4),mess(5),mess(6),mess(7),x_in,y_in,w_in,h_in)
	POKEW about&+ob_sizeof*0+ob_x,x_in : REM set form to new value
	POKEW about&+ob_sizeof*0+ob_y,y_in : REM set form to new value
'	j=objc_draw(about&,0,4,x_in,y_in,w_in,h_in)
	j=wind_set(a_handle,wf_currxywh,mess(4),mess(5),mess(6),mess(7))
	END IF
CASE wm_closed
IF mess(3)=a_handle AND a_open=1 THEN CALL close_about
CASE wm_topped
REM top my window
IF mess(3)=a_handle THEN j=wind_set(a_handle,wf_top,tt,0,0,0)

END SELECT
END SUB

SUB do_mouse(BYVAL x,BYVAL y,BYVAL button)
STATIC x,y,button,ms&,h,j,xm,ym,wm,hm,bx,by,st,wcel,hcel,ob&,mstate,mflags,ddx,ddy,slid
SHARED handle,a_handle,a_open,about&,nde&

REM what's this? One of the windows has been clicked on
handle=wind_find(x,y)

REM is it on centre_desk?!?         icon clicked on?
IF handle=0 AND nde&<>0 THEN
	h=objc_find(nde&,0,4,x,y)
	IF h=0 THEN GOTO desk:
	ms&=nde&+(ob_sizeof*h)+ob_state
	REM make selected
	POKEW ms&,(PEEKW(ms&) AND &HFFFE)+(1-(PEEKW(ms&) AND 1))
	REM redraw
	j=objc_draw(nde&,h,0,xm,ym,wm,hm)
	form_dial 3,0,0,0,0,PEEKW(nde&+(ob_sizeof*h)+ob_x),PEEKW(nde&+(ob_sizeof*h)+ob_y),PEEKW(nde&+(ob_sizeof*h)+ob_width),PEEKW(nde&+(ob_sizeof*h)+ob_height)
	
desk:
END IF	   

REM but which one? Is it mine?

REM was it the about form dialogue?
REM if it's mine and mine is open then...
IF (handle<>a_handle) OR (a_open<>1) THEN GOTO mieow:
h=objc_find(about&,0,4,x,y)

REM The drag and drop part!

IF h<>7 THEN GOTO ddskip:

j=wind_get(0,wf_workxywh,XM,YM,WM,HM)
ob&=about&+ob_sizeof*h
mstate=PEEKW(about&+h*ob_sizeof+ob_state)
mstate=(mstate AND (NOT mask_selected))+mask_selected
J=objc_change(about&,h,xm,ym,wm,hm,mstate,1)
ob&=about&+ob_sizeof*h


j=objc_offset(about&,h,wcel,hcel)
graf_dragbox PEEKW(ob&+ob_width),PEEKW(ob&+ob_height),wcel,hcel,xm,ym,wm,hm,ddx,ddy

j=form_alert(1,"[4][Dragdrop concluded at|x="+STR$(ddx)+"|y="+STR$(ddy)+"][OK]")

mstate=(mstate AND (NOT mask_selected))+mask_normal
J=objc_change(about&,h,xm,ym,wm,hm,mstate,1)
EXIT SUB

ddskip:

REM the slider part:
IF h<>10 THEN GOTO slskip:

REM mouse must be down! that is why I can check
graf_mkstate 0,0,j,0 : REM only interested in mouse button state!
IF j<>0 THEN slid=graf_slidebox(about&,9,10,1) : REM slide object 10 inside 9 inside about& (1=vertical 0=horizontal)
j=form_alert(1,"[4][Slider positioned|"+STR$(slid)+"][OK]")
EXIT SUB

Slskip:


mstate=PEEKW(about&+h*ob_sizeof+ob_state)
mflags=PEEKW(about&+h*ob_sizeof+ob_flags)
IF mflags AND mask_touchexit THEN CALL close_about : EXIT SUB
IF (mflags AND mask_selectable)=0 THEN GOTO mieow:
j=mflags AND (mask_rbutton+mask_exit)
SELECT CASE j
	CASE mask_rbutton
	mstate=(mstate AND (NOT mask_selected))+mask_selected
	CASE mask_exit
	mstate=(mstate AND (NOT mask_selected))+mask_selected
	CASE mask_exit+mask_rbutton
	mstate=(mstate AND (NOT mask_selected))+mask_selected
	CASE mask_normal
	mstate=(mstate AND (NOT mask_selected))+(mask_selected-(mstate AND mask_selected))
END SELECT
J=objc_change(about&,h,xm,ym,wm,hm,mstate,1)
IF (mflags AND mask_exit)=0 THEN GOTO mieow: : REM exit button part
graf_mkstate bx,by,st,j
DO UNTIL objc_find(about&,0,4,bx,by)<>h OR st=0
graf_mkstate bx,by,st,j
LOOP
mstate=(mstate AND (NOT mask_selected))+mask_normal
J=objc_change(about&,h,xm,ym,wm,hm,mstate,1)
IF st<>0 THEN mieow:
CALL close_about : EXIT SUB
mieow:
 



END SUB

SUB close_about
SHARED a_open,a_handle,x_in,y_in,w_in,h_in
STATIC j,xsm,ysm,wsm,hsm,state,kstate
IF a_open=0 THEN EXIT SUB
WSM=10 : HSM=10
graf_mkstate xsm,ysm,state,kstate
j=wind_close(a_handle)
j=wind_delete(a_handle)
form_dial 2,xsm,ysm,wsm,hsm,x_in,y_in,w_in,h_in
form_dial 3,xsm,ysm,wsm,hsm,x_in,y_in,w_in,h_in
a_open=0
END SUB




SUB about_me
STATIC mm,j,state,kstate
SHARED about&,a_handle,a_open,x_in,y_in,w_in,h_in,myco
STATIC XSM,YSM,WSM,HSM,xab,yab,wab,hab,attl&

IF a_open=1 THEN EXIT SUB
WSM=10 : HSM=10
graf_mkstate xsm,ysm,state,kstate

mm=rsrc_gaddr(0,FORM2,about&)
form_center about&,x_in,y_in,w_in,h_in
x_in=(x_in+4) AND &hFFF8 : REM align form window
POKEW about&+ob_sizeof*0+ob_x,x_in : REM set form to new value
j=wind_calc(0,myco,x_in,y_in,w_in,h_in,xab,yab,wab,hab) : REM what is the size of my form window?

a_handle=wind_create(myco,xab,yab,wab,hab) : REM create window
form_dial 0,xsm,ysm,wsm,hsm,x_in,y_in,w_in,h_in
form_dial 1,xsm,ysm,wsm,hsm,x_in,y_in,w_in,h_in

REM give my form window a title
j=rsrc_gaddr(5,TTLE4,attl&) : REM GET title string
j=wind_set(a_handle,wf_name,PEEKW(VARPTR(attl&)),PEEKW(VARPTR(attl&)+2),0,0)
REM give it to my form_window

j=wind_open(a_handle,xab,yab,wab,hab)
'j=objc_draw(about&,0,10,x_in,y_in,w_in,h_in)
a_open=1 : REM Yes! The form window is now open.

END SUB








FUNCTION newform_alert(BYVAL button,BYVAL addr&)
POKEW PEEKL(GB+8),button	'int_in
POKEL PEEKL(GB+16),addr&	'addr_in
GEMSYS(52)					
newform_alert%=PEEKW(PEEKL(GB+20))
END FUNCTION



