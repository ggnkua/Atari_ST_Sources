
	opt d+
	
	SECTION TEXT
	
main:

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	lea	palette(pc),a0
	lea	$ff8240,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move.l	$44e,a6

	clr.l	d2
	move.l	#100,d0
	
	bsr	save_ints
	
	bsr	set_ints
	
bouge:
	addq.l	#1,d2
	dbne	d0,bouge	
	
	bsr	waitkey
	
	bsr	old_ints
	
	clr.l	-(sp)
	trap	#1

; Ecriture du bloc gisant a l'adresse Bbase ,de dimensions Lx, Ly
; aux coordonnees x y.
; Lx est donne par pas de 4 pixels 
; x est donne par pas de 2 pixels
; on suppose A6=Physbase, il ne sera pas change.
; registres utilises : d4, d5, d6, d7, a4, a5, a6

	
	
	
printbloc:

	;controle du timer B	=interdit
	;clr.b	$fffa1b
	
	;donn‚es du timer B
	;lea		$fffa21,a0
	;move.b	#179,(a0)
	
	;masque d'interruptions B	=%1000 reautoriser lvl 4
	;move.b	#$08,-6(a0)


	move.w	#32,d7		hauteur du bloc		| 
	lea		Bbase,a5	@ du debut du bloc	| 
	move.w	d2,d5		ordonne du bloc		|  
	move.w	d5,d4		|			| 
	lsl.l		#7,d5		|			| initialisations
	lsl.l		#5,d4		| d5=160*y		| 
	add.l		d4,d5		| 			|  
	add.l		x,d5		d5=160*y+x		|  
	move.l	a6,a4		a4=physbase		|
	adda.l	d5,a4		a4=postion du bloc	
b1	
	REPT 8	
	move.l	(a5)+,(a4)+
	ENDR
	add.l	#$80,a4		changement de ligne
	dbf	d7,b1
			;	le bloc est affiche...
	rts
		
new_42:
	jmp	0.L

waitkey: 
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


set_ints:

	;masque d'interruptions A	=	niveau 1 autoris‚
	andi.b	#$fe,$fffa13
	;fe=%1111 1110
	
	;interruptions en cours de service 		(RUN QUEUE)
	andi.b	#$fe,$fffa0f
	
	;interruptions en attente de service	(READY QUEUE)
	andi.b	#$fe,$fffa0b
	
	;validation des interruptions A
	andi.b	#$fe,$fffa07

	move.l	old_4,new_42+2
	
	;inter lvl 4 	= scroll
	move.l	#printbloc,$70

	;id le clavier	
	move.l	old_key,newkey2+2
	
	;inter clavier
	move.l	#newkey,$118
	
	;validation inter A
	ori.b		#1,$fffa07

	rts

save_ints:

	move.l	$118,old_key
	move.l	$70,old_4
	lea		$fffa00,a0
	move.b	7(a0),mfp+7
	move.b	9(a0),mfp+9
	move.b	11(a0),mfp+11
	move.b	13(a0),mfp+13
	move.b	15(a0),mfp+15
	move.b	17(a0),mfp+17
	move.b	19(a0),mfp+19
	move.b	21(a0),mfp+21
	move.b	27(a0),mfp+27
	move.b	33(a0),mfp+33
	
	rts
	


old_ints:

	move.l	old_key,$118
	move.l	old_4,$70
	lea		$fffa00,a0
	move.b	mfp+7,7(a0)
	move.b	mfp+9,9(a0)
	move.b	mfp+11,11(a0)
	move.b	mfp+13,13(a0)
	move.b	mfp+15,15(a0)
	move.b	mfp+17,17(a0)
	move.b	mfp+19,19(a0)
	move.b	mfp+21,21(a0)
	move.b	mfp+27,27(a0)
	move.b	mfp+33,33(a0)
	
	rts

	;c'est pour le clavier
newkey:
	move.w	#$2300,sr
newkey2:
	jmp	$00000000


	SECTION DATA
	even	
Bbase:
	incbin	A:NULS.nul
	even
palette:
	incbin	a:nuls.pal

x	dc.w	0

	SECTION BSS
	
	even
	
old_key:
	ds.l	1

old_4:
	ds.l	1

mfp:
	ds.b	34
	
end_prg:
	END