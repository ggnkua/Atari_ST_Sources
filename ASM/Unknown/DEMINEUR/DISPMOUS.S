;
; pack de routines de gestion souris
;
;
; geremouse : retour d0=x,d1=y,d2=‚tat

ecran:	ds.l	1

decimal
	moveq	#0,d1
	move	d2,d1
	divu	#100,d1
	move	d1,d0
	add	#$30,d0
	bsr	putc
	clr	d1
	swap	d1
	divu	#10,d1
	add.l	#$300030,d1
	move	d1,d0
	bsr	putc
	swap	d1
	move	d1,d0
	bra	putc

putspace
	moveq	#0,d0
putc:	sub.b	#$20,d0
	bls.s	putsp
	cmp	#$7f-$20,d0
	blo.s	nospace
putsp	moveq	#0,d0
nospace
	pea	(a1)
	asl	#3,d0
	lea	ascii(pc),a1
	add	d0,a1			;a1=pointe sur les octets … afficher
x	set	0
	rept	8
	move.b	(a1)+,d0
	move.b	d0,x(a0)
	move.b	d0,x+2(a0)
	move.b	d0,x+4(a0)
	move.b	d0,x+6(a0)
x	set	x+160
	endr
	move.l	(sp)+,a1
	addq	#1,a0
	move	a0,d0
	lsr	#1,d0
	bcs.s	plotrts2
	addq	#6,a0
plotrts2
	rts

fadeout:
	movem.l	black_palette.w,d0-d7
	movem.l	d0-d7,real_palette.w
	movem.l	d0-d7,real_palette2.w
	st	fade_palette.w
	st	fade_palette2.w
	rts

;-------- routine de fondu des palette du fond --------;
;
; entr‚e :
;	a1=palette … obtenir
;	a0=palette courante
;
fond:
	moveq	#16-1,d7
fondu:
	moveq	#0,d6
.f2:
	move	(a1)+,d0
	move	(a0),d3

	move	d0,d1
	moveq	#$7,d2
	and.w	d0,d2
	and.w	#$700,d0
	and.w	#$070,d1

	move	d3,d4
	moveq	#$7,d5
	and.w	d3,d5
	and.w	#$700,d3
	and.w	#$070,d4

	cmp.w	d3,d0
	beq.s	.g
	bhi.s	.rm
	sub.w	#$100,d3
	bra.s	.g1
.rm:
	add.w	#$100,d3
.g1
	moveq	#-1,d6
.g:
	cmp.w	d4,d1
	beq.s	.b1
	bhi.s	.gm
	sub.w	#$10,d4
	bra.s	.gm2
.gm:	add.w	#$10,d4
.gm2	moveq	#-1,d6
.b1:
	cmp.w	d5,d2
	beq.s	.rgb
	bhi.s	.bm
	subq.w	#$1,d5
	bra.s	.bm2
.bm:	addq.w	#$1,d5
.bm2	moveq	#-1,d6
.rgb:
	or.w	d5,d3
	or.w	d4,d3
	move	d3,(a0)+
	dbra	d7,.f2
	rts

	;--- flipping screen ---;

fls:
	eor.l	#oldf1^oldf2,oldfl_a.w

	move.l	screen_addr.w,d0
	move.l	d0,d1
	eor.l	#screen_flip1^screen_flip2,d0
	move.l	d0,screen_addr.w
	lsr	#8,d1
	move.l	d1,$ffff8200.w
	rts

prgvbl:
	clr.b	$fffffa1b.w
	move.l	#hbl,basemfp+$20.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#176,$fffffa21.w
	move.b	#8,$fffffa1b.w
vbl:
	movem.l	d0-d7/a0-a6,-(sp)
;
; fade
;
	move	fade(pc),d0
	beq.s	.nofondu

	move	tint(pc),d1
	tst	d0
	bmi.s	.fadein
	eor	#7,d1
.fadein
	move.l	ptrpal(pc),a0
	lea	palette(pc),a1
	moveq	#16-1,d0
.loop
	move	(a0)+,d2

	moveq	#$7,d3
	and	d2,d3

FADE	MACRO
	sub	d1,\1
	bhs.s	.\@
	clr	\1
.\@
	ENDM

	FADE	D3
	lsr	#4,d2
	moveq	#$7,d4
	and	d2,d4
	FADE	D4
	lsr	#4,d2
	and	#$7,d2
	FADE	D2
	asl	#4,d2
	add	d4,d2
	asl	#4,d2
	add	d3,d2

	move	d2,(a1)+

	dbra	d0,.loop

	add	#65536/4,countfade	;toutes les 2 VBL
	bcc.s	.nofondu
	addq	#1,tint
	cmp	#8,tint
	blo.s	.nofondu
	clr	fade
	clr	tint
	clr	countfade

.nofondu:
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	movem.l	(sp)+,d0-d7/a0-a6
	rte
