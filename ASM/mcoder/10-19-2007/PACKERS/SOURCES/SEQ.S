;
; algorithme de recherche de chaines longues dans un fichier
;
debut=$40000
fin=$40000+53078
freq=$80000
dest=$60000

	lea	freq,a0
	move	#65536*2/4-1,d0
	moveq	#0,d1
cl:	move.l	d1,(a0)+
	dbra	d0,cl

	lea	debut,a5
	lea	fin,a6
	lea	freq,a4

	moveq	#0,d0
	move.b	(a5)+,d0
cp1:
	move.b	(a5)+,d1
	cmp.b	d0,d1
	bne.s	diff
same:
	cmp.b	(a5),d0
	bne.s	diff
	addq	#1,a5
	bra.s	same
diff:
	asl	#8,d0
	move.b	d1,d0
	move.l	d0,d1
	add.l	d1,d1
	addq	#1,(a4,d1.L)
	cmp.l	a6,a5
	blo.s	cp1
;
; calcul de la plus grande fr‚quence
;
	moveq	#0,d0
	lea	freq,a0
	lea	65536*2+freq,a1
cx:
	cmp	(a0)+,d0
	bhs.s	pabst
	move	-2(a0),d0
pabst:
	cmp.l	a1,a0
	blo.s	cx
;
; essai d'allongement de la meilleure chaine trouv‚e
;
	lsr	#1,d0
;
; pour former une chaine de 3 octets trŠs r‚p‚t‚s
;  on prend toutes les chaines de longueur 2
;  ayant une occurrence >= best occurrence/2
;
	lea	dest,a2
	lea	freq,a0
	lea	65536*2+freq,a1
	moveq	#0,d1		;code
tri:
	cmp	(a0)+,d0
	bhi.s	notr
	move	d1,(a2)+
notr:
	addq	#1,d1
	bne.s	tri

	illegal
;
; il suffit de combiner les meilleures solutions...
;
; ex :
;
; GENST2.PRG donne :
;	0000
;	3C00
;	4E75
;	6100
;
; $3C0000 -> $16
; $610000 -> $37
;
code1=$61
code2=$00
code3=$00
o:
	lea	debut,a0
	lea	fin,a1
	moveq	#0,d0
count:
	cmp.l	a1,a0
	bhs.s	fini
	cmp.b	#code1,(a0)+
	bne.s	count
	cmp.b	#code2,(a0)
	bne.s	count
	cmp.b	#code3,1(a0)
	bne.s	count
	addq	#1,d0
	bra.s	count
fini:
	illegal
