library "bios"
dim buffer%(1024)

sec=0
dv$="A"
drv=0
page=0
v=0

here:
cls
print "THE REALLY USEFUL SECTOR EDITOR";
print space$(26);"DRIVE: ";dv$
print space$(57);"SECTOR:";sec
print "    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F";
print "      PAGE:";page
print

gosub rdsec

print
out 5,1
print " - PAGE 0",
out 5,3
print " - ADVANCE A SECTOR     SHIFT";
out 5,3
print " - ADVANCE 10 SECTORS"
out 5,2
print " - PAGE 1",
out 5,4
print " - RETREAT A SECTOR     SHIFT";
OUT 5,4
print " - RETREAT 10 SECTORS"
print "D - CHANGE DRIVE"
keep_on:
k=0
do 
k=inp(2)
if k>0 then exit loop
loop

if k=200 and page=0 then keep_on
if k=208 and page=1 then keep_on
if k=200 then
v=0
page=0
goto here:
end if
if k=208 then
v=256
page=1
goto here:
end if
 

if k=203 and sec<>0 then 
sec=sec-1
v=0
page=0
goto here:
end if

if k=52 and sec>10 then
sec=sec-10
v=0
page=0
goto here:
end if

if k=54 then
sec=sec+10
page=0
v=0
goto here:
end if

if k=205 then
sec=sec+1
v=0
page=0
goto here:
end if

if (k=100 or k=68) and dv$="A" then
dv$="B"
drv=1
v=0
page=0
sec=0
goto here
end if

if (k=100 or k=68) and dv$="B" then
dv$="A"
drv=0
v=0
page=0
sec=0
goto here
end if

goto keep_on

end

rdsec:
call fnrwabs%(0,varptr(buffer%(0)),1,sec,drv)

for a=1 to 16
b$=hex$((a-1)*16)+"  "
if a=1 then b$="0"+b$
print b$;
for t=1 to 16
a$=hex$(peekb(varptr(buffer%(0))+(v)))
if len(a$)=1 then a$="0"+a$
print a$;" ";
v=v+1
next 
v=v-16
print space$(5);
for t=1 to 16
if peekb(varptr(buffer%(0))+(v))<32 then
a$="."
else a$=chr$(peekb(varptr(buffer%(0))+(v)))
end if
print a$;
v=v+1
next 
print
next a
return


