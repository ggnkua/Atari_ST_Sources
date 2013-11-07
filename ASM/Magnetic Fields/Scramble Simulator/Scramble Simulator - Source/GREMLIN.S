;+=============================================================+;
; Gremlin protection check			;
;-=============================================================-;
;set up register pointer
check_prot	move.l	a0,ptr
	lea	$ffff8604,a5
;this section will check ol' Gremmies protection
	bsr	wait2
;select side 0, drive A
	moveq	#5,d1
	bsr	select_drive_A
	moveq	#0,d0
	bsr	seek_track	seek track 0
	bsr.s	read_track	read it
	bsr	get_dma		get length
	move.l	d0,-(a7)
	bsr	wait2
	moveq	#79,d0
	bsr	seek_track	seek track 79
	bsr.s	read_track	read it
	bsr	get_dma		get length
	sub.l	d0,(a7)
	bsr	wait2
	cmpi.l	#60,(a7)+
	bgt.s	okay
error	clr.l	$420.w	Memory invalid
	move.l	4.w,a0	Reset
	jmp	(a0)
okay	moveq	#7,d1
	bsr	select_drive_A
	bra	load_game

read_track
	bsr.s	wait
	bsr	set_dma
	move.w	#$90,2(a5)
	move.w	#$190,2(a5)		select read
	move.w	#$90,2(a5)
	bsr.s	fdc_delay
	move.w	#$1f,(a5)		set sector count register
	bsr.s	fdc_delay
	move.w	#$80,2(a5)		get command register
	bsr.s	fdc_delay
	move.w	#$e4,(a5)		read track (with settling delay)
	bsr.s	fdc_delay
.w_wait	btst	#5,$fffffa01		INTRQ ?
	bne.s	.w_wait
	rts

wait	move.w	#8000,d1
.wait	dbf	d1,.wait
	rts

get_status
	move.w	#$80,2(a5)	select status register
	bsr.s	fdc_delay
	move.w	(a5),d1
	bra.s	fdc_delay

d02fdc	bsr.s	fdc_delay
	move.w	d0,(a5)		send command/data
fdc_delay
	moveq	#36,d4
.delay	dbf	d4,.delay
	rts

get_dma	moveq	#0,d0
	move.b	5(a5),d0		get dma high
	swap	d0
	move.b	7(a5),d0		get dma mid
	lsl.w	#8,d0
	move.b	9(a5),d0		set dma low
	rts

seek_track
	bsr.s	wait
	move.w	#$86,2(a5)		select data register
	bsr.s	d02fdc
	moveq	#16,d0
	move.w	#$80,2(a5)	select command register
	bsr.s	d02fdc

	move.l	#$60000,d3	allow for motor start-up
.wait	subq.l	#1,d3
	beq	error
	btst	#5,$fffffa01	INTRQ ?
	bne.s	.wait		yes

wait2	move.w	#200,d0
.hold	bsr.s	wait
	dbf	d0,.hold
	bsr	get_status
	rts

select_drive_A
	move.w	sr,-(a7)	save status
	ori.w	#$700,sr	no interrupts
	move.b	#14,$ffff8800	select port A
	move.b	$ffff8800,d0	read port A
	andi.b	#248,d0		clear lower three bits
	or.b	d1,d0
	move.b	d0,$ffff8802	write port A
	move.w	(a7)+,sr	reset status
	rts

set_dma	move.l	ptr,d0
	move.b	d0,9(a5)		set dma low
	lsr.w	#8,d0
	move.b	d0,7(a5)		set dma mid
	swap	d0
	move.b	d0,5(a5)		set dma high
	rts
ptr	dc.l	0
;main os stuff !!
load_game	rts
