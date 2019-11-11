rem        MOVE.BAS      PREFERABLY LOW RES, (OR MED)
'
X=10                       ' STARTING POSITIONS
Y=30
X1=X+5                     ' SIZE OF BAR
Y1=Y+10
FOR N=1 TO 116             ' DISPLAY BAR 116 TIMES TO REACH RIGHT SIDE.
C=RND(1)*15                ' 15 RANDOM VALUES OF C
COLOR 1,C,1,8,2            ' 15 RANDOM COLOURS, WITH SOLID FILL
BAR X,Y,X1,Y1              ' DRAWS A BAR
REM PAUSE                  '
FOR P= 1 TO 10             ' 10 TIMES FOR A SLIGHT DELAY
LOCATE 1,1                 ' TO PREVENT SCROLLING
PRINT ""                   ' PRINT NOTHING
NEXT P
COLOR 1,0,1,8,2            ' A WHITE BAR TO ERASE PREVIOUS BAR
BAR X,Y,X1,Y1
X=X+5                      ' MOVE ALONG A BIT
Y=Y+1                      ' MOVE DOWN A BIT
IF Y>100 THEN Y=Y-5        ' SLIGHT BOUNCE
DUMMY$=INKEY$              ' PRESS CONT/C TO STOP
NEXT N                     ' REPEAT EVERYTHING
