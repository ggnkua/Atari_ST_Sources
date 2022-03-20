*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*							*
*		       DSP-replay routine			*
*		for Graoumf Tracker modules (.GT2)		*
*			Falcon 030				*
*			Code 68030				*
*							*
*	     Exemple d'utilisation avec noyau non r‚sident		*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 15/12/1995, v0.742				*
* Tab setting : 11						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-95*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*



	opt	p=68030
	opt	d-



*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

FLAG_INTERPOLATION:	Equ	0	; 0 = interpolation Off
				; 1 = interpolation On



*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

waitakey:	Macro
	move.w	#7,-(sp)		; Crawcin
	trap	#1
	addq.l	#2,sp
	EndM

printames:	Macro
	pea	\1
	move.w	#9,-(sp)		; Cconws
	trap	#1
	addq.l	#6,sp
	EndM



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	bra	start		; A ne pas oublier!

	Include	'replay.s'		; Les routines de soundtrack et l'installation du noyau



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Text


start:
	move.l	#gtkpl_info_track,-(sp)
	move.w	#NBRVOIES_MAXI,-(sp)	; 32 tracks maxi
	sndkernel	kernel_on		; Installe le noyau
	addq.l	#6,sp
	tst.l	d0
	bmi	exit		; Pas possible de l'installer!

;--- Exemple de replay d'un module -------------------------------------------

	bsr	gtkpl_player_on	; Installe le player
	tst.l	d0
	bmi	essai_fin

	pea	module_gt2		; Convertit le module au format interne
	pea	module_gt2
	move.w	#0,-(sp)		; *** 0 = GT2 ***
	bsr	gtkpl_convert_module
	lea	10(sp),sp
	tst.l	d0
	bmi	essai_fin

	pea	0.l		; Pr‚pare les samples du module en calculant les
	pea	repeatbuffer	; buffers de bouclage
	pea	module_gt2
	bsr	gtkpl_make_rb_module
	lea	12(sp),sp
	tst.l	d0
	bmi	essai_fin

	clr.w	-(sp)		; Pof, on fait tourner tout ‡a
	clr.w	-(sp)
	pea	repeatbuffer
	pea	module_gt2
	bsr	gtkpl_new_module
	lea	12(sp),sp
	tst.l	d0
	bmi	essai_fin
	printames	str_playmod
	waitakey			; On attend que l'utilisateur presse une touche

	IfNE	FLAG_INTERPOLATION
	moveq	#NBRVOIES_MAXI-1,d1	; Interpole toutes les voies si on
.intloop:	move.w	#1,-(sp)		; a demand‚ cette option
	move.w	d1,-(sp)
	sndkernel	interpolate_track
	addq.l	#4,sp
	dbra	d1,.intloop
	printames	str_interpolmod
	waitakey
	EndC


	bsr	gtkpl_pause_module
	printames	str_pausemod
	waitakey

	bsr	gtkpl_cont_module
	printames	str_contmod
	waitakey

	bsr	gtkpl_stop_module
	printames	str_stopmod
	waitakey
	bsr	gtkpl_player_off	; Retire le player et libŠre ses voies

;--- Exemple de replay d'un sample (ici tir‚ du module pr‚c‚dent) ------------

	move.w	#-1,-(sp)
	sndkernel	reserve_track	; R‚serve une piste, num‚ro dans d0
	addq.l	#2,sp
	tst.l	d0
	bmi	essai_fin
	move.w	d0,d1

	move.l	gtkpl_module_inf1+adr_samples+1*4,a0	; Pointe sur le sample No 1
	move.l	replen_s(a0),-(sp)	; Replen
	move.l	repeat_s(a0),-(sp)	; Repeat
	move.l	gtkpl_module_inf1+adr_repbuf+1*4,-(sp)	; Adrbuf
	move.w	#$1,-(sp)		; Flags : Loop On (si sample pas loop, rien n'est jou‚, tant pis)
	move.w	nbits_s(a0),-(sp)	; R‚sol
	move.w	fech_s(a0),-(sp)	; Fr‚quence ech
	move.w	#$800,-(sp)	; Balance
	move.w	#$800,-(sp)	; Volume
	clr.l	-(sp)		; Position actuelle
	move.l	length_s(a0),-(sp)	; Longueur
	lea	data_s(a0),a1
	move.l	a1,-(sp)		; Adresse des donn‚es
	move.w	d1,-(sp)		; Piste
	sndkernel	play_sample	; Joue ce sample
	printames	str_playspl

	waitakey
	move.w	d1,-(sp)
	sndkernel	pause_track	; Pause
	addq.l	#2,sp
	printames	str_pausespl

	waitakey
	move.w	d1,-(sp)
	sndkernel	cont_track		; Reprise
	addq.l	#2,sp
	printames	str_contspl

	waitakey
	move.w	d1,-(sp)
	sndkernel	stop_track		; Cette fois-ci on arrˆte le sample pour de bon
	addq.l	#2,sp
	printames	str_stopspl

	move.w	d1,-(sp)
	sndkernel	free_track		; LibŠre la piste, on n'en a plus besoin
	addq.l	#2,sp

	moveq	#0,d0

essai_fin:
	tst.l	d0
	bpl.s	.no_error
	printames	str_error		; Message d'erreur
	waitakey
.no_error:	sndkernel	kernel_off		; Arrˆte le noyau

exit:	clr.w	-(sp)		; Sortie
	trap	#1





*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Data



str_playmod:	Dc.b	'Playing a module...',10,13,0
str_interpolmod:	Dc.b	'Interpolation...',10,13,0
str_pausemod:	Dc.b	'Pause...',10,13,0
str_contmod:	Dc.b	'Continue...',10,13,0
str_stopmod:	Dc.b	'Stop module.',10,13,0
str_playspl:	Dc.b	'Playing a sample...',10,13,0
str_pausespl:	Dc.b	'Pause...',10,13,0
str_contspl:	Dc.b	'Continue...',10,13,0
str_stopspl:	Dc.b	'Stop sample.',10,13,0
str_error:		Dc.b	'Oh Oh! Error!',10,13,0
		Even

module_gt2:	IncBin	'blouba.gt2'	; *** Mettre ici le nom du module
		Ds.b	50000		; *** Place pour la conversion.
					; D‚pend du module (regarder la
					; taille renvoy‚e … la conversion)
		Even



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Bss



gtkpl_info_track:	Ds.b	NBRVOIES_MAXI*next_t	; Informations sur les N voies (maximum)
repeatbuffer:	Ds.b	NBRSAMPLES_MAXI*1024	; Buffers de r‚p‚tition de N samples maxi + 1 vide



*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
