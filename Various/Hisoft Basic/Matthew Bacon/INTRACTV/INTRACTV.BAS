'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' InterActive v1.2  ½ 1997 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC GEM Toolkit - Written by Dave Nutkins and Ofir Gal
' Copyright HiSoft 1991-3
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

'$option q80,y
DEFINT A-Z
LIBRARY "bios"
'$DYNAMIC
DIM SHARED SOFTY$(0),PERSON$(50),OTHER$(50),SUMMARY$(300),SOFTWARE$(0),FEE$(0)

'$include D:\HBASIC\HGT\GEMAES.BH
'$include D:\HBASIC\HGT\TOOLBOX.BAS
'$include D:\HBASIC\HGT.2\NEWTOO~2.BAS
'$include F:\CADENZA\INTRACTV\NEWTEXT3.BAS
'$include F:\CADENZA\INTRACTV\INTRACTV.BH

CONST wf_iconify=26,wf_uniconify=27,win_icon=&h4000
CONST wm_bottom=33,wm_iconify=34,wm_uniconify=35,wm_alliconify=36
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

FUNCTION get_pop_text$(BYVAL poptree,BYVAL popobj)
STATIC oldtree&
oldtree&=tree&
selecttree poptree
get_pop_text$=RTRIM$(LTRIM$(Gette_ptext$(popobj)))
tree&=oldtree&
END FUNCTION

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL(total_items,display_items,top_item,object,background)
SHARED soft_handle
STATIC i!,height!,y_position!,x,y,w,h,top_handle

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
junk=wind_get(junk,10,top_handle,junk,junk,junk)
IF top_handle=soft_handle THEN
	junk=objc_draw(tree&,background,10,x,y,w,h)
ELSE
	Object_Redraw soft_handle,background
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SCROLL2(total_items,display_items,top_item,object,background)
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
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB OPEN_DATA
SHARED PERSON$(),OTHER$(),person_handle,other_handle
STATIC i,rename_handle,delete_handle,k,j

MOUSE 2
IF FEXISTS(CURDIR$+"\INTRACTV.DAT") THEN
	OPEN CURDIR$+"\INTRACTV.DAT" FOR INPUT AS #1
	i=1
	DO
		IF i=<11 THEN LINE INPUT #1,PERSON$(i)
		IF i>=12 THEN LINE INPUT #1,OTHER$(i-11)
		IF i>=12 THEN 
			IF OTHER$(i-11)="/start" THEN
				CLOSE #1
				EXIT LOOP
			END IF
		END IF
		INCR i
	LOOP UNTIL EOF(1)
	PERSON$(1)="  "+PERSON$(1)
	PERSON$(9)="  "+PERSON$(9)
	PERSON$(10)="  "+PERSON$(10)
	PERSON$(11)="  "+PERSON$(11)
	CALL SET_PERSON
	CALL SET_OTHER

	SelectTree POP_TITLE
	FOR j=TIT_MR TO TIT_LORD
		IF PERSON$(1)=Gette_ptext$(j) THEN 
			Inclob_state j,mask_checked
		ELSE
			Setob_state j,0
		END IF
	NEXT

	SelectTree POP_COUNTRY
	FOR j=CO1 TO CO15
		IF "  "+PERSON$(6)=Gette_ptext$(j) THEN
			Inclob_state j,mask_checked
		ELSE
			Setob_state j,0
		END IF
	NEXT

	SelectTree POP_COMPUTER
	FOR j=C1 TO C8
		Setob_state j,0
	NEXT

	FOR k=18 TO i
		FOR j=C1 TO C8
			IF OTHER$(k-11)=Gette_ptext$(j) THEN Inclob_state j,mask_checked
		NEXT
	NEXT

	SelectTree POP_OS
	FOR j=OS1 TO OS8
		Setob_state j,0
	NEXT

	FOR k=18 TO i
		FOR j=OS1 TO OS8
			IF OTHER$(k-11)=Gette_ptext$(j) THEN Inclob_state j,mask_checked
		NEXT
	NEXT

	SelectTree POP_DRIVE
	FOR j=D1 TO D6
		IF PERSON$(11)=Gette_ptext$(j) THEN
			Inclob_state j,mask_checked
		ELSE
			Setob_state j,0
		END IF
	NEXT

	SelectTree FORM_DETAILS
	IF MID$(Gette_ptext$(DET_TITLE),3,1)<>"" THEN setob_scut DET_TITLE,MID$(Gette_ptext$(DET_TITLE),3,1)
	IF MID$(Gette_ptext$(DET_COMPUTER),3,1)<>"" THEN setob_scut DET_COMPUTER,MID$(Gette_ptext$(DET_COMPUTER),3,1)
	IF MID$(Gette_ptext$(DET_OS),3,1)<>"" THEN setob_scut DET_OS,MID$(Gette_ptext$(DET_OS),3,1)
	IF person_handle THEN Object_Redraw person_handle,0
	IF person_handle THEN Object_Redraw person_handle,DET_CANCEL
	IF person_handle THEN Object_Redraw person_handle,DET_OK
	IF person_handle THEN Object_Redraw person_handle,DET_TITLE
	IF person_handle THEN Object_Redraw person_handle,DET_COMPUTER
	IF person_handle THEN Object_Redraw person_handle,DET_OS
	SelectTree FORM_OTHER
	IF other_handle THEN Object_Redraw other_handle,0
	IF other_handle THEN Object_Redraw other_handle,OTHERCANCEL
	IF other_handle THEN Object_Redraw other_handle,OTHEROK
END IF
MOUSE 0
END SUB

SUB LOAD_SOFT
SHARED SOFTWARE$(),FEE$(),NoTitles,top_item
STATIC i

MOUSE 2
IF FEXISTS(CURDIR$+"\INTRACTV.DAT") THEN
	OPEN CURDIR$+"\INTRACTV.DAT" FOR INPUT AS #1
	REDIM PRESERVE SOFTWARE$(10)
	REDIM PRESERVE FEE$(10)
	NoTitles=1
	i=1
	DO
		LINE INPUT #1,SOFTWARE$(i)
		IF SOFTWARE$(i)="/start" THEN
		DO
			LINE INPUT #1,SOFTWARE$(i)
			IF SOFTWARE$(i)="/end" THEN:CLOSE #1:top_item=1:NoTitles=i-1:MOUSE 0:EXIT SUB
			SOFTWARE$(i)="0"+SOFTWARE$(i)
			IF RIGHT$(SOFTWARE$(i),1)="+" THEN
				FEE$(i)=RIGHT$(SOFTWARE$(i),6)
			ELSE
				FEE$(i)=RIGHT$(SOFTWARE$(i),5)
			END IF
			INCR i
			INCR NoTitles
			IF NoTitles=11 THEN NoTitles=1:REDIM PRESERVE SOFTWARE$(i+10):REDIM PRESERVE FEE$(i+10)
		LOOP UNTIL EOF(1)
		END IF
	LOOP UNTIL EOF(1)
	top_item=1
	NoTitles=i-1
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SAVE_DATA
SHARED PERSON$(),OTHER$(),person_handle,other_handle,NoTitles,SOFTWARE$()
STATIC i,rename_handle,delete_handle,create_handle

MOUSE 2
IF FEXISTS(CURDIR$+"\INTRACTV.DAT") THEN
	IF FEXISTS(CURDIR$+"\INTRACTV.BAK") THEN
		delete_handle=fdelete(CURDIR$+"\INTRACTV.BAK")
		IF delete_handle<0 THEN GOTO ERROR_HANDLER
	END IF
	rename_handle=frename(CURDIR$+"\INTRACTV.DAT",CURDIR$+"\INTRACTV.BAK")
	IF rename_handle<0 THEN GOTO ERROR_HANDLER
END IF

create_handle=fcreate(CURDIR$+"\INTRACTV.DAT",2)
IF create_handle<0 THEN GOTO ERROR_HANDLER
junk=fclose(create_handle)

OPEN CURDIR$+"\INTRACTV.DAT" FOR OUTPUT AS #1
IF person_handle THEN
	SelectTree FORM_DETAILS
	PRINT #1,RTRIM$(LTRIM$(Gette_ptext$(DET_TITLE)))
	PRINT #1,Gette_ptext$(DET_NAME)
	PRINT #1,Gette_ptext$(DET_STREET)
	PRINT #1,Gette_ptext$(DET_TOWN)
	PRINT #1,Gette_ptext$(DET_POSTCODE)
	PRINT #1,Gette_ptext$(DET_COUNTRY)
	PRINT #1,Gette_ptext$(DET_PHONE)
	PRINT #1,Gette_ptext$(DET_EMAIL)
	PRINT #1,RTRIM$(LTRIM$(Gette_ptext$(DET_COMPUTER)))
	PRINT #1,RTRIM$(LTRIM$(Gette_ptext$(DET_OS)))
	PRINT #1,RTRIM$(LTRIM$(Gette_ptext$(DET_DRIVE)))
ELSE
	FOR i=1 TO 11
		PRINT #1,RTRIM$(LTRIM$(PERSON$(i)))
	NEXT
END IF

IF other_handle THEN
	SelectTree FORM_OTHER
	PRINT #1,Gette_ptext$(OTHER1)
	PRINT #1,Gette_ptext$(OTHER2)
	PRINT #1,Gette_ptext$(OTHER3)
	IF Getob_flags(B6)=1088 THEN
		PRINT #1,"ok"
	ELSE
		PRINT #1,"hidden"
	END IF
	IF Getob_flags(B7)=1088 THEN
		PRINT #1,"ok"
	ELSE
		PRINT #1,"hidden"
	END IF
	IF Getob_flags(B8)=1088 THEN
		PRINT #1,"ok"
	ELSE
		PRINT #1,"hidden"
	END IF
	IF Getob_flags(B9)=1088 THEN
		PRINT #1,"ok"
	ELSE
		PRINT #1,"hidden"
	END IF
	IF Getob_flags(B10)=1088 THEN
		PRINT #1,"ok"
	ELSE
		PRINT #1,"hidden"
	END IF
ELSE
	FOR i=1 TO 8
		PRINT #1,OTHER$(i)
	NEXT
END IF

SelectTree POP_COMPUTER
FOR i=C1 TO C8
	IF Curob_state(i,mask_checked)<>0 THEN PRINT #1,Gette_ptext$(i)
NEXT
SelectTree POP_OS
FOR i=OS1 TO OS8
	IF Curob_state(i,mask_checked)<>0 THEN PRINT #1,Gette_ptext$(i)
NEXT

PRINT #1,"/start"
FOR i=1 TO NoTitles
	PRINT #1,RIGHT$(SOFTWARE$(i),LEN(SOFTWARE$(i))-1)
