;
; ~c:install_rasters(line,height,colour,first offset,L:palette)
;

mfp	EQU	$FFFFFA00	The multi-function peripheral 68901
iera	EQU	mfp+$07		Interrupt Enable Register A (reg 4)
ierb	EQU	mfp+$09		Interrupt Enable Register B (reg 5)
imra	EQU	mfp+$13		Interrupt Mask Register A (reg 10)
imrb	EQU	mfp+$15		Interrupt Mask Register B (reg 11)
vector	EQU	mfp+$17		Vector Register (reg 12)
tbcr	EQU	mfp+$1b		Timer B Control Register (reg 14)
tbdr	EQU	mfp+$21		Timer B Data Register (reg 17)

	bra	set_hbl
	bra	reset_hbl
	bra	set_raster
	bra	turn_onc
	bra	turn_offc
	
set_raster
	move.l	a0,-(a7)
	lea	vars(pc),a0
	move	8(a7),(a0)
	move.l	(a7)+,a0
	rts
	
set_hbl
	movem.l	d1-d3/a0-a3,-(a7)	
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1			; put in supervisor mode
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	lea	vars(pc),a0
	move	32(a7),(a0)+		; line
	move	34(a7),(a0)+		; height
	move	36(a7),d0
	and.l	#$ffff,d0
	add	d0,d0
	add.l	#$ffff8240,d0	
	move.l	d0,(a0)+		; colour
	move	38(a7),10(a0)		; first offset
	move.l	40(a7),d0
	addq	#2,d0
	move.l	d0,(a0)+		; pointer
	move.l	d0,(a0)+		; palette

	tst	(a0)
	bne.s	.skip
	move	#1,(a0)			; setup flag
	move	#$2700,sr		; turn off interrupts
	move.l	$4ce.w,$4ea.w		; mouse control to last vbl entry
	bsr.s	savemfp			; save mfp registers
	lea	new_key(pc),a0
	move.l	a0,$118.w		; install new key handler
	lea	hbl(pc),a0
	move.l	a0,$120.w		; install timer B interrupt
	lea	vbl(pc),a0
	move.l	a0,$4ce.w		; install 50 Hz interrupt
	or.b	#1,(iera).w		; enable timer B
	or.b	#1,(imra).w
	move	#$2300,sr		; turn on interrupts
.skip	lea	save_sp(pc),a0
	move.l	(a0),-(a7)
	move	#$20,-(a7)
	trap	#1			; back to user mode
	addq.l	#6,a7
	movem.l	(a7)+,d1-d3/a0-a3
	rts
savemfp	lea	new_key+6(pc),a1
	move.l	$118.w,(a1)
	lea	mfpmem(pc),a1		; preserve mfp registers ...
	move.l	$118.w,(a1)+
	move.l	$120.w,(a1)+
	move.b	(tbdr).w,(a1)+
	move.b	(tbcr).w,(a1)+
	rts

reset_hbl
	movem.l	d0-d7/a0-a6,-(a7)
	lea	setup(pc),a0
	tst	(a0)			; only reset if its been set !
	beq.s	.skip
	clr	(a0)
	clr.l	-(a7)
	move	#$20,-(a7)		; supervisor mode
	trap	#1
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	move	#$2700,sr		; disable interrupts	
	bsr.s	oldmfp			; restore original mfp data	
	bsr.s	flush_keyboard		; flush keyboard processor
	move.l	$4ea.w,$4ce.w		; return priority mouse control
	clr.l	$4ea.w
	move	#$2300,sr		; restore interrupts for OS
	lea	save_sp(pc),a0
	move.l	(a0),-(a7)
	move	#$20,-(a7)
	trap	#1			; user mode
	addq.l	#6,a7
.skip	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
oldmfp	lea	mfpmem(pc),a0		; restore mfp registers ...
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,(tbdr).w
	move.b	(a0)+,(tbcr).w
	eor.b	#1,(iera).w		; disable Timer B
	eor.b	#1,(imra).w
	rts

flush_keyboard
	btst.b	#0,$fffffc00.w		; anything in keyboard buffer
	beq.s 	flushed			; no, so exit
	move.b 	$fffffc02.w,d0		; read character from keyboard
	bra.s 	flush_keyboard
flushed	rts

new_key	move	#$2500,sr	; avoids mouse interference with timer B
	jmp	$0.l		; jump to usual key/mouse handler

vbl	movem.l	d0-2/a0-1,-(a7)
	clr.b	(tbcr).w		; stop timer B
	lea	hbl(pc),a0
	move.l	a0,$120.w
	lea	vars(pc),a0
	moveq	#0,d0
	move	(a0)+,d0
	addq	#1,d0
	move	(a0)+,d1
	bne.s	.nzero
	clr.l	d0
	bra.s	.zero
.nzero	divu	d1,d0			; lines/height
.zero	move	d0,d2
	add	d2,d2
	and.l	#$ffff,d2
	swap	d0
	sub	d0,d1
	add	first_offset(pc),d1
	move.b	d1,(tbdr).w		; offset to first interrupt
	move.l	(a0)+,a1		; colour
	move.l	4(a0),d0		; palette
	add.l	d2,d0
	move.l	d0,(a0)			; pointer
	move.l	d0,a0
	move	-2(a0),(a1)
	move.b	#8,(tbcr).w		; start timer B
	movem.l	(a7)+,d0-2/a0-1
	rts
	
hbl	movem.l	d0/a0-1,-(a7)
	clr.b	(tbcr).w		; stop timer B
	lea	vars+4(pc),a0
	move.l	(a0)+,a1
	move.l	(a0),a0
	move	(a0),(a1)
	lea	vars+2(pc),a0
	move	(a0),d0			; height
	move.b	d0,(tbdr).w		; set time to next interrupt
	addq.l	#2,6(a0)		; increase pointer
	move.b	#8,(tbcr).w		; start timer B
	bclr	#0,$fffffa0f.w		; signal end of timer B
	movem.l	(a7)+,d0/a0-1
	rte

turn_onc	
	move.l	a0,-(a7)
	lea	tonc(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14
	addq	#6,a7
	move.l	(a7)+,a0
	rts
tonc	or.b	#%100000,(ierb).w	; Timer C on
	or.b	#%100000,(imrb).w
	rts

turn_offc	
	move.l	a0,-(a7)
	lea	toffc(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14
	addq	#6,a7
	move.l	(a7)+,a0
	rts
toffc	and.b	#%11011111,(ierb).w	; Timer C off
	and.b	#%11011111,(imrb).w
	rts

vars	
line	ds.w 1
height	ds.w 1
colour	ds.l 1
pointer	ds.l 1
palette	ds.l 1
setup	ds.w 1
first_offset ds.w 1
mfpmem	ds.b 14
save_sp	ds.l 1
