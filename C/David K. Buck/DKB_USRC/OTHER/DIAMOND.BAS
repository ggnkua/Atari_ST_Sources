'DKB Diamond Data file Generator by Ken Koehler
'Updated to DKB 2.11 by Aaron A. Collins

defdbl a-z
const FALSE= 0
const TRUE = NOT FALSE
CONST PI = 3.141592653589#
full.scene=TRUE

input "Number of sides          :";s
input "Top Radius    from center:";tr
input "Top Height    from center:";th
input "Center Radius from center:";cr
input "Bottom Depth  from center:";bd
screen 1 : color 7
if tr>cr then wy=tr else wy=cr		' get max dimension
if th>wy then bound=th else bound=wy
if bd>wy then bound=bd
wy=wy*1.1				' allow % extra screen space
wx=wy*1.5				' adjust aspect ratio
window (-wx,-wy) - (wx,wy)
  open "diamond.dat" for output as #1
  if full.scene then gosub WritePreText
  print #1,
  print #1,"DECLARE Diamond =
  print #1,"  COMPOSITE
  print #1,"         { s =";s ;"  tr=";tr;"  th=";th;"  cr=";cr;"  bd=";bd;" }"
  ''' Constant
  if tr>cr then size=tr else size=cr
  if th+bd>size then size=th+bd
  ark=2*pi/s/2
  b1x=0 	    : b1y=-bd: b1z=0
  a4x=0 	    : a4y= th: a4z=0
  ''' Prep
  long.side=TRUE
  pointx=cos(-2.5*ark) : pointz=sin(-2.5*ark)
  a1x=pointx   *cr  : a1y=00 : a1z=pointz   *cr
  c3x=pointx   *tr  : c3y=th : c3z=pointz   *tr
' line (  0,  0)-(c3x,c3z),1
  line (c3x,c3z)-(a1x,a1z),3
  for angle = (-1.5*ark) to (2*pi)+(-2.5*ark) step ark*2
      if long.side=TRUE  then pointx=cos(angle)     : pointz=sin(angle)
      if long.side=FALSE then pointx=cos(angle+ark) : pointz=sin(angle+ark)
      c1x=pointx*cr : c1y= 00: c1z=pointz*cr
      b2x=pointx*tr : b2y= th: b2z=pointz*tr
'     line (  0,  0)-(b2x,b2z),1
      line (b2x,b2z)-(c1x,c1z),3
      line (c1x,c1z)-(a1x,a1z),3
      line (b2x,b2z)-(c3x,c3z),1
      gosub WritePoint
      a1x=c1x : a1y=c1y : a1z=c1z
      c3x=b2x : c3y=b2y : c3z=b2z
      long.side=NOT long.side
  next angle
  print #1, "   { BOUNDED_BY                          }"
  if th>bd then print #1,      "   { ** WARNING: Watch for bounding off of top surface ** }"
  print #1,using "   {    SPHERE <0 0 0> ###.##";bound*1.01;' MAX+1%
  print #1, " END_SPHERE }"
  print #1, "   { END_BOUND                           }"
  print #1, "  END_COMPOSITE
  if full.scene then gosub WritePostText
  close #1
while inkey$="":wend
end

WritePreText:
  print #1,"INCLUDE ";chr$(34);"shapes.dat";chr$(34)
  print #1,"INCLUDE ";chr$(34);"colors.dat";chr$(34)
  print #1,"INCLUDE ";chr$(34);"textures.dat";chr$(34)
  print #1,
  print #1,"DECLARE DiamondCol = COLOUR Red
  print #1,"DECLARE DiamondTex = TEXTURE
  print #1,"    COLOUR DiamondCol
' print #1,"    REFLECTION 0.4
  print #1,"END_TEXTURE
return

WritePostText:
  print #1,"
  print #1,"VIEW_POINT
  print #1,using "   LOCATION <0.0  0.0  ####.##>";-size*1.5
  print #1,"   DIRECTION <0.0 0.0  1.0>
  print #1,"   UP  <0.0  1.0  0.0>
  print #1,"   RIGHT <1.33333 0.0 0.0>
  print #1,"   LOOK_AT ";
  print #1,using "<0.0 ####.## 0.0>";th-(size/2)
  print #1,"END_VIEW_POINT
  print #1,"
  print #1,"{ Put down the beloved famous raytrace green/yellow checkered floor }
  print #1,"OBJECT
  print #1,using "   PLANE <0.0 1.0 0.0> ####.##";-bd*1.10; ' 10% lower
  print #1," END_PLANE"
  print #1,"
  print #1,"   TEXTURE
  print #1,"      CHECKER COLOUR Yellow COLOUR Green
  print #1,using "      SCALE < ####.## ####.## ####.##>";wy/2;wy/2;wy/2
  print #1,"      AMBIENT 0.1
  print #1,"      DIFFUSE 0.9
  print #1,"   END_TEXTURE
  print #1,"   COLOUR Yellow
  print #1,"END_OBJECT
  print #1,"
  print #1,"{ Put up a ceiling}
  print #1,"OBJECT
  print #1,"   PLANE <0.0 1.0 0.0>  130.00";
  print #1," END_PLANE"
  print #1,"
  print #1,"   TEXTURE
  print #1,"      CHECKER COLOUR White COLOUR Blue
  print #1,using "      SCALE < ####.## ####.## ####.##>";wy/2;wy/2;wy/2
  print #1,"      AMBIENT 0.1
  print #1,"      DIFFUSE 0.9
  print #1,"   END_TEXTURE
  print #1,"   COLOUR Blue
  print #1,"END_OBJECT
  print #1,"
  print #1,"COMPOSITE Diamond
  print #1,"  END_COMPOSITE
  print #1,"
  print #1,"OBJECT
  print #1,"   SPHERE <0.0 0.0 0.0> 2.0 END_SPHERE
  print #1,"   TRANSLATE <100.0  120.0  -130.0>
  print #1,"   TEXTURE
  print #1,"      COLOUR White
  print #1,"      AMBIENT 1.0
  print #1,"      DIFFUSE 0.0
  print #1,"   END_TEXTURE
  print #1,"   LIGHT_SOURCE
  print #1,"   COLOUR White
  print #1,"END_OBJECT
return

WritePoint:
  current.point%=current.point%+1
  print #1, using "       { Side #### }";current.point%
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;a1z  ;c1x;c1y;c1z  ;b1x;b1y;b1z;
  print #1," END_TRIANGLE COLOUR DiamondCol TEXTURE DiamondTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;a1z  ;c1x;c1y;c1z  ;b2x;b2y;b2z;
  print #1," END_TRIANGLE COLOUR DiamondCol TEXTURE DiamondTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;a1z  ;b2x;b2y;b2z  ;c3x;c3y;c3z;
  print #1," END_TRIANGLE COLOUR DiamondCol TEXTURE DiamondTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a4x;a4y;a4z  ;b2x;b2y;b2z  ;c3x;c3y;c3z;
  print #1," END_TRIANGLE COLOUR DiamondCol TEXTURE DiamondTex END_TEXTURE END_OBJECT"
return
