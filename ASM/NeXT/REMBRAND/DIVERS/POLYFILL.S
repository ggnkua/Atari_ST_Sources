contrl=4
ptsin=12
fg_bp1=24
fg_bp2=26
fg_bp3=28
fg_bp4=30
wrt_mod=36

y1=40

patptr=46
patmsk=50
multifill=52
clip=54
xmn_clip=56
ymn_clip=58
xmx_clip=60
ymx_clip=62

init=$a000
polygon=$a006

 dc.w init
 
 move #1,fg_bp1(a0)
 clr fg_bp2(a0)
 clr fg_bp3(a0)
 clr fg_bp4(a0)

 move #2,wrt_mod(a0)
 
 move.l #fill,patptr(a0)
 
 move #4,patmsk(a0)
 clr multifill(a0)
 clr clip(a0)
 
 move.l contrl(a0),a6
 addq.l #2,a6
 move #8,(a6)
 
 move.l ptsin(a0),a6
 move.l #tab,a5
 move #2*9,d3
loop
 move (a5)+,(a6)+
 dbra d3,loop
 
 move #30,d3
loop1
 move d3,y1(a0)
 move.l a0,-(sp)
 dc polygon
 move.l (sp)+,a0
 addq #1,d3
 cmp #181,d3
 bne loop1

 move #7,-(sp)
 trap #1
 addq #2,sp
  
 clr -(sp)
 trap #1
 
fill
 dc -1
 dc -1
 dc -1
 dc -1
 dc -1
 dc -1
 dc %1100110011001100
 dc %0110011001100110
 dc %0011001100110011
 dc %1001100110011001
 
tab
 dc 80,30
 dc 40,150
 dc 320,60
 dc 400,180
 dc 20,80
 dc 500,120
 dc 510,60
 dc 210,170

 dc 80,30
 dc 80,30
 dc 80,30
 
 