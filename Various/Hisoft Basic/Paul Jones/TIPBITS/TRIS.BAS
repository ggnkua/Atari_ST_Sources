
REM $option !g
REM $option k400

REM REM $include toolbox.bas
REM REM $include pindow.bas
REM REM $include textwind.bas
REM REM $include tris.bh

LIBRARY "gemdos"

v$="0.0018"
vd$="15/9/96"
DEFINT a-z

REM **************************************
SUB init
SHARED b$,c$,g,d$,a,si(27),a$,b,l
STATIC b$,c$,g,d$,a,si(27),a$,b,l

PRINT "Loading speech system..."
PRINT " Alphabet... ";

b$="E:\TRIS\SPEECH\ALPHABET"
c$=MID$(b$,1,1)
REM G=dsetdrv%(ASC(c$)-ASC("A"))
d$=MID$(b$,3,LEN(b$)-2)
CHDIR d$
a=0

DIM si (27)
FOR a=ASC("A") TO ASC("Z") STEP 1
a$=CHR$(a)+".RAW"
b=FEXISTS(a$)

IF b THEN
PRINT CHR$(a);
REM OPEN ON a$ FOR INPUT AS #1
REM l=LOF(1)
REM si (a-ASC("A"))=l
END IF

IF b=0 THEN
PRINT "!";

END IF
NEXT                                                                               

PRINT

PRINT "    Sounds... ";

FOR a=ASC("A") TO ASC("Z")
a$=CHR$(a)+".AVR"
PRINT CHR$(a);
NEXT

END SUB

REM *********************************

REM =================================

FUNCTION TreatText$(t$)
SHARED a,c$,t2$,t$
STATIC a,c$,t2$,t$

FOR a=1 TO LEN(t$)
c$=MID$(t$,a,1)
c$=UCASE$(c$)

IF c$="." THEN t2$=t2$+c$ : c$=CHR$(30)
IF c$=" " THEN t2$=t2$+c$ : c$=CHR$(30)

IF ASC(c$)>31 THEN t2$=t2$+c$

NEXT a

IF RIGHT$(t2$,1)<>" " THEN t2$=t2$+" "
TreatText$=t2$
t2$=""

END FUNCTION

REM ====================================

REM ------------------------------------
FUNCTION NextWord$(w1$,w2$)
REM Gets the next word! Obvious... w1$ contains the word which we 
REM want TO look at next. w2$ contains the sentance to search!
STATIC w$,w1$,w2$,w3$,w1,w2,w3,w4
SHARED w$,w1$,w2$,w3$,w1,w2,w3,w4

NextWord$=""

w1=INSTR(w2$,w1$)
REM contains the first character of w1$
REM w1 will become first number of next word

DO
IF w1<LEN(w2$) THEN w$=MID$(w2$,w1,1) ELSE w$=" "
w1=w1+1
LOOP UNTIL w$=" "

REM w1 now should contain the first number.
REM w2 will contain the last character.

w2=w1+1

DO
IF w2<LEN(w2$) THEN w$=MID$(w2$,w2,1) ELSE w$=" "
w2=w2+1
LOOP UNTIL w$=" "

w2=w2-1
w3=w2-w1

NextWord$=MID$(w2$,w1,w3)

w$="" : w1$="" : w2$="" : w3$=""
w1=0 : w2=0 : w3=0 : w4=0

END FUNCTION

FUNCTION PrevWord$(p1$,p2$)
REM Erm, just like the above word, execpt it looks for the previous
REM word! Doh!
STATIC p1,p2,p3,p1$,p2$,p3$
SHARED p1,p2,p3,p1$,p2$,p3$

PrevWord$=""

p1=INSTR(p2$,p1$)

DO
IF p1>0 THEN p1$=MID$(p2$,p1,1) ELSE p1$=" "
p1=p1-1
LOOP UNTIL p1$=" "

REM p1 now should contain the last number.
REM p2 will contain the first character.

p1=p1+1
p2=p1

DO
p2=p2-1
IF p2>1 THEN p1$=MID$(p2$,p2,1) ELSE p1$=" "
LOOP UNTIL p1$=" "

p3=p1-p2

IF p2<0 THEN p2=1

REM PRINT #1,"TRIS>PREVWORD>P1='";p1;"' P2='";p2;"' P3='";p3;"'"

PrevWord$=MID$(p2$,p2,p3)

