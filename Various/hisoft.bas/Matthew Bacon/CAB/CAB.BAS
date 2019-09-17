'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' CAB v0.99.9  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' Copyright HiSoft 1991-3
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Include GEMTOOL.T

'$option j100,y
DEFINT A-Z
LIBRARY "bios"
DIM SHARED DATA$(0)
CONST cell_size=14
'$DYNAMIC
'$include E:\CADENZA.97\CAB\CAB.BH

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

SUB INITIALISE
SHARED total_mainitems,top_mainitem,fsname$,fspath$,main_handle
SHARED delete_status
STATIC i,but,x,y,w,h

fsname$="CAB.DAT"
fspath$=CURDIR$+"\"
total_mainitems=0
top_mainitem=0
delete_status=-1

SelectTree FORM_MAIN
Sette_ptext M_SURNAME,""
Sette_ptext M_FORENAME,""
FOR i=LIST1 TO LIST8
	Sette_ptext i,"_______________  _______________  _____________ "
NEXT

SelectTree FORM_EDIT
Sette_ptext ADD_ETITLE,""
Sette_ptext ADD_EGREETING,""
Sette_ptext ADD_EFORENAME,""
Sette_ptext ADD_ESURNAME,""
Sette_ptext ADD_EADDRESS,""
Sette_ptext ADD_ESTREET,""
Sette_ptext ADD_ETOWN,""
Sette_ptext ADD_ECOUNTY,""
Sette_ptext ADD_EPOSTCODE,""
Sette_ptext ADD_EPHONE1,""
Sette_ptext ADD_EPHONE2,""
Sette_ptext ADD_EFAX,""
Sette_ptext ADD_EEMAIL,""
Sette_ptext ADD_EOTHER,""

SelectTree FORM_PRINT
Sette_ptext	ADD_PRANGEF,""
Sette_ptext	ADD_PRANGET,""
CALL LOAD_DAT(fspath$+fsname$)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Load *.DAT file from disk into memory
SUB LOAD_DAT(FileSelected$)
SHARED FileSelect$,fsname$,fspath$,FileSelected$
SHARED total_mainitems,top_mainitem,record_no
STATIC i,record

IF FileSelected$="" THEN 
	MOUSE 2
	' Call FileSelector
	CALL FileSelect$(CURDIR$+"\*.DAT",fsname$,"Choose a file...")
	MOUSE 0
ELSE
	IF NOT FEXISTS(FileSelected$) THEN EXIT SUB
	FileSelect$=FileSelected$
END IF
IF fsname$="" THEN EXIT SUB

MOUSE 2
IF fsname$<>"" THEN
IF FileSelect$<>"" THEN
	IF FEXISTS(FileSelect$) THEN
		OPEN FileSelect$ FOR INPUT AS #1
		i=1
		record=1
		record_no=1
		REDIM PRESERVE DATA$((i*cell_size)+1)
		DO
			INPUT #1,DATA$(i)
			IF record=cell_size THEN record=0:INCR record_no:REDIM PRESERVE DATA$((record_no*cell_size)+1)
			INCR i
			INCR record
		LOOP UNTIL EOF(1)
		CLOSE #1
		total_mainitems=(i-1)/cell_size
		top_mainitem=0
	ELSE
		' If the filename passed does not exists then display error
		IF FileSelected$<>"" THEN
			junk=form_alert(1,"[1][  CAB:|  Error while loading data |  file into memory. ][ Abort ]")
			FileSelected$=""
		END IF
	END IF
END IF
END IF
MOUSE 0
FileSelected$=""
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

' Save *.DAT file from memory to disk
SUB SAVE_DAT
SHARED total_mainitems,FileSelect$,fsname$,fspath$
STATIC i,k

IF total_mainitems=0 THEN junk=form_alert(1,"[0][  CAB:|  There are no records to save! ][ OK ]"):EXIT SUB
' Call FileSelector
MOUSE 2
CALL FileSelect$(CURDIR$+"\*.DAT",fsname$,"Save...")
MOUSE 0
IF fsname$="" THEN EXIT SUB

MOUSE 2
IF fsname$<>"" THEN
	IF FileSelect$<>"" THEN
	' Open file to channel 1
	OPEN FileSelect$ FOR OUTPUT AS #1
	FOR i=1 TO total_mainitems*cell_size
		PRINT #1,DATA$(i)+","+DATA$(i+1)+","+DATA$(i+2)+","+DATA$(i+3)+","+DATA$(i+4)
		PRINT #1,DATA$(i+5)+","+DATA$(i+6)+","+DATA$(i+7)+","+DATA$(i+8)+","+DATA$(i+9)
		PRINT #1,DATA$(i+10)+","+DATA$(i+11)+","+DATA$(i+12)+","+DATA$(i+13)
		i=i+13
	NEXT
	CLOSE #1
	IF total_mainitems=1 THEN junk=form_alert(1,"[0][  CAB:|  One record has been saved.  | ][ OK ]")
	IF total_mainitems>1 THEN junk=form_alert(1,"[0][  CAB:| "+STR$(total_mainitems)+" records have been saved.  | | ][ OK ]")
	END IF
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Display_Data
SHARED main_handle,total_mainitems
STATIC i,k,surname$,forname$,tel$

