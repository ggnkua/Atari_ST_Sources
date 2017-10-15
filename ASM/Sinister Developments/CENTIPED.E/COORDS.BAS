defint startx,starty,x,y,space
dim coords%(6000)

def	fncalcx(c)
local c,temp
temp=(310+(sin(c/20)*(320-32)))/2
if temp MOD 2 = 1 then decr temp
fncalcx=temp
end def
def	fncalcy(c)
local c
fncalcy=100+(sin(c/50)*67)
end def

cptr=varptr(coords%(1))
init_count=400
count=init_count
pointer=1

startx=fncalcx(count)
starty=fncalcy(count)
linef startx,starty,startx,starty

coords%(pointer)=startx
incr pointer
coords%(pointer)=starty
incr pointer

biddle:
incr count
x=fncalcx(count)
y=fncalcy(count)
if y>183 or x>303 then goto oob
if y<33 or x<0 then goto oob
if x=startx and y=starty then goto bye
linef x,y,x,y
coords%(pointer)=x
incr pointer
coords%(pointer)=y
incr pointer
goto biddle
oob:
print "Sorry, coords out of bounds!!!!"
end
bye:
coords%(pointer)=-1
space=(((count+1)-init_count)*4)+2
print "space used" space "bytes"
bsave "d:\centiped.e\coords",cptr,space

