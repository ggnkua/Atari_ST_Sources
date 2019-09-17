FUNCTION howmanydrives
STATIC dummy

dummy=SPEEKW(&h4A6)
howmanydrives=dummy
END FUNCTION

DIM SHARED trackbuf&(0),formatbuf&(0),vertrackbuf&(1024),analysebuf&(0)

FUNCTION DiskError (toserr)
STATIC a$

LOCATE 10:PRINT "                                      "
LOCATE 10:PRINT CHR$(27);"p Error ";toserr;CHR$(27);"q ";ReportError$ (toserr)
LOCATE 11:PRINT "Hit any key to continue (Esc to quit) "
'=========== Wait for key press to continue ===========
DO
	a$=INKEY$
LOOP UNTIL a$<>""
LOCATE 10:PRINT "                                      "
LOCATE 11:PRINT "                                      "
IF a$=CHR$(27) THEN SYSTEM
DiskError=toserr
END FUNCTION

FUNCTION ConvDisk (drive$)
STATIC drive
drive=ASC(UCASE$(LEFT$(drive$,1)))-ASC("A")
ConvDisk=drive
END FUNCTION

SUB AnalyseDisk (drvsrc,no_sectors,no_tracks,no_sides)
STATIC toserr,trackaddr&,a&,b&,c&,d&,result

reanalyse:

REDIM analysebuf&(4608)
trackaddr&=VARPTR(analysebuf&(0))
toserr=floprd(trackaddr&,drvsrc,1,0,0,1)
IF toserr<0 THEN
	result=DiskError (toserr)
	REDIM analysebuf&(0) : no_sectors=0 : EXIT SUB
END IF
no_sectors=PEEKB(trackaddr&+&h18)

a&=PEEKB(trackaddr&+&h13)
b&=PEEKB(trackaddr&+&h14)
c&=PEEKB(trackaddr&+&h18)
d&=a&+(b&*256)
no_tracks=(d&/no_sectors)

IF PEEKW(trackaddr&+&h001A)=256 THEN
	no_sides=0
ELSE
	no_sides=1
	no_tracks=(no_tracks/2)
END IF
REDIM analysebuf&(0)
END SUB

FUNCTION DoCopyDisk (drvsrc$,drvdest$,from_track,no_sectors,no_tracks,no_sides,format,verify,copies)
STATIC trackaddr&,vertrackaddr&,formataddr&,track,side,sector,copiesdone
STATIC button,result,read_tracks,toserr,position&,drvsrc,drvdest
STATIC d_sectors,d_tracks,d_sides,old_format,a$

redocopy:

drvsrc=ConvDisk (drvsrc$) : drvdest=ConvDisk (drvdest$)
sector=1 : position&=0
FOR track=from_track TO no_tracks-1
	FOR side=0 TO no_sides
		CALL RelaySourceProgress (drvsrc$,no_sectors,track+1,side+1,copiesdone)

		trackaddr&=VARPTR(trackbuf&(position&))
		toserr=floprd(trackaddr&,drvsrc,sector,track,side,no_sectors)
		IF toserr<0 THEN
			result=DiskError (toserr)
			REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
		END IF

		position&=position&+(512*no_sectors)
		IF INKEY$=CHR$(27) THEN
			REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
		END IF
	NEXT side
NEXT track

LOCATE 7:PRINT "Insert DESTINATION disk into Drive "+drvdest$
LOCATE 8:PRINT "Hit any key to continue (Esc to quit) "
LOCATE 10:PRINT "                                      "
'=========== Wait for key press to start backup ===========
DO
	a$=INKEY$
LOOP UNTIL a$<>""
IF a$=CHR$(27) THEN SYSTEM

redodestcopy:
CALL AnalyseDisk (drvdest,d_sectors,d_tracks,d_sides)
old_format=format
IF d_sectors<>no_sectors THEN format=1
IF d_tracks<>no_tracks THEN format=1
IF d_sides<>no_sides THEN format=1

position&=0 : formataddr&=0
REDIM formatbuf&(9217)
formataddr&=VARPTR(formatbuf&(0))

FOR track=from_track TO no_tracks-1
	FOR side=0 TO no_sides
		trackaddr&=VARPTR(trackbuf&(position&))
		IF format<>0 THEN
			CALL RelayFormatProgress (drvdest$,no_sectors,track+1,side+1)
			toserr=flopfmt(formataddr&,0,drvdest,no_sectors,track,side,1)
			IF toserr<0 THEN
				result=DiskError (toserr)
				IF result=-13 THEN GOTO redodestcopy
				REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
			END IF
		END IF
		IF verify<>0 THEN
			vertrackaddr&=VARPTR(vertrackbuf&(0))
			toserr=flopver(vertrackaddr&,drvdest,sector,track,side,no_sectors)
			IF toserr<0 THEN
				result=DiskError (toserr)
				IF result=-13 THEN GOTO redodestcopy
				REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
			END IF
		END IF

		CALL RelayDestProgress (drvdest$,no_sectors,track+1,side+1,copiesdone)
		toserr=flopwr(trackaddr&,drvdest,sector,track,side,no_sectors)
		IF toserr<0 THEN
			result=DiskError (toserr)
			IF result=-13 THEN GOTO redodestcopy
			REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
		END IF
		position&=position&+(512*no_sectors)

		IF INKEY$=CHR$(27) THEN
			REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
		END IF
	NEXT side
NEXT track
format=old_format
DoCopyDisk=-1
END FUNCTION

FUNCTION CopyDisk (drvsrc$,drvdest$,format,verify,copies)
STATIC trackaddr&,formataddr&,mem_required&,result,from_track,to_track
STATIC drvsrc,drvdest,no_sectors,no_tracks,no_sides

recopy:
drvsrc=ConvDisk (drvsrc$) : drvdest=ConvDisk (drvdest$)
CALL AnalyseDisk (drvsrc,no_sectors,no_tracks,no_sides)
IF no_sectors=0 THEN
	result=DiskError (-8)
	CopyDisk=0 : EXIT FUNCTION
END IF

from_track=0
FOR to_track=0 TO no_tracks STEP +1
	mem_required&=(512*no_sectors)
	mem_required&=mem_required&*(to_track-from_track)
	mem_required&=mem_required&*(no_sides+1)

	IF mem_required&<FRE(-1) THEN
		IF to_track=no_tracks
			REDIM trackbuf&(mem_required&)
			result=DoCopyDisk (drvsrc$,drvdest$,from_track,no_sectors,to_track,no_sides,format,verify,copies)
			IF result=0 THEN
				CopyDisk=0 : REDIM trackbuf&(0)
				REDIM formatbuf&(0) : EXIT FUNCTION
			END IF
			EXIT FOR
		END IF
	ELSE
		DECR to_track
		mem_required&=(512*no_sectors)
		mem_required&=mem_required&*(to_track-from_track)
		mem_required&=mem_required&*(no_sides+1)

		REDIM trackbuf&(mem_required&)
		result=DoCopyDisk (drvsrc$,drvdest$,from_track,no_sectors,to_track,no_sides,format,verify,copies)
		IF result=0 THEN
			CopyDisk=0 : REDIM trackbuf&(0)
			REDIM formatbuf&(0) : EXIT FUNCTION
		END IF
		IF to_track=no_tracks THEN EXIT FOR
		LOCATE 7:PRINT "                                      "
		LOCATE 7:PRINT "Insert SOURCE disk into Drive A"
		from_track=to_track
	END IF
NEXT to_track
REDIM trackbuf&(0) : REDIM formatbuf&(0)
CopyDisk=-1
END FUNCTION
