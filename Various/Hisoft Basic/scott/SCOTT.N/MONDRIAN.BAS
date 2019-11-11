rem         MONDRIAN.bas  Low res     
'
DEFINT a-z
LIBRARY "GEMVDI"
'
randomize
cls
for n=1 to 60
x=RND(1)*320
y=RND(1)*180
x1=RND(1)+40
y1=RND(1)+40
vsf_perimeter 1 
vsf_color 1                 ' black
vsf_interior 1
vsl_width 8
vsl_type 1
v_bar x+8,y+8,x1-8,y1-8     ' black outline
c=RND(1)*6+2
vsf_color c
vsf_interior 1
'vr_recfl x,y,x1,y1
v_bar x,y,x1,y1             ' coloured interior
'v_bar x,y,x1,y1
next n