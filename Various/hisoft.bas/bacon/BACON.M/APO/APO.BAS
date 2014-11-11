'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' The Atari Personnel Organizer - Beta 1.33
' ½ 1996,97 Cadenza Software - Written by Matthew Bacon
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' Copyright HiSoft 1991-3

'$INCLUDE E:\CADENZA.97\APO\APO.BH
'$option q80,y
LIBRARY "bios"
CONST cell_size=1
'$DYNAMIC
DIM SHARED TITLE_DATA$(0),CONTACT_DATA$(0),FORENAME_DATA$(0),SURNAME_DATA$(0)
DIM SHARED ADDRESS_DATA$(0),STREET_DATA$(0),TOWN_DATA$(0),COUNTY_DATA$(0)
DIM SHARED POSTCODE_DATA$(0),PHONE1_DATA$(0),PHONE2_DATA$(0),FAX_DATA$(0)
DIM SHARED EMAIL_DATA$(0),BIRTHDAY_DATA$(0),NOTES1_DATA$(0),NOTES2_DATA$(0)
DIM SHARED D_DATA$(0),ALARM_DATA$(7),WEEK_BIRTH$(0),WEEK_SCHEDULE$(0)
DIM SHARED JANUARY$(32),FEBUARY$(32),MARCH$(32),APRIL$(32),MAY$(32),JUNE$(32)
DIM SHARED JULY$(32),AUGUST$(32),SEPTEMBER$(32),OCTOBER$(32),NOVEMBER$(32)
DIM SHARED DECEMBER$(32)

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION get_pop_text$(BYVAL poptree,BYVAL popobj)
STATIC oldtree&
oldtree&=tree&
selecttree poptree
get_pop_text$=RIGHT$(Gette_ptext$(popobj),LEN(Gette_ptext$(popobj))-2)
tree&=oldtree&
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION get_pop_alarm$(BYVAL poptree,BYVAL popobj)
STATIC oldtree&
oldtree&=tree&
selecttree poptree
get_pop_alarm$=Gette_ptext$(popobj)
tree&=oldtree&
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION get_pop_string$(BYVAL poptree,BYVAL popobj)
STATIC oldtree&
oldtree&=tree&
selecttree poptree
get_pop_string$=RTRIM$(LTRIM$(getob_spec$(popobj)))
tree&=oldtree&
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' File selector handler - returns a new pathname
' the global variables fspath$ and fsname$ keep the appropriate
' GEM items.
SUB FileSelect$(fspath$,fsname$,fsmessage$)
SHARED fspath$,fsname$,fsmessage$,FileSelect$
STATIC ok,i,ch
IF fspath$="" THEN CALL InitFileSelector
IF aes_version<&H130 THEN
	fsel_input fspath$,fsname$,ok
ELSE 
	fsel_exinput fspath$,fsname$,ok,fsmessage$
END IF
IF ok THEN
	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 
	FileSelect$=LEFT$(fspath$,i)+fsname$
ELSE
	FileSelect$=""
END IF
END SUB

' initialise the file selector
SUB	InitFileSelector
SHARED fspath$,fsname$
fspath$=CURDIR$+"\*.*"
fsname$=""
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Sette_ptext_update(BYVAL object,BYVAL newtext$,BYVAL FormName)
STATIC oldtree&

oldtree&=tree&
SelectTree FormName
Sette_ptext object,newtext$
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL(total_items,display_items,top_item,object,background)
STATIC i!,height!,y_position!,x,y,w,h

IF total_items=<display_items THEN
	Setob_y object,0
	Setob_height object,Getob_Height(background)
ELSE
	i!=Getob_Height(background)/total_items
	height!=i!*display_items
	y_position!=i!*top_item
	Setob_y object,y_position!
	Setob_height object,height!
END IF
w=Getob_width(background)
h=Getob_height(background)
junk=objc_offset(tree&,background,x,y)
junk=objc_draw(tree&,background,10,x,y,w,h)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL2(total_items,display_items,object,background)
STATIC i!,height!

IF total_items=<display_items THEN
	Setob_y object,0
	Setob_height object,Getob_Height(background)
ELSE
	i!=Getob_Height(background)/total_items
	height!=i!*display_items
	Setob_y object,0
	Setob_height object,height!
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL3(total_items,display_items,top_item,object,background)
STATIC i!,height!,y_position!,x,y,w,h,oldtree&

oldtree&=tree&
SelectTree ADDRESS_EDIT

IF total_items=<10 THEN
	i!=Getob_Height(background)/total_items
	height!=i!*1
	y_position!=i!*(top_item-1)
	Setob_y object,y_position!
	Setob_height object,height!
ELSE
	i!=Getob_Height(background)/display_items
	height!=i!*1
	SELECT CASE top_item
		CASE 0 TO (total_items/5)
			Setob_y object,0
			EXIT SELECT
		CASE (total_items/5) TO 2*(total_items/5)
			Setob_y object,i!
			EXIT SELECT
		CASE 2*(total_items/5) TO 3*(total_items/5)
			Setob_y object,i!*2
			EXIT SELECT
		CASE 3*(total_items/5) TO 4*(total_items/5)
			Setob_y object,i!*3
			EXIT SELECT
		CASE 4*(total_items/5) TO 5*(total_items/5)
			Setob_y object,i!*4
			EXIT SELECT
		CASE 5*(total_items/5) TO 6*(total_items/5)
			Setob_y object,i!*5
			EXIT SELECT
	END SELECT
	Setob_height object,height!
END IF

w=Getob_width(background)
h=Getob_height(background)
SelectTree ADDRESS_EDIT
junk=objc_offset(tree&,background,x,y)
junk=objc_draw(tree&,background,10,x,y,w,h)
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL4(total_items,display_items,top_item,object,background)
STATIC i!,height!,y_position!,x,y,w,h,oldtree&

oldtree&=tree&
SelectTree ADDRESS_EDIT

IF total_items=<10 THEN
	i!=Getob_Height(background)/total_items
	height!=i!*1
	y_position!=i!*(top_item-1)
	Setob_y object,y_position!
	Setob_height object,height!
ELSE
	i!=Getob_Height(background)/display_items
	height!=i!*1
	SELECT CASE top_item
		CASE 0 TO (total_items/5)
			Setob_y object,0
			EXIT SELECT
		CASE (total_items/5) TO 2*(total_items/5)
			Setob_y object,i!
			EXIT SELECT
		CASE 2*(total_items/5) TO 3*(total_items/5)
			Setob_y object,i!*2
			EXIT SELECT
		CASE 3*(total_items/5) TO 4*(total_items/5)
			Setob_y object,i!*3
			EXIT SELECT
		CASE 4*(total_items/5) TO 5*(total_items/5)
			Setob_y object,i!*4
			EXIT SELECT
		CASE 5*(total_items/5) TO 6*(total_items/5)
			Setob_y object,i!*5
			EXIT SELECT
	END SELECT
	Setob_height object,height!
END IF
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB INITIALISE
SHARED about_handle,Loaded_Path$
STATIC i

Loaded_Path$=CURDIR$+"\"

SelectTree ADDRESS_MAIN
Sette_ptext ADD_AUTOLOCATE,""
Sette_ptext ADD_SWITCH,"Surname"
FOR i=ADD1 TO ADD15
	Sette_ptext i,"______________________  ______________________"
NEXT

SelectTree ADDRESS_EDIT
FOR i=ADD_ETITLE TO ADD_ENOTES2
	Sette_ptext i,""
NEXT

SelectTree ADDRESS_ADD
FOR i=ADD_ATITLE TO ADD_ANOTES2
	Sette_ptext i,""
NEXT

SelectTree ADDRESS_PRINT
Sette_ptext ADD_PRANGEF,""
Sette_ptext ADD_PRANGET,""

SelectTree DIARY_SUMMARY
Sette_ptext D_S1,"__/__/____ ________________________________"
Sette_ptext D_S1a,"________________________________"
Sette_ptext D_S2,"__/__/____ ________________________________"
Sette_ptext D_S2a,"________________________________"
Sette_ptext D_S3,"__/__/____ ________________________________"
Sette_ptext D_S3a,"________________________________"
Sette_ptext D_S4,"__/__/____ ________________________________"
Sette_ptext D_S4a,"________________________________"
Sette_ptext D_S5,"__/__/____ ________________________________"
Sette_ptext D_S5a,"________________________________"
Sette_ptext D_S6,"__/__/____ ________________________________"
Sette_ptext D_S6a,"________________________________"
Sette_ptext D_S7,"__/__/____ ________________________________"
Sette_ptext D_S7a,"________________________________"

SelectTree DIARY_PAGE
FOR i=D1 TO D16
	Sette_ptext i,""
NEXT

SelectTree BIRTHDAY
FOR i=B1 TO B18
	Sette_ptext i,""
NEXT

SelectTree DIARY_SEARCH
Sette_ptext D_SSEARCH,""

SelectTree ALARM
FOR i=A_MES1 TO A_MES6
	Sette_ptext i,""
NEXT

SelectTree ALARM_FORM
FOR i=A_AMES1 TO A_AMES6
	Sette_ptext i,"______________________________"
NEXT
CALL Initialise_Clok

SelectTree CALCULATOR
FOR i=CALC_ANSWER1 TO CALC_ANSWER2
	Sette_ptext i,""
NEXT

SelectTree NOTEPAD
FOR i=N1 TO N18
	Sette_ptext i,""
NEXT
about_handle=openformwindow(" About... ",&h0B,FORM_ABOUT,0,ABOUT_OK,VARPTRS(close_aboutdialog))
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB REDIM_DATA(value)
REDIM PRESERVE TITLE_DATA$(value)
REDIM PRESERVE CONTACT_DATA$(value)
REDIM PRESERVE FORENAME_DATA$(value)
REDIM PRESERVE SURNAME_DATA$(value)
REDIM PRESERVE ADDRESS_DATA$(value)
REDIM PRESERVE STREET_DATA$(value)
REDIM PRESERVE TOWN_DATA$(value)
REDIM PRESERVE COUNTY_DATA$(value)
REDIM PRESERVE POSTCODE_DATA$(value)
REDIM PRESERVE PHONE1_DATA$(value)
REDIM PRESERVE PHONE2_DATA$(value)
REDIM PRESERVE FAX_DATA$(value)
REDIM PRESERVE EMAIL_DATA$(value)
REDIM PRESERVE BIRTHDAY_DATA$(value)
REDIM PRESERVE NOTES1_DATA$(value)
REDIM PRESERVE NOTES2_DATA$(value)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_aboutdialog
SHARED commonclose,commonobj,about_handle

commonclose=0										
SELECT CASE commonobj
	CASE ABOUT_OK
		about_handle=0
		commonclose=-1
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_addressdialog
SHARED commonclose,commonobj,address_handle,addedit_handle,addadd_handle
SHARED addprint_handle,total_additems,top_additem,current_record
STATIC delete_status,i,res,res$,x,y

commonclose=0										
SELECT CASE commonobj
	CASE ADD_NEW
		CALL ADDRESS_NEW
	CASE ADD_LOAD
		CALL ADDRESS_LOAD
	CASE ADD_SAVE
		CALL ADDRESS_SAVE
	CASE ADD_ADD
		Setob_state commonobj,0:Object_Redraw address_handle,commonobj
		IF addadd_handle THEN
			TopAWindow addadd_handle
		ELSE
			SelectTree ADDRESS_ADD
			FOR i=ADD_ATITLE TO ADD_ANOTES2
				Sette_ptext i,""
			NEXT
			addadd_handle=openformwindow(" Add Record :"+STR$(total_additems+1)+" ",&h0B,ADDRESS_ADD,ADD_ATITLE,ADD_ACANCEL,VARPTRS(add_addressdialog))
		END IF
		EXIT SUB
	CASE ADD_DELETE
		IF delete_status=0 THEN
			delete_status=-1
			Setob_state ADD_NEW,8:Object_Redraw address_handle,ADD_NEW
			Setob_state ADD_LOAD,8:Object_Redraw address_handle,ADD_LOAD
			Setob_state ADD_SAVE,8:Object_Redraw address_handle,ADD_SAVE
			Setob_state ADD_ADD,8:Object_Redraw address_handle,ADD_ADD
			Setob_state ADD_SORT,8:Object_Redraw address_handle,ADD_SORT
			Setob_state ADD_PRINT,8:Object_Redraw address_handle,ADD_PRINT
			EXIT SUB
		ELSE
			delete_status=0
			Setob_state ADD_NEW,0:Object_Redraw address_handle,ADD_NEW
			Setob_state ADD_LOAD,0:Object_Redraw address_handle,ADD_LOAD
			Setob_state ADD_SAVE,0:Object_Redraw address_handle,ADD_SAVE
			Setob_state ADD_ADD,0:Object_Redraw address_handle,ADD_ADD
			Setob_state ADD_SORT,0:Object_Redraw address_handle,ADD_SORT
			Setob_state ADD_PRINT,0:Object_Redraw address_handle,ADD_PRINT
		END IF
	CASE ADD_SORT
		CALL ADDRESS_SORT
	CASE ADD_PRINT
		Setob_state commonobj,0:Object_Redraw address_handle,commonobj
		IF addprint_handle THEN
			TopAWindow addprint_handle
		ELSE
			addprint_handle=openformwindow(" Print Records ",&h0B,ADDRESS_PRINT,ADD_PRANGEF,ADD_PCANCEL,VARPTRS(print_addressdialog))
		END IF
		EXIT SUB
	CASE ADD_POPUP
		res=0
		junk=objc_offset(tree&,ADD_POPUP,x,y)
		res=popup(0,ADDRESS_POPMAIN,res,x,y)
		IF res THEN
			res$=get_pop_text$(ADDRESS_POPMAIN,res)
			Sette_ptext ADD_POPUP,res$
		END IF
		Object_Redraw address_handle,commonobj
		CALL AutoLocate
		EXIT SUB
	CASE ADD_SWITCH
		CALL ADDRESS_SWITCH:EXIT SUB
	CASE ADD1 TO ADD15
		IF (top_additem-15+commonobj)>total_additems-1 THEN EXIT SUB
		current_record=(top_additem-15+commonobj)+1
		IF delete_status=-1 THEN
			CALL ADDRESS_DELETE(current_record)
		ELSE
			IF addedit_handle THEN
				CALL UPDATE_ADDEDIT2(current_record)
				TopAWindow addedit_handle
				Object_Redraw address_handle,ADDRESS_EBACK
				Object_Redraw address_handle,ADD_EBACK
			ELSE
				addedit_handle=openformwindow(" Edit Record :"+STR$(current_record)+" ",&h0B,ADDRESS_EDIT,ADD_ETITLE,ADD_ECANCEL,VARPTRS(edit_addressdialog))
				CALL UPDATE_ADDEDIT2(current_record)
			END IF
		END IF
		EXIT SUB
	CASE M_ARROWUP
		CALL ADDRESS_ARROWUP
	CASE M_ARROWDOWN
		CALL ADDRESS_ARROWDOWN
	CASE ADD_QUIT
		address_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw address_handle,commonobj
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_NEW
SHARED total_additems,top_additem,address_handle
STATIC button

