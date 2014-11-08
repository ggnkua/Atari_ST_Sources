; Calcul r‚el sans coprocesseur

	text


   SAUT
round: moveq #0,d4
   moveq #0,d5
   move.l (a6)+,d0
   smi d7
   move.l (a6),d1
   swap d0
   move d0,d2
   and #$f,d0
   bset #4,d0
   swap d0
   moveq #0,d6
   move d2,d6
   and #$fff0,d6
   bclr #15,d2
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   moveq #0,d0
   move.l d0,(a6)
   cmp #-1,d2
   bne.s .zero
   move.l #$3ff00000,-(a6)
   tst.b d7
   beq.s .glup
   bchg #7,(a6)
.glup: rts
.zero: move.l d0,-(a6)
   rts
.lb0: cmp #52,d2
   bmi.s .lb1
   subq.l #4,a6
   rts
.lb1: moveq #-1,d7
   cmp #20,d2
   bpl.s .lb2
   moveq #0,d1
   sub #20,d2
   neg d2
   move d2,d3
   subq #1,d3
   lsl.l d2,d7
   btst d3,d0
   beq.s .lb10
   bset d3,d4
.lb10: and.l d7,d0
   bra.s .fin
.lb2: sub #52,d2
   neg d2
   lsl.l d2,d7
   move d2,d3
   subq #1,d3
   btst d3,d1
   beq.s .lb3
   bset d3,d5
.lb3: and.l d7,d1
.fin: lsl.l d5
   roxl.l d4
   add.l d5,d1
   addx.l d4,d0
   btst #21,d0
   beq.s .lb4
   lsr.l d0
   roxr.l d1
   add #$10,d6
.lb4: bclr #20,d0
   swap d6
   or.l d6,d0
   move.l d1,(a6)
   move.l d0,-(a6)
   rts


; d0/d1 un r‚el
; d2/d3 l'autre
; en sortie d0/d1 leur somme
; d0-d7 modifi‚s
; a0-a7 intacts

subplus: moveq #31,d7         ; pour acc‚der au bit de signe
   moveq #20,d6               ; pour acc‚der au bit implicite
   bclr d7,d0
   bne .n1                    ; si le premier est n‚gatif
   bclr #31,d2
   bne .p1n2                  ; 2 n‚gatif et 1 positif
.p1p2:  move.l d0,d4          ; ici les deux sont positifs
   lsr.l d6,d4                ; exposant de 1
   move.l d2,d5
   lsr.l d6,d5                ; exposant de 2
   sub.w d5,d4                ; nbr de d‚calages
   bpl.s .lb0                 ; 1 > 2
   exg.l d0,d2                ; sinon on ‚change
   exg.l d1,d3
   neg d4
.lb0: move.l d0,d5            ; conserve l'exposant du plus grand
   cmp #53,d4
   bpl .endpos                ; trop de d‚calages
   and.l #$fffff,d0           ; on ote les exposants
   and.l #$fffff,d2
   bset d6,d0                 ; on ajoute le bit implicite
   bset d6,d2
   cmp #32,d4
   bpl.s .lb1
   move.l d2,d6               ; moins de 32 d‚calages
   lsr.l d4,d2
   lsr.l d4,d3
   sub #32,d4
   neg d4
   lsl.l d4,d6
   or.l d6,d3
   bra.s .lb2
.lb1: move.l d2,d3            ; plus de 32 d‚calages, d3 inutile
   moveq #0,d2
   sub #32,d4
   lsr.l d4,d3
.lb2: add.l d3,d1             ; addition
   addx.l d2,d0
   moveq #21,d6
   btst d6,d0                 ; une retenue?
   beq.s .lb4
   add.l #$100000,d5          ; si oui on augmente l'exposant
   lsr.l d0                   ; et on d‚cale … droite
   roxr.l d1
.lb4: moveq #20,d6            ; sinon on enlŠve le bit implicite
   bclr d6,d0
   and.l #$fff00000,d5        ; on garde l'exposant seul
   or.l d5,d0                 ; qu'on ajoute … la mantisse
.endpos: rts
.n1: bclr d7,d2
   beq.s .n1p2
   bsr .p1p2                  ; meme chose si deux n‚gatifs
   bset d7,d0                 ; mais signe -
   rts
.n1p2: bset d7,d7
.p1n2: move.l d0,d4           ; l'un positif l'autre n‚gatif
   lsr.l d6,d4                ; exposant de 1
   move.l d2,d5
   lsr.l d6,d5                ; exposant de 2
   sub.w d5,d4                ; nbr de d‚calages
   bpl.s .lb5                 ; 1 > 2
   exg.l d0,d2                ; sinon on ‚change
   exg.l d1,d3
   neg d4
   bchg d7,d7
.lb5: move.l d0,d5            ; conserve l'exposant du plus grand
   cmp #53,d4
   bpl .lb12                  ; trop de d‚calages
   and.l #$fffff,d0
   and.l #$fffff,d2
   bset d6,d0
   bset d6,d2
   cmp #32,d4
   bpl.s .lb6
   move.l d2,d6
   lsr.l d4,d2
   lsr.l d4,d3
   sub #32,d4
   neg d4
   lsl.l d4,d6
   or.l d6,d3
   bra.s .lb7
.lb6: move.l d2,d3
   moveq #0,d2
   sub #32,d4
   lsr.l d4,d3
.lb7: sub.l d3,d1
   subx.l d2,d0
   bne.s .lb8
   tst.l d1
   bne.s .lb8
   rts                               ; c'est z‚ro !
.lb8: bpl.s .lb9
   neg.l d1                          ; si c'est n‚gatif, le plus grand n'‚tait
   negx.l d0                         ; pas d0/d1, on oppose
   bchg d7,d7                        ; modifie le signe du r‚sultat
.lb9: moveq #20,d6
   lsr.l d6,d5                       ; ramŠne l'exposant au bit0
   bra.s .lb11
.lb10: lsl.l d1                      ; d‚calage … gauche
   roxl.l d0
   subq.w #1,d5                      ; ajuste l'exposant
.lb11: btst d6,d0                    ; tant que le bit20 n'est pas mis
   beq.s .lb10                       ; on remonte d‚caler … gauche
   bclr d6,d0                        ; sinon on ote le bit implicite
   lsl.l d6,d5                       ; on recale l'exposant au bit20
   or.l d5,d0                        ; qu'on ajoute … d0
