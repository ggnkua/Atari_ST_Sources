;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; essai de routine de ligne personnelle ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 lea.l pile,sp

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 lea.l $1f0300,a0
 move.w #7999,d0
eff_ecr clr.l (a0)+
 dbf d0,eff_ecr

; fait tableau de l'acceleration ;

 lea.l accelere,a0
 move.w #5,d0
 moveq.w #1,d1
make_table
 rept 40
 move.w d1,(a0)+ 
 endr
 addq.w #1,d1
 dbf d0,make_table

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$555,$ffff8244.w
 move.w #$333,$ffff8246.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

; efface les anciennes etoiles

 movea.l adr_old,a0
 movea.l ecr2,a1
 move.w #249,d0
 moveq.l #0,d2
eff_star
 move.w (a0)+,d1
 move.l d2,(a1,d1.w)
 dbf d0,eff_star

; swappe buffer d'effacement

 movea.l adr_old,a0
 move.l adr_old2,adr_old
 move.l a0,adr_old2

; affiche les etoiles suivant z

 lea.l star,a0
 movea.l adr_old2,a2
 move.w #249,d0
aff_star
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0),d3

 muls.w d3,d1
 asr.w #7,d1
 add.w #160,d1

 muls.w d3,d2
 asr.w #7,d2
 add.w #100,d2

 move.w d3,d7
 lsl.w d7
 lea.l accelere,a3
 add.w d7,a3

 add.w (a3),d3
 cmpi.w #319,d1
 blo no_bleme 
 move.w #18,d3
no_bleme
 tst.w d1
 bpl no_bleme2
 move.w #18,d3 
no_bleme2
 cmpi.w #199,d2
 blo no_bleme3 
 move.w #18,d3
no_bleme3
 tst.w d2
 bpl no_bleme4
 move.w #18,d2 
no_bleme4

 cmpi.w #200,d3
 blo no_z
 move.w #28,d3
no_z
 move.w d3,(a0)+

 mulu.w #160,d2
 move.w d1,d4
 lsr.w d1
 andi.w #$ffff-7,d1
 add.w d1,d2
 lsl.w d1
 sub.w d1,d4
 move.w #32768,d1
 lsr.w d4,d1

 move.w d2,(a2)+
 movea.l ecr2,a1
 add.w d2,a1

 cmpi.w #36,d3
 bhi no_aff1
 or.w d1,(a1)
 or.w d1,2(a1)
 bra.s no_test
no_aff1
 cmpi.w #72,d3
 bhi no_aff2
 or.w d1,2(a1)
 bra.s no_test
no_aff2
 or.w d1,(a1)

no_test 
 

 dbf d0,aff_star

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w

 move.l ecr2,a0
 move.l ecr1,ecr2
 move.l a0,ecr1

 cmpi.b #$62,$fffffc02.w
 bne no_help
 move.w #$221,$ffff8240.w
no_help
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

ecr1 even
 dc.l $1f0300
ecr2 even
 dc.l $1f8000

adr_old even
 dc.l old_data
adr_old2 even
 dc.l old_data2

accelere even	; tableau de l'acceleration des etoiles
 ds.w 200	; pour 200 z differents ! 

old_data even
 ds.w 500
old_data2 even
 ds.w 500

 ds.l 1500
pile ds.l 500

star even
 incbin star.dat