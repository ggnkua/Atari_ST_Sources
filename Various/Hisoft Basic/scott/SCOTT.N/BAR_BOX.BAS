rem               BAR_BOX.BAS    Medium Res.
'
x=10
y=10
x1=x+50
y1=y+20
'
color 1,2,1,1,0      ' red outlined bar
bar x,y,x1,y
'
x=x+5
y=y+30
color 1,2,1,1,3      ' red filled bar with patern 3
bar x,y,x1,y1
' 
x=x+160
y=y+40
color 1,3,1,1,1      ' Green solid filled bar.
bar x,y,x1,y1-90