.lb12: tst.l d7
   bpl.s .lb13
   bset d7,d0                        ; r‚sultat n‚gatif si bit31 de d7 = 1
.lb13: rts

   SAUT
frac: move.l (a6)+,d0
   smi d7
   bclr #31,d0
   move.l (a6),d1
   move.l d0,d2
   swap d2
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   subq.l #4,a6
   rts
.lb0: cmp #52,d2
   bmi.s .lb1
.zero: moveq #0,d0
   move.l d0,(a6)
   move.l d0,-(a6)
   rts
.lb1: addq #1,d2
   cmp #32,d2
   bpl.s .lb2
   lsl.l d2,d0
   move.l d1,d3
   lsl.l d2,d1
   sub #32,d2
   neg d2
   lsr.l d2,d3
   or.l d3,d0
   bra.s .lb3
.lb2: move.l d1,d0
   moveq #0,d1
   sub #32,d2
   lsl.l d2,d0
.lb3: move #$3fe0,d2
   and.l #$001fffff,d0
   bne.s .lb4
   tst.l d1
   beq.s .zero
.lb4: bclr #20,d0
   bne.s .lb5
   sub #$10,d2
   lsl.l d1
   roxl.l d0
   bra.s .lb4
.lb5: swap d0
   or d2,d0
   swap d0
   tst.b d7
   beq.s .fin
   bset #31,d0
.fin: move.l d1,(a6)
   move.l d0,-(a6)
   rts



; a0 pointe sur la chaine : [+/-][xxxx][./,xxxx][e/E[+/-][xxxx]]
; en sortie d0/d1 le r‚el. erreur=1 si erreur...
; a1 conserve les signes (mantisse puis exposant)
; a2 pointe sur les donn‚es ( chiffres puis puissances de 10 )
; a3 sert … d‚caler l'exposant si il y a des chiffres aprŠs la virgule
; d0-d7,a0-a3 utilis‚s

subval: clr a1
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
.virg: clr a3
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
.lb4: clr a1
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

; d0/d1 d2/d3 les deux termes
; d0/d1 le r‚sultat
; d0-d7 tous utilis‚s.
; on d‚coupe d0/d1  en 4 fois 16 bits : d0' d0  d1' d1
; de meme pour d2/d3                  ; d2' d2  d3' d3
; on multiplie alors comme dans une op‚ration … 4 chiffres, d6/d7 servant
; d'accumulateurs qui se d‚calent … mesure que la multiplication avance
; en effet la moiti‚ des bits seront tronqu‚s et n'ont pas besoin d'etre
; conserv‚s.
; d5 sert aux multiplications interm‚diaires, d4 conserve l'exposant.
; A cause du format IEEE, d6/d7 contiennent … la fin 4 ou 5 bits de trop
; qu'on enlŠvera par d‚calages.
; le d‚but de la routine est ‚quivalente … subdiv.

submul: move.l d0,d4
   swap d4
   move d4,d7
   and.l #$7ff0,d4
   beq .zero
   move.l d2,d5
   swap d5
   move d5,d6
   and #$7ff0,d5
   beq .zero
   add d5,d4
   sub #$3ff0,d4
   swap d4
   eor d6,d7
   bpl.s .lb0
   moveq #31,d6
   bset d6,d4
.lb0: and.l #$fffff,d0
   and.l #$fffff,d2
   moveq #20,d6
   bset d6,d0
   bset d6,d2
.lb1: moveq #0,d6
   move d3,d7
   mulu d1,d7
   clr d7
   swap d7
   swap d3
   move d3,d5
   mulu d1,d5
   add.l d5,d7
   bcc.s .x1
   moveq #1,d6
.x1: swap d1
   swap d3
   move d3,d5
   mulu d1,d5
   add.l d5,d7
   bcc.s .x2
   addq #1,d6
.x2: move d6,d7
   swap d7
   moveq #0,d6
   move d0,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x3
   moveq #1,d6
.x3: swap d3
   move d1,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x4
   addq #1,d6
.x4: swap d1
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x5
   addq #1,d6
.x5: move d6,d7
   swap d7
   moveq #0,d6
   move d3,d5
   mulu d0,d5
   add.l d5,d7
   bcc.s .x6
   moveq #1,d6
.x6: swap d2
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x7
   addq #1,d6
.x7: swap d1
   swap d2
   move d1,d5
   mulu d2,d5
   add.l d5,d7
   bcc.s .x8
   addq #1,d6
.x8: swap d3
   swap d0
   move d0,d5
   mulu d3,d5
   add.l d5,d7
   bcc.s .x9
   addq #1,d6
.x9: swap d6
   swap d3
   mulu d0,d3
   move d2,d5
   swap d0
   mulu d0,d5
   add.l d5,d3
   bcc.s .x10
   addq #1,d6
.x10: swap d2
   mulu d2,d1
   add.l d1,d3
   bcc.s .x11
   addq #1,d6
.x11: swap d6
   swap d3
   moveq #0,d1
   move d3,d1
   clr d3
   add.l d3,d7
   addx.l d1,d6
   move d0,d5
   mulu d2,d5
   add.l d5,d6
   swap d0
   move d0,d5
   mulu d2,d5
   swap d5
   clr d5
   add.l d5,d6
   swap d2
   mulu d2,d0
   add.l d0,d6
   moveq #25,d1
   btst d1,d6
   bne.s .cinq
   moveq #24,d1
   bne.s .katr
.zero: moveq #0,d0
   moveq #0,d1
   rts
.cinq: moveq #5,d2
   moveq #27,d3
   add.l #$00100000,d4
   bra.s .suite
.katr: moveq #4,d2
   moveq #28,d3
.suite: move d6,d1
   lsl.l d3,d1
   lsr.l d2,d7
   lsr.l d2,d6
   or.l d7,d1
   moveq #20,d2
   bclr d2,d6
   move.l d6,d0
   or.l d4,d0
   rts

; d0/d1 le dividende
; d2/d3 le diviseur
; d0/d1 le quotient
; d0-d7 tous utilis‚s

subdiv: move.l d0,d4
   swap d4
   move d4,d7
   and.l #$7ff0,d4               ; l'exposant est isol‚
   beq .zero                     ; si nul c'est zero
   move.l d2,d5
   swap d5
   move d5,d6
   and #$7ff0,d5                 ; isole l'exposant de 2
   beq .infini                   ; si nul division infinie
   sub d5,d4                     ; par division on soustrait les exposants
   add #$3ff0,d4                 ; on ajoute 3ff0 pour le codage IEEE
   swap d4                       ; ramŠne l'exposant au bit20
   eor d6,d7                     ; si <0 pas de meme signe donc r‚sultat<0
   bpl.s .lb0
   moveq #31,d6
   bset d6,d4
