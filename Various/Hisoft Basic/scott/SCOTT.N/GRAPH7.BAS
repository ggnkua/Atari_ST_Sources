rem         GRAPH7.bas   draw simple graph; LINEF from data statements
'
x=80                     ' x position for start of graph
y=120                    ' set base line
linef x,y,300,y          ' draw base line
locate 2,20              ' print title at y=2, x=20
print "SALES"            ' title
y=y-sales                ' sales value to rise above bas line
for n=1 to 7             ' do the following 7 times
read sales               ' read data items one at a time
sales=sales*2                     ' scaling; alter as required
linef x,y,x+20,120-sales          ' draw lines to each new data value
x=x+20                            ' move 20 pixels to the right
y=120-sales                       ' link from last position
next n                            ' look at next data value
rem if more or less then 7 data values, alter n=1 to ? to match, in line 8
rem  note that you must not add rems at the end of a data line.
data 25,1,8,5,30,0,11              
