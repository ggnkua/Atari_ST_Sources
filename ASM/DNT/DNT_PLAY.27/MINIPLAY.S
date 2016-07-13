*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                                  MiniPlay                               *
*                     (L)amecode Nullos / DNT-Crew 1994                   *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*                                                                         *
*Player de module tout bˆte, lancez-le pour avoir son mode d'emploi.      *
*                                                                         *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Les routines de d‚compactages sont celles fournies par leurs cr‚ateurs,  *
*parfois modifi‚es de fa‡on cosm‚tique pour les besoins du programme.     *
* Ice Packer 2.4    : Ice                                                 *
* Atomik Packer 3.5 : Altair                                              *
* Sentry 2.0        : Eagle                                               *
* PowerPacker 2.0   :  ??                                                 *
* SpeedPacker 3     : The FireHawks                                       *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Ceci est un programme freeware, MAIS ce n'est pas du domaine public.     *
*Si vous utilisez tout ou partie de ce source ou d'un autre source formant*
*ma routine de soundtracker au DSP, dans un but non-lucratif, n'oubliez   *
*pas de me le signaler.                                                   *
*Si par contre il s'agit d'une utilisation dans le cadre d'un programme   *
*commercial, il faudra demander mon autorisation, certes par simple       *
*formalit‚ mais quand mˆme...                                             *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Version 2.7 ÷÷÷÷÷*

	OPT	O+,W-		;Optimisations, pas de Warnings
	OUTPUT	.TTP		;C'est un Tos Taking Parameters
	include	c:\langages\sources\tos_030.s	;
	include	c:\langages\sources\hard_sys.s	;
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
start	StartUp	512		;
	moveq	#0,d0		;Commence par les tests sur la ligne
	lea	p_cmdcnt(a0),a6	;de commande.
	move.b	(a6)+,d6		;
	beq	usage		;
	clr.b	(a6,d6)		;
	pea	dta(pc)		;Fixer la dta comifo.
	Gemdos	Fsetdta		;
	clr.w	-(sp)		;
	pea	(a6)		;
	Gemdos	Fsfirst		;Recherche le fichier
	tst.w	d0		;
	bne	paglop_file	;
	move.l	dta+dta_size(pc),d6	;R‚cupŠre sa taille.
	clr.w	-(sp)		;
	pea	(a6)		;
	Gemdos	Fopen		;On l'ouvre.
	move.w	d0,d7		;
	move.l	d6,d5		;Conserve la taille

	pea	BufAtm(pc)		;on lit les 16 premiers
	pea	16.w		;octets pour reconnaitre
	move.w	d7,-(sp)		;le fichier
	Gemdos	Fread		;
	lea	BufAtm(pc),a0	;
	cmpi.l	#"ICE!",(a0)	;Compactage Ice ?
	bne.s	.M_10		;non
	move.l	8(a0),d6		;Si, prendre la VRAIE taille
	bra	.M_14		;
.M_10	cmpi.l	#"ATM5",(a0)+	;Compactage Atomik ?	
	bne.s	.M_11		;
	move.l	(a0),d6		;oui => VRAIE taille
	bra	.M_14		;
.M_11	cmpi.l	#"SPv3",-(a0)	;Compactage SpeedPacker?
	bne.s	.M_12		;
	move.l	12(a0),d6		;
	bra.s	.M_14		;
.M_12	cmpi.l	#"PP20",(a0)	;Compactage PowerPacker?
	bne.s	.M_13		;
	move.w	#2,-(sp)		;Format de merde: faut lire
	move.w	d7,-(sp)		;les 24 bits forts du dernier
	pea	-4.w		;mot-long pour savoir la
	Gemdos	Fseek		;taille du fichier...
	pea	BufAtm		;
	pea	4.w		;
	move.w	d7,-(sp)		;
	Gemdos	Fread		;
	move.l	BufAtm(pc),d6	;
	lsr.l	#8,d6		;
	bra.s	.M_14		;
