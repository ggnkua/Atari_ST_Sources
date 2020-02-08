
' [OLGA.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DIM SHARED olga_enabled

' Used by ole_protocol_init routine
CONST ol_server=&h0001,ol_client=&h0002,ol_peer=&h0003,ol_pipes=&h1000
CONST ol_oep=&h0001

'Used by olga_protocol_init
CONST ol_idle=&H0800,ol_pipes=&h1000,ol_start=&h2000,ol_manager=&h4000

'Used by olga_protocol_start routine
CONST ols_type=&h0001,ols_extension=&h0002,ols_name=&h0003

FUNCTION extract_name$(BYVAL dummy$)
STATIC dummy,char

dummy=LEN(dummy$)
DO
	char=ASC(MID$(dummy$,dummy,1))
	IF char="\"% OR char=":"% THEN EXIT LOOP
	IF dummy=1 THEN EXIT LOOP
	DECR dummy
LOOP
dummy$=RIGHT$(dummy$,LEN(dummy$)-dummy)
dummy=LEN(dummy$)
DO
	char=ASC(MID$(dummy$,dummy,1))
	IF char="."% THEN DECR dummy : EXIT LOOP
	IF dummy=1 THEN EXIT LOOP
	DECR dummy
LOOP
extract_name$=LEFT$(dummy$,dummy)+SPACE$(8)
END FUNCTION


FUNCTION ole_manager_id
STATIC id,dummy$

ole_manager_id=-1
IF appl_find("OLEMANGR")>-1 THEN
	id=appl_find("OLEMANGR")
	ole_manager_id=id
ELSE
	IF LEN(ENVIRON$("OLEMANAGER"))<>0 THEN
		dummy$=extract_name$(ENVIRON$("OLEMANAGER"))
		IF appl_find(dummy$)>-1 THEN
			id=appl_find(dummy$)
			ole_manager_id=id
		END IF
	ELSE
		IF appl_find("OLGA    ")>-1 THEN
			IF appl_find("OEP_SERV")>-1 THEN
				id=appl_find("OEP_SERV")
				ole_manager_id=id
				EXIT FUNCTION
			END IF
		END IF
		IF LEN(ENVIRON$("OLGAMANAGER"))<>0 THEN
			dummy$=extract_name$(ENVIRON$("OLGAMANAGER"))
			IF appl_find(dummy$)>-1 THEN
				id=appl_find(dummy$)
				ole_manager_id=id
				EXIT FUNCTION
			END IF
		END IF
		IF LEN(ENVIRON$("OEPSERVER"))<>0 THEN
			dummy$=extract_name$(ENVIRON$("OEPSERVER"))
			IF appl_find(dummy$)>-1 THEN
				id=appl_find(dummy$)
				ole_manager_id=id
			END IF
		END IF
	END IF
END IF
END FUNCTION


FUNCTION olga_manager_id
STATIC id,dummy$

IF appl_find("OLGA    ")>-1 THEN
	id=appl_find("OLGA    ")
	olga_manager_id=id
ELSE
	IF LEN(ENVIRON$("OLGAMANAGER"))<>0 THEN
		dummy$=extract_name$(ENVIRON$("OLGAMANAGER"))
		IF appl_find(dummy$)>-1 THEN
			id=appl_find(dummy$)
			olga_manager_id=id
			EXIT FUNCTION
		END IF
	END IF
	IF appl_find("OLEMANGR")>-1 THEN
		id=appl_find("OLEMANGR")
		olga_manager_id=id
	ELSE
		IF LEN(ENVIRON$("OLEMANAGER"))<>0 THEN
			dummy$=extract_name$(ENVIRON$("OLEMANAGER"))
			IF appl_find(dummy$)>-1 THEN
				id=appl_find(dummy$)
				olga_manager_id=id
			END IF
		END IF
	END IF
END IF
END FUNCTION


FUNCTION olga_protocol_init
STATIC dummy$,dummy&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

id=olga_manager_id
IF id=-1 THEN
	olga_protocol_init=0
	olga_enabled=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,0
	POKEW dummy&+8,0
	POKEW dummy&+6,ol_manager
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_init
	appl_write id,16,dummy&
	olga_protocol_init=-1
	olga_enabled=-1
END IF
END FUNCTION


