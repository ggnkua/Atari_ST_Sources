;
; Sample player.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; Uses System Timer A interrupt to provide a variable interrupt
; frequency from 48-614400 Hz
;
	bra	player
	bra	exit
	bra	wait
	bra	convert
	bra	sam_playing
	
	opt	o+	
convert	move.l	a0,-(a7)
	move.l	8(a7),a0
	move.l	12(a7),d0
.lp	add.b	#128,(a0)+
	subq.l	#1,d0
	bne.s	.lp
	move.l	(a7)+,a0
	rts
		
player	movem.l	d0-d7/a0-a6,-(a7)	
	bsr	super_on
	lea	start(pc),a0
	move.l	64(a7),d0		; start
	move.l	68(a7),d1		; length
	move.l	72(a7),d2		; speed/loop
	add.l	d0,d1			; add length to start
	move.l	d0,(a0)			; store start
	move.l	d1,4(a0)		; store destination
	move.l	d2,8(a0)		; store speed/loop
	move	#1,12(a0)		; sample playing
	move.l	d0,14(a0)
	lea	setup(pc),a1
	bset	#0,(a1)			; has program already been run ?
	bne.s   .done			; yes, so branch to done
	bsr	replay			; install interrupt
	bra.s	.skip
.done	bsr	setfreq			; set sample frequency
	lea	add1+2(pc),a0
	lea	start(pc),a1
	move.l	(a1),(a0)
	lea	samplay(pc),a0
	move.l	a0,$134.w
.skip	bsr.s	super_off
	movem.l	(a7)+,d0-d7/a0-a6
	rts
;
; Stop the sample player and interrupts
; ~C:sam_stop%()
;
exit	movem.l	d0-d7/a0-a6,-(a7)
	lea	setup(pc),a0
	bclr	#0,(a0)			; reset & test setup flag
	beq.s	.skip
	bsr.s	super_on
	move	#$2700,sr		; disable interrupts	
	bsr	oldmfp			; restore original mfp data	
	bsr	flushout		; flush keyboard processor
	lea	playing(pc),a0
	clr	(a0)			; not playing
	move	#$2300,sr		; restore interrupts for OS
	bsr.s	super_off
.skip	movem.l	(a7)+,d0-d7/a0-a6
	rts
;
; Wait for end of sample
; ~C:sam_wait%()
;
wait	move.l	a0,-(a7)
	lea	playing(pc),a0
wait_lp	tst	(a0)			; sample playing ?
	bne.s	wait_lp			; yes, keep on waiting
	move.l	(a7)+,a0
	rts
;
; Test is sample is playing
; play&=C:sam_playing%()  =0 not playing, otherwise sample address
; 
sam_playing
	move.l	a0,-(a7)
	moveq	#0,d0
	lea	playing(pc),a0
	tst	(a0)
	beq.s	.null
	move.l	current(pc),d0
.null	move.l	(a7)+,a0
	rts
super_on
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1			; supervisor mode
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	rts
super_off
	lea	save_sp(pc),a0
	move.l	(a0),-(a7)
	move	#$20,-(a7)
	trap	#1			; user mode
	addq.l	#6,a7
	rts
	
mfp	EQU	$FFFFFA00	The multi-function peripheral 68901
iera	EQU	mfp+$07		Interrupt Enable Register A (reg 4)
imra	EQU	mfp+$13		Interrupt Mask Register A (reg 10)
vector	EQU	mfp+$17		Vector Register (reg 12)
tacr	EQU	mfp+$19		Timer A Control Register (reg 13)
tadr	EQU	mfp+$1f		Timer A Data Register (reg 14)

