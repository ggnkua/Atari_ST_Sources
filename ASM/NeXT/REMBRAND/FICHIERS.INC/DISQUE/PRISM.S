;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                %
;% Format d'une image PRISM PAINT [*.PNT]         %
;% La taille de l'entete est de 128 octets.       %
;% +0  4 octets d'entete: 'PNT'+[Null]            %
;% +4  2 octets pour le num‚ro de version         %
;% +6  2 octets pour le nombre de couleurs        %
;% +8  2 octets pour largeur de l'image           %
;% +10 2 octets pour hauteur de l'image           %
;% +12 2 octets pour le nombre de plans           %
;% +14 2 octets pour le flag de compression       %
;% +16 4 octets pour la taille des datas          %
;% Le reste (54 octets) est … z‚ro                %
;%                                                %
;% Attention, les couleurs sont cod‚es sur un     %
;% intervalle VDI, soit de 0 … 1000 INCLUS.       %
;%                                                %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
 rsreset
prism_header	rs.l 1
prism_version	rs.w 1
prism_couleurs	rs.w 1
prism_largeur	rs.w 1
prism_hauteur	rs.w 1
prism_plans	rs.w 1
prism_compress	rs.w 1
prism_datas	rs.w 1

teste_image_tpi
teste_image_pnt
charge_image_true_paint
charge_image_prism_paint
gasp
 move.l buffer_fichier,a0
 cmp #'PN',(a0)+
 bne pas_format_prism_paint
 cmp #'T'<<8,(a0)+
 bne pas_format_prism_paint

 move.l buffer_fichier,a0

 tst prism_compress(a0)
 beq.s pas_compress‚_prism
 boite_alerte #1,#alert_prism_pack‚
 moveq #-1,d0
 rts
    
pas_compress‚_prism
 move prism_couleurs(a0),nombre_couleurs
 move prism_plans(a0),nombre_plans
  
 move prism_largeur(a0),d0
 add d0,d0
 move d0,largeur_image
 move prism_hauteur(a0),d0
 move d0,hauteur_image

 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement

**** On s'occuper de la palette

 tst nombre_couleurs
 beq pas_de_palette

 move.l buffer_fichier,a0	On recode la palette sur elle meme, sans
 lea 128(a0),a0			risquer de problŠme, puisque l'on passe
 move.l a0,adresse_palette	format en prenant seulement 2 par couleur !
 bsr.l recode_palette_vdi
 move nombre_couleurs,d0
 mulu #6,d0
 add.l d0,a0 
 move.l a0,adresse_image
 
**** Puis de l'image
 bra gozy
 move.l adresse_palette,a0	La palette TrueBidouill‚e !
 move.l adresse_image,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image
 lea 32(a2),a2			(On travaille par pas de 16 pixels !)
  
 move largeur_image,d7		Nombre de blocs de 16 pixels
 lsr #5,d7			(On … la largeur en MOTS)
 mulu hauteur_image,d7
.boucle_bloc
 movem.l (a1)+,d0-d3		8 mots sont charg‚s
 moveq #16-1,d5
.convert_bloc
 moveq #0,d4
 roxr d3
 addx d4,d4
 swap d3
 roxr d3
 addx d4,d4
 swap d3

 roxr d2
 addx d4,d4
 swap d2
 roxr d2
 addx d4,d4
 swap d2

 roxr d1
 addx d4,d4
 swap d1
 roxr d1
 addx d4,d4
 swap d1
 
 roxr d0
 addx d4,d4
 swap d0
 roxr d0
 addx d4,d4
 swap d0
 
 move (a0,d4.w*2),-(a2)
 dbra d5,.convert_bloc
 lea 64(a2),a2			16 pixels suivants dans l'image
 subq.l #1,d7
 bne .boucle_bloc
 moveq #0,d0
 rts

pas_format_prism_paint
 moveq #-1,d0
 rts


gozy
 move.l adresse_palette,a0	La palette TrueBidouill‚e !
 move.l adresse_image,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image

 move nombre_plans,d2
   
 move largeur_image,d4		Nombre de blocs de 16 pixels
 lsr #5,d4			(On … la largeur en MOTS)
 mulu hauteur_image,d4
.bloc_suivant

 moveq #16-1,d6			Il y … 16 pixels par bloc
.pixel_suivant
 move d2,d7			Le nombre de plans (de 1 … n)
 subq #1,d7
 moveq #0,d3			La couleur est mise … 0
.plan_suivant
 roxl.w (a1,d7.w*2)		Teste le bit
 addx d3,d3			M‚morise le bit
 dbra d7,.plan_suivant
 and #%11111111,d3
 move (a0,d3.w*2),(a2)+		Affiche le pixel
 dbra d6,.pixel_suivant

 lea (a1,d2.w*2),a1		Passe au bloc suivant (2*nombre de plans)

 subq.l #1,d4
 bne .bloc_suivant		Passe au multiple de 16 suivant...
 moveq #0,d0
 rts


pas_de_palette
 move.l buffer_fichier,a0	On recode la palette sur elle meme, sans
 lea 128(a0),a0			risquer de problŠme, puisque l'on passe
 move.l a0,adresse_image

 move.l adresse_image,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image

 move nombre_plans,d2
   
 move largeur_image,d4
 lsr d4				
 mulu hauteur_image,d4		Nombre de pixels de l'image
.bloc_suivant
 move (a1)+,(a2)+		Affiche le pixel
 subq.l #1,d4
 bne .bloc_suivant		Passe au multiple de 16 suivant...
 moveq #0,d0
 rts
