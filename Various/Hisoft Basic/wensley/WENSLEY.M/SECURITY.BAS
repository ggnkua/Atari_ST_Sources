WINDOW OFF
REM $option !yq30
LIBRARY "gemaes","xbios","mint","gemdos","gemvdi"
DEFINT a-z
REM $include gemaes.bh
REM $include a:\security.bh
DIM mess%(7)
REM $dynamic
DIM wt$(15),wv(15),editf(15),editp(15)

DECLARE FUNCTION openform(BYVAL box,BYVAL title,BYVAL gg)
DECLARE FUNCTION getinfo(BYVAL I,VARPTR d1,VARPTR d2,VARPTR d3,VARPTR d4) 
DECLARE FUNCTION iconify(BYVAL wid)

CALL apterm





REM ##### Register program name #########################################11111222223333344444#
IF PEEKW(PEEKL(GB+4)+2)=-1 THEN fide=menu_register(PEEKW(PEEKL(GB+4)+4),"  Security          ")


REM load .RSC and set menu bar
j=rsrc_load("SECURITY.RSC")
IF j=0 THEN j=form_alert(1,"[3][SECURITY.RSC][OK]") : SYSTEM
j=rsrc_gaddr(0,MENU,menu&)
menu_bar menu&,1 
j=rsrc_gaddr(0,DESKTOP,desk&)


REM place desktop
wt$(0)="FORM" : wv(0)=DESKTOP : editf(0)=0 : REM The desktop is a form?
j=wind_get(0,wf_workxywh,x,y,w,h)
positionform desk&,0,x,y,w,h

REM trick to have AES fetch desktop's colour even in MultiTOS MEMory protected mode. 
j=wind_get(0,wf_newdesk,x2,y2,w2,h2)
true&=1
POKEW VARPTR(true&),x2 : POKEW VARPTR(true&)+2,y2
POKEL desk&+ob_spec,true&+ob_spec
POKEW desk&+ob_flags,PEEKW(desk&+ob_flags)+mask_indirect

j=wind_set(0,wf_newdesk,PEEKW(VARPTR(desk&)),PEEKW(VARPTR(desk&)+2),0,0)
form_dial 3,0,0,0,0,x,y,w,h




REM main loop
DO
e=evnt_multi(mu_mesag+mu_keybd+mu_button+mu_timer,2,1,1,0,0,0,0,0,0,0,0,0,0,VARPTR(mess(0)),1000,xout,yout,bu,ks,k,gc)
IF e AND mu_mesag THEN do_message mess(0)
IF e AND mu_keybd THEN do_keybd k
IF e AND mu_button THEN do_button xout,yout,bu,ks,gc
IF e AND mu_timer THEN
	j=wind_get(0,wf_top,tt,0,0,0)
	IF UBOUND(wt$)>=tt THEN
		IF wt$(tt)="FORM" AND wv(tt)=PANEL AND iconify(tt)=0 THEN
			j=rsrc_gaddr(0,wv(tt),tree&)
			j=wind_get(tt,wf_workxywh,x,y,w,h)
			colchange tree&,ACTIVE,&HFFF0,6
			j=objc_draw(tree&,ACTIVE,&H7FFF,x,y,w,h)
			IF jax=1 THEN 
				colchange tree&,LOCKED,&HFFF0,3
				j=objc_draw(tree&,LOCKED,&H7FFF,x,y,w,h)
				colchange tree&,UNLOCKED,&HFFF0,10
				j=objc_draw(tree&,UNLOCKED,&H7FFF,x,y,w,h)
				jax=2
			END IF
			IF jax=0 THEN 
				colchange tree&,LOCKED,&HFFF0,11
				j=objc_draw(tree&,LOCKED,&H7FFF,x,y,w,h)
				colchange tree&,UNLOCKED,&HFFF0,2
				j=objc_draw(tree&,UNLOCKED,&H7FFF,x,y,w,h)
				jax=1			
			END IF
			IF jax=2 THEN jax=0
			vsync
			colchange tree&,ACTIVE,&HFFF0,14
			j=objc_draw(tree&,ACTIVE,&H7FFF,x,y,w,h)

		END IF
	END IF
