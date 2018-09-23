 lea chaine,a0
 move.l #87654321,d0
 bsr inscrit_chaine
 nop
 nop
 nop
  
inscrit_chaine
 sf d6
 move.l #1000000000,d7
.position_suivante
 move.l d0,d1
 divu.l d7,d1	Divise par la puissance de 10
 beq .inscrit_z‚ro
 st d6
 move #'0',d2
 add d1,d2
 move.b d2,(a0)+	Inscrit le caractŠre
 mulu.l d7,d1
 sub.l d1,d0
 divu.l #10,d7
 bne .position_suivante
 bra .fin_chaine
 
.inscrit_z‚ro
 tst.b d6
 beq .saute_premier_z‚ro
 move.b #'0',(a0)+
.saute_premier_z‚ro
 divu.l #10,d7
 bne .position_suivante

.fin_chaine
 clr.b (a0)+ 
 rts

chaine ds.l 50
