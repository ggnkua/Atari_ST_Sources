*---------------------------------------------------------------------*
* EXTRAIT DE LA BIBLIOTHêQUE
* FICHIER "RS_RLOAD.S"
* Version 2.00
*---------------------------------------------------------------------*
* Routine pour reloger une ressource incorporÇe dans le programme.
* La version de base est en GFA (cf. ST MAG numÇro 46)
* Le fichier ressource doit Çtre incbin Ö l'adresse RSRC_FILE
* En A6 on a l'adresse du ressource (RSRC_ADDR)
	text
RSRC_RLOAD:
	LEA		RSRC_FILE,A6
	MOVE.L	A6,D5
		
* On passe en revue tous les objets
	MOVEQ	#0,D0
	MOVE.W	18(A6),D0	offset des TREES
	MOVE.W	22(A6),D1	nbr de TREES
	MOVE.L	#4,D2		Çcart entre pointeurs de TREES
	BSR		RSRC_RADDR		

;	cmp		#$4,(a6)
;	bne		rsrc_suite

;yop	clr.l	d0
;	move.w	17*2(a6),d0
;	add.w	#2,d0
;	add.l	d0,a6
;	move.l	(a6),d1		; index dans d1
;	sub.l	d0,a6

;	MOVEQ	#0,D0
;	MOVE.W	d1,D0		CICONBLK
;	MOVE.W	24(A6),D1
;	MOVE.L	#28,D2
;	BSR		RSRC_RADDR		

rsrc_suite
	MOVEQ	#0,D0
	MOVE.W	4(A6),D0	Te_ptexts
	MOVE.W	24(A6),D1
	MOVE.L	#28,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	4(A6),D0	Te_ptmplts
	ADDQ.L	#4,D0
	MOVE.W	24(A6),D1
	MOVE.L	#28,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	4(A6),D0	Te_pvalids
	ADDQ.L	#8,D0
	MOVE.W	24(A6),D1
	MOVE.L	#28,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	6(A6),D0	Ib_pmasks
	MOVE.W	26(A6),D1
	MOVE.L	#34,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	6(A6),D0	Ib_pdatas
	ADDQ.L	#4,D0
	MOVE.W	26(A6),D1
	MOVE.L	#34,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	6(A6),D0	Ib_ptexts
	ADDQ.L	#8,D0
	MOVE.W	26(A6),D1
	MOVE.L	#34,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	8(A6),D0	Bi_pdatas
	MOVE.W	28(A6),D1
	MOVE.L	#14,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	10(A6),D0	Free_strings
	MOVE.W	30(A6),D1
	MOVE.L	#4,D2
	BSR		RSRC_RADDR		

	MOVEQ	#0,D0
	MOVE.W	16(A6),D0	Free_images
	MOVE.W	32(A6),D1
	MOVE.L	#4,D2
	BSR		RSRC_RADDR		

* Nous allons maintenant reloger les OBJ_SPEC, avec Çventuellement
* convertion des coordonnÇes avec RSRC_OBFIX
	MOVEQ	#0,D0
	MOVE.W	2(A6),D0	offset pour premier objet
	MOVE.L	A6,A4
	ADDA.L	D0,A4		ptr sur premier objet
	MOVE.W	20(A6),D4	nombre d' objets
	SUBQ.W	#1,D4		car DBF
RSRC_RLOAD2
	MOVE.B	7(A4),D0	prÇlÇve type de l'objet sans extended.	
	CMP.B	#20,D0		G_box ?
	BEQ.S	.ICI
	CMP.B	#25,D0		G_ibox ?
	BEQ.S	.ICI
	CMP.B	#27,D0		G_boxchar ?
	BEQ.S	.ICI
* On reloge dans Obj_spec. On a ÇvitÇ G_box, Ibox et Boxchar car
* pour ces 3 types d'objets, il n'y a pas d'adresse Ö reloger
* en obj_spec.
	ADD.L	D5,12(A4)	ajoute RSRC_DELTA Ö l'offset
.ICI
	rsrc_obfix	A4,#0	
	ADDA.L	#24,A4		passe Ö l'objet suivant
	DBF	D4,RSRC_RLOAD2	tant qu'il en reste
		
* Initialisation du tableau GLOBAL pour l'AES
RSRC_RLOAD1
	MOVE.L	A6,D1
	MOVEQ	#0,D0
	MOVE.W	18(A6),D0		offset des TREES
	ADD.L	D1,D0
	MOVE.L	D0,global+10	adr start de TREES
	MOVE.L	D1,global+14	adr ressource
	MOVE.W	34(A6),D0		prend taille RSC
	BCLR	#15,D0			efface l'Çventuelle marque de relocation
	MOVE.W	D0,global+18
	BSET	#15,D0			marque que le fichier est relogÇ
	MOVE.W	D0,34(A6)		et stocke cette marque + la taille RSC
	MOVE.L	A6,D0			adr du RSC
	MOVE.L	D0,12(A6)		stockÇ dans lui-mÇme
	RTS
*---------------------------------------------------------------------*
* Recoit en D1 le nombre d'objets, en D0 l'offset et en D2 l'Çcart
* entre 2 objets.
RSRC_RADDR:
	TST.W	D1				il y a des objets ?
	BEQ.S	RSRC_RADDR_END	non donc bye bye
	SUBQ.W	#1,D1			-1 car DBF
	MOVE.L	A6,A4			transfert adr RSC
	ADDA.L	D0,A4			ptr sur premier objet
.ICI	ADD.L	D5,(A4)		corrige avec RSRC_DELTA		
	ADDA.L	D2,A4			passe Ö l'objet suivant
	DBF	D1,.ICI				tant qu'il en reste
RSRC_RADDR_END
	RTS
*---------------------------------------------------------------------*
