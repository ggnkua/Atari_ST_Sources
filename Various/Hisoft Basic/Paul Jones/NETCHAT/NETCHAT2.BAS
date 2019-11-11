
REM NetChat

'REM $option q30
'REM $option k10
REM $option g,y+,v+,u+,#,[,],q50

DEFINT a-z
' LIBRARY "gemdos","xbios"
LIBRARY "waveplay"

DIM SHARED junk

REM $include netchat.bh
REM $include gemaes.bh
REM $include networld.bas
'REM $include pjcoform.bas
REM $include multitas.bas
REM $include saancht.bh


'DIM SHARED tree&
'DIM SHARED max_progs

'DEF ObjectAddr&(object)=tree&+object*ob_sizeof
'DEF Getob_spec&(object)=PEEKL(ObjectAddr&(object)+ob_spec)

SUB ProcessUserIconify (x,y,w,h)
STATIC logo&,xout,yout,wout,hout

junk=rsrc_gaddr (0,iconpic,logo&)
SelectTreeAddr logo&
junk=wind_calc (1,9,x,y,w,h,xout,yout,wout,hout)

'xout=x
'yout=y
'wout=w
'hout=h

DECR xout
DECR yout
DECR wout
DECR hout

setob_x 0,xout
setob_y 0,yout
setob_width 0,wout
setob_height 0,hout
junk=objc_draw (logo&,0,10,xout,yout,wout,hout)


END SUB

' File selector handler - returns a new pathname
' the global variables fspath$ and fsname$ keep the appropriate
' GEM items.
FUNCTION FileSelect$
SHARED fspath$,fsname$,fsmessage$,fspather$
STATIC i,ch,okb
IF fspath$="" THEN CALL InitFileSelector
' okb=VARPTR(ok)
IF aes_version<&H130 THEN
	fsel_input fspath$,fsname$,okb
ELSE 
	fsel_exinput fspath$,fsname$,okb,fsmessage$
END IF
IF okb THEN
	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 
	FileSelect$=LEFT$(fspath$,i)+fsname$
	fspather$=LEFT$(fspath$,i)
ELSE
	FileSelect$=""
END IF
END FUNCTION

' initialise the file selector
SUB	InitFileSelector
SHARED fspath$,fsname$
fspath$=CURDIR$+"\*.*"
fsname$=""
END SUB

FUNCTION killpath$ (path$)
STATIC i,ch
i=LEN(path$)
DO
	ch=ASC(MID$(path$,i,1))
	IF ch="\"% OR ch=":"% THEN EXIT LOOP
	IF i=1 THEN EXIT LOOP
	DECR i
LOOP 
killpath$=LEFT$(path$,i)
END FUNCTION

FUNCTION killname$ (path$)
STATIC i,ch,dummy$
i=LEN(path$)
DO
	ch=ASC(MID$(path$,i,1))
	IF ch="\"% OR ch=":"% THEN EXIT LOOP
	IF i=1 THEN EXIT LOOP
	DECR i
LOOP 
dummy$=RIGHT$(path$,i)

i=LEN(dummy$)
DO
	ch=ASC(MID$(dummy$,i,1))
	IF ch="."% THEN EXIT LOOP
	IF i=1 THEN EXIT LOOP
	DECR i
LOOP
killname$=LEFT$(dummy$,i-1)+"  "
END FUNCTION

SUB closewait
END SUB

SUB getmailerror (er)
SHARED waitform,account$,password$

SelectTree wait
SELECT CASE er
	CASE 1:
		sette_ptext stat,"No response from POP server"
	CASE 2:
		sette_ptext stat,account$+" is not a valid user!"
	CASE 3:
		sette_ptext stat,"Trouble with password "+password$+"!"
	CASE 4:
		sette_ptext stat,"Trouble with status!"
	CASE 5:
		sette_ptext stat,"Trouble quiting!!"
	CASE 6:
		sette_ptext stat,"Couldn't delete message!"
END SELECT

FullReDraw waitform
END SUB

SUB emailnew
STATIC a&,b&
SHARED myco

selecttree wait
sette_ptext connectet,"mail.zetnet.co.uk"
junk=openformwindow (" Please wait... ",myco,wait,0,ok,VARPTRS(closewait))
fullredraw junk

a&=CINT(TIMER)+10
DO
LOOP UNTIL CINT(TIMER)=a&

closeawindow junk
END SUB

SUB emailcheck
SHARED popserver$,password$,account$,myco,waitform,sam_present
STATIC dummy(),mail$,messages,b$,res,resp$,i,st$,ch,tim&

mail$=popserver$
IF popserver$="" THEN
	junk=form_alert (1,"[3][ Error: POP server | not specified! ][ OK ]")
ELSE
	IF carrier_detect (dummy())<>1 THEN
		junk=form_alert (1,"[3][ Error: STiK not connected | to IP! ][ OK ]")
	ELSE
		ch=tcp_connect (mail$,110,0,2000)
		IF ch=-1 THEN
			junk=form_alert (1,"[3][ Error: connecting error! ][ OK ]")
		ELSE
			SelectTree wait
			sette_ptext connectet,popserver$
			sette_ptext stat,"Please wait, connecting to..."
			sette_ptext stat2,""
			waitform=openformwindow (" Status... ",myco,wait,0,ok,VARPTRS(closewait))
			FullReDraw waitform
			resp$=get_response$ (ch,60)
			sette_ptext stat,"Please wait, requesting status..."
			FullReDraw waitform
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(1)
				GOTO qgetmail
			END IF
			res=tcpsend (ch, "USER "+account$)
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(2)
				GOTO qgetmail
			END IF
			res=tcpsend (ch, "PASS "+password$)
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(3)
				GOTO qgetmail
			END IF
			res=tcpsend (ch, "STAT")
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(4)
				GOTO qgetmail
			END IF
			
			b$=MID$(resp$,5,LEN(resp$)-4)
			FOR i=1 TO LEN(b$)
				junk=ASC(MID$(b$,i,1))
				IF junk=" "% THEN EXIT FOR
			NEXT i

			messages=VAL(MID$(b$,1,i))

			st$="You have"+STR$(messages)+" message"
			IF messages<>1 THEN st$=st$+"s"
			st$=st$+"."

