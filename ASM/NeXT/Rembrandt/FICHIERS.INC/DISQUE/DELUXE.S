;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                    %
;% Format d'une image Interchange File Format [*.IFF] %
;%                                                    %
;% AMIGA:         FORM-ILBM BMHD-CMAP-CRNG-CAMG-BODY  %
;% NEO (normale): FORM-ILBM BMHD-CMAP-BODY            %
;% NEO (rasters): FORM-ILBM BMHD-BODY-RAST            %
;%                                                    %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; - Les formats sp‚cifiques a l'Amiga tels que le HAM6 (4096 couleurs) et
; le EHB (64 couleurs) sont charg‚s correctement.
; - Il est possible de lire les images en 256 couleurs.
; - La routine accepte les images contenant des rasters (NeoMaster)
; - Les images peuvent etre compact‚es en mode PackBit [Le compactage
; vertical ne fonctionne pas].
;

 rsreset
form_type_fichier	rs.l 1 Type de fichier (ILBM-8SVX-SMUS-FTXT)

 rsreset
bmhd_x_image		rs.w 1 Largeur de l'image en pixels
bmhd_y_image		rs.w 1 Hauteur de l'image en pixels
bmhd_x_offset		rs.w 1 Offset x (0)
bmhd_y_offset		rs.w 1 Offset Y (0)
bmhd_plans		rs.b 1 Nombre de plans graphiques
bmhd_masque		rs.b 1 Masque (0=absent/1=impl‚ment‚/2=transparent/3=lasso)
bmhd_pack‚		rs.b 1 Si comprim‚ (1) sinon (0)
bmhd_inutile		rs.b 1 Inutile (0)
bmhd_transparent	rs.w 1 Couleur transparente si masque=2
bmhd_x_aspect		rs.b 1 Proportions (5=640x200/10=320x200/640x400/20=320x400)
bmhd_y_aspect		rs.b 1 (11) ???
bmhd_l_image		rs.w 1 Largeur d'image (=x_image)
bmhd_h_image		rs.w 1 Hauteur d'image (=y_image)

 rsreset
cmap_couleur_0		rs.b 3 Premier triplet RVB
cmap_couleur_1		rs.b 3 Premier triplet RVB
cmap_couleur_2		rs.b 3 Triplet RVB
cmap_couleur_3		rs.b 3 Triplet RVB
cmap_couleur_4		rs.b 3 Triplet RVB
cmap_couleur_5		rs.b 3 Triplet RVB
cmap_couleur_6		rs.b 3 Triplet RVB
cmap_couleur_7		rs.b 3 Triplet RVB
cmap_couleur_8		rs.b 3 Triplet RVB
cmap_couleur_9		rs.b 3 Triplet RVB
cmap_couleur_10		rs.b 3 Triplet RVB
cmap_couleur_11		rs.b 3 Triplet RVB
cmap_couleur_12		rs.b 3 Triplet RVB
cmap_couleur_13		rs.b 3 Triplet RVB
cmap_couleur_14		rs.b 3 Triplet RVB
cmap_couleur_15		rs.b 3 Triplet RVB

 rsreset
crng_reserv‚		rs.w 1 (0)
crng_vitesse		rs.w 1 Vitesse de cycling (16384=60 images/sec)
crng_premiŠre		rs.b 1 PremiŠre couleur … animer
crng_derniŠre		rs.b 1 DerniŠre couleur … animer

 rsreset
camg_video		rs.l 1
;
; On ne prend que le mot de poids faible:
;
; bit 2		-> ???
; bit 3		-> Mode entrelac‚
;
; bit 10	-> Mode Extra Half Bright
; bit 11	-> Mode HAM
;
; bit 14	-> ???
; bit 15	-> ???

 rsreset
body_image		rs.b 32000 L'image elle meme (32000 octets....)

 rsreset
rast_			rs.l 1 Longueur du chunk raster ???


 TEXT
 