IF total_mainitems=<0 THEN
	FOR i=List1 TO List8
		Sette_ptext_update i,"_______________  _______________  _____________ ",FORM_MAIN
	NEXT
	EXIT SUB
END IF

k=1
FOR i=List1 TO List8
	surname$=LEFT$(DATA$((k*cell_size)-(cell_size-4))+"_______________",15)
	forname$=LEFT$(DATA$((k*cell_size)-(cell_size-3))+"_______________",15)
	tel$=LEFT$(DATA$((k*cell_size)-(cell_size-10))+"_____________",13)
	Sette_ptext_update i,surname$+"  "+forname$+"  "+tel$,FORM_MAIN
	IF k=total_mainitems THEN
		IF k<8 THEN
			FOR i=i+1 TO List8
				Sette_ptext_update i,"_______________  _______________  _____________ ",FORM_MAIN
			NEXT
		END IF
		EXIT FOR
	END IF
	INCR k
NEXT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_MAINDISPLAY
SHARED main_handle,total_mainitems,top_mainitem
STATIC i,k,surname$,forname$,tel$

k=(top_mainitem+1)
FOR i=List1 TO List8
	surname$=LEFT$(DATA$((k*cell_size)-(cell_size-4))+"_______________",15)
	forname$=LEFT$(DATA$((k*cell_size)-(cell_size-3))+"_______________",15)
	tel$=LEFT$(DATA$((k*cell_size)-(cell_size-10))+"_____________",13)
	Sette_ptext_update i,surname$+"  "+forname$+"  "+tel$,FORM_MAIN
	IF k=total_mainitems THEN EXIT FOR
	INCR k
NEXT
Object_Redraw main_handle,LIST_BACKGROUND
CALL SCROLL(total_mainitems,8,top_mainitem,M_SLIDER,M_BACKGROUND)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE_EDITDISPLAY
SHARED top_mainitem,current_record
STATIC k

k=(current_record+1)
SelectTree FORM_EDIT
Sette_ptext ADD_ETITLE,DATA$((k*cell_size)-(cell_size-1))
Sette_ptext ADD_EGREETING,DATA$((k*cell_size)-(cell_size-2))
Sette_ptext ADD_EFORENAME,DATA$((k*cell_size)-(cell_size-3))
Sette_ptext ADD_ESURNAME,DATA$((k*cell_size)-(cell_size-4))
Sette_ptext ADD_EADDRESS,DATA$((k*cell_size)-(cell_size-5))
Sette_ptext ADD_ESTREET,DATA$((k*cell_size)-(cell_size-6))
Sette_ptext ADD_ETOWN,DATA$((k*cell_size)-(cell_size-7))
Sette_ptext ADD_ECOUNTY,DATA$((k*cell_size)-(cell_size-8))
Sette_ptext ADD_EPOSTCODE,DATA$((k*cell_size)-(cell_size-9))
Sette_ptext ADD_EPHONE1,DATA$((k*cell_size)-(cell_size-10))
Sette_ptext ADD_EPHONE2,DATA$((k*cell_size)-(cell_size-11))
Sette_ptext ADD_EFAX,DATA$((k*cell_size)-(cell_size-12))
Sette_ptext ADD_EEMAIL,DATA$((k*cell_size)-(cell_size-13))
Sette_ptext ADD_EOTHER,DATA$((k*cell_size)-(cell_size-14))
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB AutoLocate
SHARED total_mainitems,top_mainitem,main_handle,highlight
STATIC i,Surname$,Forename$

SelectTree FORM_MAIN
IF total_mainitems=0 THEN EXIT SUB
Surname$=Gette_ptext$(M_Surname)
Forename$=Gette_ptext$(M_Forename)
Exclob_state highlight,mask_selected
highlight=List1-1000
IF Surname$="" THEN
	IF Forename$="" THEN CALL UPDATE_MAINDISPLAY:EXIT SUB
END IF

FOR i=1 TO total_mainitems
	IF INSTR(UCASE$(DATA$((i*cell_size)-(cell_size-4))),UCASE$(Surname$)) THEN 
	IF INSTR(UCASE$(DATA$((i*cell_size)-(cell_size-3))),UCASE$(Forename$)) THEN 
		top_mainitem=(i-1)
		IF total_mainitems<8 THEN
			top_mainitem=0
			highlight=(List1+i)-1
		ELSE
			highlight=List1
			IF (top_mainitem+8)>total_mainitems THEN
				highlight=(List8-(total_mainitems-top_mainitem))+1
				top_mainitem=total_mainitems-8
			END IF
		END IF
		Inclob_state highlight,mask_selected
		CALL UPDATE_MAINDISPLAY
		EXIT SUB
	END IF
	END IF
NEXT

FOR i=1 TO total_mainitems
	IF INSTR(UCASE$(DATA$((i*cell_size)-(cell_size-3))),UCASE$(Forename$)) THEN 
	IF INSTR(UCASE$(DATA$((i*cell_size)-(cell_size-4))),UCASE$(Surname$)) THEN 
		top_mainitem=(i-1)
		IF total_mainitems<8 THEN
			top_mainitem=0
			highlight=(List1+i)-1
		ELSE
			highlight=List1
			IF (top_mainitem+8)>total_mainitems THEN
				highlight=(List8-(total_mainitems-top_mainitem))+1
				top_mainitem=total_mainitems-8
			END IF
		END IF
		Inclob_state highlight,mask_selected
		CALL UPDATE_MAINDISPLAY
		EXIT SUB
	END IF
	END IF