'			junk=form_alert (1,"[1][ "+st$+" ][ OK ]")

			IF sam_present THEN
				IF messages=0 THEN
					junk=waveplaymacro (saa_cookie&,saa_you_have_0_messages)
				ELSE
					junk=waveplaymacro (saa_cookie&,saa_you_have_x_messages)
				END IF
			END IF

			sette_ptext stat,st$
			FullReDraw waitform
			res=tcpsend (ch, "QUIT")
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN CALL getmailerror(5)
qgetmail:	junk=tcp_close (ch,0)

			tim&=CINT(TIMER)+2
			DO
			LOOP UNTIL CINT(TIMER)=tim&

			CloseAWindow waitform
			waitform=0

		END IF
	END IF
END IF
END SUB

FUNCTION get_mail$ (cn, time)
STATIC time2,time3,count,c,s$,d,exitme,co,junk$
SHARED commonerror

time2=CINT(TIMER)
time3=time2+time
s$=""

exitme=0	

DO

	DO
		IF CINT(TIMER)=time3 THEN get_mail$="" : commonerror=E_USERTIMEOUT : EXIT FUNCTION
		IF INKEY$<>"" THEN get_mail$="" : commonerror=E_USERTIMEOUT : EXIT FUNCTION
		count=cnbyte_count (cn)
		IF count<>0 THEN EXIT DO
	LOOP
	IF count<0 THEN
		get_mail$="" : commonerror=count
		EXIT FUNCTION
	END IF

	FOR co=1 TO count
		c=cnget_char (cn)
		IF c<E_NODATA THEN
			get_mail$="" : commonerror=c
			EXIT FUNCTION
		END IF
	
		s$=s$+CHR$(c)
	NEXT co
'	junk=INSTR (s$,CHR$(13)+CHR$(10)+"."+CHR$(13)+CHR$(10))
	junk$=RIGHT$ (s$,5)
	IF junk$=CHR$(13)+CHR$(10)+"."+CHR$(13)+CHR$(10) THEN EXIT DO

LOOP UNTIL exitme=1

get_mail$=s$

END FUNCTION

FUNCTION conv$ (number&, bytes)
STATIC dum2$,dum1$,dum,dum2

dum2$=STR$(number&)
dum1$=MID$(dum2$,2,LEN(dum2$)-1)
dum=LEN(dum1$)
dum2=bytes-dum
dum1$=STRING$(dum2,ASC("0"))+dum1$
conv$=dum1$
dum2$="" : dum1$="" : dum=0 : dum2=0

END FUNCTION

FUNCTION getheader$ (mailnewstxt$, searchforwhat$)
STATIC dum,dum2,dum1$,dum3

dum=INSTR (UCASE$(mailnewstxt$),UCASE$(searchforwhat$))
IF dum=0 THEN getheader$="" : EXIT FUNCTION
dum2=LEN(searchforwhat$)
dum1$=MID$(mailnewstxt$,dum+dum2,LEN(mailnewstxt$)-(dum+dum2))
dum3=INSTR (dum1$,CHR$(13))
DECR dum3
getheader$=MID$(dum1$,1,dum3)
END FUNCTION

SUB displayerror
SHARED commonerror

junk=form_alert (1,"[1][ Error: | "+gerrtxt$(commonerror)+" ][ OK ]")

END SUB

SUB mailget
SHARED popserver$,password$,account$,myco,waitform
STATIC mailtxt$,messages,b$,res,resp$,i,st$,ch,tim&,dummy(),mail
STATIC mail$,megasize&,megadown&,messnum&,mailfile$
SHARED inboxpath$,stikinitialised,sam_present

mail$=popserver$
IF popserver$="" THEN
	junk=form_alert (1,"[3][ Error: POP server | not specified! ][ OK ]")
ELSE
	IF carrier_detect (dummy())<>1 THEN
		junk=form_alert (1,"[3][ Error: STiK not connected | to IP! ][ OK ]")
	ELSE
		ch=tcp_connect (mail$,110,0,2000)
		IF ch=-1 THEN
			junk=form_alert (1,"[3][ Error: connecting error! ][ OK ]")
		ELSE
			SelectTree wait
			sette_ptext connectet,popserver$
			sette_ptext stat,"Please wait, connecting to..."
			sette_ptext stat2,""
			waitform=openformwindow (" Status... ",myco,wait,0,ok,VARPTRS(closewait))
			FullReDraw waitform
			resp$=get_response$ (ch,60)
			sette_ptext stat,"Please wait, requesting status..."
			FullReDraw waitform
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(1)
			END IF
			res=tcpsend (ch, "USER "+account$)
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(2)
			END IF
			res=tcpsend (ch, "PASS "+password$)
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(3)
			END IF
			res=tcpsend (ch, "STAT")
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN
				CALL getmailerror(4)
			END IF
			
			b$=MID$(resp$,5,LEN(resp$)-4)
			FOR i=1 TO LEN(b$)
				junk=ASC(MID$(b$,i,1))
				IF junk=" "% THEN EXIT FOR
			NEXT i

			messages=VAL(MID$(b$,1,i))

			st$="You have"+STR$(messages)+" message"
			IF messages<>1 THEN st$=st$+"s"
			st$=st$+"."

			IF sam_present THEN
				IF messages=0 THEN
					junk=waveplaymacro (saa_cookie&,saa_you_have_0_messages)
				ELSE
					junk=waveplaymacro (saa_cookie&,saa_you_have_x_messages)
				END IF
			END IF