teste_image_deluxe
charge_image_iff
pez 
 move.l buffer_fichier,a0	Image source
 cmp.l #"FORM",(a0)+		C'est pas de l'IFF
 bne erreur_format_chargement
 
 move.l (a0)+,taille_form	Permet de stopper le d‚codage … temps.
 move.l a0,adresse_form		D‚but des donn‚es du fichier IFF.
 
 cmp.l #"ILBM",(a0)+		C'est p'tet de l'IFF, mais pas graphique !!!
 bne erreur_format_chargement
 cmp.l #"BMHD",(a0)+		Et il faut un entete...
 bne erreur_format_chargement

 move.l (a0)+,taille_chunk	Longueur du chunk.

 move bmhd_x_image(a0),d0	Largeur de l'image en pixels
 move d0,nombre_colonnes
 add d0,d0
 move d0,largeur_image
  
 move bmhd_y_image(a0),d1	Hauteur de l'image en pixels
 move d1,nombre_lignes
 move d1,hauteur_image

 mulu d1,d0
 move.l d0,taille_image 

 move.l a0,-(sp)
 lea buffer_d‚packing,a0	On fait un buffer de la taille de l'image !
 bsr.l r‚serve_bloc
 move.l (sp)+,a0
 bmi erreur_m‚moire_d‚packing
 
 move.l buffer_d‚packing,a1		Image d‚cod‚e

 moveq #0,d0
 move.b bmhd_plans(a0),d0
 move d0,nombre_plans

 moveq #2,d1
 subq #1,d0
 lsl d0,d1
 move d1,nombre_couleurs

 move nombre_colonnes,d0		Largeur en pixels...
 lsr #3,d0				.../8
 mulu nombre_plans,d0			xNombre de plans = Taille de la ligne en octets
 move d0,largeur_ligne
 divu nombre_plans,d0			-> Nombre d'octets par plan !

****>>>>
arrondie_sup‚rieur
 move d0,d1
 lsl #3,d1				x8 -> Nombre de bits
 cmp nombre_colonnes,d1
 beq.s .ok_exact
 addq #1,d0				On ajoute un octet !
.ok_exact 
****<<<<
 move d0,largeur_plan

 sf flag_packed			Teste si l'image est compact‚e.
 tst.b bmhd_pack‚(a0)
 beq .pas_pack‚e
 st flag_packed
.pas_pack‚e
  
 sf chunk_map		Flag qui indique les chunks ex‚cut‚s (1->BODY 2->CMAP 3->RAST)
 
.chunk_suivant
 add.l taille_chunk,a0		Saute sur le chunk suivant
 
 move.l a0,d0			V‚rifie si le d‚codage est termin‚.
 btst #0,d0			Mais, un chunk peut avoir une longueur
 beq.s .adresse_paire		impaire... (Gasp)
 addq #1,a0
 move.l a0,d0
.adresse_paire 

 sub.l adresse_form,d0		DŠs que l'on a atteint le dernier chunk
 cmp.l taille_form,d0		on se casse !
 bge.s fin_chunck
  
 move.l (a0)+,d0		CHUNK courant
 move.l (a0)+,taille_chunk	Taille du chunk
 lea on_gosub_chunk,a6
.cherche_chunk_suivant
 move.l (a6)+,d1  		CHUNK analys‚
 move.l (a6)+,a5		et routine associ‚e
 cmp.l #-1,d1
 beq.s .chunk_suivant
 cmp.l d0,d1
 bne.s .cherche_chunk_suivant 
 pea (a0)
 jsr (a5)
 move.l (sp)+,a0
 bra .chunk_suivant
 
fin_chunck   
 cmp.b #3,chunk_map		BODY+CMAP ?
 beq ok_iff_charg‚  
 cmp.b #5,chunk_map		BODY+RAST ?
 beq ok_iff_charg‚  
 cmp.b #7,chunk_map		BODY+CMAP+RAST ?
 beq ok_iff_charg‚  
 jmp chunk_manquant		Non, alors va voir ailleurs !!!
   
ok_iff_charg‚  
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 moveq #2,d0
 bsr affiche_formulaire_chargement
 bsr charge_format_n_couleurs	Si c'est bon, on affiche... (Arg, gasp...)
 moveq #0,d0
 rts

charge_format_n_couleurs
 tst.b flag_ham
 bne charge_format_ham

 tst.b flag_ehb
 beq.s .pas_palette_ehb
.compose_palette_ehb
 move.l adresse_palette,a1
 lea 64(a1),a2
 moveq #32-1,d7
.d‚code_palette_iff_ehb
 move (a1)+,d0				R‚cupŠre la couleur
 lsr d0
 and #%0111101111101111,d0		Assombrissement
 move d0,(a2)+				M‚morise la couleur
 dbra d7,.d‚code_palette_iff_ehb
