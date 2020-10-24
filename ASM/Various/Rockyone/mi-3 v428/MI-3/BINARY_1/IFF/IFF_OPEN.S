;rockyone			POUR MI-3			19/07/2016
;Correction palette						26/02/2017
;Suppresion de tests pour fichiers de Invision			21/10/2017
;NEO 2.24 'CMPA' adresse pair ou impair				30/10/2017
;Modifier destination pour r‚duire la taille du buffer		12.07.2018
;Retrait test du byte 29 "mask" 
;pour charger les fichier IFF de ZZ-LAZY PAINT			03.10.2019
;
;Pour les images.iff Neo Master, return dans d0 l'offset        20.10.2020
;qui pointe sur la taille des data raster. normalement 6800	
;Attention, cette adresse peut etre impair
;
;			OPEN IFF compress‚ ou non compress‚
;NEO 2.24 et 2.28
;Positive_image
;Invision
;IFF avec raster
;
;		
;destination:   32034 bytes pour fichier non compress‚
;		Si le fichier est compress‚, il est reformater en PC1-3
;		dans le buffer Source.
; 					 a0/a1		a1
;			CALL IFF_Open( L Source, L destination )
;			---------------------------------------
;
; Return dans	destination le fichier au format DEGAS  32034 octets
;
;			
; Return dans 	Low d0    -2 erreur entete fichier ou taille image
;			 Offset taille raster si 'RAST' 
;
;+ 0	L	FORM
;+ 4	L	Longueur de donn‚e restante. NEO 2.24, ne compte pas ici
;		(file size-8)                la taille de la palette
;+ 8	L	ILBM
;+12	L	BMHD
;+16	L	$14
;+20	W	Largeur image
;+22	W	Hauteur image
;+24	W	X offset
;+26	W	Y offset
;+28	B	Nombre de plan
;+29	B	mask : toujours 0 ?, non, ‚gal 2 pour zz-lazy paint 
;+30	B	Flag compression 0 no, 1 pakbits, 2 rle vertical
;+31	B	Inutilis‚ 0
;+32	W	Couleur transparante
;+34	B	X aspet  5=640*200, 10=320*200/640*400, 20=320*400
;+34	B       		1 pic invision.prg
;+35	B	Y aspec  $11	1 pic invision.prg	
;+36	W	Largeur image	0 pic ivision .prg
;+38	W	Hauteur image	0 pic invision.prg
;+40	L	CMAP
;+44	L	Nombre de valeur RVB ( couleur * 3)
;+48 	B	Valeur RVB....
;	L	ANNO
;+	L       Longueur du blok 
;+	L	BODY
;+	L	Longueur du block image
;-------------------------------------------------------------------------	
;a0 source
;a1 destination
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
	
		moveq.l	#-2,d0			;R. erreur entete
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3

		cmpi.l	#'FORM',(a0)+		;+0 'FORM '
		bne	error
		movea.l	a0,a5
		adda.l	(a0),a5			; end source

		cmpi.l	#$fa60,(a0)+		;Positive Image resol 1 ?
		bne.s	ok_plan
		move.b	#2,20(a0)		;+28 , 2 plans ! pas  4	 !
	

ok_plan:	cmpi.l	#'ILBM',(A0)+		;+8
		bne	error			
		cmpi.l	#'BMHD',(A0)+		;+12
		bne	error			
		cmpi.l	#$14,(A0)+		;+16
		bne	error			
		move.w	(a0)+,d2		;+20 Largeur image
*		cmp.w	14(a0),d2		;+36
*		bne	error
		move.w	(a0)+,d3		;+22 Hauteur image
*		cmp.w	14(a0),d3		;+38
*		bne	error
		mulu.w	d2,d3
		tst.l	(a0)+			;+24 
		bne 	error
	
		moveq.l	#0,d2
		move.b	(a0)+,d2		;+28 Nombre de plan

		cmpi.b	#4,d2			; >4 ? 
		bhi	error

*		tst.b	(a0)+			;+29 Mask. Test suprim‚ 
*		bne 	error			;pour zz-lazy paint 03.10.19
		addq.l	#1,a0			;Jump byte 29 

		move.l	d2,d4			; largeur hauteur nb plan
		lsr.l	#1,d4			;   4, 2, 1, / 2, 1, 0
		lsl.l	d4,d3			; 
		cmpi.l	#256000,d3		; * par d2 is not good 
		bne	error
;........................................resolution image ................
		move.l	d2,d7		        ;     4  2  1
		subi.w	#5,d7			;    -1 -3 -4
		neg.w	d7			;     1  3  4
		lsr.b	#1,d7			;     0  1  2
;.........................................................................
		moveq.l	#-4,d0			;R. bad file

		move.b	(a0)+,d1		;+30  byte packed
		cmpi.b	#2,d1			; Rle vertical ?
		beq	error			; non trait‚ !

		mulu.w	#$80,d1			; pour d‚pactage par	
