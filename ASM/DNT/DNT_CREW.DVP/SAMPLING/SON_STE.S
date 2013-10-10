;Routine de restitution 8 bits pour STE.
;(C)oderight NulloS//DNT 1992
;
;
; Pour restituer le son, il faut utiliser la mˆme fr‚quence que
;celle d'‚chantillonnage, sinon le son va ˆtre d‚form‚.
; Par exemple,si vous utilisez un son digitalis‚ a 12,5Khz, il faut
;le restituer … une fr‚quence de 12,5Khz.
; Le problŠme sur STE, c'est que le choix des fr‚quences est restreint,
;ce qui oblige … :
;	o Digitaliser pile … la bonne fr‚quence le sample.
;	o Re-‚chantilloner par calcul le sample vers une fr‚quence
;	compatible avec le STE.
; Le deuxiŠme cas est … proscrire, car il baisse sensiblement la qualit‚
;de l'‚chantillon. C'est pourtant ce qui est fait dans un soundtracker,
;mais c'est dans ce cas particulier la seule solution.
; Les fr‚quences disponibles sur STE sont 6258Hz,12517Hz,25033Hz et 50066Hz
;Le tout en mono ou en st‚r‚o. Je n'ai pas de sample st‚r‚o … vous offrir,
;donc on s'en passera (de toute facon, digitaliser en st‚r‚o a trŠs peu
;d'int‚rˆt, ca double la taille du sample et ca n'apporte rien de bien
;extraordinaire).La st‚r‚o n'est utile que pour les musiques de type
;soundtracker (ce qui n'est pas notre propos).
; Et il y a la programmation du LMC, mais pour lui, reportez vous … l'article
;du mag'...
;
;

	include	a:\hard_sys.s

Start	move.l	4(sp),a6		;r‚cupŠre page de base
	move.l	$c(a6),a0		;Taille programme
	adda.l	$14(a6),a0		;   +   donn‚es
	adda.l	$1c(a6),a0		;   +   variables
	lea	256+2048(a0),a0	;   +   page de base+pile
	move.l	a0,d0		;
	andi.w	#-2,d0		;arondir … un nombre pair
	move.l	d0,sp		;nouvelle pile
	adda.l	a6,sp		;
	move.l	d0,-(sp)		;taille … conserver
	move.l	a6,-(sp)		;… partir de la page de base
	move.l	#$004a0000,-(sp)	;Mshrink. Rend le reste au
	trap	#1		;Gemdos.
	lea	12(sp),sp		;r‚tablit la pile
	
	clr.l	-(sp)		;passage en superviseur
	move.w	#$20,-(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
	move.l	d0,save_SSP	;sauve la pile systŠme
	move.b	conterm.w,save_conterm;et les paramŠtres clavier
	clr.b	conterm.w		;coupe le bip clavier
	bsr	Wait_Kbd		;
	move.b	#$12,KBD_data.w	;
	
	bsr	InitLMC		;met le LMC comme il faut
	lea	sample,a0
	lea	endsample,a1
	lea	bclsample,a2
	bsr	InitDMA		;lance la digit
presskey	move.l	#$000bffff,-(sp)	;demander l'‚tat shift,control 
	trap	#13		;et altenrate
	addq.l	#4,sp		;
	and.w	#$f,d0		;Press‚e(s) ?
	beq.s	presskey		;non, attendre encore

exit	bsr	KillDMA		;couper la digit
	bsr	ExitLMC		;mettre le LMC aux valeur de d‚faut
	bsr	Wait_Kbd		;attendre clavier
	move.b	#$8,KBD_data.w	;reprendre les transferts
				;souris
	move.b	save_conterm,conterm.w;et remettre bip clavier
	move.l	save_SSP,-(sp)	;repasse en utilisateur
	move.w	#$20,-(sp)		;
	trap	#1		;
	clr.w	(sp)		;et cassos
	trap	#1		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitLMC	movem.l	d0-d1/a0-a1,-(sp)	;
	lea	PCM_base.w,a0	;adresse registres du PCM
	move.w	#_mcw_pmask,mcw_mask(a0);installe mask LMC
	lea	IL_data(pc),a1	;valeur de d‚but
	moveq	#5,d1		;5 r‚glages … faire
IL_bcl	move.w	(a1)+,d0		;un de plus
	bsr	SendLMC		;on l'envoie
	dbf	d1,IL_bcl		;
	movem.l	(sp)+,d0-d1/a0-a1	;
	rts			;
IL_data	dc.w	_master_vol+40,_left_vol+20,_right_vol+20
	dc.w	_treble+6,_bass+6,_pcm_mix+2
;Volume … 40 (maximum), voix gauches et droite … 20 (maximum de ces
;"sous-volumes",aigus et graves … 6 (normal),sample seul.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Passe D0 au LMC. Le masque du LMC doit avoir ‚t‚ mis auparavant
;… $7FF une fois au moins. Et A0 doit ˆtre ‚gal … PCM_base
;On d‚bute par une attente avec dbf, car sinon le LMC n'a pas le temps
;de commencer … envoyer la donn‚e pr‚c‚dente, et on se m‚lange les
;pinceaux !!.
SendLMC	move.w	d0,-(sp)		;sauve D0 en attendant
	move.w	#99,d0		;petite boucle pour laisser
	dbf	d0,*		;le temps au LMC de commencer
	move.w	(sp)+,d0		;le transfert pr‚c‚dent..
	cmpi.w	#_mcw_pmask,mcw_mask(a0);transfert achev‚ ?
	bne.s	*-6		;non, attendre
	move.w	d0,mcw_data(a0)	;demande le transfert de D0
	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ExitLMC	movem.l	d0-d1/a0-a1,-(sp)	;mˆme chose, mais valeurs
	lea	PCM_base.w,a0	;un peu diff‚rentes.
	lea	EL_data(pc),a1	;pas besoin du mask, d‚j… mis
	moveq	#5,d1		
EL_bcl	move.w	(a1)+,d0
	bsr	SendLMC
	dbf	d1,EL_bcl
	movem.l	(sp)+,d0-d1/a0-a1
	rts

EL_data	dc.w	_master_vol+40,_left_vol+20,_right_vol+20
	dc.w	_treble+6,_bass+6,_pcm_mix+1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitDMA	movem.l	d0/a3,-(sp)	;sauve les registres
	lea	PCM_base.w,a3	;adresse DMA
	move.b	#_spl_off,pcm_mode(a3);coupe un ‚ventuel DMA
	move.b	#_mono+_Khz12,pcm_ctrl(a3);monophonie … 12Khz
	move.l	a0,d0		;d‚but de sample
	move.b	d0,spl_startl(a3)	;fixe l'octet faible
	lsr.w	#8,d0		;
	move.b	d0,spl_startm(a3)	;octet moyen
	swap	d0		;
	move.b	d0,spl_starth(a3)	;et octet fort
	move.l	a1,d0		;fin du sample, idem
	move.b	d0,spl_endl(a3)	;fixe l'octet faible
	lsr.w	#8,d0		;
	move.b	d0,spl_endm(a3)	;octet moyen
	swap	d0		;
	move.b	d0,spl_endh(a3)	;et octet fort
	move.b	#_spl_many,pcm_mode(a3) ;joue en boucle
;maintenant le DMA est lanc‚ et va boucler. On va charger par avance l'adresse
;de la boucle. Quand le DMA va arriver en fin de sample, il va alors reprendre
;depuis la derniŠre adresse de d‚but qu'on lui a indiqu‚.Ici, ce sera A2
;Puis lorsqu'il bouclera les fois suivantes, il reprendra cette valeur pour
;boucler, car on ne l'aura pas modifi‚...
	move.l	a2,d0		;boucle du sample
	move.b	d0,spl_startl(a3)	;fixe l'octet faible
	lsr.w	#8,d0		;
	move.b	d0,spl_startm(a3)	;octet moyen
	swap	d0		;
	move.b	d0,spl_starth(a3)	;et octet fort
	movem.l	(sp)+,d0/a3
	rts	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KillDMA	move.l	a0,-(sp)
	lea	PCM_base.w,a0
	move.b	#_spl_off,pcm_mode(a0)
	move.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Wait_Kbd	btst	#1,KBD_stat.w	;clavier prŠs … recevoir ?
	beq.s	Wait_Kbd		;non, attendre
	rts			;c'est bon !
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA

sample	incbin	flut_pan.spl	;sample … restituer
endsample	equ	*		;son adresse fin
bclsample	equ	sample+40962	;bouclage

	SECTION	BSS
save_SSP	ds.l	1
save_conterm
	ds.w	1
