*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*								     	*
*		       DSP-replay routine				*
*		for Graoumf Tracker modules (.GT2)			*
*			Falcon 030					*
*			Code 68030					*
*									*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*									*
*	Noyau de gestion sonore. Fichier … inclure.			*
*	Constantes devant d‚j… ˆtre d‚finies:				*
*	- RESIDENT_KER. Si celui-ci est non nul:			*
*	    KERNEL_TRAP_NUM						*
*	    n_gtkr_...							*
*	- next_t							*
*									*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 13/5/1996, v0.837					*
* Tab setting : 11							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-96*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*



*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Contr“le du Noyau -------------------------------------------------------


;-------------------------------------------------------------------
KERNEL_VERSION:		Equ	$0100	; Version xx.xx (-> 1.00)
;-------------------------------------------------------------------
		IfEq	RESIDENT_KER
STACK_P:		EquR	sp	; Pour la r‚cup‚ration des paramŠtres
SAVED_REG_SPACE:	Equ	52+4	; Taille de d1-a5 en longs sauv‚s sur
					; la pile + l'adresse de retour
NOSAVED_REG_SPACE:	Equ	4	; Idem, sans sauvegarde de registres
		Else
STACK_P:		EquR	a6	; On r‚cupŠre sur a6 au lieu de sp
SAVED_REG_SPACE:	Equ	0	; C'est plus la mˆme pile!
NOSAVED_REG_SPACE:	Equ	0
		EndC
;-------------------------------------------------------------------
;REPLAY_PREDIV:		Equ	1	; 1=49170 2=32768 3=24585 4=19668 5=16390 7=12292 9=9834 11=8295
*REPLAY_FREQ:		Equ	98340/(REPLAY_PREDIV+1)
;-------------------------------------------------------------------
NBRVOIES_MAXI:		Equ	32	; Maximum number of voices
;-------------------------------------------------------------------
SAMPLE_AMPLIFICATION:	Equ	0 	; 0 = No amplifcation over the samples original volume
					; 1 = High-power amplification enabled.
					;     Only useful on samples where
					;     volume_s * master est > $100000 (vol_t * master > $800000)
;-------------------------------------------------------------------
INTERRUPTION_TYPE:	Equ	0	; 0 = Interruption DSP
					; 1 = Timer A
		IfEq	INTERRUPTION_TYPE
DSP_EXCEPTION:	Equ	255		; Num‚ro du vecteur de l'exception DSP
		EndC
;-------------------------------------------------------------------
FLAG_CPUT_DISP:	Equ	0		; 0 = No cputime show
					; 1 = Show cputime used
		IfNe	FLAG_CPUT_DISP
NCOLOR_CPUT_DISP:	Equ	0	; Colournumber to show cputime in
		EndC
;-------------------------------------------------------------------
		IfND	CONST_T
CONST_T:	Equ	0		; 0 = Minimal size for path descriptors
					; 1 = Fixed size (to ensure compatibility of the format in future versions)
		  IfNe	CONST_T
USER_T:		Equ	$40		; Dans les descripteur de voies, donne la position
					; de d‚but des donn‚es r‚serv‚es … l'utilisateur
TOTAL_T:		Equ	$100	; Taille d'un descripteur d'une voie
		  EndC
		EndC
;-------------------------------------------------------------------
APP_ID_SPACE:	Equ	32		; Nombre d'identificateurs d'applications maximum
;-------------------------------------------------------------------



;--- Adresses ----------------------------------------------------------------

		IfNe	INTERRUPTION_TYPE
MFPST_INT_TIMERA:	Equ	$134
MFPIERA:		Equ	$fffffa07
MFPIERB:		Equ	$fffffa09
MFPISRA:		Equ	$fffffa0f
MFPISRB:		Equ	$fffffa11
MFPIMRA:		Equ	$fffffa13
MFPIMRB:		Equ	$fffffa15
MFPTACR:		Equ	$fffffa19
MFPTBCR:		Equ	$fffffa1b
MFPTCDCR:		Equ	$fffffa1d
MFPTADR:		Equ	$fffffa1f
MFPTBDR:		Equ	$fffffa21
MFPTCDR:		Equ	$fffffa23
MFPTDDR:		Equ	$fffffa25
		EndC

DSPHCR:		Equ	$ffffa200	; Host Control Register
DSPHSR:		Equ	$ffffa202	; Host Status Register
DSPIVR:		Equ	$ffffa203	; Interrupt Vector register
DSPHRDR_L:		Equ	$ffffa204	; Host Receive Data Register (Long)
DSPHTDR_L:		Equ	$ffffa204	; Host Transmit Data Register (Long)
DSPHRDR_3:		Equ	$ffffa205	; Host Receive Data Register (24 bits)
DSPHTDR_3:		Equ	$ffffa205	; Host Transmit Data Register (24 bits)
DSPHRDR_W:		Equ	$ffffa206	; Host Receive Data Register (Word)
DSPHTDR_W:		Equ	$ffffa206	; Host Transmit Data Register (Word)
DSPHRDR_B:		Equ	$ffffa207	; Host Receive Data Register (Byte)
DSPHTDR_B:		Equ	$ffffa207	; Host Transmit Data Register (Byte)

PLAYINT:		Equ	$ffff8900
PLAYMOD:		Equ	$ffff8901
TRAKCTRL:		Equ	$ffff8920
SAMPMOD:		Equ	$ffff8921
SDMATRIX:		Equ	$ffff8930	; Source Device Matrix
DDMATRIX:		Equ	$ffff8932	; Destination Device Matrix
FDECLOCK:		Equ	$ffff8934	; Frequency Diviser External Clock
FDISYNC:		Equ	$ffff8935	; Frequency Diviser Internal Sync


*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Port Host du DSP --------------------------------------------------------
writhost:	Macro			; Macro d'attente de la disponibilit‚
.wrhst\@:	btst	#1,DSPHSR.w	; du port HOST en ‚criture
	beq.s	.wrhst\@
	EndM

readhost:	Macro			; Idem en lecture
.rdhst\@:	btst	#0,DSPHSR.w
	beq.s	.rdhst\@
	EndM

zmove:	Macro			; Cherche les paramŠtres d'une routine
	move.\0	\1(STACK_P),\2	; \1 = Offset du paramŠtre par rapport … sp.
	EndM			; Donc (\1 = 0) <=> 1er paramŠtre
ztst:	Macro
	tst.\0	\1(STACK_P)
	EndM
zcmp:	Macro
	cmp.\0	\1,\2(STACK_P)
	EndM
zadd:	Macro
	add.\0	\1(STACK_P),\2
	EndM

sndkernel:	Macro			; Appel des routines par elles-mˆme.
	IfNE	RESIDENT_KER		; Dans le cas de routines r‚sidentes
	move.w	#n_gtkr_\1,-(sp)	; Empile le num‚ro de fonction correspondant
	trap	#KERNEL_TRAP_NUM	; AppŠle la fonction via le Trap
	addq.l	#2,sp
	Else
	bsr	gtkr_\1			; Un simple bsr quand on n'est pas r‚sident
	EndC
	EndM



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Text



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

