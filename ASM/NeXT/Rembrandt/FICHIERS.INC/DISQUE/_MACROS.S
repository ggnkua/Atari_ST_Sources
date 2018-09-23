; REMBRANDT 3.0 - ½  Dbug II
;
; Module contenant des routines globales pour les divers formats(1.0)
;
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc
 
 section TEXT

;
; OPTIMISATION PLACE:
; - depacke_rle (degas.s)       |
;   depacke_packbits (deluxe.s) | Routines trŠs similaires (mˆme m‚thode … 100%)...
;

; - recode_palette:
; nombre_couleurs+adresse_palette -> Palette TrueCod‚e
; > ART.S
; > CRACKART.S
; > DEGAS.S
;
; - copie_palette_image:
; flag_recopier_palette+adresse_palette -> Recopie la palette dans le s‚lecteur en
; fonction des pr‚f‚rences utilisateur
;
;- charge_format_16_couleurs
; allocation_palettes+adresse_image+fichier -> Convertie une image 4 plans vers TrueColor,
; en tenant compte ‚ventuellement de palettes multiples (rasters).
; > ART.S
; > CRACKART.S
; > DEGAS.S
;
; - recode_palette_vdi:
; nombre_couleurs+adresse_palette -> Palette TrueCod‚e
; > PRISM.S
; > _RIM.S

recode_palette
 movem.l d0-a6,-(sp)
 move.l adresse_palette,a0	Palette standard STF
 lea table_ste,a1		Table de conversion des couleurs STE
 move nombre_couleurs,d7	
 subq #1,d7
.convert_palette 		
 move (a0),d0			Couleur RVB d'origine

 move d0,d1
 and #15,d1			BLEU -> D1
 move.b (a1,d1),d1
 lsl #1,d1			4 bits vers 5 bits
  
 lsr #4,d0
 move d0,d2
 and #15,d2			VERT -> D2
 move.b (a1,d2),d2
 lsl #2,d2			4 bits vers 6 bits

 lsr #4,d0
 move d0,d3
 and #15,d3			ROUGE -> D3
 move.b (a1,d3),d3
 lsl #1,d3			4 bits vers 5 bits

 move d3,d4
 lsl #6,d4			D‚calle rouge
 or d2,d4
 lsl #5,d4			D‚calle rouge+vert
 or d1,d4
 move d4,(a0)+
 dbra d7,.convert_palette 
 movem.l (sp)+,d0-a6
 rts


copie_palette_image
 tst.b flag_recopier_palette
 beq.s .fin_recopie
 move.l adresse_palette,a0
 lea couleurs_palette,a1	La palette du s‚lecteur
 move nombre_couleurs,d7	
 beq.s .fin_recopie
 subq #1,d7
 and #255,d7			Au maximum, 256 couleurs (Spectrum...)
.recopie_palette
 move (a0)+,(a1)+
 dbra d7,.recopie_palette
.fin_recopie
 rts
 

charge_format_16_couleurs
 lea allocation_palettes,a0	*Liste des adresses des palettes
 move.l adresse_image,a1	L'image … convertir
 move.l fichier,a2		Le buffer pour stocker l'image
 lea 32(a2),a2			(On travaille par pas de 16 pixels !)
  
 move.l (a0)+,a3		PremiŠre palette  palette courante

 move largeur_image,d0
 lsr #5,d0
 subq #1,d0
 move d0,a4			Nombre de blocs de 16 pixels affichables
 
 move hauteur_image,d7		Hauteur de l'image (200 lignes pour ST BASSE)
 subq #1,d7
.boucle_ligne
 move a4,d6			Nombre de blocs de 16 pixels … d‚coder...
.convert_ligne
 movem (a1)+,d0-d3		Charge le groupe en m‚moire
 moveq #16-1,d5			*16 pixels par bloc
.convert_bloc
 moveq #0,d4
 roxr d3
 addx d4,d4
 roxr d2
 addx d4,d4
 roxr d1
 addx d4,d4
 roxr d0
 addx d4,d4
 move (a3,d4.w*2),-(a2)
 dbra d5,.convert_bloc
 lea 64(a2),a2			16 pixels suivants dans l'image
 dbra d6,.convert_ligne
 add offset_r‚siduel,a1		Pour les octets en fin de ligne...
 move.l (a0)+,d0		Adresse nulle ???
 beq .conserve_palette
 move.l d0,a3			Non, alors prends comme nouvelle palette
.conserve_palette
 dbra d7,.boucle_ligne
 rts


;
; On recode la palette sur elle meme, sans
; risquer de problŠme, puisque l'on passe d'un
; format occupant 6 octets par couleur, vers un
; autre n'en prenant que 2...
;
; Ensuite, on recr‚e une seconde palette … la suite,
; mais avec l'ordre Shifter au lieu de l'ordre VDI.
;
recode_palette_vdi
 movem.l d0-a6,-(sp)
 move.l adresse_palette,a0
 move.l a0,a1
 move nombre_couleurs,d7
 subq #1,d7
.recopie_palette
 movem (a0)+,d0-d2
 mulu.l #31,d0
 divu.l #1000,d0		R‚cupŠre le rouge sur [0-31]
 mulu.l #63,d1
 divu.l #1000,d1		R‚cupŠre le vert sur [0-63]
 mulu.l #31,d2
 divu.l #1000,d2		R‚cupŠre le bleu sur [0-31]
 lsl #5,d1			Repositionne le vert au centre
 or d1,d2
 ror #5,d0			Et met le rouge … gauche
 or d0,d2
 move d2,(a1)+
 dbra d7,.recopie_palette
* movem.l (sp)+,d0-a6
* rts

; A0 pointe sur la palette initiale
; A1 pointe sur la palette … suivre
;
 move.l adresse_palette,a0
 move.l a1,adresse_palette
 lea tables_vdi-4,a2
 move nombre_plans,d0
 move.l (a2,d0.w*4),a2		R‚cupŠre la bonne table
 move nombre_couleurs,d7
 subq #1,d7
.retrie_palette
 move (a0)+,d0			La couleur
 move (a2)+,d1			L'index
 move d0,(a1,d1.w*2)		Remet la couleur l… ou il le faut...
 dbra d7,.retrie_palette
 
 movem.l (sp)+,d0-a6
 rts

 DATA
 
table_ste	dc.b 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15

tables_vdi
 dc.l table_vdi_2	1 plan
 dc.l table_vdi_4	2 plans
 dc.l table_vdi_4		3 plans	* Inexistant
 dc.l table_vdi_16	4 plans
 dc.l table_vdi_16		5 plans * Inexistant
 dc.l table_vdi_16		6 plans	* Inexistant
 dc.l table_vdi_16		7 plans * Inexistant
 dc.l table_vdi_256	8 plans


table_vdi_2
 dc.w 0,1
table_vdi_4
 dc.w 0,3,1,2
table_vdi_16
 dc.w 0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
* dc.w 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,1
table_vdi_256
 dc.w 0,255,1,2,4,6,3,5,7,8,9,10,12,14,11,13
 dc.w 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 dc.w 32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47
 dc.w 48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63
 dc.w 64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
 dc.w 80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
 dc.w 96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111
 dc.w 112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
 dc.w 128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143
 dc.w 144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159
 dc.w 160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175
 dc.w 176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
 dc.w 192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207
 dc.w 208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223
 dc.w 224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239
 dc.w 240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,15

 BSS
 
offset_r‚siduel	ds.w 1
