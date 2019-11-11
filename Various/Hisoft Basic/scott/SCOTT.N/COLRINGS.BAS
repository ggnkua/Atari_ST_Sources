rem   COLRINGS.BAS   colour rings ST Low Res, or VGA 640x480, 256 colours
'

x=160
y=85
r=90
for n = 1 to 15  
color 1,n,1,8,2
pcircle x,y,r-(n*6)
for w = 1 to 10
locate 1,1
print "COLRINGS"
next w
next n