.M_13	move.w	#2,-(sp)		;D‚tection Sentry 2_0. Encore plus
	move.w	d7,-(sp)		;merdique que le PowerPacker: la taille
	pea	-8.w		;est aussi en fin de fichier, mais aussi
	Gemdos	Fseek		;l'identification... et le tout dans le
	pea	BufAtm		;format Intel !!. All“ la terre ?
	pea	8.w		;
	move.w	d7,-(sp)		;
	Gemdos	Fread		;
	move.l	BufAtm+4(pc),d0	;
	cmpi.l	#"Snt.",d0		;
	bne.s	.M_14		;La taille d‚compact‚e tient dans
	move.l	BufAtm(pc),d6	;l'avant dernier mot-long.
	ror.w	#8,d6		;
	swap	d6		;
	ror.w	#8,d6		;

.M_14	clr.w	-(sp)		;Puis on revient en
	move.w	d7,-(sp)		;tˆte de fichier...
	clr.l	-(sp)		;
	Gemdos	Fseek		;

	moveq	#1,d0		;
	swap	d0		;64ko en fin de buffer, plus le
	add.l	d6,d0		;buffer lui-mˆme, afin d'effectuer
	move.l	d0,-(sp)		;la transformation mod->ntk
	Gemdos	Malloc		;
	move.l	d0,mod		;
	ble	paglop_ram		;Ben merde, pas assez!
	
	move.l	mod(pc),-(sp)	;
	move.l	d5,-(sp)		;Lire pile skifo pour le fichier.
	move.w	d7,-(sp)		;
	Gemdos	Fread		;
	cmp.l	d5,d0		;
	bne	paglop_file	;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	movea.l	mod(pc),a0		;
	move.l	d5,d0		;
	bsr	ICE2_4		;tentative de d‚package
	bsr	ATM3_5		;ice, atomik ou powerpacker
	bsr	PP20		;
	bsr	Sentry2_0		;
	bsr	SPv3		;
	movea.l	a0,a1		;
	moveq	#31,d1		;31 instruments maxi
.tm_bcl	cmpi.l	#"NTK4",(a1)	;donc 32 tests
	lea	16(a1),a1		;conserve le CCR
	dbeq	d1,.tm_bcl		;hop
	sne	d1		;Conserve le r‚sultat

	movem.l	d0-d2/a0-a2,-(sp)	;
	movea.l	mod(pc),a0		;Recopie le titre du module
	lea	title(pc),a1	;comifo.
	bne.s	*+4		;
	move.l	a6,a0		;Si c'est un ntk, pas de titre!
	moveq	#19,d0		;
	move.b	(a0)+,(a1)+	;
	dbeq	d0,*-2		;
	bne.s	.0		;
	move.l	#$0d0a0000,-1(a1)	;
.0	pea	watodo(pc)		;
	Gemdos	Cconws		;
	movem.l	(sp)+,d0-d2/a0-a2	;

	tst.b	d1		;
	beq.s	.ntk		;C'est un ntk4 ?
	bsr	convert_mod_to_ntk	;NON: Pof, convertion.
.ntk	lea	freq_buf,a1	;Buffer pour les fr‚quences
	jsr	dsp_play		;Pof, la routine s'initialise

	move.l	dsp_play+8,a0	;Adresse des variables internes
	clr.b	song_stop(a0)	;->D‚bloque
	clr.b	dma2dsp(a0)	;->Transfert par le DMA
	move.b	#$1a,voice1+spl_bal(a0);R‚partir les voix par d‚faut.
	move.b	#$54,voice2+spl_bal(a0);
	move.b	#$66,voice3+spl_bal(a0);
	move.b	#$2c,voice4+spl_bal(a0);
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
wait0	move.l	_frclock.w,d0	;Attendre environ 50 Hz
wait1	cmp.l	_frclock.w,d0	;avec le compteur systŠme.
	beq.s	wait1		;
	move.b	$fffffc02.w,d0	;Lecture brutale du clavier
	ext.w	d0		;
	ble.s	wait0		;
	cmpi.w	#$4a,d0		;Touche '-' pav‚ num‚rique
	beq.s	decvol		;
	cmpi.w	#$4e,d0		;Touche '+'
	beq.s	incvol		;
	cmpi.w	#$39,d0		;       'Space'
	beq	pof		;
	cmpi.b	#$61,d0		;
	beq.s	songoff		;
	cmpi.b	#$62,d0		;
	beq	songon		;
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
pof	andi.b	#$f0,TBCR(a6)	;D‚branche tout, et cassos
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
	
	bsr	Clear_Kbd		;Efface buffer clavier.

	Gemdos	Super		;Retour en user
	Gemdos	Pterm0		;Et on se casse !!.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