NEXT
PRINT #1,"/end"

CLOSE #1
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Initialise
SHARED about_handle,soft_handle,person_handle,other_handle,fee_handle
SHARED COUNTRY$(),COMPUTER$(),OS$(),DRIVE$(),OTHER$(),celly
STATIC i,k,oldtree&,x,y,w,h

oldtree&=tree&
SelectTree FORM_DETAILS
Sette_ptext DET_TITLE,"  Mr"
Sette_ptext DET_NAME,""
Sette_ptext DET_STREET,""
Sette_ptext DET_TOWN,""
Sette_ptext DET_POSTCODE,""
Sette_ptext DET_COUNTRY,""
Sette_ptext DET_PHONE,""
Sette_ptext DET_EMAIL,""
Sette_ptext DET_COMPUTER,"  Atari STe"
Sette_ptext DET_OS,"  TOS 1.62 or above"
Sette_ptext DET_DRIVE,"  7.20Mb DD"

SelectTree POP_TITLE
Inclob_state TIT_MR,mask_checked
SelectTree POP_COMPUTER
FOR i=C1 TO C8
	IF Gette_ptext$(i)="  Atari STe" THEN Inclob_state i,mask_checked
NEXT 
SelectTree POP_OS
FOR i=OS1 TO OS8
	IF Gette_ptext$(i)="  TOS 1.62 or above" THEN Inclob_state i,mask_checked
NEXT 
SelectTree POP_DRIVE
FOR i=D1 TO D6
	IF Gette_ptext$(i)="  7.20Mb DD" THEN Inclob_state i,mask_checked
NEXT 


SelectTree FORM_OTHER
FOR i=OTHER1 TO OTHER3
	Sette_ptext i,""
NEXT
Inclob_flags B6,mask_hidetree
Exclob_flags B7,mask_hidetree
Exclob_flags B8,mask_hidetree
Inclob_flags B9,mask_hidetree
Inclob_flags B10,mask_hidetree

SelectTree FORM_PRINT
Sette_ptext P_LPP,"60"
Sette_ptext P_MARGIN,"00"

SelectTree FORM_FEE
Sette_ptext FEE_FEE,""

SelectTree FORM_SOFT
Sette_ptext SOFT_TALLY,"Items: 0 - Total spent so far: 0.00"
CALL GET_PERSON
CALL GET_OTHER
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Initialise2
SHARED about_handle,soft_handle,person_handle,other_handle,fee_handle
SHARED COUNTRY$(),COMPUTER$(),OS$(),DRIVE$()
STATIC i,k,oldtree&

oldtree&=tree&
SelectTree FORM_DETAILS
Sette_ptext DET_TITLE,"  Mr"
Sette_ptext DET_NAME,""
Sette_ptext DET_STREET,""
Sette_ptext DET_TOWN,""
Sette_ptext DET_POSTCODE,""
Sette_ptext DET_COUNTRY,""
Sette_ptext DET_PHONE,""
Sette_ptext DET_EMAIL,""
Sette_ptext DET_COMPUTER,"  Atari STe"
Sette_ptext DET_OS,"  TOS 1.62 or above"
Sette_ptext DET_DRIVE,"  7.20Mb DD"
setob_scut DET_TITLE,MID$(Gette_ptext$(DET_TITLE),3,1)
setob_scut DET_COMPUTER,MID$(Gette_ptext$(DET_COMPUTER),3,1)
setob_scut DET_OS,MID$(Gette_ptext$(DET_OS),3,1)
IF person_handle THEN Object_Redraw person_handle,0
IF person_handle THEN Object_Redraw person_handle,DET_CANCEL
IF person_handle THEN Object_Redraw person_handle,DET_OK
IF person_handle THEN Object_Redraw person_handle,DET_TITLE
IF person_handle THEN Object_Redraw person_handle,DET_COMPUTER
IF person_handle THEN Object_Redraw person_handle,DET_OS
SelectTree POP_TITLE
FOR i=TIT_MR TO TIT_LORD
	Setob_state i,0
NEXT
Inclob_state TIT_MR,mask_checked

SelectTree POP_COUNTRY
FOR i=CO1 TO CO15
	Setob_state i,0
NEXT

SelectTree POP_COMPUTER
FOR i=C1 TO C8
	IF Gette_ptext$(i)="  Atari STe" THEN
		Inclob_state i,mask_checked
	ELSE
		Setob_state i,0
	END IF
NEXT 

SelectTree POP_OS
FOR i=OS1 TO OS8
	IF Gette_ptext$(i)="  TOS 1.62 or above" THEN 
		Inclob_state i,mask_checked
	ELSE
		Setob_state i,0
	END IF
NEXT 
SelectTree POP_DRIVE
FOR i=D1 TO D6
	IF Gette_ptext$(i)="  7.20Mb DD" THEN
		Inclob_state i,mask_checked
	ELSE
		Setob_state i,0
	END IF
NEXT 

SelectTree FORM_OTHER
FOR i=OTHER1 TO OTHER3
	Sette_ptext i,""
NEXT
Inclob_flags B6,mask_hidetree
Exclob_flags B7,mask_hidetree
Exclob_flags B8,mask_hidetree
Inclob_flags B9,mask_hidetree
Inclob_flags B10,mask_hidetree
IF other_handle THEN Object_Redraw other_handle,0
IF other_handle THEN Object_Redraw other_handle,OTHERCANCEL
IF other_handle THEN Object_Redraw other_handle,OTHEROK

SelectTree FORM_FEE
Sette_ptext FEE_FEE,""
CALL GET_PERSON
CALL GET_OTHER
IF fee_handle THEN Object_Redraw fee_handle,FEE_OK
IF fee_handle THEN Object_Redraw fee_handle,0
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB GET_PERSON
SHARED PERSON$()

SelectTree FORM_DETAILS
PERSON$(1)=Gette_ptext$(DET_TITLE)
PERSON$(2)=Gette_ptext$(DET_NAME)
PERSON$(3)=Gette_ptext$(DET_STREET)
PERSON$(4)=Gette_ptext$(DET_TOWN)
PERSON$(5)=Gette_ptext$(DET_POSTCODE)
PERSON$(6)=Gette_ptext$(DET_COUNTRY)
PERSON$(7)=Gette_ptext$(DET_PHONE)
PERSON$(8)=Gette_ptext$(DET_EMAIL)
PERSON$(9)=Gette_ptext$(DET_COMPUTER)
PERSON$(10)=Gette_ptext$(DET_OS)
PERSON$(11)=Gette_ptext$(DET_DRIVE)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB GET_OTHER
SHARED OTHER$()

SelectTree FORM_OTHER
OTHER$(1)=Gette_ptext$(OTHER1)
OTHER$(2)=Gette_ptext$(OTHER2)
OTHER$(3)=Gette_ptext$(OTHER3)
IF Getob_flags(B6)=1088 THEN
	OTHER$(4)="ok"
ELSE
	OTHER$(4)="hidden"
END IF
IF Getob_flags(B7)=1088 THEN
	OTHER$(5)="ok"
ELSE
	OTHER$(5)="hidden"
END IF
IF Getob_flags(B8)=1088 THEN
	OTHER$(6)="ok"
ELSE
	OTHER$(6)="hidden"
END IF
IF Getob_flags(B9)=1088 THEN
	OTHER$(7)="ok"
ELSE
	OTHER$(7)="hidden"
END IF
IF Getob_flags(B10)=1088 THEN
	OTHER$(8)="ok"
ELSE
	OTHER$(8)="hidden"
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SET_PERSON
SHARED PERSON$()

SelectTree FORM_DETAILS
Sette_ptext DET_TITLE,PERSON$(1)
Sette_ptext DET_NAME,PERSON$(2)
Sette_ptext DET_STREET,PERSON$(3)
Sette_ptext DET_TOWN,PERSON$(4)
Sette_ptext DET_POSTCODE,PERSON$(5)
Sette_ptext DET_COUNTRY,PERSON$(6)
Sette_ptext DET_PHONE,PERSON$(7)
Sette_ptext DET_EMAIL,PERSON$(8)
Sette_ptext DET_COMPUTER,PERSON$(9)
Sette_ptext DET_OS,PERSON$(10)
Sette_ptext DET_DRIVE,PERSON$(11)
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SET_OTHER
SHARED OTHER$()

SelectTree FORM_OTHER
Sette_ptext OTHER1,OTHER$(1)
Sette_ptext OTHER2,OTHER$(2)
Sette_ptext OTHER3,OTHER$(3)
IF OTHER$(4)="ok" THEN
	Exclob_flags B6,mask_hidetree
ELSE
	Inclob_flags B6,mask_hidetree
END IF
IF OTHER$(5)="ok" THEN
	Exclob_flags B7,mask_hidetree
ELSE
	Inclob_flags B7,mask_hidetree
END IF
IF OTHER$(6)="ok" THEN
	Exclob_flags B8,mask_hidetree
ELSE
	Inclob_flags B8,mask_hidetree
END IF
IF OTHER$(7)="ok" THEN
	Exclob_flags B9,mask_hidetree
ELSE
	Inclob_flags B9,mask_hidetree
END IF
IF OTHER$(8)="ok" THEN
	Exclob_flags B10,mask_hidetree
ELSE
	Inclob_flags B10,mask_hidetree
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB processusermenus(VAL topwin,VAL item,VAL title)
SHARED commonclose,commonobj,menutree&,finished_flag
SHARED about_handle,soft_handle,person_handle,other_handle,print_handle
SHARED tsummary,SUMMARY$(),summary_handle,NoTitles,top_item
SHARED lines$(),wolines(),softy$(),celly,SOFTWARE$()
STATIC oldtree&,i,dum&,wx,wy,ww,wh,button,top_handle,x,y,w,h

