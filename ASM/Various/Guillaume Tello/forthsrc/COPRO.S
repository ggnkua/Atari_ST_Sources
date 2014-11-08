; Calcul r‚el avec coprocesseur MC68882

 text

   COPIE flint,y400
flint: fmove.d (a6)+,fp0
   fmove.l fp0,-(a6)
y400: rts

   COPIE intfl,y401
intfl: fmove.l (a6)+,fp0
   fmove.d fp0,-(a6)
y401: rts
   
   COPIE int,y402   
int: fintrz.d (a6),fp0
   fmove.d fp0,(a6) 
y402: rts

   COPIE sincos,y403
sincos:
   fsincos.d (a6),fp0:fp1
   fmove.d fp0,(a6)
   fmove.d fp1,-(a6)
y403: rts

   COPIE sin,y404
sin:
   fsin.d (a6),fp0
   fmove.d fp0,(a6)
y404: rts

   COPIE cos,y405
cos:
   fcos.d (a6),fp0
   fmove.d fp0,(a6)
y405: rts

   COPIE tan,y406
tan: 
   ftan.d (a6),fp0
   fmove.d fp0,(a6)
y406: rts

   COPIE atn,y407
atn:
   fatan.d (a6),fp0
   fmove.d fp0,(a6)
y407: rts

   COPIE carre,y408
carre:
   fmove.d (a6),fp0
   fmul.x fp0,fp0
   fmove.d fp0,(a6)
y408: rts

   COPIE expo,y409
expo: 
   fetox.d (a6),fp0
   fmove.d fp0,(a6)
y409: rts

   COPIE loga,y410
loga:
   flogn.d (a6),fp0
   fmove.d fp0,(a6)
y410: rts

   COPIE sqr,y411
sqr: 
   fsqrt.d (a6),fp0
   fmove.d fp0,(a6)
y411: rts

   COPIE fdiv,y412
fdiv: 
   fmove.d 8(a6),fp0
   fdiv.d  (a6)+,fp0
   fmove.d fp0,(a6)
y412: rts

   COPIE ffois,y413
ffois: 
   fmove.d (a6)+,fp0
   fmul.d  (a6) ,fp0
   fmove.d fp0  ,(a6)
y413: rts

   COPIE fplus,y414
fplus: 
   fmove.d (a6)+,fp0
   fadd.d  (a6) ,fp0
   fmove.d fp0  ,(a6)
y414: rts

   COPIE fmoins,y415
fmoins:
   fmove.d 8(a6),fp0
   fsub.d  (a6)+,fp0
   fmove.d fp0,(a6)
y415: rts

   COPIE inv,y416
inv: 
   fmovecr #50,fp0          ; 1
   fdiv.d (a6),fp0
   fmove.d fp0,(a6)
y416: rts

   COPIE round,y417
round:
   fint.d (a6),fp0
   fmove.d fp0,(a6)
y417: rts

   COPIE frac,y418
frac:
   fmove.d (a6),fp0
   fintrz.x fp0,fp1
   fsub.x fp1,fp0
   fmove.d fp0,(a6)
y418: rts

; a0 pointe sur la chaine : [+/-][xxxx][./,xxxx][e/E[+/-][xxxx]]
; en sortie d0/d1 le r‚el. erreur=1 si erreur...
; a1 conserve les signes (mantisse puis exposant)
; a2 pointe sur les donn‚es ( chiffres puis puissances de 10 )
; a3 sert … d‚caler l'exposant si il y a des chiffres aprŠs la virgule
; d0-d7,a0-a3 utilis‚s

subval: sub.l a1,a1
   move #1,a3
   cmp.b #'-',(a0)
   bne.s .lb0
   move #1,a1
   addq.l #1,a0
   bra.s .lb1
.lb0: cmp.b #'+',(a0)
   bne.s .lb1
   addq.l #1,a0
.lb1: moveq #0,d0
   moveq #0,d1
.lb2: move.b (a0),d7
   beq .fin
   cmp.b #".",d7
   beq.s .virg
   cmp.b #',',d7
   bne.s .lb20
.virg: sub.l a3,a3
   addq.l #1,a0
   bra.s .lb2
.lb20: cmp.b #"e",d7
   beq.s .exp
   cmp.b #'E',d7
   beq.s .exp
   cmp.w #1,a3
   beq.s .lb21
   subq #1,a3
