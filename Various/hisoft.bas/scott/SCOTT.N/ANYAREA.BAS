rem      ANYAREA.BAS    Low, Med, or VGA 640,480.
'     line scanning to find selected colour points, 
'       to compare areas , at 5 dot intervals; 1=finest res/slowest.
'                         set in line 62
' 
color 1,1,1,1,0
bar 50,29,200,120             ' frame
linef 50,90,250,90            ' central line
Locate 1,5
print "Compare areas ."
locate 2,2
Print "CONTROL/C to escape."
rem              **** start 1st area. *****
x=50
y=80
color 1,2,2,1,1               ' red area
linef x+20,y-10,x+30,y-40
linef x+30,y-40,x+140,y-30
linef x+140,y-30,x+80,y-10
linef x+80,y-10,x+20,y-10
fill x+35,y-15                ' ensure INSIDE area
'               **** start 2nd area. *****
x=50
y=140
color 1,3,3,1,1               ' green area
linef x+30,y-5,x+100,y-30
linef x+100,y-30,x+160,y-40
linef x+160,y-40,x+60,y-2
linef x+60,y-2,x+30,y-5
fill x+45,y-7                 ' ensure INSIDE area
'                  ****** scanning ******
x=50
y=30
b=0
r=0
g=0
color 1,1,1,8,2               ' black color to show scan
for s=1 to 5250   ' *** to comb down, from y=29 to y=120,(26250 for step 1, 5250 for step 5)
'print s                      ' scan points scanned
a=point(x,y)
if a=2 then                   ' if a Red plot
r=r+1                         ' red plot counter
'color 1,2,1,8,2               ' mark find with red box
'bar x,y,x+2,y-2
'color 1,1,1                   ' revert to scan colour
end if
a=point (x,y)
if a=3 then                   ' if a Green plot
g=g+1
end if
bar x,y,0,0                   ' no 'PLOT' in 1st Basic; use small bar.
if x>248 then                 ' start new line, one row down
b=b+1                         ' number of scanned rows
x=50
y=y+1
end if
if y>149 then
goto results
end if
'locate 3,3
'Print;r;"  Red plots.    ";g;" Green plots" 'for continuous, SLOW readings.
x=x+5            ' **** step interval, 1 for finest resolution
next s
results:
locate 2,2
print;r;" Red plots. ";g;" Green plots."
locate 3,2
Print "         Ratio R/G="r/g









       