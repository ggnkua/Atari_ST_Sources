
REM PDO - Print Documents Out, the example project for the HBASIC
REM       tutorial for Atari Computing by Paul Jones

LIBRARY "gemaes","gemvdi"

REM $option k10
REM $option g,y+,v+,u+,#,[,]

DEFINT a-z

DIM SHARED junk
REM DECLARE FUNCTION Dialog

REM $include pdo.bh
REM $include gemaes.bh

DIM SHARED tree&

DEF FNObjectAddr&(object)=tree&+object*ob_sizeof
DEF FNGetob_spec&(object)=PEEKL(FNObjectAddr&(object)+ob_spec)

SUB Exclob_state(object,flag_mask)
STATIC t&
t&=FNObjectAddr&(object)+ob_state
POKEW	t&,PEEKW(t&) AND (NOT flag_mask)
END SUB

SUB Sette_ptext(object,newted$)
STATIC t&,chars,i,dum1,dum2
t&=FNGetob_spec&(object)

dum1=peekw (t&+te_txtlen)-1
dum2=len(newted$)

if dum1<dum2 then chars=dum1
if dum2<dum1 then chars=dum2

t&=PEEKL(t&+te_ptext)
FOR i=1 TO chars
	POKEB t&,ASC(MID$(newted$,i,1))
	INCR t&
NEXT i
POKEB t&,0
END SUB

SUB SelectTreeAddr(BYVAL t&)
tree&=t&
END SUB

SUB SelectTree(BYVAL treeno)
STATIC formaddr&
	junk=FNrsrc_gaddr(type_tree,treeno,formaddr&)
	SelectTreeAddr formaddr&
END SUB

DEF FNGette_ptext$(BYVAL object)
STATIC t&,a$
a$=""
t&=FNGetob_spec&(object)
t&=PEEKL(t&+te_ptext)
WHILE PEEKB(t&)
	a$=a$+CHR$(PEEKB(t&))
	INCR t&
WEND
FNGette_ptext$=a$
END DEF

DEF FNDialog (dial,edit)
STATIC junk,tree&,x,y,w,h,but,type_tree,treeno,tree&

junk=FNrsrc_gaddr(0,dial,tree&)
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=FNobjc_draw(tree&,0,10,x,y,w,h)
but=FNform_do(tree&,edit) AND &h7fff
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
Exclob_state but,mask_selected


FNDialog=but

END DEF


SUB ProcessUserMenus (title,item)
STATIC dummy,finished,butn,a$,code$,name$,pass$
SHARED finished

SELECT CASE item
	CASE about:
		dummy=FNdialog (info,0)
	CASE view:
		dummy=FNform_alert (1,"[1][ You clicked on 'View'! ][ OK ]")
	CASE prin:
		OPEN "MYTEXT.TXT" FOR INPUT AS #1
		DO
			LINE INPUT #1,a$
			LPRINT a$
		LOOP UNTIL EOF (1)
		CLOSE #1
	CASE opts:
		dummy=FNform_alert (1,"[1][ You clicked on 'Printer | options'! ][ OK ]")
	CASE reg:
		butn=FNdialog (regist, regcode)
		IF butn=regbut THEN
			SelectTree regist
			code$=FNgette_ptext$ (regcode)
			name$=FNgette_ptext$ (regname)

			pass$=LEFT$(name$,2)+RIGHT$(name$,3)+MID$(name$,3,3)
			IF code$=pass$ THEN
				dummy=FNform_alert (1,"[1][ Correct key ][ OK ]")
			ELSE
				dummy=FNform_alert (1,"[1][ Incorrect key ][ OK ]")
			END IF
		END IF
	CASE loads:
		dummy=FNform_alert (1,"[1][ You clicked on 'Load | settings'! ][ OK ]")
	CASE saves:
		dummy=FNform_alert (1,"[1][ You clicked on 'Save | settings'! ][ OK ]")
	CASE quit:
		finished=-1
END SELECT
END SUB

SUB InitResourceFile(name$)
STATIC junk
SHARED resource_loaded
IF FNrsrc_load(name$)=0 THEN
	junk=FNform_alert(1,"[3][ Couldn't find PDO.RSC! ][ Quit ]")
	SYSTEM
END IF
resource_loaded=-1
END SUB

SUB StartProgram(resourcefile$,treenumber)
SHARED WindX,WindY,WindW,WindH
WINDOW ON
InitResourceFile resourcefile$
junk=FNwind_get(0,WF_WORKXYWH,WindX,WindY,WindW,WindH)
InitMenuSystem treenumber
END SUB

SUB StopProgram
SHARED menu_pointer&
STATIC junk
IF menu_pointer& THEN menu_bar menu_pointer&,0
junk=FNwind_set(0,WF_NEWDESK,0,0,0,0)
junk=FNwind_update(END_UPDATE)
junk=FNrsrc_free

STOP -1
END SUB

SUB InitMenuSystem( treenumber)
SHARED menu_pointer&,exit_item,menus_enabled
junk=FNrsrc_gaddr(0,treenumber,menu_pointer&)
menu_bar menu_pointer&,1
menus_enabled=-1
END SUB

SUB do_message(VAL mes_type)
SHARED mess(1),menu_pointer&
SHARED title,item
STATIC title,item,junk
 SELECT CASE mes_type
 CASE MN_SELECTED:
	title=mess(3)
	item=mess(4)
		CALL ProcessUserMenus (title,item)
	menu_tnormal menu_pointer&,title,1
 END SELECT
END SUB

SUB do_keybd (VAL k)
STATIC item,id

id=0

IF k=6144 THEN item=opts  : id=1 : REM Options
IF k=9728 THEN item=loads : id=1 : REM Load options
IF k=7936 THEN item=saves : id=1 : REM Save options
IF k=12032 THEN item=view : id=1 : REM View file
IF k=6400 THEN item=prin  : id=1 : REM print
IF k=4096 THEN item=quit  : id=1 : REM quit!
IF k=7680 THEN item=about : id=1 : REM about item

if id=1 then CALL ProcessUserMenus (0,item)

END SUB



DIM mess(16)
StartProgram "PDO.RSC",menu

DO
	e=FNevnt_multi(MU_MESAG+MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,_
					varptr(mess(0)),0,0,0,0,0,k,0)

	
	IF e AND MU_MESAG THEN do_message mess(0)
	IF e AND MU_KEYBD THEN do_keybd (k)

IF finished=-1 THEN CALL StopProgram

LOOP
