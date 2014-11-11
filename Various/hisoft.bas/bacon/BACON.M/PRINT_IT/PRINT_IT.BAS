'===========================================================================
'                Print IT v1.00 - Written by Matthew Bacon
'                      Copyright ½ Matthew Bacon 1996
'===========================================================================
' include the file TOOLBOX.T as the PRE-TOKENISED file !.
'===========================================================================

' Start --------------------------------------------------------------------

DEFINT a-z
' Stop default GEM window from opening
'$option k100,y
' Allows the arrays to be redimed
'$DYNAMIC

' Create Message, Printer driver, Text, Default Info. arrays
DIM SHARED mess(7),PRINTER_DRIVER$(0),TEXT$(0),DEFAULT$(0)

MOUSE 2
' If resource file does not exist, then display alert message
IF rsrc_load(CURDIR$+"\PRINT_IT.RSC")=0 THEN
	junk=form_alert(1,"[1][ |  Error while loading |  resource file. | ][ Abort ]")
	MOUSE 0
	SYSTEM
END IF


' Start Set default settings -----------------------------------------------

' Set General default settings
fspath$=CURDIR$+"\*.*"
fsname$=""
FileSelect$=""
PDRIVER_PATH$=CURDIR$+"\PRINTER.PIT"
PDRIVER_NAME$="PRINTER.PIT"
PDRIVER_DEFAULT$=CURDIR$+"\PRINTER.PIT"
VIEWER$=""

' Call sub-program to load Misc. Information
CALL LOAD_DEFAULT(CURDIR$+"\PRINT_IT.INF")

' Call sub-program "LOAD_PDRIVER" to load default printer driver 
CALL LOAD_PDRIVER(PDRIVER_DEFAULT$)
IF PRINTER_FLAG=1 THEN SYSTEM

' Set Page Attribute default settings
SelectTree FORM_PAGE
FROMPAGE$="01"
TOPAGE$="99"
LINESPP$="60"
LMARGIN$="08"
RMARGIN$="00"
NOCOPIES$="01"
PRINTALL_STATUS=1
FORMFEED_STATUS=1
CALL RESET_PAGE

' Set Header Attribute default settings
SelectTree FORM_HEADER
HEADER_LQSTATUS=1
HEADER_FONT1STATUS=1
HEADER_MESSAGE$=""
HEADER_LEFTSTATUS=1
CALL RESET_HEADER

' Set Footer Attribute default settings
SelectTree FORM_FOOTER
FOOTER_LQSTATUS=1
FOOTER_FONT1STATUS=1
FOOTER_MESSAGE$=""
FOOTER_LEFTSTATUS=1
CALL RESET_FOOTER

' Set Text Attribute default settings
SelectTree FORM_TEXT
LQ_STATUS=1
FONT1_STATUS=1
TEXT_LEFTSTATUS=1
CALL RESET_TEXT

' Set Misc. Attribute default settings
SelectTree FORM_MISC
LOAD_TEXT$=""
Sette_ptext MISC_FILE,LOAD_TEXT$
FILE_NOLINES$=""
Sette_ptext MISC_NOLINES,FILE_NOLINES$
FILE_NOPAGES$=""
Sette_ptext MISC_NOPAGES,FILE_NOPAGES$

i=LEN(PDRIVER_DEFAULT$)
DO
    IF PDRIVER_DEFAULT$="" THEN EXIT LOOP
    IF MID$(PDRIVER_DEFAULT$,i,1)="\" THEN EXIT LOOP
    IF i=1 THEN EXIT LOOP
    DECR i
LOOP 
Sette_ptext MISC_PDRIVER,RIGHT$(PDRIVER_DEFAULT$,LEN(PDRIVER_DEFAULT$)-i)

i=LEN(VIEWER$)
DO
    IF VIEWER$="" THEN EXIT LOOP
    IF MID$(VIEWER$,i,1)="\" THEN EXIT LOOP
    IF i=1 THEN EXIT LOOP
    DECR i
LOOP 
Sette_ptext MISC_VIEWER,RIGHT$(VIEWER$,LEN(VIEWER$)-i)
MOUSE 0

' End default settings -----------------------------------------------------


' Select and enable the menubar
SelectTree MENU1
menu_bar tree&,1

START_HANDLER:
' If an error occurs in the program report it
ON ERROR GOTO ERROR_HANDLER
DO
	' Wait for message
	evnt_mesag VARPTR(mess(0))
	' Handle message
	do_message
LOOP UNTIL QUIT_FLAG

' Erase arrays
ERASE mess,PRINTER_DRIVER$,TEXT$,DEFAULT$

' Disable menubar & free resource from memory then quit
SelectTree MENU1
menu_bar tree&,0
junk=rsrc_free
SYSTEM


' General sub-programs -----------------------------------------------------

' Programs main loop
SUB do_message
SHARED tree&,QUIT_FLAG,LOAD_TEXT$,VIEWER$,PDRIVER_PATH$,fsname$,FileSelect$
STATIC item,res,BUTTON,i

IF mess(0)=MN_SELECTED THEN
	item=mess(4)
	SELECT CASE item
	    CASE MENU_ABOUT:
		    ' Display About dialogue box
		    SelectTree FORM_ABOUT
		    res=handledialog(0)
		CASE MENU_LOAD:
			' Call sub-program to load file into memory
			CALL LOAD_TEXT
		CASE MENU_VIEW:
			IF LOAD_TEXT$<>"" THEN
				' Call sub-program to execute viewer and to view the 
				' text file selected
				CALL VIEW_FILE
			ELSE
				junk=form_alert(1,"[1][ |  Error, no text file has yet |  been loaded. | ][ Abort ]")
			END IF
		CASE MENU_PRINT:
			IF LOAD_TEXT$<>"" THEN
			' Call sub-program to send control codes and print text
				CALL PRINT_IT
			ELSE
				junk=form_alert(1,"[1][ |  Error, no text file has yet |  been loaded. | ][ Abort ]")
			END IF
		CASE MENU_QUIT:
			' Ask user for confirmation before quitting
			BUTTON=form_alert(2,"[3][ |  Do you really want to quit ? | ][ Quit | Cancel ]")
			SELECT CASE BUTTON
				CASE 1
					' Quit after all
					QUIT_FLAG=-1
			END SELECT
		CASE MENU_PAGE:
			' Display Page Attributes dialogue box
			SelectTree FORM_PAGE
			res=handledialog(PAGE_FROMPAGE)
			' Call sub-program to respond to dialogue result
			CALL PAGE(res)
		CASE MENU_TEXT:
			' Display Text Attributes dialogue box
			SelectTree FORM_TEXT
			res=handledialog(0)
			' Call sub-program to respond to dialogue result
			CALL TEXT(res)
		CASE MENU_MISC:
			' Display Misc. Attributes dialogue box
			SelectTree FORM_MISC
			res=handledialog(0)
			' Call sub-program to respond to dialogue result
			CALL MISC(res)
		CASE MENU_HEADER
			' Display Header Attributes dialogue box
			SelectTree FORM_HEADER
			res=handledialog(0)
			' Call sub-program to respond to dialogue result
			CALL HEADER(res)
		CASE MENU_FOOTER
			' Display Footer Attributes dialogue box
			SelectTree FORM_FOOTER
			res=handledialog(0)
			' Call sub-program to respond to dialogue result
			CALL FOOTER(res)
		CASE MENU_LOADPDRIVER
			' Call FileSelector
			CALL FileSelect$(CURDIR$+"\*.PIT",fsname$)
			' Check the file passed by File Selector is not a null string, otherwise 
			' exit sub program
			IF fsname$<>"" THEN
				' Call sub-program "LOAD_PDRIVER" to load printer driver ASCII commands
				' file "PRINTER.PIT" or file designated in the information file using
				' (.PIT - PRINT IT extension)
				CALL LOAD_PDRIVER(FileSelect$)
			END IF
		CASE MENU_TEST:
			' Call sub-program "ONLINE", Is the printer online ?
			CALL ONLINE
			' Call sub-program to test printer
			CALL TEST
		CASE MENU_FORMFEED:
			' Call sub-program "ONLINE", Is the printer online ?
			CALL ONLINE
			' Call sub-program to formfeed page in printer
			CALL FORMFEED
		CASE MENU_RESET:
			' Call sub-program "ONLINE", Is the printer online ?
			CALL ONLINE
			' Call sub-program to reset default settings in printer
			CALL RESET_PRINTER
	END SELECT
	MOUSE 0
	' Make menubar normal
	SelectTree MENU1
	menu_tnormal tree&,mess(3),1
