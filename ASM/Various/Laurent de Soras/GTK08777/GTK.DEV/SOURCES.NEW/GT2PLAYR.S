*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*							*
*		       DSP-replay routine			*
*		for Graoumf Tracker modules (.GT2)		*
*			Falcon 030				*
*			Code 68030				*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*							*
*	Routines du soundtracker				*
*	Constantes devant ˆtre d‚j… d‚finies:			*
*	- NBRTRACK_MAXI (sauf si NBRVOIES_MAXI est d‚fini)		*
*	- CONST_T. Si celui-ci est non nul:			*
*	    USER_T						*
*	    TOTAL_T					*
*	Macros devant ˆtre d‚j… d‚finies:			*
*	- sndkernel					*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 2/8/1996, v0.862					*
* Tab setting : 11						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-96*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*



	opt	p=68030
	opt	s-		; Pas de table des symboles



*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Contr“le du Soundtracker ------------------------------------------------
NBRSAMPLES_MAXI:	Equ	1+255	; Nombre maximum de samples (+1 vide)
NBRINSTR_MAXI:	Equ	1+255	; Nombre maximum d'instruments (+1 vide)
NBRPATTERNS_MAXI:	Equ	256+1	; Nombre maximum de patterns (+1 vide)
NBRVOLENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de volume (+1 vide)
NBRTONENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de tonalit‚ (+1 vide)
NBRPANENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de panning (+1 vide)

		IfD	NBRVOIES_MAXI
		IfND	NBRTRACK_MAXI
NBRTRACK_MAXI:	Equ	NBRVOIES_MAXI	; Par d‚faut, nbr de pistes = nbr de voies
		EndC
		EndC

CHECK:		Equ	2	; 0 = aucune v‚rification (un peu + rapide, - fiable)
				; 1 = v‚rifie lors de chaque op‚ration que les
				;     r‚sultats sont bien dans les bons intervalles
				; 2 = Idem que 1 mais v‚rifie aussi l'int‚grit‚
				;     des paramŠtres donn‚s.

		IfNe	CHECK
PERIOD_MAXI:	Equ	32575
PERIOD_MINI:	Equ	71
		EndC

HANDLE_ENVELOPES:	Equ	1	; 1 = gestion des enveloppes
				; 0 = pas de gestion (plus rapide)

		IfNe	HANDLE_ENVELOPES
		  IfNe	CHECK>1
ENV_COMMANDMAX:	Equ	16	; Nombre de commandes maximum par tick
				; dans une enveloppe (permet d'‚viter
				; un blocage si une enveloppe a une
				; boucle sans fin sans commande Wait).
		  EndC
		EndC

;--- Num‚ros des commandes des enveloppes ------------------------------------
ENV_COM_END:	Equ	$00
ENV_COM_JUMP:	Equ	$01
ENV_COM_WAIT:	Equ	$02
ENV_COM_SET_COUNTER:	Equ	$03
ENV_COM_LOOP:	Equ	$04
ENV_COM_KEY_OFF:	Equ	$05

ENV_COM_SET_VOLUME:	Equ	$80
ENV_COM_SET_VOL_STEP	Equ	$81
ENV_COM_SET_VOL_SPD	Equ	$82
ENV_COM_TREMOLO_ON	Equ	$83
ENV_COM_TREMOLO_OFF	Equ	$84
ENV_COM_SET_TRM_WID:	Equ	$85
ENV_COM_SET_TRM_SPD:	Equ	$86
ENV_COM_TREMOR_ON:	Equ	$87
ENV_COM_TREMOR_OFF:	Equ	$88
ENV_COM_SET_TREMOR_1:	Equ	$89
ENV_COM_SET_TREMOR_2:	Equ	$8A

ENV_COM_SET_TONE:	Equ	$A0
ENV_COM_SET_TON_STEP:	Equ	$A1
ENV_COM_SET_TON_SPD:	Equ	$A2
ENV_COM_VIBRATO_ON:	Equ	$A3
ENV_COM_VIBRATO_OFF:	Equ	$A4
ENV_COM_SET_VIB_WID:	Equ	$A5
ENV_COM_SET_VIB_SPD:	Equ	$A6

ENV_COM_SET_PANNING:	Equ	$C0
ENV_COM_SET_PAN_STEP:	Equ	$C1
ENV_COM_SET_PAN_SPD:	Equ	$C2



*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;ððð Pour le soundtracker ðððððððððððððððððððððððððððððððððððððððððððððððððððð

;--- Initialisation des enveloppes -------------------------------------------
env_initialisation:	Macro
	; ParamŠtres :
	; 1) Registre d'adresse pointant sur le descripteur de la voie
	; 2) 0 si aucune enveloppe … mettre, sinon paramŠtre 3 pris en compte
	; 3) Registre d'adresse pointant sur le nouvel instrument

	IfEq	\2

	clr.w	nevol_t(\1)	; Efface les num‚ros d'enveloppe
	clr.w	neton_t(\1)
	clr.w	nepan_t(\1)

	Else			; R‚initialise tous les paramŠtres

	move.w	volenv_i(\3),nevol_t(\1)	; Enveloppe de volume
	beq.s	.suite1\@
	env_volume_init	\1
.suite1\@:
	move.w	tonenv_i(\3),neton_t(\1)	; Enveloppe de tonalit‚
	beq.s	.suite2\@
	env_tone_init	\1
.suite2\@:
	move.w	panenv_i(\3),nepan_t(\1)	; Enveloppe de panning
	beq.s	.suite3\@
	env_panning_init	\1
.suite3\@:
	EndC

	EndM

env_volume_init:	Macro
	; ParamŠtres:
	; 1) Registre d'adresse pointant sur le descripteur de la voie
	clr.w	ev_waitcpt_t(\1)
	clr.w	ev_loopcpt_t(\1)
	move.w	#$4000,ev_volume_t(\1)
	clr.w	ev_volstep_t(\1)
	move.w	#1,ev_volspeed_t(\1)
	clr.w	ev_volcpt_t(\1)
	clr.b	ev_tremoloflag_t(\1)
	clr.b	ev_tremorflag_t(\1)
	clr.b	ev_tremolospeed_t(\1)
	clr.b	ev_tremolowidth_t(\1)
	clr.b	ev_tremolocpt_t(\1)
	clr.b	ev_tremolotype_t(\1)
	move.b	#3,ev_tremortime1_t(\1)
	move.b	#3,ev_tremortime2_t(\1)
	clr.b	ev_tremorsection_t(\1)
	clr.b	ev_tremorcpt_t(\1)
	clr.w	pevol_t(\1)	; Position dans l'enveloppe … 0
	move.w	#data_e,devol_t(\1)	; Pointeur sur les section courante (Normale ici)
	EndM

env_tone_init:	Macro
	; ParamŠtres:
	; 1) Registre d'adresse pointant sur le descripteur de la voie
	clr.w	et_waitcpt_t(\1)
	clr.w	et_loopcpt_t(\1)
	move.w	#$1000,et_tone_t(\1)
	clr.w	et_tonestep_t(\1)
	move.w	#1,et_tonespeed_t(\1)
	clr.w	et_tonecpt_t(\1)
	clr.b	et_vibratoflag_t(\1)
	clr.b	et_vibratospeed_t(\1)
	clr.b	et_vibratowidth_t(\1)
	clr.b	et_vibratocpt_t(\1)
	clr.b	et_vibratotype_t(\1)
	clr.w	peton_t(\1)	; Position dans l'enveloppe … 0
	move.w	#data_e,deton_t(\1)	; Pointeur sur les section courante (Normale ici)
	EndM

env_panning_init:	Macro
	; ParamŠtres:
	; 1) Registre d'adresse pointant sur le descripteur de la voie
	clr.w	ep_waitcpt_t(\1)
	clr.w	ep_loopcpt_t(\1)
	move.w	#$800,ep_pan_t(\1)
	clr.w	ep_panstep_t(\1)
	move.w	#1,ep_panspeed_t(\1)
	clr.w	ep_pancpt_t(\1)
	clr.w	peton_t(\1)	; Position dans l'enveloppe … 0
	move.w	#data_e,deton_t(\1)	; Pointeur sur les section courante (Normale ici)
	EndM



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Text



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

******************************************************************************
**						          **
*	BibliothŠque des fonctions de contr“le du soundtracker		*
**						          **
******************************************************************************



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Installe le player de .GTK				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_player_on:
	movem.l	d1-a5,-(sp)
	tst.w	gtkpl_flag_installed
	bne	.error		; D‚j… install‚

	move.w	#$ffff,-(sp)
	sndkernel	reserve_track
	addq.l	#2,sp
	tst.w	d0
	bmi	.error2
	move.w	d0,gtkpl_num_track

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Initialise les donn‚es principales du module
	lea	gtkpl_module_inf2,a0	; a0 pointe sur les infos du mod
	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod

	move.w	#1,mod_nbrtrack(a0)
	move.w	#1,mod_songlen(a0)
	clr.w	mod_songrep(a0)
	clr.w	mod_songpos(a0)
	move.w	#NBRPATTERNS_MAXI-1,mod_numpat(a0)	; Le pattern bidon
	clr.w	mod_linepos(a0)
	clr.w	mod_cursongpos(a0)
	clr.w	mod_curlinepos(a0)
	move.w	#6,mod_speed(a0)
	clr.w	mod_patrep(a0)
	move.w	#-1,mod_nbrticks(a0)
	move.w	#1,mod_vblnumber(a0)
	clr.w	mod_vblcpt(a0)
	move.w	#125,-(sp)
	bsr	gtkpl_set_tempo	; Fixe le tempo par d‚faut: 125 BPM
	addq.l	#2,sp

	move.l	#gtkpl_song_bidon,adr_song(a1)
	move.l	#gtkpl_pat_bidon,adr_pattern(a1)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Initialise par d‚faut les adresse des principaux chunks
	lea	gtkpl_sample_bidon,a3	; Les samples
	lea	adr_samples(a1),a2
	move.w	#NBRSAMPLES_MAXI-1,d1
.loop1:	move.l	a3,(a2)+
	dbra	d1,.loop1
	lea	gtkpl_zone_vide,a3	; et leurs buffers de bouclage
	lea	adr_repbuf(a1),a2
	move.w	#NBRSAMPLES_MAXI-1,d1
.loop2:	move.l	a3,(a2)+
	dbra	d1,.loop2

	lea	gtkpl_instr_bidon,a3	; Les instruments
	lea	adr_instrset(a1),a2
	move.w	#NBRINSTR_MAXI-1,d1
.loop3:	move.l	a3,(a2)+
	dbra	d1,.loop3

	lea	gtkpl_volenv_bidon,a3	; Les enveloppes de volume
	lea	adr_evol(a1),a2
	move.w	#NBRVOLENV_MAXI-1,d1
.loop4:	move.l	a3,(a2)+
	dbra	d1,.loop4

	lea	gtkpl_tonenv_bidon,a3	; Les enveloppes de tonalit‚
	lea	adr_eton(a1),a2
	move.w	#NBRTONENV_MAXI-1,d1
.loop5:	move.l	a3,(a2)+
	dbra	d1,.loop5

	lea	gtkpl_panenv_bidon,a3	; Les enveloppes de panning
	lea	adr_epan(a1),a2
	move.w	#NBRPANENV_MAXI-1,d1
.loop6:	move.l	a3,(a2)+
	dbra	d1,.loop6

	lea	gtkpl_pat_bidon,a3	; Les patterns
	lea	adr_pattern(a1),a2
	move.w	#NBRPATTERNS_MAXI-1,d1
.loop7:	move.l	a3,(a2)+
	dbra	d1,.loop7

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	sndkernel	get_track_adr		; On cherche l'adresse de info_track
	move.l	d0,gtkpl_adr_info_track	; Les donn‚es sont ainsi plus rapidement accessibles

	move.w	#1,gtkpl_flag_installed
	move.l	#gtkpl_gestion_partition,-(sp)	; Installe la routine dans le noyau
	sndkernel	add_routine
	addq.l	#4,sp

	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; D‚j… install‚
	bra.s	.fin
.error2:	moveq	#-2,d0		; Plus de piste libre

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	D‚sinstalle le player de .GTK				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_player_off:
	movem.l	d1-a5,-(sp)
	tst.w	gtkpl_flag_installed
	beq.s	.error		; Pas install‚

	bsr	gtkpl_reset_sndtrk_tracks

	move.l	#gtkpl_gestion_partition,-(sp)
	sndkernel	remove_routine
	addq.l	#4,sp

	clr.w	gtkpl_flag_installed
	move.w	gtkpl_module_inf2+mod_nbrtrack,d1	; LibŠre les voies
	subq.w	#1,d1
	lea	gtkpl_num_track,a0

.loop:	move.w	(a0)+,-(sp)
	sndkernel	free_track
	addq.l	#2,sp
	dbra	d1,.loop

	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Reset des voies de soundtrack				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_reset_sndtrk_tracks:
	movem.l	d1-a5,-(sp)
	move.w	#1,gtkpl_flag_stop_vcs
.wait:	tst.w	gtkpl_flag_stop_vcs	; Arrˆte le module en cours et r‚initialise les voies
	bne.s	.wait
	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Convertit un module GT2 en module GT2 version 3 minimum.	*
*	Tous les samples, patterns, etc. sont d‚pack‚s (versions futures)	*
*	ParamŠtres :					*
*	- W type : Type de module … convertir. 0 = GT2 pour l'instant	*
*	- L adrmod : Adresse du module … convertir			*
*	- L adrconv : Adresse du module converti			*
*	Renvoie la taille du module converti dans d0.		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_convert_module:
	CArgs	#52+4,f105.type.w,f105.adrmod.l,f105.adrconv.l

	movem.l	d1-a5,-(sp)
	move.l	f105.adrmod(sp),a0	; ððð> a0 = adresse du module … convertir
	move.l	f105.adrconv(sp),a5	; ððð> a5 = adresse du module converti
	move.w	f105.type(sp),d0	; d0 = type de module
	tst.w	d0		; 0 : .GT2
	beq.s	.cm_gt2
	bra	.error1



;ððð Conversion d'un module .GT2 ððððððððððððððððððððððððððððððððððððððððððððð

.cm_gt2:
	move.l	(a0),d1
	move.l	d1,d3
	and.l	#255,d3		; ððð> d3 = num‚ro de version
	lsr.l	#8,d1
	cmp.l	#'GT2',d1
	bne	.error4
	move.l	a5,a4		; ððð> a4 pointe au d‚but du module converti

;--- Copie les chunks --------------------------------------------------------
.copychk:
	move.l	4(a0),d1
	subq.l	#1,d1
	swap	d1
.ccloop1a:	swap	d1
.ccloop1b:	move.b	(a0)+,(a5)+
	dbra	d1,.ccloop1b
	swap	d1
	dbra	d1,.ccloop1a

;--- D‚tection de la fin -----------------------------------------------------
.newchunk:
	move.l	(a0),d1
	cmp.l	#'ENDC',d1		; Chunk de fin ?
	beq.s	.finmod		; Oui, c'est fini
	cmp.w	#3,d3
	bge.s	.copychk		; Si version ò 3, il DOIT y avoir un chunk de fin

	lea	gtkpl_gt2_chunknames,a1	; Sinon, on teste pour voir si on a pas d‚pass‚ la fin
.tcloop:	move.l	(a1)+,d2		; Regarde dans la liste des noms de chunk
	beq.s	.finmod		; On n'a pas reconnu le nom, ‡a doit ˆtre la fin
	cmp.l	d1,d2		; Cherche si le nom du chunk est connu
	bne.s	.tcloop		; C'est pas celui-l…, teste le suivant
	bra.s	.copychk		; Chunk identifi‚, on peut le copier

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.finmod:
	cmp.w	#3,d3		; Teste le num‚ro de version
	bge.s	.endchunk
	move.b	#3,3(a4)		; On en est au moins … la No 3 maintenant

.endchunk:	move.l	#'ENDC',(a5)+	; Cr‚e le chunk de fin s'il n'y en a pas
	move.l	#12,(a5)+
	move.l	a5,d0		; Et calcule la longueur totale du module.
	sub.l	a4,d0
	addq.l	#4,d0
	move.l	d0,(a5)+
	bra.s	.fin



;ððð Les erreurs ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð

.error1:
	moveq	#-1,d0		; -1 : Type de module invalide
	bra.s	.fin
.error4:
	moveq	#-4,d0		; -4 : Format de module invalide

.fin:
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Effectue le bouclage de tous les samples d'un module au	*
*	format interne.					*
*	ParamŠtres :					*
*	- L adrmod : Adresse du module				*
*	- L adrbuf : Adresse d'une zone pour les buffers (256Ko maxi)	*
*	- L adradrbuf : Adresse d'un tableau de NBRSAMPLES_MAXI Longs	*
*		destin‚ … contenir les adresses des buffers. Si 	*
*		cette adresse est nulle, les buffers sont directement	*
*		assign‚s au module en cours de replay, ainsi que	*
*		les adresses des samples.			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_make_rb_module:
	CArgs	#52+4,f106.adrmod.l,f106.adrbuf.l,f106.adradrbuf.l

	movem.l	d1-a5,-(sp)
	move.l	f106.adrmod(sp),a0	; a0 = adresse du module

	move.l	(a0),d1		; Teste si le module est un GT2
	lsr.l	#8,d1		; dont le num‚ro de version est
	cmp.l	#'GT2',d1		; sup‚rieur ou ‚gal … 3
	bne	.error1
	cmp.b	#3,3(a0)
	blt	.error1

	move.l	f106.adrbuf(sp),a1	; a1 = adresse des buffers
	move.l	f106.adradrbuf(sp),d1	; a2 = adresse du bloc d'adresses des buffers
	bne.s	.aabufok
	move.l	#gtkpl_module_inf1+adr_repbuf,d1	; Assigne les pointeurs au module
.aabufok:	move.l	d1,a2
	lea	gtkpl_zone_vide,a3	; a3 pointe sur une zone vide (unique buffer pour les samples vides)

	move.w	#NBRSAMPLES_MAXI-1,d1
.fill:	move.l	#gtkpl_sample_bidon,adr_samples-adr_repbuf(a2)
	move.l	a3,(a2)+		; Par d‚faut, tous les buffers sont vides
	dbra	d1,.fill
	lea	-NBRSAMPLES_MAXI*4(a2),a2

