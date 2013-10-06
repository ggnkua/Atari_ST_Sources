 opt o+,p+
 
deb
 
xx1	dc.w 0
x1	dc.w 0
yy1	dc.w 0
y1	dc.w 0
xx2	dc.w 0
x2	dc.w 0
yy2	dc.w 0
y2	dc.w 0
couleur	dc.w 0
‚cran	dc.l 0 

trace_ligne
 movem.l d0-a6,-(sp)
 
 move.l xx2(pc),d0
 move.l xx1(pc),d1
 sub.l d1,d0 		d0 = Largeur
 bpl.s .largeur_positive
 neg.l d0		d0 = ABS(Largeur)
.largeur_positive
 addq.l #1,d0		d0 = d0+1
   
 move.l yy2(pc),d1
 move.l yy1(pc),d2
 sub.l d2,d1		d1 = Hauteur
 bpl.s .hauteur_positive
 neg.l d1		d1 = ABS(hauteur)
.hauteur_positive
 addq.l #1,d1		d1 = d1+1
 
*** d0=ABS(largeur) /DX
*** d1=ABS(hauteur) /DY
*** d5=ix
*** d6=iy
*** d7=nombre de points

 cmp.l d1,d0
 bge.s largeur_max
hauteur_max
 move d1,d7		Nombre de points=hauteur
 subq #1,d7

 move.l xx1(pc),d0
 cmp.l xx2(pc),d0
 ble.s .ix_positif
.ix_n‚gatif
 move d0,d5
 neg d5
 muls.l #65536,d6
 divs.l d1,d5		IX=-DX/DY
 bra.s .v‚rifie_iy
.ix_positif
 move d0,d5
 swap d5
 divu.l d1,d5		IX=DX/DY
 bra.s .v‚rifie_iy
 nop
.v‚rifie_iy
 move.l yy1(pc),d1
 cmp.l yy2(pc),d1
 ble.s .iy_positif
.iy_n‚gatif
 move.l #-1*65536,d6	IY=1
 bra.s ex‚cute_trace
.iy_positif
 move.l #1*65536,d6	IY=1
 bra.s ex‚cute_trace
 

largeur_max
 move d0,d7		Nombre de points=largeur
 subq #1,d7

 move.l xx1(pc),d0
 cmp.l xx2(pc),d0
 ble.s .ix_positif
.ix_n‚gatif
 move.l #-1*65536,d5	IX=1
 bra.s .v‚rifie_iy
.ix_positif 
 move.l #1*65536,d5	IX=1
 bra.s .v‚rifie_iy
 nop
.v‚rifie_iy 

 move.l yy1(pc),d1
 cmp.l yy2(pc),d1
 ble.s .iy_positif
.iy_n‚gatif
 move d1,d6
 neg d6
 muls.l #65536,d6
 divs.l d0,d6		IY=-DY/DX
 bra.s ex‚cute_trace
.iy_positif
 move d1,d6
 swap d6
 divu.l d0,d6		IY=DY/DX
 bra.s ex‚cute_trace

 nop
 
ex‚cute_trace 
.loop 
 move.l ‚cran(pc),a0
 add d0,a0		X x2
 add d0,a0
 move d1,d2		Y x640
 mulu #640,d2
 add.l d2,a0
 move couleur(pc),(a0)
 swap d0
 swap d1
 add.l d5,d0
 add.l d6,d1
 swap d0
 swap d1 
 dbra d7,.loop
 movem.l (sp)+,d0-a6
 rts

fin
 