******************************************************************************
*							*
*		G R A O U M F   T R A C K E R			*
*							*
*	Soundtracker Falcon 030 32 voies au DSP			*
*	Par Laurent de Soras (c) 1994-95				*
*____________________________________________________________________________*
*							*
*	Langage          :	Assembleur 68030 (sous Devpac 2.23)	*
*	Nom du source    :	PLAYDSP3.S				*
*	Code g‚n‚r‚      :	GTPLAY.PGT				*
*	Include          :	-				*
*	IncBin           :	PERTABLE.BIN			*
*			VEXP2LIN.BIN			*
*			VLIN2EXP.BIN			*
*			V_E2L_M.BIN			*
*			V_E2L_T.BIN			*
*			V_L2E_T.BIN			*
*			PLAYDSP.P56			*
*	Version          :	0.877				*
*	Date             :	2/12/1996				*
*							*
*	Routine de replay pour le Graoumf Tracker, joue les modules	*
*	et les sons, gŠre le MIDI.				*
*							*
*	Tab = 11						*
*							*
******************************************************************************


	comment head=%111
	output	e:\gtk08770.dmo\sys\gtplay.pgt
	Opt	p=68030,x-,d-,e-,s-
	
	;Output	f:\dev.gtk\sys\gtplay.pgt



*÷÷÷ Constantes ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

REPLAY_FREQ:	Equ	49170	; Fr‚quence de base de replay

NBRVOIES_MAXI:	Equ	32	; Nombre maximum de voies, on peut en mettre
				; autant qu'on veut en fait, du moment que le
				; processeur est assez rapide pour toutes les jouer !
SAMPLE_AMPLIFICATION:	Equ	1	; 0 = ne peut pas amplifier les samples au-dessus
				; de leur volume naturel.
				; 1 = amplification … puissance ‚lev‚e possible.
				; Ce flag n'est int‚ressant que pour des samples dont
				; le volume_s * master est > $100000
				; (vol_t * master > $800000)

NBRSAMPLES_MAXI:	Equ	1+255	; Nombre maximum de samples (+1 vide)
NBRINSTR_MAXI:	Equ	1+255	; Nombre maximum d'instruments (+1 vide)
NBRPATTERNS_VIDES:	Equ	2	; Nombre de patterns vides
NBRPATTERNS_MAXI:	Equ	256+NBRPATTERNS_VIDES	; Nombre maximum de patterns (+n vides)
NBRVOLENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de volume (+1 vide)
NBRTONENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de tonalit‚ (+1 vide)
NBRPANENV_MAXI:	Equ	1+63	; Nombre maximum d'enveloppes de panning (+1 vide)


DSP_EXCEPTION:	Equ	255	; Num‚ro du vecteur d'interruption HOST du DSP

DSP_WAIT:	=	1	; Patched dsp host transfer.

INTERRUPTION_TYPE:	Equ	0	; 0 = interruption DSP
				; 1 = Timer A
				; 2 = Timer C
				; 3 = Timer D

CHECK:		Equ	2	; 0 = aucune v‚rification (+ rapide - fiable)
				; 1 = v‚rifie lors de chaque op‚ration que les
				;     r‚sultats sont bien dans les bons intervalles
				; 2 = Idem que 1 mais v‚rifie aussi l'int‚grit‚
				;     des paramŠtres donn‚s.

		IfNE	CHECK
PERIOD_MAXI:	Equ	32575
PERIOD_MINI:	Equ	71
		EndC

ENV_COMMANDMAX:	Equ	16	; Nombre de commande maximum par tick
				; dans une enveloppe

MIDI_NBR_CHANNELS:	Equ	16	; Nombre de canaux MIDI

MIDI_IN:		Equ	1	; 0 = pas de Midi In
				; 1 = gestion du Midi In
		IfNE	MIDI_IN
MIDI_IN_MAX_TCLK:	Equ	16	; En mode Synchro In, nombre max d'impulsions
				; qu'on peut rattraper. Remise … 0 aprŠs.
MIDI_IN_DATA_BUF_LEN:	Equ	256	; Buffer de r‚ception de donn‚es MIDI (pour une commande)
		EndC

MIDI_OUT:		Equ	1	; 0 = pas de Midi Out
				; 1 = gestion du Midi Out
		IfNE	MIDI_OUT
MIDI_OUT_DATA_BUF_LEN:	Equ	4096	; Buffer d'‚mission des donn‚es MIDI
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

;--- Adresses ----------------------------------------------------------------

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
CBASEHI:		Equ	$ffff8909	; Octet haut de la position DMA de lecture/enregistrement (bits 16-23)
CBASEMID:		Equ	$ffff890b	; Octet moyen (bits 8-15)
CBASELO:		Equ	$ffff890d	; Octet bas (bits 0-7)
TRAKCTRL:		Equ	$ffff8920
SAMPMOD:		Equ	$ffff8921
SDMATRIX:		Equ	$ffff8930	; Source Device Matrix
DDMATRIX:		Equ	$ffff8932	; Destination Device Matrix
FDECLOCK:		Equ	$ffff8934	; Frequency Diviser External Clock
FDISYNC:		Equ	$ffff8935	; Frequency Diviser Internal Sync

FCOLOR00:		Equ	$ffff9800	; Falcon Color $0
FC_BLACK:		Equ	$00000000	; Noir
FC_RED:		Equ	$ff000000	; Rouge
FC_GREEN:		Equ	$00ff0000	; Vert
FC_BLUE:		Equ	$000000ff	; Bleu
FC_YELLOW:		Equ	FC_RED+FC_GREEN
FC_MAGENTA:	Equ	FC_RED+FC_BLUE
FC_CYAN:		Equ	FC_GREEN+FC_BLUE
FC_WHITE:		Equ	FC_RED+FC_GREEN+FC_BLUE

MFPST_INT_TIMERA:	Equ	$134
MFPST_INT_TIMERC:	Equ	$114
MFPST_INT_TIMERD:	Equ	$110
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



*÷÷÷ Macros ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

;--- Port Host du DSP --------------------------------------------------------

writhost:	Macro			; Attend que le port Host soit
.wrhst\@:	btst	#1,DSPHSR.w	; libre en ‚criture
	beq.s	.wrhst\@
	EndM

readhost:	Macro			; Attend qu'une donn‚e soit
.rdhst\@:	btst	#0,DSPHSR.w	; pr‚sente sur le port Host afin
	beq.s	.rdhst\@		; d'ˆtre lue
	EndM

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



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	Text



;--- Programmes principaux, appel‚s par le GfA Basic -------------------------

	bra	relocation		; Relocation du prg, et fournit quelques
				; adresses au GfA
	bra	player_on		; D‚clenche toute l'installation du
				; player avec le DSP
	bra	boucle_instrument	; Boucle un instrument
	bra	gfa_play_one_sample	; Joue un sample dont on a fourni les
				; paramŠtre
	bra	gfa_play_one_note	; Joue un instrument dans une voie donn‚e
	bra	songrecord_routine_no_realtime1	; Enregistre un module



player_on:	movem.l	d0-a6,-(sp)
	pea	init_mod_player
	move.w	#$26,-(sp)
	trap	#14		; Ex‚cute en Superviseur
	addq.l	#6,sp
	movem.l	(sp)+,d0-a6
	rts

gfa_play_one_sample:
	move.l	a0,-(sp)
	move.l	4+4(sp),a0
	move.w	4+8(sp),d0
	bsr	play_one_sample
	move.l	(sp)+,a0
	rts

gfa_play_one_note:			; Param:
	movem.l	d0/a0,-(sp)	; - Adresse.l des 5 octets de la note
	move.l	8+4(sp),a0		; - Num‚ro.w de la voie
	move.w	8+8(sp),d0
	bsr	play_one_note
	movem.l	(sp)+,d0/a0
	rts

songrecord_routine_no_realtime1:
	movem.l	d0/a0,-(sp)
	pea	songrecord_routine_no_realtime
	move.w	#$26,-(sp)
	trap	#14		; Ex‚cute en Superviseur
	addq.l	#6,sp
	movem.l	(sp)+,d0/a0
	rts


;-----------------------------------------------------------------------------
;	Routine de relocation.
;	Fournir l'adresse du PRG charg‚ en 4(sp), renvoie l'adresse de
;	de adr_labels dans d0
;-----------------------------------------------------------------------------
relocation:   
	movem.l	d1/a0-a2,-(sp)
	move.l	16+4(sp),a0	; 4(sp) : adresse du PRG
	move.l	2(a0),d0
	add.l	6(a0),d0
	add.l	14(a0),d0
	adda.l	#$1c,a0
	move.l	a0,d1
	movea.l	a0,a1
	movea.l	a1,a2
	adda.l	d0,a1
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	clr.l	d0
relocloop:	move.b	(a1)+,d0
	beq.s	reloc_end
	cmp.b	#1,d0
	beq.s	reloc_nxt
	adda.l	d0,a2
	add.l	d1,(a2)
	bra.s	relocloop
reloc_nxt:	adda.l	#$fe,a2
	bra.s	relocloop
reloc_end:	lea	adr_labels(pc),a0
	move.l	a0,d0
	movem.l	(sp)+,d1/a0-a2
	rts



;-----------------------------------------------------------------------------
;	Petite initialisation
;-----------------------------------------------------------------------------
init_mod_player:

	movem.l	d0-a6,-(sp)

;--- Pr‚pare le module -------------------------------------------------------

	bsr	prepare_module
	IfNE	MIDI_IN
	bsr	gestmidi_init_in
	EndC

;--- Charge la routine DSP en m‚moire DSP ------------------------------------

	move.w	#$71,-(sp)		; DSP request ability
	trap	#14
	move.w	d0,(sp)
	move.l	#(routine_dsp_lon-routine_dsp)/3,-(sp)	; La longueur
	pea	routine_dsp
	move.w	#$6d,-(sp)		; Charge le prog en m‚moire DSP
	trap	#14
	lea	12(sp),sp

	move.l	#$902000,SDMATRIX.w	; Connecte le DSP … la matrice
	move.w	#$101,FDECLOCK.w	; 50 KHz
	move.b	#$0,PLAYMOD.w
	move.w	#$3,TRAKCTRL.w

;--- Initialise l'interruption -----------------------------------------------

	IfNE	INTERRUPTION_TYPE=0	; Interruption DSP
	move.b	#DSP_EXCEPTION,DSPIVR.w	; Num‚ro de l'exception d‚clench‚e lors de la
	move.l	#soundtracking_kernel,DSP_EXCEPTION*4.w	; r‚ception d'une donn‚e par le port Host
	move.b	#1,DSPHCR.w	; Autorise l'interruption
	move.l	#DSP_EXCEPTION*4,adr_adr_inter
	Else
	move.l	#soundtracking_kernel,adresse_interruption
	move.l	#adresse_interruption,adr_adr_inter
	EndC

	IfNE	INTERRUPTION_TYPE=1	; Interruption Timer A
	move.l	MFPST_INT_TIMERA.w,sauvegarde_timer
	bclr	#5,MFPIMRA.w	; Timer A masqu‚
	bset	#5,MFPIERA.w	; Timer A autoris‚
	move.b	#6,MFPTACR.w	; 1/100 : 24576 Hz
	move.b	#3,MFPTADR.w	; /3 : 8192 Hz
	move.l	#gtkr_interruption_timer,MFPST_INT_TIMERA.w
	bset	#5,MFPIMRA.w	; Timer A d‚masqu‚
	EndC

	IfNE	INTERRUPTION_TYPE=2	; Interruption Timer C
	move.l	MFPST_INT_TIMERC.w,sauvegarde_timer
	bclr	#5,MFPIMRB.w	; Timer C masqu‚
	bset	#5,MFPIERB.w	; Timer C autoris‚
	and.b	#%10001111,MFPTCDCR.w
	or.b	#6<<4,MFPTCDCR.w	; 1/100 : 24576 Hz
	move.b	#3,MFPTCDR.w	; /3 : 8192 Hz
	move.l	#gtkr_interruption_timer,MFPST_INT_TIMERC.w
	bset	#5,MFPIMRB.w	; Timer C d‚masqu‚
	EndC

	IfNE	INTERRUPTION_TYPE=3	; Interruption Timer D
	move.l	MFPST_INT_TIMERD.w,sauvegarde_timer
	bclr	#4,MFPIMRB.w	; Timer D masqu‚
	bset	#4,MFPIERB.w	; Timer D autoris‚
	and.b	#%11111000,MFPTCDCR.w
	or.b	#6,MFPTCDCR.w	; 1/100 : 24576 Hz
	move.b	#3,MFPTDDR.w	; /3 : 8192 Hz
	move.l	#gtkr_interruption_timer,MFPST_INT_TIMERD.w
	bset	#4,MFPIMRB.w	; Timer D d‚masqu‚
	EndC

	clr.w	flag_the_end

	writhost
	move.l	#$0,DSPHTDR_L.w	; C'est parti mon kiki!

	movem.l	(sp)+,d0-a6
	rts



	IfNE	INTERRUPTION_TYPE

;ððð Routine sous Timer si celui-ci est choisi ððððððððððððððððððððððððððððððð

gtkr_interruption_timer:
	and.w	#%1111100011111111,sr	; Autorise toutes les interruptions
	btst	#0,DSPHSR.w	; Une donn‚e a ‚t‚ envoy‚e par le DSP ?
	beq.s	.rien
	jmp	([adresse_interruption])	; Oui, faut y aller
.rien:
	IfNE	INTERRUPTION_TYPE=1
	bclr	#5,MFPISRA.w	; Sinon on attend le prochain coup
	EndC
	IfNE	INTERRUPTION_TYPE=2
	bclr	#5,MFPISRB.w
	EndC
	IfNE	INTERRUPTION_TYPE=3
	bclr	#4,MFPISRB.w
	EndC
	rte

	EndC



;-----------------------------------------------------------------------------
;	Pr‚paration du module. L'adresse du module doit ˆtre fournie
;	ainsi que les adresses du descripteur d'instruments, de la song,
;	des patterns et de tous les instruments
;-----------------------------------------------------------------------------
prepare_module:
	movem.l	d0-a6,-(sp)

	lea	module_inf1,a1
	lea	module_inf2,a5
	move.l	adr_module(a1),a0

	move.w	$c8(a0),d0		; d0 = nbr de voies
	move.w	d0,nbrvoies
	move.w	d0,mod_nbrtrack(a5)
	move.w	$ca(a0),mod_songlen(a5)
	move.w	$cc(a0),mod_songrep(a5)

	lea	repeatbuffer,a6
	move.w	#255,d0
.eff	clr.l	(a6)+		; Pour le sample 0, on met du vide
	dbra	d0,.eff
	move.w	$c4(a0),d1		; d1 = nbr d'instr
	tst.w	d1
	beq.s	prepa_pas_instr
prepa_mod_loop4:
	move.w	d1,-(sp)
	bsr	boucle_instrument	; Bouclage
	addq.l	#2,sp
	subq.w	#1,d1
	bne.s	prepa_mod_loop4
prepa_pas_instr:

	lea	module_inf1,a1
	lea	info_track,a4
	lea	new_note_buffer(pc),a6
	moveq	#0,d1		; La balance courante
	move.w	#$fff,d2		; Le flag de changement de balance
	moveq	#NBRVOIES_MAXI-1,d0