;--- Recherche des samples dans le module et bouclage de ces samples ---------
.chunk_loop:
	cmp.l	#'ENDC',(a0)	; C'‚tait le dernier chunk ?
	beq.s	.module_end	; Oui, c'est fini
	cmp.l	#'SAMP',(a0)	; C'est un sample ?
	bne.s	.next_chunk	; Non, suivant

	move.w	number_s(a0),d1	; d1 = num‚ro du sample
	cmp.w	#NBRSAMPLES_MAXI-1,d1
	bgt.s	.error2		; Trop de samples!
	move.l	a0,(adr_samples-adr_repbuf,a2,d1.w*4)	; Stoque l'adresse du sample
	tst.l	length_s(a0)
	beq.s	.finboucle		; Sample vide, pas de bouclage … faire
	move.l	a1,(a2,d1.w*4)	; Sinon stoque l'adresse du buffer dans la table
	move.w	nbits_s(a0),d2
	lsr.w	#3,d2		; Bits => Octets: 8 => 1 et 16 => 2
	move.w	d2,-(sp)
	move.l	replen_s(a0),-(sp)
	move.l	repeat_s(a0),-(sp)
	move.l	length_s(a0),-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)		; \
	add.l	#data_s,(sp)	; / Adresse des donn‚es du sample
	sndkernel	make_rbuffer	; Bouclage
	lea	22(sp),sp
	add.w	#1024,a1		; Adresse du buffer suivant
.finboucle:

.next_chunk:
	add.l	4(a0),a0		; Adresse du chunk suivant
	bra.s	.chunk_loop

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.module_end:
	moveq	#0,d0		; Aucune erreur d‚tect‚e.
	bra.s	.fin

.error1:	moveq	#-1,d0		; Ce n'est pas un module au format interne
	bra.s	.fin

.error2:	moveq	#-2,d0		; Trop de samples

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande les adresses des samples et des buffers de bouclage	*
*	du module en cours. Attention, les adresses de samples sont	*
*	en fait les adresses CHUNKS des samples. Les donn‚es se trouvent	*
*	data_s octets plus loin.				*
*	ParamŠtres :					*
*	- L ptr : Pointe sur une zone de 256 L + 256 L qui recevra	*
*		les adresses des samples et les adresses des buffers	*
*		de bouclage. (256 … remplacer par NBRSAMPLES_MAXI	*
*		‚videmment).				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_get_adr_samples:
	CArgs	#52+4,f107.ptr.l

	movem.l	d1-a5,-(sp)
	move.l	f107.ptr(sp),a0	; a0 = pointeur
	lea	gtkpl_module_inf1+adr_samples,a1
	moveq	#NBRSAMPLES_MAXI/2-1,d1	; Les adresses des samples
.loop1:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d1,.loop1
	moveq	#0,d0
	lea	gtkpl_module_inf1+adr_repbuf,a1
	moveq	#NBRSAMPLES_MAXI/2-1,d1	; Puis celles de leurs buffers
.loop2:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d1,.loop2
	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Fixe les adresses des samples et des buffers de bouclage	*
*	du module en cours. Si une des adresse est nulle, elle		*
*	n'est pas modifi‚e. De mˆme que pour la fonction pr‚c‚dente,	*
*	il s'agit des CHUNKS des samples et non des donn‚es elles-mˆme.	*
*	ParamŠtres :					*
*	- L ptr : Pointe sur une zone de 256 L + 256 L qui contient	*
*		les adresses des samples et les adresses des buffers	*
*		de bouclage. (256 … remplacer par NBRSAMPLES_MAXI	*
*		‚videmment).				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_set_adr_samples:
	CArgs	#52+4,f108.ptr.l

	movem.l	d1-a5,-(sp)
	move.l	f108.ptr(sp),a0	; a0 = pointeur

	lea	gtkpl_module_inf1+adr_samples,a1
	move.w	#NBRSAMPLES_MAXI-1,d1	; Les adresses des samples
.loop1:	move.l	(a0)+,d2
	beq.s	.null1
	move.l	d1,(a1)
.null1:	addq.l	#4,a1
	dbra	d1,.loop1

	lea	gtkpl_module_inf1+adr_repbuf,a1
	move.w	#NBRSAMPLES_MAXI-1,d1	; Puis celles de leurs buffers
.loop2:	move.l	(a0)+,d2
	beq.s	.null2
	move.l	d1,(a1)
.null2:	addq.l	#4,a1
	dbra	d1,.loop2

	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Initialise un module au format interne et commence le replay	*
*	ParamŠtres :					*
*	- L adrmod : Adresse du module				*
*	- L repbuf : Adresse des buffers de r‚p‚tition des samples	*
*		destin‚s … ˆtre calcul‚s (1 Ko/sample, 256 Ko maxi).	*
*		Si cette adresse est nulle, rien n'est chang‚, les	*
*		buffers ne sont pas recalcul‚s.			*
*	- W songpos : Position de d‚part				*
*	- W linepos : Ligne de d‚part				*
*	*** Utilise gtkpl_temp_data				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_new_module:
	CArgs	#52+4,f109.adrmod.l,f109.repbuf.l,f109.songpos.w,f109.linepos.w

	movem.l	d1-a5,-(sp)
	move.l	f109.adrmod(sp),a0	; a0 = adresse du module

	move.l	(a0),d1		; Teste si le module est un GT2
	lsr.l	#8,d1		; dont le num‚ro de version est
	cmp.l	#'GT2',d1		; sup‚rieur ou ‚gal … 3
	bne	.error1
	cmp.b	#3,3(a0)
	blt	.error1

	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod
	lea	gtkpl_module_inf2,a2	; a2 pointe sur les infos du mod

	bsr	gtkpl_stop_module	; Arrˆte ce qu'il y avait avant

	move.l	f109.repbuf(sp),d1
	beq.s	.calcbuffin
	pea	0.l
	move.l	d1,-(sp)
	pea	(a0)
	bsr	gtkpl_make_rb_module
	lea	12(sp),sp
.calcbuffin:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; R‚servation des pistes
	move.l	a0,a4		; Recherche le chunk Pattern Set
.pscloop:	cmp.l	#'ENDC',(a4)
	beq	.error3		; Fin du module atteinte et pas de Pattern Set!
	cmp.l	#'PATS',(a4)
	beq.s	.pscfound
	add.l	4(a4),a4		; Chunk suivant
	bra.s	.pscloop

.pscfound:	move.w	8(a4),d7		; ððð> d7 = nombre de pistes
	cmp.w	#NBRTRACK_MAXI,d7
	bgt	.error5		; Trop de pistes!
	move.w	d7,d1		; Nombre de pistes … r‚server
	subq.w	#2,d1
	moveq	#1,d2		; d2 = compteur de pistes d‚j… r‚serv‚es
	bmi.s	.ok		; 1 piste, elle est d‚j… r‚serv‚e
	lea	gtkpl_num_track+2,a3

.loop:	move.w	#$ffff,-(sp)
	sndkernel	reserve_track
	addq.l	#2,sp
	tst.w	d0
	bmi	.error2
	move.w	d0,(a3)+		; Piste r‚serv‚e
	addq.w	#1,d2
	move.w	d2,mod_nbrtrack(a2)
	dbra	d1,.loop
.ok:	move.w	d7,mod_nbrtrack(a2)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Fixe les balances
	lea	gtkpl_num_track,a3
	lea	234(a0),a4
	move.w	(a4)+,d1		; Nombre de piste dont on a le panning
	beq.s	.finbal		; Y en a pas ?
	cmp.w	d7,d1		; Y en a trop ?
	ble.s	.ok2
	move.w	d7,d1		; Oui, on se limite aux piste des patterns
.ok2:	subq.w	#1,d1		; d1 = compteur de pistes
.loopbal:
	move.w	(a3)+,d0		; Num‚ro de piste pour cette voie
	mulu.w	#next_t,d0
	move.w	(a4)+,([gtkpl_adr_info_track],d0.l,bal_t)
	eor.w	#$fff,d3		; Ca permet de faire changer la
	eor.w	d3,d2		; balance que 1 voie sur 2 (0 / FFF)
	dbra	d1,.loopbal
.finbal:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Trouve tous les chunks des instruments
	move.l	a0,a4
.insloop:	cmp.l	#'ENDC',(a4)
	beq.s	.insend		; Fin du module atteinte, plus d'instrument
	cmp.l	#'INST',(a4)
	bne.s	.next_ins
	move.w	8(a4),d1		; Num‚ro de l'instrument
	cmp.w	#NBRINSTR_MAXI-1,d1
	bgt	.error7		; Trop d'instrument!
	move.l	a4,(adr_instrset,a1,d1.w*4)	; Stoque son adresse
.next_ins:
	add.l	4(a4),a4		; Chunk suivant
	bra.s	.insloop
.insend:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Trouve tous les chunks des enveloppes
	move.l	a0,a4
.venvloop:	cmp.l	#'ENDC',(a4)
	beq.s	.venvend		; Fin du module atteinte, plus d'enveloppe de volume
	cmp.l	#'VENV',(a4)
	bne.s	.next_venv
	move.w	number_e(a4),d1	; Num‚ro de l'enveloppe
	cmp.w	#NBRVOLENV_MAXI-1,d1
	bgt	.error8		; Trop d'enveloppes!
	move.l	a4,(adr_evol,a1,d1.w*4)	; Stoque son adresse
.next_venv:
	add.l	chunksz_e(a4),a4		; Chunk suivant
	bra.s	.venvloop
.venvend:
	move.l	a0,a4
.tenvloop:	cmp.l	#'ENDC',(a4)
	beq.s	.tenvend		; Fin du module atteinte, plus d'enveloppe de tonalit‚
	cmp.l	#'TENV',(a4)
	bne.s	.next_tenv
	move.w	number_e(a4),d1	; Num‚ro de l'enveloppe
	cmp.w	#NBRTONENV_MAXI-1,d1
	bgt	.error8		; Trop d'enveloppes!
	move.l	a4,(adr_evol,a1,d1.w*4)	; Stoque son adresse
.next_tenv:
	add.l	chunksz_e(a4),a4		; Chunk suivant
	bra.s	.tenvloop
.tenvend:
	move.l	a0,a4
.penvloop:	cmp.l	#'ENDC',(a4)
	beq.s	.penvend		; Fin du module atteinte, plus d'enveloppe de panning
	cmp.l	#'PENV',(a4)
	bne.s	.next_penv
	move.w	number_e(a4),d1		; Num‚ro de l'enveloppe
	cmp.w	#NBRPANENV_MAXI-1,d1
	bgt	.error8		; Trop d'enveloppes!
	move.l	a4,(adr_evol,a1,d1.w*4)	; Stoque son adresse
.next_penv:
	add.l	chunksz_e(a4),a4		; Chunk suivant
	bra.s	.penvloop
.penvend:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Trouve le chunk de la song
	move.l	a0,a4
.scloop:	cmp.l	#'ENDC',(a4)
	beq	.error4		; Fin du module atteinte et pas de Song Chunk!
	cmp.l	#'SONG',(a4)
	beq.s	.scfound
	add.l	4(a4),a4		; Chunk suivant
	bra.s	.scloop

.scfound:	move.l	a4,a5		; ððð> a5 sert plus tard
	add.w	#12,a4		; Stoque l'adresse de la song, pas du chunk
	move.l	a4,gtkpl_temp_data	; Dans un buffer provisoire

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Trouve tous les chunks des patterns
	move.l	a0,a4
.ploop:	cmp.l	#'ENDC',(a4)
	beq.s	.pend		; Fin du module atteinte, plus de pattern
	cmp.l	#'PATD',(a4)
	bne.s	.next_pat
	move.w	8(a4),d1		; Num‚ro du pattern
	cmp.w	#NBRPATTERNS_MAXI-1-1,d1
	bgt	.error6		; Trop de patterns!
	move.l	a4,(adr_pattern,a1,d1.w*4)	; Stoque son adresse
.next_pat:
	add.l	4(a4),a4		; Chunk suivant
	bra.s	.ploop
.pend:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	bsr	gtkpl_reset_sndtrk_tracks	; Reset les pistes r‚serv‚es

	move.w	8(a5),mod_songlen(a2)
	move.w	10(a5),mod_songrep(a2)
	move.w	f109.songpos(sp),d1
	move.w	d1,mod_songpos(a2)
	move.w	f109.linepos(sp),mod_linepos(a2)
	move.w	d1,mod_cursongpos(a2)
	move.w	f109.linepos(sp),mod_curlinepos(a2)
	move.l	gtkpl_temp_data,adr_song(a1)
	move.w	([adr_song,a1],d1.w*2),mod_numpat(a2)
	clr.w	mod_patrep(a2)
	move.w	#-1,mod_nbrticks(a2)
	clr.w	mod_vblcpt(a2)
	move.w	228(a0),mod_speed(a2)	; Speed dans le 1er chunk
	move.w	230(a0),-(sp)
	bsr	gtkpl_set_tempo	; Fixe le tempo
	addq.l	#2,sp
	move.w	232(a0),-(sp)
	sndkernel	set_master_vol	; Fixe le master volume
	addq.l	#2,sp
	moveq	#0,d0		; Pas d'erreur visiblement
	bra.s	.fin

.error1:	moveq	#-1,d0		; Le module n'est pas au format interne
	bra.s	.fin

.error2:	moveq	#-2,d0		; Il n'y a pas assez de voies libre
	bsr	gtkpl_stop_module
	bra.s	.fin

.error3:	moveq	#-3,d0		; Chunk de Pattern Set manquant
	bsr	gtkpl_stop_module
	bra.s	.fin

.error4:	moveq	#-4,d0		; Chunk de Song manquant
	bsr	gtkpl_stop_module
	bra.s	.fin

.error5:	moveq	#-5,d0		; Trop de pistes
	bra.s	.fin

.error6:	moveq	#-6,d0		; Trop de patterns
	bsr	gtkpl_stop_module
	bra.s	.fin

.error7:	moveq	#-7,d0		; Trop d'instruments
	bsr	gtkpl_stop_module
	bra.s	.fin

.error8:	moveq	#-8,d0		; Trop d'enveloppes
	bsr	gtkpl_stop_module

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Arrˆte de jouer le module en cours. Un nouveau module devra	*
*	ˆtre r‚initialis‚ si on veut jouer quelque chose aprŠs.	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_stop_module:
	movem.l	d1-a5,-(sp)

	lea	gtkpl_module_inf2,a0	; a0 pointe sur les infos du mod
	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod

	bsr	gtkpl_reset_sndtrk_tracks

	move.w	gtkpl_module_inf2+mod_nbrtrack,d1	; LibŠre les voies sauf la 1Šre
	subq.w	#2,d1
	bmi.s	.ok
	lea	gtkpl_num_track+2,a2

.loop:	move.w	(a2)+,-(sp)
	sndkernel	free_track
	addq.l	#2,sp
	dbra	d1,.loop

.ok:	move.w	#1,mod_nbrtrack(a0)	; On lui fait jouer un module bidon
	move.w	#1,mod_songlen(a0)
	clr.w	mod_songrep(a0)
	clr.w	mod_songpos(a0)
	move.w	#NBRPATTERNS_MAXI-1,mod_numpat(a0)	; Le pattern bidon
	clr.w	mod_linepos(a0)
	clr.w	mod_cursongpos(a0)
	clr.w	mod_curlinepos(a0)
	clr.w	mod_patrep(a0)
	clr.w	mod_vblcpt(a0)
	move.w	#1,mod_vblnumber(a0)
	move.l	#gtkpl_song_bidon,adr_song(a1)
	move.l	#gtkpl_pat_bidon,adr_pattern(a1)
	move.w	#-1,mod_nbrticks(a0)
	move.w	#6,mod_speed(a0)

	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Mets le module en cours en pause				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_pause_module:
	movem.l	d1-a5,-(sp)
	cmp.w	#2,gtkpl_flag_stop_vcs
	beq.s	.error
	cmp.w	#3,gtkpl_flag_stop_vcs
	beq.s	.error

.wait:	tst.w	gtkpl_flag_stop_vcs	; Attend qu'on soit bien en phase normale
	bne.s	.wait
	move.w	#2,gtkpl_flag_stop_vcs	; Ordre de pause
.wait2:	cmp.w	#3,gtkpl_flag_stop_vcs	; Attend que l'ordre ait ‚t‚ re‡u
	bne.s	.wait2
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; On ‚tait d‚j… en pause

.fin	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Remet un module en pause en marche			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_cont_module:
	movem.l	d1-a5,-(sp)

.wait:	cmp.w	#3,gtkpl_flag_stop_vcs	; D‚j… totalement en pause ?
	beq.s	.ok		; Oui, c'est bon, on peut donner l'ordre de reprise
	cmp.w	#2,gtkpl_flag_stop_vcs
	bne.s	.error		; Bah on n'‚tait mˆme pas en pause
	bra.s	.wait		; On avait donn‚ l'ordre de pause, mais il n'est
				; pas encore re‡u par le tracker, on attend un peu.

.ok:	move.w	#4,gtkpl_flag_stop_vcs
.wait2:	tst.w	gtkpl_flag_stop_vcs
	bne.s	.wait2
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; On n'‚tait pas en pause

.fin	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Change la position d'un module en cours de replay		*
*	ParamŠtres :					*
*	- W songpos : Nouvelle position 				*
*	- W linepos : Nouvelle ligne				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_change_modpos:
	CArgs	#52+4,f10d.songpos.w,f10d.linepos.w

	movem.l	d1-a5,-(sp)

	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod
	lea	gtkpl_module_inf2,a2	; a2 pointe sur les infos du mod

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Position
	move.w	f10d.songpos(sp),d1
	cmp.w	mod_songlen(a2),d1
	bge.s	.error1
	move.w	d1,mod_songpos(a2)
	move.w	d1,mod_cursongpos(a2)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Ligne
	move.w	([adr_song,a1],d1.w*2),d1	; Cherche l'adresse du pattern
	move.l	(adr_pattern,a1,d1.w*4),a3	; de la nouvelle position
	move.w	f10d.linepos(sp),d1
	cmp.w	nlines_p(a3),d1
	bge.s	.error2
	move.w	d1,mod_linepos(a2)
	move.w	d1,mod_curlinepos(a2)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Force le tracker … red‚marer … ce point le plus t“t possible
	move.w	([adr_song,a1],d1.w*2),mod_numpat(a2)
	clr.w	mod_patrep(a2)	; Pas de Pattern delay
	move.w	#-1,mod_nbrticks(a2)	; Le prochain tick, on attaque la nouvelle ligne
	clr.w	mod_vblcpt(a2)	; Nouveau tick
	moveq	#0,d0
	bra.s	.fin

