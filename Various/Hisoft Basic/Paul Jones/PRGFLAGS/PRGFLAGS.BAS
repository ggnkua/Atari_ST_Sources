WINDOW OFF
REM $option y+,q300
LIBRARY "GEMAES","GEMVDI","GEMDOS","BIOS","XBIOS","MINT"
DEFINT a-z
REM check if OS understands iconify and tell it I understand ap_term
IF &H400<=PEEKW(PEEKL(GB+4)) THEN j=appl_getinfo(11,windflag,0,0,0) : j=shel_write(9,1,0,0,0)


REM check if run from an auto folder...
IF PEEKW(PEEKL(GB+4))=0 THEN CCONWS "PRGFLAGS needs GEM to run Properly!" : SYSTEM


REM $include prgflag3.bh
REM $include gemaes.bh
DIM mess(7) : REM message space


REM this section is for 65535 windows

REM $dynamic
REM handle_handlers

REM current GEM allows 15 windows

DIM windnum(15),wtype(15),w_ob(15),wedit(15)

REM if type=1 then wedit=current field edit index w_ob=current edit field

REM if type=0 then windnum=2 for open,1=created/closed, 0=deleted/notmine
REM window type, 0=ordinary, 1=form
REM if type=1 then windnum=tree number for form window
REM if type=2 alliconified form : windnum=tree number

REM $static


REM declare functions
DECLARE SUB do_message(BYVAL mes_type)
DECLARE FUNCTION dialog(BYVAL tree,BYVAL num)
DECLARE FUNCTION newform_alert(BYVAL button,BYVAL num)
DECLARE FUNCTION form_window(BYVAL tree,BYVAL title,BYVAL myco)

REM window buttons are...
myco=win_name+win_close+win_move+&H4000



REM load RSC file based on cookie
IF GETCOOKIE("_AKP",j&)=0 THEN j&=3: ELSE j&=j& AND &HFFFF
retry:
g$="PRGFLAGS"
rn$=STR$(j&) : rn$=RIGHT$(rn$,LEN(rn$)-1) : IF LEN(rn$)<8 THEN rn$=LEFT$(g$,8-LEN(rn$))+rn$ 
rn$=rn$+".RSC"
r=rsrc_load(rn$)
IF r=0 AND j&=3 THEN j=form_alert(1,"[3]["+rn$+"][OK]") : SYSTEM
IF r=0 AND j&<>3 THEN j&=3 : GOTO retry:
rn$="" : g$=""



j=rsrc_gaddr(0,MENU,menu&)
mnu=1 : menu_bar menu&,1 : REM put menu bar

REM ### If Multitasking present, register menu bar ######################11111222223333344444####
IF PEEKW(PEEKL(GB+4)+2)=-1 THEN mpos=menu_register(PEEKW(PEEKL(GB+4)+4),"  Prgflags setter   ")



REM main message loop
main:
e=evnt_multi(mu_mesag+mu_button+mu_keybd,258,3,0,0,0,0,0,0,0,0,0,0,0,VARPTR(mess(0)),time&,xa,ya,buttona,kstate,k,br)
IF e AND mu_mesag THEN do_message mess(0) : ' deal with a message
IF e AND mu_button AND buttona>0 THEN do_mouse xa,ya,buttona : ' deal with a click
IF e AND mu_keybd THEN do_keybd k
GOTO main:


endprog:
REM close windows
FOR CW=1 TO UBOUND(windnum)
IF wtype(CW)=0 THEN
	IF windnum(CW)=2 THEN j=wind_close(CW) : windnum(CW)=1
	IF windnum(CW)=1 THEN j=wind_delete(CW) : windnum(CW)=0
END IF

IF wtype(CW)=1 THEN
	j=wind_close(CW) : j=wind_delete(CW)
	wtype(CW)=0 : wind_num(CW)=0
END IF

IF wtype(CW)=2 THEN
	j=wind_delete(CW)
	wtype(CW)=0 : windnum(CW)=0
END IF
NEXT CW

