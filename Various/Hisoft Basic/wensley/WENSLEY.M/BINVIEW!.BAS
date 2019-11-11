REM $option g
LIBRARY "gemaes","xbios","gemdos","mint"
DEFINT a-z
DIM SHARED s

DIM SHARED outofdata%
DIM SHARED mint%
mint%=GETCOOKIE("MiNT",j&)
DECLARE FUNCTION gchar%(BYVAL handle%)



INPUT "Display code?",s

'cl$=COMMAND$
IF cl$<>"" THEN binview cl$ : SYSTEM

fspath$=CURDIR$+"\*.BIN"
fsname$=""

DO
IF PEEKW(PEEKL(GB+4))<&H130 THEN
	fsel_input fspath$,fsname$,ok
ELSE
	fsel_exinput fspath$,fsname$,ok,"Choose a library file"
END IF
IF ok THEN
	i=LEN(fspath$)
	DO
		ch=ASC(MID$(fspath$,i,1))
		IF ch="\"% OR ch=":"% THEN EXIT LOOP
		IF i=1 THEN EXIT LOOP
		DECR i
	LOOP
	binview LEFT$(fspath$,i)+fsname$
	PRINT "presskey to continue" : WHILE INKEY$="" : WEND
END IF
LOOP UNTIL ok=0
SYSTEM



SUB binview(BYVAL file$)
LOCAL ch,choice,l,l$,long&,id%,tr,op,st$,handle%,j,ch$,j&,i,p,nc,fid,ncommands&,cleverbuffer$

' used to store names of commands for HBASIC command listing.
cleverbuffer$=""


ncommands&=0

' does not work - "e"?
'OPEN "i",#1,file$
handle%=fopen%(file$,0)
outofdata%=0

DO UNTIL outofdata%=1
ch=gchar(handle)
IF outofdata=1 THEN EXIT LOOP

' &HFb
SELECT CASE ch
CASE &HFB

	REM these are for .BIN files only?

	choice=gchar(handle%)
	COLOR 2
	SELECT CASE choice
	CASE 01
	REM the first operand of a library file=01

	l=gchar(handle)
	st$=SPACE$(l)
	j&=fread&(handle,LEN(st$),SADD(st$))
	PRINT "SOURCE (file this library was made from):*"+st$+"*"

	CASE 02
	l=gchar(handle%)
	st$=SPACE$(l)
	j&=fread&(handle,LEN(st$),SADD(st$))	
	PRINT "COMMENT (comments about this file e.g author, credits copyrights):*"+st$+"*"
	
	CASE 03
	long&=&HFFFFFFFF
	j&=fread&(handle,4,VARPTR(long&))
	IF j&=4 THEN PRINT "ORG (data that follows this is to start at absolute"+HEX$(long&)+")"
	
	CASE 04
	id=&HFFFF
	j&=fread&(handle,2,VARPTR(id))
	IF j&=2 THEN
		SELECT CASE id
			CASE <0
			IF s THEN PRINT "SECTION (the following code is associated with id"+HEX$(id)+"(to give the code a name)"
			CASE 0
			IF s THEN PRINT "SECTION (the following code is an absolutely referenced section)"
			CASE >0
			IF s THEN PRINT "SECTION (the following code has symbol "+HEX$(id)
		END SELECT
	END IF	
	CASE 05
	long&=2
	j&=fread&(handle%,4,VARPTR(long&))
	IF j&=4 THEN PRINT "OFFSET "+HEX$(long&)+")"

	CASE 06
	id=1
	long&=1
	l=gchar(handle)
	st$=SPACE$(l)
	j&=fread&(handle,LEN(st$),VARPTR(st$))
	j&=fread&(handle,4,VARPTR(long&))
	j&=fread&(handle,2,VARPTR(id))
	PRINT "XDEF *"+st$+"* with value "+HEX$(long&)+" and may refer to code marked with id "+HEX$(id)

	' for HBASIC specific stuff?
	incr ncommands&
	cleverbuffer$=cleverbuffer$+chr$(l)+st$

	CASE 07
	j&=fread&(handle,4,VARPTR(long&))
	tr=gchar(handle)
	PRINT "XREF: Used to include fixed up values in compiled programs "
	IF tr AND &B1 THEN PRINT "	This number is byte sized";
	IF tr AND &B10 THEN PRINT "	This number is word sized";
	IF tr AND &B100 THEN PRINT "	This number is long sized";
	REM can be only one of the above
	IF tr AND &B1000 THEN PRINT "and signed";
	IF tr AND &B10000 THEN PRINT "and unsigned";
	IF tr AND &B100000 THEN PRINT "and relative to the Program Counter";
	IF tr AND &B1000000 THEN PRINT "and is to be relocated at runtime";
	PRINT "."
	 
	DO
	op=gchar(handle)
	IF op="û"% THEN EXIT LOOP
	SELECT CASE op
		CASE "+"%
			j&=fread&(handle,2,VARPTR(id))
			print id,"added to",long&
			long&=long&+id
		CASE "-"%
			j&=fread&(handle,2,VARPTR(id))
			print id,"taken off",long&
			long&=long&-id
		END SELECT
	LOOP
	PRINT "     XREF VALUE is",HEX$(long&)
	
	CASE &H10
	j&=fread&(handle,2,VARPTR(id))
	l=gchar(handle)
	st$=SPACE$(l)
	j&=fread&(handle,LEN(st$),VARPTR(st$))
	PRINT "DEFINE id:"+HEX$(id)+" is defined by the name *"+st$+"*"
	
	CASE &H12
	j&=fread&(handle,2,VARPTR(id))
	PRINT "COMMON using id"+HEX$(id)
	
	CASE &H13
	PRINT "END ***** this is the end ot this module *******"

	CASE &HFB
	COLOR 1
	PRINT "FB";
	CASE ELSE
	PRINT "Unknown FB code with value "+HEX$(choice)
	END SELECT
	COLOR 1

