rem $option y+,q30
LIBRARY "GEMAES","GEMVDI","BIOS","XBIOS"
defint a-z
rem $include gemaes.bh
rem $include sprite.bh
DECLARE FUNCTION newform_alert(BYVAL button,BYVAL addr&)


j=rsrc_load("SPRITE.RSC")
IF j=0 THEN j2=form_alert(1,"[3][SPRITE.RSC][OK]") : SYSTEM
j=wind_get(0,wf_workxywh,x,y,w,h)
myco=win_name+win_close+win_move+win_full+win_size
m_handle=wind_create(myco,x,y,w,h)
j=rsrc_gaddr(5,window4,alert&) : j=newform_alert(1,alert&)




j=rsrc_gaddr(5,title3,title&)
j=wind_set(m_handle,wf_name,PEEKW(VARPTR(title&)),PEEKW(VARPTR(title&)+2),0,0)
GOSUB initutil:
j2=rsrc_gaddr(0,1,tree&)


j=rsrc_gaddr(0,0,menu&)
menu_bar menu&,1

j=wind_open(m_handle,x+(w/4),y+(h/4),w/2,h/2)

time&=100

main:
e=evnt_multi(mu_mesag+mu_timer,c,m,s,1,x,y,w,h,2,x,y,w,h,VARPTR(mess(0)),time&,xout,yout,button,kstate,k,gt)
if e and mu_mesag then do_message mess(0)
IF e AND mu_timer THEN GOTO spriteutil:
GOTO main:

endprog:
j=rsrc_free
menu_bar menu&,0
SYSTEM


SUB do_message(BYVAL mes_type)
LOCAL title,item,j,j2,tt,x,y,w,h,x2,y2,w2,h2
LOCAL xre,yre,wre,hre
SHARED menu&,mess(0),m_handle,tree&,ob
SELECT CASE mes_type
CASE mn_selected 
title=mess(3)
item=mess(4)
menu_tnormal menu&,title,1
IF title=file AND item=quit THEN GOTO endprog:

CASE wm_closed
j=wind_close(mess(3))
j=wind_delete(mess(3))
 
IF mess(3)=m_handle THEN m_handle=0
CASE wm_topped
j=wind_set(mess(3),wf_top,tt,0,0,0)
CASE wm_sized,wm_moved

'j=wind_calc(1,myco,mess(4),mess(5),mess(6),mess(7),x_in,y_in,w_in,h_in)
'POKEW tree&+ob_sizeof*0+ob_x,x_in : REM set form to new value
'POKEW tree&+ob_sizeof*0+ob_y,y_in : REM set form to new value
'POKEW tree&+ob_sizeof*0+ob_width,w_in
'POKEW tree&+ob_sizeof*0+ob_height,h_in
'onlyreal:

j=wind_set(mess(3),wf_currxywh,mess(4),mess(5),mess(6),mess(7))

CASE wm_fulled
j=wind_get(mess(3),wf_currxywh,x,y,w,h)
j=wind_get(mess(3),wf_fullxywh,x2,y2,w2,h2)
IF x=x2 AND y=y2 AND w=w2 AND h=h2 THEN
	j=wind_get(mess(3),wf_prevxywh,x2,y2,w2,h2)
END IF
j=wind_set(mess(3),wf_currxywh,x2,y2,w2,h2)



CASE wm_redraw
graf_mouse 256,0


'vs_clip 1,mess(4),mess(5),mess(6),mess(7)
j=wind_get(mess(3),wf_firstxywh,xre,yre,wre,hre)
DO
IF wre=0 AND hre=0 THEN EXIT LOOP

j=wind_update(1)
vsf_color 3
vsf_interior 2
vsf_style 4
vr_recfl xre,yre,(xre+wre)-1,(yre+hre)-1

j=objc_draw(tree&,ob,0,xre,yre,wre,hre)


j=wind_update(0)



j=wind_get(mess(3),wf_nextxywh,xre,yre,wre,hre)
LOOP
vs_clip 0,0,0,0,0
graf_mouse 257,0



END SELECT
END SUB



initutil:
ix=10
iy=10
ob=1
RETURN



spriteutil:
IF m_handle<1 THEN GOTO main:


j2=rsrc_gaddr(0,1,tree&)








INCR ob : IF ob=4 THEN ob=1



graf_mkstate x,y,s,ks


j=wind_get(m_handle,wf_workxywh,x2,y2,w2,h2)


POKEW tree&+ob_sizeof*0+ob_x,x2
POKEW tree&+ob_sizeof*0+ob_y,y2

REM x and y are offsets from the top left of the window


POKEW tree&+ob_sizeof*ob+ob_x,ix
POKEW tree&+ob_sizeof*ob+ob_y,iy

j=objc_offset(tree&,ob,x3,y3)

IF x3<x THEN dx=(x-x3)/16
IF x3>x THEN dx=0-((x3-x)/16)
IF y3<y THEN dy=(y-y3)/16
IF y3>y THEN dy=0-((y3-y)/16)



IF (ix>w2) THEN ix=ix-4
IF (ix<1)  THEN ix=ix+4
IF (iy>h2) THEN iy=iy-4
IF (iy<1)  THEN iy=iy+4


IF (ix<w2) AND (ix>0) THEN ix=ix+dx
IF (iy<h2) AND (iy>0) THEN iy=iy+dy



'form_dial 3,0,0,0,0,oldsx,oldsy,32,32


j=wind_get(m_handle,wf_workxywh,x,y,w,h)
j=objc_draw(tree&,ob,0,x,y,w,h)

j=objc_offset(tree&,ob,sx,sy)


GOTO main:

FUNCTION newform_alert(BYVAL button,BYVAL addr&)
POKEW PEEKL(GB+8),button	'int_in
POKEL PEEKL(GB+16),addr&	'addr_in
GEMSYS(52)					
newform_alert%=PEEKW(PEEKL(GB+20))
END FUNCTION



