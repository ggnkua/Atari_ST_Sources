 TEXT
 
teste_image_spectrum   
 cmp.l #51104,taille_fichier
 beq charge_spectrum_normal

charge_image_spectrum_compress‚e
 move.l buffer_fichier,a0
 cmp #'SP',(a0)
 bne erreur_format_chargement
 
 move.l #32000+19200+50000,d0
 lea buffer_d‚packing,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_d‚packing
 
 bsr routine_d‚packing_spc

 move.l buffer_d‚packing,a0
 lea 32000(a0),a0
 move.l a0,adresse_palette
 move.w #9552,nombre_couleurs
 bsr recode_palette
 move.l buffer_d‚packing,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 bsr remape_spectrum
 lea buffer_d‚packing,a0
 bsr.l libŠre_bloc
 moveq #0,d0
 rts

routine_d‚packing_spc
 moveq #1,d0
 bsr affiche_formulaire_chargement
 move.l buffer_fichier,a0		Source pack‚e
 move.l 4(a0),taille_image_spc
 move.l 8(a0),taille_palette_spc
 lea 12(a0),a1
 move.l a1,adresse_image_spc
 add.l taille_image_spc,a1
 move.l a1,adresse_palette_spc
  
 move.l buffer_fichier,a0
 lea 12(a0),a0			Image source
 move.l buffer_d‚packing,a1	Image destination
 move #1,d1 
 move #7,d7 
 lea 32000(a1),a2
 lea 8(a2),a3
l0068
 lea -31840(a2),a1 
l0069
 move.b (a0)+,d6
 ext d6
 bmi.s l006b 
l006a
 move.b (a0)+,(a1)
 adda d1,a1 
 exg d7,d1 
 dbra d6,l006a
 bra.s l006d 
l006b
 neg d6
 addq #1,d6 
 move.b (a0)+,d0
l006c
 move.b d0,(a1) 
 adda d1,a1 
 exg d7,d1 
 dbra d6,l006c
l006d
 cmpa.l a2,a1 
 bcs.s l0069 
 bne fin_d‚packing_spc 
 addq.l #2,a2 
 cmpa.l a3,a2 
 bcs.s l0068 
 move.l a0,d0 
 addq.l #1,d0 
 bclr #0,d0 
 sub.l adresse_image_spc,d0 
 cmp.l taille_image_spc,d0 
 bne fin_d‚packing_spc 

 move.l adresse_palette_spc,a0
 move.l buffer_d‚packing,a1
 lea 32000(a1),a1
 move #$254,d7
 clr d0
l006e
 move #$d,d6
 move (a0)+,d1
 lsr #1,d1 
 move d0,(a1)+
l006f
 lsr #1,d1 
 bcc.s l0070 
 move (a0)+,(a1)+ 
 dbra d6,l006f
 bra.s l0071 
l0070
 move d0,(a1)+
 dbra d6,l006f
l0071
 move d0,(a1)+
 dbra d7,l006e
 suba.l adresse_palette_spc,a0 
 cmpa.l taille_palette_spc,a0 
fin_d‚packing_spc
 bsr.l ferme_formulaire
 rts 

 
charge_image_spectrum_normale
 cmp.l #51104,taille_fichier
 bne erreur_format_chargement
charge_spectrum_normal
 move.l buffer_fichier,a0
 lea 32000(a0),a0
 move.l a0,adresse_palette
 move.w #9552,nombre_couleurs
 bsr recode_palette
 move.l buffer_fichier,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 bsr remape_spectrum
 moveq #0,d0
 rts
 
remape_spectrum
 move.l fichier,a5
 move #160-1,d0
.efface_ligne_0
 clr.l (a5)+
 dbra d0,.efface_ligne_0
  
 move #1,d7 		Position Y [On ne part pas de 0...]
boucle_y
 clr d6			Position X
boucle_x
 move d6,d0 
 move d7,d1 
 bsr.s traite_xy 
 move d0,(a5)+
 addq #1,d6 
 cmp #320,d6
 bcs.s boucle_x
 addq #1,d7 
 cmp #200,d7 
 bcs.s boucle_y
 rts


traite_xy
 move.l adresse_image,a0
 move.l adresse_palette,a1

 move d1,d4	Multiplie D1 par 160 (Bah dites donc !!!)
 add d1,d1
 add d1,d1
 add d4,d1
 lsl #5,d1

 move d0,d2 
 move d0,d3 
 andi #$000f,d2		Num‚ro du pixel dans le multiple (0-15)
 andi #$fff0,d3		Num‚ro du multiple de 16
 lsr #1,d3
 add d3,d1		Offset du multiple sur l'‚cran

 adda d1,a0 		Adresse du multiple

 neg d2
 addi #15,d2		Num‚ro en bit du pixel concern‚
 clr d1
 bset d2,d1		Masque binaire correspondant
 
 move (a0)+,d3		Lit le 1er plan
 and d1,d3 		Masquage
 sne d2			Si le resultat est nul, valide un bit … 1
 ror #1,d2 

 move (a0)+,d3
 and d1,d3 
 sne d2
 ror #1,d2 

 move (a0)+,d3
 and d1,d3 
 sne d2
 ror #1,d2 

 move (a0)+,d3
 and d1,d3 
 sne d2
 rol #3,d2 		R‚cupŠre les bits

 andi #%1111,d2		Ne conserve que les bits significatifs

 move d2,d3 		Multiplie D2 par 10 (!!!)
 add d2,d2 		Je suis carr‚ment impressionn‚...
 add d2,d2 
 add d3,d2 
 add d2,d2 

 addq #1,d2 

 btst #0,d3 
 beq.s l001d 
 subq #6,d2 
l001d
 add d3,d3 
 cmp d2,d0 
 bcs.s l001e 
 addi #32,d3 
 addi #160,d2 
 cmp d2,d0 
 bcs.s l001e 
 addi #32,d3 
l001e
 move d4,d0 
 move d0,d2 
 add d0,d0 
 add d2,d0 
 lsl #5,d0 
 add d0,d3 
 move -96(a1,d3),d0 	La bonne couleur !!! (I hope so)
 rts 

 BSS
 
taille_image_spc		ds.l 1
taille_palette_spc		ds.l 1
adresse_image_spc		ds.l 1
adresse_palette_spc		ds.l 1