paglop_file
	lea	no_file(pc),a0	;
	bra.s	outerr		;
paglop_ram	lea	no_ram(pc),a0	;
	bra.s	outerr		;
paglop_snd	lea	no_snd(pc),a0	;
	bra.s	outerr		;
paglop_dsp	Xbios	Snd_Unlock		;
	lea	no_dsp(pc),a0	;
	bra.s	outerr		;
paglop_mem	lea	no_mem(pc),a0	;
	bra.s	outerr		;
usage	lea	helpme(pc),a0	;
outerr	pea	(a0)		;
	Gemdos	Cconws		;
	Gemdos	Crawcin		;
	Gemdos	Pterm0		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Clear_Kbd	move.w	#$00ff,-(sp)
	Gemdos	Crawio
	tst.l	d0
	bne.s	Clear_Kbd
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
interruption_50Hz			;comme son nom l'indique
	bsr	dsp_play+12	;
	rte			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOPROGRAM	include	mod_ntk4.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PP20	movem.l	d0-a6,-(sp)
	lea	$100(a0),a3
	move.l	a0,a5
	adda.l	d0,a0
	cmpi.l	#'PP20',(a5)+
	bne.w	.abort
	moveq	#3,d6
	moveq	#7,d7
	moveq	#1,d5
	movea.l	a3,a2
	move.l	-(a0),d1
	tst.b	d1
	beq.s	.pp_0
	bsr.s	.pp_4
	subq.b	#1,d1
	lsr.l	d1,d5
.pp_0	lsr.l	#8,d1
	adda.l	d1,a3
	move.l	d1,(sp)
	lea	BufAtm+260,a6
	moveq	#63,d0
	move.l	-(a3),-(a6)
	dbf	d0,*-2
	move.l	a3,-(a6)
	lea	$100(a3),a3

.pp_1	bsr.s	.pp_4
	bcs.s	.pp_11
	moveq	#0,d2
.pp_2	moveq	#1,d0
	bsr.s	.pp_7
	add.w	d1,d2
	cmp.w	d6,d1
	beq.s	.pp_2
.pp_3	moveq	#7,d0
	bsr.s	.pp_7
	move.b	d1,-(a3)
	dbf 	d2,.pp_3
	cmpa.l	a3,a2
	bcc.s	.pp_17

.pp_11	moveq	#1,d0
	bsr.s	.pp_7
	moveq	#0,d0
	move.b	(a5,d1.w),d0
	move.w	d1,d2
	cmp.w	d6,d2
	bne.s	.pp_14
	bsr.s	.pp_4
	bcs.s	.pp_12
	moveq	#7,d0
.pp_12	bsr.s	.pp_6
	move.w	d1,d3
.pp_13	moveq	#2,d0
	bsr.s	.pp_7
	add.w	d1,d2
	cmp.w	d7,d1
	beq.s	.pp_13
	bra.s	.pp_15

.pp_4	lsr.l	#1,d5
	beq.s	.pp_5
	rts  	

.pp_5	move.l	-(a0),d5
	roxr.l	#1,d5
	rts  	

.pp_6	subq.w	#1,d0
.pp_7	moveq	#0,d1
.pp_8	lsr.l	#1,d5
	beq.s	.pp_10
	addx.l	d1,d1
	dbf 	d0,.pp_8
	rts  	
.pp_10	move.l	-(a0),d5
	roxr.l	#1,d5
	addx.l	d1,d1
	dbf 	d0,.pp_8
	rts  	

.pp_14	bsr.s	.pp_6
	move.w	d1,d3
