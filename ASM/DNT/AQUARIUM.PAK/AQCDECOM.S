;Exemple d'utilisation de la routine de decompression
; d'A(quarium)crunchy 	

	move.w	#0,-(sp)	;basse resolution
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.l	#debut,a0	;adresse image compressee
	move.l	#dest,a1	;adresse image decompressee
	bsr	decompress	;on decompresse
	move.w	#2,-(sp)	;ou est l'ecran ?
	trap	#14
	addq.l	#2,sp
	move.l	d0,a1		;en (a1).
	move.l	#dest,a0	;On y met l'image
	move.l	#(32000/4)-1,d0
eff	move.l	(a0)+,(a1)+
	dbf	d0,eff	
	move.w	#7,-(sp)	;Attend touche clavier
	trap	#1
	addq.l	#2,sp
	move.w	#1,-(sp)	;moyenne reso
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#dest,a0
	clr.l	-(sp)
	trap	#1

	include 'decompv3.s'		;le code (magique ?)
	
	data
debut	incbin 'claudia.aqc'		;une belle image
	
	bss
	ds.b 32000
dest:	ds.b 32000
