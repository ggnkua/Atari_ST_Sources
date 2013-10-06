
 TEXT
 
charge_ressource
 lea ressource,a6

 lea liste_relocation,a0
.reloge_suivant
 move (a0)+,d0
 bmi.s .fin_reloc
 move (a6,d0.w),d0
 add (a0)+,d0
 move (a0)+,d1
 move (a6,d1.w),d1
 move (a0)+,d2
 bsr reloge
 bra.s .reloge_suivant
.fin_reloc
   
 move.l a6,a0			Objets
 add 2(a6),a0
 
 move 20(a6),d0			Nombre d'objets
 
 tst d0 
 beq .fin_relocation_objets
.boucle_reloge_objets
 move 6(a0),d1			Type de l'objet
 cmp #20,d1			G_BOX
 beq .no_box
 cmp #25,d1			G_IBOX
 beq .no_box
 cmp #27,d1			G_BOXCHAR
 beq .no_box
.reloge_ob_spec
 add.l #ressource,12(a0)	Reloge l'adresse du pointeur OB_SPEC    
.no_box

 movem.l d0/a0/a6,-(sp)		Modifie les coordonn‚es ‚cran, afin que la
 rsrc_obfix a0,#0		ressource soit correctement affich‚e...
 movem.l (sp)+,d0/a0/a6
  
 lea 24(a0),a0			Pointe sur l'objet suivant. 
 subq #1,d0			Un objet de moins.
 bne .boucle_reloge_objets

.fin_relocation_objets 

 move 18(a6),d0
 lea (a6,d0.w),a0
 move.l a0,global+10  		Liste des arbres en GLOBAL[5/6]
 
 move.l a6,global+14		Adresse de la ressource en GLOBAL[7/8]

 move 34(a6),global+18		Taille du fichier en GLOBAL[9]
 rts
 


*
* d0=Offset sur premier pointeur
* d1=Nombre de pointeurs
* d2=Distance entre deux pointeurs
*
reloge
 lea (a6,d0.w),a1
 move.l a6,d3			Il aime pas le ®add.l an,(an)¯...
   
 tst d1
 beq .fin_relocation_pointeurs
.boucle_reloge_pointeurs
 add.l d3,(a1)			Reloge l'adresse du pointeur.    
 add d2,a1			Pointe sur l'adresse suivante
 subq #1,d1			Un objet de moins.
 bne .boucle_reloge_pointeurs
.fin_relocation_pointeurs 
 rts




;}}
;}} Les ressources en relief, qui ont plus de 16 couleurs sont
;}} inutilisables dans les modes graphiques qui ont moins de
;}} couleurs. Pour cela, il est n‚c‚ssaire de proc‚der … une
;}} modification des couleurs au sein meme de la ressource
;}}
transforme_formulaire
 tst.b flag_transformation
 beq fin_transformation
 move.l #$ffffffff-15,d7
 move.l addr_out,a0
objet_suivant
 move ob_type(a0),d6

.teste_box
 cmp #20,d6	G_BOX
 beq .box
 cmp #25,d6	G_IBOX
 beq .box
 cmp #27,d6	G_BOXCHAR
 beq .box
 bra .teste_boxtext
 
.box
 and.l d7,ob_spec(a0)
 bra fin_objet

.teste_boxtext
 cmp #21,d6	G_TEXT
 beq .boxtext
 cmp #22,d6	G_BOXTEXT
 beq .boxtext
 cmp #29,d6	G_FTEXT
 beq .boxtext
 cmp #30,d6	G_FBOXTEXT
 beq .boxtext
 bra fin_objet
    
.boxtext
 move.l ob_spec(a0),a1
 and d7,18(a1)
 bra fin_objet

fin_objet
 tst ob_next(a0)
 beq fin_transformation
 lea 24(a0),a0
 bra objet_suivant

fin_transformation
 rts

 DATA

 even

liste_relocation
 dc.w 18,0,22,4		Arbres d'objets
 dc.w 4,0,24,28		TEDINFO
 dc.w 4,4,24,28		masques de saisie  
 dc.w 4,8,24,28		chaines de validation
 dc.w 6,0,26,34		masque ICONBLK
 dc.w 6,4,26,34		donn‚es ICONBLK 
 dc.w 6,8,26,34		texte ICONBLK 
 dc.w 8,0,28,14		BITBLK 
 dc.w 10,0,30,4 	FREE STRINGS
 dc.w 16,0,32,4		FREE IMAGES 
 dc.w -1
  
ressource	incbin REMBRAND.RSC

