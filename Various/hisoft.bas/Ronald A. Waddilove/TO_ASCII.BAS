REM Convert file to Ascii
REM Written in HiSoft/Power Basic
REM By R.A.Waddilove

LIBRARY "GEMAES"

WINDOW FULLW
PRINT " Enter file to convert....."
infile$=FNfilename$
PRINT "Enter new filename....."
outfile$=FNfilename$
PRINT "Converting file....."
OPEN "R",#1,infile$,1
FIELD #1,1 AS inbuff$
OPEN "R",#2,outfile$,1
FIELD #2,1 AS outbuff$
lastbyte%=0
DO
	GET #1 : byte%=ASC(inbuff$)
	IF (byte%<32 OR byte%>126) AND byte%<>10 AND byte%<>13 THEN byte%=32
	IF byte%<>32 OR lastbyte%<>32 THEN LSET outbuff$=CHR$(byte%):PUT #2
lastbyte%=byte%
LOOP UNTIL EOF(1)
CLOSE
SYSTEM

DEF FNfilename$
MOUSE 0
path$="A:\*.*"
name$=""
ok%=0
fsel_input path$,name$,ok%
WHILE right$(path$,1)<>"\"
	path$=LEFT$(path$,LEN(path$)-1)
WEND
MOUSE -1
CLS
FNfilename$=path$+name$
END DEF
