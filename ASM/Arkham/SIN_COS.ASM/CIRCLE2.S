* utilisation des fonctions
* sinus et cosinus
*******************

 dc.w $a00a
 clr -(sp)
 pea $78000
 pea $78000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp
 pea palette
 move.w #6,-(sp)
 trap #14
 addq.l #6,sp
 pea letsgo
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

* programme principal

letsgo
 moveq.w #1,d0
 jsr music
 move.l $70.w,rvbl+2
 move.l #vbl,$70.w
 clr.l $fffa06

start 
 bsr cls
 move.w #90,d3 * rayon x
 move.w #90,d4 * rayon y
 move.w #1,d5 * x1
 move.w #1,d6 * x2
start2
 bsr courbe
 
key 
 move.b $fffffc02.w,d0
 cmpi.b #$b9,d0
 beq end
 cmpi.b #$3b,d0
 beq dr1
 cmpi.b #$3c,d0
 beq ir1
 cmpi.b #$3d,d0
 beq dr2
 cmpi.b #$3e,d0
 beq ir2                       
 cmpi.b #$3f,d0
 beq dx1
 cmpi.b #$40,d0
 beq ix1
 cmpi.b #$41,d0
 beq dx2
 cmpi.b #$42,d0
 beq ix2
 cmpi.b #$43,d0
 beq start
 bra.s key

end 
 move.l #$ff1eff64,$fffa06
rvbl move.l #0,$70.w
 clr.l d0
 jsr music
 rts
                         
vbl
 movem.l d0-a6,-(sp)
 jsr music+8
 movem.l (sp)+,d0-a6
 rte

ix1
 addq.w #1,d5
 bsr cls
 bra start2

dx1
 subq.w #1,d5
 bsr cls
 bra start2

ix2
 addq.w #1,d6
 bsr cls
 bra start2

dx2
 subq.w #1,d6
 bsr cls
 bra start2
               
dr1
 tst.w d3
 beq ret1
 subq.w #5,d3
 bsr cls
ret1
 bra start2

ir1
 cmpi.w #160,d3
 beq ret2
 addq.w #5,d3
 bsr cls
ret2
 bra start2

dr2
 tst.w d4
 beq ret3
 subq.w #5,d4
 bsr cls
ret3 bra start2

ir2
 cmpi.w #100,d4
 beq ret4
 addq.w #5,d4
 bsr cls
ret4  bra start2

cls
 lea.l $78000,a0
 move.w #7999,d0
cls2 clr.l (a0)+
 dbf d0,cls2
 rts

courbe
 lea.l cosinus,a5
 lea.l sinus,a6
 clr.w d0
trace
 move.w d3,d1		* rayon x
 move.w d0,d7 
 mulu.w d5,d7		* x1
test
 cmpi.w #720,d7
 blo ok
 subi.w #720,d7
 bra.s test
ok
 muls.w (a5,d7.w),d1
 divs.w #16384,d1
 addi.w #160,d1
 move.w d4,d2		* rayon y
 move.w d0,d7 
 mulu.w d6,d7		* x2 
test2
 cmpi.w #720,d7
 blo ok2
 subi.w #720,d7
 bra.s test2
ok2
 muls.w (a6,d7.w),d2
 divs.w #16384,d2
 addi.w #100,d2

 movem.l d0-a6,-(sp)
 clr.l d0
 move.w d1,d0
 clr.l d1          
 move.w d2,d1
 bsr convert
 movem.l (sp)+,d0-a6 

 addq.w #2,d0
 cmpi.w #718,d0
 bne trace
 rts

convert * entree:x=d0,y=d1

 lea.l $78000,a0
 mulu.w #$a0,d1
 adda.w d1,a0

 move.w d0,d1
 lsr.w d0
 adda.w d0,a0

 divu.w #8,d0
 lsl.w #4,d0
 sub.w d0,d1

 move.l a0,d3
 and.l #$ffffffff-7,d3
 move.l d3,a0

 move.w #32768,d0
 lsr.w d1,d0
 or.w d0,(a0)
 rts
 

palette even
 dc.w 0,$777,2,$777,4,5,6,7,8,9,10,11,12,13,14,$777
cosinus even
 incbin cosinus.dat
sinus even
 incbin sinus.dat
music even
 incbin music.mus
 

 
 