' 48 and 95 only valid for HBASIC .BIN files created using user supplied templates.
' so I use a variable ncommands& that ensures it does not count more commands than are in the file.

CASE 48
if ncommands&>0 then
	decr ncommands&
	l=asc(left$(cleverbuffer$,1))
	nc=gchar(handle)
	print mid$(cleverbuffer$,2,l)+" "; : printparams handle,nc : print
	cleverbuffer$=mid$(cleverbuffer$,2+l)
end if
case 95
if ncommands&>0 then
	decr ncommands&
	l=asc(left$(cleverbuffer$,1))
	fid=gchar(handle)
	nc=gchar(handle)
	print "PRINT "+mid$(cleverbuffer$,2,l)+chr$(fid);
	if nc>1 then print "("; : printparams handle,nc : print ")";
	print
	cleverbuffer$=mid$(cleverbuffer$,2+l)
end if
CASE ELSE
	IF s THEN PRINT CHR$(ch);
END SELECT

IF mint% THEN
	IF finstat&(handle%)=0 THEN outofdata%=1
END IF
LOOP UNTIL outofdata%=1

j=fclose(handle%)
END SUB

sub printparams(byval handle,byval nc)
local i,p
IF nc>1 then
	for i=1 to (nc-1)
		p=gchar(handle)
		if p and 16 then print "VARPTR(";
		if (p and &B111)=1 then print "integer%";
		if (p and &B111)=2 then print "long&";
		if (p and &B111)=3 then print "single!";
		if (p and &B111)=4 then print "double#";
		if (p and &B111)=5 then print "string$";
		if p and 8 then print "(array)";
		if p and 16 then print ")";
		if i<(nc-1) then print ",";
	next i
end if
end sub


FUNCTION gchar%(BYVAL handle%)
LOCAL j,dp%,j&,je
SELECT CASE mint%
CASE 0
dp%=1
j=fread&(handle%,1,VARPTR(dp%)+1)

gchar%=dp%
IF j<0 THEN je=form_error((0-j)-31)
IF j<1 THEN outofdata%=1
CASE ELSE
j&=fgetchar&(handle%,0)
IF j&<0 THEN je=form_error((0-j&)-31) : outofdata%=1
IF j&=&HFF1A THEN outofdata%=1
gchar%=CINT(j& AND &HFF)
END SELECT
END FUNCTION