prepa_mod_loop3:
	move.w	#1,onoff_t(a4)
	move.w	#1,nbits_t(a4)
	move.w	#8363,fech_t(a4)
	clr.w	vol_t(a4)
	move.w	d1,bal_t(a4)
	move.w	d1,curbal_t(a4)
	eor.w	d2,d1		; Change la balance quand d2=$fff : L R R L L R R L ...
	eor.w	#$fff,d2		; Le flag est … $fff une fois sur deux
	move.w	#$6b00,per_t(a4)
	move.l	#sample_vide,adrsam_t(a4)
	clr.l	pos_t(a4)
	clr.w	finepos_t(a4)
	clr.l	reppos_t(a4)
	move.l	#2,replen_t(a4)
	move.l	#repeatbuffer,rbuffer_t(a4)
	clr.w	interpol_t(a4)
	clr.w	c_n_t(a4)
	clr.w	c_i_t(a4)
	clr.w	c_e_t(a4)
	clr.w	c_v_t(a4)
	move.w	#0,ninstr_t(a4)
	clr.w	norm_f_t(a4)
	clr.w	norm_v_t(a4)
	move.w	#24,curnote_t(a4)
	move.w	#$6b00,pernote_t(a4)
	clr.w	vollnot_t(a4)
	clr.w	volenot_t(a4)
	clr.w	portspd_t(a4)
	clr.w	tportspd_t(a4)
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
	move.b	#3,rollspd_t(a4)
	clr.b	rollcpt_t(a4)
	clr.w	rollnbr_t(a4)
	clr.w	delay_t(a4)
	clr.w	cut_del_t(a4)
	clr.w	tremorc_t(a4)
	move.b	#3,tremor1_t(a4)
	move.b	#6,tremor2_t(a4)
	clr.w	ploopp_t(a4)
	clr.w	ploops_t(a4)
	clr.w	ploopn_t(a4)
	clr.w	instr_t(a4)
	clr.w	transp_t(a4)
	move.w	#$100,volsam_t(a4)
	env_initialisation	a4,0
	clr.w	flag_autotempo_t(a4)
	clr.w	flag_autoperiod_t(a4)
	move.w	#$1000,mix_volume_t(a4)
	move.w	#$C00,mix_volume_e_t(a4)
	clr.w	ltvolslspd_t(a4)
	clr.w	etvolslspd_t(a4)
	clr.w	fetvolslspd_t(a4)
	clr.b	(a6)		; Le buffer de nouvelle note
	add.w	#next_t,a4
	addq.w	#6,a6
	dbra	d0,prepa_mod_loop3

	clr.w	current_track
	clr.w	dsp_plein
	clr.w	mod_songpos(a5)
	clr.w	mod_numpat(a5)
	clr.w	mod_linepos(a5)
	clr.w	mod_patrep(a5)
	move.w	#125,mod_tempo(a5)
	move.w	#6,mod_speed(a5)
	move.w	#-1,mod_nbrvbl(a5)
	move.l	#$3000,d0
	move.w	mod_nbrtrack(a5),d1
	addq.w	#4,d1
	divu.w	d1,d0
	move.w	d0,master_vol
	moveq	#0,d0
	move.w	replay_frequency,d0
	divu.w	#125*4*6/60,d0
	move.w	d0,vblsize
	move.w	d0,vblcurrentsize
	clr.w	d0
	divu.w	#125*4*6/60,d0
	move.w	d0,vblsize_frac
	clr.w	vblcurrentsize_frac
	move.w	#1,vblnumber
	clr.w	vblcpt
	clr.w	flag_stop_voices
	clr.w	flag_mt_display
	clr.w	flag_new_notes
	clr.w	flag_overflow
	clr.w	cpu_time_pourcent
	clr.w	current_play_mode
	clr.w	current_edit_mode
	clr.w	midi_in_on
	clr.w	midi_in_gfa_playline
	move.w	#-1,midi_current_status
	move.w	#-1,midi_old_status
	clr.w	midi_in_sync_flag
	clr.w	midi_in_sync_cpt
	clr.w	songrecord_flag

	lea	midi_in_noteoff_flag(pc),a2
	moveq	#MIDI_NBR_CHANNELS-1,d0
.loop1:	move.w	#-1,(a2)+
	dbra	d0,.loop1

	lea	midi_in_velo_flag(pc),a2
	moveq	#MIDI_NBR_CHANNELS-1,d0
.loop2:	move.w	#-1,(a2)+
	dbra	d0,.loop2

	lea	midi_instr_map(pc),a2
	moveq	#MIDI_NBR_CHANNELS-1,d0
.loop3:	move.w	#1,(a2)+
	dbra	d0,.loop3

	bsr	gestion_partition

	movem.l	(sp)+,d0-a6
	rts



;-----------------------------------------------------------------------------
;	Bouclage d'un instrument
;	Fournir en 4(sp).w le num‚ro de l'instrument … boucler
;	Modifie d0
;-----------------------------------------------------------------------------
boucle_instrument:
	moveq	#0,d0
	move.w	4(sp),d0
	movem.l	d1-a6,-(sp)
	lea	module_inf1,a1
	move.l	(a1,d0.w*4),a1
	lea	repeat_s(a1),a3
	lea	data_s(a1),a1	; a1 pointe sur le sample
	lea	repeatbuffer,a6
	swap	d0
	lsr.l	#6,d0
	add.l	d0,a6
	move.w	#512,d1
.loop1:	move.l	a1,a2
	add.l	(a3),a2		; a2 pointe sur le d‚but de la boucle
	move.l	replen_s-repeat_s(a3),d2	; d2 = replen
	lsr.l	#1,d2
	subq.l	#1,d2
	tst.l	d2
	bne.s	.loop2
	tst.l	(a3)
	bne.s	.loop2

	cmp.w	#16,nbits_s-repeat_s(a3)
	beq.s	.bouc16b
.bouc8b:	move.w	#1023,d1		; Pas bouclage 8 bits
	add.l	length_s-repeat_s(a3),a2
	subq.l	#1,a2
.loop3:	move.b	(a2),(a6)+
	dbra	d1,.loop3
	bra.s	.fini
.bouc16b:	subq.w	#1,d1		; Pas de bouclage 16 bits
	add.l	length_s-repeat_s(a3),a2
	subq.l	#2,a2
.loop4:	move.w	(a2),(a6)+
	dbra	d1,.loop4
	bra.s	.fini

.loop2:	move.w	(a2)+,(a6)+	; Bouclage normal
	subq.w	#1,d1
	beq.s	.fini
	subq.l	#1,d2
	bpl.s	.loop2
	bra.s	.loop1

.fini:	movem.l	(sp)+,d1-a6
	rts



;-----------------------------------------------------------------------------
;	Joue un sample
;	d0 = num‚ro de voie (0-31)
;	a0 = adresse.l du bloc de description de la voie.
;	Num‚ro de la note … la place de la p‚riode
;-----------------------------------------------------------------------------
play_one_sample:
	movem.l	a1-a2,-(sp)
	lea	info_track,a1
	mulu.w	#next_t,d0
	add.l	d0,a1		; a1 pointe sur les infos de la voie
	lea	per_table(pc),a2
	move.w	per_t(a0),d0	; Prend la note
	sub.w	#24,d0
	lsl.w	#4,d0
	move.w	(a2,d0.w),per_t(a1)	; Envoie la p‚riode
	move.w	(a2,d0.w),pernote_t(a1)	; Pour la partition
	move.w	#1,onoff_t(a1)
	move.w	nbits_t(a0),nbits_t(a1)
	move.w	fech_t(a0),fech_t(a1)
	move.w	vol_t(a0),vol_t(a1)
	move.w	vol_t(a0),vollnot_t(a1)
	move.l	adrsam_t(a0),adrsam_t(a1)
	move.l	reppos_t(a0),reppos_t(a1)
	move.l	replen_t(a0),replen_t(a1)
	move.l	rbuffer_t(a0),rbuffer_t(a1)
	clr.l	pos_t(a1)
	clr.w	finepos_t(a1)
	move.l	a1,d0		; Renvoie dans d0 l'adresse du descripteur de piste
	movem.l	(sp)+,a1-a2
	rts



;-----------------------------------------------------------------------------
;	Joue une note d'un instrument.
;	Stoque en fait la note dans un buffer qui sera scann‚ lors du
;	d‚codage de la prochaine ligne.
;	a0 = adresse de la note
;	d0 = num‚ro.w de la voie
;-----------------------------------------------------------------------------
play_one_note:
	movem.l	d0-d1/a1,-(sp)
	move.w	d0,d1		; d0 = d0 * 6
	add.w	d0,d0		;
	add.w	d1,d0		;
	add.w	d0,d0		;
	lea	new_note_buffer(pc),a1
	move.l	(a0),1(a1,d0.w)	; Copie la note
	move.b	4(a0),5(a1,d0.w)
	move.b	#1,(a1,d0.w)	; Mise en place du flag
	movem.l	(sp)+,d0-d1/a1
	rts



;-----------------------------------------------------------------------------
;	Routine d'enregistrement d'un module sous forme des sample,
;	sans utiliser l'interruption.
;-----------------------------------------------------------------------------
songrecord_routine_no_realtime:
	movem.l	d0-d1/a0,-(sp)

	move.w	songrecord_state(pc),d0
	cmp.w	#4,d0		; Teste si on est bien en enregistrement
	beq.s	.rec_end

.waitloop:	tst.w	songrecord_flag2	; Attend qu'on ait fini le mixage
	beq.s	.waitloop

	move.l	songrecord_startadr,a0
	readhost

	move.l	DSPHRDR_L.w,d0	; d0 = nombre de paquets … recevoir (2 x 24 bits)
	swap	d0
	clr.w	d0
	swap	d0
	move.l	d0,d1
	add.l	d1,d1		; => en samples
	add.l	d1,d1		; => en octets
	move.l	d1,songrecord_bufpos	; Ca donne la position finale
	beq.s	.rec_loop_end
	subq.w	#1,d0

.rec_loop:
	readhost			; Sample de gauche
	move.l	DSPHRDR_L.w,d1
	lsr.l	#8,d1		; 24 -> 16 bits
	move.w	d1,(a0)+

	readhost			; Sample de droite
	move.l	DSPHRDR_L.w,d1
	lsr.l	#8,d1		; 24 -> 16 bits
	move.w	d1,(a0)+

	dbra	d0,.rec_loop
.rec_loop_end

	move.w	sr,-(sp)
	or	#$2700,sr

	IfNE	INTERRUPTION_TYPE=0
	move.b	#1,DSPHCR.w	; R‚autorise l'interruption
	EndC
	IfNE	INTERRUPTION_TYPE=1
	bset	#5,MFPIMRA.w	; Timer A d‚masqu‚
	EndC
	IfNE	INTERRUPTION_TYPE=2
	bset	#5,MFPIMRB.w	; Timer C d‚masqu‚
	EndC
	IfNE	INTERRUPTION_TYPE=3
	bset	#4,MFPIMRB.w	; Timer D d‚masqu‚
	EndC

	writhost			; Donne le signal de reprise
	move.l	#0,DSPHTDR_L.w

	move	(sp)+,sr

.rec_end:
	movem.l	(sp)+,d0-d1/a0
	rts



;-----------------------------------------------------------------------------
;	Routine ex‚cut‚e sur l'interruption DSP juste avant le noyau.
;	Met en route le DMA pour l'enregistrement d'un module sous
;	forme de sample.
;	Arrˆte ensuite le DMA et remet le vecteur … sa place
;-----------------------------------------------------------------------------
songrecord_routine:
	movem.l	d0-a6,-(sp)
	and.w	#%1111100011111111,sr	; Autorise toutes les interruptions
	tst.w	current_track(pc)	; PremiŠre voie ?
	bne	sngrec_end		; Non, c'est pas la peine de rester

	tst.w	songrecord_state(pc)	; 0 - On a pas encore commenc‚ … enregistrer ?
	beq.s	sngrec_state0
	cmp.w	#1,songrecord_state	; 1 - On doit commencer maintenant ?
	beq	sngrec_state1
	cmp.w	#2,songrecord_state	; 2 - Attente de la fin de l'enregistrement ?
	beq	sngrec_state2
	bra	sngrec_state3	; 3 - Coupe l'enregistrement.

;--- Attend l'endroit o— on doit commencer -----------------------------------
sngrec_state0:
	move.w	songrecord_startpos(pc),d0
	cmp.w	module_inf2+mod_cursongpos,d0
	bne	sngrec_end		; Pas encore la bonne position
	move.w	songrecord_startline(pc),d0
	cmp.w	module_inf2+mod_curlinepos,d0
	bne	sngrec_end		; Pas encore la bonne ligne
	cmp.w	#NBRPATTERNS_MAXI-NBRPATTERNS_VIDES-1,module_inf2+mod_numpat
	bgt	sngrec_end		; Si on est encore dans les patterns vides
	move.w	module_inf2+mod_nbrvbl,d0
	cmp.w	module_inf2+mod_speed,d0
	bge	sngrec_end		; Si c'‚tait la fin du mode Stop

	move.w	replay_frequency(pc),songrecord_srecfreq	; Sauve l'ancienne fr‚quence
	move.w	songrecord_recfreq(pc),replay_frequency	; Fixe la fr‚quence d'‚chantillonnage

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Recalcule les valeurs de samples/frame
	move.w	module_inf2+mod_tempo,d0
	mulu.w	#4*6,d0
	move.w	replay_frequency(pc),d1
	mulu.w	#60,d1
	divu.w	d0,d1		; d1 = freq.repl * 60 s / (tempo * 4 lig * 6 ticks)
	move.l	d1,d3		;    = nombre de spl par tick
	clr.w	d3
	divu.w	d0,d3		; d3 = nbr de spl par tick, frac
	swap	d3
	move.w	d1,d3
	swap	d3		; d3 = nbr de spl par tick * $10000
	move.l	#1200-1,d0
	add.w	d1,d0
	divu.w	#1200,d0		; d0 = splpartick/1200 arrondi par excŠs
	ext.l	d0
	divu.l	d0,d3		; d3 = Nbr de spl par VBL * $10000
	move.l	d3,vblsize		; Stoque d'un coup les parties entiŠre et fractionnaire
	move.w	d0,vblnumber
	clr.w	d3
	move.l	d3,vblcurrentsize

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	tst.w	songrecord_realtime(pc)
	bne.s	.realtime

	readhost
	move.w	DSPHRDR_W.w,d0	; R‚cupŠre la commande ‚mise par le dsp (mˆme pas en fait)
	writhost
	move.l	#1<<6,DSPHTDR_L.w	; Passage en mode pas … pas
	readhost			; Attend un nouvel appel du DSP
	move.w	#1,songrecord_flag
	clr.w	songrecord_flag2
	move.w	#2,songrecord_state	; On est maintenant en enregistrement
	bra	sngrec_end

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.realtime:
	move.w	#1,songrecord_state	; Attend encore une frame … cause
	bra	sngrec_end		; du double buffer du DSP

;--- Commence l'enregistrement -----------------------------------------------
sngrec_state1:
	tst.w	songrecord_realtime(pc)
	beq.s	.stat1end
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Fixe l'adresse du buffer
	move.l	songrecord_endadr,-(sp)
	move.l	songrecord_startadr,-(sp)
	move.w	#1,-(sp)		; Pr‚cise que c'est pour l'‚criture
	move.w	#$83,-(sp)		; Setbuffer
	trap	#14
	lea	12(sp),sp

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Connecte la sortie DSP … l'enregistrement DMA
	move.w	$ffff8934.w,songrecord_sprediv	; Sauve l'ancienne pr‚division
	move.w	#1,-(sp)		; Sortie DSP
	move.w	#%0001,-(sp)	; Enregistrement DMA
	clr.w	-(sp)		; Horloge interne 25.175 MHz
	move.w	#1,-(sp)		; Pr‚division
	move.w	#1,-(sp)		; Handshake
	move.w	#$8b,-(sp)		; Devconnect
	trap	#14
	lea	12(sp),sp
	move.b	songrecord_prediv+1(pc),$ffff8934+1.w

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Commence l'enregistrement
	move.w	#%1100,-(sp)	; Enregistrement avec bouclage
	move.w	#$88,-(sp)		; Buffoper
	trap	#14
	addq.l	#4,sp

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.stat1end:	move.w	#2,songrecord_state	; On passe en phase d'attente de la fin
	bra	sngrec_state2	; Teste maintenant si c'est la fin

;--- Attend la fin de l'enregistrement ---------------------------------------
sngrec_state2:
	move.w	songrecord_endpos(pc),d0
	cmp.w	module_inf2+mod_cursongpos,d0
	bne	sngrec_end		; Pas encore la bonne position
	move.w	songrecord_endline(pc),d0
	cmp.w	module_inf2+mod_curlinepos,d0
	bne	sngrec_end		; Pas encore la bonne ligne
	tst.w	songrecord_realtime(pc)
	beq.s	sngrec_restore

	move.w	#3,songrecord_state	; Attend encore une frame … cause
	bra	sngrec_end		; du double buffer du DSP

;--- Arrˆte maintenant l'enregistrement --------------------------------------
sngrec_state3:
	tst.w	songrecord_realtime(pc)
	beq.s	sngrec_restore

; R‚cupŠre l'adresse de la derniŠre position d'enregistrement
	move.b	$ffff8901.w,d0	; S‚lectionne le registre d'enregistrement
	bset	#7,d0
	move.b	d0,$ffff8901.w
	moveq	#0,d0
	move.b	$ffff8909.w,d0	; On le lit
	swap	d0
	move.b	$ffff890b.w,d0
	lsl.w	#8,d0
	move.b	$ffff890d.w,d0
	move.l	d0,songrecord_lastadr

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Arrˆte le DMA
	move.w	#%0000,-(sp)	; Stop
	move.w	#$88,-(sp)		; Buffoper
	trap	#14
	addq.l	#4,sp

	move.w	songrecord_sprediv(pc),$ffff8934.w	; Restaure l'ancienne pr‚division

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Recalcule les valeurs de samples/frame
sngrec_restore:
	move.w	songrecord_srecfreq(pc),replay_frequency	; Restaure l'ancienne fr‚quence
	move.w	module_inf2+mod_tempo,d0
	mulu.w	#4*6,d0
	move.w	replay_frequency(pc),d1
	mulu.w	#60,d1
	divu.w	d0,d1		; d1 = freq.repl * 60 s / (tempo * 4 lig * 6 ticks)
	move.l	d1,d3		;    = nombre de spl par tick
	clr.w	d3
	divu.w	d0,d3		; d3 = nbr de spl par tick, frac
	swap	d3
	move.w	d1,d3
	swap	d3		; d3 = nbr de spl par tick * $10000
	move.l	#1200-1,d0
	add.w	d1,d0
	divu.w	#1200,d0		; d0 = splpartick/1200 arrondi par excŠs
	ext.l	d0
	divu.l	d0,d3		; d1 = Nbr de spl par VBL * $10000
	move.l	d3,vblsize		; Stoque d'un coup les parties entiŠre et fractionnaire
	move.w	d0,vblnumber
	clr.w	d3
	move.l	d3,vblcurrentsize

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Signale que c'est termin‚
	clr.w	songrecord_flag
	move.w	#4,songrecord_state
	IfNE	INTERRUPTION_TYPE=0
	move.l	#soundtracking_kernel,DSP_EXCEPTION*4.w
	Else
	move.l	#soundtracking_kernel,adresse_interruption
	EndC

	tst.w	songrecord_realtime(pc)
	bne.s	.sngresend
	readhost
	move.l	DSPHRDR_L.w,d0	; Mot de commande du DSP gob‚
	writhost
	move.l	#1<<7,DSPHTDR_L.w	; Signale au DSP qu'il peut reprendre normalement
