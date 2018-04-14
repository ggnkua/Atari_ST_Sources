*	OUTPUT e:\code\synthy.art\curent\fichiers.inl\packtiny.inl
	OPT O+,A+,P+
***********	Compactage Tiny
* 4(sp)  L  Adresse de l'image
* 8(sp)  L  Adresse du buffer CONTROL (3-10667 octets)
* 12(sp) L  Adresse PAIRE du buffer DATA (1-16000 MOTS)
* En retour dans D0: Taille DATA en octets dans mot poids fort
*	         Taille CONTROL en octets dans mot de poids faible

PackTINY	move.l	4(sp),a0
	move.l	12(sp),a1
	move.w	#15999,d0
	lea	32000.w,a2
	lea	160.w,a3
	sub.l	a4,a4
ConvertLoop	move.w	(a0,a4.w),(a1)+
	add.l	a3,a4
	cmp.w	a2,a4
	blt.s	.ConvSkip
	lea	-32000+8(a4),a4
	cmp.w	a3,a4
	blt.s	.ConvSkip
	lea	-158(a4),a4
.ConvSkip	dbf	d0,ConvertLoop
	move.l	12(sp),a0		Ptr SOURCE
	move.l	8(sp),a1		Ptr CONTROL
	move.l	a0,a2		Ptr DATA
	lea	32000(a0),a3	Adr fin SOURCE
	moveq	#4,d7

	move.l	a0,a4		Start adr
NewCode	move.w	(a0)+,d0
	cmp.l	a0,a3
	beq.s	CodeCOPY
SameLoop	cmp.w	(a0)+,d0
	bne.s	NotSame
	cmp.l	a0,a3
	bne.s	SameLoop
	bra.s	CodeREPEAT
	dc.b	"TINYPACK by Nucleus/HMD"
	EVEN
NotSame	move.l	a0,d1
	sub.l	a4,d1
	cmp.w	d7,d1
	bne.s	CodeREPEAT1
	cmp.l	a0,a3
	beq.s	CodeCOPY
	move.w	-2(a0),d0
NotSameLoop	move.w	(a0)+,d1
	cmp.w	d0,d1
	beq.s	CodeCOPY1
	move.w	d1,d0
	cmp.l	a0,a3
	bne.s	NotSameLoop
	bra.s	CodeCOPY

CodeCOPY1	sub.l	d7,a0
CodeCOPY	move.l	a0,d1
	sub.l	a4,d1
	lsr.w	#1,d1
	cmp.w	#127,d1
	ble.s	.Less127
	move.b	#1,(a1)+
	movep	d1,0(a1)
	move.b	d1,1(a1)
	addq.l	#2,a1
	dbf	d1,.copy
.Less127	move.b	d1,(a1)
	neg.b	(a1)+
	subq.w	#1,d1
.copy	move.w	(a4)+,(a2)+
	dbf	d1,.copy
	cmp.l	a0,a3
	bne.s	NewCode
	bra.s	EndOfPict
CodeREPEAT1	subq.l	#2,a0
CodeREPEAT	move.l	a0,d1
	sub.l	a4,d1
	lsr.w	#1,d1
	cmp.w	#127,d1
	ble.s	.Less127
	clr.b	(a1)+
	movep	d1,0(a1)
	move.b	d1,1(a1)
	addq.l	#2,a1
	bra.s	.REPEATEnd
.Less127	move.b	d1,(a1)+
.REPEATEnd	move.w	d0,(a2)+
	move.l	a0,a4		Start adr
	cmp.l	a0,a3
	bne	NewCode

EndOfPict	move.l	a1,d1
	sub.l	8(sp),d1		Taille CONTROL
	move.l	a2,d0
	sub.l	12(sp),d0		Taille DATA
	swap	d0
	move.w	d1,d0
	rts		