END IF
END SUB


' File selector handler
SUB FileSelect$(fspath$,fsname$)
SHARED fspath$,fsname$,FileSelect$
STATIC ok,i,ch

MOUSE 2 
IF fspath$="" THEN 
	fspath$=CURDIR$+"\*.*"
END IF

fsname$=""
fsel_input fspath$,fsname$,ok

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
	fspath$=""
	fsname$=""
END IF
MOUSE 0
END SUB


' Check printer is ready to receive data
SUB ONLINE
STATIC BUTTON

' Is the printer ready to receive data
IF bcostat(0)=0 THEN
	' If not, display alert
	BUTTON=form_alert(1,"[1][ |  Please turn your printer |  ON LINE! | ][ Continue | Cancel ]")
	SELECT CASE BUTTON
		CASE 1
			' Try again
			CALL ONLINE
		CASE 2
			SelectTree MENU1
			menu_tnormal tree&,mess(3),1
			' Go back to main loop
			GOTO START_HANDLER
	END SELECT
END IF
END SUB


' Load sub-programs --------------------------------------------------------

' Load a text file from disk into memory
SUB LOAD_TEXT
SHARED LOAD_TEXT$,TEXT_NOLINES$,TEXT_NOPAGES$,LINESPP$
SHARED FileSelect$,fsname$,FILE_NOLINES$,FILE_NOPAGES$,EXTRA_LINES
STATIC i

' Call FileSelector
CALL FileSelect$(CURDIR$+"\*.DOC",fsname$)

MOUSE 2
IF fsname$<>"" THEN
	IF FEXISTS(FileSelect$) THEN
		LOAD_TEXT$=FileSelect$
		i=0
		REDIM TEXT$(i)

		' Open file to channel 1
		OPEN LOAD_TEXT$ FOR INPUT AS #1
		DO
			' If memory runs out then load no more lines
			IF FRE(0)<3000 THEN EXIT LOOP
			' Incr line
			INCR i
			REDIM PRESERVE TEXT$(i)
			' Input line by line 
			LINE INPUT #1,TEXT$(i)
			' Loop until end of file and close channel
		LOOP UNTIL EOF(1)
		CLOSE #1

		' Workout number of lines in text file loaded
	    FILE_NOLINES$=RIGHT$(STR$(i),LEN(STR$(i))-1)

		' Workout number of pages it will take to print on
		FILE_NOPAGES$=STR$((VAL(FILE_NOLINES$)/(VAL(LINESPP$)-EXTRA_LINES))+1)
		i=0
		DO
			INCR i
			IF FILE_NOPAGES$="" THEN EXIT LOOP
			IF MID$(FILE_NOPAGES$,i,1)="." THEN EXIT LOOP
			IF i=LEN(FILE_NOPAGES$) THEN EXIT LOOP
		LOOP 
		IF LOAD_TEXT$<>"" THEN 
			IF NOT MID$(FILE_NOPAGES$,i,1)="." THEN 
				FILE_NOPAGES$=STR$(VAL(FILE_NOLINES$)/(VAL(LINESPP$)-EXTRA_LINES))
				FILE_NOPAGES$=RIGHT$(FILE_NOPAGES$,LEN(FILE_NOPAGES$)-1)
			ELSE
				IF VAL(FILE_NOPAGES$)<1 THEN
					FILE_NOPAGES$="1"
				ELSE
					FILE_NOPAGES$=RIGHT$(LEFT$(FILE_NOPAGES$,i-1),LEN(LEFT$(FILE_NOPAGES$,i-1))-1)
				END IF
			END IF
		END IF

		i=LEN(LOAD_TEXT$)
		DO
			IF LOAD_TEXT$="" THEN EXIT LOOP
			IF MID$(LOAD_TEXT$,i,1)="\" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP 

		' Place these strings into the Misc. dialogue
		SelectTree FORM_MISC
		Sette_ptext MISC_FILE,RIGHT$(LOAD_TEXT$,LEN(LOAD_TEXT$)-i)
		Sette_ptext MISC_NOLINES,FILE_NOLINES$
		Sette_ptext MISC_NOPAGES,FILE_NOPAGES$
	ELSE
		' If the filename passed does not exists then display error
		junk=form_alert(1,"[1][ |  Error while loading text |  file into memory. | ][ Abort ]")
	END IF
END IF
MOUSE 0
END SUB


' Load sub-programs --------------------------------------------------------

SUB VIEW_FILE
SHARED LOAD_TEXT$,VIEWER$,fspath$,fsname$,FileSelect$
STATIC BUTTON,first%,i,ch

MOUSE 2
' If no default viewer exists call FileSelector
IF VIEWER$="" THEN 
	CALL FileSelect$(CURDIR$+"\*.PRG",fsname$)