MOUSE 2
button=form_alert(2,"[2][  Address Book: |  Do you really want to lose |  all unsaved data? ][ Continue | Cancel ]")
SELECT CASE button
CASE 1
	total_additems=0
	top_additem=0
	CALL REDIM_DATA(cell_size+1)
	CALL dis_adddata
	Object_Redraw address_handle,ADD_MAINLIST
	CALL SCROLL(total_additems,15,top_additem,M_SLIDER,M_BACKGROUND)
END SELECT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_LOAD
SHARED FileSelect$,fsname$,fspath$,total_additems,top_additem,address_handle
SHARED highlight
STATIC i,record_no,record,button

MOUSE 2
button=form_alert(2,"[2][  Address Book: |  Do you really want to lose |  all unsaved data? ][ Continue | Cancel ]")
SELECT CASE button
	CASE 2
		MOUSE 0
		EXIT SUB
END SELECT

MOUSE 2
CALL FileSelect$(CURDIR$+"\*.DAT",fsname$,"Load...")
MOUSE 0

MOUSE 2
IF fsname$<>"" THEN
IF FileSelect$<>"" THEN
	IF FEXISTS(FileSelect$) THEN
		OPEN FileSelect$ FOR INPUT AS #1
		i=1:record_no=1:record=1
		CALL REDIM_DATA(record*5)
		DO
			INPUT #1,TITLE_DATA$(i),CONTACT_DATA$(i),FORENAME_DATA$(i),SURNAME_DATA$(i)
			INPUT #1,ADDRESS_DATA$(i),STREET_DATA$(i),TOWN_DATA$(i),COUNTY_DATA$(i)
			INPUT #1,POSTCODE_DATA$(i),PHONE1_DATA$(i),PHONE2_DATA$(i),FAX_DATA$(i)
			INPUT #1,EMAIL_DATA$(i),BIRTHDAY_DATA$(i),NOTES1_DATA$(i),NOTES2_DATA$(i)
			INCR i
			INCR record_no
			IF record_no=5 THEN record_no=0:INCR record:CALL REDIM_DATA(record*5)
		LOOP UNTIL EOF(1)
		CLOSE #1
		total_additems=i-1
		top_additem=0
	ELSE
		junk=form_alert(1,"[1][  Address Book: | Error while loading data |  file into memory. | ][ Abort ]")
	END IF
END IF

IF total_additems>0 THEN
	IF highlight>=15 THEN Exclob_state highlight,mask_selected:Object_Redraw address_handle,highlight
	CALL dis_adddata
	CALL SCROLL(total_additems,15,top_additem,M_SLIDER,M_BACKGROUND)
	Object_Redraw address_handle,ADD_AUTOLOCATE
	highlight=ADD_MAINLIST
	CALL AutoLocate
END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_SAVE
SHARED total_additems,FileSelect$,fsname$,fspath$
STATIC i,k

IF total_additems=0 THEN junk=form_alert(1,"[1][  Address Book: |  There are no records to save!  | | ][  OK  ]"):EXIT SUB
MOUSE 2
CALL FileSelect$(CURDIR$+"\*.DAT",fsname$,"Save...")
MOUSE 2
IF fsname$<>"" THEN
IF FileSelect$<>"" THEN
	OPEN FileSelect$ FOR OUTPUT AS #1
	FOR i=1 TO total_additems
		WRITE #1,TITLE_DATA$(i),CONTACT_DATA$(i),FORENAME_DATA$(i),SURNAME_DATA$(i)
		WRITE #1,ADDRESS_DATA$(i),STREET_DATA$(i),TOWN_DATA$(i),COUNTY_DATA$(i)
		WRITE #1,POSTCODE_DATA$(i),PHONE1_DATA$(i),PHONE2_DATA$(i),FAX_DATA$(i)
		WRITE #1,EMAIL_DATA$(i),BIRTHDAY_DATA$(i),NOTES1_DATA$(i),NOTES2_DATA$(i)
	NEXT
	CLOSE #1
	IF total_additems=1 THEN junk=form_alert(1,"[1][  Address Book: |  One record has been saved.  | ][  OK  ]")
	IF total_additems>1 THEN junk=form_alert(1,"[1][  Address Book: | "+STR$(total_additems)+" records have been saved.  | ][  OK  ]")
END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB add_addressdialog
SHARED commonclose,commonobj,addadd_handle,total_additems
STATIC oldtree&

oldtree&=tree&
SelectTree ADDRESS_ADD

commonclose=0										
SELECT CASE commonobj
	CASE ADD_AOK
		MOUSE 2
		INCR total_additems:CALL REDIM_DATA(total_additems+1)
		TITLE_DATA$(total_additems)=Gette_ptext$(ADD_ATITLE)
		CONTACT_DATA$(total_additems)=Gette_ptext$(ADD_AGREETING)
		FORENAME_DATA$(total_additems)=Gette_ptext$(ADD_AFORENAME)
		SURNAME_DATA$(total_additems)=Gette_ptext$(ADD_ASURNAME)
		ADDRESS_DATA$(total_additems)=Gette_ptext$(ADD_AADDRESS)
		STREET_DATA$(total_additems)=Gette_ptext$(ADD_ASTREET)
		TOWN_DATA$(total_additems)=Gette_ptext$(ADD_ATOWN)
		COUNTY_DATA$(total_additems)=Gette_ptext$(ADD_ACOUNTY)
		POSTCODE_DATA$(total_additems)=Gette_ptext$(ADD_APOSTCODE)
		PHONE1_DATA$(total_additems)=Gette_ptext$(ADD_APHONE1)
		PHONE2_DATA$(total_additems)=Gette_ptext$(ADD_APHONE2)
		FAX_DATA$(total_additems)=Gette_ptext$(ADD_AFAX)
		EMAIL_DATA$(total_additems)=Gette_ptext$(ADD_AEMAIL)
		BIRTHDAY_DATA$(total_additems)=Gette_ptext$(ADD_ABIRTHDAY)
		NOTES1_DATA$(total_additems)=Gette_ptext$(ADD_ANOTES1)
		NOTES2_DATA$(total_additems)=Gette_ptext$(ADD_ANOTES2)
		CALL UPDATE_ADDMAIN
		CALL AutoLocate
		addadd_handle=0
		commonclose=-1
		MOUSE 0
	CASE ADD_ACANCEL
		addadd_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw addadd_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_DELETE(current_record)
SHARED commonobj,total_additems,top_additem,highlight,address_handle
STATIC i,oldtree&,chighlight

oldtree&=tree&
SelectTree ADDRESS_MAIN

IF total_additems>1 THEN
	MOUSE 2
	chighlight=highlight
	FOR i=current_record TO (total_additems-1)
		TITLE_DATA$(i)=TITLE_DATA$(i+1)
		CONTACT_DATA$(i)=CONTACT_DATA$(i+1)
		FORENAME_DATA$(i)=FORENAME_DATA$(i+1)
		SURNAME_DATA$(i)=SURNAME_DATA$(i+1)
		ADDRESS_DATA$(i)=ADDRESS_DATA$(i+1)
		STREET_DATA$(i)=STREET_DATA$(i+1)
		TOWN_DATA$(i)=TOWN_DATA$(i+1)
		COUNTY_DATA$(i)=COUNTY_DATA$(i+1)
		POSTCODE_DATA$(i)=POSTCODE_DATA$(i+1)
		PHONE1_DATA$(i)=PHONE1_DATA$(i+1)
		PHONE2_DATA$(i)=PHONE2_DATA$(i+1)
		FAX_DATA$(i)=FAX_DATA$(i+1)
		EMAIL_DATA$(i)=EMAIL_DATA$(i+1)
		BIRTHDAY_DATA$(i)=BIRTHDAY_DATA$(i+1)
		NOTES1_DATA$(i)=NOTES1_DATA$(i+1)
		NOTES2_DATA$(i)=NOTES2_DATA$(i+1)
	NEXT
	DECR total_additems
	CALL REDIM_DATA(total_additems+1)
	IF (top_additem+15)>total_additems THEN top_additem=(total_additems-15)
	IF top_additem<0 THEN top_additem=0
	
	CALL UPDATE_ADDMAIN
	MOUSE 0
	IF chighlight<>commonobj THEN
		IF chighlight<commonobj THEN CALL AUTOLOCATE
		EXIT SUB
	END IF
	tree&=oldtree&
	CALL AUTOLOCATE
ELSE
	MOUSE 2
	total_additems=0
	top_additem=0
	CALL REDIM_DATA(cell_size+1)
	CALL dis_adddata
	Object_Redraw address_handle,ADD_MAINLIST
	CALL SCROLL(total_additems,15,top_additem,M_SLIDER,M_BACKGROUND)
	tree&=oldtree&
	MOUSE 0
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB print_addressdialog
SHARED commonclose,commonobj,addprint_handle,total_additems
STATIC oldtree&,i,from_record,to_record

oldtree&=tree&
SelectTree ADDRESS_PRINT

commonclose=0										
SELECT CASE commonobj
	CASE ADD_POK
		MOUSE 2
		IF Getob_state(ADD_PFROM)=1 THEN ' from/to...
			from_record=VAL(Gette_ptext$(ADD_PRANGEF))
			to_record=VAL(Gette_ptext$(ADD_PRANGET))

			IF from_record<1 THEN from_record=1
			IF to_record>total_additems THEN to_record=total_additems
			IF Gette_ptext$(ADD_PRANGEF)="" THEN from_record=1
			IF Gette_ptext$(ADD_PRANGET)="" THEN to_record=total_additems
			IF from_record>to_record THEN to_record=from_record
		ELSE ' all records
			from_record=1
			to_record=total_additems
		END IF

		IF Getob_state(ADD_PPRINT)=1 THEN ' to printer
			IF Getob_state(ADD_PLIST)=1 THEN ' print as list
				CALL PrintList(from_record,to_record)
			ELSE ' normal
				CALL PrintRecords(from_record,to_record)
			END IF
		ELSE ' to disk
			IF Getob_state(ADD_PLIST)=1 THEN ' print as list
				CALL PrintList2Disk(from_record,to_record)
			ELSE ' normal
				CALL PrintRecords2Disk(from_record,to_record)
			END IF
		END IF
		MOUSE 0
		addprint_handle=0
		commonclose=-1
		Setob_state commonobj,0:Object_Redraw addprint_handle,commonobj
	CASE ADD_PCANCEL
		addprint_handle=0
		commonclose=-1
		Setob_state commonobj,0:Object_Redraw addprint_handle,commonobj
	CASE ADD_PTITLE TO ADD_PEMAIL
		Setob_state ADD_PALLFIELDS,0:Object_Redraw addprint_handle,ADD_PALLFIELDS
	CASE ADD_PALLFIELDS
		FOR i=ADD_PTITLE TO ADD_PEMAIL
			Setob_state i,1:Object_Redraw addprint_handle,i
		NEXT
END SELECT
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB PStatus
STATIC time!,button

MOUSE 2
IF bcostat(0)=0 THEN
	time!=TIMER
	DO
		IF INKEY$=CHR$(27) THEN EXIT SUB
	LOOP UNTIL TIMER-time!>2
	button=form_alert(1,"[1][  Please turn your printer |  ON LINE! ][ Try Again ]")
	CALL PStatus
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB PrintList(from_record,to_record)
STATIC i,PRINT$

FOR i=from_record TO to_record
	CALL PStatus
	IF Getob_state(ADD_PTITLE) THEN PRINT$=TITLE_DATA$(i)
	IF Getob_state(ADD_PCONTACT) THEN PRINT$=PRINT$+","+CONTACT_DATA$(i)
	IF Getob_state(ADD_PFORENAME) THEN PRINT$=PRINT$+","+FORENAME_DATA$(i)
	IF Getob_state(ADD_PSURNAME) THEN PRINT$=PRINT$+","+SURNAME_DATA$(i)
	IF Getob_state(ADD_PADDRESS) THEN 
		PRINT$=PRINT$+","+ADDRESS_DATA$(i)
		PRINT$=PRINT$+","+STREET_DATA$(i)
		PRINT$=PRINT$+","+TOWN_DATA$(i)
		PRINT$=PRINT$+","+COUNTY_DATA$(i)
		PRINT$=PRINT$+","+POSTCODE_DATA$(i)
	END IF
	IF Getob_state(ADD_PHONE) THEN PRINT$=PRINT$+","+PHONE1_DATA$(i):PRINT$=PRINT$+","+PHONE1_DATA$(i)
	IF Getob_state(ADD_PFAX) THEN PRINT$=PRINT$+","+FAX_DATA$(i)
	IF Getob_state(ADD_PEMAIL) THEN PRINT$=PRINT$+","+EMAIL_DATA$(i)
	LPRINT PRINT$
	PRINT$=""
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB PrintRecords(from_record,to_record)
STATIC i

FOR i=from_record TO to_record
	CALL PStatus
	IF Getob_state(ADD_PTITLE) THEN LPRINT TITLE_DATA$(i)
	IF Getob_state(ADD_PCONTACT) THEN LPRINT CONTACT_DATA$(i)
	IF Getob_state(ADD_PFORENAME) THEN LPRINT FORENAME_DATA$(i)
	IF Getob_state(ADD_PSURNAME) THEN LPRINT SURNAME_DATA$(i)
	IF Getob_state(ADD_PADDRESS) THEN 
		LPRINT ADDRESS_DATA$(i)
		LPRINT STREET_DATA$(i)
		LPRINT TOWN_DATA$(i)
		LPRINT COUNTY_DATA$(i)
		LPRINT POSTCODE_DATA$(i)
	END IF
	IF Getob_state(ADD_PHONE) THEN LPRINT PHONE1_DATA$(i):LPRINT PHONE1_DATA$(i)
	IF Getob_state(ADD_PFAX) THEN LPRINT FAX_DATA$(i)
	IF Getob_state(ADD_PEMAIL) THEN LPRINT EMAIL_DATA$(i)
	LPRINT ""
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB PrintList2Disk(from_record,to_record)
STATIC i,PRINT$

