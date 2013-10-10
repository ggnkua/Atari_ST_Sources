	xdef	gtk_init
	xdef	gtk_open
	xdef	gtk_close
	xdef	gtkr_init_kernel

*÷÷÷ Constantes ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

;--- Contr“le du Noyau -------------------------------------------------------

REPLAY_FREQ			EQU	49170	; Fr‚quence de base de replay en Hz
NBRVOIES_MAXI		EQU	32	; Nombre maximum de voies, on peut
INTERRUPTION_TYPE	EQU	0	; 0 = Interruption DSP, 1 = Timer A
	IFEQ	INTERRUPTION_TYPE
DSP_EXCEPTION		EQU	255	; Num‚ro du vecteur de l'exception DSP
	ENDC

FLAG_MT_DISP		EQU	0	; 0 = rien

	IFNE	FLAG_MT_DISP
NCOLOR_MT_DISP		EQU	0	; Couleur … modifier pour afficher le temps machine (14)
	ENDC

CONST_T				EQU	1	; 0 = Taille minimale pour les descripteurs de voies
	IFNE	CONST_T
USER_T				EQU	$40	; Dans les descripteur de voies, donne la position
TOTAL_T				EQU	$100	; Taille d'un descripteur d'une voie
	ENDC

;--- Contr“le du Soundtracker ------------------------------------------------

NBRSAMPLES_MAXI		EQU	255+1	; Nombre maximum de samples (+1 vide)
CHECK				EQU	2	; 0 = aucune v‚rification (+ rapide - fiable)

;--- Adresses ----------------------------------------------------------------

	IFNE	INTERRUPTION_TYPE
MFPST_INT_TIMERA	EQU	$134
MFPIERA				EQU	$fffffa07
MFPIERB				EQU	$fffffa09
MFPISRA				EQU	$fffffa0f
MFPISRB				EQU	$fffffa11
MFPIMRA				EQU	$fffffa13
MFPIMRB				EQU	$fffffa15
MFPTACR				EQU	$fffffa19
MFPTBCR				EQU	$fffffa1b
MFPTCDCR			EQU	$fffffa1d
MFPTADR				EQU	$fffffa1f
MFPTBDR				EQU	$fffffa21
MFPTCDR				EQU	$fffffa23
MFPTDDR				EQU	$fffffa25
	ENDC

DSPHCR		EQU	$ffffa200	; Host Control Register
DSPHSR		EQU	$ffffa202	; Host Status Register
DSPIVR		EQU	$ffffa203	; Interrupt Vector register
DSPHRDR_L		EQU	$ffffa204	; Host Receive Data Register (Long)
DSPHTDR_L		EQU	$ffffa204	; Host Transmit Data Register (Long)
DSPHRDR_3		EQU	$ffffa205	; Host Receive Data Register (24 bits)
DSPHTDR_3		EQU	$ffffa205	; Host Transmit Data Register (24 bits)
DSPHRDR_W		EQU	$ffffa206	; Host Receive Data Register (Word)
DSPHTDR_W		EQU	$ffffa206	; Host Transmit Data Register (Word)
DSPHRDR_B		EQU	$ffffa207	; Host Receive Data Register (Byte)
DSPHTDR_B		EQU	$ffffa207	; Host Transmit Data Register (Byte)

PLAYINT		EQU	$ffff8900
PLAYMOD		EQU	$ffff8901
TRAKCTRL		EQU	$ffff8920
SAMPMOD		EQU	$ffff8921
SDMATRIX		EQU	$ffff8930	; Source Device Matrix
DDMATRIX		EQU	$ffff8932	; Destination Device Matrix
FDECLOCK		EQU	$ffff8934	; FrEQUency Diviser External Clock
FDISYNC		EQU	$ffff8935	; FrEQUency Diviser Internal Sync

FCOLOR00		EQU	$ffff9800	; Falcon Color $0
FC_RED		EQU	$ff000000	; Rouge
FC_GREEN		EQU	$00ff0000	; Vert
FC_BLUE		EQU	$000000ff	; Bleu


*÷÷÷ Structure ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

;--- Bloc de descritption de l'‚tat actuel de chaque voie --------------------

;úúú Partie r‚serv‚e au noyau úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
					;	RsReset
onoff_t		EQU	0	;	Rs.w	1	; 0 = voie off, 1 = voie on
nbits_t		EQU 2	;	Rs.w	1	; 1 = 8 bits, 2 = 16 bits
fech_t		EQU 4	;	Rs.w	1	; Fr‚quence d'‚chantillonnage du sample (8363 Hz par d‚faut)
vol_t		EQU 6	;	Rs.w	1	; Volume courant (0-$800)
bal_t		EQU	8	;	Rs.w	1	; Balance courante ($000..$800..$FFF)
per_t		EQU	10	;	Rs.w	1	; P‚riode courante (format "soundtracker" * $10)
adrsam_t	EQU	12	;	Rs.l	1	; Adresse du sample, paire
pos_t		EQU	16	;	Rs.l	1	; Position dans le sample, paire
finepos_t	EQU	20	;	Rs.w	1	; Position pr‚cise (1/65536)
reppos_t	EQU	22	;	Rs.l	1	; Position de r‚p‚tition du sample, paire
replen_t	EQU	26	;	Rs.l	1	; Longueur de bouclage du sample	, paire
rbuffer_t	EQU 30	;	Rs.l	1	; Adresse du buffer de r‚p‚tition de l'instrument
protect_t	EQU	34	;	Rs.w	1	: 0 = voie non prot‚g‚, sinon num‚ro de la protection

