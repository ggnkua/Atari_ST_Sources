*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*							*
*		       DSP-replay routine			*
*	          for Graoumf Tracker modules (.GT2)		*
*			Falcon 030				*
*			Code 68030				*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*							*
*	Exemple d'utilisation des routines de soundtrack avec noyau	*
*	sonore r‚sident.					*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 15/12/1995, v0.742				*
* Tab setting : 11						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-95*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*



	opt	p=68030



*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

RESIDENT_KER:	Equ	1
KERNEL_TRAP_NUM:	Equ	8	; Trap #8 pour les appels au noyau
KERNEL_COOKIE:	Equ	'SKER'	; Id du cookie du noyau

;--- Cst propres au noyau, destin‚es au soundtracker -------------------------

NBRVOIES_MAXI:	Equ	32
CONST_T:		Equ	1
USER_T:		Equ	$40
TOTAL_T:		Equ	$100

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
		IfNe	CONST_T
		 IfNe	__rs>USER_T
		  Fail	"Taille de la structure InfoTrack-Kernel sup‚rieure … la taille maximum fix‚e!"
		 Else
		  RsSet	USER_T
		 EndC
		EndC
kernelend_t:	Rs	0	; Une routine voulant utiliser la structure User
				; devra initialiser son Rs avec cette valeur.

;--- Num‚ros des routines du noyau -------------------------------------------
n_gtkr_remove_kernel:		Equ	$000
n_gtkr_kernel_status:		Equ	$001
n_gtkr_kernel_on:		Equ	$002
n_gtkr_kernel_off:		Equ	$003
n_gtkr_reset_kernel_tracks:	Equ	$004
n_gtkr_reserve_track:		Equ	$005
n_gtkr_free_track:		Equ	$006
n_gtkr_make_rbuffer:		Equ	$007
n_gtkr_play_sample:		Equ	$008
n_gtkr_stop_track:		Equ	$009
n_gtkr_pause_track:		Equ	$00A
n_gtkr_cont_track:		Equ	$00B
n_gtkr_add_routine:		Equ	$00C
n_gtkr_remove_routine:	Equ	$00D
n_gtkr_get_master_vol:	Equ	$00E
n_gtkr_set_master_vol:	Equ	$00F
n_gtkr_get_vblsize:		Equ	$010
n_gtkr_set_vblsize:		Equ	$011
n_gtkr_get_track_adr:		Equ	$012
n_gtkr_set_track_adr:		Equ	$013
n_gtkr_get_replay_freq:	Equ	$014
n_gtkr_set_replay_freq:	Equ	$015
n_gtkr_total_nbr_of_tracks:	Equ	$016
n_gtkr_nbr_of_free_tracks:	Equ	$017
n_gtkr_put_new_app_id:	Equ	$018
n_gtkr_get_app_id:		Equ	$019
n_gtkr_remove_app_id:		Equ	$01A
n_gtkr_nbr_of_app_id:		Equ	$01B
n_gtkr_interpolate_track:	Equ	$01C



*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

sndkernel:	Macro			; Appel … une fonction du noyau sonore
	move.w	#n_gtkr_\1,-(sp)
	trap	#KERNEL_TRAP_NUM
	addq.l	#2,sp
	EndM

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

gtkpl_source_first_byte:

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	bra	exemple

	Include	'cookie.s'		; Les routines de gestion des cookies
	Include	'gt2playr.s'	; Les routines de soundtrack



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Text



exemple:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		; Superviseur (… cause des cookies)
	addq.l	#6,sp

	readcookie	#KERNEL_COOKIE	; Noyau r‚sident ?
	tst.l	d0
	beq	error0		; Non, mais qu'est-ce qu'on fait ici ???

	sndkernel	kernel_status	; Le noyau est activ‚ ?
	tst.l	d0
	bne.s	activated

	move.l	#gtkr_info_track,-(sp)
	move.w	#NBRVOIES_MAXI,-(sp)
	sndkernel	kernel_on		; Non, on l'active
	addq.l	#6,sp
	tst.l	d0
	bmi	error5		; Impossible de l'activer!
