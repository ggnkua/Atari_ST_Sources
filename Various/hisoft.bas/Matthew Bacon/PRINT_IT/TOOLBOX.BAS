' Copyright HiSoft 1991-3
' You are welcome to use this code and modifications of it in
' your own programs, which you may distribute without royalties.
' However this source code and modifications to it may not
' be distributed without our express permission.

DEFINT a-z
LIBRARY "gemaes","gemvdi","gemdos","xbios","bios"

DIM SHARED junk,tree&

'  GEMAES.BH 
'  constant file for HiSoft BASIC

CONST type_tree=0,ob_spec=12,ob_state=10,ob_type=6,te_txtlen=24,te_ptext=0
CONST mask_selected=1,mn_selected=10,FMD_START=0,FMD_FINISH=3
CONST ob_sizeof=24,G_BUTTON=26
' end of GEMAES.BH


' HiSoft BASIC GEM Toolkit
' written by Dave Nutkins and Ofir Gal

DEF ObjectAddr&(object)=tree&+object*ob_sizeof

SUB SelectTreeAddr(BYVAL t&)
tree&=t&
END SUB

SUB SelectTree(BYVAL treeno)
STATIC formaddr&
	junk=rsrc_gaddr(type_tree,treeno,formaddr&)
	SelectTreeAddr formaddr&
END SUB

FUNCTION Getob_spec&(BYVAL object)
Getob_spec&=PEEKL(ObjectAddr&(object)+ob_spec)
END FUNCTION

FUNCTION Getob_state(BYVAL object)
Getob_state=PEEKW(ObjectAddr&(object)+ob_state)
END FUNCTION

FUNCTION Getob_type(BYVAL object)
Getob_type=PEEKW(ObjectAddr&(object)+ob_type)
END FUNCTION

SUB Setob_state(BYVAL object,BYVAL value)
POKEW ObjectAddr&(object)+ob_state,value
END SUB

SUB Exclob_state(BYVAL object,BYVAL flag_mask)
STATIC t&
t&=ObjectAddr&(object)+ob_state
POKEW	t&,PEEKW(t&) AND (NOT flag_mask)
END SUB

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


'Dialogue routines for the Toolbox

FUNCTION HandleDialog(BYVAL editnum)
STATIC x,y,w,h,but
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
but=form_do(tree&,editnum) AND &h7fff
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
IF Getob_type(but)=G_BUTTON THEN
	Exclob_state but,mask_selected
END IF
HandleDialog=but
END FUNCTION


'Execute routines for the Toolbox

FUNCTION GetWholeEnvironment$
STATIC i,res$,a$
res$=""
i=1
DO
	a$=ENVIRON$(i)
	IF a$="" THEN EXIT LOOP
	res$=res$+a$+CHR$(0)
	INCR i
LOOP
GetWholeEnvironment$=res$
END FUNCTION

' Resource file .bh file

CONST 	MENU1%=     0

CONST	MENU_ABOUT%=     9
CONST	MENU_QUIT%=    18
CONST	MENU_LOAD%=    19
CONST	MENU_VIEW%=    21
CONST	MENU_PRINT%=    22
CONST	MENU_TEXT%=    25
CONST	MENU_PAGE%=    26
CONST	MENU_MISC%=    27
CONST	MENU_HEADER%=    28
CONST	MENU_FOOTER%=    29
CONST	MENU_RESET%=    32
CONST	MENU_LOADPDRIVER%=    33
CONST	MENU_FORMFEED%=    35
CONST	MENU_TEST%=    36

CONST 	MENU2%=     1


CONST 	FORM_ABOUT%=     2

CONST	ABOUT_OK%=     6

CONST 	FORM_PAGE%=     3

CONST	PAGE_FROMPAGE%=     3
CONST	PAGE_HEADER%=     4
CONST	PAGE_TOPAGE%=     6
CONST	PAGE_FOOTER%=     7
CONST	PAGE_NOPAGES%=     9
CONST	PAGE_LMARGIN%=    11
CONST	PAGE_RMARGIN%=    12
CONST	PAGE_PRINTALL%=    13
CONST	PAGE_PRINTODD%=    15
CONST	PAGE_PRINTEVEN%=    18
CONST	PAGE_LINESPP%=    20
CONST	PAGE_FORMFEED%=    21
CONST	PAGE_NOCOPIES%=    23
CONST	EDIT_HEADER%=    25
CONST	EDIT_FOOTER%=    26
CONST	PAGE_CANCEL%=    27
CONST	PAGE_OK%=    28

