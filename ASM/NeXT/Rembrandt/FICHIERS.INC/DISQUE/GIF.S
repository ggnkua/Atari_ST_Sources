 text
teste_image_gif 
charge_image_gif
gif
 move.l buffer_fichier,a0

 cmp.l #'GIF8',(a0)+		Si l'entete n'est pas le message
 bne erreur_format_chargement	ÆGIF87aØ, alors on se casse...
 cmp #'9a',(a0)+
 beq.s .ok_gif
 cmp #'7a',-2(a0)
 bne erreur_format_chargement
.ok_gif

*
 move (a0)+,d0		Suit au format intel, la largeur de 
 rol #8,d0		l'Çcran
 move d0,screen_width

 move (a0)+,d0		Puis, enfin, la hauteur de l'Çcran
 rol #8,d0
 move d0,screen_height

 move.b (a0)+,d0 	* packed bits
 addq #2,a0		*.b background color index
        		*.b pixel aspect ratio
  
 lea color_table_global+2,a6
 bsr decode_color
 move d0,color_table_global

 cmp.b #",",(a0)+
 bne erreur_format_chargement

 move (a0)+,d0		DÇbut de l'image en pixels, Ö partir du cotÇ
 rol #8,d0		gauche de l'Çcran
 move d0,image_left
 	
 move (a0)+,d0		Meme chose, mais verticalement, en partant du
 rol #8,d0		haut de l'Çcran
 move d0,image_top
 
 move (a0)+,d0		La largeur de l'image en pixels
 rol #8,d0
 move d0,image_width
 
 move (a0)+,d0		Et puis sa hauteur.
 rol #8,d0
 move d0,image_height

*

 move.b (a0)+,d0 	* packed bits
 move d0,d1
 lsr #6,d1
 and #1,d1
 move d1,Interlacedgraphics
 lea color_table_local+2,a6
 bsr decode_color
 move d0,color_table_local

 move.l buffer_fichier,d0
 sub.l d0,a0
 move.l a0,d7

* reserve_memory
 move image_width,d0
 add d0,d0
 move d0,largeur_image
 move image_height,hauteur_image
 bsr.l prÇpare_buffer_image
 bne erreur_mÇmoire_chargement

 move.l d7,-(sp)
 move.l #(4096*2+4)*4,d0
 lea adr_table_gif,a0
 bsr.l rÇserve_bloc
 move.l (sp)+,d7
 tst.l d0
 bmi erreur_mÇmoire_chargement
 move.l fichier,a1

 move.l d7,-(sp)
 bsr precalcul_table
 move.l (sp)+,d7
 
 move.l buffer_fichier,a0
 add.l d7,a0

 moveq #0,d7
 move.b (a0)+,d7		*nb start decoding bits

 movem.l d0-a6,-(sp)
 bsr reunis_blocs_data_image * d nb de byte total de decompacte
 movem.l (sp)+,d0-a6

*** ici ca commence !! registre oqp !!!!


 move.l adr_table_gif,a4
 moveq #1,d0
 lsl d7,d0
 move d0,clear_code
 addq #1,d0
 move d0,end_code

 addq #1,d7
 move d7,code_size
 move d7,d0

 lsl #4,d0
 lea (table_adresse_bit,d0.w),a6
 move.l a6,adr_recal_table_code_size
 move (a6)+,d7
 move (a6)+,d4
 move.l (a6)+,a3
 move.l (a6)+,a5
 move.l (a6)+,a6



 moveq #0,d5
* decoding data

* d0 code
* d1
* d2
* d3 divers...
* d4 mask selon nb bits a prendre
* d5 nb bits a partir dukel il faut prendre
* d6 =>7 pour le and
* d7 nb de bits a prendre

* a0 source
* a1 dest
* a2 divers....
* a3 limite pour depassement de a5
* a4 table gif
* a5 poitn ds strings char ou l'on ecrit les nouvelles valeurs
* a6 pointe sur la table bit

 moveq #7,d6
.loop_data
 move.b 2(a0),d0
 swap d0
 move 1(a0),d0
 move.b (a0),d0
 lsr.l d5,d0

 and d4,d0
 add d7,d5

 move d5,d2
 and d6,d5
 lsr #3,d2
 add d2,a0


 lea (a4,d0.w*8),a2
 cmp.l a5,a2
 bge .end
 
 move.l (a2)+,d3 *nb byte to copy
 bpl.s .pas_code
 cmp.l #-2,d3
 beq .end
 move.l adr_recal_table_code_size,a6
 move (a6)+,d7
 move (a6)+,d4
 move.l (a6)+,a3
 move.l (a6)+,a5
 move.l (a6)+,a6
 bra.s .loop_data
