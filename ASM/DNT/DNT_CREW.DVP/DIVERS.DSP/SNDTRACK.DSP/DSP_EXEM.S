*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*           Exemple d'utilisation de la routine de SoundTracker           *
*                    (C)oderight Nullos / DNT-Crew 1994                   *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Ce petit programe installe une interruption 50Hz, afin de ne pas ˆtre    *
*tributaire de la fr‚quence ‚cran, mais si vous avez une VBL … 50Hz dans  *
*votre programe, vous pourrez bien s–r vous en servir...                  *
*                                                                         *
*Comme exemple d'application DSP tournant simultan‚ment, un mini-prog'    *
*tout con, qui attend de recevoir 2 fractions par le port Host, et qui    *
*retourne deux valeurs: le produit et la division de la premiŠre par      *
*la deuxiŠme...                                                           *
*                                                                         *
*Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*R‚sum‚ des touches disponibles:                                          *
*    + : augmenter le volume global                                       *
*    - : diminue                                                          *
* F1/F2: R‚gler la voix 1 vers la gauche / la droite                      *
* F3/F4: Idem voix 2                                                      *
* F5/F6: Idem voix 3                                                      *
* F7/F8: Idem voix 4                                                      *
*    F9: Envoie les samples par le Host (mode lent)                       *
*   F10: ------ -- -------- --- le DMA (mode rapide, mais avec Timer A)   *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

	OPT	O+,W-		;Optimisations, pas de Warnings
	include	tos_030.s		;
	include	hard_sys.s		;
	include	dsp_play.inc	;D‚finitions du soundtracker

ReadHost	MACRO	dst
.\@	btst	#0,$ffffa202.w
	beq.s	.\@
	move.l	$ffffa204.w,\1
	ENDM
WritHost	MACRO	src
.\@	btst	#1,$ffffa202.w
	beq.s	.\@
	move.l	\1,$ffffa204.w
	ENDM



	SECTION	TEXT
start	StartUp	512		;D‚marrage de notre
	pea	cls(pc)		;programme, pile de 512 octets.
	Gemdos	Cconws		;Cls pour faire apparaitre le
	clr.l	-(sp)		;temps machine.
	move.w	#$20,-(sp)		;
	trap	#1		;Superviseur, il vaut mieux!
	move.l	d0,2(sp)		;
	lea	mod,a0		;Adresse du module NTK4
	lea	freq_buf,a1	;Buffer pour les fr‚quences
	jsr	dsp_play		;Pof, la routine s'initialise

	move.l	dsp_play+8,a0	;Adresse des variables internes
	clr.b	song_stop(a0)	;->D‚bloque
	st.b	dma2dsp(a0)	;->Transfert par le port Host

	lea	MFP_base.w,a6	;
	move.b	VR(a6),-(sp)	;MFP en mode AEI
	bclr	#3,VR(a6)		;
	move.l	V_TB.w,-(sp)	;

	clr.b	TBCR(a6)		;
	move.l	#interruption_50Hz,V_TB.w
	bset	#0,IERA(a6)	;Installe le TimerB pour
	bset	#0,IMRA(a6)	;faire du 50Hz
	move.b	#192,TBDR(a6)	;
	move.b	#5,TBCR(a6)	;

wait0	move.w	count(pc),d0	;
	addq.w	#3,d0		;Attendre l'‚quivalent
wait1	cmp.w	count(pc),d0	;de 50Hz avec le compteur
	bne.s	wait1		;systŠme.
	move.b	$fffffc02.w,d0	;Lecture brutale du clavier
	ext.w	d0		;
	ble.s	wait0		;
	cmpi.w	#$4a,d0		;Touche '-' pav‚ num‚rique
	beq.s	decvol		;
	cmpi.w	#$4e,d0		;Touche '+'
	beq.s	incvol		;
	cmpi.w	#$39,d0		;       'Space'
	beq.s	pof		;
	subi.w	#$3b,d0		;Touche de fonction ?
	blt.s	wait0		;
	cmpi.w	#7,d0		;
	bgt.s	chg_dma2dsp	;
	lsr.b	#1,d0		;Selon F1..F8, on
	subx.b	d1,d1		;va modifier les balances
	add.b	d1,d1		;des voix.
	addq.b	#1,d1		;D'abord selon la parit‚
	neg.b	d1		;de Fx, +1 ou -1
	ext.w	d0		;
	mulu	#voice_size,d0	;Puis d‚termine la voix
	lea	(voice1+spl_bal,a0,d0),a1;concern‚e
	add.b	(a1),d1		;Pof, modifie la balance
	bpl.s	.ok		;V‚rifie sa valeur
	cmpi.b	#$80,d1		;
	bne.s	wait0		;