NEXT
CALL UPDATE_MAINDISPLAY
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_adddialog
SHARED total_mainitems,record_no,current_record,top_mainitem
STATIC x,y,w,h,but,trys

trys=0
SelectTree form_edit
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
CALL SCROLL(total_mainitems+1,1,total_mainitems,ADD_ESLIDER,ADD_EBACK)
DO
but=form_do(tree&,0) AND &h7fff
INCR trys
Setob_state but,0
junk=objc_draw(tree&,but,10,Getob_x(but),Getob_y(but),w,h)
SELECT CASE but
	CASE ADD_EUP
		IF trys=1 THEN
		INCR record_no
		REDIM PRESERVE DATA$((record_no*cell_size)+1)
		SelectTree FORM_EDIT
		DATA$(((record_no-1)*cell_size)-13)=Gette_ptext$(ADD_ETITLE)
		DATA$(((record_no-1)*cell_size)-12)=Gette_ptext$(ADD_EGREETING)
		DATA$(((record_no-1)*cell_size)-11)=Gette_ptext$(ADD_EFORENAME)
		DATA$(((record_no-1)*cell_size)-10)=Gette_ptext$(ADD_ESURNAME)
		DATA$(((record_no-1)*cell_size)-9)=Gette_ptext$(ADD_EADDRESS)
		DATA$(((record_no-1)*cell_size)-8)=Gette_ptext$(ADD_ESTREET)
		DATA$(((record_no-1)*cell_size)-7)=Gette_ptext$(ADD_ETOWN)
		DATA$(((record_no-1)*cell_size)-6)=Gette_ptext$(ADD_ECOUNTY)
		DATA$(((record_no-1)*cell_size)-5)=Gette_ptext$(ADD_EPOSTCODE)
		DATA$(((record_no-1)*cell_size)-4)=Gette_ptext$(ADD_EPHONE1)
		DATA$(((record_no-1)*cell_size)-3)=Gette_ptext$(ADD_EPHONE2)
		DATA$(((record_no-1)*cell_size)-2)=Gette_ptext$(ADD_EFAX)
		DATA$(((record_no-1)*cell_size)-1)=Gette_ptext$(ADD_EEMAIL)
		DATA$(((record_no-1)*cell_size))=Gette_ptext$(ADD_EOTHER)
		INCR total_mainitems
		current_record=total_mainitems-1
		END IF
		IF current_record=0 THEN EXIT SELECT
		DECR current_record
		CALL UPDATE_EDITDISPLAY
		junk=objc_draw(tree&,ADDRESS_EBACK,10,Getob_x(ADDRESS_EBACK),Getob_y(ADDRESS_EBACK),w,h)
		CALL SCROLL(total_mainitems,1,current_record,ADD_ESLIDER,ADD_EBACK)
	CASE ADD_EDOWN
		IF trys=1 THEN
		current_record=total_mainitems
		INCR record_no
		REDIM PRESERVE DATA$((record_no*cell_size)+1)
		SelectTree FORM_EDIT
		DATA$(((record_no-1)*cell_size)-13)=Gette_ptext$(ADD_ETITLE)
		DATA$(((record_no-1)*cell_size)-12)=Gette_ptext$(ADD_EGREETING)
		DATA$(((record_no-1)*cell_size)-11)=Gette_ptext$(ADD_EFORENAME)
		DATA$(((record_no-1)*cell_size)-10)=Gette_ptext$(ADD_ESURNAME)
		DATA$(((record_no-1)*cell_size)-9)=Gette_ptext$(ADD_EADDRESS)
		DATA$(((record_no-1)*cell_size)-8)=Gette_ptext$(ADD_ESTREET)
		DATA$(((record_no-1)*cell_size)-7)=Gette_ptext$(ADD_ETOWN)
		DATA$(((record_no-1)*cell_size)-6)=Gette_ptext$(ADD_ECOUNTY)
		DATA$(((record_no-1)*cell_size)-5)=Gette_ptext$(ADD_EPOSTCODE)
		DATA$(((record_no-1)*cell_size)-4)=Gette_ptext$(ADD_EPHONE1)
		DATA$(((record_no-1)*cell_size)-3)=Gette_ptext$(ADD_EPHONE2)
		DATA$(((record_no-1)*cell_size)-2)=Gette_ptext$(ADD_EFAX)
		DATA$(((record_no-1)*cell_size)-1)=Gette_ptext$(ADD_EEMAIL)
		DATA$(((record_no-1)*cell_size))=Gette_ptext$(ADD_EOTHER)
		INCR total_mainitems
		END IF
		IF current_record+1=total_mainitems THEN EXIT SELECT
		INCR current_record
		CALL UPDATE_EDITDISPLAY
		junk=objc_draw(tree&,ADDRESS_EBACK,10,Getob_x(ADDRESS_EBACK),Getob_y(ADDRESS_EBACK),w,h)
		CALL SCROLL(total_mainitems,1,current_record,ADD_ESLIDER,ADD_EBACK)
	CASE ADD_EOK
		IF trys=1 THEN
		INCR record_no
		REDIM PRESERVE DATA$((record_no*cell_size)+1)
		SelectTree FORM_EDIT
		DATA$(((record_no-1)*cell_size)-13)=Gette_ptext$(ADD_ETITLE)
		DATA$(((record_no-1)*cell_size)-12)=Gette_ptext$(ADD_EGREETING)
		DATA$(((record_no-1)*cell_size)-11)=Gette_ptext$(ADD_EFORENAME)
		DATA$(((record_no-1)*cell_size)-10)=Gette_ptext$(ADD_ESURNAME)
		DATA$(((record_no-1)*cell_size)-9)=Gette_ptext$(ADD_EADDRESS)
		DATA$(((record_no-1)*cell_size)-8)=Gette_ptext$(ADD_ESTREET)
		DATA$(((record_no-1)*cell_size)-7)=Gette_ptext$(ADD_ETOWN)
		DATA$(((record_no-1)*cell_size)-6)=Gette_ptext$(ADD_ECOUNTY)
		DATA$(((record_no-1)*cell_size)-5)=Gette_ptext$(ADD_EPOSTCODE)
		DATA$(((record_no-1)*cell_size)-4)=Gette_ptext$(ADD_EPHONE1)
		DATA$(((record_no-1)*cell_size)-3)=Gette_ptext$(ADD_EPHONE2)
		DATA$(((record_no-1)*cell_size)-2)=Gette_ptext$(ADD_EFAX)
		DATA$(((record_no-1)*cell_size)-1)=Gette_ptext$(ADD_EEMAIL)
		DATA$(((record_no-1)*cell_size))=Gette_ptext$(ADD_EOTHER)
		INCR total_mainitems
		END IF
		CALL AutoLocate
		form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		EXIT LOOP
	CASE ADD_ECANCEL
		form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		EXIT LOOP
