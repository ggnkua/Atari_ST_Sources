* Mini Calculatrice
* par Golio junior

	section Text
	
boucle_principale
	pea menu
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	move.w #1,-(sp)	* fonction C_conin
	trap #1		* appel du Gemdos
	addq.l #2,sp

	bsr menu_choix
	
	bra boucle_principale

menu_choix
	cmpi.b #'1',d0
	beq addition
	cmpi.b #'2',d0
	beq soustraction
	cmpi.b #'3',d0
	beq multiplication
	cmpi.w #'4',d0
	beq division
	cmpi.w #'5',d0
	beq fin
	rts

addition
	pea addi_texte
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp

			* saisir le premier op‚rande
	pea operande_1
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_1
			* saisir le second
	pea operande_2
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_2
			* realiser l'op‚ration
	move.l oper_1,d0
	add.l oper_2,d0
	move.l d0,resultat
			* afficher le r‚sultat
	bsr affiche
	rts

soustraction
	pea sous_texte
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp

			* saisir le premier op‚rande
	pea operande_1
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_1
			* saisir le second
	pea operande_2
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_2
			* realiser l'op‚ration
	move.l oper_1,d0
	sub.l oper_2,d0
	move.l d0,resultat
			* afficher le r‚sultat
	bsr affiche
	rts

multiplication
	pea mult_texte
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp

			* saisir le premier op‚rande
	pea operande_1
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_1
			* saisir le second
	pea operande_2
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_2
			* realiser l'op‚ration
	move.l oper_1,d0
	mulu.l oper_2,d0
	move.l d0,resultat
			* afficher le r‚sultat
	bsr affiche
	rts

division
	pea divi_texte
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp

			* saisir le premier op‚rande
	pea operande_1
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_1
			* saisir le second
	pea operande_2
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp
	
	bsr saisie
	move.l d0,oper_2
			* realiser l'op‚ration
	move.l oper_1,d0
	divu.l oper_2,d0
	move.l d0,resultat
			* afficher le r‚sultat
	bsr affiche
	rts
erreur
fin
	move.w #0,-(sp)	* fonction P_term0
	trap #1		* appel du Gemdos


saisie
	pea base
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp

	move.w #7,-(sp)	* fonction C_rawcin
	trap #1		* appel du Gemdos
	addq.l #2,sp

	cmpi.b #'1',d0
	beq saisie_bin
	cmpi.b #'2',d0
	beq saisie_hexa
	cmpi.b #'3',d0
	beq saisie_fichier
			* aucun type selectionn‚
	move.w #0,d0
	rts
saisie_bin
	bsr saute_ligne
	
	move.w #'%',-(sp)
	move.w #2,-(sp)	* fonction C_conout
	trap #1		* appel Gemdos
	addq.l #4,sp

	move.b #32,buffer_lecture
			* initialisation du buffer
			* de lecture
	pea buffer_lecture
	move.w #10,-(sp)	* fonction C_conrs
	trap #1		* appel du Gemdos
	addq.l #6,sp

	bsr saute_ligne
	
	move.b buffer_lecture+1,d1
	andi.w #$00FF,d1
	subq.w #1,d1
	lea buffer_lecture+2,a0
	clr.l d0
saisie_bin_b1
	lsl.l #1,d0	* passage au bit suivant
	move.b (a0)+,d2
	cmpi.b #'0',d2
	beq saisie_bin_1
	ori.b #$01,d0	* fixe le bit de poid faible … 1
saisie_bin_1
	dbra d1,saisie_bin_b1
	rts
saisie_hexa
	bsr saute_ligne
	
	move.w #'$',-(sp)
	move.w #2,-(sp)	* fonction C_conout
	trap #1		* appel Gemdos
	addq.l #4,sp

	move.b #8,buffer_lecture
			* initialisation du buffer
			* de lecture
	pea buffer_lecture
	move.w #10,-(sp)	* fonction C_conrs
	trap #1		* appel du Gemdos
	addq.l #6,sp

	bsr saute_ligne

	move.b buffer_lecture+1,d1
	andi.w #$00FF,d1
	subq.w #1,d1
	lea buffer_lecture+2,a0
	clr.l d0
saisie_hexa_b1
	lsl.l #4,d0	* passage au quartet suivant
	move.b (a0)+,d2
	cmpi.b #'A'-1,d2
	bpl saisie_hexa_A
	subi.b #'0',d2
	add.b d2,d0
	bra saisie_hexa_s1
saisie_hexa_A
	andi.b #%01011111,d2	* passe en majuscule!
	subi.b #'A'-10,d2
	add.b d2,d0
saisie_hexa_s1
	dbra d1,saisie_hexa_b1
	rts
saisie_fichier
			* ouverture du fichier
	move.w #$02,-(sp)	* ouverture en lecture/ecriture
	pea fichier_nom
	move.w #$3D,-(sp)	* fonction F_open
	trap #1		* appel Gemdos
	addq.l #8,sp
	tst.l d0
	bmi erreur
	move.w d0,fichier_handle
			* on sauve la handle du fichier

	pea tampon
	move.l #4,-(sp)
	move.w fichier_handle,-(sp)
	move.w #$3F,-(sp)	* fonction F_read
	trap #1		* appel Gemdos
	lea (sp,12),sp
	tst.l d0
	bmi erreur
	
	move.w fichier_handle,-(sp)
	move.w #$3E,-(sp)	* fonction F_close
	trap #1		* appel Gemdos
	addq.l #4,sp
	tst.l d0
	bmi erreur
	
	move.l tampon,d0
	rts
	
