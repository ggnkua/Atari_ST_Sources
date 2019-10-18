dim a$(500)
a=0
c$="\learnbas\words.lst"
open "I",#1,c$ 
while not eof(1)
a=a+1
input#1,inp$
print inp$
a$(a)=inp$
wend
close #1

start:
cls
print "MENU:"
print 
print "1 - add word"
print "2 - save file"
print "3 - quit"
print
print "Press any key..."
print
print

here:
b$=inkey$
if b$="" goto here
on instr ("123",b$) goto add,sav,qut
goto start

add:
found=0
INPUT"TYPE IN NEW WORD AND PRESS RETURN: ",new$
new$=ucase$(new$)
for t=1 to a
if a$(t)=new$ then found=1
next t
if found=1
print
print "WORD ALREADY EXISTS"
print
print "Press any key..."
while inkey$=""
wend
goto start
end if
a=a+1
a$(a)=new$
goto start


sav: 
open "O",#2,c$
for t=1 to a
print a$(t)
print#2, a$(t)
next t
close #2

qut:
end

