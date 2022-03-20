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
*	Installation du noyau en r‚sident			*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 15/12/1995, v0.742				*
* Tab setting : 11						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-95*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;     Fichier … assembler sous Devpac, Assemble ou logiciel compatible. Vous
; pouvez utiliser et distribuer ces routines ou parties comme bon vous semble,
; et si vous vous en servez dans un but non-lucratif, signalez-le moi. Pour
; une utilisation … fin commerciale, il faudra me demander mon autorisation.
;
;		Laurent de SORAS
;		92 avenue Albert 1er
;		92500 Rueil-Malmaison
;		FRANCE
;
;     Ceci est le source d'un noyau sonore pour Falcon 030. Son but est de
; faciliter la sonorisation des programmes grƒce … une bibliothŠque de
; routines. Vous pouvez alors utiliser jusqu'… 32 voies en 16 bits/50 KHz pour
; rejouer des sample. Les possibilit‚s sont alors trŠs vastes, cela va de la
; simple gestion de bruitages (pour un jeu par exemple) au replay de sound-
; tracks. L'int‚ret r‚side ‚galement dans le fait que plusieurs applications
; peuvent utiliser le noyau en mˆme temps, car on peut le laisser en temps que
; programme r‚sident. Le noyau monopolise le DSP, donc vous ne pourrez pas
; l'utiliser pour d'autres applications tant qu'il est install‚.
;     Ce programme est donc pr‚vu pour ˆtre r‚sident; ce qui implique que vos
; applications DEVRONT passer uniquement par les routines de la bibliothŠque,
; sans connaŒtre les adresses contenues dans ce listing, un peu comme pour le
; TOS. Ces routines sont d'ailleurs appelables par le TRAP #8, en empilant les
; paramŠtres … l'envers puis le num‚ro de fonction, comme d'habitude.
;     Au point de vue du fonctionnement, pour qu'une application puisse
; utiliser le noyau, elle devra d'abord r‚server des voies. Attention,
; plusieurs application pouvant cohabiter ensemble, les voies r‚serv‚es ne
; seront pas toujours les mˆmes d'une fois sur l'autre, donc faites bien la
; diff‚rence entre le num‚ro de VOS voies, et celui de celles qui leur corres-
; pond dans le noyau. Quand l'application est termin‚e ou qu'elle n'a plus
; besoin du noyau, elle devra lib‚rer les voies qu'elle avait r‚serv‚es. Et
; surtout, ne modifiez que VOS voies.
;     Encore une pr‚cision au niveau de la programmation, il est possible de
; demander au noyau l'adresse des informations sur les voies, pour y avoir
; accŠs plus rapidement qu'avec les Traps. N'utilisez que les structures
; document‚es! Il est ‚galement possible de changer cette adresse, mais cette
; op‚ration est fortement d‚conseill‚e, l'adresse pouvant ˆtre chang‚e
; seulement si l'app est seule … utiliser le noyau.
;
;     Donc un programme utilisant le noyau devrait se structurer comme ceci :
;     - Si le noyau n'est pas d‚j… l…, installation. S'il est l…, vous devrez
;       trouver le cookie 'SKER', dont la valeur est un mot long pointant sur
;       son num‚ro de version (mot court: $xx.xx).
;     - Activation du noyau si cela n'est pas fait
;     - R‚servation de N voies utiles … l'application
;     - Corps du programme : contr“le des sons grƒce aux routines
;     - Lib‚rations des N voies r‚serv‚es
;     - A la sortie, vous pouvez soit retirer le noyau de la m‚moire s'il est
;       totalement libre (nb de voies libres = nb de voies max), c'est le plus
;       conseill‚ d'ailleurs; soit le laisser, activ‚ ou non.
;
;     Si certaines choses ne sont pas encore trŠs claires sur le fonction-
; nement de ce noyau, allez lire les commentaires, certaines choses s'‚clair-
; ciront sans doute. Les *** signalent un point d‚licat.
;     D'autre part je tiens … dire que la routine de replay n'est volontaire-
; ment pas optimis‚e (… part les transferts de samples), pour pouvoir sup-
; porter des ‚volutions. Encore une fois, lisez les commentaires, il a des
; optimisations ‚videntes. Par contre les transferts de samples sont trŠs
; rapides et s'effectuent synchros avec le DSP : si vous utilisez des cartes
; acc‚l‚ratrices, il sera sans doute n‚cessaire de rajouter des NOPs dans les
; boucles ou des tests du type "writhost" optimis‚s (macro d‚finie plus bas).



	opt	p=68030



