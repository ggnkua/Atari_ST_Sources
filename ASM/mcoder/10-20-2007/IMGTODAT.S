;
; IMG to DAT
;
load=$80000	;buffer chargement
save=$90000	;buffer sauvegarde
source=$a0000	;buffer pour le source g‚n‚r‚

	bra.s	code

file:	DC.B	"COURSE"
suffixe:dc.b	".IMG",0
	even
code:
	lea	file(pc),a0
	lea	load,a6
	bsr	readfile

	lea	load,a4
	move.l	a4,a3
	add.l	d6,a3

	lea	save,a5
	lea	source,a6

	MOVE.B	#'I',(A6)+
	MOVE.B	#'M',(A6)+
	MOVE.B	#'A',(A6)+
	MOVE.B	#'G',(A6)+
	MOVE.B	#'E',(A6)+
	lea	file(pc),a0
mot2:
	move.b	(a0)+,d0
	cmp.b	#'.',d0
	beq.s	endmot2
	move.b	d0,(a6)+
	bra.s	mot2
endmot2:
	bsr	mouline

	lea	suffixe(pc),a0
	move.b	#'.',(a0)+
	move.b	#'D',(a0)+
	move.b	#'A',(a0)+
	move.b	#'T',(a0)+
	lea	file(pc),a0
	lea	save,a4
	bsr	savefile

	lea	suffixe(pc),a0
	move.b	#'.',(a0)+
	move.b	#'S',(a0)+
	clr.b	(a0)+
	lea	file(pc),a0
	lea	source,a4
	move.l	a6,a5
	bsr	savefile
	moveq	#0,d0
	illegal
;
; entr‚e :
;	a4=d‚but load
;	a5=d‚but save
;	a6=d‚but source
;
mouline:
	move	(a4)+,d6	;X
	move	(a4)+,d7	;Y

	move.b	#9,(a6)+
	move.b	#'d',(a6)+
	move.b	#'c',(a6)+
	move.b	#'.',(a6)+
	move.b	#'l',(a6)+
	move.b	#9,(a6)+
	lea	file(pc),a0
mot:
	move.b	(a0)+,d0
	cmp.b	#'.',d0
	beq.s	endmot
	move.b	d0,(a6)+
	bra.s	mot
endmot:
	move.b	#'+',(a6)+
	move.l	a5,d0
	sub.l	#save,d0
	bsr	hexa
	move.b	#',',(a6)+
	move	d6,d0
	addq	#1,d0
	asl	#8,d0
	move.b	d7,d0
	addq.b	#1,d0
	swap	d0
	clr	d0
	bsr	hexa

	move.b	#13,(a6)+
	move.b	#10,(a6)+

	move	d7,d1
	lea	$1f8000,a1
take0:
	move	d6,d0
	add	#15,d0
	lsr	#4,d0
	subq	#1,d0
	move.l	a1,a0
take1:
	move.l	(a4),(a0)+
	move.l	(a4)+,(a5)+
	move.l	(a4),(a0)+
	move.l	(a4)+,(a5)+
	dbra	d0,take1
	lea	160(a1),a1
	dbra	d1,take0

	cmp.L	a3,a4
	blo.L	mouline
	bne	error
	rts
hexa:
	move.b	#'$',(a6)+
	moveq	#8-1,d2
not0:
	move.l	d0,d1
	and.l	#$f0000000,d1
	bne.s	digit
	rol.l	#4,d0
	dbra	d2,not0
	move.b	#'0',-1(a6)
	rts
digit:
	rol.l	#4,d0
	moveq	#$f,d1
	and	d0,d1
	cmp	#10,d1
	blo.s	low10
	addq	#7,d1
low10:
	add	#'0',d1
	move.b	d1,(a6)+
	dbra	d2,digit
	rts
;
; entr‚e : a0=nom du fichier
;	   a6=d‚but chargement
; sortie : d6=nb octets charg‚s en LOAD
;
readfile:
	clr	-(sp)
	pea	(a0)
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d7
	bmi	error

	pea	(a6)
	pea	200000
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	move.l	d0,d6

	bmi	error
	cmp.l	#65536,d6
	beq	error
	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	rts
savefile:
	clr	-(sp)
	pea	(a0)
	move	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d7
	bmi	error

	pea	(a4)
	move.l	a5,d0
	sub.l	a4,d0
	move.l	d0,-(sp)
	move	d7,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	error

	move	d7,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp
	rts

error:	illegal
