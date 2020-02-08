DEFINT a-z
LIBRARY "GEMAES"
'$option q50

DIM SHARED MyProgram$,junk,Finished_Flag,mess(0)
'$include GEMAES.BH
'$include D:\ENCHANT\NEW\OLGA\OLGA.BAS

FUNCTION getaddr_text$(BYVAL addr&)
STATIC dummy$,dummy

dummy$=""
WHILE PEEKB(addr&)
	dummy$=dummy$+CHR$(PEEKB(addr&))
	INCR addr&
WEND
getaddr_text$=dummy$
END FUNCTION


SUB ENCHANTloop
SHARED mess()
STATIC event,key_pressed,clicks,mx,my,kstate,ascii$

REDIM PRESERVE mess(20) : Finished_Flag=0
DO
event=evnt_multi(MU_MESAG+MU_KEYBD+MU_BUTTON,2,1,1,0,0,0,0,0,0,0,0,0,0,_
	VARPTR(mess(0)),0,mx,my,0,kstate,key_pressed,clicks)

IF event AND MU_MESAG THEN CALL HandleUserMessage
IF event AND MU_BUTTON THEN Finished_Flag=-1
IF event AND MU_KEYBD THEN
		ascii$=UCASE$(CHR$(key_pressed AND 255))
		SELECT CASE ascii$
		CASE "Q" : Finished_Flag=-1

'Server/Client
		CASE "E" : PRINT "OLE_EXIT now!" : junk=ole_protocol_exit
		CASE "I" : junk=ole_protocol_init (ol_peer,"ED",0)
		CASE "P" : junk=olga_protocol_init

'Server
		CASE "U" : junk=olga_protocol_update ("D:\CAB\HOME.HTM",0)
		CASE "R" : junk=olga_protocol_rename ("D:\CAB\HOME.HTM","D:\CAB\HOME.HTM")
		CASE "B" : junk=olga_protocol_breaklink ("D:\CAB\HOME.HTM")

'Client
		CASE "O" : junk=olga_protocol_opendoc (6)
		CASE "C" : junk=olga_protocol_closedoc (6)
		CASE "L"
			junk=olga_protocol_link ("D:\CAB\HOME.HTM",6)
			junk=olga_protocol_link ("D:\CAB\HTML\BULLET.GIF",6)
		CASE "N" : junk=olga_protocol_unlink ("D:\CAB\HTML\BULLET.GIF",6)
		CASE "S" : junk=olga_protocol_start (ols_name,"D:\CAB\CAB.APP","D:\CAB\HOME.HTM")

		CASE "1" : junk=olga_protocol_start (ols_type,"ED","D:\CAB\README.TXT")
		CASE "2" : junk=olga_protocol_start (ols_extension,".TXT","D:\CAB\README.TXT")
		CASE "3" : junk=olga_protocol_start (ols_name,"D:\EVEREST.V35\EVEREST.PRG","D:\CAB\README.TXT")

		CASE "5" : junk=olga_protocol_start (ols_extension,".TXT","D:\CAB\README.TXT")
		CASE "6" : junk=olga_protocol_start (ols_extension,"TXT","D:\CAB\README.TXT")
		CASE "7" : junk=olga_protocol_start (ols_extension,".ASC","D:\CAB\README.TXT")
		CASE "8" : junk=olga_protocol_start (ols_extension,"ASC","D:\CAB\README.TXT")
		CASE "9" : junk=olga_protocol_start (ols_extension,".HTM","D:\CAB\README.TXT")
		CASE "0" : junk=olga_protocol_start (ols_extension,"HTM","D:\CAB\README.TXT")
		END SELECT
		CLS:LOCATE 1
		PRINT "E","Exit"
		PRINT "I","Intialise"
		PRINT "U","Update"
		PRINT "R","Rename"
		PRINT "B","Breaklink"
		PRINT "O","OpenDoc"
		PRINT "C","CloseDoc"
		PRINT "L","Link"
		PRINT "N","Unlink"
		PRINT "S","Start"
		PRINT "You pressed: ";ASCII$
		PRINT "junk: ";junk
END IF
LOOP UNTIL Finished_Flag<>0
END SUB

CLS:LOCATE 1
PRINT "E","Exit"
PRINT "I","Intialise"
PRINT "U","Update"
PRINT "R","Rename"
PRINT "B","Breaklink"
PRINT "O","OpenDoc"
PRINT "C","CloseDoc"
PRINT "L","Link"
PRINT "N","Unlink"
PRINT "S","Start"
CALL ENCHANTloop

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB HandleUserMessage
STATIC message,old_filename$,new_filename$
STATIC i,dummy&

'CLS:LOCATE 1
'FOR i=0 TO 7
'	PRINT "mess(";i") ";mess(i)
'NEXT
'PRINT "Press any key..."
'DO
'LOOP UNTIL INKEY$<>""

