debpref=$50000
finpref=debpref+$2746
debdata=$60000
findata=debdata+$939b
nb=34			;nb m‚thodes de compression
;
; 2Šme passe pour le programme
;
; 1) calcule les nb octets les plus fr‚quents dans DATA
;
	lea	debdata,a0
	lea	findata,a1
	lea	freq(pc),a2
calf:
	moveq	#0,d0
	move.b	(a0)+,d0
	add	d0,d0
	addq	#1,(a2,d0.w)
	cmp.l	a1,a0
	blo.s	calf
;
; prend les nb fr‚quences les plus utilis‚es
;
	lea	freq1(pc),a0
	lea	finfreq1(pc),a1
count:
	moveq	#0,d0		;best resultat
	lea	freq(pc),a2
	move	#256-1,d1
co2:
	cmp	(a2)+,d0
	bhs.s	co3
	lea	-2(a2),a3
	move	(a3),d0
co3:
	dbra	d1,co2

	tst	d0
	beq	bug

	clr	(a3)
	move.l	a3,d0
	sub.l	#freq,d0
	lsr	#1,d0
	move.b	d0,(a0)+
	cmp.l	a1,a0
	blo.s	count
;
; 2) calcule la fr‚quence des nb m‚thodes
;
	lea	freq(pc),a0
	move	#nb-1,d0
cl2:	move	#1,(a0)+	;au moins 1 pour setup
	dbra	d0,cl2		;efface FREQ

	lea	debpref,a0
	lea	finpref,a1
	lea	freq(pc),a2
col1:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp	#nb,d0
	bhs	bug
	add	d0,d0
	addq	#1,(a2,d0.w)
	cmp.l	a1,a0
	blo.s	col1

	lea	freq2(pc),a0
	lea	finfreq2(pc),a1
collect:
	lea	freq(pc),a2
	moveq	#0,d0
	move	#nb-1,d1
coll2:
	cmp	(a2)+,d0
	bhs.s	coll3
	lea	-2(a2),a3
	move	(a3),d0
coll3:
	dbra	d1,coll2
	tst	d0
	beq	bug

	clr	(a3)
	move.l	a3,d0
	sub.l	#freq,d0
	lsr	#1,d0
	move.b	d0,(a0)+
	cmp.l	a1,a0
	blo.s	collect
;
; 3) assigne un code … chaque m‚thode
;
	lea	freq1(pc),a0
	lea	freq2(pc),a1
	lea	finfreq2(pc),a3
	lea	freq3(pc),a2
assign:
	moveq	#0,d0
	move.b	(a1)+,d0	;code pr‚fix
	move.b	(a0)+,(a2,d0.w)
	cmp.l	a3,a1
	blo.s	assign
;
; 4) modifie tous les codes du PREFIX
;
	lea	debpref,a0
	lea	finpref,a1
	lea	freq3(pc),a2
modify:
	moveq	#0,d0
	move.b	(a0),d0
	cmp	#nb,d0
	bhs	bug
	move.b	(a2,d0.w),(a0)+
	cmp.l	a1,a0
	blo.s	modify
;
; 5) g‚nŠre un fichier contenant DATA et PREFIX m‚lang‚
;
; 6) fin de la 2Šme passe
bug:
	illegal

freq:	blk.w	256,0
freq1:	blk.b	nb
finfreq1:
freq2:	blk.b	nb
finfreq2:
freq3:	blk.b	nb
finfreq3:
	even
