rem       GRID.BAS   Medium res grid, or ST Hi and VGA 640x480
'
x=0                    ' start, top left
y=0
x1=605                 ' near right side of screen
y1=y+160               ' near lower edge of screen (400 for Falcon
'
for n=1 to 30
color 1,1,2,1,1        ' for Red lines Colour 2, use 1 for black
linef x,y,x,y1         ' draws vertical lines across screen
x=x+20                 ' for next line to the right
next n
'
for n=1 to 18
color 1,1,3,1,1        ' for Green lines colour 3, (36 for Falcon
linef 0,y,x1,y         ' draws horizontal lines across screen
y=y+10                 ' for next line down
next n
'