.pas_code

 move.l (a2)+,a2
 addq #1,d3     	 * a laisser en word !!! important
 move.l d3,(a5)+
 move.l a1,(a5)+
.lopb
 move (a2)+,(a1)+
 dbra d3,.lopb

 cmp.l a3,a5
 ble.s .loop_data
 move (a6)+,d7
 move (a6)+,d4
 move.l (a6)+,a3
 addq #4,a6
 move.l (a6)+,a6
 bra .loop_data
.no_more_data_block



.end
 bsr test_extension_89

 tst	Interlacedgraphics
 beq	Graph_not_int
 lea adr_table_gif,a0
 moveq	#0,d0
 move screen_height,d0
 beq	Graph_not_int
 add	d0,d0
 bsr.l 	realloc
 tst	d0
 bne	Graph_not_int
 move.l adr_table_gif,a0
 move.l a0,a1
 move screen_height,d0
 move d0,d5
 subq	#1,d0
 moveq	#0,d1
.loop_init
	move d1,(a1)+
	addq #1,d1
	dbra d0,.loop_init
  
  * etape 1 : 1 sur huit
  moveq	#0,d7 *cpt principale de source y
* d5 : y de l'image

  moveq #0,d6 * cpt dest
.loopet1
 cmp d6,d5
 ble .endloopet1
 move d6,(a0,d7.w*2)
 addq #8,d6
 addq #1,d7
 bra.s .loopet1
.endloopet1

  moveq #4,d6 * cpt dest
.loopet2
 cmp d6,d5
 ble .endloopet2
 move d6,(a0,d7.w*2)
 addq #8,d6
 addq #1,d7
 bra.s .loopet2
.endloopet2


  moveq #2,d6 * cpt dest
.loopet3
 cmp d6,d5
 ble .endloopet3
 move d6,(a0,d7.w*2)
 addq #4,d6
 addq #1,d7
 bra.s .loopet3
.endloopet3

  moveq #1,d6 * cpt dest
.loopet4
 cmp d6,d5
 ble .endloopet4
* move (a0,d7.w*2),d0
* move (a0,d6.w*2),(a0,d7.w*2)
* move d0,(a0,d6.w*2)
 move d6,(a0,d7.w*2)
 addq #2,d6
 addq #1,d7
 bra.s .loopet4
.endloopet4


 move screen_width,d6
 move d6,d4
 add d4,d4
 subq #1,d6
 subq #1,d5
 move.l fichier,a1
 move.l a1,a2
.looprecopinter
 move d6,d7
 move (a0)+,d0

 mulu d4,d0
 lea (a1,d0.l),a3
.looprecopin
 move (a2),d0
 move (a3),(a2)+
 move d0,(a3)+
 dbra d7,.looprecopin

 dbra d5,.looprecopinter
 

	
Graph_not_int


 lea adr_table_gif,a0
 bsr.l libäre_bloc


 moveq #0,d0
 rts













table_mask_bits
x set 0
 rept 16
 dc x
x set x<<1+1
 endr
 dc x
precalcul_table
 lea color_table_global+2,a5
 tst color_table_local
 beq.s .pas_de_couleurs_locales
 lea color_table_local+2,a5
.pas_de_couleurs_locales
 move.l a5,adresse_palette
***
 move.l adr_table_gif,a6
 move nb_colors,d7
 move d7,nombre_couleurs
 subq #1,d7
***
 moveq #0,d5 *\ d5 =$0000ffff
 subq #1,d5  */
***
.loop_prec
 move.l d5,(a6)+
 move.l a5,(a6)+
 addq #2,a5
 dbra d7,.loop_prec
 moveq #-1,d5
 move.l d5,(a6)+  * clear code
 move.l d5,(a6)+
 moveq #-2,d5
 move.l d5,(a6)+  * end
 move.l d5,(a6)+


 lea table_adresse_bit,a6
 move.l adr_table_gif,a4
 lea table_mask_bits,a2
 moveq #0,d7
 moveq #12,d6
.lk

 moveq #1,d0
 lsl d7,d0
 move d7,(a6)+
 move (a2,d7.w*2),d4
 move d4,(a6)+

 lea (a4,d0.w*8),a3
 move.l a3,(a6)+
 lsr d0
 lea (16.w,a4,d0.w*8),a5
 move.l a5,(a6)+

 addq #4,a6
 move.l a6,-4(a6)

 addq #1,d7
 dbra d6,.lk
 lea -16(a6),a5
 move.l a5,-(a6)
 rts