commonclose=0										
SELECT CASE item
	CASE MENU_ABOUT
		IF about_handle THEN
			TopAWindow about_handle
		ELSE
			about_handle=openformwindow(" InterActive Order Form v1.2 ",&h0B+win_icon,FORM_ABOUT,0,ABOUTOK,VARPTRS(close_aboutdialog))
		END IF
	CASE MENU_NEW
		CALL Initialise2
		FOR i=1 TO NoTitles
			SOFTWARE$(i)="0"+RIGHT$(SOFTWARE$(i),LEN(SOFTWARE$(i))-1)
		NEXT 
		top_item=1
		SelectTree FORM_SOFT
		Sette_ptext SOFT_TALLY,"Items: 0 - Total spent so far: 0.00"
		IF soft_handle>0 THEN
			CALL UPDATE
			Object_Redraw soft_handle,SOFT_TALLY
		END IF
	CASE MENU_OPEN:CALL OPEN_DATA
	CASE MENU_SAVE:CALL SAVE_DATA
	CASE MENU_PRINT
		IF print_handle THEN
			TopAWindow print_handle
		ELSE
			print_handle=openformwindow(" InterActive: Print... ",&h0B+win_icon,FORM_PRINT,P_LPP,P_CANCEL,VARPTRS(close_printdialog))
		END IF
	CASE MENU_QUIT
		finished_flag=-1

	CASE MENU_SOFTWARE
		IF soft_handle THEN
			TopAWindow soft_handle
		ELSE
			REDIM PRESERVE SOFTY$(NoTitles+1)
			FOR i=0 TO NoTitles+1
				SOFTY$(i)=SOFTWARE$(i)
			NEXT
			soft_handle=openformwindow(" InterActive: Select Software... ",&h0B+win_icon,FORM_SOFT,0,SOFT_CANCEL,VARPTRS(close_softdialog))
			SelectTree FORM_SOFT
			SCROLL2 NoTitles,(Getob_height(Soft_Back)/celly),top_item-1,S_SLIDER,S_BACKGROUND
		END IF
	CASE MENU_PERSONNEL
		IF person_handle THEN
			TopAWindow person_handle
		ELSE
			person_handle=openformwindow(" InterActive: Personal Details... ",&h0B+win_icon,FORM_DETAILS,DET_NAME,DET_CANCEL,VARPTRS(close_detdialog))
			SelectTree FORM_DETAILS
			IF MID$(Gette_ptext$(DET_TITLE),3,1)<>"" THEN setob_scut DET_TITLE,MID$(Gette_ptext$(DET_TITLE),3,1)
			IF MID$(Gette_ptext$(DET_COMPUTER),3,1)<>"" THEN setob_scut DET_COMPUTER,MID$(Gette_ptext$(DET_COMPUTER),3,1)
			IF MID$(Gette_ptext$(DET_OS),3,1)<>"" THEN setob_scut DET_OS,MID$(Gette_ptext$(DET_OS),3,1)
		END IF
	CASE MENU_OTHERINFO
		IF other_handle THEN
			TopAWindow other_handle
		ELSE
			other_handle=openformwindow(" InterActive: Other Information... ",&h0B+win_icon,FORM_OTHER,OTHER1,OTHERCANCEL,VARPTRS(close_otherdialog))
		END IF
	CASE MENU_SUMMARY
		CALL SUMMARY2
END SELECT
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Summary2
SHARED tsummary,wolines(),lines$(),summary$(),summary_handle
STATIC top_handle,x,y,w,h,i

CALL SUMMARY
inittextwindows 1,tsummary+1
wolines(0)=tsummary+1
FOR i=0 TO tsummary+1
	lines$(0,i)=SUMMARY$(i)
NEXT
IF summary_handle THEN
	TopAWindow summary_handle
	junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
	junk=wind_get(summary_handle,WF_WORKXYWH,x,y,w,h)
	IF top_handle=summary_handle THEN ReDraw summary_handle,x,y,w,h
ELSE
	summary_handle=opentextwindow(" InterActive: Summary ",1+2+4+8+32+64+128+256)
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_aboutdialog
SHARED commonclose,commonobj,about_handle,person_handle,info_handle

commonclose=0										
SELECT CASE commonobj
	CASE ABOUT_INFO
		Exclob_state commonobj,mask_selected
		Object_Redraw about_handle,commonobj 
		IF info_handle THEN
			TopAWindow info_handle
		ELSE
			info_handle=openformwindow(" InterActive: Cadenza Software ",11,FORM_INFO,0,INFO_OK,VARPTRS(close_infodialog))
		END IF
	CASE ABOUTOK
		commonclose=-1
		about_handle=0
		IF person_handle THEN
			TopAWindow person_handle
		ELSE
			person_handle=openformwindow(" InterActive: Personal Details... ",&h0B+win_icon,FORM_DETAILS,DET_NAME,DET_CANCEL,VARPTRS(close_detdialog))
			SelectTree FORM_DETAILS
			IF MID$(Gette_ptext$(DET_TITLE),3,1)<>"" THEN setob_scut DET_TITLE,MID$(Gette_ptext$(DET_TITLE),3,1)
			IF MID$(Gette_ptext$(DET_COMPUTER),3,1)<>"" THEN setob_scut DET_COMPUTER,MID$(Gette_ptext$(DET_COMPUTER),3,1)
			IF MID$(Gette_ptext$(DET_OS),3,1)<>"" THEN setob_scut DET_OS,MID$(Gette_ptext$(DET_OS),3,1)
		END IF
END SELECT
Object_Redraw about_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_infodialog
SHARED commonclose,commonobj,info_handle

commonclose=0										
SELECT CASE commonobj
	CASE INFO_OK
		commonclose=-1
		info_handle=0
END SELECT
Object_Redraw info_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_softdialog
SHARED commonclose,commonobj,soft_handle,top_item,NoTitles,fee_handle
SHARED edit_fee,SOFTWARE$(),SOFTY$(),celly,other_handle,FEE$(),minh,commonhandle
SHARED edit_item,edit_topitem
STATIC x,y,w,h,x1,y1,w1,h1,outx,outy,i!,i,item,k,Reg_Fee,Reg_Titles
STATIC x2,y2,w2,h2,checkagain,j

commonclose=0										
SELECT CASE commonobj
	CASE SOFT_OK
		commonclose=-1
		soft_handle=0
		IF other_handle THEN
			TopAWindow other_handle
		ELSE
			other_handle=openformwindow(" InterActive: Other Information... ",&h0B+win_icon,FORM_OTHER,OTHER1,OTHERCANCEL,VARPTRS(close_otherdialog))
		END IF
	CASE SOFT_CANCEL
		FOR i=0 TO NoTitles+1
			SOFTWARE$(i)=SOFTY$(i)
		NEXT
		commonclose=-1
		soft_handle=0
	CASE S_ARROWUP
		DO
		DECR top_item
		IF top_item=0 THEN
			top_item=1
			DO
			LOOP UNTIL MOUSE(2)=0
			Setob_state commonobj,0
			Object_Redraw soft_handle,commonobj 
			EXIT SELECT
		END IF
		CALL UPDATE4
		LOOP UNTIL MOUSE(2)=0
		Setob_state commonobj,0
		Object_Redraw soft_handle,commonobj 
	CASE S_ARROWDOWN
		DO
		INCR top_item
		item=(Getob_height(Soft_Back)/celly)
		IF top_item>=NoTitles-(item-2) THEN
			top_item=NoTitles-(item-1)
			DO
			LOOP UNTIL MOUSE(2)=0
			Setob_state commonobj,0
			Object_Redraw soft_handle,commonobj 
			EXIT SELECT
		END IF
		CALL UPDATE3
		LOOP UNTIL MOUSE(2)=0
		Setob_state commonobj,0
		Object_Redraw soft_handle,commonobj 
	CASE S_SLIDER
		SelectTree FORM_SOFT
		junk=objc_offset(tree&,S_SLIDER,x,y)
		junk=objc_offset(tree&,S_BACKGROUND,x1,y1)
		w1=Getob_width(S_BACKGROUND)
		h1=Getob_height(S_BACKGROUND)
		CALL graf_dragbox(Getob_width(S_SLIDER),Getob_height(S_SLIDER),x,y,x1,y1,w1,h1,outx,outy)
		top_item=((outy-y1)/(h1/NoTitles))+1
		CALL UPDATE		
	CASE S_BACKGROUND
		SelectTree FORM_SOFT
		item=(Getob_height(Soft_Back)/celly)
		junk=objc_offset(tree&,S_BACKGROUND,x1,y1)
		w1=Getob_width(S_BACKGROUND)
		h1=Getob_height(S_BACKGROUND)
		top_item=((MOUSE(1)-y1)/(h1/NoTitles))+1
		IF top_item>(NoTitles-(item-2)) THEN top_item=NoTitles-(item-1)
		CALL UPDATE		
	CASE Soft_Back
		SelectTree FORM_SOFT
		junk=objc_offset(tree&,Soft_Back,x1,y1)
		item=0
		FOR i=0 TO (Getob_height(Soft_Back)/celly)-2
			k=MOUSE(1)
			SELECT CASE k
				CASE ((i+1)*celly)+y1 TO ((i+2)*celly)+y1 
					item=i+1:EXIT FOR
			END SELECT
		NEXT
		IF (top_item+item)>NoTitles THEN EXIT SUB
		IF MID$(SOFTWARE$(item+top_item),2,1)=" " THEN EXIT SUB
		IF MID$(SOFTWARE$(item+top_item)+"________________________________________________________",2,42)="__________________________________________" THEN EXIT SUB

		IF LEFT$(SOFTWARE$(item+top_item),1)="0" THEN
			IF RIGHT$(SOFTWARE$(item+top_item),1)="+" THEN
				IF fee_handle THEN
					TopAWindow fee_handle
					EXIT SUB
				ELSE
					SelectTree FORM_FEE
					Exclob_flags FEE_R2,mask_hidetree
					Inclob_flags FEE_R4,mask_hidetree
					Sette_ptext FEE_FEE,""
					edit_fee=(item+top_item)
					edit_item=item
					edit_topitem=top_item
'					SOFTWARE$(item+top_item)="1"+MID$(SOFTWARE$(item+top_item),2,LEN(SOFTWARE$(item+top_item))-1)
'					CALL UPDATE2(item+top_item,item)	
					IF fee_handle THEN
						TopAWindow fee_handle
					ELSE
						fee_handle=openformwindow(" InterActive: Fee... ",11,FORM_FEE,FEE_FEE,FEE_OK,VARPTRS(close_feedialog))
					END IF
					EXIT SUB
				END IF
			ELSE
				SOFTWARE$(item+top_item)="1"+MID$(SOFTWARE$(item+top_item),2,LEN(SOFTWARE$(item+top_item))-1)
				CALL UPDATE2(item+top_item,item)	
			END IF
		ELSE
			SOFTWARE$(item+top_item)="0"+MID$(SOFTWARE$(item+top_item),2,LEN(SOFTWARE$(item+top_item))-1)
			CALL UPDATE2(item+top_item,item)	
		END IF
		i!=TIMER
		DO

		LOOP UNTIL TIMER-i!>=0.2

		Reg_Fee=0
		Reg_Titles=0
		FOR i=1 TO NoTitles 
			IF LEFT$(SOFTWARE$(i),1)="1" THEN
				INCR Reg_Titles
				Reg_Fee=Reg_Fee+VAL(RIGHT$(FEE$(i),5))
			END IF
		NEXT
		SelectTree FORM_SOFT
		Sette_ptext SOFT_TALLY,"Items:"+STR$(Reg_Titles)+" - Total spent so far: "+LTRIM$(RTRIM$(STR$(Reg_Fee)))+".00"
		Object_Redraw soft_handle,SOFT_TALLY
		EXIT SUB
	CASE SOFT_RESIZE
		SelectTree FORM_SOFT
		junk=wind_get(soft_handle,WF_CURRXYWH,x,y,w,h)
		INCR j
		IF j=1 THEN minh=((h-y)-(5*celly))

		x1=Getob_x(0)
		y1=Getob_y(0)
		w1=Getob_width(0)
		h1=Getob_height(0)
		CALL graf_rubberbox(x,y,w,minh,outx,outy)
		outy=(CINT(outy/celly))*celly