ELSE
	FileSelect$=VIEWER$
	i=LEN(VIEWER$)
	DO
		ch=ASC(MID$(VIEWER$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 
	fsname$=RIGHT$(VIEWER$,i-1)
END IF

IF fsname$<>"" THEN
	' If file does not exist, then check again in current drive
	IF NOT FEXISTS (FileSelect$) THEN
		FileSelect$=LEFT$(CURDIR$,2)+RIGHT$(FileSelect$,LEN(FileSelect$)-2)
	END IF

	IF FEXISTS(FileSelect$) THEN
		VIEWER$=FileSelect$

		' Make sure the file selected is executable
		OPEN VIEWER$ FOR INPUT AS #1
		first%=CVI(INPUT$(2,#1))
		CLOSE #1
		' If not then display alert message
		IF NOT first%=&h601A
			junk=form_alert(1,"[1][ |  This file is not executable | ][ Abort ]")
			EXIT SUB
		END IF

		IF VIEWER$<>"" THEN CALL EXECUTE(VIEWER$,LOAD_TEXT$)
	ELSE
		' If it does not exist, then display alert message
		junk=form_alert(1,"[1][ |  Error while trying to access |  viewing program. | ][ Abort ]")
		EXIT SUB
	END IF
END IF
MOUSE 0
END SUB
    

' Executes programs and return to PRINT IT when exited
SUB EXECUTE(PROGRAM$,COMMANDLINE$)
STATIC junk&

MOUSE 2
' View menu bar MENU2 (the blank one)
SelectTree MENU2
menu_tnormal tree&,mess(3),1
menu_bar tree&,1

' Disable menubar
menu_bar tree&,0

' Execute program
junk&=pexec&(0,PROGRAM$,COMMANDLINE$,GetWholeEnvironment$)

' Enable menubar after program has exited
SelectTree MENU1
menu_bar tree&,1
menu_tnormal tree&,mess(3),1
MOUSE 0
END SUB


' Print sub-programs -------------------------------------------------------

' Prints text file loaded implementing the Page, Text, Header & Footer
' attributes chosen
SUB PRINT_IT
SHARED FROMPAGE$,TOPAGE$,LINESPP$,NOCOPIES$
SHARED HEADER_STATUS,FOOTER_STATUS,NOPAGES_STATUS,PRINTALL_STATUS
SHARED PRINTODD_STATUS,PRINTEVEN_STATUS,FORMFEED_STATUS
SHARED FILE_NOLINES$,FILE_NOPAGES$,EXTRA_LINES,HEIGHT_STATUS
STATIC PAGE,COPY,START_PAGE,FINISH_PAGE,LINE_NO,START_LINE,FINISH_LINE
STATIC BUTTON,i,TIME!,LINE_POSITION,CURRENT_LINESPP

' Call sub-program "ONLINE", Is the printer online ?
CALL ONLINE

MOUSE 2
' Workout first and last page numbers to print
START_PAGE=VAL(FROMPAGE$)
FINISH_PAGE=VAL(TOPAGE$)
IF FINISH_PAGE>VAL(FILE_NOPAGES$) THEN FINISH_PAGE=VAL(FILE_NOPAGES$)

FOR PAGE=START_PAGE TO FINISH_PAGE
	' If page is odd
	IF RIGHT$(STR$(PAGE/2),2)=".5" THEN 
		' If option to print even pages only is on then incr page number
		IF PRINTEVEN_STATUS=1 THEN INCR PAGE
	ELSE
		' If option to print odd pages only is on then incr page number
		IF PRINTODD_STATUS=1 THEN INCR PAGE
	END IF 

	' If current page number is higher than last page exit
	IF PAGE>FINISH_PAGE THEN EXIT FOR

	COPY=0
	CURRENT_LINESPP=(VAL(LINESPP$)-EXTRA_LINES)
	DO
		INCR COPY
		' Workout which lines of the array to print on this page
		START_LINE=(PAGE*CURRENT_LINESPP)-CURRENT_LINESPP+1
		IF START_LINE<1 THEN START_LINE=1
		FINISH_LINE=START_LINE+CURRENT_LINESPP-1
		IF FINISH_LINE>VAL(FILE_NOLINES$) THEN FINISH_LINE=VAL(FILE_NOLINES$)

		' If print Header Atrtribute is on then call appropriate sub-program
		IF HEADER_STATUS=1 THEN CALL SEND_HEADER
		' Send Page Attributes to the printer
		CALL SEND_PAGE
		LINE_POSITION=0

		FOR LINE_NO=START_LINE TO FINISH_LINE
			INCR LINE_POSITION
			TIME!=TIMER
			' Is the printer ready to receive data
			DO
				' If printer pauses wait for 10 seconds until showing 
				' alert box
				IF TIMER>=TIME!+10.00 THEN
					' If not, display alert
					BUTTON=form_alert(1,"[1][ |  Please turn your printer |  ON LINE! | ][ Continue | Cancel ]")
					SELECT CASE BUTTON
						CASE 2
							' Go back to main loop
							EXIT SUB
					END SELECT
				END IF
			LOOP UNTIL bcostat(0)<>0

			RESUME_PRINTING:
			' Print line
			IF HEIGHT_STATUS=1 THEN LPRINT ""
			LPRINT TEXT$(LINE_NO)
		NEXT LINE_NO

		' If print Footer Attribute is on then call appropriate sub-program
		IF FOOTER_STATUS=1 THEN 
			IF LINE_POSITION<CURRENT_LINESPP THEN
				DO
					IF LINE_POSITION=CURRENT_LINESPP THEN EXIT LOOP
					INCR LINE_POSITION
					IF HEIGHT_STATUS=1 THEN LPRINT ""
					LPRINT ""
				LOOP
			END IF
			CALL SEND_FOOTER
			' Send Page Attributes to the printer
			CALL SEND_PAGE
		END IF

		' If Number pages attribute
		IF NOPAGES_STATUS=1 THEN 
			IF LINE_POSITION<CURRENT_LINESPP THEN
				DO
					IF LINE_POSITION=CURRENT_LINESPP THEN EXIT LOOP
					INCR LINE_POSITION
					IF HEIGHT_STATUS=1 THEN LPRINT ""
					LPRINT ""
				LOOP
			END IF
			CALL ASK_CODE(PRINTER_DRIVER$(19))
			LPRINT "PAGE"+STR$(PAGE)
		END IF

		' If Form Feed Attribute is on then call appropriate sub-program
		IF FORMFEED_STATUS=1 THEN CALL FORMFEED
		' Loop until the right amount of copies have been made
	LOOP UNTIL COPY>=VAL(NOCOPIES$)
' Loop until the last page has been printed
NEXT PAGE
MOUSE 0
END SUB


' Send control codes to printer of attributes chosen for text style in 
' Header text
SUB SEND_HEADER
SHARED HEADER_JOKERSTAT,HEADER_UNDERLINDSTATUS
SHARED HEADER_EMPHASISDSTATUS,HEADER_2XHEIGHTSTATUS
SHARED HEADER_CONDENSEDSTATUS,HEADER_EXPANDEDSTATUS
SHARED HEADER_FONT1STATUS,HEADER_FONT2STATUS,HEADER_FONT3STATUS
SHARED HEADER_FONT4STATUS,HEADER_LEFTSTATUS,HEADER_CENTRSTATUS
SHARED HEADER_RIGHTSTATUS,HEADER_MESSAGE$

SelectTree FORM_HEADER
' Reset printer
CALL ASK_CODE(PRINTER_DRIVER$(17))
CALL CALL_MARGIN

IF HEADER_FONT1STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(13))
IF HEADER_FONT2STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(14))
IF HEADER_FONT3STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(15))
IF HEADER_FONT4STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(16))

IF HEADER_UNDERLINDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(4))
IF HEADER_CONDENSEDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(5))
IF HEADER_EXPANDEDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(6))
IF HEADER_EMPHASISDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(9))
IF HEADER_2XHEIGHTSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(10))
IF HEADER_JOKERSTAT=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(12))
IF HEADER_LEFTSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(18))
IF HEADER_CENTRSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(19))
IF HEADER_RIGHTSTATUS=1 THEN  CALL ASK_CODE(PRINTER_DRIVER$(20))

IF HEADER_2XHEIGHTSTATUS=1 THEN LPRINT ""
IF HEADER_MESSAGE$<>"" THEN LPRINT HEADER_MESSAGE$
END SUB


' Send control codes to printer of attributes chosen for text style in 
' Footer text
SUB SEND_FOOTER
SHARED FOOTER_JOKERSTAT,FOOTER_UNDERLINDSTATUS
SHARED FOOTER_EMPHASISDSTATUS,FOOTER_2XHEIGHTSTATUS
SHARED FOOTER_CONDENSEDSTATUS,FOOTER_EXPANDEDSTATUS
SHARED FOOTER_FONT1STATUS,FOOTER_FONT2STATUS,FOOTER_FONT3STATUS
SHARED FOOTER_FONT4STATUS,FOOTER_LEFTSTATUS,FOOTER_CENTRSTATUS
SHARED FOOTER_RIGHTSTATUS,FOOTER_MESSAGE$

SelectTree FORM_FOOTER
' Reset printer
CALL ASK_CODE(PRINTER_DRIVER$(17))
CALL CALL_MARGIN

IF FOOTER_FONT1STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(13))
IF FOOTER_FONT2STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(14))
IF FOOTER_FONT3STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(15))
IF FOOTER_FONT4STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(16))

IF FOOTER_UNDERLINDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(4))
IF FOOTER_CONDENSEDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(5))
IF FOOTER_EXPANDEDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(6))
IF FOOTER_EMPHASISDSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(9))
IF FOOTER_2XHEIGHTSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(10))
IF FOOTER_JOKERSTAT=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(12))
IF FOOTER_LEFTSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(18))
IF FOOTER_CENTRSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(19))
IF FOOTER_RIGHTSTATUS=1 THEN  CALL ASK_CODE(PRINTER_DRIVER$(20))

IF FOOTER_2XHEIGHTSTATUS=1 THEN LPRINT ""
IF FOOTER_MESSAGE$<>"" THEN LPRINT FOOTER_MESSAGE$
END SUB


' Send control codes to printer of attributes chosen for text style in 
' main body of text
SUB SEND_PAGE
SHARED LQ_STATUS,DRAFT_STATUS,ITALIC_STATUS,UNDERLINED_STATUS
SHARED SUPERSCRIPT_STATUS,SUBSCRIPT_STATUS,PROPPORT_STATUS,CONDENSED_STATUS
SHARED EXPANDED_STATUS,EMPHASISED_STATUS,HEIGHT_STATUS,JOKER_STATUS
SHARED FONT1_STATUS,FONT2_STATUS,FONT3_STATUS,FONT4_STATUS
SHARED TEXT_LEFTSTATUS,TEXT_CENTRSTATUS,TEXT_RIGHTSTATUS

' Reset printer
CALL ASK_CODE(PRINTER_DRIVER$(17))
CALL CALL_MARGIN

' If attribute is selected send code to printer
IF DRAFT_STATUS=1 THEN 
	CALL ASK_CODE(PRINTER_DRIVER$(2))
ELSE
	CALL ASK_CODE(PRINTER_DRIVER$(1))
	IF FONT1_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(13))
	IF FONT2_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(14))
	IF FONT3_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(15))
	IF FONT4_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(16))
END IF

IF ITALIC_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(3))
IF UNDERLINED_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(4))
IF CONDENSED_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(5))
IF EXPANDED_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(6))
IF SUPERSCRIPT_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(7))
IF SUBSCRIPT_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(8))
IF EMPHASISED_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(9))
IF HEIGHT_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(10))
IF PROPPORT_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(11))
IF JOKER_STATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(12))
IF TEXT_LEFTSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(18))
IF TEXT_CENTRSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(19))
IF TEXT_RIGHTSTATUS=1 THEN CALL ASK_CODE(PRINTER_DRIVER$(20))
END SUB


' Translates and sends control codes to the printer for the specified
' attribute chosen
SUB ASK_CODE(PRINTER_CODE$)
STATIC i,CODE,CODE_STRING$
STATIC CODE1,CODE2,CODE3,CODE4,CODE5,CODE6,CODE6,CODE7,CODE8,CODE9,CODE10

