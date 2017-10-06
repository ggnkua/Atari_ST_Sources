
LIBRARY "GEMVDI"

DEFINT a-z

DIM test (2,15)
DIM rgb (2)

FOR a=0 TO 15
vq_color a,0,rgb()
test (0,a)=rgb(0)
test (1,a)=rgb(1)
test (2,a)=rgb(2)
NEXT a

FOR a=1000 TO 0 STEP -1
FOR b=0 TO 15
vs_color b,a,a,a
NEXT b
NEXT a

DO
LOOP UNTIL INKEY$<>""

FOR a=0 TO 15
vs_color a,test(0,a),test(1,a),test(2,a)
NEXT a
