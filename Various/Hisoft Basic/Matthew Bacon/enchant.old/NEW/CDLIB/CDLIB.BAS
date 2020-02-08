
' [CDLIB.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DECLARE FUNCTION init_CDLIB (drive_letter$,driver$)

CONST cd_offset=0,cd_pause=1,cd_unpause=2,cd_playtime=3,cd_playtracks=4
CONST cd_contents=5,cd_indexcontents=6,cd_poweroff=7,cd_poweron=8,cd_eject=9
CONST cd_volume=10,cd_channelinfo=11,cd_read2sectors=12,cd_read1sector=13
CONST cd_lock=14,cd_unlock=15,cd_audiosettings=16,cd_redbook=17,cd_catalog=19
CONST cd_trackcode=20

DIM SHARED meta&(3)

FUNCTION CDerror (toserr&)
STATIC ErrorString$

MOUSE 0
SELECT CASE toserr&
CASE -14 : junk=init_CDLIB (junk$,junk$)
CASE ELSE
	ErrorString$=ReportError$ (toserr&)
	junk=form_alert(1,"[1][  "+MyProgram$+": |  ERROR: "+STR$(toserr&)+" |  "+ErrorString$+" ][ Abort ]")
END SELECT
END FUNCTION


FUNCTION init_CDLIB (drive_letter$,driver$)
SHARED cdlib_drive$
STATIC dummy,dummy&,char,toserr&

cdinit VARPTR(meta&(0))
IF meta&(1)=0 THEN
	init_CDLIB=0
    drive_letter$=""
	driver$=""
ELSE
	init_CDLIB=-1
	drive_letter$=""
	FOR dummy=0 TO 25
		IF (meta&(0) AND (2^dummy)) THEN drive_letter$=CHR$(65+dummy)
	NEXT dummy
	cdlib_drive$=drive_letter$

	IF cdlib_drive$="" THEN
		init_CDLIB=0
	    drive_letter$=""
		driver$=""
		EXIT FUNCTION
	END IF

	driver$="" : dummy&=meta&(1)
	DO
		char=PEEKB(dummy&)
		IF char=0 THEN EXIT LOOP
		driver$=driver$+CHR$(char)
		INCR dummy&
	LOOP

	meta&(0)=0
	toserr&=cdopen&(ASC(drive_letter$),VARPTR(meta&(0)))
	IF toserr&<0 THEN
		junk=CDerror (toserr&)
		init_CDLIB=0
	ELSE
		init_CDLIB=-1
	END IF
END IF
END FUNCTION


FUNCTION pause_CDLIB
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_pause,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	pause_CDLIB=0
ELSE
	pause_CDLIB=-1
END IF
END FUNCTION


FUNCTION unpause_CDLIB
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_unpause,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	unpause_CDLIB=0
ELSE
	unpause_CDLIB=-1
END IF
END FUNCTION


FUNCTION playtime_CDLIB (BYVAL start_min,BYVAL start_sec,BYVAL end_min,BYVAL end_sec)
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

meta&(0)=0
meta&(1)=0
POKEB VARPTR(meta&(0))+0,start_min
POKEB VARPTR(meta&(0))+1,start_sec
POKEB VARPTR(meta&(0))+2,0
POKEB VARPTR(meta&(0))+3,end_min
POKEB VARPTR(meta&(1))+0,end_sec
POKEB VARPTR(meta&(1))+1,0
dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_playtime,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	playtime_CDLIB=0
ELSE
	playtime_CDLIB=-1
END IF
END FUNCTION


FUNCTION playtracks_CDLIB (BYVAL start_track,BYVAL end_track)
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

meta&(0)=0
POKEB VARPTR(meta&(0))+0,start_track
POKEB VARPTR(meta&(0))+1,1
POKEB VARPTR(meta&(0))+2,end_track
POKEB VARPTR(meta&(0))+3,1
dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_playtracks,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	playtracks_CDLIB=0
ELSE
	playtracks_CDLIB=-1
END IF
END FUNCTION


FUNCTION contents_CDLIB (first_track,last_track)
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

meta&(0)=0
dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_contents,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	first_track=0
	last_track=0
	contents_CDLIB=0
ELSE
	first_track=PEEKB(VARPTR(meta&(0))+0)
	last_track=PEEKB(VARPTR(meta&(0))+1)
	contents_CDLIB=-1
END IF
END FUNCTION


FUNCTION eject_CDLIB
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_eject,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	eject_CDLIB=0
ELSE
	eject_CDLIB=-1
END IF
END FUNCTION


FUNCTION volume_CDLIB (BYVAL volume)
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

IF volume>100 THEN volume=100
IF volume<0 THEN volume=0
meta&(0)=((16777215/100)*volume)
dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_volume,VARPTR(meta&(0)))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	volume_CDLIB=0
ELSE
	volume_CDLIB=-1
END IF
END FUNCTION


FUNCTION close_CDLIB
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&

dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdclose&(ASC(cdlib_drive$))
close_CDLIB=-1
END FUNCTION


FUNCTION catalog_CDLIB (catalog$)
SHARED cdlib_drive$
STATIC dummy$,dummy&,toserr&,catalog$

catalog$=STRING$(24,0)
dummy$="FCTL" : dummy&=PEEKL(VARPTR(dummy$))
toserr&=cdioctl&(ASC(cdlib_drive$),dummy&,cd_catalog,VARPTR(catalog$))
IF toserr&<0 THEN
	junk=CDerror (toserr&)
	catalog_CDLIB=0
ELSE
	catalog$=MID$(catalog$,2,23)
	catalog_CDLIB=-1
END IF
END FUNCTION

'[*END OF FILE*]