END IF
LOOP

REM terminate program
endprog:
REM close all open windows...
FOR I=1 TO UBOUND(wt$)
IF wt$(i)<>"" THEN
	IF wt$(i)="FORM" AND editf(i)>0 THEN
		j=rsrc_gaddr(0,wv(i),form&)
		j=objc_edit(form&,editf(i),0,editp(i),3)
		editf(i)=0
	END IF
	j=wind_close(i) : j=wind_delete(i)
END IF
NEXT I
REM remove desktop, remove menu bar, free resource then end
j=wind_set(0,wf_newdesk,0,0,0,0)
menu_bar menu&,0
j=rsrc_free
SYSTEM



SUB do_message(mes_num)
LOCAL title,item,j,i,d1,d2,d3,d4,form&,aro,which,handle
LOCAL x,y,w,h,x2,y2,w2,h2,x3,y3,w3,h3,a$
SHARED mess(0),wt$(0),wv(0),editf(0),editp(0),menu&
SELECT CASE mes_num
CASE ap_dragdrop
REM time critical items first!?
CASE ap_term
GOTO endprog:
CASE mn_selected

a$=STR$(mess(1))+" "+STR$(mess(2))+" "+STR$(mess(3))+" "+STR$(mess(4))+" "+STR$(mess(5))+" "+STR$(mess(6))+" "+STR$(mess(7))+CHR$(0)
salert VARPTR(a$)


title=mess(3)
item=mess(4)

IF title=file AND item=passwordentry THEN
	aro=0 : REM check if dialog box is already open
	FOR I=1 TO UBOUND(wt$)
	IF wt$(i)="FORM" AND wv(i)=PANEL THEN aro=i
	NEXT I

	REM I can open it
	d3=0 : REM shall I have an iconify?
	IF PEEKW(PEEKL(GB+4))=>&H400 THEN j=getinfo(11,0,0,d3,0)
	IF aro=0 THEN j=openform(PANEL,PANELT,win_name+win_close+win_info+win_move+(d3 AND &b1)*&H4000)

END IF

IF title=3 AND item=8 THEN
	aro=0 : REM check if dialog box is already open
	FOR I=1 TO UBOUND(wt$)
	IF wt$(i)="FORM" AND wv(i)=PAULS THEN aro=i
	NEXT I

	REM I can open it
	d3=0 : REM shall I have an iconify?
	IF PEEKW(PEEKL(GB+4))=>&H400 THEN j=getinfo(11,0,0,d3,0)
	IF aro=0 THEN j=openform(PAULS,PANELT,win_name+win_close+win_info+win_move+(d3 AND &b1)*&H4000)

END IF

IF title=file AND item=VDIwindow THEN
	aro=0 : REM check if dialog box is already open
	FOR I=1 TO UBOUND(wt$)
	IF wt$(i)="REAL" AND wv(i)=0 THEN aro=i
	NEXT I

	REM I can open it
	d3=0 : REM shall I have an iconify?
	IF PEEKW(PEEKL(GB+4))=>&H400 THEN j=getinfo(11,0,0,d3,0)
	IF aro=0 THEN
		IF wind_get(0,wf_workxywh,x,y,w,h)=0 THEN EXIT IF
		handle=wind_create(win_name+win_close+win_info+win_size+win_move+win_full+(d3 AND &b1)*&H4000,x,y,w,h)
		IF handle<0 THEN EXIT IF
		j=wind_open(handle,x,y,w,h)
		IF UBOUND(wt$)<handle THEN REDIM PRESERVE wt$(handle)
		IF UBOUND(wv)<handle THEN REDIM PRESERVE wv(handle)
		wt$(handle)="REAL"
		wv(handle)=0
	END IF
END IF