.sngresend:

sngrec_end:
	movem.l	(sp)+,d0-a6
	bra	soundtracking_kernel





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Noyau de la routine de soundtrack, envoie les samples au DSP.	*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Cette routine doit ˆtre plac‚e sur l'interruption DSP		*
*	Les samples sont sign‚s. Toutes les informations (rep, pos...)	*
*	sont donn‚es en octets. Un sample non boucl‚ doit avoir un	*
*	replen … 2 et reppos = longueur - 2. Tout sample doit avoir	*
*	un buffer de bouclage.				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
soundtracking_kernel:

	movem.l	d0-a6,-(sp)

	tst.w	flag_mt_display(pc)
	beq.s	.finsi
	move.l	#FC_RED,FCOLOR00.w	; Le rouge montre le temps machine utilis‚ par la routine
.finsi:

	readhost
	move.w	DSPHRDR_W.w,d0	; R‚cupŠre le temps machine donn‚ par le DSP
	cmp.w	#255,d0
	bne.s	.nooverld
	move.w	#1,flag_overflow
.nooverld:	move.w	d0,cpu_time_pourcent

	tst.w	flag_the_end	; On doit tout arrˆter ?
	beq.s	sendsam_nostop
	move.b	#0,DSPHCR.w	; Plus d'interruption DSP Host
	writhost
	move.l	#1<<3,DSPHTDR_L.w	; Arrˆt de la routine DSP
	tst.w	flag_mt_display(pc)
	beq.s	.stop_timer
	clr.l	FCOLOR00.w		; Nuit !
.stop_timer:
	IfNE	INTERRUPTION_TYPE=1	; Arret du Timer A s'il ‚tait l…
	bclr	#5,MFPIMRA.w	; Timer A masqu‚
	bclr	#5,MFPIERA.w	; Timer A annul‚
	move.l	sauvegarde_timer,MFPST_INT_TIMERA.w
	EndC
	IfNE	INTERRUPTION_TYPE=2	; Arret du Timer C
	bclr	#5,MFPIMRB.w	; Timer C masqu‚
	bclr	#5,MFPIERB.w	; Timer C annul‚
	move.l	sauvegarde_timer,MFPST_INT_TIMERC.w
	EndC
	IfNE	INTERRUPTION_TYPE=3	; Arret du Timer D s'il ‚tait l…
	bclr	#4,MFPIMRB.w	; Timer D masqu‚
	bclr	#4,MFPIERB.w	; Timer D annul‚
	move.l	sauvegarde_timer,MFPST_INT_TIMERD.w
	EndC
	bra	sendsam_the_end

sendsam_nostop:
	lea	info_track,a0	; a0 pointe sur le tableau d'infos des voies
	move.w	current_track(pc),d0	; d0 = voie courante
	bne.s	.ok
	writhost			; Si c'est la premiŠre voie : on indique
	move.l	#1<<5,DSPHTDR_L.w	; le nombre de samples par tick (d‚pend
	moveq	#0,d1		; du tempo)
	move.w	vblcurrentsize(pc),d1
	writhost
	move.l	d1,DSPHTDR_L.w
.ok:	move.w	nbrvoies(pc),d1	; d1 = nbr de voies
	move.w	d0,d2
	mulu.w	#next_t,d2
	add.w	d2,a0		; Mise … jour du pointeur sur la voie courante
sendsam_tsttrkloop:
	cmp.w	d0,d1		; C'‚tait la derniŠre voie ?
	beq	sendsam_apuvoi
	tst.w	onoff_t(a0)	; Voie active ?
	beq	sendsam_tsttrknxt
	cmp.l	#2,replen_t(a0)	; Sample non boucl‚ ? *** Gagne du temps machine, mais
	bgt.s	.suite		;                     *** provoque un petit bruit … la
	tst.l	reppos_t(a0)	; Sample vide ?
	beq	sendsam_tsttrknxt
	move.l	pos_t(a0),d3	; Si non, la fin ?    *** fin des samples dont la
	cmp.l	reppos_t(a0),d3	;                     *** courbe ne revient pas … 0
	bge.s	sendsam_cst	;                     *** (mettre ces lignes en commentaires)
.suite:	tst.w	vol_t(a0)		; Volume … 0 ?
	bne	sendsam_voieon	; Non, on envoie le sample
	moveq	#0,d5		; Oui, on fait avancer la position
	move.w	per_t(a0),d5
	mulu.w	replay_frequency,d5	; d5 = Per(note) * Freplay
	move.l	#$1ac00000,d2	; d2 = Per(C2) * $10000
	moveq	#0,d4
	move.w	fech_t(a0),d4
	mulu.l	d4,d3:d2
	divu.l	d5,d3:d2		; d2 = $10000 * Fech(C2) * Per(C2) / Per(note) / Freplay
	moveq	#0,d5
	move.w	vblcurrentsize(pc),d5
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
	move.l	#1<<4,DSPHTDR_L.w	; Bit 4 : spl cst
	move.w	vol_t(a0),d4
	mulu.w	master_vol,d4	; On multiplie par le master
	writhost
	move.l	d4,DSPHTDR_L.w	; Volume
	move.w	bal_t(a0),d4	; Envoie la balance
	lsl.w	#3,d4
	lsl.l	#8,d4
	writhost
	move.l	d4,DSPHTDR_L.w
	moveq	#0,d4
	move.l	rbuffer_t(a0),a1	; Cherche le sample constant
	move.w	(a1),d4		; a1 sur le premier octet du buffer de r‚p‚tition
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
	subq.l	#2,d1		; Sinon, pos = reppos+replen-2
	move.l	d1,pos_t(a0)
.finsi1:	lea	DSPHTDR_L.w,a2	; *** Penser … optimiser avec ces registres
	lea	DSPHTDR_W.w,a3	; *** en enlevant les macros
	lea	DSPHSR.w,a4	; *** ISR
	writhost
	move.l	#1,DSPHTDR_L.w	; Bit 1 : voie on

	move.w	vol_t(a0),d1	; d1 = volume
	mulu.w	master_vol,d1	; On multiplie par le master
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
	mulu.w	replay_frequency,d1	; d1 = Per(note) * Freplay
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

	move.w	vblcurrentsize(pc),d1
	mulu.l	d2,d1		; d1 = nbr d'‚chantillons … envoyer en 1 VBL * 65536
	add.w	d1,finepos_t(a0)
	bcc.s	.nocarry
	add.l	#$10000,d1
.nocarry:	clr.w	d1
	swap	d1
	cmp.w	#2,nbits_t(a0)
	beq	sendsam_16bits	; Si c'est du 16 bits



;--- Envoi de samples 8 bits -------------------------------------------------
sendsam_8bits:
	writhost
	move.l	#1,DSPHTDR_L.w
	addq.l	#1+1,d1		; *** Dernier sample … mixer : en envoyer 1 de plus
				; *** car le nbr est d‚cimal (arrondit par d‚faut)
				; *** Plus 1 pour l'interpolation
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
	jmp	sendsam_8loopt2(pc,d3.w*2)
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
	jmp	sendsam_8loopt3(pc,d4.w*2)
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
	jmp	sendsam_8loopt1(pc,d4.w*2)
sendsam_8loopt1:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d2,sendsam_8loopt1
	move.l	d6,pos_t(a0)	; Nouvelle position
	bra	sendsam_next



;--- Envoi de samples 16 bits ------------------------------------------------
sendsam_16bits:
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
	jmp	sendsam_16loopt2(pc,d3.w*2)
sendsam_16loopt2:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d4,sendsam_16loopt2
	tst.l	d2
	bne.s	sendsam_16boucle
	move.l	reppos_t(a0),d1	; Si on s'arrŠte pile-poil … la fin
	add.l	replen_t(a0),d1
	subq.l	#2+2,d1		; *** EnlŠve le sample de s‚curit‚ + interp.
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
	jmp	sendsam_16loopt3(pc,d4.w*2)
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
	subq.l	#2+2,d5		; *** EnlŠve le sample de s‚curit‚ + interp.
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
	jmp	sendsam_16loopt1(pc,d4.w*2)
sendsam_16loopt1:
	REPT	16
	move.w	(a1)+,(a3)
	ENDR
	dbra	d2,sendsam_16loopt1
	subq.l	#2+2,d3		; *** EnlŠve le sample suppl‚mentaire + interp.
	move.l	d3,pos_t(a0)	; Nouvelle position
	bra	sendsam_next



;--- R‚‚chantillonnage au 030 (mais mixage DSP) ------------------------------
sendsam_030:			; d2 contient l'incr‚ment entier.frac
	writhost			; d1 contient l'incr‚ment 0.entier
	move.l	#$800000,DSPHTDR_L.w
	move.l	pos_t(a0),d3	; d3 = position.l, partie entiŠre
	move.w	finepos_t(a0),d4	; d4 = position.w, partie fractionnaire
	moveq	#0,d5
	move.w	vblcurrentsize(pc),d5	; d5 = nombre.w d'‚chantillons … envoyer
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
	IFNE	DSP_WAIT
	nop
	ENDC
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
	IFNE	DSP_WAIT
	nop
	ENDC
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
	st	dsp_plein		; C'est bon, on a rempli le buffer du DSP
	tst.w	flag_mt_display(pc)
	beq.s	.finsi
	move.l	#FC_BLUE,FCOLOR00.w	; Bleu, le dsp est occup‚
.finsi	addq.w	#1,d0		; Voie suivante
	bra.s	sendsam_encore

sendsam_apuvoi:
	tst.w	songrecord_flag(pc)	; Regarde si on est en enregistrement
	beq.s	.finsi4		; sans temps r‚el et qu'on doit
	cmp.w	#2,songrecord_state	; ‚liminer les interruptions pour
	bne.s	.finsi4		; faire un dump du buffer DSP

	IfNE	INTERRUPTION_TYPE=0
	move.b	#0,DSPHCR.w	; Interdit l'interruption
	EndC
	IfNE	INTERRUPTION_TYPE=1	; Arret du Timer A s'il ‚tait l…
	bclr	#5,MFPIMRA.w	; Timer A masqu‚
	EndC
	IfNE	INTERRUPTION_TYPE=2	; Arret du Timer C
	bclr	#5,MFPIMRB.w	; Timer C masqu‚
	EndC
	IfNE	INTERRUPTION_TYPE=3	; Arret du Timer D s'il ‚tait l…
	bclr	#4,MFPIMRB.w	; Timer D masqu‚
	EndC
	move.w	#1,songrecord_flag2

.finsi4:
	moveq	#0,d0		; On recommencera la prochaine fois … la voie 0
	moveq	#1<<1,d1		; Si les deux canaux sont utilis‚s, fin normale
	tst.w	dsp_plein
	bne.s	.finsi
	moveq	#1<<2,d1		; Si rien n'a ‚t‚ envoy‚, on vide les buffers du DSP
.finsi:	writhost
	move.l	d1,DSPHTDR_L.w	; Plus de voie … mixer
	clr.w	dsp_plein		; On remet … 0 l'indicateurs
	tst.w	flag_mt_display(pc)
	beq.s	.finsi2
	move.l	#FC_GREEN,FCOLOR00.w	; Vert : gestion de partition
.finsi2:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Peuvent ˆtre plac‚es ici des routines de contr“le des samples
	IfNE	MIDI_IN
	tst.w	midi_in_on(pc)
	beq.s	.no_midi_in
	bsr	gestion_midi	; Teste le port Midi In
.no_midi_in:
	EndC

	bsr	gestion_partition	; Pr‚pare les samples pour la prochaine fois

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	tst.w	flag_mt_display(pc)
	beq.s	.finsi3
	clr.l	FCOLOR00.w		; Noir, c'est fini pour la vbl
.finsi3:

sendsam_encore:
	move.w	d0,current_track

sendsam_the_end:
	movem.l	(sp)+,d0-a6
	IfNE	INTERRUPTION_TYPE=1
	bclr	#5,MFPISRA.w	; Et signale la fin de l'interruption
	EndC
	IfNE	INTERRUPTION_TYPE=2
	bclr	#5,MFPISRB.w
	EndC
	IfNE	INTERRUPTION_TYPE=3
	bclr	#4,MFPISRB.w
	EndC
	rte





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Gestion de la partition pour modules .GTK			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Cette routine est appel‚e sous interruption, par l'interm‚diaire	*
*	du noyau.						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gestion_partition:

	movem.l	d0-a6,-(sp)

	addq.w	#1,vblcpt		; Compteur de VBL pour faire un tick
	move.w	vblnumber(pc),d0
	cmp.w	vblcpt(pc),d0
	bgt	fin_gestion_partition	; Tick pas fini : rien … faire
	clr.w	vblcpt

	lea	module_inf2,a0	; a0 pointe sur le bloc 2 d'informations (mod)
	lea	module_inf1,a1	; a1 pointe sur le bloc 1 d'informations (adr)
	lea	per_table(pc),a5	; a5 pointe sur la table des p‚riodes

	move.w	mod_nbrtrack(a0),nbrvoies	; *** Pour que nbr de voies DSP = nbr de voies soundtrack

;--- Demande d'arrˆt de toutes les voies ? -----------------------------------

	tst.w	flag_stop_voices(pc)
	beq	gp_new_vbl
	moveq	#NBRVOIES_MAXI-1,d0
	lea	info_track(pc),a4
	lea	sample_vide,a2
.loop:
	clr.w	vol_t(a4)
	move.l	a2,adrsam_t(a4)
	clr.l	pos_t(a4)
	clr.w	finepos_t(a4)
	clr.l	reppos_t(a4)
	move.l	#2,replen_t(a4)
	move.l	#repeatbuffer,rbuffer_t(a4)
	clr.w	c_n_t(a4)
	clr.w	c_i_t(a4)
	clr.w	c_e_t(a4)
	clr.w	c_v_t(a4)
	move.w	#0,ninstr_t(a4)
	clr.w	norm_f_t(a4)
	clr.w	norm_v_t(a4)
	move.w	#$100,volsam_t(a4)
	move.w	#24,curnote_t(a4)
	move.w	#$6b00,pernote_t(a4)
	clr.w	vollnot_t(a4)
	clr.w	volenot_t(a4)
	clr.w	portspd_t(a4)
	clr.w	tportspd_t(a4)
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
	clr.w	instr_t(a4)
	clr.w	transp_t(a4)
	env_initialisation	a4,0
	clr.w	flag_autotempo_t(a4)
	clr.w	flag_autoperiod_t(a4)
	add.w	#next_t,a4
	dbra	d0,.loop
	clr.w	flag_stop_voices

;--- Nouvelle VBL, teste si on a une nouvelle ligne, position etc... ---------

gp_new_vbl:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Si on est en mode Syncro Externe, on regarde si on peut lancer une VBL (ou
; plusieurs si on est en retard).
	IfNE	MIDI_IN

	tst.w	midi_in_on(pc)
	beq.s	gp_new_vbl_ok
	tst.w	midi_in_sync_flag(pc)
	beq.s	gp_new_vbl_ok
	tst.w	current_play_mode(pc)
	beq.s	gp_new_vbl_ok
gp_new_vbl_loop:
	tst.w	midi_in_sync_cpt(pc)
	ble	fin_gestion_partition
	subq.w	#1,midi_in_sync_cpt
gp_new_vbl_ok:

	EndC
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

	move.w	mod_nbrvbl(a0),d0	; Nouvelle vbl
	addq.w	#1,d0
	cmp.w	mod_speed(a0),d0	; Fin de la ligne courante ?
	blt	.suite_ligne
	moveq	#0,d0
	tst.w	mod_patrep(a0)	; R‚p‚tition de la ligne ?
	beq.s	.newline		; Non, on s'en fout

	subq.w	#1,mod_patrep(a0)	; R‚p‚tition -1
	move.w	d0,mod_nbrvbl(a0)
	lea	info_track,a3	; On initialise quelques trucs...
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie
	bra	pas_seulement_1ere_vbl	; ... puis on passe … la suite