END SELECT
LOOP
CALL UPDATE_MAINDISPLAY
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_editdialog
SHARED current_record,record_no,total_mainitems,top_mainitem
STATIC time!,k,but,x,y,w,h,i

SelectTree form_edit
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
CALL SCROLL(total_mainitems,1,current_record,ADD_ESLIDER,ADD_EBACK)
DO
but=form_do(tree&,0) AND &h7fff
Setob_state but,0
junk=objc_draw(tree&,but,10,Getob_x(but),Getob_y(but),w,h)
SELECT CASE but
	CASE ADD_EUP
		IF current_record=0 THEN EXIT SELECT
		SelectTree FORM_EDIT
		INCR CURRENT_RECORD
		DATA$((current_record*cell_size)-13)=Gette_ptext$(ADD_ETITLE)
		DATA$((current_record*cell_size)-12)=Gette_ptext$(ADD_EGREETING)
		DATA$((current_record*cell_size)-11)=Gette_ptext$(ADD_EFORENAME)
		DATA$((current_record*cell_size)-10)=Gette_ptext$(ADD_ESURNAME)
		DATA$((current_record*cell_size)-9)=Gette_ptext$(ADD_EADDRESS)
		DATA$((current_record*cell_size)-8)=Gette_ptext$(ADD_ESTREET)
		DATA$((current_record*cell_size)-7)=Gette_ptext$(ADD_ETOWN)
		DATA$((current_record*cell_size)-6)=Gette_ptext$(ADD_ECOUNTY)
		DATA$((current_record*cell_size)-5)=Gette_ptext$(ADD_EPOSTCODE)
		DATA$((current_record*cell_size)-4)=Gette_ptext$(ADD_EPHONE1)
		DATA$((current_record*cell_size)-3)=Gette_ptext$(ADD_EPHONE2)
		DATA$((current_record*cell_size)-2)=Gette_ptext$(ADD_EFAX)
		DATA$((current_record*cell_size)-1)=Gette_ptext$(ADD_EEMAIL)
		DATA$((current_record*cell_size))=Gette_ptext$(ADD_EOTHER)
		DECR current_record
		DECR current_record
		CALL UPDATE_EDITDISPLAY
		junk=objc_draw(tree&,ADDRESS_EBACK,10,Getob_x(ADDRESS_EBACK),Getob_y(ADDRESS_EBACK),w,h)
		CALL SCROLL(total_mainitems,1,current_record,ADD_ESLIDER,ADD_EBACK)
	CASE ADD_EDOWN
		IF current_record+1=total_mainitems THEN EXIT SELECT
		SelectTree FORM_EDIT
		INCR CURRENT_RECORD
		DATA$((current_record*cell_size)-13)=Gette_ptext$(ADD_ETITLE)
		DATA$((current_record*cell_size)-12)=Gette_ptext$(ADD_EGREETING)
		DATA$((current_record*cell_size)-11)=Gette_ptext$(ADD_EFORENAME)
		DATA$((current_record*cell_size)-10)=Gette_ptext$(ADD_ESURNAME)
		DATA$((current_record*cell_size)-9)=Gette_ptext$(ADD_EADDRESS)
		DATA$((current_record*cell_size)-8)=Gette_ptext$(ADD_ESTREET)
		DATA$((current_record*cell_size)-7)=Gette_ptext$(ADD_ETOWN)
		DATA$((current_record*cell_size)-6)=Gette_ptext$(ADD_ECOUNTY)
		DATA$((current_record*cell_size)-5)=Gette_ptext$(ADD_EPOSTCODE)
		DATA$((current_record*cell_size)-4)=Gette_ptext$(ADD_EPHONE1)
		DATA$((current_record*cell_size)-3)=Gette_ptext$(ADD_EPHONE2)
		DATA$((current_record*cell_size)-2)=Gette_ptext$(ADD_EFAX)
		DATA$((current_record*cell_size)-1)=Gette_ptext$(ADD_EEMAIL)
		DATA$((current_record*cell_size))=Gette_ptext$(ADD_EOTHER)
		DECR current_record
		INCR current_record
		CALL UPDATE_EDITDISPLAY
		junk=objc_draw(tree&,ADDRESS_EBACK,10,Getob_x(ADDRESS_EBACK),Getob_y(ADDRESS_EBACK),w,h)
		CALL SCROLL(total_mainitems,1,current_record,ADD_ESLIDER,ADD_EBACK)
	CASE ADD_EPRINT	
		INCR CURRENT_RECORD
		IF NOT FEXISTS(LEFT$(CURDIR$,2)+"\CLIPBRD\*.*") THEN junk=dcreate(LEFT$(CURDIR$,2)+"\CLIPBRD")
		OPEN LEFT$(CURDIR$,2)+"\CLIPBRD\SCRAP.TXT" FOR OUTPUT AS #1
			i=14
			DO
			DECR i
			PRINT #1,DATA$((current_record*cell_size)-i)
			LOOP UNTIL i=0
		CLOSE #1
		DECR CURRENT_RECORD
	CASE ADD_EOK
		SelectTree FORM_EDIT
		INCR CURRENT_RECORD
		DATA$((current_record*cell_size)-13)=Gette_ptext$(ADD_ETITLE)
		DATA$((current_record*cell_size)-12)=Gette_ptext$(ADD_EGREETING)
		DATA$((current_record*cell_size)-11)=Gette_ptext$(ADD_EFORENAME)
		DATA$((current_record*cell_size)-10)=Gette_ptext$(ADD_ESURNAME)
		DATA$((current_record*cell_size)-9)=Gette_ptext$(ADD_EADDRESS)
		DATA$((current_record*cell_size)-8)=Gette_ptext$(ADD_ESTREET)
		DATA$((current_record*cell_size)-7)=Gette_ptext$(ADD_ETOWN)
		DATA$((current_record*cell_size)-6)=Gette_ptext$(ADD_ECOUNTY)
		DATA$((current_record*cell_size)-5)=Gette_ptext$(ADD_EPOSTCODE)
		DATA$((current_record*cell_size)-4)=Gette_ptext$(ADD_EPHONE1)
		DATA$((current_record*cell_size)-3)=Gette_ptext$(ADD_EPHONE2)
		DATA$((current_record*cell_size)-2)=Gette_ptext$(ADD_EFAX)
		DATA$((current_record*cell_size)-1)=Gette_ptext$(ADD_EEMAIL)
		DATA$((current_record*cell_size))=Gette_ptext$(ADD_EOTHER)
		DECR CURRENT_RECORD
		CALL AutoLocate
		form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		EXIT LOOP
	CASE ADD_ECANCEL
		form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		EXIT LOOP
