	*****************************************
	*Sample replay routines                 *
	*Plays samples on interrupt at 5 Khz    *
	*Use initsam to initialise routine      *
	*Then use playsam with parameters       *
	*a0=start of sample, d0=length of sample*
	*****************************************

playsam	move.b	#0,$fffffa07.w	Stop sample
	move.l	a0,samdata	Address of sample
	move.w	d0,sampos		Size of sample
	or.b	#$20,$fffffa07.w	Play sample
	rts			Return

sample	movem.l	a0/d0-d1,-(sp)	Preserve registers
	move.l	samdata,a0	Address of sample data
	move.w	sampos,d1		Sample position
	clr.w	d0		Clear d0
	move.b	(a0,d1),d0	Get sample data
	tst.w	volume		Half volume?
	bne	halfvol		Yes, goto routine
	add.w	d0,d0		Multiply by 2
halfvolr	move.l	sound(pc,d0),d1	Get sound data	
	move.w	sound+4(pc,d0),d0	Get sound data
	lea	$ffff8800.w,a0	Address of sound chip
	movep.l	d1,(a0)		Send to sound chip
	movep.w	d0,(a0)		Send to sound chip
	movem.l	(sp)+,a0/d0-d1	Restore registers
	sub.w	#1,sampos		Move up sample position
	bmi.s	samend		End of sample yet?
sample2	rte			Return
samend	move.b	#0,$fffffa07.w	Disable interrupts
	rte			Return

halfvol	and.w	#$fff8,d0		Play sample at half volume
	bra	halfvolr		Return

sound	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0
	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0
	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0
	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0

initsam	move.b	#2,$484		Disable key click
	move.b	#0,$FFFF8800.W	Init register 0
	move.b	#0,$FFFF8802.W
	move.b	#1,$FFFF8800.W	Init register 1
	move.b	#0,$FFFF8802.W
	move.b	#2,$FFFF8800.W	Init register 2
	move.b	#0,$FFFF8802.W
	move.b	#3,$FFFF8800.W	Init register 3
	move.b	#0,$FFFF8802.W
	move.b	#4,$FFFF8800.W	Init register 4
	move.b	#0,$FFFF8802.W
	move.b	#5,$FFFF8800.W	Init register 5
	move.b	#0,$FFFF8802.W
	move.b	#7,$FFFF8800.W	Init register 7
	move.b	#$FF,$FFFF8802.W
	move.b	#8,$FFFF8800.W	Init register 8
	move.b	#0,$FFFF8802.W
	move.b	#9,$FFFF8800.W	Init register 9
	move.b	#0,$FFFF8802.W
	move.b	#10,$FFFF8800.W	Init register 10
	move.b	#0,$FFFF8802.W
	move.b	#0,$fffffa07.w	Initialise mfp registers
	move.b	#0,$fffffa19.w
	move.b	#120,$fffffa1f.w
	move.b	#1,$fffffa19.w
	bclr	#3,$fffffa17.w
	move.l	#sample,$134.w
	move.l	#sample2,$60.w
	or.b	#$20,$fffffa13.w
	rts			Return

sampos	dc.l	0		Position in sample
samdata	dc.l	0		Start of sample
volume	dc.w	0		Volume of sample