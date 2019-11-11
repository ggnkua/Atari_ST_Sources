
REM $include networld.bas

REM Telnet example. Simply asks for a host and port and connects to
REM it. Keeps checking user/remote for input/output. You have to run
REM STiK first, then run this program since it doesn't use a menu!

start:
INPUT "Connect to: ",name$
IF name$="" THEN STOP
INPUT "On port: ",port

cn=tcp_connect (name$,port,0,2000)
IF cn<E_NORMAL THEN
	PRINT "Connection failed!"
	PRINT gerrtxt$(cn)
	STOP
END IF
	
REM We're connected!

PRINT "Connected to '"+name$+"' on port"+STR$(port)+" chn#"+STR$(cn)
PRINT

ser_disable dummy()
OPEN "TELNET.LOG" FOR APPEND AS #1
PRINT #1,"--"
PRINT #1,"Connected to '"+name$+"' on port"+STR$(port)+" chn#"+STR$(cn)
ser_enable dummy()

LOCATE 5,1,1

check:

c=cnbyte_count (cn)
GOSUB keybd:
IF c>0 THEN
	FOR f=1 TO c
		d=cnget_char (cn)
		IF c<E_NORMAL THEN
			PRINT "cnget_char: "+gerrtxt$(c)
			GOTO check:
		END IF
		
		IF d<2 THEN
			x=tcp_close (cn,20)			
			GOTO start:
		END IF
		ser_disable dummy()
		IF d>0 THEN PRINT CHR$(d);
		IF d>0 THEN PRINT #1,CHR$(d);
		ser_enable dummy()
	NEXT
END IF

GOTO check:

keybd:

a$=INKEY$
IF a$="" THEN RETURN

IF a$=CHR$(27) THEN
	x=tcp_close (cn,20)
	CLOSE #1
	STOP
END IF

IF a$=CHR$(8) THEN GOSUB delete:
IF ASC(a$)>31 THEN kl$=kl$+a$ : PRINT a$;
IF a$=CHR$(13) THEN
	PRINT
	IF cn>-1 THEN x=tcpsend (cn,kl$)
	ser_disable dummy()
	PRINT #1,"USER>"+kl$
	ser_enable dummy()
	kl$=""
END IF

RETURN

delete:
kl$=MID$(kl$,1,LEN(kl$)-1)
GOSUB redraw:
RETURN

redraw:
x=CSRLIN
LOCATE x,1
PRINT STRING$(78,32)
LOCATE x,1
PRINT kl$;
RETURN