;
; Spectrum 512 displayer and decompressor.
; Written by Terry King/Ninth Wave Software 1993-95
;
; This uses the VBI table to install a 50 Hz interrupt. Installing the
; interrupt is simply a matter of storing the interrupt routine address
; at location $4d2. This may interfere with other programs, so it may
; be neccessary to patch it into the Level 4 interrupt at $70. See
; the wait_vbi routine to see how to do this.
;
;	~C:view_512%(L:picture,L:screen)
;	~C:unpack_spc%(L:source,L:destination)

	bra	display
unpack_spc
	movem.l	d1-7/a0-6,-(a7)
	move.l	60(a7),a0
	move.l	64(a7),a1
	lea	160(a1),a1
	lea	32000-160(a1),a4
	cmp	#"SP",(a0)+		; correct header ?
	bne	.notspc
	addq	#2,a0
	move.l	(a0)+,d6		; picture size
	addq	#4,a0
	lea	(a0,d6.l),a6		; a1 -> palette data
	move.l	#$00070001,d2		; screen increases
	moveq	#4-1,d3			; four bit planes
	lea	32000-160(a1),a2	; end of screen
.dat_lp	move.b	(a0)+,d0		; get control byte
	ext	d0
	bmi.s	.repeat
.copy	move.b	(a0)+,(a1)		; positive, direct copy of
	add	d2,a1			; <control byte+1> bytes
	swap	d2			
	dbf	d0,.copy	
	bra.s	.nxtlin
.repeat	neg	d0			; negative, repeat copy of
	addq	#1,d0			; <-control byte+2> bytes
.rlp	move.b	(a0),(a1)		; copy same byte
	add	d2,a1
	swap	d2
	dbf	d0,.rlp
	addq	#1,a0			; next control byte
.nxtlin	cmp.l	a2,a1			; finished all 199 lines ?
	blt.s	.dat_lp
	lea	-32000+2+160(a1),a1	; back to start of next plane
	dbf	d3,.dat_lp
	
	move	#596,d3			; 597 palettes
.nxtpal	move	(a6)+,d0
	moveq	#15,d1

.nxtcol	clr	d2
	roxr	#1,d0			; test each bit in carry flag
	bcc.s	.clear			; colour is black
	move	(a6)+,d2		; copy colour
.clear	move	d2,(a4)+		; store colour
	dbf	d1,.nxtcol		; next colour
	dbf	d3,.nxtpal		; next palette
	
.notspc	movem.l	(a7)+,d1-7/a0-6
	rts
	
display	movem.l	d0-7/a0-6,-(a7)
	move.l	64(a7),a5		; picture address
	move.l	68(a7),a6		; screen address
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1			; put it in supervisor mode
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	lea	spal(pc),a1		; store palette
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a1)
	move	#$12,-(a7)		; disable mouse
	move	#4,-(a7)		; send to IKDB
	move	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	move	#5,-(a7)
	move	#26,-(a7)
	trap	#14			; disable timer C
	addq.l	#4,a7	
	move.l	$4d2.w,a0
	move.l	a0,-(a7)
	bsr.s	hi_res
	bsr.s	delay
	move.l	(a7)+,a0
	move.l 	a0,$4d2.w		; restore original VBL
	move.l	68(a7),a1
	move 	#7999,d0
.lp	clr.l 	(a1)+			; clear screen
	dbf	d0,.lp
	move	#5,-(a7)
	move	#27,-(a7)
	trap	#14			; enable timer C
	addq.l	#4,a7	
	move	#8,-(a7)		; enable mouse
	move	#4,-(a7)		; send to IKDB
	move	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	movem.l	spal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w	; restore palette
	lea	save_sp(pc),a0
	move.l	(a0),-(a7)
	move	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	movem.l	(a7)+,d0-7/a0-6
	rts

delay	move.b	$fffffc02.w,D0
	beq.s	delay
	ext	d0
	btst	#8,d0
	bne.s	delay			; wait for keypress
	move	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

hi_res	lea 	(a5),a0
	lea 	(a6),a1
	move 	#7999,d0
.lp	move.l 	(a0)+,(a1)+		; copy image to screen
	dbf	d0,.lp
	lea	palette(pc),a1
	move.l	a0,(a1)
	lea	vbl(pc),a1
	move.l 	a1,$4d2.w		; install VBL routine
	rts
	
vbl	movem.l a0-a6/d0-d7,-(sp)
	move 	#$2700,sr		; turn off interrupts
	lea 	$ffff8240.w,a5		; pointer to colour table
	movem.l	blank(pc),d0-d7
	movem.l	d0-d7,(a5)
	move.l 	palette(pc),a4		; pointer to palettes
	lea 	$ffff8209.w,a3		; video Address Pointer
	move 	#197,d7			; 198 lines
test	tst.b 	(a3)			; synchronise with screen
	beq.s 	test
	moveq 	#0,d0
	move.b 	(a3),d0
	lea 	jump(pc),a3
	add.l 	d0,a3
	jmp 	(a3)
jump
	rept 	78
	nop				; NOPS for exact time delays
	endr
loop	nop
	nop
	move.l	a5,a0
	move.l	a5,a1
	move.l	a5,a2                                   
	rept	8
	move.l 	(a4)+,(a0)+		; copy palettes
	endr
	rept	8
	move.l 	(a4)+,(a1)+		; copy palettes
	endr
	rept	8
	move.l 	(a4)+,(a2)+		; copy palettes
	endr
	dbf 	d7,loop
	movem.l	blank(pc),d0-d7
	movem.l	d0-d7,(a5)		; clear palette
	move 	#$2300,sr		; interrupt on
	movem.l (sp)+,a0-a6/d0-d7
	rts				; use rts, not rte for VBI table

blank	ds.w	32
palette	ds.l	1
spal	ds.w	16
save_sp	ds.l	1
