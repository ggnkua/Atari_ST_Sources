	OPT O+,W-

***********	Condition pour generer un fichier targa
*	sinon c'est un bitmap TrueColor Falcon
__Targa
	IFD __Targa
	OUTPUT	e:\code\synthy.art\curent\fichiers.inl\targa.inl
	ELSE
	OUTPUT	e:\code\synthy.art\curent\fichiers.inl\falcon.inl
	ENDC
	
***********	Convertion de 3 images 320x200 R,V,B vers le format Targa

	move.l	4(sp),a0	* Image "rouge" (32000 octets)
	move.l	8(sp),a1	* Image "verte" (32000 octets)
	move.l	12(sp),a2	* Image "bleu"  (32000 octets)
	move.l	16(sp),a3	* Image destination (128018 octets)
	
***********	Initialisation du Header Targa: 320x200 RGB 15 bits uncompressed
	IFD __Targa
	clr.w	(a3)+
	move.w	#$200,(a3)+		* RGB uncompressed image
	clr.l	(a3)+
	clr.l	(a3)+
	move.l	#$4001c800,(a3)+	* 320x200
	move.w	#$1020,(a3)+	* 16 bits, top-down
	ENDC			* no interlace

***********	Boucle principale
*         codage pixel:	GGgBBBBb|xRRRRrGG (pour targa)
*		RRRRrGGG|GgxBBBBb (Pour Falcon030 TrueColor)

	move.w	#3999,d7
MainLoop	movem.w	(a0)+,d0-d3		* on commence par le rouge
	move.l	a3,a4
	REPT 16
	moveq	#0,d4
	IFD __Targa
	add.w	d3,d3
	addx.w	d4,d4
	add.w	d2,d2
	addx.w	d4,d4
	add.w	d1,d1
	addx.w	d4,d4
	add.w	d0,d0
	addx.w	d4,d4
	lsl.w	#3,d4
	ELSE
	add.w	d0,d0
	roxr.w	#1,d4
	add.w	d1,d1
	roxr.w	#1,d4
	add.w	d2,d2
	roxr.w	#1,d4
	add.w	d3,d3
	roxr.w	#1,d4
	ENDC	
	move.w	d4,(a4)+
	ENDR

	movem.w	(a2)+,d0-d3		* puis le bleu
	IFD __Targa
Offset	SET	0
	ELSE
Offset	SET	1
	ENDC
	REPT 16
	moveq	#0,d4
	add.w	d3,d3
	addx.w	d4,d4
	add.w	d2,d2
	addx.w	d4,d4
	add.w	d1,d1
	addx.w	d4,d4
	add.w	d0,d0
	addx.w	d4,d4
	add.w	d4,d4
	move.b	d4,Offset(a3)
Offset	SET	Offset+2
	ENDR

	movem.w	(a1)+,d0-d3		* et enfin le vert
	REPT 16
	moveq	#0,d4
	add.w	d3,d3
	addx.w	d4,d4
	add.w	d2,d2
	addx.w	d4,d4
	add.w	d1,d1
	addx.w	d4,d4
	add.w	d0,d0
	addx.w	d4,d4
	IFD __Targa
	ror.w	#2,d4
	ELSE
	lsl.w	#7,d4
	ENDC
	or.w	d4,(a3)+
	ENDR

	dbf	d7,MainLoop
	rts

			