CODE_STRING$=PRINTER_CODE$
DO
	' Letter by letter (L to R) is searched. If the letter is ","
	' then exit loop ie: found a code to send to printer
	i=0
	DO
		INCR i
		IF MID$(CODE_STRING$,i,1)="," THEN EXIT LOOP
		' If end of string, exit loop
		IF i>LEN(CODE_STRING$) THEN EXIT LOOP
	LOOP 
	' Send byte (control code) to printer
	OUT 0,VAL(LEFT$(CODE_STRING$,i-1))
	IF i+1>LEN(CODE_STRING$) THEN EXIT LOOP
	CODE_STRING$=RIGHT$(CODE_STRING$,LEN(CODE_STRING$)-i)
LOOP
END SUB


' Workout page margins, send information to printer
SUB CALL_MARGIN
SHARED LMARGIN$,RMARGIN$
STATIC i

' Workout page margins, send information to printer (LEFT)
i=0
DO
	INCR i
	IF MID$(PRINTER_DRIVER$(26),i,1)="n" THEN EXIT LOOP
	IF i>=LEN(PRINTER_DRIVER$(26)) THEN EXIT LOOP
LOOP 
CALL ASK_CODE(LEFT$(PRINTER_DRIVER$(26),i-1)+LMARGIN$+RIGHT$(PRINTER_DRIVER$(26),LEN(PRINTER_DRIVER$(26))-(i+1)))

' Workout page margins, send information to printer (RIGHT)
i=0
DO
	INCR i
	IF MID$(PRINTER_DRIVER$(27),i,1)="n" THEN EXIT LOOP
	IF i>=LEN(PRINTER_DRIVER$(27)) THEN EXIT LOOP
LOOP 
CALL ASK_CODE(LEFT$(PRINTER_DRIVER$(27),i-1)+STR$(80-VAL(RMARGIN$))+RIGHT$(PRINTER_DRIVER$(27),LEN(PRINTER_DRIVER$(27))-(i+1)))
END SUB


' Workout number of pages it will take to print on
SUB CALL_LINES
SHARED LINESPP$,HEADER_STATUS,FOOTER_STATUS,NOPAGES_STATUS
SHARED FILE_NOLINES$,FILE_NOPAGES$,EXTRA_LINES,LOAD_TEXT$
SHARED HEADER_2XHEIGHTSTATUS,FOOTER_2XHEIGHTSTATUS,HEIGHT_STATUS
STATIC i

IF NOT LOAD_TEXT$="" THEN 
	EXTRA_LINES=0
	IF HEADER_STATUS=1 THEN 
		INCR EXTRA_LINES
		IF HEADER_2XHEIGHTSTATUS=1 THEN INCR EXTRA_LINES
	END IF

	IF FOOTER_STATUS=1 THEN 
		INCR EXTRA_LINES
		IF FOOTER_2XHEIGHTSTATUS=1 THEN INCR EXTRA_LINES
	END IF

	IF NOPAGES_STATUS=1 THEN 
		INCR EXTRA_LINES
		IF HEIGHT_STATUS=1 THEN INCR EXTRA_LINES
	END IF

	IF HEIGHT_STATUS=1 THEN 
		FOR i=1 TO ((VAL(LINESPP$)-EXTRA_LINES)/2)-1
			INCR EXTRA_LINES
		NEXT i
	END IF

	' Workout number of pages it will take to print on
	FILE_NOPAGES$=STR$((VAL(FILE_NOLINES$)/(VAL(LINESPP$)-EXTRA_LINES))+1)

	i=0
	DO
		INCR i
		IF FILE_NOPAGES$="" THEN EXIT LOOP
		IF MID$(FILE_NOPAGES$,i,1)="." THEN EXIT LOOP
		IF i=LEN(FILE_NOPAGES$) THEN EXIT LOOP
	LOOP 
	IF NOT MID$(FILE_NOPAGES$,i,1)="." THEN 
		FILE_NOPAGES$=STR$(VAL(FILE_NOLINES$)/(VAL(LINESPP$)-EXTRA_LINES))
		FILE_NOPAGES$=RIGHT$(FILE_NOPAGES$,LEN(FILE_NOPAGES$)-1)
	ELSE
		IF VAL(FILE_NOPAGES$)<1 THEN
			FILE_NOPAGES$="1"
		ELSE
			FILE_NOPAGES$=RIGHT$(LEFT$(FILE_NOPAGES$,i-1),LEN(LEFT$(FILE_NOPAGES$,i-1))-1)
		END IF
	END IF
END IF

SelectTree FORM_MISC
Sette_ptext MISC_NOPAGES,FILE_NOPAGES$
END SUB


' Page sub-programs --------------------------------------------------------

' Sub-program for result given from the Page Attributes dialogue box
SUB PAGE(res)
SELECT CASE res
	CASE PAGE_OK:
		' Call sub-program to record the current strings/variables
		CALL RECORD_PAGE
	CASE PAGE_CANCEL:
		' Call sub-program to reset the current strings/variables
		' to previous settings
        CALL RESET_PAGE
	CASE EDIT_HEADER:
		' Display Header Attributes dialogue box
		SelectTree FORM_HEADER
		res=handledialog(HEADER_MESSAGE)
		' Call sub-program to respond to dialogue result
		CALL HEADER(res)

		' Display Page Attributes dialogue box
		SelectTree FORM_PAGE
		res=handledialog(PAGE_FROMPAGE)
		' Call sub-program to respond to dialogue result
		CALL PAGE(res)
	CASE EDIT_FOOTER:
		' Display Footer dialogue
		SelectTree FORM_FOOTER
		res=handledialog(FOOTER_MESSAGE)
		' Call sub-program to respond to dialogue result
		CALL FOOTER(res)

		' Display Page Attributes dialogue box
		SelectTree FORM_PAGE
		res=handledialog(PAGE_FROMPAGE)
		' Call sub-program to respond to dialogue result
		CALL PAGE(res)
END SELECT
END SUB


' Records current strings/variables in FORM_PAGE after 'OK' has been
' selected
SUB RECORD_PAGE
SHARED FROMPAGE$,TOPAGE$,LINESPP$,LMARGIN$,RMARGIN$,NOCOPIES$
SHARED HEADER_STATUS,FOOTER_STATUS,NOPAGES_STATUS,PRINTALL_STATUS
SHARED PRINTODD_STATUS,PRINTEVEN_STATUS,FORMFEED_STATUS

SelectTree FORM_PAGE
FROMPAGE$=Gette_ptext$ (PAGE_FROMPAGE)

IF VAL(Gette_ptext$(PAGE_FROMPAGE))=0 THEN Sette_ptext PAGE_FROMPAGE,"01"

IF VAL(Gette_ptext$(PAGE_TOPAGE))<VAL(Gette_ptext$(PAGE_TOPAGE)) THEN
    Sette_ptext PAGE_TOPAGE,Gette_ptext$(PAGE_FROMPAGE)
END IF

TOPAGE$=Gette_ptext$ (PAGE_TOPAGE)
LINESPP$=Gette_ptext$ (PAGE_LINESPP)
LMARGIN$=Gette_ptext$ (PAGE_LMARGIN)
RMARGIN$=Gette_ptext$ (PAGE_RMARGIN)

IF VAL(Gette_ptext$(PAGE_NOCOPIES))=0 THEN Sette_ptext PAGE_NOCOPIES,"01"
NOCOPIES$=Gette_ptext$ (PAGE_NOCOPIES)

HEADER_STATUS=Getob_state (PAGE_HEADER)
FOOTER_STATUS=Getob_state (PAGE_FOOTER)
NOPAGES_STATUS=Getob_state (PAGE_NOPAGES)
PRINTALL_STATUS=Getob_state (PAGE_PRINTALL)
PRINTODD_STATUS=Getob_state (PAGE_PRINTODD)
PRINTEVEN_STATUS=Getob_state (PAGE_PRINTEVEN)
FORMFEED_STATUS=Getob_state (PAGE_FORMFEED)
CALL CALL_LINES
END SUB


' Resets current strings/variables in FORM_PAGE to previous settings
SUB RESET_PAGE
SHARED FROMPAGE$,TOPAGE$,LINESPP$,LMARGIN$,RMARGIN$,NOCOPIES$
SHARED HEADER_STATUS,FOOTER_STATUS,NOPAGES_STATUS,PRINTALL_STATUS
SHARED PRINTODD_STATUS,PRINTEVEN_STATUS,FORMFEED_STATUS