OPEN CURDIR$+"\MAILLIST.ASC" FOR OUTPUT AS #1
FOR i=from_record TO to_record
	IF Getob_state(ADD_PTITLE) THEN PRINT$=TITLE_DATA$(i)
	IF Getob_state(ADD_PCONTACT) THEN PRINT$=PRINT$+","+CONTACT_DATA$(i)
	IF Getob_state(ADD_PFORENAME) THEN PRINT$=PRINT$+","+FORENAME_DATA$(i)
	IF Getob_state(ADD_PSURNAME) THEN PRINT$=PRINT$+","+SURNAME_DATA$(i)
	IF Getob_state(ADD_PADDRESS) THEN 
		PRINT$=PRINT$+","+ADDRESS_DATA$(i)
		PRINT$=PRINT$+","+STREET_DATA$(i)
		PRINT$=PRINT$+","+TOWN_DATA$(i)
		PRINT$=PRINT$+","+COUNTY_DATA$(i)
		PRINT$=PRINT$+","+POSTCODE_DATA$(i)
	END IF
	IF Getob_state(ADD_PHONE) THEN PRINT$=PRINT$+","+PHONE1_DATA$(i):PRINT$=PRINT$+","+PHONE1_DATA$(i)
	IF Getob_state(ADD_PFAX) THEN PRINT$=PRINT$+","+FAX_DATA$(i)
	IF Getob_state(ADD_PEMAIL) THEN PRINT$=PRINT$+","+EMAIL_DATA$(i)
	PRINT #1,PRINT$
	PRINT$=""
NEXT
CLOSE #1
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB PrintRecords2Disk(from_record,to_record)
STATIC i

OPEN CURDIR$+"\MAILSHOT.ASC" FOR OUTPUT AS #1
FOR i=from_record TO to_record
	IF Getob_state(ADD_PTITLE) THEN PRINT #1,TITLE_DATA$(i)
	IF Getob_state(ADD_PCONTACT) THEN PRINT #1,CONTACT_DATA$(i)
	IF Getob_state(ADD_PFORENAME) THEN PRINT #1,FORENAME_DATA$(i)
	IF Getob_state(ADD_PSURNAME) THEN PRINT #1,SURNAME_DATA$(i)
	IF Getob_state(ADD_PADDRESS) THEN 
		PRINT #1,ADDRESS_DATA$(i)
		PRINT #1,STREET_DATA$(i)
		PRINT #1,TOWN_DATA$(i)
		PRINT #1,COUNTY_DATA$(i)
		PRINT #1,POSTCODE_DATA$(i)
	END IF
	IF Getob_state(ADD_PHONE) THEN PRINT #1,PHONE1_DATA$(i):PRINT #1,PHONE1_DATA$(i)
	IF Getob_state(ADD_PFAX) THEN PRINT #1,FAX_DATA$(i)
	IF Getob_state(ADD_PEMAIL) THEN PRINT #1,EMAIL_DATA$(i)
	PRINT #1,""
NEXT
CLOSE #1
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_SWITCH
SHARED address_handle
STATIC oldtree&,fieldtype$

oldtree&=tree&
SelectTree ADDRESS_MAIN

Setob_state ADD_SWITCH,0
Setob_state ADD_SWITCH,32
fieldtype$=Gette_ptext$(ADD_POPUP)
SELECT CASE fieldtype$
CASE="Title":Sette_ptext ADD_POPUP,"Contact"
CASE="Contact":Sette_ptext ADD_POPUP,"Forename"
CASE="Forename":Sette_ptext ADD_POPUP,"Surname"
CASE="Surname":Sette_ptext ADD_POPUP,"Address"
CASE="Address":Sette_ptext ADD_POPUP,"Street"
CASE="Street":Sette_ptext ADD_POPUP,"Town"
CASE="Town":Sette_ptext ADD_POPUP,"County"
CASE="County":Sette_ptext ADD_POPUP,"Postcode"
CASE="Postcode":Sette_ptext ADD_POPUP,"Phone"
CASE="Phone":Sette_ptext ADD_POPUP,"Fax"
CASE="Fax":Sette_ptext ADD_POPUP,"Email"
CASE="Email":Sette_ptext ADD_POPUP,"Title"
END SELECT
Object_Redraw address_handle,ADD_POPUP
Object_Redraw address_handle,ADD_SWITCH
tree&=oldtree&
CALL AutoLocate
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_ARROWUP
SHARED total_additems,top_additem,highlight
STATIC oldtree&

oldtree&=tree&
SelectTree ADDRESS_MAIN

DECR top_additem
Exclob_state highlight,mask_selected
INCR highlight
SELECT CASE highlight
	CASE ADD1 TO ADD15:Inclob_state highlight,mask_selected
END SELECT

IF top_additem<0 THEN
	Exclob_state highlight,mask_selected
	DECR highlight
	top_additem=0
	DO
	LOOP UNTIL MOUSE(2)=0
	SELECT CASE highlight
		CASE ADD1 TO ADD15:Inclob_state highlight,mask_selected
	END SELECT
	tree&=oldtree&
ELSE
	tree&=oldtree&
	CALL UPDATE_ADDMAIN
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_ARROWDOWN
SHARED total_additems,top_additem,highlight
STATIC oldtree&

oldtree&=tree&
SelectTree ADDRESS_MAIN

INCR top_additem
Exclob_state highlight,mask_selected
DECR highlight
SELECT CASE highlight
	CASE ADD1 TO ADD15:Inclob_state highlight,mask_selected
END SELECT

IF top_additem>total_additems-15 THEN
	INCR highlight
	top_additem=total_additems-15
	DO
	LOOP UNTIL MOUSE(2)=0
	tree&=oldtree&
ELSE
	tree&=oldtree&
	CALL UPDATE_ADDMAIN
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DIS_ADDDATA
SHARED address_handle,total_additems
STATIC i,record,surname$,forename$,oldtree&

oldtree&=tree&
SelectTree ADDRESS_MAIN

IF total_additems=<0 THEN
	FOR i=ADD1 TO ADD15
		Sette_ptext_update i,"______________________  ______________________",ADDRESS_MAIN
	NEXT
	EXIT SUB
END IF

record=1
FOR i=ADD1 TO ADD15
	forename$=LEFT$(FORENAME_DATA$(record)+"______________________",22)
	surname$=LEFT$(SURNAME_DATA$(record)+"______________________",22)
	Sette_ptext_update i,surname$+"  "+forename$,ADDRESS_MAIN
	IF record=total_additems THEN
		IF record<15 THEN
			FOR i=i+1 TO ADD15
				Sette_ptext_update i,"______________________  ______________________",ADDRESS_MAIN
			NEXT
		END IF
		EXIT FOR
	END IF
	INCR record
NEXT
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_ADDMAIN
SHARED address_handle,total_additems,top_additem
STATIC oldtree&,i,record,surname$,forename$

oldtree&=tree&
SelectTree ADDRESS_MAIN

record=(top_additem+1)
FOR i=ADD1 TO ADD15
	forename$=LEFT$(FORENAME_DATA$(record)+"______________________",22)
	surname$=LEFT$(SURNAME_DATA$(record)+"______________________",22)
	Sette_ptext_update i,surname$+"  "+forename$,ADDRESS_MAIN
	IF record=total_additems THEN
		IF record<15 THEN
			FOR i=i+1 TO ADD15
				Sette_ptext_update i,"______________________  ______________________",ADDRESS_MAIN
			NEXT
		END IF
		EXIT FOR
	END IF
	INCR record
NEXT
Object_Redraw address_handle,ADD_MAINLIST
CALL SCROLL(total_additems,15,top_additem,M_SLIDER,M_BACKGROUND)
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_ADDEDIT(current_record)
SHARED addedit_handle,total_additems
STATIC oldtree&

oldtree&=tree&
SelectTree ADDRESS_EDIT

Sette_ptext ADD_ETITLE,TITLE_DATA$(current_record)
Sette_ptext ADD_EGREETING,CONTACT_DATA$(current_record)
Sette_ptext ADD_EFORENAME,FORENAME_DATA$(current_record)
Sette_ptext ADD_ESURNAME,SURNAME_DATA$(current_record)
Sette_ptext ADD_EADDRESS,ADDRESS_DATA$(current_record)
Sette_ptext ADD_ESTREET,STREET_DATA$(current_record)
Sette_ptext ADD_ETOWN,TOWN_DATA$(current_record)
Sette_ptext ADD_ECOUNTY,COUNTY_DATA$(current_record)
Sette_ptext ADD_EPOSTCODE,POSTCODE_DATA$(current_record)
Sette_ptext ADD_EPHONE1,PHONE1_DATA$(current_record)
Sette_ptext ADD_EPHONE2,PHONE2_DATA$(current_record)
Sette_ptext ADD_EFAX,FAX_DATA$(current_record)
Sette_ptext ADD_EEMAIL,EMAIL_DATA$(current_record)
Sette_ptext ADD_EBIRTHDAY,BIRTHDAY_DATA$(current_record)
Sette_ptext ADD_ENOTES1,NOTES1_DATA$(current_record)
Sette_ptext ADD_ENOTES2,NOTES2_DATA$(current_record)
tree&=oldtree&
CALL SCROLL3(total_additems,5,current_record,ADD_ESLIDER,ADD_EBACK)
CALL RenameWindow(addedit_handle," Edit Record:"+STR$(current_record)+" ")
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_ADDEDIT2(current_record)
SHARED addedit_handle,total_additems
STATIC oldtree&

oldtree&=tree&
SelectTree ADDRESS_EDIT

Sette_ptext ADD_ETITLE,TITLE_DATA$(current_record)
Sette_ptext ADD_EGREETING,CONTACT_DATA$(current_record)
Sette_ptext ADD_EFORENAME,FORENAME_DATA$(current_record)
Sette_ptext ADD_ESURNAME,SURNAME_DATA$(current_record)
Sette_ptext ADD_EADDRESS,ADDRESS_DATA$(current_record)
Sette_ptext ADD_ESTREET,STREET_DATA$(current_record)
Sette_ptext ADD_ETOWN,TOWN_DATA$(current_record)
Sette_ptext ADD_ECOUNTY,COUNTY_DATA$(current_record)
Sette_ptext ADD_EPOSTCODE,POSTCODE_DATA$(current_record)
Sette_ptext ADD_EPHONE1,PHONE1_DATA$(current_record)
Sette_ptext ADD_EPHONE2,PHONE2_DATA$(current_record)
Sette_ptext ADD_EFAX,FAX_DATA$(current_record)
Sette_ptext ADD_EEMAIL,EMAIL_DATA$(current_record)
Sette_ptext ADD_EBIRTHDAY,BIRTHDAY_DATA$(current_record)
Sette_ptext ADD_ENOTES1,NOTES1_DATA$(current_record)
Sette_ptext ADD_ENOTES2,NOTES2_DATA$(current_record)
tree&=oldtree&
CALL SCROLL4(total_additems,5,current_record,ADD_ESLIDER,ADD_EBACK)
CALL RenameWindow(addedit_handle," Edit Record:"+STR$(current_record)+" ")
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB edit_addressdialog
SHARED commonclose,commonobj,addedit_handle,address_handle,current_record
SHARED total_additems,EDIT_CHANGE
STATIC oldtree&

oldtree&=tree&
SelectTree ADDRESS_EDIT

commonclose=0										
SELECT CASE commonobj
	CASE ADD_ECANCEL
		addedit_handle=0
		commonclose=-1
	CASE ELSE
		IF EDIT_CHANGE=-1 THEN
		MOUSE 2
		TITLE_DATA$(current_record)=Gette_ptext$(ADD_ETITLE)
		CONTACT_DATA$(current_record)=Gette_ptext$(ADD_EGREETING)
		FORENAME_DATA$(current_record)=Gette_ptext$(ADD_EFORENAME)
		SURNAME_DATA$(current_record)=Gette_ptext$(ADD_ESURNAME)
		ADDRESS_DATA$(current_record)=Gette_ptext$(ADD_EADDRESS)
		STREET_DATA$(current_record)=Gette_ptext$(ADD_ESTREET)
		TOWN_DATA$(current_record)=Gette_ptext$(ADD_ETOWN)
		COUNTY_DATA$(current_record)=Gette_ptext$(ADD_ECOUNTY)
		POSTCODE_DATA$(current_record)=Gette_ptext$(ADD_EPOSTCODE)
		PHONE1_DATA$(current_record)=Gette_ptext$(ADD_EPHONE1)
		PHONE2_DATA$(current_record)=Gette_ptext$(ADD_EPHONE2)
		FAX_DATA$(current_record)=Gette_ptext$(ADD_EFAX)
		EMAIL_DATA$(current_record)=Gette_ptext$(ADD_EEMAIL)
		BIRTHDAY_DATA$(current_record)=Gette_ptext$(ADD_EBIRTHDAY)
		NOTES1_DATA$(current_record)=Gette_ptext$(ADD_ENOTES1)
		NOTES2_DATA$(current_record)=Gette_ptext$(ADD_ENOTES2)
		tree&=oldtree&
		CALL dis_adddata
		Object_Redraw address_handle,ADD_MAINLIST
		oldtree&=tree&
		SelectTree ADDRESS_MAIN
		CALL SCROLL2(total_additems,15,M_SLIDER,M_BACKGROUND)
		Object_Redraw address_handle,M_BACKGROUND
		tree&=oldtree&
		CALL AutoLocate
		MOUSE 0
		EDIT_CHANGE=0
		END IF

		oldtree&=tree&
		SelectTree ADDRESS_EDIT
		SELECT CASE commonobj
			CASE ADD_EOK
				addedit_handle=0
				commonclose=-1
			CASE ADD_EUP
				CALL ADDRESS_EUP
			CASE ADD_EDOWN
				CALL ADDRESS_EDOWN
		END SELECT
END SELECT
Setob_state commonobj,0:Object_Redraw addedit_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_EUP
SHARED addedit_handle,current_record