'		junk=form_alert(1,"[1][ mh"+STR$(minh)+" y"+STR$(y)+" h"+STR$(h)+" outy"+STR$(outy)+"][ Abort ]")
			IF (top_item+((outy-h)+Getob_height(SOFT_BACK))/celly)>NoTitles THEN
				top_item=(NoTitles-(((outy-h)+Getob_height(SOFT_BACK))/celly))+1
				IF top_item<1 THEN top_item=1
			END IF
		INCR checkagain
		SELECT CASE outy
		CASE h
			EXIT SUB
		CASE >h
			Setob_y SOFT_TALLY,Getob_y(SOFT_TALLY)+(outy-h)
			Setob_y SOFT_OK,Getob_y(SOFT_OK)+(outy-h)
			Setob_y SOFT_CANCEL,(outy-h)+Getob_y(SOFT_CANCEL)
			Setob_y S_ARROWDOWN,(outy-h)+Getob_y(S_ARROWDOWN)
			Setob_y SOFT_RESIZE,(outy-h)+Getob_y(SOFT_RESIZE)
			Setob_height S_BACKGROUND,(outy-h)+Getob_height(S_BACKGROUND)
			IF checkagain=1 THEN
				Setob_height SOFT_BACK,(outy-h)+Getob_height(SOFT_BACK)+4
			ELSE
				Setob_height SOFT_BACK,(outy-h)+Getob_height(SOFT_BACK)
			END IF
			Setob_height SOFT_FORM,(outy-h)+Getob_height(SOFT_FORM)
		CASE <h
			Setob_y SOFT_TALLY,Getob_y(SOFT_TALLY)-(h-outy)
			Setob_y SOFT_OK,Getob_y(SOFT_OK)-(h-outy)
			Setob_y SOFT_CANCEL,Getob_y(SOFT_CANCEL)-(h-outy)
			Setob_y S_ARROWDOWN,Getob_y(S_ARROWDOWN)-(h-outy)
			Setob_y SOFT_RESIZE,Getob_y(SOFT_RESIZE)-(h-outy)
			Setob_height S_BACKGROUND,Getob_height(S_BACKGROUND)-(h-outy)
			IF checkagain=1 THEN
				Setob_height SOFT_BACK,Getob_height(SOFT_BACK)-(h-outy)+4
			ELSE
				Setob_height SOFT_BACK,Getob_height(SOFT_BACK)-(h-outy)
			END IF
			Setob_height SOFT_FORM,Getob_height(SOFT_FORM)-(h-outy)
		END SELECT

		SCROLL2 NoTitles,(Getob_height(Soft_Back)/celly),top_item-1,S_SLIDER,S_BACKGROUND
		commonhandle=soft_handle
		junk=wind_set(soft_handle,WF_CURRXYWH,x,y,w,outy)
		Object_Redraw soft_handle,SOFT_FORM
		Object_Redraw soft_handle,SOFT_OK
		Object_Redraw soft_handle,SOFT_CANCEL
		CALL update
END SELECT
Object_Redraw soft_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_feedialog
SHARED commonclose,commonobj,fee_handle,FEE$(),edit_fee,SOFTWARE$()
SHARED soft_handle,NoTitles,top_item,edit_item,edit_topitem
STATIC Reg_Fee,Reg_Titles,i

SelectTree FORM_FEE
commonclose=0
SELECT CASE commonobj
	CASE FEE_OK
		SOFTWARE$(edit_item+edit_topitem)="1"+MID$(SOFTWARE$(edit_item+edit_topitem),2,LEN(SOFTWARE$(edit_item+edit_topitem))-1)
		CALL UPDATE2(edit_item+edit_topitem,edit_item)	
		IF RIGHT$(SOFTWARE$(edit_fee),1)="+" THEN
			FEE$(edit_fee)=RIGHT$(SOFTWARE$(edit_fee),6)
		ELSE
			FEE$(edit_fee)=RIGHT$(SOFTWARE$(edit_fee),5)
		END IF
		IF Getob_flags(FEE_R4)=1088 THEN
			IF NOT Gette_ptext$(FEE_FEE)="" THEN
				IF VAL(Gette_ptext$(FEE_FEE))>VAL(FEE$(edit_fee)) THEN
					IF VAL(Gette_ptext$(FEE_FEE))<10 THEN
						FEE$(edit_fee)=" "+Gette_ptext$(FEE_FEE)+".00"
					ELSE
						FEE$(edit_fee)=Gette_ptext$(FEE_FEE)+".00"
					END IF
				ELSE
					IF VAL(FEE$(edit_fee))<10 THEN
						FEE$(edit_fee)=" "+MID$(FEE$(edit_fee),2,1)+".00"
					ELSE
						FEE$(edit_fee)=LEFT$(FEE$(edit_fee),2)+".00"
					END IF
				END IF
			ELSE
				IF VAL(FEE$(edit_fee))<10 THEN
					FEE$(edit_fee)=" "+MID$(FEE$(edit_fee),2,1)+".00"
				ELSE
					FEE$(edit_fee)=LEFT$(FEE$(edit_fee),2)+".00"
				END IF
			END IF
		ELSE
			IF VAL(FEE$(edit_fee))<10 THEN
				FEE$(edit_fee)=" "+MID$(FEE$(edit_fee),2,1)+".00"
			ELSE
				FEE$(edit_fee)=LEFT$(FEE$(edit_fee),2)+".00"
			END IF
		END IF
		commonclose=-1
		fee_handle=0
		Reg_Fee=0
		Reg_Titles=0
		FOR i=1 TO NoTitles 
			IF LEFT$(SOFTWARE$(i),1)="1" THEN
				INCR Reg_Titles
				Reg_Fee=Reg_Fee+VAL(RIGHT$(FEE$(i),5))
			END IF
		NEXT
		SelectTree FORM_SOFT
		Sette_ptext SOFT_TALLY,"Items:"+STR$(Reg_Titles)+" - Total spent so far: "+LTRIM$(RTRIM$(STR$(Reg_Fee)))+".00"
		Object_Redraw soft_handle,SOFT_TALLY
	CASE FEE_R1
		Exclob_flags FEE_R2,mask_hidetree
		Inclob_flags FEE_R4,mask_hidetree
		Object_Redraw fee_handle,FEE_R1
		Object_Redraw fee_handle,FEE_R3
	CASE FEE_R3
		Inclob_flags FEE_R2,mask_hidetree
		Exclob_flags FEE_R4,mask_hidetree
		Object_Redraw fee_handle,FEE_R2
		Object_Redraw fee_handle,FEE_R4
	CASE FEE_MINIUM
		IF 1216=Getob_flags(FEE_R2) THEN
			Exclob_flags FEE_R2,mask_hidetree
			Inclob_flags FEE_R4,mask_hidetree
			Object_Redraw fee_handle,FEE_R1
			Object_Redraw fee_handle,FEE_R3
		END IF
		EXIT SUB
	CASE FEE_AMOUNT
		IF 1216=Getob_flags(FEE_R4) THEN
			Inclob_flags FEE_R2,mask_hidetree
			Exclob_flags FEE_R4,mask_hidetree
			Object_Redraw fee_handle,FEE_R2
			Object_Redraw fee_handle,FEE_R4
		END IF
		EXIT SUB
END SELECT
Object_Redraw fee_handle,commonobj
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE
SHARED top_item,NoTitles,SOFTWARE$(),soft_handle,object,celly,commonobj
STATIC wx,wy,ww,wh,x,y,w,h,x1,y1,w1,h1,handle,oldtree&
STATIC a,b,c,d,i

handle=soft_handle
SelectTree FORM_SOFT
junk=wind_get(handle,wf_workxywh,wx,wy,ww,wh)
junk=wind_get(handle,wf_firstxywh,x,y,w,h)
junk=wind_update(beg_update)
WHILE w>0 AND h>0
	CALL vs_clip(1,x,y,x+w,y+h)
		object=0
		junk=objc_offset(tree&,Soft_Back,x1,y1)
		FOR i=0 TO (Getob_height(Soft_Back)/celly)-1
			IF (top_item+i)>NoTitles THEN
				v_gtext x1,y1+((i+1)*celly),LEFT$("__________________________________________________________________",42)
			ELSE
			MOUSE -1
			IF LEFT$(SOFTWARE$(top_item+i),1)="1" THEN
				v_gtext x1,y1+((i+1)*celly),LEFT$("                                                        ",42)
				vswr_mode 4
				v_gtext x1,y1+((i+1)*celly),LEFT$(MID$(SOFTWARE$(top_item+i),2,LEN(SOFTWARE$(top_item+i))-1)+"___________________________________________________",42)
				vswr_mode 1
			ELSE
				v_gtext x1,y1+((i+1)*celly),LEFT$(MID$(SOFTWARE$(top_item+i),2,LEN(SOFTWARE$(top_item+i))-1)+"___________________________________________________",42)
			END IF
			END IF
			MOUSE 0
			INCR object
		NEXT
	CALL vs_clip(0,0,0,0,0)
	junk=wind_get(handle,wf_nextxywh,x,y,w,h)
WEND
SCROLL NoTitles,(Getob_height(Soft_Back)/celly),top_item-1,S_SLIDER,S_BACKGROUND
junk=wind_update(end_update)
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE2(i,item)
SHARED software$(),celly,top_item
STATIC x1,y1,w1,h1

MOUSE -1
junk=objc_offset(tree&,Soft_Back,x1,y1)
w1=Getob_width(Soft_Back)
h1=Getob_height(Soft_Back)
CALL vs_clip(1,x1,y1,x1+w1,y1+h1)
IF LEFT$(SOFTWARE$(i),1)="1" THEN
	v_gtext x1,y1+((item+1)*celly),LEFT$("                                                        ",42)
	vswr_mode 4
	v_gtext x1,y1+((item+1)*celly),LEFT$(MID$(SOFTWARE$(i),2,LEN(SOFTWARE$(i))-1)+"___________________________________________________",42)
	vswr_mode 1
