*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                            DSP SoundTracking                            *
*                    (C)oderight Nullos / DNT-Crew 1994                   *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Ce source contient toute la partie 68030 des routines soundtracker.      *
*A savoir:                                                                *
*         o Initialisation du player                                      *
*         o Gestion de la partition                                       *
*         o Envoie des samples vers le DSP                                *
*         o Ex‚cution de programmes DSP en parallŠle                      *
*                                                                         *
*Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Ceci est un programme freeware, MAIS ce n'est pas du domaine public.     *
*Si vous utilisez tout ou partie de ce source ou d'un autre source formant*
*ma routine de soundtracker au DSP, dans un but non-lucratif, n'oubliez   *
*pas de me le signaler.                                                   *
*Si par contre il s'agit d'une utilisation dans le cadre d'un programme   *
*commercial, il faudra demander mon autorisation, certes par simple       *
*formalit‚ mais quand mˆme...                                             *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Sont actuellement support‚s les effets suivants:                         *
*                                                                         *
*               o Arpeggio                     (0)                        *
*               o Portamento Up                (1)                        *
*               o Portamento Down              (2)                        *
*               o Tone Portamento              (3)                        *
*               o Vibrato                      (4)                        *
*               o Tone Portamento+Volume Slide (5)                        *
*               o Vibrato+Volume Slide         (6)                        *
*               o Tremolo                      (7)                        *
*               o Sample Offset                (9)                        *
*               o Volume Slide                 (A)                        *
*               o Position Jump                (B)                        *
*               o Set Volume                   (C)                        *
*               o Pattern Break                (D)                        *
*               o Set Speed                    (F)                        *
*               o Fine Portamento Up           (E1)                       *
*               o Fine Portamento Down         (E2)                       *
*               o Set Glissando Control        (E3) [OPTION]              *
*               o Set Vibrato Waveform         (E4)                       *
*               o Set Fine Tune                (E5) [OPTION]              *
*               o PatternLoop Control          (E6)                       *
*               o Set Tremolo Waveform         (E7)                       *
*               o Stop                         (E8)                       *
*               o Note Retrig                  (E9)                       *
*               o Fine Slide Volume Up         (EA)                       *
*               o Fine Slide Volume Down       (EB)                       *
*               o Note Cut                     (EC)                       *
*               o Note Delay                   (ED)                       *
*               o Pattern Delay                (EE)                       *
*               o Balances                     (EF) [Remplace Funk It]    *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Version 2.7 ÷÷÷÷÷*
;Trois labels d'assemblage conditionnels:
;	NO_FTUNE : Si d‚fini, le FineTune n'est pas g‚r‚. C'est plus
;		rapide, mais ‡a peut foirer les modules r‚cents
;	NO_FTEST : Si d‚fini, pas de contr“le des limites de la note
;		Amiga demand‚e (logiquement, test inutile).
;	TYPE_MIX : 0 pour mixage sans balances, rapide
;		1 pour mixage avec balances, moyen
;		2 pour mixage avec balances + interpolation , lent
;	NO_TEMPO : Si d‚fini, la gestion du tempo … travers le timer D
;	           est d‚sactiv‚e.

	include	dsp_play.inc
	output	.bin
	opt	o+,w-
;NO_FTUNE	set	0
NO_FTEST	set	0
TYPE_MIX	set	2
;NO_TEMPO	set	0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷Initialisation globale des variables du soundtracker÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
PartHead	equ	*-$1c		;Fichier+$1c=Adresse init
	bra.w	DSP_init_all	;Lancer tout le replay DSP
	bra.w	Mix_ExecProg	;Charger un programme DSP
	dc.l	sndtrk_data	;Variables soundtracker
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	movem.l	d0-a5,-(sp)	;Routine de replay.
	movec	cacr,d0		;
	move.w	d0,-(sp)		;
	moveq.l	#$19,d0		;
	movec	d0,cacr		;Virer le cache de donn‚e, ce
	bsr	VBL_mixer		;con pourrait nous ralentir
	move.w	#$3919,d0		;
	movec	d0,cacr		;
	bsr	VBL_player		;pour l'envoi des donn‚es vers
	move.w	#$808,d0		;le DSP!.
	or.w	(sp)+,d0		;Remet les caches comme avant,
	movec	d0,cacr		;mais en les vidant, histoire
	movem.l	(sp)+,d0-a5	;d'‚viter les gags.
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Se situe dans la SECTION TEXT pour pouvoir ˆtre accessible en
;PC-relatif.
sndtrk_data
	dcb.b	sndtrk_data_size
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
DSP_init_all
	movem.l	d0-a6,-(sp)	;
	bsr	Reloge_Partplay	;Relocation des pointeur !!
	movem.l	a0-a1,MODULE	;
	bsr.s	Test_module	;Le module est-il bien NTK4 ?
	bne.s	.dia_end		;Z=0,problŠme
	bsr	Init_module	;Reloge les pointeurs module
	bsr	Init_player	;Demarre le module
	bsr.s	Init_replay	;Init les tables de replay
	moveq	#0,d0		;Z=1,ok
.dia_end	movem.l	(sp)+,d0-a6	;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Test le bon format du module choisi
;En sortie,Z=1 si tout va bien.
Test_module
	move.l	MODULE(pc),d0	;
	ble.s	.tm_ok		;adresse valable ?
	movea.l	d0,a0		;
	moveq	#31,d0		;31 instruments maxi
.tm_bcl	cmpi.l	#"NTK4",(a0)	;donc 32 tests
	lea	16(a0),a0		;conserve le CCR
	dbeq	d0,.tm_bcl		;hop
.tm_ok	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷         Calcule les incr‚ments de fr‚quence du 50Khz        ÷÷÷÷÷÷*
*÷÷÷÷÷÷    pour le DSP, puis installe le player (qui est stopp‚)    ÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
Init_replay
*÷÷÷÷÷÷÷÷÷÷
;En A0, adresse de la future table de fr‚quence
;Les valeurs suivantes sont pr‚d‚finies:
Frq_DSP_50	equ	$24665683
Calcul_Freqinc
	movea.l	Freq_Inc(pc),a0	;
	move.l	#Frq_DSP_50,d0	;
	moveq	#108,d1		;depuis 108 (finetune mini)
.cf_bcl0	move.l	d0,d2		;
	divu.l	d1,d2		;
	move.l	d2,(a0)+		;
	addq.w	#1,d1		;
	cmpi.w	#907,d1		;Until 907
	ble.s	.cf_bcl0		;(907=p‚riode finetune maximale)
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
; Fixe les paramŠtres du systŠme sonore Falcon.
;Plan de la matrice:
;o DMA-Playback -> DSP-Input
;o DSP-Output   -> DMA-Record, Xternal-Output, DAC
;
InitMatrix	st.b	song_stop+sndtrk_data	;
	move.w	#$0400,$ffff8900.w	;Interruption Timer A, coupe DMA
	move.b	#2,$ffff8937.w	;ADDRin sur la matrice
	move.w	#$0040,$ffff8920.w	;piste 0 en 16 bits st‚r‚o
	move.w	#$0111,$ffff8930.w	;Connexions de la matrice.
	move.w	#$2313,$ffff8932.w	;
	move.w	#$0001,$ffff8934.w	;Diviseur 49Khz.
	move.w	#1,-(sp)		;Installe le programme DSP
	pea	dspmixeursize/3.w	;
	pea	dspmixeur(pc)	;
	move.w	#$6d,-(sp)		;Pof, c'est fait
	trap	#14		;
	lea	12(sp),sp		;
	bclr	#3,$fffffa17.w	;Passe le MFP en AEI
	clr.b	$fffffa19.w	;Coupe le Timer A, pour installer
	move.l	#Out_Dma,$134.w	;la routine qui envoie les samples
	bset	#5,$fffffa07.w	;vers le DSP...
	bset	#5,$fffffa13.w	;
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
Reloge_Partplay			;
	movem.l	d0-d1/a0-a1,-(sp)	;
	lea	PartHead(pc),a0	;
	tas	(a0)		;D‚j… relog‚ ?
	bmi.s	.rp_end		;
	addq.l	#2,a0		;
	move.l	(a0)+,a1		;Taille Text
	adda.l	(a0)+,a1		;           +Data
	adda.l	4(a0),a1		;Saute les ‚ventuels symbols
	lea	$1c-10(a0),a0	;->d‚but programme
	adda.l	a0,a1		;->d‚but table relocation
	move.l	a0,d0		;offset de relocation
	move.l	(a1)+,d1		;1er mot-long de table
	beq.s	.rp_end		;Nul=deja fini ?