*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

;--- Indispensables pour le noyau lui-mˆme -----------------------------------
RESIDENT_KER:	Equ	1
KERNEL_TRAP_NUM:	Equ	8
CONST_T:		Equ	1	; Taille fixe pour les descripteurs de voies
USER_T:		Equ	$40	; Dans les descripteur de voies, donne la position
				; de d‚but des donn‚es r‚serv‚es … l'utilisateur
TOTAL_T:		Equ	$100	; Taille d'un descripteur d'une voie
next_t:		Equ	TOTAL_T	; Puisqu'il ne sera pas d‚fini, il faut le cr‚er

;--- Pour l'installation -----------------------------------------------------
KERNEL_COOKIE:	Equ	'SKER'	; Cookie du noyau
COOKIEJAR_SIZE:	Equ	64	; Jar de 64 cookie: raisonnable



*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

jump_r:	Macro			; Sauts dans les routines
n_\2:	Equ	\1
	cmp.w	#\1,d7		; Comparaison avec d7
	beq	\2		; L'adresse de retour doit d‚j… ˆtre dans la pile !
	EndM



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

gtkr_source_first_byte:

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	bra	install

	Include	'cookie.s'		; Les routines de gestion de cookie
	Include	'sndkernl.s'	; Les routines du noyau



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Text



;-----------------------------------------------------------------------------
;	Installation du programme en m‚moire
;-----------------------------------------------------------------------------
install:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		; Superviseur
	addq.l	#6,sp

	readcookie	#KERNEL_COOKIE	; On est d‚j… l… ?
	tst.l	d0
	bne.s	already_installed	; Oui, on repart tout de suite

;--- Trap et cookie ----------------------------------------------------------
	move.l	#gtkr_trap_routine,$80+KERNEL_TRAP_NUM*4

	newcookie	#KERNEL_COOKIE,#gtkr_kernel_info,#cookiejar

;--- Programme r‚sident ------------------------------------------------------
	pea	message1		; Tout va bien, on signale qu'on est l…
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	move.l	#gtkr_source_last_byte-gtkr_source_first_byte+256,-(sp)
	move.w	#$31,-(sp)
	trap	#1		; Programme r‚sident

;--- D‚j… l… -----------------------------------------------------------------
already_installed:
	pea	message2
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1



;-----------------------------------------------------------------------------
;	Routine appel‚e par le Trap, servant … ex‚cuter la fonction
;	demand‚e
;-----------------------------------------------------------------------------
gtkr_trap_routine:
	movem.l	d7/a6,-(sp)
	lea	8+8(sp),a6		; Place a6 sur la pile avant le Trap (movem + stack frame)
	btst	#5,-8(a6)		; Mais au fait, USP ou SSP ?
	bne.s	.ssp		; Tout va bien, on ‚tait en superviseur
	move.l	usp,a6		; Non, c'‚tait donc USP qui pointait sur le num‚ro de fonction
.ssp:	move.w	(a6)+,d7		; On prend le num‚ro de fnc dans d7, a6 sur 1er paramŠtre
	pea	.retour		; Empile l'adresse de retour car branchement ss-prg

;úúú Les sauts aux routines úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
	jump_r	$000,gtkr_remove_kernel
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

	addq.l	#4,sp		; Mauvais num‚ro de fonction
.retour:	movem.l	(sp)+,d7/a6
	rte



;-----------------------------------------------------------------------------
;	D‚plie les routines de gestion de cookie
;-----------------------------------------------------------------------------
	cookie_routines



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Data



message1:		Dc.b	'Sound Kernel installed',10,13	; Message d'installation
		Dc.b	'By Laurent de SORAS (Dumbo/BiG NoZ) - 1995',10,13,0
message2:		Dc.b	'Sound Kernel already installed!',10,13,0
		Even
gtkr_kernel_info:	Dc.w	KERNEL_VERSION



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Section	Bss



cookiejar:		Ds.b	COOKIEJAR_SIZE*8



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

gtkr_source_last_byte:

*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
