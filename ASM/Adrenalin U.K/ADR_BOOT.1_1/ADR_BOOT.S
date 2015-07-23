	text
begin
	bra.s	l0000
	dc.b	$90,'IBM  ',$b8,'%'
	dc.b	$96,0,2,2,1,0,2,'p'
	dc.b	0,'@',6,$f9,3,0,$a,0
	dc.b	2,0,0,0
l0000	bra.s	start
	dc.b	'<<< ADRENALIN U.K. VIRUS FREE BOOTBLOCK '
	dc.b	'Version 1.1 written by MOOKIE (C) 2/1/93'
	dc.b	' >>>'
start	move.w	#7,$ffff8240.w
	move.w	#$ffff,$ffff825e.w
	pea	intro(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7
	move.l	$426.w,d0
	cmp.l	#$31415926,d0
	beq	alert
	movea.l	$42a.w,a0
	movea.l	a0,a4
	lea	16(a0),a0
	move.l	(a0)+,d0
	cmp.l	#$12123456,d0
	beq	alert
	adda.l	#$14,a4
	move.l	(a4),d0
	cmp.l	#$12123456,d0
	beq	alert
	move.l	$472.w,d0
	move.l	$4f2.w,d1
	movea.l	d0,a0
	cmpi.l	#$6072606a,(a0)
	beq.s	safe
	cmp.l	d1,d0
	bls.s	alert
safe	pea	no_virus(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7
	move.l	#$54120,d1
delay	subq.l	#1,d1
	bne.s	delay
	rts

alert	move.w	#$700,$ffff8240.l
	pea	virus(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7
	bra	alert
	dc.b	'Nu'
intro	dc.b	27,'c0',27,'b/',27,'F',27,'Y!*THE BRITISH ALLIANCE',27,'Y,-ADRE'
	dc.b	'NALIN U.K.',0
no_virus	dc.b	27,'c0',27,'b/',27,'F',27,'Y.(YOU ARE FREE OF VIRUSES'
virus	dc.b	27,'c0',27,'b/',27,'F',27,'Y.*<<< VIRUS FOUND >>>',27,'Y0$** SW'
	dc.b	'ITCH OFF ST AND RE-LOAD **',0
	dc.b	'T.B.A. g'
	dc.b	'reetings'
	dc.b	' to: CID'
	dc.b	', Insani'
	dc.b	'ty, Out '
	dc.b	'of Order'
	dc.b	', Syncro'
	dc.b	' Systems'
	dc.b	', The Le'
	dc.b	'mmings a'
	dc.b	'nd Wild!'
	dc.b	3,$e0
zuend	end
