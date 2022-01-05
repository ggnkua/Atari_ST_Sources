	*------------------------------------*
	*-- Source d'exemple d'utilisation --*
	*-- de CENTinel au 680x0           --*
	*------------------------------------*


debut_du_prog
	move.l	#$1234,d0
	move.w	#$fada,d1
	nop				; visualisation de la fenetre des registres
	move.w	#$1000,d7	
	moveq	#0,d0			; utilisation de la fonction trace
copie
	addq.l	#1,d0
	dbra	d7,copie		; utilisation du ctrl a
	
	move.w	#3,d7			; puis du changement de direction de la fleche
	bne.s	plus_loin		; ainsi que de la couleur de l'adresse d'arriv‚e
	nop				; et du forcement du brachement
plus_loin
	bsr	calcule			; trace d'un bsr
	bra	suite	
calcule
	move.w	#5,d0			; routine classique
	move.w	#3,d1
	add.w	d0,d1
	rts
	
suite
	bsr	calcule	 		; utilisation d'un ctrl a dur un bsr
	bsr	calcule	 
	
	rept	10			; pose d'un bkpt au 68030
	bsr	plus_un			; interet du trac‚ source
	endr
	
	bra.s	saute
plus_un
	addq.w	#1,d1			; la routine simple
	rts
	
	
	*--------------------------------------*
	*--- ‚viter un plantage de CENTinel ---*
	*--------------------------------------*
	
	
saute	
	nop				; ctrl r
	nop
	nop	
	tst.b	$ffff8240.w
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1			; nom de la fonction
	addq.l	#6,sp
	
	move.l	$24.w,d7		; plantage si on ne d‚cale pas le vbr
	move.l	#TRACE,$24.w		; decalage du vbr ca marche
	move.l	d7,$24.w		
		
	move.l	d0,-(sp)		; on peut le replacer
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	moveq	#0,d0
	clr.l	d1			; ctrl r
boucle
	addq.l	#1,d1			; on arrete avec shift alt help
	bra.s	boucle			; puis, on skip
	and.w	#$ff,d1
	nop
	
	*--------------------------------------------*
	*--- usage des breaks point param‚triques ---*
	*--------------------------------------------*
	
ajoute
	addq.w	#1,d0
	add.w	d0,d1			; poser un bkpt param‚tique avec condition
	cmp.w	#9000,d1		; (d0==\100)&(i0=i0+1)
	ble.s	ajoute
	
	
	*---------------------------------------*
	*--- ici c'est un peu plus complique ---*
	*--- on va chercher s'il existe x tq ---*
	*--- xð3 mod 7    <=> x=3+7k         ---*
	*--- xð5 mod 11   <=> x=5+11k'       ---*
	*---------------------------------------*


	clr.l	d0			; on efface d0 qui vaut x
	move.w	#-100,d0		; on commence la recherche a partir de -100
debut
	clr.l	d1
	clr.l	d2
	move.w	d0,d1
	move.w	d0,d2
	sub.l	#3,d2			; on calcule x-3
	sub.l	#5,d1			; on calcule x-5
	ext.l	d2			; extention des signes pour le n‚gatif
	ext.l	d1	

	*-------------------------------------------*
	*--- premiere boucle                     ---*
	*--- on a x, on cherche k tel que x-3=7k ---*
	*-------------------------------------------*

	move.w	#$8000,d3		; on met -32768 dans d3 qui est k
encore
	move.w	d3,d4	
	muls.w	#7,d4			; on multiplie par 7
	cmp.l	d4,d2			; est ce egal … x-3
	beq.s	oui			; oui, on va verifier le seconde equation
	addq.w	#1,d3			; sinon on aincremente la valeur de k
	cmp.w	#$7fff,d3
	bne.s	encore
	bra.s	non
oui

	*----------------------------------------------*
	*--- deuxieme boucle                        ---*
	*--- on a deja k, on cherche k'             ---*
	*--- tel que x (toujours le meme) =11k'+5   ---*
	*--- si on le trouve c'est que le x est bon ---*
	*----------------------------------------------*
	

	move.w	#$8000,d3		; on met -32768 dans d3 qui vaut k'
encore_1
	move.w	d3,d4			
	muls.w	#11,d4			; on multiplie par 11
	cmp.l	d4,d1			; est ce egal … x-5
	beq.s	ok			; oui => gagn‚
	addq.w	#1,d3			; sinon on ajoute 1 a k'
	cmp.w	#$7fff,d3		; c'est la fin?
	bne.s	encore_1
non
	addq.w	#1,d0			; dans x ajoute un
	cmp.w	#$7fff,d0		; x est il arriv‚ a 32767 
	bne.s	debut			; non, on recommence
	
	*--- le syteme n'a pas de solution ---*
	
	illegal

ok	
	*--- le x est bon ---*
	
	illegal













	
	
	
TRACE	bra.s	TRACE	