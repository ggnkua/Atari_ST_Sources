'DKB Gear Data file Generator by Ken Koehler
'Updated to DKB 2.11 by Aaron A. Collins

defdbl a-z
const FALSE= 0
const TRUE = NOT FALSE
CONST PI = 3.141592653589#
CONST RAD2DEG = 360/(2*PI)

while (tooth$<>"P") and (tooth$<>"F")
  input "Tooth type (Pointed/Flat):";Tooth$
  if tooth$="p" then tooth$="P"
  if tooth$="f" then tooth$="F"
wend
while (wheel$<>"D") and (wheel$<>"S")
  input "Wheel type (Disk/Spokes)     :";wheel$
  if wheel$="d" then wheel$="D"
  if wheel$="s" then wheel$="S"
wend
input "Number of teeth                :";nt
input "Gear Radius         from center:";dr
input "Disk/Spoke Thicknes from center:";dt
input "Tooth Height                   :";th
input "Tooth&Hub Thickness from center:";tt
input "Axel Radius         from center:";ar
input "Hole/Spoke Multiple            :";hm
if hm then if (nt mod hm) then print nt;"is not an even multiple of";hm
screen 1 : color 7
'if tooth$="F" then th=th*2              ' adjust for theoretic point
if dr>dr+(th/2) then wy=dr else wy=dr+(th/2) ' get max XY dimension
boundxy=wy				' save it for bounding
if dt>tt then boundz=dt else boundz=tt	' get max Z dimension
wy=wy*1.1				' allow % extra screen space
wx=wy*1.5				' adjust aspect ratio
window (-wx,-wy) - (wx,wy)		' create window sized for object
  open "gear.dat" for output as #1
  print #1,"INCLUDE ";chr$(34);"shapes.dat";chr$(34)
  print #1,"INCLUDE ";chr$(34);"colors.dat";chr$(34)
  print #1,"INCLUDE ";chr$(34);"textures.dat";chr$(34)
  print #1,
  print #1,"DECLARE GearW00Col = COLOUR Red
  print #1,"DECLARE GearW00Tex = TEXTURE
  print #1,"    COLOUR GearW00Col
  print #1,"END_TEXTURE
  print #1,
  print #1,"DECLARE GearH00Col = COLOUR Red
  print #1,"DECLARE GearH00Tex = TEXTURE
  print #1,"    COLOUR GearH00Col
  print #1,"END_TEXTURE
  print #1,
  print #1,"DECLARE GearT00Col = COLOUR Red
  print #1,"DECLARE GearT00Tex = TEXTURE
  print #1,"    COLOUR GearT00Col
  print #1,"END_TEXTURE
  print #1,
  print #1,"DECLARE Gear00 =
  print #1,"  COMPOSITE
  print #1,"         { '";tooth$;"' '";wheel$;"'  nt =";nt;"  dr=";dr;"  dt=";dt;"  th=";th;"  tt=";tt;"  ar=";ar;"  hm=";hm;" }"
  ark=2*pi/nt/2
  tp=dr+(th/2)
  tb=dr-(th/2)
  tr=tb-(th/3)
  ab=ar*1.5
  hb=tb/2
  hr=tb/(nt/hm)
  a1x=cos(-ark)*tb : a1y=sin(-ark)*tb : a1z=tt
  aspect=4*(wy/wx)/3
  circle (0,0),tb,1,,,aspect
  if tt>dt then circle (0,0),tr,1,,,aspect
  circle (0,0),ar,1,,,aspect
  if tt>dt then circle (0,0),ab,1,,,aspect
  for angle = 0 to (2*pi)-ark step ark*2
      b1x=cos(angle)*tp     : b1y=sin(angle)*tp     : b1z=tt
      line (a1x,a1y)-(b1x,b1y),1
      c1x=cos(angle+ark)*tb : c1y=sin(angle+ark)*tb : c1z=tt
      line (b1x,b1y)-(c1x,c1y),1
      if tooth$="P" then gosub WriteToothPoint
      if tooth$="F" then gosub WriteToothFlat
      a1x=c1x : a1y=c1y : a1z=c1z
  next angle
  if tt>dt or wheel$="S" then gosub WriteHardened
  if wheel$="D" then gosub WriteDisk
  if wheel$="S" then gosub WriteSpokes
  print #1,	 "    BOUNDED_BY"
  print #1,	 "      INTERSECTION"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";boundxy;boundxy;
  print #1,	 " END_QUADRIC"
  print #1,using "        PLANE < 0.0 0.0  1.0> ###.####";boundz;
  print #1,	 " END_PLANE"
  print #1,using "        PLANE < 0.0 0.0 -1.0> ###.####";boundz;
  print #1,	 " END_PLANE"
  print #1,	 "      END_INTERSECTION"
  print #1,	 "    END_BOUND"
  print #1,"  END_COMPOSITE
  close #1
while inkey$="":wend
end

WriteSpokes:
  spoke=0