message=mess(0)
SELECT CASE message
CASE OLGA_INIT  ' Sent by Manager in reply to OLE_INIT
	CLS:LOCATE 1:PRINT "OLGA_INIT"
	PRINT mess(1)
	PRINT HEX$(mess(3))
	PRINT mess(7)
CASE OLGA_ACK  ' Sent by Manager in reply to a message you sent
     message=mess(7)
     SELECT CASE message
     CASE OLGA_UPDATE  ' Sent by Manager
		CLS:LOCATE 1:PRINT "OLGA_UPDATE"
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
     CASE OLGA_INFO  ' Sent by Client in responce to OLGA_INFO
		CLS:LOCATE 1:PRINT "OLGA_INFO"
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
		PRINT mess(5)
     CASE OLGA_RENAME  ' Sent by Manager
		CLS:LOCATE 1:PRINT "OLGA_RENAME"
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(5))))
     CASE OLGA_BREAKLINK  ' Sent by Manager
		CLS:LOCATE 1:PRINT "OLGA_BREAKLINK"
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
     CASE OLGA_OPENDOC  ' Sent by Manager
		CLS:LOCATE 1:PRINT "OLGA_OPENDOC"
		PRINT mess(5)
     CASE OLGA_CLOSEDOC  ' Sent by Manager
		CLS:LOCATE 1:PRINT "OLGA_CLOSEDOC"
		PRINT mess(5)
     CASE OLGA_LINK  ' Sent by Manager confirming link
		CLS:LOCATE 1:PRINT "OLGA_LINK"
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
		PRINT mess(5)
		PRINT mess(6)
     CASE OLGA_UNLINK  ' Sent by Manager confirming unlink
		CLS:LOCATE 1:PRINT "OLGA_UNLINK"
		PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
		PRINT mess(5)
		PRINT mess(6)
     END SELECT
CASE OLGA_GETINFO  ' Sent by Client
	CLS:LOCATE 1:PRINT "OLGA_GETINFO"
	PRINT mess(5)

'	junk=olga_protocol_info (filename$,index)
CASE OLGA_INFO  ' Sent by Server in responce to OLGA_GETINFO
	CLS:LOCATE 1:PRINT "OLGA_INFO"
	PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
	PRINT mess(5)

	junk=olga_protocol_ackinfo (getaddr_text$(SPEEKL(VARPTR(mess(3)))),mess(5))
CASE OLGA_CLIENTTERMINATED  ' Sent by Manager
	CLS:LOCATE 1:PRINT "OLGA_CLIENTERMINATED"
	PRINT mess(1)
	PRINT mess(3)
	PRINT mess(4)
CASE OLGA_UPDATED  ' Sent by Manager
	CLS:LOCATE 1:PRINT "OLGA_UPDATED"
	PRINT mess(1)
	PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
	PRINT mess(5)
	PRINT mess(6)
	PRINT mess(7)
CASE OLGA_RENAMELINK  ' Sent by Manager
	CLS:LOCATE 1:PRINT "OLGA_RENAMELINK"
	PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
	PRINT getaddr_text$(SPEEKL(VARPTR(mess(5))))
	PRINT mess(7)

	junk=olga_protocol_linkrenamed (getaddr_text$(SPEEKL(VARPTR(mess(3)))),getaddr_text$(SPEEKL(VARPTR(mess(5)))),mess(7))
CASE OLGA_LINKBROKEN  'Sent by Manager
	CLS:LOCATE 1:PRINT "OLGA_LINKBROKEN"
	PRINT getaddr_text$(SPEEKL(VARPTR(mess(3))))
	PRINT mess(7)

	junk=olga_protocol_unlink (getaddr_text$(SPEEKL(VARPTR(mess(3)))),mess(7))
CASE OLGA_START  ' Sent by Manager
	CLS:LOCATE 1:PRINT "OLGA_START"
	PRINT mess(3)
	PRINT getaddr_text$(SPEEKL(VARPTR(mess(4))))
	PRINT mess(6)
CASE OLGA_SERVERTERMINATED  ' Sent by Manager
	CLS:LOCATE 1:PRINT "OLGA_SERVERTERMINATED"
	PRINT mess(1)
	PRINT mess(3)
	PRINT mess(4)
CASE OLE_NEW  ' Sent by Manager if started after or in parallel
	CLS:LOCATE 1:PRINT "OLE_NEW"
	PRINT mess(1)
	PRINT HEX$(mess(3))
	PRINT mess(4)
	PRINT mess(5)
	PRINT HEX$(mess(7))
CASE OLE_EXIT  ' Sent by Manager to let you know is no longer exists!
	CLS:LOCATE 1:PRINT "OLE_EXIT"
 	olga_enabled=0
END SELECT
END SUB