**************************************************************************
**						          		**
*	BibliothŠque des fonctions de contr“le du noyau sonore		 *
*________________________________________________________________________*
*									 *
*	Tout accŠs … des donn‚es du noyau ne devra se faire que par	 *
*	les fonctions ci-dessous, ou par des adresses communiqu‚es	 *
**	par ces routines.				          	**
**************************************************************************



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Active le noyau							*
*	ParamŠtres : 							*
*	- W nbrvoice:Nombre maxi de piste. 1 ó nbrvoice ó NBRVOIES_MAXI	*
*		Mettez le maximum, ‡a permet aux autres applications	*
*		d'utiliser le noyau en mˆme temps.			*
*	- L adrbloc : Adresse d'un bloc contenant des infos sur les	*
*		voies. La longueur totale du bloc est			*
*		nbrtrack * next_t.					*
*	Renvoie 0 si pas d'erreur.					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_on:
	CArgs	#SAVED_REG_SPACE,f002.nbrvoice.w,f002.adrbloc.l

	movem.l	d1-a5,-(sp)
	tst.w	gtkr_flag_installed	; D‚j… install‚ ?
	bne	.warning1

	move.w	#$80,-(sp)
	trap	#14		; Locksnd
	addq.l	#2,sp
	tst.w	d0
	bmi	.error1		; D‚j… occup‚!

	move.w	#$68,-(sp)
	trap	#14		; Dsp_Lock
	addq.l	#2,sp
	tst.w	d0
	bmi	.error2		; D‚j… occup‚!

	zmove.w	f002.nbrvoice,gtkr_nbrvoies
	zmove.l	f002.adrbloc,gtkr_adr_info_track
	clr.w	gtkr_current_track
	clr.w	gtkr_dsp_plein

	move.w	#$400,-(sp)		; *** Ici r‚glage pour 8 voies
	sndkernel	set_master_vol	; Th‚orique et s–r : 4096 / nbr de voies
	addq.l	#2,sp			; Le mieux c'est 12288 / (nbr de voies + 4)

	;move.w	#REPLAY_PREDIV,-(sp)
	move.w	gtkr_replay_prediv,-(sp)
	sndkernel	set_replay_freq
	addq.l	#2,sp

	move.w	gtkr_replay_freq(pc),d1
	mulu.w	#60,d1			; Calcule la taille d'une pseudo-vbl
	divu.w	#125*4*6,d1
	move.w	d1,-(sp)		; Repfreq * 60 sec / 125 bpm / 4 lignes / 6 ticks
	sndkernel	set_vblsize
	addq.l	#2,sp

	sndkernel	reset_kernel_tracks	; Reset de toutes les voies

	pea	gtkr_init_kernel		; Ca, c'est pour commencer … jouer
	move.w	#$26,-(sp)			; Ex‚cute 'gtkr_init_kernel' en
	trap	#14				; superviseur
	addq.l	#6,sp
	move.w	#1,gtkr_flag_installed
	moveq	#0,d0				; Pas d'erreur, c'est la sueur
	bra.s	.fin

.warning1:	moveq	#1,d0			; D‚j… install‚
	bra.s	.fin

.error1:	moveq	#-1,d0			; Sound sub-system locked
	bra.s	.fin

.error2:	moveq	#-2,d0			; DSP locked

.fin:	movem.l	(sp)+,d1-a5
	rts



;ððð Routine superviseur, d‚marre le programme DSP ððððððððððððððððððððððððððð

gtkr_init_kernel:
	movem.l	d0-a5,-(sp)
	clr.w	gtkr_flag_the_end
	IfNe	FLAG_CPUT_DISP
	move.l	FCOLOR00+NCOLOR_CPUT_DISP*4.w,gtkr_color_cput_disp
	EndC

;--- Charge la routine DSP en m‚moire DSP ------------------------------------
	move.w	#$71,-(sp)		; DSP request ability
	trap	#14
	addq.l	#2,sp

	move.w	d0,-(sp)
	move.l	#(gtkr_routine_dsp_lon-gtkr_routine_dsp)/3,-(sp)	; La longueur
	pea	gtkr_routine_dsp
	move.w	#$6d,-(sp)		; Charge le prog en m‚moire DSP
	trap	#14
	lea	12(sp),sp

	move.l	#$902000,SDMATRIX.w	; Connecte le DSP … la matrice
	move.b	#$1,FDECLOCK.w
	move.b	gtkr_replay_prediv+1(pc),FDISYNC.w

	move.w	#$500,PLAYINT.w
	move.w	#$3,TRAKCTRL.w

;--- Initialise l'interruption -----------------------------------------------
	IfEq	INTERRUPTION_TYPE				; Interruption DSP
	move.b	#DSP_EXCEPTION,DSPIVR.w				; Num‚ro de l'exception d‚clench‚e lors de la
	move.l	#gtkr_kernel_interruption,DSP_EXCEPTION*4.w	; r‚ception d'une donn‚e par le port Host
	move.b	#1,DSPHCR.w					; Autorise l'interruption

	Else							; Interruption Timer A
	move.l	MFPST_INT_TIMERA.w,gtkr_sauvegarde_timer_a
	bclr	#5,MFPIMRA.w					; Timer A masqu‚
	bset	#5,MFPIERA.w					; Timer A autoris‚
	move.b	#6,MFPTACR.w					; 1/100 : 24576 Hz
	move.b	#3,MFPTADR.w					; /3 : 8192 Hz
	move.l	#gtkr_interruption_timer_a,MFPST_INT_TIMERA.w
	bset	#5,MFPIMRA.w					; Timer A d‚masqu‚
	EndC

	writhost
	move.l	#$0,DSPHTDR_L.w	; C'est parti mon kiki!

	movem.l	(sp)+,d0-a5
	rts



;ððð Routine sous Timer A si celui-ci est choisi ððððððððððððððððððððððððððððð

	IfNe	INTERRUPTION_TYPE
gtkr_interruption_timer_a:
	btst	#0,DSPHSR.w			; Une donn‚e a ‚t‚ envoy‚e par le DSP ?
	bne	gtkr_kernel_interruption	; Oui, faut y aller
	bclr	#5,MFPISRA.w			; Sinon on attend le prochain coup
	;move.w	#2300,sr
	rte
	EndC



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	D‚sactive le noyau.						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_off:
	tst.w	gtkr_flag_installed
	beq.s	.error		; Pas install‚

	move.w	#1,gtkr_flag_the_end	; Ordre d'arret du noyau
.loop:	tst.w	gtkr_flag_the_end	; Attend qu'il se soit d‚sinstall‚
	bne.s	.loop

	move.w	#$69,-(sp)
	trap	#14			; Dsp_Unlock
	addq.l	#2,sp

	move.w	#$81,-(sp)
	trap	#14			; Unlocksnd
	addq.l	#2,sp

	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0

.fin:	rts



	IfNe	RESIDENT_KER

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Retire le noyau de la m‚moire					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_remove_kernel:

	; ???? Comment faire ????
	; Si quelqu'un sait, merci de me donner la r‚ponse!

	rts

	EndC



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande si le noyau est install‚				*
*	Renvoie 0 dans d0 s'il ne l'est pas, et 1 s'il l'est.		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_status:
	moveq	#0,d0
	move.w	gtkr_flag_installed,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Reset de toutes les voies du noyau				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_reset_kernel_tracks:
	movem.l	d1-a5,-(sp)

	move.w	gtkr_nbrvoies,d3
	subq.w	#1,d3
.loop:
	move.w	d3,-(sp)
	sndkernel	free_track
	addq.l	#2,sp

	move.w	d3,-(sp)
	sndkernel	stop_track
	addq.l	#2,sp

	dbra	d3,.loop

	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Fixe le master volume						*
*	ParamŠtres :							*
*	- W master : Entre 0 et $1000. Valeur … modifier en fonction	*
*		du nombre de voies : par s‚curit‚ il devrait ˆtre	*
*		fix‚ … 4096 / nbrvoies, mais on peut gagner du volume	*
*		avec 12288 / ( nbrvoies + 4 ).				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_master_vol:
	CArgs	#NOSAVED_REG_SPACE,f00f.master.w
	zmove.w	f00f.master,gtkr_master_vol
	rts


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande le master volume dans d0.w				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_master_vol:
	move.w	gtkr_master_vol,d0
	rts


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Fixe le nombre de samples/vbl dans d0.w				*
*	ParamŠtres :							*
*	- W nbr : Entre 100 et 1200. Valeur moyenne : 983		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_vblsize:
	CArgs	#NOSAVED_REG_SPACE,f011.nbr.w

	zmove.w	f011.nbr,gtkr_vblsize
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande le nombre de samples/vbl dans d0.w			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_vblsize:
	move.w	gtkr_vblsize,d0
	rts


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande au noyau de r‚server une voie				*
*	ParamŠtres :							*
*	- W id : Num‚ro d'identification attribu‚ … la voie (>0).	*
*		$FFFF correspond … aucune identification sp‚ciale	*
*	Renvoie : Le num‚ro de la voie r‚serv‚e, et -1 si aucune	*
*		voie n'est libre.					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_reserve_track:
	CArgs	#SAVED_REG_SPACE,f005.id.w

	movem.l	d1-a5,-(sp)
	moveq	#0,d0
	move.l	gtkr_adr_info_track,a0

.loop:	tst.w	protect_t(a0)
	beq.s	.ok
	add.w	#next_t,a0
	addq.w	#1,d0
	cmp.w	gtkr_nbrvoies,d0
	blt.s	.loop
.error:	moveq	#-1,d0				; Plus de voie disponible
	bra.s	.fin

.ok:	zmove.w	f005.id,protect_t(a0)

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande au noyau de lib‚rer une voie auparavant r‚serv‚e	*
*	ParamŠtres :							*
*	- W track : Num‚ro de la voie.					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_free_track:
	CArgs	#SAVED_REG_SPACE,f006.track.w

	movem.l	d1-a5,-(sp)
	zmove.w	f006.track,d1
	mulu.w	#next_t,d1
	clr.w	([gtkr_adr_info_track],d1.l,protect_t)
	moveq	#0,d0
