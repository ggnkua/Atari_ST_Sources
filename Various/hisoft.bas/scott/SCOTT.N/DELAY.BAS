rem      DELAY.BAS       3 methods.  Any Resolution except Hi Mono
rem        starts with a short delay.
'
Print "Wait...."
'
for i=1 to 6000        ' waits about 3 seconds
beep                   ' while making a beep noise
next i

'
color 1,0,1
for i=10 to 100 step 10
ellipse 300,100,i,50,0,1000
next
'
for d=1 to 200    
locate 1,1
Print ""              ' prints nothing 200 times, takes about 2 seconds
next d
'
color 1,3,1
for i=10 to 100 step 10
pellipse 300,100,i,50,0,1000
next: color 1,0,1
'
start!=timer
LOCATE 1,1
print "press RETURN"
do                       ' waits for you to press RETURN key.
a$=inkey$
loop until a$=chr$(13)
'
c=2
k=1
for i=1  to 10
color 1,1,c
circle 100+k,80,50
c=c+1
k=k+5
if c>3 then c=1 
next i