.lb0: and.l #$fffff,d0           ; conserve les mantisses
   and.l #$fffff,d2
   moveq #20,d7
   bset d7,d0                    ; ajoute le bit implicite
   bset d7,d2
   moveq #0,d5                   ; partie haute du quotient … zero
.lb1: cmp.l d2,d0
   bmi.s .lb3
   bne.s .lb2
   cmp.l d3,d1
   bcs.s .lb3
.lb2: sub.l d3,d1                ; si divd>divs on ote et on place
   subx.l d2,d0
   bset d7,d5                    ; 1 dans le quotient
.lb3: lsl.l d1                   ; divd est ensuite d‚cal‚ ( abaisser un 0 )
   roxl.l d0
   dbf d7,.lb1                   ; on boucle 21 fois
   moveq #31,d7                  ; meme boucle mais 32 fois pour la
   moveq #0,d6                   ; partie basse du quotient ( d6 )
.lb4: cmp.l d2,d0
   bmi.s .lb6
   bne.s .lb5
   cmp.l d3,d1
   bcs.s .lb6
.lb5: sub.l d3,d1
   subx.l d2,d0
   bset d7,d6
.lb6: lsl.l d1
   roxl.l d0
   dbf d7,.lb4
   moveq #20,d7
   btst d7,d5
   bne.s .lb7
   lsl.l d6                      ; si le bit20 n'est pas mis on d‚cale …
   roxl.l d5                     ; gauche et on ajuste l'exposant
   sub.l #$00100000,d4
.lb7: bclr d7,d5                 ; ote le bit implicite
   move.l d5,d0
   or.l d4,d0
   move.l d6,d1
   rts
.zero: moveq #0,d0
   moveq #0,d1
   rts
.infini: moveq #-1,d0
   moveq #-1,d1
   rts

	SAUT
flint: move.l (a6)+,d0
   smi d3
   bclr #31,d0
   swap d0
   move d0,d2
   lsr #4,d2
   sub #$3ff,d2
   bmi.s .zero
   and #$f,d0
   bset #4,d0
   swap d0
   sub #20,d2
   bgt.s .lb0
   neg d2
   lsr.l d2,d0
   bra.s .fin
.lb0: cmp #31,d2
   bpl.s .max
   move (a6),d1
   subq #1,d2
.lb1: lsl d1
   roxl.l d0
   dbf d2,.lb1
   bra.s .fin
.zero: moveq #0,d0
   bra.s .fin
.max: move.l #$7fffffff,d0
.fin: tst.b d3
   beq.s .lb2
   neg.l d0
.lb2: move.l d0,(a6)
   rts

	SAUT
intfl: moveq #0,d1
   moveq #30,d7
   moveq #0,d2
   move.l (a6),d0
   beq.s .zero
   bpl.s .lb0
   move #$800,d2
   neg.l d0
.lb0: btst d7,d0
   dbne d7,.lb0
   moveq #0,d4
   move d7,d4
   add.w #$3ff,d4
   add.w d2,d4
   lsl.w #4,d4
   swap d4
   moveq #20,d6
   sub d6,d7
   beq.s .fin
   bmi.s .gauche
   move.l d0,d1
   lsr.l d7,d0
   sub #32,d7
   neg d7
   lsl.l d7,d1
.fin: bclr d6,d0
   or.l d4,d0
   move.l d1,(a6)
   move.l d0,-(a6)
   rts
.gauche: neg d7
   lsl.l d7,d0
   bra.s .fin
.zero: move.l d1,-(a6)
   rts

	SAUT
int: move.l (a6)+,d0
   move.l (a6),d1
   move.l d0,d2
   swap d2
   bclr #15,d2
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   moveq #0,d0
   move.l d0,(a6)
   move.l d0,-(a6)
   rts
.lb0: cmp #52,d2
   bmi.s .lb1
   subq.l #4,a6
   rts
.lb1: moveq #-1,d7
   cmp #21,d2
   bpl.s .lb2
   moveq #0,d1
   sub #20,d2
   neg d2
   lsl.l d2,d7
   and.l d7,d0
   bra.s .fin
.lb2: sub #52,d2
   neg d2
   lsl.l d2,d7
   and.l d7,d1
.fin: move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
sincos: bsr trigo1
   btst #0,modulo
   bne.s .lb0
   move.l a3,(a6)
   move.l a2,-(a6)
   bra.s .lb1
.lb0: move.l a1,(a6)
   move.l a0,-(a6)
.lb1: btst #1,modulo
   beq.s .lb2
   bset #7,(a6)
.lb2: tst.b signe
   beq.s .lb4
   bchg #7,(a6)
.lb4: btst #0,modulo
   beq.s .lb3
   move.l a3,-(a6)
   move.l a2,-(a6)
   btst #1,modulo
   bne.s .fin
   bset #7,(a6)
   bra.s .fin
.lb3: move.l a1,-(a6)
   move.l a0,-(a6)
   btst #1,modulo
   beq.s .fin
   bset #7,(a6)
.fin: rts

; en entr‚e d0-1 l'angle entre 0 et pi/2
; utilise a0-1 : x et cos   a2-3 : y et sin    a4-5 : z   a6 : n
; d0-d7 pour subplus
; a4-a6 sauvegard‚s.

; Algorithme :
; x=k ( constante )   y=0    z=angle   n=0
;
;          si z<0                         si z>=0
;        x'=x+y/2^n                     x'=x-y/2^n
;        y'=y-x/2^n                     y'=y+x/2^n
;        z'=z+Cn                        z'=z-Cn      ( Cn=atn(2^-n) )
;
;                      n = n + 1     et on boucle !
;  en sortie x tend vers cosinus, et y vers sinus
;  pour x<2^-26 on prend cos=1, sin=angle



trigo: movem.l a4-a6,-(sp)
   clr .boucle
   cmp.l #$3e500000,d0       ; x<2^-26
   bpl.s .lb
   move.l #$3ff00000,a0      ; cos(x)=1
   clr.l a1
   move.l d0,a2              ; sin(x)=x
   move.l d1,a3
   bra .fin
