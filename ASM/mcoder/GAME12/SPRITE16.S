	opt	o+
;
; routine de sprite
;
; V 1.0 : 7/05/89
; V 1.1 : 17/05/89
; V 1.2 : 30/05/89
; V 2.0 : 26/09/89 avec masques pr‚calcul‚s
; V 2.1 : 03/10/89 d‚bugg‚ et am‚lior‚
; V 2.2 : 09/10/89 am‚lioration 0 d‚calage
;
largeur= 5	;=nb de plans (*8=nb octets de large) (*16=nb pixels)
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a0=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
; registres utilis‚s
;
shift	equr	d0
const	equr	d1
mask	equr	d2
plan1	equr	d3
plan2	equr	d4
rmask	equr	d5
reste1	equr	d6
reste2	equr	d7
;
;graph	equr	a0	;d‚but des sprites
;ecran	equr	a1	;adresse ‚cran
;incecr	equr	a2	;incr‚ment pour ‚cran
;incspr	equr	a3	;incr‚ment pour sprite
nbplan	equr	a4
savlig	equr	a5
regan	equr	a6

	bra.w	sprite0
	bra.w	sprite1
	bra.w	sprite2
	bra.w	sprite3
	bra.w	sprite4
	bra.w	sprite5
	bra.w	sprite6
	bra.w	sprite7
	bra.w	sprite8
	bra.w	sprite9
	bra.w	sprite10
	bra.w	sprite11
	bra.w	sprite12
	bra.w	sprite13
	bra.w	sprite14
	bra.w	sprite15

	bra.w	gsprite0
	bra.w	gsprite1
	bra.w	gsprite2
	bra.w	gsprite3
	bra.w	gsprite4
	bra.w	gsprite5
	bra.w	gsprite6
	bra.w	gsprite7
	bra.w	gsprite8
	bra.w	gsprite9
	bra.w	gsprite10
	bra.w	gsprite11
	bra.w	gsprite12
	bra.w	gsprite13
	bra.w	gsprite14
	bra.w	gsprite15

	bra.w	dsprite0
	bra.w	dsprite1
	bra.w	dsprite2
	bra.w	dsprite3
	bra.w	dsprite4
	bra.w	dsprite5
	bra.w	dsprite6
	bra.w	dsprite7
	bra.w	dsprite8
	bra.w	dsprite9
	bra.w	dsprite10
	bra.w	dsprite11
	bra.w	dsprite12
	bra.w	dsprite13
	bra.w	dsprite14
	bra.w	dsprite15

sprite1		move.l	#$80008000,const
		moveq	#1,shift
		bra	sprit
gsprite1	move.l	#$80008000,const
		moveq	#1,shift
		bra	gsprit
dsprite1	move.l	#$80008000,const
		moveq	#1,shift
		bra	dsprit

sprite2		move.l	#$C000C000,const
		moveq	#2,shift
		bra	sprit
gsprite2	move.l	#$C000C000,const
		moveq	#2,shift
		bra	gsprit
dsprite2	move.l	#$C000C000,const
		moveq	#2,shift
		bra	dsprit

sprite3		move.l	#$E000E000,const
		moveq	#3,shift
		bra	sprit
gsprite3	move.l	#$E000E000,const
		moveq	#3,shift
		bra	gsprit
dsprite3	move.l	#$E000E000,const
		moveq	#3,shift
		bra	dsprit

sprite4		move.l	#$F000F000,const
		moveq	#4,shift
		bra	sprit
gsprite4	move.l	#$F000F000,const
		moveq	#4,shift
		bra	gsprit
dsprite4	move.l	#$F000F000,const
		moveq	#4,shift
		bra	dsprit

sprite5		move.l	#$F800F800,const
		moveq	#5,shift
		bra	sprit
gsprite5	move.l	#$F800F800,const
		moveq	#5,shift
		bra	gsprit
dsprite5	move.l	#$F800F800,const
		moveq	#5,shift
		bra	dsprit

