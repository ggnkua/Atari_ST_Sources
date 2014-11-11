rem         MONDRIH2.bas  256 colours , 640x480.    
'
DEFINT a-z
LIBRARY "GEMVDI"
'
randomize
cls
vsf_color 1
v_bar 1,1,640,480           ' black area
for n=1 to 60
x=RND(1)*640
y=RND(1)*480
x1=RND(1)*540               ' width
y1=RND(1)*440               ' height
vsf_perimeter 1 
vsf_color 1                 ' black
vsf_interior 1
vsl_width 8
vsl_type 1
v_bar x-8,y+8,x1+8,y1+8     ' for black outline
c=RND(1)*6+2                ' colours (not white or black)
vsf_color c
vsf_interior 1
v_bar x,y,x1,y1             ' coloured interior
next n