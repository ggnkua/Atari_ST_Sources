; **	Depack for FIXED addresses.
;
; **    Patched to be called from GFA BASIC v3.6 by MUG U.K
;
; **	For use with v1.8 or greater.
; **	Routines are incompatible with v1.0 thru to v1.5.
;
; **	Start  = A4 = End of packed data (POPI)
; **	Finish = A2 = Start of unpack area.


unpack	movea.l	a4,a0			Start of packed file 
	movea.l	a2,a3			Finish address.
	subq.l	#4,a0
	add.l	-(a0),a2		add the oldsize.
	movea.l	a2,a4			Save end address for clearing
	subq.l	#4,a0			Skip new size.
	move.l	#$ff8240,a6
	move.w	(a6),d5			Save color

empty	move.b	-(a0),d0		Unpack data.
	beq.s	empty			Not empty.
umain	moveq	#0,d2
	bsr	shifter
	bcs.s	rep

	move.b	-(a0),d2
output	move.b	d2,-(a2)
	bra.s	ecxit

rep3	moveq	#15,d4			16bit in-operative.
	moveq	#2,d3
	bsr.s	leader
	bne.s	rloop
	move.w	d4,d2
	bra.s	output
		
rep	bsr.s	shifter
	bcc.s	repeat
	bsr.s	shifter
	bcc.s	rep3
	bsr.s	shifter
	bcs.s	rep4
special	moveq	#2,d1
	bsr	nibit
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	output
	
rep4	bsr.s	shifter
	bcc.s	rep5			V1.7 incompatability
	moveq	#15,d4			16bit in-operative.
	move.w	#3,d3
	bsr.s	leader
	bne.s	rloop
	move.b	(a2),-(a2)

ecxit	neg.w	(a6)
	move.w	d5,(a6)
	cmpa.l	a2,a3
	blt.s	umain
	rts

rep5	moveq	#4,d3
	bra.s	reps

; **	Offset bitsize is x bits depending upon D2.
; **	Also serves to reproduce RUNS , because an offset of 1 = same
; **	character repeated D3 times.

repeat	bsr.s	shifter
	bcs.s	rep2
	moveq	#1,d1
.1	lsr.b	#1,d0
	bne.s	.2
	move.b	-(a0),d0
	roxr.b	#1,d0
.2	addx.w	d2,d2
	dbf	d1,.1
	
	move.w	d2,d1			Copy bitcount
	beq.s	runing			If ZERO then do RUNS
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	nibit
	move.w	d2,d3
reps	bsr.s	lead1			Get offset size.
rloop	movea.l	a2,a1
	add.l	d2,a1			Add the offset.
replp	move.b	-(a1),-(a2)
	dbf	d3,replp
	bra.s	ecxit

shifter	lsr.b	#1,d0
	bne.s	noz
	move.b	-(a0),d0
	roxr.b	#1,d0
noz	rts

; **	Collect 2bit leader into D1
; **	Algorithm :- 2bits + 1 (1 to 4) * 4.
; **	Return the BITS in D2.

lead1	moveq	#0,d4			16bits operative.
leader	moveq	#1,d1

	moveq	#0,d2
n1	lsr.b	#1,d0
	bne.s	n2
	move.b	-(a0),d0
	roxr.b	#1,d0
n2	addx.w	d2,d2
	dbf	d1,n1

	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	nibit
	rts	
nibs	moveq	#7,d1
nibit	moveq	#0,d2
nlp	lsr.b	#1,d0
	bne.s	nlp1
	move.b	-(a0),d0
	roxr.b	#1,d0
nlp1	addx.w	d2,d2
	dbf	d1,nlp
	rts
runing	bsr.s	lead1			16bits operative
	move.w	d2,d3
	moveq	#1,d2
	bra.s	rloop
rep2	moveq	#1,d3			Size of loop.
	move.b	-(a0),d2
	bra.s	rloop
