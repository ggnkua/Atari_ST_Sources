;Routine de restitution 8 bits pour STF.
;(C)oderight NulloS//DNT 1992
;
;
; Pour restituer le son, il faut utiliser la mˆme fr‚quence que
;celle d'‚chantillonnage, sinon le son va ˆtre d‚form‚.
; Par exemple,si vous utilisez un son digitalis‚ a 12,5Khz, il faut
;le restituer … une fr‚quence de 12,5Khz.
; Pour tenir cette fr‚quence pr‚cise, il y a deux maniŠres de proc‚der:
;
;	o Faire une routine qui inclu une boucle d'attente de longueur
;	variable selon la fr‚quence voulue.
;	o Se servir d'un timer du MFP r‚gl‚ … 12,5Khz.
;
; On va se servir ici de la 2Šme m‚thode, … savoir la programmation du
;MFP pour utiliser un timer … 12,5Khz. Si vous avez des problŠmes avec les
;interruptions, jetez un coup d'oeil … ce source, ‡a pourra peut-ˆtre
;vous aider.
;
; Les timers du MFP ont une fr‚quence de travail de 2,4576 Mhz. Celle
;ci est divis‚e … volont‚ pour obtenir la fr‚quence que l'on d‚sire.
;Les diviseurs principaux sont d1=4,10,16,50,64,100 ou 200. Un deuxiŠme
;diviseur est disponible, et possŠde un valeur d2=1..255 La fr‚quence
;obtenue est 2457600/(d1*d2)
; Pour avoir du 12,5Khz, on utilise d1=4 et d2=49 ce qui donne du 12538Hz
;… peu prŠs. L… est la limite du MFP: on ne peut pas choisir au hertz
;prŠs.Mais comme les logiciels de digitalisation se servent aussi d'un
;timer, les fr‚quences sont les mˆmes entre digit et restitution.
;
; Si vous changez les valeurs du timer, la fr‚quence de restitution
;change, ce qui modifie la hauteur du son. Malheureusement, cela
;d‚forme le rendu (un son "naturel" comporte un ‚l‚ment appel‚
;timbre qui est invariable, alors qu'un changement de fr‚quence le
;modifie.Par exemple, quand on digitalise une voix qui chante le LA
;d'un octave, et que l'on double sa fr‚quence de restitution, on
;obtient le LA de l'octave sup‚rieur, mais le rendu est trŠs diff‚rent
;de la mˆme voix chantant vraiment un LA de l'octave sup‚rieur...Ca
;permet d'ailleurs de savoir o— et quand les voix des "chanteuses" de
;house-musique est trafiqu‚e....h‚h‚).
;
; Amusez vous bien !..
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

	bsr	Wait_Kbd		;attendre le clavier
	move.b	#$12,KBD_data.w	;couper la souris
	
	bsr	InitYamaha		;pr‚pare le yamaha pour la digit
	lea	sample,a0		;adresse de d‚but du sample
	lea	endsample,a1	;adresse de fin
	lea	bclsample,a2	;adresse de bouclage
	bsr	InstallDigit	;et lance la resitution !
	