END SELECT
LOOP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_printdialog
SHARED total_mainitems
STATIC i,from_record,to_record,Message$
STATIC but,x,y,w,h

SelectTree form_print
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
DO
but=form_do(tree&,0) AND &h7fff
SELECT CASE but
	CASE ADD_PALLFIELDS
		IF Getob_state(but)=0 THEN 
		Setob_state(ADD_PTITLE),0
		Setob_state(ADD_PCONTACT),0
		Setob_state(ADD_PFORENAME),0
		Setob_state(ADD_PSURNAME),0
		Setob_state(ADD_PADDRESS),0
		Setob_state(ADD_PHONE),0
		Setob_state(ADD_PFAX),0
		Setob_state(ADD_PEMAIL),0
		ELSE
		Setob_state(ADD_PTITLE),1
		Setob_state(ADD_PCONTACT),1
		Setob_state(ADD_PFORENAME),1
		Setob_state(ADD_PSURNAME),1
		Setob_state(ADD_PADDRESS),1
		Setob_state(ADD_PHONE),1
		Setob_state(ADD_PFAX),1
		Setob_state(ADD_PEMAIL),1
		END IF
		junk=objc_draw(tree&,1,10,x,y,w,h)
		junk=objc_draw(tree&,28,10,x,y,w,h)
	CASE ADD_PCANCEL
		Setob_state but,0
		junk=objc_draw(tree&,but,10,Getob_x(but),Getob_y(but),w,h)
		form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		EXIT LOOP
	CASE ADD_POK
		Setob_state but,0
		junk=objc_draw(tree&,but,10,Getob_x(but),Getob_y(but),w,h)
		from_record=VAL(Gette_ptext$(ADD_PRANGEF))
		to_record=VAL(Gette_ptext$(ADD_PRANGET))

		IF from_record<1 THEN from_record=1
		IF to_record>total_mainitems THEN to_record=total_mainitems
		IF Gette_ptext$(ADD_PRANGEF)="" THEN from_record=1
		IF Gette_ptext$(ADD_PRANGET)="" THEN to_record=total_mainitems
		IF from_record>to_record THEN to_record=from_record

		IF NOT FEXISTS(LEFT$(CURDIR$,2)+"\CLIPBRD\*.*") THEN junk=dcreate(LEFT$(CURDIR$,2)+"\CLIPBRD")
		OPEN LEFT$(CURDIR$,2)+"\CLIPBRD\SCRAP.TXT" FOR OUTPUT AS #1
		FOR i=from_record TO to_record
			IF Getob_state(ADD_PTITLE)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+0) 
			IF Getob_state(ADD_PCONTACT)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+1)
			IF Getob_state(ADD_PFORENAME)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+2)
			IF Getob_state(ADD_PSURNAME)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+3)
			IF Getob_state(ADD_PADDRESS)=1 THEN
				PRINT #1,DATA$((i*cell_size)-(cell_size-1)+4)
				PRINT #1,DATA$((i*cell_size)-(cell_size-1)+5) 
				PRINT #1,DATA$((i*cell_size)-(cell_size-1)+6) 
				PRINT #1,DATA$((i*cell_size)-(cell_size-1)+7) 
			END IF
			IF Getob_state(ADD_PHONE)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+8):PRINT #1,DATA$((i*cell_size)-(cell_size-1)+9)
			IF Getob_state(ADD_PFAX)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+10)
			IF Getob_state(ADD_PEMAIL)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+11)
			IF Getob_state(ADD_PALLFIELDS)=1 THEN PRINT #1,DATA$((i*cell_size)-(cell_size-1)+12):PRINT #1,DATA$((i*cell_size)-(cell_size-1)+13)
		NEXT
		CLOSE #1