p1=0 : p2=0 : p3=0
p1$="" : p2$="" : p3$=""

END FUNCTION

SUB ViewFile(f$)
REM Can file any file, if it's been programmed in, that is.
STATIC f,f$,f2$,f3$,f4$,r$,e$,d2$,key$,num
SHARED f,f$,f2$,f3$,f4$,r$,e$,d2$,key$,num
SHARED text$,texth,wolines(1),TextWindows

REM First, get the extension. 
REM File examples... TEXTTEXT.TXT or READ.ME or NONAME

f=1

r$="" : e$=""

IF LEN(f$)<13 AND LEN(f$)>0 THEN

DO
IF f<LEN(f$) THEN f2$=MID$(f$,f,1) ELSE f2$="." : e$="!"
f=f+1
LOOP UNTIL f2$="."

IF e$="!" THEN f3$="ASC"

REM f contains the number of the extension, now to grap it into f3$

f3$=MID$(f$,f,LEN(f$)-(f-1))

IF f3$<>"GIF" OR f3$<>"TIF" OR f3$<>"MOD" THEN

PRINT #1,"TRIS>ViewFile>"+f$

IF FEXISTS(f$) THEN

OPEN f$ FOR INPUT AS 2
WHILE NOT EOF(2)
num=num+1

IF num>20 THEN

WINDOW NAME 1," TRIS system "," Press space for next page, enter for next line, Q to quit"
BEEP

DO
key$=INKEY$
LOOP UNTIL key$=" " OR key$=CHR$(13) OR UCASE$(key$)="Q"

IF key$<>CHR$(13) THEN WINDOW NAME 1," TRIS system ",""

IF key$=" " THEN num=0
IF key$=CHR$(13) THEN num=20
IF UCASE$(key$)="Q" THEN CLOSE 2 : r$="Aborted file view" : EXIT SUB

END IF

LINE INPUT #2,f4$
PRINT f4$


WEND
CLOSE 2

r$="File loaded."

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"


END IF

IF r$="" THEN r$="File not found."
END IF

END IF

END SUB

REM ++++++++++++++++++++++++++++++++++++
SUB CheckText
STATIC t$,t2$,r$,v$,vd$,d1,d2,d3,d4,n$,f$,d1$,d2$,e$,d$,fo$,cd$
SHARED t$,t2$,r$,v$,vd$,d1,d2,d3,d4,n$,f$,d1$,d2$,e$,d$,fo$,cd$

r$=""

d2$=t$
d1$=t$

IF t$="TRIS" THEN
r$="The TRIS - The Real Intelligent System - Version "+v$+". Made by Paul Jones "
r$=r$+"in HiSoft BASIC, on "+vd$+". Copyright to PJCO, Paul Jones Corporation. "
r$=r$+"All rights reserved. TRIS is an artifical intelligent program, PJCO can not"
r$=r$+"be held responsable for what ever TRIS says."
END IF

IF t$="MIDIIN" THEN
PRINT : PRINT "MIDI mode - on" : PRINT

DO

d1=INP(-3)
IF d1 THEN
d2=INP(3)
IF d2<>254 THEN PRINT d2
END IF

LOOP UNTIL INKEY$<>""

r$="Finished."

END IF

IF t$="MIDIOUT" THEN

PRINT "MIDI out mode - on, type number above or below range of 1-255 to exit"

DO

INPUT "MIDI OUT>",d3

IF d3>-1 AND d3<256 THEN OUT 3,d3
LOOP UNTIL d3<0 OR d3>255

r$="Ok."

END IF

IF MID$(t$,1,6)="NOTEON" THEN

d4=VAL(MID$(t$,7,LEN(t$)-6))

OUT 3,144 : OUT 3,d4 : OUT 3,80

r$="MIDI sent."

END IF

IF MID$(t$,1,7)="NOTEOFF" THEN

d4=VAL(MID$(t$,8,LEN(t$)-7))

OUT 3,144 : OUT 3,d4 : OUT 3,0

r$="MIDI sent."

END IF

IF INSTR(t$,"HELLO") THEN r$="Hello user."
IF INSTR(t$,"HI") THEN r$="Hi there!"

IF INSTR(t$,"DIR") THEN

IF INSTR(t$,"ROOT") THEN

IF INSTR(t$,"TO") THEN

d$=CHR$(dgetdrv%+ASC("A"))
cd$=d$+":\"