presskey	move.l	#$000bffff,-(sp)	;demander l'‚tat shift,control 
	trap	#13		;et altenrate
	addq.l	#4,sp		;
	and.w	#7,d0		;Press‚e(s) ?
	beq.s	presskey		;non, attendre encore
	
	bsr	KillDigit		;couper la digit
	
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
;Routine de base. Elle se charge d'installer la digit dans le timer A
;(qui n'est pas utilis‚ par le systŠme, mais pour votre usage personnel
;vous pouvez aussi vous servir d'un autre, comme le TimerB pour les
;rasters).Le sample est point‚ par A0
;Je rappelle que la signification des diff‚rents bits d'interruption MFP
;sont:
;IERA/IMRA/ISRA/IPRA: 7..moniteur monochrome
;		6..sonnerie RS232
;		5..Timer A
;		4..tampon de reception plein (RS232)
;		3..erreur de reception (RS232)
;		2..tampon d'emission vide (RS232)
;		1..erreur d'‚mission (RS232)
;		0..Timer B
;
;IERB/IMRB/ISRB/IPRB: 7..interruption FDC/DMA
;		6..interruption clavier
;		5..Timer C
;		4..Timer D
;		3..interruption blitter
;		2..signal CTS (RS232)
;		1..detection de porteuse (RS232)
;		0..gestion Centronics
;Pour installer une de ces interruptions, il faut l'autoriser dans le
;bit correspondant de IERA ou IERB en le mettant … 1.Puis la d‚masquer
;avec IMRA ou IMRB (en mettant son bit … 1).A la fin de l'interruption,
;il faut mettre son bit … 0 dans le registre ISRA ou ISRB.
;Pour un timer, il faut d'abord (avant de l'autoriser) mettre son CR
;(Control Register) … 0,choisir le diviseur d2 … mettre dans TADR,TBDR
;TCDR ou TDDR (selon le timer), et mettre le diviseur d1 dans le CR
;du timer (TACR,TBCR ou TCDCR).
;On ne met pas directement d1, mais un ‚quivalent:
;	o 1 pour choisir d1=4
;	o 2 ""     ""    d1=10
;	o 3 ""     ""    d1=16
;	o 4 ""     ""    d1=50
;          o 5 ""     ""    d1=64
;	o 6 ""     ""    d1=100
;	o 7 ""     ""    d1=200
;
InstallDigit
	move.l	a0,-(sp)
	movem.l	a0-a2,TA_next	;donn‚es de la digit

	move.l	#TA_replay,V_TA.w	;installe notre routine TimerA
	lea	MFP_base.w,a0	;adresse registres MFP
	clr.b	TACR(a0)		;CR … 0
	move.b	#49,TADR(a0)	;diviseur d2=49
	move.b	#1,TACR(a0)	;diviseur d1=4
;=Fr‚quence 2457600/(4*49)=12538 Hz .Maintenant le timer est actif
	ori.b	#%00100000,IERA(a0)	;autorise le timer A
	ori.b	#%00100000,IMRA(a0)	;et d‚masque le.
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interruption Timer A qui restitue le son.C'est elle qui se charge du
;plus important: convertir les samples vers le yamaha.
TA_next	dc.l	0
TA_end	dc.l	0
TA_bcl	dc.l	0
TA_replay	movem.l	d0/a0,-(sp)	;sauve les registres
	moveq	#0,d0		;annule d0
	movea.l	TA_next(pc),a0	;adresse prochain ‚chantillon
	move.b	(a0)+,d0		;r‚cupŠre le
	cmpa.l	TA_end(pc),a0	;fin atteinte ?
	blt.s	TA_rsuite		;non
	movea.l	TA_bcl(pc),a0	;si, rentre dans la boucle

TA_rsuite	move.l	a0,TA_next		;
	lsl.w	#3,d0		;*8 pour aller dans la table
	lea	yam_ctrl.w,a0	;adresse registre yamaha
	move.l	ST_REPLAY+4(pc,d0.w),(a0) ;va chercher l'‚quivalent du
	move.l	ST_REPLAY(pc,d0.w),d0	;sample dans la table
	movep.l	d0,0(a0)		;

	move.l	(sp)+,d0		;
	move.l	(sp)+,a0		;remet les registres
	andi.b	#%11011111,ISRA+MFP_base.w ;interruption finie
	rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__SR_SIGN	equ	1
	include	STREPLAY.S