.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Joue un sample. Si la voie est en pause, elle repasse		*
*	automatiquement en marche. Toutes les longueurs sont en octets.	*
*	ParamŠtres :		Valeurs ne changeant rien :		*
*	- W track	: Num‚ro de piste			 /	*
*	- L adrspl : adresse du sample. paire		-1		*
*	- L lonspl : Longueur du sample. paire		-1		*
*		Elle est ignor‚e s'il y a bouclage.         		*
*	- L posspl : Position actuelle dans le sample	-1		*
*	- W volume : Volume (0..$800)			-1		*
*	- W balance : balance (0..$800..$FFF)		-1		*
*	- W freq : Fr‚quence en Hz du sample		 0		*
*	- W resol : 1 = 8 bits, 2 = 16 bits		-1		*
*	- W flags : +1 = boucle			 /			*
*		 +2 = calcul du buffer de r‚p‚tition        		*
*	- L adrbuf : adresse du buffer de bouclage		-1	*
*	- ( L reppos : Position de bouclage. paire )	-1		*
*	- ( L replen : longueur de bouclage. paire )	-1		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_play_sample:
	CArgs	#SAVED_REG_SPACE,f008.track.w,f008.adrspl.l,f008.lonspl.l,f008.posspl.l
	CArgs	#f008.posspl+4,f008.volume.w,f008.balance.w,f008.freq.w
	CArgs	#f008.freq+2,f008.resol.w,f008.flags.w,f008.adrbuf.l
	CArgs	#f008.adrbuf+4,f008.reppos.l,f008.replen.l

	movem.l	d1-a5,-(sp)

	zmove.w	f008.track,d3
	move.w	#next_t,d1
	mulu.w	d3,d1
	lea	([gtkr_adr_info_track],d1.l),a0

	move.w	#1,onoff_t(a0)
.adr_spl:	zmove.l	f008.adrspl,d1		; Adresse
	bmi.s	.pos_spl
	move.l	d1,adrsam_t(a0)
.pos_spl:	zmove.l	f008.posspl,d1		; Position
	bmi.s	.setvol
	move.l	d1,pos_t(a0)
	clr.w	finepos_t(a0)
.setvol:	zmove.w	f008.volume,d1		; Volume
	bmi.s	.setpan
	move.w	d1,vol_t(a0)
.setpan:	zmove.w	f008.balance,d1		; Balance
	bmi.s	.setfreq
	move.w	d1,bal_t(a0)
.setfreq:	zmove.w	f008.freq,d1		; Fr‚quence en Hz
	beq.s	.setresol
	move.w	d1,fech_t(a0)
	move.w	#$1ac0,per_t(a0)
.setresol:	zmove.w	f008.resol,d1		; R‚solution
	bmi.s	.setflags
	move.w	d1,nbits_t(a0)

.setflags:	zmove.w	f008.flags,d1
	btst	#0,d1				; Boucle ?
	bne.s	.boucle
.pasboucle:
	zmove.l	f008.lonspl,d2			; d2 = longueur
	bge.s	.pb_ok
	move.l	reppos_t(a0),d2
	add.l	replen_t(a0),d2
.pb_ok:	subq.l	#2,d2
	move.l	d2,reppos_t(a0)
	move.l	#2,replen_t(a0)
	bra.s	.buffer
.boucle:
	zmove.l	f008.reppos,d2			; Repeat position
	bmi.s	.rep_len
	move.l	d2,reppos_t(a0)
.rep_len:	zmove.l	f008.replen,d2		; Repeat length
	bmi.s	.buffer
	move.l	d2,replen_t(a0)
.buffer:
	zmove.l	f008.adrbuf,d2
	bmi.s	.setloop
	move.l	d2,rbuffer_t(a0)
.setloop:	btst	#1,d1			; Refaire le buffer de boucle ?
	beq.s	.fin
	move.w	nbits_t(a0),-(sp)
	move.l	replen_t(a0),d2
	move.l	d2,-(sp)
	move.l	reppos_t(a0),-(sp)
	add.l	reppos_t(a0),d2
	move.l	d2,-(sp)
	move.l	rbuffer_t(a0),-(sp)
	move.l	adrsam_t(a0),-(sp)
	sndkernel	make_rbuffer
	lea	22(sp),sp

.fin:	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Arrˆte une voie, et effectue son reset, sans la lib‚rer		*
*	ParamŠtre :							*
*	- W track : Num‚ro de la piste … arrˆter			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_stop_track:
	CArgs	#SAVED_REG_SPACE,f009.track.w

	movem.l	d1-a5,-(sp)

	zmove.w	f009.track,d2
	move.w	#next_t,d1
	mulu.w	d1,d2
	lea	([gtkr_adr_info_track],d2.l),a4

	lsr.w	#1,d1
	addq.w	#1,d1
	and.w	#1,d1
	mulu.w	#$fff,d1
	move.w	d1,bal_t(a4)			; La balance courante

	move.w	#1,onoff_t(a4)
	move.w	#1,nbits_t(a4)
	move.w	#8363,fech_t(a4)
	clr.w	vol_t(a4)
	move.w	#$1ac0,per_t(a4)
	move.l	#gtkr_zone_vide,adrsam_t(a4)
	clr.l	pos_t(a4)
	clr.w	finepos_t(a4)
	clr.l	reppos_t(a4)
	move.l	#2,replen_t(a4)
	move.l	#gtkr_zone_vide,rbuffer_t(a4)

	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Mets une voie en pause						*
*	ParamŠtre :							*
*	- W track : Num‚ro de la piste … mettre en pause		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_pause_track:
	CArgs	#SAVED_REG_SPACE,f00a.track.w

	movem.l	d1-a5,-(sp)
	zmove.w	f00a.track,d1
	mulu.w	#next_t,d1
	clr.w	([gtkr_adr_info_track],d1.l,onoff_t)
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Reprise d'une voie mise en pause				*
*	ParamŠtre :							*
*	- W track : Num‚ro de la piste … reprendre			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_cont_track:
	CArgs	#SAVED_REG_SPACE,f00b.track.w

	movem.l	d1-a5,-(sp)
	zmove.w	f00b.track,d1
	mulu.w	#next_t,d1
	move.w	#1,([gtkr_adr_info_track],d1.l,onoff_t)
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Ajoute une routine dans le noyau				*
*	ParamŠtres :							*
*	- L adrrout : adresse de la routine				*
*	Retour : 0 si rien … signaler, positif si la routine ‚tait	*
*		d‚j… l… (elle est cependant r‚install‚e). d0 contient	*
*		alors le nombre de fois qu'est pr‚sente cette routine.	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_add_routine:
	CArgs	#SAVED_REG_SPACE,f00c.adrrout.l

	movem.l	d1-a5,-(sp)
	moveq	#0,d0
	zmove.l	f00c.adrrout,a3	; a3 contient l'adresse de la routine
	lea	gtkr_extrout,a2
.loop:	move.l	(a2)+,d1		; Cherche un emplacement vide dans le noyau
	beq.s	.install
	cmp.l	a3,d1
	bne.s	.loop
	addq	#1,d0		; Ah elle ‚tait d‚j… l…. Mais ce n'est pas une erreur
	bra.s	.loop
.install:	clr.l	(a2)
	move.l	a3,-(a2)		; Installe la routine dans le noyau
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Retire une routine du noyau					*
*	ParamŠtres :							*
*	- L adrrout : adresse de la routine. Si elle ‚tait l…		*
*		plusieurs fois, elle n'est retir‚e qu'une fois.		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_remove_routine:
	CArgs	#SAVED_REG_SPACE,f00d.adrrout.l

	movem.l	d1-a5,-(sp)
	lea	gtkr_extrout,a0
	zmove.l	f00d.adrrout,d1
	moveq	#0,d2
.loop1:	addq.w	#1,d2
	cmp.w	#64,d2
	bgt.s	.error
	cmp.l	(a0)+,d1		; Cherche l'emplacement de notre routine
	bne.s	.loop1
.loop2:	move.l	(a0),-4(a0)	; D‚cale les adresse pour ‚craser celle du player
	beq.s	.ok		; 0 : c'est fini
	addq.l	#4,a0
	bra.s	.loop2
.ok:	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; On n'a rien trouv‚

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande l'adresse des infos sur les voies dans d0		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_track_adr:
	move.l	gtkr_adr_info_track,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Fixe l'adresse des infos sur les voies			*
