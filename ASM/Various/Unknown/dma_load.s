* Dma loader v.3, mega fast version! *

	pea	0
	move	#$20,-(a7)
	trap	#1
	addq.w	#6,a7

	move	#0,-(a7)
	pea	$78000
	pea	$78000
	move	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	pea	text(pc)
	move	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move	#$777,$ffff825e.w

	move.b	$fffff8209.w,mfp
	move.b	$fffffa15.w,mfp+1
	move.b	$fffffa11.w,mfp+2
	move.l	$11c.w,safe_irq
	
	bsr	dma_init

lp:	tst.w	ready_flg
	beq.s	lp

	move	#$404,$ffff8240.w
	move	#$666,$ffff8246.w

	move.b	mfp(pc),$ffff8209.w
	move.b	mfp+1(pc),$fffffa15.w
	move.b	mfp+2(pc),$fffffa11.w
	move.l	safe_irq,$11c.w

	illegal

mfp:		ds.w	3
safe_irq:	dc.l	0
ready_flg:	dc.w	0
sector_count:	dc.w	0
sector:		dc.w	0
track:		dc.w	0


dma_init:
	btst	#1,$fffffc00.w		*Wait for dma
	beq.s	dma_init

	pea	buffer(pc)		*Dma destination
	move.b	3(a7),$ff860d
	move.b	2(a7),$ff860b
	move.b	1(a7),$ff8609
	addq.l	#4,a7

	move.b	#14,$ffff8800.w		*Side 0
	move.b	$ffff8800.w,d0
	and.b	#$f8,d0
	bset	#0,d0
	move.b	d0,$ffff8802.w


	move	#200,sector_count	*Number of sectors
	move	#1,sector		*Start at sector...
	move	#0,track		*Start at track...

	bset	#7,$fffffa09.w
	bset	#7,$fffffa15.w

	move	#$86,$ffff8606.w	*Seek track!
	move	track(pc),$ffff8604.w
	bsr.s	dummy
	move	#$80,$ffff8606.w
	move	#$13,$ffff8604.w

	move.l	#main_dma,$11c.w
	bclr	#7,$fffffa11.w

dummy:	rts

main_dma:
	move	#$777,$ffff8240.w

	move	#$90,$ffff8606.w	*Read sector
	move	#$190,$ffff8606.w
	move	#$90,$ffff8606.w
	move	#1,$ffff8604.w
	move	#$84,$ffff8606.w
	move	sector(pc),$ffff8604.w
	bsr.s	dummy
	move	#$80,$ffff8606.w
	move	#$80,$ffff8604.w

	move.l	#irq,$11c.w
	bclr	#7,$fffffa11.w

	move	#0,$ffff8240.w

	rte

irq:
	move	#$777,$ffff8240.w

	subq.w	#1,sector_count		*Decrease counter
	tst.w	sector_count
	bne.s	finish
	st	ready_flg		*Finsihed...
	rte
finish:
	addq.w	#1,sector		*Add sector
	cmp.w	#9,sector
	ble.s	no_step			*Time for step?
	move	#1,sector
	addq.w	#1,track

	move	#$80,$ffff8606.w	*Step in
	move	#$51,$ffff8604.w

	move.l	#no_step,$11c.w
	bclr	#7,$fffffa11.w

	move	#0,$ffff8240.w

	rte

no_step:
	bra	main_dma

text:	dc.b	"Yeah! I've made a better DMA "
	dc.b	"Loader....... ",0

buffer:
