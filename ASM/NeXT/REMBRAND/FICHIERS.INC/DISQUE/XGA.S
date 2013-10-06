 TEXT
 
teste_image_xga
charge_image_xga
 lea liste_param‚trage_xga,a0
.texte_format_xga
 move.l (a0)+,d0		Taille
 beq erreur_format_chargement
 move (a0)+,d1			Largeur
 move (a0)+,d2			Hauteur
 cmp.l taille_fichier,d0
 bne .texte_format_xga

 add d1,d1
 move d1,largeur_image
 move d2,hauteur_image  
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement

 move.l buffer_fichier,a0	D‚but du fichier charg‚
 move.l fichier,a1		Destination dans le buffer d'image
 move largeur_image,d0
 mulu hauteur_image,d0		On a le nombre d'octets … recopier
 move.l d0,taille_image
 lsr.l d0
.boucle_recopie_image
 move (a0)+,(a1)+
 subq.l #1,d0
 bne.s .boucle_recopie_image
 moveq #0,d0
 rts
   
* Dans l'ordre, nous avons la taille du fichier en octets, suivi de la
* largeur et de la hauteur de l'image qui correspond. Vu que le format
* XGA n'a pas d'entete, il faut rep‚rer le format en fonction de la
* taille de l'image !

 DATA
 
liste_param‚trage_xga
 dc.l 884736
 dc.w 768,576

 dc.l 737280
 dc.w 768,480

 dc.l 614400
 dc.w 640,480

 dc.l 368640
 dc.w 384,480

 dc.l 307200
 dc.w 320,480

 dc.l 442368
 dc.w 384,576

 dc.l 128000
 dc.w 320,200

 dc.l 0
 dc.l 0
