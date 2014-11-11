rem       GRID_HI.BAS   ST Hi and VGA 640x480
'
x=0                    ' start, top left
y=0
x1=605                 ' near right side of screen
y1=y+400               ' near lower edge of screen (400 for Falcon
'
for n=1 to 30
color 1,1,2,1,1        ' for Red lines Colour 2, use 1 for black
linef x,y,x,y1         ' draws vertical lines across screen
x=x+20                 ' for next line to the right
next n
'
x=0                    ' reset x and y to Zero
y=0
for m=1 to 38
color 1,1,3,1,1        ' for Green lines colour 3, (36ws horizontal lines across screen
linef x,y,x1,y
y=y+10                 ' for next line down
next m
'
