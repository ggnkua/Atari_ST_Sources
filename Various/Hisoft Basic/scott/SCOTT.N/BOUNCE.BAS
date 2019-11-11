rem      BOUNCE.BAS    simple ball bounce demo; right mouse STOPS. Med.Res.
'                   ST Med, Hi, VGA 640x480 256 colours.
x=20
y=20
v=0
start:
a=x
b=y
v=v-1
y=y-v
x=x+2
'
color 1,0,1,8,2         ' draws a White circle to rub out previous circle
pcircle a,b,10
if y>250 then 
y=150-v
v=v-1
end if
'
color 1,1,1,8,2         ' draws black circle
pcircle x,y,10
if y>150 then
v=-v
end if
if Mouse(2)=2 then
stop
end if
if x<600 then
goto start
end if


