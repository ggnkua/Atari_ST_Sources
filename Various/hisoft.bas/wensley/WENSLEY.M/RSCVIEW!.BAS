REM $option yg
LIBRARY "gemaes","xbios"
DEFINT a-z
REM $include f:\hbasic\michael\rs_const.bh
REM $include f:\enchant\toolkit\gemaes.bh
DIM SHARED mess%(7)
REM $dynamic
DIM SHARED objseen(30)


DECLARE FUNCTION validtree(BYVAL tree&)
cl$=COMMAND$
IF cl$<>"" THEN rscview cl$ : SYSTEM

fspath$=CURDIR$+"\*.RSC"
fsname$=""

DO
IF PEEKW(PEEKL(GB+4))<&H130 THEN
	fsel_input fspath$,fsname$,ok
ELSE
	fsel_exinput fspath$,fsname$,ok,"Choose a resource file..."
END IF
IF ok THEN
	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP
	rscview LEFT$(fspath$,i)+fsname$
END IF
LOOP UNTIL ok=0
SYSTEM

SUB rscview(BYVAL file$)
STATIC e,j,tree&,index&,x,y,w,h,lrt&,i,st&,editable,tid,found,progdef,content&,skip,jex
IF rsrc_load(file$)=0 THEN j=form_error(2) : EXIT SUB


REM misdocumented GB alert!!!
REM misdocumented GB alert!!!
REM misdocumented GB alert!!!
REM misdocumented GB alert!!!

REM truth -> peekl(peekl(gb+4)+14) address of start of .rsc?
REM truth -> peekl(peekl(gb+4)+10) address of tree pointer table?

IF PEEKW(PEEKL(PEEKL(GB+4)+14)+22)=0 THEN j=form_alert(1,"[1][RSCVIEW!:|No trees in this resource file!][ok]") : j=rsrc_free : EXIT SUB

FOR index&=0 TO (PEEKW(PEEKL(PEEKL(GB+4)+14)+22)-1)
e=rsrc_gaddr(0,index&,tree&)
IF e<>0 THEN
	st&=tree& : found=0 : progdef=0
	DO
		IF PEEKW(st&+ob_type)=G_PROGDEF THEN found=1 : progdef=1 : content&=PEEKW(st&+ob_spec)
		IF PEEKW(st&+ob_flags) AND mask_lastob THEN found=1 : progdef=0
		st&=st&+ob_sizeof
	LOOP UNTIL found=1
	skip=0
	IF progdef=1 THEN
		j=form_alert(1,"[1][RSCVIEW!:Caution!|This tree contains a G_progdef!|Displaying it may cause a crash!|or it may even hide a **virus!!!**|Please verify "+STR$(content&)+"][Skip]") 
		skip=1
	'ELSE	
	'	IF validtree(tree&)=0 THEN
	'		j=form_alert(1,"[1][RSCVIEW!:Caution!|This tree may contain a|corrupt structure!|Displaying may|result in a crash][Skip]")
	'		skip=1
	'	END IF
	END IF
	
	
	IF skip=0 THEN
		form_center tree&,x,y,w,h
		form_dial 0,0,0,0,0,x,y,w,h
		form_dial 1,0,0,0,0,x,y,w,h
		j=objc_draw(tree&,0,&H7FFF,x,y,w,h)
	
		st&=tree& : tid=0 : found=0 : editable=0
		DO
			IF PEEKW(st&+ob_flags) AND mask_lastob THEN found=1 : editable=0
			IF PEEKW(st&+ob_flags) AND mask_editable THEN found=1 : editable=tid
			INCR tid : st&=st&+ob_sizeof
		LOOP UNTIL found=1
		jex=form_alert(1,"[2][RSCVIEW!:|Test this tree?][No|Yes|Windowed]")
		IF jex=2 THEN
			j=form_do(tree&,editable)
			j=objc_change(tree&,j,x,y,w,h,PEEKW(tree&+j*ob_sizeof+ob_state) AND &HFFFE,0)
		END IF
		form_dial 2,0,0,0,0,x,y,w,h
		form_dial 3,0,0,0,0,x,y,w,h
	END IF
	if jex=3 then wintest tree&,editable
END IF
NEXT index&
j=rsrc_free
END SUB


FUNCTION validtree(BYVAL tree&)
STATIC nobject,object,outfamily,j,otrace

REDIM objseen(0)


nobject=PEEKW(tree&+ob_head)
IF nobject=&HFFFF THEN validtree=1 : EXIT FUNCTION

DO
object=nobject


nobject=PEEKW(tree&+object*ob_sizeof+ob_head)
IF outfamily=1 THEN outfamily=0 : nobject=&HFFFF
IF nobject=&HFFFF THEN
	nobject=PEEKW(tree&+object*ob_sizeof+ob_next)
	IF PEEKW(tree&+nobject*ob_sizeof+ob_tail)=object THEN outfamily=1 : EXIT IF
	IF nobject=&HFFFF THEN
		IF object<>0 THEN validtree=0 : EXIT FUNCTION
	END IF
END IF

IF nobject>UBOUND(objseen) THEN REDIM PRESERVE objseen(nobject)

j=form_alert(1,"[4][Object trace:|Current object:"+STR$(object)+"|Next object:"+STR$(nobject)+"][ok]")

IF nobject>-1 THEN
	objseen(nobject)=objseen(nobject)+1
	IF objseen(nobject)>5 THEN validtree=0 : EXIT FUNCTION
END IF

LOOP UNTIL (nobject=&HFFFF) AND (object=0)

validtree=1
END FUNCTION

SUB wintest(BYVAL tree&,BYVAL editable)
LOCAL x,y,w,h,j,x2,y2,w2,h2,handle,e,xout,yout,button,ks,kp,gc,quitwindow

form_center tree&,x,y,w,h

j=wind_get(0,wf_workxywh,x2,y2,w2,h2)

handle=wind_create(win_close+win_move+win_full+win_size,x2,y2,w2,h2)
IF handle<0 THEN j=form_alert(1,"[3][RSCVIEW:|No more windows!][Cancel]") : EXIT SUB

x=PEEKW(tree&+ob_x)
y=PEEKW(tree&+ob_y)
w=PEEKW(tree&+ob_width)
h=PEEKW(tree&+ob_height)

j=wind_open(handle,x,y,w,h)
j=objc_draw(tree&,0,&H7FFF,x,y,w,h)
	
DO
e=evnt_multi(mu_keybd+mu_button+mu_mesag,258,3,0,0,0,0,0,0,0,0,0,0,0,VARPTR(mess(0)),0,xout,yout,button,ks,kp,gc)
IF e AND mu_mesag THEN do_message mess(0)
IF e AND mu_keybd THEN do_keyboard kp
IF e AND mu_button THEN do_button xout,yout,button,ks,gc
LOOP UNTIL quitwindow=1

END SUB

SUB do_keyboard(VARPTR kp)

END SUB

SUB do_message(BYVAL message)

END SUB

SUB do_button (xout,yout,button,ks,gc)

END SUB