sprite6		move.l	#$FC00FC00,const
		moveq	#6,shift
		bra	sprit
gsprite6	move.l	#$FC00FC00,const
		moveq	#6,shift
		bra	gsprit
dsprite6	move.l	#$FC00FC00,const
		moveq	#6,shift
		bra	dsprit

sprite7		move.l	#$FE00FE00,const
		moveq	#7,shift
		bra	sprit
gsprite7	move.l	#$FE00FE00,const
		moveq	#7,shift
		bra	gsprit
dsprite7	move.l	#$FE00FE00,const
		moveq	#7,shift
		bra	dsprit

sprite8		move.l	#$FF00FF00,const
		moveq	#8,shift
		bra	sprit
gsprite8	move.l	#$FF00FF00,const
		moveq	#8,shift
		bra	gsprit
dsprite8	move.l	#$FF00FF00,const
		moveq	#8,shift
		bra	dsprit

sprite9		move.l	#$FF80FF80,const
		moveq	#16-9,shift
		bra	sprit8
gsprite9	move.l	#$FF80FF80,const
		moveq	#16-9,shift
		bra	gsprit8
dsprite9	move.l	#$FF80FF80,const
		moveq	#16-9,shift
		bra	dsprit8

sprite10	move.l	#$FFC0FFC0,const
		moveq	#16-10,shift
		bra	sprit8
gsprite10	move.l	#$FFC0FFC0,const
		moveq	#16-10,shift
		bra	gsprit8
dsprite10	move.l	#$FFC0FFC0,const
		moveq	#16-10,shift
		bra	dsprit8

sprite11	move.l	#$FFE0FFE0,const
		moveq	#16-11,shift
		bra	sprit8
gsprite11	move.l	#$FFE0FFE0,const
		moveq	#16-11,shift
		bra	gsprit8
dsprite11	move.l	#$FFE0FFE0,const
		moveq	#16-11,shift
		bra	dsprit8

sprite12	move.l	#$FFF0FFF0,const
		moveq	#16-12,shift
		bra	sprit8
gsprite12	move.l	#$FFF0FFF0,const
		moveq	#16-12,shift
		bra	gsprit8
dsprite12	move.l	#$FFF0FFF0,const
		moveq	#16-12,shift
		bra	dsprit8

sprite13	move.l	#$FFF8FFF8,const
		moveq	#16-13,shift
		bra	sprit8
gsprite13	move.l	#$FFF8FFF8,const
		moveq	#16-13,shift
		bra	gsprit8
dsprite13	move.l	#$FFF8FFF8,const
		moveq	#16-13,shift
		bra	dsprit8

sprite14	move.l	#$FFFCFFFC,const
		moveq	#16-14,shift
		bra	sprit8
gsprite14	move.l	#$FFFCFFFC,const
		moveq	#16-14,shift
		bra	gsprit8
dsprite14	move.l	#$FFFCFFFC,const
		moveq	#16-14,shift
		bra	dsprit8

sprite15	move.l	#$FFFEFFFE,const
		moveq	#16-15,shift
		bra	sprit8
gsprite15	move.l	#$FFFEFFFE,const
		moveq	#16-15,shift
		bra	gsprit8
dsprite15	move.l	#$FFFEFFFE,const
		moveq	#16-15,shift
		bra	dsprit8
;
; cas du sprite avec 0 d‚calage
;
sprite0
gsprite0
dsprite0
gdsprite0
	neg	d3
	addq	#largeur,d3
;	mulu	#14,d3
	mulu	#18,d3
	lea	spr0(pc,d3.w),nbplan
sprite00
	jmp	(nbplan)
spr0
;	rept	largeur
;	movem.l	(a0)+,rmask/reste1/reste2
;	and.l	rmask,(a1)
;	or.l	reste1,(a1)+
;	and.l	(a1),rmask
;	or.l	rmask,reste2
;	move.l	reste2,(a1)+
;	endr
	rept	largeur
