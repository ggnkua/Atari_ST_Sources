REM   SKETCH.BAS     Simple sketch prg. any Resolution.
'
Print "Hold down Left Mouse to Draw; Right click to STOP." 
DO
IF mouse(2)=1 then PSET(MOUSE(0),MOUSE(1)-20)  ' puts dots where mouse points.
LOOP UNTIL MOUSE(2)=2    ' finish by clicking right mouse button.
