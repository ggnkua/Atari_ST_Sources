
              move.l   4(sp),a0      
              lea   stack,sp      
              move.l   $c(a0),d0      
              add.l   $14(sp),d0      
              add.l   $1c(sp),d0      
              move.l   d0,-(sp)      
              move.l   a0,-(sp)      
              move.l   #$4a0000,-(sp)      
              trap   #1         
              adda   #00000012,sp 
              ;-------- load ---------
              clr.w -(sp)
              pea f_nam
              move.w #$3d,-(sp)
              trap #1
              move.w d0,f_hand
              pea in_fo
              move.l #34,-(sp)
              move.w d0,-(sp)
              move.w #$3f,-(sp)
              trap #1
              pea buffer
              move.l #32000,-(sp)
              move.w f_hand,-(sp)
              move.w #$3f,-(sp)
              trap #1
              move.w f_hand,-(sp)
              move.w #$3e,-(sp)
              trap #1
              adda.l #36,sp      
              ;-------- init ---------
              move.w #0,-(sp)
              move.l #-1,-(sp)
              move.l #-1,-(sp)
              move.w #5,-(sp)
              trap #14
              adda.l #12,sp
              clr.b rad
              clr.b byte
              clr.b plan
              pea color
              move.w #6,-(sp)
              trap #14
              adda.l #6,sp
              move.l #$f8000,p_1
              move.l #$f8002,p_2
              move.l #$f8004,p_3
              move.l #$f8006,p_4
              ;-------- huvudloop ----
              ; reg a0 haller reda pa vart i bufferten
              ; vi ar
              ; reg d0 haller reda pa kommandobyten
              lea buffer,a0
              lea mellan,a1            
igen          clr.w d0
              move.b (a0)+,d0
              bmi minus
              add.b d0,byte
              addi.b #1,byte 
loop_one      move.b (a0)+,(a1)+
              dbra d0,loop_one                  
              jmp vidare
minus         neg.b d0
              add.b d0,byte
              addi.b #1,byte
              move.b (a0)+,d1
loop_two      move.b d1,(a1)+
              dbra d0,loop_two
vidare        cmpi.b #40,byte
              bne igen
              clr.b byte
              lea mellan,a1      
              jsr move_mellan
              lea mellan,a1
              addi.b #1,plan
              cmpi.b #4,plan
              bne igen
              clr.b plan
              addi.b #1,rad
              cmpi.b #200,rad
              bne igen 
eend          jmp eend
              ; ------ enda subrutinen ---------
move_mellan   move.b plan,d5
              cmpi.b #0,d5
              bne aaa
              move.l p_1,a5
              lea p_1,a4
              jmp olja
aaa           cmpi.b #1,d5
              bne bbb
              move.l p_2,a5
              lea p_2,a4
              jmp olja 
bbb           cmpi.b #2,d5
              bne ccc
              move.l p_3,a5
              lea p_3,a4
              jmp olja
ccc           move.l p_4,a5
              lea p_4,a4
olja          move.w #19,d7
loop_three    move.w (a1)+,(a5)
              add.l #8,a5
              dbra d7,loop_three
              move.l a5,(a4)
              rts                   
              SECTION DATA
f_nam         dc.b "test.pc1",0
              SECTION BSS
f_hand        ds.b 2
buffer        ds.b 32000
mellan        ds.b 80
rad           ds.b 1
              EVEN
byte          ds.b 1
plan          ds.b 1
              EVEN
picture       ds.b 32000
in_fo         ds.b 2
color         ds.b 32
p_1           ds.b 4
p_2           ds.b 4
p_3           ds.b 4
p_4           ds.b 4       
              ds.b $100                
stack:

