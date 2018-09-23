; REMBRANDT 3.0 - ½  Dbug II
;
; Module de r‚glage des pr‚f‚rences. (1.1)
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

choix_parametre_preferences
 move.l ptr_preference,adresse_formulaire
 clr premier_objet
 bsr affiche_formulaire
 bsr gere_formulaire

 cmp #objet_non_preferences,objet_exit
 beq .ignore_param‚trages

;
; On a click‚ soit sur CONFIRMER soit sur SAUVER.
; Dans les deux cas, on valide les param‚trages choisis.
;
 move.l ptr_preference,a0		Pointeur sur le formulaire

 move #objet_pref_shrink_box*24,d0	Valider les grow/shrink box
 lea flag_shrink_box,a1			Le drapeau qui correspond
 bsr m‚morise_bouton 

 move #objet_pref_maj_palette*24,d0	Mettre … jour la palette au chargement
 lea flag_recopier_palette,a1
 bsr m‚morise_bouton 

; move #objet_pref_utilise_rim*24,d0
; lea flag_utiliser_rim,a1
; bsr m‚morise_bouton 

.fin_param‚trage

.ignore_param‚trages
 bsr ferme_formulaire
 rts
 