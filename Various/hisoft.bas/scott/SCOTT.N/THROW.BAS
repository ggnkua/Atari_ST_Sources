rem       THROW.BAS  gravity demo 
'
locate 1,30
print "Thrown ball."
'
for x=1 to 600 step 20          ' draw vertical grid
linef x,y+20,x,400
next x
x=0                             ' reset x to 0
for y=20 to 400 step 10          ' draw horizontal grid
linef x,y,600,y
next y
'
for s=1 to 4000 step 5
h=(s*(16*(s*s)))/1000000        ' gravity
color 1,1,1,8,2
pcircle s*3+20,h*5+20,2
if mouse(2)=2 then              ' stop if click right mouse button.
stop                            ' ( in case stuck in loop)
end if
next s

