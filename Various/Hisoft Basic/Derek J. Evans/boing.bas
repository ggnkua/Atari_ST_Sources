REM $option #-a-b-o-p-v+x-y+

' ----------------------------------
' Desc: Amiga BOING for Hisoft BASIC
' Auth: Derek J. Evans 2023
' Reqs: HSB 1.31+ (Inc. PowerBasic)
' ----------------------------------

DEFLNG a-z

LIBRARY "XBIOS", "GEMVDI", "GEMAES"

IF fn getrez% THEN
  a=fn form_alert%(1,"[1][|Low Resolution Required ][OK]")
  END
END IF

DEF SEG &h484
POKE 0,PEEK(0) AND NOT 1

MOUSE -1:vs_clip 1,0,0,319,199

a=fn setcolor%( 0,&h555)
a=fn setcolor%( 1,&h700)
a=fn setcolor%( 2,&h777)
a=fn setcolor%( 4,&h303)
a=fn setcolor%( 8,&h333)
a=fn setcolor%(12,&h606)
a=fn setcolor%(13,&h700)
a=fn setcolor%(14,&h777)
a=fn setcolor%(15,&h000)

vsf_color 0:v_bar 0,0,320,200
v_gtext 16,16,"Calculating sintables ..."

sphere_init

frame_w=71:frame_h=77:frame_max=9
frame_size=((frame_w+15)\16)*frame_h*4+3

DIM frames%((frame_max+1)*frame_size)

FOR frame=0 TO frame_max
  vsf_color 0:v_bar 0,0,320,200
  vst_point 9
  v_gtext 0,8,"Rendering Images. Please wait ..."
  v_gtext 0,25,"["+STRING$(frame,8)+STRING$(frame_max-frame,32)+"]"
  vsf_color 9:v_ellpie 165,105,30,32,0,3600
  sphere_draw frame*2
  GET (130,64)-(130+frame_w-1,64+frame_h-1),frames%(frame*frame_size) 
NEXT frame

vsf_color 0:v_bar 0,0,320,200
vsl_color 12

x1=16:x2=-20

FOR i=16 TO 320-16 STEP 16
  draw_line x1,0,x1,176
  draw_line x1,176,x2,200
  x1=x1+16:x2=x2+20
NEXT i

FOR i=0 TO 180 STEP 16
  draw_line 16,i,320-16,i
NEXT i

draw_line 4,185,318,185
draw_line 0,199,319,199


x=100*&h10000:xx=&h10000
y=5*&h10000:yy=0:frame=0
x%=-200:y%=-200:f%=0

DO
  DEF SEG &hff8207 
  WHILE PEEK(0) < 230 : WEND
  PUT (x%,y%),frames%(f%*frame_size),XOR
  x%=PEEKW(VARPTR(x))
  y%=PEEKW(VARPTR(y))
  f%=frame
  PUT (x%,y%),frames%(f%*frame_size),XOR
  IF x%<4 OR x%>250 THEN xx=-xx:x=x+xx
  IF y%>110 THEN yy=-yy:y=y+yy
  yy=yy+3000:x=x+xx:y=y+yy
  frame=(x%\1)MOD(frame_max+1)
LOOP UNTIL LEN(INKEY$)

END

SUB sphere_init
  LOCAL i,deg2rad!
  DIM SHARED SIN_!(360),COS_!(360)
  DIM SHARED x(4),y(4)
  deg2rad!=3.141592/180
  FOR i=0 TO 360
    sin_!(i)=SIN(i*deg2rad!)
    cos_!(i)=COS(i*deg2rad!)
  NEXT i
END SUB

SUB sphere_point(a,y!,VARPTR px%, VARPTR py%)
  LOCAL w!,x!,z!,xx!,yy!
  w!=SQR(10000-y!*y!)
  x!=sin_!(a)*w!:z!=cos_!(a)*w!+200
  xx!=x!*cos_!(25)-y!*sin_!(25)
  yy!=x!*sin_!(25)+y!*cos_!(25)
  px%=xx!*50/z!+160
  py%=yy!*60/z!+100
END SUB

SUB sphere_draw(VAL spin)
  LOCAL y,a,count,pts%(7)
  FOR y=-90 TO 80 STEP 20
    FOR a=90 TO 220 STEP 10
      sphere_point a-5+spin,y-10,pts%(0),pts%(1)
      sphere_point a+5+spin,y-10,pts%(2),pts%(3)
      sphere_point a+5+spin,y+10,pts%(4),pts%(5)
      sphere_point a-5+spin,y+10,pts%(6),pts%(7)
      vsf_color 2+(count AND 1)
      IF pts%(0) >= pts%(2) THEN v_fillarea 4,pts%()
      count=count+1
    NEXT a
    count=count+1
  NEXT y
END SUB

SUB draw_line(x1,y1,x2,y2)
  LOCAL pts%(3)
  pts%(0)=x1:pts%(1)=y1
  pts%(2)=x2:pts%(3)=y2
  v_pline 2,pts%()
END SUB

END
