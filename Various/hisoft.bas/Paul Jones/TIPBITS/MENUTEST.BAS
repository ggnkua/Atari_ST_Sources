
LIBRARY "gemaes"
DEFINT a-z
REM $include pjcotest.lst
REM $include gemaes.bh

REM $option k10,gy!

a=rsrc_load ("PJCOTEST.RSC")
a=rsrc_gaddr (0,menu1,menuaddr&)
a=rsrc_gaddr (0,popmenu,ptree&)

DIM mess(16)
DIM messag(16)
a&=VARPTR(mess(0))
SPOKEL a&,ptree&
SPOKEW a&+4,0 : REM was pop
SPOKEW a&+6,1
SPOKEW a&+8,0
SPOKEW a&+10,0
a=menu_attach (1,menuaddr&,pop,a&)
REM d=menu_istart (1,menuaddr&,1,pop)
REM tree points TO the object tree of the menu TO alter. imenu specifies 
REM the object within the submenu which will be aligned with menu item 
REM item.

REM b=form_alert (1,"[1][ "+STR$(a)+","+STR$(d)+" ][ Ok ]")
menu_bar menuaddr&,1


DO
	evnt_mesag VARPTR(messag(0))
	type=SPEEKW (VARPTR(messag(0)))
	item=SPEEKW (VARPTR(messag(0))+6)
	title=SPEEKW (VARPTR(messag(0))+8)
LOOP UNTIL type=10

IF type=10 THEN
	b=form_alert (1,"[1][ "+STR$(item)+" ][ OK ]")
	menu_bar menuaddr&,0
END IF