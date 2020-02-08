
' [DISK.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

DECLARE FUNCTION ReportError$ (toserr)
DECLARE SUB RelaySourceProgress (drive$,no_sectors,track,side)
DECLARE SUB RelayDestProgress (drive$,no_sectors,track,side,copy)
DECLARE SUB update_mouse	' Can be found in CURSER.BAS

DIM SHARED trackbuf&(0),formatbuf&(0),vertrackbuf&(1024),analysebuf&(0)

FUNCTION freediskspace& (drive)
STATIC buffer&(),free&

DIM buffer&(4)
dfree buffer&(), drive
free&=buffer&(0)*buffer&(2)*buffer&(3)
freediskspace&=free&
END FUNCTION


FUNCTION ConvDisk (drive$)
STATIC drive
drive=ASC(UCASE$(LEFT$(drive$,1)))-ASC("A")
ConvDisk=drive
END FUNCTION

FUNCTION DiskError (toserr)
STATIC button,ErrorString$

MOUSE 0
SELECT CASE toserr
	CASE -2
		button=form_alert (1,"[1][  "+MyProgram$+": |  ERROR: Drive not ready! ][ Try Again | Cancel ]")
		SELECT CASE button
			CASE 1 : DiskError=1
			CASE 2 : DiskError=0
		END SELECT
	CASE -13
		button=form_alert (1,"[1][  "+MyProgram$+": |  ERROR: Disk 'Write protected!' ][ Try Again | Cancel ]")
		SELECT CASE button
			CASE 1 : DiskError=1
			CASE 2 : DiskError=0
		END SELECT
	CASE ELSE
		ErrorString$=ReportError$ (toserr)
		junk=form_alert(1,"[1][  "+MyProgram$+": |  ERROR: "+ErrorString$+" ][ Abort ]") : DiskError=0
END SELECT
END FUNCTION


SUB AnalyseDisk (drvsrc,no_sectors,no_tracks,no_sides)
STATIC toserr,trackaddr&,a&,b&,c&,d&,result

reanalyse:

REDIM analysebuf&(4608)
trackaddr&=VARPTR(analysebuf&(0))
toserr=floprd(trackaddr&,drvsrc,1,0,0,1)
IF toserr<0 THEN
	result=DiskError (toserr)
	IF result=0 THEN REDIM analysebuf&(0) : no_sectors=0 : EXIT SUB
	GOTO reanalyse
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
SHARED copy_handle
STATIC trackaddr&,vertrackaddr&,formataddr&,track,side,sector,copiesdone
STATIC button,result,read_tracks,toserr,position&,drvsrc,drvdest
STATIC d_sectors,d_tracks,d_sides,old_format

redocopy:

drvsrc=ConvDisk (drvsrc$) : drvdest=ConvDisk (drvdest$)
sector=1 : position&=0
FOR track=from_track TO no_tracks-1
	FOR side=0 TO no_sides
		update_mouse
		CALL RelaySourceProgress (drvsrc$,no_sectors,track+1,side+1)

		trackaddr&=VARPTR(trackbuf&(position&))
		toserr=floprd(trackaddr&,drvsrc,sector,track,side,no_sectors)
		IF toserr<0 THEN
			result=DiskError (toserr)
			IF result=0 THEN REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
			MOUSE 0
			button=form_alert (1,"[1][  "+MyProgram$+": |  Insert source disk ][ OK | Cancel ]")
			SELECT CASE button
				CASE 2 : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
			END SELECT
			GOTO redocopy
		END IF

		update_mouse
		position&=position&+(512*no_sectors)
		IF INKEY$=CHR$(27) THEN
			MOUSE 0
			button=form_alert (1,"[1][  "+MyProgram$+": |  Reading interupted...? ][ Continue | Cancel ]")
			SELECT CASE button
				CASE 2 : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
			END SELECT
		END IF
	NEXT side
NEXT track