DECR current_record
IF current_record<1 THEN
	current_record=1
	DO
	LOOP UNTIL MOUSE(2)=0
ELSE
	CALL UPDATE_ADDEDIT(current_record)
	Object_Redraw addedit_handle,ADDRESS_EBACK
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_EDOWN
SHARED total_additems,current_record,addedit_handle

INCR current_record
IF current_record>total_additems THEN
	current_record=total_additems
	DO
	LOOP UNTIL MOUSE(2)=0
ELSE
	CALL UPDATE_ADDEDIT(current_record)
	Object_Redraw addedit_handle,ADDRESS_EBACK
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB AUTOLOCATE
SHARED total_additems,top_additem,address_handle,highlight
STATIC i,locate$,fieldtype$,match$,chighlight
STATIC oldtree&

IF total_additems=0 THEN EXIT SUB
oldtree&=tree&
SelectTree ADDRESS_MAIN

chighlight=highlight
locate$=Gette_ptext$(ADD_AUTOLOCATE)
Exclob_state highlight,mask_selected

IF locate$<>"" THEN
fieldtype$=Gette_ptext$(ADD_POPUP)
LOCATE_AGAIN:
FOR i=1 TO total_additems
	SELECT CASE fieldtype$
		CASE="Title":match$=TITLE_DATA$(i)
		CASE="Contact":match$=CONTACT_DATA$(i)
		CASE="Forename":match$=FORENAME_DATA$(i)
		CASE="Surname":match$=SURNAME_DATA$(i)
		CASE="Address":match$=ADDRESS_DATA$(i)
		CASE="Street":match$=STREET_DATA$(i)
		CASE="Town":match$=TOWN_DATA$(i)
		CASE="County":match$=COUNTY_DATA$(i)
		CASE="Postcode":match$=POSTCODE_DATA$(i)
		CASE="Phone":match$=PHONE1_DATA$(i)
		CASE="Phone2":match$=PHONE2_DATA$(i)
		CASE="Fax":match$=FAX_DATA$(i)
		CASE="Email":match$=EMAIL_DATA$(i)
	END SELECT

	IF INSTR(UCASE$(match$),UCASE$(locate$)) THEN
		top_additem=(i-1)
		IF total_additems<15 THEN
			top_additem=0
			highlight=(ADD1+i)-1
		ELSE
			highlight=ADD1
			IF (top_additem+15)>total_additems THEN
				highlight=(ADD15-(total_additems-top_additem))+1
				top_additem=total_additems-15
			END IF
		END IF
		Inclob_state highlight,mask_selected
		tree&=oldtree&
		IF highlight<>chighlight THEN CALL UPDATE_ADDMAIN
		EXIT SUB
	END IF
NEXT
IF fieldtype$="Phone" THEN fieldtype$="Phone2":GOTO LOCATE_AGAIN
END IF
Object_Redraw address_handle,ADD_MAINLIST
top_additem=0
highlight=ADD1-1000
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ADDRESS_SORT
SHARED total_additems,highlight
STATIC oldtree&,sort$,fieldtype$,match$,i,k
STATIC title$,contact$,forename$,surname$,address$,street$,town$,county$
STATIC postcode$,phone1$,phone2$,fax$,email$,birthday$,notes1$,notes2$

IF total_additems=0 THEN EXIT SUB
oldtree&=tree&
SelectTree ADDRESS_MAIN

fieldtype$=Gette_ptext$(ADD_POPUP)
MOUSE 2
FOR i=1 TO total_additems
	title$=TITLE_DATA$(i)
	contact$=CONTACT_DATA$(i)
	forename$=FORENAME_DATA$(i)
	surname$=SURNAME_DATA$(i)
	address$=ADDRESS_DATA$(i)
	street$=STREET_DATA$(i)
	town$=TOWN_DATA$(i)
	county$=COUNTY_DATA$(i)
	postcode$=POSTCODE_DATA$(i)
	phone1$=PHONE1_DATA$(i)
	phone2$=PHONE2_DATA$(i)
	fax$=FAX_DATA$(i)
	email$=EMAIL_DATA$(i)
	birthday$=BIRTHDAY_DATA$(i)
	notes1$=NOTES1_DATA$(i)
	notes2$=NOTES2_DATA$(i)

	SELECT CASE fieldtype$
		CASE="Title":sort$=title$
		CASE="Contact":sort$=contact$
		CASE="Forename":sort$=forename$+surname$
		CASE="Surname":sort$=surname$+forename$
		CASE="Address":sort$=address$
		CASE="Street":sort$=street$
		CASE="Town":sort$=town$
		CASE="County":sort$=county$
		CASE="Postcode":sort$=postcode$
		CASE="Phone":sort$=phone1$+phone2$
		CASE="Fax":sort$=fax$
		CASE="Email":sort$=email$
	END SELECT

	FOR k=i-1 TO 1 STEP -1
	SELECT CASE fieldtype$
		CASE="Title":match$=TITLE_DATA$(k)
		CASE="Contact":match$=CONTACT_DATA$(k)
		CASE="Forename":match$=FORENAME_DATA$(k)+SURNAME_DATA$(k)
		CASE="Surname":match$=SURNAME_DATA$(k)+FORENAME_DATA$(k)
		CASE="Address":match$=ADDRESS_DATA$(k)
		CASE="Street":match$=STREET_DATA$(k)
		CASE="Town":match$=TOWN_DATA$(k)
		CASE="County":match$=COUNTY_DATA$(k)
		CASE="Postcode":match$=POSTCODE_DATA$(k)
		CASE="Phone":match$=PHONE1_DATA$(k)+PHONE2_DATA$(k)
		CASE="Fax":match$=FAX_DATA$(k)
		CASE="Email":match$=EMAIL_DATA$(k)
	END SELECT

	IF UCASE$(match$)<UCASE$(sort$) THEN EXIT FOR
		TITLE_DATA$(k+1)=TITLE_DATA$(k)
		CONTACT_DATA$(k+1)=CONTACT_DATA$(k)
		FORENAME_DATA$(k+1)=FORENAME_DATA$(k)
		SURNAME_DATA$(k+1)=SURNAME_DATA$(k)
		ADDRESS_DATA$(k+1)=ADDRESS_DATA$(k)
		STREET_DATA$(k+1)=STREET_DATA$(k)
		TOWN_DATA$(k+1)=TOWN_DATA$(k)
		COUNTY_DATA$(k+1)=COUNTY_DATA$(k)
		POSTCODE_DATA$(k+1)=POSTCODE_DATA$(k)
		PHONE1_DATA$(k+1)=PHONE1_DATA$(k)
		PHONE2_DATA$(k+1)=PHONE2_DATA$(k)
		FAX_DATA$(k+1)=FAX_DATA$(k)
		EMAIL_DATA$(k+1)=EMAIL_DATA$(k)
		BIRTHDAY_DATA$(k+1)=BIRTHDAY_DATA$(k)
		NOTES1_DATA$(k+1)=NOTES1_DATA$(k)
		NOTES2_DATA$(k+1)=NOTES2_DATA$(k)
	NEXT
	TITLE_DATA$(k+1)=title$
	CONTACT_DATA$(k+1)=contact$
	FORENAME_DATA$(k+1)=forename$
	SURNAME_DATA$(k+1)=surname$
	ADDRESS_DATA$(k+1)=address$
	STREET_DATA$(k+1)=street$
	TOWN_DATA$(k+1)=town$
	COUNTY_DATA$(k+1)=county$
	POSTCODE_DATA$(k+1)=postcode$
	PHONE1_DATA$(k+1)=phone1$
	PHONE2_DATA$(k+1)=phone2$
	FAX_DATA$(k+1)=fax$
	EMAIL_DATA$(k+1)=email$
	BIRTHDAY_DATA$(k+1)=birthday$
	NOTES1_DATA$(k+1)=notes1$
	NOTES2_DATA$(k+1)=notes2$
NEXT
MOUSE 0
tree&=oldtree&
IF highlight=<15 THEN 
	CALL UPDATE_ADDMAIN
ELSE
	CALL autolocate
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_calcdialog
SHARED commonclose,commonobj,calc_handle
SHARED dec_exists,Digits,Multi_Already,Memory$,Memory
STATIC oldtree&

oldtree&=tree&
SelectTree CALCULATOR
commonclose=0										
SELECT CASE commonobj
	CASE CALC_AC
		dec_exists=0
		Digits=0
		Multi_Already=0
		Sette_ptext CALC_Answer1,""
		Sette_ptext CALC_Answer2,""
		Sette_ptext Choice,""
		Object_Redraw calc_handle,CALC_Answer1
		Object_Redraw calc_handle,CALC_Answer2
		Object_Redraw calc_handle,Choice
	CASE CALC_C
		dec_exists=0
		Digits=0
		Sette_ptext CALC_Answer2,""
		Object_Redraw calc_handle,CALC_Answer2
	CASE CALC_MPLUS
		IF NOT Gette_ptext$(CALC_Answer2)="" THEN
			Memory=-1
			Memory$=Gette_ptext$(CALC_Answer2)
		END IF
	CASE CALC_MR
		IF Memory THEN
			Sette_ptext CALC_Answer2,Memory$
			Object_Redraw calc_handle,CALC_Answer2
		END IF
	CASE CALC_PORM
		IF Gette_ptext$(CALC_Answer2)="" THEN
			Sette_ptext CALC_Answer1,STR$(VAL(Gette_ptext$(CALC_Answer1))-(2*VAL(Gette_ptext$(CALC_Answer1))))
			Object_Redraw calc_handle,CALC_Answer1
		ELSE
			Sette_ptext CALC_Answer2,STR$(VAL(Gette_ptext$(CALC_Answer2))-(2*VAL(Gette_ptext$(CALC_Answer2))))
			Object_Redraw calc_handle,CALC_Answer2
		END IF
	CASE CALC_Zero:CALL Display("0")
	CASE CALC_Points
		INCR Digits
		IF Digits>10 THEN Digits=10:EXIT SELECT
		IF dec_exists=0 THEN
			dec_exists=-1
			Sette_ptext CALC_Answer2,Gette_ptext$(CALC_Answer2)+"."
			Object_Redraw calc_handle,CALC_Answer2
		END IF
	CASE CALC_One:CALL Display("1")
	CASE CALC_Two:CALL Display("2")
	CASE CALC_Three:CALL Display("3")
	CASE CALC_Four:CALL Display("4")
	CASE CALC_Five:CALL Display("5")
	CASE CALC_Six:CALL Display("6")
	CASE CALC_Seven:CALL Display("7")
	CASE CALC_Eight:CALL Display("8")
	CASE CALC_Nine:CALL Display("9")
	CASE CALC_Divide:CALL Multiply(CHR$(246))
	CASE CALC_Multiply:CALL Multiply("X")
	CASE CALC_Minus:CALL Multiply("-")
	CASE CALC_Plus:CALL Multiply("+")
	CASE CALC_Equals:CALL WorkOUT("=")
	CASE CALC_QUIT
		calc_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0
Object_Redraw calc_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Display(ascii$)
SHARED calc_handle,Digits
STATIC oldtree&

oldtree&=tree&
SelectTree CALCULATOR
INCR Digits
IF Digits>10 THEN Digits=10:EXIT SUB
Sette_ptext CALC_Answer2,Gette_ptext$(CALC_Answer2)+ascii$
Object_Redraw calc_handle,CALC_Answer2
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Multiply(type$)
SHARED calc_handle,dec_exists,Multi_Already,Digits
STATIC oldtree&

oldtree&=tree&
SelectTree CALCULATOR

IF Gette_ptext$(CALC_Answer2)="" THEN 
	Multi_Already=-1
	Sette_ptext Choice,type$
	Object_Redraw calc_handle,Choice
END IF

IF Multi_Already THEN CALL WorkOUT(type$):EXIT SUB
dec_exists=0
Digits=0
Multi_Already=-1
Sette_ptext CALC_Answer1,Gette_ptext$(CALC_Answer2)
Sette_ptext CALC_Answer2,""
Sette_ptext Choice,type$
Object_Redraw calc_handle,CALC_Answer1
Object_Redraw calc_handle,CALC_Answer2
Object_Redraw calc_handle,Choice
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB WorkOUT(Choice$)
SHARED calc_handle,dec_exists,Multi_Already,Digits
STATIC Chose$,answer!,oldtree&

oldtree&=tree&
SelectTree CALCULATOR

IF Gette_ptext$(CALC_Answer2)="" THEN EXIT SUB

Chose$=Gette_ptext$(Choice)
SELECT CASE Chose$
	CASE==CHR$(246)
		answer!=VAL(Gette_ptext$(CALC_Answer1))/VAL(Gette_ptext$(CALC_Answer2)) 
	CASE=="X"
		answer!=VAL(Gette_ptext$(CALC_Answer1))*VAL(Gette_ptext$(CALC_Answer2)) 
	CASE=="-"
		answer!=VAL(Gette_ptext$(CALC_Answer1))-VAL(Gette_ptext$(CALC_Answer2)) 
	CASE=="+"
		answer!=VAL(Gette_ptext$(CALC_Answer1))+VAL(Gette_ptext$(CALC_Answer2)) 
	CASE=="="
		EXIT SUB
END SELECT

dec_exists=0
Digits=0
Multi_Already=0
Sette_ptext CALC_Answer1,STR$(answer!)
Sette_ptext CALC_Answer2,""
Sette_ptext Choice,Choice$
Object_Redraw calc_handle,CALC_Answer1
Object_Redraw calc_handle,CALC_Answer2
Object_Redraw calc_handle,Choice
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB keyboard_calc(KEY$)
SHARED calc_handle,dec_exists,Digits,Multi_Already
STATIC commonobj,oldtree&

oldtree&=tree&
SelectTree CALCULATOR