.lb21: tst.l d0
   beq.s .lb3
   add.l #$100000,d0
   move.l d0,d2
   move.l d1,d3
   add.l #$200000,d2
   bsr subplus
.lb3: moveq #0,d7
   move.b (a0)+,d7
   sub.b #'0',d7
   beq.s .lb2
   cmp.b #10,d7
   bmi.s .lb31
   move #1,erreur
   rts
.lb31: lea chdata,a2
   add d7,d7
   move -2(a2,d7.w),d2
   swap d2
   clr d2
   moveq #0,d3
   bsr subplus
   bra.s .lb2
.exp: addq.l #1,a0
   cmp #1,a1
   bne.s .lb4
   moveq #31,d7
   bset d7,d0
.lb4: sub.l a1,a1
   moveq #0,d4
   cmp.b #'-',(a0)
   bne.s .lb5
   move #1,a1
   addq.l #1,a0
   bra.s .lb6
.lb5: cmp.b #'+',(a0)
   bne.s .lb6
   addq.l #1,a0
.lb6: move.b (a0)+,d7
   beq.s .lb7
   ext.w d7
   sub.w #'0',d7
   muls #10,d4
   add d7,d4
   bra.s .lb6
.fin: moveq #0,d4
   cmp #1,a1
   bne.s .lb71
   moveq #31,d7
   bset d7,d0
.lb7: cmp #1,a1
   bne.s .lb71
   neg d4
.lb71: cmp #1,a3
   beq.s .lb8
   add a3,d4
.lb8: lea posdata,a2
   tst d4
   bpl.s .lb81
   neg d4
   lea negdata,a2
.lb81: move d4,a3
.lb9: move a3,d4
   beq.s .sortie
   lsr d4
   bcc.s .lb10
   move d4,a3
   move.l (a2)+,d2
   move.l (a2)+,d3
   bsr submul
   bra.s .lb9
.lb10: addq.l #8,a2
   move d4,a3
   bra.s .lb9
.sortie: rts

; fmove.p renvoit 12 octets qui donnent 24 chiffres BCD
; Seee E00M MMMM MMMM MMMM MMMM
; S bit 3 = signe de la mantisse
;   bit 2 = signe de l'exposant
; Eeee exposant ( oh, la belle inversion )
; M,MMMM... mantisse

subaff: fmove.d (a6)+,fp0
   move.l #packbuf,a0
   moveq #32,d0
   fmove.p fp0,(a0)
   move.l #affbuf+1,a1
   btst #7,(a0)         ; signe
   beq.s .lb0
   moveq #'-',d0
.lb0: move.b d0,(a1)+
   addq.l #3,a0
   move.b (a0)+,d0      ; premier chiffre
   unpk d0,d0,#$3030
   move.b d0,(a1)+
   move.b #".",(a1)+
   moveq #7,d1
.lb1: move.b (a0)+,d0   ; les 16 chiffres de la mantisse en 8 fois 2
   unpk d0,d0,#$3030
   move.w d0,(a1)+
   dbf d1,.lb1
   move.b #"e",(a1)+
   moveq #"+",d2
   move.l #packbuf,a0
   move (a0)+,d0
   move (a0),d1
   btst #14,d0
   beq.s .lb2
   moveq #"-",d2
.lb2: move.b d2,(a1)+
   and.w #$F000,d1
   and.w #$0FFF,d0
   or d0,d1
   lsr #8,d1
   unpk d1,d1,#$3030
   move d1,(a1)+
   unpk d0,d0,#$3030
   move d0,(a1)+
   clr.b (a1)
   rts

copro: dc.l 0,0,0,0

subplus: movem.l d0-d3,copro
   fmove.d copro,fp0
   fadd.d  copro+8 ,fp0
   fmove.d fp0,copro
   movem.l copro,d0-d1
   rts

submul: movem.l d0-d3,copro
   fmove.d copro,fp0
   fmul.d  copro+8,fp0
   fmove.d fp0,copro
   movem.l copro,d0-d1
   rts
   
subdiv: movem.l d0-d3,copro
   fmove.d copro,fp0
   fdiv.d  copro+8,fp0
   fmove.d fp0,copro
   movem.l copro,d0-d1
   rts

 end
