/*
	routine de d‚compactage de fichier .TNY

	Format de .TNY :

	offset		signification

	  0		R‚solution (0=basse,1=moyenne,2=haute)

	$01		Palette
	$21		(32 octets pour les 16 couleurs)

	$23		Nb octets du premier segment
	$24

	$25		Nb octets du deuxieme segment /2
	$26

	$27		D‚but du premier segment

	$27+($23-$24)	D‚but du deuxieme segment et fin du premier segment

	$27+($23-$24)+($25-$26)*2=fin du deuxieme segment

*/

long source,destin;
tiny(tiny1,tiny2)
long tiny1,tiny2;
{
	source=tiny1;
	destin=tiny2;
#asm

;
; ROUTINE DE DECOMPACTAGE DE FICHIERS .TNY
;
;
;
; Registres utilis‚s :
;
; D0=offset pointeur ‚cran (varie de 0 … 32000)
; D1=octet lu dans le premier segment
;
; A2=pointe sur le premier segment
; A3=pointe sur l'‚cran (ne varie pas)
; A4=pointe sur le deuxieme segment
; A5=pointe sur la fin du premier segment
;

	movem.l	d0-d1/a2-a5,-(sp)

	move.l	_source,a4	;pointe sur le premier octet charg‚
	lea	33(a4),a4	;saute la r‚solution et les palettes (33 octets)

	move.b	(a4)+,d0	;nb octets du premier segment
	asl	#8,d0
	move.b	(a4)+,d0

	addq	#2,a4		;2 octets donnant la longueur
				;du deuxieme segment /2 (inutilis‚)
	move.l	a4,a2		;pointe sur le premier segment
	add	d0,a4		;pointe sur le deuxieme segment
	moveq	#0,d0		;offset ‚cran=0
	move.l	_destin,a3	;pointe sur l'‚cran … afficher
	move.l	a4,a5		;debut deuxieme segment=fin premier segment
	bra.s	lbl77
lbl84:
	move.b	(a2)+,d1
	ext.w	d1
	cmp.b	#2,d1
	bhs.s	lbl72

	move.b	(a2)+,d1
	asl	#8,d1
	move.b	(a2)+,d1
	tst.b	-3(a2)
	beq.s	lbl72
	neg	d1

lbl72:	tst	d1
	bpl.s	lbl79
	neg	d1
	bra.s	lbl80
lbl82:
	move.b	(a4)+,0(a3,d0.w)
	move.b	(a4)+,1(a3,d0.w)
	add	#160,d0
	cmp	#$7D00,d0
	blo.s	lbl80
	sub	#$7D00-8,d0
	cmp	#160,d0
	blo.s	lbl80
	sub	#160-2,d0
lbl80:	dbra	d1,lbl82
	bra.s	lbl77

lbl83:
	move.b	(a4),0(a3,d0.w)
	move.b	1(a4),1(a3,d0.w)
	add	#160,d0
	cmp	#$7D00,d0
	blo.s	lbl79
	sub	#$7D00-8,d0
	cmp	#160,d0
	blo.s	lbl79
	sub	#160-2,d0
lbl79:	dbra	d1,lbl83
	addq	#2,a4
lbl77:	cmp.l	a5,a2
	blo.s	lbl84
	movem.l	(sp)+,d0-d1/a2-a5

#endasm
}
