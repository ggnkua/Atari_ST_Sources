rem     TEXTEFCT.BAS    Text effects, p 292 in the Manual *** Med Res***
'   must start with DEFINT a-z, and Library "gemvdi";    positions at x,y
'
defint a-z                  ' avoids typing % at end of all functions
library "gemvdi"            ' source of these effects
vst_color 1                 ' 1 black, 2 red, 3 green etc
vst_height 17               ' leave room above base of large text.
vst_rotation 0              ' 900 =anti clock=vertical; 1800=upside down
v_gtext 20,50,"Color 1,height 17,Rotation 0, at 20x,50y"
vst_height 7
v_gtext 20,60,"Height 7,(normal effects)"
vst_effects 1
v_gtext 20,70,"Thickened,1"
vst_effects 8
v_gtext 20,80,"Underlined,8"
vst_effects 4
v_gtext 20,90,"Skewed,4"
vst_effects 16
v_gtext 20,100,"Outline 16"
vst_effects 32
v_gtext 20,110,"Shaddowed, 32"
vst_height 3                       ' just OK at high res. 
v_gtext 20,116,"Height 3"
vst_height 6
vst_rotation 900                   ' vertical text
v_gtext 40,185,"Height 6"
vst_height 7
vst_rotation 0                     ' normal text angle
vst_alignment 1,0         '1=centred on x,0=left Justified, 3 right just.
v_gtext 310,135,"Centred"   ' is base line, 1 half line...5 top of cell.
v_gtext 310,150,"This line also centred on x=310"