.pas_palette_ehb

 lea allocation_palettes,a0	*Liste des adresses des palettes
 move.l adresse_image,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image

 move largeur_plan,d2
 mulu nombre_plans,d2		Offset de longueur de ligne

 move.l (a0)+,a3		PremiŠre palette  palette courante
 
 move hauteur_image,d5   
 subq #1,d5
.ligne_suivante

 move nombre_colonnes,d1	D‚compteur de pixels...
 
 move.l a1,a4			D‚but de la ligne
 
 move largeur_plan,d4		Nombre d'octets dans le plan
 subq #1,d4
.octet_suivant

 moveq #8-1,d6			8 bits par octet
.bit_suivant

 lea (a4,d2.l),a5		D‚but de l'octet
 move nombre_plans,d7
 subq #1,d7
 moveq #0,d3			La couleur est mise … 0
.plan_suivant
 sub largeur_plan,a5		Passe au plan suivant
 move.b (a5),d0
 addx.b d0,d0			Teste le bit
 move.b d0,(a5)
 addx d3,d3			M‚morise le bit
 dbra d7,.plan_suivant

 move (a3,d3.w*2),(a2)+		Affiche le pixel
 subq #1,d1
 beq.s .saute_ligne_suivante
 dbra d6,.bit_suivant

 addq #1,a4			Passe … l'octet suivant.
 dbra d4,.octet_suivant

.saute_ligne_suivante
 add.l d2,a1			Passe … la ligne suivante
 
 move.l (a0)+,d0		Adresse nulle ???
 beq .conserve_palette
 move.l d0,a3			Non, alors prends comme nouvelle palette
.conserve_palette
 dbra d5,.ligne_suivante
 rts


charge_format_ham
aqw
 lea allocation_palettes,a0	*Liste des adresses des palettes
 move.l adresse_image,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image

 move largeur_plan,d2
 mulu nombre_plans,d2		Offset de longueur de ligne

 move.l (a0)+,a3		PremiŠre palette  palette courante
 
 move hauteur_image,d5   
 subq #1,d5
.ligne_suivante

 move nombre_colonnes,d1	D‚compteur de pixels...
 
 move.l a1,a4			D‚but de la ligne
 
 move largeur_plan,d4		Nombre d'octets dans le plan
 subq #1,d4
.octet_suivant

 moveq #8-1,d6			8 bits par octet
.bit_suivant

 lea (a4,d2.l),a5		D‚but de l'octet
 move nombre_plans,d7
 subq #1,d7
 moveq #0,d3			La couleur est mise … 0
.plan_suivant
 sub largeur_plan,a5		Passe au plan suivant
 move.b (a5),d0
 addx.b d0,d0			Teste le bit
 move.b d0,(a5)
 addx d3,d3			M‚morise le bit
 dbra d7,.plan_suivant
** d3 contient une valeur sur 6 bits:
*
* xxyyyy
* avec xx: 00 -> Couleur n0 %yyyy de la palette
*          01 -> Couleur du point pr‚c‚dent avec %yyyy de bleu
*          10 -> Couleur du point pr‚c‚dent avec %yyyy de rouge
*          11 -> Couleur du point pr‚c‚dent avec %yyyy de vert
*
 move d3,d0
 lsr #4,d0
 cmp #%00,d0
 beq.s .cas_couleur
 cmp #%01,d0
 beq.s .cas_bleu
 cmp #%10,d0
 beq.s .cas_rouge
 cmp #%11,d0
 beq.s .cas_vert
 bra.s .azerty
  
.cas_vert
 and #%1111100000011111,couleur_ham
 lsl #7,d3
 and #%0000011110000000,d3
 or d3,couleur_ham
 bra.s .affiche_point

.cas_rouge
 and #%0000011111111111,couleur_ham
 ror #4,d3
 and #%1111100000000000,d3
 or d3,couleur_ham
 bra.s .affiche_point

.cas_bleu  
 and #%1111111111100000,couleur_ham
 add d3,d3
 and #%0000000000011110,d3
 or d3,couleur_ham
 bra.s .affiche_point

.cas_couleur
 and #15,d3
 move (a3,d3.w*2),couleur_ham
 bra.s .affiche_point
 
.affiche_point 
 move couleur_ham,(a2)+			Affiche le pixel
 subq #1,d1
 beq.s .saute_ligne_suivante
 dbra d6,.bit_suivant

 addq #1,a4			Passe … l'octet suivant.
 dbra d4,.octet_suivant