.lb: move.l d0,a4
   move.l d1,a5
   clr.l a2
   clr.l a3
   move.l cordk,a0
   move.l cordk+4,a1
   move.l #cordic1,a6
.lb0: move.l (a6)+,d2
   move.l (a6)+,d3
   move.l a5,d1
   move.l a4,d0
   bmi .lb4
   bchg #31,d2
   bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb1
   clr.l a2
   clr.l a3
   bra.s .lb2
.lb1: bchg #31,d2
   move.l d2,a2
   move.l d1,a3
.lb2: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bsr subplus
   bra.s .lb7
.lb4: bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb5
   clr.l a2
   clr.l a3
   bra.s .lb6
.lb5: move.l d2,a2
   move.l d1,a3
.lb6: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bchg #31,d2
   bsr subplus
.lb7: exg.l d0,a2
   exg.l d1,a3
   move.l a0,d2
   move.l a1,d3
   bsr subplus
   move.l d0,a0
   move.l d1,a1
   addq #1,.boucle
   move dpth,d2      ; profondeur de calcul
   cmp .boucle,d2
   bne .lb0
.fin: movem.l (sp)+,a4-a6
   rts
.boucle: dc.w 0

; en entr‚e : l'angle sur la pile

trigo1: clr.b modulo        ; 0, 1, 2 ou 3 fois pi/2
   move.l (a6)+,d0
   smi signe
   bclr #31,d0
   move.l (a6),d1
   move.l #pisur2,a0
   move.l (a0)+,d2
   move.l (a0),d3
   bsr subdiv             ; calcule x/(pi/2)
   swap d0
   move d0,d2
   and #$f,d0
   bset #4,d0
   swap d0
   lsr #4,d2
   sub #$3ff,d2
   bpl.s .lb0
   move.l -4(a6),d0       ; si n‚gatif alors, x<pi/2
   move.l (a6),d1
   bclr #31,d0
   bra .suite
.lb0: cmp #51,d2
   bpl .trop
.lb1: lsl.l d1
   roxl.l d0
   dbf d2,.lb1
   btst #21,d0
   beq.s .lb2
   addq.b #1,modulo
.lb2: btst #22,d0
   beq.s .lb3
   addq.b #2,modulo
.lb3: and.l #$001fffff,d0
   bne.s .lb4
   tst.l d1
   beq.s .lb6
   moveq #20,d7
.lb4: bclr d7,d0
   bne.s .lb5
   lsl.l d1
   roxl.l d0
   subq #1,d2
   bra.s .lb4
.lb5: add #$3ff,d2
   lsl #4,d2
   bclr #16,d2
   swap d2
   clr d2
   add.l d2,d0
.lb6: move.l (a0),d3
   move.l -(a0),d2
   bsr submul
.suite: bsr trigo
   rts
.trop: subq.l #4,a6
   rts

	SAUT
sin: bsr trigo1
   btst #0,modulo
   bne.s .lb0
   move.l a3,(a6)
   move.l a2,-(a6)
   bra.s .lb1
.lb0: move.l a1,(a6)
   move.l a0,-(a6)
.lb1: btst #1,modulo
   beq.s .lb2
   bset #7,(a6)
.lb2: tst.b signe
   beq.s .fin
   bchg #7,(a6)
.fin: rts

	SAUT
cos: bsr trigo1
   btst #0,modulo
   beq.s .lb0
   move.l a3,(a6)
   move.l a2,-(a6)
   btst #1,modulo
   bne.s .fin
   bset #7,(a6)
   bra.s .fin
.lb0: move.l a1,(a6)
   move.l a0,-(a6)
   btst #1,modulo
   beq.s .fin
   bset #7,(a6)
.fin: rts

	SAUT
tan: bsr trigo1
   btst #0,modulo
   beq.s .lb0
   move.l a0,d0
   move.l a1,d1
   move.l a2,d2
   move.l a3,d3
   bset #31,d0
   bra.s .suite
.lb0: move.l a2,d0
   move.l a3,d1
   move.l a0,d2
   move.l a1,d3
.suite: bsr subdiv
   tst.b signe
   beq.s .fin
   bchg #31,d0
.fin: move.l d1,(a6)
   move.l d0,-(a6)
   rts

; Algorithme :
; x=1   y=angle    z=0   n=0
;
;          si y>=0                         si y<0
;        x'=x+y/2^n                     x'=x-y/2^n
;        y'=y-x/2^n                     y'=y+x/2^n
;        z'=z+Cn                        z'=z-Cn      ( Cn=atn(2^-n) )
;
;                      n = n + 1     et on boucle !
;  en sortie z tend vers atn
;  pour x<2^-26 on prend atn(x)=x

atn: movem.l a4-a6,-(sp)
   clr .boucle
   move.l (a6)+,d0
   smi signe
   bclr #31,d0
   move.l d0,a2
   move.l (a6),a3
   cmp.l #$3e500000,a2       ; x<2^-26
   bpl.s .lb
   movem.l (sp)+,a4-a6       ; atn(x)=x
   rts
.lb: clr.l a4
   clr.l a5
   move.l #cordic1,a6
   move.l #$3ff00000,a0
   clr.l a1
.lb0: move.l (a6)+,d2
   move.l (a6)+,d3
   move.l a5,d1
   move.l a4,d0
   cmp.l #0,a2
   bpl .lb4
   bchg #31,d2
   bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb1
   clr.l a2
   clr.l a3
   bra.s .lb2
.lb1: bchg #31,d2
   move.l d2,a2
   move.l d1,a3
.lb2: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bsr subplus
   bra.s .lb7
.lb4: bsr subplus
   move.l d0,a4
   move.l d1,a5
   move.l a2,d0
   move.l d0,d2
   smi d5
   move.l a3,d1
   move .boucle,d7
   lsl #4,d7
   swap d7
   clr d7
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   beq.s .lb5
   clr.l a2
   clr.l a3
   bra.s .lb6
.lb5: move.l d2,a2
   move.l d1,a3
.lb6: move.l a0,d2
   smi d5
   move.l a1,d3
   sub.l d7,d2
   smi d6
   cmp.b d6,d5
   bne.s .lb7
   bchg #31,d2
   bsr subplus
.lb7: exg.l d0,a2
   exg.l d1,a3
   move.l a0,d2
   move.l a1,d3
   bsr subplus
   move.l d0,a0
   move.l d1,a1
   addq #1,.boucle
   move dpth,d0
   cmp .boucle,d0
   bne .lb0
   move.l a4,d0
   move.l a5,d1
   movem.l (sp)+,a4-a6
   tst.b signe
   beq.s .fin
   bset #31,d0