END SELECT
LOOP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Sort_IT_Out
SHARED total_mainitems
STATIC i,k,surname$,forename$,address1$,address2$,address3$,address4$
STATIC postcode$,tel$,tel2$,fax$,other$,title$,email$,contact$

MOUSE 2
FOR i=1 TO total_mainitems
	title$=DATA$((i*cell_size)-(cell_size-1))
	contact$=DATA$((i*cell_size)-(cell_size-1)+1)
	forename$=DATA$(((i*cell_size)-(cell_size-1))+2)
	surname$=DATA$((i*cell_size)-(cell_size-1)+3)
	address1$=DATA$(((i*cell_size)-(cell_size-1))+4)
	address2$=DATA$(((i*cell_size)-(cell_size-1))+5)
	address3$=DATA$(((i*cell_size)-(cell_size-1))+6)
	address4$=DATA$(((i*cell_size)-(cell_size-1))+7)
	postcode$=DATA$(((i*cell_size)-(cell_size-1))+8)
	tel$=DATA$(((i*cell_size)-(cell_size-1))+9)
	tel2$=DATA$(((i*cell_size)-(cell_size-1))+10)
	fax$=DATA$(((i*cell_size)-(cell_size-1))+11)
	email$=DATA$(((i*cell_size)-(cell_size-1))+12)
	other$=DATA$(((i*cell_size)-(cell_size-1))+13)
	FOR k=i-1 TO 1 STEP -1
		IF (UCASE$(DATA$((k*cell_size)-(cell_size-1)+3)+DATA$(((k*cell_size)-(cell_size-1))+2)))<(UCASE$((surname$+forename$))) THEN EXIT FOR
		DATA$(((k+1)*cell_size)-(cell_size-1))=DATA$((k*cell_size)-(cell_size-1))
		DATA$((((k+1)*cell_size)-(cell_size-1))+1)=DATA$(((k*cell_size)-(cell_size-1))+1)
		DATA$((((k+1)*cell_size)-(cell_size-1))+2)=DATA$(((k*cell_size)-(cell_size-1))+2)
		DATA$((((k+1)*cell_size)-(cell_size-1))+3)=DATA$(((k*cell_size)-(cell_size-1))+3)
		DATA$((((k+1)*cell_size)-(cell_size-1))+4)=DATA$(((k*cell_size)-(cell_size-1))+4)
		DATA$((((k+1)*cell_size)-(cell_size-1))+5)=DATA$(((k*cell_size)-(cell_size-1))+5)
		DATA$((((k+1)*cell_size)-(cell_size-1))+6)=DATA$(((k*cell_size)-(cell_size-1))+6)
		DATA$((((k+1)*cell_size)-(cell_size-1))+7)=DATA$(((k*cell_size)-(cell_size-1))+7)
		DATA$((((k+1)*cell_size)-(cell_size-1))+8)=DATA$(((k*cell_size)-(cell_size-1))+8)
		DATA$((((k+1)*cell_size)-(cell_size-1))+9)=DATA$(((k*cell_size)-(cell_size-1))+9)
		DATA$((((k+1)*cell_size)-(cell_size-1))+10)=DATA$(((k*cell_size)-(cell_size-1))+10)
		DATA$((((k+1)*cell_size)-(cell_size-1))+11)=DATA$(((k*cell_size)-(cell_size-1))+11)
		DATA$((((k+1)*cell_size)-(cell_size-1))+12)=DATA$(((k*cell_size)-(cell_size-1))+12)
		DATA$((((k+1)*cell_size)-(cell_size-1))+13)=DATA$(((k*cell_size)-(cell_size-1))+13)
	NEXT
	DATA$(((k+1)*cell_size)-(cell_size-1))=title$
	DATA$((((k+1)*cell_size)-(cell_size-1))+1)=contact$
	DATA$((((k+1)*cell_size)-(cell_size-1))+2)=forename$
	DATA$((((k+1)*cell_size)-(cell_size-1))+3)=surname$
	DATA$((((k+1)*cell_size)-(cell_size-1))+4)=address1$
	DATA$((((k+1)*cell_size)-(cell_size-1))+5)=address2$
	DATA$((((k+1)*cell_size)-(cell_size-1))+6)=address3$
	DATA$((((k+1)*cell_size)-(cell_size-1))+7)=address4$
	DATA$((((k+1)*cell_size)-(cell_size-1))+8)=postcode$
	DATA$((((k+1)*cell_size)-(cell_size-1))+9)=tel$
	DATA$((((k+1)*cell_size)-(cell_size-1))+10)=tel2$
	DATA$((((k+1)*cell_size)-(cell_size-1))+11)=fax$
	DATA$((((k+1)*cell_size)-(cell_size-1))+12)=email$
	DATA$((((k+1)*cell_size)-(cell_size-1))+13)=other$
