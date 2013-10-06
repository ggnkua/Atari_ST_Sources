col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256

mode=coltc+l40+tv+pal

 move #mode,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 nop
 nop
 nop
 clr -(sp)
 trap #1
  
 