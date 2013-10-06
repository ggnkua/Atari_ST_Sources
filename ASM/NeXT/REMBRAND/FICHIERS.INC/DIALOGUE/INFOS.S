; REMBRANDT 3.0 - ½  Dbug II
;
; Module de r‚glage des informations sur l'image. (1.0)
;
; - On peut modifier le nom de l'image.
; - On dispose de trois lignes de 34 caractŠres pour des commentaires
;   concernant l'image, son auteur, etc...
; - Permet de choisir si l'image doit etre compact‚e ou non.
; - Permet de d‚cider si la palette doit etre int‚gr‚e … l'image
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

choix_informations_image
azer
 move.l ptr_info_image,adresse_formulaire
 bsr initialise_informations_image
 
 bsr affiche_formulaire
 bsr gere_formulaire

 move objet_exit,d0
 cmp #objet_inf_annule,d0
 beq .fin_informations_image

;
; Ce g‚nialissime morceau de code prend le nom qui a ‚t‚ tap‚ par
; l'utilisateur, et le recopie … la place du nom de fichier actuel.
; Il en profite pour remplacer les espaces par des '_' et convertie les
; caractŠres minuscules par des caractŠres majuscule...
; C'est cool non ? Surtout qu'il rajoute aprŠs l'ancienne extension,
; quelque soit la longueur initiale du nom...
;
 lea nom_image,a0
 moveq #9-1,d0			L'extension est dans les 9 1Šres places...
.cherche_extension
 cmp.b #'.',(a0)+
 dbeq d0,.cherche_extension
 cmp.b #'.',-(a0)
 beq.s .prends_extension
 moveq #0,d1			On met une extension vide.
 bra.s .fin_extension
.prends_extension
 move.l (a0),d1			Ancienne extension du fichier.
.fin_extension
 
 move.l ptr_info_image,a1
 
 move.l ([ob_spec+objet_inf_nom_image*24,a1]),a0	Adresse nom
 lea nom_image,a2
.recopie_nom
 move.b (a0)+,d0
 beq.s .fin_recopie
 cmp.b #' ',d0
 bne.s .recopie_car
 move.b #'_',(a2)+
 bra.s .recopie_nom
.recopie_car
 cmp2.b limites_alphabet,d0
 bcs.s .pas_minuscule
 sub #32,d0
.pas_minuscule
 move.b d0,(a2)+
 bra.s .recopie_nom
.fin_recopie
 move.l d1,(a2)+		Recopie l'extension … la fin
 clr.b (a2)+			Puis l'indispensable octet nul !

 move.l ptr_info_image,a0

 move.l ([ob_spec+objet_inf_texte_1*24,a0]),a1	Adresse texte_1
 move.l ([ob_spec+objet_inf_texte_2*24,a0]),a2	Adresse texte_2
 move.l ([ob_spec+objet_inf_texte_3*24,a0]),a3	Adresse texte_3
 move.l ([ob_spec+objet_inf_texte_4*24,a0]),a4	Adresse texte_4
 lea infos_texte,a5
 moveq #35-1,d0
.recopie_textes
 move.b (a4)+,105(a5)
 move.b (a3)+,70(a5)
 move.b (a2)+,35(a5)
 move.b (a1)+,(a5)+
 dbra d0,.recopie_textes

; move #objet_inf_packe_image*24,d0
; lea flag_compacter_image,a1
; bsr m‚morise_bouton
  
; move #objet_inf_sauv_palette*24,d0
; lea flag_sauver_palette,a1
; bsr m‚morise_bouton
  
.fin_informations_image
 bsr ferme_formulaire
 bsr compose_infos_fenetre		Met … jour la ligne d'infos !
 rts

*
* D'abord, il faut recopie toutes les informations qui doivent se trouver
* dans le formulaire:
* - Le nom du fichier
* - Les quatres chaines de caractŠres
* - Le bouton [compactage]
* - Le bouton [sauver la palette]
*
initialise_informations_image
 move.l ptr_info_image,a0

 move.l ([ob_spec+objet_inf_nom_image*24,a0]),a1	Adresse nom
 lea nom_image,a2
 moveq #8-1,d0			Le nom fait 8 caractŠres au maximum.
.recopie_nom
 move.b (a2)+,d0
 beq .fin_inscription
 cmp.b #'.',d0
 beq .fin_inscription
 move.b d0,(a1)+
 dbra d0,.recopie_nom
.fin_inscription
 clr.b (a1)+ 

 move.l ([ob_spec+objet_inf_texte_1*24,a0]),a1	Adresse texte_1
 move.l ([ob_spec+objet_inf_texte_2*24,a0]),a2	Adresse texte_2
 move.l ([ob_spec+objet_inf_texte_3*24,a0]),a3	Adresse texte_3
 move.l ([ob_spec+objet_inf_texte_4*24,a0]),a4	Adresse texte_4
 lea infos_texte,a5
 moveq #35-1,d0
.recopie_textes
 move.b 105(a5),(a4)+
 move.b 70(a5),(a3)+
 move.b 35(a5),(a2)+
 move.b (a5)+,(a1)+
 dbra d0,.recopie_textes
   
; move #objet_inf_packe_image*24,d0
; lea flag_compacter_image,a1
; bsr positionne_bouton
  
; move #objet_inf_sauv_palette*24,d0
; lea flag_sauver_palette,a1
; bsr positionne_bouton
 rts


 
 BSS

infos_texte 
infos_texte_1		ds.b 35
infos_texte_2		ds.b 35
infos_texte_3		ds.b 35
infos_texte_4		ds.b 35
