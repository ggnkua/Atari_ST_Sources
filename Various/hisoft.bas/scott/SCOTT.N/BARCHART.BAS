REM       BARCHART   for VGA 6340x480 256 colours, or ST Hi Res. 
'
REM       7 bars, read from Data.
REM
COLOR 1,1,1,8,2
LOCATE 1,34                   ' top row, 34th column
PRINT "BARCHART"
x=100
y=300                         ' try ~170 for Med. or Low Res.
v=0                           ' start with nothing
p=7                           ' ***** set number of data points
'                 now draw base line and upright.
LINEF 97,302,520,302          ' try make ~302 into ~152 for Med or Low Res
LINEF 97,302,97,100           '      also. 
'
FOR n=1 TO p
READ v
v=v*2                         '  manual scaling adjustment
COLOR 1,n,1,8,2
BAR x,y-v,52,v                ' 
x=x+400/p
NEXT n
DATA 20,10,50,99,70,5,40
'
DEFINT a-z
LIBRARY "gemvdi"
vst_height 7
vst_color 4
v_gtext 102,360," Mon   Tue   Wed   Thu    Fri   Sat   Sun" ' try 360 make 180

'
v_gtext 60,348,"  0"       ' try halving the y values (348,248,148)
v_gtext 60,248," 50"
v_gtext 60,148,"100"
'
vst_height 9
v_gtext 200,380,"Days of the Week" 'Try 380 as 190
'
v_gtext 40,130,"Units"
'
vst_height 20             ' height of text
vst_rotation 900          ' turns it 90.0 degrees antic clock, to vertical
v_gtext 62,274,"Sales"

 