*	ParamŠtres :					*
*	- L adr : Adresse des infos. Cette adresse ne doit ˆtre	*
*		modifi‚e que si une seule application utilise le	*
*	      	noyau lors de cette op‚ration, c.a.d s'il n'y a	*
*		aucune voie r‚serv‚e, ou seulement par l'app en	*
*		question. Lorsque l'app se termine, elle doit	*
*		restituer l'ancienne adresse, toujours dans les mˆmes	*
*		conditions, ou laisser l'espace m‚moire r‚serv‚	*
*	Retour : l'ancienne adresse dans d0			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_track_adr:
	CArgs	#NOSAVED_REG_SPACE,f013.adr.l

	move.l	gtkr_adr_info_track,d0
	zmove.l	f013.adr,gtkr_adr_info_track
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Change la fr‚quence de replay du noyau. Cette routine peut	*
*	ˆtre appel‚e alors que le noyau est d‚sactiv‚.		*
*	Attention, la taille d'une pseudo-vbl n'est pas recalcul‚e.	*
*	ParamŠtre :					*
*	- W prediviseur : Pr‚diviseur d'horloge. Les valeurs normalement	*
*		autoris‚es sont 1, 2, 3, 4, 5, 7, 9 et 11, corres-	*
*		pondant aux fr‚quences  49170, 32780, 24585, 19668,	*
*		16390, 12292, 9834 et 8195 Hz.			*
*	Renvoie l'erreur -1 si le pr‚diviseur n'est pas compris entre	*
*	1 et 15 (inclus).					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_replay_freq:
	CArgs	#SAVED_REG_SPACE,f015.prediviseur.w

	movem.l	d1-a5,-(sp)

	zmove.w	f015.prediviseur,d1	; V‚rifie la validit‚ du pr‚diviseur
	tst.w	d1		; < 1 ?
	ble.s	.error1
	cmp.w	#15,d1		; > 15 ?
	bgt.s	.error1

	move.w	d1,gtkr_replay_prediv
	move.w	(gtkr_replay_freq_tab,d1.w*2),gtkr_replay_freq
	pea	.set
	move.w	#$26,-(sp)
	trap	#14		; Routine en superviseur
	addq.l	#6,sp

	moveq	#0,d0
	bra.s	.fin

.error1:
	moveq	#-1,d0		; Pr‚diviseur trop petit ou trop grand

.fin:
	movem.l	(sp)+,d1-a5
	rts

.set:
	move.b	gtkr_replay_prediv+1(pc),FDISYNC.w
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande la fr‚quence de replay du noyau.			*
*	R‚sultat dans d0, en Hz.				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_replay_freq:
	moveq	#0,d0
	move.w	gtkr_replay_freq(pc),d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Fabrique le buffer de boucle d'un sample			*
*	ParamŠtres :					*
*	- L adrspl : Adresse du sample				*
*	- L adrbuf : Adresse du buffer (1024 octets)		*
*	- L length : Longueur du sample (en octets). Paire. S'il y a	*
*		bouclage, cette longueur n'a pas d'importance.	*
*	- L reppos : Position de r‚p‚tition (en octets). Paire		*
*	- L replen : Taille de la boucle (octets). Paire		*
*	- W resol : R‚solution du sample (1 = 8 bits, 2 = 16 bits)	*
*	Un sample non boucl‚ devra avoir reppos = 0 et replen = 2	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_make_rbuffer:
	CArgs	#SAVED_REG_SPACE,f007.adrspl.l,f007.adrbuf.l,f007.length.l
	CArgs	#f007.length+4,f007.reppos.l,f007.replen.l,f007.resol.w

	movem.l	d1-a5,-(sp)
	zmove.l	f007.adrspl,a0	; a0 = adresse du sample
	zmove.l	f007.adrbuf,a2	; a2 = adresse du buffer

	move.w	#512,d1
.loop1:	move.l	a0,a3
	zadd.l	f007.reppos,a3	; a3 pointe sur le d‚but de la boucle
	zmove.l	f007.replen,d2	; d2 = replen
	lsr.l	#1,d2
	subq.l	#1,d2
	tst.l	d2
	bne.s	.loop2
	ztst.l	f007.reppos
	bne.s	.loop2

	ztst.l	f007.length
	beq.s	.vide
	zcmp.w	#2,f007.resol
	beq.s	.bouc16b
.bouc8b:	move.w	#1023,d1		; Pas bouclage 8 bits
	zadd.l	f007.length,a0
	subq.l	#1,a0
.loop3:	move.b	(a0),(a2)+
	dbra	d1,.loop3
	bra.s	.fin
.bouc16b:	subq.w	#1,d1		; Pas de bouclage 16 bits
	zadd.l	f007.length,a0
	subq.l	#2,a0
.loop4:	move.w	(a0),(a2)+
	dbra	d1,.loop4
	bra.s	.fin
.vide:	moveq	#127,d1
.loopvide:	clr.l	(a2)+
	clr.l	(a2)+
	dbra	d1,.loopvide
	bra.s	.fin

.loop2:	move.w	(a3)+,(a2)+	; Bouclage normal
	subq.w	#1,d1
	beq.s	.fin
	subq.l	#1,d2
	bpl.s	.loop2
	bra.s	.loop1

.fin:	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande combien il a de voies au total			*
*	Renvoie: Le nombre total de voies			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_total_nbr_of_tracks:
	moveq	#0,d0
	move.w	gtkr_nbrvoies,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande combien il reste de voies non-r‚serv‚es		*
*	Renvoie: Le nombre de voies libres			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_nbr_of_free_tracks:
	movem.l	d1-a5,-(sp)
	moveq	#0,d0		; Compteur de pistes libres
	move.l	gtkr_adr_info_track,a0
	move.w	gtkr_nbrvoies,d1	; Compteur de pistes totales
	subq.w	#1,d1
.loop:	tst.w	protect_t(a0)	; Voie prot‚g‚e ?
	bne.s	.endif
	addq.w	#1,d0		; On, on incr‚mente le compteur de pistes libres
.endif:	add.w	#next_t,a0
	dbra	d1,.loop

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Place un nouvel identificateur d'application dans le noyau	*
*          ParamŠtres:					*
*	- L ident : l'identificateur en question, propre … l'application	*
*		qui le d‚pose.				*
*	- L value : Une valeur propre … l'application, par exemple une	*
*		adresse d'un bloc de paramŠtres servant … un proto-	*
*		cole inter-applications.			*
*	Renvoie:						*
*	0 si tout s'est pass‚ correctement,			*
*	1 si l'identificateur ‚tait d‚j… l… (le nouveau est cependant	*
*		r‚install‚),				*
*	-1 s'il n'y a plus de place pour le nouvel identificateur.	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_put_new_app_id:
	CArgs	#SAVED_REG_SPACE,f018.id.l,f018.value.l

	movem.l	d1-a5,-(sp)
	zmove.l	f018.id,d1		; d1 = identificateur
	zmove.l	f018.value,d2	; d2 = valeur
	moveq	#0,d3		; d3 = compteur d'identificateurs
	moveq	#0,d0		; Pas d'erreur pour l'instant
	lea	gtkr_app_id_stack,a0
.loop:
	move.l	(a0),d4
	beq.s	.place
	cmp.l	d1,d4		; Compare avec l'id scann‚
	bne.s	.suite
	moveq	#1,d0		; C'est le mˆme, on est d‚j… l…
.suite:	addq.w	#1,d3
	addq.l	#8,a0
	cmp.w	#APP_ID_SPACE,d3	; Il reste de la place ?
	blt.s	.loop
	moveq	#-1,d0		; Non, erreur -1
	bra.s	.fin

.place:	move.l	d1,(a0)+		; Place l'identificateur
	move.l	d2,(a0)+		; Et sa valeur
	clr.l	(a0)		; Le prochain espace est libre

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande si un identificateur d'application est pr‚sent		*
*          ParamŠtre:						*
*	- L ident : l'identificateur				*
*	Renvoie: l'adresse de la valeur (… aller chercher tout de suite	*
*		aprŠs car son adresse peut changer aprŠs), ou 0 si	*
*		l'identificateur n'a pas ‚t‚ trouv‚.		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_app_id:
	CArgs	#SAVED_REG_SPACE,f019.id.l

	movem.l	d1-a5,-(sp)
	zmove.l	f019.id,d1		; d1 = identificateur
	lea	gtkr_app_id_stack,a0