SelectTree FORM_PAGE
Sette_ptext PAGE_FROMPAGE,FROMPAGE$
Sette_ptext PAGE_TOPAGE,TOPAGE$
Sette_ptext PAGE_LINESPP,LINESPP$
Sette_ptext PAGE_LMARGIN,LMARGIN$
Sette_ptext PAGE_RMARGIN,RMARGIN$
Sette_ptext PAGE_NOCOPIES,NOCOPIES$

Setob_state PAGE_HEADER,HEADER_STATUS
Setob_state PAGE_FOOTER,FOOTER_STATUS
Setob_state PAGE_NOPAGES,NOPAGES_STATUS
Setob_state PAGE_PRINTALL,PRINTALL_STATUS
Setob_state PAGE_PRINTODD,PRINTODD_STATUS
Setob_state PAGE_PRINTEVEN,PRINTEVEN_STATUS
Setob_state PAGE_FORMFEED,FORMFEED_STATUS
END SUB


' Header sub-programs ------------------------------------------------------

' Sub-program for result given from the Header Attributes dialogue box
SUB HEADER(res)
SELECT CASE res
	CASE HEADER_OK:
		' Call sub-program to record the current strings/variables
		CALL RECORD_HEADER
	CASE HEADER_CANCEL:
		' Call sub-program to reset the current strings/variables
		' to previous settings
		CALL RESET_HEADER
END SELECT
END SUB


' Records current strings/variables in FORM_HEADER after 'OK' has been
' selected
SUB RECORD_HEADER
SHARED HEADER_JOKERSTAT,HEADER_UNDERLINDSTATUS
SHARED HEADER_EMPHASISDSTATUS,HEADER_2XHEIGHTSTATUS
SHARED HEADER_CONDENSEDSTATUS,HEADER_EXPANDEDSTATUS
SHARED HEADER_FONT1STATUS,HEADER_FONT2STATUS,HEADER_FONT3STATUS
SHARED HEADER_FONT4STATUS,HEADER_LEFTSTATUS,HEADER_CENTRSTATUS
SHARED HEADER_RIGHTSTATUS,HEADER_MESSAGE$

SelectTree FORM_HEADER
HEADER_JOKERSTAT=Getob_State(HEADER_JOKER)
HEADER_UNDERLINDSTATUS=Getob_State(HEADER_UNDERLIND)
HEADER_EMPHASISDSTATUS=Getob_State(HEADER_EMPHASISD)
HEADER_2XHEIGHTSTATUS=Getob_State(HEADER_2XHEIGHT)
HEADER_CONDENSEDSTATUS=Getob_State(HEADER_CONDENSED)
HEADER_EXPANDEDSTATUS=Getob_State(HEADER_EXPANDED)
HEADER_FONT1STATUS=Getob_State(HEADER_FONT1)
HEADER_FONT2STATUS=Getob_State(HEADER_FONT2)
HEADER_FONT3STATUS=Getob_State(HEADER_FONT3)
HEADER_FONT4STATUS=Getob_State(HEADER_FONT4)
HEADER_LEFTSTATUS=Getob_State(HEADER_JUSTLEFT)
HEADER_CENTRSTATUS=Getob_State(HEADER_JUSTCENTR)
HEADER_RIGHTSTATUS=Getob_State(HEADER_JUSTRIGHT)
HEADER_MESSAGE$=Gette_ptext$(HEADER_MESSAGE)
CALL CALL_LINES
END SUB


' Resets current strings/variables in FORM_HEADER to previous settings
SUB RESET_HEADER
SHARED HEADER_JOKERSTAT,HEADER_UNDERLINDSTATUS
SHARED HEADER_EMPHASISDSTATUS,HEADER_2XHEIGHTSTATUS
SHARED HEADER_CONDENSEDSTATUS,HEADER_EXPANDEDSTATUS
SHARED HEADER_FONT1STATUS,HEADER_FONT2STATUS,HEADER_FONT3STATUS
SHARED HEADER_FONT4STATUS,HEADER_LEFTSTATUS,HEADER_CENTRSTATUS
SHARED HEADER_RIGHTSTATUS,HEADER_MESSAGE$

SelectTree FORM_HEADER
Setob_state HEADER_JOKER,HEADER_JOKER
Setob_state HEADER_UNDERLIND,HEADER_UNDERLINDSTATUS
Setob_state HEADER_EMPHASISD,HEADER_EMPHASISDSTATUS
Setob_state HEADER_2XHEIGHT,HEADER_2XHEIGHTSTATUS
Setob_state HEADER_CONDENSED,HEADER_CONDENSEDSTATUS
Setob_state HEADER_EXPANDED,HEADER_EXPANDEDSTATUS
Setob_state HEADER_FONT1,HEADER_FONT1STATUS
Setob_state HEADER_FONT2,HEADER_FONT2STATUS
Setob_state HEADER_FONT3,HEADER_FONT3STATUS
Setob_state HEADER_FONT4,HEADER_FONT4STATUS
Setob_state HEADER_JUSTLEFT,HEADER_LEFTSTATUS
Setob_state HEADER_JUSTCENTR,HEADER_CENTRSTATUS
Setob_state HEADER_JUSTRIGHT,HEADER_RIGHTSTATUS
Sette_ptext HEADER_MESSAGE,HEADER_MESSAGE$

Sette_ptext HEADER_JOKERNAME,PRINTER_DRIVER$(21)
Sette_ptext HEADER_F1NAME,PRINTER_DRIVER$(22)
Sette_ptext HEADER_F2NAME,PRINTER_DRIVER$(23)
Sette_ptext HEADER_F3NAME,PRINTER_DRIVER$(24)
Sette_ptext HEADER_F4NAME,PRINTER_DRIVER$(25)

' If attribute disabled then enable
IF Getob_state(HEADER_JOKER)=8 THEN Setob_state HEADER_JOKER,0
IF Getob_state(HEADER_FONT1)=8 THEN Setob_state HEADER_FONT1,0
IF Getob_state(HEADER_FONT2)=8 THEN Setob_state HEADER_FONT2,0
IF Getob_state(HEADER_FONT3)=8 THEN Setob_state HEADER_FONT3,0
IF Getob_state(HEADER_FONT4)=8 THEN Setob_state HEADER_FONT4,0

' If attribute doesn't exist, disable selection box
IF Gette_ptext$(HEADER_JOKERNAME)="" THEN Setob_state HEADER_JOKER,8
IF Gette_ptext$(HEADER_F1NAME)="" THEN Setob_state HEADER_FONT1,8
IF Gette_ptext$(HEADER_F2NAME)="" THEN Setob_state HEADER_FONT2,8
IF Gette_ptext$(HEADER_F3NAME)="" THEN Setob_state HEADER_FONT3,8
IF Gette_ptext$(HEADER_F4NAME)="" THEN Setob_state HEADER_FONT4,8
END SUB


' Footer sub-programs ------------------------------------------------------

' Sub-program for result given from the Footer Attributes dialogue box
SUB FOOTER(res)
SELECT CASE res
	CASE FOOTER_OK:
		' Call sub-program to record the current strings/variables
		CALL RECORD_FOOTER
	CASE FOOTER_CANCEL:
		' Call sub-program to reset the current strings/variables
		' to previous settings
		CALL RESET_FOOTER
END SELECT
END SUB


' Records current strings/variables in FORM_FOOTER after 'OK' has been
' selected
SUB RECORD_FOOTER
SHARED FOOTER_JOKERSTAT,FOOTER_UNDERLINDSTATUS
SHARED FOOTER_EMPHASISDSTATUS,FOOTER_2XHEIGHTSTATUS
SHARED FOOTER_CONDENSEDSTATUS,FOOTER_EXPANDEDSTATUS
SHARED FOOTER_FONT1STATUS,FOOTER_FONT2STATUS,FOOTER_FONT3STATUS
SHARED FOOTER_FONT4STATUS,FOOTER_LEFTSTATUS,FOOTER_CENTRSTATUS
SHARED FOOTER_RIGHTSTATUS,FOOTER_MESSAGE$

