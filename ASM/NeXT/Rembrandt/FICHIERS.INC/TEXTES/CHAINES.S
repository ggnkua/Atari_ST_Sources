; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion de chaines de caractŠres. (1.1)
;
; - MOT LONG non sign‚ -> Ecriture d'une chaine ASCII
; - Lecture d'une chaine ASCII -> MOT LONG non sign‚

;#################################################################
;##
;## Cette fonction transforme un chiffre non sign‚ cod‚ sur un
;## mot long, en une chaine de caractŠres ASCII, termin‚e par
;## un octet nul (Format C/Gem).
;## D0.L -> Valeur … convertir
;## A0.L -> Adresse de la chaine
;##
;#################################################################

**** ! Le dernier caractŠre pointe sur le caractŠre '0'...
**** Cela permet l'‚criture chain‚e de chaines num‚riques.

 TEXT
 
inscrit_chaine
 tst.l d0
 bne.s .pas_nul
 move.b #'0',(a0)+
 clr.b (a0)
 rts
.pas_nul 
 movem.l d1/d2/d6/d7,-(sp)
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
 bne.s .position_suivante
 bra.s .fin_chaine
 
.inscrit_z‚ro
 tst.b d6
 beq.s .saute_premier_z‚ro
 move.b #'0',(a0)+
.saute_premier_z‚ro
 divu.l #10,d7
 bne.s .position_suivante

.fin_chaine
 clr.b (a0)
 movem.l (sp)+,d1/d2/d6/d7
 rts


;
; Mˆme chose que pr‚c‚dement, mais la valeur num‚rique est directement inscrite.
; La fin de la chaine est indiqu‚e par '-1'
;
inscrit_chaine_3x5
 tst.l d0
 bne.s .pas_nul
 clr.b (a0)+
 move.b #-1,(a0)
 rts
.pas_nul 
 movem.l d1/d2/d6/d7,-(sp)
 sf d6
 move.l #1000000000,d7
.position_suivante
 move.l d0,d1
 divu.l d7,d1	Divise par la puissance de 10
 beq .inscrit_z‚ro
 st d6
 move.b d1,(a0)+	Inscrit le caractŠre
 mulu.l d7,d1
 sub.l d1,d0
 divu.l #10,d7
 bne.s .position_suivante
 bra.s .fin_chaine
 
.inscrit_z‚ro
 tst.b d6
 beq.s .saute_premier_z‚ro
 clr.b (a0)+
.saute_premier_z‚ro
 divu.l #10,d7
 bne.s .position_suivante

.fin_chaine
 move.b #-1,(a0)
 movem.l (sp)+,d1/d2/d6/d7
 rts


;#################################################################
;##
;## Cette fonction transforme une chaine ASCII termin‚e par un
;## un octet nul (Format C/Gem) en un mot long non sign‚.
;## A0.L -> Adresse de la chaine … convertir
;## D0.L -> R‚sultat non sign‚
;##
;#################################################################

lit_chaine
 move.l d1,-(sp)
 moveq #0,d0
 moveq #0,d1
.position_suivante
 move.b (a0)+,d1
 beq.s .fin_chaine
 mulu #10,d0
 sub #'0',d1
 add.l d1,d0
 bra.s .position_suivante
.fin_chaine
 move.l (sp)+,d1
 rts


; Affiche une chaine de caractŠres … l'‚cran.
; a0-> Adresse de la chaine
; a1-> Adresse ‚cran
;
affiche_chaine_texte 
 movem.l d0-a6,-(sp)
 move largeur_‚cran,d7
 sub #12,d7
  
 move.l a1,a6
 lea fonte,a3

 move.l #-1,d6		On affiche par d‚faut en BLANC
    
.lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0 	Prends le code ASCII du caractŠre
 beq .fin_de_texte	si 0, termin‚
 cmp.b #-1,d0		si -1, le mot suivant contient la couleur du texte
 bne.s .pas_change_couleur
 move (a0),d6
 swap d6
 move (a0)+,d6
 bra.s .lettre_suivante
.pas_change_couleur
 cmp.b #13,d0
 bne.s .pas_saut_de_ligne
 move largeur_‚cran,d0
 lea (a6,d0.w*8),a6
 move.l a6,a1
 bra.s .lettre_suivante
.pas_saut_de_ligne
 mulu #72,d0
 lea (a3,d0.w),a4	Adresse du caractŠre d‚sir‚
 move.l a1,a5		Adresse d'affichage du caractŠre
 rept 6
 move.l (a4)+,d1
 and.l d6,d1
 move.l d1,(a5)+	Affichage d'une rang‚e du caractŠre
 move.l (a4)+,d1
 and.l d6,d1
 move.l d1,(a5)+
 move.l (a4)+,d1
 and.l d6,d1
 move.l d1,(a5)+
 add d7,a5
 endr
 lea 12(a1),a1
 bra .lettre_suivante
.fin_de_texte 
 movem.l (sp)+,d0-a6
 rts

;
; Recopie une chaine de caractŠres au format C (termin‚e par un 0)
; A0 -> Chaine source
; A1 -> Chaine destination
;
copie_chaine_texte
 move.b (a0)+,(a1)+
 bne.s copie_chaine_texte
 rts
 