'			junk=form_alert (1,"[1][ "+st$+" ][ OK ]")

			sette_ptext stat,st$
			FullReDraw waitform

			IF messages>0 THEN

				IF FEXISTS (inboxpath$+"NETCHAT.DAT") THEN
					OPEN inboxpath$+"NETCHAT.DAT" FOR INPUT AS #2
					INPUT #2,messnum&
					CLOSE #2
				ELSE
					messnum&=1
				END IF
						
'				ser_disable dummy()
'				OPEN "MAIL.TXT" FOR APPEND AS #1
'				ser_enable dummy()

'			sette_ptext stat,st$
'			FullReDraw waitform


				FOR mail=1 TO messages
					res=tcpsend (ch, "RETR"+STR$(mail))
					sette_ptext stat,"Requesting message #"+STR$(mail)
					FullReDraw waitform
					resp$=get_response$ (ch,60)
					IF MID$(resp$,1,3)<>"+OK" THEN
						CALL getmailerror (5)
					END IF

					junk=VAL(MID$(resp$,4,LEN(resp$)-3))
					sette_ptext stat,"Receiving message #"+STR$(mail)+", size"+STR$(junk)+" bytes."
					FullReDraw waitform

					mailtxt$=get_mail$ (ch,60)
					IF mailtxt$="" THEN CALL displayerror : EXIT SUB
					megasize&=megasize&+LEN(mailtxt$)
					INCR megadown&

					ser_disable dummy()
					sette_ptext stat,"Saving message #"+STR$(mail)
					FullReDraw waitform
'					PRINT #1,mailtxt$

					mailfile$=inboxpath$+"MAIL"+conv$(messnum&,4)+".TXT"
					OPEN mailfile$ FOR OUTPUT AS #2
						PRINT #2,mailtxt$
					CLOSE #2
					INCR messnum&

					OPEN inboxpath$+"MAIL.INF" FOR APPEND AS #3
						PRINT #3,messnum&-1
						PRINT #3,getheader$ (mailtxt$,CHR$(10)+"From: ")
						PRINT #3,getheader$ (mailtxt$,CHR$(10)+"To: ")
						PRINT #3,getheader$ (mailtxt$,CHR$(10)+"Reply-To: ")
						PRINT #3,getheader$ (mailtxt$,CHR$(10)+"Subject: ")
						PRINT #3,getheader$ (mailtxt$,CHR$(10)+"Date: ")
					CLOSE #3
					ser_enable dummy()
					mailtxt$=""

				res=tcpsend (ch, "DELE"+STR$(mail))
				resp$=get_response$ (ch,60)
				IF MID$(resp$,1,3)<>"+OK" THEN
					CALL getmailerror(6)
				END IF

				NEXT
				ser_disable dummy()
				OPEN inboxpath$+"NETCHAT.DAT" FOR OUTPUT AS #2
					PRINT #2,messnum&
				CLOSE #2
				ser_enable dummy()

			END IF
			CLOSE #1
			
			res=tcpsend (ch, "QUIT")
			sette_ptext stat,"Closing connection..."
			FullReDraw waitform
			resp$=get_response$ (ch,60)
			IF MID$(resp$,1,3)<>"+OK" THEN CALL getmailerror(5)
			junk=tcp_close (ch,0)

'			tim&=CINT(TIMER)+2
'			DO
'			LOOP UNTIL CINT(TIMER)=tim&

'			CloseAWindow waitform
'			waitform=0


			st$=STR$(megadown&)+" message"
			IF megadown&<>1 THEN st$=st$+"s"
			st$=st$+" were downloaded."
			sette_ptext stat,st$
			sette_ptext stat2,"Total size"+STR$(megasize&)+"."
			sette_ptext connectet,"You may now close this window."
			FullRedraw waitform
			megasize&=0
			megadown&=0

		END IF
	END IF
END IF
END SUB

FUNCTION getusername$ (emailaddress$)
STATIC a,b

REM email (name)
REM name <email>
REM email
b=0
a=INSTR (emailaddress$,"(")
IF a>0 THEN
	b=INSTR (emailaddress$,")")
	getusername$=MID$(emailaddress$,a+1,b-a-1)
'	junk=form_alert (1,"[1][ "+MID$(emailaddress$,b-1,1)+" ][ OK ]")
	b=1
END IF
a=INSTR (emailaddress$,"<")
IF a>0 THEN
	getusername$=MID$(emailaddress$,1,a-2)
	b=1
END IF

IF b=0 THEN getusername$=emailaddress$
END FUNCTION

FUNCTION getemailaddress$ (emailaddress$)
STATIC a,b

REM email (name)
REM name <email>
REM email
b=0
a=INSTR (emailaddress$,"(")
IF a>0 THEN
	getemailaddress$=MID$(emailaddress$,1,a-2)