SelectTree FORM_FOOTER
FOOTER_JOKERSTAT=Getob_State(FOOTER_JOKER)
FOOTER_UNDERLINDSTATUS=Getob_State(FOOTER_UNDERLIND)
FOOTER_EMPHASISDSTATUS=Getob_State(FOOTER_EMPHASISD)
FOOTER_2XHEIGHTSTATUS=Getob_State(FOOTER_2XHEIGHT)
FOOTER_CONDENSEDSTATUS=Getob_State(FOOTER_CONDENSED)
FOOTER_EXPANDEDSTATUS=Getob_State(FOOTER_EXPANDED)
FOOTER_FONT1STATUS=Getob_State(FOOTER_FONT1)
FOOTER_FONT2STATUS=Getob_State(FOOTER_FONT2)
FOOTER_FONT3STATUS=Getob_State(FOOTER_FONT3)
FOOTER_FONT4STATUS=Getob_State(FOOTER_FONT4)
FOOTER_LEFTSTATUS=Getob_State(FOOTER_JUSTLEFT)
FOOTER_CENTRSTATUS=Getob_State(FOOTER_JUSTCENTR)
FOOTER_RIGHTSTATUS=Getob_State(FOOTER_JUSTRIGHT)
FOOTER_MESSAGE$=Gette_ptext$(FOOTER_MESSAGE)
CALL CALL_LINES
END SUB


' Resets current strings/variables in FORM_FOOTER to previous settings
SUB RESET_FOOTER
SHARED FOOTER_JOKERSTAT,FOOTER_UNDERLINDSTATUS
SHARED FOOTER_EMPHASISDSTATUS,FOOTER_2XHEIGHTSTATUS
SHARED FOOTER_CONDENSEDSTATUS,FOOTER_EXPANDEDSTATUS
SHARED FOOTER_FONT1STATUS,FOOTER_FONT2STATUS,FOOTER_FONT3STATUS
SHARED FOOTER_FONT4STATUS,FOOTER_LEFTSTATUS,FOOTER_CENTRSTATUS
SHARED FOOTER_RIGHTSTATUS,FOOTER_MESSAGE$

SelectTree FORM_FOOTER
Setob_state FOOTER_JOKER,FOOTER_JOKERSTAT
Setob_state FOOTER_UNDERLIND,FOOTER_UNDERLINDSTATUS
Setob_state FOOTER_EMPHASISD,FOOTER_EMPHASISDSTATUS
Setob_state FOOTER_2XHEIGHT,FOOTER_2XHEIGHTSTATUS
Setob_state FOOTER_CONDENSED,FOOTER_CONDENSEDSTATUS
Setob_state FOOTER_EXPANDED,FOOTER_EXPANDEDSTATUS
Setob_state FOOTER_FONT1,FOOTER_FONT1STATUS
Setob_state FOOTER_FONT2,FOOTER_FONT2STATUS
Setob_state FOOTER_FONT3,FOOTER_FONT3STATUS
Setob_state FOOTER_FONT4,FOOTER_FONT4STATUS
Setob_state FOOTER_JUSTLEFT,FOOTER_LEFTSTATUS
Setob_state FOOTER_JUSTCENTR,FOOTER_CENTRSTATUS
Setob_state FOOTER_JUSTRIGHT,FOOTER_RIGHTSTATUS
Sette_ptext FOOTER_MESSAGE,FOOTER_MESSAGE$

Sette_ptext FOOTER_JOKERNAME,PRINTER_DRIVER$(21)
Sette_ptext FOOTER_F1NAME,PRINTER_DRIVER$(22)
Sette_ptext FOOTER_F2NAME,PRINTER_DRIVER$(23)
Sette_ptext FOOTER_F3NAME,PRINTER_DRIVER$(24)
Sette_ptext FOOTER_F4NAME,PRINTER_DRIVER$(25)

' If attribute disabled then enable
IF Getob_state(FOOTER_JOKER)=8 THEN Setob_state FOOTER_JOKER,0
IF Getob_state(FOOTER_FONT1)=8 THEN Setob_state FOOTER_FONT1,0
IF Getob_state(FOOTER_FONT2)=8 THEN Setob_state FOOTER_FONT2,0
IF Getob_state(FOOTER_FONT3)=8 THEN Setob_state FOOTER_FONT3,0
IF Getob_state(FOOTER_FONT4)=8 THEN Setob_state FOOTER_FONT4,0

' If attribute doesn't exist, disable selection box
IF Gette_ptext$(FOOTER_JOKERNAME)="" THEN Setob_state FOOTER_JOKER,8
IF Gette_ptext$(FOOTER_F1NAME)="" THEN Setob_state FOOTER_FONT1,8
IF Gette_ptext$(FOOTER_F2NAME)="" THEN Setob_state FOOTER_FONT2,8
IF Gette_ptext$(FOOTER_F3NAME)="" THEN Setob_state FOOTER_FONT3,8
IF Gette_ptext$(FOOTER_F4NAME)="" THEN Setob_state FOOTER_FONT4,8
END SUB


' Text sub-programs --------------------------------------------------------

' Sub-program for result given from the Text Attributes dialogue box
SUB TEXT(res)
SELECT CASE res
	CASE TEXT_OK:
		' Call sub-program to record the current strings/variables
		CALL RECORD_TEXT
	CASE TEXT_CANCEL:
		' Call sub-program to reset the current strings/variables
		' to previous settings
		CALL RESET_TEXT
END SELECT
END SUB


' Records current strings/variables in FORM_TEXT after 'OK' has been
' selected
SUB RECORD_TEXT
SHARED LQ_STATUS,DRAFT_STATUS,ITALIC_STATUS,UNDERLINED_STATUS
SHARED SUPERSCRIPT_STATUS,SUBSCRIPT_STATUS,PROPPORT_STATUS,CONDENSED_STATUS
SHARED EXPANDED_STATUS,EMPHASISED_STATUS,HEIGHT_STATUS,JOKER_STATUS
SHARED FONT1_STATUS,FONT2_STATUS,FONT3_STATUS,FONT4_STATUS
SHARED TEXT_LEFTSTATUS,TEXT_CENTRSTATUS,TEXT_RIGHTSTATUS

SelectTree FORM_TEXT
LQ_STATUS=Getob_state(QUALITY_LQ)
DRAFT_STATUS=Getob_state(QUALITY_DRAFT)
ITALIC_STATUS=Getob_state(STYLE_ITALIC)
UNDERLINED_STATUS=Getob_state(STYLE_UNDERLINED)
SUPERSCRIPT_STATUS=Getob_state(STYLE_SUPERSCRPT)
SUBSCRIPT_STATUS=Getob_state(STYLE_SUBSCRPT)
PROPPORT_STATUS=Getob_state(STYLE_PROPORT)
CONDENSED_STATUS=Getob_state(STYLE_CONDENSED)
EXPANDED_STATUS=Getob_state(STYLE_EXPANDED)
EMPHASISED_STATUS=Getob_state(STYLE_EMPHASISED)
HEIGHT_STATUS=Getob_state(STYLE_2XHEIGHT)
JOKER_STATUS=Getob_state(STYLE_JOKER)
FONT1_STATUS=Getob_state(FONT_FONT1)
FONT2_STATUS=Getob_state(FONT_FONT3)
FONT3_STATUS=Getob_state(FONT_FONT2)
FONT4_STATUS=Getob_state(FONT_FONT4)
TEXT_LEFTSTATUS=Getob_state(TEXT_JUSTLEFT)
TEXT_CENTRSTATUS=Getob_state(TEXT_JUSTCENTRE)
TEXT_RIGHTSTATUS=Getob_state(TEXT_JUSTRIGHT)
CALL CALL_LINES
END SUB


' Resets current strings/variables in FORM_TEXT to previous settings
SUB RESET_TEXT
SHARED LQ_STATUS,DRAFT_STATUS,ITALIC_STATUS,UNDERLINED_STATUS
SHARED SUPERSCRIPT_STATUS,SUBSCRIPT_STATUS,PROPPORT_STATUS,CONDENSED_STATUS
SHARED EXPANDED_STATUS,EMPHASISED_STATUS,HEIGHT_STATUS,JOKER_STATUS
SHARED FONT1_STATUS,FONT2_STATUS,FONT3_STATUS,FONT4_STATUS
SHARED TEXT_LEFTSTATUS,TEXT_CENTRSTATUS,TEXT_RIGHTSTATUS