affiche
	pea base
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel Gemdos
	addq.l #6,sp

	move.w #7,-(sp)	* fonction C_rawcin
	trap #1		* appel du Gemdos
	addq.l #2,sp

	cmpi.b #'1',d0
	beq affiche_bin
	cmpi.b #'2',d0
	beq affiche_hexa
	cmpi.b #'3',d0
	beq affiche_fichier

	rts
affiche_bin
	lea affiche_bin_txt+12,a0
	move.w #32-1,d1
	move.l resultat,d0
affiche_bin_b1
	lsl.l #1,d0
	bcs affiche_bin_1
	move.b #'0',(a0)+
	bra affiche_bin_fin
affiche_bin_1
	move.b #'1',(a0)+
affiche_bin_fin
	dbra d1,affiche_bin_b1
	
	pea affiche_bin_txt
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel du Gemdos	
	addq.l #6,sp

	move.w #7,-(sp)	* fonction C_rawcin
	trap #1		* appel du Gemdos
	addq.l #2,sp
	rts
affiche_hexa
	lea affiche_hexa_txt_f-2,a0
			* a0 pointe sur l'octet 13
	move.w #8-1,d1
	move.l resultat,d0
affiche_hexa_b1
	move.b d0,d2
	andi.b #$0F,d2
	cmpi.b #$A,d2
	bpl affiche_hexa_sup
	add.b #'0',d2
	bra affiche_hexa_suite
affiche_hexa_sup
	add.b #'A'-$A,d2
affiche_hexa_suite
	move.b d2,-(a0)
	lsr.l #4,d0
	dbra d1,affiche_hexa_b1

	pea affiche_hexa_txt
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel du Gemdos	
	addq.l #6,sp
	
	move.w #7,-(sp)	* fonction C_rawcin
	trap #1		* appel du Gemdos
	addq.l #2,sp
	rts

affiche_fichier
			* creation du fichier
	move.w #00,-(sp)	* fichier en Lecture/Ecriture
	pea fichier_nom
	move.w #$3C,-(sp)	* fonction F_create
	trap #1		* appel Gemdos
	addq.l #8,sp
	tst.l d0
	bmi erreur
			* on r‚cupŠre le handle du fichier cr‚‚
	move.w d0,fichier_handle

			* ecriture
	pea resultat	* adresse du bloc a sauvegarder
	move.l #4,-(sp)	* 4 octets … ‚crire
	move.w fichier_handle,-(sp)
	move.w #$40,-(sp)	* fonction F_write
	trap #1		* appel Gemdos
	lea 12(sp),sp
	tst.l d0
	bmi erreur
	
			* fermeture
	move.w fichier_handle,-(sp)
	move.w #$3E,-(sp)	* fonction F_close
	trap #1		* appel Gemdos
	addq.l #4,sp
	tst.l d0
	bmi erreur
	rts
	
saute_ligne
	move.w #10,-(sp)
	move.w #2,-(sp)	* fonction C_conout
	trap #1		* appel Gemdos

	move.w #13,-(sp)
	move.w #2,-(sp)	* fonction C_conout
	trap #1		* appel Gemdos
	
	addq.l #8,sp	* et oui, osons!
	rts

	section Data
menu	dc.b 27,"E"
	dc.b "1 : addition", 10, 13, "2 : soustraction", 10, 13
	dc.b "3 : multiplication", 10, 13, "4 : division", 10, 13
	dc.b "5 : quitter", 10, 13, "Votre choix : "
	dc.b 00
	
addi_texte	dc.b 10, 13, " Addition ", 10, 13, 00
sous_texte	dc.b 10, 13, " Soutraction", 10, 13, 00
mult_texte	dc.b 10, 13, " Multiplication", 10, 13, 00
divi_texte	dc.b 10, 13, " Division", 10, 13, 00

operande_1	dc.b " PremiŠre op‚rande : ", 10, 13, 00
operande_2	dc.b " Seconde op‚rande  : ", 10, 13, 00

base	dc.b " Choix de la base :", 10,13
	dc.b "  1 : Base binaire", 10, 13
	dc.b "  2 : Base hexad‚cimale", 10, 13
	dc.b "  3 : Fichier", 10, 13, 00

affiche_bin_txt
	dc.b "R‚sultat : %00000000000000000000000000000000",13,10
	dc.b 00

affiche_hexa_txt
	dc.b "R‚sultat : $00000000",13,10
affiche_hexa_txt_f
	dc.b 00

fichier_nom
	dc.b "mini_cal.dat"
	dc.b 00

	section Bss
oper_1	ds.l 1
oper_2	ds.l 1
resultat	ds.l 1
tampon	ds.l 1
fichier_handle
	ds.w 1
buffer_lecture
	ds.b 1		* longueur maximal (retour chariot non inclu)
	ds.b 1		* nombre de caractŠres re‡us
	ds.b 255		* stockage de la chaine lue