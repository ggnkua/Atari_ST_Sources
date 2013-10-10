;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                         ;
;                 o Sauvegarde des registres Hardware                     ;
;                 o Installation d'exceptions "maison"                    ;
;                 o Changements de r‚solution synchronis‚s                ;
;                   (Par d‚faut, passage en basse pendant InitHard)       ;
;                 o Primitives de gestion du hard                         ;
;                 o Si label TT d‚fini, pas de 50Hz                       ;
;                 o Si label NO_SYS d‚finie, pas d'appel system           ;
;                   (pour effacer buffer clavier + Alt, Shift et Ctrl)    ;
;                 o Si ‚tiquette NO_KBD d‚finie, pas de reset clavier en  ;
;                   InitHard&ExitHard                                     ;
;                                                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;(C)oderight NULLOS//DNT 1990/91/92;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	TEXT
	include	hard_sys.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     Structure du buffer de sauvegarde                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RSRESET
__sync_	rs.b	1
__resol_	rs.b	1
__vbase_	rs.b	3
__hscroll_	rs.b	1
__linewid_	rs.b	1
__yamaha_	rs.b	15
__colors_	rs.w	16
__aer_	rs.b	1
__ddr_	rs.b	1
__iera_	rs.b	1
__ierb_	rs.b	1
__ipra_	rs.b	1
__iprb_	rs.b	1
__isra_	rs.b	1
__isrb_	rs.b	1
__imra_	rs.b	1
__imrb_	rs.b	1
__vr_	rs.b	2
__tacr_	rs.b	1
__tbcr_	rs.b	1
__tcdcr_	rs.b	2
__tadr_	rs.b	1
__tbdr_	rs.b	1
__tcdr_	rs.b	1
__tddr_	rs.b	4
__ucr_	rs.b	1

__inter_	rs.l	24
__ih_size_	rs.b	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                  Initialisation du Hard et des exceptions               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InitHard	move.w	#$2700,sr		;
	movem.l	d0-a6,-(sp)	;
	bsr	UnsetAcia		;coupe l'ACIA
	lea	SaveRegBuffer(pc),a1	;Adresse de sauvegarde
	move.b	v_synch.w,(a1)+	;sauve tous les paramŠtres
	move.b	v_resol.w,(a1)+	;vid‚o
	move.b	v_base_h.w,(a1)+	;
	move.b	v_base_m.w,(a1)+	;
	move.b	v_base_l.w,(a1)+	;
	move.b	v_hscroll.w,(a1)+	;
	move.b	v_linewid.w,(a1)+	;

	moveq	#$e,d0		;Puis ce qui concerne le
IH_yam	move.b	d0,yam_ctrl.w	;Yamaha: tous ses registres
	move.b	yam_read.w,(a1)+	;
	dbf	d0,IH_yam		;

	movem.l	v_color.w,d0-d7	;Maintenant, les couleurs
	movem.l	d0-d7,(a1)		;

	lea	MFP_base.w,a3
	movep.l	AER(a3),d0		;AER,DDR,IERA,IERB
	movep.l	IPRA(a3),d1	;IPRA,IPRB,ISRA,ISRB
	movep.l	IMRA(a3),d2	;IMRA,IMRB,VR,(TACR)
	move.b	UCR(a3),d5		;UCR
	moveq	#0,d4		;On enleve tout
	movep.w	d4,IERA(a3)	;empŠche les IRQ pour ne pas
	movep.w	d4,IMRA(a3)	;gˆner notre d‚tection de TxDR
	move.b	d4,GPIP(a3)	;Flush le registre I/O
	move.b	#$40,VR(a3)	;Mode AEI,vecteurs en $100
	lea	TADR(a3),a4	;premier compteur
	lea	TACR(a3),a5	;et son controleur
	bsr.s	.idg_TxDR		;recupŠre TimerA
	bsr.s	.idg_TxDR		;puis B
	bsr.s	.idg_TxDR		;puis C
	subq.l	#2,a5		;… cause de TCDCR...
	bsr.s	.idg_TxDR		;et enfin D
	movem.l	d0-d5,32(a1)	;D4=TxDR{ABCD}/D3=TxCR{ABC0}
				;     !!!!!WARNING!!!!!~~>0<~~~
	movem.l	$60.w,d0-d7	;
	movem.l	d0-d7,56(a1)	;toutes les IRQ.
	movem.l	$100.w,d0-d7	;
	movem.l	d0-d7,88(a1)	;plus tout le MFP
	movem.l	$120.w,d0-d7	;
	movem.l	d0-d7,120(a1)	;MFP 2Šme...

	bsr	InstallExcept	;Installe les bombes

	move.w	#$2300,sr		;retour … la normale
	bsr	ResetAcia		;remettre l'ACIA
	IFND	NO_KBD		;
	bsr	ResetKbd		;
	ENDC			;
	bsr	ResetShifter	;Un p'tit reset shifter
	bsr	ResetYamaha	;et yamaha (->coupe le son)
	movem.l	(sp)+,d0-a6	;
	rts			;

