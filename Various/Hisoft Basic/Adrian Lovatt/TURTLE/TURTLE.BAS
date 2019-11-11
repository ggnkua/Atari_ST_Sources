' turtle graphic extensions for hisoft basic 
' ½ adda  th august 


DEFSNG a-z

REM Move turtle forward by r.
SUB fwd(r)
SHARED curx, cury, dir, penstate, aspect
STATIC newx, newy
  newx=curx+(r*COS(dir)*aspect)
  newy=cury+r*SIN(dir)
  IF penstate=-1 THEN
    LINEF curx, cury, newx, newy
  END IF
  curx=newx
  cury=newy
END SUB

REM move turtle back by r
SUB back(r)
SHARED curx, cury, dir, penstate, aspect
STATIC newx, newy
  newx=curx-(r*COS(dir)*aspect)
  newy=cury-r*SIN(dir)
  IF penstate=-1 THEN
    LINEF curx, cury, newx, newy
  END IF
  curx=newx
  cury=newy
END SUB

REM Turn turtle clockwise through r degrees.
SUB right(r)
SHARED dir
  dir=dir+r/180*3.1415926
END SUB

REM Turn turtle anti-clockwise through r degrees.
SUB left(r)
SHARED dir
  dir=dir-r/180*3.1415926
END SUB

REM set penup - no lines
SUB pup
SHARED penstate
  penstate=0
END SUB

REM set pendown - draw lines
SUB pdown
SHARED penstate
  penstate=-1
END SUB

FUNCTION heading
SHARED dir
heading=CINT(dir*180/3.1415926)
END FUNCTION

SUB head(r)
SHARED dir
dir=r/180*3.1415926
END SUB

REM Set this up for a particular screen size.
curx=300 : cury=80 : dir=0

REM this is to keep track of the pen
penstate=-1

REM this is the pixel aspect ratio
REM should be 2 for medium res else 1
aspect=2

