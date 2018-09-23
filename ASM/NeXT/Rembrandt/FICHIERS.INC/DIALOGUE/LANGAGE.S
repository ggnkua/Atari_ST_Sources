; REMBRANDT 3.0 - Ω  Dbug II
;
; Module de choix du langage courant. (1.0)
;
; 0-> Franáais
; 1-> Anglais
; 2-> Allemand
; 3-> *Espagnol
; 4-> *Italien 

 ifeq _main_part
 <pREMB_xxx.S>q doit àtre assemblÇ !!!
 END
 endc

 TEXT

choix_langue_franáais
 move #0,langue
 move #objet_menu_francais*24+ob_state+1,d0
 bra.s valide_langage

choix_langue_anglais
 move #1,langue
 move #objet_menu_anglais*24+ob_state+1,d0
 bra.s valide_langage

choix_langue_allemand
 move #2,langue
 move #objet_menu_allemand*24+ob_state+1,d0
 bra.s valide_langage

choix_langue_espagnol
 move #3,langue
 move #objet_menu_espagnol*24+ob_state+1,d0
 bra.s valide_langage

choix_langue_italien
 move #4,langue
 move #objet_menu_italien*24+ob_state+1,d0

valide_langage

 move.l ptr_hierarchique,a0
;
; On dÇselectionne toutes les langues
;
 bclr #2,objet_menu_francais*24+ob_state+1(a0)
 bclr #2,objet_menu_anglais*24+ob_state+1(a0)
 bclr #2,objet_menu_allemand*24+ob_state+1(a0)
 bclr #2,objet_menu_espagnol*24+ob_state+1(a0)
 bclr #2,objet_menu_italien*24+ob_state+1(a0)

 bset #2,(a0,d0.w)
 st flag_traduction
 rts


 
traduit_ressources
arf
 sf flag_traduction
 menu_bar ptr_menu_accessoires,#0	Efface la barre de menu
 
 move langue,d0			NumÇro de la langue
 
 lea convertir_ressources,a0
.formulaire_suivant 
 move.l (a0)+,a1		Adresse du pointeur sur le formulaire...
 cmp.l #0,a1			Si 0, c'est fini...
 beq.s .fin_traduction
 move.l (a1),a1			RÇcupäre l'adresse pointÇe...
.objet_suivant
 addq #1,a0			Alligne sur le mot suivant...
 move.l a0,d1
 bclr #0,d1
 move.l d1,a0
 move (a0)+,d1			NumÇro de l'objet
 cmp #-1,d1
 beq.s .formulaire_suivant
 moveq #0,d2			Langue numÇro 0
.chaine_suivante
 tst.b (a0)+			Si -1, on a atteint la fin de l'objet
 beq.s .objet_suivant
 subq #1,a0
 cmp d0,d2			C'est la bonne langue ???
 bne.s .parcours_chaine

;
; On modifie l'adresse du texte... mais il faut tester le type de 
; l'objet, pour connaitre la signification de OB_SPEC...
; G_TEXT(21),G_BOXTEXT(22),G_FTEXT(29),G_FBOXTEXT(30) -> Structure TEDINFO
; G_BUTTON(26),G_STRING(28),G_TITLE(32) -> Adresse du texte
;
 move (ob_type,a1,d1.w),d3	RÇcupäre le type de l'objet 
 cmp #26,d3
 beq.s .pointage_direct
 cmp #28,d3
 beq.s .pointage_direct
 cmp #32,d3
 beq.s .pointage_direct
.pointage_indirect
 move.l a0,([ob_spec,a1,d1.w])	Note la nouvelle adresse indirectement
 bra.s .parcours_chaine
 
.pointage_direct
 move.l a0,(ob_spec,a1,d1.w)	Note la nouvelle adresse directement

.parcours_chaine
 tst.b (a0)+
 bne.s .parcours_chaine
 addq #1,d2			Chaine suivante... 
 bra.s .chaine_suivante

.fin_traduction

 menu_bar ptr_menu_accessoires,#1	Affiche la barre de menu
 bsr retrace_ressource			Demande un redraw total...
 rts