SELECT CASE KEY$
	CASE="1"
		commonobj=CALC_One
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("1")
	CASE="2"
		commonobj=CALC_Two
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("2")
	CASE="3"
		commonobj=CALC_Three
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("3")
	CASE="4"
		commonobj=CALC_Four
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("4")
	CASE="5"
		commonobj=CALC_Five
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("5")
	CASE="6"
		commonobj=CALC_Six
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("6")
	CASE="7"
		commonobj=CALC_Seven
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("7")
	CASE="8"
		commonobj=CALC_Eight
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("8")
	CASE="9"
		commonobj=CALC_Nine
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("9")
	CASE="0"
		commonobj=CALC_Zero
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Display("0")
	CASE="."
		commonobj=CALC_Points
		INCR Digits
		IF Digits>10 THEN Digits=10:EXIT SELECT
		IF dec_exists=0 THEN
			dec_exists=-1
			Sette_ptext CALC_Answer2,Gette_ptext$(CALC_Answer2)+"."
			Object_Redraw calc_handle,CALC_Answer2
		END IF
	CASE="/"
		commonobj=CALC_Divide
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Multiply(CHR$(246))
	CASE="*"
		commonobj=CALC_Multiply
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Multiply("X")
	CASE="-"
		commonobj=CALC_Minus
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Multiply("-")
	CASE="+"
		commonobj=CALC_Plus
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL Multiply("+")
	CASE="="
		commonobj=CALC_Equals
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL WorkOUT("=")
	CASE=CHR$(8)
		DECR Digits
		IF Digits<0 THEN Digits=0:EXIT SUB
		Sette_ptext CALC_Answer2,LEFT$(Gette_ptext$(CALC_Answer2),LEN(Gette_ptext$(CALC_Answer2))-1)
		Object_Redraw calc_handle,CALC_Answer2
		EXIT SUB
	CASE=CHR$(13)
		commonobj=CALC_Equals
		setob_state commonobj,1
		Object_Redraw calc_handle,commonobj
		CALL WorkOUT("=")
	CASE ELSE
		EXIT SUB
END SELECT
setob_state commonobj,0
Object_Redraw calc_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_clockdialog
SHARED commonclose,commonobj,clock_handle,alarm_handle
STATIC x,y,res,res$
STATIC oldtree&

oldtree&=tree&
SelectTree ALARM_CLOCK

commonclose=0										
SELECT CASE commonobj
	CASE=A_Day
		res=0
		junk=objc_offset(tree&,A_Day,x,y)
		res=popup(0,Day,res,x,y)
		IF res THEN
			res$=get_pop_string$(Day,res)
			sette_ptext A_Day,res$
		END IF
	CASE=A_Month
		res=0
		junk=objc_offset(tree&,A_Month,x,y)
		res=popup(0,Month,res,x,y)
		IF res THEN
			res$=get_pop_string$(Month,res)
			sette_ptext A_Month,res$
			CALL LeapYear
		END IF
	CASE=A_Year
		res=0
		junk=objc_offset(tree&,A_Year,x,y)
		res=popup(0,Year,res,x,y)
		IF res THEN
			res$=get_pop_string$(Year,res)
			sette_ptext A_Year,res$
			CALL LeapYear
		END IF
	CASE A_OK
		clock_handle=0
		commonclose=-1
		CALL setclock
	CASE=A_Cancel
		commonclose=-1
		clock_handle=0
	CASE=A_Alarm
		Object_Redraw clock_handle,commonobj
		IF alarm_handle THEN
			TopAWindow alarm_handle
		ELSE
			alarm_handle=openformwindow(" AutoClock: Alarm ",&h0B,ALARM,A_BeAlarmed,A_ALARMOK,VARPTRS(close_alarmdialog))
		END IF
END SELECT
IF NOT COMMONOBJ=A_ALARM THEN IF commonclose=0 THEN Object_Redraw clock_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Initialise_Clok
SHARED clock_handle
STATIC month$,oldtree&,year$

oldtree&=tree&
SelectTree ALARM_CLOCK

Sette_ptext A_TIME,LEFT$(TIME$,2)+MID$(TIME$,4,2)
Sette_ptext A_DAY,MID$(DATE$,4,2)
month$=LEFT$(DATE$,2)
SELECT CASE month$
	CASE=="01":Sette_ptext A_Month,"January":Month$="January"
	CASE=="02":Sette_ptext A_Month,"Febuary":Month$="Febuary"
	CASE=="03":Sette_ptext A_Month,"March":Month$="March"
	CASE=="04":Sette_ptext A_Month,"April":Month$="April"
	CASE=="05":Sette_ptext A_Month,"May":Month$="May"
	CASE=="06":Sette_ptext A_Month,"June":Month$="June"
	CASE=="07":Sette_ptext A_Month,"July":Month$="July"
	CASE=="08":Sette_ptext A_Month,"August":Month$="August"
	CASE=="09":Sette_ptext A_Month,"September":Month$="September"
	CASE=="10":Sette_ptext A_Month,"October":Month$="October"
	CASE=="11":Sette_ptext A_Month,"November":Month$="November"
	CASE=="12":Sette_ptext A_Month,"December":Month$="December"
END SELECT
Sette_ptext A_Year,RIGHT$(DATE$,4)
IF Gette_ptext$(A_Day)="00" THEN Sette_ptext A_Day,"01"
IF Gette_ptext$(A_year)="20<8" THEN Sette_ptext A_Year,"1997"
year$=Gette_ptext$(A_year)
CALL LEAPYEAR

SelectTree DIARY_PAGE
Sette_ptext D_DATE,MID$(DATE$,4,2)
Sette_ptext D_MONTH,Month$
Sette_ptext D_YEAR,Year$
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SetClock
SHARED clock_handle
STATIC month$,oldtree&

oldtree&=tree&
SelectTree ALARM_CLOCK

IF NOT Gette_ptext$(A_time)="" THEN
	IF VAL(LEFT$(Gette_ptext$(A_time),2))>23 THEN Sette_ptext A_time,"00"+RIGHT$(Gette_ptext$(A_time),2)
	IF VAL(RIGHT$(Gette_ptext$(A_time),2))>59 THEN Sette_ptext A_time,"0000"
	TIME$=LEFT$(Gette_ptext$(A_time),2)+":"+RIGHT$(Gette_ptext$(A_time),2)+":"+"00"
END IF

month$=LEFT$(Gette_ptext$(A_month),3)
SELECT CASE month$
	CASE=="Jan":MONTH$="01"
	CASE=="Feb":MONTH$="02"
	CASE=="Mar":MONTH$="03"
	CASE=="Apr":MONTH$="04"
	CASE=="May":MONTH$="05"
	CASE=="Jun":MONTH$="06"
	CASE=="Jul":MONTH$="07"
	CASE=="Aug":MONTH$="08"
	CASE=="Sep":MONTH$="09"
	CASE=="Oct":MONTH$="10"
	CASE=="Nov":MONTH$="11"
	CASE=="Dec":MONTH$="12"
END SELECT
IF Gette_ptext$(A_day)="00" THEN junk=form_alert(1,"[1][  Error - Invalid date. | ][ Abort ]"):setob_state A_ok,0:Object_Redraw clock_handle,A_ok:GOTO retry
IF Gette_ptext$(A_year)="20<8" THEN junk=form_alert(1,"[1][  Error - Invalid date. | ][ Abort ]"):setob_state A_ok,0:Object_Redraw clock_handle,A_ok:GOTO retry
DATE$=MONTH$+"/"+Gette_ptext$(A_day)+"/"+Gette_ptext$(A_year)
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LeapYear
STATIC i,month$,year$,oldtree&

oldtree&=tree&
SelectTree ALARM_CLOCK

month$=LEFT$(Gette_ptext$(A_month),3)
year$=Gette_ptext$(A_year)

SelectTree Day
FOR i=D_D1 TO D_D31
	Setob_state i,0
NEXT

SELECT CASE month$
	CASE=="Feb"
		Setob_state D_D30,8:Setob_state D_D31,8
		IF NOT VAL(year$) MOD 4=0 THEN Setob_state D_D29,8
	CASE=="Apr":Setob_state D_D31,8
	CASE=="Jun":Setob_state D_D31,8
	CASE=="Sep":Setob_state D_D31,8
	CASE=="Nov":Setob_state D_D31,8
END SELECT
SelectTree ALARM_CLOCK
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_alarmdialog
SHARED commonclose,commonobj,alarm_handle,alarm_active,alarm$
STATIC x,y,res,res$,oldtree&

oldtree&=tree&
SelectTree ALARM

commonclose=0										
SELECT CASE commonobj
	CASE ALARMSTATUS
		res=0
		junk=objc_offset(tree&,ALARMSTATUS,x,y)
		res=popup(0,ALARM_STATUS,res,x,y)
		IF res THEN
			res$=get_pop_alarm$(ALARM_STATUS,res)
			sette_ptext ALARMSTATUS,res$
		END IF
		Object_Redraw alarm_handle,commonobj
	CASE A_ALARMOK
		IF res$="On" THEN alarm_active=-1
		IF res$="Off" THEN alarm_active=0
		alarm$=LEFT$(Gette_ptext$(A_BeAlarmed),2)+":"+RIGHT$(Gette_ptext$(A_BeAlarmed),2)
		ALARM_DATA$(0)=Gette_ptext$(A_Mes1)
		ALARM_DATA$(1)=Gette_ptext$(A_Mes2)
		ALARM_DATA$(2)=Gette_ptext$(A_Mes3)
		ALARM_DATA$(3)=Gette_ptext$(A_Mes4)
		ALARM_DATA$(4)=Gette_ptext$(A_Mes5)
		ALARM_DATA$(5)=Gette_ptext$(A_Mes6)
		alarm_handle=0
		commonclose=-1
END SELECT
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_notesdialog
SHARED commonclose,commonobj,notes_handle

commonclose=0										
SELECT CASE commonobj
	CASE NOTES_QUIT
		notes_handle=0
		commonclose=-1
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB processusermenus(VAL topwin,VAL item,VAL title)
SHARED commonclose,commonobj,menutree&
SHARED about_handle,address_handle,diary_handle,calc_handle,clock_handle
SHARED notes_handle,dsum_handle,total_additems,top_additem,dpage_handle
SHARED birthday_handle,total_additems,EDITD_CHANGE
STATIC oldtree&,i,line$,Month$

IF EDITD_CHANGE=-1 THEN
	oldtree&=tree&
	MOUSE 2
	SelectTree DIARY_PAGE
	line$=Gette_ptext$(D1)
	FOR i=D2 TO D16
	line$=line$+CHR$(0)+Gette_ptext$(i)
	NEXT
	i=VAL(Gette_ptext$(D_Date))
	Month$=LEFT$(Gette_ptext$(D_MONTH),3)
	SELECT CASE Month$
	CASE=="Jan":January$(i)=line$
	CASE=="Feb":Febuary$(i)=line$
	CASE=="Mar":March$(i)=line$
	CASE=="Apr":April$(i)=line$
	CASE=="May":May$(i)=line$
	CASE=="Jun":June$(i)=line$
	CASE=="Jul":July$(i)=line$
	CASE=="Aug":August$(i)=line$
	CASE=="Sep":September$(i)=line$
	CASE=="Oct":October$(i)=line$
	CASE=="Nov":November$(i)=line$
	CASE=="Dec":December$(i)=line$
	END SELECT
	MOUSE 0
	tree&=oldtree&
END IF

commonclose=0										
SELECT CASE item
	CASE MENU_ABOUT
		IF about_handle THEN
			TopAWindow about_handle
		ELSE
			about_handle=openformwindow(" About... ",&h0B,FORM_ABOUT,0,ABOUT_OK,VARPTRS(close_aboutdialog))
		END IF
	CASE MENU_ADDBOOK
		IF address_handle THEN
			TopAWindow address_handle
		ELSE
			address_handle=openformwindow(" Cadenza Address Book ",&h0B,ADDRESS_MAIN,ADD_AUTOLOCATE,ADD_QUIT,VARPTRS(close_addressdialog))
			CALL dis_adddata
			oldtree&=tree&
			SelectTree ADDRESS_MAIN
			CALL SCROLL2(total_additems,15,M_SLIDER,M_BACKGROUND)
			tree&=oldtree&
		END IF
	CASE MENU_DIARY
		IF dpage_handle THEN
			TopAWindow dpage_handle
		ELSE
			dpage_handle=openformwindow(" Diary: Entry ",&h0B,DIARY_PAGE,D1,DIARY_QUIT,VARPTRS(close_pagedialog))
		END IF
		IF diary_handle THEN
			TopAWindow diary_handle
		ELSE
			diary_handle=openformwindow(" Diary: Toolbox ",&h0B,D_TOOLBOX,0,D_QUIT,VARPTRS(close_diarydialog))
		END IF
	CASE MENU_CALC
		IF calc_handle THEN
			TopAWindow calc_handle
		ELSE
			calc_handle=openformwindow(" Calc IT ",&h0B,CALCULATOR,0,CALC_QUIT,VARPTRS(close_calcdialog))
		END IF
	CASE MENU_CLOCK
		CALL INITIALISE_CLOK
		IF clock_handle THEN
			TopAWindow clock_handle
		ELSE
			clock_handle=openformwindow(" AutoClock'97 ",&h0B,ALARM_CLOCK,A_TIME,A_CANCEL,VARPTRS(close_clockdialog))
		END IF
	CASE MENU_NOTEPAD
		IF notes_handle THEN
			TopAWindow notes_handle
		ELSE
			notes_handle=openformwindow(" NotePad ",&h0B,NOTEPAD,N1,NOTES_QUIT,VARPTRS(close_notesdialog))
		END IF
	CASE MENU_QUIT
		CALL QUIT_ME
	CASE MENU_TDIARY
		CALL Initialise_Clok
		CALL UPDATE_DPAGE
		IF diary_handle THEN
			TopAWindow diary_handle
		ELSE
			diary_handle=openformwindow(" Diary: Toolbox ",&h0B,D_TOOLBOX,0,D_QUIT,VARPTRS(close_diarydialog))
		END IF
		IF dpage_handle THEN
			Object_Redraw dpage_handle,D_DATE
			Object_Redraw dpage_handle,D_MONTH
			Object_Redraw dpage_handle,D_YEAR
			TopAWindow dpage_handle
		ELSE
			dpage_handle=openformwindow(" Diary: Entry ",&h0B,DIARY_PAGE,D1,DIARY_QUIT,VARPTRS(close_pagedialog))
		END IF
	CASE MENU_TBIRTH
		IF TOTAL_ADDITEMS=0 THEN CALL BIRTHDAY_LOAD
		CALL update_birthday
		IF birthday_handle THEN
			TopAWindow birthday_handle
		ELSE
			birthday_handle=openformwindow(" Today's Birthdays ",&h0B,BIRTHDAY,0,BIRTH_QUIT,VARPTRS(close_birthdaydialog))
		END IF
	CASE MENU_TSUM
		CALL SETSUMMARY
		IF dsum_handle THEN
			TopAWindow dsum_handle
		ELSE
			dsum_handle=openformwindow(" Summary ",&h0B,DIARY_SUMMARY,0,D_SQUIT,VARPTRS(close_summarydialog))
		END IF
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB QUIT_ME
SHARED finished_flag,commonclose
STATIC button