.pp_15	addq.w	#1,d2
.pp_16	move.b	(a3,d3.w),-(a3)
	dbf 	d2,.pp_16
	cmpa.l	a3,a2
	bcs.s	.pp_1
.pp_17	lea	-$100(a2),a1
	move.l	$104(sp),d0
	lsr.l	#3,d0
.pp_18	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	subq.l	#1,d0
	bcc.s	.pp_18
	lea	BufAtm,a6
	move.l	(a6)+,a3
	moveq	#63,d0
	move.l	(a6)+,(a3)+
	dbf	d0,*-2
	moveq	#0,d0
.abort	movem.l	(sp)+,d0-a6
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
ICE2_4	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0
	bne.s	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_ber
.get_ber:
	bsr.s	.get_d0_bits
.no_ber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
DEC_SPACE:	EQU	2048

ATM3_5	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	move.l	(a0)+,d0
	lea	4(a0,d0.l),a5
	move.l	d0,(a7)
	link	a2,#-28
	move.l	d0,-(a7)
	move.l	a5,a4
	lea	DEC_SPACE(a4),a5
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	lsl	#2,d0
	sub	d0,a4
	lea	BufAtm,a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra.s	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr.s	copy_decrun
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:
	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Sentry2_0	movem.l	d0-a6,-(sp)
	move.l	a0,a3
	lea	(a0,d0.l),a0
	moveq	#8,d6
	bsr	get_long
	cmpi.l	#'.tnS',d0
	beq.s	.unpack
	movem.l	(sp)+,d0-a6
	rts
.unpack	bsr	get_long		;
	move.l	d0,(sp)		; save depack len
	lea	(a3,d0.l),a2	; dest adres
	move.l	a2,a5		; save for picture depack
	bsr	get_long
	moveq	#0,d1
	add.l	d0,d0
	addx.w	d1,d1
	move.w	d1,unp_pic
	moveq	#0,d1
	add.l	d0,d0
	addx.w	d1,d1
	move.w	d1,unp_sam
	bne.s	.no_sam
	move.l	d0,-(sp)
	bsr	get_long
	move.l	d0,samoff+4
	bsr	get_long
	move.l	d0,samoff
	move.l	(sp)+,d0
.no_sam	bsr.s	unp_loop	; unpack data
	tst	unp_pic
	bne.s	.no_pic
	bsr	unp_picture
.no_pic	tst	unp_sam
	bne.s	.no_mod
	bsr	samples
.no_mod	movem.l	(sp)+,d0-a6
	rts

unp_loop
	bsr.s	.getbit
.cont	bcs.s   .blocks
	bsr.s	.getbit
	bcs.s	.copy_2
	move.b	-(a0),-(a2)	; 1 byte copy
	bra	l_col
.copy_2	bsr.s	.getbit
	bcs.s	.c_more
	moveq	#1,d2		; copy 2 bytes
	bra.s	.copy
.c_more	lea	copy_tab(pc),a4
.c_loop	move.l	(a4)+,d1
	bsr.s	.getbyte		; haal aantal
	subq.w	#1,d2
	bpl.s	.found
	bra.s	.c_loop
.found	swap	d1
	add.w	d1,d2

.copy	move.b	-(a0),-(a2)
	dbf	d2,.copy
	bra	l_col

.get_off
	MOVEQ	#1,D1		;OFFSET
	BSR.S	.getbyte
	move.b	(a4,d2),d1	; bits
	ADD.W	D2,D2
	ext.w	d1
	move.w	4(a4,d2),d4
	bsr.s	.getbyte
	add.w	d4,d2
	rts
.getbit	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha
	rts
.haha	bsr.s	get_long
	addx.l	d0,d0	;ROXR.L  #1,D0
	rts
.haha1	bsr.s	get_long
	addx.l	d0,d0	;ROXR.L  #1,D0
	bra.s	.getbyt
.getbyte
	CLR.W   D2
.loop	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha1
.getbyt	addx.L  d2,D2 
	DBF     D1,.loop
	RTS

.blocks	bsr.s	.getbit
	bcs.s	.string3
	moveq	#1,d3		; 2 bytes-string
	moveq	#8-1,d1	; small-bits-offset
	bra.s	.string_copy
