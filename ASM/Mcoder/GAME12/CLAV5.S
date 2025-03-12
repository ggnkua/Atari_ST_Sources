;
; routine hyper-optimis‚e de clavier
;
; V1.0 : 25/05/89
; V1.1 : 08/08/89
; V1.2 : 02/09/89
; V1.3 : 10/09/89 addq.b #8,d0 au lieu de cmp.b #$f6,d0
;
; mieux :
;	- g‚rer compteur 8 bits pour xmouse et ymouse
;	   (gain de cycles et de m‚moire)
;	- tester si avec Midi ‡a plante
;	    si non -> enlever aciaexit
;	- enlever gestion Caps Lock
;
; gŠre :
;	- un tableau d'enfoncement de touches (TABKEY)
;	- un latch de chaque joystick (STICK0,STICK1)
;	- les coordonn‚es d'une souris (XMOUSE,YMOUSE)
;	- un changement de fr‚quence (CHMODE)
;	- les clicks de la souris (LASTCLK)
;
; si la bordure devient rouge, il y a un bug !!!!
;
veckey	equ	basemfp+$18+2

midikey:
	tst.b	$fffffc00.w
	bpl.s	bugge
	move	d0,-(sp)
	clr	d0
	move.b	$fffffc02.w,d0

	addq.b	#8,d0
	bcs.s	pakey
;
; clavier
;
	cmp.b	#$44+8,d0	;appui sur F10 ??
	beq.s	chsync
	pea	(a0)
	lea	tabkey-8\w,a0
	bclr	#7,d0
	seq	0(a0,d0.w)
	move.l	(sp)+,a0
	move	(sp)+,d0
	rte
bugge:
	addq	#7,$ffff8240.w
	bra.s	bugge
;	tst.b	$FFFFFC06.W
;	move	#$700,$FFFF8240.w	;indique bug !!!
;	rte
chsync
	eor.b	#2,chmode\w	;on changera de synchro a la prochaine trame
	move	(sp)+,d0
	rte
pakey
;
;+si $f6 (+7 octets)	etat ikbd
;+si $f7 (+5)		position absolue souris
; si $f8 (+2)		position relative souris (+aucun clic)
; si $f9 (+2)		meme chose +clic bouton droit
; si $fa (+2)		meme chose +clic bouton gauche
; si $fb (+2)		meme chose +les 2 clics
;+si $fc (+6)		date interne
;+si $fd (+2)		etat manettes
; si $fe (+1)		manette 0
; si $ff (+1)		manette 1
;
	asl.b	#4,d0
	jmp	keyf8(pc,d0.w)
keyf8
	move.b	d0,setclk\w		;d0=0
	move	#mouse1,veckey\w
	move	(sp)+,d0
	rte
	ds.b	16-(*-keyf8)	;2 octets
keyf9
	move.b	#1,setclk\w		;d0=$10
	move	#mouse1,veckey\w
	move	(sp)+,d0
	rte
	ds.b	16-(*-keyf9)
keyfa	move.b	#2,setclk\w		;d0=$20
	move	#mouse1,veckey\w
	move	(sp)+,d0
	rte
	ds.b	16-(*-keyfa)
keyfb	move.b	#3,setclk\w		;d0=$30
	move	#mouse1,veckey\w
	move	(sp)+,d0
	rte
	ds.b	16-(*-keyfb)
keyfc
	bra.s	bugge			;d0=$40
mouse1
	move.b	$FFFFFC02.w,setx\w	;gain d'octets
	move	#mouse2,veckey\w
	rte
	ds.b	16-(*-keyfc)
keyfd
	bra.s	bugge			;d0=$50
joy0
	move.b	$FFFFFC02.w,stick0\w
;
; manette: x000yyyy
; x=fire
; yyyy=position manette
;	bit 0=haut si 1
;	bit 1=bas si 1
;	bit 2=gauche si 1
;	bit 3=droite si 1
;
	move	#midikey,veckey\w
	rte
	ds.b	16-(*-keyfd)
keyfe
	move	#joy0,veckey\w
	move	(sp)+,d0
	rte
	ds.b	16-(*-keyfe)
keyff
	move	#joy1,veckey\w
	move	(sp)+,d0
	rte

joy1
	move.b	$FFFFFC02.w,stick1\w
;
; manette: x000yyyy
; x=fire
; yyyy=position manette
;	bit 0=haut si 1
;	bit 1=bas si 1
;	bit 2=gauche si 1
;	bit 3=droite si 1
;
	move	#midikey,veckey\w
	rte
mouse2
	move	d0,-(sp)
	move.b	$FFFFFC02.w,d0
	ext	d0
	add	d0,ymouse\w
setx	equ	*+3
	move	#0,d0		;code automodifiable
	ext	d0
	add	d0,xmouse\w
setclk	equ	*+3
	move.b	#0,lastclk\w	;code automodifiable
	move	(sp)+,d0
	move	#midikey,veckey\w
	rte

