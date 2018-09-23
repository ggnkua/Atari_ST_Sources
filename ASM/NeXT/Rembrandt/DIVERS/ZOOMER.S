*
*
* Petite routine … la con destin‚e a convertir une image
* DEGAS en image TRUE COLOR
*
*
 opt o+,w+

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
 pea ecran
 pea ecran
 move #5,-(sp)
 trap #14
 add #14,sp

 bsr convert_image

*
* On bidouille le cache
*
 movec cacr,d0
 move d0,sauve_cache
 bclr #11,d0	Clear data cache
 bclr #9,d0	Not Freeze data cache
 bset #8,d0	Enable data cache

 bset #3,d0	Clear instruction cache
 bclr #1,d0	Not Freeze instruction cache
 bset #0,d0	Enable instruction cache
 movec d0,cacr

 move #0,x_souris
 move #0,y_souris
 bsr zoome_image

 movec cacr,d0
 bset #1,d0	Freeze instruction cache
 movec d0,cacr

 bsr affiche_image

attend_touche
 dc.w $a000
 move -602(a0),x_souris
 move -600(a0),y_souris
 tst.w -596(a0)
 bne fin_boucle

 move #$7000,$ffff9800.w
 bsr zoome_image
* bsr trace_ligne
 move #-1,$ffff9800.w

 move #37,-(sp)
 trap #14
 addq #2,sp
 
 bra attend_touche

fin_boucle

;
; Restaure tout
; 
 move old_video,-(sp)
 move #3,-(sp)
 move.l old_adresse,-(sp)
 move.l old_adresse,-(sp)
 move #5,-(sp)
 trap #14
 add #14,sp

 move sauve_cache,d0
 movec d0,cacr
 rts
 
 



convert_image
;
; Avant tout, on commence par triturer la palette pour qu'elle soit plus
; rapide … valider.
;
 lea 2+image_degas,a0
 moveq #16-1,d7
convert_palette 
 move (a0),d0

 move d0,d1
 and #15,d1

 lsr #4,d0
 move d0,d2
 and #15,d2

 lsr #4,d0
 move d0,d3
 and #15,d3 

 move d3,d4
 lsl #5,d4
 or d2,d4
 lsl #6,d4
 or d1,d4
 lsl #2,d4
 move d4,(a0)+
 dbra d7,convert_palette 

;
; Maintenant, on s'occupe de l'image.
; 
 
 lea image_degas+2,a0	La palette
 lea 32(a0),a1		L'image … convertir
 lea buffer+32,a2	Le buffer pour stocker l'image
 
 move #4000-1,d7
.convert_image 
 movem (a1)+,d0-d3
 moveq #0,d4
 moveq #16-1,d6
.convert_bloc
 roxr d3
 roxl d4
 roxr d2
 roxl d4
 roxr d1
 roxl d4
 roxr d0
 roxl d4
 and #15,d4
 move (a0,d4*2),-(a2)
 dbra d6,.convert_bloc
 lea 64(a2),a2
 dbra d7,.convert_image
 rts

affiche_image
 lea buffer,a0
 lea ecran,a1
 move #128000/4-1,d7
boucle_affiche
 move.l (a0)+,(a1)+
 dbra d7,boucle_affiche 
 rts


x=60
y=50
f=3

zoome_image
 lea buffer,a0
 move x_souris,d0
 add d0,d0
 add d0,a0
 move y_souris,d0
 mulu #640,d0
 add.l d0,a0
 move #640,d1
 
 lea ecran,a1
 moveq #y-1,d7
zoome_y
 moveq #f-1,d4
zoom_yy 
 move.l a0,a2
 move.l a1,a3

 moveq #x-1,d6
zoome_x
 move.w (a2)+,d0
 move d0,(a3)+
 move d0,(a3)+
 move d0,(a3)+
 dbra d6,zoome_x
 
 lea 640(a1),a1
 dbra d4,zoom_yy
 lea 640(a0),a0
 dbra d7,zoome_y
 rts
 
trace_ligne
 rts
  
 section DATA 

image_degas	incbin D:\GRAPHES\<_IMAGES.__>\DEGAS\FONTE_2.PI1

 section BSS

old_video	ds.w 1 
old_adresse	ds.w 1
buffer		ds.l 128000/4
ecran		ds.l 128000/4
x_souris	ds.w 1
y_souris	ds.w 1
sauve_cache	ds.w 1

 end
 
 