FOR copiesdone=1 TO copies
	MOUSE 0
	IF copiesdone>1 THEN
		button=form_alert (1,"[1][  "+MyProgram$+": |  Insert next destination disk! ][ OK | Cancel ]")
		SELECT CASE button
			CASE 2 : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
		END SELECT
	ELSE
		button=form_alert (1,"[1][  "+MyProgram$+": |  Insert destination disk ][ OK | Cancel ]")
		SELECT CASE button
			CASE 2 : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
		END SELECT
	END IF

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
			update_mouse
			CALL RelayDestProgress (drvdest$,no_sectors,track+1,side+1,copiesdone)

			trackaddr&=VARPTR(trackbuf&(position&))
			IF format<>0 THEN
				toserr=flopfmt(formataddr&,0,drvdest,no_sectors,track,side,1)
				IF toserr<0 THEN
					result=DiskError (toserr)
					IF result=0 THEN REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
					GOTO redodestcopy
				END IF
			END IF
			update_mouse
			IF verify<>0 THEN
				vertrackaddr&=VARPTR(vertrackbuf&(0))
				toserr=flopver(vertrackaddr&,drvdest,sector,track,side,no_sectors)
				IF toserr<0 THEN
					result=DiskError (toserr)
					IF result=0 THEN REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
					GOTO redodestcopy
				END IF
			END IF

			toserr=flopwr(trackaddr&,drvdest,sector,track,side,no_sectors)
			IF toserr<0 THEN
				result=DiskError (toserr)
				IF result=0 THEN REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
				GOTO redodestcopy
			END IF
			position&=position&+(512*no_sectors)

			update_mouse
			IF INKEY$=CHR$(27) THEN
				MOUSE 0
				button=form_alert (1,"[1][  "+MyProgram$+": |  Copying interupted...? ][ Continue | Cancel ]")
				SELECT CASE button
					CASE 2 : REDIM formatbuf&(0) : REDIM trackbuf&(0) : DoCopyDisk=0 : EXIT FUNCTION
				END SELECT
			END IF
		NEXT side
	NEXT track
	format=old_format
NEXT copiesdone
MOUSE 0 : DoCopyDisk=-1
END FUNCTION


FUNCTION CopyDisk (drvsrc$,drvdest$,format,verify,copies)
STATIC trackaddr&,formataddr&,track,side,sector,button,drvsrc,drvdest
STATIC toserr,no_sectors,no_tracks,no_sides,mem_required&,result

recopy:

button=form_alert (1,"[1][  "+MyProgram$+": |  Insert source disk ][ OK | Cancel ]")
SELECT CASE button
	CASE 2 : CopyDisk=0 : EXIT FUNCTION
END SELECT

drvsrc=ConvDisk (drvsrc$) : drvdest=ConvDisk (drvdest$)
IF drvsrc=drvdest THEN junk=form_alert (1,"[1][  "+MyProgram$+": |  ERROR: The source and destination|  cannot be the same! ][ Abort ]") : CopyDisk=0 : EXIT FUNCTION
CALL AnalyseDisk (drvsrc,no_sectors,no_tracks,no_sides)
IF no_sectors=0 THEN junk=form_alert (1,"[1][  "+MyProgram$+": |  ERROR: Disk could not be analysed! ][ Abort ]") : CopyDisk=0 : EXIT FUNCTION
mem_required&=(512*no_sectors) : mem_required&=mem_required&*no_tracks
mem_required&=mem_required&*(no_sides+1)

IF mem_required&<FRE(-1) THEN
	REDIM trackbuf&(mem_required&)
	result=DoCopyDisk (drvsrc$,drvdest$,0,no_sectors,no_tracks,no_sides,format,verify,copies)
	IF result=0 THEN CopyDisk=0 : REDIM trackbuf&(0) : REDIM formatbuf&(0) : EXIT FUNCTION