CONST 	FORM_TEXT%=     4

CONST	QUALITY_LQ%=     7
CONST	QUALITY_DRAFT%=     8
CONST	STYLE_ITALIC%=    10
CONST	STYLE_EMPHASISED%=    12
CONST	STYLE_UNDERLINED%=    14
CONST	STYLE_2XHEIGHT%=    16
CONST	STYLE_PROPORT%=    18
CONST	STYLE_JOKER%=    20
CONST	TEXT_JOKER%=    21
CONST	STYLE_SUPERSCRPT%=    22
CONST	STYLE_SUBSCRPT%=    24
CONST	FONT_FONT1%=    28
CONST	FONT_FONT2%=    29
CONST	FONT_FONT4%=    30
CONST	FONT_NAME1%=    31
CONST	FONT_NAME2%=    32
CONST	FONT_NAME3%=    33
CONST	FONT_NAME4%=    34
CONST	FONT_FONT3%=    35
CONST	TEXT_CANCEL%=    36
CONST	TEXT_OK%=    37
CONST	STYLE_EXPANDED%=    40
CONST	STYLE_CONDENSED%=    42
CONST	TEXT_JUSTLEFT%=    44
CONST	TEXT_JUSTCENTRE%=    46
CONST	TEXT_JUSTRIGHT%=    48

CONST 	FORM_MISC%=     5

CONST	MISC_FILE%=     4
CONST	MISC_NOLINES%=     6
CONST	MISC_NOPAGES%=     8
CONST	MISC_PDRIVER%=    12
CONST	MISC_FSPDRIVER%=    13
CONST	MISC_VIEWER%=    15
CONST	MISC_FSVIEWER%=    16
CONST	MISC_SAVEDEFAULT%=    17
CONST	MISC_OK%=    18

CONST 	FORM_HEADER%=     6

CONST	HEADER_MESSAGE%=     3
CONST	HEADER_UNDERLIND%=     5
CONST	HEADER_2XHEIGHT%=     7
CONST	HEADER_CONDENSED%=     9
CONST	HEADER_JOKER%=    11
CONST	HEADER_JOKERNAME%=    12
CONST	HEADER_EXPANDED%=    13
CONST	HEADER_EMPHASISD%=    15
CONST	HEADER_FONT1%=    19
CONST	HEADER_FONT2%=    20
CONST	HEADER_FONT4%=    21
CONST	HEADER_FONT3%=    22
CONST	HEADER_F1NAME%=    23
CONST	HEADER_F2NAME%=    24
CONST	HEADER_F3NAME%=    25
CONST	HEADER_F4NAME%=    26
CONST	HEADER_CANCEL%=    27
CONST	HEADER_OK%=    28
CONST	HEADER_JUSTLEFT%=    31
CONST	HEADER_JUSTCENTR%=    33
CONST	HEADER_JUSTRIGHT%=    35

CONST 	FORM_FOOTER%=     7

CONST	FOOTER_MESSAGE%=     3
CONST	FOOTER_UNDERLIND%=     5
CONST	FOOTER_2XHEIGHT%=     7
CONST	FOOTER_CONDENSED%=     9
CONST	FOOTER_JOKER%=    11
CONST	FOOTER_JOKERNAME%=    12
CONST	FOOTER_EXPANDED%=    13
CONST	FOOTER_EMPHASISD%=    15
CONST	FOOTER_FONT1%=    19
CONST	FOOTER_FONT2%=    20
CONST	FOOTER_FONT4%=    21
CONST	FOOTER_FONT3%=    22
CONST	FOOTER_F1NAME%=    23
CONST	FOOTER_F2NAME%=    24
CONST	FOOTER_F3NAME%=    25
CONST	FOOTER_F4NAME%=    26
CONST	FOOTER_CANCEL%=    27
CONST	FOOTER_OK%=    28
CONST	FOOTER_JUSTLEFT%=    31
CONST	FOOTER_JUSTCENTR%=    33
CONST	FOOTER_JUSTRIGHT%=    35
