REM    GRAPH365.BAS   set for Hi Res or Falcon; try halving the Y values for Med/Low Res.
'
LINEF 97,301,520,301         ' base line (Y 301 becomes 150)
LINEF 97,301,97,100          ' y axis
LOCATE 2,34
PRINT "GRAPH365."             ' title
DEFINT a-z
LIBRARY "gemvdi"
vsl_width 1                  ' line width attributes(in ODD numbers)
vsl_type 1                   ' 1 solid;2 long dash;3 dot;4 dash dot
vsl_color 2                  ' line color
x=100                        ' left start of graph
ox=100                       ' left edge
y=300                        ' base line of  graph (halve this also in Med/Low res)
oy=y                         ' starting level
n=365                           ' **** number of data items
s=400/n
FOR n=1 TO 365                  ' is 365 entries 
'READ y
y=RND(1)*100                  ' random test data
y=y*1                         ' manual scaling
y=300-y                       ' try y=150-y for Med/low res
LINEF ox,oy,x,y
'
ox=x
oy=y
x=x+s                         ' step along x axis
NEXT n
vst_height 7                  ' text height
vst_color 4                   ' text color
'                halve the Y values below for Med/low res
v_gtext 92,360, "0       100         200         300          400"
v_gtext 60,345,"  0"
v_gtext 60,295," 50"
v_gtext 60,245,"100"
vst_height 9
v_gtext 190,398,"Days of the Year."
v_gtext 40,130,"Units."
vst_height 20
vst_rotation 900
v_gtext 52,274,"Sales."

'             need 365 data items; substitute your own data
DATA 50,100,10,36,2,  60,8,12,43,13,  48,2,16,6,51,  13,88,12,4,44
DATA 0,50,10,100,5,   20,12,6,30,100,  50
rem etc.