SelectTree FORM_TEXT
Setob_state QUALITY_LQ,LQ_STATUS
Setob_state QUALITY_DRAFT,DRAFT_STATUS
Setob_state STYLE_ITALIC,ITALIC_STATUS
Setob_state STYLE_UNDERLINED,UNDERLINED_STATUS
Setob_state STYLE_SUPERSCRPT,SUPERSCRIPT_STATUS
Setob_state STYLE_SUBSCRPT,SUBSCRIPT_STATUS
Setob_state STYLE_PROPORT,PROPPORT_STATUS
Setob_state STYLE_CONDENSED,CONDENSED_STATUS
Setob_state STYLE_EXPANDED,EXPANDED_STATUS
Setob_state STYLE_EMPHASISED,EMPHASISED_STATUS
Setob_state STYLE_2XHEIGHT,HEIGHT_STATUS
Setob_state STYLE_JOKER,JOKER_STATUS
Setob_state FONT_FONT1,FONT1_STATUS
Setob_state FONT_FONT2,FONT2_STATUS
Setob_state FONT_FONT3,FONT3_STATUS
Setob_state FONT_FONT4,FONT4_STATUS
Setob_state TEXT_JUSTLEFT,TEXT_LEFTSTATUS
Setob_state TEXT_JUSTCENTRE,TEXT_CENTRSTATUS
Setob_state TEXT_JUSTRIGHT,TEXT_RIGHTSTATUS

Sette_ptext TEXT_JOKER,PRINTER_DRIVER$(21)
Sette_ptext FONT_NAME1,PRINTER_DRIVER$(22)
Sette_ptext FONT_NAME2,PRINTER_DRIVER$(23)
Sette_ptext FONT_NAME3,PRINTER_DRIVER$(24)
Sette_ptext FONT_NAME4,PRINTER_DRIVER$(25)

' If attribute disabled then enable
IF Getob_state(STYLE_JOKER)=8 THEN Setob_state STYLE_JOKER,0
IF Getob_state(FONT_FONT1)=8 THEN Setob_state FONT_FONT1,0
IF Getob_state(FONT_FONT2)=8 THEN Setob_state FONT_FONT2,0
IF Getob_state(FONT_FONT3)=8 THEN Setob_state FONT_FONT3,0
IF Getob_state(FONT_FONT4)=8 THEN Setob_state FONT_FONT4,0

' If attribute doesn't exist, disable selection box
IF Gette_ptext$(TEXT_JOKER)="" THEN Setob_state STYLE_JOKER,8
IF Gette_ptext$(FONT_NAME1)="" THEN Setob_state FONT_FONT1,8
IF Gette_ptext$(FONT_NAME2)="" THEN Setob_state FONT_FONT2,8
IF Gette_ptext$(FONT_NAME3)="" THEN Setob_state FONT_FONT3,8
IF Gette_ptext$(FONT_NAME4)="" THEN Setob_state FONT_FONT4,8
END SUB


' Misc. sub-programs -------------------------------------------------------

' Sub-program for result given from the Misc. Attributes dialogue box
SUB MISC(res)
SHARED FileSelect$,fspath$,fsname$,VIEWER$
SHARED PDRIVER_PATH$,PDRIVER_NAME$,VIEWER_DEFAULT$,PDRIVER_DEFAULT$
STATIC BUTTON,i

SELECT CASE res
	CASE MISC_OK:
		IF NOT VIEWER$=VIEWER_DEFAULT$ THEN VIEWER$=VIEWER_DEFAULT$
	CASE MISC_FSPDRIVER:
		' Call FileSelector
		CALL FileSelect$(CURDIR$+"\*.PIT",fsname$)

		' Check the file passed by File Selector is not a null string,
		' otherwise exit sub program
		IF fsname$<>"" THEN 
			' Make the file chosen the new default Printer driver
			PDRIVER_DEFAULT$=FileSelect$
			i=LEN(PDRIVER_DEFAULT$)
			DO
				IF PDRIVER_DEFAULT$="" THEN EXIT LOOP
				IF MID$(PDRIVER_DEFAULT$,i,1)="\" THEN EXIT LOOP
				IF i=1 THEN EXIT LOOP
				DECR i
			LOOP 
			Sette_ptext MISC_PDRIVER,RIGHT$(PDRIVER_DEFAULT$,LEN(PDRIVER_DEFAULT$)-i)
		END IF
       
		' Display Misc. Attributes dialogue box
		SelectTree FORM_MISC
		res=handledialog(0)
		' Call sub-program to respond to dialogue result
		CALL MISC(res)
	CASE MISC_FSVIEWER:
		' Call FileSelector
		CALL FileSelect$(CURDIR$+"\*.PRG",fsname$)

		' Check the file passed by File Selector is not a null string,
		' otherwise exit sub program
		IF fsname$<>"" THEN
			VIEWER_DEFAULT$=FileSelect$
			i=LEN(VIEWER_DEFAULT$)
			DO
				IF VIEWER_DEFAULT$="" THEN EXIT LOOP
				IF MID$(VIEWER_DEFAULT$,i,1)="\" THEN EXIT LOOP
				IF i=1 THEN EXIT LOOP
				DECR i
			LOOP 
			Sette_ptext MISC_VIEWER,RIGHT$(VIEWER_DEFAULT$,LEN(VIEWER_DEFAULT$)-i)
		END IF

		' Display Misc. Attributes dialogue box
		SelectTree FORM_MISC
		res=handledialog(0)
		' Call sub-program to respond to dialogue result
		CALL MISC(res)
	CASE MISC_SAVEDEFAULT:
		' Call FileSelector
		CALL FileSelect$(CURDIR$+"\*.INF","PRINT_IT.INF")
		' Call sub-program to save new Misc. settings to disk
		CALL SAVE_DEFAULT(FileSelect$)

		' Display Misc. dialogue box
		SelectTree FORM_MISC
		res=handledialog(0)
		' Call sub-program to respond to dialogue result
		CALL MISC(res)
END SELECT
END SUB


' Load default settings 
SUB LOAD_DEFAULT(DEF_FILE$)
SHARED PDRIVER_PATH$,VIEWER$,VIEWER_DEFAULT$
STATIC i

MOUSE 2
' Check the default file exists, if not check current drive
IF NOT FEXISTS (DEF_FILE$) THEN
	DEF_FILE$=CURDIR$+RIGHT$(DEF_FILE$,LEN(DEF_FILE$)-2)
END IF

' Check the default file exists, if it does load it
IF FEXISTS (DEF_FILE$) THEN
	OPEN DEF_FILE$ FOR INPUT AS #1
	i=0
	REDIM DEFAULT$(i)
	DO
		INCR i
		REDIM PRESERVE DEFAULT$(i)

		' Input line by line until line contains "#DEFAULT SETTINGS"
		LINE INPUT #1,DEFAULT$(i)

		' If the first line of the opened file is not ... (as below)
		' then instruct the user that this is probably not a Print IT
		' Misc. Information file
		IF NOT DEFAULT$(1)="PRINT IT v1.00 - Written by Matthew Bacon" THEN
			CLOSE #1
			junk=form_alert(1,"[1][ |  Error while loading |  Misc. Information file. ][ Abort ]")
			EXIT SUB
		END IF

		IF DEFAULT$(i)="#DEFAULT SETTINGS"
			i=0
			' Wipe clean the array
			REDIM DEFAULT$(i)
			DO
				' Incr line
				INCR i
				' Increase array size without deleting current data
				REDIM PRESERVE DEFAULT$(i)
				' Input data in array line i
				LINE INPUT #1,DEFAULT$(i)
				' Loop until end of file and close channel
            LOOP UNTIL EOF(1)
            CLOSE #1

			PDRIVER_PATH$=DEFAULT$(1)
			VIEWER$=DEFAULT$(2)
			VIEWER_DEFAULT$=DEFAULT$(2)
			EXIT SUB
		ELSE
			' If line i does not contain "#DEFAULT SETTINGS" then 
			' incr i and loop
			INCR i
		END IF
		' Loop until end of file and close channel
	LOOP UNTIL EOF(1)
	CLOSE #1
END IF
MOUSE 0
END SUB


' Save default settings ie: Default Printer driver and Viewer file paths
SUB SAVE_DEFAULT(DEF_FILE$)
SHARED PDRIVER_DEFAULT$,VIEWER_DEFAULT$,fsname$