''for angle= 0 to 359 step 360/(nt/hm)
  for angle = 0 to (2*pi)-ark step (2*PI)/(nt/hm)
    spoke=spoke+1
    line (cos(angle)*ar,sin(angle)*ar)-(cos(angle)*tb,sin(angle)*tb),1
    print #1,	   "    OBJECT"
    print #1,using "      {Spoke ###}";spoke
    print #1,	   "      INTERSECTION"
    print #1,	   "        QUADRIC Cylinder_Y";
    print #1,using " SCALE <###.#### 1.0 ###.####>";dt;dt;
    print #1,	   " END_QUADRIC"
    print #1,using "        PLANE < 0.0  1.0 0.0> ###.####";tb;
    print #1,	   " END_PLANE"
    print #1,using "        PLANE < 0.0 -1.0 0.0> ###.####";-ar;
    print #1,	   " END_PLANE"
    print #1,	   "      END_INTERSECTION"
    print #1,using "      ROTATE <0 0 ###.####>";angle*RAD2DEG
    print #1,	   "      COLOUR GearW00Col TEXTURE GearW00Tex END_TEXTURE"
    print #1,	   "    END_OBJECT"
  next angle
return

WriteDisk:
  print #1,	 "    OBJECT"
  print #1,	 "      {main disk}"
  print #1,	 "      INTERSECTION"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";tb;tb;
  print #1,	 " END_QUADRIC"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";ar;ar;
  print #1,	 " INVERSE END_QUADRIC"
  print #1,using "        PLANE < 0.0 0.0  1.0> ###.####";dt;
  print #1,	 " END_PLANE"
  print #1,using "        PLANE < 0.0 0.0 -1.0> ###.####";dt;
  print #1,	 " END_PLANE"
  if hm then gosub DrillHoles
  print #1,	 "      END_INTERSECTION"
  print #1,	 "      COLOUR GearW00Col TEXTURE GearW00Tex END_TEXTURE"
  print #1,	 "    END_OBJECT"
return

DrillHoles:
  for angle = 0 to (2*pi)-ark step (2*pi)/(nt/hm)
      x=cos(angle)*hb : y=sin(angle)*hb
      circle (x,y),hr,1,,,aspect
      print #1,      "        QUADRIC Cylinder_Z";
      print #1,using " SCALE <###.#### ###.#### 1.0>";hr;hr;
      print #1,using " TRANSLATE <###.#### ###.#### 0.0>";x;y;
      print #1,      " INVERSE END_QUADRIC"
  next angle
return

WriteHardened:
  print #1,	 "    OBJECT"
  print #1,	 "      {tooth base}"
  print #1,	 "      INTERSECTION"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";tb;tb;
  print #1,	 " END_QUADRIC"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";tr;tr;
  print #1,	 " INVERSE END_QUADRIC"
  print #1,using "        PLANE < 0.0 0.0  1.0> ###.####";tt;
  print #1,	 " END_PLANE"
  print #1,using "        PLANE < 0.0 0.0 -1.0> ###.####";tt;
  print #1,	 " END_PLANE"
  print #1,	 "      END_INTERSECTION"
  print #1,	 "      COLOUR GearH00Col TEXTURE GearH00Tex END_TEXTURE"
  print #1,	 "    END_OBJECT"
  print #1,	 "    OBJECT"
  print #1,	 "      {axle ring}"
  print #1,	 "      INTERSECTION"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";ab;ab;
  print #1,	 " END_QUADRIC"
  print #1,	 "        QUADRIC Cylinder_Z";
  print #1,using " SCALE <###.#### ###.#### 1.0>";ar;ar;
  print #1,	 " INVERSE END_QUADRIC"
  print #1,using "        PLANE < 0.0 0.0  1.0> ###.####";tt;
  print #1,	 " END_PLANE"
  print #1,using "        PLANE < 0.0 0.0 -1.0> ###.####";tt;
  print #1,	 " END_PLANE"
  print #1,	 "      END_INTERSECTION"
  print #1,	 "      COLOUR GearH00Col TEXTURE GearH00Tex END_TEXTURE"
  print #1,	 "    END_OBJECT"
return

WriteToothPoint:
  current.tooth%=current.tooth%+1
  print #1, using "       { Tooth #### }";current.tooth%
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y; a1z ;b1x;b1y; b1z ;c1x;c1y; c1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;-a1z ;b1x;b1y;-b1z ;c1x;c1y;-c1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;-a1z ;b1x;b1y; b1z ;b1x;b1y;-b1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;-a1z ;b1x;b1y; b1z ;a1x;a1y; a1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;c1x;c1y;-c1z ;b1x;b1y; b1z ;b1x;b1y;-b1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;c1x;c1y;-c1z ;b1x;b1y; b1z ;c1x;c1y; c1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
return

WriteToothFlat:
  current.tooth%=current.tooth%+1
  print #1, using "       { Tooth #### }";current.tooth%
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y; a1z ;b1x;b1y; b1z ;c1x;c1y; c1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;-a1z ;b1x;b1y;-b1z ;c2x;c2y;-c2z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;-a1z ;b1x;b1y; b1z ;b1x;b1y;-b1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;a1x;a1y;-a1z ;b1x;b1y; b1z ;a1x;a1y; a1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;c1x;c1y;-c1z ;b1x;b1y; b1z ;b1x;b1y;-b1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
  print #1, using "    OBJECT TRIANGLE <###.#### ###.#### ###.####> <###.#### ###.#### ###.####> <###.#### ###.#### ###.####>" ;c1x;c1y;-c1z ;b1x;b1y; b1z ;c1x;c1y; c1z;
  print #1,	  " END_TRIANGLE COLOUR GearT00Col TEXTURE GearT00Tex END_TEXTURE END_OBJECT"
return