.error1:	moveq	#-1,d0		; Position hors de la song
	bra.s	.fin

.error2:	moveq	#-2,d0		; Num‚ro de ligne hors du pattern

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande la position d'un module en cours de replay.		*
*	R‚sultat dans d0					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_get_modsongpos:
	moveq	#0,d0
	move.w	gtkpl_module_inf2+mod_cursongpos,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande le num‚ro de la ligne courante dans un module en cours	*
*	de replay.						*
*	R‚sultat dans d0					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_get_modlinepos:
	moveq	#0,d0
	move.w	gtkpl_module_inf2+mod_curlinepos,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Fixe le tempo pour le module				*
*	ParamŠtre :					*
*	- W Tempo : Tempo en BPM				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_set_tempo:
	CArgs	#52+4,f111.tempo.w

	movem.l	d1-a5,-(sp)

	move.w	f111.tempo(sp),d4
	move.w	d4,gtkpl_module_inf2+mod_tempo
	mulu.w	#4*6,d4
	sndkernel	get_replay_freq
	mulu.w	#60,d0
	divu.w	d4,d0		; d0 = freq.repl * 60 s / (tempo * 4 lig * 6 ticks)
	move.l	d0,d3		;    = nombre de spl par tick
	clr.w	d3
	divu.w	d4,d3		; d3 = nbr de spl par tick, frac
	swap	d3
	move.w	d0,d3
	swap	d3		; d3 = nbr de spl par tick * $10000
	move.l	#1200-1,d4
	add.w	d0,d4
	divu.w	#1200,d4		; d4 = splpartick/1200 arrondi par excŠs
	ext.l	d4
	divu.l	d4,d3		; d3 = Nbr de spl par VBL * $10000
	move.l	d3,gtkpl_vblsize_int		; Stoque d'un coup les parties entiŠre et fractionnaire
	move.w	d4,gtkpl_module_inf2+mod_vblnumber
	swap	d3
	move.w	d3,-(sp)
	sndkernel	set_vblsize
	addq.l	#2,sp
	moveq	#0,d0

	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Permet de savoir le tempo du module dans d0 (en BPM).		*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_get_tempo:
	movem.l	d1-a5,-(sp)

	moveq	#0,d0
	move.w	gtkpl_module_inf2+mod_tempo,d0

	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Demande l'adresse du flag de synchro pour d‚mos                   *
*	R‚sultat dans d0					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_get_synchro_adr:
	move.l	#gtkpl_demo_synchro,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Gestion de la partition pour modules .GT2			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Cette routine est appel‚e sous interruption, par l'interm‚diaire	*
*	du noyau.						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkpl_gestion_partition:

	movem.l	d0-a6,-(sp)

	lea	gtkpl_module_inf2,a0	; a0 pointe sur le bloc 2 d'informations (mod)
	lea	gtkpl_module_inf1,a1	; a1 pointe sur le bloc 1 d'informations (adr)

	addq.w	#1,mod_vblcpt(a0)	; Compteur de VBL pour faire un tick
	move.w	mod_vblnumber(a0),d0
	cmp.w	mod_vblcpt(a0),d0
	bgt	gtkpl_fin_gestion_partition	; Tick pas fini : rien … faire
	clr.w	mod_vblcpt(a0)

	lea	gtkpl_per_table,a5	; a5 pointe sur la table des p‚riodes

;--- Demande d'arrˆt de toutes les voies ? -----------------------------------
	tst.w	gtkpl_flag_stop_vcs
	beq	gtkpl_new_vbl
	cmp.w	#1,gtkpl_flag_stop_vcs	; Ordre d'arrˆt
	beq.s	.stop
	cmp.w	#2,gtkpl_flag_stop_vcs	; Ordre de pause (volume … 0)
	beq	.pause
	cmp.w	#4,gtkpl_flag_stop_vcs	; Ordre de fin de pause
	beq	.finpause
	bra	gtkpl_fin_gestion_partition		; D‚j… en pause, on ne fait rien

;--- R‚initialise les voies --------------------------------------------------
.stop:	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	lea	gtkpl_zone_vide,a2
	lea	gtkpl_num_track,a3
.loop:
	move.w	(a3)+,d1
	mulu.w	#next_t,d1
	lea	([gtkpl_adr_info_track],d1.l),a4
	clr.w	vol_t(a4)
;	move.w	#$800,bal_t(a4)	; La balance n'est cependant pas r‚initialis‚e
	move.l	a2,adrsam_t(a4)
	clr.l	pos_t(a4)
	clr.w	finepos_t(a4)
	clr.l	reppos_t(a4)
	move.l	#2,replen_t(a4)
	move.l	#gtkpl_zone_vide,rbuffer_t(a4)
	clr.w	c_n_t(a4)
	clr.w	c_i_t(a4)
	clr.w	c_e_t(a4)
	clr.w	c_v_t(a4)
	move.w	#0,ninstr_t(a4)
	clr.w	norm_f_t(a4)
	clr.w	norm_v_t(a4)
	move.w	#48,curnote_t(a4)
	move.w	#$1ac0,pernote_t(a4)
	clr.w	vollnot_t(a4)
	clr.w	volenot_t(a4)
	clr.w	portspd_t(a4)
	move.w	#48,note2sl_t(a4)
	move.w	#$1ac0,per2sl_t(a4)
	clr.b	vibspd_t(a4)
	clr.b	vibcpt_t(a4)
	clr.b	vibamp_t(a4)
	clr.b	vibwav_t(a4)
	clr.b	tremspd_t(a4)
	clr.b	tremcpt_t(a4)
	clr.b	tremamp_t(a4)
	clr.b	tremwav_t(a4)
	clr.w	tremorc_t(a4)
	move.b	#3,tremor1_t(a4)
	move.b	#6,tremor2_t(a4)
	clr.w	ploopp_t(a4)
	clr.w	ploops_t(a4)
	clr.w	ploopn_t(a4)
	env_initialisation	a4,0
	clr.w	flag_autotempo_t(a4)
	clr.w	flag_autoperiod_t(a4)
	dbra	d0,.loop
	clr.w	gtkpl_flag_stop_vcs	; On a fini le nettoyage
	bra	gtkpl_fin_gestion_partition

;--- Mise en pause -----------------------------------------------------------
.pause:	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	lea	gtkpl_pause_backup,a2
	lea	gtkpl_num_track,a3
.loop2:
	move.w	(a3)+,d1
	mulu.w	#next_t,d1
	lea	([gtkpl_adr_info_track],d1.l),a4
	move.l	pos_t(a4),(a2)+
	move.l	reppos_t(a4),(a2)+
	move.w	vol_t(a4),(a2)+
	clr.l	pos_t(a4)
	clr.l	reppos_t(a4)
	clr.w	vol_t(a4)
	dbra	d0,.loop2
	move.w	#3,gtkpl_flag_stop_vcs	; Signale qu'on est bien en pause
	bra	gtkpl_fin_gestion_partition

;--- Reprise aprŠs une pause -------------------------------------------------
.finpause:	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	lea	gtkpl_pause_backup,a2
	lea	gtkpl_num_track,a3
.loop3:
	move.w	(a3)+,d1
	mulu.w	#next_t,d1
	lea	([gtkpl_adr_info_track],d1.l),a4
	move.l	(a2)+,pos_t(a4)
	move.l	(a2)+,reppos_t(a4)
	move.w	(a2)+,vol_t(a4)
	dbra	d0,.loop3
	clr.w	gtkpl_flag_stop_vcs	; Signale qu'on est bien reparti

;ððð Nouvelle VBL, teste si on a une nouvelle ligne, position etc ðððððððððððð
gtkpl_new_vbl:
	move.w	mod_nbrticks(a0),d0	; Nouvelle vbl
	addq.w	#1,d0
	cmp.w	mod_speed(a0),d0	; Fin de la ligne courante ?
	blt	.suite_ligne
	moveq	#0,d0
	tst.w	mod_patrep(a0)	; R‚p‚tition de la ligne ?
	beq.s	.newline		; Non, on s'en fout

	subq.w	#1,mod_patrep(a0)	; R‚p‚tition -1
	move.w	d0,mod_nbrticks(a0)
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie
	bra	gtkpl_pas_seulement_1ere_vbl	; ... puis on passe … la suite

.newline:	move.w	mod_songpos(a0),mod_cursongpos(a0)	; Actualise la position
	move.w	mod_linepos(a0),mod_curlinepos(a0)
	clr.w	mod_flagnewpos(a0)	; Indique que la position reste la mˆme pour le moment
	move.w	mod_numpat(a0),d3	; Met dans chaque descripteur de voie une partie de la ligne
	move.l	(adr_pattern,a1,d3.w*4),a4	; a4 pointe sur le chunk du pattern
	move.w	mod_linepos(a0),d1
	move.w	mod_nbrtrack(a0),d3
	mulu.w	#5,d3
	mulu.w	d1,d3
	lea	data_p(a4,d3.l),a2	; a2 contient l'adresse de la nouvelle ligne
	move.w	mod_nbrtrack(a0),d3
	subq.w	#1,d3		; d3 contient le nombre de voies -1
	move.l	a4,-(sp)		; Sauve a4 (chunk du pattern)
	lea	gtkpl_num_track,a4
.loop:
	move.w	(a4)+,d4
	mulu.w	#next_t,d4
	lea	([gtkpl_adr_info_track],d4.l),a3	; a3 pointe le descripteur de voie
	move.b	(a2)+,c_n_t+1(a3)	; Recopie la note
	move.b	(a2)+,c_i_t+1(a3)	; Recopie l'instrument
	move.w	(a2)+,c_e_t(a3)	; Recopie l'effet
	move.b	(a2)+,c_v_t+1(a3)	; Recopie la commande de volume
	add.w	#next_t,a3		; Voie suivante
	dbra	d3,.loop
	move.l	(sp)+,a4		; R‚cupŠre a4 (chunk du pattern)

	addq.w	#1,d1		; Calcule la prochaine ligne
	cmp.w	nlines_p(a4),d1	; Fin du pattern ?
	blt.s	.suite_pos
	moveq	#0,d1
	move.w	mod_songpos(a0),d2	; Oui, nouvelle position
	addq.w	#1,d2
	cmp.w	mod_songlen(a0),d2	; Fin de la song ?
	blt.s	.suite_song
	move.w	mod_songrep(a0),d2	; Oui, bouclage
.suite_song:
	move.w	d2,mod_songpos(a0)
	move.w	([adr_song,a1],d2.w*2),mod_numpat(a0)	; Trouve le nouveau pattern
.suite_pos:
	move.w	d1,mod_linepos(a0)	; Pointe sur la ligne suivante
.suite_ligne:
	move.w	d0,mod_nbrticks(a0)

;ððð Passe aux crible toutes les voies ððððððððððððððððððððððððððððððððððððððð
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie
	tst.w	d0		; C'est la premiŠre VBL ?
	bne	gtkpl_pas_seulement_1ere_vbl
	tst.w	mod_patrep(a0)	; Sinon, c'est en cours de r‚p‚tition ?
	bne	gtkpl_pas_seulement_1ere_vbl

gtkpl_premvbl_loop:			; Boucle de test si c'est la premiŠre vbl
;--- D‚code les diff‚rentes parties d'une ligne -----------------------------
	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	sub.w	d7,d0
	lea	gtkpl_num_track,a3
	move.w	(a3,d0.w*2),d0
	mulu.w	#next_t,d0
	lea	([gtkpl_adr_info_track],d0.l),a3	; a3 pointe sur les informations des voies

	move.w	c_n_t(a3),d0	; d0 = note
	move.w	c_i_t(a3),d1	; d1 = instrument
	move.w	c_e_t(a3),d2	; d2 = effet

	tst.w	d1
	bne.s	gtkpl_instrum	; S'il y a instrument
	tst.w	d0
	bne	gtkpl_pas_instrument	; S'il y a note sans instr
	tst.w	d2
	bne	gtkpl_effets1	; Seulement l'effet
	tst.w	c_v_t(a3)
	beq	fx_fin1		; Pas de volume on se tire
	bra	gtkpl_effets1
	
;--- Instrument d‚tect‚ ------------------------------------------------------
gtkpl_instrum:
	move.w	d2,d3
	and.w	#$FF00,d3		; d3 = num‚ro de l'effet 2 chiffres
	cmp.w	#$900,d3		; Note delay, on s'en va directos
	beq	gtkpl_effets1_no_vol

	tst.w	d1		; Y a-t-il un instrument ?
	beq.s	gtkpl_pas_instrument
	move.w	d1,instr_t(a3)	; Oui, il devient l'instrument courant
	move.l	(adr_instrset,a1,d1.w*4),a2	; a2 pointe sur l'instrument
	move.w	vol_i(a2),d3	; Prend le volume dans d3
	move.w	curnote_t(a3),d4	; Recherche le sample qui va avec la note courante
	move.b	transp_i(a2,d4.w*2),d1
	ext.w	d1
	move.w	d1,transp_t(a3)	; Transposition
	moveq	#0,d1
	move.b	splnum_i(a2,d4.w*2),d1
.fin_s:	move.w	d1,ninstr_t(a3)	; Il devient le sample courant
	lea	([adr_samples,a1,d1.w*4],vol_s),a2
	move.w	(a2),volsam_t(a3)	; Le volume propre du sample
	move.w	d3,norm_v_t(a3)	; Recopie le volume de l'instrument dans la voie
	move.w	2(a2),norm_f_t(a3)
	move.w	autobal_s-vol_s(a2),d3
	bmi.s	.pasbalnc
	move.w	d3,curbal_t(a3)	; Avec la balance
.pasbalnc:	move.w	norm_v_t(a3),d3
	lea	gtkpl_vlin_2_exp,a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Sans oublier le volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant aussi

;--- Note --------------------------------------------------------------------
gtkpl_pas_instrument:
	tst.w	d0
	beq	gtkpl_effets1	; S'il n'y a pas de note on s'en va
	move.w	d2,d3
	and.w	#$FF00,d3		; d3 = num‚ro de l'effet 2 chiffres
	cmp.w	#$300,d3
	beq.s	gtkpl_tone_p
	cmp.w	#$500,d3
	beq.s	gtkpl_tone_p
	cmp.w	#$600,d3
	beq.s	gtkpl_tone_p
	cmp.w	#$AB00,d3
	beq.s	gtkpl_tone_p
	cmp.w	#$1800,d3
	blt.s	gtkpl_pas_tone_p
	cmp.w	#$1B00,d3
	bgt.s	gtkpl_pas_tone_p
gtkpl_tone_p:			; S'il y a un tone portamento (3,5,6,ab,18,19,1a ou 1b)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	add.w	transp_t(a3),d3	; Transposition du sample courant
	sub.w	#24,d3

	IfNe	CHECK
	bpl.s	.check1ok
	moveq	#24,d3
.check1ok:	cmp.w	#127,d3
	ble.s	.check2ok
	moveq	#127,d3
.check2ok:
	EndC

	lsl.w	#3,d3
	add.w	norm_f_t(a3),d3
	move.w	(a5,d3.w*2),per2sl_t(a3)	; on met la p‚riode de c“t‚
	move.w	c_v_t(a3),d3		; Commande de volume ?
	beq	fx_fin1
	lea	gtkpl_vlin_2_exp,a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)		; Volume courant ajust‚
	bra	fx_fin1

gtkpl_pas_tone_p:
	move.w	d0,curnote_t(a3)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	move.w	instr_t(a3),d1
	move.l	(adr_instrset,a1,d1.w*4),a2	; a2 pointe sur l'instrument
	env_initialisation	a3,1,a2		; Initialise les enveloppes
	move.w	curnote_t(a3),d4		; Recherche le sample qui va avec la note courante
	move.b	transp_i(a2,d4.w*2),d1
	ext.w	d1
	move.w	d1,transp_t(a3)		; Transposition
	add.w	d1,d3			; Sur la note
	moveq	#0,d1
	move.b	splnum_i(a2,d4.w*2),d1
	move.w	d1,ninstr_t(a3)		; Il devient le sample courant
	move.w	([adr_samples,a1,d1.w*4],vol_s),volsam_t(a3)	; Recopie le volume du sample
	move.w	([adr_samples,a1,d1.w*4],autobal_s),d4
	bmi.s	.pas_autb
	move.w	d4,curbal_t(a3)		; Recopie la balance du sample
.pas_autb:	sub.w	#24,d3

	IfNe	CHECK
	bpl.s	.check1ok
	moveq	#24,d3
.check1ok:	cmp.w	#127,d3
	ble.s	.check2ok
	moveq	#127,d3
.check2ok:
	EndC

	lsl.w	#3,d3
	add.w	norm_f_t(a3),d3
	add.w	d3,d3
	move.w	(a5,d3.w),pernote_t(a3)	; Sinon c'est une note normale
	move.w	(a5,d3.w),per2sl_t(a3)

gtkpl_fin_tone_p:
	moveq	#0,d3		; d3 position dans le sample (au d‚but)
	move.w	d2,d4
	and.w	#$F000,d4		; d4 num‚ro de l'effet 1 chiffre
	cmp.w	#$9000,d4		; On doit jouer … partir d'un certain point ?
	bne.s	.ofsplfin
	move.w	d2,d3		; Sample Offset
	sub.w	#$9000,d3
	lsl.l	#8,d3
.ofsplfin:
	move.l	d3,pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
	move.w	ninstr_t(a3),d1
	move.l	(adr_samples,a1,d1.w*4),a4
	move.l	a4,adrsam_t(a3)	; Recopie l'adresse du sample
	add.l	#data_s,adrsam_t(a3)
	move.l	(adr_repbuf,a1,d1.w*4),rbuffer_t(a3)	; l'adresse du buffer de r‚p‚tition,
	move.w	nbits_s(a4),d3	; Nombre de bits
	lsr.w	#3,d3
	move.w	d3,nbits_t(a3)
	move.w	fech_s(a4),fech_t(a3)	; Fr‚quence d'‚chantillonnage
	lea	repeat_s(a4),a4
	move.l	(a4)+,d3		; le point de r‚p‚tition,
	move.l	(a4),d4		; et la taille de la boucle
	move.l	d4,d5
	add.l	d3,d5
	cmp.l	#2,d5
	bgt.s	.finsi
	move.l	-replen_s+length_s(a4),d3	; Si pas de bouclage
	moveq	#2,d4
	subq.l	#2,d3
	tst.l	d3
	bpl.s	.finsi
	moveq	#0,d3
