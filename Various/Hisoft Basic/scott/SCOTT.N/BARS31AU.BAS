REM    BARS31AU set up for Hi Res or Falcon. See BARCHART for notes for Med Res
REM       31 bars, read from Data.  *** Auto Scaled ***
REM                  
COLOR 1,1,1,8,2
LOCATE 1,34
PRINT "BAR31AU"
x=100
y=300
p=31                            ' ***** set number of data points
'
dim v(31)                       ' find max value for Auto Scaling.
for i=1 to 31
read v(i)
next i
'

l=1                             ' L=1
for i=1 to 31
if v(i)>v(l) then               '
l=i
end if
next i
rem                             ' max value is v(l)
'
LINEF 97,302,520,302
LINEF 97,302,97,100
'
restore
FOR n=1 TO p+1
c=n
IF c>15 THEN
c=c+2
END IF
READ d
d=d*200/v(l)                      '  scaling
COLOR 1,c,1,8,2
BAR x,y-d,52/(p/5),d            ' 52/(p/5) is bar width  
x=x+400/p                       ' step along
NEXT n
REM          rows of 20 data values, in groups of 5; Total 31
DATA 20,10,50,99,70, 5,40,2,18,21, 67,13,88,13,56,3, 34,12,77,2,19
DATA 22,1,76,45,99, 56,45,32,23,12, 100
'
DEFINT a-z
LIBRARY "gemvdi"
vst_height 7
vst_color 4
v_gtext 102,360,"1    5      10     15     20     25      30" 
'
v_gtext 60,348,"  0"
v_gtext 60,248," 50"
v_gtext 60,148,"100"
'
vst_height 9
v_gtext 200,375,"Days of the Month"
'
v_gtext 34,130,"Units"
'
vst_height 20
vst_rotation 900
v_gtext 62,274,"Sales"
'                      ******************


 


