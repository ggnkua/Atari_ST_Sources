;
; STE screen switcher and hardware scroller
;

mfp	EQU	$FFFFFA00	The multi-function peripheral 68901
iera	EQU	mfp+$07		Interrupt Enable Register A (reg 4)
ierb	EQU	mfp+$09		Interrupt Enable Register B (reg 5)
imra	EQU	mfp+$13		Interrupt Mask Register A (reg 10)
imrb	EQU	mfp+$15		Interrupt Mask Register B (reg 11)
vector	EQU	mfp+$17		Vector Register (reg 12)
tbcr	EQU	mfp+$1b		Timer B Control Register (reg 14)
tbdr	EQU	mfp+$21		Timer B Data Register (reg 17)

	bra	set_split
	bra	reset_split
	
set_split
	movem.l	d1-d3/a0-a3,-(a7)	
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1			; put in supervisor mode
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	lea	copy(pc),a0
	move	32(a7),(a0)+		; line
	move	34(a7),d0		; x1
	move	36(a7),d1		; extra width1
	sub	#160,d1
	lsr	#1,d1
	move.l	38(a7),a1		; palette1
	move.l	42(a7),a2		; screen1
	move	d0,d2
	and	#$f,d0			; d0=skew
	beq.s	.no1
	subq	#4,d1
.no1	lsr	#1,d2			; d1=int extra
	and	#$fff8,d2
	add	d2,a2			; add to screen
	move	d0,(a0)+
	move	d1,(a0)+
	move.l	a1,(a0)+
	move.l	a2,(a0)+	

	move	46(a7),d0		; x2
	move	48(a7),d1		; extra width2
	sub	#160,d1
	lsr	#1,d1
	move.l	50(a7),a1		; palette2
	move.l	54(a7),a2		; screen2
	move	d0,d2
	and	#$f,d0			; d0=skew
	beq.s	.no2
	subq	#4,d1
.no2	lsr	#1,d2			; d1=int extra
	and	#$fff8,d2
	add	d2,a2			; add to screen
	move	d0,(a0)+
	move	d1,(a0)+
	move.l	a1,(a0)+
	move.l	a2,(a0)+	
		
	bset	#0,(a0)			; setup flag
	bne.s	.done
	move	#$2700,sr		; turn off interrupts
	move.l	$4ce.w,$4ea.w		; mouse control to last vbl entry
	bsr.s	savemfp			; save mfp registers
	lea	new_key(pc),a0
	move.l	a0,$118.w		; install new key handler
	lea	copy+6(pc),a0
	tst.l	(a0)
	bmi.s	.nopal
	tst.l	12(a0)
	bmi.s	.nopal
	lea	vbl1(pc),a0
	bra.s	.ok
.nopal	lea	vbl2(pc),a0
.ok	move.l	a0,$4ce.w		; install 50 Hz interrupt
	or.b	#1,(iera).w		; enable timer B
	or.b	#1,(imra).w
	and.b	#%11011111,(ierb).w	; Timer C off
	and.b	#%11011111,(imrb).w
	move	#$2300,sr		; turn on interrupts
.done	lea	save_sp(pc),a0
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

reset_split
	movem.l	d0-d7/a0-a6,-(a7)
	lea	setup(pc),a0
	bclr	#0,(a0)
	beq.s	.done			; only reset if its been set !
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
.done	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
oldmfp	lea	mfpmem(pc),a0		; restore mfp registers ...
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,(tbdr).w
	move.b	(a0)+,(tbcr).w
	eor.b	#1,(iera).w		; disable Timer B
	eor.b	#1,(imra).w
	or.b	#%100000,(ierb).w	; Timer C on
	or.b	#%100000,(imrb).w
	clr.b	$ffff820f.w
	clr.b	$ffff8265.w
	rts

flush_keyboard
	btst.b	#0,$fffffc00.w		; anything in keyboard buffer
	beq.s 	flushed			; no, so exit
	move.b 	$fffffc02.w,d0		; read character from keyboard
	bra.s 	flush_keyboard
