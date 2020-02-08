 
LIBRARY "networld"
DEFINT a-z

REM $include transprt.bh

REM This is an include file for NetWorld. It creates functions that will
REM let you connect to the internet quickly and painlessly. Well, just!
REM :-)

DIM SHARED stikinitialised

DEF FNgerrtxt$ (er)
LOCAL s$,e&,d
e&=FNget_err_text& (er)
DO
	d=PEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
FNgerrtxt$=s$
s$="" : e&=0 : d=0
END DEF

DEF FNgvstr$ (er$)
LOCAL s$,er$,d,e&
er$=er$+CHR$(0)
e&=FNgetvstr& (VARPTR(er$))
DO
	d=PEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
FNgvstr$=s$
s$="" : e&=0 : d=0 : er$=""
END DEF

DEF FNtcp_author$
LOCAL s$,er$,d,e&,b(1)
e&=FNtcp_author& (b())
DO
	d=PEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
FNtcp_author$=s$
s$="" : e&=0 : d=0 : er$=""
END DEF

DEF FNtcp_version$
LOCAL s$,er$,d,e&,b(1)
e&=FNtcp_version& (b())
DO
	d=PEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
FNtcp_version$=s$
s$="" : e&=0 : d=0 : er$=""
END DEF

DEF FNtcp_module$
LOCAL s$,er$,d,e&,b(1)
e&=FNtcp_module& (b())
DO
	d=PEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
FNtcp_module$=s$
s$="" : e&=0 : d=0 : er$=""
END DEF

DEF FNnetworldver$
LOCAL s$,er$,d,e&,b(1)
e&=FNnetwldver& (b())
DO
	d=PEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
FNnetworldver$=s$
s$="" : e&=0 : d=0 : er$=""
END DEF

DEF FNTCP_connect (domain$, port, tos, alloc)
LOCAL a,num,anum&,x,TCP_cnnect,dum(1)

domain$=domain$+CHR$(0)
num=FNresolve (VARPTR(domain$),0,VARPTR(anum&),1)
IF num<0 THEN
'	a=FNform_alert (1,"[1][ Resolve returns: | "+gerrtxt$(num)+" | ][ OK ]")
	TCP_cnnect=-1
END IF

x=FNTCP_open (anum&, port, tos, alloc)
IF x<0 THEN
'	a=FNform_alert (1,"[1][ TCP_open returns: | "+gerrtxt$(x)+" | ][ OK ]")
	TCP_cnnect=-1
END IF

IF TCP_cnnect<>-1 THEN FNTCP_connect=x ELSE FNTCP_connect=-1

END DEF

SUB initnetworld
LOCAL a,b(1)
a=FNinitstik (b())
'IF a<1 THEN a=FNform_alert (1,"[3][ STiK not installed | correctly! ][ OK ]")
stikinitialised=a
END SUB

DEF FNtcpsend (cn,mess$)
LOCAL x

mess$=mess$+CHR$(13)+CHR$(10)
x=FNtcp_send (cn,VARPTR(mess$),LEN(mess$))
FNtcpsend=x

END DEF

initnetworld