IF PEEKW(PEEKL(GB+4)+2)=-1 THEN j=menu_unregister(mpos)
IF mnu=1 THEN menu_bar menu&,0
r=rsrc_free
SYSTEM



SUB do_message(BYVAL mes_type) STATIC

LOCAL pip,f,cc$,m&,j,title,item,tree&,tt,ii,m
LOCAL xre,yre,wre,hre
LOCAL x_in,y_in,w_in,h_in
LOCAL x,y,w,h,x2,y2,w2,h2

SHARED mess(0),menu&,windnum(0),wtype(0),myco,windflag,allicons





SELECT CASE mes_type

	CASE ap_dragdrop
	REM IS NOT currently used by this program, still
	REM is good programming practise to reject rather
	REM than ignore requests
	pip=fopen("U:\PIPE\DRAGDROP."+CHR$(PEEKB(VARPTR(mess(7))))+CHR$(PEEKB(VARPTR(mess(7))+1)),2)
	IF pip<0 THEN f=form_error(ABS(pip)-31) : GOTO mm:
	cc$=CHR$(1)
	m&=fwrite&(pip,1&,VARPTR(cc$))
	mm:
	IF pip>-1 THEN j=fclose(pip)
	CASE 50 : REM ap_term

	IF mess(4)=50 THEN GOTO endprog:



	CASE mn_selected 
	title=mess(3)
	item=mess(4)
	menu_tnormal menu&,title,1
	IF title=desk AND item=prgflags THEN
		REM check if ABOUT window is already open

		FOR j=0 TO UBOUND(windnum)
		IF windnum(j)=ABOUT AND wtype(j)=1 THEN EXIT IF : REM can't have more than one about open!
		NEXT j

		REM try to open about's window
		j=form_window(ABOUT,ABOUT_T,MYCO)
		REM could not open
		IF j<0 THEN j=rsrc_gaddr(5,WINDOWERROR,tree&) : j=newform_alert(1,tree&) : EXIT IF

		REM increase array size if needed
		IF j>UBOUND(windnum) THEN REDIM PRESERVE windnum(j)
		IF j>UBOUND(wtype) THEN REDIM PRESERVE wtype(j)
		REM ...and insert this window entry
		wtype(j)=1 : REM its a formwindow!!
		windnum(j)=ABOUT : REM rsrc_gaddr!

	END IF
 
	REM if quit pressed then exit...
	IF title=file AND item=quit THEN GOTO endprog:

	CASE wm_redraw

	IF wtype(mess(3))<>0 THEN GOTO skipreal:
	j=wind_get(mess(3),wf_firstxywh,xre,yre,wre,hre)
	DO
	IF wre=0 AND hre=0 THEN EXIT LOOP
	j=objc_draw(tree&,0,4,xre,yre,wre,hre)
	j=wind_get(mess(3),wf_nextxywh,xre,yre,wre,hre)
	LOOP

	graf_mouse 256,0
	'vs_clip 1,mess(4),mess(5),mess(6),mess(7)
	j=wind_get(mess(3),wf_firstxywh,xre,yre,wre,hre)
	DO
	IF wre=0 AND hre=0 THEN EXIT LOOP
	j=wind_update(1)
	REM update
	j=wind_update(0)
	j=wind_get(mess(3),wf_nextxywh,xre,yre,wre,hre)
	LOOP
	graf_mouse 257,0

	skipreal:


	REM redraw formdialog
	IF wtype(mess(3))<>1 THEN skipform:
	REM is it iconified?
	ii=0
	IF &H410<=PEEKW(PEEKL(GB+4)) AND (windflag AND &B10000000) THEN j=wind_get(mess(3),26,ii,w,h,0)



	IF ii=0 THEN j=rsrc_gaddr(0,windnum(mess(3)),tree&)
	IF ii<>0 THEN j=rsrc_gaddr(0,ICONIFIED,tree&)

	j=wind_get(mess(3),wf_firstxywh,xre,yre,wre,hre)
	DO
	IF wre=0 AND hre=0 THEN EXIT LOOP
	j=objc_draw(tree&,0,4,xre,yre,wre,hre)
	j=wind_get(mess(3),wf_nextxywh,xre,yre,wre,hre)
	LOOP

	skipform:

 	CASE 34 : REM wm_iconify
	IF &H410<=PEEKW(PEEKL(GB+4)) AND (windflag AND &B10000000) THEN

		j=rsrc_gaddr(0,ICONIFIED,tree&)
		j=wind_get(mess(3),wf_currxywh,x,y,w,h)
		j=wind_calc(1,win_name,mess(4),mess(5),mess(6),mess(7),x_in,y_in,w_in,h_in)

		graf_shrinkbox mess(4),mess(5),mess(6),mess(7),x,y,w,h

		POKEW tree&+ob_sizeof*0+ob_x,x_in : REM set form to new value
		POKEW tree&+ob_sizeof*0+ob_y,y_in : REM set form to new value
		POKEW tree&+ob_sizeof*0+ob_width,w_in
		POKEW tree&+ob_sizeof*0+ob_height,h_in
		j=wind_set(mess(3),26,mess(4),mess(5),mess(6),mess(7))
	END IF

	CASE 35 : REM wm_uniconify


	IF &H410<=PEEKW(PEEKL(GB+4)) AND (windflag AND &B100000000) THEN
		j=wind_get(mess(3),wf_currxywh,x,y,w,h)
		graf_growbox x,y,w,h,mess(4),mess(5),mess(6),mess(7)
		j=wind_set(mess(3),27,mess(4),mess(5),mess(6),mess(7))
	END IF 

	CASE 36 : REM wm_alliconify


	REM if alliconify icon not already on screen/ create it

	IF allicons>0 THEN GOTO removewindowsonly: 
	j=wind_get(0,wf_workxywh,x,y,w,h)
	m=wind_create(win_name+win_move,x,y,w,h) 
	IF m<0 THEN j=rsrc_gaddr(5,WINDOWERROR,tree&) : j=newform_alert(1,tree&) : GOTO cantalliconify:
		
	IF NOT((&H410<=PEEKW(PEEKL(GB+4))) AND (windflag AND &B10000000)) THEN
		j=wind_delete(m): BEEP
		GOTO cantalliconify:
	END IF
			
	j=wind_set(m,26,mess(4),mess(5),mess(6),mess(7))
	j=rsrc_gaddr(5,ALLICON_T,tree&)
	j=wind_set(m,wf_name,PEEKW(VARPTR(tree&)),PEEKW(VARPTR(tree&)),0,0)
	j=wind_open(m,mess(4),mess(5),mess(6),mess(7)) 

	allicons=m

	removewindowsonly:
	REM close all other windows

	FOR tt=1 TO UBOUND(windnum)
	REM if it's real and open then
	IF wtype(tt)=0 AND windnum(tt)=2 THEN
		j=wind_close(tt)
		windnum(tt)=1
		REM close it
	END IF

	REM if it's a formwindow/ close it.
	IF wtype(tt)=1 THEN wtype(tt)=2 : j=wind_close(tt)
	NEXT tt

	cantalliconify:
	CASE wm_sized,wm_moved
	REM formwindows need this, real ones don't
	IF wtype(mess(3))<>1 THEN GOTO skipformmoved:

	ii=0
	IF &H410<=PEEKW(PEEKL(GB+4)) AND (windflag AND &B10000000) THEN j=wind_get(mess(3),26,ii,0,0,0)

	IF ii=0 THEN j=rsrc_gaddr(0,windnum(mess(3)),tree&)
	IF ii<>0 THEN j=rsrc_gaddr(0,ICONIFIED,tree&)

	IF ii=0 THEN j=wind_calc(1,myco,mess(4),mess(5),mess(6),mess(7),x_in,y_in,w_in,h_in)
	IF ii<>0 THEN j=wind_calc(1,win_name,mess(4),mess(5),mess(6),mess(7),x_in,y_in,w_in,h_in)

	POKEW tree&+ob_sizeof*0+ob_x,x_in : REM set form to new value
	POKEW tree&+ob_sizeof*0+ob_y,y_in : REM set form to new value
	POKEW tree&+ob_sizeof*0+ob_width,w_in
	POKEW tree&+ob_sizeof*0+ob_height,h_in


	skipformmoved:
	j=wind_set(mess(3),wf_currxywh,mess(4),mess(5),mess(6),mess(7))




	CASE wm_fulled
	j=wind_get(mess(3),wf_currxywh,x,y,w,h)
	j=wind_get(mess(3),wf_fullxywh,x2,y2,w2,h2)
	IF x=x2 AND y=y2 AND w=w2 AND h=h2 THEN
		j=wind_get(mess(3),wf_prevxywh,x2,y2,w2,h2)
	END IF
	j=wind_set(mess(3),wf_currxywh,x2,y2,w2,h2)

	CASE wm_closed
	j=wind_close(mess(3)) 
	j=wind_delete(mess(3))
	windnum(mess(3))=0
	wtype(mess(3))=0

	CASE wm_topped
	j=wind_set(mess(3),wf_top,tt,0,0,0)

