defdbl a-z
const FALSE= 0
const TRUE = NOT FALSE
CONST PI = 3.141592653589#

input "Number of points:";p
input "Point Top    from center:";t
input "Point Bottom from center:";b
input "Point Joint  from center:";j
input "Thickness    from center:";th
screen 1 : color 7
if t>b then wy=t else wy=b
if j>wy then wy=j
if th>wy then wy=th
wy=wy*1.1				' allow % extra screen space
wx=wy*1.5				' adjust aspect ratio
window (-wx,-wy) - (wx,wy)
  open "star.dat" for output as #1
  print #1,"DECLARE Star =
  print #1,"  COMPOSITE
  print #1,"         { p=";p;"  t=";t;"  b=";b;"  j=";j;"  th=";th;" }"
  ark=2*pi/p/2
  pointx=cos(-2*ark): pointy=sin(-2*ark)
  a3x=pointx*b	    : a3y=pointy*b	: a3z=th
  c2x=cos(-ark)*j   : c2y=sin(-ark)*j	: c2z=0
  pset (c2x,c2y)
  for angle = 0 to (2*pi)-ark step ark*2
      pointx=cos(angle): pointy=sin(angle)
      a1x=pointx*t	   : a1y=pointy*t	  : a1z=0
      line -(a1x,a1y),1
      b1x=pointx*b	   : b1y=pointy*b	  : b1z=th
      c1x=cos(angle+ark)*j : c1y=sin(angle+ark)*j : c1z=0
      line -(c1x,c1y),1
      c4x=0   : c4y=0	: c4z=th
      gosub WritePoint
      a3x=b1x : a3y=b1y : a3z=b1z
      c2x=c1x : c2y=c1y : c2z=c1z
  next angle
  print #1,"  END_COMPOSITE
  close #1
while inkey$="":wend
end

WritePoint:
  current.point%=current.point%+1
  print #1, using "       { Point #### }";current.point%

  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y; a1z  ;b1x;b1y; b1z  ;c1
x;c1y; c1z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y; a1z  ;b1x;b1y; b1z  ;c2
x;c2y; c2z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a3x;a3y; a3z  ;b1x;b1y; b1z  ;c2
x;c2y; c2z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a3x;a3y; a3z  ;b1x;b1y; b1z  ;c4
x;c4y; c4z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"

  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y; a1z  ;b1x;b1y;-b1z  ;c1
x;c1y; c1z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y; a1z  ;b1x;b1y;-b1z  ;c2
x;c2y; c2z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a3x;a3y;-a3z  ;b1x;b1y;-b1z  ;c2
x;c2y; c2z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a3x;a3y;-a3z  ;b1x;b1y;-b1z  ;c4
x;c4y;-c4z;
  print #1,	  " END_TRIANGLE COLOUR StarCol TEXTURE StarTex END_TEXTURE END_OBJECT"
return