replay	move	#$2700,sr		; interrupts off	
	bsr.s	savemfp			; save original MFP registers
	lea	inull(pc),a1
	move.l	a1,$134.w		; null routine
	bsr.s	setfreq			; set frequency
	bsr	enabmfp			; start mfp running	
	bsr	setsnd			; set up sound registers
	lea	add1+2(pc),a0
	move.l	a0,6(a0)		; insert self-modifying address
	lea	start(pc),a1
	move.l	(a1),(a0)
	lea	vbl_patch+2(pc),a0
	move.l	$70.w,(a0)
	lea	sam_vbl(pc),a0
	move.l	a0,$70.w		; install sample controller
	lea	samplay(pc),a0
	move.l	a0,$134.w		; install sample player
	move	#$2300,sr		; enable interrupts	
	rts	
flushout
	btst.b	#0,$fffffc00.w		; anything in keyboard buffer
	beq.s 	flushed			; no, so exit
	move.b 	$fffffc02.w,d0		; read character from keyboard
	bra.s 	flushout
flushed	rts
	
savemfp	lea	mfpmem(pc),a1
	move.l	$134.w,(a1)+
	move.l	$70.w,(a1)+
	move.b	(tadr).w,(a1)+		; preserve mfp registers ...
	move.b	(tacr).w,(a1)+
	rts
	
oldmfp	lea	mfpmem(pc),a0
	move.l	(a0)+,$134.w
	move.l	(a0)+,$70.w
	move.b	(a0)+,(tadr).w
	move.b	(a0)+,(tacr).w
	and.b	#%11011111,(imra).w	; disable Timer A
	and.b	#%11011111,(iera).w	; disable Timer A
;	bset.b	#3,(vector).w
	rts

setfreq	move	8(a0),d0		; get speed
	move.l	#614400,d1
	divu	d0,d1
	clr.b	(tacr).w		; disable Timer A
 	move.b	d1,(tadr).w		; /by D1 in data register
	move.b	#1,(tacr).w		; /by 4 in control register	
	rts

enabmfp	or.b	#%00100000,(imra).w	; enable Timer A
	or.b	#%00100000,(iera).w	; enable Timer A
;	bclr.b	#3,(vector).w
	rts

setsnd	lea	.soff(pc),a0
	moveq	#8,d0
.lp	move.b	(a0)+,$ffff8800.w
	clr.b	$ffff8802.w
	dbf	d0,.lp
	move.b	#7,$ffff8800.w		; set up channel mixing
	move.b	#$ff,$ffff8802.w	; & port 'A' I/O	
	rts
.soff	dc.b	8,9,10,0,1,2,3,4,5

sam_vbl	movem.l	d0-1/a0-1,-(a7)
	lea	add1+2(pc),a0		; self-modifying address
	lea	start(pc),a1
	move.l	(a0),d0			; sample address	
	move.l	4(a1),d1		; destination address
	sub.l	d0,d1			; finished yet ?
	bpl.s	.notfin	
	clr	12(a1)			; stop playing
	tst	10(a1)
	beq.s	.fin
	move	#1,12(a1)
	move.l	(a1),(a0)		; store start within instruction
	bra.s	.notfin
.fin	lea	inull(pc),a0		; when finished,
	move.l	a0,$134.w		; insert a null interrupt
.notfin	movem.l	(a7)+,d0-1/a0-1
vbl_patch jmp	$0.l			; execute other OS calls

samplay	movem.l	d0/a0,-(a7)
	moveq	#0,d0			; clear d0
add1	move.b	$0.l,d0			; get sample byte
	addq.l	#1,add1+2		; increase sample address
	lsl	#3,d0			; times 8 for lookup table	
	lea	$ffff8800.w,a0		; sound chip address
	move.l	snd_out+4(pc,d0.w),(a0)	; get and play channel C
	move.l	snd_out(pc,d0.w),d0	; get channels A & B
	movep.l	d0,(a0)			; play A & B
	movem.l	(a7)+,d0/a0
inull	bclr	#5,$fffffa0f.w		; end of interrupt
	rte