END SELECT
END SUB


SUB do_keybd(BYVAL k)
LOCAL j,ky,tw,state,x,y,w,h,n,kx,tree&,flags,index,stay
SHARED mess(0),wtype(0),windnum(0),w_ob(0),wedit(0)


REM split key into ASCII and scancode
KY=k AND 255
kx=(k AND &HFF00)/&H100

REM find the topped window
j=wind_get(0,wf_top,tw,0,0,0)

REM is it my window?
IF tw>UBOUND(wtype) THEN EXIT SUB

REM is it a formwindow?
IF wtype(tw)<>1 THEN GOTO skipedit:

REM any f(box)text's? : w_ob contains the objectnumber of the object being edited
IF w_ob(tw)=-1 THEN GOTO skipedit:

REM Get formwindow tree address
j=rsrc_gaddr(0,windnum(tw),tree&)

REM and get the position of the cursor in the f(box)text

index=wedit(tw) : REM wedit contains the position of the cursor in the object currently being edited

REM process f(box)text with new character
j=objc_edit(tree&,w_ob(tw),k,index,2)

stay=index-wedit(tw)
wedit(tw)=index

skipedit:


REM process default buttons in formdialogs

IF (ky<>13) OR (wtype(tw)<>1) OR stay<>0 THEN GOTO skipdefault:

REM get form address
j=rsrc_gaddr(0,windnum(tw),tree&)

REM search for a default object

n=0
again:
flags=PEEKW(tree&+ob_sizeof*n+ob_flags)
REM found one
IF flags AND mask_default THEN GOTO do_it:
REM none found
IF flags AND mask_lastob THEN GOTO skipdefault:
INCR n : GOTO again:


REM Animate and activate default button
do_it:
state=PEEKW(tree&+ob_sizeof*n+ob_state) AND &HFFFE
x=PEEKW(tree&+ob_sizeof*0+ob_x)
y=PEEKW(tree&+ob_sizeof*0+ob_y)
w=PEEKW(tree&+ob_sizeof*0+ob_width)
h=PEEKW(tree&+ob_sizeof*0+ob_height)
	

j=objc_change(tree&,n,x,y,w,h,state+mask_selected,1)
mess(3)=tw : mess(0)=wm_closed : appl_write PEEKW(PEEKL(GB+4)+4),16,VARPTR(mess(0))
j=objc_change(tree&,n,x,y,w,h,state+mask_normal,0)
skipdefault:

END SUB



REM standard dialog box routine

FUNCTION dialog(BYVAL tree,BYVAL num)
LOCAL tree&,j,x1,y1,w1,h1,x,y,w,h
w1=10 : h1=10