;R‚cupŠre le TxDR d'un Timer en attendant son passage … 1 (fin de Timer)
;puis un passage par une plus grande valeur (si 0,sortie imm‚diate)
;(si 1,sortie aprŠs un temps d'attente correspondant … la plus grande
;p‚riode).
.idg_TxDR			;En A4=TxDR,A5=TxCR
	move.l	d0,-(sp)	;En sortie,D4.b={TxDR},D3.b={TxCR}
	lsl.l	#8,d4	;pr‚pare D3-4 … recevoir les nouvelles
	lsl.l	#8,d3	;donn‚es
	move.b	(a5),d3	;et A4-5 incr‚ment‚s
	beq.s	.idgt_2	;Si pas de compteur
	move.b	#$44,(a5)	;diviseur 50 ($44 pour TCDCR)
	moveq	#8,d0	;8*28=224 cycles (>8E6/(2457600/50))
.idgt_0	cmpi.b	#1,(a4)	;compteur en fin de parcours ??
	bhi.s	.idgt_0	;non,pas encore.
.idgt_1	move.b	(a4),d4	;r‚cupŠre le TxDR		;8
	cmpi.b	#1,d4	;Encore … 1 ??		;8
	dbne	d0,.idgt_1	;Si Oui,alors boucle jusqu'… fin	;12
.idgt_2	clr.b	(a5)	;Timer OFF
	addq.l	#2,a4	;timer suivant
	addq.l	#2,a5	;
	move.l	(sp)+,d0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ExitHard	move.w	#$2700,sr		;op‚ration inverse.
	IFND	NO_KBD		;Si c'est autoris‚
	reset			;Reset hardware
	ENDC			;
	bsr	UnsetAcia		;vire l'ACIA
	movem.l	d0-a6,-(sp)	;
	lea	SaveRegBuffer+2(pc),a1;ne restaure pas sync+resol
	bsr	ResetYamaha	;coupe le yamaha

	bsr	RestoreExcept	;remettre les anciennes bombes

	move.b	(a1)+,v_base_h.w	;restitue adresse ‚cran
	move.b	(a1)+,v_base_m.w	;et tutti quanti
	move.b	(a1)+,v_base_l.w	;
	move.b	(a1)+,v_hscroll.w	;
	move.b	(a1)+,v_linewid.w	;
	moveq	#$e,d0		;
.EH_yam	move.b	d0,yam_ctrl.w	;Remettre le yamaha comme
	move.b	(a1)+,yam_write.w	;avant
	dbf	d0,.EH_yam		;
	movem.l	(a1)+,d0-d7	;puis les couleurs
	movem.l	d0-7,v_color.w	;
	lea	MFP_base.w,a3	;
	movem.l	(a1)+,d0-d5	;Au tour du MFP
	clr.b	GPIP(a3)		;
	movep.l	d0,AER(a3)		;
	movep.l	d1,IPRA(a3)	;
	movep.l	d2,IMRA(a3)	;
	moveq	#0,d0		;
	movep.l	d0,TACR(a3)	;Coupe les timer pour restituer
	movep.l	d4,TADR(a3)	;les TxDR juste aprŠs
	ror.w	#8,d3		;
	move.b	d3,TCDCR(a3)	;Puis relance les Timers
	swap	d3		;selon la sauvegarde
	movep.w	d3,TACR(a3)	;
	move.b	d5,UCR(a3)		;
	movem.l	(a1)+,d0-d7	;Restitue maintenant les
	movem.l	d0-d7,$60.w	;vecteurs d'interruption
	movem.l	(a1)+,d0-d7	;
	movem.l	d0-d7,$100.w	;
	movem.l	(a1)+,d0-d7	;
	movem.l	d0-d7,$120.w	;
	bsr	ResetAcia		;
	IFND	NO_KBD		;
	bsr	ResetKbd		;m‚chant reset clavier
	move.b	#$08,KBD_data.w	;souris ON
	ENDC			;

	IFND	NO_SYS		;Si on peut appeler le systŠme
	move.l	#$000bffff,-(sp)	;mise … z‚ro du buffer clavier
	trap	#13		;
	andi.w	#$00f0,d0		;D'abord, annule l'‚tat
	move.w	d0,-(sp)		;shift/alt/ctrl
	move.w	#$000b,-(sp)	;
	trap	#13		;
	move.l	#$000e0001,-(sp)	;Puis mise … z‚ro du
	trap	#14		;du buffer clavier
	movea.l	d0,a0		;
	move.w	6(a0),8(a0)	;
	move.w	#34,-(sp)		;demande les vecteurs claviers
	trap	#14		;
	movea.l	d0,a0		;
	clr.b	109(a0)		;Annule touche press‚e
	lea	14(sp),sp		;
	ENDC

	move.w	#$2300,sr		;r‚autorise les ITs
	bsr	ResetShifter	;initialise le shifter
	move.w	SaveRegBuffer(pc),d0	;restitue fr‚quence+r‚solution
	bsr	ChangeResol	;

	movem.l	(sp)+,d0-a6
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     D‚tournement des exceptions                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InstallExcept
	movem.l	d0-d7/a0/a1,-(sp)	;Installation des bombes.
	lea	$8.w,a0		;
	lea	Save_except(pc),a1	;
	movem.l	(a0),d0-d7		;
	movem.l	d0-d7,(a1)		;
	lea	_2_Bombes(pc),a1	;
	moveq	#8-1,d0		;8 vecteurs
