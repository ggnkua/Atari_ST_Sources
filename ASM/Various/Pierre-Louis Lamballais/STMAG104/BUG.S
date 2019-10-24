* Extrait du TOS d'un FALCON 030
* montrant le bug de la fonction Fwrite
* avec handle … -3.
* Pierre-Louis LAMBALLAIS pour PARX
* ST MAG num‚ro 104

	link	a6,#0
	move.l	d7,-(a7)
	move.w	8(a6),d7	pr‚l‚ve le handle
	moveq	#-3,d0		charge pour comparaison
	cmp.w	d0,d7		compare handle et valeur limite
* ERREUR! Le test BLE (Branch Lower or Equal) va d‚clencher
* le saut si D7 est inf‚rieur ou ‚gal … D0. Il aurait
* fallut charger D0 avec -4 ou bien faire BLT c'est … 
* dire Branch if Lower Than (saut si inf‚rieur).
	ble.s	$E19CBA
	movea.l	$6EE4,a0
	cmp.w	$3A(a0),d7
	blt.s	$E19CBE
E19CBA	moveq	#0,d0		valeur de retour
	bra.s	$E19CE0		et bye bye...
	tst.w	d7
	bpl.s	$E19CD0
	move.l	d7,d0
	addq.w	#3,d0
	add.w	d0,d0
	ori.w	#1,d0
	ext.l	d0
	bra.s	$E19CE0
	movea.l	$6EE4,a1
	movea.l	$3C(a1),a1
	lea	0(a1,d7.w*4),a0
	move.l	(a0),d0
E19CE0	move.l	(a7)+,d7
	unlk	a6
	rts