graf_mkstate x1,y1,0,0
j=rsrc_gaddr(0,tree,tree&) 
form_center tree&,x,y,w,h
form_dial 1,x1,y1,w1,h1,x,y,w,h
form_dial 0,x1,y1,w1,h1,x,y,w,h
j=objc_draw(tree&,0,10,x,y,w,h)
dialog=form_do(tree&,num)
form_dial 3,x1,y1,w1,h1,x,y,w,h
form_dial 2,x1,y1,w1,h1,x,y,w,h
END FUNCTION


SUB do_mouse(x,y,b)
LOCAL x,y,w,h,b,ob,h,j,tree&,flags,obfind,nxt,prv,parent,obj,state,jj,oldstate,ii
SHARED wtype(0),windnum(0),mess(0),windflag

REM Find the window the user clicked upon

h=wind_find(x,y)
REM h=window id or 0 if the desktop was clicked

IF h>UBOUND(wtype) THEN EXIT SUB : REM It's not my window

REM this routine is currently only for formwindow buttons
IF wtype(h)<>1 THEN EXIT SUB: REM currently only formwindows!

REM is it iconified?

ii=0
IF &H410<=PEEKW(PEEKL(GB+4)) AND (windflag AND &B10000000) THEN j=wind_get(mess(3),26,ii,0,0,0)




REM get address of form
IF ii=0 THEN j=rsrc_gaddr(0,windnum(h),tree&)
IF ii<>0 THEN j=rsrc_gaddr(0,ICONIFIED,tree&)

REM and find the object in the formwindow that is being clicked

ob=objc_find(tree&,0,10,x,y)
REM oops, that was not an object
IF ob<0 THEN EXIT SUB

REM get the flags of the clicked object, so we know what to do.

flags=PEEKW(tree&+ob*ob_sizeof+ob_flags)
oldstate=PEEKW(tree&+ob*ob_sizeof+ob_state)


REM if it's a touchexit the form closes immediately

IF flags AND mask_touchexit THEN mess(3)=h : mess(0)=wm_closed : appl_write PEEKW(PEEKL(GB+4)+4),16,VARPTR(mess(0))
IF (flags AND mask_selectable)=0 THEN EXIT SUB

REM Process radiobuttons
IF (flags AND mask_rbutton)=0 THEN GOTO skipradio:
REM Find parent of this object


obfind=ob
	
findparentagain:
nxt=PEEKW(tree&+ob_sizeof*obfind+ob_next)
prv=PEEKW(tree&+ob_sizeof*nxt+ob_tail)

IF nxt=-1 THEN EXIT SUB
IF obfind<>prv THEN obfind=nxt : GOTO findparentagain:
REM found the parent, now select the object and deselect other radios.

parent=nxt

obj=PEEKW(tree&+ob_sizeof*parent+ob_head)

nxtunsel:

IF (PEEKW(tree&+obj*ob_sizeof+ob_flags) AND mask_rbutton) AND obj<>ob THEN
	x=PEEKW(tree&+ob_sizeof*0+ob_x)
	y=PEEKW(tree&+ob_sizeof*0+ob_y)
	w=PEEKW(tree&+ob_sizeof*0+ob_width)
	h=PEEKW(tree&+ob_sizeof*0+ob_height)
	j=objc_change(tree&,obj,x,y,w,h,PEEKW(tree&+obj*ob_sizeof+ob_state) AND &HFFFE,1) : REM unselect objects
END IF

IF obj<>PEEKW(tree&+ob_sizeof*parent+ob_tail) THEN : obj=PEEKW(tree&+ob_sizeof*obj+ob_next) : GOTO nxtunsel:


x=PEEKW(tree&+ob_sizeof*0+ob_x)
y=PEEKW(tree&+ob_sizeof*0+ob_y)
w=PEEKW(tree&+ob_sizeof*0+ob_width)
h=PEEKW(tree&+ob_sizeof*0+ob_height)
j=objc_change(tree&,ob,x,y,w,h,(PEEKW(tree&+obj*ob_sizeof+ob_state) AND &HFFFE)+mask_selected,1) : REM select pressed radio object

