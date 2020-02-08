
' [TOOLBX_B.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' Object Tree routines

DEF ObjectAddr&(object)=tree&+object*ob_sizeof

SUB SelectTreeAddr (BYVAL addr&)
tree&=addr&
END SUB

SUB SelectTree (BYVAL treeno)
STATIC formaddr&
junk=rsrc_gaddr(type_tree,treeno,formaddr&)
SelectTreeAddr formaddr&
END SUB


' Get object values

FUNCTION getobj_head (BYVAL object)
getobj_head=PEEKW(ObjectAddr&(object)+ob_head)
END FUNCTION

FUNCTION getobj_tail (BYVAL object)
getobj_tail=PEEKW(ObjectAddr&(object)+ob_tail)
END FUNCTION

FUNCTION getobj_spec& (BYVAL object)
getobj_spec&=PEEKL(ObjectAddr&(object)+ob_spec)
END FUNCTION

FUNCTION getobj_state (BYVAL object)
getobj_state=PEEKW(ObjectAddr&(object)+ob_state)
END FUNCTION

FUNCTION getobj_flags (BYVAL object)
getobj_flags=PEEKW(ObjectAddr&(object)+ob_flags)
END FUNCTION

FUNCTION getobj_type (BYVAL object)
getobj_type=PEEKW(ObjectAddr&(object)+ob_type)
END FUNCTION

FUNCTION getobj_next (BYVAL object)
getobj_next=PEEKW(ObjectAddr&(object)+ob_next)
END FUNCTION

FUNCTION getobj_x (BYVAL object)
getobj_x=PEEKW(ObjectAddr&(object)+ob_x)
END FUNCTION

FUNCTION getobj_y (BYVAL object)
getobj_y=PEEKW(ObjectAddr&(object)+ob_y)
END FUNCTION

FUNCTION getobj_width (BYVAL object)
getobj_width=PEEKW(ObjectAddr&(object)+ob_width)
END FUNCTION

FUNCTION getobj_height (BYVAL object)
getobj_height=PEEKW(ObjectAddr&(object)+ob_height)
END FUNCTION

SUB getobj_xywh (BYVAL object,valuex,valuey,valuew,valueh)
valuex=PEEKW(ObjectAddr&(object)+ob_x)
valuey=PEEKW(ObjectAddr&(object)+ob_y)
valuew=PEEKW(ObjectAddr&(object)+ob_width)
valueh=PEEKW(ObjectAddr&(object)+ob_height)
END SUB


' Set object values

SUB setobj_spec (BYVAL object,BYVAL value&)
POKEL ObjectAddr&(object)+ob_spec,value&
END SUB

SUB setobj_state (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_state,value
END SUB

SUB setobj_flags (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_flags,value
END SUB

SUB setobj_type (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_type,value
END SUB

SUB setobj_x (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_x,value
END SUB

SUB setobj_y (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_y,value
END SUB

SUB setobj_width (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_width,value
END SUB

SUB setobj_height (BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_height,value
END SUB

SUB setobj_xywh (BYVAL object,BYVAL valuex,BYVAL valuey,BYVAL valuew,BYVAL valueh)
IF NOT valuex<0 THEN POKEW ObjectAddr&(object)+ob_x,valuex
IF NOT valuey<0 THEN POKEW ObjectAddr&(object)+ob_y,valuey
IF NOT valuew<0 THEN POKEW ObjectAddr&(object)+ob_width,valuew
IF NOT valueh<0 THEN POKEW ObjectAddr&(object)+ob_height,valueh
END SUB


' Other object routines

SUB remove_state (BYVAL object,BYVAL flag_mask)
STATIC addr&
addr&=ObjectAddr&(object)+ob_state
POKEW addr&,PEEKW(addr&) AND (NOT flag_mask)
END SUB

SUB include_state (BYVAL object,BYVAL flag_mask)
STATIC addr&
addr&=ObjectAddr&(object)+ob_state
POKEW addr&,PEEKW(addr&) OR flag_mask
END SUB

FUNCTION enquire_state (BYVAL object,BYVAL flag_mask)
enquire_state=(PEEKW(ObjectAddr&(object)+ob_state) AND flag_mask)<>0
END FUNCTION

SUB remove_flags (BYVAL object,BYVAL flag_mask)
STATIC addr&
addr&=ObjectAddr&(object)+ob_flags
POKEW addr&,PEEKW(addr&) AND (NOT flag_mask)
END SUB

SUB include_flags (BYVAL object,BYVAL flag_mask)
STATIC addr&
addr&=ObjectAddr&(object)+ob_flags
POKEW addr&,PEEKW(addr&) OR flag_mask
END SUB

FUNCTION enquire_flags (BYVAL object,BYVAL flag_mask)
enquire_flags=(PEEKW(ObjectAddr&(object)+ob_flags) AND flag_mask)<>0
END FUNCTION


' Text object (tedinfo) routines

SUB setobj_text (BYVAL object,BYVAL text$)
STATIC addr&,chars,i

addr&=getobj_spec&(object)
chars=MIN(PEEKW(addr&+te_txtlen)-1,LEN(text$))
addr&=PEEKL(addr&+te_ptext)
FOR i=1 TO chars
	POKEB addr&,ASC(MID$(text$,i,1))
	INCR addr&
NEXT i
POKEB addr&,0
END SUB

FUNCTION getobj_spec$ (BYVAL object)
STATIC addr&,dummy$
dummy$=""
addr&=getobj_spec&(object)
WHILE PEEKB(addr&)
	dummy$=dummy$+CHR$(PEEKB(addr&))
	INCR addr&
WEND
getobj_spec$=dummy$
END FUNCTION

FUNCTION getobj_text$ (BYVAL object)
STATIC addr&,dummy$,type

type=getobj_type(object)
SELECT CASE type
CASE G_STRING,G_BUTTON
	dummy$=getobj_spec$ (object)
CASE ELSE
	dummy$=""
	addr&=getobj_spec&(object)
	addr&=PEEKL(addr&+te_ptext)
	WHILE PEEKB(addr&)
		dummy$=dummy$+CHR$(PEEKB(addr&))
		INCR addr&
	WEND
END SELECT
getobj_text$=dummy$
END FUNCTION

FUNCTION getaddr_text$(BYVAL addr&)
STATIC dummy$
dummy$=""
WHILE PEEKB(addr&)
	dummy$=dummy$+CHR$(PEEKB(addr&))
	INCR addr&
WEND
getaddr_text$=dummy$
END FUNCTION

SUB setobj_spec_str (BYVAL object,BYVAL spec$)
STATIC addr&,i,chars
chars=LEN(spec$)
addr&=getobj_spec&(object)
FOR i=1 TO chars
	POKEB addr&,ASC(MID$(spec$,i,1))
	INCR addr&
NEXT i
POKEB addr&,0
END SUB

FUNCTION aes_version
aes_version=PEEKW(PEEKL(GB+4))
END FUNCTION

'[*END OF FILE*]