.IE_bcl	move.l	a1,(a0)+		;
	lea	10(a1),a1		;
	dbf	d0,.IE_bcl		;
	movem.l	(sp)+,d0-d7/a0/a1	;
	rts			;

RestoreExcept
	movem.l	d0-d7/a0/a1,-(sp)	;Sens inverse..
	lea	$8.w,a0		;
	lea	Save_except(pc),a1	;
	movem.l	(a1),d0-d7		;
	movem.l	d0-d7,(a0)		;
	movem.l	(sp)+,d0-d7/a0/a1	;
	rts


Save_except	dcb.l	8,0

;plan de sauvegarde:	_ERRx
;		_SRxxxx
;		_PCxxxxxxxx
;		_OFxxxxxxxx
;		_D0-7/A0-7
;Les infos sont sauv‚es … partir de $200.
_2_Bombes	move.l	#"ERR2",$200.w
	bra.s	.Plantage
.3_Bombes	move.l	#"ERR3",$200.w
	bra.s	.Plantage
.4_Bombes	move.l	#"ERR4",$200.w
	bra.s	.Plantage
.5_Bombes	move.l	#"ERR5",$200.w
	bra.s	.Plantage
.6_Bombes	move.l	#"ERR6",$200.w
	bra.s	.Plantage
.7_Bombes	move.l	#"ERR7",$200.w
	bra.s	.Plantage
.8_Bombes	move.l	#"ERR8",$200.w
	bra.s	.Plantage
.9_Bombes	move.l	#"ERR9",$200.w

.Plantage	move.w	#$2700,sr		;enlŠve les IT
	movem.l	d0-d7,$21c.w	;Sauve tous les registres
	movem.l	a0-a7,$23c.w	;
	move.l	usp,a0		;sans oublier la pile usp
	move.l	a0,$25c.w		;

	clr.l	$426.w		;D‚connecte le reset
	lea	$204.w,a0		;
	moveq	#-1,d0		;
	moveq	#-1,d1		;
	cmpi.b	#"3",$203.w	;Type d'erreur >3 ?
	bgt.s	.plant0		;Oui
	move.l	(sp)+,d0		;Non,contexte suppl‚mentaire
	move.l	(sp)+,d1		;
.plant0	move.l	d0,(a0)+		;
	move.l	d1,(a0)+		;
	move.w	#"SR",(a0)+	;message SR+valeur.w
	move.w	(sp)+,(a0)+	;
	move.w	#"PC",(a0)+	;message PC+valeur.l
	move.l	(sp)+,d0		;
	move.l	d0,(a0)+		;
	move.w	#"OF",(a0)+	;message OF+valeur.l
	IFD	start		;Si le label start existe alors
	subi.l	#start,d0		;on calcule la distance du bug
	ELSEIF			;
	move.l	$4f2.w,a1		;Sinon on calcule la distance
	move.l	40(a1),a1		;par rapport … la page de base.
	sub.l	(a1),d0		;(TOS >=1.2 uniquement!!)
	ENDC			;
	move.l	d0,(a0)+		;stocke le r‚sultat.

	lea	68(a0),a0		;on se place aprŠs les registres
	btst	#5,-6(sp)		;Exception depuis superviseur ?
	bne.s	.plant1		;
	move.l	usp,sp		;non=>La pile est utilisateur
