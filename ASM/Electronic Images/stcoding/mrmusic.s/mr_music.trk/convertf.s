; Convert and save a 16khz frequency table to a MR Music 64 note lookup.

	lea	tab(pc),a0
	lea	endnote(pc),a1
	lea	compare(pc),a2
	
	move.w	#1024-1,d7
	moveq	#64-1,d0
	move.l	-(a1),d1
convtab:
	cmp.l	(a0)+,d1
	ble.s	stillno
	move.l	-(a1),d1
	move.w	d0,(a2)+
	subq.w	#1,d0
	dbra	d7,convtab
	
stillno:move.w	d0,(a2)+
	dbra	d7,convtab



save:	clr.w	-(sp)
	pea	savename(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.w	#8,sp
	tst.l	d0
	bmi.s	error
	move.w	d0,handle
write:	pea	compare(pc)
	move.l	#2048,-(sp)
	move.w	handle(pc),-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.w	#12,sp
close:	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
error:


	
	clr.w	-(sp)
	trap	#1

savename:
	dc.b	'C:\CONVERT.TAB',0
	even
handle:	ds.w	1



tab:	incbin	c:\16_khz.frq

notetab:DC.W	$0,$2AB7,$0,$2D41,$0,$2FF2,$0,$32CB
	DC.W	$0,$35D1,$0,$3904,$0,$3C68,$0,$4000
	DC.W	$0,$43CE,$0,$47D6,$0,$4C1B,$0,$50A2
	DC.W	$0,$556E,$0,$5A82,$0,$5FE4,$0,$6597
	DC.W	$0,$6BA2,$0,$7208,$0,$78D0,$0,$8000
	DC.W	$0,$879C,$0,$8FAC,$0,$9837,$0,$A145
	DC.W	$0,$AADC,$0,$B504,$0,$BFC8,$0,$CB2F
	DC.W	$0,$D744,$0,$E411,$0,$F1A1,$1,$0
	DC.W	$1,$F38,$1,$1F59,$1,$306F,$1,$428A
	DC.W	$1,$55B8,$1,$6A09,$1,$7F91,$1,$965F
	DC.W	$1,$AE89,$1,$C823,$1,$E343,$2,$0
	DC.W	$2,$1E71,$2,$3EB3,$2,$60DF,$2,$8514
	DC.W	$2,$AB70,$2,$D413,$2,$FF22,$3,$2CBF
	DC.W	$3,$5D13,$3,$9047,$3,$C686,$3,$FFFF
	DC.W	$4,$3CE3,$4,$7D66,$4,$C1BF,$5,$A28
	DC.W	$5,$56E0,$5,$A827,$5,$FE44,$6,$597F
endnote:

compare:
	ds.w	1024