.rp_reloc	adda.l	d1,a0		;Avance dans le code
	add.l	d0,(a0)		;Reloge
	moveq	#0,d1		;
.rp_bcl	move.b	(a1)+,d1		;Suivant !
	beq.s	.rp_end		;Finito ?
	cmpi.b	#$1,d1		;+254 ?
	bne.s	.rp_reloc		;
	lea	254(a0),a0		;Oui, alors suivant
	bra.s	.rp_bcl		;
.rp_end	movem.l	(sp)+,d0-d1/a0-a1	;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷Relocation des samples du module÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
Init_module
	movea.l	MODULE(pc),a0	;
	movea.l	a0,a1		;
	move.l	(a0),d2		;d‚but premier sample
	add.l	a1,d2		;offset->adresse

.im_bcl	cmpi.l	#"NTK4",(a0)	;Fin de la table de sample ?
	beq.s	.im_end		;oui,stop
	move.l	(a0),d0		;non,prendre l'offset
	move.l	d0,d1		;
	add.l	a1,d0		;on le trasnforme en adresse
	move.l	d0,(a0)+		;on stocke
	sub.l	d1,(a0)+		;transforme le spl_end en size,
				;pour cette routine de replay
	addq.l	#8,a0		;saute spl_replen,spl_vol&ftune
	bra.s	.im_bcl		;suivant

.im_end	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷Initialise les pointeurs du player÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Pour lancer la lecture d'un module,il faut :
;
; _mettre le song_pos … 0
; _mettre le pat_break0 … -1 (ou n‚gatif) et le pat_break1 … 0
; _effacer tout le reste
; _mettre l'adresse de fin d'un sample non boucl‚ dans les 4 voies
;
Init_player
	lea	sndtrk_data(pc),a4	;
	movea.l	a4,a0
	move.w	#voice4+voice_size-1,d0
.ip_clr	clr.b	(a0)+
	dbf	d0,.ip_clr
	move.l	MODULE(pc),a0
.ip_srch1	tst.l	spl_replen(a0)
	beq.s	.ips1_0
	cmpi.l	#"NTK4",16(a0)
	beq.s	.ips1_0
	lea	16(a0),a0
	bra.s	.ip_srch1
.ips1_0	move.l	spl_start(a0),d0
	move.l	spl_end(a0),d1
	move.l	d0,voice1+spl_start(a4)
	move.l	d1,voice1+spl_end(a4)
	move.w	#$1ac,voice1+base_freq(a4)
	move.w	#$1ac,voice1+real_freq(a4)
	move.b	#$18,voice1+spl_bal(a4)

	move.l	d0,voice2+spl_start(a4)
	move.l	d1,voice2+spl_end(a4)
	move.w	#$1ac,voice2+base_freq(a4)
	move.w	#$1ac,voice2+real_freq(a4)
	move.b	#$68,voice2+spl_bal(a4)

	move.l	d0,voice3+spl_start(a4)
	move.l	d1,voice3+spl_end(a4)
	move.w	#$1ac,voice3+base_freq(a4)
	move.w	#$1ac,voice3+real_freq(a4)
	move.b	#$68,voice3+spl_bal(a4)

	move.l	d0,voice4+spl_start(a4)
	move.l	d1,voice4+spl_end(a4)
	move.w	#$1ac,voice4+base_freq(a4)
	move.w	#$1ac,voice4+real_freq(a4)
	move.b	#$18,voice4+spl_bal(a4)

.ip_srch2	cmpi.l	#"NTK4",(a0)+	;recherche l'id de fin
	bne.s	.ip_srch2		;des infos samples.
.ips2_0	moveq	#0,d0		;fixe la longueur de la
	move.b	(a0)+,d0		;partitions ainsi que son
	move.w	d0,song_long(a4)	;point de red‚marrage.
	move.b	(a0)+,d0		;Warning:Si red‚marrage=$78
	cmpi.w	#$78,d0		;valeur fausse (dummy byte
	bne.s	.ips2_1		;des anciens soundtrackers)
	clr.w	d0		;Et mise … z‚ro par d‚faut
.ips2_1	move.w	d0,song_loop(a4)	;
	move.l	a0,song_base(a4)	;conserve la base de la
	lea	128(a0),a0		;partition ainsi que
	move.l	a0,pat_base(a4)	;des pattern
	st	pat_break0(a4)	;commence par un break
	clr.w	pat_break1(a4)	;au d‚but du pattern
	clr.w	song_pos(a4)	;pour lancer le tout
	clr.w	compteur(a4)	;
	move.w	#6,speed(a4)	;Vitesse par d‚faut,
	move.w	#$7D,tempo(a4)	;Tempo par d‚faut
	move.w	#$100,master_vol(a4)	;plein volume,
vm_rts	move.w	#-2,rundsp(a4)	;Premier transfert.
	bclr	#7,$ffff8931.w	;
	rts			;(liaison DSP->Matrice)


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷Chargement d'un programe DSP au format binaire÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Entr‚e:	A0 = programme au format binaire crach‚ par Dsp_LodToBinary
;	D0 = taille de ce fichier en mots DSP
;
;Ce sont les mˆmes paramŠtres que le Dsp_ExecProg original, ability en
;moins.
Mix_ExecProg
	movem.l	d0-d1/a0,-(sp)	;
	move.b	#$80+$14,$ffffa201.w	;D‚clenche le loader cot‚ DSP.
.waiting	tst.b	$ffffa201.w	;Attendre sa r‚action
	bmi.s	.waiting		;
.send	subq.l	#1,a0		;Envoyer des mots DSP, merci le
	move.l	(a0)+,d1		;030 pour les adresses impaires!
.0	btst	#1,$ffffa202.w	;Attendre le bon vouloir du DSP
	beq.s	.0		;
	move.l	d1,$ffffa204.w	;Paf, balance la sauce.
	moveq	#-1,d1		;Dernier transfert ?
	subq.w	#1,d0		;
	beq.s	.0		;Oui, envoyer un -1 au DSP
	bpl.s	.send		;Non, suivant
	movem.l	(sp)+,d0-d1/a0	;Finito !
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷Mixage des samples÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
ReadHost	MACRO	dst
.\@	btst	#0,(a0)
	beq.s	.\@
	move.l	(a1),\1
	ENDM
WritHost	MACRO	src
.\@	btst	#1,(a0)
	beq.s	.\@
	move.l	\1,(a1)
	ENDM

vm_plantage
	not.w	$ffff9800.w	;
	rts

VBL_mixer	lea	sndtrk_data(pc),a4	;Les variables..
	tst.b	song_stop(a4)	;
	bne	vm_rts		;
	tas	$ffff8931.w	;Connecte DSP->Matrice
	lea	$ffffa201.w,a0	;Host Command Vector Register
	lea	$ffffa204.w,a1	;Host Transmit/Receive
	move.b	#$80+$13,(a0)	;Paf, d‚clenche le Host
	move.w	#1000,d0		;
.waithc	tst.b	(a0)		;Attendre le d‚clenchement, au cas
	dbpl	d0,.waithc		;o— le DSP serait sur un gros REP.
	bmi.s	vm_plantage	;
	addq.l	#1,a0		;Host Interrupt Status Register

	move.l	#"NTK",d3	;<POUR NE PAS COUPER&BLOQUER UN TRANSFERT HOST>
	move.l	d3,d2		;Par d‚faut: Host->030 vide,
	move.l	d3,d1		;sur 2 niveaux...