CHDIR cd$

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Root directory." : EXIT SUB

END IF
END IF

IF INSTR(t$,"CHANGE") THEN

t$=d2$
cd$=NextWord$("DIR",t$)
t$=d2$
PRINT #1,"TRIS>CHANGE>CD$='"+cd$+"'"
IF cd$="TO" THEN
	t$=d2$
	cd$=NextWord$("TO ",t$)
	t$=d2$
END IF

PRINT #1,"TRIS>CHANGE>DIRECTORY>"+cd$

CHDIR cd$

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Directory changed."

END IF

t$=d2$
e$="*.*"
fo$=""

IF INSTR(t$,"EXT") THEN

t$=d2$
e$=NextWord$("EXT",t$)
t$=d2$
e$=MID$(e$,2,LEN(e$))
IF LEN(e$)=3 THEN e$="*."+e$
IF LEN(e$)=0 THEN e$="*.*"

PRINT #1,"TRIS>DIR>EXTENSION='"+e$+"'"

END IF

IF INSTR(t$,"FOLDER") THEN

t$=d2$
fo$=NextWord$("FOLDER",t$)
t$=d2$
fo$="\"+MID$(fo$,1,LEN(fo$))

PRINT #1,"TRIS>DIR>FOLDER='"+fo$+"'"

END IF

IF INSTR(t$,"DRIVE")=0 AND INSTR(t$,"FOLDER")=0 AND INSTR(t$,"CHANGE")=0 THEN 
d$=CHR$(dgetdrv%+ASC("A"))
fo$=CURDIR$
FILES CURDIR$+"\"+e$
r$="Directory of '"+CURDIR$+"\"+e$+"' complete."
END IF

IF INSTR(t$,"DRIVE") THEN

t$=d2$
d$=NextWord$("DRIVE",t$)
t$=d2$

IF LEN(d$)=2 THEN d$=MID$(d$,1,1)
IF LEN(d$)>2 THEN d$=CHR$(dgetdrv%+ASC("A"))
IF LEN(d$)=0 THEN d$=CHR$(dgetdrv%+ASC("A"))

PRINT #1,"TRIS>DIR>DRIVE '"+d$+"'"

IF LEN(d$)=0 THEN FILES d$+":"+fo$+"\"+e$

IF LEN(d$)=1 THEN
FILES d$+":"+fo$+"\"+e$

PRINT #1,"TRIS>DIR>FILES '"+d$+":"+fo$+"\"+e$+"'"
END IF 

END IF

IF r$="" THEN r$="Directory of '"+d$+":"+fo$+"\"+e$+"' complete."

END IF

t$=d2$

IF INSTR(t$,"LOOK") THEN

t$=d2$

n$=NextWord$("LOOK",t$)

t$=d2$

PRINT #1,"TRIS>>Typed in '"+t$+"'. NextWord='"+n$+"'"

IF n$="LIKE" THEN r$="Does it matter?"

t$=d2$

IF n$="AT" THEN

IF r$="" THEN
t$=d2$
f$=NextWord$("AT",t$)
t$=d2$

PRINT #1,"TRIS>VIEWFILE>NextWord='"+f$+"'"

ViewFile (f$)

IF f$="DRIVE" THEN r$="It's very nice. What about it?"

END IF
END IF

d1$=""

END IF

t$=d2$

IF INSTR(t$,"CD") THEN

cd$=NextWord$("CD",t$)

t$=d2$

CHDIR cd$

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Changed folder."

END IF

t$=d2$

IF INSTR(t$,"CHANGE") THEN

t$=d2$

IF INSTR(t$,"DRIVE") THEN
t$=d2$
n$=NextWord$("DRIVE",t$)
t$=d2$

IF n$="TO" THEN
	t$=d2$
	n$=NextWord$("TO",t$)
	t$=d2$
END IF

d1=dsetdrv%(ASC(n$)-ASC("A"))

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Drive changed."

END IF
END IF

t$=d2$

IF INSTR(t$,"FOLDER") THEN

IF INSTR(t$,"IN") THEN 

t$=d2$
n$=NextWord$("FOLDER",t$)
t$=d2$

CHDIR n$

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Gone into folder."

END IF

IF INSTR(t$,"BACK") THEN

CHDIR ".."

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Gone back a folder."

END IF

IF INSTR(t$,"PREVIOUS") THEN