.ok	move.b	d1,(a1)		;
	bra.s	wait0		;
chg_dma2dsp
	subq.b	#8,d0		;Selon F9-F10, le transfert
	seq	dma2dsp(a0)	;se fera en Host ou en DMA
	bra.s	wait0		;

decvol	subq.w	#1,master_vol(a0)	;Volume global, pour faire
	bpl.s	wait0		;des fade-in / fade-out
incvol	move.w	master_vol(a0),d0	;qui glissent comme un pet de
	addq.w	#1,d0		;nonne sur de la toile cir‚e
	cmpi.w	#$100,d0		;
	ble.s	*+4		;
	subq.w	#1,d0		;
	move.w	d0,master_vol(a0)	;
	bra.s	wait0		;
		
pof	bsr	loader		;Petite d‚mo du DSP...

	clr.b	TBCR(a6)		;D‚branche tout, et cassos
	bclr	#0,IERA(a6)	;
 	bclr	#0,IMRA(a6)	;
	move.l	(sp)+,V_TB.w	;
	move.b	(sp)+,VR(a6)	;
fini	clr.b	$ffff8901.w	;
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	Xbios	Snd_DspTriState	;pour pas merder.
	trap	#1		;Cassos
	moveq	#6,d7		;R‚glages sonores: 
	moveq	#3,d6		;(6,3);(5,3);(4,3);(1,$x0);(0,$x0)
.soundsys	cmp.w	d6,d7		;couple (3,3) ?
	bne.s	.soundset		;
	moveq	#1,d7		;Oui->passe au couple (1,$x0)
	move.w	#$e0,d6		;La valeur est modifi‚e en court
.soundset	move.w	d6,-(sp)		;de route..
	move.w	d7,-(sp)		;Un couple...
	Xbios	Snd_Cmd		;
	dbf	d7,.soundsys	;Suivant
.pcm_frq	move.w	#1,-(sp)		;Voil…, on a remis le son
	clr.l	-(sp)		;dans un ‚tat correct.
	pea	8.w		;
	Xbios	Snd_DevConnect	;

	clr.w	(sp)		;Et on se casse !!.
	trap	#1		;

loader
	lea	tstprg(pc),a0	;Adresse et taille de notre
	move.w	#tstprgsize/3,d0	;programme exemple.
	bsr	dsp_play+4		;
	WritHost	#$123456		;On lui envoie deux nombres
	WritHost	#$654321		;
	ReadHost	d0
	ReadHost	d1		;Et paf, il les divise puis
	ReadHost	d2		;les multiplie....
	rts			;Impressionnant non?

interruption_50Hz			;comme son nom l'indique
	ror.w	hop		;timer 200Hz, une fois sur 4
	bcc.s	.bah_non		;->50Hz.
	not.w	v_color.w		;
	not.l	v_color030.w	;
	bsr	dsp_play+12	;
	not.w	v_color.w		;
	not.l	v_color030.w	;
.bah_non	addq.w	#1,count		;
	rte			;

hop	dc.w	$1111		;
count	dc.w	0

	SECTION	DATA
tstprg	incbin	test.p56		;Petit exemple.
tstprgsize	equ	*-tstprg

cls	dc.b	27,'E',$d,$a,0
	even

yoman	incbin	dsp_play.bin	;Routine de mixage!
dsp_play	equ	yoman+$1c
	even
mod	incbin	lizagrdk.ntk	;Mettez votre module NTK ici

	SECTION	BSS
freq_buf	ds.l	907-108+1		;Buffer indispensable
