********************************************
* ECRIT UNE TEXTE COMPLET EN PETITE FONTE  *
* ( CELA PERMET D'ECRIRE PLUS !! ) EN EFFET*
* ON PEUT DISPOSER DE 53 CAR. DE + EN MOY. *
* RESO.,SOIT 13 DE PLUS !!                 *
********************************************

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

* reformate l'ecran avec le clipping

 lea.l contrl,a0
 move.w #129,(a0)
 move.w #2,2(a0)
 move.w #1,6(a0)
 move.w #1,12(a0)
 move.w #1,intin
 lea.l ptsin,a0
 move.w #0,(a0)+
 move.w #0,(a0)+
 move.w #319,(a0)+
 move.w #199,(a0)+
 jsr vdi

* fixe la taille des caracteres

 lea.l contrl,a0
 move.w #12,(a0)
 move.w #1,2(a0)
 move.w #0,6(a0)
 move.w #1,12(a0)
 lea.l ptsin,a0
 move.w #0,(a0)+
 move.w #4,(a0)
 jsr vdi

* affiche le texte

 move.w #5,d6
 lea.l text,a6
loop
 lea.l contrl,a0
 move.w #8,(a0)
 move.w #1,2(a0)
 move.w #53,6(a0)	Nomre de car. par ligne
 move.w #1,12(a0)
 lea.l ptsin,a0
 move.w #0,(a0)+
 move.w d6,(a0)+
 
 lea.l intin,a0
 rept 53
 clr.w d0
 move.b (a6)+,d0
 move.w d0,(a0)+
 endr

 addi.w #8,d6

 movem.l d5-d6/a6,-(sp)
 jsr vdi
 movem.l (sp)+,d5-d6/a6
 tst.b (a6)
 bne loop

* refixe la taille des caracteres

 lea.l contrl,a0
 move.w #12,(a0)
 move.w #1,2(a0)
 move.w #0,6(a0)
 move.w #1,12(a0)
 lea.l ptsin,a0
 move.w #0,(a0)+
 move.w #6,(a0)
 jsr vdi

 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 clr -(sp)
 trap #1

vdi	* appel vdi
 move.l #vdipb,d1
 moveq.w #115,d0
 trap #2
 rts
vdipb dc.l contrl,intin,ptsin,intout,ptsout
contrl ds.w 12
intin  ds.w 128
intout ds.w 128
ptsin  ds.w 128
ptsout ds.w 128

text
 DC.B "SALUT BANDES DE NAZES ! VOUS VOUS DITES SUREMENT:    "
 DC.B "QU'EST CE QUE C'EST QUE CE BOURRIN AVEC CES 53 CARAC-"
 DC.B "-TERES PAR LIGNE ?? ET BIEN JE VOUS EMMERDE,CAR AU-  "
 DC.B "-JOURD'HUI,JE VIENS DE DECOUVRIR ENFIN (APRES DE LON-"
 DC.B "-GUES NUITS D'HIVER) LE SECRET DE LA VDI............."
 REPT 50
 DC.B 0
 ENDR