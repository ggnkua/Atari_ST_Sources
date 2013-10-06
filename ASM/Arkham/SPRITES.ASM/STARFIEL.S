;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STARFIELD EN BOULE (4 PLANS PARALLAXE) ;
; BY TCHOOM/ARKHAM (C) 1993		 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l pile,sp
 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 lea.l 12(sp),sp
 bsr init_table
 bsr precalcul
 lea.l $1f0300,a0
 move.w #15999,d0
clr_all clr.l (a0)+
 dbf d0,clr_all
 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 clr.w $ffff8240.w
 move.w #$023,$ffff8242.w
 move.w #$045,$ffff8244.w
 move.w #$467,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface ancien champ d'etoile

 move.l adr_clr2,a0
 move.w #20,d0
 moveq.w #0,d1
clr_star
 movem.l (a0)+,a1-a4
n set 0
 rept 13
 move.l d1,n(a1)
 move.l d1,n+8(a1)
n set n+$a0
 endr
n set 0
 rept 9
 move.l d1,n(a2)
 move.l d1,n+8(a2)
n set n+$a0
 endr
n set 0
 rept 6
 move.l d1,n(a3)
 move.l d1,n+8(a3)
n set n+$a0
 endr
n set 0
 rept 3
 move.l d1,n(a4)
 move.l d1,n+8(a4)
n set n+$a0
 endr
 dbf d0,clr_star

; affiche le champ d'etoiles

 lea.l champ,a0
 movea.l adr_clr2,a4
 move.w #20,d7
aff_boule
 move.w (a0),d0			Premier plan
 addq.w #4,(a0)
 bsr clip
 move.w (a0)+,d1
 add.w d0,d0
 add.w d0,d0
 add.w d1,d1
 movea.l ecr2,a2  
 lea.l table_y,a1
 add.w (a1,d1.w),a2
 lea.l table_x,a1
 lea.l $90000,a3
 add.w d0,a1
 add.w (a1)+,a2
 add.w (a1),a3 

 move.l a2,(a4)+
n set 0
 rept 13
 move.l (a3)+,d0
 or.l d0,n(a2)
 move.l (a3)+,d0
 or.l d0,n+8(a2)
n set n+$a0
 endr

 move.w (a0),d0		Deuxieme plan
 addq.w #3,(a0)
 bsr clip
 move.w (a0)+,d1
 add.w d0,d0
 add.w d0,d0
 add.w d1,d1
 movea.l ecr2,a2  
 lea.l table_y,a1
 add.w (a1,d1.w),a2
 lea.l table_x,a1
 lea.l $90000,a3
 add.w d0,a1
 add.w (a1)+,a2
 add.w (a1),a3 
 add.w #104,a3

 move.l a2,(a4)+
n set 0
 rept 9
 move.l (a3)+,d0
 or.l d0,n(a2)
 move.l (a3)+,d0
 or.l d0,n+8(a2)
n set n+$a0
 endr

 move.w (a0),d0		Troisieme plan
 addq.w #2,(a0)
 bsr clip
 move.w (a0)+,d1
 add.w d0,d0
 add.w d0,d0
 add.w d1,d1
 movea.l ecr2,a2  
 lea.l table_y,a1
 add.w (a1,d1.w),a2
 lea.l table_x,a1
 lea.l $90000,a3
 add.w d0,a1
 add.w (a1)+,a2
 add.w (a1),a3 
 add.w #176,a3

 move.l a2,(a4)+
n set 0
 rept 6
 move.l (a3)+,d0
 or.l d0,n(a2)
 move.l (a3)+,d0
 or.l d0,n+8(a2)
n set n+$a0
 endr

 move.w (a0),d0		Quatrieme plan
 addq.w #1,(a0)
 bsr clip
 move.w (a0)+,d1
 add.w d0,d0
 add.w d0,d0
 add.w d1,d1
 movea.l ecr2,a2  
 lea.l table_y,a1
 add.w (a1,d1.w),a2
 lea.l table_x,a1
 lea.l $90000,a3
 add.w d0,a1
 add.w (a1)+,a2
 add.w (a1),a3 
 add.w #224,a3

 move.l a2,(a4)+
n set 0
 rept 3
 move.l (a3)+,d0
 or.l d0,n(a2)
 move.l (a3)+,d0
 or.l d0,n+8(a2)
n set n+$a0
 endr

 dbf d7,aff_boule

; swappe ecrans et buffer d'effacement

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr1,d0
 move.l ecr2,ecr1
 move.l d0,ecr2
 move.l adr_clr1,d0
 move.l adr_clr2,adr_clr1
 move.l d0,adr_clr2

 cmpi.b #$36,$fffffc02.w
 bne.s no_shift
 move.w #$520,$ffff8240.w
no_shift
 bra prog

clip
 cmp.w #319,(a0)
 bhi.s clip2
 addq.l #2,a0
 rts
clip2
 clr.w (a0)+
 rts

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 rts

; routines d'initialisation

init_table
 lea.l table_x,a0
 move.w #19,d0
 moveq.w #0,d1 
fill_table_x
 move.w #0,d2
 moveq.w #15,d3
fill_table_x2
 move.w d1,(a0)+
 move.w d2,(a0)+
 add.w #248,d2
 dbf d3,fill_table_x2
 addq.w #8,d1
 dbf d0,fill_table_x
 
 lea.l table_y,a0
 moveq.w #0,d0
 move.w #199,d1
fill_table_y
 move.w d0,(a0)+
 addi.w #$a0,d0
 dbf d1,fill_table_y
 rts

; precalcul des 16 positions des sprites ;

precalcul
 lea.l $90000,a1
 moveq.w #15,d0
precalcul2
 lea.l boule,a0
 move.w #30,d1
precalcul3
 move.l (a0),(a1)+
 move.l 4(a0),(a1)+
 roxr.w (a0)
 roxr.w 4(a0)
 roxr.w 2(a0)
 roxr.w 6(a0)
 addq.l #8,a0
 dbf d1,precalcul3
 dbf d0,precalcul2
 rts

; section data

adr_clr1	dc.l clr_buf
adr_clr2	dc.l clr_buf2
ecr1		dc.l $1f0300
ecr2		dc.l $1f8000
table_x		ds.l 320
table_y		ds.w 200
clr_buf		dcb.l 300,$1f8000
clr_buf2	dcb.l 300,$1f8000
boule		incbin boule.dat
champ		incbin champ.dat
		ds.l 5000
pile		ds.l 50