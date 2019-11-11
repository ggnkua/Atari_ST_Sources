rem               BAR_FILS.BAS   Low,Med, VGA 640x480 256 colours.
'
rem line 10;   Text colour,fill colour,line colour,index,style.
x=10
y=5
x1=x+50
y1=y+8
'
for f=1 to 20
color 1,f,1,f,2      ' f=fill number  (1,2 to 12,3)
bar x,y,x1,y
x=x+20
y=y+12
next f
'