FUNCTION ole_protocol_init (BYVAL server_or_client, BYVAL XACC_type$,BYVAL ole_mode)
STATIC dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(XACC_type$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

id=ole_manager_id
IF id=-1 THEN
	ole_protocol_init=0
	olga_enabled=0
ELSE
	POKEL dummy&+14,addr&
	POKEW dummy&+12,0
	POKEW dummy&+10,ole_mode
	POKEW dummy&+8,0
	POKEW dummy&+6,server_or_client
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,ole_init
	appl_write id,16,dummy&
	ole_protocol_init=-1
	olga_enabled=-1
END IF
END FUNCTION


FUNCTION ole_protocol_exit
STATIC dummy$,dummy&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN ole_protocol_exit=0 : EXIT FUNCTION
id=ole_manager_id
IF id=-1 THEN
	ole_protocol_exit=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,0
	POKEW dummy&+8,0
	POKEW dummy&+6,0
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,ole_exit
	appl_write id,16,dummy&
	ole_protocol_exit=-1
	olga_enabled=0
END IF
END FUNCTION


FUNCTION olga_protocol_update (BYVAL filename$,BYVAL index)
STATIC dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_update=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_update=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,index
	POKEW dummy&+8,0
	POKEL dummy&+6,addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_update
	appl_write id,16,dummy&
	olga_protocol_update=-1
END IF
END FUNCTION


FUNCTION olga_protocol_getinfo (BYVAL index)
STATIC dummy$,dummy&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_getinfo=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_getinfo=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,index
	POKEW dummy&+8,0
	POKEW dummy&+6,0
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_getinfo
	appl_write id,16,dummy&
	olga_protocol_getinfo=-1
END IF
END FUNCTION


FUNCTION olga_protocol_info (BYVAL filename$,BYVAL index)
STATIC dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_info=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_info=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,index
	POKEW dummy&+8,0
	POKEL dummy&+6,addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_info
	appl_write id,16,dummy&
	olga_protocol_info=-1
END IF
END FUNCTION


FUNCTION olga_protocol_rename (BYVAL old_filename$,BYVAL new_filename$)
STATIC dummy$,dummy&,old_addr$,old_addr&,new_addr$,new_addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
old_addr$=LEFT$(old_filename$,255)+CHR$(0) : old_addr&=SADD(old_addr$)
new_addr$=LEFT$(new_filename$,255)+CHR$(0) : new_addr&=SADD(new_addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_rename=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_rename=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEL dummy&+10,new_addr&
	POKEW dummy&+8,0
	POKEL dummy&+6,old_addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_rename
	appl_write id,16,dummy&
	olga_protocol_rename=-1
END IF
END FUNCTION


FUNCTION olga_protocol_breaklink (BYVAL filename$)
STATIC dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_breaklink=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_breaklink=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,0
	POKEW dummy&+8,0
	POKEL dummy&+6,addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_breaklink
	appl_write id,16,dummy&
	olga_protocol_breaklink=-1
END IF
END FUNCTION


FUNCTION olga_protocol_opendoc (BYVAL group_id)
STATIC dummy$,dummy&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_opendoc=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_opendoc=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,group_id
	POKEW dummy&+8,0
	POKEW dummy&+6,0
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_opendoc
	appl_write id,16,dummy&
	olga_protocol_opendoc=-1
END IF
END FUNCTION


FUNCTION olga_protocol_closedoc (BYVAL group_id)
STATIC dummy$,dummy&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_closedoc=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_closedoc=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,group_id
	POKEW dummy&+8,0
	POKEW dummy&+6,0
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_closedoc
	appl_write id,16,dummy&
	olga_protocol_closedoc=-1
END IF
END FUNCTION


FUNCTION olga_protocol_link (BYVAL filename$,BYVAL group_id)
SHARED dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_link=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_link=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,group_id
	POKEW dummy&+8,0
	POKEL dummy&+6,addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_link
	appl_write id,16,dummy&
	olga_protocol_link=-1
END IF
END FUNCTION


FUNCTION olga_protocol_unlink (BYVAL filename$,BYVAL group_id)
SHARED dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_unlink=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_unlink=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,group_id
	POKEW dummy&+8,0
	POKEL dummy&+6,addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_unlink
	appl_write id,16,dummy&
	olga_protocol_unlink=-1
END IF
END FUNCTION


FUNCTION olga_protocol_linkrenamed (BYVAL old_filename$,BYVAL new_filename$,BYVAL group_id)
SHARED dummy$,dummy&,old_addr$,old_addr&,new_addr$,new_addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
old_addr$=LEFT$(old_filename$,255)+CHR$(0) : old_addr&=SADD(old_addr$)
new_addr$=LEFT$(new_filename$,255)+CHR$(0) : new_addr&=SADD(new_addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_linkrenamed=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_linkrenamed=0
ELSE
	POKEW dummy&+14,group_id
	POKEW dummy&+12,0
	POKEL dummy&+10,new_addr&
	POKEW dummy&+8,0
	POKEL dummy&+6,old_addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_linkrenamed
	appl_write id,16,dummy&
	olga_protocol_linkrenamed=-1
END IF
END FUNCTION


FUNCTION olga_protocol_start (BYVAL type,BYVAL filename$,BYVAL commandline$)
SHARED dummy$,dummy&,addr$,addr&,comm_addr$,comm_addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
comm_addr$=LEFT$(commandline$,255)+CHR$(0) : comm_addr&=SADD(comm_addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_start=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_start=0
ELSE
	POKEW dummy&+14,0
	POKEL dummy&+12,comm_addr&
	SELECT CASE type
	CASE ols_type
		POKEL dummy&+10,addr&
		POKEW dummy&+8,0
	CASE ols_extension,ols_name
		POKEW dummy&+10,0
		POKEL dummy&+8,addr&
	END SELECT
	POKEW dummy&+6,type
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_start
	appl_write id,16,dummy&
	olga_protocol_start=-1
END IF
END FUNCTION


FUNCTION olga_protocol_ackinfo (BYVAL filename$,BYVAL index)
SHARED dummy$,dummy&,addr$,addr&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
addr$=LEFT$(filename$,255)+CHR$(0) : addr&=SADD(addr$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

IF olga_enabled=0 THEN olga_protocol_ackinfo=0 : EXIT FUNCTION
id=olga_manager_id
IF id=-1 THEN
	olga_protocol_ackinfo=0
ELSE
	POKEW dummy&+14,olga_info
	POKEW dummy&+12,0
	POKEW dummy&+10,index
	POKEW dummy&+8,0
	POKEL dummy&+6,addr&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,olga_ack
	appl_write id,16,dummy&
	olga_protocol_ackinfo=-1
END IF
END FUNCTION

'[*END OF FILE*]