.saute_ligne_suivante
 add.l d2,a1			Passe … la ligne suivante
 
 move.l (a0)+,d0		Adresse nulle ???
 beq .conserve_palette
 move.l d0,a3			Non, alors prends comme nouvelle palette
.conserve_palette
 dbra d5,.ligne_suivante
.azerty
 rts

couleur_ham	ds.w 1

; En entr‚e:
; A0 -> Source plan par plan pack‚e ou non
; A1 -> [buffer de d‚packing]

traite_iff_body
ifff
 bset #0,chunk_map

 tst.b flag_packed
 bne  depacke_packbits

.image_non_pack‚e
 move.l a0,adresse_image
 rts
	
depacke_packbits
zap
 moveq #1,d0
 bsr affiche_formulaire_chargement

 move.l a1,adresse_image

 move.l a0,a2
 add.l taille_chunk,a2

.boucle_d‚packing
 move.b (a0)+,d0
 blt.s .n‚gatif
 ext d0
.recopie_octets
 move.b (a0)+,(a1)+
 dbra d0,.recopie_octets
 cmpa.l a2,a0
 ble.s .boucle_d‚packing
 bra.s .fin_d‚packing

.n‚gatif
 cmp.b #-128,d0
 beq.s .fin_controle
 ext d0
 neg d0
 move.b (a0)+,d1
.duplique_octet
 move.b d1,(a1)+
 dbra d0,.duplique_octet

.fin_controle
 cmpa.l a2,a0
 ble.s .boucle_d‚packing

.fin_d‚packing
 bsr.l ferme_formulaire
 rts



traite_iff_cmap
 bset #1,chunk_map
 move.l a0,a2
 move.l a2,adresse_palette
 move.l a2,allocation_palettes
 move.l taille_chunk,d7
 subq #1,d7
.d‚code_palette_iff
 moveq #0,d0
 move.b (a0)+,d0	R‚cupŠre le rouge
 lsl #8,d0		Cadre … gauche
 and #%1111100000000000,d0
 moveq #0,d1
 move.b (a0)+,d1	Charge le vert
 lsl #3,d1
 and #%0000011111100000,d1
 or d1,d0 
 moveq #0,d1
 move.b (a0)+,d1	Charge le bleu
 lsr #3,d1
 and #%0000000000011111,d1
 or d1,d0
 move d0,(a2)+		Sauve la couleur en codage 16 bits RVB
 subq.l #3,d7
 bgt.s .d‚code_palette_iff
 rts


*  2 -> Mode entrelac‚ (double vertical)
*  7 -> Mode extra half bright (64 couleurs)
* 11 -> Mode hold and modify
* 12 -> ???
* 14 -> ???
*
traite_iff_camg
 move.l camg_video(a0),d0

 btst #7,d0
 sne flag_ehb

 btst #11,d0
 sne flag_ham
 rts


traite_iff_rast
 bset #2,chunk_map

 lea allocation_palettes,a1
 move.l taille_chunk,d7
 
.raster_suivant
 move (a0)+,d0			Num‚ro de la ligne 
 move.l a0,(a1,d0*4)		Adresse de la palette dans le buffer
 move.l a0,adresse_palette
 movem.l d0-a6,-(sp)
 bsr recode_palette
 movem.l (sp)+,d0-a6
 lea 32(a0),a0
 sub.l #34,d7
 bpl .raster_suivant
 rts

 even
 
on_gosub_chunk
 dc.l "BODY"
 dc.l traite_iff_body
 dc.l "CMAP"
 dc.l traite_iff_cmap
 dc.l "RAST"
 dc.l traite_iff_rast
 dc.l "CAMG"
 dc.l traite_iff_camg
 dc.l -1,-1
 
chunk_manquant
 boite_alerte #1,#alert_manque_chunk
 moveq #-1,d0
 rts

compactage_iff_inconnu
 boite_alerte #1,#alert_compactage_inconnu
 moveq #-1,d0
 rts

 BSS
 
adresse_form			ds.l 1	Adresse de d‚but des donn‚es (IFF)
taille_form			ds.l 1	Taille des donn‚es (IFF)
taille_chunk			ds.l 1	Taille du chunk courant (IFF)
flag_ham			ds.w 1
flag_ehb			ds.w 1

chunk_map			ds.w 1	Champ de bits indiquant la pr‚sence des CHUNKS.
  