.link	move.l	d1,d0		;Conserve les 2 pr‚c‚dents
	move.l	d2,d1		;
	ReadHost	d2		;Lire le port Host
	cmp.l	d3,d2		;C'est la synchro du mixer ?
	bne.s	.link		;Non, on l'attend !...
	WritHost	d3		;Balance notre identification, et lire
	ReadHost	-(sp)		;ce que le mixer a capt‚ pour Host->DSP
	ReadHost	-(sp)		;
	WritHost	d0		;On lui envoie ce que l'on a capt‚.
	WritHost	d1		;
;A partir de maintenant, 030 et DSP sont synchros...
	move.w	master_vol(a4),d4	;Volume g‚n‚ral, ben oui
	move.w	rundsp(a4),d0	;Premier envoi ?
	clr.w	rundsp(a4)		;
	tst.b	dma2dsp(a4)	;
	lea	voice1(a4),a4	;
	bne	Mix_030		;

Mix_DMA	ext.l	d0		;-2 ou 0, transfert DMA
	move.l	d0,(a1)		;Zou galinette.
	bpl.s	.cmd_0		;
.winit	ReadHost	d0		;Si init, attendre le DSP
.cmd_0	ReadHost	d0		;R‚ponse DSP: r‚initialisation ??
	beq.s	.winit		;

	moveq	#4-1,d2		;4 voix … mixer...
	lea	dmalst(pc),a3	;
.cmd_loop	moveq	#0,d0		;
	move.b	spl_bal(a4),d0	;Balance du sample
	swap	d0		;
	move.l	d0,(a1)		;
	move.w	spl_vol(a4),d0	;Volume lin‚aire de l'Amiga
	mulu	d4,d0		;Selon le volume global
	move.l	d0,(a1)		;

	move.w	real_freq(a4),d0	;Incr‚ment de fr‚quence
	IFND	NO_FTEST		;
	subi.w	#108,d0		;
	bpl.s	*+4		;Inutile normalement, vu
	moveq	#0,d0		;que la lecture de partition
	cmpi.w	#907-108,d0	;contr“le un peu les valeurs
	ble.s	*+6		;
	move.w	#907-108,d0	;
	move.l	([Freq_Inc.w,pc],d0.w*4),(a1)
	ELSE			;
	move.l	([Freq_Inc.w,pc],d0.w*4,-108*4.w),(a1)
	ENDC			;

	movea.l	spl_start(a4),a2	;Pr‚pare les pointeurs du
	move.l	spl_pos(a4),d1	;sample.
	adda.l	d1,a2		;
	move.l	(a1),d0		;Le DSP nous donne l'avanc‚e
	add.l	d0,d1		;dans le sample en 1/50 sec.

	cmp.l	spl_end(a4),d1	;
	blt.s	.cmd_r1		;Voil…, au prochain coup le
	tst.l	spl_replen(a4)	;sample en sera l….
	bne.s	.cmd_r0		;
	move.l	spl_end(a4),d1	;
	bra.s	.cmd_r1		;
.cmd_r0	sub.l	spl_replen(a4),d1	;
.cmd_r1	move.l	d1,spl_pos(a4)	;

	lsr.l	#2,d0		;Mais bon, faut d‚j… envoyer!
	add.l	d0,d0		;DMA 16 bits st‚r‚o->4 octets->2 mots DSP
	addq.l	#4,d0		;
	move.l	d0,(a1)		;Retour … l'envoyeur

	move.l	a2,d1		;
	lsr.w	#1,d1		;Signale la parit‚ de
	subx.l	d1,d1		;d‚but de l'‚chantillon (car
	move.l	d1,(a1)		;le DMA demande la parit‚,
	adda.l	d1,a2		;->le DSP sautera le 1er octet)
	move.l	a2,(a3)+		;
	add.l	d0,d0		;
	adda.l	d0,a2		;
	move.l	a2,(a3)+		;hoplaboum
.cmd_7	lea	voice_size(a4),a4	;
	dbf	d2,.cmd_loop	;

.cmd_run	clr.b	$ffff8901.w	;
	move.b	#1,$fffffa1f.w	;
	movem.l	dmalst(pc),d0-d3	;
	move.w	#-3,dmacnt		;
	move.b	d0,$ffff8907.w	;Debut de sample
	lsr.w	#8,d0		;
	move.l	d0,$ffff8902.w	;
	move.b	d1,$ffff8913.w	;Fin de sample
	lsr.w	#8,d1		;
	move.l	d1,$ffff890e.w	;


.syncd0	btst	#0,(a0)		;Synchro DSP, indispensable pour
	beq.s	.syncd0		;lancer le DMA et le SSI en mˆme
	tst.l	(a1)		;temps.
.syncd1	btst	#1,(a0)		;
	beq.s	.syncd1		;
	move.l	d0,(a1)		;

	move.b	#3,$ffff8901.w	;Et paf, c'est parti...
	tas	$ffff8933.w	;Connecte le SSI sur la matrice (Matrice->DSP)
	move.b	d2,$ffff8907.w	;
	lsr.w	#8,d2		;Pr‚pare le sample suivant.
	move.l	d2,$ffff8902.w	;
	move.b	d3,$ffff8913.w	;
	lsr.w	#8,d3		;
	move.l	d3,$ffff890e.w	;
	move.b	#8,$fffffa19.w	;EventCount, mais ignore la 1Šre
				;interruption...
wm_ReSend	moveq	#1,d0		;Si c'est n‚cessaire, rebalance au
.resend	move.l	(sp)+,d1		;DSP un envoi Host interrompu par
	cmpi.l	#'NTK',d1		;le mixeur.
	beq.s	.nosend		;
	move.l	d1,(a1)		;
.nosend	dbf	d0,.resend		;
	rts			;

dmalst	ds.l	2*4		;
dmabrk	dc.l	spldummy,spldummy+18*2
dmacnt	dc.w	1		;
Out_Dma	move.l	d1,-(sp)		;On balance les 2 derniers samples ici
	movec	cacr,d1		;
	move.w	d1,-(sp)		;Ah, ce cache interne,
	moveq	#0,d1		;quel farceur...
	movec	d1,cacr		;
	move.l	d0,-(sp)		;
	move.w	dmacnt(pc),d0	;
	addq.w	#1,d0		;
	move.w	d0,dmacnt		;
	ble.s	.out_ok		;
	clr.b	$fffffa19.w	;Coupe l'It & le DMA,
	move.b	#2,$fffffa1f.w	;dans 2 interruptions (le temps
	move.l	#Stop_Dma,$134.w	;de laisser la SSI dig‚rer).
	move.b	#8,$fffffa19.w	;
	bra.s	.out_fin		;
.out_ok	movem.l	(dmabrk.w,pc,d0.w*8),d0-d1;s‚curit‚ du cot‚ DSP.
	move.b	d0,$ffff8907.w	;
	lsr.w	#8,d0		;
	move.l	d0,$ffff8902.w	;
	move.b	d1,$ffff8913.w	;
	lsr.w	#8,d1		;
	move.l	d1,$ffff890e.w	;
.out_fin	move.l	(sp)+,d0		;
	move.w	#$800,d1		;On a touch‚ … des datas, donc le
	or.w	(sp)+,d1		;cache n'est plus valide...
	movec	d1,cacr		;C'est absurde mais bon..
	move.l	(sp)+,d1		;
	rte
spldummy	dcb.w	18,$7f80

Stop_Dma	clr.b	$fffffa19.w
	move.l	#Out_Dma,$134.w
	clr.b	$ffff8901.w
	rte			;

Mix_030	addq.w	#1,d0		;-1 ou 1, transfert 030
	ext.l	d0		;
	move.l	d0,(a1)		;Vroom, on le passe au dsp
	bpl.s	.cm0_go		;
