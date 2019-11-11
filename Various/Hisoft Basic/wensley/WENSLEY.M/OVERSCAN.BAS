REM $option y
LIBRARY "gemaes","xbios","falcon"
DEFINT a-z

j=shel_write(9,1,0,0,0)
h%=vsetmode%(&HFFFF)

IF (h% AND &B1000000) THEN h%=(h% AND &B1111111110111111) ELSE h%=(h% AND &B1111111110111111)+&B01000000

REM set overscan.

j=shel_write(5,h%,1,0,0)
hj=form_alert(1,"[2][O"+STR$(j)+"][ok]")
SYSTEM