.newline:	move.w	mod_songpos(a0),mod_cursongpos(a0)	; Actualise la position
	move.w	mod_linepos(a0),mod_curlinepos(a0)
	clr.w	mod_flagnewpos(a0)	; Indique que les positions et lignes restent les mˆmes
	clr.w	mod_flagnewline(a0)	; pour le moment (sert aux effets 0Bxx et 0Dxx)
	move.w	mod_numpat(a0),d3	; Met dans chaque descripteur de voie une partie de la ligne
	move.l	(adr_pattern,a1,d3.w*4),a4	; a4 pointe sur le chunk du pattern
	move.w	mod_linepos(a0),d1
	move.w	mod_nbrtrack(a0),d3
	mulu.w	#5,d3
	mulu.w	d1,d3
	lea	data_p(a4,d3.l),a2	; a2 contient l'adresse de la nouvelle ligne
	lea	info_track,a3	; a3 pointe sur le descripteur de voies
	move.w	mod_nbrtrack(a0),d3
	subq.w	#1,d3		; d3 contient le nombre de voies -1
.loop:	move.b	(a2)+,c_n_t+1(a3)	; Recopie la note
	move.b	(a2)+,c_i_t+1(a3)	; Recopie l'instrument
	move.w	(a2)+,c_e_t(a3)	; Recopie l'effet
	move.b	(a2)+,c_v_t+1(a3)	; Recopie la commande de volume
	move.w	#1,flag_new_note_t(a3)	; La note est nouvelle
	add.w	#next_t,a3		; Voie suivante
	dbra	d3,.loop

	addq.w	#1,d1		; Calcule la prochaine ligne
	cmp.w	nlines_p(a4),d1	; Fin du pattern ?
	blt.s	.suite_pos
	moveq	#0,d1
	move.w	mod_songpos(a0),d2	; Nouvelle position
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
	move.w	d0,mod_nbrvbl(a0)

;--- Passe aux crible toutes les voies ---------------------------------------

	bsr	additional_notes	; * Modifie d3, a2, a3, ‚ventuellement d2, a4 et le pattern
	lea	info_track,a3	; a3 pointe sur les informations des voies
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie
	tst.w	flag_new_notes(pc)
	bne.s	premiere_vbl	; Si on a des notes qui arrivent en cours de route
	tst.w	d0		; C'est la premiŠre VBL ?
	bne	pas_seulement_1ere_vbl
	tst.w	mod_patrep(a0)	; Sinon, c'est en cours de r‚p‚tition ?
	bne	pas_seulement_1ere_vbl

;--- D‚code les diff‚rentes parties d'une ligne -----------------------------

premiere_vbl:
	clr.w	flag_new_notes	; Au cas o— on aurait eu des notes supl‚mentaire
premvbl_loop:			; Boucle de test si c'est la premiŠre vbl
	tst.w	flag_new_note_t(a3)	; Nouvelle note?
	beq	prmvbl_next_track	; Non, on teste la suivante
	clr.w	flag_new_note_t(a3)
	move.w	c_n_t(a3),d0	; d0 = note
	move.w	c_i_t(a3),d1	; d1 = instrument
	move.w	c_e_t(a3),d2	; d2 = effet

	tst.w	d1
	bne.s	instrum		; S'il y a instrument
	tst.w	d0
	bne	pas_instrument	; S'il y a note sans instr
	tst.w	d2
	bne	effets1		; Seulement l'effet
	tst.w	c_v_t(a3)
	beq	fx_fin1		; Pas de volume on se tire
	bra	effets1
	
instrum:	move.w	d2,d3
	and.w	#$FF00,d3		; d3 = num‚ro de l'effet 2 chiffres
	cmp.w	#$900,d3		; Note delay, on s'en va directos
	beq	effets1_no_vol

	tst.w	d1		; Y a-t-il un instrument ?
	beq.s	pas_instrument
	move.w	d1,instr_t(a3)	; Oui, il devient l'instrument courant
	mulu.w	#next_i,d1
	lea	([adr_instrset,a1],d1.l),a2	; a2 pointe sur l'instrument
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
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Sans oublier le volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant aussi

pas_instrument:
	tst.w	d0
	beq	effets1		; S'il n'y a pas de note on s'en va
	move.w	d2,d3
	and.w	#$FF00,d3		; d3 = num‚ro de l'effet 2 chiffres
	cmp.w	#$300,d3
	beq.s	tone_p
	cmp.w	#$500,d3
	beq.s	tone_p
	cmp.w	#$600,d3
	beq.s	tone_p
	cmp.w	#$AB00,d3
	beq.s	tone_p
	cmp.w	#$1800,d3
	blt.s	pas_tone_p
	cmp.w	#$1B00,d3
	bgt.s	pas_tone_p
tone_p:				; S'il y a un tone portamento (3,5,6,ab,18,19,1a ou 1b)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	add.w	transp_t(a3),d3	; Transposition du sample courant
	sub.w	#24,d3
	IfNE	CHECK
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
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)		; Volume courant ajust‚
	bra	fx_fin1

pas_tone_p:
	move.w	d0,curnote_t(a3)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	move.w	instr_t(a3),d1
	mulu.w	#next_i,d1
	lea	([adr_instrset,a1],d1.l),a2	; a2 pointe sur l'instrument
	env_initialisation	a3,1,a2		; Initialise les enveloppes
	move.w	curnote_t(a3),d4		; Recherche le sample qui va avec la note courante
	move.b	transp_i(a2,d4.w*2),d1
	ext.w	d1
	move.w	d1,transp_t(a3)		; Transposition
	add.w	d1,d3			; Sur la note
	moveq	#0,d1
	move.b	splnum_i(a2,d4.w*2),d1
	move.w	d1,ninstr_t(a3)		; Il devient le sample courant
	move.l	(adr_samples,a1,d1.w*4),a4
	move.w	vol_s(a4),volsam_t(a3)	; Recopie le volume du sample
	move.w	ftune_s(a4),norm_f_t(a3)	; Recopie le finetune du sample
	move.w	autobal_s(a4),d4
	bmi.s	.pas_autb
	move.w	d4,curbal_t(a3)		; Recopie la balance du sample
.pas_autb:	sub.w	#24,d3
	IfNE	CHECK
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

fin_tone_p:
	moveq	#0,d3		; d3 position dans le sample (au d‚but)
	move.w	d2,d4
	and.w	#$F000,d4		; d4 num‚ro de l'effet 1 chiffre
	cmp.w	#$9000,d4		; On doit jouer … partir d'un certain point ?
	bne.s	fin_ppart
	move.w	d2,d3		; Sample Offset
	sub.w	#$9000,d3
	lsl.l	#8,d3
fin_ppart:	move.l	d3,pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
	move.w	ninstr_t(a3),d1
	move.l	(adr_samples,a1,d1.w*4),a4
	move.l	a4,adrsam_t(a3)	; Recopie l'adresse du sample
	add.l	#data_s,adrsam_t(a3)
	moveq	#0,d3
	move.w	d1,d3
	swap	d3
	lsr.l	#6,d3		; d3 = d1*1024
	add.l	#repeatbuffer,d3
	move.l	d3,rbuffer_t(a3)	; l'adresse du buffer de r‚p‚tition,
	move.w	nbits_s(a4),d3	; Nombre de bits
	lsr.w	#3,d3
	move.w	d3,nbits_t(a3)
	move.w	fech_s(a4),fech_t(a3)		; Fr‚quence d'‚chantillonnage
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

;--- L… on gŠre les effets qui n'agissent qu'en d‚but de note ---------------

effets1:
	move.w	c_v_t(a3),d3	; Commande de volume ?
	beq.s	effets1_no_vol
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant ajust‚
effets1_no_vol:
	move.w	d2,d3
	lsr.w	#8,d3		; d3 = num‚ro d'effet
	move.w	d2,d4
	cmp.w	#$20,d3		; section 00xx - 1fxx
	blt.s	.saute
	cmp.w	#$a0,d3
	blt.s	.ef1ch
	cmp.w	#$cf,d3		; section a0xx - cfxx
	bgt.s	.ef1ch
	sub.w	#$80,d3		; transforme en 20xx - 4fxx
.saute:	and.w	#$FF,d4		; d4 = paramŠtre 8 bits
	jmp	([fx_table_de_sauts1,d3.w*4])	; On saute dans la bonne routine

.ef1ch:	lsr.b	#4,d3		; Pour les effets … 1 chiffre
	and.w	#$FFF,d4		; d4 = paramŠtre 12 bits
	jmp	([fx_table_de_sauts1b,d3.w*4])	; Hop on y va

fx_fin1:

prmvbl_next_track:
	add.w	#next_t,a3
	dbra	d7,premvbl_loop
	lea	info_track,a3	; a3 pointe sur les informations des voies
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie

;--- Ici on ex‚cute les effets qui agissent pendant toute la dur‚e de la note

pas_seulement_1ere_vbl:
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
	cmp.w	#$cf,d3		; section a0xx - cfxx
	bgt.s	.ef1ch2
	sub.w	#$80,d3		; transforme en 20xx - 4fxx
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
	lsr.l	#8,d5		; du sample. -> /$800
	mulu.w	mix_volume_t(a3),d5	; Et du volume de mix: /$800 * /$1000 -> /$800000
	lsl.l	#4,d5		; -> /$8000000
	swap	d5		; -> /$800
	move.w	d5,vol_t(a3)	; Volume final

;--- Gestion de l'enveloppe de volume ----------------------------------------