CHDIR ".."

WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

r$="Gone back to previous folder."

END IF

END IF

IF INSTR(t$,"WHAT") THEN

IF INSTR(t$,"TIME") THEN

r$="The time is: "+TIME$

END IF

IF INSTR(t$,"DATE") THEN

r$="The date is: "+DATE$+" in the form Month-Day-Year"

END IF
END IF

IF t$="EXIT " THEN r$="Terminating program..."

IF r$="" THEN r$="'"+MID$(d2$,1,LEN(d2$)-1)+"' has not been entered into my 'brain'!"

END SUB

SUB ProcessKeys (ascii$,scan_code, kstate)
STATIC ascii$,scan_code,kstate,k1$,k2$,k3$,finished_flag,t$,r$
SHARED ascii$,scan_code,kstate,k1$,k2$,k3$,finsihed_flag,t$,r$

k1$=ascii$
IF ASC(k1$)>31 THEN k2$=k2$+k1$
IF ASC(k1$)=13 THEN
PRINT #1,"USER>"+k2$+CHR$(13)+CHR$(10)
t$=TreatText$(k2$)
PRINT #1,"TRIS>T>"+t$
CALL CheckText
PRINT "TRIS>"+r$
PRINT #1,"TRIS>"+r$
PRINT 
END IF

IF ASC(k1$)=8 THEN k2$=MID$(k2$,1,LEN(k2$)-1)
IF k1$<>"" THEN PRINT k1$;

IF k2$="EXIT" THEN
finished_flag=-1
PRINT #1,"TRIS>Finish time... "+TIME$
PRINT #1
PRINT #1,STRING$(80,ASC("-"))
CLOSE #1
END IF

k3$=k1$
k2$=""

END SUB




REM ++++++++++++++++++++++++++++++++++++

wx=PEEKW(SYSTAB+58)
wy=PEEKW(SYSTAB+60)
ww=PEEKW(SYSTAB+62)
wh=PEEKW(SYSTAB+64)

WINDOW OPEN 1," TRIS system ",wx,wy,ww,wh,win_all
WINDOW NAME 1," TRIS system "," "+CURDIR$+"\"

REM 1=Title bar
REM 2=Close box
REM 4=Full box
REM 8=Move box
REM 16=Info line
REM 32=Size box
REM 64=Up arrow
REM 128=Down arrow
REM 256=Vertical slider
REM 512=Left Arrow
REM 1024=Right arrow
REM 2048=Horizontal slider

WINDOW OUTPUT 1

WINDOW CONTRL 1,3,1000
WINDOW CONTRL 1,2,1000

WINDOW ON

REM **** Initisation ****

REM StartProgram "TRIS.RSC",MENU,0
REM keys_enabled=1

PRINT
PRINT
PRINT "             Loading the...."
PRINT 
PRINT                                                                               
PRINT "            ############# ###########    ####   ##########      "               
PRINT "                ####      ####    ####   ####  ####             "               
PRINT "                ####      ###########    ####    #########      "               
PRINT "                ####      #### #####     ####          #####    "               
PRINT "                ####      ####    ####   ####  ###########      "               
PRINT 
PRINT "                        The Real Intelligent System "                                                                              
PRINT "                                  V"+v$
PRINT 

j=cursconf%(5,0)
dummy=cursconf%(2,j)

OPEN "TRISTYPE.DAT" FOR APPEND AS #1
PRINT #1
PRINT #1,STRING$(80,ASC("-"))
PRINT #1
PRINT #1,"TRIS> Start date... "+DATE$
PRINT #1,"TRIS> Start time... "+TIME$
PRINT #1,"TRIS> Version...... "+v$+" ("+vd$+")"
PRINT #1

REM HGTLoop

DO

IF INKEY$=CHR$(27) THEN CLOSE #1 : PRINT "Closed"
LINE INPUT "USER>",dummy$
PRINT #1,"USER>"+dummy$

t$=TreatText$(dummy$)

PRINT #1,"TRIS>T>"+t$
CALL CheckText

PRINT "TRIS>"+r$
PRINT #1,"TRIS>"+r$

PRINT 

LOOP UNTIL t$="EXIT "
PRINT #1,"TRIS>Finish time... "+TIME$
PRINT #1
PRINT #1,STRING$(80,ASC("-"))
CLOSE #1

REM StopProgram
STOP -1