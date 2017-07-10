* a ne pas detacher de la vbl
calc_hard
 move.l buf1,a1
 move xecran,d0
 and #3,d0
 neg d0
 addq #3,d0
 add d0,d0
 add d0,d0
 lea adr_buf,a0
 add d0,a0
 move.l (a0),buf1
 lea -160*7(a1),a1
 move.l a1,d0
 and.l #$fe,d0
 lsl.l #4,d0
 lea hard,a0
 add.l d0,a0
 add 24(a0),a1
 lea jsr_hard,a2
h set 0
 rept 6
 move.l (a0)+,h+2(a2)
h set h+6
 endr
 move.l a1,d0
 lea $ffff8201.w,a1
 lsr.l #8,d0
 movep d0,(a1)
 rts

* 0 normal
* 1 gauche
* 2 droit
* 3 full
* 4 courte
* 5 normal_158
* 6 ligne_184
nop =$4e71
normal
 dcb.w 128-6-5+2,nop
 rts

gauche
 move.b d1,(a0)
 nop
 move.b d0,(a0)
 dcb.w 89+2+2,nop
 nop
 dcb.w 12+2+2,nop
 nop
 dcb.w 12-6-5+2,nop
 rts

droite
 dcb.w 89+5,nop
 move.b d0,(a1)
 nop
 move.b d1,(a1)
 dcb.w 12,nop
 move.b d1,(a0)
 nop
 move.b d0,(a0)
 dcb.w 12-6-5+2,nop
 rts

full
 move.b  d1,(a0)   
 nop
 move.b  d0,(a0)   
 dcb.w 89,nop
 move.b  d0,(a1)   
 move.b  d1,(a1)  
 dcb.w 13,nop
 move.b  d1,(a0)   
 nop 
 move.b  d0,(a0)  
 dcb.w 12-6-5+2,nop
 rts

courte            ; 54
 dcb.w 41,nop
 move.b d1,(a0)   ; haute 2
 dcb.w 42,nop
 move.b d0,(a0)   ; basse 0
 dcb.w 41-6-5+2,nop
 rts

normal_158
 dcb.w 33,nop
 move.b  d0,(a1)   ; 60 hz
 dcb.w 68,nop
 move.b  d1,(a1)   ; 50 hz
 dcb.w 23-6-5+2,nop
 rts

ligne_184
 move.b  d1,(a0)
 nop
 move.b  d0,(a0)
 dcb.w 33-5,nop
 move.b  d0,(a1)   ; 60 hz
 dcb.w 68,nop
 move.b  d1,(a1)   ; 50 hz
 dcb.w 23-6-5+2,nop
 rts

refait_hard
 lea hard,a0
 moveq #128-1,d2
 moveq #5,d1
.loop
 move.l (a0),d0
 add d0,d0  
 add d0,d0  
 move.l routines(pc,d0.w),(a0)+
 dbra d1,.loop
 addq.l #8,a0
 moveq #5,d1
 dbra d2,.loop
 rts 
routines dc.l normal,gauche,droite,full,courte,normal_158,ligne_184

 data
table_mul_24
h set 0
 rept 21
 dc.w h
h set h+24
 endr

table_230 
h set 0
 rept 300
 dc.l h
h set h+230
 endr
