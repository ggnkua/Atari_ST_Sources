'$option q450,!gy

'$include toolbox.bas
'$include menu.bas
'$include objcext.bas
'$include xformdo.bas
'$include window.bas
'$include objwind.bas
'$include formwind.bas
'$include popup.bas
'$include filesel.bas
'$include exec2.bas

'$INCLUDE install.BH

DEFINT a-z

SUB ex1
STATIC d1$,i$(1),st$,d1,d2$,dummy
SHARED i$(1),st$

REM ##T1  Doh! Text about goes here...

d1$=MID$(st$,4,2)
d1=VAL(d1$)+5

d2$=MID$(st$,7,LEN(st$)-6)
i$(d1)=d2$

END SUB

SUB ex2
STATIC d1$,te$(1),st$,d1,d2$
SHARED te$(1),st$

REM ##F1 EXAMPLE NAME

d1$=MID$(st$,4,2)
d1=VAL(d1$)+1
d2$="  "+MID$(st$,6,LEN(st$)-5)

te$(d1)=d2$

END SUB

SUB ex3
STATIC d1$,te$(1),st$,d1,d2$,fil$(1)
SHARED te$(1),st$,fil$(1)

REM ##L1 EXAMPLE.TOS

d1$=MID$(st$,4,2)
d1=VAL(d1$)+1
d2$=MID$(st$,6,LEN(st$)-5)

fil$(d1)=d2$

END SUB

SUB ex4
STATIC d1$,te$(1),st$,d1,d2$,by$(1)
SHARED te$(1),st$,by$(1)

REM ##B1 Paul Jones

d1$=MID$(st$,4,2)
d1=VAL(d1$)+1
d2$=MID$(st$,6,LEN(st$)-5)

by$(d1)=d2$

END SUB

SUB ex5
STATIC d1$,te$(1),st$,d1,d2$,mac$(1)
SHARED te$(1),st$,mac$(1)

REM ##C1 123456

d1$=MID$(st$,4,2)
d1=VAL(d1$)+1
d2$=MID$(st$,6,LEN(st$)-5)

mac$(d1)=d2$

END SUB

SUB ex6
STATIC d1$,te$(1),st$,d1,d2$,mem$(1)
SHARED te$(1),st$,mem$(1)

REM ##S1 512

d1$=MID$(st$,4,2)
d1=VAL(d1$)+1
d2$=MID$(st$,6,LEN(st$)-5)

mem$(d1)=d2$

END SUB

SUB ex7
STATIC d1$,te$(1),st$,d1,d2$,size$(1)
SHARED te$(1),st$,size$(1)

REM ##U1 132

d1$=MID$(st$,4,2)
d1=VAL(d1$)+1
d2$=MID$(st$,6,LEN(st$)-5)

size$(d1)=d2$

END SUB

SUB Comm
STATIC s$,st$,f$,title$,ish$
SHARED s$,st$,f$,title$,ish$

s$=MID$(st$,5,LEN(st$)-4)
f$=MID$(st$,3,1)

REM ##I  1
REM ##M Atari Computing Cover Disc 1
REM ##F1 PS Example
REM ##L1 TEST.LZH
REM ##T1  Doh!

IF f$="M" THEN title$=s$
IF f$="I" THEN ish$=s$
IF f$="T" THEN CALL ex1
IF f$="F" THEN CALL ex2
IF f$="L" THEN CALL ex3
IF f$="B" THEN CALL ex4
IF f$="C" THEN CALL ex5
IF f$="S" THEN CALL ex6
IF f$="U" THEN CALL ex7
END SUB

SUB processusermenus(VAL topwin,VAL item,VAL title)
SHARED myhandle,title$,infobox,commonclose,ver$
STATIC res,title$,commonclose,infobox,ver$

Commonclose=0

SELECT CASE item
	CASE mpop
		IF myhandle THEN
			TopAWindow myhandle
		ELSE
			myhandle=openformwindow(" PJCO install: "+title$,&h0B,dialog,0,ok_but,VARPTRS(close_dialog))
		END IF
	CASE mabout
infobox=form_alert (1,"[1][ PJCO Install by Paul Jones | for PJCO. ½1997. Version "+ver$+"][ Ok ]")

END SELECT
END SUB

