REM               256NCOLR      Falcon at 256 colours, 640x480
REM
PRINT "        COLR256N; numbers 1 to 256; 640x480, 256 colours."
x=60
y=34
h=23
p=3
FOR l=1 TO 256 
LOCATE p,3
PRINT l               ' color numbers, in column down left edge.
l=l+14                ' 14, + next l,  makes +15
p=p+1
NEXT l
FOR n=1 to 256
COLOR 1,n,1,8,2
BAR x,y,31,h
x=x+32
IF x>535 THEN
x=60
y=y+17                ' to match PRINT rows
p=p+1
END IF
NEXT n
'
DEFINT a_z
LIBRARY "gemvdi"
vst_height 6
vst_color 1
vswr_mode 2                     ' Transparent
v_gtext 300,90,"8"              ' drop text line by 16
v_gtext 294,106,"23"            ' increase Colour numbers by 15
v_gtext 294,122,"38"
v_gtext 294,140,"53"
v_gtext 294,156,"68"
v_gtext 294,172,"83"
v_gtext 294,190,"98"
v_gtext 290,208,"113"
v_gtext 290,226,"128" 
vst_color 16                     ' use white,,on dark colours
v_gtext 290,244,"143"
V_gtext 290,258,"158"
v_gtext 290,276,"173"
v_gtext 290,294,"188"
v_gtext 290,312,"203"
v_gtext 290,330,"218"
v_gtext 290,348,"233"
v_gtext 290,366,"248"
PRINT CHR$(7)
