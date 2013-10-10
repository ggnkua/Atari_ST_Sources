;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                 RANDOM                                  ;
;                                                                         ;
;   . Appeler InitRandom pour lancer le processus, avec en paramŠtre:     ;
;                    o D0<>0  Valeur initiale impos‚e                     ;
;                    o D0=0   ------ -------- cr‚‚e de toute piŠce …      ;
;                             partir du timer systŠme et du compteur vid‚o;
;                             L'appel doit alors ˆtre en superviseur.     ;
;                                                                         ;
;   . Puis, pour obtenir une nombre al‚atoire 32 bits, appeler Random     ;
;     qui le retourne en D0. Les bits de CCR sont positionn‚s selon cette ;
;     valeur de retour.                                                   ;
;                                                                         ;
;   . Selon la pr‚sence de l'‚tiquette __RND_TYPE, le random g‚n‚r‚ sera  ;
;     optimis‚ en taille&vitesse (0), ou normal (1)                       ;
;     Le mode optimis‚ est "moins fiable" que l'autre, mais occupe moins  ;
;     de place et est plus rapide. A vous de choisir...                   ;
;     (moins fiable entre guillemets, bicoze y'a aucune ‚tude math‚matique;
;     faite sur cet algo (impossible); les deux repr‚sentent le mˆme algo ;
;     mais avec des paramˆtres de modulo diff‚rents, le (1) ‚tant celui   ;
;     donn‚ en modŠle par son inventeur)                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NulloS/DNT-Crew 1992;

	IFND	__RND_TYPE
__RND_TYPE	equ	0
	ENDC

InitRandom	movem.l	d0-2/a0,-(sp)	;
	tst.l	d0		;semence automatique ?
	bne.s	.IR_fill		;
	move.w	$4ba.w,d0		;oui, on g‚nŠre la semence
	lsl.w	#8,d0		;
	move.b	$ffff8209.w,d0	;
	swap	d0		;
	or.l	$4ba.w,d0		;attention … ce qu'elle ne
	bne.s	.IR_fill		;soit pas nulle !!
	moveq	#%01010011,d0	;<-valeur quelconque!
.IR_fill	moveq	#54,d2		;ce qui suit n'est pas
	lea	gna_buff(pc),a0	;tout … fait un g‚n‚rateur
.IR_bcl	move.l	d0,d1		;de Lehmer, il a ‚t‚ un
	swap	d1		;tout petit peu modifi‚
	mulu	#46819,d0		;pour ne pas faire d‚g‚n‚rer
	mulu	#46819,d1		;la routine random.
	swap	d1		;
	eor.l	d1,d0		;
	IFNE	__RND_TYPE		;
	move.l	d0,220(a0)		;
	ENDC			;
	move.l	d0,(a0)+		;
	dbf	d2,.IR_bcl		;
	movem.l	(sp)+,d0-2/a0	;
	rts

	IFEQ	__RND_TYPE
Random	movem.l	d1/a0,-(sp)	;6
	movea.l	gna_pt(pc),a0	;4
	move.l	-(a0),d0		;4
	cmpa.l	#gna_buff,a0	;4
	beq.s	.restart		;2/3
	move.l	a0,gna_pt		;5
	move.l	-(a0),d1		;4
	eor.l	d1,d0		;2
	move.l	(sp)+,d1		;3
	move.l	d0,(a0)		;3
	movea.l	(sp)+,a0		;3 (conserve CCR)
	rts			;4 ==44

.restart	lea	gna_pt(pc),a0	;2
	move.l	a0,(a0)		;3
	move.l	-(a0),d1		;4
	eor.l	d1,d0		;2
	move.l	(sp)+,d1		;3
	move.l	d0,(a0)		;3
	movea.l	(sp)+,a0		;3 (conserve CCR)
	rts			;4 ==45

	ELSE

Random	movem.l	d1/a0,-(sp)	;6
	movea.l	gna_pt(pc),a0	;4
	move.l	-(a0),d0		;4
	move.l	23*4+4(a0),d1	;4
	eor.l	d1,d0		;2
	move.l	(sp)+,d1		;3
	move.l	d0,(a0)		;3
	cmpa.l	#gna_buff,a0	;4
	beq.s	.restart		;2/3
	move.l	a0,gna_pt		;5
	move.l	d0,55*4(a0)	;4 (stock & test CCR)
	movea.l	(sp)+,a0		;3 (conserve CCR)
	rts			;4 ==48

.restart	lea	gna_buff+55*4(pc),a0	;2
	move.l	a0,55*4(a0)	;4
	move.l	d0,(a0)		;3
	movea.l	(sp)+,a0		;3
	rts			;4 ==49
	ENDC

	IFNE	__RND_TYPE
gna_buff	dcb.l	110,0
gna_pt	dc.l	gna_buff+55*4
	ELSE
gna_buff	dcb.l	55,0
gna_pt	dc.l	gna_pt
	ENDC