'	junk=form_alert (1,"[1][ "+MID$(emailaddress$,b-1,1)+" ][ OK ]")
	b=1
END IF
a=INSTR (emailaddress$,"<")
IF a>0 THEN
	b=INSTR (emailaddress$,">")
	getemailaddress$=MID$(emailaddress$,a+1,b-a-1)
	b=1
END IF

IF b=0 THEN getemailaddress$=emailaddress$
END FUNCTION

FUNCTION sizeit$ (stringtosize$,size)
STATIC a,b

IF LEN(stringtosize$)>size THEN
	sizeit$=MID$(stringtosize$,1,size)
	EXIT FUNCTION
END IF

a=LEN(stringtosize$)
b=size-a
sizeit$=stringtosize$+STRING$(b," ")

END FUNCTION

SUB inboxclose
SHARED commonclose,commonobj,inboxform,mailpos,maxmailpos,inboxpath$
SHARED minfmess(1),emailaddress$,minffrom$(1),outboxpath$,minfsub$(1)
SHARED minfreply$(1),sigfilename$,netchatver$,emailstyle,username$
STATIC oldbutton,obj,a,a$,b,replytxt$
SHARED messbutstat1,messbutstat2,messtxt1$,messtxt2$
STATIC xban,ban,banner$(1)

obj=commonobj
commonclose=0

IF (obj=upinbox) OR (obj=downinbox) THEN
	Object_redraw inboxform,obj
	IF obj=upinbox THEN
		mailpos=mailpos-10
	ELSE
		mailpos=mailpos+10
	END IF
		IF mailpos<1 THEN mailpos=1
	CALL redrawinbox
END IF

SelectTree inmail

IF obj=viewmail THEN
	commonclose=-1
	inboxform=0
	FOR a=txt1 TO txt10
		IF curob_state (a,mask_selected)<>0 THEN
			b=a+mailpos-1

			a$=inboxpath$+"MAIL"+conv$(minfmess(b),4)+".TXT"
			CALL viewfilemulti (a$)
		END IF
	NEXT a
'	fullredraw inboxform
	CALL ProcessUserMenus (0,openinbox,0)
END IF

IF obj=reply THEN
	FOR a=txt1 TO txt10
		IF curob_state (a,mask_selected)<>0 THEN
			b=a+mailpos-1
			a$=inboxpath$+"MAIL"+conv$(minfmess(b),4)+".TXT"
'			CALL viewfilemulti (a$)

			OPEN a$ FOR INPUT AS #2
			OPEN outboxpath$+"TEMP.TXT" FOR OUTPUT AS #3

			DO
				LINE INPUT #2,replytxt$
			LOOP UNTIL replytxt$=""

			b=a+mailpos-1

			IF minfreply$(b)="" THEN minfreply$(b)=minffrom$(b)
			IF getemailaddress$(minfreply$(b))<>getemailaddress$ (minffrom$(b)) THEN
				junk=form_alert (1,"[1][ To: address? ][ From | Reply-To ]")
				IF junk=1 THEN replytxt$=minffrom$(b)
				IF junk=2 THEN replytxt$=minfreply$(b)
			ELSE
				replytxt$=minfreply$(b)
				IF replytxt$="" THEN replytxt$=minffrom$(b)
			END IF
			
			PRINT #3,"To: "+getemailaddress$(replytxt$)

REM Type 1 Paul Jones <paulat.jones...>
REM Type 2 paulat.jones@zetnet.co.uk (Paul Jones)
REM Type 3 paulat.jones@zetnet.co.uk

			SELECT CASE emailstyle
				CASE 1
					replytxt$=username$+" <"+emailaddress$+">"
				CASE 2
					replytxt$=emailaddress$+" ("+username$+")"
				CASE 3
					replytxt$=emailaddress$
			END SELECT
			PRINT #3,"From: "+replytxt$
			PRINT #3,"Reply-To: "+emailaddress$
			replytxt$=minfsub$(b)
			IF INSTR (replytxt$,"Re: ")=0 THEN
				replytxt$="Re: "+replytxt$
			END IF
			PRINT #3,"Subject: "+replytxt$
			PRINT #3,"X-Mailer: NetChat v"+netchatver$+" (Atari) by Paul Jones"
'			PRINT #3,"X-comment: If Atari is dead then #atari is heaven."

			IF messbutstat1=1 THEN
				IF FEXISTS(messtxt1$) THEN
					OPEN messtxt1$ FOR INPUT AS #5
					ban=1
					DO
						LINE INPUT #5,replytxt$
						REDIM PRESERVE banner$(ban)
						banner$(ban)=replytxt$
						INCR ban
					LOOP UNTIL EOF (5)
					
					DO
						xban=CINT(RANDOM&/100000)
					LOOP UNTIL xban<=ban
					
					PRINT #3,"X-Comment: "+banner$(xban)
				ERASE banner$
				END IF
			END IF

			PRINT #3
			PRINT #3
			PRINT #3,"You wrote: "
			PRINT #3
			
			DO
				LINE INPUT #2,replytxt$
				replytxt$=">"+replytxt$
				PRINT #3,replytxt$
			LOOP UNTIL EOF(2)

			IF FEXISTS (sigfilename$) THEN
				PRINT #3
				PRINT #3,"---"
				OPEN sigfilename$ FOR INPUT AS #4

				DO
					LINE INPUT #4,replytxt$
					PRINT #3,replytxt$
				LOOP UNTIL EOF(4)
				CLOSE #4
			END IF

			CLOSE #2
			CLOSE #3
			
			CALL viewfilemulti (outboxpath$+"TEMP.TXT")
						
		END IF
	NEXT a