.string3
	lea	small_offset(pc),a4
	bsr.s	.getbit
	bcs.s	.string_more
	moveq	#2,d3		; 3 bytes-string
	bra.s	.do_strings
.string_more
	moveq	#1,d1		; 2 bits-commando
	bsr.s	.getbyte
	subq.w	#1,d2		; large string?
	bmi.s	.large
	moveq	#3,d3		; minimaal 4 bytes-string
	add.w	d2,d3		; meer?
	bra.s	.do_strings
.large	lea	aantal_tab(pc),a4
	bsr.s	.get_off
	move.w	d2,d3
	lea	offset_tab(pc),a4
.do_strings
	bsr.s	.get_off
	bra.s	.s_copy
.string_copy
	bsr.s	.getbyte
.s_copy	move.b	-1(a2,d2.w),-(a2) 
	dbf	d3,.s_copy

l_col	cmpa.l	a2,a3 
	blt	unp_loop
ex_unp	RTS
get_long
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	move.w	#$10,ccr
	rts
samples	lea	samoff(pc),a1
	move.l	a3,a0		; source adres
	add.l	(a1)+,a0
	move.l	(a1),d0
	lea	(a0,d0.l),a2
.loop	move.b	(a0)+,d0
	sub.b	d0,(a0)
	neg.b	(a0)
	cmp.l	a2,a0
	blt.s	.loop
	rts
unp_picture
.low	move.w	#$0f9f,d7
snt2_01	moveq	#3,d6
snt2_02	move.w	-(a5),d4
	moveq	#3,d5
snt2_03	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,snt2_03
	dbra	d6,snt2_02
	movem.w d0-d3,(a5)
	dbra	d7,snt2_01
	rts
samoff	dc.l	0,0
unp_pic	dc.w	0
unp_sam	dc.w	0
offset_tab
	dc.b	5-1,8-1,9-1,13-1
	dc.w	2,2+32,2+32+256,2+32+256+512
aantal_tab
	dc.b	2-1,3-1,5-1,9-1
	dc.w	6,6+4,6+4+8,6+4+8+32
small_offset
	dc.b	4-1,5-1,7-1,9-1
	dc.w	2,2+16,2+16+32,2+16+32+128