reunis_blocs_data_image
 moveq #0,d0 * taille  total en bytes
 move.l a0,a5 *source
 move.l a0,a6 *dest
.loop_blocs
 moveq #0,d1
 move.b (a5)+,d1
 beq.s .end_image
 add.l d1,d0

; move d1,d2
; sub #254,d2
; beq.s .r254
; subq #1,d2
; beq.s .r255

 subq #1,d1
.loop_rec
 move.b (a5)+,(a6)+
 dbra d1,.loop_rec
 bra.s .loop_blocs
.end_image
 rts

.r254
x set 0
 rept 7
 movem.l (a5)+,d2-d7/a2-a4
 movem.l d2-d7/a2-a4,x(a6)
x set x+36
 endr
 lea 252(a6),a6
 move (a5)+,(a6)+
 bra.s .loop_blocs

.r255
x set 0
 rept 7
 movem.l (a5)+,d2-d7/a2-a4
 movem.l d2-d7/a2-a4,x(a6)
x set x+36
 endr
 lea 252(a6),a6
 move (a5)+,(a6)+
 move.b (a5)+,(a6)+
 bra .loop_blocs
 
test_extension_89
 move.l a0,a1
*21f9  graphics control extension =+8
 cmp #$21f9,(a1)
 bne.s .no_graphics_extension
 lea 8(a0),a0
 bra.s .fin_repere_extension
.no_graphics_extension

*21fe  comment extension =+2+block(1.b(=>)+taille*))+1.b(=>0)
 cmp #$21fe,(a1)
 bne.s .no_coment_extension
 addq #2,a1
 moveq #0,d0
.loop_coment_extension
 move.b (a1)+,d0
 beq.s .fin_coment_extension
 add.l d0,a1
 bra.s .loop_coment_extension
.fin_coment_extension
 move.l a1,a0
 bra.s .fin_repere_extension
.no_coment_extension

*21010c plain text extension
 cmp #$2101,(a1)
 bne.s .no_plain_text_extension
 cmp.b #$0c,2(a1)
 bne.s .no_plain_text_extension
 lea 2+13(a1),a1
 moveq #0,d0
.loop_plain_text_extension
 move.b (a1)+,d0
 beq.s .fin_plain_text_extension
 add.l d0,a1
 bra.s .loop_plain_text_extension
.fin_plain_text_extension
 move.l a1,a0
 bra.s .fin_repere_extension
.no_plain_text_extension

*21ff0b application extension
 cmp #$21ff,(a1)
 bne.s .no_application_extension
 cmp.b #$0b,2(a1)
 bne.s .no_application_extension
 lea 2+12(a1),a1
 moveq #0,d0
.loop_application_extension
 move.b (a1)+,d0
 beq.s .fin_application_extension
 add.l d0,a1
 bra.s .loop_application_extension
.fin_application_extension
 move.l a1,a0
 bra.s .fin_repere_extension
.no_application_extension

.fin_repere_extension
 rts


decode_color
 btst #7,d0
 beq.s .pas_de_color

 move d0,d1
 and #%111,d1
 addq #1,d1
 moveq #1,d2
 lsl d1,d2 *> nb_colors
 move d2,nb_colors
 subq #1,d2
.loop_color
 moveq #0,d0
 move.b (a0)+,d0
 and.b #%11111000,d0
 lsl #8,d0
 moveq #0,d1
 move.b (a0)+,d1
 and.b #%11111100,d1
 lsl #3,d1
 or d1,d0
 moveq #0,d1
 move.b (a0)+,d1
 and.b #%11111000,d1
 lsr #3,d1
 or d1,d0
 move d0,(a6)+ 
 dbra d2,.loop_color
 moveq #-1,d0
 rts
.pas_de_color
 moveq #0,d0
 rts

 BSS

adr_table_gif		ds.l 1

table_adresse_bit	ds.l 4*14

color_table_global	ds.w 256+1
color_table_local	ds.w 256+1
nb_colors		ds.w 1

screen_width		ds.w 1
screen_height		ds.w 1
image_left		ds.w 1
image_top		ds.w 1
image_width		ds.w 1
image_height		ds.w 1


Interlacedgraphics	ds.w 	1

clear_code		ds.w 1
end_code		ds.w 1
code_size		ds.w 1
adr_recal_table_code_size ds.l 1

