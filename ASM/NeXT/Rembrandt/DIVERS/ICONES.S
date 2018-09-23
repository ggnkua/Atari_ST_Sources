;
;
; D‚coupage des icones dans une image PI9 faite avec DELMPAINT.
;
;
;
cut_it
 lea image,a0
 lea palette,a1
 move #256-1,d7
.couleur_suivante
 move.b (a0)+,d0		Rouge
 lsl #8,d0			Pousse le rouge … gauche
 and #%1111100000000000,d0 	Et masque les bits en trop !
 moveq #0,d1
 move.b (a0)+,d1
 lsl #3,d1
 and #%11111100000,d1
 or d1,d0			Ajoute le vert au rouge
 moveq #0,d1
 move.b (a0)+,d1
 lsr #3,d1
 or d1,d0			Ajoute le bleu au reste
 move d0,(a1)+			Sauve la couleur dans la palette !
 dbra d7,.couleur_suivante

 lea liste_noms,a0
 lea palette,a1

 
 move #2,colonne
.boucle_colonne
 move #2,ligne
.boucle_ligne
 tst.b (a0)		V‚rifie si on a un '0'
 beq .fin_boucle_ligne

 lea icone,a2
 move #18,(a2)+		Largeur de l'icone
 move #18,(a2)+		Hauteur de l'icone

 move #0,y
.boucle_y
 move #0,x 
.boucle_x
 move colonne,d0		X
 add x,d0
 move ligne,d1			Y
 add y,d1
 bsr calcule_couleur		R‚cupŠre la couleur
 move (a1,d0.w*2),(a2)+		Et sauve !
 addq #1,x
 cmp #17,x
 ble .boucle_x
 addq #1,y
 cmp #17,y
 ble .boucle_y

 bsr sauve_fichier
 
 add #22,ligne 
 bra .boucle_ligne
.fin_boucle_ligne
 add #22,colonne
 addq #1,a0
 tst.b (a0)		Un second z‚ro signifie la fin de la table !
 bne .boucle_colonne

 clr -(sp)		Quitte le programme
 trap #1
 
 
 

calcule_couleur 
 movem.l d0-a6,-(sp)
 lea image+1024,a0		Adresse … l'‚cran
 move 8(sp),d1			Y
 mulu #320,d1			Offset vertical
 add.l d1,a0			Adresse verticale
 lea 16(a0),a0			Part de la fin du groupe

 move 10(sp),d0			X
 move d0,d2

 and #%1111,d1			Num‚ro du pixel dans le bloc
 moveq #15,d3
 sub d1,d3			Num‚ro inverse du pixel
 
 and #-1-%1111,d2		Octet pour l'affichage   
 add d2,a0			Adresse de d‚part du bloc

 moveq #0,d0			Commence par clearer le r‚sultat

 moveq #8-1,d7			Il y a 8 plans par pixel
.loop
 move -(a0),d2			Prend le mot suivant
 lsl d0				d‚calle le r‚sultat
 btst d3,d2			teste le D1 iŠme bit
 beq.s .bit_0
 bset #0,d0			Met le bit … 1 dans le r‚sultat
.bit_0 
 dbra d7,.loop
 movem.l (sp)+,d0-a6
 rts

fin


sauve_fichier
 lea nom_fichier,a6
.recopie_nom
 move.b (a0)+,(a6)+
 bne.s .recopie_nom
 subq #1,a6
 move.l #'.ICN',(a6)+
 clr.b (a6)+
 
 movem.l d0-a6,-(sp)
 pea texte_chemin
 move #9,-(sp)
 trap #1
 addq #6,sp
 
 clr -(sp)
 pea chemin
 move #$3c,-(sp)
 trap #1
 addq #8,sp
 tst d0
 bmi fuck_file

 move d0,handle
 
 pea icone
 move.l #652,-(sp)
 move handle,-(sp)
 move #$40,-(sp)
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi fuck_file
 
 move handle,-(sp)
 move #$3e,-(sp)
 trap #1
 addq #4,sp
 tst d0
 bmi fuck_file
    
 movem.l (sp)+,d0-a6
 rts

fuck_file
 pea fuck_text
 move #9,-(sp)
 trap #1
 addq #6,sp
 move #7,-(sp)
 trap #1
 addq #2,sp
 clr -(sp)
 trap #1
 
 DATA

fuck_text
 dc.b 27,"EPlantage !!!!",0
 even
 
image		incbin E:\PROJETS\REMBRAND\divers\icones.pi9

liste_noms
 dc.b "crayon",0
 dc.b 0

 dc.b "regle",0
 dc.b    "ligne",0
 dc.b    "kligne",0
 dc.b    "rayon",0
 dc.b 0
  
 dc.b "gomme",0
 dc.b    "gfine",0
 dc.b    "gmoyenne",0
 dc.b 0
  
 dc.b "peinture",0
 dc.b 0
 
 dc.b "fleche",0
 dc.b    "90gauche",0
 dc.b    "90droite",0
 dc.b    "hflip",0
 dc.b    "vflip",0
 dc.b 0
 
 dc.b "compas",0
 dc.b    "cercle",0
 dc.b    "disque  ",0
 dc.b 0
 
 dc.b "effet",0
 dc.b    "gris",0
 dc.b 0
 
 dc.b "equerre",0
 dc.b    "carre",0
 dc.b    "boite",0
 dc.b 0
 
 dc.b "aerosol",0
 dc.b    "spray_1",0
 dc.b    "spray_2 ",0
 dc.b 0
 
 dc.b "pacman",0
 dc.b    "paneau",0
 dc.b 0

 dc.b 0



texte_chemin
 dc.b 10,13
chemin
 dc.b "E:\PROJETS\REMBRAND\FICHIERS.INC\ICONES\"
nom_fichier
 dc.b "12345678.123",0
 

 BSS

palette		ds.w 256	La palette TrueCod‚e¿

icone		ds.b 652

x		ds.w 1
y		ds.w 1
ligne		ds.w 1
colonne		ds.w 1
handle		ds.w 1
 
 END
 