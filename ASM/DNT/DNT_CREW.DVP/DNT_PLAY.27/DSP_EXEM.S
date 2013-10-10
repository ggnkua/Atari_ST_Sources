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
* Help : Coupe le soundtracker                                            *
* Undo : Relance le soundtracker                                          *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Version 2.7 ÷÷÷÷÷*

	OPT	O+,W-		;Optimisations, pas de Warnings
	include	include\tos_030.s	;
	include	include\hard_sys.s	;
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
				;temps machine.
	Xbios	Snd_Lock		;Le systŠme sonore est libre ?
	subq.w	#1,d0		;
	bne	paglop_snd		;
	Xbios	Dsp_Lock		;Et le DSP ?
	tst.w	d0		;
	bne	paglop_dsp		;
	pea	freq_buf(pc)	;2 mots longs pour le r‚sultat
	pea	freq_buf+4(pc)	;
	Xbios	Dsp_Available	;
	cmpi.l	#$3000-$200,freq_buf(pc)
	ble	paglop_mem		;Assez de place en m‚moire Y
	cmpi.l	#$3000-$100,freq_buf(pc)
	ble	paglop_mem		;et X ?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	clr.l	-(sp)		;Passage en superviseur
	Gemdos	Super		;
	move.l	d0,-(sp)		;

	clr.w	-(sp)		;Lire le module
	pea	(modname,pc)	;
	Gemdos	Fopen		;
	move.w	d0,d7		;
	pea	mod		;
	clr.l	-(sp)		;
	addq.b	#1,(sp)		;
	move.w	d7,-(sp)		;
	Gemdos	Fread		;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lea	mod,a0		;Adresse du module NTK4
	lea	freq_buf,a1	;Buffer pour les fr‚quences
	jsr	dsp_play		;Pof, la routine s'initialise

	move.l	dsp_play+8,a0	;Adresse des variables internes
	clr.b	song_stop(a0)	;->D‚bloque
	clr.b	dma2dsp(a0)	;->Transfert par le DMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lea	MFP_base.w,a6	;Installe le TimerD en 50Hz
	move.b	VR(a6),-(sp)	;MFP en mode AEI
	bclr	#3,VR(a6)		;
	move.l	V_TD.w,-(sp)	;

	andi.b	#$f0,TCDCR(a6)	;
	move.l	#interruption_50Hz,V_TD.w
	bset	#4,IERB(a6)	;
	bset	#4,IMRB(a6)	;
	move.b	#246,TDDR(a6)	;~50Hz
	ori.b	#7,TCDCR(a6)	;
	clr.w	$200.w		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	move.l	dsp_play+8,a0	;Adresse des variables internes
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
	cmpi.b	#$61,d0		;
	beq.s	songoff		;
	cmpi.b	#$62,d0		;
	beq.s	songon		;
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
	bra	wait0		;

songoff	st.b	song_stop(a0)	;Ben tiens!
	bra	wait0		;
songon	clr.b	song_stop(a0)	;
	bra	wait0		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pof	bsr	loader
	bsr	run_dsp		;Petite demo DSP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	andi.b	#$f0,TBCR(a6)	;D‚branche tout, et cassos
	bclr	#4,IERB(a6)	;
 	bclr	#4,IMRB(a6)	;
	move.l	(sp)+,V_TD.w	;
	move.b	(sp)+,VR(a6)	;
fini	clr.b	$ffff8901.w	;
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	Xbios	Snd_DspTriState	;pour pas merder.
	moveq	#6,d7		;R‚glages sonores: 
	moveq	#3,d6		;(6,3);(5,3);(4,3)
.soundsys	cmp.w	d6,d7		;couple (3,3) ?
	beq.s	.pcm_frq		;
.soundset	move.w	d6,-(sp)		;
	move.w	d7,-(sp)		;Un couple...
	Xbios	Snd_Cmd		;
	dbf	d7,.soundsys	;Suivant
.pcm_frq	move.w	#1,-(sp)		;Voil…, on a remis le son
	clr.l	-(sp)		;dans un ‚tat correct.
	pea	8.w		;
	Xbios	Snd_DevConnect	;

	Xbios	Snd_Unlock		;On libŠre tout le monde
	Xbios	Dsp_Unlock		;

	Gemdos	Super		;Retour en user
	Gemdos	Pterm0		;Et on se casse !!.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
paglop_snd	lea	no_snd(pc),a0	;
	bra.s	outerr		;
paglop_dsp	Xbios	Snd_Unlock		;
	lea	no_dsp(pc),a0	;
	bra.s	outerr		;
paglop_mem	lea	no_mem(pc),a0	;
outerr	pea	(a0)		;
	Gemdos	Cconws		;
	Gemdos	Crawcin		;
	Gemdos	Pterm0		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loader	lea	tstprg(pc),a0	;Adresse et taille de notre
	move.w	#tstprgsize/3,d0	;programme exemple.
	bsr	dsp_play+4		;
	rts

run_dsp	movem.l	d0-d2,-(sp)
	WritHost	#$123456		;On lui envoie deux nombres
	WritHost	#$654321		;
	ReadHost	d0		;
	ReadHost	d1		;Et paf, il les divise puis
	ReadHost	d2		;les multiplie....
	movem.l	(sp)+,d0-d2	;
	rts			;Impressionnant non?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
interruption_50Hz			;comme son nom l'indique
	move.w	d0,-(sp)		;
	move.w	v_VFC.w,d0		;

	not.l	v_color030.w	;
	bsr	dsp_play+12	;
	not.l	v_color030.w	;

	sub.w	v_VFC.w,d0		;Temps machine...
	neg.w	d0		;
	cmp.w	$200.w,d0		;
	ble.s	.0		;
	move.w	d0,$200.w		;

.0	move.w	(sp)+,d0		;
	addq.w	#1,count		;
	rte			;

count	dc.w	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
tstprg	incbin	test.p56		;Petit exemple.
tstprgsize	equ	*-tstprg

cls	dc.b	27,'E',$d,$a,0
	even
yoman	incbin	dsp_play.bin	;Routine de mixage!
dsp_play	equ	yoman+$1c
modname	dc.b	"chipmun2.ntk",0	;Mettez votre module NTK ici
no_snd	dc.b	$d,$a,"Le systŠme sonore est d‚j… en service!",$d,$a,0
no_dsp	dc.b	$d,$a,"Le DSP est d‚j… utilis‚!",$d,$a,0
no_mem	dc.b	$d,$a,"Pas assez de m‚moire DSP!",$d,$a,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	BSS
freq_buf	ds.l	907-108+1		;Buffer indispensable
mod	ds.b	400000		;