ELSE
	mem_required&=(512*no_sectors) : mem_required&=mem_required&*(no_tracks/2)
	mem_required&=mem_required&*(no_sides+1)
	IF mem_required&<FRE(-1) THEN
		REDIM trackbuf&(mem_required&)
		result=DoCopyDisk (drvsrc$,drvdest$,0,no_sectors,(no_tracks/2),no_sides,format,verify,copies)
		IF result=0 THEN CopyDisk=0 : REDIM trackbuf&(0) : REDIM formatbuf&(0) : EXIT FUNCTION
		result=DoCopyDisk (drvsrc$,drvdest$,(no_tracks/2),no_sectors,no_tracks,no_sides,format,verify,copies)
		IF result=0 THEN CopyDisk=0 : REDIM trackbuf&(0) : REDIM formatbuf&(0) : EXIT FUNCTION
	ELSE
		junk=form_alert (1,"[1][  "+MyProgram$+": |  Not enough memory to copy |  disk! ][ OK ]")
		CopyDisk=0 : REDIM trackbuf&(0)
		REDIM formatbuf&(0) : EXIT FUNCTION
	END IF
END IF
MOUSE 0 : CopyDisk=-1
REDIM trackbuf&(0) : REDIM formatbuf&(0)
END FUNCTION


FUNCTION FormatDisk (drvdest$,frmsectors,frmtracks,frmsides,verify)
STATIC buffer&(),drvdest,sectors,track,side,toserr,dtype,totalsectors
STATIC boot&,bootinfo&,i,result

reformat:

drvdest=ConvDisk (drvdest$) : REDIM buffer&(9217)
FOR track=0 TO frmtracks-1
	FOR side=0 to frmsides-1
		update_mouse
		toserr=flopfmt(VARPTR(buffer&(0)),0,drvdest,frmsectors,track,side,1)
		IF toserr<0 THEN
				result=DiskError (toserr)
				IF result=0 THEN REDIM buffer&(0) : FormatDisk=0 : EXIT FUNCTION
				GOTO reformat
			END IF
		update_mouse
		IF verify<>0 THEN
			toserr=flopver(VARPTR(buffer&(0)),drvdest,1,track,side,frmsectors)
			IF toserr<0 THEN
				result=DiskError (toserr)
				IF result=0 THEN REDIM buffer&(0) : FormatDisk=0 : EXIT FUNCTION
				GOTO reformat
			END IF
		END IF
	NEXT side
NEXT track

update_mouse
FOR i=0 to (512*frmsectors)
	buffer&(i)=0
NEXT i
toserr=flopwr(VARPTR(buffer&(0)),drvdest,1,0,0,frmsectors)
IF toserr<0 THEN
	MOUSE 0
	result=DiskError (toserr)
	IF result=0 THEN REDIM buffer&(0) : FormatDisk=0 : EXIT FUNCTION
	GOTO reformat
END IF

update_mouse
IF frmsides=1 and frmtracks<41 then dtype=0
IF frmsides=2 and frmtracks<41 then dtype=1
IF frmsides=1 and frmtracks>40 then dtype=2
IF frmsides=2 and frmtracks>40 then dtype=3

totalsectors=frmsides*(frmtracks*frmsectors)
bootinfo&=(totalsectors-(int(totalsectors/256)*256))
update_mouse

boot&=varptr(buffer&(0))
protobt boot&,&h1000000,dtype,0
pokeb boot&,&hE9
pokeb boot&+&h13,bootinfo&
pokeb boot&+&h14,int(totalsectors/256)
POKEB boot&+&h18,frmsectors
pokeb boot&+&h19,0

update_mouse
toserr=flopwr(boot&,drvdest,1,0,0,1)
IF toserr<0 THEN
	MOUSE 0
	junk=form_alert (1,"[1][  "+MyProgram$+": |  Bootsector could not be |  written! ][ Abort ]")
	REDIM buffer&(0) : FormatDisk=0 : EXIT FUNCTION
END IF
REDIM buffer&(0) : FormatDisk=-1
MOUSE 0
END FUNCTION

'[*END OF FILE*]