SUB seter
STATIC res,d1,i$(1),dummy,res$,a,te$(1),res2,myhandle,by$(1),d$,mch&,mch$
SHARED res,i$(1),res$,te$(1),res2,myhandle,by$(1)
STATIC fil$(1),mem$(1),mac$(1),size$(1)
SHARED fil$(1),mem$(1),mac$(1),size$(1)


FOR a=1 TO 12
IF te$(a)<>"" THEN
	IF MID$(te$(a),3,LEN(te$(a))-2)=MID$(res$,3,LEN(res$)-2) THEN res2=a
REM dummy=form_alert (1,"[1][ t$='"+te$(a)+"' | res$='"+res$+"' | res2="+STR$(res2)+" ][ Ok ]")
END IF
NEXT a

IF res$<>"  Install" THEN
	SelectTree models
	Setob_state t1,mask_normal
	SelectTree dialog
	Exclob_state install,mask_disabled
	Object_redraw myhandle,install
ELSE
	SelectTree dialog
	Inclob_state install,mask_disabled
	Object_redraw myhandle,install
END IF 

d1=(res2*5)-4

SelectTree dialog

REM dummy=form_alert (1,"[1][ Number:"+STR$(d1)+" ][ Ok ]")

REM Text---------------------

Object_redraw myhandle,pop_but

Sette_ptext i1,i$(d1)
Sette_ptext i2,i$(d1+1)
Sette_ptext i3,i$(d1+2)
Sette_ptext i4,i$(d1+3)
Sette_ptext i5,i$(d1+4)

Object_redraw myhandle,i1
Object_redraw myhandle,i2
Object_redraw myhandle,i3
Object_redraw myhandle,i4
Object_redraw myhandle,i5

Sette_ptext by,by$(res2)
Object_redraw myhandle,by

Sette_ptext fil,fil$(res2)
Object_redraw myhandle,fil

Sette_ptext mem,mem$(res2)+"K"
Object_redraw myhandle,mem

REM Machine type...

d$=""

IF INSTR (mac$(res2),"1") THEN d$=d$+",ST/Mega ST"
IF INSTR (mac$(res2),"2") THEN d$=d$+",STe"
IF INSTR (mac$(res2),"3") THEN d$=d$+",ST Book"
IF INSTR (mac$(res2),"4") THEN d$=d$+",Mega STe"
IF INSTR (mac$(res2),"5") THEN d$=d$+",TT"
IF INSTR (mac$(res2),"6") THEN d$=d$+",Falcon 030"

d$=MID$(d$,2,LEN(d$)-1)

IF GETCOOKIE ("_MCH",mch&)=0 THEN mch&=0
IF mch&=0 THEN mch$="ST/Mega ST"
IF mch&=65536 THEN mch$="STe"
IF mch&=65544 THEN mch$="ST Book"
IF mch&=65552 THEN mch$="Mega STe"
IF mch&=131072 THEN mch$="TT"
IF mch&=196608 THEN mch$="Falcon 030"

IF INSTR(d$,mch$)=0 THEN
	d$=d$+"*"
	Sette_ptext com,"**** Incompatable ****"
	Object_redraw myhandle,com
ELSE
	Sette_ptext com,""
	Object_redraw myhandle,com
END IF


Sette_ptext machine,d$
Object_redraw myhandle,machine

Sette_ptext siz,size$(res2)+"K"
Object_redraw myhandle,siz

REM Object_redraw myhandle,0

REM FullRedraw myhandle

REM DECR res
END SUB

SUB setname
STATIC te$(1),a
SHARED te$(1)

SelectTree models

IF te$(1)<>"" THEN Sette_ptext t1,te$(1) : Setob_state t1,mask_normal
IF te$(2)<>"" THEN Sette_ptext t2,te$(2) : Setob_state t2,mask_normal
IF te$(3)<>"" THEN Sette_ptext t3,te$(3) : Setob_state t3,mask_normal
IF te$(4)<>"" THEN Sette_ptext t4,te$(4) : Setob_state t4,mask_normal
IF te$(5)<>"" THEN Sette_ptext t5,te$(5) : Setob_state t5,mask_normal
IF te$(6)<>"" THEN Sette_ptext t6,te$(6) : Setob_state t6,mask_normal
IF te$(7)<>"" THEN Sette_ptext t7,te$(7) : Setob_state t7,mask_normal
IF te$(8)<>"" THEN Sette_ptext t8,te$(8) : Setob_state t8,mask_normal
IF te$(9)<>"" THEN Sette_ptext t9,te$(9) : Setob_state t9,mask_normal
IF te$(10)<>"" THEN Sette_ptext t10,te$(10) : Setob_state t10,mask_normal
IF te$(11)<>"" THEN Sette_ptext t11,te$(11) : Setob_state t11,mask_normal
IF te$(12)<>"" THEN Sette_ptext t12,te$(12) : Setob_state t12,mask_normal