ELSE
	v_gtext x1,y1+((item+1)*celly),LEFT$(MID$(SOFTWARE$(i),2,LEN(SOFTWARE$(i))-1)+"___________________________________________________",42)
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE3
SHARED celly,top_item,source(),dest(),xy(),commonobj,NoTitles
STATIC x,y,w,h

MOUSE -1
SelectTree FORM_SOFT
junk=objc_offset(tree&,Soft_Back,x,y)
w=Getob_width(Soft_Back)
h=Getob_height(Soft_Back)
CALL vs_clip(1,x,y,x+w,y+h)
xy(0)=x
xy(1)=y+celly+1
xy(2)=x+w
xy(3)=y+h
xy(4)=x
xy(5)=y+1
xy(6)=x+w
xy(7)=y+h-celly
CALL vro_cpyfm(3,xy(),VARPTR(source(0)),VARPTR(dest(0)))
CALL vs_clip(0,0,0,0,0)
IF LEFT$(SOFTWARE$(top_item+(h/celly)-1),1)="1" THEN
	v_gtext x,y+(((h/celly))*celly),LEFT$("                                                        ",42)
	vswr_mode 4
	v_gtext x,(y+h),LEFT$(MID$(SOFTWARE$(top_item+(h/celly)-1),2,LEN(SOFTWARE$(top_item+(h/celly)-1))-1)+"___________________________________________________",42)
	vswr_mode 1
ELSE
	v_gtext x,(y+h),LEFT$("                                                        ",42)
	v_gtext x,(y+h),LEFT$(MID$(SOFTWARE$(top_item+(h/celly)-1),2,LEN(SOFTWARE$(top_item+(h/celly)-1))-1)+"___________________________________________________",42)
END IF
SCROLL NoTitles,(Getob_height(Soft_Back)/celly),top_item-1,S_SLIDER,S_BACKGROUND
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB UPDATE4
SHARED celly,top_item,source(),dest(),xy(),commonobj,NoTitles
STATIC x,y,w,h

MOUSE -1
SelectTree FORM_SOFT
junk=objc_offset(tree&,Soft_Back,x,y)
w=Getob_width(Soft_Back)
h=Getob_height(Soft_Back)
CALL vs_clip(1,x,y,x+w,y+h)
xy(0)=x
xy(1)=y
xy(2)=x+w
xy(3)=y+h-celly
xy(4)=x
xy(5)=y+celly
xy(6)=x+w
xy(7)=y+h
CALL vro_cpyfm(3,xy(),VARPTR(source(0)),VARPTR(dest(0)))
IF LEFT$(SOFTWARE$(top_item),1)="1" THEN
	v_gtext x,y+celly,LEFT$("                                                        ",42)
	CALL vs_clip(0,0,0,0,0)
	vswr_mode 4
	v_gtext x,y+celly,LEFT$(MID$(SOFTWARE$(top_item),2,LEN(SOFTWARE$(top_item))-1)+"___________________________________________________",42)
	vswr_mode 1
ELSE
	v_gtext x,y+celly,LEFT$("                                                        ",42)
	CALL vs_clip(0,0,0,0,0)
	v_gtext x,y+celly,LEFT$(MID$(SOFTWARE$(top_item),2,LEN(SOFTWARE$(top_item))-1)+"___________________________________________________",42)
END IF
SCROLL NoTitles,(Getob_height(Soft_Back)/celly),top_item-1,S_SLIDER,S_BACKGROUND
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_detdialog
SHARED commonclose,commonobj,person_handle,soft_handle,SOFTY$(),SOFTWARE$()
SHARED NoTitles,celly,top_item
STATIC res,res$,x,y,i

commonclose=0:res=0
SELECT CASE commonobj
	CASE DET_OK
		commonclose=-1
		person_handle=0
		CALL GET_PERSON
		IF soft_handle THEN
			TopAWindow soft_handle
		ELSE
			REDIM PRESERVE SOFTY$(NoTitles+1)
			FOR i=0 TO NoTitles+1
				SOFTY$(i)=SOFTWARE$(i)
			NEXT
			soft_handle=openformwindow(" InterActive: Select Software... ",&h0B+win_icon,FORM_SOFT,0,SOFT_CANCEL,VARPTRS(close_softdialog))
			SelectTree FORM_SOFT
			SCROLL2 NoTitles,(Getob_height(Soft_Back)/celly),top_item-1,S_SLIDER,S_BACKGROUND
		END IF
	CASE DET_CANCEL
		commonclose=-1
		person_handle=0
		CALL SET_PERSON
	CASE DET_A1
		junk=objc_offset(tree&,DET_TITLE,x,y)
		res=popup(0,POP_TITLE,res,x,y)
		IF res THEN
			SelectTree POP_TITLE
			FOR i=TIT_MR TO TIT_LORD
				IF Curob_state(i,mask_checked)<>0 THEN Exclob_state i,mask_checked
			NEXT
			Inclob_state res,mask_checked
			SelectTree FORM_DETAILS
			res$=get_pop_text$(POP_TITLE,res)
			IF LEN(res$)=0 THEN EXIT SELECT
			sette_ptext DET_TITLE,"  "+res$
			setob_scut DET_TITLE,LEFT$(res$,1)
			Object_Redraw person_handle,DET_TITLE
		END IF
	CASE DET_A2
		junk=objc_offset(tree&,DET_COUNTRY,x,y)
		res=popup(0,POP_COUNTRY,res,x,y)
		IF res THEN
			SelectTree POP_COUNTRY
			FOR i=CO1 TO CO15
				IF Curob_state(i,mask_checked)<>0 THEN Exclob_state i,mask_checked
			NEXT
			Inclob_state res,mask_checked
			SelectTree FORM_DETAILS
			res$=get_pop_text$(POP_COUNTRY,res)
			IF LEN(res$)=0 THEN EXIT SELECT
			sette_ptext DET_COUNTRY,res$
			setob_scut DET_COUNTRY,LEFT$(res$,1)
			Object_Redraw person_handle,DET_COUNTRY
		END IF
	CASE DET_A3
		junk=objc_offset(tree&,DET_COMPUTER,x,y)
		res=popup(0,POP_COMPUTER,res,x,y)
		IF res THEN
			SelectTree POP_COMPUTER
			IF Curob_state(res,mask_checked)<>0 THEN
				Exclob_state res,mask_checked
				res=0
				FOR i=C1 TO C8
					IF Curob_state(i,mask_checked)<>0 THEN res=i:EXIT FOR
				NEXT
			END IF

			IF res=0 THEN
				SelectTree FORM_DETAILS
				sette_ptext DET_COMPUTER,"                "
				Object_Redraw person_handle,DET_COMPUTER
			ELSE
				Inclob_state res,mask_checked
				SelectTree FORM_DETAILS
				res$=get_pop_text$(POP_COMPUTER,res)
				IF LEN(res$)=0 THEN EXIT SELECT
				sette_ptext DET_COMPUTER,"  "+res$
				setob_scut DET_COMPUTER,LEFT$(res$,1)
				Object_Redraw person_handle,DET_COMPUTER
			END IF
		END IF
	CASE DET_A4
		junk=objc_offset(tree&,DET_OS,x,y)
		res=popup(0,POP_OS,res,x,y)
		IF res THEN
			SelectTree POP_OS
			IF Curob_state(res,mask_checked)<>0 THEN
				Exclob_state res,mask_checked
				res=0
				FOR i=OS1 TO OS8
					IF Curob_state(i,mask_checked)<>0 THEN res=i:EXIT FOR
				NEXT
			END IF

			IF res=0 THEN
				SelectTree FORM_DETAILS
				sette_ptext DET_OS,"                "
				Object_Redraw person_handle,DET_OS
			ELSE
				Inclob_state res,mask_checked
				SelectTree FORM_DETAILS
				res$=get_pop_text$(POP_OS,res)
				IF LEN(res$)=0 THEN EXIT SELECT
				sette_ptext DET_OS,"  "+res$
				setob_scut DET_OS,LEFT$(res$,1)
				Object_Redraw person_handle,DET_OS
			END IF
		END IF
	CASE DET_A5
		junk=objc_offset(tree&,DET_DRIVE,x,y)
		res=popup(0,POP_DRIVE,res,x,y)
		IF res THEN
			SelectTree POP_DRIVE
			FOR i=D1 TO D6
				IF Curob_state(i,mask_checked)<>0 THEN Exclob_state i,mask_checked
			NEXT
			Inclob_state res,mask_checked
			SelectTree FORM_DETAILS
			res$=get_pop_text$(POP_DRIVE,res)
			IF LEN(res$)=0 THEN EXIT SELECT
			sette_ptext DET_DRIVE,"  "+res$
			Object_Redraw person_handle,DET_DRIVE
		END IF
	CASE DET_TITLE
		junk=objc_offset(tree&,DET_TITLE,x,y)
		res=popup(0,POP_TITLE,res,x,y)
		IF res THEN
			SelectTree POP_TITLE
			FOR i=TIT_MR TO TIT_LORD
				IF Curob_state(i,mask_checked)<>0 THEN Exclob_state i,mask_checked
			NEXT
			Inclob_state res,mask_checked
			SelectTree FORM_DETAILS
			res$=get_pop_text$(POP_TITLE,res)
			IF LEN(res$)=0 THEN EXIT SELECT
			sette_ptext DET_TITLE,"  "+res$
			setob_scut DET_TITLE,LEFT$(res$,1)
			Object_Redraw person_handle,DET_TITLE
		END IF
	CASE DET_COUNTRY
		junk=objc_offset(tree&,DET_COUNTRY,x,y)
		res=popup(0,POP_COUNTRY,res,x,y)
		IF res THEN
			SelectTree POP_COUNTRY
			FOR i=CO1 TO CO15
				IF Curob_state(i,mask_checked)<>0 THEN Exclob_state i,mask_checked
			NEXT
			Inclob_state res,mask_checked
			SelectTree FORM_DETAILS
			res$=get_pop_text$(POP_COUNTRY,res)
			IF LEN(res$)=0 THEN EXIT SELECT
			sette_ptext DET_COUNTRY,res$
			setob_scut DET_COUNTRY,LEFT$(res$,1)
			Object_Redraw person_handle,DET_COUNTRY
		END IF
	CASE DET_COMPUTER
		junk=objc_offset(tree&,DET_COMPUTER,x,y)
		res=popup(0,POP_COMPUTER,res,x,y)
		IF res THEN
			SelectTree POP_COMPUTER
			IF Curob_state(res,mask_checked)<>0 THEN
				Exclob_state res,mask_checked
				res=0
				FOR i=C1 TO C8
					IF Curob_state(i,mask_checked)<>0 THEN res=i:EXIT FOR
				NEXT
			END IF

			IF res=0 THEN
				SelectTree FORM_DETAILS
				sette_ptext DET_COMPUTER,"                "
				Object_Redraw person_handle,DET_COMPUTER
			ELSE
				Inclob_state res,mask_checked
				SelectTree FORM_DETAILS
				res$=get_pop_text$(POP_COMPUTER,res)
				IF LEN(res$)=0 THEN EXIT SELECT
				sette_ptext DET_COMPUTER,"  "+res$
				setob_scut DET_COMPUTER,LEFT$(res$,1)
				Object_Redraw person_handle,DET_COMPUTER
			END IF
		END IF
	CASE DET_OS
		junk=objc_offset(tree&,DET_OS,x,y)
		res=popup(0,POP_OS,res,x,y)
		IF res THEN
			SelectTree POP_OS
			IF Curob_state(res,mask_checked)<>0 THEN
				Exclob_state res,mask_checked
				res=0
				FOR i=OS1 TO OS8
					IF Curob_state(i,mask_checked)<>0 THEN res=i:EXIT FOR
				NEXT
			END IF

			IF res=0 THEN
				SelectTree FORM_DETAILS
				sette_ptext DET_OS,"                "
				Object_Redraw person_handle,DET_OS
			ELSE
				Inclob_state res,mask_checked
				SelectTree FORM_DETAILS
				res$=get_pop_text$(POP_OS,res)
				IF LEN(res$)=0 THEN EXIT SELECT
				sette_ptext DET_OS,"  "+res$
				setob_scut DET_OS,LEFT$(res$,1)
				Object_Redraw person_handle,DET_OS
			END IF
		END IF
	CASE DET_DRIVE
		junk=objc_offset(tree&,DET_DRIVE,x,y)
		res=popup(0,POP_DRIVE,res,x,y)
		IF res THEN
			SelectTree POP_DRIVE
			FOR i=D1 TO D6
				IF Curob_state(i,mask_checked)<>0 THEN Exclob_state i,mask_checked
			NEXT
			Inclob_state res,mask_checked
			SelectTree FORM_DETAILS
			res$=get_pop_text$(POP_DRIVE,res)
			IF LEN(res$)=0 THEN EXIT SELECT
			sette_ptext DET_DRIVE,"  "+res$
			Object_Redraw person_handle,DET_DRIVE
		END IF
