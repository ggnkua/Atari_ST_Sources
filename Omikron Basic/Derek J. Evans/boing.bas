' -----------------------------------
' Desc: Amiga BOING for OMIKRON.BASIC
' Auth: Derek J. Evans 2023
' -----------------------------------
DEFINTL "A-Z"

XBIOS (Getrez,4)
IF Getrez THEN
  FORM_ALERT (1,"[1][|Low Resolution Required][OK]",R): END
ENDIF

POKE $484, PEEK($484) AND NOT 1
PRINT CHR$(27);"f";: MOUSEOFF : CLS : CLIP 0,0,320,200
PALETTE $555,$700,$777,0,$303,0,0,0,$333,0,0,0,$606,$700,$777,0

Sphere_Init

Frame_Max=9: DIM Frames(Frame_Max):Frame_W=71:Frame_H=77

FOR Frame=0 TO Frame_Max
  CLS
  TEXT 0,8,"Rendering Images. Please wait ...."
  TEXT 0,24,"["+ STRING$(Frame,8)+ STRING$(Frame_Max-Frame,32)+"]"
  FILL COLOR =9: PELLIPSE 165,105,30,32
  Sphere_Draw(Frame*2)
  Frames(Frame)= MEMORY(FN Image_Sizeof(Frame_W,Frame_H,4))
  BITBLT 130,64,Frame_W,Frame_H TO Frames(Frame)
NEXT Frame

CLS : LINE COLOR =12:X1=16:X2=-20
FOR I=16 TO 320-16 STEP 16
  DRAW X1,0 TO X1,176: DRAW X1,176 TO X2,200:X1=X1+16:X2=X2+20
NEXT I
FOR I=0 TO 180 STEP 16: DRAW 16,I TO 320-16,I: NEXT I
DRAW 4,185 TO 319,185: DRAW 0,199 TO 319,199

X=100 SHL 16:Y=5 SHL 16:Xx=1 SHL 16:Yy=0 SHL 16
Frame=0:X%=-200:Y%=-200:F%=0

WHILE 1
  WHILE PEEK($FF8207)<225: WEND
  BITBLT Frames(F%) TO X%,Y%,Frame_W,Frame_H,6
  X%= HIGH(X):Y%= HIGH(Y):F%=Frame
  BITBLT Frames(F%) TO X%,Y%,Frame_W,Frame_H,6
  IF X%<4 OR X%>250 THEN Xx=-Xx:X=X+Xx
  IF Y%>110 THEN
    Yy=-Yy:Y=Y+Yy
  ENDIF
  Yy=Yy+3000:X=X+Xx:Y=Y+Yy
  Frame=(X% SHR 1) MOD (Frame_Max+1)
WEND

DEF PROC Sphere_Init
  DIM Sin_!(360),Cos_!(360),Xy%(0,8): LOCAL I,Deg2rad!= PI /180
  FOR I=0 TO 360
    Sin_!(I)= SIN(I*Deg2rad!):Cos_!(I)= COS(I*Deg2rad!)
  NEXT I
RETURN

DEF PROC Sphere_Point(A,Y!,Px,Py)
  LOCAL W!,X!,Z!,Xx!,Yy!
  W!= SQR(10000-Y!*Y!):X!=Sin_!(A)*W!:Z!=Cos_!(A)*W!+200
  Xx!=X!*Cos_!(25)-Y!*Sin_!(25):Yy!=X!*Sin_!(25)+Y!*Cos_!(25)
  WPOKE Px,Xx!*50/Z!+160: WPOKE Py,Yy!*60/Z!+100
RETURN

DEF PROC Sphere_Draw(Spin)
  LOCAL Y,A,Count=0
  LOCAL Px= LPEEK( VARPTR(Xy%(0,0)))+ LPEEK( SEGPTR +20),Py=Px+2
  FOR Y=-90 TO 80 STEP 20
    FOR A=90 TO 220 STEP 10
      Sphere_Point(A-5+Spin,Y-10,Px,Py)
      Sphere_Point(A+5+Spin,Y-10,Px+4,Py+4)
      Sphere_Point(A+5+Spin,Y+10,Px+8,Py+8)
      Sphere_Point(A-5+Spin,Y+10,Px+12,Py+12)
      FILL COLOR =2+(Count AND 1)
      IF Xy%(0,0)>Xy%(0,2) THEN PPOLYGON Xy%(0,8 SHR - COMPILER )
      Count=Count+1
    NEXT A
    Count=Count+1
  NEXT Y
RETURN

DEF FN Image_Sizeof(X,Y,Z)=(((X+15) SHR 4)*Y*Z+3) SHL 1

END
