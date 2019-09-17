; sam_conv holds 9 routines to change sampled sound data
; Call from GfA Basic:
; ret%=C:sample_conv%(command,L:source%,L:dest%,L:length%)
; if ret%=-1 an error has occurred: either parameter <0 or >7
; or worse an address error (source% or dest% not even where
; they should be..) 
;

; command: 0 --> 8-bit stereo to 8 bit mono
;          1 --> 16-bit stereo to 16-bit mono
;          2 --> sign/unsign sample (bitsize doesn't matter)
;	 3 --> double 8-bit to 16-bit (also mono to stereo)
;          4 --> shrink 16-bit to 8-bit sample
;	 5 --> reverse: 8-bit mono using BYTES
;	 6 --> reverse: 8-bit stereo or 16-bit mono using WORDS
;          7 --> reverse: 16-bit stereo using LONGS
;	 8 --> adjust volume

; Theo Ros, 29/08/1997		SAM_CONV.PRG = 516 bytes

; =============================================================
	move.w	4(sp),d0		; command
	movem.l	6(sp),a0/a1	; source en dest
	move.l	14(sp),d1		; length
	tst.w	d0		; 0: stereo 8-bit --> mono 8-bit
	beq.s	st8_mono8	
	cmpi.w	#1,d0		; 1: stereo 16-bit --> mono 16-bit
	beq.s	st16_mono16
	cmpi.w	#2,d0		; 2: signed <-> unsigned  
	beq.s	sign
	cmpi.w	#3,d0		; 3: 8-bit sample --> 16-bit
	beq	sample8_16
	cmpi.w	#4,d0		; 4: 16-bit sample --> 8-bit
	beq	sample16_8	
	cmpi.w	#5,d0		; 5: reverse 8-bit mono
	beq	reverse8
	cmpi.w	#6,d0		; 6: reverse 8-bit stereo/16-bits mono
	beq	reverse16
	cmpi.w	#7,d0		; 7: reverse 16-bit stereo
	beq	reverse32
	cmpi.w	#8,d0		; 8: adjust volume in sample
	beq	volume
	moveq	#-1,d0		; error
	rts

; =============================================================
; converts 8-bit stereo sample to 8-bit mono
; -->	A0 = Sample Start Address
;       	A1 = Sample Destination Address
;	D1 = Sample length (in bytes)
; <--	length of mono sample (=half the size of stereo)
; =============================================================

st8_mono8:	lsr.l	#1,d1	; length\2
		move.l	d1,d0	
stereo_mono:	subq.l	#1,d1
		bmi	conv_exit	
		move.b	(a0)+,d2
		or.b	(a0)+,d2
		move.b	d2,(a1)+
		bra.s	stereo_mono

; =============================================================
; converts 16-bit stereo sample to 16-bit mono
; -->	A0 = Sample Start Address 		EVEN
;       	A1 = Sample Destination Address	EVEN
;	D1 = Sample length (in bytes)
; <--	length of mono sample (=half the size of stereo)
; =============================================================

st16_mono16:	bsr	chk_address	; check if EVEN
		bne	conv_exit
		lsr.l	#1,d1		; length\2
		move.l	d1,d0
		lsr.l	#1,d1		; using WORDS
ste16_loop:	subq.l	#1,d1
		bmi	conv_exit	
		move.w	(a0)+,d2
		or.w	(a0)+,d2
		move.w	d2,(a1)+
		bra.s	ste16_loop

; =============================================================
; converts SIGNED to UNSIGNED and vice versa
; -->	A0 = Sample Start Address
;       	A1 = Sample Destination Address
;	D1 = Sample length (in bytes)
; <--	rubbish: always 0
; =============================================================


sign:		move.l	d1,d0	 
		beq	conv_exit
		move.l	a0,d1		; should be both even or odd
		andi.l	#1,d1		; for maximum performance
		move.l	a1,d2
		andi.l	#1,d2
		cmp.w	d1,d2
		bne.s	sign_bytes	; one is odd, other even:
		tst.w	d1		; only bytesize possible
		beq.s	sign_longs
		move.b	(a0)+,d2		; both odd, so do first byte
		eori.b	#$80,d2
		move.b	d2,(a1)+
		subq.l	#1,d0
		
sign_longs:	move.l	d0,d1
		beq.s	conv_exit
		andi.l	#-4,d1		; divisible by 4?
		beq.s	sign_words
		sub.l	d1,d0		; adjust length
sign_loop4:	move.l	(a0)+,d2
		eori.l	#$80808080,d2
		move.l	d2,(a1)+
		subq.l	#4,d1
		bne.s	sign_loop4
		
sign_words:	move.l	d0,d1
		beq.s	conv_exit
		andi.l	#-2,d1		; divisible by 2?
		beq.s	sign_bytes
		sub.l	d1,d0
sign_loop2:	move.w	(a0)+,d2
		eori.w	#$8080,d2
		move.w	d2,(a1)+
		subq.l	#2,d1
		bne.s	sign_loop2
		
sign_bytes: 	move.l	d0,d1
		beq.s	conv_exit
		move.b	(a0)+,d2
		eori.b	#$80,d2
		move.b	d2,(a1)+
		subq.l	#1,d0
		bra.s	sign_bytes
		
; =============================================================
; converts 8-bit sample to 16-bit	(also: mono --> stereo)
; -->	A0 = Sample Start Address
;       	A1 = Sample Destination Address
;	D1 = Sample length (in bytes)
; <--	length of sample (double the 8-bit size)
; =============================================================

sample8_16:	move.l	d1,d0
		add.l	d0,d0
sample8_loop:	subq.l	#1,d1
		bmi.s	conv_exit	
		move.b	(a0),(a1)+
		move.b	(a0)+,(a1)+
		bra.s	sample8_loop

; =============================================================
; converts 16-bit sample naar 8-bit
; -->	A0 = Sample Start Address
;       	A1 = Sample Destination Address
;	D1 = Sample length (in bytes)
; <--	length of sample (half the 16-bit size)
; =============================================================

sample16_8:	lsr.l	#1,d1		; length\2
		move.l	d1,d0
sample16_loop:	subq.l	#1,d1
		bmi.s	conv_exit	
		move.b	(a0)+,d2
		or.b	(a0)+,d2
		move.b	d2,(a1)+
		bra.s	sample16_loop

; =============================================================
; subroutine chk_address checks if both source and destination
; addresses are at even word boundaries. d0=0: ok, d0=-1: error
; =============================================================

chk_address:	move.l	a0,d0
		andi.l	#1,d0
		bne.s	adr_exit
		move.l	a1,d0
		andi.l	#1,d0
adr_exit:		neg.l	d0
		rts
		
		
conv_exit:	rts
		

; =============================================================
; reverses 8-bit mono sample
; -->	A0 = Sample Start Address
;       	A1 = Sample Destination Address
;	D1 = Sample length (in bytes)
; <--	length of sample (=unchanged)
; =============================================================

reverse8:		move.l	d1,d0
		cmpa.l	a0,a1
		beq.s	rev_same		; reverse 'in place'
		add.l	d1,a1
reverse_loop:	subq.l	#1,d1
		bmi.s	conv_exit	
		move.b	(a0)+,-(a1)
		bra.s	reverse_loop
		
rev_same:		add.l	d1,a1
		lsr.l	#1,d1
same_loop:	subq.l	#1,d1
		bmi.s	conv_exit
		move.b	-(a1),d2
		move.b	(a0),(a1)
		move.b	d2,(a0)+
		bra.s	same_loop

; =============================================================
; reverses 16-bit mono or 8-bit stereo sample
; -->	A0 = Sample Start Address		EVEN
;       	A1 = Sample Destination Address	EVEN
;	D1 = Sample length (in bytes)
; <--	length of sample (=as it should be..)
; =============================================================

reverse16:	bsr.s	chk_address	; check if EVEN
		bne.s	conv_exit
		addq.l	#1,d1
		andi.l	#-2,d1		; divisible by 2
		move.l	d1,d0
		cmpa.l	a0,a1
		beq.s	rev_place		; reverse 'in place'
		add.l	d1,a1
		lsr.l	#1,d1
rev_loop:		subq.l	#1,d1
		bmi.s	conv_exit	
		move.w	(a0)+,-(a1)
		bra.s	rev_loop
		
rev_place:	add.l	d1,a1
		lsr.l	#2,d1
place_loop:	subq.l	#1,d1
		bmi.s	conv_exit
		move.w	-(a1),d2	
		move.w	(a0),(a1)	
		move.w	d2,(a0)+	
		bra.s	place_loop

; =============================================================
; reverses 16-bit stereo sample
; -->	A0 = Sample Start Address		EVEN
;       	A1 = Sample Destination Address	EVEN
;	D1 = Sample length (in bytes)
; <--	length of sample (=as it should be..)
; =============================================================

reverse32:	bsr.s	chk_address	; check if EVEN
		bne.s	conv_exit
		addq.l	#3,d1
		andi.l	#-4,d1		; divisible by 4
		move.l	d1,d0
		cmpa.l	a0,a1
		beq.s	rev_idem		; reverse 'in place'
		add.l	d1,a1
		lsr.l	#2,d1
rev_32loop:	subq.l	#1,d1
		bmi.s	conv_exit	
		move.l	(a0)+,-(a1)
		bra.s	rev_32loop
		
rev_idem:		add.l	d1,a1
		lsr.l	#3,d1
idem_loop:	subq.l	#1,d1
		bmi.s	conv_exit
		move.l	-(a1),d2	
		move.l	(a0),(a1)	
		move.l	d2,(a0)+	
		bra.s	idem_loop

; =============================================================
; adjusts volume for each byte in the sample
; (INcreasing volume can result in terrible quality...)
; -->	A0 = Sample Start Address
;       	A1 = Sample Destination Address
;	D1 = Sample length (in bytes)
; <--	rubbish: factor as put in
; =============================================================

volume:		moveq	#0,d0
		move.w	18(sp),d0		; factor*1000
		bmi.s	volsign		; negative means do signed sample
		cmpi.w	#1000,d0		; positive handles UNsigned sample
		beq	conv_exit
u_volume:		subq.l	#1,d1
		bmi	conv_exit
		moveq	#0,d2
		move.b	(a0)+,d2
		mulu.w	d0,d2
		divu.w	#1000,d2
		move.b	d2,(a1)+
		bra.s	u_volume
	
volsign:		cmpi.w	#-1000,d0
		beq	conv_exit
		neg.w	d0
s_volume:		subq.l	#1,d1
		bmi	conv_exit
		moveq	#0,d2
		move.b	(a0)+,d2
		ext.w	d2
		muls.w	d0,d2
		divs.w	#1000,d2
		move.b	d2,(a1)+
		bra.s	s_volume
