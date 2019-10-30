REM Backup Cover Disc (81 track x 10 sectors)
REM Compile with HiSoft Basic
REM By R.A.Waddilove
REM Last altered 10/8/89

LIBRARY "XBIOS"

DIM a%(110000)
buffer& = VARPTR(a%(0))

? "********** Copy disc **********"
?:INPUT "1 or 2 sides";sides%
?:INPUT "How many tracks";tracks%

FOR s%=0 TO sides%-1
	CALL copy(s%,0,39)
	CALL copy(s%,40,tracks%-1)
NEXT
GOTOXY 0,15: INPUT "All done.....hit Return";a$
SYSTEM

SUB copy(side%,i%,j%)
SHARED buffer&
GOTOXY 0,6 : ? "Copying side";side%
GOTOXY 0,8 : INPUT "Insert source disc, then press Return";a$
buf&=buffer&
FOR track% = i% TO j%
	GOTOXY 0,9 : ? "Reading track"track%;
	buf&=buf&+512*10
	IF FNfloprd%(buf&,0,1,track%,side%,10) THEN SYSTEM
NEXT
GOTOXY 0,11 : INPUT "Insert destination disc, then press Return";a$
buf&=buffer&
FOR track% = i% TO j%
	GOTOXY 0,12 : ? "Writing track";track%;
	buf&=buf&+512*10
	IF FNflopwr%(buf&,0,1,track%,side%,10) THEN SYSTEM
NEXT
END SUB