activated:

;--- Exemple de replay d'un module -------------------------------------------
	bsr	gtkpl_player_on	; Installe le player
	tst.l	d0
	bmi	error1

	pea	module_gt2		; Convertit le module au format interne
	pea	module_gt2
	move.w	#0,-(sp)		; *** 0 = GT2 ***
	bsr	gtkpl_convert_module
	lea	10(sp),sp
	tst.l	d0
	bmi	error2

	pea	0.l		; Pr‚pare les samples du module en calculant les
	pea	repeatbuffer	; buffers de bouclage
	pea	module_gt2
	bsr	gtkpl_make_rb_module
	lea	12(sp),sp
	tst.l	d0
	bmi	error3

	clr.w	-(sp)		; Pof, on fait tourner tout ‡a
	clr.w	-(sp)
	pea	repeatbuffer
	pea	module_gt2
	bsr	gtkpl_new_module
	lea	12(sp),sp
	tst.l	d0
	bmi	error4
	printames	str_playmod
	waitakey			; On attend que l'utilisateur presse une touche

	and.b	#%11011111,d0	; -> majuscule
	cmp.b	#'R',d0		; Touche R ?
	bne.s	exit_player_not_res	; Non, on retire le player avant de partir

	clr.w	-(sp)		; Oui, on le laisse tourner
	move.l	#gtkpl_source_last_byte-gtkpl_source_first_byte+256,-(sp)
	move.w	#$31,-(sp)
	trap	#1		; On quitte avec le player en r‚sident

exit_player_not_res:
	bsr	gtkpl_player_off	; Retire le player et libŠre ses voies
exit:	clr.w	-(sp)		; Sortie
	trap	#1

error0:	printames	str_error0
	waitakey
	bra.s	exit

error1:	printames	str_error1
	waitakey
	bra.s	exit

error2:	printames	str_error2
	waitakey
	bra.s	exit_player_not_res

error3:	printames	str_error3
	waitakey
	bra.s	exit_player_not_res

error4:	printames	str_error4
	waitakey
	bra.s	exit_player_not_res

error5:	printames	str_error5
	waitakey
	bra	exit



;-----------------------------------------------------------------------------
;	D‚plie les routines de gestion de cookies
;-----------------------------------------------------------------------------
	cookie_routines



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Data



str_playmod:	Dc.b	'Playing a module...',10,13
		Dc.b	'Press <R> if you want to quit and',10,13
		Dc.b	'continue playing the module.',10,13,0
str_pausemod:	Dc.b	'Pause...',10,13,0
str_contmod:	Dc.b	'Continue...',10,13,0
str_stopmod:	Dc.b	'Stop module.',10,13,0
str_playspl:	Dc.b	'Playing a sample...',10,13,0
str_pausespl:	Dc.b	'Pause...',10,13,0
str_contspl:	Dc.b	'Continue...',10,13,0
str_stopspl:	Dc.b	'Stop sample.',10,13,0
str_error0:	Dc.b	'Error: Sound Kernel not installed...',10,13,0
str_error1:	Dc.b	'Error: player can''t be installed',10,13,0
str_error2:	Dc.b	'Error: module can''t be converted',10,13,0
str_error3:	Dc.b	'Error: loopbuffer can''t be created',10,13,0
str_error4:	Dc.b	'Error: module can''t be played',10,13,0
str_error5:	Dc.b	'Error: Sound Kernel can''t be activated.',10,13
		Dc.b	'Probably sound sub-system locked...',10,13,0
		Even

module_gt2:	IncBin	'blouba.gt2'	; *** Mettre ici le nom du module
		Ds.b	50000
		Even



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Bss



gtkr_info_track:	Ds.b	next_t*NBRVOIES_MAXI
		Even
repeatbuffer:	Ds.b	NBRSAMPLES_MAXI*1024	; Buffers de r‚p‚tition de N samples maxi + 1 vide



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

gtkpl_source_last_byte:

*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