NEXT
MOUSE 0
CALL autolocate
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_maindialog
SHARED commonclose,commonobj,main_handle,total_mainitems,top_mainitem
SHARED highlight,current_record,FileSelect$,delete_status,record_no
STATIC res,res$,x,y,button,delete_record,i

commonclose=0										
SELECT CASE commonobj
	CASE OPTIONS	
		res=0
		junk=objc_offset(tree&,OPTIONS,x,y)
		res=popup(0,POP_MAIN,res,x,y)
		SELECT CASE res
			CASE about
				SelectTree form_about
				junk=HandleDialog(0)
			CASE new_data
exit_new:		MOUSE 2
				button=form_alert(2,"[2][  CAB:|  Do you really want to loose |  all unsaved data? ][ Continue | Cancel ]")
				SELECT CASE button
				CASE 1
					total_mainitems=0
					top_mainitem=0
					record_no=1
					REDIM DATA$((1*cell_size)+1)
					CALL Display_Data
					Object_Redraw main_handle,LIST_BACKGROUND
					CALL SCROLL(total_mainitems,8,top_mainitem,M_SLIDER,M_BACKGROUND)
				END SELECT
				MOUSE 0
			CASE load
exit_load:		CALL LOAD_DAT("")
				IF total_mainitems>0 THEN
					IF FileSelect$<>"" THEN
						CALL Display_Data
						CALL SCROLL2(total_mainitems,8,M_SLIDER,M_BACKGROUND)
						CALL AutoLocate
					END IF
				END IF
			CASE save
				CALL SAVE_DAT
			CASE add
				SelectTree FORM_EDIT
				Sette_ptext ADD_ETITLE,""
				Sette_ptext ADD_EGREETING,""
				Sette_ptext ADD_EFORENAME,""
				Sette_ptext ADD_ESURNAME,""
				Sette_ptext ADD_EADDRESS,""
				Sette_ptext ADD_ESTREET,""
				Sette_ptext ADD_ETOWN,""
				Sette_ptext ADD_ECOUNTY,""
				Sette_ptext ADD_EPOSTCODE,""
				Sette_ptext ADD_EPHONE1,""
				Sette_ptext ADD_EPHONE2,""
				Sette_ptext ADD_EFAX,""
				Sette_ptext ADD_EEMAIL,""
				Sette_ptext ADD_EOTHER,""
				CALL close_adddialog
			CASE delete
				IF delete_status=0 THEN
					delete_status=-1
					Sette_ptext	OPTIONS,"Options"
					SelectTree POP_MAIN
					Setob_state about,0
					Setob_state new_data,0
					Setob_state load,0
					Setob_state save,0
					Setob_state add,0
					Setob_state delete,0
					Setob_state Print_It,0
					Setob_state sort,0
					SelectTree FORM_MAIN
					Object_Redraw main_handle,Options
				ELSE
					delete_status=0
					Sette_ptext	OPTIONS,"Delete record"
					SelectTree POP_MAIN
					Setob_state about,8
					Setob_state new_data,8
					Setob_state load,8
					Setob_state save,8
					Setob_state add,8
					Setob_state sort,8
					Setob_state Print_It,8
					SelectTree FORM_MAIN
					Object_Redraw main_handle,Options
				END IF
			CASE sort
				CALL Sort_IT_Out
			CASE Print_It
				CALL close_printdialog
			CASE quit
				CALL QUIT_ME
		END SELECT
		EXIT SUB
	CASE List1 TO List8
		IF (top_mainitem-list1+commonobj)>total_mainitems-1 THEN EXIT SUB
		IF delete_status=0 THEN
			delete_record=(top_mainitem-list1+commonobj)
			FOR i=(delete_record*cell_size) TO ((total_mainitems-1)*cell_size)
				Data$(i)=Data$(i+cell_size)
			NEXT
			DECR total_mainitems
			DECR record_no
			REDIM PRESERVE DATA$((record_no*cell_size)+1)
			IF (top_mainitem+8)>total_mainitems THEN top_mainitem=(total_mainitems-8)
			IF top_mainitem<0 THEN top_mainitem=0
			CALL Display_Data
			CALL AUTOLOCATE
		ELSE
			current_record=(top_mainitem-list1+commonobj)
			CALL UPDATE_EDITDISPLAY
			CALL close_editdialog
		END IF
		EXIT SUB
	CASE M_ARROWUP
		DECR top_mainitem
		Exclob_state highlight,mask_selected
		INCR highlight
		SELECT CASE highlight
			CASE List1 TO List8:Inclob_state highlight,mask_selected
		END SELECT
		IF top_mainitem<0 THEN
			Exclob_state highlight,mask_selected
			DECR highlight
			top_mainitem=0
			DO
			LOOP UNTIL MOUSE(2)=0
			SELECT CASE highlight
				CASE List1 TO List8:Inclob_state highlight,mask_selected
			END SELECT
			EXIT SELECT
		END IF
		CALL UPDATE_MAINDISPLAY
	CASE M_ARROWDOWN
		INCR top_mainitem
		Exclob_state highlight,mask_selected
		DECR highlight
		SELECT CASE highlight
			CASE List1 TO List8:Inclob_state highlight,mask_selected
		END SELECT
		IF top_mainitem>total_mainitems-8 THEN
			INCR highlight
			top_mainitem=total_mainitems-8
			DO
			LOOP UNTIL MOUSE(2)=0
			EXIT SELECT
		END IF
		CALL UPDATE_MAINDISPLAY
	CASE MAIN_QUIT
		CALL QUIT_ME
