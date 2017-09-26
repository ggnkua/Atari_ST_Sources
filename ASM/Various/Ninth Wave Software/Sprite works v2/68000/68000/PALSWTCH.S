;
; Palette switcher. Allows one complete palette switch giving 32 
; on screen colours.
;
; 	~C:install_hbl(lines,l:palette1,l:palette2)
;

mfp	EQU	$FFFFFA00	The multi-function peripheral 68901
iera	EQU	mfp+$07		Interrupt Enable Register A (reg 4)
imra	EQU	mfp+$13		Interrupt Mask Register A (reg 10)
vector	EQU	mfp+$17		Vector Register (reg 12)
tbcr	EQU	mfp+$1b		Timer B Control Register (reg 14)
tbdr	EQU	mfp+$21		Timer B Data Register (reg 17)

	bra	set_hbl
	bra	reset_hbl
	
set_hbl
	movem.l	d1-d3/a0-a3,-(a7)	
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1			; put in supervisor mode
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	lea	vars(pc),a0
	move	32(a7),(a0)		; line
	subq	#2,(a0)+
	move.l	34(a7),(a0)+		; palette 1
	move.l	38(a7),(a0)+		; palette 2
	bset	#0,(a0)			; setup flag
	bne.s	.done
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

reset_hbl
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
	rts

flush_keyboard
	btst.b	#0,$fffffc00.w		; anything in keyboard buffer
	beq.s 	flushed			; no, so exit
	move.b 	$fffffc02.w,d0		; read character from keyboard
	bra.s 	flush_keyboard
flushed	rts

new_key	move	#$2500,sr	; avoids mouse interference with timer B
	jmp	$0.l		; jump to usual key/mouse handler

vbl	movem.l	d0/a0-1,-(a7)
	clr.b	(tbcr).w		; stop timer B
	lea	hbl(pc),a0
	move.l	a0,$120.w
	lea	vars(pc),a0
	move	(a0),d0
	ble.s	.pal2		
	move.b	d0,(tbdr).w		; set time to next interrupt
	move.l	2(a0),a0		; get palette 1 address
	bra.s	.ok
.pal2	clr.b	(tbdr).w		; draw only palette 2
	move.l	6(a0),a0		; if line<=0
.ok	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.b	#8,(tbcr).w		; start timer B
	movem.l	(a7)+,d0/a0-1
	rts
	
hbl	clr.b	(tbcr).w		; stop timer B
	move.b	d0,-(a7)
	move.b	$ffff8a3c.w,d0	
	clr.b	$ffff8a3c.w		; stop blitter interfering
	move	#$2100,sr
	stop	#$2100
	movem.l	d0-7/a0,-(a7)
	move	#6,d0
.dlp	dbf	d0,.dlp
	move.l	pal2(pc),a0		; get palette 2 address
	movem.l	(a0),d0-7
	movem.l	d0-7,$ffff8240.w
	movem.l	(a7)+,d0-7/a0
	move.b	d0,$ffff8a3c.w
	move.b	(a7)+,d0
	bclr	#0,$fffffa0f.w		; signal end of timer B
	rte

vars	ds.w	1
pal1	ds.l	1
pal2	ds.l	1
setup	ds.w	1
mfpmem	ds.b	14
save_sp	ds.l	1
