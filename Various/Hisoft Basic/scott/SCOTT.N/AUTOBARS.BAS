rem     AUTOBARS.BAS      Auto Scaling.    Medium Res.
'
dim a(7)                     ' adjust for number of bars .
max=0
Print "Enter value for each bar."
for i=1 to 7                 ' for 7 bars...adjust if required
rem input a(i)               ' **** manual entries; add rem if using Data.
read a(i)                    ' **** remove REM for Data reading.
'
if a(i)>max then             ' sets max to = current value if > max.
max=a(i)
end if
next i
cls                          ' clears the display
'
Print "                     AUTO scaling bar chart."
locate 17,23
print "Sales"
locate 8,4
print "Weekdays."
n=2                          ' leave room for Title
for i=1 to 7                 ' for 7 entries; **** adjust if required.
for j=1 to 50*a(i)/max       ' scaling factor, (50)
if a(i)>0 then
locate (i+n),(20+j)          ' from row 3 downward           
print "#",                         
end if
next j
locate(i+n),(18)
 print i
n=n+1
next i
'
REM         put REM before Data line, if entering data manually.
DATA 5,100,2,24,82,0,10