copy_tab
	dc.w	2,1
	dc.w	5,2
	dc.w	12,3
	dc.w	27,4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SPv3	movem.l	d0-d7/a0-a6,-(a7)
	lea	BufSpv3(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	.R054
	tst.w	(a1)
	bne.s	.R054
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(a7)
	movea.l	a0,a2
.R020	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(a7),a1
	lea	$0192(a6),a3
	moveq	#$7F,d0
.R032	move.l	(a2)+,(a3)+
	dbf 	d0,.R032
	suba.l	a2,a3
	move.l	a3,-(a7)
	bsr.s	.R05A
	bsr	.R134
	move.b	-(a0),d0
	adda.l	(a7)+,a0
	move.b	d0,(a0)+
	lea	$0192(a6),a2
	bsr	.R136
	bsr	.R0FA
.R054	movem.l	(a7)+,d0-d7/a0-a6
	rts  	

.R05A	clr.w	d5
	move.w	-(a0),d6
	lea	$0004(a6),a3
	move.b	d6,(a3)+
	moveq	#$01,d3
	moveq	#$06,d4
.R068	cmp.b	d6,d3
	bne.s	.R06E
	addq.w	#2,d3
.R06E	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf 	d4,.R068
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	$0111(a6),a5
	move.b	-(a0),d4
	lea	$01(a5,d4.w),a3
.R08E	move.b	-(a0),-(a3)
	dbf 	d4,.R08E
	move.b	-(a0),-(a3)
	beq.s	.R09A
	suba.w	d4,a0
.R09A	moveq	#$00,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
.R0A2	bsr.s	.R0AC
	bsr.s	.R0AC
	dbf 	d2,.R0A2
	rts  	

.R0AC	not.w	d4
	add.b	d7,d7
	bne.s	.R0B6
	move.b	-(a0),d7
	addx.b	d7,d7
.R0B6	bcs.s	.R0CA
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts  	

.R0CA	moveq	#$02,d1
	bsr	.R1F4
	add.w	d0,d0
	beq.s	.R0E2
	move.b	d0,-(a3)
	moveq	#$02,d1
	bsr	.R1F4
	add.w	d0,d0
	move.b	d0,-(a3)
	rts  	

.R0E2	moveq	#$02,d1
	bsr	.R1F4
	move.w	$000C(a6),d1
	add.w	d0,d0
	beq.s	.R0F4
	move.w	$000E(a6),d1
.R0F4	or.w	d1,d0
	move.w	d0,-(a3)
	rts  	

.R0FA	tst.w	d6
	bpl.s	.R132
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	$0004(a7),a3
.R106	moveq	#$03,d6
.R108	move.w	(a2)+,d0
	moveq	#$03,d5
.R10C	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf 	d5,.R10C
	dbf 	d6,.R108
	cmpa.l	a2,a3
	blt.s	.R132
	movem.w	d1-d4,-$0008(a2)
	cmpa.l	a2,a3
	bne.s	.R106
.R132	rts  	

.R134	move.b	-(a0),-(a1)
.R136	swap	d5
	lea	$010E(a6),a3
	cmpa.l	a0,a2
	blt.s	.R144
	rts  	

.R142	adda.w	d3,a3
.R144	add.b	d7,d7
	bcc.s	.R156
	beq.s	.R150
.R14A	move.w	(a3),d3
	bmi.s	.R142
	bra.s	.R15A

.R150	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	.R14A
.R156	move.w	-(a3),d3
	bmi.s	.R142
.R15A	ext.w	d3
	jmp	.R160(pc,d3.w)

.R160	bra.s	.R160
	bra.s	.R1D8
	bra.s	.R1D8
	bra.s	.R1D8
	bra.s	.R1D8
	bra.s	.R1D8
	bra.s	.R1B6
	bra.s	.R1A2
	bra.s	.R17E
	bra.s	.R186
	bra.s	.R17A
	bra.s	.R190
	bra.s	.R134

.R17A	move.b	(a5),-(a1)
	bra.s	.R136

.R17E	bsr.s	.R1F0
	move.b	$01(a5,d0.w),-(a1)
	bra.s	.R136

.R186	bsr.s	.R1F0
	add.w	(a6),d0
	move.b	$01(a5,d0.w),-(a1)
	bra.s	.R136

.R190	moveq	#$03,d1
	bsr.s	.R1F4
	lsr.w	#1,d0
	bcc.s	.R19A
	not.w	d0
.R19A	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	.R136

.R1A2	lea	.table(pc),a4
	bsr.s	.R21C
	addi.w	#$0010,d0
	lea	$01(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra.s	.R136

.R1B6	moveq	#$03,d1
	bsr.s	.R1F4
	tst.w	d0
	beq.s	.R1C2
	addq.w	#5,d0
	bra.s	.R1D4

.R1C2	move.b	-(a0),d0
	beq.s	.R1CC
	addi.w	#$0014,d0
	bra.s	.R1D4

.R1CC	moveq	#$0D,d1
	bsr.s	.R1F4
	addi.w	#$0114,d0
.R1D4	move.w	d0,d3
	add.w	d3,d3
.R1D8	lea	.table+2(pc),a4
	bsr.s	.R21C
	lsr.w	#1,d3
	lea	$01(a1,d0.w),a3
	move.b	-(a3),-(a1)
.R1E6	move.b	-(a3),-(a1)
	dbf 	d3,.R1E6
	bra	.R136

.R1F0	moveq	#$00,d1
	move.b	(a3),d1
.R1F4	moveq	#$00,d0
	cmpi.w	#$0007,d1
	bpl.s	.R214
.R1FC	add.b	d7,d7
	beq.s	.R208
	addx.w	d0,d0
	dbf 	d1,.R1FC
	rts  	

.R208	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf 	d1,.R1FC
	rts  	

.R214	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	.R1FC
	rts  	

.R21C	moveq	#$00,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	.R1F4
	tst.b	d6
	beq.s	.R258
	move.w	d0,d4
	andi.w	#-$0010,d4
	andi.w	#$000F,d0
	beq.s	.R24E
	lsr.w	#1,d0
	beq.s	.R244
	roxr.b	#1,d7
	bcc.s	.R24E
	move.b	d7,(a0)+
	moveq	#-$80,d7
	bra.s	.R24E

.R244	moveq	#$02,d1
	bsr.s	.R1F4
	add.w	d0,d0
	or.w	d4,d0
	bra.s	.R258

.R24E	lea	$0004(a6),a3
	or.b	$00(a3,d0.w),d4
	move.w	d4,d0
.R258	add.w	$0012(a4),d0
	rts  	

.table	dc.w	$0003,$0004
	dc.w	$0005,$0007,$0008,$0009
	dc.w	$000a,$000b,$000c,$fff0
	dc.w	$0000,$0020,$0060,$0160
	dc.w	$0360,$0760,$0f60,$1f60

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
yoman	incbin	dsp_play.bin	;Routine de mixage!
dsp_play	equ	yoman+$1c
no_snd	dc.b	$d,$a,"Le systŠme sonore est d‚j… en service!",$d,$a,0
no_dsp	dc.b	$d,$a,"Le DSP est d‚j… utilis‚!",$d,$a,0
no_mem	dc.b	$d,$a,"Pas assez de m‚moire DSP!",$d,$a,0
no_ram	dc.b	$d,$a,"Pas assez de m‚moire 68030!",$d,$a,0
no_file	dc.b	$d,$a,"Impossible de lire le fichier indiqu‚!",$d,$a,0
helpme	dc.b	$d,$a,">>>>>>> MiniPlay 2.7 - (L)amecode Nullos/DNT 94 <<<<<<<"
	dc.b	$d,$a,"Pour utiliser ce programme:"
	dc.b	$d,$a,"  o Installez-le en application pour les fichiers *.MOD"
	dc.b	$d,$a,"  o Installez son ic“ne sur le bureau, et tirez vos"
	dc.b	$d,$a,"    fichiers *.MOD et *.NTK dessus"
	dc.b	$d,$a,"  o Lancez-le en indiquant un nom de module dans la ligne"
	dc.b	$d,$a,"    de commandes"
	dc.b	$d,$a,"Les fichiers peuvent avoir ‚t‚ compact‚s avec Atomik 3.5,"
	dc.b	$d,$a,"Ice 2.4, PowerPacker 2.0, Sentry 2.0 ou SpeedPacker 3."
	dc.b	$d,$a,0
watodo	dc.b	27,"E***************************************************************************"
	dc.b	$d,$a,"*                      R‚sum‚ des touches disponibles:                    *"
	dc.b	$d,$a,"*    + : augmenter le volume global                                       *"
	dc.b	$d,$a,"*    - : diminue                                                          *"
	dc.b	$d,$a,"* F1/F2: R‚gler la voix 1 vers la gauche / la droite                      *"
	dc.b	$d,$a,"* F3/F4: Idem voix 2                                                      *"
	dc.b	$d,$a,"* F5/F6: Idem voix 3                                                      *"
	dc.b	$d,$a,"* F7/F8: Idem voix 4                                                      *"
	dc.b	$d,$a,"*    F9: Envoie les samples par le Host (mode lent)                       *"
	dc.b	$d,$a,"*   F10: ------ --- ------- --- le DMA (mode rapide, mais avec Timer A)   *"
	dc.b	$d,$a,"* Undo : Coupe le soundtracker                                            *"
	dc.b	$d,$a,"* Help : Relance le soundtracker                                          *"
	dc.b	$d,$a,"***********************************MiniPlay 2.7 - (L)amecode Nullos/DNT 94*"
	dc.b	$d,$a,$a,"Nom du module: "
title	dcb.b	20," "
	dc.b	$d,$a,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	BSS
mod	ds.l	1
dta	ds.b	44
BufAtm
BufSpv3
freq_buf	ds.l	907-108+1		;Buffer indispensable
