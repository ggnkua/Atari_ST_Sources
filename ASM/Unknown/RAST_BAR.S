KEYBOARD   equ $fffc02
IMRB       equ $fffa15
BACKGR     equ $ff8240

           move.l #raster,-(sp)
           move.w #38,-(sp)
           trap #14
           addq.l #6,sp
           clr.w -(sp)
           trap #1

raster     move.w #$2700,SR

           move.b KEYBOARD,D3
  
loop       cmpi.b #0,$ff8209
           move.b $ff8203,D0
           move.b $ff8207,D1
           cmp.b D0,D1
           bne loop
  
           clr.l D0
           lea rstable,A0
  
draw       move.w 0(A0,D0.w),D1
           move.w D1,BACKGR
  
           move.w 2(A0,D0.w),D1
wait       dbf D1,wait
 
           addq.l #4,D0
  
           cmp.l #132,D0
           bne draw
  
           move.b KEYBOARD,D2
           cmp.b D2,D3
           beq loop

           move.w #$777,BACKGR
           move.w #$2300,sr
           rts

  
rstable    dc.w $000,4032
  
 
           dc.w $000,34
           dc.w $100,34
           dc.w $100,34
           dc.w $100,34
           dc.w $200,34
           dc.w $200,37
           dc.w $200,34
           dc.w $300,34
           dc.w $300,34
           dc.w $400,34
           dc.w $400,37
           dc.w $500,34
           dc.w $500,34
           dc.w $600,34
           dc.w $600,34
           dc.w $700,37
           dc.w $700,34
           dc.w $600,34
           dc.w $600,34
           dc.w $500,34
           dc.w $500,37
           dc.w $400,34
           dc.w $400,34
           dc.w $300,34
           dc.w $300,34
           dc.w $200,37
           dc.w $200,34
           dc.w $200,34
           dc.w $100,34
           dc.w $100,34
           dc.w $100,37
           dc.w $000,34
  
           end
?