snd_out	DC.W	$80C,$90B,$A00,$900,$80C,$90B,$A00,$900
	DC.W	$80D,$908,$A00,$800,$80B,$90B,$A00,$B00
	DC.W	$80D,$909,$A00,$500,$80C,$90B,$A00,$800
	DC.W	$80D,$909,$A00,$200,$80D,$908,$A00,$600
	DC.W	$80C,$90B,$A00,$700,$80D,$907,$A00,$700
	DC.W	$80C,$90B,$A00,$600,$80C,$90A,$A00,$900
	DC.W	$80B,$90B,$A00,$A00,$80C,$90B,$A00,$200
	DC.W	$80C,$90B,$A00,$000,$80C,$90A,$A00,$800
	DC.W	$80D,$906,$A00,$400,$80D,$905,$A00,$500
	DC.W	$80D,$905,$A00,$400,$80C,$909,$A00,$900
	DC.W	$80D,$904,$A00,$300,$80B,$90B,$A00,$900
	DC.W	$80C,$90A,$A00,$500,$80B,$90A,$A00,$A00
	DC.W	$80C,$909,$A00,$800,$80B,$90B,$A00,$800
	DC.W	$80C,$90A,$A00,$000,$80C,$90A,$A00,$000
	DC.W	$80C,$909,$A00,$700,$80B,$90B,$A00,$700
	DC.W	$80C,$909,$A00,$600,$80B,$90B,$A00,$600
	DC.W	$80B,$90A,$A00,$900,$80B,$90B,$A00,$500
	DC.W	$80A,$90A,$A00,$A00,$80B,$90B,$A00,$200
	DC.W	$80B,$90A,$A00,$800,$80C,$907,$A00,$700
	DC.W	$80C,$908,$A00,$400,$80C,$907,$A00,$600
	DC.W	$80B,$909,$A00,$900,$80C,$906,$A00,$600
	DC.W	$80A,$90A,$A00,$900,$80C,$907,$A00,$300
	DC.W	$80B,$90A,$A00,$500,$80B,$909,$A00,$800
	DC.W	$80B,$90A,$A00,$300,$80A,$90A,$A00,$800
	DC.W	$80B,$90A,$A00,$000,$80B,$909,$A00,$700
	DC.W	$80B,$908,$A00,$800,$80A,$90A,$A00,$700
	DC.W	$80A,$909,$A00,$900,$80C,$901,$A00,$100
	DC.W	$80A,$90A,$A00,$600,$80B,$908,$A00,$700
	DC.W	$80A,$90A,$A00,$500,$80A,$909,$A00,$800
	DC.W	$80A,$90A,$A00,$200,$80A,$90A,$A00,$100
	DC.W	$80A,$90A,$A00,$000,$809,$909,$A00,$900
	DC.W	$80A,$908,$A00,$800,$80B,$908,$A00,$100
	DC.W	$80A,$909,$A00,$600,$80B,$907,$A00,$400
	DC.W	$80A,$909,$A00,$500,$809,$909,$A00,$800
	DC.W	$80A,$909,$A00,$300,$80A,$908,$A00,$600
	DC.W	$80A,$909,$A00,$000,$809,$909,$A00,$700
	DC.W	$809,$908,$A00,$800,$80A,$908,$A00,$400
	DC.W	$809,$909,$A00,$600,$80A,$908,$A00,$100
	DC.W	$809,$909,$A00,$500,$809,$908,$A00,$700
	DC.W	$808,$908,$A00,$800,$809,$909,$A00,$200
	DC.W	$809,$908,$A00,$600,$809,$909,$A00,$000
	DC.W	$809,$907,$A00,$700,$808,$908,$A00,$700
	DC.W	$809,$907,$A00,$600,$809,$908,$A00,$200
	DC.W	$808,$908,$A00,$600,$809,$906,$A00,$600
	DC.W	$808,$907,$A00,$700,$808,$908,$A00,$400
	DC.W	$808,$907,$A00,$600,$808,$908,$A00,$200
	DC.W	$807,$907,$A00,$700,$808,$906,$A00,$600
	DC.W	$808,$907,$A00,$400,$807,$907,$A00,$600
	DC.W	$808,$906,$A00,$500,$808,$906,$A00,$400
	DC.W	$807,$906,$A00,$600,$807,$907,$A00,$400
	DC.W	$808,$905,$A00,$400,$806,$906,$A00,$600
	DC.W	$807,$906,$A00,$400,$807,$905,$A00,$500
	DC.W	$806,$906,$A00,$500,$806,$906,$A00,$400
	DC.W	$806,$905,$A00,$500,$806,$906,$A00,$200
	DC.W	$806,$905,$A00,$400,$805,$905,$A00,$500
	DC.W	$806,$905,$A00,$200,$805,$905,$A00,$400
	DC.W	$805,$904,$A00,$400,$805,$905,$A00,$200
	DC.W	$804,$904,$A00,$400,$804,$904,$A00,$300
	DC.W	$804,$904,$A00,$200,$804,$903,$A00,$300
	DC.W	$803,$903,$A00,$300,$803,$903,$A00,$200
	DC.W	$803,$902,$A00,$200,$802,$902,$A00,$200
	DC.W	$802,$902,$A00,$100,$801,$901,$A00,$100
	DC.W	$802,$901,$A00,$000,$801,$901,$A00,$000
	DC.W	$801,$900,$A00,$000,$800,$900,$A00,$000
	DC.W	$80E,$90D,$A00,$C00,$80F,$903,$A00,$000
	DC.W	$80F,$903,$A00,$000,$80F,$903,$A00,$000
	DC.W	$80F,$903,$A00,$000,$80F,$903,$A00,$000
	DC.W	$80F,$903,$A00,$000,$80E,$90D,$A00,$B00
	DC.W	$80E,$90D,$A00,$B00,$80E,$90D,$A00,$B00
	DC.W	$80E,$90D,$A00,$B00,$80E,$90D,$A00,$B00
	DC.W	$80E,$90D,$A00,$B00,$80E,$90D,$A00,$B00
	DC.W	$80E,$90D,$A00,$A00,$80E,$90D,$A00,$A00
	DC.W	$80E,$90D,$A00,$A00,$80E,$90D,$A00,$A00
	DC.W	$80E,$90C,$A00,$C00,$80E,$90D,$A00,$000
	DC.W	$80D,$90D,$A00,$D00,$80D,$90D,$A00,$D00
	DC.W	$80D,$90D,$A00,$D00,$80D,$90D,$A00,$D00
	DC.W	$80D,$90D,$A00,$D00,$80D,$90D,$A00,$D00
	DC.W	$80E,$90C,$A00,$B00,$80E,$90C,$A00,$B00
	DC.W	$80E,$90C,$A00,$B00,$80E,$90C,$A00,$B00
	DC.W	$80E,$90C,$A00,$B00,$80E,$90C,$A00,$B00
	DC.W	$80E,$90C,$A00,$B00,$80E,$90C,$A00,$B00
	DC.W	$80E,$90C,$A00,$A00,$80E,$90C,$A00,$A00
	DC.W	$80E,$90C,$A00,$A00,$80E,$90C,$A00,$A00
	DC.W	$80D,$90D,$A00,$C00,$80D,$90D,$A00,$C00
	DC.W	$80E,$90C,$A00,$900,$80E,$90C,$A00,$900
	DC.W	$80E,$90C,$A00,$500,$80E,$90C,$A00,$000
	DC.W	$80E,$90C,$A00,$000,$80E,$90B,$A00,$B00
	DC.W	$80E,$90B,$A00,$B00,$80E,$90B,$A00,$B00
	DC.W	$80E,$90B,$A00,$B00,$80E,$90B,$A00,$A00
	DC.W	$80E,$90B,$A00,$A00,$80E,$90B,$A00,$A00
	DC.W	$80D,$90D,$A00,$B00,$80D,$90D,$A00,$B00
	DC.W	$80D,$90D,$A00,$B00,$80E,$90B,$A00,$900
	DC.W	$80E,$90B,$A00,$900,$80E,$90B,$A00,$900
	DC.W	$80D,$90C,$A00,$C00,$80D,$90D,$A00,$A00
	DC.W	$80E,$90B,$A00,$700,$80E,$90B,$A00,$000
	DC.W	$80E,$90B,$A00,$000,$80D,$90D,$A00,$900
	DC.W	$80D,$90D,$A00,$900,$80E,$90A,$A00,$900
	DC.W	$80D,$90D,$A00,$800,$80D,$90D,$A00,$700
	DC.W	$80D,$90D,$A00,$400,$80D,$90D,$A00,$000
	DC.W	$80E,$90A,$A00,$400,$80E,$909,$A00,$900
	DC.W	$80E,$909,$A00,$900,$80D,$90C,$A00,$B00
	DC.W	$80E,$909,$A00,$800,$80E,$909,$A00,$800
	DC.W	$80E,$909,$A00,$700,$80E,$908,$A00,$800
	DC.W	$80E,$909,$A00,$100,$80C,$90C,$A00,$C00
	DC.W	$80D,$90C,$A00,$A00,$80E,$908,$A00,$600
	DC.W	$80E,$907,$A00,$700,$80E,$908,$A00,$000
	DC.W	$80E,$907,$A00,$500,$80E,$906,$A00,$600
	DC.W	$80D,$90C,$A00,$900,$80E,$905,$A00,$500
	DC.W	$80E,$904,$A00,$400,$80D,$90C,$A00,$800
	DC.W	$80D,$90B,$A00,$B00,$80E,$900,$A00,$000
	DC.W	$80D,$90C,$A00,$600,$80D,$90C,$A00,$500
	DC.W	$80D,$90C,$A00,$200,$80C,$90C,$A00,$B00
	DC.W	$80C,$90C,$A00,$B00,$80D,$90B,$A00,$A00
	DC.W	$80D,$90B,$A00,$A00,$80D,$90B,$A00,$A00
	DC.W	$80D,$90B,$A00,$A00,$80C,$90C,$A00,$A00
	DC.W	$80C,$90C,$A00,$A00,$80C,$90C,$A00,$A00
	DC.W	$80D,$90B,$A00,$900,$80D,$90B,$A00,$900
	DC.W	$80D,$90A,$A00,$A00,$80D,$90A,$A00,$A00
	DC.W	$80D,$90A,$A00,$A00,$80C,$90C,$A00,$900
	DC.W	$80C,$90C,$A00,$900,$80C,$90C,$A00,$900
	DC.W	$80D,$90B,$A00,$600,$80C,$90B,$A00,$B00
	DC.W	$80C,$90C,$A00,$800,$80D,$90B,$A00,$000
	DC.W	$80D,$90B,$A00,$000,$80C,$90C,$A00,$700
	DC.W	$80C,$90C,$A00,$600,$80C,$90C,$A00,$500
	DC.W	$80C,$90C,$A00,$300,$80C,$90C,$A00,$100
	DC.W	$80C,$90B,$A00,$A00,$80D,$90A,$A00,$500
	DC.W	$80D,$90A,$A00,$400,$80D,$90A,$A00,$200
	DC.W	$80D,$909,$A00,$800,$80D,$909,$A00,$800

; The MFP runs at 2457600 Hz. To calculate a sample frequency you must
; divide this frequency by two values. The first byte is a value between
; 0-255 and the second byte is a look-up value:
;	1 = Divide by 4
;	2 = Divide by 10
;	3 = Divide by 16
;	4 = Divide by 50
;	5 = Divide by 64
;	6 = Divide by 100
;	7 = Divide by 200
; This routine uses divide by 4 and calculates the second divider value.
; 2457600/4=614400, this is then divided by the frequency which gives
; the second divider.
;  
; Example: 7500kHz would give 614400/7500=81. So the control register
; would be one (/by 4) and the data register would be 81.

setup		ds.w	1
mfpmem		ds.b	10
start		ds.l	1
destination	ds.l	1
speed		ds.w	1
loop		ds.w	1
playing		ds.w	1
current		ds.l	1
save_sp		ds.l	1