EXIT SUB
skipradio:


state=PEEKW(tree&+ob_sizeof*ob+ob_state) AND &HFFFE


IF oldstate AND mask_selected THEN
jj=graf_watchbox(tree&,ob,state+mask_normal,state+mask_selected)
ELSE
jj=graf_watchbox(tree&,ob,state+mask_selected,state+mask_normal)
END IF



IF (jj=1) AND ((flags AND mask_exit)<>0) THEN
	mess(3)=h : mess(0)=wm_closed : appl_write PEEKW(PEEKL(GB+4)+4),16,VARPTR(mess(0))
	j=objc_change(tree&,ob,x,y,w,h,state+mask_normal,0)
END IF




END SUB





REM a function to open a formwindow

FUNCTION form_window(BYVAL tree,BYVAL title,BYVAL myco)
STATIC mm,j,tree,tree&,x_in,y_in,w_in,h_in,myco,handle
STATIC XSM,YSM,WSM,HSM,xab,yab,wab,hab,title,attl&,MX,MY,MW,MH
LOCAL alert&,edit,n,flags,k
SHARED index,newindex,w_ob(0),wedit(0)


j=wind_get(0,wf_workxywh,MX,MY,MW,MH) : REM get screen work area (excludes menu bar)

WSM=10 : HSM=10
graf_mkstate xsm,ysm,0,0

mm=rsrc_gaddr(0,tree,tree&)

x_in=PEEKW(tree&+ob_sizeof*0+ob_x)
y_in=PEEKW(tree&+ob_sizeof*0+ob_y)
w_in=PEEKW(tree&+ob_sizeof*0+ob_width)
h_in=PEEKW(tree&+ob_sizeof*0+ob_height)


form_center tree&,x_in,y_in,w_in,h_in
x_in=(x_in+4) AND &hFFF8 : REM align form window
POKEW tree&+ob_sizeof*0+ob_x,x_in : REM set form to new value
j=wind_calc(0,myco,x_in,y_in,w_in,h_in,xab,yab,wab,hab) : REM what is the size of my form window?

handle=wind_create(myco,MX,MY,MW,MH) : REM create window
IF handle<0 THEN form_window=handle : EXIT FUNCTION

form_dial 0,xsm,ysm,wsm,hsm,x_in,y_in,w_in,h_in
form_dial 1,xsm,ysm,wsm,hsm,x_in,y_in,w_in,h_in

REM give my form window a title
IF title>-1 THEN
	j=rsrc_gaddr(5,title,attl&) : REM GET title string
	j=wind_set(handle,wf_name,PEEKW(VARPTR(attl&)),PEEKW(VARPTR(attl&)+2),0,0)
	REM give it to my form_window
END IF

j=wind_open(handle,xab,yab,wab,hab)
'j=objc_draw(tree&,0,10,x_in,y_in,w_in,h_in)


REM if the formwindow contains an edit field!

edit=-1
n=0
agai_n:
flags=PEEKW(tree&+ob_sizeof*n+ob_flags)
IF flags AND mask_editable THEN edit=n : GOTO ed_it:
IF flags AND mask_lastob THEN GOTO end_it:
INCR n : GOTO agai_n:
ed_it:

REM create space for the extra values
IF UBOUND(w_ob)<handle THEN REDIM PRESERVE w_ob(handle)
IF UBOUND(wedit)<handle THEN REDIM PRESERVE wedit(handle)

w_ob(handle)=edit
wedit(handle)=0
index=wedit(handle)
j=objc_edit(tree&,edit,k,index,0)
wedit(handle)=index

end_it:
form_window=handle
END FUNCTION


FUNCTION newform_alert(BYVAL button,BYVAL addr&)
LOCAL j
POKEW PEEKL(GB+8),button	'int_in
POKEL PEEKL(GB+16),addr&	'addr_in
GEMSYS(52)					
newform_alert=PEEKW(PEEKL(GB+20))
END FUNCTION