MOUSE 2
button=form_alert(2,"[2][  Do you really want to quit ? |  All unsaved data will be |  lost! ][ Continue | Cancel ]")
SELECT CASE button
	CASE 1
		commonclose=-1
		finished_flag=-1
END SELECT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_diarydialog
SHARED commonclose,commonobj,diary_handle,dpage_handle,dsearch_handle
SHARED dschedule_handle,dprint_handle,EDITD_CHANGE
STATIC oldtree&,button,Month$,i,line$

oldtree&=tree&
IF EDITD_CHANGE=-1 THEN
	MOUSE 2
	SelectTree DIARY_PAGE
	line$=Gette_ptext$(D1)
	FOR i=D2 TO D16
		line$=line$+CHR$(0)+Gette_ptext$(i)
	NEXT
	i=VAL(Gette_ptext$(D_Date))
	Month$=LEFT$(Gette_ptext$(D_MONTH),3)
	SELECT CASE Month$
	CASE=="Jan":January$(i)=line$
	CASE=="Feb":Febuary$(i)=line$
	CASE=="Mar":March$(i)=line$
	CASE=="Apr":April$(i)=line$
	CASE=="May":May$(i)=line$
	CASE=="Jun":June$(i)=line$
	CASE=="Jul":July$(i)=line$
	CASE=="Aug":August$(i)=line$
	CASE=="Sep":September$(i)=line$
	CASE=="Oct":October$(i)=line$
	CASE=="Nov":November$(i)=line$
	CASE=="Dec":December$(i)=line$
	END SELECT
	MOUSE 0
END IF

SelectTree D_TOOLBOX

commonclose=0										
SELECT CASE commonobj
	CASE D_NEW
		MOUSE 2
		button=form_alert(2,"[2][  Diary: |  Do you really want to lose |  all unsaved data? ][ Continue | Cancel ]")
		SELECT CASE button
		CASE 1
	 		REDIM JANUARY$(32)
			REDIM FEBUARY$(32)
			REDIM MARCH$(32)
			REDIM APRIL$(32)
			REDIM MAY$(32)
			REDIM JUNE$(32)
			REDIM JULY$(32)
			REDIM AUGUST$(32)
			REDIM SEPTEMBER$(32)
			REDIM OCTOBER$(32)
			REDIM NOVEMBER$(32)
			REDIM DECEMBER$(32)
		END SELECT
		IF dpage_handle THEN CALL UPDATE_DPAGE
		MOUSE 0
	CASE D_LOAD
		MOUSE 2
		button=form_alert(2,"[2][  Diary: |  Do you really want to lose |  all unsaved data? ][ Continue | Cancel ]")
		SELECT CASE button
		CASE 1
			CALL DIARY_LOAD
		END SELECT
		MOUSE 0
	CASE D_SAVE
		CALL DIARY_SAVE
	CASE D_EDIT
		Setob_state commonobj,0:Object_Redraw diary_handle,commonobj
		IF dpage_handle THEN
			TopAWindow dpage_handle
		ELSE
			dpage_handle=openformwindow(" Diary: Entry ",&h0B,DIARY_PAGE,D1,DIARY_QUIT,VARPTRS(close_pagedialog))
		END IF
		EXIT SUB
	CASE D_DELETE
		button=form_alert(2,"[2][  Diary: |  Do you really want to lose |  Diary Entry? ][  Yes  |  No  ]")
		SELECT CASE button
		CASE 1
			CALL DIARY_DELETE
		END SELECT
	CASE D_SEARCH
		Setob_state commonobj,0:Object_Redraw diary_handle,commonobj
		SelectTree DIARY_SEARCH
		Setob_state D_SSEARCH,0
		IF dsearch_handle THEN
			TopAWindow dsearch_handle
		ELSE
			dsearch_handle=openformwindow(" Diary: Search ",&h0B,DIARY_SEARCH,D_SSEARCH,D_SCANCEL,VARPTRS(close_searchdialog))
		END IF
		EXIT SUB
	CASE D_RESCHEDULE
		Setob_state commonobj,0:Object_Redraw diary_handle,commonobj
		IF dschedule_handle THEN
			TopAWindow dschedule_handle
		ELSE
			dschedule_handle=openformwindow(" Diary: Entry ",&h0B,DIARY_SCHEDULE,0,D_RCANCEL,VARPTRS(close_scheduledialog))
		END IF
		EXIT SUB
	CASE D_PRINT
		Setob_state commonobj,0:Object_Redraw diary_handle,commonobj
		IF dprint_handle THEN
			TopAWindow dprint_handle
		ELSE
			dprint_handle=openformwindow(" Diary: Print ",&h0B,DIARY_PRINT,0,D_PCANCEL,VARPTRS(close_printdialog))
		END IF
		EXIT SUB
	CASE D_QUIT
		diary_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw diary_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DIARY_LOAD
SHARED dpage_handle,Loaded_Path$
STATIC Months,i,button,oldtree&,File$,Month$

MOUSE 2
REDIM JANUARY$(32):REDIM FEBUARY$(32):REDIM MARCH$(32)
REDIM APRIL$(32):REDIM MAY$(32):REDIM JUNE$(32)
REDIM JULY$(32):REDIM AUGUST$(32):REDIM SEPTEMBER$(32)
REDIM OCTOBER$(32):REDIM NOVEMBER$(32):REDIM DECEMBER$(32)

FOR Months=1 TO 12
SELECT CASE Months
	CASE 1:File$=Loaded_Path$+"DIARY\JANUARY.DAT"
	CASE 2:File$=Loaded_Path$+"DIARY\FEBUARY.DAT"
	CASE 3:File$=Loaded_Path$+"DIARY\MARCH.DAT"
	CASE 4:File$=Loaded_Path$+"DIARY\APRIL.DAT"
	CASE 5:File$=Loaded_Path$+"DIARY\MAY.DAT"
	CASE 6:File$=Loaded_Path$+"DIARY\JUNE.DAT"
	CASE 7:File$=Loaded_Path$+"DIARY\JULY.DAT"
	CASE 8:File$=Loaded_Path$+"DIARY\AUGUST.DAT"
	CASE 9:File$=Loaded_Path$+"DIARY\SEPTEMBER.DAT"
	CASE 10:File$=Loaded_Path$+"DIARY\OCTOBER.DAT"
	CASE 11:File$=Loaded_Path$+"DIARY\NOVEMBER.DAT"
	CASE 12:File$=Loaded_Path$+"DIARY\DECEMBER.DAT"
END SELECT

IF FEXISTS(File$) THEN
	OPEN File$ FOR INPUT AS #1
	i=1
	DO
	SELECT CASE Months
		CASE 1:INPUT #1,JANUARY$(i)
		CASE 2:INPUT #1,FEBUARY$(i)
		CASE 3:INPUT #1,MARCH$(i)
		CASE 4:INPUT #1,APRIL$(i)
		CASE 5:INPUT #1,MAY$(i)
		CASE 6:INPUT #1,JUNE$(i)
		CASE 7:INPUT #1,JULY$(i)
		CASE 8:INPUT #1,AUGUST$(i)
		CASE 9:INPUT #1,SEPTEMBER$(i)
		CASE 10:INPUT #1,OCTOBER$(i)
		CASE 11:INPUT #1,NOVEMBER$(i)
		CASE 12:INPUT #1,DECEMBER$(i)
	END SELECT
	IF i>31 THEN EXIT LOOP
	INCR i
	LOOP UNTIL EOF(1)
	CLOSE #1
ELSE
	SELECT CASE Months
		CASE 1:Month$="January"
		CASE 2:Month$="Febuary"
		CASE 3:Month$="March"
		CASE 4:Month$="April"
		CASE 5:Month$="May"
		CASE 6:Month$="June"
		CASE 7:Month$="July"
		CASE 8:Month$="August"
		CASE 9:Month$="September"
		CASE 10:Month$="October"
		CASE 11:Month$="November"
		CASE 12:Month$="December"
	END SELECT
	junk=form_alert(1,"[1][  Diary: |  Error while loading Diary |  information "+Month$+". | ][ Abort ]")
END IF
NEXT
IF dpage_handle THEN CALL UPDATE_DPAGE
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DIARY_SAVE
SHARED current_ditem,dpage_handle
STATIC Months,i,button,oldtree&,File$

MOUSE 2
FOR Months=1 TO 12
SELECT CASE Months
	CASE 1:File$=CURDIR$+"\DIARY\JANUARY.DAT"
	CASE 2:File$=CURDIR$+"\DIARY\FEBUARY.DAT"
	CASE 3:File$=CURDIR$+"\DIARY\MARCH.DAT"
	CASE 4:File$=CURDIR$+"\DIARY\APRIL.DAT"
	CASE 5:File$=CURDIR$+"\DIARY\MAY.DAT"
	CASE 6:File$=CURDIR$+"\DIARY\JUNE.DAT"
	CASE 7:File$=CURDIR$+"\DIARY\JULY.DAT"
	CASE 8:File$=CURDIR$+"\DIARY\AUGUST.DAT"
	CASE 9:File$=CURDIR$+"\DIARY\SEPTEMBER.DAT"
	CASE 10:File$=CURDIR$+"\DIARY\OCTOBER.DAT"
	CASE 11:File$=CURDIR$+"\DIARY\NOVEMBER.DAT"
	CASE 12:File$=CURDIR$+"\DIARY\DECEMBER.DAT"
END SELECT

OPEN File$ FOR OUTPUT AS #1
FOR i=1 TO 31
SELECT CASE Months
	CASE 1:WRITE #1,JANUARY$(i)
	CASE 2:WRITE #1,FEBUARY$(i)
	CASE 3:WRITE #1,MARCH$(i)
	CASE 4:WRITE #1,APRIL$(i)
	CASE 5:WRITE #1,MAY$(i)
	CASE 6:WRITE #1,JUNE$(i)
	CASE 7:WRITE #1,JULY$(i)
	CASE 8:WRITE #1,AUGUST$(i)
	CASE 9:WRITE #1,SEPTEMBER$(i)
	CASE 10:WRITE #1,OCTOBER$(i)
	CASE 11:WRITE #1,NOVEMBER$(i)
	CASE 12:WRITE #1,DECEMBER$(i)
END SELECT
NEXT
CLOSE #1
NEXT
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DIARY_DELETE
SHARED dpage_handle
STATIC oldtree&,current_day,i,Month$

oldtree&=tree&
SelectTree DIARY_PAGE

MOUSE 2
current_day=VAL(Gette_ptext$(D_Date))
Month$=LEFT$(Gette_ptext$(D_MONTH),3)
SELECT CASE Month$
	CASE=="Jan":January$(current_day)=""
	CASE=="Feb":Febuary$(current_day)=""
	CASE=="Mar":March$(current_day)=""
	CASE=="Apr":April$(current_day)=""
	CASE=="May":May$(current_day)=""
	CASE=="Jun":June$(current_day)=""
	CASE=="Jul":July$(current_day)=""
	CASE=="Aug":August$(current_day)=""
	CASE=="Sep":September$(current_day)=""
	CASE=="Oct":October$(current_day)=""
	CASE=="Nov":November$(current_day)=""
	CASE=="Dec":December$(current_day)=""
END SELECT

FOR i=D1 TO D16
	Sette_ptext i,"______________________________________"
NEXT
IF dpage_handle THEN Object_Redraw dpage_handle,D_DAYONEBACK
tree&=oldtree&
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_pagedialog
SHARED commonclose,commonobj,dpage_handle,EDITD_CHANGE
STATIC oldtree&,res,res$,x,y,w,h,i,line$,Month$

oldtree&=tree&
IF EDITD_CHANGE=-1 THEN
	MOUSE 2
	SelectTree DIARY_PAGE
	line$=Gette_ptext$(D1)
	FOR i=D2 TO D16
		line$=line$+CHR$(0)+Gette_ptext$(i)
	NEXT
	i=VAL(Gette_ptext$(D_Date))
	Month$=LEFT$(Gette_ptext$(D_MONTH),3)
	SELECT CASE Month$
	CASE=="Jan":January$(i)=line$
	CASE=="Feb":Febuary$(i)=line$
	CASE=="Mar":March$(i)=line$
	CASE=="Apr":April$(i)=line$
	CASE=="May":May$(i)=line$
	CASE=="Jun":June$(i)=line$
	CASE=="Jul":July$(i)=line$
	CASE=="Aug":August$(i)=line$
	CASE=="Sep":September$(i)=line$
	CASE=="Oct":October$(i)=line$
	CASE=="Nov":November$(i)=line$
	CASE=="Dec":December$(i)=line$
	END SELECT
	MOUSE 0
END IF
SelectTree DIARY_PAGE
CALL LEAPYEAR2(Gette_ptext$(D_Month),Gette_ptext$(D_Year))

commonclose=0										
SELECT CASE commonobj
	CASE=D_DATE
		res=0
		junk=objc_offset(tree&,D_DATE,x,y)
		res=popup(0,Day,res,x,y)
		IF res THEN
			res$=get_pop_string$(Day,res)
			sette_ptext D_DATE,res$
			CALL update_dpage
		END IF
		Object_Redraw dpage_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_Month
		res=0
		junk=objc_offset(tree&,D_Month,x,y)
		res=popup(0,Month,res,x,y)
		IF res THEN
			res$=get_pop_string$(Month,res)
			sette_ptext D_Month,res$
			CALL LEAPYEAR2(Gette_ptext$(D_Month),Gette_ptext$(D_Year))
			CALL update_dpage
		END IF
		Object_Redraw dpage_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_Year
		tree&=oldtree&
		EXIT SUB
		res=0
		junk=objc_offset(tree&,D_Year,x,y)
		res=popup(0,Year,res,x,y)
		IF res THEN
			res$=get_pop_string$(Year,res)
			CALL LEAPYEAR2(Gette_ptext$(D_Month),Gette_ptext$(D_Year))
			sette_ptext D_Year,res$
		END IF
		Object_Redraw dpage_handle,commonobj
		EXIT SUB
	CASE DIARY_QUIT
		dpage_handle=0
		commonclose=-1
		EDITD_CHANGE=0