flushed	rts

new_key	move	#$2500,sr	; avoids mouse interference with timer B
	jmp	$0.l		; jump to usual key/mouse handler

vbl1	movem.l	d0/a0-1,-(a7)
	lea	copy(pc),a0
	lea	vars(pc),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0),(a1)
	clr.b	(tbcr).w		; stop timer B
	lea	hbl1(pc),a0
	move.l	a0,$120.w
	lea	vars(pc),a0
	move.b	3(a0),$ffff8265.w
	move.b	5(a0),$ffff820f.w
	move	(a0),d0
	ble.s	.pal2		
	move.b	d0,(tbdr).w		; set time to next interrupt
	move.l	6(a0),a0		; get palette 1 address
	lea	screen1(pc),a1		
	bra.s	.ok
.pal2	clr.b	(tbdr).w		; draw only palette 2
	move.l	18(a0),a0		; if line<=0
	lea	screen2(pc),a1		
.ok	move.b	#8,(tbcr).w		; start timer B
	move.b	1(a1),$ffff8205.w	
	move.b	2(a1),$ffff8207.w	
	move.b	3(a1),$ffff8209.w	
	
	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l	(a7)+,d0/a0-1
	rts
	
hbl1	movem.l	d0-1/a0-1,-(a7)
	clr.b	(tbcr).w		; stop timer B
	move	#$8209,a0
	move.b	(a0),d0
.dlp	cmp.b	(a0),d0
	beq.s	.dlp
	move	#24,d0			; wait till end of line
.del	dbf	d0,.del	
	lea	x2(pc),a1		; change to new screen address
	move.b	1(a1),92(a0)
	move.b	3(a1),6(a0)
	move.b	9(a1),-4(a0)
	move.b	10(a1),-2(a0)
	move.b	11(a1),(a0)

	move.l	pal2(pc),a0
	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movem.l	(a7)+,d0-1/a0-1
	bclr	#0,$fffffa0f.w		; signal end of timer B
	rte

vbl2	movem.l	d0/a0-1,-(a7)
	lea	copy(pc),a0
	lea	vars(pc),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0),(a1)
	clr.b	(tbcr).w		; stop timer B
	lea	hbl2(pc),a0
	move.l	a0,$120.w
	lea	vars(pc),a0
	move.b	3(a0),$ffff8265.w
	move.b	5(a0),$ffff820f.w
	move	(a0),d0
	ble.s	.pal2		
	move.b	d0,(tbdr).w		; set time to next interrupt
	lea	screen1(pc),a1		
	bra.s	.ok
.pal2	clr.b	(tbdr).w
	lea	screen2(pc),a1		
.ok	move.b	#8,(tbcr).w		; start timer B
	move.b	1(a1),$ffff8205.w	
	move.b	2(a1),$ffff8207.w	
	move.b	3(a1),$ffff8209.w	
	movem.l	(a7)+,d0/a0-1
	rts
	
hbl2	movem.l	d0-1/a0-1,-(a7)
	clr.b	(tbcr).w		; stop timer B
	move	#$8209,a0
	move.b	(a0),d0
.dlp	cmp.b	(a0),d0
	beq.s	.dlp
	move	#24,d0			; wait till end of line
.del	dbf	d0,.del	
	lea	x2(pc),a1		; change to new screen address
	move.b	1(a1),92(a0)
	move.b	3(a1),6(a0)
	move.b	9(a1),-4(a0)
	move.b	10(a1),-2(a0)
	move.b	11(a1),(a0)
	movem.l	(a7)+,d0-1/a0-1
	bclr	#0,$fffffa0f.w		; signal end of timer B
	rte

vars
line	ds.w	1
x1	ds.w	1
width1	ds.w	1
pal1	ds.l	1
screen1	ds.l	1
x2	ds.w	1
width2	ds.w	1
pal2	ds.l	1
screen2	ds.l	1
copy	ds.b	26
setup	ds.w	1
mfpmem	ds.b	16
save_sp	ds.l	1