.winit	ReadHost	d0		;Si init, attendre le DSP
.cm0_go	ReadHost	d0		;Tout est ok ?
	beq.s	.winit		;Gasp, le DSP se re-init!

	lea	dmalst(pc),a3	;
	moveq	#4-1,d2		;4 voix … mixer...
	moveq	#0,d3		;
	subq.w	#1,d3		;Masque $0000FFFF

.cm0_loop	moveq	#0,d0		;
	move.b	spl_bal(a4),d0	;Balance du sample
	swap	d0		;
	move.l	d0,(a1)		;
	move.w	spl_vol(a4),d0	;Volume
	mulu	d4,d0		;
	move.l	d0,(a1)		;

	move.w	real_freq(a4),d0	;Incr‚ment de fr‚quence
	IFND	NO_FTEST		;
	subi.w	#108,d0		;
	bpl.s	*+4		;
	moveq	#0,d0		;
	cmpi.w	#907-108,d0	;
	ble.s	*+6		;
	move.w	#907-108,d0	;
	move.l	([Freq_Inc.w,pc],d0.w*4),(a1)
	ELSE			;
	move.l	([Freq_Inc.w,pc],d0.w*4,-108*4.w),(a1)
	ENDC			;

	movea.l	spl_start(a4),a2	;
	move.l	spl_pos(a4),d1	;
	adda.l	d1,a2		;
	move.l	(a1),d0		;
	add.l	d0,d1		;

	cmp.l	spl_end(a4),d1	;
	blt.s	.cm0_r1		;Voil…, au prochain coup le
	tst.l	spl_replen(a4)	;sample en sera l….
	bne.s	.cm0_r0		;
	move.l	spl_end(a4),d1	;
	bra.s	.cm0_r1		;
.cm0_r0	sub.l	spl_replen(a4),d1	;
.cm0_r1	move.l	d1,spl_pos(a4)	;

	divu.w	#3,d0		;
	addq.w	#2,d0		;
	and.l	d3,d0		;
	move.l	d0,(a1)		;Retour … l'envoyeur
	move.l	a2,(a3)+		;
	move.l	d0,(a3)+		;
	move.l	d0,(a1)		;Pas de parit‚ … envoyer
	lea	voice_size(a4),a4	;Suivant !
	dbf	d2,.cm0_loop	;

.sync00	btst	#0,(a0)		;Synchro DSP, s‚curit‚ pour le
	beq.s	.sync00		;trasfert Host, pas indispensable
	tst.l	(a1)		;mais permet un code unique cot‚ DSP.
.sync01	btst	#1,(a0)		;
	beq.s	.sync01		;
	move.l	d0,(a1)		;

	lea	dmalst(pc),a3	;
	moveq	#4-1,d2		;
.cm0_tx	move.l	(a3)+,a2		;
	move.l	(a3)+,d0		;

	moveq	#7,d1		;
	and.w	d0,d1		;
	neg.w	d1		;
	lsr.w	#3,d0		;
	jmp	.cm0_5(pc,d1.w*4)	;
.cm0_4
	rept	8
	subq.l	#1,a2		;
	move.l	(a2)+,(a1)		;
	endr
.cm0_5	dbf	d0,.cm0_4		;
	dbf	d2,.cm0_tx		;
	bra	wm_ReSend		;

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷Lecture de la partition et gestion des effets÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷          Centre nerveux du player !         ÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
VBL_player
	lea	sndtrk_data(pc),a0	;les variables..
	tst.b	song_stop(a0)	;Module stopp‚ ?
	bne.s	vp_rts		;Oui, cassos..
	subq.w	#1,compteur(a0)	;compteur--
	ble	vp_read_pattern	;lire la partition ?

vp_command	lea	voice1(a0),a2	;non,alors controle les
	moveq	#3,d6		;effets (4 voies)
vpc_bcl	movem.w	comm(a2),d1-2	;d1:data d2:commande
	jmp	([vpc_ad.w,pc,d2.w])	;go !
vp_rts	rts			;
vpc_ad	dc.l	vpc_arpege		;0=ArpŠge
	dc.l	vpc_portup		;1=Portamento Up
	dc.l	vpc_portdn		;2=Portamento Down
	dc.l	vpc_portto		;3=Portamento Tone
	dc.l	vpc_vibrato	;4=Vibrato
	dc.l	vpc_port_vol	;5=Portamento Tone+Volume Slide
	dc.l	vpc_vibr_vol	;6=Vibrato+Volume Slide
	dc.l	vpc_tremolo	;7=Tremolo
	dc.l	vpc_reset		;8=Rien
	dc.l	vpc_reset		;9=Pas maintenant
	dc.l	vpc_volslid	;A=Volume Slide
	dc.l	vpc_reset		;B=Pas maintenant
	dc.l	vpc_reset		;C=Pas maintenant
	dc.l	vpc_reset		;D=Pas maintenant
	dc.l	vpc_E_com		;E=Sp‚cialit‚s locales..
	dc.l	vpc_reset		;F=Pas maintenant

vpc_E_com	move.w	d1,d2		;
	and.w	#$00f,d1		;Commendes Ex
	sub.w	d1,d2		;
	cmpi.w	#$0c0,d2		;Note Cut ?
	beq.s	vpc_note_cut	;oui
	cmpi.w	#$090,d2		;Note Retrig ?
	beq.s	vpc_retrig_note	;oui
	cmpi.w	#$0d0,d2		;Note Delay ?
	bne.s	vpc_next		;Non

vpc_note_delay
	move.w	freq(a2),d0	;Y'avait une fr‚quence ?
	beq.s	vpc_next		;Notre compteur va de
	sub.w	speed(a0),d1	;Speed … 1,alors que data
	add.w	compteur(a0),d1	;est pr‚vu pour 0 … Speed-1
	bne.s	vpc_next		;Donc on corrige.....
	move.w	instr(a2),d3	;
	movem.l	([MODULE.w,pc],d3.w,-16.w),d3-d5/a3 ;Et r‚cupŠre ses infos
	movem.l	d3-d5/a3,(a2)	;
	tst.w	emulbug(a2)	;
	bne.s	.spl0		;
	clr.l	spl_off(a2)	;
	move.w	spl_vol(a2),base_vol(a2)
	bra.s	.spl1		;
.spl0	move.w	base_vol(a2),spl_vol(a2);
.spl1	
	IFD	NO_FTUNE		;Si le FineTune est interdit
	move.w	d0,base_freq(a2)	;
	move.w	d0,real_freq(a2)	;
	ELSE			;
	lea	PeriodeTable(pc),a3	;
	bsr	v_getftune		;On approxime la note
	adda.w	spl_ftune(a2),a3	;et on prend l'‚quivalent
	move.w	(a3),base_freq(a2)	;du finetune=>fr‚q de base
	move.w	(a3),real_freq(a2)	;ainsi que celle jou‚e.
	ENDC
	move.l	spl_off(a2),spl_pos(a2);Utiliser SampleOffset pour lancer le sample
	bra.s	vpc_next		;

vpc_retrig_note
	bsr	v_retrig_note
	bra.s	vpc_next

vpc_note_cut
	sub.w	speed(a0),d1	;Il faut qu'il se soit ecoul‚
	add.w	compteur(a0),d1	;(data) VBL avant de couper
	bne.s	vpc_next		;rat‚
	move.w	d1,spl_vol(a2)	;Ca y'est,coupe le volume
	move.w	d1,base_vol(a2)	;(basique et reel)

vpc_reset	move.w	base_freq(a2),real_freq(a2);certaines commandes
				;remettent la fr‚quence de base
vpc_next	lea	voice_size(a2),a2	;prochaine voie
	dbf	d6,vpc_bcl		;
	rts			;

vpc_portup	move.w	base_freq(a2),d0	;augmente la frequence
	sub.w	d1,d0		;selon le data
	cmpi.w	#113,d0		;trop petit ?
	bge.s	vpcpup_end		;non.
	moveq	#113,d0		;si,retablit
vpcpup_end	move.w	d0,base_freq(a2)	;sauve dans les 2 frequences
	move.w	d0,real_freq(a2)	;a la fois
	bra.s	vpc_next		;yeah.Hop