;						; Pc_Open
* 		moveq.l	#3,d4
*loop2:
*		tst.b	(a0)+			;+31,32,33,34,35
*		bne.s 	error
*		dbra.w 	d4,loop2

		lea.l	9(a0),a0		; +40  'CMAP'

;........................................save au format Degas............	
;
		tst.b	d1
		beq.s	not_pack
		move.l	60(sp),a1	; but = source if packed
		
not_pack:	move.b	d1,(a1)+	; byte pack 0 ou $80 format DEGAS
		move.b	d7,(a1)+	; resol	format DEGAS


;					; A1 = adresse pour palette
		lea.l	32(a1),a2	; A2 = adresse pour data

		bsr 	pal		;Neo 2.28 palette avant data
;					;Neo 2.24 palette aprŠs data
find_body	bsr	read_bytes
		cmpi.l	#'BODY',d6
		beq.s	ok_body
		subq.l	#3,a0
		cmpa.l	a0,a5
		bhi.s	find_body			
		bra.s	error

ok_body:	bsr.s	read_bytes	; d6 = Taille des data image

		tst.b	d1		; source compress‚ ?
		beq.s	no_packed	; non

;........................................fichier compress‚...............
copy:		move.b	(a0)+,(a2)+
		subq.w	#1,d6
		bhi.s	copy		>0
		bra.s	end_pic

;.......................................image non compress‚..............
no_packed:	moveq.l	#0,d1
		cmpi.l	#32000,d6
		beq.s	all_pic

		cmpi.l	#64000,d6	; Moyenne resol Positive Image
		bne.s	error		;           and Invision.prg

		move.w	#160,d1		; les ligne sont doubl‚ !!!

all_pic:	lea.l	param(pc),a3
		move.w	d7,d3		; resol image
		mulu.w	#6,d3
		adda.w	d3,a3
		move.w	(a3)+,d3	; Nombre de ligne
		move.w	(a3)+,d4	; Ecart entre deux word d'un plan

ligne:		movea.l	a2,a4		; D‚but d'un plan de ligne
		move.w	d2,d6		; Nombre de plan

plan:		move.w	(a3),d5		; Nombre de word par plan

word:		move.b	(a0)+,(a4)
		move.b	(a0)+,1(a4)
		adda.w	d4,a4
		dbra.w	d5,word		; Word suivant

		lea.l -158(a4),a4	
		subq.b	#1,d6
		bhi.s	plan		; prochain plan d'une ligne

		lea.l	160(a2),a2
		adda.w	d1,a0		; Moyenne resol: ligne doubl‚ dans
;					; fichier de Positive Image et
;					; Invision

		dbra.w	d3,ligne	; Ligne suivante

;........................................end_prg....................

end_pic:	moveq.l	#0,d0		;R error if negativ
		bsr.s	pal		; Palette aprŠs data image ??

		bsr.s	read_bytes
		cmpi.l	#'RAST',d6
		bne.s	end_prg

		bsr.s	read_bytes
		cmpi.l	#6800,d6
		bne.s	end_prg

		move.l	a0,d0
		subq.l	#4,d0
		sub.l	60(sp),d0	;R. offset to size data raster
end_prg:	
error:		movem.l	(a7)+,d1-d7/a0-a6
		rts
;-------------------------------------------------------------------------
read_bytes:	moveq.l	#0,d6
		add.b	(a0)+,d6
		lsl.l	#8,d6
		add.b	(a0)+,d6
		lsl.l	#8,d6
		add.b	(a0)+,d6
		lsl.l	#8,d6
		add.b	(a0)+,d6
		rts

;........................................palette de couleur RVB | HARD....
;
; NEO 2.24 :  l'adresse de 'CMAP' peut ‚tre impair.
;--------------------------------------------------

pal:		bsr.s	read_bytes
		cmpi.l	#'CMAP',d6
		bne.s	no_pal		; palette d‚j… transf‚r‚

		bsr.s	read_bytes	; Nombre d'octets de couleur

		lea.l	vdi_0(pc),a3
		moveq.l	#0,d3
color:		moveq.l	#0,d4
		moveq.l	#2,d5
rvb:		move.b	(a0)+,d3	; read values R, V, B
		lsr.b	#4,d3
		lsl.w	#4,d4
		add.b	0(a3,d3.w),d4
		dbra.w	d5,rvb

		move.w	d4,(a1)+	; Save color
		subq.b	#3,d6
		bhi.s	color		
		rts
no_pal:		subq.l	#4,a0
		rts
;.........................................................................

	even
;		nb_ligne, offset_word, nb_word ....  3 r‚solutions
param:	dc.w	199,8,19,199,4,39,199,2,79
	
;                0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
vdi_0:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
	

	end
;-------------------------------------------------------------------------