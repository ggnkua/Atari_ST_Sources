
LIBRARY "gemaes","gemvdi"

REM $option k20
REM $option g,y+,v+,u+,#,[,]

DEFINT a-z

DIM SHARED junk
REM DECLARE FUNCTION Dialog

REM $include sharewar.bh
REM $include gemaes.bh

DIM SHARED tree&

DEF FNObjectAddr&(object)=tree&+object*ob_sizeof
DEF FNGetob_spec&(object)=PEEKL(FNObjectAddr&(object)+ob_spec)

SUB Exclob_state(object,flag_mask)
STATIC t&
t&=FNObjectAddr&(object)+ob_state
POKEW	t&,PEEKW(t&) AND (NOT flag_mask)
END SUB

SUB SelectTreeAddr(t&)
tree&=t&
END SUB

SUB SelectTree(treeno)
STATIC formaddr&
	junk=FNrsrc_gaddr(type_tree,treeno,formaddr&)
	SelectTreeAddr formaddr&
END SUB

SUB form_show (dial)
STATIC junk,tree&,x,y,w,h,but,type_tree,treeno,tree&

junk=FNrsrc_gaddr(0,dial,tree&)
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
junk=FNobjc_draw(tree&,0,10,x,y,w,h)
END SUB

SUB form_show_part (dial, object)
STATIC junk,tree&,x,y,w,h,but,type_tree,treeno,tree&
STATIC x2,y2,w2,h2

junk=FNrsrc_gaddr(0,dial,tree&)
form_center tree&,x,y,w,h
SelectTree dial

form_dial FMD_START,0,0,0,0,x,y,w,h

junk=FNobjc_draw(tree&,object,0,x,y,w,h)

END SUB

'Returns the value of the ob_x field in the given object of the current tree
DEF FNGetob_x (object)
FNGetob_x=PEEKW(FNObjectAddr&(object)+ob_x)
END DEF

'Returns the value of the ob_y field in the given object of the current tree
DEF FNGetob_y (object)
FNGetob_y=PEEKW(FNObjectAddr&(object)+ob_y)
END DEF

'Returns the value of the ob_width field in the given object of the current tree
DEF FNGetob_width (object)
FNGetob_width=PEEKW(FNObjectAddr&(object)+ob_width)
END DEF

'Returns the value of the ob_height field in the given object of the current tree
DEF FNGetob_height (object)
FNGetob_height=PEEKW(FNObjectAddr&(object)+ob_height)
END DEF

'Sets the value of the ob_width field in the given object of the current tree
SUB Setob_width (object, value)
POKEW FNObjectAddr&(object)+ob_width,value
END SUB

SUB InitResourceFile(name$)
STATIC junk
SHARED resource_loaded
IF FNrsrc_load(name$)=0 THEN
	junk=FNform_alert(1,"[3][ Couldn't find SHAREWAR.RSC! ][ Quit ]")
	SYSTEM
END IF
resource_loaded=-1
END SUB

SUB StartProgram (resourcefile$)
WINDOW ON
InitResourceFile resourcefile$
END SUB

SUB StopProgram
STATIC junk
junk=FNrsrc_free
STOP -1
END SUB


SUB GetSetObjects
SHARED wwidth,swidth,spart

SelectTree sharedial
wwidth=FNgetob_width (whiteback)

setob_width slidebar, 0
swidth=0

spart=wwidth/100

END SUB

SUB do_timer
SHARED swidth,wwidth,spart
SHARED finished

swidth=swidth+spart
IF swidth>wwidth THEN
	finished=-1
ELSE
	setob_width slidebar,swidth
'	form_show_part sharedial, whiteback
	form_show_part sharedial, slidebar
END IF

END SUB

DIM mess(16)
StartProgram "SHAREWAR.RSC"
GetSetObjects

	form_show (sharedial)

DO
	e=FNevnt_multi(MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,_
					VARPTR(mess(0)),100,0,0,0,0,k,0)

	IF e AND MU_TIMER THEN CALL do_timer

IF finished=-1 THEN CALL StopProgram

LOOP