REM            TRIANGLS
'
LOCATE 1,30
PRINT "TRIANGLS"
x=100
y=100
'
COLOR 1,3,4,8,2
LINEF x,y,x+30,y              ' base line
LINEF x,y-20,x+30,y           ' up at an angle
LINEF x,y,x,y-20              ' close to base line
FILL x+10,y-2
'
COLOR 1,2,4,8,2
LINEF x+100,y,x+150,y+10      ' base line, sloping down
LINEF x+150,y+10,x+190,y-40   ' slope up from base
LINEF x+190,y-40,x+100,y      ' link to start
FILL x+120,y-2                ' min-max x/2. min y-2
'
y=200
COLOR ,11,2,8,2
FOR n=1 TO 3
LINEF x+10,y,x+50,y+10      ' base line, sloping down
LINEF x+50,y+10,x+90,y-40   ' slope up from base
LINEF x+90,y-40,x+10,y      ' link to start
FILL x+20,y-1
x=x+40
y=y+30
NEXT n
'
x=100
y=100
COLOR ,,10
FOR n=1 TO 4                  ' repeated sloping lines
LINEF x+260,y+10,x+340,y-20
x=x+20
y=y-1
NEXT n