;úúú Partie utilisateur (soundtracker en l'occurence) úúúúúúúúúúúúúúúúúúúúúúúú
;	IFNE	CONST_T
;	RsSet	USER_T
;	ENDC
c_n_t		EQU	$40		;	Rs.w	1	; La note dans la ligne de commande          \
c_i_t		EQU	$40+2	;	Rs.w	1	; L'instrument dans la ligne de commande      > * Ne pas dissocier
c_e_t		EQU	$40+4	;	Rs.w	1	; L'effet+paramŠtre dans la ligne de commande/
c_v_t		EQU	$40+6	;	Rs.w	1	; Le volume dans la ligne de commande       /
ninstr_t	EQU	$40+8	;	Rs.w	1	; Num‚ro de l'instrument courant
norm_v_t	EQU	$40+10	;	Rs.w	1	; Le volume par d‚faut de l'instrument (0-$100)\ * Ne pas dissocier
norm_f_t	EQU	$40+12	;	Rs.w	1	; Finetune de l'instrument                     /
curnote_t	EQU	$40+14	;	Rs.w	1	; La note courante
pernote_t	EQU	$40+16	;	Rs.w	1	; P‚riode courante (sans effet de vibrato)
vollnot_t	EQU	$40+18	;	Rs.w	1	; Volume courant lin‚aire (sans tremolo) (0-$800)
volenot_t	EQU	$40+20	;	Rs.w	1	; Volume courant exponentiel (sans tremolo)
portspd_t	EQU	$40+22	;	Rs.w	1	; Vitesse de tone portamento
note2sl_t	EQU	$40+24	;	Rs.w	1	; Note … atteindre en cas de slide
per2sl_t	EQU	$40+26	;	Rs.w	1	; P‚riode de la note … atteindre en cas de tone porta
vibspd_t	EQU	$40+28	;	Rs.b	1	; Vitesse du vibrato
vibcpt_t	EQU	$40+29	;	Rs.b	1	; Compteur du vibrato
vibamp_t	EQU	$40+30	;	Rs.b	1	; Amplitude du vibrato
vibwav_t	EQU	$40+31	;	Rs.b	1	; Forme d'onde du vibrato
tremspd_t	EQU	$40+32	;	Rs.b	1	; Vitesse du tremolo
tremcpt_t	EQU	$40+33	;	Rs.b	1	; Compteur du tremolo
tremamp_t	EQU	$40+34	;	Rs.b	1	; Amplitude du tremolo
tremwav_t	EQU	$40+35	;	Rs.b	1	; Forme d'onde du tremolo
rollspd_t	EQU	$40+36	;	Rs.b	1	; Vitesse des roulements
rollcpt_t	EQU	$40+37	;	Rs.b	1	; Compteur de roulements
rollnbr_t	EQU	$40+38	;	Rs.w	1	; Nbr de roulements encore … jouer
delay_t		EQU	$40+40	;	Rs.w	1	; Nbr de ticks … attendre avant de jouer la note
cut_del_t	EQU	$40+42	;	Rs.w	1	; Nbr de ticks … attendre avant de couper la note
tremorc_t	EQU	$40+44	;	Rs.w	1	; Compteur de tremor
tremor1_t	EQU	$40+46	;	Rs.b	1	; Nbr de frames o— la note n'est pas coup‚e
tremor2_t	EQU	$40+47	;	Rs.b	1	; P‚riode d'un tremor
ploopp_t	EQU	$40+48	;	Rs.w	1	; Point de r‚p‚tition pour l'effet Pattern loop
ploopn_t	EQU	$40+50	;	Rs.w	1	; Nombre de r‚p‚titions pour l'effet Pattern loop
;	IFNE	CONST_T
;	RsSet	TOTAL_T
;	ENDC
next_t		EQU	$100	;	Rs.w	1

;--- Diverses adresses … modifier lors d'un changement de module -------------
;												RsReset
adr_samples		EQU	0						;	Rs.l	NBRSAMPLES_MAXI	; Adresse de 256 samples maxi (… partir du sample 0)
adr_repbuf		EQU	NBRSAMPLES_MAXI*4		;	Rs.l	NBRSAMPLES_MAXI	; Adresse de 256 buffers de bouclage (… partir du sample 0)
adr_song		EQU	NBRSAMPLES_MAXI*8		;	Rs.l	1	; Adresse de la song
adr_pattern		EQU	4+(NBRSAMPLES_MAXI*8)	;	Rs.l	1	; Adresse des patterns
adr_instrheader	EQU	8+(NBRSAMPLES_MAXI*8)	;	Rs.l	1	; Adresse du descripteur des instruments (en partant de 0)
adr_next		EQU	12+(NBRSAMPLES_MAXI*8)

;--- Bloc de renseignements sur le module en cours ---------------------------
;							RsReset
mod_nbrtrack	EQU	0	;	Rs.w	1	; Nombre de pistes par pattern
mod_nbrlines	EQU	2	;	Rs.w	1	; Nombre de lignes par pattern
mod_songlen		EQU	4	;	Rs.w	1	; Taille de la song
mod_songrep		EQU	6	;	Rs.w	1	; Point de r‚p‚tition
mod_songpos		EQU	8	;	Rs.w	1	; Num‚ro de position dans la song (prochaine)
mod_numpat		EQU	10	;	Rs.w	1	; Num‚ro du pattern (actuel)
mod_linepos		EQU	12	;	Rs.w	1	; Num‚ro de position de la ligne (prochaine)
mod_cursongpos	EQU	14	;	Rs.w	1	; Songpos (actuelle)
mod_curlinepos	EQU	16	;	Rs.w	1	; Linepos (actuelle)
mod_speed		EQU	18	;	Rs.w	1	; Vitesse courante (ticks/ligne)
mod_patrep		EQU	20	;	Rs.w	1	; Nombre de r‚p‚titions de la ligne
mod_nbrticks	EQU	22	;	Rs.w	1	; Nombre de ticks ‚coul‚s depuis le d‚but de la ligne
mod_vblnumber	EQU	24	;	Rs.w	1	; Nbr de VBL pour tenir un tick
mod_vblcpt		EQU	26	;	Rs.w	1	; Compteur de VBL
mod_next		EQU	28	;	Rs.w	1

;--- Bloc de description des samples (au d‚but d'un module .GTK) -------------
;				RsReset
name_s			EQU	0	;	Rs.b	28	; Nom du sample
						;	Rs.w	7	; R‚serv‚ pour les ‚volutions suivantes
autobal_s		EQU	42	;	Rs.w	1	; Balance automatique, -1 = rien
nbits_s			EQU	44	;	Rs.w	1	; 1 = 8 bits, 2 = 16 bits               *** Ne pas dissocier \
fech_s			EQU	46	;	Rs.w	1	; Fr‚quence d'‚chantillonnage du sample (8363 Hz par d‚faut) /
length_s		EQU	48	;	Rs.l	1	; Longueur du sample
repeat_s		EQU	52	;	Rs.l	1	; Point de bouclage
replen_s		EQU	56	;	Rs.l	1	; Longueur de boucle
vol_s			EQU	60	;	Rs.w	1	; Volume   \ *** Ne pas dissocier
ftune_s			EQU	62	;	Rs.w	1	; Finetune /
next_s			EQU	64	;	Rs.w	1


*÷÷÷ Macros ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

MACRO	writhost				; Macro d'attente de la disponibilit‚
	LOCAL	.wrhst
.wrhst:	btst	#1,DSPHSR.w	; du port HOST en ‚criture
	beq.s	.wrhst
	ENDM

MACRO	readhost
	LOCAL	.rdhst				; Idem en lecture
.rdhst:	btst	#0,DSPHSR.w
	beq.s	.rdhst
	ENDM

;--- Celle-l… c'est pour le prg d'exemple ------------------------------------

MACRO	waitakey
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*


gtk_init:
	movem.l	d1-a6,-(a7)

;ððð Exemple d'utilisation ððððððððððððððððððððððððððððððððððððððððððððððððððð

	move.l	#gtkr_info_track,-(sp)
	move.w	#NBRVOIES_MAXI,-(sp)	; 32 tracks maxi
	bsr	gtkr_kernel_on	; Installe le noyau
	addq.l	#6,sp

;--- Exemple de replay d'un module -------------------------------------------

	bsr	gtkr_player_on	; Installe le player
	movem.l	(a7)+,d1-a6
	tst.l	d0
	bmi	gtk_close
	rts

gtk_open:
	movem.l	d1-a6,-(a7)
;	pea	module_gtk		; Convertit le module au format interne
;	pea	module_gtk
	move.l	a0,mod_ptr
	pea	(a0)
	pea	(a0)
	move.w	#0,-(sp)		; *** 0 = GTK, 1 = MOD ***
	bsr	gtkr_convert_module
	lea	10(sp),sp
	tst.l	d0
	bmi	gtk_close

	pea	0.l		; Pr‚pare les samples du module en calculant les
	pea	repeatbuffer	; buffers de bouclage
;	pea	module_gtk
	move.l	mod_ptr,-(a7)
	bsr	gtkr_make_rb_module
	lea	12(sp),sp
	tst.l	d0
	bmi	gtk_close

	clr.w	-(sp)		; Pof, on fait tourner tout ‡a
	clr.w	-(sp)
	pea	repeatbuffer
;	pea	module_gtk
	move.l	mod_ptr,-(a7)
	bsr	gtkr_new_module
	lea	12(sp),sp
	movem.l	(a7)+,d1-a6
	tst.l	d0
	bmi	gtk_close

	rts

gtk_close:
	movem.l	d1-a6,-(a7)
	bsr	gtkr_kernel_off	; Arrˆte le noyau
	movem.l	(a7)+,d1-a6
	rts


mod_ptr:	dc.l	0


******************************************************************************
**						          **
*	BibliothŠque des fonctions de contr“le du noyau sonore		*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Tout accŠs … des donn‚es du noyau ne devra se faire que par	*
*	les fonctions ci-dessous, ou par des adresses communiqu‚es	*
**	par ces routines.				          **
******************************************************************************



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Installe le noyau					;
;	ParamŠtres : 					;
;	- W nbrtrack : Nombre maxi de piste. 1 ó nbrtrack ó 32.	;
;	- L adrbloc : Adresse d'un bloc contenant des infos sur les	;
;		voies. La longueur totale du bloc est		;
;		nbrtrack * next_t.				;
;	Renvoie 0 si pas d'erreur.				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_on:
	movem.l	d1-a5,-(sp)
	tst.w	gtkr_flag_installed	; D‚j… install‚ ?
	bne	.error
	move.w	0+52+4(sp),gtkr_nbrvoies
	move.l	2+52+4(sp),gtkr_adr_info_track
	clr.w	gtkr_current_track
	clr.w	gtkr_dsp_plein

	move.w	#$100,-(sp)	; *** Ici r‚glage pour 8 voies
	bsr	gtkr_set_master_vol	; Th‚orique et s–r : 4096 / nbr de voies
	addq.l	#2,sp		; Le mieux c'est 12288 / (nbr de voies + 4)

	move.w	#REPLAY_FREQ*60/125/4/6,-(sp)	; Repfreq * 60 sec / 125 bpm / 4 lignes / 6 ticks
	bsr	gtkr_set_vblsize
	addq.l	#2,sp

	bsr	gtkr_reset_kernel_tracks	; Reset de toutes les voies

	pea	gtkr_init_kernel	; Ca, c'est pour commencer … jouer
	move.w	#$26,-(sp)		; Ex‚cute 'init_mod_player' en
	trap	#14		; superviseur
	addq.l	#6,sp
	move.w	#1,gtkr_flag_installed
	moveq	#0,d0		; Pas d'erreur, c'est la sueur
	bra.s	.fin

.error:	moveq	#-1,d0

.fin:	movem.l	(sp)+,d1-a5
	rts

;ððð Routine superviseur, d‚marre le programme DSP ððððððððððððððððððððððððððð
gtkr_init_kernel:
	movem.l	d0-a5,-(sp)
	clr.w	gtkr_flag_the_end
	IFNE	FLAG_MT_DISP
	move.l	FCOLOR00+NCOLOR_MT_DISP*4.w,gtkr_color_mt_disp
	ENDC

;--- Charge la routine DSP en m‚moire DSP ------------------------------------
;	pea	gtkr_routine_dsp
;	pea	lod_name
;	move.w	#$6f,-(sp)		; LOD -> bin
;	trap	#14
;	lea	10(sp),sp
;	move.l	d0,gtkr_routine_dsp_lon
	move.l	#(gtkr_routine_dsp_end-gtkr_routine_dsp)/3,gtkr_routine_dsp_lon

	move.w	#$71,-(sp)		; DSP rEQUest ability
	trap	#14
	addq.l	#2,sp

	move.w	d0,-(sp)
	move.l	gtkr_routine_dsp_lon,-(sp)	; La longueur
	pea	gtkr_routine_dsp
	move.w	#$6d,-(sp)		; Charge le prog en m‚moire DSP
	trap	#14
	lea	12(sp),sp

	move.l	#$902000,SDMATRIX.w	; Connecte le DSP … la matrice
	move.w	#$101,FDECLOCK.w	; 50 KHz. Vous pouvez mettre une autre fr‚quence,
	move.w	#$500,PLAYINT.w	; ce qui permettra + de voies mais - de qualit‚.
	move.w	#$3,TRAKCTRL.w	; Dans ce cas n'oubliez pas de changer le EQU du d‚but.

;--- Initialise l'interruption -----------------------------------------------
	IFEQ	INTERRUPTION_TYPE	; Interruption DSP
	move.b	#DSP_EXCEPTION,DSPIVR.w	; Num‚ro de l'exception d‚clench‚e lors de la
	move.l	#gtkr_kernel_interruption,DSP_EXCEPTION*4.w	; r‚ception d'une donn‚e par le port Host
	move.b	#1,DSPHCR.w	; Autorise l'interruption

	ELSE			; Interruption Timer A
	move.l	MFPST_INT_TIMERA.w,gtkr_sauvegarde_timer_a
	bclr	#5,MFPIMRA.w	; Timer A masqu‚
	bset	#5,MFPIERA.w	; Timer A autoris‚
	move.b	#6,MFPTACR.w	; 1/100 : 24576 Hz
	move.b	#3,MFPTADR.w	; /3 : 8192 Hz
	move.l	#gtkr_interruption_timer_a,MFPST_INT_TIMERA.w
	bset	#5,MFPIMRA.w	; Timer A d‚masqu‚
	ENDC

	writhost
	move.l	#$0,DSPHTDR_L.w	; C'est parti mon kiki!

	movem.l	(sp)+,d0-a5
	rts

	IFNE	INTERRUPTION_TYPE
;ððð Routine sous Timer A si celui-ci est choisi ððððððððððððððððððððððððððððð
gtkr_interruption_timer_a:
	btst	#0,DSPHSR.w	; Une donn‚e a ‚t‚ envoy‚e par le DSP ?
	bne	gtkr_kernel_interruption	; Oui, faut y aller
	bclr	#5,MFPISRA.w	; Sinon on attend le prochain coup
	rte
	ENDC



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	D‚sinstalle le noyau.					;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_off:
	tst.w	gtkr_flag_installed
	beq.s	.error		; Pas install‚

	move.w	#1,gtkr_flag_the_end	; Ordre d'arret du noyau
.loop:	tst.w	gtkr_flag_the_end	; Attend qu'il se soit d‚sinstall‚
	bne.s	.loop
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0

.fin:	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande si le noyau est install‚				;
;	Renvoie 0 dans d0.w s'il ne l'est pas, et 1 s'il l'est.	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_kernel_status:
	move.w	gtkr_flag_installed,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Reset de toutes les voies du noyau			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_reset_kernel_tracks:
	movem.l	d1-a5,-(sp)

	move.w	gtkr_nbrvoies,d3
	subq.w	#1,d3
.loop:
	move.w	d3,-(sp)
	bsr	gtkr_free_track
	addq.l	#2,sp

	move.w	d3,-(sp)
	bsr	gtkr_stop_track
	addq.l	#2,sp

	dbra	d3,.loop

	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Fixe le master volume					;
;	ParamŠtres :					;
;	- W master : Entre 0 et $1000. Valeur … modifier en fonction	;
;		du nombre de voies : par s‚curit‚ il devrait ˆtre	;
;		fix‚ … 4096 / nbrvoies, mais on peut gagner du volume	;
;		avec 12288 / ( nbrvoies + 4 ).			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_master_vol:
	move.w	0+0+4(sp),gtkr_master_vol
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande le master volume dans d0.w			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_master_vol:
	move.w	gtkr_master_vol,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Fixe le nombre de samples/vbl dans d0.w			;
;	ParamŠtres :					;
;	- W nbr : Entre 100 et 1200. Valeur moyenne : 983		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_vblsize:
	move.w	0+0+4(sp),gtkr_vblsize
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande le nombre de samples/vbl dans d0.w			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_vblsize:
	move.w	gtkr_vblsize,d0
	rts


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande au noyau de r‚server une voie			;
;	ParamŠtres :					;
;	- W id : Num‚ro d'identification attribu‚ … la voie (>0).	;
;		$FFFF correspond … aucune identification sp‚ciale	;
;	Renvoie : Le num‚ro de la voie r‚serv‚e, et -1 si aucune	;
;		voie n'est libre.				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_reserve_track:
	movem.l	d1-a5,-(sp)
	moveq	#0,d0
	move.l	gtkr_adr_info_track,a0

.loop:	tst.w	protect_t(a0)
	beq.s	.ok
	add.w	#next_t,a0
	addq.w	#1,d0
	cmp.w	gtkr_nbrvoies,d0
	blt.s	.loop
.error:	moveq	#-1,d0		; Plus de voie disponible
	bra.s	.fin

.ok:	move.w	0+52+4(sp),protect_t(a0)

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande au noyau de lib‚rer une voie auparavant r‚serv‚e	;
;	ParamŠtres :					;
;	- W track : Num‚ro de la voie.				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_free_track:
	movem.l	d1-a5,-(sp)
	move.w	0+52+4(sp),d1
	mulu.w	#next_t,d1
	clr.w	([gtkr_adr_info_track],protect_t,d1.l)
	moveq	#0,d0
.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Joue un sample. Si la voie est en pause, elle repasse		;
;	automatiquement en marche. Toutes les longueurs sont en octets.	;
;	ParamŠtres :		Valeurs ne changeant rien :	;
;	- W track	: Num‚ro de piste			 /	;
;	- L adrspl : adresse du sample. paire		-1	;
;	- L lonspl : Longueur du sample. paire		-1	;
;		Elle est ignor‚e s'il y a bouclage.         	;
;	- L posspl : Position actuelle dans le sample	-1	;
;	- W volume : Volume (0..$800)			-1	;
;	- W balance : balance (0..$800..$FFF)		-1	;
;	- W freq : Fr‚quence en Hz du sample		 0	;
;	- W resol : 1 = 8 bits, 2 = 16 bits		-1	;
;	- W flags : +1 = boucle			 /	;
;		 +2 = calcul du buffer de r‚p‚tition        	;
;	- L adrbuf : adresse du buffer de bouclage		-1	;
;	- ( L reppos : Position de bouclage. paire )	-1	;
;	- ( L replen : longueur de bouclage. paire )	-1	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_play_sample:
	movem.l	d1-a5,-(sp)

	move.w	0+52+4(sp),d3
	move.w	#next_t,d1
	mulu.w	d3,d1
	lea	([gtkr_adr_info_track],d1.l),a0

	move.w	#1,onoff_t(a0)
.adrspl:	move.l	2+52+4(sp),d1	; Adresse
	bmi.s	.posspl
	move.l	d1,adrsam_t(a0)
.posspl:	move.l	10+52+4(sp),d1	; Position
	bmi.s	.volume
	move.l	d1,pos_t(a0)
	clr.w	finepos_t(a0)
.volume:	move.w	14+52+4(sp),d1	; Volume
	bmi.s	.balance
	move.w	d1,vol_t(a0)
.balance:	move.w	16+52+4(sp),d1	; Balance
	bmi.s	.freq
	move.w	d1,bal_t(a0)
.freq:	move.w	18+52+4(sp),d1	; Fr‚quence en Hz
	beq.s	.resol
	move.w	d1,fech_t(a0)
	move.w	#$1ac0,per_t(a0)
.resol:	move.w	20+52+4(sp),d1	; R‚solution
	bmi.s	.flags
	move.w	d1,nbits_t(a0)

.flags:	move.w	22+52+4(sp),d1
	btst	#0,d1		; Boucle ?
	bne.s	.boucle
.pasboucle:
	move.l	6+52+4(sp),d2	; d2 = longueur
	bge.s	.pb_ok
	move.l	reppos_t(a0),d2
	add.l	replen_t(a0),d2
.pb_ok:	subq.l	#2,d2
	move.l	d2,reppos_t(a0)
	move.l	#2,replen_t(a0)
	bra.s	.buffer
.boucle:
	move.l	28+52+4(sp),d2	; Repeat position
	bmi.s	.replen
	move.l	d2,reppos_t(a0)
.replen:	move.l	32+52+4(sp),d2	; Repeat length
	bmi.s	.buffer
	move.l	d2,replen_t(a0)
.buffer:
	move.l	24+52+4(sp),d2
	bmi.s	.setloop
	move.l	d2,rbuffer_t(a0)
.setloop:	btst	#1,d1		; Refaire le buffer de boucle ?
	beq.s	.fin
	move.w	nbits_t(a0),-(sp)
	move.l	replen_t(a0),d2
	move.l	d2,-(sp)
	move.l	reppos_t(a0),-(sp)
	add.l	reppos_t(a0),d2
	move.l	d2,-(sp)
	move.l	rbuffer_t(a0),-(sp)
	move.l	adrsam_t(a0),-(sp)
	bsr	gtkr_make_rbuffer
	lea	22(sp),sp

.fin:	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Arrˆte une voie, et effectue son reset, sans la lib‚rer	;
;	ParamŠtre :					;
;	- W track : Num‚ro de la piste … arrˆter			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_stop_track:
	movem.l	d1-a5,-(sp)

	move.w	0+52+4(sp),d2
	move.w	#next_t,d1
	mulu.w	d1,d2
	lea	([gtkr_adr_info_track],d2.l),a4

	lsr.w	#1,d1
	addq.w	#1,d1
	and.w	#1,d1
	mulu.w	#$fff,d1
	move.w	d1,bal_t(a4)	; La balance courante

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



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Mets une voie en pause				;
;	ParamŠtre :					;
;	- W track : Num‚ro de la piste … mettre en pause		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_pause_track:
	movem.l	d1-a5,-(sp)
	move.w	0+52+4(sp),d1
	mulu.w	#next_t,d1
	clr.w	([gtkr_adr_info_track],onoff_t,d1.l)
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Reprise d'une voie mise en pause				;
;	ParamŠtre :					;
;	- W track : Num‚ro de la piste … reprendre			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_cont_track:
	movem.l	d1-a5,-(sp)
	move.w	0+52+4(sp),d1
	mulu.w	#next_t,d1
	move.w	#1,([gtkr_adr_info_track],onoff_t,d1.l)
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Ajoute une routine dans le noyau				;
;	ParamŠtres :					;
;	- L adrrout : adresse de la routine			;
;	Retour : 0 si rien … signaler, positif si la routine ‚tait	;
;		d‚j… l… (elle est cependant r‚install‚e). d0 contient	;
;		alors le nombre de fois qu'est pr‚sente cette routine.	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_add_routine:
	movem.l	d1-a5,-(sp)
	moveq	#0,d0
	lea	gtkr_extrout,a2
.loop:	move.l	(a2)+,d1		; Cherche un emplacement vide dans le noyau
	cmp.l	a2,d1
	beq.s	.ok
	addq	#1,d0		; Ah elle ‚tait d‚j… l…. Mais ce n'est pas une erreur
.ok:	tst.l	d1
	bne.s	.loop
	clr.l	(a2)
	move.l	0+52+4(sp),-(a2)	; Installe la routine dans le noyau
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Retire une routine du noyau				;
;	ParamŠtres :					;
;	- L adrrout : adresse de la routine. Si elle ‚tait l…		;
;		plusieurs fois, elle n'est retir‚e qu'une fois.	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_remove_routine:
	movem.l	d1-a5,-(sp)
	lea	gtkr_extrout,a0
	move.l	0+52+4(sp),d1
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



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande l'adresse des infos sur les voies dans d0		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_track_adr:
	move.l	gtkr_adr_info_track,d0
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Fixe l'adresse des infos sur les voies			;
;	ParamŠtres :					;
;	- L adr : Adresse des infos. Cette adresse ne doit ˆtre	;
;		modifi‚e que si une seule application utilise le	;
;	      	noyau lors de cette op‚ration, c.a.d s'il n'y a	;
;		aucune voie r‚serv‚e, ou seulement par l'app en	;
;		question. Lorsque l'app se termine, elle doit	;
;		restituer l'ancienne adresse, toujours dans les mˆmes	;
;		conditions, ou laisser l'espace m‚moire r‚serv‚	;
;	Retour : l'ancienne adresse dans d0			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_track_adr:
	move.l	gtkr_adr_info_track,d0
	move.l	0+0+4(sp),gtkr_adr_info_track
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Fabrique le buffer de boucle d'un sample			;
;	ParamŠtres :					;
;	- L adrspl : Adresse du sample				;
;	- L adrbuf : Adresse du buffer (1024 octets)		;
;	- L length : Longueur du sample (en octets). Paire. S'il y a	;
;		bouclage, cette longueur n'a pas d'importance.	;
;	- L reppos : Position de r‚p‚tition (en octets). Paire		;
;	- L replen : Taille de la boucle (octets). Paire		;
;	- W resol : R‚solution du sample (1 = 8 bits, 2 = 16 bits)	;
;	Un sample non boucl‚ devra avoir reppos = 0 et replen = 2	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_make_rbuffer:
	movem.l	d1-a5,-(sp)
	move.l	0+52+4(sp),a0	; a0 = adresse du sample
	move.l	4+52+4(sp),a2	; a2 = adresse du buffer

	move.w	#512,d1
.loop1:	move.l	a0,a3
	add.l	12+52+4(sp),a3	; a3 pointe sur le d‚but de la boucle
	move.l	16+52+4(sp),d2	; d2 = replen
	lsr.l	#1,d2
	subq.l	#1,d2
	tst.l	d2
	bne.s	.loop2
	tst.l	12+52+4(sp)
	bne.s	.loop2

	tst.l	8+52+4(sp)
	beq.s	.vide
	cmp.w	#2,20+52+4(sp)
	beq.s	.bouc16b
.bouc8b:	move.w	#1023,d1		; Pas bouclage 8 bits
	add.l	8+52+4(sp),a0
	subq.l	#1,a0
.loop3:	move.b	(a0),(a2)+
	dbra	d1,.loop3
	bra.s	.fin
.bouc16b:	subq.w	#1,d1		; Pas de bouclage 16 bits
	add.l	8+52+4(sp),a0
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
	movem.l	d0-a6,-(sp)	; est en interruption DSP
	IFNE	FLAG_MT_DISP	; Le rouge montre le temps machine utilis‚ par le 030
	move.l	#FC_RED,FCOLOR00+NCOLOR_MT_DISP*4.w
	ENDC
	readhost
	move.w	DSPHRDR_W.w,d0	; R‚cupŠre la commande ‚mise par le dsp
	tst.w	gtkr_flag_the_end	; On doit tout arrˆter ?
	beq.s	sendsam_nostop

	move.b	#0,DSPHCR.w	; Plus d'interruption DSP Host
	writhost
	move.l	#8,DSPHTDR_L.w	; Arrˆt de la routine DSP
	clr.w	gtkr_flag_the_end	; Signale qu'on a arrˆt‚
	IFNE	FLAG_MT_DISP	; On remet la couleur de fond
	move.l	gtkr_color_mt_disp,FCOLOR00+NCOLOR_MT_DISP*4.w
	ENDC
	IFNE	INTERRUPTION_TYPE	; Arret du Timer A s'il ‚tait l…
	bclr	#5,MFPIMRA.w	; Timer A masqu‚
	bclr	#5,MFPIERA.w	; Timer A annul‚
	move.l	gtkr_sauvegarde_timer_a,MFPST_INT_TIMERA.w
	ENDC
	bra	sendsam_the_end

sendsam_nostop:
	move.l	gtkr_adr_info_track,a0	; a0 pointe sur le tableau d'infos des voies
	move.w	gtkr_current_track,d0	; d0 = voie courante
	bne.s	sendsam_nostop_ok
	writhost			; PremiŠre voie : on indique le nombre
	move.l	#32,DSPHTDR_L.w	; de samples par VBL (d‚pend du tempo)
	moveq	#0,d1
	move.w	gtkr_vblsize,d1
	writhost
	move.l	d1,DSPHTDR_L.w
sendsam_nostop_ok:
	move.w	gtkr_nbrvoies,d1	; d1 = nbr de voies
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
	mulu.w	#REPLAY_FREQ,d5	; d5 = Per(note) * Freplay
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
	writhost
	move.l	d1,DSPHTDR_L.w
	move.w	bal_t(a0),d1	; Envoie la balance
	lsl.w	#3,d1
	lsl.l	#8,d1
	writhost
	move.l	d1,DSPHTDR_L.w

	moveq	#0,d1
	move.w	per_t(a0),d1
	mulu.w	#REPLAY_FREQ,d1	; d1 = Per(note) * Freplay
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
	addq.l	#1,d1		; *** dernier sample … mixer : en envoyer 1 de plus
	btst	#0,pos_t+3(a0)	; *** car le nbr est d‚cimal (arrondit par d‚faut)
	beq.s	sendsam_8even	; Adresse de d‚but de bloc paire

	move.l	reppos_t(a0),d3
	addq.l	#1,d3
	cmp.l	pos_t(a0),d3
	bne.s	.ELZE
	move.l	rbuffer_t(a0),a1	; Si on tombe sur le 2Šme octet de la boucle, on prend
	addq.l	#1,a1		; celui du bouclage (‚vite gr‚sillements pour le sample 0)
	bra.s	.finsi
.ELZE:	move.l	adrsam_t(a0),a1	; a1 = adresse du sample
	add.l	pos_t(a0),a1
.finsi:	move.l	d1,d2		; l… c'est impair
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
	subq.l	#1,d1		; *** correction position r‚elle/nbr de spl envoy‚s
	add.l	pos_t(a0),d1	; Calcul de la position suivante
	cmp.l	reppos_t(a0),d1
	ble.s	.ELZE
	sub.l	reppos_t(a0),d1
	divul.l	replen_t(a0),d6:d1
	add.l	reppos_t(a0),d6	; d6 = nvlpos = ((pos + N - rep) MOD replen) + rep
	bra.s	.finsi
.ELZE:	move.l	d1,d6
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
	ENDM			; modifier le d3.w*2 du jmp d'avant. Idem plus loin
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
	ENDM
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
	ENDM
	dbra	d2,sendsam_8loopt1
	move.l	d6,pos_t(a0)	; Nouvelle position
	bra	sendsam_next



;--- Transfert en 16 bits ----------------------------------------------------
sendsam_16bits:			; Envoi de sample 16 bits
	writhost
	move.l	#2,DSPHTDR_L.w	; Signale que c'est du 16 bits
	move.l	d1,d2
	add.l	d2,d2		; d2 = nombre d'octets
	addq.l	#2,d2		; *** Sample de s‚curit‚
	writhost
	move.l	d1,DSPHTDR_L.w	; d1 = nombre de samples -1 … envoyer en une VBL
				; *** + 1 sample … cause de l'arrondi par excŠs
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
	ENDM
	dbra	d4,sendsam_16loopt2
	tst.l	d2
	bne.s	sendsam_16boucle
	move.l	reppos_t(a0),d1	; Si on s'arrŠte pile-poil … la fin
	add.l	replen_t(a0),d1
	subq.l	#2,d1		; *** EnlŠve le sample de s‚curit‚
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
	ENDM
	dbra	d3,sendsam_16loopt3

	tst.l	d2		; Qu'est-ce qui reste ?
	beq.s	sendsam_16fin	; Rien, on se tire
	divul.l	replen_t(a0),d4:d5
	add.l	reppos_t(a0),d4
	move.l	d4,pos_t(a0)	; pos = ((pos + N - rep) MOD replen) + rep
	bra	sendsam_16avantfin	; On revient pour finir le transfert

sendsam_16fin:
	subq.l	#2,d5		; *** EnlŠve le sample de s‚curit‚
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
	ENDM
	dbra	d2,sendsam_16loopt1
	subq.l	#2,d3		; *** EnlŠve le sample suppl‚mentaire
	move.l	d3,pos_t(a0)	; Nouvelle position



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

	move.w	d6,d7
	not.w	d7
	and.w	#7,d7
	lsr.w	#3,d6
	jmp	(.loop1,d7.w*8)
.loop1:
	REPT	8
	move.b	(a1,d3.l),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	ENDM
	dbra	d6,.loop1

	move.l	reppos_t(a0),d6
	add.l	replen_t(a0),d6
	cmp.l	d6,d3
	blt.s	.s2
	sub.l	replen_t(a0),d3
.s2:	tst.l	d5
	ble	.fini

; Dans la boucle maintenant
	move.l	#1024-1,d6
	sub.l	reppos_t(a0),d3
	sub.l	d3,d6
	swap	d6
	divul.l	d2,d7:d6		; d6 = nbr de samples -1 … envoyer avant la fin de la boucle
	subq.l	#1,d5
	cmp.l	d5,d6
	ble.s	.s3
	move.l	d5,d6
.s3:	sub.l	d6,d5		; Ajuste le compteur de samples

	move.w	d6,d7
	not.w	d7
	and.w	#7,d7
	lsr.w	#3,d6
	jmp	(.loop2,d7.w*8)
.loop2:
	REPT	8
	move.b	(a2,d3.l),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	ENDM
	dbra	d6,.loop2

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

	move.w	d6,d7
	not.w	d7
	and.w	#7,d7
	lsr.w	#3,d6
	jmp	(.loop1,d7.w*8)
.loop1:
	REPT	8
	move.w	(a1,d3.l*2),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	ENDM
	dbra	d6,.loop1

	add.l	d3,d3
	move.l	reppos_t(a0),d6
	add.l	replen_t(a0),d6
	cmp.l	d6,d3
	blt.s	.s2
	sub.l	replen_t(a0),d3
.s2:	tst.l	d5
	ble	.fini2

; Dans la boucle maintenant
	move.l	#1024/2-1,d6
	sub.l	reppos_t(a0),d3
	lsr.l	#1,d3
	sub.l	d3,d6
	swap	d6
	divul.l	d2,d7:d6		; d6 = nbr de samples -1 … envoyer avant la fin de la boucle
	subq.l	#1,d5
	cmp.l	d5,d6
	ble.s	.s3
	move.l	d5,d6
.s3:	sub.l	d6,d5		; Ajuste le compteur de samples

	move.w	d6,d7
	not.w	d7
	and.w	#7,d7
	lsr.w	#3,d6
	jmp	(.loop2,d7.w*8)
.loop2:
	REPT	8
	move.w	(a2,d3.l*2),(a3)
	add.w	d2,d4
	addx.l	d1,d3
	ENDM
	dbra	d6,.loop2

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
	IFNE	FLAG_MT_DISP	; Bleu, le dsp est occup‚
	move.l	#FC_BLUE,FCOLOR00+NCOLOR_MT_DISP*4.w
	ENDC
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
	IFNE	FLAG_MT_DISP	; Vert : les routines externes
	move.l	#FC_GREEN,FCOLOR00+NCOLOR_MT_DISP*4.w
	ENDC

	lea	gtkr_extrout,a0	; a0 pointe sur la table des routines
.extloop:	move.l	(a0)+,d1
	beq.s	.ext_end		; Adresse = 0, c'est fini
	movem.l	d0/a0,-(sp)
	jsr	(d1.l)		; Ex‚cute une routine ext‚rieure (ex : partition)
	movem.l	(sp)+,d0/a0
	bra.s	.extloop		; Routine suivante
.ext_end:

	IFNE	FLAG_MT_DISP	; C'est fini pour la vbl
	move.l	gtkr_color_mt_disp,FCOLOR00+NCOLOR_MT_DISP*4.w
	ENDC

sendsam_encore:
	move.w	d0,gtkr_current_track

sendsam_the_end:
	movem.l	(sp)+,d0-a6
	IFNE	INTERRUPTION_TYPE
	bclr	#5,MFPISRA.w
	ENDC
	rte





******************************************************************************
**						          **
*	BibliothŠque des fonctions de contr“le du soundtracker		*
**						          **
******************************************************************************



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Installe le player de .GTK				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_player_on:
	movem.l	d1-a5,-(sp)
	tst.w	gtkpl_flag_installed
	bne	.error		; D‚j… install‚

	move.w	#$ffff,-(sp)
	bsr	gtkr_reserve_track
	addq.l	#2,sp
	tst.w	d0
	bmi	.error2
	move.w	d0,gtkpl_num_track

	lea	gtkpl_module_inf2,a0	; a0 pointe sur les infos du mod
	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod

	move.w	#1,mod_nbrtrack(a0)
	move.w	#1,mod_nbrlines(a0)
	move.w	#1,mod_songlen(a0)
	clr.w	mod_songrep(a0)
	clr.w	mod_songpos(a0)
	clr.w	mod_numpat(a0)
	clr.w	mod_linepos(a0)
	clr.w	mod_cursongpos(a0)
	clr.w	mod_curlinepos(a0)
	move.w	#6,mod_speed(a0)
	clr.w	mod_patrep(a0)
	move.w	#-1,mod_nbrticks(a0)
	move.w	#1,mod_vblnumber(a0)
	clr.w	mod_vblcpt(a0)

	lea	gtkr_zone_vide,a3
	move.l	a3,adr_song(a1)
	move.l	a3,adr_pattern(a1)
	move.l	a3,adr_instrheader(a1)

	lea	adr_samples(a1),a2
	moveq	#NBRSAMPLES_MAXI/2-1,d1
.loop:	move.l	a3,(a2)+
	move.l	a3,(a2)+
	dbra	d1,.loop
	lea	adr_repbuf(a1),a2
	moveq	#NBRSAMPLES_MAXI/2-1,d1
.loop2:	move.l	a3,(a2)+
	move.l	a3,(a2)+
	dbra	d1,.loop2

	bsr	gtkr_get_track_adr		; On cherche l'adresse de info_track
	move.l	d0,gtkpl_adr_info_track	; Les donn‚es sont ainsi plus rapidement accessibles

	move.w	#1,gtkpl_flag_installed
	move.l	#gestion_partition,-(sp)	; Installe la routine dans le noyau
	bsr	gtkr_add_routine
	addq.l	#4,sp

	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; D‚j… install‚
	bra.s	.fin
.error2:	moveq	#-2,d0		; Plus de piste libre

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	D‚sinstalle le player de .GTK				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_player_off:
	movem.l	d1-a5,-(sp)
	tst.w	gtkpl_flag_installed
	beq.s	.error		; Pas install‚

	bsr	gtkr_reset_sndtrk_tracks

	move.l	#gestion_partition,-(sp)
	bsr	gtkr_remove_routine
	addq.l	#4,sp

	clr.w	gtkpl_flag_installed
	move.w	gtkpl_module_inf2+mod_nbrtrack,d1	; LibŠre les voies
	subq.w	#1,d1
	lea	gtkpl_num_track,a0

.loop:	move.w	(a0)+,-(sp)
	bsr	gtkr_free_track
	addq.l	#2,sp
	dbra	d1,.loop

	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Reset des voies de soundtrack				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_reset_sndtrk_tracks:
	movem.l	d1-a5,-(sp)
	move.w	#1,gtkpl_flag_stop_vcs
.wait:	tst.w	gtkpl_flag_stop_vcs	; Arrˆte le module en cours et r‚initialise les voies
	bne.s	.wait
	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Convertit un module en module au format interne		;
;	ParamŠtres :					;
;	- W type : Type de module … convertir. 0 = GTK, 1 = MOD	;
;	- L adrmod : Adresse du module … convertir			;
;	- L adrconv : Adresse du module converti			;
;	Renvoie la taille du module converti dans d0.		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_convert_module:
	movem.l	d1-a5,-(sp)
	move.l	2+52+4(sp),a0	; ððð> a0 = adresse du module … convertir
	move.l	6+52+4(sp),a5	; ððð> a5 = adresse du module converti
	move.w	0+52+4(sp),d0	; d0 = type de module
	tst.l	d0		; 0 : .GTK
	beq.s	gtkr_cm_gtk
	cmp.w	#1,d0
	beq	gtkr_cm_mod
	bra	gtkr_cm_error1

;ððð Conversion d'un module .GTK ððððððððððððððððððððððððððððððððððððððððððððð
gtkr_cm_gtk:
	moveq	#0,d0
	move.b	3(a0),d0		; ððð> d0 = Num‚ro de format
	beq	gtkr_cm_error3	; D‚j… converti
	cmp.w	#4,d0
	bgt	gtkr_cm_error2	; Num‚ro invalide

	moveq	#64,d1		; d1 = taille d'une en-tˆte d'instrument = 64 octets
	cmp.w	#2,d0
	bgt.s	.li64
	moveq	#48,d1		; Version ó 2 : 48 octets
.li64:	move.l	d1,d6		; ððð> d6 sert plus tard (taille d'un header)
	mulu.w	196(a0),d1		; ððð> d1 = place prise par les en-tˆtes d'instruments

;--- Cherche la place prise par les patterns ---------------------------------
	move.l	d1,d3
	add.l	#206,d3		; Offset de la song
	moveq	#0,d2		; d2 = le plus grand num‚ro de pattern
	move.w	202(a0),d4		; Taille de la song
	subq.w	#1,d4
.looppgnp:	cmp.w	(a0,d3.l),d2
	bgt.s	.nextpgnp
	move.w	(a0,d3.l),d2
.nextpgnp:	addq.l	#2,d3
	dbra	d4,.looppgnp
	addq.w	#1,d2
	mulu.w	200(a0),d2
	mulu.w	198(a0),d2
	move.l	d2,d7		; ððð> d7 = Taille des patterns en notes
	move.l	d2,d3
	add.l	d2,d2
	add.l	d2,d2		; 4 octets par note
	cmp.w	#4,d0
	blt.s	.suitep1
	add.l	d3,d2		; 5 octets par note
.suitep1:				; ððð> d2 = place prise par les patterns

;--- Cherche la place prise par les samples ----------------------------------
	move.l	#718,d4
	add.l	d1,d4
	add.l	d2,d4		; Offset des samples
	moveq	#0,d3
	move.l	#206-16,d4
	add.l	d6,d4		; d4 = offset de la longueur du 1er sample
	move.w	196(a0),d5
	subq.w	#1,d5
.loopti:	add.l	(a0,d4.l),d3
	add.l	d6,d4
	dbra	d5,.loopti		; ððð> d3 = place prise par les samples

;--- Copie des samples -------------------------------------------------------
	lea	718(a0),a1
	add.l	d3,a1
	add.l	d2,a1
	add.l	d1,a1		; a1 = adresse de fin du module .GTK
	lea	718(a5),a2
	add.l	d3,a2
	move.w	196(a0),d4
	addq.w	#1,d4		; On insŠre le sample nø0
	mulu.w	#64,d4
	add.l	d4,a2
	move.l	d7,d4		; Taille des patterns
	mulu.l	#5,d4		; *** BUG!!!!!! (Fixed by MrPink July 98)
	add.l	d4,a2		; a2 = adresse de fin du module converti
	move.l	a2,a3		; ððð> a3 = idem. On s'en sert plus tard
	move.l	d3,d4
	subq.l	#1,d4
	swap	d4
.loopcsa2:	swap	d4
.loopcsa1:	move.b	-(a1),-(a2)	; Recopie les samples
	dbra	d4,.loopcsa1
	swap	d4
	dbra	d4,.loopcsa2

;--- Copie (conversion) des patterns -----------------------------------------
	subq.l	#1,d7
	swap	d7
	cmp.w	#3,d0
	ble.s	.pat4_l2		; Pas de volume sur les versions ó 3
.pat5_l2:	swap	d7		; Copie les patterns de 5 octets/note
.pat5_l1:	move.b	-(a1),-(a2)	; Volume
	move.l	-(a1),-(a2)	; Note + instr + effet
	dbra	d7,.pat5_l1
	swap	d7
	dbra	d7,.pat5_l2
	bra.s	.pat_fin
.pat4_l2:	swap	d7		; Copie les patterns de 5 octets/note
.pat4_l1:	clr.b	-(a2)		; Volume : rien
	move.l	-(a1),-(a2)	; Note + instr + effet
	dbra	d7,.pat4_l1
	swap	d7
	dbra	d7,.pat4_l2
.pat_fin:

	moveq	#127,d4		; Recopie la song
.loopcsng:	move.l	-(a1),-(a2)
	dbra	d4,.loopcsng

;--- Copie et conversion des headers de samples ------------------------------
	move.w	196(a0),d4
	subq.l	#1,d4
	cmp.w	#1,d0
	beq.s	.loopchs1		; v1
	cmp.w	#2,d0
	beq.s	.loopchs2		; v2
	bra.s	.loopchs3		; v3 et plus...
.loopchs1:	
	REPT	4
	move.l	-(a1),-(a2)	; Longueur, reppos, replen, volume, finetune
	ENDM
	move.l	#$000120ab,-(a2)	; R‚solution, fr‚quence
	move.l	#$0000ffff,-(a2)	; -, autobalance
	clr.l	-(a2)		; -
	clr.l	-(a2)
	clr.l	-(a2)
	subq.l	#4,a1		; Saute les 4 derniers car. du nom (32 -> 28)
	REPT	7
	move.l	-(a1),-(a2)	; Nom
	ENDM
	dbra	d4,.loopchs1
	bra.s	.chs_fin
.loopchs2:
	REPT	5
	move.l	-(a1),-(a2)	; Longueur, reppos, replen, volume, finetune,
	ENDM			; r‚solution, fr‚quence
	move.l	#$0000ffff,-(a2)	; -, autobalance
	clr.l	-(a2)		; -
	clr.l	-(a2)
	clr.l	-(a2)
	REPT	7
	move.l	-(a1),-(a2)	; Nom
	ENDM
	dbra	d4,.loopchs2
	bra.s	.chs_fin
.loopchs3:
	REPT	16
	move.l	-(a1),-(a2)	; Tout
	ENDM
	dbra	d4,.loopchs3

.chs_fin:				; Header du sample 0
	clr.l	-(a2)		; Volume + finetune
	move.l	#2,-(a2)		; Replen
	clr.l	-(a2)		; Reppos
	clr.l	-(a2)		; Length
	move.l	#$000120ab,-(a2)	; R‚sol + fr‚quence
	move.l	#$0000ffff,-(a2)	; Autobalance. Le reste on s'en fout
	REPT	10
	clr.l	-(a2)
	ENDM

	moveq	#102,d4
.loopcdeb:	move.w	-(a1),-(a2)	; Copie le d‚but
	dbra	d4,.loopcdeb

	clr.b	3(a5)		; Donne 0 comme num‚ro de format au module converti
	sub.l	a0,a3
	move.l	a3,d0		; Revoie la taille du nouveau module
	bra	gtkr_cm_fin

;ððð Conversion d'un module .MOD ððððððððððððððððððððððððððððððððððððððððððððð
gtkr_cm_mod:
	lea	gtkpl_id_mod,a1
	move.l	$438(a0),d0	; Identificateur de type de module
	moveq	#0,d1
.loopid:	tst.b	(a1)
	beq.s	.idnotfnd
	cmp.l	(a1)+,d0		; Bon identificateur ?
	beq.s	.idfound
	addq.l	#1,a1		; Non, saute le nbr de piste
	bra.s	.loopid		; et cherche le suivant
.idfound:	moveq	#64,d0		; d0 = nbr de lignes
	move.b	(a1),d1		; d1 = nbr de pistes
	lea	$43C(a0),a1	; ððð> a1 = adresse des patterns
	bra.s	.init1
.idnotfnd:	cmp.w	#'FA',$438(a0)	; Ce ne serait pas un module Digital Tracker alors ?
	bne	gtkr_cm_error4	; Non, erreur
	move.b	$43a(a0),d1	; Oui, prend le nombre de piste (ASCII aprŠs le 'FA')
	sub.b	#'0',d1
	mulu.w	#10,d1
	add.b	$43b(a0),d1
	sub.b	#'0',d1		; d1 = nbr de pistes
	move.w	$43c(a0),d0	; d0 = nbr de lignes
	lea	$440(a0),a1	; ððð> a1 = adresse des patterns (d‚calage pour D.T.)

.init1:	moveq	#0,d2
	move.w	d0,gtkpl_mod_nbl
	move.w	d1,gtkpl_mod_nbt
	move.b	$3b6(a0),d2
	move.w	d2,gtkpl_mod_sl
	move.b	$3b7(a0),d2
	move.w	d2,gtkpl_mod_sr

;--- Cherche le nombre de patterns sauv‚s dans le module ---------------------
	move.w	gtkpl_mod_sl,d2
	subq.w	#1,d2
	moveq	#0,d3
	moveq	#0,d4
	lea	$3b8(a0),a2	; a2 pointe sur la song
.cpmloop:	move.b	(a2)+,d3		; d3 = num‚ro de pattern
	cmp.w	d4,d3		; Cherche le plus grand num‚ro
	ble.s	.cpmnext
	move.w	d3,d4
.cpmnext:	dbra	d2,.cpmloop
	addq.w	#1,d4		; d4 = Nombre de patterns dans le module. d4 sert plus bas
	move.w	d4,gtkpl_mod_nbp

;--- Copie des samples -------------------------------------------------------
	moveq	#0,d0		; Cherche d'abord la taille totale des samples
	moveq	#0,d1
	moveq	#30,d2
	lea	20+$16(a0),a2	; Pointe sur la taille/2 du 1er sample
.cltsloop:	move.w	(a2),d1
	add.l	d1,d0
	add.w	#$1e,a2
	dbra	d2,.cltsloop	; d0 = taille des samples en mots

	mulu.w	gtkpl_mod_nbt,d4
	mulu.w	gtkpl_mod_nbl,d4	; d4 = nbr de notes
	lea	(a1,d4.l*4),a2
	lea	(a2,d0.l*2),a2	; a2 = adresse des samples
	lea	718+NBRSAMPLES_MAXI*next_s(a5),a4
	lea	(a4,d4.l*4),a4
	add.l	d4,a4
	lea	(a4,d0.l*2),a4	; a4 = idem, dans le module converti
	move.l	a4,gtkpl_mod_len
	subq.l	#1,d0
	swap	d0
.cpsloop2:	swap	d0
.cpsloop1:	move.w	-(a2),-(a4)	; Hop, copie
	dbra	d0,.cpsloop1
	swap	d0
	dbra	d0,.cpsloop2

;--- Conversion des patterns -------------------------------------------------
	move.w	gtkpl_mod_nbp,d0	; On ressort le nbr de patterns
	mulu.w	gtkpl_mod_nbt,d0
	mulu.w	gtkpl_mod_nbl,d0	; d0 = Nbr de notes … convertir
	lea	(a1,d0.l*4),a2	; a2 = adresse de fin des patterns dans le module .MOD
	lea	718+NBRSAMPLES_MAXI*next_s(a5),a4	; a4 =    "    "   "   "     "      "    "   "    converti
	lea	(a4,d0.l*4),a4
	add.l	d0,a4		; L… y a 5 octets par note
	subq.l	#1,d0
	swap	d0

cv_nt2gtk_loop2:
	swap	d0
cv_nt2gtk_loop1:
	move.l	-(a2),d1		; d1 = ancienne note
	moveq	#0,d2		; d2 = nouvelle note
	move.l	d1,d3
	and.l	#$0fff0000,d3
	beq.s	cv_nt2gtk_instr	; S'il n'y a rien
	swap	d3
	moveq	#36,d4
	lea	protrack_pernote,a3
.loop:	cmp.w	(a3)+,d3		; recherche la note
	beq.s	.finloop
	addq.w	#1,d4
	cmp.w	#72,d4
	bne.s	.loop
	moveq	#0,d4
.finloop:	lsl.w	#8,d4
	swap	d4
	move.l	d4,d2		; Note convertie

cv_nt2gtk_instr:
	move.l	d1,d3
	and.l	#$f000f000,d3
	lsr.l	#8,d3
	swap	d3
	move.w	d3,d4
	swap	d3
	lsr.b	#4,d3
	add.w	d4,d3		; d3 = instrument
	ext.l	d3		; Vide la partie sup‚rieure
	swap	d3
	add.l	d3,d2		; Instrument converti

	moveq	#0,d3
	move.w	d1,d3
	lsr.w	#8,d3
	and.b	#$f,d3		; d3 = num‚ro d'effet
	move.w	d1,d4
	and.w	#$ff,d4		; d4 = paramŠtre 2 chiffres

	bsr	convert_profx_2_gtkfx	; Convertit l'effet

	clr.b	-(a4)		; Efface le volume interne
	move.l	d2,-(a4)		; Met la note
	dbra	d0,cv_nt2gtk_loop1
	swap	d0
	dbra	d0,cv_nt2gtk_loop2

;--- Conversion de la song ---------------------------------------------------
	move.w	gtkpl_mod_sl,d2
	subq.w	#1,d2
	moveq	#0,d3
	lea	$3b8(a0),a2	; a2 pointe sur la song
	lea	206+NBRSAMPLES_MAXI*next_s(a5),a4	; a4 aussi, dans le module converti
.csngloop:	move.b	(a2)+,d3		; Copie le num‚ro de pattern
	move.w	d3,(a4)+
	dbra	d2,.csngloop

;--- Conversion des headers des sample ---------------------------------------
	lea	206+32*next_s(a5),a4	; Headers d'instr dans le module converti
	move.w	#NBRSAMPLES_MAXI-1-32,d0
.loopins1:	add.w	#autobal_s,a4	; Efface tous les headers … partir du sample 32
	move.w	#$ffff,(a4)+	; Autobalance
	move.l	#$000120ab,(a4)+	; Bits, freq
	clr.l	(a4)+		; Length
	clr.l	(a4)+		; Repeat
	move.l	#2,(a4)+		; Replen
	clr.l	(a4)+		; Volume, finetune
	dbra	d0,.loopins1

	lea	20+30*$1e(a0),a2	; Headers d'instr dans le module .MOD : sample 31
	lea	206+31*next_s(a5),a4	;    "       "     "    "    "   converti : sample 31
	moveq	#30,d0		; d0 = Compteur d'instruments
.loopins2:	move.w	#$ffff,autobal_s(a4)	; Autobalance
	move.l	#$000120ab,nbits_s(a4)	; Bits, freq
	moveq	#0,d1
	move.w	$16(a2),d1		; Length
	add.l	d1,d1
	move.l	d1,length_s(a4)
	moveq	#0,d1
	move.w	$1a(a2),d1		; Repeat
	add.l	d1,d1
	move.l	d1,repeat_s(a4)
	moveq	#0,d1
	move.w	$1c(a2),d1		; Replen
	add.l	d1,d1
	move.l	d1,replen_s(a4)
	moveq	#0,d1
	move.b	$19(a2),d1		; Volume
	add.w	d1,d1
	add.w	d1,d1
	move.w	d1,vol_s(a4)
	moveq	#0,d1
	move.b	$18(a2),d1		; Finetune
	cmp.b	#7,d1
	ble.s	.ins2ftok
	sub.w	#16,d1
.ins2ftok:	move.w	d1,ftune_s(a4)
	sub.w	#$1e,a2		; Instrument suivant (pr‚c‚dent en
	sub.w	#next_s,a4		; fait puisqu'on commence par la fin)
	dbra	d0,.loopins2

	lea	206+autobal_s(a5),a4	; Efface le header du sample 0 maintenant
	move.w	#$ffff,(a4)+	; Autobalance
	move.l	#$000120ab,(a4)+	; Bits, freq
	clr.l	(a4)+		; Length
	clr.l	(a4)+		; Repeat
	move.l	#2,(a4)+		; Replen
	clr.l	(a4)+		; Volume, finetune

;--- Le reste ----------------------------------------------------------------
	move.l	#'GTKx'-'x',(a5)
	move.w	#NBRSAMPLES_MAXI-1,196(a5)	; Nbr d'instruments
	move.w	gtkpl_mod_nbl,198(a5)	; Nbr de lignes
	move.w	gtkpl_mod_nbt,200(a5)	; Nbr de pistes
	move.w	gtkpl_mod_sl,202(a5)	; Longueur de la song
	move.w	gtkpl_mod_sr,d1	; Point de bouclage de la song
	cmp.w	202(a5),d1		; V‚rifie que le point de bouclage
	blt.s	.sngrepok		; est bien dans la song, … cause de
	moveq	#0,d1		; certains trackers qui mettent $7f
.sngrepok:	move.w	d1,204(a5)		; quand il n'y a pas de bouclage.

	move.l	gtkpl_mod_len,a4
	sub.l	a5,a4
	move.l	a4,d0		; La taille du module
	bra.s	gtkr_cm_fin

gtkr_cm_error1:
	moveq	#-1,d0		; -1 : Type de module invalide
	bra.s	gtkr_cm_fin
gtkr_cm_error2:
	moveq	#-2,d0		; -2 : Num‚ro de version de format invalide
	bra.s	gtkr_cm_fin
gtkr_cm_error3:
	moveq	#-3,d0		; -3 : Module d‚j… au bon format
	bra.s	gtkr_cm_fin
gtkr_cm_error4:
	moveq	#-4,d0		; -4 : Format de module invalide

gtkr_cm_fin:
	movem.l	(sp)+,d1-a5
	rts

;------------------------------------------------------------------------------
;	Convertit un effet Protracker en un effet Graoumf Tracker
;	d2 = Note.l au format Graoumf (sans effet)
;	d3 = effet.b protracker (0-F)
;	d4 = paramŠtre.w protracker (0-FF)
;	Attention, ces registres ne sont pas sauv‚s
;	Au retour :
;	d2 = Note + Effet
;------------------------------------------------------------------------------
convert_profx_2_gtkfx:
	cmp.b	#1,d3		; Les effets qui ne changent pas
	beq.s	.nochange
	cmp.b	#2,d3
	beq.s	.nochange
	cmp.b	#3,d3
	beq.s	.nochange
	cmp.b	#4,d3
	beq.s	.nochange
	cmp.b	#7,d3
	beq.s	.nochange
	cmp.b	#11,d3
	beq.s	.nochange
	cmp.b	#13,d3
	bne.s	.suite
.nochange:	move.w	d4,d2
	lsl.w	#8,d3
	add.w	d3,d2
	and.w	#$fff,d2
	bra	.fin

.suite:	tst.b	d3		; Arpeggio
	bne.s	.5
	tst.b	d4
	beq	.fin
	add.w	#$1000,d4
	move.w	d4,d2
	bra	.fin

.5:	cmp.b	#5,d3		; Vol slide + porta
	bne.s	.6
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.5neg
	add.w	#$1800,d4
	move.w	d4,d2
	bra	.fin
.5neg:	move.w	#$1900,d2
	sub.w	d4,d2
	bra	.fin

.6:	cmp.b	#6,d3		; Vol slide + vib
	bne.s	.8
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.6neg
	add.w	#$1c00,d4
	move.w	d4,d2
	bra	.fin
.6neg:	move.w	#$1d00,d2
	sub.w	d4,d2
	bra	.fin

.8:	cmp.b	#8,d3		; Set balance
	bne.s	.9
	add.w	#$400,d3
	lsl.w	#4,d3
	move.w	d3,d2
	bra	.fin

.9:	cmp.b	#9,d3		; Play part of sample
	bne.s	.10
	add.w	#$9000,d4
	move.w	d4,d2
	bra	.fin

.10:	cmp.b	#10,d3		; Vol slide
	bne.s	.12
	move.w	d4,d3
	and.w	#$f,d3
	lsr.w	#4,d4
	sub.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	bmi.s	.10neg
	add.w	#$1400,d4
	move.w	d4,d2
	bra	.fin
.10neg:	move.w	#$1500,d2
	sub.w	d4,d2
	bra	.fin

.12:	cmp.b	#12,d3		; Set volume
	bne.s	.15
	add.w	d4,d4
	add.w	d4,d4
	add.w	#$2000,d4
	move.w	d4,d2
	bra	.fin

.15:	cmp.b	#15,d3		; Tempo
	bne.s	.14
	move.w	#$0F00,d2
	cmp.w	#$20,d4
	bge.s	.15_ok
	move.w	#$A800,d2
.15_ok:	move.b	d4,d2
	bra	.fin

.14:	cmp.b	#14,d3		; Effets ‚tendus
	bne	.fin
	move.w	d4,d3
	lsr.b	#4,d3
	and.b	#$f,d4
	cmp.b	#1,d3		; Fine porta up
	bne.s	.e2
	add.w	#$1100,d4
	move.w	d4,d2
	bra	.fin

.e2:	cmp.b	#2,d3		; Fine porta down
	bne.s	.e4
	add.w	#$1200,d4
	move.w	d4,d2
	bra	.fin

.e4:	cmp.b	#4,d3		; Set vib wave
	bne.s	.e5
	add.w	#$c00,d4
	move.w	d4,d2
	bra	.fin

.e5:	cmp.b	#5,d3		; Set finetune
	bne.s	.e6
	cmp.b	#7,d4
	bgt.s	.e5neg
	add.w	#$800,d4
	move.w	d4,d2
	bra	.fin
.e5neg:	move.w	#$810,d2
	sub.w	d4,d2
	bra	.fin

.e6:	cmp.b	#6,d3		; Pattern loop
	bne.s	.e7
	add.w	#$b100,d4
	move.w	d4,d2
	bra.s	.fin

.e7:	cmp.b	#7,d3		; Set trem wave
	bne.s	.e8
	add.w	#$e00,d4
	move.w	d4,d2
	bra.s	.fin

.e8:	cmp.b	#8,d3		; Set balance (2)
	bne.s	.e9
	lsl.w	#8,d4
	add.w	#$4000,d4
	move.w	d4,d2
	bra.s	.fin

.e9:	cmp.b	#9,d3		; Retrig sample
	bne.s	.e10
	lsl.w	#8,d4
	add.w	#$7000,d4
	move.w	d4,d2
	bra.s	.fin

.e10:	cmp.b	#10,d3		; Fine vol up
	bne.s	.e11
	move.w	#$a400,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra.s	.fin

.e11:	cmp.b	#11,d3		; Fine vol down
	bne.s	.e12
	move.w	#$a500,d2
	add.b	d4,d4
	add.b	d4,d4
	add.b	d4,d2
	bra.s	.fin

.e12:	cmp.b	#12,d3		; Note cut
	bne.s	.e13
	add.w	#$a00,d4
	move.w	d4,d2
	bra.s	.fin

.e13:	cmp.b	#13,d3		; Note delay
	bne.s	.ee
	add.w	#$a00,d4
	move.w	d4,d2
	bra.s	.fin

.ee:	cmp.b	#$e,d3		; Pattern delay
	bne.s	.defaut
	add.w	#$aa00,d4
	move.w	d4,d2
	bra.s	.fin

.defaut:	clr.w	d2		; rien par d‚faut
.fin:	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Effectue le bouclage de tous les samples d'un module au	;
;	format interne.					;
;	ParamŠtres :					;
;	- L adrmod : Adresse du module				;
;	- L adrbuf : Adresse d'une zone pour les buffers (256Ko maxi)	;
;	- L adradrbuf : Adresse d'un tableau de 256 Longs destin‚ …	;
;		contenir les adresses des buffers. Si cette adresse	;
;		est nulle, les buffers sont directement assign‚s au	;
;		module en cours de replay, ainsi que les adresses des	;
;		samples					;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_make_rb_module:
	movem.l	d1-a5,-(sp)
	move.l	0+52+4(sp),a0	; a0 = adresse du module

	tst.b	3(a0)
	bne	.error

	move.l	4+52+4(sp),a1	; a1 = adresse des buffers
	move.l	8+52+4(sp),d1	; a2 = adresse du bloc d'adresses des buffers
	bne.s	.aabufok
	move.l	#gtkpl_module_inf1+adr_repbuf,d1	; Assigne les pointeurs au module
.aabufok:	move.l	d1,a2
	lea	gtkr_zone_vide,a3	; a3 pointe sur une zone vide (unique buffer pour les samples vides)

	moveq	#NBRSAMPLES_MAXI/2-1,d1
.fill:	move.l	a3,adr_samples-adr_repbuf(a2)	; Par d‚faut, tous les buffers sont vides
	move.l	a3,(a2)+
	move.l	a3,adr_samples-adr_repbuf(a2)
	move.l	a3,(a2)+
	dbra	d1,.fill
	lea	-NBRSAMPLES_MAXI*4(a2),a2

;--- Recherche de la position des samples dans le module ---------------------
	move.w	196(a0),d1		; d1 = nombre de samples (sans compter le nø0)
	lea	206(a0),a4
	moveq	#next_s,d2
	mulu.w	d1,d2
	add.l	#next_s,d2		; Taille des headers
	add.l	d2,a4
	moveq	#0,d2
	move.w	202(a0),d3
	subq.w	#1,d3
.loop2:	cmp.w	(a4,d3.w*2),d2
	bge.s	.next2
	move.w	(a4,d3.w*2),d2
.next2:	dbra	d3,.loop2
	addq.w	#1,d2		; Pattern maxi
	mulu.w	200(a0),d2
	mulu.w	198(a0),d2
	mulu.l	#5,d2
	add.l	d2,a4
	add.w	#512,a4		; a4 pointe sur le premier sample
	lea	206(a0),a0		; a0 pointe sur les headers
	moveq	#0,d2		; d2 = taille du groupe de buffers

;--- Bouclage de chaque sample -----------------------------------------------
.loop:	tst.l	repeat_s(a0)
	bne.s	.normal
	cmp.l	#2,replen_s(a0)
	bgt.s	.normal
	tst.l	length_s(a0)
	beq.s	.next		; Rien si c'est le sample vide
.normal:	move.l	a4,adr_samples-adr_repbuf(a2)
	move.w	nbits_s(a0),-(sp)
	move.l	replen_s(a0),-(sp)
	move.l	repeat_s(a0),-(sp)
	move.l	length_s(a0),-(sp)
	move.l	a1,-(sp)
	move.l	a4,-(sp)
	bsr	gtkr_make_rbuffer	; Boucle
	lea	22(sp),sp
	move.l	a1,(a2)
	add.w	#1024,a1
	add.l	#1024,d2
	add.l	length_s(a0),a4
.next:	add.w	#next_s,a0		; Header suivant
	addq.l	#4,a2
	dbra	d1,.loop
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; Ce n'est pas un module au format interne

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Demande les adresses des samples et des buffers de bouclage	;
;	du module en cours					;
;	PramŠtres :					;
;	- L ptr : Pointe sur une zone de 256 L + 256 L qui recevra	;
;		les adresses des samples et les adresses des buffers	;
;		de bouclage.				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_get_adr_samples:
	movem.l	d1-a5,-(sp)
	move.l	0+52+4(sp),a0	; a0 = pointeur
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
;	Fixe les adresses des samples et des buffers de bouclage	;
;	du module en cours. Si une des adresse est nulle, elle		;
;	n'est pas modifi‚e.					;
;	PramŠtres :					;
;	- L ptr : Pointe sur une zone de 256 L + 256 L qui contient	;
;		les adresses des samples et les adresses des buffers	;
;		de bouclage.				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_set_adr_samples:
	movem.l	d1-a5,-(sp)
	move.l	0+52+4(sp),a0	; a0 = pointeur

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
;	Initialise un module au format interne et commence le replay	;
;	ParamŠtres :					;
;	- L adrmod : Adresse du module				;
;	- L adrrep : Adresse des buffers de r‚p‚tition des samples	;
;		destin‚s … ˆtre calcul‚s (1 Ko/sample, 256 Ko maxi).	;
;	Si cette adresse est nulle, rien n'est chang‚.		;
;	- W songpos : Position de d‚part				;
;	- W linepos : Ligne de d‚part				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_new_module:
	movem.l	d1-a5,-(sp)
	move.l	0+52+4(sp),a0	; a0 = adresse du module
	tst.b	3(a0)
	bne	.error

	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod
	lea	gtkpl_module_inf2,a2	; a2 pointe sur les infos du mod

	bsr	gtkr_stop_module	; Arrˆte ce qu'il y avait avant

	move.l	4+52+4(sp),d1
	beq.s	.calcbuffin
	pea	0.l
	move.l	d1,-(sp)
	pea	(a0)
	bsr	gtkr_make_rb_module
	lea	12(sp),sp
.calcbuffin:

	move.w	200(a0),d1		; R‚serve les pistes
	subq.w	#2,d1
	bmi.s	.ok		; 1 piste, elle est d‚j… r‚serv‚e
	lea	gtkpl_num_track+2,a3

.loop:	move.w	#$ffff,-(sp)
	bsr	gtkr_reserve_track
	addq.l	#2,sp
	tst.w	d0
	bmi	.error2
	move.w	d0,(a3)+		; Piste r‚serv‚e
	dbra	d1,.loop

.ok:	lea	gtkpl_num_track,a3	; Fixe les balances
	moveq	#0,d2
	moveq	#0,d3
	move.w	200(a0),d1
	subq.w	#1,d1
.loopbal:
	move.w	(a3)+,d0		; Num‚ro de piste pour cette voie
	mulu.w	#next_t,d0
	move.w	d2,([gtkpl_adr_info_track],d0.l,bal_t)
	eor.w	#$fff,d3		; Ca permet de faire changer la
	eor.w	d3,d2		; balance que 1 voie sur 2 (0 / FFF)
	dbra	d1,.loopbal

	lea	206(a0),a3
	move.l	a3,adr_instrheader(a1)
	move.w	196(a0),d1
	addq.w	#1,d1
	mulu.w	#next_s,d1
	add.l	d1,a3
	move.l	a3,adr_song(a1)
	lea	512(a3),a3
	move.l	a3,adr_pattern(a1)

	move.w	200(a0),mod_nbrtrack(a2)
	bsr	gtkr_reset_sndtrk_tracks	; Reset les pistes r‚serv‚es

	move.w	198(a0),mod_nbrlines(a2)
	move.w	202(a0),mod_songlen(a2)
	move.w	204(a0),mod_songrep(a2)
	move.w	8+52+4(sp),d1
	move.w	d1,mod_songpos(a2)
	move.w	10+52+4(sp),mod_linepos(a2)
	move.w	d1,mod_cursongpos(a2)
	move.w	10+52+4(sp),mod_curlinepos(a2)
	move.w	([adr_song,a1],d1.w*2),mod_numpat(a2)
	move.w	#6,mod_speed(a2)
	clr.w	mod_patrep(a2)
	move.w	#-1,mod_nbrticks(a2)
	move.w	#1,mod_vblnumber(a2)
	clr.w	mod_vblcpt(a2)
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; Le module n'est pas au format interne
	bra.s	.fin

.error2:	moveq	#-2,d0		; Il n'y a pas assez de piste libre

.fin:	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Arrˆte de jouer le module en cours. Un nouveau module devra	;
;	ˆtre r‚initialis‚ si on veut jouer quelque chose aprŠs.	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_stop_module:
	movem.l	d1-a5,-(sp)

	lea	gtkpl_module_inf2,a0	; a0 pointe sur les infos du mod
	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod

	bsr	gtkr_reset_sndtrk_tracks

	move.w	gtkpl_module_inf2+mod_nbrtrack,d1	; LibŠre les voies sauf la 1Šre
	subq.w	#2,d1
	bmi.s	.ok
	lea	gtkpl_num_track+2,a0

.loop:	move.w	(a0)+,-(sp)
	bsr	gtkr_free_track
	addq.l	#2,sp
	dbra	d1,.loop

.ok:
	move.w	#1,mod_nbrtrack(a0)	; On lui fait jouer un module bidon
	move.w	#1,mod_nbrlines(a0)
	move.w	#1,mod_songlen(a0)
	clr.w	mod_songrep(a0)
	clr.w	mod_songpos(a0)
	clr.w	mod_numpat(a0)
	clr.w	mod_linepos(a0)
	clr.w	mod_cursongpos(a0)
	clr.w	mod_curlinepos(a0)
	move.w	#6,mod_speed(a0)
	clr.w	mod_patrep(a0)
	move.w	#-1,mod_nbrticks(a0)
	move.w	#1,mod_vblnumber(a0)
	clr.w	mod_vblcpt(a0)

	lea	gtkr_zone_vide,a3
	move.l	a3,adr_song(a1)
	move.l	a3,adr_pattern(a1)
	move.l	a3,adr_instrheader(a1)

	moveq	#0,d0
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Mets le module en cours en pause				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_pause_module:
	movem.l	d1-a5,-(sp)
	cmp.w	#2,gtkpl_flag_stop_vcs
	beq.s	.error
	cmp.w	#3,gtkpl_flag_stop_vcs
	beq.s	.error

.wait:	tst.w	gtkpl_flag_stop_vcs	; Attend qu'on soit bien en phase normale
	bne.s	.wait
	move.w	#2,gtkpl_flag_stop_vcs
.wait2:	cmp.w	#3,gtkpl_flag_stop_vcs
	bne.s	.wait
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; On ‚tait d‚j… en pause

.fin:
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Remet un module en pause en marche			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_cont_module:
	movem.l	d1-a5,-(sp)

.wait:	cmp.w	#3,gtkpl_flag_stop_vcs
	beq.s	.ok
	cmp.w	#2,gtkpl_flag_stop_vcs
	bne.s	.error
	bra.s	.wait

.ok:	move.w	#0,gtkpl_flag_stop_vcs
.wait2:	tst.w	gtkpl_flag_stop_vcs
	bne.s	.wait2
	moveq	#0,d0
	bra.s	.fin

.error:	moveq	#-1,d0		; On n'‚tait pas en pause

.fin:
	movem.l	(sp)+,d1-a5
	rts



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;	Change la position d'un module en cours de replay		;
;	ParamŠtres :					;
;	- W songpos : Nouvelle position 				;
;	- W linepos : Nouvelle ligne				;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gtkr_change_modpos:
	movem.l	d1-a5,-(sp)

	lea	gtkpl_module_inf1,a1	; a1 pointe sur les adr du mod
	lea	gtkpl_module_inf2,a2	; a2 pointe sur les infos du mod

	move.w	0+52+4(sp),d1	; Position
	cmp.w	mod_songlen(a2),d1
	bge.s	.error1
	move.w	d1,mod_songpos(a2)
	move.w	d1,mod_cursongpos(a2)

	move.w	2+52+4(sp),d1	; Ligne
	cmp.w	mod_nbrlines(a2),d1
	bge.s	.error2
	move.w	d1,mod_linepos(a2)
	move.w	d1,mod_curlinepos(a2)

	move.w	([adr_song,a1],d1.w*2),mod_numpat(a2)
	clr.w	mod_patrep(a2)
	move.w	#-1,mod_nbrticks(a2)
	clr.w	mod_vblcpt(a2)
	moveq	#0,d0
	bra.s	.fin

.error1:	moveq	#-1,d0		; Position hors de la song
	bra.s	.fin

.error2:	moveq	#-2,d0		; Num‚ro de ligne hors du pattern

.fin:	movem.l	(sp)+,d1-a5
	rts




*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Gestion de la partition pour modules .GTK			*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Cette routine est appel‚e sous interruption, par l'interm‚diaire	*
*	du noyau.						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
gestion_partition:

	movem.l	d0-a6,-(sp)

	lea	gtkpl_module_inf2,a0	; a0 pointe sur le bloc 2 d'informations
	lea	gtkpl_module_inf1,a1	; a1 pointe sur le bloc 1 d'informations
	lea	per_table(pc),a5	; a5 pointe sur la table des p‚riodes

	addq.w	#1,mod_vblcpt(a0)	; Compteur de VBL pour faire un tick
	move.w	mod_vblnumber(a0),d0
	cmp.w	mod_vblcpt(a0),d0
	bgt	fin_gestion_partition	; Tick pas fini : rien … faire
	clr.w	mod_vblcpt(a0)

;--- Demande d'arrˆt de toutes les voies ? -----------------------------------
	tst.w	gtkpl_flag_stop_vcs
	beq	gp_new_vbl
	cmp.w	#1,gtkpl_flag_stop_vcs	; Ordre d'arrˆt
	beq.s	.stop
	cmp.w	#2,gtkpl_flag_stop_vcs	; Ordre de pause (volume … 0)
	beq	.pause
	cmp.w	#4,gtkpl_flag_stop_vcs	; Ordre de fin de pause
	beq	.finpause
	bra	fin_gestion_partition		; D‚j… en pause, on ne fait rien

;--- R‚initialise les voies --------------------------------------------------
.stop:	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	lea	gtkr_zone_vide,a2
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
	move.l	#gtkr_zone_vide,rbuffer_t(a4)
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
	clr.w	ploopn_t(a4)
	dbra	d0,.loop
	clr.w	gtkpl_flag_stop_vcs	; On a fini le nettoyage
	bra	fin_gestion_partition

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
	bra	fin_gestion_partition

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
gp_new_vbl:
	move.w	mod_nbrticks(a0),d0	; Nouvelle vbl
	addq.w	#1,d0
	move.w	mod_songpos(a0),mod_cursongpos(a0)	; Actualise la position
	move.w	mod_linepos(a0),mod_curlinepos(a0)
	cmp.w	mod_speed(a0),d0	; Fin de la ligne courante ?
	blt	.suite_ligne
	moveq	#0,d0
	tst.w	mod_patrep(a0)	; R‚p‚tition de la ligne ?
	beq.s	.ok		; Non, on s'en fout

	subq.w	#1,mod_patrep(a0)	; R‚p‚tition -1
	move.w	d0,mod_nbrticks(a0)
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie
	bra	pas_seulement_1ere_vbl	; ... puis on passe … la suite

.ok:	move.w	mod_linepos(a0),d1	; Alors passe … la ligne d‚ja calcul‚e
	move.w	mod_numpat(a0),d3	; Met dans chaque descripteur de voie une partie
	mulu.w	mod_nbrlines(a0),d3	; de la ligne
	add.w	d1,d3
	mulu.w	mod_nbrtrack(a0),d3
	lea	([adr_pattern,a1],d3.l*4),a2
	lea	(a2,d3.l),a2	; a2 contient l'adresse de la nouvelle ligne
	move.w	mod_nbrtrack(a0),d3
	subq.w	#1,d3		; d3 contient le nombre de voies -1
	lea	gtkpl_num_track,a4
.loop:
	move.w	(a4)+,d4
	mulu.w	#next_t,d4
	lea	([gtkpl_adr_info_track],c_n_t+1,d4.l),a3	; a3 pointe sur l'octet bas de la note
	move.b	(a2)+,(a3)		; Recopie la note
	move.b	(a2)+,2(a3)	; Recopie l'instrument
	move.w	(a2)+,3(a3)	; Recopie l'effet
	move.b	(a2)+,6(a3)	; Recopie la  commande de volume
	add.w	#next_t,a3		; Voie suivante
	dbra	d3,.loop
	addq.w	#1,d1		; Calcule la prochaine ligne
	cmp.w	mod_nbrlines(a0),d1	; Fin du pattern ?
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
	bne	pas_seulement_1ere_vbl
	tst.w	mod_patrep(a0)	; Sinon, c'est en cours de r‚p‚tition ?
	bne	pas_seulement_1ere_vbl

premvbl_loop:			; Boucle de test si c'est la premiŠre vbl
;--- D‚code les diff‚rentes parties d'une ligne ------------------------------
	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	sub.w	d7,d0
	lea	gtkpl_num_track,a4
	move.w	(a4,d0.w*2),d0
	mulu.w	#next_t,d0
	lea	([gtkpl_adr_info_track],d0.l),a3	; a3 pointe sur les informations des voies

	move.w	c_n_t(a3),d0	; d0 = note
	move.w	c_i_t(a3),d1	; d1 = instrument
	move.w	c_e_t(a3),d2	; d2 = effet

	tst.w	d1
	bne.s	.instrum		; S'il y a instrument
	tst.w	d0
	bne.s	pas_instrument	; S'il y a note sans instr
	tst.w	d2
	bne	effets1		; Seulement l'effet
	tst.w	c_v_t(a3)
	beq	fx_fin1		; Pas de volume on se tire
	bra	effets1

;--- Instrument d‚tect‚ ------------------------------------------------------
.instrum:	move.w	d2,d3
	and.w	#$FF00,d3		; d3 = num‚ro de l'effet 2 chiffres
	cmp.w	#$900,d3		; Note delay, on s'en va directos
	beq	effets1_no_vol

	tst.w	d1		; Y a-t-il un instrument ?
	beq.s	pas_instrument
	move.w	d1,ninstr_t(a3)	; Oui, il devient l'instrument courant
	moveq	#next_s,d3
	mulu.w	d1,d3		; Recopie le finetune et le volume de l'instrument
	lea	([adr_instrheader,a1],d3.w,vol_s),a2
	move.l	(a2),norm_v_t(a3)	; dans la voie
	move.w	autobal_s-vol_s(a2),d3
	bmi.s	.pasbalnc
	move.w	d3,bal_t(a3)	; Avec la balance
.pasbalnc:	move.w	norm_v_t(a3),d3
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Sans oublier le volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant aussi

;--- Note --------------------------------------------------------------------
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
	sub.w	#24,d3
	lsl.w	#3,d3
	add.w	norm_f_t(a3),d3
	move.w	(a5,d3.w*2),per2sl_t(a3)	; on met la p‚riode de c“t‚
	move.w	c_v_t(a3),d3	; Commande de volume ?
	beq	fx_fin1
	lea	vlin_2_exp(pc),a4
	move.w	(a4,d3.w*2),volenot_t(a3)	; Volume exponentiel
	lsl.w	#3,d3
	move.w	d3,vollnot_t(a3)	; Volume courant ajust‚
	bra	fx_fin1
pas_tone_p:
	move.w	d0,curnote_t(a3)
	move.w	d0,note2sl_t(a3)
	move.w	d0,d3
	sub.w	#24,d3
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
	move.w	d2,d3		; Offset sample
	sub.w	#$9000,d3
	lsl.l	#8,d3
fin_ppart:	move.l	d3,pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
	move.w	ninstr_t(a3),d1
	move.l	(adr_samples,a1,d1.w*4),adrsam_t(a3)	; Recopie l'adresse du sample,
	move.w	d1,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	#adr_repbuf,d3
	move.l	(a1,d3.w),rbuffer_t(a3)	; l'adresse du buffer de r‚p‚tition,
	moveq	#next_s,d3
	mulu.w	d1,d3
	lea	([adr_instrheader,a1],d3.w),a4
	move.w	nbits_s(a4),nbits_t(a3)	; Nombre de bits
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

effets1:
;ððð L… on gŠre les effets qui n'agissent qu'en d‚but de note ðððððððððððððððð
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
	cmp.w	#$bf,d3		; section a0xx - bfxx
	bgt.s	.ef1ch
	sub.w	#$80,d3		; transforme en 20xx - 3fxx
.saute:	and.w	#$FF,d4		; d4 = paramŠtre 8 bits
	jmp	([fx_table_de_sauts1,d3.w*4])	; On saute dans la bonne routine

.ef1ch:	lsr.b	#4,d3		; Pour les effets … 1 chiffre
	and.w	#$FFF,d4		; d4 = paramŠtre 12 bits

	cmp.b	#2,d3		; Set linear volume
	bne.s	.e_3
	IFNE	CHECK=2
	cmp.w	#$100,d4
	ble.s	.ok2
	move.w	#$100,d4
	ENDC
.ok2:	lea	vlin_2_exp(pc),a4
	move	(a4,d4.w*2),volenot_t(a3)
	lsl.w	#3,d4
	move.w	d4,vollnot_t(a3)
	bra	fx_fin1

.e_3:	cmp.b	#3,d3		; Set exponential volume
	bne.s	.e_4
	IFNE	CHECK=2
	cmp.w	#$800,d4
	ble.s	.ok3
	move.w	#$800,d4
	ENDC
.ok3:	move.w	d4,volenot_t(a3)
	lea	vexp_2_lin(pc),a4
	move.w	(a4,d4.w*2),vollnot_t(a3)
	bra	fx_fin1

.e_4:	cmp.b	#4,d3		; Balance
	bne.s	.e_5
	move.w	d4,bal_t(a3)
	bra	fx_fin1

.e_5:	cmp.b	#5,d3		; Set linear master volume
	bne.s	.e_6
	IFNE	CHECK=2
	cmp.w	#$FFF,d4
	ble.s	.ok5
	move.w	#$FFF,d4
	ENDC
.ok5:	move.w	d4,-(sp)
	bsr	gtkr_set_master_vol
	addq.l	#2,sp
	bra.s	fx_fin1

.e_6:	cmp.b	#6,d3
	bne.s	.e_7
	lea	vexp_2_lin_master(pc),a4	; Set exponential master volume
	move.w	(a4,d4.w*2),-(sp)
	bsr	gtkr_set_master_vol
	addq.l	#2,sp
	bra.s	fx_fin1

.e_7:	cmp.b	#7,d3
	bne.s	.e_8
	move.w	d4,d5		; Roll (simple)
	and.w	#$FF,d5		; d5 = nbr de coups maxi
	bne.s	.pl7
	moveq	#-1,d5		; Si d5 = 0, r‚p‚titions infinies
.pl7:	move.w	d5,rollnbr_t(a3)
	lsr.w	#8,d4		; d4 = vitesse
	beq.s	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra.s	fx_fin1

.e_8:	cmp.b	#8,d3		; Roll + volume slide + set balance (init)
	beq	fx_roll_and_vsl_and_sbl_init

fx_fin1:
	dbra	d7,premvbl_loop
	move.w	mod_nbrtrack(a0),d7
	subq.w	#1,d7		; d7 = compteur de voie

pas_seulement_1ere_vbl:
;ððð Ici on ex‚cute les effets qui agissent pendant toute la dur‚e de la note ððð
	move.w	mod_nbrtrack(a0),d0
	subq.w	#1,d0
	sub.w	d7,d0
	lea	gtkpl_num_track,a4
	move.w	(a4,d0.w*2),d0
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
.saute:
	and.w	#$FF,d4
	jmp	([fx_table_de_sauts2,d3.w*4])	; On saute dans la bonne routine

.ef1ch2:	lsr.b	#4,d3		; Encore une fois, les effets … 1 chiffre
	and.w	#$FFF,d4

	cmp.b	#7,d3
	beq	fx_roll_7		; Roll (simple)
	cmp.b	#8,d3
	beq	fx_roll_and_vsl	; Roll + vol slide + set bal

fx_fin_normale:			; C'est l'adresse normale de retour
	move.w	vollnot_t(a3),vol_t(a3)	; Les routines qui modifient normalement
	move.w	pernote_t(a3),per_t(a3)	; les paramŠtres passent par l…
fx_fin_speciale:
	dbra	d7,pas_seulement_1ere_vbl

fin_gestion_partition:
	movem.l	(sp)+,d0-a6
	rts



;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð
;	Effets agissant seulement au d‚but d'une note
;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð

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
	sub.w	#24,d3
	lsl.w	#3,d3
	add.w	d5,d3
	move.w	(a5,d3.w*2),pernote_t(a3)	; Sinon on corrige la note
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Note cut (initialisation)
;-----------------------------------------------------------------------------
fx_note_precut:
	move.w	d4,cut_del_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Jump to position
;-----------------------------------------------------------------------------
fx_pos_jump:
	IFNE	CHECK
	cmp.w	mod_songlen(a0),d4
	bge	fx_fin1
	ENDC
	move.w	d4,mod_songpos(a0)	; Nouvelle position
	move.w	([adr_song,a1],d4.w*2),mod_numpat(a0)	; Trouve le nouveau pattern
	clr.w	mod_linepos(a0)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set vibrato wave
;-----------------------------------------------------------------------------
fx_set_vib_wave:
	IFNE	CHECK=2
	and.b	#3,d4
	ENDC
	move.b	d4,vibwav_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set tremolo wave
;-----------------------------------------------------------------------------
fx_set_trem_wave:
	IFNE	CHECK=2
	and.b	#3,d4
	ENDC
	move.b	d4,tremwav_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Break pattern & jump to line
;-----------------------------------------------------------------------------
fx_break_pat:
	move.w	mod_cursongpos(a0),d3
	addq.w	#1,d3		; Nouvelle position
	cmp.w	mod_songlen(a0),d3	; Fin de la song ?
	blt.s	.s_song
	move.w	mod_songrep(a0),d3	; Oui, bouclage
.s_song:	move.w	d3,mod_songpos(a0)
	move.w	([adr_song,a1],d3.w*2),mod_numpat(a0)	; Trouve le nouveau pattern
	IFNE	CHECK=2
	cmp.w	mod_nbrlines(a0),d4
	blt.s	.ok
	moveq	#0,d4		; Si la nouvelle ligne est en dehors du pattern
	ENDC
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
	bra	fx_fin1
.doloop:	tst.w	ploopn_t(a3)	; D‚j… dans une boucle ?
	beq.s	.suite		; Non, nouveau compteur
	move.w	ploopn_t(a3),d4	; d4 = nbr de r‚p‚tition … faire
	subq.w	#1,d4		; Boucle -1
.suite:	move.w	d4,ploopn_t(a3)
	beq	fx_fin1		; Si on en est … 0, fin de la boucle
	move.w	ploopp_t(a3),mod_linepos(a0)	; Point de bouclage
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set global speed
;-----------------------------------------------------------------------------
fx_set_global_speed:
	tst.w	d4
	beq	fx_fin1
	cmp.w	#31,d4
	bgt.s	.tempo
	move.w	d4,mod_speed(a0)
	move.w	#REPLAY_FREQ*60/125/4/6,-(sp)
	bsr	gtkr_set_vblsize
	addq.l	#2,sp
	bra	fx_fin1
.tempo:	lea	tempo_table(pc),a4
	move.w	-126(a4,d4.w*4),-(sp)
	bsr	gtkr_set_vblsize
	addq.l	#2,sp
	move.w	-128(a4,d4.w*4),mod_vblnumber(a0)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set number of frames
;-----------------------------------------------------------------------------
fx_set_nbr_of_frames:
	IFNE	CHECK=2
	tst.w	d4
	beq	fx_fin1
	ENDC
	move.w	d4,mod_speed(a0)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Set fine speed
;-----------------------------------------------------------------------------
fx_set_fine_speed:
	add.w	d4,d4
	IFNE	CHECK=2
	beq	fx_fin1
	ENDC
	add.w	#REPLAY_FREQ*60/125/4/6-256,d4
	move.w	d4,-(sp)
	bsr	gtkr_set_vblsize
	addq.l	#2,sp
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine portamento up
;-----------------------------------------------------------------------------
fx_fine_porta_up:
	move.w	pernote_t(a3),d5
	lsl.w	#4,d4
	sub.w	d4,d5
	IFNE	CHECK
	cmp.w	#768,d5
	bge.s	.ok
	move.w	#768,d5
	ENDC
.ok:	move.w	d5,pernote_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine portamento down
;-----------------------------------------------------------------------------
fx_fine_porta_down:
	IFNE	CHECK
	ext.l	d4
	ENDC
	lsl.w	#4,d4
	add.w	pernote_t(a3),d4
	IFNE	CHECK
	cmp.l	#32575,d4
	ble.s	.ok
	move.w	#32575,d4
	ENDC
.ok:	move.w	d4,pernote_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Note delay - initialisation
;-----------------------------------------------------------------------------
fx_predelay:
	move.w	d4,delay_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine volume slide (linear)
;-----------------------------------------------------------------------------
fx_fine_v_sldown_l:			; Fine volume slide down (lin) \
	neg.w	d4		;                               > *** Ne pas s‚parer
fx_fine_v_slup_l:			; Fine volume slide up (lin)   /
	bsr	fx_do_v_slide_l
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Fine volume slide (exponential)
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
	move.w	d5,bal_t(a3)	; Fixe la balance
	and.w	#15,d4		; d4 = vitesse
	beq	fx_fin1		; Si vitesse = 0, r‚p‚titions continues
	move.b	d4,rollspd_t(a3)
	clr.b	rollcpt_t(a3)
	bra	fx_fin1

;-----------------------------------------------------------------------------
;	Tremor (initialisation)
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






;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð
;	Effets agissant pendant la note
;ððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððððð

;-----------------------------------------------------------------------------
;	Arpeggio
;-----------------------------------------------------------------------------
fx_arpeggio:
	moveq	#0,d5
	move.w	mod_nbrticks(a0),d5
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
	sub.w	#24,d4
	lsl.w	#3,d4
	add.w	norm_f_t(a3),d4
	move.w	(a5,d4.w*2),d4
	IFNE	CHECK
	cmp.w	#768,d4
	bge.s	.suite2
	move.w	#768,d4
	ENDC
.suite2:	move.w	d4,per_t(a3)
	move.w	vollnot_t(a3),vol_t(a3)	; On met le bon volume car on ne
	bra	fx_fin_speciale		; repasse pas par la fin normale

;-----------------------------------------------------------------------------
;	(Fine) Portamento up
;-----------------------------------------------------------------------------
fx_porta_up:			; \
	lsl.w	#4,d4		;  > *** Ne pas s‚parer
fx_extra_fine_porta_up:		; /
	sub.w	d4,pernote_t(a3)
	IFNE	CHECK
	cmp.w	#768,pernote_t(a3)
	bge	fx_fin_normale
	move.w	#768,pernote_t(a3)
	ENDC
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	(Fine) Portamento down
;-----------------------------------------------------------------------------
fx_porta_down:			; \
	lsl.w	#4,d4		;  > *** Ne pas s‚parer
fx_extra_fine_porta_down:		; /
	ext.l	d4
	add.w	pernote_t(a3),d4
	IFNE	CHECK
	cmp.l	#32575,d4
	ble.s	.suite
	move.w	#32575,d4
	ENDC
.suite:	move.w	d4,pernote_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	(Extra fine) Tone portamento
;-----------------------------------------------------------------------------
fx_tone_porta:
	bsr.s	fx_do_tone_porta
	bra	fx_fin_normale

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
	tst.w	d4		; Retour par fx_fin_speciale !
	beq.s	.suite
	move.w	d4,d5
	and.w	#$f,d4
	move.b	d4,vibamp_t(a3)
	lsr.w	#2,d5
	and.w	#$3c,d5
	move.b	d5,vibspd_t(a3)
.suite:	moveq	#0,d3
	move.b	vibcpt_t(a3),d3
	move.b	vibwav_t(a3),d4
	and.b	#3,d4
	beq.s	.sinus		; Forme sinus : 0
	subq.b	#1,d4
	bne.s	.carre		; Forme carr‚e : 2 (ou 3)
	add.b	d3,d3		; Forme triangulaire : 1
	bpl.s	.positif
	not.b	d3		; Si c'est n‚gatif
.positif:	add.b	d3,d3
	bra.s	.commun
.carre:	move.w	#255,d3
	bra.s	.commun
.sinus:	lsr.w	#2,d3
	and.w	#$1f,d3		; d3 = offset dans la table de sinus
	lea	sin_table_gtk(pc),a4
	move.w	(a4,d3.w*2),d3	; d3 = sinus
.commun:	move.b	vibamp_t(a3),d4
	and.w	#$f,d4
	mulu.w	d4,d3		; Multiplie par l'amplitude
	lsr.w	#3,d3
	move.w	pernote_t(a3),d4
	tst.b	vibcpt_t(a3)	; N‚gatif ?
	bpl.s	.negatif
	add.w	d3,d4		; Nouvelle p‚riode de la note
	bra.s	.ok
.negatif:	sub.w	d3,d4		; Nouvelle p‚riode de la note
.ok:	move.b	vibspd_t(a3),d3
	add.b	d3,vibcpt_t(a3)	; Ajoute la fr‚quence
	move.w	d4,per_t(a3)	; Valide la nouvelle p‚riode
	move.w	vollnot_t(a3),vol_t(a3)	; Met le volume
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
;	Vibrato + Tone portamento
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
	tst.w	d4
	beq.s	.suite
	move.w	d4,d5
	and.w	#$f,d4
	move.b	d4,tremamp_t(a3)
	lsr.w	#2,d5
	and.w	#$3c,d5
	move.b	d5,tremspd_t(a3)
.suite:	moveq	#0,d3
	move.b	tremcpt_t(a3),d3
	move.b	tremwav_t(a3),d4
	and.b	#3,d4
	beq.s	.sinus		; Forme sinus : 0
	subq.b	#1,d4
	bne.s	.carre		; Forme carr‚e : 2 (ou 3)
	add.b	d3,d3		; Forme triangulaire : 1
	bpl.s	.positif
	not.b	d3		; Si c'est n‚gatif
.positif:	add.b	d3,d3
	bra.s	.commun
.carre:	move.w	#255,d3
	bra.s	.commun
.sinus:	lsr.w	#2,d3
	and.w	#$1f,d3		; d3 = offset dans la table de sinus
	lea	sin_table_gtk(pc),a4
	move.w	(a4,d3.w*2),d3	; d3 = sinus
.commun:	move.b	tremamp_t(a3),d4
	and.w	#$f,d4
	mulu.w	d4,d3		; Multiplie par l'amplitude
	lsr.w	#1,d3
	move.w	vollnot_t(a3),d4
	tst.b	tremcpt_t(a3)	; N‚gatif ?
	bmi.s	.negatif
	add.w	d3,d4		; Nouveau volume de la note
	IFNE	CHECK
	cmp.w	#$800,d4
	ble.s	.ok
	move.w	#$800,d4
	ENDC
	bra.s	.ok
.negatif:	sub.w	d3,d4		; Nouveau volume de la note
	IFNE	CHECK
	bpl.s	.ok
	moveq	#0,d4
	ENDC
.ok:	move.b	tremspd_t(a3),d3
	add.b	d3,tremcpt_t(a3)	; Ajoute la fr‚quence
	move.w	d4,vol_t(a3)	; Valide le nouveau volume
	move.w	pernote_t(a3),per_t(a3)	; Met la p‚riode
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
	beq.s	.pas_inst
	move.w	d1,ninstr_t(a3)	; Oui, il devient l'instrument courant
	moveq	#next_s,d3
	mulu.w	d1,d3		; Recopie le finetune et le volume de l'instrument
	lea	([adr_instrheader,a1],d3.w),a4
	move.l	vol_s(a4),norm_v_t(a3)	; dans la voie
	move.w	nbits_s(a4),nbits_t(a3)	; Nombre de bits
	move.w	fech_s(a4),fech_t(a3)		; Fr‚quence d'‚chantillonnage
	move.w	autobal_s(a4),d3
	bmi.s	.pasbalnc
	move.w	d3,bal_t(a3)		; La balance
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
	sub.w	#24,d3
	lsl.w	#3,d3
	add.w	norm_f_t(a3),d3
	add.w	d3,d3
	move.w	(a5,d3.w),pernote_t(a3)	; Sinon c'est une note normale
	move.w	(a5,d3.w),per2sl_t(a3)
	clr.l	pos_t(a3)
	clr.w	finepos_t(a3)
	clr.w	tremorc_t(a3)
	move.w	ninstr_t(a3),d1
	move.l	(adr_samples,a1,d1.w*4),adrsam_t(a3)	; Recopie l'adresse du sample,
	move.w	d1,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	#adr_repbuf,d3
	move.l	(a1,d3.w),rbuffer_t(a3)	; l'adresse du buffer de r‚p‚tition,
	moveq	#next_s,d3
	mulu.w	d1,d3
	lea	([adr_instrheader,a1],d3.w,repeat_s),a4
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

;-----------------------------------------------------------------------------
;	Note cut
;-----------------------------------------------------------------------------
fx_note_cut:			; Note Cut
	tst.w	cut_del_t(a3)	; Compteur … 0 ?
	bmi	fx_fin_normale	; -1, plus besoin de l'effet
	bne.s	.nxt_vbl		; <>0 , on attend encore
	clr.w	vollnot_t(a3)
	clr.w	volenot_t(a3)
.nxt_vbl:	subq.w	#1,cut_del_t(a3)
	bra	fx_fin_normale

;-----------------------------------------------------------------------------
;	Linear volume slide
;-----------------------------------------------------------------------------
fx_v_sldown_l:			; Volume slide down (lin) \
	neg.w	d4		;                          > *** Ne pas s‚parer
fx_v_slup_l:			; Volume slide up (lin)   /
	bsr.s	fx_do_v_slide_l
	bra	fx_fin_normale

fx_do_v_slide_l:			; Sous-routine de volume slide (lin.)
	move.w	vollnot_t(a3),d5
	lsr.w	#3,d5
	add.w	d5,d4
	IFNE	CHECK
	tst.w	d4
	bgt.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$100,d4
	ble.s	.ok2
	move.w	#$100,d4
	ENDC
.ok2:	lea	vlin_2_exp(pc),a4
	move	(a4,d4.w*2),volenot_t(a3)
	lsl.w	#3,d4
	move.w	d4,vollnot_t(a3)
	rts

;-----------------------------------------------------------------------------
;	Exponential volume slide
;-----------------------------------------------------------------------------
fx_v_sldown_e:			; Volume slide down (exp) \
	neg.w	d4		;                          > *** Ne pas s‚parer
fx_v_slup_e:			; Volume slide up (exp)   /
	bsr.s	fx_do_v_slide_e
	bra	fx_fin_normale

fx_do_v_slide_e:			; Sous-routine de volume slide (exp.)
	add.w	volenot_t(a3),d4
	IFNE	CHECK
	tst.w	d4
	bgt.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$800,d4
	ble.s	.ok2
	move.w	#$800,d4
	ENDC
.ok2:	move.w	d4,volenot_t(a3)
	lea	vexp_2_lin(pc),a4
	move.w	(a4,d4.w*2),vollnot_t(a3)
	rts

;-----------------------------------------------------------------------------
;	Linear volume slide + tone porta
;-----------------------------------------------------------------------------
fx_v_sldown_l_tp:			; Volume slide down (lin) + tone porta \
	neg.w	d4		;                                       > *** Ne pas s‚parer
fx_v_slup_l_tp:			; Volume slide up (lin) + tone porta   /
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
;	Linear volume slide + Vibrato
;-----------------------------------------------------------------------------
fx_v_sldown_l_vib:			; Volume slide down (lin) + vibrato \
	neg.w	d4		;                                    > *** Ne pas s‚parer
fx_v_slup_l_vib:			; Volume slide up (lin) + vibrato   /
	bsr.s	fx_do_v_slide_l
	moveq	#0,d4
	bsr	fx_do_vibrato
	bra	fx_fin_speciale

;-----------------------------------------------------------------------------
;	Exponential volume slide + vibrato
;-----------------------------------------------------------------------------
fx_v_sldown_e_vib:			; Volume slide down (exp) + vibrato \
	neg.w	d4		;                                    > *** Ne pas s‚parer
fx_v_slup_e_vib:			; Volume slide up (exp) + vibrato   /
	bsr.s	fx_do_v_slide_e
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
	bsr	gtkr_get_master_vol
	move.w	d0,d5
	move.w	(sp)+,d0
	add.w	d5,d4
	IFNE	CHECK
	tst.w	d4
	bpl.s	.ok1
	moveq	#0,d4
.ok1:	cmp.w	#$fff,d4
	ble.s	.ok2
	move.w	#$fff,d4
	ENDC
.ok2:	move.w	d4,-(sp)
	bsr	gtkr_set_master_vol
	addq.l	#2,sp
	rts

;-----------------------------------------------------------------------------
;	Left balance move
;-----------------------------------------------------------------------------
fx_left_bal_move:
	sub.w	d4,bal_t(a3)
	IFNE	CHECK
	tst.w	bal_t(a3)
	bpl	fx_fin_normale
	clr.w	bal_t(a3)
	ENDC
	bra	fx_fin_normale
	
;-----------------------------------------------------------------------------
;	Right balance move
;-----------------------------------------------------------------------------
fx_right_bal_move:
	add.w	bal_t(a3),d4
	IFNE	CHECK
	cmp.w	#$fff,d4
	ble.s	.ok
	move.w	#$fff,d4
	ENDC
.ok:	move.w	d4,bal_t(a3)
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
;	Roll + Volume slide
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
	bne.s	.fin_roll
	move.w	vollnot_t(a3),d3	; R‚cupŠre le volume courant
	and.w	#$FF,d4		; Au cas o— on arrive de Roll + vsl + sbl
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
	bra	fx_fin_speciale





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*


;--- Pour le noyau -----------------------------------------------------------
;lod_name:		DC.B	"e:\teachers\sources\playdsp.lod",0	; *** Nom du fichier .LOD, avec son chemin !
	EVEN
gtkr_routine_dsp:	INCLUDE	"gtk\dsp_bin.dcb"	;DS.B	10000	; Place pour le chargement du prog DSP
gtkr_routine_dsp_end:
	EVEN				; Il est charg‚ … l'initialisation du player

;--- Pour le soundtracker ----------------------------------------------------
;úúú Tables de sauts pour les effets úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
;    Certains sont inutilis‚s, donc on se tire directement
fx_table_de_sauts1:
; 00xx - 0fxx
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_set_ftune,fx_predelay,fx_note_cut,fx_pos_jump
		DC.L	fx_set_vib_wave,fx_break_pat,fx_set_trem_wave,fx_set_global_speed
; 10xx - 1fxx
		DC.L	fx_fin1,fx_fine_porta_up,fx_fine_porta_down,fx_roll_and_vsl_init
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
; a0xx - afxx
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_fine_v_slup_l,fx_fine_v_sldown_l,fx_fine_mv_slup_l,fx_fine_mv_sldown_l
		DC.L	fx_set_nbr_of_frames,fx_set_fine_speed,fx_pattern_delay,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
; b0xx - bfxx
		DC.L	fx_tremor_init,fx_pattern_loop,fx_fin1,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1
		DC.L	fx_fin1,fx_fin1,fx_fin1,fx_fin1

fx_table_de_sauts2:
; 00xx - 0fxx
		DC.L	fx_fin_normale,fx_porta_up,fx_porta_down,fx_tone_porta
		DC.L	fx_vibrato,fx_tone_porta_vib,fx_vib_tone_porta,fx_tremolo
		DC.L	fx_fin_normale,fx_delay,fx_fin_normale,fx_fin_normale
		DC.L	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
; 10xx - 1fxx
		DC.L	fx_arpeggio,fx_fin_normale,fx_fin_normale,fx_roll_and_vsl
		DC.L	fx_v_slup_l,fx_v_sldown_l,fx_v_slup_e,fx_v_sldown_e
		DC.L	fx_v_slup_l_tp,fx_v_sldown_l_tp,fx_v_slup_e_tp,fx_v_sldown_e_tp
		DC.L	fx_v_slup_l_vib,fx_v_sldown_l_vib,fx_v_slup_e_vib,fx_v_sldown_e_vib
; a0xx - afxx
		DC.L	fx_mv_slup_l,fx_mv_sldown_l,fx_fin_normale,fx_fin_normale
		DC.L	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		DC.L	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_extra_fine_tone_porta
		DC.L	fx_extra_fine_porta_up,fx_extra_fine_porta_down,fx_left_bal_move,fx_right_bal_move
; b0xx - bfxx
		DC.L	fx_tremor,fx_fin_normale,fx_fin_normale,fx_fin_normale
		DC.L	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		DC.L	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale
		DC.L	fx_fin_normale,fx_fin_normale,fx_fin_normale,fx_fin_normale

;úúú Table de 32 sinus [0,ã[ úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
sin_table_gtk:
		DC.W	$00,$18,$31,$4a,$61,$78,$8d,$a1	; { E(255sin(kã/32)) | kî{0...31} }
		DC.W	$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		DC.W	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5
		DC.W	$b4,$a1,$8d,$78,$61,$4a,$31,$18

per_tab_load:	INCLUDE	"gtk\pertable.dcb"	;	'e:\teachers\sources\pertable.bin'	 Table de p‚riodes pour les notes (8 finetunes par note)
per_table		EQU	per_tab_load+24*2	; D‚calage de 24 finetunes avant le C-0
tempo_table:	INCLUDE	"gtk\temtable.dcb"	;	'e:\teachers\sources\temtable.bin'	; Table des spl/vbl et vbl/frame pour chaque tempo de 32 … 255
vexp_2_lin:		INCLUDE	"gtk\vexp2lin.dcb"	;	'e:\teachers\sources\vexp2lin.bin'	; Les correspondances de volume pour instrument
vlin_2_exp:		INCLUDE	"gtk\vlin2exp.dcb"	;	'e:\teachers\sources\vlin2exp.bin'
vexp_2_lin_master:	INCLUDE	"gtk\v_e2l_m.dcb"	;	'e:\teachers\sources\v_e2l_m.bin'	; Pareil, pour le master

;úúú Sert au convertisseur de modules úúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúúú
gtkpl_id_mod:	
		DC.B	'M.K.',4,'M!K!',4,'M&K&',4,'RASP',4	; 16 identificateurs
		DC.B	'FLT4',4,'FLT6',6,'FLT8',8,'CD81',8	; pour les modules .MOD
		DC.B	'4CHN',4,'6CHN',6,'8CHN',8,'12CH',12	; avec le nombre de voies
		DC.B	'16CH',16,'24CH','20CH',24,'32CH',32	; correspondant
		DC.B	0
		EVEN

protrack_pernote:	DC.W	$358,$328,$2FA,$2D0,$2A6,$280	; P‚riodes des notes
		DC.W	$25C,$23A,$21A,$1FC,$1E0,$1C5	; de C-1 … B-3 au format
		DC.W	$1AC,$194,$17D,$168,$153,$140	; Protracker
		DC.W	$12E,$11D,$10D,$0FE,$0F0,$0E2
		DC.W	$0D6,$0CA,$0BE,$0B4,$0AA,$0A0
		DC.W	$097,$08F,$087,$07F,$078,$071

;--- Pour le programme d'exemple ---------------------------------------------
;module_gtk:	;IncBin	'e:\teachers\daftgodz.gtk'	; *** Mettre ici le nom du module
;		incbin	d:\gods\maggie\link2\maggie.gtk
;modend:		DS.B	16*256	; *** Place pour la conversion.
		EVEN

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	BSS



;--- Pour le noyau -----------------------------------------------------------
gtkr_flag_installed:	DS.W	1	; 1 = Noyau install‚, 0 = non install‚
gtkr_adr_info_track:	DS.L	1	; Adresse de info_track
gtkr_nbrvoies:	DS.W	1	; Nombre de voies … mixer
gtkr_current_track:	DS.W	1	; Piste courante
gtkr_dsp_plein:	DS.W	1	; A 0 si aucune voie n'a ‚t‚ envoy‚e.
gtkr_master_vol:	DS.W	1	; Le master volume (0 - $1000), $100 pour 16 voies
gtkr_vblsize:	DS.W	1	; Nbr de samples/VBL (1000 en moyenne)
gtkr_flag_the_end:	DS.W	1	; 1 = On arrˆte le noyau
gtkr_info_track:	DS.B	NBRVOIES_MAXI*next_t	; Informations sur les N voies (maximum)
gtkr_extrout:	DS.L	17	; Place pour les adr de 16 routines … ‚x‚cuter en fin d'IT. 0 = pu d'routine
gtkr_zone_vide:	DS.B	1024	; 1Ko de vide (totalement vide, qui doit le rester)
		IFNE	FLAG_MT_DISP
gtkr_color_mt_disp:	DS.L	1	; Sauvegarde de la couleur
		ENDC
		IFNE	INTERRUPTION_TYPE
gtkr_sauvegarde_timer_A:	DS.L	1
		ENDC
gtkr_routine_dsp_lon:	DS.L	1

;--- Pour le soundtracker ----------------------------------------------------
gtkpl_flag_installed:	DS.W	1	; 1 = Player install‚, 0 = non install‚
gtkpl_adr_info_track:	DS.L	1	; Adresse de info_track, copie pour le player !
gtkpl_num_track:	DS.W	NBRVOIES_MAXI	; Pistes occup‚es par le tracker
gtkpl_flag_stop_vcs:	DS.W	1	; 1 = Faire taire les voies, attendre le retour
				; … 0 avant de changer les paramŠtres de la song
gtkpl_pause_backup:	DS.B	NBRVOIES_MAXI*(4+4+2)	; Sauvegardes des longueurs, positions et
				; volumes sur chaque track lors d'une pause
gtkpl_module_inf1:	DS.B	adr_next	; Quelques adresses concernant le module
gtkpl_module_inf2:	DS.B	mod_next	; Informations g‚n‚rales sur le module
gtkpl_mod_nbp:	DS.W	1	; Nombre de patterns d'un module .MOD … convertir
gtkpl_mod_nbt:	DS.W	1	; Nombre de pistes d'un module .MOD … convertir
gtkpl_mod_nbl:	DS.W	1	; Nombre de lignes d'un module .MOD … convertir
gtkpl_mod_sl:	DS.W	1	; Nombre de postitons d'un module .MOD … convertir
gtkpl_mod_sr:	DS.W	1	; Point de r‚p‚tition d'un module .MOD … convertir
gtkpl_mod_len:	DS.W	1	; Taille d'un module converti

;--- Pour le programme d'exemple ---------------------------------------------
repeatbuffer:	DS.B	NBRSAMPLES_MAXI*1024	; Buffers de r‚p‚tition de N samples maxi + 1 vide
source_last_byte:



*÷÷÷ FIN ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