;	move.l	(a0)+,reste2
;	move.l	(a1)+,reste1
;	and.l	reste2,reste1
	move.l	(a0)+,reste1
	move.l	reste1,reste2
	and.l	(a1)+,reste1
	or.l	(a0)+,reste1
	and.l	(a1)+,reste2
	or.l	(a0)+,reste2
	movem.l	reste1/reste2,-8(a1)
	endr

	add	a3,a0
	add	a2,a1
	dbra	d4,sprite00
	rts

sprit
	neg	d3
	addq	#largeur,d3

	mulu	#48,d3
	lea	spr2(pc,d3.w),nbplan
spr1
	move	d4,savlig

	movem.l	(a0)+,mask/plan1/plan2

	ror.l	shift,mask
	ror.l	shift,plan1
	ror.l	shift,plan2

	move.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1

	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2

	or.l	const,mask
	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	jmp	(nbplan)
spr2
	rept	largeur-1
	movem.l	(a0)+,mask/plan1/plan2
	swap	reste1
	swap	reste2
	ror.l	shift,mask
	ror.l	shift,plan1
	ror.l	shift,plan2
	eor.l	rmask,mask
	eor.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask
	eor.l	reste1,plan1
	eor.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1
	eor.l	reste2,plan2
	eor.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2
	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+
	endr
	not.l	rmask
	and.l	const,rmask
	beq.s	spr3
	not.l	rmask
	swap	reste1
	swap	reste2
	and.l	rmask,(a1)
	or.l	reste1,(a1)
	and.l	4(a1),rmask
	or.l	rmask,reste2
	move.l	reste2,4(a1)
spr3
	add	a3,a0
	add	a2,a1
	move	savlig,d4
	dbeq	d4,spr1
	rts

gsprit
	neg	d3
	addq	#largeur-1,d3
	mulu	#48,d3
	lea	spr5(pc,d3.w),nbplan
spr4
	move	d4,savlig

	movem.l	-12(a0),rmask/reste1/reste2
	ror.l	shift,rmask
	ror.l	shift,reste1
	ror.l	shift,reste2
	and.l	const,rmask
	and.l	const,reste1
	and.l	const,reste2

	jmp	(nbplan)
spr5
	rept	largeur-1
	movem.l	(a0)+,mask/plan1/plan2
	swap	reste1
	swap	reste2
	ror.l	shift,mask
	ror.l	shift,plan1
	ror.l	shift,plan2
	eor.l	rmask,mask
	eor.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	eor.l	reste1,plan1
	eor.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1

	eor.l	reste2,plan2
	eor.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2

	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+
	endr

	not.l	rmask
	and.l	const,rmask
	beq.s	spr6
	not.l	rmask
	swap	reste1
	swap	reste2
	and.l	rmask,(a1)
	or.l	reste1,(a1)
	and.l	4(a1),rmask
	or.l	rmask,reste2
	move.l	reste2,4(a1)
spr6
	add	a3,a0
	add	a2,a1
	move	savlig,d4
	dbeq	d4,spr4
	rts

dsprit
	neg	d3
	addq	#largeur,d3

	mulu	#48,d3
	lea	spr8(pc,d3.w),nbplan
spr7
	move	d4,savlig

	movem.l	(a0)+,mask/plan1/plan2

	ror.l	shift,mask
	ror.l	shift,plan1
	ror.l	shift,plan2
	move.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1

	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2

	or.l	const,mask
	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	jmp	(nbplan)
spr8
	rept	largeur-1

	movem.l	(a0)+,mask/plan1/plan2
	swap	reste1
	swap	reste2
	ror.l	shift,mask
	ror.l	shift,plan1
	ror.l	shift,plan2
	eor.l	rmask,mask
	eor.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask
	eor.l	reste1,plan1
	eor.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1

	eor.l	reste2,plan2
	eor.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2

	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	endr

	add	a3,a0
	add	a2,a1
	move	savlig,d4
	dbeq	d4,spr7
	rts