END SUB

FUNCTION get_pop_text$(BYVAL poptree,BYVAL popobj)
STATIC oldtree&,te$(1)
SHARED te$(1)
oldtree&=tree&
selecttree poptree
get_pop_text$=te$(popobj)
tree&=oldtree&
END FUNCTION

SUB AlertDialog(stat)
STATIC x,y,w,h,but,stat

IF stat=1 THEN
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
form_dial FMD_GROW,x+w\2,y+h\2,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
END IF

IF stat=0 THEN
form_dial FMD_SHRINK,x+w\2,y+h\2,0,0,x,y,w,h
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
END IF

IF stat=3 THEN
form_center tree&,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
END IF

IF stat=4 THEN
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
END IF


END SUB


SUB Inst
STATIC res$,gh,dir$,dir2$,dir3$,l&,l2&,l3&,l4&,l5&,dummy$,ex$,b,commonclose
SHARED res$,gh,dir$,dir2$,dir3$,l&,l2&,l3&,l4&,l5&,dummy$,ex$,b,commonclose
STATIC insbox,tic,fil$(1),res2,te$(1),dummy,ab,dir4$,dir5$,askp,myhandle
SHARED insbox,tic,fil$(1),res2,te$(1),ab,dir4$,dir5$,askp,myhandle

ab=0

SelectTree inst

IF res$<>"All" THEN
	Sette_ptext fileex,res$
ELSE
	Sette_ptext fileex,res$+"  -"+te$(res2)
END IF

dir4$=dir$

Setob_width slide,1

IF tic=1 THEN
REM	dummy=form_alert (1,"[1][ CHDIR='"+dir$+"' | MKDIR='"+dir2$+"' | CHDIR '"+dir3$+"' ][ Ok ]")
	gh=dsetdrv%(ASC(MID$(dir$,1,1))-ASC("A"))
	CHDIR dir$
	MKDIR dir2$
	gh=dsetdrv%(ASC(MID$(ex$,1,1))-ASC("A"))
	CHDIR ex$
	dir$=dir3$
END IF 

IF ab=0 THEN

commonclose=-1
Inclob_state ok5,mask_disabled
Sette_ptext statu,"Copying"
insbox=openformwindow (" PJCO Install: Installing... ",&h0b,inst,0,ok5,VARPTRS(Close_Dialog3))
Object_Redraw insbox,0

OPEN fil$(res2) FOR INPUT AS #1
OPEN dir$+fil$(res2) FOR OUTPUT AS #2
l&=LOF(1)
l2&=l&

l3&=l2&/100

l4&=1024
 
DO
l&=l&-l4& : IF l&<0 THEN l&=l&+l4& : l4&=l&

l5&=l5&+l4&

