rem         TOSSCOIN.BAS
'
' 
locate 2,20
print "Tossing a Coin"
print"     Press right mouse to stop"
print
h=0
t=0
 Randomize          ' to be different each time program is run
'
for n=1 to 10000
if mouse(2)=2 then
stop
end if 
x=rnd
if x>.5 then h=h+1
if x<.5 then t=t+1
locate 7,5
print n,"Throws: ";"  ";"Result:-  ";h,"H";"      ";t,"T";
rem print h,"H"
rem print t,"T"
next n


