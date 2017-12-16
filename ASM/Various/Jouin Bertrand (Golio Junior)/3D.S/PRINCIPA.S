* fichier principal
* contient les inits, et l'appel … la fonction … chaque vbl
* necessite l'inclusion de principal.h pour les reservations de place
* Par Golio Junior

* paramŠtre d'entr‚ : 
* Video_mode : mode video … envoyer … Vsetmode (ou Setscreen)
* Taille_ecran : taille en octet de l'ecran

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

		* appel de la routine d'initialisation
	bsr prg_init
bouc
	wait_sys
				* permet d'obtenir le temps machine en noir	
	move.l #-1,$ff9800
	bsr prg
	move.l #0,$ff9800
				* repetion tant que la touche
				* espace n'est pas frapp‚e
	cmp.b #$39,$fffffc02
	bne.s bouc
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