.finsi:
	move.l	d3,reppos_t(a3)
	move.l	d4,replen_t(a3)

;ððð L… on gŠre les effets qui n'agissent qu'en d‚but de note ðððððððððððððððð

gtkpl_effets1:
	move.w	c_v_t(a3),d3	; Commande de volume ?
	beq.s	gtkpl_effets1_no_vol
	lea	gtkpl_vlin_2_exp,a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant ajust‚
gtkpl_effets1_no_vol:
	move.w	d2,d3
	lsr.w	#8,d3		; d3 = num‚ro d'effet
	move.w	d2,d4
	cmp.w	#$20,d3		; section 00xx - 1fxx
	blt.s	.saute
	cmp.w	#$a0,d3
	blt.s	.ef1ch
	cmp.w	#$bf,d3		; section a0xx - bfxx
	bgt.s	.ef1ch
	sub.w	#$80,d3		; transforme en 20xx - 3fxx
.saute:	and.w	#$FF,d4		; d4 = paramŠtre 8 bits
	jmp	([fx_table_de_sauts1,d3.w*4])	; On saute dans la bonne routine

.ef1ch:	lsr.b	#4,d3		; Pour les effets … 1 chiffre
	and.w	#$FFF,d4		; d4 = paramŠtre 12 bits
	jmp	([fx_table_de_sauts1b,d3.w*4])	; Hop on y va!

fx_fin1:
	dbra	d7,gtkpl_premvbl_loop
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie

;ððð Ici on ex‚cute les effets qui agissent pendant toute la dur‚e de la note ððð

gtkpl_pas_seulement_1ere_vbl:
	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	sub.w	d7,d0
	lea	gtkpl_num_track,a3
	move.w	(a3,d0.w*2),d0
	mulu.w	#next_t,d0
	lea	([gtkpl_adr_info_track],d0.l),a3	; a3 pointe sur les informations de la voie

	move.w	c_n_t(a3),d0
	move.w	c_i_t(a3),d1
	move.w	c_e_t(a3),d2
	beq	fx_fin_normale	; Si pas d'effet
	move.w	d2,d3
	lsr.w	#8,d3
	move.w	d2,d4		; d4 paramŠtre de l'effet
	cmp.w	#$20,d3		; section 00xx - 1fxx
	blt.s	.saute
	cmp.w	#$a0,d3
	blt.s	.ef1ch2
	cmp.w	#$bf,d3		; section a0xx - bfxx
	bgt.s	.ef1ch2
	sub.w	#$80,d3		; transforme en 20xx - 3fxx
.saute	and.w	#$FF,d4
	jmp	([fx_table_de_sauts2,d3.w*4])	; On saute dans la bonne routine

.ef1ch2:	lsr.b	#4,d3		; Encore une fois, les effets … 1 chiffre
	and.w	#$FFF,d4

	cmp.b	#7,d3
	beq	fx_roll_7		; Roll (simple)
	cmp.b	#8,d3
	beq	fx_roll_and_vsl	; Roll + vol slide + set bal

fx_fin_normale:			; C'est l'adresse normale de retour.
	move.w	vollnot_t(a3),vol_t(a3)	; Les routines qui modifient normalement
	move.w	pernote_t(a3),per_t(a3)	; les paramŠtres passent par l….
	move.w	curbal_t(a3),bal_t(a3)
fx_fin_speciale:
	move.w	vol_t(a3),d5	; Tout … la fin, il faut aussi
	mulu.w	volsam_t(a3),d5	; tenir compte du volume propre
	lsr.l	#8,d5		; du sample.
	move.w	d5,vol_t(a3)

;ððð Gestion des enveloppes ðððððððððððððððððððððððððððððððððððððððððððððððððð

	IfNe	HANDLE_ENVELOPES

;--- Gestion de l'enveloppe de volume ----------------------------------------
gtkpl_gestion_env_volume:
	move.w	nevol_t(a3),d0	; d0 = Num‚ro d'enveloppe
	beq	gtkpl_gestion_env_tone	; Pas d'enveloppe de volume
	tst.w	ev_waitcpt_t(a3)	; On est sur un Wait ?
	bgt	.enveloppe_wait	; Oui, alors on le continue
	move.w	ev_volume_t(a3),d1
	tst.w	pevol_t(a3)	; Position n‚gative ?
	bmi	.env_set_volume	; Oui, l'enveloppe est finie
	lea	([gtkpl_module_inf1+adr_evol,d0.w*4]),a4
	add.w	devol_t(a3),a4	; a4 pointe sur la section courante
	moveq	#0,d6		; d6 = Nombre de commandes ex‚cut‚es … la file.
				; Limite car si l'utilisateur oublie les Waits
				; on peut avoir des problŠmes de boucles infinies
	move.w	pevol_t(a3),d0	; d0 = position dans la section courante

.comloop:	move.b	(a4,d0.w),d2	; d2 = num‚ro de commande
	beq	.c_end
	addq.w	#1,d0		; Pointe maintenant sur le paramŠtre
	cmp.b	#ENV_COM_JUMP,d2
	beq	.c_jump
	cmp.b	#ENV_COM_WAIT,d2
	beq	.c_wait
	cmp.b	#ENV_COM_SET_COUNTER,d2
	beq	.c_set_counter
	cmp.b	#ENV_COM_LOOP,d2
	beq	.c_loop
	cmp.b	#ENV_COM_KEY_OFF,d2
	beq	.c_key_off
	cmp.b	#ENV_COM_SET_VOLUME,d2
	beq	.c_volume
	cmp.b	#ENV_COM_SET_VOL_STEP,d2
	beq	.c_vol_step
	cmp.b	#ENV_COM_SET_VOL_SPD,d2
	beq	.c_vol_speed
	cmp.b	#ENV_COM_TREMOLO_ON,d2
	beq	.c_tremolo_on
	cmp.b	#ENV_COM_TREMOLO_OFF,d2
	beq	.c_tremolo_off
	cmp.b	#ENV_COM_SET_TRM_WID,d2
	beq	.c_tremolo_width
	cmp.b	#ENV_COM_SET_TRM_SPD,d2
	beq	.c_tremolo_speed
	cmp.b	#ENV_COM_TREMOR_ON,d2
	beq	.c_tremor_on
	cmp.b	#ENV_COM_TREMOR_OFF,d2
	beq	.c_tremor_off
	cmp.b	#ENV_COM_SET_TREMOR_1,d2
	beq	.c_tremor_time1
	cmp.b	#ENV_COM_SET_TREMOR_2,d2
	beq	.c_tremor_time2
				; ??? Commande inconnue, on passe … la suite
