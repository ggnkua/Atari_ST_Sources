;----- Fichier : DspPlay.T ------------------------------------------------

	SECTION	TEXT

***************************************************************************

	include	tos_030.t
	include	hard_sys.t
	include	dsp_play.inc

***************************************************************************

; En entr‚e : a0=@ du module

INIT_MOD:	lea	freq_buf,a1		;Fr‚quences
	jsr	dsp_play		;Initialisation du player
	move.l	dsp_play+8,a0	;@ des variables internes
	clr.b	song_stop(a0)	;D‚blocage
	move.b	#-1,dma2dsp(a0)	;-1=Host 0=DMA
	RTS
***************************************************************************

PLAY_MOD:	jsr	dsp_play+12
	RTS

***************************************************************************

STOP_MOD:	clr.b	$ffff8901.w
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	Xbios	Snd_DspTriState	;pour pas merder.
	trap	#1		;Cassos
	moveq	#6,d7		;R‚glages sonores: 
	moveq	#3,d6		;(6,3);(5,3);(4,3);(1,$x0);(0,$x0)
.soundsys	cmp.w	d6,d7		;couple (3,3) ?
	bne.s	.soundset
	moveq	#1,d7		;Oui->passe au couple (1,$x0)
	move.w	#$e0,d6		;La valeur est modifi‚e en court
.soundset	move.w	d6,-(sp)		;de route..
	move.w	d7,-(sp)		;Un couple...
	Xbios	Snd_Cmd
	dbf	d7,.soundsys	;Suivant
.pcm_frq	move.w	#1,-(sp)		;Voil…, on a remis le son
	clr.l	-(sp)		;dans un ‚tat correct.
	pea	8.w
	Xbios	Snd_DevConnect
	RTS

***************************************************************************

; En entr‚e : a0.l=@ du prog et d0.l=taille

CHARGE_DSP:	jsr	dsp_play+4
	RTS

***************************************************************************

	SECTION	DATA

yoman	incbin	dsp_play.bin	;Routine de mixage!
dsp_play	equ	yoman+$1c
	even

***************************************************************************

	SECTION	BSS

freq_buf	ds.l	907-108+1		;Buffer indispensable

***************************************************************************

	SECTION	TEXT
