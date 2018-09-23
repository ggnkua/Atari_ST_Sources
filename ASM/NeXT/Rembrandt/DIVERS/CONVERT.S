*
*
* Petite routine … la con destin‚e a convertir une image
* DEGAS en image TRUE COLOR
*
*
deb
 opt o+
 
image_degas	dc.l "DBUG"
buffer		dc.l "NEXT"

;
; Avant tout, on commence par triturer la palette pour qu'elle soit plus
; rapide … valider.
;
 lea 2+image_degas(pc),a0
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
 lsl d4
 move d4,(a0)+
 dbra d7,convert_palette 

;
; Maintenant, on s'occupe de l'image.
; 
 
 lea 2+image_degas(pc),a0	La palette
 lea 32(a0),a1			L'image … convertir
 lea buffer(pc),a2 		Le buffer pour stocker l'image

 move #4000-1,d7
convert_image 
 movem (a1)+,d0-d3
 moveq #16-1,d6
convert_bloc
 roxr d0
 roxl d4
 roxr d1
 roxl d4
 roxr d2
 roxl d4
 roxr d3
 roxl d4
 and #15,d4
 move (a0,d4*2),(a2)+ 
 dbra d6,convert_bloc
 dbra d7,convert_image
 rts

fin