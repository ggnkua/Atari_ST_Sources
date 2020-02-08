
' [MENU.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

' DECLARE FUNCTION ConvertAlt(ScanCode)		' Can be found in TOOLBX_C.BAS

CONST MaxShortCut=150

SUB Init_Menu(BYVAL treeno,BYVAL exititem)
junk=rsrc_gaddr(0,treeno,menutree&)
menu_bar menutree&,1
menu_exititem=exititem
menus_enabled=-1
CALL ScanMenu
END SUB


FUNCTION menu_checkitem (BYVAL item,BYVAL flag)
CALL menu_icheck (menutree&,item,flag)
menu_checkitem=-1
END FUNCTION


FUNCTION menu_disableitem (BYVAL item,BYVAL flag)
CALL menu_ienable (menutree&,item,flag)
menu_disableitem=-1
END FUNCTION


FUNCTION menu_selectitem (BYVAL item,BYVAL flag)
CALL menu_tnormal (menutree&,item,flag)
menu_selectitem=-1
END FUNCTION


FUNCTION menu_changetext (BYVAL item,BYVAL text$)
CALL menu_text (menutree&,item,text$)
menu_changetext=-1
END FUNCTION


FUNCTION CreateShortCut(BYVAL Scancode,BYVAL kstate)
SHARED total_shortcuts,scascii(),scchar(),sctitle(),scitem(),mess()
STATIC char,dummy,altcode

char=Scancode MOD 256
IF kstate=1 THEN CreateShortCut=0 : EXIT SUB
IF kstate=2 THEN CreateShortCut=0 : EXIT SUB
IF char=32 THEN CreateShortCut=0 : EXIT SUB
altcode=ConvertAlt(ScanCode)
FOR dummy=1 TO total_shortcuts
	SELECT CASE kstate
	CASE 5,6,9,10
		IF (scascii(dummy)=-2 AND scchar(dummy)=char) _
		OR (scascii(dummy)=-3 AND char=0 AND altcode=scchar(dummy)) THEN
			CreateShortCut=-1 : mess(0)=mn_selected
			mess(3)=sctitle(dummy) : mess(4)=scitem(dummy)
			EXIT FUNCTION
		END IF
	CASE ELSE
		IF (scascii(dummy)=-1 AND scchar(dummy)=char) _
		OR (scascii(dummy)=0 AND char=0 AND altcode=scchar(dummy)) _
		OR (scascii(dummy)=1 AND Scancode=scchar(dummy)) THEN
			CreateShortCut=-1 : mess(0)=mn_selected
			mess(3)=sctitle(dummy) : mess(4)=scitem(dummy)
			EXIT FUNCTION
		END IF
	END SELECT
NEXT dummy
CreateShortCut=0
END FUNCTION


SUB ScanMenu
SHARED total_shortcuts,scspec$(),scspecval(),scascii(),scchar()
SHARED scitem(),sctitle(),total_count
STATIC oldtree&,dummy,title,item,type

REDIM scspec$(MaxShortCut),scspecval(MaxShortCut) : total_count=0
RecordSpecial "Help",&h6200 : RecordSpecial "Undo",&h6100
RecordSpecial "BS",&hE08 : RecordSpecial "Del",&h537F
RecordSpecial "Esc",&h011b : RecordSpecial "Ins",&h5200
RecordSpecial "Home",&h4700: RecordSpecial "Clr",&h4737
RecordSpecial "Tab",&h0f09
FOR dummy=1 TO 10
	RecordSpecial "F"+CHR$(dummy+"0"%),&h3A00+&h100*dummy
	RecordSpecial CHR$(1)+"F"+CHR$(dummy+"0"%),&h5300+&h100*dummy
NEXT dummy

REDIM scascii(MaxShortCut),scchar(MaxShortCut),scitem(MaxShortCut),sctitle(MaxShortCut)
oldtree&=tree& : SelectTreeAddr menutree& : title=1 : item=0 : total_shortcuts=0
DO
	type=getobj_type(item)
	SELECT CASE type
	CASE G_TEXT: ConsiderString item,title,getobj_text$(item)
	CASE G_STRING: ConsiderString item,title,getobj_spec$(item)
	CASE G_BOX: INCR title
	END SELECT
	IF enquire_flags(item,mask_lastob) THEN EXIT LOOP
	INCR item
LOOP
END SUB


SUB Record(BYVAL ascii,BYVAL char,BYVAL item,BYVAL title)
SHARED total_shortcuts,scascii(),scchar(),scitem(),sctitle()

INCR total_shortcuts
IF total_shortcuts>MaxShortCut THEN
	DECR total_shortcuts
ELSE
	scascii(total_shortcuts)=ascii : scchar(total_shortcuts)=char
	scitem(total_shortcuts)=item : sctitle(total_shortcuts)=title
END IF
END SUB


SUB ConsiderString(BYVAL item,BYVAL title,BYVAL text$)
SHARED total_shortcuts,scspec$(),scspecval(),total_count
STATIC dummy,temp,char,i,keycontrol

dummy=LEN(text$)
IF dummy<1 THEN EXIT SUB
IF RIGHT$(text$,1)=" " THEN text$=LEFT$(text$,dummy-1) : DECR dummy
IF dummy<3 THEN EXIT SUB

FOR temp=1 TO total_count
	i=LEN(scspec$(temp))
	IF dummy>i+2 THEN
		IF RIGHT$(text$,i)=scspec$(temp) THEN Record 1,scspecval(temp),item,title : EXIT SUB
	END IF
NEXT temp

keycontrol=ASC(MID$(text$,dummy-1,1))
char=ASC(UCASE$(RIGHT$(text$,1)))
SELECT CASE keycontrol
CASE " "%,1 : Record -1,char,item,title
CASE "^"%
	IF ASC(MID$(text$,dummy-2,1))=1 THEN
		Record -2,char-&h40,item,title
	ELSE
		Record -1,char-&h40,item,title
	END IF
CASE 7
	IF ASC(MID$(text$,dummy-2,1))=1 THEN
		Record -3,char,item,title
	ELSE
		Record 0,char,item,title
	END IF
END SELECT
END SUB


SUB RecordSpecial(BYVAL dummy$,BYVAL ScanCode)
SHARED scspec$(1),scspecval(1),total_count

INCR total_count
scspec$(total_count)=dummy$
scspecval(total_count)=ScanCode
END SUB

'[*END OF FILE*]