.loop:
	move.l	(a0),d4
	beq.s	.notfound		; 0, c'‚tait la fin
	cmp.l	d1,d4		; Compare avec l'id scann‚
	beq.s	.found
	addq.l	#8,a0
	bra.s	.loop

.notfound:	moveq	#0,d0		; Non, erreur
	bra.s	.fin

.found:	addq.l	#4,a0		; Pointe sur la valeur
	move.l	a0,d0		; Renvoie son adresse

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Retire un identificateur d'application			*
*          ParamŠtre:						*
*	- L ident : l'identificateur				*
*	Renvoie:						*
*	0 si l'op‚ration s'est pass‚e correctement			*
*	1 si l'identificateur ‚tait le dernier (il n'y en a plus aprŠs	*
*		sur la pile)				*
*	-1 si l'identificateur n'a pas ‚t‚ trouv‚			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_remove_app_id:
	CArgs	#SAVED_REG_SPACE,f01a.id.l

	movem.l	d1-a5,-(sp)
	zmove.l	f01a.id,d1		; d1 = identificateur
	lea	gtkr_app_id_stack,a0
	moveq	#1,d0		; C'est peut-ˆtre le dernier
.loop:
	move.l	(a0),d2
	beq.s	.error1		; On a atteint la fin sans le trouver
	cmp.l	d2,d1
	beq.s	.found
	moveq	#0,d0		; C'‚tait pas le dernier
	addq.l	#8,a0
	bra.s	.loop

.found:
.loop2:	move.l	8(a0),(a0)		; Ecrase l'identificateur en descendant la pile
	beq.s	.fin		; fini, on s'en va
	moveq	#0,d0		; C'‚tait pas le dernier
	move.l	12(a0),4(a0)
	addq.l	#8,a0
	bra.s	.loop2

.error1:	moveq	#-1,d0		; Indentificateur non trouv‚

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande le nombre d'identificateurs d'application pr‚sents	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_nbr_of_app_id:
	movem.l	d1-a5,-(sp)

	lea	gtkr_app_id_stack,a0
	moveq	#0,d0
.loop:	
	tst.l	(a0)
	beq.s	.fin
	addq.l	#1,d0
	addq.l	#8,a0
	bra.s	.loop

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Interpolation on/off d'une piste.			*
*	ParamŠtres:					*
*	- W track : la piste … interpoler (0-...)			*
*	- W etat : 0 = pas d'interpolation, sinon interpolation	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_interpolate_track:
	CArgs	#SAVED_REG_SPACE,f01c.track.w,f01c.etat.w

	movem.l	d1-a5,-(sp)

	move.l	gtkr_adr_info_track,a0
	zmove.w	f01c.track,d1
	mulu.w	#next_t,d1
	ztst.w	f01c.etat
	beq.s	.nointerp
.interpol:	move.w	#1,interpol_t(a0,d1.l)
	bra.s	.fin	
.nointerp:	clr.w	interpol_t(a0,d1.l)
.fin:
	moveq	#0,d0

	movem.l	(sp)+,d1-a5
	rts





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Noyau de la routine sonore, envoie les samples au DSP.		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Cette routine doit ˆtre plac‚e sur l'interruption DSP Host	*
*	Les samples sont sign‚s. Toutes les informations (rep, pos...)	*
*	sont donn‚es en octets. Un sample non boucl‚ doit avoir un	*
*	replen … 2 et reppos = longueur - 2. Tout sample doit avoir	*
*	un buffer de bouclage.				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_interruption:

;	or.w	#$2700,sr		; Y en a pas besoin, surtout si on
;	move.w	#$2300,sr
	movem.l	d0-a6,-(sp)	; est en interruption DSP
	IfNe	FLAG_CPUT_DISP	; Le rouge montre le temps machine utilis‚ par le 030
	move.l	#FC_RED,FCOLOR00+NCOLOR_CPUT_DISP*4.w
	EndC
	readhost
	move.w	DSPHRDR_W.w,d0	; R‚cupŠre la commande ‚mise par le dsp
	tst.w	gtkr_flag_the_end	; On doit tout arrˆter ?
	beq.s	sendsam_nostop

	move.b	#0,DSPHCR.w	; Plus d'interruption DSP Host
	writhost
	move.l	#8,DSPHTDR_L.w	; Arrˆt de la routine DSP
	clr.w	gtkr_flag_the_end	; Signale qu'on a arrˆt‚
	IfNe	FLAG_CPUT_DISP	; On remet la couleur de fond
	move.l	gtkr_color_cput_disp,FCOLOR00+NCOLOR_CPUT_DISP*4.w
	EndC
	IfNe	INTERRUPTION_TYPE	; Arret du Timer A s'il ‚tait l…
	bclr	#5,MFPIMRA.w	; Timer A masqu‚
	bclr	#5,MFPIERA.w	; Timer A annul‚
	move.l	gtkr_sauvegarde_timer_a,MFPST_INT_TIMERA.w
	EndC
	bra	sendsam_the_end

sendsam_nostop:
	move.l	gtkr_adr_info_track,a0	; a0 pointe sur le tableau d'infos des voies
	move.w	gtkr_current_track,d0	; d0 = voie courante
	bne.s	.ok
	writhost			; PremiŠre voie : on indique le nombre
	move.l	#32,DSPHTDR_L.w	; de samples par VBL (d‚pend du tempo)
	moveq	#0,d1
	move.w	gtkr_vblsize,d1
	writhost
	move.l	d1,DSPHTDR_L.w
.ok:	move.w	gtkr_nbrvoies,d1	; d1 = nbr de voies
	move.w	d0,d2
	mulu.w	#next_t,d2
	add.w	d2,a0		; Mise … jour du pointeur
sendsam_tsttrkloop:
	cmp.w	d0,d1		; C'‚tait la derniŠre voie ?
	beq	sendsam_apuvoi
	tst.w	onoff_t(a0)	; Voie active ?
	beq	sendsam_tsttrknxt
	cmp.l	#2,replen_t(a0)	; Sample non boucl‚ ?
	bgt.s	.suite
	tst.l	reppos_t(a0)
	beq	sendsam_tsttrknxt	; (L… y a carr‚ment rien)
	move.l	pos_t(a0),d3	; Si oui, la fin ?
	cmp.l	reppos_t(a0),d3
	bge.s	sendsam_cst
.suite:	tst.w	vol_t(a0)		; Volume … 0 ?
	bne	sendsam_voieon	; Non, on envoie le sample
	moveq	#0,d5		; Oui, on fait avancer la position
	move.w	per_t(a0),d5
	mulu.w	gtkr_replay_freq(pc),d5	; d5 = Per(note) * Freplay
	move.l	#$1ac00000,d2	; d2 = Per(C2) * $10000
	moveq	#0,d4
	move.w	fech_t(a0),d4
	mulu.l	d4,d3:d2
	divu.l	d5,d3:d2		; d2 = $10000 * Fech(C2) * Per(C2) / Per(note) / Freplay
	moveq	#0,d5
	move.w	gtkr_vblsize,d5
	mulu.l	d2,d5		; d5 = nbr d'‚chantillons … envoyer en 1 VBL * 65536
	add.w	d5,finepos_t(a0)
	bcc.s	.nocarry
	add.l	#$10000,d5
.nocarry:	clr.w	d5
	swap	d5
	cmp.w	#2,nbits_t(a0)
	bne.s	.8bits
	add.l	d5,d5
.8bits:	add.l	pos_t(a0),d5	; Position suivante
	cmp.l	reppos_t(a0),d5
	ble.s	.fin
	sub.l	reppos_t(a0),d5
	divul.l	replen_t(a0),d4:d5
	add.l	reppos_t(a0),d4
	move.l	d4,d5		; d5 = nvlpos = ((pos + N - rep) MOD replen) + rep
.fin:	move.l	d5,pos_t(a0)
sendsam_tsttrknxt:
	addq.w	#1,d0
	add.w	#next_t,a0
	bra	sendsam_tsttrkloop

sendsam_cst:			; Envoi d'un sample constant (quand un
	moveq	#0,d4		; instrument est fini et non boucl‚)
	writhost
	move.l	#16,DSPHTDR_L.w	; Bit 4 : spl cst
	move.w	vol_t(a0),d4
	mulu.w	gtkr_master_vol,d4	; On multiplie par le master
	writhost
	move.l	d4,DSPHTDR_L.w	; Volume
	move.w	bal_t(a0),d4	; Envoie la balance
	lsl.w	#3,d4
	lsl.l	#8,d4
	writhost
	move.l	d4,DSPHTDR_L.w
	moveq	#0,d4
	move.w	([rbuffer_t,a0]),d4	; Cherche le sample constant
