Rem    LINESDEM.bas   coloured lines; ST LOW, or VGA 256 colours
'              press right mouse button to stop.
'
for n=1 to 500     ' number of linesl, larger number=longer display
'
if mouse(2)=2 then
stop
end if
'
x=rnd(1)*320       'setting start of vertical  line
y=200
x1=x+200           ' setting the end of the line
y1=y-200
'
c=rnd(1)*15        ' random colours
color 1,1,c        ' 3rd item c, sets the colour number
linef x,y,x,y1     ' draws vertical line from x,y to x,y1
'
x=0                ' reset  x, y, x1 and  y1
y=200
x1=320
y1=y
color 1,1,c        ' horizontal lines, from x,y to x1,y
y=rnd(1)*200
linef x,y,x1,y 
'
next n             ' repeat the sequence