END IF

IF obj=ok THEN
	commonclose=-1
	inboxform=0
END IF

'oldbutton=commonobj

END SUB

SUB redrawinbox
SHARED mailpos,maxmailpos,inboxpath$
SHARED minfmess(1),minffrom$(1),minfto$(1),minfreply$(1),minfsub$(1)
SHARED minfdate$(1),inboxform
STATIC a,x,boxnum

REDIM minfmess(1),minffrom$(1),minfto$(1),minfreply$(1),minfsub$(1)
REDIM minfdate$(1)

x=1

OPEN inboxpath$+"MAIL.INF" FOR INPUT AS #2
	WHILE NOT EOF(2)
		INPUT #2,minfmess(x)
		LINE INPUT #2,minffrom$(x)
		LINE INPUT #2,minfto$(x)
		LINE INPUT #2,minfreply$(x)
		LINE INPUT #2,minfsub$(x)
		LINE INPUT #2,minfdate$(x)
		INCR x
		REDIM PRESERVE minfmess(x),minffrom$(x),minfto$(x),minfreply$(x)
		REDIM PRESERVE minfsub$(x),minfdate$(x)
	WEND

CLOSE #2

maxmailpos=x

boxnum=txt1

SelectTree inmail

FOR a=mailpos TO mailpos+10
	IF a>maxmailpos OR boxnum>txt10 THEN
		FOR junk=boxnum TO txt10
			sette_ptext junk,""
			Exclob_flags junk,mask_selectable+mask_rbutton
		NEXT
		EXIT FOR
	END IF
		
'	sette_ptext boxnum,minffrom$(a)
	sette_ptext boxnum,sizeit$(getusername$(minffrom$(a)),25)+" "+sizeit$(minfsub$(a),30)+" "+sizeit$(minfdate$(a),30)

	IF minffrom$(a)<>"" THEN
		Inclob_flags boxnum,mask_selectable+mask_rbutton
		Exclob_state boxnum,mask_selected
	ELSE
		Exclob_flags boxnum,mask_selectable+mask_rbutton
		sette_ptext boxnum,""
		Exclob_state boxnum,mask_selected
	END IF
	INCR boxnum
NEXT a

Fullredraw inboxform

END SUB


SUB infobox
SHARED aboutform
aboutform=0
END SUB

SUB closeprog
SHARED editorpath$,commonobj,outboxpath$,fsmessage$,fspather$,editorsupportsva
STATIC oldoutboxpath$,oldeditorpath$,dummy$,oldinboxpath$
SHARED progform,inboxpath$

progform=0
SelectTree program
SELECT CASE commonobj
	CASE progcancel
		sette_ptext editpath,editorpath$
		sette_ptext outbox,outboxpath$
		sette_ptext inbox,inboxpath$
		IF editorsupportsva=1 THEN
			Inclob_state editorva,mask_selected
		ELSE
			Exclob_state editorva,mask_selected
		END IF
	CASE progset
		editorpath$=gette_ptext$(editpath)
		outboxpath$=gette_ptext$(outbox)
		inboxpath$=gette_ptext$(inbox)
		IF curob_state (editorva,mask_selected)<>0 THEN
			editorsupportsva=1
		ELSE
			editorsupportsva=0
		END IF
	CASE fsel1
		oldeditorpath$=editorpath$
		fsmessage$="Please select editor..."
		editorpath$=fileselect$
		IF editorpath$="" THEN editorpath$=oldeditorpath$
		IF editorpath$<>"" THEN sette_ptext editpath,editorpath$
		CALL ProcessUserMenus (0,progsett,0)
	CASE fsel2
		oldoutboxpath$=outboxpath$
		fsmessage$="Please select outbox path..."
		dummy$=fileselect$
		outboxpath$=fspather$
		IF outboxpath$="" THEN outboxpath$=oldoutboxpath$
		IF outboxpath$<>"" THEN sette_ptext outbox,outboxpath$
		CALL ProcessUserMenus (0,progsett,0)
	CASE fsel3
		oldinboxpath$=inboxpath$
		fsmessage$="Please select inbox path..."
		dummy$=fileselect$
		inboxpath$=fspather$
		IF inboxpath$="" THEN inboxpath$=oldinboxpath$
		IF inboxpath$<>"" THEN sette_ptext inbox,inboxpath$
		CALL ProcessUserMenus (0,progsett,0)
END SELECT


END SUB

SUB closeserver
SHARED smtpserver$,popserver$,newsserver$,commonobj
SHARED serform

serform=0

SelectTree server
SELECT CASE commonobj
	CASE cancelserver
		sette_ptext smtp,smtpserver$
		sette_ptext pop3,popserver$
		sette_ptext news,newsserver$
	CASE setserver
		smtpserver$=gette_ptext$ (smtp)
		popserver$=gette_ptext$ (pop3)
		newsserver$=gette_ptext$ (news)
END SELECT
END SUB	

SUB closepersonal
SHARED commonobj,username$,emailaddress$,organisation$
SHARED persform,password$,account$
persform=0

SelectTree personal
SELECT CASE commonobj
	CASE perscancel
		sette_ptext usrname,username$
		sette_ptext password,password$
		sette_ptext account,account$
		sette_ptext email,emailaddress$
		sette_ptext organ,organisation$
	CASE persok
		username$=gette_ptext$ (usrname)
		password$=gette_ptext$ (password)
		account$=gette_ptext$ (account)
		emailaddress$=gette_ptext$ (email)
		organisation$=gette_ptext$ (organ)