;	neg.w	d4		; Inverse le signe (… cause des autres samples
	lsl.l	#8,d4		; qui avaient leur signe invers‚ … la r‚ception
	cmp.w	#2,nbits_t(a0)	; sur le DSP)
	beq.s	.16
	clr.w	d4
.16:	writhost
	move.l	d4,DSPHTDR_L.w
	clr.l	reppos_t(a0)	; A pu sample
	bra.s	sendsam_tsttrknxt



sendsam_voieon:
	move.l	reppos_t(a0),d1	; V‚rifie que pos < reppos+replen
	add.l	replen_t(a0),d1
	cmp.l	pos_t(a0),d1
	bgt.s	.finsi1
	subq.l	#2,d1
	move.l	d1,pos_t(a0)
.finsi1:	lea	DSPHRDR_L.w,a2	; *** Penser … optimiser avec ces registres
	lea	DSPHRDR_W.w,a3	; *** en enlevant les macros
	lea	DSPHSR.w,a4	; *** HSR
	writhost
	move.l	#1,DSPHTDR_L.w	; Bit 1 : voie on

	move.w	vol_t(a0),d1	; d1 = volume
	mulu.w	gtkr_master_vol,d1	; On multiplie par le master
	moveq	#0,d2		; Le nombre de d‚calages … faire en cas d'amplif.

	IfNE	SAMPLE_AMPLIFICATION
	cmp.l	#$800000,d1
	blt.s	.samampok
.samamplp:	addq.w	#1,d2
	lsr.l	#1,d1
	cmp.l	#$800000,d1
	bge.s	.samamplp
.samampok:
	EndC

	writhost
	move.l	d1,DSPHTDR_L.w	; Le volume
	writhost
	move.l	d2,DSPHTDR_L.w	; Les d‚calages

	move.w	bal_t(a0),d1	; Envoie la balance
	lsl.w	#3,d1
	lsl.l	#8,d1
	writhost
	move.l	d1,DSPHTDR_L.w

	moveq	#0,d1
	move.w	per_t(a0),d1
	mulu.w	gtkr_replay_freq(pc),d1	; d1 = Per(note) * Freplay
	move.l	#$1ac00000,d2	; d2 = Per(C2) * $10000
	moveq	#0,d4
	move.w	fech_t(a0),d4
	mulu.l	d4,d3:d2
	divu.l	d1,d3:d2		; d2.l = $10000 * Fech(C2) * Per(C2) / Per(note) / Freplay
	swap	d2
	moveq	#0,d1
	move.w	d2,d1		; d1.w = incr‚ment de position (entier)
	swap	d2		; d2.w = incr‚ment de position (1/65536)
	cmp.w	#2,d1
	bge	sendsam_030	; Si y en a trop … envoyer, r‚‚chantillonnage au 030
	move.w	d2,d3
	lsl.l	#8,d3
	writhost
	move.l	d1,DSPHTDR_L.w	; P‚riode mot fort
	writhost			; Envoie la p‚riode du sample mot faible
	move.l	d3,DSPHTDR_L.w

	move.w	finepos_t(a0),d3
	lsl.l	#8,d3
	writhost
	move.l	d3,DSPHTDR_L.w	; Envoie une pr‚cision de la position

	moveq	#0,d1
	move.w	interpol_t(a0),d1	; Interpolation ?
	writhost
	move.l	d1,DSPHTDR_L.w

	move.w	gtkr_vblsize,d1
	mulu.l	d2,d1		; d1 = nbr d'‚chantillons … envoyer en 1 VBL * 65536
	add.w	d1,finepos_t(a0)
	bcc.s	.nocarry
	add.l	#$10000,d1
.nocarry:	clr.w	d1
	swap	d1
	cmp.w	#2,nbits_t(a0)
	beq	sendsam_16bits	; Si c'est du 16 bits



;--- Transfert en 8 bits -----------------------------------------------------
sendsam_8bits:			; L… c'est du 8 bits
	writhost
	move.l	#1,DSPHTDR_L.w
	addq.l	#1+1,d1		; *** dernier sample … mixer : en envoyer 1 de plus
				; *** car le nbr est d‚cimal (arrondit par d‚faut)
				; *** plus 1 pour l'interpolation
	btst	#0,pos_t+3(a0)
	beq.s	sendsam_8even	; Adresse de d‚but de bloc paire

	move.l	reppos_t(a0),d3
	addq.l	#1,d3
	cmp.l	pos_t(a0),d3
	bne.s	.else
	move.l	rbuffer_t(a0),a1	; Si on tombe sur le 2Šme octet de la boucle, on prend
	addq.l	#1,a1		; celui du bouclage (‚vite gr‚sillements pour le sample 0)
	bra.s	.finsi
.else	move.l	adrsam_t(a0),a1	; a1 = adresse du sample
	add.l	pos_t(a0),a1
.finsi	move.l	d1,d2		; l… c'est impair
	subq.l	#2,d2
	lsr.l	#1,d2		; d2 = N/2-1 arrondi par d‚faut
	subq.l	#1,d1
	addq.l	#1,pos_t(a0)
	writhost
	move.l	d2,DSPHTDR_L.w	; Envoie le nbr de mots (2 ‚chantillons)
	writhost
	move.w	#1,DSPHTDR_W.w	; Adresse impaire
	writhost
	move.b	(a1)+,DSPHTDR_B.w	; Envoi 1 ‚chantillon -> adresse paire
	bra.s	sendsam_8transfert

sendsam_8even:			; L… c'est pair
	move.l	d1,d2
	subq.l	#1,d2
	lsr.l	#1,d2		; Arrondit par excŠs
	writhost
	move.l	d2,DSPHTDR_L.w
	writhost
	move.l	#0,DSPHTDR_L.w

sendsam_8transfert:
	move.l	d1,d2
	subq.l	#1+1,d1		; *** correction position r‚elle/nbr de spl envoy‚s
	add.l	pos_t(a0),d1	; Calcul de la position suivante
	cmp.l	reppos_t(a0),d1
	ble.s	.else
	sub.l	reppos_t(a0),d1
	divul.l	replen_t(a0),d6:d1
	add.l	reppos_t(a0),d6	; d6 = nvlpos = ((pos + N - rep) MOD replen) + rep
	bra.s	.finsi
.else:	move.l	d1,d6
.finsi:

sendsam_8avantfin:
	move.l	pos_t(a0),d3
	move.l	reppos_t(a0),d4
	cmp.l	d4,d3		; Teste si on est juste sur le d‚but de la boucle
	beq.s	sendsam_8boucle	; (par ex. dans le cas de samples non boucl‚s)
	move.l	adrsam_t(a0),a1	; a1 = adresse du sample
	add.l	d3,a1
	add.l	d2,d3
	add.l	replen_t(a0),d4
	cmp.l	d4,d3		; On d‚passe la fin ?
	blt	sendsam_8noloop
	sub.l	pos_t(a0),d4	; d4 = nbr d'octets avant la boucle
	beq.s	sendsam_8boucle
	sub.l	d4,d2
	subq.l	#1,d4		; Arrondit par excŠs
	lsr.l	#1,d4

	move.w	d4,d3		; Transfert ce qu'il y a avant la boucle
	not.w	d3
	and.w	#15,d3
	lsr.w	#4,d4
	writhost			; AprŠs ‡a plus de tests, DSP et 030 synchro!
	jmp	(sendsam_8loopt2,d3.w*2)
sendsam_8loopt2:
	REPT	16		; Pour cartes acc‚l‚ratrices : intercaller des
	move.w	(a1)+,(a3)		; NOPs ou des tests du TXDE, ne pas oublier de
	ENDR			; modifier le d3.w*2 du jmp d'avant. Idem plus loin
	dbra	d4,sendsam_8loopt2
	tst.l	d2
	bne.s	sendsam_8boucle
	move.l	d6,pos_t(a0)	; Si on s'arrŠte pile-poil … la fin
	bra	sendsam_next

sendsam_8boucle:			; Envoie la boucle
	move.l	rbuffer_t(a0),a1
	move.l	#1024,d3
	cmp.l	d3,d2
	bgt.s	.finsi
	move.l	d2,d3		; Si le transfert se termine dans le buffer de boucle
.finsi:	sub.l	d3,d2
	move.l	d3,d5		; d5 = nbr d'octets transf‚r‚s
	subq.l	#1,d3
	lsr.l	#1,d3		; Arrondit par excŠs
	move.w	d3,d4		; Transfert ce qu'il y a dans la boucle
	not.w	d4
	and.w	#15,d4
	lsr.w	#4,d3
	writhost
	jmp	(sendsam_8loopt3,d4.w*2)
sendsam_8loopt3:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d3,sendsam_8loopt3

	tst.l	d2		; Qu'est-ce qui reste ?
	beq.s	sendsam_8fin	; Rien, on se tire
	divul.l	replen_t(a0),d4:d5
	add.l	reppos_t(a0),d4
	move.l	d4,pos_t(a0)	; pos = ((pos + N - rep) MOD replen) + rep
	bra	sendsam_8avantfin	; On revient pour finir le transfert

sendsam_8fin:
	move.l	d6,pos_t(a0)	; Nouvelle position
	bra	sendsam_next

sendsam_8noloop:
	subq.l	#1,d2
	lsr.l	#1,d2		; Arrondit par excŠs
	move.w	d2,d4		; Transfert !
	not.w	d4
	and.w	#15,d4
	lsr.w	#4,d2
	writhost
	jmp	(sendsam_8loopt1,d4.w*2)
sendsam_8loopt1:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d2,sendsam_8loopt1
	move.l	d6,pos_t(a0)	; Nouvelle position
	bra	sendsam_next



;--- Transfert en 16 bits ----------------------------------------------------
sendsam_16bits:			; Envoi de sample 16 bits
	writhost
	move.l	#2,DSPHTDR_L.w	; Signale que c'est du 16 bits
	move.l	d1,d2
	add.l	d2,d2		; d2 = nombre d'octets
	addq.l	#2+2,d2		; *** 1 sample de s‚curit‚
				; *** plus 1 sample pour l'interpolation
	addq.l	#-1+1+1,d1		; d1 = nombre de samples -1 … envoyer en une VBL
				; *** + 1 sample … cause de l'arrondi par excŠs
				; *** + 1 pour l'interpolation
	writhost
	move.l	d1,DSPHTDR_L.w

sendsam_16avantfin:
	move.l	pos_t(a0),d3
	move.l	adrsam_t(a0),a1	; a1 = adresse du sample
	add.l	d3,a1
	add.l	d2,d3
	move.l	reppos_t(a0),d4
	add.l	replen_t(a0),d4
	cmp.l	d4,d3		; On d‚passe la fin ?
	blt	sendsam_16noloop
	sub.l	pos_t(a0),d4	; d4 = nbr d'octets avant la boucle
	beq.s	sendsam_16boucle
	sub.l	d4,d2
	lsr.l	#1,d4
	subq.l	#1,d4

	move.w	d4,d3		; Transfert ce qu'il y a avant la boucle
	not.w	d3
	and.w	#15,d3
	lsr.w	#4,d4
	writhost
	jmp	(sendsam_16loopt2,d3.w*2)
sendsam_16loopt2:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d4,sendsam_16loopt2
	tst.l	d2
	bne.s	sendsam_16boucle
	move.l	reppos_t(a0),d1	; Si on s'arrŠte pile-poil … la fin
	add.l	replen_t(a0),d1
	subq.l	#2+2,d1		; *** EnlŠve le sample de s‚curit‚
	move.l	d1,pos_t(a0)
	bra	sendsam_next

sendsam_16boucle:			; Envoie la boucle
	move.l	rbuffer_t(a0),a1
	move.l	#1024,d3
	cmp.l	d3,d2
	bgt.s	.finsi
	move.l	d2,d3		; Si le transfert se termine dans le buffer de boucle
.finsi:	sub.l	d3,d2
	move.l	d3,d5		; d5 = nbr d'octets transf‚r‚s
	lsr.l	#1,d3
	subq.l	#1,d3
	move.w	d3,d4		; Transfert ce qu'il y a dans la boucle
	not.w	d4
	and.w	#15,d4
	lsr.w	#4,d3
	writhost
	jmp	(sendsam_16loopt3,d4.w*2)
sendsam_16loopt3:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d3,sendsam_16loopt3

	tst.l	d2		; Qu'est-ce qui reste ?
	beq.s	sendsam_16fin	; Rien, on se tire
	divul.l	replen_t(a0),d4:d5
	add.l	reppos_t(a0),d4
	move.l	d4,pos_t(a0)	; pos = ((pos + N - rep) MOD replen) + rep
	bra	sendsam_16avantfin	; On revient pour finir le transfert

sendsam_16fin:
	subq.l	#2+2,d5		; *** EnlŠve le sample de s‚curit‚
	divul.l	replen_t(a0),d4:d5
	add.l	reppos_t(a0),d4
	move.l	d4,pos_t(a0)	; pos = ((pos + N - rep) MOD replen) + rep
	bra	sendsam_next

sendsam_16noloop:
	lsr.w	#1,d2
	subq.w	#1,d2
	move.w	d2,d4		; Transfert !
	not.w	d4
	and.w	#15,d4
	lsr.w	#4,d2
	writhost
	jmp	(sendsam_16loopt1,d4.w*2)
sendsam_16loopt1:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d2,sendsam_16loopt1
	subq.l	#2+2,d3		; *** EnlŠve le sample suppl‚mentaire
	move.l	d3,pos_t(a0)	; Nouvelle position
	bra	sendsam_next



;--- R‚‚chantillonnage au 030 (mais mixage DSP) -------------------------------
sendsam_030:
	writhost
	move.l	#$800000,DSPHTDR_L.w
	move.l	pos_t(a0),d3	; d3 = position.l, partie entiŠre
	move.w	finepos_t(a0),d4	; d4 = position.w, partie fractionnaire
	moveq	#0,d5
	move.w	gtkr_vblsize,d5	; d5 = nombre.w d'‚chantillons … envoyer
	move.l	adrsam_t(a0),a1	; a1 = adresse du sample
	move.l	rbuffer_t(a0),a2	; a2 = adresse du buffer
	cmp.w	#2,nbits_t(a0)
	beq	sendsam_03016



sendsam_0308:
	lea	DSPHTDR_B.w,a3
	writhost
	move.l	#$8000,DSPHTDR_L.w
	writhost			; 030 et DSP synchros
.sendloop:
	move.l	reppos_t(a0),d6
	add.l	replen_t(a0),d6
	sub.l	d3,d6		; d6 = longueur avant la fin
	subq.l	#1,d6		; On soustrait 1 AVANT le div pour arrondir par excŠs
	moveq	#0,d7		; Mets d6 * $10000 dans d7:d6
	swap	d6		; |
	move.w	d6,d7		; |
	clr.w	d6		; |
	divu.l	d2,d7:d6		; d6 = nbr de samples -1 possibles … envoyer avant la fin
	subq.l	#1,d5
	cmp.l	d5,d6
	ble.s	.s1
	move.l	d5,d6
.s1:	sub.l	d6,d5		; Ajuste le compteur de samples

.loop1:
	move.b	(a1,d3.l),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	dbra	d6,.loop1

	move.l	reppos_t(a0),d6
	add.l	replen_t(a0),d6
	cmp.l	d6,d3
	blt.s	.s2a
	sub.l	replen_t(a0),d3
	tst.l	d5
	ble	.fini
	bra.s	.s2b
.s2a:	tst.l	d5
	ble	.fini
	move.l	reppos_t(a0),d3	; Si erreur d'arrondi, on remet au d‚but de la boucle
.s2b:

; Dans la boucle maintenant
	move.l	#1024-1,d6
	sub.l	reppos_t(a0),d3
	sub.l	d3,d6
	swap	d6
	moveq	#0,d7
	divul.l	d2,d7:d6		; d6 = nbr de samples -1 … envoyer avant la fin de la boucle
	subq.l	#1,d5
	cmp.l	d5,d6
	ble.s	.s3
	move.l	d5,d6
.s3:	sub.l	d6,d5		; Ajuste le compteur de samples

.loop2:
	move.b	(a2,d3.l),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	dbra	d6,.loop2

	moveq	#0,d6
	divul.l	replen_t(a0),d6:d3
	move.l	d6,d3
	add.l	reppos_t(a0),d3	; R‚ajuste la position en fin de boucle
	tst.l	d5
	bgt	.sendloop

.fini:
	move.l	d3,pos_t(a0)
	move.w	d4,finepos_t(a0)
	bra	sendsam_next



sendsam_03016:
	lea	DSPHTDR_W.w,a3
	lsr.l	#1,d3		; d3 : Octets -> Samples
	writhost
	move.l	#$80,DSPHTDR_L.w
	writhost			; 030 et DSP synchros
.sendloop:
	move.l	reppos_t(a0),d6
	add.l	replen_t(a0),d6
	lsr.l	#1,d6		; En samples !
	sub.l	d3,d6		; Longueur avant la fin
	subq.l	#1,d6
	moveq	#0,d7
	swap	d6
	move.w	d6,d7
	clr.w	d6
	divu.l	d2,d7:d6		; d6 = nbr de samples -1 possibles … envoyer avant la fin
	subq.l	#1,d5
	cmp.l	d5,d6
	ble.s	.s1
	move.l	d5,d6
.s1:	sub.l	d6,d5		; Ajuste le compteur de samples

.loop1:
	move.w	(a1,d3.l*2),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	dbra	d6,.loop1

	add.l	d3,d3
	move.l	reppos_t(a0),d6
	add.l	replen_t(a0),d6
	cmp.l	d6,d3
	blt.s	.s2a
	sub.l	replen_t(a0),d3
	tst.l	d5
	ble	.fini2
	bra.s	.s2b
.s2a:	tst.l	d5
	ble	.fini2
	move.l	reppos_t(a0),d3	; Si erreur d'arrondi, on remet au d‚but de la boucle
.s2b:


; Dans la boucle maintenant
	move.l	#1024/2-1,d6
	sub.l	reppos_t(a0),d3
	lsr.l	#1,d3
	sub.l	d3,d6
	swap	d6
	moveq	#0,d7
	divul.l	d2,d7:d6		; d6 = nbr de samples -1 … envoyer avant la fin de la boucle
	subq.l	#1,d5
	cmp.l	d5,d6
	ble.s	.s3
	move.l	d5,d6
.s3:	sub.l	d6,d5		; Ajuste le compteur de samples

.loop2:
	move.w	(a2,d3.l*2),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	dbra	d6,.loop2

	moveq	#0,d6
	add.l	d3,d3
	divul.l	replen_t(a0),d6:d3
	move.l	d6,d3
	add.l	reppos_t(a0),d3	; R‚ajuste la position en fin de boucle
	tst.l	d5
	ble.s	.fini2
	lsr.l	#1,d3
	bra	.sendloop

.fini:	add.l	d3,d3
.fini2:	move.l	d3,pos_t(a0)
	move.w	d4,finepos_t(a0)



sendsam_next:
	st	gtkr_dsp_plein	; C'est bon, on a rempli le buffer du DSP
	IfNe	FLAG_CPUT_DISP	; Bleu, le dsp est occup‚
	move.l	#FC_BLUE,FCOLOR00+NCOLOR_CPUT_DISP*4.w
	EndC
	addq.w	#1,d0		; Voie suivante
	bra.s	sendsam_encore

sendsam_apuvoi:
	moveq	#0,d0		; On recommencera la prochaine fois … la voie 0
	moveq	#2,d1		; Si les deux canaux sont utilis‚s, fin normale
	tst.w	gtkr_dsp_plein
	bne.s	.finsi
	moveq	#4,d1		; Si rien n'a ‚t‚ envoy‚, on vide les buffers du DSP
.finsi:	writhost
	move.l	d1,DSPHTDR_L.w	; Plus de voie … mixer
	clr.w	gtkr_dsp_plein	; On remet … 0 l'indicateurs
	IfNe	FLAG_CPUT_DISP	; Vert : les routines externes
	move.l	#FC_GREEN,FCOLOR00+NCOLOR_CPUT_DISP*4.w
	EndC

	lea	gtkr_extrout,a0	; a0 pointe sur la table des routines
.extloop:	move.l	(a0)+,d1
	beq.s	.ext_end		; Adresse = 0, c'est fini
	movem.l	d0/a0,-(sp)
	jsr	(d1.l)		; Ex‚cute une routine ext‚rieure (ex : partition)
	movem.l	(sp)+,d0/a0
	bra.s	.extloop		; Routine suivante
.ext_end:

	IfNe	FLAG_CPUT_DISP	; C'est fini pour la vbl
	move.l	gtkr_color_cput_disp,FCOLOR00+NCOLOR_CPUT_DISP*4.w
	EndC

sendsam_encore:
	move.w	d0,gtkr_current_track

sendsam_the_end:
	movem.l	(sp)+,d0-a6
	IfNe	INTERRUPTION_TYPE
	bclr	#5,MFPISRA.w
	EndC
	rte





*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Data



;--- Pour le noyau -----------------------------------------------------------
gtkr_flag_installed:	Dc.w	0	; 1 = Noyau install‚, 0 = non install‚
	; Ces deux mots doivent ˆtre modifi‚s ensemble ---v
*gtkr_replay_prediv:	Dc.w	REPLAY_PREDIV	; Pr‚diviseur de l'horloge
gtkr_replay_prediv:	Dc.w	1		; Pr‚diviseur de l'horloge
*gtkr_replay_freq:	Dc.w	REPLAY_FREQ	; Fr‚quence de restitution
gtkr_replay_freq:	Dc.w	98340/2		; Fr‚quence de restitution
gtkr_replay_freq_tab:	Dc.w	50033		; Table des fr‚quence du CoDec,
	variable1:	Set	2		; selon les pr‚diviseurs de
		Rept	15		; l'horloge.
		Dc.w	98340/variable1
	variable1:	Set	variable1+1
		EndR

gtkr_routine_dsp:	IncBin	'playdsp.p56'	; Prog DSP
gtkr_routine_dsp_lon:
		Even



*~~~ Structures ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Bloc de descritption de l'‚tat actuel de chaque voie --------------------

;... Partie r‚serv‚e au noyau ................................................
		RsReset
onoff_t:		Rs.w	1	; 0 = voie off, 1 = voie on
nbits_t:		Rs.w	1	; 1 = 8 bits, 2 = 16 bits
fech_t:		Rs.w	1	; Fr‚quence d'‚chantillonnage du sample (8363 Hz par d‚faut)
vol_t:		Rs.w	1	; Volume courant (0-$800)
bal_t:		Rs.w	1	; Balance courante ($000..$800..$FFF)
per_t:		Rs.w	1	; P‚riode courante (format "soundtracker" * $10)
adrsam_t:		Rs.l	1	; Adresse du sample, paire
pos_t:		Rs.l	1	; Position dans le sample, paire
finepos_t:		Rs.w	1	; Position pr‚cise (1/65536)
reppos_t:		Rs.l	1	; Position de r‚p‚tition du sample, paire
replen_t:		Rs.l	1	; Longueur de bouclage du sample	, paire
rbuffer_t:		Rs.l	1	; Adresse du buffer de r‚p‚tition de l'instrument
protect_t:		Rs.w	1	; 0 = voie non prot‚g‚, sinon num‚ro de la protection
interpol_t		Rs.w	1	; 0 = pas d'interpolation pour le mixage de cette voie
		IfNe	CONST_T
		 IfNe	__rs>USER_T
		  Fail	"Taille de la structure InfoTrack-Kernel sup‚rieure … la taille maximum fix‚e!"
		 Else
		  RsSet	USER_T
		 EndC
		EndC
kernelend_t:	Rs	0	; Une routine voulant utiliser la structure User
				; devra initialiser son Rs avec cette valeur.



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Bss



gtkr_adr_info_track:	Ds.l	1	; Adresse de info_track
gtkr_nbrvoies:	Ds.w	1	; Nombre de voies … mixer
gtkr_current_track:	Ds.w	1	; Piste courante
gtkr_dsp_plein:	Ds.w	1	; A 0 si aucune voie n'a ‚t‚ envoy‚e.
gtkr_master_vol:	Ds.w	1	; Le master volume (0 - $1000), $100 pour 16 voies
gtkr_vblsize:	Ds.w	1	; Nbr de samples/VBL (1000 en moyenne)
gtkr_flag_the_end:	Ds.w	1	; 1 = On arrˆte le noyau
gtkr_extrout:	Ds.l	17	; Place pour les adr de 16 routines … ‚x‚cuter en fin d'IT. 0 = pu d'routine
gtkr_zone_vide:	Ds.b	1024	; 1Ko de vide (totalement vide, qui doit le rester)
		IfNe	FLAG_CPUT_DISP
gtkr_color_cput_disp:	Ds.l	1	; Sauvegarde de la couleur
		EndC
		IfNe	INTERRUPTION_TYPE
gtkr_sauvegarde_timer_A:	Ds.l	1
		EndC
gtkr_app_id_stack:	Ds.l	2*APP_ID_SPACE+1	; Les identificateurs d'application
				; plus 1 long qui est nul et qui indique est
				; plac‚ aprŠs le dernier id. pr‚sent



*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