IF title=file AND item=quit THEN GOTO endprog:

menu_tnormal menu&,title,1
CASE wm_redraw
	a$=wt$(mess(3))

	SELECT CASE a$
	CASE "FORM"
	IF iconify(mess(3))=0 THEN
		j=rsrc_gaddr(0,wv(mess(3)),form&)
		ELSE
		j=rsrc_gaddr(0,ICONIFIED,form&)
	END IF
	REM ensure form size and place matches window before update?
	IF wind_get(mess(3),wf_workxywh,x,y,w,h)=1 THEN positionform form&,0,x,y,w,h
	IF wind_get(mess(3),wf_firstxywh,x,y,w,h)=0 THEN BEEP : EXIT SELECT
	DO 
		intersection mess(4),mess(5),mess(6),mess(7),x,y,w,h,x2,y2,w2,h2
		IF (w2>0) AND (h2>0) THEN j=objc_draw(form&,0,&H7FFF,x2,y2,w2,h2)
		IF wind_get(mess(3),wf_nextxywh,x,y,w,h)=0 THEN EXIT SELECT
	LOOP UNTIL w=0 AND h=0
	IF editf(mess(3))>0 AND iconify(mess(3))=0 THEN j=objc_edit(form&,editf(mess(3)),0,editp(mess(3)),1)

	CASE "REAL"
	IF wind_update(1)=0 THEN BEEP : EXIT SELECT
	IF wind_get(mess(3),wf_firstxywh,x,y,w,h)=0 THEN BEEP : EXIT SELECT
		DO 
		intersection mess(4),mess(5),mess(6),mess(7),x,y,w,h,x2,y2,w2,h2
		IF (w2>0) AND (h2>0) THEN
				vs_clip 1,x2,y2,x2+w2-1,y2+h2-1
				which=wv(mess(3))
				j=wind_get(mess(3),wf_workxywh,x3,y3,w3,h3)
				SELECT CASE which
				CASE 0
				
				vsf_color 1
				vsf_interior 2
				vsf_style 13
				v_bar x3,y3,x3+w3-1,y3+h3-1
				END SELECT
				vs_clip 0,x2,y2,x2+w2-1,y2+h2-1
			END IF
		IF wind_get(mess(3),wf_nextxywh,x,y,w,h)=0 THEN EXIT SELECT
	LOOP UNTIL w=0 AND h=0
	IF wind_update(0)=0 THEN BEEP : EXIT SELECT
	END SELECT

CASE 33
IF PEEKW(PEEKL(GB+4))=>&H400 THEN j=wind_set(mess(3),25,0,0,0,0)
CASE wm_topped
j=wind_set(mess(3),wf_top,mess(3),0,0,0)
CASE wm_closed
IF wt$(mess(3))="FORM" AND editf(mess(3))>0 THEN j=rsrc_gaddr(0,wv(mess(3)),form&) : j=objc_edit(form&,editf(mess(3)),0,editp(mess(3)),3) : editf(mess(3))=0
j=wind_close(mess(3))
j=wind_delete(mess(3))
wt$(mess(3))=""
CASE wm_fulled
j=wind_get(mess(3),wf_fullxywh,x,y,w,h)
j=wind_get(mess(3),wf_currxywh,x2,y2,w2,h2)
IF x2=x AND y2=y AND w2=w AND h2=h THEN j=wind_get(mess(3),wf_prevxywh,x,y,w,h)
j=wind_set(mess(3),wf_currxywh,x,y,w,h)
IF UBOUND(wt$)=>mess(3) THEN
	IF wt$(mess(3))="FORM" AND iconify(mess(3))=0 THEN
		j=rsrc_gaddr(0,wv(mess(3)),form&)
		IF j<>0 THEN
			j=wind_get(mess(3),wf_workxywh,x,y,w,h)
			IF j<>0 THEN
				positionform form&,0,x,y,w,h
			END IF
		END IF
	END IF
END IF
j=wind_get(mess(3),wf_workxywh,x,y,w,h)