END SELECT
Object_Redraw person_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_otherdialog
SHARED commonclose,commonobj,other_handle
SHARED tsummary,woLines(),summary$(),lines$(),summary_handle
STATIC top_handle,x,y,w,h,i

commonclose=0										
SELECT CASE commonobj
	CASE OTHEROK
		CALL GET_OTHER
		CALL SUMMARY2
		commonclose=-1
		other_handle=0
	CASE OTHERCANCEL
		commonclose=-1
		other_handle=0
		CALL SET_OTHER
	CASE B1
		Exclob_flags B6,mask_hidetree
	CASE B2
		Exclob_flags B7,mask_hidetree
	CASE B3
		Exclob_flags B8,mask_hidetree
	CASE B4
		Exclob_flags B9,mask_hidetree
	CASE B5
		Exclob_flags B10,mask_hidetree
	CASE B6
		Inclob_flags B6,mask_hidetree
	CASE B7
		Inclob_flags B7,mask_hidetree
	CASE B8
		Inclob_flags B8,mask_hidetree
	CASE B9
		Inclob_flags B9,mask_hidetree
	CASE B10
		Inclob_flags B10,mask_hidetree
	CASE O_NONUK
		IF 1216=Getob_flags(B6) THEN 
			Exclob_flags B6,mask_hidetree
		ELSE
			Inclob_flags B6,mask_hidetree
		END IF
		Object_Redraw other_handle,B1
		EXIT SUB
	CASE O_EMAILKEY
		IF 1216=Getob_flags(B7) THEN
			Exclob_flags B7,mask_hidetree
		ELSE
			Inclob_flags B7,mask_hidetree
		END IF
		Object_Redraw other_handle,B2
		EXIT SUB
	CASE O_MASTER
		IF 1216=Getob_flags(B8) THEN
			Exclob_flags B8,mask_hidetree
		ELSE
			Inclob_flags B8,mask_hidetree
		END IF
		Object_Redraw other_handle,B3
		EXIT SUB
	CASE O_STAMP
		IF 1216=Getob_flags(B9) THEN 
			Exclob_flags B9,mask_hidetree
		ELSE
			Inclob_flags B9,mask_hidetree
		END IF
		Object_Redraw other_handle,B4
		EXIT SUB
	CASE O_SEPARATELY
		IF 1216=Getob_flags(B10) THEN 
			Exclob_flags B10,mask_hidetree
		ELSE
			Inclob_flags B10,mask_hidetree
		END IF
		Object_Redraw other_handle,B5
		EXIT SUB
END SELECT
Object_Redraw other_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB close_printdialog
SHARED commonclose,commonobj,print_handle

commonclose=0										
SELECT CASE commonobj
	CASE P_OK
		CALL PRINT_IT
		SelectTree FORM_PRINT
		Setob_state P_OK,0
		Object_Redraw print_handle,P_OK
		EXIT SUB
	CASE P_CANCEL
		commonclose=-1
		print_handle=0
	CASE P_R1
		Exclob_flags P_R2,mask_hidetree:Inclob_flags P_R4,mask_hidetree
		Object_Redraw print_handle,P_R2
		Object_Redraw print_handle,P_R4
		EXIT SUB
	CASE P_R3
		Exclob_flags P_R4,mask_hidetree:Inclob_flags P_R2,mask_hidetree
		Object_Redraw print_handle,P_R2
		Object_Redraw print_handle,P_R4
		EXIT SUB
	CASE P_B1:Exclob_flags P_B2,mask_hidetree
	CASE P_B2:Inclob_flags P_B2,mask_hidetree
	CASE P_ASCII
		IF 1216=Getob_flags(P_R2) THEN
			Exclob_flags P_R2,mask_hidetree:Inclob_flags P_R4,mask_hidetree
			Object_Redraw print_handle,P_R2
			Object_Redraw print_handle,P_R4
			EXIT SUB
		END IF
	CASE P_PRINTER
		IF 1216=Getob_flags(P_R4) THEN
			Exclob_flags P_R4,mask_hidetree:Inclob_flags P_R2,mask_hidetree
			Object_Redraw print_handle,P_R2
			Object_Redraw print_handle,P_R4
			EXIT SUB
		END IF
	CASE P_FF
		IF 1216=Getob_flags(P_B2) THEN 
			Exclob_flags P_B2,mask_hidetree
		ELSE
			Inclob_flags P_B2,mask_hidetree
		END IF
		Object_Redraw print_handle,P_B1
		EXIT SUB
END SELECT
Object_Redraw print_handle,commonobj 
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB SUMMARY
SHARED PERSON$(),OTHER$(),SUMMARY$(),person_handle,other_handle,tsummary
SHARED NoTitles,fee$()
STATIC i,k,temp$,Reg_Titles,Reg_Fee,j

tsummary=0
MOUSE 2
INCR tsummary:SUMMARY$(tsummary)="InterActive order form: Please send this order form to..."
INCR tsummary:SUMMARY$(tsummary)="=========================================================================="
INCR tsummary:SUMMARY$(tsummary)="Address : InterActive: 65 Mill Road, Colchester, Essex, CO4 5LJ, England"
INCR tsummary:SUMMARY$(tsummary)="E-Mail  : jconnor@cix.co.uk"
INCR tsummary:SUMMARY$(tsummary)="Phone   : UK+(0)1206 852602 - and leave a message on the answerphone!"
INCR tsummary:SUMMARY$(tsummary)=""
INCR tsummary:SUMMARY$(tsummary)="Personal details"
INCR tsummary:SUMMARY$(tsummary)="--------------------------------------------------------------------------"
IF person_handle THEN
	SelectTree FORM_DETAILS
	INCR tsummary:SUMMARY$(tsummary)="Name    : "+RTRIM$(LTRIM$(Gette_ptext$(DET_TITLE)))+" "+Gette_ptext$(DET_NAME)
	INCR tsummary:SUMMARY$(tsummary)="Street  : "+Gette_ptext$(DET_STREET)
	INCR tsummary:SUMMARY$(tsummary)="Town    : "+Gette_ptext$(DET_TOWN)
	INCR tsummary:SUMMARY$(tsummary)="Postcode: "+Gette_ptext$(DET_POSTCODE)
	INCR tsummary:SUMMARY$(tsummary)="Country : "+Gette_ptext$(DET_COUNTRY)
	INCR tsummary:SUMMARY$(tsummary)="Phone   : "+Gette_ptext$(DET_PHONE)
	INCR tsummary:SUMMARY$(tsummary)="E-Mail  : "+Gette_ptext$(DET_EMAIL)
ELSE
	INCR tsummary:SUMMARY$(tsummary)="Name    : "+RTRIM$(LTRIM$(PERSON$(1)+" "+PERSON$(2)))
	INCR tsummary:SUMMARY$(tsummary)="Street  : "+PERSON$(3)
	INCR tsummary:SUMMARY$(tsummary)="Town    : "+PERSON$(4)
	INCR tsummary:SUMMARY$(tsummary)="Postcode: "+PERSON$(5)
	INCR tsummary:SUMMARY$(tsummary)="Country : "+PERSON$(6)
	INCR tsummary:SUMMARY$(tsummary)="Phone   : "+PERSON$(7)
	INCR tsummary:SUMMARY$(tsummary)="E-Mail  : "+PERSON$(8)
END IF
INCR tsummary:SUMMARY$(tsummary)=""
INCR tsummary:SUMMARY$(tsummary)="Software required              Version   Reg. Fee"
INCR tsummary:SUMMARY$(tsummary)="--------------------------------------------------------------------------"
Reg_Fee=0
Reg_Titles=0
FOR i=1 TO NoTitles 
	IF LEFT$(SOFTWARE$(i),1)="1" THEN
		INCR Reg_Titles
		temp$=MID$(SOFTWARE$(i),2,LEN(SOFTWARE$(i))-1)
		FOR k=1 TO LEN(temp$)
			IF MID$(temp$,k,1)="_" THEN MID$(temp$,k,1)=" "
		NEXT
		INCR tsummary:SUMMARY$(tsummary)=LEFT$(temp$,25)+"       "+MID$(temp$,26,10)+""+fee$(i)
		Reg_Fee=Reg_Fee+VAL(RIGHT$(fee$(i),5))
	END IF