;La table est organis‚ comme suit...les 128 lignes de 8 dc.w contiennent
;chacune 2 ‚quivalent sample<=>yamaha.
;Chaque ‚quivalent est comme suit:
;dc.w    $080x,$090y,$0a0a,$0z0z
;Les registres du yamaha correspondants aux volumes 0,1 et 2 sont les
;registres No 8,9 et 10 (donc $08,$09 et $0a).
;Pour acc‚der … un registre, il faut ‚crire son num‚ro en yam_ctrl=ff8800.w
;puis ‚crire sa valeur en yam_write=$ff8802. Ces deux adresses contiennent
;un octet, donc.Mais les adresses $ff8804 et $ff8806 ont exactement les
;mˆmes r“les (dans l'ordre), ce sont en quelque sorte des images de yam_ctrl
;et yam_write (en fait, les adresses $ff8800+4*n et $ff8802+4*n sont
;toutes ‚quivalentes 2 … 2).
;Bref.Un fois charg‚ en D0 la valeur 080x090y, on fait un movep.l … l'adresse
;ffff8800. Or movep ‚crit les 4 octets du registre D0 aux adresses 0(a0),2(a0)
;4(a0) et 6(a0), donc $ff8800,$ff8802,$ff8804 et $ff8806...Donc il ‚crit
;8 en $ff8800, ce qui s‚lectionne le volume 0,puis la valeur x en $ff8802,
;donc dans le registre de volume.Ensuite 9 et y en $ff8804 et $ff8806, ce
;qui place y dans le volume 1 !!.Deux volumes ont donc ‚t‚ plac‚s.
;Il reste le troisiŠme. le move.l ST_REPLAY(pc,d0.w),(a0) place la
;valeur $0a0a0z0z en $ff8800...Les adresses $ff8801 et $ff8803 n'existent
;pas, mais la manoeuvre ne provoque pas de bombes. Donc on ‚crit 10=$a
;en $ff8800 (et $ff8801,mais cela n'a aucun effet), puis z en $ff8802 (et
;$ff8803).
;En fin de compte, nous avons plac‚ x,y et z dans les volumes 0,1 et 2
;selon la valeur de l'‚chantillon. La somme des volumes 4 bits va ainsi
;‚muler un convertisseur 8 bits, la table permettant de trouver l'‚quivalent
;8 bits=>3 fois 4 bits...
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
KillDigit	move.l	a0,-(sp)
	lea	MFP_base.w,a0	;adresse registres MFP
	clr.b	TACR(a0)		;coupe d'abord le timer A
	clr.b	TADR(a0)		;annule son diviseur
	andi.b	#%11011111,IERA(a0)	;interdit le timer A
	andi.b	#%11011111,IMRA(a0)	;masque le
	move.l	(sp)+,a0		;le timer est maintenant
	rts			;totallement enlev‚
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Wait_Kbd	btst	#1,KBD_stat.w	;clavier prŠs … recevoir ?
	beq.s	Wait_Kbd		;non, attendre
	rts			;c'est bon !
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Coupe les oscillateurs ainsi que les enveloppes du processeur sonore
;afin de pouvoir se servir du volume de chaque voix comme d'un
;convertisseur 4 bits.
;
InitYamaha
	movem.l	d0/a0-a1,-(sp)	;
	lea	yam_ctrl.w,a1	;adresse du registre yamaha
	lea	yaminit_data+1(pc),a0	;donn‚es … envoyer
	moveq	#14,d0		;15 registres
yami_0	move.b	d0,(a1)		;selectionne le registre No D0
	move.b	(a0)+,2(a1)	;donne lui la bonne valeur
	dbf	d0,yami_0		;registre suivant
	movem.l	(sp)+,d0/a0-a1	;
	rts			;
yaminit_data
	dc.b	$00,$27,$00,$00,$00,$00,$00,$00
	dc.b	$ff,$00,$ff,$ff,$ff,$ff,$ff,$ff
	
	SECTION	DATA

sample	incbin	flut_pan.spl	;sample … restituer
endsample	equ	*		;son adresse fin
bclsample	equ	sample+40962	;bouclage

	SECTION	BSS
save_SSP	ds.l	1
save_conterm
	ds.w	1