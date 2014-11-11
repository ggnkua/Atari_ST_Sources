rem   COLOURS.BAS     for LOW Resolution. 
'                      (or Falcon 640x480, 256 colours, but Numbers wrong!) 
'
'palette         ' set to default
x=55
y=2
x1=x+20
y1=y+30
a=1
b=17
locate 1,20
print "COLOR Numbers."
'
locate 1,2
print "White"
locate 2,3
print "Black"
locate 3,4
print "Red"
for n=0 to 15
color 1,n,1,1,1
bar x,y,x1,y1
locate a,b
print n
a=a+1
b=b+1
x=x+8
y=y+9
next n