sprit8
	neg	d3
	addq	#largeur,d3

	mulu	#52,d3
	lea	spr10(pc,d3.w),nbplan
spr9
	move	d4,savlig

	movem.l	(a0)+,mask/plan1/plan2

	rol.l	shift,mask
	rol.l	shift,plan1
	rol.l	shift,plan2
	move.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1

	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2

	swap	plan1
	swap	plan2

	or.l	const,mask
	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	jmp	(nbplan)
spr10
;
; reste est … l'endroit
; plan est … swapper
;
	rept	largeur-1

	movem.l	(a0)+,mask/plan1/plan2

	rol.l	shift,mask
	rol.l	shift,plan1
	rol.l	shift,plan2

	eor.l	rmask,mask
	eor.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	reste1,regan
	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1
	swap	plan1
	add.l	regan,plan1

	move.l	reste2,regan
	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2
	swap	plan2
	add.l	regan,plan2

	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	endr

	not.l	rmask
	and.l	const,rmask
	beq.s	spr11
	not.l	rmask
	and.l	rmask,(a1)
	or.l	reste1,(a1)
	and.l	4(a1),rmask
	or.l	rmask,reste2
	move.l	reste2,4(a1)
spr11
	add	a3,a0
	add	a2,a1
	move	savlig,d4
	dbeq	d4,spr9
	rts

gsprit8
	neg	d3
	addq	#largeur-1,d3
	mulu	#52,d3
	lea	spr13(pc,d3.w),nbplan
spr12	move	d4,savlig

	movem.l	-12(a0),rmask/reste1/reste2
	rol.l	shift,rmask
	rol.l	shift,reste1
	rol.l	shift,reste2
	and.l	const,rmask
	and.l	const,reste1
	and.l	const,reste2

	jmp	(nbplan)
spr13
	rept	largeur-1

	movem.l	(a0)+,mask/plan1/plan2

	rol.l	shift,mask
	rol.l	shift,plan1
	rol.l	shift,plan2

	eor.l	rmask,mask
	eor.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	reste1,regan
	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1
	swap	plan1
	add.l	regan,plan1

	move.l	reste2,regan
	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2
	swap	plan2
	add.l	regan,plan2

	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	endr

	not.l	rmask
	and.l	const,rmask
	beq.s	spr14
	not.l	rmask
	and.l	rmask,(a1)
	or.l	reste1,(a1)
	and.l	4(a1),rmask
	or.l	rmask,reste2
	move.l	reste2,4(a1)
spr14
	add	a3,a0
	add	a2,a1
	move	savlig,d4
	dbeq	d4,spr12
	rts

dsprit8
	neg	d3
	addq	#largeur,d3

	mulu	#52,d3
	lea	spr16(pc,d3.w),nbplan
spr15
	move	d4,savlig

	movem.l	(a0)+,mask/plan1/plan2

	rol.l	shift,mask
	rol.l	shift,plan1
	rol.l	shift,plan2

	move.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1

	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2

	swap	plan1
	swap	plan2
	or.l	const,mask
	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	jmp	(nbplan)
spr16
	rept	largeur-1
	movem.l	(a0)+,mask/plan1/plan2

	rol.l	shift,mask
	rol.l	shift,plan1
	rol.l	shift,plan2

	eor.l	rmask,mask
	eor.l	mask,rmask
	and.l	const,rmask
	eor.l	rmask,mask

	move.l	reste1,regan
	move.l	plan1,reste1
	and.l	const,reste1
	eor.l	reste1,plan1
	swap	plan1
	add.l	regan,plan1

	move.l	reste2,regan
	move.l	plan2,reste2
	and.l	const,reste2
	eor.l	reste2,plan2
	swap	plan2
	add.l	regan,plan2

	and.l	mask,(a1)
	or.l	plan1,(a1)+
	and.l	(a1),mask
	or.l	mask,plan2
	move.l	plan2,(a1)+

	endr

	add	a3,a0
	add	a2,a1
	move	savlig,d4
	dbeq	d4,spr15
	rts