gestion_env_volume:
	move.w	nevol_t(a3),d0	; d0 = Num‚ro d'enveloppe
	beq	gestion_env_tone	; Pas d'enveloppe de volume
	tst.w	ev_waitcpt_t(a3)	; On est sur un Wait ?
	bgt	.enveloppe_wait	; Oui, alors on le continue
	move.w	ev_volume_t(a3),d1
	tst.w	pevol_t(a3)	; Position n‚gative ?
	bmi	.env_set_volume	; Oui, l'enveloppe est finie
	lea	([module_inf1+adr_evol,d0.w*4]),a4
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
.comsuite:	addq.w	#1,d6		; Une commande de plus
	cmp.w	#ENV_COMMANDMAX,d6
	ble	.comloop		; Tout baigne, prochaine commande
	move.w	ev_volume_t(a3),d1	; Sinon on arrˆte pour ce tick
	move.w	d0,pevol_t(a3)
	bra	.env_set_volume

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
	lea	([module_inf1+adr_eton,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,deton_t(a3)
	clr.w	peton_t(a3)
	clr.w	et_waitcpt_t(a3)
	move.w	nepan_t(a3),d0
	lea	([module_inf1+adr_epan,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,depan_t(a3)
	clr.w	pepan_t(a3)
	clr.w	ep_waitcpt_t(a3)
	move.w	nevol_t(a3),d0
	lea	([module_inf1+adr_evol,d0.w*4]),a4
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
	IfNE	CHECK
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
	lea	sin_table(pc),a4
	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	ev_tremolowidth_t(a3),d4
	and.w	#$ff,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#2,d3
	add.l	d3,d1		; Additionne au volume
	IfNE	CHECK
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

gestion_env_tone:
	move.w	neton_t(a3),d0	; d0 = Num‚ro d'enveloppe
	beq	gestion_env_panning
	tst.w	et_waitcpt_t(a3)	; On est sur un Wait ?
	bgt	.enveloppe_wait	; Oui, alors on le continue
	move.w	et_tone_t(a3),d1
	tst.w	peton_t(a3)	; Position n‚gative ?
	bmi	.env_set_tone	; Oui, l'enveloppe est finie
	lea	([module_inf1+adr_eton,d0.w*4]),a4
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
.comsuite:	addq.w	#1,d6		; Une commande de plus
	cmp.w	#ENV_COMMANDMAX,d6
	ble.s	.comloop		; Tout baigne, prochaine commande
	move.w	et_tone_t(a3),d1	; Sinon on arrˆte pour ce tick
	move.w	d0,peton_t(a3)
	bra	.env_set_tone

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
	lea	([module_inf1+adr_evol,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,devol_t(a3)
	clr.w	pevol_t(a3)
	clr.w	ev_waitcpt_t(a3)
	move.w	nepan_t(a3),d0
	lea	([module_inf1+adr_epan,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,depan_t(a3)
	clr.w	pepan_t(a3)
	clr.w	ep_waitcpt_t(a3)
	move.w	neton_t(a3),d0
	lea	([module_inf1+adr_eton,d0.w*4]),a4
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
	IfNE	CHECK
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
	lea	sin_table(pc),a4
	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	et_vibratowidth_t(a3),d4
	and.w	#$ff,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#5,d3
	add.l	d3,d1		; Additionne … la p‚riode
	IfNE	CHECK
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
	IfNE	CHECK
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

gestion_env_panning:
	move.w	nepan_t(a3),d0	; d0 = Num‚ro d'enveloppe
	beq	fin_gestion_enveloppes
	tst.w	ep_waitcpt_t(a3)	; On est sur un Wait ?
	bgt	.enveloppe_wait	; Oui, alors on le continue
	move.w	ep_pan_t(a3),d1
	tst.w	pepan_t(a3)	; Position n‚gative ?
	bmi	.env_set_pan	; Oui, l'enveloppe est finie
	lea	([module_inf1+adr_epan,d0.w*4]),a4
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
.comsuite:	addq.w	#1,d6		; Une commande de plus
	cmp.w	#ENV_COMMANDMAX,d6
	ble.s	.comloop		; Tout baigne, prochaine commande
	move.w	ep_pan_t(a3),d1	; Sinon on arrˆte pour ce tick
	move.w	d0,pepan_t(a3)
	bra	.env_set_pan

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
	lea	([module_inf1+adr_evol,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,devol_t(a3)
	clr.w	pevol_t(a3)
	clr.w	ev_waitcpt_t(a3)
	move.w	neton_t(a3),d0
	lea	([module_inf1+adr_eton,d0.w*4]),a4
	move.w	keyoffoffset_e(a4),d2
	add.w	#data_e,d2
	move.w	d2,deton_t(a3)
	clr.w	peton_t(a3)
	clr.w	et_waitcpt_t(a3)
	move.w	nepan_t(a3),d0
	lea	([module_inf1+adr_epan,d0.w*4]),a4
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
	IfNE	CHECK
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

;--- Voie suivante... --------------------------------------------------------

fin_gestion_enveloppes:
	add.w	#next_t,a3
	dbra	d7,pas_seulement_1ere_vbl

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
	IfNE	MIDI_IN

	tst.w	midi_in_on(pc)
	beq.s	.no_midi_in
	tst.w	midi_in_sync_flag(pc)
	beq.s	.no_sync
	tst.w	current_play_mode(pc)
	bne	gp_new_vbl_loop
.no_sync:
.no_midi_in:

	EndC
; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

fin_gestion_partition:

;--- Mise … jour du nombre de spl par vbl ------------------------------------

	move.l	vblsize(pc),d0	; Prend d'un coup les parties entiŠres et frac
	moveq	#0,d1
	move.w	vblcurrentsize_frac(pc),d1	; Le compteur frac courant
	add.l	d1,d0		; Ajoute 1 … vblsize en cas de retenue
	move.l	d0,vblcurrentsize	; Mise … jour des 2 parties

	movem.l	(sp)+,d0-a6
	rts



;-----------------------------------------------
;	Quand une note est rentr‚e
;	au clavier en plus de la song
;	Modifie d3, a2, a3 et eventuellement
;	d2, a4 et le pattern
;-----------------------------------------------
additional_notes:
	lea	info_track,a3
	lea	new_note_buffer(pc),a2
	tst.w	current_edit_mode(pc)	; Si on est en Edit + Play, on
	beq	.addnotes_normal	; enregistre les nouvelles notes
	tst.w	current_play_mode(pc)	; sur le pattern
	bne.s	.play_mode

;--- En mode Edit sans Play, signale au GfA l'arriv‚e de nouvelles notes -----
	move.w	mod_nbrtrack(a0),d3
	subq.w	#1,d3
.nn_loop3:	tst.b	(a2)		; Note rentr‚e?
	beq.s	.nonewn3
	move.w	#1,midi_in_gfa_playline
.nonewn3:	addq.l	#6,a2
	dbra	d3,.nn_loop3
	rts

;--- En mode Edit + Play, on change le pattern -------------------------------
.play_mode:
	move.w	mod_numpat(a0),d3
	move.w	mod_curlinepos(a0),d1
	move.l	(adr_pattern,a1,d3.w*4),a4	; a4 pointe sur le chunk du pattern
	move.w	mod_nbrtrack(a0),d3
	mulu.w	#5,d3
	mulu.w	d1,d3
	lea	data_p(a4,d3.l),a4	; a4 contient l'adresse de la ligne … modifier
	move.w	mod_nbrtrack(a0),d3
	subq.w	#1,d3
.nn_loop:	tst.b	(a2)		; Note rentr‚e?
	beq.s	.nonewnot
	move.b	1(a2),d2		; Recopie la note
	beq.s	.copynote		; InsŠre-la dans le pattern
	move.b	d2,(a4)		; si elle existe (<> 0)
.copynote:	move.b	d2,c_n_t+1(a3)
	move.b	2(a2),d2		; Recopie l'instrument
	beq.s	.copyinst
	move.b	d2,1(a4)
.copyinst:	move.b	d2,c_i_t+1(a3)
	move.w	3(a2),d2		; Recopie l'effet
	beq.s	.copyfx
	move.w	d2,2(a4)
.copyfx:	move.w	d2,c_e_t(a3)
	move.b	5(a2),d2		; Recopie la commande de volume
	beq.s	.copyvol
	move.b	d2,4(a4)
.copyvol:	move.b	d2,c_v_t+1(a3)
	clr.b	(a2)		; Signale qu'on a vid‚ la nouvelle note
	move.w	#1,flag_new_notes	; Idem, mais pour dire au player qu'il y a du neuf
	move.w	#1,flag_new_note_t(a3)	; Pr‚cise la piste
.nonewnot:	add.w	#next_t,a3
	addq.l	#6,a2
	addq.l	#5,a4
	dbra	d3,.nn_loop
	rts

;--- En mode Normal (sans Edit) ----------------------------------------------
.addnotes_normal:
	move.w	mod_nbrtrack(a0),d3
	subq.w	#1,d3
.nn_loop2:	tst.b	(a2)		; Note rentr‚e?
	beq.s	.nonewn2
	move.b	1(a2),c_n_t+1(a3)	; Recopie la note
	move.b	2(a2),c_i_t+1(a3)	; Recopie l'instrument
	move.w	3(a2),c_e_t(a3)	; Recopie l'effet
	move.b	5(a2),c_v_t+1(a3)	; Recopie la commande de volume
	clr.b	(a2)		; Signale qu'on a vid‚ la nouvelle note
	move.w	#1,flag_new_notes	; Idem, mais pour dire au player qu'il y a du neuf
	move.w	#1,flag_new_note_t(a3)	; Pr‚cise la piste
.nonewn2:	add.w	#next_t,a3
	addq.l	#6,a2
	dbra	d3,.nn_loop2
	rts



;***********************************************
; Effets agissant seulement au d‚but d'une note
;***********************************************

;-----------------------------------------------
;	Set Linear Volume
;-----------------------------------------------
fx_set_lin_volume:
	IfNE	CHECK=2
	cmp.w	#$100,d4
	ble.s	.ok2
	move.w	#$100,d4
	EndC

.ok2:	lea	vlin_2_exp(pc),a4
	move	(a4,d4.w*2),volenot_t(a3)
	lsl.w	#3,d4
	move.w	d4,vollnot_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Set Exponential Volume
;-----------------------------------------------
fx_set_exp_volume:
	IfNE	CHECK=2
	cmp.w	#$800,d4
	ble.s	.ok3
	move.w	#$800,d4
	EndC

.ok3:	move.w	d4,volenot_t(a3)
	lea	vexp_2_lin(pc),a4
	move.w	(a4,d4.w*2),vollnot_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Set Balance
;-----------------------------------------------
fx_set_balance:
	move.w	d4,curbal_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Set Linear Master Volume
;-----------------------------------------------
fx_set_lin_master_vol:
	IfNE	CHECK=2
	cmp.w	#$FFF,d4
	ble.s	.ok5
	move.w	#$FFF,d4
	EndC

.ok5:	move.w	d4,master_vol
	bra	fx_fin1

;-----------------------------------------------
;	Set Exponential Master Volume
;-----------------------------------------------
fx_set_exp_master_vol:
	lea	vexp_2_lin_master(pc),a4
	move.w	(a4,d4.w*2),master_vol
	bra	fx_fin1

;-----------------------------------------------
;	Roll (initialisation)
;-----------------------------------------------
fx_roll_7_init:
	move.w	d4,d5
	and.w	#$FF,d5		; d5 = nbr de coups maxi
	bne.s	.pl7
	moveq	#-1,d5		; Si d5 = 0, r‚p‚titions infinies
.pl7:	move.w	d5,rollnbr_t(a3)
	lsr.w	#8,d4		; d4 = vitesse
	tst.b	d4
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Roll + volume slide + set balance
;	(initialisation)
;-----------------------------------------------
fx_roll_and_vsl_and_sbl_init:
	move.w	d4,d5
	and.w	#$F00,d5
	move.w	d5,curbal_t(a3)	; Fixe la balance
	and.w	#15,d4		; d4 = vitesse
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Arpeggio, initialisation
;-----------------------------------------------
fx_arpeggio_init:
	clr.w	arpegcpt_t(a3)	; Compteur … 0
	bra	fx_fin1

;-----------------------------------------------
;	 Detune
;-----------------------------------------------
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

;-----------------------------------------------
;	Note cut, initialisation
;-----------------------------------------------
fx_note_precut:
	move.w	d4,cut_del_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Position Jump
;-----------------------------------------------
fx_pos_jump:
	tst.w	mod_flagnewline(a0)	; La ligne n'a pas encore ‚t‚ chang‚e par un 0Dxx ?
	bne.s	.ok
	clr.w	mod_linepos(a0)
.ok:
	IfNE	CHECK
	cmp.w	mod_songlen(a0),d4
	bge	fx_fin1
	EndC
	move.w	d4,mod_songpos(a0)	; Nouvelle position
	move.w	([adr_song,a1],d4.w*2),mod_numpat(a0)	; Trouve le nouveau pattern
	move.w	#-1,mod_flagnewpos(a0)	; On signale que la position a ‚t‚ modifi‚e
	bra	fx_fin1

;-----------------------------------------------
;	Set vibrato wave
;-----------------------------------------------
fx_set_vib_wave:
	IfNE	CHECK=2
	and.b	#3,d4
	EndC
	move.b	d4,vibwav_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Set tremolo wave
;-----------------------------------------------
fx_set_trem_wave:
	IfNE	CHECK=2
	and.b	#3,d4
	EndC
	move.b	d4,tremwav_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Break pattern & jump to line
;-----------------------------------------------
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
	IfNE	CHECK=2
	move.w	mod_numpat(a0),d5
	move.l	(adr_pattern,a1,d5.w*4),a4
	cmp.w	nlines_p(a4),d4
	blt.s	.ok
	moveq	#0,d4		; Si la nouvelle ligne est en dehors du pattern
	EndC
.ok:	move.w	d4,mod_linepos(a0)	; Pointe sur la nouvelle ligne du pattern
	move.w	#-1,mod_flagnewline(a0)
	bra	fx_fin1

;-----------------------------------------------
;	Pattern loop
;-----------------------------------------------
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
	bra	fx_fin1		; si par hasard on ‚tait all‚ ailleurs

;-----------------------------------------------
;	Set global speed
;-----------------------------------------------
fx_set_global_speed:
	tst.w	d4
	beq	fx_fin1
	cmp.w	#31,d4
	bgt.s	.tempo
	move.w	d4,mod_speed(a0)
	moveq	#125,d4		; Tempo 125
.tempo:
	tst.w	midi_in_on(pc)	; Si on est en sychro MIDI externe,
	beq.s	.chgtempo		; on change la valeur du tempo mais
	tst.w	midi_in_sync_flag(pc) ; pas la dur‚e d'un tick.
	bne	fx_fin1

.chgtempo:	move.w	d4,-(sp)
	bsr	fx_change_tempo
	addq.l	#2,sp
	bra	fx_fin1

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Change le tempo. Nouveau tempo: mot en paramŠtre dans la pile.
fx_change_tempo:
	movem.l	d3-d5,-(sp)
	move.w	4*3+4(sp),d4
	move.w	d4,mod_tempo(a0)
	mulu.w	#4*6,d4
	move.w	replay_frequency(pc),d5
	mulu.w	#60,d5
	divu.w	d4,d5		; d5 = freq.repl * 60 s / (tempo * 4 lig * 6 ticks)
	move.l	d5,d3		;    = nombre de spl par tick
	clr.w	d3
	divu.w	d4,d3		; d3 = nbr de spl par tick, frac
	swap	d3
	move.w	d5,d3
	swap	d3		; d3 = nbr de spl par tick * $10000
	move.l	#1200-1,d4
	add.w	d5,d4
	divu.w	#1200,d4		; d4 = splpartick/1200 arrondi par excŠs
	ext.l	d4
	divu.l	d4,d3		; d3 = Nbr de spl par VBL * $10000
	move.l	d3,vblsize		; Stoque d'un coup les parties entiŠre et fractionnaire
	move.w	d4,vblnumber
	movem.l	(sp)+,d3-d5
	rts

;-----------------------------------------------
;	Set number of frames
;-----------------------------------------------
fx_set_nbr_of_frames:
	IfNE	CHECK=2
	tst.w	d4
	beq	fx_fin1
	EndC
	move.w	d4,mod_speed(a0)
	bra	fx_fin1

;-----------------------------------------------
;	Set fine speed
;-----------------------------------------------
fx_set_fine_speed:
	add.w	d4,d4
	IfNE	CHECK=2
	beq	fx_fin1
	EndC
	moveq	#0,d5
	move.w	replay_frequency,d5
	divu.w	#125*4*6/60,d5
	sub.w	#256,d5
	add.w	d5,d4
	move.w	d4,vblsize		; Attention, Tempo non modifi‚.
	bra	fx_fin1

;-----------------------------------------------
;	Fine portamento up
;-----------------------------------------------
fx_fine_porta_up:
	move.w	pernote_t(a3),d5
	lsl.w	#4,d4
	bne.s	.ok2
	move.w	fportspd_t(a3),d4
.ok2:	move.w	d4,fportspd_t(a3)
	sub.w	d4,d5
	IfNE	CHECK
	cmp.w	#PERIOD_MINI,d5
	bge.s	.ok
	move.w	#PERIOD_MINI,d5
	EndC
.ok:	move.w	d5,pernote_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Fine portamento down
;-----------------------------------------------
fx_fine_porta_down:
	IfNE	CHECK
	ext.l	d4
	EndC
	lsl.w	#4,d4
	bne.s	.ok2
	move.w	fportspd_t(a3),d4
.ok2:	move.w	d4,fportspd_t(a3)
	add.w	pernote_t(a3),d4
	IfNE	CHECK
	cmp.l	#PERIOD_MAXI,d4
	ble.s	.ok
	move.w	#PERIOD_MAXI,d4
	EndC
.ok:	move.w	d4,pernote_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Note delay - initialisation
;-----------------------------------------------
fx_predelay:
	move.w	d4,delay_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Fine volume slide
;-----------------------------------------------
fx_fine_v_sldown_l:
	neg.w	d4
fx_fine_v_slup_l:
	tst.w	d4
	bne.s	.ok
	move.w	fvolslspd_t(a3),d4
.ok:	move.w	d4,fvolslspd_t(a3)
	bsr	fx_do_v_slide_l
	bra	fx_fin1

;-----------------------------------------------
;	Fine exponential volume slide
;-----------------------------------------------
; *** Ces 2 effets sont inutilis‚s pour l'instant
;fx_fine_v_sldown_e:			; Fine volume slide down (exp) \
;	neg.w	d4		;                               > *** Ne pas s‚parer
;fx_fine_v_slup_e:			; Fine volume slide up (exp)   /
;	bsr	fx_do_v_slide_e
;	bra	fx_fin1

;-----------------------------------------------
;	Fine master volume slide
;-----------------------------------------------
fx_fine_mv_sldown_l:			; Fine master volume slide up (lin)   \
	neg.w	d4		;                                      > *** Ne pas s‚parer
fx_fine_mv_slup_l:			; Fine master volume slide down (lin) /
	bsr	fx_do_mv_slide_l
	bra	fx_fin1

;-----------------------------------------------
;	Pattern delay
;-----------------------------------------------
fx_pattern_delay:
	move.w	d4,mod_patrep(a0)
	bra	fx_fin1

;-----------------------------------------------
;	Roll + volume slide (initialisation)
;-----------------------------------------------
fx_roll_and_vsl_init:
	and.w	#15,d4		; d4 = vitesse
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Tremor (initialisation)
;-----------------------------------------------
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

;-----------------------------------------------
;	Set flags
;-----------------------------------------------
fx_set_flags:
.bit0:
	btst	#0,d4		; Bit 0 : interpolation
	beq.s	.bit0off
	move.w	#1,interpol_t(a3)
	bra.s	.fin
.bit0off:	clr.w	interpol_t(a3)
.fin:
	bra	fx_fin1

;-----------------------------------------------
;	Set volume envelope
;-----------------------------------------------
fx_set_vol_env:
	IfNE	CHECK=2
	cmp.w	#NBRVOLENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
.ok:
	EndC
	move.w	d4,nevol_t(a3)
	beq	fx_fin1

	env_volume_init	a3
	bra	fx_fin1

;-----------------------------------------------
;	Set tone envelope
;-----------------------------------------------
fx_set_ton_env:
	IfNE	CHECK=2
	cmp.w	#NBRTONENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
.ok:
	EndC
	move.w	d4,neton_t(a3)
	beq	fx_fin1

	env_tone_init	a3
	bra	fx_fin1

;-----------------------------------------------
;	Set panning envelope
;-----------------------------------------------
fx_set_pan_env:
	IfNE	CHECK=2
	cmp.w	#NBRPANENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
.ok:
	EndC
	move.w	d4,nepan_t(a3)
	beq	fx_fin1

	env_panning_init	a3
	bra	fx_fin1

;-----------------------------------------------
;	Set volume envelope (Key Off)
;-----------------------------------------------
fx_set_vol_env_ko:
	IfNE	CHECK=2
	cmp.w	#NBRVOLENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
.ok:
	EndC
	move.w	d4,nevol_t(a3)
	beq	fx_fin1

	env_volume_init	a3
	move.w	([module_inf1+adr_evol,d4.w*4],keyoffoffset_e.w),d6
	add.w	d6,devol_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Set tone envelope (Key Off)
;-----------------------------------------------
fx_set_ton_env_ko:
	IfNE	CHECK=2
	cmp.w	#NBRTONENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
.ok:
	EndC
	move.w	d4,neton_t(a3)
	beq	fx_fin1

	env_tone_init	a3
	move.w	([module_inf1+adr_eton,d4.w*4],keyoffoffset_e.w),d6
	add.w	d6,deton_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Set panning envelope (Key Off)
;-----------------------------------------------
fx_set_pan_env_ko:
	IfNE	CHECK=2
	cmp.w	#NBRPANENV_MAXI-1,d4
	ble.s	.ok
	moveq	#0,d4
.ok:
	EndC
	move.w	d4,nepan_t(a3)
	beq	fx_fin1

	env_panning_init	a3
	move.w	([module_inf1+adr_epan,d4.w*4],keyoffoffset_e.w),d6
	add.w	d6,depan_t(a3)
	bra	fx_fin1

;-----------------------------------------------
;	Fine Sample Offset
;-----------------------------------------------
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

;-----------------------------------------------
;	Very Fine Sample Offset
;-----------------------------------------------
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

;-----------------------------------------------
;	Increment Sample Position
;-----------------------------------------------
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

;-----------------------------------------------
;	Decrement Sample Position
;-----------------------------------------------
fx_dec_sample_pos:
	ext.l	d4
	sub.l	d4,pos_t(a3)

	IfNE	CHECK
	bpl	fx_fin1
	clr.l	pos_t(a3)
	EndC

	bra	fx_fin1

;-----------------------------------------------
;	AutoTempo (initialisation)
;-----------------------------------------------
fx_init_autotempo:
	move.w	#1,flag_autotempo_t(a3)	; On le fait en 'tous les ticks' … cause
	bra	fx_fin1			; d'une ‚ventuelle commande de vitesse

;-----------------------------------------------
;	AutoPeriod (initialisation)
;-----------------------------------------------
fx_init_autoperiod:
	move.w	#1,flag_autoperiod_t(a3)	; On le fait en 'tous les ticks' … cause
	bra	fx_fin1			; d'une ‚ventuelle commande de vitesse

;-----------------------------------------------
;	Demo Synchro
;-----------------------------------------------
fx_demo_synchro:
	bra	fx_fin1

;-----------------------------------------------
;	Set track linear volume
;-----------------------------------------------
fx_set_trk_lin_vol:
	lsl.w	#8,d4
	bsr	fx_do_set_trk_lin_vol
	bra	fx_fin1

fx_do_set_trk_lin_vol:
	tst.w	d4
	beq.s	.vol_0
	move.w	d4,mix_volume_t(a3)

	move.w	#$F00,d5
.loop:	add.w	d4,d4
	bcs.s	.ok
	sub.w	#$100,d5
	bra.s	.loop

.ok:	lsr.w	#8,d4		; De 0 … $FF
	add.w	d4,d4		; * 2 … cause du tableau en mots
	lea	vlin_2_exp_track(pc),a4
	add.w	(a4,d4.w),d5

	move.w	d5,mix_volume_e_t(a3)
	rts

.vol_0:	clr.w	mix_volume_t(a3)
	clr.w	mix_volume_e_t(a3)
	rts

;-----------------------------------------------
;	Set track exponential volume
;-----------------------------------------------
fx_set_trk_exp_vol:
	lsl.w	#4,d4
	bsr	fx_do_set_trk_exp_vol
	bra	fx_fin1

fx_do_set_trk_exp_vol:
	tst.w	d4
	beq.s	.vol_0
	move.w	d4,mix_volume_e_t(a3)
	lsr.w	#4,d4
	move.w	d4,d5

	and.w	#$F,d4		; On isole la partie inf‚rieure, pour calculer 2^(0.xxx)
	lsl.w	#4+1,d4		; De 0 … $F0, * 2 car .w
	lea	vexp_2_lin_track(pc),a4
	move.w	(a4,d4.w),d4	; R‚sultat: [2^(0/256), 2^(255/256)] => [$8000, $FFFF]

	lsr.w	#4,d5		; La partie restante, c'est du 2^n
	sub.w	#$F,d5		; Pour le sens du d‚calage
	neg.w	d5
	lsr.w	d5,d4		; Finalement on a v_lin = 2 ^ (valeur/16)

	move.w	d4,mix_volume_t(a3)
	rts

.vol_0:	clr.w	mix_volume_t(a3)
	clr.w	mix_volume_e_t(a3)
	rts

;-----------------------------------------------
;	Fine exponential track volume slide
;-----------------------------------------------
fx_fine_t_v_sldown_e:
	neg.w	d4
fx_fine_t_v_slup_e:
	tst.w	d4
	bne.s	.ok
	move.w	fetvolslspd_t(a3),d4
.ok:	move.w	d4,fetvolslspd_t(a3)
	bsr	fx_do_t_v_slide_e
	bra	fx_fin1



;***********************************************
;	Effets agissant pendant la note
;***********************************************

;-----------------------------------------------
;	Arpeggio
;-----------------------------------------------
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
	IfNE	CHECK
	cmp.w	#PERIOD_MINI,d4
	bge.s	.suite2
	move.w	#PERIOD_MINI,d4
	EndC
.suite2:	move.w	d4,per_t(a3)
	move.w	vollnot_t(a3),vol_t(a3)	; On met le bon volume car on ne
	move.w	curbal_t(a3),bal_t(a3)	; repasse pas par la fin normale
	bra	fx_fin_speciale

;-----------------------------------------------
;	Portamento up
;-----------------------------------------------
fx_porta_up:
	lsl.w	#4,d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	sub.w	d4,pernote_t(a3)
	IfNE	CHECK
	cmp.w	#PERIOD_MINI,pernote_t(a3)
	bge	fx_fin_normale
	move.w	#PERIOD_MINI,pernote_t(a3)
	EndC
	bra	fx_fin_normale

;-----------------------------------------------
;	Extra fine portamento up
;-----------------------------------------------
fx_extra_fine_porta_up:
	tst.w	d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	sub.w	d4,pernote_t(a3)
	IfNE	CHECK
	cmp.w	#PERIOD_MINI,pernote_t(a3)
	bge	fx_fin_normale
	move.w	#PERIOD_MINI,pernote_t(a3)
	EndC
	bra	fx_fin_normale

;-----------------------------------------------
;	Portamento down
;-----------------------------------------------
fx_porta_down:
	lsl.w	#4,d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	ext.l	d4
	add.w	pernote_t(a3),d4
	IfNE	CHECK
	cmp.l	#PERIOD_MAXI,d4
	ble.s	.suite
	move.w	#PERIOD_MAXI,d4
	EndC
.suite:	move.w	d4,pernote_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------
;	Extra fine portamento down
;-----------------------------------------------
fx_extra_fine_porta_down:
	ext.l	d4
	bne.s	.ok
	move.w	portspd_t(a3),d4
.ok:	move.w	d4,portspd_t(a3)
	add.w	pernote_t(a3),d4
	IfNE	CHECK
	cmp.l	#PERIOD_MAXI,d4
	ble.s	.suite
	move.w	#PERIOD_MAXI,d4
	EndC
.suite:	move.w	d4,pernote_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------
;	Tone portamento
;-----------------------------------------------
fx_tone_porta:
	bsr.s	fx_do_tone_porta
	bra	fx_fin_normale

;-----------------------------------------------
;	Extra fine tone portamento
;-----------------------------------------------
fx_extra_fine_tone_porta:
	bsr.s	fx_do_very_fine_tone_porta
	bra	fx_fin_normale

fx_do_tone_porta:			; Ex‚cute le Tone Portamento
	lsl.w	#4,d4
fx_do_very_fine_tone_porta:
	tst.w	d4
	bne.s	.suite1
	move.w	tportspd_t(a3),d4
.suite1:	move.w	d4,tportspd_t(a3)
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

;-----------------------------------------------
;	Vibrato
;-----------------------------------------------
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
	lea	sin_table(pc),a4
	and.b	#3,d4
	beq.s	.sinus		; Forme sinus : 0
	lea	square_table(pc),a4
	subq.b	#1,d4
	bne.s	.sinus		; Forme carr‚e : 2 (ou 3)
	lea	rampdown_table(pc),a4
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

;-----------------------------------------------
;	Tone portamento + vibrato
;-----------------------------------------------
fx_tone_porta_vib:
	bsr	fx_do_tone_porta
	moveq	#0,d4
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------
;	Vibrato + tone portamento
;-----------------------------------------------
fx_vib_tone_porta:
	move.w	d4,-(sp)
	moveq	#0,d4
	bsr	fx_do_tone_porta
	move.w	d4,(sp)+
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------
;	Tremolo
;-----------------------------------------------
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
	lea	sin_table(pc),a4
	and.b	#3,d4
	beq.s	.sinus		; Forme sinus : 0
	lea	square_table(pc),a4
	subq.b	#1,d4
	bne.s	.sinus		; Forme carr‚e : 2 (ou 3)
	lea	rampdown_table(pc),a4
.sinus:	lsr.w	#2,d3
	and.w	#$3f,d3		; d3 = offset dans la table de sinus
	move.w	(a4,d3.w*2),d3	; d3 = sinus
	move.b	tremamp_t(a3),d4
	and.w	#$f,d4
	muls.w	d4,d3		; Multiplie par l'amplitude
	asr.w	#1,d3
	move.w	vollnot_t(a3),d4
	IfNE	CHECK
	tst.b	tremcpt_t(a3)	; N‚gatif ?
	bmi.s	.negatif
	EndC
	add.w	d3,d4		; Nouveau volume de la note
	IfNE	CHECK
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

;-----------------------------------------------
;	Note delay
;-----------------------------------------------
fx_delay:
	tst.w	delay_t(a3)
	bmi	fx_fin_normale	; -1, l'effet n'a plus de raison d'ˆtre
	bne	.nxt_vbl		; Compteur<>0, on attend encore
				; On initialise une note normale
	tst.w	d1		; Y a-t-il un instrument ?
	beq	.pas_inst
	move.w	d1,instr_t(a3)	; Oui, il devient l'instrument courant
	mulu.w	#next_i,d1
	lea	([adr_instrset,a1],d1.l),a2	; a2 pointe sur l'instrument
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
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Sans oublier le volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant aussi

.pas_inst:	tst.w	d0
	beq	fx_fin_normale	; S'il n'y a pas de note on s'en va
	move.w	d0,curnote_t(a3)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	move.w	instr_t(a3),d1
	mulu.w	#next_i,d1
	lea	([adr_instrset,a1],d1.l),a2	; a2 pointe sur l'instrument
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
	IfNE	CHECK
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
	moveq	#0,d3
	move.w	d1,d3
	swap	d3
	lsr.l	#6,d3		; d3 = d1*1024
	add.l	#repeatbuffer,d3
	move.l	d3,rbuffer_t(a3)	; l'adresse du buffer de r‚p‚tition,
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
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant ajust‚
.nxt_vbl:	subq.w	#1,delay_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------
;	Note cut
;-----------------------------------------------
fx_note_cut:
	tst.w	cut_del_t(a3)	; Compteur … 0 ?
	bmi	fx_fin_normale	; -1, plus besoin de l'effet
	bne.s	.nxt_vbl		; <>0 , on attend encore
	move.w	nepan_t(a3),d5	; Sinon on met les enveloppes sur Key Off
	lea	([module_inf1+adr_epan,d5.w*4]),a4
	move.w	keyoffoffset_e(a4),d6
	add.w	#data_e,d6
	move.w	d6,depan_t(a3)
	clr.w	pepan_t(a3)
	clr.w	ep_waitcpt_t(a3)
	move.w	neton_t(a3),d5
	lea	([module_inf1+adr_eton,d5.w*4]),a4
	move.w	keyoffoffset_e(a4),d6
	add.w	#data_e,d6
	move.w	d6,deton_t(a3)
	clr.w	peton_t(a3)
	clr.w	et_waitcpt_t(a3)
	move.w	nevol_t(a3),d5
	beq.s	.pas_env		; Si pas d'enveloppe de volume, on le coupe simplement
	lea	([module_inf1+adr_evol,d5.w*4]),a4
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

;-----------------------------------------------
;	Volume slide (linear)
;-----------------------------------------------
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
	IfNE	CHECK
	tst.w	d4
	bgt.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$100,d4
	ble.s	.ok2
	move.w	#$100,d4
	EndC
.ok2:	lea	vlin_2_exp(pc),a4
	move	(a4,d4.w*2),volenot_t(a3)
	lsl.w	#3,d4
	move.w	d4,vollnot_t(a3)
	rts

;-----------------------------------------------
;	Volume slide (exponential)
;-----------------------------------------------
fx_v_sldown_e:			; Volume slide down (exp) \
	neg.w	d4		;                          > *** Ne pas s‚parer
fx_v_slup_e:			; Volume slide up (exp)   /
	bsr.s	fx_do_v_slide_e
	bra	fx_fin_normale

fx_do_v_slide_e:			; Sous-routine de volume slide (exp.)
	add.w	volenot_t(a3),d4
	IfNE	CHECK
	tst.w	d4
	bgt.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$800,d4
	ble.s	.ok2
	move.w	#$800,d4
	EndC
.ok2:	move.w	d4,volenot_t(a3)
	lea	vexp_2_lin(pc),a4
	move.w	(a4,d4.w*2),vollnot_t(a3)
	rts

;-----------------------------------------------
;	Linear volume slide + tone porta
;-----------------------------------------------
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

;-----------------------------------------------
;	Exponential volume slide + tone porta
;-----------------------------------------------
fx_v_sldown_e_tp:			; Volume slide down (exp) + tone porta \
	neg.w	d4		;                                       > *** Ne pas s‚parer
fx_v_slup_e_tp:			; Volume slide up (exp) + tone porta   /
	bsr.s	fx_do_v_slide_e
	moveq	#0,d4
	bsr	fx_do_tone_porta
	bra	fx_fin_normale

;-----------------------------------------------
;	Linear volume slide + vibrato
;-----------------------------------------------
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

;-----------------------------------------------
;	Exponential volume slide + vibrato
;-----------------------------------------------
fx_v_sldown_e_vib:			; Volume slide down (exp) + vibrato \
	neg.w	d4		;                                    > *** Ne pas s‚parer
fx_v_slup_e_vib:			; Volume slide up (exp) + vibrato   /
	bsr	fx_do_v_slide_e
	moveq	#0,d4
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------
;	Linear master volume slide
;-----------------------------------------------
fx_mv_sldown_l:			; Master volume slide down (lin) \
	neg.w	d4		;                                 > *** Ne pas s‚parer
fx_mv_slup_l:			; Master volume slide up (lin)   /
	bsr.s	fx_do_mv_slide_l
	bra	fx_fin_normale

fx_do_mv_slide_l:			; Sous-routine de master volume slide (lin)
	move.w	master_vol(pc),d5
	add.w	d5,d4
	IfNE	CHECK
	tst.w	d4
	bpl.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$fff,d4
	ble.s	.ok2
	move.w	#$fff,d4
	EndC
.ok2:	move.w	d4,master_vol
	rts

;-----------------------------------------------
;	Left & Right balance move
;-----------------------------------------------
fx_left_bal_move:
	neg.w	d4
fx_right_bal_move:
	lsl.w	#4,d4
	bne.s	.ok
	move.w	panslspd_t(a3),d4
.ok:	move.w	d4,panslspd_t(a3)
	add.w	curbal_t(a3),d4
	IfNE	CHECK
	bge.s	.ok3
	moveq	#0,d4
.ok3:	cmp.w	#$fff,d4
	ble.s	.ok2
	move.w	#$fff,d4
	EndC
.ok2:	move.w	d4,curbal_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------
;	Roll
;-----------------------------------------------
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

;-----------------------------------------------
;	Roll + volume slide
;-----------------------------------------------
fx_roll_and_vsl:
	tst.b	rollcpt_t(a3)
	bne	.nxt_roll
	clr.l	pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
.nxt_roll:	move.b	rollcpt_t(a3),d5
	addq.b	#1,d5
	cmp.b	rollspd_t(a3),d5
	bne.s	.fin_roll
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
.vol_ok:	lea	vlin_2_exp(pc),a4
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

;-----------------------------------------------
;	Tremor
;-----------------------------------------------
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
	move.w	d4,-(sp)
	bsr	fx_change_tempo	; Hop le nouveau tempo
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

;-----------------------------------------------
;	Linear track volume slide
;-----------------------------------------------
fx_t_v_sldown_l:
	neg.w	d4
fx_t_v_slup_l:
	asl.w	#4,d4
	bne.s	.ok
	move.w	ltvolslspd_t(a3),d4
.ok:	move.w	d4,ltvolslspd_t(a3)
	bsr	fx_do_t_v_slide_l
	bra	fx_fin_normale

fx_do_t_v_slide_l:
	moveq	#0,d5
	move.w	d4,d5
	moveq	#0,d4
	move.w	mix_volume_t(a3),d4
	add.l	d5,d4
	IfNE	CHECK
	bpl.s	.ok
	moveq	#0,d4
.ok:	cmp.l	#$FFFF,d4
	ble.s	.ok2
	move.l	#$FFFF,d4
.ok2:
	EndC
	bsr	fx_do_set_trk_lin_vol
	rts

;-----------------------------------------------
;	Exponential track volume slide
;-----------------------------------------------
fx_t_v_sldown_e:
	neg.w	d4
fx_t_v_slup_e:
	tst.w	d4
	bne.s	.ok
	move.w	etvolslspd_t(a3),d4
.ok:	move.w	d4,etvolslspd_t(a3)
	bsr	fx_do_t_v_slide_e
	bra	fx_fin_normale

fx_do_t_v_slide_e:
	move.w	mix_volume_e_t(a3),d5
	add.w	d5,d4
	IfNE	CHECK
	bpl.s	.ok
	moveq	#0,d4
.ok:	cmp.w	#$FFF,d4
	ble.s	.ok2
	move.w	#$FFF,d4
.ok2:
	EndC
	bsr	fx_do_set_trk_exp_vol
	rts



	IfNE	MIDI_IN

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Gestion du port Midi					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Cette routine est appel‚e sous interruption, par l'interm‚diaire	*
*	du noyau.						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gestion_midi:

	movem.l	d0-a6,-(sp)
	lea	midi_data_buffer(pc),a2	; a2 = adresse du buffer de donn‚es
	lea	midi_track_state(pc),a3	; a3 = adresse de l'activit‚ des pistes

;--- Cherche les donn‚es arriv‚es sur le port Midi ---------------------------
gestmidi_new_data:
	move.w	sr,-(sp)
	or.w	#$700,sr		; Pour ne pas ˆtre d‚rang‚
	move.l	midi_iorec_adr(pc),a0
	move.w	iorec_ibufhd(a0),d1	; Position de lecture
	cmp.w	iorec_ibuftl(a0),d1
	beq	gestmidi_no_more_data	; Pas de nouvelles donn‚es Midi

	addq.w	#1,d1		; Ajourne d'abord la position de lecture
	cmp.w	iorec_ibufsz(a0),d1
	blt.s	.nxtposok
	moveq	#0,d1
.nxtposok:	moveq	#0,d0
	move.b	([a0,iorec_ibuf.w],d1.w),d0	; d0 = donn‚e
	move.w	d1,iorec_ibufhd(a0)
	move.w	(sp)+,sr

	cmp.b	#$FE,d0		; Active Sensing, inint‚ressant
	beq	gestmidi_data_loop_end
	tst.b	d0		; C'est un octet de status?
	bmi.s	gestmidi_new_status

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Reprend l'ancien status
	move.w	midi_current_channel(pc),d1
	move.w	midi_current_status(pc),d2
	move.w	midi_nbr_bytes_recvd(pc),d3
	addq.w	#1,d3		; Nouvel octet de donn‚e re‡u
	move.w	d3,midi_nbr_bytes_recvd
	bra.s	gestmidi_data_sort

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Change le status et le canal
gestmidi_new_status:
	cmp.w	#$F0,d0		; System Message ?
	blt.s	gestmidi_new_status_normal
	move.w	midi_current_status(pc),midi_old_status
	move.w	d0,d2
	move.w	d2,midi_current_status
	move.w	midi_nbr_bytes_recvd(pc),midi_old_nbrbytesrec
	moveq	#0,d3
	move.w	d3,midi_nbr_bytes_recvd
	bra.s	gestmidi_new_status_end

gestmidi_new_status_normal:
	move.b	d0,d1
	move.b	d0,d2
	and.w	#15,d1
	addq.w	#1,d1		; d1 = num‚ro du canal Midi (1-16)
	lsr.b	#4,d2
	and.w	#7,d2		; d2 = num‚ro de commande
	moveq	#0,d3		; d3 = Nombre - 1 d'octets d‚j… re‡us
	move.w	d1,midi_current_channel
	move.w	d2,midi_current_status
	move.w	d3,midi_nbr_bytes_recvd
gestmidi_new_status_end:

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
; Tri des donn‚es.
; A cet endroit:
; d0.l = nouvelle donn‚e
; d1.w = num‚ro du canal
; d2.w = num‚ro de la commande
; d3.w = position dans le buffer de r‚ception
gestmidi_data_sort:
	lea	module_inf2(pc),a0	; a0 = infos sur le module
	move.b	d0,(a2,d3.w)	; Sauve l'octet dans le buffer
	tst.w	d2		; Note Off
	beq	gestmidi_note_off
	cmp.w	#1,d2		; Note On
	beq	gestmidi_note_on
	cmp.w	#2,d2		; Polyphonic Aftertouch
	beq	gestmidi_polyphonic_aftertouch
	cmp.w	#3,d2		; Control Change
	beq	gestmidi_control_change
	cmp.w	#4,d2		; Program Change
	beq	gestmidi_program_change
	cmp.w	#5,d2		; Channel Aftertouch
	beq	gestmidi_channel_aftertouch
	cmp.w	#6,d2		; Pitch Bend
	beq	gestmidi_pitch_bend
	cmp.w	#$F0,d2		; System Message: System Exclusive
	beq	gestmidi_sm_system_exclusive
	cmp.w	#$F1,d2		; System Message: MIDI Time Code Quarter Frame
	beq	gestmidi_sm_midi_time_code_quarter_frame
	cmp.w	#$F2,d2		; System Message: Song Position Pointer
	beq	gestmidi_sm_song_position_pointer
	cmp.w	#$F3,d2		; System Message: Song Select
	beq	gestmidi_sm_song_select
	cmp.w	#$F4,d2		; System Message: Undefined
	beq	gestmidi_sm_undefined
	cmp.w	#$F5,d2		; System Message: Undefined
	beq	gestmidi_sm_undefined
	cmp.w	#$F6,d2		; System Message: Tune Request
	beq	gestmidi_sm_tune_request
	cmp.w	#$F7,d2		; System Message: End of Exclusive
	beq	gestmidi_sm_end_of_exclusive
	cmp.w	#$F8,d2		; System Message: Timing Clock
	beq	gestmidi_sm_timing_clock
	cmp.w	#$F9,d2		; System Message: Undefined
	beq	gestmidi_sm_undefined
	cmp.w	#$FA,d2		; System Message: Start
	beq	gestmidi_sm_start
	cmp.w	#$FB,d2		; System Message: Continue
	beq	gestmidi_sm_continue
	cmp.w	#$FC,d2		; System Message: Stop
	beq	gestmidi_sm_stop
	cmp.w	#$FD,d2		; System Message: Undefined
	beq	gestmidi_sm_undefined
	cmp.w	#$FF,d2		; System Message: System Reset
	beq	gestmidi_sm_system_request

gestmidi_data_loop_end:
	bra	gestmidi_new_data
gestmidi_no_more_data:		; *** Attention on a sauv‚ sr sur la pile avant!
	move.w	(sp)+,sr

;--- Transforme les nouvelles donn‚es en notes du tracker --------------------
	lea	module_inf2(pc),a0	; a0 = infos sur le module
	move.l	a3,a4		; a4 = adresse de la piste courante
	lea	new_note_buffer(pc),a5	; a5 = adresse du buffer de nouvelles notes
	move.w	mod_nbrtrack(a0),d4
	subq.w	#1,d4		; d4 = compteur de boucles
gestmidi_conv_note_loop:
	tst.w	midi_ts_flags(a4)	; La voie a subi des modifications?
	beq.s	gestmidi_conv_note_next
	move.l	midi_ts_pat_note(a4),1(a5)
	move.b	midi_ts_pat_volume(a4),5(a5)
	move.b	#1,(a5)		; Flag mis pour la nouvelle note
	and.w	#$FFFE,midi_ts_flags(a4)	; Mise … jour effectu‚e
gestmidi_conv_note_next:
	add.w	#midi_ts_next,a4
	addq.l	#6,a5
	dbra	d4,gestmidi_conv_note_loop

	movem.l	(sp)+,d0-a6
	rts



;----------------------------------------------------------------------------;
;	Note Off						;
;----------------------------------------------------------------------------;
gestmidi_note_off:
	cmp.w	#2,d3		; Attend 2 octets de donn‚e
	blt.s	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
gestmidi_note_off_2:
	tst.w	((midi_in_noteoff_flag-2).l,d1.w*2)
	beq.s	.nonotoff		; Flag = 0: Ignore totalement le message Note Off

	moveq	#0,d5
	move.b	1(a2),d5		; d5 = la note … ‚teindre
	move.w	mod_nbrtrack(a0),d4
	subq.w	#1,d4		; d4 = compteur de boucles
	move.l	a3,a4		; a4 = adresse de la piste courante
.findnote_loop:			; On va chercher la note
	cmp.w	midi_ts_channel(a4),d1	; C'est le bon canal?
	bne.s	.endif1
	cmp.w	midi_ts_note(a4),d5	; La bonne note?
	beq.s	.note_found
.endif1:	add.w	#midi_ts_next,a4
	dbra	d4,.findnote_loop
	bra.s	gestmidi_data_loop_end

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.note_found:
	clr.w	midi_ts_velocity(a4)	; V‚locit‚ … 0
	clr.w	midi_ts_note(a4)
	clr.w	midi_ts_pitch(a4)

	tst.w	((midi_in_noteoff_flag-2).l,d1.w*2)
	bpl.s	.nonotoff		; Flag = 1: on ne transcrit pas le message sur la partition
	move.l	#$00000A00,midi_ts_pat_note(a4)	; Note Cut pur et dur
	clr.b	midi_ts_pat_volume(a4)
	or.w	#1,midi_ts_flags(a4)	; Mise … jour
.nonotoff:

	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	Note On						;
;----------------------------------------------------------------------------;
gestmidi_note_on:
	cmp.w	#2,d3		; Attend 2 octets de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	tst.w	d0		; V‚locit‚ nulle?
	beq.s	gestmidi_note_off_2	; Oui, c'est un Note Off en fait
	moveq	#0,d5
	move.b	1(a2),d5		; d5 = la nouvelle note
	move.w	mod_nbrtrack(a0),d4
	subq.w	#1,d4		; d4 = compteur de boucles
	move.l	a3,a4		; a4 = adresse de la piste courante
.findtrack_loop:			; On va chercher la note
	cmp.w	midi_ts_channel(a4),d1	; C'est le bon canal?
	bne.s	.endif1		; Non, passe ton chemin
	cmp.w	midi_ts_note(a4),d5	; Y a d‚j… cette note?
	beq.s	.track_found	; Oui, on la remplace
	tst.w	midi_ts_velocity(a4)	; La piste est libre?
	beq.s	.track_found	; Oui, on y va
.endif1:	add.w	#midi_ts_next,a4
	dbra	d4,.findtrack_loop
	bra	gestmidi_data_loop_end

; -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
.track_found:
	move.w	d5,midi_ts_note(a4)	; Enregistre la note
	move.w	d0,midi_ts_velocity(a4)	; Sa v‚locit‚

	tst.w	((midi_in_velo_flag-2).l,d1.w*2)
	beq.s	.no_velo
	add.w	d0,d0		; Conversion V‚locit‚ -> Volume
	cmp.w	#255,d0		; Volume un peu trop fort?
	ble.s	.velo_ok
	move.b	#255,d0		; 255 maxi, bien s–r
.velo_ok:	move.b	d0,midi_ts_pat_volume(a4)	; Conversion en notes de pattern
.no_velo:	move.b	d5,midi_ts_pat_note(a4)
	clr.w	midi_ts_pat_effect(a4)	; Efface ‚galement l'effet, au cas
				; o— il y aurait eu un Note Cut juste avant
	move.w	midi_ts_channel(a4),d5	; Trouve l'instrument associ‚
	lea	midi_instr_map(pc),a5		; … ce canal
	move.b	-1(a5,d5.w*2),midi_ts_pat_instr(a4)
	clr.w	midi_ts_pat_effect(a4)

	or.w	#1,midi_ts_flags(a4)	; Mise … jour
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	Polyphonic Aftertouch					;
;----------------------------------------------------------------------------;
gestmidi_polyphonic_aftertouch:
	cmp.w	#2,d3		; Attend 2 octets de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	Control change					;
;----------------------------------------------------------------------------;
gestmidi_control_change:
	cmp.w	#2,d3		; Attend 2 octets de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	Program Change					;
;----------------------------------------------------------------------------;
gestmidi_program_change:
	cmp.w	#1,d3		; Attend 1 octet de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	Channel Aftertouch					;
;----------------------------------------------------------------------------;
gestmidi_channel_aftertouch:
	cmp.w	#1,d3		; Attend 1 octet de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	Pitch Bend						;
;----------------------------------------------------------------------------;
gestmidi_pitch_bend:
	cmp.w	#2,d3		; Attend 2 octets de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: System Exclusive				;
;----------------------------------------------------------------------------;
gestmidi_sm_system_exclusive:
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: MIDI Time Code Quarter Frame		;
;----------------------------------------------------------------------------;
gestmidi_sm_midi_time_code_quarter_frame:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Song Position Pointer			;
;----------------------------------------------------------------------------;
gestmidi_sm_song_position_pointer:
	cmp.w	#2,d3		; Attend 2 octets de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es

	move.w	midi_old_status(pc),midi_current_status
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Song Select				;
;----------------------------------------------------------------------------;
gestmidi_sm_song_select:
	cmp.w	#1,d3		; Attend 1 octet de donn‚e
	blt	gestmidi_data_loop_end
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es

	move.w	midi_old_status(pc),midi_current_status
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Undefined				;
;----------------------------------------------------------------------------;
gestmidi_sm_undefined:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Tune Request				;
;----------------------------------------------------------------------------;
gestmidi_sm_tune_request:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: End of Exclusive				;
;----------------------------------------------------------------------------;
gestmidi_sm_end_of_exclusive:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Timing Clock				;
;----------------------------------------------------------------------------;
gestmidi_sm_timing_clock:
	move.w	midi_old_status(pc),midi_current_status
	move.w	midi_old_nbrbytesrec(pc),midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	tst.w	midi_in_sync_flag(pc)
	beq	gestmidi_data_loop_end

	cmp.w	#MIDI_IN_MAX_TCLK,midi_in_sync_cpt	; On n'a pas trop de retard ?
	bgt.s	.too_late		; Si oui, tant pis, abandonne
	addq.w	#1,midi_in_sync_cpt

	bra	gestmidi_data_loop_end

.too_late:
	move.w	#1,midi_in_sync_cpt
	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Start					;
;----------------------------------------------------------------------------;
gestmidi_sm_start:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	tst.w	midi_in_sync_flag(pc)
	beq	gestmidi_data_loop_end

	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Continue				;
;----------------------------------------------------------------------------;
gestmidi_sm_continue:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	tst.w	midi_in_sync_flag(pc)
	beq	gestmidi_data_loop_end

	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: Stop					;
;----------------------------------------------------------------------------;
gestmidi_sm_stop:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	tst.w	midi_in_sync_flag(pc)
	beq	gestmidi_data_loop_end

	bra	gestmidi_data_loop_end



;----------------------------------------------------------------------------;
;	System Message: System Reset				;
;----------------------------------------------------------------------------;
gestmidi_sm_system_request:
	move.w	midi_old_status(pc),midi_current_status
	clr.w	midi_nbr_bytes_recvd	; On est prˆt … recevoir un autre flux de donn‚es
	bra	gestmidi_data_loop_end



*============================================================================*
*	R‚initialisation du Midi In				*
*============================================================================*
gestmidi_init_in:
	movem.l	d0/a0-a2,-(sp)

	move.w	#1,midi_current_channel	; 1 par d‚faut
	move.w	#-1,midi_current_status	; -1 = pas de status
	move.w	#-1,midi_old_status
	clr.w	midi_nbr_bytes_recvd		; Aucune donn‚e re‡ue

;--- Remet … 0 les status courant et la ligne de pattern … fabriquer ---------
	lea	midi_track_state(pc),a0
	moveq	#NBRVOIES_MAXI-1,d0
.init1loop:
	clr.w	midi_ts_channel(a0)	; Efface les num‚ro de canal
	clr.w	midi_ts_note(a0)	; remet … 0 l'activit‚ des notes
	clr.w	midi_ts_velocity(a0)
	clr.w	midi_ts_pitch(a0)
	clr.w	midi_ts_flags(a0)
	clr.b	midi_ts_pat_note(a0)	; Efface la note de pattern
	clr.b	midi_ts_pat_instr(a0)
	clr.b	midi_ts_pat_effect(a0)
	clr.b	midi_ts_pat_volume(a0)
	add.w	#midi_ts_next,a0
	dbra	d0,.init1loop

;--- Vide le buffer Midi -----------------------------------------------------
.init2loop:
	move.w	#3,-(sp)		; P‚riph‚rique: interface Midi
	move.w	#1,-(sp)		; Bconstat
	trap	#13
	addq.l	#4,sp
	tst.w	d0
	beq.s	.init2end		; Pas de nouvelles donn‚es Midi
	move.w	#3,-(sp)		; P‚riph‚rique: interface Midi
	move.w	#2,-(sp)		; Bconin
	trap	#13
	addq.l	#4,sp
	bra.s	.init2loop
.init2end:

;--- Cherche l'adresse du bloc IOREC -----------------------------------------
	move.w	#2,-(sp)		; MIDI
	move.w	#14,-(sp)		; Iorec
	trap	#14
	addq.l	#4,sp
	move.l	d0,midi_iorec_adr	; R‚cupŠre l'adresse du bloc

	movem.l	(sp)+,d0/a0-a2
	rts

	EndC





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	Data

adr_labels:	Dc.w	next_t			; Tout ‡a c'est pour le GfA
		Dc.l	nbrvoies,master_vol
		Dc.l	module_inf1+adr_samples,module_inf1+adr_module
		Dc.l	module_inf1+adr_instrset,module_inf1+adr_song
		Dc.l	module_inf1+adr_pattern
		Dc.l	module_inf2+mod_nbrtrack,mix_volume_e_t
		Dc.l	module_inf2+mod_songlen,module_inf2+mod_songrep
		Dc.l	module_inf2+mod_songpos,module_inf2+mod_numpat
		Dc.l	module_inf2+mod_linepos,module_inf2+mod_speed
		Dc.l	module_inf2+mod_nbrvbl
		Dc.l	info_track,repeatbuffer,flag_stop_voices
		Dc.l	mix_volume_t,flag_the_end,onoff_t,nbits_t,fech_t,curbal_t
		Dc.l	flag_mt_display,vblsize,module_inf2+mod_patrep,vblnumber
		Dc.l	replay_frequency
		Dc.l	module_inf1+adr_evol,module_inf1+adr_eton,module_inf1+adr_epan
		Dc.l	songrecord_state,songrecord_routine
		Dc.l	module_inf2+mod_tempo,interpol_t,adr_adr_inter
		Dc.l	current_play_mode,current_edit_mode
		Dc.l	midi_in_gfa_playline,midi_instr_map
		Dc.l	midi_track_state,midi_ts_next,new_note_buffer
		Dc.l	midi_in_noteoff_flag,midi_in_velo_flag
		Dc.l	midi_in_sync_flag,midi_in_sync_cpt,midi_in_on
		Dc.l	cpu_time_pourcent,flag_overflow

replay_frequency:	Dc.w	REPLAY_FREQ	; Fr‚quence de restitution

		; Table de sauts pour les effets. Certains sont
		; inutilis‚s, donc on se tire directement
fx_table_de_sauts1:	; 00xx - 0fxx
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
		Dc.l	fx_set_pan_env_ko,fx_fin1,fx_fine_sample_offset,fx_very_fine_sample_offset
		Dc.l	fx_inc_sample_pos,fx_dec_sample_pos,fx_init_autotempo,fx_init_autoperiod
		; c0xx - cfxx
		Dc.l	fx_fin1,fx_fin1,fx_set_trk_lin_vol,fx_set_trk_exp_vol
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fine_t_v_slup_e,fx_fine_t_v_sldown_e,fx_fin1,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1

fx_table_de_sauts1b:	; 0xxx - fxxx
		Dc.l	fx_fin1,fx_fin1,fx_set_lin_volume,fx_set_exp_volume
		Dc.l	fx_set_balance,fx_set_lin_master_vol,fx_set_exp_master_vol,fx_roll_7_init
		Dc.l	fx_roll_and_vsl_and_sbl_init,fx_fin1,fx_fin1,fx_fin1
		Dc.l	fx_fin1,fx_fin1,fx_fin1,fx_fin1

fx_table_de_sauts2:	; 00xx - 0fxx
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
		; c0xx - cfxx
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		Dc.l	fx_t_v_slup_l,fx_t_v_sldown_l,fx_t_v_slup_e,fx_t_v_sldown_e
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		Dc.l	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale

sin_table:				; Table de 64 sinus (0->2pi)
		Dc.w	$00,$18,$31,$4a,$61,$78,$8d,$a1
		Dc.w	$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		Dc.w	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5
		Dc.w	$b4,$a1,$8d,$78,$61,$4a,$31,$18
		Dc.w	-$00,-$18,-$31,-$4a,-$61,-$78,-$8d,-$a1
		Dc.w	-$b4,-$c5,-$d4,-$e0,-$eb,-$f4,-$fa,-$fd
		Dc.w	-$ff,-$fd,-$fa,-$f4,-$eb,-$e0,-$d4,-$c5
		Dc.w	-$b4,-$a1,-$8d,-$78,-$61,-$4a,-$31,-$18
square_table:			; Table d'onde carr‚e de 64 ‚l‚ments
		Dcb.w	32,$ff
		Dcb.w	32,-$ff
rampdown_table:			; Table d'onde triangulaire de 64 ‚l‚ments
	variable1:	Set	$ff
		Rept	64
		Dc.w	variable1
	variable1:	Set	variable1-8
		EndR

				; Table des p‚riodes de chaque note,
				; avec les finetunes de 0 … +7
per_tab_load:	IncBin	'pertable.bin'
per_table:		Equ	per_tab_load+24*2	; D‚calage de 24 finetunes avant le C-0
vexp_2_lin:	IncBin	'vexp2lin.bin'	; Les correspondances de volume pour instrument
vlin_2_exp:	IncBin	'vlin2exp.bin'
vexp_2_lin_master:	IncBin	'v_e2l_m.bin'	; Pareil, pour le master
vexp_2_lin_track:	IncBin	'v_e2l_t.bin'	; exp -> lin, pour le mix des pistes
vlin_2_exp_track:	IncBin	'v_l2e_t.bin'	; lin -> exp, pour le mix des pistes
		Even
routine_dsp:	IncBin	'playdsp.p56'	; Prog DSP
routine_dsp_lon:
		Even



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

;--- Bloc de descritption de l'‚tat actuel de chaque voie --------------------
		RsReset
onoff_t:		Rs.w	1	; 0 = voie off, 1 = voie on
nbits_t:		Rs.w	1	; 1 = 8 bits, 2 = 16 bits
fech_t:		Rs.w	1	; Fr‚quence d'‚chantillonnage du sample (8363 Hz par d‚faut)
vol_t:		Rs.w	1	; Volume courant (0-$800)
bal_t:		Rs.w	1	; Balance courante ($000..$800..$FFF)
per_t:		Rs.w	1	; P‚riode courante (format "soundtracker" * $10)
adrsam_t:		Rs.l	1	; Adresse du sample, paire
pos_t:		Rs.l	1	; Position dans le sample
finepos_t:		Rs.w	1	; Position pr‚cise (1/65536)
reppos_t:		Rs.l	1	; Position de r‚p‚tition du sample, paire
replen_t:		Rs.l	1	; Longueur de bouclage du sample	, paire
rbuffer_t:		Rs.l	1	; Adresse du buffer de r‚p‚tition de l'instrument
protect_t:		Rs.w	1	; *** pas d'utilit‚ ici (sert pour les routines s‚par‚es)
interpol_t		Rs.w	1	; 0 = pas d'interpolation pour le mixage de cette voie
	; C'‚tait tout ce dont la partie "mixage" avait besoin.
	; Maintenant, ce dont le player a besoin :
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
portspd_t:		Rs.w	1	; Vitesse du Portamento
tportspd_t:	Rs.w	1	; Vitesse du Tone Portamento
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
delay_t:		Rs.w	1	; Nbr de frames … attendre avant de jouer la note
cut_del_t:		Rs.w	1	; Nbr de frames … attendre avant de couper la note
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
current_rs:
		rs.b	current_rs&1	; Equivaut … RsEven
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
current_rs2:
		rs.b	current_rs2&1	; Equivaut … RsEven
ep_waitcpt_t:	Rs.w	1	; Compteur de la commande Wait de l'enveloppe de panning
ep_loopcpt_t:	Rs.w	1	; Compteur de boucle
ep_pan_t:		Rs.w	1	; Panning courant
ep_panstep_t:	Rs.w	1	; Pas du panning
ep_panspeed_t:	Rs.w	1	; Vitesse du panning
ep_pancpt_t:	Rs.w	1	; Compteur du panning
current_rs3:
		rs.b	current_rs3&1	; Equivaut … RsEven
flag_new_note_t:	Rs.w	1	; 1 si la note courante doit ˆtre "initialis‚e"
				; 0 si ‡a a d‚j… ‚t‚ fait (vbl suivante).
flag_autotempo_t:	Rs.w	1	; 1 au 1er tick, 0 sinon.
flag_autoperiod_t:	Rs.w	1	; 1 au 1er tick, 0 sinon.
mix_volume_t:	Rs.w	1	; Volume normal lin‚aire: $1000
mix_volume_e_t:	Rs.w	1	; Volume normal exponentiel: $C00
ltvolslspd_t:	Rs.w	1	; Incr‚ment du Linear track volume slide
etvolslspd_t:	Rs.w	1	; Incr‚ment de l'Exponential track volume slide
fetvolslspd_t:	Rs.w	1	; Incr‚ment du Fine exponential track volume slide
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
chunkid_p:		Rs.l	1
chunksz_p:		Rs.l	1
number_p:		Rs.w	1
name_p:		Rs.b	16
codagev_p:		Rs.w	1
nlines_p:		Rs.w	1
ntrack_p:		Rs.w	1
data_p:		Rs	0

;--- Chunk de description des enveloppes -------------------------------------
		RsReset
chunkid_e:		Rs.l	1	; 'VENV', 'PENV' ou 'TENV'
chunksz_e:		Rs.l	1	; Taille du chunk
number_e:		Rs.w	1	; Num‚ro de l'enveloppe
name_e:		Rs.b	20	; Nom de l'enveloppe
keyoffoffset_e:	Rs.w	1	; Offset de la section Key Off par rapport … data_e
data_e:		Rs	0	; D‚but des donn‚es de l'enveloppe

;--- Diverses adresses -------------------------------------------------------
		RsReset
adr_samples:	Rs.l	NBRSAMPLES_MAXI	; Adresse de 256 samples maxi (… partir de 0)
adr_pattern:	Rs.l	NBRPATTERNS_MAXI	; Adresse de 256 patterns + 2 pour les patterns bidons
adr_module:	Rs.l	1	; Adresse du module en m‚moire
adr_instrset:	Rs.l	1	; Adresse du descripteur des instruments (en partant de 0)
adr_evol:		Rs.l	NBRVOLENV_MAXI	; Adresse de 64 enveloppes de volume
adr_eton:		Rs.l	NBRTONENV_MAXI	; Adresse de 64 enveloppes de tonalit‚
adr_epan:		Rs.l	NBRPANENV_MAXI	; Adresse de 64 enveloppes de panning
adr_song:		Rs.l	1	; Adresse de la song
adr_next:		Rs	0

;--- Bloc de renseignements sur le module en cours ---------------------------
		RsReset
mod_nbrtrack:	Rs.w	1	; Nombre de pistes par pattern
mod_songlen:	Rs.w	1	; Taille de la song
mod_songrep:	Rs.w	1	; Point de r‚p‚tition
mod_songpos:	Rs.w	1	; Num‚ro de la position suivante dans la song
mod_numpat:	Rs.w	1	; Num‚ro du pattern courant
mod_linepos:	Rs.w	1	; Num‚ro de position de la ligne suivante
mod_cursongpos:	Rs.w	1	; Num‚ro de la position actuelle
mod_curlinepos:	Rs.w	1	; Num‚ro de la ligne actuelle
mod_flagnewpos:	Rs.w	1	; -1 si la position a ‚t‚ chang‚e par un Pos Jump, 0 sinon
mod_flagnewline:	Rs.w	1	; -1 si la ligne a ‚t‚ chang‚e par un Break Pattern, 0 sinon
mod_speed:		Rs.w	1	; Vitesse courante (ticks/ligne)
mod_patrep:	Rs.w	1	; Nombre de r‚p‚titions de la ligne
mod_nbrvbl:	Rs.w	1	; Nombre de ticks ‚coul‚es depuis le d‚but de la ligne
mod_tempo:		Rs.w	1	; Tempo en BPM
mod_next:		Rs	0

;--- Informations sur un sample … digitaliser --------------------------------
		RsReset
rec_adresse:	Rs.l	1	; Adresse de d‚but d'enregistrement
rec_longueur:	Rs.l	1	; Longueur du sample … ‚chantillonner
rec_position:	Rs.l	1	; Position courante d'‚chantillonnage
rec_flag_loop:	Rs.w	1	; bit 0 = Echantillonner en boucle (jusqu'… demande d'arrˆt)
				; bit 1 = Indique si on a d‚j… boucl‚
rec_nbits:		Rs.w	1	; Nombre d'octets par sample (1 ou 2)
rec_canal:		Rs.w	1	; Canal d'enregistrement (1=L, 2=R, 3=L+R).
rec_trigger:	Rs.w	1	; Valeur mini … recevoir pour commencer l'‚ch. (/32768)
rec_frequence:	Rs.w	1	; Fr‚quence CODEC (valeur.w … placer en $FFFF8934)

		IfNE	MIDI_IN

;--- Pour chaque piste du tableau d'entr‚es Midi -----------------------------
		RsReset
midi_ts_channel:	Rs.w	1	; Num‚ro du canal Midi auquel est associ‚ cette piste
midi_ts_velocity:	Rs.w	1	; V‚locit‚ (0-128), (0 ou -1) = piste libre, -1 = Note off … l'instant
midi_ts_note:	Rs.w	1	; Hauteur de la note
midi_ts_pitch:	Rs.w	1	; Hauteur du pitch
midi_ts_flags:	Rs.w	1	; Bit 0 = mise … jour de la note
midi_ts_pat_note:	Rs.b	1	; \ Note ‚quivalente dans le pattern
midi_ts_pat_instr:	Rs.b	1	;  \
midi_ts_pat_effect:	Rs.w	1	;  / *** Ne pas dissocier
midi_ts_pat_volume:	Rs.b	1	; /
current_rs4:
		rs.b	current_rs4&1	; Equivaut … RsEven
midi_ts_next:	Rs	0

;--- Structure IOREC ---------------------------------------------------------
		RsReset
iorec_ibuf:	Rs.l	1	; Adresse du buffer
iorec_ibufsz:	Rs.w	1	; Taille du buffer
iorec_ibufhd:	Rs.w	1	; Prochaine position d'‚criture
iorec_ibuftl:	Rs.w	1	; Prochaine position de lecture
iorec_ibuflow:	Rs.w	1	; Masque pour Xon
iorec_ibufhi:	Rs.w	1	; Masque pour Xoff

		EndC



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	Bss

nbrvoies:		Ds.w	1	; Nombre de voies … mixer
dsp_ability:	Ds.w	1	; Num‚ro de programme pour le DSP
current_track:	Ds.w	1	; Piste courante
dsp_plein:		Ds.w	1	; A 0 si aucune voie n'a ‚t‚ envoy‚e.
master_vol:	Ds.w	1	; Le master volume (0 - $1000), $100 pour 16 voies
vblsize:		Ds.w	1	; Nbr de samples/VBL (1000 en moyenne) \ * Ne pas
vblsize_frac:	Ds.w	1	; Pr‚cision fractionnaire              / dissocier !!!
vblcurrentsize:	Ds.w	1	; Nbr de samples/VBL pour cette VBL   \ * Ne pas
vblcurrentsize_frac:	Ds.w	1	; Compteur en pr‚cision fractionnaire / dissocier !!!
vblnumber:		Ds.w	1	; Nbr de VBL pour tenir un tick
vblcpt:		Ds.w	1	; Compteur de VBL
cpu_time_pourcent:	Ds.w	1	; Pourcentage de temps machine occup‚
new_note_buffer:	Ds.b	NBRVOIES_MAXI*6	; Notes en attente pour la
				; prochaine ligne (1 flag + 5 octets de note)
flag_stop_voices:	Ds.w	1	; 1 = Faire taire les voies, attendre le retour
				; … 0 avant de changer les paramŠtres de la song
flag_the_end:	Ds.w	1	; 1 = On arrˆte le replay
flag_mt_display:	Ds.w	1	; 1 = affiche les bandes de temps-machine
flag_new_notes:	Ds.w	1	; 1 = On a des notes … rajouter (new_note_buffer)
flag_overflow:	Ds.w	1	; 1 = il y a eu surcharge des voies.
				; Ce flag n'est pas remis automatiquement … 0
current_edit_mode:	Ds.w	1	; 0 = rien, 1 = Edit
current_play_mode:	Ds.w	1	; 0 = stop, 1 = Play song, 2 = Play Pattern
real_pattern_number:	Ds.w	1	; Num‚ro r‚el du pattern courant (Edit Mode/Stop)
real_line_number:	Ds.w	1	; Num‚ro r‚el de la ligne courante (Edit Mode/Stop)
sauvegarde_timer:	Ds.l	1	; Adresse de l'ancien timer A, C ou D
adresse_interruption:	Ds.l	1	; Adresse de l'interruption (doit contenir
				; soundtracking_kernel)
adr_adr_inter:	Ds.l	1	; Contient adresse_interruption ou le vecteur DSP

		IfNE	MIDI_IN
midi_in_on:	Ds.w	1	; 1 = Gestion MIDI IN
midi_in_gfa_playline:	Ds.w	1	; 1 = Signale au GfA que le MIDI a re‡u des notes
				; en mode Edit sans Play.
midi_in_sync_flag:	Ds.w	1	; 1 = Syncronisation en entr‚e
midi_in_sync_cpt:	Ds.w	1	; Compteur d'impulsions entre chaque ligne
midi_current_status:	Ds.w	1	; Num‚ro du status Midi courant
midi_old_status:	Ds.w	1	; Num‚ro du status Midi avant un System Message
midi_current_channel:	Ds.w	1	; Num‚ro du canal Midi courant
midi_nbr_bytes_recvd:	Ds.w	1	; Nombre d'octets de donn‚e d‚j… re‡us
midi_old_nbrbytesrec:	Ds.w	1	; Nombre d'octets re‡us avant un System Message
midi_iorec_adr:	Ds.l	1	; Adresse du bloc IOREC
midi_data_buffer:	Ds.b	MIDI_IN_DATA_BUF_LEN	; Octet de status + octets des donn‚es
midi_instr_map:	Ds.w	MIDI_NBR_CHANNELS	; Instrument du tracker assign‚ … chaque canal
midi_in_noteoff_flag:	Ds.w	MIDI_NBR_CHANNELS	; 0 = Note Off totalement ignor‚
					; 1 = Note Off pris en compte mais non transcrit sur la partition
					; -1 = Note Off mis sur les patterns
midi_in_velo_flag:	Ds.w	MIDI_NBR_CHANNELS	; 0 = V‚locit‚ ignor‚e
					; -1 = V‚locit‚ mise sur les patterns
midi_track_state:	Ds.b	NBRVOIES_MAXI*midi_ts_next	; Activit‚ des pistes
		EndC

;*** v--- Ne pas changer l'ordre de ce groupe ---v *** (… cause du GfA)
songrecord_state:	Ds.w	1	; Etat de l'enregistrement d'un module via le DMA
songrecord_startpos:	Ds.w	1	; Position de d‚but de l'enregistrement
songrecord_startline:	Ds.w	1	; Ligne de d‚but de l'enregistrement
songrecord_endpos:	Ds.w	1	; Position de fin de l'enregistrement
songrecord_endline:	Ds.w	1	; Ligne de fin de l'enregistrement
songrecord_startadr:	Ds.l	1	; Adresse de d‚but du buffer
songrecord_endadr:	Ds.l	1	; Adresse de fin du buffer
songrecord_state2:	Ds.w	1	; 0 = On peut enregistrer au prochain passage
				; 1 = il reste 1 boucle … faire avant d'enregistrer
songrecord_lastadr:	Ds.l	1	; Adresse courante du buffer quand l'enregistrement
				; se termine
songrecord_prediv:	Ds.w	1	; Pr‚diviseur de fr‚quence DMA pour la vitesse de rec.
songrecord_recfreq:	Ds.w	1	; Fr‚quence d'‚chantillonnage en Hz
songrecord_sprediv:	Ds.w	1	; Sauvegarde de l'ancien pr‚diviseur
songrecord_srecfreq:	Ds.w	1	; Sauvegarde de l'ancienne fr‚quence de replay
songrecord_realtime:	Ds.w	1	; 0 = sans ‚coute, 1 = temps r‚el (synchro MIDI possible)
songrecord_bufpos:	Ds.l	1	; Position dans le buffer d'enregistrement
songrecord_flag:	Ds.w	1	; 0 = mode normal, 1 = mode d'enregistrement diff‚r‚
songrecord_flag2:	Ds.w	1	; 0 = pas de donn‚e re‡ue, 1 = on peut faire le dump

module_inf1:	Ds.b	adr_next
module_inf2:	Ds.b	mod_next
info_track:	Ds.b	NBRVOIES_MAXI*next_t	; Informations sur les 32 voies (maxi)
sample_vide:	Ds.l	1	; Un sample vide
repeatbuffer:	Ds.b	NBRSAMPLES_MAXI*1024	; Buffers de r‚p‚tition de 255 samples maxi + 1 vide



*÷÷÷ FIN ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
