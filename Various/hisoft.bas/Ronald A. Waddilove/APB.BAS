REM Make APB disc

LIBRARY "XBIOS"

a$=STRING$(185000,0)
buffer& = (SADD(a$)+1) AND &HFFFFFFFE

BLOAD "apb1",buffer&
?"Put a blank formatted disc"
INPUT"in drive A then press Return";a$
?:?"Creating APB disc"
CALL writetracks(0,39)
?:INPUT "Insert Cover Disc, then press Return";a$
BLOAD "apb2",buffer&
?:INPUT "Insert APB disc, then press Return";a$:?
CALL writetracks(40,79)
?:INPUT "Press RESET button";a$
SYSTEM

SUB writetracks(start%,finish%)
SHARED buffer&
buf&=buffer&
IF FEXISTS("APB1") THEN STOP
FOR track% = start% TO finish%
	IF FNflopwr%(buf&,0,1,track%,0,9) THEN STOP
	buf&=buf&+512*9
NEXT
END SUB