vpc_portdn	move.w	base_freq(a2),d0	;idem,mais sens inverse
	add.w	d1,d0		;
	cmpi.w	#856,d0		;
	ble.s	vpcpup_end		;
	move.w	#856,d0		;
	bra.s	vpcpup_end		;

vpc_vibr_vol			;Effets combin‚s: sont trait‚s
	move.w	d1,-(sp)		;comme un portamento tone
	bsr	in_vpcvib		;ou un vibrato dont l'octet de
	move.w	(sp)+,d1		;parametre est nul,suivi d'un
	bra.s	in_vpc_volslid	;volume slide selon le vrai
vpc_port_vol			;octet de commande
	bsr	in_vpcpto		;
	bra.s	in_vpc_volslid

vpc_volslid			;slide de volume.
	move.w	base_freq(a2),real_freq(a2);remettre la bonne fr‚quence
in_vpc_volslid			;^- interdit si virb_vol ou port_vol
	moveq	#$0f,d0		;quartet faible
	and.w	d1,d0		;non nul ?
	bne.s	vpcvdn		;oui, c'est une aumentation
vpcvup	lsr.w	#4,d1		;mais si,augmentation
	add.b	base_vol(a2),d1	;on rajoute ca au volume
	cmpi.b	#$40,d1		;maximalise
	ble.s	*+4		;
	moveq	#$40,d1		;
	move.b	d1,base_vol(a2)	;et hop
	move.b	d1,spl_vol(a2)	;
	bra.s	vpc_next		;
vpcvdn	move.b	base_vol(a2),d1	;idem,mais dans l'autre
	sub.b	d0,d1		;sens
	bpl.s	*+4		;...
	moveq	#0,d1		;
	move.b	d1,base_vol(a2)	;
	move.b	d1,spl_vol(a2)	;
	bra.s	vpc_next		;	

arp_compt	dc.b	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0;F(X)=X MOD 3
	dc.b	1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1;
vpc_arpege	tst.b	d1		;si pas de paramŠtre
	beq.s	vpca_2		;alors pas d'arpŠge!
	move.w	speed(a0),d3	;Notre compteur fait n..1
	sub.w	compteur(a0),d3	;->il faut 0..n-1
	move.b	arp_compt(pc,d3.w),d3	;prendre le No de note
	beq.s	vpca_2		;si nul,note normale
	subq.w	#2,d3		;si 2,alors quartet faible
	beq.s	vpca_0		;
	lsr.b	#4,d1		;sinon quartet fort
vpca_0	move.w	base_freq(a2),d0	;frequence de base
	lea	PeriodeTable(pc),a3	;table de toutes les notes
	IFND	NO_FTUNE		;
	adda.w	spl_ftune(a2),a3	;selon le finetune
	ENDC			;
	and.w	#$f,d1		;
	bsr	v_getftune		;choppe l'‚quivalent
	move.w	(a3,d1.w*2),real_freq(a2);on recopie alors la
	bra	vpc_next		;note dans la fr‚quence r‚elle
vpca_2	move	base_freq(a2),real_freq(a2);ici,reelle=base
	bra	vpc_next



vpc_portto	tst.w	d1		;data nul ?
	beq.s	vpcpto_0		;oui
	move.b	d1,port_vit(a2)	;non,nouvelle vitesse
	clr.w	comm(a2)		;et annule le data
vpcpto_0	bsr.s	in_vpcpto		;Lancer kernel du portamento
	bra	vpc_next		;suivant

in_vpcpto	move.w	port_fin(a2),d2	;encore actif ?
	beq.s	vpcpto_end		;non,on arrete
	moveq	#0,d0		;annule bits forts
	move.b	port_vit(a2),d0	;prendre la vitesse
	tst.b	port_sns(a2)	;quel sens de slide ?
	bne.s	vpcpto_2		;augmente !
	add.w	base_freq(a2),d0	;non,baisse
	cmp.w	d2,d0		;frequence finale atteinte?
	blt.s	vpcpto_3		;non

vpcpto_1	move.w	d2,real_freq(a2)	;si,alors on la prend
	move.w	d2,base_freq(a2)	;directement
	clr.w	port_fin(a2)	;et on l'efface
vpcpto_end	rts			;retour … l'envoyeur

vpcpto_2	sub.w	base_freq(a2),d0	;idem,mais pour une baisse
	neg.w	d0		;
	cmp.w	d2,d0		;
	ble.s	vpcpto_1		;

vpcpto_3	move.w	d0,base_freq(a2)	;fr‚quence de base
	IFND	NO_FTUNE		;
	tst.b	glissando(a2)	;glissando actif ?
	beq.s	vpcpto_4		;non
	lea	PeriodeTable(pc),a3	;si, on approxime la fr‚quence
	adda.w	spl_ftune(a2),a3	;r‚elle.
	bsr	v_getftune		;
	move.w	(a3),real_freq(a2)	;
	rts			;
	ENDC			;
vpcpto_4	move.w	d0,real_freq(a2)	;
	rts



vpc_vibrato
	tst.w	d1		;nouvelle vitesse/amplitude ?
	beq.s	vpcvib_0		;non
	move.b	d1,vibr_va(a2)	;si !
	clr.w	comm(a2)		;Efface ancienne valeur
vpcvib_0	bsr.s	in_vpcvib		;Lancer Kernel du vibrato
	bra	vpc_next		;suivant

in_vpcvib	moveq	#$3f,d1		;modulo 64 de l'
	and.b	vibr_off(a2),d1	;offset de vibration
	moveq	#3,d2		;bits 0-1 uniquement du
	and.b	vibr_ctrl(a2),d2	;controleur de la waveform
	beq.s	ivpcvib_2		;si nul,RAS
	add.w	d1,d1		;sinon,prendre 4*offset
	add.w	d1,d1		;
	subq.w	#1,d2		;ctrl=1 ?
	beq.s	ivpcvib_3		;Oui,alors progression lineaire
	add.b	d1,d1		;Non,on maximalise l'amplitude
	moveq	#$7e,d1		;d2=1 -> $7e+1 = $7f
	addx.b	d2,d1		;X selon signe, donc on obtient
	bra.s	ivpcvib_3		;$7F si positif (X=0) ou $80

ivpcvib_2	move.b	vibr_sin(pc,d1.w),d1	;
ivpcvib_3	ext.w	d1		;on etend le signe.
	move.b	vibr_va(a2),d0	;on cherche l'amplitude du
	moveq	#$0f,d2		;
	and.b	d0,d2		;vibrato
	muls.w	d2,d1		;voil…,on a donc 128*amplitude
	asr.w	#6,d1		;on reprend 2*amplitude
	add.w	base_freq(a2),d1	;centr‚e sur la base de frequence
	move.w	d1,real_freq(a2)	;qui donne donc ce qu'on veut
	lsr.b	#4,d0		;maintenant,la vitesse du sinus
	add.b	d0,vibr_off(a2)	;hop,incr‚mente
	rts			;retour … l'envoyeur

vibr_sin	dc.b	$00,$0c,$18,$25,$30,$3c,$47,$51
	dc.b	$5a,$62,$6a,$70,$76,$7a,$7d,$7f
	dc.b	$7f,$7f,$7d,$7a,$76,$70,$6a,$62
	dc.b	$5a,$51,$47,$3c,$30,$25,$18,$0c
	dc.b	$00,$f3,$e7,$da,$cf,$c3,$b8,$ae
	dc.b	$a5,$9d,$95,$8f,$89,$85,$82,$80
	dc.b	$80,$80,$82,$85,$89,$8f,$95,$9d
	dc.b	$a5,$ae,$b8,$c3,$cf,$da,$e7,$f3	


vpc_tremolo
	move.w	base_freq(a2),real_freq(a2);Ne pas oublier
	tst.w	d1		;nouvelle vitesse/amplitude ?
	beq.s	vpctrem_0		;non
	move.b	d1,trem_va(a2)	;si !
	clr.w	comm(a2)		;signale la prise en compte

