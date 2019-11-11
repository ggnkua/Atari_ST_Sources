REM       BARCHATL.bas   set up for Med Res. 
'
REM       7 bars, read from Data.
REM
COLOR 1,1,1,8,2
LOCATE 1,16                   ' top row, 34th column
PRINT "BARCHART"
x=50
y=140                         ' 
v=0                           ' start with nothing
p=7                           ' ***** set number of data points
'                 now draw base line and upright.
LINEF 47,140,260,140          ' 
LINEF 47,140,47,40            '    
'
FOR n=1 TO p
READ v
v=v*1                         '  manual scaling adjustment, unity.
COLOR 1,n,1,8,2
BAR x,y-v,26,v                ' 
x=x+200/p
NEXT n
DATA 20,10,50,99,70,5,40
'
DEFINT a-z
LIBRARY "gemvdi"
vst_height 4
vst_color 2
v_gtext 44,176," Mon  Tue  Wed  Thu  Fri  Sat  Sun" ' 

'
v_gtext 30,165,"  0"       '
v_gtext 60,248," 50"
v_gtext 30,66,"100"
'
vst_height 9
v_gtext 200,380,"Days of the Week" '
'
vst_height 5
v_gtext 20,50,"Units"
'
vst_height 5             ' height of text
vst_rotation 900          ' turns it 90.0 degrees antic clock, to vertical
v_gtext 30,130,"Sales"

 