NEXT
IF Reg_Titles>0 THEN
	INCR tsummary:SUMMARY$(tsummary)="-------------------------------------------------"
	IF Reg_Fee<10 THEN 
		IF Reg_Fee>0 THEN INCR tsummary:SUMMARY$(tsummary)="                                   Total:  "+RTRIM$(LTRIM$(STR$(Reg_fee)))+".00 (Sterling)"
	ELSE
		INCR tsummary:SUMMARY$(tsummary)="                                   Total: "+RTRIM$(LTRIM$(STR$(Reg_fee)))+".00 (Sterling)"
	END IF
ELSE
	INCR tsummary:SUMMARY$(tsummary)=""
END IF
INCR tsummary:SUMMARY$(tsummary)="--------------------------------------------------------------------------"
INCR tsummary:SUMMARY$(tsummary)=""
INCR tsummary:SUMMARY$(tsummary)="Where did you hear about InterActive?"
INCR tsummary:SUMMARY$(tsummary)="--------------------------------------------------------------------------"
IF other_handle THEN
	SelectTree FORM_OTHER
	INCR tsummary:SUMMARY$(tsummary)=Gette_ptext$(OTHER1)+" "+Gette_ptext$(OTHER2)
	INCR tsummary:SUMMARY$(tsummary)=Gette_ptext$(OTHER3)
ELSE
	INCR tsummary:SUMMARY$(tsummary)=OTHER$(1)+" "+OTHER$(2)
	INCR tsummary:SUMMARY$(tsummary)=OTHER$(3)
END IF
INCR tsummary:SUMMARY$(tsummary)=""
INCR tsummary:SUMMARY$(tsummary)="System"
INCR tsummary:SUMMARY$(tsummary)="--------------------------------------------------------------------------"
j=0
SelectTree POP_COMPUTER
FOR i=C1 TO C8
	IF Curob_state(i,mask_checked)<>0 THEN
		INCR j
		IF j=1 THEN INCR tsummary:SUMMARY$(tsummary)="        Computer(s): "+RTRIM$(LTRIM$(Gette_ptext$(i)))
		IF j>1 THEN INCR tsummary:SUMMARY$(tsummary)="                     "+RTRIM$(LTRIM$(Gette_ptext$(i)))
	END IF
NEXT

j=0
SelectTree POP_OS
FOR i=OS1 TO OS8
	IF Curob_state(i,mask_checked)<>0 THEN
		INCR j
		IF j=1 THEN INCR tsummary:SUMMARY$(tsummary)="Operating System(s): "+RTRIM$(LTRIM$(Gette_ptext$(i)))
		IF j>1 THEN INCR tsummary:SUMMARY$(tsummary)="                     "+RTRIM$(LTRIM$(Gette_ptext$(i)))
	END IF
NEXT

IF person_handle THEN
	SelectTree FORM_DETAILS
	INCR tsummary:SUMMARY$(tsummary)="              Drive: "+RTRIM$(LTRIM$(Gette_ptext$(DET_DRIVE)))
ELSE
	INCR tsummary:SUMMARY$(tsummary)="              Drive: "+RTRIM$(LTRIM$(PERSON$(11)))
END IF

INCR tsummary:SUMMARY$(tsummary)=""
INCR tsummary:SUMMARY$(tsummary)="Summary"
INCR tsummary:SUMMARY$(tsummary)="--------------------------------------------------------------------------"
IF other_handle THEN
	SelectTree FORM_OTHER
	IF Getob_flags(B6)=1088 THEN INCR tsummary:SUMMARY$(tsummary)="[*] Non-UK destination - 1 P&P added":INCR Reg_Fee
	IF Getob_flags(B7)=1088 THEN INCR tsummary:SUMMARY$(tsummary)="[*] Please E-Mail me any keys/details."
	IF Getob_flags(B8)=1088 THEN INCR tsummary:SUMMARY$(tsummary)="[*] I do not require any Master disk/s."
	IF Getob_flags(B9)=1088 THEN INCR tsummary:SUMMARY$(tsummary)="[*] I enclose a SAE & disk/s for upgrade/s."
	IF Getob_flags(B10)=1088 THEN INCR tsummary:SUMMARY$(tsummary)="[*] My payment is to arrive separately."
ELSE
	IF OTHER$(4)="ok" THEN INCR tsummary:SUMMARY$(tsummary)="[*] Non-UK destination - 1 P&P added":INCR Reg_Fee
	IF OTHER$(5)="ok" THEN INCR tsummary:SUMMARY$(tsummary)="[*] Please E-Mail me any keys/details."
	IF OTHER$(6)="ok" THEN INCR tsummary:SUMMARY$(tsummary)="[*] I do not require any Master disk/s."
	IF OTHER$(7)="ok" THEN INCR tsummary:SUMMARY$(tsummary)="[*] I enclose a SAE & disk/s for upgrade/s."
	IF OTHER$(8)="ok" THEN INCR tsummary:SUMMARY$(tsummary)="[*] My payment is to arrive separately."
END IF
INCR tsummary:SUMMARY$(tsummary)=""
IF Reg_Titles>1 THEN
	INCR tsummary:SUMMARY$(tsummary)="I wish to register the"+STR$(Reg_Titles)+" software titles named above, at the total cost"
	INCR tsummary:SUMMARY$(tsummary)="of "+RTRIM$(LTRIM$(STR$(Reg_fee)))+".00 (Sterling) including P&P for which I enclose payment."
ELSE
	IF Reg_Titles=1 THEN
		INCR tsummary:SUMMARY$(tsummary)="I wish to register the"+STR$(Reg_Titles)+" software title named above, at the total cost"
		INCR tsummary:SUMMARY$(tsummary)="of "+RTRIM$(LTRIM$(STR$(Reg_fee)))+".00 (Sterling) including P&P for which I enclose payment."
	END IF
END IF
INCR tsummary:SUMMARY$(tsummary)="=========================================================================="
INCR tsummary:SUMMARY$(tsummary)="These details will be stored electronically. Your entry is available for"
INCR tsummary:SUMMARY$(tsummary)="inspection on request under the provisions of the UK Data Protection Act."
INCR tsummary:SUMMARY$(tsummary)=""
INCR tsummary:SUMMARY$(tsummary)="Produced using IOFG v1.2 - Copyright 1997 Cadenza Software."
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB PRINT_IT
SHARED tsummary,SUMMARY$()
STATIC i,LPP,MARGIN,create_handle,delete_handle,k,button

SelectTree FORM_PRINT
LPP=VAL(Gette_ptext$(P_LPP))
MARGIN=VAL(Gette_ptext$(P_MARGIN))
MOUSE 2
CALL SUMMARY
SelectTree FORM_PRINT
IF Curob_flags(P_R4,mask_hidetree)=0 THEN
	k=0
	FOR i=1 TO tsummary
		INCR k
		MOUSE 2
		DO
		IF bcostat(0)=0 THEN
			BUTTON=form_alert(1,"[1][  InterActive:|  Please turn your printer |  ON LINE! | ][ Continue | Cancel ]")
			SELECT CASE BUTTON
				CASE 2
					MOUSE 0
					EXIT SUB
			END SELECT
		END IF
		LOOP UNTIL bcostat(0)<>0
		MOUSE 0

		LPRINT STRING$(MARGIN," ")+SUMMARY$(i)
		IF Curob_flags(P_B2,mask_hidetree)=0 THEN IF k=lpp THEN LPRINT CHR$(12):k=0
	NEXT
	LPRINT CHR$(12)
ELSE
	IF FEXISTS(CURDIR$+"\ORDERFRM.TXT") THEN
		delete_handle=fdelete(CURDIR$+"\ORDERFRM.TXT")
		IF delete_handle<0 THEN GOTO ERROR_HANDLER
	END IF
	create_handle=fcreate(CURDIR$+"\ORDERFRM.TXT",2)
	IF create_handle<0 THEN GOTO ERROR_HANDLER
	junk=fclose(create_handle)
	OPEN CURDIR$+"\ORDERFRM.TXT" FOR OUTPUT AS #1
		FOR i=1 TO tsummary
			PRINT #1,SUMMARY$(i)
		NEXT
	CLOSE #1
END IF
MOUSE 0
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

Startprogram CURDIR$+"\INTRACTV.RSC",MENU1,-1
Initialise
CALL OPEN_DATA
CALL LOAD_SOFT
about_handle=openformwindow(" InterActive Order Form v1.2 ",&h0B+win_icon,FORM_ABOUT,0,ABOUTOK,VARPTRS(close_aboutdialog))
CALL DisplayBubbleGEM("Welcome to the InterActive Order Form Generator!  IOFG v1.2 has been designed to make the registration of software via InterActive even easier! | Enjoy!")

RETURN_HANDLER:
ON ERROR GOTO ERROR_HANDLER
CALL xHGTloop2
CALL DisplayBubbleGEM("Goodbye! Thank you for using IOFG!")
StopProgram

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB DisplayBubbleGEM(message$)
STATIC dummy$,dummy&,message&,id

dummy$=SPACE$(16)
dummy&=VARPTR(dummy$)
message$=LEFT$(message$,255)+CHR$(0) 
message&=VARPTR(message$)
id=appl_find("BUBBLE  ")
IF id<>-1 THEN
	POKEW dummy&,&HBABB
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&+4,0
	POKEW dummy&+6,MOUSE(0)
	POKEW dummy&+8,MOUSE(1)
	POKEL dummy&+10,message&
	POKEW dummy&+14,0
	appl_write id,16,dummy&
END IF
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB ProcessClicks2(button,x,y)
SHARED about_handle,person_handle,soft_handle,fee_handle,other_handle,print_handle
STATIC TOP_HANDLE,oldtree&,object

