;Converts d0 to decimal in output buffer, leading zeros suppressed
;ENTRY d0.L=number to be converted
;      a0=address of output buffer
;EXIT  value stored as decimal in a0 buffer, NUL terminated
;      a0=address of last (NUL) chr

bin_dec	movem.l	d0-d2/a1,-(sp)
	tst.l	d0	check if zero
	beq	bin_dec5	and bra if 0
	move.l	#10-1,d1	No of iterations=10, bit 31=0
	move.l	#dec_table-4,a1	access power of 10 table
bin_dec1	adda.l	#4,a1	next power
	move	#'0'-1,d2	preset to '0'
bin_dec2	addq	#1,d2	inc digit
	sub.l	(a1),d0	& subtract
	bcc.s	bin_dec2	till negative
	add.l	(a1),d0	correct d0
	cmp.b	#'0',d2	bra if not zero
	bne.s	bin_dec3
	btst	#31,d1	bit 31=leading zero flag
	beq.s	bin_dec4	skip if leading zero
bin_dec3	bset	#31,d1	set flag if not
	move.b	d2,(a0)+	and output to buffer
bin_dec4	dbra	d1,bin_dec1	repeat 10 times
bin_dec6	clr.b	(a0)	set NUL
	movem.l	(sp)+,d0-d2/a1
	rts

bin_dec5	move.b	#'0',(a0)+	output one 0
	bra	bin_dec6	and exit
	
dec_table	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1