dummy$=INPUT$ (l4&,#1)
PRINT #2,dummy$;

Setob_width slide,ABS((l5&/l2&)*100)*4
Sette_ptext per,STR$(CINT((l5&/l2&)*100))

Object_redraw insbox,slide
Object_redraw insbox,per

LOOP UNTIL l5&=l2&
CLOSE #1

l&=0
l2&=0
l3&=0
l4&=0
l5&=0

Sette_ptext statu,"De-crunching"
Object_redraw insbox,statu
Execute ex$+"INSTALL.DAT","X /q "+dir$+fil$(res2)+" "+dir$
b=cursconf% (0,0)

KILL dir$+fil$(res2)

Exclob_state ok5,mask_disabled
Object_redraw insbox,ok5

Sette_ptext statu,"Installed OK"
Object_Redraw insbox,statu

REM CloseAWindow insbox

REM IF askp<>0 THEN
REM CloseAWindow askp
REM askp=0
REM END IF

dir$=dir5$

REM TopAWindow myhandle
REM Object_Redraw myhandle,0

END IF

END SUB

SUB Close_dialog3
SHARED commonclose,myhandle,commonobj,res$,infobox,insbox,res2,fil$(1)
SHARED askp,dir$,dir2$,dir3$,dummo
STATIC x,y,res$,res,dummy,insbox,res2,fil$(1),l&,l2&,l3&,l4&,l5&
STATIC dummy$,askp,dir$,i,ch,dir2$,dir3$,dummo,infobox

SELECT CASE commonobj

	CASE=ok4
		commonclose=-1
REM closeawindow dummo
		dummo=0
	CASE=ok5
CloseAWindow insbox
		commonclose=-1
		insbox=0

IF commonclose=0 THEN Object_Redraw infobox,commonobj
END SELECT
END SUB

SUB Close_dialog2
SHARED askp,commonobj,dir$,f2$,fspath$,fsname$,fsmessage$,f2$,commonclose
SHARED insbox,l&,l2&,l3&,l4&,l5&,res$,fil$(1),res2,dummy$,ex$
STATIC askp,commonobj,dir$,f2$,fspath$,fsname$,fsmessage$,f2$,commonclose
STATIC insbox,l&,l2&,l3&,l4&,l5&,res$,fil$(1),res2,dummy$,i,ch,ex$,b
SHARED dir2$,dir3$,ex$,tic,dir4$,dir5$,myhandle
STATIC dir2$,dir3$,ex$,gh,tic,dum,dir4$,dir5$,myhandle

commonclose=0

REM	Commonclose=-1
REM 	askp=0

SELECT CASE commonobj

	CASE cancel
		Commonclose=-1
REM closeawindow askp
		askp=0
	CASE showdir
 	Object_redraw askp,showdir
		commonobj=change

	CASE change
		Object_redraw askp,change

			IF INSTR(dir$,dir2$)<>0 THEN 
				dir$=MID$(dir$,INSTR(dir$,dir2$),LEN(dir$)-INSTR(dir$,dir2$))+"\*.*"
			END IF

		fspath$=dir$
		fsname$=""
		fsmessage$="Destination folder..."
		f2$=fileselect$

		IF fspath$<>"" OR f2$<>"" THEN

	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 

dir$=LEFT$(fspath$,i)

dir5$=dir$

	i=LEN(fil$(res2))

	DO
		ch=ASC(MID$(fil$(res2),i,1))
		IF ch="."% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 

IF fil$(res2)="ALL FILES" THEN
	dir2$="..."
ELSE
	dir2$=LEFT$(fil$(res2),i-1)
END IF

dir3$=dir$+dir2$+"\"

			Sette_ptext showdir,dir$
			Sette_ptext showdir2,dir3$
			Object_redraw askp,showdir
			Object_redraw askp,showdir2
		END IF

	CASE tick1
IF Curob_state (tick1,mask_selected)<>0 THEN tic=1 ELSE tic=0

	CASE ok3
		commonclose=-1
		askp=0

IF fil$(res2)="ALL FILES" THEN
dum=2
DO

IF fil$(dum)<>"" THEN
res2=dum

	i=LEN(fil$(res2))
	DO
		ch=ASC(MID$(fil$(res2),i,1))
		IF ch="."% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 

dir2$=LEFT$(fil$(res2),i-1)
dir4$=dir$
dir3$=dir$+dir2$+"\"

REM IF tic=1 THEN dir$=dir3$

CALL inst
dir$=dir4$

END IF

INCR dum
LOOP UNTIL dum=12

ELSE

REM IF tic=1 THEN dir$=dir3$
CALL inst

END IF

TopAWindow myhandle
REM Object_Redraw myhandle,0

IF commonclose=0 THEN Object_Redraw askp,commonobj
END SELECT 
END SUB

SUB close_dialog
SHARED commonclose,myhandle,commonobj,res$,infobox,insbox,res2,fil$(1)
SHARED askp,dir$,dir2$,dir3$,dummo
STATIC x,y,res$,res,dummy,insbox,res2,fil$(1),l&,l2&,l3&,l4&,l5&
STATIC dummy$,askp,dir$,i,ch,dir2$,dir3$,dummo,infobox

commonclose=0										

SELECT CASE commonobj

		CASE=install

SelectTree askplace
Sette_ptext showdir,dir$

i=LEN(fil$(res2))

	DO
		ch=ASC(MID$(fil$(res2),i,1))
		IF ch="."% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP 

IF fil$(res2)="ALL FILES" THEN
	dir2$="..."
ELSE
	dir2$=LEFT$(fil$(res2),i-1)
END IF
dir3$=dir$+dir2$+"\"

Sette_ptext showdir2,dir3$

askp=openformwindow (" PJCO Install: Destination ",&h0B,askplace,0,cancel,VARPTRS(Close_Dialog2))
Object_redraw askp,0

	CASE=pop_but
commonclose=0
		junk=objc_offset(tree&,pop_but,x,y)		'find object position
		res=popup(0,models,res,x,y)			'do the pop
		IF res THEN 									'if there was a result
			res$=get_pop_text$(models,res)	'get the text
CALL seter
res$=MID$(res$,3,LEN(res$)-2)
REM dummy=form_alert (1,"[1][ res$='"+res$+"' ][ Ok ]")
			sette_ptext pop_but,res$				'display it in the main dialog
			setob_scut pop_but,LEFT$(res$,1)		'change the keybd shortcut
Object_redraw myhandle,pop_but
		END IF
	CASE=ok_but
 	commonclose=-1
REM closeawindow myhandle
		myhandle=0
IF commonclose=0 THEN Object_Redraw myhandle,commonobj
END SELECT
END SUB

startprogram "INSTALL.RSC",menu1,mquit

ON ERROR GOTO handle

tic=1

DIM te$(12)
DIM i$(60)
DIM by$(12)
DIM fil$(12)
DIM mac$(12)
DIM mem$(12)
DIM size$(12)

ex$=CURDIR$+"\"
dir$=CURDIR$+"\"

IF FEXISTS("INSTALL.INF") THEN
OPEN "INSTALL.INF" FOR INPUT AS 2
WHILE NOT EOF(2)
LINE INPUT #2,st$
IF MID$(st$,1,2)="##" THEN CALL comm
WEND
CLOSE 2
END IF

te$(1)="  Install"
by$(1)="Paul Jones"
fil$(1)="INSTALL.PRG"
mac$(1)="123456"
mem$(1)="100"
size$(1)="80"
i$(1)="To chose which program you want to install, click on 'INSTALL'."
i$(2)="This will give you a selection of programs on the disk. Once one"
i$(3)="has been selected, this box will contain information about it." 
i$(4)="Easy!"

te$(12)="  All"
by$(12)="Various people"
fil$(12)="ALL FILES"
mac$(12)="123456"
mem$(12)="Varable "

FOR g=2 TO 11
l&=VAL(size$(g))
te&=te&+l&
NEXT g

g$=STR$(te&)
size$(12)=MID$(g$,2,LEN(g$)-1)
i$(56)="Installs all files at the same time."

ver$="0.38"
SelectTree dialog
setob_scut pop_but,MID$(te$(1),3,1)
CALL setname
myhandle=openformwindow(" PJCO install: "+title$,&h0B,dialog,0,ok_but,VARPTRS(close_dialog))
Object_redraw myhandle,0
res$=te$(1) : CALL seter
SelectTree models
Inclob_state t1,mask_checked

xHGTloop
stopProgram

main:
xHGTloop
stopProgram
RETURN

Handle:

IF ERR=75 THEN
	SelectTree errdi
REM                  1234567890123456789012345678901234567890
	Sette_ptext er1,"The folder for this program already"
	Sette_ptext er2,"exists! You must have already installed"
	Sette_ptext er3,"the software. Line:"+STR$(ERL)
REM	dummo=form_alert (1,"[3][ The folder for this program | already exists! You must have | already installed this before ][ Ok ]")
	dummo=openformwindow (" PJCO install: warning ",&h0b,errdi,0,ok4,VARPTRS(close_dialog3))
	ab=1
	Object_redraw dummo,0
	insbox=0
	RESUME main
ELSE
	dummy=form_alert (1,"[3][ Error:"+STR$(ERR)+" | in line"+STR$(ERL)+" ][ Ok ]")
	RESUME main
END IF

RETURN