CASE wm_sized,wm_moved
IF wt$(mess(3))="FORM" THEN	
	IF iconify(mess(3))=0 THEN
		j=rsrc_gaddr(0,wv(mess(3)),form&)
		ELSE
		j=rsrc_gaddr(0,ICONIFIED,form&)
	END IF
	j=wind_get(mess(3),wf_workxywh,x2,y2,w2,h2)
	j=wind_set(mess(3),wf_currxywh,mess(4),mess(5),mess(6),mess(7))
	j=wind_get(mess(3),wf_workxywh,x,y,w,h)
	graf_movebox w,h,x2,y2,x,y
	positionform form&,0,x,y,w,h
END IF
j=wind_set(mess(3),wf_currxywh,mess(4),mess(5),mess(6),mess(7))
CASE 34,36 REM iconify situations...
j=wind_get(mess(3),wf_currxywh,x,y,w,h)
graf_shrinkbox mess(4),mess(5),mess(6),mess(7),x,y,w,h
j=wind_set(mess(3),26,mess(4),mess(5),mess(6),mess(7))
CASE 35
j=wind_get(mess(3),wf_currxywh,x,y,w,h)
graf_growbox x,y,w,h,mess(4),mess(5),mess(6),mess(7)
j=wind_set(mess(3),27,mess(4),mess(5),mess(6),mess(7))
END SELECT
END SUB


SUB do_keybd(k)
LOCAL k,tt,form&,j,closeme,newobj,kout,x,y,w,h,obedit,editable,nextob,i,d
SHARED editf(0),wt$(0),wv(0),mess(0),editp(0)
j=wind_get(0,wf_top,tt,0,0,0)
IF j<0 OR tt>UBOUND(wt$) THEN EXIT SUB : REM error 
IF (wt$(tt)<>"FORM") OR (iconify(tt)>0) THEN EXIT SUB : REM not a form window
j=rsrc_gaddr(0,wv(tt),form&) : REM get box address
closeme=form_keybd(form&,editf(tt),editf(tt),k,newobj,kout)
IF closeme=0 THEN
	j=wind_get(tt,wf_workxywh,x,y,w,h)
	j=objc_change(form&,newobj,x,y,w,h,(PEEKW(form&+ob_sizeof*newobj+ob_state) AND &HFFFE)+mask_selected,1)
	j=objc_change(form&,newobj,x,y,w,h,(PEEKW(form&+ob_sizeof*newobj+ob_state) AND &HFFFE)+mask_normal,0)
	REM instruct myself to close the window
	IF tt>0 THEN deletewindow tt
	EXIT SUB
END IF
IF kout>0 THEN j=objc_edit(form&,editf(tt),kout,editp(tt),2)
IF newobj<>editf(tt) THEN
	IF (PEEKW(form&+ob_sizeof*newobj+ob_flags) AND mask_editable)=0 THEN
		BEEP : REM stop bad output from form_keybd (unlikely [but a virus may do])
	ELSE
		j=objc_edit(form&,editf(tt),kout,editp(tt),3)
		j=objc_edit(form&,newobj,kout,editp(tt),1)
		editf(tt)=newobj
	END IF
END IF
END SUB


SUB do_button(xout,yout,bu,ks,gc)
SHARED wt$(0),wv(0),mess(0),editf(0),editp(0)
LOCAL j,form&,closeme,newobj,x,y,w,h,kout
IF UBOUND(wt$)<wind_find(xout,yout) THEN EXIT SUB : REM error catch
IF wt$(wind_find(xout,yout))<>"FORM" THEN EXIT SUB : REM this can't process non form
IF iconify(wind_find(xout,yout))=0 THEN
	j=rsrc_gaddr(0,wv(wind_find(xout,yout)),form&)
	ELSE
	j=rsrc_gaddr(0,ICONIFIED,form&)
	IF wind_get(wind_find(xout,yout),wf_workxywh,x,y,w,h)=1 THEN positionform form&,0,x,y,w,h