.plant1				;Ici, rajouter par exemple
				;un dump de la pile, etc...
				;C'est vous qui voyez !

	lea	v_color0.w,a0	;Boucle sans fin
	move.w	#$2,(a0)		;
.plant2	addq.w	#4,(a0)		;C'est un pseudo colorshock
	bra.s	.plant2		;Faire reset pour quitter !..



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                   Primitives de gestion du clavier                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NE DOIVENT JAMAIS ETRE APPELEES EN INTERRUPTION !!
;(leurs temps d'‚x‚cution sont longs et variables)

ResetAcia	move.b	#$03,KBD_ctrl.w	;master reset
	move.b	#$96,KBD_ctrl.w	;interruptions autoris‚es
	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UnsetAcia	move.b	#$03,KBD_ctrl.w	;master reset
	move.b	#$16,KBD_ctrl.w	;pas d'interrutions
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ResetKbd	move.w	d0,-(sp)		;
	bsr.s	WaitKbdIn		;
	move.b	#$80,KBD_data.w	;
	bsr.s	WaitKbdIn		;SofReset=$80+$01
	move.b	#$01,KBD_data.w	;
	bra.s	FlushKbd+2		;Attend que le clavier se calme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StopKbdOut	bsr.s	WaitKbdIn		;Coupe les transferts 6301
	move.b	#$13,KBD_data.w	;$13=PauseOutput
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlushKbd	move.w	d0,-(sp)		;
	move.w	#$47ff,d0		;d‚lai ENORME !!
	tst.l	KBD_stat.w		;lire status+data -> flush
	dbf	d0,*-4		;yeah man.
	move.w	(sp)+,d0		;
	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitKbdIn				;attend que le clavier soit
	btst	#1,KBD_stat.w	;prˆt … recevoir
	beq.s	WaitKbdIn		;
	move.w	d0,-(sp)		;
	move.w	#950,d0		;boucle d'attente pour laisser
.wki_wait	bsr.s	DummyRTS		;respirer ce bon vieux clavier
	dbf	d0,.wki_wait	;
	move.w	(sp)+,d0		;
DummyRTS	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitKbdOut				;attend que le clavier envoie
	btst	#0,KBD_stat.w	;une donn‚e
	beq.s	WaitKbdOut		;
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=chaine … envoyer.
;La longueur de la chaine est dans le premier octet,
;Le mode doit ˆtre dans le 2eme octet, suivi de ses paramŠtres.
;A la suite doivent OBLIGATOIREMENT figurer une valeur de test du clavier
;et la valeur attendue en retour.
;Ne sont vraiment valables que:
;Commandes:$08,$09,$0f,$10,$12,$14,$15,$1a
;Test     :$88,$88,$8f,$8f,$92,$94,$94,$9a
;Retour   :$08,$09,$0f,$10,$12,$14,$15,$1a
;
;Par exemple, pour passer en souris absolue avec des coordonn‚es
;maxi de 319 et 199, il faut utiliser la chaine:
;$05,$09,$01,$3f,$00,$c7,$88,$09=[5 oct,mode 9,319,199,tst $88,result $09]
ChangeKbdMode
	movem.l	d0/a0-a1,-(sp)	;
	lea	KBD_data.w,a1	;
.CKM_0	movea.l	4(sp),a0		;Reprend la chaine.
	moveq	#0,d0		;
	move.b	(a0)+,d0		;La taille voulue+1 pour test
	bsr	StopKbdOut		;couper les transferts.
.CKM_1	bsr.s	WaitKbdIn		;
	move.b	(a0)+,(a1)		;octet suivant … envoyer
	dbf	d0,.CKM_1		;
	bsr.s	WaitKbdOut		;Attendre r‚ponse du clavier
	move.b	(a1),d0		;aprŠs le test
.CKM_2	cmpi.b	#$f6,d0		;D‚but d'un paquet d'‚tat ?
	bne.s	.CKM_0		;non, recommence tout
	bsr.s	WaitKbdOut		;
	move.b	(a1),d0		;
	cmp.b	(a0),d0		;Mode correctement fix‚ ?
	bne.s	.CKM_2		;Non, tentative suivante
	movem.l	(sp)+,d0/a0-a1	;
	rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         Changer la resolution de l'‚cran,en synchro avec l'ecran        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;D0=(frequence.b|r‚solution.b).w
ChangeResol
	move.w	sr,-(sp)		;Routine sortie presque
	movem.l	d0-d4/a0/a1,-(sp)	;telle quelle de la ROM
	move.w	#$2700,sr		;Elle assure un changement
	lea	MFP_base.w,a0	;parfait de r‚solution
	lea	TBDR(a0),a1	;et de fr‚quence.
	move.b	IERA(a0),d1	;La preuve ?:votre ST a-t-il
	move.b	TBCR(a0),d2	;d‚j… foir‚ les bitplans
	bclr	#0,IERA(a0)	;aprŠs un Reset ?...
	move.b	#$10,TBCR(a0)	;Bloque le timer B, et mise …
	moveq	#1,d4		;z‚ro de son entr‚e hbl.
	clr.b	TBCR(a0)		;
	move.b	#240,(a1)		;240 lignes
	move.b	#8,TBCR(a0)	;Compteur de lignes
.chres_0	cmp.b	(a1),d4		;Attend que 240-1 lignes 
	bne.s	.chres_0		;soient pass‚es.
;On ne peut sortir de cette boucle qu'… la fin d'une ligne affich‚e
;(car sortie provoqu‚e par TBDR qui passe … 1, donc qui change, donc
;fin de ligne!). De plus, attendre 239 lignes provoque donc une pause
;de plus d'une VBL, par s‚curit‚ (stabilisation aprŠs bourrage reset)

.chres_1	move.b	(a1),d4		;Valeur actuelle pour tester
	move.w	#$267,d3		;attente=$268*28=17248 cycles
.chres_2	cmp.b	(a1),d4		;8 cycles
	bne.s	.chres_1		;8
	dbf	d3,.chres_2	;12 =>28 cycles par boucle
;Sortie si pendant 17248 cycles, pas d'affichage=>33/34 lignes aprŠs le
;bas de l'‚cran =>juste avant la VBL en 50/60 Hz.

	move.b	#$10,TBCR(a0)	;Remet le Timer B … z‚ro
	move.b	d0,v_resol.w	;Maintenant, la r‚solution
	lsr.w	#8,d0		;et la synchro peuvent ˆtre
	move.b	d0,v_synch.w	;chang‚e sans risque
	move.b	d1,IERA(a0)	;
	move.b	d2,TBCR(a0)	;Restitue touskifo.
	movem.l	(sp)+,d0-d4/a0/a1	;
DummyVBL	rte			;restitue le sr empil‚ + haut
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Effectuer un Reset Shifter en sortie d'overscan              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ResetShifter
	move.w	d0,-(sp)		;Reset-shifter, pour
	move.w	d1,-(sp)		;remettre la vid‚o dans
	move.l	$70.w,-(sp)	;le droit chemin aprŠs
	move.l	#FlagVBL,$70.w	;un overscan notament
	moveq	#4,d0		;On le bourre 5 fois
	moveq	#1,d1		;on attend 2 VBL
	clr.w	Flag		;init le flag
.rs_bcl	cmp.w	Flag(pc),d1	;
	bcc.s	.rs_bcl		;
	moveq	#-1,d1		;
	move.b	#1,v_resol.w	;On bourre la vid‚o
	ror.l	d1,d1		;en passant en moyenne/basse
	clr.b	v_resol.w		;
	IFND	TT		;Si ce n'est pas un TT
	ror.l	d1,d1		;on bourre aussi la synchro
	clr.b	v_synch.w		;
	ror.l	d1,d1		;
	move.b	#2,v_synch.w	;
	ENDC			;
	move.w	Flag(pc),d1	;
	dbf	d0,.rs_bcl		;VBL suivante
	move.l	(sp)+,$70.w	;
	move.w	(sp)+,d1		;
	move.w	(sp)+,d0		;
	rts			;

FlagVBL	addq.w	#1,Flag		;indique le passage de la VBL
	rte
Flag	dc.w	0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       Reset du Yamaha                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ResetYamaha
	movem.l	d0/a0-a1,-(sp)	;Valeur par d‚faut:
	lea	yam_ctrl.w,a1	;son totallement coup‚
	lea	.yaminit+1(pc),a0	;drive ‚teint
	moveq	#14,d0		;
.yamr_0	move.b	d0,(a1)		;
	move.b	(a0)+,2(a1)	;
	dbf	d0,.yamr_0		;
	movem.l	(sp)+,d0/a0-a1	;
	rts
.yaminit
	dc.b	$00,$27,$00,$00,$00,$00,$00,$00
	dc.b	$ff,$00,$ff,$ff,$ff,$ff,$ff,$ff

SaveRegBuffer dcb.b	__ih_size_,0
