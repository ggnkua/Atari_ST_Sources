;
; 3Šme m‚thode : calcul des fr‚quences
;
; 1) bytes
;
debut:	equ	$20000
fin:	equ	debut+224094
datas:	equ	$57000

	lea	debut,a0
	lea	fin,a1
	lea	datas,a6
	move.l	a6,a5
	moveq	#-1,d0
	moveq	#0,d1
clrk:	move	d1,(a5)+
	dbra	d0,clrk

rept:	moveq	#0,d0
	move.b	(a0)+,d0
	add	d0,d0
	addq	#1,0(a6,d0.L)
	cmp.l	a1,a0
	blo.s	rept
	illegal

