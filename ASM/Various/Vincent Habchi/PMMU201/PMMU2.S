*	PMMU patch 2. (Freeware, of course !)
*	This utility converts 32 bit 030 address into 24 bit
*	68000 like address.
*	Written : Monday, November 11th (French Memorial Day)
*	by Vincent Habchi (Elendir@inf.enst.fr).

*	Celui-ci marche, n'est ce pas Oya ?

pmmu
	pea.l	patch
	move.w	#$26,-(sp)		Supexec.
	trap	#14
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1			Et c'est fini.
	
*

patch
	lea.l	table,a0		Adresse de la table.
	movea.w	#$700,a1
	moveq.l	#31,d0			Compteur.
.tabl
	move.l	(a0)+,(a1)+		Copie la nouvelle table.
	dbra.w	d0,.tabl
*
	lea.l	newcrp,a0		Met … jour le CRP.
	pmove.d	(a0),crp
	addq.w	#8,a0
	pmove.l	(a0),tc			Et le TC.
	addq.w	#4,a0			D‚sactive les TTn.
	pmove.l	(a0),tt0
	pmove.l	(a0),tt1
*
	pflusha
	rts				Et fin.

table	dc.l	$00000001,$00100001,$00200001,$00300001
	dc.l	$00400001,$00500001,$00600001,$00700001
	dc.l	$00800001,$00900001,$00a00001,$00b00001
	dc.l	$00c00001,$00d00001,$00e00001,$00000742
	dc.l	$00f00001,$00f10001,$00f20001,$00f30001
	dc.l	$00f40001,$00f50001,$00f60001,$00f70001
	dc.l	$00f80001,$00f90001,$00fa0001,$00fb0001
	dc.l	$00e00001,$00e10001,$00e20001,$00ff0041

newcrp	dc.l	$00100002,$00000700
	dc.l	$80c84440
	dc.l	$00000000
	
*	Assemblied with Devpack 2.23
*	(P) 11/91.