END SELECT
Setob_state commonobj,0:Object_Redraw dpage_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB update_dpage
SHARED dpage_handle
STATIC oldtree&,current_day,i,k,old_start,Month$,page$

oldtree&=tree&
SelectTree DIARY_PAGE

MOUSE 2
current_day=VAL(Gette_ptext$(D_Date))
Month$=LEFT$(Gette_ptext$(D_MONTH),3)
SELECT CASE Month$
	CASE=="Jan":page$=January$(current_day)
	CASE=="Feb":page$=Febuary$(current_day)
	CASE=="Mar":page$=March$(current_day)
	CASE=="Apr":page$=April$(current_day)
	CASE=="May":page$=May$(current_day)
	CASE=="Jun":page$=June$(current_day)
	CASE=="Jul":page$=July$(current_day)
	CASE=="Aug":page$=August$(current_day)
	CASE=="Sep":page$=September$(current_day)
	CASE=="Oct":page$=October$(current_day)
	CASE=="Nov":page$=November$(current_day)
	CASE=="Dec":page$=December$(current_day)
END SELECT

IF page$<>"" THEN
	old_start=1
	FOR k=D1 TO D16
		i=old_start
		DO
			IF MID$(page$,i,1)=CHR$(0) THEN EXIT LOOP
			IF i>LEN(page$) THEN EXIT LOOP
			INCR i
		LOOP 
		IF MID$(page$,old_start,i-old_start)="" THEN
			Sette_ptext k,""
		ELSE
			Sette_ptext k,MID$(page$,old_start,i-old_start)
		END IF
		old_start=i+1
	NEXT
ELSE
	FOR k=D1 TO D16
		Sette_ptext k,""
	NEXT
END IF
IF dpage_handle THEN Object_Redraw dpage_handle,D_DAYONEBACK
tree&=oldtree&
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_searchdialog
SHARED commonclose,commonobj,dsearch_handle
STATIC oldtree&

oldtree&=tree&
SelectTree DIARY_SEARCH

commonclose=0										
SELECT CASE commonobj
	CASE D_SOK
		CALL DIARY_LOCATE
		dsearch_handle=0
		commonclose=-1
	CASE D_SCANCEL
		dsearch_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw dsearch_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DIARY_LOCATE
SHARED dpage_handle
STATIC oldtree&,Month$,Day$,i,locate$,match$,position

oldtree&=tree&
SelectTree DIARY_SEARCH
locate$=Gette_ptext$(D_SSEARCH)
IF Getob_state(D_SCURRENTDATE)<>0 THEN
	SelectTree DIARY_PAGE
	position=VAL(Gette_ptext$(D_DATE))
	Month$=Gette_ptext$(D_MONTH)
ELSE
	position=1
	Month$="January"
END IF
SelectTree DIARY_PAGE

IF locate$<>"" THEN
DO
FOR i=position TO 31
	SELECT CASE Month$
		CASE="January":match$=January$(i)
		CASE="Febuary":match$=Febuary$(i)
		CASE="March":match$=March$(i)
		CASE="April":match$=April$(i)
		CASE="May":match$=May$(i)
		CASE="June":match$=June$(i)
		CASE="July":match$=July$(i)
		CASE="August":match$=August$(i)
		CASE="September":match$=September$(i)
		CASE="October":match$=October$(i)
		CASE="November":match$=November$(i)
		CASE="December":match$=December$(i)
	END SELECT

	IF INSTR(UCASE$(match$),UCASE$(locate$)) THEN
		Day$=STR$(i)
		IF i<10 THEN Day$="0"+RIGHT$(Day$,1)
		Sette_ptext D_Date,RIGHT$(DAY$,2)
		Sette_ptext D_MONTH,Month$
		CALL UPDATE_DPAGE
		IF dpage_handle THEN
			Object_Redraw dpage_handle,D_DATE
			Object_Redraw dpage_handle,D_MONTH
			Object_Redraw dpage_handle,D_YEAR
		ELSE
			dpage_handle=openformwindow(" Diary: Entry ",&h0B,DIARY_PAGE,D1,DIARY_QUIT,VARPTRS(close_pagedialog))
		END IF
		EXIT LOOP
	END IF
NEXT
	SELECT CASE Month$
		CASE="January":Month$="Febuary":EXIT SELECT
		CASE="Febuary":Month$="March":EXIT SELECT
		CASE="March":Month$="April":EXIT SELECT
		CASE="April":Month$="May":EXIT SELECT
		CASE="May":Month$="June":EXIT SELECT
		CASE="June":Month$="July":EXIT SELECT
		CASE="July":Month$="August":EXIT SELECT
		CASE="August":Month$="September":EXIT SELECT
		CASE="September":Month$="October":EXIT SELECT
		CASE="October":Month$="November":EXIT SELECT
		CASE="November":Month$="December":EXIT SELECT
		CASE="December"
			junk=form_alert(1,"[1][  Diary: |  Search unsuccessful. |  No match found. ][  OK  ]")
			EXIT LOOP
	END SELECT
LOOP
END IF
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_scheduledialog
SHARED commonclose,commonobj,dschedule_handle
STATIC oldtree&,res,res$,x,y,button

oldtree&=tree&
SelectTree DIARY_SCHEDULE

commonclose=0										
SELECT CASE commonobj
	CASE D_ROK
		button=form_alert(1,"[1][  Diary: |  Are you sure you |  want to Re-Schedule? ][  OK  ]")
		SELECT CASE button
		CASE 1
			CALL DIARY_RESCHEDULE
			CALL UPDATE_DPAGE
		END SELECT
		dschedule_handle=0
		commonclose=-1
	CASE D_RCANCEL
		dschedule_handle=0
		commonclose=-1
	CASE=D_RDAY1
		CALL LEAPYEAR2(Gette_ptext$(D_RMonth1),Gette_ptext$(D_RYear1))
		res=0
		junk=objc_offset(tree&,D_RDAY1,x,y)
		res=popup(0,Day,res,x,y)
		IF res THEN
			res$=get_pop_string$(Day,res)
			sette_ptext D_RDAY1,res$
		END IF
		Object_Redraw dschedule_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_RMonth1
		res=0
		junk=objc_offset(tree&,D_RMonth1,x,y)
		res=popup(0,Month,res,x,y)
		IF res THEN
			res$=get_pop_string$(Month,res)
			sette_ptext D_RMonth1,res$
			CALL LEAPYEAR2(Gette_ptext$(D_RMonth1),Gette_ptext$(D_RYear1))
		END IF
		Object_Redraw dschedule_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_RYear1
		tree&=oldtree&
		EXIT SELECT
		res=0
		junk=objc_offset(tree&,D_RYear1,x,y)
		res=popup(0,Year,res,x,y)
		IF res THEN
			res$=get_pop_string$(Year,res)
			sette_ptext D_RYear1,res$
			CALL LEAPYEAR2(Gette_ptext$(D_RMonth1),Gette_ptext$(D_RYear1))
		END IF
		Object_Redraw dschedule_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_RDAY2
		CALL LEAPYEAR2(Gette_ptext$(D_RMonth2),Gette_ptext$(D_RYear2))
		res=0
		junk=objc_offset(tree&,D_RDAY2,x,y)
		res=popup(0,Day,res,x,y)
		IF res THEN
			res$=get_pop_string$(Day,res)
			sette_ptext D_RDAY2,res$
		END IF
		Object_Redraw dschedule_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_RMonth2
		res=0
		junk=objc_offset(tree&,D_RMonth2,x,y)
		res=popup(0,Month,res,x,y)
		IF res THEN
			res$=get_pop_string$(Month,res)
			sette_ptext D_RMonth2,res$
			CALL LEAPYEAR2(Gette_ptext$(D_RMonth2),Gette_ptext$(D_RYear2))
		END IF
		Object_Redraw dschedule_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_RYear2
		tree&=oldtree&
		EXIT SUB
		res=0
		junk=objc_offset(tree&,D_RYear2,x,y)
		res=popup(0,Year,res,x,y)
		IF res THEN
			res$=get_pop_string$(Year,res)
			sette_ptext D_RYear2,res$
			CALL LEAPYEAR2(Gette_ptext$(D_RMonth2),Gette_ptext$(D_RYear2))
		END IF
		Object_Redraw dschedule_handle,commonobj
		tree&=oldtree&
		EXIT SUB
END SELECT
Setob_state commonobj,0:Object_Redraw dschedule_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DIARY_RESCHEDULE
STATIC oldtree&,month$,today,reschedule$,today2

MOUSE 2
oldtree&=tree&
SelectTree DIARY_SCHEDULE

today=VAL(Gette_ptext$(D_Rday1))
Month$=LEFT$(Gette_ptext$(D_RMONTH1),3)
SELECT CASE Month$
	CASE=="Jan":reschedule$=January$(today)
	CASE=="Feb":reschedule$=Febuary$(today)
	CASE=="Mar":reschedule$=March$(today)
	CASE=="Apr":reschedule$=April$(today)
	CASE=="May":reschedule$=May$(today)
	CASE=="Jun":reschedule$=June$(today)
	CASE=="Jul":reschedule$=July$(today)
	CASE=="Aug":reschedule$=August$(today)
	CASE=="Sep":reschedule$=September$(today)
	CASE=="Oct":reschedule$=October$(today)
	CASE=="Nov":reschedule$=November$(today)
	CASE=="Dec":reschedule$=December$(today)
END SELECT

today2=VAL(Gette_ptext$(D_Rday2))
Month$=LEFT$(Gette_ptext$(D_RMONTH2),3)
SELECT CASE Month$
	CASE=="Jan":January$(today2)=reschedule$
	CASE=="Feb":Febuary$(today2)=reschedule$
	CASE=="Mar":March$(today2)=reschedule$
	CASE=="Apr":April$(today2)=reschedule$
	CASE=="May":May$(today2)=reschedule$
	CASE=="Jun":June$(today2)=reschedule$
	CASE=="Jul":July$(today2)=reschedule$
	CASE=="Aug":August$(today2)=reschedule$
	CASE=="Sep":September$(today2)=reschedule$
	CASE=="Oct":October$(today2)=reschedule$
	CASE=="Nov":November$(today2)=reschedule$
	CASE=="Dec":December$(today2)=reschedule$
END SELECT
tree&=oldtree&
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_printdialog
SHARED commonclose,commonobj,dprint_handle
STATIC oldtree&,print_day,Month$,Page$,old_start,i,k,res,res$,x,y

oldtree&=tree&
SelectTree DIARY_PRINT
CALL LEAPYEAR2(Gette_ptext$(D_PMonth),Gette_ptext$(D_PYear))

commonclose=0										
SELECT CASE commonobj
	CASE=D_PDAY
		res=0
		junk=objc_offset(tree&,D_PDAY,x,y)
		res=popup(0,Day,res,x,y)
		IF res THEN
			res$=get_pop_string$(Day,res)
			sette_ptext D_PDAY,res$
		END IF
		Object_Redraw dprint_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_PMonth
		res=0
		junk=objc_offset(tree&,D_PMonth,x,y)
		res=popup(0,Month,res,x,y)
		IF res THEN
			res$=get_pop_string$(Month,res)
			sette_ptext D_PMonth,res$
			CALL LEAPYEAR2(Gette_ptext$(D_PMonth),Gette_ptext$(D_PYear))
		END IF
		Object_Redraw dprint_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE=D_PYear
		tree&=oldtree&
		EXIT SELECT
		res=0
		junk=objc_offset(tree&,D_PYear,x,y)
		res=popup(0,Year,res,x,y)
		IF res THEN
			res$=get_pop_string$(Year,res)
			sette_ptext D_PYear,res$
			CALL LEAPYEAR2(Gette_ptext$(D_PMonth),Gette_ptext$(D_PYear))
		END IF
		Object_Redraw dprint_handle,commonobj
		tree&=oldtree&
		EXIT SUB
	CASE D_PPRINT
		print_day=VAL(Gette_ptext$(D_PDAY))
		Month$=LEFT$(Gette_ptext$(D_PMONTH),3)
		SELECT CASE Month$
		CASE=="Jan":page$=January$(print_day)
		CASE=="Feb":page$=Febuary$(print_day)
		CASE=="Mar":page$=March$(print_day)
		CASE=="Apr":page$=April$(print_day)
		CASE=="May":page$=May$(print_day)
		CASE=="Jun":page$=June$(print_day)
		CASE=="Jul":page$=July$(print_day)
		CASE=="Aug":page$=August$(print_day)
		CASE=="Sep":page$=September$(print_day)
		CASE=="Oct":page$=October$(print_day)
		CASE=="Nov":page$=November$(print_day)
		CASE=="Dec":page$=December$(print_day)
		END SELECT

		IF Getob_state(P_PRINTER) THEN
			CALL PStatus
			LPRINT "Diary Entry: "+Gette_ptext$(D_PDAY)+"-"Gette_ptext$(D_PMONTH)+"-"Gette_ptext$(D_PYEAR)
			LPRINT ""
		END IF 

		IF Getob_state(P_DISK) THEN
			OPEN CURDIR$+"\ENTRY.ASC" FOR OUTPUT AS #1
			PRINT #1,"Diary Entry: "+Gette_ptext$(D_PDAY)+"-"Gette_ptext$(D_PMONTH)+"-"Gette_ptext$(D_PYEAR)
			PRINT #1,""
		END IF

		IF page$<>"" THEN
			IF Getob_state(P_PRINTER) THEN CALL PStatus
			old_start=1
			FOR k=1 TO 16
				i=old_start
				DO
					IF MID$(page$,i,1)=CHR$(0) THEN EXIT LOOP
					IF i>LEN(page$) THEN EXIT LOOP
					INCR i
				LOOP 
				IF MID$(page$,old_start,i-old_start)="" THEN
					IF Getob_state(P_PRINTER) THEN CALL PStatus:LPRINT ""
					IF Getob_state(P_DISK) THEN PRINT #1,""
				ELSE
					IF Getob_state(P_PRINTER) THEN CALL PStatus:LPRINT MID$(page$,old_start,i-old_start)
					IF Getob_state(P_DISK) THEN PRINT #1,MID$(page$,old_start,i-old_start)
				END IF
				old_start=i+1
			NEXT
		ELSE
			FOR k=1 TO 16
				IF Getob_state(P_PRINTER) THEN CALL PStatus:LPRINT ""
				IF Getob_state(P_DISK) THEN PRINT #1,""
			NEXT
		END IF
		IF Getob_state(P_DISK) THEN CLOSE #1
		dprint_handle=0
		commonclose=-1
	CASE D_PCANCEL
		dprint_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw dprint_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_birthdaydialog
SHARED commonclose,commonobj,birthday_handle
STATIC oldtree&

oldtree&=tree&
SelectTree BIRTHDAY

commonclose=0										
SELECT CASE commonobj
	CASE BIRTH_QUIT
		birthday_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw birthday_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Update_Birthday
SHARED total_additems,birthday_handle
STATIC oldtree&,i,k,BIRTH_DATE$,Month$,Day$

oldtree&=tree&
SelectTree DIARY_PAGE

MOUSE 2
Day$=Gette_ptext$(D_Date)
Month$=LEFT$(Gette_ptext$(D_MONTH),3)
SELECT CASE Month$
	CASE=="Jan":MONTH$="01"
	CASE=="Feb":MONTH$="02"
	CASE=="Mar":MONTH$="03"
	CASE=="Apr":MONTH$="04"
	CASE=="May":MONTH$="05"
	CASE=="Jun":MONTH$="06"
	CASE=="Jul":MONTH$="07"
	CASE=="Aug":MONTH$="08"
	CASE=="Sep":MONTH$="09"
	CASE=="Oct":MONTH$="10"
	CASE=="Nov":MONTH$="11"
	CASE=="Dec":MONTH$="12"
END SELECT
BIRTH_DATE$=Day$+Month$

SelectTree BIRTHDAY
FOR i=B1 TO B18
	Sette_ptext i,"_________________________________"
NEXT

k=B1
FOR i=1 TO total_additems
IF LEFT$(birthday_data$(i),4)=BIRTH_DATE$ THEN
	Sette_ptext k,Day$+"/"+Month$+" "+surname_data$(i)+", "+forename_data$(i)
	INCR k
	IF k=B18 THEN EXIT FOR
END IF
NEXT
IF birthday_handle THEN Object_Redraw birthday_handle,0
tree&=oldtree&
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB BIRTHDAY_LOAD
SHARED FileSelect$,fsname$,fspath$,total_additems,top_additem,address_handle
SHARED highlight
STATIC i,record_no,record,button,oldtree&

MOUSE 2
button=form_alert(1,"[2][  Diary: |  Birthday information is not |  available.  Please load |  Address Book | ][  OK  ]")

MOUSE 2
CALL FileSelect$(CURDIR$+"\*.DAT",fsname$,"Load...")
MOUSE 0

MOUSE 2
IF fsname$<>"" THEN
IF FileSelect$<>"" THEN
	IF FEXISTS(FileSelect$) THEN
		OPEN FileSelect$ FOR INPUT AS #1
		i=1:record_no=1:record=1
		CALL REDIM_DATA(record*5)
		DO
			INPUT #1,TITLE_DATA$(i),CONTACT_DATA$(i),FORENAME_DATA$(i),SURNAME_DATA$(i)
			INPUT #1,ADDRESS_DATA$(i),STREET_DATA$(i),TOWN_DATA$(i),COUNTY_DATA$(i)
			INPUT #1,POSTCODE_DATA$(i),PHONE1_DATA$(i),PHONE2_DATA$(i),FAX_DATA$(i)
			INPUT #1,EMAIL_DATA$(i),BIRTHDAY_DATA$(i),NOTES1_DATA$(i),NOTES2_DATA$(i)
			INCR i
			INCR record_no
			IF record_no=5 THEN record_no=0:INCR record:CALL REDIM_DATA(record*5)
		LOOP UNTIL EOF(1)
		CLOSE #1
		total_additems=i-1
		top_additem=0
	ELSE
		junk=form_alert(1,"[1][  Diary: | Error while loading Address |  Book file into memory. | ][ Abort ]")
	END IF
END IF

IF total_additems>0 THEN
	oldtree&=tree&
	SelectTree ADDRESS_MAIN
	IF highlight>=15 THEN Exclob_state highlight,mask_selected:Object_Redraw address_handle,highlight
	CALL SCROLL2(total_additems,15,M_SLIDER,M_BACKGROUND)
	highlight=ADD_MAINLIST
	IF address_handle THEN 
		Object_Redraw address_handle,0
		CALL UPDATE_ADDMAIN
		CALL AutoLocate
	END IF
	tree&=oldtree&
END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_summarydialog
SHARED commonclose,commonobj,dsum_handle
STATIC oldtree&,i

oldtree&=tree&
SelectTree DIARY_SUMMARY

commonclose=0										
SELECT CASE commonobj
	CASE D_SQUIT
		dsum_handle=0
		commonclose=-1
END SELECT
Setob_state commonobj,0:Object_Redraw dsum_handle,commonobj
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SETSUMMARY
SHARED dsum_handle
STATIC oldtree&,ditem,Day$,Month$,Year$,summary$
STATIC i,k,summary2$,summary3$,Month2$

MOUSE 2
oldtree&=tree&
SelectTree DIARY_PAGE

ditem=VAL(Gette_ptext$(D_DATE))
Day$=Gette_ptext$(D_DATE)
Month$=LEFT$(Gette_ptext$(D_MONTH),3)
Year$=Gette_ptext$(D_YEAR)

SELECT CASE Month$
	CASE=="Dec":IF ditem>25 THEN ditem=25:Month$="Dec"
END SELECT

SelectTree DIARY_SUMMARY
FOR k=D_S1 TO D_S7
NEXT_MONTH:
SELECT CASE Month$
	CASE=="Jan"
		IF ditem>31 THEN ditem=1:Month$="Feb":GOTO NEXT_MONTH
		summary$=January$(ditem):Month2$="01"
	CASE=="Feb"
		IF NOT VAL(year$) MOD 4=0 THEN 
			Setob_state D_D29,8
			IF ditem>28 THEN ditem=1:Month$="Mar":GOTO NEXT_MONTH
		ELSE
			IF ditem>29 THEN ditem=1:Month$="Mar":GOTO NEXT_MONTH
		END IF
		summary$=Febuary$(ditem):Month2$="02"
	CASE=="Mar"
		IF ditem>31 THEN ditem=1:Month$="Apr":GOTO NEXT_MONTH
		summary$=March$(ditem):Month2$="03"
	CASE=="Apr"
		IF ditem>30 THEN ditem=1:Month$="May":GOTO NEXT_MONTH
		summary$=April$(ditem):Month2$="04"
	CASE=="May"
		IF ditem>31 THEN ditem=1:Month$="Jun":GOTO NEXT_MONTH
		summary$=May$(ditem):Month2$="05"
	CASE=="Jun"
		IF ditem>30 THEN ditem=1:Month$="Jul":GOTO NEXT_MONTH
		summary$=June$(ditem):Month2$="06"
	CASE=="Jul"
		IF ditem>31 THEN ditem=1:Month$="Aug":GOTO NEXT_MONTH
		summary$=July$(ditem):Month2$="07"
	CASE=="Aug"
		IF ditem>31 THEN ditem=1:Month$="Sep":GOTO NEXT_MONTH
		summary$=August$(ditem):Month2$="08"
	CASE=="Sep"
		IF ditem>30 THEN ditem=1:Month$="Oct":GOTO NEXT_MONTH
		summary$=September$(ditem):Month2$="09"
	CASE=="Oct"
		IF ditem>31 THEN ditem=1:Month$="Nov":GOTO NEXT_MONTH
		summary$=October$(ditem):Month2$="10"
	CASE=="Nov"
		IF ditem>30 THEN ditem=1:Month$="Dec":GOTO NEXT_MONTH
		summary$=November$(ditem):Month2$="11"
	CASE=="Dec":summary$=December$(ditem):Month2$="12"
END SELECT

i=LEN(summary$)
IF LEN(summary$) THEN
	i=LEN(summary$)
	DO
		IF MID$(summary$,i,1)=CHR$(0) THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 
	summary2$=RIGHT$(summary$,LEN(summary$)-i)
	summary2$=summary2$+"_________________________________"
ELSE
	summary2$="_____________________________________"
END IF

IF (i-1)>1 THEN
	summary$=LEFT$(summary$,i-1)
	i=LEN(summary$)
	DO
		IF MID$(summary$,i,1)=CHR$(0) THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 
	summary3$=RIGHT$(summary$,LEN(summary$)-i)
	summary3$=summary3$+"_________________________________"
ELSE
	summary3$="_________________________________"
END IF

IF VAL(RIGHT$(STR$(ditem),LEN(STR$(ditem))-1))<10 THEN
	Sette_ptext k,"0"+RIGHT$(STR$(ditem),LEN(STR$(ditem))-1)+"/"+Month2$+"/"+Year$+" "+summary3$
	INCR k
	Sette_ptext k,summary2$
ELSE
	Sette_ptext k,RIGHT$(STR$(ditem),LEN(STR$(ditem))-1)+"/"+Month2$+"/"+Year$+" "+summary3$
	INCR k
	Sette_ptext k,summary2$
END IF
INCR ditem
NEXT
IF dsum_handle THEN Object_Redraw dsum_handle,0
tree&=oldtree&
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LeapYear2(Month$,Year$)
STATIC i,oldtree&

Month$=LEFT$(Month$,3)
oldtree&=tree&
SelectTree Day
FOR i=D_D1 TO D_D31
	Setob_state i,0
NEXT

SELECT CASE month$
	CASE=="Feb"
		Setob_state D_D30,8:Setob_state D_D31,8
		IF NOT VAL(year$) MOD 4=0 THEN Setob_state D_D29,8
	CASE=="Apr":Setob_state D_D31,8
	CASE=="Jun":Setob_state D_D31,8
	CASE=="Sep":Setob_state D_D31,8
	CASE=="Nov":Setob_state D_D31,8
END SELECT
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

RETURN_HANDLER:
ON ERROR GOTO ERROR_HANDLER
Startprogram CURDIR$+"\APO.RSC",MENU1,-1
CALL Initialise
CALL REDIM_DATA(cell_size+1)

retry:
xHGTLOOP2
StopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'The New Toolbox's main loop
SUB xHGTloop2
SHARED about_handle,address_handle,diary_handle,calc_handle,clock_handle
SHARED notes_handle,dsum_handle,addedit_handle,alarm_active,alarm$,dpage_handle
SHARED finished_flag,Mess(1),clicks_enabled,keys_enabled,menus_enabled
SHARED mouse_detect_both,forms_enabled,EDIT_CHANGE,EDITD_CHANGE
STATIC ev,key_pressed,clicks,x,y,kstate,button,but
STATIC mclicks,mmask,mstate,top_handle

REDIM PRESERVE mess(7)
IF mouse_detect_both THEN
	mclicks=258
	mmask=3
	mstate=0
ELSE
	mclicks=2
	mmask=1
	mstate=1
END IF	

 finished_flag=0
 DO
	junk=wind_update(END_UPDATE)
	ev=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON+MU_TIMER,mclicks,mmask,mstate, _
			0,0,0,0,0,_
			0,0,0,0,0,_
			VARPTR(mess(0)),2500,_
			x,y, _
			button,kstate, _
			key_pressed,clicks)
	junk=wind_update(BEG_UPDATE)

' Start of AutoClock specific code
	IF alarm_active=-1 THEN
		IF alarm$=LEFT$(TIME$,5)
			BEEP
			SelectTree Alarm_Form
			Sette_ptext A_ALARMTIME,TIME$
			Sette_ptext A_AMes1,ALARM_DATA$(0):Sette_ptext A_AMes2,ALARM_DATA$(1)
			Sette_ptext A_AMes3,ALARM_DATA$(2):Sette_ptext A_AMes4,ALARM_DATA$(3)
			Sette_ptext A_AMes5,ALARM_DATA$(4):Sette_ptext A_AMes6,ALARM_DATA$(5)
			BEEP
			but=HandleDialog(0)
			alarm_active=0
		END IF
	END IF
' End of AutoClock specific code

	IF ev AND MU_KEYBD THEN	
		junk=wind_get(junk,10,top_handle,junk,junk,junk)
		IF kstate=4 THEN
			IF UCASE$(CHR$(key_pressed AND 255))=UCASE$("q") THEN CALL QUIT_ME
			IF key_pressed=529 THEN key_pressed=0:CALL processusermenus(top_handle,MENU_ADDBOOK,16)
			IF key_pressed=768 THEN key_pressed=0:CALL processusermenus(top_handle,MENU_DIARY,16)
			IF key_pressed=1043 THEN key_pressed=0:CALL processusermenus(top_handle,MENU_CLOCK,16)
			IF key_pressed=1300 THEN key_pressed=0:CALL processusermenus(top_handle,MENU_CALC,16)
			IF key_pressed=1557 THEN key_pressed=0:CALL processusermenus(top_handle,MENU_NOTEPAD,16) 
		END IF
		KeyboardEvent key_pressed,kstate
		SELECT CASE top_handle
			CASE address_handle
				IF (key_pressed AND 255)=8 THEN CALL AutoLocate
				IF (key_pressed AND 255)=<13 THEN EXIT SELECT
				CALL AutoLocate
			CASE addedit_handle
				EDIT_CHANGE=-1
			CASE dpage_handle
				EDITD_CHANGE=-1
			CASE calc_handle
				CALL keyboard_calc(CHR$(key_pressed AND 255))
		END SELECT
	END IF

	IF ev AND MU_MESAG THEN
		do_message
	END IF
	IF ev AND MU_BUTTON THEN
		IF forms_enabled THEN
			IF NOT ProcessFormClicks(button,clicks,kstate,x,y) THEN
				IF clicks_enabled THEN 	ProcessClicks clicks,kstate,x,y
			END IF
		ELSE
			IF clicks_enabled THEN 	ProcessClicks clicks,kstate,x,y
		END IF
	END IF
 LOOP UNTIL finished_flag
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' If an error has occurred...
ERROR_HANDLER:
' If system has run out of available windows
IF ERR=68 THEN CALL NoMoreWindows:GOTO RETURN_HANDLER
' Display alert and abort to main loop
button=form_alert(1,"[1][  An ERROR"+STR$(ERR)+" has occurred ! |  Tolerate or abort program? | ][ Tolerate | Abort ]")
SELECT CASE button
	CASE 2
		' user decides to abort
		junk=rsrc_free
		SYSTEM
END SELECT
' Go back to main loop
GOTO RETURN_HANDLER

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
