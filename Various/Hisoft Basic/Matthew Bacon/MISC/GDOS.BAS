DEFINT a-z
LIBRARY "gemaes","gemvdi","gemdos","bios","xbios"
'$option q100
'$include f:\enchant\system.bas

junk=graf_handle(sysfont_w,sysfont_h,0,0)

' /* MFDB& structure */
CONST fd_addr=0,fd_w=2,fd_h=3,fd_wdwidth=4,fd_stand=5,fd_nplanes=6
CONST fd_r1=7,fd_r2=8,fd_r3=9,fd_size=9
CONST wa_uppage=0,wa_dnpage=1,wa_upline=2,wa_dnline=3
CONST wa_lfpage=4,wa_rtpage=5,wa_lfline=6,wa_rtline=7
DIM SHARED s_MFDB&(fd_size),d_MFDB&(fd_size),xy(8),info(200)

CALL welldone

SUB welldone
SHARED sysfont_w,sysfont_h
STATIC a&,rast&,w,h,rastlen&,handle,newhandle,i,a!

v_gtext 1,4*sysfont_h,"Your old handle was"+STR$(cvhandle)
v_gtext 1,5*sysfont_h,"Your old pointer to bitmap is "+STR$(d_MFDB&(fd_addr))
w=scr_w : h=scr_h
d_MFDB&(fd_addr)=0
d_MFDB&(fd_w)=w
d_MFDB&(fd_h)=h
d_MFDB&(fd_wdwidth)=(d_MFDB&(fd_w)+15)>>4
d_MFDB&(fd_stand)=0
vq_extnd 1,info()
d_MFDB&(fd_nplanes)=info(4)

s_MFDB&(fd_addr)=0
s_MFDB&(fd_w)=w
s_MFDB&(fd_h)=h
s_MFDB&(fd_wdwidth)=(s_MFDB&(fd_w)+15)>>4
s_MFDB&(fd_stand)=0
s_MFDB&(fd_nplanes)=info(4)

FOR i=0 TO 9
	v_gtext 20*sysfont_w,(i*sysfont_h)+(10*sysfont_h),"dest "+STR$(i)+" "+STR$(d_MFDB&(i))
NEXT

POKEW CONTRL,100
POKEW CONTRL+2,0
POKEW CONTRL+6,20
POKEW CONTRL+10,1
handle=cvhandle
POKEW CONTRL+12,handle
POKEL CONTRL+14,VARPTR(d_MFDB&(fd_addr))

POKEW INTIN,1
POKEW INTIN+2,1
POKEW INTIN+4,1
POKEW INTIN+6,1
POKEW INTIN+8,1
POKEW INTIN+10,1
POKEW INTIN+12,1
POKEW INTIN+14,1
POKEW INTIN+16,1
POKEW INTIN+18,1
POKEW INTIN+20,2

POKEW INTIN+22,w-1
POKEW INTIN+24,h-1
POKEW INTIN+26,1
POKEW INTIN+28,1
POKEW INTIN+30,0
POKEW INTIN+32,0
POKEW INTIN+34,0
POKEW INTIN+36,0
POKEW INTIN+38,0
VDISYS(0)

newhandle=PEEKW(CONTRL+12)
change_handle newhandle
v_gtext 1,6*sysfont_h,"Hello"

v_gtext 1,7*sysfont_h,"Your new handle is "+STR$(newhandle)
v_gtext 1,8*sysfont_h,"Your pointer to bitmap is "+STR$(d_MFDB&(fd_addr))

FOR i=0 TO 9
	v_gtext 1*sysfont_w,(i*sysfont_h)+(10*sysfont_h),"dest "+STR$(i)+" "+STR$(d_MFDB&(i))
NEXT
a&=(4096*info(4))
a&=a&*16
a&=a&+h
v_gtext 1*sysfont_w,(21*sysfont_h),"The height is..."+STR$(a&)
a!=(4096!*w)
v_gtext 1*sysfont_w,(20*sysfont_h),"The width is..."+STR$(a!)
DO

LOOP UNTIL INKEY$<>""
change_handle handle

xy(0)=0
xy(1)=0
xy(2)=w-1
xy(3)=h-1
xy(4)=0
xy(5)=0
xy(6)=w-1
xy(7)=h-1
vro_cpyfm 6,xy(),VARPTR(d_MFDB&(0)),VARPTR(s_MFDB&(0))
vro_cpyfm 3,xy(),VARPTR(s_MFDB&(0)),VARPTR(d_MFDB&(0))
DO

LOOP UNTIL INKEY$<>""
xy(0)=0
xy(1)=0
xy(2)=w-1
xy(3)=h-1
xy(4)=10
xy(5)=10
xy(6)=w-1
xy(7)=h-1
vro_cpyfm 3,xy(),VARPTR(d_MFDB&(0)),VARPTR(s_MFDB&(0))
END SUB