END IF
closeme=form_button(form&,objc_find(form&,0,&H7FFF,xout,yout),gc,newobj)
IF closeme=0 THEN
	IF newobj AND &H8000 THEN BEEP
	newobj=newobj AND &H7FFF
	j=wind_find(xout,yout)
	IF j>0 THEN deletewindow(j)
	IF wind_get(wind_find(xout,yout),wf_workxywh,x,y,w,h)=0 THEN EXIT SUB
	j=objc_change(form&,newobj,x,y,w,h,(PEEKW(form&+ob_sizeof*newobj+ob_state) AND &HFFFE)+mask_normal,0)
	EXIT SUB
END IF



IF newobj<>editf(wind_find(xout,yout)) AND newobj>0 THEN
	j=objc_edit(form&,editf(wind_find(xout,yout)),0,editp(wind_find(xout,yout)),3)
	j=objc_edit(form&,newobj,0,editp(wind_find(xout,yout)),1)
	editf(wind_find(xout,yout))=newobj
END IF


END SUB


FUNCTION openform(BYVAL box,BYVAL title,BYVAL gg)
LOCAL j,form&,x,y,w,h,x2,y2,w2,h2,handle,st&,obedit,editable
SHARED wt$(0),wv(0),editf(0),editp(0)
REM this opens a formwindow
j=rsrc_gaddr(0,box,form&)
IF j=0 THEN openform=-1 : EXIT SUB
j=wind_get(0,wf_workxywh,x,y,w,h)
handle=wind_create(gg,x,y,w,h)
IF handle<0 THEN openform=handle : EXIT SUB : REM could not create window
IF title<>-1 THEN j=rsrc_gaddr(5,title,st&) : j=wind_set(handle,wf_name,PEEKW(VARPTR(st&)),PEEKW(VARPTR(st&)+2),0,0)
form_center form&,x2,y2,w2,h2
j=wind_calc(0,gg,x2,y2,w2,h2,x,y,w,h)
IF j=0 THEN j=wind_delete(handle) : openform=-1 : EXIT SUB
j=wind_open(handle,x,y,w,h)
IF j=0 THEN j=wind_delete(handle) : openform=-1 : EXIT SUB : REM error with wind_open!
obedit=-1
editable=0
DO
obedit=obedit+1
IF (PEEKW(form&+ob_sizeof*obedit+ob_flags) AND mask_editable)>0 THEN editable=obedit
LOOP UNTIL ((PEEKW(form&+ob_sizeof*obedit+ob_flags) AND mask_lastob)>0) OR editable>0
IF UBOUND(editf)<handle THEN REDIM PRESERVE editf(handle)
IF UBOUND(editp)<handle THEN REDIM PRESERVE editp(handle)
IF UBOUND(wt$)<handle THEN REDIM PRESERVE wt$(handle)
IF UBOUND(wv)<handle THEN REDIM PRESERVE wv(handle)
editf(handle)=editable
IF editf(handle)>0 THEN j=objc_edit(form&,editf(handle),0,editp(handle),1)
wt$(handle)="FORM" : REM register as a formwindow with registry
wv(handle)=box : REM store form id.
openform=handle
END FUNCTION

REM simple, commonly used functions

REM is it iconified?

FUNCTION iconify(BYVAL wid)
LOCAL j,i,d
i=0 : REM is it iconified?
IF PEEKW(PEEKL(GB+4))=>&H400 THEN j=getinfo(11,d,0,0,0)
IF PEEKW(PEEKL(GB+4))=>&H410 AND j=1 AND (d AND &B10000000) THEN j=wind_get(wid,26,i,0,0,0)
iconify=i
END FUNCTION

SUB positionform(tree&,object,x,y,w,h)
POKEW tree&+ob_sizeof*object+ob_x,x
POKEW tree&+ob_sizeof*object+ob_y,y
POKEW tree&+ob_sizeof*object+ob_width,w
POKEW tree&+ob_sizeof*object+ob_height,h
END SUB