vpctrem_0	moveq	#$3f,d1		;modulo 64 de l'
	and.b	trem_off(a2),d1	;offset de vibration
	moveq	#$03,d2		;bits 0-1 uniquement du
	and.b	trem_ctrl(a2),d2	;Controleur de la waveform
	beq.s	vpctrem_2		;si nul,RAS
	add.w	d1,d1		;sinon,prendre 4*offset
	add.w	d1,d1		;
	subq.w	#1,d2		;ctrl=1 ,
	beq.s	vpctrem_3		;Oui,alors progression lineaire
	add.b	d1,d1		;Non,on maximalise l'amplitude
	moveq	#$7e,d1		;d2=1 -> $7e+1 = $7f
	addx.b	d2,d1		;X selon signe, donc on obtient
	bra.s	vpctrem_3		;obtient -64 ou +63.

vpctrem_2	move.b	vibr_sin(pc,d1.w),d1	;
vpctrem_3	ext.w	d1		;on etend le signe.
	move.b	trem_va(a2),d0	;on cherche l'amplitude du
	moveq	#$f,d2		;
	and.b	d0,d2		;tremolo
	muls.w	d2,d1		;voil…,on a donc 128*amplitude
	asr.w	#5,d1		;on reprend 4*amplitude
	add.b	base_vol(a2),d1	;centr‚e sur la base de volume
	bpl.s	vpctrem_4		;
	moveq	#0,d1		;
	bra.s	vpctrem_5		;On borne la valeur obtenue
vpctrem_4	cmpi.b	#$40,d1		;
	ble.s	vpctrem_5		;
	moveq	#$40,d1		;
vpctrem_5	move.b	d1,spl_vol(a2)	;qui donne donc ce qu'on veut
	lsr.b	#4,d0		;maintenant,la vitesse du sinus
	add.b	d0,trem_off(a2)	;
	rts			;retour … l'envoyeur

*÷÷÷÷÷÷÷÷÷÷÷
;En A3, l'adresse de la table FineTune voulue, en D0 la note … approximer
;En sortie, A3 pointe sur l'approximation
v_getftune
	REPT	3
	cmp.w	8*2(a3),d0
	bhs.s	.vgft_0
	lea	9*2(a3),a3
	ENDR
.vgft_0	moveq	#7,d3
	cmp.w	(a3)+,d0
	dbhs	d3,*-2
	blo.s	*+4
	subq.l	#2,a3
	rts

PeriodeTable
; format scrut‚ en 4*9 notes (au lieu de 3*12 de la gamme):
; Il reste qu'une table comporte 36 entr‚e...

; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113

	IFND	NO_FTUNE
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	ENDC
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Lecture de la partition.Seuls certains effets sont valables et
;control‚s.
;Pour lancer la lecture d'un module,il faut :
;
; _mettre le song_pos … 0
; _mettre le pat_break0 … -1 (ou n‚gatif) et pat_break1 … 0
; _effacer tout le reste
; _mettre l'adresse de fin d'un sample non boucl‚ dans les 4 voies
;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
vp_read_pattern
	move.w	speed(a0),compteur(a0);relance le compteur.
	tst.w	pat_break0(a0)	;Pattern shunt‚ ?
	bne.s	vp_np		;oui,directement le suivant...
	tst.b	pat_delay(a0)	;Y'a un delay ?
	beq.s	vp_nd0		;Ah non
	subq.b	#1,pat_delay(a0)	;Si,un de moins
	bra	vp_command		;et continue les commandes

vp_nd0	tst.w	pat_break2(a0)	;Pattern … red‚marrer ?
	beq.s	vp_nd1		;non
	move.w	pat_break1(a0),d2	;si,selon le point voulu
	moveq	#0,d0		;pour effacer
	move.w	d0,pat_break1(a0)	;C'est fini pour lui.
	move.w	d0,pat_break2(a0)	;commande ‚x‚cut‚e.
	bra.s	vp2		;hop.

vp_nd1	moveq	#$10,d2		;
	add.w	pat_pos(a0),d2	;Avance d'un pas dans le pattern
	andi.w	#$3f0,d2		;Ne pas depasser la dose
	bne.s	vp2		;Tout-va-bien ? (ca ne nous..
				;concerne pas).

vp_np	moveq	#0,d0		;effacement...
	move.w	d0,pat_break0(a0)	;pas/plus de break
	move.w	pat_break1(a0),d2	;placement voulue dans pattern
	move.w	d0,pat_break1(a0)	;efface ce bordel (pour les
				;prochains d‚but de pattern)
	move.w	song_pos(a0),d0	;prendre position dans song
	move.w	d0,d1		;
	addq.w	#1,d1		;+1 car 1 de + !!
	cmp.w	song_long(a0),d1	;Fini ?
	blt.s	vp1		;non
	move.w	song_loop(a0),d1	;si,restart le tout
vp1	move.w	d1,song_pos(a0)	;sauve la prochaine position
	movea.l	song_base(a0),a1	;base des songs
	move.b	0(a1,d0.w),d0	;recupŠre le No de pattern
	lsl.l	#8,d0		;*(taille du pattern=1024)/4
	lea	([pat_base.w,a0],d0.l*4),a1
	move.l	a1,pat_adr(a0)

vp2	move.w	d2,pat_pos(a0)	;position actuelle dans pattern
	lea	([pat_adr.w,a0],d2.w),a1;
	lea	voice1(a0),a2	;A2:infos voie concern‚e
	moveq	#3,d6		;4 voies … traiter

*÷÷÷÷÷÷÷÷÷÷	Traitement d'une voie
vp_read_voice
	tst.l	pattlec(a2)	;
	bne.s	vpr_skip		;
	move.w	base_freq(a2),real_freq(a2);

vpr_skip	move.l	(a1)+,d0		;recupŠre note+control
	clr.w	emulbug(a2)	;
	move.l	d0,pattlec(a2)	;stockage brut.
	move.w	d0,d1		;
	swap	d0		;
	move.w	d0,d2		;isole No instrument
	andi.w	#$7ff,d0		;bits 15..11
	sub.w	d0,d2		;
	beq.s	vpr_noinst		;pas d'instrument !
vpr_inst	lsr.w	#7,d2		;->bits 8..4 (*16!)
	clr.l	spl_off(a2)	;Instrument pr‚cis‚->offset annul‚
	move.w	d2,rtsni(a2)	;C'est pas le tout, mais il faut aussi
	tst.w	d0		;‚muler les innombrables bugs du ProTracker!!
	bne.s	.realnew		;
	move.w	instr(a2),d2	;
	move.w	([MODULE.w,pc],d2.w,-16+spl_vol.w),d2
	move.w	d2,spl_vol(a2)	;
	move.w	d2,base_vol(a2)	;
	bra.s	vpr_getcom		;
.realnew	move.w	d2,instr(a2)	;Stocke cet instrument (No*16)
	bra.s	vpr_getcom		;
vpr_noinst	tst.w	d0		;Pas d'instrument, mais une fr‚quence?
	beq.s	vpr_getcom		;
	move.w	rtsni(a2),instr(a2)	;Oui, alors prendre le dernier instrument pr‚cis‚
	move.w	d0,emulbug(a2)	;
;>>En gros:
;. Si y'a note et instrument, no comment
;. Si y'a note et PAS instrument, alors prendre le dernier instrument pr‚cis‚
;  (et non pas utilis‚ !!) puis le relancer selon la note, sans toucher au
;  volume ni au sample-offset.
;. Si y'a instrument et PAS note, alors prendre le volume de l'instrument
;  pr‚cis‚ et le mettre dans celui utilis‚ actuellement, annuler le
;  sample offset et ne pas toucher au reste (!!!)...
;
;Tout ceci d‚rive de bugs d–s au fouilli immonde et aux rajouts bricol‚s qui
;traŒnent dans les sources SoundTracker. C'est incompr‚hensible, et il faut
;tester tous les cas possibles pour constater le r‚sultat (impossible de
;pr‚voir!).

