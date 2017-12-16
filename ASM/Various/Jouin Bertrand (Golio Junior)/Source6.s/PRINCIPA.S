* fichier principal
* contient les inits, et l'appel … la fonction … chaque vbl
* necessite l'inclusion de principal.h pour les reservations de place
* Par Golio Junior

* paramŠtre d'entr‚ : 
* Video_mode : mode video … envoyer … Vsetmode (ou Setscreen)
* Taille_ecran : taille en octet de l'ecran
* Fond : contient le fond … afficher
* Fond_offset : offset du d‚but de l'image

* paramŠtre de sortie :
* adr_ecran : adresse de l'ecran

wait_sys macro		* attendre une vbl du systŠme
	move.w sr,-(sp)
	andi.w #$fbff,sr
	move.l $466.w,d0
wait_sys\@
	cmp.l $466.w,d0
	beq.s wait_sys\@
	move.w (sp)+,sr
	endm

	section TEXT
				* passage en superviseur
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp

				* demande de r‚solution
	move.w #-1,-(sp)
	move.w #$58,-(sp)		* Vsetmode
	trap #14
	adda.l #4,sp
	move.w d0,ancien_mode
				* adresse physique
	move.w #2,-(sp)		* Physbase
	trap #14
	adda.l #2,sp 
	move.l d0,ancien_phys
				* adresse logique
	move.w #3,-(sp)		* Logbase
	trap #14
	adda.l #2,sp
	move.l d0,ancien_log

			* Mise en place de la nouvelle r‚solution
			* calcul de l'adresse ‚cran (qui doit ˆtre un
			* mutiple de 4)
	move.l #ecran+4,d0
	andi.b #$FC,d0		* il  suffit d'annuler les 2
				* bits  de poid faible
	move.l d0,adr_ecran		* on stocke l'adresse ‚cran
	move.w #Video_mode,-(sp)	* fixe le nouveau mode video
	move.w #3,-(sp)
	move.l d0,-(sp)		* ‚cran physique = ‚cran logique
	move.l d0,-(sp)
	move.w #5,-(sp)		* Setscreen
	trap #14
	adda.l #14,sp

	* affichage du fond (fichier TPI)
	bsr aff_fond
bouc
	wait_sys
				* permet d'obtenir le temps machine en noir	
	move.l #-1,$ff9800
	bsr prg
	move.l #0,$ff9800
				* repetion tant que la touche
				* espace n'est pas frapp‚e
	cmp.b #$39,$fffffc02.w
	bne bouc
				* fin du programme

				* remise en place de la r‚solution
	move.w ancien_mode,-(sp)
	move.w #3,-(sp)
	move.l ancien_phys,-(sp)
	move.l ancien_log,-(sp)
	move.w #5,-(sp)
	trap #14
	adda.l #14,sp

				* retour au mode utilisateur
	clr.l -(sp)
	move.w #32,-(sp)
	trap #1
	addq.l #6,sp

				* retour systŠme
	move.w #0,-(sp)
	trap #1

* affichage d'une image de fond (format TPI)	
aff_fond
	move.l #Fond,a2
	adda.w #Fond_offset,a2
	move.l adr_ecran,a0
	move.w #Taille_ecran/4-1,d0
boucaff
	move.l (a2)+,(a0)+
	dbra.w d0,boucaff
	bsr init_palette
	rts

* Initialisation de la palette
init_palette
	move.l #Fond,a0
	adda.w #128,a0	
	move.l #$FF9800,a1
	move.l #255,d7
init_pal_b
	bsr convert_color
	move.l d3,(a1)+
	dbra d7,init_pal_b

	move.l #Fond,a0
	adda.w #128,a0	
	bsr convert_color
	move.l d3,$FF9800		* couleur vdi 0
	bsr convert_color
	move.l d3,$FF9800+255*4	* couleur vdi 1
	bsr convert_color
	move.l d3,$FF9800+1*4		* couleur vdi 2
	bsr convert_color
	move.l d3,$FF9800+2*4		* couleur vdi 3
	bsr convert_color
	move.l d3,$FF9800+4*4		* couleur vdi 4
	bsr convert_color
	move.l d3,$FF9800+6*4		* couleur vdi 5
	bsr convert_color
	move.l d3,$FF9800+3*4		* couleur vdi 6
	bsr convert_color
	move.l d3,$FF9800+5*4		* couleur vdi 7
	bsr convert_color
	move.l d3,$FF9800+7*4		* couleur vdi 8
	bsr convert_color
	move.l d3,$FF9800+8*4		* couleur vdi 9
	bsr convert_color
	move.l d3,$FF9800+9*4		* couleur vdi 10
	bsr convert_color
	move.l d3,$FF9800+10*4	* couleur vdi 11
	bsr convert_color
	move.l d3,$FF9800+12*4	* couleur vdi 12
	bsr convert_color
	move.l d3,$FF9800+14*4	* couleur vdi 13
	bsr convert_color
	move.l d3,$FF9800+11*4	* couleur vdi 14
	bsr convert_color
	move.l d3,$FF9800+13*4	* couleur vdi 15
	move.l #Fond,a0
	adda.l #128+6*255,a0
	bsr convert_color
	move.l d3,$FF9800+15*4	* couleur compl‚mentaire du 15 vdi
	rts

* convertion des couleurs
* a0 pointe sur une couleur au format vdi
* mot long de la palette dans d3
Convert_color
	moveq.l #0,d0
	move.w (a0)+,d0
	mulu.l #255,d0
	divu.l #1000,d0
	andi.b #%11111100,d0
	
	moveq.l #0,d1
	move.w (a0)+,d1
	mulu.l #255,d1
	divu.l #1000,d1
	andi.b #%11111100,d1
	
	moveq.l #0,d2
	move.w (a0)+,d2
	mulu.l #255,d2
	divu.l #1000,d2
	andi.b #%11111100,d2
	
	move.b d0,d3
	lsl.l #8,d3
	move.b d1,d3
	lsl.l #8,d3
	move.b #0,d3
	lsl.l #8,d3
	move.b d2,d3
	rts