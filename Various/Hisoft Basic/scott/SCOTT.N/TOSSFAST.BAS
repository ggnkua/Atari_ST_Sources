rem         TOSSFAST.BAS
'        generates about 40,000 per minute on ST, for 1 million tosses.
'                        70,000 per minute on Falcon
locate 2,20
print "    Fast Coin Tossing; 70,000/min on Falcon."
print"   Set for 1 million tosses;  Press right mouse to stop"
print
print "   Enter seed number"
h=0
t=0
 Randomize          ' to be different each time program is run
'
for n=1 to 1000001      ' allows 1 million tosses; set more if needed.
if mouse(2)=2 then
stop
end if 
x=rnd
if x>.5 then h=h+1
if x<.5 then t=t+1
if n/100=int(n/100) then     ' only print results at 100 intervals 
locate 9,5
print n,"Throws: ";"  ";"Result:-  ";h,"H";"      ";t,"T"
end if
next n


