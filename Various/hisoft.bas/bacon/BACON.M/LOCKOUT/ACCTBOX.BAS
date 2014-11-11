' HiSoft BASIC GEM Toolkit Desk accessory version
DEFINT a-z
REM $option y+,v+,u+,#,[,]
LIBRARY "gemaes","gemvdi","xbios","gemdos"
DIM SHARED junk,tree&		' the current Toolbox tree
'Gives the address of the given object in the current tree
DEF ObjectAddr&(object)=tree&+object*ob_sizeof

'Selects a new tree given the address of the root
SUB SelectTreeAddr(BYVAL t&)
tree&=t&
END SUB

' Selects a given tree in the resource file
SUB SelectTree(BYVAL treeno)
STATIC formaddr&
	junk=rsrc_gaddr(type_tree,treeno,formaddr&)
	SelectTreeAddr formaddr&
END SUB

'Returns the value of the ob_spec field in the given object of the current tree
FUNCTION Getob_spec&(BYVAL object)
Getob_spec&=PEEKL(ObjectAddr&(object)+ob_spec)
END FUNCTION

'Returns the value of the ob_type field in the given object of the current tree
FUNCTION Getob_type(BYVAL object)
Getob_type=PEEKW(ObjectAddr&(object)+ob_type)
END FUNCTION

'Sets the value of the ob_width field in the given object of the current tree
SUB Setob_width(BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_width,value
END SUB

'Sets the value of the ob_height field in the given object of the current tree
SUB Setob_height(BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_height,value
END SUB

'Removes a given mask (e.g. mask_selected,mask_disable) from the ob_state
'field in the given object of the current tree
SUB Exclob_state(BYVAL object,BYVAL flag_mask)
STATIC t&
t&=ObjectAddr&(object)+ob_state
POKEW	t&,PEEKW(t&) AND (NOT flag_mask)
END SUB

' set a tedinfo record
SUB Sette_ptext(BYVAL object,BYVAL newted$)
STATIC t&,chars,i
t&=Getob_spec&(object)
chars=MIN(PEEKW(t&+te_txtlen)-1,LEN(newted$))		'-1 for the null
t&=PEEKL(t&+te_ptext)
FOR i=1 TO chars
	POKEB t&,ASC(MID$(newted$,i,1))
	INCR t&
NEXT i
POKEB t&,0									'must end in null
END SUB

' extract a tedinfo record
FUNCTION Gette_ptext$(BYVAL object)
STATIC t&,a$
a$=""
t&=Getob_spec&(object)
t&=PEEKL(t&+te_ptext)
WHILE PEEKB(t&)
	a$=a$+CHR$(PEEKB(t&))
	INCR t&
WEND
Gette_ptext$=a$
END FUNCTION

SUB do_message
SHARED exit_item,Finished_Flag,Mess(1),AlreadyOpen
STATIC cur_front,MessageType,title,item

	MessageType=Mess(0)
	junk=wind_get(Mess(3),WF_TOP,cur_front,junk,junk,junk)
 	SELECT CASE MessageType
	CASE AC_OPEN:
		WINDOW SYSTEM
 		AccOpened
 		AlreadyOpen=-1
 	CASE WM_CLOSED: 
		AlreadyOpen=0
		WINDOW STOP
	END SELECT
END SUB

' a general routine to produce a dialog box and handle interaction
' the return result is the exit object number
FUNCTION HandleDialog(BYVAL editnum)
STATIC x,y,w,h,but
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
but=form_do(tree&,editnum) AND &h7fff
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
IF Getob_type(but)=G_BUTTON THEN
	Exclob_state but,mask_selected
END IF
HandleDialog=but
END FUNCTION