REM HiSoft appl_getinfo didn't work? so here may be a working one?

FUNCTION getinfo(BYVAL I,VARPTR d1,VARPTR d2,VARPTR d3,VARPTR d4) 
IF PEEKW(PEEKL(GB+4))<&H400 THEN d1=0 : d2=0 : d3=0 : d4=0 : getinfo=0 : EXIT SUB
POKEW PEEKL(GB+8),I
GEMSYS(130)
getinfo=PEEKW(PEEKL(GB+12))
d1=PEEKW(PEEKL(GB+12)+2)
d2=PEEKW(PEEKL(GB+12)+4)
d3=PEEKW(PEEKL(GB+12)+6)
d4=PEEKW(PEEKL(GB+12)+8)
END FUNCTION

SUB deletewindow(BYVAL windid)
SHARED mess(0)
mess(0)=wm_closed
mess(1)=PEEKW(PEEKL(GB+4)+4)
mess(2)=0
mess(3)=windid
mess(4)=0
mess(5)=0
mess(6)=0
mess(7)=0
appl_write PEEKW(PEEKL(GB+4)+4),16,VARPTR(mess(0))
END SUB

SUB apterm
REM sets apterm functionality
STATIC d,j
IF getinfo(10,d,0,0,0)=0 THEN EXIT SUB
IF (d AND &HFF)<9 THEN EXIT SUB
IF getinfo(12,d,0,0,0)=0 THEN EXIT SUB
IF (d AND &B1000)=0 THEN EXIT SUB
j=shel_write(9,1,0,0,0) : REM supports ap_term
END SUB

SUB colchange(BYVAL tree&,BYVAL object,BYVAL mask,BYVAL new)
STATIC type
type=PEEKW(tree&+ob_sizeof*object+ob_type)
SELECT CASE type
CASE G_BOX,G_IBOX,G_BOXCHAR
POKEL tree&+ob_sizeof*object+ob_spec,(PEEKL(tree&+ob_sizeof*object+ob_spec) AND (&HFFFF0000+mask))+new
CASE G_TEXT,G_BOXTEXT,G_FTEXT,G_FBOXTEXT
POKEW PEEKL(tree&+ob_sizeof*object+ob_spec)+te_color,(PEEKW(PEEKL(tree&+ob_sizeof*object+ob_spec)+te_color) AND mask)+new
CASE G_IMAGE
POKEW PEEKL(tree&+ob_sizeof*object+ob_spec)+bi_color,(PEEKW(PEEKL(tree&+ob_sizeof*object+ob_spec)+bi_color) AND mask)+new
CASE G_ICON,33
POKEW PEEKL(tree&+ob_sizeof*object+ob_spec)+ib_char,(PEEKW(PEEKL(tree&+ob_sizeof*object+ob_spec)+ib_char) AND mask)+new
END SELECT
END SUB



REM Register program name in multitasker
REM at start of program use:?
REM multitaskname "Programname"
REM 


FUNCTION multitaskname(BYVAL name$)
STATIC done,fide,entry$
entry$="  "+name$
IF LEN(entry$)<20 THEN entry$=entry$+SPACE$(20-LEN(entry$))
IF LEN(entry$)>20 THEN entry$=LEFT$(entry$,20)
IF PEEKW(PEEKL(GB+4)+2)=-1 THEN multitaskname=menu_register(PEEKW(PEEKL(GB+4)+4),entry$)
END FUNCTION

SUB getobjectposition(BYVAL tree&,BYVAL obj,VARPTR x,VARPTR y,VARPTR w,VARPTR h)
x=PEEKW(tree&+ob_sizeof*obj+ob_x)
y=PEEKW(tree&+ob_sizeof*obj+ob_y)
w=PEEKW(tree&+ob_sizeof*obj+ob_width)
h=PEEKW(tree&+ob_sizeof*obj+ob_height)
END SUB
