
LIBRARY "networld"
DEFINT a-z

REM $include transprt.bh

REM This is an include file for NetWorld. It creates functions that will
REM let you connect to the internet quickly and painlessly. Well, just!
REM :-)

DIM SHARED stikinitialised

FUNCTION gerrtxt$ (er)
LOCAL s$,e&,d
e&=get_err_text& (er)
DO
	d=SPEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
gerrtxt$=s$
s$="" : e&=0 : d=0
END FUNCTION

FUNCTION gvstr$ (er$)
LOCAL s$,er$,d,e&
er$=er$+CHR$(0)
e&=getvstr& (VARPTR(er$))
DO
	d=SPEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
gvstr$=s$
s$="" : e&=0 : d=0 : er$=""
END FUNCTION

FUNCTION tcp_author$
LOCAL s$,er$,d,e&,b(1)
e&=tcp_author& (b())
DO
	d=SPEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
tcp_author$=s$
s$="" : e&=0 : d=0 : er$=""
END FUNCTION

FUNCTION tcp_version$
LOCAL s$,er$,d,e&,b(1)
e&=tcp_version& (b())
DO
	d=SPEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
tcp_version$=s$
s$="" : e&=0 : d=0 : er$=""
END FUNCTION

FUNCTION tcp_module$
LOCAL s$,er$,d,e&,b(1)
e&=tcp_module& (b())
DO
	d=SPEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
tcp_module$=s$
s$="" : e&=0 : d=0 : er$=""
END FUNCTION

FUNCTION networldver$
LOCAL s$,er$,d,e&,b(1)
e&=netwldver& (b())
DO
	d=SPEEKB (e&)
	IF d=0 THEN EXIT DO
	s$=s$+CHR$(d)
	INCR e&
LOOP
networldver$=s$
s$="" : e&=0 : d=0 : er$=""
END FUNCTION

FUNCTION TCP_connect (domain$, port, tos, alloc)
LOCAL a,num,anum&,x,TCP_cnnect,dum(1)

domain$=domain$+CHR$(0)
num=resolve (VARPTR(domain$),0,VARPTR(anum&),1)
IF num<0 THEN
	TCP_cnnect=-1
END IF

x=TCP_open (anum&, port, tos, alloc)
IF x<0 THEN
	TCP_cnnect=-1
END IF

IF TCP_cnnect<>-1 THEN TCP_connect=x ELSE TCP_connect=-1

END FUNCTION

SUB initnetworld
LOCAL a,b(1)
a=initstik (b())
'IF a<1 THEN a=form_alert (1,"[3][ STiK not installed | correctly! ][ OK ]")
stikinitialised=a
END SUB

FUNCTION get_response$ (cn, time)
LOCAL time2,time3,count,c,s$,dum(1),d

time2=CINT(TIMER)
time3=time2+time
s$=""
DO
count=cnbyte_count (cn)
IF count<>0 THEN EXIT DO
LOOP
IF count<0 THEN
	get_response$=gerrtxt$(count)
	EXIT FUNCTION
END IF
	
IF CINT(TIMER)=time3 THEN get_response$=gerrtxt$(E_USERTIMEOUT) : EXIT FUNCTION

IF INKEY$<>"" THEN get_response$=gerrtxt$(E_USERTIMEOUT) : EXIT FUNCTION

FOR d=1 TO count
	c=cnget_char (cn)
	IF c<E_NODATA THEN
		get_response$=gerrtxt$(c)
		EXIT FUNCTION
	END IF
	
	IF c>0 AND c<256 THEN s$=s$+CHR$(c)
NEXT

get_response$=s$

END FUNCTION

FUNCTION tcpsend (cn,mess$)
LOCAL x

mess$=mess$+CHR$(13)+CHR$(10)
x=tcp_send (cn,VARPTR(mess$),LEN(mess$))
tcpsend=x

END FUNCTION

initnetworld