oldtree&=tree&
junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
SELECT CASE top_handle
	CASE about_handle
		SelectTree FORM_ABOUT
		object=objc_find(tree&,BASEABOUT,100,x,y)
		SELECT CASE object
			CASE ABOUT_INFO:CALL DisplayBubbleGEM("If you click here, details of how to contact Cadenza Software will be displayed.")
			CASE ABOUTOK:CALL DisplayBubbleGEM("If you click here, you will move along the wizard!")
		END SELECT
	CASE person_handle
		SelectTree FORM_DETAILS
		object=objc_find(tree&,BASEDETAILS,100,x,y)
		SELECT CASE object
			CASE DET_OK:CALL DisplayBubbleGEM("If you click here, you will move along the wizard!, are all your personal details correct?")
			CASE DET_CANCEL:CALL DisplayBubbleGEM("If you click here, this dialog will disappear and IOFG will forget any changes you may have made!")
		END SELECT
	CASE soft_handle
		SelectTree FORM_SOFT
		object=objc_find(tree&,SOFT_FORM,100,x,y)
		SELECT CASE object
			CASE SOFT_OK:CALL DisplayBubbleGEM("If you click here, you will move along the wizard!, have you selected all the software titles you require?")
			CASE SOFT_CANCEL:CALL DisplayBubbleGEM("If you click here, this dialog will disappear and IOFG will forget any changes you may have made!")
			CASE SOFT_RESIZE:CALL DisplayBubbleGEM("By clicking here with your left mouse button and dragging, this window may be increased/decreased in size!")
			CASE SOFT_TALLY:CALL DisplayBubbleGEM("This displays the total amount payable for registration of the software titles selected.")
		END SELECT
	CASE fee_handle
		SelectTree FORM_FEE
		object=objc_find(tree&,BASEFEE,100,x,y)
		SELECT CASE object
			CASE FEE_OK:CALL DisplayBubbleGEM("By clicking here, you accept the registration fee selected.")
			CASE FEE_MINIUM:CALL DisplayBubbleGEM("By clicking here, you will only pay the minimum registration fee for the software title in question.")
			CASE FEE_AMOUNT:CALL DisplayBubbleGEM("By clicking here, you may enter your own chosen registration fee for the software title in question (more NOT less than the minimum fee required!)")
		END SELECT
	CASE other_handle
		SelectTree FORM_OTHER
		object=objc_find(tree&,BASEOTHER,100,x,y)
		SELECT CASE object
			CASE OTHEROK:CALL DisplayBubbleGEM("If you click here, you will move along the wizard!, are all your details correct?")
			CASE OTHERCANCEL:CALL DisplayBubbleGEM("If you click here, this dialog will disappear and IOFG will forget any changes you may have made!")
			CASE O_NONUK:CALL DisplayBubbleGEM("Click here if you live outside of the United Kingdom.")
			CASE O_EMAILKEY:CALL DisplayBubbleGEM("Click here if you would like your registration details/keys sent to you via email.")
			CASE O_MASTER:CALL DisplayBubbleGEM("Click here if you do not require master disk/s.")
			CASE O_STAMP:CALL DisplayBubbleGEM("Click here if you have enclosed a SAE & disk/s for upgrades.")
			CASE O_SEPARATELY:CALL DisplayBubbleGEM("Click here if payment for your registration/s is to arrive seperately.")
		END SELECT
	CASE print_handle
		SelectTree FORM_PRINT
		object=objc_find(tree&,BASEPRINT,100,x,y)
		SELECT CASE object
			CASE P_OK:CALL DisplayBubbleGEM("Click here to print your order form to the output selected.")
			CASE P_CANCEL:CALL DisplayBubbleGEM("If you click here, this dialog will disappear and IOFG will forget any changes you may have made!")
			CASE P_ASCII:CALL DisplayBubbleGEM("By clicking here, your chosen output will be an ASCII file on disk.")
			CASE P_PRINTER:CALL DisplayBubbleGEM("By clicking here, your chosen output will be your printer.")
			CASE P_FF:CALL DisplayBubbleGEM("Click here to send a from feed after each page.")
		END SELECT
END SELECT
tree&=oldtree&
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB xHGTloop2
STATIC ev,key_pressed,clicks,x,y,kstate,button,w,h
STATIC mclicks,mmask,mstate,message,y,top_handle,item
SHARED finished_flag,Mess(1),clicks_enabled,keys_enabled,menus_enabled,forms_enabled
SHARED mouse_detect_both,summary_handle,commonclose,soft_handle,fee_handle
SHARED about_handle,person_handle,other_handle,print_handle,curline,tsummary,celly,leave
SHARED top_item,NoTitles,object

REDIM PRESERVE mess(7)
'IF mouse_detect_both THEN
	mclicks=258
	mmask=3
	mstate=0
'ELSE
'	mclicks=2
'	mmask=1
'	mstate=1
'END IF	

 finished_flag=0
 DO
	key_pressed=0
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
		SELECT CASE key_pressed
			CASE=18432:EXIT SELECT
			CASE=20480:EXIT SELECT
			CASE=18488:EXIT SELECT
			CASE=20530:EXIT SELECT
			CASE ELSE
				IF CHR$(key_pressed AND 255)=" " THEN EXIT SELECT
				KeyboardEvent key_pressed,kstate
				EXIT IF
		END SELECT

		junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
		SELECT CASE top_handle
			CASE print_handle

			CASE about_handle

			CASE summary_handle
				junk=wind_get(summary_handle,WF_VSLIDE,y,junk,junk,junk)
				SELECT CASE kstate
					CASE 0
						IF key_pressed=18432 THEN IF NOT y=1 THEN CALL WindowArrowed2(summary_handle,WA_UPLINE)
						IF key_pressed=20480 THEN IF NOT y=1000 THEN CALL WindowArrowed2(summary_handle,WA_DNLINE)
					CASE 1 TO 2
						IF key_pressed=18488 THEN IF NOT y=1 THEN mess(0)=wm_arrowed:mess(3)=summary_handle:mess(4)=WA_UPPAGE:do_message
						IF key_pressed=20530 THEN IF NOT y=1000 THEN mess(0)=wm_arrowed:mess(3)=summary_handle:mess(4)=WA_DNPAGE:do_message
				END SELECT
			CASE soft_handle
				SelectTree FORM_SOFT
				SELECT CASE kstate
					CASE 0
						IF key_pressed=18432 THEN 
							DECR top_item
							IF top_item=0 THEN
								top_item=1
								EXIT SELECT
							END IF
							Setob_state S_ARROWUP,1
							object_Redraw soft_handle,S_ARROWUP
							CALL UPDATE4
							Setob_state S_ARROWUP,0
							object_Redraw soft_handle,S_ARROWUP
						END IF
						IF key_pressed=20480 THEN 
							INCR top_item
							item=(Getob_height(Soft_Back)/celly)
							IF top_item>=NoTitles-(item-2) THEN
								top_item=NoTitles-(item-1)
								EXIT SELECT
							END IF
							Setob_state S_ARROWDOWN,1
							object_Redraw soft_handle,S_ARROWDOWN
							CALL UPDATE3
							Setob_state S_ARROWDOWN,0
							object_Redraw soft_handle,S_ARROWDOWN
						END IF
				END SELECT
			CASE ELSE
				KeyboardEvent key_pressed,kstate
		END SELECT
	END IF

	IF ev AND MU_MESAG THEN
		message=mess(0)
		leave=0
		SELECT CASE message 
			CASE wm_closed
				IF mess(3)=summary_handle THEN
					commonclose=-1:summary_handle=0
					button=form_alert(1,"[2][  InterActive: |  Are these details correct? ][ Yes | No ]")
				END IF
			CASE wm_arrowed
				junk=wind_get(summary_handle,9,y,junk,junk,junk)
				IF mess(4)=2 THEN IF y=1 THEN leave=1
				IF mess(4)=3 THEN IF y=1000 THEN leave=1
				WindowArrowed2 mess(3),mess(4)
		END SELECT
		IF leave=0 THEN
		do_message
		message=mess(0)
		SELECT CASE message 
			CASE wm_closed
				IF mess(3)=summary_handle THEN
					junk=wind_get(junk,WF_TOP,top_handle,junk,junk,junk)
					SELECT CASE button
						CASE 1:processusermenus top_handle,MENU_PRINT,16
						CASE 2:processusermenus top_handle,MENU_ABOUT,16
					END SELECT
				END IF
			CASE wm_redraw
				IF mess(3)=soft_handle THEN CALL UPDATE
			CASE wm_sized
				IF mess(3)=summary_handle THEN WindowArrowed2 mess(3),mess(4)
			CASE wm_fulled
				IF mess(3)=summary_handle THEN WindowArrowed2 mess(3),mess(4)
			CASE wm_iconify
				top_handle=mess(3)
				RenameWindow mess(3),"inactive"
				SELECT CASE top_handle
					CASE about_handle
						SelectTree FORM_ABOUT:Exclob_flags ABOUT_ICON,mask_hidetree
					CASE print_handle
						SelectTree FORM_PRINT:Exclob_flags PRINT_ICON,mask_hidetree
					CASE person_handle
						SelectTree FORM_DETAILS:Exclob_flags DET_ICON,mask_hidetree
					CASE soft_handle
						SelectTree FORM_SOFT:Exclob_flags SOFT_ICON,mask_hidetree
					CASE other_handle
						SelectTree FORM_OTHER:Exclob_flags OTHER_ICON,mask_hidetree
				END SELECT
				junk=wind_set(mess(3),wf_iconify,mess(4),mess(5),mess(6),mess(7))
			CASE wm_uniconify
				top_handle=mess(3)
				SELECT CASE top_handle
					CASE about_handle
						RenameWindow mess(3)," InterActive Order Form v1.2 "
						SelectTree FORM_ABOUT:Inclob_flags ABOUT_ICON,mask_hidetree
					CASE print_handle
						RenameWindow mess(3)," InterActive: Print... "
						SelectTree FORM_PRINT:Inclob_flags PRINT_ICON,mask_hidetree
					CASE person_handle
						RenameWindow mess(3)," InterActive: Personal Details... "
						SelectTree FORM_DETAILS:Inclob_flags DET_ICON,mask_hidetree
					CASE soft_handle
						RenameWindow mess(3)," InterActive: Select Software... "
						SelectTree FORM_SOFT:Inclob_flags SOFT_ICON,mask_hidetree
					CASE other_handle
						RenameWindow mess(3)," InterActive: Other Information... "
						SelectTree FORM_OTHER:Inclob_flags OTHER_ICON,mask_hidetree
				END SELECT
				junk=wind_set(mess(3),wf_uniconify,mess(4),mess(5),mess(6),mess(7))
		END SELECT
		END IF
	END IF
	IF ev AND MU_BUTTON THEN
		IF BUTTON=2 THEN
			CALL ProcessClicks2(button,x,y)
		ELSE
			IF forms_enabled THEN
				IF NOT ProcessFormClicks(button,clicks,kstate,x,y) THEN
					IF clicks_enabled THEN 	ProcessClicks clicks,kstate,x,y
				END IF
			ELSE
				IF clicks_enabled THEN 	ProcessClicks clicks,kstate,x,y
			END IF
		END IF
	END IF
LOOP UNTIL finished_flag
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ERROR_HANDLER:
MOUSE 2
button=form_alert(1,"[1][  InterActive: |  An ERROR"+STR$(ERR)+" has occurred! |  Try to tolerate or abort |  program? | ][ Tolerate | Abort ]")
SELECT CASE button
	CASE 2
		junk=rsrc_free
		SYSTEM
END SELECT
MOUSE 0
GOTO RETURN_HANDLER

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
