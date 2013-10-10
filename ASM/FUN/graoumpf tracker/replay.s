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
*	Utilisation des routines de soundtrack avec le noyau sonore	*
*	non r‚sident.					*
*          => Donne le fichier REPLAY.PGT (… assembler avec GFA_FLAG = 1).	*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 21/7/1996, v0.865				*
* Tab setting : 11						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-96*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*



	opt	p=68030
	opt	d-		; Pas de table des symboles
	output	D:\REPLAY.PGT



*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Contr“le du Noyau -------------------------------------------------------
GFA_FLAG:		Equ	1	; 0 = assembleur
				; 1 = routine pour GfA Basic et
				;     fichier REPLAY.PGT
RESIDENT_KER:	Equ	0	; On ne reste pas r‚sident



*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Pour les routines GfA Basic  --------------------------------------------

	IfNe	GFA_FLAG
jump_r:	Macro			; Sauts dans les routines
	cmp.w	#\1,d7		; Comparaison avec le num‚ro de fonction
	beq	\2		; L'adresse de retour doit d‚j… ˆtre dans la pile !
	EndM
	EndC



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Text



;ððð Partie GfA Basic ððððððððððððððððððððððððððððððððððððððððððððððððððððððððð

	IfNe	GFA_FLAG

	bra	gfa_relocation

;--- Sauts aux routines, pour le GfA Basic ------------------------------------
	move.l	(sp),gfa_adresse_appel
	move.l	sp,gfa_pile
	lea	gfa_autrepile,sp

	movem.l	d1-a6,-(sp)
	pea	gfa_sauts
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d1-a6
	move.l	gfa_pile,sp
	move.l	gfa_adresse_appel,(sp)
	rts

gfa_sauts:
	move.l	sp,gfa_superpile
	move.l	gfa_pile,sp	; On se place sur la ribambelle de paramŠtres GfA
	move.w	4(sp),d7		; Prends le No de fonction, aprŠs l'adr de retour
	addq.l	#2,sp		; Ecrase le-dit num‚ro
	move.l	#gfa_fin,(sp)	; Met l'adresse de retour juste avant le 1er paramŠtre

	jump_r	$001,gtkr_kernel_status
	jump_r	$002,gtkr_kernel_on
	jump_r	$003,gtkr_kernel_off
	jump_r	$004,gtkr_reset_kernel_tracks
	jump_r	$005,gtkr_reserve_track
	jump_r	$006,gtkr_free_track
	jump_r	$007,gtkr_make_rbuffer
	jump_r	$008,gtkr_play_sample
	jump_r	$009,gtkr_stop_track
	jump_r	$00A,gtkr_pause_track
	jump_r	$00B,gtkr_cont_track
	jump_r	$00C,gtkr_add_routine
	jump_r	$00D,gtkr_remove_routine
	jump_r	$00E,gtkr_get_master_vol
	jump_r	$00F,gtkr_set_master_vol
	jump_r	$010,gtkr_get_vblsize
	jump_r	$011,gtkr_set_vblsize
	jump_r	$012,gtkr_get_track_adr
	jump_r	$013,gtkr_set_track_adr
	jump_r	$014,gtkr_get_replay_freq
	jump_r	$015,gtkr_set_replay_freq
	jump_r	$016,gtkr_total_nbr_of_tracks
	jump_r	$017,gtkr_nbr_of_free_tracks
	jump_r	$018,gtkr_put_new_app_id
	jump_r	$019,gtkr_get_app_id
	jump_r	$01A,gtkr_remove_app_id
	jump_r	$01B,gtkr_nbr_of_app_id
	jump_r	$01C,gtkr_interpolate_track

	jump_r	$102,gtkpl_player_on
	jump_r	$103,gtkpl_player_off
	jump_r	$104,gtkpl_reset_sndtrk_tracks
	jump_r	$105,gtkpl_convert_module
	jump_r	$106,gtkpl_make_rb_module
	jump_r	$107,gtkpl_get_adr_samples
	jump_r	$108,gtkpl_set_adr_samples
	jump_r	$109,gtkpl_new_module
	jump_r	$10A,gtkpl_stop_module
	jump_r	$10B,gtkpl_pause_module
	jump_r	$10C,gtkpl_cont_module
	jump_r	$10D,gtkpl_change_modpos
	jump_r	$10E,gtkpl_get_modsongpos
	jump_r	$10F,gtkpl_get_modlinepos
	jump_r	$110,gtkpl_get_tempo
	jump_r	$111,gtkpl_set_tempo
	jump_r	$112,gtkpl_get_synchro_adr

gfa_fin:	move.l	gfa_superpile,sp		; Remet la bonne pile
	rts

;--- Relocation du programme --------------------------------------------------
gfa_relocation:   
	movem.l	d1-d2/a0-a3,-(sp)	move.l	24+4(sp),a0	; 4(sp) : adresse du PRG
	move.l	2(a0),d0
	add.l	6(a0),d0
	add.l	14(a0),d0
	move.l	10(a0),d2
	adda.l	#$1c,a0
	move.l	a0,d1
	movea.l	a0,a1
	movea.l	a1,a2
	adda.l	d0,a1
	move.l	a1,a3
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	clr.l	d0
.loop:	move.b	(a1)+,d0
	beq.s	.end
	cmp.b	#1,d0
	beq.s	.next
	adda.l	d0,a2
	add.l	d1,(a2)
	bra.s	.loop
.next:	adda.l	#$fe,a2
	bra.s	.loop
.end:	clr.w	(a3)+		; Vide la zone BSS
	subq.l	#2,d2
	bgt.s	.end
	move.l	#gfa_info_track,d0	; Renvoie l'adresse des infos sur les pistes
	movem.l	(sp)+,d1-d2/a0-a3
	rts

	EndC



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Include	'sndkernl.s'	; Les routines du noyau
	Include	'gt2playr.s'	; Les routines du soundtracker



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Bss



;--- Pour le GfA -------------------------------------------------------------
		IfNe	GFA_FLAG

gfa_adresse_appel:	Ds.l	1
gfa_pile:		Ds.l	1
gfa_superpile:	Ds.l	1
		Ds.l	256
gfa_autrepile:
gfa_info_track:	Ds.b	next_t*NBRVOIES_MAXI	; Informations sur les pistes
		Even

		EndC



*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