END SELECT
END SUB

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

SUB Execute(nname$,commline$)
SHARED menutree&,Windx,Windy,Windw,Windh,HowManyWindows,woHandle(1)
SHARED desktree&
STATIC junk&,junk,wind_temp(2),curhandle,i,curtop
STATIC dummypath1$,dummypath2$,dummydrive,pe,mxprogs

mxprogs=PEEKW(PEEKL(GB+4)+ap_count)
IF mxprogs=-1 THEN pe=100 ELSE pe=0

IF pe=0 THEN
	junk=wind_get(0,WF_TOP,curtop,0,0,0)
	DIM windtemp(HowmanyWindows,4)
	FOR i=1 TO HowManyWindows
		curhandle=woHandle(i)
		junk=wind_get(curhandle,WF_CURRXYWH,windtemp(i,1),windtemp(i,2),windtemp(i,3),windtemp(i,4)) ' current size
		junk=wind_close(woHandle(i))
	NEXT i

IF menutree& THEN menu_bar menutree&,0

junk=wind_update(END_UPDATE)

END IF

dummypath1$=killpath$ (nname$)
dummypath2$=CURDIR$
dummydrive=dgetdrv

junk=dsetdrv (ASC(MID$(dummypath1$,1,1))-ASC("A"))
CHDIR dummypath1$


junk&=pexec&(pe,nname$,commline$,GetWholeEnvironment$)

junk=dsetdrv (dummydrive)
CHDIR dummypath2$

IF pe=0 THEN

junk=wind_set(0,WF_NEWDESK,PEEKW(VARPTR(desktree&)),PEEKW(VARPTR(desktree&)+2),0,0)


IF menutree& THEN menu_bar menutree&,1
FOR i=1 TO HowManyWindows
	junk=wind_open(woHandle(i),windtemp(i,1),windtemp(i,2),windtemp(i,3),windtemp(i,4)) ' current size
NEXT i
ERASE windtemp
junk=wind_set(0,WF_TOP,curtop,0,0,0)
form_dial FMD_FINISH,0,0,0,0,Windx,Windy,Windw,Windh

junk=wind_update(BEG_UPDATE)

END IF

END SUB

SUB va_send (to$,commline$)
STATIC a$,a&,c$,c&,i

a$=SPACE$(16) : a&=VARPTR(a$)
'c$="H:\MODS\INTRO.MOD"+CHR$(0) : c&=VARPTR(c$)
c$=commline$+CHR$(0) : c&=VARPTR(c$)

i=appl_find(to$)

IF i=-1 THEN junk=form_alert (1,"[1][ FILE Not here! ][ OK ]")

IF i<>-1 THEN

POKEW a&,&H4711
POKEW a&+2,PEEKW(PEEKL(GB+4)+4)
POKEW a&+4,0
POKEL a&+6,c&
POKEW a&+10,0

appl_write i,16,a&
END IF


END SUB

SUB ViewFileMulti (filename$)
SHARED editorpath$,editorsupportsva
STATIC mxprogs,editorva$

mxprogs=PEEKW(PEEKL(GB+4)+ap_count)

IF editorpath$="" THEN
	junk=form_alert (1,"[1][ No editor set! ][ OK ]")
ELSE
	IF mxprogs=-1 THEN
		editorva$=killname$ (editorpath$)
'		junk=form_alert (1,"[1][ '"+editorva$+"' ][ OK ]")
		IF appl_find (editorva$)<>-1 AND editorsupportsva=1 THEN
			CALL va_send (editorva$,filename$)
		ELSE
			CALL Execute (editorpath$,filename$)
		END IF
	ELSE
		CALL Execute (editorpath$,filename$)
	END IF
END IF

END SUB

SUB closesignature
SHARED commonobj,sigfilename$,oldsigfile$,fsmessage$,fspather$
STATIC sigerfile$,dummy$,sigformer
SHARED sigform
sigformer=sigform
sigform=0

SelectTree signature
SELECT CASE commonobj
	CASE sigcancel
		sette_ptext siggy,sigfilename$
		sigfilename$=oldsigfile$
		oldsigfile$=""
	CASE sigset
		sigfilename$=gette_ptext$ (siggy)
		oldsigfile$=""
	CASE sigview
		sigerfile$=gette_ptext$ (siggy)
		CALL viewfilemulti (sigerfile$)
	CASE fselsig
		IF oldsigfile$="" THEN oldsigfile$=sigfilename$
		fsmessage$="Please select signature file..."
		sigfilename$=fileselect$
		IF sigfilename$="" THEN sigfilename$=oldsigfile$
		IF sigfilename$<>"" THEN sette_ptext siggy,sigfilename$
		CALL ProcessUserMenus (0,sigfile,0)
END SELECT

END SUB

SUB emailoptsclose
SHARED commonobj,emailstyle,emailoptsform

emailoptsform=0

SelectTree emailopts
SELECT CASE commonobj
	CASE emailcancel
		SELECT CASE emailstyle
			CASE 1
				junk=emailbut1
			CASE 2
				junk=emailbut2
			CASE 3
				junk=emailbut3
		END SELECT
		SetButton emailbox,junk
	CASE emailset
		junk=GetButton (emailbox)
		SELECT CASE junk
			CASE emailbut1
				emailstyle=1
			CASE emailbut2
				emailstyle=2
			CASE emailbut3
				emailstyle=3
		END SELECT
END SELECT
END SUB