vpr_getcom	move.w	d1,d2		;Isole:
	clr.b	d2		;commande=$X00
	sub.w	d2,d1		;data    =$0YY
	lsr.w	#6,d2		;000..F00->000..03C (*4)
	movem.w	d1-2,comm(a2)	;stocke pour les autres VBL
				;D0=Note demand‚e
	move.w	d0,freq(a2)	;on la conserve
	beq	vpr_comm		;si nulle,pas de note
	jmp	([vpr_ad1.w,pc,d2.w])	;selon la commande...

vpr_ad1	dc.l	vpr_freq		;0=R.A.S
	dc.l	vpr_freq		;1=R.A.S
	dc.l	vpr_freq		;2=R.A.S
	dc.l	vpr_porta_start	;3=d‚marrer un portemento
	dc.l	vpr_freq		;4=R.A.S
	dc.l	vpr_porta_start	;5=porta+volslide
	dc.l	vpr_freq		;6=R.A.S
	dc.l	vpr_freq		;7=R.A.S
	dc.l	vpr_freq		;8=R.A.S
	dc.l	vpr_sample_offset	;9=fixer offset sample
	dc.l	vpr_freq		;A=R.A.S
	dc.l	vpr_freq		;B=R.A.S
	dc.l	vpr_freq		;C=R.A.S
	dc.l	vpr_freq		;D=R.A.S
	dc.l	vpr_note_delay	;E=Note delay ??
	dc.l	vpr_freq		;F=R.A.S

vpr_note_delay
	move.w	d1,d3		;Isole la sous-commande
	andi.w	#$0f0,d3		;
	cmpi.w	#$0d0,d3		;Note Delay ?
	bne.s	vpr_freq		;Non,fr‚quence … raffraichir
				;Si, gŠre le delay.
	cmp.b	d1,d3		;Pas de data dans delay ?
	beq.s	vpr_freq		;Yes man,comme si de rien n'etait
	bra	vpr_next_voice	;Non,ne lance pas encore le sample

vpr_porta_start			;Demarre un Tone Portamento
	IFND	NO_FTUNE		;
	lea	PeriodeTable(pc),a3	;
	bsr	v_getftune		;On approxime la note
	adda.w	spl_ftune(a2),a3	;et on prend l'‚quivalent
	move.w	(a3),d0		;
	ENDC			;
	cmp.w	base_freq(a2),d0	;frequence finale=initiale ?
	bne.s	vprps_0		;non
	clr.w	port_fin(a2)	;si,pas de portamento
	bra	vpr_next_voice	;
vprps_0	slt	port_sns(a2)	;finale < initiale ?
	move.w	d0,port_fin(a2)	;
	bra	vpr_next_voice

vpr_sample_offset			;Rejouer sample depuis position
	tst.w	d1		;Nouvel offset ?
	beq.s	vprso_0		;Non
	move.b	d1,s_offset(a2)	;Si,stocke le !
vprso_0	moveq	#0,d1		;
	move.b	s_offset(a2),d1	;reprendre data d'offset
	lsl.l	#8,d1		;offset selon le parametre
	add.l	spl_off(a2),d1	;add pr‚c‚dent (c pas 1 bug!)
	move.l	spl_end(a2),d3	;taille du sample (end=offset!)
	cmp.l	d3,d1		;offset<taille?
	ble.s	*+4		;oui,l'offset est coh‚rent
	move.l	d3,d1		;non,alors valeur maxi
	move.l	d1,spl_off(a2)	;on stocke...puis vpr_freq

vpr_freq
	move.w	instr(a2),d3	;
	movem.l	([MODULE.w,pc],d3.w,-16.w),d3-d5/a3 ;Et r‚cupŠre ses infos
	movem.l	d3-d5/a3,(a2)	;
	tst.w	emulbug(a2)	;
	bne.s	.spl0		;
	move.w	spl_vol(a2),base_vol(a2)
	bra.s	.spl1		;
.spl0	move.w	base_vol(a2),spl_vol(a2);
.spl1	
	IFD	NO_FTUNE		;Si le FineTune est interdit
	move.w	d0,base_freq(a2)	;
	move.w	d0,real_freq(a2)	;
	ELSE			;
	lea	PeriodeTable(pc),a3	;
	bsr	v_getftune		;On approxime la note
	adda.w	spl_ftune(a2),a3	;et on prend l'‚quivalent
	move.w	(a3),base_freq(a2)	;du finetune=>fr‚q de base
	move.w	(a3),real_freq(a2)	;ainsi que celle jou‚e.
	ENDC
	move.l	spl_off(a2),spl_pos(a2);Utiliser SampleOffset pour lancer le sample

	btst	#2,vibr_ctrl(a2)	;On s'occupe des waveform
	bne.s	vprnv_0		;Si bit 2 nul,alors redemarre
	clr.b	vibr_off(a2)	;la courbe … chaque fois
vprnv_0	btst	#2,trem_ctrl(a2)	;Et ce pour tremolo+vibrato
	bne.s	vpr_comm		;
	clr.b	trem_off(a2)	;

vpr_comm	jmp	([vpr_ad2.w,pc,d2.w])	;selon la commande...

vpr_ad2	dc.l	vpr_PerNop		;0=R.A.S
	dc.l	vpr_PerNop		;1=R.A.S
	dc.l	vpr_PerNop		;2=R.A.S
	dc.l	vpr_PerNop		;3=R.A.S
	dc.l	vpr_PerNop		;4=R.A.S
	dc.l	vpr_PerNop		;5=R.A.S
	dc.l	vpr_PerNop		;6=R.A.S
	dc.l	vpr_PerNop		;7=R.A.S
	dc.l	vpr_PerNop		;8=R.A.S
	dc.l	vpr_PerNop		;9=R.A.S
	dc.l	vpr_PerNop		;A=R.A.S
	dc.l	vpr_jump		;B=Jump To ...
	dc.l	vpr_volume		;C=Set Volume
	dc.l	vpr_break		;D=Pattern Break
	dc.l	vpr_Emanager	;E=Edition Sp‚ciale
	dc.l	vpr_speed		;F=Set Speed

vpr_PerNop	move.w	base_freq(a2),real_freq(a2);

vpr_next_voice
	lea	voice_size(a2),a2	;voie suivante
	dbf	d6,vp_read_voice	;
	rts			;finito el boulo

vpr_Emanager
	move.w	d1,d2		;
	andi.w	#$00f,d1		;Quartet de donn‚e
	sub.w	d1,d2		;Quartet de commande
	lsr.w	#2,d2		;00..F0->00..3C (*4)
	jmp	([vpr_ad3.w,pc,d2.w])	;comme d'habitude...

vpr_ad3	dc.l	vpr_next_voice	;E0=Filter (inactif)
	dc.l	vpr_fineportup	;E1=Fine Portamento Up
	dc.l	vpr_fineportdn	;E2=Fine Portamento Down
	dc.l	vpr_glissando	;E3=Set Glissando Control
	dc.l	vpr_vibr_form	;E4=Set Vibrato Waveform
	dc.l	vpr_fine_tune	;E5=Set Fine Tune
	dc.l	vpr_loop_ctrl	;E6=Loop Controler
	dc.l	vpr_trem_form	;E7=Set Tremolo Waveform
	dc.l	vpr_Estop		;E8=Stop
	dc.l	vpr_retrig		;E9=Retrig note
	dc.l	vpr_finevolup	;EA=Fine Volume Slide Up
	dc.l	vpr_finevoldn	;EB=Fine Volume Slide Down
	dc.l	vpr_note_cut	;EC=Note Cut
	dc.l	vpr_next_voice	;ED=R.A.S
	dc.l	vpr_pat_delay	;EE=Pattern Delay
	dc.l	vpr_set_funk	;EF=Set Funk Repeat

vpr_Estop	st	song_stop(a0)	;Oui,break
	bra.s	vpr_next_voice	;Rien du tout,cassos