.fin: move.l d0,(a6)
   move.l d1,4(a6)
   rts
.boucle: dc.w 0

	SAUT
carre: move.l (a6)+,d0
   move.l (a6),d1
   move.l d0,d2
   move.l d1,d3
   bsr submul
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

; algorithme : X=m*2^n. On sait calculer l'exponentielle d'une valeur
; inf‚rieure … 1. Si X<2^-26 on utilise un DL : exp(X)=1+X
;                 Si X<1     alors x=X      et e=0
;                 Si X>1     alors x=m*2^-1 et e=n+1
; Pour calculer l'exponentielle de x:
;    on d‚compose x en une somme de Ci, avec Ci=ln(1+2^-i)
;    ensuite exp(x)= produit de (1+2^-i), ce qui se fait par d‚calages et somme
; Pour calculer ensuite exp(X) :
;    exp(X)=exp(x)^(2^e), c'est … dire au carr‚ e fois.
; ( Note : si X ‚tait n‚gatif, on calcule ensuite 1/exp(X) )

expo: moveq #0,d3
   move.l #$00100000,d2      ; d2-d3 est l'exponentielle, au d‚but 1.
   move.l (a6)+,d0
   smi signe
   bclr #31,d0
   cmp.l #$408633ce,d0
   bmi.s .lb
   move.l #$7fffffff,d0
   moveq #0,d1
   bra .sortie
.lb: cmp.l #$3e500000,d0
   bpl.s .lb0
   subq.l #4,a6          ; si x<2^-26 alors
   move.l d3,-(a6)     ; exp(x)=1+x
   move.l #$3ff00000,-(a6)
   bra fplus
.lb0: move.l (a6),d1
   swap d0
   move d0,d4
   and #$f,d0
   bset #4,d0
   swap d0               ; d0 ne contient plus que la mantisse
   lsr #4,d4
   sub #$3ff,d4          ; d4 est l'exposant
   bmi.s .lb1            ; si n‚gatif exp est direct
   addq #1,d4            ; sinon m*2^n est calcul‚ avec m*2^-1 d'abord
   swap d4               ; puis par mise au carr‚ on tient compte de 2^(n+1)
   move #-1,d4
   bra.s .lb2
.lb1: swap d4
   clr d4
   swap d4
.lb2: neg d4             ; ici d4 contient [n+1 ou 0].w pour les mises au carr‚
   move.l #logexp,a0     ;                 [ e ].w      exposant de la mantisse
.lb3: cmp dpthex,d4      ; a t-on fini?
   bpl .fin
   move d4,d6
   asl #3,d6
   move d4,d5
   lea -8(a0,d6),a1      ; a1 pointe sur la donn‚e ayant le meme expos que x
   move.l (a1)+,d6
   move.l (a1)+,d7
   sub.l d7,d1
   subx.l d6,d0          ; calcule x-Ci
   bpl.s .lb4            ; positif, c'est bon
   add.l d7,d1
   addx.l d6,d0          ; sinon restaure x
   addq #1,d5            ; prend Ci+1, un eposant en dessous
   move.l (a1)+,d6
   move.l (a1),d7
   lsr.l d6              ; d‚calage oblig‚
   roxr.l d7
   sub.l d7,d1
   subx.l d6,d0          ; calcule le nouveau x-Ci
.lb4: bne.s .lb6         ; si le r‚sulat est nul
   tst.l d1
   beq .lb5              ; on saute
.lb6: btst #20,d0        ; sinon on v‚rifie que x contient toujours le bit 20
   bne.s .lb5
   addq #1,d4            ; cas contraire on d‚cale d'une position
   lsl.l d1
   roxl.l d0
   bra.s .lb6            ; nouvelle v‚rification
.lb5: move d5,d6
   swap d5
   move d6,d5            ; d5 contient deux fois l'exposant de x
   move.l d2,d6
   move.l d3,d7          ; dans d6-d7 on calcule d2-d3 / 2^i
   subq #1,d5
   beq.s .lb8
   cmp #32,d5
   bpl.s .lb7
   move.l d0,a1               ; moins de 32 d‚calages
   move.l d6,d0
   lsr.l d5,d6
   lsr.l d5,d7
   sub #32,d5
   neg d5
   lsl.l d5,d0
   or.l d0,d7
   move.l a1,d0
   bra.s .lb8
.lb7: move.l d6,d7            ; plus de 32 d‚calages, d7 inutile
   moveq #0,d6
   sub #32,d5
   lsr.l d5,d7
.lb8: swap d5
   add.l d7,d3
   addx.l d6,d2               ; d2-d3 = d2-d3 *(1+2^-i)
   move.l d0,d7
   or.l d1,d7                 ; si la mantisse est nulle
   bne .lb3                   ; on ne reviendra pas en arriŠre
.fin: swap d4
   move.l #$3ff00000,d6       ; exposant normal, si e^x < 2
   btst #21,d2                ; si e^x d‚passe 2, bit 21 mis
   beq.s .lb10
   move.l #$40000000,d6       ; alors 1 pour exposant
   lsr.l d2                   ; et on d‚cale
   roxr.l d3
.lb10: bclr #20,d2            ; ote le bit implicite
   or.l d6,d2                 ; ajoute l'exposant
   move.l d2,d0
   move.l d3,d1               ; colle le tout dans d0-d1
   move d4,a0
.lb9: cmp #0,a0               ; eposant de d‚part nul?
   beq.s .sortie              ; si oui pas de mise au carr‚
   subq #1,a0                 ; sinon
   move.l d0,d2
   move.l d1,d3
   bsr submul                 ; au carr‚
   bra.s .lb9                 ; on boucle
.sortie: tst.b signe          ; signe moins?
   beq.s .out
   move.l d0,d2
   move.l d1,d3
   move.l #$3ff00000,d0
   moveq #0,d1
   bsr subdiv                 ; si oui alors exp(-x)=1/exp(x)
.out: move.l d1,(a6)          ; ouf...
   move.l d0,-(a6)
   rts