SUB messoptsclose
SHARED commonobj,oldmesstxt1$,oldmesstxt2$,messtxt1$,messoptsform
SHARED messbutstat1,messbutstat2,fsmessage$,commonclose,messtxt2$
STATIC dummy$

SelectTree messageopts

SELECT CASE commonobj
	CASE messcancel
		sette_ptext xcfile,oldmesstxt1$
		sette_ptext xhfile,oldmesstxt2$
		IF messbutstat1=1 THEN
			Inclob_state messbut1,mask_selected
		ELSE
			Exclob_state messbut1,mask_selected
		END IF
		IF messbutstat2=1 THEN
			Inclob_state messbut2,mask_selected
		ELSE
			Exclob_state messbut2,mask_selected
		END IF
		commonclose=-1
		messoptsform=0
	CASE messset
		messtxt1$=gette_ptext$(xcfile)
		messtxt2$=gette_ptext$(xhfile)
		IF curob_state (messbut1,mask_selected)<>0 THEN
			messbutstat1=1
		ELSE
			messbutstat1=0
		END IF
		IF curob_state (messbut2,mask_selected)<>0 THEN
			messbutstat2=1
		ELSE
			messbutstat2=0
		END IF
		commonclose=-1
		messoptsform=0
	CASE messfsel1
		oldmesstxt1$=messtxt1$
		fsmessage$="Please select comment filename..."
		messtxt1$=fileselect$
		IF messtxt1$="" THEN messtxt1$=oldmesstxt1$
		IF messtxt1$<>"" THEN sette_ptext xcfile,messtxt1$
		commonclose=0
		FullReDraw messoptsform
	CASE messfsel2
		oldmesstxt2$=messtxt2$
		fsmessage$="Please select extra header file..."
		messtxt2$=fileselect$
		IF messtxt2$="" THEN messtxt2$=oldmesstxt2$
		IF messtxt2$<>"" THEN sette_ptext xhfile,messtxt2$
		commonclose=0
		FullReDraw messoptsform
END SELECT
END SUB

SUB closeyellow
SHARED yellowform
yellowform=0
END SUB

SUB changeslider (sliderpos)
STATIC calc1!,calc2!
SHARED yellowform

'junk=form_alert (1,"[1][ "+STR$(sliderpos)+" ][ OK ]")

SelectTree pages
calc1!=sliderpos/1000
calc2!=getob_height (slider2)*calc1!
setob_y slider1,CINT(calc2!)
Object_Redraw yellowform,slider1
Object_Redraw yellowform,slider2

'junk=form_alert (1,"[1][ "+STR$(calc2#)+" ][ OK ]")

END SUB 

SUB ProcessUserMenus (VAL wind, item, VAL title)
STATIC dummy,finished
SHARED finished,myco
SHARED editorpath$,smtpserver$,popserver$,newsserver$,username$,emailaddress$
SHARED outboxpath$,organisation$,sigfilename$
SHARED aboutform,progform,serform,persform,sigform,yellowform
SHARED clickfront,clickback,mytree&,clickvert
SHARED editorsupportsva,password$,account$,inboxpath$,commonclose,inboxform
SHARED emailoptsform,messoptsform,emailstyle,messtxt1$,messtxt2$,messbutstat1
SHARED messbutstat2

SELECT CASE item
	CASE savesettings:
		junk=form_alert (1,"[2][ Save settings? ][ Yes | No ]")
		IF junk=1 THEN
			OPEN "NETCHAT.INF" FOR OUTPUT AS #1
			BusyBee 1
			PRINT #1,editorpath$
			PRINT #1,smtpserver$
			PRINT #1,popserver$
			PRINT #1,newsserver$
			PRINT #1,username$
			PRINT #1,emailaddress$
			PRINT #1,outboxpath$
			PRINT #1,organisation$
			PRINT #1,sigfilename$
			PRINT #1,editorsupportsva
			PRINT #1,password$
			PRINT #1,account$
			PRINT #1,inboxpath$
			PRINT #1,emailstyle
			PRINT #1,messtxt1$
			PRINT #1,messtxt2$
			PRINT #1,messbutstat1
			PRINT #1,messbutstat2
			CLOSE #1
			BusyBee 0
		END IF
	CASE about:
		IF aboutform=0 THEN
			aboutform=openformwindow (" About NetChat ",myco,infodi,0,ok,VARPTRS(infobox))
		ELSE
			TopAWindow aboutform
		END IF
	CASE progsett:
		IF progform=0 THEN
			progform=openformwindow (" Program settings ",myco,program,editpath,progcancel,VARPTRS(closeprog))
		ELSE
			TopAWindow progform
		END IF
	CASE sersett
		IF serform=0 THEN
			serform=openformwindow (" Server settings ",myco,server,smtp,cancelserver,VARPTRS(closeserver))
		ELSE
			TopAWindow serform
		END IF
	CASE usersett
		IF persform=0 THEN
			persform=openformwindow (" User settings ",myco,personal,usrname,perscancel,VARPTRS(closepersonal))
		ELSE
			TopAWindow persform
		END IF
	CASE sigfile
		IF sigform=0 THEN
			sigform=openformwindow (" Signature options ",myco,signature,siggy,sigcancel,VARPTRS(closesignature))
		ELSE
			TopAWindow sigform
		END IF
	CASE yellow
		IF yellowform=0 THEN
			clickfront=slider1 : clickback=slider2 : junk=rsrc_gaddr(0,pages,mytree&) : clickvert=1
			yellowform=openformwindow (" Yellow pages ",myco,pages,0,ok,VARPTRS(closeyellow))
		ELSE
			TopAWindow yellowform
		END IF
	CASE checkmail
		CALL emailcheck
	CASE newemail
		CALL emailnew
	CASE getmail
		CALL mailget
	CASE openinbox
		IF inboxform=0 THEN
			inboxform=openformwindow (" Inbox ",myco,inmail,0,ok,VARPTRS(inboxclose))
		ELSE
			TopAWindow inboxform
		END IF
		CALL redrawinbox
	CASE eopts
		IF emailoptsform=0 THEN
			emailoptsform=openformwindow (" Email options ",myco,emailopts,0,emailcancel,VARPTRS(emailoptsclose))
		ELSE
			TopAWindow emailoptsform
		END IF
	CASE messopts
		IF messoptsform=0 THEN
			messoptsform=openformwindow (" Message options ",myco,messageopts,0,messcancel,VARPTRS(messoptsclose))
		ELSE
			TopAWindow messoptsform
		END IF
