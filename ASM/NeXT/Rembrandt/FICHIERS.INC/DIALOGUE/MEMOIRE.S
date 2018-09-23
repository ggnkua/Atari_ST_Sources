; REMBRANDT 3.0 - ½  Dbug II
;
; Module d'affichage de l'occupation m‚moire. (1.0)
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

 
affiche_m‚moire
 move.l ptr_regle_memoire,adresse_formulaire
 clr premier_objet
 bsr affiche_formulaire
 bsr gere_formulaire
 bsr ferme_formulaire
 rts

; lea label_infos_m‚moire,a0
; move.l #'Libr',(a0)+
; move #'e:',(a0)+
; move.l memoire_libre,d0
; bsr inscrit_chaine
; move.l #'   |',(a0)+
; move.l #'Occu',(a0)+
; move.l #'p‚e:',(a0)+
; move.l memoire_occupe,d0
; bsr inscrit_chaine
; move.l #'   ]',(a0)+
; move.l #'[OK]',(a0)+ 
; clr.b (a0)+			Inscrit la chaine
; form_alert #1,#alert_infos_m‚moire
; rts



compose_infos_fenetre
 lea infos_fenetre,a0

 move.l #' nø',(a0)+		Num‚ro de l'image

 move.b #' ',(a0)+ 		Un espace vide

 lea nom_image,a1		Nom de l'image ‚dit‚e
 moveq #8-1,d0
.recopie_nom
 move.b (a1)+,d0
 beq .fin_inscription
 cmp.b #'.',d0
 beq .fin_inscription
 move.b d0,(a0)+
 dbra d0,.recopie_nom
.fin_inscription

 move.b #' ',(a0)+ 		Un espace vide

 moveq #0,d0
 move largeur_image,d0		La largeur de l'image
 lsr d0
 bsr inscrit_chaine

 move.b #'x',(a0)+ 		Le signe X … la place du z‚ro de fin de chaine

 moveq #0,d0
 move hauteur_image,d0		La hauteur de l'image
 bsr inscrit_chaine

 move #' ',(a0)+		Une flŠche
 move.b #' ',(a0)+
 
 move.l taille_image,d0		La hauteur de l'image
 bsr inscrit_chaine

 move.b #' ',(a0)+		Un espace vide

 move.l #'octe',(a0)+		Le mot 'octets'
 move #'ts',(a0)+

 clr.b (a0)+			Inscrit la chaine
  
 move.l	#infos_fenetre,int_in+4				Adresse de la chaine de caractŠres.
 wind_set handle_fen,#3					Modifie le titre
 rts


	DATA
	
alert_infos_m‚moire
 dc.b "[3][Informations m‚moire:|"
label_infos_m‚moire
 dcb 80,0

 BSS

 rsreset
image_bloc		rs.l 1		L'adresse de l'image (donn‚es)
image_largeur		rs.w 1		La largeur de l'image en octets
image_hauteur		rs.w 1		La hauteur
image_taille_image	rs.l 1		La taille (largeur*hauteur) en octets
image_nom		rs.b 8		Les 8 octets qui composent le nom
image_chemin		rs.b taille_chemin    Le chemin d'accŠs … l'image
image_taille_rs		rs.w 1

informations_image	ds.b image_taille_rs*maximum_image
