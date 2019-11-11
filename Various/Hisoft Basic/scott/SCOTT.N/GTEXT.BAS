rem      GTEXT.BAS    graphics text at x,y positions
'
defint a-x
library "gemvdi"
'
vst_color 3
vst_height 9
vst_rotation 0
v_gtext 10,150,"v_gtext height 9 at 10,150"
vst_height 21
vst_color 1
v_gtext 140,70,"v_gtext height 21 at 140,70"
vst_height 7
vst_color 2
vst_rotation 900
v_gtext 500,180,"7 at 500,180"
v_gtext 550,180,"Rotation 900"