	output	main.tos
main:
	move	#$2700,sr
	lea	$6200.w,a7
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	move.l	#$31415926,$426.w
	move.l	4.w,$42a.w

	move	#$8240,a0
	rept	8
	clr.l	(a0)+
	endr

	reset

	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
;
; loader crypt‚
;
track	equ	1
secteur	equ	1
nbsec	equ	40
adresse	equ	$6000

	MOVE.B	#3,$FFFFFC00.W
	MOVE.B	#$96,$FFFFFC00.W
	move.l	#$0700c000,$ffff8800.w
	MOVE.L	#$07078080,$FFFF8200.W
;	move.b	#$11,$fffffc02.w

	lea	$80000,a0
	move	#($400000-$80000)/$800-1,d0
	move.l	#'OHNO',d1
.fil	move.l	d1,(a0)
	lea	$800(a0),a0
	dbra	d0,.fil

	move	$446.w,d0
	addq	#1,d0
	add	d0,d0
	eor	#7,d0
	move.b	#$e,$ffff8800.w
	move.b	d0,$ffff8802.w
;
; 0->101
; 1->011
;
	move	#$80,$ffff8606.w
	nop
	nop
	move	#$03,$ffff8604.w
.restore:
	btst	#5,$fffffa01.w
	bne.s	.restore

      	move	#$86,$ffff8606.w
      	move	#track,$ffff8604.w
 
 	move	#$80,$ffff8606.w
 	nop
 	nop
 	move	#$17,$ffff8604.w	;seek with verify
 	
.seek:	btst	#5,$fffffa01.w
	bne.s	.seek

	moveq	#secteur,d0	;num‚ro secteur
	moveq	#nbsec-1,d1
	moveq	#adresse/256,d2
.load:
	move	#$84,$ffff8606.w
	move	d0,$ffff8604.w

	clr.b	$ffff860d.w
	move.b	d2,$ffff860b.w
	clr.b	$ffff8609.w

	move	#$90,$ffff8606.w
	move	#$190,$ffff8606.w
	move	#$90,$ffff8606.w
	move	#1,$ffff8604.w
	move	#$80,$ffff8606.w
	nop
	nop
	move	#$80,$ffff8604.w
.loadit:
	btst	#5,$fffffa01.w
	bne.s	.loadit

	addq	#1,d0
	cmp	#10,d0
	bls.s	.nostep
	move	#$80,$ffff8606.w
	moveq	#1,d0
	nop
	move	#$53,$ffff8604.w
.stepin:
	btst	#5,$fffffa01.w
	bne.s	.stepin
.nostep:
	addq.b	#2,d2
	dbra	d1,.load

	MOVE.L	#'CODE',D0
	MOVE	#$800/4-1,D1
	LEA	adresse.w,A0
CRYPTE:
	EOR.L	#$31415926,D0
	ADD.L	#$27182818,D0
	EOR.L	D0,(A0)+
	DBRA	D1,CRYPTE

	jmp	adresse.w
