REM       BARCHATM.bas   set up for Med Res. 
'
REM       7 bars, read from Data.
REM
COLOR 1,1,1,8,2
LOCATE 1,34                   ' top row, 34th column
PRINT "BARCHART"
x=100
y=140                         ' 
v=0                           ' start with nothing
p=7                           ' ***** set number of data points
'                 now draw base line and upright.
LINEF 97,140,520,140          ' 
LINEF 97,140,97,40            '    
'
FOR n=1 TO p
READ v
v=v*1                         '  manual scaling adjustment, unity.
COLOR 1,1,1,8,2
BAR x,y-v,52,v                ' 
x=x+400/p
NEXT n
DATA 20,10,50,99,70,5,40
'
DEFINT a-z
LIBRARY "gemvdi"
vst_height 7
vst_color 2
v_gtext 102,176," Mon   Tue   Wed   Thu    Fri   Sat   Sun" ' 

'
v_gtext 60,165,"  0"       '
v_gtext 60,248," 50"
v_gtext 60,66,"100"
'
vst_height 9
v_gtext 200,380,"Days of the Week" '
'
v_gtext 30,100,"Units"
'
vst_height 20             ' height of text
vst_rotation 900          ' turns it 90.0 degrees antic clock, to vertical
v_gtext 62,274,"Sales"

 