MOUSE 2
' Check the file passed by File Selector is not a null string, otherwise 
' exit sub program
IF fsname$<>"" THEN
	' If the default file is a .BAK file then change it to a .INF
	IF RIGHT$(DEF_FILE$,4)=".BAK" THEN
		DEF_FILE$=LEFT$(DEF_FILE$,LEN(DEF_FILE$)-4)+".INF"
	END IF

	' Check if a .BAK default file exists, if it does delete it
	IF FEXISTS (LEFT$(DEF_FILE$,LEN(DEF_FILE$)-4)+".BAK") THEN
		KILL LEFT$(DEF_FILE$,LEN(DEF_FILE$)-4)+".BAK"
	END IF

	' Check the default file exists, if it does change name to .BAK
	IF FEXISTS (DEF_FILE$) THEN
		IF RIGHT$(DEF_FILE$,4)=".INF" THEN
			NAME DEF_FILE$ AS LEFT$(DEF_FILE$,LEN(DEF_FILE$)-4)+".BAK"
		END IF
	END IF

	' Open file to channel 1
	OPEN DEF_FILE$ FOR OUTPUT AS #1
	PRINT #1,"PRINT IT v1.00 - Written by Matthew Bacon"
	PRINT #1,""
	PRINT #1,"#DEFAULT SETTINGS"
	PRINT #1,PDRIVER_DEFAULT$
	PRINT #1,VIEWER_DEFAULT$
	PRINT #1,"#END"
	CLOSE #1
END IF
MOUSE 0
END SUB


' Printer ------------------------------------------------------------------

' Load printer driver into array
SUB LOAD_PDRIVER(FileSelect$)
SHARED PDRIVER_PATH$,PDRIVER_NAME$,fsname$,fspath$,PDRIVER_DEFAULT$
SHARED PRINTER_FLAG
STATIC i,string_length,position

PRINTER_FLAG=0
MOUSE 2
' Check the printer driver file exists, if not check current drive
IF NOT FEXISTS (FileSelect$) THEN
	FileSelect$=CURDIR$+RIGHT$(FileSelect$,LEN(FileSelect$)-2)
END IF

' Check the default file exists, if it does load it
IF FEXISTS (FileSelect$)
	' Continue
ELSE
	PRINTER_FLAG=1
	' If file does not exist, display alert message
	junk=form_alert(1,"[1][ |  Error while loading |  printer driver. | ][ Abort ]")
	EXIT SUB
END IF

' Open file to channel 1
OPEN FileSelect$ FOR INPUT AS #1
i=0
REDIM PRINTER_DRIVER$(i)
DO
	INCR i
	REDIM PRESERVE PRINTER_DRIVER$(i)
	' Input line by line until line contains "#ASCII CODES" which
	' signals the start of the control codes in the file
	LINE INPUT #1,PRINTER_DRIVER$(i)

	' If the first line of the opened file is not ... (as below)
	' then instruct the user that this is probably not a Print IT
	' printer driver file
	IF NOT PRINTER_DRIVER$(1)="PRINT IT v1.00 - Written by Matthew Bacon" THEN
		CLOSE #1
		junk=form_alert(1,"[1][ |  Error while loading |  printer driver. Not a |  Print IT printer |  driver file. ][ Abort ]")
		EXIT SUB
	END IF

	IF PRINTER_DRIVER$(i)="#ASCII CODES" THEN
		i=0
		' Wipe clean the array
		REDIM PRINTER_DRIVER$(i)
		DO
			' Incr line
			INCR i
			' Increase array size without deleting current data
			REDIM PRESERVE PRINTER_DRIVER$(i)
			' Input data in array line i
			LINE INPUT #1,PRINTER_DRIVER$(i)

			' Workout total length of array line i 
			string_length=LEN(PRINTER_DRIVER$(i))
			position=0
			' Loop until end of control code (signalled by a ASCII
			' character #, then make this the array DATA
			DO
				INCR position
				IF MID$(PRINTER_DRIVER$(i),position,1)="#" THEN EXIT LOOP
				IF position=string_length THEN EXIT LOOP
			LOOP 

			' If array data equals is "#" or a starts with a space
			' "#" then ignore it and reset data to a null string ""
			IF LEFT$(PRINTER_DRIVER$(i),1)="#" THEN
				PRINTER_DRIVER$(i)=""
			ELSE
				PRINTER_DRIVER$(i)=LEFT$(PRINTER_DRIVER$(i),position-1)
			END IF

			' Loop until end of file and close channel
		LOOP UNTIL EOF(1)
		CLOSE #1

		PDRIVER_PATH$=FileSelect$
		' Make sure only the printer driver name is passed to
		' string PDRIVER_NAME$
		i=LEN(PDRIVER_PATH$)
		DO
			IF MID$(PDRIVER_PATH$,i,1)="\" THEN EXIT LOOP
			IF i=1 THEN EXIT LOOP
			DECR i
		LOOP 
		PDRIVER_NAME$=RIGHT$(PDRIVER_PATH$,LEN(PDRIVER_PATH$)-i)
		CALL RESET_TEXT
		CALL RESET_HEADER
		CALL RESET_FOOTER
		MOUSE 0
		EXIT SUB
	END IF
	' Loop until end of file and close channel
LOOP UNTIL EOF(1)
CLOSE #1
MOUSE 0
END SUB


' Test sub-programs --------------------------------------------------------

' Sends control codes to the printer
SUB TEST
MOUSE 2
CALL ASK_CODE(PRINTER_DRIVER$(17))
LPRINT "Printer test - Print IT v1.00 - Written by Matthew Bacon"
LPRINT ""
CALL ASK_CODE(PRINTER_DRIVER$(1))
LPRINT "This is an example of: Letter Quality text"
CALL ASK_CODE(PRINTER_DRIVER$(2))
LPRINT "This is an example of: Draft Quality text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(3))
LPRINT "This is an example of: Italic text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(4))
LPRINT "This is an example of: Underlined text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(5))
LPRINT "This is an example of: Condensed text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(6))
LPRINT "This is an example of: Expanded text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(7))
LPRINT "This is an example of: Superscript text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(8))
LPRINT "This is an example of: Subscript text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(9))
LPRINT "This is an example of: Emphasised/Bold text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(10))
LPRINT ""
LPRINT "This is an example of: Double height text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(11))
LPRINT "This is an example of: Proportional text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(12))
LPRINT "This is an example of: Joker text"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(13))
LPRINT "This is an example of: "+PRINTER_DRIVER$(22)+" font"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(14))
LPRINT "This is an example of: "+PRINTER_DRIVER$(23)+" font"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(15))
LPRINT "This is an example of: "+PRINTER_DRIVER$(24)+" font"
CALL ASK_CODE(PRINTER_DRIVER$(17))

CALL ASK_CODE(PRINTER_DRIVER$(16))
LPRINT "This is an example of: "+PRINTER_DRIVER$(25)+" font"
CALL ASK_CODE(PRINTER_DRIVER$(17))
MOUSE 0
END SUB


' Form feed sub-programs ---------------------------------------------------

' Send control code to printer, instructing to Form Feed
SUB FORMFEED
OUT 0,12
END SUB


' Reset sub-programs -------------------------------------------------------

' Send control code to printer, instructing to reset to default settings
SUB RESET_PRINTER
CALL ASK_CODE(PRINTER_DRIVER$(17))
END SUB


' Error sub-programs -------------------------------------------------------

' Find out error occurred
ERROR_HANDLER:
MOUSE 0
' If printer error
IF ERR=57 THEN RESUME REPORT_PRINTERERROR
' If other error
IF ERR>=0 THEN RESUME REPORT_GENERALERROR


' Handle printer error
SUB PRINTER_ERROR
STATIC BUTTON

REPORT_PRINTERERROR:
BUTTON=form_alert(1,"[1][ |  A Printer ERROR has occurred ! |  Is the printer ON LINE ? ][ Continue | Cancel ]")
SELECT CASE BUTTON
	CASE 1
		' Is the printer ready to receive data
		IF bcostat(0)=0 THEN
			' If not, display alert and abort to main loop
			BUTTON=form_alert(1,"[1][ |  The printer is still not |  ON LINE ! |  Aborting printing ! ][ Abort ]")
			SelectTree MENU1
			menu_tnormal tree&,mess(3),1
			' Go back to main loop
			GOTO START_HANDLER
		ELSE
			MOUSE 2
			' If an error occurs in the program report it
			ON ERROR GOTO ERROR_HANDLER
			' Return to printing
			GOTO RESUME_PRINTING
		END IF
	CASE 2
		' Abort to main loop
		SelectTree MENU1
		menu_tnormal tree&,mess(3),1
		' Go back to main loop
		GOTO START_HANDLER
END SELECT
END SUB


' Handle General error
SUB GENERAL_ERROR

REPORT_GENERALERROR:
' Display alert and abort to main loop
JUNK=form_alert(1,"[1][ |  An ERROR"+STR$(ERR)+" has occurred ! |  Abort to main program |  loop. ][ Abort ]")
SelectTree MENU1
menu_tnormal tree&,mess(3),1
' Go back to main loop
GOTO START_HANDLER
END SUB


' End ----------------------------------------------------------------------
