REM  SMARTIES.BAS, Random colours
'                 ST LOW or Falcon VGA 640x480, 256 colours
Print "Press right mouse button to STOP"
 for p=1 to 100
locate 1,10
print""
next p
FOR n=1 TO 1000
if mouse(2)=2 then
stop
end if
x=RND(1)*600+20
y=RND(1)*400+20
r=RND(1)*30
c=RND(1)*15
'
COLOR 1,c,2,8,2
PCIRCLE x,y,r
NEXT n