END SELECT
END SUB

StartProgram "NETCHAT.RSC",menu,quit

multitask_name ("  NetChat")

IF stikinitialised<>1 THEN
	a=form_alert (1,"[3][ STiK is *not* installed | correctly! ][ OK ]")
	menu_ienable menutree&,checkmail,0
	menu_ienable menutree&,getmail,0
END IF

netchatver$="0.41"
myco=win_name+win_move+win_close+&H4000
mint=GETCOOKIE ("MiNT",junk&)
sam_present=GETCOOKIE ("SAM"+CHR$(0),junk&)
IF mint THEN dummy=shel_write (9,1,0,0,0)
	REM Tell GEM we can understand AP_TERM's
IF sam_present THEN junk=waveplayglobal (0)

SelectTree infodi
sette_ptext version,netchatver$
sette_ptext datecreated,"19/08/1997"

' Load settings

IF FEXISTS ("NETCHAT.INF") THEN
	OPEN "NETCHAT.INF" FOR INPUT AS #1
	LINE INPUT #1,editorpath$
	LINE INPUT #1,smtpserver$
	LINE INPUT #1,popserver$
	LINE INPUT #1,newsserver$
	LINE INPUT #1,username$
	LINE INPUT #1,emailaddress$
	LINE INPUT #1,outboxpath$
	LINE INPUT #1,organisation$
	LINE INPUT #1,sigfilename$
	INPUT #1,editorsupportsva
	LINE INPUT #1,password$
	LINE INPUT #1,account$
	LINE INPUT #1,inboxpath$
	INPUT #1,emailstyle
	LINE INPUT #1,messtxt1$
	LINE INPUT #1,messtxt2$
	INPUT #1,messbutstat1
	INPUT #1,messbutstat2
	CLOSE #1
ELSE
	editorpath$=""
	smtpserver$=""
	popserver$=""
	newsserver$=""
	username$=""
	emailaddress$=""
	outboxpath$=""
	organisation$=""
	sigfilename$=""
	editorsupportsva=0
	password$=""
	account$=""
	inboxpath$=""
	emailstyle=1
	messtxt1$=""
	messtxt2$=""
	messbutstat1=0
	messbutstat2=0
END IF 

IF smtpserver$="" THEN
	smtpserver$=gvstr$ ("SMTPSERVER")
	IF smtpserver$="0" THEN smtpserver$=""
END IF

IF popserver$="" THEN
	popserver$=gvstr$ ("POPSERVER")
	IF popserver$="0" THEN popserver$=""
END IF

IF newsserver$="" THEN
	newsserver$=gvstr$ ("NEWSSERVER")
	IF newsserver$="0" THEN newsserver$=""
END IF

IF username$="" THEN
	username$=gvstr$ ("FULLNAME")
	IF username$="0" THEN username$=""
END IF

IF emailaddress$="" THEN
	emailaddress$=gvstr$ ("EMAIL")
	IF emailaddress$="0" THEN emailaddress$=""
END IF

IF account$="" THEN
	account$=gvstr$ ("USERNAME")
	IF account$="0" THEN account$=""
END IF

SelectTree program
sette_ptext editpath,editorpath$
sette_ptext outbox,outboxpath$
sette_ptext inbox,inboxpath$
IF editorsupportsva=1 THEN
	Inclob_state editorva,mask_selected
ELSE
	Exclob_state editorva,mask_selected
END IF

SelectTree server
sette_ptext smtp,smtpserver$
sette_ptext pop3,popserver$
sette_ptext news,newsserver$

SelectTree personal
sette_ptext usrname,username$
sette_ptext password,password$
sette_ptext account,account$
sette_ptext email,emailaddress$
sette_ptext organ,organisation$

SelectTree signature
sette_ptext siggy,sigfilename$

SelectTree emailopts
SELECT CASE emailstyle
	CASE 1:
		setbutton emailbox,emailbut1
	CASE 2:
		setbutton emailbox,emailbut2
	CASE 3:
		setbutton emailbox,emailbut3
END SELECT

SelectTree messageopts
sette_ptext xcfile,messtxt1$
sette_ptext xhfile,messtxt2$

IF messbutstat1=1 THEN
	Inclob_state messbut1,mask_selected
ELSE
	Exclob_state messbut2,mask_selected
END IF

IF messbutstat2=1 THEN
	Inclob_state messbut1,mask_selected
ELSE
	Exclob_state messbut2,mask_selected
END IF


mailpos=1
xHGTloop
stopprogram
'CALL main