.comsuite:
	IfNe	CHECK>1

	addq.w	#1,d6		; Une commande de plus
	cmp.w	#ENV_COMMANDMAX,d6
	ble	.comloop		; Tout baigne, prochaine commande
	move.w	ev_volume_t(a3),d1	; Sinon on arrˆte pour ce tick
	move.w	d0,pevol_t(a3)
	bra	.env_set_volume

	Else

	bra	.comloop

	EndC

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_end:
	move.w	#-1,pevol_t(a3)	; Signale qu'on s'arrˆte
	move.w	ev_volume_t(a3),d1
	bra	.env_set_volume
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_wait:
	move.w	(a4,d0.w),ev_waitcpt_t(a3)
	addq.w	#2,d0
	move.w	d0,pevol_t(a3)
	bra	.enveloppe_wait
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_jump:
	move.w	(a4,d0.w),d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_set_counter:
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.w	d2,ev_loopcpt_t(a3)
	addq.w	#1,d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_loop:
	addq.w	#2,d0
	subq.w	#1,ev_loopcpt_t(a3)
	ble.s	.comsuite
	move.w	-2(a4,d0.w),d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_key_off:
	move.w	neton_t(a3),d0
	lea	([gtkpl_module_inf1+adr_eton,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,deton_t(a3)
	clr.w	peton_t(a3)
	clr.w	et_waitcpt_t(a3)
	move.w	nepan_t(a3),d0
	lea	([gtkpl_module_inf1+adr_epan,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,depan_t(a3)
	clr.w	pepan_t(a3)
	clr.w	ep_waitcpt_t(a3)
	move.w	nevol_t(a3),d0
	lea	([gtkpl_module_inf1+adr_evol,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,devol_t(a3)
	add.w	d2,a4
	moveq	#0,d0
	moveq	#0,d6
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_volume:
	move.w	(a4,d0.w),ev_volume_t(a3)
	addq.w	#2,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_vol_step:
	move.w	(a4,d0.w),ev_volstep_t(a3)
	addq.w	#2,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_vol_speed:
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.w	d2,ev_volspeed_t(a3)
	clr.w	ev_volcpt_t(a3)
	addq.w	#1,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremolo_on:
	move.b	#1,ev_tremoloflag_t(a3)
	clr.b	ev_tremolocpt_t(a3)
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremolo_off:
	clr.b	ev_tremoloflag_t(a3)
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremolo_width:
	move.b	(a4,d0.w),ev_tremolowidth_t(a3)
	addq.w	#1,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremolo_speed:
	move.b	(a4,d0.w),ev_tremolospeed_t(a3)
	addq.w	#1,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremor_on:
	move.b	#1,ev_tremorflag_t(a3)
	clr.b	ev_tremorcpt_t(a3)
	clr.b	ev_tremorsection_t(a3)
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremor_off:
	clr.b	ev_tremorflag_t(a3)
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremor_time1:
	move.b	(a4,d0.w),ev_tremortime1_t(a3)
	addq.w	#1,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tremor_time2:
	move.b	(a4,d0.w),ev_tremortime2_t(a3)
	addq.w	#1,d0
	bra	.comsuite

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.enveloppe_wait:
	subq.w	#1,ev_waitcpt_t(a3)	; On d‚cr‚mente le Wait
	move.w	ev_volcpt_t(a3),d0	; Mont‚e de volume ?
	bne.s	.noincvol

	IfNe	CHECK

	moveq	#0,d1
	move.w	ev_volume_t(a3),d1
	move.w	ev_volstep_t(a3),d2
	ext.l	d2
	add.l	d2,d1
	bpl.s	.incvols1
	moveq	#0,d1
.incvols1:	cmp.l	#32767,d1
	ble.s	.incvols2
	move.w	#32767,d1
.incvols2:	move.w	d1,ev_volume_t(a3)

	Else

	move.w	ev_volstep_t(a3),d1
	add.w	d1,ev_volume_t(a3)

	EndC

.noincvol:	addq.w	#1,d0		; On incr‚mente le compteur de volume
	cmp.w	ev_volspeed_t(a3),d0
	blt.s	.volcptok
	moveq	#0,d0
.volcptok:	move.w	d0,ev_volcpt_t(a3)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	moveq	#0,d1
	move.w	ev_volume_t(a3),d1
	tst.b	ev_tremoloflag_t(a3)
	beq.s	.tremor
	moveq	#0,d3
	move.b	ev_tremolocpt_t(a3),d3
	lea	gtkpl_sin_table,a4
	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	ev_tremolowidth_t(a3),d4
	and.w	#$ff,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#2,d3
	add.l	d3,d1		; Additionne au volume

	IfNe	CHECK
	bpl.s	.tremolo1
	moveq	#0,d1
.tremolo1:	cmp.l	#32767,d1
	ble.s	.tremolo2
	move.w	#32767,d1
.tremolo2:
	EndC

	move.b	ev_tremolospeed_t(a3),d2
	add.b	d2,ev_tremolocpt_t(a3)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.tremor:	tst.b	ev_tremorflag_t(a3)
	beq.s	.env_set_volume
	move.b	ev_tremorcpt_t(a3),d2
	addq.b	#1,d2
	tst.b	ev_tremorsection_t(a3)	; Volume On ou Off ?
	beq.s	.tremors1
	moveq	#0,d1			; Volume … 0
	cmp.b	ev_tremortime2_t(a3),d2
	blt.s	.tremors2
	moveq	#0,d2
	clr.b	ev_tremorsection_t(a3)
	bra.s	.tremors2
.tremors1:	cmp.b	ev_tremortime1_t(a3),d2	; Plein volume
	blt.s	.tremors2
	moveq	#0,d2
	move.b	#1,ev_tremorsection_t(a3)
.tremors2:	move.b	d2,ev_tremorcpt_t(a3)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.env_set_volume:
	mulu.w	vol_t(a3),d1
	add.l	d1,d1
	add.l	d1,d1
	swap	d1
	move.w	d1,vol_t(a3)

;--- Gestion de l'enveloppe de tonalit‚ --------------------------------------
gtkpl_gestion_env_tone:
	move.w	neton_t(a3),d0	; d0 = Num‚ro d'enveloppe
	beq	gtkpl_gestion_env_panning
	tst.w	et_waitcpt_t(a3)	; On est sur un Wait ?
	bgt	.enveloppe_wait	; Oui, alors on le continue
	move.w	et_tone_t(a3),d1
	tst.w	peton_t(a3)	; Position n‚gative ?
	bmi	.env_set_tone	; Oui, l'enveloppe est finie
	lea	([gtkpl_module_inf1+adr_eton,d0.w*4]),a4
	add.w	deton_t(a3),a4	; a4 pointe sur la section courante
	moveq	#0,d6		; d6 = Nombre de commandes ex‚cut‚es … la file.
				; Limite car si l'utilisateur oublie les Waits
				; on peut avoir des problŠmes de boucles infinies
	move.w	peton_t(a3),d0	; d0 = position dans la section courante

.comloop:	move.b	(a4,d0.w),d2	; d2 = num‚ro de commande
	beq.s	.c_end
	addq.w	#1,d0		; Pointe maintenant sur le paramŠtre
	cmp.b	#ENV_COM_JUMP,d2
	beq	.c_jump
	cmp.b	#ENV_COM_WAIT,d2
	beq.s	.c_wait
	cmp.b	#ENV_COM_SET_COUNTER,d2
	beq	.c_set_counter
	cmp.b	#ENV_COM_LOOP,d2
	beq	.c_loop
	cmp.b	#ENV_COM_KEY_OFF,d2
	beq	.c_key_off
	cmp.b	#ENV_COM_SET_TONE,d2
	beq	.c_tone
	cmp.b	#ENV_COM_SET_TON_STEP,d2
	beq	.c_tone_step
	cmp.b	#ENV_COM_SET_TON_SPD,d2
	beq	.c_tone_speed
	cmp.b	#ENV_COM_VIBRATO_ON,d2
	beq	.c_vibrato_on
	cmp.b	#ENV_COM_VIBRATO_OFF,d2
	beq	.c_vibrato_off
	cmp.b	#ENV_COM_SET_VIB_WID,d2
	beq	.c_vibrato_width
	cmp.b	#ENV_COM_SET_VIB_SPD,d2
	beq	.c_vibrato_speed
				; ??? Commande inconnue, on passe … la suite
.comsuite:

	IfNe	CHECK>1

	addq.w	#1,d6		; Une commande de plus
	cmp.w	#ENV_COMMANDMAX,d6
	ble.s	.comloop		; Tout baigne, prochaine commande
	move.w	et_tone_t(a3),d1	; Sinon on arrˆte pour ce tick
	move.w	d0,peton_t(a3)
	bra	.env_set_tone

	Else

	bra	.comloop

	EndC

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_end:
	move.w	#-1,peton_t(a3)	; Signale qu'on s'arrˆte
	move.w	et_tone_t(a3),d1
	bra	.env_set_tone
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_wait:
	move.w	(a4,d0.w),et_waitcpt_t(a3)
	addq.w	#2,d0
	move.w	d0,peton_t(a3)
	bra	.enveloppe_wait
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_jump:
	move.w	(a4,d0.w),d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_set_counter:
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.w	d2,et_loopcpt_t(a3)
	addq.w	#1,d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_loop:
	addq.w	#2,d0
	subq.w	#1,et_loopcpt_t(a3)
	ble.s	.comsuite
	move.w	-2(a4,d0.w),d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_key_off:
	move.w	nevol_t(a3),d0
	lea	([gtkpl_module_inf1+adr_evol,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,devol_t(a3)
	clr.w	pevol_t(a3)
	clr.w	ev_waitcpt_t(a3)
	move.w	nepan_t(a3),d0
	lea	([gtkpl_module_inf1+adr_epan,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,depan_t(a3)
	clr.w	pepan_t(a3)
	clr.w	ep_waitcpt_t(a3)
	move.w	neton_t(a3),d0
	lea	([gtkpl_module_inf1+adr_eton,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,deton_t(a3)
	add.w	d2,a4
	moveq	#0,d0
	moveq	#0,d6
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tone:
	move.w	(a4,d0.w),et_tone_t(a3)
	addq.w	#2,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tone_step:
	move.w	(a4,d0.w),et_tonestep_t(a3)
	addq.w	#2,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_tone_speed:
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.w	d2,et_tonespeed_t(a3)
	clr.w	et_tonecpt_t(a3)
	addq.w	#1,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_vibrato_on:
	move.b	#1,et_vibratoflag_t(a3)
	clr.b	et_vibratocpt_t(a3)
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_vibrato_off:
	clr.b	et_vibratoflag_t(a3)
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_vibrato_width:
	move.b	(a4,d0.w),et_vibratowidth_t(a3)
	addq.w	#1,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_vibrato_speed:
	move.b	(a4,d0.w),et_vibratospeed_t(a3)
	addq.w	#1,d0
	bra	.comsuite

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.enveloppe_wait:
	subq.w	#1,et_waitcpt_t(a3)	; On d‚cr‚mente le Wait
	move.w	et_tonecpt_t(a3),d0	; Mont‚e de p‚riode ?
	bne.s	.noincton

	IfNe	CHECK

	moveq	#0,d1
	move.w	et_tone_t(a3),d1
	move.w	et_tonestep_t(a3),d2
	ext.l	d2
	add.l	d2,d1
	bpl.s	.inctons1
	moveq	#0,d1
.inctons1:	cmp.l	#32767,d1
	ble.s	.inctons2
	move.w	#32767,d1
.inctons2:	move.w	d1,et_tone_t(a3)

	Else

	move.w	et_tonestep_t(a3),d1
	add.w	d1,et_tone_t(a3)

	EndC

.noincton:	addq.w	#1,d0		; On incr‚mente le compteur de tonalit‚
	cmp.w	et_tonespeed_t(a3),d0
	blt.s	.toncptok
	moveq	#0,d0
.toncptok:	move.w	d0,et_tonecpt_t(a3)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	moveq	#0,d1
	move.w	et_tone_t(a3),d1
	tst.b	et_vibratoflag_t(a3)
	beq.s	.env_set_tone
	moveq	#0,d3
	move.b	et_vibratocpt_t(a3),d3
	lea	gtkpl_sin_table,a4
	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	et_vibratowidth_t(a3),d4
	and.w	#$ff,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#5,d3
	add.l	d3,d1		; Additionne … la p‚riode

	IfNe	CHECK
	bpl.s	.vibrato1
	moveq	#0,d1
.vibrato1:	cmp.l	#32767,d1
	ble.s	.vibrato2
	move.w	#32767,d1
.vibrato2:
	EndC

	move.b	et_vibratospeed_t(a3),d2
	add.b	d2,et_vibratocpt_t(a3)

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.env_set_tone:
	mulu.w	per_t(a3),d1
	lsl.l	#4,d1

	IfNe	CHECK

	clr.w	d1
	swap	d1
	cmp.l	#PERIOD_MINI,d1
	bge.s	.setton1
	move.w	#PERIOD_MINI,d1
.setton1:	cmp.l	#PERIOD_MAXI,d1
	ble.s	.setton2
	move.w	#PERIOD_MAXI,d1

	Else

	swap	d1

	EndC

.setton2:	move.w	d1,per_t(a3)

;--- Gestion de l'enveloppe de panning ---------------------------------------
gtkpl_gestion_env_panning:
	move.w	nepan_t(a3),d0	; d0 = Num‚ro d'enveloppe
	beq	gtkpl_fin_gestion_enveloppes
	tst.w	ep_waitcpt_t(a3)	; On est sur un Wait ?
	bgt	.enveloppe_wait	; Oui, alors on le continue
	move.w	ep_pan_t(a3),d1
	tst.w	pepan_t(a3)	; Position n‚gative ?
	bmi	.env_set_pan	; Oui, l'enveloppe est finie
	lea	([gtkpl_module_inf1+adr_epan,d0.w*4]),a4
	add.w	depan_t(a3),a4	; a4 pointe sur la section courante
	moveq	#0,d6		; d6 = Nombre de commandes ex‚cut‚es … la file.
				; Limite car si l'utilisateur oublie les Waits
				; on peut avoir des problŠmes de boucles infinies
	move.w	pepan_t(a3),d0	; d0 = position dans la section courante

.comloop:	move.b	(a4,d0.w),d2	; d2 = num‚ro de commande
	beq.s	.c_end
	addq.w	#1,d0		; Pointe maintenant sur le paramŠtre
	cmp.b	#ENV_COM_JUMP,d2
	beq.s	.c_jump
	cmp.b	#ENV_COM_WAIT,d2
	beq.s	.c_wait
	cmp.b	#ENV_COM_SET_COUNTER,d2
	beq.s	.c_set_counter
	cmp.b	#ENV_COM_LOOP,d2
	beq.s	.c_loop
	cmp.b	#ENV_COM_KEY_OFF,d2
	beq.s	.c_key_off
	cmp.b	#ENV_COM_SET_PANNING,d2
	beq	.c_pan
	cmp.b	#ENV_COM_SET_PAN_STEP,d2
	beq	.c_pan_step
	cmp.b	#ENV_COM_SET_PAN_SPD,d2
	beq	.c_pan_speed
				; ??? Commande inconnue, on passe … la suite
.comsuite:
	IfNe	CHECK>1

	addq.w	#1,d6		; Une commande de plus
	cmp.w	#ENV_COMMANDMAX,d6
	ble.s	.comloop		; Tout baigne, prochaine commande
	move.w	ep_pan_t(a3),d1	; Sinon on arrˆte pour ce tick
	move.w	d0,pepan_t(a3)
	bra	.env_set_pan

	Else

	bra	.comloop

	EndC


; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_end:
	move.w	#-1,pepan_t(a3)	; Signale qu'on s'arrˆte
	move.w	ep_pan_t(a3),d1
	bra	.env_set_pan
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_wait:
	move.w	(a4,d0.w),ep_waitcpt_t(a3)
	addq.w	#2,d0
	move.w	d0,pepan_t(a3)
	bra	.enveloppe_wait
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_jump:
	move.w	(a4,d0.w),d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_set_counter:
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.w	d2,ep_loopcpt_t(a3)
	addq.w	#1,d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_loop:
	addq.w	#2,d0
	subq.w	#1,ep_loopcpt_t(a3)
	ble.s	.comsuite
	move.w	-2(a4,d0.w),d0
	bra.s	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_key_off:
	move.w	nevol_t(a3),d0
	lea	([gtkpl_module_inf1+adr_evol,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,devol_t(a3)
	clr.w	pevol_t(a3)
	clr.w	ev_waitcpt_t(a3)
	move.w	neton_t(a3),d0
	lea	([gtkpl_module_inf1+adr_eton,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,deton_t(a3)
	clr.w	peton_t(a3)
	clr.w	et_waitcpt_t(a3)
	move.w	nepan_t(a3),d0
	lea	([gtkpl_module_inf1+adr_epan,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,depan_t(a3)
	add.w	d2,a4
	moveq	#0,d0
	moveq	#0,d6
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_pan:
	move.w	(a4,d0.w),ep_pan_t(a3)
	addq.w	#2,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_pan_step:
	move.w	(a4,d0.w),ep_panstep_t(a3)
	addq.w	#2,d0
	bra	.comsuite
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.c_pan_speed:
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.w	d2,ep_panspeed_t(a3)
	clr.w	ep_pancpt_t(a3)
	addq.w	#1,d0
	bra	.comsuite

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.enveloppe_wait:
	subq.w	#1,ep_waitcpt_t(a3)	; On d‚cr‚mente le Wait
	move.w	ep_pancpt_t(a3),d0	; Mont‚e de p‚riode ?
	bne.s	.noincpan

	IfNe	CHECK

	moveq	#0,d1
	move.w	ep_pan_t(a3),d1
	move.w	ep_panstep_t(a3),d2
	ext.l	d2
	add.l	d2,d1
	bpl.s	.incpans1
	moveq	#0,d1
.incpans1:	cmp.l	#$FFF,d1
	ble.s	.incpans2
	move.w	#$FFF,d1
.incpans2:	move.w	d1,ep_pan_t(a3)

	Else

	move.w	ep_panstep_t(a3),d1
	add.w	d1,ep_pan_t(a3)

	EndC

.noincpan:	addq.w	#1,d0		; On incr‚mente le compteur de tonalit‚
	cmp.w	ep_panspeed_t(a3),d0
	blt.s	.pancptok
	moveq	#0,d0
.pancptok:	move.w	d0,ep_pancpt_t(a3)
	move.w	ep_pan_t(a3),d1

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.env_set_pan:
	move.w	bal_t(a3),d2
	sub.w	#$800,d2
	bmi.s	.envsetp1
	neg.w	d2		; d2 = -abs(PanPos-2048)
.envsetp1:	add.w	#$800,d2
	sub.w	#$800,d1		; d1 = PanEnv-2048
	muls.w	d2,d1		; Multiplication sign‚e
	asl.l	#5,d1		; Divise par 2048 (*32/65536)
	swap	d1
	add.w	d1,bal_t(a3)	; PanPos + (PanEnv-2048)*(2048-abs(PanPos-2048))/2048

gtkpl_fin_gestion_enveloppes:
	EndC

;--- Voie suivante... --------------------------------------------------------
	dbra	d7,gtkpl_pas_seulement_1ere_vbl

gtkpl_fin_gestion_partition:

;--- Mise … jour du nombre de spl par vbl ------------------------------------
	moveq	#0,d2
	move.w	gtkpl_vblsize_int,d0
	move.w	gtkpl_vblsize_frac,d1
	add.w	gtkpl_vblsize_count,d1
	addx.w	d2,d0
	move.w	d1,gtkpl_vblsize_count
	move.w	d0,-(sp)
	sndkernel	set_vblsize	; *** d0 n'est pas sauv‚
	addq.l	#2,sp

	movem.l	(sp)+,d0-a6
	rts



;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð
;	Effets agissant seulement au d‚but d'une note
;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð

;-----------------------------------------------------------------------------
;	Set Linear Volume
;-----------------------------------------------------------------------------
fx_set_lin_volume:
	IfNe	CHECK=2
	cmp.w	#$100,d4
	ble.s	.ok2
	move.w	#$100,d4
	EndC

.ok2:	lea	gtkpl_vlin_2_exp,a4
	move	(a4,d4.w*2),volenot_t(a3)
	lsl.w	#3,d4
	move.w	d4,vollnot_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set Exponential Volume
;-----------------------------------------------------------------------------
fx_set_exp_volume:
	IfNe	CHECK=2
	cmp.w	#$800,d4
	ble.s	.ok3
	move.w	#$800,d4
	EndC

.ok3:	move.w	d4,volenot_t(a3)
	lea	gtkpl_vexp_2_lin,a4
	move.w	(a4,d4.w*2),vollnot_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set Balance
;-----------------------------------------------------------------------------
fx_set_balance:
	move.w	d4,curbal_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set Linear Master Volume
;-----------------------------------------------------------------------------
fx_set_lin_master_vol:
	IfNe	CHECK=2
	cmp.w	#$FFF,d4
	ble.s	.ok5
	move.w	#$FFF,d4
	EndC

.ok5:	move.w	d4,-(sp)
	sndkernel	set_master_vol	; *** d0 n'est pas sauv‚
	addq.l	#2,sp
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set Exponential Master Volume
;-----------------------------------------------------------------------------
fx_set_exp_master_vol:
	lea	gtkpl_vexp_2_lin_mst,a4
	move.w	(a4,d4.w*2),-(sp)
	sndkernel	set_master_vol	; *** d0 n'est pas sauv‚
	addq.l	#2,sp
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Roll (initialisation)
;-----------------------------------------------------------------------------
fx_roll_7_init:
	move.w	d4,d5
	and.w	#$FF,d5		; d5 = nbr de coups maxi
	bne.s	.pl7
	moveq	#-1,d5		; Si d5 = 0, r‚p‚titions infinies
.pl7:	move.w	d5,rollnbr_t(a3)
	lsr.w	#8,d4		; d4 = vitesse
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Arpeggio (initialisation)
;-----------------------------------------------------------------------------
fx_arpeggio_init:
	clr.w	arpegcpt_t(a3)	; Compteur … 0
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Detune
;-----------------------------------------------------------------------------
fx_set_ftune:
	move.w	d4,d5
	and.w	#$F,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	move.w	d5,norm_f_t(a3)	; nouveau finetune
	tst.w	d0
	beq	fx_fin1		; On s'en va si il n'y a pas de note … c“t‚
	move.w	d0,d3
	add.w	transp_t(a3),d3
	sub.w	#24,d3
	lsl.w	#3,d3
	add.w	d5,d3
	move.w	(a5,d3.w*2),pernote_t(a3)	; Sinon on corrige la note
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Note cut, initialisation
;-----------------------------------------------------------------------------
fx_note_precut:
	move.w	d4,cut_del_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Position Jump
;-----------------------------------------------------------------------------
fx_pos_jump:
	IfNe	CHECK
	cmp.w	mod_songlen(a0),d4
	bge	fx_fin1
	EndC

	move.w	d4,mod_songpos(a0)	; Nouvelle position
	move.w	([adr_song,a1],d4.w*2),mod_numpat(a0)	; Trouve le nouveau pattern
	move.w	#-1,mod_flagnewpos(a0)	; On signale que la position a ‚t‚ modifi‚e
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set vibrato wave
;-----------------------------------------------------------------------------
fx_set_vib_wave:
	IfNe	CHECK=2
	and.b	#3,d4
	EndC

	move.b	d4,vibwav_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set tremolo wave
;-----------------------------------------------------------------------------
fx_set_trem_wave:
	IfNe	CHECK=2
	and.b	#3,d4
	EndC

	move.b	d4,tremwav_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Break pattern & jump to line
;-----------------------------------------------------------------------------
fx_break_pat:
	tst.w	mod_flagnewpos(a0)	; La position a d‚j… ‚t‚ chang‚e ?
	bne.s	.np_end		; Oui, on ne le refait pas.
	move.w	mod_cursongpos(a0),d3
	addq.w	#1,d3		; Nouvelle position
	cmp.w	mod_songlen(a0),d3	; Fin de la song ?
	blt.s	.s_song
	move.w	mod_songrep(a0),d3	; Oui, bouclage
.s_song:	move.w	d3,mod_songpos(a0)
	move.w	([adr_song,a1],d3.w*2),mod_numpat(a0)	; Trouve le nouveau pattern
.np_end:
	IfNe	CHECK=2
	move.w	mod_numpat(a0),d5
	move.l	(adr_pattern,a1,d5.w*4),a4
	cmp.w	nlines_p(a4),d4
	blt.s	.ok
	moveq	#0,d4		; Si la nouvelle ligne est en dehors du pattern
	EndC

.ok:	move.w	d4,mod_linepos(a0)	; Pointe sur la nouvelle ligne du pattern
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Pattern loop
;-----------------------------------------------------------------------------
fx_pattern_loop:
	tst.b	d4		; D‚but de boucle ?
	bne.s	.doloop		; Non, c'est la fin de la boucle alors
	tst.w	ploopn_t(a3)
	bne	fx_fin1		; C'est pas la 1Šre fois, on fait rien
	move.w	mod_curlinepos(a0),ploopp_t(a3)	; Sinon, on m‚morise la position de bouclage
	move.w	mod_cursongpos(a0),ploops_t(a3)
	bra	fx_fin1
.doloop:	tst.w	ploopn_t(a3)	; D‚j… dans une boucle ?
	beq.s	.suite		; Non, nouveau compteur
	move.w	ploopn_t(a3),d4	; d4 = nbr de r‚p‚tition … faire
	subq.w	#1,d4		; Boucle -1
.suite:	move.w	d4,ploopn_t(a3)
	beq	fx_fin1		; Si on en est … 0, fin de la boucle
	move.w	ploopp_t(a3),mod_linepos(a0)	; Point de bouclage
	move.w	ploops_t(a3),mod_songpos(a0)	; On se remet sur la bonne position
	move.w	mod_songpos(a0),d3		; Pattern correspondant
	move.w	([adr_song,a1],d3.w*2),mod_numpat(a0)
	bra	fx_fin1		; si par hasard on ‚tait all‚ ailleurs.

;-----------------------------------------------------------------------------
;	Set global speed
;-----------------------------------------------------------------------------
fx_set_global_speed:
	tst.w	d4
	beq	fx_fin1
	cmp.w	#31,d4
	bgt.s	.tempo
	move.w	d4,mod_speed(a0)
	moveq	#125,d4		; Tempo 125
.tempo:
	move.w	d4,-(sp)
	bsr	gtkpl_set_tempo	; *** d0 n'est pas sauv‚
	addq.l	#2,sp
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set number of frames
;-----------------------------------------------------------------------------
fx_set_nbr_of_frames:
	IfNe	CHECK=2
	tst.w	d4
	beq	fx_fin1
	EndC

	move.w	d4,mod_speed(a0)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set fine speed
;-----------------------------------------------------------------------------
fx_set_fine_speed:
	add.w	d4,d4

	IfNe	CHECK=2
	beq	fx_fin1
	EndC

	moveq	#0,d5
	sndkernel	set_replay_freq	; *** d0 n'est pas sauv‚
	divu.w	#125*4*6/60,d0
	sub.w	#256,d0
	add.w	d0,d4
	move.w	d4,-(sp)		; La valeur de mod_tempo n'est pas chang‚e!
	sndkernel	set_vblsize	; *** d0 n'est pas sauv‚
	addq.l	#2,sp
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine portamento up
;-----------------------------------------------------------------------------
fx_fine_porta_up:
	move.w	pernote_t(a3),d5
	lsl.w	#4,d4
	bne.s	.ok2
	move.w	fportspd_t(a3),d4
.ok2:	move.w	d4,fportspd_t(a3)
	sub.w	d4,d5

	IfNe	CHECK
	cmp.w	#PERIOD_MINI,d5
	bge.s	.ok
	move.w	#PERIOD_MINI,d5
	EndC

.ok:	move.w	d5,pernote_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine portamento down
;-----------------------------------------------------------------------------
fx_fine_porta_down:
	IfNe	CHECK
	ext.l	d4
	EndC

	lsl.w	#4,d4
	bne.s	.ok2
	move.w	fportspd_t(a3),d4
.ok2:	move.w	d4,fportspd_t(a3)
	add.w	pernote_t(a3),d4

	IfNe	CHECK
	cmp.l	#PERIOD_MAXI,d4
	ble.s	.ok
	move.w	#PERIOD_MAXI,d4
	EndC

.ok:	move.w	d4,pernote_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Note delay - initialisation
;-----------------------------------------------------------------------------
fx_predelay:
	move.w	d4,delay_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine volume slide
;-----------------------------------------------------------------------------
fx_fine_v_sldown_l:
	neg.w	d4
fx_fine_v_slup_l:
	tst.w	d4
	bne.s	.ok
	move.w	fvolslspd_t(a3),d4
.ok:	move.w	d4,fvolslspd_t(a3)
	bsr	fx_do_v_slide_l
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine exponential volume slide
;-----------------------------------------------------------------------------
; *** Ces 2 effets sont inutilis‚s pour l'instant
;fx_fine_v_sldown_e:			; Fine volume slide down (exp) \
;	neg.w	d4		;                               > *** Ne pas s‚parer
;fx_fine_v_slup_e:			; Fine volume slide up (exp)   /
;	bsr	fx_do_v_slide_e
;	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine master volume slide
;-----------------------------------------------------------------------------
fx_fine_mv_sldown_l:			; Fine master volume slide up (lin)   \
	neg.w	d4		;                                      > *** Ne pas s‚parer
fx_fine_mv_slup_l:			; Fine master volume slide down (lin) /
	bsr	fx_do_mv_slide_l
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Pattern delay
;-----------------------------------------------------------------------------
fx_pattern_delay:
	move.w	d4,mod_patrep(a0)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Roll + volume slide (initialisation)
;-----------------------------------------------------------------------------
fx_roll_and_vsl_init:
	and.w	#15,d4		; d4 = vitesse
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Roll + volume slide + set balance
;	(initialisation)
;-----------------------------------------------------------------------------
fx_roll_and_vsl_and_sbl_init:
	move.w	d4,d5
	and.w	#$F00,d5
	move.w	d5,curbal_t(a3)	; Fixe la balance
	and.w	#15,d4		; d4 = vitesse
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Tr‚mor (initialisation)
;-----------------------------------------------------------------------------
fx_tremor_init:
	tst.b	d4
	beq	fx_fin1
	move.b	d4,d5
	lsr.b	#4,d5
	bne.s	.ok1
	moveq	#16,d5
.ok1:	move.b	d5,tremor1_t(a3)
	and.b	#15,d4
	bne.s	.ok2
	moveq	#16,d4
.ok2:	add.b	d5,d4
	move.b	d4,tremor2_t(a3)
	bra	fx_fin1


;-----------------------------------------------------------------------------
;	Set flags
;-----------------------------------------------------------------------------
fx_set_flags:
.bit0:
	btst	#0,d4		; Bit 0 : interpolation
	beq.s	.bit0off
	move.w	#1,interpol_t(a3)
	bra.s	.fin
.bit0off:	clr.w	interpol_t(a3)
.fin:
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set volume envelope
;-----------------------------------------------------------------------------
fx_set_vol_env:
	IfNE	CHECK=2
	cmp.w	#NBRVOLENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.w	d4,nevol_t(a3)
	beq	fx_fin1

	env_volume_init	a3
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set tone envelope
;-----------------------------------------------------------------------------
fx_set_ton_env:
	IfNE	CHECK=2
	cmp.w	#NBRTONENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.w	d4,neton_t(a3)
	beq	fx_fin1

	env_tone_init	a3
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set panning envelope
;-----------------------------------------------------------------------------
fx_set_pan_env:
	IfNE	CHECK=2
	cmp.w	#NBRPANENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.w	d4,nepan_t(a3)
	beq	fx_fin1

	env_panning_init	a3
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set volume envelope (Key Off)
;-----------------------------------------------------------------------------
fx_set_vol_env_ko:
	IfNE	CHECK=2
	cmp.w	#NBRVOLENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.w	d4,nevol_t(a3)
	beq	fx_fin1

	env_volume_init	a3
	move.w	([gtkpl_module_inf1+adr_evol,d4.w*4],keyoffoffset_e.w),d6
	add.w	d6,devol_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set tone envelope (Key Off)
;-----------------------------------------------------------------------------
fx_set_ton_env_ko:
	IfNE	CHECK=2
	cmp.w	#NBRTONENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.w	d4,neton_t(a3)
	beq	fx_fin1

	env_tone_init	a3
	move.w	([gtkpl_module_inf1+adr_eton,d4.w*4],keyoffoffset_e.w),d6
	add.w	d6,deton_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set panning envelope (Key Off)
;-----------------------------------------------------------------------------
fx_set_pan_env_ko:
	IfNE	CHECK=2
	cmp.w	#NBRPANENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.w	d4,nepan_t(a3)
	beq	fx_fin1

	env_panning_init	a3
	move.w	([gtkpl_module_inf1+adr_epan,d4.w*4],keyoffoffset_e.w),d6
	add.w	d6,depan_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine Sample Offset
;-----------------------------------------------------------------------------
fx_fine_sample_offset:
	lsl.w	#4,d4
	ext.l	d4

	IfNE	CHECK
	move.l	reppos_t(a3),d6
	add.l	replen_t(a3),d6
	cmp.l	d6,d4
	blt.s	.ok
	move.l	d6,d4
	subq.l	#1,d4
	bpl.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.l	d4,pos_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Very Fine Sample Offset
;-----------------------------------------------------------------------------
fx_very_fine_sample_offset:
	ext.l	d4

	IfNE	CHECK
	move.l	reppos_t(a3),d6
	add.l	replen_t(a3),d6
	cmp.l	d6,d4
	blt.s	.ok
	move.l	d6,d4
	subq.l	#1,d4
	bpl.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.l	d4,pos_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Increment Sample Position
;-----------------------------------------------------------------------------
fx_inc_sample_pos:
	ext.l	d4
	add.l	pos_t(a3),d4

	IfNE	CHECK

	move.l	reppos_t(a3),d6
	add.l	replen_t(a3),d6
	cmp.l	d6,d4
	blt.s	.ok

	sub.l	reppos_t(a3),d4	; Si on d‚borde de la boucle
	divul.l	replen_t(a3),d6:d4
	add.l	reppos_t(a3),d6
	move.l	d6,d4		; pos = ((pos + N - rep) MOD replen) + rep

	EndC

.ok:	move.l	d4,pos_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Decrement Sample Position
;-----------------------------------------------------------------------------
fx_dec_sample_pos:
	ext.l	d4
	sub.l	d4,pos_t(a3)

	IfNE	CHECK
	bpl	fx_fin1
	clr.l	pos_t(a3)
	EndC

	bra	fx_fin1

;-----------------------------------------------------------------------------
;	AutoTempo (initialisation)
;-----------------------------------------------------------------------------
fx_init_autotempo:
	move.w	#1,flag_autotempo_t(a3)	; On le fait en 'tous les ticks' … cause
	bra	fx_fin1			; d'une ‚ventuelle commande de vitesse

;-----------------------------------------------------------------------------
;	AutoPeriod (initialisation)
;-----------------------------------------------------------------------------
fx_init_autoperiod:
	move.w	#1,flag_autoperiod_t(a3)	; On le fait en 'tous les ticks' … cause
	bra	fx_fin1			; d'une ‚ventuelle commande de vitesse



;-----------------------------------------------------------------------------
;	Demo Synchro
;-----------------------------------------------------------------------------
fx_demo_synchro:
	move.w	d4,gtkpl_demo_synchro
	bra	fx_fin1
	


;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð
;	Effets agissant pendant la note
;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð

;-----------------------------------------------------------------------------
;	Arpeggio
;-----------------------------------------------------------------------------
fx_arpeggio:
	moveq	#0,d5
	move.w	arpegcpt_t(a3),d5
	addq.w	#1,arpegcpt_t(a3)
	divu.w	#3,d5
	swap	d5
	tst.w	d5
	beq	fx_fin_normale
	cmp.b	#1,d5
	bne.s	.suite
	lsr.b	#4,d4
.suite:	and.b	#$F,d4		; d4 = nbr de 1/2 tons … d‚caler
	beq	fx_fin_normale
	add.w	curnote_t(a3),d4
	add.w	transp_t(a3),d4
	sub.w	#24,d4
	lsl.w	#3,d4
	add.w	norm_f_t(a3),d4
	move.w	(a5,d4.w*2),d4

	IfNe	CHECK
	cmp.w	#PERIOD_MINI,d4
	bge.s	.suite2
	move.w	#PERIOD_MINI,d4
	EndC

.suite2:	move.w	d4,per_t(a3)
	move.w	vollnot_t(a3),vol_t(a3)	; On met le bon volume car on ne
	move.w	curbal_t(a3),bal_t(a3)	; repasse pas par la fin normale
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Portamento up
;-----------------------------------------------------------------------------
fx_porta_up:
	lsl.w	#4,d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	sub.w	d4,pernote_t(a3)

	IfNe	CHECK
	cmp.w	#PERIOD_MINI,pernote_t(a3)
	bge	fx_fin_normale
	move.w	#PERIOD_MINI,pernote_t(a3)
	EndC

	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Extra fine portamento up
;-----------------------------------------------------------------------------
fx_extra_fine_porta_up:
	tst.w	d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	sub.w	d4,pernote_t(a3)

	IfNe	CHECK
	cmp.w	#PERIOD_MINI,pernote_t(a3)
	bge	fx_fin_normale
	move.w	#PERIOD_MINI,pernote_t(a3)
	EndC

	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Portamento down
;-----------------------------------------------------------------------------
fx_porta_down:
	lsl.w	#4,d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	ext.l	d4
	add.w	pernote_t(a3),d4

	IfNe	CHECK
	cmp.l	#PERIOD_MAXI,d4
	ble.s	.suite
	move.w	#PERIOD_MAXI,d4
	EndC

.suite:	move.w	d4,pernote_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Extra fine portamento down
;-----------------------------------------------------------------------------
fx_extra_fine_porta_down:
	ext.l	d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	add.w	pernote_t(a3),d4

	IfNe	CHECK
	cmp.l	#PERIOD_MAXI,d4
	ble.s	.suite
	move.w	#PERIOD_MAXI,d4
	EndC

.suite:	move.w	d4,pernote_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Tone portamento
;-----------------------------------------------------------------------------
fx_tone_porta:
	bsr.s	fx_do_tone_porta
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Extra fine tone portamento
;-----------------------------------------------------------------------------
fx_extra_fine_tone_porta:
	bsr.s	fx_do_very_fine_tone_porta
	bra	fx_fin_normale

fx_do_tone_porta:			; Ex‚cute le Tone Portamento
	lsl.w	#4,d4
fx_do_very_fine_tone_porta:
	tst.w	d4
	bne.s	.suite1
	move.w	portspd_t(a3),d4
.suite1:	move.w	d4,portspd_t(a3)
	move.w	pernote_t(a3),d5	; d5 = p‚riode actuelle
	move.w	per2sl_t(a3),d6	; d6 = p‚riode … atteindre
	cmp.w	d6,d5
	beq.s	.fin2
	blt.s	.monte
	sub.w	d4,d5
	cmp.w	d6,d5
	bge.s	.fin
	move.w	d6,d5		; On a atteint la nouvelle note
	move.w	note2sl_t(a3),curnote_t(a3)
	bra.s	.fin
.monte:	add.w	d4,d5
	cmp.w	d6,d5
	ble.s	.fin
	move.w	d6,d5		; On a atteint la nouvelle note
	move.w	note2sl_t(a3),curnote_t(a3)
.fin:	move.w	d5,pernote_t(a3)
.fin2:	rts

;-----------------------------------------------------------------------------
;	Vibrato
;-----------------------------------------------------------------------------
fx_vibrato:
	bsr.s	fx_do_vibrato
	bra	fx_fin_speciale

fx_do_vibrato:			; Ex‚cute le Vibrato
	move.w	d4,d5		; Retour par fx_fin_speciale !
	and.w	#$f,d4
	beq.s	.suite1
	move.b	d4,vibamp_t(a3)
.suite1:	lsr.w	#2,d5
	and.w	#$3c,d5
	beq.s	.suite2
	move.b	d5,vibspd_t(a3)
.suite2:	moveq	#0,d3
	move.b	vibcpt_t(a3),d3
	move.b	vibwav_t(a3),d4
	lea	gtkpl_sin_table,a4
	and.b	#3,d4
	beq.s	.sinus		; Forme sinus : 0
	lea	gtkpl_square_table,a4
	subq.b	#1,d4
	bne.s	.sinus		; Forme carr‚e : 2 (ou 3)
	lea	gtkpl_rampdown_table,a4
.sinus:	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	vibamp_t(a3),d4
	and.w	#$f,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#3,d3
	move.w	pernote_t(a3),d4
	add.w	d3,d4		; Nouvelle p‚riode de la note
	move.b	vibspd_t(a3),d3
	add.b	d3,vibcpt_t(a3)	; Ajoute la fr‚quence
	move.w	d4,per_t(a3)	; Valide la nouvelle p‚riode
	move.w	vollnot_t(a3),vol_t(a3)	; Met le volume
	move.w	curbal_t(a3),bal_t(a3)
	rts

;-----------------------------------------------------------------------------
;	Tone portamento + vibrato
;-----------------------------------------------------------------------------
fx_tone_porta_vib:
	bsr	fx_do_tone_porta
	moveq	#0,d4
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Vibrato + tone portamento
;-----------------------------------------------------------------------------
fx_vib_tone_porta:
	move.w	d4,-(sp)
	moveq	#0,d4
	bsr	fx_do_tone_porta
	move.w	d4,(sp)+
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Tremolo
;-----------------------------------------------------------------------------
fx_tremolo:
	move.w	d4,d5
	and.w	#$f,d4
	beq.s	.suite1
	move.b	d4,tremamp_t(a3)
.suite1:	lsr.w	#2,d5
	and.w	#$3c,d5
	beq.s	.suite2
	move.b	d5,tremspd_t(a3)
.suite2:	moveq	#0,d3
	move.b	tremcpt_t(a3),d3
	move.b	tremwav_t(a3),d4
	lea	gtkpl_sin_table,a4
	and.b	#3,d4
	beq.s	.sinus		; Forme sinus : 0
	lea	gtkpl_square_table,a4
	subq.b	#1,d4
	bne.s	.sinus		; Forme carr‚e : 2 (ou 3)
	lea	gtkpl_rampdown_table,a4
.sinus:	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	tremamp_t(a3),d4
	and.w	#$f,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#1,d3
	move.w	vollnot_t(a3),d4

	IfNe	CHECK
	tst.b	tremcpt_t(a3)	; N‚gatif ?
	bmi.s	.negatif
	EndC

	add.w	d3,d4		; Nouveau volume de la note

	IfNe	CHECK
	cmp.w	#$800,d4
	ble.s	.ok
	move.w	#$800,d4
	bra.s	.ok
.negatif:	add.w	d3,d4		; Nouveau volume de la note
	bpl.s	.ok
	moveq	#0,d4
	EndC

.ok:	move.b	tremspd_t(a3),d3
	add.b	d3,tremcpt_t(a3)	; Ajoute la fr‚quence
	move.w	d4,vol_t(a3)	; Valide le nouveau volume
	move.w	pernote_t(a3),per_t(a3)	; Met la p‚riode
	move.w	curbal_t(a3),bal_t(a3)
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Note delay
;-----------------------------------------------------------------------------
fx_delay:
	tst.w	delay_t(a3)
	bmi	fx_fin_normale	; -1, l'effet n'a plus de raison d'ˆtre
	bne	.nxt_vbl		; Compteur<>0, on attend encore
				; On initialise une note normale
	tst.w	d1		; Y a-t-il un instrument ?
	beq	.pas_inst
	move.w	d1,instr_t(a3)	; Oui, il devient l'instrument courant
	move.l	(adr_instrset,a1,d1.w*4),a2	; a2 pointe sur l'instrument
	move.w	vol_i(a2),d3	; Prend le volume dans d3
	move.w	curnote_t(a3),d4
	tst.w	d0		; Nouvelle note ?
	beq.s	.note_s
	move.w	d0,d4
.note_s:	move.b	transp_i(a2,d4.w*2),d1
	ext.w	d1
	move.w	d1,transp_t(a3)	; Transposition
	add.w	d1,d3		; Sur la note
	moveq	#0,d1
	move.b	splnum_i(a2,d4.w*2),d1
	move.w	d1,ninstr_t(a3)	; Il devient le sample courant
	move.l	(adr_samples,a1,d1.w*4),a4	; Recopie le finetune
	move.w	vol_s(a4),volsam_t(a3)	; et le volume du sample.
	move.w	d3,norm_v_t(a3)		; Le volume de l'instrument dans la voie
	move.w	ftune_s(a4),norm_f_t(a3)
	move.w	nbits_s(a4),d3		; Nombre de bits
	lsr.w	#3,d3
	move.w	d3,nbits_t(a3)
	move.w	fech_s(a4),fech_t(a3)		; Fr‚quence d'‚chantillonnage
	move.w	autobal_s(a4),d3
	bmi.s	.pasbalnc
	move.w	d3,curbal_t(a3)		; La balance
.pasbalnc:	move.w	norm_v_t(a3),d3
	lea	gtkpl_vlin_2_exp,a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Sans oublier le volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant aussi

.pas_inst:	tst.w	d0
	beq	fx_fin_normale	; S'il n'y a pas de note on s'en va
	move.w	d0,curnote_t(a3)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	move.w	instr_t(a3),d1
	move.l	(adr_instrset,a1,d1.w*4),a2	; a2 pointe sur l'instrument
	env_initialisation	a3,1,a2	; Initialise les enveloppes
	move.b	transp_i(a2,d0.w*2),d1
	ext.w	d1
	move.w	d1,transp_t(a3)	; Transposition
	add.w	d1,d3		; Sur la note
	moveq	#0,d1
	move.b	splnum_i(a2,d0.w*2),d1
	move.w	d1,ninstr_t(a3)	; Il devient le sample courant
	move.w	([adr_samples,a1,d1.w*4],vol_s),volsam_t(a3)	; Recopie le volume du sample
	move.w	([adr_samples,a1,d1.w*4],autobal_s),d4
	bmi.s	.pas_autb
	move.w	d4,curbal_t(a3)	; Recopie la balance du sample
.pas_autb:	sub.w	#24,d3

	IfNe	CHECK
	bpl.s	.check1ok
	moveq	#24,d3
.check1ok:	cmp.w	#127,d3
	ble.s	.check2ok
	moveq	#127,d3
.check2ok:
	EndC

	lsl.w	#3,d3
	add.w	norm_f_t(a3),d3
	add.w	d3,d3
	move.w	(a5,d3.w),pernote_t(a3)	; Sinon c'est une note normale
	move.w	(a5,d3.w),per2sl_t(a3)
	clr.l	pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
	move.w	ninstr_t(a3),d1
	move.l	(adr_samples,a1,d1.w*4),a4
	move.l	a4,adrsam_t(a3)	; Recopie l'adresse du sample,
	add.l	#data_s,adrsam_t(a3)
	move.l	(adr_repbuf,a1,d1.w*4),rbuffer_t(a3)	; l'adresse du buffer de r‚p‚tition,
	lea	repeat_s(a4),a4
	move.l	(a4)+,d3		; le point de r‚p‚tition,
	move.l	(a4),d4		; et la taille de la boucle
	move.l	d4,d5
	add.l	d3,d5
	cmp.l	#2,d5
	bne.s	.finsi
	move.l	-replen_s+length_s(a4),d3	; Si pas de bouclage
	subq.l	#2,d3
	moveq	#2,d4
.finsi:	move.l	d3,reppos_t(a3)
	move.l	d4,replen_t(a3)
	move.w	c_v_t(a3),d3	; Commande de volume ?
	beq.s	.nxt_vbl
	lea	gtkpl_vlin_2_exp,a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant ajust‚
.nxt_vbl:	subq.w	#1,delay_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Note cut
;-----------------------------------------------------------------------------
fx_note_cut:
	tst.w	cut_del_t(a3)	; Compteur … 0 ?
	bmi	fx_fin_normale	; -1, plus besoin de l'effet
	bne.s	.nxt_vbl		; <>0 , on attend encore
	move.w	nepan_t(a3),d5	; Sinon on met les enveloppes sur Key Off
	lea	([gtkpl_module_inf1+adr_epan,d5.w*4]),a4
	move.w	keyoffoffset_e(a4),d6
	add.w	#data_e,d6
	move.w	d6,depan_t(a3)
	clr.w	pepan_t(a3)
	clr.w	ep_waitcpt_t(a3)
	move.w	neton_t(a3),d5
	lea	([gtkpl_module_inf1+adr_eton,d5.w*4]),a4
	move.w	keyoffoffset_e(a4),d6
	add.w	#data_e,d6
	move.w	d6,deton_t(a3)
	clr.w	peton_t(a3)
	clr.w	et_waitcpt_t(a3)
	move.w	nevol_t(a3),d5
	beq.s	.pas_env		; Si pas d'enveloppe de volume, on le coupe simplement
	lea	([gtkpl_module_inf1+adr_evol,d5.w*4]),a4
	move.w	keyoffoffset_e(a4),d6
	add.w	#data_e,d6
	move.w	d6,devol_t(a3)
	clr.w	pevol_t(a3)
	clr.w	ev_waitcpt_t(a3)
	bra.s	.nxt_vbl
.pas_env:	clr.w	vollnot_t(a3)
	clr.w	volenot_t(a3)
.nxt_vbl:	subq.w	#1,cut_del_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Volume slide (linear)
;-----------------------------------------------------------------------------
fx_v_sldown_l:
	neg.w	d4
fx_v_slup_l:
	tst.w	d4
	bne.s	.ok
	move.w	volslspd_t(a3),d4
.ok:	move.w	d4,volslspd_t(a3)
	bsr.s	fx_do_v_slide_l
	bra	fx_fin_normale

fx_do_v_slide_l:			; Sous-routine de volume slide (lin.)
	move.w	vollnot_t(a3),d5
	lsr.w	#3,d5
	add.w	d5,d4

	IfNe	CHECK
	tst.w	d4
	bgt.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$100,d4
	ble.s	.ok2
	move.w	#$100,d4
	EndC

.ok2:	lea	gtkpl_vlin_2_exp,a4
	move	(a4,d4.w*2),volenot_t(a3)
	lsl.w	#3,d4
	move.w	d4,vollnot_t(a3)
	rts

;-----------------------------------------------------------------------------
;	Volume slide (exponential)
;-----------------------------------------------------------------------------
fx_v_sldown_e:			; Volume slide down (exp) \
	neg.w	d4		;                          > *** Ne pas s‚parer
fx_v_slup_e:			; Volume slide up (exp)   /
	bsr.s	fx_do_v_slide_e
	bra	fx_fin_normale

fx_do_v_slide_e:			; Sous-routine de volume slide (exp.)
	add.w	volenot_t(a3),d4

	IfNe	CHECK
	tst.w	d4
	bgt.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$800,d4
	ble.s	.ok2
	move.w	#$800,d4
	EndC

.ok2:	move.w	d4,volenot_t(a3)
	lea	gtkpl_vexp_2_lin,a4
	move.w	(a4,d4.w*2),vollnot_t(a3)
	rts

;-----------------------------------------------------------------------------
;	Linear volume slide + tone porta
;-----------------------------------------------------------------------------
fx_v_sldown_l_tp:
	neg.w	d4
fx_v_slup_l_tp:
	tst.w	d4
	bne.s	.ok
	move.w	volslspd_t(a3),d4
.ok:	move.w	d4,volslspd_t(a3)
	bsr.s	fx_do_v_slide_l
	moveq	#0,d4
	bsr	fx_do_tone_porta
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Exponential volume slide + tone porta
;-----------------------------------------------------------------------------
fx_v_sldown_e_tp:			; Volume slide down (exp) + tone porta \
	neg.w	d4		;                                       > *** Ne pas s‚parer
fx_v_slup_e_tp:			; Volume slide up (exp) + tone porta   /
	bsr.s	fx_do_v_slide_e
	moveq	#0,d4
	bsr	fx_do_tone_porta
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Linear volume slide + vibrato
;-----------------------------------------------------------------------------
fx_v_sldown_l_vib:
	neg.w	d4
fx_v_slup_l_vib:
	tst.w	d4
	bne.s	.ok
	move.w	volslspd_t(a3),d4
.ok:	move.w	d4,volslspd_t(a3)
	bsr	fx_do_v_slide_l
	moveq	#0,d4
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Exponential volume slide + vibrato
;-----------------------------------------------------------------------------
fx_v_sldown_e_vib:			; Volume slide down (exp) + vibrato \
	neg.w	d4		;                                    > *** Ne pas s‚parer
fx_v_slup_e_vib:			; Volume slide up (exp) + vibrato   /
	bsr	fx_do_v_slide_e
	moveq	#0,d4
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Linear master volume slide
;-----------------------------------------------------------------------------
fx_mv_sldown_l:			; Master volume slide down (lin) \
	neg.w	d4		;                                 > *** Ne pas s‚parer
fx_mv_slup_l:			; Master volume slide up (lin)   /
	bsr.s	fx_do_mv_slide_l
	bra	fx_fin_normale

fx_do_mv_slide_l:			; Sous-routine de master volume slide (lin)
	move.w	d0,-(sp)
	sndkernel	get_master_vol
	move.w	d0,d5
	move.w	(sp)+,d0
	add.w	d5,d4

	IfNe	CHECK
	tst.w	d4
	bpl.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$fff,d4
	ble.s	.ok2
	move.w	#$fff,d4
	EndC

.ok2:	move.w	d4,-(sp)
	sndkernel	set_master_vol
	addq.l	#2,sp
	rts

;-----------------------------------------------------------------------------
;	Left & Right balance move
;-----------------------------------------------------------------------------
fx_left_bal_move:
	neg.w	d4
fx_right_bal_move:
	lsl.w	#4,d4
	bne.s	.ok
	move.w	panslspd_t(a3),d4
.ok:	move.w	d4,panslspd_t(a3)
	add.w	curbal_t(a3),d4

	IfNe	CHECK
	bge.s	.ok3
	moveq	#0,d4
.ok3:	cmp.w	#$fff,d4
	ble.s	.ok2
	move.w	#$fff,d4
	EndC

.ok2:	move.w	d4,curbal_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Roll
;-----------------------------------------------------------------------------
fx_roll_7:
	tst.w	rollnbr_t(a3)
	beq	fx_fin_normale
	tst.b	rollcpt_t(a3)
	bne	.nxt_roll
	clr.l	pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
	subq.w	#1,rollnbr_t(a3)
.nxt_roll:	move.b	rollcpt_t(a3),d4
	addq.b	#1,d4
	cmp.b	rollspd_t(a3),d4
	bne.s	.fin_roll
	moveq	#0,d4
.fin_roll:	move.b	d4,rollcpt_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Roll + volume slide
;-----------------------------------------------------------------------------
fx_roll_and_vsl:
	tst.b	rollcpt_t(a3)
	bne	.nxt_roll
	clr.l	pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
.nxt_roll:	move.b	rollcpt_t(a3),d5
	addq.b	#1,d5
	cmp.b	rollspd_t(a3),d5
	bne	.fin_roll
	move.w	vollnot_t(a3),d3	; R‚cupŠre le volume courant
	and.w	#$FF,d4
	lsr.w	#4,d4
	cmp.b	#5,d4
	bgt.s	.x2_3
	moveq	#1,d5		; 0, -1, -2, -4, -8, -16
	addq.w	#2,d4
	lsl.w	d4,d5
	and.w	#-8,d5
	sub.w	d5,d3
	bra.s	.vol_ok
.x2_3:	cmp.b	#6,d4		; x 2/3
	bne.s	.x1_2
	add.w	d3,d3
	divu.w	#3,d3
	bra.s	.vol_ok
.x1_2:	cmp.b	#7,d4		; x 1/2
	bne.s	.plus_n
	lsr.w	#1,d3
	bra.s	.vol_ok
.plus_n:	cmp.b	#13,d4		; 0, +1, +2, +4, +8, +16
	bgt.s	.x3_2
	moveq	#1,d5
	subq.w	#6,d4
	lsl.w	d4,d5
	and.w	#-8,d5
	add.w	d5,d3
	bra.s	.vol_ok
.x3_2:	cmp.b	#14,d4
	bne.s	.x2
	move.w	d3,d5
	add.w	d3,d3
	add.w	d5,d3
	lsr.w	#1,d3
	bra.s	.vol_ok
.x2:	add.w	d3,d3
.vol_ok:	lea	gtkpl_vlin_2_exp,a4
	tst.w	d3
	bpl.s	.finsi1
	moveq	#0,d3
.finsi1:	cmp.w	#$800,d3
	ble.s	.finsi2
	move.w	#$800,d3
.finsi2:	move.w	d3,vollnot_t(a3)	; Volume courant
	lsr.w	#3,d3
	move.w	(a4,d3.w*2),volenot_t(a3)	; Sans oublier le volume exponentiel
	moveq	#0,d5
.fin_roll:	move.b	d5,rollcpt_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Tremor
;-----------------------------------------------------------------------------
fx_tremor:
	move.w	tremorc_t(a3),d4
	addq.w	#1,d4
	cmp.b	tremor2_t(a3),d4
	blt.s	.ok
	moveq	#0,d4
.ok:	move.w	tremorc_t(a3),d5
	move.w	d4,tremorc_t(a3)
	cmp.b	tremor1_t(a3),d5
	blt	fx_fin_normale	; Volume on
	clr.w	vol_t(a3)		; Volume off
	move.w	pernote_t(a3),per_t(a3)
	move.w	curbal_t(a3),bal_t(a3)
	bra	fx_fin_speciale

;-----------------------------------------------
;	AutoTempo
;-----------------------------------------------
fx_autotempo:
	tst.w	flag_autotempo_t(a3)	; D‚j… venu ?
	beq	fx_fin_normale	; Oui, on repart

; Tempo = 60 s * lignes * freqech * speed / (4 lignespartemps * longueurenspl * 6 ticks)
	move.w	d4,d5		; {
	add.w	d4,d4		;   d4 * 5
	add.w	d4,d4		;   car 5 = 60/4/(6/2)
	add.w	d5,d4		; }
	mulu.w	mod_speed(a0),d4
	mulu.w	fech_t(a3),d4
	move.l	reppos_t(a3),d5
	add.l	replen_t(a3),d5	; d5 = longueur du sample
	cmp.w	#2,nbits_t(a3)	; en unit‚s et non en octets
	bne.s	.ok1
	add.l	d4,d4		; Optimisation de la division par 2 de d5
.ok1:	cmp.l	#1024,d5		; Ne marche qu'avec des samples > 1 Ko.
	blt	fx_fin_normale
	add.l	d5,d5		; * 2 -> /(6/2) de d4
	move.l	d5,d3		; {
	lsr.l	#1,d3		;   Division avec r‚sultat arrondi au plus proche
	add.l	d3,d4		;
	divu.l	d5,d4		; } d4 = tempo
	beq	fx_fin_normale	; On s'en va si un des paramŠtres ‚tait nul
.test2:	cmp.l	#999,d4		; Tempo trop rapide ?
	ble.s	.ok2
	lsr.l	#1,d4		; On divise par 2 alors
	bra.s	.test2
.ok2:
	move.w	d4,-(sp)		; Hop le nouveau tempo
	bsr	gtkpl_set_tempo	; *** d0 non sauv‚
	addq.l	#2,sp

	clr.w	flag_autotempo_t(a3)	; C'est fini pour aujourd'hui
	bra	fx_fin_normale

;-----------------------------------------------
;	AutoPeriod
;-----------------------------------------------
fx_autoperiod:
	tst.w	flag_autoperiod_t(a3)	; D‚j… venu ?
	beq	fx_fin_normale	; Oui, on repart

; Periode = $1ac0 * 60 s * nbrlignes * speed * freqech / (tempo * 4 ligpartps * longueurspl * 6 ticks)
	mulu.w	#$1ac0*60/4/6,d4
	move.w	mod_speed(a0),d5
	mulu.w	fech_t(a3),d5
	mulu.l	d5,d5:d4		; d5:d4 = $1ac0*60*nbrlig*speed*fech/4/6

	move.l	reppos_t(a3),d3
	add.l	replen_t(a3),d3	; d3 = longueur du sample
	cmp.w	#2,nbits_t(a3)	; en unit‚s et non en octets
	bne.s	.ok1
	add.l	d4,d4		; Optimisation de la division par 2 de d5:d4
	addx.l	d5,d5
.ok1:	cmp.l	#1024,d3		; Ne marche qu'avec des samples > 1 Ko.
	blt	fx_fin_normale

	divu.l	d3,d5:d4		; *** r‚sultat sur plus de 32 bits ???
	moveq	#0,d5
	move.w	mod_tempo(a0),d5
	divu.l	d5,d4

	IfNE	CHECK

	ble	fx_fin_normale

.test1:	cmp.l	#PERIOD_MINI,d4
	bge.s	.oktest1
	add.l	d4,d4
	bra.s	.test1
.oktest1:

.test2:	cmp.l	#PERIOD_MAXI,d4
	ble.s	.oktest2
	lsr.l	d4,d4
	bra.s	.test2
.oktest2:

	EndC

	move.w	d4,pernote_t(a3)	; Fixe la nouvelle p‚riode

	clr.w	flag_autoperiod_t(a3)	; C'est fini pour aujourd'hui
	bra	fx_fin_normale





*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Data



;--- Pour le soundtracker ----------------------------------------------------
;... Tables de sauts pour les effets .........................................
	;    Certains sont inutilis‚s, donc on se tire directement
fx_table_de_sauts1:
	; 00xx - 0fxx
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_set_ftune,fx_predelay,fx_note_precut,fx_pos_jump
		Dc.l	fx_set_vib_wave,fx_break_pat,fx_set_trem_wave,fx_set_global_speed
	; 10xx - 1fxx
		Dc.l	fx_arpeggio_init,fx_fine_porta_up,fx_fine_porta_down,fx_roll_and_vsl_init
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
	; a0xx - afxx
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fine_v_slup_l,fx_fine_v_sldown_l,fx_fine_mv_slup_l,fx_fine_mv_sldown_l
		Dc.l	fx_set_nbr_of_frames,fx_set_fine_speed,fx_pattern_delay,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
	; b0xx - bfxx
		Dc.l	fx_tremor_init,fx_pattern_loop,fx_set_flags,fx_set_vol_env
		Dc.l	fx_set_ton_env,fx_set_pan_env,fx_set_vol_env_ko,fx_set_ton_env_ko
		Dc.l	fx_set_pan_env_ko,fx_demo_synchro,fx_fine_sample_offset,fx_very_fine_sample_offset
		Dc.l	fx_inc_sample_pos,fx_dec_sample_pos,fx_init_autotempo,fx_init_autoperiod

fx_table_de_sauts1b:
	; 0xxx - fxxx
		Dc.l	fx_fin1,fx_fin1,fx_set_lin_volume,fx_set_exp_volume
		Dc.l	fx_set_balance,fx_set_lin_master_vol,fx_set_exp_master_vol,fx_roll_7_init
		Dc.l	fx_roll_and_vsl_and_sbl_init,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1

fx_table_de_sauts2:
	; 00xx - 0fxx
		Dc.l	fx_fin_normale,fx_porta_up,fx_porta_down,fx_tone_porta
		Dc.l	fx_vibrato,fx_tone_porta_vib,fx_vib_tone_porta,fx_tremolo
		Dc.l	fx_fin_normale,fx_delay,fx_note_cut,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
	; 10xx - 1fxx
		Dc.l	fx_arpeggio,fx_fin_normale,fx_fin_normale,fx_roll_and_vsl
		Dc.l	fx_v_slup_l,fx_v_sldown_l,fx_v_slup_e,fx_v_sldown_e
		Dc.l	fx_v_slup_l_tp,fx_v_sldown_l_tp,fx_v_slup_e_tp,fx_v_sldown_e_tp
		Dc.l	fx_v_slup_l_vib,fx_v_sldown_l_vib,fx_v_slup_e_vib,fx_v_sldown_e_vib
	; a0xx - afxx
		Dc.l	fx_mv_slup_l,fx_mv_sldown_l,fx_fin_normale,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_extra_fine_tone_porta
		Dc.l	fx_extra_fine_porta_up,fx_extra_fine_porta_down,fx_left_bal_move,fx_right_bal_move
	; b0xx - bfxx
		Dc.l	fx_tremor,fx_fin_normale,fx_fin_normale,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_autotempo,fx_autoperiod

;... Table de 64 sinus [0,2ã[ ................................................
gtkpl_sin_table:
		Dc.w	$00,$18,$31,$4a,$61,$78,$8d,$a1
		Dc.w	$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		Dc.w	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5
		Dc.w	$b4,$a1,$8d,$78,$61,$4a,$31,$18
		Dc.w	-$00,-$18,-$31,-$4a,-$61,-$78,-$8d,-$a1
		Dc.w	-$b4,-$c5,-$d4,-$e0,-$eb,-$f4,-$fa,-$fd
		Dc.w	-$ff,-$fd,-$fa,-$f4,-$eb,-$e0,-$d4,-$c5
		Dc.w	-$b4,-$a1,-$8d,-$78,-$61,-$4a,-$31,-$18
gtkpl_square_table:			; Table d'onde carr‚e de 64 ‚l‚ments
		Dcb.w	32,$ff
		Dcb.w	32,-$ff
gtkpl_rampdown_table:			; Table d'onde triangulaire de 64 ‚l‚ments
	variable1:	Set	$ff
		Rept	64
		Dc.w	variable1
	variable1:	Set	variable1-8
		EndR

gtkpl_per_tab_load:	IncBin	'pertable.bin'	; Table de p‚riodes pour les notes (8 finetunes par note)
gtkpl_per_table:	Equ	gtkpl_per_tab_load+24*2	; D‚calage de 24 finetunes avant le C-0
gtkpl_vexp_2_lin:	IncBin	'vexp2lin.bin'	; Les correspondances de volume pour instrument
gtkpl_vlin_2_exp:	IncBin	'vlin2exp.bin'
gtkpl_vexp_2_lin_mst:	IncBin	'v_e2l_m.bin'	; Pareil, pour le master

;... Nom des chunks dans un module GT2 .......................................
gtkpl_gt2_chunknames:	Dc.l	'XCOM','TCN1','SONG','PATS'
		Dc.l	'PATD','ORCH','INST','SAMP'
		Dc.l	'VENV','TENV','PENV','ENDC'
		Dc.l	0
	; Cette liste est valable jusqu'… la version 3 du format GT2. Pour
	; pouvoir convertir correctement d'‚ventuels formats sup‚rieurs, il
	; est n‚cessaire de mettre … jour cette liste avec la documentation
	; des formats.

;... Donn‚es servant en Pause/Stop ...........................................
gtkpl_song_bidon:	Dc.w	NBRPATTERNS_MAXI-1	; 1 seule position: pattern 256

gtkpl_pat_bidon:	Dc.l	'PATD',32+NBRTRACK_MAXI*5	; Id, longueur
		Dc.w	NBRPATTERNS_MAXI-1	; Num‚ro
		Ds.b	16		; Nom
		Dc.w	0,1,NBRTRACK_MAXI	; Version de codage, lignes, pistes
		Dcb.b	NBRTRACK_MAXI*5,0	; -> 1 seule ligne, vide
		Even

gtkpl_instr_bidon:	Dc.l	'INST',316	; Id, longueur
		Dc.w	0	; Num‚ro
		Ds.b	28	; Nom
		Dc.w	0,0,-1	; Type, volume, autobalance
		Dc.w	0,0,0	; Enveloppes de volume, tonalit‚ et finetune
		Ds.b	10	; R‚serv‚
		Dcb.w	128,0<<8+0	; Samples et transpositions

gtkpl_sample_bidon:	Dc.l	'SAMP',64	; Id, longueur
		Dc.w	0	; Num‚ro
		Ds.b	28	; Nom
		Dc.w	0,-1,1,8363	; mono, balance, 8 bits, fr‚quence
		Dc.l	0,0,2	; Longueur, reppos, replen
		Dc.w	0,0,0	; Volume, finetune, version de codage

gtkpl_volenv_bidon:	Dc.l	'VENV',34	; Id, longueur
		Dc.w	0	; Num‚ro
		Ds.b	20	; Nom
		Dc.w	1	; Offset de la partie Key Off
		Dcb.b	2,0	; Enveloppes Attack et Key Off: End

gtkpl_tonenv_bidon:	Dc.l	'TENV',34	; Id, longueur
		Dc.w	0	; Num‚ro
		Ds.b	20	; Nom
		Dc.w	1	; Offset de la partie Key Off
		Dcb.b	2,0	; Enveloppes Attack et Key Off: End

gtkpl_panenv_bidon:	Dc.l	'PENV',34	; Id, longueur
		Dc.w	0	; Num‚ro
		Ds.b	20	; Nom
		Dc.w	1	; Offset de la partie Key Off
		Dcb.b	2,0	; Enveloppes Attack et Key Off: End

		Even



*~~~ Structures ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Bloc de descritption de l'‚tat actuel de chaque voie --------------------

;... Partie r‚serv‚e au noyau ................................................
		RsReset

;... Partie utilisateur (soundtracker en l'occurence) ........................
		IfNE	CONST_T

		RsSet	USER_T

		Else

		RsSet	kernelend_t

		EndC

c_n_t:		Rs.w	1	; La note dans la ligne de commande          \
c_i_t:		Rs.w	1	; L'instrument dans la ligne de commande      > * Ne pas dissocier
c_e_t:		Rs.w	1	; L'effet+paramŠtre dans la ligne de commande/
c_v_t:		Rs.w	1	; Le volume dans la ligne de commande       /
ninstr_t:		Rs.w	1	; Num‚ro de l'instrument courant
norm_v_t:		Rs.w	1	; Le volume par d‚faut du sample (0-$100)\ * Ne pas dissocier
norm_f_t:		Rs.w	1	; Finetune du sample                     /
curnote_t:		Rs.w	1	; La note courante
pernote_t:		Rs.w	1	; P‚riode courante (sans effet de vibrato)
vollnot_t:		Rs.w	1	; Volume courant lin‚aire (sans tremolo) (0-$800)
volenot_t:		Rs.w	1	; Volume courant exponentiel (sans tremolo)
portspd_t:		Rs.w	1	; Vitesse de tone portamento
note2sl_t:		Rs.w	1	; Note … atteindre en cas de slide
per2sl_t:		Rs.w	1	; P‚riode de la note … atteindre en cas de tone porta
arpegcpt_t:	Rs.w	1	; Compteur de l'arpeggio
vibspd_t:		Rs.b	1	; Vitesse du vibrato
vibcpt_t:		Rs.b	1	; Compteur du vibrato
vibamp_t:		Rs.b	1	; Amplitude du vibrato
vibwav_t:		Rs.b	1	; Forme d'onde du vibrato
tremspd_t:		Rs.b	1	; Vitesse du tremolo
tremcpt_t:		Rs.b	1	; Compteur du tremolo
tremamp_t:		Rs.b	1	; Amplitude du tremolo
tremwav_t:		Rs.b	1	; Forme d'onde du tremolo
rollspd_t:		Rs.b	1	; Vitesse des roulements
rollcpt_t:		Rs.b	1	; Compteur de roulements
rollnbr_t:		Rs.w	1	; Nbr de roulements encore … jouer
delay_t:		Rs.w	1	; Nbr de ticks … attendre avant de jouer la note
cut_del_t:		Rs.w	1	; Nbr de ticks … attendre avant de couper la note
tremorc_t:		Rs.w	1	; Compteur de tremor
tremor1_t:		Rs.b	1	; Nbr de frames o— la note n'est pas coup‚e
tremor2_t:		Rs.b	1	; P‚riode d'un tremor
ploopp_t:		Rs.w	1	; Point de r‚p‚tition pour l'effet Pattern loop
ploops_t:		Rs.w	1	; Position      "       "      "      "     "
ploopn_t:		Rs.w	1	; Nombre de r‚p‚titions pour l'effet Pattern loop
curbal_t:		Rs.w	1	; Balance courante
instr_t:		Rs.w	1	; Num‚ro de l'instrument courant
volsam_t:		Rs.w	1	; Volume du sample courant
transp_t:		Rs.w	1	; Transposition du sample courant
volslspd_t:	Rs.w	1	; Vitesse du volume slide
fvolslspd_t:	Rs.w	1	; Vitesse du fine volume slide
fportspd_t:	Rs.w	1	; Vitesse du fine portamento
panslspd_t:	Rs.w	1	; Vitesse du panning slide
nevol_t:		Rs.w	1	; Num‚ro de l'enveloppe de volume
neton_t:		Rs.w	1	; Num‚ro de l'enveloppe de tonalit‚
nepan_t:		Rs.w	1	; Num‚ro de l'enveloppe de panning
pevol_t:		Rs.w	1	; Position dans l'enveloppe de volume
peton_t:		Rs.w	1	; Position dans l'enveloppe de tonalit‚
pepan_t:		Rs.w	1	; Position dans l'enveloppe de panning
devol_t:		Rs.w	1	; D‚calage dans l'enveloppe de volume (32 pour l'Attack, 32 + ?? pour le Key Off)
deton_t:		Rs.w	1	; D‚calage dans l'enveloppe de tonalit‚
depan_t:		Rs.w	1	; D‚calage dans l'enveloppe de panning
ev_waitcpt_t:	Rs.w	1	; Compteur de la commande Wait de l'enveloppe de volume
ev_loopcpt_t:	Rs.w	1	; Compteur de boucle
ev_volume_t:	Rs.w	1	; Volume courant
ev_volstep_t:	Rs.w	1	; Pas du volume
ev_volspeed_t:	Rs.w	1	; Vitesse du volume
ev_volcpt_t:	Rs.w	1	; Compteur du volume
ev_tremoloflag_t:	Rs.b	1	; Flag de tremolo (on/off)
ev_tremorflag_t:	Rs.b	1	; Flag de tremor (on/off)
ev_tremolospeed_t:	Rs.b	1	; Vitesse du tremolo
ev_tremolowidth_t:	Rs.b	1	; Amplitude du tremolo
ev_tremolocpt_t:	Rs.b	1	; Compteur du tremolo
ev_tremolotype_t:	Rs.b	1	; Type de tremolo (0 = sin, 1 = carr‚, 2 = triangle)
ev_tremortime1_t:	Rs.b	1	; Longueur du tremor Volume On
ev_tremortime2_t:	Rs.b	1	; Longueur du tremor Volume Off
ev_tremorsection_t:	Rs.b	1	; Section actuelle du tremor (0 = time1, 1 = time2)
ev_tremorcpt_t:	Rs.b	1	; Compteur du tremor
		RsSet	(__rs+1)&-2	; Equivaut … RsEven
et_waitcpt_t:	Rs.w	1	; Compteur de la commande Wait de l'enveloppe de tonalit‚
et_loopcpt_t:	Rs.w	1	; Compteur de boucle
et_tone_t:		Rs.w	1	; P‚riode courante
et_tonestep_t:	Rs.w	1	; Pas de la p‚riode
et_tonespeed_t:	Rs.w	1	; Vitesse de la p‚riode
et_tonecpt_t:	Rs.w	1	; Compteur de la p‚riode
et_vibratoflag_t:	Rs.b	1	; Flag de vibrato (on/off)
et_vibratospeed_t:	Rs.b	1	; Vitesse du vibrato
et_vibratowidth_t:	Rs.b	1	; Amplitude du vibrato
et_vibratocpt_t:	Rs.b	1	; Compteur du vibrato
et_vibratotype_t:	Rs.b	1	; Type de vibrato (0 = sin, 1 = carr‚, 2 = triangle)
		RsSet	(__rs+1)&-2	; Equivaut … RsEven
ep_waitcpt_t:	Rs.w	1	; Compteur de la commande Wait de l'enveloppe de panning
ep_loopcpt_t:	Rs.w	1	; Compteur de boucle
ep_pan_t:		Rs.w	1	; Panning courant
ep_panstep_t:	Rs.w	1	; Pas du panning
ep_panspeed_t:	Rs.w	1	; Vitesse du panning
ep_pancpt_t:	Rs.w	1	; Compteur du panning
		RsSet	(__rs+1)&-2	; Equivaut … RsEven
flag_autotempo_t:	Rs.w	1	; 1 au 1er tick, 0 sinon.
flag_autoperiod_t:	Rs.w	1	; 1 au 1er tick, 0 sinon.

		IfNe	CONST_T
		 IfNe	__rs>TOTAL_T
		  Fail	"Taille de la structure InfoTrack-User sup‚rieure … la taille maximum fix‚e!"
		 Else
		  RsSet	TOTAL_T
		 EndC
		EndC

next_t:		Rs	0

;--- Chunk de description des samples ----------------------------------------
		RsReset
chunkid_s:		Rs.l	1	; 'SAMP'
chunksz_s:		Rs.l	1	; Taille du chunk
number_s:		Rs.w	1	; Num‚ro du sample
name_s:		Rs.b	28	; Nom du sample
stereo_s:		Rs.w	1	; 0 = mono, 1 = stereo
autobal_s:		Rs.w	1	; Balance automatique, -1 = rien
nbits_s:		Rs.w	1	; 1 = 8 bits, 2 = 16 bits
fech_s:		Rs.w	1	; Fr‚quence d'‚chantillonnage du sample (8363 Hz par d‚faut)
length_s:		Rs.l	1	; Longueur du sample
repeat_s:		Rs.l	1	; Point de bouclage
replen_s:		Rs.l	1	; Longueur de boucle
vol_s:		Rs.w	1	; Volume   \ *** Ne pas dissocier
ftune_s:		Rs.w	1	; Finetune /
codagev_s:		Rs.w	1	; Version de codage
data_s:		Rs	0	; D‚but des donn‚es du sample

;--- Chunk de description des instruments ------------------------------------
		RsReset
chunkid_i:		Rs.l	1	; 'INST'
chunksz_i:		Rs.l	1	; Taille du chunk
number_i:		Rs.w	1	; Num‚ro de l'instrument
name_i:		Rs.b	28	; Nom de l'instrument
type_i:		Rs.w	1	; Type de l'instrument (0 = sample)
vol_i:		Rs.w	1	; Volume
autobal_i:		Rs.w	1	; Autobalance
volenv_i:		Rs.w	1	; Enveloppe de volume
tonenv_i:		Rs.w	1	; Enveloppe de tonalit‚
panenv_i:		Rs.w	1	; Enveloppe de panning
		Rs.b	10	; R‚serv‚
splnum_i:		Rs.b	128*2	; Num‚ros de samples pour chaque note
transp_i:		Equ	splnum_i+1
next_i:		Rs	0

;--- Chunk de description des patterns ---------------------------------------
		RsReset
chunkid_p:		Rs.l	1	; 'PATD'
chunksz_p:		Rs.l	1	; Taille du chunk
number_p:		Rs.w	1	; Num‚ro du pattern
name_p:		Rs.b	16	; Nom du pattern
codagev_p:		Rs.w	1	; Version de codage (ici 0)
nlines_p:		Rs.w	1	; Nombre de lignes du pattern
ntrack_p:		Rs.w	1	; Nombre de pistes du pattern
data_p:		Rs	0	; D‚but des donn‚es du pattern

;--- Chunk de description des enveloppes -------------------------------------
		RsReset
chunkid_e:		Rs.l	1	; 'VENV', 'PENV' ou 'TENV'
chunksz_e:		Rs.l	1	; Taille du chunk
number_e:		Rs.w	1	; Num‚ro de l'enveloppe
name_e:		Rs.b	20	; Nom de l'enveloppe
keyoffoffset_e:	Rs.w	1	; Offset de la section Key Off par rapport … data_e
data_e:		Rs	0	; D‚but des donn‚es de l'enveloppe

;--- Diverses adresses … modifier lors d'un changement de module -------------
		RsReset
adr_samples:	Rs.l	NBRSAMPLES_MAXI	; Adresse de 256 samples maxi (… partir de 0)
adr_repbuf:	Rs.l	NBRSAMPLES_MAXI	; Adresse de 256 buffers de bouclage (… partir du sample 0)
adr_instrset:	Rs.l	NBRINSTR_MAXI	; Adresse de 256 instruments (en partant de 0)
adr_pattern:	Rs.l	NBRPATTERNS_MAXI	; Adresse de 256 patterns + 1 pour le pattern bidon
adr_evol:		Rs.l	NBRVOLENV_MAXI	; Adresse de 64 enveloppes de volume
adr_eton:		Rs.l	NBRTONENV_MAXI	; Adresse de 64 enveloppes de tonalit‚
adr_epan:		Rs.l	NBRPANENV_MAXI	; Adresse de 64 enveloppes de panning
adr_song:		Rs.l	1		; Adresse de la song
adr_next:		Rs	0

;--- Bloc de renseignements sur le module en cours ---------------------------
		RsReset
mod_nbrtrack:	Rs.w	1	; Nombre de pistes par pattern
mod_songlen:	Rs.w	1	; Taille de la song
mod_songrep:	Rs.w	1	; Point de r‚p‚tition
mod_songpos:	Rs.w	1	; Num‚ro de position dans la song (prochaine)
mod_numpat:	Rs.w	1	; Num‚ro du pattern (actuel)
mod_linepos:	Rs.w	1	; Num‚ro de position de la ligne (prochaine)
mod_cursongpos:	Rs.w	1	; Songpos (actuelle)
mod_curlinepos:	Rs.w	1	; Linepos (actuelle)
mod_flagnewpos:	Rs.w	1	; -1 si la position a ‚t‚ chang‚e par un Pos Jump, 0 sinon
mod_speed:		Rs.w	1	; Vitesse courante (ticks/ligne)
mod_patrep:	Rs.w	1	; Nombre de r‚p‚titions de la ligne
mod_nbrticks:	Rs.w	1	; Nombre de ticks ‚coul‚s depuis le d‚but de la ligne
mod_vblnumber:	Rs.w	1	; Nbr de VBL pour tenir un tick
mod_vblcpt:	Rs.w	1	; Compteur de VBL
mod_tempo:		Rs.w	1	; Tempo en BPM
mod_next:		Rs	0



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Bss



;--- Pour le soundtracker ----------------------------------------------------
gtkpl_flag_installed:	Ds.w	1	; 1 = Player install‚, 0 = non install‚
gtkpl_adr_info_track:	Ds.l	1	; Adresse de info_track, copie pour le player!
gtkpl_num_track:	Ds.w	NBRTRACK_MAXI	; Pistes occup‚es par le tracker
gtkpl_flag_stop_vcs:	Ds.w	1	; 1 = Faire taire les voies, attendre le retour
				; … 0 avant de changer les paramŠtres de la song
gtkpl_vblsize_int:	Ds.w	1	; \ *** Ne pas
gtkpl_vblsize_frac:	Ds.w	1	; / dissocier!!!
gtkpl_vblsize_count:	Ds.w	1	;
gtkpl_demo_synchro:	Ds.w	1
gtkpl_pause_backup:	Ds.b	NBRTRACK_MAXI*(4+4+2)	; Sauvegardes des longueurs, positions et
				; volumes sur chaque track lors d'une pause
gtkpl_module_inf1:	Ds.b	adr_next	; Quelques adresses concernant le module
gtkpl_module_inf2:	Ds.b	mod_next	; Informations g‚n‚rales sur le module
gtkpl_mod_len:	Ds.l	1	; Taille d'un module converti
gtkpl_temp_data:	Ds.l	1
gtkpl_zone_vide:	Ds.b	1024	; 1Ko de vide (totalement vide, qui doit le rester)

		Even



*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
