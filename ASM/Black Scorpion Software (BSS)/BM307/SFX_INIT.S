;	IN
;	d0=number of channels
;	d1=VBL delay
;	d2=1=12.25kHz 2=25.5kHz 4=50kHz

samplebuffer_size	=	3072

	SECTION TEXT

sound_init:
	tst.b	sound_on
	beq.s	.go
	rts
.go:	st	sound_on

	Cconws	#sfx_init

*****
* Setup variables
*****
	Cconws	#sfx_initvariables
	subq.w	#1,d0
	move.w	d0,num_channels	; save number of channels
	subq.w	#1,d1
	move.w	d1,num_VBLs		; save numbers of VBL

	move.w	d2,freq	; save frequenzy for later
	
	mulu	#256,d2
	move.w	d2,samdiv		; save samdiv

	move.l	#samplebuffer_size,d0
	moveq	#STRAM_only,d1
	jsr	allocate_chunk
	move.l	d0,a0

;	lea	samplebuffer,a0

	move.l	a0,samstart		; sample start
	move.l	a0,sampos		; sample position
	move.l	d2,d3
	mulu	#3*4,d3
	add.l	d3,a0
	move.l	a0,samend		; sample end

*****
* Setup frequenzy adds
*****
	Cconws	#sfx_initfreq
	move.w	freq,d2
	lea	freqtabledata,a0
	lea	freqtable,a1
	moveq.l	#7,d4
	cmp.b	#1,d2
	beq.s	.its12
	moveq.l	#1,d3
	cmp.w	#2,d2
	bne.s	.no50
	moveq.l	#2,d3
.no50:
.freqloop:
	move.w	(a0)+,d5
	lsr.w	d3,d5
	move.w	d5,(a1)+
	dbra	d4,.freqloop
	bra.s	.freqdone
.its12:
	move.w	(a0)+,(a1)+
	dbra	d4,.its12	
.freqdone:

*****
* Calculate volume table
*****
	Cconws	#sfx_initvol
	lea	voltable,a0
	move.l	#255,d3
.volloop:
	move.l	#255,d4
	sub.l	d3,d4	; max
	move.l	#255,d5
.volloop2:
	move.l	#255,d6
	sub.b	d5,d6
	ext.w	d6
	muls	d4,d6
	divs	#255,d6
	move.b	d6,(a0)+
	dbra	d5,.volloop2
	dbra	d3,.volloop

*****
* Calculate ambient table
*****
	Cconws	#sfx_initamb
	addq.l	#1,d0
	lea	ambtable,a0
	move.l	#255,d4
.ambloop:
	move.l	#255,d5
	sub.b	d4,d5
	ext.w	d5
	muls	#256,d5
	divs	d0,d5
	move.w	d5,(a0)+
	move.w	d5,(a0)+
	dbra	d4,.ambloop

*****
* Calculate panoration table
*****
	Cconws	#sfx_initpan
	lea	ambtable,a0
	lea	pantable,a1
	move.l	#255,d3
.panloop:
	move.l	(a0)+,(a1)+
	dbra	d3,.panloop

	Cconws	#sfx_initdone

	rts


sound_start:
*****
* Setup sound chip
*****
	move.l	samstart,d3
	move.b	d3,$ffff8907.w	; frame start (low byte)
	move.b	d3,$ffff890D.w	; frame count (low byte)
	lsr.w	#8,d3
	move.b	d3,$ffff8905.w	; frame start (mid byte)
	move.b	d3,$ffff890B	; frame count (mid byte)
	swap	d3
	move.b	d3,$ffff8903.w	; frame start (high byte)
	move.b	d3,$ffff8909.w	; frame count (high byte)
	move.l	samend,d3
	sub.l	#4,d3
	move.b	d3,$ffff8913.w	; frame end (low byte)
	lsr.w	#8,d3
	move.b	d3,$ffff8911.w	; frame end (mid byte)
	swap 	d3
	move.b	d3,$ffff890f.w	; frame end (high byte)

	move.w	freq,d7
	cmp.b	#1,d7
	bne.s	.not12
	moveq.l	#%01000001,d3
	bra.s	.freqset
.not12:
	cmp.b	#2,d7
	bne.s	.not25
	moveq.l	#%01000010,d3
	bra.s	.freqset
.not25:
	moveq.l	#%01000011,d3
.freqset:
	move.w	d3,$ffff8920.w	; set track control and sound mode

	move.w	#%00000011,$ffff8900	; set interupts and start DMA

	move.l	$70.w,sfx_VBL2+2	; old VBL
	move.l	#sfx_VBL,$70.w	; new VBL

	rts