END SELECT
Setob_state commonobj,0:Object_Redraw main_handle,commonobj
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB QUIT_ME
SHARED main_handle,commonclose
STATIC button

commonclose=-1:main_handle=0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' Start of program

ON ERROR GOTO ERROR_HANDLER
StartAccessory "  CAB v0.99.9 "
DO
	evnt_mesag VARPTR(mess(0))
	CALL do_message:GOTO return_handler
LOOP

RETURN_HANDLER:
ON ERROR GOTO ERROR_HANDLER
xhgtloop2

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB AccOpened
SHARED commonclose,commonobj,resource_loaded
SHARED main_handle,total_mainitems
STATIC i

INCR i
IF resource_loaded=0 THEN
	MOUSE 2
	IF rsrc_load(CURDIR$+"\CAB.RSC")=0 THEN
		junk=form_alert(1,"[1][  CAB:|  Error while loading |  resource file. | ][ Abort ]")
		MOUSE 0:resource_loaded=0:EXIT SUB	
	END IF
	MOUSE 0:resource_loaded=-1
END IF

IF i=1 THEN
	SelectTree form_about
	junk=HandleDialog(0)
	CALL initialise
END IF

commonclose=0
IF main_handle THEN
	TopAWindow main_handle
ELSE
	main_handle=openformwindow(" CAB (Cadenza Address Book) ",&h0B,FORM_MAIN,M_Surname,MAIN_QUIT,VARPTRS(close_maindialog))
	Object_Redraw main_handle,commonobj
	CALL Display_Data
	CALL SCROLL2(total_mainitems,8,M_SLIDER,M_BACKGROUND)
	CALL AutoLocate
	IF i>1 THEN FullRedraw main_handle
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'The New Toolbox's main loop
SUB xHGTloop2
STATIC ev,key_pressed,clicks,x,y,kstate,button
STATIC mclicks,mmask,mstate,top_handle
SHARED finished_flag,Mess(1),clicks_enabled,keys_enabled,menus_enabled,forms_enabled
SHARED mouse_detect_both,main_handle,keyboardpressed$

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
	ev=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON,mclicks,mmask,mstate, _
			0,0,0,0,0,_
			0,0,0,0,0,_
			VARPTR(mess(0)),0,_
			x,y, _
			button,kstate, _
			key_pressed,clicks)
	junk=wind_update(BEG_UPDATE)


	IF ev AND MU_KEYBD THEN	
		KeyboardEvent key_pressed,kstate
		junk=wind_get(junk,10,top_handle,junk,junk,junk)
		SELECT CASE top_handle
		CASE main_handle
			IF (key_pressed AND 255)=8 THEN CALL AutoLocate
			IF (key_pressed AND 255)=<13 THEN EXIT SELECT
			CALL AutoLocate
		END SELECT
	END IF
exit_input:

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
IF ERR=68 THEN CALL NoMoreWindows:SYSTEM
' Display alert and abort to main loop
button=form_alert(1,"[1][  CAB:|  An ERROR"+STR$(ERR)+" has occurred ! |  Try to tolerate or abort |  program? | ][ Tolerate | Abort ]")
SELECT CASE button
	CASE 2
		' user decides to abort
		junk=rsrc_free
		SYSTEM
END SELECT
' If system has run out of available windows, then quit
' Go back to main loop
ON ERROR GOTO ERROR_HANDLER
GOTO RETURN_HANDLER

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
