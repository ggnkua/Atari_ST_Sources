debug=0
*
*
* Routine pour tester des effets en TrueColor
* Les effets sont dans des fichiers .S:
*
* NEGATIF.S	-> N‚gativer l'image
* LUMIERE.S	-> Assombrir ou claircir l'image
* 
;
;
; Quelques constantes pour les modes vid‚os
;
;
col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256

mode=coltc+l40+tv+pal

 pea superviseur
 move #$26,-(sp)
 trap #14
 addq #6,sp
;
; Et quitte
; 
 clr -(sp)
 trap #1



 
superviseur 
 move.l #ecran+4,d0
 and #$ffff-3,d0
 move.l d0,‚cran
 ifeq debug
;
; R‚cupŠre la r‚solution courante et l'adresse de la m‚moire
; vid‚o
;
 move #-1,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 move d0,old_video
 
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,old_adresse

;
; Valide ma propre r‚solution
; et mon propre ecran
; 
 move #mode,-(sp)
 move #3,-(sp)
 move.l ‚cran,-(sp)
 move.l ‚cran,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc

 bsr affiche_image
 bsr traite_image

 move #7,-(sp)
 trap #1
 addq #2,sp
 nop
  
;
; Restaure tout
; 
 ifeq debug
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp
 endc
 rts

affiche_image
 bsr recode_palette
 bsr convertir_image
 bsr copie_image
 rts

copie_image
 move.l ‚cran,a0
 lea copie,a1
 lea copie_2,a2
 move #128000/4-1,d7
.recopie 
 move.l (a0),(a1)+
 move.l (a0)+,(a2)+
 dbra d7,.recopie 
 rts
 
convertir_image
 lea image+2,a0			La palette de l'image
 lea image+34,a1		Le buffer pour stocker l'image
 move.l ‚cran,a2		L'image … convertir
 lea 32(a2),a2			(On travaille par pas de 16 pixels !)

 move #200-1,d7			200 lignes dans une image
.boucle_ligne
 move #20-1,d6			20 groupes de mots par ligne
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
 move (a0,d4.w*2),-(a2)
 dbra d5,.convert_bloc
 lea 64(a2),a2			16 pixels suivants dans l'image
 dbra d6,.convert_ligne
 dbra d7,.boucle_ligne
 rts

recode_palette
 lea image+2,a0			Palette standard STF
 lea table_ste,a1		Table de conversion des couleurs STE
 moveq #16-1,d7	
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
 rts

table_ste
 dc.b 0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15

 
traite_image
 include g_flou.s
 rts
 
 section DATA 

image	incbin D:\GRAPHES\<_IMAGES.__>\DEGAS\FREYDA6.PI1
undo	incbin D:\GRAPHES\<_IMAGES.__>\DEGAS\FREYDA6.PI1

largeur_image	dc.w 320*2
hauteur_image	dc.w 200
taille_image	dc.l 320*200*2

fichier		dc.l copie
‚cran_undo	dc.l copie_2

 section BSS

couleur		ds.w 1
‚cran		ds.l 1

old_video	ds.w 1 
old_adresse	ds.w 1
x_souris	ds.w 1
y_souris	ds.w 1

 ds.l 10000
ecran		ds.l 128000/4
copie		ds.l 128000/4
copie_2		ds.l 128000/4
 ds.l 10000

 end
 