; algorithme : X=m*2^e
; donc ln(X)= ln(m) + e * ln(2)
; pour le calcul de ln(m) :
;   on ‚crit m sous la forme d'un produit de (1+2^-i)
;   puis ln(m) = somme ( ln(1+2^-i) ), valeurs en m‚moire.
; [ plutot que de diviser m par 1+2^-i ( ce qui est long )
; on part de k=1, puis on calcule k'=k*(1+2^-i) ( par d‚calage et somme )
; ceci tant qu'on ne d‚passe pas m. ]
; [ si X<0, on prend la valeur absolue
;   si m<1+2^-26, on utilise un DL ln(1+x)=x-x^2/2 ]

	SAUT
loga: move.l (a6)+,d0
   bclr #31,d0
   move.l (a6),d1             ; d0-d1 = abs(x)
   swap d0
   move d0,d2
   and #$f,d0
   bset #4,d0
   swap d0                    ; d0 ne contient plus que la mantisse
   lsr #4,d2
   bne.s .lb0
   moveq #-1,d0               ; si x=0
   move.l d0,(a6)             ; ln(x)= -infini
   move.l d0,-(a6)
   rts
.lb0: move.l #logexp+8,a1     ; pointe sur ln(1.5)
   clr a0
   sub #$3ff,d2               ; d2 est l'exposant
   bne.s .lb1
   moveq #0,d2                ; si l'exp est nul, la partie e*ln(2)
   move.l d2,(a6)             ; est nulle aussi
   move.l d2,-(a6)
   bra.s .lb5
.lb1: bpl.s .lb2
   move #1,a0                 ; a0=1 si l'exp est n‚gatif
   neg d2
.lb2: movem.l d0-d1,-(sp)     ; sauve d0-d1
   moveq #10,d5
.lb3: bclr d5,d2              ; convertit e ( entre 1 et 1024 ) en r‚el
   dbne d5,.lb3
   moveq #0,d3
   moveq #20,d6
   sub d5,d6
   lsl.l d6,d2
   add #$3ff,d5
   lsl #4,d5
   swap d5
   or.l d5,d2                 ; dans d2-d3
   move.l #$3fe62e42,d0       ; ln(2) dans d0-d1
   move.l #-$105c611,d1
   cmp #0,a0
   beq.s .lb4
   bset #31,d0                ; ajuste le signe
.lb4: bsr submul
   move.l d1,(a6)
   move.l d0,-(a6)            ; conserve e*ln(2) sur la pile
   movem.l (sp)+,d0-d1        ; r‚cupŠre d0-d1
.lb5: move.l d0,a2            ; a2-a3 est la mantisse
   move.l d1,a3
   moveq #1,d6                ; nombre de d‚calages ( 1 pour 1.5 )
   moveq #0,d2
   moveq #0,d3
   moveq #0,d1                ; d0-d1 est l'accumulateur 0 au d‚part
   moveq #0,d0
   bset #20,d2                ; d2-d3 est l'approche de la mantisse, 1 au d‚part
.lb6: move.l d2,d4
   move.l d3,d5               ; d4-d5 va etre d2-d3/2^i
   move d6,a0
   cmp #32,d6
   bpl.s .lb7
   move.l d4,d7               ; moins de 32 d‚calages
   lsr.l d6,d4
   lsr.l d6,d5
   sub #32,d6
   neg d6
   lsl.l d6,d7
   or.l d7,d5
   bra.s .lb8
.lb7: move.l d4,d5            ; plus de 32 d‚calages, d5 inutile
   moveq #0,d4
   sub #32,d6
   lsr.l d6,d5
.lb8: move a0,d6
   add.l d3,d5                ; d4-d5= d2-d3+d4-d5, donc d4-d5=d2-d3*(1+2^-i)
   addx.l d2,d4
   cmp.l a2,d4
   bmi.s .ok                  ; ne d‚passe pas la mantisse, ok
   bne.s .autre               ; sinon au suivant
   cmp.l a3,d5                ; meme chose si ‚galit‚ des 21 bits sup‚rieurs
   beq.s .ok
   bcc.s .autre
.ok: move.l d4,d2             ; d2-d3 devient d4-d5
   move.l d5,d3
   tst.l d0
   bne.s .lb9
   move.l (a1)+,d0            ; si d0=0, premier calcul
   move.l (a1)+,d1
   move d6,d7
   swap d6
   move d7,d6                 ; on initialise d6.w (fort)
   swap d6
   bra.s .suite
.lb9: move.l (a1)+,d4         ; sinon on ajoute … d0-d1 ln(1+2^-i)
   move.l (a1)+,d5
   move.l d6,a0
   swap d6
   sub a0,d6
   neg d6                     ; pour cela il faut d‚caler !
   cmp #32,d6
   bpl.s .lb10
   move.l d4,d7               ; moins de 32 d‚calages
   lsr.l d6,d4
   lsr.l d6,d5
   sub #32,d6
   neg d6
   lsl.l d6,d7
   or.l d7,d5
   bra.s .lb11
.lb10: move.l d4,d5            ; plus de 32 d‚calages, d5 inutile
   moveq #0,d4
   sub #32,d6
   lsr.l d6,d5
.lb11: move.l a0,d6
   add.l d5,d1
   addx.l d4,d0                ; mise … jour de l'accumulateur
   btst #21,d0
   beq.s .suite
   lsr.l d0                    ; d‚passe 2, on ajuste
   roxr.l d1
   sub.l #$10000,d6            ; l'exposant aussi
   bra.s .suite
.autre: addq.l #8,a1           ; si pas ok, on passe … i+1
.suite: addq #1,d6
   cmp dpthln,d6               ; a t-on fini?
   bne .lb6
   tst.l d0                    ; si accu nul, alors e*ln(2) suffit
   beq.s .fin
   swap d6                     ; sinon on reforme l'accu avec son exposant
   moveq #-1,d7
   sub d6,d7
   add #$3ff,d7
   lsl #4,d7
   swap d7
   clr d7
   bclr #20,d0
   or.l d7,d0
   move.l (a6)+,d2
   move.l (a6),d3             ; r‚cupŠre e*ln(2)
   bsr subplus                ; additionne ln(m) avec e*ln(2)
   move.l d1,(a6)             ; c'est fini...
   move.l d0,-(a6)
.fin: rts

; sqr(A) utilise l'algorithme de newton appliqu‚ … f(x)=x^2-A
; ce qui donne : x'=(x+A/x)/2, qui est ex‚cut‚ 6 fois avec pour valeur
; de d‚part ( A = m * 2^e ) x = m * 2^(e/2), ce qui assure une erreur
; de d‚part d'un facteur racine de 2 au plus !

	SAUT
sqr: lea .boucle(pc),a1         ; zone servant de compteur de boucle
   move #6,(a1)                 ; 6 boucles
   bclr #7,(a6)                 ; signe non pris en compte
   move.l a6,a0                 ; on recopie A dans la pile un cran en dessous
   move.l 4(a6),d1              ; A est en plus dans D0/D1
   move.l d1,-(a0)
   move.l (a6),d0
   swap d0
   move d0,d2
   and #$7ff0,d2
   beq .zero
   sub #$3ff0,d2
   asr d2                       ; pour le x de d‚part on divise l'exposant
   add #$3ff0,d2                ; par 2.
   and #$7ff0,d2
   and #$f,d0
   or d2,d0
   swap d0
   move.l d0,-4(a0)
.lb0: move.l d0,d2              ; copie x dans d2/d3
   move.l d1,d3
   move.l (a6),d0               ; A dans d0/d1
   move.l 4(a6),d1
   bsr subdiv                   ; A/x
   move.l (a0),d3               ; x dans d2/d3
   move.l -(a0),d2
   bsr subplus                  ; x+A/x
   sub.l #$00100000,d0          ; (x+A/x)/2
   move.l d0,(a0)+              ; copie le nouveau x dans la pile
   move.l d1,(a0)
   subq #1,(a1)                 ; boucle finie?
   bne.s .lb0
   move.l d0,(a6)               ; si oui d0/d1 sur la pile
   move.l d1,4(a6)
   rts
.boucle: dc.w 0
.zero: clr.l (a6)
   clr.l 4(a6)
   rts

	SAUT
fdiv: move.l (a6)+,d2
   move.l (a6)+,d3
   move.l (a6)+,d0
   move.l (a6),d1
   bsr subdiv
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
ffois: move.l (a6)+,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr submul
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
fplus: move.l (a6)+,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr subplus
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

	SAUT
fmoins: move.l (a6)+,d0
   moveq #31,d7
   bchg d7,d0
   move.l (a6)+,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr subplus
   move.l d1,(a6)
   move.l d0,-(a6)
   rts

; sur la pile (a6) contient le r‚el
; en sortie dans #affbuf se trouve la chaine
; utilise d0-d7 et a0-a3

subaff: lea affbuf,a3
   move.l (a6)+,d0
   bpl.s .lb0
   move.b #'-',(a3)+
   bclr #31,d0
   bra.s .lbb
.lb0: move.b #' ',(a3)+
.lbb: move.l (a6)+,d1
   bne.s .lba
   tst.l d0
   bne.s .lba
   move.l #$20300000,affbuf ; espace, z‚ro, fin
   rts
.lba: moveq #8,d7          ; 9 boucles de 10^+-256 … 10^+-1
   moveq #0,d5          ; puissance de 10
   btst #30,d0          ; si il est mis l'exposant est au moins $400 donc >0
   beq .negatif
   lea posdata+72,a2
.lb1: move.l -(a2),d3
   move.l -(a2),d2
   cmp.l d0,d2
   bmi.s .non
   bne.s .oui
   cmp.l d3,d1
   bcs.s .oui
.non: move d5,a0
   move d7,a1
   bsr subdiv
   move a1,d7
   move a0,d5
   bset d7,d5
.oui: dbf d7,.lb1
   moveq #1,d7
   cmp #8,d5
   bpl .suite
   move d5,d7
   addq #1,d7
   moveq #0,d5
   bra .suite
.negatif: lea negdata+72,a2
 .lb2: move.l -(a2),d3
   move.l -(a2),d2
   cmp.l d2,d0
   bmi.s .non2
   bne.s .oui2
   cmp.l d1,d3
   bcs.s .oui2
.non2: move d5,a0
   move d7,a1
   bsr subdiv
   move a1,d7
   move a0,d5
   bset d7,d5
.oui2: dbf d7,.lb2
   cmp.l #$3ff00000,d0
   bpl.s .lbe
.lbd: move.l (a2)+,d2
   move.l (a2),d3
   move d5,a0
   bsr subdiv
   move a0,d5
   addq #1,d5
.lbe: moveq #1,d7     ; normalement virgule aprŠs le premier chiffre
   cmp #5,d5
   bpl.s .lb5
   tst d5
   beq.s .lb5
   moveq #0,d7     ; sinon pas de virgule !, elle y est d‚j….
   move.b #'0',(a3)+
   move.b #'.',(a3)+ ; puisque je la mets !
   subq #1,d5
   bra.s .lb3
.lb4: move.b #'0',(a3)+
.lb3: dbf d5,.lb4
   moveq #0,d5
.lb5: neg d5
.suite: moveq #10,d6       ; 11 chiffres
   move.l d0,d2
   swap d2
   lsr #4,d2
   sub #$3ff,d2           ; d2 est l'exposant
   and.l #$000fffff,d0    ; on vire l'exposant
   bset #20,d0            ; ajout du bit implicite
   subq #3,d2
   neg d2
.lb6: lsr.l d0
   roxr.l d1
   dbf d2,.lb6               ; now la partie entiŠre de la mantisse est dans le
.lb8: swap d0                ; mot sup‚rieur de d0
   add.b #'0',d0
   move.b d0,(a3)+
   subq #1,d7
   bne.s .lb7
   move.b #'.',(a3)+
.lb7: clr d0
   swap d0
   lsl.l d1
   roxl.l d0
   move.l d1,d3
   move.l d0,d2
   lsl.l d1
   roxl.l d0
   lsl.l d1
   roxl.l d0
   add.l d3,d1
   addx.l d2,d0
   dbf d6,.lb8
   cmp.b #'5',-(a3)
   bmi.s .lb9
   move.l a3,a2
.la0: cmp.b #".",-(a2)
   beq.s .la1
   addq.b #1,(a2)
   cmp.b #'9'+1,(a2)
   bne.s .lb9
   move.b #'0',(a2)
   bra.s .la0
.la1: move.l a2,a0
.la2: cmp.l #affbuf+2,a2
   bmi.s .la3
   addq.b #1,-(a2)
   cmp.b #'9'+1,(a2)
   bne.s .lb9
   move.b #'0',(a2)
   bra.s .la2
.la3: move.b #'1',(a2)
   tst d5
   beq.s .la4
   addq #1,d5
   bra.s .lb9
.la4: move.b #'0',(a0)+
   move.b #'.',(a0)
.lb9: cmp.b #'0',-(a3)
   beq.s .lb9
   cmp.b #'.',(a3)
   beq.s .lb10
   addq.l #1,a3
.lb10: tst d5
   beq.s .fin
   bpl.s .lb11
   move.b #'e',(a3)+
   move.b #'-',(a3)+
   neg d5
   bra.s .lb12
.lb11: move.b #'e',(a3)+
.lb12: addq.l #1,a3
   cmp #10,d5
   bmi.s .lb13
   addq.l #1,a3
   cmp #100,d5
   bmi.s .lb13
   addq.l #1,a3
.lb13: move.l a3,a0
   ext.l d5
.lb14: divs #10,d5
   swap d5
   add.b #'0',d5
   move.b d5,-(a0)
   swap d5
   ext.l d5
   bne.s .lb14
.fin: clr.b (a3)
   rts

inv: move.l #$3ff00000,d0
   moveq #0,d1
   move.l (a6)+,d2
   move.l (a6),d3
   bsr subdiv
   move.l d1,(a6)
   move.l d0,-(a6)
   rts


   data

; pour logarithme et exponentielle
; log(1+2^-n) n partant de 0.
; seule la mantisse est pr‚sente ( le bit implicite est mis )
; les exposants commencent … -1 puis descendent de 1 en 1.

logexp:

   dc.l $162E42,-$105C611
   dc.l $19F323,-$134067B4
   dc.l $1C8FF7,-$386565DE
   dc.l $1E2707,$6E2AF2E6
   dc.l $1F0A30,-$3FEE9D5A
   dc.l $1F829B,$E783300
   dc.l $1FC0A8,-$4F03FC1C
   dc.l $1FE02A,$6B106789
   dc.l $1FF00A,-$5D4EF440
   dc.l $1FF802,-$5654EF1A
   dc.l $1FFC00,-$55754EF0
   dc.l $1FFE00,$2AA6AB11
   dc.l $1FFF00,$AAA2AB1
   dc.l $1FFF80,$2AA9AAB
   dc.l $1FFFC0,$AAA8AB
   dc.l $1FFFE0,$2AAA6B
   dc.l $1FFFF0,$AAAA3
   dc.l $1FFFF8,$2AAAA
   dc.l $1FFFFC,$AAAB
   dc.l $1FFFFE,$2AAB
   dc.l $1FFFFF,$AAB
   dc.l $1FFFFF,-$7FFFFD55
   dc.l $1FFFFF,-$3FFFFF55
   dc.l $1FFFFF,-$1FFFFFD5
   dc.l $1FFFFF,-$FFFFFF5
   dc.l $1FFFFF,-$7FFFFFD
   dc.l $1FFFFF,-$3FFFFFF
   dc.l $1FFFFF,-$2000000
   dc.l $1FFFFF,-$1000000
   dc.l $1FFFFF,-$800000
   dc.l $1FFFFF,-$400000
   dc.l $1FFFFF,-$200000
   dc.l $1FFFFF,-$100000
   dc.l $1FFFFF,-$80000
   dc.l $1FFFFF,-$40000
   dc.l $1FFFFF,-$20000
   dc.l $1FFFFF,-$10000
   dc.l $1FFFFF,-$8000
   dc.l $1FFFFF,-$4000
   dc.l $1FFFFF,-$2000
   dc.l $1FFFFF,-$1000
   dc.l $1FFFFF,-$800
   dc.l $1FFFFF,-$400
   dc.l $1FFFFF,-$200
   dc.l $1FFFFF,-$100
   dc.l $1FFFFF,-$80
   dc.l $1FFFFF,-$40
   dc.l $1FFFFF,-$20
   dc.l $1FFFFF,-$10
   dc.l $1FFFFF,-$8
   dc.l $1FFFFF,-$4
   dc.l $1FFFFF,-$2
   dc.l $1FFFFF,-$1

; donn‚es pour les fonctions trigo
; chaque ligne repr‚sente atn(2^-n), en commen‡ant avec n=0.

cordic1:
   dc.l $3FE921FB,$54442D18
   dc.l $3FDDAC67,$561BB4F
   dc.l $3FCF5B75,-$6D37F23
   dc.l $3FBFD5BA,-$6553D092
   dc.l $3FAFF55B,-$48D30216
   dc.l $3F9FFD55,-$445689DB
   dc.l $3F8FFF55,$5BBB729B
   dc.l $3F7FFFD5,$55BBBA97
   dc.l $3F6FFFF5,$555BBBB7
   dc.l $3F5FFFFD,$5555BBBC
   dc.l $3F4FFFFF,$55555BBC
   dc.l $3F3FFFFF,-$2AAAAA44
   dc.l $3F2FFFFF,-$AAAAAA4
   dc.l $3F1FFFFF,-$2AAAAAA
   dc.l $3F0FFFFF,-$AAAAAB
   dc.l $3EFFFFFF,-$2AAAAB
   dc.l $3EEFFFFF,-$AAAAB
   dc.l $3EDFFFFF,-$2AAAB
   dc.l $3ECFFFFF,-$AAAB
   dc.l $3EBFFFFF,-$2AAB
   dc.l $3EAFFFFF,-$AAB
   dc.l $3E9FFFFF,-$2AB
   dc.l $3E8FFFFF,-$AB
   dc.l $3E7FFFFF,-$2B
   dc.l $3E6FFFFF,-$B
   dc.l $3E5FFFFF,-$3
   dc.l $3E4FFFFF,-$1
   dc.l $3E400000,$0
   dc.l $3E300000,$0
   dc.l $3E200000,$0
   dc.l $3E100000,$0
   dc.l $3E000000,$0
   dc.l $3DF00000,$0
   dc.l $3DE00000,$0
   dc.l $3DD00000,$0
   dc.l $3DC00000,$0
   dc.l $3DB00000,$0
   dc.l $3DA00000,$0
   dc.l $3D900000,$0
   dc.l $3D800000,$0
   dc.l $3D700000,$0
   dc.l $3D600000,$0
   dc.l $3D500000,$0
   dc.l $3D400000,$0
   dc.l $3D300000,$0
   dc.l $3D200000,$0
   dc.l $3D100000,$0
   dc.l $3D000000,$0
   dc.l $3CF00000,$0
   dc.l $3CE00000,$0
   dc.l $3CD00000,$0
   dc.l $3CC00000,$0
   dc.l $3CB00000,$0

	text
	end
