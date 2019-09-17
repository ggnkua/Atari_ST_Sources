REM $include G:\turtle\turtle.bas
' adda`s turtle graphics library
' lesson 1
' the basics


' simple movement of the turtle
fwd 50
right 90
fwd 50
right 90
fwd 50
right 90
fwd 50
right 90

' this draws a square
' using a loop is much better
FOR i=1 TO 4
fwd 50
right 90
NEXT i

' writing a procedure is easy
' use a basic sub-program
SUB sqar
STATIC i
FOR i=1 TO 4
fwd 50
right 90
NEXT i
END SUB

' try to imagine yourself following the commands
' you can even pass parameters to procedures
SUB sqar1(side)
STATIC i
FOR i=1 TO 4
fwd side
right 90
NEXT i
END SUB

' this can lead to interesting shapes
sid=50
FOR f=1 TO 10
sqar1 sid
sid=sid-5
NEXT f

' in another window try some shapes yourself
' don`t forget to include the library