vpr_jump	move.w	d1,song_pos(a0)	;Un petit jump dans
	st	pat_break0(a0)	;la partition (data contient
	clr.w	pat_break1(a0)	;le No pattern, qu'on commence
	bra.s	vpr_next_voice	;depuis le d‚but)

vpr_break	moveq	#$0f,d0		;Trafique le data (il est
	and.w	d1,d0		;en BCD)
	sub.w	d0,d1		;Chiffre des dizaines
	mulu	#10,d1		;donc *10 (et premult*16)
	lsl.w	#4,d0		;chiffre unit‚ ( ""  "" )
	add.w	d0,d1		;Combine
	cmpi.w	#64*16,d1		;Dans le pattern ?
	blt.s	vpr_break0		;ouais.
	moveq	#0,d1		;non,par d‚faut...
vpr_break0	st	pat_break0(a0)	;Indique le break
	move.w	d1,pat_break1(a0)	;et la nouvelle position
	bra	vpr_next_voice

vpr_speed	cmpi.w	#$20,d1		;Vitesse correcte ?
	bhs.s	vpr_tempo		;Non, c'est un tempo
	move.w	d1,speed(a0)	;nouvelle vitesse
	move.w	d1,compteur(a0)	;dans le compteur aussi!
	bra	vpr_next_voice	;
vpr_tempo	move.w	d1,tempo(a0)	;
	IFND	NO_TEMPO		;Si c'est autoris‚,
	andi.b	#$f0,$fffffa1d.w	;reconfigure le Timer D.
	cmpi.w	#$79,d1		;
	bge.s	*+4		;Fait rentrer le Tempo dans
	moveq	#$79,d1		;un interval acceptable.
	cmpi.w	#$a0,d1		;
	ble.s	*+6		;Tempo/2.5=Fr‚quence
	move.w	#$a0,d1		;TDDR=256 pour 48Hz
	move.l	#48*256*5/2,d0	;->TDDR=48*256*2.5/Tempo
	divu.w	d1,d0		;
	move.w	d0,d2		;
	swap	d0		;
	add.w	d0,d0		;Arrondir le r‚sultat.
	cmp.w	d1,d0		;
	blt.s	*+4		;
	addq.w	#1,d2		;
	move.b	d2,$fffffa25.w	;
	ori.b	#$07,$fffffa1d.w	;
	ENDC			;
	bra	vpr_next_voice	;
	

vpr_volume	cmpi.w	#$40,d1		;set volume
	bls.s	vpr_vol0		;faut faire gaffe (<$40!)
	moveq	#$40,d1		;quand meme que
vpr_vol0	move.b	d1,spl_vol(a2)	;
	move.b	d1,base_vol(a2)	;
	bra	vpr_next_voice	;

vpr_fineportup
	move.w	base_freq(a2),d0	;augmente la frequence
	sub.w	d1,d0		;
	cmpi.w	#113,d0		;trop petit ?
	bge.s	vprpup_end		;non.
	moveq	#113,d0		;si,retablit
vprpup_end	move.w	d0,base_freq(a2)	;sauve dans les 2 frequences
	move.w	d0,real_freq(a2)	;a la fois
	bra	vpr_next_voice	;yeah.Hop
vpr_fineportdn
	move.w	base_freq(a2),d0	;idem,mais sens inverse
	add.w	d1,d0		;
	cmpi.w	#856,d0		;
	ble.s	vprpup_end		;
	move.w	#856,d0		;
	bra.s	vprpup_end		;

vpr_glissando
	IFND	NO_FTUNE		;
	move.b	d1,glissando(a2)	;
	ENDC
	bra	vpr_next_voice	;suivant

vpr_vibr_form
	move.b	d1,vibr_ctrl(a2)	;de controle pour
	bra	vpr_next_voice	;le vibrato

vpr_trem_form
	move.b	d1,trem_ctrl(a2)	;
	bra	vpr_next_voice	;

vpr_finevolup			;Le principe du fine
	add.b	base_vol(a2),d1	;volume (ou down) est
	cmpi.b	#$40,d1		;le meme que pour
	ble.s	vprfvup_0		;un fine portamento.
	moveq	#$40,d1		;Le changement a lieu
vprfvup_0	move.b	d1,base_vol(a2)	;uniquement prendant la
	move.b	d1,spl_vol(a2)	;la lecture de partition
	bra	vpr_next_voice	;(et non pas … chaque VBL)

vpr_finevoldn
	sub.b	base_vol(a2),d1	;
	neg.b	d1		;
	bpl.s	vprfvup_0		;
	moveq	#0,d1		;
	bra.s	vprfvup_0		;

vpr_note_cut			;
	tst.w	d1		;coupure aprŠs 0 vbl (cad
	bne	vpr_next_voice	;maintenant !!) ?
	move.w	d1,spl_vol(a2)	;oui,efface tout
	move.w	d1,base_vol(a2)	;..
	bra	vpr_next_voice	;..

vpr_pat_delay
	tst.b	pat_delay(a0)	;Y'a deja un d‚lay ?
	bne	vpr_next_voice	;Ouai,ne rien faire
	move.b	d1,pat_delay(a0)	;Non,conserve le delay
	bra	vpr_next_voice	;et cassos

vpr_loop_ctrl
	tst.w	d1		;Data nul ?
	bne.s	vprlc_0		;Non
	move.w	pat_pos(a0),pat_loopos(a0);si,alors c'est le Start!
	bra	vpr_next_voice	;et on se casse
vprlc_0	tst.b	pat_loop(a0)	;Sinon,on est d‚j… en boucle ?
	bne.s	vprlc_1		;oui
	move.b	d1,pat_loop(a0)	;non,entame la boucle !
vprlc_go	move.w	pat_loopos(a0),pat_break1(a0);goto Start
	st	pat_break2(a0)	;en red‚marant le pattern
	bra	vpr_next_voice	;
vprlc_1	subq.b	#1,pat_loop(a0)	;Une boucle de plus !
	bne.s	vprlc_go		;fini ?
	bra	vpr_next_voice	;ouais,arrˆte les frais.

vpr_fine_tune
	IFND	NO_FTUNE		;
	move.w	d1,d0		;
	lsl.w	#3,d1		;
	add.w	d0,d1		;multiplication par 36
	add.w	d1,d1		;=(8+1)*4
	add.w	d1,d1		;
	move.w	d1,spl_ftune(a2)	;On conserve le FineTune
	ENDC
	bra	vpr_next_voice	;

vpr_retrig	bsr.s	v_retrig_note
	bra	vpr_next_voice

v_retrig_note
	tst.w	d1		;Data nulle ?
	beq.s	vrn_end		;ouaip...
	move.w	speed(a0),d0	;Compteur n..1 corrig‚
	sub.w	compteur(a0),d0	;en 0..n-1
	divu	d1,d0		;compteur multiple du retrig ?
	swap	d0		;
	tst.w	d0		;Alors ?
	bne.s	vrn_end		;non
	move.l	spl_off(a2),spl_pos(a2);Reprend sample depuis le debut
vrn_end	rts

vpr_set_funk
	lsl.b	#3,d1		;Il ne sert pas,donc...
	addq.b	#4,d1		;
	move.b	d1,spl_bal(a2)	;
	bra	vpr_next_voice	;suivant


*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;Diff‚rents datas n‚cessaires au programme.
	IFEQ	TYPE_MIX
dspmixeur	incbin	dspmix_0.p56
	ELSE
	IFEQ	TYPE_MIX-1
dspmixeur	incbin	dspmix_1.p56
	ELSE
	IFEQ	TYPE_MIX-2
dspmixeur	incbin	dspmix_2.p56
	ELSE
dspmixeur	incbin	dspmix_0.p56
	ENDC
	ENDC
	ENDC
dspmixeursize equ	*-dspmixeur
	even
MODULE	dc.l	-1		;->module NTK4
Freq_Inc	dc.l	-1		;->incr‚ments de fr‚quence
