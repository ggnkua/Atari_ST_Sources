
LIBRARY "GEMVDI"

DEFINT a-z
REM $option k300

DIM inv(10)
DIM outv(57)

IF gdos=-1 THEN

oldhand=cvhandle
REM PRINT "Got old handle"

inv (0)=1
inv (1)=1
inv (2)=1
inv (3)=1
inv (4)=1
inv (5)=1
inv (6)=1
inv (7)=1
inv (8)=1
inv (9)=1
inv (10)=0
PRINT "Set inv() variables"

REM v_opnwk inv(),handle,outv()
REM PRINT "Opening workstation..."

REM IF handle=0 THEN PRINT "Could not open workstation!" : STOP

font=vst_load_fonts
REM PRINT "Loaded fonts..."

size=20

vst_height size
vst_point size

REM vst_alignment 0,0

b=10

FOR a=1 TO font
dummy=vqt_name (a,font$)
vst_font dummy
vst_color 1
t$="Font"+STR$(a)+"='"+font$+"'"
REM PRINT t$
v_gtext 1,b,t$
REM v_justified 1,b,t$,640,1,1
b=b+size
REM DO
REM LOOP UNTIL INKEY$<>""
NEXT a


vst_font 1
vst_unload_fonts
REM PRINT "Unloaded fonts..."
REM v_clswk
REM PRINT "Deleting workstation..."

change_handle oldhand
REM PRINT "Setting old handle..."

END IF